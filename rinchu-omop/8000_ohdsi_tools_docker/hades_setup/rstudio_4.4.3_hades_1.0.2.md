# rinchu/hades:1.0.2 — インストール済みアプリ・バージョン一覧

> 最終更新: 2026-07-31
> 動作確認: `rstudio_4.4.3_hades_1.0.2_check.R` 37/37 成功（2026-07-31 13:53、`LD_LIBRARY_PATH` を注入しない素の `docker run` で実行）
> — Java/JVM・JDBC 4 種・ビルド後パッチ 4 件もすべて ✅

> **ビルドDockerfile**: `hades_setup/rstudio_4.4.3_hades_1.0.2.Dockerfile`
> **ビルド構成**: 4ステージマルチステージビルド（R / RStudio / HADES前提 / HADES分析パッケージ）
> **対応アーキテクチャ**: linux/amd64, linux/arm64 (Apple Silicon)
> **ビルド状況**: ✅ フルビルド完了（2026-07-31、macOS arm64。Stage 1 の R ソースビルドから全ステージ再構築）
> **イメージサイズ**: 4.22GB（site-library は cleanup で 1.4G → 451M）
> **1.0.1 からの変更**: HADES パッケージ 18 本のバージョン更新（下表参照）、OhdsiShinyAppBuilder をコミット固定から `v1.1.0` タグ固定に変更、OhdsiReportGenerator presentation テンプレートパッチの陳腐化（ORG 2.3.0 でも当該機能は upstream 非搭載。後述）

---

### 1.0.1 → 1.0.2 バージョン更新一覧（18 パッケージ）

| パッケージ | 1.0.1 | 1.0.2 | 備考 |
|----------|-------|-------|-----|
| DatabaseConnector | 7.1.0 | **7.2.0** | |
| Cyclops | 3.6.0 | **3.7.1** | |
| duckdb | 1.3.0 | **1.5.5** | Andromeda バックエンド |
| Andromeda | 1.2.0 | **1.2.1** | |
| FeatureExtraction | 3.13.0 | **3.14.0** | |
| DataQualityDashboard | 2.8.7 | **2.8.9** | |
| MethodEvaluation | 2.4.0 | **2.4.1** | |
| CohortGenerator | 1.1.0 | **1.1.1** | BIGINT→INT パッチは継続必要 |
| PhenotypeLibrary | 3.36.0 | **3.37.0** | |
| PheValuator | 2.2.16 | **2.2.17** | |
| Keeper | 0.2.1 | **2.1.3** | メジャーバージョンアップ |
| CohortMethod | 6.0.1 | **6.0.3** | |
| SelfControlledCaseSeries | 6.1.1 | **6.1.5** | |
| SelfControlledCohort | 1.6.0 | **2.0.0** | メジャーバージョンアップ |
| Characterization | 3.0.0 | **3.0.1** | attrition 列幅パッチは継続必要 |
| OhdsiReportGenerator | 2.1.0 | **2.3.0** | ⚠️ presentation 機能が削除（後述） |
| OhdsiShinyModules | 3.5.0 | **3.6.0** | |
| OhdsiShinyAppBuilder | `edb96fb`（コミット固定） | **1.1.0**（タグ固定） | 全パッケージのタグ固定化が完了 |

> これにより Dockerfile 内の `remotes::install_github()` は **全 37 パッケージがタグまたはコミットで明示固定**された状態を維持している（Achilles のみ `113433da` のコミット固定。タグ未発行のため）。

---

### 基盤ソフトウェア

