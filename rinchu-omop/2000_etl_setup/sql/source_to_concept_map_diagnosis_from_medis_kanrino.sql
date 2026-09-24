/*
============================================================
  Script Name : source_to_concept_map_medis_diagknr.sql
  Description : MEDIS ICD10対応標準病名マスタを元に、
                病名管理番号からStandard Concept
                のconcept_idに変換するsource_to_concept_mapを作成する

  構成概要：
  1. cte_00_icd10_to_standard
     - ATHENA concept/concept_relationshipからICD10とStandard Conceptとの対応表
     (マッピング先はCondition かつ Standard conceptに限定)

  2. cte_01_byomeimst
     - MEDIS病名マスタのconcept結合用前処理(ICD10コード書式の編集)

  3. cte_02_icd10
     - MEDIS病名マスタ病名管理番号とICD10のconcept_idの対応表

  4. cte_03_standard
     - MEDIS病名マスタ病名管理番号とStandard concept_idの対応表

  5. cte04_icd_standard_union
     - cte_02_icd10とcte_03_standardの統合

  6. cte05_final
     - source_to_concept_map形式に整形

  出力：OMOP CDMのsource_to_concept_map形式に準拠したデータセット
  vocabulary_id:
    MEDIS_DIAGKNR_S : 病名管理番号 to Standard Concept(ICD10からMaps toで関連付けられたstandard concept_id)
    MEDIS_DIAGKNR_N : 病名管理番号 to Non-Standard Concept(ICD10)
    MEDIS_DIAGKNR_V : 病名管理番号 to value用Standard Concept(ICD10からMaps to valueで関連付けられたstandard concept_id)
============================================================
*/
CREATE OR REPLACE VIEW :working_schema.v_source_to_concept_map_medis_diagknr AS
WITH

-- conceptとconcept_relationshipを使用してICD10(non-standard)とstandard conceptとの対応表を作成する
cte_00_icd10_to_standard AS(
SELECT
    cr.concept_id_1,
    c1.concept_name AS concept_name_1,
    c1.vocabulary_id AS vocabulary_id_1,
    c1.domain_id AS domain_id_1,
    c1.concept_class_id AS concept_class_id_1,
    c1.concept_code AS concept_code_1,
    cr.relationship_id, 
    cr.concept_id_2,
    c2.concept_name AS concept_name_2,
    c2.vocabulary_id AS vocabulary_id_2,
    c2.domain_id AS domain_id_2,
    c2.concept_class_id AS concept_class_id_2,
    c2.concept_code AS concept_code_2
FROM :working_schema.concept_relationship_f cr
JOIN :working_schema.concept_f c1 ON cr.concept_id_1 = c1.concept_id
JOIN :working_schema.concept_f c2 ON cr.concept_id_2 = c2.concept_id
WHERE
    c1.vocabulary_id = 'ICD10'
    AND c2.standard_concept = 'S'
),

-- MEDIS病名マスタのICD10コードをconceptのICD10コードと形式一致するように整形
cte_01_byomeimst AS (
    SELECT
    by.*,
    CASE
        WHEN LENGTH(REPLACE(by.icd10_2013, '-', '.')) <= 3 THEN REPLACE(by.icd10_2013, '-', '.')
        WHEN REPLACE(by.icd10_2013, '-', '.') LIKE '%.%' THEN REPLACE(by.icd10_2013, '-', '.')
        ELSE LEFT(REPLACE(by.icd10_2013, '-', '.'), 3) || '.' || RIGHT(REPLACE(by.icd10_2013, '-', '.'), LENGTH(REPLACE(by.icd10_2013, '-', '.')) - 3)
    END AS icd10_1,
    CASE
        WHEN LENGTH(REPLACE(by.icd10_2013_sub, '-', '.')) <= 3 THEN REPLACE(by.icd10_2013_sub, '-', '.')
        WHEN REPLACE(by.icd10_2013_sub, '-', '.') LIKE '%.%' THEN REPLACE(by.icd10_2013_sub, '-', '.')
        ELSE LEFT(REPLACE(by.icd10_2013_sub, '-', '.'), 3) || '.' || RIGHT(REPLACE(by.icd10_2013_sub, '-', '.'), LENGTH(REPLACE(by.icd10_2013_sub, '-', '.')) - 3)
    END AS icd10_2
    FROM :source_schema.mst_medis_byomei by
),

