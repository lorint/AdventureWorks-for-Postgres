FROM library/postgres

RUN apt-get update
RUN apt-get -y install unzip ruby

RUN mkdir /build
COPY update_csvs.rb /build/
COPY adventure_works_2014_OLTP_script.zip /build/
RUN cd /build && \
    unzip adventure_works_2014_OLTP_script.zip && \
    rm adventure_works_2014_OLTP_script.zip && \
    ruby update_csvs.rb && \
    cp *.csv /docker-entrypoint-initdb.d/
RUN rm /build -rf

COPY install.sql /docker-entrypoint-initdb.d/

WORKDIR /docker-entrypoint-initdb.d