| アプリ | バージョン | 取得元 | v1.0.2 ビルド進捗 |
|-------|---------|-------|-----------------|
| OS | Ubuntu 24.04 LTS (noble) | https://hub.docker.com/_/ubuntu | ✅ S1 |
| R | 4.4.3 (2025-02-28) | rocker-org/rocker-versioned2 スクリプト | ✅ S1 |
| RStudio Server | 2024.12.1+563 | https://posit.co/download/rstudio-server/ | ✅ S2 |
| Pandoc | （RStudio同梱版） | RStudio インストーラ同梱 | ✅ S2 |
| Quarto | （RStudio同梱版） | RStudio インストーラ同梱 | ✅ S2 |
| Java | Amazon Corretto 1.8（実測 1.8.0_502） | https://aws.amazon.com/corretto/ | ✅ S3 |
| PostgreSQL JDBC Driver | 42.7.8 | https://jdbc.postgresql.org/ | ✅ S3 |
| Redshift JDBC Driver | 2.1.0.20（+ AWS SDK 1.12.493 一式、`DatabaseConnector::downloadJdbcDrivers` 経由） | https://docs.aws.amazon.com/redshift/latest/mgmt/jdbc20-download-driver.html | ✅ S3 |
| SQL Server JDBC Driver | 9.2.0（jre8、`DatabaseConnector::downloadJdbcDrivers` 経由） | https://learn.microsoft.com/sql/connect/jdbc/microsoft-jdbc-driver-for-sql-server | ✅ S3 |
| Oracle JDBC Driver | ojdbc8（`DatabaseConnector::downloadJdbcDrivers` 経由） | https://www.oracle.com/database/technologies/appdev/jdbc-downloads.html | ✅ S3 |

> JDBC ドライバーは `/jdbcdrivers` に計 23 ファイル（依存 jar 含む）を配置。

---

### HADES R パッケージ — インストール済み（37 / 39パッケージ）

> 公式 HADES パッケージ一覧: https://ohdsi.github.io/Hades/packages.html
> バージョンは `rinchu/hades:1.0.2` ビルド済みイメージ上での実測値（2026-07-31、37/37 ロード成功）。
> 取得元: 全パッケージ `remotes::install_github()` で GitHub から直接取得
> CRAN 依存: RSPM (`https://packagemanager.posit.co/cran/__linux__/noble/latest`) からバイナリ優先

#### Supporting（基盤・共通ライブラリ）

| パッケージ | バージョン | 取得元 | v1.0.2 ビルド進捗 |
|----------|---------|-------|-----------------|
| SqlRender | 1.19.5 | GitHub (OHDSI/SqlRender) | ✅ |
| DatabaseConnector | 7.2.0 | GitHub (OHDSI/DatabaseConnector) | ✅ **更新** |
| Cyclops | 3.7.1 | GitHub (OHDSI/Cyclops) | ✅ **更新** |
| Andromeda | 1.2.1 | GitHub (OHDSI/Andromeda) | ✅ **更新** |
| FeatureExtraction | 3.14.0 | GitHub (OHDSI/FeatureExtraction) | ✅ **更新** |
| ParallelLogger | 3.5.1 | GitHub (OHDSI/ParallelLogger) | ✅ |
| BigKnn | 1.0.2 | GitHub (OHDSI/BigKnn) | ✅ |
| ROhdsiWebApi | 1.3.3 | GitHub (OHDSI/ROhdsiWebApi) | ✅ |
| OhdsiSharing | 0.2.2 | GitHub (OHDSI/OhdsiSharing) | ✅ |
| Eunomia | 2.1.0 | GitHub (OHDSI/Eunomia) | ✅ |
| BrokenAdaptiveRidge | 1.0.1 | GitHub (OHDSI/BrokenAdaptiveRidge) | ✅ |
| IterativeHardThresholding | 1.0.3 | GitHub (OHDSI/IterativeHardThresholding) | ✅ |
| ResultModelManager | 0.6.2 | GitHub (OHDSI/ResultModelManager) | ✅ |
| OhdsiShinyModules | 3.6.0 | GitHub (OHDSI/OhdsiShinyModules) | ✅ **更新** |
| OhdsiShinyAppBuilder | 1.1.0 | GitHub (OHDSI/OhdsiShinyAppBuilder) | ✅ **更新（タグ固定化）** |
| OhdsiReportGenerator | 2.3.0 | GitHub (OHDSI/OhdsiReportGenerator) | ✅ **更新・パッチ適用済** |
| Strategus | 1.5.0 | GitHub (OHDSI/Strategus) | ✅ |

