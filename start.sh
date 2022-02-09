#!/usr/bin/env bash

### Colors ##
ESC=$(printf '\033') RESET="${ESC}[0m"
GREY="${ESC}[1;4m" GREYFILLED="${ESC}[100m" EXITRED="${ESC}[91m"

### Color Functions ##
print_GREYFILLED() { printf "${GREYFILLED}%s${RESET}\n" "$1"; }
print_GREY() { printf "${GREY}%s${RESET}\n" "$1"; }
print_EXITRED() { printf "${EXITRED}%s${RESET}\n" "$1"; }
bye() { echo "Closing..."; exit 0; }
fail() { echo "You have selected a wrong option..." exit 1; }

### MENU
mainmenu() {
    echo -ne "
$(print_GREYFILLED 'EFPIA RWE SUBMISSION PILOT')

$(print_GREY 'Synpuf')
1 Download & ETL: Build & Run Container
2 Download & ETL: Export Container to .tar.gz
3 PostgreSQL: Build & Run Container
4 PostgreSQL: Export Container to .tar.gz
5 Upload to PostgreSQL: Build & Run Container
6 Upload to PostgreSQL: Export Container to .tar.gz
7 Data Quality Dashboard: Build & Run Container
8 Data Quality Dashboard: Export Container to .tar.gz
9 Analysis: Build & Run Container
10 Analysis: Export Container to .tar.gz

$(print_GREY 'FTP ETL')
11 Download: Build & Run Container
12 Download: Export Container to .tar.gz
13 PostgreSQL: Build & Run Container
14 PostgreSQL: Export Container to .tar.gz
15 Upload to PostgreSQL: Build & Run Container
16 Upload to PostgreSQL: Export Container to .tar.gz
17 Data Quality Dashboard: Build & Run Container
18 Data Quality Dashboard: Export Container to .tar.gz
19 Analysis: Build & Run Container
20 Analysis: Export Container to .tar.gz
$(print_EXITRED '0 Exit')
Choose an option:  "
    read -r ans
    case $ans in
    1)
        { 
            sudo docker rm -f rwe_etlcms; cd ~/EFPIA-RWD-SUBMISSION-PILOT/Docker/rwe_etlcms; sudo docker build . -t rwe_etlcms; sudo docker run -d --name rwe_etlcms -p 8792:8787 -e dumlsapikey=XXXX -e PASSWORD=rwe -v ~/EFPIA-RWD-SUBMISSION-PILOT:/EFPIA-RWD-SUBMISSION-PILOT rwe_etlcms 
            }
        ;;
    2)
        {  
            mkdir -p ~/EFPIA-RWD-SUBMISSION-PILOT/Docker/images; sudo docker save rwe_etlcms > ~/EFPIA-RWD-SUBMISSION-PILOT/Docker/images/rwe_etlcms.tar 
            }
        ;;
    3)
        {
            sudo docker rm -f rwe_postgresql; cd ~/EFPIA-RWD-SUBMISSION-PILOT/Docker/rwe_postgresql; sudo docker build . -t rwe_postgresql; sudo docker run -itd --shm-size=18g -e POSTGRES_DB=rwe -e POSTGRES_USER=rwe -e POSTGRES_PASSWORD=rwe --name rwe_postgresql -v ~/EFPIA-RWD-SUBMISSION-PILOT/Data/postgresql:/var/lib/postgresql/data -v ~/EFPIA-RWD-SUBMISSION-PILOT:/EFPIA-RWD-SUBMISSION-PILOT rwe_postgresql; docker inspect rwe_postgresql | grep IPAddress | grep -v null| cut -d '"' -f 4 | head -1
            }
        ;;
    4)
        {  
            mkdir -p ~/EFPIA-RWD-SUBMISSION-PILOT/Docker/images; sudo docker save rwe_etlcms > rwe_etlcms.tar 
            }
        ;;
    5)
        {
            sudo docker rm -f rwe_cdmupload; cd ~/EFPIA-RWD-SUBMISSION-PILOT/Docker/rwe_cdmupload; sudo docker build . -t rwe_cdmupload; sudo docker run -d -e POSTGRESQLIP="$(sudo docker inspect rwe_postgresql | grep IPAddress | grep -v null| cut -d '"' -f 4 | head -1)" -e PASSWORD=rwe --name rwe_cdmupload -p 8787:8787 -v ~/EFPIA-RWD-SUBMISSION-PILOT:/EFPIA-RWD-SUBMISSION-PILOT rwe_cdmupload
            }
        ;;
    6)
        {  
            mkdir -p ~/EFPIA-RWD-SUBMISSION-PILOT/Docker/images; sudo docker save rwe_cdmupload > rwe_cdmupload.tar 
            }
        ;;
    7)
        {
            sudo docker rm -f rwe_qualitydashboard; cd ~/EFPIA-RWD-SUBMISSION-PILOT/Docker/rwe_qualitydashboard; sudo docker build . -t rwe_qualitydashboard; sudo docker run --name rwe_qualitydashboard -p 8791:8787 -e POSTGRESQLIP="$(docker inspect rwe_postgresql | grep IPAddress | grep -v null| cut -d '"' -f 4 | head -1)" -e PASSWORD=rwe -v ~/EFPIA-RWD-SUBMISSION-PILOT:/EFPIA-RWD-SUBMISSION-PILOT rwe_qualitydashboard
            }
        ;;
    8)
        {  
            mkdir -p ~/EFPIA-RWD-SUBMISSION-PILOT/Docker/images; sudo docker save rwe_qualitydashboard > rwe_qualitydashboard.tar 
            }
        ;;
    9)
        {
            sudo docker rm -f rwe_ranalysis; cd ~/EFPIA-RWD-SUBMISSION-PILOT/Docker/rwe_ranalysis; sudo docker build . -t rwe_ranalysis; sudo docker run -d --name rwe_ranalysis -p 8789:8787 -e POSTGRESQLIP="$(docker inspect rwe_postgresql | grep IPAddress | grep -v null| cut -d '"' -f 4 | head -1)" -e PASSWORD=rwe -v ~/EFPIA-RWD-SUBMISSION-PILOT:/EFPIA-RWD-SUBMISSION-PILOT -v ~/EFPIA-RWD-SUBMISSION-PILOT/Output/RANALYSIS_RSTUDIO:/EFPIA-RWD-SUBMISSION-PILOT/Output/RANALYSIS_RSTUDIO rwe_ranalysis
            }
        ;;
    10)
        {  
            mkdir -p ~/EFPIA-RWD-SUBMISSION-PILOT/Docker/images; sudo docker save rwe_ranalysis > rwe_ranalysis.tar 
            }
        ;;
    11)
        {
            sudo docker rm -f rwe_ftpfiles; cd /EFPIA-RWD-SUBMISSION-PILOT/Docker/rwe_ftpfiles; sudo docker build . -t rwe_ftpfiles; sudo docker run -d --name rwe_ftpfiles -p 8792:8787 -e PASSWORD=rwe -v ~/EFPIA-RWD-SUBMISSION-PILOT:/EFPIA-RWD-SUBMISSION-PILOT rwe_ftpfiles
            }
        ;;
    12)
        {  
            mkdir -p ~/EFPIA-RWD-SUBMISSION-PILOT/Docker/images; sudo docker save rwe_ftpfiles > rwe_ftpfiles.tar 
            }
        ;;
    13)
    {
        sudo docker rm -f rwe_postgresql_ftpfiles; cd ~/EFPIA-RWD-SUBMISSION-PILOT/Docker/rwe_postgresql_ftpfiles; sudo docker build . -t rwe_postgresql_ftpfiles; sudo docker run -p 5431:5432  -itd --shm-size=18g -e POSTGRES_DB=rwe -e POSTGRES_USER=rwe -e POSTGRES_PASSWORD=rwe --name rwe_postgresql_ftpfiles -v ~/EFPIA-RWD-SUBMISSION-PILOT/Data/postgresqlftp:/var/lib/postgresql/data -v ~/EFPIA-RWD-SUBMISSION-PILOT:/EFPIA-RWD-SUBMISSION-PILOT rwe_postgresql
        }
        ;;
    14)
        {  
            mkdir -p ~/EFPIA-RWD-SUBMISSION-PILOT/Docker/images; sudo docker save rwe_postgresql_ftpfiles > rwe_postgresql_ftpfiles.tar 
            }
        ;;
    15)
        submenu_5
        -e POSTGRESQLIP="$(docker inspect rwe_postgresql | grep IPAddress | grep -v null| cut -d '"' -f 4 | head -1)" 
        ;;
    16)
        submenu_5
        -e POSTGRESQLIP="$(docker inspect rwe_postgresql | grep IPAddress | grep -v null| cut -d '"' -f 4 | head -1)" 
        ;;
    17)
        submenu_5
        -e POSTGRESQLIP="$(docker inspect rwe_postgresql | grep IPAddress | grep -v null| cut -d '"' -f 4 | head -1)" 
        ;;
    18)
        submenu_5
        -e POSTGRESQLIP="$(docker inspect rwe_postgresql | grep IPAddress | grep -v null| cut -d '"' -f 4 | head -1)" 
        ;;
    19)
        submenu_5
        -e POSTGRESQLIP="$(docker inspect rwe_postgresql | grep IPAddress | grep -v null| cut -d '"' -f 4 | head -1)" 
        ;;
    20)
        submenu_5
        -e POSTGRESQLIP="$(docker inspect rwe_postgresql | grep IPAddress | grep -v null| cut -d '"' -f 4 | head -1)" 
        ;;
    0)
        bye
        ;;
    *)
        fail
        ;;
    esac
}

mainmenu