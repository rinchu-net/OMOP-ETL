# syntax=docker/dockerfile:1
# HADES フルビルド Dockerfile — 4ステージ構成
#
# ┌─────────────────────────────────────────────────────────────┐
# │  Stage 1  builder-r          Ubuntu Noble + R ソースビルド  │
# │  Stage 2  builder-rstudio    + RStudio / Pandoc / Quarto    │
# │  Stage 3  builder-hades-base + Java / Rcpp / 前提パッケージ │
# │  Stage 4  builder-hades-pkgs + 全 HADES 分析パッケージ群   │
# │  runtime                     Stage2 + Stage4 成果物コピー   │
# └─────────────────────────────────────────────────────────────┘
#
# バージョンアップ手順:
#   R / RStudio バージョンアップ  → フルリビルド（Stage 1 から）
#   HADES パッケージ追加・更新    → インクリメンタルビルド（rstudio_hades_incremental.Dockerfile）
#   前提パッケージ更新のみ        → --no-cache --target=builder-hades-base 以降を再ビルド
#
# インストール方針:
#   全 HADES パッケージを remotes::install_github() で GitHub から直接取得
#   全パッケージに ref='vX.Y.Z' でバージョン固定（GitHub タグ）
#   CRAN 依存は RSPM (latest) からバイナリ優先で取得
#   全パッケージに stopifnot(requireNamespace()) で明示的に検証
#   pak::pkg_install() は使用禁止（サイレント失敗リスク、exit code 0 のまま未インストール）
#   r-universe は使用しない（37本中14本が未登録で信頼性不足）


################################################################################
## STAGE 1: BUILDER-R
## Ubuntu Noble + R ソースビルド（rocker 公開スクリプトをそのまま使用・変更禁止）
################################################################################
FROM docker.io/library/ubuntu:noble AS builder-r

ENV R_VERSION="4.4.3"
ENV R_HOME="/usr/local/lib/R"
ENV TZ="Etc/UTC"

COPY scripts/install_R_source.sh /rocker_scripts/install_R_source.sh
RUN /rocker_scripts/install_R_source.sh

ENV CRAN="https://p3m.dev/cran/__linux__/noble/latest"
ENV LANG=en_US.UTF-8

COPY scripts/bin/ /rocker_scripts/bin/
COPY scripts/setup_R.sh /rocker_scripts/setup_R.sh
RUN <<EOF
if grep -q "1000" /etc/passwd; then
    userdel --remove "$(id -un 1000)";
fi
/rocker_scripts/setup_R.sh
EOF


################################################################################
## STAGE 2: BUILDER-RSTUDIO
## RStudio Server / Pandoc / Quarto のインストール（rocker 公開スクリプト・変更禁止）
## ※ runtime はこのステージをベースにする
################################################################################
FROM builder-r AS builder-rstudio

ENV S6_VERSION="v2.1.0.2"
ENV RSTUDIO_VERSION="2024.12.1+563"
ENV DEFAULT_USER="rstudio"

COPY scripts/install_rstudio.sh /rocker_scripts/install_rstudio.sh
COPY scripts/install_s6init.sh /rocker_scripts/install_s6init.sh
COPY scripts/default_user.sh /rocker_scripts/default_user.sh
COPY scripts/init_set_env.sh /rocker_scripts/init_set_env.sh
COPY scripts/init_userconf.sh /rocker_scripts/init_userconf.sh
COPY scripts/pam-helper.sh /rocker_scripts/pam-helper.sh
RUN /rocker_scripts/install_rstudio.sh

COPY scripts/install_pandoc.sh /rocker_scripts/install_pandoc.sh
RUN /rocker_scripts/install_pandoc.sh

COPY scripts/install_quarto.sh /rocker_scripts/install_quarto.sh
RUN /rocker_scripts/install_quarto.sh

COPY scripts /rocker_scripts

EXPOSE 8787
CMD ["/init"]


