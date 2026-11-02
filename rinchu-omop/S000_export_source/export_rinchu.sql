\echo ==== 各テーブルの全件を抽出します ====
\echo ==== PatientIdentification ====
\copy (SELECT * FROM @schema.patientidentification) to 'dat/PatientIdentification.csv' csv header
\echo ==== PatientAddress ====
\copy (SELECT * FROM @schema.patientaddress) to 'dat/PatientAddress.csv' csv header
\echo ==== PatientVisit ====
\copy (SELECT * FROM @schema.patientvisit) to 'dat/PatientVisit.csv' csv header
\echo ==== PatientDisease ====
\copy (SELECT * FROM @schema.patientdisease) to 'dat/PatientDisease.csv' csv header
\echo ==== ObservationResult ====
\copy (SELECT * FROM @schema.observationresult) to 'dat/ObservationResult.csv' csv header
\echo ==== PrescriptionData ====
\copy (SELECT * FROM @schema.prescriptiondata) to 'dat/PrescriptionData.csv' csv header
\echo ==== InjectionData ====
\copy (SELECT * FROM @schema.injectiondata) to 'dat/InjectionData.csv' csv header