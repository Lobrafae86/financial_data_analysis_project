/*
==============================================================

Create Database and Schemas

==============================================================
Script Purpose:
    This scripts creates a new database named "FinanceData".
    The scripts sets up three schemas withing the database: 'bronze', 'silver' and 'gold'.

*/

--Create the Database--
CREATE DATABASE FinanceData;

USE FinanceData;

--Create Schemas--
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
