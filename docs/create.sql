-- MySQL dump 8.23
--
-- Host: localhost    Database: dev
---------------------------------------------------------
-- Server version	3.23.58

--
-- Table structure for table `Article`
--

CREATE TABLE Article (
  wobjectId int(11) NOT NULL default '0',
  image varchar(255) default NULL,
  linkTitle varchar(255) default NULL,
  linkURL text,
  attachment varchar(255) default NULL,
  convertCarriageReturns int(11) NOT NULL default '0',
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table `Article`
--


INSERT INTO Article VALUES (1,NULL,'','',NULL,0);
INSERT INTO Article VALUES (2,NULL,'','',NULL,0);
INSERT INTO Article VALUES (3,NULL,'','',NULL,0);
INSERT INTO Article VALUES (4,NULL,'','',NULL,0);

--
-- Table structure for table `DataForm`
--

CREATE TABLE DataForm (
  wobjectId int(11) NOT NULL default '0',
  acknowledgement text,
  mailData int(11) NOT NULL default '1',
  emailTemplateId int(11) NOT NULL default '2',
  acknowlegementTemplateId int(11) NOT NULL default '3',
  listTemplateId int(11) NOT NULL default '1'
) TYPE=MyISAM;

--
-- Dumping data for table `DataForm`
--


INSERT INTO DataForm VALUES (7,'Thank you for telling your friends about WebGUI!',1,2,3,1);

--
-- Table structure for table `DataForm_entry`
--

CREATE TABLE DataForm_entry (
  DataForm_entryId int(11) NOT NULL default '0',
  wobjectId int(11) NOT NULL default '0',
  userId int(11) default NULL,
  username varchar(255) default NULL,
  ipAddress varchar(255) default NULL,
  submissionDate int(11) NOT NULL default '0',
  PRIMARY KEY  (DataForm_entryId)
) TYPE=MyISAM;

--
-- Dumping data for table `DataForm_entry`
--



--
-- Table structure for table `DataForm_entryData`
--

CREATE TABLE DataForm_entryData (
  DataForm_entryId int(11) NOT NULL default '0',
  DataForm_fieldId int(11) NOT NULL default '0',
  wobjectId int(11) NOT NULL default '0',
  value text,
  PRIMARY KEY  (DataForm_entryId,DataForm_fieldId)
) TYPE=MyISAM;

--
-- Dumping data for table `DataForm_entryData`
--



--
-- Table structure for table `DataForm_field`
--

CREATE TABLE DataForm_field (
  wobjectId int(11) NOT NULL default '0',
  DataForm_fieldId int(11) NOT NULL default '0',
  sequenceNumber int(11) NOT NULL default '0',
  name varchar(255) NOT NULL default '',
  status varchar(35) default NULL,
  type varchar(30) NOT NULL default '',
  possibleValues text,
  defaultValue text,
  width int(11) default NULL,
  subtext mediumtext,
  rows int(11) default NULL,
  isMailField int(11) NOT NULL default '0',
  label varchar(255) default NULL,
  DataForm_tabId int(11) NOT NULL default '0',
  PRIMARY KEY  (DataForm_fieldId)
) TYPE=MyISAM;

--
-- Dumping data for table `DataForm_field`
--


INSERT INTO DataForm_field VALUES (7,1000,1,'from','required','email','','',0,'',0,1,'Your Email Address',0);
INSERT INTO DataForm_field VALUES (7,1001,2,'to','required','email','','',0,'',0,1,'Your Friends Email Address',0);
INSERT INTO DataForm_field VALUES (7,1002,3,'cc','hidden','email',NULL,NULL,0,NULL,NULL,1,'Cc',0);
INSERT INTO DataForm_field VALUES (7,1003,4,'bcc','hidden','email',NULL,NULL,0,NULL,NULL,1,'Bcc',0);
INSERT INTO DataForm_field VALUES (7,1004,5,'subject','hidden','text','','Cool CMS',0,'',0,1,'Subject',0);
INSERT INTO DataForm_field VALUES (7,1005,6,'url','visible','url','','http://www.plainblack.com/webgui',0,'',0,1,'URL',0);
INSERT INTO DataForm_field VALUES (7,1006,7,'message','required','textarea','','Hey I just wanted to tell you about this great program called WebGUI that I found: http://www.plainblack.com/webgui\r\n\r\nYou should really check it out.',34,'',6,0,'Message',0);

--
-- Table structure for table `DataForm_tab`
--

CREATE TABLE DataForm_tab (
  wobjectId int(11) NOT NULL default '0',
  label varchar(255) NOT NULL default '',
  subtext text,
  sequenceNumber int(11) NOT NULL default '0',
  DataForm_tabId int(11) NOT NULL default '0'
) TYPE=MyISAM;

--
-- Dumping data for table `DataForm_tab`
--



--
-- Table structure for table `EventsCalendar`
--

CREATE TABLE EventsCalendar (
  wobjectId int(11) NOT NULL default '0',
  calendarLayout varchar(30) NOT NULL default 'list',
  paginateAfter int(11) NOT NULL default '50',
  startMonth varchar(35) NOT NULL default 'current',
  endMonth varchar(35) NOT NULL default 'after12',
  defaultMonth varchar(35) NOT NULL default 'current',
  eventTemplateId int(11) NOT NULL default '1',
  isMaster int(11) NOT NULL default '0',
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table `EventsCalendar`
--



--
-- Table structure for table `EventsCalendar_event`
--

CREATE TABLE EventsCalendar_event (
  EventsCalendar_eventId int(11) NOT NULL default '0',
  wobjectId int(11) NOT NULL default '0',
  name varchar(255) default NULL,
  description text,
  startDate int(11) default NULL,
  endDate int(11) default NULL,
  EventsCalendar_recurringId int(11) NOT NULL default '0',
  PRIMARY KEY  (EventsCalendar_eventId),
  KEY EventsCalendar1 (wobjectId,endDate,startDate)
) TYPE=MyISAM;

--
-- Dumping data for table `EventsCalendar_event`
--



--
-- Table structure for table `FileManager`
--

CREATE TABLE FileManager (
  wobjectId int(11) NOT NULL default '0',
  paginateAfter int(11) NOT NULL default '50',
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table `FileManager`
--



--
-- Table structure for table `FileManager_file`
--

CREATE TABLE FileManager_file (
  FileManager_fileId int(11) NOT NULL default '0',
  wobjectId int(11) NOT NULL default '0',
  fileTitle varchar(128) NOT NULL default 'untitled',
  downloadFile varchar(255) default NULL,
  groupToView int(11) NOT NULL default '2',
  briefSynopsis varchar(255) default NULL,
  dateUploaded int(11) default NULL,
  sequenceNumber int(11) NOT NULL default '1',
  alternateVersion1 varchar(255) default NULL,
  alternateVersion2 varchar(255) default NULL,
  PRIMARY KEY  (FileManager_fileId)
) TYPE=MyISAM;

--
-- Dumping data for table `FileManager_file`
--



--
-- Table structure for table `HttpProxy`
--

CREATE TABLE HttpProxy (
  wobjectId int(11) NOT NULL default '0',
  proxiedUrl varchar(255) default NULL,
  timeout int(11) default NULL,
  removeStyle int(11) default NULL,
  filterHtml varchar(30) default NULL,
  followExternal int(11) default NULL,
  followRedirect int(11) default NULL,
  cacheHttp int(11) default '0',
  useCache int(11) default '0',
  debug int(11) default '0',
  rewriteUrls int(11) default NULL,
  searchFor varchar(255) default NULL,
  stopAt varchar(255) default NULL,
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table `HttpProxy`
--



--
-- Table structure for table `IndexedSearch`
--

CREATE TABLE IndexedSearch (
  wobjectId int(11) NOT NULL default '0',
  indexName varchar(35) default 'Search_index',
  users text,
  searchRoot text,
  pageList text,
  namespaces text,
  paginateAfter int(11) default NULL,
  languages text,
  contentTypes text,
  previewLength int(11) default NULL,
  highlight int(11) default NULL,
  highlight_1 varchar(35) default NULL,
  highlight_2 varchar(35) default NULL,
  highlight_3 varchar(35) default NULL,
  highlight_4 varchar(35) default NULL,
  highlight_5 varchar(35) default NULL,
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table `IndexedSearch`
--



--
-- Table structure for table `IndexedSearch_docInfo`
--

CREATE TABLE IndexedSearch_docInfo (
  docId int(11) NOT NULL default '0',
  indexName varchar(35) NOT NULL default 'Search_index',
  pageId int(11) NOT NULL default '0',
  wobjectId int(11) NOT NULL default '0',
  page_groupIdView int(11) default NULL,
  wobject_groupIdView int(11) default NULL,
  wobject_special_groupIdView int(11) default NULL,
  languageId int(11) NOT NULL default '0',
  namespace varchar(35) default NULL,
  location varchar(255) default NULL,
  headerShortcut text,
  bodyShortcut text,
  contentType text NOT NULL,
  ownerId int(11) default '1',
  dateIndexed int(11) NOT NULL default '0',
  PRIMARY KEY  (docId,indexName)
) TYPE=MyISAM;

--
-- Dumping data for table `IndexedSearch_docInfo`
--



--
-- Table structure for table `MessageBoard`
--

CREATE TABLE MessageBoard (
  wobjectId int(11) NOT NULL default '0',
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table `MessageBoard`
--



--
-- Table structure for table `MessageBoard_forums`
--

CREATE TABLE MessageBoard_forums (
  wobjectId int(11) default NULL,
  forumId int(11) default NULL,
  title varchar(255) default NULL,
  description text,
  sequenceNumber int(11) NOT NULL default '1'
) TYPE=MyISAM;

--
-- Dumping data for table `MessageBoard_forums`
--



--
-- Table structure for table `Navigation`
--

CREATE TABLE Navigation (
  navigationId int(11) NOT NULL default '0',
  identifier varchar(30) NOT NULL default 'undefined',
  depth int(11) NOT NULL default '99',
  method varchar(35) NOT NULL default 'descendants',
  startAt varchar(35) NOT NULL default 'current',
  stopAtLevel int(11) NOT NULL default '-1',
  templateId int(11) NOT NULL default '1',
  showSystemPages int(11) NOT NULL default '0',
  showHiddenPages int(11) NOT NULL default '0',
  showUnprivilegedPages int(11) NOT NULL default '0',
  reverse int(11) NOT NULL default '0',
  PRIMARY KEY  (navigationId,identifier)
) TYPE=MyISAM;

--
-- Dumping data for table `Navigation`
--


INSERT INTO Navigation VALUES (1,'crumbTrail',99,'self_and_ancestors','current',-1,2,0,0,0,1);
INSERT INTO Navigation VALUES (2,'FlexMenu',99,'pedigree','current',2,1,0,0,0,0);
INSERT INTO Navigation VALUES (3,'currentMenuVertical',1,'descendants','current',-1,1,0,0,0,0);
INSERT INTO Navigation VALUES (4,'currentMenuHorizontal',1,'descendants','current',-1,3,0,0,0,0);
INSERT INTO Navigation VALUES (5,'PreviousDropMenu',99,'self_and_sisters','current',-1,4,0,0,0,0);
INSERT INTO Navigation VALUES (6,'previousMenuVertical',1,'descendants','mother',-1,1,0,0,0,0);
INSERT INTO Navigation VALUES (7,'previousMenuHorizontal',1,'descendants','mother',-1,3,0,0,0,0);
INSERT INTO Navigation VALUES (8,'rootmenu',1,'daughters','root',-1,3,0,0,0,0);
INSERT INTO Navigation VALUES (9,'SpecificDropMenu',3,'descendants','home',-1,4,0,0,0,0);
INSERT INTO Navigation VALUES (10,'SpecificSubMenuVertical',3,'descendants','home',-1,1,0,0,0,0);
INSERT INTO Navigation VALUES (11,'SpecificSubMenuHorizontal',1,'descendants','home',-1,3,0,0,0,0);
INSERT INTO Navigation VALUES (12,'TopLevelMenuVertical',1,'descendants','WebGUIroot',-1,1,0,0,0,0);
INSERT INTO Navigation VALUES (13,'TopLevelMenuHorizontal',1,'descendants','WebGUIroot',-1,3,0,0,0,0);
INSERT INTO Navigation VALUES (14,'RootTab',99,'daughters','root',-1,5,0,0,0,0);
INSERT INTO Navigation VALUES (15,'TopDropMenu',1,'decendants','WebGUIroot',-1,4,0,0,0,0);
INSERT INTO Navigation VALUES (16,'dtree',99,'self_and_descendants','WebGUIroot',-1,6,0,0,0,0);
INSERT INTO Navigation VALUES (17,'coolmenu',99,'descendants','WebGUIroot',-1,7,0,0,0,0);
INSERT INTO Navigation VALUES (18,'Synopsis',99,'self_and_descendants','current',-1,8,0,0,0,0);
INSERT INTO Navigation VALUES (1000,'TopLevelMenuHorizontal_1000',1,'WebGUIroot','WebGUIroot',-1,1000,0,0,0,0);
INSERT INTO Navigation VALUES (1001,'currentMenuHorizontal_1001',1,'descendants','current',-1,1001,0,0,0,0);
INSERT INTO Navigation VALUES (1002,'FlexMenu_1002',99,'pedigree','current',2,1,0,0,0,0);

--
-- Table structure for table `Poll`
--

CREATE TABLE Poll (
  wobjectId int(11) NOT NULL default '0',
  active int(11) NOT NULL default '1',
  graphWidth int(11) NOT NULL default '150',
  voteGroup int(11) default NULL,
  question varchar(255) default NULL,
  a1 varchar(255) default NULL,
  a2 varchar(255) default NULL,
  a3 varchar(255) default NULL,
  a4 varchar(255) default NULL,
  a5 varchar(255) default NULL,
  a6 varchar(255) default NULL,
  a7 varchar(255) default NULL,
  a8 varchar(255) default NULL,
  a9 varchar(255) default NULL,
  a10 varchar(255) default NULL,
  a11 varchar(255) default NULL,
  a12 varchar(255) default NULL,
  a13 varchar(255) default NULL,
  a14 varchar(255) default NULL,
  a15 varchar(255) default NULL,
  a16 varchar(255) default NULL,
  a17 varchar(255) default NULL,
  a18 varchar(255) default NULL,
  a19 varchar(255) default NULL,
  a20 varchar(255) default NULL,
  karmaPerVote int(11) NOT NULL default '0',
  randomizeAnswers int(11) NOT NULL default '0',
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table `Poll`
--



--
-- Table structure for table `Poll_answer`
--

CREATE TABLE Poll_answer (
  wobjectId int(11) NOT NULL default '0',
  answer char(3) default NULL,
  userId int(11) default NULL,
  ipAddress varchar(50) default NULL
) TYPE=MyISAM;

--
-- Dumping data for table `Poll_answer`
--



--
-- Table structure for table `Product`
--

CREATE TABLE Product (
  wobjectId int(11) NOT NULL default '0',
  image1 varchar(255) default NULL,
  image2 varchar(255) default NULL,
  image3 varchar(255) default NULL,
  brochure varchar(255) default NULL,
  manual varchar(255) default NULL,
  warranty varchar(255) default NULL,
  price varchar(255) default NULL,
  productNumber varchar(255) default NULL,
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table `Product`
--



--
-- Table structure for table `Product_accessory`
--

CREATE TABLE Product_accessory (
  wobjectId int(11) NOT NULL default '0',
  AccessoryWobjectId int(11) NOT NULL default '0',
  sequenceNumber int(11) NOT NULL default '0',
  PRIMARY KEY  (wobjectId,AccessoryWobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table `Product_accessory`
--



--
-- Table structure for table `Product_benefit`
--

CREATE TABLE Product_benefit (
  wobjectId int(11) NOT NULL default '0',
  Product_benefitId int(11) NOT NULL default '0',
  benefit varchar(255) default NULL,
  sequenceNumber int(11) NOT NULL default '0',
  PRIMARY KEY  (Product_benefitId)
) TYPE=MyISAM;

--
-- Dumping data for table `Product_benefit`
--



--
-- Table structure for table `Product_feature`
--

CREATE TABLE Product_feature (
  wobjectId int(11) NOT NULL default '0',
  Product_featureId int(11) NOT NULL default '0',
  feature varchar(255) default NULL,
  sequenceNumber int(11) NOT NULL default '0',
  PRIMARY KEY  (Product_featureId)
) TYPE=MyISAM;

--
-- Dumping data for table `Product_feature`
--



--
-- Table structure for table `Product_related`
--

CREATE TABLE Product_related (
  wobjectId int(11) NOT NULL default '0',
  RelatedWobjectId int(11) NOT NULL default '0',
  sequenceNumber int(11) NOT NULL default '0',
  PRIMARY KEY  (wobjectId,RelatedWobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table `Product_related`
--



--
-- Table structure for table `Product_specification`
--

CREATE TABLE Product_specification (
  wobjectId int(11) NOT NULL default '0',
  Product_specificationId int(11) NOT NULL default '0',
  name varchar(255) default NULL,
  value varchar(255) default NULL,
  units varchar(255) default NULL,
  sequenceNumber int(11) NOT NULL default '0',
  PRIMARY KEY  (Product_specificationId)
) TYPE=MyISAM;

--
-- Dumping data for table `Product_specification`
--



--
-- Table structure for table `SQLReport`
--

CREATE TABLE SQLReport (
  wobjectId int(11) NOT NULL default '0',
  dbQuery text,
  paginateAfter int(11) NOT NULL default '50',
  preprocessMacros int(11) NOT NULL default '0',
  debugMode int(11) NOT NULL default '0',
  databaseLinkId int(11) NOT NULL default '0',
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table `SQLReport`
--



--
-- Table structure for table `SiteMap`
--

CREATE TABLE SiteMap (
  wobjectId int(11) NOT NULL default '0',
  startAtThisLevel int(11) NOT NULL default '0',
  depth int(11) NOT NULL default '0',
  indent int(11) NOT NULL default '5',
  alphabetic int(11) NOT NULL default '0',
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table `SiteMap`
--


INSERT INTO SiteMap VALUES (-1,1,0,5,0);
INSERT INTO SiteMap VALUES (8,0,0,5,0);

--
-- Table structure for table `Survey`
--

CREATE TABLE Survey (
  wobjectId int(11) NOT NULL default '0',
  questionOrder varchar(30) default NULL,
  groupToTakeSurvey int(11) default NULL,
  groupToViewReports int(11) default NULL,
  mode varchar(30) default NULL,
  Survey_id int(11) NOT NULL default '0',
  anonymous char(1) NOT NULL default '0',
  questionsPerPage int(11) NOT NULL default '1',
  responseTemplateId int(11) NOT NULL default '1',
  reportcardTemplateId int(11) NOT NULL default '1',
  overviewTemplateId int(11) NOT NULL default '1',
  maxResponsesPerUser int(11) NOT NULL default '1',
  questionsPerResponse int(11) NOT NULL default '9999999',
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table `Survey`
--



--
-- Table structure for table `Survey_answer`
--

CREATE TABLE Survey_answer (
  Survey_id int(11) default NULL,
  Survey_questionId int(11) NOT NULL default '0',
  Survey_answerId int(11) NOT NULL default '0',
  sequenceNumber int(11) NOT NULL default '1',
  gotoQuestion int(11) default NULL,
  answer varchar(255) default NULL,
  isCorrect int(11) NOT NULL default '0',
  PRIMARY KEY  (Survey_answerId)
) TYPE=MyISAM;

--
-- Dumping data for table `Survey_answer`
--



--
-- Table structure for table `Survey_question`
--

CREATE TABLE Survey_question (
  Survey_id int(11) default NULL,
  Survey_questionId int(11) NOT NULL default '0',
  question text,
  sequenceNumber int(11) NOT NULL default '1',
  allowComment int(11) NOT NULL default '0',
  randomizeAnswers int(11) NOT NULL default '0',
  answerFieldType varchar(35) default NULL,
  gotoQuestion int(11) default NULL,
  PRIMARY KEY  (Survey_questionId)
) TYPE=MyISAM;

--
-- Dumping data for table `Survey_question`
--



--
-- Table structure for table `Survey_questionResponse`
--

CREATE TABLE Survey_questionResponse (
  Survey_id int(11) default NULL,
  Survey_questionId int(11) NOT NULL default '0',
  Survey_answerId int(11) NOT NULL default '0',
  Survey_responseId int(11) NOT NULL default '0',
  response varchar(255) default NULL,
  comment text,
  dateOfResponse int(11) default NULL,
  PRIMARY KEY  (Survey_questionId,Survey_answerId,Survey_responseId)
) TYPE=MyISAM;

--
-- Dumping data for table `Survey_questionResponse`
--



--
-- Table structure for table `Survey_response`
--

CREATE TABLE Survey_response (
  Survey_id int(11) default NULL,
  Survey_responseId int(11) NOT NULL default '0',
  userId varchar(11) default NULL,
  username varchar(255) default NULL,
  ipAddress varchar(15) default NULL,
  startDate int(11) default NULL,
  endDate int(11) default NULL,
  isComplete int(11) NOT NULL default '0',
  PRIMARY KEY  (Survey_responseId)
) TYPE=MyISAM;

--
-- Dumping data for table `Survey_response`
--



--
-- Table structure for table `SyndicatedContent`
--

CREATE TABLE SyndicatedContent (
  wobjectId int(11) NOT NULL default '0',
  rssUrl text,
  maxHeadlines int(11) NOT NULL default '0',
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table `SyndicatedContent`
--


INSERT INTO SyndicatedContent VALUES (6,'http://www.plainblack.com/news?wid=920&func=viewRSS',3);

--
-- Table structure for table `USS`
--

CREATE TABLE USS (
  wobjectId int(11) NOT NULL default '0',
  groupToContribute int(11) default NULL,
  submissionsPerPage int(11) NOT NULL default '50',
  defaultStatus varchar(30) default 'Approved',
  groupToApprove int(11) NOT NULL default '4',
  karmaPerSubmission int(11) NOT NULL default '0',
  submissionTemplateId int(11) NOT NULL default '1',
  filterContent varchar(30) NOT NULL default 'javascript',
  sortBy varchar(35) NOT NULL default 'dateUpdated',
  sortOrder varchar(4) NOT NULL default 'desc',
  USS_id int(11) NOT NULL default '0',
  submissionFormTemplateId int(11) NOT NULL default '1',
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table `USS`
--


INSERT INTO USS VALUES (5,3,1000,'Approved',4,0,1,'none','sequenceNumber','asc',1000,3);

--
-- Table structure for table `USS_submission`
--

CREATE TABLE USS_submission (
  USS_submissionId int(11) NOT NULL default '0',
  title varchar(128) default NULL,
  dateSubmitted int(11) default NULL,
  username varchar(30) default NULL,
  userId int(11) NOT NULL default '1',
  content text,
  image varchar(255) default NULL,
  attachment varchar(255) default NULL,
  status varchar(30) NOT NULL default 'Approved',
  views int(11) NOT NULL default '0',
  forumId int(11) default NULL,
  dateUpdated int(11) NOT NULL default '0',
  sequenceNumber int(11) NOT NULL default '0',
  USS_id int(11) NOT NULL default '0',
  contentType varchar(35) NOT NULL default 'mixed',
  userDefined1 text,
  userDefined2 text,
  userDefined3 text,
  userDefined4 text,
  userDefined5 text,
  startDate int(11) default 946710000,
  endDate int(11) default 2114406000,
  PRIMARY KEY  (USS_submissionId),
  KEY test (status,userId)
) TYPE=MyISAM;

--
-- Dumping data for table `USS_submission`
--


INSERT INTO USS_submission VALUES (1,'Talk to the Experts',1076705448,'Admin',3,'<img src=\"^Extras;styles/webgui6/img_talk_to_experts.gif\" align=\"right\" style=\"padding-left: 15px;\" /> Our website contains all of the different methods for reaching us. Our friendly staff will be happy to assist you in any way possible.\r\n\r\n',NULL,NULL,'Approved',0,1004,1076706084,0,1000,'html','http://www.plainblack.com/contact_us','0',NULL,NULL,NULL,NULL,NULL);
INSERT INTO USS_submission VALUES (2,'Request an Interactive Demonstration CD',1076705448,'Admin',3,'<img src=\"^Extras;styles/webgui6/img_cd.gif\" align=\"right\" style=\"padding-left: 15px;\" />This CD shows all of the excellent features that WebGUI provides and gives you a brief overview of the product. It also provides examples of how the product works and how it can be used in your environment.',NULL,NULL,'Approved',0,1005,1076706084,0,1000,'html','http://www.plainblack.com/presentation_cd','0',NULL,NULL,NULL,NULL,NULL);
INSERT INTO USS_submission VALUES (3,'Get the Manual',1076705448,'Admin',3,'<img src=\"^Extras;styles/webgui6/img_manual.gif\" align=\"right\" style=\"padding-left: 15px;\" />Ruling WebGUI is the definitive guide to everything WebGUI related. It has been compiled by the experts at Plain Black Software and covers almost all aspects of WebGUI. When you purchase Ruling WebGUI, you will receive updates to this great manual for one full year.',NULL,NULL,'Approved',0,1006,1076706084,0,1000,'html','http://www.plainblack.com/ruling_webgui','0',NULL,NULL,NULL,NULL,NULL);
INSERT INTO USS_submission VALUES (4,'Purchase Technical Support',1076705448,'Admin',3,'<img src=\"^Extras;styles/webgui6/img_tech_support.gif\" align=\"right\" style=\"padding-left: 15px;\" />The WebGUI Support Center is there to help you when you get stuck. With a system as large as WebGUI, you\'ll likely have some questions, and our courteous and knowlegable staff is available to answer those questions. And best of all, you get Ruling WebGUI free when you sign up for the Support Center.\r\n\r\n',NULL,NULL,'Approved',0,1007,1076706084,0,1000,'html','http://www.plainblack.com/support_programs','0',NULL,NULL,NULL,NULL,NULL);
INSERT INTO USS_submission VALUES (5,'Sign Up for Hosting',1076705448,'Admin',3,'<img src=\"^Extras;styles/webgui6/img_hosting.gif\" align=\"right\" style=\"padding-left: 15px;\" />We provide professional hosting services for you so you don\'t have to go through the trouble of finding a hoster who likely won\'t know what to do with WebGUI anyway.',NULL,NULL,'Approved',0,1008,1076706084,0,1000,'html','http://www.plainblack.com/hosting','0',NULL,NULL,NULL,NULL,NULL);
INSERT INTO USS_submission VALUES (6,'Look Great',1076705448,'Admin',3,'<img src=\"^Extras;styles/webgui6/img_look_great.gif\" align=\"right\" style=\"padding-left: 15px;\" />Let Plain Black\'s design team build you a professional looking design. Our award-winning designers can get you the look you need on time and on budget, every time.',NULL,NULL,'Approved',0,1009,1076706084,0,1000,'html','http://www.plainblack.com/design','0',NULL,NULL,NULL,NULL,NULL);

--
-- Table structure for table `WSClient`
--

CREATE TABLE WSClient (
  wobjectId int(11) NOT NULL default '0',
  call text NOT NULL,
  uri varchar(255) NOT NULL default '',
  proxy varchar(255) NOT NULL default '',
  preprocessMacros int(11) NOT NULL default '0',
  paginateAfter int(11) NOT NULL default '50',
  paginateVar varchar(35) default NULL,
  debugMode int(11) NOT NULL default '0',
  params text,
  execute_by_default tinyint(4) NOT NULL default '1',
  templateId int(11) NOT NULL default '1',
  decodeUtf8 tinyint(3) unsigned NOT NULL default '0',
  httpHeader varchar(50) default NULL,
  sharedCache tinyint(3) unsigned NOT NULL default '0',
  cacheTTL smallint(5) unsigned NOT NULL default '60',
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table `WSClient`
--



--
-- Table structure for table `WobjectProxy`
--

CREATE TABLE WobjectProxy (
  wobjectId int(11) NOT NULL default '0',
  proxiedWobjectId int(11) NOT NULL default '0',
  overrideTitle int(11) NOT NULL default '0',
  overrideDescription int(11) NOT NULL default '0',
  overrideTemplate int(11) NOT NULL default '0',
  overrideDisplayTitle int(11) NOT NULL default '0',
  proxiedTemplateId int(11) NOT NULL default '1',
  proxiedNamespace varchar(35) default NULL,
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table `WobjectProxy`
--



--
-- Table structure for table `authentication`
--

CREATE TABLE authentication (
  userId int(11) NOT NULL default '0',
  authMethod varchar(30) NOT NULL default '',
  fieldName varchar(128) NOT NULL default '',
  fieldData text,
  PRIMARY KEY  (userId,authMethod,fieldName)
) TYPE=MyISAM;

--
-- Dumping data for table `authentication`
--


INSERT INTO authentication VALUES (1,'LDAP','ldapUrl',NULL);
INSERT INTO authentication VALUES (3,'LDAP','ldapUrl','');
INSERT INTO authentication VALUES (1,'LDAP','connectDN',NULL);
INSERT INTO authentication VALUES (3,'LDAP','connectDN','');
INSERT INTO authentication VALUES (1,'WebGUI','identifier','No Login');
INSERT INTO authentication VALUES (3,'WebGUI','identifier','RvlMjeFPs2aAhQdo/xt/Kg');
INSERT INTO authentication VALUES (1,'WebGUI','passwordLastUpdated','1078704037');
INSERT INTO authentication VALUES (1,'WebGUI','passwordTimeout','3122064000');
INSERT INTO authentication VALUES (1,'WebGUI','changeUsername','1');
INSERT INTO authentication VALUES (1,'WebGUI','changePassword','1');
INSERT INTO authentication VALUES (3,'WebGUI','passwordLastUpdated','1078704037');
INSERT INTO authentication VALUES (3,'WebGUI','passwordTimeout','3122064000');
INSERT INTO authentication VALUES (3,'WebGUI','changeUsername','1');
INSERT INTO authentication VALUES (3,'WebGUI','changePassword','1');

--
-- Table structure for table `collateral`
--

CREATE TABLE collateral (
  collateralId int(11) NOT NULL default '0',
  name varchar(128) NOT NULL default 'untitled',
  filename varchar(255) default NULL,
  parameters text,
  userId int(11) default NULL,
  username varchar(128) default NULL,
  dateUploaded int(11) default NULL,
  collateralFolderId int(11) NOT NULL default '0',
  collateralType varchar(30) NOT NULL default 'image',
  thumbnailSize int(11) NOT NULL default '50',
  PRIMARY KEY  (collateralId)
) TYPE=MyISAM;

--
-- Dumping data for table `collateral`
--



--
-- Table structure for table `collateralFolder`
--

CREATE TABLE collateralFolder (
  collateralFolderId int(11) NOT NULL default '0',
  name varchar(128) NOT NULL default 'untitled',
  parentId int(11) NOT NULL default '0',
  description varchar(255) default NULL
) TYPE=MyISAM;

--
-- Dumping data for table `collateralFolder`
--


INSERT INTO collateralFolder VALUES (0,'Root',0,'Top level');

--
-- Table structure for table `databaseLink`
--

CREATE TABLE databaseLink (
  databaseLinkId int(11) NOT NULL default '0',
  title varchar(255) default NULL,
  DSN varchar(255) default NULL,
  username varchar(255) default NULL,
  identifier varchar(255) default NULL,
  PRIMARY KEY  (databaseLinkId)
) TYPE=MyISAM;

--
-- Dumping data for table `databaseLink`
--



--
-- Table structure for table `forum`
--

CREATE TABLE forum (
  forumId int(11) NOT NULL default '0',
  addEditStampToPosts int(11) NOT NULL default '1',
  filterPosts varchar(30) default 'javascript',
  karmaPerPost int(11) NOT NULL default '0',
  groupToPost int(11) NOT NULL default '2',
  editTimeout int(11) NOT NULL default '3600',
  moderatePosts int(11) NOT NULL default '0',
  groupToModerate int(11) NOT NULL default '4',
  attachmentsPerPost int(11) NOT NULL default '0',
  allowRichEdit int(11) NOT NULL default '1',
  allowReplacements int(11) NOT NULL default '1',
  views int(11) NOT NULL default '0',
  replies int(11) NOT NULL default '0',
  rating int(11) NOT NULL default '0',
  threads int(11) NOT NULL default '0',
  lastPostId int(11) NOT NULL default '0',
  lastPostDate int(11) NOT NULL default '0',
  forumTemplateId int(11) NOT NULL default '1',
  threadTemplateId int(11) NOT NULL default '1',
  postTemplateId int(11) NOT NULL default '1',
  postformTemplateId int(11) NOT NULL default '1',
  postPreviewTemplateId int(11) NOT NULL default '1',
  notificationTemplateId int(11) NOT NULL default '1',
  searchTemplateId int(11) NOT NULL default '1',
  archiveAfter int(11) NOT NULL default '31536000',
  postsPerPage int(11) NOT NULL default '10',
  threadsPerPage int(11) NOT NULL default '30',
  masterForumId int(11) default NULL,
  groupToView int(11) NOT NULL default '7',
  usePreview int(11) NOT NULL default '1',
  PRIMARY KEY  (forumId)
) TYPE=MyISAM;

--
-- Dumping data for table `forum`
--


INSERT INTO forum VALUES (1000,1,'javascript',0,7,3600,0,4,0,1,1,0,0,0,0,0,0,1,1,1,1,1,1,31536000,30,NULL,7);
INSERT INTO forum VALUES (1001,1,'javascript',0,7,3600,0,4,0,1,1,0,0,0,0,0,0,1,1,1,1,1,1,31536000,30,NULL,7);
INSERT INTO forum VALUES (1002,1,'javascript',0,2,3600,0,4,0,1,1,0,0,0,0,0,0,1,1,1,1,1,1,31536000,30,NULL,7);
INSERT INTO forum VALUES (1003,1,'javascript',0,7,3600,0,4,0,1,1,0,0,0,0,0,0,1,1,1,1,1,1,31536000,30,NULL,7);
INSERT INTO forum VALUES (1004,1,'javascript',0,2,3600,0,4,0,1,1,0,0,0,0,0,0,1,1,1,1,1,1,31536000,30,NULL,7);
INSERT INTO forum VALUES (1005,1,'javascript',0,2,3600,0,4,0,1,1,0,0,0,0,0,0,1,1,1,1,1,1,31536000,30,NULL,7);
INSERT INTO forum VALUES (1006,1,'javascript',0,2,3600,0,4,0,1,1,0,0,0,0,0,0,1,1,1,1,1,1,31536000,30,NULL,7);
INSERT INTO forum VALUES (1007,1,'javascript',0,2,3600,0,4,0,1,1,0,0,0,0,0,0,1,1,1,1,1,1,31536000,30,NULL,7);
INSERT INTO forum VALUES (1008,1,'javascript',0,2,3600,0,4,0,1,1,0,0,0,0,0,0,1,1,1,1,1,1,31536000,30,NULL,7);
INSERT INTO forum VALUES (1009,1,'javascript',0,2,3600,0,4,0,1,1,0,0,0,0,0,0,1,1,1,1,1,1,31536000,30,NULL,7);

--
-- Table structure for table `forumPost`
--

CREATE TABLE forumPost (
  forumPostId int(11) NOT NULL default '0',
  parentId int(11) NOT NULL default '0',
  forumThreadId int(11) NOT NULL default '0',
  userId int(11) NOT NULL default '0',
  username varchar(30) default NULL,
  subject varchar(255) default NULL,
  message text,
  dateOfPost int(11) default NULL,
  views int(11) NOT NULL default '0',
  status varchar(30) NOT NULL default 'approved',
  contentType varchar(30) NOT NULL default 'some html',
  rating int(11) NOT NULL default '0',
  PRIMARY KEY  (forumPostId)
) TYPE=MyISAM;

--
-- Dumping data for table `forumPost`
--



--
-- Table structure for table `forumPostAttachment`
--

CREATE TABLE forumPostAttachment (
  forumPostAttachmentId int(11) NOT NULL default '0',
  forumPostId int(11) NOT NULL default '0',
  filename varchar(255) default NULL,
  PRIMARY KEY  (forumPostAttachmentId)
) TYPE=MyISAM;

--
-- Dumping data for table `forumPostAttachment`
--



--
-- Table structure for table `forumPostRating`
--

CREATE TABLE forumPostRating (
  forumPostId int(11) NOT NULL default '0',
  userId int(11) NOT NULL default '0',
  ipAddress varchar(16) default NULL,
  dateOfRating int(11) default NULL,
  rating int(11) NOT NULL default '0'
) TYPE=MyISAM;

--
-- Dumping data for table `forumPostRating`
--



--
-- Table structure for table `forumRead`
--

CREATE TABLE forumRead (
  userId int(11) NOT NULL default '0',
  forumPostId int(11) NOT NULL default '0',
  forumThreadId int(11) NOT NULL default '0',
  lastRead int(11) NOT NULL default '0',
  PRIMARY KEY  (userId,forumPostId)
) TYPE=MyISAM;

--
-- Dumping data for table `forumRead`
--



--
-- Table structure for table `forumSubscription`
--

CREATE TABLE forumSubscription (
  forumId int(11) NOT NULL default '0',
  userId int(11) NOT NULL default '0',
  PRIMARY KEY  (forumId,userId)
) TYPE=MyISAM;

--
-- Dumping data for table `forumSubscription`
--



--
-- Table structure for table `forumThread`
--

CREATE TABLE forumThread (
  forumThreadId int(11) NOT NULL default '0',
  forumId int(11) NOT NULL default '0',
  rootPostId int(11) NOT NULL default '0',
  views int(11) NOT NULL default '0',
  replies int(11) NOT NULL default '0',
  lastPostId int(11) NOT NULL default '0',
  lastPostDate int(11) NOT NULL default '0',
  isLocked int(11) NOT NULL default '0',
  isSticky int(11) NOT NULL default '0',
  status varchar(30) NOT NULL default 'approved',
  rating int(11) NOT NULL default '0',
  PRIMARY KEY  (forumThreadId)
) TYPE=MyISAM;

--
-- Dumping data for table `forumThread`
--



--
-- Table structure for table `forumThreadSubscription`
--

CREATE TABLE forumThreadSubscription (
  forumThreadId int(11) NOT NULL default '0',
  userId int(11) NOT NULL default '0',
  PRIMARY KEY  (forumThreadId,userId)
) TYPE=MyISAM;

--
-- Dumping data for table `forumThreadSubscription`
--



--
-- Table structure for table `groupGroupings`
--

CREATE TABLE groupGroupings (
  groupId int(11) NOT NULL default '0',
  inGroup int(11) NOT NULL default '0'
) TYPE=MyISAM;

--
-- Dumping data for table `groupGroupings`
--


INSERT INTO groupGroupings VALUES (4,12);
INSERT INTO groupGroupings VALUES (6,12);
INSERT INTO groupGroupings VALUES (8,12);
INSERT INTO groupGroupings VALUES (9,12);
INSERT INTO groupGroupings VALUES (10,12);
INSERT INTO groupGroupings VALUES (11,12);
INSERT INTO groupGroupings VALUES (3,2);
INSERT INTO groupGroupings VALUES (3,4);
INSERT INTO groupGroupings VALUES (3,5);
INSERT INTO groupGroupings VALUES (3,6);
INSERT INTO groupGroupings VALUES (3,7);
INSERT INTO groupGroupings VALUES (3,8);
INSERT INTO groupGroupings VALUES (3,9);
INSERT INTO groupGroupings VALUES (3,10);
INSERT INTO groupGroupings VALUES (3,11);
INSERT INTO groupGroupings VALUES (3,12);

--
-- Table structure for table `groupings`
--

CREATE TABLE groupings (
  groupId int(11) NOT NULL default '0',
  userId int(11) NOT NULL default '0',
  expireDate int(11) NOT NULL default '2114402400',
  groupAdmin int(11) NOT NULL default '0',
  PRIMARY KEY  (groupId,userId)
) TYPE=MyISAM;

--
-- Dumping data for table `groupings`
--


INSERT INTO groupings VALUES (1,1,2114402400,0);
INSERT INTO groupings VALUES (3,3,2114402400,0);
INSERT INTO groupings VALUES (7,1,2114402400,0);
INSERT INTO groupings VALUES (7,3,2114402400,0);
INSERT INTO groupings VALUES (2,3,2114402400,0);

--
-- Table structure for table `groups`
--

CREATE TABLE groups (
  groupId int(11) NOT NULL default '0',
  groupName varchar(30) default NULL,
  description varchar(255) default NULL,
  expireOffset int(11) NOT NULL default '314496000',
  karmaThreshold int(11) NOT NULL default '1000000000',
  ipFilter text,
  dateCreated int(11) NOT NULL default '997938000',
  lastUpdated int(11) NOT NULL default '997938000',
  deleteOffset int(11) NOT NULL default '14',
  expireNotifyOffset int(11) NOT NULL default '-14',
  expireNotifyMessage text,
  expireNotify int(11) NOT NULL default '0',
  scratchFilter text,
  autoAdd int(11) NOT NULL default '0',
  autoDelete int(11) NOT NULL default '0',
  databaseLinkId int(11) NOT NULL default '0',
  dbCacheTimeout int(11) NOT NULL default '3600',
  dbQuery text,
  isEditable int(11) NOT NULL default '1',
  showInForms int(11) NOT NULL default '1',
  PRIMARY KEY  (groupId)
) TYPE=MyISAM;

--
-- Dumping data for table `groups`
--


INSERT INTO groups VALUES (1,'Visitors','This is the public group that has no privileges.',314496000,1000000000,NULL,997938000,997938000,14,-14,NULL,0,NULL,0,0,0,3600,NULL,0,1);
INSERT INTO groups VALUES (2,'Registered Users','All registered users belong to this group automatically. There are no associated privileges other than that the user has an account and is logged in.',314496000,1000000000,NULL,997938000,997938000,14,-14,NULL,0,NULL,0,0,0,3600,NULL,0,1);
INSERT INTO groups VALUES (3,'Admins','Anyone who belongs to this group has privileges to do anything and everything.',314496000,1000000000,NULL,997938000,997938000,14,-14,NULL,0,NULL,0,0,0,3600,NULL,1,1);
INSERT INTO groups VALUES (4,'Content Managers','Users that have privileges to edit content on this site. The user still needs to be added to a group that has editing privileges on specific pages.',314496000,1000000000,NULL,997938000,997938000,14,-14,NULL,0,NULL,0,0,0,3600,NULL,1,1);
INSERT INTO groups VALUES (6,'Package Managers','Users that have privileges to add, edit, and delete packages of wobjects and pages to deploy.',314496000,1000000000,NULL,997938000,997938000,14,-14,NULL,0,NULL,0,0,0,3600,NULL,1,1);
INSERT INTO groups VALUES (7,'Everyone','A group that automatically includes all users including Visitors.',314496000,1000000000,NULL,997938000,997938000,14,-14,NULL,0,NULL,0,0,0,3600,NULL,0,1);
INSERT INTO groups VALUES (8,'Template Managers','Users that have privileges to edit templates for this site.',314496000,1000000000,NULL,997938000,997938000,14,-14,NULL,0,NULL,0,0,0,3600,NULL,1,1);
INSERT INTO groups VALUES (9,'Theme Managers','Users in this group can use the theme manager to create new themes and install themes from other systems.',314496000,1000000000,NULL,997938000,997938000,14,-14,NULL,0,NULL,0,0,0,3600,NULL,1,1);
INSERT INTO groups VALUES (10,'Translation Managers','Users that can edit language translations for WebGUI.',314496000,1000000000,NULL,997938000,997938000,14,-14,NULL,0,NULL,0,0,0,3600,NULL,1,1);
INSERT INTO groups VALUES (11,'Secondary Admins','Users that have limited administrative privileges.',314496000,1000000000,NULL,997938000,997938000,14,-14,NULL,0,NULL,0,0,0,3600,NULL,1,1);
INSERT INTO groups VALUES (12,'Turn Admin On','These users can enable admin mode.',314496000,1000000000,NULL,997938000,997938000,14,-14,NULL,0,NULL,0,0,0,3600,NULL,1,0);

--
-- Table structure for table `incrementer`
--

CREATE TABLE incrementer (
  incrementerId varchar(50) NOT NULL default '',
  nextValue int(11) NOT NULL default '1',
  PRIMARY KEY  (incrementerId)
) TYPE=MyISAM;

--
-- Dumping data for table `incrementer`
--


INSERT INTO incrementer VALUES ('groupId',26);
INSERT INTO incrementer VALUES ('pageId',1005);
INSERT INTO incrementer VALUES ('USS_id',1001);
INSERT INTO incrementer VALUES ('userId',26);
INSERT INTO incrementer VALUES ('wobjectId',9);
INSERT INTO incrementer VALUES ('EventsCalendar_eventId',1000);
INSERT INTO incrementer VALUES ('USS_submissionId',7);
INSERT INTO incrementer VALUES ('EventsCalendar_recurringId',1000);
INSERT INTO incrementer VALUES ('messageLogId',1000);
INSERT INTO incrementer VALUES ('FileManager_fileId',1);
INSERT INTO incrementer VALUES ('collateralId',1);
INSERT INTO incrementer VALUES ('profileCategoryId',1000);
INSERT INTO incrementer VALUES ('templateId',1000);
INSERT INTO incrementer VALUES ('collateralFolderId',1000);
INSERT INTO incrementer VALUES ('Product_featureId',1000);
INSERT INTO incrementer VALUES ('Product_specificationId',1000);
INSERT INTO incrementer VALUES ('languageId',1000);
INSERT INTO incrementer VALUES ('DataForm_fieldId',1007);
INSERT INTO incrementer VALUES ('DataForm_entryId',1000);
INSERT INTO incrementer VALUES ('Product_benefitId',1000);
INSERT INTO incrementer VALUES ('Survey_answerId',1000);
INSERT INTO incrementer VALUES ('Survey_questionId',1000);
INSERT INTO incrementer VALUES ('Survey_responseId',1000);
INSERT INTO incrementer VALUES ('Survey_id',1000);
INSERT INTO incrementer VALUES ('themeId',1000);
INSERT INTO incrementer VALUES ('themeComponentId',1000);
INSERT INTO incrementer VALUES ('databaseLinkId',1000);
INSERT INTO incrementer VALUES ('forumId',1010);
INSERT INTO incrementer VALUES ('forumThreadId',1);
INSERT INTO incrementer VALUES ('forumPostId',1);
INSERT INTO incrementer VALUES ('replacementId',1000);
INSERT INTO incrementer VALUES ('DataForm_tabId',1000);
INSERT INTO incrementer VALUES ('navigationId',1003);

--
-- Table structure for table `karmaLog`
--

CREATE TABLE karmaLog (
  userId int(11) NOT NULL default '0',
  amount int(11) NOT NULL default '1',
  source varchar(255) default NULL,
  description text,
  dateModified int(11) NOT NULL default '1026097656'
) TYPE=MyISAM;

--
-- Dumping data for table `karmaLog`
--



--
-- Table structure for table `messageLog`
--

CREATE TABLE messageLog (
  messageLogId int(11) NOT NULL default '0',
  userId int(11) NOT NULL default '0',
  message text,
  url text,
  dateOfEntry int(11) default NULL,
  subject varchar(255) default NULL,
  status varchar(30) default 'notice',
  PRIMARY KEY  (messageLogId,userId)
) TYPE=MyISAM;

--
-- Dumping data for table `messageLog`
--



--
-- Table structure for table `page`
--

CREATE TABLE page (
  pageId int(11) NOT NULL default '0',
  parentId int(11) NOT NULL default '0',
  title varchar(255) default NULL,
  styleId int(11) NOT NULL default '0',
  ownerId int(11) NOT NULL default '0',
  sequenceNumber int(11) NOT NULL default '1',
  metaTags text,
  urlizedTitle varchar(255) default NULL,
  defaultMetaTags int(11) NOT NULL default '0',
  menuTitle varchar(128) default NULL,
  synopsis text,
  templateId int(11) NOT NULL default '1',
  startDate int(11) NOT NULL default '946710000',
  endDate int(11) NOT NULL default '2082783600',
  redirectURL text,
  userDefined1 varchar(255) default NULL,
  userDefined2 varchar(255) default NULL,
  userDefined3 varchar(255) default NULL,
  userDefined4 varchar(255) default NULL,
  userDefined5 varchar(255) default NULL,
  languageId varchar(50) NOT NULL default 'English',
  groupIdView int(11) NOT NULL default '3',
  groupIdEdit int(11) NOT NULL default '3',
  hideFromNavigation int(11) NOT NULL default '0',
  newWindow int(11) NOT NULL default '0',
  bufferUserId int(11) default NULL,
  bufferDate int(11) default NULL,
  bufferPrevId int(11) default NULL,
  cacheTimeout int(11) NOT NULL default '60',
  cacheTimeoutVisitor int(11) NOT NULL default '600',
  printableStyleId int(11) NOT NULL default '3',
  wobjectPrivileges int(11) NOT NULL default '0',
  lft int(11) default NULL,
  rgt int(11) default NULL,
  id int(11) default NULL,
  depth int(3) default NULL,
  PRIMARY KEY  (pageId)
) TYPE=MyISAM;

--
-- Dumping data for table `page`
--


INSERT INTO page VALUES (1,0,'Home',1001,3,0,'','home',1,'Home',NULL,1,946710000,2082783600,NULL,NULL,NULL,NULL,NULL,NULL,'English',7,3,0,0,NULL,NULL,NULL,60,600,3,0,1,12,1,0);
INSERT INTO page VALUES (4,0,'Page Not Found',-6,3,21,'','page_not_found',0,'Page Not Found',NULL,1,946710000,2082783600,NULL,NULL,NULL,NULL,NULL,NULL,'English',7,3,1,0,NULL,NULL,NULL,60,600,3,0,13,14,4,0);
INSERT INTO page VALUES (3,0,'Trash',5,3,22,'','trash',0,'Trash',NULL,1,946710000,2082783600,NULL,NULL,NULL,NULL,NULL,NULL,'English',3,3,1,0,NULL,NULL,NULL,60,600,3,0,15,16,3,0);
INSERT INTO page VALUES (2,0,'Clipboard',4,3,23,'','clipboard',0,'Clipboard',NULL,1,946710000,2082783600,NULL,NULL,NULL,NULL,NULL,NULL,'English',4,4,1,0,NULL,NULL,NULL,60,600,3,0,17,18,2,0);
INSERT INTO page VALUES (5,0,'Packages',1,3,24,'','packages',0,'Packages',NULL,1,946710000,2082783600,NULL,NULL,NULL,NULL,NULL,NULL,'English',6,6,1,0,NULL,NULL,NULL,60,600,3,0,19,20,5,0);
INSERT INTO page VALUES (1000,1,'Getting Started',1001,3,1,'','getting_started',1,'Getting Started','',1,946710000,2082783600,'',NULL,NULL,NULL,NULL,NULL,'English',7,3,0,0,NULL,NULL,NULL,60,600,3,0,2,3,1000,1);
INSERT INTO page VALUES (1001,1,'What should you do next?',1001,3,2,'','your_next_step',1,'Your Next Step','',1,946710000,2082783600,'',NULL,NULL,NULL,NULL,NULL,'English',7,3,0,0,NULL,NULL,NULL,60,600,3,0,4,5,1001,1);
INSERT INTO page VALUES (1002,1,'The Latest News',1001,3,3,'','the_latest_news',1,'The Latest News','',1,946710000,2082783600,'',NULL,NULL,NULL,NULL,NULL,'English',7,3,0,0,NULL,NULL,NULL,60,600,3,0,6,7,1002,1);
INSERT INTO page VALUES (1003,1,'Tell A Friend',1001,3,4,'','tell_a_friend',1,'Tell A Friend','',1,946710000,2082783600,'',NULL,NULL,NULL,NULL,NULL,'English',7,3,0,0,NULL,NULL,NULL,60,600,3,0,8,9,1003,1);
INSERT INTO page VALUES (1004,1,'Site Map',1001,3,4,'','site_map',1,'Site Map','',1,946710000,2082783600,'',NULL,NULL,NULL,NULL,NULL,'English',7,3,0,0,NULL,NULL,NULL,60,600,3,0,10,11,1004,1);
INSERT INTO page VALUES (0,-1,NULL,0,0,1,NULL,NULL,0,NULL,NULL,1,946710000,2082783600,NULL,NULL,NULL,NULL,NULL,NULL,'English',3,3,0,0,NULL,NULL,NULL,60,600,3,0,0,21,0,-1);

--
-- Table structure for table `pageStatistics`
--

CREATE TABLE pageStatistics (
  dateStamp int(11) default NULL,
  userId int(11) default NULL,
  username varchar(35) default NULL,
  ipAddress varchar(15) default NULL,
  userAgent varchar(255) default NULL,
  referer text,
  pageId int(11) default NULL,
  pageTitle varchar(255) default NULL,
  wobjectId int(11) default NULL,
  wobjectFunction varchar(60) default NULL
) TYPE=MyISAM;

--
-- Dumping data for table `pageStatistics`
--



--
-- Table structure for table `replacements`
--

CREATE TABLE replacements (
  replacementId int(11) NOT NULL default '0',
  searchFor varchar(255) default NULL,
  replaceWith text,
  PRIMARY KEY  (replacementId)
) TYPE=MyISAM;

--
-- Dumping data for table `replacements`
--


INSERT INTO replacements VALUES (1,'[quote]','<blockquote><i>');
INSERT INTO replacements VALUES (2,'[/quote]','</i></blockquote>');
INSERT INTO replacements VALUES (3,'[image]','<img src=\"');
INSERT INTO replacements VALUES (4,'[/image]','\" border=\"0\" / >');
INSERT INTO replacements VALUES (5,'shit','crap');
INSERT INTO replacements VALUES (6,'fuck','farg');
INSERT INTO replacements VALUES (7,'asshole','icehole');
INSERT INTO replacements VALUES (8,'nigger','guy');
INSERT INTO replacements VALUES (9,'[b]','<b>');
INSERT INTO replacements VALUES (10,'[/b]','</b>');
INSERT INTO replacements VALUES (11,'[i]','<i>');
INSERT INTO replacements VALUES (12,'[/i]','</i>');

--
-- Table structure for table `settings`
--

CREATE TABLE settings (
  name varchar(255) NOT NULL default '',
  value text,
  PRIMARY KEY  (name)
) TYPE=MyISAM;

--
-- Dumping data for table `settings`
--


INSERT INTO settings VALUES ('maxAttachmentSize','10000');
INSERT INTO settings VALUES ('sessionTimeout','3600');
INSERT INTO settings VALUES ('smtpServer','localhost');
INSERT INTO settings VALUES ('companyEmail','info@mycompany.com');
INSERT INTO settings VALUES ('ldapURL','ldap://ldap.mycompany.com:389/o=MyCompany');
INSERT INTO settings VALUES ('companyName','My Company');
INSERT INTO settings VALUES ('companyURL','http://www.mycompany.com');
INSERT INTO settings VALUES ('ldapId','shortname');
INSERT INTO settings VALUES ('ldapIdName','LDAP Shortname');
INSERT INTO settings VALUES ('ldapPasswordName','LDAP Password');
INSERT INTO settings VALUES ('authMethod','WebGUI');
INSERT INTO settings VALUES ('anonymousRegistration','0');
INSERT INTO settings VALUES ('notFoundPage','1');
INSERT INTO settings VALUES ('webguiRecoverPasswordEmail','Someone (probably you) requested your account information be sent. Your password has been reset. The following represents your new account information:');
INSERT INTO settings VALUES ('profileName','1');
INSERT INTO settings VALUES ('profileExtraContact','1');
INSERT INTO settings VALUES ('profileMisc','1');
INSERT INTO settings VALUES ('profileHome','0');
INSERT INTO settings VALUES ('profileWork','0');
INSERT INTO settings VALUES ('preventProxyCache','0');
INSERT INTO settings VALUES ('thumbnailSize','50');
INSERT INTO settings VALUES ('textAreaRows','5');
INSERT INTO settings VALUES ('textAreaCols','50');
INSERT INTO settings VALUES ('textBoxSize','30');
INSERT INTO settings VALUES ('defaultPage','1');
INSERT INTO settings VALUES ('onNewUserAlertGroup','3');
INSERT INTO settings VALUES ('alertOnNewUser','0');
INSERT INTO settings VALUES ('useKarma','0');
INSERT INTO settings VALUES ('karmaPerLogin','1');
INSERT INTO settings VALUES ('runOnRegistration','');
INSERT INTO settings VALUES ('maxImageSize','100000');
INSERT INTO settings VALUES ('showDebug','0');
INSERT INTO settings VALUES ('trackPageStatistics','0');
INSERT INTO settings VALUES ('smbPDC','your PDC');
INSERT INTO settings VALUES ('smbBDC','your BDC');
INSERT INTO settings VALUES ('smbDomain','your NT Domain');
INSERT INTO settings VALUES ('selfDeactivation','1');
INSERT INTO settings VALUES ('snippetsPreviewLength','30');
INSERT INTO settings VALUES ('mailFooter','^c;\n^e;\n^u;\n');
INSERT INTO settings VALUES ('webguiSendWelcomeMessage','0');
INSERT INTO settings VALUES ('webguiWelcomeMessage','Welcome to our site.');
INSERT INTO settings VALUES ('siteicon','^Extras;favicon.png');
INSERT INTO settings VALUES ('favicon','^Extras;favicon.ico');
INSERT INTO settings VALUES ('sharedClipboard','0');
INSERT INTO settings VALUES ('sharedTrash','0');
INSERT INTO settings VALUES ('proxiedClientAddress','0');
INSERT INTO settings VALUES ('ldapUserRDN','cn');
INSERT INTO settings VALUES ('encryptLogin','0');
INSERT INTO settings VALUES ('hostToUse','HTTP_HOST');
INSERT INTO settings VALUES ('webguiExpirePasswordOnCreation','0');
INSERT INTO settings VALUES ('webguiPasswordLength','0');
INSERT INTO settings VALUES ('webguiPasswordRecovery','1');
INSERT INTO settings VALUES ('webguiPasswordTimeout','3122064000');
INSERT INTO settings VALUES ('ldapWelcomeMessage','Welcome to our site.');
INSERT INTO settings VALUES ('ldapSendWelcomeMessage','0');
INSERT INTO settings VALUES ('smbWelcomeMessage','Welcome to our site.');
INSERT INTO settings VALUES ('smbSendWelcomeMessage','0');
INSERT INTO settings VALUES ('useAdminStyle','1');
INSERT INTO settings VALUES ('adminStyleId','1000');
INSERT INTO settings VALUES ('webguiChangePassword','1');
INSERT INTO settings VALUES ('webguiChangeUsername','1');

--
-- Table structure for table `template`
--

CREATE TABLE template (
  templateId int(11) NOT NULL default '0',
  name varchar(255) default NULL,
  template mediumtext,
  namespace varchar(35) NOT NULL default 'Page',
  isEditable int(11) NOT NULL default '1',
  showInForms int(11) NOT NULL default '1',
  PRIMARY KEY  (templateId,namespace)
) TYPE=MyISAM;

--
-- Dumping data for table `template`
--


INSERT INTO template VALUES (1,'Default Site Map','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_loop page_loop>\r\n  <tmpl_if page.isRoot><p /></tmpl_if>\r\n  <tmpl_var page.indent>&middot;<a href=\"<tmpl_var page.url>\"><tmpl_var page.title></a><br />\r\n</tmpl_loop>','SiteMap',1,1);
INSERT INTO template VALUES (3,'Left Align Image','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.isFirstPage>\r\n<tmpl_if image.url>\r\n  <table width=\"100%\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\"><tr><td class=\"content\">\r\n  <img src=\"<tmpl_var image.url>\" align=\"left\" border=\"0\">\r\n</tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n  <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n\r\n<tmpl_if pagination.isLastPage>\r\n<tmpl_if linkurl>\r\n  <tmpl_if linktitle>\r\n    <p /><a href=\"<tmpl_var linkUrl>\"><tmpl_var linkTitle></a>\r\n  </tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_var attachment.box> <p />\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.isFirstPage>\r\n<tmpl_if image.url>\r\n  </td></tr></table>\r\n</tmpl_if>\r\n</tmpl_if>\r\n\r\n\r\n<tmpl_if pagination.pageCount.isMultiple>\r\n<tmpl_var pagination.previousPage> \r\n&middot;\r\n<tmpl_var pagination.pageList.upTo20>\r\n&middot;\r\n<tmpl_var pagination.nextPage>\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.isLastPage>\r\n\r\n<tmpl_if allowDiscussion>\r\n  <p><table width=\"100%\" cellspacing=\"2\" cellpadding=\"1\" border=\"0\">\r\n  <tr><td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var replies.URL>\"><tmpl_var replies.label> (<tmpl_var replies.count>)</a></td>\r\n  <td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var post.url>\"><tmpl_var post.label></a></td></tr>\r\n  </table>\r\n</tmpl_if>\r\n\r\n</tmpl_if>','Article',1,1);
INSERT INTO template VALUES (2,'List with Thumbnails','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_if session.scratch.search>\r\n <tmpl_var search.form>\r\n</tmpl_if>\r\n<table cellpadding=\"3\" cellspacing=\"1\" border=\"0\" width=\"100%\">\r\n\r\n<tr>\r\n  <td colspan=\"3\" align=\"right\" class=\"tableMenu\">\r\n                <a href=\"<tmpl_var search.url>\"><tmpl_var search.label></a>\r\n                <tmpl_if session.var.adminOn>\r\n                      &middot; <a href=\"<tmpl_var addfile.url>\"><tmpl_var addfile.label></a>\r\n                 </tmpl_if>\r\n   </td>\r\n</tr>\r\n\r\n<tr>\r\n  <td class=\"tableHeader\"><a href=\"<tmpl_var titleColumn.url>\"><tmpl_var titleColumn.label></a></td>\r\n  <td class=\"tableHeader\"><a href=\"<tmpl_var descriptionColumn.url>\"><tmpl_var descriptionColumn.label></a></td>\r\n  <td class=\"tableHeader\"><a href=\"<tmpl_var dateColumn.url>\"><tmpl_var dateColumn.label></a></td>\r\n</tr>\r\n\r\n<tmpl_loop file_loop>\r\n   <tmpl_if file.canView>\r\n        <tr>\r\n           <td class=\"tableData\" valign=\"top\">\r\n             <tmpl_if session.var.adminOn>\r\n                   <tmpl_var file.controls>\r\n              </tmpl_if>\r\n              <a href=\"<tmpl_var file.version1.url>\"><tmpl_var file.title></a>\r\n               &nbsp;&middot;&nbsp;\r\n              <a href=\"<tmpl_var file.version1.url>\"><img src=\"<tmpl_var file.version1.icon>\" border=\"0\" width=\"16\" height=\"16\" align=\"middle\" /><tmpl_var file.version1.type>/<tmpl_var file.version1.size></a>\r\n              <tmpl_if file.version2.name>\r\n                   &nbsp;&middot;&nbsp;\r\n                   <a href=\"<tmpl_var file.version2.url>\"><img src=\"<tmpl_var file.version2.icon>\" border=0 width=\"16\" height=\"16\" align=\"middle\" /><tmpl_var file.version2.type>/<tmpl_var file.version2.size></a>\r\n              </tmpl_if>\r\n              <tmpl_if file.version3.name>\r\n                   &nbsp;&middot;&nbsp;\r\n                   <a href=\"<tmpl_var file.version3.url>\"><img src=\"<tmpl_var file.version3.icon>\" border=\"0\" width=\"16\" height=\"16\" align=\"middle\" /><tmpl_var file.version3.type>/<tmpl_var file.version3.size></a>\r\n              </tmpl_if>\r\n           </td>\r\n           <td class=\"tableData\" valign=\"top\">\r\n                    <tmpl_if file.version1.isImage>\r\n                           <img src=\"<tmpl_var file.version1.thumbnail>\" border=0 align=\"middle\" hspace=\"3\">\r\n                    </tmpl_if>\r\n                <tmpl_var file.description>\r\n           </td>\r\n           <td class=\"tableData\" valign=\"top\">\r\n                 <tmpl_var file.date>\r\n           </td>\r\n        </tr>\r\n      </tmpl_if>\r\n</tmpl_loop>\r\n\r\n<tmpl_if noresults>\r\n    <tr><td class=\"tableData\" colspan=\"3\"><tmpl_var noresults.message></td></tr>\r\n</tmpl_if>\r\n\r\n</table>\r\n\r\n<tmpl_if pagination.pageCount.isMultiple>\r\n  <div class=\"pagination\">\r\n    <tmpl_var pagination.previousPage> &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>\r\n  </div>\r\n</tmpl_if>','FileManager',1,1);
INSERT INTO template VALUES (3,'Calendar Month (Small)','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_if session.var.adminOn>\r\n    <a href=\"<tmpl_var addevent.url>\"><tmpl_var addevent.label></a>\r\n    <p />\r\n</tmpl_if>\r\n\r\n\n\n\n<tmpl_loop month_loop>\n	<table border=\"1\" width=\"100%\">\n	<tr><td colspan=7 class=\"tableHeader\"><h2 align=\"center\"><tmpl_var month> <tmpl_var year></h2></td></tr>\n	<tr>\n	<tmpl_if session.user.firstDayOfWeek>\n		<th class=\"tableData\"><tmpl_var monday.label.short></th>\n		<th class=\"tableData\"><tmpl_var tuesday.label.short></th>\n		<th class=\"tableData\"><tmpl_var wednesday.label.short></th>\n		<th class=\"tableData\"><tmpl_var thursday.label.short></th>\n		<th class=\"tableData\"><tmpl_var friday.label.short></th>\n		<th class=\"tableData\"><tmpl_var saturday.label.short></th>\n		<th class=\"tableData\"><tmpl_var sunday.label.short></th>\n	<tmpl_else>\n		<th class=\"tableData\"><tmpl_var sunday.label.short></th>\n		<th class=\"tableData\"><tmpl_var monday.label.short></th>\n		<th class=\"tableData\"><tmpl_var tuesday.label.short></th>\n		<th class=\"tableData\"><tmpl_var wednesday.label.short></th>\n		<th class=\"tableData\"><tmpl_var thursday.label.short></th>\n		<th class=\"tableData\"><tmpl_var friday.label.short></th>\n		<th class=\"tableData\"><tmpl_var saturday.label.short></th>\n	</tmpl_if>\n	</tr><tr>\n	<tmpl_loop prepad_loop>\n		<td>&nbsp;</td>\n	</tmpl_loop>\n 	<tmpl_loop day_loop>\n		<tmpl_if isStartOfWeek>\n			<tr>\n		</tmpl_if>\n		<td class=\"table<tmpl_if isToday>Header<tmpl_else>Data</tmpl_if>\" width=\"28\" valign=\"top\" align=\"left\"><p><b>\n				<tmpl_if url>\n					<a href=\"<tmpl_var url>\"><tmpl_var day></a>\n				<tmpl_else>\n					<tmpl_var day>\n				</tmpl_if>\n		</b></p></td>		\n		<tmpl_if isEndOfWeek>\n			</tr>\n		</tmpl_if>\n	</tmpl_loop>\n	<tmpl_loop postpad_loop>\n		<td>&nbsp;</td>\n	</tmpl_loop>\n	</tr>\n	</table>\n</tmpl_loop>\n\n\n<tmpl_if pagination.pageCount.isMultiple>\n  <div class=\"pagination\">\n    <tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>\n  </div>\n</tmpl_if>\n','EventsCalendar',1,1);
INSERT INTO template VALUES (1,'Default Event','<h1><tmpl_var title></h1>\r\n\r\n<table width=\"100%\" cellspacing=\"0\" cellpadding=\"5\" border=\"0\">\r\n<tr>\r\n<td valign=\"top\" class=\"tableHeader\" width=\"100%\">\r\n<b><tmpl_var start.label>:</b> <tmpl_var start.date><br />\r\n<b><tmpl_var end.label>:</b> <tmpl_var end.date><br />\r\n</td><td valign=\"top\" class=\"tableMenu\" nowrap=\"1\">\r\n\r\n<tmpl_if canEdit>\r\n     <a href=\"<tmpl_var edit.url>\"><tmpl_var edit.label></a><br />\r\n     <a href=\"<tmpl_var delete.url>\"><tmpl_var delete.label></a><br />\r\n</tmpl_if>\r\n\r\n<tmpl_if previous.url>\r\n     <a href=\"<tmpl_var previous.url>\"><tmpl_var previous.label></a><br />\r\n</tmpl_if>\r\n\r\n<tmpl_if next.url>\r\n     <a href=\"<tmpl_var next.url>\"><tmpl_var next.label></a><br />\r\n</tmpl_if>\r\n\r\n</td></tr>\r\n</table>\r\n<tmpl_var description>','EventsCalendar/Event',1,1);
INSERT INTO template VALUES (1,'Default File Manager','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_if session.scratch.search>\r\n <tmpl_var search.form>\r\n</tmpl_if>\r\n<table cellpadding=\"3\" cellspacing=\"1\" border=\"0\" width=\"100%\">\r\n\r\n<tr>\r\n  <td colspan=\"3\" align=\"right\" class=\"tableMenu\">\r\n                <a href=\"<tmpl_var search.url>\"><tmpl_var search.label></a>\r\n                <tmpl_if session.var.adminOn>\r\n                      &middot; <a href=\"<tmpl_var addfile.url>\"><tmpl_var addfile.label></a>\r\n                 </tmpl_if>\r\n   </td>\r\n</tr>\r\n\r\n<tr>\r\n  <td class=\"tableHeader\"><a href=\"<tmpl_var titleColumn.url>\"><tmpl_var titleColumn.label></a></td>\r\n  <td class=\"tableHeader\"><a href=\"<tmpl_var descriptionColumn.url>\"><tmpl_var descriptionColumn.label></a></td>\r\n  <td class=\"tableHeader\"><a href=\"<tmpl_var dateColumn.url>\"><tmpl_var dateColumn.label></a></td>\r\n</tr>\r\n\r\n<tmpl_loop file_loop>\r\n   <tmpl_if file.canView>\r\n        <tr>\r\n           <td class=\"tableData\" valign=\"top\">\r\n             <tmpl_if session.var.adminOn>\r\n                   <tmpl_var file.controls>\r\n              </tmpl_if>\r\n              <a href=\"<tmpl_var file.version1.url>\"><tmpl_var file.title></a>\r\n               &nbsp;&middot;&nbsp;\r\n              <a href=\"<tmpl_var file.version1.url>\"><img src=\"<tmpl_var file.version1.icon>\" border=\"0\" width=\"16\" height=\"16\" align=\"middle\" /><tmpl_var file.version1.type>/<tmpl_var file.version1.size></a>\r\n              <tmpl_if file.version2.name>\r\n                   &nbsp;&middot;&nbsp;\r\n                   <a href=\"<tmpl_var file.version2.url>\"><img src=\"<tmpl_var file.version2.icon>\" border=0 width=\"16\" height=\"16\" align=\"middle\" /><tmpl_var file.version2.type>/<tmpl_var file.version2.size></a>\r\n              </tmpl_if>\r\n              <tmpl_if file.version3.name>\r\n                   &nbsp;&middot;&nbsp;\r\n                   <a href=\"<tmpl_var file.version3.url>\"><img src=\"<tmpl_var file.version3.icon>\" border=\"0\" width=\"16\" height=\"16\" align=\"middle\" /><tmpl_var file.version3.type>/<tmpl_var file.version3.size></a>\r\n              </tmpl_if>\r\n           </td>\r\n           <td class=\"tableData\" valign=\"top\">\r\n                <tmpl_var file.description>\r\n           </td>\r\n           <td class=\"tableData\" valign=\"top\">\r\n                 <tmpl_var file.date>\r\n           </td>\r\n        </tr>\r\n      </tmpl_if>\r\n</tmpl_loop>\r\n\r\n<tmpl_if noresults>\r\n    <tr><td class=\"tableData\" colspan=\"3\"><tmpl_var noresults.message></td></tr>\r\n</tmpl_if>\r\n\r\n</table>\r\n\r\n<tmpl_if pagination.pageCount.isMultiple>\r\n  <div class=\"pagination\">\r\n    <tmpl_var pagination.previousPage> &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>\r\n  </div>\r\n</tmpl_if>','FileManager',1,1);
INSERT INTO template VALUES (2,'Events List','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_if session.var.adminOn>\r\n    <a href=\"<tmpl_var addevent.url>\"><tmpl_var addevent.label></a>\r\n    <p />\r\n</tmpl_if>\r\n\r\n\n<tmpl_loop month_loop>\n	<tmpl_loop day_loop>\n		<tmpl_loop event_loop>\n			<tmpl_if isFirstDayOfEvent>\n				<tmpl_unless dateIsSameAsPrevious>\n					<b>\n						<tmpl_var start.month> <tmpl_var start.day><tmpl_unless startEndYearMatch>,\n						          <tmpl_ start.year> - \n							<tmpl_var end.month> <tmpl_var end.day></tmpl_unless><tmpl_unless startEndMonthMatch> - <tmpl_var end.month> <tmpl_var end.day><tmpl_else><tmpl_unless startEndDayMatch> - <tmpl_var end.day></tmpl_unless></tmpl_unless>, <tmpl_var end.year>\n					</b>\n				</tmpl_unless>\n				<blockquote>\n					<tmpl_if session.var.adminOn>\n						<a href=\"<tmpl_var url>\">\n					</tmpl_if>\n					<i><tmpl_var name></i>\n					<tmpl_if session.var.adminOn>\n						</a>\n					</tmpl_if>\n					<tmpl_if description>\n						- <tmpl_var description>\n					</tmpl_if description>\n				</blockquote>\n			</tmpl_if>\n		</tmpl_loop>\n	</tmpl_loop>\n</tmpl_loop>\n\n\n\n<tmpl_if pagination.pageCount.isMultiple>\n  <div class=\"pagination\">\n    <tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>\n  </div>\n</tmpl_if>\n','EventsCalendar',1,1);
INSERT INTO template VALUES (2,'Center Image','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.isFirstPage>\r\n<tmpl_if image.url>\r\n  <div align=\"center\"><img src=\"<tmpl_var image.url>\" border=\"0\"></div>\r\n</tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n  <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.isLastPage>\r\n<tmpl_if linkurl>\r\n  <tmpl_if linktitle>\r\n    <p /><a href=\"<tmpl_var linkUrl>\"><tmpl_var linkTitle></a>\r\n  </tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_var attachment.box> <p />\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.pageCount.isMultiple>\r\n<tmpl_var pagination.previousPage> \r\n&middot;\r\n<tmpl_var pagination.pageList.upTo20>\r\n&middot;\r\n<tmpl_var pagination.nextPage>\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.isLastPage>\r\n<tmpl_if allowDiscussion>\r\n  <p><table width=\"100%\" cellspacing=\"2\" cellpadding=\"1\" border=\"0\">\r\n  <tr><td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var replies.URL>\"><tmpl_var replies.label> (<tmpl_var replies.count>)</a></td>\r\n  <td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var post.url>\"><tmpl_var post.label></a></td></tr>\r\n  </table>\r\n</tmpl_if>\r\n</tmpl_if>','Article',1,1);
INSERT INTO template VALUES (1,'Default Article','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.isFirstPage>\r\n<tmpl_if image.url>\r\n  <table width=\"100%\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\"><tr><td class=\"content\">\r\n  <img src=\"<tmpl_var image.url>\" align=\"right\" border=\"0\">\r\n</tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n  <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n\r\n<tmpl_if pagination.isLastPage>\r\n<tmpl_if linkUrl>\r\n  <tmpl_if linkTitle>\r\n    <p /><a href=\"<tmpl_var linkUrl>\"><tmpl_var linkTitle></a>\r\n  </tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_var attachment.box> <p />\r\n</tmpl_if>\r\n\r\n\r\n<tmpl_if pagination.pageCount.isMultiple>\r\n<tmpl_var pagination.previousPage> \r\n&middot;\r\n<tmpl_var pagination.pageList.upTo20>\r\n&middot;\r\n<tmpl_var pagination.nextPage>\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.isFirstPage>\r\n<tmpl_if image.url>\r\n  </td></tr></table>\r\n</tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.isLastPage>\r\n<tmpl_if allowDiscussion>\r\n  <p><table width=\"100%\" cellspacing=\"2\" cellpadding=\"1\" border=\"0\">\r\n  <tr><td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var replies.URL>\"><tmpl_var replies.label> (<tmpl_var replies.count>)</a></td>\r\n  <td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var post.url>\"><tmpl_var post.label></a></td></tr>\r\n  </table>\r\n</tmpl_if>\r\n\r\n</tmpl_if>','Article',1,1);
INSERT INTO template VALUES (4,'Linked Image with Caption','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.isFirstPage>\r\n<tmpl_if image.url>\r\n  <table width=\"100%\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\"><tr><td class=\"content\">\r\n   <table align=\"right\"><tr><td align=\"center\">\r\n   <tmpl_if linkUrl>\r\n        <a href=\"<tmpl_var linkUrl>\">\r\n      <img src=\"<tmpl_var image.url>\" border=\"0\">\r\n       <br /><tmpl_var linkTitle></a>\r\n    <tmpl_else>\r\n           <img src=\"<tmpl_var image.url>\" border=\"0\">\r\n           <br /> <tmpl_var linkTitle>\r\n   </tmpl_if>\r\n  </td></tr></table>\r\n</tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n  <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.isLastPage>\r\n<tmpl_var attachment.box> <p />\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.isFirstPage>\r\n<tmpl_if image.url>\r\n  </td></tr></table>\r\n</tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.pageCount.isMultiple>\r\n<tmpl_var pagination.previousPage> \r\n&middot;\r\n<tmpl_var pagination.pageList.upTo20>\r\n&middot;\r\n<tmpl_var pagination.nextPage>\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.isLastPage>\r\n\r\n<tmpl_if allowDiscussion>\r\n  <p><table width=\"100%\" cellspacing=\"2\" cellpadding=\"1\" border=\"0\">\r\n  <tr><td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var replies.URL>\"><tmpl_var replies.label> (<tmpl_var replies.count>)</a></td>\r\n  <td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var post.url>\"><tmpl_var post.label></a></td></tr>\r\n  </table>\r\n</tmpl_if>\r\n\r\n\r\n</tmpl_if>','Article',1,1);
INSERT INTO template VALUES (1,'Default USS','<tmpl_if displayTitle> <h1><tmpl_var title></h1></tmpl_if><tmpl_if description>    <tmpl_var description><p /></tmpl_if><tmpl_if session.scratch.search> <tmpl_var search.form></tmpl_if><table width="100%" cellpadding=2 cellspacing=1 border=0><tr><td align="right" class="tableMenu"><tmpl_if canPost>   <a href="<tmpl_var post.url>"><tmpl_var post.label></a> &middot;</tmpl_if><a href="<tmpl_var search.url>"><tmpl_var search.label></a></td></tr></table><table width="100%" cellspacing=1 cellpadding=2 border=0><tr><td class="tableHeader"><tmpl_var title.label></td><td class="tableHeader"><tmpl_var date.label></td><td class="tableHeader"><tmpl_var by.label></td></tr><tmpl_loop submissions_loop><tmpl_if submission.inDateRange><tr><td class="tableData">     <a href="<tmpl_var submission.URL>">  <tmpl_var submission.title>    <tmpl_if submission.currentUser>        (<tmpl_var submission.status>)     </tmpl_if></td><td class="tableData"><tmpl_var submission.date></td><td class="tableData"><a href="<tmpl_var submission.userProfile>"><tmpl_var submission.username></a></td></tr><tmpl_else> <tmpl_if canModerate><tr><td class="tableData">     <i>*<a href="<tmpl_var submission.URL>">  <tmpl_var submission.title>    <tmpl_if submission.currentUser>        (<tmpl_var submission.status>)     </tmpl_if></i></td><td class="tableData"><i><tmpl_var submission.date></i></td><td class="tableData"><i><a href="<tmpl_var submission.userProfile>"><tmpl_var submission.username></a></i></td></tr> </tmpl_if></tmpl_if></tmpl_loop></table><tmpl_if pagination.pageCount.isMultiple>  <div class="pagination">    <tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>  </div></tmpl_if>','USS',1,1);
INSERT INTO template VALUES (16,'FAQ','<a name=\"top\"></a>\r\n<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n <tmpl_if canPost>\n			<a href=\"<tmpl_var post.url>\"> <tmpl_var addquestion.label></a><p />\r\n</tmpl_if>\r\n\r\n<ul>\r\n<tmpl_loop submissions_loop>\r\n   <li><a href=\"#<tmpl_var submission.id>\"><span class=\"faqQuestion\"><tmpl_var submission.title></span></a>\r\n</tmpl_loop>\r\n</ul>\r\n<p />\r\n\r\n\r\n<tmpl_loop submissions_loop>\r\n\r\n  \n		<tmpl_if submission.currentUser>\n			<tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var submission.edit.url>\"><tmpl_var submission.edit.label></a>]</tmpl_unless>\n		</tmpl_if>\n		<tmpl_if canModerate>\n			<tmpl_if session.var.adminOn><tmpl_var submission.controls><tmpl_else><tmpl_unless submission.currentUser><tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var submission.edit.url>\"><tmpl_var submission.edit.label></a>]</tmpl_unless></tmpl_unless></tmpl_if>\n		</tmpl_if>\n		\r\n\r\n  <a name=\"<tmpl_var submission.id>\"><span class=\"faqQuestion\"><tmpl_var submission.title></span></a><br />\r\n  <tmpl_var submission.content.full>\r\n  <p /><a href=\"#top\">[top]</a><p />\r\n</tmpl_loop>\r\n\r\n','USS',1,1);
INSERT INTO template VALUES (2,'Traditional with Thumbnails','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n\r\n<tmpl_if session.scratch.search>\r\n <tmpl_var search.form>\r\n</tmpl_if>\r\n\r\n\r\n<table width=\"100%\" cellpadding=2 cellspacing=1 border=0><tr>\r\n<td align=\"right\" class=\"tableMenu\">\r\n\r\n<tmpl_if canPost>\r\n   <a href=\"<tmpl_var post.url>\"><tmpl_var post.label></a> &middot;\r\n</tmpl_if>\r\n\r\n<a href=\"<tmpl_var search.url>\"><tmpl_var search.label></a>\r\n\r\n</td></tr></table>\r\n\r\n<table width=\"100%\" cellspacing=1 cellpadding=2 border=0>\r\n<tr>\r\n<td class=\"tableHeader\"><tmpl_var title.label></td>\r\n<td class=\"tableHeader\"><tmpl_var thumbnail.label></td>\r\n<td class=\"tableHeader\"><tmpl_var date.label></td>\r\n<td class=\"tableHeader\"><tmpl_var by.label></td>\r\n</tr>\r\n\r\n<tmpl_loop submissions_loop>\r\n\r\n<tr>\r\n<td class=\"tableData\">\r\n     <a href=\"<tmpl_var submission.URL>\">  <tmpl_var submission.title>\r\n    <tmpl_if submission.currentUser>\r\n        (<tmpl_var submission.status>)\r\n     </tmpl_if>\r\n</td>\r\n   <td class=\"tableData\">\r\n      <tmpl_if submission.thumbnail>\r\n             <a href=\"<tmpl_var submission.url>\"><img src=\"<tmpl_var submission.thumbnail>\" border=\"0\"></a>\r\n      </tmpl_if>\r\n  </td>\r\n\r\n<td class=\"tableData\"><tmpl_var submission.date></td>\r\n<td class=\"tableData\"><a href=\"<tmpl_var submission.userProfile>\"><tmpl_var submission.username></a></td>\r\n</tr>\r\n\r\n</tmpl_loop>\r\n\r\n</table>\r\n\r\n<tmpl_if pagination.pageCount.isMultiple>\r\n  <div class=\"pagination\">\r\n    <tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>\r\n  </div>\r\n</tmpl_if>\r\n\r\n','USS',1,1);
INSERT INTO template VALUES (3,'Weblog','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n\r\n<tmpl_if session.scratch.search>\r\n <tmpl_var search.form>\r\n</tmpl_if>\r\n\r\n\r\n<tmpl_if canPost>\r\n   <a href=\"<tmpl_var post.url>\"><tmpl_var post.label></a> &middot;\r\n</tmpl_if>\r\n\r\n\r\n<a href=\"<tmpl_var search.url>\"><tmpl_var search.label></a>\r\n<p />\r\n<table width=\"100%\" cellpadding=2 cellspacing=1 border=0>\r\n\r\n<tmpl_loop submissions_loop>\r\n\r\n<tr><td class=\"tableHeader\"><tmpl_var submission.title>\r\n  <tmpl_if submission.currentUser>\r\n            (<tmpl_var submission.status>)\r\n  </tmpl_if>\r\n</td></tr><tr><td class=\"tableData\"><b>\r\n  <tmpl_if submission.thumbnail>\r\n    <a href=\"<tmpl_var submission.url>\"><img src=\"<tmpl_var submission.thumbnail>\" border=\"0\" align=\"right\"/></a>\r\n   </tmpl_if>\r\n <tmpl_var by.label> <a href=\"<tmpl_var submission.userProfile>\"><tmpl_var submission.username></a>  - <tmpl_var submission.date></b><br />\r\n<tmpl_var submission.content>\r\n<p /> ( <a href=\"<tmpl_var submission.url>\"><tmpl_var readmore.label></a>\r\n                <tmpl_if submission.responses>\r\n                         | <tmpl_var submission.responses> <tmpl_var responses.label>\r\n                </tmpl_if>\r\n         )<p/>\r\n</td></tr>\r\n\r\n</tmpl_loop>\r\n\r\n</table>\r\n\r\n<tmpl_if pagination.pageCount.isMultiple>\r\n  <div class=\"pagination\">\r\n    <tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.nextPage>\r\n  </div>\r\n</tmpl_if>\r\n','USS',1,1);
INSERT INTO template VALUES (4,'Photo Gallery','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p/>\r\n</tmpl_if>\r\n\r\n<tmpl_if session.scratch.search>\r\n <tmpl_var search.form>\r\n</tmpl_if>\r\n\r\n<tmpl_if canPost>\r\n   <a href=\"<tmpl_var post.url>\"><tmpl_var post.label></a> &middot;\r\n</tmpl_if>\r\n\r\n\r\n<a href=\"<tmpl_var search.url>\"><tmpl_var search.label></a><p />\r\n\r\n<table width=\"100%\" cellpadding=2 cellspacing=1 border=0>\r\n<tr>\r\n<tmpl_loop submissions_loop>\r\n\r\n<td align=\"center\" class=\"tableData\">\r\n  \r\n  <tmpl_if submission.thumbnail>\r\n       <a href=\"<tmpl_var submission.url>\"><img src=\"<tmpl_var submission.thumbnail>\" border=\"0\"/></a><br />\r\n  </tmpl_if>\r\n  <a href=\"<tmpl_var submission.url>\"><tmpl_var submission.title></a>\r\n  <tmpl_if submission.currentUser>\r\n    (<tmpl_var submission.status>)\r\n  </tmpl_if>\r\n</td>\r\n\r\n<tmpl_if submission.thirdColumn>\r\n  </tr><tr>\r\n</tmpl_if>\r\n\r\n</tmpl_loop>\r\n</tr>\r\n</table>\r\n\r\n<tmpl_if pagination.pageCount.isMultiple>\r\n  <div class=\"pagination\">\r\n    <tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>\r\n  </div>\r\n</tmpl_if>\r\n','USS',1,1);
INSERT INTO template VALUES (1,'Default Submission','<h1><tmpl_var submission.header.label></h1><tmpl_var form.header><table><tmpl_if user.isVisitor> <tmpl_if submission.isNew><tr><td><tmpl_var visitorName.label></td><td><tmpl_var visitorName.form></td></tr></tmpl_if> </tmpl_if><tr><td><tmpl_var title.label></td><td><tmpl_var title.form></td></tr><tr><td><tmpl_var body.label></td><td><tmpl_var body.form></td></tr><tr><td><tmpl_var image.label></td><td><tmpl_var image.form></td></tr><tr><td><tmpl_var attachment.label></td><td><tmpl_var attachment.form></td></tr><tr><td><tmpl_var contentType.label></td><td><tmpl_var contentType.form></td></tr><tr><td><tmpl_var startDate.label></td><td><tmpl_var startDate.form></td></tr><tr><td><tmpl_var endDate.label></td><td><tmpl_var endDate.form></td></tr><tr><td></td><td><tmpl_var form.submit></td></tr></table><tmpl_var form.footer>','USS/Submission',1,1);
INSERT INTO template VALUES (1,'Default Forum','<tmpl_if user.canPost>\n	<a href=\"<tmpl_var thread.new.url>\"><tmpl_var thread.new.label></a>\n	<tmpl_unless user.isVisitor>\n		&bull; \n		<tmpl_if user.isSubscribed>\n			<a href=\"<tmpl_var forum.unsubscribe.url>\"><tmpl_var forum.unsubscribe.label></a>\n		<tmpl_else>\n			<a href=\"<tmpl_var forum.subscribe.url>\"><tmpl_var forum.subscribe.label></a>\n		</tmpl_if>\n	</tmpl_unless>\n	&bull;\n	<a href=\"<tmpl_var forum.search.url>\"><tmpl_var forum.search.label></a>\n	<p />\n</tmpl_if>\n\n<table width=\"100%\" cellspacing=\"0\" cellpadding=\"3\" border=\"0\">\n<tr>\n	<td class=\"tableHeader\"><tmpl_var thread.subject.label></td>\n	<td class=\"tableHeader\"><tmpl_var thread.user.label></td>\n	<td class=\"tableHeader\"><a href=\"<tmpl_var thread.sortby.views.url>\"><tmpl_var thread.views.label></a></td>\n	<td class=\"tableHeader\"><a href=\"<tmpl_var thread.sortby.replies.url>\"><tmpl_var thread.replies.label></a></td>\n	<td class=\"tableHeader\"><a href=\"<tmpl_var thread.sortby.rating.url>\"><tmpl_var thread.rating.label></a></td>\n	<td class=\"tableHeader\"><a href=\"<tmpl_var thread.sortby.date.url>\"><tmpl_var thread.date.label></a></td>\n	<td class=\"tableHeader\"><a href=\"<tmpl_var thread.sortby.lastreply.url>\"><tmpl_var thread.last.label></a></td>\n</tr>\n<tmpl_loop thread_loop>\n<tr>\n	<td class=\"tableData\"><a href=\"<tmpl_var thread.root.url>\"><tmpl_var thread.root.subject></a></td>\n	<tmpl_if thread.root.user.isVisitor>\n		<td class=\"tableData\"><tmpl_var thread.root.user.name></td>\n	<tmpl_else>\n		<td class=\"tableData\"><a href=\"<tmpl_var thread.root.user.profile>\"><tmpl_var thread.root.user.name></a></td>\n	</tmpl_if>\n	<td class=\"tableData\" align=\"center\"><tmpl_var thread.views></td>\n	<td class=\"tableData\" align=\"center\"><tmpl_var thread.replies></td>\n	<td class=\"tableData\" align=\"center\"><tmpl_var thread.rating></td>\n	<td class=\"tableData\"><tmpl_var thread.root.date> @ <tmpl_var thread.root.time></td>\n	<td  class=\"tableData\" style=\"font-size: 11px;\">\n		<a href=\"<tmpl_var thread.last.url>\"><tmpl_var thread.last.subject></a>\n		by \n		<tmpl_if thread.last.user.isVisitor>\n			<tmpl_var thread.last.user.name>\n		<tmpl_else>\n			<a href=\"<tmpl_var thread.last.user.profile>\"><tmpl_var thread.last.user.name></a>\n		</tmpl_if>\n		on <tmpl_var thread.last.date> @ <tmpl_var thread.last.time>\n	</td>\n</tr>\n</tmpl_loop>\n</table>\n\n<tmpl_if multiplePages>\n  <div class=\"pagination\">\n    <tmpl_var previousPage>  &middot; <tmpl_var pageList> &middot; <tmpl_var nextPage>\n  </div>\n</tmpl_if>\n\n\n<div align=\"center\">\n<a href=\"<tmpl_var callback.url>\">-=: <tmpl_var callback.label> :=-</a>\n</div>\n','Forum',1,1);
INSERT INTO template VALUES (5,'Classifieds','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_if session.scratch.search>\r\n <tmpl_var search.form>\r\n</tmpl_if>\r\n\r\n<tmpl_if canPost>\r\n   <a href=\"<tmpl_var post.url>\"><tmpl_var post.label></a> &middot;\r\n</tmpl_if>\r\n\r\n<a href=\"<tmpl_var search.url>\"><tmpl_var search.label></a><p />\r\n\r\n<table width=\"100%\" cellpadding=3 cellspacing=0 border=0>\r\n<tr>\r\n<tmpl_loop submissions_loop>\r\n\r\n<td valign=\"top\" class=\"tableData\" width=\"33%\" style=\"border: 1px dotted #aaaaaa; padding: 10px;\">\r\n  <h2><a href=\"<tmpl_var submission.url>\"><tmpl_var submission.title></a></h2>\r\n  <tmpl_if submission.currentUser>\r\n    (<tmpl_var submission.status>)\r\n  </tmpl_if>\r\n<br />\r\n  <tmpl_if submission.thumbnail>\r\n       <a href=\"<tmpl_var submission.url>\"><img src=\"<tmpl_var submission.thumbnail>\" border=\"0\"/ align=\"right\"></a><br />\r\n  </tmpl_if>\r\n<tmpl_var submission.content>\r\n</td>\r\n\r\n<tmpl_if submission.thirdColumn>\r\n  </tr><tr>\r\n</tmpl_if>\r\n\r\n</tmpl_loop>\r\n</tr>\r\n</table>\r\n\r\n<tmpl_if pagination.pageCount.isMultiple>\r\n  <div class=\"pagination\">\r\n    <tmpl_var pagination.previousPage>   <tmpl_var pagination.pageList.upTo20>  <tmpl_var pagination.nextPage>\r\n  </div>\r\n</tmpl_if>\r\n','USS',1,1);
INSERT INTO template VALUES (15,'Topics','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n <tmpl_if canPost>\n			<a href=\"<tmpl_var post.url>\"> <tmpl_var addquestion.label></a><p />\r\n</tmpl_if>\r\n\r\n\r\n<tmpl_loop submissions_loop>\r\n  \n		<tmpl_if submission.currentUser>\n			<tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var submission.edit.url>\"><tmpl_var submission.edit.label></a>]</tmpl_unless>\n		</tmpl_if>\n		<tmpl_if canModerate>\n			<tmpl_if session.var.adminOn><tmpl_var submission.controls><tmpl_else><tmpl_unless submission.currentUser><tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var submission.edit.url>\"><tmpl_var submission.edit.label></a>]</tmpl_unless></tmpl_unless></tmpl_if>\n		</tmpl_if>\n		\r\n  <h2><tmpl_var submission.title></h2>\r\n  <tmpl_var submission.content.full>\r\n  <p />\r\n</tmpl_loop>\r\n\r\n','USS',1,1);
INSERT INTO template VALUES (19,'Link List','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n\r\n <tmpl_if canPost>\n			<a href=\"<tmpl_var post.url>\"> <tmpl_var addlink.label></a><p />\r\n</tmpl_if>\r\n\r\n<tmpl_loop submissions_loop>\r\n   \r\n    \n		<tmpl_if submission.currentUser>\n			<tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var submission.edit.url>\"><tmpl_var submission.edit.label></a>]</tmpl_unless>\n		</tmpl_if>\n		<tmpl_if canModerate>\n			<tmpl_if session.var.adminOn><tmpl_var submission.controls><tmpl_else><tmpl_unless submission.currentUser><tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var submission.edit.url>\"><tmpl_var submission.edit.label></a>]</tmpl_unless></tmpl_unless></tmpl_if>\n		</tmpl_if>\r\n   &middot;\r\n   <a href=\"<tmpl_var submission.userDefined1>\"\r\n   <tmpl_if submission.userDefined2>\r\n          target=\"_blank\"\r\n    </tmpl_if>\r\n    ><span class=\"linkTitle\"><tmpl_var submission.title></span></a>\r\n\r\n    <tmpl_if submission.content.full>\r\n              - <tmpl_var submission.content.full>\r\n   </tmpl_if>\r\n   <br/>\r\n</tmpl_loop>\r\n','USS',1,1);
INSERT INTO template VALUES (18,'Unordered List','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n <tmpl_if canPost>\n			<a href=\"<tmpl_var post.url>\"> <tmpl_var addlink.label></a><p />\r\n</tmpl_if>\r\n\r\n<ul>\r\n<tmpl_loop submissions_loop>\r\n<li>\r\n   \n		<tmpl_if submission.currentUser>\n			<tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var submission.edit.url>\"><tmpl_var submission.edit.label></a>]</tmpl_unless>\n		</tmpl_if>\n		<tmpl_if canModerate>\n			<tmpl_if session.var.adminOn><tmpl_var submission.controls><tmpl_else><tmpl_unless submission.currentUser><tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var submission.edit.url>\"><tmpl_var submission.edit.label></a>]</tmpl_unless></tmpl_unless></tmpl_if>\n		</tmpl_if>\r\n   \r\n   <a href=\"<tmpl_var submission.userDefined1>\"\r\n   <tmpl_if submission.userDefined2>\r\n          target=\"_blank\"\r\n    </tmpl_if>\r\n    ><span class=\"linkTitle\"><tmpl_var submission.title></span></a>\r\n\r\n    <tmpl_if submission.content.full>\r\n              - <tmpl_var submission.content.full>\r\n   </tmpl_if>\r\n </li>\r\n</tmpl_loop>\r\n</u>','USS',1,1);
INSERT INTO template VALUES (1,'Default Product','<style>\r\n.productFeatureHeader,.productSpecificationHeader,.productRelatedHeader,.productAccessoryHeader, .productBenefitHeader  {\r\n    font-weight: bold;\r\n    font-size: 15px;\r\n}\r\n.productFeature,.productSpecification,.productRelated,.productAccessory, .productBenefit {\r\n    font-size: 12px;\r\n}\r\n.productAttributeSeperator {\r\n    background-color: black;\r\n}\r\n</style>\r\n\r\n<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<table width=\"100%\" cellpadding=\"3\" cellspacing=\"0\" border=\"0\">\r\n<tr>\r\n  <td class=\"content\" valign=\"top\">\r\n\r\n<tmpl_if description>\r\n   <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_if price>\r\n    <b>Price:</b> <tmpl_var price><br />\r\n</tmpl_if>\r\n\r\n<tmpl_if productnumber>\r\n    <b>Product Number:</b> <tmpl_var productNumber><br />\r\n</tmpl_if>\r\n\r\n<br>\r\n\r\n<tmpl_if brochure.url>\r\n    <a href=\"<tmpl_var brochure.url>\"><img src=\"<tmpl_var brochure.icon>\" border=0 align=\"absmiddle\"><tmpl_var brochure.label></a><br />\r\n</tmpl_if>\r\n\r\n<tmpl_if manual.url>\r\n    <a href=\"<tmpl_var manual.url>\"><img src=\"<tmpl_var manual.icon>\" border=0 align=\"absmiddle\"><tmpl_var manual.label></a><br />\r\n</tmpl_if>\r\n\r\n<tmpl_if warranty.url>\r\n    <a href=\"<tmpl_var warranty.url>\"><img src=\"<tmpl_var warranty.icon>\" border=0 align=\"absmiddle\"><tmpl_var warranty.label></a><br />\r\n</tmpl_if>\r\n\r\n  </td>\r\n\r\n<td valign=\"top\">\r\n<tmpl_if thumbnail1>\r\n    <a href=\"<tmpl_var image1>\"><img src=\"<tmpl_var thumbnail1>\" border=\"0\" /></a><p />\r\n</tmpl_if>\r\n<tmpl_if thumbnail2>\r\n    <a href=\"<tmpl_var image2>\"><img src=\"<tmpl_var thumbnail2>\" border=\"0\" /></a><p />\r\n</tmpl_if>\r\n<tmpl_if thumbnail3>\r\n    <a href=\"<tmpl_var image3>\"><img src=\"<tmpl_var thumbnail3>\" border=\"0\" /></a><p />\r\n</tmpl_if>\r\n  </td>\r\n</tr>\r\n</table>\r\n\r\n\r\n<table border=\"0\" cellpadding=\"0\" cellspacing=\"5\">\r\n<tr>\r\n<td valign=\"top\" class=\"productFeature\"><div class=\"productFeatureHeader\">Features</div>\r\n\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addfeature.url>\"><tmpl_var addfeature.label></a><p />\r\n</tmpl_if>\r\n\r\n<tmpl_loop feature_loop>\r\n  <tmpl_if session.var.adminOn><tmpl_var feature.controls></tmpl_if><tmpl_var feature.feature><br />\r\n</tmpl_loop>\r\n<p/>\r\n</td>\r\n\r\n  <td class=\"productAttributeSeperator\"><img src=\"^Extras;spacer.gif\" width=\"1\" height=\"1\"></td>\r\n\r\n  <td valign=\"top\" class=\"productBenefit\"><div class=\"productBenefitHeader\">Benefits</div>\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addBenefit.url>\"><tmpl_var addBenefit.label></a><p />\r\n</tmpl_if>\r\n<tmpl_loop benefit_loop>\r\n  <tmpl_if session.var.adminOn><tmpl_var benefit.controls></tmpl_if><tmpl_var benefit.benefit><br />\r\n</tmpl_loop>\r\n<p/></td>\r\n\r\n  <td class=\"productAttributeSeperator\"><img src=\"^Extras;spacer.gif\" width=\"1\" height=\"1\"></td>\r\n\r\n  <td valign=\"top\" class=\"productSpecification\"><div class=\"productSpecificationHeader\">Specifications</div>\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addSpecification.url>\"><tmpl_var addSpecification.label></a><p />\r\n</tmpl_if>\r\n<tmpl_loop specification_loop>\r\n  <tmpl_if session.var.adminOn><tmpl_var specification.controls></tmpl_if><b><tmpl_var specification.label>:</b> <tmpl_var specification.specification> <tmpl_var specification.units><br />\r\n</tmpl_loop>\r\n<p/></td>\r\n\r\n  <td class=\"productAttributeSeperator\"><img src=\"^Extras;spacer.gif\" width=\"1\" height=\"1\"></td>\r\n\r\n  <td valign=\"top\" class=\"productAccessory\"><div class=\"productAccessoryHeader\">Accessories</div>\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addaccessory.url>\"><tmpl_var addaccessory.label></a><p />\r\n</tmpl_if>\r\n\r\n<tmpl_loop accessory_loop>\r\n  <tmpl_if session.var.adminOn><tmpl_var accessory.controls></tmpl_if><a href=\"<tmpl_var accessory.url>\"><tmpl_var accessory.title></a><br />\r\n</tmpl_loop>\r\n<p/></td>\r\n\r\n  <td class=\"productAttributeSeperator\"><img src=\"^Extras;spacer.gif\" width=\"1\" height=\"1\"></td>\r\n\r\n  <td valign=\"top\" class=\"productRelated\"><div class=\"productRelatedHeader\">Related Products</div>\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addRelatedProduct.url>\"><tmpl_var addRelatedProduct.label></a><p />\r\n</tmpl_if>\r\n\r\n<tmpl_loop relatedproduct_loop>\r\n  <tmpl_if session.var.adminOn><tmpl_var RelatedProduct.controls></tmpl_if><a href=\"<tmpl_var relatedproduct.url>\"><tmpl_var relatedproduct.title></a><br />\r\n</tmpl_loop>\r\n</td>\r\n\r\n</tr>\r\n</table>\r\n\r\n','Product',1,1);
INSERT INTO template VALUES (2,'Benefits Showcase','<style>\r\n.productOptions {\r\n  font-family: Helvetica, Arial, sans-serif;\r\n  font-size: 11px;\r\n}\r\n</style>\r\n\r\n<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n\r\n<tmpl_if image1>\r\n    <img src=\"<tmpl_var image1>\" border=\"0\" /><p />\r\n</tmpl_if>\r\n<table width=\"100%\" cellpadding=\"3\" cellspacing=\"0\" border=\"0\">\r\n<tr>\r\n  <td class=\"content\" valign=\"top\" width=\"66%\"><tmpl_if description>\r\n<tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n  <b>Benefits</b><br />\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addBenefit.url>\"><tmpl_var addBenefit.label></a><p />\r\n</tmpl_if>\r\n\r\n<tmpl_loop benefit_loop>\r\n  <tmpl_if session.var.adminOn><tmpl_var benefit.controls></tmpl_if><tmpl_var benefit.benefit><br />\r\n</tmpl_loop>\r\n\r\n  </td>\r\n  <td valign=\"top\" width=\"34%\" class=\"productOptions\">\r\n\r\n<tmpl_if thumbnail2>\r\n    <a href=\"<tmpl_var image2>\"><img src=\"<tmpl_var thumbnail2>\" border=\"0\" /></a><p />\r\n</tmpl_if>\r\n\r\n<b>Specifications</b><br />\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addSpecification.url>\"><tmpl_var addSpecification.label></a><p />\r\n</tmpl_if>\r\n<tmpl_loop specification_loop>\r\n  <tmpl_if session.var.adminOn><tmpl_var specification.controls></tmpl_if><b><tmpl_var specification.label>:</b> <tmpl_var specification.specification> <tmpl_var specification.units><br />\r\n</tmpl_loop>\r\n\r\n<b>Options</b><br />\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addaccessory.url>\"><tmpl_var addaccessory.label></a><p />\r\n</tmpl_if>\r\n\r\n<tmpl_loop accessory_loop>\r\n  <tmpl_if session.var.adminOn><tmpl_var accessory.controls></tmpl_if><a href=\"<tmpl_var accessory.url>\"><tmpl_var accessory.title></a><br />\r\n</tmpl_loop>\r\n\r\n<b>Other Products</b><br />\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addRelatedProduct.url>\"><tmpl_var addRelatedProduct.label></a><p />\r\n</tmpl_if>\r\n<tmpl_loop relatedproduct_loop>\r\n  <tmpl_if session.var.adminOn><tmpl_var RelatedProduct.controls></tmpl_if><a href=\"<tmpl_var relatedproduct.url>\"><tmpl_var relatedproduct.title></a><br />\r\n</tmpl_loop>\r\n\r\n  </td>\r\n</tr>\r\n</table>\r\n\r\n','Product',1,1);
INSERT INTO template VALUES (3,'Three Columns','<style>\r\n.productFeatureHeader,.productSpecificationHeader,.productRelatedHeader,.productAccessoryHeader, .productBenefitHeader  {\r\n   font-weight: bold;\r\n   font-size: 15px;\r\n}\r\n.productFeature,.productSpecification,.productRelated,.productAccessory, .productBenefit {\r\n   font-size: 12px;\r\n}\r\n\r\n</style>\r\n\r\n\r\n<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<table width=\"100%\" cellpadding=\"3\" cellspacing=\"0\" border=\"0\">\r\n<tr>\r\n  <td align=\"center\">\r\n<tmpl_if thumbnail1>\r\n    <a href=\"<tmpl_var image1>\"><img src=\"<tmpl_var thumbnail1>\" border=\"0\" /></a>\r\n</tmpl_if>\r\n</td>\r\n   <td align=\"center\">\r\n<tmpl_if thumbnail2>\r\n    <a href=\"<tmpl_var image2>\"><img src=\"<tmpl_var thumbnail2>\" border=\"0\" /></a>\r\n</tmpl_if>\r\n</td>\r\n  <td align=\"center\">\r\n<tmpl_if thumbnail3>\r\n    <a href=\"<tmpl_var image3>\"><img src=\"<tmpl_var thumbnail3>\" border=\"0\" /></a>\r\n</tmpl_if>\r\n</td>\r\n</tr>\r\n</table>\r\n<table border=\"0\" cellpadding=\"0\" cellspacing=\"5\" width=\"100%\">\r\n<tr>\r\n  <td valign=\"top\" class=\"tableData\" width=\"35%\">\r\n\r\n<b>Features</b><br />\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addfeature.url>\"><tmpl_var addfeature.label></a><p />\r\n</tmpl_if>\r\n<tmpl_loop feature_loop>\r\n  <tmpl_if session.var.adminOn><tmpl_var feature.controls></tmpl_if><tmpl_var feature.feature><br />\r\n</tmpl_loop>\r\n<p />\r\n\r\n<b>Benefits</b><br/>\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addBenefit.url>\"><tmpl_var addBenefit.label></a><p />\r\n</tmpl_if>\r\n\r\n<tmpl_loop benefit_loop>\r\n  <tmpl_if session.var.adminOn><tmpl_var benefit.controls></tmpl_if><tmpl_var benefit.benefit><br />\r\n</tmpl_loop>\r\n<p />\r\n\r\n</td>\r\n  <td valign=\"top\" class=\"tableData\" width=\"35%\">\r\n\r\n<b>Specifications</b><br />\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addSpecification.url>\"><tmpl_var addSpecification.label></a><p />\r\n</tmpl_if>\r\n<tmpl_loop specification_loop>\r\n  <tmpl_if session.var.adminOn><tmpl_var specification.controls></tmpl_if><b><tmpl_var specification.label>:</b> <tmpl_var specification.specification> <tmpl_var specification.units><br />\r\n</tmpl_loop>\r\n<p />\r\n\r\n<b>Accessories</b><br />\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addaccessory.url>\"><tmpl_var addaccessory.label></a><p />\r\n</tmpl_if>\r\n\r\n<tmpl_loop accessory_loop>\r\n  <tmpl_if session.var.adminOn><tmpl_var accessory.controls></tmpl_if><a href=\"<tmpl_var accessory.url>\"><tmpl_var accessory.title></a><br />\r\n</tmpl_loop>\r\n<p />\r\n\r\n<b>Related Products</b><br />\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addRelatedProduct.url>\"><tmpl_var addRelatedProduct.label></a><p />\r\n</tmpl_if>\r\n<tmpl_loop relatedproduct_loop>\r\n   <tmpl_if session.var.adminOn><tmpl_var RelatedProduct.controls></tmpl_if><a href=\"<tmpl_var relatedproduct.url>\"><tmpl_var relatedproduct.title></a><br />\r\n</tmpl_loop>\r\n<p />\r\n</td>\r\n  <td class=\"tableData\" valign=\"top\" width=\"30%\">\r\n    <tmpl_if price> \r\n    <b>Price:</b> <tmpl_var price><br />\r\n</tmpl_if>\r\n\r\n<tmpl_if productnumber>\r\n    <b>Product Number:</b> <tmpl_var productNumber><br />\r\n</tmpl_if>\r\n<br />\r\n<tmpl_if brochure.url>\r\n    <a href=\"<tmpl_var brochure.url>\"><img src=\"<tmpl_var brochure.icon>\" border=0 align=\"absmiddle\" /><tmpl_var brochure.label></a><br />\r\n</tmpl_if>\r\n<tmpl_if manual.url>\r\n    <a href=\"<tmpl_var manual.url>\"><img src=\"<tmpl_var manual.icon>\" border=0 align=\"absmiddle\" /><tmpl_var manual.label></a><br />\r\n</tmpl_if>\r\n<tmpl_if warranty.url>\r\n    <a href=\"<tmpl_var warranty.url>\"><img src=\"<tmpl_var warranty.icon>\" border=0 align=\"absmiddle\" /><tmpl_var warranty.label></a><br />\r\n</tmpl_if>\r\n  </td>\r\n</tr>\r\n</table>\r\n\r\n\r\n','Product',1,1);
INSERT INTO template VALUES (5,'Left Column','\n		<tmpl_if session.var.adminOn>\n		<style>\n			div.wobject:hover {\n				border: 2px ridge gray;\n			}\n			div.wobject {\n				border: 2px hidden;\n			}\n			.dragable{\n  position: relative;\n}\n.dragTrigger{\n  position: relative;\n  cursor: move;\n}\n.dragging{\n  position: relative;\n  cursor: hand;\n  z-index: 2000; \n  background-image: url(\"^Extras;opaque.gif\");\n}\n.draggedOverTop{\n  position: relative;\n  border: 1px dotted #aaaaaa;\n  border-top: 8px #aaaaaa dotted;\n}\n.draggedOverBottom {\n  position: relative;\n  border: 1px dotted #aaaaaa;\n  border-bottom: 8px #aaaaaa dotted;\n}\n.hidden{\n  display: none;\n}\n.blank {\n  position: relative;\n  cursor: hand;\n  background-color: white;\n}\n.blankOver {\n  position: relative;\n  cursor: hand;\n  background-color: black;\n}\n.empty {\n  position: relative;\n  padding: 25px;\n  width: 50px;\n  height: 100px;\n  background-image: url(\"^Extras;opaque.gif\");\n}\n		</style><script language=JavaScript1.2 src=\"^Extras;draggable.js\"></script>\n		</tmpl_if>\n		<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n			<tmpl_var page.controls>\n		</tmpl_if> </tmpl_if>\n		<table cellpadding=\"3\" cellspacing=\"0\" border=\"0\" width=\"100%\">\r\n<tr>\r\n  <td valign=\"top\" class=\"content\" width=\"34%\">	\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n<table border=0 id=\"position1\" class=\"content\">\n            <tbody>\n</tmpl_if> </tmpl_if>\n		<tmpl_loop position1_loop>\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n            <tr id=\"td<tmpl_var wobject.id>\">\n            <td>\n            <div id=\"td<tmpl_var wobject.id>_div\" class=\"dragable\">      \n</tmpl_if></tmpl_if>\n			<tmpl_if wobject.canView> \n				<div class=\"wobject\"> <div class=\"wobject<tmpl_var wobject.namespace>\" id=\"wobjectId<tmpl_var wobject.id>\">\n				<tmpl_if session.var.adminOn> <tmpl_if wobject.canEdit>\n					<tmpl_var wobject.controls><tmpl_if page.canEdit><tmpl_var wobject.controls.drag></tmpl_if>\n				</tmpl_if> </tmpl_if>\n				<tmpl_if wobject.isInDateRange>\n                      			<a name=\"<tmpl_var wobject.id>\"></a>\n					<tmpl_var wobject.content>\n				</tmpl_if wobject.isInDateRange> \n				</div> </div>\n			</tmpl_if>\n			<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n         </div>\n                </td>\n            </tr>\n</tmpl_if></tmpl_if>\n		</tmpl_loop>\n		<tmpl_if session.var.adminOn> \n            </tbody>\n        </table>\n</tmpl_if>\n	</td>\r\n  <td valign=\"top\" class=\"content\" width=\"66%\">	\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n<table border=0 id=\"position2\" class=\"content\">\n            <tbody>\n</tmpl_if> </tmpl_if>\n		<tmpl_loop position2_loop>\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n            <tr id=\"td<tmpl_var wobject.id>\">\n            <td>\n            <div id=\"td<tmpl_var wobject.id>_div\" class=\"dragable\">      \n</tmpl_if></tmpl_if>\n			<tmpl_if wobject.canView> \n				<div class=\"wobject\"> <div class=\"wobject<tmpl_var wobject.namespace>\" id=\"wobjectId<tmpl_var wobject.id>\">\n				<tmpl_if session.var.adminOn> <tmpl_if wobject.canEdit>\n					<tmpl_var wobject.controls><tmpl_if page.canEdit><tmpl_var wobject.controls.drag></tmpl_if>\n				</tmpl_if> </tmpl_if>\n				<tmpl_if wobject.isInDateRange>\n                      			<a name=\"<tmpl_var wobject.id>\"></a>\n					<tmpl_var wobject.content>\n				</tmpl_if wobject.isInDateRange> \n				</div> </div>\n			</tmpl_if>\n			<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n         </div>\n                </td>\n            </tr>\n</tmpl_if></tmpl_if>\n		</tmpl_loop>\n		<tmpl_if session.var.adminOn> \n            </tbody>\n        </table>\n</tmpl_if>\n	</td>\r\n</tr>\r\n</table>\n<tmpl_if session.var.adminOn> \n\n<table>\n<tr id=\"blank\" class=\"hidden\">\n<td>\n<div><div class=\"empty\">&nbsp;</div></div>\n</td>\n</tr>\n</table>\n<iframe id=\"dragSubmitter\" style=\"display: none;\"></iframe>\n<script>\ndragable_init(\"^\\;\");\n</script>\n</tmpl_if>\n		','page',1,1);
INSERT INTO template VALUES (4,'Left Column Collateral','<style>\r\n.productCollateral {\r\n   font-size: 11px;\r\n}\r\n</style>\r\n\r\n\r\n<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n\r\n<table width=\"100%\">\r\n<tr><td valign=\"top\" class=\"productCollateral\" width=\"100\">\r\n<img src=\"^Extras;spacer.gif\" width=\"100\" height=\"1\" /><br />\r\n<tmpl_if brochure.url>\r\n    <a href=\"<tmpl_var brochure.url>\"><img src=\"<tmpl_var brochure.icon>\" border=0 align=\"absmiddle\" /><tmpl_var brochure.label></a><br />\r\n</tmpl_if>\r\n<tmpl_if manual.url>\r\n    <a href=\"<tmpl_var manual.url>\"><img src=\"<tmpl_var manual.icon>\" border=0 align=\"absmiddle\" /><tmpl_var manual.label></a><br />\r\n</tmpl_if>\r\n<tmpl_if warranty.url>\r\n    <a href=\"<tmpl_var warranty.url>\"><img src=\"<tmpl_var warranty.icon>\" border=0 align=\"absmiddle\" /><tmpl_var warranty.label></a><br />\r\n</tmpl_if>\r\n<br/>\r\n<div align=\"center\">\r\n<tmpl_if thumbnail1>\r\n    <a href=\"<tmpl_var image1>\"><img src=\"<tmpl_var thumbnail1>\" border=\"0\" /></a><p />\r\n</tmpl_if>\r\n<tmpl_if thumbnail2>\r\n    <a href=\"<tmpl_var image2>\"><img src=\"<tmpl_var thumbnail2>\" border=\"0\" /></a><p />\r\n</tmpl_if>\r\n<tmpl_if thumbnail3>\r\n    <a href=\"<tmpl_var image3>\"><img src=\"<tmpl_var thumbnail3>\" border=\"0\" /></a><p />\r\n</tmpl_if>\r\n</div>\r\n</td><td valign=\"top\" class=\"content\" width=\"100%\">\r\n<tmpl_if description>\r\n<tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<b>Specs:</b><br/>\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addSpecification.url>\"><tmpl_var addSpecification.label></a><p />\r\n</tmpl_if>\r\n<tmpl_loop specification_loop>\r\n  <tmpl_if session.var.adminOn><tmpl_var specification.controls></tmpl_if><b><tmpl_var specification.label>:</b> <tmpl_var specification.specification> <tmpl_var specification.units><br />\r\n</tmpl_loop>\r\n<p />\r\n\r\n<b>Features:</b><br/>\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addfeature.url>\"><tmpl_var addfeature.label></a><p />\r\n</tmpl_if>\r\n<tmpl_loop feature_loop>\r\n  <tmpl_if session.var.adminOn><tmpl_var feature.controls></tmpl_if><tmpl_var feature.feature><br />\r\n</tmpl_loop>\r\n<p />\r\n\r\n<b>Options:</b><br />\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addaccessory.url>\"><tmpl_var addaccessory.label></a><p />\r\n</tmpl_if>\r\n<tmpl_loop accessory_loop>\r\n  &middot;<tmpl_if session.var.adminOn><tmpl_var accessory.controls></tmpl_if><a href=\"<tmpl_var accessory.url>\"><tmpl_var accessory.title></a><br />\r\n</tmpl_loop>\r\n\r\n</td></tr>\r\n</table>\r\n','Product',1,1);
INSERT INTO template VALUES (4,'Three Over One','\n		<tmpl_if session.var.adminOn>\n		<style>\n			div.wobject:hover {\n				border: 2px ridge gray;\n			}\n			div.wobject {\n				border: 2px hidden;\n			}\n			.dragable{\n  position: relative;\n}\n.dragTrigger{\n  position: relative;\n  cursor: move;\n}\n.dragging{\n  position: relative;\n  cursor: hand;\n  z-index: 2000; \n  background-image: url(\"^Extras;opaque.gif\");\n}\n.draggedOverTop{\n  position: relative;\n  border: 1px dotted #aaaaaa;\n  border-top: 8px #aaaaaa dotted;\n}\n.draggedOverBottom {\n  position: relative;\n  border: 1px dotted #aaaaaa;\n  border-bottom: 8px #aaaaaa dotted;\n}\n.hidden{\n  display: none;\n}\n.blank {\n  position: relative;\n  cursor: hand;\n  background-color: white;\n}\n.blankOver {\n  position: relative;\n  cursor: hand;\n  background-color: black;\n}\n.empty {\n  position: relative;\n  padding: 25px;\n  width: 50px;\n  height: 100px;\n  background-image: url(\"^Extras;opaque.gif\");\n}\n		</style><script language=JavaScript1.2 src=\"^Extras;draggable.js\"></script>\n		</tmpl_if>\n		<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n			<tmpl_var page.controls>\n		</tmpl_if> </tmpl_if>\n		<table cellpadding=\"3\" cellspacing=\"0\" border=\"0\" width=\"100%\">\r\n<tr>\r\n  <td valign=\"top\" class=\"content\" width=\"33%\">	\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n<table border=0 id=\"position1\" class=\"content\">\n            <tbody>\n</tmpl_if> </tmpl_if>\n		<tmpl_loop position1_loop>\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n            <tr id=\"td<tmpl_var wobject.id>\">\n            <td>\n            <div id=\"td<tmpl_var wobject.id>_div\" class=\"dragable\">      \n</tmpl_if></tmpl_if>\n			<tmpl_if wobject.canView> \n				<div class=\"wobject\"> <div class=\"wobject<tmpl_var wobject.namespace>\" id=\"wobjectId<tmpl_var wobject.id>\">\n				<tmpl_if session.var.adminOn> <tmpl_if wobject.canEdit>\n					<tmpl_var wobject.controls><tmpl_if page.canEdit><tmpl_var wobject.controls.drag></tmpl_if>\n				</tmpl_if> </tmpl_if>\n				<tmpl_if wobject.isInDateRange>\n                      			<a name=\"<tmpl_var wobject.id>\"></a>\n					<tmpl_var wobject.content>\n				</tmpl_if wobject.isInDateRange> \n				</div> </div>\n			</tmpl_if>\n			<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n         </div>\n                </td>\n            </tr>\n</tmpl_if></tmpl_if>\n		</tmpl_loop>\n		<tmpl_if session.var.adminOn> \n            </tbody>\n        </table>\n</tmpl_if>\n	</td>\r\n  <td valign=\"top\" class=\"content\" width=\"34%\">	\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n<table border=0 id=\"position2\" class=\"content\">\n            <tbody>\n</tmpl_if> </tmpl_if>\n		<tmpl_loop position2_loop>\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n            <tr id=\"td<tmpl_var wobject.id>\">\n            <td>\n            <div id=\"td<tmpl_var wobject.id>_div\" class=\"dragable\">      \n</tmpl_if></tmpl_if>\n			<tmpl_if wobject.canView> \n				<div class=\"wobject\"> <div class=\"wobject<tmpl_var wobject.namespace>\" id=\"wobjectId<tmpl_var wobject.id>\">\n				<tmpl_if session.var.adminOn> <tmpl_if wobject.canEdit>\n					<tmpl_var wobject.controls><tmpl_if page.canEdit><tmpl_var wobject.controls.drag></tmpl_if>\n				</tmpl_if> </tmpl_if>\n				<tmpl_if wobject.isInDateRange>\n                      			<a name=\"<tmpl_var wobject.id>\"></a>\n					<tmpl_var wobject.content>\n				</tmpl_if wobject.isInDateRange> \n				</div> </div>\n			</tmpl_if>\n			<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n         </div>\n                </td>\n            </tr>\n</tmpl_if></tmpl_if>\n		</tmpl_loop>\n		<tmpl_if session.var.adminOn> \n            </tbody>\n        </table>\n</tmpl_if>\n	</td>\r\n  <td valign=\"top\" class=\"content\" width=\"33%\">	\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n<table border=0 id=\"position3\" class=\"content\">\n            <tbody>\n</tmpl_if> </tmpl_if>\n		<tmpl_loop position3_loop>\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n            <tr id=\"td<tmpl_var wobject.id>\">\n            <td>\n            <div id=\"td<tmpl_var wobject.id>_div\" class=\"dragable\">      \n</tmpl_if></tmpl_if>\n			<tmpl_if wobject.canView> \n				<div class=\"wobject\"> <div class=\"wobject<tmpl_var wobject.namespace>\" id=\"wobjectId<tmpl_var wobject.id>\">\n				<tmpl_if session.var.adminOn> <tmpl_if wobject.canEdit>\n					<tmpl_var wobject.controls><tmpl_if page.canEdit><tmpl_var wobject.controls.drag></tmpl_if>\n				</tmpl_if> </tmpl_if>\n				<tmpl_if wobject.isInDateRange>\n                      			<a name=\"<tmpl_var wobject.id>\"></a>\n					<tmpl_var wobject.content>\n				</tmpl_if wobject.isInDateRange> \n				</div> </div>\n			</tmpl_if>\n			<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n         </div>\n                </td>\n            </tr>\n</tmpl_if></tmpl_if>\n		</tmpl_loop>\n		<tmpl_if session.var.adminOn> \n            </tbody>\n        </table>\n</tmpl_if>\n	</td>\r\n</tr>\r\n<tr>\r\n  <td valign=\"top\" class=\"content\" colspan=\"3\">	\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n<table border=0 id=\"position4\" class=\"content\">\n            <tbody>\n</tmpl_if> </tmpl_if>\n		<tmpl_loop position4_loop>\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n            <tr id=\"td<tmpl_var wobject.id>\">\n            <td>\n            <div id=\"td<tmpl_var wobject.id>_div\" class=\"dragable\">      \n</tmpl_if></tmpl_if>\n			<tmpl_if wobject.canView> \n				<div class=\"wobject\"> <div class=\"wobject<tmpl_var wobject.namespace>\" id=\"wobjectId<tmpl_var wobject.id>\">\n				<tmpl_if session.var.adminOn> <tmpl_if wobject.canEdit>\n					<tmpl_var wobject.controls><tmpl_if page.canEdit><tmpl_var wobject.controls.drag></tmpl_if>\n				</tmpl_if> </tmpl_if>\n				<tmpl_if wobject.isInDateRange>\n                      			<a name=\"<tmpl_var wobject.id>\"></a>\n					<tmpl_var wobject.content>\n				</tmpl_if wobject.isInDateRange> \n				</div> </div>\n			</tmpl_if>\n			<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n         </div>\n                </td>\n            </tr>\n</tmpl_if></tmpl_if>\n		</tmpl_loop>\n		<tmpl_if session.var.adminOn> \n            </tbody>\n        </table>\n</tmpl_if>\n	</td>\r\n</tr>\r\n</table>\n<tmpl_if session.var.adminOn> \n\n<table>\n<tr id=\"blank\" class=\"hidden\">\n<td>\n<div><div class=\"empty\">&nbsp;</div></div>\n</td>\n</tr>\n</table>\n<iframe id=\"dragSubmitter\" style=\"display: none;\"></iframe>\n<script>\ndragable_init(\"^\\;\");\n</script>\n</tmpl_if>\n		','page',1,1);
INSERT INTO template VALUES (3,'One Over Three','\n		<tmpl_if session.var.adminOn>\n		<style>\n			div.wobject:hover {\n				border: 2px ridge gray;\n			}\n			div.wobject {\n				border: 2px hidden;\n			}\n			.dragable{\n  position: relative;\n}\n.dragTrigger{\n  position: relative;\n  cursor: move;\n}\n.dragging{\n  position: relative;\n  cursor: hand;\n  z-index: 2000; \n  background-image: url(\"^Extras;opaque.gif\");\n}\n.draggedOverTop{\n  position: relative;\n  border: 1px dotted #aaaaaa;\n  border-top: 8px #aaaaaa dotted;\n}\n.draggedOverBottom {\n  position: relative;\n  border: 1px dotted #aaaaaa;\n  border-bottom: 8px #aaaaaa dotted;\n}\n.hidden{\n  display: none;\n}\n.blank {\n  position: relative;\n  cursor: hand;\n  background-color: white;\n}\n.blankOver {\n  position: relative;\n  cursor: hand;\n  background-color: black;\n}\n.empty {\n  position: relative;\n  padding: 25px;\n  width: 50px;\n  height: 100px;\n  background-image: url(\"^Extras;opaque.gif\");\n}\n		</style><script language=JavaScript1.2 src=\"^Extras;draggable.js\"></script>\n		</tmpl_if>\n		<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n			<tmpl_var page.controls>\n		</tmpl_if> </tmpl_if>\n		<table cellpadding=\"3\" cellspacing=\"0\" border=\"0\" width=\"100%\">\r\n<tr>\r\n  <td valign=\"top\" class=\"content\" colspan=\"3\">	\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n<table border=0 id=\"position1\" class=\"content\">\n            <tbody>\n</tmpl_if> </tmpl_if>\n		<tmpl_loop position1_loop>\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n            <tr id=\"td<tmpl_var wobject.id>\">\n            <td>\n            <div id=\"td<tmpl_var wobject.id>_div\" class=\"dragable\">      \n</tmpl_if></tmpl_if>\n			<tmpl_if wobject.canView> \n				<div class=\"wobject\"> <div class=\"wobject<tmpl_var wobject.namespace>\" id=\"wobjectId<tmpl_var wobject.id>\">\n				<tmpl_if session.var.adminOn> <tmpl_if wobject.canEdit>\n					<tmpl_var wobject.controls><tmpl_if page.canEdit><tmpl_var wobject.controls.drag></tmpl_if>\n				</tmpl_if> </tmpl_if>\n				<tmpl_if wobject.isInDateRange>\n                      			<a name=\"<tmpl_var wobject.id>\"></a>\n					<tmpl_var wobject.content>\n				</tmpl_if wobject.isInDateRange> \n				</div> </div>\n			</tmpl_if>\n			<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n         </div>\n                </td>\n            </tr>\n</tmpl_if></tmpl_if>\n		</tmpl_loop>\n		<tmpl_if session.var.adminOn> \n            </tbody>\n        </table>\n</tmpl_if>\n	</td>\r\n</tr>\r\n<tr>\r\n  <td valign=\"top\" class=\"content\" width=\"33%\">	\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n<table border=0 id=\"position2\" class=\"content\">\n            <tbody>\n</tmpl_if> </tmpl_if>\n		<tmpl_loop position2_loop>\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n            <tr id=\"td<tmpl_var wobject.id>\">\n            <td>\n            <div id=\"td<tmpl_var wobject.id>_div\" class=\"dragable\">      \n</tmpl_if></tmpl_if>\n			<tmpl_if wobject.canView> \n				<div class=\"wobject\"> <div class=\"wobject<tmpl_var wobject.namespace>\" id=\"wobjectId<tmpl_var wobject.id>\">\n				<tmpl_if session.var.adminOn> <tmpl_if wobject.canEdit>\n					<tmpl_var wobject.controls><tmpl_if page.canEdit><tmpl_var wobject.controls.drag></tmpl_if>\n				</tmpl_if> </tmpl_if>\n				<tmpl_if wobject.isInDateRange>\n                      			<a name=\"<tmpl_var wobject.id>\"></a>\n					<tmpl_var wobject.content>\n				</tmpl_if wobject.isInDateRange> \n				</div> </div>\n			</tmpl_if>\n			<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n         </div>\n                </td>\n            </tr>\n</tmpl_if></tmpl_if>\n		</tmpl_loop>\n		<tmpl_if session.var.adminOn> \n            </tbody>\n        </table>\n</tmpl_if>\n	</td>\r\n  <td valign=\"top\" class=\"content\" width=\"34%\">	\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n<table border=0 id=\"position3\" class=\"content\">\n            <tbody>\n</tmpl_if> </tmpl_if>\n		<tmpl_loop position3_loop>\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n            <tr id=\"td<tmpl_var wobject.id>\">\n            <td>\n            <div id=\"td<tmpl_var wobject.id>_div\" class=\"dragable\">      \n</tmpl_if></tmpl_if>\n			<tmpl_if wobject.canView> \n				<div class=\"wobject\"> <div class=\"wobject<tmpl_var wobject.namespace>\" id=\"wobjectId<tmpl_var wobject.id>\">\n				<tmpl_if session.var.adminOn> <tmpl_if wobject.canEdit>\n					<tmpl_var wobject.controls><tmpl_if page.canEdit><tmpl_var wobject.controls.drag></tmpl_if>\n				</tmpl_if> </tmpl_if>\n				<tmpl_if wobject.isInDateRange>\n                      			<a name=\"<tmpl_var wobject.id>\"></a>\n					<tmpl_var wobject.content>\n				</tmpl_if wobject.isInDateRange> \n				</div> </div>\n			</tmpl_if>\n			<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n         </div>\n                </td>\n            </tr>\n</tmpl_if></tmpl_if>\n		</tmpl_loop>\n		<tmpl_if session.var.adminOn> \n            </tbody>\n        </table>\n</tmpl_if>\n	</td>\r\n  <td valign=\"top\" class=\"content\" width=\"33%\">	\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n<table border=0 id=\"position4\" class=\"content\">\n            <tbody>\n</tmpl_if> </tmpl_if>\n		<tmpl_loop position4_loop>\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n            <tr id=\"td<tmpl_var wobject.id>\">\n            <td>\n            <div id=\"td<tmpl_var wobject.id>_div\" class=\"dragable\">      \n</tmpl_if></tmpl_if>\n			<tmpl_if wobject.canView> \n				<div class=\"wobject\"> <div class=\"wobject<tmpl_var wobject.namespace>\" id=\"wobjectId<tmpl_var wobject.id>\">\n				<tmpl_if session.var.adminOn> <tmpl_if wobject.canEdit>\n					<tmpl_var wobject.controls><tmpl_if page.canEdit><tmpl_var wobject.controls.drag></tmpl_if>\n				</tmpl_if> </tmpl_if>\n				<tmpl_if wobject.isInDateRange>\n                      			<a name=\"<tmpl_var wobject.id>\"></a>\n					<tmpl_var wobject.content>\n				</tmpl_if wobject.isInDateRange> \n				</div> </div>\n			</tmpl_if>\n			<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n         </div>\n                </td>\n            </tr>\n</tmpl_if></tmpl_if>\n		</tmpl_loop>\n		<tmpl_if session.var.adminOn> \n            </tbody>\n        </table>\n</tmpl_if>\n	</td>\r\n</tr>\r\n</table>\n<tmpl_if session.var.adminOn> \n\n<table>\n<tr id=\"blank\" class=\"hidden\">\n<td>\n<div><div class=\"empty\">&nbsp;</div></div>\n</td>\n</tr>\n</table>\n<iframe id=\"dragSubmitter\" style=\"display: none;\"></iframe>\n<script>\ndragable_init(\"^\\;\");\n</script>\n</tmpl_if>\n		','page',1,1);
INSERT INTO template VALUES (2,'News','\n		<tmpl_if session.var.adminOn>\n		<style>\n			div.wobject:hover {\n				border: 2px ridge gray;\n			}\n			div.wobject {\n				border: 2px hidden;\n			}\n			.dragable{\n  position: relative;\n}\n.dragTrigger{\n  position: relative;\n  cursor: move;\n}\n.dragging{\n  position: relative;\n  cursor: hand;\n  z-index: 2000; \n  background-image: url(\"^Extras;opaque.gif\");\n}\n.draggedOverTop{\n  position: relative;\n  border: 1px dotted #aaaaaa;\n  border-top: 8px #aaaaaa dotted;\n}\n.draggedOverBottom {\n  position: relative;\n  border: 1px dotted #aaaaaa;\n  border-bottom: 8px #aaaaaa dotted;\n}\n.hidden{\n  display: none;\n}\n.blank {\n  position: relative;\n  cursor: hand;\n  background-color: white;\n}\n.blankOver {\n  position: relative;\n  cursor: hand;\n  background-color: black;\n}\n.empty {\n  position: relative;\n  padding: 25px;\n  width: 50px;\n  height: 100px;\n  background-image: url(\"^Extras;opaque.gif\");\n}\n		</style><script language=JavaScript1.2 src=\"^Extras;draggable.js\"></script>\n		</tmpl_if>\n		<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n			<tmpl_var page.controls>\n		</tmpl_if> </tmpl_if>\n		<table cellpadding=\"3\" cellspacing=\"0\" border=\"0\" width=\"100%\">\r\n<tr>\r\n  <td valign=\"top\" class=\"content\" colspan=\"2\" width=\"100%\">	\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n<table border=0 id=\"position1\" class=\"content\">\n            <tbody>\n</tmpl_if> </tmpl_if>\n		<tmpl_loop position1_loop>\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n            <tr id=\"td<tmpl_var wobject.id>\">\n            <td>\n            <div id=\"td<tmpl_var wobject.id>_div\" class=\"dragable\">      \n</tmpl_if></tmpl_if>\n			<tmpl_if wobject.canView> \n				<div class=\"wobject\"> <div class=\"wobject<tmpl_var wobject.namespace>\" id=\"wobjectId<tmpl_var wobject.id>\">\n				<tmpl_if session.var.adminOn> <tmpl_if wobject.canEdit>\n					<tmpl_var wobject.controls><tmpl_if page.canEdit><tmpl_var wobject.controls.drag></tmpl_if>\n				</tmpl_if> </tmpl_if>\n				<tmpl_if wobject.isInDateRange>\n                      			<a name=\"<tmpl_var wobject.id>\"></a>\n					<tmpl_var wobject.content>\n				</tmpl_if wobject.isInDateRange> \n				</div> </div>\n			</tmpl_if>\n			<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n         </div>\n                </td>\n            </tr>\n</tmpl_if></tmpl_if>\n		</tmpl_loop>\n		<tmpl_if session.var.adminOn> \n            </tbody>\n        </table>\n</tmpl_if>\n	</td></tr>\r\n<tr>\r\n  <td valign=\"top\" class=\"content\" width=\"50%\">	\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n<table border=0 id=\"position2\" class=\"content\">\n            <tbody>\n</tmpl_if> </tmpl_if>\n		<tmpl_loop position2_loop>\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n            <tr id=\"td<tmpl_var wobject.id>\">\n            <td>\n            <div id=\"td<tmpl_var wobject.id>_div\" class=\"dragable\">      \n</tmpl_if></tmpl_if>\n			<tmpl_if wobject.canView> \n				<div class=\"wobject\"> <div class=\"wobject<tmpl_var wobject.namespace>\" id=\"wobjectId<tmpl_var wobject.id>\">\n				<tmpl_if session.var.adminOn> <tmpl_if wobject.canEdit>\n					<tmpl_var wobject.controls><tmpl_if page.canEdit><tmpl_var wobject.controls.drag></tmpl_if>\n				</tmpl_if> </tmpl_if>\n				<tmpl_if wobject.isInDateRange>\n                      			<a name=\"<tmpl_var wobject.id>\"></a>\n					<tmpl_var wobject.content>\n				</tmpl_if wobject.isInDateRange> \n				</div> </div>\n			</tmpl_if>\n			<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n         </div>\n                </td>\n            </tr>\n</tmpl_if></tmpl_if>\n		</tmpl_loop>\n		<tmpl_if session.var.adminOn> \n            </tbody>\n        </table>\n</tmpl_if>\n	</td>\r\n  <td valign=\"top\" class=\"content\" width=\"50%\">	\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n<table border=0 id=\"position3\" class=\"content\">\n            <tbody>\n</tmpl_if> </tmpl_if>\n		<tmpl_loop position3_loop>\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n            <tr id=\"td<tmpl_var wobject.id>\">\n            <td>\n            <div id=\"td<tmpl_var wobject.id>_div\" class=\"dragable\">      \n</tmpl_if></tmpl_if>\n			<tmpl_if wobject.canView> \n				<div class=\"wobject\"> <div class=\"wobject<tmpl_var wobject.namespace>\" id=\"wobjectId<tmpl_var wobject.id>\">\n				<tmpl_if session.var.adminOn> <tmpl_if wobject.canEdit>\n					<tmpl_var wobject.controls><tmpl_if page.canEdit><tmpl_var wobject.controls.drag></tmpl_if>\n				</tmpl_if> </tmpl_if>\n				<tmpl_if wobject.isInDateRange>\n                      			<a name=\"<tmpl_var wobject.id>\"></a>\n					<tmpl_var wobject.content>\n				</tmpl_if wobject.isInDateRange> \n				</div> </div>\n			</tmpl_if>\n			<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n         </div>\n                </td>\n            </tr>\n</tmpl_if></tmpl_if>\n		</tmpl_loop>\n		<tmpl_if session.var.adminOn> \n            </tbody>\n        </table>\n</tmpl_if>\n	</td>\r\n</tr>\r\n<tr>\r\n  <td valign=\"top\" class=\"content\" colspan=\"2\" width=\"100%\">	\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n<table border=0 id=\"position4\" class=\"content\">\n            <tbody>\n</tmpl_if> </tmpl_if>\n		<tmpl_loop position4_loop>\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n            <tr id=\"td<tmpl_var wobject.id>\">\n            <td>\n            <div id=\"td<tmpl_var wobject.id>_div\" class=\"dragable\">      \n</tmpl_if></tmpl_if>\n			<tmpl_if wobject.canView> \n				<div class=\"wobject\"> <div class=\"wobject<tmpl_var wobject.namespace>\" id=\"wobjectId<tmpl_var wobject.id>\">\n				<tmpl_if session.var.adminOn> <tmpl_if wobject.canEdit>\n					<tmpl_var wobject.controls><tmpl_if page.canEdit><tmpl_var wobject.controls.drag></tmpl_if>\n				</tmpl_if> </tmpl_if>\n				<tmpl_if wobject.isInDateRange>\n                      			<a name=\"<tmpl_var wobject.id>\"></a>\n					<tmpl_var wobject.content>\n				</tmpl_if wobject.isInDateRange> \n				</div> </div>\n			</tmpl_if>\n			<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n         </div>\n                </td>\n            </tr>\n</tmpl_if></tmpl_if>\n		</tmpl_loop>\n		<tmpl_if session.var.adminOn> \n            </tbody>\n        </table>\n</tmpl_if>\n	</td>\r\n</tr>\r\n</table>\r\n\n<tmpl_if session.var.adminOn> \n\n<table>\n<tr id=\"blank\" class=\"hidden\">\n<td>\n<div><div class=\"empty\">&nbsp;</div></div>\n</td>\n</tr>\n</table>\n<iframe id=\"dragSubmitter\" style=\"display: none;\"></iframe>\n<script>\ndragable_init(\"^\\;\");\n</script>\n</tmpl_if>\n		','page',1,1);
INSERT INTO template VALUES (7,'Side By Side','\n		<tmpl_if session.var.adminOn>\n		<style>\n			div.wobject:hover {\n				border: 2px ridge gray;\n			}\n			div.wobject {\n				border: 2px hidden;\n			}\n			.dragable{\n  position: relative;\n}\n.dragTrigger{\n  position: relative;\n  cursor: move;\n}\n.dragging{\n  position: relative;\n  cursor: hand;\n  z-index: 2000; \n  background-image: url(\"^Extras;opaque.gif\");\n}\n.draggedOverTop{\n  position: relative;\n  border: 1px dotted #aaaaaa;\n  border-top: 8px #aaaaaa dotted;\n}\n.draggedOverBottom {\n  position: relative;\n  border: 1px dotted #aaaaaa;\n  border-bottom: 8px #aaaaaa dotted;\n}\n.hidden{\n  display: none;\n}\n.blank {\n  position: relative;\n  cursor: hand;\n  background-color: white;\n}\n.blankOver {\n  position: relative;\n  cursor: hand;\n  background-color: black;\n}\n.empty {\n  position: relative;\n  padding: 25px;\n  width: 50px;\n  height: 100px;\n  background-image: url(\"^Extras;opaque.gif\");\n}\n		</style><script language=JavaScript1.2 src=\"^Extras;draggable.js\"></script>\n		</tmpl_if>\n		<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n			<tmpl_var page.controls>\n		</tmpl_if> </tmpl_if>\n		<table cellpadding=\"3\" cellspacing=\"0\" border=\"0\" width=\"100%\">\r\n<tr>\r\n  <td valign=\"top\" class=\"content\" width=\"50%\">	\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n<table border=0 id=\"position1\" class=\"content\">\n            <tbody>\n</tmpl_if> </tmpl_if>\n		<tmpl_loop position1_loop>\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n            <tr id=\"td<tmpl_var wobject.id>\">\n            <td>\n            <div id=\"td<tmpl_var wobject.id>_div\" class=\"dragable\">      \n</tmpl_if></tmpl_if>\n			<tmpl_if wobject.canView> \n				<div class=\"wobject\"> <div class=\"wobject<tmpl_var wobject.namespace>\" id=\"wobjectId<tmpl_var wobject.id>\">\n				<tmpl_if session.var.adminOn> <tmpl_if wobject.canEdit>\n					<tmpl_var wobject.controls><tmpl_if page.canEdit><tmpl_var wobject.controls.drag></tmpl_if>\n				</tmpl_if> </tmpl_if>\n				<tmpl_if wobject.isInDateRange>\n                      			<a name=\"<tmpl_var wobject.id>\"></a>\n					<tmpl_var wobject.content>\n				</tmpl_if wobject.isInDateRange> \n				</div> </div>\n			</tmpl_if>\n			<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n         </div>\n                </td>\n            </tr>\n</tmpl_if></tmpl_if>\n		</tmpl_loop>\n		<tmpl_if session.var.adminOn> \n            </tbody>\n        </table>\n</tmpl_if>\n	</td>\r\n  <td valign=\"top\" class=\"content\" width=\"50%\">	\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n<table border=0 id=\"position2\" class=\"content\">\n            <tbody>\n</tmpl_if> </tmpl_if>\n		<tmpl_loop position2_loop>\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n            <tr id=\"td<tmpl_var wobject.id>\">\n            <td>\n            <div id=\"td<tmpl_var wobject.id>_div\" class=\"dragable\">      \n</tmpl_if></tmpl_if>\n			<tmpl_if wobject.canView> \n				<div class=\"wobject\"> <div class=\"wobject<tmpl_var wobject.namespace>\" id=\"wobjectId<tmpl_var wobject.id>\">\n				<tmpl_if session.var.adminOn> <tmpl_if wobject.canEdit>\n					<tmpl_var wobject.controls><tmpl_if page.canEdit><tmpl_var wobject.controls.drag></tmpl_if>\n				</tmpl_if> </tmpl_if>\n				<tmpl_if wobject.isInDateRange>\n                      			<a name=\"<tmpl_var wobject.id>\"></a>\n					<tmpl_var wobject.content>\n				</tmpl_if wobject.isInDateRange> \n				</div> </div>\n			</tmpl_if>\n			<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n         </div>\n                </td>\n            </tr>\n</tmpl_if></tmpl_if>\n		</tmpl_loop>\n		<tmpl_if session.var.adminOn> \n            </tbody>\n        </table>\n</tmpl_if>\n	</td>\r\n</tr>\r\n</table>\r\n\n<tmpl_if session.var.adminOn> \n\n<table>\n<tr id=\"blank\" class=\"hidden\">\n<td>\n<div><div class=\"empty\">&nbsp;</div></div>\n</td>\n</tr>\n</table>\n<iframe id=\"dragSubmitter\" style=\"display: none;\"></iframe>\n<script>\ndragable_init(\"^\\;\");\n</script>\n</tmpl_if>\n		','page',1,1);
INSERT INTO template VALUES (6,'Right Column','\n		<tmpl_if session.var.adminOn>\n		<style>\n			div.wobject:hover {\n				border: 2px ridge gray;\n			}\n			div.wobject {\n				border: 2px hidden;\n			}\n			.dragable{\n  position: relative;\n}\n.dragTrigger{\n  position: relative;\n  cursor: move;\n}\n.dragging{\n  position: relative;\n  cursor: hand;\n  z-index: 2000; \n  background-image: url(\"^Extras;opaque.gif\");\n}\n.draggedOverTop{\n  position: relative;\n  border: 1px dotted #aaaaaa;\n  border-top: 8px #aaaaaa dotted;\n}\n.draggedOverBottom {\n  position: relative;\n  border: 1px dotted #aaaaaa;\n  border-bottom: 8px #aaaaaa dotted;\n}\n.hidden{\n  display: none;\n}\n.blank {\n  position: relative;\n  cursor: hand;\n  background-color: white;\n}\n.blankOver {\n  position: relative;\n  cursor: hand;\n  background-color: black;\n}\n.empty {\n  position: relative;\n  padding: 25px;\n  width: 50px;\n  height: 100px;\n  background-image: url(\"^Extras;opaque.gif\");\n}\n		</style><script language=JavaScript1.2 src=\"^Extras;draggable.js\"></script>\n		</tmpl_if>\n		<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n			<tmpl_var page.controls>\n		</tmpl_if> </tmpl_if>\n		<table cellpadding=\"3\" cellspacing=\"0\" border=\"0\" width=\"100%\">\r\n<tr>\r\n  <td valign=\"top\" class=\"content\" width=\"66%\">	\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n<table border=0 id=\"position1\" class=\"content\">\n            <tbody>\n</tmpl_if> </tmpl_if>\n		<tmpl_loop position1_loop>\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n            <tr id=\"td<tmpl_var wobject.id>\">\n            <td>\n            <div id=\"td<tmpl_var wobject.id>_div\" class=\"dragable\">      \n</tmpl_if></tmpl_if>\n			<tmpl_if wobject.canView> \n				<div class=\"wobject\"> <div class=\"wobject<tmpl_var wobject.namespace>\" id=\"wobjectId<tmpl_var wobject.id>\">\n				<tmpl_if session.var.adminOn> <tmpl_if wobject.canEdit>\n					<tmpl_var wobject.controls><tmpl_if page.canEdit><tmpl_var wobject.controls.drag></tmpl_if>\n				</tmpl_if> </tmpl_if>\n				<tmpl_if wobject.isInDateRange>\n                      			<a name=\"<tmpl_var wobject.id>\"></a>\n					<tmpl_var wobject.content>\n				</tmpl_if wobject.isInDateRange> \n				</div> </div>\n			</tmpl_if>\n			<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n         </div>\n                </td>\n            </tr>\n</tmpl_if></tmpl_if>\n		</tmpl_loop>\n		<tmpl_if session.var.adminOn> \n            </tbody>\n        </table>\n</tmpl_if>\n	</td>\r\n  <td valign=\"top\" class=\"content\" width=\"34%\">	\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n<table border=0 id=\"position2\" class=\"content\">\n            <tbody>\n</tmpl_if> </tmpl_if>\n		<tmpl_loop position2_loop>\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n            <tr id=\"td<tmpl_var wobject.id>\">\n            <td>\n            <div id=\"td<tmpl_var wobject.id>_div\" class=\"dragable\">      \n</tmpl_if></tmpl_if>\n			<tmpl_if wobject.canView> \n				<div class=\"wobject\"> <div class=\"wobject<tmpl_var wobject.namespace>\" id=\"wobjectId<tmpl_var wobject.id>\">\n				<tmpl_if session.var.adminOn> <tmpl_if wobject.canEdit>\n					<tmpl_var wobject.controls><tmpl_if page.canEdit><tmpl_var wobject.controls.drag></tmpl_if>\n				</tmpl_if> </tmpl_if>\n				<tmpl_if wobject.isInDateRange>\n                      			<a name=\"<tmpl_var wobject.id>\"></a>\n					<tmpl_var wobject.content>\n				</tmpl_if wobject.isInDateRange> \n				</div> </div>\n			</tmpl_if>\n			<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n         </div>\n                </td>\n            </tr>\n</tmpl_if></tmpl_if>\n		</tmpl_loop>\n		<tmpl_if session.var.adminOn> \n            </tbody>\n        </table>\n</tmpl_if>\n	</td>\r\n</tr>\r\n</table>\r\n\n<tmpl_if session.var.adminOn> \n\n<table>\n<tr id=\"blank\" class=\"hidden\">\n<td>\n<div><div class=\"empty\">&nbsp;</div></div>\n</td>\n</tr>\n</table>\n<iframe id=\"dragSubmitter\" style=\"display: none;\"></iframe>\n<script>\ndragable_init(\"^\\;\");\n</script>\n</tmpl_if>\n		','page',1,1);
INSERT INTO template VALUES (1,'Default Page','\n		<tmpl_if session.var.adminOn>\n		<style>\n			div.wobject:hover {\n				border: 2px ridge gray;\n			}\n			div.wobject {\n				border: 2px hidden;\n			}\n			.dragable{\n  position: relative;\n}\n.dragTrigger{\n  position: relative;\n  cursor: move;\n}\n.dragging{\n  position: relative;\n  cursor: hand;\n  z-index: 2000; \n  background-image: url(\"^Extras;opaque.gif\");\n}\n.draggedOverTop{\n  position: relative;\n  border: 1px dotted #aaaaaa;\n  border-top: 8px #aaaaaa dotted;\n}\n.draggedOverBottom {\n  position: relative;\n  border: 1px dotted #aaaaaa;\n  border-bottom: 8px #aaaaaa dotted;\n}\n.hidden{\n  display: none;\n}\n.blank {\n  position: relative;\n  cursor: hand;\n  background-color: white;\n}\n.blankOver {\n  position: relative;\n  cursor: hand;\n  background-color: black;\n}\n.empty {\n  position: relative;\n  padding: 25px;\n  width: 50px;\n  height: 100px;\n  background-image: url(\"^Extras;opaque.gif\");\n}\n		</style><script language=JavaScript1.2 src=\"^Extras;draggable.js\"></script>\n		</tmpl_if>\n		<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n			<tmpl_var page.controls>\n		</tmpl_if> </tmpl_if>\n		<table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" width=\"100%\">\r\n<tr>\r\n<td valign=\"top\" class=\"content\">	\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n<table border=0 id=\"position1\" class=\"content\">\n            <tbody>\n</tmpl_if> </tmpl_if>\n		<tmpl_loop position1_loop>\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n            <tr id=\"td<tmpl_var wobject.id>\">\n            <td>\n            <div id=\"td<tmpl_var wobject.id>_div\" class=\"dragable\">      \n</tmpl_if></tmpl_if>\n			<tmpl_if wobject.canView> \n				<div class=\"wobject\"> <div class=\"wobject<tmpl_var wobject.namespace>\" id=\"wobjectId<tmpl_var wobject.id>\">\n				<tmpl_if session.var.adminOn> <tmpl_if wobject.canEdit>\n					<tmpl_var wobject.controls><tmpl_if page.canEdit><tmpl_var wobject.controls.drag></tmpl_if>\n				</tmpl_if> </tmpl_if>\n				<tmpl_if wobject.isInDateRange>\n                      			<a name=\"<tmpl_var wobject.id>\"></a>\n					<tmpl_var wobject.content>\n				</tmpl_if wobject.isInDateRange> \n				</div> </div>\n			</tmpl_if>\n			<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n         </div>\n                </td>\n            </tr>\n</tmpl_if></tmpl_if>\n		</tmpl_loop>\n		<tmpl_if session.var.adminOn> \n            </tbody>\n        </table>\n</tmpl_if>\n	</td>\r\n</tr>\r\n</table>\r\n\n<tmpl_if session.var.adminOn> \n\n<table>\n<tr id=\"blank\" class=\"hidden\">\n<td>\n<div><div class=\"empty\">&nbsp;</div></div>\n</td>\n</tr>\n</table>\n<iframe id=\"dragSubmitter\" style=\"display: none;\"></iframe>\n<script>\ndragable_init(\"^\\;\");\n</script>\n</tmpl_if>\n		','page',1,1);
INSERT INTO template VALUES (2,'Descriptive Site Map','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_loop page_loop>\r\n  <tmpl_var page.indent><a href=\"<tmpl_var page.url>\"><tmpl_var page.title></a> \r\n   <tmpl_if page.synopsis>\r\n       - <tmpl_var page.synopsis>\r\n   </tmpl_if>\r\n <p />\r\n</tmpl_loop>','SiteMap',1,1);
INSERT INTO template VALUES (6,'Guest Book','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_if canPost>\r\n   <a href=\"<tmpl_var post.url>\"><tmpl_var post.label></a> <p />\r\n</tmpl_if>\r\n\r\n\r\n<tmpl_loop submissions_loop>\r\n\r\n<tmpl_if __odd__>\r\n<div class=\"highlight\">\r\n</tmpl_if>\r\n\r\n<b>On <tmpl_var submission.date> <a href=\"<tmpl_var submission.userProfile>\"><tmpl_var submission.username></a> from <a href=\"<tmpl_var submission.url>\">the <tmpl_var submission.title> department</a> wrote</b>, <i><tmpl_var submission.content></i>\r\n\r\n<tmpl_if __odd__>\r\n</div >\r\n</tmpl_if>\r\n\r\n<p/>\r\n\r\n</tmpl_loop>\r\n\r\n<tmpl_if pagination.pageCount.isMultiple>\r\n  <div class=\"pagination\">\r\n    <tmpl_var pagination.previousPage>  <tmpl_var pagination.nextPage>\r\n  </div>\r\n</tmpl_if>\r\n','USS',1,1);
INSERT INTO template VALUES (1,'Default Syndicated Content','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<h1>\r\n<tmpl_if channel.link>\r\n     <a href=\"<tmpl_var channel.link>\" target=\"_blank\"><tmpl_var channel.title></a>    \r\n<tmpl_else>\r\n     <tmpl_var channel.title>\r\n</tmpl_if>\r\n</h1>\r\n\r\n<tmpl_if channel.description>\r\n    <tmpl_var channel.description><p />\r\n</tmpl_if>\r\n\r\n\r\n<tmpl_loop item_loop>\r\n<li>\r\n  <tmpl_if link>\r\n       <a href=\"<tmpl_var link>\" target=\"_blank\"><tmpl_var title></a>    \r\n    <tmpl_else>\r\n       <tmpl_var title>\r\n  </tmpl_if>\r\n     <tmpl_if description>\r\n        - <tmpl_var description>\r\n     </tmpl_if>\r\n     <br>\r\n\r\n</tmpl_loop>','SyndicatedContent',1,1);
INSERT INTO template VALUES (1,'Default Poll','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<span class=\"pollQuestion\"><tmpl_var question></span><br />\r\n\r\n<tmpl_if canVote>\r\n\r\n    <tmpl_var form.start>\r\n    <tmpl_loop answer_loop>\r\n         <tmpl_var answer.form> <tmpl_var answer.text><br />\r\n    </tmpl_loop>\r\n     <p />\r\n    <tmpl_var form.submit>\r\n    <tmpl_var form.end>\r\n\r\n<tmpl_else>\r\n\r\n    <tmpl_loop answer_loop>\r\n       <span class=\"pollAnswer\"><hr size=\"1\"><tmpl_var answer.text><br></span>\r\n       <table cellpadding=0 cellspacing=0 border=0><tr>\r\n           <td width=\"<tmpl_var answer.graphWidth>\" class=\"pollColor\"><img src=\"^Extras;spacer.gif\" height=\"1\" width=\"1\"></td>\r\n           <td class=\"pollAnswer\">&nbsp;&nbsp;<tmpl_var answer.percent>% (<tmpl_var answer.total>)</td>\r\n       </tr></table>\r\n    </tmpl_loop>\r\n    <span class=\"pollAnswer\"><hr size=\"1\"><b><tmpl_var responses.label>:</b> <tmpl_var responses.total></span>\r\n\r\n</tmpl_if>\r\n\r\n','Poll',1,1);
INSERT INTO template VALUES (1,'Mail Form','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if error_loop>\r\n<ul>\r\n<tmpl_loop error_loop>\r\n  <li><b><tmpl_var error.message></b>\r\n</tmpl_loop>\r\n</ul>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_if canEdit>\r\n      <a href=\"<tmpl_var entryList.url>\"><tmpl_var entryList.label></a>\r\n      &middot; <a href=\"<tmpl_var export.tab.url>\"><tmpl_var export.tab.label></a>\r\n      <tmpl_if entryId>\r\n        &middot; <a href=\"<tmpl_var delete.url>\"><tmpl_var delete.label></a>\r\n      </tmpl_if>\r\n      <tmpl_if session.var.adminOn>\r\n          &middot; <a href=\"<tmpl_var addField.url>\"><tmpl_var addField.label></a>\r\n			 &middot; <a href=\"<tmpl_var addTab.url>\"><tmpl_var addTab.label></a>\r\n     </tmpl_if>\r\n   <p /> \r\n</tmpl_if>\r\n\r\n<tmpl_var form.start>\r\n<table>\r\n<tmpl_loop field_loop>\r\n  <tmpl_unless field.isHidden>\r\n     <tr><td class=\"formDescription\" valign=\"top\">\r\n        <tmpl_if session.var.adminOn><tmpl_if canEdit><tmpl_var field.controls></tmpl_if></tmpl_if>\r\n        <tmpl_var field.label>\r\n     </td><td class=\"tableData\" valign=\"top\">\r\n       <tmpl_if field.isDisplayed>\r\n            <tmpl_var field.value>\r\n       <tmpl_else>\r\n            <tmpl_var field.form>\r\n       </tmpl_if>\r\n        <tmpl_if field.required>*</tmpl_if>\r\n        <span class=\"formSubtext\"><br /><tmpl_var field.subtext></span>\r\n     </td></tr>\r\n  </tmpl_unless>\r\n</tmpl_loop>\r\n<tr><td></td><td><tmpl_var form.send></td></tr>\r\n</table>\r\n\r\n<tmpl_var form.end>\r\n','DataForm',1,1);
INSERT INTO template VALUES (2,'Default Email','<tmpl_var edit.url>\n\n<tmpl_loop field_loop><tmpl_unless field.isMailField><tmpl_var field.label>:	 <tmpl_var field.value>\n</tmpl_unless></tmpl_loop>','DataForm',1,1);
INSERT INTO template VALUES (3,'Default Acknowledgement','<tmpl_var acknowledgement>\r\n<p />\r\n<table border=\"0\">\r\n<tmpl_loop field_loop>\r\n<tmpl_unless field.isMailField><tmpl_unless field.isHidden>\r\n  <tr><td class=\"tableHeader\"><tmpl_var field.label></td>\r\n  <td class=\"tableData\"><tmpl_var field.value></td></tr>\r\n</tmpl_unless></tmpl_unless>\r\n</tmpl_loop>\r\n</table>\r\n<p />\r\n<a href=\"<tmpl_var back.url>\"><tmpl_var back.label></a>','DataForm',1,1);
INSERT INTO template VALUES (1,'Data List','<a href=\"<tmpl_var back.url>\"><tmpl_var back.label></a>\n<p />\n<table width=\"100%\">\n<tr>\n<td class=\"tableHeader\">Entry ID</td>\n<tmpl_loop field_loop>\n  <tmpl_unless field.isMailField>\n    <td class=\"tableHeader\"><tmpl_var field.label></td>\n  </tmpl_unless field.isMailField>\n</tmpl_loop field_loop>\n<td class=\"tableHeader\">Submission Date</td>\n</tr>\n<tmpl_loop record_loop>\n<tr>\n  <td class=\"tableData\"><a href=\"<tmpl_var record.edit.url>\"><tmpl_var record.entryId></a></td>\n  <tmpl_loop record.data_loop>\n    <tmpl_unless record.data.isMailField>\n       <td class=\"tableData\"><tmpl_var record.data.value></td>\n     </tmpl_unless record.data.isMailField>\n  </tmpl_loop record.data_loop>\n  <td class=\"tableData\"><tmpl_var record.submissionDate.human></td>\n</tr>\n</tmpl_loop record_loop>\n</table>','DataForm/List',1,1);
INSERT INTO template VALUES (1,'Default HTTP Proxy','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_if search.for>\r\n  <tmpl_if content>\r\n    <!-- Display search string. Remove if unwanted -->\r\n    <tmpl_var search.for>\r\n  <tmpl_else>\r\n    <!-- Error: Starting point not found -->\r\n    <b>Error: Search string <i><tmpl_var search.for></i> not found in content.</b>\r\n  </tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_var content>\r\n\r\n<tmpl_if stop.at>\r\n  <tmpl_if content.trailing>\r\n    <!-- Display stop search string. Remove if unwanted -->\r\n    <tmpl_var stop.at>\r\n  <tmpl_else>\r\n    <!-- Warning: End point not found -->\r\n    <b>Warning: Ending search point <i><tmpl_var stop.at></i> not found in content.</b>\r\n  </tmpl_if>\r\n</tmpl_if>','HttpProxy',1,1);
INSERT INTO template VALUES (1,'Default Message Board','<tmpl_if displayTitle>\n    <h1><tmpl_var title></h1>\n</tmpl_if>\n\n<tmpl_if description>\n    <tmpl_var description><p />\n</tmpl_if>\n\n<tmpl_if session.var.adminOn>\n   <a href=\"<tmpl_var forum.add.url>\"><tmpl_var forum.add.label></a><p />\n</tmpl_if>\n\n<tmpl_if areMultipleForums>\n	<table width=\"100%\" cellpadding=\"3\" cellspacing=\"0\">\n		<tr>\n			<tmpl_if session.var.adminOn>\n				<td></td>\n			</tmpl_if>\n			<td class=\"tableHeader\"><tmpl_var title.label></td>\n			<td class=\"tableHeader\"><tmpl_var views.label></td>\n			<td class=\"tableHeader\"><tmpl_var rating.label></td>\n			<td class=\"tableHeader\"><tmpl_var threads.label></td>\n			<td class=\"tableHeader\"><tmpl_var replies.label></td>\n			<td class=\"tableHeader\"><tmpl_var lastpost.label></td>\n		</tr>\n		<tmpl_loop forum_loop>\n			<tr>\n				<tmpl_if session.var.adminOn>\n					<td><tmpl_var forum.controls></td>\n				</tmpl_if>\n				<td class=\"tableData\">\n					<a href=\"<tmpl_var forum.url>\"><tmpl_var forum.title></a><br />\n					<span style=\"font-size: 10px;\"><tmpl_var forum.description></span>\n				</td>\n				<td class=\"tableData\" align=\"center\"><tmpl_var forum.views></td>\n				<td class=\"tableData\" align=\"center\"><tmpl_var forum.rating></td>\n				<td class=\"tableData\" align=\"center\"><tmpl_var forum.threads></td>\n				<td class=\"tableData\" align=\"center\"><tmpl_var forum.replies></td>\n				<td class=\"tableData\"><span style=\"font-size: 10px;\">\n					<a href=\"<tmpl_var forum.lastpost.url>\"><tmpl_var forum.lastpost.subject></a>\n					by \n					<tmpl_if forum.lastpost.user.isVisitor>\n						<tmpl_var forum.lastpost.user.name>\n					<tmpl_else>\n						<a href=\"<tmpl_var forum.lastpost.user.profile>\"><tmpl_var forum.lastpost.user.name></a>\n					</tmpl_if>\n					on <tmpl_var forum.lastpost.date> @ <tmpl_var forum.lastpost.time>\n				</span></td>\n			</tr>\n		</tmpl_loop>\n	</table>\n<tmpl_else>\n	<h2><tmpl_var default.title></h2>\n	<tmpl_if session.var.adminOn>\n		<tmpl_var default.controls><br />\n	</tmpl_if>\n	<tmpl_var default.description><p />\n	<tmpl_var default.listing>\n</tmpl_if>','MessageBoard',1,1);
INSERT INTO template VALUES (1,'Default Post Form','<h1><tmpl_var newpost.header></h1>\n\n<tmpl_var form.begin>\n<table>\n\n<tmpl_if user.isVisitor>\n	<tr><td><tmpl_var visitorName.label></td><td><tmpl_var visitorName.form></td></tr>\n</tmpl_if>\n\n<tr><td><tmpl_var subject.label></td><td><tmpl_var subject.form></td></tr>\n<tr><td><tmpl_var message.label></td><td><tmpl_var message.form></td></tr>\n\n<tmpl_if newpost.isNewMessage>\n	<tmpl_unless user.isVisitor>\n		<tr><td><tmpl_var subscribe.label></td><td><tmpl_var subscribe.form></td></tr>\n	</tmpl_unless>\n	<tmpl_if user.isModerator>\n		<tr><td><tmpl_var lock.label></td><td><tmpl_var lock.form></td></tr>\n		<tr><td><tmpl_var sticky.label></td><td><tmpl_var sticky.form></td></tr>\n	</tmpl_if>\n</tmpl_if>\n\n<tr><td><tmpl_var contentType.label></td><td><tmpl_var contentType.form></td></tr>\n<tr><td></td><td><tmpl_var form.submit></td></tr>\n\n</table>\n<tmpl_var form.end>\n\n<p>\n<tmpl_var post.full>\n</p>','Forum/PostForm',1,1);
INSERT INTO template VALUES (1,'Default Post','<h1><tmpl_var post.subject></h1>\n\n<table width=\"100%\">\n<tr>\n<td class=\"content\" valign=\"top\">\n<tmpl_var post.message>\n<tmpl_unless post.isLocked>\n	<tmpl_if user.canPost>\n		<p />\n		<a href=\"<tmpl_var post.reply.url>\"><tmpl_var post.reply.label></a>\n		<tmpl_unless post.hasRated>\n			&bull; <tmpl_var post.rate.label>: [ <a href=\"<tmpl_var post.rate.url.1>\">1</a>, <a href=\"<tmpl_var post.rate.url.2>\">2</a>, \n				<a href=\"<tmpl_var post.rate.url.3>\">3</a>, <a href=\"<tmpl_var post.rate.url.4>\">4</a>, <a href=\"<tmpl_var post.rate.url.5>\">5</a> ]\n		</tmpl_unless>\n	</tmpl_if>\n	<tmpl_if post.canEdit>\n		 &bull; <a href=\"<tmpl_var post.edit.url>\"><tmpl_var post.edit.label></a>\n	 	&bull; <a href=\"<tmpl_var post.delete.url>\"><tmpl_var post.delete.label></a>\n	</tmpl_if>\n	<tmpl_if post.isModerator>\n		 &bull; <a href=\"<tmpl_var post.approve.url>\"><tmpl_var post.approve.label></a>\n	 	&bull; <a href=\"<tmpl_var post.deny.url>\"><tmpl_var post.deny.label></a>\n	</tmpl_if>\n</tmpl_unless>\n</td><td valign=\"top\" class=\"tableHeader\" width=\"170\" nowrap=\"1\">\n<b><tmpl_var post.date.label>:</b> <tmpl_var post.date.value> @ <tmpl_var post.time.value><br />\n<b><tmpl_var post.rating.label>:</b> <tmpl_var post.rating.value><br />\n<b><tmpl_var post.views.label>:</b> <tmpl_var post.views.value><br />\n<b><tmpl_var post.status.label>:</b> <tmpl_var post.status.value><br />\n<tmpl_if post.user.isVisitor>\n	<b><tmpl_var post.user.label>:</b> <tmpl_var post.user.name><br />\n<tmpl_else>\n	<b><tmpl_var post.user.label>:</b> <a href=\"<tmpl_var post.user.profile>\"><tmpl_var post.user.name></a><br />\n</tmpl_if>\n</td>\n</tr>\n</table>','Forum/Post',1,1);
INSERT INTO template VALUES (1,'Default Thread','<div align=\"right\">\n<script language=\"JavaScript\" type=\"text/javascript\">	<!--\n	function goLayout(){\n		location = document.layout.layoutSelect.options[document.layout.layoutSelect.selectedIndex].value\n	}\n	//-->	</script>\n\n        <form name=\"layout\"><select name=\"layoutSelect\" size=\"1\" onChange=\"goLayout()\">\n		<option value=\"<tmpl_var thread.layout.flat.url>\" <tmpl_if thread.layout.isFlat>selected=\"1\"</tmpl_if>><tmpl_var thread.layout.flat.label></option>\n		<option value=\"<tmpl_var thread.layout.nested.url>\" <tmpl_if thread.layout.isNested>selected=\"1\"</tmpl_if>><tmpl_var thread.layout.nested.label></option>\n		<option value=\"<tmpl_var thread.layout.threaded.url>\" <tmpl_if thread.layout.isThreaded>selected=\"1\"</tmpl_if>><tmpl_var thread.layout.threaded.label></option>\n	</select> </form> \n</div>\n<tmpl_if thread.layout.isFlat>\n	<tmpl_loop post_loop>\n			<a name=\"<tmpl_var post.id>\"></a>\n			<tmpl_if __ODD__>\n				<div class=\"highlight\" <tmpl_if post.isCurrent>style=\"border: 4px dotted #aaaaaa; padding: 5px;\"</tmpl_if>>\n			<tmpl_else>\n				<div <tmpl_if post.isCurrent>style=\"border: 4px dotted #aaaaaa; padding: 5px;\"</tmpl_if>>\n			</tmpl_if>\n			<tmpl_var post.full>\n		</div>\n	</tmpl_loop>\n</tmpl_if>\n\n<tmpl_if thread.layout.isNested>\n	<tmpl_loop post_loop>\n		<table width=\"100%\" cellspacing=\"0\" cellpadding=\"3\" border=\"0\">\n			<tr>\n			<tmpl_loop post.indent_loop>\n				<td width=\"20\">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp;</td>\n			</tmpl_loop>\n			<td>\n				<a name=\"<tmpl_var post.id>\"></a>\n				<tmpl_if __ODD__>\n					<div class=\"highlight\" <tmpl_if post.isCurrent>style=\"border: 4px dotted #aaaaaa; padding: 5px;\"</tmpl_if>>\n				<tmpl_else>\n					<div <tmpl_if post.isCurrent>style=\"border: 4px dotted #aaaaaa; padding: 5px;\"</tmpl_if>>\n				</tmpl_if>\n					<tmpl_var post.full>\n				</div>\n			</td>\n		</tr>\n		</table>\n	</tmpl_loop>\n</tmpl_if>\n\n<tmpl_if thread.layout.isThreaded>\n	<tmpl_var post.full>\n	<table width=\"100%\" cellspacing=\"0\" cellpadding=\"3\" border=\"0\">\n	<tr>\n		<td class=\"tableHeader\"><tmpl_var thread.subject.label></td>\n		<td class=\"tableHeader\"><tmpl_var thread.user.label></td>\n		<td class=\"tableHeader\"><tmpl_var thread.date.label></td>\n	</tr>\n	<tmpl_loop post_loop>\n		<tmpl_if post.isCurrent>\n			<tr class=\"highlight\">\n		<tmpl_else>\n			<tr>\n		</tmpl_if>\n			<td class=\"tableData\"><tmpl_loop post.indent_loop>&nbsp;&nbsp;&nbsp;</tmpl_loop><a href=\"<tmpl_var post.url>\"><tmpl_var post.subject></a></td>\n			<tmpl_if thread.root.user.isVisitor>\n				<td class=\"tableData\"><tmpl_var post.user.name></td>\n			<tmpl_else>\n				<td class=\"tableData\"><a href=\"<tmpl_var post.user.profile>\"><tmpl_var post.user.name></a></td>\n			</tmpl_if>\n			<td class=\"tableData\"><tmpl_var post.date.value> @ <tmpl_var post.time.value></td>\n		</tr>\n	</tmpl_loop>\n	</table>\n</tmpl_if>\n\n<tmpl_if multiplePages>\n  <div class=\"pagination\">\n    <tmpl_var previousPage>  &middot; <tmpl_var pageList> &middot; <tmpl_var nextPage>\n  </div>\n</tmpl_if>\n\n<p />\n<a href=\"<tmpl_var thread.list.url>\"><tmpl_var thread.list.label></a> &bull;\n<a href=\"<tmpl_var thread.previous.url>\"><tmpl_var thread.previous.label></a> &bull;\n<a href=\"<tmpl_var thread.next.url>\"><tmpl_var thread.next.label></a> \n<tmpl_if user.canPost>\n	&bull; <a href=\"<tmpl_var thread.new.url>\"><tmpl_var thread.new.label></a>\n	<tmpl_unless user.isVisitor>\n		&bull;\n		<tmpl_if user.isSubscribed>\n			<a href=\"<tmpl_var thread.unsubscribe.url>\"><tmpl_var thread.unsubscribe.label></a>\n		<tmpl_else>\n			<a href=\"<tmpl_var thread.subscribe.url>\"><tmpl_var thread.subscribe.label></a>\n		</tmpl_if>\n	</tmpl_unless>\n	<tmpl_if user.isModerator>\n		&bull;\n		<tmpl_if thread.isSticky>\n			<a href=\"<tmpl_var thread.unstick.url>\"><tmpl_var thread.unstick.label></a>\n		<tmpl_else>\n			<a href=\"<tmpl_var thread.stick.url>\"><tmpl_var thread.stick.label></a>\n		</tmpl_if>\n		&bull;\n		<tmpl_if thread.isLocked>\n			<a href=\"<tmpl_var thread.unlock.url>\"><tmpl_var thread.unlock.label></a>\n		<tmpl_else>\n			<a href=\"<tmpl_var thread.lock.url>\"><tmpl_var thread.lock.label></a>\n		</tmpl_if>\n	</tmpl_if>\n</tmpl_if>\n\n<div align=\"center\">\n<a href=\"<tmpl_var callback.url>\">-=: <tmpl_var callback.label> :=-</a>\n</div>','Forum/Thread',1,1);
INSERT INTO template VALUES (1,'Default Forum Notification','<tmpl_var notify.subscription.message>\n\n<tmpl_var post.url>','Forum/Notification',1,1);
INSERT INTO template VALUES (1,'Default Forum Search','<tmpl_var form.begin>\n<table width=\"100%\" class=\"tableMenu\">\n<tr><td align=\"right\" width=\"15%\">\n	<h1><tmpl_var search.label></h1>\n	</td>\n	<td valign=\"top\" width=\"70%\" align=\"center\">\n		<table>\n			<tr><td class=\"tableData\"><tmpl_var all.label></td><td class=\"tableData\"><tmpl_var all.form></td></tr>\'\n			<tr><td class=\"tableData\"><tmpl_var exactphrase.label></td><td class=\"tableData\"><tmpl_var exactphrase.form></td></tr>\n			<tr><td class=\"tableData\"><tmpl_var atleastone.label></td><td class=\"tableData\"><tmpl_var atleastone.form></td></tr>\n			<tr><td class=\"tableData\"><tmpl_var without.label></td><td class=\"tableData\"><tmpl_var without.form></td></tr>\n			<tr><td class=\"tableData\"><tmpl_var results.label></td><td class=\"tableData\"><tmpl_var results.form></td></tr>\n		</table>\n	</td><td width=\"15%\">\n        		<tmpl_var form.search>\n	</td>\n</tr></table>\n<tmpl_var form.end>\n<tmpl_if doit>\n	<table width=\"100%\" cellspacing=\"0\" cellpadding=\"3\" border=\"0\">\n	<tr>\n		<td class=\"tableHeader\"><tmpl_var post.subject.label></td>\n		<td class=\"tableHeader\"><tmpl_var post.user.label></td>\n		<td class=\"tableHeader\"><tmpl_var post.date.label></td>\n	</tr>\n	<tmpl_loop post_loop>\n			<tr>\n			<td class=\"tableData\"><a href=\"<tmpl_var post.url>\"><tmpl_var post.subject></a></td>\n			<tmpl_if thread.root.user.isVisitor>\n				<td class=\"tableData\"><tmpl_var post.user.name></td>\n			<tmpl_else>\n				<td class=\"tableData\"><a href=\"<tmpl_var post.user.profile>\"><tmpl_var post.user.name></a></td>\n			</tmpl_if>\n			<td class=\"tableData\"><tmpl_var post.date> @ <tmpl_var post.time></td>\n		</tr>\n	</tmpl_loop>\n	</table>\n</tmpl_if>\n\n<tmpl_if multiplePages>\n  <div class=\"pagination\">\n    <tmpl_var previousPage>  &middot; <tmpl_var pageList> &middot; <tmpl_var nextPage>\n  </div>\n</tmpl_if>','Forum/Search',1,1);
INSERT INTO template VALUES (1000,'AutoGen ^t;','<tmpl_if session.var.adminOn>\n<tmpl_var config.button>\n</tmpl_if>\n<span class=\"horizontalMenu\">\n<tmpl_loop page_loop>\n<a class=\"horizontalMenu\"\n   <tmpl_if page.newWindow>target=\"_blank\"</tmpl_if>\n   href=\"<tmpl_var page.url>\"><tmpl_var page.menuTitle></a>\n   <tmpl_unless \"__last__\"> &middot; </tmpl_unless>\n</tmpl_loop>\n</span>','Navigation',1,1);
INSERT INTO template VALUES (1001,'AutoGen ^m;','<tmpl_if session.var.adminOn>\n<tmpl_var config.button>\n</tmpl_if>\n<span class=\"horizontalMenu\">\n<tmpl_loop page_loop>\n<a class=\"horizontalMenu\" \n   <tmpl_if page.newWindow>target=\"_blank\"</tmpl_if>\n   href=\"<tmpl_var page.url>\"><tmpl_var page.menuTitle></a>\n   <tmpl_unless \"__last__\"> &middot; </tmpl_unless>\n</tmpl_loop>\n</span>','Navigation',1,1);
INSERT INTO template VALUES (1000,'Syndicated Articles','<tmpl_if displayTitle>\n    <h1><tmpl_var title></h1>\n</tmpl_if>\n\n<tmpl_if description>\n    <tmpl_var description><p />\n</tmpl_if>\n\n<h1>\n<tmpl_if channel.link>\n     <a href=\"<tmpl_var channel.link>\" target=\"_blank\"><tmpl_var channel.title></a>    \n<tmpl_else>\n     <tmpl_var channel.title>\n</tmpl_if>\n</h1>\n\n<tmpl_if channel.description>\n    <tmpl_var channel.description><p />\n</tmpl_if>\n\n\n<tmpl_loop item_loop>\n\n       <b><tmpl_var title></b>\n     <tmpl_if description>\n        <br /><tmpl_var description>\n     </tmpl_if>\n  <tmpl_if link>\n       <br /><a href=\"<tmpl_var link>\" target=\"_blank\" style=\"font-size: 9px;\">Read More...</a>    \n   </tmpl_if>\n     <br /><br />\n\n</tmpl_loop>','SyndicatedContent',1,1);
INSERT INTO template VALUES (1,'Default Submission Form','<h1><tmpl_var submission.header.label></h1>\n\n<tmpl_var form.header>\n	<table>\n	<tmpl_if user.isVisitor> <tmpl_if submission.isNew>\n		<tr><td><tmpl_var visitorName.label></td><td><tmpl_var visitorName.form></td></tr>\n	</tmpl_if> </tmpl_if>\n	<tr><td><tmpl_var title.label></td><td><tmpl_var title.form></td></tr>\n	<tr><td><tmpl_var body.label></td><td><tmpl_var body.form></td></tr>\n	<tr><td><tmpl_var image.label></td><td><tmpl_var image.form></td></tr>\n	<tr><td><tmpl_var attachment.label></td><td><tmpl_var attachment.form></td></tr>\n	<tr><td><tmpl_var contentType.label></td><td><tmpl_var contentType.form></td></tr>\n	<tr><td></td><td><tmpl_var form.submit></td></tr>\n	</table>\n<tmpl_var form.footer>\n','USS/SubmissionForm',1,1);
INSERT INTO template VALUES (2,'FAQ Submission Form','<h1><tmpl_var question.header.label></h1>\n\n<tmpl_var form.header>\n	<table>\n	<tmpl_if user.isVisitor> <tmpl_if submission.isNew>\n		<tr><td><tmpl_var visitorName.label></td><td><tmpl_var visitorName.form></td></tr>\n	</tmpl_if> </tmpl_if>\n	<tr><td><tmpl_var question.label></td><td><tmpl_var title.form.textarea></td></tr>\n	<tr><td><tmpl_var answer.label></td><td><tmpl_var body.form></td></tr>\n	<tr><td><tmpl_var contentType.label></td><td><tmpl_var contentType.form></td></tr>\n	<tr><td></td><td><tmpl_var form.submit></td></tr>\n	</table>\n<tmpl_var form.footer>\n','USS/SubmissionForm',1,1);
INSERT INTO template VALUES (3,'Link List Submission Form','<h1><tmpl_var link.header.label></h1>\n\n<tmpl_var form.header>\n	<table>\n	<tmpl_if user.isVisitor> <tmpl_if submission.isNew>\n		<tr><td><tmpl_var visitorName.label></td><td><tmpl_var visitorName.form></td></tr>\n	</tmpl_if> </tmpl_if>\n	<tr><td><tmpl_var title.label></td><td><tmpl_var title.form></td></tr>\n	<tr><td><tmpl_var description.label></td><td><tmpl_var body.form.textarea></td></tr>\n	<tr><td><tmpl_var contentType.label></td><td><tmpl_var contentType.form></td></tr>\n	<tr><td><tmpl_var url.label></td><td><tmpl_var userDefined1.form></td></tr>\n	<tr><td><tmpl_var newWindow.label></td><td><tmpl_var userDefined2.form.yesNo></td></tr>\n	<tr><td></td><td><tmpl_var form.submit></td></tr>\n	</table>\n<tmpl_var form.footer>\n','USS/SubmissionForm',1,1);
INSERT INTO template VALUES (1,'Default Login Box','<div class=\"loginBox\">\n<tmpl_if user.isVisitor>\n	<tmpl_var form.header>\n             <span><tmpl_var username.label><br></span>\n             <tmpl_var username.form>\n             <span><br><tmpl_var password.label><br></span>\n             <tmpl_var password.form>\n             <span><br></span>\n             <tmpl_var form.login>\n	<tmpl_var form.footer>\n	<tmpl_if session.setting.anonymousRegistration>\n                        <p><a href=\"<tmpl_var account.create.url>\"><tmpl_var account.create.label></a></p>\n	</tmpl_if>	\n<tmpl_else>\n	<tmpl_unless customText>\n		<tmpl_var hello.label> <a href=\"<tmpl_var account.display.url>\"><tmpl_var session.user.username></a>.\n                          <tmpl_var logout.label>\n	<tmpl_else>\n		<tmpl_var customText>\n	</tmpl_unless>\n</tmpl_if>\n</div>\n','Macro/L_loginBox',1,1);
INSERT INTO template VALUES (2,'Horizontal Login Box','<div class=\"loginBox\">\n<tmpl_if user.isVisitor>\n	<tmpl_var form.header>\n	<table border=\"0\" class=\"loginBox\" cellpadding=\"1\" cellspacing=\"0\">\n	<tr>\n		<td><tmpl_var username.form></td>\n		<td><tmpl_var password.form></td>\n		<td><tmpl_var form.login></td>\n	</tr>\n	<tr>\n		<td><tmpl_var username.label></td>\n		<td><tmpl_var password.label></td>\n		<td></td>\n	</tr>\n	</table>             	<tmpl_if session.setting.anonymousRegistration>\n                        <a href=\"<tmpl_var account.create.url>\"><tmpl_var account.create.label></a>\n	</tmpl_if>		<tmpl_var form.footer> \n<tmpl_else>\n	<tmpl_unless customText>\n		<tmpl_var hello.label> <a href=\"<tmpl_var account.display.url>\"><tmpl_var session.user.username></a>.\n                          <tmpl_var logout.label><br />\n	<tmpl_else>\n		<tmpl_var customText>\n	</tmpl_unless>\n</tmpl_if>\n</div>\n','Macro/L_loginBox',1,1);
INSERT INTO template VALUES (1,'Default SQL Report','<tmpl_if displayTitle>\n    <h1><tmpl_var title></h1>\n</tmpl_if>\n\n<tmpl_if description>\n    <tmpl_var description><p />\n</tmpl_if>\n\n<tmpl_if debugMode>\n	<ul>\n	<tmpl_loop debug_loop>\n		<li><tmpl_var debug.output></li>\n	</tmpl_loop>\n	</ul>\n</tmpl_if>\n\n<table width=\"100%\">\n<tr>\n	<tmpl_loop columns_loop>\n		<td class=\"tableHeader\"><tmpl_var column.name></td>\n	</tmpl_loop>\n</tr>\n<tmpl_loop rows_loop>\n	<tr>\n		<tmpl_loop row.field_loop>\n			<td class=\"tableData\"><tmpl_var field.value></td>\n		</tmpl_loop>\n	</tr>\n</tmpl_loop>\n</table>\n\n<tmpl_if pagination.pageCount.isMultiple>\n  <div class=\"pagination\">\n    <tmpl_var pagination.previousPage>   <tmpl_var pagination.pageList.upTo20>  <tmpl_var pagination.nextPage>\n  </div>\n</tmpl_if>','SQLReport',1,1);
INSERT INTO template VALUES (1,'Default Messsage Log Display Template','<h1><tmpl_var displayTitle></h1>\r\n\r\n<table width=\"100%\" cellspacing=1 cellpadding=2 border=0>\r\n<tr>\r\n   <td class=\"tableHeader\">\r\n      <tmpl_var message.subject.label>\r\n   </td>\r\n   <td class=\"tableHeader\">\r\n      <tmpl_var message.status.label>\r\n   </td>\r\n   <td class=\"tableHeader\">\r\n      <tmpl_var message.dateOfEntry.label>\r\n   </td>\r\n</tr>\r\n<tmpl_if message.noresults>\r\n   <tr>\r\n       <td class=\"tableData\">\r\n          <tmpl_var message.noresults>\r\n       </td>\r\n       <td class=\"tableData\">\r\n          &nbsp;\r\n       </td>\r\n       <td class=\"tableData\">\r\n          &nbsp;\r\n       </td>\r\n   </tr>\r\n<tmpl_else>\r\n   <tmpl_loop message.loop>\r\n      <tr>\r\n         <td class=\"tableData\">\r\n            <tmpl_var message.subject>\r\n         </td>\r\n         <td class=\"tableData\">\r\n            <tmpl_var message.status>\r\n         </td>\r\n         <td class=\"tableData\">\r\n            <tmpl_var message.dateOfEntry>\r\n         </td>\r\n     </tr>\r\n  </tmpl_loop>\r\n</tmpl_if>\r\n</table>\r\n<tmpl_if message.multiplePages>\r\n  <div class=\"pagination\">\r\n    <tmpl_var message.previousPage>  &middot; <tmpl_var message.pageList> &middot; <tmpl_var message.nextPage>\r\n  </div>\r\n</tmpl_if>\r\n<div class=\"accountOptions\">\r\n   <ul>\r\n      <tmpl_loop message.accountOptions>\r\n         <li><tmpl_var options.display>\r\n      </tmpl_loop>\r\n   </ul>\r\n</div>','Operation/MessageLog/View',1,1);
INSERT INTO template VALUES (1,'Default MessageLog Message Template','<tmpl_var displayTitle>\r\n<b><tmpl_var message.subject></b><br>\r\n<tmpl_var message.dateOfEntry><br>\r\n<tmpl_var message.status><br><br>\r\n<tmpl_var message.text><p>\r\n\r\n<div class=\"accountOptions\">\r\n   <ul>\r\n      <tmpl_if message.takeAction>\r\n         <li><tmpl_var message.takeAction>\r\n      </tmpl_if>\r\n      <tmpl_loop message.accountOptions>\r\n         <li><tmpl_var options.display>\r\n      </tmpl_loop>\r\n   </ul>\r\n</div>\r\n\r\n\r\n','Operation/MessageLog/Message',1,1);
INSERT INTO template VALUES (1,'Default Edit Profile Template','<tmpl_var displayTitle>\r\n\r\n<tmpl_if profile.message>\r\n   <tmpl_var profile.message>\r\n</tmpl_if>\r\n\r\n<tmpl_var profile.form.header>\r\n<table >\r\n<tmpl_var profile.form.hidden>\r\n\r\n<tmpl_loop profile.form.elements>\r\n     <tr>\r\n       <td class=\"tableHeader\" valign=\"top\" colspan=\"2\">\r\n         <tmpl_var profile.form.category>\r\n       </td>\r\n     </tr>\r\n \r\n <tmpl_loop profile.form.category.loop>\r\n   <tr>\r\n    <td class=\"formDescription\" valign=\"top\">\r\n      <tmpl_var profile.form.element.label>\r\n    </td>\r\n    <td class=\"tableData\">\r\n      <tmpl_var profile.form.element>\r\n      <tmpl_if profile.form.element.subtext>\r\n        <span class=\"formSubtext\">\r\n         <tmpl_var profile.form.element.subtext>\r\n        </span>\r\n      </tmpl_if>\r\n    </td>\r\n   </tr>\r\n </tmpl_loop>\r\n</tmpl_loop>\r\n<tmpl_loop create.form.profile>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var profile.formElement.label></td>\r\n   <td class=\"tableData\"><tmpl_var profile.formElement></td>\r\n</tr>\r\n</tmpl_loop>\r\n<tr>\r\n <td class=\"formDescription\" valign=\"top\"></td>\r\n <td class=\"tableData\">\r\n     <tmpl_var profile.form.submit>\r\n </td>\r\n</tr>\r\n</table>\r\n<tmpl_var create.form.footer>\r\n\r\n<div class=\"accountOptions\">\r\n   <ul>\r\n      <tmpl_loop profile.accountOptions>\r\n         <li><tmpl_var options.display>\r\n      </tmpl_loop>\r\n   </ul>\r\n</div>','Operation/Profile/Edit',1,1);
INSERT INTO template VALUES (1,'Default Profile Display Template','<tmpl_var displayTitle>\r\n\r\n<table>\r\n  <tmpl_loop profile.elements>\r\n    <tr>\r\n    <tmpl_if profile.category>\r\n      <td colspan=\"2\" class=\"tableHeader\">\r\n        <tmpl_var profile.category>\r\n      </td>\r\n    <tmpl_else>\r\n      <td class=\"tableHeader\">\r\n         <tmpl_var profile.label>\r\n      </td>\r\n      <td class=\"tableData\">\r\n         <tmpl_var profile.value>\r\n      </td>\r\n    </tmpl_if>   \r\n    </tr>\r\n  </tmpl_loop>\r\n</table>\r\n<div class=\"accountOptions\">\r\n   <ul>\r\n      <tmpl_loop profile.accountOptions>\r\n         <li><tmpl_var options.display>\r\n      </tmpl_loop>\r\n   </ul>\r\n</div>','Operation/Profile/View',1,1);
INSERT INTO template VALUES (3,'Midas','<script language=\"JavaScript\">\r\nfunction fixChars(element) {\r\n   element.value = element.value.replace(/~V/mg,\"-\");\r\n}\r\n</script>\r\n\r\n<tmpl_if midas.supported>\r\n   <script language=\"JavaScript\">\r\n      var formObj; \r\n      var extrasDir=\"<tmpl_var session.config.extrasURL\";\r\n      function openEditWindow(obj) {\r\n         formObj = obj;\r\n         window.open(\"<tmpl_var session.config.extrasURL>/midas/editor.html\",\"editWindow\",\"width=600,height=400,resizable=1\");                    }\r\n   </script>\r\n   <tmpl_var button>\r\n</tmpl_if>\r\n\r\n<tmpl_var textarea>\r\n','richEditor',1,1);
INSERT INTO template VALUES (4,'Classic','<script language=\"JavaScript\">\r\nfunction fixChars(element) {\r\n   element.value = element.value.replace(/~V/mg,\"-\");\r\n}\r\n</script>\r\n\r\n<tmpl_if classic.supported>\r\n   <script language=\"JavaScript\">\r\n      var formObj; var extrasDir=\"<tmpl_var session.config.extrasURL>\";\r\n      function openEditWindow(obj) {\r\n         formObj = obj;\r\n         window.open(\"<tmpl_var session.config.extrasURL>/ie5edit.html\",\"editWindow\",\"width=490,height=400,resizable=1\");\r\n      }\r\n      function setContent(content) { \r\n         formObj.value = content; \r\n      } \r\n   </script>\r\n   <tmpl_var button>\r\n</tmpl_if>\r\n\r\n<tmpl_var textarea>\r\n','richEditor',1,1);
INSERT INTO template VALUES (2,'EditOnPro2','<script language=\"JavaScript\">\r\nfunction fixChars(element) {\r\n   element.value = element.value.replace(/~V/mg,\"-\");\r\n}\r\n</script>\r\n\r\n<script language=\"JavaScript\">\r\nvar formObj;\r\nfunction openEditWindow(obj) {\r\n   formObj = obj;\r\n   window.open(\"<tmpl_var session.config.extrasURL>/eopro.html\",\"editWindow\",\"width=720,height=450,resizable=1\");\r\n} \r\n</script>','richEditor',1,1);
INSERT INTO template VALUES (1,'HTMLArea','<script language=\"JavaScript\">\r\nfunction fixChars(element) {\r\n   element.value = element.value.replace(/~V/mg,\"-\");\r\n}\r\n</script>\r\n\r\n<tmpl_if htmlArea.supported>\r\n   <tmpl_if popup>\r\n      <script language=\"JavaScript\">\r\n	var formObj;\r\n        var extrasDir=\"<tmpl_var session.config.extrasURL>\";\r\n        function openEditWindow(obj) {\r\n           formObj = obj;\r\n           window.open(\"<tmpl_var session.config.extrasURL>/htmlArea/editor.html\",\"editWindow\",\"width=490,height=400,resizable=1\");\r\n        }\r\n        function setContent(content) {\r\n           formObj.value = content;\r\n        }\r\n      </script>\r\n   <tmpl_else>\r\n   <script language=\"JavaScript\" src=\"<tmpl_var session.config.extrasURL>/htmlArea/editor.js\"></script>\r\n   <script>\r\n var master = window;\n     _editor_url = \"<tmpl_var session.config.extrasURL>/htmlArea/\";\r\n   </script>      \r\n   </tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_var textarea>\r\n\r\n<tmpl_if htmlArea.supported>\r\n   <script language=\"Javascript1.2\">\r\n      editor_generate(\"<tmpl_var form.name>\");\r\n   </script>\r\n</tmpl_if>\r\n','richEditor',1,1);
INSERT INTO template VALUES (5,'lastResort','<script language=\"JavaScript\">\r\nfunction fixChars(element) {\r\n   element.value = element.value.replace(/~V/mg,\"-\");\r\n}\r\n</script>\r\n\r\n<script language=\"JavaScript\">\r\n      var formObj;\r\n      var extrasDir=\"<tmpl_var session.config.extrasURL>\";\r\n      function openEditWindow(obj) {\r\n         formObj = obj;\r\n         window.open(\"<tmpl_var session.config.extrasURL>/lastResortEdit.html\",\"editWindow\",\"width=500,height=410\");\r\n      }\r\n      function setContent(content) {\r\n         formObj.value = content;\r\n      } \r\n</script>\r\n\r\n<tmpl_var button>\r\n\r\n<tmpl_var textarea>','richEditor',1,1);
INSERT INTO template VALUES (1,'Default Overview Report','<h1><tmpl_var title></h1>\n\n<tmpl_if user.canViewReports>\n	<a href=\"<tmpl_var survey.url>\"><tmpl_var survey.label></a> \n	&bull;\n	<a href=\"<tmpl_var report.gradebook.url>\"><tmpl_var report.gradebook.label></a> \n	&bull;\n	<a href=\"<tmpl_var delete.all.responses.url>\"><tmpl_var delete.all.responses.label></a> \n	<br />\n	<a href=\"<tmpl_var export.answers.url>\"><tmpl_var export.answers.label></a> \n	&bull;\n	<a href=\"<tmpl_var export.questions.url>\"><tmpl_var export.questions.label></a> \n	&bull;\n	<a href=\"<tmpl_var export.responses.url>\"><tmpl_var export.responses.label></a> \n	&bull;\n	<a href=\"<tmpl_var export.composite.url>\"><tmpl_var export.composite.label></a> \n</tmpl_if>\n\n<br /> <br />\n\n<script>\nfunction toggleDiv(divId) {\n   if (document.getElementById(divId).style.visibility == \"none\") {\n	document.getElementById(divId).style.display = \"block\";\n   } else {\n	document.getElementById(divId).style.display = \"none\";	\n   }\n}\n</script>\n\n<tmpl_loop question_loop>\n	<b><tmpl_var question></b>\n              <tmpl_if question.isRadioList>\n                        <table class=\"tableData\">\n                        <tr class=\"tableHeader\"><td width=\"60%\"><tmpl_var answer.label></td>\n                                <td width=\"20%\"><tmpl_var response.count.label></td>\n                                <td width=\"20%\"><tmpl_var response.percent.label></td></tr>\n                        <tmpl_loop answer_loop>\n                                <tmpl_if answer.isCorrect>\n                                        <tr class=\"highlight\">\n                                <tmpl_else>\n                                        <tr>\n                                </tmpl_if>\n                                	<td><tmpl_var answer></td>\n                                	<td><tmpl_var answer.response.count></td>\n                                	<td><tmpl_var answer.response.percent></td>\n			<tmpl_if allowComment>\n                        			<td><a href=\"#\" onClick=\"toggle(\'comment<tmpl_var answer.id>\');\"><tmpl_var show.comments.label></a></td>\n			</tmpl_if>\n                               </tr>\n		<tmpl_if question.allowComment>\n			<tr id=\"comment<tmpl_var answer.id>\">\n				<td colspan=\"3\">\n					<tmpl_loop comment_loop>\n						<p>\n						<tmpl_var answer.comment>\n						</p>\n					</tmpl_loop>\n				</td>\n			</tr>\n		</tmpl_if>\n		</tmpl_loop>\n                        </table>\n               <tmpl_else>\n                        <br />\n		<a href=\"#\" onClick=\"toggle(\'response<tmpl_var question.id>\');\"><tmpl_var show.answers.label></a>\n		<br />\n		<div id=\"response<tmpl_var question.id>\">\n			<tmpl_loop answer_loop>\n				<p>\n				<tmpl_var answer.response>\n				</p>\n                			<tmpl_if question.allowComment>\n					<blockquote>\n					<tmpl_var answer.comment>\n					</blockquote>\n                			</tmpl_if>\n			</tmpl_loop>\n		</div>\n                </tmpl_if>\n	<br /><br /><br />\n\n</tmpl_loop>\n\n\n<tmpl_if pagination.pageCount.isMultiple>\n  <div class=\"pagination\">\n    <tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>\n  </div>\n</tmpl_if>\n\n','Survey/Overview',1,1);
INSERT INTO template VALUES (1,'Default Gradebook Report','<h1><tmpl_var title></h1>\n\n<tmpl_if user.canViewReports>\n	<a href=\"<tmpl_var survey.url>\"><tmpl_var survey.label></a> \n	&bull;\n	<a href=\"<tmpl_var report.overview.url>\"><tmpl_var report.overview.label></a> \n	&bull;\n	<a href=\"<tmpl_var delete.all.responses.url>\"><tmpl_var delete.all.responses.label></a> \n	<br />\n	<a href=\"<tmpl_var export.answers.url>\"><tmpl_var export.answers.label></a> \n	&bull;\n	<a href=\"<tmpl_var export.questions.url>\"><tmpl_var export.questions.label></a> \n	&bull;\n	<a href=\"<tmpl_var export.responses.url>\"><tmpl_var export.responses.label></a> \n	&bull;\n	<a href=\"<tmpl_var export.composite.url>\"><tmpl_var export.composite.label></a> \n</tmpl_if>\n\n<br /> <br />\n\n<table class=\"tableData\">\n<tr class=\"tableHeader\"><td width=\"60%\"><tmpl_var response.user.label></td>\n                <td width=\"20%\"><tmpl_var response.count.label></td>\n                <td width=\"20%\"><tmpl_var response.percent.label></td></tr>\n<tmpl_loop response_loop>\n<tr>\n	<td><a href=\"<tmpl_var response.url>\"><tmpl_var response.user.name></a></td>\n	<td><tmpl_var response.count.correct>/<tmpl_var question.count></td>\n             <td><tmpl_var response.percent>%</td>\n</tr>\n</tmpl_loop>\n</table>\n\n\n<tmpl_if pagination.pageCount.isMultiple>\n  <div class=\"pagination\">\n    <tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>\n  </div>\n</tmpl_if>\n','Survey/Gradebook',1,1);
INSERT INTO template VALUES (1,'Default Survey','<tmpl_if displayTitle>\n    <h1><tmpl_var title></h1>\n</tmpl_if>\n\n\n<tmpl_if description>\n  <tmpl_var description><p />\n</tmpl_if>\n\n\n<tmpl_if user.canTakeSurvey>\n	<tmpl_if response.isComplete>\n		<tmpl_if mode.isSurvey>\n			<tmpl_var thanks.survey.label>\n		<tmpl_else>\n			<tmpl_var thanks.quiz.label>\n			<div align=\"center\">\n				<b><tmpl_var questions.correct.count.label>:</b> <tmpl_var questions.correct.count> / <tmpl_var questions.total>\n				<br />\n				<b><tmpl_var questions.correct.percent.label>:</b><tmpl_var questions.correct.percent>% \n			</div>\n		</tmpl_if>\n		<tmpl_if user.canRespondAgain>\n			<br /> <br /> <a href=\"<tmpl_var start.newResponse.url>\"><tmpl_var start.newResponse.label></a>\n		</tmpl_if>\n	<tmpl_else>\n		<tmpl_if response.id>\n			<tmpl_var form.header>\n			<table width=\"100%\" cellpadding=\"3\" cellspacing=\"0\" border=\"0\" class=\"content\">\n				<tr>\n					<td valign=\"top\">\n					<tmpl_loop question_loop>\n						<p><tmpl_var question.question></p>\n						<tmpl_var question.answer.label><br />\n						<tmpl_var question.answer.field><br />\n						<br />\n						<tmpl_if question.allowComment>\n							<tmpl_var question.comment.label><br />\n							<tmpl_var question.comment.field><br />\n						</tmpl_if>\n					</tmpl_loop>\n					</td>\n					<td valign=\"top\" nowrap=\"1\">\n						<b><tmpl_var questions.sofar.label>:</b> <tmpl_var questions.sofar.count> / <tmpl_var questions.total> <br />\n						<tmpl_unless mode.isSurvey>\n							<b><tmpl_var questions.correct.count.label>:</b> <tmpl_var questions.correct.count> / <tmpl_var questions.sofar.count><br />\n							<b><tmpl_var questions.correct.percent.label>:</b><tmpl_var questions.correct.percent>% / 100%<br />\n						</tmpl_unless>\n					</td>\n				</tr>\n			</table>\n			<div align=\"center\"><tmpl_var form.submit></div>\n			<tmpl_var form.footer>\n		<tmpl_else>\n			<a href=\"<tmpl_var start.newResponse.url>\"><tmpl_var start.newResponse.label></a>\n		</tmpl_if>\n	</tmpl_if>\n<tmpl_else>\n	<tmpl_if mode.isSurvey>\n		<tmpl_var survey.noprivs.label>\n	<tmpl_else>\n		<tmpl_var quiz.noprivs.label>\n	</tmpl_if>\n</tmpl_if>\n<br />\n<br />\n<tmpl_if user.canViewReports>\n	<a href=\"<tmpl_var report.gradebook.url>\"><tmpl_var report.gradebook.label></a> \n	&bull;\n	<a href=\"<tmpl_var report.overview.url>\"><tmpl_var report.overview.label></a> \n	&bull;\n	<a href=\"<tmpl_var delete.all.responses.url>\"><tmpl_var delete.all.responses.label></a> \n	<br />\n	<a href=\"<tmpl_var export.answers.url>\"><tmpl_var export.answers.label></a> \n	&bull;\n	<a href=\"<tmpl_var export.questions.url>\"><tmpl_var export.questions.label></a> \n	&bull;\n	<a href=\"<tmpl_var export.responses.url>\"><tmpl_var export.responses.label></a> \n	&bull;\n	<a href=\"<tmpl_var export.composite.url>\"><tmpl_var export.composite.label></a> \n</tmpl_if>\n\n\n<tmpl_if session.var.adminOn>\n	<p>\n		<a href=\"<tmpl_var question.add.url>\"><tmpl_var question.add.label></a>\n	</p>\n	<tmpl_loop question.edit_loop>\n		<tmpl_var question.edit.controls>\n          	<tmpl_var question.edit.question>\n		<br />\n        </tmpl_loop>\n</tmpl_if>\n','Survey',1,1);
INSERT INTO template VALUES (1,'Default Response','<h1><tmpl_var title></h1>\n\n<tmpl_if user.canViewReports>\n	<a href=\"<tmpl_var survey.url>\"><tmpl_var survey.label></a> \n	&bull;\n	<a href=\"<tmpl_var report.overview.url>\"><tmpl_var report.overview.label></a> \n	&bull;\n	<a href=\"<tmpl_var report.gradebook.url>\"><tmpl_var report.gradebook.label></a> \n</tmpl_if>\n<a href=\"<tmpl_var delete.url>\"><tmpl_var delete.label></a><p/>\n<b><tmpl_var start.date.label>:</b> <tmpl_var start.date.human> <tmpl_var start.time.human><br />\n<b><tmpl_var end.date.label>:</b> <tmpl_var end.date.human> <tmpl_var end.time.human><br />\n<b><tmpl_var duration.label>:</b> <tmpl_var duration.minutes> <tmpl_var duration.minutes.label> <tmpl_var duration.seconds> <tmpl_var duration.seconds.label>\n\n<p/>\n<tmpl_loop question_loop>\n\n               <b><tmpl_var question></b><br />\n                  <table class=\"tableData\" width=\"100%\">\n<tmpl_if question.isRadioList>\n               \n    <tr><td valign=\"top\" class=\"tableHeader\" width=\"25%\">\n                               <tmpl_var answer.label></td><td width=\"75%\">\n                   <tmpl_var question.answer>                       \n</td></tr>\n        </tmpl_if>\n               <tr><td width=\"25%\" valign=\"top\" class=\"tableHeader\"><tmpl_var response.label></td>\n               \n<td width=\"75%\"><tmpl_var question.response></td></tr>\n                <tmpl_if question.comment>\n                        <tr><td valign=\"top\" class=\"tableHeader\">\n                                <tmpl_var comment.label> </td>\n                                <td><tmpl_var question.comment></td></tr>\n               </tmpl_if>\n\n       </table><p/>\n</tmpl_loop>','Survey/Response',1,1);
INSERT INTO template VALUES (4,'Tab Form','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if error_loop>\r\n	<ul>\r\n		<tmpl_loop error_loop>\r\n			<li><b><tmpl_var error.message></b>\r\n			</tmpl_loop>\r\n	</ul>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n	<tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_if canEdit>\r\n	<a href=\"<tmpl_var entryList.url>\"><tmpl_var entryList.label></a>\r\n		&middot; <a href=\"<tmpl_var export.tab.url>\"><tmpl_var export.tab.label></a>\r\n	<tmpl_if entryId>\r\n		&middot; <a href=\"<tmpl_var delete.url>\"><tmpl_var delete.label></a>\r\n	</tmpl_if>\r\n	<tmpl_if session.var.adminOn>\r\n		&middot; <a href=\"<tmpl_var addField.url>\"><tmpl_var addField.label></a>\r\n		&middot; <a href=\"<tmpl_var addTab.url>\"><tmpl_var addTab.label></a>\r\n	</tmpl_if>\r\n<p /> \r\n</tmpl_if>\r\n<tmpl_var form.start>\r\n<link href=\"/extras/tabs/tabs.css\" rel=\"stylesheet\" rev=\"stylesheet\" type=\"text/css\">\r\n<div class=\"tabs\">\r\n	<tmpl_loop tab_loop>\r\n		<span onclick=\"toggleTab(<tmpl_var tab.sequence>)\" id=\"tab<tmpl_var tab.sequence>\" class=\"tab\"><tmpl_var tab.label>\r\n		<tmpl_if session.var.adminOn>\r\n			<tmpl_if canEdit>\r\n				<tmpl_var tab.controls>\r\n			</tmpl_if>\r\n		</tmpl_if>\r\n		</span>\r\n	</tmpl_loop>\r\n</div>\r\n<tmpl_loop tab_loop>\r\n	<tmpl_var tab.start>\r\n		<table>\r\n			<tmpl_loop tab.field_loop>\r\n				<tmpl_unless tab.field.isHidden>\r\n						<tr>\r\n							<td class=\"formDescription\" valign=\"top\">\r\n								<tmpl_if session.var.adminOn>\r\n									<tmpl_if canEdit>\r\n										<tmpl_var tab.field.controls>\r\n									</tmpl_if>\r\n								</tmpl_if>\r\n								<tmpl_var tab.field.label>\r\n							</td>\r\n							<td class=\"tableData\" valign=\"top\">\r\n								<tmpl_if tab.field.isDisplayed>\r\n									<tmpl_var tab.field.value>\r\n								<tmpl_else>\r\n									<tmpl_var tab.field.form>\r\n								</tmpl_if>\r\n								<tmpl_if tab.field.isRequired>*</tmpl_if>\r\n								<span class=\"formSubtext\">\r\n									<br />\r\n									<tmpl_var tab.field.subtext>\r\n								</span>\r\n							</td>\r\n						</tr>\r\n				</tmpl_unless>\r\n			</tmpl_loop>\r\n			<tr>\r\n				<td colspan=\"2\">\r\n					<span class=\"tabSubtext\"><tmpl_var tab.subtext></span>\r\n				</td>\r\n			</tr>\r\n		</table>\r\n		<br>\r\n		<div><input type=\"submit\" value=\"save\"></div>\r\n	<tmpl_var tab.end>\r\n</tmpl_loop>\r\n<tmpl_var tab.init>\r\n<tmpl_var form.end>\r\n','DataForm',1,1);
INSERT INTO template VALUES (1,'Xmethods: getTemp','<h1><tmpl_var title></h1>\n\n<tmpl_if description>\n  <tmpl_var description><br /><br />\n</tmpl_if>\n\n\r\n<tmpl_if results>\r\n  <tmpl_loop results>\r\n    The current temp is: <tmpl_var result>\r\n  </tmpl_loop>\r\n<tmpl_else>\r\n  Failed to retrieve temp.\r\n</tmpl_if>','WSClient',1,1);
INSERT INTO template VALUES (2,'Google: doGoogleSearch','<style>\n.googleDetail {\n  font-size: 9px;\n}\n</style>\n\n<h1><tmpl_var title></h1>\n\n<tmpl_if description>\n  <tmpl_var description><br /><br />\n</tmpl_if>\n\n<form method=\"post\">\n <input type=\"hidden\" name=\"func\" value=\"view\">\n <input type=\"hidden\" name=\"wid\" value=\"<tmpl_var wobjectId>\">\n <input type=\"hidden\" name=\"targetWobjects\" value=\"doGoogleSearch\">\n <input type=\"text\" name=\"q\"><input type=\"submit\" value=\"Search\">\n</form>\n\n<tmpl_if results>\n  <tmpl_loop results>\n   <tmpl_if resultElements>\n      <p> You searched for <b><tmpl_var searchQuery></b>. We found around <tmpl_var estimatedTotalResultsCount> matching records.</p>\n   </tmpl_if>\n\n   <tmpl_loop resultElements>\n     <a href=\"<tmpl_var URL>\">\n	<tmpl_if title>\n		    <tmpl_var title>\n	<tmpl_else>\n                    <tmpl_var url>\n        </tmpl_if>\n     </a><br />\n        <tmpl_if snippet>\n            <tmpl_var snippet><br />\n        </tmpl_if>\n        <div class=\"googleDetail\">\n        <tmpl_if summary>\n            <b>Description:</b> <tmpl_var summary><br />\n        </tmpl_if>\n        <a href=\"<tmpl_var URL>\"><tmpl_var URL></a>\n     <tmpl_if cachedSize>\n           - <tmpl_var cachedSize>\n     </tmpl_if>\n     </div><br />\n    </tmpl_loop>\n  </tmpl_loop>\n<tmpl_else>\n   Could not retrieve results from Google.\n</tmpl_if>','WSClient',1,1);
INSERT INTO template VALUES (1,'Default Admin Bar','<script language=\"JavaScript\" type=\"text/javascript\">   <!--\r\n        function goContent(){\r\n                location = document.content.contentSelect.options[document.content.contentSelect.selectedIndex].value\r\n        }\r\n        function goAdmin(){\r\n                location = document.admin.adminSelect.options[document.admin.adminSelect.selectedIndex].value\r\n        }\r\n        //-->   </script>\r\n \r\n<div class=\"adminBar\">\r\n<table class=\"adminBar\" cellpadding=\"3\" cellspacing=\"0\" border=\"0\">\r\n	<tr>\r\n        		<form name=\"content\"> <td>\r\n<select name=\"contentSelect\" onChange=\"goContent()\">\r\n<option value=\"\"><tmpl_var addcontent.label></option>\r\n<option value=\"<tmpl_var addpage.url>\"><tmpl_var addpage.label></option>\r\n<optgroup label=\"<tmpl_var clipboard.label>\">	\r\n<tmpl_loop clipboard_loop>\r\n<option value=\"<tmpl_var clipboard.url>\"><tmpl_var clipboard.label></option>\r\n</tmpl_loop>\r\n</optgroup>\r\n<optgroup label=\"<tmpl_var contentTypes.label>\">	\r\n<tmpl_loop contentTypes_loop>\r\n<option value=\"<tmpl_var contentType.url>\"><tmpl_var contentType.label></option>\r\n</tmpl_loop>\r\n</optgroup>\r\n<optgroup label=\"<tmpl_var packages.label>\">	\r\n<tmpl_loop package_loop>\r\n<option value=\"<tmpl_var package.url>\"><tmpl_var package.label></option>\r\n</tmpl_loop>\r\n</optgroup>\r\n</select>\r\n		</td> </form>\r\n\r\n        		<form name=\"admin\"> <td align=\"center\">\r\n			<select name=\"adminSelect\" onChange=\"goAdmin()\">\r\n				<option value=\"\"><tmpl_var admin.label></option>\r\n				<tmpl_loop admin_loop>\r\n					<option value=\"<tmpl_var admin.url>\"><tmpl_var admin.label></option>\r\n				</tmpl_loop>\r\n			</select>\r\n		</td> </form>\r\n        	</tr>\r\n</table>\r\n</div>\r\n','Macro/AdminBar',1,1);
INSERT INTO template VALUES (2,'DHTML Admin Bar','<script language=\"JavaScript1.2\" src=\"^Extras;/coolmenus/coolmenus4.js\">\r\n/*****************************************************************************\r\nCopyright (c) 2001 Thomas Brattli (webmaster@dhtmlcentral.com)\r\n                                                                                                                                                             \r\nDHTML coolMenus - Get it at coolmenus.dhtmlcentral.com\r\nVersion 4.0_beta\r\nThis script can be used freely as long as all copyright messages are\r\nintact.\r\n                                                                                                                                                             \r\nExtra info - Coolmenus reference/help - Extra links to help files ****\r\nCSS help: http://192.168.1.31/projects/coolmenus/reference.asp?m=37\r\nGeneral: http://coolmenus.dhtmlcentral.com/reference.asp?m=35\r\nMenu properties: http://coolmenus.dhtmlcentral.com/properties.asp?m=47\r\nLevel properties: http://coolmenus.dhtmlcentral.com/properties.asp?m=48\r\nBackground bar properties: http://coolmenus.dhtmlcentral.com/properties.asp?m=49\r\nItem properties: http://coolmenus.dhtmlcentral.com/properties.asp?m=50\r\n******************************************************************************/\r\n</script>\r\n<style type=\"text/css\">\r\n                                                                                                                                                          \r\n.adminBarTop,.adminBarTopOver,.adminBarSub,.adminBarSubOver{position:absolute; overflow:hidden; cursor:pointer; cursor:hand}\r\n.adminBarTop,.adminBarTopOver{padding:4px; font-size:12px; font-weight:bold}\r\n.adminBarTop{color:white; border: 1px solid #aaaaaa; }\r\n.adminBarTopOver,.adminBarSubOver{color:#EC4300;}\r\n.adminBarSub,.adminBarSubOver{padding:2px; font-size:11px; font-weight:bold}\r\n.adminBarSub{color: white; background-color: #666666; layer-background-color: #666666;}\r\n.adminBarSubOver,.adminBarSubOver,.adminBarBorder,.adminBarBkg{layer-background-color: black; background-color: black;}\r\n.adminBarBorder{position:absolute; visibility:hidden; z-index:300}\r\n.adminBarBkg{position:absolute; width:10; height:10; visibility:hidden; }\r\n</style>\r\n\r\n<script language=\"JavaScript1.2\">\r\nadminBar=new makeCM(\"adminBar\"); \r\n\r\n//menu properties\r\nadminBar.resizeCheck=1; \r\nadminBar.rows=1;  \r\nadminBar.onlineRoot=\"\"; \r\nadminBar.pxBetween =0;\r\nadminBar.fillImg=\"\"; \r\nadminBar.fromTop=0; \r\nadminBar.fromLeft=30; \r\nadminBar.wait=600; \r\nadminBar.zIndex=10000;\r\nadminBar.menuPlacement=\"left\";\r\n\r\n//background bar properties\r\nadminBar.useBar=1; \r\nadminBar.barWidth=\"\"; \r\nadminBar.barHeight=\"menu\"; \r\nadminBar.barX=0;\r\nadminBar.barY=\"menu\"; \r\nadminBar.barClass=\"adminBarBkg\";\r\nadminBar.barBorderX=0; \r\nadminBar.barBorderY=0;\r\n\r\nadminBar.level[0]=new cm_makeLevel(160,20,\"adminBarTop\",\"adminBarTopOver\",1,1,\"adminBarBorder\",0,\"bottom\",0,0,0,0,0);\r\nadminBar.level[1]=new cm_makeLevel(160,18,\"adminBarSub\",\"adminBarSubOver\",1,1,\"adminBarBorder\",0,\"right\",0,5,\"menu_arrow.gif\",10,10);\r\n\r\n\r\nadminBar.makeMenu(\'addcontent\',\'\',\'<tmpl_var addcontent.label>\',\'\');\r\n\r\n\r\nadminBar.makeMenu(\'clipboard\',\'addcontent\',\'<tmpl_var clipboard.label> &raquo;\',\'\');\r\n<tmpl_loop clipboard_loop> \r\n	adminBar.makeMenu(\'clipboard<tmpl_var clipboard.count>\',\'clipboard\',\'<tmpl_var clipboard.label>\',\'<tmpl_var clipboard.url>\');\r\n</tmpl_loop>\r\n\r\n\r\nadminBar.makeMenu(\'contentTypes\',\'addcontent\',\'<tmpl_var contentTypes.label> &raquo;\',\'\');\r\n<tmpl_loop contentTypes_loop> \r\n	adminBar.makeMenu(\'contentTypes<tmpl_var contentType.count>\',\'contentTypes\',\'<tmpl_var contentType.label>\',\'<tmpl_var contentType.url>\');\r\n</tmpl_loop>\r\n\r\n<tmpl_if packages.canAdd>\r\nadminBar.makeMenu(\'packages\',\'addcontent\',\'<tmpl_var packages.label> &raquo;\',\'\');\r\n<tmpl_loop package_loop> \r\n	adminBar.makeMenu(\'package<tmpl_var package.count>\',\'packages\',\'<tmpl_var package.label>\',\'<tmpl_var package.url>\');\r\n</tmpl_loop>\r\n</tmpl_if>\r\n\r\nadminBar.makeMenu(\'page\',\'addcontent\',\'<tmpl_var addpage.label>\',\'<tmpl_var addpage.url>\');\r\n\r\nadminBar.makeMenu(\'admin\',\'\',\'<tmpl_var admin.label>\',\'\');\r\n<tmpl_loop admin_loop> \r\n	adminBar.makeMenu(\'admin<tmpl_var admin.count>\',\'admin\',\'<tmpl_var admin.label>\',\'<tmpl_var admin.url>\');\r\n</tmpl_loop>\r\n \r\nadminBar.construct()\r\n</script>\r\n','Macro/AdminBar',1,1);
INSERT INTO template VALUES (2,'crumbTrail','<tmpl_if session.var.adminOn>\r\n<tmpl_var config.button>\r\n</tmpl_if>\r\n<span class=\"crumbTrail\">\r\n<tmpl_loop page_loop>\r\n<a class=\"crumbTrail\" \r\n   <tmpl_if page.newWindow>target=\"_blank\"</tmpl_if>\r\n   href=\"<tmpl_var page.url>\"><tmpl_var page.menuTitle></a>\r\n   <tmpl_unless \"__last__\"> &gt; </tmpl_unless>\r\n</tmpl_loop>\r\n</span>','Navigation',1,1);
INSERT INTO template VALUES (1,'verticalMenu','<tmpl_if session.var.adminOn>\r\n<tmpl_var config.button><br>\r\n</tmpl_if>\r\n<span class=\"verticalMenu\">\r\n<tmpl_loop page_loop>\r\n<tmpl_var page.indent><a class=\"verticalMenu\" \r\n   <tmpl_if page.newWindow>target=\"_blank\"</tmpl_if> href=\"<tmpl_var page.url>\">\r\n   <tmpl_if page.isCurrent>\r\n      <span class=\"selectedMenuItem\"><tmpl_var page.menuTitle></span>\r\n   <tmpl_else><tmpl_var page.menuTitle></tmpl_if></a><br>\r\n</tmpl_loop>\r\n</span>','Navigation',1,1);
INSERT INTO template VALUES (3,'horizontalMenu','<tmpl_if session.var.adminOn>\r\n<tmpl_var config.button>\r\n</tmpl_if>\r\n<span class=\"horizontalMenu\">\r\n<tmpl_loop page_loop>\r\n<a class=\"horizontalMenu\" \r\n   <tmpl_if page.newWindow>target=\"_blank\"</tmpl_if>\r\n   href=\"<tmpl_var page.url>\"><tmpl_var page.menuTitle></a>\r\n   <tmpl_unless \"__last__\"> &middot; </tmpl_unless>\r\n</tmpl_loop>\r\n</span>','Navigation',1,1);
INSERT INTO template VALUES (4,'DropMenu','<script language=\"JavaScript\" type=\"text/javascript\">\r\nfunction go(formObj){\r\n   if (formObj.chooser.options[formObj.chooser.selectedIndex].value != \"none\") {\r\n	location = formObj.chooser.options[formObj.chooser.selectedIndex].value\r\n   }\r\n}\r\n</script>\r\n<form>\r\n<tmpl_if session.var.adminOn>\r\n<tmpl_var config.button>\r\n</tmpl_if>\r\n<select name=\"chooser\" size=1 onChange=\"go(this.form)\">\r\n<option value=none>Where do you want to go?</option>\r\n<tmpl_loop page_loop>\r\n<option value=\"<tmpl_var page.url>\"><tmpl_loop page.indent_loop>&nbsp;&nbsp;</tmpl_loop>- <tmpl_var page.menuTitle></option>\r\n</tmpl_loop>\r\n</select>\r\n</form>','Navigation',1,1);
INSERT INTO template VALUES (5,'Tabs','<tmpl_if session.var.adminOn>\r\n<tmpl_var config.button>\r\n</tmpl_if>\r\n<tmpl_loop page_loop>\r\n   <tmpl_if page.isCurrent>\r\n      <span class=\"rootTabOn\">\r\n   <tmpl_else>\r\n      <span class=\"rootTabOff\">\r\n   </tmpl_if>\r\n   <a <tmpl_if page.newWindow>target=\"_blank\"</tmpl_if> href=\"<tmpl_var page.url>\"><tmpl_var page.menuTitle></a>\r\n   </span>\r\n</tmpl_loop>','Navigation',1,1);
INSERT INTO template VALUES (6,'dtree','<link rel=\"StyleSheet\" href=\"<tmpl_var session.config.extrasURL>/Navigation/dtree/dtree.css\" type=\"text/css\" />\r\n<script type=\"text/javascript\" src=\"<tmpl_var session.config.extrasURL>/Navigation/dtree/dtree.js\"></script>\r\n\r\n<tmpl_if session.var.adminOn>\r\n<tmpl_var config.button>\r\n</tmpl_if>\r\n\r\n<script>\r\n// Path to dtree directory\r\n_dtree_url = \"<tmpl_var session.config.extrasURL>/Navigation/dtree/\";\r\n</script>\r\n\r\n<div class=\"dtree\">\r\n<script type=\"text/javascript\">\r\n<!--\r\n	d = new dTree(\'d\');\r\n	<tmpl_loop page_loop>\r\n	d.add(\r\n		<tmpl_var page.pageId>,\r\n		<tmpl_if __first__>-99<tmpl_else><tmpl_var page.parentId></tmpl_if>,\r\n		\'<tmpl_var page.menuTitle>\',\r\n		\'<tmpl_var page.url>\',\r\n		\'<tmpl_var page.synopsis>\'\r\n		<tmpl_if page.newWindow>,\'_blank\'</tmpl_if>\r\n	);\r\n	</tmpl_loop>\r\n	document.write(d);\r\n//-->\r\n</script>\r\n\r\n</div>','Navigation',1,1);
INSERT INTO template VALUES (1,'Calendar Month (Big)','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_if session.var.adminOn>\r\n    <a href=\"<tmpl_var addevent.url>\"><tmpl_var addevent.label></a>\r\n    <p />\r\n</tmpl_if>\r\n\r\n<tmpl_loop month_loop>\n	<table border=\"1\" width=\"100%\">\n	<tr><td colspan=7 class=\"tableHeader\"><h2 align=\"center\"><tmpl_var month> <tmpl_var year></h2></td></tr>\n	<tr>\n	<tmpl_if session.user.firstDayOfWeek>\n		<th class=\"tableData\"><tmpl_var monday.label></th>\n		<th class=\"tableData\"><tmpl_var tuesday.label></th>\n		<th class=\"tableData\"><tmpl_var wednesday.label></th>\n		<th class=\"tableData\"><tmpl_var thursday.label></th>\n		<th class=\"tableData\"><tmpl_var friday.label></th>\n		<th class=\"tableData\"><tmpl_var saturday.label></th>\n		<th class=\"tableData\"><tmpl_var sunday.label></th>\n	<tmpl_else>\n		<th class=\"tableData\"><tmpl_var sunday.label></th>\n		<th class=\"tableData\"><tmpl_var monday.label></th>\n		<th class=\"tableData\"><tmpl_var tuesday.label></th>\n		<th class=\"tableData\"><tmpl_var wednesday.label></th>\n		<th class=\"tableData\"><tmpl_var thursday.label></th>\n		<th class=\"tableData\"><tmpl_var friday.label></th>\n		<th class=\"tableData\"><tmpl_var saturday.label></th>\n	</tmpl_if>\n	</tr><tr>\n	<tmpl_loop prepad_loop>\n		<td>&nbsp;</td>\n	</tmpl_loop>\n 	<tmpl_loop day_loop>\n		<tmpl_if isStartOfWeek>\n			<tr>\n		</tmpl_if>\n		<td class=\"table<tmpl_if isToday>Header<tmpl_else>Data</tmpl_if>\" width=\"14%\" valign=\"top\" align=\"left\"><p><b><tmpl_var day></b></p>\n		<tmpl_loop event_loop>\n			<tmpl_if name>\n				&middot;<a href=\"<tmpl_var url>\"><tmpl_var name></a><br />\n			</tmpl_if>\n		</tmpl_loop>\n		</td>\n		<tmpl_if isEndOfWeek>\n			</tr>\n		</tmpl_if>\n	</tmpl_loop>\n	<tmpl_loop postpad_loop>\n		<td>&nbsp;</td>\n	</tmpl_loop>\n	</tr>\n	</table>\n</tmpl_loop>\n\n\n<tmpl_if pagination.pageCount.isMultiple>\n  <div class=\"pagination\">\n    <tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>\n  </div>\n</tmpl_if>\n','EventsCalendar',1,1);
INSERT INTO template VALUES (7,'Cool Menus','<tmpl_if session.var.adminOn>\r\n<tmpl_var config.button>\r\n</tmpl_if>\r\n\r\n<style>\r\n/* CoolMenus 4 - default styles - do not edit */\r\n.cCMAbs{position:absolute; visibility:hidden; left:0; top:0}\r\n/* CoolMenus 4 - default styles - end */\r\n\r\n/*Styles for level 0*/\r\n.cLevel0,.cLevel0over{position:absolute; padding:2px; font-family:tahoma,arial,helvetica; font-size:12px; font-weight:bold;\r\n\r\n}\r\n.cLevel0{background-color:navy; layer-background-color:navy; color:white;\r\ntext-align: center;\r\n}\r\n.cLevel0over{background-color:navy; layer-background-color:navy; color:white; cursor:pointer; cursor:hand; \r\ntext-align: center; \r\n}\r\n\r\n.cLevel0border{position:absolute; visibility:hidden; background-color:#569635; layer-background-color:#006699; \r\n \r\n}\r\n\r\n\r\n/*Styles for level 1*/\r\n.cLevel1, .cLevel1over{position:absolute; padding:2px; font-family:tahoma, arial,helvetica; font-size:11px; font-weight:bold}\r\n.cLevel1{background-color:Navy; layer-background-color:Navy; color:white;}\r\n.cLevel1over{background-color:#336699; layer-background-color:#336699; color:Yellow; cursor:pointer; cursor:hand; }\r\n.cLevel1border{position:absolute; visibility:hidden; background-color:#006699; layer-background-color:#006699}\r\n\r\n/*Styles for level 2*/\r\n.cLevel2, .cLevel2over{position:absolute; padding:2px; font-family:tahoma,arial,helvetica; font-size:10px; font-weight:bold}\r\n.cLevel2{background-color:Navy; layer-background-color:Navy; color:white;}\r\n.cLevel2over{background-color:#0099cc; layer-background-color:#0099cc; color:Yellow; cursor:pointer; cursor:hand; }\r\n.cLevel2border{position:absolute; visibility:hidden; background-color:#006699; layer-background-color:#006699}\r\n\r\n</style>\r\n\r\n  \r\n\r\n<script language=\"JavaScript1.2\" src=\"<tmpl_var session.config.extrasURL>/coolmenus/coolmenus4.js\">\r\n/*****************************************************************************\r\nCopyright (c) 2001 Thomas Brattli (webmaster@dhtmlcentral.com)\r\n\r\nDHTML coolMenus - Get it at coolmenus.dhtmlcentral.com\r\nVersion 4.0_beta\r\nThis script can be used freely as long as all copyright messages are\r\nintact.\r\n\r\nExtra info - Coolmenus reference/help - Extra links to help files **** \r\nCSS help: http://coolmenus.dhtmlcentral.com/projects/coolmenus/reference.asp?m=37\r\nGeneral: http://coolmenus.dhtmlcentral.com/reference.asp?m=35\r\nMenu properties: http://coolmenus.dhtmlcentral.com/properties.asp?m=47\r\nLevel properties: http://coolmenus.dhtmlcentral.com/properties.asp?m=48\r\n\r\nBackground bar properties: http://coolmenus.dhtmlcentral.com/properties.asp?m=49\r\nItem properties: http://coolmenus.dhtmlcentral.com/properties.asp?m=50\r\n******************************************************************************/\r\n</script>\r\n\r\n\r\n<script language=\"JavaScript\">\r\n\r\n/*** \r\nThis is the menu creation code - place it right after you body tag\r\nFeel free to add this to a stand-alone js file and link it to your page.\r\n**/\r\n\r\n//Menu object creation\r\ncoolmenu=new makeCM(\"coolmenu\") //Making the menu object. Argument: menuname\r\n\r\ncoolmenu.frames = 0\r\n\r\n//Menu properties   \r\ncoolmenu.pxBetween=2\r\ncoolmenu.fromLeft=200 \r\ncoolmenu.fromTop=100   \r\ncoolmenu.rows=1\r\ncoolmenu.menuPlacement=\"center\"   //The whole menu alignment, left, center, or right\r\n                                                             \r\ncoolmenu.resizeCheck=1 \r\ncoolmenu.wait=1000 \r\ncoolmenu.fillImg=\"cm_fill.gif\"\r\ncoolmenu.zIndex=100\r\n\r\n//Background bar properties\r\ncoolmenu.useBar=0\r\ncoolmenu.barWidth=\"100%\"\r\ncoolmenu.barHeight=\"menu\" \r\ncoolmenu.barClass=\"cBar\"\r\ncoolmenu.barX=0 \r\ncoolmenu.barY=0\r\ncoolmenu.barBorderX=0\r\ncoolmenu.barBorderY=0\r\ncoolmenu.barBorderClass=\"\"\r\n\r\n//Level properties - ALL properties have to be spesified in level 0\r\ncoolmenu.level[0]=new cm_makeLevel() //Add this for each new level\r\ncoolmenu.level[0].width=110\r\ncoolmenu.level[0].height=21 \r\ncoolmenu.level[0].regClass=\"cLevel0\"\r\ncoolmenu.level[0].overClass=\"cLevel0over\"\r\ncoolmenu.level[0].borderX=1\r\ncoolmenu.level[0].borderY=1\r\ncoolmenu.level[0].borderClass=\"cLevel0border\"\r\ncoolmenu.level[0].offsetX=0\r\ncoolmenu.level[0].offsetY=0\r\ncoolmenu.level[0].rows=0\r\ncoolmenu.level[0].arrow=0\r\ncoolmenu.level[0].arrowWidth=0\r\ncoolmenu.level[0].arrowHeight=0\r\ncoolmenu.level[0].align=\"bottom\"\r\n\r\n//EXAMPLE SUB LEVEL[1] PROPERTIES - You have to specify the properties you want different from LEVEL[0] - If you want all items to look the same just remove this\r\ncoolmenu.level[1]=new cm_makeLevel() //Add this for each new level (adding one to the number)\r\ncoolmenu.level[1].width=coolmenu.level[0].width+20\r\ncoolmenu.level[1].height=25\r\ncoolmenu.level[1].regClass=\"cLevel1\"\r\ncoolmenu.level[1].overClass=\"cLevel1over\"\r\ncoolmenu.level[1].borderX=1\r\ncoolmenu.level[1].borderY=1\r\ncoolmenu.level[1].align=\"right\" \r\ncoolmenu.level[1].offsetX=0\r\ncoolmenu.level[1].offsetY=0\r\ncoolmenu.level[1].borderClass=\"cLevel1border\"\r\n\r\n\r\n//EXAMPLE SUB LEVEL[2] PROPERTIES - You have to spesify the properties you want different from LEVEL[1] OR LEVEL[0] - If you want all items to look the same just remove this\r\ncoolmenu.level[2]=new cm_makeLevel() //Add this for each new level (adding one to the number)\r\ncoolmenu.level[2].width=coolmenu.level[0].width+20\r\ncoolmenu.level[2].height=25\r\ncoolmenu.level[2].offsetX=0\r\ncoolmenu.level[2].offsetY=0\r\ncoolmenu.level[2].regClass=\"cLevel2\"\r\ncoolmenu.level[2].overClass=\"cLevel2over\"\r\ncoolmenu.level[2].borderClass=\"cLevel2border\"\r\n\r\n//EXAMPLE SUB LEVEL[2] PROPERTIES - You have to spesify the properties you want different from LEVEL[1] OR LEVEL[0] - If you want all items to look the same just remove this\r\ncoolmenu.level[3]=new cm_makeLevel() //Add this for each new level (adding one to the number)\r\ncoolmenu.level[3].width=coolmenu.level[0].width+20\r\ncoolmenu.level[3].height=25\r\ncoolmenu.level[3].offsetX=0\r\ncoolmenu.level[3].offsetY=0\r\ncoolmenu.level[3].regClass=\"cLevel2\"\r\ncoolmenu.level[3].overClass=\"cLevel2over\"\r\ncoolmenu.level[3].borderClass=\"cLevel2border\"\r\n\r\n\r\n\r\n<tmpl_loop page_loop>\r\ncoolmenu.makeMenu(\'coolmenu_<tmpl_var page.urlizedTitle>\',\'coolmenu_<tmpl_var page.mother.urlizedTitle>\',\'<tmpl_var page.menuTitle>\',\'<tmpl_var page.url>\'<tmpl_if page.newWindow>,\'_blank\'</tmpl_if>);\r\n</tmpl_loop>\r\n\r\n\r\ncoolmenu.construct();\r\n\r\n</script>','Navigation',1,1);
INSERT INTO template VALUES (2,'Advanced Search','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<table class=\"tableMenu\" width=\"100%\">\r\n  <tbody>\r\n    <tr>\r\n      <form method=\"post\" encType=\"multipart/form-data\">\r\n<input type=\"hidden\" name=\"func\" value=\"view\">\r\n<input type=\"hidden\" name=\"wid\" value=\"<tmpl_var wid>\">\r\n<td vAlign=\"top\" align=\"middle\">\r\n  <table>\r\n    <tbody>\r\n      <tr>\r\n<td class=\"tableData\"><b>Search for:</b></td>\r\n<td class=\"tableData\"><input maxLength=\"255\" size=\"25\" value=\'<tmpl_var query>\' name=\"query\"></td>\r\n<td class=\"tableData\">in</td>\r\n<td class=\"tableData\">\r\n   <select size=\"1\" name=\"namespaces\">\r\n   <tmpl_loop namespaces>\r\n      <option value=\"<tmpl_var value>\" <tmpl_if selected>selected</tmpl_if>><tmpl_var name></option>\r\n   </tmpl_loop>\r\n   </select>\r\n \r\n     </td>\r\n      </tr>\r\n      <tr>\r\n	<td class=\"tableData\" valign=top><b>Content in language:</b></td>\r\n	<td class=\"tableData\" valign=top>\r\n	   <tmpl_loop languages>\r\n		<input type=\"checkbox\" name=\"languages\" value=\"<tmpl_var value>\" \r\n			<tmpl_if selected>checked=\"1\"</tmpl_if> ><tmpl_var name><br>\r\n	   </tmpl_loop>\r\n	</td>\r\n          <td class=\"tableData\" valign=top><b>Created by:</b></td>\r\n          <td class=\"tableData\" valign=top>\r\n	   <select size=\"1\" name=\"users\">\r\n	   <tmpl_loop users>\r\n	      <option value=\"<tmpl_var value>\" <tmpl_if selected>selected</tmpl_if>><tmpl_var name></option>\r\n	   </tmpl_loop>\r\n	   </select>\r\n	 </td>\r\n     </td>\r\n      </tr>\r\n      <tr>\r\n          <td class=\"tableData\"><b>Type of content:</b></td>\r\n          <td class=\"tableData\">\r\n	   <select size=\"1\" name=\"contentTypes\">\r\n	   <tmpl_loop contentTypes>\r\n      <option value=\"<tmpl_var value>\" <tmpl_if selected>selected</tmpl_if>><tmpl_var name></option>\r\n   </tmpl_loop>\r\n   </select>\r\n   </td>\r\n<td class=\"tableData\"><b>Number of Results:</b></td>\r\n<td class=\"tableData\">\r\n	<select size=\"1\" name=\"paginateAfter\">\r\n	<option <tmpl_var select_10> >10</option>\r\n	<option <tmpl_var select_25> >25</option>\r\n	<option <tmpl_var select_50> >50</option>\r\n	<option <tmpl_var select_100 >>100</option>\r\n	</select>\r\n</td>\r\n      </tr>\r\n      <tr>\r\n	<td class=\"tableData\"></td>\r\n	<td class=\"tableData\"></td>\r\n<td class=\"tableData\"></td>\r\n<td class=\"tableData\"><input onclick=\"this.value=\'Please wait...\'\" type=\"submit\" value=\"search\"></td>\r\n      </tr>\r\n\r\n    </tbody>\r\n  </table>\r\n</td>\r\n<td></td>\r\n      </form>\r\n    </tr>\r\n  </tbody>\r\n</table>\r\n\r\n<p/>\r\n<tmpl_if numberOfResults>\r\n   <p>Results <tmpl_var startNr> - <tmpl_var endNr> of about <tmpl_var numberOfResults> \r\n   containing <b>\"<tmpl_var queryHighlighted>\"</b>. Search took <b><tmpl_var duration></b> seconds.</p>\r\n</tmpl_if>\r\n<ol style=\"Margin-Top: 0px; Margin-Bottom: 0px;\" start=\"<tmpl_var startNr>\">\r\n\r\n<tmpl_loop resultsLoop>\r\n   <li>\r\n	<a href=\"<tmpl_var location>\">\r\n	   <tmpl_if header><tmpl_var header><tmpl_else>No Title</tmpl_if></a>\r\n	<tmpl_if username>\r\n	   by <a href=\"<tmpl_var userProfile>\"><tmpl_var username></a>\r\n	</tmpl_if>\r\n	<div>\r\n	   <tmpl_if \"body\">\r\n		<span class=\"preview\"><tmpl_var \"body\"></span><br/>\r\n	   </tmpl_if>\r\n	   <span style=\"color:#666666;\"><tmpl_var location></span>\r\n	   <br/>\r\n	   <br/>\r\n	</div>\r\n   </li>\r\n</tmpl_loop>\r\n\r\n</ol>\r\n\n\n\n<tmpl_if pagination.pageCount.isMultiple>\n  <div class=\"pagination\">\n    <tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>\n  </div>\n</tmpl_if>\n','IndexedSearch',1,1);
INSERT INTO template VALUES (3,'Search in Help','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<table class=\"tableMenu\" width=\"100%\">\r\n  <tbody>\r\n    <tr>\r\n      <td align=\"center\" width=\"15%\">\r\n      <h1><tmpl_var int.search></h1>\r\n      </td>\r\n      <td vAlign=\"top\" align=\"middle\">\r\n      <table>\r\n      <form method=\"post\">\r\n      <input type=\"hidden\" name=\"contentTypes\" value=\"help\">\r\n      <input type=\"hidden\" name=\"func\" value=\"view\">\r\n      <input type=\"hidden\" name=\"wid\" value=\"<tmpl_var wid>\">\r\n      <tbody>\r\n      <tr>\r\n	<td align=center class=\"tableData\">\r\n	   <input maxLength=\"255\" size=\"30\" value=\'<tmpl_var query>\' name=\"query\">\r\n	</td>\r\n	<td class=\"tableData\"><tmpl_var submit></td>\r\n      </tr>\r\n      <tr>\r\n	<td align=center class=\"tableData\" valign=\"top\"><b>In namespace: </b>\r\n	   <select size=\"1\" name=\"namespaces\">\r\n	   <tmpl_loop namespaces>\r\n		<option value=\"<tmpl_var value>\" <tmpl_if selected>selected</tmpl_if>><tmpl_var name></option>\r\n	   </tmpl_loop>\r\n	   </select>\r\n	</td>\r\n      </tbody>\r\n      </table>\r\n      </td>\r\n      </form>\r\n    </tr>\r\n  </tbody>\r\n</table>\r\n\r\n<p/>\r\n<tmpl_if numberOfResults>\r\n   <p>Results <tmpl_var startNr> - <tmpl_var endNr> of about <tmpl_var numberOfResults> \r\n   containing <b>\"<tmpl_var queryHighlighted>\"</b>. Search took <b><tmpl_var duration></b> seconds.</p>\r\n</tmpl_if>\r\n<ol style=\"Margin-Top: 0px; Margin-Bottom: 0px;\" start=\"<tmpl_var startNr>\">\r\n\r\n<tmpl_loop resultsLoop>\r\n   <li>\r\n	<a href=\"<tmpl_var location>\">\r\n	   <tmpl_if header><tmpl_var header><tmpl_else>No Title</tmpl_if></a>\r\n	<div>\r\n	   <tmpl_if \"body\">\r\n		<span class=\"preview\"><tmpl_var \"body\"></span><br/>\r\n	   </tmpl_if>\r\n	   <span style=\"color:#666666;\">Namespace: <tmpl_var namespace></span>\r\n	   <br/>\r\n	   <br/>\r\n	</div>\r\n   </li>\r\n</tmpl_loop>\r\n\r\n</ol>\r\n\n\n\n<tmpl_if pagination.pageCount.isMultiple>\n  <div class=\"pagination\">\n    <tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>\n  </div>\n</tmpl_if>\n','IndexedSearch',1,1);
INSERT INTO template VALUES (1,'Default Search','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<table class=\"tableMenu\" width=\"100%\">\r\n  <tbody>\r\n    <tr>\r\n      <td align=\"center\" width=\"15%\">\r\n      <h1><tmpl_var int.search></h1>\r\n      </td>\r\n      <td vAlign=\"top\" align=\"middle\">\r\n      <table>\r\n      <form method=\"post\">\r\n      <input type=\"hidden\" name=\"func\" value=\"view\">\r\n      <input type=\"hidden\" name=\"wid\" value=\"<tmpl_var wid>\">\r\n      <tbody>\r\n      <tr>\r\n	<td colspan=\"2\" class=\"tableData\">\r\n	   <input maxLength=\"255\" size=\"30\" value=\'<tmpl_var query>\' name=\"query\">\r\n	</td>\r\n	<td class=\"tableData\"><tmpl_var submit></td>\r\n      </tr>\r\n      <tr>\r\n	<td class=\"tableData\" valign=\"top\">\r\n  	   <tmpl_loop languages>\r\n	     <input type=\"radio\" name=\"languages\" value=\"<tmpl_var value>\" \r\n	     <tmpl_if __FIRST__>\r\n		<tmpl_if query>\r\n		   <tmpl_if selected>\r\n			checked=\"1\"\r\n		   </tmpl_if>\r\n		<tmpl_else>\r\n		   checked=\"1\"\r\n	        </tmpl_if>\r\n             <tmpl_else>\r\n	     	<tmpl_if selected>checked=\"1\"</tmpl_if>\r\n	     </tmpl_if>\r\n	     ><tmpl_var name>\r\n	     <br>\r\n	   </tmpl_loop>\r\n	</td>\r\n	<td class=\"tableData\" valign=\"top\">\r\n	   <tmpl_loop contentTypesSimple>\r\n	     <tmpl_unless __FIRST__>\r\n	     	<input type=\"checkbox\" name=\"contentTypes\" value=\"<tmpl_var value>\"\r\n		<tmpl_if type_content>\r\n		   <tmpl_if query>\r\n			<tmpl_if selected>\r\n			   checked=\"1\"\r\n			</tmpl_if>\r\n		   <tmpl_else>\r\n			checked=\"1\"\r\n		   </tmpl_if>\r\n		<tmpl_else>\r\n		   <tmpl_if selected>checked=\"1\"</tmpl_if>\r\n		</tmpl_if>\r\n		><tmpl_var name>\r\n                <br>\r\n	     </tmpl_unless>\r\n	   </tmpl_loop>\r\n	</td>\r\n        <td></td>\r\n      </tbody>\r\n      </form>\r\n      </table>\r\n      </td>      \r\n    </tr>\r\n  </tbody>\r\n</table>\r\n\r\n<p/>\r\n<tmpl_if numberOfResults>\r\n   <p>Results <tmpl_var startNr> - <tmpl_var endNr> of about <tmpl_var numberOfResults> \r\n   containing <b>\"<tmpl_var queryHighlighted>\"</b>. Search took <b><tmpl_var duration></b> seconds.</p>\r\n   <ol style=\"Margin-Top: 0px; Margin-Bottom: 0px;\" start=\"<tmpl_var startNr>\">\r\n   <tmpl_loop resultsLoop>\r\n      <li>\r\n	   <a href=\"<tmpl_var location>\">\r\n	      <tmpl_if header><tmpl_var header><tmpl_else>No Title</tmpl_if></a>\r\n	   <div>\r\n	      <tmpl_if \"body\">\r\n		   <span class=\"preview\"><tmpl_var \"body\"></span><br/>\r\n	      </tmpl_if>\r\n	      <span style=\"color:#666666;\">Location: <tmpl_var crumbTrail></span>\r\n	      <br/>\r\n	      <br/>\r\n	   </div>\r\n      </li>\r\n   </tmpl_loop>\r\n   </ol>\r\n</tmpl_if> \n\n\n<tmpl_if pagination.pageCount.isMultiple>\n  <div class=\"pagination\">\n    <tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>\n  </div>\n</tmpl_if>\n','IndexedSearch',1,1);
INSERT INTO template VALUES (14,'Job Listing','<tmpl_if displayTitle>\n    <h1><tmpl_var title></h1>\n</tmpl_if>\n\n<tmpl_if description>\n    <tmpl_var description><p />\n</tmpl_if>\n\n<tmpl_if session.scratch.search>\n <tmpl_var search.form>\n</tmpl_if>\n\n<table width=\"100%\" cellpadding=2 cellspacing=1 border=0><tr>\n<td align=\"right\" class=\"tableMenu\">\n\n<tmpl_if canPost>\n   <a href=\"<tmpl_var post.url>\">Add a job.</a> &middot;\n</tmpl_if>\n\n<a href=\"<tmpl_var search.url>\"><tmpl_var search.label></a>\n\n</td></tr></table>\n\n<table width=\"100%\" cellspacing=1 cellpadding=2 border=0>\n<tr>\n<td class=\"tableHeader\">Job Title</td>\n<td class=\"tableHeader\">Location</td>\n<td class=\"tableHeader\">Compensation</td>\n<td class=\"tableHeader\">Date Posted</td>\n</tr>\n\n<tmpl_loop submissions_loop>\n\n<tr>\n<td class=\"tableData\">\n     <a href=\"<tmpl_var submission.URL>\">  <tmpl_var submission.title>\n</td>\n<td class=\"tableData\"><tmpl_var submission.userDefined2></td>\n<td class=\"tableData\"><tmpl_var submission.userDefined1></td>\n<td class=\"tableData\"><tmpl_var submission.date></td>\n</tr>\n\n</tmpl_loop>\n\n</table>\n\n<tmpl_if pagination.pageCount.isMultiple>\n  <div class=\"pagination\">\n    <tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>\n  </div>\n</tmpl_if>\n','USS',1,1);
INSERT INTO template VALUES (2,'Job','<h1><tmpl_var title></h1>\n\n<tmpl_if content>\n<p>\n<b>Job Description</b><br />\n<tmpl_var content>\n</p>\n</tmpl_if>\n\n<tmpl_if userDefined3.value>\n<p>\n<b>Job Requirements</b><br />\n<tmpl_var userDefined3.value>\n</p>\n</tmpl_if>\n\n<table>\n<tr>\n  <td class=\"tableHeader\">Date Posted</td>\n  <td class=\"tableData\"><tmpl_var date.human></td>\n</tr>\n<tr>\n  <td  class=\"tableHeader\">Location</td>\n  <td class=\"tableData\"><tmpl_var userDefined2.value></td>\n</tr>\n<tr>\n  <td  class=\"tableHeader\">Compensation</td>\n  <td class=\"tableData\"><tmpl_var userDefined1.value></td>\n</tr>\n<tr>\n  <td  class=\"tableHeader\">Views</td>\n  <td class=\"tableData\"><tmpl_var views.count></td>\n</tr>\n</table>\n\n<p>\n<tmpl_if previous.more>\n   <a href=\"<tmpl_var previous.url>\">&laquo; Previous Job</a> &middot;\n</tmpl_if>\n<a href=\"<tmpl_var back.url>\">List All Jobs</a>\n<tmpl_if next.more>\n   &middot; <a href=\"<tmpl_var next.url>\">Next Job &raquo;</a>\n</tmpl_if>\n</p>\n\n\n<tmpl_if canEdit>\n<p>\n   <a href=\"<tmpl_var edit.url>\">Edit</a>\n   &middot;\n   <a href=\"<tmpl_var delete.url>\"><tmpl_var delete.label></a>\n</p>\n</tmpl_if>\n\n<tmpl_if canChangeStatus>\n <p>\n<b>Status:</b> <tmpl_var status.status> ||\n   <a href=\"<tmpl_var approve.url>\"><tmpl_var approve.label></a>\n   &middot;\n   <a href=\"<tmpl_var deny.url>\"><tmpl_var deny.label></a>\n </p>\n</tmpl_if>\n\n\n\n','USS/Submission',1,1);
INSERT INTO template VALUES (4,'Job Submission Form','<h1>Edit Job Posting</h1>\n\n<tmpl_var form.header>\n<input type=\"hidden\" name=\"contentType\" value=\"html\" />\n	<table>\n	<tmpl_if user.isVisitor> <tmpl_if submission.isNew>\n		<tr><td><tmpl_var visitorName.label></td><td><tmpl_var visitorName.form></td></tr>\n	</tmpl_if> </tmpl_if>\n	<tr><td>Job Title</td><td><tmpl_var title.form></td></tr>\n	<tr><td>Job Description</td><td><tmpl_var body.form></td></tr>\n	<tr><td>Job Requirements</td><td><tmpl_var userDefined3.form.htmlarea></td></tr>\n	<tr><td>Compensation</td><td><tmpl_var userDefined1.form></td></tr>\n	<tr><td>Location</td><td><tmpl_var userDefined2.form></td></tr>\n	<tr><td></td><td><tmpl_var form.submit></td></tr>\n	</table>\n<tmpl_var form.footer>\n','USS/SubmissionForm',1,1);
INSERT INTO template VALUES (8,'Synopsis','<div class=\"synopsis\">\r\n<tmpl_loop page_loop>\r\n   <div class=\"synopsis_title\">\r\n      <a href=\"<tmpl_var page.url>\"><tmpl_var page.menuTitle></a>\r\n   </div>\r\n   <tmpl_if page.indent>\r\n      <div class=\"synopsis_sub\">\r\n         <tmpl_var page.synopsis>\r\n      </div>\r\n   <tmpl_else>\r\n      <div class=\"synopsis_summary\">\r\n         <tmpl_var page.synopsis>\r\n      </div>\r\n   </tmpl_if>\r\n</tmpl_loop>\r\n</div>','Navigation',1,1);
INSERT INTO template VALUES (1,'Default WebGUI Login Template','<h1>\n   <tmpl_var title>\n</h1>\n\n<tmpl_if login.message>\r\n   <tmpl_var login.message>\r\n</tmpl_if>\r\n\r\n<tmpl_var login.form.header>\r\n<table >\r\n<tmpl_var login.form.hidden>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var login.form.username.label></td>\r\n   <td class=\"tableData\"><tmpl_var login.form.username></td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var login.form.password.label></td>\r\n   <td class=\"tableData\"><tmpl_var login.form.password></td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"></td>\r\n   <td class=\"tableData\"><tmpl_var login.form.submit></td>\r\n</tr>\r\n</table>\r\n<tmpl_var login.form.footer>\r\n\r\n<div class=\"accountOptions\">\r\n   <ul>\n     <tmpl_if recoverPassword.isAllowed>\n	     <li><a href=\"<tmpl_var recoverPassword.url>\"><tmpl_var recoverPassword.label></a></li>\n	  </tmpl_if>\n           <tmpl_if anonymousRegistration.isAllowed>\n	     <li><a href=\"<tmpl_var createAccount.url>\"><tmpl_var createAccount.label></a></li>\n	  </tmpl_if>\r\n   </ul>\r\n</div>','Auth/WebGUI/Login',1,1);
INSERT INTO template VALUES (1,'Default WebGUI Account Display Template','<h1>\n   <tmpl_var title>\n</h1>\n\n\n<tmpl_if account.message>\r\n   <tmpl_var account.message>\r\n</tmpl_if>\r\n\r\n<tmpl_var account.form.header>\r\n<table >\r\n\n<tmpl_if account.form.karma>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var account.form.karma.label></td>\r\n   <td class=\"tableData\"><tmpl_var account.form.karma></td>\r\n</tr>\r\n</tmpl_if>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var account.form.username.label></td>\r\n   <td class=\"tableData\"><tmpl_var account.form.username></td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var account.form.password.label></td>\r\n   <td class=\"tableData\"><tmpl_var account.form.password></td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var account.form.passwordConfirm.label></td>\r\n   <td class=\"tableData\"><tmpl_var account.form.passwordConfirm></td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"></td>\r\n   <td class=\"tableData\"><tmpl_var account.form.submit></td>\r\n</tr>\r\n</table>\r\n<tmpl_var account.form.footer>\r\n\r\n<div class=\"accountOptions\">\r\n   <ul>\r\n      <tmpl_loop account.options>\r\n         <li><tmpl_var options.display>\r\n      </tmpl_loop>\r\n   </ul>\r\n</div>','Auth/WebGUI/Account',1,1);
INSERT INTO template VALUES (1,'Default WebGUI Anonymous Registration Template','   <h1><tmpl_var title></h1>\r\n\n<tmpl_if create.message>\r\n   <tmpl_var create.message>\r\n</tmpl_if>\r\n\r\n<tmpl_var create.form.header>\r\n<table >\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var create.form.username.label></td>\r\n   <td class=\"tableData\"><tmpl_var create.form.username></td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var create.form.password.label></td>\r\n   <td class=\"tableData\"><tmpl_var create.form.password></td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var create.form.passwordConfirm.label></td>\r\n   <td class=\"tableData\"><tmpl_var create.form.passwordConfirm></td>\r\n</tr>\r\n<tmpl_loop create.form.profile>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var profile.formElement.label></td>\r\n   <td class=\"tableData\"><tmpl_var profile.formElement></td>\r\n</tr>\r\n</tmpl_loop>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"></td>\r\n   <td class=\"tableData\"><tmpl_var create.form.submit></td>\r\n</tr>\r\n</table>\r\n<tmpl_var create.form.footer>\r\n\r\n<div class=\"accountOptions\">\r\n   <ul>\r\n      <li><a href=\"<tmpl_var login.url>\"><tmpl_var login.label></a></li>\r\n      <tmpl_if recoverPassword.isAllowed>\r\n	     <li><a href=\"<tmpl_var recoverPassword.url>\"><tmpl_var recoverPassword.label></a></li>\n	  </tmpl_if>\r\n   </ul>\r\n</div>','Auth/WebGUI/Create',1,1);
INSERT INTO template VALUES (1,'Default WebGUI Password Recovery Template','<h1>\n   <tmpl_var title>\n</h1>\n\r\n\r\n<tmpl_if recover.message>\r\n   <tmpl_var recover.message>\r\n</tmpl_if>\r\n\r\n<tmpl_var recover.form.header>\r\n<table >\r\n<tmpl_var recover.form.hidden>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var recover.form.email.label></td>\r\n   <td class=\"tableData\"><tmpl_var recover.form.email></td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"></td>\r\n   <td class=\"tableData\"><tmpl_var recover.form.submit></td>\r\n</tr>\r\n</table>\r\n<tmpl_var recover.form.footer>\r\n\r\n\r\n<div class=\"accountOptions\">\r\n   <ul>\n       <tmpl_if anonymousRegistration.isAllowed>\n	     <li><a href=\"<tmpl_var createAccount.url>\"><tmpl_var createAccount.label></a></li>\n	  </tmpl_if>\n         <li><a href=\"<tmpl_var login.url>\"><tmpl_var login.label></a></li>\n      \r\n   </ul>\r\n</div>','Auth/WebGUI/Recovery',1,1);
INSERT INTO template VALUES (1,'Default WebGUI Password Reset Template','<h1>\n   <tmpl_var title>\n</h1>\n\r\n<tmpl_if expired.message>\r\n   <tmpl_var expired.message>\r\n</tmpl_if>\r\n\r\n<tmpl_var expired.form.header>\r\n<table >\r\n<tmpl_var expired.form.hidden>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\">\r\n      <tmpl_var expired.form.oldPassword.label>\r\n   </td>\r\n   <td class=\"tableData\">\r\n      <tmpl_var expired.form.oldPassword>\r\n   </td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\">\r\n      <tmpl_var expired.form.password.label>\r\n   </td>\r\n   <td class=\"tableData\">\r\n      <tmpl_var expired.form.password>\r\n   </td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\">\r\n  <tmpl_var expired.form.passwordConfirm.label>\r\n   </td>\r\n   <td class=\"tableData\">\r\n   <tmpl_var expired.form.passwordConfirm>\r\n   </td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"></td>\r\n   <td class=\"tableData\">\r\n   <tmpl_var expired.form.submit>\r\n   </td>\r\n</tr>\r\n</table>\r\n<tmpl_var expired.form.footer>','Auth/WebGUI/Expired',1,1);
INSERT INTO template VALUES (1,'Default LDAP Login Template','<h1>\n   <tmpl_var title>\n</h1>\r\n<tmpl_if login.message>\r\n   <tmpl_var login.message>\r\n</tmpl_if>\r\n\r\n<tmpl_var login.form.header>\r\n<table >\r\n<tmpl_var login.form.hidden>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var login.form.username.label></td>\r\n   <td class=\"tableData\"><tmpl_var login.form.username></td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var login.form.password.label></td>\r\n   <td class=\"tableData\"><tmpl_var login.form.password></td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"></td>\r\n   <td class=\"tableData\"><tmpl_var login.form.submit></td>\r\n</tr>\r\n</table>\r\n<tmpl_var login.form.footer>\r\n\r\n<div class=\"accountOptions\">\r\n   <ul>\r\n             <tmpl_if anonymousRegistration.isAllowed>\n	     <li><a href=\"<tmpl_var createAccount.url>\"><tmpl_var createAccount.label></a></li>\n	  </tmpl_if>\n\n   </ul>\r\n</div>','Auth/LDAP/Login',1,1);
INSERT INTO template VALUES (1,'Default LDAP Account Display Template','<h1>\n   <tmpl_var title>\n</h1>\n\n\r\n<tmpl_var account.message>\r\n<tmpl_if account.form.karma>\r\n<br><br>\r\n<table>\r\n<tr>\r\n  <td class=\"formDescription\">\r\n      <tmpl_var account.form.karma.label>\r\n  </td>\r\n  <td class=\"tableData\">\r\n       <tmpl_var account.form.karma>\r\n  </td>\r\n</tr>\r\n</table>\r\n</tmpl_if>\r\n\r\n<div class=\"accountOptions\">\r\n   <ul>\r\n      <tmpl_loop account.options>\r\n         <li><tmpl_var options.display>\r\n      </tmpl_loop>\r\n   </ul>\r\n</div>','Auth/LDAP/Account',1,1);
INSERT INTO template VALUES (1,'Default LDAP Anonymous Registration Template','<h1>\n   <tmpl_var title>\r\n</h1>\n<tmpl_if create.message>\r\n   <tmpl_var create.message>\r\n</tmpl_if>\r\n\r\n<tmpl_var create.form.header>\r\n<table >\r\n<tmpl_var create.form.hidden>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var create.form.ldapId.label></td>\r\n   <td class=\"tableData\"><tmpl_var create.form.ldapId></td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var create.form.password.label></td>\r\n   <td class=\"tableData\"><tmpl_var create.form.password></td>\r\n</tr>\r\n<tmpl_loop create.form.profile>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var profile.formElement.label></td>\r\n   <td class=\"tableData\"><tmpl_var profile.formElement></td>\r\n</tr>\r\n</tmpl_loop>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"></td>\r\n   <td class=\"tableData\"><tmpl_var create.form.submit></td>\r\n</tr>\r\n</table>\r\n<tmpl_var create.form.footer>\r\n\r\n\r\n<div class=\"accountOptions\">\r\n   <ul>\n     <li><a href=\"<tmpl_var login.url>\"><tmpl_var login.label></a></li>\n \n  </ul>\r\n</div>','Auth/LDAP/Create',1,1);
INSERT INTO template VALUES (1,'Default SMB Login Template','<h1>\n   <tmpl_var title>\n</h1>\n\n\r\n<tmpl_if login.message>\r\n   <tmpl_var login.message>\r\n</tmpl_if>\r\n\r\n<tmpl_var login.form.header>\r\n<table >\r\n<tmpl_var login.form.hidden>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var login.form.username.label></td>\r\n   <td class=\"tableData\"><tmpl_var login.form.username></td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var login.form.password.label></td>\r\n   <td class=\"tableData\"><tmpl_var login.form.password></td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"></td>\r\n   <td class=\"tableData\"><tmpl_var login.form.submit></td>\r\n</tr>\r\n</table>\r\n<tmpl_var login.form.footer>\r\n\r\n<div class=\"accountOptions\">\r\n   <ul>\n           <tmpl_if anonymousRegistration.isAllowed>\n	     <li><a href=\"<tmpl_var createAccount.url>\"><tmpl_var createAccount.label></a></li>\n	  </tmpl_if>\n   </ul>\r\n</div>','Auth/SMB/Login',1,1);
INSERT INTO template VALUES (1,'Default SMB Account Display Template','<h1>\n   <tmpl_var title>\n</h1>\n\n\r\n<tmpl_var account.message>\r\n<tmpl_if account.form.karma>\r\n<br><br>\r\n<table>\r\n<tr>\r\n  <td class=\"formDescription\">\r\n      <tmpl_var account.form.karma.label>\r\n  </td>\r\n  <td class=\"tableData\">\r\n       <tmpl_var account.form.karma>\r\n  </td>\r\n</tr>\r\n</table>\r\n</tmpl_if>\r\n<div class=\"accountOptions\">\r\n   <ul>\r\n      <tmpl_loop account.options>\r\n         <li><tmpl_var options.display>\r\n      </tmpl_loop>\r\n   </ul>\r\n</div>','Auth/SMB/Account',1,1);
INSERT INTO template VALUES (1,'Default SMB Anonymous Registration Template','<h1>  \n <tmpl_var title>\r\n</h1>\n<tmpl_if create.message>\r\n   <tmpl_var create.message>\r\n</tmpl_if>\r\n\r\n<tmpl_var create.form.header>\r\n<table >\r\n<tmpl_var create.form.hidden>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var create.form.loginId.label></td>\r\n   <td class=\"tableData\"><tmpl_var create.form.loginId></td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var create.form.password.label></td>\r\n   <td class=\"tableData\"><tmpl_var create.form.password></td>\r\n</tr>\r\n<tmpl_loop create.form.profile>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var profile.formElement.label></td>\r\n   <td class=\"tableData\"><tmpl_var profile.formElement></td>\r\n</tr>\r\n</tmpl_loop>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"></td>\r\n   <td class=\"tableData\"><tmpl_var create.form.submit></td>\r\n</tr>\r\n</table>\r\n<tmpl_var create.form.footer>\r\n\r\n\r\n<div class=\"accountOptions\">\r\n   <ul>\r\n     <li><a href=\"<tmpl_var login.url>\"><tmpl_var login.label></a></li>\n\n       </ul>\r\n</div>','Auth/SMB/Create',1,1);
INSERT INTO template VALUES (1,'Default WebGUI Yes/No Prompt','<h1><tmpl_var title></h1>\n\n<p>\n<tmpl_var question>\n</p>\n\n<div align=\"center\">\n\n<a href=\"<tmpl_var yes.url>\"><tmpl_var yes.label></a>\n\n&nbsp;  &nbsp; &nbsp; &nbsp; &nbsp; \n\n<a href=\"<tmpl_var no.url>\"><tmpl_var no.label></a>\n\n</div>\n','prompt',1,1);
INSERT INTO template VALUES (2,'Fail Safe','<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n		<html>\n		<head>\n			<title><tmpl_var session.page.title> - <tmpl_var session.setting.companyName></title>\n			<tmpl_var head.tags>\n		<style>\r\n.adminBar {\r\n        background-color: #dddddd;\r\n        font-size: 8pt;\r\n        font-family: helvetica, arial;\r\n        color: #000055;\r\n}\r\n</style>\n		</head>\n		^AdminBar;\n\n<body>\r\n^H; / ^Navigation(TopLevelMenuHorizontal_1000); / ^Navigation(currentMenuHorizontal_1001); / ^a;\r\n<hr>\n\n\n			<tmpl_var body.content>\n		\n\n<hr>\r\n^H; / ^Navigation(TopLevelMenuHorizontal_1000); / ^Navigation(currentMenuHorizontal_1001); / ^a;\r\n</body>\n		</html>\n		','style',0,0);
INSERT INTO template VALUES (1000,'WebGUI 6 Admin Style','<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n		<html>\n		<head>\n			<title><tmpl_var session.page.title> - <tmpl_var session.setting.companyName></title>\n			<tmpl_var head.tags>\n		<style>\r\n\r\ninput:focus, textarea:focus {\r\n background-color: #D5E0E1;\r\n}\r\n\r\ninput, textarea, select {\r\n -moz-border-radius: 6px;\r\n background-color: #B9CDCF;\r\n border: ridge;\r\n}\r\n\r\n\r\n.content{\r\n	color: #000000;\r\n	font-family: Arial, Helvetica, sans-serif;\r\n	font-size: 10pt;\r\n	padding: 5px;\r\n}\r\n\r\nbody{\r\n	color: Black;\r\n	font-family: Arial, Helvetica, sans-serif;\r\n	font-size: 10pt;\r\n	padding: 0px;\r\n	background-position: top;\r\n	background-repeat: repeat-x;\r\n}\r\n\r\na {\r\n	color:#EC4300;\r\n	font-family: Arial, Helvetica, sans-serif;\r\n	font-weight: bold;\r\n	text-decoration: underline;\r\n}\r\n\r\na:hover{\r\n	color:#EC4300; \r\n	font-family: Arial, Helvetica, sans-serif;\r\n	font-weight: bold;\r\n	text-decoration: none;\r\n}\r\n\r\n.adminBar {\r\n  background-color: #CCCCCC;\r\n  font-family: helvetica, arial;\r\n}\r\n\r\n.tableMenu {\r\n  background-color: #CCCCCC;\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.tableMenu a {\r\n  font-size: 10pt;\r\n  text-decoration: none;\r\n}\r\n\r\n.tableHeader {\r\n  background-color: #CECECE;\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.tableData {\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n\r\n.pagination {\r\n  font-family: helvetica, arial;\r\n  font-size: 8pt;\r\n  text-align: center;\r\n}\r\n\r\n\r\nh1 {\r\n	font-size: 14pt;\r\n	font-family: helvetica, arial;\r\n	color: #EC4300;\r\n}\r\n\r\n.tab {\r\n  -moz-border-radius: 6px 6px 0px 0px;\r\n border: 1px solid black;\r\n   background-color: #eeeeee;\r\n}\r\n.tabBody {\r\n   border: 1px solid black;\r\n   border-top: 1px solid black;\r\n   border-left: 1px solid black;\r\n   background-color: #dddddd; \r\n}\r\ndiv.tabs {\r\n    line-height: 15px;\r\n    font-size: 14px;\r\n}\r\n.tabHover {\r\n   background-color: #cccccc;\r\n}\r\n.tabActive { \r\n   background-color: #dddddd; \r\n}\r\n\r\n</style>\r\n		\r\n\r\n\r\n\n		</head>\n				<body bgcolor=\"#D5E0E1\" leftmargin=\"0\" topmargin=\"0\" rightmargin=\"0\" bottommargin=\"0\" marginwidth=\"0\" marginheight=\"0\">\r\n\r\n^AdminBar(2);<br /> <br />\r\n\r\n<div class=\"content\" style=\"padding: 10px;\">\r\n  \n			<tmpl_var body.content>\n		\r\n</div>\r\n\r\n\r\n<div width=\"100%\" style=\"color: white; padding: 3px; background-color: black; text-align: center;\">^H; / ^PageTitle; / ^AdminToggle; / ^LoginToggle; / ^a;</div>\r\n</body>\r\n\r\n\r\n\r\n\r\n\r\n\n		</html>\n		','style',1,1);
INSERT INTO template VALUES (4,'Clipboard','<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n		<html>\n		<head>\n			<title><tmpl_var session.page.title> - <tmpl_var session.setting.companyName></title>\n			<tmpl_var head.tags>\n		<style>\r\n.adminBar {\r\n        background-color: #dddddd;\r\n        font-size: 8pt;\r\n        font-family: helvetica, arial;\r\n        color: #000055;\r\n}\r\n</style>\n		</head>\n		^AdminBar;\n\n<body>\r\n<table width=\"100%\">\r\n<tr><td><span style=\"font-size: 36pt;\">Clipboard</span>\r\n</td>\r\n<td align=\"right\">^H; / ^a;</td></tr>\r\n<tr><td bgcolor=\"#000000\" colspan=\"2\"><img src=\"^Extras;spacer.gif\" height=\"1\"></td></tr>\r\n</table>\r\n<table width=\"100%\"><tr><td valign=\"top\" width=\"30%\"><b>PAGES</b><br>^Navigation(FlexMenu_1002);</td><td width=\"1\" bgcolor=\"#000000\"><img src=\"^Extras;spacer.gif\" width=\"1\"></td><td valign=\"top\" width=\"70%\"><b>CONTENT</b><br>\n\n\n			<tmpl_var body.content>\n		\n\n</td></tr></table>\r\n<table width=\"100%\">\r\n<tr><td bgcolor=\"#000000\" colspan=\"2\"><img src=\"^Extras;spacer.gif\" height=\"1\"></td></tr>\r\n</table>\r\n^H; / ^a;\r\n</body>\n		</html>\n		','style',0,0);
INSERT INTO template VALUES (1001,'WebGUI 6','<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n		<html>\n		<head>\n			<title><tmpl_var session.page.title> - <tmpl_var session.setting.companyName></title>\n			<tmpl_var head.tags>\n		<style>\r\n\r\n.nav,  A.nav:hover, .verticalMenu {\r\n font-size: 10px;\r\n text-decoration: none;\r\n}\r\n\r\n.pageTitle, .pageTitle A {\r\n  font-size: 30px;\r\n}\r\n\r\ninput:focus, textarea:focus {\r\n background-color: #D5E0E1;\r\n}\r\n\r\ninput, textarea, select {\r\n -moz-border-radius: 6px;\r\n background-color: #B9CDCF;\r\n border: ridge;\r\n}\r\n\r\n.wgBoxTop{\r\n	background-image: url(\"^Extras;/styles/webgui6/hdr_bg_corner_right.jpg\");\r\n        width: 195px;\r\n        height: 93px;\r\n}\r\n.wgBoxBottom{\r\n	background-image: url(\"^Extras;/styles/webgui6/content_bg_clouds.jpg\");\r\n	padding-bottom: 21px;\r\n        width: 529px;\r\n        height: 88px;\r\n}\r\n.logo {\r\n	background-image: url(\"^Extras;/styles/webgui6/hdr_bg_corner_left.jpg\");\r\n	background-color: #F4F4F4;\r\n	width: 195px;\r\n        height: 93px;\r\n        padding-bottom: 25px;\r\n}\r\n.login {\r\n        width: 334px;\r\n        height: 93px;\r\n	background-image: url(\"^Extras;/styles/webgui6/hdr_bg_center.jpg\");\r\n	background-color: #C1D6D8;\r\n        padding-top: 5px;\r\n	font-family: Arial, Helvetica, sans-serif;\r\n	font-size: 10px;\r\n	font-weight: bold;\r\n	color: #EC4300;\r\n}\n  input.loginBoxField { \n font-size: 10px;\n background-color: white;\n }\n .loginBox {\n font-size: 10px;\n }\n input.loginBoxButton {\n font-size: 10px;\n }  \r\n.iconBox{\r\n	background-image: url(\"^Extras;/styles/webgui6/content_bg_corner_left_top.jpg\");\r\n        width: 195px;\r\n        height: 88px;\r\n        vertical-align: bottom;\r\n        text-align: center;\r\n}\r\n.dateLeft {\r\n	background-image: url(\"^Extras;/styles/webgui6/date_bg_left.jpg\");	\r\n     width: 53px;\r\n     height: 59px;\r\n}\r\n\r\n.dateRight {\r\n     width: 53px;\r\n     height: 59px;\r\n	background-image: url(\"^Extras;/styles/webgui6/date_right_bg.jpg\");	\r\n}\r\n\r\n.date {\r\n	color: #393C3C;\r\n	font-family: Arial, Helvetica, sans-serif;\r\n	font-size: 11px;\r\n	font-weight: bold;\r\n}\r\n\r\n.contentbgLeft {\r\n	background-image: url(\"^Extras;/styles/webgui6/content_bg_left.jpg\");	\r\n    width: 53px;\r\n	\r\n}\r\n.contentbgRight {\r\n	background-image: url(\"^Extras;/styles/webgui6/content_bg_right.jpg\");	\r\n	\r\n}\r\n\r\n\r\n.content{\r\n	color: #000000;\r\n	font-family: Arial, Helvetica, sans-serif;\r\n	font-size: 10pt;\r\n	padding: 5px;\r\n}\r\n\r\nbody{\r\n	color: Black;\r\n	font-family: Arial, Helvetica, sans-serif;\r\n	font-size: 10pt;\r\n	padding: 0px;\r\n        background-image: url(\"^Extras;/styles/webgui6/bg.gif\");\r\n	background-position: top;\r\n	background-repeat: repeat-x;\r\n}\r\n\r\na {\r\n	color:#EC4300;\r\n	font-family: Arial, Helvetica, sans-serif;\r\n	font-weight: bold;\r\n	text-decoration: underline;\r\n}\r\n\r\na:hover{\r\n	color:#EC4300; \r\n	font-family: Arial, Helvetica, sans-serif;\r\n	font-weight: bold;\r\n	text-decoration: none;\r\n}\r\n\r\n.adminBar {\r\n  background-color: #CCCCCC;\r\n  font-family: helvetica, arial;\r\n}\r\n.tableMenu {\r\n  background-color: #CCCCCC;\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n.tableMenu a {\r\n  font-size: 10pt;\r\n  text-decoration: none;\r\n}\r\n.tableHeader {\r\n  background-color: #CECECE;\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n.tableData {\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n.pollColor {\r\n  background-color: #CCCCCC;\r\n  border: thin solid #393C3C;\r\n}\r\n.pagination {\r\n  font-family: helvetica, arial;\r\n  font-size: 8pt;\r\n  text-align: center;\r\n}\r\n\r\nh1, h2, h3, h4, h5, h6 {\r\n   font-family: helvetica, arial;\r\n	color: #EC4300;\r\n}\r\n\r\nh1 {\r\n	font-size: 14pt;\r\n	font-family: helvetica, arial;\r\n	color: #EC4300;\r\n}\r\n\r\n.tab {\r\n  border: 1px solid black;\r\n   background-color: #eeeeee;\r\n}\r\n.tabBody {\r\n   border: 1px solid black;\r\n   border-top: 1px solid black;\r\n   border-left: 1px solid black;\r\n   background-color: #dddddd; \r\n}\r\ndiv.tabs {\r\n    line-height: 15px;\r\n    font-size: 14px;\r\n}\r\n.tabHover {\r\n   background-color: #cccccc;\r\n}\r\n.tabActive { \r\n   background-color: #dddddd; \r\n}\r\n\r\n</style>\r\n		\n		</head>\n		<body bgcolor=\"#D5E0E1\" leftmargin=\"0\" topmargin=\"0\" rightmargin=\"0\" bottommargin=\"0\" marginwidth=\"0\" marginheight=\"0\">\r\n^AdminBar(2);\r\n\r\n<!-- logo / login table starts here -->\r\n<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\" align=\"center\">\r\n	<tr>	\r\n		<td width=\"195\" align=\"center\" class=\"logo\"><a href=\"http://www.plainblack.com/webgui\"><img border=\"0\" src=\"^Extras;/styles/webgui6/wg_logo.gif\"></a></td>\r\n		<td width=\"334\" align=\"center\" valign=\"top\" class=\"login\">^L(17,\"\",2); ^AdminToggle;</td>\r\n		<td width=\"195\" align=\"center\" class=\"wgBoxTop\" valign=\"bottom\"><a href=\"http://www.plainblack.com/webgui\"><img border=\"0\" src=\"^Extras;/styles/webgui6/wg_box_top.gif\"></a></td>\r\n	</tr>\r\n</table>\r\n<!-- logo / login table ends here -->\r\n<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\" align=\"center\">\r\n	<tr>\r\n	<!-- print, email icons here -->\r\n		<td class=\"iconBox\">\n &nbsp; &nbsp; &nbsp; &nbsp; \r\n<a href=\"^H(linkonly);\"><img border=\"0\" src=\"^Extras;/styles/webgui6/icon_home.gif\" title=\"Go Home\" alt=\"home\" /></a> \n <a href=\"^/;tell_a_friend\"><img border=\"0\" src=\"^Extras;/styles/webgui6/icon_email.gif\" alt=\"Email\" title=\"Email a friend about this site.\" /></a>\r\n<a href=\"^r(linkonly);\"><img border=\"0\" src=\"^Extras;/styles/webgui6/icon_print.gif\" alt=\"Print\" title=\"Make page printable.\" /></a> \n <a href=\"site_map\"><img border=\"0\" src=\"^Extras;/styles/webgui6/icon_site_map.gif\" title=\"View the site map.\" ALT=\"Site Map\" /></a> <a href=\"http://www.plainblack.com\"><img border=\"0\" src=\"^Extras;/styles/webgui6/icon_pb.gif\" ALT=\"Plain Black Icon\" title=\"Visit plainblack.com.\" /></a>\r\n</td>\r\n	<!-- box clouds here -->\r\n		<td class=\"wgBoxBottom\">^Spacer(56,1);<a href=\"http://www.plainblack.com/what_is_webgui\"><img border=\"0\" src=\"^Extras;/styles/webgui6/txt_the_last.gif\"></a>^Spacer(26,1);<a href=\"http://www.plainblack.com/webgui\"><img border=\"0\" src=\"^Extras;/styles/webgui6/wg_box_bottom.gif\"></a></td>\r\n	</tr>\r\n</table>\r\n<!-- date & page title table start here -->\r\n<table width=\"724\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\" align=\"center\">\r\n	<tr>\r\n		<td class=\"dateLeft\">^Spacer(53,59);</td>\r\n		<td width=\"141\" bgcolor=\"#BDC6C7\" class=\"date\">^D(\"%c %D, %y\");</td>\r\n		<td><img border=\"0\" src=\"^Extras;/styles/webgui6/date_right_shadow.gif\"></td>\r\n		<td width=\"467\" bgcolor=\"#B9CDCF\"><div class=\"pageTitle\">^PageTitle;</div></td>\r\n		<td class=\"dateRight\">^Spacer(53,59);</td>\r\n	</tr>\r\n</table>\r\n<!-- date and page title table end here -->\r\n<!-- left nav & content table start here -->\r\n<table width=\"724\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\" align=\"center\">\r\n	<tr>\r\n		<td class=\"contentbgLeft\">^Spacer(53,1);</td>\r\n		<!-- nav column -->\r\n		<td width=\"142\" valign=\"top\" bgcolor=\"#E2E1E1\" style=\"width: 142px;\">\r\n<br /> <div class=\"nav\">\r\n^Navigation(FlexMenu_1002);\r\n</div> <br /> <br />\r\n<a href=\"http://www.plainblack.com/webgui\"><img border=\"0\" src=\"^Extras;/styles/webgui6/powered_by_aqua_blue.gif\"></a>\r\n</td>\r\n\r\n		<td valign=\"top\" bgcolor=\"#F4F4F4\"><img border=\"0\" src=\"^Extras;/styles/webgui6/lnav_shadow.jpg\"></td>\r\n		<!-- content column -->\r\n		<td width=\"466\" valign=\"top\" bgcolor=\"#F4F4F4\" class=\"content\">\n			<tmpl_var body.content>\n		</td>\r\n		<td class=\"contentbgRight\">^Spacer(53,1);</td>\r\n	</tr>\r\n</table>\r\n<!-- left nav & content table end here -->\r\n<!-- footer -->\r\n<table width=\"724\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\" align=\"center\">\r\n	<tr>\r\n		<td><img border=\"0\" src=\"^Extras;/styles/webgui6/footer.jpg\"></td>\r\n	</tr>\r\n        <tr>\r\n                <td align=\"center\"><a href=\"http://www.plainblack.com\"><img border=\"0\" src=\"^Extras;/styles/webgui6/logo_pb.gif\"></a><br /><span style=\"font-size: 11px;\"><a href=\"http://www.plainblack.com/design\">Design by Plain Black</a></span></td>\r\n        </tr>\r\n</table>\r\n</body>\r\n</body>\n		</html>\n		','style',1,1);
INSERT INTO template VALUES (3,'Make Page Printable','<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n		<html>\n		<head>\n			<title><tmpl_var session.page.title> - <tmpl_var session.setting.companyName></title>\n			<tmpl_var head.tags>\n		<style>\r\n\r\n.content{\r\n  background-color: #ffffff;\r\n  color: #000000;\r\n  font-family: helvetica, arial;\r\n  font-size: 10pt;\r\n  padding: 10pt;\r\n}\r\n\r\nH1 {\r\n  font-family: helvetica, arial;\r\n  font-size: 16pt;\r\n}\r\n\r\nA {\r\n  color: #EF4200;\r\n}\r\n\r\n.pagination {\r\n  font-family: helvetica, arial;\r\n  font-size: 8pt;\r\n  text-align: center;\r\n}\r\n\r\n.formDescription {\r\n  font-family: helvetica, arial;\r\n  font-size: 10pt;\r\n  font-weight: bold;\r\n}\r\n\r\n.formSubtext {\r\n  font-family: helvetica, arial;\r\n  font-size: 8pt;\r\n}\r\n\r\n.highlight {\r\n  background-color: #dddddd;\r\n}\r\n\r\n.tableMenu {\r\n  background-color: #cccccc;\r\n  font-size: 8pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.tableMenu a {\r\n  text-decoration: none;\r\n}\r\n\r\n.tableHeader {\r\n  background-color: #cccccc;\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.tableData {\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.pollAnswer {\r\n  font-family: Helvetica, Arial;\r\n  font-size: 8pt;\r\n}\r\n\r\n.pollColor {\r\n  background-color: #444444;\r\n}\r\n\r\n.pollQuestion {\r\n  font-face: Helvetica, Arial;\r\n  font-weight: bold;\r\n}\r\n\r\n.faqQuestion {\r\n  font-size: 12pt;\r\n  font-weight: bold;\r\n  color: #000000;\r\n}\r\n\r\n</style>\n		</head>\n		^AdminBar;\n\n<body onLoad=\"window.print()\">\r\n<div align=\"center\"><a href=\"^\\;\"><img src=\"^Extras;plainblack.gif\" border=\"0\"></a></div>\n\n\n			<tmpl_var body.content>\n		\n\n<div align=\"center\"> 2001-2004 Plain Black LLC</div>\r\n</body>\n		</html>\n		','style',1,1);
INSERT INTO template VALUES (5,'Trash','<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n		<html>\n		<head>\n			<title><tmpl_var session.page.title> - <tmpl_var session.setting.companyName></title>\n			<tmpl_var head.tags>\n		<style>\r\n.adminBar {\r\n        background-color: #dddddd;\r\n        font-size: 8pt;\r\n        font-family: helvetica, arial;\r\n        color: #000055;\r\n}\r\n</style>\n		</head>\n		^AdminBar;\n\n<body>\r\n<table width=\"100%\">\r\n<tr><td><span style=\"font-size: 36pt;\">Trash</span>\r\n</td>\r\n<td align=\"right\">^H; / ^a; / <a href=\"^\\;?op=purgeTrash\">Empty Trash</a></td></tr>\r\n<tr><td bgcolor=\"#000000\" colspan=\"2\"><img src=\"^Extras;spacer.gif\" height=\"1\"></td></tr>\r\n</table>\r\n<table width=\"100%\"><tr><td valign=\"top\" width=\"30%\"><b>PAGES</b><br>^Navigation(FlexMenu_1002);</td><td width=\"1\" bgcolor=\"#000000\"><img src=\"^Extras;spacer.gif\" width=\"1\"></td><td valign=\"top\" width=\"70%\"><b>CONTENT</b><br>\n\n\n			<tmpl_var body.content>\n		\n\n</td></tr></table>\r\n<table width=\"100%\">\r\n<tr><td bgcolor=\"#000000\" colspan=\"2\"><img src=\"^Extras;spacer.gif\" height=\"1\"></td></tr>\r\n</table>\r\n^H; / ^a; / <a href=\"^\\;?op=purgeTrash\">Empty Trash</a>\r\n</body>\n		</html>\n		','style',0,0);
INSERT INTO template VALUES (1,'Packages','<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n		<html>\n		<head>\n			<title><tmpl_var session.page.title> - <tmpl_var session.setting.companyName></title>\n			<tmpl_var head.tags>\n		<style>\r\n.adminBar {\r\n        background-color: #dddddd;\r\n        font-size: 8pt;\r\n        font-family: helvetica, arial;\r\n        color: #000055;\r\n}\r\n</style>\n		</head>\n		^AdminBar;\n\n<body>\r\n<table width=\"100%\">\r\n<tr><td><span style=\"font-size: 36pt;\">Packages</span>\r\n</td>\r\n<td align=\"right\">^H; / ^a;</td></tr>\r\n<tr><td bgcolor=\"#000000\" colspan=\"2\"><img src=\"^Extras;spacer.gif\" height=\"1\"></td></tr>\r\n</table>\r\n<table width=\"100%\"><tr><td valign=\"top\" width=\"30%\"><b>PACKAGES</b><br>^Navigation(FlexMenu_1002);</td><td width=\"1\" bgcolor=\"#000000\"><img src=\"^Extras;spacer.gif\" width=\"1\"></td><td valign=\"top\" width=\"70%\"><b>CONTENT</b><br>\n\n\n			<tmpl_var body.content>\n		\n\n</td></tr></table>\r\n<table width=\"100%\">\r\n<tr><td bgcolor=\"#000000\" colspan=\"2\"><img src=\"^Extras;spacer.gif\" height=\"1\"></td></tr>\r\n</table>\r\n^H; / ^a;\r\n</body>\n		</html>\n		','style',0,0);
INSERT INTO template VALUES (10,'htmlArea Image Manager','<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n		<html>\n		<head>\n			<title><tmpl_var session.page.title> - <tmpl_var session.setting.companyName></title>\n			<tmpl_var head.tags>\n		<style type=\"text/css\">\r\nTD { font: 8pt \'MS Shell Dlg\', Helvetica, sans-serif; }\r\nTD.delete { font: italic 7pt \'MS Shell Dlg\', Helvetica, sans-serif; }\r\nTD.label { font: 8pt \'MS Shell Dlg\', Helvetica, sans-serif; background-color: #c0c0c0; }\r\nTD.none { font: italic 12pt \'MS Shell Dlg\', Helvetica, sans-serif; }\r\n\r\n</style>\r\n\n		</head>\n		<script language=\"javascript\">\r\nfunction findAncestor(element, name, type) {\r\n   while(element != null && (element.name != name || element.tagName != type))\r\n      element = element.parentElement;\r\n   return element;\r\n}\r\n</script>\r\n<script language=\"javascript\">\r\n\r\nfunction actionComplete(action, path, error, info) {\r\n   var manager = findAncestor(window.frameElement, \'manager\', \'TABLE\');\r\n   var wrapper = findAncestor(window.frameElement, \'wrapper\', \'TABLE\');\r\n\r\n   if(manager) {\r\n      if(error.length < 1) {\r\n         manager.all.actions.reset();\r\n         if(action == \'upload\') {\r\n            manager.all.actions.image.value = \'\';\r\n            manager.all.actions.name.value = \'\';\r\n           manager.all.actions.thumbnailSize.value = \'\';\r\n\r\n         }\r\n         if(action == \'create\')\r\n            manager.all.actions.folder.value = \'\';\r\n         if(action == \'delete\')\r\n            manager.all.txtFileName.value = \'\';\r\n      }\r\n      manager.all.actions.DPI.value = 96;\r\n      manager.all.actions.path.value = path;\r\n   }\r\n   if(wrapper)\r\n      wrapper.all.viewer.contentWindow.navigate(\'/?op=htmlAreaviewCollateral\');\r\n   if(error.length > 0)\r\n      alert(error);\r\n   else if(info.length > 0)\r\n      alert(info);\r\n}\r\n</script>\r\n\r\n<script language=\"javascript\">\r\nfunction deleteCollateral(options) {\r\n   var lister = findAncestor(window.frameElement, \'lister\', \'IFRAME\');\r\n\r\n   if(lister && confirm(\"Are you sure you want to delete this item ?\"))\r\n      lister.contentWindow.navigate(\'^/;?op=htmlAreaDelete&\' + options);\r\n}\r\n</script>\r\n</head>\r\n<body leftmargin=\"0\" topmargin=\"0\" marginwidth=\"0\" marginheight=\"0\">\r\n\n			<tmpl_var body.content>\n		\r\n</body>\n		</html>\n		','style',1,0);
INSERT INTO template VALUES (6,'Empty','<tmpl_var body.content>','style',0,0);
INSERT INTO template VALUES (5,'Item','<tmpl_if displaytitle>\r\n   <tmpl_if linkurl>\r\n       <a href=\"<tmpl_var linkurl>\">\r\n    </tmpl_if>\r\n     <span class=\"itemTitle\"><tmpl_var title></span>\r\n   <tmpl_if linkurl>\r\n      </a>\r\n    </tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_if attachment.name>\r\n   <tmpl_if displaytitle> - </tmpl_if>\r\n   <a href=\"<tmpl_var attachment.url>\"><img src=\"<tmpl_var attachment.Icon>\" border=\"0\" alt=\"<tmpl_var attachment.name>\" width=\"16\" height=\"16\" border=\"0\" align=\"middle\" /></a>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n  - <tmpl_var description>\r\n</tmpl_if>','Article',1,1);
INSERT INTO template VALUES (6,'Item w/pop-up Links','<tmpl_if displaytitle>\r\n   <tmpl_if linkurl>\r\n       <a href=\"<tmpl_var linkurl>\" target=\"_blank\">\r\n    </tmpl_if>\r\n     <span class=\"itemTitle\"><tmpl_var title></span>\r\n   <tmpl_if linkurl>\r\n      </a>\r\n    </tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_if attachment.name>\r\n   <tmpl_if displaytitle> - </tmpl_if>\r\n   <a href=\"<tmpl_var attachment.url>\" target=\"_blank\"><img src=\"<tmpl_var attachment.Icon>\" border=\"0\" alt=\"<tmpl_var attachment.name>\" width=\"16\" height=\"16\" border=\"0\" align=\"middle\" /></a>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n  - <tmpl_var description>\r\n</tmpl_if>','Article',1,1);
INSERT INTO template VALUES (17,'Q and A','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n <tmpl_if canPost>\n			<a href=\"<tmpl_var post.url>\"> <tmpl_var addquestion.label></a><p />\r\n</tmpl_if>\r\n\r\n\r\n<tmpl_loop submissions_loop>\r\n   \n		<tmpl_if submission.currentUser>\n			<tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var submission.edit.url>\"><tmpl_var submission.edit.label></a>]</tmpl_unless>\n		</tmpl_if>\n		<tmpl_if canModerate>\n			<tmpl_if session.var.adminOn><tmpl_var submission.controls><tmpl_else><tmpl_unless submission.currentUser><tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var submission.edit.url>\"><tmpl_var submission.edit.label></a>]</tmpl_unless></tmpl_unless></tmpl_if>\n		</tmpl_if>\n		\r\n  <b>Q: <tmpl_var submission.title></b><br />\r\n  A: <tmpl_var submission.content.full>\r\n  <p />\r\n</tmpl_loop>\r\n\r\n','USS',1,1);
INSERT INTO template VALUES (20,'Ordered List','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n <tmpl_if canPost>\n			<a href=\"<tmpl_var post.url>\"> <tmpl_var addlink.label></a><p />\r\n</tmpl_if>\r\n\r\n<ol>\r\n<tmpl_loop submissions_loop>\r\n  <li>\r\n   \n		<tmpl_if submission.currentUser>\n			<tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var submission.edit.url>\"><tmpl_var submission.edit.label></a>]</tmpl_unless>\n		</tmpl_if>\n		<tmpl_if canModerate>\n			<tmpl_if session.var.adminOn><tmpl_var submission.controls><tmpl_else><tmpl_unless submission.currentUser><tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var submission.edit.url>\"><tmpl_var submission.edit.label></a>]</tmpl_unless></tmpl_unless></tmpl_if>\n		</tmpl_if>\r\n\r\n   <a href=\"<tmpl_var submission.userDefined1>\"\r\n   <tmpl_if submission.userDefined2>\r\n          target=\"_blank\"\r\n    </tmpl_if>\r\n    ><span class=\"linkTitle\"><tmpl_var submission.title></span></a>\r\n\r\n    <tmpl_if submission.content.full>\r\n              - <tmpl_var submission.content.full>\r\n   </tmpl_if>\r\n  </li>\r\n</tmpl_loop>\r\n</ol>','USS',1,1);
INSERT INTO template VALUES (21,'Descriptive','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n <tmpl_if canPost>\n			<a href=\"<tmpl_var post.url>\"> <tmpl_var addlink.label></a><p />\r\n</tmpl_if>\r\n\r\n<tmpl_loop submissions_loop>\r\n   \n		<tmpl_if submission.currentUser>\n			<tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var submission.edit.url>\"><tmpl_var submission.edit.label></a>]</tmpl_unless>\n		</tmpl_if>\n		<tmpl_if canModerate>\n			<tmpl_if session.var.adminOn><tmpl_var submission.controls><tmpl_else><tmpl_unless submission.currentUser><tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var submission.edit.url>\"><tmpl_var submission.edit.label></a>]</tmpl_unless></tmpl_unless></tmpl_if>\n		<br />\r\n   </tmpl_if>\r\n\r\n  <a href=\"<tmpl_var submission.userDefined1>\"\r\n   <tmpl_if submission.userDefined2>\r\n          target=\"_blank\"\r\n    </tmpl_if>\r\n    ><span class=\"linkTitle\"><tmpl_var submission.title></span></a>\r\n\r\n    <tmpl_if submission.content.full>\r\n              - <tmpl_var submission.content.full>\r\n   </tmpl_if>\r\n   <p />\r\n</tmpl_loop>\r\n','USS',1,1);
INSERT INTO template VALUES (1000,'Titled Link List','<tmpl_if displayTitle>\n    <h1><tmpl_var title></h1>\n</tmpl_if>\n\n<tmpl_if description>\n    <tmpl_var description><p />\n</tmpl_if>\n\n <tmpl_if canPost>\n			<a href=\"<tmpl_var post.url>\"> <tmpl_var addlink.label></a><p />\n</tmpl_if>\n\n<tmpl_loop submissions_loop>\n   \n		<tmpl_if submission.currentUser>\n			<tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var submission.edit.url>\"><tmpl_var submission.edit.label></a>]</tmpl_unless>\n		</tmpl_if>\n		<tmpl_if canModerate>\n			<tmpl_if session.var.adminOn><tmpl_var submission.controls><tmpl_else><tmpl_unless submission.currentUser><tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var submission.edit.url>\"><tmpl_var submission.edit.label></a>]</tmpl_unless></tmpl_unless></tmpl_if>\n		<br />\n   </tmpl_if>\n\n  <a href=\"<tmpl_var submission.userDefined1>\"\n   <tmpl_if submission.userDefined2>\n          target=\"_blank\"\n    </tmpl_if>\n    ><span class=\"linkTitle\"><tmpl_var submission.title></span></a>\n\n    <tmpl_if submission.content.full>\n              <br /> <tmpl_var submission.content.full>\n   </tmpl_if>\n   <p />\n</tmpl_loop>\n','USS',1,1);
INSERT INTO template VALUES (3,'Link','<h1><tmpl_var title></h1>\r\n\r\n<tmpl_if content>\r\n<p>\r\n<b>Link Description</b><br />\r\n<tmpl_var content>\r\n</p>\r\n</tmpl_if>\r\n\r\n<b>Link URL</b><br />\r\n<a href=\"<tmpl_var userDefined1.value>\"><tmpl_var userDefined1.value></a>\r\n\r\n<p>\r\n<a href=\"<tmpl_var back.url>\">List All Links</a>\r\n</p>\r\n\r\n\r\n<tmpl_if canEdit>\r\n<p>\r\n   <a href=\"<tmpl_var edit.url>\">Edit</a>\r\n   &middot;\r\n   <a href=\"<tmpl_var delete.url>\"><tmpl_var delete.label></a>\r\n</p>\r\n</tmpl_if>\r\n\r\n<tmpl_if canChangeStatus>\r\n <p>\r\n<b>Status:</b> <tmpl_var status.status> ||\r\n   <a href=\"<tmpl_var approve.url>\"><tmpl_var approve.label></a>\r\n   &middot;\r\n   <a href=\"<tmpl_var deny.url>\"><tmpl_var deny.label></a>\r\n </p>\r\n</tmpl_if>\r\n\r\n\r\n\r\n','USS/Submission',1,1);
INSERT INTO template VALUES (1,'Default Account Macro','<a class=\"myAccountLink\" href=\"<tmpl_var account.url>\"><tmpl_var account.text></a>','Macro/a_account',1,1);
INSERT INTO template VALUES (1,'Default Editable Toggle Macro','<a href=\"<tmpl_var toggle.url>\"><tmpl_var toggle.text></a>','Macro/EditableToggle',1,1);
INSERT INTO template VALUES (1,'Default Admin Toggle Macro','<a href=\"<tmpl_var toggle.url>\"><tmpl_var toggle.text></a>','Macro/AdminToggle',1,1);
INSERT INTO template VALUES (1,'Default File Macro','<a href=\"<tmpl_var file.url>\"><img src=\"<tmpl_var file.icon>\" align=\"middle\" border=\"0\" /><tmpl_var file.name></a>','Macro/File',1,1);
INSERT INTO template VALUES (2,'File no icon','<a href=\"<tmpl_var file.url>\"><tmpl_var file.name></a>','Macro/File',1,1);
INSERT INTO template VALUES (3,'File with size','<a href=\"<tmpl_var file.url>\"><img src=\"<tmpl_var file.icon>\" align=\"middle\" border=\"0\" /><tmpl_var file.name></a>(<tmpl_var file.size>)','Macro/File',1,1);
INSERT INTO template VALUES (1,'Default Group Add Macro','<a href=\"<tmpl_var group.url>\"><tmpl_var group.text></a>','Macro/GroupAdd',1,1);
INSERT INTO template VALUES (1,'Default Group Delete Macro','<a href=\"<tmpl_var group.url>\"><tmpl_var group.text></a>','Macro/GroupDelete',1,1);
INSERT INTO template VALUES (1,'Default Homelink','<a class=\"homeLink\" href=\"<tmpl_var homeLink.url>\"><tmpl_var homeLink.text></a>','Macro/H_homeLink',1,1);
INSERT INTO template VALUES (1,'Default Make Printable','<a class=\"makePrintableLink\" href=\"<tmpl_var printable.url>\"><tmpl_var printable.text></a>','Macro/r_printable',1,1);
INSERT INTO template VALUES (1,'Default LoginToggle','<a class=\"loginToggleLink\" href=\"<tmpl_var toggle.url>\"><tmpl_var toggle.text></a>','Macro/LoginToggle',1,1);
INSERT INTO template VALUES (1,'Attachment Box','<p>\r\n  <table cellpadding=3 cellspacing=0 border=1>\r\n  <tr>   \r\n    <td class=\"tableHeader\">\r\n<a href=\"<tmpl_var attachment.url>\"><img src=\"<tmpl_var session.config.extrasURL>/attachment.gif\" border=\"0\" alt=\"<tmpl_var attachment.name>\"></a></td><td>\r\n<a href=\"<tmpl_var attachment.url>\"><img src=\"<tmpl_var attachment.icon>\" align=\"middle\" width=\"16\" height=\"16\" border=\"0\" alt=\"<tmpl_var attachment.name>\"><tmpl_var attachment.name></a>\r\n    </td>\r\n  </tr>\r\n  </table>\r\n</p>\r\n','AttachmentBox',1,1);
INSERT INTO TEMPLATE VALUES (1,'Default Post Preview','<h2><tmpl_var newpost.header></h2>\n\n<h1><tmpl_var post.subject></h1>\n\n<table width=\"100%\">\n<tr>\n<td class=\"content\" valign=\"top\">\n<tmpl_var post.message>\n</td>\n</tr>\n</table>\n\n<tmpl_var form.begin>\n<input type=\"button\" value=\"cancel\" onclick=\"window.history.go(-1)\"><tmpl_var form.submit>\n<tmpl_var form.end>\n','Forum/PostPreview',1,1);

--
-- Table structure for table `theme`
--

CREATE TABLE theme (
  themeId int(11) NOT NULL default '0',
  name varchar(255) default NULL,
  designer varchar(255) default NULL,
  designerURL text,
  original int(11) NOT NULL default '1',
  webguiVersion varchar(10) default NULL,
  versionNumber int(11) NOT NULL default '0'
) TYPE=MyISAM;

--
-- Dumping data for table `theme`
--



--
-- Table structure for table `themeComponent`
--

CREATE TABLE themeComponent (
  themeId int(11) NOT NULL default '0',
  themeComponentId int(11) NOT NULL default '0',
  type varchar(35) default NULL,
  id varchar(255) default NULL
) TYPE=MyISAM;

--
-- Dumping data for table `themeComponent`
--



--
-- Table structure for table `userLoginLog`
--

CREATE TABLE userLoginLog (
  userId int(11) default NULL,
  status varchar(30) default NULL,
  timeStamp int(11) default NULL,
  ipAddress varchar(128) default NULL,
  userAgent text
) TYPE=MyISAM;

--
-- Dumping data for table `userLoginLog`
--



--
-- Table structure for table `userProfileCategory`
--

CREATE TABLE userProfileCategory (
  profileCategoryId int(11) NOT NULL default '0',
  categoryName varchar(255) default NULL,
  sequenceNumber int(11) NOT NULL default '1',
  visible int(11) NOT NULL default '1',
  editable int(11) NOT NULL default '1',
  PRIMARY KEY  (profileCategoryId)
) TYPE=MyISAM;

--
-- Dumping data for table `userProfileCategory`
--


INSERT INTO userProfileCategory VALUES (1,'WebGUI::International::get(449,\"WebGUI\");',6,1,1);
INSERT INTO userProfileCategory VALUES (2,'WebGUI::International::get(440,\"WebGUI\");',2,1,1);
INSERT INTO userProfileCategory VALUES (3,'WebGUI::International::get(439,\"WebGUI\");',1,1,1);
INSERT INTO userProfileCategory VALUES (4,'WebGUI::International::get(445,\"WebGUI\");',7,0,1);
INSERT INTO userProfileCategory VALUES (5,'WebGUI::International::get(443,\"WebGUI\");',3,1,1);
INSERT INTO userProfileCategory VALUES (6,'WebGUI::International::get(442,\"WebGUI\");',4,1,1);
INSERT INTO userProfileCategory VALUES (7,'WebGUI::International::get(444,\"WebGUI\");',5,1,1);

--
-- Table structure for table `userProfileData`
--

CREATE TABLE userProfileData (
  userId int(11) NOT NULL default '0',
  fieldName varchar(128) NOT NULL default '',
  fieldData text,
  PRIMARY KEY  (userId,fieldName)
) TYPE=MyISAM;

--
-- Dumping data for table `userProfileData`
--


INSERT INTO userProfileData VALUES (1,'language','English');
INSERT INTO userProfileData VALUES (3,'language','English');
INSERT INTO userProfileData VALUES (3,'uiLevel','9');

--
-- Table structure for table `userProfileField`
--

CREATE TABLE userProfileField (
  fieldName varchar(128) NOT NULL default '',
  fieldLabel varchar(255) default NULL,
  visible int(11) NOT NULL default '0',
  required int(11) NOT NULL default '0',
  dataType varchar(128) NOT NULL default 'text',
  dataValues text,
  dataDefault text,
  sequenceNumber int(11) NOT NULL default '1',
  profileCategoryId int(11) NOT NULL default '1',
  protected int(11) NOT NULL default '0',
  editable int(11) NOT NULL default '1',
  PRIMARY KEY  (fieldName)
) TYPE=MyISAM;

--
-- Dumping data for table `userProfileField`
--


INSERT INTO userProfileField VALUES ('email','WebGUI::International::get(56,\"WebGUI\");',1,1,'email',NULL,NULL,1,2,1,1);
INSERT INTO userProfileField VALUES ('firstName','WebGUI::International::get(314,\"WebGUI\");',1,0,'text',NULL,NULL,1,3,1,1);
INSERT INTO userProfileField VALUES ('middleName','WebGUI::International::get(315,\"WebGUI\");',1,0,'text',NULL,NULL,2,3,1,1);
INSERT INTO userProfileField VALUES ('lastName','WebGUI::International::get(316,\"WebGUI\");',1,0,'text',NULL,NULL,3,3,1,1);
INSERT INTO userProfileField VALUES ('icq','WebGUI::International::get(317,\"WebGUI\");',1,0,'text',NULL,NULL,2,2,1,1);
INSERT INTO userProfileField VALUES ('aim','WebGUI::International::get(318,\"WebGUI\");',1,0,'text',NULL,NULL,3,2,1,1);
INSERT INTO userProfileField VALUES ('msnIM','WebGUI::International::get(319,\"WebGUI\");',1,0,'text',NULL,NULL,4,2,1,1);
INSERT INTO userProfileField VALUES ('yahooIM','WebGUI::International::get(320,\"WebGUI\");',1,0,'text',NULL,NULL,5,2,1,1);
INSERT INTO userProfileField VALUES ('cellPhone','WebGUI::International::get(321,\"WebGUI\");',1,0,'phone',NULL,NULL,6,2,1,1);
INSERT INTO userProfileField VALUES ('pager','WebGUI::International::get(322,\"WebGUI\");',1,0,'phone',NULL,NULL,7,2,1,1);
INSERT INTO userProfileField VALUES ('emailToPager','WebGUI::International::get(441,\"WebGUI\");',1,0,'email',NULL,NULL,8,2,1,1);
INSERT INTO userProfileField VALUES ('language','WebGUI::International::get(304,\"WebGUI\");',1,0,'selectList','WebGUI::International::getLanguages()','[\'English\']',1,4,1,1);
INSERT INTO userProfileField VALUES ('homeAddress','WebGUI::International::get(323,\"WebGUI\");',1,0,'text',NULL,NULL,1,5,1,1);
INSERT INTO userProfileField VALUES ('homeCity','WebGUI::International::get(324,\"WebGUI\");',1,0,'text',NULL,NULL,2,5,1,1);
INSERT INTO userProfileField VALUES ('homeState','WebGUI::International::get(325,\"WebGUI\");',1,0,'text',NULL,NULL,3,5,1,1);
INSERT INTO userProfileField VALUES ('homeZip','WebGUI::International::get(326,\"WebGUI\");',1,0,'zipcode',NULL,NULL,4,5,1,1);
INSERT INTO userProfileField VALUES ('homeCountry','WebGUI::International::get(327,\"WebGUI\");',1,0,'text',NULL,NULL,5,5,1,1);
INSERT INTO userProfileField VALUES ('homePhone','WebGUI::International::get(328,\"WebGUI\");',1,0,'phone',NULL,NULL,6,5,1,1);
INSERT INTO userProfileField VALUES ('workAddress','WebGUI::International::get(329,\"WebGUI\");',1,0,'text',NULL,NULL,2,6,1,1);
INSERT INTO userProfileField VALUES ('workCity','WebGUI::International::get(330,\"WebGUI\");',1,0,'text',NULL,NULL,3,6,1,1);
INSERT INTO userProfileField VALUES ('workState','WebGUI::International::get(331,\"WebGUI\");',1,0,'text',NULL,NULL,4,6,1,1);
INSERT INTO userProfileField VALUES ('workZip','WebGUI::International::get(332,\"WebGUI\");',1,0,'zipcode',NULL,NULL,5,6,1,1);
INSERT INTO userProfileField VALUES ('workCountry','WebGUI::International::get(333,\"WebGUI\");',1,0,'text',NULL,NULL,6,6,1,1);
INSERT INTO userProfileField VALUES ('workPhone','WebGUI::International::get(334,\"WebGUI\");',1,0,'phone',NULL,NULL,7,6,1,1);
INSERT INTO userProfileField VALUES ('gender','WebGUI::International::get(335,\"WebGUI\");',1,0,'selectList','{\r\n  \'neuter\'=>WebGUI::International::get(403),\r\n  \'male\'=>WebGUI::International::get(339),\r\n  \'female\'=>WebGUI::International::get(340)\r\n}','[\'neuter\']',1,7,1,1);
INSERT INTO userProfileField VALUES ('birthdate','WebGUI::International::get(336,\"WebGUI\");',1,0,'date',NULL,NULL,2,7,1,1);
INSERT INTO userProfileField VALUES ('homeURL','WebGUI::International::get(337,\"WebGUI\");',1,0,'url',NULL,NULL,7,5,1,1);
INSERT INTO userProfileField VALUES ('workURL','WebGUI::International::get(446,\"WebGUI\");',1,0,'url',NULL,NULL,8,6,1,1);
INSERT INTO userProfileField VALUES ('workName','WebGUI::International::get(450,\"WebGUI\");',1,0,'text',NULL,NULL,1,6,1,1);
INSERT INTO userProfileField VALUES ('timeOffset','WebGUI::International::get(460,\"WebGUI\");',1,0,'text',NULL,'\'0\'',3,4,1,1);
INSERT INTO userProfileField VALUES ('dateFormat','WebGUI::International::get(461,\"WebGUI\");',1,0,'selectList','{\r\n \'%M/%D/%y\'=>WebGUI::DateTime::epochToHuman(\"\",\"%M/%D/%y\"),\r\n \'%y-%m-%d\'=>WebGUI::DateTime::epochToHuman(\"\",\"%y-%m-%d\"),\r\n \'%D-%c-%y\'=>WebGUI::DateTime::epochToHuman(\"\",\"%D-%c-%y\"),\r\n \'%c %D, %y\'=>WebGUI::DateTime::epochToHuman(\"\",\"%c %D, %y\")\r\n}\r\n','[\'%M/%D/%y\']',4,4,1,1);
INSERT INTO userProfileField VALUES ('timeFormat','WebGUI::International::get(462,\"WebGUI\");',1,0,'selectList','{\r\n \'%H:%n %p\'=>WebGUI::DateTime::epochToHuman(\"\",\"%H:%n %p\"),\r\n \'%H:%n:%s %p\'=>WebGUI::DateTime::epochToHuman(\"\",\"%H:%n:%s %p\"),\r\n \'%j:%n\'=>WebGUI::DateTime::epochToHuman(\"\",\"%j:%n\"),\r\n \'%j:%n:%s\'=>WebGUI::DateTime::epochToHuman(\"\",\"%j:%n:%s\")\r\n}\r\n','[\'%H:%n %p\']',5,4,1,1);
INSERT INTO userProfileField VALUES ('discussionLayout','WebGUI::International::get(509)',1,0,'selectList','{\n  threaded=>WebGUI::International::get(511),\n  flat=>WebGUI::International::get(510),\n  nested=>WebGUI::International::get(1045)\n}\n','[\'threaded\']',6,4,0,1);
INSERT INTO userProfileField VALUES ('INBOXNotifications','WebGUI::International::get(518)',1,0,'selectList','{ \r\n  none=>WebGUI::International::get(519),\r\n email=>WebGUI::International::get(520),\r\n  emailToPager=>WebGUI::International::get(521),\r\n  icq=>WebGUI::International::get(522)\r\n}','[\'email\']',7,4,0,1);
INSERT INTO userProfileField VALUES ('firstDayOfWeek','WebGUI::International::get(699,\"WebGUI\");',1,0,'selectList','{0=>WebGUI::International::get(27,\"WebGUI\"),1=>WebGUI::International::get(28,\"WebGUI\")}','[0]',3,4,1,1);
INSERT INTO userProfileField VALUES ('uiLevel','WebGUI::International::get(739,\"WebGUI\");',0,0,'selectList','{\r\n0=>WebGUI::International::get(729,\"WebGUI\"),\r\n1=>WebGUI::International::get(730,\"WebGUI\"),\r\n2=>WebGUI::International::get(731,\"WebGUI\"),\r\n3=>WebGUI::International::get(732,\"WebGUI\"),\r\n4=>WebGUI::International::get(733,\"WebGUI\"),\r\n5=>WebGUI::International::get(734,\"WebGUI\"),\r\n6=>WebGUI::International::get(735,\"WebGUI\"),\r\n7=>WebGUI::International::get(736,\"WebGUI\"),\r\n8=>WebGUI::International::get(737,\"WebGUI\"),\r\n9=>WebGUI::International::get(738,\"WebGUI\")\r\n}','[5]',8,4,1,0);
INSERT INTO userProfileField VALUES ('alias','WebGUI::International::get(858)',1,0,'text','','',4,3,0,1);
INSERT INTO userProfileField VALUES ('signature','WebGUI::International::get(859)',1,0,'HTMLArea','','',5,3,0,1);
INSERT INTO userProfileField VALUES ('publicProfile','WebGUI::International::get(861)',1,0,'yesNo','','1',9,4,0,1);
INSERT INTO userProfileField VALUES ('publicEmail','WebGUI::International::get(860)',1,0,'yesNo','','1',10,4,0,1);
INSERT INTO userProfileField VALUES ('richEditor','WebGUI::International::get(496)',1,0,'selectList','{\r\n1=>WebGUI::International::get(495), #htmlArea\r\n#2=>WebGUI::International::get(494), #editOnPro2\r\n3=>WebGUI::International::get(887), #midas\r\n4=>WebGUI::International::get(879), #classic\r\n5=>WebGUI::International::get(880),\r\nnone=>WebGUI::International::get(881)\r\n}','[1]',11,4,0,1);
INSERT INTO userProfileField VALUES ('richEditorMode','WebGUI::International::get(882)',1,0,'selectList','{\r\ninline=>WebGUI::International::get(883),\r\npopup=>WebGUI::International::get(884)\r\n}','[\'inline\']',12,4,0,1);
INSERT INTO userProfileField VALUES ('toolbar','WebGUI::International::get(746)',0,0,'selectList','WebGUI::Icon::getToolbarOptions()','[\'useLanguageDefault\']',13,4,0,0);

--
-- Table structure for table `userSession`
--

CREATE TABLE userSession (
  sessionId varchar(60) NOT NULL default '',
  expires int(11) default NULL,
  lastPageView int(11) default NULL,
  adminOn int(11) NOT NULL default '0',
  lastIP varchar(50) default NULL,
  userId int(11) default NULL,
  PRIMARY KEY  (sessionId)
) TYPE=MyISAM;

--
-- Dumping data for table `userSession`
--


INSERT INTO userSession VALUES ('53IpegCf7XUGw',1053935988,1053907988,0,'',1);
INSERT INTO userSession VALUES ('97ztu03AFZcic',1053935998,1053907998,0,'',1);
INSERT INTO userSession VALUES ('46ZH2lWWxIb1o',1056507480,1056479480,0,'',1);
INSERT INTO userSession VALUES ('86B3dgfvo8kYc',1066694125,1066666125,0,'',1);
INSERT INTO userSession VALUES ('14OZTAw8AMqos',1069040618,1069012618,0,'',1);
INSERT INTO userSession VALUES ('58qIk5WZvWqVc',1078710434,1078682434,0,'',1);
INSERT INTO userSession VALUES ('65yqW0d/2SYpQ',1083516102,1083512502,0,'',1);
INSERT INTO userSession VALUES ('73c34c7NM4bTI',1085521404,1085517804,0,'',1);
INSERT INTO userSession VALUES ('66Lyi64YHr.82',1089810313,1089806713,0,'',1);

--
-- Table structure for table `userSessionScratch`
--

CREATE TABLE userSessionScratch (
  sessionId varchar(60) default NULL,
  name varchar(255) default NULL,
  value varchar(255) default NULL
) TYPE=MyISAM;

--
-- Dumping data for table `userSessionScratch`
--



--
-- Table structure for table `users`
--

CREATE TABLE users (
  userId int(11) NOT NULL default '0',
  username varchar(100) default NULL,
  authMethod varchar(30) NOT NULL default 'WebGUI',
  dateCreated int(11) NOT NULL default '1019867418',
  lastUpdated int(11) NOT NULL default '1019867418',
  karma int(11) NOT NULL default '0',
  status varchar(35) NOT NULL default 'Active',
  referringAffiliate int(11) NOT NULL default '0',
  PRIMARY KEY  (userId),
  UNIQUE KEY username_unique (username)
) TYPE=MyISAM;

--
-- Dumping data for table `users`
--


INSERT INTO users VALUES (1,'Visitor','WebGUI',1019867418,1019867418,0,'Active',0);
INSERT INTO users VALUES (3,'Admin','WebGUI',1019867418,1019935552,0,'Active',1);

--
-- Table structure for table `webguiVersion`
--

CREATE TABLE webguiVersion (
  webguiVersion varchar(10) default NULL,
  versionType varchar(30) default NULL,
  dateApplied int(11) default NULL
) TYPE=MyISAM;

--
-- Dumping data for table `webguiVersion`
--


INSERT INTO webguiVersion VALUES ('6.1.0','initial install',unix_timestamp());

--
-- Table structure for table `wobject`
--

CREATE TABLE wobject (
  wobjectId int(11) NOT NULL default '0',
  pageId int(11) default NULL,
  namespace varchar(35) default NULL,
  sequenceNumber int(11) NOT NULL default '1',
  title varchar(255) default NULL,
  displayTitle int(11) NOT NULL default '1',
  description mediumtext,
  dateAdded int(11) default NULL,
  addedBy int(11) default NULL,
  lastEdited int(11) default NULL,
  editedBy int(11) default NULL,
  templatePosition int(11) NOT NULL default '1',
  startDate int(11) NOT NULL default '946710000',
  endDate int(11) NOT NULL default '2114406000',
  userDefined1 varchar(255) default NULL,
  userDefined2 varchar(255) default NULL,
  userDefined3 varchar(255) default NULL,
  userDefined4 varchar(255) default NULL,
  userDefined5 varchar(255) default NULL,
  allowDiscussion int(11) NOT NULL default '0',
  bufferUserId int(11) default NULL,
  bufferDate int(11) default NULL,
  bufferPrevId int(11) default NULL,
  templateId int(11) NOT NULL default '1',
  ownerId int(11) NOT NULL default '0',
  groupIdEdit int(11) NOT NULL default '3',
  groupIdView int(11) NOT NULL default '3',
  forumId int(11) default NULL,
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table `wobject`
--


INSERT INTO wobject VALUES (-1,4,'SiteMap',0,'Page Not Found',1,'The page you were looking for could not be found on this system. Perhaps it has been deleted or renamed. The following list is a site map of this site. If you don\'t find what you\'re looking for on the site map, you can always start from the <a href=\"^/;\">Home Page</a>.',1001744792,3,1016077239,3,1,1001744792,1336444487,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,2,3,3,7,1003);
INSERT INTO wobject VALUES (1,1,'Article',1,'Welcome',1,'Welcome to WebGUI. This is web done right.\n<br /><br />\nWebGUI is a user-friendly web site management system made by <a href=\"http://www.plainblack.com\">Plain Black</a>. It is designed to be easy to use for the average business user, but powerful enough to satisfy the needs of a large enterprise.\n<br /><br />\nThere are thousands of <a href=\"http://www.adinknetwork.com\" target=\"_blank\">small</a> and <a href=\"http://www.brunswickbowling.com\" target=\"_blank\">large</a> businesses, <a href=\"http://www.troy30c.org\" target=\"_blank\">schools</a>, <a href=\"http://goaggies.cameron.edu/\" target=\"_blank\">universities</a>, <a href=\"http://www.lambtononline.ca/\" target=\"_blank\">governments</a>, <a href=\"http://www.hetnieuweland.nl/\" target=\"_blank\">clubs</a>, <a href=\"http://www.k3b.org\" target=\"_blank\">projects</a>, <a href=\"http://www.cmsmatrix.org\" target=\"_blank\">communities</a>, and <a href=\"http://www.primaat.com\" target=\"_blank\">individuals</a> using WebGUI all over the world today. A brief list of some of them can be found <a href=\"http://www.plainblack.com/examples\">here</a>. There\'s no reason your site shouldn\'t be on that list.<br /><br />',1076701903,3,1076707751,3,1,946710000,2082783600,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,1,3,3,7,1005);
INSERT INTO wobject VALUES (2,1,'Article',2,'Key Benefits',1,'<img src=\"^Extras;styles/webgui6/img_hands.jpg\" style=\"position: relative;\" align=\"right\" />\n<style>\ndt {\n font-weight: bold;\n}\n</style>\n\n<dl>\n\n<dt>Easy to Use</dt>\n<dd>If you can use a web browser, then you can manage a web site with WebGUI. WebGUI\'s unique WYSIWYG inline content editing interface ensures that you know where you are and what your content will look like while you\'re editing. In addition, you don\'t need to install and learn any complicated programs, you can edit everything with your trusty web browser.</dd>\n<br />\n\n<dt>Flexible Designs</dt>\n<dd>WebGUI\'s powerful templating system ensures that no two WebGUI sites ever need to look the same. You\'re not restricted in how your content is laid out or how your navigation functions.</dd>\n<br />\n\n<dt>Work Faster</dt>\n<dd>Though there is some pretty cool technology behind the scenes that makes WebGUI work, our first concern has always been usability and not technology. After all if it\'s not useful, why use it? With that in mind WebGUI has all kinds of wizards, short cuts, online help, and other aids to help you work faster.</dd>\n<br />\n\n<dt>Localized Content</dt>\n<dd>With WebGUI there\'s no need to limit yourself to one language or timezone. It\'s a snap to build a multi-lingual site with WebGUI. In fact, even WebGUI\'s built in functions and online help have been translated to more than 15 languages. User\'s can also adjust their local settings for dates, times, and other localized oddities. </dd>\n<br />\n\n<dt>Pluggable By Design</dt>\n<dd>When <a href=\"http://www.plainblack.com\">Plain Black</a> created WebGUI we knew we wouldn\'t be able to think of everything you want to use WebGUI for, so we made most of WebGUI\'s functions pluggable. This allows you to add new features to WebGUI and still be able to upgrade the core system without a fuss.</dd>\n\n</dl>',1076702850,3,1076707868,3,1,946710000,2082783600,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,1,3,3,7,1007);
INSERT INTO wobject VALUES (3,1000,'Article',1,'Getting Started',0,'If you\'re reading this message it means that you\'ve got WebGUI up and running. Good job! The installation is not trivial.\n\n<p/>\n \nIn order to do anything useful with your new installation you\'ll need to log in as the default administrator account. Follow these steps to get started:\n\n<p/>\n\n<ol>\n<li><a href=\"^a(linkonly);\">Click here to log in.</a> (username: Admin password: 123qwe)\n<li><a href=\"^\\;?op=switchOnAdmin\">Click here to turn the administrative interface on.</a>\n</ol>\n<blockquote style=\"font-size: 10px;\">\n<b>NOTE:</b> You could have also done these steps using the block at the top of this page.\n</blockquote>\n\n<p/>\n\nNow that you\'re in as the administrator, you should <a href=\"^a(linkonly);\">change your password</a> so no one else can log in and mess with your site. You might also want to <a href=\"^\\;?op=listUsers\">create another account</a> for yourself with Administrative privileges in case you can\'t log in with the Admin account for some reason.\n\n<p/>\n \nYou\'ll now notice little buttons and menus on all the pages in your site. These controls help you administer your site. The \"Add content\" menu lets you add new content to your pages as well as paste content from the clipboard. The \"Administrative functions\" menu let\'s you control users and groups as well as many other admin settings. The little toolbars help you manipulate the content in your pages.\n\n\n<p/>\n\nFor more information about how to administer <a href=\"http://www.plainblack.com/webgui\">WebGUI</a> consider getting a copy of <a href=\"http://www.plainblack.com/ruling_webgui\">Ruling WebGUI</a>. <a href=\"http://www.plainblack.com\">Plain Black Software</a> also provides several <a href=\"http://www.plainblack.com/support_programs\">Support Programs</a> for WebGUI if you run into trouble.\n\n<p/>\n \nEnjoy your new WebGUI site!',1076704456,3,1076704456,3,1,946710000,2082783600,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,1,3,3,7,1009);
INSERT INTO wobject VALUES (5,1001,'USS',2,'Your Next Step',0,' To learn more about WebGUI and how you can best implement WebGUI in your organization, please see the choices below.\n\n',1076705448,3,1076706084,3,1,946710000,2082783600,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,1000,3,3,7,NULL);
INSERT INTO wobject VALUES (6,1002,'SyndicatedContent',1,'The Latest News',0,'This is the latest news from Plain Black and WebGUI pulled directly from the site every hour.',1076708567,3,1076709040,3,1,946710000,2082783600,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,1000,3,3,7,NULL);
INSERT INTO wobject VALUES (7,1003,'DataForm',1,'Tell A Friend',0,'Tell a friend about WebGUI.',1076709292,3,1076709522,3,1,946710000,2082783600,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,1,3,3,7,NULL);
INSERT INTO wobject VALUES (8,1004,'SiteMap',0,'Site Map',0,'',1001744792,3,1016077239,3,1,1001744792,1336444487,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,2,3,3,7,NULL);

