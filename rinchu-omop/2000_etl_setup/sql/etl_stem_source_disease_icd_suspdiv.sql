\set ON_ERROR_STOP on
-- 仕様: 疑い病名 [dis_suspect_cd='1'] は Condition ではなく Observation_result に分離する
CREATE OR REPLACE VIEW :working_schema.v_stem_source_disease_icd_suspdiv AS
WITH etl_disease AS (
    SELECT
        patient_id AS person_source_value,
        sch_dis_start_date AS start_date,
        NULL::timestamp AS start_datetime,
        NULL::time AS start_time,
        COALESCE( -- OUTCOME_DATEを優先、なければEND_DATEを使用　ただし9999-12-31はNULLに変換する
            NULLIF(sch_dis_outcome_date, '9999-12-31'::date),
            NULLIF(sch_dis_end_date, '9999-12-31'::date)
        ) AS end_date,
        NULL::timestamp AS end_datetime,
        dept_cd_s AS provider_source_value,
        NULL AS visit_source_value,
        NULL AS visit_detail_source_value,
        CASE
            WHEN dis_suspect_cd = '1' THEN 'Uncertain diagnosis' -- 疑い病名は’Uncertain diagnosis’固定
            WHEN LENGTH(REPLACE(icd10_cd, '-', '.')) <= 3 THEN REPLACE(icd10_cd, '-', '.')
            WHEN REPLACE(icd10_cd, '-', '.') LIKE '%.%' THEN REPLACE(icd10_cd, '-', '.')
            ELSE LEFT(REPLACE(icd10_cd, '-', '.'), 3) || '.' || RIGHT(REPLACE(icd10_cd, '-', '.'), LENGTH(REPLACE(icd10_cd, '-', '.')) - 3)
        END AS source_value,
        CASE
            WHEN dis_suspect_cd = '1' THEN 'Observation' -- 疑い病名はObservationに分離
            ELSE 'Condition'
        END AS source_domain_id,
        CASE
            WHEN dis_suspect_cd = '1' THEN 'UNCERTAIN_DIAGNOSIS' -- 疑い病名は’Uncertain diagnosis’固定
            ELSE 'RINCHU_DIAGICD'    -- 臨中固有マッピングを優先使用
        END AS source_vocabulary_id,
        CASE
            WHEN dis_suspect_cd = '1' THEN NULL -- 疑い病名はNULL固定
            ELSE 'ATHENA_ICD10'  -- 標準はICD10コードからstandard conceptへマッピング
        END AS secondary_vocabulary_id,   
        CASE
            WHEN dis_suspect_cd = '1' THEN 'Uncertain diagnosis' -- 疑い病名は’Uncertain diagnosis’固定
            ELSE COALESCE(icd10_cd, '') || '|' || COALESCE(dis_management_cd, '') || '|' || COALESCE(dis_name, '')
        END AS source_regvalue,
        'EHR' AS type_category,
        CASE
            WHEN dis_suspect_cd = '1' THEN -- 疑い病名はvalue_source_valueにICD10コードを格納
                CASE
                    WHEN LENGTH(REPLACE(icd10_cd, '-', '.')) <= 3 THEN REPLACE(icd10_cd, '-', '.')
                    WHEN REPLACE(icd10_cd, '-', '.') LIKE '%.%' THEN REPLACE(icd10_cd, '-', '.')
                    ELSE LEFT(REPLACE(icd10_cd, '-', '.'), 3) || '.' || RIGHT(REPLACE(icd10_cd, '-', '.'), LENGTH(REPLACE(icd10_cd, '-', '.')) - 3)
                END
            ELSE NULL
        END AS value_source_value,
        CASE
            WHEN dis_suspect_cd = '1' THEN 'Condition'  -- 疑い病名はvalue_domain_idをConditionに分離
            ELSE 'Meas Value'
        END AS value_domain_id,
        CASE
            WHEN dis_suspect_cd = '1' THEN 'RINCHU_DIAGICD'  -- 疑い病名はvalue_vocabulary_idをRINCHU_DIAGICDに分離
            ELSE 'ATHENA_ICD10_VALUE'
        END AS value_vocabulary_id,   -- ICD10からstandard concept(Meas Value)へマッピング
        CASE
            WHEN dis_suspect_cd = '1' THEN 'ATHENA_ICD10'  -- 疑い病名はvalue_secondary_vocabulary_idをATHENA_ICD10に分離
            ELSE NULL
        END AS value_secondary_vocabulary_id,
        CASE
            WHEN dis_suspect_cd = '1' THEN COALESCE(icd10_cd, '') || '|' || COALESCE(dis_management_cd, '') || '|' || COALESCE(dis_name, '')  -- 疑い病名はvalue_source_regvalueにICD10コードを格納
            ELSE NULL
        END AS value_source_regvalue,
        NULL AS unit_source_value,
        NULL AS unit_domain_id,
        NULL AS unit_vocabulary_id,
        NULL AS unit_secondary_vocabulary_id,
        NULL AS unit_source_regvalue,
        NULL::integer AS value_as_number,
        NULL AS qualifier_source_value,
        NULL AS qualifier_domain_id,
        NULL AS qualifier_vocabulary_id,
        NULL AS qualifier_secondary_vocabulary_id,
        NULL AS qualifier_source_regvalue,
        NULL AS value_as_string,
        NULL::integer AS range_low,
        NULL::integer AS range_high,
        NULL AS operator_source_value,
        NULL AS operator_domain_id,
        NULL AS operator_vocabulary_id,
        NULL AS operator_secondary_vocabulary_id,
        NULL AS operator_source_regvalue,
        NULL::integer AS quantity,
        NULL AS anatomic_site_source_value,
        NULL AS anatomic_site_domain_id,
        NULL AS anatomic_site_vocabulary_id,
        NULL AS anatomic_site_secondary_vocabulary_id,
        NULL AS anatomic_site_source_regvalue,
        NULL AS specimen_source_id,
        CASE
            WHEN dis_suspect_cd = '1' THEN NULL
            WHEN dis_classification_cd = '1' THEN 'MAIN'
            WHEN dis_classification_cd = '2' THEN 'SUB'
            ELSE NULL
        END AS status_source_value,
        CASE
            WHEN dis_suspect_cd = '1' THEN NULL
            ELSE 'Condition Status'
        END AS status_domain_id,
        CASE
            WHEN dis_suspect_cd = '1' THEN NULL
            ELSE 'RINCHU_DIS_STATUS'
        END AS status_vocabulary_id,
        NULL AS status_secondary_vocabulary_id,
        CASE
            WHEN dis_suspect_cd = '1' THEN NULL
            ELSE COALESCE(dis_classification_cd, '')
        END AS status_source_regvalue,
        NULL AS unique_device_id,
        NULL AS modifier_source_value,
        NULL AS modifier_domain_id,
        NULL AS modifier_vocabulary_id,
        NULL AS modifier_secondary_vocabulary_id,
        NULL AS modifier_source_regvalue,
        CASE
            -- HL7表 0241-患者の結果
            WHEN dis_outcome_cd = 'D' THEN dis_outcome_cd || '|死亡' 
            WHEN dis_outcome_cd = 'R' THEN dis_outcome_cd || '|回復' 
            WHEN dis_outcome_cd = 'N' THEN dis_outcome_cd || '|回復せず/変わらない' 
            WHEN dis_outcome_cd = 'W' THEN dis_outcome_cd || '|悪化' 
            WHEN dis_outcome_cd = 'S' THEN dis_outcome_cd || '|後遺症' 
            WHEN dis_outcome_cd = 'F' THEN dis_outcome_cd || '|完全に回復した' 
            WHEN dis_outcome_cd = 'U' THEN dis_outcome_cd || '|未知' 
            -- JHSD表 0006-転帰区分
            WHEN dis_outcome_cd = 'I' THEN dis_outcome_cd || '|中止' 
            WHEN dis_outcome_cd = 'M' THEN dis_outcome_cd || '|寛解' 
            WHEN dis_outcome_cd = 'C' THEN dis_outcome_cd || '|継続' 
            WHEN dis_outcome_cd = 'O' THEN dis_outcome_cd || '|その他' 
            ELSE NULL
        END AS stop_reason,
        NULL::integer AS refills,
        NULL::integer AS days_supply,
        NULL AS sig,
        NULL AS lot_number,
        NULL::date AS verbatim_end_date,
        NULL AS route_source_value,
        NULL AS route_domain_id,
        NULL AS route_vocabulary_id,
        NULL AS route_secondary_vocabulary_id,
        NULL AS route_source_regvalue,
        'PatientDisease' AS stem_source_table,
        'icd10_cd' AS stem_source_field,
        dis_unique_id AS stem_source_rowid
    FROM :source_schema.patientdisease
)

SELECT * FROM etl_disease ORDER BY person_source_value, start_date, source_value;

--- テストクエリ
--SELECT COUNT(1) FROM :working_schema.v_stem_source_disease_icd_suspdiv;
--SELECT * FROM :working_schema.v_stem_source_disease_icd_suspdiv LIMIT 100;

--- データ生成
--DELETE FROM :working_schema.stem WHERE table_name = 'PatientDisease';
--INSERT INTO :working_schema.stem SELECT * FROM :working_schema.v_stem_source_disease_icd_suspdiv;
--SELECT * FROM :working_schema.stem WHERE table_name = 'PatientDisease';
