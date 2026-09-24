# Appendix: source tables

### Table: patientidentification

| Field | Type | Most freq. value | Comment |
| --- | --- | --- | --- |
| pi_unique_id | integer |  |  |
| patient_id | character varying |  |  |
| sex | character varying |  |  |
| birthdate | character varying |  |  |
| sch_birthdate | date |  |  |
| race | text |  |  |
| ethnic_group | text |  |  |
| data_update_date | character varying |  |  |
| ts_table_update | timestamp without time zone |  |  |

### Table: patientaddress

| Field | Type | Most freq. value | Comment |
| --- | --- | --- | --- |
| pa_unique_id | integer |  |  |
| patient_id | character varying |  |  |
| pa_start_date | character varying |  |  |
| pa_end_date | character varying |  |  |
| postal_cd | character varying |  |  |
| data_update_date | character varying |  |  |
| ts_table_update | timestamp without time zone |  |  |

### Table: patientvisit

| Field | Type | Most freq. value | Comment |
| --- | --- | --- | --- |
| pv_unique_id | integer |  |  |
| patient_id | character varying |  |  |
| pv_adtsegment | text |  |  |
| pv_event_occurred_date | character varying |  |  |
| pv_event_occurred_time | character varying |  |  |
| pv_admit_date | character varying |  |  |
| pv_admit_time | character varying |  |  |
| dept_cd_l | text |  |  |
| pv_discharge_date | character varying |  |  |
| pv_discharge_time | character varying |  |  |
| dept_cd_s | character varying |  |  |
| pv_discharge_cd_l | text |  |  |
| pv_datetime | character varying |  |  |
| sch_pv_admit_date | date |  |  |
| sch_pv_discharge_date | date |  |  |
| sch_pv_event_occurred_date | date |  |  |
| pv_admit_age | integer |  |  |
| pv_admit_months | integer |  |  |
| pv_admit_days | integer |  |  |
| data_update_date | character varying |  |  |
| ts_table_update | timestamp without time zone |  |  |

### Table: prescriptiondata

| Field | Type | Most freq. value | Comment |
| --- | --- | --- | --- |
| pres_unique_id | integer |  |  |
| patient_id | character varying |  |  |
| dept_cd_s | character varying |  |  |
| dept_cd_l | text |  |  |
| dept_name_l | text |  |  |
| placer_order_no | character varying |  |  |
| rp_no | character varying |  |  |
| pres_route | text |  |  |
| pres_site | text |  |  |
| pres_classification | text |  |  |
| pres_administration_type | text |  |  |
| pres_start_date | character varying |  |  |
| pres_end_date | character varying |  |  |
| sch_pres_start_date | date |  |  |
| sch_pres_end_date | date |  |  |
| pres_medicine_cd_yj | character varying |  |  |
| sch_pres_medicine_cd_yj4 | character varying |  |  |
| sch_pres_medicine_cd_yj7 | character varying |  |  |
| pres_medicine_cd_hot | character varying |  |  |
| sch_pres_medicine_cd_hot7 | character varying |  |  |
| sch_pres_medicine_cd_hot9 | character varying |  |  |
| pres_medicine_cd_l | text |  |  |
| pres_medicine_name_l | text |  |  |
| pres_dosage_min | real |  |  |
| pres_dosage_max | real |  |  |
| pres_dosage_unit_cd_s | character varying |  |  |
| pres_dosage_unit_cd_l | text |  |  |
| pres_dosage_unit_name_l | text |  |  |
| pres_dispense_amount | real |  |  |
| pres_dispense_unit_cd_s | character varying |  |  |
| pres_dispense_unit_cd_l | character varying |  |  |
| pres_dispense_unit_name_l | text |  |  |
| pres_total_quantity | real |  |  |
| pres_total_unit_cd_s | character varying |  |  |
| pres_total_unit_cd_l | text |  |  |
| pres_total_unit_name_l | text |  |  |
| pres_actual_days | integer |  |  |
| pres_administration_cd_s | character varying |  |  |
| pres_administration_name_s | text |  |  |
| pres_administration_cd_l | text |  |  |
| pres_administration_name_l | text |  |  |
| pres_supplement_cd_s | character varying |  |  |
| pres_supplement_name_s | text |  |  |
| pres_supplement_cd_l | text |  |  |
| pres_supplement_name_l | text |  |  |
| pres_rp_comment | text |  |  |
| pres_instructions_cd | text |  |  |
| pres_instructions_name | text |  |  |
| pres_start_age | integer |  |  |
| pres_period | integer |  |  |
| pres_start_months | integer |  |  |
| pres_start_days | integer |  |  |
| data_update_date | character varying |  |  |
| ts_table_update | timestamp without time zone |  |  |

