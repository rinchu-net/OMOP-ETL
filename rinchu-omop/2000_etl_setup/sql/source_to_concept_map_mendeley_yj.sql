/*
============================================================
  Script Name : omop_source_to_concept_map_mendeley.sql
  Description : 愛媛大薬剤マッピングテーブル(Mendeley公開)をもとに、YJコードとRxNorm(Standard Concept)、
                のconcept_idに変換するsource_to_concept_mapを作成する

  構成概要：
  1. cte_00_MendeleyWithOtherTables
    -- mendeleyの薬剤マッピングテーブルの薬価収載医薬品コードとMEDIS HOTマスタを連結し、YJコードを導出
    -- マッピングテーブルのmm8w1cuiからmm8w5cuiと:working_schema.concept_fを連結し、一致するconcept_idを取得

  2. cte01_ranked
     - YJコードでユニークとなるように絞込みを行うための連番付与

  3. cte02_final
     - source_to_concept_map形式に整形

  出力：OMOP CDMのsource_to_concept_map形式に準拠したデータセット

============================================================
*/
CREATE OR REPLACE VIEW :working_schema.v_source_to_concept_map_drug_mendeley_yj AS
WITH

-- mendeleyの薬剤マッピングテーブルの薬価収載医薬品コードとMEDIS HOTマスタを連結し、YJコードを導出
-- マッピングテーブルのmm8w1cuiからmm8w5cuiと一致するconcept_idを取得
cte_00_MendeleyWithOtherTables AS(
SELECT
	m.category, m.nhidplc, m.ingredient, m.specification, m.japansedrugname, m.normalizedname, 1 as mm8swlevel, m.mm8w1str as mm8wstr, m.mm8w1cui as mm8wcul, m.mm8w1tty as mm8wtty,
	y.個別医薬品コード, y.販売名, y.包装単位単位, y.薬価基準収載医薬品コード, y.レセプト電算処理システム医薬品名, y.レセプト電算処理システムコード１,
	c.concept_id, c.concept_name, c.domain_id, c.vocabulary_id, c.concept_class_id, c.standard_concept, c.concept_code
FROM :source_schema.mst_mendeley m
LEFT OUTER JOIN :source_schema.mst_medis_hot13 y on m.nhidplc = y.薬価基準収載医薬品コード
LEFT OUTER JOIN :working_schema.concept_f c on TRIM(m.mm8w1cui) = CAST(c.concept_id as TEXT)
WHERE m.mm8w1str != 'N/A'
UNION
SELECT
	m.category, m.nhidplc, m.ingredient, m.specification, m.japansedrugname, m.normalizedname, 2 as mm8swlevel, m.mm8w2str as mm8wstr, m.mm8w2cui as mm8wcul, m.mm8w2tty as mm8wtty,
	y.個別医薬品コード, y.販売名, y.包装単位単位, y.薬価基準収載医薬品コード, y.レセプト電算処理システム医薬品名, y.レセプト電算処理システムコード１,
	c.concept_id, c.concept_name, c.domain_id, c.vocabulary_id, c.concept_class_id, c.standard_concept, c.concept_code
FROM :source_schema.mst_mendeley m
LEFT OUTER JOIN :source_schema.mst_medis_hot13 y on m.nhidplc = y.薬価基準収載医薬品コード
LEFT OUTER JOIN :working_schema.concept_f c on TRIM(m.mm8w2cui) = CAST(c.concept_id as TEXT)
WHERE m.mm8w2str != 'N/A'
UNION
SELECT
	m.category, m.nhidplc, m.ingredient, m.specification, m.japansedrugname, m.normalizedname, 3 as mm8swlevel, m.mm8w3str as mm8wstr, m.mm8w3cui as mm8wcul, m.mm8w3tty as mm8wtty,
	y.個別医薬品コード, y.販売名, y.包装単位単位, y.薬価基準収載医薬品コード, y.レセプト電算処理システム医薬品名, y.レセプト電算処理システムコード１,
	c.concept_id, c.concept_name, c.domain_id, c.vocabulary_id, c.concept_class_id, c.standard_concept, c.concept_code
FROM :source_schema.mst_mendeley m
LEFT OUTER JOIN :source_schema.mst_medis_hot13 y on m.nhidplc = y.薬価基準収載医薬品コード
LEFT OUTER JOIN :working_schema.concept_f c on TRIM(m.mm8w3cui) = CAST(c.concept_id as TEXT)
WHERE m.mm8w3str != 'N/A'
UNION
SELECT
	m.category, m.nhidplc, m.ingredient, m.specification, m.japansedrugname, m.normalizedname, 4 as mm8swlevel, m.mm8w4str as mm8wstr, m.mm8w4cui as mm8wcul, m.mm8w4tty as mm8wtty,
	y.個別医薬品コード, y.販売名, y.包装単位単位, y.薬価基準収載医薬品コード, y.レセプト電算処理システム医薬品名, y.レセプト電算処理システムコード１,
	c.concept_id, c.concept_name, c.domain_id, c.vocabulary_id, c.concept_class_id, c.standard_concept, c.concept_code
FROM :source_schema.mst_mendeley m
LEFT OUTER JOIN :source_schema.mst_medis_hot13 y on m.nhidplc = y.薬価基準収載医薬品コード
LEFT OUTER JOIN :working_schema.concept_f c on TRIM(m.mm8w4cui) = CAST(c.concept_id as TEXT)
WHERE m.mm8w4str != 'N/A'
UNION
SELECT
	m.category, m.nhidplc, m.ingredient, m.specification, m.japansedrugname, m.normalizedname, 5 as mm8swlevel, m.mm8w5str as mm8wstr, m.mm8w5cui as mm8wcul, m.mm8w5tty as mm8wtty,
	y.個別医薬品コード, y.販売名, y.包装単位単位, y.薬価基準収載医薬品コード, y.レセプト電算処理システム医薬品名, y.レセプト電算処理システムコード１,
	c.concept_id, c.concept_name, c.domain_id, c.vocabulary_id, c.concept_class_id, c.standard_concept, c.concept_code
FROM :source_schema.mst_mendeley m
LEFT OUTER JOIN :source_schema.mst_medis_hot13 y on m.nhidplc = y.薬価基準収載医薬品コード
LEFT OUTER JOIN :working_schema.concept_f c on TRIM(m.mm8w5cui) = CAST(c.concept_id as TEXT)
WHERE m.mm8w5str != 'N/A'
),

