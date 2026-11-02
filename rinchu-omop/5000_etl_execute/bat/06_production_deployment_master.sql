\set ON_ERROR_STOP on
---------------------------------------------------------------------
-- masterテーブルからproductionテーブルへのデータ移行
---------------------------------------------------------------------
-- domain
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] migrating domain | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo migrating domain ..
ALTER TABLE :production_schema.domain DISABLE TRIGGER ALL;
TRUNCATE TABLE :production_schema.domain CASCADE;
INSERT INTO :production_schema.domain SELECT * FROM :working_schema.domain_f;
ALTER TABLE :production_schema.domain ENABLE TRIGGER ALL;
ANALYZE VERBOSE :production_schema.domain;
DO $$ BEGIN RAISE NOTICE '[END] migrating domain | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

-- vocabulary
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] migrating vocabulary | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo migrating vocabulary ..
ALTER TABLE :production_schema.vocabulary DISABLE TRIGGER ALL;
TRUNCATE TABLE :production_schema.vocabulary CASCADE;
INSERT INTO :production_schema.vocabulary SELECT * FROM :working_schema.vocabulary_f;
ALTER TABLE :production_schema.vocabulary ENABLE TRIGGER ALL;
ANALYZE VERBOSE :production_schema.vocabulary;
DO $$ BEGIN RAISE NOTICE '[END] migrating vocabulary | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

-- concept_class
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] migrating concept_class | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo migrating concept_class ..
ALTER TABLE :production_schema.concept_class DISABLE TRIGGER ALL;
TRUNCATE TABLE :production_schema.concept_class CASCADE;
INSERT INTO :production_schema.concept_class SELECT * FROM :working_schema.concept_class_f;
ALTER TABLE :production_schema.concept_class ENABLE TRIGGER ALL;
ANALYZE VERBOSE :production_schema.concept_class;
DO $$ BEGIN RAISE NOTICE '[END] migrating concept_class | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

-- concept
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] migrating concept | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo migrating concept ..
ALTER TABLE :production_schema.concept DISABLE TRIGGER ALL;
TRUNCATE TABLE :production_schema.concept CASCADE;
INSERT INTO :production_schema.concept SELECT * FROM :working_schema.concept_f;
ALTER TABLE :production_schema.concept ENABLE TRIGGER ALL;
ANALYZE VERBOSE :production_schema.concept;
DO $$ BEGIN RAISE NOTICE '[END] migrating concept | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

-- concept_relationship
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] migrating concept_relationship | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo migrating concept_relationship ..
ALTER TABLE :production_schema.concept_relationship DISABLE TRIGGER ALL;
TRUNCATE TABLE :production_schema.concept_relationship CASCADE;
INSERT INTO :production_schema.concept_relationship SELECT * FROM :working_schema.concept_relationship_f;
ALTER TABLE :production_schema.concept_relationship ENABLE TRIGGER ALL;
ANALYZE VERBOSE :production_schema.concept_relationship;
DO $$ BEGIN RAISE NOTICE '[END] migrating concept_relationship | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

-- concept_ancestor
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] migrating concept_ancestor | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo migrating concept_ancestor ..
ALTER TABLE :production_schema.concept_ancestor DISABLE TRIGGER ALL;
TRUNCATE TABLE :production_schema.concept_ancestor CASCADE;
INSERT INTO :production_schema.concept_ancestor SELECT * FROM :working_schema.concept_ancestor_f;
ALTER TABLE :production_schema.concept_ancestor ENABLE TRIGGER ALL;
ANALYZE VERBOSE :production_schema.concept_ancestor;
DO $$ BEGIN RAISE NOTICE '[END] migrating concept_ancestor | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

-- concept_synonym
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] migrating concept_synonym | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo migrating concept_synonym ..
ALTER TABLE :production_schema.concept_synonym DISABLE TRIGGER ALL;
TRUNCATE TABLE :production_schema.concept_synonym CASCADE;
INSERT INTO :production_schema.concept_synonym SELECT * FROM :working_schema.concept_synonym_f;
ALTER TABLE :production_schema.concept_synonym ENABLE TRIGGER ALL;
ANALYZE VERBOSE :production_schema.concept_synonym;
DO $$ BEGIN RAISE NOTICE '[END] migrating concept_synonym | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

-- drug_strength
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] migrating drug_strength | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo migrating drug_strength ..
ALTER TABLE :production_schema.drug_strength DISABLE TRIGGER ALL;
TRUNCATE TABLE :production_schema.drug_strength CASCADE;
INSERT INTO :production_schema.drug_strength SELECT * FROM :working_schema.drug_strength_f;
ALTER TABLE :production_schema.drug_strength ENABLE TRIGGER ALL;
ANALYZE VERBOSE :production_schema.drug_strength;
DO $$ BEGIN RAISE NOTICE '[END] migrating drug_strength | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

-- relationship
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] migrating relationship | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo migrating relationship ..
ALTER TABLE :production_schema.relationship DISABLE TRIGGER ALL;
TRUNCATE TABLE :production_schema.relationship CASCADE;
INSERT INTO :production_schema.relationship SELECT * FROM :working_schema.relationship_f;
ALTER TABLE :production_schema.relationship ENABLE TRIGGER ALL;
ANALYZE VERBOSE :production_schema.relationship;
DO $$ BEGIN RAISE NOTICE '[END] migrating relationship | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================
