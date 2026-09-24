## Table name: measurement

### Reading from observationresult

ターゲットテーブル:measurement
<br>・当テーブルは&nbsp;PatientDisease、ObservationResult、PrescriptionData、InjectionData&nbsp;からデータが登録される。
<br>・各テーブルの&nbsp;病名、検査値、薬剤名などを&nbsp;ATHENA&nbsp;Vocabularyを介したstandard&nbsp;conceptへの変換後、standard&nbsp;conceptのdomainが&nbsp;"Measurement"&nbsp;で定義されているデータが格納される。
<br>
<br>本項では、ObservationResultをもとに生成された、device_exposureテーブルの各項目のとの出力結果の対応を記載する。
<br>・concept変換元のソースコードは標準検査項目コードとし、臨中ネット様が作成予定のマッピングテーブルを介したstandard&nbsp;conceptへの変換を行う。
<br>

![](md_files/image16.png)

| Destination Field | Source field | Logic | Comment field |
| --- | --- | --- | --- |
| measurement_id |  |  | 一意の連番を設定する |
| person_id | patient_id |  | person.person_source_valueと結合してperson_idを取得・登録する<br> |
| measurement_concept_id | obx_cd_s | measurement_concept_idに変換  <br>Source_to_concept_map:  <br>VocabID:RINCHU_OBX_CD  <br>DomainID:Measurement | 標準検査コード(JLAC11)をsource_to_concept_mapを介してSNOMED,LOINC他のStandard&nbsp;Vocabularyに変換する<br> |
| measurement_date | spm_collect_date |  | 検体採取日をそのまま登録する<br> |
| measurement_datetime | spm_collect_date<br>spm_collect_time | CASE  <br>&nbsp;&nbsp;WHEN&nbsp;spm_collect_time&nbsp;=&nbsp;'999999'&nbsp;  <br>&nbsp;&nbsp;&nbsp;&nbsp;OR&nbsp;spm_collect_time&nbsp;IS&nbsp;NULL&nbsp;  <br>&nbsp;&nbsp;&nbsp;&nbsp;OR&nbsp;spm_collect_time&nbsp;~&nbsp;'^[0-9]{6}\$'&nbsp;=&nbsp;false&nbsp;  <br>&nbsp;&nbsp;&nbsp;&nbsp;OR&nbsp;SUBSTRING(spm_collect_time,&nbsp;1,&nbsp;2)::integer&nbsp;>=&nbsp;24&nbsp;  <br>&nbsp;&nbsp;&nbsp;&nbsp;OR&nbsp;SUBSTRING(spm_collect_time,&nbsp;3,&nbsp;2)::integer&nbsp;>=&nbsp;60&nbsp;  <br>&nbsp;&nbsp;&nbsp;&nbsp;OR&nbsp;SUBSTRING(spm_collect_time,&nbsp;5,&nbsp;2)::integer&nbsp;>=&nbsp;60&nbsp;  <br>&nbsp;&nbsp;THEN&nbsp;TO_TIMESTAMP(spm_collect_date&nbsp;\|\|&nbsp;'000000','YYYYMMDDHH24MISS')  <br>&nbsp;&nbsp;ELSE&nbsp;TO_TIMESTAMP(spm_collect_date&nbsp;\|\|&nbsp;spm_collect_time,'YYYYMMDDHH24MISS')  <br>END&nbsp;AS&nbsp;start_datetime<br> | 検体採取日＋検体採取時刻を登録する<br><br>（patientdisease&nbsp;が元テーブルの場合、設定しない） |
| measurement_time | spm_collect_time | CASE  <br>&nbsp;&nbsp;WHEN&nbsp;spm_collect_time&nbsp;=&nbsp;'999999'&nbsp;  <br>&nbsp;&nbsp;&nbsp;&nbsp;OR&nbsp;spm_collect_time&nbsp;IS&nbsp;NULL&nbsp;  <br>&nbsp;&nbsp;&nbsp;&nbsp;OR&nbsp;spm_collect_time&nbsp;~&nbsp;'^[0-9]{6}\$'&nbsp;=&nbsp;false&nbsp;  <br>&nbsp;&nbsp;&nbsp;&nbsp;OR&nbsp;SUBSTRING(spm_collect_time,&nbsp;1,&nbsp;2)::integer&nbsp;>=&nbsp;24&nbsp;  <br>&nbsp;&nbsp;&nbsp;&nbsp;OR&nbsp;SUBSTRING(spm_collect_time,&nbsp;3,&nbsp;2)::integer&nbsp;>=&nbsp;60&nbsp;  <br>&nbsp;&nbsp;&nbsp;&nbsp;OR&nbsp;SUBSTRING(spm_collect_time,&nbsp;5,&nbsp;2)::integer&nbsp;>=&nbsp;60&nbsp;  <br>&nbsp;&nbsp;THEN&nbsp;'00:00:00'::time  <br>&nbsp;&nbsp;ELSE&nbsp;TO_TIMESTAMP(spm_collect_time,'HH24MISS')::time  <br>END&nbsp;AS&nbsp;start_time | 検体採取時刻をそのまま登録する<br>（patientdisease&nbsp;が元テーブルの場合、設定しない） |
| measurement_type_concept_id |  |  | 32817（EHR）固定とする |
| operator_concept_id | obx_value_l | "Source_to_concept_map:  <br>VocabID:RINCHU_OBX_OPERATOR  <br>DomainID:Meas&nbsp;Value&nbsp;Operator"  <br>  <br>検査結果値に含まれる当符号の抽出ロジックは以下  <br>  <br>CASE&nbsp;  <br>&nbsp;&nbsp;--&nbsp;定性マーカーを抽出  <br>&nbsp;&nbsp;WHEN&nbsp;obx_value_l&nbsp;~&nbsp;'\([+\-±]+\)'&nbsp;THEN&nbsp;  <br>&nbsp;&nbsp;&nbsp;&nbsp;(regexp_match(obx_value_l,&nbsp;'(\([+\-±]+\))'))[1]  <br>  <br>&nbsp;&nbsp;--&nbsp;純粋な数値の場合はNULL  <br>&nbsp;&nbsp;WHEN&nbsp;obx_value_l&nbsp;~&nbsp;'^[+-]?[0-9]*\.?[0-9]+([eE][+-]?[0-9]+)?\$'&nbsp;THEN&nbsp;  <br>&nbsp;&nbsp;&nbsp;&nbsp;NULL  <br>  <br>&nbsp;&nbsp;--&nbsp;演算子+数値のみの場合はNULL（例:&nbsp;<40,&nbsp;>=5.0,&nbsp;<=25）  <br>&nbsp;&nbsp;WHEN&nbsp;obx_value_l&nbsp;~&nbsp;'^(<\|>\|<=\|>=\|≤\|≥\|≧\|＜\|＞)\s*[0-9]+\.?[0-9]*\$'&nbsp;THEN&nbsp;  <br>&nbsp;&nbsp;&nbsp;&nbsp;NULL  <br>  <br>&nbsp;&nbsp;ELSE&nbsp;  <br>&nbsp;&nbsp;&nbsp;&nbsp;--&nbsp;その他の非数値データ：演算子記号（記号・日本語）を除去した値を返す  <br>&nbsp;&nbsp;&nbsp;&nbsp;--&nbsp;ただし、除去後に純粋な数値になる場合はNULLを返す（例:&nbsp;600.0<,&nbsp;180.0以上）  <br>&nbsp;&nbsp;&nbsp;&nbsp;CASE  <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;WHEN&nbsp;TRIM(  <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;regexp_replace(  <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;obx_value_l,&nbsp;  <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'(<\|>\|<=\|>=\|≤\|≥\|≧\|＜\|＞\|以上\|以下\|未満\|ｲｼﾞｮｳ\|ｲｶ\|ﾐﾏﾝ)',&nbsp;  <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'',&nbsp;  <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'g'  <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;)  <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;)&nbsp;~&nbsp;'^[+-]?[0-9]*\.?[0-9]+([eE][+-]?[0-9]+)?\$'&nbsp;THEN  <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;NULL  <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ELSE  <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;regexp_replace(  <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;obx_value_l,&nbsp;  <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'(<\|>\|<=\|>=\|≤\|≥\|≧\|＜\|＞\|以上\|以下\|未満\|ｲｼﾞｮｳ\|ｲｶ\|ﾐﾏﾝ)',&nbsp;  <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'',&nbsp;  <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'g'  <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;)  <br>&nbsp;&nbsp;&nbsp;&nbsp;END  <br>END&nbsp;AS&nbsp;value_source_value  <br> | 検査結果値に含まれる当符号を抽出し、source_to_concept_mapを介してStandard&nbsp;Vocabularyに変換する<br>（patientdisease&nbsp;が元テーブルの場合、設定しない） |
| value_as_number | sch_obx_value_s<br>sch_obx_value_l | CASE  <br>&nbsp;&nbsp;WHEN&nbsp;sch_obx_value_s&nbsp;IS&nbsp;NOT&nbsp;NULL&nbsp;THEN&nbsp;sch_obx_value_s  <br>  <br>&nbsp;&nbsp;--&nbsp;sch_obx_value_sがNULLの場合、obx_value_lから等符号を除去した数値を抽出して登録  <br>&nbsp;&nbsp;WHEN&nbsp;obx_value_l&nbsp;IS&nbsp;NOT&nbsp;NULL&nbsp;THEN  <br>&nbsp;&nbsp;&nbsp;&nbsp;CASE  <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;--&nbsp;不等号（記号・日本語）を除去して数値を抽出  <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;WHEN&nbsp;TRIM(  <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;regexp_replace(  <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;obx_value_l,  <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'(<\|>\|<=\|>=\|≤\|≥\|≧\|＜\|＞\|以上\|以下\|未満\|ｲｼﾞｮｳ\|ｲｶ\|ﾐﾏﾝ)',  <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'',  <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'g'  <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;)  <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;)&nbsp;~&nbsp;'^[+-]?[0-9]*\.?[0-9]+([eE][+-]?[0-9]+)?\$'  <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;THEN&nbsp;TRIM(  <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;regexp_replace(  <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;obx_value_l,  <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'(<\|>\|<=\|>=\|≤\|≥\|≧\|＜\|＞\|以上\|以下\|未満\|ｲｼﾞｮｳ\|ｲｶ\|ﾐﾏﾝ)',  <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'',  <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'g'  <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;)  <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;)::numeric  <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ELSE&nbsp;NULL  <br>&nbsp;&nbsp;&nbsp;&nbsp;END  <br>  <br>&nbsp;&nbsp;ELSE&nbsp;NULL  <br>END&nbsp;AS&nbsp;value_as_number  <br><br> | 標準単位換算値（数値型）をそのまま登録する<br><br>（patientdisease&nbsp;が元テーブルの場合、設定しない） |
| value_as_concept_id | sch_obx_value_l | Source_to_concept_map:  <br>VocabID:RINCHU_OBX_VALUE  <br>DomainID:Meas&nbsp;Value | 検査結果値をsource_to_concept_mapを介してStandard&nbsp;Vocabularyに変換する<br>（patientdisease&nbsp;が元テーブルの場合、設定しない） |
| unit_concept_id | obx_unit_s | Source_to_concept_map:  <br>VocabID:RINCHU_OBX_UNIT  <br>DomainID:Unit | 標準単位をsource_to_concept_mapを介してStandard&nbsp;Vocabularyに変換する<br>（patientdisease&nbsp;が元テーブルの場合、設定しない） |
| range_low | obx_range_low_l | CASE&nbsp;  <br>&nbsp;&nbsp;WHEN&nbsp;obx_range_low_l&nbsp;~&nbsp;'^[+-]?[0-9]*\.?[0-9]+([eE][+-]?[0-9]+)?\$'&nbsp;  <br>&nbsp;&nbsp;THEN&nbsp;obx_range_low_l::numeric  <br>&nbsp;&nbsp;ELSE&nbsp;NULL&nbsp;  <br>END&nbsp;AS&nbsp;range_low | 正常値下限をそのまま登録する<br>（patientdisease&nbsp;が元テーブルの場合、設定しない） |
| range_high | obx_range_high_l | CASE&nbsp;  <br>&nbsp;&nbsp;WHEN&nbsp;obx_range_high_l&nbsp;~&nbsp;'^[+-]?[0-9]*\.?[0-9]+([eE][+-]?[0-9]+)?\$'&nbsp;  <br>&nbsp;&nbsp;THEN&nbsp;obx_range_high_l::numeric  <br>&nbsp;&nbsp;ELSE&nbsp;NULL&nbsp;  <br>END&nbsp;AS&nbsp;range_high | 正常値上限をそのまま登録する<br>（patientdisease&nbsp;が元テーブルの場合、設定しない） |
| provider_id | dept_cd_s |  | 当該標準診療科コードを示すprovider_idを取得して登録する<br> |
| visit_occurrence_id |  |  | （設定しない） |
| visit_detail_id |  |  | （設定しない） |
| measurement_source_value | obx_cd_s<br>obx_name_s<br>obx_name_l | COALESCE(obx_cd_s,&nbsp;'')&nbsp;\|\|&nbsp;'\|'&nbsp;\|\|&nbsp;COALESCE(obx_name_s,&nbsp;'')&nbsp;\|\|&nbsp;'\|'&nbsp;\|\|&nbsp;COALESCE(obx_name_l,&nbsp;'')&nbsp;\|\|&nbsp;'\|'&nbsp;\|\|&nbsp;COALESCE(spm_cd_s,&nbsp;'')&nbsp;\|\|&nbsp;'\|'&nbsp;\|\|&nbsp;COALESCE(spm_name_s,&nbsp;'')&nbsp;AS&nbsp;source_regvalue<br><br> | 検査項目標準コード\|検査項目標準名称\|材料標準コード\|材料標準名称の形式に編集して判読可能な値として登録する<br><br><br>検査項目標準コード\|検査項目標準名称の形式に編集して判読可能な値として登録する  <br>(patientdiseaseの場合、ICD10コード\|病名管理番号\|病名表記) |
| measurement_source_concept_id | obx_cd_s | measurement_concept_idに変換  <br>Source_to_concept_map:  <br>VocabID:RINCHU_OBX_CD  <br>DomainID:Measurement | source_to_concept_mapから検査項目標準コード(JLAC11)のsource_concept_idを取得しセットする<br> |
| unit_source_value | obx_unit_s |  | 取得元データの単位を登録する。<br>（patientdisease&nbsp;が元テーブルの場合、設定しない） |
| unit_source_concept_id | obx_unit_s | Source_to_concept_map:  <br>VocabID:RINCHU_OBX_UNIT  <br>DomainID:Unit | 標準単位をsource_to_concept_mapを介してsource_concept_idに変換する<br>（patientdisease&nbsp;が元テーブルの場合、設定しない） |
| value_source_value | sch_obx_value_s |  | 検査結果値そのままを登録する。<br>（patientdisease&nbsp;が元テーブルの場合、設定しない） |
| measurement_event_id |  |  | （設定しない） |
| meas_event_field_concept_id |  |  | （設定しない） |

