-- ============================================================================
-- mart_funnel_analysis.sql
-- Analyse de conversion par source et type pour Q1 2026
-- ============================================================================


CREATE VIEW mart_funnel_analysis

AS
WITH q1_2026_opportunities AS (
    SELECT 
        o.*,
        DATEDIFF(day, o.created_date, o.closed_date) AS sales_cycle_days
    FROM stg_opportunities o
    WHERE o.closed_date >= '2026-01-01' 
      AND o.closed_date <= '2026-03-31'
      AND o.status IN ('won', 'lost')
)
SELECT 
    q.source,
    q.type,
    
    -- === MÉTRIQUES DE VOLUME ===
    COUNT(DISTINCT q.opportunity_id) AS total_opportunities,
    COUNT(DISTINCT CASE WHEN q.status = 'won' THEN q.opportunity_id END) AS nb_won,
    COUNT(DISTINCT CASE WHEN q.status = 'lost' THEN q.opportunity_id END) AS nb_lost,
    
    -- === MÉTRIQUES DE CONVERSION ===
    CAST(COUNT(CASE WHEN q.status = 'won' THEN 1 END) AS FLOAT) / 
        NULLIF(COUNT(*), 0) * 100 AS win_rate_pct,
    
    -- === MÉTRIQUES DE VALEUR ===
    SUM(CASE WHEN q.status = 'won' THEN q.arr ELSE 0 END) AS total_arr_won,
    AVG(CASE WHEN q.status = 'won' THEN q.arr END) AS avg_deal_size,
    
    -- ARR total par opportunité (pour pondérer l'importance)
    SUM(CASE WHEN q.status = 'won' THEN q.arr ELSE 0 END) / 
        NULLIF(COUNT(DISTINCT q.opportunity_id), 0) AS arr_per_opportunity,
    
    -- === MÉTRIQUES DE VÉLOCITÉ ===
    AVG(CASE WHEN q.status = 'won' THEN q.sales_cycle_days END) AS avg_sales_cycle_won_days,
    
    -- === CONTRIBUTION AU TOTAL ===
    SUM(CASE WHEN q.status = 'won' THEN q.arr ELSE 0 END) / 
        (SELECT SUM(CASE WHEN status = 'won' THEN arr ELSE 0 END) FROM q1_2026_opportunities) * 100 
        AS pct_of_total_arr

FROM q1_2026_opportunities q

-- grouper par source et type
GROUP BY 
    q.source,
    q.type
;