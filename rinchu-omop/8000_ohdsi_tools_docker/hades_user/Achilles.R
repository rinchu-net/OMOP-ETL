library(Achilles)

connectionDetails <- createConnectionDetails(
  dbms="postgresql",
  server="host.rancher-desktop.internal/OHDSI",
  user="ohdsi_app_user",
  password="app1",
  port="5432",
  pathToDriver = "/jdbcdrivers")

options(connectionObserver = NULL)

achilles(connectionDetails = connectionDetails,
         cdmVersion = "5.4",
         cdmDatabaseSchema = "omop",
         vocabDatabaseSchema = "omop",
         resultsDatabaseSchema = "result",
         outputFolder = "output",
         optimizeAtlasCache = TRUE,
         smallCellCount = 0,
         createIndices = TRUE # 推奨
)