-- source_to_concept_map形式に編集
cte01_ranked AS(
    SELECT
        薬価基準収載医薬品コード as source_code_mendeley,
        mm8swlevel as mm8swlevel, 
        japansedrugname AS source_code_description_mendeley_jp,
        normalizedname AS source_code_description_mendeley_std,
        個別医薬品コード AS source_code,
        ROW_NUMBER() OVER (PARTITION BY 個別医薬品コード ORDER BY mm8swlevel ASC) AS rn,
        CAST('20' || SUBSTRING(レセプト電算処理システムコード１, 2, 8) AS INTEGER) AS source_concept_id,
        'MENDELEY_DRUGYJ' AS source_vocabulary_id,
        販売名 AS source_code_description,
        COALESCE(concept_id,0) AS target_concept_id,
        concept_name AS target_concept_name,
        domain_id AS target_domain_id,
        COALESCE(vocabulary_id,'')  AS target_vocabulary_id,
        TO_DATE('19000101','YYYYMMDD') AS valid_start_date,
        TO_DATE('20991231','YYYYMMDD') AS valid_end_date,
        '' AS invalid_reason
    FROM cte_00_MendeleyWithOtherTables
    WHERE 個別医薬品コード IS NOT NULL
    ORDER BY source_code, target_vocabulary_id, target_concept_id
),

cte02_final AS (
    SELECT
        source_code,
        source_concept_id,
        source_vocabulary_id,
        source_code_description,
        target_concept_id,
        target_vocabulary_id,
        valid_start_date,
        valid_end_date,
        invalid_reason
    FROM cte01_ranked
    WHERE rn = 1
)

SELECT * FROM cte02_final ORDER BY source_concept_id;

/* 中間CTEの確認
SELECT * FROM cte01_ranked order by source_code_mendeley,mm8swlevel,source_code;
*/

/* source_to_concept_mapへの登録
DELETE FROM :working_schema.source_to_concept_map_f  WHERE source_vocabulary_id = 'RINCHU_DRUG';
INSERT INTO :working_schema.source_to_concept_map_f  SELECT * FROM :working_schema.v_source_to_concept_map_drug_mendeley_yj ORDER BY source_code, target_vocabulary_id, target_concept_id;
SELECT * FROM :working_schema.source_to_concept_map_f  WHERE source_vocabulary_id = 'RINCHU_DRUG';
*/

/* Export
psql -U ユーザー名 -d データベース名 -c "\COPY (SELECT * FROM :working_schema.v_source_to_concept_map_drug_mendeley_yj) TO 'C:/Users/path/to/source_to_concept_map_MENDELEY_DRUG_YJ.csv' WITH CSV HEADER ENCODING 'UTF8'";
*/

/* domain_idを付加してSELECT
SELECT source_code, source_concept_id, source_vocabulary_id, source_code_description, target_concept_id, target_vocabulary_id, c.domain_id
FROM  :working_schema.v_source_to_concept_map_drug_mendeley
LEFT JOIN :working_schema.concept_f c ON target_concept_id = c.concept_id;
*/

