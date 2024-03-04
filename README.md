# Salary Per Hour

This mini project consisted of 2 parts:
- CSV Data Loader : A python program that reads from CSV files, transforms, and loads the data to the
destination table in incremental mode.
- Salary Per Hour Query : A SQL script that reads from `employees` and `timesheets` tables,transforms, and loads the result to `salary_per_hour` table in full-snapshot mode.


## System Requirements:
- Python 3.9
- PostgreSQL 16

## Setting up the database:
- Download and install PostgreSQL
- Create a database named `salary_per_hour`
- Create tables inside `salary_per_hour` database using DDL provided in path `sql/ddl.sql`
  
## How to run locally - CSV Data Loader:
1. Download and install Python
2. Download and install Poetry
3. Clone this repository to your local system
4. Navigate this project local directory via command line/terminal
5. Run `poetry install` to install all necessary dependencies
6. Run `poetry shell` to activate the virtual environment
7. Make sure that PostgreSQL instance is already running and you have set up the database
8. Adjust project directory definition on `csv_data_loader/main.py` line 8 based on your local directory
9. Run `python csv_data_loader/main.py` to run the python program

## How to run locally - Salary per Hour Query:
Execute all queries written in `sql/salary_per_hour.sql` on database client connected to database that contains `employees`,`timesheets`,and `salary_per_hour` tables