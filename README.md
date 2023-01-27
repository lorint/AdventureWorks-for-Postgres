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

## How to set up the database:

Download [Adventure Works 2014 OLTP Script](https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorks-oltp-install-script.zip).

Extract the .zip and copy all of the CSV files into the same folder, also containing update_csvs.rb file and install.sql.

Modify the CSVs to work with Postgres by running:
```
ruby update_csvs.rb
```
Create the database and tables, import the data, and set up the views and keys with:
```
psql -c "CREATE DATABASE \"Adventureworks\";"
psql -d Adventureworks < install.sql
```
(If you do not have a database created for your user account then you may need to also add:  `-U postgres`  to the above two commands.)

All 68 tables are properly set up, and 11 of the 20 views are established.  The ones not built are those that rely on XML functions like value and ref.  To see a list of tables, open psql, and then connect to the database and show all the tables with these two commands:
```
\c "Adventureworks"
\dt (humanresources|person|production|purchasing|sales).*
```

## Using with Docker

You can spin up a new database using **Docker** with `docker-compose up`.

_You will need to rename the Adventure Works 2014 OLTP Script archive to **adventure_works_2014_OLTP_script.zip** to get this to work!_


## Motivation

Five years ago I was pretty happy developing .NET apps for large organizations.  The stack was
mature, and good practices surrounding software development were very respected.  The same kind of
approach I appreciated from my days writing Java code was there, and the community was passionate.

Then along came Windows 8.  The //build/ conference in September 2011 revealed its first beta, and
even with that early peek at the new direction things were headed, it was clear that everything about
the platform was a haphazard combination of the new Metro apps along with all the traditional control
panel and options and API for classic code.  It left a very bad taste in my mouth.  Perhaps it would
look pretty, but be very unusable.  I couldn't see it ever being successful.  Once the "red pill"
registry setting vanished from the builds in mid-2012, the Windows 7 interface was then no longer
available even in Server editions.  I knew it was time for a change.  For a year I stuck it out
watching to see if there was any hope for some kind of tablet miracle out of Redmond, but I was
consistently unimpressed.

In mid-2013 a friend looped me in on a new project involving Ruby on Rails, and I fervently dove in
and have very much enjoyed the elegance of that ecosystem.  A big part of that has been ramping up my
knowledge of Postgres.  What a great database engine!  I figure that others departing the Microsoft
camp may appreciate the same data samples they're familiar with, so I created this along with the
Northwind sample.  It's been useful in the classroom training folks about Rails.  I expect with the
heavy-handed tactics Microsoft has now used around Windows 10 that even more organizations will
choose to transition away from that platform, so there will be lots of opportunity for samples like
this to help people learn a new environment.

As well, with the imminent release of SQL Server 2017 for Linux, this sample could be used to
evaluate performance differences between Postgres and SQL 2017.  Never thought I'd see the day that
MS SQL got compiled for Linux, but alas, here we are. 

Let's keep coding fun.

Enjoy!
