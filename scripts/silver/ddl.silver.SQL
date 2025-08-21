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
CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '=====================================================';
        PRINT 'Loading Silver Layer';
        PRINT '=====================================================';

        PRINT '-----------------------------------------------------';
        PRINT 'Loading Stock Market price to Silver Layer';
        PRINT '-----------------------------------------------------';
        
        -- Use DROP TABLE IF EXISTS to prevent 'object already exists' error.
        IF OBJECT_ID('silver.stock_market_price') IS NOT NULL
        BEGIN
            DROP TABLE silver.stock_market_price;
        END

        SET @start_time = GETDATE();
        -- Create silver table
        SELECT *
        INTO
            silver.stock_market_price
        FROM bronze.stock_market_prices_filtered;
        
        SET @end_time = GETDATE();
        PRINT '>>Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds'
        PRINT '>>--------------------------------------------------'

        PRINT '===================================================='
        PRINT 'Loading Balance Sheet to silver layer'
        PRINT '===================================================='
        
        -- Use DROP TABLE IF EXISTS to prevent 'object already exists' error.
        IF OBJECT_ID('silver.balance_sheet') IS NOT NULL
        BEGIN
            DROP TABLE silver.balance_sheet;
        END

        SET @start_time = GETDATE();
        SELECT 
            UPPER(TRIM(Account_Description)) as Account_Description,
            UPPER(TRIM(company)) as Company,
            TRIM(year) as Year,
            FORMAT(
                CASE 
                    WHEN Amount IS NULL THEN 0 
                    ELSE Amount
                END, 'N0'
            ) AS Amount
        INTO
            silver.balance_sheet
        FROM bronze.balance_sheet_3;
        
        SET @end_time = GETDATE();
        PRINT '>>Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds'
        PRINT '>>--------------------------------------------------'

        PRINT '==================================================='
        PRINT 'Loading Income Statement to silver layer'
        PRINT '==================================================='
        
        -- Use DROP TABLE IF EXISTS to prevent 'object already exists' error.
        IF OBJECT_ID('silver.income_statement') IS NOT NULL
        BEGIN
            DROP TABLE silver.income_statement;
        END

        SET @start_time = GETDATE();
        SELECT 
            UPPER(TRIM(Account_Description)) AS Account_Description,
            UPPER(TRIM(company)) AS Company,
            UPPER(TRIM(year)) as Year,
            FORMAT(
                CASE 
                    WHEN Amount IS NULL THEN 0
                    ELSE Amount
                END, 'N0'
            ) AS Amount
        INTO
            silver.income_statement
        FROM bronze.income_statement_3;
        
        SET @end_time = GETDATE();
        PRINT '>>Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds'
        PRINT '>>--------------------------------------------------'
        
        SET @batch_end_time = GETDATE();
        PRINT '===================================================='
        PRINT 'Loading silver layer is completed';
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
