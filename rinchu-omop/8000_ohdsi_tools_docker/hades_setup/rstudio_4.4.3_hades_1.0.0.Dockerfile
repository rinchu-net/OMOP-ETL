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
#   CRAN 依存は RSPM (Posit Package Manager) からバイナリ優先で取得
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

ENV CRAN="https://p3m.dev/cran/__linux__/noble/2025-04-10"
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
RUN mkdir -p /jdbcdrivers && \
    curl -L -o /jdbcdrivers/postgresql-42.7.8.jar \
        https://jdbc.postgresql.org/download/postgresql-42.7.8.jar

# ---- Rcpp（コンパイル基盤）
# cleanup ステップで *.h を削除するため、インクリメンタルビルド時に Rcpp を再インストールして
# ヘッダーを復元する必要がある（rstudio_hades_incremental.Dockerfile 参照）。
# このフルビルドでは cleanup 前なので問題なし。
RUN R -q -e "install.packages('Rcpp', repos='https://cloud.r-project.org/')"

# ---- remotes（GitHub 直接インストール用）
RUN R -q -e "install.packages('remotes', repos='https://cloud.r-project.org/')"

# ---- HADES 前提パッケージ群（Supporting Core）
# 多くの HADES 分析パッケージが依存するコアライブラリ。
# 全パッケージを remotes::install_github() で GitHub から直接取得。
# CRAN 依存は RSPM バイナリ優先で取得（ソースコンパイル失敗を防止）。

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(RSPM='https://packagemanager.posit.co/cran/__linux__/noble/latest', CRAN='https://cloud.r-project.org/')); \
             remotes::install_github('OHDSI/SqlRender'); \
             stopifnot(requireNamespace('SqlRender', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(RSPM='https://packagemanager.posit.co/cran/__linux__/noble/latest', CRAN='https://cloud.r-project.org/')); \
             remotes::install_github('OHDSI/DatabaseConnector'); \
             stopifnot(requireNamespace('DatabaseConnector', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(RSPM='https://packagemanager.posit.co/cran/__linux__/noble/latest', CRAN='https://cloud.r-project.org/')); \
             remotes::install_github('OHDSI/Cyclops'); \
             stopifnot(requireNamespace('Cyclops', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(RSPM='https://packagemanager.posit.co/cran/__linux__/noble/latest', CRAN='https://cloud.r-project.org/')); \
             remotes::install_github('OHDSI/Andromeda'); \
             stopifnot(requireNamespace('Andromeda', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(RSPM='https://packagemanager.posit.co/cran/__linux__/noble/latest', CRAN='https://cloud.r-project.org/')); \
             remotes::install_github('OHDSI/FeatureExtraction'); \
             stopifnot(requireNamespace('FeatureExtraction', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(RSPM='https://packagemanager.posit.co/cran/__linux__/noble/latest', CRAN='https://cloud.r-project.org/')); \
             remotes::install_github('OHDSI/ParallelLogger'); \
             stopifnot(requireNamespace('ParallelLogger', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(RSPM='https://packagemanager.posit.co/cran/__linux__/noble/latest', CRAN='https://cloud.r-project.org/')); \
             remotes::install_github('OHDSI/BigKnn'); \
             stopifnot(requireNamespace('BigKnn', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(RSPM='https://packagemanager.posit.co/cran/__linux__/noble/latest', CRAN='https://cloud.r-project.org/')); \
             remotes::install_github('OHDSI/ROhdsiWebApi'); \
             stopifnot(requireNamespace('ROhdsiWebApi', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(RSPM='https://packagemanager.posit.co/cran/__linux__/noble/latest', CRAN='https://cloud.r-project.org/')); \
             remotes::install_github('OHDSI/OhdsiSharing'); \
             stopifnot(requireNamespace('OhdsiSharing', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(RSPM='https://packagemanager.posit.co/cran/__linux__/noble/latest', CRAN='https://cloud.r-project.org/')); \
             remotes::install_github('OHDSI/Eunomia'); \
             stopifnot(requireNamespace('Eunomia', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(RSPM='https://packagemanager.posit.co/cran/__linux__/noble/latest', CRAN='https://cloud.r-project.org/')); \
             remotes::install_github('OHDSI/CirceR'); \
             stopifnot(requireNamespace('CirceR', quietly=TRUE))"

# ---- UI 基盤（DataQualityDashboard / Shiny アプリ用）
RUN R -q -e "options(repos = c(RSPM='https://packagemanager.posit.co/cran/__linux__/noble/latest', CRAN='https://cloud.r-project.org/')); \
             install.packages(c('shiny', 'DT'))"


################################################################################
## STAGE 4: BUILDER-HADES-PKGS
## HADES 分析パッケージ群（全 37 パッケージ）
##
## 全パッケージを remotes::install_github() で GitHub から直接取得。
## CRAN 依存は RSPM バイナリ優先。各パッケージに stopifnot() 検証。
## OhdsiReportGenerator は OhdsiShinyModules より先に配置（依存関係）。
################################################################################
FROM builder-hades-base AS builder-hades-pkgs

# ============================================================
# Evidence Quality（エビデンスの質）
# ============================================================
RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(RSPM='https://packagemanager.posit.co/cran/__linux__/noble/latest', CRAN='https://cloud.r-project.org/')); \
             remotes::install_github('OHDSI/Achilles'); \
             stopifnot(requireNamespace('Achilles', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(RSPM='https://packagemanager.posit.co/cran/__linux__/noble/latest', CRAN='https://cloud.r-project.org/')); \
             remotes::install_github('OHDSI/DataQualityDashboard'); \
             stopifnot(requireNamespace('DataQualityDashboard', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(RSPM='https://packagemanager.posit.co/cran/__linux__/noble/latest', CRAN='https://cloud.r-project.org/')); \
             remotes::install_github('OHDSI/EmpiricalCalibration'); \
             stopifnot(requireNamespace('EmpiricalCalibration', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(RSPM='https://packagemanager.posit.co/cran/__linux__/noble/latest', CRAN='https://cloud.r-project.org/')); \
             remotes::install_github('OHDSI/MethodEvaluation'); \
             stopifnot(requireNamespace('MethodEvaluation', quietly=TRUE))"

# ============================================================
# Cohort Construction & Evaluation（コホート構築・評価）
# ============================================================
RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(RSPM='https://packagemanager.posit.co/cran/__linux__/noble/latest', CRAN='https://cloud.r-project.org/')); \
             remotes::install_github('OHDSI/CohortDiagnostics'); \
             stopifnot(requireNamespace('CohortDiagnostics', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(RSPM='https://packagemanager.posit.co/cran/__linux__/noble/latest', CRAN='https://cloud.r-project.org/')); \
             remotes::install_github('OHDSI/CohortGenerator'); \
             stopifnot(requireNamespace('CohortGenerator', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(RSPM='https://packagemanager.posit.co/cran/__linux__/noble/latest', CRAN='https://cloud.r-project.org/')); \
             remotes::install_github('OHDSI/Capr'); \
             stopifnot(requireNamespace('Capr', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(RSPM='https://packagemanager.posit.co/cran/__linux__/noble/latest', CRAN='https://cloud.r-project.org/')); \
             remotes::install_github('OHDSI/PhenotypeLibrary'); \
             stopifnot(requireNamespace('PhenotypeLibrary', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(RSPM='https://packagemanager.posit.co/cran/__linux__/noble/latest', CRAN='https://cloud.r-project.org/')); \
             remotes::install_github('OHDSI/PheValuator'); \
             stopifnot(requireNamespace('PheValuator', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(RSPM='https://packagemanager.posit.co/cran/__linux__/noble/latest', CRAN='https://cloud.r-project.org/')); \
             remotes::install_github('OHDSI/CohortExplorer'); \
             stopifnot(requireNamespace('CohortExplorer', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(RSPM='https://packagemanager.posit.co/cran/__linux__/noble/latest', CRAN='https://cloud.r-project.org/')); \
             remotes::install_github('OHDSI/Keeper'); \
             stopifnot(requireNamespace('Keeper', quietly=TRUE))"

# ============================================================
# Population-level Estimation（母集団レベルの推定）
# ============================================================
RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(RSPM='https://packagemanager.posit.co/cran/__linux__/noble/latest', CRAN='https://cloud.r-project.org/')); \
             remotes::install_github('OHDSI/CohortMethod'); \
             stopifnot(requireNamespace('CohortMethod', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(RSPM='https://packagemanager.posit.co/cran/__linux__/noble/latest', CRAN='https://cloud.r-project.org/')); \
             remotes::install_github('OHDSI/SelfControlledCaseSeries'); \
             stopifnot(requireNamespace('SelfControlledCaseSeries', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(RSPM='https://packagemanager.posit.co/cran/__linux__/noble/latest', CRAN='https://cloud.r-project.org/')); \
             remotes::install_github('OHDSI/SelfControlledCohort'); \
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
             options(repos = c(RSPM='https://packagemanager.posit.co/cran/__linux__/noble/latest', CRAN='https://cloud.r-project.org/')); \
             remotes::install_github('OHDSI/PatientLevelPrediction'); \
             stopifnot(requireNamespace('PatientLevelPrediction', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(RSPM='https://packagemanager.posit.co/cran/__linux__/noble/latest', CRAN='https://cloud.r-project.org/')); \
             remotes::install_github('OHDSI/EnsemblePatientLevelPrediction'); \
             stopifnot(requireNamespace('EnsemblePatientLevelPrediction', quietly=TRUE))"

# DeepPatientLevelPrediction: Python/PyTorch 依存で重量超過のため除外

# ============================================================
# Characterization（特性解析）
# ============================================================
RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(RSPM='https://packagemanager.posit.co/cran/__linux__/noble/latest', CRAN='https://cloud.r-project.org/')); \
             remotes::install_github('OHDSI/Characterization'); \
             stopifnot(requireNamespace('Characterization', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(RSPM='https://packagemanager.posit.co/cran/__linux__/noble/latest', CRAN='https://cloud.r-project.org/')); \
             remotes::install_github('OHDSI/CohortIncidence'); \
             stopifnot(requireNamespace('CohortIncidence', quietly=TRUE))"

# TreatmentPatterns: OHDSI org ではなく darwin-eu-dev で管理
RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(RSPM='https://packagemanager.posit.co/cran/__linux__/noble/latest', CRAN='https://cloud.r-project.org/')); \
             remotes::install_github('darwin-eu-dev/TreatmentPatterns'); \
             stopifnot(requireNamespace('TreatmentPatterns', quietly=TRUE))"

# ============================================================
# Supporting Advanced（上位サポートパッケージ）
# OhdsiReportGenerator → OhdsiShinyModules の順（依存関係）
# Strategus は最後（CohortIncidence 等に依存）
# ============================================================
RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(RSPM='https://packagemanager.posit.co/cran/__linux__/noble/latest', CRAN='https://cloud.r-project.org/')); \
             remotes::install_github('OHDSI/BrokenAdaptiveRidge'); \
             stopifnot(requireNamespace('BrokenAdaptiveRidge', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(RSPM='https://packagemanager.posit.co/cran/__linux__/noble/latest', CRAN='https://cloud.r-project.org/')); \
             remotes::install_github('OHDSI/IterativeHardThresholding'); \
             stopifnot(requireNamespace('IterativeHardThresholding', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(RSPM='https://packagemanager.posit.co/cran/__linux__/noble/latest', CRAN='https://cloud.r-project.org/')); \
             remotes::install_github('OHDSI/ResultModelManager'); \
             stopifnot(requireNamespace('ResultModelManager', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(RSPM='https://packagemanager.posit.co/cran/__linux__/noble/latest', CRAN='https://cloud.r-project.org/')); \
             remotes::install_github('OHDSI/OhdsiReportGenerator'); \
             stopifnot(requireNamespace('OhdsiReportGenerator', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(RSPM='https://packagemanager.posit.co/cran/__linux__/noble/latest', CRAN='https://cloud.r-project.org/')); \
             remotes::install_github('OHDSI/OhdsiShinyModules'); \
             stopifnot(requireNamespace('OhdsiShinyModules', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(RSPM='https://packagemanager.posit.co/cran/__linux__/noble/latest', CRAN='https://cloud.r-project.org/')); \
             remotes::install_github('OHDSI/OhdsiShinyAppBuilder'); \
             stopifnot(requireNamespace('OhdsiShinyAppBuilder', quietly=TRUE))"

RUN --mount=type=secret,id=ghpat \
    R -q -e "Sys.setenv(GITHUB_PAT = trimws(paste(readLines('/run/secrets/ghpat', warn=FALSE), collapse=''))); \
             options(repos = c(RSPM='https://packagemanager.posit.co/cran/__linux__/noble/latest', CRAN='https://cloud.r-project.org/')); \
             remotes::install_github('OHDSI/Strategus'); \
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


################################################################################
## RUNTIME
## builder-rstudio をベースに builder-hades-pkgs の成果物をコピー
## → ビルド依存（build-essential / Java JDK 等）を含まないクリーンなイメージ
################################################################################
FROM builder-rstudio AS runtime

# ---- HADES 用ランタイム依存ライブラリ（rJava / libpq 実行に必要）
RUN apt-get update && apt-get install -y \
    libcurl4 \
    libssl3 \
    libxml2 \
    libpq5 \
    libicu74 \
    unixodbc \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ---- Java 実行環境（rJava / DatabaseConnector JDBC 接続に必要）
COPY --from=builder-hades-pkgs /usr/lib/jvm/java-1.8.0-amazon-corretto \
                                /usr/lib/jvm/java-1.8.0-amazon-corretto
RUN update-alternatives --install /usr/bin/java java \
        /usr/lib/jvm/java-1.8.0-amazon-corretto/bin/java 100
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-amazon-corretto

# ---- PostgreSQL JDBC ドライバー
COPY --from=builder-hades-pkgs /jdbcdrivers /jdbcdrivers

# ---- R パッケージ（site-library + base library）
COPY --from=builder-hades-pkgs /usr/local/lib/R/site-library /usr/local/lib/R/site-library
COPY --from=builder-hades-pkgs /usr/local/lib/R/library      /usr/local/lib/R/library

EXPOSE 8787
CMD ["/init"]
