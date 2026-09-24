# HADES パッケージ動作確認スクリプト — rinchu/hades:1.0.1（統合フルビルド版）
# 対象: HADES 公式 39 パッケージ中、インストール対象の 37 パッケージ
# 除外: EvidenceSynthesis（BeastJar競合）/ DeepPatientLevelPrediction（Python依存）
#
# RStudio で実行:
#   source("~/hades_setup/hades_package_test_v101.R")

cat("===========================================\n")
cat(" HADES パッケージ動作確認\n")
cat(" rinchu/hades:1.0.1（統合フルビルド版）\n")
cat(paste0(" 実行日時: ", Sys.time(), "\n"))
cat("===========================================\n\n")

results <- list()

check_pkg <- function(pkg) {
  result <- tryCatch({
    suppressPackageStartupMessages(library(pkg, character.only = TRUE))
    ver <- as.character(packageVersion(pkg))
    cat(sprintf("  \u2705 %-35s %s\n", pkg, ver))
    list(status = "OK", version = ver)
  }, error = function(e) {
    cat(sprintf("  \u274c %-35s ERROR: %s\n", pkg, conditionMessage(e)))
    list(status = "ERROR", version = NA)
  })
  result
}

# ============================================================
# Supporting（基盤・共通ライブラリ）
# ============================================================
cat("--- Supporting ---\n")
results[["SqlRender"]]                    <- check_pkg("SqlRender")
results[["DatabaseConnector"]]            <- check_pkg("DatabaseConnector")
results[["Cyclops"]]                      <- check_pkg("Cyclops")
results[["Andromeda"]]                    <- check_pkg("Andromeda")
results[["FeatureExtraction"]]            <- check_pkg("FeatureExtraction")
results[["ParallelLogger"]]               <- check_pkg("ParallelLogger")
results[["BigKnn"]]                       <- check_pkg("BigKnn")
results[["ROhdsiWebApi"]]                 <- check_pkg("ROhdsiWebApi")
results[["OhdsiSharing"]]                 <- check_pkg("OhdsiSharing")
results[["Eunomia"]]                      <- check_pkg("Eunomia")
results[["BrokenAdaptiveRidge"]]          <- check_pkg("BrokenAdaptiveRidge")
results[["IterativeHardThresholding"]]    <- check_pkg("IterativeHardThresholding")
results[["ResultModelManager"]]           <- check_pkg("ResultModelManager")
results[["OhdsiShinyModules"]]            <- check_pkg("OhdsiShinyModules")
results[["OhdsiShinyAppBuilder"]]         <- check_pkg("OhdsiShinyAppBuilder")
results[["OhdsiReportGenerator"]]         <- check_pkg("OhdsiReportGenerator")
results[["Strategus"]]                    <- check_pkg("Strategus")

cat("\n--- Evidence Quality ---\n")
results[["Achilles"]]                     <- check_pkg("Achilles")
results[["DataQualityDashboard"]]         <- check_pkg("DataQualityDashboard")
results[["EmpiricalCalibration"]]         <- check_pkg("EmpiricalCalibration")
results[["MethodEvaluation"]]             <- check_pkg("MethodEvaluation")

cat("\n--- Cohort Construction & Evaluation ---\n")
results[["CirceR"]]                       <- check_pkg("CirceR")
results[["CohortDiagnostics"]]            <- check_pkg("CohortDiagnostics")
results[["CohortGenerator"]]              <- check_pkg("CohortGenerator")
results[["Capr"]]                         <- check_pkg("Capr")
results[["PhenotypeLibrary"]]             <- check_pkg("PhenotypeLibrary")
results[["PheValuator"]]                  <- check_pkg("PheValuator")
results[["CohortExplorer"]]              <- check_pkg("CohortExplorer")
results[["Keeper"]]                       <- check_pkg("Keeper")

cat("\n--- Population-level Estimation ---\n")
results[["CohortMethod"]]                 <- check_pkg("CohortMethod")
results[["SelfControlledCaseSeries"]]     <- check_pkg("SelfControlledCaseSeries")
results[["SelfControlledCohort"]]         <- check_pkg("SelfControlledCohort")

cat("\n--- Patient-level Prediction ---\n")
results[["PatientLevelPrediction"]]       <- check_pkg("PatientLevelPrediction")
results[["EnsemblePatientLevelPrediction"]] <- check_pkg("EnsemblePatientLevelPrediction")

cat("\n--- Characterization ---\n")
results[["Characterization"]]             <- check_pkg("Characterization")
results[["CohortIncidence"]]              <- check_pkg("CohortIncidence")
results[["TreatmentPatterns"]]            <- check_pkg("TreatmentPatterns")

# ============================================================
# Java 初期化チェック（library() では検出できないため個別確認）
# ============================================================
cat("\n--- Java / JDBC ---\n")
java_ok <- tryCatch({
  ver <- DatabaseConnector::getAvailableJavaHeapSpace()
  cat(sprintf("  ✅ %-35s %s\n", "Java (rJava)", ver))
  TRUE
}, error = function(e) {
  cat(sprintf("  ❌ %-35s ERROR: %s\n", "Java (rJava)", conditionMessage(e)))
  FALSE
})

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
  cat(" \u2014 全パッケージ正常\n")
}
cat(sprintf(" Java: %s\n", if (java_ok) "✅ OK" else "❌ ERROR"))
cat("===========================================\n")
cat("\n【除外パッケージ（インストール対象外）】\n")
cat("  EvidenceSynthesis         : BeastJar バージョン競合（>=10.5.1 必要、1.x インストール済み）\n")
cat("  DeepPatientLevelPrediction: Python/PyTorch 依存で重量超過\n")
