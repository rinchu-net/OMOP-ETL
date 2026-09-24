@echo off
chcp 65001
REM RINCHUテーブルデータをCSVでエクスポート
REM 環境変数読み込み
CALL _env_source.bat

SET PGCLIENTENCODING=UTF8
SET PARAM=-U %PGUSER% -d %PGDATABASE%

REM タイムスタンプ取得（date/time環境変数を使用）
set YEAR=%date:~0,4%
set MONTH=%date:~5,2%
set DAY=%date:~8,2%
set HOUR=%time:~0,2%
set MINUTE=%time:~3,2%
set SECOND=%time:~6,2%
REM 時間の先頭スペースを0に置換
if "%HOUR:~0,1%"==" " set HOUR=0%HOUR:~1,1%
set LOGTS=%YEAR%%MONTH%%DAY%_%HOUR%%MINUTE%%SECOND%

SET TARGET=export_rinchu
if not exist log mkdir log
if not exist dat mkdir dat
set LOGFILE=log\%TARGET%_%LOGTS%.log
set SCHEMA=%SOURCE_SCHEMA%
set TEMPLATE=export_rinchu.sql
set SQL=export_rinchu_run.sql
powershell -Command "(Get-Content %TEMPLATE%) -replace '@schema', '%SCHEMA%' | Set-Content %SQL% -Encoding UTF8"
psql %PARAM% -f %SQL% >> %LOGFILE% 2>&1

REM 完了メッセージ
ECHO エクスポートが完了しました。
del export_rinchu_run.sql
