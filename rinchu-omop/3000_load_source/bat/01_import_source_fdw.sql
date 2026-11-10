\set ON_ERROR_STOP on
/*
============================================================
  Script Name : 01_import_source_fdw.sql
  Description : 臨中DBへpostgres_fdwで接続し、ソーステーブルを
                OMOP DBのソーススキーマへ取り込む

  構成概要：
    1. 外部サーバ定義
    - 外部テーブル用スキーマ(rinchu_fdw)と外部サーバ(rinchu_srv)を毎回作り直す
      （_env.batの接続情報の変更を確実に反映するため）
    - 臨中DBの7テーブルを外部テーブルとしてIMPORT FOREIGN SCHEMAで取り込む

    2. 事前検証（ソーステーブルを変更する前に実施）
    - 臨中DBに7テーブルが存在すること
    - ソーススキーマのテーブルの全カラムが、臨中DB側に同名で存在すること
      （臨中DB側にのみ存在するカラムはWARNINGを出力して取り込み対象外とする）

    3. データ取込
    - カラム名を明示してINSERT ... SELECTで取り込む（カラム順の違いは問題にならない）
    - 2と3は1つのトランザクションで実行するため、途中で失敗した場合は
      ソーステーブルは取込前の状態のまま残る

  入力(psql変数)：
    source_schema, rinchu_host, rinchu_port, rinchu_db, rinchu_schema,
    rinchu_user, rinchu_password, rinchu_sslmode, rinchu_fetch_size

  前提：
    - 実行ユーザはスーパーユーザ（CREATE EXTENSIONのため）
    - OMOP DBのサーバから臨中DBへネットワーク接続できること
============================================================
*/

\set fdw_schema rinchu_fdw

\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] create foreign server | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo ==== create foreign server to RINCHU database ====
DROP SERVER IF EXISTS rinchu_srv CASCADE;
DROP SCHEMA IF EXISTS :"fdw_schema" CASCADE;
CREATE SCHEMA :"fdw_schema";
CREATE EXTENSION IF NOT EXISTS postgres_fdw WITH SCHEMA :"fdw_schema";

CREATE SERVER rinchu_srv
    FOREIGN DATA WRAPPER postgres_fdw
    OPTIONS (
        host :'rinchu_host',
        port :'rinchu_port',
        dbname :'rinchu_db',
        sslmode :'rinchu_sslmode',
        fetch_size :'rinchu_fetch_size',
        application_name 'rinchu-omop-etl'
    );

CREATE USER MAPPING FOR CURRENT_USER
    SERVER rinchu_srv
    OPTIONS (user :'rinchu_user', password :'rinchu_password');

\echo ==== import foreign tables (connects to RINCHU database) ====
IMPORT FOREIGN SCHEMA :"rinchu_schema"
    LIMIT TO (
        patientidentification,
        patientaddress,
        patientvisit,
        patientdisease,
        observationresult,
        prescriptiondata,
        injectiondata
    )
    FROM SERVER rinchu_srv
    INTO :"fdw_schema";
DO $$ BEGIN RAISE NOTICE '[END] create foreign server | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

-- DOブロック内ではpsql変数を参照できないため、セッション設定経由で渡す
SELECT set_config('rinchu.source_schema', :'source_schema', false) AS source_schema,
       set_config('rinchu.fdw_schema', :'fdw_schema', false) AS fdw_schema;

\echo =====================================================================
\echo ==== validate and load source tables ====
DO $$
DECLARE
    v_src     text := current_setting('rinchu.source_schema');
    v_fdw     text := current_setting('rinchu.fdw_schema');
    v_tables  text[] := ARRAY[
        'patientidentification',
        'patientaddress',
        'patientvisit',
        'patientdisease',
        'observationresult',
        'prescriptiondata',
        'injectiondata'
    ];
    v_t       text;
    v_missing text;
    v_extra   text;
    v_cols    text;
    v_rows    bigint;
    v_errors  text := '';
BEGIN
    ------------------------------------------------------------
    -- 1. 事前検証
    ------------------------------------------------------------
    FOREACH v_t IN ARRAY v_tables LOOP
        IF to_regclass(format('%I.%I', v_src, v_t)) IS NULL THEN
            v_errors := v_errors || format(E'\n  - OMOP DBのソーステーブルが存在しません: %I.%I', v_src, v_t);
            CONTINUE;
        END IF;
        IF to_regclass(format('%I.%I', v_fdw, v_t)) IS NULL THEN
            v_errors := v_errors || format(E'\n  - 臨中DBにテーブルが存在しません: %s', v_t);
            CONTINUE;
        END IF;

        SELECT string_agg(l.column_name::text, ', ' ORDER BY l.ordinal_position)
          INTO v_missing
          FROM information_schema.columns l
         WHERE l.table_schema = v_src
           AND l.table_name = v_t
           AND NOT EXISTS (
                SELECT 1 FROM information_schema.columns r
                 WHERE r.table_schema = v_fdw
                   AND r.table_name = v_t
                   AND r.column_name = l.column_name);
        IF v_missing IS NOT NULL THEN
            v_errors := v_errors || format(E'\n  - %s: 臨中DB側に存在しないカラム: %s', v_t, v_missing);
        END IF;

        SELECT string_agg(r.column_name::text, ', ' ORDER BY r.ordinal_position)
          INTO v_extra
          FROM information_schema.columns r
         WHERE r.table_schema = v_fdw
           AND r.table_name = v_t
           AND NOT EXISTS (
                SELECT 1 FROM information_schema.columns l
                 WHERE l.table_schema = v_src
                   AND l.table_name = v_t
                   AND l.column_name = r.column_name);
        IF v_extra IS NOT NULL THEN
            RAISE WARNING '%: 臨中DB側にのみ存在するカラムは取り込みません: %', v_t, v_extra;
        END IF;
    END LOOP;

    IF v_errors <> '' THEN
        RAISE EXCEPTION '臨中DBとOMOP DBのソーステーブル定義が一致しないため、取込を中止しました。%', v_errors;
    END IF;

    ------------------------------------------------------------
    -- 2. データ取込
    ------------------------------------------------------------
    FOREACH v_t IN ARRAY v_tables LOOP
        RAISE NOTICE '[START] loading % | %', v_t, clock_timestamp() AT TIME ZONE 'Asia/Tokyo';

        SELECT string_agg(quote_ident(column_name::text), ', ' ORDER BY ordinal_position)
          INTO v_cols
          FROM information_schema.columns
         WHERE table_schema = v_src
           AND table_name = v_t;

        EXECUTE format('TRUNCATE TABLE %I.%I', v_src, v_t);
        EXECUTE format('INSERT INTO %I.%I (%s) SELECT %s FROM %I.%I',
                       v_src, v_t, v_cols, v_cols, v_fdw, v_t);
        GET DIAGNOSTICS v_rows = ROW_COUNT;

        RAISE NOTICE '[END] loading % : % rows | %', v_t, v_rows, clock_timestamp() AT TIME ZONE 'Asia/Tokyo';
    END LOOP;
END $$;
\echo =====================================================================

\echo ==== analyze source tables ====
ANALYZE :"source_schema".patientidentification;
ANALYZE :"source_schema".patientaddress;
ANALYZE :"source_schema".patientvisit;
ANALYZE :"source_schema".patientdisease;
ANALYZE :"source_schema".observationresult;
ANALYZE :"source_schema".prescriptiondata;
ANALYZE :"source_schema".injectiondata;
