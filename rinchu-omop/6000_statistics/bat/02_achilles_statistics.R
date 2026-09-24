#====================================================================
# achilles
#  description: code{achilles} creates descriptive statistics summary for an entire OMOP CDM instance.
#  details: code{achilles} creates descriptive statistics summary for an entire OMOP CDM instance.
#  Github: https://github.com/OHDSI/Achilles/blob/main/man/achilles.Rd
#
# Prerequisites:
# install.packages("usethis")  # .Renviron編集用
# library(usethis)
# edit_r_environ() ---> .Renvironに「_JAVA_OPTIONS='-Xmx4g'」を追記
# install.packages("remotes")
# remotes::install_github("OHDSI/Achilles")
#====================================================================
library(Achilles)

connectionDetails <- createConnectionDetails(
  dbms="postgresql", 
  server="localhost/OHDSI", 
  user="ohdsi_app_user", 
  password="app1",
  port="5432",
  pathToDriver = "path/to/jdbcdrivers")

options(connectionObserver = NULL)

achilles(connectionDetails = connectionDetails,
        sqlOnly = TRUE,
        cdmVersion = "5.4",
        cdmDatabaseSchema = "omop", 
        resultsDatabaseSchema = "atlas", 
        outputFolder = "output")
