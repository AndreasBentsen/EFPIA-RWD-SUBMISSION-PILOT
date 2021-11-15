#!/bin/bash

# Recipe:
# https://github.com/OHDSI/ETL-CMS/tree/master/python_etl

# 1. Install required software
# Python 2.7 with python-dotenv
cd /EFPIA-RWD-SUBMISSION-PILOT/src/
pip install -r requirements.txt

# 4. Setup the .env file to specify file locations
mkdir -p /EFPIA-RWD-SUBMISSION-PILOT/Data/
mkdir -p /EFPIA-RWD-SUBMISSION-PILOT/Data/OHDSI
mkdir -p /EFPIA-RWD-SUBMISSION-PILOT/Data/Evidera
mkdir -p /EFPIA-RWD-SUBMISSION-PILOT/Data/OHDSI/CMS_Control
mkdir -p /EFPIA-RWD-SUBMISSION-PILOT/Data/OHDSI/CMS_SynPuf
mkdir -p /EFPIA-RWD-SUBMISSION-PILOT/Data/OHDSI/OMOP/02_Vocabulary/Standard_Vocabulary_v5
mkdir -p /EFPIA-RWD-SUBMISSION-PILOT/Data/Evidera/98_output

# 2. Download SynPUF input data 
# 1 is not working
python get_synpuf_files.py  > log_download.txt

# 3. Download CDMv5 Vocabulary files
# https://athena.ohdsi.org/vocabulary/list

#apt-get install unzip 
unzip /EFPIA-RWD-SUBMISSION-PILOT/vocab.zip -d /EFPIA-RWD-SUBMISSION-PILOT/Data/OHDSI/OMOP/02_Vocabulary/Standard_Vocabulary_v5

# Because CPT4 vocabulary is not part of CONCEPT.csv file, one must download it with the provided cpt4.jar program via: 
cd /EFPIA-RWD-SUBMISSION-PILOT/Data/OHDSI/OMOP/02_Vocabulary/Standard_Vocabulary_v5
java -Dumls-apikey='dcb7040b-aba5-42e5-b1a0-dd3b9d9912a8' -jar cpt4.jar 5

# 5. Test ETL with DE_0 CMS test data
#python CMS_SynPuf_ETL_CDM_v5.py 0

# 6. Run ETL on CMS data
cd /EFPIA-RWD-SUBMISSION-PILOT/src
python CMS_SynPuf_ETL_CDM_v5.py 1 > /EFPIA-RWD-SUBMISSION-PILOT/Docker/etl_cms/log_conversion_1.txt
python CMS_SynPuf_ETL_CDM_v5.py 2 > /EFPIA-RWD-SUBMISSION-PILOT/Docker/etl_cms/log_conversion_2.txt
python CMS_SynPuf_ETL_CDM_v5.py 3 > /EFPIA-RWD-SUBMISSION-PILOT/Docker/etl_cms/log_conversion_3.txt
python CMS_SynPuf_ETL_CDM_v5.py 4 > /EFPIA-RWD-SUBMISSION-PILOT/Docker/etl_cms/log_conversion_4.txt
python CMS_SynPuf_ETL_CDM_v5.py 5 > /EFPIA-RWD-SUBMISSION-PILOT/Docker/etl_cms/log_conversion_5.txt
python CMS_SynPuf_ETL_CDM_v5.py 6 > /EFPIA-RWD-SUBMISSION-PILOT/Docker/etl_cms/log_conversion_6.txt
python CMS_SynPuf_ETL_CDM_v5.py 7 > /EFPIA-RWD-SUBMISSION-PILOT/Docker/etl_cms/log_conversion_7.txt
python CMS_SynPuf_ETL_CDM_v5.py 8 > /EFPIA-RWD-SUBMISSION-PILOT/Docker/etl_cms/log_conversion_8.txt
python CMS_SynPuf_ETL_CDM_v5.py 9 > /EFPIA-RWD-SUBMISSION-PILOT/Docker/etl_cms/log_conversion_9.txt
python CMS_SynPuf_ETL_CDM_v5.py 10 > /EFPIA-RWD-SUBMISSION-PILOT/Docker/etl_cms/log_conversion_10.txt
python CMS_SynPuf_ETL_CDM_v5.py 11 > /EFPIA-RWD-SUBMISSION-PILOT/Docker/etl_cms/log_conversion_11.txt
python CMS_SynPuf_ETL_CDM_v5.py 12 > /EFPIA-RWD-SUBMISSION-PILOT/Docker/etl_cms/log_conversion_12.txt
python CMS_SynPuf_ETL_CDM_v5.py 13 > /EFPIA-RWD-SUBMISSION-PILOT/Docker/etl_cms/log_conversion_13.txt
python CMS_SynPuf_ETL_CDM_v5.py 14 > /EFPIA-RWD-SUBMISSION-PILOT/Docker/etl_cms/log_conversion_14.txt
python CMS_SynPuf_ETL_CDM_v5.py 15 > /EFPIA-RWD-SUBMISSION-PILOT/Docker/etl_cms/log_conversion_15.txt
python CMS_SynPuf_ETL_CDM_v5.py 16 > /EFPIA-RWD-SUBMISSION-PILOT/Docker/etl_cms/log_conversion_16.txt
python CMS_SynPuf_ETL_CDM_v5.py 17 > /EFPIA-RWD-SUBMISSION-PILOT/Docker/etl_cms/log_conversion_17.txt
python CMS_SynPuf_ETL_CDM_v5.py 18 > /EFPIA-RWD-SUBMISSION-PILOT/Docker/etl_cms/log_conversion_18.txt
python CMS_SynPuf_ETL_CDM_v5.py 19 > /EFPIA-RWD-SUBMISSION-PILOT/Docker/etl_cms/log_conversion_19.txt
python CMS_SynPuf_ETL_CDM_v5.py 20 > /EFPIA-RWD-SUBMISSION-PILOT/Docker/etl_cms/log_conversion_20.txt
