-- ============================================================
-- WebAPI Sources Data Initialization
-- TRUNCATE and INSERT source and source_daimon data
-- ============================================================

-- Clear existing data
TRUNCATE TABLE webapi.source_daimon RESTART IDENTITY CASCADE;
TRUNCATE TABLE webapi.source RESTART IDENTITY CASCADE;

-- ============================================================
-- Insert into source table
-- ============================================================
INSERT INTO webapi.source (
    source_id,
    source_name,
    source_key,
    source_connection,
    source_dialect,
    username,
    password,
    krb_auth_method,
    keytab_name,
    krb_keytab,
    krb_admin_server,
    deleted_date,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    is_cache_enabled,
    check_connection
) VALUES 
    (1, 'omop', 'rinchu_omop', 'jdbc:postgresql://host.rancher-desktop.internal:5432/OHDSI?user=ohdsi_app_user&password=app1', 'postgresql', '', '', 'PASSWORD', '', '', '', NULL, NULL, NOW(), NULL, NOW(), false, true)
;

-- ============================================================
-- Insert into source_daimon table
-- ============================================================
INSERT INTO webapi.source_daimon (
    source_daimon_id,
    source_id,
    daimon_type,
    table_qualifier,
    priority
) VALUES
    (1, 1, 0, 'omop', 0),
    (2, 1, 1, 'omop', 1),
    (3, 1, 2, 'result', 1),
    (4, 1, 5, 'temp', 0)
;

-- Reset sequence
SELECT setval(pg_get_serial_sequence('webapi.source', 'source_id'), COALESCE(MAX(source_id), 0) + 1, false) FROM webapi.source;
SELECT setval(pg_get_serial_sequence('webapi.source_daimon', 'source_daimon_id'), COALESCE(MAX(source_daimon_id), 0) + 1, false) FROM webapi.source_daimon;

SELECT * FROM webapi.source;