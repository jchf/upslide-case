DROP TABLE IF EXISTS stg_opportunities;

CREATE TABLE stg_opportunities AS 
    
SELECT
    TRIM(opportunity_id) AS opportunity_id,
    
    -- Normalisation created_date
    CASE
        -- Format YYYY-MM-DD (contient '-')
        WHEN created_date LIKE '%-%' 
            THEN TRY_CAST(created_date AS DATE)
        
        -- Format DD/MM/YYYY (contient '/')
        WHEN created_date LIKE '%/%' 
            THEN TRY_CAST(
                SUBSTRING(created_date, 7, 4) + '-' +  -- Année
                SUBSTRING(created_date, 4, 2) + '-' +  -- Mois
                SUBSTRING(created_date, 1, 2)          -- Jour
                AS DATE
            )
        
        -- Autre format : tentative de parsing automatique
        ELSE TRY_CAST(created_date AS DATE)
    END AS created_date,
    
    -- Normalisation closed_date (même logique)
    CASE
        WHEN closed_date LIKE '%-%' 
            THEN TRY_CAST(closed_date AS DATE)
        WHEN closed_date LIKE '%/%' 
            THEN TRY_CAST(
                SUBSTRING(closed_date, 7, 4) + '-' +
                SUBSTRING(closed_date, 4, 2) + '-' +
                SUBSTRING(closed_date, 1, 2)
                AS DATE
            )
        ELSE TRY_CAST(closed_date AS DATE)
    END AS closed_date,
    
    -- Autres colonnes inchangées
    arr,
    LOWER(status) AS status,
    TRIM(salesperson_id) AS salesperson_id,
    LOWER(source) AS source,
    LOWER(type) AS type,
    TRIM(account_id) AS account_id,
    
    -- Colonnes de contrôle qualité (optionnel mais utile pour le rendu)
    created_date AS created_date_raw,  -- Garder la valeur originale pour audit
    closed_date AS closed_date_raw
FROM
    OPENROWSET(
        BULK '../devdataopsdatalake/test/opportunities.csv',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE
    ) AS stg_opportunities
