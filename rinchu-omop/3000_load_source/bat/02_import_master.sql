\set ON_ERROR_STOP on
\echo ====================================
\echo ==== truncate table before load ====
\echo ====================================
\echo ==== TRUNCATE mst_medis_byomei ====
TRUNCATE TABLE "@schema"."mst_medis_byomei";
\echo ==== TRUNCATE mst_medis_hot13 ====
TRUNCATE TABLE "@schema"."mst_medis_hot13";
\echo ==== TRUNCATE mst_zipcode ====
TRUNCATE TABLE "@schema"."mst_zipcode";

\echo ====================================
\echo ==== execute data loading      =====
\echo ====================================
\echo ==== mst_medis_byomei ====
-- MEDISから取得したマスタデータをそのまま使用する場合
--\copy "@schema"."mst_medis_byomei" from '../mst/medis_byomei_nmain517.txt' csv ENCODING 'SJIS'
-- MEDISから取得したマスタデータに廃止済病名を補完するツールで生成したデータを使用する場合
\copy "@schema"."mst_medis_byomei" from '../mst/medis_byomei_nmain517_addhistory.csv' csv header ENCODING 'UTF8'
\echo ==== mst_medis_hot13 ====
\copy "@schema"."mst_medis_hot13" from '../mst/medis_iyakuhin_20250331_utf8.csv' csv header ENCODING 'UTF8'
\echo ==== mst_zipcode ====
\copy "@schema"."mst_zipcode" from '../mst/utf_ken_all.csv' csv ENCODING 'UTF8'
--\echo ==== mst_mendeley ====
--\copy "@schema"."mst_mendeley" from '../mst/rxnorm_mapping.tsv' csv DELIMITER E'\t' header ENCODING 'UTF8'

\echo ===================================
\echo ==== table records count       ====
\echo ===================================
SELECT '@schema.mst_medis_byomei' AS table, COUNT(*) AS count FROM "@schema"."mst_medis_byomei";
SELECT '@schema.mst_medis_hot13' AS table, COUNT(*) AS count FROM "@schema"."mst_medis_hot13";
SELECT '@schema.mst_zipcode' AS table, COUNT(*) AS count FROM "@schema"."mst_zipcode";
--SELECT '@schema.mst_mendeley' AS table, COUNT(*) AS count FROM "@schema"."mst_mendeley";