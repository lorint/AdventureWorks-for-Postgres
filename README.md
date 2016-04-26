# AdventureWorks-for-Postgres
###  by Lorin Thwaits

This consists of a ruby file to convert the CSVs into a format usable by Postgres,
as well as a Postgres script to create the tables, load the data, add primary and
foreign keys, and create some of the views used by Adventureworks.

## How to use this file:

Download [Adventure Works 2014 OLTP Script](https://msftdbprodsamples.codeplex.com/downloads/get/880662).
(If this link becomes broken then here's the [original page](https://msftdbprodsamples.codeplex.com/releases/view/125550).)

Extract the .zip and copy all of the CSV files into the same folder, also containing update_csvs.rb file and install.sql.

Modify the CSVs to work with Postgres by running:
    ruby update_csvs.rb

Create the database and tables, import the data, and set up the views and keys with:
    psql -c "CREATE DATABASE \"Adventureworks\";"
    psql -d Adventureworks < install.sql

The Production.ProductReview table gets omitted, but the remaining 67 tables are properly set up.

As well, 11 of the 20 views are established.  The ones not built are those that rely on XML functions like value and ref.

Enjoy!