> **HADES 公式一覧外の同梱パッケージ**: `duckdb` 1.5.5（Andromeda バックエンド、`duckdb/duckdb-r` からタグ固定）、`shiny` 1.14.0 / `DT` 0.34.0（DataQualityDashboard・Shiny アプリ基盤）、`sunburstR` 2.1.8 / `networkD3` 0.4.1（TreatmentPatterns 可視化）。CRAN 由来のものは RSPM latest からバイナリ取得のためバージョン固定していない。

#### Evidence Quality（エビデンスの質）

| パッケージ | バージョン | 取得元 | v1.0.2 ビルド進捗 |
|----------|---------|-------|-----------------|
| Achilles | 1.8 | GitHub (OHDSI/Achilles、コミット `113433da` 固定) | ✅ |
| DataQualityDashboard | 2.8.9 | GitHub (OHDSI/DataQualityDashboard) | ✅ **更新** |
| EmpiricalCalibration | 3.1.4 | GitHub (OHDSI/EmpiricalCalibration) | ✅ |
| MethodEvaluation | 2.4.1 | GitHub (OHDSI/MethodEvaluation) | ✅ **更新** |

#### Cohort Construction & Evaluation（コホート構築・評価）

| パッケージ | バージョン | 取得元 | v1.0.2 ビルド進捗 |
|----------|---------|-------|-----------------|
| CirceR | 1.3.3 | GitHub (OHDSI/CirceR) | ✅ |
| CohortDiagnostics | 3.4.2 | GitHub (OHDSI/CohortDiagnostics) | ✅ |
| CohortGenerator | 1.1.1 | GitHub (OHDSI/CohortGenerator) | ✅ **更新・パッチ適用済** |
| Capr | 2.1.1 | GitHub (OHDSI/Capr) | ✅ |
| PhenotypeLibrary | 3.37.0 | GitHub (OHDSI/PhenotypeLibrary) | ✅ **更新** |
| PheValuator | 2.2.17 | GitHub (OHDSI/PheValuator) | ✅ **更新** |
| CohortExplorer | 0.1.0 | GitHub (OHDSI/CohortExplorer) | ✅ **パッチ適用済** |
| Keeper | 2.1.3 | GitHub (OHDSI/Keeper) | ✅ **更新（メジャー）** |

#### Population-level Estimation（母集団レベルの推定）

| パッケージ | バージョン | 取得元 | v1.0.2 ビルド進捗 |
|----------|---------|-------|-----------------|
| CohortMethod | 6.0.3 | GitHub (OHDSI/CohortMethod) | ✅ **更新** |
| SelfControlledCaseSeries | 6.1.5 | GitHub (OHDSI/SelfControlledCaseSeries) | ✅ **更新** |
| SelfControlledCohort | 2.0.0 | GitHub (OHDSI/SelfControlledCohort) | ✅ **更新（メジャー）** |

#### Patient-level Prediction（患者レベルの予測）

| パッケージ | バージョン | 取得元 | v1.0.2 ビルド進捗 |
|----------|---------|-------|-----------------|
| PatientLevelPrediction | 6.6.0 | GitHub (OHDSI/PatientLevelPrediction) | ✅ |
| EnsemblePatientLevelPrediction | 1.0.3 | GitHub (OHDSI/EnsemblePatientLevelPrediction) | ✅ |

#### Characterization（特性解析）