-- MEDIS病名マスタの病名管理番号とICD10のconcept_idの対応表を生成
-- 完全一致を優先し、完全一致がない場合のみ部分一致と結合
cte_02_icd10 AS (
    WITH combined_icd AS (
        SELECT by.*, by.icd10_1 AS icd_code, 1 AS icdnum FROM cte_01_byomeimst by
        UNION ALL
        SELECT by.*, by.icd10_2 AS icd_code, 2 AS icdnum FROM cte_01_byomeimst by
        WHERE by.icd10_2013_sub IS NOT NULL AND icd10_2013_sub != ''
    )
    SELECT
        c.*,
        c.kanrino AS byomei_cd,
        c.icd_code AS icd10_cd,
        COALESCE(c.icd_code || '|' || c.byomeiname, c.byomeiname) AS byomei_name,
        COALESCE(con_exact.concept_id, con_partial.concept_id, con_digit_remove.concept_id, con_base.concept_id) AS concept_id,
        COALESCE(con_exact.concept_name, con_partial.concept_name, con_digit_remove.concept_name, con_base.concept_name) AS concept_name,
        COALESCE(con_exact.vocabulary_id, con_partial.vocabulary_id, con_digit_remove.vocabulary_id, con_base.vocabulary_id) AS vocabulary_id,
        COALESCE(con_exact.domain_id, con_partial.domain_id, con_digit_remove.domain_id, con_base.domain_id) AS domain_id,
        COALESCE(con_exact.concept_class_id, con_partial.concept_class_id, con_digit_remove.concept_class_id, con_base.concept_class_id) AS concept_class_id,
        COALESCE(con_exact.concept_code, con_partial.concept_code, con_digit_remove.concept_code, con_base.concept_code) AS concept_code,
        COALESCE(con_exact.valid_start_date, con_partial.valid_start_date, con_digit_remove.valid_start_date, con_base.valid_start_date) AS valid_start_date,
        COALESCE(con_exact.valid_end_date, con_partial.valid_end_date, con_digit_remove.valid_end_date, con_base.valid_end_date) AS valid_end_date,
        COALESCE(con_exact.invalid_reason, con_partial.invalid_reason, con_digit_remove.invalid_reason, con_base.invalid_reason) AS invalid_reason,
        c.icdnum
    FROM combined_icd c
    LEFT JOIN :working_schema.concept_f con_exact ON con_exact.vocabulary_id = 'ICD10' AND con_exact.concept_code = c.icd_code
    LEFT JOIN :working_schema.concept_f con_partial ON con_partial.vocabulary_id = 'ICD10' AND
     (con_partial.concept_code = c.icd_code || '0' OR con_partial.concept_code || '0' = c.icd_code)
    LEFT JOIN :working_schema.concept_f con_digit_remove ON con_digit_remove.vocabulary_id = 'ICD10' AND
     con_digit_remove.concept_code = LEFT(c.icd_code, LENGTH(c.icd_code) - 1)
    LEFT JOIN :working_schema.concept_f con_base ON con_base.vocabulary_id = 'ICD10' AND
     con_base.concept_code = LEFT(c.icd_code, POSITION('.' IN c.icd_code) - 1)
    ORDER BY kanrino
),

-- MEDIS病名マスタの病名管理番号とstandard concept_idの対応表を生成
cte_03_standard AS (
    SELECT
        -- MEDIS病名マスタ
        icd.*,
        -- ICD10 to standard mapping
        r.relationship_id,
        r.concept_id_2 AS concept_id_std,
        r.concept_name_2 AS concept_name_std,
        r.vocabulary_id_2 AS vocabulary_id_std,
        r.domain_id_2 AS domain_id_std,
        r.concept_class_id_2 AS concept_class_id_std,
        r.concept_code_2 AS concept_code_std
    FROM cte_02_icd10 icd
    JOIN cte_00_icd10_to_standard r ON icd.concept_id = r.concept_id_1
),

