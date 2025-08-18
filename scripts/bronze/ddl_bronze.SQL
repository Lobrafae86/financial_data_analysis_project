CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    PRINT '===================================='
    PRINT 'Loading stock market price 2'
    PRINT '====================================='
    --Select only years 2024 to 2022
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
    --Create new table to proceed unpivot 
    INTO 
        bronze.stock_market_prices_2
    FROM bronze.stock_market_prices
    WHERE 
        CAST(DATE as Date) BETWEEN '2022-01-01' AND '2024-12-31'
    PRINT '====================================================='
    PRINT 'Load Income Statement'
    PRINT '====================================================='
    --Select only years 2024, 2023, and 2022.
    SELECT 
        column1 as Account_Description,
        column2 as TSLA_2024,
        column3 as TSLA_2023,
        column4 as TSLA_2022,
        column7 as AAPL_2024,
        column8 as AAPL_2023,
        column9 as AAPL_2022,
        column12 as GOOGL_2024,
        column13 as GOOGL_2023,
        column14 as GOOGL_2022,
        column16 as AMZN_2024,
        column17 AS AMZN_2023,
        column18 AS AMZN_2022,
        column22 AS MSFT_2024,
        column23 AS MSFT_2023,
        column24 AS MSFT_2022,
        column25 AS META_2024,
        column26 AS META_2023,
        column27 AS META_2022,
        column30 AS NFLX_2024,
        column31 AS NFLX_2023,
        column32 AS NFLX_2022,
        column35 AS NVDA_2024,
        column36 AS NVDA_2023,
        column37 AS NVDA_2022
    --Create new table to proceed unpivot 
    INTO 
        bronze.income_statement_2
    FROM bronze.income_statement
    --Select only account key needed
    WHERE 
        column1 IN (
            'Total Revenue',
            'Cost Of Revenue',
            'Gross Profit',
            'Operating Income',
            'Total Expenses',
            'Net Interest Income',
            'Pretax Income'
        )
    PRINT '======================================='
    PRINT 'Load Balance Sheet'
    PRINT '======================================='
    --Select only years 2024, 2023, and 2022.
        SELECT 
            column1 as Account_Description,
            column2 as TSLA_2024,
            column3 as TSLA_2023,
            column4 as TSLA_2022,
            column7 as AAPL_2024,
            column8 as AAPL_2023,
            column9 as AAPL_2022,
            column12 as GOOGL_2024,
            column13 as GOOGL_2023,
            column14 as GOOGL_2022,
            column17 AS AMZN_2024,
            column18 AS AMZN_2023,
            column19 AS AMZN_2022,
            column23 AS MSFT_2024,
            column24 AS MSFT_2023,
            column25 AS MSFT_2022,
            column27 AS META_2024,
            column28 AS META_2023,
            column29 AS META_2022,
            column32 AS NFLX_2024,
            column33 AS NFLX_2023,
            column34 AS NFLX_2022,
            column38 AS NVDA_2024,
            column39 AS NVDA_2023,
            column40 AS NVDA_2022
        --Create new table to proceed unpivot 
        INTO 
            bronze.balance_sheets_2
        FROM bronze.balance_sheets
        --Select only account key needed
        WHERE column1 IN (
            'Current Assets',
            'Gross PPE',
            'Net PPE',
            'Total Assets',
            'Current Liabilities',
            'Total Debt',
            'Total Capitalization')
END