| パッケージ | バージョン | 取得元 | v1.0.2 ビルド進捗 |
|----------|---------|-------|-----------------|
| Characterization | 3.0.1 | GitHub (OHDSI/Characterization) | ✅ **更新・パッチ適用済** |
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
| 除外理由 | BeastJar を 1.x → 10.x にアップグレードすると `MethodEvaluation` 等の既存パッケージが破損するリスクがある |
| 対応予定 | 次回 R/RStudio バージョンアップ時のフルリビルドで BeastJar を最新版で一括インストール |

> **注**: 1.0.2 は Stage 1 からのフルリビルドだったが、BeastJar の一括更新は今回スコープに含めていない（パッケージバージョン更新のみの版のため）。EvidenceSynthesis の解消は引き続き R/RStudio バージョンアップ時の課題として持ち越し。

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

### runtime ステージ: `ENV LD_LIBRARY_PATH`（削除禁止）

runtime ステージには `ENV JAVA_HOME` に加えて **`ENV LD_LIBRARY_PATH` が必須**である。1.0.2 の初回ビルド定義でこの行が欠落しており、rJava 依存の 14 パッケージがロード不能になる不具合が発生した（ビルド後に検出・修正済み）。

**なぜ必要か**

R は起動時に `$R_HOME/etc/ldpaths` を読んで `LD_LIBRARY_PATH` を組み立てる。ところが runtime ステージは `FROM builder-rstudio`（＝Java 導入前のステージ）を土台にしており、`R CMD javareconf` の成果物が置かれる `/usr/local/lib/R/etc/` は builder ステージからコピーしていない。そのため `ldpaths` は rocker 素の既定値のまま残る。

```sh
# runtime ステージの ldpaths（javareconf 未反映）
: ${JAVA_HOME=/usr/lib/jvm/java-21-openjdk-<arch>}
: ${R_JAVA_LD_LIBRARY_PATH=${JAVA_HOME}/lib/server}     # ← JDK 9+ のレイアウト
```

`ENV JAVA_HOME` で JAVA_HOME 自体は Corretto に上書きされるが、2 行目の組み立て方は変わらないため `${JAVA_HOME}/lib/server` を指す。Corretto **8** は JDK 8 のレイアウトなので、実際の `libjvm.so` は別の場所にある。

| | パス | 実在 |
|---|---|---|
| ldpaths が指す先 | `/usr/lib/jvm/java-1.8.0-amazon-corretto/lib/server` | ❌ |
| 実際の配置（arm64） | `/usr/lib/jvm/java-1.8.0-amazon-corretto/jre/lib/aarch64/server/libjvm.so` | ✅ |
| 実際の配置（amd64） | `/usr/lib/jvm/java-1.8.0-amazon-corretto/jre/lib/amd64/server/libjvm.so` | ✅ |

`ld.so` は存在しないパスを警告なく無視するため、`ENV LD_LIBRARY_PATH` が無いと以下で失敗する。

```
error: unable to load shared object '/usr/local/lib/R/site-library/rJava/libs/rJava.so':
  libjvm.so: cannot open shared object file: No such file or directory
```

**影響を受けるパッケージ（14本）**: SqlRender, DatabaseConnector, FeatureExtraction, Achilles, DataQualityDashboard, CohortGenerator, CohortDiagnostics, PheValuator, Keeper, CohortMethod, SelfControlledCaseSeries, SelfControlledCohort, CohortIncidence, Strategus

**検出が難しい理由（重要）**

1. **ビルドは成功する。** Stage 3/4 の `stopifnot(requireNamespace())` は `R CMD javareconf` 済みのビルダーステージ内で実行されるため全て通る。壊れているのは runtime ステージだけで、ビルドログには一切異常が出ない。
2. **compose 経由では露見しない。** `builder/docker-compose-build.yml` と `docker-compose.yml` の `hades` サービスが同値の `LD_LIBRARY_PATH` を env で渡しており、`ldpaths` はこれを温存して追記する（`LD_LIBRARY_PATH="${R_LD_LIBRARY_PATH}:${LD_LIBRARY_PATH}"`）。RStudio を触る限り問題は出ない。
3. **アーキ非依存。** amd64（Windows）でも Corretto 8 のレイアウトは同一であり、同じ不具合が発生する。「Windows ビルドでは問題なかった」は再現条件を満たしていないだけ。
4. `requireNamespace()` は「未インストール」と「ロード時例外」の両方で `FALSE` を返すため、**症状がパッケージ欠落に見える**。

