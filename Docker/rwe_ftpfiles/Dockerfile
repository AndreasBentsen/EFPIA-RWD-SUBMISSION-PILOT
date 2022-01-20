FROM rocker/rstudio

RUN apt update -y
RUN apt install -y openjdk-8-jdk openjdk-8-jre libssl-dev libsodium-dev iputils-ping iproute2
RUN mkdir /jdbc_driver_folder
RUN chmod 777 /jdbc_driver_folder
RUN R CMD javareconf JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
COPY Renviron.site /usr/local/lib/R/etc/Renviron.site

# Install postgres
RUN apt-get install wget ca-certificates
RUN apt-get update && apt-get install -y gnupg
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
#RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/impish-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
#RUN cat /etc/apt/sources.list.d/pgdg.list
RUN apt-get update
RUN apt-get -y install postgresql postgresql-contrib

RUN Rscript -e 'options(java.parameters = c("-XX:+UseConcMarkSweepGC", "-Xmx8g")); install.packages(c("DatabaseConnector","SqlRender","readr"))'
RUN Rscript -e 'install.packages(c("remotes"))'
RUN Rscript -e 'remotes::install_github("ohdsi/OhdsiSharing")'

ENV USER="rstudio"
CMD ["/usr/lib/rstudio-server/bin/rserver", "--server-daemonize", "0", "--auth-none", "1"]