################################################################################
## STAGE 3: BUILDER-HADES-BASE
## HADES 前提環境のセットアップ
##   - ビルド依存ライブラリ（apt）
##   - Java（Amazon Corretto 8）+ R CMD javareconf
##   - PostgreSQL JDBC ドライバー
##   - Rcpp（コンパイル基盤 — cleanup で *.h を削除するため最初にインストール）
##   - remotes（GitHub 直接インストール用）
##   - HADES 前提パッケージ群（他の分析パッケージが依存するコアライブラリ）
##
## このステージは R/RStudio バージョン変更時以外ほぼ変わらない。
## キャッシュが長持ちするよう、変更頻度の低いものを前に配置している。
################################################################################
FROM builder-rstudio AS builder-hades-base

# ---- ビルド依存ライブラリ（R パッケージのコンパイルに必要）
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    build-essential \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libpq-dev \
    unixodbc-dev \
    libpcre2-dev \
    zlib1g-dev \
    libbz2-dev \
    liblzma-dev \
    libdeflate-dev \
    libicu-dev \
    curl \
    cmake \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ---- Java（Amazon Corretto 8）
# rJava / DatabaseConnector の JDBC 接続に必要
RUN apt-get update && \
    wget -O- https://apt.corretto.aws/corretto.key | gpg --dearmor \
        | tee /usr/share/keyrings/corretto-keyring.gpg > /dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/corretto-keyring.gpg] https://apt.corretto.aws stable main" \
        | tee /etc/apt/sources.list.d/corretto.list && \
    apt-get update && \
    apt-get install -y java-1.8.0-amazon-corretto-jdk && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    R CMD javareconf

# ---- PostgreSQL JDBC ドライバー
# 他の JDBC（Redshift / SQL Server / Oracle）は DatabaseConnector インストール後に
# downloadJdbcDrivers 経由でまとめて取得する（後段）
RUN mkdir -p /jdbcdrivers && \
    curl -L -o /jdbcdrivers/postgresql-42.7.8.jar \
        https://jdbc.postgresql.org/download/postgresql-42.7.8.jar

# ---- Rcpp（コンパイル基盤）
# cleanup ステップで *.h を削除するため、インクリメンタルビルド時に Rcpp を再インストールして
# ヘッダーを復元する必要がある（rstudio_hades_incremental.Dockerfile 参照）。
# このフルビルドでは cleanup 前なので問題なし。
RUN R -q -e "install.packages('Rcpp', repos='https://packagemanager.posit.co/cran/__linux__/noble/latest')"

# ---- remotes（GitHub 直接インストール用）
RUN R -q -e "install.packages('remotes', repos='https://packagemanager.posit.co/cran/__linux__/noble/latest')"