**露見する経路**: ARACHNE Execution Engine。AEE は docker.sock 経由で hades イメージを**直接 `docker run`** し、CMD を `Rscript` に上書きして実行するため compose の env を通らない（詳細は `documents/arachne.md` §8）。

**検証方法**（`docker compose run` では検証できない。素の `docker run` が必須）

```bash
docker run --rm rinchu/hades:1.0.2 Rscript -e \
  "cat(tryCatch({library(rJava); .jinit(); 'rJava OK'}, error=function(e) paste('ERROR:', conditionMessage(e))), '\n')"
```

---

### ビルド後パッチ一覧と upstream 追従状況（2026-07-31 確認）

| # | パッチ | 対象バージョン（1.0.2） | upstream の状態 | 1.0.2 での要否 |
|---|-------|---------------------|---------------|--------------|
| 1 | CohortExplorer `server.R` | v0.1.0 | v0.1.0 が最新タグ（修正版未リリース） | ✅ **継続必要** |
| 2 | ORG `getIncidenceRatesV0.sql` | v2.3.0 | v2.3.0 も `i.database_id` のまま | ✅ **継続必要** |
| 3 | ORG presentation テンプレート 5 件 | v2.3.0 | **v2.3.0 でも presentation 機能は非搭載（ファイル 0 件）** | ❌ **不要（撤去推奨）** |
| 4 | Characterization `CreateTargetCohortTable.sql` | v3.0.1 | v3.0.1 も `VARCHAR(50)` のまま | ✅ **継続必要** |
| 5 | CohortGenerator `CreateCohortTables.sql` BIGINT→INT | v1.1.1 | v1.1.1 も `BIGINT` のまま | ✅ **継続必要** |

---

### ビルド後パッチ: CohortExplorer v0.1.0 Shiny バグ修正（2026-03-26 / 1.0.2 で継続）

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

> **1.0.2 時点の upstream 確認**: OHDSI/CohortExplorer の最新タグは依然 `v0.1.0`。修正版はリリースされていないためパッチを継続する。

---

### ビルド後パッチ: OhdsiReportGenerator CohortIncidence スキーマ修正（2026-04-17 / 1.0.2 で継続）

OhdsiReportGenerator の `getIncidenceRatesV0.sql` が CohortIncidence v3+ の新スキーマに対応していないため、`include_ci: true` で Quarto レポートが生成されないバグに対するパッチ。

- **原因**: CI v3.0.0 (2024-06-30) でテーブル構造が再設計され `database_id` が `source_name` に変更されたが、ORG は未追従
- **症状**: `Error: no such column: i.database_id`（OhdsiReportGenerator レポート生成失敗）
- **パッチファイル**: `ohdsi_issue/OhdsiReportGenerator_getIncidenceRatesV0_patched.sql`
- **Dockerfile 適用方法**: `COPY` で `getIncidenceRatesV0.sql` を差し替え（CohortExplorer パッチ直後）
- **詳細ドキュメント**: `ohdsi_issue/CohortIncidence_issue_fix.md`

| # | 修正内容 | 対象ファイル |
|---|---------|-----------|
| 1 | `ON d.database_id = i.database_id` → `ON d.database_id = i.source_name` | `getIncidenceRatesV0.sql` |

> **1.0.2 時点の upstream 確認**: ORG v2.3.0 の `inst/sql/sql_server/characterization/getIncidenceRatesV0.sql` は依然 `on d.database_id = i.database_id`（46行目）。**2.1.0 → 2.3.0 でも未修正のためパッチを継続する。**

