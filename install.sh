#!/bin/bash

export PGUSER=postgres
psql <<- SHELL
  CREATE USER docker;
  CREATE DATABASE "Adventureworks";
  GRANT ALL PRIVILEGES ON DATABASE "Adventureworks" TO docker;
SHELL
cd /data
psql -d Adventureworks < /data/install.sql
