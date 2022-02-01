# Code for analyzing issues during ETL
library(DatabaseConnector)
Sys.setenv(postgresServer='172.17.0.5')
# Download JDBC
downloadJdbcDrivers(dbms = "postgresql" , pathToDriver = Sys.getenv("pathToDriver") , method = "auto")
connectionDetails <- createConnectionDetails(dbms = "postgresql", pathToDriver=Sys.getenv("pathToDriver"),
                                             server = paste(pathToDriver=Sys.getenv("postgresServer"), Sys.getenv("postgresDatabase"), sep = "/"),
                                             user = Sys.getenv("postgresUser"),
                                             password = Sys.getenv("postgresPassword"),
                                             port = Sys.getenv("postgresPort"))

# Connection
cdmDatabaseSchema <- "rwe"
connection <- connect(connectionDetails)

# Tables
sql <- "SELECT TABLENAME FROM pg_catalog.pg_tables WHERE SCHEMANAME='@cdm_database_schema'"
tables = renderTranslateQuerySql(connection = connection, 
                        sql = sql,
                        cdm_database_schema = cdmDatabaseSchema)$TABLENAME

# Loop to count rows and present first 50 rows
sql_count <- "SELECT COUNT(*) FROM @cdm_database_schema.@table"
sql_first_50 <- "SELECT * FROM @cdm_database_schema.@table LIMIT 50"
lapply(tables,function(x) {
  message(x)
  count = renderTranslateQuerySql(connection = connection, 
                          sql = sql_count,
                          cdm_database_schema = cdmDatabaseSchema,
                          table = x)
  rows = renderTranslateQuerySql(connection = connection, 
                          sql = sql_first_50,
                          cdm_database_schema = cdmDatabaseSchema,
                          table = x)
  message(paste0("Rows: ",count))
  print( rows )
})