---

### ⚠️ 陳腐化: OhdsiReportGenerator presentation テンプレートパッチ（1.0.2 で不要化）

1.0.1 では ORG v2.1.0 の presentation テンプレート 5 件に対し、`seq_len()` の閉じ括弧欠落（計 12 箇所）と `cohort_incidence_template.qmd` の dplyr data masking バグを修正するパッチを適用していた。

**1.0.2 では、このパッチは意味を持たない。** ORG v2.3.0 でも presentation 機能そのものは upstream 非搭載のため。

| 確認項目 | v2.1.0 | v2.3.0 |
|---------|--------|--------|
| `inst/templates/presentation/` 配下の `.qmd` | 16 ファイル | **0 ファイル（ディレクトリごと削除）** |
| エクスポート関数 `generatePresentation()` | あり | **なし**（88 エクスポート中、`presentation` に該当する関数は皆無） |

現状の Dockerfile はパッチ 5 件を `COPY` し続けているため、イメージ内には **v2.1.0 由来の孤立した 5 ファイルだけが入った `templates/presentation/` ディレクトリ**が生成されている。v2.1.0 に存在した残り 11 ファイル（`background.qmd` / `cohort_method.qmd` / `topline.qmd` 等）は同梱されていない。

- **機能上の実害**: なし（`generatePresentation()` が存在しないため、これらのファイルを読む経路が無い）
- **推奨対応**: Dockerfile から当該 `COPY` 5 行を撤去し、`ohdsi_issue/OhdsiReportGenerator_*_patched.qmd` 5 ファイルもアーカイブする
- **⚠️ 運用上の影響**: `generatePresentation()` を使ったワークフローがある場合、**ORG 2.1.0 → 2.3.0 のアップグレードで当該機能が失われる**。レポート生成は `generateFullReport()` / `createPredictionReport()` / `generateSummaryPredictionReport()` へ移行が必要

> 本ドキュメント作成時点では Dockerfile を変更していない（イメージは 5 ファイルを含んだ状態でビルド済み）。撤去は次回ビルド時に判断すること。

---

### ビルド後パッチ: Characterization attrition 列幅修正（2026-04-18 / 1.0.2 で継続）

Characterization の `CreateTargetCohortTable.sql` が attrition 一時テーブルを `attr_reason VARCHAR(50)` で作成する一方、`NonCaseCohorts.sql` は 50 文字を超える固定文言を INSERT するため、risk factor cohort generation 中に SQL エラーで失敗するバグに対するパッチ。

- **原因**: `CreateTargetCohortTable.sql` の attrition 一時テーブル定義が `ResultTables.sql` の `attr_reason VARCHAR(200)` と不整合
- **症状**: `ERROR: value too long for type character varying(50)` により Characterization が abort し、ORG の `Risk Factors` セクションが空になる
- **パッチファイル**: `ohdsi_issue/Characterization_CreateTargetCohortTable_patched.sql`
- **Dockerfile 適用方法**: `COPY` で `CreateTargetCohortTable.sql` を差し替え（ORG パッチ直後）

| # | 修正内容 | 対象ファイル |
|---|---------|-----------|
| 1 | `attr_reason VARCHAR(50)` → `attr_reason VARCHAR(200)` | `CreateTargetCohortTable.sql` |

> **1.0.2 時点の upstream 確認**: Characterization v3.0.1 の `inst/sql/sql_server/CreateTargetCohortTable.sql` は依然 `attr_reason VARCHAR(50),`（17行目）。**3.0.0 → 3.0.1 でも未修正のためパッチを継続する。**

---

### ビルド後パッチ: CohortGenerator DDL 型修正（2026-04-22 / 1.0.2 で継続）

