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

insert into settings (name,value) VALUES ("urlExtension","");
alter table users change userId userId char(22) not null;
alter table DataForm_entry change userId userId char(22);
alter table IndexedSearch_docInfo change ownerId ownerId char(22);
alter table Poll_answer change userId userId char(22);
alter table Survey_response change userId userId char(22);
alter table USS_submission change userId userId char(22);
alter table authentication change userId userId char(22);
alter table collateral change userId userId char(22);
alter table forumPost change userId userId char(22);
alter table forumPostRating change userId userId char(22);
alter table forumRead change userId userId char(22);
alter table forumSubscription change userId userId char(22);
alter table forumThreadSubscription change userId userId char(22);
alter table groupings change userId userId char(22);
alter table karmaLog change userId userId char(22);
alter table messageLog change userId userId char(22);
alter table page change ownerId ownerId char(22);
alter table pageStatistics change userId userId char(22);
alter table passiveProfileAOI change userId userId char(22);
alter table passiveProfileLog change userId userId char(22);
alter table userLoginLog change userId userId char(22);
alter table userProfileData change userId userId char(22);
alter table userSession change userId userId char(22);
alter table wobject change ownerId ownerId char(22);
alter table wobject change addedBy addedBy char(22);
alter table wobject change editedBy editedBy char(22);
alter table wobject change wobjectId wobjectId  char(22);
alter table wobject change forumId forumId  char(22);
alter table wobject change pageId pageId  char(22);
alter table wobject change groupIdView groupIdView  char(22);
alter table wobject change groupIdEdit groupIdEdit char(22);
alter table wobject change bufferUserId bufferUserId char(22);
alter table wobject change bufferPrevId bufferPrevId char(22);
alter table wobject change templateId templateId char(22);
alter table Article change wobjectId wobjectId char(22);
alter table USS change wobjectId wobjectId char(22);
alter table USS change groupToContribute groupToContribute char(22);
alter table USS change groupToApprove groupToApprove char(22);
alter table USS change submissionTemplateId submissionTemplateId char(22);
alter table USS change submissionFormTemplateId submissionFormTemplateId char(22);
alter table USS change submissionFormTemplateId submissionFormTemplateId char(22);
alter table USS change USS_id USS_id char(22);
alter table USS_submission change USS_submissionId USS_submissionId char(22);
alter table USS_submission change forumId forumId char(22);
alter table USS_submission change USS_id USS_id char(22);
alter table DataForm change wobjectId wobjectId char(22);
alter table DataForm change emailTemplateId emailTemplateId char(22);
alter table DataForm change acknowlegementTemplateId acknowlegementTemplateId char(22);
alter table DataForm change listTemplateId listTemplateId char(22);
alter table DataForm_entry change wobjectId wobjectId char(22);
alter table DataForm_entry change DataForm_entryId DataForm_entryId char(22);
alter table DataForm_tab change wobjectId wobjectId char(22);
alter table DataForm_tab change DataForm_tabId DataForm_tabId char(22);
alter table EventsCalendar change wobjectId wobjectId char(22);
alter table EventsCalendar_event change wobjectId wobjectId char(22);
alter table FileManager change wobjectId wobjectId char(22);
alter table FileManager_file change wobjectId wobjectId char(22);
alter table FileManager_file change FileManager_fileId FileManager_fileId char(22);
alter table EventsCalendar_event change EventsCalendar_eventId EventsCalendar_eventId char(22);
alter table EventsCalendar change eventTemplateId eventTemplateId char(22);
alter table EventsCalendar_event change EventsCalendar_recurringId EventsCalendar_recurringId char(22);
alter table FileManager_file change groupToView groupToView char(22);

delete from template where namespace='style' and templateId='10';
INSERT INTO template VALUES (10,'htmlArea Image Manager','<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n		<html>\n		<head>\n			<title><tmpl_var session.page.title> - <tmpl_var session.setting.companyName></title>\n			<tmpl_var head.tags>\n		<style type=\"text/css\">\r\nTD { font: 8pt \'MS Shell Dlg\', Helvetica, sans-serif; }\r\nTD.delete { font: italic 7pt \'MS Shell Dlg\', Helvetica, sans-serif; }\r\nTD.label { font: 8pt \'MS Shell Dlg\', Helvetica, sans-serif; background-color: #c0c0c0; }\r\nTD.none { font: italic 12pt \'MS Shell Dlg\', Helvetica, sans-serif; }\r\n\r\n</style>\r\n\n		</head>\n		<script language=\"javascript\">\r\nfunction findAncestor(element, name, type) {\r\n   while(element != null && (element.name != name || element.tagName != type))\r\n      element = element.parentElement;\r\n   return element;\r\n}\r\n</script>\r\n<script language=\"javascript\">\r\n\r\nfunction actionComplete(action, path, error, info) {\r\n   var manager = findAncestor(window.frameElement, \'manager\', \'TABLE\');\r\n   var wrapper = findAncestor(window.frameElement, \'wrapper\', \'TABLE\');\r\n\r\n   if(manager) {\r\n      if(error.length < 1) {\r\n         manager.all.actions.reset();\r\n         if(action == \'upload\') {\r\n            manager.all.actions.image.value = \'\';\r\n            manager.all.actions.name.value = \'\';\r\n           manager.all.actions.thumbnailSize.value = \'\';\r\n\r\n         }\r\n         if(action == \'create\')\r\n            manager.all.actions.folder.value = \'\';\r\n         if(action == \'delete\')\r\n            manager.all.txtFileName.value = \'\';\r\n      }\r\n      manager.all.actions.DPI.value = 96;\r\n      manager.all.actions.path.value = path;\r\n   }\r\n   if(wrapper)\r\n      wrapper.all.viewer.contentWindow.navigate(\'^/;?op=htmlAreaviewCollateral\');\r\n   if(error.length > 0)\r\n      alert(error);\r\n   else if(info.length > 0)\r\n      alert(info);\r\n}\r\n</script>\r\n\r\n<script language=\"javascript\">\r\nfunction deleteCollateral(options) {\r\n   var lister = findAncestor(window.frameElement, \'lister\', \'IFRAME\');\r\n\r\n   if(lister && confirm(\"Are you sure you want to delete this item ?\"))\r\n      lister.contentWindow.navigate(\'^/;?op=htmlAreaDelete&\' + options);\r\n}\r\n</script>\r\n</head>\r\n<body leftmargin=\"0\" topmargin=\"0\" marginwidth=\"0\" marginheight=\"0\">\r\n\n			<tmpl_var body.content>\n		\r\n</body>\n		</html>\n		','style',1,0);


INSERT INTO groups VALUES (13,'Export Managers','Users in this group can export pages to disk.',314496000,1000000000,NULL,997938000,997938000,14,-14,NULL,0,NULL,0,0,0,3600,NULL,1,1);

INSERT INTO groupGroupings VALUES (3,13);

