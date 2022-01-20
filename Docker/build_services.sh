#################################################
# Remove existing containers if they exist
#################################################
sudo docker rm -f rwe_etlcms
sudo docker rm -f rwe_cdmupload
sudo docker rm -f rwe_ftpfiles
sudo docker rm -f rwe_postgres
sudo docker rm -f rwe_qualitydashboard
sudo docker rm -f rwe_cdmupload
sudo docker rm -f rwe_r_analysis

#################################################
# Build images
#################################################
cd /EFPIA-RWD-SUBMISSION-PILOT/Docker/rwe_postgresql
sudo docker build . -t rwe_postgresql

cd /EFPIA-RWD-SUBMISSION-PILOT/Docker/rwe_etlcms
sudo docker build . -t rwe_etlcms

cd /EFPIA-RWD-SUBMISSION-PILOT/Docker/rwe_cdmupload
sudo docker build . -t rwe_cdmupload

cd /EFPIA-RWD-SUBMISSION-PILOT/Docker/rwe_qualitydashboard
sudo docker build . -t rwe_qualitydashboard

cd /EFPIA-RWD-SUBMISSION-PILOT/Docker/rwe_ranalysis
sudo docker build . -t rwe_ranalysis

cd /EFPIA-RWD-SUBMISSION-PILOT/Docker/rwe_ftpfiles
sudo docker build . -t rwe_ftpfiles

#################################################
# Run images
#################################################

# 1. PostgreSQL 
# (SynPuf)
sudo docker run --cpuset-cpus="3-5"  -itd --shm-size=18g -e POSTGRES_DB=rwe -e POSTGRES_USER=rwe -e POSTGRES_PASSWORD=rwe --name rwe_postgresql -v /EFPIA-RWD-SUBMISSION-PILOT/Data/postgresql:/var/lib/postgresql/data -v /EFPIA-RWD-SUBMISSION-PILOT:/EFPIA-RWD-SUBMISSION-PILOT rwe_postgresql
# FTP
sudo docker run -p 5431:5432 --cpuset-cpus="3-5"  -itd --shm-size=18g -e POSTGRES_DB=rwe -e POSTGRES_USER=rwe -e POSTGRES_PASSWORD=rwe --name rwe_postgresql_ftpfiles -v /EFPIA-RWD-SUBMISSION-PILOT/Data/postgresqlftp:/var/lib/postgresql/data -v /EFPIA-RWD-SUBMISSION-PILOT:/EFPIA-RWD-SUBMISSION-PILOT rwe_postgresql

# 2. ETL
#sudo docker run -it --entrypoint /bin/bash --name rwe_etlcms -v /EFPIA-RWD-SUBMISSION-PILOT:/EFPIA-RWD-SUBMISSION-PILOT rwe_etlcms 
sudo docker run -d --name rwe_etlcms -v /EFPIA-RWD-SUBMISSION-PILOT:/EFPIA-RWD-SUBMISSION-PILOT rwe_etlcms

# 3. UPLOAD
#sudo docker run -it --entrypoint bash -e PASSWORD=rwe --name rwe_cdmupload -p 8787:8787 -v /EFPIA-RWD-SUBMISSION-PILOT:/EFPIA-RWD-SUBMISSION-PILOT rwe_cdmupload
sudo docker run -d -e PASSWORD=rwe --name rwe_cdmupload -p 8787:8787 -v /EFPIA-RWD-SUBMISSION-PILOT:/EFPIA-RWD-SUBMISSION-PILOT rwe_cdmupload

# 4. Quality Dashboard
sudo docker run --name rwe_qualitydashboard -p 8791:8787 -e PASSWORD=rwe -v /EFPIA-RWD-SUBMISSION-PILOT:/EFPIA-RWD-SUBMISSION-PILOT rwe_qualitydashboard

# 5. R Analysis
#sudo docker run --name rwe_ranalysis -v /EFPIA-RWD-SUBMISSION-PILOT:/EFPIA-RWD-SUBMISSION-PILOT -it --entrypoint bash rwe_ranalysis 

