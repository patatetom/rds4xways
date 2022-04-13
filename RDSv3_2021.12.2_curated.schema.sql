CREATE TABLE PACKAGE_OBJECT (
	package_object_id	INTEGER	UNIQUE	NOT NULL,
	package_id	INTEGER		NOT NULL,
	object_id		INTEGER	UNIQUE	NOT NULL,
	CONSTRAINT PK_PACKAGE_OBJECT__PACKAGE_OBJECT_ID PRIMARY KEY (package_object_id)
);
CREATE TABLE APPLICATION (
	application_id	INTEGER		UNIQUE		NOT NULL,
	package_id	INTEGER				NOT NULL,
	name                VARCHAR		DEFAULT ''	NOT NULL,
	name_b64            VARCHAR				NOT NULL,
	name_coding         VARCHAR				NOT NULL,
	version             VARCHAR		DEFAULT '',
	poe                 VARCHAR		DEFAULT 'purchased'	NOT NULL,
	build               VARCHAR		DEFAULT '',
	latest_copyright    VARCHAR		DEFAULT '',
	other               VARCHAR		DEFAULT '',
	creation_date	TIMESTAMP	DEFAULT CURRENT_TIMESTAMP	NOT NULL,
	update_date	TIMESTAMP	DEFAULT CURRENT_TIMESTAMP	NOT NULL,
	CONSTRAINT PK_APPPLICATION__APPLICATION_ID PRIMARY KEY (application_id),
	CONSTRAINT FK_APPLICATION__PACKAGE_ID FOREIGN KEY (package_id) REFERENCES PACKAGE_OBJECT (package_id)
);
CREATE TABLE APPLICATION_TYPE (
	application_type_id	INTEGER	UNIQUE			NOT NULL,
	description	VARCHAR				NOT NULL,
	creation_date	TIMESTAMP	DEFAULT CURRENT_TIMESTAMP	NOT NULL,
	update_date	TIMESTAMP	DEFAULT CURRENT_TIMESTAMP	NOT NULL,
	CONSTRAINT PK_APPLICATION_TYPE__APPLICATION_TYPE_ID PRIMARY KEY (application_type_id)
);
CREATE TABLE APPLICATION_APPLICATION_TYPE (
	application_application_type_id	INTEGER	UNIQUE	NOT NULL,
	application_id			INTEGER		NOT NULL,
	application_type_id			INTEGER		NOT NULL,
	CONSTRAINT PK_APP_APP_TYPE__APPLICATION_APPLICATION_TYPE_ID PRIMARY KEY (application_application_type_id),
	CONSTRAINT FK_APPLICATION_APPLICATION_TYPE__APPLICATION_ID FOREIGN KEY (application_id) REFERENCES APPLICATION (application_id),
	CONSTRAINT FK_APPLICATION_APPLICATION_TYPE__APPLICATION_TYPE_ID FOREIGN KEY (application_type_id) REFERENCES APPLICATION_TYPE (application_type_id)
);
CREATE TABLE LANGUAGE (
	language_id	INTEGER	UNIQUE			NOT NULL,
	name		VARCHAR	DEFAULT ''		NOT NULL,
	creation_date	TIMESTAMP	DEFAULT CURRENT_TIMESTAMP	NOT NULL,
	update_date	TIMESTAMP	DEFAULT CURRENT_TIMESTAMP	NOT NULL,
	language_tag	VARCHAR,
	CONSTRAINT PK_LANGUAGE_LANGUAGE_ID PRIMARY KEY (language_id)
);
CREATE TABLE APPLICATION_LANGUAGE (
	application_language_id	INTEGER	UNIQUE	NOT NULL,
	language_id		INTEGER		NOT NULL,
	application_id		INTEGER		NOT NULL,
	CONSTRAINT PK_APPLICATION_LANGUAGE__APPLICATION_LANGUAGE_ID PRIMARY KEY (application_language_id),
	CONSTRAINT FK_APPLICATIONI_LANGUAGE__APPLICATION_ID FOREIGN KEY (application_id) REFERENCES APPLICATION (application_id),
	CONSTRAINT FK_APPLICATION_LANGUAGE__LANGUAGE_ID FOREIGN KEY (language_id) REFERENCES LANGUAGE (language_id)
);
CREATE TABLE OPERATING_SYSTEM (
	operating_system_id	INTEGER	UNIQUE			NOT NULL,
	name		VARCHAR	DEFAULT ''		NOT NULL,
	name_b64		VARCHAR,
	name_coding	VARCHAR,
	version		VARCHAR	DEFAULT ''		NOT NULL,
	architecture	VARCHAR	DEFAULT ''		NOT NULL,
	creation_date	TIMESTAMP	DEFAULT CURRENT_TIMESTAMP	NOT NULL,
	update_date	TIMESTAMP	DEFAULT CURRENT_TIMESTAMP	NOT NULL,
	CONSTRAINT PK_OPERATING_SYSTEM__OPERATING_SYSTEM_ID PRIMARY KEY (operating_system_id)
);
CREATE TABLE OPERATING_SYSTEM_APPLICATION (
	operating_system_application_id	INTEGER	UNIQUE	NOT NULL,
	operating_system_id			INTEGER		NOT NULL,
	application_id			INTEGER		NOT NULL,
	CONSTRAINT PK_OPERATING_SYSTEM_APP__OPERATING_SYSTEM_APP_ID PRIMARY KEY (operating_system_application_id),
	CONSTRAINT FK_OPERATING_SYSTEM_APPLICATION__OS_APPLICATION_ID FOREIGN KEY (operating_system_id) REFERENCES OPERATING_SYSTEM (operating_system_id),
	CONSTRAINT FK_PLATFORM_APPLICATION__APPLICATION_ID FOREIGN KEY (application_id) REFERENCES APPLICATION (application_id)
);
CREATE TABLE MANUFACTURER (
	manufacturer_id	INTEGER	UNIQUE			NOT NULL,
	name		VARCHAR	DEFAULT ''		NOT NULL,
	name_b64		VARCHAR,
	name_coding	VARCHAR,
	address1		VARCHAR	DEFAULT ''		NOT NULL,
	address1_b64	VARCHAR,
	address1_coding	VARCHAR,
	address2		VARCHAR	DEFAULT ''		NOT NULL,
	address2_b64	VARCHAR,
	address2_coding	VARCHAR,
	city		VARCHAR	DEFAULT ''		NOT NULL,
	city_b64		VARCHAR,
	city_coding	VARCHAR,
	stateprov		VARCHAR	DEFAULT ''		NOT NULL,
	postal_code	VARCHAR	DEFAULT ''		NOT NULL,
	country		VARCHAR	DEFAULT ''		NOT NULL,
	telephone		VARCHAR	DEFAULT ''		NOT NULL,
	fax		VARCHAR	DEFAULT ''		NOT NULL,
	url		VARCHAR	DEFAULT ''		NOT NULL,
	url_b64		VARCHAR,
	url_coding	VARCHAR,
	email		VARCHAR	DEFAULT ''		NOT NULL,
	creation_date	TIMESTAMP	DEFAULT CURRENT_TIMESTAMP	NOT NULL,
	update_date	TIMESTAMP	DEFAULT CURRENT_TIMESTAMP	NOT NULL,
	CONSTRAINT PK_MANUFACTURER_MANUFACTURER_ID PRIMARY KEY (manufacturer_id)
);
CREATE TABLE MANUFACTURER_APPLICATION (
	manufacturer_application_id	INTEGER	UNIQUE	NOT NULL,
	manufacturer_id		INTEGER		NOT NULL,
	application_id		INTEGER		NOT NULL,
	CONSTRAINT PK_MANUFACTURER_APPLICATION__MANUFACTURER_APPLICATION_ID PRIMARY KEY (manufacturer_application_id),
	CONSTRAINT FK_MANUFACTURER_APPLICATION__APPLICATION_ID FOREIGN KEY (application_id) REFERENCES APPLICATION (application_id),
	CONSTRAINT FK_MANUFACTURER_APPLICATION__MANUFACTURER_ID FOREIGN KEY (manufacturer_id) REFERENCES MANUFACTURER (manufacturer_id)
);
CREATE TABLE MANUFACTURER_OPERATING_SYSTEM (
	manufacturer_operating_system_id	INTEGER	UNIQUE	NOT NULL,
	operating_system_id			INTEGER		NOT NULL,
	manufacturer_id			INTEGER		NOT NULL,
	CONSTRAINT PK_MANUFACTURER_OPERATING_SYSTEM__MANUFACTURER_OS_ID PRIMARY KEY (manufacturer_operating_system_id),
	CONSTRAINT FK_MANUFACTURER_OPERATING_SYSTEM__MANUFACTURER_ID FOREIGN KEY (manufacturer_id) REFERENCES MANUFACTURER (manufacturer_id),
	CONSTRAINT FK_MANUFACTURER_OPERATING_SYSTEM__OPERATING_SYSTEM_ID FOREIGN KEY (operating_system_id) REFERENCES OPERATING_SYSTEM (operating_system_id)
);
CREATE TABLE METADATA (
	metadata_id	NUMERIC	UNIQUE			NOT NULL,
	object_id		INTEGER,
	key_hash		VARCHAR				NOT NULL,
	image_hash	VARCHAR,
	path		VARCHAR				NOT NULL,
	path_b64		VARCHAR,
	path_coding	VARCHAR,
	file_name		VARCHAR				NOT NULL,
	file_name_b64	VARCHAR,
	file_name_coding	VARCHAR,
	extension		VARCHAR	DEFAULT ''		NOT NULL,
	extension_b64	VARCHAR,
	extension_coding	VARCHAR,
	bytes		INTEGER				NOT NULL,
	mtime		TIMESTAMP,
	used_in_rds	TIMESTAMP,
	update_date	TIMESTAMP	DEFAULT CURRENT_TIMESTAMP	NOT NULL,
	recursion_level	INTEGER,
	extractee_id	INTEGER	DEFAULT 0		,
	crc32	VARCHAR	NOT NULL,
	md5		VARCHAR	NOT NULL,
	sha1	VARCHAR	NOT NULL,
	sha256	VARCHAR	NOT NULL,
	CONSTRAINT PK_METADATA__METADATA_ID PRIMARY KEY (metadata_id),
	CONSTRAINT FK_METADATA__EXTRACTEE_ID FOREIGN KEY (extractee_id) REFERENCES METADATA (metadata_id),
	CONSTRAINT FK_METADATA__OBJECT_ID FOREIGN KEY (object_id) REFERENCES PACKAGE_OBJECT (object_id)
);
CREATE TABLE VERSION (
	version	VARCHAR	UNIQUE	NOT NULL,
	build_set	VARCHAR	NOT NULL,
	build_date	TIMESTAMP	DEFAULT CURRENT_TIMESTAMP	NOT NULL,
	release_date	TIMESTAMP	NOT NULL,
	description	VARCHAR	NOT NULL,
	CONSTRAINT PK_VERSION__VERSION PRIMARY KEY (version)
);
CREATE VIEW FILE AS
    SELECT
        UPPER(md.sha256) AS sha256,
        UPPER(md.sha1) AS sha1,
        UPPER(md.md5) AS md5,
        CASE md.extension
	        WHEN ''
                THEN md.file_name
                ELSE md.file_name||'.'||md.extension
            END AS file_name,
        md.bytes AS file_size,
        po.package_id
    FROM
        METADATA AS md,
        PACKAGE_OBJECT AS po
    WHERE
        md.object_id = po.object_id
