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
alter table authentication change userId userId char(22) not null;
alter table collateral change userId userId char(22);
alter table forumPost change userId userId char(22);
alter table forumPostRating change userId userId char(22);
alter table forumRead change userId userId char(22) not null;
alter table forumSubscription change userId userId char(22) not null;
alter table forumThreadSubscription change userId userId char(22) not null;
alter table groupings change userId userId char(22) not null;
alter table karmaLog change userId userId char(22);
alter table messageLog change userId userId char(22) not null;
alter table page change ownerId ownerId char(22);
alter table pageStatistics change userId userId char(22);
alter table passiveProfileAOI change userId userId char(22) not null;
alter table passiveProfileLog change userId userId char(22);
alter table userLoginLog change userId userId char(22);
alter table userProfileData change userId userId char(22) not null;
alter table userSession change userId userId char(22);
alter table wobject change ownerId ownerId char(22);
alter table wobject change addedBy addedBy char(22);
alter table wobject change editedBy editedBy char(22);
alter table wobject change wobjectId wobjectId  char(22) not null;
alter table wobject change forumId forumId  char(22) not null;
alter table wobject change pageId pageId  char(22);
alter table wobject change groupIdView groupIdView  char(22);
alter table wobject change groupIdEdit groupIdEdit char(22);
alter table wobject change bufferUserId bufferUserId char(22);
alter table wobject change bufferPrevId bufferPrevId char(22);
alter table wobject change templateId templateId char(22);
alter table Article change wobjectId wobjectId char(22) not null;
alter table USS change wobjectId wobjectId char(22) not null;
alter table USS change groupToContribute groupToContribute char(22);
alter table USS change groupToApprove groupToApprove char(22);
alter table USS change submissionTemplateId submissionTemplateId char(22);
alter table USS change submissionFormTemplateId submissionFormTemplateId char(22);
alter table USS change submissionFormTemplateId submissionFormTemplateId char(22);
alter table USS change USS_id USS_id char(22);
alter table USS_submission change USS_submissionId USS_submissionId char(22) not null;
alter table USS_submission change forumId forumId char(22);
alter table USS_submission change USS_id USS_id char(22);
alter table DataForm change wobjectId wobjectId char(22) not null;
alter table DataForm change emailTemplateId emailTemplateId char(22);
alter table DataForm change acknowlegementTemplateId acknowlegementTemplateId char(22);
alter table DataForm change listTemplateId listTemplateId char(22);
alter table DataForm_entry change wobjectId wobjectId char(22);
alter table DataForm_entry change DataForm_entryId DataForm_entryId char(22) not null;
alter table DataForm_tab change wobjectId wobjectId char(22);
alter table DataForm_tab change DataForm_tabId DataForm_tabId char(22) not null;
alter table EventsCalendar change wobjectId wobjectId char(22) not null;
alter table EventsCalendar_event change wobjectId wobjectId char(22);
alter table FileManager change wobjectId wobjectId char(22) not null;
alter table FileManager_file change wobjectId wobjectId char(22);
alter table FileManager_file change FileManager_fileId FileManager_fileId char(22) not null;
alter table EventsCalendar_event change EventsCalendar_eventId EventsCalendar_eventId char(22) not null;
alter table EventsCalendar change eventTemplateId eventTemplateId char(22);
alter table EventsCalendar_event change EventsCalendar_recurringId EventsCalendar_recurringId char(22);
alter table FileManager_file change groupToView groupToView char(22);

