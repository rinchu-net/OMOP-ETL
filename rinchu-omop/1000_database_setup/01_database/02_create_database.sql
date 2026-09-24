---- まずCREATE DATABASEだけを単独で実行してください ----
CREATE DATABASE "(your database name here)"
  WITH ENCODING='UTF8'
       OWNER=ohdsi_admin
       LC_COLLATE='ja_JP.UTF-8'
       LC_CTYPE='ja_JP.UTF-8'
       CONNECTION LIMIT=-1
       TEMPLATE template0;

---- 次に以下のコマンドを実行してください ----
COMMENT ON DATABASE "(your database name here)"
  IS 'OHDSI database with correct UTF-8 locale';
GRANT ALL ON DATABASE "(your database name here)" TO GROUP ohdsi_admin;
GRANT CONNECT, TEMPORARY ON DATABASE "(your database name here)" TO GROUP ohdsi_app;