### Table: injectiondata

| Field | Type | Most freq. value | Comment |
| --- | --- | --- | --- |
| inj_unique_id | integer |  |  |
| patient_id | character varying |  |  |
| dept_cd_s | character varying |  |  |
| dept_cd_l | text |  |  |
| dept_name_l | text |  |  |
| placer_order_no | character varying |  |  |
| rp_no | character varying |  |  |
| inj_route | text |  |  |
| inj_start_date | character varying |  |  |
| inj_administrative_method | text |  |  |
| inj_start_time | character varying |  |  |
| inj_end_date | character varying |  |  |
| inj_end_time | character varying |  |  |
| sch_inj_start_date | date |  |  |
| sch_inj_end_date | date |  |  |
| inj_medicine_cd_yj | character varying |  |  |
| sch_inj_medicine_cd_yj4 | character varying |  |  |
| sch_inj_medicine_cd_yj7 | character varying |  |  |
| inj_medicine_cd_hot | character varying |  |  |
| sch_inj_medicine_cd_hot7 | character varying |  |  |
| sch_inj_medicine_cd_hot9 | character varying |  |  |
| inj_medicine_cd_l | text |  |  |
| inj_medicine_name_l | text |  |  |
| inj_administered_amount | real |  |  |
| inj_dosage_unit_cd_s | character varying |  |  |
| inj_administered_unit_cd_l | text |  |  |
| inj_administered_unit_name_l | text |  |  |
| inj_administration_notes | text |  |  |
| inj_administered_per | text |  |  |
| inj_indication | text |  |  |
| inj_completion_status | character varying |  |  |
| inj_start_age | integer |  |  |
| inj_start_months | integer |  |  |
| inj_start_days | integer |  |  |
| data_update_date | character varying |  |  |
| ts_table_update | timestamp without time zone |  |  |

### Table: observationresult

| Field | Type | Most freq. value | Comment |
| --- | --- | --- | --- |
| obx_unique_id | integer |  |  |
| patient_id | character varying |  |  |
| dept_cd_s | character varying |  |  |
| dept_cd_l | text |  |  |
| dept_name_l | text |  |  |
| placer_order_no | character varying |  |  |
| filler_order_no | character varying |  |  |
| spm_id | character varying |  |  |
| obx_set_id | character varying |  |  |
| obx_sub_id | character varying |  |  |
| spm_collect_date | character varying |  |  |
| spm_collect_time | character varying |  |  |
| sch_spm_collect_date | date |  |  |
| obx_cd_s | character varying |  |  |
| obx_name_s | text |  |  |
| obx_cd_l | character varying |  |  |
| obx_name_l | text |  |  |
| spm_cd_s | character varying |  |  |
| spm_name_s | text |  |  |
| spm_cd_l | character varying |  |  |
| spm_name_l | text |  |  |
| obx_value_l | text |  |  |
| sch_obx_value_l | real |  |  |
| obx_unit_l | character varying |  |  |
| sch_obx_value_s | real |  |  |
| obx_unit_s | character varying |  |  |
| obx_range_text_l | text |  |  |
| obx_range_high_l | character varying |  |  |
| obx_range_low_l | character varying |  |  |
| obx_abnormal_cd | character varying |  |  |
| obx_result_status_cd | character varying |  |  |
| obx_result_comment | text |  |  |
| spm_collect_age | integer |  |  |
| spm_collect_months | integer |  |  |
| spm_collect_days | integer |  |  |
| data_update_date | character varying |  |  |
| ts_table_update | timestamp without time zone |  |  |

### Table: patientdisease

