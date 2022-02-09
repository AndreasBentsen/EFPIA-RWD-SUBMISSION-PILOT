#!/bin/bash
echo "\npostgresServer = $POSTGRESQLIP" | tee -a >> /usr/local/lib/R/etc/Renviron.site


# Set up packages and keyring
#Rscript "/EFPIA-RWD-SUBMISSION-PILOT/Docker/cdm_upload_rstudio/setup.R"
cd /EFPIA-RWD-SUBMISSION-PILOT/logs
R CMD BATCH --no-save /EFPIA-RWD-SUBMISSION-PILOT/Docker/rwe_qualitydashboard/RunDataQualityDashboard.R