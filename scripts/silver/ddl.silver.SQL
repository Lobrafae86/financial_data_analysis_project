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
        PRINT 'Loading Stock Market price to Silver Layer';
        PRINT '=====================================================';

        PRINT '-----------------------------------------------------';
        PRINT 'Loading Tables';
        PRINT '-----------------------------------------------------';
        -- Loading silver.stock_market_price
        SET @start_time = GETDATE();
        -- Unpivoting data to structure it
        SELECT
            Date,
            Company,
            Amount
        INTO
            silver.stock_market_price
        FROM bronze.stock_market_prices_2
        UNPIVOT (
            Amount  FOR Company IN (
                TSLA,
                AAPL,
                GOOGL,
                AMZN,
                MSFT,
                META,
                NFLX,
                NVDA
            )
        ) AS UnpivotedData; 
        SET @end_time = GETDATE();
        PRINT '>>Load duration' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)+ 'seconds'
        PRINT '>>--------------------------------------------------'

        PRINT '===================================================='
        PRINT 'Loading Balance Sheet to silver layer'
        PRINT '===================================================='

        -- Loading silver.balance_sheet
        SET @start_time = GETDATE();
        SELECT 
            UPPER(TRIM([Account_Description])) AS Account_Description,--Remove unwanted space & format number
            FORMAT(TSLA_2024,'#,###') AS TSLA_2024,
            FORMAT(TSLA_2023,'#,###') AS TSLA_2023,
            FORMAT(TSLA_2022,'#,###') AS TSLA_2022,
            FORMAT(AAPL_2024,'#,###') AS AAPL_2024,
            FORMAT(AAPL_2023,'#,###') AS AAPL_2023,
            FORMAT(AAPL_2022,'#,###') AS AAPL_2022,
            FORMAT(GOOGL_2024,'#,###') AS GOOGL_2024,
            FORMAT(GOOGL_2023,'#,###') AS GOOGL_2023,
            FORMAT(GOOGL_2022,'#,###') AS GOOGL_2022,
            FORMAT(AMZN_2024,'#,###') AS AMZN_2024,
            FORMAT(AMZN_2023,'#,###') AS AMZN_2023,
            FORMAT(AMZN_2022,'#,###') AS AMZN_2022,
            FORMAT(MSFT_2024,'#,###') AS MSFT_2024,
            FORMAT(MSFT_2023,'#,###') AS MSFT_2023,
            FORMAT(MSFT_2022,'#,###') AS MSFT_2022,
            FORMAT(META_2024,'#,###') AS META_2024,
            FORMAT(META_2023,'#,###') AS META_2023,
            FORMAT(META_2022,'#,###') AS META_2022,
            FORMAT(NFLX_2024,'#,###') AS NFLX_2024,
            FORMAT(NFLX_2023,'#,###') AS NFLX_2023,
            FORMAT(NFLX_2022,'#,###') AS NFLX_2022,
            FORMAT(NVDA_2024,'#,###') AS NVDA_2024,
            FORMAT(NVDA_2023,'#,###') AS NVDA_2023,
            FORMAT(NVDA_2022,'#,###') AS NVDA_2022
        FROM [bronze].[income_statement_2]
        SET @end_time = GETDATE();
        PRINT '>>Load duration' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)+ 'seconds'
        PRINT '>>--------------------------------------------------'

        PRINT '==================================================='
        PRINT 'Loading Income Statement to silver layer'
        PRINT '==================================================='

        -- Loading silver.income_statement
        SET @start_time = GETDATE();
        SELECT 
            UPPER(TRIM([Account_Description])) AS Account_Description,--Remove unwanted space & format number
            FORMAT(TSLA_2024,'#,###') AS TSLA_2024,
            FORMAT(TSLA_2023,'#,###') AS TSLA_2023,
            FORMAT(TSLA_2022,'#,###') AS TSLA_2022,
            FORMAT(AAPL_2024,'#,###') AS AAPL_2024,
            FORMAT(AAPL_2023,'#,###') AS AAPL_2023,
            FORMAT(AAPL_2022,'#,###') AS AAPL_2022,
            FORMAT(GOOGL_2024,'#,###') AS GOOGL_2024,
            FORMAT(GOOGL_2023,'#,###') AS GOOGL_2023,
            FORMAT(GOOGL_2022,'#,###') AS GOOGL_2022,
            FORMAT(AMZN_2024,'#,###') AS AMZN_2024,
            FORMAT(AMZN_2023,'#,###') AS AMZN_2023,
            FORMAT(AMZN_2022,'#,###') AS AMZN_2022,
            FORMAT(MSFT_2024,'#,###') AS MSFT_2024,
            FORMAT(MSFT_2023,'#,###') AS MSFT_2023,
            FORMAT(MSFT_2022,'#,###') AS MSFT_2022,
            FORMAT(META_2024,'#,###') AS META_2024,
            FORMAT(META_2023,'#,###') AS META_2023,
            FORMAT(META_2022,'#,###') AS META_2022,
            FORMAT(NFLX_2024,'#,###') AS NFLX_2024,
            FORMAT(NFLX_2023,'#,###') AS NFLX_2023,
            FORMAT(NFLX_2022,'#,###') AS NFLX_2022,
            FORMAT(NVDA_2024,'#,###') AS NVDA_2024,
            FORMAT(NVDA_2023,'#,###') AS NVDA_2023,
            FORMAT(NVDA_2022,'#,###') AS NVDA_2022
        FROM [bronze].[income_statement_2]
        SET @end_time = GETDATE();
        PRINT '>>Load duration' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + 'seconds'
        PRINT '>>--------------------------------------------------'
        SET @batch_end_time = GETDATE();
        PRINT '===================================================='
        PRINT 'Loading silver layer is completed';
        PRINT 'Total load duration: ' + CAST(DATEDIFF(SECOND,@batch_start_time,@batch_end_time) AS NVARCHAR) + 'seconds'
        PRINT '===================================================='
    END TRY
    BEGIN CATCH
        PRINT '===================================================='
        PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
        PRINT 'Error Message' + ERROR_MESSAGE();
        PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '===================================================='
    END CATCH
END

EXEC silver.load_silver
