CREATE ROLE ohdsi_admin
  CREATEDB REPLICATION
   VALID UNTIL 'infinity';
COMMENT ON ROLE ohdsi_admin
  IS 'Administration group for OHDSI applications';

CREATE ROLE ohdsi_app
   VALID UNTIL 'infinity';
COMMENT ON ROLE ohdsi_app
  IS 'Application group for OHDSI applications';

-- (your password here)箇所のパスワードを必ず設定してください。
CREATE ROLE ohdsi_admin_user LOGIN ENCRYPTED PASSWORD '(your password here)'
   VALID UNTIL 'infinity';
GRANT ohdsi_admin TO ohdsi_admin_user;
COMMENT ON ROLE ohdsi_admin_user
  IS 'Admin user account for OHDSI applications';

ALTER ROLE ohdsi_admin_user
	SUPERUSER
	CREATEDB
	CREATEROLE;

-- (your password here)箇所のパスワードを必ず設定してください。
CREATE ROLE ohdsi_app_user LOGIN ENCRYPTED PASSWORD '(your password here)'
   VALID UNTIL 'infinity';
GRANT ohdsi_app TO ohdsi_app_user;
COMMENT ON ROLE ohdsi_app_user
  IS 'Application user account for OHDSI applications';
    
ALTER ROLE ohdsi_app_user
	SUPERUSER
	CREATEDB
	CREATEROLE;
