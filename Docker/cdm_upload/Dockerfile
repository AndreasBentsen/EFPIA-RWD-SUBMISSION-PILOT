FROM rocker/rstudio

RUN apt update -y
RUN apt install -y openjdk-8-jdk openjdk-8-jre libssl-dev libsodium-dev iputils-ping iproute2
RUN R CMD javareconf JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
RUN Rscript -e 'install.packages(c("DatabaseConnector","SqlRender","readr"))'
RUN mkdir /jdbc_driver_folder
RUN chmod 777 /jdbc_driver_folder
COPY Renviron.site /usr/local/lib/R/etc/Renviron.site

ENTRYPOINT [ "/bin/bash /EFPIA-RWD-SUBMISSION-PILOT/Docker/cdm_upload/entrypoint.sh" ]