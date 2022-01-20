FROM rocker/rstudio

RUN apt update -y 
RUN apt install -y openjdk-8-jdk openjdk-8-jre libssl-dev libsodium-dev iputils-ping iproute2 
RUN apt update -y 
RUN apt install -y bzip2 zlib1g-dev liblzma-dev libpcre2-dev libbz2-dev libicu-dev libicu-dev
RUN apt update -y 
RUN apt install -y libxml2-dev


RUN R CMD javareconf JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/

RUN mkdir /jdbc_driver_folder
RUN chmod 777 /jdbc_driver_folder

RUN mkdir /Covid19EstimationHydroxychloroquine
RUN chmod 777 /Covid19EstimationHydroxychloroquine

COPY Renviron.site /usr/local/lib/R/etc/Renviron.site
COPY setup.R /setup.R

RUN Rscript /setup.R
RUN Rscript -e 'install.packages(c("readr","shiny","DT"))'

ENTRYPOINT [ "/bin/sh","/EFPIA-RWD-SUBMISSION-PILOT/Docker/rwe_ranalysis/entrypoint.sh" ]