/* FILE(sha256,sha1,md5,file_name,file_size,package_id) */;
CREATE VIEW MFG AS  
    SELECT 
        manufacturer_id,
        name
    FROM
        MANUFACTURER
/* MFG(manufacturer_id,name) */;
CREATE VIEW OS AS
   	SELECT
        os.operating_system_id,
        os.name,
        os.version,
        mos.manufacturer_id
    FROM
        OPERATING_SYSTEM AS os,
        MANUFACTURER_OPERATING_SYSTEM AS mos
    WHERE
        os.operating_system_id = mos.operating_system_id
/* OS(operating_system_id,name,version,manufacturer_id) */;
CREATE VIEW PKG AS
    SELECT
        a.package_id,
        a.name,
        a.version,
        osa.operating_system_id,
        ma.manufacturer_id,
        l.name AS language,
        at.description AS application_type
    FROM
        APPLICATION AS a,
        OPERATING_SYSTEM_APPLICATION AS osa,
        MANUFACTURER_APPLICATION AS ma,
        APPLICATION_LANGUAGE AS al,
        LANGUAGE AS l,
        APPLICATION_APPLICATION_TYPE AS aat,
        APPLICATION_TYPE AS at
    WHERE
        a.application_id = osa.application_id
    AND
        a.application_id = ma.application_id
    AND
        a.application_id = al.application_id
    AND
        al.language_id = l.language_id
    AND
        a.application_id = aat.application_id
    AND
        aat.application_type_id = at.application_type_id
/* PKG(package_id,name,version,operating_system_id,manufacturer_id,language,application_type) */;