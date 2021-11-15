#!/bin/bash

#cp /EFPIA-RWD-SUBMISSION-PILOT/Docker/cdm_upload_rstudio/.Renviron /root/.Renviron

# Set up packages and keyring
#Rscript "/EFPIA-RWD-SUBMISSION-PILOT/Docker/cdm_upload_rstudio/setup.R"
cd /EFPIA-RWD-SUBMISSION-PILOT/Docker/cdm_upload/
R CMD BATCH --no-save UploadTables.R
