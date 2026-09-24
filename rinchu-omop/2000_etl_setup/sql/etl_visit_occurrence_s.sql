\set ON_ERROR_STOP on
-----------------------------------------------
-- View: v_visit_occurrence_s
-- Purpose: Create source data from PatientVisit
-----------------------------------------------
CREATE OR REPLACE VIEW :working_schema.v_visit_occurrence_s AS 
WITH

-- 外来受診データ（cte_outpatient）
-- ADT^A04^ADT_A01のレコードをそのまま取得
-- 終了日時はNULLのまま（単発受診）

cte_outpatient AS (
    SELECT 
        patient_id AS person_source_value,
        pv_adtsegment AS visit_source_value,
		dept_cd_s AS provider_source_value,
        pv_admit_date AS visit_start_date,
        pv_admit_time AS visit_start_time,
        pv_admit_date AS visit_end_date,
        pv_admit_time AS visit_end_time,
		NULL AS discharged_to_source_value,
        pv_unique_id AS load_row_id,
        pv_unique_id AS parent_load_row_id  -- 外来受診は自レコードのpv_unique_id
    FROM :source_schema.patientvisit
    WHERE pv_adtsegment = 'ADT^A04^ADT_A01'
),

-- 退院データ抽出（cte_discharge）
-- ADT^A03^ADT_A03のレコードのみ抽出
cte_discharge AS (
    SELECT 
        pv_unique_id,
        patient_id,
        pv_discharge_date,
        pv_discharge_time,
        pv_discharge_cd_l
    FROM :source_schema.patientvisit
    WHERE pv_adtsegment = 'ADT^A03^ADT_A03'
    AND pv_discharge_date IS NOT NULL
),

-- 入院データ抽出（cte_admit）
-- ADT^A01^ADT_A01のレコードのみ抽出し、次の入院日を取得
cte_admit AS (
    SELECT 
        pv_unique_id,
        patient_id,
        pv_adtsegment,
        dept_cd_s,
        pv_admit_date,
        pv_admit_time,
        LEAD(pv_admit_date) OVER (PARTITION BY patient_id ORDER BY pv_unique_id) AS next_admit_date
    FROM :source_schema.patientvisit
    WHERE pv_adtsegment = 'ADT^A01^ADT_A01'
    AND pv_admit_date IS NOT NULL
),

-- 退院データにランク付け（cte_discharge_ranked）
-- 各入院に対応する退院を特定するため、pv_unique_idで昇順にランク付け
cte_discharge_ranked AS (
    SELECT 
        d.patient_id,
        d.pv_discharge_date,
        d.pv_discharge_time,
        d.pv_discharge_cd_l,
        a.pv_unique_id AS admit_unique_id,
        a.pv_admit_date,
        ROW_NUMBER() OVER (
            PARTITION BY a.pv_unique_id 
            ORDER BY d.pv_discharge_date ASC, d.pv_unique_id ASC
        ) AS rn
    FROM cte_admit a
    LEFT JOIN cte_discharge d
        ON a.patient_id = d.patient_id
        AND a.pv_admit_date <= d.pv_discharge_date
        AND (a.next_admit_date IS NULL OR d.pv_discharge_date < a.next_admit_date)
),

-- 入院データ（cte_inpatient）
-- 各入院に対応する最初の退院のみを選択
cte_inpatient AS (
    SELECT 
        a.patient_id AS person_source_value,
        a.pv_adtsegment AS visit_source_value,
		a.dept_cd_s AS provider_source_value,
        a.pv_admit_date AS visit_start_date,
        a.pv_admit_time AS visit_start_time,
        d.pv_discharge_date AS visit_end_date,
        d.pv_discharge_time AS visit_end_time,
		d.pv_discharge_cd_l AS discharged_to_source_value,
        a.pv_unique_id AS load_row_id,
        a.pv_unique_id AS parent_load_row_id
	FROM cte_admit a
    LEFT JOIN cte_discharge_ranked d
        ON a.pv_unique_id = d.admit_unique_id
        AND d.rn = 1
),

