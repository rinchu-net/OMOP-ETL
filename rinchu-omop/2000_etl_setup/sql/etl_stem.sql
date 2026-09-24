\set ON_ERROR_STOP on
/*
============================================================
  Script Name : etl_stem.sql
  Description : ETL中間テーブル(stem_source)について、
                person,provider,visit_occurrence,visit_detail,concept等の
                外部テーブルを結合し、外部参照カラムを補完する

  構成概要：
    1. person
    - personテーブルを結合し、person_idを取得

    2. provider
    - providerテーブルを結合し、provider_idを取得

    3. visit_occurrence, visit_detail
    - 【Performance Tuning対応で廃止】visit_occurrence_idが必要なテーブルは各v_*_mで個別実装すること

    4. source_value
    - source_value(procedure, condition_occurrenceなど各テーブルの主項目のソースコード）
        から、source_to_concept_mapを使用してconcept_idを取得する。
    - source_to_concept_mapを検索する際、２段階でconcept_idを取得する。
        1. source_vocabulary_idが一致するマッピングを取得
        2. 取得できなければsecondary_vocabulary_idが一致するマッピングを取得
        3. それでも取得できなければ0
    - この仕様の前提として、source_to_concept_mapには以下の前提でマッピングテーブルを整備する必要がある。
        1. standard conceptとのマッピングはsource_vocabulary_id (ex:SNOMEDなど)
        2. non-standard conceptとのマッピングはsecondary_vocabulary_id (ex:ICD10など)

  5. value_source_value, unit_source_value, qualifier_source_value, operator_source_value, anatomic_site_source_value, status_source_value, modifier_source_value, route_source_value
    - source_valueと同様、各項目のソースコードをsource_to_concept_mapを使用して２段階でconcept_idを取得する。

  6. type_category
    - source_to_concept_map.source_vocabulary_id = 'RINCHU_EVENT_TYPE'の固定条件で、該当するマッピングを取得する

  7. domain_id
    - 各レコードをどのdomainとして扱うかを決定する
       1. concept_idが0の場合はconceptの定義のdomainがMetaDataになってしまうので、データ作成元が指定したsource_domain_idを使用
       2. conceptにconcept_idが存在しない場合はdomain不明のため、データ作成元が指定したsource_domain_idを使用
       3. それ以外の場合(concept_idが正常に取得できた場合）はconceptに定義されたdomain_idを使用

  出力：stem_sourceに各種idを付加したデータセット
============================================================
*/
CREATE OR REPLACE VIEW :working_schema.v_stem AS
WITH
cte_mapped AS (
SELECT

-------------------------------------------------------
-- stem_source join external tables
-------------------------------------------------------
    src.person_source_value,
        ps.person_id,
    src.start_date,
    src.start_datetime,
    src.start_time,
    src.end_date,
    src.end_datetime,
    src.provider_source_value,
        pr.provider_id,
    NULL::varchar AS visit_source_value,
    NULL::bigint  AS visit_occurrence_id,
    NULL::varchar AS visit_detail_source_value,
    NULL::bigint  AS visit_detail_id,
    src.source_value,
    src.source_domain_id,
    src.source_vocabulary_id,
    src.source_secondary_vocabulary_id,
        CASE
            WHEN evt1c.concept_id IS NOT NULL THEN src.source_vocabulary_id
            WHEN evt2c.concept_id IS NOT NULL THEN src.source_secondary_vocabulary_id
            ELSE src.source_vocabulary_id
        END AS mapped_source_vocabulary_id,
        COALESCE(evt1.source_concept_id, evt2.source_concept_id, 0) AS source_concept_id,
        COALESCE(evt1c.concept_id, evt2c.concept_id, 0) AS concept_id,
        COALESCE(evt1c.concept_name, evt2c.concept_name) AS concept_name,
        COALESCE(evt1c.domain_id, evt2c.domain_id) AS concept_domain_id,
        COALESCE(evt1c.vocabulary_id, evt2c.vocabulary_id) AS concept_vocabulary_id,
    src.source_regvalue,
    src.type_category,
        COALESCE(et.target_concept_id, NULL) AS type_concept_id,

-------------------------------------------------------
--Measurement and Observation
-------------------------------------------------------
    src.value_source_value,
    src.value_domain_id,
    src.value_vocabulary_id,
    src.value_secondary_vocabulary_id,
        CASE
            WHEN val1c.concept_id IS NOT NULL THEN src.value_vocabulary_id
            WHEN val2c.concept_id IS NOT NULL THEN src.value_secondary_vocabulary_id
            WHEN val3c.concept_id IS NOT NULL THEN src.source_vocabulary_id -- val3 is for considering the measurement value from disease code mapping
            ELSE src.value_vocabulary_id
        END AS mapped_value_vocabulary_id,
        COALESCE(val1c.concept_id, val2c.concept_id, val3c.concept_id) AS value_as_concept_id, -- val3 is for considering the measurement value from disease code mapping
        COALESCE(val1c.concept_name, val2c.concept_name, val3c.concept_name) AS value_as_concept_name, -- val3 is for considering the measurement value from disease code mapping
        COALESCE(val1c.domain_id, val2c.domain_id, val3c.domain_id) AS value_as_concept_domain_id, -- val3 is for considering the measurement value from disease code mapping
        COALESCE(val1c.vocabulary_id, val2c.vocabulary_id, val3c.vocabulary_id) AS value_as_concept_vocabulary_id, -- val3 is for considering the measurement value from disease code mapping
    CASE 
        WHEN val3c.concept_id IS NOT NULL THEN src.source_regvalue -- val3 is for considering the measurement value from disease code mapping
        ELSE src.value_source_regvalue
    END AS value_source_regvalue,

-------------------------------------------------------
--Measurement, Specimen, Observation, and Drug
-------------------------------------------------------
    src.unit_source_value,
    src.unit_domain_id,
    src.unit_vocabulary_id,
    src.unit_secondary_vocabulary_id,
        CASE
            WHEN unit1c.concept_id IS NOT NULL THEN src.unit_vocabulary_id
            WHEN unit2c.concept_id IS NOT NULL THEN src.unit_secondary_vocabulary_id
            ELSE src.unit_vocabulary_id
        END AS mapped_unit_vocabulary_id,
        COALESCE(unit1.source_concept_id, unit2.source_concept_id) AS unit_source_concept_id,
        COALESCE(unit1c.concept_id, unit2c.concept_id) AS unit_concept_id,
        COALESCE(unit1c.concept_name, unit2c.concept_name) AS unit_concept_name,
        COALESCE(unit1c.domain_id, unit2c.domain_id) AS unit_concept_domain_id,
        COALESCE(unit1c.vocabulary_id, unit2c.vocabulary_id) AS unit_concept_vocabulary_id,
    src.unit_source_regvalue,

-------------------------------------------------------
--Measurement and Observation
-------------------------------------------------------
    src.value_as_number,

-------------------------------------------------------
--Observation
-------------------------------------------------------
    src.qualifier_source_value,
    src.qualifier_domain_id,
    src.qualifier_vocabulary_id,
    src.qualifier_secondary_vocabulary_id,
        CASE
            WHEN qlf1c.concept_id IS NOT NULL THEN src.qualifier_vocabulary_id
            WHEN qlf2c.concept_id IS NOT NULL THEN src.qualifier_secondary_vocabulary_id
            ELSE src.qualifier_vocabulary_id
        END AS mapped_qualifier_vocabulary_id,
        COALESCE(qlf1c.concept_id, qlf2c.concept_id) AS qualifier_concept_id,
        COALESCE(qlf1c.concept_name, qlf2c.concept_name) AS qualifier_concept_name,
        COALESCE(qlf1c.domain_id, qlf2c.domain_id) AS qualifier_concept_domain_id,
        COALESCE(qlf1c.vocabulary_id, qlf2c.vocabulary_id) AS qualifier_concept_vocabulary_id,
    src.qualifier_source_regvalue,
    src.value_as_string,


-------------------------------------------------------
--Measurement
-------------------------------------------------------
    src.range_low,
    src.range_high,
    src.operator_source_value,
    src.operator_domain_id,
    src.operator_vocabulary_id,
    src.operator_secondary_vocabulary_id,
        CASE
            WHEN op1c.concept_id IS NOT NULL THEN src.operator_vocabulary_id
            WHEN op2c.concept_id IS NOT NULL THEN src.operator_secondary_vocabulary_id
            ELSE src.operator_vocabulary_id
        END AS mapped_operator_vocabulary_id,
        COALESCE(op1c.concept_id, op2c.concept_id) AS operator_concept_id,
        COALESCE(op1c.concept_name, op2c.concept_name) AS operator_concept_name,
        COALESCE(op1c.domain_id, op2c.domain_id) AS operator_concept_domain_id,
        COALESCE(op1c.vocabulary_id, op2c.vocabulary_id) AS operator_concept_vocabulary_id,
    src.operator_source_regvalue,

-------------------------------------------------------
--Drug, Specimen, Procedure, and Device
-------------------------------------------------------
    src.quantity,

    --Specimen
    src.anatomic_site_source_value,
    src.anatomic_site_domain_id,
    src.anatomic_site_vocabulary_id,
    src.anatomic_site_secondary_vocabulary_id,
        CASE
            WHEN as1c.concept_id IS NOT NULL THEN src.anatomic_site_vocabulary_id
            WHEN as2c.concept_id IS NOT NULL THEN src.anatomic_site_secondary_vocabulary_id
            ELSE src.anatomic_site_vocabulary_id
        END AS mapped_anatomic_site_vocabulary_id,
        COALESCE(as1c.concept_id, as2c.concept_id) AS anatomic_site_concept_id,
        COALESCE(as1c.concept_name, as2c.concept_name) AS anatomic_site_concept_name,
        COALESCE(as1c.domain_id, as2c.domain_id) AS anatomic_site_concept_domain_id,
        COALESCE(as1c.vocabulary_id, as2c.vocabulary_id) AS anatomic_site_concept_vocabulary_id,
    src.specimen_source_id,
    src.anatomic_site_source_regvalue,

-------------------------------------------------------
--Specimen and Condition
-------------------------------------------------------
    src.status_source_value,
    src.status_domain_id,
    src.status_vocabulary_id,
    src.status_secondary_vocabulary_id,
        CASE
            WHEN sts1c.concept_id IS NOT NULL THEN src.status_vocabulary_id
            WHEN sts2c.concept_id IS NOT NULL THEN src.status_secondary_vocabulary_id
            ELSE src.status_vocabulary_id
        END AS mapped_status_vocabulary_id,
        COALESCE(sts1c.concept_id, sts2c.concept_id) AS status_concept_id,
        COALESCE(sts1c.concept_name, sts2c.concept_name) AS status_concept_name,
        COALESCE(sts1c.domain_id, sts2c.domain_id) AS status_concept_domain_id,
        COALESCE(sts1c.vocabulary_id, sts2c.vocabulary_id) AS status_concept_vocabulary_id,
    src.status_source_regvalue,

-------------------------------------------------------
--Device
-------------------------------------------------------
    src.unique_device_id,

-------------------------------------------------------
--Procedure
-------------------------------------------------------
    src.modifier_source_value,
    src.modifier_domain_id,
    src.modifier_vocabulary_id,
    src.modifier_secondary_vocabulary_id,
        CASE
            WHEN mdf1c.concept_id IS NOT NULL THEN src.modifier_vocabulary_id
            WHEN mdf2c.concept_id IS NOT NULL THEN src.modifier_secondary_vocabulary_id
            ELSE src.modifier_vocabulary_id
        END AS mapped_modifier_vocabulary_id,
        COALESCE(mdf1c.concept_id, mdf2c.concept_id) AS modifier_concept_id,
        COALESCE(mdf1c.concept_name, mdf2c.concept_name) AS modifier_concept_name,
        COALESCE(mdf1c.domain_id, mdf2c.domain_id) AS modifier_concept_domain_id,
        COALESCE(mdf1c.vocabulary_id, mdf2c.vocabulary_id) AS modifier_concept_vocabulary_id,
    src.modifier_source_regvalue,

-------------------------------------------------------
--Drug and Condition
-------------------------------------------------------
    src.stop_reason,

-------------------------------------------------------
--Drug
-------------------------------------------------------
    src.refills,
    src.days_supply,
    src.sig,
    src.lot_number,
    src.verbatim_end_date,
    src.route_source_value,
    src.route_domain_id,
    src.route_vocabulary_id,
    src.route_secondary_vocabulary_id,
        CASE
            WHEN rot1c.concept_id IS NOT NULL THEN src.route_vocabulary_id
            WHEN rot2c.concept_id IS NOT NULL THEN src.route_secondary_vocabulary_id
            ELSE src.route_vocabulary_id
        END AS mapped_route_vocabulary_id,
        COALESCE(rot1c.concept_id, rot2c.concept_id) AS route_concept_id,
        COALESCE(rot1c.concept_name, rot2c.concept_name) AS route_concept_name,
        COALESCE(rot1c.domain_id, rot2c.domain_id) AS route_concept_domain_id,
        COALESCE(rot1c.vocabulary_id, rot2c.vocabulary_id) AS route_concept_vocabulary_id,
    src.route_source_regvalue,

-------------------------------------------------------
--work
-------------------------------------------------------
    src.stem_source_table,
    src.stem_source_field,
    src.stem_source_rowid

FROM :working_schema.stem_source src
-- person_source_valueからperson_idを取得
LEFT JOIN :working_schema.person_f ps ON src.person_source_value = ps.person_source_value

-- provider_source_valueからprovider_idを取得
LEFT JOIN :working_schema.provider_f pr ON src.provider_source_value = pr.provider_source_value


-- source_valueからstandard conceptを取得
LEFT JOIN :working_schema.source_to_concept_map_f evt1 ON src.source_value = evt1.source_code
    AND src.source_vocabulary_id = evt1.source_vocabulary_id
    -- standard conceptのconceptを取得
    LEFT JOIN :working_schema.concept_f evt1c ON evt1.target_concept_id = evt1c.concept_id
-- source_valueからnon-standard conceptを取得
LEFT JOIN :working_schema.source_to_concept_map_f evt2 ON src.source_value = evt2.source_code
    AND src.source_secondary_vocabulary_id = evt2.source_vocabulary_id
    -- non-standard conceptのconceptを取得
    LEFT JOIN :working_schema.concept_f evt2c ON evt2.target_concept_id = evt2c.concept_id

-- type_categoryからstandard conceptを取得
LEFT JOIN :working_schema.source_to_concept_map_f et ON src.type_category = et.source_code
    AND et.source_vocabulary_id = 'RINCHU_EVENT_TYPE'

-- value_source_valueからstandard conceptを取得
LEFT JOIN :working_schema.source_to_concept_map_f val1 ON src.value_source_value = val1.source_code
    AND src.value_vocabulary_id = val1.source_vocabulary_id
    -- standard conceptのconceptを取得
    LEFT JOIN :working_schema.concept_f val1c ON val1.target_concept_id = val1c.concept_id
-- value_source_valueからnon-standard conceptを取得
LEFT JOIN :working_schema.source_to_concept_map_f val2 ON src.value_source_value = val2.source_code
    AND src.value_secondary_vocabulary_id = val2.source_vocabulary_id
    -- non-standard conceptのconceptを取得
    LEFT JOIN :working_schema.concept_f val2c ON val2.target_concept_id = val2c.concept_id
-- source_valueからstandard conceptを取得(病名コードのICD10 to Standard conceptでMaps to Valueが設定されているケースへの特別対応)
LEFT JOIN :working_schema.source_to_concept_map_f val3 ON src.source_value = val3.source_code
    AND src.value_vocabulary_id = val3.source_vocabulary_id
    -- standard conceptのconceptを取得
    LEFT JOIN :working_schema.concept_f val3c ON val3.target_concept_id = val3c.concept_id

-- unit_source_valueからstandard conceptを取得
LEFT JOIN :working_schema.source_to_concept_map_f unit1 ON src.unit_source_value = unit1.source_code
    AND src.unit_vocabulary_id = unit1.source_vocabulary_id
    -- standard conceptのconceptを取得
    LEFT JOIN :working_schema.concept_f unit1c ON unit1.target_concept_id = unit1c.concept_id
-- unit_source_valueからnon-standard conceptを取得
LEFT JOIN :working_schema.source_to_concept_map_f unit2 ON src.unit_source_value = unit2.source_code
    AND src.unit_secondary_vocabulary_id = unit2.source_vocabulary_id
    -- non-standard conceptのconceptを取得
    LEFT JOIN :working_schema.concept_f unit2c ON unit2.target_concept_id = unit2c.concept_id

-- qualifier_source_valueからstandard conceptを取得
LEFT JOIN :working_schema.source_to_concept_map_f qlf1 ON src.qualifier_source_value = qlf1.source_code
    AND src.qualifier_vocabulary_id = qlf1.source_vocabulary_id
    -- standard conceptのconceptを取得
    LEFT JOIN :working_schema.concept_f qlf1c ON qlf1.target_concept_id = qlf1c.concept_id
-- qualifier_source_valueからnon-standard conceptを取得
LEFT JOIN :working_schema.source_to_concept_map_f qlf2 ON src.qualifier_source_value = qlf2.source_code
    AND src.qualifier_secondary_vocabulary_id = qlf2.source_vocabulary_id
    -- non-standard conceptのconceptを取得
    LEFT JOIN :working_schema.concept_f qlf2c ON qlf2.target_concept_id = qlf2c.concept_id

-- operator_source_valueからstandard conceptを取得
LEFT JOIN :working_schema.source_to_concept_map_f op1 ON src.operator_source_value = op1.source_code
    AND src.operator_vocabulary_id = op1.source_vocabulary_id
    -- standard conceptのconceptを取得
    LEFT JOIN :working_schema.concept_f op1c ON op1.target_concept_id = op1c.concept_id
-- operator_source_valueからnon-standard conceptを取得
LEFT JOIN :working_schema.source_to_concept_map_f op2 ON src.operator_source_value = op2.source_code
    AND src.operator_secondary_vocabulary_id = op2.source_vocabulary_id
    -- non-standard conceptのconceptを取得
    LEFT JOIN :working_schema.concept_f op2c ON op2.target_concept_id = op2c.concept_id

-- anatomic_site_source_valueからstandard conceptを取得
LEFT JOIN :working_schema.source_to_concept_map_f as1 ON src.anatomic_site_source_value = as1.source_code
    AND src.anatomic_site_vocabulary_id = as1.source_vocabulary_id
    -- standard conceptのconceptを取得
    LEFT JOIN :working_schema.concept_f as1c ON as1.target_concept_id = as1c.concept_id
-- anatomic_site_source_valueからnon-standard conceptを取得
LEFT JOIN :working_schema.source_to_concept_map_f as2 ON src.anatomic_site_source_value = as2.source_code
    AND src.anatomic_site_secondary_vocabulary_id = as2.source_vocabulary_id
    -- non-standard conceptのconceptを取得
    LEFT JOIN :working_schema.concept_f as2c ON as2.target_concept_id = as2c.concept_id

-- status_source_valueからstandard conceptを取得
LEFT JOIN :working_schema.source_to_concept_map_f sts1 ON src.status_source_value = sts1.source_code
    AND src.status_vocabulary_id = sts1.source_vocabulary_id
    -- standard conceptのconceptを取得
    LEFT JOIN :working_schema.concept_f sts1c ON sts1.target_concept_id = sts1c.concept_id
-- status_source_valueからnon-standard conceptを取得
LEFT JOIN :working_schema.source_to_concept_map_f sts2 ON src.status_source_value = sts2.source_code
    AND src.status_secondary_vocabulary_id = sts2.source_vocabulary_id
    -- non-standard conceptのconceptを取得
    LEFT JOIN :working_schema.concept_f sts2c ON sts2.target_concept_id = sts2c.concept_id

-- modifier_source_valueからstandard conceptを取得
LEFT JOIN :working_schema.source_to_concept_map_f mdf1 ON src.modifier_source_value = mdf1.source_code
    AND src.modifier_vocabulary_id = mdf1.source_vocabulary_id
    -- standard conceptのconceptを取得
    LEFT JOIN :working_schema.concept_f mdf1c ON mdf1.target_concept_id = mdf1c.concept_id
-- modifier_source_valueからnon-standard conceptを取得
LEFT JOIN :working_schema.source_to_concept_map_f mdf2 ON src.modifier_source_value = mdf2.source_code
    AND src.modifier_secondary_vocabulary_id = mdf2.source_vocabulary_id
    -- non-standard conceptのconceptを取得
    LEFT JOIN :working_schema.concept_f mdf2c ON mdf2.target_concept_id = mdf2c.concept_id

-- route_source_valueからstandard conceptを取得
LEFT JOIN :working_schema.source_to_concept_map_f rot1 ON src.route_source_value = rot1.source_code
    AND src.route_vocabulary_id = rot1.source_vocabulary_id
    -- standard conceptのconceptを取得
    LEFT JOIN :working_schema.concept_f rot1c ON rot1.target_concept_id = rot1c.concept_id
-- route_source_valueからnon-standard conceptを取得
LEFT JOIN :working_schema.source_to_concept_map_f rot2 ON src.route_source_value = rot2.source_code
    AND src.route_secondary_vocabulary_id = rot2.source_vocabulary_id
    -- non-standard conceptのconceptを取得
    LEFT JOIN :working_schema.concept_f rot2c ON rot2.target_concept_id = rot2c.concept_id
)

-- 最終SELECT
SELECT
    -- 各レコードをどのdomainとして扱うかを決定する
    CASE
      -- 1. concept_idが0の場合はconceptの定義のdomainがMetaDataになってしまうので、データ作成元が指定したsource_domain_idを使用
        WHEN concept_id = 0 THEN source_domain_id
      --2. conceptにconcept_idが存在しない場合はdomain不明のため、データ作成元が指定したsource_domain_idを使用
        WHEN concept_domain_id IS NULL THEN source_domain_id
      --3. それ以外の場合(concept_idが正常に取得できた場合）はconceptに定義されたdomain_idを使用
        ELSE concept_domain_id
    END AS domain_id,
    *
FROM cte_mapped;

/*
SELECT * FROM :working_schema.v_stem LIMIT 100;
*/