CohortGenerator の `CreateCohortTables.sql` が `cohort_definition_id` / `subject_id` を `BIGINT` で定義するため、JDBC 経由で R に読み込まれた値が `integer64`（bit64 クラス）になり、TreatmentPatterns が内部で使用する Andromeda への `copy_to` で型が壊れて `computePathways` が全件 0 を返すバグに対するパッチ。

- **原因チェーン**: PostgreSQL BIGINT → JDBC → R `integer64` → Andromeda `copy_to` → 全件フィルタアウト
- **症状**: `minEraDuration` フィルタ後の件数が 0 になり `treatment_pathways.csv` が空になる
- **Dockerfile 適用方法**: `RUN sed -i` で `cohort_definition_id BIGINT` / `subject_id BIGINT` を `INT` に置換（Characterization パッチ直後）
- **変更対象**: `/usr/local/lib/R/site-library/CohortGenerator/sql/sql_server/CreateCohortTables.sql`

| # | 修正内容 | 対象カラム |
|---|---------|---------|
| 1 | `cohort_definition_id BIGINT` → `cohort_definition_id INT` | JOIN キー（OHDSI CDM 仕様は INTEGER） |
| 2 | `subject_id BIGINT` → `subject_id INT` | JOIN キー（OHDSI CDM 仕様は INTEGER） |

> `person_count BIGINT` / `inclusion_rule_mask BIGINT` は件数・マスクビットのため変更しない。
> **1.0.2 時点の upstream 確認**: CohortGenerator v1.1.1 の `inst/sql/sql_server/CreateCohortTables.sql` は依然 `cohort_definition_id BIGINT` / `subject_id BIGINT`。**1.1.0 → 1.1.1 でも未修正のため sed パッチを継続する。**

---

### パッケージ追加: TreatmentPatterns 可視化依存（sunburstR / networkD3 + libglpk40）（2026-04-22 / 1.0.2 で継続）

TreatmentPatterns v3.1.2 のオプション依存パッケージ（可視化）が未収録だと sunburst.html / sankey.html が生成されない問題への対応。根本原因は2層構造。

**層 1: R パッケージ未収録**
`sunburstR` / `networkD3` がイメージに未収録のため TreatmentPatterns が可視化をスキップする。

**層 2: igraph の実行時リンク依存（networkD3 のみ）**
`networkD3` は内部で `igraph` を使用し、`igraph` は `libglpk.so.40` を実行時リンクする。
ベースイメージに `libglpk` が未収録のため、R パッケージをインストールしても `library(networkD3)` がロードエラーになる。

```
Error: unable to load shared object 'igraph.so':
  libglpk.so.40: cannot open shared object file: No such file or directory
```

- **Dockerfile 適用方法**: runtime ステージの apt ブロックに `libglpk40` を含め、builder 側で `install.packages()` により R パッケージを追加（TreatmentPatterns インストール直後）

| 追加内容 | 種別 | 1.0.2 実測 | 用途 |
|---------|------|-----------|-----|
| `libglpk40` | apt システムライブラリ | 導入済 | igraph の実行時リンク依存（networkD3 経由） |
| `sunburstR` | CRAN R パッケージ | 2.1.8 | `createSunburstPlot()` — Sunburst チャート生成 |
| `networkD3` | CRAN R パッケージ | 0.4.1 | `createSankeyDiagram()` — Sankey ダイアグラム生成 |

> 1.0.2 では `igraph` 2.3.3 のロードに成功していることを確認済み（`libglpk40` が正しく効いている）。
> `libglpk40` が見つからない場合は `libglpk-dev` または `apt-cache search glpk` で確認すること（Ubuntu バージョン差異）。

---

### runtime ステージ システムライブラリ追加履歴と注意事項

#### 追加済みシステムライブラリ一覧

| ライブラリ | 追加日 | 依存チェーン | 症状 |
|----------|-------|------------|------|
| `libglpk40` | 2026-04-22 | `networkD3` → `igraph` → `libglpk.so.40` | `library(networkD3)` がロードエラー |
| `libuv1t64` | 2026-04-22 | `fs` → `libuv.so.1` | `library(fs)` がロードエラー、OhdsiReportGenerator が落ちる |

