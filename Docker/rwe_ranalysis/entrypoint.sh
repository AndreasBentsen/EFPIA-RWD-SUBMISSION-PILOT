#!/bin/bash
#cp /EFPIA-RWD-SUBMISSION-PILOT/Docker/cdm_upload_rstudio/.Renviron /root/.Renviron

# Set up packages and keyring
#Rscript "/EFPIA-RWD-SUBMISSION-PILOT/Docker/cdm_upload_rstudio/setup.R"
#Rscript "/EFPIA-RWD-SUBMISSION-PILOT/Docker/cdm_upload_rstudio/UploadTables.R"



#cp /EFPIA-RWD-SUBMISSION-PILOT/Docker/cdm_upload_rstudio/.Renviron /root/.Renviron

# Set up packages and keyring
#Rscript "/EFPIA-RWD-SUBMISSION-PILOT/Docker/cdm_upload_rstudio/setup.R"
cd /EFPIA-RWD-SUBMISSION-PILOT/logs
R CMD BATCH --no-save /EFPIA-RWD-SUBMISSION-PILOT/src/r_analysis/execute.R
