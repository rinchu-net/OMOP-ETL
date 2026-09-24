# rinchu/hades:1.0.0 — インストール済みアプリ・バージョン一覧

> 最終更新: 2026-03-26
> 動作確認: `hades_package_test.R` 37/37 成功（2026-03-26 03:23）

> **ビルドDockerfile**: `hades_setup/rstudio_4.4.3_hades_1.0.0.Dockerfile`
> **ビルド構成**: 4ステージマルチステージビルド（R / RStudio / HADES前提 / HADES分析パッケージ）
> **対応アーキテクチャ**: linux/amd64, linux/arm64 (Apple Silicon)
> **ビルド状況**: ✅ 最終ビルド完了（2026-03-26 --no-cache）
> **ビルドログ**: `builder/docker_build_log_hades100_final.txt`

### 基盤ソフトウェア

| アプリ | バージョン | 取得元 | v1.0.0 ビルド進捗 |
|-------|---------|-------|-----------------|
| OS | Ubuntu 24.04 LTS (noble) | https://hub.docker.com/_/ubuntu | ✅ S1 |
| R | 4.4.3 (2025-02-28) | rocker-org/rocker-versioned2 スクリプト | ✅ S1 |
| RStudio Server | 2024.12.1+563 | https://posit.co/download/rstudio-server/ | ✅ S2 |
| Pandoc | （RStudio同梱版） | RStudio インストーラ同梱 | ✅ S2 |
| Quarto | （RStudio同梱版） | RStudio インストーラ同梱 | ✅ S2 |
| Java | Amazon Corretto 1.8 | https://aws.amazon.com/corretto/ | ✅ S3 |
| PostgreSQL JDBC Driver | 42.7.8 | https://jdbc.postgresql.org/ | ✅ S3 |

---

### HADES R パッケージ — インストール済み（37 / 39パッケージ）

> 公式 HADES パッケージ一覧: https://ohdsi.github.io/Hades/packages.html
> バージョンは `rinchu/hades:1.0.0` 最終ビルドでの確認値（2026-03-26、`hades_package_test.R` 37/37 成功）。
> 取得元: 全パッケージ `remotes::install_github()` で GitHub から直接取得
> CRAN 依存: RSPM (`https://packagemanager.posit.co/cran/__linux__/noble/latest`) からバイナリ優先

#### Supporting（基盤・共通ライブラリ）

| パッケージ | バージョン | 取得元 | v1.0.0 ビルド進捗 |
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
| OhdsiReportGenerator | 2.1.0 | GitHub (OHDSI/OhdsiReportGenerator) | ✅ |
| Strategus | 1.5.0 | GitHub (OHDSI/Strategus) | ✅ |

#### Evidence Quality（エビデンスの質）

| パッケージ | バージョン | 取得元 | v1.0.0 ビルド進捗 |
|----------|---------|-------|-----------------|
| Achilles | 1.8 | GitHub (OHDSI/Achilles) | ✅ |
| DataQualityDashboard | 2.8.7 | GitHub (OHDSI/DataQualityDashboard) | ✅ |
| EmpiricalCalibration | 3.1.4 | GitHub (OHDSI/EmpiricalCalibration) | ✅ |
| MethodEvaluation | 2.4.0 | GitHub (OHDSI/MethodEvaluation) | ✅ |

#### Cohort Construction & Evaluation（コホート構築・評価）

| パッケージ | バージョン | 取得元 | v1.0.0 ビルド進捗 |
|----------|---------|-------|-----------------|
| CirceR | 1.3.3 | GitHub (OHDSI/CirceR) | ✅ |
| CohortDiagnostics | 3.4.2 | GitHub (OHDSI/CohortDiagnostics) | ✅ |
| CohortGenerator | 1.1.0 | GitHub (OHDSI/CohortGenerator) | ✅ |
| Capr | 2.1.1 | GitHub (OHDSI/Capr) | ✅ |
| PhenotypeLibrary | 3.36.0 | GitHub (OHDSI/PhenotypeLibrary) | ✅ |
| PheValuator | 2.2.16 | GitHub (OHDSI/PheValuator) | ✅ |
| CohortExplorer | 0.1.0 | GitHub (OHDSI/CohortExplorer) | ✅ **パッチ適用済** |
| Keeper | 0.2.1 | GitHub (OHDSI/Keeper) | ✅ |

