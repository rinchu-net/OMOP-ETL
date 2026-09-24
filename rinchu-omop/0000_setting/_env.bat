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
