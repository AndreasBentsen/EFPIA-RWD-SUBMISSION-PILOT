rm(list=ls())
#options(java.parameters = c("-XX:+UseConcMarkSweepGC", "-Xmx8g"))
options(java.parameters = c("-Xms8g","-Xmx8g"))
if (!require(DatabaseConnector)) install.packages("DatabaseConnector")
if (!require(SqlRender)) install.packages("SqlRender")
if (!require(readr)) install.packages("readr")

downloadJdbcDrivers(
  dbms = "postgresql",
  pathToDriver = Sys.getenv("pathToDriver"),
  method = "auto"
)

message("Downloaded JDBC Drivers...")
connectionDetails <- createConnectionDetails(dbms = "postgresql", pathToDriver=Sys.getenv("pathToDriver"),
                                             server = paste(pathToDriver=Sys.getenv("postgresServer"), Sys.getenv("postgresDatabase"), sep = "/"),
                                             user = Sys.getenv("postgresUser"),
                                             password = Sys.getenv("postgresPassword"),
                                             port = Sys.getenv("postgresPort"))

message("Connection Object...")

# Use bulk upload? Will be much faster, but requires POSTGRES_PATH variable set to folder containing pg.exe:
bulkLoad <- TRUE # need to fix ubuntu postgres TODO

# Schema where the CDM data should be uploaded:
cdmDatabaseSchema <- Sys.getenv("cdmDatabaseSchema")
# Local folder containing the vocabulary used in the ETL:
vocabFolder <- Sys.getenv("vocabFolder")

# Local folder containing the ETL-ed data. Data is expected to be in CSV files, with names corresponding to 
# the CDM table names. Number prefixes will be ignored. E.g. 'care_site_1.csv will be loaded into the 'case_site' table.
cdmFolder <- Sys.getenv("cdmFolder")

# Maximum number of rows that will be loaded into memory before writing to the database:
batchSize <- 2e7



connection <- connect(connectionDetails)
message("Connected...")

# Create table structures -----------------------------------------
sql <- render("CREATE SCHEMA IF NOT EXISTS rwe;")
executeSql(connection, sql)

sql <- render("SET SEARCH_PATH = @cdm_database_schema;", cdm_database_schema = cdmDatabaseSchema)
executeSql(connection, sql)

sql <- readSql("/EFPIA-RWD-SUBMISSION-PILOT/src/CdmUploadR/OMOP CDM ddl - PostgreSQL.sql")
executeSql(connection, sql)

# Load vocabulary ------------------------------------------------------------------
cdmTables <- tolower(getTableNames(connection, cdmDatabaseSchema))

files <- list.files(vocabFolder, ".csv")
for (file in files) {
  table <- gsub(".csv", "", tolower(file))
  if (table %in% cdmTables) {
    message("Uploading ", file, " to table ", table)
    upload <- function(chunk, pos) {
      message("- Uploading rows " , pos, " to ", (pos + nrow(chunk)))
      # The | becomes a quote and consumes all memoryu
      # 3060788	|Zoledronic acid 800micrograms/mL infusion concentrate 5mL vial	Drug	 
      dateCols <- grepl("_date$", tolower(colnames(chunk)))
      dateCols <- tolower(colnames(chunk))[dateCols]
      for (dateCol in dateCols) {
        if (is.numeric(chunk[[dateCol]])) {
          message(paste0("Converting col ",dateCol," to date"))
          chunk[[dateCol]] <- as.Date(as.character(chunk[[dateCol]]), "%Y%m%d")
        }
      }
      conceptIdCols <- grep("concept_id", tolower(colnames(chunk)))
      for (conceptIdCol in conceptIdCols) {
        chunk[, conceptIdCol] <- as.integer(chunk[[conceptIdCol]])
      }
      # Exceptions where bulk loading fails
      if (table %in% c("drug_strength")) {
        bulkLoad = FALSE
      }
      # For bulk uploading:
      options(encoding = "UTF-8")
      insertTable(connection = connection,
                  databaseSchema = cdmDatabaseSchema,
                  tableName = table,
                  data = chunk,
                  dropTableIfExists = FALSE,
                  createTable = FALSE,
                  bulkLoad = bulkLoad)
      # Enable bulk loading again
      bulkLoad = TRUE
    }

      read_delim_chunked(file = file.path(vocabFolder, file), 
                        callback = upload,
                        delim = "\t", 
                        #quote = "|", 
                        quote = "", 
                        na = "",
                        col_types = cols(),
                        guess_max = 1e5, 
                        progress = FALSE,
                        chunk_size = batchSize)   
      # "" replace to null
      if (table=="concept") {
        DatabaseConnector::renderTranslateExecuteSql(connection = connection, 
                                      sql = "UPDATE @cdmDatabaseSchema.concept SET invalid_reason = NULLIF(invalid_reason, '')",
                                      cdmDatabaseSchema = cdmDatabaseSchema)
        DatabaseConnector::renderTranslateExecuteSql(connection = connection, 
                                                     sql = "UPDATE @cdmDatabaseSchema.concept SET standard_concept = NULLIF(standard_concept, '')",
                                                     cdmDatabaseSchema = cdmDatabaseSchema)
      } else if (table=="concept_relationship") {
          DatabaseConnector::renderTranslateExecuteSql(connection = connection, 
                                        sql = "UPDATE @cdmDatabaseSchema.concept_relationship SET invalid_reason = NULLIF(invalid_reason, '')",
                                        cdmDatabaseSchema = cdmDatabaseSchema)
      }    else if (table=="vocabulary") {
        DatabaseConnector::renderTranslateExecuteSql(connection = connection, 
                                                     sql = "UPDATE @cdmDatabaseSchema.vocabulary SET vocabulary_version = NULLIF(vocabulary_version, '')",
                                                     cdmDatabaseSchema = cdmDatabaseSchema)
      }   

      
  } else {
    message("Skipping file ", file, " because not a CDM table")
  }
}