-- 転科データ（cte_transfer）
-- ADT^A02^ADT_A02のレコードをpv_event_occurred_dateを開始日として取得
-- 終了日時はNULLのまま（イベント記録）
cte_transfer AS (
    SELECT 
        t.patient_id AS person_source_value,
        t.pv_adtsegment AS visit_source_value,
		t.dept_cd_s AS provider_source_value,
        t.pv_event_occurred_date AS visit_start_date,
        t.pv_event_occurred_time AS visit_start_time,
        t.pv_event_occurred_date AS visit_end_date,
        t.pv_event_occurred_time AS visit_end_time,
		NULL AS discharged_to_source_value,
        t.pv_unique_id AS load_row_id,
        -- 転科日の直近の入院日を持つ入院データのpv_unique_idを取得
        (SELECT admit.pv_unique_id 
         FROM :source_schema.patientvisit admit
         WHERE admit.patient_id = t.patient_id
         AND admit.pv_adtsegment = 'ADT^A01^ADT_A01'
         AND admit.pv_admit_date IS NOT NULL
         AND admit.pv_admit_date <= t.pv_event_occurred_date
         ORDER BY admit.pv_admit_date DESC
         LIMIT 1
        ) AS parent_load_row_id
    FROM :source_schema.patientvisit t
    WHERE t.pv_adtsegment = 'ADT^A02^ADT_A02'
),

-- 外泊開始データ抽出（cte_leave_start）
cte_leave_start AS (
    SELECT 
        pv_unique_id,
        patient_id,
        pv_adtsegment,
        dept_cd_s,
        pv_event_occurred_date,
        pv_event_occurred_time
    FROM :source_schema.patientvisit
    WHERE pv_adtsegment = 'ADT^A21^ADT_A21'
),

-- 外泊終了データ抽出（cte_leave_end）
cte_leave_end AS (
    SELECT 
        pv_unique_id,
        patient_id,
        pv_event_occurred_date,
        pv_event_occurred_time
    FROM :source_schema.patientvisit
    WHERE pv_adtsegment = 'ADT^A22^ADT_A21'
),

-- 外泊終了データにランク付け（cte_leave_end_ranked）
-- 各外泊開始に対応する帰院を特定するため、pv_unique_idで昇順にランク付け
cte_leave_end_ranked AS (
    SELECT 
        ls.pv_unique_id AS leave_start_unique_id,
        le.pv_unique_id,
        le.pv_event_occurred_date,
        le.pv_event_occurred_time,
        ROW_NUMBER() OVER (
            PARTITION BY ls.pv_unique_id 
            ORDER BY le.pv_unique_id ASC
        ) AS rn
    FROM cte_leave_start ls
    LEFT JOIN cte_leave_end le
        ON ls.patient_id = le.patient_id
        AND ls.pv_event_occurred_date || ls.pv_event_occurred_time < le.pv_event_occurred_date || le.pv_event_occurred_time
),

-- 外泊データ（cte_leave）
-- 各外泊開始に対応する最初の帰院のみを選択
cte_leave AS (
    SELECT 
        ls.patient_id AS person_source_value,
        ls.pv_adtsegment AS visit_source_value,
		ls.dept_cd_s AS provider_source_value,
        ls.pv_event_occurred_date AS visit_start_date,
        ls.pv_event_occurred_time AS visit_start_time,
        ler.pv_event_occurred_date AS visit_end_date,
        ler.pv_event_occurred_time AS visit_end_time,
		NULL AS discharged_to_source_value,
        ls.pv_unique_id AS load_row_id,
        -- 外泊開始日の直近の入院日を持つ入院データのpv_unique_idを取得
        (SELECT admit.pv_unique_id 
         FROM :source_schema.patientvisit admit
         WHERE admit.patient_id = ls.patient_id
         AND admit.pv_adtsegment = 'ADT^A01^ADT_A01'
         AND admit.pv_admit_date IS NOT NULL
         AND admit.pv_admit_date <= ls.pv_event_occurred_date
         ORDER BY admit.pv_admit_date DESC
         LIMIT 1
        ) AS parent_load_row_id
    FROM cte_leave_start ls
    LEFT JOIN cte_leave_end_ranked ler
        ON ls.pv_unique_id = ler.leave_start_unique_id
        AND ler.rn = 1
),

