-- MySQL dump 8.23
--
-- Host: localhost    Database: dev
---------------------------------------------------------
-- Server version	3.23.58

--
-- Table structure for table `Article`
--

CREATE TABLE Article (
  linkTitle varchar(255) default NULL,
  linkURL text,
  convertCarriageReturns int(11) NOT NULL default '0',
  assetId varchar(22) NOT NULL default '',
  templateId varchar(22) NOT NULL default '',
  PRIMARY KEY  (assetId)
) TYPE=MyISAM;

--
-- Dumping data for table `Article`
--


INSERT INTO Article VALUES ('','',0,'TKzUMeIxRLrZ3NAEez6CXQ','PBtmpl0000000000000002');
INSERT INTO Article VALUES ('','',0,'sWVXMZGibxHe2Ekj1DCldA','PBtmpl0000000000000002');
INSERT INTO Article VALUES ('','',0,'x_WjMvFmilhX-jvZuIpinw','PBtmpl0000000000000002');

--
-- Table structure for table `Collaboration`
--

CREATE TABLE Collaboration (
  assetId varchar(22) NOT NULL default '',
  postGroupId varchar(22) NOT NULL default '2',
  moderateGroupId varchar(22) NOT NULL default '4',
  moderatePosts int(11) NOT NULL default '0',
  karmaPerPost int(11) NOT NULL default '0',
  collaborationTemplateId varchar(22) NOT NULL default '',
  threadTemplateId varchar(22) NOT NULL default '',
  postFormTemplateId varchar(22) NOT NULL default '',
  searchTemplateId varchar(22) NOT NULL default '',
  notificationTemplateId varchar(22) NOT NULL default '',
  sortBy varchar(35) NOT NULL default 'dateUpdated',
  sortOrder varchar(4) NOT NULL default 'desc',
  usePreview int(11) NOT NULL default '1',
  addEditStampToPosts int(11) NOT NULL default '0',
  editTimeout int(11) NOT NULL default '3600',
  attachmentsPerPost int(11) NOT NULL default '0',
  allowRichEdit int(11) NOT NULL default '1',
  filterCode varchar(30) NOT NULL default 'javascript',
  useContentFilter int(11) NOT NULL default '1',
  threads int(11) NOT NULL default '0',
  views int(11) NOT NULL default '0',
  replies int(11) NOT NULL default '0',
  rating int(11) NOT NULL default '0',
  lastPostId varchar(22) default NULL,
  lastPostDate bigint(20) default NULL,
  archiveAfter int(11) NOT NULL default '31536000',
  postsPerPage int(11) NOT NULL default '10',
  threadsPerPage int(11) NOT NULL default '30',
  subscriptionGroupId varchar(22) default NULL,
  allowReplies int(11) NOT NULL default '0',
  displayLastReply int(11) NOT NULL default '0',
  PRIMARY KEY  (assetId)
) TYPE=MyISAM;

--
-- Dumping data for table `Collaboration`
--


INSERT INTO Collaboration VALUES ('DC1etlIaBRQitXnchZKvUw','3','4',0,0,'wCIc38CvNHUK7aY92Ww4SQ','PBtmpl0000000000000067','PBtmpl0000000000000114','PBtmpl0000000000000031','PBtmpl0000000000000027','lineage','asc',0,0,931536000,2,1,'none',0,5,2,0,0,NULL,NULL,31536000,10,1000,'a7jbpVdbzxchqtSj_9W71w',0,0);

--
-- Table structure for table `DataForm`
--

CREATE TABLE DataForm (
  acknowledgement text,
  mailData int(11) NOT NULL default '1',
  emailTemplateId varchar(22) default NULL,
  acknowlegementTemplateId varchar(22) default NULL,
  listTemplateId varchar(22) default NULL,
  assetId varchar(22) NOT NULL default '',
  templateId varchar(22) NOT NULL default '',
  PRIMARY KEY  (assetId)
) TYPE=MyISAM;

--
-- Dumping data for table `DataForm`
--


INSERT INTO DataForm VALUES ('Thank you for telling your friends about WebGUI!',1,'PBtmpl0000000000000085','PBtmpl0000000000000104','PBtmpl0000000000000021','Szs5eev3OMssmnsyLRZmWA','PBtmpl0000000000000020');

--
-- Table structure for table `DataForm_entry`
--

CREATE TABLE DataForm_entry (
  DataForm_entryId varchar(22) NOT NULL default '',
  userId varchar(22) default NULL,
  username varchar(255) default NULL,
  ipAddress varchar(255) default NULL,
  submissionDate int(11) NOT NULL default '0',
  assetId varchar(22) default NULL,
  PRIMARY KEY  (DataForm_entryId)
) TYPE=MyISAM;

--
-- Dumping data for table `DataForm_entry`
--



--
-- Table structure for table `DataForm_entryData`
--

CREATE TABLE DataForm_entryData (
  DataForm_entryId varchar(22) NOT NULL default '',
  DataForm_fieldId varchar(22) NOT NULL default '',
  value text,
  assetId varchar(22) default NULL,
  PRIMARY KEY  (DataForm_entryId,DataForm_fieldId)
) TYPE=MyISAM;

--
-- Dumping data for table `DataForm_entryData`
--



--
-- Table structure for table `DataForm_field`
--

CREATE TABLE DataForm_field (
  DataForm_fieldId varchar(22) NOT NULL default '',
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
  DataForm_tabId varchar(22) NOT NULL default '0',
  vertical smallint(1) default '1',
  extras varchar(128) default NULL,
  assetId varchar(22) default NULL,
  PRIMARY KEY  (DataForm_fieldId)
) TYPE=MyISAM;

--
-- Dumping data for table `DataForm_field`
--


INSERT INTO DataForm_field VALUES ('1000',1,'from','required','email','','',0,'',0,1,'Your Email Address','0',1,NULL,'Szs5eev3OMssmnsyLRZmWA');
INSERT INTO DataForm_field VALUES ('1001',2,'to','required','email','','',0,'',0,1,'Your Friends Email Address','0',1,NULL,'Szs5eev3OMssmnsyLRZmWA');
INSERT INTO DataForm_field VALUES ('1002',3,'cc','hidden','email',NULL,NULL,0,NULL,NULL,1,'Cc','0',1,NULL,'Szs5eev3OMssmnsyLRZmWA');
INSERT INTO DataForm_field VALUES ('1003',4,'bcc','hidden','email',NULL,NULL,0,NULL,NULL,1,'Bcc','0',1,NULL,'Szs5eev3OMssmnsyLRZmWA');
INSERT INTO DataForm_field VALUES ('1004',5,'subject','hidden','text','','Cool CMS',0,'',0,1,'Subject','0',1,NULL,'Szs5eev3OMssmnsyLRZmWA');
INSERT INTO DataForm_field VALUES ('1005',6,'url','visible','url','','http://www.plainblack.com/webgui',0,'',0,1,'URL','0',1,NULL,'Szs5eev3OMssmnsyLRZmWA');
INSERT INTO DataForm_field VALUES ('1006',7,'message','required','textarea','','Hey I just wanted to tell you about this great program called WebGUI that I found: http://www.plainblack.com/webgui\r\n\r\nYou should really check it out.',34,'',6,0,'Message','0',1,NULL,'Szs5eev3OMssmnsyLRZmWA');

--
-- Table structure for table `DataForm_tab`
--

CREATE TABLE DataForm_tab (
  label varchar(255) NOT NULL default '',
  subtext text,
  sequenceNumber int(11) NOT NULL default '0',
  DataForm_tabId varchar(22) NOT NULL default '',
  assetId varchar(22) default NULL
) TYPE=MyISAM;

--
-- Dumping data for table `DataForm_tab`
--



--
-- Table structure for table `EventsCalendar`
--

CREATE TABLE EventsCalendar (
  calendarLayout varchar(30) NOT NULL default 'list',
  paginateAfter int(11) NOT NULL default '50',
  startMonth varchar(35) NOT NULL default 'current',
  endMonth varchar(35) NOT NULL default 'after12',
  defaultMonth varchar(35) NOT NULL default 'current',
  eventTemplateId varchar(22) default NULL,
  scope int(11) NOT NULL default '0',
  assetId varchar(22) NOT NULL default '',
  templateId varchar(22) NOT NULL default '',
  PRIMARY KEY  (assetId)
) TYPE=MyISAM;

--
-- Dumping data for table `EventsCalendar`
--



--
-- Table structure for table `EventsCalendar_event`
--

CREATE TABLE EventsCalendar_event (
  description text,
  eventStartDate bigint(20) default NULL,
  eventEndDate bigint(20) default NULL,
  EventsCalendar_recurringId varchar(22) default NULL,
  eventLocation text,
  templateId varchar(22) default NULL,
  assetId varchar(22) NOT NULL default '',
  PRIMARY KEY  (assetId),
  KEY EventsCalendar1 (eventEndDate,eventStartDate)
) TYPE=MyISAM;

--
-- Dumping data for table `EventsCalendar_event`
--



--
-- Table structure for table `FileAsset`
--

CREATE TABLE FileAsset (
  assetId varchar(22) NOT NULL default '',
  storageId varchar(22) NOT NULL default '',
  filename varchar(255) NOT NULL default '',
  olderVersions text,
  PRIMARY KEY  (assetId)
) TYPE=MyISAM;

--
-- Dumping data for table `FileAsset`
--



--
-- Table structure for table `Folder`
--

CREATE TABLE Folder (
  assetId varchar(22) NOT NULL default '',
  templateId varchar(22) NOT NULL default '',
  PRIMARY KEY  (assetId)
) TYPE=MyISAM;

--
-- Dumping data for table `Folder`
--


INSERT INTO Folder VALUES ('PBasset000000000000002','PBtmpl0000000000000078');
INSERT INTO Folder VALUES ('Wmjn6I1fe9DKhiIR39YC0g','PBtmpl0000000000000078');
INSERT INTO Folder VALUES ('UE5_3bD7kWDLUN2B-iuNuA','PBtmpl0000000000000078');
INSERT INTO Folder VALUES ('RTsbVBEYnn3OPZWmXyIFhQ','PBtmpl0000000000000078');

--
-- Table structure for table `HttpProxy`
--

CREATE TABLE HttpProxy (
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
  cookieJarStorageId varchar(22) default NULL,
  assetId varchar(22) NOT NULL default '',
  templateId varchar(22) NOT NULL default '',
  PRIMARY KEY  (assetId)
) TYPE=MyISAM;

--
-- Dumping data for table `HttpProxy`
--



--
-- Table structure for table `ITransact_recurringStatus`
--

CREATE TABLE ITransact_recurringStatus (
  gatewayId varchar(128) NOT NULL default '',
  initDate int(11) NOT NULL default '0',
  lastTransaction int(11) NOT NULL default '0',
  status varchar(10) NOT NULL default '',
  errorMessage varchar(128) default NULL,
  recipe varchar(15) NOT NULL default '',
  PRIMARY KEY  (gatewayId)
) TYPE=MyISAM;

--
-- Dumping data for table `ITransact_recurringStatus`
--



--
-- Table structure for table `ImageAsset`
--

CREATE TABLE ImageAsset (
  assetId varchar(22) NOT NULL default '',
  thumbnailSize int(11) NOT NULL default '50',
  parameters text,
  PRIMARY KEY  (assetId)
) TYPE=MyISAM;

--
-- Dumping data for table `ImageAsset`
--



--
-- Table structure for table `IndexedSearch`
--

CREATE TABLE IndexedSearch (
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
  forceSearchRoots smallint(1) default '1',
  linkURL text,
  assetId varchar(22) NOT NULL default '',
  templateId varchar(22) NOT NULL default '',
  PRIMARY KEY  (assetId)
) TYPE=MyISAM;

--
-- Dumping data for table `IndexedSearch`
--



--
-- Table structure for table `IndexedSearch_default`
--

CREATE TABLE IndexedSearch_default (
  param varchar(16) binary NOT NULL default '',
  value varchar(255) default NULL,
  PRIMARY KEY  (param)
) TYPE=MyISAM;

--
-- Dumping data for table `IndexedSearch_default`
--


INSERT INTO IndexedSearch_default VALUES ('','');
INSERT INTO IndexedSearch_default VALUES ('protocol','40');
INSERT INTO IndexedSearch_default VALUES ('num_of_docs','0');
INSERT INTO IndexedSearch_default VALUES ('frontend','none');
INSERT INTO IndexedSearch_default VALUES ('backend','phrase');
INSERT INTO IndexedSearch_default VALUES ('table','IndexedSearch_default');
INSERT INTO IndexedSearch_default VALUES ('index_splitter','/(\\w{2,$word_length})/g');
INSERT INTO IndexedSearch_default VALUES ('word_id_table','IndexedSearch_default_words');
INSERT INTO IndexedSearch_default VALUES ('count_bits','8');
INSERT INTO IndexedSearch_default VALUES ('search_splitter','/(\\w{2,$word_length}\\*?)/g');
INSERT INTO IndexedSearch_default VALUES ('data_table','IndexedSearch_default_data');
INSERT INTO IndexedSearch_default VALUES ('name_length','255');
INSERT INTO IndexedSearch_default VALUES ('position_bits','32');
INSERT INTO IndexedSearch_default VALUES ('blob_direct_fetc','20');
INSERT INTO IndexedSearch_default VALUES ('filter','map { lc $_ if ($_ !~ /\\^.*;/) }');
INSERT INTO IndexedSearch_default VALUES ('doc_id_bits','16');
INSERT INTO IndexedSearch_default VALUES ('init_env','');
INSERT INTO IndexedSearch_default VALUES ('stemmer',NULL);
INSERT INTO IndexedSearch_default VALUES ('word_length','20');
INSERT INTO IndexedSearch_default VALUES ('stoplist',NULL);
INSERT INTO IndexedSearch_default VALUES ('word_id_bits','16');
INSERT INTO IndexedSearch_default VALUES ('max_doc_id','10');

--
-- Table structure for table `IndexedSearch_default_data`
--

CREATE TABLE IndexedSearch_default_data (
  word_id smallint(5) unsigned NOT NULL default '0',
  doc_id smallint(5) unsigned NOT NULL default '0',
  idx longblob NOT NULL,
  KEY word_id (word_id),
  KEY doc_id (doc_id)
) TYPE=MyISAM;

--
-- Dumping data for table `IndexedSearch_default_data`
--


INSERT INTO IndexedSearch_default_data VALUES (1,1,'Y\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (2,1,'<\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (3,1,':\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (4,1,'X\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (5,1,'$\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (6,1,'H\0\0\0Z\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (7,1,'S\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (8,1,'L\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (9,1,'?\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (10,1,'\0\0\0\r\0\0\0A\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (11,1,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (12,1,'T\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (13,1,';\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (14,1,'J\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (15,1,'&\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (16,1,'5\0\0\0>\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (17,1,'\0\0\0\0\0\0\0\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (18,1,'P\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (19,1,'4\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (20,1,'C\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (21,1,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (22,1,'-\0\0\03\0\0\0I\0\0\0K\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (23,1,'O\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (24,1,'G\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (25,1,'B\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (26,1,'	\0\0\0\0\0\0\Z\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (27,1,'\n\0\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (28,1,'\0\0\0\0\0\0\0\0\0)\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (29,1,'\'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (30,1,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (31,1,'7\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (32,1,'/\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (33,1,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (34,1,'M\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (35,1,'@\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (36,1,'.\0\0\06\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (37,1,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (38,1,'F\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (39,1,'\0\0\0U\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (40,1,'#\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (41,1,'8\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (42,1,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (43,1,'\"\0\0\0+\0\0\0D\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (44,1,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (45,1,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (46,1,'R\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (47,1,'\0\0\0%\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (48,1,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (49,1,'!\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (50,1,'(\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (51,1,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (52,1,'\0\0\0N\0\0\0W\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (53,1,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (54,1,'9\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (55,1,',\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (56,1,'2\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (57,1,'*\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (58,1,'E\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (59,1,'1\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (60,1,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (61,1,' \0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (62,1,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (63,1,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (64,1,'0\0\0\0Q\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (65,1,'=\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (66,1,'V\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (67,2,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (68,2,'\0\0');
INSERT INTO IndexedSearch_default_data VALUES (69,2,'\0\0\0\0\0\0%\0\0\0(\0\0\02\0\0\07\0\0\0A\0\0\0\\\0\0\0¢\0\0\0Ô\0\0\0ˇ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (70,2,'S\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (71,2,'\0\0\0à\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (72,2,'\0\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (73,2,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (74,2,'y\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (75,2,'!\0\0\04\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (76,2,'—\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (77,2,'Ä\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (78,2,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (79,2,'+\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (80,2,';\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (81,2,'ü\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (10,2,'\0\0\0\0\0\0L\0\0\0T\0\0\0z\0\0\0ì\0\0\0®\0\0\0º\0\0\0¿\0\0\0‰\0\0\0Û\0\0\0˙\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (82,2,'k\0\0\0√\0\0\0˚\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (12,2,',\0\0\0F\0\0\0b\0\0\0i\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (83,2,'“\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (84,2,'t\0\0\0Ö\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (85,2,'π\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (16,2,'*\0\0\0<\0\0\0É\0\0\0ù\0\0\0ƒ\0\0\0Ÿ\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (86,2,'n\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (87,2,'=\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (21,2,'O\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (22,2,'ó\0\0\0Ì\0\0\0˘\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (88,2,'\0\0');
INSERT INTO IndexedSearch_default_data VALUES (25,2,'á\0\0\0ï\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (26,2,'d\0\0\0p\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (89,2,'«\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (90,2,'@\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (91,2,'.\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (92,2,'Ï\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (29,2,'M\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (93,2,'G\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (94,2,'‡\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (33,2,'â\0\0\0é\0\0\0¥\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (95,2,'\n\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (96,2,'∑\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (34,2,'\0\0\0\0\0\0B\0\0\0–\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (97,2,'Õ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (98,2,'õ\0\0\0≈\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (99,2,'\'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (100,2,'Æ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (101,2,'◊\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (102,2,'æ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (46,2,'R\0\0\0™\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (103,2,'_\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (104,2,'0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (105,2,'Ë\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (106,2,'5\0\0\0`\0\0\0ë\0\0\0Ω\0\0\0¬\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (47,2,'œ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (107,2,'	\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (108,2,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (109,2,'Ê\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (110,2,'3\0\0\0]\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (111,2,'6\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (51,2,'ﬁ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (112,2,'í\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (113,2,'\0\0');
INSERT INTO IndexedSearch_default_data VALUES (114,2,'#\0\0\0P\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (115,2,'[\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (116,2,'s\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (117,2,'Ü\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (118,2,'Œ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (119,2,'≠\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (120,2,'J\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (121,2,'•\0\0\0€\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (122,2,'\0\0');
INSERT INTO IndexedSearch_default_data VALUES (123,2,'e\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (124,2,'8\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (125,2,'„\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (64,2,'o\0\0\0©\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (126,2,'j\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (63,2,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (127,2,'1\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (128,2,'å\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (129,2,'‹\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (130,2,'&\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (131,2,' \0\0\0-\0\0\0c\0\0\0¶\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (132,2,'\0\0\0î\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (1,2,'$\0\0\0Q\0\0\0x\0\0\0ê\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (133,2,'^\0\0\0Ñ\0\0\0ä\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (134,2,'˛\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (135,2,'|\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (136,2,'f\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (137,2,'≥\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (11,2,'‚\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (138,2,'∞\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (14,2,'q\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (139,2,'\Z\0\0\0E\0\0\0è\0\0\0ß\0\0\0ª\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (140,2,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (141,2,'u\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (142,2,'\r\0\0');
INSERT INTO IndexedSearch_default_data VALUES (143,2,'w\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (144,2,'ö\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (145,2,'Â\0\0\0Á\0\0\0ˆ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (146,2,'C\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (147,2,'‘\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (148,2,'ﬂ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (27,2,'\0\0\0\0\0\0H\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (149,2,'ò\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (28,2,'\0\0\0:\0\0\0X\0\0\0†\0\0\0¨\0\0\0Ø\0\0\0∂\0\0\0 \0\0\0Î\0\0\0Ò\0\0\0\0\0\0\0\0\n\0\0');
INSERT INTO IndexedSearch_default_data VALUES (30,2,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (150,2,'Í\0\0\0	\0\0');
INSERT INTO IndexedSearch_default_data VALUES (151,2,'±\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (152,2,'>\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (153,2,'l\0\0\0{\0\0\0£\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (154,2,'~\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (39,2,'\0\0\0∫\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (155,2,'r\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (156,2,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (157,2,'ÿ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (158,2,'À\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (42,2,'˜\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (43,2,'Z\0\0\0v\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (159,2,'\0\0\0I\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (160,2,'9\0\0\0W\0\0\0´\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (161,2,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (162,2,'m\0\0\0§\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (163,2,'ã\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (164,2,'g\0\0\0≤\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (165,2,'\"\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (166,2,'\0\0');
INSERT INTO IndexedSearch_default_data VALUES (167,2,'\0\0');
INSERT INTO IndexedSearch_default_data VALUES (48,2,'˝\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (168,2,'ı\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (169,2,'U\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (170,2,'¡\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (171,2,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (49,2,'÷\0\0\0Ù\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (172,2,'a\0\0\0h\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (173,2,'…\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (174,2,'K\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (175,2,'D\0\0\0Ó\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (52,2,'È\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (176,2,'û\0\0\0⁄\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (177,2,'”\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (178,2,'µ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (179,2,'V\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (180,2,'¯\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (181,2,'\0\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (182,2,'ø\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (183,2,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (184,2,'?\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (59,2,')\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (185,2,'›\0\0\0¸\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (186,2,'/\0\0\0Y\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (187,2,'Ç\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (188,2,'ô\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (60,2,'·\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (61,2,'\r\0\0\0\0\0\0ç\0\0\0Ú\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (189,2,'Å\0\0\0»\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (190,2,'ú\0\0\0°\0\0\0∆\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (191,2,'}\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (192,2,'N\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (193,2,'\0\0');
INSERT INTO IndexedSearch_default_data VALUES (194,2,'Ã\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (195,2,'’\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (196,2,'∏\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (197,2,'ñ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (67,3,'w\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (198,3,'4\0\0\0P\0\0\0ù\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (69,3,'\0\0\0\0\0\0(\0\0\0K\0\0\0]\0\0\0c\0\0\0t\0\0\0É\0\0\0é\0\0\0†\0\0\0©\0\0\0Ω\0\0\0Õ\0\0\0Ì\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (199,3,'z\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (200,3,'≈\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (71,3,'\0\0\0Ï\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (201,3,'@\0\0\0g\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (202,3,'û\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (76,3,'N\0\0\0v\0\0\0Â\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (203,3,')\0\0\0è\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (204,3,'®\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (10,3,'\0\0\0€\0\0\0·\0\0\0Î\0\0\0Ù\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (82,3,'∫\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (12,3,'%\0\0\0f\0\0\0r\0\0\0õ\0\0\0¢\0\0\0Æ\0\0\0“\0\0\0Ú\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (16,3,'\0\0\0o\0\0\0î\0\0\0¿\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (205,3,'5\0\0\0Q\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (206,3,'3\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (207,3,'Á\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (208,3,'Ä\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (22,3,'X\0\0\0ﬂ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (209,3,'ø\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (25,3,'ó\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (210,3,'ï\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (26,3,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (90,3,'È\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (89,3,'M\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (211,3,'p\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (33,3,'\r\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (34,3,'l\0\0\0Ñ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (212,3,'9\0\0\0B\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (213,3,'\n\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (214,3,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (100,3,'}\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (46,3,'i\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (215,3,'ﬁ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (216,3,'E\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (217,3,'1\0\0\0b\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (218,3,'u\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (219,3,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (220,3,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (106,3,'\0\0\0-\0\0\0=\0\0\0_\0\0\0n\0\0\0Å\0\0\0Ü\0\0\0ö\0\0\0—\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (221,3,'?\0\0\0â\0\0\0«\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (222,3,'Ò\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (223,3,'\"\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (110,3,'	\0\0\0^\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (224,3,'G\0\0\0\0\0\0π\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (225,3,'ì\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (226,3,'Ë\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (113,3,'•\0\0\0™\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (227,3,'Ó\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (228,3,'À\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (229,3,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (230,3,'7\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (231,3,'æ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (232,3,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (233,3,'\0\0\0\0\0\0›\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (234,3,'J\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (235,3,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (236,3,'±\0\0\0√\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (237,3,'‰\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (238,3,'.\0\0\0`\0\0\0∞\0\0\0≤\0\0\0¬\0\0\0ƒ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (239,3,'T\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (240,3,'\0\0\0\0\0\08\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (241,3,'∑\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (131,3,'¶\0\0\0¨\0\0\0¥\0\0\0–\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (133,3,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (1,3,'\0\0\0\\\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (242,3,'‹\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (4,3,'I\0\0\0ñ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (243,3,'‡\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (244,3,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (245,3,'e\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (7,3,'ç\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (246,3,'>\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (247,3,'Ê\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (11,3,'„\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (138,3,'j\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (248,3,'W\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (14,3,'å\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (139,3,'$\0\0\0q\0\0\0~\0\0\0á\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (249,3,'ô\0\0\0Ø\0\0\0”\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (18,3,':\0\0\0C\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (250,3,'!\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (251,3,'Ô\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (252,3,'Ç\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (253,3,'\Z\0\0\0\'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (254,3,'ë\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (28,3,' \0\0\0+\0\0\06\0\0\0;\0\0\0D\0\0\0x\0\0\0≠\0\0\0Ÿ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (255,3,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (256,3,'µ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (257,3,'y\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (258,3,'2\0\0\0{\0\0\0ä\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (259,3,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (35,3,'R\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (260,3,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (261,3,'í\0\0\0 \0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (39,3,'s\0\0\0ú\0\0\0£\0\0\0ı\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (262,3,'[\0\0\0ê\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (158,3,'’\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (43,3,'\0\0\0/\0\0\0F\0\0\0S\0\0\0V\0\0\0a\0\0\0à\0\0\0ò\0\0\0§\0\0\0∂\0\0\0∏\0\0\0…\0\0\0œ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (44,3,'O\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (263,3,'Z\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (264,3,'≥\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (160,3,'*\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (163,3,'#\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (265,3,'\0\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (266,3,'º\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (267,3,'L\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (268,3,'¡\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (165,3,'H\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (269,3,'◊\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (167,3,'&\0\0\0´\0\0\0Û\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (48,3,'\0\0\0Y\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (168,3,'h\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (172,3,'ÿ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (49,3,'|\0\0\0ã\0\0\0‘\0\0\0Í\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (270,3,'k\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (271,3,'0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (176,3,'∆\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (272,3,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (273,3,'A\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (60,3,'‚\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (190,3,'ü\0\0\0Ã\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (274,3,'d\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (275,3,'U\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (276,3,',\0\0\0<\0\0\0m\0\0\0Ö\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (277,3,'÷\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (278,3,'ß\0\0\0ª\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (279,3,'Œ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (195,3,'»\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (280,3,'°\0\0\0⁄\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (281,4,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (12,4,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (282,4,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (281,5,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (12,5,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (282,5,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (283,5,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (284,6,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (285,7,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (286,8,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (287,9,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (235,10,'\0\0\0');

--
-- Table structure for table `IndexedSearch_default_words`
--

CREATE TABLE IndexedSearch_default_words (
  word varchar(20) binary NOT NULL default '',
  id smallint(5) unsigned NOT NULL auto_increment,
  PRIMARY KEY  (id),
  UNIQUE KEY word (word)
) TYPE=MyISAM;

--
-- Dumping data for table `IndexedSearch_default_words`
--


INSERT INTO IndexedSearch_default_words VALUES ('that',1);
INSERT INTO IndexedSearch_default_words VALUES ('projects',2);
INSERT INTO IndexedSearch_default_words VALUES ('governments',3);
INSERT INTO IndexedSearch_default_words VALUES ('on',4);
INSERT INTO IndexedSearch_default_words VALUES ('business',5);
INSERT INTO IndexedSearch_default_words VALUES ('list',6);
INSERT INTO IndexedSearch_default_words VALUES ('reason',7);
INSERT INTO IndexedSearch_default_words VALUES ('them',8);
INSERT INTO IndexedSearch_default_words VALUES ('individuals',9);
INSERT INTO IndexedSearch_default_words VALUES ('webgui',10);
INSERT INTO IndexedSearch_default_words VALUES ('black',11);
INSERT INTO IndexedSearch_default_words VALUES ('your',12);
INSERT INTO IndexedSearch_default_words VALUES ('clubs',13);
INSERT INTO IndexedSearch_default_words VALUES ('some',14);
INSERT INTO IndexedSearch_default_words VALUES ('but',15);
INSERT INTO IndexedSearch_default_words VALUES ('and',16);
INSERT INTO IndexedSearch_default_words VALUES ('welcome',17);
INSERT INTO IndexedSearch_default_words VALUES ('here',18);
INSERT INTO IndexedSearch_default_words VALUES ('small',19);
INSERT INTO IndexedSearch_default_words VALUES ('over',20);
INSERT INTO IndexedSearch_default_words VALUES ('system',21);
INSERT INTO IndexedSearch_default_words VALUES ('of',22);
INSERT INTO IndexedSearch_default_words VALUES ('found',23);
INSERT INTO IndexedSearch_default_words VALUES ('brief',24);
INSERT INTO IndexedSearch_default_words VALUES ('all',25);
INSERT INTO IndexedSearch_default_words VALUES ('is',26);
INSERT INTO IndexedSearch_default_words VALUES ('web',27);
INSERT INTO IndexedSearch_default_words VALUES ('to',28);
INSERT INTO IndexedSearch_default_words VALUES ('powerful',29);
INSERT INTO IndexedSearch_default_words VALUES ('home',30);
INSERT INTO IndexedSearch_default_words VALUES ('businesses',31);
INSERT INTO IndexedSearch_default_words VALUES ('enterprise',32);
INSERT INTO IndexedSearch_default_words VALUES ('it',33);
INSERT INTO IndexedSearch_default_words VALUES ('can',34);
INSERT INTO IndexedSearch_default_words VALUES ('using',35);
INSERT INTO IndexedSearch_default_words VALUES ('large',36);
INSERT INTO IndexedSearch_default_words VALUES ('right',37);
INSERT INTO IndexedSearch_default_words VALUES ('today',38);
INSERT INTO IndexedSearch_default_words VALUES ('site',39);
INSERT INTO IndexedSearch_default_words VALUES ('average',40);
INSERT INTO IndexedSearch_default_words VALUES ('schools',41);
INSERT INTO IndexedSearch_default_words VALUES ('made',42);
INSERT INTO IndexedSearch_default_words VALUES ('the',43);
INSERT INTO IndexedSearch_default_words VALUES ('done',44);
INSERT INTO IndexedSearch_default_words VALUES ('designed',45);
INSERT INTO IndexedSearch_default_words VALUES ('no',46);
INSERT INTO IndexedSearch_default_words VALUES ('user',47);
INSERT INTO IndexedSearch_default_words VALUES ('this',48);
INSERT INTO IndexedSearch_default_words VALUES ('for',49);
INSERT INTO IndexedSearch_default_words VALUES ('enough',50);
INSERT INTO IndexedSearch_default_words VALUES ('by',51);
INSERT INTO IndexedSearch_default_words VALUES ('be',52);
INSERT INTO IndexedSearch_default_words VALUES ('management',53);
INSERT INTO IndexedSearch_default_words VALUES ('universities',54);
INSERT INTO IndexedSearch_default_words VALUES ('needs',55);
INSERT INTO IndexedSearch_default_words VALUES ('thousands',56);
INSERT INTO IndexedSearch_default_words VALUES ('satisfy',57);
INSERT INTO IndexedSearch_default_words VALUES ('world',58);
INSERT INTO IndexedSearch_default_words VALUES ('are',59);
INSERT INTO IndexedSearch_default_words VALUES ('plain',60);
INSERT INTO IndexedSearch_default_words VALUES ('use',61);
INSERT INTO IndexedSearch_default_words VALUES ('friendly',62);
INSERT INTO IndexedSearch_default_words VALUES ('easy',63);
INSERT INTO IndexedSearch_default_words VALUES ('there',64);
INSERT INTO IndexedSearch_default_words VALUES ('communities',65);
INSERT INTO IndexedSearch_default_words VALUES ('shouldn',66);
INSERT INTO IndexedSearch_default_words VALUES ('want',67);
INSERT INTO IndexedSearch_default_words VALUES ('fuss',68);
INSERT INTO IndexedSearch_default_words VALUES ('you',69);
INSERT INTO IndexedSearch_default_words VALUES ('two',70);
INSERT INTO IndexedSearch_default_words VALUES ('if',71);
INSERT INTO IndexedSearch_default_words VALUES ('key',72);
INSERT INTO IndexedSearch_default_words VALUES ('key_benefits',73);
INSERT INTO IndexedSearch_default_words VALUES ('makes',74);
INSERT INTO IndexedSearch_default_words VALUES ('editing',75);
INSERT INTO IndexedSearch_default_words VALUES ('also',76);
INSERT INTO IndexedSearch_default_words VALUES ('always',77);
INSERT INTO IndexedSearch_default_words VALUES ('unique',78);
INSERT INTO IndexedSearch_default_words VALUES ('what',79);
INSERT INTO IndexedSearch_default_words VALUES ('install',80);
INSERT INTO IndexedSearch_default_words VALUES ('aids',81);
INSERT INTO IndexedSearch_default_words VALUES ('functions',82);
INSERT INTO IndexedSearch_default_words VALUES ('adjust',83);
INSERT INTO IndexedSearch_default_words VALUES ('technology',84);
INSERT INTO IndexedSearch_default_words VALUES ('lingual',85);
INSERT INTO IndexedSearch_default_words VALUES ('though',86);
INSERT INTO IndexedSearch_default_words VALUES ('learn',87);
INSERT INTO IndexedSearch_default_words VALUES ('still',88);
INSERT INTO IndexedSearch_default_words VALUES ('have',89);
INSERT INTO IndexedSearch_default_words VALUES ('programs',90);
INSERT INTO IndexedSearch_default_words VALUES ('will',91);
INSERT INTO IndexedSearch_default_words VALUES ('think',92);
INSERT INTO IndexedSearch_default_words VALUES ('trusty',93);
INSERT INTO IndexedSearch_default_words VALUES ('when',94);
INSERT INTO IndexedSearch_default_words VALUES ('bold',95);
INSERT INTO IndexedSearch_default_words VALUES ('build',96);
INSERT INTO IndexedSearch_default_words VALUES ('15',97);
INSERT INTO IndexedSearch_default_words VALUES ('online',98);
INSERT INTO IndexedSearch_default_words VALUES ('where',99);
INSERT INTO IndexedSearch_default_words VALUES ('yourself',100);
INSERT INTO IndexedSearch_default_words VALUES ('dates',101);
INSERT INTO IndexedSearch_default_words VALUES ('fact',102);
INSERT INTO IndexedSearch_default_words VALUES ('restricted',103);
INSERT INTO IndexedSearch_default_words VALUES ('like',104);
INSERT INTO IndexedSearch_default_words VALUES ('wouldn',105);
INSERT INTO IndexedSearch_default_words VALUES ('in',106);
INSERT INTO IndexedSearch_default_words VALUES ('weight',107);
INSERT INTO IndexedSearch_default_words VALUES ('inline',108);
INSERT INTO IndexedSearch_default_words VALUES ('knew',109);
INSERT INTO IndexedSearch_default_words VALUES ('re',110);
INSERT INTO IndexedSearch_default_words VALUES ('addition',111);
INSERT INTO IndexedSearch_default_words VALUES ('mind',112);
INSERT INTO IndexedSearch_default_words VALUES ('add',113);
INSERT INTO IndexedSearch_default_words VALUES ('ensures',114);
INSERT INTO IndexedSearch_default_words VALUES ('same',115);
INSERT INTO IndexedSearch_default_words VALUES ('cool',116);
INSERT INTO IndexedSearch_default_words VALUES ('after',117);
INSERT INTO IndexedSearch_default_words VALUES ('languages',118);
INSERT INTO IndexedSearch_default_words VALUES ('limit',119);
INSERT INTO IndexedSearch_default_words VALUES ('flexible',120);
INSERT INTO IndexedSearch_default_words VALUES ('localized',121);
INSERT INTO IndexedSearch_default_words VALUES ('features',122);
INSERT INTO IndexedSearch_default_words VALUES ('laid',123);
INSERT INTO IndexedSearch_default_words VALUES ('don',124);
INSERT INTO IndexedSearch_default_words VALUES ('created',125);
INSERT INTO IndexedSearch_default_words VALUES ('navigation',126);
INSERT INTO IndexedSearch_default_words VALUES ('while',127);
INSERT INTO IndexedSearch_default_words VALUES ('why',128);
INSERT INTO IndexedSearch_default_words VALUES ('oddities',129);
INSERT INTO IndexedSearch_default_words VALUES ('know',130);
INSERT INTO IndexedSearch_default_words VALUES ('content',131);
INSERT INTO IndexedSearch_default_words VALUES ('has',132);
INSERT INTO IndexedSearch_default_words VALUES ('not',133);
INSERT INTO IndexedSearch_default_words VALUES ('allows',134);
INSERT INTO IndexedSearch_default_words VALUES ('our',135);
INSERT INTO IndexedSearch_default_words VALUES ('out',136);
INSERT INTO IndexedSearch_default_words VALUES ('timezone',137);
INSERT INTO IndexedSearch_default_words VALUES ('one',138);
INSERT INTO IndexedSearch_default_words VALUES ('with',139);
INSERT INTO IndexedSearch_default_words VALUES ('manage',140);
INSERT INTO IndexedSearch_default_words VALUES ('behind',141);
INSERT INTO IndexedSearch_default_words VALUES ('core',142);
INSERT INTO IndexedSearch_default_words VALUES ('scenes',143);
INSERT INTO IndexedSearch_default_words VALUES ('cuts',144);
INSERT INTO IndexedSearch_default_words VALUES ('we',145);
INSERT INTO IndexedSearch_default_words VALUES ('edit',146);
INSERT INTO IndexedSearch_default_words VALUES ('local',147);
INSERT INTO IndexedSearch_default_words VALUES ('design',148);
INSERT INTO IndexedSearch_default_words VALUES ('wizards',149);
INSERT INTO IndexedSearch_default_words VALUES ('able',150);
INSERT INTO IndexedSearch_default_words VALUES ('language',151);
INSERT INTO IndexedSearch_default_words VALUES ('any',152);
INSERT INTO IndexedSearch_default_words VALUES ('work',153);
INSERT INTO IndexedSearch_default_words VALUES ('concern',154);
INSERT INTO IndexedSearch_default_words VALUES ('pretty',155);
INSERT INTO IndexedSearch_default_words VALUES ('then',156);
INSERT INTO IndexedSearch_default_words VALUES ('times',157);
INSERT INTO IndexedSearch_default_words VALUES ('more',158);
INSERT INTO IndexedSearch_default_words VALUES ('browser',159);
INSERT INTO IndexedSearch_default_words VALUES ('need',160);
INSERT INTO IndexedSearch_default_words VALUES ('font',161);
INSERT INTO IndexedSearch_default_words VALUES ('faster',162);
INSERT INTO IndexedSearch_default_words VALUES ('useful',163);
INSERT INTO IndexedSearch_default_words VALUES ('or',164);
INSERT INTO IndexedSearch_default_words VALUES ('interface',165);
INSERT INTO IndexedSearch_default_words VALUES ('upgrade',166);
INSERT INTO IndexedSearch_default_words VALUES ('new',167);
INSERT INTO IndexedSearch_default_words VALUES ('so',168);
INSERT INTO IndexedSearch_default_words VALUES ('sites',169);
INSERT INTO IndexedSearch_default_words VALUES ('built',170);
INSERT INTO IndexedSearch_default_words VALUES ('wysiwyg',171);
INSERT INTO IndexedSearch_default_words VALUES ('how',172);
INSERT INTO IndexedSearch_default_words VALUES ('translated',173);
INSERT INTO IndexedSearch_default_words VALUES ('designs',174);
INSERT INTO IndexedSearch_default_words VALUES ('everything',175);
INSERT INTO IndexedSearch_default_words VALUES ('other',176);
INSERT INTO IndexedSearch_default_words VALUES ('their',177);
INSERT INTO IndexedSearch_default_words VALUES ('snap',178);
INSERT INTO IndexedSearch_default_words VALUES ('ever',179);
INSERT INTO IndexedSearch_default_words VALUES ('most',180);
INSERT INTO IndexedSearch_default_words VALUES ('benefits',181);
INSERT INTO IndexedSearch_default_words VALUES ('even',182);
INSERT INTO IndexedSearch_default_words VALUES ('dt',183);
INSERT INTO IndexedSearch_default_words VALUES ('complicated',184);
INSERT INTO IndexedSearch_default_words VALUES ('pluggable',185);
INSERT INTO IndexedSearch_default_words VALUES ('look',186);
INSERT INTO IndexedSearch_default_words VALUES ('usability',187);
INSERT INTO IndexedSearch_default_words VALUES ('short',188);
INSERT INTO IndexedSearch_default_words VALUES ('been',189);
INSERT INTO IndexedSearch_default_words VALUES ('help',190);
INSERT INTO IndexedSearch_default_words VALUES ('first',191);
INSERT INTO IndexedSearch_default_words VALUES ('templating',192);
INSERT INTO IndexedSearch_default_words VALUES ('without',193);
INSERT INTO IndexedSearch_default_words VALUES ('than',194);
INSERT INTO IndexedSearch_default_words VALUES ('settings',195);
INSERT INTO IndexedSearch_default_words VALUES ('multi',196);
INSERT INTO IndexedSearch_default_words VALUES ('kinds',197);
INSERT INTO IndexedSearch_default_words VALUES ('these',198);
INSERT INTO IndexedSearch_default_words VALUES ('another',199);
INSERT INTO IndexedSearch_default_words VALUES ('many',200);
INSERT INTO IndexedSearch_default_words VALUES ('password',201);
INSERT INTO IndexedSearch_default_words VALUES ('controls',202);
INSERT INTO IndexedSearch_default_words VALUES ('ll',203);
INSERT INTO IndexedSearch_default_words VALUES ('lets',204);
INSERT INTO IndexedSearch_default_words VALUES ('steps',205);
INSERT INTO IndexedSearch_default_words VALUES ('follow',206);
INSERT INTO IndexedSearch_default_words VALUES ('several',207);
INSERT INTO IndexedSearch_default_words VALUES ('privileges',208);
INSERT INTO IndexedSearch_default_words VALUES ('users',209);
INSERT INTO IndexedSearch_default_words VALUES ('menus',210);
INSERT INTO IndexedSearch_default_words VALUES ('mess',211);
INSERT INTO IndexedSearch_default_words VALUES ('click',212);
INSERT INTO IndexedSearch_default_words VALUES ('reading',213);
INSERT INTO IndexedSearch_default_words VALUES ('ve',214);
INSERT INTO IndexedSearch_default_words VALUES ('copy',215);
INSERT INTO IndexedSearch_default_words VALUES ('turn',216);
INSERT INTO IndexedSearch_default_words VALUES ('administrator',217);
INSERT INTO IndexedSearch_default_words VALUES ('might',218);
INSERT INTO IndexedSearch_default_words VALUES ('got',219);
INSERT INTO IndexedSearch_default_words VALUES ('order',220);
INSERT INTO IndexedSearch_default_words VALUES ('admin',221);
INSERT INTO IndexedSearch_default_words VALUES ('enjoy',222);
INSERT INTO IndexedSearch_default_words VALUES ('anything',223);
INSERT INTO IndexedSearch_default_words VALUES ('administrative',224);
INSERT INTO IndexedSearch_default_words VALUES ('buttons',225);
INSERT INTO IndexedSearch_default_words VALUES ('support',226);
INSERT INTO IndexedSearch_default_words VALUES ('run',227);
INSERT INTO IndexedSearch_default_words VALUES ('toolbars',228);
INSERT INTO IndexedSearch_default_words VALUES ('means',229);
INSERT INTO IndexedSearch_default_words VALUES ('get',230);
INSERT INTO IndexedSearch_default_words VALUES ('control',231);
INSERT INTO IndexedSearch_default_words VALUES ('trivial',232);
INSERT INTO IndexedSearch_default_words VALUES ('getting',233);
INSERT INTO IndexedSearch_default_words VALUES ('note',234);
INSERT INTO IndexedSearch_default_words VALUES ('message',235);
INSERT INTO IndexedSearch_default_words VALUES ('well',236);
INSERT INTO IndexedSearch_default_words VALUES ('software',237);
INSERT INTO IndexedSearch_default_words VALUES ('as',238);
INSERT INTO IndexedSearch_default_words VALUES ('block',239);
INSERT INTO IndexedSearch_default_words VALUES ('started',240);
INSERT INTO IndexedSearch_default_words VALUES ('clipboard',241);
INSERT INTO IndexedSearch_default_words VALUES ('consider',242);
INSERT INTO IndexedSearch_default_words VALUES ('ruling',243);
INSERT INTO IndexedSearch_default_words VALUES ('trouble',244);
INSERT INTO IndexedSearch_default_words VALUES ('change',245);
INSERT INTO IndexedSearch_default_words VALUES ('username',246);
INSERT INTO IndexedSearch_default_words VALUES ('provides',247);
INSERT INTO IndexedSearch_default_words VALUES ('top',248);
INSERT INTO IndexedSearch_default_words VALUES ('pages',249);
INSERT INTO IndexedSearch_default_words VALUES ('do',250);
INSERT INTO IndexedSearch_default_words VALUES ('into',251);
INSERT INTO IndexedSearch_default_words VALUES ('case',252);
INSERT INTO IndexedSearch_default_words VALUES ('installation',253);
INSERT INTO IndexedSearch_default_words VALUES ('notice',254);
INSERT INTO IndexedSearch_default_words VALUES ('good',255);
INSERT INTO IndexedSearch_default_words VALUES ('from',256);
INSERT INTO IndexedSearch_default_words VALUES ('create',257);
INSERT INTO IndexedSearch_default_words VALUES ('account',258);
INSERT INTO IndexedSearch_default_words VALUES ('running',259);
INSERT INTO IndexedSearch_default_words VALUES ('job',260);
INSERT INTO IndexedSearch_default_words VALUES ('little',261);
INSERT INTO IndexedSearch_default_words VALUES ('now',262);
INSERT INTO IndexedSearch_default_words VALUES ('page',263);
INSERT INTO IndexedSearch_default_words VALUES ('paste',264);
INSERT INTO IndexedSearch_default_words VALUES ('getting_started',265);
INSERT INTO IndexedSearch_default_words VALUES ('let',266);
INSERT INTO IndexedSearch_default_words VALUES ('could',267);
INSERT INTO IndexedSearch_default_words VALUES ('groups',268);
INSERT INTO IndexedSearch_default_words VALUES ('about',269);
INSERT INTO IndexedSearch_default_words VALUES ('else',270);
INSERT INTO IndexedSearch_default_words VALUES ('default',271);
INSERT INTO IndexedSearch_default_words VALUES ('up',272);
INSERT INTO IndexedSearch_default_words VALUES ('123qwe',273);
INSERT INTO IndexedSearch_default_words VALUES ('should',274);
INSERT INTO IndexedSearch_default_words VALUES ('at',275);
INSERT INTO IndexedSearch_default_words VALUES ('log',276);
INSERT INTO IndexedSearch_default_words VALUES ('information',277);
INSERT INTO IndexedSearch_default_words VALUES ('menu',278);
INSERT INTO IndexedSearch_default_words VALUES ('manipulate',279);
INSERT INTO IndexedSearch_default_words VALUES ('administer',280);
INSERT INTO IndexedSearch_default_words VALUES ('email',281);
INSERT INTO IndexedSearch_default_words VALUES ('address',282);
INSERT INTO IndexedSearch_default_words VALUES ('friends',283);
INSERT INTO IndexedSearch_default_words VALUES ('cc',284);
INSERT INTO IndexedSearch_default_words VALUES ('bcc',285);
INSERT INTO IndexedSearch_default_words VALUES ('subject',286);
INSERT INTO IndexedSearch_default_words VALUES ('url',287);

--
-- Table structure for table `IndexedSearch_docInfo`
--

CREATE TABLE IndexedSearch_docInfo (
  docId int(11) NOT NULL default '0',
  indexName varchar(35) NOT NULL default 'Search_index',
  assetId varchar(22) default NULL,
  groupIdView varchar(22) default NULL,
  special_groupIdView varchar(22) default NULL,
  namespace varchar(35) default NULL,
  location varchar(255) default NULL,
  headerShortcut text,
  bodyShortcut text,
  contentType text NOT NULL,
  ownerId varchar(22) default NULL,
  dateIndexed int(11) NOT NULL default '0',
  PRIMARY KEY  (docId,indexName)
) TYPE=MyISAM;

--
-- Dumping data for table `IndexedSearch_docInfo`
--


INSERT INTO IndexedSearch_docInfo VALUES (1,'IndexedSearch_default','TKzUMeIxRLrZ3NAEez6CXQ','7','7','Article','/home/welcome','select title from asset where assetId = \'TKzUMeIxRLrZ3NAEez6CXQ\'','select description from wobject where assetId = \'TKzUMeIxRLrZ3NAEez6CXQ\'','content','3',1109980803);
INSERT INTO IndexedSearch_docInfo VALUES (2,'IndexedSearch_default','sWVXMZGibxHe2Ekj1DCldA','7','7','Article','/home/key_benefits','select title from asset where assetId = \'sWVXMZGibxHe2Ekj1DCldA\'','select description from wobject where assetId = \'sWVXMZGibxHe2Ekj1DCldA\'','content','3',1109980804);
INSERT INTO IndexedSearch_docInfo VALUES (3,'IndexedSearch_default','x_WjMvFmilhX-jvZuIpinw','7','7','Article','/getting_started/getting_started','select title from asset where assetId = \'x_WjMvFmilhX-jvZuIpinw\'','select description from wobject where assetId = \'x_WjMvFmilhX-jvZuIpinw\'','content','3',1109980804);
INSERT INTO IndexedSearch_docInfo VALUES (4,'IndexedSearch_default','Szs5eev3OMssmnsyLRZmWA','7','7','DataForm_field','/tell_a_friend/tell_a_friend','select label from DataForm_field where DataForm_fieldId = \'1000\'','select subtext, possibleValues from DataForm_field where DataForm_fieldId = \'1000\'','content','3',1109980804);
INSERT INTO IndexedSearch_docInfo VALUES (5,'IndexedSearch_default','Szs5eev3OMssmnsyLRZmWA','7','7','DataForm_field','/tell_a_friend/tell_a_friend','select label from DataForm_field where DataForm_fieldId = \'1001\'','select subtext, possibleValues from DataForm_field where DataForm_fieldId = \'1001\'','content','3',1109980804);
INSERT INTO IndexedSearch_docInfo VALUES (6,'IndexedSearch_default','Szs5eev3OMssmnsyLRZmWA','7','7','DataForm_field','/tell_a_friend/tell_a_friend','select label from DataForm_field where DataForm_fieldId = \'1002\'','select subtext, possibleValues from DataForm_field where DataForm_fieldId = \'1002\'','content','3',1109980804);
INSERT INTO IndexedSearch_docInfo VALUES (7,'IndexedSearch_default','Szs5eev3OMssmnsyLRZmWA','7','7','DataForm_field','/tell_a_friend/tell_a_friend','select label from DataForm_field where DataForm_fieldId = \'1003\'','select subtext, possibleValues from DataForm_field where DataForm_fieldId = \'1003\'','content','3',1109980804);
INSERT INTO IndexedSearch_docInfo VALUES (8,'IndexedSearch_default','Szs5eev3OMssmnsyLRZmWA','7','7','DataForm_field','/tell_a_friend/tell_a_friend','select label from DataForm_field where DataForm_fieldId = \'1004\'','select subtext, possibleValues from DataForm_field where DataForm_fieldId = \'1004\'','content','3',1109980804);
INSERT INTO IndexedSearch_docInfo VALUES (9,'IndexedSearch_default','Szs5eev3OMssmnsyLRZmWA','7','7','DataForm_field','/tell_a_friend/tell_a_friend','select label from DataForm_field where DataForm_fieldId = \'1005\'','select subtext, possibleValues from DataForm_field where DataForm_fieldId = \'1005\'','content','3',1109980804);
INSERT INTO IndexedSearch_docInfo VALUES (10,'IndexedSearch_default','Szs5eev3OMssmnsyLRZmWA','7','7','DataForm_field','/tell_a_friend/tell_a_friend','select label from DataForm_field where DataForm_fieldId = \'1006\'','select subtext, possibleValues from DataForm_field where DataForm_fieldId = \'1006\'','content','3',1109980804);

--
-- Table structure for table `Layout`
--

CREATE TABLE Layout (
  assetId varchar(22) NOT NULL default '',
  templateId varchar(22) NOT NULL default '',
  contentPositions text,
  PRIMARY KEY  (assetId)
) TYPE=MyISAM;

--
-- Dumping data for table `Layout`
--


INSERT INTO Layout VALUES ('68sKwDgf9cGH58-NZcU4lg','PBtmpl0000000000000054','TKzUMeIxRLrZ3NAEez6CXQ,sWVXMZGibxHe2Ekj1DCldA');
INSERT INTO Layout VALUES ('_iHetEvMQUOoxS-T2CM0sQ','PBtmpl0000000000000054','x_WjMvFmilhX-jvZuIpinw');
INSERT INTO Layout VALUES ('8Bb8gu-me2mhL3ljFyiWLg','PBtmpl0000000000000054','DC1etlIaBRQitXnchZKvUw');
INSERT INTO Layout VALUES ('2TqQc4OISddWCZmRY1_m8A','PBtmpl0000000000000054','fK-HMSboA3uu0c1KYkYspA');
INSERT INTO Layout VALUES ('Swf6L8poXKc7hUaNPkBevw','PBtmpl0000000000000054','Szs5eev3OMssmnsyLRZmWA');
INSERT INTO Layout VALUES ('x3OFY6OJh_qsXkZfPwug4A','PBtmpl0000000000000054','pJd5TLAjfWMVXD6sCRLwUg');

--
-- Table structure for table `MessageBoard`
--

CREATE TABLE MessageBoard (
  assetId varchar(22) NOT NULL default '',
  templateId varchar(22) NOT NULL default '',
  PRIMARY KEY  (assetId)
) TYPE=MyISAM;

--
-- Dumping data for table `MessageBoard`
--



--
-- Table structure for table `Navigation`
--

CREATE TABLE Navigation (
  assetId varchar(22) NOT NULL default '',
  assetsToInclude text,
  startType varchar(35) default NULL,
  startPoint varchar(255) default NULL,
  endPoint varchar(35) default NULL,
  showSystemPages int(11) NOT NULL default '0',
  showHiddenPages int(11) NOT NULL default '0',
  showUnprivilegedPages int(11) NOT NULL default '0',
  templateId varchar(22) NOT NULL default '',
  PRIMARY KEY  (assetId)
) TYPE=MyISAM;

--
-- Dumping data for table `Navigation`
--


INSERT INTO Navigation VALUES ('pJd5TLAjfWMVXD6sCRLwUg','descendants','specificUrl','root','55',0,0,0,'PBtmpl0000000000000048');
INSERT INTO Navigation VALUES ('PBnav00000000000000001','self\nancestors','relativeToCurrentUrl','0','55',0,0,0,'PBtmpl0000000000000093');
INSERT INTO Navigation VALUES ('PBnav00000000000000014','pedigree','relativeToRoot','1','55',0,0,0,'PBtmpl0000000000000048');
INSERT INTO Navigation VALUES ('PBnav00000000000000015','descendants','relativeToCurrentUrl','0','1',0,0,0,'PBtmpl0000000000000048');
INSERT INTO Navigation VALUES ('PBnav00000000000000016','descendants','relativeToCurrentUrl','0','1',0,0,0,'PBtmpl0000000000000108');
INSERT INTO Navigation VALUES ('PBnav00000000000000017','self\nsiblings','relativeToCurrentUrl','0','55',0,0,0,'PBtmpl0000000000000117');
INSERT INTO Navigation VALUES ('PBnav00000000000000018','descendants','relativeToCurrentUrl','-1','1',0,0,0,'PBtmpl0000000000000048');
INSERT INTO Navigation VALUES ('PBnav00000000000000019','descendants','relativeToCurrentUrl','-1','1',0,0,0,'PBtmpl0000000000000108');
INSERT INTO Navigation VALUES ('PBnav00000000000000020','descendants','relativeToRoot','0','1',0,0,0,'PBtmpl0000000000000108');
INSERT INTO Navigation VALUES ('PBnav00000000000000021','descendants','specificUrl','home','3',0,0,0,'PBtmpl0000000000000117');
INSERT INTO Navigation VALUES ('PBnav00000000000000002','descendants','specificUrl','home','3',0,0,0,'PBtmpl0000000000000048');
INSERT INTO Navigation VALUES ('PBnav00000000000000006','descendants','specificUrl','home','1',0,0,0,'PBtmpl0000000000000108');
INSERT INTO Navigation VALUES ('PBnav00000000000000007','descendants','relativeToRoot','1','1',0,0,0,'PBtmpl0000000000000048');
INSERT INTO Navigation VALUES ('PBnav00000000000000008','descendants','relativeToRoot','1','1',0,0,0,'PBtmpl0000000000000108');
INSERT INTO Navigation VALUES ('PBnav00000000000000009','descendants','relativeToRoot','0','1',0,0,0,'PBtmpl0000000000000124');
INSERT INTO Navigation VALUES ('PBnav00000000000000010',NULL,'relativeToRoot','1','1',0,0,0,'PBtmpl0000000000000117');
INSERT INTO Navigation VALUES ('PBnav00000000000000011','self\ndescendants','relativeToRoot','1','55',0,0,0,'PBtmpl0000000000000130');
INSERT INTO Navigation VALUES ('PBnav00000000000000012','descendants','relativeToRoot','1','55',0,0,0,'PBtmpl0000000000000134');
INSERT INTO Navigation VALUES ('PBnav00000000000000013','self\ndescendants','relativeToCurrentUrl','0','55',0,0,0,'PBtmpl0000000000000136');
INSERT INTO Navigation VALUES ('f2bihDeMoI-Ojt2dutJNQA',NULL,'relativeToRoot','1','1',0,0,0,'PBtmpl0000000000000071');
INSERT INTO Navigation VALUES ('KZ2UytxNpbF-3Eg3RNvQQQ','descendants','relativeToCurrentUrl','0','1',0,0,0,'PBtmpl0000000000000075');
INSERT INTO Navigation VALUES ('G0wlShbk_XruYVfbXqWq_w','pedigree','relativeToRoot','1','55',0,0,0,'PBtmpl0000000000000048');

--
-- Table structure for table `Poll`
--

CREATE TABLE Poll (
  active int(11) NOT NULL default '1',
  graphWidth int(11) NOT NULL default '150',
  voteGroup varchar(22) default NULL,
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
  assetId varchar(22) NOT NULL default '',
  templateId varchar(22) NOT NULL default '',
  PRIMARY KEY  (assetId)
) TYPE=MyISAM;

--
-- Dumping data for table `Poll`
--



--
-- Table structure for table `Poll_answer`
--

CREATE TABLE Poll_answer (
  answer char(3) default NULL,
  userId varchar(22) default NULL,
  ipAddress varchar(50) default NULL,
  assetId varchar(22) default NULL
) TYPE=MyISAM;

--
-- Dumping data for table `Poll_answer`
--



--
-- Table structure for table `Post`
--

CREATE TABLE Post (
  assetId varchar(22) NOT NULL default '',
  threadId varchar(22) NOT NULL default '',
  dateSubmitted bigint(20) default NULL,
  dateUpdated bigint(20) default NULL,
  username varchar(30) default NULL,
  content mediumtext,
  status varchar(30) NOT NULL default 'approved',
  views int(11) NOT NULL default '0',
  contentType varchar(35) NOT NULL default 'mixed',
  userDefined1 text,
  userDefined2 text,
  userDefined3 text,
  userDefined4 text,
  userDefined5 text,
  storageId varchar(22) default NULL,
  rating int(11) NOT NULL default '0',
  PRIMARY KEY  (assetId)
) TYPE=MyISAM;

--
-- Dumping data for table `Post`
--


INSERT INTO Post VALUES ('pSygeMG7bSL1Za0SNqfUbw','pSygeMG7bSL1Za0SNqfUbw',1076705448,1076706084,'Admin','<img src=\"^Extras;styles/webgui6/img_talk_to_experts.gif\" align=\"right\" style=\"padding-left: 15px;\" /> Our website contains all of the different methods for reaching us. Our friendly staff will be happy to assist you in any way possible.\r\n\r\n','approved',2,'html','http://www.plainblack.com/contact_us','0',NULL,NULL,NULL,NULL,0);
INSERT INTO Post VALUES ('mdIaXozmVNE_Rga2BY0mxA','mdIaXozmVNE_Rga2BY0mxA',1076705448,1076706084,'Admin','<img src=\"^Extras;styles/webgui6/img_manual.gif\" align=\"right\" style=\"padding-left: 15px;\" />Ruling WebGUI is the definitive guide to everything WebGUI related. It has been compiled by the experts at Plain Black and covers almost all aspects of WebGUI. When you purchase Ruling WebGUI, you will receive updates to this great manual for one full year.','approved',0,'html','http://www.plainblack.com/store/rwg','0',NULL,NULL,NULL,NULL,0);
INSERT INTO Post VALUES ('9kDcFufTKbMTkeAHyP36fw','9kDcFufTKbMTkeAHyP36fw',1076705448,1076706084,'Admin','<img src=\"^Extras;styles/webgui6/img_tech_support.gif\" align=\"right\" style=\"padding-left: 15px;\" />The WebGUI Support Center is there to help you when you get stuck. With a system as large as WebGUI, you\'ll likely have some questions, and our courteous and knowlegable staff is available to answer those questions. And best of all, you get Ruling WebGUI free when you sign up for the Support Center.\r\n\r\n','approved',0,'html','http://www.plainblack.com/store/support','0',NULL,NULL,NULL,NULL,0);
INSERT INTO Post VALUES ('5Y8eOI2u_HOvkzrRuLdz1g','5Y8eOI2u_HOvkzrRuLdz1g',1076705448,1076706084,'Admin','<img src=\"^Extras;styles/webgui6/img_hosting.gif\" align=\"right\" style=\"padding-left: 15px;\" />We provide professional hosting services for you so you don\'t have to go through the trouble of finding a hoster who likely won\'t know what to do with WebGUI anyway.','approved',0,'html','http://www.plainblack.com/store/hosting','0',NULL,NULL,NULL,NULL,0);
INSERT INTO Post VALUES ('ImmYJRWOPFedzI4Bg1k6GA','ImmYJRWOPFedzI4Bg1k6GA',1076705448,1076706084,'Admin','<img src=\"^Extras;styles/webgui6/img_look_great.gif\" align=\"right\" style=\"padding-left: 15px;\" />Let Plain Black\'s design team build you a professional looking design. Our award-winning designers can get you the look you need on time and on budget, every time.','approved',0,'html','http://www.plainblack.com/design','0',NULL,NULL,NULL,NULL,0);

--
-- Table structure for table `Post_rating`
--

CREATE TABLE Post_rating (
  assetId varchar(22) NOT NULL default '',
  userId varchar(22) NOT NULL default '',
  ipAddress varchar(15) NOT NULL default '',
  dateOfRating bigint(20) default NULL,
  rating int(11) NOT NULL default '0'
) TYPE=MyISAM;

--
-- Dumping data for table `Post_rating`
--



--
-- Table structure for table `Post_read`
--

CREATE TABLE Post_read (
  postId varchar(22) NOT NULL default '',
  threadId varchar(22) NOT NULL default '',
  userId varchar(22) NOT NULL default '',
  readDate bigint(20) default NULL
) TYPE=MyISAM;

--
-- Dumping data for table `Post_read`
--


INSERT INTO Post_read VALUES ('pSygeMG7bSL1Za0SNqfUbw','pSygeMG7bSL1Za0SNqfUbw','1',1109194986);

--
-- Table structure for table `Product`
--

CREATE TABLE Product (
  image1 varchar(255) default NULL,
  image2 varchar(255) default NULL,
  image3 varchar(255) default NULL,
  brochure varchar(255) default NULL,
  manual varchar(255) default NULL,
  warranty varchar(255) default NULL,
  price varchar(255) default NULL,
  productNumber varchar(255) default NULL,
  assetId varchar(22) NOT NULL default '',
  templateId varchar(22) NOT NULL default '',
  PRIMARY KEY  (assetId)
) TYPE=MyISAM;

--
-- Dumping data for table `Product`
--



--
-- Table structure for table `Product_accessory`
--

CREATE TABLE Product_accessory (
  sequenceNumber int(11) NOT NULL default '0',
  assetId varchar(22) NOT NULL default '',
  accessoryAssetId varchar(22) NOT NULL default '',
  PRIMARY KEY  (assetId,accessoryAssetId)
) TYPE=MyISAM;

--
-- Dumping data for table `Product_accessory`
--



--
-- Table structure for table `Product_benefit`
--

CREATE TABLE Product_benefit (
  Product_benefitId varchar(22) NOT NULL default '',
  benefit varchar(255) default NULL,
  sequenceNumber int(11) NOT NULL default '0',
  assetId varchar(22) NOT NULL default '',
  PRIMARY KEY  (Product_benefitId)
) TYPE=MyISAM;

--
-- Dumping data for table `Product_benefit`
--



--
-- Table structure for table `Product_feature`
--

CREATE TABLE Product_feature (
  Product_featureId varchar(22) NOT NULL default '',
  feature varchar(255) default NULL,
  sequenceNumber int(11) NOT NULL default '0',
  assetId varchar(22) NOT NULL default '',
  PRIMARY KEY  (Product_featureId)
) TYPE=MyISAM;

--
-- Dumping data for table `Product_feature`
--



--
-- Table structure for table `Product_related`
--

CREATE TABLE Product_related (
  sequenceNumber int(11) NOT NULL default '0',
  assetId varchar(22) NOT NULL default '',
  relatedAssetId varchar(22) NOT NULL default '',
  PRIMARY KEY  (assetId,relatedAssetId)
) TYPE=MyISAM;

--
-- Dumping data for table `Product_related`
--



--
-- Table structure for table `Product_specification`
--

CREATE TABLE Product_specification (
  Product_specificationId varchar(22) NOT NULL default '',
  name varchar(255) default NULL,
  value varchar(255) default NULL,
  units varchar(255) default NULL,
  sequenceNumber int(11) NOT NULL default '0',
  assetId varchar(22) NOT NULL default '',
  PRIMARY KEY  (Product_specificationId)
) TYPE=MyISAM;

--
-- Dumping data for table `Product_specification`
--



--
-- Table structure for table `SQLReport`
--

CREATE TABLE SQLReport (
  dbQuery1 text,
  paginateAfter int(11) NOT NULL default '50',
  preprocessMacros1 int(11) default '0',
  debugMode int(11) NOT NULL default '0',
  databaseLinkId1 varchar(22) default NULL,
  placeholderParams1 text,
  preprocessMacros2 int(11) default '0',
  dbQuery2 text,
  placeholderParams2 text,
  databaseLinkId2 varchar(22) default NULL,
  preprocessMacros3 int(11) default '0',
  dbQuery3 text,
  placeholderParams3 text,
  databaseLinkId3 varchar(22) default NULL,
  preprocessMacros4 int(11) default '0',
  dbQuery4 text,
  placeholderParams4 text,
  databaseLinkId4 varchar(22) default NULL,
  preprocessMacros5 int(11) default '0',
  dbQuery5 text,
  placeholderParams5 text,
  databaseLinkId5 varchar(22) default NULL,
  assetId varchar(22) NOT NULL default '',
  templateId varchar(22) NOT NULL default '',
  PRIMARY KEY  (assetId)
) TYPE=MyISAM;

--
-- Dumping data for table `SQLReport`
--



--
-- Table structure for table `Shortcut`
--

CREATE TABLE Shortcut (
  overrideTitle int(11) NOT NULL default '0',
  overrideDescription int(11) NOT NULL default '0',
  overrideTemplate int(11) NOT NULL default '0',
  overrideDisplayTitle int(11) NOT NULL default '0',
  overrideTemplateId varchar(22) NOT NULL default '',
  shortcutByCriteria int(11) NOT NULL default '0',
  resolveMultiples varchar(30) default 'mostRecent',
  shortcutCriteria text NOT NULL,
  description mediumtext,
  assetId varchar(22) NOT NULL default '',
  templateId varchar(22) NOT NULL default '',
  shortcutToAssetId varchar(22) NOT NULL default '',
  PRIMARY KEY  (assetId)
) TYPE=MyISAM;

--
-- Dumping data for table `Shortcut`
--



--
-- Table structure for table `Survey`
--

CREATE TABLE Survey (
  questionOrder varchar(30) default NULL,
  groupToTakeSurvey varchar(22) default NULL,
  groupToViewReports varchar(22) default NULL,
  mode varchar(30) default NULL,
  Survey_id varchar(22) default NULL,
  anonymous char(1) NOT NULL default '0',
  questionsPerPage int(11) NOT NULL default '1',
  responseTemplateId varchar(22) default NULL,
  overviewTemplateId varchar(22) default NULL,
  maxResponsesPerUser int(11) NOT NULL default '1',
  questionsPerResponse int(11) NOT NULL default '9999999',
  gradebookTemplateId varchar(22) default 'PBtmpl0000000000000062',
  assetId varchar(22) NOT NULL default '',
  templateId varchar(22) NOT NULL default '',
  PRIMARY KEY  (assetId)
) TYPE=MyISAM;

--
-- Dumping data for table `Survey`
--



--
-- Table structure for table `Survey_answer`
--

CREATE TABLE Survey_answer (
  Survey_id varchar(22) default NULL,
  Survey_questionId varchar(22) default NULL,
  Survey_answerId varchar(22) NOT NULL default '',
  sequenceNumber int(11) NOT NULL default '1',
  gotoQuestion varchar(22) default NULL,
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
  Survey_id varchar(22) default NULL,
  Survey_questionId varchar(22) NOT NULL default '',
  question text,
  sequenceNumber int(11) NOT NULL default '1',
  allowComment int(11) NOT NULL default '0',
  randomizeAnswers int(11) NOT NULL default '0',
  answerFieldType varchar(35) default NULL,
  gotoQuestion varchar(22) default NULL,
  PRIMARY KEY  (Survey_questionId)
) TYPE=MyISAM;

--
-- Dumping data for table `Survey_question`
--



--
-- Table structure for table `Survey_questionResponse`
--

CREATE TABLE Survey_questionResponse (
  Survey_id varchar(22) default NULL,
  Survey_questionId varchar(22) NOT NULL default '',
  Survey_answerId varchar(22) NOT NULL default '',
  Survey_responseId varchar(22) NOT NULL default '',
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
  Survey_id varchar(22) default NULL,
  Survey_responseId varchar(22) NOT NULL default '',
  userId varchar(22) default NULL,
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
  rssUrl text,
  maxHeadlines int(11) NOT NULL default '0',
  assetId varchar(22) NOT NULL default '',
  templateId varchar(22) NOT NULL default '',
  PRIMARY KEY  (assetId)
) TYPE=MyISAM;

--
-- Dumping data for table `SyndicatedContent`
--


INSERT INTO SyndicatedContent VALUES ('http://www.plainblack.com/news/news?func=viewRSS',3,'fK-HMSboA3uu0c1KYkYspA','GNvjCFQWjY2AF2uf0aCM8Q');

--
-- Table structure for table `Thread`
--

CREATE TABLE Thread (
  assetId varchar(22) NOT NULL default '',
  replies int(11) NOT NULL default '0',
  lastPostId varchar(22) NOT NULL default '0',
  lastPostDate bigint(20) default NULL,
  isLocked int(11) NOT NULL default '0',
  isSticky int(11) NOT NULL default '0',
  subscriptionGroupId varchar(22) default NULL,
  PRIMARY KEY  (assetId)
) TYPE=MyISAM;

--
-- Dumping data for table `Thread`
--


INSERT INTO Thread VALUES ('pSygeMG7bSL1Za0SNqfUbw',0,'',NULL,0,0,'wP1Lt8NIySq9MS8xPGnAsQ');
INSERT INTO Thread VALUES ('mdIaXozmVNE_Rga2BY0mxA',0,'',NULL,0,0,'OL-d6C93EeUr4Rja-q3-yQ');
INSERT INTO Thread VALUES ('9kDcFufTKbMTkeAHyP36fw',0,'',NULL,0,0,'YPCggIxdKT3AMMlML-CAuw');
INSERT INTO Thread VALUES ('5Y8eOI2u_HOvkzrRuLdz1g',0,'',NULL,0,0,'C02CXMw3c42EJJR_nktyMw');
INSERT INTO Thread VALUES ('ImmYJRWOPFedzI4Bg1k6GA',0,'',NULL,0,0,'zZmjNsD1FhaSFkgXvnCQUg');

--
-- Table structure for table `WSClient`
--

CREATE TABLE WSClient (
  callMethod text,
  uri varchar(255) NOT NULL default '',
  proxy varchar(255) NOT NULL default '',
  preprocessMacros int(11) NOT NULL default '0',
  paginateAfter int(11) NOT NULL default '50',
  paginateVar varchar(35) default NULL,
  debugMode int(11) NOT NULL default '0',
  params text,
  execute_by_default tinyint(4) NOT NULL default '1',
  decodeUtf8 tinyint(3) unsigned NOT NULL default '0',
  httpHeader varchar(50) default NULL,
  sharedCache tinyint(3) unsigned NOT NULL default '0',
  cacheTTL smallint(5) unsigned NOT NULL default '60',
  assetId varchar(22) NOT NULL default '',
  templateId varchar(22) NOT NULL default '',
  PRIMARY KEY  (assetId)
) TYPE=MyISAM;

--
-- Dumping data for table `WSClient`
--



--
-- Table structure for table `asset`
--

CREATE TABLE asset (
  assetId varchar(22) NOT NULL default '',
  parentId varchar(22) NOT NULL default '',
  lineage varchar(255) NOT NULL default '',
  state varchar(35) NOT NULL default '',
  className varchar(255) NOT NULL default '',
  title varchar(255) NOT NULL default 'untitled',
  menuTitle varchar(255) NOT NULL default 'untitled',
  url varchar(255) NOT NULL default '',
  startDate bigint(20) NOT NULL default '997995720',
  endDate bigint(20) NOT NULL default '9223372036854775807',
  ownerUserId varchar(22) NOT NULL default '',
  groupIdView varchar(22) NOT NULL default '',
  groupIdEdit varchar(22) NOT NULL default '',
  synopsis text,
  newWindow int(11) NOT NULL default '0',
  isHidden int(11) NOT NULL default '0',
  isSystem int(11) NOT NULL default '0',
  encryptPage int(11) NOT NULL default '0',
  assetSize int(11) NOT NULL default '0',
  lastUpdated bigint(20) NOT NULL default '0',
  lastUpdatedBy varchar(22) default NULL,
  isPackage int(11) NOT NULL default '0',
  extraHeadTags text,
  isPrototype int(11) NOT NULL default '0',
  PRIMARY KEY  (assetId),
  UNIQUE KEY url (url),
  UNIQUE KEY lineage (lineage),
  KEY parentId (parentId),
  KEY state_parentId_lineage (state,parentId,lineage),
  KEY isPrototype_className_assetId (isPrototype,className,assetId)
) TYPE=MyISAM;

--
-- Dumping data for table `asset`
--


INSERT INTO asset VALUES ('PBasset000000000000001','infinity','000001','published','WebGUI::Asset','Root','Root','root',997995720,9223372036854775807,'3','3','3',NULL,0,1,1,0,0,0,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBasset000000000000002','PBasset000000000000001','000001000001','published','WebGUI::Asset::Wobject::Folder','Import Node','Import','root/import',997995720,9223372036854775807,'3','3','3',NULL,0,1,1,0,212,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('68sKwDgf9cGH58-NZcU4lg','PBasset000000000000001','000001000002','published','WebGUI::Asset::Wobject::Layout','Home','Home','home',946710000,2082783600,'3','7','3',NULL,0,0,0,0,532,0,NULL,0,'',0);
INSERT INTO asset VALUES ('TKzUMeIxRLrZ3NAEez6CXQ','68sKwDgf9cGH58-NZcU4lg','000001000002000001','published','WebGUI::Asset::Wobject::Article','Welcome','Welcome','home/welcome',946710000,2082783600,'3','7','3',NULL,0,1,0,0,1599,0,NULL,0,NULL,0);
INSERT INTO asset VALUES ('sWVXMZGibxHe2Ekj1DCldA','68sKwDgf9cGH58-NZcU4lg','000001000002000002','published','WebGUI::Asset::Wobject::Article','Key Benefits','Key Benefits','home/key_benefits',946710000,2082783600,'3','7','3',NULL,0,1,0,0,2279,0,NULL,0,NULL,0);
INSERT INTO asset VALUES ('_iHetEvMQUOoxS-T2CM0sQ','68sKwDgf9cGH58-NZcU4lg','000001000002000003','published','WebGUI::Asset::Wobject::Layout','Getting Started','Getting Started','getting_started',946710000,2082783600,'3','7','3','',0,0,0,0,567,0,NULL,0,'',0);
INSERT INTO asset VALUES ('x_WjMvFmilhX-jvZuIpinw','_iHetEvMQUOoxS-T2CM0sQ','000001000002000003000001','published','WebGUI::Asset::Wobject::Article','Getting Started','Getting Started','getting_started/getting_started',946710000,2082783600,'3','7','3',NULL,0,1,0,0,2254,0,NULL,0,NULL,0);
INSERT INTO asset VALUES ('8Bb8gu-me2mhL3ljFyiWLg','68sKwDgf9cGH58-NZcU4lg','000001000002000004','published','WebGUI::Asset::Wobject::Layout','What should you do next?','Your Next Step','your_next_step',946710000,2082783600,'3','7','3','',0,0,0,0,575,0,NULL,0,'',0);
INSERT INTO asset VALUES ('DC1etlIaBRQitXnchZKvUw','8Bb8gu-me2mhL3ljFyiWLg','000001000002000004000001','published','WebGUI::Asset::Wobject::Collaboration','Your Next Step','Your Next Step','your_next_step/your_next_step',946710000,2082783600,'3','7','3',NULL,0,1,0,0,563,1109194990,NULL,0,NULL,0);
INSERT INTO asset VALUES ('pSygeMG7bSL1Za0SNqfUbw','DC1etlIaBRQitXnchZKvUw','000001000002000004000001000001','published','WebGUI::Asset::Post::Thread','Talk to the Experts','Talk to the Experts','talk_to_the_experts',946710000,2114406000,'3','7','3','<img src=\"^Extras;styles/webgui6/img_talk_to_experts.gif\" align=\"right\" style=\"padding-left: 15px;\" /> Our website contains all of the different methods for reaching us. Our friendly staff will be happy to assist you in any way possible.\r',0,1,0,0,809,1109194990,NULL,0,NULL,0);
INSERT INTO asset VALUES ('mdIaXozmVNE_Rga2BY0mxA','DC1etlIaBRQitXnchZKvUw','000001000002000004000001000002','published','WebGUI::Asset::Post::Thread','Get the Manual','Get the Manual','get_the_manual',946710000,2114406000,'3','7','3','<img src=\"^Extras;styles/webgui6/img_manual.gif\" align=\"right\" style=\"padding-left: 15px;\" />Ruling WebGUI is the definitive guide to everything WebGUI related. It has been compiled by the experts at Plain Black and covers almost all aspects of WebGUI. When you purchase Ruling WebGUI, you will receive updates to this great manual for one full year.',0,1,0,0,359,0,NULL,0,NULL,0);
INSERT INTO asset VALUES ('9kDcFufTKbMTkeAHyP36fw','DC1etlIaBRQitXnchZKvUw','000001000002000004000001000003','published','WebGUI::Asset::Post::Thread','Purchase Technical Support','Purchase Technical Support','purchase_technical_support',946710000,2114406000,'3','7','3','<img src=\"^Extras;styles/webgui6/img_tech_support.gif\" align=\"right\" style=\"padding-left: 15px;\" />The WebGUI Support Center is there to help you when you get stuck. With a system as large as WebGUI, you\'ll likely have some questions, and our courteous and knowlegable staff is available to answer those questions. And best of all, you get Ruling WebGUI free when you sign up for the Support Center.\r',0,1,0,0,403,0,NULL,0,NULL,0);
INSERT INTO asset VALUES ('5Y8eOI2u_HOvkzrRuLdz1g','DC1etlIaBRQitXnchZKvUw','000001000002000004000001000004','published','WebGUI::Asset::Post::Thread','Sign Up for Hosting','Sign Up for Hosting','sign_up_for_hosting',946710000,2114406000,'3','7','3','<img src=\"^Extras;styles/webgui6/img_hosting.gif\" align=\"right\" style=\"padding-left: 15px;\" />We provide professional hosting services for you so you don\'t have to go through the trouble of finding a hoster who likely won\'t know what to do with WebGUI anyway.',0,1,0,0,259,0,NULL,0,NULL,0);
INSERT INTO asset VALUES ('ImmYJRWOPFedzI4Bg1k6GA','DC1etlIaBRQitXnchZKvUw','000001000002000004000001000005','published','WebGUI::Asset::Post::Thread','Look Great','Look Great','look_great',946710000,2114406000,'3','7','3','<img src=\"^Extras;styles/webgui6/img_look_great.gif\" align=\"right\" style=\"padding-left: 15px;\" />Let Plain Black\'s design team build you a professional looking design. Our award-winning designers can get you the look you need on time and on budget, every time.',0,1,0,0,260,0,NULL,0,NULL,0);
INSERT INTO asset VALUES ('2TqQc4OISddWCZmRY1_m8A','68sKwDgf9cGH58-NZcU4lg','000001000002000005','published','WebGUI::Asset::Wobject::Layout','The Latest News','The Latest News','the_latest_news',946710000,2082783600,'3','7','3','',0,0,0,0,569,0,NULL,0,'',0);
INSERT INTO asset VALUES ('fK-HMSboA3uu0c1KYkYspA','2TqQc4OISddWCZmRY1_m8A','000001000002000005000001','published','WebGUI::Asset::Wobject::SyndicatedContent','The Latest News','The Latest News','the_latest_news/the_latest_news',946710000,2082783600,'3','7','3',NULL,0,1,0,0,552,0,NULL,0,NULL,0);
INSERT INTO asset VALUES ('Swf6L8poXKc7hUaNPkBevw','68sKwDgf9cGH58-NZcU4lg','000001000002000006','published','WebGUI::Asset::Wobject::Layout','Tell A Friend','Tell A Friend','tell_a_friend',946710000,2082783600,'3','7','3','',0,0,0,0,563,0,NULL,0,'',0);
INSERT INTO asset VALUES ('Szs5eev3OMssmnsyLRZmWA','Swf6L8poXKc7hUaNPkBevw','000001000002000006000001','published','WebGUI::Asset::Wobject::DataForm','Tell A Friend','Tell A Friend','tell_a_friend/tell_a_friend',946710000,2082783600,'3','7','3',NULL,0,1,0,0,472,0,NULL,0,NULL,0);
INSERT INTO asset VALUES ('x3OFY6OJh_qsXkZfPwug4A','68sKwDgf9cGH58-NZcU4lg','000001000002000007','published','WebGUI::Asset::Wobject::Layout','Site Map','Site Map','site_map',946710000,2082783600,'3','7','3','',0,0,0,0,548,0,NULL,0,'',0);
INSERT INTO asset VALUES ('pJd5TLAjfWMVXD6sCRLwUg','x3OFY6OJh_qsXkZfPwug4A','000001000002000007000001','published','WebGUI::Asset::Wobject::Navigation','Site Map','Site Map','site_map/site_map',1001744792,1336444487,'3','7','3',NULL,0,1,0,0,440,0,NULL,0,NULL,0);
INSERT INTO asset VALUES ('Wmjn6I1fe9DKhiIR39YC0g','PBasset000000000000002','000001000001000001','published','WebGUI::Asset::Wobject::Folder','Navigation Configurations','Navigation Configurations','navigation_configurations',997995720,9223372036854775807,'3','4','4',NULL,0,1,0,0,0,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBnav00000000000000001','Wmjn6I1fe9DKhiIR39YC0g','000001000001000001000001','published','WebGUI::Asset::Wobject::Navigation','crumbTrail','crumbTrail','crumbtrail',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,516,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBnav00000000000000014','Wmjn6I1fe9DKhiIR39YC0g','000001000001000001000002','published','WebGUI::Asset::Wobject::Navigation','FlexMenu','FlexMenu','flexmenu',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,498,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBnav00000000000000015','Wmjn6I1fe9DKhiIR39YC0g','000001000001000001000003','published','WebGUI::Asset::Wobject::Navigation','currentMenuVertical','currentMenuVertical','currentmenuvertical',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,539,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBnav00000000000000016','Wmjn6I1fe9DKhiIR39YC0g','000001000001000001000004','published','WebGUI::Asset::Wobject::Navigation','currentMenuHorizontal','currentMenuHorizontal','currentmenuhorizontal',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,545,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBnav00000000000000017','Wmjn6I1fe9DKhiIR39YC0g','000001000001000001000005','published','WebGUI::Asset::Wobject::Navigation','PreviousDropMenu','PreviousDropMenu','previousdropmenu',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,533,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBnav00000000000000018','Wmjn6I1fe9DKhiIR39YC0g','000001000001000001000006','published','WebGUI::Asset::Wobject::Navigation','previousMenuVertical','previousMenuVertical','previousmenuvertical',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,543,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBnav00000000000000019','Wmjn6I1fe9DKhiIR39YC0g','000001000001000001000007','published','WebGUI::Asset::Wobject::Navigation','previousMenuHorizontal','previousMenuHorizontal','previousmenuhorizontal',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,549,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBnav00000000000000020','Wmjn6I1fe9DKhiIR39YC0g','000001000001000001000008','published','WebGUI::Asset::Wobject::Navigation','rootmenu','rootmenu','rootmenu',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,500,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBnav00000000000000021','Wmjn6I1fe9DKhiIR39YC0g','000001000001000001000009','published','WebGUI::Asset::Wobject::Navigation','SpecificDropMenu','SpecificDropMenu','specificdropmenu',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,524,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBnav00000000000000002','Wmjn6I1fe9DKhiIR39YC0g','000001000001000001000010','published','WebGUI::Asset::Wobject::Navigation','SpecificSubMenuVertical','SpecificSubMenuVertical','specificsubmenuvertical',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,545,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBnav00000000000000006','Wmjn6I1fe9DKhiIR39YC0g','000001000001000001000011','published','WebGUI::Asset::Wobject::Navigation','SpecificSubMenuHorizontal','SpecificSubMenuHorizontal','specificsubmenuhorizontal',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,551,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBnav00000000000000007','Wmjn6I1fe9DKhiIR39YC0g','000001000001000001000012','published','WebGUI::Asset::Wobject::Navigation','TopLevelMenuVertical','TopLevelMenuVertical','toplevelmenuvertical',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,536,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBnav00000000000000008','Wmjn6I1fe9DKhiIR39YC0g','000001000001000001000013','published','WebGUI::Asset::Wobject::Navigation','TopLevelMenuHorizontal','TopLevelMenuHorizontal','toplevelmenuhorizontal',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,542,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBnav00000000000000009','Wmjn6I1fe9DKhiIR39YC0g','000001000001000001000014','published','WebGUI::Asset::Wobject::Navigation','RootTab','RootTab','roottab',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,497,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBnav00000000000000010','Wmjn6I1fe9DKhiIR39YC0g','000001000001000001000015','published','WebGUI::Asset::Wobject::Navigation','TopDropMenu','TopDropMenu','topdropmenu',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,483,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBnav00000000000000011','Wmjn6I1fe9DKhiIR39YC0g','000001000001000001000016','published','WebGUI::Asset::Wobject::Navigation','dtree','dtree','dtree',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,497,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBnav00000000000000012','Wmjn6I1fe9DKhiIR39YC0g','000001000001000001000017','published','WebGUI::Asset::Wobject::Navigation','coolmenu','coolmenu','coolmenu',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,501,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBnav00000000000000013','Wmjn6I1fe9DKhiIR39YC0g','000001000001000001000018','published','WebGUI::Asset::Wobject::Navigation','Synopsis','Synopsis','synopsis',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,512,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('f2bihDeMoI-Ojt2dutJNQA','Wmjn6I1fe9DKhiIR39YC0g','000001000001000001000019','published','WebGUI::Asset::Wobject::Navigation','TopLevelMenuHorizontal_1000','TopLevelMenuHorizontal_1000','toplevelmenuhorizontal_1000',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,534,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('KZ2UytxNpbF-3Eg3RNvQQQ','Wmjn6I1fe9DKhiIR39YC0g','000001000001000001000020','published','WebGUI::Asset::Wobject::Navigation','currentMenuHorizontal_1001','currentMenuHorizontal_1001','currentmenuhorizontal_1001',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,563,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('G0wlShbk_XruYVfbXqWq_w','Wmjn6I1fe9DKhiIR39YC0g','000001000001000001000021','published','WebGUI::Asset::Wobject::Navigation','FlexMenu_1002','FlexMenu_1002','flexmenu_1002',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,513,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('UE5_3bD7kWDLUN2B-iuNuA','PBasset000000000000002','000001000001000002','published','WebGUI::Asset::Wobject::Folder','Files, Snippets, and Images','Files, Snippets, and Images','collateral',997995720,9223372036854775807,'3','4','4',NULL,0,1,0,0,0,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('RTsbVBEYnn3OPZWmXyIFhQ','PBasset000000000000002','000001000001000003','published','WebGUI::Asset::Wobject::Folder','Templates','Templates','templates',997995720,9223372036854775807,'3','4','4',NULL,0,1,0,0,0,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000103','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000001','published','WebGUI::Asset::Template','Left Align Image','Left Align Image','left_align_image',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,1417,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000105','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000002','published','WebGUI::Asset::Template','Calendar Month (Small)','Calendar Month (Small)','calendar_month_small',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,2194,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000023','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000003','published','WebGUI::Asset::Template','Default Event','Default Event','default_event',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,756,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000086','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000004','published','WebGUI::Asset::Template','Events List','Events List','events_list',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,1568,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000084','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000005','published','WebGUI::Asset::Template','Center Image','Center Image','center_image',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,1228,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000002','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000006','published','WebGUI::Asset::Template','Default Article','Default Article','default_article',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,1416,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000115','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000007','published','WebGUI::Asset::Template','Linked Image with Caption','Linked Image with Caption','linked_image_with_caption',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,1571,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000066','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000008','published','WebGUI::Asset::Template','Default USS','Default USS','default_uss',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,1702,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000080','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000009','published','WebGUI::Asset::Template','FAQ','FAQ','faq',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,1132,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000097','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000010','published','WebGUI::Asset::Template','Traditional with Thumbnails','Traditional with Thumbnails','traditional_with_thumbnails',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,1640,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000112','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000011','published','WebGUI::Asset::Template','Weblog','Weblog','weblog',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,10881,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000121','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000012','published','WebGUI::Asset::Template','Photo Gallery','Photo Gallery','photo_gallery',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,1148,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000067','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000013','published','WebGUI::Asset::Template','Default Submission','Default Submission','default_submission',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,11190,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000026','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000014','published','WebGUI::Asset::Template','Default Forum','Default Forum','default_forum',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,2449,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000128','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000015','published','WebGUI::Asset::Template','Classifieds','Classifieds','classifieds',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,1242,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000079','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000016','published','WebGUI::Asset::Template','Topics','Topics','topics',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,865,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000083','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000017','published','WebGUI::Asset::Template','Link List','Link List','link_list',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,1068,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000082','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000018','published','WebGUI::Asset::Template','Unordered List','Unordered List','unordered_list',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,1066,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000056','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000019','published','WebGUI::Asset::Template','Default Product','Default Product','default_product',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,4434,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000095','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000020','published','WebGUI::Asset::Template','Benefits Showcase','Benefits Showcase','benefits_showcase',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,2168,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000110','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000021','published','WebGUI::Asset::Template','Three Columns','Three Columns','three_columns',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,3782,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000135','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000022','published','WebGUI::Asset::Template','Side By Side','Side By Side','side_by_side',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,1729,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000131','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000023','published','WebGUI::Asset::Template','Right Column','Right Column','right_column',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,1729,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000119','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000024','published','WebGUI::Asset::Template','Left Column Collateral','Left Column Collateral','left_column_collateral',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,2491,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000054','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000025','published','WebGUI::Asset::Template','Default Page','Default Page','default_page',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,921,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000024','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000026','published','WebGUI::Asset::Template','File','File','file',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,212,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000088','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000027','published','WebGUI::Asset::Template','Image','Image','image',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,147,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000078','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000028','published','WebGUI::Asset::Template','File Folder','File Folder','file_folder',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,1059,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000125','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000029','published','WebGUI::Asset::Template','Left Column','Left Column','left_column',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,1727,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000118','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000030','published','WebGUI::Asset::Template','Three Over One','Three Over One','three_over_one',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,2916,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000109','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000031','published','WebGUI::Asset::Template','One Over Three','One Over Three','one_over_three',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,2914,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000094','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000032','published','WebGUI::Asset::Template','News','News','news',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,2883,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000133','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000033','published','WebGUI::Asset::Template','Guest Book','Guest Book','guest_book',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,865,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000065','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000034','published','WebGUI::Asset::Template','Default Syndicated Content','Default Syndicated Content','default_syndicated_content',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,799,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000055','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000035','published','WebGUI::Asset::Template','Default Poll','Default Poll','default_poll',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,1114,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000020','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000036','published','WebGUI::Asset::Template','Mail Form','Mail Form','mail_form',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,1620,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000085','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000037','published','WebGUI::Asset::Template','Default Email','Default Email','default_email',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,254,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000104','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000038','published','WebGUI::Asset::Template','Default Acknowledgement','Default Acknowledgement','default_acknowledgement',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,479,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000021','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000039','published','WebGUI::Asset::Template','Data List','Data List','data_list',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,793,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000033','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000040','published','WebGUI::Asset::Template','Default HTTP Proxy','Default HTTP Proxy','default_http_proxy',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,871,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000047','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000041','published','WebGUI::Asset::Template','Default Message Board','Default Message Board','default_message_board',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,2119,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000029','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000042','published','WebGUI::Asset::Template','Default Post Form','Default Post Form','default_post_form',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,976,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000032','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000043','published','WebGUI::Asset::Template','Default Thread','Default Thread','default_thread',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,9673,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000027','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000044','published','WebGUI::Asset::Template','Default Forum Notification','Default Forum Notification','default_forum_notification',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,155,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000031','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000045','published','WebGUI::Asset::Template','Default Forum Search','Default Forum Search','default_forum_search',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,1866,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000071','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000046','published','WebGUI::Asset::Template','AutoGen ^t;','AutoGen ^t;','autogen_t',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,463,1109194981,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000075','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000047','published','WebGUI::Asset::Template','AutoGen ^m;','AutoGen ^m;','autogen_m',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,464,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('GNvjCFQWjY2AF2uf0aCM8Q','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000048','published','WebGUI::Asset::Template','Syndicated Articles','Syndicated Articles','syndicated_articles',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,792,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000068','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000049','published','WebGUI::Asset::Template','Default Submission Form','Default Submission Form','default_submission_form',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,870,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000099','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000050','published','WebGUI::Asset::Template','FAQ Submission Form','FAQ Submission Form','faq_submission_form',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,657,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000114','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000051','published','WebGUI::Asset::Template','Link List Submission Form','Link List Submission Form','link_list_submission_form',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,812,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000092','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000052','published','WebGUI::Asset::Template','Horizontal Login Box','Horizontal Login Box','horizontal_login_box',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,897,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000044','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000053','published','WebGUI::Asset::Template','Default Login Box','Default Login Box','default_login_box',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,844,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000059','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000054','published','WebGUI::Asset::Template','Default SQL Report','Default SQL Report','default_sql_report',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,4016,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000050','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000055','published','WebGUI::Asset::Template','Default Messsage Log Display Template','Default Messsage Log Display Template','default_messsage_log_display_template',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,1334,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000049','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000056','published','WebGUI::Asset::Template','Default MessageLog Message Template','Default MessageLog Message Template','default_messagelog_message_template',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,427,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000051','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000057','published','WebGUI::Asset::Template','Default Edit Profile Template','Default Edit Profile Template','default_edit_profile_template',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,1330,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000052','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000058','published','WebGUI::Asset::Template','Default Profile Display Template','Default Profile Display Template','default_profile_display_template',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,593,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000126','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000059','published','WebGUI::Asset::Template','lastResort','lastResort','lastresort',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,504,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000063','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000060','published','WebGUI::Asset::Template','Default Overview Report','Default Overview Report','default_overview_report',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,3098,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000062','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000061','published','WebGUI::Asset::Template','Default Gradebook Report','Default Gradebook Report','default_gradebook_report',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,1411,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000061','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000062','published','WebGUI::Asset::Template','Default Survey','Default Survey','default_survey',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,3117,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000064','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000063','published','WebGUI::Asset::Template','Default Response','Default Response','default_response',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,1613,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000116','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000064','published','WebGUI::Asset::Template','Tab Form','Tab Form','tab_form',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,2348,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000069','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000065','published','WebGUI::Asset::Template','Xmethods: getTemp','Xmethods: getTemp','xmethods_gettemp',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,359,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000100','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000066','published','WebGUI::Asset::Template','Google: doGoogleSearch','Google: doGoogleSearch','google_dogooglesearch',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,1397,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000035','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000067','published','WebGUI::Asset::Template','Default Admin Bar','Default Admin Bar','default_admin_bar',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,1810,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000090','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000068','published','WebGUI::Asset::Template','DHTML Admin Bar','DHTML Admin Bar','dhtml_admin_bar',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,4440,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000093','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000069','published','WebGUI::Asset::Template','crumbTrail','crumbTrail','crumbtrail2',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,462,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000048','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000070','published','WebGUI::Asset::Template','verticalMenu','verticalMenu','verticalmenu',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,569,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000108','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000071','published','WebGUI::Asset::Template','horizontalMenu','horizontalMenu','horizontalmenu',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,474,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000117','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000072','published','WebGUI::Asset::Template','DropMenu','DropMenu','dropmenu',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,757,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000124','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000073','published','WebGUI::Asset::Template','Tabs','Tabs','tabs',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,489,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000130','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000074','published','WebGUI::Asset::Template','dtree','dtree','dtree2',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,909,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000022','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000075','published','WebGUI::Asset::Template','Calendar Month (Big)','Calendar Month (Big)','calendar_month_big',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,2137,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000134','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000076','published','WebGUI::Asset::Template','Cool Menus','Cool Menus','cool_menus',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,6334,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000034','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000077','published','WebGUI::Asset::Template','Default Search','Default Search','default_search',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,2477,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000077','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000078','published','WebGUI::Asset::Template','Job Listing','Job Listing','job_listing',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,1294,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000098','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000079','published','WebGUI::Asset::Template','Job','Job','job',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,1423,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000122','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000080','published','WebGUI::Asset::Template','Job Submission Form','Job Submission Form','job_submission_form',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,796,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000136','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000081','published','WebGUI::Asset::Template','Synopsis','Synopsis','synopsis2',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,605,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000013','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000082','published','WebGUI::Asset::Template','Default WebGUI Login Template','Default WebGUI Login Template','default_webgui_login_template',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,1019,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000010','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000083','published','WebGUI::Asset::Template','Default WebGUI Account Display Template','Default WebGUI Account Display Template','default_webgui_account_display_template',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,1183,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000011','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000084','published','WebGUI::Asset::Template','Default WebGUI Anonymous Registration Template','Default WebGUI Anonymous Registration Template','default_webgui_anonymous_registration_template',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,1305,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000014','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000085','published','WebGUI::Asset::Template','Default WebGUI Password Recovery Template','Default WebGUI Password Recovery Template','default_webgui_password_recovery_template',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,803,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000012','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000086','published','WebGUI::Asset::Template','Default WebGUI Password Reset Template','Default WebGUI Password Reset Template','default_webgui_password_reset_template',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,944,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000006','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000087','published','WebGUI::Asset::Template','Default LDAP Login Template','Default LDAP Login Template','default_ldap_login_template',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,874,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000004','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000088','published','WebGUI::Asset::Template','Default LDAP Account Display Template','Default LDAP Account Display Template','default_ldap_account_display_template',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,456,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000005','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000089','published','WebGUI::Asset::Template','Default LDAP Anonymous Registration Template','Default LDAP Anonymous Registration Template','default_ldap_anonymous_registration_template',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,1004,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000057','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000093','published','WebGUI::Asset::Template','Default WebGUI Yes/No Prompt','Default WebGUI Yes/No Prompt','default_webgui_yes/no_prompt',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,232,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000060','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000094','published','WebGUI::Asset::Template','Fail Safe','Fail Safe','fail_safe',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,776,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('9tBSOV44a9JPS8CcerOvYw','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000095','published','WebGUI::Asset::Template','WebGUI 6 Admin Style','WebGUI 6 Admin Style','webgui_6_admin_style',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,2530,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('B1bNjWVtzSjsvGZh9lPz_A','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000096','published','WebGUI::Asset::Template','WebGUI 6','WebGUI 6','webgui_6',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,7898,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000111','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000097','published','WebGUI::Asset::Template','Make Page Printable','Make Page Printable','make_page_printable',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,1756,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000137','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000098','published','WebGUI::Asset::Template','Admin Console','Admin Console','admin_console',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,503,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000132','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000099','published','WebGUI::Asset::Template','Empty','Empty','empty',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,23,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000123','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000100','published','WebGUI::Asset::Template','Item','Item','item',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,644,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000129','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000101','published','WebGUI::Asset::Template','Item w/pop-up Links','Item w/pop-up Links','item_w/pop-up_links',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,676,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000081','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000102','published','WebGUI::Asset::Template','Q and A','Q and A','q_and_a',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,876,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000101','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000103','published','WebGUI::Asset::Template','Ordered List','Ordered List','ordered_list',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,1067,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000102','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000104','published','WebGUI::Asset::Template','Descriptive','Descriptive','descriptive',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,1059,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('wCIc38CvNHUK7aY92Ww4SQ','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000105','published','WebGUI::Asset::Template','Titled Link List','Titled Link List','titled_link_list',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,1038,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000113','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000106','published','WebGUI::Asset::Template','Link','Link','link',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,797,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000037','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000107','published','WebGUI::Asset::Template','Default Account Macro','Default Account Macro','default_account_macro',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,82,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000038','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000108','published','WebGUI::Asset::Template','Default Editable Toggle Macro','Default Editable Toggle Macro','default_editable_toggle_macro',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,58,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000036','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000109','published','WebGUI::Asset::Template','Default Admin Toggle Macro','Default Admin Toggle Macro','default_admin_toggle_macro',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,58,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000039','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000110','published','WebGUI::Asset::Template','Default File Macro','Default File Macro','default_file_macro',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,114,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000091','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000111','published','WebGUI::Asset::Template','File no icon','File no icon','file_no_icon',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,54,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000107','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000112','published','WebGUI::Asset::Template','File with size','File with size','file_with_size',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,136,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000040','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000113','published','WebGUI::Asset::Template','Default Group Add Macro','Default Group Add Macro','default_group_add_macro',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,56,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000041','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000114','published','WebGUI::Asset::Template','Default Group Delete Macro','Default Group Delete Macro','default_group_delete_macro',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,56,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000042','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000115','published','WebGUI::Asset::Template','Default Homelink','Default Homelink','default_homelink',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,79,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000045','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000116','published','WebGUI::Asset::Template','Default Make Printable','Default Make Printable','default_make_printable',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,90,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000043','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000117','published','WebGUI::Asset::Template','Default LoginToggle','Default LoginToggle','default_logintoggle',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,82,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000003','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000118','published','WebGUI::Asset::Template','Attachment Box','Attachment Box','attachment_box',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,477,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000138','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000119','published','WebGUI::Asset::Template','TinyMCE','TinyMCE','tinymce',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,734,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000053','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000120','published','WebGUI::Asset::Template','Subscription code redemption','Subscription code redemption','subscription_code_redemption',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,121,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000046','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000121','published','WebGUI::Asset::Template','Subscriptionitem default template','Subscriptionitem default template','subscriptionitem_default_template',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,136,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000018','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000122','published','WebGUI::Asset::Template','Default transaction error template','Default transaction error template','default_transaction_error_template',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,484,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000016','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000123','published','WebGUI::Asset::Template','Default checkout confirmation template','Default checkout confirmation template','default_checkout_confirmation_template',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,429,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000019','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000124','published','WebGUI::Asset::Template','Default view purchase history template','Default view purchase history template','default_view_purchase_history_template',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,540,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000015','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000125','published','WebGUI::Asset::Template','Default cancel checkout template','Default cancel checkout template','default_cancel_checkout_template',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,18,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000017','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000126','published','WebGUI::Asset::Template','Default payment gateway selection template','Default payment gateway selection template','default_payment_gateway_selection_template',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,468,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000001','RTsbVBEYnn3OPZWmXyIFhQ','000001000001000003000127','published','WebGUI::Asset::Template','Admin Console','Admin Console','admin_console2',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,2754,1109194982,NULL,0,NULL,0);
INSERT INTO asset VALUES ('PBtmpl0000000000000140','PBasset000000000000002','000001000001000004','published','WebGUI::Asset::Template','Default Shortcut','Default Shortcut','PBtmpl0000000000000140',997995720,9223372036854775807,'3','7','4',NULL,0,1,0,0,901,1109194982,NULL,0,NULL,0);

--
-- Table structure for table `assetHistory`
--

CREATE TABLE assetHistory (
  assetId varchar(22) NOT NULL default '',
  userId varchar(22) NOT NULL default '',
  dateStamp bigint(20) NOT NULL default '0',
  actionTaken varchar(255) NOT NULL default ''
) TYPE=MyISAM;

--
-- Dumping data for table `assetHistory`
--


INSERT INTO assetHistory VALUES ('PBasset000000000000002','1',1109194982,'added child PBtmpl0000000000000140');
INSERT INTO assetHistory VALUES ('PBtmpl0000000000000140','1',1109194982,'created');

--
-- Table structure for table `authentication`
--

CREATE TABLE authentication (
  userId varchar(22) NOT NULL default '',
  authMethod varchar(30) NOT NULL default '',
  fieldName varchar(128) NOT NULL default '',
  fieldData text,
  PRIMARY KEY  (userId,authMethod,fieldName)
) TYPE=MyISAM;

--
-- Dumping data for table `authentication`
--


INSERT INTO authentication VALUES ('1','LDAP','ldapUrl',NULL);
INSERT INTO authentication VALUES ('3','LDAP','ldapUrl','');
INSERT INTO authentication VALUES ('1','LDAP','connectDN',NULL);
INSERT INTO authentication VALUES ('3','LDAP','connectDN','');
INSERT INTO authentication VALUES ('1','WebGUI','identifier','No Login');
INSERT INTO authentication VALUES ('3','WebGUI','identifier','RvlMjeFPs2aAhQdo/xt/Kg');
INSERT INTO authentication VALUES ('1','WebGUI','passwordLastUpdated','1078704037');
INSERT INTO authentication VALUES ('1','WebGUI','passwordTimeout','3122064000');
INSERT INTO authentication VALUES ('1','WebGUI','changeUsername','1');
INSERT INTO authentication VALUES ('1','WebGUI','changePassword','1');
INSERT INTO authentication VALUES ('3','WebGUI','passwordLastUpdated','1078704037');
INSERT INTO authentication VALUES ('3','WebGUI','passwordTimeout','3122064000');
INSERT INTO authentication VALUES ('3','WebGUI','changeUsername','1');
INSERT INTO authentication VALUES ('3','WebGUI','changePassword','1');

--
-- Table structure for table `commerceSettings`
--

CREATE TABLE commerceSettings (
  fieldName varchar(64) NOT NULL default '',
  fieldValue varchar(255) NOT NULL default '',
  namespace varchar(64) NOT NULL default '',
  type varchar(10) NOT NULL default ''
) TYPE=MyISAM;

--
-- Dumping data for table `commerceSettings`
--



--
-- Table structure for table `databaseLink`
--

CREATE TABLE databaseLink (
  databaseLinkId varchar(22) NOT NULL default '',
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
-- Table structure for table `groupGroupings`
--

CREATE TABLE groupGroupings (
  groupId char(22) NOT NULL default '',
  inGroup char(22) NOT NULL default ''
) TYPE=MyISAM;

--
-- Dumping data for table `groupGroupings`
--


INSERT INTO groupGroupings VALUES ('4','12');
INSERT INTO groupGroupings VALUES ('6','12');
INSERT INTO groupGroupings VALUES ('8','12');
INSERT INTO groupGroupings VALUES ('9','12');
INSERT INTO groupGroupings VALUES ('11','12');
INSERT INTO groupGroupings VALUES ('3','2');
INSERT INTO groupGroupings VALUES ('3','4');
INSERT INTO groupGroupings VALUES ('3','5');
INSERT INTO groupGroupings VALUES ('3','6');
INSERT INTO groupGroupings VALUES ('3','7');
INSERT INTO groupGroupings VALUES ('3','8');
INSERT INTO groupGroupings VALUES ('3','9');
INSERT INTO groupGroupings VALUES ('3','13');
INSERT INTO groupGroupings VALUES ('3','11');
INSERT INTO groupGroupings VALUES ('3','12');

--
-- Table structure for table `groupings`
--

CREATE TABLE groupings (
  groupId char(22) NOT NULL default '',
  userId char(22) NOT NULL default '',
  expireDate int(11) NOT NULL default '2114402400',
  groupAdmin int(11) NOT NULL default '0',
  PRIMARY KEY  (groupId,userId)
) TYPE=MyISAM;

--
-- Dumping data for table `groupings`
--


INSERT INTO groupings VALUES ('1','1',2114402400,0);
INSERT INTO groupings VALUES ('3','3',2114402400,0);
INSERT INTO groupings VALUES ('7','1',2114402400,0);
INSERT INTO groupings VALUES ('7','3',2114402400,0);
INSERT INTO groupings VALUES ('2','3',2114402400,0);

--
-- Table structure for table `groups`
--

CREATE TABLE groups (
  groupId varchar(22) NOT NULL default '',
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
  databaseLinkId varchar(22) default NULL,
  dbCacheTimeout int(11) NOT NULL default '3600',
  dbQuery text,
  isEditable int(11) NOT NULL default '1',
  showInForms int(11) NOT NULL default '1',
  PRIMARY KEY  (groupId)
) TYPE=MyISAM;

--
-- Dumping data for table `groups`
--


INSERT INTO groups VALUES ('1','Visitors','This is the public group that has no privileges.',314496000,1000000000,NULL,997938000,997938000,14,-14,NULL,0,NULL,0,0,'0',3600,NULL,0,1);
INSERT INTO groups VALUES ('2','Registered Users','All registered users belong to this group automatically. There are no associated privileges other than that the user has an account and is logged in.',314496000,1000000000,NULL,997938000,997938000,14,-14,NULL,0,NULL,0,0,'0',3600,NULL,0,1);
INSERT INTO groups VALUES ('3','Admins','Anyone who belongs to this group has privileges to do anything and everything.',314496000,1000000000,NULL,997938000,997938000,14,-14,NULL,0,NULL,0,0,'0',3600,NULL,1,1);
INSERT INTO groups VALUES ('4','Content Managers','Users that have privileges to edit content on this site. The user still needs to be added to a group that has editing privileges on specific pages.',314496000,1000000000,NULL,997938000,997938000,14,-14,NULL,0,NULL,0,0,'0',3600,NULL,1,1);
INSERT INTO groups VALUES ('6','Package Managers','Users that have privileges to add, edit, and delete packages of wobjects and pages to deploy.',314496000,1000000000,NULL,997938000,997938000,14,-14,NULL,0,NULL,0,0,'0',3600,NULL,1,1);
INSERT INTO groups VALUES ('7','Everyone','A group that automatically includes all users including Visitors.',314496000,1000000000,NULL,997938000,997938000,14,-14,NULL,0,NULL,0,0,'0',3600,NULL,0,1);
INSERT INTO groups VALUES ('8','Template Managers','Users that have privileges to edit templates for this site.',314496000,1000000000,NULL,997938000,997938000,14,-14,NULL,0,NULL,0,0,'0',3600,NULL,1,1);
INSERT INTO groups VALUES ('9','Theme Managers','Users in this group can use the theme manager to create new themes and install themes from other systems.',314496000,1000000000,NULL,997938000,997938000,14,-14,NULL,0,NULL,0,0,'0',3600,NULL,1,1);
INSERT INTO groups VALUES ('13','Export Managers','Users in this group can export pages to disk.',314496000,1000000000,NULL,997938000,997938000,14,-14,NULL,0,NULL,0,0,'0',3600,NULL,1,1);
INSERT INTO groups VALUES ('11','Secondary Admins','Users that have limited administrative privileges.',314496000,1000000000,NULL,997938000,997938000,14,-14,NULL,0,NULL,0,0,'0',3600,NULL,1,1);
INSERT INTO groups VALUES ('12','Turn Admin On','These users can enable admin mode.',314496000,1000000000,NULL,997938000,997938000,14,-14,NULL,0,NULL,0,0,'0',3600,NULL,1,0);
INSERT INTO groups VALUES ('a7jbpVdbzxchqtSj_9W71w','DC1etlIaBRQitXnchZKvUw','The group to store subscriptions for the collaboration system DC1etlIaBRQitXnchZKvUw',314496000,1000000000,NULL,1109194980,1109194980,14,-14,NULL,0,NULL,0,0,NULL,3600,NULL,0,0);
INSERT INTO groups VALUES ('wP1Lt8NIySq9MS8xPGnAsQ','pSygeMG7bSL1Za0SNqfUbw','The group to store subscriptions for the thread pSygeMG7bSL1Za0SNqfUbw',314496000,1000000000,NULL,1109194980,1109194980,14,-14,NULL,0,NULL,0,0,NULL,3600,NULL,0,0);
INSERT INTO groups VALUES ('OL-d6C93EeUr4Rja-q3-yQ','mdIaXozmVNE_Rga2BY0mxA','The group to store subscriptions for the thread mdIaXozmVNE_Rga2BY0mxA',314496000,1000000000,NULL,1109194980,1109194980,14,-14,NULL,0,NULL,0,0,NULL,3600,NULL,0,0);
INSERT INTO groups VALUES ('YPCggIxdKT3AMMlML-CAuw','9kDcFufTKbMTkeAHyP36fw','The group to store subscriptions for the thread 9kDcFufTKbMTkeAHyP36fw',314496000,1000000000,NULL,1109194980,1109194980,14,-14,NULL,0,NULL,0,0,NULL,3600,NULL,0,0);
INSERT INTO groups VALUES ('C02CXMw3c42EJJR_nktyMw','5Y8eOI2u_HOvkzrRuLdz1g','The group to store subscriptions for the thread 5Y8eOI2u_HOvkzrRuLdz1g',314496000,1000000000,NULL,1109194980,1109194980,14,-14,NULL,0,NULL,0,0,NULL,3600,NULL,0,0);
INSERT INTO groups VALUES ('zZmjNsD1FhaSFkgXvnCQUg','ImmYJRWOPFedzI4Bg1k6GA','The group to store subscriptions for the thread ImmYJRWOPFedzI4Bg1k6GA',314496000,1000000000,NULL,1109194980,1109194980,14,-14,NULL,0,NULL,0,0,NULL,3600,NULL,0,0);

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



--
-- Table structure for table `karmaLog`
--

CREATE TABLE karmaLog (
  userId varchar(22) default NULL,
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
  messageLogId varchar(22) NOT NULL default '',
  userId varchar(22) NOT NULL default '',
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
-- Table structure for table `metaData_properties`
--

CREATE TABLE metaData_properties (
  fieldId varchar(22) NOT NULL default '',
  fieldName varchar(100) NOT NULL default '',
  description mediumtext NOT NULL,
  fieldType varchar(30) default NULL,
  possibleValues text,
  defaultValue varchar(100) default NULL,
  PRIMARY KEY  (fieldId),
  UNIQUE KEY field_unique (fieldName)
) TYPE=MyISAM;

--
-- Dumping data for table `metaData_properties`
--



--
-- Table structure for table `metaData_values`
--

CREATE TABLE metaData_values (
  fieldId varchar(22) NOT NULL default '',
  value varchar(100) default NULL,
  assetId varchar(22) NOT NULL default '',
  PRIMARY KEY  (fieldId)
) TYPE=MyISAM;

--
-- Dumping data for table `metaData_values`
--



--
-- Table structure for table `passiveProfileAOI`
--

CREATE TABLE passiveProfileAOI (
  userId varchar(22) NOT NULL default '',
  fieldId varchar(22) NOT NULL default '',
  value varchar(100) NOT NULL default '',
  count int(11) default NULL,
  PRIMARY KEY  (userId,fieldId,value)
) TYPE=MyISAM;

--
-- Dumping data for table `passiveProfileAOI`
--



--
-- Table structure for table `passiveProfileLog`
--

CREATE TABLE passiveProfileLog (
  passiveProfileLogId varchar(22) NOT NULL default '',
  userId varchar(22) default NULL,
  sessionId varchar(60) default NULL,
  wobjectId varchar(22) default NULL,
  dateOfEntry int(11) default '0',
  PRIMARY KEY  (passiveProfileLogId)
) TYPE=MyISAM;

--
-- Dumping data for table `passiveProfileLog`
--



--
-- Table structure for table `redirect`
--

CREATE TABLE redirect (
  assetId varchar(22) NOT NULL default '',
  redirectUrl text,
  PRIMARY KEY  (assetId)
) TYPE=MyISAM;

--
-- Dumping data for table `redirect`
--



--
-- Table structure for table `replacements`
--

CREATE TABLE replacements (
  replacementId varchar(22) NOT NULL default '',
  searchFor varchar(255) default NULL,
  replaceWith text,
  PRIMARY KEY  (replacementId)
) TYPE=MyISAM;

--
-- Dumping data for table `replacements`
--


INSERT INTO replacements VALUES ('1','[quote]','<blockquote><i>');
INSERT INTO replacements VALUES ('2','[/quote]','</i></blockquote>');
INSERT INTO replacements VALUES ('3','[image]','<img src=\"');
INSERT INTO replacements VALUES ('4','[/image]','\" border=\"0\" / >');
INSERT INTO replacements VALUES ('5','shit','crap');
INSERT INTO replacements VALUES ('6','fuck','farg');
INSERT INTO replacements VALUES ('7','asshole','icehole');
INSERT INTO replacements VALUES ('8','nigger','guy');
INSERT INTO replacements VALUES ('9','[b]','<b>');
INSERT INTO replacements VALUES ('10','[/b]','</b>');
INSERT INTO replacements VALUES ('11','[i]','<i>');
INSERT INTO replacements VALUES ('12','[/i]','</i>');

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
INSERT INTO settings VALUES ('notFoundPage','68sKwDgf9cGH58-NZcU4lg');
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
INSERT INTO settings VALUES ('defaultPage','68sKwDgf9cGH58-NZcU4lg');
INSERT INTO settings VALUES ('onNewUserAlertGroup','3');
INSERT INTO settings VALUES ('alertOnNewUser','0');
INSERT INTO settings VALUES ('useKarma','0');
INSERT INTO settings VALUES ('karmaPerLogin','1');
INSERT INTO settings VALUES ('runOnRegistration','');
INSERT INTO settings VALUES ('maxImageSize','100000');
INSERT INTO settings VALUES ('showDebug','0');
INSERT INTO settings VALUES ('richEditCss','^/;site.css');
INSERT INTO settings VALUES ('selfDeactivation','1');
INSERT INTO settings VALUES ('snippetsPreviewLength','30');
INSERT INTO settings VALUES ('mailFooter','^c;\n^e;\n^u;\n');
INSERT INTO settings VALUES ('webguiSendWelcomeMessage','0');
INSERT INTO settings VALUES ('webguiWelcomeMessage','Welcome to our site.');
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
INSERT INTO settings VALUES ('commerceCheckoutCanceledTemplateId','1');
INSERT INTO settings VALUES ('webguiChangePassword','1');
INSERT INTO settings VALUES ('webguiChangeUsername','1');
INSERT INTO settings VALUES ('metaDataEnabled','0');
INSERT INTO settings VALUES ('passiveProfilingEnabled','0');
INSERT INTO settings VALUES ('urlExtension','');
INSERT INTO settings VALUES ('commerceConfirmCheckoutTemplateId','1');
INSERT INTO settings VALUES ('commercePaymentPlugin','PayFlowPro');
INSERT INTO settings VALUES ('commerceSelectPaymentGatewayTemplateId','1');
INSERT INTO settings VALUES ('commerceTransactionErrorTemplateId','1');
INSERT INTO settings VALUES ('AdminConsoleTemplate','PBtmpl0000000000000001');
INSERT INTO settings VALUES ('userFunctionStyleId','B1bNjWVtzSjsvGZh9lPz_A');
INSERT INTO settings VALUES ('webguiValidateEmail','0');
INSERT INTO settings VALUES ('webguiUseCaptcha','1');
INSERT INTO settings VALUES ('webguiAccountTemplate','PBtmpl0000000000000010');
INSERT INTO settings VALUES ('webguiCreateAccountTemplate','PBtmpl0000000000000011');
INSERT INTO settings VALUES ('webguiExpiredPasswordTemplate','PBtmpl0000000000000012');
INSERT INTO settings VALUES ('webguiLoginTemplate','PBtmpl0000000000000013');
INSERT INTO settings VALUES ('webguiPasswordRecoveryTemplate','PBtmpl0000000000000014');
INSERT INTO settings VALUES ('ldapAccountTemplate','PBtmpl0000000000000004');
INSERT INTO settings VALUES ('ldapCreateAccountTemplate','PBtmpl0000000000000005');
INSERT INTO settings VALUES ('ldapLoginTemplate','PBtmpl0000000000000006');
INSERT INTO settings VALUES ('specialState','init');

--
-- Table structure for table `shoppingCart`
--

CREATE TABLE shoppingCart (
  sessionId varchar(22) NOT NULL default '',
  itemId varchar(64) NOT NULL default '',
  itemType varchar(40) NOT NULL default '',
  quantity int(4) NOT NULL default '0',
  PRIMARY KEY  (sessionId,itemId,itemType)
) TYPE=MyISAM;

--
-- Dumping data for table `shoppingCart`
--



--
-- Table structure for table `snippet`
--

CREATE TABLE snippet (
  assetId varchar(22) NOT NULL default '',
  snippet mediumtext,
  PRIMARY KEY  (assetId)
) TYPE=MyISAM;

--
-- Dumping data for table `snippet`
--



--
-- Table structure for table `subscription`
--

CREATE TABLE subscription (
  subscriptionId varchar(22) NOT NULL default '',
  name varchar(128) default NULL,
  price float default '0',
  description mediumtext,
  subscriptionGroup varchar(22) NOT NULL default '',
  duration varchar(12) NOT NULL default 'Monthly',
  executeOnSubscription varchar(128) default NULL,
  karma int(4) default '0',
  deleted int(1) default '0',
  PRIMARY KEY  (subscriptionId)
) TYPE=MyISAM;

--
-- Dumping data for table `subscription`
--



--
-- Table structure for table `subscriptionCode`
--

CREATE TABLE subscriptionCode (
  batchId varchar(22) NOT NULL default '',
  code varchar(64) NOT NULL default '',
  status varchar(10) NOT NULL default 'Unused',
  dateCreated int(11) NOT NULL default '0',
  dateUsed int(11) NOT NULL default '0',
  expires int(11) NOT NULL default '0',
  usedBy varchar(22) NOT NULL default '0',
  PRIMARY KEY  (code)
) TYPE=MyISAM;

--
-- Dumping data for table `subscriptionCode`
--



--
-- Table structure for table `subscriptionCodeBatch`
--

CREATE TABLE subscriptionCodeBatch (
  batchId varchar(22) NOT NULL default '',
  name varchar(128) default NULL,
  description mediumtext NOT NULL,
  subscriptionId varchar(22) NOT NULL default '',
  PRIMARY KEY  (batchId)
) TYPE=MyISAM;

--
-- Dumping data for table `subscriptionCodeBatch`
--



--
-- Table structure for table `subscriptionCodeSubscriptions`
--

CREATE TABLE subscriptionCodeSubscriptions (
  code varchar(64) NOT NULL default '',
  subscriptionId varchar(22) NOT NULL default '',
  UNIQUE KEY code (code,subscriptionId)
) TYPE=MyISAM;

--
-- Dumping data for table `subscriptionCodeSubscriptions`
--



--
-- Table structure for table `template`
--

CREATE TABLE template (
  template mediumtext,
  namespace varchar(35) NOT NULL default 'Page',
  isEditable int(11) NOT NULL default '1',
  showInForms int(11) NOT NULL default '1',
  assetId varchar(22) NOT NULL default '',
  PRIMARY KEY  (assetId)
) TYPE=MyISAM;

--
-- Dumping data for table `template`
--


INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a>\n<tmpl_if session.var.adminOn>\n	<p><tmpl_var controls></p>\n</tmpl_if>	\n		<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.isFirstPage>\r\n<tmpl_if image.url>\r\n  <table width=\"100%\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\"><tr><td class=\"content\">\r\n  <img src=\"<tmpl_var image.url>\" align=\"left\" border=\"0\">\r\n</tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n  <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n\r\n<tmpl_if pagination.isLastPage>\r\n<tmpl_if linkurl>\r\n  <tmpl_if linktitle>\r\n    <p /><a href=\"<tmpl_var linkUrl>\"><tmpl_var linkTitle></a>\r\n  </tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_var attachment.box> <p />\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.isFirstPage>\r\n<tmpl_if image.url>\r\n  </td></tr></table>\r\n</tmpl_if>\r\n</tmpl_if>\r\n\r\n\r\n<tmpl_if pagination.pageCount.isMultiple>\r\n<tmpl_var pagination.previousPage> \r\n&middot;\r\n<tmpl_var pagination.pageList.upTo20>\r\n&middot;\r\n<tmpl_var pagination.nextPage>\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.isLastPage>\r\n\r\n<tmpl_if allowDiscussion>\r\n  <p><table width=\"100%\" cellspacing=\"2\" cellpadding=\"1\" border=\"0\">\r\n  <tr><td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var replies.URL>\"><tmpl_var replies.label> (<tmpl_var replies.count>)</a></td>\r\n  <td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var post.url>\"><tmpl_var post.label></a></td></tr>\r\n  </table>\r\n</tmpl_if>\r\n\r\n</tmpl_if>','Article',1,1,'PBtmpl0000000000000103');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a> <tmpl_if session.var.adminOn> <p><tmpl_var controls></p> </tmpl_if><tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_if session.var.adminOn>\r\n    <a href=\"<tmpl_var addevent.url>\"><tmpl_var addevent.label></a>\r\n    <p />\r\n</tmpl_if>\r\n\r\n\n\n\n<tmpl_loop month_loop>\n	<table border=\"1\" width=\"100%\">\n	<tr><td colspan=7 class=\"tableHeader\"><h2 align=\"center\"><tmpl_var month> <tmpl_var year></h2></td></tr>\n	<tr>\n	<tmpl_if session.user.firstDayOfWeek>\n		<th class=\"tableData\"><tmpl_var monday.label.short></th>\n		<th class=\"tableData\"><tmpl_var tuesday.label.short></th>\n		<th class=\"tableData\"><tmpl_var wednesday.label.short></th>\n		<th class=\"tableData\"><tmpl_var thursday.label.short></th>\n		<th class=\"tableData\"><tmpl_var friday.label.short></th>\n		<th class=\"tableData\"><tmpl_var saturday.label.short></th>\n		<th class=\"tableData\"><tmpl_var sunday.label.short></th>\n	<tmpl_else>\n		<th class=\"tableData\"><tmpl_var sunday.label.short></th>\n		<th class=\"tableData\"><tmpl_var monday.label.short></th>\n		<th class=\"tableData\"><tmpl_var tuesday.label.short></th>\n		<th class=\"tableData\"><tmpl_var wednesday.label.short></th>\n		<th class=\"tableData\"><tmpl_var thursday.label.short></th>\n		<th class=\"tableData\"><tmpl_var friday.label.short></th>\n		<th class=\"tableData\"><tmpl_var saturday.label.short></th>\n	</tmpl_if>\n	</tr><tr>\n	<tmpl_loop prepad_loop>\n		<td>&nbsp;</td>\n	</tmpl_loop>\n 	<tmpl_loop day_loop>\n		<tmpl_if isStartOfWeek>\n			<tr>\n		</tmpl_if>\n		<td class=\"table<tmpl_if isToday>Header<tmpl_else>Data</tmpl_if>\" width=\"28\" valign=\"top\" align=\"left\"><p><b>\n				<tmpl_if url>\n					<a href=\"<tmpl_var url>\"><tmpl_var day></a>\n				<tmpl_else>\n					<tmpl_var day>\n				</tmpl_if>\n		</b></p></td>		\n		<tmpl_if isEndOfWeek>\n			</tr>\n		</tmpl_if>\n	</tmpl_loop>\n	<tmpl_loop postpad_loop>\n		<td>&nbsp;</td>\n	</tmpl_loop>\n	</tr>\n	</table>\n</tmpl_loop>\n\n\n<tmpl_if pagination.pageCount.isMultiple>\n  <div class=\"pagination\">\n    <tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>\n  </div>\n</tmpl_if>\n','EventsCalendar',1,1,'PBtmpl0000000000000105');
INSERT INTO template VALUES ('<h1><tmpl_var title></h1>\r\n\r\n<table width=\"100%\" cellspacing=\"0\" cellpadding=\"5\" border=\"0\">\r\n<tr>\r\n<td valign=\"top\" class=\"tableHeader\" width=\"100%\">\r\n<b><tmpl_var start.label>:</b> <tmpl_var start.date><br />\r\n<b><tmpl_var end.label>:</b> <tmpl_var end.date><br />\r\n</td><td valign=\"top\" class=\"tableMenu\" nowrap=\"1\">\r\n\r\n<tmpl_if canEdit>\r\n     <a href=\"<tmpl_var edit.url>\"><tmpl_var edit.label></a><br />\r\n     <a href=\"<tmpl_var delete.url>\"><tmpl_var delete.label></a><br />\r\n</tmpl_if>\r\n\r\n<tmpl_if previous.url>\r\n     <a href=\"<tmpl_var previous.url>\"><tmpl_var previous.label></a><br />\r\n</tmpl_if>\r\n\r\n<tmpl_if next.url>\r\n     <a href=\"<tmpl_var next.url>\"><tmpl_var next.label></a><br />\r\n</tmpl_if>\r\n\r\n</td></tr>\r\n</table>\r\n<tmpl_var description>','EventsCalendar/Event',1,1,'PBtmpl0000000000000023');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a> <tmpl_if session.var.adminOn> <p><tmpl_var controls></p> </tmpl_if><tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_if session.var.adminOn>\r\n    <a href=\"<tmpl_var addevent.url>\"><tmpl_var addevent.label></a>\r\n    <p />\r\n</tmpl_if>\r\n\r\n\n<tmpl_loop month_loop>\n	<tmpl_loop day_loop>\n		<tmpl_loop event_loop>\n			<tmpl_if isFirstDayOfEvent>\n				<tmpl_unless dateIsSameAsPrevious>\n					<b>\n						<tmpl_var start.day.dayOfWeek> <tmpl_var start.month> <tmpl_var start.day><tmpl_unless startEndYearMatch>,\n						          <tmpl_ start.year> - \n							<tmpl_var end.day.dayOfWeek> <tmpl_var end.month> <tmpl_var end.day></tmpl_unless><tmpl_unless startEndMonthMatch> - <tmpl_var end.day.dayOfWeek> <tmpl_var end.month> <tmpl_var end.day><tmpl_else><tmpl_unless startEndDayMatch> - <tmpl_var end.day></tmpl_unless></tmpl_unless>, <tmpl_var end.year>\n					</b>\n				</tmpl_unless>\n				<blockquote>\n					<tmpl_if session.var.adminOn>\n						<a href=\"<tmpl_var url>\">\n					</tmpl_if>\n					<i><tmpl_var name></i>\n					<tmpl_if session.var.adminOn>\n						</a>\n					</tmpl_if>\n					<tmpl_if description>\n						- <tmpl_var description>\n					</tmpl_if description>\n				</blockquote>\n			</tmpl_if>\n		</tmpl_loop>\n	</tmpl_loop>\n</tmpl_loop>\n\n\n\n<tmpl_if pagination.pageCount.isMultiple>\n  <div class=\"pagination\">\n    <tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>\n  </div>\n</tmpl_if>\n','EventsCalendar',1,1,'PBtmpl0000000000000086');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a>\n<tmpl_if session.var.adminOn>\n	<p><tmpl_var controls></p>\n</tmpl_if>	\n		<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.isFirstPage>\r\n<tmpl_if image.url>\r\n  <div align=\"center\"><img src=\"<tmpl_var image.url>\" border=\"0\"></div>\r\n</tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n  <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.isLastPage>\r\n<tmpl_if linkurl>\r\n  <tmpl_if linktitle>\r\n    <p /><a href=\"<tmpl_var linkUrl>\"><tmpl_var linkTitle></a>\r\n  </tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_var attachment.box> <p />\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.pageCount.isMultiple>\r\n<tmpl_var pagination.previousPage> \r\n&middot;\r\n<tmpl_var pagination.pageList.upTo20>\r\n&middot;\r\n<tmpl_var pagination.nextPage>\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.isLastPage>\r\n<tmpl_if allowDiscussion>\r\n  <p><table width=\"100%\" cellspacing=\"2\" cellpadding=\"1\" border=\"0\">\r\n  <tr><td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var replies.URL>\"><tmpl_var replies.label> (<tmpl_var replies.count>)</a></td>\r\n  <td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var post.url>\"><tmpl_var post.label></a></td></tr>\r\n  </table>\r\n</tmpl_if>\r\n</tmpl_if>','Article',1,1,'PBtmpl0000000000000084');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a>\n<tmpl_if session.var.adminOn>\n	<p><tmpl_var controls></p>\n</tmpl_if>	\n		<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.isFirstPage>\r\n<tmpl_if image.url>\r\n  <table width=\"100%\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\"><tr><td class=\"content\">\r\n  <img src=\"<tmpl_var image.url>\" align=\"right\" border=\"0\">\r\n</tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n  <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n\r\n<tmpl_if pagination.isLastPage>\r\n<tmpl_if linkUrl>\r\n  <tmpl_if linkTitle>\r\n    <p /><a href=\"<tmpl_var linkUrl>\"><tmpl_var linkTitle></a>\r\n  </tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_var attachment.box> <p />\r\n</tmpl_if>\r\n\r\n\r\n<tmpl_if pagination.pageCount.isMultiple>\r\n<tmpl_var pagination.previousPage> \r\n&middot;\r\n<tmpl_var pagination.pageList.upTo20>\r\n&middot;\r\n<tmpl_var pagination.nextPage>\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.isFirstPage>\r\n<tmpl_if image.url>\r\n  </td></tr></table>\r\n</tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.isLastPage>\r\n<tmpl_if allowDiscussion>\r\n  <p><table width=\"100%\" cellspacing=\"2\" cellpadding=\"1\" border=\"0\">\r\n  <tr><td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var replies.URL>\"><tmpl_var replies.label> (<tmpl_var replies.count>)</a></td>\r\n  <td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var post.url>\"><tmpl_var post.label></a></td></tr>\r\n  </table>\r\n</tmpl_if>\r\n\r\n</tmpl_if>','Article',1,1,'PBtmpl0000000000000002');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a>\n<tmpl_if session.var.adminOn>\n	<p><tmpl_var controls></p>\n</tmpl_if>	\n		<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.isFirstPage>\r\n<tmpl_if image.url>\r\n  <table width=\"100%\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\"><tr><td class=\"content\">\r\n   <table align=\"right\"><tr><td align=\"center\">\r\n   <tmpl_if linkUrl>\r\n        <a href=\"<tmpl_var linkUrl>\">\r\n      <img src=\"<tmpl_var image.url>\" border=\"0\">\r\n       <br /><tmpl_var linkTitle></a>\r\n    <tmpl_else>\r\n           <img src=\"<tmpl_var image.url>\" border=\"0\">\r\n           <br /> <tmpl_var linkTitle>\r\n   </tmpl_if>\r\n  </td></tr></table>\r\n</tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n  <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.isLastPage>\r\n<tmpl_var attachment.box> <p />\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.isFirstPage>\r\n<tmpl_if image.url>\r\n  </td></tr></table>\r\n</tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.pageCount.isMultiple>\r\n<tmpl_var pagination.previousPage> \r\n&middot;\r\n<tmpl_var pagination.pageList.upTo20>\r\n&middot;\r\n<tmpl_var pagination.nextPage>\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.isLastPage>\r\n\r\n<tmpl_if allowDiscussion>\r\n  <p><table width=\"100%\" cellspacing=\"2\" cellpadding=\"1\" border=\"0\">\r\n  <tr><td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var replies.URL>\"><tmpl_var replies.label> (<tmpl_var replies.count>)</a></td>\r\n  <td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var post.url>\"><tmpl_var post.label></a></td></tr>\r\n  </table>\r\n</tmpl_if>\r\n\r\n\r\n</tmpl_if>','Article',1,1,'PBtmpl0000000000000115');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a> <tmpl_if session.var.adminOn> <p><tmpl_var controls></p> </tmpl_if><tmpl_if displayTitle>    <h1><tmpl_var title></h1></tmpl_if><tmpl_if description>    <tmpl_var description><p /></tmpl_if><tmpl_if session.scratch.search> </tmpl_if><table width=\"100%\" cellpadding=2 cellspacing=1 border=0><tr><td align=\"right\" class=\"tableMenu\"><tmpl_if user.canPost>   <a href=\"<tmpl_var add.url>\"><tmpl_var post.label></a> &middot;</tmpl_if><a href=\"<tmpl_var search.url>\"><tmpl_var search.label></a></td></tr></table><table width=\"100%\" cellspacing=1 cellpadding=2 border=0><tr><td class=\"tableHeader\"><tmpl_var title.label></td><td class=\"tableHeader\"><tmpl_var date.label></td><td class=\"tableHeader\"><tmpl_var by.label></td></tr><tmpl_loop post_loop><tmpl_if inDateRange><tr><td class=\"tableData\">     <a href=\"<tmpl_var URL>\">  <tmpl_var title>    <tmpl_if user.isPoster>        (<tmpl_var status>)     </tmpl_if></td><td class=\"tableData\"><tmpl_var dateSubmitted.human></td><td class=\"tableData\"><a href=\"<tmpl_var userProfile.url>\"><tmpl_var username></a></td></tr><tmpl_else> <tmpl_if user.isModerator><tr><td class=\"tableData\">     <i>*<a href=\"<tmpl_var URL>\">  <tmpl_var title>    <tmpl_if user.isPoster>        (<tmpl_var status>)     </tmpl_if></i></td><td class=\"tableData\"><i><tmpl_var dateSubmitted.human></i></td><td class=\"tableData\"><i><a href=\"<tmpl_var userProfile.url>\"><tmpl_var username></a></i></td></tr> </tmpl_if></tmpl_if></tmpl_loop></table><tmpl_if pagination.pageCount.isMultiple>  <div class=\"pagination\">    <tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>  </div></tmpl_if>','Collaboration',1,1,'PBtmpl0000000000000066');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a> <tmpl_if session.var.adminOn> <p><tmpl_var controls></p> </tmpl_if><a name=\"top\"></a>\r\n<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n <tmpl_if user.canPost>\n			<a href=\"<tmpl_var add.url>\"> <tmpl_var addquestion.label></a><p />\r\n</tmpl_if>\r\n\r\n<ul>\r\n<tmpl_loop post_loop>\r\n   <li><a href=\"#<tmpl_var assetId>\"><span class=\"faqQuestion\"><tmpl_var title></span></a>\r\n</tmpl_loop>\r\n</ul>\r\n<p />\r\n\r\n\r\n<tmpl_loop post_loop>\r\n\r\n  \n		<tmpl_if user.isPoster>\n			<tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var edit.url>\"><tmpl_var edit.label></a>]</tmpl_unless>\n		</tmpl_if>\n		<tmpl_if user.isModerator>\n			<tmpl_if session.var.adminOn><tmpl_var controls><tmpl_else><tmpl_unless user.isPoster><tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var edit.url>\"><tmpl_var edit.label></a>]</tmpl_unless></tmpl_unless></tmpl_if>\n		</tmpl_if>\n		\r\n\r\n  <a name=\"<tmpl_var assetId>\"><span class=\"faqQuestion\"><tmpl_var title></span></a><br />\r\n  <tmpl_var content>\r\n  <p /><a href=\"#top\">[top]</a><p />\r\n</tmpl_loop>\r\n\r\n','Collaboration',1,1,'PBtmpl0000000000000080');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a> <tmpl_if session.var.adminOn> <p><tmpl_var controls></p> </tmpl_if><tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n\r\n<tmpl_if session.scratch.search>\r\n \r\n</tmpl_if>\r\n\r\n\r\n<table width=\"100%\" cellpadding=2 cellspacing=1 border=0><tr>\r\n<td align=\"right\" class=\"tableMenu\">\r\n\r\n<tmpl_if user.canPost>\r\n   <a href=\"<tmpl_var add.url>\"><tmpl_var post.label></a> &middot;\r\n</tmpl_if>\r\n\r\n<a href=\"<tmpl_var search.url>\"><tmpl_var search.label></a>\r\n\r\n</td></tr></table>\r\n\r\n<table width=\"100%\" cellspacing=1 cellpadding=2 border=0>\r\n<tr>\r\n<td class=\"tableHeader\"><tmpl_var title.label></td>\r\n<td class=\"tableHeader\"><tmpl_var thumbnail.label></td>\r\n<td class=\"tableHeader\"><tmpl_var date.label></td>\r\n<td class=\"tableHeader\"><tmpl_var by.label></td>\r\n</tr>\r\n\r\n<tmpl_loop post_loop>\r\n\r\n<tr>\r\n<td class=\"tableData\">\r\n     <a href=\"<tmpl_var URL>\">  <tmpl_var title>\r\n    <tmpl_if user.isPoster>\r\n        (<tmpl_var status>)\r\n     </tmpl_if>\r\n</td>\r\n   <td class=\"tableData\">\r\n      <tmpl_if thumbnail>\r\n             <a href=\"<tmpl_var url>\"><img src=\"<tmpl_var thumbnail>\" border=\"0\"></a>\r\n      </tmpl_if>\r\n  </td>\r\n\r\n<td class=\"tableData\"><tmpl_var dateSubmitted.human></td>\r\n<td class=\"tableData\"><a href=\"<tmpl_var userProfile.url>\"><tmpl_var username></a></td>\r\n</tr>\r\n\r\n</tmpl_loop>\r\n\r\n</table>\r\n\r\n<tmpl_if pagination.pageCount.isMultiple>\r\n  <div class=\"pagination\">\r\n    <tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>\r\n  </div>\r\n</tmpl_if>\r\n\r\n','Collaboration',1,1,'PBtmpl0000000000000097');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a> <tmpl_if session.var.adminOn> <p><tmpl_var controls></p> </tmpl_if><tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n\r\n<tmpl_if session.scratch.search>\r\n \r\n</tmpl_if>\r\n\r\n\r\n<tmpl_if user.canPost>\r\n   <a href=\"<tmpl_var add.url>\"><tmpl_var post.label></a> &middot;\r\n</tmpl_if>\r\n\r\n\r\n<a href=\"<tmpl_var search.url>\"><tmpl_var search.label></a>\r\n<p />\r\n<table width=\"100%\" cellpadding=2 cellspacing=1 border=0>\r\n\r\n<tmpl_loop post_loop>\r\n\r\n<tr><td class=\"tableHeader\"><tmpl_var title>\r\n  <tmpl_if user.isPoster>\r\n            (<tmpl_var status>)\r\n  </tmpl_if>\r\n</td></tr><tr><td class=\"tableData\"><b>\r\n  <tmpl_if thumbnail>\r\n    <a href=\"<tmpl_var url>\"><img src=\"<tmpl_var thumbnail>\" border=\"0\" align=\"right\"/></a>\r\n   </tmpl_if>\r\n <tmpl_var by.label> <a href=\"<tmpl_var userProfile.url>\"><tmpl_var username></a>  - <tmpl_var dateSubmitted.human></b><br />\r\n<tmpl_var synopsis>\r\n<p /> ( <a href=\"<tmpl_var url>\"><tmpl_var readmore.label></a>\r\n                <tmpl_if replies>\r\n                         | <tmpl_if repliesAllowed>\n<style>\n	.postBorder {\n		border: 1px solid #cccccc;\n		width: 100%;\n		margin-bottom: 10px;\n	}\n 	.postBorderCurrent {\n		border: 3px dotted black;\n		width: 100%;\n		margin-bottom: 10px;\n	}\n	.postSubject {\n		border-bottom: 1px solid #cccccc;\n		font-weight: bold;\n		padding: 3px;\n	}\n	.postData {\n		border-bottom: 1px solid #cccccc;\n		font-size: 11px;\n		background-color: #eeeeee;\n		color: black;\n		padding: 3px;\n	}\n	.postControls {\n		border-top: 1px solid #cccccc;\n		background-color: #eeeeee;\n		color: black;\n		padding: 3px;\n	}\n	.postMessage {\n		padding: 3px;\n	}\n	.currentThread {\n		background-color: #eeeeee;\n	}\n	.threadHead {\n		font-weight: bold;\n		border-bottom: 1px solid #cccccc;\n		font-size: 11px;\n		background-color: #eeeeee;\n		color: black;\n		padding: 3px;\n	}\n	.threadData {\n		font-size: 11px;\n		padding: 3px;\n	}\n</style>\n	\n\n\n<div style=\"float: left; width: 70%\">\n	<h1><tmpl_var replies.label></h1>\n</div>\n<div style=\"width: 30%; float: left; text-align: right;\">\n	<script language=\"JavaScript\" type=\"text/javascript\">	<!--\n	function goLayout(){\n		location = document.discussionlayout.layoutSelect.options[document.discussionlayout.layoutSelect.selectedIndex].value\n	}\n	//-->	\n	</script>\n	<form name=\"discussionlayout\">\n		<select name=\"layoutSelect\" size=\"1\" onChange=\"goLayout()\">\n			<option value=\"<tmpl_var layout.flat.url>\" <tmpl_if layout.isFlat>selected=\"1\"</tmpl_if>><tmpl_var layout.flat.label></option>\n			<option value=\"<tmpl_var layout.nested.url>\" <tmpl_if layout.isNested>selected=\"1\"</tmpl_if>><tmpl_var layout.nested.label></option>\n			<option value=\"<tmpl_var layout.threaded.url>\" <tmpl_if layout.isThreaded>selected=\"1\"</tmpl_if>><tmpl_var layout.threaded.label></option>\n		</select> \n	</form> \n</div>\n<div style=\"clear: both;\"></div>\n\n	\n\n\n\n\n\n\n\n\n<tmpl_if layout.isThreaded>\n<!-- begin threaded layout -->\n	<tmpl_loop post_loop>\n		<tmpl_unless isThreadRoot>\n		<tmpl_if isCurrent>\n			<div class=\"postBorder\">\n				<a name=\"<tmpl_var assetId>\"></a>\n				<div class=\"postSubject\">\n					<tmpl_var title>\n				</div>\n				<div class=\"postData\">\n					<div style=\"float: left; width: 50%;\">\n						<b><tmpl_var user.label>:</b> \n							<tmpl_if user.isVisitor>\n								<tmpl_var username>\n							<tmpl_else>\n								<a href=\"<tmpl_var userProfile.url>\"><tmpl_var username></a>\n							</tmpl_if>\n							<br />\n						<b><tmpl_var date.label>:</b> <tmpl_var dateSubmitted.human><br />\n					</div>	\n					<div>\n						<b><tmpl_var views.label>:</b> <tmpl_var views><br />\n						<b><tmpl_var rating.label>:</b> <tmpl_var rating>\n							<tmpl_unless hasRated>\n								 &nbsp; &nbsp;<tmpl_var rate.label> [ <a href=\"<tmpl_var rate.url.1>\">1</a>, <a href=\"<tmpl_var rate.url.2>\">2</a>, <a href=\"<tmpl_var rate.url.3>\">3</a>, <a href=\"<tmpl_var rate.url.4>\">4</a>, <a href=\"<tmpl_var rate.url.5>\">5</a> ]\n							</tmpl_unless>\n							<br />\n						<tmpl_if user.isModerator>\n							<b><tmpl_var status.label>:</b> <tmpl_var status>  &nbsp; &nbsp; [ <a href=\"<tmpl_var approve.url>\"><tmpl_var approve.label></a> | <a href=\"<tmpl_var deny.url>\"><tmpl_var deny.label></a> ]<br />\n						<tmpl_else>	\n							<tmpl_if user.isPoster>\n								<b><tmpl_var status.label>:</b> <tmpl_var status><br />\n							</tmpl_if>	\n						</tmpl_if>	\n					</div>	\n				</div>\n				<div class=\"postMessage\">\n					<tmpl_var content>\n				</div>\n				<tmpl_unless isLocked>\n					<div class=\"postControls\">\n						<tmpl_if user.canReply>\n							<a href=\"<tmpl_var reply.url>\">[<tmpl_var reply.label>]</a>\n						</tmpl_if>\n						<tmpl_if user.canEdit>\n							<a href=\"<tmpl_var edit.url>\">[<tmpl_var edit.label>]</a>\n							<a href=\"<tmpl_var delete.url>\">[<tmpl_var delete.label>]</a>\n						</tmpl_if>\n					</div>\n				</tmpl_unless>\n			</div>	\n		</tmpl_if>\n		</tmpl_unless>\n	</tmpl_loop>\n	<table style=\"width: 100%\">\n		<thead>\n			<tr>\n				<td class=\"threadHead\"><tmpl_var subject.label></td>\n				<td class=\"threadHead\"><tmpl_var user.label></td>\n				<td class=\"threadHead\"><tmpl_var date.label></td>\n			</tr>\n		</thead>\n		<tbody>\n			<tmpl_loop post_loop>\n				<tmpl_unless isThreadRoot>\n				<tr <tmpl_if isCurrent>class=\"currentThread\"</tmpl_if>>\n					<td class=\"threadData\"><tmpl_loop indent_loop>&nbsp; &nbsp;</tmpl_loop><a href=\"<tmpl_var url>\"><tmpl_var title.short></a></td>\n					<td class=\"threadData\"><tmpl_var username></td>\n					<td class=\"threadData\"><tmpl_var dateSubmitted.human></td>\n				</tr>\n				</tmpl_unless>\n			</tmpl_loop>\n		</tbody>\n	</table>	\n<!-- end threaded layout -->\n</tmpl_if>\n\n\n\n<tmpl_if layout.isFlat>\n<!-- begin flat layout -->\n	<tmpl_loop post_loop>\n		<tmpl_unless isThreadRoot>\n		<div class=\"postBorder<tmpl_if isCurrent>Current</tmpl_if>\">\n			<a name=\"<tmpl_var assetId>\"></a>\n			<div class=\"postSubject\">\n				<tmpl_var title>\n			</div>\n			<div class=\"postData\">\n				<div style=\"float: left; width: 50%\">\n					<b><tmpl_var user.label>:</b> \n						<tmpl_if user.isVisitor>\n							<tmpl_var username>\n						<tmpl_else>\n							<a href=\"<tmpl_var userProfile.url>\"><tmpl_var username></a>\n						</tmpl_if>\n						<br />\n					<b><tmpl_var date.label>:</b> <tmpl_var dateSubmitted.human><br />\n				</div>	\n				<div>\n					<b><tmpl_var views.label>:</b> <tmpl_var views><br />\n					<b><tmpl_var rating.label>:</b> <tmpl_var rating>\n						<tmpl_unless hasRated>\n							 &nbsp; &nbsp;<tmpl_var rate.label> [ <a href=\"<tmpl_var rate.url.1>\">1</a>, <a href=\"<tmpl_var rate.url.2>\">2</a>, <a href=\"<tmpl_var rate.url.3>\">3</a>, <a href=\"<tmpl_var rate.url.4>\">4</a>, <a href=\"<tmpl_var rate.url.5>\">5</a> ]\n						</tmpl_unless>\n						<br />\n					<tmpl_if user.isModerator>\n						<b><tmpl_var status.label>:</b> <tmpl_var status>  &nbsp; &nbsp; [ <a href=\"<tmpl_var approve.url>\"><tmpl_var approve.label></a> | <a href=\"<tmpl_var deny.url>\"><tmpl_var deny.label></a> ]<br />\n					<tmpl_else>	\n						<tmpl_if user.isPoster>\n							<b><tmpl_var status.label>:</b> <tmpl_var status><br />\n						</tmpl_if>	\n					</tmpl_if>	\n				</div>	\n			</div>\n			<div class=\"postMessage\">\n				<tmpl_var content>\n			</div>\n			<tmpl_unless isLocked>\n				<div class=\"postControls\">\n					<tmpl_if user.canReply>\n						<a href=\"<tmpl_var reply.url>\">[<tmpl_var reply.label>]</a>\n					</tmpl_if>\n					<tmpl_if user.canEdit>\n						<a href=\"<tmpl_var edit.url>\">[<tmpl_var edit.label>]</a>\n						<a href=\"<tmpl_var delete.url>\">[<tmpl_var delete.label>]</a>\n					</tmpl_if>\n				</div>\n			</tmpl_unless>\n		</div>\n		</tmpl_unless>\n	</tmpl_loop>\n<!-- end flat layout -->\n</tmpl_if>\n\n\n\n<tmpl_if layout.isNested>\n<!-- begin nested layout -->\n    <tmpl_loop post_loop>\n		<tmpl_unless isThreadRoot>\n		<div style=\"margin-left: <tmpl_var depthX10>px;\">\n			<div class=\"postBorder<tmpl_if isCurrent>Current</tmpl_if>\">\n				<a name=\"<tmpl_var assetId>\"></a>\n				<div class=\"postSubject\">\n					<tmpl_var title>\n				</div>\n				<div class=\"postData\">\n					<div style=\"float: left; width: 50%\">\n						<b><tmpl_var user.label>:</b> \n							<tmpl_if user.isVisitor>\n								<tmpl_var username>\n							<tmpl_else>\n								<a href=\"<tmpl_var userProfile.url>\"><tmpl_var username></a>\n							</tmpl_if>\n							<br />\n						<b><tmpl_var date.label>:</b> <tmpl_var dateSubmitted.human><br />\n					</div>	\n					<div>\n						<b><tmpl_var views.label>:</b> <tmpl_var views><br />\n						<b><tmpl_var rating.label>:</b> <tmpl_var rating>\n							<tmpl_unless hasRated>\n								 &nbsp; &nbsp;<tmpl_var rate.label> [ <a href=\"<tmpl_var rate.url.1>\">1</a>, <a href=\"<tmpl_var rate.url.2>\">2</a>, <a href=\"<tmpl_var rate.url.3>\">3</a>, <a href=\"<tmpl_var rate.url.4>\">4</a>, <a href=\"<tmpl_var rate.url.5>\">5</a> ]\n							</tmpl_unless>\n							<br />\n						<tmpl_if user.isModerator>\n							<b><tmpl_var status.label>:</b> <tmpl_var status>  &nbsp; &nbsp; [ <a href=\"<tmpl_var approve.url>\"><tmpl_var approve.label></a> | <a href=\"<tmpl_var deny.url>\"><tmpl_var deny.label></a> ]<br />\n						<tmpl_else>	\n							<tmpl_if user.isPoster>\n								<b><tmpl_var status.label>:</b> <tmpl_var status><br />\n							</tmpl_if>	\n						</tmpl_if>	\n					</div>	\n				</div>\n				<div class=\"postMessage\">\n					<tmpl_var content>\n				</div>\n				<tmpl_unless isLocked>\n					<div class=\"postControls\">\n						<tmpl_if user.canReply>\n							<a href=\"<tmpl_var reply.url>\">[<tmpl_var reply.label>]</a>\n						</tmpl_if>\n						<tmpl_if user.canEdit>\n							<a href=\"<tmpl_var edit.url>\">[<tmpl_var edit.label>]</a>\n							<a href=\"<tmpl_var delete.url>\">[<tmpl_var delete.label>]</a>\n						</tmpl_if>\n					</div>\n				</tmpl_unless>\n			</div>\n		</div>\n		</tmpl_unless>\n	</tmpl_loop>\n<!-- end nested layout -->\n</tmpl_if>\n\n\n\n<tmpl_if pagination.pageCount.isMultiple>\n	<div class=\"pagination\" style=\"margin-top: 20px;\">\n		[ <tmpl_var pagination.previousPage>  | <tmpl_var pagination.pageList.upTo10> | <tmpl_var pagination.nextPage> ]\n	</div>\n</tmpl_if>\n\n\n<div style=\"margin-top: 20px;\">\n	<tmpl_if user.isModerator>\n		<tmpl_if isSticky>\n			<a href=\"<tmpl_var unstick.url>\">[<tmpl_var unstick.label>]</a>\n		<tmpl_else>\n			<a href=\"<tmpl_var stick.url>\">[<tmpl_var stick.label>]</a>\n		</tmpl_if>\n		<tmpl_if isLocked>\n			<a href=\"<tmpl_var unlock.url>\">[<tmpl_var unlock.label>]</a>\n		<tmpl_else>\n			<a href=\"<tmpl_var lock.url>\">[<tmpl_var lock.label>]</a>\n		</tmpl_if>\n	</tmpl_if>\n	<tmpl_unless user.isVisitor>\n		<tmpl_if user.isSubscribed>\n			<a href=\"<tmpl_var unsubscribe.url>\">[<tmpl_var unsubscribe.label>]</a>\n		<tmpl_else>\n			<a href=\"<tmpl_var subscribe.url>\">[<tmpl_var subscribe.label>]</a>\n		</tmpl_if>\n	</tmpl_unless>\n</div>\n</tmpl_if>\n <tmpl_var responses.label>\r\n                </tmpl_if>\r\n         )<p/>\r\n</td></tr>\r\n\r\n</tmpl_loop>\r\n\r\n</table>\r\n\r\n<tmpl_if pagination.pageCount.isMultiple>\r\n  <div class=\"pagination\">\r\n    <tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.nextPage>\r\n  </div>\r\n</tmpl_if>\r\n','Collaboration',1,1,'PBtmpl0000000000000112');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a> <tmpl_if session.var.adminOn> <p><tmpl_var controls></p> </tmpl_if><tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p/>\r\n</tmpl_if>\r\n\r\n<tmpl_if session.scratch.search>\r\n \r\n</tmpl_if>\r\n\r\n<tmpl_if user.canPost>\r\n   <a href=\"<tmpl_var add.url>\"><tmpl_var post.label></a> &middot;\r\n</tmpl_if>\r\n\r\n\r\n<a href=\"<tmpl_var search.url>\"><tmpl_var search.label></a><p />\r\n\r\n<table width=\"100%\" cellpadding=2 cellspacing=1 border=0>\r\n<tr>\r\n<tmpl_loop post_loop>\r\n\r\n<td align=\"center\" class=\"tableData\">\r\n  \r\n  <tmpl_if thumbnail>\r\n       <a href=\"<tmpl_var url>\"><img src=\"<tmpl_var thumbnail>\" border=\"0\"/></a><br />\r\n  </tmpl_if>\r\n  <a href=\"<tmpl_var url>\"><tmpl_var title></a>\r\n  <tmpl_if user.isPoster>\r\n    (<tmpl_var status>)\r\n  </tmpl_if>\r\n</td>\r\n\r\n<tmpl_if isThird>\r\n  </tr><tr>\r\n</tmpl_if>\r\n\r\n</tmpl_loop>\r\n</tr>\r\n</table>\r\n\r\n<tmpl_if pagination.pageCount.isMultiple>\r\n  <div class=\"pagination\">\r\n    <tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>\r\n  </div>\r\n</tmpl_if>\r\n','Collaboration',1,1,'PBtmpl0000000000000121');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a> <tmpl_if session.var.adminOn> <p><tmpl_var controls></p> </tmpl_if><h1><tmpl_var title></h1>\n<table width=\"100%\" cellpadding=2 cellspacing=1 border=0>\n<tr><td valign=\"top\" class=\"tableHeader\" width=\"100%\">\n<b><tmpl_var user.label>:</b> <a href=\"<tmpl_var userProfile.url>\"><tmpl_var username></a><br />\n<b><tmpl_var date.label>:</b> <tmpl_var dateSubmitted.human><br />\n<b><tmpl_var status.label>:</b> <tmpl_var status><br />\n<b><tmpl_var views.label>:</b> <tmpl_var views><br />\n</td>\n<td rowspan=\"2\" class=\"tableMenu\" nowrap=\"1\" valign=\"top\">\n\n<tmpl_if previous.url>\n <a href=\"<tmpl_var previous.url>\">&laquo;<tmpl_var previous.label></a><br />\n</tmpl_if>\n<tmpl_if next.url>\n <a href=\"<tmpl_var next.url>\"><tmpl_var next.label>&raquo;</a><br />\n</tmpl_if>\n<tmpl_if canEdit>\n <a href=\"<tmpl_var edit.url>\"><tmpl_var edit.label></a><br />\n <a href=\"<tmpl_var delete.url>\"><tmpl_var delete.label></a><br />\n</tmpl_if>\n<tmpl_if canChangeStatus>\n <a href=\"<tmpl_var approve.url>\"><tmpl_var approve.label></a><br />\n <a href=\"<tmpl_var deny.url>\"><tmpl_var deny.label></a><br />\n</tmpl_if>\n<tmpl_if user.canPost>\n <a href=\"<tmpl_var edit.url>\"><tmpl_var post.label></a><br />\n</tmpl_if>\n<a href=\"<tmpl_var search.url>\"><tmpl_var search.label></a><br />\n<a href=\"<tmpl_var collaboration.url>\"><tmpl_var back.label></a><br />\n\n</td> </tr><tr><td class=\"tableData\">\n<tmpl_if image.url>\n <img src=\"<tmpl_var image.url>\" border=\"0\"><p />\n</tmpl_if>\n<tmpl_var content><p />\n<tmpl_if attachment.name><div><a href=\"<tmpl_var attachment.url>\"><img src=\"<tmpl_var attachment.icon>\" border=\"0\" alt=\"<tmpl_var attachment.name>\"> <tmpl_var attachment.name></a></div></tmpl_if><br />\n\n</td></tr></table>\n\n<tmpl_if repliesAllowed>\n<style>\n	.postBorder {\n		border: 1px solid #cccccc;\n		width: 100%;\n		margin-bottom: 10px;\n	}\n 	.postBorderCurrent {\n		border: 3px dotted black;\n		width: 100%;\n		margin-bottom: 10px;\n	}\n	.postSubject {\n		border-bottom: 1px solid #cccccc;\n		font-weight: bold;\n		padding: 3px;\n	}\n	.postData {\n		border-bottom: 1px solid #cccccc;\n		font-size: 11px;\n		background-color: #eeeeee;\n		color: black;\n		padding: 3px;\n	}\n	.postControls {\n		border-top: 1px solid #cccccc;\n		background-color: #eeeeee;\n		color: black;\n		padding: 3px;\n	}\n	.postMessage {\n		padding: 3px;\n	}\n	.currentThread {\n		background-color: #eeeeee;\n	}\n	.threadHead {\n		font-weight: bold;\n		border-bottom: 1px solid #cccccc;\n		font-size: 11px;\n		background-color: #eeeeee;\n		color: black;\n		padding: 3px;\n	}\n	.threadData {\n		font-size: 11px;\n		padding: 3px;\n	}\n</style>\n	\n\n\n<div style=\"float: left; width: 70%\">\n	<h1><tmpl_var replies.label></h1>\n</div>\n<div style=\"width: 30%; float: left; text-align: right;\">\n	<script language=\"JavaScript\" type=\"text/javascript\">	<!--\n	function goLayout(){\n		location = document.discussionlayout.layoutSelect.options[document.discussionlayout.layoutSelect.selectedIndex].value\n	}\n	//-->	\n	</script>\n	<form name=\"discussionlayout\">\n		<select name=\"layoutSelect\" size=\"1\" onChange=\"goLayout()\">\n			<option value=\"<tmpl_var layout.flat.url>\" <tmpl_if layout.isFlat>selected=\"1\"</tmpl_if>><tmpl_var layout.flat.label></option>\n			<option value=\"<tmpl_var layout.nested.url>\" <tmpl_if layout.isNested>selected=\"1\"</tmpl_if>><tmpl_var layout.nested.label></option>\n			<option value=\"<tmpl_var layout.threaded.url>\" <tmpl_if layout.isThreaded>selected=\"1\"</tmpl_if>><tmpl_var layout.threaded.label></option>\n		</select> \n	</form> \n</div>\n<div style=\"clear: both;\"></div>\n\n	\n\n\n\n\n\n\n\n\n<tmpl_if layout.isThreaded>\n<!-- begin threaded layout -->\n	<tmpl_loop post_loop>\n		<tmpl_unless isThreadRoot>\n		<tmpl_if isCurrent>\n			<div class=\"postBorder\">\n				<a name=\"<tmpl_var assetId>\"></a>\n				<div class=\"postSubject\">\n					<tmpl_var title>\n				</div>\n				<div class=\"postData\">\n					<div style=\"float: left; width: 50%;\">\n						<b><tmpl_var user.label>:</b> \n							<tmpl_if user.isVisitor>\n								<tmpl_var username>\n							<tmpl_else>\n								<a href=\"<tmpl_var userProfile.url>\"><tmpl_var username></a>\n							</tmpl_if>\n							<br />\n						<b><tmpl_var date.label>:</b> <tmpl_var dateSubmitted.human><br />\n					</div>	\n					<div>\n						<b><tmpl_var views.label>:</b> <tmpl_var views><br />\n						<b><tmpl_var rating.label>:</b> <tmpl_var rating>\n							<tmpl_unless hasRated>\n								 &nbsp; &nbsp;<tmpl_var rate.label> [ <a href=\"<tmpl_var rate.url.1>\">1</a>, <a href=\"<tmpl_var rate.url.2>\">2</a>, <a href=\"<tmpl_var rate.url.3>\">3</a>, <a href=\"<tmpl_var rate.url.4>\">4</a>, <a href=\"<tmpl_var rate.url.5>\">5</a> ]\n							</tmpl_unless>\n							<br />\n						<tmpl_if user.isModerator>\n							<b><tmpl_var status.label>:</b> <tmpl_var status>  &nbsp; &nbsp; [ <a href=\"<tmpl_var approve.url>\"><tmpl_var approve.label></a> | <a href=\"<tmpl_var deny.url>\"><tmpl_var deny.label></a> ]<br />\n						<tmpl_else>	\n							<tmpl_if user.isPoster>\n								<b><tmpl_var status.label>:</b> <tmpl_var status><br />\n							</tmpl_if>	\n						</tmpl_if>	\n					</div>	\n				</div>\n				<div class=\"postMessage\">\n					<tmpl_var content>\n				</div>\n				<tmpl_unless isLocked>\n					<div class=\"postControls\">\n						<tmpl_if user.canReply>\n							<a href=\"<tmpl_var reply.url>\">[<tmpl_var reply.label>]</a>\n						</tmpl_if>\n						<tmpl_if user.canEdit>\n							<a href=\"<tmpl_var edit.url>\">[<tmpl_var edit.label>]</a>\n							<a href=\"<tmpl_var delete.url>\">[<tmpl_var delete.label>]</a>\n						</tmpl_if>\n					</div>\n				</tmpl_unless>\n			</div>	\n		</tmpl_if>\n		</tmpl_unless>\n	</tmpl_loop>\n	<table style=\"width: 100%\">\n		<thead>\n			<tr>\n				<td class=\"threadHead\"><tmpl_var subject.label></td>\n				<td class=\"threadHead\"><tmpl_var user.label></td>\n				<td class=\"threadHead\"><tmpl_var date.label></td>\n			</tr>\n		</thead>\n		<tbody>\n			<tmpl_loop post_loop>\n				<tmpl_unless isThreadRoot>\n				<tr <tmpl_if isCurrent>class=\"currentThread\"</tmpl_if>>\n					<td class=\"threadData\"><tmpl_loop indent_loop>&nbsp; &nbsp;</tmpl_loop><a href=\"<tmpl_var url>\"><tmpl_var title.short></a></td>\n					<td class=\"threadData\"><tmpl_var username></td>\n					<td class=\"threadData\"><tmpl_var dateSubmitted.human></td>\n				</tr>\n				</tmpl_unless>\n			</tmpl_loop>\n		</tbody>\n	</table>	\n<!-- end threaded layout -->\n</tmpl_if>\n\n\n\n<tmpl_if layout.isFlat>\n<!-- begin flat layout -->\n	<tmpl_loop post_loop>\n		<tmpl_unless isThreadRoot>\n		<div class=\"postBorder<tmpl_if isCurrent>Current</tmpl_if>\">\n			<a name=\"<tmpl_var assetId>\"></a>\n			<div class=\"postSubject\">\n				<tmpl_var title>\n			</div>\n			<div class=\"postData\">\n				<div style=\"float: left; width: 50%\">\n					<b><tmpl_var user.label>:</b> \n						<tmpl_if user.isVisitor>\n							<tmpl_var username>\n						<tmpl_else>\n							<a href=\"<tmpl_var userProfile.url>\"><tmpl_var username></a>\n						</tmpl_if>\n						<br />\n					<b><tmpl_var date.label>:</b> <tmpl_var dateSubmitted.human><br />\n				</div>	\n				<div>\n					<b><tmpl_var views.label>:</b> <tmpl_var views><br />\n					<b><tmpl_var rating.label>:</b> <tmpl_var rating>\n						<tmpl_unless hasRated>\n							 &nbsp; &nbsp;<tmpl_var rate.label> [ <a href=\"<tmpl_var rate.url.1>\">1</a>, <a href=\"<tmpl_var rate.url.2>\">2</a>, <a href=\"<tmpl_var rate.url.3>\">3</a>, <a href=\"<tmpl_var rate.url.4>\">4</a>, <a href=\"<tmpl_var rate.url.5>\">5</a> ]\n						</tmpl_unless>\n						<br />\n					<tmpl_if user.isModerator>\n						<b><tmpl_var status.label>:</b> <tmpl_var status>  &nbsp; &nbsp; [ <a href=\"<tmpl_var approve.url>\"><tmpl_var approve.label></a> | <a href=\"<tmpl_var deny.url>\"><tmpl_var deny.label></a> ]<br />\n					<tmpl_else>	\n						<tmpl_if user.isPoster>\n							<b><tmpl_var status.label>:</b> <tmpl_var status><br />\n						</tmpl_if>	\n					</tmpl_if>	\n				</div>	\n			</div>\n			<div class=\"postMessage\">\n				<tmpl_var content>\n			</div>\n			<tmpl_unless isLocked>\n				<div class=\"postControls\">\n					<tmpl_if user.canReply>\n						<a href=\"<tmpl_var reply.url>\">[<tmpl_var reply.label>]</a>\n					</tmpl_if>\n					<tmpl_if user.canEdit>\n						<a href=\"<tmpl_var edit.url>\">[<tmpl_var edit.label>]</a>\n						<a href=\"<tmpl_var delete.url>\">[<tmpl_var delete.label>]</a>\n					</tmpl_if>\n				</div>\n			</tmpl_unless>\n		</div>\n		</tmpl_unless>\n	</tmpl_loop>\n<!-- end flat layout -->\n</tmpl_if>\n\n\n\n<tmpl_if layout.isNested>\n<!-- begin nested layout -->\n    <tmpl_loop post_loop>\n		<tmpl_unless isThreadRoot>\n		<div style=\"margin-left: <tmpl_var depthX10>px;\">\n			<div class=\"postBorder<tmpl_if isCurrent>Current</tmpl_if>\">\n				<a name=\"<tmpl_var assetId>\"></a>\n				<div class=\"postSubject\">\n					<tmpl_var title>\n				</div>\n				<div class=\"postData\">\n					<div style=\"float: left; width: 50%\">\n						<b><tmpl_var user.label>:</b> \n							<tmpl_if user.isVisitor>\n								<tmpl_var username>\n							<tmpl_else>\n								<a href=\"<tmpl_var userProfile.url>\"><tmpl_var username></a>\n							</tmpl_if>\n							<br />\n						<b><tmpl_var date.label>:</b> <tmpl_var dateSubmitted.human><br />\n					</div>	\n					<div>\n						<b><tmpl_var views.label>:</b> <tmpl_var views><br />\n						<b><tmpl_var rating.label>:</b> <tmpl_var rating>\n							<tmpl_unless hasRated>\n								 &nbsp; &nbsp;<tmpl_var rate.label> [ <a href=\"<tmpl_var rate.url.1>\">1</a>, <a href=\"<tmpl_var rate.url.2>\">2</a>, <a href=\"<tmpl_var rate.url.3>\">3</a>, <a href=\"<tmpl_var rate.url.4>\">4</a>, <a href=\"<tmpl_var rate.url.5>\">5</a> ]\n							</tmpl_unless>\n							<br />\n						<tmpl_if user.isModerator>\n							<b><tmpl_var status.label>:</b> <tmpl_var status>  &nbsp; &nbsp; [ <a href=\"<tmpl_var approve.url>\"><tmpl_var approve.label></a> | <a href=\"<tmpl_var deny.url>\"><tmpl_var deny.label></a> ]<br />\n						<tmpl_else>	\n							<tmpl_if user.isPoster>\n								<b><tmpl_var status.label>:</b> <tmpl_var status><br />\n							</tmpl_if>	\n						</tmpl_if>	\n					</div>	\n				</div>\n				<div class=\"postMessage\">\n					<tmpl_var content>\n				</div>\n				<tmpl_unless isLocked>\n					<div class=\"postControls\">\n						<tmpl_if user.canReply>\n							<a href=\"<tmpl_var reply.url>\">[<tmpl_var reply.label>]</a>\n						</tmpl_if>\n						<tmpl_if user.canEdit>\n							<a href=\"<tmpl_var edit.url>\">[<tmpl_var edit.label>]</a>\n							<a href=\"<tmpl_var delete.url>\">[<tmpl_var delete.label>]</a>\n						</tmpl_if>\n					</div>\n				</tmpl_unless>\n			</div>\n		</div>\n		</tmpl_unless>\n	</tmpl_loop>\n<!-- end nested layout -->\n</tmpl_if>\n\n\n\n<tmpl_if pagination.pageCount.isMultiple>\n	<div class=\"pagination\" style=\"margin-top: 20px;\">\n		[ <tmpl_var pagination.previousPage>  | <tmpl_var pagination.pageList.upTo10> | <tmpl_var pagination.nextPage> ]\n	</div>\n</tmpl_if>\n\n\n<div style=\"margin-top: 20px;\">\n	<tmpl_if user.isModerator>\n		<tmpl_if isSticky>\n			<a href=\"<tmpl_var unstick.url>\">[<tmpl_var unstick.label>]</a>\n		<tmpl_else>\n			<a href=\"<tmpl_var stick.url>\">[<tmpl_var stick.label>]</a>\n		</tmpl_if>\n		<tmpl_if isLocked>\n			<a href=\"<tmpl_var unlock.url>\">[<tmpl_var unlock.label>]</a>\n		<tmpl_else>\n			<a href=\"<tmpl_var lock.url>\">[<tmpl_var lock.label>]</a>\n		</tmpl_if>\n	</tmpl_if>\n	<tmpl_unless user.isVisitor>\n		<tmpl_if user.isSubscribed>\n			<a href=\"<tmpl_var unsubscribe.url>\">[<tmpl_var unsubscribe.label>]</a>\n		<tmpl_else>\n			<a href=\"<tmpl_var subscribe.url>\">[<tmpl_var subscribe.label>]</a>\n		</tmpl_if>\n	</tmpl_unless>\n</div>\n</tmpl_if>\n','Collaboration/Thread',1,1,'PBtmpl0000000000000067');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a> \r\n<tmpl_if session.var.adminOn> \r\n	<p><tmpl_var controls></p> \r\n</tmpl_if>\r\n\r\n<p>\r\n<tmpl_if user.canPost>\r\n	<a href=\"<tmpl_var add.url>\"><tmpl_var add.label></a>\r\n	<tmpl_unless user.isVisitor>\r\n		&bull; \r\n		<tmpl_if user.isSubscribed>\r\n			<a href=\"<tmpl_var unsubscribe.url>\"><tmpl_var unsubscribe.label></a>\r\n		<tmpl_else>\r\n			<a href=\"<tmpl_var subscribe.url>\"><tmpl_var subscribe.label></a>\r\n		</tmpl_if>\r\n	</tmpl_unless>\r\n	&bull;\r\n</tmpl_if>\r\n<a href=\"<tmpl_var search.url>\"><tmpl_var search.label></a>\r\n</p>\r\n\r\n<table width=\"100%\" cellspacing=\"0\" cellpadding=\"3\" border=\"0\">\r\n<tr>\r\n	<td class=\"tableHeader\"><tmpl_var subject.label></td>\r\n	<td class=\"tableHeader\"><tmpl_var user.label></td>\r\n	<td class=\"tableHeader\"><a href=\"<tmpl_var sortby.views.url>\"><tmpl_var views.label></a></td>\r\n	<td class=\"tableHeader\"><a href=\"<tmpl_var sortby.replies.url>\"><tmpl_var replies.label></a></td>\r\n	<td class=\"tableHeader\"><a href=\"<tmpl_var sortby.rating.url>\"><tmpl_var rating.label></a></td>\r\n	<td class=\"tableHeader\"><a href=\"<tmpl_var sortby.date.url>\"><tmpl_var date.label></a></td>\r\n	<tmpl_if displayLastReply>\r\n		<td class=\"tableHeader\"><a href=\"<tmpl_var sortby.lastreply.url>\"><tmpl_var lastReply.label></a></td>\r\n	</tmpl_if>\r\n</tr>\r\n<tmpl_loop post_loop>\r\n<tr>\r\n	<td class=\"tableData\"><a href=\"<tmpl_var url>\"><tmpl_var title></a></td>\r\n	<tmpl_if user.isVisitor>\r\n		<td class=\"tableData\"><tmpl_var username></td>\r\n	<tmpl_else>\r\n		<td class=\"tableData\"><a href=\"<tmpl_var userProfile.url>\"><tmpl_var username></a></td>\r\n	</tmpl_if>\r\n	<td class=\"tableData\" align=\"center\"><tmpl_var views></td>\r\n	<td class=\"tableData\" align=\"center\"><tmpl_var replies></td>\r\n	<td class=\"tableData\" align=\"center\"><tmpl_var rating></td>\r\n	<td class=\"tableData\"><tmpl_var dateSubmitted.human> @ <tmpl_var timeSubmitted.human></td>\r\n	<tmpl_if displayLastReply>\r\n		<td  class=\"tableData\" style=\"font-size: 11px;\">\r\n			<a href=\"<tmpl_var lastReply.url>\"><tmpl_var lastReply.title></a>\r\n			by \r\n			<tmpl_if lastReply.user.isVisitor>\r\n				<tmpl_var lastReply.username>\r\n			<tmpl_else>\r\n				<a href=\"<tmpl_var lastReply.userProfile.url>\"><tmpl_var lastReply.username></a>\r\n			</tmpl_if>\r\n			on <tmpl_var lastReply.dateSubmitted.human> @ <tmpl_var lastReply.timeSubmitted.human>\r\n		</td>\r\n	</tmpl_if>\r\n</tr>\r\n</tmpl_loop>\r\n</table>\r\n\r\n<tmpl_if pagination.pageCount.isMultiple>\r\n  <div class=\"pagination\">\r\n    <tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo10> &middot; <tmpl_var pagination.nextPage>\r\n  </div>\r\n</tmpl_if>\r\n\r\n\r\n','Collaboration',1,1,'PBtmpl0000000000000026');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a> <tmpl_if session.var.adminOn> <p><tmpl_var controls></p> </tmpl_if><tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_if session.scratch.search>\r\n \r\n</tmpl_if>\r\n\r\n<tmpl_if user.canPost>\r\n   <a href=\"<tmpl_var add.url>\"><tmpl_var post.label></a> &middot;\r\n</tmpl_if>\r\n\r\n<a href=\"<tmpl_var search.url>\"><tmpl_var search.label></a><p />\r\n\r\n<table width=\"100%\" cellpadding=3 cellspacing=0 border=0>\r\n<tr>\r\n<tmpl_loop post_loop>\r\n\r\n<td valign=\"top\" class=\"tableData\" width=\"33%\" style=\"border: 1px dotted #aaaaaa; padding: 10px;\">\r\n  <h2><a href=\"<tmpl_var url>\"><tmpl_var title></a></h2>\r\n  <tmpl_if user.isPoster>\r\n    (<tmpl_var status>)\r\n  </tmpl_if>\r\n<br />\r\n  <tmpl_if thumbnail>\r\n       <a href=\"<tmpl_var url>\"><img src=\"<tmpl_var thumbnail>\" border=\"0\"/ align=\"right\"></a><br />\r\n  </tmpl_if>\r\n<tmpl_var synopsis>\r\n</td>\r\n\r\n<tmpl_if isThird>\r\n  </tr><tr>\r\n</tmpl_if>\r\n\r\n</tmpl_loop>\r\n</tr>\r\n</table>\r\n\r\n<tmpl_if pagination.pageCount.isMultiple>\r\n  <div class=\"pagination\">\r\n    <tmpl_var pagination.previousPage>  ∑ <tmpl_var pagination.pageList.upTo20> ∑ <tmpl_var pagination.nextPage>\r\n  </div>\r\n</tmpl_if>\r\n','Collaboration',1,1,'PBtmpl0000000000000128');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a> <tmpl_if session.var.adminOn> <p><tmpl_var controls></p> </tmpl_if><tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n <tmpl_if user.canPost>\n			<a href=\"<tmpl_var add.url>\"> <tmpl_var addquestion.label></a><p />\r\n</tmpl_if>\r\n\r\n\r\n<tmpl_loop post_loop>\r\n  \n		<tmpl_if user.isPoster>\n			<tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var edit.url>\"><tmpl_var edit.label></a>]</tmpl_unless>\n		</tmpl_if>\n		<tmpl_if user.isModerator>\n			<tmpl_if session.var.adminOn><tmpl_var controls><tmpl_else><tmpl_unless user.isPoster><tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var edit.url>\"><tmpl_var edit.label></a>]</tmpl_unless></tmpl_unless></tmpl_if>\n		</tmpl_if>\n		\r\n  <h2><tmpl_var title></h2>\r\n  <tmpl_var content>\r\n  <p />\r\n</tmpl_loop>\r\n\r\n','Collaboration',1,1,'PBtmpl0000000000000079');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a> <tmpl_if session.var.adminOn> <p><tmpl_var controls></p> </tmpl_if><tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n\r\n <tmpl_if user.canPost>\n			<a href=\"<tmpl_var add.url>\"> <tmpl_var addlink.label></a><p />\r\n</tmpl_if>\r\n\r\n<tmpl_loop post_loop>\r\n   \r\n    \n		<tmpl_if user.isPoster>\n			<tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var edit.url>\"><tmpl_var edit.label></a>]</tmpl_unless>\n		</tmpl_if>\n		<tmpl_if user.isModerator>\n			<tmpl_if session.var.adminOn><tmpl_var controls><tmpl_else><tmpl_unless user.isPoster><tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var edit.url>\"><tmpl_var edit.label></a>]</tmpl_unless></tmpl_unless></tmpl_if>\n		</tmpl_if>\r\n   &middot;\r\n   <a href=\"<tmpl_var userDefined1>\"\r\n   <tmpl_if userDefined2>\r\n          target=\"_blank\"\r\n    </tmpl_if>\r\n    ><span class=\"linkTitle\"><tmpl_var title></span></a>\r\n\r\n    <tmpl_if content>\r\n              - <tmpl_var content>\r\n   </tmpl_if>\r\n   <br/>\r\n</tmpl_loop>\r\n','Collaboration',1,1,'PBtmpl0000000000000083');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a> <tmpl_if session.var.adminOn> <p><tmpl_var controls></p> </tmpl_if><tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n <tmpl_if user.canPost>\n			<a href=\"<tmpl_var add.url>\"> <tmpl_var addlink.label></a><p />\r\n</tmpl_if>\r\n\r\n<ul>\r\n<tmpl_loop post_loop>\r\n<li>\r\n   \n		<tmpl_if user.isPoster>\n			<tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var edit.url>\"><tmpl_var edit.label></a>]</tmpl_unless>\n		</tmpl_if>\n		<tmpl_if user.isModerator>\n			<tmpl_if session.var.adminOn><tmpl_var controls><tmpl_else><tmpl_unless user.isPoster><tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var edit.url>\"><tmpl_var edit.label></a>]</tmpl_unless></tmpl_unless></tmpl_if>\n		</tmpl_if>\r\n   \r\n   <a href=\"<tmpl_var userDefined1>\"\r\n   <tmpl_if userDefined2>\r\n          target=\"_blank\"\r\n    </tmpl_if>\r\n    ><span class=\"linkTitle\"><tmpl_var title></span></a>\r\n\r\n    <tmpl_if content>\r\n              - <tmpl_var content>\r\n   </tmpl_if>\r\n </li>\r\n</tmpl_loop>\r\n</u>','Collaboration',1,1,'PBtmpl0000000000000082');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a>\n<tmpl_if session.var.adminOn>\n	<p><tmpl_var controls></p>\n</tmpl_if>	\n		<style>\r\n.productFeatureHeader,.productSpecificationHeader,.productRelatedHeader,.productAccessoryHeader, .productBenefitHeader  {\r\n    font-weight: bold;\r\n    font-size: 15px;\r\n}\r\n.productFeature,.productSpecification,.productRelated,.productAccessory, .productBenefit {\r\n    font-size: 12px;\r\n}\r\n.productAttributeSeperator {\r\n    background-color: black;\r\n}\r\n</style>\r\n\r\n<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<table width=\"100%\" cellpadding=\"3\" cellspacing=\"0\" border=\"0\">\r\n<tr>\r\n  <td class=\"content\" valign=\"top\">\r\n\r\n<tmpl_if description>\r\n   <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_if price>\r\n    <b>Price:</b> <tmpl_var price><br />\r\n</tmpl_if>\r\n\r\n<tmpl_if productnumber>\r\n    <b>Product Number:</b> <tmpl_var productNumber><br />\r\n</tmpl_if>\r\n\r\n<br>\r\n\r\n<tmpl_if brochure.url>\r\n    <a href=\"<tmpl_var brochure.url>\"><img src=\"<tmpl_var brochure.icon>\" border=0 align=\"absmiddle\"><tmpl_var brochure.label></a><br />\r\n</tmpl_if>\r\n\r\n<tmpl_if manual.url>\r\n    <a href=\"<tmpl_var manual.url>\"><img src=\"<tmpl_var manual.icon>\" border=0 align=\"absmiddle\"><tmpl_var manual.label></a><br />\r\n</tmpl_if>\r\n\r\n<tmpl_if warranty.url>\r\n    <a href=\"<tmpl_var warranty.url>\"><img src=\"<tmpl_var warranty.icon>\" border=0 align=\"absmiddle\"><tmpl_var warranty.label></a><br />\r\n</tmpl_if>\r\n\r\n  </td>\r\n\r\n<td valign=\"top\">\r\n<tmpl_if thumbnail1>\r\n    <a href=\"<tmpl_var image1>\"><img src=\"<tmpl_var thumbnail1>\" border=\"0\" /></a><p />\r\n</tmpl_if>\r\n<tmpl_if thumbnail2>\r\n    <a href=\"<tmpl_var image2>\"><img src=\"<tmpl_var thumbnail2>\" border=\"0\" /></a><p />\r\n</tmpl_if>\r\n<tmpl_if thumbnail3>\r\n    <a href=\"<tmpl_var image3>\"><img src=\"<tmpl_var thumbnail3>\" border=\"0\" /></a><p />\r\n</tmpl_if>\r\n  </td>\r\n</tr>\r\n</table>\r\n\r\n\r\n<table border=\"0\" cellpadding=\"0\" cellspacing=\"5\">\r\n<tr>\r\n<td valign=\"top\" class=\"productFeature\"><div class=\"productFeatureHeader\">Features</div>\r\n\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addfeature.url>\"><tmpl_var addfeature.label></a><p />\r\n</tmpl_if>\r\n\r\n<tmpl_loop feature_loop>\r\n  ∑<tmpl_if session.var.adminOn><tmpl_var feature.controls></tmpl_if><tmpl_var feature.feature><br />\r\n</tmpl_loop>\r\n<p/>\r\n</td>\r\n\r\n  <td class=\"productAttributeSeperator\"><img src=\"^Extras;spacer.gif\" width=\"1\" height=\"1\"></td>\r\n\r\n  <td valign=\"top\" class=\"productBenefit\"><div class=\"productBenefitHeader\">Benefits</div>\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addBenefit.url>\"><tmpl_var addBenefit.label></a><p />\r\n</tmpl_if>\r\n<tmpl_loop benefit_loop>\r\n  ∑<tmpl_if session.var.adminOn><tmpl_var benefit.controls></tmpl_if><tmpl_var benefit.benefit><br />\r\n</tmpl_loop>\r\n<p/></td>\r\n\r\n  <td class=\"productAttributeSeperator\"><img src=\"^Extras;spacer.gif\" width=\"1\" height=\"1\"></td>\r\n\r\n  <td valign=\"top\" class=\"productSpecification\"><div class=\"productSpecificationHeader\">Specifications</div>\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addSpecification.url>\"><tmpl_var addSpecification.label></a><p />\r\n</tmpl_if>\r\n<tmpl_loop specification_loop>\r\n  ∑<tmpl_if session.var.adminOn><tmpl_var specification.controls></tmpl_if><b><tmpl_var specification.label>:</b> <tmpl_var specification.specification> <tmpl_var specification.units><br />\r\n</tmpl_loop>\r\n<p/></td>\r\n\r\n  <td class=\"productAttributeSeperator\"><img src=\"^Extras;spacer.gif\" width=\"1\" height=\"1\"></td>\r\n\r\n  <td valign=\"top\" class=\"productAccessory\"><div class=\"productAccessoryHeader\">Accessories</div>\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addaccessory.url>\"><tmpl_var addaccessory.label></a><p />\r\n</tmpl_if>\r\n\r\n<tmpl_loop accessory_loop>\r\n  ∑<tmpl_if session.var.adminOn><tmpl_var accessory.controls></tmpl_if><a href=\"<tmpl_var accessory.url>\"><tmpl_var accessory.title></a><br />\r\n</tmpl_loop>\r\n<p/></td>\r\n\r\n  <td class=\"productAttributeSeperator\"><img src=\"^Extras;spacer.gif\" width=\"1\" height=\"1\"></td>\r\n\r\n  <td valign=\"top\" class=\"productRelated\"><div class=\"productRelatedHeader\">Related Products</div>\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addRelatedProduct.url>\"><tmpl_var addRelatedProduct.label></a><p />\r\n</tmpl_if>\r\n\r\n<tmpl_loop relatedproduct_loop>\r\n  ∑<tmpl_if session.var.adminOn><tmpl_var RelatedProduct.controls></tmpl_if><a href=\"<tmpl_var relatedproduct.url>\"><tmpl_var relatedproduct.title></a><br />\r\n</tmpl_loop>\r\n</td>\r\n\r\n</tr>\r\n</table>\r\n\r\n','Product',1,1,'PBtmpl0000000000000056');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a>\n<tmpl_if session.var.adminOn>\n	<p><tmpl_var controls></p>\n</tmpl_if>	\n		<style>\r\n.productOptions {\r\n  font-family: Helvetica, Arial, sans-serif;\r\n  font-size: 11px;\r\n}\r\n</style>\r\n\r\n<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n\r\n<tmpl_if image1>\r\n    <img src=\"<tmpl_var image1>\" border=\"0\" /><p />\r\n</tmpl_if>\r\n<table width=\"100%\" cellpadding=\"3\" cellspacing=\"0\" border=\"0\">\r\n<tr>\r\n  <td class=\"content\" valign=\"top\" width=\"66%\"><tmpl_if description>\r\n<tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n  <b>Benefits</b><br />\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addBenefit.url>\"><tmpl_var addBenefit.label></a><p />\r\n</tmpl_if>\r\n\r\n<tmpl_loop benefit_loop>\r\n  ∑<tmpl_if session.var.adminOn><tmpl_var benefit.controls></tmpl_if><tmpl_var benefit.benefit><br />\r\n</tmpl_loop>\r\n\r\n  </td>\r\n  <td valign=\"top\" width=\"34%\" class=\"productOptions\">\r\n\r\n<tmpl_if thumbnail2>\r\n    <a href=\"<tmpl_var image2>\"><img src=\"<tmpl_var thumbnail2>\" border=\"0\" /></a><p />\r\n</tmpl_if>\r\n\r\n<b>Specifications</b><br />\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addSpecification.url>\"><tmpl_var addSpecification.label></a><p />\r\n</tmpl_if>\r\n<tmpl_loop specification_loop>\r\n  ∑<tmpl_if session.var.adminOn><tmpl_var specification.controls></tmpl_if><b><tmpl_var specification.label>:</b> <tmpl_var specification.specification> <tmpl_var specification.units><br />\r\n</tmpl_loop>\r\n\r\n<b>Options</b><br />\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addaccessory.url>\"><tmpl_var addaccessory.label></a><p />\r\n</tmpl_if>\r\n\r\n<tmpl_loop accessory_loop>\r\n  ∑<tmpl_if session.var.adminOn><tmpl_var accessory.controls></tmpl_if><a href=\"<tmpl_var accessory.url>\"><tmpl_var accessory.title></a><br />\r\n</tmpl_loop>\r\n\r\n<b>Other Products</b><br />\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addRelatedProduct.url>\"><tmpl_var addRelatedProduct.label></a><p />\r\n</tmpl_if>\r\n<tmpl_loop relatedproduct_loop>\r\n  ∑<tmpl_if session.var.adminOn><tmpl_var RelatedProduct.controls></tmpl_if><a href=\"<tmpl_var relatedproduct.url>\"><tmpl_var relatedproduct.title></a><br />\r\n</tmpl_loop>\r\n\r\n  </td>\r\n</tr>\r\n</table>\r\n\r\n','Product',1,1,'PBtmpl0000000000000095');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a>\n<tmpl_if session.var.adminOn>\n	<p><tmpl_var controls></p>\n</tmpl_if>	\n		<style>\r\n.productFeatureHeader,.productSpecificationHeader,.productRelatedHeader,.productAccessoryHeader, .productBenefitHeader  {\r\n   font-weight: bold;\r\n   font-size: 15px;\r\n}\r\n.productFeature,.productSpecification,.productRelated,.productAccessory, .productBenefit {\r\n   font-size: 12px;\r\n}\r\n\r\n</style>\r\n\r\n\r\n<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<table width=\"100%\" cellpadding=\"3\" cellspacing=\"0\" border=\"0\">\r\n<tr>\r\n  <td align=\"center\">\r\n<tmpl_if thumbnail1>\r\n    <a href=\"<tmpl_var image1>\"><img src=\"<tmpl_var thumbnail1>\" border=\"0\" /></a>\r\n</tmpl_if>\r\n</td>\r\n   <td align=\"center\">\r\n<tmpl_if thumbnail2>\r\n    <a href=\"<tmpl_var image2>\"><img src=\"<tmpl_var thumbnail2>\" border=\"0\" /></a>\r\n</tmpl_if>\r\n</td>\r\n  <td align=\"center\">\r\n<tmpl_if thumbnail3>\r\n    <a href=\"<tmpl_var image3>\"><img src=\"<tmpl_var thumbnail3>\" border=\"0\" /></a>\r\n</tmpl_if>\r\n</td>\r\n</tr>\r\n</table>\r\n<table border=\"0\" cellpadding=\"0\" cellspacing=\"5\" width=\"100%\">\r\n<tr>\r\n  <td valign=\"top\" class=\"tableData\" width=\"35%\">\r\n\r\n<b>Features</b><br />\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addfeature.url>\"><tmpl_var addfeature.label></a><p />\r\n</tmpl_if>\r\n<tmpl_loop feature_loop>\r\n  ∑<tmpl_if session.var.adminOn><tmpl_var feature.controls></tmpl_if><tmpl_var feature.feature><br />\r\n</tmpl_loop>\r\n<p />\r\n\r\n<b>Benefits</b><br/>\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addBenefit.url>\"><tmpl_var addBenefit.label></a><p />\r\n</tmpl_if>\r\n\r\n<tmpl_loop benefit_loop>\r\n  ∑<tmpl_if session.var.adminOn><tmpl_var benefit.controls></tmpl_if><tmpl_var benefit.benefit><br />\r\n</tmpl_loop>\r\n<p />\r\n\r\n</td>\r\n  <td valign=\"top\" class=\"tableData\" width=\"35%\">\r\n\r\n<b>Specifications</b><br />\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addSpecification.url>\"><tmpl_var addSpecification.label></a><p />\r\n</tmpl_if>\r\n<tmpl_loop specification_loop>\r\n  ∑<tmpl_if session.var.adminOn><tmpl_var specification.controls></tmpl_if><b><tmpl_var specification.label>:</b> <tmpl_var specification.specification> <tmpl_var specification.units><br />\r\n</tmpl_loop>\r\n<p />\r\n\r\n<b>Accessories</b><br />\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addaccessory.url>\"><tmpl_var addaccessory.label></a><p />\r\n</tmpl_if>\r\n\r\n<tmpl_loop accessory_loop>\r\n  ∑<tmpl_if session.var.adminOn><tmpl_var accessory.controls></tmpl_if><a href=\"<tmpl_var accessory.url>\"><tmpl_var accessory.title></a><br />\r\n</tmpl_loop>\r\n<p />\r\n\r\n<b>Related Products</b><br />\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addRelatedProduct.url>\"><tmpl_var addRelatedProduct.label></a><p />\r\n</tmpl_if>\r\n<tmpl_loop relatedproduct_loop>\r\n   ∑<tmpl_if session.var.adminOn><tmpl_var RelatedProduct.controls></tmpl_if><a href=\"<tmpl_var relatedproduct.url>\"><tmpl_var relatedproduct.title></a><br />\r\n</tmpl_loop>\r\n<p />\r\n</td>\r\n  <td class=\"tableData\" valign=\"top\" width=\"30%\">\r\n    <tmpl_if price> \r\n    <b>Price:</b> <tmpl_var price><br />\r\n</tmpl_if>\r\n\r\n<tmpl_if productnumber>\r\n    <b>Product Number:</b> <tmpl_var productNumber><br />\r\n</tmpl_if>\r\n<br />\r\n<tmpl_if brochure.url>\r\n    <a href=\"<tmpl_var brochure.url>\"><img src=\"<tmpl_var brochure.icon>\" border=0 align=\"absmiddle\" /><tmpl_var brochure.label></a><br />\r\n</tmpl_if>\r\n<tmpl_if manual.url>\r\n    <a href=\"<tmpl_var manual.url>\"><img src=\"<tmpl_var manual.icon>\" border=0 align=\"absmiddle\" /><tmpl_var manual.label></a><br />\r\n</tmpl_if>\r\n<tmpl_if warranty.url>\r\n    <a href=\"<tmpl_var warranty.url>\"><img src=\"<tmpl_var warranty.icon>\" border=0 align=\"absmiddle\" /><tmpl_var warranty.label></a><br />\r\n</tmpl_if>\r\n  </td>\r\n</tr>\r\n</table>\r\n\r\n\r\n','Product',1,1,'PBtmpl0000000000000110');
INSERT INTO template VALUES ('<a href=\"<tmpl_var assetId>\"></a>\r\n\r\n<tmpl_if displayTitle>\r\n  <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n  <p><tmpl_var description></p>\r\n</tmpl_if>\r\n\r\n<tmpl_if showAdmin>\r\n<p><tmpl_var controls></p>\r\n</tmpl_if>\r\n\r\n<div style=\"clear: both;\">&nbsp;</div>\r\n\r\n<div>\r\n<!-- begin position 1 -->\r\n<div style=\"width: 50%; float: left;\">\r\n<tmpl_if showAdmin>\r\n	<table border=\"0\" id=\"position1\" class=\"content\"><tbody>\r\n</tmpl_if>\r\n\r\n<tmpl_loop position1_loop>\r\n	<tmpl_if showAdmin>\r\n            	<tr id=\"td<tmpl_var id>\">\r\n            		<td><div id=\"td<tmpl_var id>_div\" class=\"dragable\">      \r\n	</tmpl_if>\r\n\r\n	<div class=\"content\"><tmpl_var dragger.icon><tmpl_var content></div>\r\n\r\n	<tmpl_if showAdmin>\r\n         			</div></td>\r\n            	</tr>\r\n	</tmpl_if>\r\n</tmpl_loop>\r\n\r\n<tmpl_if showAdmin> \r\n            </tbody></table>\r\n</tmpl_if>\r\n</div>\r\n<!-- end position 1 -->\r\n\r\n<!-- begin position 2 -->\r\n<div style=\"width: 50%; float: left;\">\r\n<tmpl_if showAdmin>\r\n	<table border=\"0\" id=\"position2\" class=\"content\"><tbody>\r\n</tmpl_if>\r\n\r\n<tmpl_loop position2_loop>\r\n	<tmpl_if showAdmin>\r\n            	<tr id=\"td<tmpl_var id>\">\r\n            		<td><div id=\"td<tmpl_var id>_div\" class=\"dragable\">      \r\n	</tmpl_if>\r\n\r\n	<div class=\"content\"><tmpl_var dragger.icon><tmpl_var content></div>\r\n\r\n	<tmpl_if showAdmin>\r\n         			</div></td>\r\n            	</tr>\r\n	</tmpl_if>\r\n</tmpl_loop>\r\n\r\n<tmpl_if showAdmin> \r\n            </tbody></table>\r\n</tmpl_if>\r\n</div>\r\n<!-- end position 2 -->\r\n</div>\r\n\r\n<div style=\"clear: both;\">&nbsp;</div>\r\n\r\n\r\n<tmpl_if showAdmin> \r\n	<table><tr id=\"blank\" class=\"hidden\"><td><div><div class=\"empty\">&nbsp;</div></div></td></tr></table>\r\n            <tmpl_var dragger.init>\r\n</tmpl_if>\r\n		','Layout',1,1,'PBtmpl0000000000000135');
INSERT INTO template VALUES ('<a href=\"<tmpl_var assetId>\"></a>\r\n\r\n<tmpl_if displayTitle>\r\n  <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n  <p><tmpl_var description></p>\r\n</tmpl_if>\r\n\r\n<tmpl_if showAdmin>\r\n<p><tmpl_var controls></p>\r\n</tmpl_if>\r\n\r\n<div style=\"clear: both;\">&nbsp;</div>\r\n\r\n<div>\r\n<!-- begin position 1 -->\r\n<div style=\"width: 66%; float: left;\">\r\n<tmpl_if showAdmin>\r\n	<table border=\"0\" id=\"position1\" class=\"content\"><tbody>\r\n</tmpl_if>\r\n\r\n<tmpl_loop position1_loop>\r\n	<tmpl_if showAdmin>\r\n            	<tr id=\"td<tmpl_var id>\">\r\n            		<td><div id=\"td<tmpl_var id>_div\" class=\"dragable\">      \r\n	</tmpl_if>\r\n\r\n	<div class=\"content\"><tmpl_var dragger.icon><tmpl_var content></div>\r\n\r\n	<tmpl_if showAdmin>\r\n         			</div></td>\r\n            	</tr>\r\n	</tmpl_if>\r\n</tmpl_loop>\r\n\r\n<tmpl_if showAdmin> \r\n            </tbody></table>\r\n</tmpl_if>\r\n</div>\r\n<!-- end position 1 -->\r\n\r\n<!-- begin position 2 -->\r\n<div style=\"width: 34%; float: left;\">\r\n<tmpl_if showAdmin>\r\n	<table border=\"0\" id=\"position2\" class=\"content\"><tbody>\r\n</tmpl_if>\r\n\r\n<tmpl_loop position2_loop>\r\n	<tmpl_if showAdmin>\r\n            	<tr id=\"td<tmpl_var id>\">\r\n            		<td><div id=\"td<tmpl_var id>_div\" class=\"dragable\">      \r\n	</tmpl_if>\r\n\r\n	<div class=\"content\"><tmpl_var dragger.icon><tmpl_var content></div>\r\n\r\n	<tmpl_if showAdmin>\r\n         			</div></td>\r\n            	</tr>\r\n	</tmpl_if>\r\n</tmpl_loop>\r\n\r\n<tmpl_if showAdmin> \r\n            </tbody></table>\r\n</tmpl_if>\r\n</div>\r\n<!-- end position 2 -->\r\n</div>\r\n\r\n<div style=\"clear: both;\">&nbsp;</div>\r\n\r\n\r\n<tmpl_if showAdmin> \r\n	<table><tr id=\"blank\" class=\"hidden\"><td><div><div class=\"empty\">&nbsp;</div></div></td></tr></table>\r\n            <tmpl_var dragger.init>\r\n</tmpl_if>\r\n		','Layout',1,1,'PBtmpl0000000000000131');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a>\n<tmpl_if session.var.adminOn>\n	<p><tmpl_var controls></p>\n</tmpl_if>	\n		<style>\r\n.productCollateral {\r\n   font-size: 11px;\r\n}\r\n</style>\r\n\r\n\r\n<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n\r\n<table width=\"100%\">\r\n<tr><td valign=\"top\" class=\"productCollateral\" width=\"100\">\r\n<img src=\"^Extras;spacer.gif\" width=\"100\" height=\"1\" /><br />\r\n<tmpl_if brochure.url>\r\n    <a href=\"<tmpl_var brochure.url>\"><img src=\"<tmpl_var brochure.icon>\" border=0 align=\"absmiddle\" /><tmpl_var brochure.label></a><br />\r\n</tmpl_if>\r\n<tmpl_if manual.url>\r\n    <a href=\"<tmpl_var manual.url>\"><img src=\"<tmpl_var manual.icon>\" border=0 align=\"absmiddle\" /><tmpl_var manual.label></a><br />\r\n</tmpl_if>\r\n<tmpl_if warranty.url>\r\n    <a href=\"<tmpl_var warranty.url>\"><img src=\"<tmpl_var warranty.icon>\" border=0 align=\"absmiddle\" /><tmpl_var warranty.label></a><br />\r\n</tmpl_if>\r\n<br/>\r\n<div align=\"center\">\r\n<tmpl_if thumbnail1>\r\n    <a href=\"<tmpl_var image1>\"><img src=\"<tmpl_var thumbnail1>\" border=\"0\" /></a><p />\r\n</tmpl_if>\r\n<tmpl_if thumbnail2>\r\n    <a href=\"<tmpl_var image2>\"><img src=\"<tmpl_var thumbnail2>\" border=\"0\" /></a><p />\r\n</tmpl_if>\r\n<tmpl_if thumbnail3>\r\n    <a href=\"<tmpl_var image3>\"><img src=\"<tmpl_var thumbnail3>\" border=\"0\" /></a><p />\r\n</tmpl_if>\r\n</div>\r\n</td><td valign=\"top\" class=\"content\" width=\"100%\">\r\n<tmpl_if description>\r\n<tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<b>Specs:</b><br/>\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addSpecification.url>\"><tmpl_var addSpecification.label></a><p />\r\n</tmpl_if>\r\n<tmpl_loop specification_loop>\r\n  ∑<tmpl_if session.var.adminOn><tmpl_var specification.controls></tmpl_if><b><tmpl_var specification.label>:</b> <tmpl_var specification.specification> <tmpl_var specification.units><br />\r\n</tmpl_loop>\r\n<p />\r\n\r\n<b>Features:</b><br/>\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addfeature.url>\"><tmpl_var addfeature.label></a><p />\r\n</tmpl_if>\r\n<tmpl_loop feature_loop>\r\n  ∑<tmpl_if session.var.adminOn><tmpl_var feature.controls></tmpl_if><tmpl_var feature.feature><br />\r\n</tmpl_loop>\r\n<p />\r\n\r\n<b>Options:</b><br />\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addaccessory.url>\"><tmpl_var addaccessory.label></a><p />\r\n</tmpl_if>\r\n<tmpl_loop accessory_loop>\r\n  &middot;<tmpl_if session.var.adminOn><tmpl_var accessory.controls></tmpl_if><a href=\"<tmpl_var accessory.url>\"><tmpl_var accessory.title></a><br />\r\n</tmpl_loop>\r\n\r\n</td></tr>\r\n</table>\r\n','Product',1,1,'PBtmpl0000000000000119');
INSERT INTO template VALUES ('<a href=\"<tmpl_var assetId>\"></a>\r\n\r\n<tmpl_if displayTitle>\r\n  <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n  <p><tmpl_var description></p>\r\n</tmpl_if>\r\n\r\n<tmpl_if showAdmin>\r\n<p><tmpl_var controls></p>\r\n</tmpl_if>\r\n\r\n<tmpl_if showAdmin>\r\n	<table border=\"0\" id=\"position1\" class=\"content\"><tbody>\r\n</tmpl_if>\r\n\r\n<tmpl_loop position1_loop>\r\n	<tmpl_if showAdmin>\r\n            	<tr id=\"td<tmpl_var id>\">\r\n            		<td><div id=\"td<tmpl_var id>_div\" class=\"dragable\">      \r\n	</tmpl_if>\r\n\r\n	<div class=\"content\"><tmpl_var dragger.icon><tmpl_var content></div>\r\n\r\n	<tmpl_if showAdmin>\r\n         			</div></td>\r\n            	</tr>\r\n	</tmpl_if>\r\n</tmpl_loop>\r\n\r\n<tmpl_if showAdmin> \r\n            </tbody></table>\r\n</tmpl_if>\r\n\r\n<tmpl_if showAdmin> \r\n	<table><tr id=\"blank\" class=\"hidden\"><td><div><div class=\"empty\">&nbsp;</div></div></td></tr></table>\r\n            <tmpl_var dragger.init>\r\n</tmpl_if>\r\n		','Layout',1,1,'PBtmpl0000000000000054');
INSERT INTO template VALUES ('<tmpl_if session.var.adminOn><tmpl_if controls><p><tmpl_var controls></p></tmpl_if></tmpl_if><a href=\"<tmpl_var fileUrl>\"><img src=\"<tmpl_var fileIcon>\" alt=\"<tmpl_var title>\" border=\"0\" /><tmpl_var filename></a>','FileAsset',1,1,'PBtmpl0000000000000024');
INSERT INTO template VALUES ('<tmpl_if session.var.adminOn><tmpl_if controls><p><tmpl_var controls></p></tmpl_if></tmpl_if><img src=\"<tmpl_var fileUrl>\" <tmpl_var parameters> />','ImageAsset',1,1,'PBtmpl0000000000000088');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a><tmpl_if session.var.adminOn>\r\n <p><tmpl_var controls></p>\r\n</tmpl_if>\r\n\r\n<tmpl_if displayTitle>\r\n      <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n     <p><tmpl_var description></p>\r\n</tmpl_if>\r\n\r\n<table width=\"100%\" cellpadding=\"3\" cellspacing=\"0\" class=\"content\">\r\n<tmpl_loop subfolder_loop>\r\n<tr>\r\n    <td class=\"tableData\" valign=\"top\"><a href=\"<tmpl_var url>\"><img src=\"<tmpl_var icon.small>\" border=\"0\" alt=\"<tmpl_var title>\"></a> <a href=\"<tmpl_var url>\"><tmpl_var title></td>\r\n<td valign=\"top\" colspan=\"3\"><tmpl_var synopsis></td></tr>\r\n</tmpl_loop>\r\n<tmpl_loop file_loop>\r\n<tr>\r\n <td valign=\"top\" class=\"tableData\"><a href=\"<tmpl_var url>\"><img src=\"<tmpl_var icon.small>\" border=\"0\" alt=\"<tmpl_var title>\"></a> <a href=\"<tmpl_var url>\"><tmpl_var title></td>\r\n   <td class=\"tableData\" valign=\"top\"><tmpl_var synopsis></td>\r\n     <td class=\"tableData\" valign=\"top\">^D(\"%z %Z\",<tmpl_var date.epoch>);</td>\r\n   <td class=\"tableData\" valign=\"top\"><tmpl_var size></td>\r\n</tr>\r\n</tmpl_loop>\r\n\r\n</table>','Folder',1,1,'PBtmpl0000000000000078');
INSERT INTO template VALUES ('<a href=\"<tmpl_var assetId>\"></a>\r\n\r\n<tmpl_if displayTitle>\r\n  <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n  <p><tmpl_var description></p>\r\n</tmpl_if>\r\n\r\n<tmpl_if showAdmin>\r\n<p><tmpl_var controls></p>\r\n</tmpl_if>\r\n\r\n<div style=\"clear: both;\">&nbsp;</div>\r\n\r\n<div>\r\n<!-- begin position 1 -->\r\n<div style=\"width: 34%; float: left;\">\r\n<tmpl_if showAdmin>\r\n	<table border=\"0\" id=\"position1\" class=\"content\"><tbody>\r\n</tmpl_if>\r\n\r\n<tmpl_loop position1_loop>\r\n	<tmpl_if showAdmin>\r\n            	<tr id=\"td<tmpl_var id>\">\r\n            		<td><div id=\"td<tmpl_var id>_div\" class=\"dragable\">      \r\n	</tmpl_if>\r\n\r\n	<div class=\"content\"><tmpl_var dragger.icon><tmpl_var content></div>\r\n\r\n	<tmpl_if showAdmin>\r\n         			</div></td>\r\n            	</tr>\r\n	</tmpl_if>\r\n</tmpl_loop>\r\n\r\n<tmpl_if showAdmin> \r\n            </tbody></table>\r\n</tmpl_if>\r\n</div>\r\n<!-- end position 1 -->\r\n\r\n<!-- begin position 2 -->\r\n<div style=\"width: 66%; float: left;\">\r\n<tmpl_if showAdmin>\r\n	<table border=\"0\" id=\"position2\" class=\"content\"><tbody>\r\n</tmpl_if>\r\n\r\n<tmpl_loop position2_loop>\r\n	<tmpl_if showAdmin>\r\n            	<tr id=\"td<tmpl_var id>\">\r\n            		<td><div id=\"td<tmpl_var id>_div\" class=\"dragable\">      \r\n	</tmpl_if>\r\n\r\n	<div class=\"content\"><tmpl_var dragger.icon><tmpl_var content></div>\r\n\r\n	<tmpl_if showAdmin>\r\n         			</div></td>\r\n            	</tr>\r\n	</tmpl_if>\r\n</tmpl_loop>\r\n\r\n<tmpl_if showAdmin> \r\n            </tbody></table>\r\n</tmpl_if>\r\n</div>\r\n<!-- end position 2 -->\r\n</div>\r\n\r\n<div style=\"clear: both;\">&nbsp;</div>\r\n\r\n<tmpl_if showAdmin> \r\n	<table><tr id=\"blank\" class=\"hidden\"><td><div><div class=\"empty\">&nbsp;</div></div></td></tr></table>\r\n            <tmpl_var dragger.init>\r\n</tmpl_if>\r\n		','Layout',1,1,'PBtmpl0000000000000125');
INSERT INTO template VALUES ('<a href=\"<tmpl_var assetId>\"></a>\r\n\r\n<tmpl_if displayTitle>\r\n  <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n  <p><tmpl_var description></p>\r\n</tmpl_if>\r\n\r\n<tmpl_if showAdmin>\r\n<p><tmpl_var controls></p>\r\n</tmpl_if>\r\n\r\n<div style=\"clear: both;\">&nbsp;</div>\r\n\r\n<div>\r\n<!-- begin position 1 -->\r\n<div style=\"width: 33%; float: left;\">\r\n<tmpl_if showAdmin>\r\n	<table border=\"0\" id=\"position1\" class=\"content\"><tbody>\r\n</tmpl_if>\r\n\r\n<tmpl_loop position1_loop>\r\n	<tmpl_if showAdmin>\r\n            	<tr id=\"td<tmpl_var id>\">\r\n            		<td><div id=\"td<tmpl_var id>_div\" class=\"dragable\">      \r\n	</tmpl_if>\r\n\r\n	<div class=\"content\"><tmpl_var dragger.icon><tmpl_var content></div>\r\n\r\n	<tmpl_if showAdmin>\r\n         			</div></td>\r\n            	</tr>\r\n	</tmpl_if>\r\n</tmpl_loop>\r\n\r\n<tmpl_if showAdmin> \r\n            </tbody></table>\r\n</tmpl_if>\r\n</div>\r\n<!-- end position 1 -->\r\n\r\n\r\n<!-- begin position 2 -->\r\n<div style=\"width: 34%; float: left;\">\r\n<tmpl_if showAdmin>\r\n	<table border=\"0\" id=\"position2\" class=\"content\"><tbody>\r\n</tmpl_if>\r\n\r\n<tmpl_loop position2_loop>\r\n	<tmpl_if showAdmin>\r\n            	<tr id=\"td<tmpl_var id>\">\r\n            		<td><div id=\"td<tmpl_var id>_div\" class=\"dragable\">      \r\n	</tmpl_if>\r\n\r\n	<div class=\"content\"><tmpl_var dragger.icon><tmpl_var content></div>\r\n\r\n	<tmpl_if showAdmin>\r\n         			</div></td>\r\n            	</tr>\r\n	</tmpl_if>\r\n</tmpl_loop>\r\n\r\n<tmpl_if showAdmin> \r\n            </tbody></table>\r\n</tmpl_if>\r\n</div>\r\n<!-- end position 2 -->\r\n\r\n<!-- begin position 3 -->\r\n<div style=\"width: 33%; float: left;\">\r\n<tmpl_if showAdmin>\r\n	<table border=\"0\" id=\"position3\" class=\"content\"><tbody>\r\n</tmpl_if>\r\n\r\n<tmpl_loop position3_loop>\r\n	<tmpl_if showAdmin>\r\n            	<tr id=\"td<tmpl_var id>\">\r\n            		<td><div id=\"td<tmpl_var id>_div\" class=\"dragable\">      \r\n	</tmpl_if>\r\n\r\n	<div class=\"content\"><tmpl_var dragger.icon><tmpl_var content></div>\r\n\r\n	<tmpl_if showAdmin>\r\n         			</div></td>\r\n            	</tr>\r\n	</tmpl_if>\r\n</tmpl_loop>\r\n\r\n<tmpl_if showAdmin> \r\n            </tbody></table>\r\n</tmpl_if>\r\n</div>\r\n<!-- end position 3 -->\r\n\r\n</div>\r\n\r\n<div style=\"clear: both;\">&nbsp;</div>\r\n\r\n<!-- begin position 4 -->\r\n<div>\r\n<tmpl_if showAdmin>\r\n	<table border=\"0\" id=\"position4\" class=\"content\"><tbody>\r\n</tmpl_if>\r\n\r\n<tmpl_loop position4_loop>\r\n	<tmpl_if showAdmin>\r\n            	<tr id=\"td<tmpl_var id>\">\r\n            		<td><div id=\"td<tmpl_var id>_div\" class=\"dragable\">      \r\n	</tmpl_if>\r\n\r\n	<div class=\"content\"><tmpl_var dragger.icon><tmpl_var content></div>\r\n\r\n	<tmpl_if showAdmin>\r\n         			</div></td>\r\n            	</tr>\r\n	</tmpl_if>\r\n</tmpl_loop>\r\n\r\n<tmpl_if showAdmin> \r\n            </tbody></table>\r\n</tmpl_if>\r\n</div>\r\n<!-- end position 4 -->\r\n\r\n\r\n\r\n<tmpl_if showAdmin> \r\n	<table><tr id=\"blank\" class=\"hidden\"><td><div><div class=\"empty\">&nbsp;</div></div></td></tr></table>\r\n            <tmpl_var dragger.init>\r\n</tmpl_if>\r\n		','Layout',1,1,'PBtmpl0000000000000118');
INSERT INTO template VALUES ('<a href=\"<tmpl_var assetId>\"></a>\r\n\r\n<tmpl_if displayTitle>\r\n  <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n  <p><tmpl_var description></p>\r\n</tmpl_if>\r\n\r\n<tmpl_if showAdmin>\r\n<p><tmpl_var controls></p>\r\n</tmpl_if>\r\n\r\n<!-- begin position 1 -->\r\n<div>\r\n<tmpl_if showAdmin>\r\n	<table border=\"0\" id=\"position1\" class=\"content\"><tbody>\r\n</tmpl_if>\r\n\r\n<tmpl_loop position1_loop>\r\n	<tmpl_if showAdmin>\r\n            	<tr id=\"td<tmpl_var id>\">\r\n            		<td><div id=\"td<tmpl_var id>_div\" class=\"dragable\">      \r\n	</tmpl_if>\r\n\r\n	<div class=\"content\"><tmpl_var dragger.icon><tmpl_var content></div>\r\n\r\n	<tmpl_if showAdmin>\r\n         			</div></td>\r\n            	</tr>\r\n	</tmpl_if>\r\n</tmpl_loop>\r\n\r\n<tmpl_if showAdmin> \r\n            </tbody></table>\r\n</tmpl_if>\r\n</div>\r\n<!-- end position 1 -->\r\n\r\n<div style=\"clear: both;\">&nbsp;</div>\r\n\r\n<div>\r\n<!-- begin position 2 -->\r\n<div style=\"width: 33%; float: left;\">\r\n<tmpl_if showAdmin>\r\n	<table border=\"0\" id=\"position2\" class=\"content\"><tbody>\r\n</tmpl_if>\r\n\r\n<tmpl_loop position2_loop>\r\n	<tmpl_if showAdmin>\r\n            	<tr id=\"td<tmpl_var id>\">\r\n            		<td><div id=\"td<tmpl_var id>_div\" class=\"dragable\">      \r\n	</tmpl_if>\r\n\r\n	<div class=\"content\"><tmpl_var dragger.icon><tmpl_var content></div>\r\n\r\n	<tmpl_if showAdmin>\r\n         			</div></td>\r\n            	</tr>\r\n	</tmpl_if>\r\n</tmpl_loop>\r\n\r\n<tmpl_if showAdmin> \r\n            </tbody></table>\r\n</tmpl_if>\r\n</div>\r\n<!-- end position 2 -->\r\n\r\n<!-- begin position 3 -->\r\n<div style=\"width: 34%; float: left;\">\r\n<tmpl_if showAdmin>\r\n	<table border=\"0\" id=\"position3\" class=\"content\"><tbody>\r\n</tmpl_if>\r\n\r\n<tmpl_loop position3_loop>\r\n	<tmpl_if showAdmin>\r\n            	<tr id=\"td<tmpl_var id>\">\r\n            		<td><div id=\"td<tmpl_var id>_div\" class=\"dragable\">      \r\n	</tmpl_if>\r\n\r\n	<div class=\"content\"><tmpl_var dragger.icon><tmpl_var content></div>\r\n\r\n	<tmpl_if showAdmin>\r\n         			</div></td>\r\n            	</tr>\r\n	</tmpl_if>\r\n</tmpl_loop>\r\n\r\n<tmpl_if showAdmin> \r\n            </tbody></table>\r\n</tmpl_if>\r\n</div>\r\n<!-- end position 3 -->\r\n\r\n\r\n<!-- begin position 4 -->\r\n<div style=\"width: 33%; float: left;\">\r\n<tmpl_if showAdmin>\r\n	<table border=\"0\" id=\"position4\" class=\"content\"><tbody>\r\n</tmpl_if>\r\n\r\n<tmpl_loop position4_loop>\r\n	<tmpl_if showAdmin>\r\n            	<tr id=\"td<tmpl_var id>\">\r\n            		<td><div id=\"td<tmpl_var id>_div\" class=\"dragable\">      \r\n	</tmpl_if>\r\n\r\n	<div class=\"content\"><tmpl_var dragger.icon><tmpl_var content></div>\r\n\r\n	<tmpl_if showAdmin>\r\n         			</div></td>\r\n            	</tr>\r\n	</tmpl_if>\r\n</tmpl_loop>\r\n\r\n<tmpl_if showAdmin> \r\n            </tbody></table>\r\n</tmpl_if>\r\n</div>\r\n<!-- end position 4 -->\r\n\r\n</div>\r\n\r\n<div style=\"clear: both;\">&nbsp;</div>\r\n\r\n\r\n<tmpl_if showAdmin> \r\n	<table><tr id=\"blank\" class=\"hidden\"><td><div><div class=\"empty\">&nbsp;</div></div></td></tr></table>\r\n            <tmpl_var dragger.init>\r\n</tmpl_if>\r\n		','Layout',1,1,'PBtmpl0000000000000109');
INSERT INTO template VALUES ('<a href=\"<tmpl_var assetId>\"></a>\r\n\r\n<tmpl_if displayTitle>\r\n  <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n  <p><tmpl_var description></p>\r\n</tmpl_if>\r\n\r\n<tmpl_if showAdmin>\r\n<p><tmpl_var controls></p>\r\n</tmpl_if>\r\n\r\n<!-- begin position 1 -->\r\n<div>\r\n<tmpl_if showAdmin>\r\n	<table border=\"0\" id=\"position1\" class=\"content\"><tbody>\r\n</tmpl_if>\r\n\r\n<tmpl_loop position1_loop>\r\n	<tmpl_if showAdmin>\r\n            	<tr id=\"td<tmpl_var id>\">\r\n            		<td><div id=\"td<tmpl_var id>_div\" class=\"dragable\">      \r\n	</tmpl_if>\r\n\r\n	<div class=\"content\"><tmpl_var dragger.icon><tmpl_var content></div>\r\n\r\n	<tmpl_if showAdmin>\r\n         			</div></td>\r\n            	</tr>\r\n	</tmpl_if>\r\n</tmpl_loop>\r\n\r\n<tmpl_if showAdmin> \r\n            </tbody></table>\r\n</tmpl_if>\r\n</div>\r\n<!-- end position 1 -->\r\n\r\n<div style=\"clear: both;\">&nbsp;</div>\r\n\r\n<div>\r\n<!-- begin position 2 -->\r\n<div style=\"width: 50%; float: left;\">\r\n<tmpl_if showAdmin>\r\n	<table border=\"0\" id=\"position2\" class=\"content\"><tbody>\r\n</tmpl_if>\r\n\r\n<tmpl_loop position2_loop>\r\n	<tmpl_if showAdmin>\r\n            	<tr id=\"td<tmpl_var id>\">\r\n            		<td><div id=\"td<tmpl_var id>_div\" class=\"dragable\">      \r\n	</tmpl_if>\r\n\r\n	<div class=\"content\"><tmpl_var dragger.icon><tmpl_var content></div>\r\n\r\n	<tmpl_if showAdmin>\r\n         			</div></td>\r\n            	</tr>\r\n	</tmpl_if>\r\n</tmpl_loop>\r\n\r\n<tmpl_if showAdmin> \r\n            </tbody></table>\r\n</tmpl_if>\r\n</div>\r\n<!-- end position 2 -->\r\n\r\n<!-- begin position 3 -->\r\n<div style=\"width: 50%; float: left;\">\r\n<tmpl_if showAdmin>\r\n	<table border=\"0\" id=\"position3\" class=\"content\"><tbody>\r\n</tmpl_if>\r\n\r\n<tmpl_loop position3_loop>\r\n	<tmpl_if showAdmin>\r\n            	<tr id=\"td<tmpl_var id>\">\r\n            		<td><div id=\"td<tmpl_var id>_div\" class=\"dragable\">      \r\n	</tmpl_if>\r\n\r\n	<div class=\"content\"><tmpl_var dragger.icon><tmpl_var content></div>\r\n\r\n	<tmpl_if showAdmin>\r\n         			</div></td>\r\n            	</tr>\r\n	</tmpl_if>\r\n</tmpl_loop>\r\n\r\n<tmpl_if showAdmin> \r\n            </tbody></table>\r\n</tmpl_if>\r\n</div>\r\n<!-- end position 3 -->\r\n</div>\r\n\r\n<div style=\"clear: both;\">&nbsp;</div>\r\n\r\n\r\n<!-- begin position 4 -->\r\n<div>\r\n<tmpl_if showAdmin>\r\n	<table border=\"0\" id=\"position4\" class=\"content\"><tbody>\r\n</tmpl_if>\r\n\r\n<tmpl_loop position4_loop>\r\n	<tmpl_if showAdmin>\r\n            	<tr id=\"td<tmpl_var id>\">\r\n            		<td><div id=\"td<tmpl_var id>_div\" class=\"dragable\">      \r\n	</tmpl_if>\r\n\r\n	<div class=\"content\"><tmpl_var dragger.icon><tmpl_var content></div>\r\n\r\n	<tmpl_if showAdmin>\r\n         			</div></td>\r\n            	</tr>\r\n	</tmpl_if>\r\n</tmpl_loop>\r\n\r\n<tmpl_if showAdmin> \r\n            </tbody></table>\r\n</tmpl_if>\r\n</div>\r\n<!-- end position 4 -->\r\n\r\n\r\n\r\n\r\n<tmpl_if showAdmin> \r\n	<table><tr id=\"blank\" class=\"hidden\"><td><div><div class=\"empty\">&nbsp;</div></div></td></tr></table>\r\n            <tmpl_var dragger.init>\r\n</tmpl_if>\r\n		','Layout',1,1,'PBtmpl0000000000000094');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a> <tmpl_if session.var.adminOn> <p><tmpl_var controls></p> </tmpl_if><tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_if user.canPost>\r\n   <a href=\"<tmpl_var add.url>\"><tmpl_var post.label></a> <p />\r\n</tmpl_if>\r\n\r\n\r\n<tmpl_loop post_loop>\r\n\r\n<tmpl_if __odd__>\r\n<div class=\"highlight\">\r\n</tmpl_if>\r\n\r\n<b>On <tmpl_var dateSubmitted.human> <a href=\"<tmpl_var userProfile.url>\"><tmpl_var username></a> from <a href=\"<tmpl_var url>\">the <tmpl_var title> department</a> wrote</b>, <i><tmpl_var synopsis></i>\r\n\r\n<tmpl_if __odd__>\r\n</div >\r\n</tmpl_if>\r\n\r\n<p/>\r\n\r\n</tmpl_loop>\r\n\r\n<tmpl_if pagination.pageCount.isMultiple>\r\n  <div class=\"pagination\">\r\n    <tmpl_var pagination.previousPage> ∑ <tmpl_var pagination.nextPage>\r\n  </div>\r\n</tmpl_if>\r\n','Collaboration',1,1,'PBtmpl0000000000000133');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a>\n<tmpl_if session.var.adminOn>\n	<p><tmpl_var controls></p>\n</tmpl_if>	\n		<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<h1>\r\n<tmpl_if channel.link>\r\n     <a href=\"<tmpl_var channel.link>\" target=\"_blank\"><tmpl_var channel.title></a>    \r\n<tmpl_else>\r\n     <tmpl_var channel.title>\r\n</tmpl_if>\r\n</h1>\r\n\r\n<tmpl_if channel.description>\r\n    <tmpl_var channel.description><p />\r\n</tmpl_if>\r\n\r\n\r\n<tmpl_loop item_loop>\r\n<li>\r\n  <tmpl_if link>\r\n       <a href=\"<tmpl_var link>\" target=\"_blank\"><tmpl_var title></a>    \r\n    <tmpl_else>\r\n       <tmpl_var title>\r\n  </tmpl_if>\r\n     <tmpl_if description>\r\n        - <tmpl_var description>\r\n     </tmpl_if>\r\n     <br>\r\n\r\n</tmpl_loop>','SyndicatedContent',1,1,'PBtmpl0000000000000065');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a>\n<tmpl_if session.var.adminOn>\n	<p><tmpl_var controls></p>\n</tmpl_if>	\n		<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<span class=\"pollQuestion\"><tmpl_var question></span><br />\r\n\r\n<tmpl_if canVote>\r\n\r\n    <tmpl_var form.start>\r\n    <tmpl_loop answer_loop>\r\n         <tmpl_var answer.form> <tmpl_var answer.text><br />\r\n    </tmpl_loop>\r\n     <p />\r\n    <tmpl_var form.submit>\r\n    <tmpl_var form.end>\r\n\r\n<tmpl_else>\r\n\r\n    <tmpl_loop answer_loop>\r\n       <span class=\"pollAnswer\"><hr size=\"1\"><tmpl_var answer.text><br></span>\r\n       <table cellpadding=0 cellspacing=0 border=0><tr>\r\n           <td width=\"<tmpl_var answer.graphWidth>\" class=\"pollColor\"><img src=\"^Extras;spacer.gif\" height=\"1\" width=\"1\"></td>\r\n           <td class=\"pollAnswer\">&nbsp;&nbsp;<tmpl_var answer.percent>% (<tmpl_var answer.total>)</td>\r\n       </tr></table>\r\n    </tmpl_loop>\r\n    <span class=\"pollAnswer\"><hr size=\"1\"><b><tmpl_var responses.label>:</b> <tmpl_var responses.total></span>\r\n\r\n</tmpl_if>\r\n\r\n','Poll',1,1,'PBtmpl0000000000000055');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a>\n<tmpl_if session.var.adminOn>\n	<p><tmpl_var controls></p>\n</tmpl_if>	\n		<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if error_loop>\r\n<ul>\r\n<tmpl_loop error_loop>\r\n  <li><b><tmpl_var error.message></b>\r\n</tmpl_loop>\r\n</ul>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_if canEdit>\r\n      <a href=\"<tmpl_var entryList.url>\"><tmpl_var entryList.label></a>\r\n      &middot; <a href=\"<tmpl_var export.tab.url>\"><tmpl_var export.tab.label></a>\r\n      <tmpl_if entryId>\r\n        &middot; <a href=\"<tmpl_var delete.url>\"><tmpl_var delete.label></a>\r\n      </tmpl_if>\r\n      <tmpl_if session.var.adminOn>\r\n          &middot; <a href=\"<tmpl_var addField.url>\"><tmpl_var addField.label></a>\r\n			 &middot; <a href=\"<tmpl_var addTab.url>\"><tmpl_var addTab.label></a>\r\n     </tmpl_if>\r\n   <p /> \r\n</tmpl_if>\r\n\r\n<tmpl_var form.start>\r\n<table>\r\n<tmpl_loop field_loop>\r\n  <tmpl_unless field.isHidden>\r\n     <tr><td class=\"formDescription\" valign=\"top\">\r\n        <tmpl_if session.var.adminOn><tmpl_if canEdit><tmpl_var field.controls></tmpl_if></tmpl_if>\r\n        <tmpl_var field.label>\r\n     </td><td class=\"tableData\" valign=\"top\">\r\n       <tmpl_if field.isDisplayed>\r\n            <tmpl_var field.value>\r\n       <tmpl_else>\r\n            <tmpl_var field.form>\r\n       </tmpl_if>\r\n        <tmpl_if field.required>*</tmpl_if>\r\n        <span class=\"formSubtext\"><br /><tmpl_var field.subtext></span>\r\n     </td></tr>\r\n  </tmpl_unless>\r\n</tmpl_loop>\r\n<tr><td></td><td><tmpl_var form.send></td></tr>\r\n</table>\r\n\r\n<tmpl_var form.end>\r\n','DataForm',1,1,'PBtmpl0000000000000020');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a>\n<tmpl_if session.var.adminOn>\n	<p><tmpl_var controls></p>\n</tmpl_if>	\n		<tmpl_var edit.url>\n\n<tmpl_loop field_loop><tmpl_unless field.isMailField><tmpl_var field.label>:	 <tmpl_var field.value>\n</tmpl_unless></tmpl_loop>','DataForm',1,1,'PBtmpl0000000000000085');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a>\n<tmpl_if session.var.adminOn>\n	<p><tmpl_var controls></p>\n</tmpl_if>	\n		<tmpl_var acknowledgement>\r\n<p />\r\n<table border=\"0\">\r\n<tmpl_loop field_loop>\r\n<tmpl_unless field.isMailField><tmpl_unless field.isHidden>\r\n  <tr><td class=\"tableHeader\"><tmpl_var field.label></td>\r\n  <td class=\"tableData\"><tmpl_var field.value></td></tr>\r\n</tmpl_unless></tmpl_unless>\r\n</tmpl_loop>\r\n</table>\r\n<p />\r\n<a href=\"<tmpl_var back.url>\"><tmpl_var back.label></a>','DataForm',1,1,'PBtmpl0000000000000104');
INSERT INTO template VALUES ('<a href=\"<tmpl_var back.url>\"><tmpl_var back.label></a>\n<p />\n<table width=\"100%\">\n<tr>\n<td class=\"tableHeader\">Entry ID</td>\n<tmpl_loop field_loop>\n  <tmpl_unless field.isMailField>\n    <td class=\"tableHeader\"><tmpl_var field.label></td>\n  </tmpl_unless field.isMailField>\n</tmpl_loop field_loop>\n<td class=\"tableHeader\">Submission Date</td>\n</tr>\n<tmpl_loop record_loop>\n<tr>\n  <td class=\"tableData\"><a href=\"<tmpl_var record.edit.url>\"><tmpl_var record.entryId></a></td>\n  <tmpl_loop record.data_loop>\n    <tmpl_unless record.data.isMailField>\n       <td class=\"tableData\"><tmpl_var record.data.value></td>\n     </tmpl_unless record.data.isMailField>\n  </tmpl_loop record.data_loop>\n  <td class=\"tableData\"><tmpl_var record.submissionDate.human></td>\n</tr>\n</tmpl_loop record_loop>\n</table>','DataForm/List',1,1,'PBtmpl0000000000000021');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a>\n<tmpl_if session.var.adminOn>\n	<p><tmpl_var controls></p>\n</tmpl_if>	\n		<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_if search.for>\r\n  <tmpl_if content>\r\n    <!-- Display search string. Remove if unwanted -->\r\n    <tmpl_var search.for>\r\n  <tmpl_else>\r\n    <!-- Error: Starting point not found -->\r\n    <b>Error: Search string <i><tmpl_var search.for></i> not found in content.</b>\r\n  </tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_var content>\r\n\r\n<tmpl_if stop.at>\r\n  <tmpl_if content.trailing>\r\n    <!-- Display stop search string. Remove if unwanted -->\r\n    <tmpl_var stop.at>\r\n  <tmpl_else>\r\n    <!-- Warning: End point not found -->\r\n    <b>Warning: Ending search point <i><tmpl_var stop.at></i> not found in content.</b>\r\n  </tmpl_if>\r\n</tmpl_if>','HttpProxy',1,1,'PBtmpl0000000000000033');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a>\n<tmpl_if session.var.adminOn>\n	<p><tmpl_var controls></p>\n</tmpl_if>	\n		<tmpl_if displayTitle>\n    <h1><tmpl_var title></h1>\n</tmpl_if>\n\n<tmpl_if description>\n    <tmpl_var description><p />\n</tmpl_if>\n\n<tmpl_if session.var.adminOn>\n   <a href=\"<tmpl_var forum.add.url>\"><tmpl_var forum.add.label></a><p />\n</tmpl_if>\n\n<tmpl_if areMultipleForums>\n	<table width=\"100%\" cellpadding=\"3\" cellspacing=\"0\">\n		<tr>\n			<tmpl_if session.var.adminOn>\n				<td></td>\n			</tmpl_if>\n			<td class=\"tableHeader\"><tmpl_var title.label></td>\n			<td class=\"tableHeader\"><tmpl_var views.label></td>\n			<td class=\"tableHeader\"><tmpl_var rating.label></td>\n			<td class=\"tableHeader\"><tmpl_var threads.label></td>\n			<td class=\"tableHeader\"><tmpl_var replies.label></td>\n			<td class=\"tableHeader\"><tmpl_var lastpost.label></td>\n		</tr>\n		<tmpl_loop forum_loop>\n			<tr>\n				<tmpl_if session.var.adminOn>\n					<td><tmpl_var forum.controls></td>\n				</tmpl_if>\n				<td class=\"tableData\">\n					<a href=\"<tmpl_var forum.url>\"><tmpl_var forum.title></a><br />\n					<span style=\"font-size: 10px;\"><tmpl_var forum.description></span>\n				</td>\n				<td class=\"tableData\" align=\"center\"><tmpl_var forum.views></td>\n				<td class=\"tableData\" align=\"center\"><tmpl_var forum.rating></td>\n				<td class=\"tableData\" align=\"center\"><tmpl_var forum.threads></td>\n				<td class=\"tableData\" align=\"center\"><tmpl_var forum.replies></td>\n				<td class=\"tableData\"><span style=\"font-size: 10px;\">\n					<a href=\"<tmpl_var forum.lastpost.url>\"><tmpl_var forum.lastpost.subject></a>\n					by \n					<tmpl_if forum.lastpost.user.isVisitor>\n						<tmpl_var forum.lastpost.user.name>\n					<tmpl_else>\n						<a href=\"<tmpl_var forum.lastpost.user.profile>\"><tmpl_var forum.lastpost.user.name></a>\n					</tmpl_if>\n					on <tmpl_var forum.lastpost.date> @ <tmpl_var forum.lastpost.time>\n				</span></td>\n			</tr>\n		</tmpl_loop>\n	</table>\n<tmpl_else>\n	<h2><tmpl_var default.title></h2>\n	<tmpl_if session.var.adminOn>\n		<tmpl_var default.controls><br />\n	</tmpl_if>\n	<tmpl_var default.description><p />\n	<tmpl_var default.listing>\n</tmpl_if>','MessageBoard',1,1,'PBtmpl0000000000000047');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a> <tmpl_if session.var.adminOn> <p><tmpl_var controls></p> </tmpl_if><h1><tmpl_var newheader></h1>\n\n<tmpl_var form.header>\n<table>\n\n<tmpl_if user.isVisitor>\n	<tr><td><tmpl_var visitorName.label></td><td><tmpl_var visitorName.form></td></tr>\n</tmpl_if>\n\n<tr><td><tmpl_var subject.label></td><td><tmpl_var title.form></td></tr>\n<tr><td><tmpl_var message.label></td><td><tmpl_var content.form></td></tr>\n\n<tmpl_if newisNewMessage>\n	<tmpl_unless user.isVisitor>\n		<tr><td><tmpl_var subscribe.label></td><td><tmpl_var subscribe.form></td></tr>\n	</tmpl_unless>\n	<tmpl_if user.isModerator>\n		<tr><td><tmpl_var lock.label></td><td><tmpl_var lock.form></td></tr>\n		<tr><td><tmpl_var sticky.label></td><td><tmpl_var sticky.form></td></tr>\n	</tmpl_if>\n</tmpl_if>\n\n<tr><td><tmpl_var contentType.label></td><td><tmpl_var contentType.form></td></tr>\n<tr><td></td><td><tmpl_var form.submit></td></tr>\n\n</table>\n<tmpl_var form.footer>\n\n<p>\n<tmpl_var full>\n</p>','Collaboration/PostForm',1,1,'PBtmpl0000000000000029');
INSERT INTO template VALUES ('\n<a name=\"<tmpl_var assetId>\"></a> \n<tmpl_if session.var.adminOn> \n	<p><tmpl_var controls></p>\n</tmpl_if>\n\n\n<style>\n	.postBorder {\n		border: 1px solid #cccccc;\n		width: 100%;\n		margin-bottom: 10px;\n	}\n 	.postBorderCurrent {\n		border: 3px dotted black;\n		width: 100%;\n		margin-bottom: 10px;\n	}\n	.postSubject {\n		border-bottom: 1px solid #cccccc;\n		font-weight: bold;\n		padding: 3px;\n	}\n	.postData {\n		border-bottom: 1px solid #cccccc;\n		font-size: 11px;\n		background-color: #eeeeee;\n		color: black;\n		padding: 3px;\n	}\n	.postControls {\n		border-top: 1px solid #cccccc;\n		background-color: #eeeeee;\n		color: black;\n		padding: 3px;\n	}\n	.postMessage {\n		padding: 3px;\n	}\n	.currentThread {\n		background-color: #eeeeee;\n	}\n	.threadHead {\n		font-weight: bold;\n		border-bottom: 1px solid #cccccc;\n		font-size: 11px;\n		background-color: #eeeeee;\n		color: black;\n		padding: 3px;\n	}\n	.threadData {\n		font-size: 11px;\n		padding: 3px;\n	}\n</style>\n	\n\n\n<div style=\"float: left; width: 70%\">\n	<h1><a href=\"<tmpl_var collaboration.url>\"><tmpl_var collaboration.title></a></h1>\n</div>\n<div style=\"width: 30%; float: left; text-align: right;\">\n	<script language=\"JavaScript\" type=\"text/javascript\">	<!--\n	function goLayout(){\n		location = document.layout.layoutSelect.options[document.layout.layoutSelect.selectedIndex].value\n	}\n	//-->	\n	</script>\n	<form name=\"layout\">\n		<select name=\"layoutSelect\" size=\"1\" onChange=\"goLayout()\">\n			<option value=\"<tmpl_var layout.flat.url>\" <tmpl_if layout.isFlat>selected=\"1\"</tmpl_if>><tmpl_var layout.flat.label></option>\n			<option value=\"<tmpl_var layout.nested.url>\" <tmpl_if layout.isNested>selected=\"1\"</tmpl_if>><tmpl_var layout.nested.label></option>\n			<option value=\"<tmpl_var layout.threaded.url>\" <tmpl_if layout.isThreaded>selected=\"1\"</tmpl_if>><tmpl_var layout.threaded.label></option>\n		</select> \n	</form> \n</div>\n<div style=\"clear: both;\"></div>\n\n	\n\n\n\n\n\n\n\n\n<tmpl_if layout.isThreaded>\n<!-- begin threaded layout -->\n	<tmpl_loop post_loop>\n		<tmpl_if isCurrent>\n			<div class=\"postBorder\">\n				<a name=\"<tmpl_var assetId>\"></a>\n				<div class=\"postSubject\">\n					<tmpl_var title>\n				</div>\n				<div class=\"postData\">\n					<div style=\"float: left; width: 50%;\">\n						<b><tmpl_var user.label>:</b> \n							<tmpl_if user.isVisitor>\n								<tmpl_var username>\n							<tmpl_else>\n								<a href=\"<tmpl_var userProfile.url>\"><tmpl_var username></a>\n							</tmpl_if>\n							<br />\n						<b><tmpl_var date.label>:</b> <tmpl_var dateSubmitted.human><br />\n					</div>	\n					<div>\n						<b><tmpl_var views.label>:</b> <tmpl_var views><br />\n						<b><tmpl_var rating.label>:</b> <tmpl_var rating>\n							<tmpl_unless hasRated>\n								 &nbsp; &nbsp;<tmpl_var rate.label> [ <a href=\"<tmpl_var rate.url.1>\">1</a>, <a href=\"<tmpl_var rate.url.2>\">2</a>, <a href=\"<tmpl_var rate.url.3>\">3</a>, <a href=\"<tmpl_var rate.url.4>\">4</a>, <a href=\"<tmpl_var rate.url.5>\">5</a> ]\n							</tmpl_unless>\n							<br />\n						<tmpl_if user.isModerator>\n							<b><tmpl_var status.label>:</b> <tmpl_var status>  &nbsp; &nbsp; [ <a href=\"<tmpl_var approve.url>\"><tmpl_var approve.label></a> | <a href=\"<tmpl_var deny.url>\"><tmpl_var deny.label></a> ]<br />\n						<tmpl_else>	\n							<tmpl_if user.isPoster>\n								<b><tmpl_var status.label>:</b> <tmpl_var status><br />\n							</tmpl_if>	\n						</tmpl_if>	\n					</div>	\n				</div>\n				<div class=\"postMessage\">\n					<tmpl_var content>\n				</div>\n				<tmpl_unless isLocked>\n					<div class=\"postControls\">\n						<tmpl_if user.canReply>\n							<a href=\"<tmpl_var reply.url>\">[<tmpl_var reply.label>]</a>\n						</tmpl_if>\n						<tmpl_if user.canEdit>\n							<a href=\"<tmpl_var edit.url>\">[<tmpl_var edit.label>]</a>\n							<a href=\"<tmpl_var delete.url>\">[<tmpl_var delete.label>]</a>\n						</tmpl_if>\n					</div>\n				</tmpl_unless>\n			</div>	\n		</tmpl_if>\n	</tmpl_loop>\n	<table style=\"width: 100%\">\n		<thead>\n			<tr>\n				<td class=\"threadHead\"><tmpl_var subject.label></td>\n				<td class=\"threadHead\"><tmpl_var user.label></td>\n				<td class=\"threadHead\"><tmpl_var date.label></td>\n			</tr>\n		</thead>\n		<tbody>\n			<tmpl_loop post_loop>\n				<tr <tmpl_if isCurrent>class=\"currentThread\"</tmpl_if>>\n					<td class=\"threadData\"><tmpl_loop indent_loop>&nbsp; &nbsp;</tmpl_loop><a href=\"<tmpl_var url>\"><tmpl_var title.short></a></td>\n					<td class=\"threadData\"><tmpl_var username></td>\n					<td class=\"threadData\"><tmpl_var dateSubmitted.human></td>\n				</tr>\n			</tmpl_loop>\n		</tbody>\n	</table>	\n<!-- end threaded layout -->\n</tmpl_if>\n\n\n\n<tmpl_if layout.isFlat>\n<!-- begin flat layout -->\n	<tmpl_loop post_loop>\n		<div class=\"postBorder<tmpl_if isCurrent>Current</tmpl_if>\">\n			<a name=\"<tmpl_var assetId>\"></a>\n			<div class=\"postSubject\">\n				<tmpl_var title>\n			</div>\n			<div class=\"postData\">\n				<div style=\"float: left; width: 50%\">\n					<b><tmpl_var user.label>:</b> \n						<tmpl_if user.isVisitor>\n							<tmpl_var username>\n						<tmpl_else>\n							<a href=\"<tmpl_var userProfile.url>\"><tmpl_var username></a>\n						</tmpl_if>\n						<br />\n					<b><tmpl_var date.label>:</b> <tmpl_var dateSubmitted.human><br />\n				</div>	\n				<div>\n					<b><tmpl_var views.label>:</b> <tmpl_var views><br />\n					<b><tmpl_var rating.label>:</b> <tmpl_var rating>\n						<tmpl_unless hasRated>\n							 &nbsp; &nbsp;<tmpl_var rate.label> [ <a href=\"<tmpl_var rate.url.1>\">1</a>, <a href=\"<tmpl_var rate.url.2>\">2</a>, <a href=\"<tmpl_var rate.url.3>\">3</a>, <a href=\"<tmpl_var rate.url.4>\">4</a>, <a href=\"<tmpl_var rate.url.5>\">5</a> ]\n						</tmpl_unless>\n						<br />\n					<tmpl_if user.isModerator>\n						<b><tmpl_var status.label>:</b> <tmpl_var status>  &nbsp; &nbsp; [ <a href=\"<tmpl_var approve.url>\"><tmpl_var approve.label></a> | <a href=\"<tmpl_var deny.url>\"><tmpl_var deny.label></a> ]<br />\n					<tmpl_else>	\n						<tmpl_if user.isPoster>\n							<b><tmpl_var status.label>:</b> <tmpl_var status><br />\n						</tmpl_if>	\n					</tmpl_if>	\n				</div>	\n			</div>\n			<div class=\"postMessage\">\n				<tmpl_var content>\n			</div>\n			<tmpl_unless isLocked>\n				<div class=\"postControls\">\n					<tmpl_if user.canReply>\n						<a href=\"<tmpl_var reply.url>\">[<tmpl_var reply.label>]</a>\n					</tmpl_if>\n					<tmpl_if user.canEdit>\n						<a href=\"<tmpl_var edit.url>\">[<tmpl_var edit.label>]</a>\n						<a href=\"<tmpl_var delete.url>\">[<tmpl_var delete.label>]</a>\n					</tmpl_if>\n				</div>\n			</tmpl_unless>\n		</div>\n	</tmpl_loop>\n<!-- end flat layout -->\n</tmpl_if>\n\n\n\n<tmpl_if layout.isNested>\n<!-- begin nested layout -->\n    <tmpl_loop post_loop>\n		<div style=\"margin-left: <tmpl_var depthX10>px;\">\n			<div class=\"postBorder<tmpl_if isCurrent>Current</tmpl_if>\">\n				<a name=\"<tmpl_var assetId>\"></a>\n				<div class=\"postSubject\">\n					<tmpl_var title>\n				</div>\n				<div class=\"postData\">\n					<div style=\"float: left; width: 50%\">\n						<b><tmpl_var user.label>:</b> \n							<tmpl_if user.isVisitor>\n								<tmpl_var username>\n							<tmpl_else>\n								<a href=\"<tmpl_var userProfile.url>\"><tmpl_var username></a>\n							</tmpl_if>\n							<br />\n						<b><tmpl_var date.label>:</b> <tmpl_var dateSubmitted.human><br />\n					</div>	\n					<div>\n						<b><tmpl_var views.label>:</b> <tmpl_var views><br />\n						<b><tmpl_var rating.label>:</b> <tmpl_var rating>\n							<tmpl_unless hasRated>\n								 &nbsp; &nbsp;<tmpl_var rate.label> [ <a href=\"<tmpl_var rate.url.1>\">1</a>, <a href=\"<tmpl_var rate.url.2>\">2</a>, <a href=\"<tmpl_var rate.url.3>\">3</a>, <a href=\"<tmpl_var rate.url.4>\">4</a>, <a href=\"<tmpl_var rate.url.5>\">5</a> ]\n							</tmpl_unless>\n							<br />\n						<tmpl_if user.isModerator>\n							<b><tmpl_var status.label>:</b> <tmpl_var status>  &nbsp; &nbsp; [ <a href=\"<tmpl_var approve.url>\"><tmpl_var approve.label></a> | <a href=\"<tmpl_var deny.url>\"><tmpl_var deny.label></a> ]<br />\n						<tmpl_else>	\n							<tmpl_if user.isPoster>\n								<b><tmpl_var status.label>:</b> <tmpl_var status><br />\n							</tmpl_if>	\n						</tmpl_if>	\n					</div>	\n				</div>\n				<div class=\"postMessage\">\n					<tmpl_var content>\n				</div>\n				<tmpl_unless isLocked>\n					<div class=\"postControls\">\n						<tmpl_if user.canReply>\n							<a href=\"<tmpl_var reply.url>\">[<tmpl_var reply.label>]</a>\n						</tmpl_if>\n						<tmpl_if user.canEdit>\n							<a href=\"<tmpl_var edit.url>\">[<tmpl_var edit.label>]</a>\n							<a href=\"<tmpl_var delete.url>\">[<tmpl_var delete.label>]</a>\n						</tmpl_if>\n					</div>\n				</tmpl_unless>\n			</div>\n		</div>\n	</tmpl_loop>\n<!-- end nested layout -->\n</tmpl_if>\n\n\n\n<tmpl_if pagination.pageCount.isMultiple>\n	<div class=\"pagination\" style=\"margin-top: 20px;\">\n		[ <tmpl_var pagination.previousPage>  | <tmpl_var pagination.pageList.upTo10> | <tmpl_var pagination.nextPage> ]\n	</div>\n</tmpl_if>\n\n\n<div style=\"margin-top: 20px;\">\n    <tmpl_if previous.url>\n		<a href=\"<tmpl_var previous.url>\">[<tmpl_var previous.label>]</a> \n	</tmpl_if>	\n    <tmpl_if next.url>\n		<a href=\"<tmpl_var next.url>\">[<tmpl_var next.label>]</a> \n	</tmpl_if>	\n	<tmpl_if user.canPost>\n		<a href=\"<tmpl_var add.url>\">[<tmpl_var add.label>]</a>\n	</tmpl_if>\n	<tmpl_if user.isModerator>\n		<tmpl_if isSticky>\n			<a href=\"<tmpl_var unstick.url>\">[<tmpl_var unstick.label>]</a>\n		<tmpl_else>\n			<a href=\"<tmpl_var stick.url>\">[<tmpl_var stick.label>]</a>\n		</tmpl_if>\n		<tmpl_if isLocked>\n			<a href=\"<tmpl_var unlock.url>\">[<tmpl_var unlock.label>]</a>\n		<tmpl_else>\n			<a href=\"<tmpl_var lock.url>\">[<tmpl_var lock.label>]</a>\n		</tmpl_if>\n	</tmpl_if>\n	<tmpl_unless user.isVisitor>\n		<tmpl_if user.isSubscribed>\n			<a href=\"<tmpl_var unsubscribe.url>\">[<tmpl_var unsubscribe.label>]</a>\n		<tmpl_else>\n			<a href=\"<tmpl_var subscribe.url>\">[<tmpl_var subscribe.label>]</a>\n		</tmpl_if>\n	</tmpl_unless>\n</div>\n\n','Collaboration/Thread',1,1,'PBtmpl0000000000000032');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a> <tmpl_if session.var.adminOn> <p><tmpl_var controls></p> </tmpl_if><tmpl_var notify.subscription.message>\n\n<tmpl_var url>','Collaboration/Notification',1,1,'PBtmpl0000000000000027');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a> <tmpl_if session.var.adminOn> <p><tmpl_var controls></p> </tmpl_if><tmpl_var form.header>\n<table width=\"100%\" class=\"tableMenu\">\n<tr><td align=\"right\" width=\"15%\">\n	<h1><tmpl_var search.label></h1>\n	</td>\n	<td valign=\"top\" width=\"70%\" align=\"center\">\n		<table>\n			<tr><td class=\"tableData\"><tmpl_var all.label></td><td class=\"tableData\"><tmpl_var all.form></td></tr>\'\n			<tr><td class=\"tableData\"><tmpl_var exactphrase.label></td><td class=\"tableData\"><tmpl_var exactphrase.form></td></tr>\n			<tr><td class=\"tableData\"><tmpl_var atleastone.label></td><td class=\"tableData\"><tmpl_var atleastone.form></td></tr>\n			<tr><td class=\"tableData\"><tmpl_var without.label></td><td class=\"tableData\"><tmpl_var without.form></td></tr>\n			<tr><td class=\"tableData\"><tmpl_var results.label></td><td class=\"tableData\"><tmpl_var results.form></td></tr>\n		</table>\n	</td><td width=\"15%\">\n        		<tmpl_var form.search>\n	</td>\n</tr></table>\n<tmpl_var form.footer>\n<tmpl_if doit>\n	<table width=\"100%\" cellspacing=\"0\" cellpadding=\"3\" border=\"0\">\n	<tr>\n		<td class=\"tableHeader\"><tmpl_var title.label></td>\n		<td class=\"tableHeader\"><tmpl_var user.label></td>\n		<td class=\"tableHeader\"><tmpl_var date.label></td>\n	</tr>\n	<tmpl_loop post_loop>\n			<tr>\n			<td class=\"tableData\"><a href=\"<tmpl_var url>\"><tmpl_var title></a></td>\n			<tmpl_if user.isVisitor>\n				<td class=\"tableData\"><tmpl_var username></td>\n			<tmpl_else>\n				<td class=\"tableData\"><a href=\"<tmpl_var userProfile.url>\"><tmpl_var username></a></td>\n			</tmpl_if>\n			<td class=\"tableData\"><tmpl_var date> @ <tmpl_var time></td>\n		</tr>\n	</tmpl_loop>\n	</table>\n</tmpl_if>\n\n<tmpl_if pagination.pageCount.isMultiple>\n  <div class=\"pagination\">\n    <tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo10> &middot; <tmpl_var pagination.nextPage>\n  </div>\n</tmpl_if>','Collaboration/Search',1,1,'PBtmpl0000000000000031');
INSERT INTO template VALUES ('\n		<tmpl_if displayTitle>\n		<h1><tmpl_var title></h1>\n		</tmpl_if>\n		<tmpl_if description>\n			<p><tmpl_var description></p>\n		</tmpl_if>\n		<tmpl_if session.var.adminOn>\n<tmpl_var controls>\n</tmpl_if>\n<span class=\"horizontalMenu\">\n<tmpl_loop page_loop>\n<a class=\"horizontalMenu\"\n   <tmpl_if page.newWindow>target=\"_blank\"</tmpl_if>\n   href=\"<tmpl_var page.url>\"><tmpl_var page.menuTitle></a>\n   <tmpl_unless \"__last__\"> &middot; </tmpl_unless>\n</tmpl_loop>\n</span>','Navigation',1,1,'PBtmpl0000000000000071');
INSERT INTO template VALUES ('\n		<tmpl_if displayTitle>\n		<h1><tmpl_var title></h1>\n		</tmpl_if>\n		<tmpl_if description>\n			<p><tmpl_var description></p>\n		</tmpl_if>\n		<tmpl_if session.var.adminOn>\n<tmpl_var controls>\n</tmpl_if>\n<span class=\"horizontalMenu\">\n<tmpl_loop page_loop>\n<a class=\"horizontalMenu\" \n   <tmpl_if page.newWindow>target=\"_blank\"</tmpl_if>\n   href=\"<tmpl_var page.url>\"><tmpl_var page.menuTitle></a>\n   <tmpl_unless \"__last__\"> &middot; </tmpl_unless>\n</tmpl_loop>\n</span>','Navigation',1,1,'PBtmpl0000000000000075');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a>\n<tmpl_if session.var.adminOn>\n	<p><tmpl_var controls></p>\n</tmpl_if>	\n		<tmpl_if displayTitle>\n    <h1><tmpl_var title></h1>\n</tmpl_if>\n\n<tmpl_if description>\n    <tmpl_var description><p />\n</tmpl_if>\n\n<h1>\n<tmpl_if channel.link>\n     <a href=\"<tmpl_var channel.link>\" target=\"_blank\"><tmpl_var channel.title></a>    \n<tmpl_else>\n     <tmpl_var channel.title>\n</tmpl_if>\n</h1>\n\n<tmpl_if channel.description>\n    <tmpl_var channel.description><p />\n</tmpl_if>\n\n\n<tmpl_loop item_loop>\n\n       <b><tmpl_var title></b>\n     <tmpl_if description>\n        <br /><tmpl_var description>\n     </tmpl_if>\n  <tmpl_if link>\n       <br /><a href=\"<tmpl_var link>\" target=\"_blank\" style=\"font-size: 9px;\">Read More...</a>    \n   </tmpl_if>\n     <br /><br />\n\n</tmpl_loop>','SyndicatedContent',1,1,'GNvjCFQWjY2AF2uf0aCM8Q');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a> <tmpl_if session.var.adminOn> <p><tmpl_var controls></p> </tmpl_if><h1><tmpl_var header.label></h1><tmpl_var form.header><table><tmpl_if user.isVisitor> <tmpl_if isNewPost><tr><td><tmpl_var visitorName.label></td><td><tmpl_var visitorName.form></td></tr></tmpl_if> </tmpl_if><tr><td><tmpl_var title.label></td><td><tmpl_var title.form></td></tr><tr><td><tmpl_var body.label></td><td><tmpl_var content.form></td></tr><tr><td></td><td></td></tr><tr><td><tmpl_var attachment.label></td><td><tmpl_var attachment.form></td></tr><tr><td><tmpl_var contentType.label></td><td><tmpl_var contentType.form></td></tr><tr><td><tmpl_var startDate.label></td><td><tmpl_var startDate.form></td></tr><tr><td><tmpl_var endDate.label></td><td><tmpl_var endDate.form></td></tr><tr><td></td><td><tmpl_var form.submit></td></tr></table><tmpl_var form.footer>','Collaboration/PostForm',1,1,'PBtmpl0000000000000068');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a> <tmpl_if session.var.adminOn> <p><tmpl_var controls></p> </tmpl_if><h1><tmpl_var question.header.label></h1>\n\n<tmpl_var form.header>\n	<table>\n	<tmpl_if user.isVisitor> <tmpl_if isNewPost>\n		<tr><td><tmpl_var visitorName.label></td><td><tmpl_var visitorName.form></td></tr>\n	</tmpl_if> </tmpl_if>\n	<tr><td><tmpl_var question.label></td><td><tmpl_var title.form.textarea></td></tr>\n	<tr><td><tmpl_var answer.label></td><td><tmpl_var content.form></td></tr>\n	<tr><td><tmpl_var contentType.label></td><td><tmpl_var contentType.form></td></tr>\n	<tr><td></td><td><tmpl_var form.submit></td></tr>\n	</table>\n<tmpl_var form.footer>\n','Collaboration/PostForm',1,1,'PBtmpl0000000000000099');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a> <tmpl_if session.var.adminOn> <p><tmpl_var controls></p> </tmpl_if><h1><tmpl_var link.header.label></h1>\n\n<tmpl_var form.header>\n	<table>\n	<tmpl_if user.isVisitor> <tmpl_if isNewPost>\n		<tr><td><tmpl_var visitorName.label></td><td><tmpl_var visitorName.form></td></tr>\n	</tmpl_if> </tmpl_if>\n	<tr><td><tmpl_var title.label></td><td><tmpl_var title.form></td></tr>\n	<tr><td><tmpl_var description.label></td><td><tmpl_var content.form></td></tr>\n	<tr><td><tmpl_var contentType.label></td><td><tmpl_var contentType.form></td></tr>\n	<tr><td><tmpl_var url.label></td><td><tmpl_var userDefined1.form></td></tr>\n	<tr><td><tmpl_var newWindow.label></td><td><tmpl_var userDefined2.form.yesNo></td></tr>\n	<tr><td></td><td><tmpl_var form.submit></td></tr>\n	</table>\n<tmpl_var form.footer>\n','Collaboration/PostForm',1,1,'PBtmpl0000000000000114');
INSERT INTO template VALUES ('<div class=\"loginBox\">\r\n<tmpl_if user.isVisitor>\r\n	<tmpl_var form.header>\r\n	<table border=\"0\" class=\"loginBox\" cellpadding=\"1\" cellspacing=\"0\">\r\n	<tr>\r\n		<td><tmpl_var username.form></td>\r\n		<td><tmpl_var password.form></td>\r\n		<td><tmpl_var form.login></td>\r\n	</tr>\r\n	<tr>\r\n		<td><tmpl_var username.label></td>\r\n		<td><tmpl_var password.label></td>\r\n		<td></td>\r\n	</tr>\r\n	</table>             	<tmpl_if session.setting.anonymousRegistration>\r\n                        <a href=\"<tmpl_var account.create.url>\"><tmpl_var account.create.label></a>\r\n	</tmpl_if>		<tmpl_var form.footer> \r\n<tmpl_else>\r\n	<tmpl_unless customText>\r\n		<tmpl_var hello.label> <a href=\"<tmpl_var account.display.url>\"><tmpl_var session.user.username></a>.\r\n                          <a href=\"<tmpl_var logout.url>\"><tmpl_var logout.label></a><br />\r\n	<tmpl_else>\r\n		<tmpl_var customText>\r\n	</tmpl_unless>\r\n</tmpl_if>\r\n</div>\r\n','Macro/L_loginBox',1,1,'PBtmpl0000000000000092');
INSERT INTO template VALUES ('<div class=\"loginBox\">\r\n<tmpl_if user.isVisitor>\r\n	<tmpl_var form.header>\r\n             <span><tmpl_var username.label><br></span>\r\n             <tmpl_var username.form>\r\n             <span><br><tmpl_var password.label><br></span>\r\n             <tmpl_var password.form>\r\n             <span><br></span>\r\n             <tmpl_var form.login>\r\n	<tmpl_var form.footer>\r\n	<tmpl_if session.setting.anonymousRegistration>\r\n                        <p><a href=\"<tmpl_var account.create.url>\"><tmpl_var account.create.label></a></p>\r\n	</tmpl_if>	\r\n<tmpl_else>\r\n	<tmpl_unless customText>\r\n		<tmpl_var hello.label> <a href=\"<tmpl_var account.display.url>\"><tmpl_var session.user.username></a>.\r\n                          <a href=\"<tmpl_var logout.url>\"><tmpl_var logout.label></a>\r\n	<tmpl_else>\r\n		<tmpl_var customText>\r\n	</tmpl_unless>\r\n</tmpl_if>\r\n</div>\r\n','Macro/L_loginBox',1,1,'PBtmpl0000000000000044');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a>\n<tmpl_if session.var.adminOn>\n	<p><tmpl_var controls></p>\n</tmpl_if>	\n		<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_if debugMode>\r\n	<ul>\r\n	<tmpl_loop debug_loop>\r\n		<li><tmpl_var debug.output></li>\r\n	</tmpl_loop>\r\n	</ul>\r\n</tmpl_if>\r\n\r\n<table width=\"100%\" cellspacing=0 cellpadding=0 style=\"border: 1px solid black;\">\r\n<tr>\r\n   <tmpl_loop columns_loop>\r\n	<td class=\"tableHeader\"><tmpl_var column.name></td>\r\n   </tmpl_loop>\r\n</tr>\r\n\r\n<tmpl_loop rows_loop>\r\n   <tr>\r\n   <tmpl_loop row.field_loop>\r\n	<td class=\"tableData\"><tmpl_var field.value></td>\r\n   </tmpl_loop>\r\n   </tr>\r\n   <!-- Handle nested query2 -->\r\n   <tmpl_if hasNest>\r\n	<tr>\r\n	<td colspan=\"<tmpl_var columns.count>\">\r\n	<table width=\"100%\" cellspacing=0 cellpadding=0>\r\n	<tr>\r\n	<td width=\"20\">\r\n	   &nbsp;\r\n	</td>\r\n	<td>\r\n	   <table width=\"100%\" cellspacing=0 cellpadding=0 style=\"border: 1px solid black;\">\r\n	   <tr>\r\n	   <tmpl_loop query2.columns_loop>\r\n		<td class=\"tableHeader\"><tmpl_var column.name></td>\r\n	   </tmpl_loop>\r\n	   </tr>\r\n	   <tmpl_loop query2.rows_loop>\r\n	   <tr>\r\n	   <tmpl_loop query2.row.field_loop>\r\n		<td class=\"tableData\"><tmpl_var field.value></td>\r\n	   </tmpl_loop>\r\n	   </tr>\r\n	   <!-- Handle nested query3 -->\r\n	   <tmpl_if query2.hasNest>\r\n		<tr>\r\n		<td colspan=\"<tmpl_var query2.columns.count>\">\r\n		<table width=\"100%\" cellspacing=0 cellpadding=0>\r\n		<tr>\r\n		<td width=\"20\">\r\n		   &nbsp;\r\n		</td>\r\n		<td>\r\n		   <table width=\"100%\" cellspacing=0 cellpadding=0 style=\"border: 1px solid black;\">\r\n		   <tr>\r\n		   <tmpl_loop query3.columns_loop>\r\n			<td class=\"tableHeader\"><tmpl_var column.name></td>\r\n		   </tmpl_loop>\r\n		   </tr>\r\n		   <tmpl_loop query3.rows_loop>\r\n		   <tr>\r\n		   <tmpl_loop query3.row.field_loop>\r\n			<td class=\"tableData\"><tmpl_var field.value></td>\r\n		   </tmpl_loop>\r\n		   </tr>\r\n	   		<!-- Handle nested query4 -->\r\n			   <tmpl_if query3.hasNest>\r\n				<tr>\r\n				<td colspan=\"<tmpl_var query3.columns.count>\">\r\n				<table width=\"100%\" cellspacing=0 cellpadding=0>\r\n				<tr>\r\n				<td width=\"20\">\r\n				   &nbsp;\r\n				</td>\r\n				<td>\r\n				   <table width=\"100%\" cellspacing=0 cellpadding=0 style=\"border: 1px solid black;\">\r\n				   <tr>\r\n				   <tmpl_loop query4.columns_loop>\r\n					<td class=\"tableHeader\"><tmpl_var column.name></td>\r\n				   </tmpl_loop>\r\n				   </tr>\r\n				   <tmpl_loop query4.rows_loop>\r\n				   <tr>\r\n				   <tmpl_loop query4.row.field_loop>\r\n					<td class=\"tableData\"><tmpl_var field.value></td>\r\n				   </tmpl_loop>\r\n			   		<!-- Handle nested query5 -->\r\n					   <tmpl_if query4.hasNest>\r\n						<tr>\r\n						<td colspan=\"<tmpl_var query4.columns.count>\">\r\n						<table width=\"100%\" cellspacing=0 cellpadding=0>\r\n						<tr>\r\n						<td width=\"20\">\r\n						   &nbsp;\r\n						</td>\r\n						<td>\r\n						   <table width=\"100%\" cellspacing=0 cellpadding=0 style=\"border: 1px solid black;\">\r\n						   <tr>\r\n						   <tmpl_loop query5.columns_loop>\r\n							<td class=\"tableHeader\"><tmpl_var column.name></td>\r\n						   </tmpl_loop>\r\n						   </tr>\r\n						   <tmpl_loop query5.rows_loop>\r\n						   <tr>\r\n						   <tmpl_loop query5.row.field_loop>\r\n							<td class=\"tableData\"><tmpl_var field.value></td>\r\n						   </tmpl_loop>\r\n						   </tr>\r\n						   </tmpl_loop>\r\n						   </table>\r\n						</td>\r\n						</tr>\r\n						</table>\r\n					        </td>\r\n			        		</tr>\r\n					   </tmpl_if>\r\n				   </tr>\r\n				   </tmpl_loop>\r\n				   </table>\r\n				</td>\r\n				</tr>\r\n				</table>\r\n			        </td>\r\n			        </tr>\r\n			   </tmpl_if>\r\n		   </tmpl_loop>\r\n		   </table>\r\n		</td>\r\n		</tr>\r\n		</table>\r\n	        </td>\r\n	        </tr>\r\n	   </tmpl_if>\r\n	   </tmpl_loop>\r\n	   </table>\r\n	</td>\r\n	</tr>\r\n	</table>\r\n   </td>\r\n</tr>\r\n</tmpl_if>\r\n</tmpl_loop>\r\n</table>\r\n\r\n<tmpl_if pagination.pageCount.isMultiple>\r\n  <div class=\"pagination\">\r\n    <tmpl_var pagination.previousPage>   <tmpl_var pagination.pageList.upTo20>  <tmpl_var pagination.nextPage>\r\n  </div>\r\n</tmpl_if>','SQLReport',1,1,'PBtmpl0000000000000059');
INSERT INTO template VALUES ('<h1><tmpl_var displayTitle></h1>\r\n\r\n<table width=\"100%\" cellspacing=1 cellpadding=2 border=0>\r\n<tr>\r\n   <td class=\"tableHeader\">\r\n      <tmpl_var message.subject.label>\r\n   </td>\r\n   <td class=\"tableHeader\">\r\n      <tmpl_var message.status.label>\r\n   </td>\r\n   <td class=\"tableHeader\">\r\n      <tmpl_var message.dateOfEntry.label>\r\n   </td>\r\n</tr>\r\n<tmpl_if message.noresults>\r\n   <tr>\r\n       <td class=\"tableData\">\r\n          <tmpl_var message.noresults>\r\n       </td>\r\n       <td class=\"tableData\">\r\n          &nbsp;\r\n       </td>\r\n       <td class=\"tableData\">\r\n          &nbsp;\r\n       </td>\r\n   </tr>\r\n<tmpl_else>\r\n   <tmpl_loop message.loop>\r\n      <tr>\r\n         <td class=\"tableData\">\r\n            <tmpl_var message.subject>\r\n         </td>\r\n         <td class=\"tableData\">\r\n            <tmpl_var message.status>\r\n         </td>\r\n         <td class=\"tableData\">\r\n            <tmpl_var message.dateOfEntry>\r\n         </td>\r\n     </tr>\r\n  </tmpl_loop>\r\n</tmpl_if>\r\n</table>\r\n<tmpl_if message.multiplePages>\r\n  <div class=\"pagination\">\r\n    <tmpl_var message.previousPage>  &middot; <tmpl_var message.pageList> &middot; <tmpl_var message.nextPage>\r\n  </div>\r\n</tmpl_if>\r\n<div class=\"accountOptions\">\r\n   <ul>\r\n      <tmpl_loop message.accountOptions>\r\n         <li><tmpl_var options.display>\r\n      </tmpl_loop>\r\n   </ul>\r\n</div>','Operation/MessageLog/View',1,1,'PBtmpl0000000000000050');
INSERT INTO template VALUES ('<tmpl_var displayTitle>\r\n<b><tmpl_var message.subject></b><br>\r\n<tmpl_var message.dateOfEntry><br>\r\n<tmpl_var message.status><br><br>\r\n<tmpl_var message.text><p>\r\n\r\n<div class=\"accountOptions\">\r\n   <ul>\r\n      <tmpl_if message.takeAction>\r\n         <li><tmpl_var message.takeAction>\r\n      </tmpl_if>\r\n      <tmpl_loop message.accountOptions>\r\n         <li><tmpl_var options.display>\r\n      </tmpl_loop>\r\n   </ul>\r\n</div>\r\n\r\n\r\n','Operation/MessageLog/Message',1,1,'PBtmpl0000000000000049');
INSERT INTO template VALUES ('<tmpl_var displayTitle>\r\n\r\n<tmpl_if profile.message>\r\n   <tmpl_var profile.message>\r\n</tmpl_if>\r\n\r\n<tmpl_var profile.form.header>\r\n<table >\r\n<tmpl_var profile.form.hidden>\r\n\r\n<tmpl_loop profile.form.elements>\r\n     <tr>\r\n       <td class=\"tableHeader\" valign=\"top\" colspan=\"2\">\r\n         <tmpl_var profile.form.category>\r\n       </td>\r\n     </tr>\r\n \r\n <tmpl_loop profile.form.category.loop>\r\n   <tr>\r\n    <td class=\"formDescription\" valign=\"top\">\r\n      <tmpl_var profile.form.element.label>\r\n    </td>\r\n    <td class=\"tableData\">\r\n      <tmpl_var profile.form.element>\r\n      <tmpl_if profile.form.element.subtext>\r\n        <span class=\"formSubtext\">\r\n         <tmpl_var profile.form.element.subtext>\r\n        </span>\r\n      </tmpl_if>\r\n    </td>\r\n   </tr>\r\n </tmpl_loop>\r\n</tmpl_loop>\r\n<tmpl_loop create.form.profile>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var profile.formElement.label></td>\r\n   <td class=\"tableData\"><tmpl_var profile.formElement></td>\r\n</tr>\r\n</tmpl_loop>\r\n<tr>\r\n <td class=\"formDescription\" valign=\"top\"></td>\r\n <td class=\"tableData\">\r\n     <tmpl_var profile.form.submit>\r\n </td>\r\n</tr>\r\n</table>\r\n<tmpl_var create.form.footer>\r\n\r\n<div class=\"accountOptions\">\r\n   <ul>\r\n      <tmpl_loop profile.accountOptions>\r\n         <li><tmpl_var options.display>\r\n      </tmpl_loop>\r\n   </ul>\r\n</div>','Operation/Profile/Edit',1,1,'PBtmpl0000000000000051');
INSERT INTO template VALUES ('<tmpl_var displayTitle>\r\n\r\n<table>\r\n  <tmpl_loop profile.elements>\r\n    <tr>\r\n    <tmpl_if profile.category>\r\n      <td colspan=\"2\" class=\"tableHeader\">\r\n        <tmpl_var profile.category>\r\n      </td>\r\n    <tmpl_else>\r\n      <td class=\"tableHeader\">\r\n         <tmpl_var profile.label>\r\n      </td>\r\n      <td class=\"tableData\">\r\n         <tmpl_var profile.value>\r\n      </td>\r\n    </tmpl_if>   \r\n    </tr>\r\n  </tmpl_loop>\r\n</table>\r\n<div class=\"accountOptions\">\r\n   <ul>\r\n      <tmpl_loop profile.accountOptions>\r\n         <li><tmpl_var options.display>\r\n      </tmpl_loop>\r\n   </ul>\r\n</div>','Operation/Profile/View',1,1,'PBtmpl0000000000000052');
INSERT INTO template VALUES ('^JavaScript(\"<tmpl_var session.config.extrasURL>/textFix.js\");\r\n\r\n<script language=\"JavaScript\">\r\n      var formObj;\r\n      var extrasDir=\"<tmpl_var session.config.extrasURL>\";\r\n      function openEditWindow(obj) {\r\n         formObj = obj;\r\n         window.open(\"<tmpl_var session.config.extrasURL>/lastResortEdit.html\",\"editWindow\",\"width=500,height=410\");\r\n      }\r\n      function setContent(content) {\r\n         formObj.value = content;\r\n      } \r\n</script>\r\n\r\n<tmpl_var button>\r\n\r\n<tmpl_var textarea>','richEditor',1,1,'PBtmpl0000000000000126');
INSERT INTO template VALUES ('<h1><tmpl_var title></h1>\n\n<tmpl_if user.canViewReports>\n	<a href=\"<tmpl_var survey.url>\"><tmpl_var survey.label></a> \n	&bull;\n	<a href=\"<tmpl_var report.gradebook.url>\"><tmpl_var report.gradebook.label></a> \n	&bull;\n	<a href=\"<tmpl_var delete.all.responses.url>\"><tmpl_var delete.all.responses.label></a> \n	<br />\n	<a href=\"<tmpl_var export.answers.url>\"><tmpl_var export.answers.label></a> \n	&bull;\n	<a href=\"<tmpl_var export.questions.url>\"><tmpl_var export.questions.label></a> \n	&bull;\n	<a href=\"<tmpl_var export.responses.url>\"><tmpl_var export.responses.label></a> \n	&bull;\n	<a href=\"<tmpl_var export.composite.url>\"><tmpl_var export.composite.label></a> \n</tmpl_if>\n\n<br /> <br />\n\n<script>\nfunction toggleDiv(divId) {\n   if (document.getElementById(divId).style.visibility == \"none\") {\n	document.getElementById(divId).style.display = \"block\";\n   } else {\n	document.getElementById(divId).style.display = \"none\";	\n   }\n}\n</script>\n\n<tmpl_loop question_loop>\n	<b><tmpl_var question></b>\n              <tmpl_if question.isRadioList>\n                        <table class=\"tableData\">\n                        <tr class=\"tableHeader\"><td width=\"60%\"><tmpl_var answer.label></td>\n                                <td width=\"20%\"><tmpl_var response.count.label></td>\n                                <td width=\"20%\"><tmpl_var response.percent.label></td></tr>\n                        <tmpl_loop answer_loop>\n                                <tmpl_if answer.isCorrect>\n                                        <tr class=\"highlight\">\n                                <tmpl_else>\n                                        <tr>\n                                </tmpl_if>\n                                	<td><tmpl_var answer></td>\n                                	<td><tmpl_var answer.response.count></td>\n                                	<td><tmpl_var answer.response.percent></td>\n			<tmpl_if allowComment>\n                        			<td><a href=\"#\" onClick=\"toggle(\'comment<tmpl_var answer.id>\');\"><tmpl_var show.comments.label></a></td>\n			</tmpl_if>\n                               </tr>\n		<tmpl_if question.allowComment>\n			<tr id=\"comment<tmpl_var answer.id>\">\n				<td colspan=\"3\">\n					<tmpl_loop comment_loop>\n						<p>\n						<tmpl_var answer.comment>\n						</p>\n					</tmpl_loop>\n				</td>\n			</tr>\n		</tmpl_if>\n		</tmpl_loop>\n                        </table>\n               <tmpl_else>\n                        <br />\n		<a href=\"#\" onClick=\"toggle(\'response<tmpl_var question.id>\');\"><tmpl_var show.answers.label></a>\n		<br />\n		<div id=\"response<tmpl_var question.id>\">\n			<tmpl_loop answer_loop>\n				<p>\n				<tmpl_var answer.response>\n				</p>\n                			<tmpl_if question.allowComment>\n					<blockquote>\n					<tmpl_var answer.comment>\n					</blockquote>\n                			</tmpl_if>\n			</tmpl_loop>\n		</div>\n                </tmpl_if>\n	<br /><br /><br />\n\n</tmpl_loop>\n\n\n<tmpl_if pagination.pageCount.isMultiple>\n  <div class=\"pagination\">\n    <tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>\n  </div>\n</tmpl_if>\n\n','Survey/Overview',1,1,'PBtmpl0000000000000063');
INSERT INTO template VALUES ('<h1><tmpl_var title></h1>\n\n<tmpl_if user.canViewReports>\n	<a href=\"<tmpl_var survey.url>\"><tmpl_var survey.label></a> \n	&bull;\n	<a href=\"<tmpl_var report.overview.url>\"><tmpl_var report.overview.label></a> \n	&bull;\n	<a href=\"<tmpl_var delete.all.responses.url>\"><tmpl_var delete.all.responses.label></a> \n	<br />\n	<a href=\"<tmpl_var export.answers.url>\"><tmpl_var export.answers.label></a> \n	&bull;\n	<a href=\"<tmpl_var export.questions.url>\"><tmpl_var export.questions.label></a> \n	&bull;\n	<a href=\"<tmpl_var export.responses.url>\"><tmpl_var export.responses.label></a> \n	&bull;\n	<a href=\"<tmpl_var export.composite.url>\"><tmpl_var export.composite.label></a> \n</tmpl_if>\n\n<br /> <br />\n\n<table class=\"tableData\">\n<tr class=\"tableHeader\"><td width=\"60%\"><tmpl_var response.user.label></td>\n                <td width=\"20%\"><tmpl_var response.count.label></td>\n                <td width=\"20%\"><tmpl_var response.percent.label></td></tr>\n<tmpl_loop response_loop>\n<tr>\n	<td><a href=\"<tmpl_var response.url>\"><tmpl_var response.user.name></a></td>\n	<td><tmpl_var response.count.correct>/<tmpl_var question.count></td>\n             <td><tmpl_var response.percent>%</td>\n</tr>\n</tmpl_loop>\n</table>\n\n\n<tmpl_if pagination.pageCount.isMultiple>\n  <div class=\"pagination\">\n    <tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>\n  </div>\n</tmpl_if>\n','Survey/Gradebook',1,1,'PBtmpl0000000000000062');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a>\n<tmpl_if session.var.adminOn>\n	<p><tmpl_var controls></p>\n</tmpl_if>	\n		<tmpl_if displayTitle>\n    <h1><tmpl_var title></h1>\n</tmpl_if>\n\n\n<tmpl_if description>\n  <tmpl_var description><p />\n</tmpl_if>\n\n\n<tmpl_if user.canTakeSurvey>\n	<tmpl_if response.isComplete>\n		<tmpl_if mode.isSurvey>\n			<tmpl_var thanks.survey.label>\n		<tmpl_else>\n			<tmpl_var thanks.quiz.label>\n			<div align=\"center\">\n				<b><tmpl_var questions.correct.count.label>:</b> <tmpl_var questions.correct.count> / <tmpl_var questions.total>\n				<br />\n				<b><tmpl_var questions.correct.percent.label>:</b><tmpl_var questions.correct.percent>% \n			</div>\n		</tmpl_if>\n		<tmpl_if user.canRespondAgain>\n			<br /> <br /> <a href=\"<tmpl_var start.newResponse.url>\"><tmpl_var start.newResponse.label></a>\n		</tmpl_if>\n	<tmpl_else>\n		<tmpl_if response.id>\n			<tmpl_var form.header>\n			<table width=\"100%\" cellpadding=\"3\" cellspacing=\"0\" border=\"0\" class=\"content\">\n				<tr>\n					<td valign=\"top\">\n					<tmpl_loop question_loop>\n						<p><tmpl_var question.question></p>\n						<tmpl_var question.answer.label><br />\n						<tmpl_var question.answer.field><br />\n						<br />\n						<tmpl_if question.allowComment>\n							<tmpl_var question.comment.label><br />\n							<tmpl_var question.comment.field><br />\n						</tmpl_if>\n					</tmpl_loop>\n					</td>\n					<td valign=\"top\" nowrap=\"1\">\n						<b><tmpl_var questions.sofar.label>:</b> <tmpl_var questions.sofar.count> / <tmpl_var questions.total> <br />\n						<tmpl_unless mode.isSurvey>\n							<b><tmpl_var questions.correct.count.label>:</b> <tmpl_var questions.correct.count> / <tmpl_var questions.sofar.count><br />\n							<b><tmpl_var questions.correct.percent.label>:</b><tmpl_var questions.correct.percent>% / 100%<br />\n						</tmpl_unless>\n					</td>\n				</tr>\n			</table>\n			<div align=\"center\"><tmpl_var form.submit></div>\n			<tmpl_var form.footer>\n		<tmpl_else>\n			<a href=\"<tmpl_var start.newResponse.url>\"><tmpl_var start.newResponse.label></a>\n		</tmpl_if>\n	</tmpl_if>\n<tmpl_else>\n	<tmpl_if mode.isSurvey>\n		<tmpl_var survey.noprivs.label>\n	<tmpl_else>\n		<tmpl_var quiz.noprivs.label>\n	</tmpl_if>\n</tmpl_if>\n<br />\n<br />\n<tmpl_if user.canViewReports>\n	<a href=\"<tmpl_var report.gradebook.url>\"><tmpl_var report.gradebook.label></a> \n	&bull;\n	<a href=\"<tmpl_var report.overview.url>\"><tmpl_var report.overview.label></a> \n	&bull;\n	<a href=\"<tmpl_var delete.all.responses.url>\"><tmpl_var delete.all.responses.label></a> \n	<br />\n	<a href=\"<tmpl_var export.answers.url>\"><tmpl_var export.answers.label></a> \n	&bull;\n	<a href=\"<tmpl_var export.questions.url>\"><tmpl_var export.questions.label></a> \n	&bull;\n	<a href=\"<tmpl_var export.responses.url>\"><tmpl_var export.responses.label></a> \n	&bull;\n	<a href=\"<tmpl_var export.composite.url>\"><tmpl_var export.composite.label></a> \n</tmpl_if>\n\n\n<tmpl_if session.var.adminOn>\n	<p>\n		<a href=\"<tmpl_var question.add.url>\"><tmpl_var question.add.label></a>\n	</p>\n	<tmpl_loop question.edit_loop>\n		<tmpl_var question.edit.controls>\n          	<tmpl_var question.edit.question>\n		<br />\n        </tmpl_loop>\n</tmpl_if>\n','Survey',1,1,'PBtmpl0000000000000061');
INSERT INTO template VALUES ('<h1><tmpl_var title></h1>\n\n<tmpl_if user.canViewReports>\n	<a href=\"<tmpl_var survey.url>\"><tmpl_var survey.label></a> \n	&bull;\n	<a href=\"<tmpl_var report.overview.url>\"><tmpl_var report.overview.label></a> \n	&bull;\n	<a href=\"<tmpl_var report.gradebook.url>\"><tmpl_var report.gradebook.label></a> \n</tmpl_if>\n<a href=\"<tmpl_var delete.url>\"><tmpl_var delete.label></a><p/>\n<b><tmpl_var start.date.label>:</b> <tmpl_var start.date.human> <tmpl_var start.time.human><br />\n<b><tmpl_var end.date.label>:</b> <tmpl_var end.date.human> <tmpl_var end.time.human><br />\n<b><tmpl_var duration.label>:</b> <tmpl_var duration.minutes> <tmpl_var duration.minutes.label> <tmpl_var duration.seconds> <tmpl_var duration.seconds.label>\n\n<p/>\n<tmpl_loop question_loop>\n\n               <b><tmpl_var question></b><br />\n                  <table class=\"tableData\" width=\"100%\">\n<tmpl_if question.isRadioList>\n               \n    <tr><td valign=\"top\" class=\"tableHeader\" width=\"25%\">\n                               <tmpl_var answer.label></td><td width=\"75%\">\n                   <tmpl_var question.answer>                       \n</td></tr>\n        </tmpl_if>\n               <tr><td width=\"25%\" valign=\"top\" class=\"tableHeader\"><tmpl_var response.label></td>\n               \n<td width=\"75%\"><tmpl_var question.response></td></tr>\n                <tmpl_if question.comment>\n                        <tr><td valign=\"top\" class=\"tableHeader\">\n                                <tmpl_var comment.label> </td>\n                                <td><tmpl_var question.comment></td></tr>\n               </tmpl_if>\n\n       </table><p/>\n</tmpl_loop>','Survey/Response',1,1,'PBtmpl0000000000000064');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a>\n<tmpl_if session.var.adminOn>\n	<p><tmpl_var controls></p>\n</tmpl_if>	\n		<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if error_loop>\r\n	<ul>\r\n		<tmpl_loop error_loop>\r\n			<li><b><tmpl_var error.message></b>\r\n			</tmpl_loop>\r\n	</ul>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n	<tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_if canEdit>\r\n	<a href=\"<tmpl_var entryList.url>\"><tmpl_var entryList.label></a>\r\n		&middot; <a href=\"<tmpl_var export.tab.url>\"><tmpl_var export.tab.label></a>\r\n	<tmpl_if entryId>\r\n		&middot; <a href=\"<tmpl_var delete.url>\"><tmpl_var delete.label></a>\r\n	</tmpl_if>\r\n	<tmpl_if session.var.adminOn>\r\n		&middot; <a href=\"<tmpl_var addField.url>\"><tmpl_var addField.label></a>\r\n		&middot; <a href=\"<tmpl_var addTab.url>\"><tmpl_var addTab.label></a>\r\n	</tmpl_if>\r\n<p /> \r\n</tmpl_if>\r\n<tmpl_var form.start>\r\n<link href=\"/extras/tabs/tabs.css\" rel=\"stylesheet\" rev=\"stylesheet\" type=\"text/css\">\r\n<div class=\"tabs\">\r\n	<tmpl_loop tab_loop>\r\n		<span onclick=\"toggleTab(<tmpl_var tab.sequence>)\" id=\"tab<tmpl_var tab.sequence>\" class=\"tab\"><tmpl_var tab.label>\r\n		<tmpl_if session.var.adminOn>\r\n			<tmpl_if canEdit>\r\n				<tmpl_var tab.controls>\r\n			</tmpl_if>\r\n		</tmpl_if>\r\n		</span>\r\n	</tmpl_loop>\r\n</div>\r\n<tmpl_loop tab_loop>\r\n	<tmpl_var tab.start>\r\n		<table>\r\n			<tmpl_loop tab.field_loop>\r\n				<tmpl_unless tab.field.isHidden>\r\n						<tr>\r\n							<td class=\"formDescription\" valign=\"top\">\r\n								<tmpl_if session.var.adminOn>\r\n									<tmpl_if canEdit>\r\n										<tmpl_var tab.field.controls>\r\n									</tmpl_if>\r\n								</tmpl_if>\r\n								<tmpl_var tab.field.label>\r\n							</td>\r\n							<td class=\"tableData\" valign=\"top\">\r\n								<tmpl_if tab.field.isDisplayed>\r\n									<tmpl_var tab.field.value>\r\n								<tmpl_else>\r\n									<tmpl_var tab.field.form>\r\n								</tmpl_if>\r\n								<tmpl_if tab.field.isRequired>*</tmpl_if>\r\n								<span class=\"formSubtext\">\r\n									<br />\r\n									<tmpl_var tab.field.subtext>\r\n								</span>\r\n							</td>\r\n						</tr>\r\n				</tmpl_unless>\r\n			</tmpl_loop>\r\n			<tr>\r\n				<td colspan=\"2\">\r\n					<span class=\"tabSubtext\"><tmpl_var tab.subtext></span>\r\n				</td>\r\n			</tr>\r\n		</table>\r\n		<br>\r\n		<tmpl_var form.save>\r\n	<tmpl_var tab.end>\r\n</tmpl_loop>\r\n<tmpl_var tab.init>\r\n<tmpl_var form.end>\r\n','DataForm',1,1,'PBtmpl0000000000000116');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a>\n<tmpl_if session.var.adminOn>\n	<p><tmpl_var controls></p>\n</tmpl_if>	\n		<h1><tmpl_var title></h1>\n\n<tmpl_if description>\n  <tmpl_var description><br /><br />\n</tmpl_if>\n\n\r\n<tmpl_if results>\r\n  <tmpl_loop results>\r\n    The current temp is: <tmpl_var result>\r\n  </tmpl_loop>\r\n<tmpl_else>\r\n  Failed to retrieve temp.\r\n</tmpl_if>','WSClient',1,1,'PBtmpl0000000000000069');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a>\n<tmpl_if session.var.adminOn>\n	<p><tmpl_var controls></p>\n</tmpl_if>	\n		<style>\n.googleDetail {\n  font-size: 9px;\n}\n</style>\n\n<h1><tmpl_var title></h1>\n\n<tmpl_if description>\n  <tmpl_var description><br /><br />\n</tmpl_if>\n\n<form method=\"post\">\n <input type=\"hidden\" name=\"func\" value=\"view\">\n <input type=\"hidden\" name=\"wid\" value=\"<tmpl_var wobjectId>\">\n <input type=\"hidden\" name=\"targetWobjects\" value=\"doGoogleSearch\">\n <input type=\"text\" name=\"q\"><input type=\"submit\" value=\"Search\">\n</form>\n\n<tmpl_if results>\n  <tmpl_loop results>\n   <tmpl_if resultElements>\n      <p> You searched for <b><tmpl_var searchQuery></b>. We found around <tmpl_var estimatedTotalResultsCount> matching records.</p>\n   </tmpl_if>\n\n   <tmpl_loop resultElements>\n     <a href=\"<tmpl_var URL>\">\n	<tmpl_if title>\n		    <tmpl_var title>\n	<tmpl_else>\n                    <tmpl_var url>\n        </tmpl_if>\n     </a><br />\n        <tmpl_if snippet>\n            <tmpl_var snippet><br />\n        </tmpl_if>\n        <div class=\"googleDetail\">\n        <tmpl_if summary>\n            <b>Description:</b> <tmpl_var summary><br />\n        </tmpl_if>\n        <a href=\"<tmpl_var URL>\"><tmpl_var URL></a>\n     <tmpl_if cachedSize>\n           - <tmpl_var cachedSize>\n     </tmpl_if>\n     </div><br />\n    </tmpl_loop>\n  </tmpl_loop>\n<tmpl_else>\n   Could not retrieve results from Google.\n</tmpl_if>','WSClient',1,1,'PBtmpl0000000000000100');
INSERT INTO template VALUES ('<script language=\"JavaScript\" type=\"text/javascript\">   <!--\r\n        function goContent(){\r\n                location = document.content.contentSelect.options[document.content.contentSelect.selectedIndex].value\r\n        }\r\n        function goAdmin(){\r\n                location = document.admin.adminSelect.options[document.admin.adminSelect.selectedIndex].value\r\n        }\r\n        //-->   </script>\r\n \r\n<div class=\"adminBar\">\r\n<table class=\"adminBar\" cellpadding=\"3\" cellspacing=\"0\" border=\"0\">\r\n	<tr>\r\n        		<form name=\"content\"> <td>\r\n<select name=\"contentSelect\" onChange=\"goContent()\">\r\n<option value=\"\"><tmpl_var addcontent.label></option>\r\n\r\n<tmpl_if clipboard_loop>\r\n<optgroup label=\"<tmpl_var clipboard.label>\">	\r\n<tmpl_loop clipboard_loop>\r\n<option value=\"<tmpl_var clipboard.url>\"><tmpl_var clipboard.label></option>\r\n</tmpl_loop>\r\n</optgroup>\r\n</tmpl_if>\r\n<tmpl_loop container_loop> <option value=\"<tmpl_var container.url>\"><tmpl_var container.label></option> </tmpl_loop>\r\n<tmpl_if contentTypes_loop>\r\n<optgroup label=\"<tmpl_var contentTypes.label>\">	\r\n<tmpl_loop contentTypes_loop>\r\n<option value=\"<tmpl_var contentType.url>\"><tmpl_var contentType.label></option>\r\n</tmpl_loop>\r\n</optgroup>\r\n</tmpl_if>\r\n\r\n<tmpl_if package_loop>\r\n<optgroup label=\"<tmpl_var packages.label>\">	\r\n<tmpl_loop package_loop>\r\n<option value=\"<tmpl_var package.url>\"><tmpl_var package.label></option>\r\n</tmpl_loop>\r\n</optgroup>\r\n</tmpl_if>\r\n\r\n</select>\r\n		</td> </form>\r\n\r\n        		<form name=\"admin\"> <td align=\"center\">\r\n			<select name=\"adminSelect\" onChange=\"goAdmin()\">\r\n				<option value=\"\"><tmpl_var admin.label></option>\r\n				<tmpl_loop admin_loop>\r\n					<option value=\"<tmpl_var admin.url>\"><tmpl_var admin.label></option>\r\n				</tmpl_loop>\r\n			</select>\r\n		</td> </form>\r\n        	</tr>\r\n</table>\r\n</div>\r\n','Macro/AdminBar',1,1,'PBtmpl0000000000000035');
INSERT INTO template VALUES ('^JavaScript(\"<tmpl_var session.config.extrasURL>/coolmenus/coolmenus4.js\");\r\n<style type=\"text/css\">\r\n                                                                                                                                                          \r\n.adminBarTop,.adminBarTopOver,.adminBarSub,.adminBarSubOver{position:absolute; overflow:hidden; cursor:pointer; cursor:hand}\r\n.adminBarTop,.adminBarTopOver{padding:4px; font-size:12px; font-weight:bold}\r\n.adminBarTop{color:white; border: 1px solid #aaaaaa; }\r\n.adminBarTopOver,.adminBarSubOver{color:#EC4300;}\r\n.adminBarSub,.adminBarSubOver{padding:2px; font-size:11px; font-weight:bold}\r\n.adminBarSub{color: white; background-color: #666666; layer-background-color: #666666;}\r\n.adminBarSubOver,.adminBarSubOver,.adminBarBorder,.adminBarBkg{layer-background-color: black; background-color: black;}\r\n.adminBarBorder{position:absolute; visibility:hidden; z-index:300}\r\n.adminBarBkg{position:absolute; width:10; height:10; visibility:hidden; }\r\n</style>\r\n\r\n<script language=\"JavaScript1.2\">\r\n/*****************************************************************************\r\nCopyright (c) 2001 Thomas Brattli (webmaster@dhtmlcentral.com)\r\n                                                                                                                                                             \r\nDHTML coolMenus - Get it at coolmenus.dhtmlcentral.com\r\nVersion 4.0_beta\r\nThis script can be used freely as long as all copyright messages are\r\nintact.\r\n                                                                                                                                                             \r\nExtra info - Coolmenus reference/help - Extra links to help files ****\r\nCSS help: http://192.168.1.31/projects/coolmenus/reference.asp?m=37\r\nGeneral: http://coolmenus.dhtmlcentral.com/reference.asp?m=35\r\nMenu properties: http://coolmenus.dhtmlcentral.com/properties.asp?m=47\r\nLevel properties: http://coolmenus.dhtmlcentral.com/properties.asp?m=48\r\nBackground bar properties: http://coolmenus.dhtmlcentral.com/properties.asp?m=49\r\nItem properties: http://coolmenus.dhtmlcentral.com/properties.asp?m=50\r\n******************************************************************************/\r\nadminBar=new makeCM(\"adminBar\"); \r\n\r\n//menu properties\r\nadminBar.resizeCheck=1; \r\nadminBar.rows=1;  \r\nadminBar.onlineRoot=\"\"; \r\nadminBar.pxBetween =0;\r\nadminBar.fillImg=\"\"; \r\nadminBar.fromTop=0; \r\nadminBar.fromLeft=30; \r\nadminBar.wait=600; \r\nadminBar.zIndex=10000;\r\nadminBar.menuPlacement=\"left\";\r\n\r\n//background bar properties\r\nadminBar.useBar=1; \r\nadminBar.barWidth=\"\"; \r\nadminBar.barHeight=\"menu\"; \r\nadminBar.barX=0;\r\nadminBar.barY=\"menu\"; \r\nadminBar.barClass=\"adminBarBkg\";\r\nadminBar.barBorderX=0; \r\nadminBar.barBorderY=0;\r\n\r\nadminBar.level[0]=new cm_makeLevel(160,20,\"adminBarTop\",\"adminBarTopOver\",1,1,\"adminBarBorder\",0,\"bottom\",0,0,0,0,0);\r\nadminBar.level[1]=new cm_makeLevel(160,18,\"adminBarSub\",\"adminBarSubOver\",1,1,\"adminBarBorder\",0,\"right\",0,5,\"menu_arrow.gif\",10,10);\r\n\r\n\r\nadminBar.makeMenu(\'addcontent\',\'\',\'<tmpl_var addcontent.label>\',\'\');\r\n\r\n<tmpl_if clipboard_loop>\r\nadminBar.makeMenu(\'clipboard\',\'addcontent\',\'<tmpl_var clipboard.label> &raquo;\',\'\');\r\n<tmpl_loop clipboard_loop> \r\n	adminBar.makeMenu(\'clipboard<tmpl_var __counter__>\',\'clipboard\',\'<tmpl_var clipboard.label>\',\'<tmpl_var clipboard.url>\');\r\n</tmpl_loop>\r\n</tmpl_if>\r\n<tmpl_loop container_loop> adminBar.makeMenu(\'container<tmpl_var __counter__>\',\'addcontent\',\'<tmpl_var container.label>\',\'<tmpl_var container.url>\'); </tmpl_loop>\r\n<tmpl_if contentTypes_loop>\r\nadminBar.makeMenu(\'contentTypes\',\'addcontent\',\'<tmpl_var contentTypes.label> &raquo;\',\'\');\r\n<tmpl_loop contentTypes_loop> \r\n	adminBar.makeMenu(\'contentTypes<tmpl_var __counter__>\',\'contentTypes\',\'<tmpl_var contentType.label>\',\'<tmpl_var contentType.url>\');\r\n</tmpl_loop>\r\n</tmpl_if>\r\n\r\n<tmpl_if package_loop>\r\n<tmpl_if packages.canAdd>\r\nadminBar.makeMenu(\'packages\',\'addcontent\',\'<tmpl_var packages.label> &raquo;\',\'\');\r\n<tmpl_loop package_loop> \r\n	adminBar.makeMenu(\'package<tmpl_var __counter__>\',\'packages\',\'<tmpl_var package.label>\',\'<tmpl_var package.url>\');\r\n</tmpl_loop>\r\n</tmpl_if>\r\n</tmpl_if>\r\n\r\n\r\nadminBar.makeMenu(\'admin\',\'\',\'<tmpl_var admin.label>\',\'\');\r\n<tmpl_loop admin_loop> \r\n	adminBar.makeMenu(\'admin<tmpl_var admin.count>\',\'admin\',\'<tmpl_var admin.label>\',\'<tmpl_var admin.url>\');\r\n</tmpl_loop>\r\n \r\nadminBar.construct()\r\n</script>\r\n','Macro/AdminBar',1,1,'PBtmpl0000000000000090');
INSERT INTO template VALUES ('\n		<tmpl_if displayTitle>\n		<h1><tmpl_var title></h1>\n		</tmpl_if>\n		<tmpl_if description>\n			<p><tmpl_var description></p>\n		</tmpl_if>\n		<tmpl_if session.var.adminOn>\r\n<tmpl_var controls>\r\n</tmpl_if>\r\n<span class=\"crumbTrail\">\r\n<tmpl_loop page_loop>\r\n<a class=\"crumbTrail\" \r\n   <tmpl_if page.newWindow>target=\"_blank\"</tmpl_if>\r\n   href=\"<tmpl_var page.url>\"><tmpl_var page.menuTitle></a>\r\n   <tmpl_unless \"__last__\"> &gt; </tmpl_unless>\r\n</tmpl_loop>\r\n</span>','Navigation',1,1,'PBtmpl0000000000000093');
INSERT INTO template VALUES ('\n		<tmpl_if displayTitle>\n		<h1><tmpl_var title></h1>\n		</tmpl_if>\n		<tmpl_if description>\n			<p><tmpl_var description></p>\n		</tmpl_if>\n		<tmpl_if session.var.adminOn>\r\n<tmpl_var controls><br>\r\n</tmpl_if>\r\n<span class=\"verticalMenu\">\r\n<tmpl_loop page_loop>\r\n<tmpl_var page.indent><a class=\"verticalMenu\" \r\n   <tmpl_if page.newWindow>target=\"_blank\"</tmpl_if> href=\"<tmpl_var page.url>\">\r\n   <tmpl_if page.isCurrent>\r\n      <span class=\"selectedMenuItem\"><tmpl_var page.menuTitle></span>\r\n   <tmpl_else><tmpl_var page.menuTitle></tmpl_if></a><br>\r\n</tmpl_loop>\r\n</span>','Navigation',1,1,'PBtmpl0000000000000048');
INSERT INTO template VALUES ('\n		<tmpl_if displayTitle>\n		<h1><tmpl_var title></h1>\n		</tmpl_if>\n		<tmpl_if description>\n			<p><tmpl_var description></p>\n		</tmpl_if>\n		<tmpl_if session.var.adminOn>\r\n<tmpl_var controls>\r\n</tmpl_if>\r\n<span class=\"horizontalMenu\">\r\n<tmpl_loop page_loop>\r\n<a class=\"horizontalMenu\" \r\n   <tmpl_if page.newWindow>target=\"_blank\"</tmpl_if>\r\n   href=\"<tmpl_var page.url>\"><tmpl_var page.menuTitle></a>\r\n   <tmpl_unless \"__last__\"> &middot; </tmpl_unless>\r\n</tmpl_loop>\r\n</span>','Navigation',1,1,'PBtmpl0000000000000108');
INSERT INTO template VALUES ('\n		<tmpl_if displayTitle>\n		<h1><tmpl_var title></h1>\n		</tmpl_if>\n		<tmpl_if description>\n			<p><tmpl_var description></p>\n		</tmpl_if>\n		<script language=\"JavaScript\" type=\"text/javascript\">\r\nfunction go(formObj){\r\n   if (formObj.chooser.options[formObj.chooser.selectedIndex].value != \"none\") {\r\n	location = formObj.chooser.options[formObj.chooser.selectedIndex].value\r\n   }\r\n}\r\n</script>\r\n<form>\r\n<tmpl_if session.var.adminOn>\r\n<tmpl_var controls>\r\n</tmpl_if>\r\n<select name=\"chooser\" size=1 onChange=\"go(this.form)\">\r\n<option value=none>Where do you want to go?</option>\r\n<tmpl_loop page_loop>\r\n<option value=\"<tmpl_var page.url>\"><tmpl_loop page.indent_loop>&nbsp;&nbsp;</tmpl_loop>- <tmpl_var page.menuTitle></option>\r\n</tmpl_loop>\r\n</select>\r\n</form>','Navigation',1,1,'PBtmpl0000000000000117');
INSERT INTO template VALUES ('\n		<tmpl_if displayTitle>\n		<h1><tmpl_var title></h1>\n		</tmpl_if>\n		<tmpl_if description>\n			<p><tmpl_var description></p>\n		</tmpl_if>\n		<tmpl_if session.var.adminOn>\r\n<tmpl_var controls>\r\n</tmpl_if>\r\n<tmpl_loop page_loop>\r\n   <tmpl_if page.isCurrent>\r\n      <span class=\"rootTabOn\">\r\n   <tmpl_else>\r\n      <span class=\"rootTabOff\">\r\n   </tmpl_if>\r\n   <a <tmpl_if page.newWindow>target=\"_blank\"</tmpl_if> href=\"<tmpl_var page.url>\"><tmpl_var page.menuTitle></a>\r\n   </span>\r\n</tmpl_loop>','Navigation',1,1,'PBtmpl0000000000000124');
INSERT INTO template VALUES ('\n		<tmpl_if displayTitle>\n		<h1><tmpl_var title></h1>\n		</tmpl_if>\n		<tmpl_if description>\n			<p><tmpl_var description></p>\n		</tmpl_if>\n		^StyleSheet(\"<tmpl_var session.config.extrasURL>/Navigation/dtree/dtree.css\");\r\n^JavaScript(\"<tmpl_var session.config.extrasURL>/Navigation/dtree/dtree.js\");\r\n\r\n<tmpl_if session.var.adminOn>\r\n<tmpl_var controls>\r\n</tmpl_if>\r\n\r\n<script>\r\n// Path to dtree directory\r\n_dtree_url = \"<tmpl_var session.config.extrasURL>/Navigation/dtree/\";\r\n</script>\r\n\r\n<div class=\"dtree\">\r\n<script type=\"text/javascript\">\r\n<!--\r\n	d = new dTree(\'d\');\r\n	<tmpl_loop page_loop>\r\n	d.add(\r\n		\'<tmpl_var page.assetId>\',\r\n		<tmpl_if __first__>-99<tmpl_else>\'<tmpl_var page.parentId>\'</tmpl_if>,\r\n		\'<tmpl_var page.menuTitle>\',\r\n		\'<tmpl_var page.url>\',\r\n		\'<tmpl_var page.synopsis>\'\r\n		<tmpl_if page.newWindow>,\'_blank\'</tmpl_if>\r\n	);\r\n	</tmpl_loop>\r\n	document.write(d);\r\n//-->\r\n</script>\r\n\r\n</div>','Navigation',1,1,'PBtmpl0000000000000130');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a> <tmpl_if session.var.adminOn> <p><tmpl_var controls></p> </tmpl_if><tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_if session.var.adminOn>\r\n    <a href=\"<tmpl_var addevent.url>\"><tmpl_var addevent.label></a>\r\n    <p />\r\n</tmpl_if>\r\n\r\n<tmpl_loop month_loop>\n	<table border=\"1\" width=\"100%\">\n	<tr><td colspan=7 class=\"tableHeader\"><h2 align=\"center\"><tmpl_var month> <tmpl_var year></h2></td></tr>\n	<tr>\n	<tmpl_if session.user.firstDayOfWeek>\n		<th class=\"tableData\"><tmpl_var monday.label></th>\n		<th class=\"tableData\"><tmpl_var tuesday.label></th>\n		<th class=\"tableData\"><tmpl_var wednesday.label></th>\n		<th class=\"tableData\"><tmpl_var thursday.label></th>\n		<th class=\"tableData\"><tmpl_var friday.label></th>\n		<th class=\"tableData\"><tmpl_var saturday.label></th>\n		<th class=\"tableData\"><tmpl_var sunday.label></th>\n	<tmpl_else>\n		<th class=\"tableData\"><tmpl_var sunday.label></th>\n		<th class=\"tableData\"><tmpl_var monday.label></th>\n		<th class=\"tableData\"><tmpl_var tuesday.label></th>\n		<th class=\"tableData\"><tmpl_var wednesday.label></th>\n		<th class=\"tableData\"><tmpl_var thursday.label></th>\n		<th class=\"tableData\"><tmpl_var friday.label></th>\n		<th class=\"tableData\"><tmpl_var saturday.label></th>\n	</tmpl_if>\n	</tr><tr>\n	<tmpl_loop prepad_loop>\n		<td>&nbsp;</td>\n	</tmpl_loop>\n 	<tmpl_loop day_loop>\n		<tmpl_if isStartOfWeek>\n			<tr>\n		</tmpl_if>\n		<td class=\"table<tmpl_if isToday>Header<tmpl_else>Data</tmpl_if>\" width=\"14%\" valign=\"top\" align=\"left\"><p><b><tmpl_var day></b></p>\n		<tmpl_loop event_loop>\n			<tmpl_if name>\n				&middot;<a href=\"<tmpl_var url>\"><tmpl_var name></a><br />\n			</tmpl_if>\n		</tmpl_loop>\n		</td>\n		<tmpl_if isEndOfWeek>\n			</tr>\n		</tmpl_if>\n	</tmpl_loop>\n	<tmpl_loop postpad_loop>\n		<td>&nbsp;</td>\n	</tmpl_loop>\n	</tr>\n	</table>\n</tmpl_loop>\n\n\n<tmpl_if pagination.pageCount.isMultiple>\n  <div class=\"pagination\">\n    <tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>\n  </div>\n</tmpl_if>\n','EventsCalendar',1,1,'PBtmpl0000000000000022');
INSERT INTO template VALUES ('\n		<tmpl_if displayTitle>\n		<h1><tmpl_var title></h1>\n		</tmpl_if>\n		<tmpl_if description>\n			<p><tmpl_var description></p>\n		</tmpl_if>\n		<tmpl_if session.var.adminOn>\r\n<tmpl_var controls>\r\n</tmpl_if>\r\n\r\n<style>\r\n/* CoolMenus 4 - default styles - do not edit */\r\n.cCMAbs{position:absolute; visibility:hidden; left:0; top:0}\r\n/* CoolMenus 4 - default styles - end */\r\n\r\n/*Styles for level 0*/\r\n.cLevel0,.cLevel0over{position:absolute; padding:2px; font-family:tahoma,arial,helvetica; font-size:12px; font-weight:bold;\r\n\r\n}\r\n.cLevel0{background-color:navy; layer-background-color:navy; color:white;\r\ntext-align: center;\r\n}\r\n.cLevel0over{background-color:navy; layer-background-color:navy; color:white; cursor:pointer; cursor:hand; \r\ntext-align: center; \r\n}\r\n\r\n.cLevel0border{position:absolute; visibility:hidden; background-color:#569635; layer-background-color:#006699; \r\n \r\n}\r\n\r\n\r\n/*Styles for level 1*/\r\n.cLevel1, .cLevel1over{position:absolute; padding:2px; font-family:tahoma, arial,helvetica; font-size:11px; font-weight:bold}\r\n.cLevel1{background-color:Navy; layer-background-color:Navy; color:white;}\r\n.cLevel1over{background-color:#336699; layer-background-color:#336699; color:Yellow; cursor:pointer; cursor:hand; }\r\n.cLevel1border{position:absolute; visibility:hidden; background-color:#006699; layer-background-color:#006699}\r\n\r\n/*Styles for level 2*/\r\n.cLevel2, .cLevel2over{position:absolute; padding:2px; font-family:tahoma,arial,helvetica; font-size:10px; font-weight:bold}\r\n.cLevel2{background-color:Navy; layer-background-color:Navy; color:white;}\r\n.cLevel2over{background-color:#0099cc; layer-background-color:#0099cc; color:Yellow; cursor:pointer; cursor:hand; }\r\n.cLevel2border{position:absolute; visibility:hidden; background-color:#006699; layer-background-color:#006699}\r\n\r\n</style>\r\n\r\n  \r\n\r\n^JavaScript(\"<tmpl_var session.config.extrasURL>/coolmenus/coolmenus4.js\");\r\n<script language=\"JavaScript\">\r\n/*****************************************************************************\r\nCopyright (c) 2001 Thomas Brattli (webmaster@dhtmlcentral.com)\r\n\r\nDHTML coolMenus - Get it at coolmenus.dhtmlcentral.com\r\nVersion 4.0_beta\r\nThis script can be used freely as long as all copyright messages are\r\nintact.\r\n\r\nExtra info - Coolmenus reference/help - Extra links to help files **** \r\nCSS help: http://coolmenus.dhtmlcentral.com/projects/coolmenus/reference.asp?m=37\r\nGeneral: http://coolmenus.dhtmlcentral.com/reference.asp?m=35\r\nMenu properties: http://coolmenus.dhtmlcentral.com/properties.asp?m=47\r\nLevel properties: http://coolmenus.dhtmlcentral.com/properties.asp?m=48\r\n\r\nBackground bar properties: http://coolmenus.dhtmlcentral.com/properties.asp?m=49\r\nItem properties: http://coolmenus.dhtmlcentral.com/properties.asp?m=50\r\n******************************************************************************/\r\n\r\n/*** \r\nThis is the menu creation code - place it right after you body tag\r\nFeel free to add this to a stand-alone js file and link it to your page.\r\n**/\r\n\r\n//Menu object creation\r\ncoolmenu=new makeCM(\"coolmenu\") //Making the menu object. Argument: menuname\r\n\r\ncoolmenu.frames = 0\r\n\r\n//Menu properties   \r\ncoolmenu.onlineRoot=\"\"\ncoolmenu.pxBetween=2\r\ncoolmenu.fromLeft=200 \r\ncoolmenu.fromTop=100   \r\ncoolmenu.rows=1\r\ncoolmenu.menuPlacement=\"center\"   //The whole menu alignment, left, center, or right\r\n                                                             \r\ncoolmenu.resizeCheck=1 \r\ncoolmenu.wait=1000 \r\ncoolmenu.fillImg=\"cm_fill.gif\"\r\ncoolmenu.zIndex=100\r\n\r\n//Background bar properties\r\ncoolmenu.useBar=0\r\ncoolmenu.barWidth=\"100%\"\r\ncoolmenu.barHeight=\"menu\" \r\ncoolmenu.barClass=\"cBar\"\r\ncoolmenu.barX=0 \r\ncoolmenu.barY=0\r\ncoolmenu.barBorderX=0\r\ncoolmenu.barBorderY=0\r\ncoolmenu.barBorderClass=\"\"\r\n\r\n//Level properties - ALL properties have to be spesified in level 0\r\ncoolmenu.level[0]=new cm_makeLevel() //Add this for each new level\r\ncoolmenu.level[0].width=110\r\ncoolmenu.level[0].height=21 \r\ncoolmenu.level[0].regClass=\"cLevel0\"\r\ncoolmenu.level[0].overClass=\"cLevel0over\"\r\ncoolmenu.level[0].borderX=1\r\ncoolmenu.level[0].borderY=1\r\ncoolmenu.level[0].borderClass=\"cLevel0border\"\r\ncoolmenu.level[0].offsetX=0\r\ncoolmenu.level[0].offsetY=0\r\ncoolmenu.level[0].rows=0\r\ncoolmenu.level[0].arrow=0\r\ncoolmenu.level[0].arrowWidth=0\r\ncoolmenu.level[0].arrowHeight=0\r\ncoolmenu.level[0].align=\"bottom\"\r\n\r\n//EXAMPLE SUB LEVEL[1] PROPERTIES - You have to specify the properties you want different from LEVEL[0] - If you want all items to look the same just remove this\r\ncoolmenu.level[1]=new cm_makeLevel() //Add this for each new level (adding one to the number)\r\ncoolmenu.level[1].width=coolmenu.level[0].width+20\r\ncoolmenu.level[1].height=25\r\ncoolmenu.level[1].regClass=\"cLevel1\"\r\ncoolmenu.level[1].overClass=\"cLevel1over\"\r\ncoolmenu.level[1].borderX=1\r\ncoolmenu.level[1].borderY=1\r\ncoolmenu.level[1].align=\"right\" \r\ncoolmenu.level[1].offsetX=0\r\ncoolmenu.level[1].offsetY=0\r\ncoolmenu.level[1].borderClass=\"cLevel1border\"\r\n\r\n\r\n//EXAMPLE SUB LEVEL[2] PROPERTIES - You have to spesify the properties you want different from LEVEL[1] OR LEVEL[0] - If you want all items to look the same just remove this\r\ncoolmenu.level[2]=new cm_makeLevel() //Add this for each new level (adding one to the number)\r\ncoolmenu.level[2].width=coolmenu.level[0].width+20\r\ncoolmenu.level[2].height=25\r\ncoolmenu.level[2].offsetX=0\r\ncoolmenu.level[2].offsetY=0\r\ncoolmenu.level[2].regClass=\"cLevel2\"\r\ncoolmenu.level[2].overClass=\"cLevel2over\"\r\ncoolmenu.level[2].borderClass=\"cLevel2border\"\r\n\r\n//EXAMPLE SUB LEVEL[2] PROPERTIES - You have to spesify the properties you want different from LEVEL[1] OR LEVEL[0] - If you want all items to look the same just remove this\r\ncoolmenu.level[3]=new cm_makeLevel() //Add this for each new level (adding one to the number)\r\ncoolmenu.level[3].width=coolmenu.level[0].width+20\r\ncoolmenu.level[3].height=25\r\ncoolmenu.level[3].offsetX=0\r\ncoolmenu.level[3].offsetY=0\r\ncoolmenu.level[3].regClass=\"cLevel2\"\r\ncoolmenu.level[3].overClass=\"cLevel2over\"\r\ncoolmenu.level[3].borderClass=\"cLevel2border\"\r\n\r\n\r\n\r\n<tmpl_loop page_loop>\r\ncoolmenu.makeMenu(\'coolmenu_<tmpl_var page.assetId>\'.replace(/\\-/g,\"a\"),\'coolmenu_<tmpl_var page.parent.assetId>\'.replace(/\\-/g,\"a\"),\"<tmpl_var page.menuTitle>\",\'<tmpl_var page.url>\'<tmpl_if page.newWindow>,\'_blank\'</tmpl_if>);\r\n</tmpl_loop>\r\n\r\n\r\ncoolmenu.construct();\r\n\r\n</script>','Navigation',1,1,'PBtmpl0000000000000134');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a>\n<tmpl_if session.var.adminOn>\n	<p><tmpl_var controls></p>\n</tmpl_if>	\n		<a name=\"<tmpl_var assetId>\"></a>\r\n<tmpl_if session.var.adminOn>\r\n	<p><tmpl_var controls></p>\r\n</tmpl_if>	\r\n		<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<table class=\"tableMenu\" width=\"100%\">\r\n  <tbody>\r\n    <tr>\r\n      <td align=\"center\" width=\"15%\">\r\n      <h1><tmpl_var int.search></h1>\r\n      </td>\r\n      <td vAlign=\"top\" align=\"middle\">\r\n      <table>\r\n      <form method=\"post\" action=\"<tmpl_var actionURL>\">\r\n      <tbody>\r\n      <tr>\r\n	<td colspan=\"2\" class=\"tableData\">\r\n	   <input maxLength=\"255\" size=\"30\" value=\'<tmpl_var query>\' name=\"query\">\r\n	</td>\r\n	<td class=\"tableData\"><tmpl_var submit></td>\r\n      </tr>\r\n      <tr>\r\n	<td class=\"tableData\" valign=\"top\">\r\n\r\n	</td>\r\n	<td class=\"tableData\" valign=\"top\">\r\n	   <tmpl_loop contentTypesSimple>\r\n	     <tmpl_unless __FIRST__>\r\n	     	<input type=\"checkbox\" name=\"contentTypes\" value=\"<tmpl_var value>\"\r\n		<tmpl_if type_content>\r\n		   <tmpl_if query>\r\n			<tmpl_if selected>\r\n			   checked=\"1\"\r\n			</tmpl_if>\r\n		   <tmpl_else>\r\n			checked=\"1\"\r\n		   </tmpl_if>\r\n		<tmpl_else>\r\n		   <tmpl_if selected>checked=\"1\"</tmpl_if>\r\n		</tmpl_if>\r\n		><tmpl_var name>\r\n                <br>\r\n	     </tmpl_unless>\r\n	   </tmpl_loop>\r\n	</td>\r\n        <td></td>\r\n      </tbody>\r\n      </form>\r\n      </table>\r\n      </td>      \r\n    </tr>\r\n  </tbody>\r\n</table>\r\n\r\n<p/>\r\n<tmpl_if numberOfResults>\r\n   <p>Results <tmpl_var startNr> - <tmpl_var endNr> of about <tmpl_var numberOfResults> \r\n   containing <b>\"<tmpl_var queryHighlighted>\"</b>. Search took <b><tmpl_var duration></b> seconds.</p>\r\n   <ol style=\"Margin-Top: 0px; Margin-Bottom: 0px;\" start=\"<tmpl_var startNr>\">\r\n   <tmpl_loop resultsLoop>\r\n      <li>\r\n	   <a href=\"<tmpl_var location>\">\r\n	      <tmpl_if header><tmpl_var header><tmpl_else>No Title</tmpl_if></a>\r\n	   <div>\r\n	      <tmpl_if \"body\">\r\n		   <span class=\"preview\"><tmpl_var \"body\"></span><br/>\r\n	      </tmpl_if>\r\n	      <span style=\"color:#666666;\">Location: <tmpl_var crumbTrail></span>\r\n	      <br/>\r\n	      <br/>\r\n	   </div>\r\n      </li>\r\n   </tmpl_loop>\r\n   </ol>\r\n</tmpl_if> \r\n\r\n\r\n<tmpl_if pagination.pageCount.isMultiple>\r\n  <div class=\"pagination\">\r\n    <tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>\r\n  </div>\r\n</tmpl_if>\r\n','IndexedSearch',1,1,'PBtmpl0000000000000034');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a> <tmpl_if session.var.adminOn> <p><tmpl_var controls></p> </tmpl_if><tmpl_if displayTitle>\n    <h1><tmpl_var title></h1>\n</tmpl_if>\n\n<tmpl_if description>\n    <tmpl_var description><p />\n</tmpl_if>\n\n<tmpl_if session.scratch.search>\n \n</tmpl_if>\n\n<table width=\"100%\" cellpadding=2 cellspacing=1 border=0><tr>\n<td align=\"right\" class=\"tableMenu\">\n\n<tmpl_if user.canPost>\n   <a href=\"<tmpl_var add.url>\">Add a job.</a> &middot;\n</tmpl_if>\n\n<a href=\"<tmpl_var search.url>\"><tmpl_var search.label></a>\n\n</td></tr></table>\n\n<table width=\"100%\" cellspacing=1 cellpadding=2 border=0>\n<tr>\n<td class=\"tableHeader\">Job Title</td>\n<td class=\"tableHeader\">Location</td>\n<td class=\"tableHeader\">Compensation</td>\n<td class=\"tableHeader\">Date Posted</td>\n</tr>\n\n<tmpl_loop post_loop>\n\n<tr>\n<td class=\"tableData\">\n     <a href=\"<tmpl_var URL>\">  <tmpl_var title>\n</td>\n<td class=\"tableData\"><tmpl_var userDefined2></td>\n<td class=\"tableData\"><tmpl_var userDefined1></td>\n<td class=\"tableData\"><tmpl_var dateSubmitted.human></td>\n</tr>\n\n</tmpl_loop>\n\n</table>\n\n<tmpl_if pagination.pageCount.isMultiple>\n  <div class=\"pagination\">\n    <tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>\n  </div>\n</tmpl_if>\n','Collaboration',1,1,'PBtmpl0000000000000077');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a> <tmpl_if session.var.adminOn> <p><tmpl_var controls></p> </tmpl_if><h1><tmpl_var title></h1>\n\n<tmpl_if content>\n<p>\n<b>Job Description</b><br />\n<tmpl_var content>\n</p>\n</tmpl_if>\n\n<tmpl_if userDefined3.value>\n<p>\n<b>Job Requirements</b><br />\n<tmpl_var userDefined3.value>\n</p>\n</tmpl_if>\n\n<table>\n<tr>\n  <td class=\"tableHeader\">Date Posted</td>\n  <td class=\"tableData\"><tmpl_var dateSubmitted.human></td>\n</tr>\n<tr>\n  <td  class=\"tableHeader\">Location</td>\n  <td class=\"tableData\"><tmpl_var userDefined2.value></td>\n</tr>\n<tr>\n  <td  class=\"tableHeader\">Compensation</td>\n  <td class=\"tableData\"><tmpl_var userDefined1.value></td>\n</tr>\n<tr>\n  <td  class=\"tableHeader\">Views</td>\n  <td class=\"tableData\"><tmpl_var views></td>\n</tr>\n</table>\n\n<p>\n<tmpl_if previous.url>\n   <a href=\"<tmpl_var previous.url>\">&laquo; Previous Job</a> &middot;\n</tmpl_if>\n<a href=\"<tmpl_var collaboration.url>\">List All Jobs</a>\n<tmpl_if next.url>\n   &middot; <a href=\"<tmpl_var next.url>\">Next Job &raquo;</a>\n</tmpl_if>\n</p>\n\n\n<tmpl_if canEdit>\n<p>\n   <a href=\"<tmpl_var edit.url>\">Edit</a>\n   &middot;\n   <a href=\"<tmpl_var delete.url>\"><tmpl_var delete.label></a>\n</p>\n</tmpl_if>\n\n<tmpl_if canChangeStatus>\n <p>\n<b>Status:</b> <tmpl_var status> ||\n   <a href=\"<tmpl_var approve.url>\"><tmpl_var approve.label></a>\n   &middot;\n   <a href=\"<tmpl_var deny.url>\"><tmpl_var deny.label></a>\n </p>\n</tmpl_if>\n\n\n\n','Collaboration/Thread',1,1,'PBtmpl0000000000000098');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a> <tmpl_if session.var.adminOn> <p><tmpl_var controls></p> </tmpl_if><h1>Edit Job Posting</h1>\n\n<tmpl_var form.header>\n<input type=\"hidden\" name=\"contentType\" value=\"html\" />\n	<table>\n	<tmpl_if user.isVisitor> <tmpl_if isNewPost>\n		<tr><td><tmpl_var visitorName.label></td><td><tmpl_var visitorName.form></td></tr>\n	</tmpl_if> </tmpl_if>\n	<tr><td>Job Title</td><td><tmpl_var title.form></td></tr>\n	<tr><td>Job Description</td><td><tmpl_var content.form></td></tr>\n	<tr><td>Job Requirements</td><td><tmpl_var userDefined3.form.htmlarea></td></tr>\n	<tr><td>Compensation</td><td><tmpl_var userDefined1.form></td></tr>\n	<tr><td>Location</td><td><tmpl_var userDefined2.form></td></tr>\n	<tr><td></td><td><tmpl_var form.submit></td></tr>\n	</table>\n<tmpl_var form.footer>\n','Collaboration/PostForm',1,1,'PBtmpl0000000000000122');
INSERT INTO template VALUES ('\n		<tmpl_if displayTitle>\n		<h1><tmpl_var title></h1>\n		</tmpl_if>\n		<tmpl_if description>\n			<p><tmpl_var description></p>\n		</tmpl_if>\n		<tmpl_if session.var.adminOn>\n<tmpl_var controls>\n</tmpl_if>\n<div class=\"synopsis\">\r\n<tmpl_loop page_loop>\r\n   <div class=\"synopsis_title\">\r\n      <a href=\"<tmpl_var page.url>\"><tmpl_var page.menuTitle></a>\r\n   </div>\r\n   <tmpl_if page.indent>\r\n      <div class=\"synopsis_sub\">\r\n         <tmpl_var page.synopsis>\r\n      </div>\r\n   <tmpl_else>\r\n      <div class=\"synopsis_summary\">\r\n         <tmpl_var page.synopsis>\r\n      </div>\r\n   </tmpl_if>\r\n</tmpl_loop>\r\n</div>','Navigation',1,1,'PBtmpl0000000000000136');
INSERT INTO template VALUES ('<h1>\n   <tmpl_var title>\n</h1>\n\n<tmpl_if login.message>\r\n   <tmpl_var login.message>\r\n</tmpl_if>\r\n\r\n<tmpl_var login.form.header>\r\n<table >\r\n<tmpl_var login.form.hidden>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var login.form.username.label></td>\r\n   <td class=\"tableData\"><tmpl_var login.form.username></td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var login.form.password.label></td>\r\n   <td class=\"tableData\"><tmpl_var login.form.password></td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"></td>\r\n   <td class=\"tableData\"><tmpl_var login.form.submit></td>\r\n</tr>\r\n</table>\r\n<tmpl_var login.form.footer>\r\n\r\n<div class=\"accountOptions\">\r\n   <ul>\n     <tmpl_if recoverPassword.isAllowed>\n	     <li><a href=\"<tmpl_var recoverPassword.url>\"><tmpl_var recoverPassword.label></a></li>\n	  </tmpl_if>\n           <tmpl_if anonymousRegistration.isAllowed>\n	     <li><a href=\"<tmpl_var createAccount.url>\"><tmpl_var createAccount.label></a></li>\n	  </tmpl_if>\r\n   </ul>\r\n</div>','Auth/WebGUI/Login',1,1,'PBtmpl0000000000000013');
INSERT INTO template VALUES ('<h1>\n   <tmpl_var title>\n</h1>\n\n\n<tmpl_if account.message>\r\n   <tmpl_var account.message>\r\n</tmpl_if>\r\n\r\n<tmpl_var account.form.header>\r\n<table >\r\n\n<tmpl_if account.form.karma>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var account.form.karma.label></td>\r\n   <td class=\"tableData\"><tmpl_var account.form.karma></td>\r\n</tr>\r\n</tmpl_if>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var account.form.username.label></td>\r\n   <td class=\"tableData\"><tmpl_var account.form.username></td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var account.form.password.label></td>\r\n   <td class=\"tableData\"><tmpl_var account.form.password></td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var account.form.passwordConfirm.label></td>\r\n   <td class=\"tableData\"><tmpl_var account.form.passwordConfirm></td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"></td>\r\n   <td class=\"tableData\"><tmpl_var account.form.submit></td>\r\n</tr>\r\n</table>\r\n<tmpl_var account.form.footer>\r\n\r\n<div class=\"accountOptions\">\r\n   <ul>\r\n      <tmpl_loop account.options>\r\n         <li><tmpl_var options.display>\r\n      </tmpl_loop>\r\n   </ul>\r\n</div>','Auth/WebGUI/Account',1,1,'PBtmpl0000000000000010');
INSERT INTO template VALUES ('   <h1><tmpl_var title></h1>\r\n\r\n<tmpl_if create.message>\r\n   <tmpl_var create.message>\r\n</tmpl_if>\r\n\r\n<tmpl_var create.form.header>\r\n<table >\r\n<tmpl_if useCaptcha>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var create.form.captcha.label></td>\r\n   <td class=\"tableData\"><tmpl_var create.form.captcha></td>\r\n</tr>\r\n</tmpl_if>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var create.form.username.label></td>\r\n   <td class=\"tableData\"><tmpl_var create.form.username></td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var create.form.password.label></td>\r\n   <td class=\"tableData\"><tmpl_var create.form.password></td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var create.form.passwordConfirm.label></td>\r\n   <td class=\"tableData\"><tmpl_var create.form.passwordConfirm></td>\r\n</tr>\r\n<tmpl_loop create.form.profile>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var profile.formElement.label></td>\r\n   <td class=\"tableData\"><tmpl_var profile.formElement></td>\r\n</tr>\r\n</tmpl_loop>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"></td>\r\n   <td class=\"tableData\"><tmpl_var create.form.submit></td>\r\n</tr>\r\n</table>\r\n<tmpl_var create.form.footer>\r\n\r\n<div class=\"accountOptions\">\r\n   <ul>\r\n      <li><a href=\"<tmpl_var login.url>\"><tmpl_var login.label></a></li>\r\n      <tmpl_if recoverPassword.isAllowed>\r\n	     <li><a href=\"<tmpl_var recoverPassword.url>\"><tmpl_var recoverPassword.label></a></li>\r\n	  </tmpl_if>\r\n   </ul>\r\n</div>','Auth/WebGUI/Create',1,1,'PBtmpl0000000000000011');
INSERT INTO template VALUES ('<h1>\n   <tmpl_var title>\n</h1>\n\r\n\r\n<tmpl_if recover.message>\r\n   <tmpl_var recover.message>\r\n</tmpl_if>\r\n\r\n<tmpl_var recover.form.header>\r\n<table >\r\n<tmpl_var recover.form.hidden>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var recover.form.email.label></td>\r\n   <td class=\"tableData\"><tmpl_var recover.form.email></td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"></td>\r\n   <td class=\"tableData\"><tmpl_var recover.form.submit></td>\r\n</tr>\r\n</table>\r\n<tmpl_var recover.form.footer>\r\n\r\n\r\n<div class=\"accountOptions\">\r\n   <ul>\n       <tmpl_if anonymousRegistration.isAllowed>\n	     <li><a href=\"<tmpl_var createAccount.url>\"><tmpl_var createAccount.label></a></li>\n	  </tmpl_if>\n         <li><a href=\"<tmpl_var login.url>\"><tmpl_var login.label></a></li>\n      \r\n   </ul>\r\n</div>','Auth/WebGUI/Recovery',1,1,'PBtmpl0000000000000014');
INSERT INTO template VALUES ('<h1>\n   <tmpl_var title>\n</h1>\n\r\n<tmpl_if expired.message>\r\n   <tmpl_var expired.message>\r\n</tmpl_if>\r\n\r\n<tmpl_var expired.form.header>\r\n<table >\r\n<tmpl_var expired.form.hidden>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\">\r\n      <tmpl_var expired.form.oldPassword.label>\r\n   </td>\r\n   <td class=\"tableData\">\r\n      <tmpl_var expired.form.oldPassword>\r\n   </td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\">\r\n      <tmpl_var expired.form.password.label>\r\n   </td>\r\n   <td class=\"tableData\">\r\n      <tmpl_var expired.form.password>\r\n   </td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\">\r\n  <tmpl_var expired.form.passwordConfirm.label>\r\n   </td>\r\n   <td class=\"tableData\">\r\n   <tmpl_var expired.form.passwordConfirm>\r\n   </td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"></td>\r\n   <td class=\"tableData\">\r\n   <tmpl_var expired.form.submit>\r\n   </td>\r\n</tr>\r\n</table>\r\n<tmpl_var expired.form.footer>','Auth/WebGUI/Expired',1,1,'PBtmpl0000000000000012');
INSERT INTO template VALUES ('<h1>\n   <tmpl_var title>\n</h1>\r\n<tmpl_if login.message>\r\n   <tmpl_var login.message>\r\n</tmpl_if>\r\n\r\n<tmpl_var login.form.header>\r\n<table >\r\n<tmpl_var login.form.hidden>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var login.form.username.label></td>\r\n   <td class=\"tableData\"><tmpl_var login.form.username></td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var login.form.password.label></td>\r\n   <td class=\"tableData\"><tmpl_var login.form.password></td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"></td>\r\n   <td class=\"tableData\"><tmpl_var login.form.submit></td>\r\n</tr>\r\n</table>\r\n<tmpl_var login.form.footer>\r\n\r\n<div class=\"accountOptions\">\r\n   <ul>\r\n             <tmpl_if anonymousRegistration.isAllowed>\n	     <li><a href=\"<tmpl_var createAccount.url>\"><tmpl_var createAccount.label></a></li>\n	  </tmpl_if>\n\n   </ul>\r\n</div>','Auth/LDAP/Login',1,1,'PBtmpl0000000000000006');
INSERT INTO template VALUES ('<h1>\n   <tmpl_var title>\n</h1>\n\n\r\n<tmpl_var account.message>\r\n<tmpl_if account.form.karma>\r\n<br><br>\r\n<table>\r\n<tr>\r\n  <td class=\"formDescription\">\r\n      <tmpl_var account.form.karma.label>\r\n  </td>\r\n  <td class=\"tableData\">\r\n       <tmpl_var account.form.karma>\r\n  </td>\r\n</tr>\r\n</table>\r\n</tmpl_if>\r\n\r\n<div class=\"accountOptions\">\r\n   <ul>\r\n      <tmpl_loop account.options>\r\n         <li><tmpl_var options.display>\r\n      </tmpl_loop>\r\n   </ul>\r\n</div>','Auth/LDAP/Account',1,1,'PBtmpl0000000000000004');
INSERT INTO template VALUES ('<h1>\n   <tmpl_var title>\r\n</h1>\n<tmpl_if create.message>\r\n   <tmpl_var create.message>\r\n</tmpl_if>\r\n\r\n<tmpl_var create.form.header>\r\n<table >\r\n<tmpl_var create.form.hidden>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var create.form.ldapId.label></td>\r\n   <td class=\"tableData\"><tmpl_var create.form.ldapId></td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var create.form.password.label></td>\r\n   <td class=\"tableData\"><tmpl_var create.form.password></td>\r\n</tr>\r\n<tmpl_loop create.form.profile>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var profile.formElement.label></td>\r\n   <td class=\"tableData\"><tmpl_var profile.formElement></td>\r\n</tr>\r\n</tmpl_loop>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"></td>\r\n   <td class=\"tableData\"><tmpl_var create.form.submit></td>\r\n</tr>\r\n</table>\r\n<tmpl_var create.form.footer>\r\n\r\n\r\n<div class=\"accountOptions\">\r\n   <ul>\n     <li><a href=\"<tmpl_var login.url>\"><tmpl_var login.label></a></li>\n \n  </ul>\r\n</div>','Auth/LDAP/Create',1,1,'PBtmpl0000000000000005');
INSERT INTO template VALUES ('<h1><tmpl_var title></h1>\n\n<p>\n<tmpl_var question>\n</p>\n\n<div align=\"center\">\n\n<a href=\"<tmpl_var yes.url>\"><tmpl_var yes.label></a>\n\n&nbsp;  &nbsp; &nbsp; &nbsp; &nbsp; \n\n<a href=\"<tmpl_var no.url>\"><tmpl_var no.label></a>\n\n</div>\n','prompt',1,1,'PBtmpl0000000000000057');
INSERT INTO template VALUES ('<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"\n        \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n<html xmlns=\"http://www.w3.org/1999/xhtml\">\n        <head>\n                <title>^Page(\"title\"); - WebGUI</title>\n				<tmpl_var head.tags>\n                <style type=\"text/css\">\n			.menu {\n				position: absolute;\n				top: 50px;\n				left: 5px;\n                                z-index: 10;\n				font-family: georgia, verdana, helvetica, arial, sans-serif;\n                                color: white;\n				font-size: 11px;\n				}\n			.content {\n				position: absolute;\n				top: 50px;\n				left: 195px;\n                                z-index: 10;\n                                font-family: georgia, verdana, helvetica, arial, sans-serif;\n                                color: white;\n				font-size: 13px;\n                                }\n                        .header {\n				position: absolute;\n				left: 5px;\n				top: 5px;\n                                z-index: 10;\n                                font-size: 30px;\n                                font-family: georgia, verdana, helvetica, arial, sans-serif;\n                                color: white;\n                                }\n			.background {\n				position: absolute; \n				top: 0; \n				left: 0; \n				width: 100%; \n				height: 100%; \n				z-index: 5;\n				border: 0px;\n				}\n			body {\n				background-color: #6974DE;\n				}\n				</style>\n        </head>\n        <body>	\n			^AdminBar;\n			<div class=\"header\">^PageTitle;</div>\n			<div class=\"menu\">^AssetProxy(flexMenu);</div>\n			<div class=\"content\"><tmpl_var body.content>\n			<hr />\n			^LoginToggle; &nbsp; ^a(^@;); &nbsp; ^AdminToggle;\n			</div>\n			<img src=\"<tmpl_var session.config.extrasURL>/background.jpg\" border=\"0\" class=\"background\" />\n		</body>\n</html>\n','style',0,0,'PBtmpl0000000000000060');
INSERT INTO template VALUES ('<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n		<html>\n		<head>\n			<title>^Page(title); - <tmpl_var session.setting.companyName></title>\n				\n	<link rel=\"icon\" href=\"^Extras;favicon.png\" type=\"image/png\" />\n	<link rel=\"SHORTCUT ICON\" href=\"^Extras;favicon.ico\" />\n	<tmpl_var head.tags>\n	\n		<style>\r\n\r\ninput:focus, textarea:focus {\r\n background-color: #D5E0E1;\r\n}\r\n\r\ninput, textarea, select {\r\n -moz-border-radius: 6px;\r\n background-color: #B9CDCF;\r\n border: ridge;\r\n}\r\n\r\n\r\n.content{\r\n	color: #000000;\r\n	font-family: Arial, Helvetica, sans-serif;\r\n	font-size: 10pt;\r\n	padding: 5px;\r\n}\r\n\r\nbody{\r\n	color: Black;\r\n	font-family: Arial, Helvetica, sans-serif;\r\n	font-size: 10pt;\r\n	padding: 0px;\r\n	background-position: top;\r\n	background-repeat: repeat-x;\r\n}\r\n\r\na {\r\n	color:#EC4300;\r\n	font-family: Arial, Helvetica, sans-serif;\r\n	font-weight: bold;\r\n	text-decoration: underline;\r\n}\r\n\r\na:hover{\r\n	color:#EC4300; \r\n	font-family: Arial, Helvetica, sans-serif;\r\n	font-weight: bold;\r\n	text-decoration: none;\r\n}\r\n\r\n.adminBar {\r\n  background-color: #CCCCCC;\r\n  font-family: helvetica, arial;\r\n}\r\n\r\n.tableMenu {\r\n  background-color: #CCCCCC;\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.tableMenu a {\r\n  font-size: 10pt;\r\n  text-decoration: none;\r\n}\r\n\r\n.tableHeader {\r\n  background-color: #CECECE;\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.tableData {\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n\r\n.pagination {\r\n  font-family: helvetica, arial;\r\n  font-size: 8pt;\r\n  text-align: center;\r\n}\r\n\r\n\r\nh1 {\r\n	font-size: 14pt;\r\n	font-family: helvetica, arial;\r\n	color: #EC4300;\r\n}\r\n\r\n.tab {\r\n  -moz-border-radius: 6px 6px 0px 0px;\r\n border: 1px solid black;\r\n   background-color: #eeeeee;\r\n}\r\n.tabBody {\r\n   border: 1px solid black;\r\n   border-top: 1px solid black;\r\n   border-left: 1px solid black;\r\n   background-color: #dddddd; \r\n}\r\ndiv.tabs {\r\n    line-height: 15px;\r\n    font-size: 14px;\r\n}\r\n.tabHover {\r\n   background-color: #cccccc;\r\n}\r\n.tabActive { \r\n   background-color: #dddddd; \r\n}\r\n\r\n</style>\r\n		\r\n\r\n\r\n\n		</head>\n				<body bgcolor=\"#D5E0E1\" leftmargin=\"0\" topmargin=\"0\" rightmargin=\"0\" bottommargin=\"0\" marginwidth=\"0\" marginheight=\"0\">\r\n\r\n^AdminBar(\"PBtmpl0000000000000090\");<br /> <br />\r\n\r\n<div class=\"content\" style=\"padding: 10px;\">\r\n  \n			<tmpl_var body.content>\n		\r\n</div>\r\n\r\n\r\n<div width=\"100%\" style=\"color: white; padding: 3px; background-color: black; text-align: center;\">^H; / ^PageTitle; / ^AdminToggle; / ^LoginToggle; / ^a;</div>\r\n</body>\r\n\r\n\r\n\r\n\r\n\r\n\n		</html>\n		','style',1,1,'9tBSOV44a9JPS8CcerOvYw');
INSERT INTO template VALUES ('<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n		<html>\n		<head>\n			<title>^Page(title); - <tmpl_var session.setting.companyName></title>\n				\n	<link rel=\"icon\" href=\"^Extras;favicon.png\" type=\"image/png\" />\n	<link rel=\"SHORTCUT ICON\" href=\"^Extras;favicon.ico\" />\n	<tmpl_var head.tags>\n	\n		<style>\r\n\r\n.nav,  A.nav:hover, .verticalMenu {\r\n font-size: 10px;\r\n text-decoration: none;\r\n}\r\n\r\n.pageTitle, .pageTitle A {\r\n  font-size: 30px;\r\n}\r\n\r\ninput:focus, textarea:focus {\r\n background-color: #D5E0E1;\r\n}\r\n\r\ninput, textarea, select {\r\n -moz-border-radius: 6px;\r\n background-color: #B9CDCF;\r\n border: ridge;\r\n}\r\n\r\n.wgBoxTop{\r\n	background-image: url(\"^Extras;/styles/webgui6/hdr_bg_corner_right.jpg\");\r\n        width: 195px;\r\n        height: 93px;\r\n}\r\n.wgBoxBottom{\r\n	background-image: url(\"^Extras;/styles/webgui6/content_bg_clouds.jpg\");\r\n	padding-bottom: 21px;\r\n        width: 529px;\r\n        height: 88px;\r\n}\r\n.logo {\r\n	background-image: url(\"^Extras;/styles/webgui6/hdr_bg_corner_left.jpg\");\r\n	background-color: #F4F4F4;\r\n	width: 195px;\r\n        height: 93px;\r\n        padding-bottom: 25px;\r\n}\r\n.login {\r\n        width: 334px;\r\n        height: 93px;\r\n	background-image: url(\"^Extras;/styles/webgui6/hdr_bg_center.jpg\");\r\n	background-color: #C1D6D8;\r\n        padding-top: 5px;\r\n	font-family: Arial, Helvetica, sans-serif;\r\n	font-size: 10px;\r\n	font-weight: bold;\r\n	color: #EC4300;\r\n}\n  input.loginBoxField { \n font-size: 10px;\n background-color: white;\n }\n .loginBox {\n font-size: 10px;\n }\n input.loginBoxButton {\n font-size: 10px;\n }  \r\n.iconBox{\r\n	background-image: url(\"^Extras;/styles/webgui6/content_bg_corner_left_top.jpg\");\r\n        width: 195px;\r\n        height: 88px;\r\n        vertical-align: bottom;\r\n        text-align: center;\r\n}\r\n.dateLeft {\r\n	background-image: url(\"^Extras;/styles/webgui6/date_bg_left.jpg\");	\r\n     width: 53px;\r\n     height: 59px;\r\n}\r\n\r\n.dateRight {\r\n     width: 53px;\r\n     height: 59px;\r\n	background-image: url(\"^Extras;/styles/webgui6/date_right_bg.jpg\");	\r\n}\r\n\r\n.date {\r\n	color: #393C3C;\r\n	font-family: Arial, Helvetica, sans-serif;\r\n	font-size: 11px;\r\n	font-weight: bold;\r\n}\r\n\r\n.contentbgLeft {\r\n	background-image: url(\"^Extras;/styles/webgui6/content_bg_left.jpg\");	\r\n    width: 53px;\r\n	\r\n}\r\n.contentbgRight {\r\n	background-image: url(\"^Extras;/styles/webgui6/content_bg_right.jpg\");	\r\n	\r\n}\r\n\r\n\r\n.content{\r\n	color: #000000;\r\n	font-family: Arial, Helvetica, sans-serif;\r\n	font-size: 10pt;\r\n	padding: 5px;\r\n}\r\n\r\nbody{\r\n	color: Black;\r\n	font-family: Arial, Helvetica, sans-serif;\r\n	font-size: 10pt;\r\n	padding: 0px;\r\n        background-image: url(\"^Extras;/styles/webgui6/bg.gif\");\r\n	background-position: top;\r\n	background-repeat: repeat-x;\r\n}\r\n\r\na {\r\n	color:#EC4300;\r\n	font-family: Arial, Helvetica, sans-serif;\r\n	font-weight: bold;\r\n	text-decoration: underline;\r\n}\r\n\r\na:hover{\r\n	color:#EC4300; \r\n	font-family: Arial, Helvetica, sans-serif;\r\n	font-weight: bold;\r\n	text-decoration: none;\r\n}\r\n\r\n.adminBar {\r\n  background-color: #CCCCCC;\r\n  font-family: helvetica, arial;\r\n}\r\n.tableMenu {\r\n  background-color: #CCCCCC;\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n.tableMenu a {\r\n  font-size: 10pt;\r\n  text-decoration: none;\r\n}\r\n.tableHeader {\r\n  background-color: #CECECE;\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n.tableData {\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n.pollColor {\r\n  background-color: #CCCCCC;\r\n  border: thin solid #393C3C;\r\n}\r\n.pagination {\r\n  font-family: helvetica, arial;\r\n  font-size: 8pt;\r\n  text-align: center;\r\n}\r\n\r\nh1, h2, h3, h4, h5, h6 {\r\n   font-family: helvetica, arial;\r\n	color: #EC4300;\r\n}\r\n\r\nh1 {\r\n	font-size: 14pt;\r\n	font-family: helvetica, arial;\r\n	color: #EC4300;\r\n}\r\n\r\n.tab {\r\n  border: 1px solid black;\r\n   background-color: #eeeeee;\r\n}\r\n.tabBody {\r\n   border: 1px solid black;\r\n   border-top: 1px solid black;\r\n   border-left: 1px solid black;\r\n   background-color: #dddddd; \r\n}\r\ndiv.tabs {\r\n    line-height: 15px;\r\n    font-size: 14px;\r\n}\r\n.tabHover {\r\n   background-color: #cccccc;\r\n}\r\n.tabActive { \r\n   background-color: #dddddd; \r\n}\r\n\r\n</style>\r\n		\n		</head>\n		<body bgcolor=\"#D5E0E1\" leftmargin=\"0\" topmargin=\"0\" rightmargin=\"0\" bottommargin=\"0\" marginwidth=\"0\" marginheight=\"0\">\r\n^AdminBar(\"PBtmpl0000000000000090\");\r\n\r\n<!-- logo / login table starts here -->\r\n<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\" align=\"center\">\r\n	<tr>	\r\n		<td width=\"195\" align=\"center\" class=\"logo\"><a href=\"http://www.plainblack.com/webgui\"><img border=\"0\" src=\"^Extras;/styles/webgui6/wg_logo.gif\"></a></td>\r\n		<td width=\"334\" align=\"center\" valign=\"top\" class=\"login\">^L(\"17\",\"\",\"PBtmpl0000000000000092\"); ^AdminToggle;</td>\r\n		<td width=\"195\" align=\"center\" class=\"wgBoxTop\" valign=\"bottom\"><a href=\"http://www.plainblack.com/webgui\"><img border=\"0\" src=\"^Extras;/styles/webgui6/wg_box_top.gif\"></a></td>\r\n	</tr>\r\n</table>\r\n<!-- logo / login table ends here -->\r\n<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\" align=\"center\">\r\n	<tr>\r\n	<!-- print, email icons here -->\r\n		<td class=\"iconBox\">\n &nbsp; &nbsp; &nbsp; &nbsp; \r\n<a href=\"^H(linkonly);\"><img border=\"0\" src=\"^Extras;/styles/webgui6/icon_home.gif\" title=\"Go Home\" alt=\"home\" /></a> \n <a href=\"^/;tell_a_friend\"><img border=\"0\" src=\"^Extras;/styles/webgui6/icon_email.gif\" alt=\"Email\" title=\"Email a friend about this site.\" /></a>\r\n<a href=\"^r(linkonly);\"><img border=\"0\" src=\"^Extras;/styles/webgui6/icon_print.gif\" alt=\"Print\" title=\"Make page printable.\" /></a> \n <a href=\"site_map\"><img border=\"0\" src=\"^Extras;/styles/webgui6/icon_site_map.gif\" title=\"View the site map.\" ALT=\"Site Map\" /></a> <a href=\"http://www.plainblack.com\"><img border=\"0\" src=\"^Extras;/styles/webgui6/icon_pb.gif\" ALT=\"Plain Black Icon\" title=\"Visit plainblack.com.\" /></a>\r\n</td>\r\n	<!-- box clouds here -->\r\n		<td class=\"wgBoxBottom\">^Spacer(56,1);<a href=\"http://www.plainblack.com/what_is_webgui\"><img border=\"0\" src=\"^Extras;/styles/webgui6/txt_the_last.gif\"></a>^Spacer(26,1);<a href=\"http://www.plainblack.com/webgui\"><img border=\"0\" src=\"^Extras;/styles/webgui6/wg_box_bottom.gif\"></a></td>\r\n	</tr>\r\n</table>\r\n<!-- date & page title table start here -->\r\n<table width=\"724\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\" align=\"center\">\r\n	<tr>\r\n		<td class=\"dateLeft\">^Spacer(53,59);</td>\r\n		<td width=\"141\" bgcolor=\"#BDC6C7\" class=\"date\">^D(\"%c %D, %y\");</td>\r\n		<td><img border=\"0\" src=\"^Extras;/styles/webgui6/date_right_shadow.gif\"></td>\r\n		<td width=\"467\" bgcolor=\"#B9CDCF\"><div class=\"pageTitle\">^PageTitle;</div></td>\r\n		<td class=\"dateRight\">^Spacer(53,59);</td>\r\n	</tr>\r\n</table>\r\n<!-- date and page title table end here -->\r\n<!-- left nav & content table start here -->\r\n<table width=\"724\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\" align=\"center\">\r\n	<tr>\r\n		<td class=\"contentbgLeft\">^Spacer(53,1);</td>\r\n		<!-- nav column -->\r\n		<td width=\"142\" valign=\"top\" bgcolor=\"#E2E1E1\" style=\"width: 142px;\">\r\n<br /> <div class=\"nav\">\r\n^AssetProxy(\"flexmenu_1002\");\r\n</div> <br /> <br />\r\n<a href=\"http://www.plainblack.com/webgui\"><img border=\"0\" src=\"^Extras;/styles/webgui6/powered_by_aqua_blue.gif\"></a>\r\n</td>\r\n\r\n		<td valign=\"top\" bgcolor=\"#F4F4F4\"><img border=\"0\" src=\"^Extras;/styles/webgui6/lnav_shadow.jpg\"></td>\r\n		<!-- content column -->\r\n		<td width=\"466\" valign=\"top\" bgcolor=\"#F4F4F4\" class=\"content\">\n			<tmpl_var body.content>\n		</td>\r\n		<td class=\"contentbgRight\">^Spacer(53,1);</td>\r\n	</tr>\r\n</table>\r\n<!-- left nav & content table end here -->\r\n<!-- footer -->\r\n<table width=\"724\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\" align=\"center\">\r\n	<tr>\r\n		<td><img border=\"0\" src=\"^Extras;/styles/webgui6/footer.jpg\"></td>\r\n	</tr>\r\n        <tr>\r\n                <td align=\"center\"><a href=\"http://www.plainblack.com\"><img border=\"0\" src=\"^Extras;/styles/webgui6/logo_pb.gif\"></a><br /><span style=\"font-size: 11px;\"><a href=\"http://www.plainblack.com/design\">Design by Plain Black</a></span></td>\r\n        </tr>\r\n</table>\r\n</body>\n		</html>\n		','style',1,1,'B1bNjWVtzSjsvGZh9lPz_A');
INSERT INTO template VALUES ('<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n		<html>\n		<head>\n			<title>^Page(title); - <tmpl_var session.setting.companyName></title>\n				\n	<link rel=\"icon\" href=\"^Extras;favicon.png\" type=\"image/png\" />\n	<link rel=\"SHORTCUT ICON\" href=\"^Extras;favicon.ico\" />\n	<tmpl_var head.tags>\n	\n		<style>\r\n\r\n.content{\r\n  background-color: #ffffff;\r\n  color: #000000;\r\n  font-family: helvetica, arial;\r\n  font-size: 10pt;\r\n  padding: 10pt;\r\n}\r\n\r\nH1 {\r\n  font-family: helvetica, arial;\r\n  font-size: 16pt;\r\n}\r\n\r\nA {\r\n  color: #EF4200;\r\n}\r\n\r\n.pagination {\r\n  font-family: helvetica, arial;\r\n  font-size: 8pt;\r\n  text-align: center;\r\n}\r\n\r\n.formDescription {\r\n  font-family: helvetica, arial;\r\n  font-size: 10pt;\r\n  font-weight: bold;\r\n}\r\n\r\n.formSubtext {\r\n  font-family: helvetica, arial;\r\n  font-size: 8pt;\r\n}\r\n\r\n.highlight {\r\n  background-color: #dddddd;\r\n}\r\n\r\n.tableMenu {\r\n  background-color: #cccccc;\r\n  font-size: 8pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.tableMenu a {\r\n  text-decoration: none;\r\n}\r\n\r\n.tableHeader {\r\n  background-color: #cccccc;\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.tableData {\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.pollAnswer {\r\n  font-family: Helvetica, Arial;\r\n  font-size: 8pt;\r\n}\r\n\r\n.pollColor {\r\n  background-color: #444444;\r\n}\r\n\r\n.pollQuestion {\r\n  font-face: Helvetica, Arial;\r\n  font-weight: bold;\r\n}\r\n\r\n.faqQuestion {\r\n  font-size: 12pt;\r\n  font-weight: bold;\r\n  color: #000000;\r\n}\r\n\r\n</style>\n		</head>\n		^AdminBar(\"\");\n\n<body onLoad=\"window.print()\">\r\n<div align=\"center\"><a href=\"^PageUrl;\"><img src=\"^Extras;plainblack.gif\" border=\"0\"></a></div>\n\n\n			<tmpl_var body.content>\n		\n\n<div align=\"center\">© 2001-2004 Plain Black LLC</div>\r\n</body>\n		</html>\n		','style',1,1,'PBtmpl0000000000000111');
INSERT INTO template VALUES ('<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"\r\n        \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\r\n<html xmlns=\"http://www.w3.org/1999/xhtml\">\r\n<head>\r\n        <title>WebGUI <tmpl_var session.webgui.version>-<tmpl_var session.webgui.status> Admin Console</title>\r\n        	\n	<link rel=\"icon\" href=\"^Extras;favicon.png\" type=\"image/png\" />\n	<link rel=\"SHORTCUT ICON\" href=\"^Extras;favicon.ico\" />\n	<tmpl_var head.tags>\n	 \r\n</head>\r\n<body>\r\n<tmpl_var body.content>\r\n</body>\r\n</html>\r\n','style',1,0,'PBtmpl0000000000000137');
INSERT INTO template VALUES ('<tmpl_var body.content>','style',0,0,'PBtmpl0000000000000132');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a>\n<tmpl_if session.var.adminOn>\n	<p><tmpl_var controls></p>\n</tmpl_if>	\n		<tmpl_if displaytitle>\r\n   <tmpl_if linkurl>\r\n       <a href=\"<tmpl_var linkurl>\">\r\n    </tmpl_if>\r\n     <span class=\"itemTitle\"><tmpl_var title></span>\r\n   <tmpl_if linkurl>\r\n      </a>\r\n    </tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_if attachment.name>\r\n   <tmpl_if displaytitle> - </tmpl_if>\r\n   <a href=\"<tmpl_var attachment.url>\"><img src=\"<tmpl_var attachment.Icon>\" border=\"0\" alt=\"<tmpl_var attachment.name>\" width=\"16\" height=\"16\" border=\"0\" align=\"middle\" /></a>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n  - <tmpl_var description>\r\n</tmpl_if>','Article',1,1,'PBtmpl0000000000000123');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a>\n<tmpl_if session.var.adminOn>\n	<p><tmpl_var controls></p>\n</tmpl_if>	\n		<tmpl_if displaytitle>\r\n   <tmpl_if linkurl>\r\n       <a href=\"<tmpl_var linkurl>\" target=\"_blank\">\r\n    </tmpl_if>\r\n     <span class=\"itemTitle\"><tmpl_var title></span>\r\n   <tmpl_if linkurl>\r\n      </a>\r\n    </tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_if attachment.name>\r\n   <tmpl_if displaytitle> - </tmpl_if>\r\n   <a href=\"<tmpl_var attachment.url>\" target=\"_blank\"><img src=\"<tmpl_var attachment.Icon>\" border=\"0\" alt=\"<tmpl_var attachment.name>\" width=\"16\" height=\"16\" border=\"0\" align=\"middle\" /></a>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n  - <tmpl_var description>\r\n</tmpl_if>','Article',1,1,'PBtmpl0000000000000129');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a> <tmpl_if session.var.adminOn> <p><tmpl_var controls></p> </tmpl_if><tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n <tmpl_if user.canPost>\n			<a href=\"<tmpl_var add.url>\"> <tmpl_var addquestion.label></a><p />\r\n</tmpl_if>\r\n\r\n\r\n<tmpl_loop post_loop>\r\n   \n		<tmpl_if user.isPoster>\n			<tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var edit.url>\"><tmpl_var edit.label></a>]</tmpl_unless>\n		</tmpl_if>\n		<tmpl_if user.isModerator>\n			<tmpl_if session.var.adminOn><tmpl_var controls><tmpl_else><tmpl_unless user.isPoster><tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var edit.url>\"><tmpl_var edit.label></a>]</tmpl_unless></tmpl_unless></tmpl_if>\n		</tmpl_if>\n		\r\n  <b>Q: <tmpl_var title></b><br />\r\n  A: <tmpl_var content>\r\n  <p />\r\n</tmpl_loop>\r\n\r\n','Collaboration',1,1,'PBtmpl0000000000000081');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a> <tmpl_if session.var.adminOn> <p><tmpl_var controls></p> </tmpl_if><tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n <tmpl_if user.canPost>\n			<a href=\"<tmpl_var add.url>\"> <tmpl_var addlink.label></a><p />\r\n</tmpl_if>\r\n\r\n<ol>\r\n<tmpl_loop post_loop>\r\n  <li>\r\n   \n		<tmpl_if user.isPoster>\n			<tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var edit.url>\"><tmpl_var edit.label></a>]</tmpl_unless>\n		</tmpl_if>\n		<tmpl_if user.isModerator>\n			<tmpl_if session.var.adminOn><tmpl_var controls><tmpl_else><tmpl_unless user.isPoster><tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var edit.url>\"><tmpl_var edit.label></a>]</tmpl_unless></tmpl_unless></tmpl_if>\n		</tmpl_if>\r\n\r\n   <a href=\"<tmpl_var userDefined1>\"\r\n   <tmpl_if userDefined2>\r\n          target=\"_blank\"\r\n    </tmpl_if>\r\n    ><span class=\"linkTitle\"><tmpl_var title></span></a>\r\n\r\n    <tmpl_if content>\r\n              - <tmpl_var content>\r\n   </tmpl_if>\r\n  </li>\r\n</tmpl_loop>\r\n</ol>','Collaboration',1,1,'PBtmpl0000000000000101');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a> <tmpl_if session.var.adminOn> <p><tmpl_var controls></p> </tmpl_if><tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n <tmpl_if user.canPost>\n			<a href=\"<tmpl_var add.url>\"> <tmpl_var addlink.label></a><p />\r\n</tmpl_if>\r\n\r\n<tmpl_loop post_loop>\r\n   \n		<tmpl_if user.isPoster>\n			<tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var edit.url>\"><tmpl_var edit.label></a>]</tmpl_unless>\n		</tmpl_if>\n		<tmpl_if user.isModerator>\n			<tmpl_if session.var.adminOn><tmpl_var controls><tmpl_else><tmpl_unless user.isPoster><tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var edit.url>\"><tmpl_var edit.label></a>]</tmpl_unless></tmpl_unless></tmpl_if>\n		<br />\r\n   </tmpl_if>\r\n\r\n  <a href=\"<tmpl_var userDefined1>\"\r\n   <tmpl_if userDefined2>\r\n          target=\"_blank\"\r\n    </tmpl_if>\r\n    ><span class=\"linkTitle\"><tmpl_var title></span></a>\r\n\r\n    <tmpl_if content>\r\n              - <tmpl_var content>\r\n   </tmpl_if>\r\n   <p />\r\n</tmpl_loop>\r\n','Collaboration',1,1,'PBtmpl0000000000000102');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a> <tmpl_if session.var.adminOn> <p><tmpl_var controls></p> </tmpl_if><tmpl_if displayTitle>\n    <h1><tmpl_var title></h1>\n</tmpl_if>\n\n<tmpl_if description>\n    <tmpl_var description><p />\n</tmpl_if>\n\n <tmpl_if user.canPost>\n			<a href=\"<tmpl_var add.url>\"> <tmpl_var addlink.label></a><p />\n</tmpl_if>\n\n<tmpl_loop post_loop>\n   \n		<tmpl_if user.isPoster>\n			<tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var edit.url>\"><tmpl_var edit.label></a>]</tmpl_unless>\n		</tmpl_if>\n		<tmpl_if user.isModerator>\n			<tmpl_if session.var.adminOn><tmpl_var controls><tmpl_else><tmpl_unless user.isPoster><tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var edit.url>\"><tmpl_var edit.label></a>]</tmpl_unless></tmpl_unless></tmpl_if>\n		<br />\n   </tmpl_if>\n\n  <a href=\"<tmpl_var userDefined1>\"\n   <tmpl_if userDefined2>\n          target=\"_blank\"\n    </tmpl_if>\n    ><span class=\"linkTitle\"><tmpl_var title></span></a>\n\n    <tmpl_if content>\n              <br /> <tmpl_var content>\n   </tmpl_if>\n   <p />\n</tmpl_loop>\n','Collaboration',1,1,'wCIc38CvNHUK7aY92Ww4SQ');
INSERT INTO template VALUES ('<a name=\"<tmpl_var assetId>\"></a> <tmpl_if session.var.adminOn> <p><tmpl_var controls></p> </tmpl_if><h1><tmpl_var title></h1>\r\n\r\n<tmpl_if content>\r\n<p>\r\n<b>Link Description</b><br />\r\n<tmpl_var content>\r\n</p>\r\n</tmpl_if>\r\n\r\n<b>Link URL</b><br />\r\n<a href=\"<tmpl_var userDefined1.value>\"><tmpl_var userDefined1.value></a>\r\n\r\n<p>\r\n<a href=\"<tmpl_var collaboration.url>\">List All Links</a>\r\n</p>\r\n\r\n\r\n<tmpl_if canEdit>\r\n<p>\r\n   <a href=\"<tmpl_var edit.url>\">Edit</a>\r\n   &middot;\r\n   <a href=\"<tmpl_var delete.url>\"><tmpl_var delete.label></a>\r\n</p>\r\n</tmpl_if>\r\n\r\n<tmpl_if canChangeStatus>\r\n <p>\r\n<b>Status:</b> <tmpl_var status> ||\r\n   <a href=\"<tmpl_var approve.url>\"><tmpl_var approve.label></a>\r\n   &middot;\r\n   <a href=\"<tmpl_var deny.url>\"><tmpl_var deny.label></a>\r\n </p>\r\n</tmpl_if>\r\n\r\n\r\n\r\n','Collaboration/Thread',1,1,'PBtmpl0000000000000113');
INSERT INTO template VALUES ('<a class=\"myAccountLink\" href=\"<tmpl_var account.url>\"><tmpl_var account.text></a>','Macro/a_account',1,1,'PBtmpl0000000000000037');
INSERT INTO template VALUES ('<a href=\"<tmpl_var toggle.url>\"><tmpl_var toggle.text></a>','Macro/EditableToggle',1,1,'PBtmpl0000000000000038');
INSERT INTO template VALUES ('<a href=\"<tmpl_var toggle.url>\"><tmpl_var toggle.text></a>','Macro/AdminToggle',1,1,'PBtmpl0000000000000036');
INSERT INTO template VALUES ('<a href=\"<tmpl_var file.url>\"><img src=\"<tmpl_var file.icon>\" align=\"middle\" border=\"0\" /><tmpl_var file.name></a>','Macro/File',1,1,'PBtmpl0000000000000039');
INSERT INTO template VALUES ('<a href=\"<tmpl_var file.url>\"><tmpl_var file.name></a>','Macro/File',1,1,'PBtmpl0000000000000091');
INSERT INTO template VALUES ('<a href=\"<tmpl_var file.url>\"><img src=\"<tmpl_var file.icon>\" align=\"middle\" border=\"0\" /><tmpl_var file.name></a>(<tmpl_var file.size>)','Macro/File',1,1,'PBtmpl0000000000000107');
INSERT INTO template VALUES ('<a href=\"<tmpl_var group.url>\"><tmpl_var group.text></a>','Macro/GroupAdd',1,1,'PBtmpl0000000000000040');
INSERT INTO template VALUES ('<a href=\"<tmpl_var group.url>\"><tmpl_var group.text></a>','Macro/GroupDelete',1,1,'PBtmpl0000000000000041');
INSERT INTO template VALUES ('<a class=\"homeLink\" href=\"<tmpl_var homeLink.url>\"><tmpl_var homeLink.text></a>','Macro/H_homeLink',1,1,'PBtmpl0000000000000042');
INSERT INTO template VALUES ('<a class=\"makePrintableLink\" href=\"<tmpl_var printable.url>\"><tmpl_var printable.text></a>','Macro/r_printable',1,1,'PBtmpl0000000000000045');
INSERT INTO template VALUES ('<a class=\"loginToggleLink\" href=\"<tmpl_var toggle.url>\"><tmpl_var toggle.text></a>','Macro/LoginToggle',1,1,'PBtmpl0000000000000043');
INSERT INTO template VALUES ('<p>\r\n  <table cellpadding=3 cellspacing=0 border=1>\r\n  <tr>   \r\n    <td class=\"tableHeader\">\r\n<a href=\"<tmpl_var attachment.url>\"><img src=\"<tmpl_var session.config.extrasURL>/attachment.gif\" border=\"0\" alt=\"<tmpl_var attachment.name>\"></a></td><td>\r\n<a href=\"<tmpl_var attachment.url>\"><img src=\"<tmpl_var attachment.icon>\" align=\"middle\" width=\"16\" height=\"16\" border=\"0\" alt=\"<tmpl_var attachment.name>\"><tmpl_var attachment.name></a>\r\n    </td>\r\n  </tr>\r\n  </table>\r\n</p>\r\n','AttachmentBox',1,1,'PBtmpl0000000000000003');
INSERT INTO template VALUES ('^JavaScript(\"<tmpl_var session.config.extrasURL>/tinymce/jscripts/tiny_mce/tiny_mce.js\");\r\n<script language=\"javascript\" type=\"text/javascript\">\r\n	  tinyMCE.init({\r\n    theme : \"advanced\",\r\n    mode : \"specific_textareas\",\r\n    elements : \"elm1,elm2\",\r\n    content_css : \"<tmpl_var session.setting.richEditCss>\",\r\n    extended_valid_elements : \"a[href|target|name]\",\r\n    plugins : \"collateral,emotions,insertImage,iespell,pagetree,table\",\r\n    theme_advanced_buttons2_add : \"insertImage,pagetree,collateral\",     \r\n    theme_advanced_buttons3_add : \"emotions,iespell\"     ,\r\n    theme_advanced_buttons3_add_before : \"tablecontrols,separator\",\r\n    debug : false,\r\nauto_reset_designmode : true \r\n });\r\n</script>\r\n\r\n<tmpl_var textarea>','richEditor',1,1,'PBtmpl0000000000000138');
INSERT INTO template VALUES ('<tmpl_if batchDescription>\r\nBatch: <tmpl_var batchDescription>\r\n</tmpl_if>\r\n\r\n<tmpl_var message><br>\r\n<tmpl_var codeForm>','Operation/RedeemSubscription',1,1,'PBtmpl0000000000000053');
INSERT INTO template VALUES ('<h2><tmpl_var name></h2>\r\n<tmpl_var description><br>\r\n<br>\r\n<br>\r\n$ <tmpl_var price><br>\r\n<a href=\"<tmpl_var url>\">Subscribe now</a><br>','Macro/SubscriptionItem',1,1,'PBtmpl0000000000000046');
INSERT INTO template VALUES ('<table border=\"1\" cellpadding=\"5\" cellspacing=\"0\">\r\n  <tr>\r\n    <th>Transaction description</th>\r\n    <th>Price</th>\r\n    <th>Status</th>\r\n    <th>Error</th>\r\n  </tr>\r\n<tmpl_loop resultLoop>\r\n  <tr>\r\n    <td align=\"left\"><tmpl_var purchaseDescription></td>\r\n    <td align=\"right\"><tmpl_var purchaseAmount></td>\r\n    <td><tmpl_var status></td>\r\n    <td align=\"left\"><tmpl_var error> (<tmpl_var errorCode>)</td>\r\n  </tr>\r\n</tmpl_loop>\r\n</table><br>\r\n<br>\r\n\r\n<tmpl_var statusExplanation>','Commerce/TransactionError',1,1,'PBtmpl0000000000000018');
INSERT INTO template VALUES ('<tmpl_var title><br>\r\n<br>\r\n<ul>\r\n<tmpl_loop errorLoop>\r\n<li><tmpl_var message></li>\r\n</tmpl_loop>\r\n</ul>\r\n\r\n<tmpl_if recurringItems>\r\n<table border=\"0\" cellpadding=\"5\">\r\n<tmpl_loop recurringLoop>\r\n  <tr>\r\n    <td align=\"left\"><b>Subscription \"<tmpl_var name>\"</b></td>\r\n    <td> : </td>\r\n    <td align=\"left\">$ <tmpl_var price> every <tmpl_var period></td>\r\n  </tr>\r\n</tmpl_loop>\r\n</table><br>\r\n<br>\r\n</tmpl_if>\r\n<tmpl_var form>','Commerce/ConfirmCheckout',1,1,'PBtmpl0000000000000016');
INSERT INTO template VALUES ('<table border=\"0\">\r\n<tmpl_loop purchaseHistoryLoop>\r\n	<tr>\r\n		<td><b><tmpl_var initDate></b></td>\r\n		<td><b><tmpl_var completionDate></b></td>\r\n		<td align=\"right\"><b>$ <tmpl_var amount></b></td>\r\n		<td><b><tmpl_var status></b></td>\r\n		<td><tmpl_if canCancel><a href=\"<tmpl_var cancelUrl>\">Cancel</a></tmpl_if></td>\r\n	</tr>\r\n	<tmpl_loop itemLoop>\r\n	<tr>\r\n		<td \"align=right\"><tmpl_var quantity> x </td>\r\n		<td \"align=left\"><tmpl_var itemName></td>\r\n		<td \"align=right\">$ <tmpl_var amount></td>\r\n	</tr>\r\n	</tmpl_loop>\r\n</tmpl_loop>\r\n</table>','Commerce/ViewPurchaseHistory',1,1,'PBtmpl0000000000000019');
INSERT INTO template VALUES ('<tmpl_var message>','Commerce/CheckoutCanceled',1,1,'PBtmpl0000000000000015');
INSERT INTO template VALUES ('<tmpl_if pluginsAvailable>\r\n   <tmpl_var message><br>\r\n    <tmpl_var formHeader>\r\n       <table border=\"0\" cellspacing=\"0\" cellpadding=\"5\">\r\n    <tmpl_loop pluginLoop>\r\n            <tr>\r\n                        <td><tmpl_var formElement></td>\r\n                     <td align=\"left\"><tmpl_var name></td>\r\n           </tr>\r\n       </tmpl_loop>\r\n        </table>\r\n    <tmpl_var formSubmit>\r\n    <tmpl_var formFooter>\r\n<tmpl_else>\r\n <tmpl_var noPluginsMessage>\r\n</tmpl_if>','Commerce/SelectPaymentGateway',1,1,'PBtmpl0000000000000017');
INSERT INTO template VALUES ('^StyleSheet(^Extras;/adminConsole/adminConsole.css);\r\n^JavaScript(^Extras;/adminConsole/adminConsole.js);\r\n\r\n<div id=\"application_help\">\r\n  <tmpl_if help.url>\r\n    <a href=\"<tmpl_var help.url>\" target=\"_blank\"><img src=\"^Extras;/adminConsole/small/help.gif\" alt=\"?\" border=\"0\" /></a>\r\n  </tmpl_if>\r\n</div>\r\n<div id=\"application_icon\">\r\n    <img src=\"<tmpl_var application.icon>\" border=\"0\" title=\"<tmpl_var application.title>\" alt=\"<tmpl_var application.title>\" />\r\n</div>\r\n<div class=\"adminConsoleTitleIconMedalian\">\r\n<img src=\"^Extras;/adminConsole/medalian.gif\" border=\"0\" alt=\"*\" />\r\n</div>\r\n<div id=\"console_icon\">\r\n     <img src=\"<tmpl_var console.icon>\" border=\"0\" title=\"<tmpl_var console.title>\" alt=\"<tmpl_var console.title>\" />\r\n</div>\r\n<div id=\"application_title\">\r\n       <tmpl_var application.title>\r\n</div>\r\n<div id=\"console_title\">\r\n       <tmpl_var console.title>\r\n</div>\r\n<div id=\"application_workarea\">\r\n       <tmpl_var application.workArea>\r\n</div>\r\n<div id=\"console_workarea\">\r\n        <div class=\"adminConsoleSpacer\">\r\n            &nbsp;\r\n        </div>\r\n        <tmpl_loop application_loop>\r\n                <tmpl_if canUse>\r\n                     <div class=\"adminConsoleApplication\">\r\n                           <a href=\"<tmpl_var url>\"><img src=\"<tmpl_var icon>\" border=\"0\" title=\"<tmpl_var title>\" alt=\"<tmpl_var title>\" /></a><br />\r\n                           <a href=\"<tmpl_var url>\"><tmpl_var title></a>\r\n                     </div>\r\n               </tmpl_if>\r\n       </tmpl_loop>\r\n        <div class=\"adminConsoleSpacer\">\r\n            &nbsp;\r\n        </div>\r\n</div>\r\n<div class=\"adminConsoleMenu\">\r\n        <div id=\"adminConsoleMainMenu\" class=\"adminConsoleMainMenu\">\r\n                <div id=\"console_toggle_on\">\r\n                        <a href=\"#\" onClick=\"toggleAdminConsole()\"><tmpl_var toggle.on.label></a><br />\r\n                </div>\r\n                <div id=\"console_toggle_off\">\r\n                        <a href=\"#\" onClick=\"toggleAdminConsole()\"><tmpl_var toggle.off.label></a><br />\r\n                </div>\r\n        </div>\r\n        <div id=\"adminConsoleApplicationSubmenu\"  class=\"adminConsoleApplicationSubmenu\">\r\n              <tmpl_loop submenu_loop>\r\n                        <a href=\"<tmpl_var url>\" <tmpl_var extras>><tmpl_var label></a><br />\r\n              </tmpl_loop>\r\n        </div>\r\n        <div id=\"adminConsoleUtilityMenu\" class=\"adminConsoleUtilityMenu\">\r\n                <a href=\"^PageUrl;\"><tmpl_var backtosite.label></a><br />\r\n                ^AdminToggle;<br />\r\n                ^LoginToggle;<br />\r\n        </div>\r\n</div>\r\n<script lang=\"JavaScript\">\r\n  initAdminConsole(<tmpl_if application.title>true<tmpl_else>false</tmpl_if>,<tmpl_if submenu_loop>true<tmpl_else>false</tmpl_if>);\r\n</script>\r\n','AdminConsole',1,1,'PBtmpl0000000000000001');
INSERT INTO template VALUES ('\n<a name=\"<tmpl_var assetId>\"></a>\n<tmpl_if session.var.adminOn>\n	<p><tmpl_var controls></p>\n	<div style=\"width: 100%; border: 1px groove black;\">\n		<div style=\"width: 100%; background-image: url(<tmpl_var session.config.extrasURL>/opaque.gif);\">\n			<div style=\"text-align: center; font-weight: bold;\"><a href=\"<tmpl_var originalURL>\"><tmpl_var shortcut.label></a></div>\n		</div>\n</tmpl_if>	\n<tmpl_var shortcut.content>\n<tmpl_if session.var.adminOn>\n		<div style=\"width: 100%; background-image: url(<tmpl_var session.config.extrasURL>/opaque.gif);\">\n			<div style=\"text-align: center; font-weight: bold;\"><a href=\"<tmpl_var originalURL>\"><tmpl_var shortcut.label></a></div>\n		</div>\n	</div>\n</tmpl_if>	\n		','Shortcut',1,1,'PBtmpl0000000000000140');

--
-- Table structure for table `theme`
--

CREATE TABLE theme (
  themeId varchar(22) NOT NULL default '',
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
  themeId varchar(22) default NULL,
  themeComponentId varchar(22) default NULL,
  type varchar(35) default NULL,
  id varchar(255) default NULL
) TYPE=MyISAM;

--
-- Dumping data for table `themeComponent`
--



--
-- Table structure for table `transaction`
--

CREATE TABLE transaction (
  transactionId varchar(22) NOT NULL default '',
  userId varchar(22) NOT NULL default '',
  amount float NOT NULL default '0',
  gatewayId varchar(128) default NULL,
  gateway varchar(64) NOT NULL default '',
  recurring tinyint(1) NOT NULL default '0',
  initDate int(11) NOT NULL default '0',
  completionDate int(11) default '0',
  status varchar(10) NOT NULL default 'Pending',
  lastPayedTerm int(6) NOT NULL default '0',
  PRIMARY KEY  (transactionId)
) TYPE=MyISAM;

--
-- Dumping data for table `transaction`
--



--
-- Table structure for table `transactionItem`
--

CREATE TABLE transactionItem (
  transactionId varchar(22) NOT NULL default '',
  itemName varchar(64) NOT NULL default '',
  amount float NOT NULL default '0',
  quantity int(4) NOT NULL default '0',
  itemId varchar(64) NOT NULL default '',
  itemType varchar(40) NOT NULL default ''
) TYPE=MyISAM;

--
-- Dumping data for table `transactionItem`
--



--
-- Table structure for table `userLoginLog`
--

CREATE TABLE userLoginLog (
  userId varchar(22) default NULL,
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
  profileCategoryId varchar(22) NOT NULL default '',
  categoryName varchar(255) default NULL,
  sequenceNumber int(11) NOT NULL default '1',
  visible int(11) NOT NULL default '1',
  editable int(11) NOT NULL default '1',
  PRIMARY KEY  (profileCategoryId)
) TYPE=MyISAM;

--
-- Dumping data for table `userProfileCategory`
--


INSERT INTO userProfileCategory VALUES ('1','WebGUI::International::get(449,\"WebGUI\");',6,1,1);
INSERT INTO userProfileCategory VALUES ('2','WebGUI::International::get(440,\"WebGUI\");',2,1,1);
INSERT INTO userProfileCategory VALUES ('3','WebGUI::International::get(439,\"WebGUI\");',1,1,1);
INSERT INTO userProfileCategory VALUES ('4','WebGUI::International::get(445,\"WebGUI\");',7,0,1);
INSERT INTO userProfileCategory VALUES ('5','WebGUI::International::get(443,\"WebGUI\");',3,1,1);
INSERT INTO userProfileCategory VALUES ('6','WebGUI::International::get(442,\"WebGUI\");',4,1,1);
INSERT INTO userProfileCategory VALUES ('7','WebGUI::International::get(444,\"WebGUI\");',5,1,1);

--
-- Table structure for table `userProfileData`
--

CREATE TABLE userProfileData (
  userId varchar(22) NOT NULL default '',
  fieldName varchar(128) NOT NULL default '',
  fieldData text,
  PRIMARY KEY  (userId,fieldName)
) TYPE=MyISAM;

--
-- Dumping data for table `userProfileData`
--


INSERT INTO userProfileData VALUES ('1','language','English');
INSERT INTO userProfileData VALUES ('3','language','English');
INSERT INTO userProfileData VALUES ('3','uiLevel','9');

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
  profileCategoryId varchar(22) default NULL,
  protected int(11) NOT NULL default '0',
  editable int(11) NOT NULL default '1',
  PRIMARY KEY  (fieldName)
) TYPE=MyISAM;

--
-- Dumping data for table `userProfileField`
--


INSERT INTO userProfileField VALUES ('email','WebGUI::International::get(56,\"WebGUI\");',1,1,'email',NULL,NULL,1,'2',1,1);
INSERT INTO userProfileField VALUES ('firstName','WebGUI::International::get(314,\"WebGUI\");',1,0,'text',NULL,NULL,1,'3',1,1);
INSERT INTO userProfileField VALUES ('middleName','WebGUI::International::get(315,\"WebGUI\");',1,0,'text',NULL,NULL,2,'3',1,1);
INSERT INTO userProfileField VALUES ('lastName','WebGUI::International::get(316,\"WebGUI\");',1,0,'text',NULL,NULL,3,'3',1,1);
INSERT INTO userProfileField VALUES ('icq','WebGUI::International::get(317,\"WebGUI\");',1,0,'text',NULL,NULL,2,'2',1,1);
INSERT INTO userProfileField VALUES ('aim','WebGUI::International::get(318,\"WebGUI\");',1,0,'text',NULL,NULL,3,'2',1,1);
INSERT INTO userProfileField VALUES ('msnIM','WebGUI::International::get(319,\"WebGUI\");',1,0,'text',NULL,NULL,4,'2',1,1);
INSERT INTO userProfileField VALUES ('yahooIM','WebGUI::International::get(320,\"WebGUI\");',1,0,'text',NULL,NULL,5,'2',1,1);
INSERT INTO userProfileField VALUES ('cellPhone','WebGUI::International::get(321,\"WebGUI\");',1,0,'phone',NULL,NULL,6,'2',1,1);
INSERT INTO userProfileField VALUES ('pager','WebGUI::International::get(322,\"WebGUI\");',1,0,'phone',NULL,NULL,7,'2',1,1);
INSERT INTO userProfileField VALUES ('emailToPager','WebGUI::International::get(441,\"WebGUI\");',1,0,'email',NULL,NULL,8,'2',1,1);
INSERT INTO userProfileField VALUES ('language','WebGUI::International::get(304,\"WebGUI\");',1,0,'selectList','WebGUI::International::getLanguages()','[\'English\']',1,'4',1,1);
INSERT INTO userProfileField VALUES ('homeAddress','WebGUI::International::get(323,\"WebGUI\");',1,0,'text',NULL,NULL,1,'5',1,1);
INSERT INTO userProfileField VALUES ('homeCity','WebGUI::International::get(324,\"WebGUI\");',1,0,'text',NULL,NULL,2,'5',1,1);
INSERT INTO userProfileField VALUES ('homeState','WebGUI::International::get(325,\"WebGUI\");',1,0,'text',NULL,NULL,3,'5',1,1);
INSERT INTO userProfileField VALUES ('homeZip','WebGUI::International::get(326,\"WebGUI\");',1,0,'zipcode',NULL,NULL,4,'5',1,1);
INSERT INTO userProfileField VALUES ('homeCountry','WebGUI::International::get(327,\"WebGUI\");',1,0,'text',NULL,NULL,5,'5',1,1);
INSERT INTO userProfileField VALUES ('homePhone','WebGUI::International::get(328,\"WebGUI\");',1,0,'phone',NULL,NULL,6,'5',1,1);
INSERT INTO userProfileField VALUES ('workAddress','WebGUI::International::get(329,\"WebGUI\");',1,0,'text',NULL,NULL,2,'6',1,1);
INSERT INTO userProfileField VALUES ('workCity','WebGUI::International::get(330,\"WebGUI\");',1,0,'text',NULL,NULL,3,'6',1,1);
INSERT INTO userProfileField VALUES ('workState','WebGUI::International::get(331,\"WebGUI\");',1,0,'text',NULL,NULL,4,'6',1,1);
INSERT INTO userProfileField VALUES ('workZip','WebGUI::International::get(332,\"WebGUI\");',1,0,'zipcode',NULL,NULL,5,'6',1,1);
INSERT INTO userProfileField VALUES ('workCountry','WebGUI::International::get(333,\"WebGUI\");',1,0,'text',NULL,NULL,6,'6',1,1);
INSERT INTO userProfileField VALUES ('workPhone','WebGUI::International::get(334,\"WebGUI\");',1,0,'phone',NULL,NULL,7,'6',1,1);
INSERT INTO userProfileField VALUES ('gender','WebGUI::International::get(335,\"WebGUI\");',1,0,'selectList','{\r\n  \'neuter\'=>WebGUI::International::get(403),\r\n  \'male\'=>WebGUI::International::get(339),\r\n  \'female\'=>WebGUI::International::get(340)\r\n}','[\'neuter\']',1,'7',1,1);
INSERT INTO userProfileField VALUES ('birthdate','WebGUI::International::get(336,\"WebGUI\");',1,0,'date',NULL,NULL,2,'7',1,1);
INSERT INTO userProfileField VALUES ('homeURL','WebGUI::International::get(337,\"WebGUI\");',1,0,'url',NULL,NULL,7,'5',1,1);
INSERT INTO userProfileField VALUES ('workURL','WebGUI::International::get(446,\"WebGUI\");',1,0,'url',NULL,NULL,8,'6',1,1);
INSERT INTO userProfileField VALUES ('workName','WebGUI::International::get(450,\"WebGUI\");',1,0,'text',NULL,NULL,1,'6',1,1);
INSERT INTO userProfileField VALUES ('timeOffset','WebGUI::International::get(460,\"WebGUI\");',1,0,'text',NULL,'\'0\'',3,'4',1,1);
INSERT INTO userProfileField VALUES ('dateFormat','WebGUI::International::get(461,\"WebGUI\");',1,0,'selectList','{\r\n \'%M/%D/%y\'=>WebGUI::DateTime::epochToHuman(\"\",\"%M/%D/%y\"),\r\n \'%y-%m-%d\'=>WebGUI::DateTime::epochToHuman(\"\",\"%y-%m-%d\"),\r\n \'%D-%c-%y\'=>WebGUI::DateTime::epochToHuman(\"\",\"%D-%c-%y\"),\r\n \'%c %D, %y\'=>WebGUI::DateTime::epochToHuman(\"\",\"%c %D, %y\")\r\n}\r\n','[\'%M/%D/%y\']',4,'4',1,1);
INSERT INTO userProfileField VALUES ('timeFormat','WebGUI::International::get(462,\"WebGUI\");',1,0,'selectList','{\r\n \'%H:%n %p\'=>WebGUI::DateTime::epochToHuman(\"\",\"%H:%n %p\"),\r\n \'%H:%n:%s %p\'=>WebGUI::DateTime::epochToHuman(\"\",\"%H:%n:%s %p\"),\r\n \'%j:%n\'=>WebGUI::DateTime::epochToHuman(\"\",\"%j:%n\"),\r\n \'%j:%n:%s\'=>WebGUI::DateTime::epochToHuman(\"\",\"%j:%n:%s\")\r\n}\r\n','[\'%H:%n %p\']',5,'4',1,1);
INSERT INTO userProfileField VALUES ('discussionLayout','WebGUI::International::get(509)',1,0,'selectList','{\n  threaded=>WebGUI::International::get(511),\n  flat=>WebGUI::International::get(510),\n  nested=>WebGUI::International::get(1045)\n}\n','[\'threaded\']',6,'4',0,1);
INSERT INTO userProfileField VALUES ('INBOXNotifications','WebGUI::International::get(518)',1,0,'selectList','{ \r\n  none=>WebGUI::International::get(519),\r\n email=>WebGUI::International::get(520),\r\n  emailToPager=>WebGUI::International::get(521),\r\n  icq=>WebGUI::International::get(522)\r\n}','[\'email\']',7,'4',0,1);
INSERT INTO userProfileField VALUES ('firstDayOfWeek','WebGUI::International::get(699,\"WebGUI\");',1,0,'selectList','{0=>WebGUI::International::get(27,\"WebGUI\"),1=>WebGUI::International::get(28,\"WebGUI\")}','[0]',3,'4',1,1);
INSERT INTO userProfileField VALUES ('uiLevel','WebGUI::International::get(739,\"WebGUI\");',0,0,'selectList','{\r\n0=>WebGUI::International::get(729,\"WebGUI\"),\r\n1=>WebGUI::International::get(730,\"WebGUI\"),\r\n2=>WebGUI::International::get(731,\"WebGUI\"),\r\n3=>WebGUI::International::get(732,\"WebGUI\"),\r\n4=>WebGUI::International::get(733,\"WebGUI\"),\r\n5=>WebGUI::International::get(734,\"WebGUI\"),\r\n6=>WebGUI::International::get(735,\"WebGUI\"),\r\n7=>WebGUI::International::get(736,\"WebGUI\"),\r\n8=>WebGUI::International::get(737,\"WebGUI\"),\r\n9=>WebGUI::International::get(738,\"WebGUI\")\r\n}','[5]',8,'4',1,0);
INSERT INTO userProfileField VALUES ('alias','WebGUI::International::get(858)',1,0,'text','','',4,'3',0,1);
INSERT INTO userProfileField VALUES ('signature','WebGUI::International::get(859)',1,0,'HTMLArea','','',5,'3',0,1);
INSERT INTO userProfileField VALUES ('publicProfile','WebGUI::International::get(861)',1,0,'yesNo','','1',9,'4',0,1);
INSERT INTO userProfileField VALUES ('publicEmail','WebGUI::International::get(860)',1,0,'yesNo','','1',10,'4',0,1);
INSERT INTO userProfileField VALUES ('richEditor','WebGUI::International::get(496)',1,0,'selectList','{\'PBtmpl0000000000000126\'=>WebGUI::International::get(880),\r\nnone=>WebGUI::International::get(881),\r\n\'PBtmpl0000000000000138\'=>WebGUI::International::get(\"tinymce\")\n}','[\'PBtmpl0000000000000138\']',11,'4',0,1);
INSERT INTO userProfileField VALUES ('richEditorMode','WebGUI::International::get(882)',1,0,'selectList','{\r\ninline=>WebGUI::International::get(883),\r\npopup=>WebGUI::International::get(884)\r\n}','[\'inline\']',12,'4',0,1);
INSERT INTO userProfileField VALUES ('toolbar','WebGUI::International::get(746)',0,0,'selectList','WebGUI::Icon::getToolbarOptions()','[\'useLanguageDefault\']',13,'4',0,0);

--
-- Table structure for table `userSession`
--

CREATE TABLE userSession (
  sessionId varchar(22) NOT NULL default '',
  expires int(11) default NULL,
  lastPageView int(11) default NULL,
  adminOn int(11) NOT NULL default '0',
  lastIP varchar(50) default NULL,
  userId varchar(22) default NULL,
  PRIMARY KEY  (sessionId)
) TYPE=MyISAM;

--
-- Dumping data for table `userSession`
--



--
-- Table structure for table `userSessionScratch`
--

CREATE TABLE userSessionScratch (
  sessionId varchar(22) NOT NULL default '',
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
  userId varchar(22) NOT NULL default '',
  username varchar(100) default NULL,
  authMethod varchar(30) NOT NULL default 'WebGUI',
  dateCreated int(11) NOT NULL default '1019867418',
  lastUpdated int(11) NOT NULL default '1019867418',
  karma int(11) NOT NULL default '0',
  status varchar(35) NOT NULL default 'Active',
  referringAffiliate varchar(22) NOT NULL default '',
  PRIMARY KEY  (userId),
  UNIQUE KEY username_unique (username)
) TYPE=MyISAM;

--
-- Dumping data for table `users`
--


INSERT INTO users VALUES ('1','Visitor','WebGUI',1019867418,1019867418,0,'Active','0');
INSERT INTO users VALUES ('3','Admin','WebGUI',1019867418,1109989293,0,'Active','1');

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


INSERT INTO webguiVersion VALUES ('6.5.1','initial install',unix_timestamp());

--
-- Table structure for table `wobject`
--

CREATE TABLE wobject (
  displayTitle int(11) NOT NULL default '1',
  description mediumtext,
  assetId varchar(22) NOT NULL default '',
  styleTemplateId varchar(22) NOT NULL default '',
  printableStyleTemplateId varchar(22) NOT NULL default '',
  cacheTimeout int(11) NOT NULL default '60',
  cacheTimeoutVisitor int(11) NOT NULL default '3600',
  PRIMARY KEY  (assetId)
) TYPE=MyISAM;

--
-- Dumping data for table `wobject`
--


INSERT INTO wobject VALUES (1,'Welcome to WebGUI. This is web done right.\n<br /><br />\nWebGUI is a user-friendly web site management system made by <a href=\"http://www.plainblack.com\">Plain Black</a>. It is designed to be easy to use for the average business user, but powerful enough to satisfy the needs of a large enterprise.\n<br /><br />\nThere are thousands of <a href=\"http://www.adinknetwork.com\" target=\"_blank\">small</a> and <a href=\"http://www.brunswickbowling.com\" target=\"_blank\">large</a> businesses, <a href=\"http://www.troy30c.org\" target=\"_blank\">schools</a>, <a href=\"http://goaggies.cameron.edu/\" target=\"_blank\">universities</a>, <a href=\"http://www.lambtononline.ca/\" target=\"_blank\">governments</a>, <a href=\"http://www.hetnieuweland.nl/\" target=\"_blank\">clubs</a>, <a href=\"http://www.k3b.org\" target=\"_blank\">projects</a>, <a href=\"http://www.cmsmatrix.org\" target=\"_blank\">communities</a>, and <a href=\"http://www.primaat.com\" target=\"_blank\">individuals</a> using WebGUI all over the world today. A brief list of some of them can be found <a href=\"http://www.plainblack.com/webgui/examples\">here</a>. There\'s no reason your site shouldn\'t be on that list.<br /><br />','TKzUMeIxRLrZ3NAEez6CXQ','B1bNjWVtzSjsvGZh9lPz_A','PBtmpl0000000000000111',60,600);
INSERT INTO wobject VALUES (1,'<img src=\"^Extras;styles/webgui6/img_hands.jpg\" style=\"position: relative;\" align=\"right\" />\n<style>\ndt {\n font-weight: bold;\n}\n</style>\n\n<dl>\n\n<dt>Easy to Use</dt>\n<dd>If you can use a web browser, then you can manage a web site with WebGUI. WebGUI\'s unique WYSIWYG inline content editing interface ensures that you know where you are and what your content will look like while you\'re editing. In addition, you don\'t need to install and learn any complicated programs, you can edit everything with your trusty web browser.</dd>\n<br />\n\n<dt>Flexible Designs</dt>\n<dd>WebGUI\'s powerful templating system ensures that no two WebGUI sites ever need to look the same. You\'re not restricted in how your content is laid out or how your navigation functions.</dd>\n<br />\n\n<dt>Work Faster</dt>\n<dd>Though there is some pretty cool technology behind the scenes that makes WebGUI work, our first concern has always been usability and not technology. After all if it\'s not useful, why use it? With that in mind WebGUI has all kinds of wizards, short cuts, online help, and other aids to help you work faster.</dd>\n<br />\n\n<dt>Localized Content</dt>\n<dd>With WebGUI there\'s no need to limit yourself to one language or timezone. It\'s a snap to build a multi-lingual site with WebGUI. In fact, even WebGUI\'s built in functions and online help have been translated to more than 15 languages. User\'s can also adjust their local settings for dates, times, and other localized oddities. </dd>\n<br />\n\n<dt>Pluggable By Design</dt>\n<dd>When <a href=\"http://www.plainblack.com\">Plain Black</a> created WebGUI we knew we wouldn\'t be able to think of everything you want to use WebGUI for, so we made most of WebGUI\'s functions pluggable. This allows you to add new features to WebGUI and still be able to upgrade the core system without a fuss.</dd>\n\n</dl>','sWVXMZGibxHe2Ekj1DCldA','B1bNjWVtzSjsvGZh9lPz_A','PBtmpl0000000000000111',60,600);
INSERT INTO wobject VALUES (0,'If you\'re reading this message it means that you\'ve got WebGUI up and running. Good job! The installation is not trivial.\n\n<p/>\n \nIn order to do anything useful with your new installation you\'ll need to log in as the default administrator account. Follow these steps to get started:\n\n<p/>\n\n<ol>\n<li><a href=\"^a(linkonly);\">Click here to log in.</a> (You specified the username and password when you first visited your new WebGUI site.)\n<li><a href=\"^PageUrl;?op=switchOnAdmin\">Click here to turn the administrative interface on.</a>\n</ol>\n<blockquote style=\"font-size: 10px;\">\n<b>NOTE:</b> You could have also done these steps using the block at the top of this page.\n</blockquote>\n\n<p/>\n\n You might want to <a href=\"^PageUrl;?op=listUsers\">create another account</a> for yourself with Administrative privileges in case you can\'t log in with the Admin account for some reason.\n\n<p/>\n \nYou\'ll now notice little buttons and menus on all the pages in your site. These controls help you administer your site. The \"Add content\" menu lets you add new content to your pages as well as paste content from the clipboard. The \"Administrative functions\" menu let\'s you control users and groups as well as many other admin settings. The little toolbars help you manipulate the content in your pages.\n\n\n<p/>\n\nFor more information about how to administer <a href=\"http://www.plainblack.com/webgui\">WebGUI</a> consider getting a copy of <a href=\"http://www.plainblack.com/store/rwg\">Ruling WebGUI</a>. <a href=\"http://www.plainblack.com\">Plain Black</a> also provides several <a href=\"http://www.plainblack.com/store/support\">Support Programs</a> for WebGUI if you run into trouble.\n\n<p/>\n \nEnjoy your new WebGUI site!','x_WjMvFmilhX-jvZuIpinw','B1bNjWVtzSjsvGZh9lPz_A','PBtmpl0000000000000111',60,600);
INSERT INTO wobject VALUES (0,' To learn more about WebGUI and how you can best implement WebGUI in your organization, please see the choices below.\n\n','DC1etlIaBRQitXnchZKvUw','B1bNjWVtzSjsvGZh9lPz_A','PBtmpl0000000000000111',60,600);
INSERT INTO wobject VALUES (0,'This is the latest news from Plain Black and WebGUI pulled directly from the site every hour.','fK-HMSboA3uu0c1KYkYspA','B1bNjWVtzSjsvGZh9lPz_A','PBtmpl0000000000000111',60,600);
INSERT INTO wobject VALUES (0,'Tell a friend about WebGUI.','Szs5eev3OMssmnsyLRZmWA','B1bNjWVtzSjsvGZh9lPz_A','PBtmpl0000000000000111',60,600);
INSERT INTO wobject VALUES (0,'','pJd5TLAjfWMVXD6sCRLwUg','B1bNjWVtzSjsvGZh9lPz_A','PBtmpl0000000000000111',60,600);
INSERT INTO wobject VALUES (0,NULL,'68sKwDgf9cGH58-NZcU4lg','B1bNjWVtzSjsvGZh9lPz_A','PBtmpl0000000000000111',60,600);
INSERT INTO wobject VALUES (0,NULL,'_iHetEvMQUOoxS-T2CM0sQ','B1bNjWVtzSjsvGZh9lPz_A','PBtmpl0000000000000111',60,600);
INSERT INTO wobject VALUES (0,NULL,'8Bb8gu-me2mhL3ljFyiWLg','B1bNjWVtzSjsvGZh9lPz_A','PBtmpl0000000000000111',60,600);
INSERT INTO wobject VALUES (0,NULL,'2TqQc4OISddWCZmRY1_m8A','B1bNjWVtzSjsvGZh9lPz_A','PBtmpl0000000000000111',60,600);
INSERT INTO wobject VALUES (0,NULL,'Swf6L8poXKc7hUaNPkBevw','B1bNjWVtzSjsvGZh9lPz_A','PBtmpl0000000000000111',60,600);
INSERT INTO wobject VALUES (0,NULL,'x3OFY6OJh_qsXkZfPwug4A','B1bNjWVtzSjsvGZh9lPz_A','PBtmpl0000000000000111',60,600);
INSERT INTO wobject VALUES (1,NULL,'PBasset000000000000002','PBtmpl0000000000000060','PBtmpl0000000000000111',60,3600);
INSERT INTO wobject VALUES (1,NULL,'Wmjn6I1fe9DKhiIR39YC0g','PBtmpl0000000000000060','PBtmpl0000000000000111',60,3600);
INSERT INTO wobject VALUES (0,NULL,'PBnav00000000000000001','PBtmpl0000000000000060','PBtmpl0000000000000111',60,3600);
INSERT INTO wobject VALUES (0,NULL,'PBnav00000000000000014','PBtmpl0000000000000060','PBtmpl0000000000000111',60,3600);
INSERT INTO wobject VALUES (0,NULL,'PBnav00000000000000015','PBtmpl0000000000000060','PBtmpl0000000000000111',60,3600);
INSERT INTO wobject VALUES (0,NULL,'PBnav00000000000000016','PBtmpl0000000000000060','PBtmpl0000000000000111',60,3600);
INSERT INTO wobject VALUES (0,NULL,'PBnav00000000000000017','PBtmpl0000000000000060','PBtmpl0000000000000111',60,3600);
INSERT INTO wobject VALUES (0,NULL,'PBnav00000000000000018','PBtmpl0000000000000060','PBtmpl0000000000000111',60,3600);
INSERT INTO wobject VALUES (0,NULL,'PBnav00000000000000019','PBtmpl0000000000000060','PBtmpl0000000000000111',60,3600);
INSERT INTO wobject VALUES (0,NULL,'PBnav00000000000000020','PBtmpl0000000000000060','PBtmpl0000000000000111',60,3600);
INSERT INTO wobject VALUES (0,NULL,'PBnav00000000000000021','PBtmpl0000000000000060','PBtmpl0000000000000111',60,3600);
INSERT INTO wobject VALUES (0,NULL,'PBnav00000000000000002','PBtmpl0000000000000060','PBtmpl0000000000000111',60,3600);
INSERT INTO wobject VALUES (0,NULL,'PBnav00000000000000006','PBtmpl0000000000000060','PBtmpl0000000000000111',60,3600);
INSERT INTO wobject VALUES (0,NULL,'PBnav00000000000000007','PBtmpl0000000000000060','PBtmpl0000000000000111',60,3600);
INSERT INTO wobject VALUES (0,NULL,'PBnav00000000000000008','PBtmpl0000000000000060','PBtmpl0000000000000111',60,3600);
INSERT INTO wobject VALUES (0,NULL,'PBnav00000000000000009','PBtmpl0000000000000060','PBtmpl0000000000000111',60,3600);
INSERT INTO wobject VALUES (0,NULL,'PBnav00000000000000010','PBtmpl0000000000000060','PBtmpl0000000000000111',60,3600);
INSERT INTO wobject VALUES (0,NULL,'PBnav00000000000000011','PBtmpl0000000000000060','PBtmpl0000000000000111',60,3600);
INSERT INTO wobject VALUES (0,NULL,'PBnav00000000000000012','PBtmpl0000000000000060','PBtmpl0000000000000111',60,3600);
INSERT INTO wobject VALUES (0,NULL,'PBnav00000000000000013','PBtmpl0000000000000060','PBtmpl0000000000000111',60,3600);
INSERT INTO wobject VALUES (0,NULL,'f2bihDeMoI-Ojt2dutJNQA','PBtmpl0000000000000060','PBtmpl0000000000000111',60,3600);
INSERT INTO wobject VALUES (0,NULL,'KZ2UytxNpbF-3Eg3RNvQQQ','PBtmpl0000000000000060','PBtmpl0000000000000111',60,3600);
INSERT INTO wobject VALUES (0,NULL,'G0wlShbk_XruYVfbXqWq_w','PBtmpl0000000000000060','PBtmpl0000000000000111',60,3600);
INSERT INTO wobject VALUES (1,NULL,'UE5_3bD7kWDLUN2B-iuNuA','PBtmpl0000000000000060','PBtmpl0000000000000111',60,3600);
INSERT INTO wobject VALUES (1,NULL,'RTsbVBEYnn3OPZWmXyIFhQ','PBtmpl0000000000000060','PBtmpl0000000000000111',60,3600);

