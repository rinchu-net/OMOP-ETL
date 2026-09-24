\set ON_ERROR_STOP on
--=================================================================
-- MEDIS標準マスター
-- https://www2.medis.or.jp/stdcd/byomei/index.html
--=================================================================

--------------------------------------
-- 	病名マスター（ICD10対応標準病名マスター）
-- 	Column Mapping (Japanese -> English):
-- 	変更区分 -> chgkbn
-- 	病名管理番号 -> kanrino
-- 	病名表記 -> byomeiname
-- 	病名表記カナ -> byomeiname_kana
-- 	採択区分 -> saitakukbn
-- 	病名交換用コード -> exchangecd
-- 	ＩＣＤ１０ー２０１３ -> icd10_2013
-- 	ＩＣＤ１０ー２０１３複数分類コード -> icd10_2013_sub
-- 	予備1 -> yobi1
-- 	予備2 -> yobi2
-- 	レセ電算コード -> rcptcd
-- 	傷病名省略名称 -> byomeinamer
-- 	使用分野 -> siyoubunya
-- 	変更履歴番号 -> rirekino
-- 	変更日付 -> chgdate
-- 	移行先病名管理番号 -> iko_kanrino
-- 	単独使用禁止区分 -> tankinshikbn
-- 	保険請求外区分 -> hokengaikbn
-- 	予備3 -> yobi3
-- 	予備4 -> yobi4
--------------------------------------
CREATE TABLE :source_schema.mst_medis_byomei (	
	chgkbn char,
	kanrino varchar(8),
	byomeiname varchar(60),
	byomeiname_kana varchar(100),
	saitakukbn char,
	exchangecd varchar(4),
	icd10_2013 varchar(5),
	icd10_2013_sub varchar(5),
	yobi1 varchar(3),
	yobi2 varchar(150),
	rcptcd varchar(33),
	byomeinamer varchar(40),
	siyoubunya char,
	rirekino varchar(3),
	chgdate varchar(8),
	iko_kanrino varchar(8),
	tankinshikbn varchar(2),
	hokengaikbn char,
	yobi3 varchar(5),
	yobi4 varchar(5)
);	
CREATE INDEX idx_mst_medis_byomei_1  ON :source_schema.mst_medis_byomei (kanrino ASC);
CREATE INDEX idx_mst_medis_byomei_2  ON :source_schema.mst_medis_byomei (exchangecd ASC);
CREATE INDEX idx_mst_medis_byomei_3  ON :source_schema.mst_medis_byomei (icd10_2013 ASC);
CREATE INDEX idx_mst_medis_byomei_4  ON :source_schema.mst_medis_byomei (icd10_2013_sub ASC);
CREATE INDEX idx_mst_medis_byomei_5  ON :source_schema.mst_medis_byomei (rcptcd ASC);

--------------------------------------
-- 	医薬品マスター（HOTコードマスター）
-- https://www2.medis.or.jp/master/hcode/
--------------------------------------
CREATE TABLE :source_schema.mst_medis_hot13 (
    基準番号 CHAR(13),
    処方用番号 CHAR(7),
    会社識別番号 CHAR(2),
    調剤用番号 CHAR(2),
    物流用番号 CHAR(2),
    ＪＡＮコード CHAR(13),
    薬価基準収載医薬品コード CHAR(12),
    個別医薬品コード CHAR(12),
    レセプト電算処理システムコード１ CHAR(9),
    レセプト電算処理システムコード２ CHAR(9),
    告示名称 VARCHAR(120),
    販売名 VARCHAR(120),
    レセプト電算処理システム医薬品名 VARCHAR(90),
    規格単位 VARCHAR(80),
    包装形態 VARCHAR(16),
    包装単位数 CHAR(12),
    包装単位単位 VARCHAR(16),
    包装総量数 CHAR(12),
    包装総量単位 VARCHAR(16),
    区分 VARCHAR(2),
    製造会社 VARCHAR(100),
    販売会社 VARCHAR(100),
    レコード区分 CHAR(1),
    更新年月日 CHAR(8)
);
CREATE INDEX idx_mst_medis_hot13_1  ON :source_schema.mst_medis_hot13 (基準番号 ASC);
CREATE INDEX idx_mst_medis_hot13_2  ON :source_schema.mst_medis_hot13 (薬価基準収載医薬品コード ASC);
CREATE INDEX idx_mst_medis_hot13_3  ON :source_schema.mst_medis_hot13 (個別医薬品コード ASC);
CREATE INDEX idx_mst_medis_hot13_4  ON :source_schema.mst_medis_hot13 (レセプト電算処理システムコード１ ASC);

--=================================================================
-- 郵便番号マスター
-- https://www.post.japanpost.jp/zipcode/dl/utf-zip.html
--=================================================================
CREATE TABLE :source_schema.mst_zipcode (
	jiscode             varchar(5),
	zipcode_old         char(5),
	zipcode             char(7),
	prefecture_kana     varchar(15),
	city_kana           varchar(31),
	street_kana         varchar(512),
	prefecture          varchar(15),
	city                varchar(31),
	street              varchar(512),
	flag1               smallint,
	flag2               smallint,
	flag3               smallint,
	flag4               smallint,
	flag5               smallint,
	flag6               smallint
);
CREATE INDEX idx_mst_zipcode_1 ON :source_schema.mst_zipcode(zipcode);


--=================================================================
-- 愛媛大 薬剤マッピングマスタ(mendeley公開テーブル)
-- https://data.mendeley.com/datasets/y3756v8237/1
--=================================================================
CREATE TABLE :source_schema.mst_mendeley(
    category char(9),
    nhidplc  char(12),
    ingredient varchar(100),
    specification varchar(100),
    japansedrugname varchar(100),
    normalizedname varchar(256),
    mm8w1str varchar(256),
    mm8w2str varchar(256),
    mm8w3str varchar(256),
    mm8w4str varchar(256),
    mm8w5str varchar(256),
    mm8w1cui char(20),
    mm8w2cui char(20),
    mm8w3cui char(20),
    mm8w4cui char(20),
    mm8w5cui char(20),
    mm8w1tty char(20),
    mm8w2tty char(20),
    mm8w3tty char(20),
    mm8w4tty char(20),
    mm8w5tty char(20),
    osv_id char(8),
    osv_name varchar(256),
    osv_class char(20),
    comment varchar(50)
);
CREATE INDEX idx_mst_mendeley_1  ON :source_schema.mst_mendeley (nhidplc ASC);
CREATE INDEX idx_mst_mendeley_2  ON :source_schema.mst_mendeley (mm8w1cui ASC);
CREATE INDEX idx_mst_mendeley_3  ON :source_schema.mst_mendeley (mm8w2cui ASC);
CREATE INDEX idx_mst_mendeley_4  ON :source_schema.mst_mendeley (mm8w3cui ASC);
CREATE INDEX idx_mst_mendeley_5  ON :source_schema.mst_mendeley (mm8w4cui ASC);
CREATE INDEX idx_mst_mendeley_6  ON :source_schema.mst_mendeley (mm8w5cui ASC);
