/*
=====================================================================
Store Procedure: Load Silver Layer (bronze -> Silver)
=====================================================================
Script Purpose:
    This store procedure performs the ETL (Extract, Transform, Load)
    process to populate the 'silver' schema tables from the 'bronze'
    schema.
Action Performed:
    - Insert transformed and cleansed data from bronze into Silver 
    tables.
Parameters:
None.
This stored procedure does not accept any parameters or return of 
any values.
=====================================================================
/*
CREATE OR ALTER PROCEDURE gold.load_goldr AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '=====================================================';
        PRINT 'Loading Gold Layer';
        PRINT '=====================================================';

        PRINT '-----------------------------------------------------';
        PRINT 'Loading table to calculate ROE';
        PRINT '-----------------------------------------------------';
        
        -- Use DROP TABLE IF EXISTS to prevent 'object already exists' error.
        IF OBJECT_ID('gold.bsis') IS NOT NULL
        BEGIN
            DROP TABLE gold.bsis;
        END

        SET @start_time = GETDATE();
-- Create ROE by filtering only Operating REvenue and Common Stock Equity.
SELECT 
    Account_Description,
    Company,
    Year,
    Amount
FROM gold.bsis
WHERE Account_Description = 'Operating Revenue' OR Account_Description = 'Common Stock Equity'
GROUP BY 
    Account_Description,
    Company,
    Year,
    Amount
SET @end_time = GETDATE();
        PRINT '>>Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds'
        PRINT '>>--------------------------------------------------'

        PRINT '===================================================='
        PRINT 'Loading table to calculate ROA'
        PRINT '===================================================='
        
        -- Use DROP TABLE IF EXISTS to prevent 'object already exists' error.
        IF OBJECT_ID('gold.bsis') IS NOT NULL
        BEGIN
            DROP TABLE gold.bsis;
        END

        SET @start_time = GETDATE();
-- Creating ROA, first we need to include the Assets accounts and then create a DAX to calculate Total Assets.
SELECT 
    Account_Description AS Account_Description,
    Company,
    Year,
    Amount
FROM gold.bsis
WHERE Account_Description IN (
    'Cash and Cash Equivalents',
    'Accounts Receivable',
    'Inventory',
    'Net PPE',
    'Intangible Assets',
    'Deferred Assets',
    'Other Properties',
    'Common Stock Equity'
)
SET @end_time = GETDATE();
        PRINT '>>Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds'
        PRINT '>>--------------------------------------------------'

        PRINT '==================================================='
        PRINT 'Loading union of tables Balance Sheet and Income Statement'
        PRINT '==================================================='
        
        -- Use DROP TABLE IF EXISTS to prevent 'object already exists' error.
        IF OBJECT_ID('gold.balance_income') IS NOT NULL
        BEGIN
            DROP TABLE gold.balance_income;
        END
--Union all on balance sheet & income statement to create dashboard
--Create view
SET @start_time = GETDATE();
CREATE gold.balance_income AS
SELECT *
FROM silver.balance_sheet
UNION ALL
SELECT *
FROM silver.income_statement
SET @end_time = GETDATE();
        PRINT '>>Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds'
        PRINT '>>--------------------------------------------------'
        
        SET @batch_end_time = GETDATE();
        PRINT '===================================================='
        PRINT 'Loading gold layer is completed';
        PRINT 'Total load duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds'
        PRINT '===================================================='
    END TRY
    BEGIN CATCH
        PRINT '===================================================='
        PRINT 'ERROR OCCURED DURING LOADING SILVER LAYER'
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '===================================================='
    END CATCH
END;
