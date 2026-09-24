# Handover: ACT-052 — CohortIncidence × OhdsiReportGenerator スキーマ不一致修正

**作成日**: 2026-04-17  
**対象リポジトリ**: `omop-analysis-assistant` (ブランチ: `feature/ohdsi-report-generator`)  
**HADES Docker**: `rinchu/hades:1.0.0`  
**Dockerfile**: `/Users/hirokikakimoto/github/omop-pipeline/8000_ohdsi_tools_docker/hades_setup/rstudio_4.4.3_hades_1.0.0.Dockerfile`

---

## 問題の概要

`include_ci: true` で OhdsiReportGenerator (ORG) を実行すると、Quarto レポートの `cohort_incidence` チャンクで以下のエラーが発生し HTML が生成されない。

```
Error in value[[3L]]():
! ... no such column: i.database_id
```

**影響シナリオ**: S2 (胃がん) / S4 (T2DM/CKD) の ORG レポートに CI セクションが欠落  
**現状の workaround**: フィクスチャで `include_ci: false` に設定（CI 分析は実行されるが ORG レポートに反映されない）

---

## 根本原因

### パッケージバージョン

| パッケージ | バージョン | インストール方式 |
|---|---|---|
| CohortIncidence | **4.1.1** (2026-03-03 リリース) | `remotes::install_github('OHDSI/CohortIncidence')` (バージョン固定なし) |
| OhdsiReportGenerator | **2.1.0** | `remotes::install_github('OHDSI/OhdsiReportGenerator')` (バージョン固定なし) |

### スキーマ不一致の詳細

**ORG 2.1.0** のクエリ（`getIncidenceRatesV0.sql`）:
```sql
-- ファイルパス（コンテナ内）:
-- /usr/local/lib/R/site-library/OhdsiReportGenerator/sql/sql_server/characterization/getIncidenceRatesV0.sql

FROM @schema.@ci_table_prefixINCIDENCE_SUMMARY i
  ...
INNER JOIN @schema.@database_table_name d
  ON d.database_id = i.database_id   -- ← i.database_id を期待
```

**CohortIncidence 4.1.1** の DDL (`incidence_summary` テーブル):
```sql
CREATE TABLE incidence_summary (
  ref_id int,
  source_name varchar(255),          -- ← database_id ではなく source_name
  target_cohort_definition_id bigint,
  ...
);
```

**経緯**: CI v3.0.0 (2024-06-30) でテーブル構造が再設計され `database_id` が `source_name` に変わった。ORG 2.1.0 はこの変更に追従していない。

---

## 修正方針

### 推奨: ORG の SQL ファイルをパッチ（CohortExplorer と同じアプローチ）

Dockerfile に `COPY` ステップを追加し、ORG の SQL ファイルを修正版で差し替える。CohortExplorer の Shiny バグパッチ（Dockerfile 末尾に既にある）と同じパターン。

#### 変更が必要な SQL ファイル

**ファイル**: `getIncidenceRatesV0.sql`  
コンテナ内パス: `/usr/local/lib/R/site-library/OhdsiReportGenerator/sql/sql_server/characterization/getIncidenceRatesV0.sql`

**変更箇所（1か所のみ）**:

```sql
-- 修正前
INNER JOIN @schema.@database_table_name d
  ON d.database_id = i.database_id

-- 修正後
INNER JOIN @schema.@database_table_name d
  ON d.database_id = i.source_name
```

#### ⚠️ 前提条件の確認（必須）

`source_name` に何が入るかを事前に確認すること。

`ci_incidence_summary.source_name` の値が `database_meta_data.database_id` の値（= `{{ ds.database }}`、例: `"OHDSI"`）と一致していないと JOIN が空振りしてレポートが空になる。

確認方法:
```r
# HADES コンテナ内で実行
con <- DBI::dbConnect(RSQLite::SQLite(), '/path/to/results_db.sqlite')
DBI::dbGetQuery(con, "SELECT DISTINCT source_name FROM ci_incidence_summary")
DBI::dbGetQuery(con, "SELECT database_id FROM database_meta_data")
DBI::dbDisconnect(con)
```

- **一致する場合**: SQL パッチのみで完結
- **一致しない場合**: 追加対応が必要（後述）

#### Dockerfile への追加手順

1. パッチ適用済みファイルを作成:

```bash
# omop-pipeline リポジトリの ohdsi_issue/ 配下に配置（CohortExplorer パッチと同じ場所）
cp \
  /usr/local/lib/R/site-library/OhdsiReportGenerator/sql/sql_server/characterization/getIncidenceRatesV0.sql \
  ohdsi_issue/OhdsiReportGenerator_getIncidenceRatesV0_patched.sql

# source_name に修正
sed -i 's/ON d\.database_id = i\.database_id/ON d.database_id = i.source_name/' \
  ohdsi_issue/OhdsiReportGenerator_getIncidenceRatesV0_patched.sql
```

2. Dockerfile (`rstudio_4.4.3_hades_1.0.0.Dockerfile`) に追加:

```dockerfile
# CohortExplorer パッチの直後（runtime ステージの前）に追加
# OhdsiReportGenerator v2.1.0 CohortIncidence スキーマパッチ
# Issue: ORG の getIncidenceRatesV0.sql が CI v3+ の source_name ではなく
#        CI v2 以前の database_id を参照しているため include_ci=true 時に失敗
COPY ohdsi_issue/OhdsiReportGenerator_getIncidenceRatesV0_patched.sql \
    /usr/local/lib/R/site-library/OhdsiReportGenerator/sql/sql_server/characterization/getIncidenceRatesV0.sql
```