# Load CDM tables -------------------------------------------------------------------
cdmTables <- tolower(getTableNames(connection, cdmDatabaseSchema))

files <- list.files(cdmFolder, ".csv")
# files <- files[which(files == "person_1.csv"):length(files)]
# file <- files[1]
for (file in files) {
  table <- gsub(".[0-9]+.csv", "", tolower(file))
  if (table %in% cdmTables) {
    gc()
    message("Uploading ", file, " to table ", table)
    cdmFields <- renderTranslateQuerySql(connection, "SELECT TOP 0 * FROM @cdm_database_schema.@table;", cdm_database_schema = cdmDatabaseSchema, table = table)
    cdmFieldNames <- tolower(colnames(cdmFields))
    integerFields <- cdmFieldNames[sapply(cdmFields, storage.mode) == "integer"]
    
    upload <- function(chunk, pos) {
      message("- Uploading rows " , pos, " to ", (pos + nrow(chunk)))
      message("Dimensions ",ncol(chunk))
      message("Size: ",object.size(chunk)/1000000000)
      # Birth time elements as integer
      mobCols <- grepl("month_of_birth", tolower(colnames(chunk)))
      mobCols <- tolower(colnames(chunk))[mobCols]
      dobCols <- grepl("day_of_birth", tolower(colnames(chunk)))
      dobCols <- tolower(colnames(chunk))[dobCols]
      yobCols <- grepl("year_of_birth", tolower(colnames(chunk)))
      yobCols <- tolower(colnames(chunk))[yobCols]
      if (length(mobCols)>0) {
        message(paste0("Converting month of birth"))
        chunk[[mobCols]] <- as.integer(chunk[[mobCols]])
      }
      if (length(dobCols)>0) {
        message(paste0("Converting day of birth"))
        chunk[[dobCols]] <- as.integer(chunk[[dobCols]])
      }
      if (length(yobCols)>0) {
        message(paste0("Converting year of birth"))
        chunk[[yobCols]] <- as.integer(chunk[[yobCols]])
      }
      # Date cols
      dateCols <- grepl("_date$", tolower(colnames(chunk)))
      dateCols <- tolower(colnames(chunk))[dateCols]
      for (dateCol in dateCols) {
        if (is.numeric(chunk[[dateCol]])) {
          message(paste0("Converting col ",dateCol," to date"))
          chunk[[dateCol]] <- as.Date(as.character(chunk[[dateCol]]), "%Y%m%d")
        }
      }
      
      mismatchColumns <- colnames(chunk)[!tolower(colnames(chunk)) %in% cdmFieldNames]
      if (length(mismatchColumns) > 0) {
        warning("Ignoring columns not in CDM: ", paste(mismatchColumns, collapse = ","))
        chunk <- chunk[ ,!colnames(chunk) %in% mismatchColumns]
      }
      integerCols <- which(colnames(chunk) %in% integerFields)
      for (integerCol in integerCols) {
        chunk[, integerCol] <- as.integer(chunk[[integerCol]])
      }
      missingDateTimeFields <- cdmFieldNames[grep("_datetime$", cdmFieldNames)]
      missingDateTimeFields <- missingDateTimeFields[!missingDateTimeFields %in% tolower(colnames(chunk))]
      if (length(missingDateTimeFields) > 0) {
        for (field in missingDateTimeFields) {
          column <- gsub("_datetime", "_date", field)
          if (column %in% tolower(colnames(chunk))) {
            message("  Copying field ", column, " to field ", field)
            chunk[field] <- chunk[column]
          } else {
            warning("Could not generate datetime field ", field, " because column ", column, " was not found")
          }
        }
      }
      if (table == "drug_exposure" && any(is.na(chunk$drug_exposure_end_date))) {
        chunk$drug_exposure_end_date <- chunk$drug_exposure_start_date + ifelse(is.na(chunk$days_supply), 0, chunk$days_supply - 1)
      }
      
      # Exceptions where bulk loading fails
      if (table %in% c("care_site","condition_occurrence","death","device_exposure","drug_exposure","observation","person","procedure_occurrence","provider","visit_occurrence")) {        bulkLoad = FALSE      }
      # For bulk uploading:
      options(encoding = "UTF-8")
      insertTable(connection = connection,
                  databaseSchema = cdmDatabaseSchema,
                  tableName = table,
                  data = chunk,
                  dropTableIfExists = FALSE,
                  createTable = FALSE,
                  bulkLoad = bulkLoad)
      # Enable bulk loading again
      bulkLoad = TRUE
    }
    
    read_csv_chunked(file = file.path(cdmFolder, file), 
                     callback = upload,
                     na = "",
                     col_types = cols(),
                     guess_max = 1e5, 
                     progress = FALSE,
                     chunk_size = batchSize)
  } else {
    message("Skipping file ", file, " because not a CDM table")
  }
}


