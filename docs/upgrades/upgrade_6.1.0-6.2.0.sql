insert into webguiVersion values ('6.2.0','upgrade',unix_timestamp());
DROP TABLE IF EXISTS metaData_fields;
CREATE TABLE metaData_fields (
  fieldId int(11) NOT NULL default '0',
  fieldName varchar(100) NOT NULL ,
  description mediumtext NOT NULL ,
  fieldType varchar(30),
  possibleValues text default NULL,
  defaultValue varchar(100) default NULL,
  PRIMARY KEY  (fieldId),
  UNIQUE KEY field_unique (fieldName)
) TYPE=MyISAM;

DROP TABLE IF EXISTS metaData_data;
CREATE TABLE metaData_data (
  fieldId int(11) NOT NULL default '0',
  wobjectId int(11) NOT NULL default '0',
  value varchar(100) default NULL,
  PRIMARY KEY  (fieldId, wobjectId)
) TYPE=MyISAM;

DROP TABLE IF EXISTS passiveProfileLog;
CREATE TABLE passiveProfileLog (
  passiveProfileLogId int(11) NOT NULL default '0',
  userId int(11) NOT NULL default '0',
  sessionId varchar(60) default NULL,
  wobjectId int(11) NOT NULL default '0',
  dateOfEntry int(11) default '0', 
  PRIMARY KEY  (passiveProfileLogId)
) TYPE=MyISAM;

DROP TABLE IF EXISTS passiveProfileAOI;
CREATE TABLE passiveProfileAOI (
  userId int(11) NOT NULL default '0',
  fieldId int(11) NOT NULL,
  value varchar(100) NOT NULL,
  count int(11),
  PRIMARY KEY  (userId,fieldId,value)
) TYPE=MyISAM;

DELETE FROM incrementer WHERE incrementerId = "metaData_fieldId";
INSERT INTO incrementer (incrementerId, nextValue) values ("metaData_fieldId", 1000);

DELETE FROM incrementer WHERE incrementerId = "passiveProfileLogId";
INSERT INTO incrementer (incrementerId, nextValue) values ("passiveProfileLogId", 1000);

DELETE FROM settings WHERE name = "metaDataEnabled";
INSERT INTO settings (name, value) values ("metaDataEnabled", 0);
DELETE FROM settings WHERE name = "passiveProfilingEnabled";
INSERT INTO settings (name, value) values ("passiveProfilingEnabled", 0);

