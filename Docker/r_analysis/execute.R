library(Covid19EstimationHydroxychloroquine)

# Download JDBC
downloadJdbcDrivers(
  dbms = "postgresql",
  pathToDriver = Sys.getenv("pathToDriver"),
  method = "auto"
)

# Optional: specify where the temporary files (used by the ff package) will be created:
options(fftempdir = "/tmp")

# Maximum number of cores to be used:
maxCores <- parallel::detectCores()

# Minimum cell count when exporting data:
minCellCount <- 5

# The folder where the study intermediate and result files will be written:
outputFolder <- "/Covid19EstimationHydroxychloroquine"

# Details for connecting to the server:
# See ?DatabaseConnector::createConnectionDetails for help
connectionDetails <- createConnectionDetails(dbms = "postgresql", pathToDriver=Sys.getenv("pathToDriver"),
                                             server = paste(pathToDriver=Sys.getenv("postgresServer"), Sys.getenv("postgresDatabase"), sep = "/"),
                                             user = Sys.getenv("postgresUser"),
                                             password = Sys.getenv("postgresPassword"),
                                             port = Sys.getenv("postgresPort"))

# The name of the database schema where the CDM data can be found:
cdmDatabaseSchema <- Sys.getenv("cdmDatabaseSchema")

# The name of the database schema and table where the study-specific cohorts will be instantiated:
cohortDatabaseSchema <- "rwe"
cohortTable <- "cohort"

# Some meta-information that will be used by the export function:
# Please use a short and descriptive databaseId and databaseName, e.g. OptumDOD
databaseId <- "rwe"
databaseName <- "rwe_submission_pilot"
databaseDescription <- "RWE Submission Pilot"

# If using Oracle, define a schema that can be used to emulate temp tables. Otherwise set as NULL:
oracleTempSchema <- NULL

execute(connectionDetails = connectionDetails,
        cdmDatabaseSchema = cdmDatabaseSchema,
        cohortDatabaseSchema = cohortDatabaseSchema,
        cohortTable = cohortTable,
        oracleTempSchema = oracleTempSchema,
        outputFolder = outputFolder,
        databaseId = databaseId,
        databaseName = databaseName,
        databaseDescription = databaseDescription,
        createCohorts = TRUE,
        synthesizePositiveControls = FALSE,
        runAnalyses = TRUE,
        runDiagnostics = TRUE,
        packageResults = TRUE,
        maxCores = maxCores)

resultsZipFile <- file.path(outputFolder, "export", paste0("Results", databaseId, ".zip"))
dataFolder <- file.path(outputFolder, "shinyData")
prepareForEvidenceExplorer(resultsZipFile = resultsZipFile, dataFolder = dataFolder)
launchEvidenceExplorer(dataFolder = dataFolder, blind = TRUE, launch.browser = FALSE)


keyFileName <- "<directory location of study-data-site-covid19.dat>"
userName <- "study-data-site-covid19"
OhdsiSharing::sftpUploadFile(privateKeyFileName = keyFileName,
                          userName = userName,
                          remoteFolder = "Covid19EstimationHydroxychloroquine",
                          fileName = "<directory location of outputFolder/export>")