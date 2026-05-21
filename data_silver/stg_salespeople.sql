DROP TABLE IF EXISTS stg_salespeople;

CREATE TABLE stg_salespeople AS 
SELECT
    TRIM(salesperson_id) AS salesperson_id,
    name,
    UPPER(TRIM(salesperson_office)) AS salesperson_office
FROM
    OPENROWSET(
        BULK 'https://devdataopsdatalake.dfs.core.windows.net/devdataopsdatalake/test/salespeople.csv',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
    HEADER_ROW = TRUE
    ) AS stg_salespeople
