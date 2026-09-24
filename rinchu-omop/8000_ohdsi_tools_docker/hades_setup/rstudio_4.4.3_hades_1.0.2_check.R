# HADES パッケージ動作確認スクリプト — rinchu/hades:1.0.2（統合フルビルド版）
# 対象: HADES 公式 39 パッケージ中、インストール対象の 37 パッケージ
# 除外: EvidenceSynthesis（BeastJar競合）/ DeepPatientLevelPrediction（Python依存）
#
# RStudio で実行:
#   source("~/hades_setup/rstudio_4.4.3_hades_1.0.2_check.R")
#
# AEE と同一条件（LD_LIBRARY_PATH を注入しない素の docker run）で検証する場合:
#   docker run --rm -v "$PWD/hades_setup:/home/rstudio/hades_setup" rinchu/hades:1.0.2 \
#     Rscript /home/rstudio/hades_setup/rstudio_4.4.3_hades_1.0.2_check.R
#
#   ※ docker compose 経由（RStudio 上での source / docker compose exec）は compose の env が
#     LD_LIBRARY_PATH を渡すため、image への内蔵有無を検証できない。§Java/JVM の判定を参照。

cat("===========================================\n")
cat(" HADES パッケージ動作確認\n")
cat(" rinchu/hades:1.0.2（統合フルビルド版）\n")
cat(paste0(" 実行日時: ", Sys.time(), "\n"))
cat(paste0(" R: ", getRversion(), " / ", R.version$platform, "\n"))
cat("===========================================\n\n")

results <- list()

# sprintf の %-35s は文字数で詰めるため日本語ラベルで桁がずれる。表示幅でパディングする。
pad <- function(s, w = 35) paste0(s, strrep(" ", max(0, w - nchar(s, type = "width"))))

check_pkg <- function(pkg) {
  result <- tryCatch({
    suppressPackageStartupMessages(library(pkg, character.only = TRUE))
    ver <- as.character(packageVersion(pkg))
    cat(sprintf("  ✅ %-35s %s\n", pkg, ver))
    list(status = "OK", version = ver)
  }, error = function(e) {
    cat(sprintf("  ❌ %-35s ERROR: %s\n", pkg, conditionMessage(e)))
    list(status = "ERROR", version = NA)
  })
  result
}

# ============================================================
# Supporting（基盤・共通ライブラリ）
# ============================================================
cat("--- Supporting ---\n")
results[["SqlRender"]]                      <- check_pkg("SqlRender")
results[["DatabaseConnector"]]              <- check_pkg("DatabaseConnector")
results[["Cyclops"]]                        <- check_pkg("Cyclops")
results[["Andromeda"]]                      <- check_pkg("Andromeda")
results[["FeatureExtraction"]]              <- check_pkg("FeatureExtraction")
results[["ParallelLogger"]]                 <- check_pkg("ParallelLogger")
results[["BigKnn"]]                         <- check_pkg("BigKnn")
results[["ROhdsiWebApi"]]                   <- check_pkg("ROhdsiWebApi")
results[["OhdsiSharing"]]                   <- check_pkg("OhdsiSharing")
results[["Eunomia"]]                        <- check_pkg("Eunomia")
results[["BrokenAdaptiveRidge"]]            <- check_pkg("BrokenAdaptiveRidge")
results[["IterativeHardThresholding"]]      <- check_pkg("IterativeHardThresholding")
results[["ResultModelManager"]]             <- check_pkg("ResultModelManager")
results[["OhdsiShinyModules"]]              <- check_pkg("OhdsiShinyModules")
results[["OhdsiShinyAppBuilder"]]           <- check_pkg("OhdsiShinyAppBuilder")
results[["OhdsiReportGenerator"]]           <- check_pkg("OhdsiReportGenerator")
results[["Strategus"]]                      <- check_pkg("Strategus")

cat("\n--- Evidence Quality ---\n")
results[["Achilles"]]                       <- check_pkg("Achilles")
results[["DataQualityDashboard"]]           <- check_pkg("DataQualityDashboard")
results[["EmpiricalCalibration"]]           <- check_pkg("EmpiricalCalibration")
results[["MethodEvaluation"]]               <- check_pkg("MethodEvaluation")

cat("\n--- Cohort Construction & Evaluation ---\n")
results[["CirceR"]]                         <- check_pkg("CirceR")
results[["CohortDiagnostics"]]              <- check_pkg("CohortDiagnostics")
results[["CohortGenerator"]]                <- check_pkg("CohortGenerator")
results[["Capr"]]                           <- check_pkg("Capr")
results[["PhenotypeLibrary"]]               <- check_pkg("PhenotypeLibrary")
results[["PheValuator"]]                    <- check_pkg("PheValuator")
results[["CohortExplorer"]]                 <- check_pkg("CohortExplorer")
results[["Keeper"]]                         <- check_pkg("Keeper")

