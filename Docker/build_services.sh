# Remove existing containers if they exist
sudo docker rm rwe_etlcms
sudo docker rm rwe_postgres
sudo docker rm rwe_cdmupload

# Build images
cd etl_cms
sudo docker build . -t rwe_etlcms

cd ..
cd postgresql
sudo docker build . -t rwe_postgres

cd ..
cd cdm_upload
sudo docker build . -t rwe_cdmupload

cd ..
cd r_analysis
sudo docker build . -t rwe_r_analysis

cd ..
cd cdm_ftpfiles
sudo docker build . -t rwe_r_ftpfiles

# 1. Run postgres
sudo docker run -e POSTGRES_DB=rwe -e POSTGRES_USER=rwe -e POSTGRES_PASSWORD=rwe --name rwe_postgres -v /home/oem/Dropbox/R/EFPIA-RWD-SUBMISSION-PILOT:/EFPIA-RWD-SUBMISSION-PILOT rwe_postgres

# 2. Run etl (with volume)
sudo docker run --name rwe_etlcms -v /home/oem/Dropbox/R/EFPIA-RWD-SUBMISSION-PILOT:/EFPIA-RWD-SUBMISSION-PILOT rwe_etlcms 

# 3. Cdm Upload through R
# sudo docker run --name rwe_cdmupload -v /home/oem/Dropbox/R/EFPIA-RWD-SUBMISSION-PILOT:/EFPIA-RWD-SUBMISSION-PILOT rwe_cdmupload 
sudo docker run -e PASSWORD=rwe --name rwe_cdmupload -p 8787:8787 -v /home/oem/Dropbox/R/EFPIA-RWD-SUBMISSION-PILOT:/EFPIA-RWD-SUBMISSION-PILOT rwe_cdmupload 

# 4. R Analysis
#sudo docker run --name rwe_r_analysis -v /home/oem/Dropbox/R/EFPIA-RWD-SUBMISSION-PILOT:/EFPIA-RWD-SUBMISSION-PILOT -it --entrypoint bash rwe_r_analysis 
sudo docker run --name rwe_r_analysis -p 8788:8787 -e PASSWORD=rwe -v /home/oem/Dropbox/R/EFPIA-RWD-SUBMISSION-PILOT:/EFPIA-RWD-SUBMISSION-PILOT rwe_r_analysis

# 4. R FTP Files
sudo docker run --name rwe_r_ftpfiles -p 8789:8787 -e PASSWORD=rwe -v /home/oem/Dropbox/R/EFPIA-RWD-SUBMISSION-PILOT:/EFPIA-RWD-SUBMISSION-PILOT rwe_r_ftpfiles


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