-- MEDIS病名マスタの病名管理番号とicd10 / standard concept_idの対応表を統合
cte04_icd_standard_union AS (
/* 病名管理番号 to icd10(non-standard)マッピング は使用しないため出力しない
    SELECT
        'N' AS standard_flg,
        icd.byomei_cd AS source_code,
        icd.byomei_name AS source_code_description,
        0 AS source_concept_id,
        NULL AS relationship_id,
        icd.concept_id AS target_concept_id,
        icd.concept_name AS target_concept_name,
        icd.concept_code AS target_concept_code,
        icd.vocabulary_id AS target_vocabulary_id,
        icd.domain_id AS target_domain_id,
        icd.concept_class_id AS target_concept_class_id,
        icd.valid_start_date AS target_valid_start_date,
        icd.valid_end_date AS target_valid_end_date,
        icd.invalid_reason AS target_invalid_reason
    FROM cte_02_icd10 icd
    UNION
*/
	SELECT
        'Y' AS standard_flg,
        std.byomei_cd AS source_code,
        std.byomei_name AS source_code_description,
        COALESCE(std.concept_id, 0) AS source_concept_id,
        std.relationship_id AS relationship_id,
        std.concept_id_std AS target_concept_id,
        std.concept_name_std AS target_concept_name,
        std.concept_code_std AS target_concept_code,
        std.vocabulary_id_std AS target_vocabulary_id,
        std.domain_id_std AS target_domain_id,
        std.concept_class_id_std AS target_concept_class_id,
        std.valid_start_date AS target_valid_start_date,
        std.valid_end_date AS target_valid_end_date,
        std.invalid_reason AS target_invalid_reason
    FROM cte_03_standard std
),

-- source_to_concept_map形式に編集
cte_final_prep AS(
	SELECT
        TRIM(TO_CHAR(source_code::integer,'00000000')) AS source_code,
        source_concept_id,
        CASE WHEN relationship_id = 'Maps to value' AND target_domain_id = 'Meas Value' THEN 'MEDIS_DIAGKNR_V'
        ELSE
            CASE 
                WHEN standard_flg = 'Y' THEN 'MEDIS_DIAGKNR_S'
                ELSE 'MEDIS_DIAGKNR_N'
            END
        END AS source_vocabulary_id,
        source_code_description,
        COALESCE(target_concept_id,0) AS target_concept_id,
		COALESCE(target_vocabulary_id,'')  AS target_vocabulary_id,
        COALESCE(target_valid_start_date, TO_DATE('19700101','YYYYMMDD')) AS valid_start_date,
        COALESCE(target_valid_end_date, TO_DATE('20991231','YYYYMMDD')) AS valid_end_date,
		target_invalid_reason AS invalid_reason,
		ROW_NUMBER() OVER (PARTITION BY source_code, target_concept_id ORDER BY source_concept_id) AS rn
	FROM cte04_icd_standard_union
),

cte_final AS(
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
	FROM cte_final_prep
	WHERE rn = 1
	ORDER BY source_code, source_vocabulary_id, target_concept_id
)
SELECT * FROM cte_final ORDER BY source_code, source_code_description,source_vocabulary_id, target_concept_id;

/* source_to_concept_mapへの登録
DELETE FROM :working_schema.source_to_concept_map_f WHERE source_vocabulary_id LIKE 'MEDIS_DIAGKNR%';
INSERT INTO :working_schema.source_to_concept_map_f SELECT * FROM :working_schema.v_source_to_concept_map_MEDIS_DIAGKNR;
SELECT * FROM :working_schema.source_to_concept_map_f WHERE source_vocabulary_id LIKE 'MEDIS_DIAGKNR%';
SELECT DISTINCT source_vocabulary_id, count(1) FROM :working_schema.source_to_concept_map_f WHERE source_vocabulary_id LIKE 'MEDIS_DIAGKNR%' GROUP BY source_vocabulary_id;
*/

/*　domain_idを付加してSELECT
SELECT source_code, source_concept_id, source_vocabulary_id, source_code_description, target_concept_id, target_vocabulary_id, c.domain_id, c.concept_class_id, c.concept_name
FROM  :working_schema.v_source_to_concept_map_MEDIS_DIAGKNR
LEFT JOIN :working_schema.concept_f c ON target_concept_id = c.concept_id
ORDER BY source_code, source_vocabulary_id, source_code_description;
*/