# ---- HADES 前提パッケージ群（Supporting Core）
# 多くの HADES 分析パッケージが依存するコアライブラリ。
# 全パッケージを remotes::install_github() で GitHub タグ（ref='vX.Y.Z'）指定で取得。
# CRAN 依存は RSPM (latest) からバイナリ優先で取得。

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(CRAN='https://packagemanager.posit.co/cran/__linux__/noble/latest')); \
             remotes::install_github('OHDSI/SqlRender', ref='v1.19.5'); \
             stopifnot(requireNamespace('SqlRender', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(CRAN='https://packagemanager.posit.co/cran/__linux__/noble/latest')); \
             remotes::install_github('OHDSI/DatabaseConnector', ref='v7.2.0'); \
             stopifnot(requireNamespace('DatabaseConnector', quietly=TRUE))"

# ---- 追加 JDBC ドライバー（Redshift / SQL Server / Oracle）
# DatabaseConnector の公式 downloader 経由で取得。
#   - redshift  : redshift-jdbc42 + 依存 AWS SDK / jackson / httpclient 一式
#   - sql server: mssql-jdbc（Synapse / PDW にも同ドライバを使用）
#   - oracle    : ojdbc8
# 取得先はいずれも DatabaseConnector が動作確認済みのバージョン。
RUN R -q -e "DatabaseConnector::downloadJdbcDrivers('redshift',   pathToDriver='/jdbcdrivers'); \
             DatabaseConnector::downloadJdbcDrivers('sql server', pathToDriver='/jdbcdrivers'); \
             DatabaseConnector::downloadJdbcDrivers('oracle',     pathToDriver='/jdbcdrivers'); \
             stopifnot(length(Sys.glob('/jdbcdrivers/redshift-jdbc42-*.jar')) > 0); \
             stopifnot(length(Sys.glob('/jdbcdrivers/mssql-jdbc*.jar'))       > 0); \
             stopifnot(length(Sys.glob('/jdbcdrivers/ojdbc*.jar'))            > 0)"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(CRAN='https://packagemanager.posit.co/cran/__linux__/noble/latest')); \
             remotes::install_github('OHDSI/Cyclops', ref='v3.7.1'); \
             stopifnot(requireNamespace('Cyclops', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(CRAN='https://packagemanager.posit.co/cran/__linux__/noble/latest')); \
             remotes::install_github('duckdb/duckdb-r', ref='v1.5.5'); \
             stopifnot(packageVersion('duckdb') >= '1.3.0')"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(CRAN='https://packagemanager.posit.co/cran/__linux__/noble/latest')); \
             remotes::install_github('OHDSI/Andromeda', ref='v1.2.1'); \
             stopifnot(packageVersion('Andromeda') >= '1.2.1')"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(CRAN='https://packagemanager.posit.co/cran/__linux__/noble/latest')); \
             remotes::install_github('OHDSI/FeatureExtraction', ref='v3.14.0'); \
             stopifnot(requireNamespace('FeatureExtraction', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(CRAN='https://packagemanager.posit.co/cran/__linux__/noble/latest')); \
             remotes::install_github('OHDSI/ParallelLogger', ref='v3.5.1'); \
             stopifnot(requireNamespace('ParallelLogger', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(CRAN='https://packagemanager.posit.co/cran/__linux__/noble/latest')); \
             remotes::install_github('OHDSI/BigKnn', ref='v1.0.2'); \
             stopifnot(requireNamespace('BigKnn', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(CRAN='https://packagemanager.posit.co/cran/__linux__/noble/latest')); \
             remotes::install_github('OHDSI/ROhdsiWebApi', ref='v1.3.3'); \
             stopifnot(requireNamespace('ROhdsiWebApi', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(CRAN='https://packagemanager.posit.co/cran/__linux__/noble/latest')); \
             remotes::install_github('OHDSI/OhdsiSharing', ref='v0.2.2'); \
             stopifnot(requireNamespace('OhdsiSharing', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(CRAN='https://packagemanager.posit.co/cran/__linux__/noble/latest')); \
             remotes::install_github('OHDSI/Eunomia', ref='v2.1.0'); \
             stopifnot(requireNamespace('Eunomia', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(CRAN='https://packagemanager.posit.co/cran/__linux__/noble/latest')); \
             remotes::install_github('OHDSI/CirceR', ref='v1.3.3'); \
             stopifnot(requireNamespace('CirceR', quietly=TRUE))"

# ---- UI 基盤（DataQualityDashboard / Shiny アプリ用）
RUN R -q -e "options(repos = c(CRAN='https://packagemanager.posit.co/cran/__linux__/noble/latest')); \
             install.packages(c('shiny', 'DT'))"


################################################################################
## STAGE 4: BUILDER-HADES-PKGS
## HADES 分析パッケージ群（全 37 パッケージ）
##
## 全パッケージを remotes::install_github() で GitHub タグ指定で取得。
## CRAN 依存は RSPM (latest) からバイナリ優先。
## 各パッケージに stopifnot() 検証。
## OhdsiReportGenerator は OhdsiShinyModules より先に配置（依存関係）。
################################################################################
FROM builder-hades-base AS builder-hades-pkgs

# ============================================================
# Evidence Quality（エビデンスの質）
# ============================================================
RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(CRAN='https://packagemanager.posit.co/cran/__linux__/noble/latest')); \
             remotes::install_github('OHDSI/Achilles', ref='113433da2ce33ec26463a49f45278ba297a75987'); \
             stopifnot(requireNamespace('Achilles', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(CRAN='https://packagemanager.posit.co/cran/__linux__/noble/latest')); \
             remotes::install_github('OHDSI/DataQualityDashboard', ref='v2.8.9'); \
             stopifnot(requireNamespace('DataQualityDashboard', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(CRAN='https://packagemanager.posit.co/cran/__linux__/noble/latest')); \
             remotes::install_github('OHDSI/EmpiricalCalibration', ref='v3.1.4'); \
             stopifnot(requireNamespace('EmpiricalCalibration', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(CRAN='https://packagemanager.posit.co/cran/__linux__/noble/latest')); \
             remotes::install_github('OHDSI/MethodEvaluation', ref='v2.4.1'); \
             stopifnot(requireNamespace('MethodEvaluation', quietly=TRUE))"

# ============================================================
# Cohort Construction & Evaluation（コホート構築・評価）
# ============================================================
RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(CRAN='https://packagemanager.posit.co/cran/__linux__/noble/latest')); \
             remotes::install_github('OHDSI/CohortDiagnostics', ref='v3.4.2'); \
             stopifnot(requireNamespace('CohortDiagnostics', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(CRAN='https://packagemanager.posit.co/cran/__linux__/noble/latest')); \
             remotes::install_github('OHDSI/CohortGenerator', ref='v1.1.1'); \
             stopifnot(requireNamespace('CohortGenerator', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(CRAN='https://packagemanager.posit.co/cran/__linux__/noble/latest')); \
             remotes::install_github('OHDSI/Capr', ref='v2.1.1'); \
             stopifnot(requireNamespace('Capr', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(CRAN='https://packagemanager.posit.co/cran/__linux__/noble/latest')); \
             remotes::install_github('OHDSI/PhenotypeLibrary', ref='v3.37.0'); \
             stopifnot(requireNamespace('PhenotypeLibrary', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(CRAN='https://packagemanager.posit.co/cran/__linux__/noble/latest')); \
             remotes::install_github('OHDSI/PheValuator', ref='v2.2.17'); \
             stopifnot(requireNamespace('PheValuator', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(CRAN='https://packagemanager.posit.co/cran/__linux__/noble/latest')); \
             remotes::install_github('OHDSI/CohortExplorer', ref='v0.1.0'); \
             stopifnot(requireNamespace('CohortExplorer', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(CRAN='https://packagemanager.posit.co/cran/__linux__/noble/latest')); \
             remotes::install_github('OHDSI/Keeper', ref='v2.1.3'); \
             stopifnot(requireNamespace('Keeper', quietly=TRUE))"

# ============================================================
# Population-level Estimation（母集団レベルの推定）
# ============================================================
RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(CRAN='https://packagemanager.posit.co/cran/__linux__/noble/latest')); \
             remotes::install_github('OHDSI/CohortMethod', ref='v6.0.3'); \
             stopifnot(requireNamespace('CohortMethod', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(CRAN='https://packagemanager.posit.co/cran/__linux__/noble/latest')); \
             remotes::install_github('OHDSI/SelfControlledCaseSeries', ref='v6.1.5'); \
             stopifnot(requireNamespace('SelfControlledCaseSeries', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(CRAN='https://packagemanager.posit.co/cran/__linux__/noble/latest')); \
             remotes::install_github('OHDSI/SelfControlledCohort', ref='v2.0.0'); \
             stopifnot(requireNamespace('SelfControlledCohort', quietly=TRUE))"

# EvidenceSynthesis: 除外（BeastJar バージョン競合）
#   インストール済み BeastJar 1.x に対し EvidenceSynthesis は >= 10.5.1 を要求。
#   BeastJar を 1.x → 10.x にアップグレードすると MethodEvaluation 等が破損するリスク。
#   次回 R/RStudio フルリビルド時に BeastJar 最新版で一括インストール予定。

# ============================================================
# Patient-level Prediction（患者レベルの予測）
# ============================================================
RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(CRAN='https://packagemanager.posit.co/cran/__linux__/noble/latest')); \
             remotes::install_github('OHDSI/PatientLevelPrediction', ref='v6.6.0'); \
             stopifnot(requireNamespace('PatientLevelPrediction', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(CRAN='https://packagemanager.posit.co/cran/__linux__/noble/latest')); \
             remotes::install_github('OHDSI/EnsemblePatientLevelPrediction', ref='v1.0.3'); \
             stopifnot(requireNamespace('EnsemblePatientLevelPrediction', quietly=TRUE))"

# DeepPatientLevelPrediction: Python/PyTorch 依存で重量超過のため除外

# ============================================================
# Characterization（特性解析）
# ============================================================
RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(CRAN='https://packagemanager.posit.co/cran/__linux__/noble/latest')); \
             remotes::install_github('OHDSI/Characterization', ref='v3.0.1'); \
             stopifnot(requireNamespace('Characterization', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(CRAN='https://packagemanager.posit.co/cran/__linux__/noble/latest')); \
             remotes::install_github('OHDSI/CohortIncidence', ref='v4.1.1'); \
             stopifnot(requireNamespace('CohortIncidence', quietly=TRUE))"

# TreatmentPatterns: OHDSI org ではなく darwin-eu-dev で管理
RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(CRAN='https://packagemanager.posit.co/cran/__linux__/noble/latest')); \
             remotes::install_github('darwin-eu-dev/TreatmentPatterns', ref='v3.1.2'); \
             stopifnot(requireNamespace('TreatmentPatterns', quietly=TRUE))"

# TreatmentPatterns オプション依存パッケージ（可視化）
# networkD3 → igraph → libglpk（システムライブラリ）の実行時リンク依存。
# libglpk40 は runtime ステージの apt に追加済み（builder ステージからはコピーされないため）。
# CRAN パッケージのため shiny/DT と同様 stopifnot なし
RUN R -q -e "options(repos = c(CRAN='https://packagemanager.posit.co/cran/__linux__/noble/latest')); \
             install.packages(c('sunburstR', 'networkD3'))"

# ============================================================
# Supporting Advanced（上位サポートパッケージ）
# OhdsiReportGenerator → OhdsiShinyModules の順（依存関係）
# Strategus は最後（CohortIncidence 等に依存）
# ============================================================
RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(CRAN='https://packagemanager.posit.co/cran/__linux__/noble/latest')); \
             remotes::install_github('OHDSI/BrokenAdaptiveRidge', ref='v1.0.1'); \
             stopifnot(requireNamespace('BrokenAdaptiveRidge', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(CRAN='https://packagemanager.posit.co/cran/__linux__/noble/latest')); \
             remotes::install_github('OHDSI/IterativeHardThresholding', ref='v1.0.3'); \
             stopifnot(requireNamespace('IterativeHardThresholding', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(CRAN='https://packagemanager.posit.co/cran/__linux__/noble/latest')); \
             remotes::install_github('OHDSI/ResultModelManager', ref='v0.6.2'); \
             stopifnot(requireNamespace('ResultModelManager', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(CRAN='https://packagemanager.posit.co/cran/__linux__/noble/latest')); \
             remotes::install_github('OHDSI/OhdsiReportGenerator', ref='v2.3.0'); \
             stopifnot(requireNamespace('OhdsiReportGenerator', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(CRAN='https://packagemanager.posit.co/cran/__linux__/noble/latest')); \
             remotes::install_github('OHDSI/OhdsiShinyModules', ref='v3.6.0'); \
             stopifnot(requireNamespace('OhdsiShinyModules', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(CRAN='https://packagemanager.posit.co/cran/__linux__/noble/latest')); \
             remotes::install_github('OHDSI/OhdsiShinyAppBuilder', ref='v1.1.0'); \
             stopifnot(requireNamespace('OhdsiShinyAppBuilder', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(CRAN='https://packagemanager.posit.co/cran/__linux__/noble/latest')); \
             remotes::install_github('OHDSI/Strategus', ref='v1.5.0'); \
             stopifnot(requireNamespace('Strategus', quietly=TRUE))"

# ---- site-library のサイズ削減（不要ファイルを削除）
# 注: この cleanup で *.h が削除されるため、インクリメンタルビルド時は
#     Rcpp を再インストールしてヘッダーを復元する必要がある（incremental.Dockerfile 参照）
RUN <<EOF
echo "=== Before cleanup ===" && du -sh /usr/local/lib/R/site-library
find /usr/local/lib/R/site-library -type d \( -name "doc" -o -name "html" -o -name "vignettes" -o -name "tests" -o -name "src" \) -exec rm -rf {} + 2>/dev/null || true
find /usr/local/lib/R/site-library -type f \( -name "*.c" -o -name "*.cpp" -o -name "*.h" -o -name "*.f90" \) -delete 2>/dev/null || true
find /usr/local/lib/R/site-library -type f \( -name "NEWS*" -o -name "README*" -o -name "LICENSE*" -o -name "CITATION" \) -delete 2>/dev/null || true
find /usr/local/lib/R/site-library -type f -name "*.so" -exec strip --strip-unneeded {} \; 2>/dev/null || true
find /usr/local/lib/R/site-library -type f -name "*.a" -exec strip --strip-unneeded {} \; 2>/dev/null || true
find /usr/local/lib/R/site-library -type f -name "*.o" -delete 2>/dev/null || true
echo "=== After cleanup ===" && du -sh /usr/local/lib/R/site-library
EOF

# CohortExplorer v0.1.0 Shiny バグパッチ（R 4.4.x 対応）
# Issue: https://github.com/OHDSI/CohortExplorer/issues/38
# 修正内容: Date-POSIXt 型不整合 + req() ガード追加（詳細は ohdsi_issue/ 参照）
COPY ohdsi_issue/CohortExplorer_server_patched.R \
    /usr/local/lib/R/site-library/CohortExplorer/shiny/server.R

# OhdsiReportGenerator v2.1.0 CohortIncidence スキーマパッチ
# Issue: ORG の getIncidenceRatesV0.sql が CI v3+ の source_name ではなく
#        CI v2 以前の database_id を参照しているため include_ci=true 時に失敗
# 修正内容: ON d.database_id = i.database_id → ON d.database_id = i.source_name
COPY ohdsi_issue/OhdsiReportGenerator_getIncidenceRatesV0_patched.sql \
    /usr/local/lib/R/site-library/OhdsiReportGenerator/sql/sql_server/characterization/getIncidenceRatesV0.sql

# OhdsiReportGenerator v2.1.0 presentation テンプレートパッチ
# Issue: presentation .qmd に parse error となる seq_len() の閉じ括弧欠落と
#        cohort_incidence_template.qmd の dplyr data masking バグがある
# 修正内容: 5 テンプレートを patched .qmd で差し替え
COPY ohdsi_issue/OhdsiReportGenerator_assure_presentation_patched.qmd \
    /usr/local/lib/R/site-library/OhdsiReportGenerator/templates/presentation/assure_presentation.qmd
COPY ohdsi_issue/OhdsiReportGenerator_cohort_definitions_patched.qmd \
    /usr/local/lib/R/site-library/OhdsiReportGenerator/templates/presentation/cohort_definitions.qmd
COPY ohdsi_issue/OhdsiReportGenerator_characterization_patched.qmd \
    /usr/local/lib/R/site-library/OhdsiReportGenerator/templates/presentation/characterization.qmd
COPY ohdsi_issue/OhdsiReportGenerator_cohort_incidence_template_patched.qmd \
    /usr/local/lib/R/site-library/OhdsiReportGenerator/templates/presentation/cohort_incidence_template.qmd
COPY ohdsi_issue/OhdsiReportGenerator_sccs_patched.qmd \
    /usr/local/lib/R/site-library/OhdsiReportGenerator/templates/presentation/sccs.qmd

# Characterization v3.0.0 attrition 列幅パッチ
# Issue: CreateTargetCohortTable.sql の attr_reason VARCHAR(50) が
#        NonCaseCohorts.sql の長い attrition reason を収容できず risk factor 解析が失敗
# 修正内容: attr_reason VARCHAR(50) → VARCHAR(200)
COPY ohdsi_issue/Characterization_CreateTargetCohortTable_patched.sql \
    /usr/local/lib/R/site-library/Characterization/sql/sql_server/CreateTargetCohortTable.sql

# CohortGenerator v1.1.0 DDL 型修正 — cohort_definition_id / subject_id を BIGINT → INT
# OHDSI CDM 仕様準拠（JOIN キーは INTEGER）。BIGINT のままだと JDBC → integer64 →
# Andromeda copy_to で型破損し TreatmentPatterns computePathways が全件 0 を返す。
RUN sed -i \
    -e 's/cohort_definition_id BIGINT/cohort_definition_id INT/g' \
    -e 's/subject_id BIGINT/subject_id INT/g' \
    /usr/local/lib/R/site-library/CohortGenerator/sql/sql_server/CreateCohortTables.sql


################################################################################
## RUNTIME
## builder-rstudio をベースに builder-hades-pkgs の成果物をコピー
## → ビルド依存（build-essential / Java JDK 等）を含まないクリーンなイメージ
################################################################################
FROM builder-rstudio AS runtime

# ---- HADES 用ランタイム依存ライブラリ（rJava / libpq 実行に必要）
# libglpk40: networkD3 → igraph の実行時リンク依存（builder ステージからはコピーされないため runtime に明示追加）
RUN apt-get update && apt-get install -y \
    libcurl4 \
    libssl3 \
    libxml2 \
    libpq5 \
    libicu74 \
    unixodbc \
    libglpk40 \
    libuv1t64 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ---- Java 実行環境（rJava / DatabaseConnector JDBC 接続に必要）
COPY --from=builder-hades-pkgs /usr/lib/jvm/java-1.8.0-amazon-corretto \
                                /usr/lib/jvm/java-1.8.0-amazon-corretto
RUN update-alternatives --install /usr/bin/java java \
        /usr/lib/jvm/java-1.8.0-amazon-corretto/bin/java 100
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-amazon-corretto

# rJava / DatabaseConnector が libjvm.so を解決するための JVM ライブラリパス。
# 対話 RStudio は docker-compose.yml の env で同値を渡すため image には不要だったが、
# ARACHNE Execution Engine は compose env を介さず本 image を直接 docker run するため、
# 非対話 Rscript 実行でも JVM を解決できるよう image に内蔵する。
# これにより AEE 専用 runtime イメージ(旧 hades-arachne-runtime)を廃し hades 一本に統合する。
# 両アーキ分を列挙（存在しない側のパスは ld.so が無視するため無害）。
ENV LD_LIBRARY_PATH=/usr/lib/jvm/java-1.8.0-amazon-corretto/jre/lib/amd64/server:/usr/lib/jvm/java-1.8.0-amazon-corretto/jre/lib/aarch64/server

# ---- JDBC ドライバー（PostgreSQL / Redshift / SQL Server / Oracle + 依存 jar 一式）
COPY --from=builder-hades-pkgs /jdbcdrivers /jdbcdrivers

# ---- R パッケージ（site-library + base library）
COPY --from=builder-hades-pkgs /usr/local/lib/R/site-library /usr/local/lib/R/site-library
COPY --from=builder-hades-pkgs /usr/local/lib/R/library      /usr/local/lib/R/library

EXPOSE 8787
CMD ["/init"]

