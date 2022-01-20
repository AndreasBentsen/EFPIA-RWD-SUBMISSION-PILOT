# (Optional): Code to run DataQualityDashboard on the uploaded CMD data
library(DataQualityDashboard)

outputFolder <- "/EFPIA-RWD-SUBMISSION-PILOT/Output/DQD"

downloadJdbcDrivers(
  dbms = "postgresql",
  pathToDriver = Sys.getenv("pathToDriver"),
  method = "auto"
)

connectionDetails <- createConnectionDetails(dbms = "postgresql", pathToDriver=Sys.getenv("pathToDriver"),
                                             server = paste(pathToDriver=Sys.getenv("postgresServer"), Sys.getenv("postgresDatabase"), sep = "/"),
                                             user = Sys.getenv("postgresUser"),
                                             password = Sys.getenv("postgresPassword"),
                                             port = Sys.getenv("postgresPort"))

cdmDatabaseSchema <- "rwe"
resultsDatabaseSchema <- "ohdsi_results"

executeDqChecks(connectionDetails = connectionDetails, 
                cdmDatabaseSchema = cdmDatabaseSchema, 
                resultsDatabaseSchema = resultsDatabaseSchema,
                cdmSourceName = "SynPuf", 
                cdmVersion = "5.2.2",
                outputFolder = outputFolder)

# View the dashboard --------------------------------------------------
jsonFile <- list.files(outputFolder, ".json", full.names = TRUE)
viewDqDashboard(jsonPath = jsonFile)