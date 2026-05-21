DROP TABLE IF EXISTS stg_accounts;

CREATE TABLE stg_accounts AS 
SELECT
    TRIM(account_id) AS account_id,
    UPPER(TRIM(account_office)) AS account_office,
    account_name
FROM
    OPENROWSET(
        BULK 'httpsdevdataopsdatalake.dfs.core.windows.netdevdataopsdatalaketestaccounts.csv',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE
    ) AS stg_accounts
