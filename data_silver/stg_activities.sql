DROP TABLE IF EXISTS stg_activities;

CREATE TABLE stg_activities AS 
SELECT
    TRIM(activity_id) AS activity_id,
    TRIM(opportunity_id) AS opportunity_id,
    LOWER(TRIM(activity_type)) AS activity_type,
    CASE
        WHEN activity_date LIKE '%-%' 
            THEN TRY_CAST(activity_date AS DATE)
        WHEN activity_date LIKE '%/%' 
            THEN TRY_CAST(
                SUBSTRING(activity_date, 7, 4) + '-' +
                SUBSTRING(activity_date, 4, 2) + '-' +
                SUBSTRING(activity_date, 1, 2)
                AS DATE
            )
        ELSE TRY_CAST(activity_date AS DATE)
    END AS activity_date
FROM
    OPENROWSET(
        BULK 'https://devdataopsdatalake.dfs.core.windows.net/devdataopsdatalake/test/activities.csv',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE
    ) AS stg_activities