> 1.0.2 では `fs` 2.1.0 / `igraph` 2.3.3 ともロード成功を確認済み。

runtime ステージの apt ブロック全体: `libcurl4` / `libssl3` / `libxml2` / `libpq5` / `libicu74` / `unixodbc` / `libglpk40` / `libuv1t64`

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

---

### 1.0.2 移行時の注意

`rinchu/hades:1.0.1` を参照していた箇所は 2026-07-31 にすべて 1.0.2 へ揃えた。

| ファイル | 内容 | 状態 |
|---------|------|-----|
| `builder/.env` | `HADES_VERSION=1.0.2` | ✅ |
| `.env`（`8000_ohdsi_tools_docker/`） | `HADES_VERSION` が 1.0.1 のままで builder/.env と乖離していた（`docker-compose.yml` の hades は本ファイルを参照） | ✅ 1.0.2 に修正 |
| `docker-compose.arachne.yml` | `DOCKER_IMAGE_DEFAULT: rinchu/hades:1.0.2` | ✅ |
| `documents/arachne.md` | §8.1 を新設し 1.0.2 への更新経緯・検証状況を記載。正本 Dockerfile 参照も更新 | ✅ |
| `documents/installed_apps.md` | 全パッケージバージョン・パッチ一覧・イメージ参照を 1.0.2 に更新 | ✅ |
| `documents/arachne_for_administrator.md` | 管理者手順のイメージ確認を 1.0.2 に更新。`LD_LIBRARY_PATH` 検証手順とトラブルシュート項目を追加 | ✅ |
| `arachne/README.md` | 前提イメージを 1.0.2 に更新 | ✅ |

> **⚠️ `DOCKER_IMAGE_PULL: NEVER`**: AEE はイメージを自動取得しない。`DOCKER_IMAGE_DEFAULT` のタグと同じイメージがローカルに無いと分析が起動しないため、hades を上げ替えたら両方を必ず揃えること。
>
> **⚠️ 未検証**: AEE 経由の実分析（実 CDM 接続・結果回収）は 1.0.2 ではまだ流していない。DatabaseConnector 7.1.0 → 7.2.0、SelfControlledCohort 1.6.0 → 2.0.0、Keeper 0.2.1 → 2.1.3 などメジャー更新を含むため、本番運用前に 1 本流して確認すること。
>
> ARACHNE から 1.0.2 を使う場合、**`ENV LD_LIBRARY_PATH` が入ったイメージであること**を必ず確認すること（前掲の `docker run` 検証コマンド）。AEE は compose env を通らないため、この 1 行が無いと全分析が rJava エラーで失敗する。

---

### ビルド記録（1.0.2）

| 項目 | 内容 |
|-----|-----|
| ビルド日 | 2026-07-31 |
| ビルド環境 | macOS (Apple Silicon) / Docker Engine 29.4.2 / Docker Compose v5.1.3 |
| ビルド方法 | `builder/docker-compose-build.sh build hades`（BuildKit、`--secret id=ghpat`） |
| ビルド範囲 | Stage 1（R ソースビルド）からのフルビルド。前回ビルドキャッシュは枝刈り済みだった |
| イメージサイズ | 4.22GB |
| site-library | cleanup 前 1.4G → 後 451M |
| 検証 | HADES 37/37 ロード成功、rJava/JVM 1.8.0_502 起動、JDBC 23 ファイル配置、パッチ 4 種適用確認、RStudio Server 応答（HTTP 302） |
| ビルドログ | `builder/docker_build_log_hades_20260731_185140.txt`（初回）<br>`builder/docker_build_log_hades_20260731_200108_ldpath.txt`（`ENV LD_LIBRARY_PATH` 修正後） |