3. `rstudio_4.4.3_hades_1.0.0.md` のパッチ一覧テーブルに記載を追加。

---

### source_name と database_id が一致しない場合の追加対応

CI の `source_name` が `database_id` と異なる値の場合、2つの追加対応が必要。

**対応 A: CI テンプレートで source_name を明示設定**

`backend/app/expert_templates/cohort_incidence.R.j2` の `buildOptions` を修正:

```r
# 現在:
buildOpts <- CohortIncidence::buildOptions(
  cohortTable           = paste0(cohortDatabaseSchema, ".", cohortTable),
  cdmDatabaseSchema     = cdmDatabaseSchema,
  resultsDatabaseSchema = cohortDatabaseSchema,
  refId                 = 1L
)

# 修正後（sourceName を追加 — ds.database と一致させる）:
buildOpts <- CohortIncidence::buildOptions(
  cohortTable           = paste0(cohortDatabaseSchema, ".", cohortTable),
  cdmDatabaseSchema     = cdmDatabaseSchema,
  resultsDatabaseSchema = cohortDatabaseSchema,
  refId                 = 1L,
  sourceName            = "{{ ds.database }}"
)
```

**対応 B: RMM テンプレートで挿入後に source_name を上書き**

`backend/app/expert_templates/result_model_manager.R.j2` の CI 挿入ブロックに追加:

```r
# 全行の source_name を database_id と統一（ORG の JOIN 条件に合わせるため）
DatabaseConnector::executeSql(
  connection        = rmmConnection,
  sql               = "UPDATE main.ci_incidence_summary SET source_name = '{{ ds.database }}';",
  progressBar       = FALSE,
  reportOverallTime = FALSE
)
```

---

## 現状コードとの関係

### 現在の workaround（削除対象）

`result_model_manager.R.j2` に以下の ALTER TABLE パッチが入っている（本修正完了後に削除可）:

```r
# OhdsiReportGenerator Quarto expects database_id column in ci_incidence_summary.
# CohortIncidence uses source_name instead — add database_id for compatibility.
tryCatch({
  DatabaseConnector::executeSql(
    connection = rmmConnection,
    sql = "ALTER TABLE main.ci_incidence_summary ADD COLUMN database_id VARCHAR;",
    ...
  )
  DatabaseConnector::executeSql(
    connection = rmmConnection,
    sql = "UPDATE main.ci_incidence_summary SET database_id = '{{ ds.database }}';",
    ...
  )
}, error = function(e) { ... })
```

このブロックを削除し、上記の Dockerfile パッチ方式に置き換える。

### フィクスチャの include_ci 設定（要復元）

以下のフィクスチャを `include_ci: false` → `include_ci: true` に戻す:

- `backend/tests/fixtures/s2_gastric_cancer_full.json` — `s2_org_001` ステップの params
- `backend/tests/fixtures/s4_t2dm_ckd_full.json` — `s4_org_001` ステップの params

---

## 検証手順

### Layer 2（レンダリング確認）

```bash
cd backend && uv run pytest tests/ --ignore=tests/test_expert_r_execution.py -q
# 期待: 133 passed
```

### Layer 3（R 実行確認）

```bash
cd backend
uv run pytest tests/test_expert_r_execution.py::test_s2_gastric_cancer_full_pipeline -v -m slow
uv run pytest tests/test_expert_r_execution.py::test_s4_t2dm_ckd_full_pipeline -v -m slow
```

確認ポイント:
```
OhdsiReportGenerator: HTML report at expert_output_XXXXXXXX/results/ohdsi_report.html
```
ORG HTML が生成されること。加えて、生成された HTML を開いて **Incidence Rate** セクションにデータが表示されること（空でないこと）を目視確認。

### Docker 再ビルド

インクリメンタルビルド用 Dockerfile があれば:
```bash
# rstudio_hades_incremental.Dockerfile でパッチファイルのみ適用
docker build -f rstudio_hades_incremental.Dockerfile -t rinchu/hades:1.0.1 .
```

---

## 関連ファイル一覧

| ファイル | 変更要否 | 内容 |
|---|---|---|
| `hades_setup/rstudio_4.4.3_hades_1.0.0.Dockerfile` | **追加** | ORG SQL パッチの COPY ステップ |
| `hades_setup/rstudio_4.4.3_hades_1.0.0.md` | **追加** | パッチ記録 |
| `ohdsi_issue/OhdsiReportGenerator_getIncidenceRatesV0_patched.sql` | **新規** | 修正済み SQL ファイル |
| `backend/app/expert_templates/result_model_manager.R.j2` | **削除** | ALTER TABLE workaround ブロックを削除 |
| `backend/app/expert_templates/cohort_incidence.R.j2` | **条件付き** | source_name 不一致の場合のみ `sourceName` 追加 |
| `backend/tests/fixtures/s2_gastric_cancer_full.json` | **変更** | `include_ci: false` → `include_ci: true` |
| `backend/tests/fixtures/s4_t2dm_ckd_full.json` | **変更** | `include_ci: false` → `include_ci: true` |

---

## 参考: GitHub 調査結果

- **ORG `getIncidenceRatesV0.sql`**: `ON d.database_id = i.database_id` を使用（CI v2.x 向け）
- **CI DDL** (`resultsSchema.sql`): v3.0.0 (2024-06-30) から `source_name` に統一。`database_id` カラムなし
- **ORG の DESCRIPTION**: CohortIncidence の依存バージョン要件の明記なし
- **結論**: ORG 2.1.0 は CI v2.x 前提で書かれており、CI v3+ とは非互換