delete from template where namespace='style' and templateId='10';
INSERT INTO template VALUES (10,'htmlArea Image Manager','<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n		<html>\n		<head>\n			<title><tmpl_var session.page.title> - <tmpl_var session.setting.companyName></title>\n			<tmpl_var head.tags>\n		<style type=\"text/css\">\r\nTD { font: 8pt \'MS Shell Dlg\', Helvetica, sans-serif; }\r\nTD.delete { font: italic 7pt \'MS Shell Dlg\', Helvetica, sans-serif; }\r\nTD.label { font: 8pt \'MS Shell Dlg\', Helvetica, sans-serif; background-color: #c0c0c0; }\r\nTD.none { font: italic 12pt \'MS Shell Dlg\', Helvetica, sans-serif; }\r\n\r\n</style>\r\n\n		</head>\n		<script language=\"javascript\">\r\nfunction findAncestor(element, name, type) {\r\n   while(element != null && (element.name != name || element.tagName != type))\r\n      element = element.parentElement;\r\n   return element;\r\n}\r\n</script>\r\n<script language=\"javascript\">\r\n\r\nfunction actionComplete(action, path, error, info) {\r\n   var manager = findAncestor(window.frameElement, \'manager\', \'TABLE\');\r\n   var wrapper = findAncestor(window.frameElement, \'wrapper\', \'TABLE\');\r\n\r\n   if(manager) {\r\n      if(error.length < 1) {\r\n         manager.all.actions.reset();\r\n         if(action == \'upload\') {\r\n            manager.all.actions.image.value = \'\';\r\n            manager.all.actions.name.value = \'\';\r\n           manager.all.actions.thumbnailSize.value = \'\';\r\n\r\n         }\r\n         if(action == \'create\')\r\n            manager.all.actions.folder.value = \'\';\r\n         if(action == \'delete\')\r\n            manager.all.txtFileName.value = \'\';\r\n      }\r\n      manager.all.actions.DPI.value = 96;\r\n      manager.all.actions.path.value = path;\r\n   }\r\n   if(wrapper)\r\n      wrapper.all.viewer.contentWindow.navigate(\'^/;?op=htmlAreaviewCollateral\');\r\n   if(error.length > 0)\r\n      alert(error);\r\n   else if(info.length > 0)\r\n      alert(info);\r\n}\r\n</script>\r\n\r\n<script language=\"javascript\">\r\nfunction deleteCollateral(options) {\r\n   var lister = findAncestor(window.frameElement, \'lister\', \'IFRAME\');\r\n\r\n   if(lister && confirm(\"Are you sure you want to delete this item ?\"))\r\n      lister.contentWindow.navigate(\'^/;?op=htmlAreaDelete&\' + options);\r\n}\r\n</script>\r\n</head>\r\n<body leftmargin=\"0\" topmargin=\"0\" marginwidth=\"0\" marginheight=\"0\">\r\n\n			<tmpl_var body.content>\n		\r\n</body>\n		</html>\n		','style',1,0);


INSERT INTO groups VALUES (13,'Export Managers','Users in this group can export pages to disk.',314496000,1000000000,NULL,997938000,997938000,14,-14,NULL,0,NULL,0,0,0,3600,NULL,1,1);

