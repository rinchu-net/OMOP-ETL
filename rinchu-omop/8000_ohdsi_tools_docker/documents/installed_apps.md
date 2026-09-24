# Dockerイメージ インストール済みアプリ・バージョン一覧

> 最終更新: 2026-08-10
> 本ドキュメントは `rinchu/hades:1.0.2`（統合フルビルド版）の構成を定義する。
> 動作確認: HADES パッケージ 37/37 ロード成功（2026-08-10、ビルド済みイメージ上で実測）

---

## コンテナ構成サマリー

### 基本構成（常時起動）
| コンテナ | イメージ | ベースイメージ | 主要アプリ |
|---------|---------|-------------|----------|
| omopdb | rinchu/omopdb:1.0.0 | postgres:15 | PostgreSQL 15 |
| webapi | rinchu/webapi:2.15.1 | eclipse-temurin:8-jre | OHDSI WebAPI 2.15.1, Java 1.8 |
| atlas | rinchu/atlas:2.15.0 | nginxinc/nginx-unprivileged:1.27.2-alpine | OHDSI Atlas 2.15.0 |
| hades | rinchu/hades:1.0.2 | ubuntu:noble (24.04) | R 4.4.3, RStudio Server 2024.12.1+563, HADES 37パッケージ |

---

## rinchu/omopdb:1.0.0

| アプリ | バージョン | 取得元 |
|-------|---------|-------|
| PostgreSQL | 15 | https://hub.docker.com/_/postgres |
| PostgreSQL JDBC Driver | 42.7.8 | https://jdbc.postgresql.org/ |

---

## rinchu/webapi:2.15.1

### ランタイム

| アプリ | バージョン | 取得元 |
|-------|---------|-------|
| OHDSI WebAPI | 2.15.1-SNAPSHOT | https://github.com/OHDSI/WebAPI |
| Java (Eclipse Temurin JRE) | 1.8.0_482 | https://hub.docker.com/_/eclipse-temurin |
| Tomcat（組み込み） | 8.5.43 | Spring Boot 内包 |

### ビルド環境（ビルド時のみ）

| アプリ | バージョン |
|-------|---------|
| Maven | 3.6 |
| JDK | 11 |

### 主要ライブラリ

| ライブラリ | バージョン |
|----------|---------|
| Spring Boot | 1.5.22.RELEASE |
| Spring Core | 4.3.25.RELEASE |
| Jackson | 2.12.7.1 |
| Log4j | 2.17.1 |
| PostgreSQL JDBC | 42.3.10 |
| SqlRender (Java) | 1.19.1 |
| OpenTelemetry Java Agent | 1.17.0 |

---

## rinchu/atlas:2.15.0

### ランタイム

| アプリ | バージョン | 取得元 |
|-------|---------|-------|
| OHDSI Atlas | 2.15.0-DEV | https://github.com/OHDSI/Atlas |
| nginx | 1.27.2 (unprivileged) | https://hub.docker.com/r/nginxinc/nginx-unprivileged |

### ビルド環境（ビルド時のみ）

| アプリ | バージョン |
|-------|---------|
| Node.js | 18.14.1 |

---

## rinchu/hades:1.0.2（統合フルビルド版）

> **ビルドDockerfile**: `hades_setup/rstudio_4.4.3_hades_1.0.2.Dockerfile`
> **ビルド構成**: 4ステージマルチステージビルド（R / RStudio / HADES前提 / HADES分析パッケージ）
> **対応アーキテクチャ**: linux/amd64, linux/arm64 (Apple Silicon)
> **ビルド状況**: ✅ フルビルド完了（2026-08-10、macOS arm64。Stage 1 の R ソースビルドから全ステージ再構築）
> **イメージサイズ**: 4.22GB
> **1.0.1 からの変更**: HADES パッケージ 18 本のバージョン更新、OhdsiShinyAppBuilder をコミット固定から `v1.1.0` タグ固定に変更
> **詳細**: [`../hades_setup/rstudio_4.4.3_hades_1.0.2.md`](../hades_setup/rstudio_4.4.3_hades_1.0.2.md)

### 基盤ソフトウェア

