\echo ==== 各テーブルの全件を抽出します ====
\echo ==== PatientIdentification ====
\copy "@schema"."patientidentification" to 'dat/PatientIdentification.csv' csv header
\echo ==== PatientAddress ====
\copy "@schema"."patientaddress" to 'dat/PatientAddress.csv' csv header
\echo ==== PatientVisit ====
\copy "@schema"."patientvisit" to 'dat/PatientVisit.csv' csv header
\echo ==== PatientDisease ====
\copy "@schema"."patientdisease" to 'dat/PatientDisease.csv' csv header
\echo ==== ObservationResult ====
\copy "@schema"."observationresult" to 'dat/ObservationResult.csv' csv header
\echo ==== PrescriptionData ====
\copy "@schema"."prescriptiondata" to 'dat/PrescriptionData.csv' csv header
\echo ==== InjectionData ====
\copy "@schema"."injectiondata" to 'dat/InjectionData.csv' csv header