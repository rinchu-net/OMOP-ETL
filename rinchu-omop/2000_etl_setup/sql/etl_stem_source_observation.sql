\set ON_ERROR_STOP on
CREATE OR REPLACE VIEW :working_schema.v_stem_source_observation AS
WITH etl_stem_source_observation AS (
    SELECT
        patient_id AS person_source_value,
        sch_spm_collect_date AS start_date,
		CASE
			WHEN spm_collect_time = '999999' OR spm_collect_time IS NULL OR spm_collect_time ~ '^[0-9]{6}$' = false 
			     OR SUBSTRING(spm_collect_time, 1, 2)::integer >= 24 
			     OR SUBSTRING(spm_collect_time, 3, 2)::integer >= 60 
			     OR SUBSTRING(spm_collect_time, 5, 2)::integer >= 60 
			THEN TO_TIMESTAMP(spm_collect_date || '000000','YYYYMMDDHH24MISS')
			ELSE TO_TIMESTAMP(spm_collect_date || spm_collect_time,'YYYYMMDDHH24MISS')
		END AS start_datetime,
		CASE
			WHEN spm_collect_time = '999999' OR spm_collect_time IS NULL OR spm_collect_time ~ '^[0-9]{6}$' = false 
			     OR SUBSTRING(spm_collect_time, 1, 2)::integer >= 24 
			     OR SUBSTRING(spm_collect_time, 3, 2)::integer >= 60 
			     OR SUBSTRING(spm_collect_time, 5, 2)::integer >= 60 
			THEN '00:00:00'::time
			ELSE TO_TIMESTAMP(spm_collect_time,'HH24MISS')::time
		END AS start_time,
        NULL::date AS end_date,
        NULL::timestamp AS end_datetime,
        dept_cd_s AS provider_source_value,
        NULL AS visit_source_value,
        NULL AS visit_detail_source_value,
        obx_cd_s AS source_value,
        'Measurement' AS source_domain_id,
        'RINCHU_OBX_CD' AS source_vocabulary_id,
        NULL AS secondary_vocabulary_id,
        COALESCE(obx_cd_s, '') || '|' || COALESCE(obx_name_s, '') || '|' || COALESCE(obx_name_l, '') || '|' || COALESCE(spm_cd_s, '') || '|' || COALESCE(spm_name_s, '') AS source_regvalue,
        'EHR' AS type_category,
        -- value_source_valueには、value_concept_idに変換させるべき値だけを抽出して設定する
        CASE 
            -- 定性マーカーを抽出（()/[] どちらの括りにも対応）
            WHEN obx_value_l ~ '[\(\[][+\-±]+[\)\]]' THEN
                (regexp_match(obx_value_l, '([\(\[][+\-±]+[\)\]])'))[1]
            -- 純粋な数値の場合はNULL
            WHEN obx_value_l ~ '^[+-]?[0-9]*\.?[0-9]+([eE][+-]?[0-9]+)?$' THEN
                NULL
            -- 演算子+数値のみの場合はNULL（例: <40, >=5.0, <=25）
            WHEN obx_value_l ~ '^(<|>|<=|>=|≤|≥|≧|＜|＞)\s*[0-9]+\.?[0-9]*$' THEN
                NULL
            ELSE
                -- その他の非数値データ：演算子記号（記号・日本語）を除去した値を返す
                -- ただし、除去後に純粋な数値になる場合はNULLを返す（例: 600.0<, 180.0以上）
                CASE
                    WHEN TRIM(regexp_replace(obx_value_l, '(<|>|<=|>=|≤|≥|≧|＜|＞|以上|以下|未満|ｲｼﾞｮｳ|ｲｶ|ﾐﾏﾝ)', '', 'g')) ~ '^[+-]?[0-9]*\.?[0-9]+([eE][+-]?[0-9]+)?$' THEN
                        NULL
                    ELSE
                        regexp_replace(obx_value_l, '(<|>|<=|>=|≤|≥|≧|＜|＞|以上|以下|未満|ｲｼﾞｮｳ|ｲｶ|ﾐﾏﾝ)', '', 'g')
                END
        END AS value_source_value,
        'Meas Value' AS value_domain_id,    
        'RINCHU_OBX_VALUE' AS value_vocabulary_id,
        NULL AS value_secondary_vocabulary_id,
        obx_value_l AS value_source_regvalue,
        obx_unit_s AS unit_source_value,
        'Unit' AS unit_domain_id,
        'RINCHU_OBX_UNIT' AS unit_vocabulary_id,
        NULL AS unit_secondary_vocabulary_id,
        obx_unit_s AS unit_source_regvalue,
--      sch_obx_value_s AS value_as_number,
        CASE
            WHEN sch_obx_value_s IS NOT NULL THEN sch_obx_value_s
            -- sch_obx_value_sがNULLの場合、obx_value_lから等符号を除去した数値を抽出して登録
            WHEN obx_value_l IS NOT NULL THEN
                CASE
                    -- 定性マーカー（()/[]括り）と不等号（記号・日本語）を除去して数値を抽出
                    WHEN TRIM(regexp_replace(obx_value_l, '(\([+\-±]+\)|\[[+\-±]+\]|<|>|<=|>=|≤|≥|≧|＜|＞|以上|以下|未満|ｲｼﾞｮｳ|ｲｶ|ﾐﾏﾝ)', '', 'g')) ~ '^[+-]?[0-9]*\.?[0-9]+([eE][+-]?[0-9]+)?$'
                    THEN TRIM(regexp_replace(obx_value_l, '(\([+\-±]+\)|\[[+\-±]+\]|<|>|<=|>=|≤|≥|≧|＜|＞|以上|以下|未満|ｲｼﾞｮｳ|ｲｶ|ﾐﾏﾝ)', '', 'g'))::numeric
                    ELSE NULL
                END
            ELSE NULL
        END AS value_as_number,
        NULL AS qualifier_source_value,
        NULL AS qualifier_domain_id,
        NULL AS qualifier_vocabulary_id,
        NULL AS qualifier_secondary_vocabulary_id,
        NULL AS qualifier_source_regvalue,
        obx_value_l AS value_as_string,
        CASE 
            WHEN obx_range_low_l ~ '^[+-]?[0-9]*\.?[0-9]+([eE][+-]?[0-9]+)?$' 
            THEN obx_range_low_l::numeric
            ELSE NULL 
        END AS range_low,
        CASE 
            WHEN obx_range_high_l ~ '^[+-]?[0-9]*\.?[0-9]+([eE][+-]?[0-9]+)?$' 
            THEN obx_range_high_l::numeric
            ELSE NULL 
        END AS range_high,
        CASE 
            WHEN obx_value_l is not NULL AND (position('<=' in obx_value_l) <> 0 OR position('≤' in obx_value_l) <> 0) THEN '<=' 
            WHEN obx_value_l is not NULL AND (position('以下' in obx_value_l) <> 0 OR (position('ｲｶ' in obx_value_l) <> 0 AND obx_value_l <> 'ﾊﾝｲｶﾞｲ')) THEN '<=' 
            WHEN obx_value_l is not NULL AND (position('>=' in obx_value_l) <> 0 OR position('≥' in obx_value_l) <> 0 OR position('≧' in obx_value_l) <> 0) THEN '>=' 
            WHEN obx_value_l is not NULL AND (position('以上' in obx_value_l) <> 0 OR (position('ｲｼﾞｮｳ' in obx_value_l) <> 0 AND obx_value_l <> 'ｲｼﾞｮｳ') OR position('≧' in obx_value_l) <> 0) THEN '>=' 
            WHEN obx_value_l is not NULL AND (position('<' in obx_value_l) <> 0 OR position('＜' in obx_value_l) <> 0) THEN '<' 
            WHEN obx_value_l is not NULL AND (position('未満' in obx_value_l) <> 0 OR position('ﾐﾏﾝ' in obx_value_l) <> 0) THEN '<' 
            WHEN obx_value_l is not NULL AND (position('>' in obx_value_l) <> 0 OR position('＞' in obx_value_l) <> 0) THEN '>' 
            WHEN obx_value_l is not NULL AND position('=' in obx_value_l) <> 0 THEN '=' 
        END AS operator_source_value,
        'Meas Value Operator' AS operator_domain_id,
        'RINCHU_OBX_OPERATOR' AS operator_vocabulary_id,
        NULL AS operator_secondary_vocabulary_id,
        CASE 
            WHEN obx_value_l is not NULL AND (position('<=' in obx_value_l) <> 0 OR position('≤' in obx_value_l) <> 0) THEN '<=' 
            WHEN obx_value_l is not NULL AND (position('以下' in obx_value_l) <> 0 OR (position('ｲｶ' in obx_value_l) <> 0 AND obx_value_l <> 'ﾊﾝｲｶﾞｲ')) THEN '以下' 
            WHEN obx_value_l is not NULL AND (position('>=' in obx_value_l) <> 0 OR position('≥' in obx_value_l) <> 0 OR position('≧' in obx_value_l) <> 0) THEN '>=' 
            WHEN obx_value_l is not NULL AND (position('以上' in obx_value_l) <> 0 OR (position('ｲｼﾞｮｳ' in obx_value_l) <> 0 AND obx_value_l <> 'ｲｼﾞｮｳ') OR position('≧' in obx_value_l) <> 0) THEN '以上' 
            WHEN obx_value_l is not NULL AND (position('<' in obx_value_l) <> 0 OR position('＜' in obx_value_l) <> 0) THEN '<' 
            WHEN obx_value_l is not NULL AND (position('未満' in obx_value_l) <> 0 OR position('ﾐﾏﾝ' in obx_value_l) <> 0) THEN '未満' 
            WHEN obx_value_l is not NULL AND (position('>' in obx_value_l) <> 0 OR position('＞' in obx_value_l) <> 0) THEN '>' 
            WHEN obx_value_l is not NULL AND position('=' in obx_value_l) <> 0 THEN '=' 
        END AS operator_source_regvalue,
        NULL::integer AS quantity,
        NULL AS anatomic_site_source_value,
        NULL AS anatomic_site_domain_id,
        NULL AS anatomic_site_vocabulary_id,
        NULL AS anatomic_site_secondary_vocabulary_id,
        NULL AS anatomic_site_source_regvalue,
        NULL AS specimen_source_id,
        obx_result_status_cd AS status_source_value,
        NULL AS status_domain_id,
        'RINCHU_OBX_STATUS' AS status_vocabulary_id,
        NULL AS status_secondary_vocabulary_id,
        obx_result_status_cd AS status_source_regvalue,
        NULL AS unique_device_id,
        NULL AS modifier_source_value,
        NULL AS modifier_domain_id,
        NULL AS modifier_vocabulary_id,
        NULL AS modifier_secondary_vocabulary_id,
        NULL AS modifier_source_regvalue,
        NULL AS stop_reason,
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
        'ObservationResult' AS stem_source_table,
        'obx_cd_s' AS stem_source_field,
        obx_unique_id AS stem_source_rowid
    FROM :source_schema.ObservationResult
    WHERE obx_cd_s IS NOT NULL
)

SELECT * FROM etl_stem_source_observation;

--- テストクエリ
--SELECT COUNT(1) FROM :working_schema.v_stem_source_observation;
--SELECT * FROM :working_schema.v_stem_source_observation LIMIT 100;

--- データ生成
--DELETE FROM :working_schema.stem_source WHERE table_name = 'ObservationResult';
--INSERT INTO :working_schema.stem_source SELECT * FROM :working_schema.v_stem_source_observation;
--SELECT * FROM :working_schema.stem_source WHERE table_name = 'ObservationResult';
