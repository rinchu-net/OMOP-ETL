\set ON_ERROR_STOP on
---------------------------------------------------------------------
-- ETL Step 02: v_stem -> stem_m への実体化
-- 目的: マッピングテーブル (STCM) 更新後に stem_m だけを再構築可能に
--       するため 01 から分離。03_mapping_checklist の入力として
--       stem_m が必要なため、03 の前に必ず本ステップを実行する。
---------------------------------------------------------------------

\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] materialize v_stem -> stem_m | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo TRUNCATE stem_m
TRUNCATE TABLE :working_schema.stem_m;
\echo INSERT INTO stem_m SELECT FROM v_stem
INSERT INTO :working_schema.stem_m SELECT * FROM :working_schema.v_stem;
\echo ANALYZE stem_m
ANALYZE VERBOSE :working_schema.stem_m;
DO $$ BEGIN RAISE NOTICE '[END] materialize v_stem -> stem_m | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================