| アプリ | バージョン | 取得元 |
|-------|---------|-------|
| OS | Ubuntu 24.04 LTS (noble) | https://hub.docker.com/_/ubuntu |
| R | 4.4.3 (2025-02-28) | rocker-org/rocker-versioned2 スクリプト |
| RStudio Server | 2024.12.1+563 | https://posit.co/download/rstudio-server/ |
| Pandoc | （RStudio同梱版） | RStudio インストーラ同梱 |
| Quarto | （RStudio同梱版） | RStudio インストーラ同梱 |
| Java | Amazon Corretto 1.8（実測 1.8.0_502） | https://aws.amazon.com/corretto/ |
| PostgreSQL JDBC Driver | 42.7.8 | https://jdbc.postgresql.org/ |
| Redshift JDBC Driver | 2.1.0.20（+ AWS SDK 1.12.493 一式） | `DatabaseConnector::downloadJdbcDrivers` 経由 |
| SQL Server JDBC Driver | 9.2.0 (jre8) | `DatabaseConnector::downloadJdbcDrivers` 経由 |
| Oracle JDBC Driver | ojdbc8 | `DatabaseConnector::downloadJdbcDrivers` 経由 |

> JDBC ドライバーは `/jdbcdrivers` に計 23 ファイル（依存 jar 含む）を配置。

> **⚠️ runtime ステージの `ENV LD_LIBRARY_PATH` は削除禁止。** これが無いと rJava 依存の 14 パッケージが
> ロード不能になり、ARACHNE Execution Engine 経由の分析がすべて失敗する（対話 RStudio は compose env が
> 同値を渡すため正常に見えてしまう）。詳細と検証コマンドは
> [`../hades_setup/rstudio_4.4.3_hades_1.0.2.md`](../hades_setup/rstudio_4.4.3_hades_1.0.2.md) / [`arachne.md`](arachne.md) §8.1。

---

### HADES R パッケージ — インストール済み（37 / 39パッケージ）

> 公式 HADES パッケージ一覧: https://ohdsi.github.io/Hades/packages.html
> バージョンは `rinchu/hades:1.0.2` ビルド済みイメージ上での実測値（2026-08-10、37/37 ロード成功）。
> 取得元: 全パッケージ `remotes::install_github()` で GitHub から直接取得
> CRAN 依存: RSPM (`https://packagemanager.posit.co/cran/__linux__/noble/latest`) からバイナリ優先

#### Supporting（基盤・共通ライブラリ）

| パッケージ | バージョン | 取得元 |
|----------|---------|-------|
| SqlRender | 1.19.5 | GitHub (OHDSI/SqlRender) |
| DatabaseConnector | 7.2.0 | GitHub (OHDSI/DatabaseConnector) |
| Cyclops | 3.7.1 | GitHub (OHDSI/Cyclops) |
| Andromeda | 1.2.1 | GitHub (OHDSI/Andromeda) |
| FeatureExtraction | 3.14.0 | GitHub (OHDSI/FeatureExtraction) |
| ParallelLogger | 3.5.1 | GitHub (OHDSI/ParallelLogger) |
| BigKnn | 1.0.2 | GitHub (OHDSI/BigKnn) |
| ROhdsiWebApi | 1.3.3 | GitHub (OHDSI/ROhdsiWebApi) |
| OhdsiSharing | 0.2.2 | GitHub (OHDSI/OhdsiSharing) |
| Eunomia | 2.1.0 | GitHub (OHDSI/Eunomia) |
| BrokenAdaptiveRidge | 1.0.1 | GitHub (OHDSI/BrokenAdaptiveRidge) |
| IterativeHardThresholding | 1.0.3 | GitHub (OHDSI/IterativeHardThresholding) |
| ResultModelManager | 0.6.2 | GitHub (OHDSI/ResultModelManager) |
| OhdsiShinyModules | 3.6.0 | GitHub (OHDSI/OhdsiShinyModules) |
| OhdsiShinyAppBuilder | 1.1.0 | GitHub (OHDSI/OhdsiShinyAppBuilder) |
| OhdsiReportGenerator | 2.3.0 | GitHub (OHDSI/OhdsiReportGenerator) **パッチ適用済** |
| Strategus | 1.5.0 | GitHub (OHDSI/Strategus) |

> **HADES 公式一覧外の同梱パッケージ**: `duckdb` 1.5.5（Andromeda バックエンド）、`shiny` 1.14.0 / `DT` 0.34.0、`sunburstR` 2.1.8 / `networkD3` 0.4.1（TreatmentPatterns 可視化）。
#### Evidence Quality（エビデンスの質）

| パッケージ | バージョン | 取得元 |
|----------|---------|-------|
| Achilles | 1.8 | GitHub (OHDSI/Achilles、コミット `113433da` 固定) |
| DataQualityDashboard | 2.8.9 | GitHub (OHDSI/DataQualityDashboard) |
| EmpiricalCalibration | 3.1.4 | GitHub (OHDSI/EmpiricalCalibration) |
| MethodEvaluation | 2.4.1 | GitHub (OHDSI/MethodEvaluation) |

#### Cohort Construction & Evaluation（コホート構築・評価）

