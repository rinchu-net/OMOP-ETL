# fill out the connection details -----------------------------------------------------------------------
connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = "postgresql",  # database version: postgresql
  user = "ohdsi_app_user",
  password = "app1",
  server = "host.rancher-desktop.internal/OHDSI",  # host/database
  port = "5432",
  extraSettings = "",
  pathToDriver = "/jdbcdrivers"  # JDBCドライバーが保存されているフォルダ
)

cdmDatabaseSchema <- "omop" # CDM schema
resultsDatabaseSchema <- "result" # Results schema
cdmSourceName <- "OHDSI" # 任意の名称
cdmVersion <- "5.4" # OMOP CDM version. Currently supports 5.2, 5.3, and 5.4

numThreads <- 1
sqlOnly <- FALSE
sqlOnlyIncrementalInsert <- FALSE
sqlOnlyUnionCount <- 1

# where should the results and logs go? ----------------------------------------------------------------
outputFolder <- "/home/rstudio/hades_user/dqdout"   # ファイルの出力先
outputFile <- "results.json"

verboseMode <- TRUE
writeToTable <- TRUE
writeTableName <- "dqdashboard_results"
writeToCsv <- FALSE
csvFile <- ""
checkLevels <- c("TABLE", "FIELD", "CONCEPT")
checkNames <- c()
tablesToExclude <- c("CONCEPT", "VOCABULARY", "CONCEPT_ANCESTOR", "CONCEPT_RELATIONSHIP", "CONCEPT_CLASS", "CONCEPT_SYNONYM", "RELATIONSHIP", "DOMAIN", "COHORT_DEFINITION")

# run the job --------------------------------------------------------------------------------------
# DQD v2.8.x では内蔵コンセプト CSV に旧チェック名列が残るため deprecation warning が出る（upstream 未修正）
# チェック自体は正常動作するため、DQD 固有の DEPRECATION WARNING のみを抑制する
withCallingHandlers(
  DataQualityDashboard::executeDqChecks(connectionDetails = connectionDetails,
                                        cdmDatabaseSchema = cdmDatabaseSchema,
                                        resultsDatabaseSchema = resultsDatabaseSchema,
                                        cdmSourceName = cdmSourceName,
                                        cdmVersion = cdmVersion,
                                        numThreads = numThreads,
                                        sqlOnly = sqlOnly,
                                        sqlOnlyUnionCount = sqlOnlyUnionCount,
                                        sqlOnlyIncrementalInsert = sqlOnlyIncrementalInsert,
                                        outputFolder = outputFolder,
                                        outputFile = outputFile,
                                        verboseMode = verboseMode,
                                        writeToTable = writeToTable,
                                        writeToCsv = writeToCsv,
                                        csvFile = csvFile,
                                        checkLevels = checkLevels,
                                        tablesToExclude = tablesToExclude,
                                        checkNames = checkNames),
  warning = function(w) {
    if (grepl("^DEPRECATION WARNING", conditionMessage(w))) invokeRestart("muffleWarning")
  }
)

# inspect logs ----------------------------------------------------------------------------
ParallelLogger::launchLogViewer(logFileName = file.path(outputFolder,
                                                        sprintf("log_DqDashboard_%s.txt", cdmSourceName)))

# DataQualityDashboard --------------------------------------------------------------------
DataQualityDashboard::viewDqDashboard(file.path(outputFolder,outputFile))
