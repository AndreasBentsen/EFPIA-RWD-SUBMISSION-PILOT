setwd("/Covid19EstimationHydroxychloroquine")

install.packages("https://cran.r-project.org/src/contrib/Archive/renv/renv_0.14.0.tar.gz", 
                 repos=NULL)
download.file("https://raw.githubusercontent.com/ohdsi-studies/Covid19EstimationHydroxychloroquine/reproducibility/renv.lock", "renv.lock")
renv::init()

library(Covid19EstimationHydroxychloroquine)

# Download JDBC
downloadJdbcDrivers(
  dbms = "postgresql",
  pathToDriver = Sys.getenv("pathToDriver"),
  method = "auto"
)

# Optional: specify where the temporary files (used by the ff package) will be created:
options(fftempdir = "/EFPIA-RWD-SUBMISSION-PILOT/Temp/", andromedaTempFolder = "/EFPIA-RWD-SUBMISSION-PILOT/Temp/")

# Maximum number of cores to be used:
maxCores <- 1

# Minimum cell count when exporting data:
minCellCount <- 5

# The folder where the study intermediate and result files will be written:
outputFolder <- "/EFPIA-RWD-SUBMISSION-PILOT/Output/RANALYSIS"

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

connectionDetails = connectionDetails
cdmDatabaseSchema = cdmDatabaseSchema
cohortDatabaseSchema = cohortDatabaseSchema
cohortTable = cohortTable
oracleTempSchema = oracleTempSchema
outputFolder = outputFolder
databaseId = databaseId
databaseName = databaseName
databaseDescription = databaseDescription
createCohorts = TRUE
synthesizePositiveControls = FALSE
runAnalyses = TRUE
runDiagnostics = TRUE
packageResults = TRUE
maxCores = maxCores

# execute(connectionDetails = connectionDetails,
#         cdmDatabaseSchema = cdmDatabaseSchema,
#         cohortDatabaseSchema = cohortDatabaseSchema,
#         cohortTable = cohortTable,
#         oracleTempSchema = oracleTempSchema,
#         outputFolder = outputFolder,
#         databaseId = databaseId,
#         databaseName = databaseName,
#         databaseDescription = databaseDescription,
#         createCohorts = TRUE,
#         synthesizePositiveControls = FALSE,
#         runAnalyses = TRUE,
#         runDiagnostics = TRUE,
#         packageResults = TRUE,
#         maxCores = maxCores)

if (!file.exists(outputFolder)) 
  dir.create(outputFolder, recursive = TRUE)
if (!is.null(getOption("fftempdir")) && !file.exists(getOption("fftempdir"))) {
  warning("fftempdir '", getOption("fftempdir"), "' not found. Attempting to create folder")
  dir.create(getOption("fftempdir"), recursive = TRUE)
}
ParallelLogger::addDefaultFileLogger(file.path(outputFolder, 
                                               "log.txt"))
on.exit(ParallelLogger::unregisterLogger("DEFAULT"))
if (createCohorts) {
  ParallelLogger::logInfo("Creating exposure and outcome cohorts")
  createCohorts(connectionDetails = connectionDetails, 
                cdmDatabaseSchema = cdmDatabaseSchema, cohortDatabaseSchema = cohortDatabaseSchema, 
                cohortTable = cohortTable, oracleTempSchema = oracleTempSchema, 
                outputFolder = outputFolder)
}
doPositiveControlSynthesis = FALSE
if (doPositiveControlSynthesis) {
  if (synthesizePositiveControls) {
    ParallelLogger::logInfo("Synthesizing positive controls")
    synthesizePositiveControls(connectionDetails = connectionDetails, 
                               cdmDatabaseSchema = cdmDatabaseSchema, cohortDatabaseSchema = cohortDatabaseSchema, 
                               cohortTable = cohortTable, oracleTempSchema = oracleTempSchema, 
                               outputFolder = outputFolder, maxCores = maxCores)
  }
}
if (runAnalyses) {
  ParallelLogger::logInfo("Running CohortMethod analyses")
  runCohortMethod(connectionDetails = connectionDetails, 
                  cdmDatabaseSchema = cdmDatabaseSchema, cohortDatabaseSchema = cohortDatabaseSchema, 
                  cohortTable = cohortTable, oracleTempSchema = oracleTempSchema, 
                  outputFolder = outputFolder, maxCores = maxCores)
}
if (runDiagnostics) {
  ParallelLogger::logInfo("Running diagnostics")
  generateDiagnostics(outputFolder = outputFolder, maxCores = maxCores)
}
if (packageResults) {
  ParallelLogger::logInfo("Packaging results")
  exportResults(outputFolder = outputFolder, databaseId = databaseId, 
                databaseName = databaseName, databaseDescription = databaseDescription, 
                minCellCount = minCellCount, maxCores = maxCores)
}


resultsZipFile <- file.path(outputFolder, "export", paste0("Results", databaseId, ".zip"))
dataFolder <- file.path(outputFolder, "shinyData")
prepareForEvidenceExplorer(resultsZipFile = resultsZipFile, dataFolder = dataFolder)
# launchEvidenceExplorer(dataFolder = dataFolder, blind = TRUE, launch.browser = TRUE)


#keyFileName <- "<directory location of study-data-site-covid19.dat>"
#userName <- "nn-synpuf-covid19"
#OhdsiSharing::sftpUploadFile(privateKeyFileName = keyFileName,
#                          userName = userName,
#                          remoteFolder = "Covid19EstimationHydroxychloroquine",
#                          fileName = "/EFPIA-RWD-SUBMISSION-PILOT/Output/RANALYSIS/export")