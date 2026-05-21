-- ============================================================================
-- mart_sales_performance_by_office.sql
-- Performance agrégée par bureau pour Q1 2026
-- ============================================================================

CREATE VIEW mart_sales_performance_by_office

AS
WITH q1_2026_opportunities AS (
    SELECT 
        o.*,
        s.salesperson_office,
        a.account_office,
        DATEDIFF(day, o.created_date, o.closed_date) AS sales_cycle_days
    FROM stg_opportunities o
    LEFT JOIN stg_salespeople s ON o.salesperson_id = s.salesperson_id
    LEFT JOIN stg_accounts a ON o.account_id = a.account_id
    WHERE o.closed_date >= '2026-01-01' 
      AND o.closed_date <= '2026-03-31'
      AND o.status IN ('won', 'lost')
)
SELECT 
    q.account_office,
    
    -- === OBJECTIFS AGRÉGÉS ===
    SUM(t.quarter_target) AS total_target_office,
    COUNT(DISTINCT t.salesperson_id) AS nb_salespeople,
    
    -- === MÉTRIQUES DE VOLUME ===
    COUNT(DISTINCT q.opportunity_id) AS total_opportunities_closed,
    COUNT(DISTINCT CASE WHEN q.status = 'won' THEN q.opportunity_id END) AS nb_deals_won,
    
    -- === MÉTRIQUES DE VALEUR ===
    SUM(CASE WHEN q.status = 'won' THEN q.arr ELSE 0 END) AS total_arr_won,
    AVG(CASE WHEN q.status = 'won' THEN q.arr END) AS avg_deal_size,
    
    -- === PERFORMANCE VS OBJECTIF ===
    CASE 
        WHEN SUM(t.quarter_target) > 0 
        THEN (SUM(CASE WHEN q.status = 'won' THEN q.arr ELSE 0 END) / SUM(t.quarter_target)) * 100 
        ELSE NULL 
    END AS quota_attainment_pct,
    
    SUM(CASE WHEN q.status = 'won' THEN q.arr ELSE 0 END) - COALESCE(SUM(t.quarter_target), 0) AS gap_vs_target,
    
    -- === MÉTRIQUES DE CONVERSION ===
    CAST(COUNT(CASE WHEN q.status = 'won' THEN 1 END) AS FLOAT) / 
        NULLIF(COUNT(*), 0) * 100 AS win_rate_pct,
    
    -- === MÉTRIQUES PAR SALES ===
    SUM(CASE WHEN q.status = 'won' THEN q.arr ELSE 0 END) / 
        NULLIF(COUNT(DISTINCT t.salesperson_id), 0) AS arr_per_salesperson,
    
    COUNT(DISTINCT q.opportunity_id) / 
        NULLIF(COUNT(DISTINCT t.salesperson_id), 0) AS opps_per_salesperson

FROM q1_2026_opportunities q
LEFT JOIN stg_targets t 
    ON q.account_office = t.account_office

-- grouper par office
GROUP BY q.account_office;