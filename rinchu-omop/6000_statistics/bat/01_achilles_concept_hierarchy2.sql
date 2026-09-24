\set ON_ERROR_STOP on
----------------------------------------------
-- OHDSI WebAPI互換性：achilles_analysisテーブル生成
-- 
-- ★ 背景・問題の説明 ★
-- 
-- OHDSI Achilles のバージョン進化による命名の変更：
-- 
--   Achilles v1.6以前：
--     - achilles_analysis テーブル：分析メタデータ定義テーブル
--     - achilles_performance テーブル：性能情報テーブル
-- 
--   Achilles v1.8以降（現在）：
--     - heracles_analysis テーブル：分析メタデータ定義テーブル（名前変更）
--     - achilles_performance：廃止
-- 
-- ★ 発生している問題 ★
-- 
-- 01_achilles_concept_hierarchy1.sql（OHDSI WebAPI DDL生成）は
-- 最新のAchilles v1.8仕様に従い heracles_analysis テーブルを作成しています。
-- 
-- しかし、WebAPI内部のSQLクエリの一部は古い仕様のまま
-- achilles_analysis テーブルを参照しており、テーブルが存在しない
-- ため "achilles_analysis not found" エラーが発生します。
-- 
-- WebAPIの完全なアップデートを待つ代わりに、ここでは後方互換性を
-- 確保する目的で、heracles_analysis から achilles_analysis への
-- テーブルエイリアスを実装しています。
-- 
-- ★ このスクリプトの役割 ★
-- 
-- heracles_analysisテーブルからachilles_analysisテーブルを生成することで、
-- WebAPIの古いコードとの互換性を維持します。
-- 
-- 目的：
--   - WebAPI内部の古いSQLクエリが achilles_analysis を参照可能にする
--   - 最新のAchilles v1.8実装と古いWebAPIコードの不一致を吸収
--   - ETL完了後、最新の分析メタデータを常にWebAPIで利用可能にする
--
-- 特徴：
--   - 繰り返し実行可能（冪等性あり）
--   - テーブルが存在しない場合は作成
--   - テーブルが存在する場合はTRUNCATE+INSERTで内容を更新
--   - heracles_analysisから最新データを常に同期
----------------------------------------------

-- achilles_analysis テーブルが存在しない場合は作成
CREATE TABLE IF NOT EXISTS :atlasresult_schema.achilles_analysis
 (analysis_id int,
	analysis_name varchar(255),
	stratum_1_name varchar(255),
	stratum_2_name varchar(255),
	stratum_3_name varchar(255),
	stratum_4_name varchar(255),
	stratum_5_name varchar(255),
	analysis_type varchar(255)
);

-- achilles_analysis テーブルの内容をリセット
TRUNCATE TABLE :atlasresult_schema.achilles_analysis;

-- heracles_analysis から achilles_analysis へデータを移行
INSERT INTO :atlasresult_schema.achilles_analysis
	(analysis_id, analysis_name, stratum_1_name, stratum_2_name, stratum_3_name, stratum_4_name, stratum_5_name, analysis_type)
SELECT
	analysis_id,
	analysis_name,
	stratum_1_name,
	stratum_2_name,
	stratum_3_name,
	stratum_4_name,
	stratum_5_name,
	analysis_type
FROM :atlasresult_schema.heracles_analysis;
