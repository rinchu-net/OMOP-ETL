/*
============================================================
  Script Name : v_source_to_concept_map_athena_icd10_medisextention.sql
  Description : MEDIS病名マスタのICD10コードのうち、ATHENAのICD10に存在しないコードを
                Standard Conceptのconcept_idに変換するsource_to_concept_mapを作成する

  構成概要：
  1. cte_medis_icd10_1
     - MEDIS病名マスタから抽出したICD10コード
  
  2. cte_medis_icd10_2
     - ICD10コードを標準形式に変換（Xnnn → Xnn.n形式）
  
  3. cte_medis_icd10_3
     - 4〜5桁コードから3桁の上位階層コード（Xnn.n）を生成
  
  4. cte_medis_icd10_combined_source
     - ICD10に存在しないが、ICD10CMまたはICD10上位階層に存在するコードを抽出
  
  5. cte_00_icd10_to_standard
     - Concept Relationshipを使用して、補完コードとStandard Conceptとの対応表を作成
  
  6. cte_final
     - source_to_concept_map形式に整形

  出力：OMOP CDMのsource_to_concept_map形式に準拠したデータセット
============================================================
*/
CREATE OR REPLACE VIEW :working_schema.v_source_to_concept_map_athena_icd10_medisextention AS
WITH

-- MEDIS病名マスタからICD10コードを抽出する
cte_medis_icd10_1 AS (
    SELECT DISTINCT icd10_2013 AS icd10
    FROM :source_schema.mst_medis_byomei
    WHERE icd10_2013 IS NOT NULL AND icd10_2013 != ''
    UNION
    SELECT DISTINCT icd10_2013_sub AS icd10
    FROM :source_schema.mst_medis_byomei
    WHERE icd10_2013_sub IS NOT NULL AND icd10_2013_sub != ''
),

-- XnnnやXnn-nの形式をXnn.nの標準形式に変換する
cte_medis_icd10_2 AS (
    SELECT 
        icd10 AS icd10_org,
        CASE
            WHEN LENGTH(icd10_normalized) <= 3 THEN icd10_normalized
            WHEN icd10_normalized LIKE '%.%' THEN icd10_normalized
            ELSE LEFT(icd10_normalized, 3) || '.' || RIGHT(icd10_normalized, LENGTH(icd10_normalized) - 3)
        END AS icd10_formatted
    FROM (
        SELECT 
            icd10,
            REPLACE(icd10, '-', '.') AS icd10_normalized
        FROM cte_medis_icd10_1
    ) sub
),

-- Xnn.nnののコードの場合、Xnn.nのコードも生成する
cte_medis_icd10_3 AS (
    SELECT 
        icd10_org,
        icd10_formatted,
        CASE
            WHEN LENGTH(icd10_formatted) >= 6 THEN LEFT(icd10_formatted, 5)
            ELSE icd10_formatted
        END AS icd10_upperlevel
    FROM cte_medis_icd10_2
),

-- ICD10には存在せずICD10CMにのみ存在するコード、または
-- ICD10ににもICD10CMにも存在せず、icd10_upperlevelがICD10に存在するコードを抽出する
cte_medis_icd10_combined_source AS (
    -- パターン1: ICD10に存在せず、ICD10CMに存在するコード
    SELECT 
        c3.icd10_org,
        c3.icd10_formatted,
        cf.concept_id,
        cf.concept_name,
        cf.vocabulary_id,
        cf.domain_id,
        cf.concept_class_id,
        cf.concept_code,
        cf.standard_concept,
        cf.valid_start_date,
        cf.valid_end_date,
        cf.invalid_reason
    FROM cte_medis_icd10_3 c3
    JOIN :working_schema.concept_f cf ON c3.icd10_formatted = cf.concept_code
    WHERE cf.vocabulary_id = 'ICD10CM'
        AND NOT EXISTS (
            SELECT 1
            FROM :working_schema.concept_f cf_icd10
            WHERE cf_icd10.concept_code = c3.icd10_formatted
            AND cf_icd10.vocabulary_id = 'ICD10'
        )
    
    UNION
    
    -- パターン2: icd10_formattedがICD10とICD10CMに存在せず、icd10_upperlevelがICD10に存在するコード
    SELECT 
        c3.icd10_org,
        c3.icd10_formatted,
        cf.concept_id,
        cf.concept_name,
        cf.vocabulary_id,
        cf.domain_id,
        cf.concept_class_id,
        cf.concept_code,
        cf.standard_concept,
        cf.valid_start_date,
        cf.valid_end_date,
        cf.invalid_reason
    FROM cte_medis_icd10_3 c3
    JOIN :working_schema.concept_f cf ON c3.icd10_upperlevel = cf.concept_code
    WHERE cf.vocabulary_id = 'ICD10'
        AND NOT EXISTS (
            SELECT 1
            FROM :working_schema.concept_f cf_icd10cm
            WHERE cf_icd10cm.concept_code = c3.icd10_formatted
            AND cf_icd10cm.vocabulary_id = 'ICD10CM'
        )
        AND NOT EXISTS (
            SELECT 1
            FROM :working_schema.concept_f cf_icd10
            WHERE cf_icd10.concept_code = c3.icd10_formatted
            AND cf_icd10.vocabulary_id = 'ICD10'
        )
),