# Create indices and constraints ----------------------------------------------------------
sql <- render("SET SEARCH_PATH = @cdm_database_schema;", cdm_database_schema = cdmDatabaseSchema)
executeSql(connection, sql)

sql <- readSql("/EFPIA-RWD-SUBMISSION-PILOT/src/CdmUploadR/OMOP CDM constraints - PostgreSQL.sql") # <- errors
executeSql(connection, sql)

sql <- readSql("/EFPIA-RWD-SUBMISSION-PILOT/src/CdmUploadR/OMOP CDM indexes required - PostgreSQL.sql")
executeSql(connection, sql)

sql <- readSql("/EFPIA-RWD-SUBMISSION-PILOT/src/CdmUploadR/AdditionalIndexesAndAnalyze.sql")
executeSql(connection, sql)


# Build eras ------------------------------------------------------------------------
sql <- render("SET SEARCH_PATH = @cdm_database_schema;", cdm_database_schema = cdmDatabaseSchema)
executeSql(connection, sql)

sql <- readSql("/EFPIA-RWD-SUBMISSION-PILOT/src/CdmUploadR/buildConditionEras.sql")
renderTranslateExecuteSql(connection, sql)

sql <- readSql("/EFPIA-RWD-SUBMISSION-PILOT/src/CdmUploadR/buildDrugEras.sql")
renderTranslateExecuteSql(connection, sql)

# Populate cdm_source --------------------------------------------------
sql <- "SELECT vocabulary_version FROM @cdm_database_schema.vocabulary WHERE vocabulary_id = 'None';"
vocabularyVersion <- DatabaseConnector::renderTranslateQuerySql(connection = connection,
                                                                sql = sql,
                                                                cdm_database_schema = cdmDatabaseSchema)[1, 1]
row <- data.frame(cdm_source_name = "Medicare Claims Synthetic Public Use Files (SynPUFs)",
                  cdm_source_abbreviation = "rwe",
                  source_description = "Medicare Claims Synthetic Public Use Files (SynPUFs) were created to allow interested parties to gain familiarity using Medicare claims data while protecting beneficiary privacy. These files are intended to promote development of software and applications that utilize files in this format, train researchers on the use and complexities of Centers for Medicare and Medicaid Services (CMS) claims, and support safe data mining innovations. The SynPUFs were created by combining randomized information from multiple unique beneficiaries and changing variable values. This randomization and combining of beneficiary information ensures privacy of health information.",
                  cdm_release_date = Sys.Date(),
                  cdm_version = "5.2.2",
                  vocabulary_version = vocabularyVersion)
insertTable(connection = connection,
            databaseSchema = cdmDatabaseSchema,
            tableName = "cdm_source",
            data = row,
            createTable = FALSE)


disconnect(connection)

sink()