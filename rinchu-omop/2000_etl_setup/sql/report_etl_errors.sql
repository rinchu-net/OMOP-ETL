-----------------------------------------------
-- ETL実行結果集計
-- 全テーブルの件数と、error_field別エラー件数を集計
-----------------------------------------------
CREATE OR REPLACE VIEW :working_schema.v_report_etl_errors AS
WITH error_summary AS (
    -- person_e
    SELECT 
        'person_e_' AS table_name,
        error_field,
        COUNT(*) AS error_count
    FROM :working_schema.person_e
    WHERE error_field IS NOT NULL
    GROUP BY error_field
    
    UNION ALL
    
    -- death_e
    SELECT 
        'death_e_' AS table_name,
        error_field,
        COUNT(*) AS error_count
    FROM :working_schema.death_e
    WHERE error_field IS NOT NULL
    GROUP BY error_field
    
    UNION ALL
    
    -- visit_occurrence_e
    SELECT 
        'visit_occurrence_e_' AS table_name,
        error_field,
        COUNT(*) AS error_count
    FROM :working_schema.visit_occurrence_e
    WHERE error_field IS NOT NULL
    GROUP BY error_field
    
    UNION ALL
    
    -- condition_occurrence_e (error_field列を使用)
    SELECT 
        'condition_occurrence_e_' AS table_name,
        error_field AS error_field,
        COUNT(*) AS error_count
    FROM :working_schema.condition_occurrence_e
    WHERE error_field IS NOT NULL
    GROUP BY error_field
    
    UNION ALL
    
    -- drug_exposure_e (error_field列を使用)
    SELECT 
        'drug_exposure_e_' AS table_name,
        error_field AS error_field,
        COUNT(*) AS error_count
    FROM :working_schema.drug_exposure_e
    WHERE error_field IS NOT NULL
    GROUP BY error_field
    
    UNION ALL
    
    -- procedure_occurrence_e (error_field列を使用)
    SELECT 
        'procedure_occurrence_e_' AS table_name,
        error_field AS error_field,
        COUNT(*) AS error_count
    FROM :working_schema.procedure_occurrence_e
    WHERE error_field IS NOT NULL
    GROUP BY error_field
    
    UNION ALL
    
    -- measurement_e (error_field列を使用)
    SELECT 
        'measurement_e_' AS table_name,
        error_field AS error_field,
        COUNT(*) AS error_count
    FROM :working_schema.measurement_e
    WHERE error_field IS NOT NULL
    GROUP BY error_field
    
    UNION ALL
    
    -- observation_e (error_field列を使用)
    SELECT 
        'observation_e_' AS table_name,
        error_field AS error_field,
        COUNT(*) AS error_count
    FROM :working_schema.observation_e
    WHERE error_field IS NOT NULL
    GROUP BY error_field
    
    UNION ALL
    
    -- specimen_e (error_field列を使用)
    SELECT 
        'specimen_e_' AS table_name,
        error_field AS error_field,
        COUNT(*) AS error_count
    FROM :working_schema.specimen_e
    WHERE error_field IS NOT NULL
    GROUP BY error_field
),

table_totals AS (
    SELECT 'person' AS base_table, 
           (SELECT COUNT(*) FROM :working_schema.person_e) + (SELECT COUNT(*) FROM :working_schema.person_f) AS total_count
    UNION ALL
    SELECT 'death', 
           (SELECT COUNT(*) FROM :working_schema.death_e) + (SELECT COUNT(*) FROM :working_schema.death_f)
    UNION ALL
    SELECT 'visit_occurrence', 
           (SELECT COUNT(*) FROM :working_schema.visit_occurrence_e) + (SELECT COUNT(*) FROM :working_schema.visit_occurrence_f)
    UNION ALL
    SELECT 'condition_occurrence', 
           (SELECT COUNT(*) FROM :working_schema.condition_occurrence_e) + (SELECT COUNT(*) FROM :working_schema.condition_occurrence_f)
    UNION ALL
    SELECT 'drug_exposure', 
           (SELECT COUNT(*) FROM :working_schema.drug_exposure_e) + (SELECT COUNT(*) FROM :working_schema.drug_exposure_f)
    UNION ALL
    SELECT 'procedure_occurrence', 
           (SELECT COUNT(*) FROM :working_schema.procedure_occurrence_e) + (SELECT COUNT(*) FROM :working_schema.procedure_occurrence_f)
    UNION ALL
    SELECT 'measurement', 
           (SELECT COUNT(*) FROM :working_schema.measurement_e) + (SELECT COUNT(*) FROM :working_schema.measurement_f)
    UNION ALL
    SELECT 'observation', 
           (SELECT COUNT(*) FROM :working_schema.observation_e) + (SELECT COUNT(*) FROM :working_schema.observation_f)
    UNION ALL
    SELECT 'specimen', 
           (SELECT COUNT(*) FROM :working_schema.specimen_e) + (SELECT COUNT(*) FROM :working_schema.specimen_f)
)

-- 最終結果: テーブル名、総件数、エラーカラム名、エラー件数、エラー率を表示
SELECT 
    tt.base_table AS table_name,
    tt.total_count,
    COALESCE(es.error_field, '(No Errors)') AS error_field,
    COALESCE(es.error_count, 0) AS error_count,
    ROUND(100.0 * COALESCE(es.error_count, 0) / NULLIF(tt.total_count, 0), 2) AS error_percentage
FROM table_totals tt
LEFT JOIN error_summary es ON tt.base_table = REPLACE(es.table_name, '_e_', '')
ORDER BY tt.base_table, es.error_count DESC NULLS LAST;

