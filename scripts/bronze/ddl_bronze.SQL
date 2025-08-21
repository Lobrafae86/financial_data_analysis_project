/*
==========================================================================
DDL Script: Create Bronze Tables 2
==========================================================================
Script Purpose:
    This script creates tables in "bronze" schema, dropping existing tables 
    if they aready exist.
    Run this script to re-define the DDL structure of 'bronze tables.
==========================================================================
/*

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    -- Error corrected: Added DATETIME to @batch_end_time declaration.
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME
    BEGIN TRY 
        SET @batch_start_time = GETDATE()
        PRINT '====================================='
        PRINT 'Loading Bronze Layer'
        PRINT '====================================='

        PRINT '-------------------------------------'
        PRINT 'Loading stock market price'
        PRINT '-------------------------------------'
        
        -- Use DROP TABLE IF EXISTS to prevent the 'object already exists' error.
        -- This ensures the procedure can be run multiple times safely.
        SET @start_time = GETDATE()
        IF OBJECT_ID('bronze.stock_market_prices_filtered') IS NOT NULL
        BEGIN
            DROP TABLE bronze.stock_market_prices_filtered;
        END

        SELECT 
            CAST(Date AS DATE) AS Date,
            TSLA,
            AAPL,
            GOOGL,
            AMZN,
            MSFT,
            META,
            NFLX,
            NVDA
        INTO 
            bronze.stock_market_prices_filtered
        FROM 
            bronze.stock_market_prices
        WHERE 
            CAST(DATE as Date) BETWEEN '2022-01-01' AND '2024-12-31'
        SET @end_time = GETDATE()
        PRINT 'Load duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) as NVARCHAR) + ' seconds'
        PRINT '--------------------'

        PRINT '--------------------------------------------'
        PRINT 'Load Income Statement'
        PRINT '--------------------------------------------'
        -- Drop table before recreating it with SELECT INTO to avoid object already exists error.
        SET @start_time = GETDATE()
        IF OBJECT_ID('bronze.income_statement_3') IS NOT NULL
        BEGIN
            DROP TABLE bronze.income_statement_3;
        END
        SELECT 
            t.Account_Description,
            v.company,
            v.year,
            v.Amount
        INTO
            bronze.income_statement_3
        FROM bronze.income_statement_2 as t
        CROSS APPLY
            (VALUES
                ('TSLA','2024', t.TSLA_2024),
                ('TSLA','2023', t.TSLA_2023),
                ('TSLA','2022', t.TSLA_2022),
                ('AAPL','2024', t.AAPL_2024),
                ('AAPL','2023', t.AAPL_2023),
                ('AAPL','2022', t.AAPL_2022),
                ('GOOGL','2024', t.GOOGL_2024),
                ('GOOGL','2023', t.GOOGL_2023),
                ('GOOGL','2022', t.GOOGL_2022),
                ('AMZN','2024', t.AMZN_2024),
                ('AMZN','2023', t.AMZN_2023),
                ('AMZN','2022', t.AMZN_2022),
                ('MSFT','2024', t.MSFT_2024),
                ('MSFT','2023', t.MSFT_2023),
                ('MSFT','2022', t.MSFT_2022),
                ('META','2024', t.META_2024),
                ('META','2023', t.META_2023),
                ('META','2022', t.META_2022),
                ('NFLX','2024', t.NFLX_2024),
                ('NFLX','2023', t.NFLX_2023),
                ('NFLX','2X2', t.NFLX_2022),
                ('NVDA','2024', t.NVDA_2024),
                ('NVDA','2023', t.NVDA_2023),
                ('NVDA','2022', t.NVDA_2022)
            ) AS v (company,year,Amount);
        SET @end_time = GETDATE()
        PRINT 'Load duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) as NVARCHAR) + ' seconds'
        PRINT '--------------------'

        PRINT '---------------------------------------'
        PRINT 'Load Balance Sheet'
        PRINT '---------------------------------------'
        -- Drop table before recreating it with SELECT INTO to avoid object already exists error.
        SET @start_time = GETDATE()
        IF OBJECT_ID('bronze.balance_sheet_3') IS NOT NULL
        BEGIN
            DROP TABLE bronze.balance_sheet_3;
        END
        SELECT 
            t.Account_Description,
            v.company,
            v.year,
            v.Amount
        INTO
            bronze.balance_sheet_3
        FROM bronze.balance_sheets_2 as t
        CROSS APPLY
            (VALUES
                ('TSLA','2024', t.TSLA_2024),
                ('TSLA','2023', t.TSLA_2023),
                ('TSLA','2022', t.TSLA_2022),
                ('AAPL','2024', t.AAPL_2024),
                ('AAPL','2023', t.AAPL_2023),
                ('AAPL','2022', t.AAPL_2022),
                ('GOOGL','2024', t.GOOGL_2024),
                ('GOOGL','2023', t.GOOGL_2023),
                ('GOOGL','2022', t.GOOGL_2022),
                ('AMZN','2024', t.AMZN_2024),
                ('AMZN','2023', t.AMZN_2023),
                ('AMZN','2022', t.AMZN_2022),
                ('MSFT','2024', t.MSFT_2024),
                ('MSFT','2023', t.MSFT_2023),
                ('MSFT','2022', t.MSFT_2022),
                ('META','2024', t.META_2024),
                ('META','2023', t.META_2023),
                ('META','2022', t.META_2022),
                ('NFLX','2024', t.NFLX_2024),
                ('NFLX','2023', t.NFLX_2023),
                ('NFLX','2022', t.NFLX_2022),
                ('NVDA','2024', t.NVDA_2024),
                ('NVDA','2023', t.NVDA_2023),
                ('NVDA','2022', t.NVDA_2022)
            ) AS v (company,year,Amount);
        SET @end_time = GETDATE()
        PRINT 'Load duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) as NVARCHAR) + ' seconds';
        PRINT '--------------------'
        
        SET @batch_end_time =GETDATE()
        PRINT '======================================'
        PRINT 'Loading Bronze Layer is completed'
        PRINT '    - Total load duration: ' + CAST(DATEDIFF(second,@batch_start_time,@batch_end_time) as NVARCHAR) + ' seconds'
        PRINT '======================================'
    END TRY
    BEGIN CATCH
        PRINT '======================================'
        PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
        PRINT 'Error message: ' + ERROR_MESSAGE();
        PRINT 'Error state: ' + CAST (ERROR_STATE() AS NVARCHAR);
        PRINT '======================================'
    END CATCH
END;