-- conceptとconcept_relationshipを使用してstandard conceptとの対応表を作成する
cte_icd10_to_standard AS(
SELECT
    cr.concept_id_1,
    c1.concept_name AS concept_name_1,
    c1.vocabulary_id AS vocabulary_id_1,
    c1.domain_id AS domain_id_1,
    c1.concept_class_id AS concept_class_id_1,
    comb.icd10_formatted AS concept_code_1,
    cr.relationship_id, 
    cr.concept_id_2,
    c2.concept_name AS concept_name_2,
    c2.vocabulary_id AS vocabulary_id_2,
    c2.domain_id AS domain_id_2,
    c2.concept_class_id AS concept_class_id_2,
    c2.concept_code AS concept_code_2,
    c2.valid_start_date AS valid_start_date_2,
    c2.valid_end_date AS valid_end_date_2,
    c2.invalid_reason AS invalid_reason_2
FROM cte_medis_icd10_combined_source comb
JOIN :working_schema.concept_relationship_f cr ON comb.concept_id = cr.concept_id_1
JOIN :working_schema.concept_f c1 ON cr.concept_id_1 = c1.concept_id
JOIN :working_schema.concept_f c2 ON cr.concept_id_2 = c2.concept_id
WHERE c2.standard_concept = 'S'
),

cte_final AS(
	SELECT
        concept_code_1 AS source_code,
        concept_id_1 AS source_concept_id,
        CASE
            WHEN relationship_id ='Maps to value' THEN 'ATHENA_ICD10_VALUE'
            ELSE 'ATHENA_ICD10'
        END AS source_vocabulary_id,
        concept_name_1 AS source_code_description,
        COALESCE(concept_id_2,0) AS target_concept_id,
		COALESCE(vocabulary_id_2,'')  AS target_vocabulary_id,
        COALESCE(valid_start_date_2, TO_DATE('19700101','YYYYMMDD')) AS valid_start_date,
        COALESCE(valid_end_date_2, TO_DATE('20991231','YYYYMMDD')) AS valid_end_date,
		invalid_reason_2 AS invalid_reason
	FROM cte_icd10_to_standard
)

SELECT * FROM cte_final ORDER BY source_code, source_vocabulary_id, target_concept_id;



/* source_to_concept_mapへの登録
DELETE FROM :working_schema.source_to_concept_map_f WHERE source_vocabulary_id = 'ICD10';
INSERT INTO :working_schema.source_to_concept_map_f SELECT * FROM :working_schema.v_source_to_concept_map_athena_icd10_medisextention;
SELECT * FROM :working_schema.source_to_concept_map_f WHERE source_vocabulary_id = 'ICD10';
*/

/*　domain_idを付加してSELECT
SELECT source_code, source_concept_id, source_vocabulary_id, source_code_description, target_concept_id, target_vocabulary_id, c.domain_id, c.concept_class_id, c.concept_name
FROM  :working_schema.v_source_to_concept_map_athena_icd10_medisextention
LEFT JOIN :working_schema.concept_f c ON target_concept_id = c.concept_id
ORDER BY source_code;
*/

