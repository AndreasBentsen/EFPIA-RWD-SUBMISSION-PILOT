FROM postgres

COPY tune_db.sql /docker-entrypoint-initdb.d/
RUN chmod a+r /docker-entrypoint-initdb.d/*

#CMD ["postgres","-c","config_file=/etc/postgresql.conf"]