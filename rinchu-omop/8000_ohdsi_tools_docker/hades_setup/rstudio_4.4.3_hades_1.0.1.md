# rinchu/hades:1.0.1 — インストール済みアプリ・バージョン一覧

> 最終更新: 2026-04-18
> 動作確認: `hades_package_test.R` 37/37 成功（2026-03-26 03:23）

> **ビルドDockerfile**: `hades_setup/rstudio_4.4.3_hades_1.0.1.Dockerfile`
> **ビルド構成**: 4ステージマルチステージビルド（R / RStudio / HADES前提 / HADES分析パッケージ）
> **対応アーキテクチャ**: linux/amd64, linux/arm64 (Apple Silicon)
> **ビルド状況**: ✅ ビルド定義更新済（2026-04-22）
> **1.0.0 からの変更**: OhdsiReportGenerator `getIncidenceRatesV0.sql` CohortIncidence スキーマパッチ追加、OhdsiReportGenerator presentation テンプレートパッチ追加、Characterization `CreateTargetCohortTable.sql` attrition 列幅パッチ追加、CohortGenerator `CreateCohortTables.sql` BIGINT→INT パッチ追加、TreatmentPatterns 可視化依存パッケージ（sunburstR / networkD3）追加

### 基盤ソフトウェア

| アプリ | バージョン | 取得元 | v1.0.1 ビルド進捗 |
|-------|---------|-------|-----------------|
| OS | Ubuntu 24.04 LTS (noble) | https://hub.docker.com/_/ubuntu | ✅ S1 |
| R | 4.4.3 (2025-02-28) | rocker-org/rocker-versioned2 スクリプト | ✅ S1 |
| RStudio Server | 2024.12.1+563 | https://posit.co/download/rstudio-server/ | ✅ S2 |
| Pandoc | （RStudio同梱版） | RStudio インストーラ同梱 | ✅ S2 |
| Quarto | （RStudio同梱版） | RStudio インストーラ同梱 | ✅ S2 |
| Java | Amazon Corretto 1.8 | https://aws.amazon.com/corretto/ | ✅ S3 |
| PostgreSQL JDBC Driver | 42.7.8 | https://jdbc.postgresql.org/ | ✅ S3 |
| Redshift JDBC Driver | 2.1.0.x（DatabaseConnector::downloadJdbcDrivers 経由） | https://docs.aws.amazon.com/redshift/latest/mgmt/jdbc20-download-driver.html | ✅ S3 |
| SQL Server JDBC Driver | 9.2.0（DatabaseConnector::downloadJdbcDrivers 経由） | https://learn.microsoft.com/sql/connect/jdbc/microsoft-jdbc-driver-for-sql-server | ✅ S3 |
| Oracle JDBC Driver | 19.8（ojdbc8、DatabaseConnector::downloadJdbcDrivers 経由） | https://www.oracle.com/database/technologies/appdev/jdbc-downloads.html | ✅ S3 |

---

### HADES R パッケージ — インストール済み（37 / 39パッケージ）

> 公式 HADES パッケージ一覧: https://ohdsi.github.io/Hades/packages.html
> バージョンは `rinchu/hades:1.0.0` 最終ビルドでの確認値（2026-03-26、`hades_package_test.R` 37/37 成功）。パッケージ構成は 1.0.1 でも変更なし。
> 取得元: 全パッケージ `remotes::install_github()` で GitHub から直接取得
> CRAN 依存: RSPM (`https://packagemanager.posit.co/cran/__linux__/noble/latest`) からバイナリ優先

#### Supporting（基盤・共通ライブラリ）