| Field | Type | Most freq. value | Comment |
| --- | --- | --- | --- |
| dis_unique_id | integer |  |  |
| patient_id | character varying |  |  |
| icd10_cd | character varying |  |  |
| dis_start_date | character varying |  |  |
| dis_end_date | character varying |  |  |
| dis_classification_cd | character varying |  |  |
| dis_suspect_cd | character varying |  |  |
| dept_cd_s | character varying |  |  |
| dept_cd_l | text |  |  |
| dept_name_l | text |  |  |
| dis_outcome_cd | character varying |  |  |
| dis_instance_id | character varying |  |  |
| dis_management_cd | character varying |  |  |
| dis_name | text |  |  |
| dis_exchange_cd | character varying |  |  |
| dis_cd | character varying |  |  |
| dis_prefix_cd | text |  |  |
| dis_suffix_cd | text |  |  |
| dis_established_date | character varying |  |  |
| dis_outcome_date | character varying |  |  |
| sch_dis_start_date | date |  |  |
| sch_dis_established_date | date |  |  |
| sch_dis_end_date | date |  |  |
| sch_dis_outcome_date | date |  |  |
| dis_start_age | integer |  |  |
| dis_start_months | integer |  |  |
| dis_start_days | integer |  |  |
| dis_established_age | integer |  |  |
| dis_established_months | integer |  |  |
| dis_established_days | integer |  |  |
| data_update_date | character varying |  |  |
| ts_table_update | timestamp without time zone |  |  |

### Table: mst_medis_byomei

| Field | Type | Most freq. value | Comment |
| --- | --- | --- | --- |
| chgkbn | character |  |  |
| kanrino | character varying |  |  |
| byomeiname | character varying |  |  |
| byomeiname_kana | character varying |  |  |
| saitakukbn | character |  |  |
| exchangecd | character varying |  |  |
| icd10_2013 | character varying |  |  |
| icd10_2013_sub | character varying |  |  |
| yobi1 | character varying |  |  |
| yobi2 | character varying |  |  |
| rcptcd | character varying |  |  |
| byomeinamer | character varying |  |  |
| siyoubunya | character |  |  |
| rirekino | character varying |  |  |
| chgdate | character varying |  |  |
| iko_kanrino | character varying |  |  |
| tankinshikbn | character varying |  |  |
| hokengaikbn | character |  |  |
| yobi3 | character varying |  |  |
| yobi4 | character varying |  |  |

### Table: mst_medis_hot13

| Field | Type | Most freq. value | Comment |
| --- | --- | --- | --- |
| 基準番号 | character |  |  |
| 処方用番号 | character |  |  |
| 会社識別番号 | character |  |  |
| 調剤用番号 | character |  |  |
| 物流用番号 | character |  |  |
| ｊａｎコード | character |  |  |
| 薬価基準収載医薬品コード | character |  |  |
| 個別医薬品コード | character |  |  |
| レセプト電算処理システムコード１ | character |  |  |
| レセプト電算処理システムコード２ | character |  |  |
| 告示名称 | character varying |  |  |
| 販売名 | character varying |  |  |
| レセプト電算処理システム医薬品名 | character varying |  |  |
| 規格単位 | character varying |  |  |
| 包装形態 | character varying |  |  |
| 包装単位数 | character |  |  |
| 包装単位単位 | character varying |  |  |
| 包装総量数 | character |  |  |
| 包装総量単位 | character varying |  |  |
| 区分 | character varying |  |  |
| 製造会社 | character varying |  |  |
| 販売会社 | character varying |  |  |
| レコード区分 | character |  |  |
| 更新年月日 | character |  |  |

### Table: mst_zipcode

| Field | Type | Most freq. value | Comment |
| --- | --- | --- | --- |
| jiscode | character varying |  |  |
| zipcode_old | character |  |  |
| zipcode | character |  |  |
| prefecture_kana | character varying |  |  |
| city_kana | character varying |  |  |
| street_kana | character varying |  |  |
| prefecture | character varying |  |  |
| city | character varying |  |  |
| street | character varying |  |  |
| flag1 | smallint |  |  |
| flag2 | smallint |  |  |
| flag3 | smallint |  |  |
| flag4 | smallint |  |  |
| flag5 | smallint |  |  |
| flag6 | smallint |  |  |

