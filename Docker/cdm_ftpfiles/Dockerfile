FROM rocker/rstudio

RUN apt update -y
RUN apt install -y openjdk-8-jdk openjdk-8-jre libssl-dev libsodium-dev iputils-ping iproute2
RUN R CMD javareconf JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
RUN Rscript -e 'install.packages(c("remotes"))'
RUN Rscript -e 'remotes::install_github("ohdsi/OhdsiSharing")'