INSERT INTO groupGroupings VALUES (3,13);
alter table DataForm_entryData change wobjectId wobjectId char(22);
alter table DataForm_entryData change DataForm_entryId DataForm_entryId char(22) not null;
alter table DataForm_entryData change DataForm_fieldId DataForm_fieldId char(22) not null;
alter table DataForm_field change wobjectId wobjectId char(22);
alter table DataForm_field change DataForm_fieldId DataForm_fieldId char(22) not null;
alter table DataForm_field change DataForm_tabId DataForm_tabId char(22) not null default 0;
alter table HttpProxy change wobjectId wobjectId char(22) not null;
alter table IndexedSearch change wobjectId wobjectId char(22) not null;
alter table IndexedSearch_docInfo change pageId pageId char(22);
alter table IndexedSearch_docInfo change wobjectId wobjectId char(22);
alter table IndexedSearch_docInfo change page_groupIdView page_groupIdView char(22);
alter table IndexedSearch_docInfo change wobject_groupIdView wobject_groupIdView char(22);
alter table IndexedSearch_docInfo change wobject_special_groupIdView wobject_special_groupIdView char(22);
alter table IndexedSearch_docInfo change languageId languageId varchar(35);
alter table MessageBoard change wobjectId wobjectId char(22) not null;
alter table MessageBoard_forums change wobjectId wobjectId char(22);
alter table MessageBoard_forums change forumId forumId char(22);
alter table Navigation change navigationId navigationId char(22) not null;
alter table Navigation change templateId templateId char(22);
alter table Poll change wobjectId wobjectId char(22) not null;
alter table Poll change voteGroup voteGroup char(22);
alter table Poll_answer change wobjectId wobjectId char(22);
alter table Product change wobjectId wobjectId char(22) not null;
alter table Product_accessory change wobjectId wobjectId char(22) not null;
alter table Product_accessory change AccessoryWobjectId AccessoryWobjectId char(22) not null;
alter table Product_benefit change wobjectId wobjectId char(22);
alter table Product_benefit change Product_benefitId Product_benefitId char(22) not null;
alter table Product_feature change wobjectId wobjectId char(22);
alter table Product_feature change Product_featureId Product_featureId char(22) not null;
alter table Product_related change wobjectId wobjectId char(22) not null;
alter table Product_related change RelatedWobjectId RelatedWobjectId char(22) not null;
alter table Product_specification change wobjectId wobjectId char(22);
alter table Product_specification change Product_specificationId Product_specificationId char(22) not null;
alter table SQLReport change wobjectId wobjectId char(22) not null;
alter table SQLReport change databaseLinkId databaseLinkId char(22);
alter table SiteMap change wobjectId wobjectId char(22) not null;
alter table Survey change wobjectId wobjectId char(22) not null;
alter table Survey change groupToTakeSurvey groupToTakeSurvey char(22);
alter table Survey change groupToViewReports groupToViewReports char(22);
alter table Survey change Survey_id Survey_id char(22);
alter table Survey change responseTemplateId responseTemplateId char(22);
alter table Survey change reportcardTemplateId reportcardTemplateId char(22);
alter table Survey change overviewTemplateId overviewTemplateId char(22);
alter table Survey_answer change Survey_id Survey_id char(22);
alter table Survey_answer change Survey_questionId Survey_questionId char(22);
alter table Survey_answer change Survey_answerId Survey_answerId char(22) not null;
alter table Survey_answer change gotoQuestion gotoQuestion char(22);
alter table Survey_question change Survey_id Survey_id char(22);
alter table Survey_question change Survey_questionId Survey_questionId char(22) not null;
alter table Survey_question change gotoQuestion gotoQuestion char(22);
alter table Survey_questionResponse change Survey_id Survey_id char(22);
alter table Survey_questionResponse change Survey_answerId Survey_answerId char(22) not null;
alter table Survey_questionResponse change Survey_responseId Survey_responseId char(22) not null;
alter table Survey_questionResponse change Survey_questionId Survey_questionId char(22) not null;
alter table Survey_response change Survey_id Survey_id char(22);
alter table Survey_response change Survey_responseId Survey_responseId char(22) not null;
alter table SyndicatedContent change wobjectId wobjectId char(22) not null;
alter table WSClient change wobjectId wobjectId char(22) not null;
alter table WSClient drop column templateId;
alter table WobjectProxy change wobjectId wobjectId char(22) not null;
alter table WobjectProxy change proxiedWobjectId proxiedWobjectId char(22);
alter table collateral change collateralId collateralId char(22) not null;
alter table collateral change collateralFolderId collateralFolderId char(22);
alter table collateralFolder change collateralFolderId collateralFolderId char(22) not null;
alter table collateralFolder change parentId parentId char(22) not null;
alter table databaseLink change databaseLinkId databaseLinkId char(22) not null;
alter table forum change forumId forumId char(22) not null;
alter table forum change groupToPost groupToPost char(22);
alter table forum change groupToModerate groupToModerate char(22);
alter table forum change lastPostId lastPostId char(22);
alter table forum change forumTemplateId forumTemplateId char(22);
alter table forum change threadTemplateId threadTemplateId char(22);
alter table forum change postTemplateId postTemplateId char(22);
alter table forum change postformTemplateId postformTemplateId char(22);
alter table forum change notificationTemplateId notificationTemplateId char(22);
alter table forum change searchTemplateId searchTemplateId char(22);
alter table forum change groupToView groupToView char(22);
alter table forum change masterForumId masterForumId char(22);
alter table forumPost change forumPostId forumPostId char(22) not null;
alter table forumPost change parentId parentId char(22);
alter table forumPost change forumThreadId forumThreadId char(22);
alter table forumPostAttachment change forumPostAttachmentId forumPostAttachmentId char(22) not null;
alter table forumPostAttachment change forumPostId forumPostId char(22);
alter table forumPostRating change forumPostId forumPostId char(22);
alter table forumRead change forumPostId forumPostId char(22) not null;
alter table forumRead change forumThreadId forumThreadId char(22);
alter table forumSubscription change forumId forumId char(22) not null;
alter table forumThread change forumThreadId forumThreadId char(22) not null;
alter table forumThread change forumId forumId char(22);
alter table forumThread change rootPostId rootPostId char(22);
alter table forumThread change lastPostId lastPostId char(22);
alter table forumThreadSubscription change forumThreadId forumThreadId char(22) not null;
alter table groupGroupings change groupId groupId char(22) not null;
alter table groupGroupings change inGroup inGroup char(22) not null;
alter table groupings change groupId groupId char(22) not null;
alter table groups change groupId groupId char(22) not null;
alter table groups change databaseLinkId databaseLinkId char(22);
alter table messageLog change messageLogId messageLogId char(22) not null;
alter table metaData_properties change fieldId fieldId char(22) not null;
alter table metaData_values change fieldId fieldId char(22) not null;
alter table metaData_values change wobjectId wobjectId char(22) not null;
alter table page change pageId pageId char(22) not null;
alter table page change parentId parentId char(22);
alter table page change templateId templateId char(22);
alter table page change styleId styleId char(22);
alter table page change groupIdView groupIdView char(22);
alter table page change groupIdEdit groupIdEdit char(22);
alter table page change bufferUserId bufferUserId char(22);
alter table page change bufferPrevId bufferPrevId char(22);
alter table page change printableStyleId printableStyleId char(22);
alter table pageStatistics change pageId pageId char(22);
alter table pageStatistics change wobjectId wobjectId char(22);
alter table passiveProfileAOI change fieldId fieldId char(22) not null;
alter table passiveProfileLog change passiveProfileLogId passiveProfileLogId char(22) not null;
alter table passiveProfileLog change wobjectId wobjectId char(22);
alter table replacements change replacementId replacementId char(22) not null;
alter table template change templateId templateId char(22) not null;
alter table theme change themeId themeId char(22) not null;
alter table themeComponent change themeId themeId char(22);
alter table userProfileCategory change profileCategoryId profileCategoryId char(22) not null;
alter table userProfileField change profileCategoryId profileCategoryId char(22);
alter table userSession change sessionId sessionId char(22) not null;
alter table userSessionScratch change sessionId sessionId char(22) not null;
alter table users change referringAffiliate referringAffiliate char(22) not null;
alter table page change lft nestedSetLeft int(11);
alter table page change rgt nestedSetRight int(11);
alter table page change id id char(22);
delete from incrementer where incrementerId in ("messageLogId","profileCategoryId","templateId","navigationId","passiveProfileLogId","metaData_fieldId","userId","collateralId","pageId","databaseLinkId", "DataForm_entryId", "DataForm_fieldId", "DataForm_tabId", "EventsCalendar_eventId", "EventsCalendar_recurringId", "FileManager_fileId", "forumId", "forumPostId", "forumThreadId", "groupId", "languageId", "Product_benefitId", "Product_featureId", "Product_specificationId", "replacementId", "Survey_answerId", "Survey_id", "Survey_questionId", "Survey_responseId", "USS_id", "USS_submissionId", "wobjectId");
alter table forum change postsPerPage threadsPerPage int(11) default 30;
alter table forum add postsPerPage int(11) default 10 after threadsPerPage;
update page set title='Nameless Root',menuTitle='Nameless Root',urlizedTitle='nameless_root', redirectUrl='/' where pageId=0;
create table urls (
	urlId char(22) not null primary key,
	url varchar(255) not null unique key,
	subroutine varchar(255) not null,
	params text
);

