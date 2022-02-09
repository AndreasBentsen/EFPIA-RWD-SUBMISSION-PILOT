#!/bin/bash
echo "\npostgresServer = $POSTGRESQLIP" | tee -a >> /usr/local/lib/R/etc/Renviron.site

cd /EFPIA-RWD-SUBMISSION-PILOT/logs
R CMD BATCH --no-save /EFPIA-RWD-SUBMISSION-PILOT/src/r_analysis/execute.R