| パッケージ | バージョン | 取得元 | v1.0.1 ビルド進捗 |
|----------|---------|-------|-----------------|
| SqlRender | 1.19.5 | GitHub (OHDSI/SqlRender) | ✅ |
| DatabaseConnector | 7.1.0 | GitHub (OHDSI/DatabaseConnector) | ✅ |
| Cyclops | 3.6.0 | GitHub (OHDSI/Cyclops) | ✅ |
| Andromeda | 1.2.0 | GitHub (OHDSI/Andromeda) | ✅ |
| FeatureExtraction | 3.13.0 | GitHub (OHDSI/FeatureExtraction) | ✅ |
| ParallelLogger | 3.5.1 | GitHub (OHDSI/ParallelLogger) | ✅ |
| BigKnn | 1.0.2 | GitHub (OHDSI/BigKnn) | ✅ |
| ROhdsiWebApi | 1.3.3 | GitHub (OHDSI/ROhdsiWebApi) | ✅ |
| OhdsiSharing | 0.2.2 | GitHub (OHDSI/OhdsiSharing) | ✅ |
| Eunomia | 2.1.0 | GitHub (OHDSI/Eunomia) | ✅ |
| BrokenAdaptiveRidge | 1.0.1 | GitHub (OHDSI/BrokenAdaptiveRidge) | ✅ |
| IterativeHardThresholding | 1.0.3 | GitHub (OHDSI/IterativeHardThresholding) | ✅ |
| ResultModelManager | 0.6.2 | GitHub (OHDSI/ResultModelManager) | ✅ |
| OhdsiShinyModules | 3.5.0 | GitHub (OHDSI/OhdsiShinyModules) | ✅ |
| OhdsiShinyAppBuilder | 1.0.0 | GitHub (OHDSI/OhdsiShinyAppBuilder) | ✅ |
| OhdsiReportGenerator | 2.1.0 | GitHub (OHDSI/OhdsiReportGenerator) | ✅ **パッチ適用済** |
| Strategus | 1.5.0 | GitHub (OHDSI/Strategus) | ✅ |

#### Evidence Quality（エビデンスの質）

| パッケージ | バージョン | 取得元 | v1.0.1 ビルド進捗 |
|----------|---------|-------|-----------------|
| Achilles | 1.8 | GitHub (OHDSI/Achilles) | ✅ |
| DataQualityDashboard | 2.8.7 | GitHub (OHDSI/DataQualityDashboard) | ✅ |
| EmpiricalCalibration | 3.1.4 | GitHub (OHDSI/EmpiricalCalibration) | ✅ |
| MethodEvaluation | 2.4.0 | GitHub (OHDSI/MethodEvaluation) | ✅ |

#### Cohort Construction & Evaluation（コホート構築・評価）

| パッケージ | バージョン | 取得元 | v1.0.1 ビルド進捗 |
|----------|---------|-------|-----------------|
| CirceR | 1.3.3 | GitHub (OHDSI/CirceR) | ✅ |
| CohortDiagnostics | 3.4.2 | GitHub (OHDSI/CohortDiagnostics) | ✅ |
| CohortGenerator | 1.1.0 | GitHub (OHDSI/CohortGenerator) | ✅ **パッチ適用済** |
| Capr | 2.1.1 | GitHub (OHDSI/Capr) | ✅ |
| PhenotypeLibrary | 3.36.0 | GitHub (OHDSI/PhenotypeLibrary) | ✅ |
| PheValuator | 2.2.16 | GitHub (OHDSI/PheValuator) | ✅ |
| CohortExplorer | 0.1.0 | GitHub (OHDSI/CohortExplorer) | ✅ **パッチ適用済** |
| Keeper | 0.2.1 | GitHub (OHDSI/Keeper) | ✅ |

#### Population-level Estimation（母集団レベルの推定）

| パッケージ | バージョン | 取得元 | v1.0.1 ビルド進捗 |
|----------|---------|-------|-----------------|
| CohortMethod | 6.0.1 | GitHub (OHDSI/CohortMethod) | ✅ |
| SelfControlledCaseSeries | 6.1.1 | GitHub (OHDSI/SelfControlledCaseSeries) | ✅ |
| SelfControlledCohort | 1.6.0 | GitHub (OHDSI/SelfControlledCohort) | ✅ |

#### Patient-level Prediction（患者レベルの予測）

| パッケージ | バージョン | 取得元 | v1.0.1 ビルド進捗 |
|----------|---------|-------|-----------------|
| PatientLevelPrediction | 6.6.0 | GitHub (OHDSI/PatientLevelPrediction) | ✅ |
| EnsemblePatientLevelPrediction | 1.0.3 | GitHub (OHDSI/EnsemblePatientLevelPrediction) | ✅ |

#### Characterization（特性解析）

| パッケージ | バージョン | 取得元 | v1.0.1 ビルド進捗 |
|----------|---------|-------|-----------------|
| Characterization | 3.0.0 | GitHub (OHDSI/Characterization) | ✅ **パッチ適用済** |
| CohortIncidence | 4.1.1 | GitHub (OHDSI/CohortIncidence) | ✅ |
| TreatmentPatterns | 3.1.2 | GitHub (darwin-eu-dev/TreatmentPatterns) | ✅ **追加パッケージあり** |

---

### HADES R パッケージ — インストール除外（2 / 39パッケージ）

#### EvidenceSynthesis ❌ — 依存ライブラリのバージョン競合

