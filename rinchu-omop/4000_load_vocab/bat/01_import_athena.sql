\set ON_ERROR_STOP on
\echo ====================================
\echo ==== truncate table before load ====
\echo ====================================
\echo ==== TRUNCATE domain ====
TRUNCATE TABLE "@schema"."domain_f";
\echo ==== TRUNCATE vocabulary ====
TRUNCATE TABLE "@schema"."vocabulary_f";
\echo ==== TRUNCATE concept_class ====
TRUNCATE TABLE "@schema"."concept_class_f";
\echo ==== TRUNCATE concept ====
TRUNCATE TABLE "@schema"."concept_f";
\echo ==== TRUNCATE concept_relationship ====
TRUNCATE TABLE "@schema"."concept_relationship_f";
\echo ==== TRUNCATE concept_ancestor ====
TRUNCATE TABLE "@schema"."concept_ancestor_f";
\echo ==== TRUNCATE concept_synonym ====
TRUNCATE TABLE "@schema"."concept_synonym_f";
\echo ==== TRUNCATE drug_strength ====
TRUNCATE TABLE "@schema"."drug_strength_f";
\echo ==== TRUNCATE relationship ====
TRUNCATE TABLE "@schema"."relationship_f";

\echo ====================================
\echo ==== execute data loading      =====
\echo ====================================
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] loading domain | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo ==== domain ====
\copy "@schema"."domain_f" from '../athena/DOMAIN.csv'WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, QUOTE E'\b', NULL '', ENCODING 'UTF8')
DO $$ BEGIN RAISE NOTICE '[END] loading domain | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] loading vocabulary | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo ==== vocabulary ====
\copy "@schema"."vocabulary_f" from '../athena/VOCABULARY.csv'WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, QUOTE E'\b', NULL '', ENCODING 'UTF8')
DO $$ BEGIN RAISE NOTICE '[END] loading vocabulary | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] loading concept_class | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo ==== concept_class ====
\copy "@schema"."concept_class_f" from '../athena/CONCEPT_CLASS.csv'WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, QUOTE E'\b', NULL '', ENCODING 'UTF8')
DO $$ BEGIN RAISE NOTICE '[END] loading concept_class | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] loading concept | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo ==== concept ====
\copy "@schema"."concept_f" from '../athena/CONCEPT.csv'WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, QUOTE E'\b', NULL '', ENCODING 'UTF8')
DO $$ BEGIN RAISE NOTICE '[END] loading concept | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] loading concept_relationship | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo ==== concept_relationship ====
\copy "@schema"."concept_relationship_f" from '../athena/CONCEPT_RELATIONSHIP.csv'WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, QUOTE E'\b', NULL '', ENCODING 'UTF8')
DO $$ BEGIN RAISE NOTICE '[END] loading concept_relationship | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] loading concept_ancestor | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo ==== concept_ancestor ====
\copy "@schema"."concept_ancestor_f" from '../athena/CONCEPT_ANCESTOR.csv'WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, QUOTE E'\b', NULL '', ENCODING 'UTF8')
DO $$ BEGIN RAISE NOTICE '[END] loading concept_ancestor | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] loading concept_synonym | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo ==== concept_synonym ====
\copy "@schema"."concept_synonym_f" from '../athena/CONCEPT_SYNONYM.csv'WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, QUOTE E'\b', NULL '', ENCODING 'UTF8')
DO $$ BEGIN RAISE NOTICE '[END] loading concept_synonym | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] loading drug_strength | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo ==== drug_strength ====
\copy "@schema"."drug_strength_f" from '../athena/DRUG_STRENGTH.csv'WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, QUOTE E'\b', NULL '', ENCODING 'UTF8')
DO $$ BEGIN RAISE NOTICE '[END] loading drug_strength | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] loading relationship | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo ==== relationship ====
\copy "@schema"."relationship_f" from '../athena/RELATIONSHIP.csv'WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, QUOTE E'\b', NULL '', ENCODING 'UTF8')
DO $$ BEGIN RAISE NOTICE '[END] loading relationship | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

\echo ===================================
\echo ==== table analyze             ====
\echo ===================================
\echo ==== analyze ====
ANALYZE "@schema"."concept_f";
ANALYZE "@schema"."vocabulary_f";
ANALYZE "@schema"."domain_f";
ANALYZE "@schema"."concept_class_f";
ANALYZE "@schema"."concept_relationship_f";
ANALYZE "@schema"."concept_ancestor_f";
ANALYZE "@schema"."concept_synonym_f";
ANALYZE "@schema"."drug_strength_f";
ANALYZE "@schema"."relationship_f";

\echo ===================================
\echo ==== table records count       ====
\echo ===================================
SELECT '@schema.domain_f' AS table, COUNT(*) AS count FROM "@schema"."domain_f";
SELECT '@schema.vocabulary_f' AS table, COUNT(*) AS count FROM "@schema"."vocabulary_f";
SELECT '@schema.concept_class_f' AS table, COUNT(*) AS count FROM "@schema"."concept_class_f";
SELECT '@schema.concept_f' AS table, COUNT(*) AS count FROM "@schema"."concept_f";
SELECT '@schema.concept_relationship_f' AS table, COUNT(*) AS count FROM "@schema"."concept_relationship_f";
SELECT '@schema.concept_ancestor_f' AS table, COUNT(*) AS count FROM "@schema"."concept_ancestor_f";
SELECT '@schema.concept_synonym_f' AS table, COUNT(*) AS count FROM "@schema"."concept_synonym_f";
SELECT '@schema.drug_strength_f' AS table, COUNT(*) AS count FROM "@schema"."drug_strength_f";
SELECT '@schema.relationship_f' AS table, COUNT(*) AS count FROM "@schema"."relationship_f";
