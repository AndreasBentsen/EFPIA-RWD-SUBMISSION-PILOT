#!/bin/bash
cd /EFPIA-RWD-SUBMISSION-PILOT/logs
R CMD BATCH --no-save /EFPIA-RWD-SUBMISSION-PILOT/Docker/rwe_ftpfiles/Sftp_2.R
cd ~
unzip EtlOutput.zip -d /EFPIA-RWD-SUBMISSION-PILOT/Data/ftpfiles
unzip Vocab.zip -d /EFPIA-RWD-SUBMISSION-PILOT/Data/ftpfiles/Vocab