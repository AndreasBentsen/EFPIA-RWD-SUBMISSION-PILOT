FROM rocker/rstudio

RUN apt update -y
RUN apt install -y openjdk-8-jdk openjdk-8-jre libssl-dev libsodium-dev iputils-ping iproute2
RUN R CMD javareconf JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
RUN Rscript -e 'options(java.parameters = c("-XX:+UseConcMarkSweepGC", "-Xmx8g")); install.packages(c("DatabaseConnector","SqlRender","readr"))'
RUN mkdir /jdbc_driver_folder
RUN chmod 777 /jdbc_driver_folder
COPY Renviron.site /usr/local/lib/R/etc/Renviron.site

# Install postgres
RUN apt-get install wget ca-certificates
RUN apt-get update && apt-get install -y gnupg
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
#RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/impish-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
#RUN cat /etc/apt/sources.list.d/pgdg.list
RUN apt-get update
RUN apt-get -y install postgresql postgresql-contrib

ENTRYPOINT [ "/bin/sh","/EFPIA-RWD-SUBMISSION-PILOT/Docker/rwe_cdmupload/entrypoint.sh" ]