#### Population-level Estimation（母集団レベルの推定）

| パッケージ | バージョン | 取得元 | v1.0.0 ビルド進捗 |
|----------|---------|-------|-----------------|
| CohortMethod | 6.0.1 | GitHub (OHDSI/CohortMethod) | ✅ |
| SelfControlledCaseSeries | 6.1.1 | GitHub (OHDSI/SelfControlledCaseSeries) | ✅ |
| SelfControlledCohort | 1.6.0 | GitHub (OHDSI/SelfControlledCohort) | ✅ |

#### Patient-level Prediction（患者レベルの予測）

| パッケージ | バージョン | 取得元 | v1.0.0 ビルド進捗 |
|----------|---------|-------|-----------------|
| PatientLevelPrediction | 6.6.0 | GitHub (OHDSI/PatientLevelPrediction) | ✅ |
| EnsemblePatientLevelPrediction | 1.0.3 | GitHub (OHDSI/EnsemblePatientLevelPrediction) | ✅ |

#### Characterization（特性解析）

| パッケージ | バージョン | 取得元 | v1.0.0 ビルド進捗 |
|----------|---------|-------|-----------------|
| Characterization | 3.0.0 | GitHub (OHDSI/Characterization) | ✅ |
| CohortIncidence | 4.1.1 | GitHub (OHDSI/CohortIncidence) | ✅ |
| TreatmentPatterns | 3.1.2 | GitHub (darwin-eu-dev/TreatmentPatterns) | ✅ |

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

### 注意事項: r-universe を使用しない理由（2026-03-26 ビルド時の知見）

v1.0.0 の初期ビルドでは OHDSI r-universe (`https://ohdsi.r-universe.dev`) から `install.packages()` でパッケージを取得する方式を採用していたが、以下の問題により **全パッケージを GitHub 直接取得に切り替えた**。

#### 問題1: 37本中14本が r-universe に未登録

r-universe API で確認したところ、以下の14パッケージが HTTP 404（未登録）だった。
これは一時的な障害ではなく、OHDSI の r-universe に `packages.json` レジストリが存在せず、
CRAN 経由で自動発見されたパッケージのみが掲載されている構造的な問題である。

| 未登録パッケージ |
|----------------|
| BigKnn, ROhdsiWebApi, OhdsiSharing, Achilles, MethodEvaluation, CohortDiagnostics, Capr, PhenotypeLibrary, SelfControlledCohort, EnsemblePatientLevelPrediction, BrokenAdaptiveRidge, IterativeHardThresholding, OhdsiShinyModules, OhdsiShinyAppBuilder |

#### 問題2: r-universe の設計が本番ビルド向きではない

- パッケージは継続的にリビルドされ、チェックサムが変化する（再現性なし）
- ビルド失敗すると一時的にパッケージが消失する
- OHDSI 公式の Hades Dockerfile も r-universe ではなく `remotes::install_github()` を使用

#### 問題3: pak::pkg_install() のサイレント失敗

旧 v1.0.0 ビルドで使用した `pak::pkg_install('OHDSI/X')` は、インストール失敗時にも exit code 0 を返す場合があり、6パッケージがサイレントに欠落していた（v1.0.2 で発覚・修正）。

#### 採用した方式

```
remotes::install_github('OHDSI/X')   ← 全37本を GitHub から直接取得
+ RSPM をリポジトリに追加              ← CRAN 依存パッケージをバイナリで取得
+ stopifnot(requireNamespace(...))    ← インストール失敗時にビルドを即時中断
```

この方式により、r-universe の可用性やビルド状況に依存せず、確実にビルドが完走する。

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