-- 全データを統合
cte_union AS (
    SELECT * FROM cte_outpatient
    UNION ALL
    SELECT * FROM cte_inpatient
    UNION ALL  
    SELECT * FROM cte_transfer
    UNION ALL
    SELECT * FROM cte_leave
),

cte_final AS (
	SELECT 
		person_source_value,
		TO_DATE(visit_start_date, 'YYYYMMDD') AS visit_start_date,
		CASE
			WHEN visit_start_time = '999999' THEN TO_TIMESTAMP(visit_start_date || '000000','YYYYMMDDHH24MISS')
			ELSE TO_TIMESTAMP(visit_start_date || visit_start_time,'YYYYMMDDHH24MISS')
		END AS visit_start_datetime,
		CASE
			WHEN visit_end_date IS NULL THEN (TO_TIMESTAMP(visit_start_date || '000000','YYYYMMDDHH24MISS') + INTERVAL '13 days')::date
			ELSE TO_DATE(visit_end_date, 'YYYYMMDD')
		END AS visit_end_date,
		CASE
			WHEN visit_end_date IS NULL THEN TO_TIMESTAMP(visit_start_date || '000000','YYYYMMDDHH24MISS') + INTERVAL '13 days'
			WHEN visit_end_time IS NULL THEN TO_TIMESTAMP(visit_end_date || '000000','YYYYMMDDHH24MISS')
			WHEN visit_end_time = '999999' THEN TO_TIMESTAMP(visit_end_date || '000000','YYYYMMDDHH24MISS')
			ELSE TO_TIMESTAMP(visit_end_date || visit_end_time,'YYYYMMDDHH24MISS')
		END AS visit_end_datetime,
		0 AS visit_type_concept_id,
		provider_source_value,
		CAST(:care_site_source_value AS VARCHAR) AS care_site_source_value,
		visit_source_value,
		'RINCHU_VISIT' AS visit_source_vocabulary_id,
		'Visit' AS visit_source_domain_id,
/*
        CASE 
            WHEN visit_source_value = 'ADT^A04^ADT_A01' THEN visit_source_value || '|外来診察の受付'
            WHEN visit_source_value = 'ADT^A01^ADT_A01' THEN visit_source_value || '|入院実施'
            WHEN visit_source_value = 'ADT^A03^ADT_A03' THEN visit_source_value || '|退院実施'
            WHEN visit_source_value = 'ADT^A02^ADT_A02' THEN visit_source_value || '|転科・転棟実施'
            WHEN visit_source_value = 'ADT^A21^ADT_A21' THEN visit_source_value || '|外出泊実施'
            WHEN visit_source_value = 'ADT^A22^ADT_A21' THEN visit_source_value || '|外出泊帰院実施'
            ELSE visit_source_value
        END AS visit_source_regvalue,
*/
        visit_source_value AS visit_source_regvalue,
		NULL AS admitted_from_source_value,
		NULL AS admitted_from_vocabulary_id,
		NULL AS admitted_from_domain_id,
		discharged_to_source_value,
		'RINCHU_VISIT' AS discharged_to_vocabulary_id,
		'Visit' AS discharged_to_domain_id,
		NULL::integer AS preceding_visit_occurrence_id,
		ROW_NUMBER() OVER (PARTITION BY person_source_value, parent_load_row_id ORDER BY visit_start_date, visit_start_time, load_row_id) AS rownum,
		'PatientVisit' AS table_name,
		'pv_adtsegment' AS column_name,
		load_row_id,
		parent_load_row_id
	FROM cte_union
)

SELECT * FROM cte_final 
ORDER BY person_source_value, visit_start_date, visit_start_datetime;

--- テストクエリ
--SELECT COUNT(1) FROM :working_schema.v_visit_occurrence_s;
--SELECT * FROM :working_schema.v_visit_occurrence_s LIMIT 100;

--- データ生成
--TRUNCATE TABLE :working_schema.visit_occurrence_s;
--INSERT INTO :working_schema.visit_occurrence_s SELECT * FROM :working_schema.v_visit_occurrence_s;
