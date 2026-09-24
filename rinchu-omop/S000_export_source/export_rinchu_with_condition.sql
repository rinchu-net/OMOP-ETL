\echo ==== C50の病名を持つ患者に限定してデータ抽出します ====
\echo ==== PatientIdentification ====
\COPY (SELECT * FROM @schema.patientidentification WHERE PATIENT_ID IN (SELECT PATIENT_ID FROM @schema.patientdisease WHERE ICD10_CD LIKE 'C50%')) TO 'dat/PatientIdentification.csv' WITH CSV HEADER;
\echo ==== PatientAddress ====
\COPY (SELECT * FROM @schema.patientaddress WHERE PATIENT_ID IN (SELECT PATIENT_ID FROM @schema.patientdisease WHERE ICD10_CD LIKE 'C50%')) TO 'dat/PatientAddress.csv' WITH CSV HEADER;
\echo ==== PatientVisit ====
\COPY (SELECT * FROM @schema.patientvisit WHERE PATIENT_ID IN (SELECT PATIENT_ID FROM @schema.patientdisease WHERE ICD10_CD LIKE 'C50%')) TO 'dat/PatientVisit.csv' WITH CSV HEADER;
\echo ==== PatientDisease ====
\COPY (SELECT * FROM @schema.patientdisease WHERE PATIENT_ID IN (SELECT PATIENT_ID FROM @schema.patientdisease WHERE ICD10_CD LIKE 'C50%')) TO 'dat/PatientDisease.csv' WITH CSV HEADER;
\echo ==== ObservationResult ====
\COPY (SELECT * FROM @schema.observationresult WHERE PATIENT_ID IN (SELECT PATIENT_ID FROM @schema.patientdisease WHERE ICD10_CD LIKE 'C50%')) TO 'dat/ObservationResult.csv' WITH CSV HEADER;
\echo ==== PrescriptionData ====
\COPY (SELECT * FROM @schema.prescriptiondata WHERE PATIENT_ID IN (SELECT PATIENT_ID FROM @schema.patientdisease WHERE ICD10_CD LIKE 'C50%')) TO 'dat/PrescriptionData.csv' WITH CSV HEADER;
\echo ==== InjectionData ====
\COPY (SELECT * FROM @schema.injectiondata WHERE PATIENT_ID IN (SELECT PATIENT_ID FROM @schema.patientdisease WHERE ICD10_CD LIKE 'C50%')) TO 'dat/InjectionData.csv' WITH CSV HEADER;