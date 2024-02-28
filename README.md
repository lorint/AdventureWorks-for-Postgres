# AdventureWorks for Postgres

This project provides the scripts necessary to set up the OLTP part of the go-to database used in
training classes and for sample apps on the Microsoft stack. The result is 68 tables containing HR,
sales, product, and purchasing data organized across 5 schemas. It represents a fictitious bicycle
parts wholesaler with a hierarchy of nearly 300 employees, 500 products, 20000 customers, and 31000
sales each having an average of 4 line items. So it's big enough to be interesting, but not
unwieldy. In addition to being a well-rounded OLTP sample, it is also a good choice to demonstrate
ETL into a data warehouse.

Provided is a ruby file to convert CSVs available on CodePlex into a format usable by Postgres, as
well as a Postgres script to create the tables, load the data, convert the hierarchyid columns, add
primary and foreign keys, and create some of the views used by Adventureworks.

## Usage

All scripts assume Unixy environment where make command is available.
Everything is orchestrated through Makefile

1. Start your destination database

    `make db_start`

2. Run `make upload_data` once DB is fully up.

    - downloads the zip with AdventureWorks data
    - unpacks it
    - converts it using Ruby script
    - starts a separate postgres container that connects to the destination DB and streams data there

## Details

Data is downloaded from [Adventure Works 2014 OLTP Script](https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorks-oltp-install-script.zip).

Contents are extracted and processed / converted by update_csvs.rb

Some DB creation boilerplate SQL is rendered by steps in Makefile

All sql (dynamically rendered DB creation and tables restoration) is ran in a container that connects to the virtual network
on which DB instance is available and streams data to DB using psql command.

Wherever you see `?=` in Makefile you can override these environment variables by providing alternative values before the `make` command.
Example:

```
POSTGRES_USER=super POSTGRES_PASSWORD=pass DB_HOST=another_host DB_NAME=NotAdventureWorks make upload_data
```
