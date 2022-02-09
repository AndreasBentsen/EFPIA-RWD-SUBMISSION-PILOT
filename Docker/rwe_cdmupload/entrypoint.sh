#!/bin/bash
echo "\npostgresServer = $POSTGRESQLIP" | tee -a >> /usr/local/lib/R/etc/Renviron.site

cd /EFPIA-RWD-SUBMISSION-PILOT/logs
R CMD BATCH --no-save /EFPIA-RWD-SUBMISSION-PILOT/Docker/rwe_cdmupload/UploadTables.R
R CMD BATCH --no-save /EFPIA-RWD-SUBMISSION-PILOT/Docker/rwe_cdmupload/AnalyzeConceptIssues.R