alter table page drop column id;
alter table forum add postPreviewTemplateId varchar(22) NULL after postformTemplateId;
alter table forum add usePreview int(11) NOT NULL default 1;
INSERT INTO template VALUES (1,'Default Post Preview','<h2><tmpl_var newpost.header></h2>\n\n<h1><tmpl_var post.subject></h1>\n\n<table width=\"100%\">\n<tr>\n<td class=\"content\" valign=\"top\">\n<tmpl_var post.message>\n</td>\n</tr>\n</table>\n\n<tmpl_var form.begin>\n<input type=\"button\" value=\"cancel\" onclick=\"window.history.go(-1)\"><tmpl_var form.submit>\n<tmpl_var form.end>\n','Forum/PostPreview',1,1);
UPDATE userProfileField SET dataValues = '{\r\n6=>WebGUI::International::get(\'HTMLArea 3\'),\r\n1=>WebGUI::International::get(495), #htmlArea\r\n#2=>WebGUI::International::get(494), #editOnPro2\r\n3=>WebGUI::International::get(887), #midas\r\n4=>WebGUI::International::get(879), #classic\r\n5=>WebGUI::International::get(880),\r\nnone=>WebGUI::International::get(881)\r\n}' WHERE fieldName = 'richEditor';
INSERT INTO template VALUES ('6','HTMLArea 3 (Mozilla / IE)','<script language=\"JavaScript\"> \r\nfunction fixChars(element) { \r\nelement.value = element.value.replace(/-/mg,\"-\"); \r\n} \r\n</script> \r\n\r\n<tmpl_if htmlArea3.supported> \r\n\r\n<script type=\"text/javascript\"> \r\n_editor_url = \"<tmpl_var session.config.extrasURL>/htmlArea3/\"; \r\n_editor_lang = \"en\"; \r\n</script> \r\n<script type=\"text/javascript\" src=\"<tmpl_var session.config.extrasURL>/htmlArea3/htmlarea.js\"></script> \r\n<script language=\"JavaScript\"> \r\nHTMLArea.loadPlugin(\"TableOperations\"); \r\nHTMLArea.loadPlugin(\"FullPage\"); \r\nfunction initEditor() { \r\n// create an editor for the textbox \r\neditor = new HTMLArea(\"<tmpl_var form.name>\"); \r\n\r\n// register the FullPage plugin \r\neditor.registerPlugin(FullPage); \r\n\r\n// register the SpellChecker plugin \r\neditor.registerPlugin(TableOperations); \r\n\r\nsetTimeout(function() { \r\neditor.generate(); \r\n}, 500); \r\nreturn false; \r\n} \r\nwindow.setTimeout(\"initEditor()\", 250); \r\n</script> \r\n</tmpl_if> \r\n\r\n<tmpl_var textarea> ','richEditor',1,1);

