FROM python:2.7
#FROM jupyter/datascience-notebook
RUN /usr/local/bin/python -m pip install --upgrade pip
#RUN /usr/local/bin/python -m pip install --upgrade distribute
#RUN /usr/local/bin/python -m pip install python-dotenv

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get -y install default-jre-headless && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    
# Fix certificate issues
RUN apt-get update && \
    apt-get install ca-certificates-java && \
    apt-get clean && \
    update-ca-certificates -f;

# Setup JAVA_HOME -- useful for docker commandline
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
RUN export JAVA_HOME

ENTRYPOINT [ "/EFPIA-RWD-SUBMISSION-PILOT/Docker/rwe_etlcms/entrypoint.sh" ]