#!/bin/bash

# Download the AdventureWorks database
URL="https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorks-oltp-install-script.zip"
DEST_FILE="adventure_works_2014_OLTP_script.zip"
curl --proto '=https' --tlsv1.2 --progress-bar -SfL "$URL" -o "$DEST_FILE"
docker-compose up
