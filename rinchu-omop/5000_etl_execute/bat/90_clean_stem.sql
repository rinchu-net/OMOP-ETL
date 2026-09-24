-- ===============================================================
-- 90_clean_stem.sql
--   01_etl_execution_to_stem.sql + 02_etl_execution_stem_mapped.sql
--   の INSERT 対象テーブル を TRUNCATE する。
--   :working_schema は呼び出し側 (-v working_schema=...) で指定。
-- ===============================================================

\echo ==== TRUNCATE stem stage tables in :working_schema ====

-- 01_etl_execution_to_stem.sql の INSERT 対象
TRUNCATE TABLE :working_schema.person_s;
TRUNCATE TABLE :working_schema.person_m;
TRUNCATE TABLE :working_schema.person_f;
TRUNCATE TABLE :working_schema.person_e;

TRUNCATE TABLE :working_schema.visit_occurrence_s;
TRUNCATE TABLE :working_schema.visit_occurrence_m;
TRUNCATE TABLE :working_schema.visit_occurrence_f;
TRUNCATE TABLE :working_schema.visit_occurrence_e;

TRUNCATE TABLE :working_schema.visit_detail_f;

TRUNCATE TABLE :working_schema.death_s;
TRUNCATE TABLE :working_schema.death_m;
TRUNCATE TABLE :working_schema.death_f;
TRUNCATE TABLE :working_schema.death_e;

TRUNCATE TABLE :working_schema.stem_source;

-- 02_etl_execution_stem_mapped.sql の INSERT 対象
TRUNCATE TABLE :working_schema.stem_m;

\echo ==== Done ====