cat("\n--- Population-level Estimation ---\n")
results[["CohortMethod"]]                   <- check_pkg("CohortMethod")
results[["SelfControlledCaseSeries"]]       <- check_pkg("SelfControlledCaseSeries")
results[["SelfControlledCohort"]]           <- check_pkg("SelfControlledCohort")

cat("\n--- Patient-level Prediction ---\n")
results[["PatientLevelPrediction"]]         <- check_pkg("PatientLevelPrediction")
results[["EnsemblePatientLevelPrediction"]] <- check_pkg("EnsemblePatientLevelPrediction")

cat("\n--- Characterization ---\n")
results[["Characterization"]]               <- check_pkg("Characterization")
results[["CohortIncidence"]]                <- check_pkg("CohortIncidence")
results[["TreatmentPatterns"]]              <- check_pkg("TreatmentPatterns")

# ============================================================
# Java / JVM 解決チェック
#
# 1.0.2 のビルド定義から一度 ENV LD_LIBRARY_PATH が欠落し、rJava 依存の 14 パッケージが
# ロード不能になった経緯がある。runtime ステージの $R_HOME/etc/ldpaths は
# R CMD javareconf 未反映（${JAVA_HOME}/lib/server を指す＝Corretto 8 には存在しない）ため、
# image に ENV LD_LIBRARY_PATH が無いと libjvm.so を解決できない。
# 詳細は rstudio_4.4.3_hades_1.0.2.md / documents/arachne.md §8.1。
# ============================================================
cat("\n--- Java / JVM 解決 ---\n")

java_home <- Sys.getenv("JAVA_HOME")
ld_paths  <- strsplit(Sys.getenv("LD_LIBRARY_PATH"), ":", fixed = TRUE)[[1]]
libjvm    <- list.files(java_home, pattern = "^libjvm\\.so$", recursive = TRUE, full.names = TRUE)

cat(sprintf("     %s %s\n", pad("JAVA_HOME"), if (nzchar(java_home)) java_home else "(未設定)"))
if (length(libjvm) == 0) {
  cat(sprintf("  ❌ %s JAVA_HOME 配下に見つからない\n", pad("libjvm.so")))
  ld_ok <- FALSE
} else {
  cat(sprintf("     %s %s\n", pad("libjvm.so"), libjvm[1]))
  ld_ok <- any(dirname(libjvm) %in% ld_paths)
  cat(sprintf("  %s %s %s\n",
              if (ld_ok) "✅" else "❌",
              pad("LD_LIBRARY_PATH に含まれる"),
              if (ld_ok) "yes" else "no — rJava は libjvm.so を解決できない"))
}

java_ok <- tryCatch({
  suppressPackageStartupMessages(library(rJava))
  rJava::.jinit()
  jver <- rJava::.jcall("java/lang/System", "S", "getProperty", "java.version")
  cat(sprintf("  ✅ %s java.version = %s\n", pad("rJava .jinit()"), jver))
  TRUE
}, error = function(e) {
  cat(sprintf("  ❌ %s ERROR: %s\n", pad("rJava .jinit()"), conditionMessage(e)))
  FALSE
})

if (java_ok && "getAvailableJavaHeapSpace" %in% getNamespaceExports("DatabaseConnector")) {
  tryCatch({
    cat(sprintf("  ✅ %s %s\n", pad("Java heap (DatabaseConnector)"),
                DatabaseConnector::getAvailableJavaHeapSpace()))
  }, error = function(e) {
    cat(sprintf("  ❌ %s ERROR: %s\n", pad("Java heap (DatabaseConnector)"), conditionMessage(e)))
  })
}

if (java_ok && !ld_ok) {
  cat("  ⚠ compose の env で LD_LIBRARY_PATH が補われている可能性がある。\n")
  cat("    AEE は compose env を通らないため、素の docker run で再検証すること。\n")
}

# ============================================================
# JDBC ドライバー
# ============================================================
cat("\n--- JDBC ドライバー (/jdbcdrivers) ---\n")
jdbc_specs <- list(
  "PostgreSQL" = "postgresql-*.jar",
  "Redshift"   = "redshift-jdbc42-*.jar",
  "SQL Server" = "mssql-jdbc*.jar",
  "Oracle"     = "ojdbc*.jar"
)
jdbc_ng <- 0
for (nm in names(jdbc_specs)) {
  hit <- Sys.glob(file.path("/jdbcdrivers", jdbc_specs[[nm]]))
  if (length(hit) > 0) {
    cat(sprintf("  ✅ %s %s\n", pad(nm), basename(hit[1])))
  } else {
    cat(sprintf("  ❌ %s 見つからない (%s)\n", pad(nm), jdbc_specs[[nm]]))
    jdbc_ng <- jdbc_ng + 1
  }
}
cat(sprintf("     %s %d ファイル\n", pad("/jdbcdrivers 総数"),
            length(list.files("/jdbcdrivers"))))