| パッケージ | バージョン | 取得元 |
|----------|---------|-------|
| CirceR | 1.3.3 | GitHub (OHDSI/CirceR) |
| CohortDiagnostics | 3.4.2 | GitHub (OHDSI/CohortDiagnostics) |
| CohortGenerator | 1.1.1 | GitHub (OHDSI/CohortGenerator) **パッチ適用済** |
| Capr | 2.1.1 | GitHub (OHDSI/Capr) |
| PhenotypeLibrary | 3.37.0 | GitHub (OHDSI/PhenotypeLibrary) |
| PheValuator | 2.2.17 | GitHub (OHDSI/PheValuator) |
| CohortExplorer | 0.1.0 | GitHub (OHDSI/CohortExplorer) **パッチ適用済** |
| Keeper | 2.1.3 | GitHub (OHDSI/Keeper) |

#### Population-level Estimation（母集団レベルの推定）

| パッケージ | バージョン | 取得元 |
|----------|---------|-------|
| CohortMethod | 6.0.3 | GitHub (OHDSI/CohortMethod) |
| SelfControlledCaseSeries | 6.1.5 | GitHub (OHDSI/SelfControlledCaseSeries) |
| SelfControlledCohort | 2.0.0 | GitHub (OHDSI/SelfControlledCohort) |

#### Patient-level Prediction（患者レベルの予測）

| パッケージ | バージョン | 取得元 |
|----------|---------|-------|
| PatientLevelPrediction | 6.6.0 | GitHub (OHDSI/PatientLevelPrediction) |
| EnsemblePatientLevelPrediction | 1.0.3 | GitHub (OHDSI/EnsemblePatientLevelPrediction) |

#### Characterization（特性解析）

| パッケージ | バージョン | 取得元 |
|----------|---------|-------|
| Characterization | 3.0.1 | GitHub (OHDSI/Characterization) **パッチ適用済** |
| CohortIncidence | 4.1.1 | GitHub (OHDSI/CohortIncidence) |
| TreatmentPatterns | 3.1.2 | GitHub (darwin-eu-dev/TreatmentPatterns) |

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

---

### ビルド後パッチ一覧（1.0.2 / upstream 追従状況 2026-08-10 確認）

各パッチの詳細は [`../hades_setup/rstudio_4.4.3_hades_1.0.2.md`](../hades_setup/rstudio_4.4.3_hades_1.0.2.md) を参照。

| # | パッチ | 対象バージョン | upstream の状態 | 1.0.2 での要否 |
|---|-------|-------------|---------------|--------------|
| 1 | CohortExplorer `server.R`（Shiny タイムライン表示バグ） | v0.1.0 | v0.1.0 が最新タグ（修正版未リリース） | ✅ 継続必要 |
| 2 | ORG `getIncidenceRatesV0.sql`（CohortIncidence スキーマ） | v2.3.0 | v2.3.0 も `i.database_id` のまま | ✅ 継続必要 |
| 3 | ORG presentation テンプレート 5 件（`seq_len()` 括弧欠落ほか） | v2.3.0 | **v2.3.0 でも presentation 機能は非搭載（ファイル 0 件）** | ❌ 不要（撤去推奨） |
| 4 | Characterization `CreateTargetCohortTable.sql`（attrition 列幅） | v3.0.1 | v3.0.1 も `VARCHAR(50)` のまま | ✅ 継続必要 |
| 5 | CohortGenerator `CreateCohortTables.sql`（BIGINT→INT） | v1.1.1 | v1.1.1 も `BIGINT` のまま | ✅ 継続必要 |

> **⚠️ ORG 2.1.0 → 2.3.0 で `generatePresentation()` が削除された。** upstream から `inst/templates/presentation/` が
> 丸ごと消えており（v2.1.0: 16 ファイル → v2.3.0: 0 ファイル）、エクスポート関数にも presentation 系は存在しない。
> 当該機能を使ったワークフローがある場合は `generateFullReport()` / `createPredictionReport()` /
> `generateSummaryPredictionReport()` への移行が必要。パッチ 3 は機能上の実害こそ無いが撤去が望ましい。

---

### 取得元の内訳

| 取得元 | パッケージ数 | 備考 |
|-------|-----------|-----|
| GitHub (`remotes::install_github()`) | 37 | 全 HADES パッケージ。CRAN 依存は RSPM バイナリ優先 |
| インストール除外 | 2 | 依存関係の競合 / 重量超過 |
| **合計（HADES公式39パッケージ）** | **39** | |

> **TreatmentPatterns について**: OHDSI 公式ではなく `darwin-eu-dev` が開発元。
> `OHDSI/TreatmentPatterns` は GitHub に存在しない（HTTP 404）。
