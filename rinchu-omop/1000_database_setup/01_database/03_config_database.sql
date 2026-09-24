-- ====================================================================
-- DB 単位スコープでの PostgreSQL 設定永続化
-- ====================================================================
--   目的: ETL 処理に最適化したパラメータを DB 単位で永続化する。
--         同 PG インスタンス上の他 DB (ATLAS / WebAPI 等) には影響を
--         与えない。
--
--   使い方:
--     psql -h <host> -p <port> -U <user> -d <dbname> \
--          -v DBNAME=<dbname> \
--          -f 03_config_database.sql
--
--     例:
--       psql -d OHDSI  -v DBNAME=OHDSI  -f 03_config_database.sql
--       psql -d omop-o -v DBNAME=omop-o -f 03_config_database.sql
--       psql -d omop-k -v DBNAME=omop-k -f 03_config_database.sql
--
--   反映タイミング: ALTER DATABASE は 新規セッション以降 に有効化。
--                   既存接続には反映されない。ETL は psql を毎回新規
--                   起動するため問題なし。
--
--   設定値の根拠: P000_PerformanceTuning/data/results_workmem_compare.csv
--     - work_mem = 256MB    : 4MB は NoSpace error / 3x 悪化、512MB は
--                             1.0-1.1x 逆効果。256MB が最適。
--     - hash_mem_multiplier = 2.0 : Hash 系のみ 512MB を許容。
--     - max_parallel_workers_per_gather = 4 : OHDSI/omop-o/omop-k 共通の
--                             既存 postgresql.conf 値。重 view の Parallel
--                             Seq Scan 4 worker 起動を保証。
--     - parallel_setup_cost = 100, parallel_tuple_cost = 0.01 :
--                             既存 postgresql.conf 値。並列計画を採用しや
--                             すくする。
--
--   解除方法: ALTER DATABASE :"DBNAME" RESET <parameter>;
-- ====================================================================

\set ON_ERROR_STOP on

\echo =====================================================================
\echo ==== ALTER DATABASE :"DBNAME" SET ... ====
\echo =====================================================================

ALTER DATABASE :"DBNAME" SET work_mem = '256MB';
ALTER DATABASE :"DBNAME" SET hash_mem_multiplier = 2.0;
ALTER DATABASE :"DBNAME" SET max_parallel_workers_per_gather = 4;
ALTER DATABASE :"DBNAME" SET parallel_setup_cost = 100;
ALTER DATABASE :"DBNAME" SET parallel_tuple_cost = 0.01;

-- 注: enable_nestloop を off にする運用は STEP 1.1 評価で「効果は誤差レベル
--      かつ環境依存」のため、本ファイルでは設定しない。必要に応じて個別に
--      追加すること。

\echo =====================================================================
\echo ==== 設定確認 (新規セッションで反映) ====
\echo =====================================================================

-- 既存セッションで設定値を確認するには、一度切断して再接続するか、psql の
-- メタコマンドで別のセッションを張る必要がある。下記は psql 実行直後の確認用。
-- (既存セッションには反映されないため "source" 列が default のままに見える点に注意)
SELECT name, setting, unit, source
FROM pg_settings
WHERE name IN (
    'work_mem',
    'hash_mem_multiplier',
    'max_parallel_workers_per_gather',
    'parallel_setup_cost',
    'parallel_tuple_cost'
)
ORDER BY name;

-- DB 単位で設定された値の一覧 (これは現セッションでも見える)
SELECT
    (SELECT datname FROM pg_database WHERE oid = s.setdatabase) AS database,
    unnest(s.setconfig) AS db_level_setting
FROM pg_db_role_setting s
WHERE s.setdatabase = (SELECT oid FROM pg_database WHERE datname = :'DBNAME')
ORDER BY db_level_setting;
