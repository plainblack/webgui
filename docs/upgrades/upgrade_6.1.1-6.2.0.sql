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
alter table WobjectProxy change proxiedTemplateId proxiedTemplateId char(22) not null default '1';

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
update template set templateId=-1 where templateId=1 and namespace='style';
update template set templateId=1 where templateId=2 and namespace='style';
update template set templateId=2 where templateId=-1 and namespace='style';
update page set styleId=-1 where styleId=1;
update page set styleId=1 where styleId=2;
update page set styleId=2 where styleId=-1;
alter table page drop column id;
alter table page add subroutine varchar(255) not null default 'generate';
alter table page add subroutinePackage varchar(255) not null default 'WebGUI::Page';
alter table page add subroutineParams text;
alter table forum add postPreviewTemplateId varchar(22) NULL after postformTemplateId;
alter table forum add usePreview int(11) NOT NULL default 1;
INSERT INTO template VALUES (1,'Default Post Preview','<h2><tmpl_var newpost.header></h2>\n\n<h1><tmpl_var post.subject></h1>\n\n<table width=\"100%\">\n<tr>\n<td class=\"content\" valign=\"top\">\n<tmpl_var post.message>\n</td>\n</tr>\n</table>\n\n<tmpl_var form.begin>\n<input type=\"button\" value=\"cancel\" onclick=\"window.history.go(-1)\"><tmpl_var form.submit>\n<tmpl_var form.end>\n','Forum/PostPreview',1,1);
UPDATE userProfileField SET dataValues = '{\r\n6=>WebGUI::International::get(\'HTMLArea 3\'),\r\n1=>WebGUI::International::get(495), #htmlArea\r\n#2=>WebGUI::International::get(494), #editOnPro2\r\n3=>WebGUI::International::get(887), #midas\r\n4=>WebGUI::International::get(879), #classic\r\n5=>WebGUI::International::get(880),\r\nnone=>WebGUI::International::get(881)\r\n}' WHERE fieldName = 'richEditor';
INSERT INTO template VALUES ('6','HTMLArea 3 (Mozilla / IE)','<script language=\"JavaScript\"> \r\nfunction fixChars(element) { \r\nelement.value = element.value.replace(/-/mg,\"-\"); \r\n} \r\n</script> \r\n\r\n<tmpl_if htmlArea3.supported> \r\n\r\n<script type=\"text/javascript\"> \r\n_editor_url = \"<tmpl_var session.config.extrasURL>/htmlArea3/\"; \r\n_editor_lang = \"en\"; \r\n</script> \r\n<script type=\"text/javascript\" src=\"<tmpl_var session.config.extrasURL>/htmlArea3/htmlarea.js\"></script> \r\n<script language=\"JavaScript\"> \r\nHTMLArea.loadPlugin(\"TableOperations\"); \r\n//HTMLArea.loadPlugin(\"FullPage\"); \r\nfunction initEditor() { \r\n// create an editor for the textbox \r\neditor = new HTMLArea(\"<tmpl_var form.name>\"); \r\n\r\n// register the FullPage plugin \r\//neditor.registerPlugin(FullPage); \r\n\r\n// register the SpellChecker plugin \r\neditor.registerPlugin(TableOperations); \r\n\r\nsetTimeout(function() { \r\neditor.generate(); \r\n}, 500); \r\nreturn false; \r\n} \r\nwindow.setTimeout(\"initEditor()\", 250); \r\n</script> \r\n</tmpl_if> \r\n\r\n<tmpl_var textarea> ','richEditor',1,1);
alter table page add encryptPage int(11) default 0;
alter table USS_submission add startDate int(11) default 946710000;
alter table USS_submission add endDate int(11) default 2114406000;
update template set template = '<h1><tmpl_var submission.header.label></h1><tmpl_var form.header><table><tmpl_if user.isVisitor> <tmpl_if submission.isNew><tr><td><tmpl_var visitorName.label></td><td><tmpl_var visitorName.form></td></tr></tmpl_if> </tmpl_if><tr><td><tmpl_var title.label></td><td><tmpl_var title.form></td></tr><tr><td><tmpl_var body.label></td><td><tmpl_var body.form></td></tr><tr><td><tmpl_var image.label></td><td><tmpl_var image.form></td></tr><tr><td><tmpl_var attachment.label></td><td><tmpl_var attachment.form></td></tr><tr><td><tmpl_var contentType.label></td><td><tmpl_var contentType.form></td></tr><tr><td><tmpl_var startDate.label></td><td><tmpl_var startDate.form></td></tr><tr><td><tmpl_var endDate.label></td><td><tmpl_var endDate.form></td></tr><tr><td></td><td><tmpl_var form.submit></td></tr></table><tmpl_var form.footer>' where templateId=1 and namespace = 'USS/SubmissionForm';
update template set template = '<tmpl_if displayTitle>    <h1><tmpl_var title></h1></tmpl_if><tmpl_if description>    <tmpl_var description><p /></tmpl_if><tmpl_if session.scratch.search> <tmpl_var search.form></tmpl_if><table width="100%" cellpadding=2 cellspacing=1 border=0><tr><td align="right" class="tableMenu"><tmpl_if canPost>   <a href="<tmpl_var post.url>"><tmpl_var post.label></a> &middot;</tmpl_if><a href="<tmpl_var search.url>"><tmpl_var search.label></a></td></tr></table><table width="100%" cellspacing=1 cellpadding=2 border=0><tr><td class="tableHeader"><tmpl_var title.label></td><td class="tableHeader"><tmpl_var date.label></td><td class="tableHeader"><tmpl_var by.label></td></tr><tmpl_loop submissions_loop><tmpl_if submission.inDateRange><tr><td class="tableData">     <a href="<tmpl_var submission.URL>">  <tmpl_var submission.title>    <tmpl_if submission.currentUser>        (<tmpl_var submission.status>)     </tmpl_if></td><td class="tableData"><tmpl_var submission.date></td><td class="tableData"><a href="<tmpl_var submission.userProfile>"><tmpl_var submission.username></a></td></tr><tmpl_else> <tmpl_if canModerate><tr><td class="tableData">     <i>*<a href="<tmpl_var submission.URL>">  <tmpl_var submission.title>    <tmpl_if submission.currentUser>        (<tmpl_var submission.status>)     </tmpl_if></i></td><td class="tableData"><i><tmpl_var submission.date></i></td><td class="tableData"><i><a href="<tmpl_var submission.userProfile>"><tmpl_var submission.username></a></i></td></tr> </tmpl_if></tmpl_if></tmpl_loop></table><tmpl_if pagination.pageCount.isMultiple>  <div class="pagination">    <tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>  </div></tmpl_if>' where templateId=1 and namespace='USS';
delete from template where templateId>=1 and templateId<=6 and namespace='richEditor';
delete from template where templateId=6 and namespace='Navigation';
INSERT INTO template (templateId, name, template, namespace, isEditable, showInForms) VALUES ('6','dtree','^StyleSheet(\"<tmpl_var session.config.extrasURL>/Navigation/dtree/dtree.css\");\r\n^JavaScript(\"<tmpl_var session.config.extrasURL>/Navigation/dtree/dtree.js\");\r\n\r\n<tmpl_if session.var.adminOn>\r\n<tmpl_var config.button>\r\n</tmpl_if>\r\n\r\n<script>\r\n// Path to dtree directory\r\n_dtree_url = \"<tmpl_var session.config.extrasURL>/Navigation/dtree/\";\r\n</script>\r\n\r\n<div class=\"dtree\">\r\n<script type=\"text/javascript\">\r\n<!--\r\n	d = new dTree(\'d\');\r\n	<tmpl_loop page_loop>\r\n	d.add(\r\n		<tmpl_var page.pageId>,\r\n		<tmpl_if __first__>-99<tmpl_else><tmpl_var page.parentId></tmpl_if>,\r\n		\'<tmpl_var page.menuTitle>\',\r\n		\'<tmpl_var page.url>\',\r\n		\'<tmpl_var page.synopsis>\'\r\n		<tmpl_if page.newWindow>,\'_blank\'</tmpl_if>\r\n	);\r\n	</tmpl_loop>\r\n	document.write(d);\r\n//-->\r\n</script>\r\n\r\n</div>','Navigation',1,1);
delete from template where templateId=7 and namespace='Navigation';
delete from template where templateId=2 and namespace='Macro/AdminBar';
INSERT INTO template (templateId, name, template, namespace, isEditable, showInForms) VALUES ('2','DHTML Admin Bar','^JavaScript(\"<tmpl_var session.config.extrasURL>/coolmenus/coolmenus4.js\");\r\n<style type=\"text/css\">\r\n                                                                                                                                                          \r\n.adminBarTop,.adminBarTopOver,.adminBarSub,.adminBarSubOver{position:absolute; overflow:hidden; cursor:pointer; cursor:hand}\r\n.adminBarTop,.adminBarTopOver{padding:4px; font-size:12px; font-weight:bold}\r\n.adminBarTop{color:white; border: 1px solid #aaaaaa; }\r\n.adminBarTopOver,.adminBarSubOver{color:#EC4300;}\r\n.adminBarSub,.adminBarSubOver{padding:2px; font-size:11px; font-weight:bold}\r\n.adminBarSub{color: white; background-color: #666666; layer-background-color: #666666;}\r\n.adminBarSubOver,.adminBarSubOver,.adminBarBorder,.adminBarBkg{layer-background-color: black; background-color: black;}\r\n.adminBarBorder{position:absolute; visibility:hidden; z-index:300}\r\n.adminBarBkg{position:absolute; width:10; height:10; visibility:hidden; }\r\n</style>\r\n\r\n<script language=\"JavaScript1.2\">\r\n/*****************************************************************************\nCopyright (c) 2001 Thomas Brattli (webmaster@dhtmlcentral.com)\n                                                                                                                                                             \nDHTML coolMenus - Get it at coolmenus.dhtmlcentral.com\nVersion 4.0_beta\nThis script can be used freely as long as all copyright messages are\nintact.\n                                                                                                                                                             \nExtra info - Coolmenus reference/help - Extra links to help files ****\nCSS help: http://192.168.1.31/projects/coolmenus/reference.asp?m=37\nGeneral: http://coolmenus.dhtmlcentral.com/reference.asp?m=35\nMenu properties: http://coolmenus.dhtmlcentral.com/properties.asp?m=47\nLevel properties: http://coolmenus.dhtmlcentral.com/properties.asp?m=48\nBackground bar properties: http://coolmenus.dhtmlcentral.com/properties.asp?m=49\nItem properties: http://coolmenus.dhtmlcentral.com/properties.asp?m=50\n******************************************************************************/\nadminBar=new makeCM(\"adminBar\"); \r\n\r\n//menu properties\r\nadminBar.resizeCheck=1; \r\nadminBar.rows=1;  \r\nadminBar.onlineRoot=\"\"; \r\nadminBar.pxBetween =0;\r\nadminBar.fillImg=\"\"; \r\nadminBar.fromTop=0; \r\nadminBar.fromLeft=30; \r\nadminBar.wait=600; \r\nadminBar.zIndex=10000;\r\nadminBar.menuPlacement=\"left\";\r\n\r\n//background bar properties\r\nadminBar.useBar=1; \r\nadminBar.barWidth=\"\"; \r\nadminBar.barHeight=\"menu\"; \r\nadminBar.barX=0;\r\nadminBar.barY=\"menu\"; \r\nadminBar.barClass=\"adminBarBkg\";\r\nadminBar.barBorderX=0; \r\nadminBar.barBorderY=0;\r\n\r\nadminBar.level[0]=new cm_makeLevel(160,20,\"adminBarTop\",\"adminBarTopOver\",1,1,\"adminBarBorder\",0,\"bottom\",0,0,0,0,0);\r\nadminBar.level[1]=new cm_makeLevel(160,18,\"adminBarSub\",\"adminBarSubOver\",1,1,\"adminBarBorder\",0,\"right\",0,5,\"menu_arrow.gif\",10,10);\r\n\r\n\r\nadminBar.makeMenu(\'addcontent\',\'\',\'<tmpl_var addcontent.label>\',\'\');\r\n\r\n\r\nadminBar.makeMenu(\'clipboard\',\'addcontent\',\'<tmpl_var clipboard.label> &raquo;\',\'\');\r\n<tmpl_loop clipboard_loop> \r\n	adminBar.makeMenu(\'clipboard<tmpl_var clipboard.count>\',\'clipboard\',\'<tmpl_var clipboard.label>\',\'<tmpl_var clipboard.url>\');\r\n</tmpl_loop>\r\n\r\n\r\nadminBar.makeMenu(\'contentTypes\',\'addcontent\',\'<tmpl_var contentTypes.label> &raquo;\',\'\');\r\n<tmpl_loop contentTypes_loop> \r\n	adminBar.makeMenu(\'contentTypes<tmpl_var contentType.count>\',\'contentTypes\',\'<tmpl_var contentType.label>\',\'<tmpl_var contentType.url>\');\r\n</tmpl_loop>\r\n\r\n<tmpl_if packages.canAdd>\r\nadminBar.makeMenu(\'packages\',\'addcontent\',\'<tmpl_var packages.label> &raquo;\',\'\');\r\n<tmpl_loop package_loop> \r\n	adminBar.makeMenu(\'package<tmpl_var package.count>\',\'packages\',\'<tmpl_var package.label>\',\'<tmpl_var package.url>\');\r\n</tmpl_loop>\r\n</tmpl_if>\r\n\r\nadminBar.makeMenu(\'page\',\'addcontent\',\'<tmpl_var addpage.label>\',\'<tmpl_var addpage.url>\');\r\n\r\nadminBar.makeMenu(\'admin\',\'\',\'<tmpl_var admin.label>\',\'\');\r\n<tmpl_loop admin_loop> \r\n	adminBar.makeMenu(\'admin<tmpl_var admin.count>\',\'admin\',\'<tmpl_var admin.label>\',\'<tmpl_var admin.url>\');\r\n</tmpl_loop>\r\n \r\nadminBar.construct()\r\n</script>\r\n','Macro/AdminBar',1,1);
INSERT INTO template (templateId, name, template, namespace, isEditable, showInForms) VALUES ('7','Cool Menus','<tmpl_if session.var.adminOn>\r\n<tmpl_var config.button>\r\n</tmpl_if>\r\n\r\n<style>\r\n/* CoolMenus 4 - default styles - do not edit */\r\n.cCMAbs{position:absolute; visibility:hidden; left:0; top:0}\r\n/* CoolMenus 4 - default styles - end */\r\n\r\n/*Styles for level 0*/\r\n.cLevel0,.cLevel0over{position:absolute; padding:2px; font-family:tahoma,arial,helvetica; font-size:12px; font-weight:bold;\r\n\r\n}\r\n.cLevel0{background-color:navy; layer-background-color:navy; color:white;\r\ntext-align: center;\r\n}\r\n.cLevel0over{background-color:navy; layer-background-color:navy; color:white; cursor:pointer; cursor:hand; \r\ntext-align: center; \r\n}\r\n\r\n.cLevel0border{position:absolute; visibility:hidden; background-color:#569635; layer-background-color:#006699; \r\n \r\n}\r\n\r\n\r\n/*Styles for level 1*/\r\n.cLevel1, .cLevel1over{position:absolute; padding:2px; font-family:tahoma, arial,helvetica; font-size:11px; font-weight:bold}\r\n.cLevel1{background-color:Navy; layer-background-color:Navy; color:white;}\r\n.cLevel1over{background-color:#336699; layer-background-color:#336699; color:Yellow; cursor:pointer; cursor:hand; }\r\n.cLevel1border{position:absolute; visibility:hidden; background-color:#006699; layer-background-color:#006699}\r\n\r\n/*Styles for level 2*/\r\n.cLevel2, .cLevel2over{position:absolute; padding:2px; font-family:tahoma,arial,helvetica; font-size:10px; font-weight:bold}\r\n.cLevel2{background-color:Navy; layer-background-color:Navy; color:white;}\r\n.cLevel2over{background-color:#0099cc; layer-background-color:#0099cc; color:Yellow; cursor:pointer; cursor:hand; }\r\n.cLevel2border{position:absolute; visibility:hidden; background-color:#006699; layer-background-color:#006699}\r\n\r\n</style>\r\n\r\n  \r\n\r\n^JavaScript(\"<tmpl_var session.config.extrasURL>/coolmenus/coolmenus4.js\");\r\n<script language=\"JavaScript\">\r\n/*****************************************************************************\nCopyright (c) 2001 Thomas Brattli (webmaster@dhtmlcentral.com)\n\nDHTML coolMenus - Get it at coolmenus.dhtmlcentral.com\nVersion 4.0_beta\nThis script can be used freely as long as all copyright messages are\nintact.\n\nExtra info - Coolmenus reference/help - Extra links to help files **** \nCSS help: http://coolmenus.dhtmlcentral.com/projects/coolmenus/reference.asp?m=37\nGeneral: http://coolmenus.dhtmlcentral.com/reference.asp?m=35\nMenu properties: http://coolmenus.dhtmlcentral.com/properties.asp?m=47\nLevel properties: http://coolmenus.dhtmlcentral.com/properties.asp?m=48\n\nBackground bar properties: http://coolmenus.dhtmlcentral.com/properties.asp?m=49\nItem properties: http://coolmenus.dhtmlcentral.com/properties.asp?m=50\n******************************************************************************/\n\r\n/*** \r\nThis is the menu creation code - place it right after you body tag\r\nFeel free to add this to a stand-alone js file and link it to your page.\r\n**/\r\n\r\n//Menu object creation\r\ncoolmenu=new makeCM(\"coolmenu\") //Making the menu object. Argument: menuname\r\n\r\ncoolmenu.frames = 0\r\n\r\n//Menu properties   \r\ncoolmenu.pxBetween=2\r\ncoolmenu.fromLeft=200 \r\ncoolmenu.fromTop=100   \r\ncoolmenu.rows=1\r\ncoolmenu.menuPlacement=\"center\"   //The whole menu alignment, left, center, or right\r\n                                                             \r\ncoolmenu.resizeCheck=1 \r\ncoolmenu.wait=1000 \r\ncoolmenu.fillImg=\"cm_fill.gif\"\r\ncoolmenu.zIndex=100\r\n\r\n//Background bar properties\r\ncoolmenu.useBar=0\r\ncoolmenu.barWidth=\"100%\"\r\ncoolmenu.barHeight=\"menu\" \r\ncoolmenu.barClass=\"cBar\"\r\ncoolmenu.barX=0 \r\ncoolmenu.barY=0\r\ncoolmenu.barBorderX=0\r\ncoolmenu.barBorderY=0\r\ncoolmenu.barBorderClass=\"\"\r\n\r\n//Level properties - ALL properties have to be spesified in level 0\r\ncoolmenu.level[0]=new cm_makeLevel() //Add this for each new level\r\ncoolmenu.level[0].width=110\r\ncoolmenu.level[0].height=21 \r\ncoolmenu.level[0].regClass=\"cLevel0\"\r\ncoolmenu.level[0].overClass=\"cLevel0over\"\r\ncoolmenu.level[0].borderX=1\r\ncoolmenu.level[0].borderY=1\r\ncoolmenu.level[0].borderClass=\"cLevel0border\"\r\ncoolmenu.level[0].offsetX=0\r\ncoolmenu.level[0].offsetY=0\r\ncoolmenu.level[0].rows=0\r\ncoolmenu.level[0].arrow=0\r\ncoolmenu.level[0].arrowWidth=0\r\ncoolmenu.level[0].arrowHeight=0\r\ncoolmenu.level[0].align=\"bottom\"\r\n\r\n//EXAMPLE SUB LEVEL[1] PROPERTIES - You have to specify the properties you want different from LEVEL[0] - If you want all items to look the same just remove this\r\ncoolmenu.level[1]=new cm_makeLevel() //Add this for each new level (adding one to the number)\r\ncoolmenu.level[1].width=coolmenu.level[0].width+20\r\ncoolmenu.level[1].height=25\r\ncoolmenu.level[1].regClass=\"cLevel1\"\r\ncoolmenu.level[1].overClass=\"cLevel1over\"\r\ncoolmenu.level[1].borderX=1\r\ncoolmenu.level[1].borderY=1\r\ncoolmenu.level[1].align=\"right\" \r\ncoolmenu.level[1].offsetX=0\r\ncoolmenu.level[1].offsetY=0\r\ncoolmenu.level[1].borderClass=\"cLevel1border\"\r\n\r\n\r\n//EXAMPLE SUB LEVEL[2] PROPERTIES - You have to spesify the properties you want different from LEVEL[1] OR LEVEL[0] - If you want all items to look the same just remove this\r\ncoolmenu.level[2]=new cm_makeLevel() //Add this for each new level (adding one to the number)\r\ncoolmenu.level[2].width=coolmenu.level[0].width+20\r\ncoolmenu.level[2].height=25\r\ncoolmenu.level[2].offsetX=0\r\ncoolmenu.level[2].offsetY=0\r\ncoolmenu.level[2].regClass=\"cLevel2\"\r\ncoolmenu.level[2].overClass=\"cLevel2over\"\r\ncoolmenu.level[2].borderClass=\"cLevel2border\"\r\n\r\n//EXAMPLE SUB LEVEL[2] PROPERTIES - You have to spesify the properties you want different from LEVEL[1] OR LEVEL[0] - If you want all items to look the same just remove this\r\ncoolmenu.level[3]=new cm_makeLevel() //Add this for each new level (adding one to the number)\r\ncoolmenu.level[3].width=coolmenu.level[0].width+20\r\ncoolmenu.level[3].height=25\r\ncoolmenu.level[3].offsetX=0\r\ncoolmenu.level[3].offsetY=0\r\ncoolmenu.level[3].regClass=\"cLevel2\"\r\ncoolmenu.level[3].overClass=\"cLevel2over\"\r\ncoolmenu.level[3].borderClass=\"cLevel2border\"\r\n\r\n\r\n\r\n<tmpl_loop page_loop>\r\ncoolmenu.makeMenu(\'coolmenu_<tmpl_var page.urlizedTitle>\',\'coolmenu_<tmpl_var page.mother.urlizedTitle>\',\'<tmpl_var page.menuTitle>\',\'<tmpl_var page.url>\'<tmpl_if page.newWindow>,\'_blank\'</tmpl_if>);\r\n</tmpl_loop>\r\n\r\n\r\ncoolmenu.construct();\r\n\r\n</script>','Navigation',1,1);
INSERT INTO template (templateId, name, template, namespace, isEditable, showInForms) VALUES ('3','Midas','^JavaScript(\"<tmpl_var session.config.extrasURL>/textFix.js\");\r\n\r\n<tmpl_if midas.supported>\r\n   <script language=\"JavaScript\">\r\n      var formObj; \r\n      var extrasDir=\"<tmpl_var session.config.extrasURL\";\r\n      function openEditWindow(obj) {\r\n         formObj = obj;\r\n         window.open(\"<tmpl_var session.config.extrasURL>/midas/editor.html\",\"editWindow\",\"width=600,height=400,resizable=1\");                    }\r\n   </script>\r\n   <tmpl_var button>\r\n</tmpl_if>\r\n\r\n<tmpl_var textarea>\r\n','richEditor',1,1);
INSERT INTO template (templateId, name, template, namespace, isEditable, showInForms) VALUES ('4','Classic','^JavaScript(\"<tmpl_var session.config.extrasURL>/textFix.js\");\r\n\r\n<tmpl_if classic.supported>\r\n   <script language=\"JavaScript\">\r\n      var formObj; var extrasDir=\"<tmpl_var session.config.extrasURL>\";\r\n      function openEditWindow(obj) {\r\n         formObj = obj;\r\n         window.open(\"<tmpl_var session.config.extrasURL>/ie5edit.html\",\"editWindow\",\"width=490,height=400,resizable=1\");\r\n      }\r\n      function setContent(content) { \r\n         formObj.value = content; \r\n      } \r\n   </script>\r\n   <tmpl_var button>\r\n</tmpl_if>\r\n\r\n<tmpl_var textarea>\r\n','richEditor',1,1);
INSERT INTO template (templateId, name, template, namespace, isEditable, showInForms) VALUES ('2','EditOnPro2','^JavaScript(\"<tmpl_var session.config.extrasURL>/textFix.js\");\r\n\r\n<script language=\"JavaScript\">\r\nvar formObj;\r\nfunction openEditWindow(obj) {\r\n   formObj = obj;\r\n   window.open(\"<tmpl_var session.config.extrasURL>/eopro.html\",\"editWindow\",\"width=720,height=450,resizable=1\");\r\n} \r\n</script>','richEditor',1,1);
INSERT INTO template (templateId, name, template, namespace, isEditable, showInForms) VALUES ('6','HTMLArea 3 (Mozilla / IE)','^JavaScript(\"<tmpl_var session.config.extrasURL>/textFix.js\");\r\n<tmpl_if htmlArea3.supported> \r\n^RawHeadTags(\"\n<script type=\'text/javascript\'> \n _editor_url = \'<tmpl_var session.config.extrasURL>/htmlArea3/\'; \n _editor_lang = \'en\'; \n</script> \n\");\r\n^JavaScript(\"<tmpl_var session.config.extrasURL>/htmlArea3/htmlarea.js\"); \r\n^RawHeadTags(\"\n<script language=\'JavaScript\'> \r\n HTMLArea.loadPlugin(\'TableOperations\'); \r\n</script>\n\");\n<script language=\"JavaScript\"> \nfunction initEditor() { \r\n  editor = new HTMLArea(\"<tmpl_var form.name>\"); \r\n  editor.registerPlugin(TableOperations); \r\n\r\n  setTimeout(function() { \r\n   editor.generate(); \r\n   }, 500); \r\n  return false; \r\n} \r\nwindow.setTimeout(\"initEditor()\", 250); \r\n</script> \r\n</tmpl_if> \r\n\r\n<tmpl_var textarea> ','richEditor',1,1);
INSERT INTO template (templateId, name, template, namespace, isEditable, showInForms) VALUES ('5','lastResort','^JavaScript(\"<tmpl_var session.config.extrasURL>/textFix.js\");\r\n\r\n<script language=\"JavaScript\">\r\n      var formObj;\r\n      var extrasDir=\"<tmpl_var session.config.extrasURL>\";\r\n      function openEditWindow(obj) {\r\n         formObj = obj;\r\n         window.open(\"<tmpl_var session.config.extrasURL>/lastResortEdit.html\",\"editWindow\",\"width=500,height=410\");\r\n      }\r\n      function setContent(content) {\r\n         formObj.value = content;\r\n      } \r\n</script>\r\n\r\n<tmpl_var button>\r\n\r\n<tmpl_var textarea>','richEditor',1,1);
INSERT INTO template (templateId, name, template, namespace, isEditable, showInForms) VALUES ('1','HTMLArea','^JavaScript(\"<tmpl_var session.config.extrasURL>/textFix.js\");\r\n<tmpl_if htmlArea.supported>\r\n   <tmpl_if popup>\r\n      <script language=\"JavaScript\">\r\n	var formObj;\r\n        var extrasDir=\"<tmpl_var session.config.extrasURL>\";\r\n        function openEditWindow(obj) {\r\n           formObj = obj;\r\n           window.open(\"<tmpl_var session.config.extrasURL>/htmlArea/editor.html\",\"editWindow\",\"width=490,height=400,resizable=1\");\r\n        }\r\n        function setContent(content) {\r\n           formObj.value = content;\r\n        }\r\n      </script>\r\n   <tmpl_else>\r\n   ^JavaScript(\"<tmpl_var session.config.extrasURL>/htmlArea/editor.js\");\r\n   <script>\r\n var master = window;\n     _editor_url = \"<tmpl_var session.config.extrasURL>/htmlArea/\";\r\n   </script>      \r\n   </tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_var textarea>\r\n\r\n<tmpl_if htmlArea.supported>\r\n   <script language=\"Javascript1.2\">\r\n      editor_generate(\"<tmpl_var form.name>\");\r\n   </script>\r\n</tmpl_if>\r\n','richEditor',1,1);
alter table page add column isSystem int not null default 0;
update page set isSystem=1 where pageId in (4,3,2,5,0);
