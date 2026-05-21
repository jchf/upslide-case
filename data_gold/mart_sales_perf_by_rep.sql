-- ============================================================================
-- mart_sales_performance_by_rep.sql
-- Performance commerciale détaillée par sales rep pour Q1 2026
-- ============================================================================

CREATE TABLE mart_sales_performance_by_rep

AS
WITH q1_2026_opportunities AS (
    -- Opportunités closes en Q1 2026
    SELECT 
        o.*,
        s.name AS salesperson_name,
        s.salesperson_office,
        a.account_office,
        DATEDIFF(day, o.created_date, o.closed_date) AS sales_cycle_days
    FROM stg_opportunities o
    LEFT JOIN stg_salespeople s ON o.salesperson_id = s.salesperson_id
    LEFT JOIN stg_accounts a ON o.account_id = a.account_id
    WHERE o.closed_date >= '2026-01-01' 
      AND o.closed_date <= '2026-03-31'
      AND o.status IN ('won', 'lost')
),
activities_summary AS (
    -- Résumé des activités par opportunité
    SELECT 
        opportunity_id,
        COUNT(*) AS total_activities,
        SUM(CASE WHEN activity_type = 'call' THEN 1 ELSE 0 END) AS nb_calls,
        SUM(CASE WHEN activity_type = 'meeting_online' THEN 1 ELSE 0 END) AS nb_meetings_online,
        SUM(CASE WHEN activity_type = 'meeting_f2f' THEN 1 ELSE 0 END) AS nb_meetings_f2f,
        SUM(CASE WHEN activity_type = 'linkedin' THEN 1 ELSE 0 END) AS nb_linkedin
    FROM stg_activities
    GROUP BY opportunity_id
)
SELECT 
    q.salesperson_id,
    q.salesperson_name,
    q.salesperson_office,
    
    -- === OBJECTIFS ===
    MAX(t.quarter_target) AS quarter_target,
    
    -- === MÉTRIQUES DE VOLUME ===
    COUNT(DISTINCT q.opportunity_id) AS total_opportunities_closed,
    COUNT(DISTINCT CASE WHEN q.status = 'won' THEN q.opportunity_id END) AS nb_deals_won,
    COUNT(DISTINCT CASE WHEN q.status = 'lost' THEN q.opportunity_id END) AS nb_deals_lost,
    
    -- Ventilation par type
    COUNT(DISTINCT CASE WHEN q.status = 'won' AND q.type = 'new business' THEN q.opportunity_id END) AS nb_new_business_won,
    COUNT(DISTINCT CASE WHEN q.status = 'won' AND q.type = 'upsell' THEN q.opportunity_id END) AS nb_upsell_won,
    
    -- === MÉTRIQUES DE VALEUR (ARR) ===
    SUM(CASE WHEN q.status = 'won' THEN q.arr ELSE 0 END) AS total_arr_won,
    SUM(CASE WHEN q.status = 'won' AND q.type = 'new business' THEN q.arr ELSE 0 END) AS arr_new_business,
    SUM(CASE WHEN q.status = 'won' AND q.type = 'upsell' THEN q.arr ELSE 0 END) AS arr_upsell,
    AVG(CASE WHEN q.status = 'won' THEN q.arr END) AS avg_deal_size,
    
    -- === PERFORMANCE VS OBJECTIF ===
    CASE 
        WHEN MAX(t.quarter_target) > 0 
        THEN (SUM(CASE WHEN q.status = 'won' THEN q.arr ELSE 0 END) / MAX(t.quarter_target)) * 100 
        ELSE NULL 
    END AS quota_attainment_pct,
    
    SUM(CASE WHEN q.status = 'won' THEN q.arr ELSE 0 END) - COALESCE(MAX(t.quarter_target), 0) AS gap_vs_target,
    
    -- Flag sous-performance
    CASE 
        WHEN SUM(CASE WHEN q.status = 'won' THEN q.arr ELSE 0 END) < COALESCE(MAX(t.quarter_target), 0)
        THEN 1 ELSE 0 
    END AS is_underperforming,
    
    -- === MÉTRIQUES DE CONVERSION ===
    CAST(COUNT(CASE WHEN q.status = 'won' THEN 1 END) AS FLOAT) / 
        NULLIF(COUNT(*), 0) * 100 AS win_rate_pct,
    
    -- Win rate par type
    CAST(COUNT(CASE WHEN q.status = 'won' AND q.type = 'new business' THEN 1 END) AS FLOAT) / 
        NULLIF(COUNT(CASE WHEN q.type = 'new business' THEN 1 END), 0) * 100 AS win_rate_new_business_pct,
    
    CAST(COUNT(CASE WHEN q.status = 'won' AND q.type = 'upsell' THEN 1 END) AS FLOAT) / 
        NULLIF(COUNT(CASE WHEN q.type = 'upsell' THEN 1 END), 0) * 100 AS win_rate_upsell_pct,
    
    -- === MÉTRIQUES DE VÉLOCITÉ ===
    AVG(CASE WHEN q.status = 'won' THEN q.sales_cycle_days END) AS avg_sales_cycle_won_days,
    AVG(CASE WHEN q.status = 'lost' THEN q.sales_cycle_days END) AS avg_sales_cycle_lost_days,
    
    -- === MÉTRIQUES D'ACTIVITÉ ===
    AVG(COALESCE(act.total_activities, 0)) AS avg_activities_per_opp,
    AVG(CASE WHEN q.status = 'won' THEN COALESCE(act.total_activities, 0) END) AS avg_activities_per_won_deal,
    AVG(CASE WHEN q.status = 'lost' THEN COALESCE(act.total_activities, 0) END) AS avg_activities_per_lost_deal,
    
    -- Mix d'activités
    SUM(COALESCE(act.nb_calls, 0)) AS total_calls,
    SUM(COALESCE(act.nb_meetings_online, 0)) AS total_meetings_online,
    SUM(COALESCE(act.nb_meetings_f2f, 0)) AS total_meetings_f2f

FROM q1_2026_opportunities q
LEFT JOIN stg_targets t 
    ON q.salesperson_id = t.salesperson_id 
    AND q.account_office = t.account_office  -- Match sur le bon office
LEFT JOIN activities_summary act 
    ON q.opportunity_id = act.opportunity_id

-- Grouper par commercial
GROUP BY 
    q.salesperson_id,
    q.salesperson_name,
    q.salesperson_office