{
sudo docker build . -t rwe_ranalysis
sudo docker run -d --cpuset-cpus="0-2" --name rwe_ranalysis -p 8789:8787 -e PASSWORD=rwe -v /EFPIA-RWD-SUBMISSION-PILOT:/EFPIA-RWD-SUBMISSION-PILOT -v /EFPIA-RWD-SUBMISSION-PILOT/Output/RANALYSIS_RSTUDIO:/EFPIA-RWD-SUBMISSION-PILOT/Output/RANALYSIS_RSTUDIO rwe_ranalysis
}
# 5b. R Analysis (RSTUDIO)
{
sudo docker stop rwe_ranalysis_rstudio && sudo docker rm rwe_ranalysis_rstudio
cd /EFPIA-RWD-SUBMISSION-PILOT/Docker/rwe_ranalysis_rstudio
sudo docker build . -t rwe_ranalysis_rstudio
sudo docker run -d --name rwe_ranalysis_rstudio -p 8790:8787 -e PASSWORD=rwe -v /EFPIA-RWD-SUBMISSION-PILOT:/EFPIA-RWD-SUBMISSION-PILOT -v /EFPIA-RWD-SUBMISSION-PILOT/Output/RANALYSIS_RSTUDIO:/EFPIA-RWD-SUBMISSION-PILOT/Output/RANALYSIS_RSTUDIO rwe_ranalysis_rstudio
}

# 6. FTP Files
{
sudo docker rm -f rwe_ftpfiles
cd /EFPIA-RWD-SUBMISSION-PILOT/Docker/rwe_ftpfiles
sudo docker build . -t rwe_ftpfiles
sudo docker run -d --name rwe_ftpfiles -p 8792:8787 -e PASSWORD=rwe -v /EFPIA-RWD-SUBMISSION-PILOT:/EFPIA-RWD-SUBMISSION-PILOT rwe_ftpfiles
}

#################################################
# Save
#################################################
cd..
sudo docker save rwe_postgres > rwe_postgres.tar

# Docker Compose
#sudo docker-compose -f docker-compose.yml up


# Recipe:
# https://github.com/OHDSI/ETL-CMS/tree/master/python_etl

# 1. Install required software
# Python 2.7 with python-dotenv
cd /EFPIA-RWD-SUBMISSION-PILOT/src/
pip install -r requirements.txt

# 2. Download SynPUF input data 
# 1 is not working
python get_synpuf_files.py /EFPIA-RWD-SUBMISSION-PILOT/Data/OHDSI/CMS_SynPuf 2

# 3. Download CDMv5 Vocabulary files
# https://athena.ohdsi.org/vocabulary/list

#apt-get install unzip 
unzip /EFPIA-RWD-SUBMISSION-PILOT/vocab.zip -d /EFPIA-RWD-SUBMISSION-PILOT/Data/OHDSI/OMOP/02_Vocabulary/Standard_Vocabulary_v5

# Because CPT4 vocabulary is not part of CONCEPT.csv file, one must download it with the provided cpt4.jar program via: 
cd /EFPIA-RWD-SUBMISSION-PILOT/Data/OHDSI/OMOP/02_Vocabulary/Standard_Vocabulary_v5
java -Dumls-apikey='XXXXXXXX INSERT KEY HERE XXXXXXXXXXXXXXXX' -jar cpt4.jar 5

# 4. Setup the .env file to specify file locations
mkdir -p /EFPIA-RWD-SUBMISSION-PILOT/Data/ \ 
/EFPIA-RWD-SUBMISSION-PILOT/Data/OHDSI \ 
/EFPIA-RWD-SUBMISSION-PILOT/Data/Evidera \ 
/EFPIA-RWD-SUBMISSION-PILOT/Data/OHDSI/CMS_Control \ 
/EFPIA-RWD-SUBMISSION-PILOT/Data/OHDSI/CMS_SynPuf \ 
/EFPIA-RWD-SUBMISSION-PILOT/Data/OHDSI/OMOP/02_Vocabulary/Standard_Vocabulary_v5 \ 
/EFPIA-RWD-SUBMISSION-PILOT/Data/Evidera/98_output

# 5. Test ETL with DE_0 CMS test data
#python CMS_SynPuf_ETL_CDM_v5.py 0

# 6. Run ETL on CMS data
cd /EFPIA-RWD-SUBMISSION-PILOT/src
python CMS_SynPuf_ETL_CDM_v5.py 2

# 7. Load data into the database

# Install psql
apt-get install wget ca-certificates
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ 'lsb_release -cs'-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
apt-get update
apt-get -y install postgresql postgresql-contrib

# Connect... TODO
psql 'dbname=rwe user=rwe password=rwe hostaddr=172.18.0.2' -f 'sql/create_CDMv5_tables.sql' -v data_dir={data_directory}