# ============================================================
# ビルド後パッチ適用確認
# 各パッチの背景・upstream 追従状況は rstudio_4.4.3_hades_1.0.2.md を参照
# ============================================================
cat("\n--- ビルド後パッチ適用確認 ---\n")

check_patch <- function(label, path, ok_fn) {
  if (!nzchar(path) || !file.exists(path)) {
    cat(sprintf("  ❌ %s ファイルが無い\n", pad(label)))
    return(FALSE)
  }
  txt <- paste(readLines(path, warn = FALSE), collapse = "\n")
  ok <- isTRUE(ok_fn(txt))
  cat(sprintf("  %s %s %s\n", if (ok) "✅" else "❌", pad(label),
              if (ok) "適用済" else "未適用"))
  ok
}

patch_ng <- 0
patch_ng <- patch_ng + !check_patch(
  "CohortExplorer server.R",
  system.file("shiny", "server.R", package = "CohortExplorer"),
  function(t) grepl("shiny::req(", t, fixed = TRUE) &&
              grepl("as.integer(as.Date(firstOccurrenceDateValue)", t, fixed = TRUE))

patch_ng <- patch_ng + !check_patch(
  "ORG getIncidenceRatesV0.sql",
  system.file("sql", "sql_server", "characterization", "getIncidenceRatesV0.sql",
              package = "OhdsiReportGenerator"),
  function(t) grepl("i.source_name", t, fixed = TRUE) &&
              !grepl("i.database_id", t, fixed = TRUE))

patch_ng <- patch_ng + !check_patch(
  "Characterization attr_reason 列幅",
  system.file("sql", "sql_server", "CreateTargetCohortTable.sql", package = "Characterization"),
  function(t) grepl("attr_reason VARCHAR(200)", t, fixed = TRUE))

patch_ng <- patch_ng + !check_patch(
  "CohortGenerator BIGINT→INT",
  system.file("sql", "sql_server", "CreateCohortTables.sql", package = "CohortGenerator"),
  function(t) !grepl("cohort_definition_id BIGINT", t, fixed = TRUE) &&
              !grepl("subject_id BIGINT", t, fixed = TRUE))

# ORG presentation テンプレートパッチは 2.2.0 で陳腐化（機能ごと upstream から削除）
org_has_presentation <- "generatePresentation" %in% getNamespaceExports("OhdsiReportGenerator")
cat(sprintf("  ℹ %s %s\n", pad("ORG presentation 機能"),
            if (org_has_presentation) "あり（パッチ有効）"
            else "v2.2.0 で削除済 — presentation パッチは陳腐化（撤去推奨）"))

# ============================================================
# サマリー
# ============================================================
ok  <- sum(sapply(results, function(r) r$status == "OK"))
err <- sum(sapply(results, function(r) r$status == "ERROR"))

cat("\n===========================================\n")
cat(sprintf(" 結果: %d / %d 成功", ok, ok + err))
if (err > 0) {
  cat(sprintf("  (%d 件エラー)\n", err))
  cat(" エラーパッケージ:\n")
  for (pkg in names(results)) {
    if (results[[pkg]]$status == "ERROR") cat(sprintf("   - %s\n", pkg))
  }
} else {
  cat(" — 全パッケージ正常\n")
}
cat(sprintf(" Java/JVM   : %s\n", if (java_ok && ld_ok) "✅ OK（image 内蔵の LD_LIBRARY_PATH で解決）"
                                  else if (java_ok)     "⚠ OK（ただし LD_LIBRARY_PATH の出所要確認）"
                                  else                  "❌ ERROR"))
cat(sprintf(" JDBC       : %s\n", if (jdbc_ng == 0) "✅ 4 種すべて配置"
                                  else sprintf("❌ %d 種欠落", jdbc_ng)))
cat(sprintf(" パッチ     : %s\n", if (patch_ng == 0) "✅ 4 件すべて適用済"
                                  else sprintf("❌ %d 件未適用", patch_ng)))
cat("===========================================\n")

cat("\n【除外パッケージ（インストール対象外）】\n")
cat("  EvidenceSynthesis         : BeastJar バージョン競合（>=10.5.1 必要、1.x インストール済み）\n")
cat("  DeepPatientLevelPrediction: Python/PyTorch 依存で重量超過\n")

if (err > 0 || !java_ok || !ld_ok || jdbc_ng > 0 || patch_ng > 0) {
  cat("\n⚠ 未解決の項目があります。詳細は rstudio_4.4.3_hades_1.0.2.md を参照してください。\n")
}