| 項目 | 内容 |
|-----|-----|
| カテゴリ | Population-level Estimation |
| 取得元（予定） | GitHub (OHDSI/EvidenceSynthesis) |
| エラー内容 | `BeastJar >= 10.5.1` が必要だが、インストール済みは `BeastJar 1.x` |
| 除外理由 | BeastJar を 1.x → 10.x にアップグレードすると `MethodEvaluation` 等の既存パッケージが破損するリスクがある。BeastJar のメジャーバージョンアップを全体フルリビルドと同時に行うことで解決予定 |
| 対応予定 | 次回 R/RStudio バージョンアップ時のフルリビルドで BeastJar を最新版で一括インストール |

#### DeepPatientLevelPrediction ❌ — 依存環境の重量超過

| 項目 | 内容 |
|-----|-----|
| カテゴリ | Patient-level Prediction |
| 取得元（予定） | GitHub (OHDSI/DeepPatientLevelPrediction) |
| エラー内容 | Python / PyTorch / CUDA 環境を必要とする |
| 除外理由 | Python ランタイムおよび PyTorch（数GB規模）をコンテナに含めると、イメージサイズが過大になりデプロイ・配布に支障をきたす。GPU 環境が必要なため汎用 CPU コンテナには不適 |
| 対応予定 | 対応する場合は GPU 対応の専用コンテナとして別途構築する |

---

### 取得元の内訳

| 取得元 | パッケージ数 | 備考 |
|-------|-----------|-----|
| GitHub (`remotes::install_github()`) | 37 | 全 HADES パッケージ。CRAN 依存は RSPM バイナリ優先 |
| インストール除外 | 2 | 依存関係の競合 / 重量超過 |
| **合計（HADES公式39パッケージ）** | **39** | |

> **TreatmentPatterns について**: OHDSI 公式ではなく `darwin-eu-dev` が開発元。
> `OHDSI/TreatmentPatterns` は GitHub に存在しない（HTTP 404）。

---

### ビルド後パッチ: CohortExplorer v0.1.0 Shiny バグ修正（2026-03-26）

CohortExplorer v0.1.0 の `createCohortExplorerApp()` が生成する Shiny アプリで、患者タイムラインが `Error: [object Object]` で表示されないバグに対するパッチ。

- **OHDSI Issue**: https://github.com/OHDSI/CohortExplorer/issues/38
- **原因**: R 4.4.x 環境固有の問題（R 4.2.x では暗黙の型変換により顕在化しなかった）
- **パッチファイル**: `ohdsi_issue/CohortExplorer_server_patched.R`
- **Dockerfile 適用方法**: `COPY` でテンプレート `server.R` を差し替え（cleanup ステップ後、runtime ステージ前）
- **詳細ドキュメント**: `ohdsi_issue/CohortExplorer_issue_fix.md`, `ohdsi_issue/CohortExplorer_issue_patch.md`

| # | 修正内容 | 対象行 | 問題 |
|---|---------|-------|------|
| 1 | `daysToFirst` を `as.integer(as.Date(...) - as.Date(...))` に型統一 | 220行目 | Date-POSIXt 型不整合で `abs()` エラー |
| 2 | `dataFromRds` reactive に `shiny::req()` ガード追加 | 5行目 | input 初期化前の評価で NULL エラー |
| 3 | `queryResult` reactive に `shiny::req()` ガード追加 | 63行目 | `dataFromRds()` が NULL 時に `filter()` エラー |

> このパッチは CohortExplorer v0.1.0 固有。OHDSI 側で修正版がリリースされた場合はパッチを除去し、通常の `install_github` に戻す。

---

### ビルド後パッチ: OhdsiReportGenerator v2.1.0 CohortIncidence スキーマ修正（2026-04-17）

OhdsiReportGenerator v2.1.0 の `getIncidenceRatesV0.sql` が CohortIncidence v3+ の新スキーマに対応していないため、`include_ci: true` で Quarto レポートが生成されないバグに対するパッチ。

- **原因**: CI v3.0.0 (2024-06-30) でテーブル構造が再設計され `database_id` が `source_name` に変更されたが、ORG 2.1.0 は未追従
- **症状**: `Error: no such column: i.database_id`（OhdsiReportGenerator レポート生成失敗）
- **パッチファイル**: `ohdsi_issue/OhdsiReportGenerator_getIncidenceRatesV0_patched.sql`
- **Dockerfile 適用方法**: `COPY` で `getIncidenceRatesV0.sql` を差し替え（CohortExplorer パッチ直後）
- **詳細ドキュメント**: `ohdsi_issue/CohortIncidence_issue_fix.md`

| # | 修正内容 | 対象ファイル |
|---|---------|-----------|
| 1 | `ON d.database_id = i.database_id` → `ON d.database_id = i.source_name` | `getIncidenceRatesV0.sql` |

