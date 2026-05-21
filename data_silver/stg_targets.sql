DROP TABLE IF EXISTS stg_targets;

CREATE TABLE stg_targets AS 
SELECT
    TRIM(salesperson_id) AS salesperson_id,
    UPPER(TRIM(account_office)) AS account_office,
    target_quarter,
    TRY_CAST(quarter_target AS DECIMAL(18,2)) AS quarter_target
FROM
    OPENROWSET(
        BULK '../devdataopsdatalake/test/targets.csv',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE
    ) AS stg_targets
WHERE quarter_target > 0;