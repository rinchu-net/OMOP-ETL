-- Create ohdsi_admin role if not exists
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'ohdsi_admin') THEN
    CREATE ROLE ohdsi_admin CREATEDB REPLICATION VALID UNTIL 'infinity';
    COMMENT ON ROLE ohdsi_admin IS 'Administration group for OHDSI applications';
  END IF;
END $$;

-- Create ohdsi_app role if not exists
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'ohdsi_app') THEN
    CREATE ROLE ohdsi_app VALID UNTIL 'infinity';
    COMMENT ON ROLE ohdsi_app IS 'Application group for OHDSI applications';
  END IF;
END $$;

-- Create ohdsi_admin_user role if not exists
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'ohdsi_admin_user') THEN
    CREATE ROLE ohdsi_admin_user LOGIN ENCRYPTED PASSWORD 'admin1' VALID UNTIL 'infinity';
    GRANT ohdsi_admin TO ohdsi_admin_user;
    COMMENT ON ROLE ohdsi_admin_user IS 'Admin user account for OHDSI applications';
    ALTER ROLE ohdsi_admin_user SUPERUSER CREATEDB CREATEROLE;
  END IF;
END $$;

-- Create ohdsi_app_user role if not exists
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'ohdsi_app_user') THEN
    CREATE ROLE ohdsi_app_user LOGIN ENCRYPTED PASSWORD 'app1' VALID UNTIL 'infinity';
    GRANT ohdsi_app TO ohdsi_app_user;
    COMMENT ON ROLE ohdsi_app_user IS 'Application user account for OHDSI applications';
    ALTER ROLE ohdsi_app_user SUPERUSER CREATEDB CREATEROLE;
  END IF;
END $$;
