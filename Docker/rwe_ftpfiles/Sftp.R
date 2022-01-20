# This code is for uploading and downloading large files using the OHDSI SFTP server. Requires an account.

keyFile <- "/EFPIA-RWD-SUBMISSION-PILOT/Docker/rwe_ftpfiles/study-coordinator-repro"
userName <- "study-coordinator-repro"

library(OhdsiSharing)
connection <- sftpConnect(userName = userName, privateKeyFileName = keyFile)

# Download vocabulary files ---------------------------------------------
connection <- sftpConnect(userName = userName, privateKeyFileName = keyFile)
sftpGetFiles(connection, "Vocab.zip")

# Download ETL-ed files ---------------------------------------------
connection <- sftpConnect(userName = userName, privateKeyFileName = keyFile)
sftpGetFiles(connection, "EtlOutput.zip")