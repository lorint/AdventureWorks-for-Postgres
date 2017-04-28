#!/bin/bash

export PGUSER=postgres
psql <<- SHELL
  CREATE USER docker;
  CREATE DATABASE "AdventureWorks";
  GRANT ALL PRIVILEGES ON DATABASE "AdventureWorks" TO docker;
SHELL
psql -d AdventureWorks < /data/install.sql
