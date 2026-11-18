@echo off
REM 環境変数一括設定ファイル

REM PostgreSQL接続情報
SET PGUSER=ohdsi_admin_user
SET PGPASSWORD=admin1
SET PGDATABASE=OHDSI
SET PGHOST=localhost
SET PGPORT=5432

REM データベース・スキーマ情報
SET SOURCE_SCHEMA=source
SET WORKING_SCHEMA=stage
SET PRODUCTION_SCHEMA=omop
SET ATLASRESULT_SCHEMA=result
SET TEMP_SCHEMA=temp

REM care_siteとcare_site_source_valueは、既定値9999999を医療機関番号7桁に変更して使用してください。
SET CARE_SITE_SOURCE_VALUE=9999999

REM POSTGRESQL UNLOGGEDテーブル設定[Y/N]
REM Yに設定するとテーブル作成後にUNLOGGED化してETL処理を高速化します。ただしクラッシュ時にデータが失われるデメリットがあります。
SET PGS_UNLOGGED=Y

REM ソースデータ取込方式[CSV/DB]
REM   CSV : 3000_load_source\dat に配置したCSVファイルを取り込みます（既定）。
REM   DB  : 臨中DBへpostgres_fdwで接続し、ソーステーブルを直接取り込みます。
REM         OMOP DBのサーバ（Docker利用時はomopdbコンテナ）から臨中DBへ接続できる必要があります。
SET SOURCE_LOAD_MODE=CSV

REM 臨中DB接続情報（SOURCE_LOAD_MODE=DB の場合のみ使用）
REM   RINCHU_HOST     : OMOP DBのサーバから見た臨中DBのホスト名またはIPアドレス
REM   RINCHU_SCHEMA   : 臨中DBでソーステーブル（PatientIdentification等）が格納されているスキーマ
REM   RINCHU_USER     : 臨中DBの読み取り専用ユーザを推奨（7テーブルへのSELECT権限のみ）
REM   RINCHU_PASSWORD : 「&」等の記号を含められるよう SET "変数=値" の形式で記述しています。
REM                     「%」「"」を含むパスワードはバッチで正しく扱えないため使用しないでください。
REM   RINCHU_SSLMODE  : 臨中DBへの接続のSSLモード（disable/prefer/require/verify-ca/verify-full）
REM   RINCHU_FETCH_SIZE : 臨中DBから1回に取得する行数。大きいほど高速ですがメモリを使用します。
SET RINCHU_HOST=localhost
SET RINCHU_PORT=5432
SET RINCHU_DB=rinchu
SET RINCHU_SCHEMA=source
SET RINCHU_USER=omop_reader
SET "RINCHU_PASSWORD=(your password here)"
SET RINCHU_SSLMODE=prefer
SET RINCHU_FETCH_SIZE=50000
