#!/bin/bash

#cp /EFPIA-RWD-SUBMISSION-PILOT/Docker/cdm_upload_rstudio/.Renviron /root/.Renviron

# Set up packages and keyring
#Rscript "/EFPIA-RWD-SUBMISSION-PILOT/Docker/cdm_upload_rstudio/setup.R"
cd /EFPIA-RWD-SUBMISSION-PILOT/logs
R CMD BATCH --no-save /EFPIA-RWD-SUBMISSION-PILOT/Docker/rwe_qualitydashboard/RunDataQualityDashboard.R
cd /EFPIA-RWD-SUBMISSION-PILOT/Output/FTP
unzip Vocab.zip -d Vocab
unzip EtlOutput.zip -d EtlOutput