> このパッチは OhdsiReportGenerator v2.1.0 固有。ORG 側で修正版がリリースされた場合はパッチを除去し、通常の `install_github` に戻す。

---

### ビルド後パッチ: OhdsiReportGenerator v2.1.0 presentation テンプレート修正（2026-04-18）

OhdsiReportGenerator v2.1.0 の presentation テンプレート群に parse error となる `seq_len()` の閉じ括弧欠落と、`cohort_incidence_template.qmd` の dplyr data masking による `tar` 列名衝突があるため、`generatePresentation()` が失敗するバグに対するパッチ。

- **原因**: `assure_presentation.qmd` / `cohort_definitions.qmd` / `characterization.qmd` / `cohort_incidence_template.qmd` / `sccs.qmd` に計 12 箇所の `seq_len()` 閉じ括弧欠落があり、さらに `cohort_incidence_template.qmd` は loop 変数 `tar` が tibble 列 `tar` と衝突する
- **症状**: `generatePresentation()` が `parse error` または `tar$tarStartWith` の data masking error で失敗し、`continuing without presentation` にフォールバックする
- **パッチファイル**:
  `ohdsi_issue/OhdsiReportGenerator_assure_presentation_patched.qmd`
  `ohdsi_issue/OhdsiReportGenerator_cohort_definitions_patched.qmd`
  `ohdsi_issue/OhdsiReportGenerator_characterization_patched.qmd`
  `ohdsi_issue/OhdsiReportGenerator_cohort_incidence_template_patched.qmd`
  `ohdsi_issue/OhdsiReportGenerator_sccs_patched.qmd`
- **Dockerfile 適用方法**: `COPY` で presentation テンプレート 5 ファイルを差し替え（ORG SQL パッチ直後）

| # | 修正内容 | 対象ファイル |
|---|---------|-----------|
| 1 | `lapply(seq_len(nrow(subsets), function(i){` → `lapply(seq_len(nrow(subsets)), function(i){` | `assure_presentation.qmd` |
| 2 | `for(... in seq_len(...){` → `for(... in seq_len(...)){` を 11 箇所修正 | `cohort_definitions.qmd`, `characterization.qmd`, `cohort_incidence_template.qmd`, `sccs.qmd` |
| 3 | ループ変数 `tar` を `tarInfo` に変更 | `cohort_incidence_template.qmd` |

> このパッチは OhdsiReportGenerator v2.1.0 固有。ORG 側で修正版がリリースされた場合はパッチを除去し、通常の `install_github` に戻す。

---

### ビルド後パッチ: Characterization v3.0.0 attrition 列幅修正（2026-04-18）

Characterization v3.0.0 の `CreateTargetCohortTable.sql` が attrition 一時テーブルを `attr_reason VARCHAR(50)` で作成する一方、`NonCaseCohorts.sql` は 50 文字を超える固定文言を INSERT するため、risk factor cohort generation 中に SQL エラーで失敗するバグに対するパッチ。

- **原因**: `CreateTargetCohortTable.sql` の attrition 一時テーブル定義が `ResultTables.sql` の `attr_reason VARCHAR(200)` と不整合
- **症状**: `ERROR: value too long for type character varying(50)` により Characterization が abort し、ORG の `Risk Factors` セクションが空になる
- **パッチファイル**: `ohdsi_issue/Characterization_CreateTargetCohortTable_patched.sql`
- **Dockerfile 適用方法**: `COPY` で `CreateTargetCohortTable.sql` を差し替え（ORG パッチ直後）

| # | 修正内容 | 対象ファイル |
|---|---------|-----------|
| 1 | `attr_reason VARCHAR(50)` → `attr_reason VARCHAR(200)` | `CreateTargetCohortTable.sql` |

> このパッチは Characterization v3.0.0 固有。OHDSI 側で修正版がリリースされた場合はパッチを除去し、通常の `install_github` に戻す。

---

### ビルド後パッチ: CohortGenerator v1.1.0 DDL 型修正（2026-04-22）

CohortGenerator v1.1.0 の `CreateCohortTables.sql` が `cohort_definition_id` / `subject_id` を `BIGINT` で定義するため、JDBC 経由で R に読み込まれた値が `integer64`（bit64 クラス）になり、TreatmentPatterns が内部で使用する Andromeda（SQLite バックエンド）への `copy_to` で型が壊れて `computePathways` が全件 0 を返すバグに対するパッチ。