### Reading from patientdisease

本項では、PasientDiseaseをもとに生成された、device_exposureテーブルの各項目のとの出力結果の対応を記載する。
<br>　例：「ICD10&nbsp;/&nbsp;R70.1:血漿粘（稠）度異常&nbsp;(2)」&nbsp;→&nbsp;「OMOP&nbsp;コンセプト&nbsp;ID&nbsp;/&nbsp;4246053:&nbsp;Elevated&nbsp;erythrocyte&nbsp;sedimentation&nbsp;rate&nbsp;and&nbsp;abnormality&nbsp;of&nbsp;plasma&nbsp;viscosity」
<br>

![](md_files/image17.png)

| Destination Field | Source field | Logic | Comment field |
| --- | --- | --- | --- |
| measurement_id |  |  | 一意の連番を設定する |
| person_id | patient_id |  | person.person_source_valueと結合してperson_idを取得・登録する<br> |
| measurement_concept_id | icd10_cd | Source_to_concept_map:  <br>VocabID:RINCHU_DIAGCD,&nbsp;ATHENA_ICD10  <br>DomainID:Measurement  <br> | （patientdiseaseの場合、ICD-10コードをAthenaのStandard&nbsp;Vocabularyに変換する）<br> |
| measurement_date | sch_dis_start_date |  | 病名開始日をそのまま登録する<br> |
| measurement_datetime |  |  | （patientdisease&nbsp;が元テーブルの場合、設定しない） |
| measurement_time |  |  | （patientdisease&nbsp;が元テーブルの場合、設定しない） |
| measurement_type_concept_id |  |  | 32817（EHR）固定とする |
| operator_concept_id |  |  | （patientdisease&nbsp;が元テーブルの場合、設定しない） |
| value_as_number |  |  | （patientdisease&nbsp;が元テーブルの場合、設定しない） |
| value_as_concept_id |  |  | （patientdisease&nbsp;が元テーブルの場合、設定しない） |
| unit_concept_id |  |  | （patientdisease&nbsp;が元テーブルの場合、設定しない） |
| range_low |  |  | （patientdisease&nbsp;が元テーブルの場合、設定しない） |
| range_high |  |  | （patientdisease&nbsp;が元テーブルの場合、設定しない） |
| provider_id | dept_cd_s |  | 当該標準診療科コードを示すprovider_idを取得して登録する<br> |
| visit_occurrence_id |  |  | （設定しない） |
| visit_detail_id |  |  | （設定しない） |
| measurement_source_value | dis_management_cd<br>icd10_cd<br>dis_name | COALESCE(icd10_cd,&nbsp;'')&nbsp;\|\|&nbsp;'\|'&nbsp;\|\|&nbsp;COALESCE(dis_management_cd,&nbsp;'')&nbsp;\|\|&nbsp;'\|'&nbsp;\|\|&nbsp;COALESCE(dis_name,&nbsp;'')<br> | ICD10コード\|病名管理番号\|病名表記の形式に編集して判読可能な値として登録する<br><br>検査項目標準コード\|検査項目標準名称の形式に編集して判読可能な値として登録する  <br>(patientdiseaseの場合、ICD10コード\|病名管理番号\|病名表記) |
| measurement_source_concept_id | dis_management_cd | Source_to_concept_map:  <br>VocabID:RINCHU_DIAGCD,&nbsp;ATHENA_ICD10  <br>DomainID:Measurement | source_to_concept_mapから標準コード(ICD10)のsource_concept_idを取得しセットする  <br><br> |
| unit_source_value |  |  | （patientdisease&nbsp;が元テーブルの場合、設定しない） |
| unit_source_concept_id |  |  | （patientdisease&nbsp;が元テーブルの場合、設定しない） |
| value_source_value |  |  | （patientdisease&nbsp;が元テーブルの場合、設定しない） |
| measurement_event_id |  |  | （設定しない） |
| meas_event_field_concept_id |  |  | （設定しない） |

