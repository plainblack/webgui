insert into webguiVersion values ('6.2.0','upgrade',unix_timestamp());
DROP TABLE IF EXISTS metaData_properties;
CREATE TABLE metaData_properties (
  fieldId int(11) NOT NULL default '0',
  fieldName varchar(100) NOT NULL ,
  description mediumtext NOT NULL ,
  fieldType varchar(30),
  possibleValues text default NULL,
  defaultValue varchar(100) default NULL,
  PRIMARY KEY  (fieldId),
  UNIQUE KEY field_unique (fieldName)
) TYPE=MyISAM;

DROP TABLE IF EXISTS metaData_values;
CREATE TABLE metaData_values (
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

alter table WobjectProxy add proxyByCriteria int default 0;
alter table WobjectProxy add resolveMultiples varchar(30) default "mostRecent";
alter table WobjectProxy add proxyCriteria text default NULL;

alter table IndexedSearch add column (forceSearchRoots smallint(1) default 1);
alter table DataForm_field add column (vertical smallint(1) default 1);
alter table DataForm_field add column (extras varchar(128));

INSERT INTO groups VALUES (13,'Export Managers','Users in this group can export pages to disk.',314496000,1000000000,NULL,997938000,997938000,14,-14,NULL,0,NULL,0,0,0,3600,NULL,1,1);

INSERT INTO groupGroupings VALUES (3,13);