- **原因チェーン**: PostgreSQL BIGINT → JDBC → R `integer64` → Andromeda `copy_to` → SQLite が integer64 を正しく扱えず全件フィルタアウト
- **症状**: `minEraDuration` フィルタ後の件数が 0 になり `treatment_pathways.csv` が空になる
- **Dockerfile 適用方法**: `RUN sed -i` で `cohort_definition_id BIGINT` / `subject_id BIGINT` を `INT` に置換（Characterization パッチ直後）
- **変更対象**: `/usr/local/lib/R/site-library/CohortGenerator/sql/sql_server/CreateCohortTables.sql`

| # | 修正内容 | 対象カラム |
|---|---------|---------|
| 1 | `cohort_definition_id BIGINT` → `cohort_definition_id INT` | JOIN キー（OHDSI CDM 仕様は INTEGER） |
| 2 | `subject_id BIGINT` → `subject_id INT` | JOIN キー（OHDSI CDM 仕様は INTEGER） |

> `person_count BIGINT` / `inclusion_rule_mask BIGINT` は件数・マスクビットのため変更しない。
> このパッチは CohortGenerator v1.1.0 固有。OHDSI 側で修正版がリリースされた場合はパッチを除去し、通常の `install_github` に戻す。

---

### パッケージ追加: TreatmentPatterns 可視化依存（sunburstR / networkD3 + libglpk40）（2026-04-22）

TreatmentPatterns v3.1.2 のオプション依存パッケージ（可視化）が `rinchu/hades:1.0.1` ベースイメージに含まれておらず、sunburst.html / sankey.html が生成されない問題への対応。根本原因は2層構造。

**層 1: R パッケージ未収録**
`sunburstR` / `networkD3` がイメージに未収録のため TreatmentPatterns が可視化をスキップする。

**層 2: igraph の実行時リンク依存（networkD3 のみ）**
`networkD3` は内部で `igraph` を使用し、`igraph` は `libglpk.so.40` を実行時リンクする。
ベースイメージに `libglpk` が未収録のため、R パッケージをインストールしても `library(networkD3)` がロードエラーになる。

```
Error: unable to load shared object 'igraph.so':
  libglpk.so.40: cannot open shared object file: No such file or directory
```

**確認済み状況（2026-04-22 実行テスト）**: `sunburst.html` ✅ / `sankey.html` ❌（libglpk なし）

- **Dockerfile 適用方法**: `apt-get install -y libglpk40` を先に実行し、その後 `install.packages()` で R パッケージを追加（TreatmentPatterns インストール直後）

| 追加内容 | 種別 | 用途 |
|---------|------|-----|
| `libglpk40` | apt システムライブラリ | igraph の実行時リンク依存（networkD3 経由） |
| `sunburstR` | CRAN R パッケージ | `createSunburstPlot()` — Sunburst チャート生成 |
| `networkD3` | CRAN R パッケージ | `createSankeyDiagram()` — Sankey ダイアグラム生成 |

> `libglpk40` が見つからない場合は `libglpk-dev` または `apt-cache search glpk` で確認すること（Ubuntu バージョン差異）。

---

### runtime ステージ システムライブラリ追加履歴と注意事項

#### 追加済みシステムライブラリ一覧

| ライブラリ | 追加日 | 依存チェーン | 症状 |
|----------|-------|------------|------|
| `libglpk40` | 2026-04-22 | `networkD3` → `igraph` → `libglpk.so.40` | `library(networkD3)` がロードエラー |
| `libuv1t64` | 2026-04-22 | `fs` → `libuv.so.1` | `library(fs)` がロードエラー、OhdsiReportGenerator が落ちる |

#### 注意: apt キャッシュ bust による暗黙依存の消失

runtime ステージの `apt-get install` ブロックに変更を加えると、そのステップの **Docker キャッシュが無効化**され fresh 実行になる。
以前のキャッシュ済みレイヤーで推移的依存として入っていたシステムライブラリが、新しい apt 解決では含まれなくなることがある。

**影響が出るパターン**:
- runtime apt ブロックへのパッケージ追加・削除
- `apt-get update` の結果が変わる（apt ミラーのパッケージバージョン更新）

**診断方法**: `library(パッケージ名)` がロードエラーになった場合、以下で依存 `.so` を確認する。

```bash
docker exec hades ldd /usr/local/lib/R/site-library/<pkg>/libs/<pkg>.so \
  | grep "not found"
```

見つかったライブラリ名から apt パッケージを特定し、runtime ステージの apt ブロックに明示追加する。

```bash
# パッケージ名の調べ方
apt-file search libXXX.so.N   # または
dpkg -S libXXX.so.N
```
