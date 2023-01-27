#!/usr/bin/env ruby

# AdventureWorks for Postgres
#  by Lorin Thwaits

# How to use this file:

# Download "Adventure Works 2014 OLTP Script" from:
#   https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorks-oltp-install-script.zip

# Extract the .zip and copy all of the CSV files into the same folder containing
# this update_csvs.rb file and the install.sql file.

# Modify the CSVs to work with Postgres by running:
#   ruby update_csvs.rb

# Create the database and tables, import the data, and set up the views and keys with:
#   psql -c "CREATE DATABASE \"Adventureworks\";"
#   psql -d Adventureworks < install.sql

# (you may need to also add:  -U postgres  to the above two commands)

# All 68 tables are properly set up.
# All 20 views are established.
# 68 additional convenience views are added which:
#   * Provide a shorthand to refer to tables.
#   * Add an "id" column to a primary key or primary-ish key if it makes sense.

#   For example, with the convenience views you can simply do:
#       SELECT pe.p.firstname, hr.e.jobtitle
#       FROM pe.p
#         INNER JOIN hr.e ON pe.p.id = hr.e.id;
#   Instead of:
#       SELECT p.firstname, e.jobtitle
#       FROM person.person AS p
#         INNER JOIN humanresources.employee AS e ON p.businessentityid = e.businessentityid;

# Schemas for these views:
#   pe = person
#   hr = humanresources
#   pr = production
#   pu = purchasing
#   sa = sales
# Easily get a list of all of these in psql with:  \dv (pe|hr|pr|pu|sa).*

# Enjoy!


Dir.glob('./*.csv') do |csv_file|
  f = if (is_needed = csv_file.end_with?('/Address.csv'))
        File.open(csv_file, "rb:WINDOWS-1252:UTF-8")
      else
        File.open(csv_file, "rb:UTF-16LE:UTF-8")
      end
  output = ""
  text = ""
  is_first = true
  is_pipes = false
  begin
  f.each do |line|
    if is_first
      if line.include?("+|")
        is_pipes = true
      end
      if line[0] == "\uFEFF"
        line = line[1..-1]
        is_needed = true
      end
    end
    is_first = false
    break if !is_needed
    if is_pipes
      if line.strip.end_with?("&|")
        text << line.gsub("|474946383961", "|\\\\x474946383961") # For GIF data
                    .gsub(/\"/, "\"\"")
                    .strip[0..-3]
        output << text.split("+|").map { |part|
          (part[1] == "<" && part[-1] == ">") ? '"' + part[1..-1] + '"' :
          (part.include?("\t") ? '"' + part + '"' : part)
        }.join("\t")
        output << "\n"
        text = ""
      else
        text << line.gsub(/\"/, "\"\"").gsub("\r\n", "\\n")
      end
    else
      output << line.gsub(/\"/, "\"\"").gsub(/\&\|\n/, "\n").gsub(/\&\|\r\n/, "\n")
                    .gsub("\tE6100000010C", "\t\\\\xE6100000010C") # For geospatial data
                    .gsub(/\r\n/, "\n") # Make everything compatible with Windows -- change \r\n into just \n
    end
  end
  if is_needed
    puts "Processing #{csv_file}"
    f.close
    w = File.open(csv_file + ".xyz", "w")
    w.write(output)
    w.close
    File.delete(csv_file)
    File.rename(csv_file + ".xyz", csv_file)
  end

  # Here's a list of files that get snagged here:
  #    Address.csv
  #    AWBuildVersion.csv
  #    CreditCard.csv
  #    Culture.csv
  #    Currency.csv
  #    Department.csv
  #    EmployeeDepartmentHistory.csv
  #    EmployeePayHistory.csv
  #    Product.csv
  #    ProductCostHistory.csv
  #    ProductModelIllustration.csv
  #    ProductReview.csv
  #    SalesOrderDetail.csv
  #    SalesTerritory.csv
  #    Shift.csv
  #    ShipMethod.csv
  #    ShoppingCartItem.csv
  #    SpecialOffer.csv
  #    Vendor.csv
  #    WorkOrder.csv
  rescue Encoding::InvalidByteSequenceError
    f.close
  end
end
