-- MySQL dump 8.23
--
-- Host: localhost    Database: dev
---------------------------------------------------------
-- Server version	3.23.58

--
-- Table structure for table `Article`
--

CREATE TABLE Article (
  wobjectId varchar(22) NOT NULL default '',
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


INSERT INTO Article VALUES ('1',NULL,'','',NULL,0);
INSERT INTO Article VALUES ('2',NULL,'','',NULL,0);
INSERT INTO Article VALUES ('3',NULL,'','',NULL,0);
INSERT INTO Article VALUES ('4',NULL,'','',NULL,0);

--
-- Table structure for table `DataForm`
--

CREATE TABLE DataForm (
  wobjectId varchar(22) NOT NULL default '',
  acknowledgement text,
  mailData int(11) NOT NULL default '1',
  emailTemplateId varchar(22) default NULL,
  acknowlegementTemplateId varchar(22) default NULL,
  listTemplateId varchar(22) default NULL
) TYPE=MyISAM;

--
-- Dumping data for table `DataForm`
--


INSERT INTO DataForm VALUES ('7','Thank you for telling your friends about WebGUI!',1,'2','3','1');

--
-- Table structure for table `DataForm_entry`
--

CREATE TABLE DataForm_entry (
  DataForm_entryId varchar(22) NOT NULL default '',
  wobjectId varchar(22) default NULL,
  userId varchar(22) default NULL,
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
  DataForm_entryId varchar(22) NOT NULL default '',
  DataForm_fieldId varchar(22) NOT NULL default '',
  wobjectId varchar(22) default NULL,
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
  wobjectId varchar(22) default NULL,
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
  PRIMARY KEY  (DataForm_fieldId)
) TYPE=MyISAM;

--
-- Dumping data for table `DataForm_field`
--


INSERT INTO DataForm_field VALUES ('7','1000',1,'from','required','email','','',0,'',0,1,'Your Email Address','0',1,NULL);
INSERT INTO DataForm_field VALUES ('7','1001',2,'to','required','email','','',0,'',0,1,'Your Friends Email Address','0',1,NULL);
INSERT INTO DataForm_field VALUES ('7','1002',3,'cc','hidden','email',NULL,NULL,0,NULL,NULL,1,'Cc','0',1,NULL);
INSERT INTO DataForm_field VALUES ('7','1003',4,'bcc','hidden','email',NULL,NULL,0,NULL,NULL,1,'Bcc','0',1,NULL);
INSERT INTO DataForm_field VALUES ('7','1004',5,'subject','hidden','text','','Cool CMS',0,'',0,1,'Subject','0',1,NULL);
INSERT INTO DataForm_field VALUES ('7','1005',6,'url','visible','url','','http://www.plainblack.com/webgui',0,'',0,1,'URL','0',1,NULL);
INSERT INTO DataForm_field VALUES ('7','1006',7,'message','required','textarea','','Hey I just wanted to tell you about this great program called WebGUI that I found: http://www.plainblack.com/webgui\r\n\r\nYou should really check it out.',34,'',6,0,'Message','0',1,NULL);

--
-- Table structure for table `DataForm_tab`
--

CREATE TABLE DataForm_tab (
  wobjectId varchar(22) default NULL,
  label varchar(255) NOT NULL default '',
  subtext text,
  sequenceNumber int(11) NOT NULL default '0',
  DataForm_tabId varchar(22) NOT NULL default ''
) TYPE=MyISAM;

--
-- Dumping data for table `DataForm_tab`
--



--
-- Table structure for table `EventsCalendar`
--

CREATE TABLE EventsCalendar (
  wobjectId varchar(22) NOT NULL default '',
  calendarLayout varchar(30) NOT NULL default 'list',
  paginateAfter int(11) NOT NULL default '50',
  startMonth varchar(35) NOT NULL default 'current',
  endMonth varchar(35) NOT NULL default 'after12',
  defaultMonth varchar(35) NOT NULL default 'current',
  eventTemplateId varchar(22) default NULL,
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
  EventsCalendar_eventId varchar(22) NOT NULL default '',
  wobjectId varchar(22) default NULL,
  name varchar(255) default NULL,
  description text,
  startDate int(11) default NULL,
  endDate int(11) default NULL,
  EventsCalendar_recurringId varchar(22) default NULL,
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
  wobjectId char(22) NOT NULL default '',
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
  FileManager_fileId varchar(22) NOT NULL default '',
  wobjectId varchar(22) default NULL,
  fileTitle varchar(128) NOT NULL default 'untitled',
  downloadFile varchar(255) default NULL,
  groupToView varchar(22) default NULL,
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
  wobjectId varchar(22) NOT NULL default '',
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
  wobjectId varchar(22) NOT NULL default '',
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
  PRIMARY KEY  (wobjectId)
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
INSERT INTO IndexedSearch_default VALUES ('max_doc_id','36');

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


INSERT INTO IndexedSearch_default_data VALUES (1,1,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (2,2,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (3,2,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (4,2,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (5,3,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (6,4,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (7,5,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (8,6,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (9,6,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (10,7,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (11,7,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (12,7,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (13,7,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (14,7,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (15,8,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (16,8,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (17,8,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (18,9,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (19,9,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (20,10,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (21,10,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (22,11,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (23,11,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (15,12,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (24,12,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (25,12,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (26,12,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (15,13,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (27,13,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (28,13,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (29,14,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (30,14,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (31,14,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (32,15,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (33,15,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (34,15,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (35,15,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (36,16,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (37,16,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (38,17,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (15,17,'\0\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (39,17,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (40,17,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (11,17,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (41,17,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (42,17,'\n\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (43,17,'	\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (24,17,'\0\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (44,17,'\0\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (45,17,'\Z\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (46,17,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (47,17,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (48,17,'\r\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (49,17,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (50,17,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (32,17,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (51,17,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (52,17,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (53,17,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (54,17,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (25,17,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (55,17,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (26,17,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (56,17,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (57,17,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (15,18,'\0\0\0\0\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (11,18,'\"\0\0\0&\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (27,18,'\0\0\0-\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (58,18,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (59,18,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (60,18,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (61,18,'\0\0\0$\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (62,18,'+\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (49,18,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (32,18,'.\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (63,18,'\n\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (64,18,'0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (65,18,')\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (66,18,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (67,18,'(\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (68,18,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (69,18,'\0\0\0\r\0\0\0 \0\0\0%\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (70,18,'/\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (71,18,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (72,18,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (26,18,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (73,18,'\Z\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (42,18,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (74,18,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (43,18,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (24,18,'\0\0\0*\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (75,18,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (76,18,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (46,18,'\'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (36,18,',\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (28,18,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (77,18,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (78,18,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (79,18,'!\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (80,18,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (30,18,'#\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (81,18,'	\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (82,18,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (83,18,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (84,18,'1\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (15,19,'\0\0\08\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (11,19,'\r\0\0\0\0\0\0\0\0\0.\0\0\04\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (31,19,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (44,19,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (61,19,'0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (35,19,'5\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (49,19,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (85,19,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (32,19,'7\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (86,19,'\0\0\0)\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (69,19,'\0\0\0\0\0\01\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (87,19,'(\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (88,19,'+\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (89,19,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (73,19,'\0\0\0!\0\0\0*\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (90,19,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (29,19,'\0\0\0\0\0\09\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (91,19,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (42,19,',\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (34,19,'6\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (43,19,'-\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (74,19,'	\0\0\0$\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (92,19,'\0\0\0:\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (24,19,'\0\0\0&\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (93,19,'2\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (94,19,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (28,19,'\0\0\0/\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (95,19,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (96,19,' \0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (97,19,'%\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (79,19,'\0\0\03\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (98,19,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (99,19,'\'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (51,19,'#\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (30,19,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (100,19,'\"\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (101,19,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (102,19,'\n\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (103,19,'\0\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (104,19,'\Z\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (15,20,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (105,20,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (11,20,'\0\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (106,20,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (107,20,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (35,20,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (108,20,'\r\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (49,20,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (109,20,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (12,20,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (32,20,'\0\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (110,20,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (111,20,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (69,20,'!\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (90,20,' \0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (42,20,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (13,20,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (34,20,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (112,20,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (113,20,'\"\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (24,20,'\0\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (94,20,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (114,20,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (115,20,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (116,20,'\n\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (33,20,'\0\0\0	\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (117,20,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (118,20,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (119,20,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (104,20,'\Z\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (15,21,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (11,21,'\n\0\0\0\0\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (120,21,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (121,21,'\0\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (44,21,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (122,21,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (49,21,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (71,21,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (73,21,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (123,21,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (124,21,'\Z\0\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (125,21,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (37,21,'\0\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (126,21,'\0\0\0\r\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (75,21,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (28,21,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (36,21,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (114,21,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (127,21,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (128,21,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (129,21,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (130,21,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (131,21,'	\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (132,21,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (133,21,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (15,22,'\0\0\0\0\0\0+\0\0\03\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (11,22,'\0\0\0\"\0\0\0&\0\0\0.\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (2,22,'\0\0\0\0\0\05\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (59,22,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (3,22,'\0\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (134,22,'!\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (20,22,'\0\0\0-\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (121,22,'\0\0\0*\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (135,22,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (136,22,'\n\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (137,22,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (138,22,'0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (139,22,'\Z\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (62,22,'\0\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (140,22,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (12,22,'%\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (32,22,'	\0\0\0)\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (141,22,'\'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (55,22,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (142,22,'1\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (91,22,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (42,22,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (143,22,'$\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (74,22,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (4,22,'\0\0\0\r\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (144,22,'2\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (76,22,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (1,22,'4\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (115,22,'#\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (80,22,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (127,22,'\0\0\0(\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (145,22,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (129,22,'/\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (146,22,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (21,22,'\0\0\0 \0\0\0,\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (147,22,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (148,23,'V\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (149,23,'9\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (150,23,'7\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (121,23,'U\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (151,23,'!\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (139,23,'E\0\0\0W\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (152,23,'P\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (153,23,'I\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (154,23,'<\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (69,23,'\0\0\0\n\0\0\0>\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (71,23,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (155,23,'Q\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (156,23,'8\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (89,23,'G\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (157,23,'#\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (73,23,'2\0\0\0;\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (158,23,'\0\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (159,23,'M\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (160,23,'1\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (161,23,'@\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (91,23,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (42,23,'*\0\0\00\0\0\0F\0\0\0H\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (4,23,'L\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (162,23,'D\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (43,23,'?\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (74,23,'\0\0\0\0\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (163,23,'\0\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (24,23,'\0\0\0\0\0\0\0\0\0&\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (164,23,'$\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (165,23,'4\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (166,23,',\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (80,23,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (129,23,'J\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (167,23,'=\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (101,23,'+\0\0\03\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (168,23,'	\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (169,23,'C\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (170,23,' \0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (21,23,'\0\0\0R\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (171,23,'5\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (172,23,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (15,23,'\0\0\0(\0\0\0A\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (173,23,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (174,23,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (175,23,'O\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (176,23,'\0\0\0\"\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (62,23,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (32,23,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (177,23,'%\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (66,23,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (55,23,'\Z\0\0\0K\0\0\0T\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (178,23,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (179,23,'6\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (180,23,')\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (181,23,'/\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (182,23,'\'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (183,23,'B\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (184,23,'.\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (75,23,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (185,23,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (50,23,'\r\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (186,23,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (102,23,'-\0\0\0N\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (187,23,':\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (188,23,'S\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (189,24,'Ï\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (190,24,'\0\0');
INSERT INTO IndexedSearch_default_data VALUES (11,24,'\0\0\0\0\0\0!\0\0\0$\0\0\0.\0\0\03\0\0\0=\0\0\0X\0\0\0û\0\0\0Î\0\0\0˚\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (191,24,'O\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (134,24,'\n\0\0\0Ñ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (192,24,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (193,24,'u\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (194,24,'\0\0\00\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (195,24,'Õ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (138,24,'|\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (196,24,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (12,24,'\'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (197,24,'7\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (198,24,'õ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (69,24,'\0\0\0\0\0\0H\0\0\0P\0\0\0v\0\0\0è\0\0\0§\0\0\0∏\0\0\0º\0\0\0‡\0\0\0Ô\0\0\0ˆ\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (199,24,'g\0\0\0ø\0\0\0˜\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (155,24,'(\0\0\0B\0\0\0^\0\0\0e\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (200,24,'Œ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (201,24,'p\0\0\0Å\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (202,24,'µ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (73,24,'&\0\0\08\0\0\0\0\0\0ô\0\0\0¿\0\0\0’\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (203,24,'j\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (204,24,'9\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (91,24,'K\0\0\0\n\0\0');
INSERT INTO IndexedSearch_default_data VALUES (42,24,'ì\0\0\0È\0\0\0ı\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (205,24,'\0\0');
INSERT INTO IndexedSearch_default_data VALUES (43,24,'É\0\0\0ë\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (74,24,'`\0\0\0l\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (94,24,'√\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (206,24,'<\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (46,24,'*\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (207,24,'Ë\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (164,24,'I\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (208,24,'C\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (79,24,'‹\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (80,24,'Ö\0\0\0ä\0\0\0∞\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (209,24,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (131,24,'≥\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (129,24,'\0\0\0\0\0\0>\0\0\0Ã\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (210,24,'…\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (211,24,'ó\0\0\0¡\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (212,24,'#\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (213,24,'™\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (214,24,'”\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (215,24,'∫\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (175,24,'N\0\0\0¶\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (216,24,'[\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (217,24,',\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (218,24,'‰\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (45,24,'1\0\0\0\\\0\0\0ç\0\0\0π\0\0\0æ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (176,24,'À\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (219,24,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (220,24,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (221,24,'‚\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (141,24,'/\0\0\0Y\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (222,24,'2\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (66,24,'⁄\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (223,24,'é\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (224,24,'˝\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (225,24,'\0\0\0L\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (226,24,'W\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (227,24,'o\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (228,24,'Ç\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (229,24,' \0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (230,24,'©\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (231,24,'F\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (232,24,'°\0\0\0◊\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (233,24,'ˇ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (234,24,'a\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (115,24,'4\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (235,24,'ﬂ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (102,24,'k\0\0\0•\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (236,24,'f\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (186,24,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (237,24,'-\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (238,24,'à\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (239,24,'ÿ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (105,24,'\"\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (240,24,'\0\0\0)\0\0\0_\0\0\0¢\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (59,24,'{\0\0\0ê\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (148,24,' \0\0\0M\0\0\0t\0\0\0å\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (3,24,'Z\0\0\0Ä\0\0\0Ü\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (241,24,'˙\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (44,24,'x\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (242,24,'b\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (243,24,'Ø\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (71,24,'ﬁ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (70,24,'¨\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (89,24,'m\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (90,24,'\0\0\0A\0\0\0ã\0\0\0£\0\0\0∑\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (244,24,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (245,24,'q\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (246,24,'	\0\0');
INSERT INTO IndexedSearch_default_data VALUES (247,24,'s\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (248,24,'ñ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (112,24,'·\0\0\0„\0\0\0Ú\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (249,24,'?\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (250,24,'–\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (126,24,'€\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (163,24,'\0\0\0\0\0\0D\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (251,24,'î\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (24,24,'\0\0\06\0\0\0T\0\0\0ú\0\0\0®\0\0\0´\0\0\0≤\0\0\0∆\0\0\0Á\0\0\0Ì\0\0\0¸\0\0\0\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (252,24,'Ê\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (253,24,'≠\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (52,24,':\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (254,24,'h\0\0\0w\0\0\0ü\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (255,24,'z\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (21,24,'\0\0\0∂\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (256,24,'n\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (257,24,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (258,24,'‘\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (259,24,'«\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (172,24,'Û\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (15,24,'V\0\0\0r\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (260,24,'\0\0\0E\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (120,24,'5\0\0\0S\0\0\0ß\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (261,24,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (262,24,'i\0\0\0†\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (263,24,'á\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (135,24,'c\0\0\0Æ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (264,24,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (265,24,'\0\0');
INSERT INTO IndexedSearch_default_data VALUES (266,24,'˛\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (62,24,'˘\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (108,24,'Ò\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (267,24,'Q\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (268,24,'Ω\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (269,24,'\Z\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (32,24,'“\0\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (270,24,']\0\0\0d\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (271,24,'≈\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (272,24,'G\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (72,24,'@\0\0\0Í\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (55,24,'Â\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (273,24,'ö\0\0\0÷\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (274,24,'œ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (275,24,'±\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (276,24,'R\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (277,24,'Ù\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (278,24,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (279,24,'ª\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (280,24,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (281,24,';\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (184,24,'%\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (282,24,'Ÿ\0\0\0¯\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (37,24,'+\0\0\0U\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (283,24,'~\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (284,24,'ï\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (75,24,'›\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (185,24,'	\0\0\0\r\0\0\0â\0\0\0Ó\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (76,24,'}\0\0\0ƒ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (95,24,'ò\0\0\0ù\0\0\0¬\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (285,24,'y\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (286,24,'J\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (287,24,'\0\0');
INSERT INTO IndexedSearch_default_data VALUES (288,24,'»\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (289,24,'—\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (290,24,'¥\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (291,24,'í\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (189,25,'s\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (292,25,'0\0\0\0L\0\0\0ô\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (11,25,'\0\0\0\0\0\0$\0\0\0G\0\0\0Y\0\0\0_\0\0\0p\0\0\0\0\0\0ä\0\0\0ú\0\0\0•\0\0\0π\0\0\0…\0\0\0È\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (293,25,'v\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (294,25,'¡\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (134,25,'\0\0\0Ë\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (295,25,'<\0\0\0c\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (296,25,'ö\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (195,25,'J\0\0\0r\0\0\0·\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (85,25,'%\0\0\0ã\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (297,25,'§\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (69,25,'\0\0\0◊\0\0\0›\0\0\0Á\0\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (199,25,'∂\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (155,25,'!\0\0\0b\0\0\0n\0\0\0ó\0\0\0û\0\0\0™\0\0\0Œ\0\0\0Ó\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (73,25,'\0\0\0k\0\0\0ê\0\0\0º\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (298,25,'1\0\0\0M\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (299,25,'/\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (300,25,'„\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (301,25,'|\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (42,25,'T\0\0\0€\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (302,25,'ª\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (43,25,'ì\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (303,25,'ë\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (74,25,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (206,25,'Â\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (94,25,'I\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (304,25,'l\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (80,25,'	\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (129,25,'h\0\0\0Ä\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (305,25,'5\0\0\0>\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (306,25,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (307,25,'\r\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (213,25,'y\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (175,25,'e\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (308,25,'⁄\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (309,25,'A\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (310,25,'-\0\0\0^\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (311,25,'q\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (312,25,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (313,25,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (45,25,'\Z\0\0\0)\0\0\09\0\0\0[\0\0\0j\0\0\0}\0\0\0Ç\0\0\0ñ\0\0\0Õ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (49,25,';\0\0\0Ö\0\0\0√\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (314,25,'Ì\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (315,25,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (141,25,'\0\0\0Z\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (316,25,'C\0\0\0{\0\0\0µ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (317,25,'è\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (29,25,'‰\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (224,25,'°\0\0\0¶\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (318,25,'Í\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (319,25,'«\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (320,25,'\n\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (28,25,'3\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (321,25,'∫\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (322,25,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (9,25,'\0\0\0Ÿ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (323,25,'F\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (324,25,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (325,25,'≠\0\0\0ø\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (82,25,'‡\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (103,25,'*\0\0\0\\\0\0\0¨\0\0\0Æ\0\0\0æ\0\0\0¿\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (326,25,'P\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (8,25,'\0\0\04\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (6,25,'≥\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (240,25,'¢\0\0\0®\0\0\0∞\0\0\0Ã\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (3,25,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (148,25,'\0\0\0X\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (327,25,'ÿ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (121,25,'E\0\0\0í\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (61,25,'‹\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (109,25,'Ï\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (328,25,'a\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (152,25,'â\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (329,25,':\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (330,25,'‚\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (71,25,'ﬂ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (70,25,'f\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (331,25,'S\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (89,25,'à\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (90,25,' \0\0\0m\0\0\0z\0\0\0É\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (332,25,'ï\0\0\0´\0\0\0œ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (159,25,'6\0\0\0?\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (13,25,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (333,25,'Î\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (334,25,'~\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (335,25,'\0\0\0#\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (336,25,'ç\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (24,25,'\0\0\0\'\0\0\02\0\0\07\0\0\0@\0\0\0t\0\0\0©\0\0\0’\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (337,25,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (144,25,'±\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (338,25,'u\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (339,25,'.\0\0\0w\0\0\0Ü\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (340,25,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (167,25,'N\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (341,25,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (342,25,'é\0\0\0∆\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (21,25,'o\0\0\0ò\0\0\0ü\0\0\0Ò\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (343,25,'W\0\0\0å\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (259,25,'—\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (15,25,'\0\0\0+\0\0\0B\0\0\0O\0\0\0R\0\0\0]\0\0\0Ñ\0\0\0î\0\0\0†\0\0\0≤\0\0\0¥\0\0\0≈\0\0\0À\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (173,25,'K\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (2,25,'V\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (344,25,'Ø\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (120,25,'&\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (263,25,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (122,25,'∏\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (136,25,'H\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (345,25,'Ω\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (264,25,'D\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (346,25,'”\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (266,25,'\"\0\0\0ß\0\0\0Ô\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (62,25,'\0\0\0U\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (108,25,'d\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (270,25,'‘\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (32,25,'x\0\0\0á\0\0\0–\0\0\0Ê\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (347,25,'g\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (348,25,',\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (273,25,'¬\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (34,25,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (349,25,'=\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (75,25,'ﬁ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (95,25,'õ\0\0\0»\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (14,25,'`\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (77,25,'Q\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (350,25,'(\0\0\08\0\0\0i\0\0\0Å\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (351,25,'“\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (352,25,'£\0\0\0∑\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (353,25,' \0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (289,25,'ƒ\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (354,25,'ù\0\0\0÷\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (11,26,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (355,26,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (356,26,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (69,26,'\0\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (155,26,'\0\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (73,26,'	\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (204,26,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (129,26,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (10,26,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (45,26,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (357,26,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (24,26,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (358,26,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (359,26,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (259,26,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (15,26,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (360,26,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (346,26,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (270,26,'\n\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (88,26,'\r\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (361,26,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (69,27,'\r\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (73,27,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (74,27,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (128,27,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (16,27,'\0\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (17,27,'\0\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (362,27,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (71,27,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (144,27,'	\0\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (363,27,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (21,27,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (15,27,'\0\0\0\0\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (62,27,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (364,27,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (75,27,'\n\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (69,28,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (19,28,'\0\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (18,28,'\0\0\0\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (346,28,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (20,29,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (21,29,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (365,30,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (155,30,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (366,30,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (365,31,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (155,31,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (366,31,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (367,31,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (368,32,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (369,33,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (370,34,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (371,35,'\0\0\0');
INSERT INTO IndexedSearch_default_data VALUES (324,36,'\0\0\0');

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


INSERT INTO IndexedSearch_default_words VALUES ('home',1);
INSERT INTO IndexedSearch_default_words VALUES ('page',2);
INSERT INTO IndexedSearch_default_words VALUES ('not',3);
INSERT INTO IndexedSearch_default_words VALUES ('found',4);
INSERT INTO IndexedSearch_default_words VALUES ('trash',5);
INSERT INTO IndexedSearch_default_words VALUES ('clipboard',6);
INSERT INTO IndexedSearch_default_words VALUES ('packages',7);
INSERT INTO IndexedSearch_default_words VALUES ('started',8);
INSERT INTO IndexedSearch_default_words VALUES ('getting',9);
INSERT INTO IndexedSearch_default_words VALUES ('next',10);
INSERT INTO IndexedSearch_default_words VALUES ('you',11);
INSERT INTO IndexedSearch_default_words VALUES ('what',12);
INSERT INTO IndexedSearch_default_words VALUES ('do',13);
INSERT INTO IndexedSearch_default_words VALUES ('should',14);
INSERT INTO IndexedSearch_default_words VALUES ('the',15);
INSERT INTO IndexedSearch_default_words VALUES ('latest',16);
INSERT INTO IndexedSearch_default_words VALUES ('news',17);
INSERT INTO IndexedSearch_default_words VALUES ('friend',18);
INSERT INTO IndexedSearch_default_words VALUES ('tell',19);
INSERT INTO IndexedSearch_default_words VALUES ('map',20);
INSERT INTO IndexedSearch_default_words VALUES ('site',21);
INSERT INTO IndexedSearch_default_words VALUES ('root',22);
INSERT INTO IndexedSearch_default_words VALUES ('nameless',23);
INSERT INTO IndexedSearch_default_words VALUES ('to',24);
INSERT INTO IndexedSearch_default_words VALUES ('talk',25);
INSERT INTO IndexedSearch_default_words VALUES ('experts',26);
INSERT INTO IndexedSearch_default_words VALUES ('manual',27);
INSERT INTO IndexedSearch_default_words VALUES ('get',28);
INSERT INTO IndexedSearch_default_words VALUES ('support',29);
INSERT INTO IndexedSearch_default_words VALUES ('purchase',30);
INSERT INTO IndexedSearch_default_words VALUES ('technical',31);
INSERT INTO IndexedSearch_default_words VALUES ('for',32);
INSERT INTO IndexedSearch_default_words VALUES ('hosting',33);
INSERT INTO IndexedSearch_default_words VALUES ('up',34);
INSERT INTO IndexedSearch_default_words VALUES ('sign',35);
INSERT INTO IndexedSearch_default_words VALUES ('great',36);
INSERT INTO IndexedSearch_default_words VALUES ('look',37);
INSERT INTO IndexedSearch_default_words VALUES ('assist',38);
INSERT INTO IndexedSearch_default_words VALUES ('way',39);
INSERT INTO IndexedSearch_default_words VALUES ('website',40);
INSERT INTO IndexedSearch_default_words VALUES ('reaching',41);
INSERT INTO IndexedSearch_default_words VALUES ('of',42);
INSERT INTO IndexedSearch_default_words VALUES ('all',43);
INSERT INTO IndexedSearch_default_words VALUES ('our',44);
INSERT INTO IndexedSearch_default_words VALUES ('in',45);
INSERT INTO IndexedSearch_default_words VALUES ('will',46);
INSERT INTO IndexedSearch_default_words VALUES ('us',47);
INSERT INTO IndexedSearch_default_words VALUES ('methods',48);
INSERT INTO IndexedSearch_default_words VALUES ('admin',49);
INSERT INTO IndexedSearch_default_words VALUES ('friendly',50);
INSERT INTO IndexedSearch_default_words VALUES ('staff',51);
INSERT INTO IndexedSearch_default_words VALUES ('any',52);
INSERT INTO IndexedSearch_default_words VALUES ('contains',53);
INSERT INTO IndexedSearch_default_words VALUES ('different',54);
INSERT INTO IndexedSearch_default_words VALUES ('be',55);
INSERT INTO IndexedSearch_default_words VALUES ('possible',56);
INSERT INTO IndexedSearch_default_words VALUES ('happy',57);
INSERT INTO IndexedSearch_default_words VALUES ('almost',58);
INSERT INTO IndexedSearch_default_words VALUES ('has',59);
INSERT INTO IndexedSearch_default_words VALUES ('covers',60);
INSERT INTO IndexedSearch_default_words VALUES ('ruling',61);
INSERT INTO IndexedSearch_default_words VALUES ('this',62);
INSERT INTO IndexedSearch_default_words VALUES ('guide',63);
INSERT INTO IndexedSearch_default_words VALUES ('full',64);
INSERT INTO IndexedSearch_default_words VALUES ('updates',65);
INSERT INTO IndexedSearch_default_words VALUES ('by',66);
INSERT INTO IndexedSearch_default_words VALUES ('receive',67);
INSERT INTO IndexedSearch_default_words VALUES ('related',68);
INSERT INTO IndexedSearch_default_words VALUES ('webgui',69);
INSERT INTO IndexedSearch_default_words VALUES ('one',70);
INSERT INTO IndexedSearch_default_words VALUES ('black',71);
INSERT INTO IndexedSearch_default_words VALUES ('everything',72);
INSERT INTO IndexedSearch_default_words VALUES ('and',73);
INSERT INTO IndexedSearch_default_words VALUES ('is',74);
INSERT INTO IndexedSearch_default_words VALUES ('plain',75);
INSERT INTO IndexedSearch_default_words VALUES ('been',76);
INSERT INTO IndexedSearch_default_words VALUES ('at',77);
INSERT INTO IndexedSearch_default_words VALUES ('aspects',78);
INSERT INTO IndexedSearch_default_words VALUES ('when',79);
INSERT INTO IndexedSearch_default_words VALUES ('it',80);
INSERT INTO IndexedSearch_default_words VALUES ('definitive',81);
INSERT INTO IndexedSearch_default_words VALUES ('software',82);
INSERT INTO IndexedSearch_default_words VALUES ('compiled',83);
INSERT INTO IndexedSearch_default_words VALUES ('year',84);
INSERT INTO IndexedSearch_default_words VALUES ('ll',85);
INSERT INTO IndexedSearch_default_words VALUES ('questions',86);
INSERT INTO IndexedSearch_default_words VALUES ('those',87);
INSERT INTO IndexedSearch_default_words VALUES ('best',88);
INSERT INTO IndexedSearch_default_words VALUES ('some',89);
INSERT INTO IndexedSearch_default_words VALUES ('with',90);
INSERT INTO IndexedSearch_default_words VALUES ('system',91);
INSERT INTO IndexedSearch_default_words VALUES ('center',92);
INSERT INTO IndexedSearch_default_words VALUES ('free',93);
INSERT INTO IndexedSearch_default_words VALUES ('have',94);
INSERT INTO IndexedSearch_default_words VALUES ('help',95);
INSERT INTO IndexedSearch_default_words VALUES ('courteous',96);
INSERT INTO IndexedSearch_default_words VALUES ('available',97);
INSERT INTO IndexedSearch_default_words VALUES ('stuck',98);
INSERT INTO IndexedSearch_default_words VALUES ('answer',99);
INSERT INTO IndexedSearch_default_words VALUES ('knowlegable',100);
INSERT INTO IndexedSearch_default_words VALUES ('large',101);
INSERT INTO IndexedSearch_default_words VALUES ('there',102);
INSERT INTO IndexedSearch_default_words VALUES ('as',103);
INSERT INTO IndexedSearch_default_words VALUES ('likely',104);
INSERT INTO IndexedSearch_default_words VALUES ('know',105);
INSERT INTO IndexedSearch_default_words VALUES ('who',106);
INSERT INTO IndexedSearch_default_words VALUES ('won',107);
INSERT INTO IndexedSearch_default_words VALUES ('so',108);
INSERT INTO IndexedSearch_default_words VALUES ('trouble',109);
INSERT INTO IndexedSearch_default_words VALUES ('finding',110);
INSERT INTO IndexedSearch_default_words VALUES ('hoster',111);
INSERT INTO IndexedSearch_default_words VALUES ('we',112);
INSERT INTO IndexedSearch_default_words VALUES ('anyway',113);
INSERT INTO IndexedSearch_default_words VALUES ('professional',114);
INSERT INTO IndexedSearch_default_words VALUES ('don',115);
INSERT INTO IndexedSearch_default_words VALUES ('services',116);
INSERT INTO IndexedSearch_default_words VALUES ('go',117);
INSERT INTO IndexedSearch_default_words VALUES ('through',118);
INSERT INTO IndexedSearch_default_words VALUES ('provide',119);
INSERT INTO IndexedSearch_default_words VALUES ('need',120);
INSERT INTO IndexedSearch_default_words VALUES ('on',121);
INSERT INTO IndexedSearch_default_words VALUES ('let',122);
INSERT INTO IndexedSearch_default_words VALUES ('team',123);
INSERT INTO IndexedSearch_default_words VALUES ('time',124);
INSERT INTO IndexedSearch_default_words VALUES ('budget',125);
INSERT INTO IndexedSearch_default_words VALUES ('design',126);
INSERT INTO IndexedSearch_default_words VALUES ('looking',127);
INSERT INTO IndexedSearch_default_words VALUES ('every',128);
INSERT INTO IndexedSearch_default_words VALUES ('can',129);
INSERT INTO IndexedSearch_default_words VALUES ('award',130);
INSERT INTO IndexedSearch_default_words VALUES ('build',131);
INSERT INTO IndexedSearch_default_words VALUES ('winning',132);
INSERT INTO IndexedSearch_default_words VALUES ('designers',133);
INSERT INTO IndexedSearch_default_words VALUES ('if',134);
INSERT INTO IndexedSearch_default_words VALUES ('or',135);
INSERT INTO IndexedSearch_default_words VALUES ('could',136);
INSERT INTO IndexedSearch_default_words VALUES ('following',137);
INSERT INTO IndexedSearch_default_words VALUES ('always',138);
INSERT INTO IndexedSearch_default_words VALUES ('list',139);
INSERT INTO IndexedSearch_default_words VALUES ('renamed',140);
INSERT INTO IndexedSearch_default_words VALUES ('re',141);
INSERT INTO IndexedSearch_default_words VALUES ('start',142);
INSERT INTO IndexedSearch_default_words VALUES ('find',143);
INSERT INTO IndexedSearch_default_words VALUES ('from',144);
INSERT INTO IndexedSearch_default_words VALUES ('deleted',145);
INSERT INTO IndexedSearch_default_words VALUES ('perhaps',146);
INSERT INTO IndexedSearch_default_words VALUES ('were',147);
INSERT INTO IndexedSearch_default_words VALUES ('that',148);
INSERT INTO IndexedSearch_default_words VALUES ('projects',149);
INSERT INTO IndexedSearch_default_words VALUES ('governments',150);
INSERT INTO IndexedSearch_default_words VALUES ('business',151);
INSERT INTO IndexedSearch_default_words VALUES ('reason',152);
INSERT INTO IndexedSearch_default_words VALUES ('them',153);
INSERT INTO IndexedSearch_default_words VALUES ('individuals',154);
INSERT INTO IndexedSearch_default_words VALUES ('your',155);
INSERT INTO IndexedSearch_default_words VALUES ('clubs',156);
INSERT INTO IndexedSearch_default_words VALUES ('but',157);
INSERT INTO IndexedSearch_default_words VALUES ('welcome',158);
INSERT INTO IndexedSearch_default_words VALUES ('here',159);
INSERT INTO IndexedSearch_default_words VALUES ('small',160);
INSERT INTO IndexedSearch_default_words VALUES ('over',161);
INSERT INTO IndexedSearch_default_words VALUES ('brief',162);
INSERT INTO IndexedSearch_default_words VALUES ('web',163);
INSERT INTO IndexedSearch_default_words VALUES ('powerful',164);
INSERT INTO IndexedSearch_default_words VALUES ('businesses',165);
INSERT INTO IndexedSearch_default_words VALUES ('enterprise',166);
INSERT INTO IndexedSearch_default_words VALUES ('using',167);
INSERT INTO IndexedSearch_default_words VALUES ('right',168);
INSERT INTO IndexedSearch_default_words VALUES ('today',169);
INSERT INTO IndexedSearch_default_words VALUES ('average',170);
INSERT INTO IndexedSearch_default_words VALUES ('schools',171);
INSERT INTO IndexedSearch_default_words VALUES ('made',172);
INSERT INTO IndexedSearch_default_words VALUES ('done',173);
INSERT INTO IndexedSearch_default_words VALUES ('designed',174);
INSERT INTO IndexedSearch_default_words VALUES ('no',175);
INSERT INTO IndexedSearch_default_words VALUES ('user',176);
INSERT INTO IndexedSearch_default_words VALUES ('enough',177);
INSERT INTO IndexedSearch_default_words VALUES ('management',178);
INSERT INTO IndexedSearch_default_words VALUES ('universities',179);
INSERT INTO IndexedSearch_default_words VALUES ('needs',180);
INSERT INTO IndexedSearch_default_words VALUES ('thousands',181);
INSERT INTO IndexedSearch_default_words VALUES ('satisfy',182);
INSERT INTO IndexedSearch_default_words VALUES ('world',183);
INSERT INTO IndexedSearch_default_words VALUES ('are',184);
INSERT INTO IndexedSearch_default_words VALUES ('use',185);
INSERT INTO IndexedSearch_default_words VALUES ('easy',186);
INSERT INTO IndexedSearch_default_words VALUES ('communities',187);
INSERT INTO IndexedSearch_default_words VALUES ('shouldn',188);
INSERT INTO IndexedSearch_default_words VALUES ('want',189);
INSERT INTO IndexedSearch_default_words VALUES ('fuss',190);
INSERT INTO IndexedSearch_default_words VALUES ('two',191);
INSERT INTO IndexedSearch_default_words VALUES ('key',192);
INSERT INTO IndexedSearch_default_words VALUES ('makes',193);
INSERT INTO IndexedSearch_default_words VALUES ('editing',194);
INSERT INTO IndexedSearch_default_words VALUES ('also',195);
INSERT INTO IndexedSearch_default_words VALUES ('unique',196);
INSERT INTO IndexedSearch_default_words VALUES ('install',197);
INSERT INTO IndexedSearch_default_words VALUES ('aids',198);
INSERT INTO IndexedSearch_default_words VALUES ('functions',199);
INSERT INTO IndexedSearch_default_words VALUES ('adjust',200);
INSERT INTO IndexedSearch_default_words VALUES ('technology',201);
INSERT INTO IndexedSearch_default_words VALUES ('lingual',202);
INSERT INTO IndexedSearch_default_words VALUES ('though',203);
INSERT INTO IndexedSearch_default_words VALUES ('learn',204);
INSERT INTO IndexedSearch_default_words VALUES ('still',205);
INSERT INTO IndexedSearch_default_words VALUES ('programs',206);
INSERT INTO IndexedSearch_default_words VALUES ('think',207);
INSERT INTO IndexedSearch_default_words VALUES ('trusty',208);
INSERT INTO IndexedSearch_default_words VALUES ('bold',209);
INSERT INTO IndexedSearch_default_words VALUES ('15',210);
INSERT INTO IndexedSearch_default_words VALUES ('online',211);
INSERT INTO IndexedSearch_default_words VALUES ('where',212);
INSERT INTO IndexedSearch_default_words VALUES ('yourself',213);
INSERT INTO IndexedSearch_default_words VALUES ('dates',214);
INSERT INTO IndexedSearch_default_words VALUES ('fact',215);
INSERT INTO IndexedSearch_default_words VALUES ('restricted',216);
INSERT INTO IndexedSearch_default_words VALUES ('like',217);
INSERT INTO IndexedSearch_default_words VALUES ('wouldn',218);
INSERT INTO IndexedSearch_default_words VALUES ('weight',219);
INSERT INTO IndexedSearch_default_words VALUES ('inline',220);
INSERT INTO IndexedSearch_default_words VALUES ('knew',221);
INSERT INTO IndexedSearch_default_words VALUES ('addition',222);
INSERT INTO IndexedSearch_default_words VALUES ('mind',223);
INSERT INTO IndexedSearch_default_words VALUES ('add',224);
INSERT INTO IndexedSearch_default_words VALUES ('ensures',225);
INSERT INTO IndexedSearch_default_words VALUES ('same',226);
INSERT INTO IndexedSearch_default_words VALUES ('cool',227);
INSERT INTO IndexedSearch_default_words VALUES ('after',228);
INSERT INTO IndexedSearch_default_words VALUES ('languages',229);
INSERT INTO IndexedSearch_default_words VALUES ('limit',230);
INSERT INTO IndexedSearch_default_words VALUES ('flexible',231);
INSERT INTO IndexedSearch_default_words VALUES ('localized',232);
INSERT INTO IndexedSearch_default_words VALUES ('features',233);
INSERT INTO IndexedSearch_default_words VALUES ('laid',234);
INSERT INTO IndexedSearch_default_words VALUES ('created',235);
INSERT INTO IndexedSearch_default_words VALUES ('navigation',236);
INSERT INTO IndexedSearch_default_words VALUES ('while',237);
INSERT INTO IndexedSearch_default_words VALUES ('why',238);
INSERT INTO IndexedSearch_default_words VALUES ('oddities',239);
INSERT INTO IndexedSearch_default_words VALUES ('content',240);
INSERT INTO IndexedSearch_default_words VALUES ('allows',241);
INSERT INTO IndexedSearch_default_words VALUES ('out',242);
INSERT INTO IndexedSearch_default_words VALUES ('timezone',243);
INSERT INTO IndexedSearch_default_words VALUES ('manage',244);
INSERT INTO IndexedSearch_default_words VALUES ('behind',245);
INSERT INTO IndexedSearch_default_words VALUES ('core',246);
INSERT INTO IndexedSearch_default_words VALUES ('scenes',247);
INSERT INTO IndexedSearch_default_words VALUES ('cuts',248);
INSERT INTO IndexedSearch_default_words VALUES ('edit',249);
INSERT INTO IndexedSearch_default_words VALUES ('local',250);
INSERT INTO IndexedSearch_default_words VALUES ('wizards',251);
INSERT INTO IndexedSearch_default_words VALUES ('able',252);
INSERT INTO IndexedSearch_default_words VALUES ('language',253);
INSERT INTO IndexedSearch_default_words VALUES ('work',254);
INSERT INTO IndexedSearch_default_words VALUES ('concern',255);
INSERT INTO IndexedSearch_default_words VALUES ('pretty',256);
INSERT INTO IndexedSearch_default_words VALUES ('then',257);
INSERT INTO IndexedSearch_default_words VALUES ('times',258);
INSERT INTO IndexedSearch_default_words VALUES ('more',259);
INSERT INTO IndexedSearch_default_words VALUES ('browser',260);
INSERT INTO IndexedSearch_default_words VALUES ('font',261);
INSERT INTO IndexedSearch_default_words VALUES ('faster',262);
INSERT INTO IndexedSearch_default_words VALUES ('useful',263);
INSERT INTO IndexedSearch_default_words VALUES ('interface',264);
INSERT INTO IndexedSearch_default_words VALUES ('upgrade',265);
INSERT INTO IndexedSearch_default_words VALUES ('new',266);
INSERT INTO IndexedSearch_default_words VALUES ('sites',267);
INSERT INTO IndexedSearch_default_words VALUES ('built',268);
INSERT INTO IndexedSearch_default_words VALUES ('wysiwyg',269);
INSERT INTO IndexedSearch_default_words VALUES ('how',270);
INSERT INTO IndexedSearch_default_words VALUES ('translated',271);
INSERT INTO IndexedSearch_default_words VALUES ('designs',272);
INSERT INTO IndexedSearch_default_words VALUES ('other',273);
INSERT INTO IndexedSearch_default_words VALUES ('their',274);
INSERT INTO IndexedSearch_default_words VALUES ('snap',275);
INSERT INTO IndexedSearch_default_words VALUES ('ever',276);
INSERT INTO IndexedSearch_default_words VALUES ('most',277);
INSERT INTO IndexedSearch_default_words VALUES ('benefits',278);
INSERT INTO IndexedSearch_default_words VALUES ('even',279);
INSERT INTO IndexedSearch_default_words VALUES ('dt',280);
INSERT INTO IndexedSearch_default_words VALUES ('complicated',281);
INSERT INTO IndexedSearch_default_words VALUES ('pluggable',282);
INSERT INTO IndexedSearch_default_words VALUES ('usability',283);
INSERT INTO IndexedSearch_default_words VALUES ('short',284);
INSERT INTO IndexedSearch_default_words VALUES ('first',285);
INSERT INTO IndexedSearch_default_words VALUES ('templating',286);
INSERT INTO IndexedSearch_default_words VALUES ('without',287);
INSERT INTO IndexedSearch_default_words VALUES ('than',288);
INSERT INTO IndexedSearch_default_words VALUES ('settings',289);
INSERT INTO IndexedSearch_default_words VALUES ('multi',290);
INSERT INTO IndexedSearch_default_words VALUES ('kinds',291);
INSERT INTO IndexedSearch_default_words VALUES ('these',292);
INSERT INTO IndexedSearch_default_words VALUES ('another',293);
INSERT INTO IndexedSearch_default_words VALUES ('many',294);
INSERT INTO IndexedSearch_default_words VALUES ('password',295);
INSERT INTO IndexedSearch_default_words VALUES ('controls',296);
INSERT INTO IndexedSearch_default_words VALUES ('lets',297);
INSERT INTO IndexedSearch_default_words VALUES ('steps',298);
INSERT INTO IndexedSearch_default_words VALUES ('follow',299);
INSERT INTO IndexedSearch_default_words VALUES ('several',300);
INSERT INTO IndexedSearch_default_words VALUES ('privileges',301);
INSERT INTO IndexedSearch_default_words VALUES ('users',302);
INSERT INTO IndexedSearch_default_words VALUES ('menus',303);
INSERT INTO IndexedSearch_default_words VALUES ('mess',304);
INSERT INTO IndexedSearch_default_words VALUES ('click',305);
INSERT INTO IndexedSearch_default_words VALUES ('reading',306);
INSERT INTO IndexedSearch_default_words VALUES ('ve',307);
INSERT INTO IndexedSearch_default_words VALUES ('copy',308);
INSERT INTO IndexedSearch_default_words VALUES ('turn',309);
INSERT INTO IndexedSearch_default_words VALUES ('administrator',310);
INSERT INTO IndexedSearch_default_words VALUES ('might',311);
INSERT INTO IndexedSearch_default_words VALUES ('got',312);
INSERT INTO IndexedSearch_default_words VALUES ('order',313);
INSERT INTO IndexedSearch_default_words VALUES ('enjoy',314);
INSERT INTO IndexedSearch_default_words VALUES ('anything',315);
INSERT INTO IndexedSearch_default_words VALUES ('administrative',316);
INSERT INTO IndexedSearch_default_words VALUES ('buttons',317);
INSERT INTO IndexedSearch_default_words VALUES ('run',318);
INSERT INTO IndexedSearch_default_words VALUES ('toolbars',319);
INSERT INTO IndexedSearch_default_words VALUES ('means',320);
INSERT INTO IndexedSearch_default_words VALUES ('control',321);
INSERT INTO IndexedSearch_default_words VALUES ('trivial',322);
INSERT INTO IndexedSearch_default_words VALUES ('note',323);
INSERT INTO IndexedSearch_default_words VALUES ('message',324);
INSERT INTO IndexedSearch_default_words VALUES ('well',325);
INSERT INTO IndexedSearch_default_words VALUES ('block',326);
INSERT INTO IndexedSearch_default_words VALUES ('consider',327);
INSERT INTO IndexedSearch_default_words VALUES ('change',328);
INSERT INTO IndexedSearch_default_words VALUES ('username',329);
INSERT INTO IndexedSearch_default_words VALUES ('provides',330);
INSERT INTO IndexedSearch_default_words VALUES ('top',331);
INSERT INTO IndexedSearch_default_words VALUES ('pages',332);
INSERT INTO IndexedSearch_default_words VALUES ('into',333);
INSERT INTO IndexedSearch_default_words VALUES ('case',334);
INSERT INTO IndexedSearch_default_words VALUES ('installation',335);
INSERT INTO IndexedSearch_default_words VALUES ('notice',336);
INSERT INTO IndexedSearch_default_words VALUES ('good',337);
INSERT INTO IndexedSearch_default_words VALUES ('create',338);
INSERT INTO IndexedSearch_default_words VALUES ('account',339);
INSERT INTO IndexedSearch_default_words VALUES ('running',340);
INSERT INTO IndexedSearch_default_words VALUES ('job',341);
INSERT INTO IndexedSearch_default_words VALUES ('little',342);
INSERT INTO IndexedSearch_default_words VALUES ('now',343);
INSERT INTO IndexedSearch_default_words VALUES ('paste',344);
INSERT INTO IndexedSearch_default_words VALUES ('groups',345);
INSERT INTO IndexedSearch_default_words VALUES ('about',346);
INSERT INTO IndexedSearch_default_words VALUES ('else',347);
INSERT INTO IndexedSearch_default_words VALUES ('default',348);
INSERT INTO IndexedSearch_default_words VALUES ('123qwe',349);
INSERT INTO IndexedSearch_default_words VALUES ('log',350);
INSERT INTO IndexedSearch_default_words VALUES ('information',351);
INSERT INTO IndexedSearch_default_words VALUES ('menu',352);
INSERT INTO IndexedSearch_default_words VALUES ('manipulate',353);
INSERT INTO IndexedSearch_default_words VALUES ('administer',354);
INSERT INTO IndexedSearch_default_words VALUES ('choices',355);
INSERT INTO IndexedSearch_default_words VALUES ('see',356);
INSERT INTO IndexedSearch_default_words VALUES ('please',357);
INSERT INTO IndexedSearch_default_words VALUES ('organization',358);
INSERT INTO IndexedSearch_default_words VALUES ('below',359);
INSERT INTO IndexedSearch_default_words VALUES ('step',360);
INSERT INTO IndexedSearch_default_words VALUES ('implement',361);
INSERT INTO IndexedSearch_default_words VALUES ('hour',362);
INSERT INTO IndexedSearch_default_words VALUES ('directly',363);
INSERT INTO IndexedSearch_default_words VALUES ('pulled',364);
INSERT INTO IndexedSearch_default_words VALUES ('email',365);
INSERT INTO IndexedSearch_default_words VALUES ('address',366);
INSERT INTO IndexedSearch_default_words VALUES ('friends',367);
INSERT INTO IndexedSearch_default_words VALUES ('cc',368);
INSERT INTO IndexedSearch_default_words VALUES ('bcc',369);
INSERT INTO IndexedSearch_default_words VALUES ('subject',370);
INSERT INTO IndexedSearch_default_words VALUES ('url',371);

--
-- Table structure for table `IndexedSearch_docInfo`
--

CREATE TABLE IndexedSearch_docInfo (
  docId int(11) NOT NULL default '0',
  indexName varchar(35) NOT NULL default 'Search_index',
  pageId varchar(22) default NULL,
  wobjectId varchar(22) default NULL,
  page_groupIdView varchar(22) default NULL,
  wobject_groupIdView varchar(22) default NULL,
  wobject_special_groupIdView varchar(22) default NULL,
  languageId varchar(35) default NULL,
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


INSERT INTO IndexedSearch_docInfo VALUES (1,'IndexedSearch_default','1','0','7','7','7','English','Page','home','select title from page where pageId = 1','select synopsis from page where pageId = 1','page','3',1094490005);
INSERT INTO IndexedSearch_docInfo VALUES (2,'IndexedSearch_default','4','0','7','7','7','English','Page','page_not_found','select title from page where pageId = 4','select synopsis from page where pageId = 4','page','3',1094490005);
INSERT INTO IndexedSearch_docInfo VALUES (3,'IndexedSearch_default','3','0','3','7','7','English','Page','trash','select title from page where pageId = 3','select synopsis from page where pageId = 3','page','3',1094490005);
INSERT INTO IndexedSearch_docInfo VALUES (4,'IndexedSearch_default','2','0','4','7','7','English','Page','clipboard','select title from page where pageId = 2','select synopsis from page where pageId = 2','page','3',1094490005);
INSERT INTO IndexedSearch_docInfo VALUES (5,'IndexedSearch_default','5','0','6','7','7','English','Page','packages','select title from page where pageId = 5','select synopsis from page where pageId = 5','page','3',1094490005);
INSERT INTO IndexedSearch_docInfo VALUES (6,'IndexedSearch_default','1000','0','7','7','7','English','Page','getting_started','select title from page where pageId = 1000','select synopsis from page where pageId = 1000','page','3',1094490005);
INSERT INTO IndexedSearch_docInfo VALUES (7,'IndexedSearch_default','1001','0','7','7','7','English','Page','your_next_step','select title from page where pageId = 1001','select synopsis from page where pageId = 1001','page','3',1094490005);
INSERT INTO IndexedSearch_docInfo VALUES (8,'IndexedSearch_default','1002','0','7','7','7','English','Page','the_latest_news','select title from page where pageId = 1002','select synopsis from page where pageId = 1002','page','3',1094490005);
INSERT INTO IndexedSearch_docInfo VALUES (9,'IndexedSearch_default','1003','0','7','7','7','English','Page','tell_a_friend','select title from page where pageId = 1003','select synopsis from page where pageId = 1003','page','3',1094490005);
INSERT INTO IndexedSearch_docInfo VALUES (10,'IndexedSearch_default','1004','0','7','7','7','English','Page','site_map','select title from page where pageId = 1004','select synopsis from page where pageId = 1004','page','3',1094490005);
INSERT INTO IndexedSearch_docInfo VALUES (11,'IndexedSearch_default','0','0','3','7','7','English','Page','nameless_root','select title from page where pageId = 0','select synopsis from page where pageId = 0','page','3',1094490005);
INSERT INTO IndexedSearch_docInfo VALUES (12,'IndexedSearch_default','NOHx0iiGFZq8GBx8pCoPkw','0','7','7','7','English','Page','your_next_step/your_next_step/talk_to_the_experts','select title from page where pageId = NOHx0iiGFZq8GBx8pCoPkw','select synopsis from page where pageId = NOHx0iiGFZq8GBx8pCoPkw','page','3',1094490005);
INSERT INTO IndexedSearch_docInfo VALUES (13,'IndexedSearch_default','cFlWrGVwXV7eJ0Zvcd8p3w','0','7','7','7','English','Page','your_next_step/your_next_step/get_the_manual','select title from page where pageId = cFlWrGVwXV7eJ0Zvcd8p3w','select synopsis from page where pageId = cFlWrGVwXV7eJ0Zvcd8p3w','page','3',1094490005);
INSERT INTO IndexedSearch_docInfo VALUES (14,'IndexedSearch_default','0r2GNyJ5HImgY8xx_tQBZQ','0','7','7','7','English','Page','your_next_step/your_next_step/purchase_technical_support','select title from page where pageId = 0r2GNyJ5HImgY8xx_tQBZQ','select synopsis from page where pageId = 0r2GNyJ5HImgY8xx_tQBZQ','page','3',1094490005);
INSERT INTO IndexedSearch_docInfo VALUES (15,'IndexedSearch_default','uGRHud5vVtKFT1ciQ2OGIg','0','7','7','7','English','Page','your_next_step/your_next_step/sign_up_for_hosting','select title from page where pageId = uGRHud5vVtKFT1ciQ2OGIg','select synopsis from page where pageId = uGRHud5vVtKFT1ciQ2OGIg','page','3',1094490005);
INSERT INTO IndexedSearch_docInfo VALUES (16,'IndexedSearch_default','gvLbaIffuze4HhKFtiCmsw','0','7','7','7','English','Page','your_next_step/your_next_step/look_great','select title from page where pageId = gvLbaIffuze4HhKFtiCmsw','select synopsis from page where pageId = gvLbaIffuze4HhKFtiCmsw','page','3',1094490005);
INSERT INTO IndexedSearch_docInfo VALUES (17,'IndexedSearch_default','1001','5','7','7','7','English','USS','your_next_step?func=viewSubmission&wid=5&sid=1','select title from USS_submission where USS_submissionId = 1','select content from USS_submission where USS_submissionId = 1','wobjectDetail','3',1094490005);
INSERT INTO IndexedSearch_docInfo VALUES (18,'IndexedSearch_default','1001','5','7','7','7','English','USS','your_next_step?func=viewSubmission&wid=5&sid=3','select title from USS_submission where USS_submissionId = 3','select content from USS_submission where USS_submissionId = 3','wobjectDetail','3',1094490005);
INSERT INTO IndexedSearch_docInfo VALUES (19,'IndexedSearch_default','1001','5','7','7','7','English','USS','your_next_step?func=viewSubmission&wid=5&sid=4','select title from USS_submission where USS_submissionId = 4','select content from USS_submission where USS_submissionId = 4','wobjectDetail','3',1094490005);
INSERT INTO IndexedSearch_docInfo VALUES (20,'IndexedSearch_default','1001','5','7','7','7','English','USS','your_next_step?func=viewSubmission&wid=5&sid=5','select title from USS_submission where USS_submissionId = 5','select content from USS_submission where USS_submissionId = 5','wobjectDetail','3',1094490005);
INSERT INTO IndexedSearch_docInfo VALUES (21,'IndexedSearch_default','1001','5','7','7','7','English','USS','your_next_step?func=viewSubmission&wid=5&sid=6','select title from USS_submission where USS_submissionId = 6','select content from USS_submission where USS_submissionId = 6','wobjectDetail','3',1094490005);
INSERT INTO IndexedSearch_docInfo VALUES (22,'IndexedSearch_default','4','-1','7','7','7','English','SiteMap','page_not_found#-1','select title from wobject where wobjectId = -1','select description from wobject where wobjectId = -1','wobject','3',1094490005);
INSERT INTO IndexedSearch_docInfo VALUES (23,'IndexedSearch_default','1','1','7','7','7','English','Article','home#1','select title from wobject where wobjectId = 1','select description from wobject where wobjectId = 1','wobject','3',1094490005);
INSERT INTO IndexedSearch_docInfo VALUES (24,'IndexedSearch_default','1','2','7','7','7','English','Article','home#2','select title from wobject where wobjectId = 2','select description from wobject where wobjectId = 2','wobject','3',1094490005);
INSERT INTO IndexedSearch_docInfo VALUES (25,'IndexedSearch_default','1000','3','7','7','7','English','Article','getting_started#3','select title from wobject where wobjectId = 3','select description from wobject where wobjectId = 3','wobject','3',1094490005);
INSERT INTO IndexedSearch_docInfo VALUES (26,'IndexedSearch_default','1001','5','7','7','7','English','USS','your_next_step#5','select title from wobject where wobjectId = 5','select description from wobject where wobjectId = 5','wobject','3',1094490005);
INSERT INTO IndexedSearch_docInfo VALUES (27,'IndexedSearch_default','1002','6','7','7','7','English','SyndicatedContent','the_latest_news#6','select title from wobject where wobjectId = 6','select description from wobject where wobjectId = 6','wobject','3',1094490005);
INSERT INTO IndexedSearch_docInfo VALUES (28,'IndexedSearch_default','1003','7','7','7','7','English','DataForm','tell_a_friend#7','select title from wobject where wobjectId = 7','select description from wobject where wobjectId = 7','wobject','3',1094490005);
INSERT INTO IndexedSearch_docInfo VALUES (29,'IndexedSearch_default','1004','8','7','7','7','English','SiteMap','site_map#8','select title from wobject where wobjectId = 8','select description from wobject where wobjectId = 8','wobject','3',1094490005);
INSERT INTO IndexedSearch_docInfo VALUES (30,'IndexedSearch_default','1003','7','7','7','7','English','DataForm','tell_a_friend#7','select label from DataForm_field where DataForm_fieldId = \'1000\'','select subtext from DataForm_field where DataForm_fieldId = \'1000\'','wobjectDetail','3',1094490005);
INSERT INTO IndexedSearch_docInfo VALUES (31,'IndexedSearch_default','1003','7','7','7','7','English','DataForm','tell_a_friend#7','select label from DataForm_field where DataForm_fieldId = \'1001\'','select subtext from DataForm_field where DataForm_fieldId = \'1001\'','wobjectDetail','3',1094490005);
INSERT INTO IndexedSearch_docInfo VALUES (32,'IndexedSearch_default','1003','7','7','7','7','English','DataForm','tell_a_friend#7','select label from DataForm_field where DataForm_fieldId = \'1002\'','select subtext from DataForm_field where DataForm_fieldId = \'1002\'','wobjectDetail','3',1094490005);
INSERT INTO IndexedSearch_docInfo VALUES (33,'IndexedSearch_default','1003','7','7','7','7','English','DataForm','tell_a_friend#7','select label from DataForm_field where DataForm_fieldId = \'1003\'','select subtext from DataForm_field where DataForm_fieldId = \'1003\'','wobjectDetail','3',1094490005);
INSERT INTO IndexedSearch_docInfo VALUES (34,'IndexedSearch_default','1003','7','7','7','7','English','DataForm','tell_a_friend#7','select label from DataForm_field where DataForm_fieldId = \'1004\'','select subtext from DataForm_field where DataForm_fieldId = \'1004\'','wobjectDetail','3',1094490005);
INSERT INTO IndexedSearch_docInfo VALUES (35,'IndexedSearch_default','1003','7','7','7','7','English','DataForm','tell_a_friend#7','select label from DataForm_field where DataForm_fieldId = \'1005\'','select subtext from DataForm_field where DataForm_fieldId = \'1005\'','wobjectDetail','3',1094490005);
INSERT INTO IndexedSearch_docInfo VALUES (36,'IndexedSearch_default','1003','7','7','7','7','English','DataForm','tell_a_friend#7','select label from DataForm_field where DataForm_fieldId = \'1006\'','select subtext from DataForm_field where DataForm_fieldId = \'1006\'','wobjectDetail','3',1094490005);

--
-- Table structure for table `MessageBoard`
--

CREATE TABLE MessageBoard (
  wobjectId char(22) NOT NULL default '',
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table `MessageBoard`
--



--
-- Table structure for table `MessageBoard_forums`
--

CREATE TABLE MessageBoard_forums (
  wobjectId varchar(22) default NULL,
  forumId varchar(22) default NULL,
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
  navigationId varchar(22) NOT NULL default '',
  identifier varchar(30) NOT NULL default 'undefined',
  depth int(11) NOT NULL default '99',
  method varchar(35) NOT NULL default 'descendants',
  startAt varchar(35) NOT NULL default 'current',
  stopAtLevel int(11) NOT NULL default '-1',
  templateId varchar(22) default NULL,
  showSystemPages int(11) NOT NULL default '0',
  showHiddenPages int(11) NOT NULL default '0',
  showUnprivilegedPages int(11) NOT NULL default '0',
  reverse int(11) NOT NULL default '0',
  PRIMARY KEY  (navigationId,identifier)
) TYPE=MyISAM;

--
-- Dumping data for table `Navigation`
--


INSERT INTO Navigation VALUES ('1','crumbTrail',99,'self_and_ancestors','current',-1,'2',0,0,0,1);
INSERT INTO Navigation VALUES ('2','FlexMenu',99,'pedigree','current',2,'1',0,0,0,0);
INSERT INTO Navigation VALUES ('3','currentMenuVertical',1,'descendants','current',-1,'1',0,0,0,0);
INSERT INTO Navigation VALUES ('4','currentMenuHorizontal',1,'descendants','current',-1,'3',0,0,0,0);
INSERT INTO Navigation VALUES ('5','PreviousDropMenu',99,'self_and_sisters','current',-1,'4',0,0,0,0);
INSERT INTO Navigation VALUES ('6','previousMenuVertical',1,'descendants','mother',-1,'1',0,0,0,0);
INSERT INTO Navigation VALUES ('7','previousMenuHorizontal',1,'descendants','mother',-1,'3',0,0,0,0);
INSERT INTO Navigation VALUES ('8','rootmenu',1,'daughters','root',-1,'3',0,0,0,0);
INSERT INTO Navigation VALUES ('9','SpecificDropMenu',3,'descendants','home',-1,'4',0,0,0,0);
INSERT INTO Navigation VALUES ('10','SpecificSubMenuVertical',3,'descendants','home',-1,'1',0,0,0,0);
INSERT INTO Navigation VALUES ('11','SpecificSubMenuHorizontal',1,'descendants','home',-1,'3',0,0,0,0);
INSERT INTO Navigation VALUES ('12','TopLevelMenuVertical',1,'descendants','WebGUIroot',-1,'1',0,0,0,0);
INSERT INTO Navigation VALUES ('13','TopLevelMenuHorizontal',1,'descendants','WebGUIroot',-1,'3',0,0,0,0);
INSERT INTO Navigation VALUES ('14','RootTab',99,'daughters','root',-1,'5',0,0,0,0);
INSERT INTO Navigation VALUES ('15','TopDropMenu',1,'decendants','WebGUIroot',-1,'4',0,0,0,0);
INSERT INTO Navigation VALUES ('16','dtree',99,'self_and_descendants','WebGUIroot',-1,'6',0,0,0,0);
INSERT INTO Navigation VALUES ('17','coolmenu',99,'descendants','WebGUIroot',-1,'7',0,0,0,0);
INSERT INTO Navigation VALUES ('18','Synopsis',99,'self_and_descendants','current',-1,'8',0,0,0,0);
INSERT INTO Navigation VALUES ('1000','TopLevelMenuHorizontal_1000',1,'WebGUIroot','WebGUIroot',-1,'1000',0,0,0,0);
INSERT INTO Navigation VALUES ('1001','currentMenuHorizontal_1001',1,'descendants','current',-1,'1001',0,0,0,0);
INSERT INTO Navigation VALUES ('1002','FlexMenu_1002',99,'pedigree','current',2,'1',0,0,0,0);

--
-- Table structure for table `Poll`
--

CREATE TABLE Poll (
  wobjectId varchar(22) NOT NULL default '',
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
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table `Poll`
--



--
-- Table structure for table `Poll_answer`
--

CREATE TABLE Poll_answer (
  wobjectId varchar(22) default NULL,
  answer char(3) default NULL,
  userId varchar(22) default NULL,
  ipAddress varchar(50) default NULL
) TYPE=MyISAM;

--
-- Dumping data for table `Poll_answer`
--



--
-- Table structure for table `Product`
--

CREATE TABLE Product (
  wobjectId varchar(22) NOT NULL default '',
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
  wobjectId char(22) NOT NULL default '',
  AccessoryWobjectId char(22) NOT NULL default '',
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
  wobjectId varchar(22) default NULL,
  Product_benefitId varchar(22) NOT NULL default '',
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
  wobjectId varchar(22) default NULL,
  Product_featureId varchar(22) NOT NULL default '',
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
  wobjectId char(22) NOT NULL default '',
  RelatedWobjectId char(22) NOT NULL default '',
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
  wobjectId varchar(22) default NULL,
  Product_specificationId varchar(22) NOT NULL default '',
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
  wobjectId varchar(22) NOT NULL default '',
  dbQuery text,
  paginateAfter int(11) NOT NULL default '50',
  preprocessMacros int(11) NOT NULL default '0',
  debugMode int(11) NOT NULL default '0',
  databaseLinkId varchar(22) default NULL,
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table `SQLReport`
--



--
-- Table structure for table `SiteMap`
--

CREATE TABLE SiteMap (
  wobjectId char(22) NOT NULL default '',
  startAtThisLevel int(11) NOT NULL default '0',
  depth int(11) NOT NULL default '0',
  indent int(11) NOT NULL default '5',
  alphabetic int(11) NOT NULL default '0',
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table `SiteMap`
--


INSERT INTO SiteMap VALUES ('-1',1,0,5,0);
INSERT INTO SiteMap VALUES ('8',0,0,5,0);

--
-- Table structure for table `Survey`
--

CREATE TABLE Survey (
  wobjectId varchar(22) NOT NULL default '',
  questionOrder varchar(30) default NULL,
  groupToTakeSurvey varchar(22) default NULL,
  groupToViewReports varchar(22) default NULL,
  mode varchar(30) default NULL,
  Survey_id varchar(22) default NULL,
  anonymous char(1) NOT NULL default '0',
  questionsPerPage int(11) NOT NULL default '1',
  responseTemplateId varchar(22) default NULL,
  reportcardTemplateId varchar(22) default NULL,
  overviewTemplateId varchar(22) default NULL,
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
  wobjectId varchar(22) NOT NULL default '',
  rssUrl text,
  maxHeadlines int(11) NOT NULL default '0',
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table `SyndicatedContent`
--


INSERT INTO SyndicatedContent VALUES ('6','http://www.plainblack.com/news?wid=920&func=viewRSS',3);

--
-- Table structure for table `USS`
--

CREATE TABLE USS (
  wobjectId varchar(22) NOT NULL default '',
  groupToContribute varchar(22) default NULL,
  submissionsPerPage int(11) NOT NULL default '50',
  defaultStatus varchar(30) default 'Approved',
  groupToApprove varchar(22) default NULL,
  karmaPerSubmission int(11) NOT NULL default '0',
  submissionTemplateId varchar(22) default NULL,
  filterContent varchar(30) NOT NULL default 'javascript',
  sortBy varchar(35) NOT NULL default 'dateUpdated',
  sortOrder varchar(4) NOT NULL default 'desc',
  USS_id varchar(22) default NULL,
  submissionFormTemplateId varchar(22) default NULL,
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table `USS`
--


INSERT INTO USS VALUES ('5','3',1000,'Approved','4',0,'1','none','sequenceNumber','asc','1000','3');

--
-- Table structure for table `USS_submission`
--

CREATE TABLE USS_submission (
  USS_submissionId varchar(22) NOT NULL default '',
  title varchar(128) default NULL,
  dateSubmitted int(11) default NULL,
  username varchar(30) default NULL,
  userId varchar(22) default NULL,
  content text,
  image varchar(255) default NULL,
  attachment varchar(255) default NULL,
  status varchar(30) NOT NULL default 'Approved',
  views int(11) NOT NULL default '0',
  forumId varchar(22) default NULL,
  dateUpdated int(11) NOT NULL default '0',
  sequenceNumber int(11) NOT NULL default '0',
  USS_id varchar(22) default NULL,
  contentType varchar(35) NOT NULL default 'mixed',
  userDefined1 text,
  userDefined2 text,
  userDefined3 text,
  userDefined4 text,
  userDefined5 text,
  startDate int(11) default '946710000',
  endDate int(11) default '2114406000',
  pageId varchar(22) NOT NULL default '',
  PRIMARY KEY  (USS_submissionId),
  KEY test (status,userId)
) TYPE=MyISAM;

--
-- Dumping data for table `USS_submission`
--


INSERT INTO USS_submission VALUES ('1','Talk to the Experts',1076705448,'Admin','3','<img src=\"^Extras;styles/webgui6/img_talk_to_experts.gif\" align=\"right\" style=\"padding-left: 15px;\" /> Our website contains all of the different methods for reaching us. Our friendly staff will be happy to assist you in any way possible.\r\n\r\n',NULL,NULL,'Approved',0,'1004',1076706084,0,'1000','html','http://www.plainblack.com/contact_us','0',NULL,NULL,NULL,946710000,2114406000,'NOHx0iiGFZq8GBx8pCoPkw');
INSERT INTO USS_submission VALUES ('3','Get the Manual',1076705448,'Admin','3','<img src=\"^Extras;styles/webgui6/img_manual.gif\" align=\"right\" style=\"padding-left: 15px;\" />Ruling WebGUI is the definitive guide to everything WebGUI related. It has been compiled by the experts at Plain Black Software and covers almost all aspects of WebGUI. When you purchase Ruling WebGUI, you will receive updates to this great manual for one full year.',NULL,NULL,'Approved',0,'1006',1076706084,0,'1000','html','http://www.plainblack.com/ruling_webgui','0',NULL,NULL,NULL,946710000,2114406000,'cFlWrGVwXV7eJ0Zvcd8p3w');
INSERT INTO USS_submission VALUES ('4','Purchase Technical Support',1076705448,'Admin','3','<img src=\"^Extras;styles/webgui6/img_tech_support.gif\" align=\"right\" style=\"padding-left: 15px;\" />The WebGUI Support Center is there to help you when you get stuck. With a system as large as WebGUI, you\'ll likely have some questions, and our courteous and knowlegable staff is available to answer those questions. And best of all, you get Ruling WebGUI free when you sign up for the Support Center.\r\n\r\n',NULL,NULL,'Approved',0,'1007',1076706084,0,'1000','html','http://www.plainblack.com/support_programs','0',NULL,NULL,NULL,946710000,2114406000,'0r2GNyJ5HImgY8xx_tQBZQ');
INSERT INTO USS_submission VALUES ('5','Sign Up for Hosting',1076705448,'Admin','3','<img src=\"^Extras;styles/webgui6/img_hosting.gif\" align=\"right\" style=\"padding-left: 15px;\" />We provide professional hosting services for you so you don\'t have to go through the trouble of finding a hoster who likely won\'t know what to do with WebGUI anyway.',NULL,NULL,'Approved',0,'1008',1076706084,0,'1000','html','http://www.plainblack.com/hosting','0',NULL,NULL,NULL,946710000,2114406000,'uGRHud5vVtKFT1ciQ2OGIg');
INSERT INTO USS_submission VALUES ('6','Look Great',1076705448,'Admin','3','<img src=\"^Extras;styles/webgui6/img_look_great.gif\" align=\"right\" style=\"padding-left: 15px;\" />Let Plain Black\'s design team build you a professional looking design. Our award-winning designers can get you the look you need on time and on budget, every time.',NULL,NULL,'Approved',0,'1009',1076706084,0,'1000','html','http://www.plainblack.com/design','0',NULL,NULL,NULL,946710000,2114406000,'gvLbaIffuze4HhKFtiCmsw');

--
-- Table structure for table `WSClient`
--

CREATE TABLE WSClient (
  wobjectId varchar(22) NOT NULL default '',
  call text NOT NULL,
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
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table `WSClient`
--



--
-- Table structure for table `WobjectProxy`
--

CREATE TABLE WobjectProxy (
  wobjectId varchar(22) NOT NULL default '',
  proxiedWobjectId varchar(22) default NULL,
  overrideTitle int(11) NOT NULL default '0',
  overrideDescription int(11) NOT NULL default '0',
  overrideTemplate int(11) NOT NULL default '0',
  overrideDisplayTitle int(11) NOT NULL default '0',
  proxiedTemplateId varchar(22) NOT NULL default '1',
  proxiedNamespace varchar(35) default NULL,
  proxyByCriteria int(11) default '0',
  resolveMultiples varchar(30) default 'mostRecent',
  proxyCriteria text,
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table `WobjectProxy`
--



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
-- Table structure for table `collateral`
--

CREATE TABLE collateral (
  collateralId varchar(22) NOT NULL default '',
  name varchar(128) NOT NULL default 'untitled',
  filename varchar(255) default NULL,
  parameters text,
  userId varchar(22) default NULL,
  username varchar(128) default NULL,
  dateUploaded int(11) default NULL,
  collateralFolderId varchar(22) default NULL,
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
  collateralFolderId varchar(22) NOT NULL default '',
  name varchar(128) NOT NULL default 'untitled',
  parentId varchar(22) NOT NULL default '',
  description varchar(255) default NULL
) TYPE=MyISAM;

--
-- Dumping data for table `collateralFolder`
--


INSERT INTO collateralFolder VALUES ('0','Root','-1','Top level');

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
-- Table structure for table `forum`
--

CREATE TABLE forum (
  forumId varchar(22) NOT NULL default '',
  addEditStampToPosts int(11) NOT NULL default '1',
  filterPosts varchar(30) default 'javascript',
  karmaPerPost int(11) NOT NULL default '0',
  groupToPost varchar(22) default NULL,
  editTimeout int(11) NOT NULL default '3600',
  moderatePosts int(11) NOT NULL default '0',
  groupToModerate varchar(22) default NULL,
  attachmentsPerPost int(11) NOT NULL default '0',
  allowRichEdit int(11) NOT NULL default '1',
  allowReplacements int(11) NOT NULL default '1',
  views int(11) NOT NULL default '0',
  replies int(11) NOT NULL default '0',
  rating int(11) NOT NULL default '0',
  threads int(11) NOT NULL default '0',
  lastPostId varchar(22) default NULL,
  lastPostDate int(11) NOT NULL default '0',
  forumTemplateId varchar(22) default NULL,
  threadTemplateId varchar(22) default NULL,
  postTemplateId varchar(22) default NULL,
  postformTemplateId varchar(22) default NULL,
  postPreviewTemplateId varchar(22) default NULL,
  notificationTemplateId varchar(22) default NULL,
  searchTemplateId varchar(22) default NULL,
  archiveAfter int(11) NOT NULL default '31536000',
  threadsPerPage int(11) default '30',
  postsPerPage int(11) default '10',
  masterForumId varchar(22) default NULL,
  groupToView varchar(22) default NULL,
  usePreview int(11) NOT NULL default '1',
  PRIMARY KEY  (forumId)
) TYPE=MyISAM;

--
-- Dumping data for table `forum`
--


INSERT INTO forum VALUES ('1000',1,'javascript',0,'7',3600,0,'4',0,1,1,0,0,0,0,'0',0,'1','1','1','1',NULL,'1','1',31536000,30,10,NULL,'7',1);
INSERT INTO forum VALUES ('1001',1,'javascript',0,'7',3600,0,'4',0,1,1,0,0,0,0,'0',0,'1','1','1','1',NULL,'1','1',31536000,30,10,NULL,'7',1);
INSERT INTO forum VALUES ('1002',1,'javascript',0,'2',3600,0,'4',0,1,1,0,0,0,0,'0',0,'1','1','1','1',NULL,'1','1',31536000,30,10,NULL,'7',1);
INSERT INTO forum VALUES ('1003',1,'javascript',0,'7',3600,0,'4',0,1,1,0,0,0,0,'0',0,'1','1','1','1',NULL,'1','1',31536000,30,10,NULL,'7',1);
INSERT INTO forum VALUES ('1004',1,'javascript',0,'2',3600,0,'4',0,1,1,0,0,0,0,'0',0,'1','1','1','1',NULL,'1','1',31536000,30,10,NULL,'7',1);
INSERT INTO forum VALUES ('1006',1,'javascript',0,'2',3600,0,'4',0,1,1,0,0,0,0,'0',0,'1','1','1','1',NULL,'1','1',31536000,30,10,NULL,'7',1);
INSERT INTO forum VALUES ('1007',1,'javascript',0,'2',3600,0,'4',0,1,1,0,0,0,0,'0',0,'1','1','1','1',NULL,'1','1',31536000,30,10,NULL,'7',1);
INSERT INTO forum VALUES ('1008',1,'javascript',0,'2',3600,0,'4',0,1,1,0,0,0,0,'0',0,'1','1','1','1',NULL,'1','1',31536000,30,10,NULL,'7',1);
INSERT INTO forum VALUES ('1009',1,'javascript',0,'2',3600,0,'4',0,1,1,0,0,0,0,'0',0,'1','1','1','1',NULL,'1','1',31536000,30,10,NULL,'7',1);

--
-- Table structure for table `forumPost`
--

CREATE TABLE forumPost (
  forumPostId varchar(22) NOT NULL default '',
  parentId varchar(22) default NULL,
  forumThreadId varchar(22) default NULL,
  userId varchar(22) default NULL,
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
  forumPostAttachmentId varchar(22) NOT NULL default '',
  forumPostId varchar(22) default NULL,
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
  forumPostId varchar(22) default NULL,
  userId varchar(22) default NULL,
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
  userId char(22) NOT NULL default '',
  forumPostId char(22) NOT NULL default '',
  forumThreadId char(22) default NULL,
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
  forumId char(22) NOT NULL default '',
  userId char(22) NOT NULL default '',
  PRIMARY KEY  (forumId,userId)
) TYPE=MyISAM;

--
-- Dumping data for table `forumSubscription`
--



--
-- Table structure for table `forumThread`
--

CREATE TABLE forumThread (
  forumThreadId varchar(22) NOT NULL default '',
  forumId varchar(22) default NULL,
  rootPostId varchar(22) default NULL,
  views int(11) NOT NULL default '0',
  replies int(11) NOT NULL default '0',
  lastPostId varchar(22) default NULL,
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
  forumThreadId char(22) NOT NULL default '',
  userId char(22) NOT NULL default '',
  PRIMARY KEY  (forumThreadId,userId)
) TYPE=MyISAM;

--
-- Dumping data for table `forumThreadSubscription`
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


INSERT INTO incrementer VALUES ('collateralFolderId',1000);
INSERT INTO incrementer VALUES ('themeId',1000);
INSERT INTO incrementer VALUES ('themeComponentId',1000);

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
  wobjectId varchar(22) NOT NULL default '',
  value varchar(100) default NULL,
  PRIMARY KEY  (fieldId,wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table `metaData_values`
--



--
-- Table structure for table `page`
--

CREATE TABLE page (
  pageId varchar(22) NOT NULL default '',
  parentId varchar(22) default NULL,
  title varchar(255) default NULL,
  styleId varchar(22) default NULL,
  ownerId varchar(22) default NULL,
  sequenceNumber int(11) NOT NULL default '1',
  metaTags text,
  urlizedTitle varchar(255) default NULL,
  defaultMetaTags int(11) NOT NULL default '0',
  menuTitle varchar(128) default NULL,
  synopsis text,
  templateId varchar(22) default NULL,
  startDate int(11) NOT NULL default '946710000',
  endDate int(11) NOT NULL default '2082783600',
  redirectURL text,
  userDefined1 varchar(255) default NULL,
  userDefined2 varchar(255) default NULL,
  userDefined3 varchar(255) default NULL,
  userDefined4 varchar(255) default NULL,
  userDefined5 varchar(255) default NULL,
  languageId varchar(50) NOT NULL default 'English',
  groupIdView varchar(22) default NULL,
  groupIdEdit varchar(22) default NULL,
  hideFromNavigation int(11) NOT NULL default '0',
  newWindow int(11) NOT NULL default '0',
  bufferUserId varchar(22) default NULL,
  bufferDate int(11) default NULL,
  bufferPrevId varchar(22) default NULL,
  cacheTimeout int(11) NOT NULL default '60',
  cacheTimeoutVisitor int(11) NOT NULL default '600',
  printableStyleId varchar(22) default NULL,
  wobjectPrivileges int(11) NOT NULL default '0',
  nestedSetLeft int(11) default NULL,
  nestedSetRight int(11) default NULL,
  depth int(3) default NULL,
  subroutine varchar(255) NOT NULL default 'generate',
  subroutinePackage varchar(255) NOT NULL default 'WebGUI::Page',
  subroutineParams text,
  encryptPage int(11) default '0',
  isSystem int(11) NOT NULL default '0',
  PRIMARY KEY  (pageId)
) TYPE=MyISAM;

--
-- Dumping data for table `page`
--


INSERT INTO page VALUES ('1','0','Home','1001','3',0,'','home',1,'Home',NULL,'1',946710000,2082783600,NULL,NULL,NULL,NULL,NULL,NULL,'English','7','3',0,0,NULL,NULL,NULL,60,600,'3',0,1,22,0,'generate','WebGUI::Page',NULL,0,0);
INSERT INTO page VALUES ('4','0','Page Not Found','-6','3',21,'','page_not_found',0,'Page Not Found',NULL,'1',946710000,2082783600,NULL,NULL,NULL,NULL,NULL,NULL,'English','7','3',1,0,NULL,NULL,NULL,60,600,'3',0,23,24,0,'generate','WebGUI::Page',NULL,0,1);
INSERT INTO page VALUES ('3','0','Trash','5','3',22,'','trash',0,'Trash',NULL,'1',946710000,2082783600,NULL,NULL,NULL,NULL,NULL,NULL,'English','3','3',1,0,NULL,NULL,NULL,60,600,'3',0,25,26,0,'generate','WebGUI::Page',NULL,0,1);
INSERT INTO page VALUES ('2','0','Clipboard','4','3',23,'','clipboard',0,'Clipboard',NULL,'1',946710000,2082783600,NULL,NULL,NULL,NULL,NULL,NULL,'English','4','4',1,0,NULL,NULL,NULL,60,600,'3',0,27,28,0,'generate','WebGUI::Page',NULL,0,1);
INSERT INTO page VALUES ('5','0','Packages','2','3',24,'','packages',0,'Packages',NULL,'1',946710000,2082783600,NULL,NULL,NULL,NULL,NULL,NULL,'English','6','6',1,0,NULL,NULL,NULL,60,600,'3',0,29,30,0,'generate','WebGUI::Page',NULL,0,1);
INSERT INTO page VALUES ('1000','1','Getting Started','1001','3',1,'','getting_started',1,'Getting Started','','1',946710000,2082783600,'',NULL,NULL,NULL,NULL,NULL,'English','7','3',0,0,NULL,NULL,NULL,60,600,'3',0,2,3,1,'generate','WebGUI::Page',NULL,0,0);
INSERT INTO page VALUES ('1001','1','What should you do next?','1001','3',2,'','your_next_step',1,'Your Next Step','','1',946710000,2082783600,'',NULL,NULL,NULL,NULL,NULL,'English','7','3',0,0,NULL,NULL,NULL,60,600,'3',0,4,15,1,'generate','WebGUI::Page',NULL,0,0);
INSERT INTO page VALUES ('1002','1','The Latest News','1001','3',3,'','the_latest_news',1,'The Latest News','','1',946710000,2082783600,'',NULL,NULL,NULL,NULL,NULL,'English','7','3',0,0,NULL,NULL,NULL,60,600,'3',0,16,17,1,'generate','WebGUI::Page',NULL,0,0);
INSERT INTO page VALUES ('1003','1','Tell A Friend','1001','3',4,'','tell_a_friend',1,'Tell A Friend','','1',946710000,2082783600,'',NULL,NULL,NULL,NULL,NULL,'English','7','3',0,0,NULL,NULL,NULL,60,600,'3',0,18,19,1,'generate','WebGUI::Page',NULL,0,0);
INSERT INTO page VALUES ('1004','1','Site Map','1001','3',4,'','site_map',1,'Site Map','','1',946710000,2082783600,'',NULL,NULL,NULL,NULL,NULL,'English','7','3',0,0,NULL,NULL,NULL,60,600,'3',0,20,21,1,'generate','WebGUI::Page',NULL,0,0);
INSERT INTO page VALUES ('0','-1','Nameless Root','0','0',1,NULL,'nameless_root',0,'Nameless Root',NULL,'1',946710000,2082783600,'/',NULL,NULL,NULL,NULL,NULL,'English','3','3',0,0,NULL,NULL,NULL,60,600,'3',0,0,31,-1,'generate','WebGUI::Page',NULL,0,1);
INSERT INTO page VALUES ('NOHx0iiGFZq8GBx8pCoPkw','1001','Talk to the Experts','1001','3',1,'','your_next_step/your_next_step/talk_to_the_experts',1,'Talk to the Experts','','1',946710000,2082783600,'',NULL,NULL,NULL,NULL,NULL,'English','7','3',1,0,NULL,NULL,NULL,60,600,'3',0,5,6,2,'viewSubmissionAsPage','WebGUI::Wobject::USS','{wobjectId=>\'5\',submissionId=>\'1\'}',0,1);
INSERT INTO page VALUES ('cFlWrGVwXV7eJ0Zvcd8p3w','1001','Get the Manual','1001','3',1,'','your_next_step/your_next_step/get_the_manual',1,'Get the Manual','','1',946710000,2082783600,'',NULL,NULL,NULL,NULL,NULL,'English','7','3',1,0,NULL,NULL,NULL,60,600,'3',0,7,8,2,'viewSubmissionAsPage','WebGUI::Wobject::USS','{wobjectId=>\'5\',submissionId=>\'3\'}',0,1);
INSERT INTO page VALUES ('0r2GNyJ5HImgY8xx_tQBZQ','1001','Purchase Technical Support','1001','3',1,'','your_next_step/your_next_step/purchase_technical_support',1,'Purchase Technical Support','','1',946710000,2082783600,'',NULL,NULL,NULL,NULL,NULL,'English','7','3',1,0,NULL,NULL,NULL,60,600,'3',0,9,10,2,'viewSubmissionAsPage','WebGUI::Wobject::USS','{wobjectId=>\'5\',submissionId=>\'4\'}',0,1);
INSERT INTO page VALUES ('uGRHud5vVtKFT1ciQ2OGIg','1001','Sign Up for Hosting','1001','3',1,'','your_next_step/your_next_step/sign_up_for_hosting',1,'Sign Up for Hosting','','1',946710000,2082783600,'',NULL,NULL,NULL,NULL,NULL,'English','7','3',1,0,NULL,NULL,NULL,60,600,'3',0,11,12,2,'viewSubmissionAsPage','WebGUI::Wobject::USS','{wobjectId=>\'5\',submissionId=>\'5\'}',0,1);
INSERT INTO page VALUES ('gvLbaIffuze4HhKFtiCmsw','1001','Look Great','1001','3',1,'','your_next_step/your_next_step/look_great',1,'Look Great','','1',946710000,2082783600,'',NULL,NULL,NULL,NULL,NULL,'English','7','3',1,0,NULL,NULL,NULL,60,600,'3',0,13,14,2,'viewSubmissionAsPage','WebGUI::Wobject::USS','{wobjectId=>\'5\',submissionId=>\'6\'}',0,1);

--
-- Table structure for table `pageStatistics`
--

CREATE TABLE pageStatistics (
  dateStamp int(11) default NULL,
  userId varchar(22) default NULL,
  username varchar(35) default NULL,
  ipAddress varchar(15) default NULL,
  userAgent varchar(255) default NULL,
  referer text,
  pageId varchar(22) default NULL,
  pageTitle varchar(255) default NULL,
  wobjectId varchar(22) default NULL,
  wobjectFunction varchar(60) default NULL
) TYPE=MyISAM;

--
-- Dumping data for table `pageStatistics`
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
INSERT INTO settings VALUES ('metaDataEnabled','0');
INSERT INTO settings VALUES ('passiveProfilingEnabled','0');
INSERT INTO settings VALUES ('urlExtension','');

--
-- Table structure for table `template`
--

CREATE TABLE template (
  templateId varchar(22) NOT NULL default '',
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


INSERT INTO template VALUES ('1','Default Site Map','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_loop page_loop>\r\n  <tmpl_if page.isRoot><p /></tmpl_if>\r\n  <tmpl_var page.indent>&middot;<a href=\"<tmpl_var page.url>\"><tmpl_var page.title></a><br />\r\n</tmpl_loop>','SiteMap',1,1);
INSERT INTO template VALUES ('3','Left Align Image','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.isFirstPage>\r\n<tmpl_if image.url>\r\n  <table width=\"100%\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\"><tr><td class=\"content\">\r\n  <img src=\"<tmpl_var image.url>\" align=\"left\" border=\"0\">\r\n</tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n  <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n\r\n<tmpl_if pagination.isLastPage>\r\n<tmpl_if linkurl>\r\n  <tmpl_if linktitle>\r\n    <p /><a href=\"<tmpl_var linkUrl>\"><tmpl_var linkTitle></a>\r\n  </tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_var attachment.box> <p />\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.isFirstPage>\r\n<tmpl_if image.url>\r\n  </td></tr></table>\r\n</tmpl_if>\r\n</tmpl_if>\r\n\r\n\r\n<tmpl_if pagination.pageCount.isMultiple>\r\n<tmpl_var pagination.previousPage> \r\n&middot;\r\n<tmpl_var pagination.pageList.upTo20>\r\n&middot;\r\n<tmpl_var pagination.nextPage>\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.isLastPage>\r\n\r\n<tmpl_if allowDiscussion>\r\n  <p><table width=\"100%\" cellspacing=\"2\" cellpadding=\"1\" border=\"0\">\r\n  <tr><td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var replies.URL>\"><tmpl_var replies.label> (<tmpl_var replies.count>)</a></td>\r\n  <td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var post.url>\"><tmpl_var post.label></a></td></tr>\r\n  </table>\r\n</tmpl_if>\r\n\r\n</tmpl_if>','Article',1,1);
INSERT INTO template VALUES ('2','List with Thumbnails','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_if session.scratch.search>\r\n <tmpl_var search.form>\r\n</tmpl_if>\r\n<table cellpadding=\"3\" cellspacing=\"1\" border=\"0\" width=\"100%\">\r\n\r\n<tr>\r\n  <td colspan=\"3\" align=\"right\" class=\"tableMenu\">\r\n                <a href=\"<tmpl_var search.url>\"><tmpl_var search.label></a>\r\n                <tmpl_if session.var.adminOn>\r\n                      &middot; <a href=\"<tmpl_var addfile.url>\"><tmpl_var addfile.label></a>\r\n                 </tmpl_if>\r\n   </td>\r\n</tr>\r\n\r\n<tr>\r\n  <td class=\"tableHeader\"><a href=\"<tmpl_var titleColumn.url>\"><tmpl_var titleColumn.label></a></td>\r\n  <td class=\"tableHeader\"><a href=\"<tmpl_var descriptionColumn.url>\"><tmpl_var descriptionColumn.label></a></td>\r\n  <td class=\"tableHeader\"><a href=\"<tmpl_var dateColumn.url>\"><tmpl_var dateColumn.label></a></td>\r\n</tr>\r\n\r\n<tmpl_loop file_loop>\r\n   <tmpl_if file.canView>\r\n        <tr>\r\n           <td class=\"tableData\" valign=\"top\">\r\n             <tmpl_if session.var.adminOn>\r\n                   <tmpl_var file.controls>\r\n              </tmpl_if>\r\n              <a href=\"<tmpl_var file.version1.url>\"><tmpl_var file.title></a>\r\n               &nbsp;&middot;&nbsp;\r\n              <a href=\"<tmpl_var file.version1.url>\"><img src=\"<tmpl_var file.version1.icon>\" border=\"0\" width=\"16\" height=\"16\" align=\"middle\" /><tmpl_var file.version1.type>/<tmpl_var file.version1.size></a>\r\n              <tmpl_if file.version2.name>\r\n                   &nbsp;&middot;&nbsp;\r\n                   <a href=\"<tmpl_var file.version2.url>\"><img src=\"<tmpl_var file.version2.icon>\" border=0 width=\"16\" height=\"16\" align=\"middle\" /><tmpl_var file.version2.type>/<tmpl_var file.version2.size></a>\r\n              </tmpl_if>\r\n              <tmpl_if file.version3.name>\r\n                   &nbsp;&middot;&nbsp;\r\n                   <a href=\"<tmpl_var file.version3.url>\"><img src=\"<tmpl_var file.version3.icon>\" border=\"0\" width=\"16\" height=\"16\" align=\"middle\" /><tmpl_var file.version3.type>/<tmpl_var file.version3.size></a>\r\n              </tmpl_if>\r\n           </td>\r\n           <td class=\"tableData\" valign=\"top\">\r\n                    <tmpl_if file.version1.isImage>\r\n                           <img src=\"<tmpl_var file.version1.thumbnail>\" border=0 align=\"middle\" hspace=\"3\">\r\n                    </tmpl_if>\r\n                <tmpl_var file.description>\r\n           </td>\r\n           <td class=\"tableData\" valign=\"top\">\r\n                 <tmpl_var file.date>\r\n           </td>\r\n        </tr>\r\n      </tmpl_if>\r\n</tmpl_loop>\r\n\r\n<tmpl_if noresults>\r\n    <tr><td class=\"tableData\" colspan=\"3\"><tmpl_var noresults.message></td></tr>\r\n</tmpl_if>\r\n\r\n</table>\r\n\r\n<tmpl_if pagination.pageCount.isMultiple>\r\n  <div class=\"pagination\">\r\n    <tmpl_var pagination.previousPage> &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>\r\n  </div>\r\n</tmpl_if>','FileManager',1,1);
INSERT INTO template VALUES ('3','Calendar Month (Small)','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_if session.var.adminOn>\r\n    <a href=\"<tmpl_var addevent.url>\"><tmpl_var addevent.label></a>\r\n    <p />\r\n</tmpl_if>\r\n\r\n\n\n\n<tmpl_loop month_loop>\n	<table border=\"1\" width=\"100%\">\n	<tr><td colspan=7 class=\"tableHeader\"><h2 align=\"center\"><tmpl_var month> <tmpl_var year></h2></td></tr>\n	<tr>\n	<tmpl_if session.user.firstDayOfWeek>\n		<th class=\"tableData\"><tmpl_var monday.label.short></th>\n		<th class=\"tableData\"><tmpl_var tuesday.label.short></th>\n		<th class=\"tableData\"><tmpl_var wednesday.label.short></th>\n		<th class=\"tableData\"><tmpl_var thursday.label.short></th>\n		<th class=\"tableData\"><tmpl_var friday.label.short></th>\n		<th class=\"tableData\"><tmpl_var saturday.label.short></th>\n		<th class=\"tableData\"><tmpl_var sunday.label.short></th>\n	<tmpl_else>\n		<th class=\"tableData\"><tmpl_var sunday.label.short></th>\n		<th class=\"tableData\"><tmpl_var monday.label.short></th>\n		<th class=\"tableData\"><tmpl_var tuesday.label.short></th>\n		<th class=\"tableData\"><tmpl_var wednesday.label.short></th>\n		<th class=\"tableData\"><tmpl_var thursday.label.short></th>\n		<th class=\"tableData\"><tmpl_var friday.label.short></th>\n		<th class=\"tableData\"><tmpl_var saturday.label.short></th>\n	</tmpl_if>\n	</tr><tr>\n	<tmpl_loop prepad_loop>\n		<td>&nbsp;</td>\n	</tmpl_loop>\n 	<tmpl_loop day_loop>\n		<tmpl_if isStartOfWeek>\n			<tr>\n		</tmpl_if>\n		<td class=\"table<tmpl_if isToday>Header<tmpl_else>Data</tmpl_if>\" width=\"28\" valign=\"top\" align=\"left\"><p><b>\n				<tmpl_if url>\n					<a href=\"<tmpl_var url>\"><tmpl_var day></a>\n				<tmpl_else>\n					<tmpl_var day>\n				</tmpl_if>\n		</b></p></td>		\n		<tmpl_if isEndOfWeek>\n			</tr>\n		</tmpl_if>\n	</tmpl_loop>\n	<tmpl_loop postpad_loop>\n		<td>&nbsp;</td>\n	</tmpl_loop>\n	</tr>\n	</table>\n</tmpl_loop>\n\n\n<tmpl_if pagination.pageCount.isMultiple>\n  <div class=\"pagination\">\n    <tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>\n  </div>\n</tmpl_if>\n','EventsCalendar',1,1);
INSERT INTO template VALUES ('1','Default Event','<h1><tmpl_var title></h1>\r\n\r\n<table width=\"100%\" cellspacing=\"0\" cellpadding=\"5\" border=\"0\">\r\n<tr>\r\n<td valign=\"top\" class=\"tableHeader\" width=\"100%\">\r\n<b><tmpl_var start.label>:</b> <tmpl_var start.date><br />\r\n<b><tmpl_var end.label>:</b> <tmpl_var end.date><br />\r\n</td><td valign=\"top\" class=\"tableMenu\" nowrap=\"1\">\r\n\r\n<tmpl_if canEdit>\r\n     <a href=\"<tmpl_var edit.url>\"><tmpl_var edit.label></a><br />\r\n     <a href=\"<tmpl_var delete.url>\"><tmpl_var delete.label></a><br />\r\n</tmpl_if>\r\n\r\n<tmpl_if previous.url>\r\n     <a href=\"<tmpl_var previous.url>\"><tmpl_var previous.label></a><br />\r\n</tmpl_if>\r\n\r\n<tmpl_if next.url>\r\n     <a href=\"<tmpl_var next.url>\"><tmpl_var next.label></a><br />\r\n</tmpl_if>\r\n\r\n</td></tr>\r\n</table>\r\n<tmpl_var description>','EventsCalendar/Event',1,1);
INSERT INTO template VALUES ('1','Default File Manager','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_if session.scratch.search>\r\n <tmpl_var search.form>\r\n</tmpl_if>\r\n<table cellpadding=\"3\" cellspacing=\"1\" border=\"0\" width=\"100%\">\r\n\r\n<tr>\r\n  <td colspan=\"3\" align=\"right\" class=\"tableMenu\">\r\n                <a href=\"<tmpl_var search.url>\"><tmpl_var search.label></a>\r\n                <tmpl_if session.var.adminOn>\r\n                      &middot; <a href=\"<tmpl_var addfile.url>\"><tmpl_var addfile.label></a>\r\n                 </tmpl_if>\r\n   </td>\r\n</tr>\r\n\r\n<tr>\r\n  <td class=\"tableHeader\"><a href=\"<tmpl_var titleColumn.url>\"><tmpl_var titleColumn.label></a></td>\r\n  <td class=\"tableHeader\"><a href=\"<tmpl_var descriptionColumn.url>\"><tmpl_var descriptionColumn.label></a></td>\r\n  <td class=\"tableHeader\"><a href=\"<tmpl_var dateColumn.url>\"><tmpl_var dateColumn.label></a></td>\r\n</tr>\r\n\r\n<tmpl_loop file_loop>\r\n   <tmpl_if file.canView>\r\n        <tr>\r\n           <td class=\"tableData\" valign=\"top\">\r\n             <tmpl_if session.var.adminOn>\r\n                   <tmpl_var file.controls>\r\n              </tmpl_if>\r\n              <a href=\"<tmpl_var file.version1.url>\"><tmpl_var file.title></a>\r\n               &nbsp;&middot;&nbsp;\r\n              <a href=\"<tmpl_var file.version1.url>\"><img src=\"<tmpl_var file.version1.icon>\" border=\"0\" width=\"16\" height=\"16\" align=\"middle\" /><tmpl_var file.version1.type>/<tmpl_var file.version1.size></a>\r\n              <tmpl_if file.version2.name>\r\n                   &nbsp;&middot;&nbsp;\r\n                   <a href=\"<tmpl_var file.version2.url>\"><img src=\"<tmpl_var file.version2.icon>\" border=0 width=\"16\" height=\"16\" align=\"middle\" /><tmpl_var file.version2.type>/<tmpl_var file.version2.size></a>\r\n              </tmpl_if>\r\n              <tmpl_if file.version3.name>\r\n                   &nbsp;&middot;&nbsp;\r\n                   <a href=\"<tmpl_var file.version3.url>\"><img src=\"<tmpl_var file.version3.icon>\" border=\"0\" width=\"16\" height=\"16\" align=\"middle\" /><tmpl_var file.version3.type>/<tmpl_var file.version3.size></a>\r\n              </tmpl_if>\r\n           </td>\r\n           <td class=\"tableData\" valign=\"top\">\r\n                <tmpl_var file.description>\r\n           </td>\r\n           <td class=\"tableData\" valign=\"top\">\r\n                 <tmpl_var file.date>\r\n           </td>\r\n        </tr>\r\n      </tmpl_if>\r\n</tmpl_loop>\r\n\r\n<tmpl_if noresults>\r\n    <tr><td class=\"tableData\" colspan=\"3\"><tmpl_var noresults.message></td></tr>\r\n</tmpl_if>\r\n\r\n</table>\r\n\r\n<tmpl_if pagination.pageCount.isMultiple>\r\n  <div class=\"pagination\">\r\n    <tmpl_var pagination.previousPage> &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>\r\n  </div>\r\n</tmpl_if>','FileManager',1,1);
INSERT INTO template VALUES ('2','Events List','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_if session.var.adminOn>\r\n    <a href=\"<tmpl_var addevent.url>\"><tmpl_var addevent.label></a>\r\n    <p />\r\n</tmpl_if>\r\n\r\n\n<tmpl_loop month_loop>\n	<tmpl_loop day_loop>\n		<tmpl_loop event_loop>\n			<tmpl_if isFirstDayOfEvent>\n				<tmpl_unless dateIsSameAsPrevious>\n					<b>\n						<tmpl_var start.month> <tmpl_var start.day><tmpl_unless startEndYearMatch>,\n						          <tmpl_ start.year> - \n							<tmpl_var end.month> <tmpl_var end.day></tmpl_unless><tmpl_unless startEndMonthMatch> - <tmpl_var end.month> <tmpl_var end.day><tmpl_else><tmpl_unless startEndDayMatch> - <tmpl_var end.day></tmpl_unless></tmpl_unless>, <tmpl_var end.year>\n					</b>\n				</tmpl_unless>\n				<blockquote>\n					<tmpl_if session.var.adminOn>\n						<a href=\"<tmpl_var url>\">\n					</tmpl_if>\n					<i><tmpl_var name></i>\n					<tmpl_if session.var.adminOn>\n						</a>\n					</tmpl_if>\n					<tmpl_if description>\n						- <tmpl_var description>\n					</tmpl_if description>\n				</blockquote>\n			</tmpl_if>\n		</tmpl_loop>\n	</tmpl_loop>\n</tmpl_loop>\n\n\n\n<tmpl_if pagination.pageCount.isMultiple>\n  <div class=\"pagination\">\n    <tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>\n  </div>\n</tmpl_if>\n','EventsCalendar',1,1);
INSERT INTO template VALUES ('2','Center Image','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.isFirstPage>\r\n<tmpl_if image.url>\r\n  <div align=\"center\"><img src=\"<tmpl_var image.url>\" border=\"0\"></div>\r\n</tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n  <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.isLastPage>\r\n<tmpl_if linkurl>\r\n  <tmpl_if linktitle>\r\n    <p /><a href=\"<tmpl_var linkUrl>\"><tmpl_var linkTitle></a>\r\n  </tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_var attachment.box> <p />\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.pageCount.isMultiple>\r\n<tmpl_var pagination.previousPage> \r\n&middot;\r\n<tmpl_var pagination.pageList.upTo20>\r\n&middot;\r\n<tmpl_var pagination.nextPage>\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.isLastPage>\r\n<tmpl_if allowDiscussion>\r\n  <p><table width=\"100%\" cellspacing=\"2\" cellpadding=\"1\" border=\"0\">\r\n  <tr><td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var replies.URL>\"><tmpl_var replies.label> (<tmpl_var replies.count>)</a></td>\r\n  <td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var post.url>\"><tmpl_var post.label></a></td></tr>\r\n  </table>\r\n</tmpl_if>\r\n</tmpl_if>','Article',1,1);
INSERT INTO template VALUES ('1','Default Article','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.isFirstPage>\r\n<tmpl_if image.url>\r\n  <table width=\"100%\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\"><tr><td class=\"content\">\r\n  <img src=\"<tmpl_var image.url>\" align=\"right\" border=\"0\">\r\n</tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n  <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n\r\n<tmpl_if pagination.isLastPage>\r\n<tmpl_if linkUrl>\r\n  <tmpl_if linkTitle>\r\n    <p /><a href=\"<tmpl_var linkUrl>\"><tmpl_var linkTitle></a>\r\n  </tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_var attachment.box> <p />\r\n</tmpl_if>\r\n\r\n\r\n<tmpl_if pagination.pageCount.isMultiple>\r\n<tmpl_var pagination.previousPage> \r\n&middot;\r\n<tmpl_var pagination.pageList.upTo20>\r\n&middot;\r\n<tmpl_var pagination.nextPage>\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.isFirstPage>\r\n<tmpl_if image.url>\r\n  </td></tr></table>\r\n</tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.isLastPage>\r\n<tmpl_if allowDiscussion>\r\n  <p><table width=\"100%\" cellspacing=\"2\" cellpadding=\"1\" border=\"0\">\r\n  <tr><td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var replies.URL>\"><tmpl_var replies.label> (<tmpl_var replies.count>)</a></td>\r\n  <td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var post.url>\"><tmpl_var post.label></a></td></tr>\r\n  </table>\r\n</tmpl_if>\r\n\r\n</tmpl_if>','Article',1,1);
INSERT INTO template VALUES ('4','Linked Image with Caption','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.isFirstPage>\r\n<tmpl_if image.url>\r\n  <table width=\"100%\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\"><tr><td class=\"content\">\r\n   <table align=\"right\"><tr><td align=\"center\">\r\n   <tmpl_if linkUrl>\r\n        <a href=\"<tmpl_var linkUrl>\">\r\n      <img src=\"<tmpl_var image.url>\" border=\"0\">\r\n       <br /><tmpl_var linkTitle></a>\r\n    <tmpl_else>\r\n           <img src=\"<tmpl_var image.url>\" border=\"0\">\r\n           <br /> <tmpl_var linkTitle>\r\n   </tmpl_if>\r\n  </td></tr></table>\r\n</tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n  <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.isLastPage>\r\n<tmpl_var attachment.box> <p />\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.isFirstPage>\r\n<tmpl_if image.url>\r\n  </td></tr></table>\r\n</tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.pageCount.isMultiple>\r\n<tmpl_var pagination.previousPage> \r\n&middot;\r\n<tmpl_var pagination.pageList.upTo20>\r\n&middot;\r\n<tmpl_var pagination.nextPage>\r\n</tmpl_if>\r\n\r\n<tmpl_if pagination.isLastPage>\r\n\r\n<tmpl_if allowDiscussion>\r\n  <p><table width=\"100%\" cellspacing=\"2\" cellpadding=\"1\" border=\"0\">\r\n  <tr><td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var replies.URL>\"><tmpl_var replies.label> (<tmpl_var replies.count>)</a></td>\r\n  <td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var post.url>\"><tmpl_var post.label></a></td></tr>\r\n  </table>\r\n</tmpl_if>\r\n\r\n\r\n</tmpl_if>','Article',1,1);
INSERT INTO template VALUES ('1','Default USS','<tmpl_if displayTitle>    <h1><tmpl_var title></h1></tmpl_if><tmpl_if description>    <tmpl_var description><p /></tmpl_if><tmpl_if session.scratch.search> <tmpl_var search.form></tmpl_if><table width=\"100%\" cellpadding=2 cellspacing=1 border=0><tr><td align=\"right\" class=\"tableMenu\"><tmpl_if canPost>   <a href=\"<tmpl_var post.url>\"><tmpl_var post.label></a> &middot;</tmpl_if><a href=\"<tmpl_var search.url>\"><tmpl_var search.label></a></td></tr></table><table width=\"100%\" cellspacing=1 cellpadding=2 border=0><tr><td class=\"tableHeader\"><tmpl_var title.label></td><td class=\"tableHeader\"><tmpl_var date.label></td><td class=\"tableHeader\"><tmpl_var by.label></td></tr><tmpl_loop submissions_loop><tmpl_if submission.inDateRange><tr><td class=\"tableData\">     <a href=\"<tmpl_var submission.URL>\">  <tmpl_var submission.title>    <tmpl_if submission.currentUser>        (<tmpl_var submission.status>)     </tmpl_if></td><td class=\"tableData\"><tmpl_var submission.date></td><td class=\"tableData\"><a href=\"<tmpl_var submission.userProfile>\"><tmpl_var submission.username></a></td></tr><tmpl_else> <tmpl_if canModerate><tr><td class=\"tableData\">     <i>*<a href=\"<tmpl_var submission.URL>\">  <tmpl_var submission.title>    <tmpl_if submission.currentUser>        (<tmpl_var submission.status>)     </tmpl_if></i></td><td class=\"tableData\"><i><tmpl_var submission.date></i></td><td class=\"tableData\"><i><a href=\"<tmpl_var submission.userProfile>\"><tmpl_var submission.username></a></i></td></tr> </tmpl_if></tmpl_if></tmpl_loop></table><tmpl_if pagination.pageCount.isMultiple>  <div class=\"pagination\">    <tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>  </div></tmpl_if>','USS',1,1);
INSERT INTO template VALUES ('16','FAQ','<a name=\"top\"></a>\r\n<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n <tmpl_if canPost>\n			<a href=\"<tmpl_var post.url>\"> <tmpl_var addquestion.label></a><p />\r\n</tmpl_if>\r\n\r\n<ul>\r\n<tmpl_loop submissions_loop>\r\n   <li><a href=\"#<tmpl_var submission.id>\"><span class=\"faqQuestion\"><tmpl_var submission.title></span></a>\r\n</tmpl_loop>\r\n</ul>\r\n<p />\r\n\r\n\r\n<tmpl_loop submissions_loop>\r\n\r\n  \n		<tmpl_if submission.currentUser>\n			<tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var submission.edit.url>\"><tmpl_var submission.edit.label></a>]</tmpl_unless>\n		</tmpl_if>\n		<tmpl_if canModerate>\n			<tmpl_if session.var.adminOn><tmpl_var submission.controls><tmpl_else><tmpl_unless submission.currentUser><tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var submission.edit.url>\"><tmpl_var submission.edit.label></a>]</tmpl_unless></tmpl_unless></tmpl_if>\n		</tmpl_if>\n		\r\n\r\n  <a name=\"<tmpl_var submission.id>\"><span class=\"faqQuestion\"><tmpl_var submission.title></span></a><br />\r\n  <tmpl_var submission.content.full>\r\n  <p /><a href=\"#top\">[top]</a><p />\r\n</tmpl_loop>\r\n\r\n','USS',1,1);
INSERT INTO template VALUES ('2','Traditional with Thumbnails','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n\r\n<tmpl_if session.scratch.search>\r\n <tmpl_var search.form>\r\n</tmpl_if>\r\n\r\n\r\n<table width=\"100%\" cellpadding=2 cellspacing=1 border=0><tr>\r\n<td align=\"right\" class=\"tableMenu\">\r\n\r\n<tmpl_if canPost>\r\n   <a href=\"<tmpl_var post.url>\"><tmpl_var post.label></a> &middot;\r\n</tmpl_if>\r\n\r\n<a href=\"<tmpl_var search.url>\"><tmpl_var search.label></a>\r\n\r\n</td></tr></table>\r\n\r\n<table width=\"100%\" cellspacing=1 cellpadding=2 border=0>\r\n<tr>\r\n<td class=\"tableHeader\"><tmpl_var title.label></td>\r\n<td class=\"tableHeader\"><tmpl_var thumbnail.label></td>\r\n<td class=\"tableHeader\"><tmpl_var date.label></td>\r\n<td class=\"tableHeader\"><tmpl_var by.label></td>\r\n</tr>\r\n\r\n<tmpl_loop submissions_loop>\r\n\r\n<tr>\r\n<td class=\"tableData\">\r\n     <a href=\"<tmpl_var submission.URL>\">  <tmpl_var submission.title>\r\n    <tmpl_if submission.currentUser>\r\n        (<tmpl_var submission.status>)\r\n     </tmpl_if>\r\n</td>\r\n   <td class=\"tableData\">\r\n      <tmpl_if submission.thumbnail>\r\n             <a href=\"<tmpl_var submission.url>\"><img src=\"<tmpl_var submission.thumbnail>\" border=\"0\"></a>\r\n      </tmpl_if>\r\n  </td>\r\n\r\n<td class=\"tableData\"><tmpl_var submission.date></td>\r\n<td class=\"tableData\"><a href=\"<tmpl_var submission.userProfile>\"><tmpl_var submission.username></a></td>\r\n</tr>\r\n\r\n</tmpl_loop>\r\n\r\n</table>\r\n\r\n<tmpl_if pagination.pageCount.isMultiple>\r\n  <div class=\"pagination\">\r\n    <tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>\r\n  </div>\r\n</tmpl_if>\r\n\r\n','USS',1,1);
INSERT INTO template VALUES ('3','Weblog','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n\r\n<tmpl_if session.scratch.search>\r\n <tmpl_var search.form>\r\n</tmpl_if>\r\n\r\n\r\n<tmpl_if canPost>\r\n   <a href=\"<tmpl_var post.url>\"><tmpl_var post.label></a> &middot;\r\n</tmpl_if>\r\n\r\n\r\n<a href=\"<tmpl_var search.url>\"><tmpl_var search.label></a>\r\n<p />\r\n<table width=\"100%\" cellpadding=2 cellspacing=1 border=0>\r\n\r\n<tmpl_loop submissions_loop>\r\n\r\n<tr><td class=\"tableHeader\"><tmpl_var submission.title>\r\n  <tmpl_if submission.currentUser>\r\n            (<tmpl_var submission.status>)\r\n  </tmpl_if>\r\n</td></tr><tr><td class=\"tableData\"><b>\r\n  <tmpl_if submission.thumbnail>\r\n    <a href=\"<tmpl_var submission.url>\"><img src=\"<tmpl_var submission.thumbnail>\" border=\"0\" align=\"right\"/></a>\r\n   </tmpl_if>\r\n <tmpl_var by.label> <a href=\"<tmpl_var submission.userProfile>\"><tmpl_var submission.username></a>  - <tmpl_var submission.date></b><br />\r\n<tmpl_var submission.content>\r\n<p /> ( <a href=\"<tmpl_var submission.url>\"><tmpl_var readmore.label></a>\r\n                <tmpl_if submission.responses>\r\n                         | <tmpl_var submission.responses> <tmpl_var responses.label>\r\n                </tmpl_if>\r\n         )<p/>\r\n</td></tr>\r\n\r\n</tmpl_loop>\r\n\r\n</table>\r\n\r\n<tmpl_if pagination.pageCount.isMultiple>\r\n  <div class=\"pagination\">\r\n    <tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.nextPage>\r\n  </div>\r\n</tmpl_if>\r\n','USS',1,1);
INSERT INTO template VALUES ('4','Photo Gallery','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p/>\r\n</tmpl_if>\r\n\r\n<tmpl_if session.scratch.search>\r\n <tmpl_var search.form>\r\n</tmpl_if>\r\n\r\n<tmpl_if canPost>\r\n   <a href=\"<tmpl_var post.url>\"><tmpl_var post.label></a> &middot;\r\n</tmpl_if>\r\n\r\n\r\n<a href=\"<tmpl_var search.url>\"><tmpl_var search.label></a><p />\r\n\r\n<table width=\"100%\" cellpadding=2 cellspacing=1 border=0>\r\n<tr>\r\n<tmpl_loop submissions_loop>\r\n\r\n<td align=\"center\" class=\"tableData\">\r\n  \r\n  <tmpl_if submission.thumbnail>\r\n       <a href=\"<tmpl_var submission.url>\"><img src=\"<tmpl_var submission.thumbnail>\" border=\"0\"/></a><br />\r\n  </tmpl_if>\r\n  <a href=\"<tmpl_var submission.url>\"><tmpl_var submission.title></a>\r\n  <tmpl_if submission.currentUser>\r\n    (<tmpl_var submission.status>)\r\n  </tmpl_if>\r\n</td>\r\n\r\n<tmpl_if submission.thirdColumn>\r\n  </tr><tr>\r\n</tmpl_if>\r\n\r\n</tmpl_loop>\r\n</tr>\r\n</table>\r\n\r\n<tmpl_if pagination.pageCount.isMultiple>\r\n  <div class=\"pagination\">\r\n    <tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>\r\n  </div>\r\n</tmpl_if>\r\n','USS',1,1);
INSERT INTO template VALUES ('1','Default Submission','<h1><tmpl_var title></h1>\n<table width=\"100%\" cellpadding=2 cellspacing=1 border=0>\n<tr><td valign=\"top\" class=\"tableHeader\" width=\"100%\">\n<b><tmpl_var user.label>:</b> <a href=\"<tmpl_var user.Profile>\"><tmpl_var user.username></a><br />\n<b><tmpl_var date.label>:</b> <tmpl_var date.human><br />\n<b><tmpl_var status.label>:</b> <tmpl_var status.status><br />\n<b><tmpl_var views.label>:</b> <tmpl_var views.count><br />\n</td>\n<td rowspan=\"2\" class=\"tableMenu\" nowrap=\"1\" valign=\"top\">\n\n<tmpl_if previous.more>\n   <a href=\"<tmpl_var previous.url>\">&laquo;<tmpl_var previous.label></a><br />\n</tmpl_if>\n<tmpl_if next.more>\n   <a href=\"<tmpl_var next.url>\"><tmpl_var next.label>&raquo;</a><br />\n</tmpl_if>\n<tmpl_if canEdit>\n   <a href=\"<tmpl_var edit.url>\"><tmpl_var edit.label></a><br />\n   <a href=\"<tmpl_var delete.url>\"><tmpl_var delete.label></a><br />\n</tmpl_if>\n<tmpl_if canChangeStatus>\n   <a href=\"<tmpl_var approve.url>\"><tmpl_var approve.label></a><br />\n   <a href=\"<tmpl_var deny.url>\"><tmpl_var deny.label></a><br />\n</tmpl_if>\n<tmpl_if canPost>\n   <a href=\"<tmpl_var post.url>\"><tmpl_var post.label></a><br />\n</tmpl_if>\n<a href=\"<tmpl_var search.url>\"><tmpl_var search.label></a><br />\n<a href=\"<tmpl_var back.url>\"><tmpl_var back.label></a><br />\n\n</td</tr><tr><td class=\"tableData\">\n<tmpl_if image.url>\n  <img src=\"<tmpl_var image.url>\" border=\"0\"><p />\n</tmpl_if>\n<tmpl_var content><p />\n<tmpl_var attachment.box><br />\n\n</td></tr></table>\n\n<tmpl_var replies>','USS/Submission',1,1);
INSERT INTO template VALUES ('1','Default Forum','<tmpl_if user.canPost>\n	<a href=\"<tmpl_var thread.new.url>\"><tmpl_var thread.new.label></a>\n	<tmpl_unless user.isVisitor>\n		&bull; \n		<tmpl_if user.isSubscribed>\n			<a href=\"<tmpl_var forum.unsubscribe.url>\"><tmpl_var forum.unsubscribe.label></a>\n		<tmpl_else>\n			<a href=\"<tmpl_var forum.subscribe.url>\"><tmpl_var forum.subscribe.label></a>\n		</tmpl_if>\n	</tmpl_unless>\n	&bull;\n	<a href=\"<tmpl_var forum.search.url>\"><tmpl_var forum.search.label></a>\n	<p />\n</tmpl_if>\n\n<table width=\"100%\" cellspacing=\"0\" cellpadding=\"3\" border=\"0\">\n<tr>\n	<td class=\"tableHeader\"><tmpl_var thread.subject.label></td>\n	<td class=\"tableHeader\"><tmpl_var thread.user.label></td>\n	<td class=\"tableHeader\"><a href=\"<tmpl_var thread.sortby.views.url>\"><tmpl_var thread.views.label></a></td>\n	<td class=\"tableHeader\"><a href=\"<tmpl_var thread.sortby.replies.url>\"><tmpl_var thread.replies.label></a></td>\n	<td class=\"tableHeader\"><a href=\"<tmpl_var thread.sortby.rating.url>\"><tmpl_var thread.rating.label></a></td>\n	<td class=\"tableHeader\"><a href=\"<tmpl_var thread.sortby.date.url>\"><tmpl_var thread.date.label></a></td>\n	<td class=\"tableHeader\"><a href=\"<tmpl_var thread.sortby.lastreply.url>\"><tmpl_var thread.last.label></a></td>\n</tr>\n<tmpl_loop thread_loop>\n<tr>\n	<td class=\"tableData\"><a href=\"<tmpl_var thread.root.url>\"><tmpl_var thread.root.subject></a></td>\n	<tmpl_if thread.root.user.isVisitor>\n		<td class=\"tableData\"><tmpl_var thread.root.user.name></td>\n	<tmpl_else>\n		<td class=\"tableData\"><a href=\"<tmpl_var thread.root.user.profile>\"><tmpl_var thread.root.user.name></a></td>\n	</tmpl_if>\n	<td class=\"tableData\" align=\"center\"><tmpl_var thread.views></td>\n	<td class=\"tableData\" align=\"center\"><tmpl_var thread.replies></td>\n	<td class=\"tableData\" align=\"center\"><tmpl_var thread.rating></td>\n	<td class=\"tableData\"><tmpl_var thread.root.date> @ <tmpl_var thread.root.time></td>\n	<td  class=\"tableData\" style=\"font-size: 11px;\">\n		<a href=\"<tmpl_var thread.last.url>\"><tmpl_var thread.last.subject></a>\n		by \n		<tmpl_if thread.last.user.isVisitor>\n			<tmpl_var thread.last.user.name>\n		<tmpl_else>\n			<a href=\"<tmpl_var thread.last.user.profile>\"><tmpl_var thread.last.user.name></a>\n		</tmpl_if>\n		on <tmpl_var thread.last.date> @ <tmpl_var thread.last.time>\n	</td>\n</tr>\n</tmpl_loop>\n</table>\n\n<tmpl_if multiplePages>\n  <div class=\"pagination\">\n    <tmpl_var previousPage>  &middot; <tmpl_var pageList> &middot; <tmpl_var nextPage>\n  </div>\n</tmpl_if>\n\n\n<div align=\"center\">\n<a href=\"<tmpl_var callback.url>\">-=: <tmpl_var callback.label> :=-</a>\n</div>\n','Forum',1,1);
INSERT INTO template VALUES ('5','Classifieds','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_if session.scratch.search>\r\n <tmpl_var search.form>\r\n</tmpl_if>\r\n\r\n<tmpl_if canPost>\r\n   <a href=\"<tmpl_var post.url>\"><tmpl_var post.label></a> &middot;\r\n</tmpl_if>\r\n\r\n<a href=\"<tmpl_var search.url>\"><tmpl_var search.label></a><p />\r\n\r\n<table width=\"100%\" cellpadding=3 cellspacing=0 border=0>\r\n<tr>\r\n<tmpl_loop submissions_loop>\r\n\r\n<td valign=\"top\" class=\"tableData\" width=\"33%\" style=\"border: 1px dotted #aaaaaa; padding: 10px;\">\r\n  <h2><a href=\"<tmpl_var submission.url>\"><tmpl_var submission.title></a></h2>\r\n  <tmpl_if submission.currentUser>\r\n    (<tmpl_var submission.status>)\r\n  </tmpl_if>\r\n<br />\r\n  <tmpl_if submission.thumbnail>\r\n       <a href=\"<tmpl_var submission.url>\"><img src=\"<tmpl_var submission.thumbnail>\" border=\"0\"/ align=\"right\"></a><br />\r\n  </tmpl_if>\r\n<tmpl_var submission.content>\r\n</td>\r\n\r\n<tmpl_if submission.thirdColumn>\r\n  </tr><tr>\r\n</tmpl_if>\r\n\r\n</tmpl_loop>\r\n</tr>\r\n</table>\r\n\r\n<tmpl_if pagination.pageCount.isMultiple>\r\n  <div class=\"pagination\">\r\n    <tmpl_var pagination.previousPage>  ∑ <tmpl_var pagination.pageList.upTo20> ∑ <tmpl_var pagination.nextPage>\r\n  </div>\r\n</tmpl_if>\r\n','USS',1,1);
INSERT INTO template VALUES ('15','Topics','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n <tmpl_if canPost>\n			<a href=\"<tmpl_var post.url>\"> <tmpl_var addquestion.label></a><p />\r\n</tmpl_if>\r\n\r\n\r\n<tmpl_loop submissions_loop>\r\n  \n		<tmpl_if submission.currentUser>\n			<tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var submission.edit.url>\"><tmpl_var submission.edit.label></a>]</tmpl_unless>\n		</tmpl_if>\n		<tmpl_if canModerate>\n			<tmpl_if session.var.adminOn><tmpl_var submission.controls><tmpl_else><tmpl_unless submission.currentUser><tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var submission.edit.url>\"><tmpl_var submission.edit.label></a>]</tmpl_unless></tmpl_unless></tmpl_if>\n		</tmpl_if>\n		\r\n  <h2><tmpl_var submission.title></h2>\r\n  <tmpl_var submission.content.full>\r\n  <p />\r\n</tmpl_loop>\r\n\r\n','USS',1,1);
INSERT INTO template VALUES ('19','Link List','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n\r\n <tmpl_if canPost>\n			<a href=\"<tmpl_var post.url>\"> <tmpl_var addlink.label></a><p />\r\n</tmpl_if>\r\n\r\n<tmpl_loop submissions_loop>\r\n   \r\n    \n		<tmpl_if submission.currentUser>\n			<tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var submission.edit.url>\"><tmpl_var submission.edit.label></a>]</tmpl_unless>\n		</tmpl_if>\n		<tmpl_if canModerate>\n			<tmpl_if session.var.adminOn><tmpl_var submission.controls><tmpl_else><tmpl_unless submission.currentUser><tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var submission.edit.url>\"><tmpl_var submission.edit.label></a>]</tmpl_unless></tmpl_unless></tmpl_if>\n		</tmpl_if>\r\n   &middot;\r\n   <a href=\"<tmpl_var submission.userDefined1>\"\r\n   <tmpl_if submission.userDefined2>\r\n          target=\"_blank\"\r\n    </tmpl_if>\r\n    ><span class=\"linkTitle\"><tmpl_var submission.title></span></a>\r\n\r\n    <tmpl_if submission.content.full>\r\n              - <tmpl_var submission.content.full>\r\n   </tmpl_if>\r\n   <br/>\r\n</tmpl_loop>\r\n','USS',1,1);
INSERT INTO template VALUES ('18','Unordered List','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n <tmpl_if canPost>\n			<a href=\"<tmpl_var post.url>\"> <tmpl_var addlink.label></a><p />\r\n</tmpl_if>\r\n\r\n<ul>\r\n<tmpl_loop submissions_loop>\r\n<li>\r\n   \n		<tmpl_if submission.currentUser>\n			<tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var submission.edit.url>\"><tmpl_var submission.edit.label></a>]</tmpl_unless>\n		</tmpl_if>\n		<tmpl_if canModerate>\n			<tmpl_if session.var.adminOn><tmpl_var submission.controls><tmpl_else><tmpl_unless submission.currentUser><tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var submission.edit.url>\"><tmpl_var submission.edit.label></a>]</tmpl_unless></tmpl_unless></tmpl_if>\n		</tmpl_if>\r\n   \r\n   <a href=\"<tmpl_var submission.userDefined1>\"\r\n   <tmpl_if submission.userDefined2>\r\n          target=\"_blank\"\r\n    </tmpl_if>\r\n    ><span class=\"linkTitle\"><tmpl_var submission.title></span></a>\r\n\r\n    <tmpl_if submission.content.full>\r\n              - <tmpl_var submission.content.full>\r\n   </tmpl_if>\r\n </li>\r\n</tmpl_loop>\r\n</u>','USS',1,1);
INSERT INTO template VALUES ('1','Default Product','<style>\r\n.productFeatureHeader,.productSpecificationHeader,.productRelatedHeader,.productAccessoryHeader, .productBenefitHeader  {\r\n    font-weight: bold;\r\n    font-size: 15px;\r\n}\r\n.productFeature,.productSpecification,.productRelated,.productAccessory, .productBenefit {\r\n    font-size: 12px;\r\n}\r\n.productAttributeSeperator {\r\n    background-color: black;\r\n}\r\n</style>\r\n\r\n<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<table width=\"100%\" cellpadding=\"3\" cellspacing=\"0\" border=\"0\">\r\n<tr>\r\n  <td class=\"content\" valign=\"top\">\r\n\r\n<tmpl_if description>\r\n   <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_if price>\r\n    <b>Price:</b> <tmpl_var price><br />\r\n</tmpl_if>\r\n\r\n<tmpl_if productnumber>\r\n    <b>Product Number:</b> <tmpl_var productNumber><br />\r\n</tmpl_if>\r\n\r\n<br>\r\n\r\n<tmpl_if brochure.url>\r\n    <a href=\"<tmpl_var brochure.url>\"><img src=\"<tmpl_var brochure.icon>\" border=0 align=\"absmiddle\"><tmpl_var brochure.label></a><br />\r\n</tmpl_if>\r\n\r\n<tmpl_if manual.url>\r\n    <a href=\"<tmpl_var manual.url>\"><img src=\"<tmpl_var manual.icon>\" border=0 align=\"absmiddle\"><tmpl_var manual.label></a><br />\r\n</tmpl_if>\r\n\r\n<tmpl_if warranty.url>\r\n    <a href=\"<tmpl_var warranty.url>\"><img src=\"<tmpl_var warranty.icon>\" border=0 align=\"absmiddle\"><tmpl_var warranty.label></a><br />\r\n</tmpl_if>\r\n\r\n  </td>\r\n\r\n<td valign=\"top\">\r\n<tmpl_if thumbnail1>\r\n    <a href=\"<tmpl_var image1>\"><img src=\"<tmpl_var thumbnail1>\" border=\"0\" /></a><p />\r\n</tmpl_if>\r\n<tmpl_if thumbnail2>\r\n    <a href=\"<tmpl_var image2>\"><img src=\"<tmpl_var thumbnail2>\" border=\"0\" /></a><p />\r\n</tmpl_if>\r\n<tmpl_if thumbnail3>\r\n    <a href=\"<tmpl_var image3>\"><img src=\"<tmpl_var thumbnail3>\" border=\"0\" /></a><p />\r\n</tmpl_if>\r\n  </td>\r\n</tr>\r\n</table>\r\n\r\n\r\n<table border=\"0\" cellpadding=\"0\" cellspacing=\"5\">\r\n<tr>\r\n<td valign=\"top\" class=\"productFeature\"><div class=\"productFeatureHeader\">Features</div>\r\n\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addfeature.url>\"><tmpl_var addfeature.label></a><p />\r\n</tmpl_if>\r\n\r\n<tmpl_loop feature_loop>\r\n  ∑<tmpl_if session.var.adminOn><tmpl_var feature.controls></tmpl_if><tmpl_var feature.feature><br />\r\n</tmpl_loop>\r\n<p/>\r\n</td>\r\n\r\n  <td class=\"productAttributeSeperator\"><img src=\"^Extras;spacer.gif\" width=\"1\" height=\"1\"></td>\r\n\r\n  <td valign=\"top\" class=\"productBenefit\"><div class=\"productBenefitHeader\">Benefits</div>\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addBenefit.url>\"><tmpl_var addBenefit.label></a><p />\r\n</tmpl_if>\r\n<tmpl_loop benefit_loop>\r\n  ∑<tmpl_if session.var.adminOn><tmpl_var benefit.controls></tmpl_if><tmpl_var benefit.benefit><br />\r\n</tmpl_loop>\r\n<p/></td>\r\n\r\n  <td class=\"productAttributeSeperator\"><img src=\"^Extras;spacer.gif\" width=\"1\" height=\"1\"></td>\r\n\r\n  <td valign=\"top\" class=\"productSpecification\"><div class=\"productSpecificationHeader\">Specifications</div>\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addSpecification.url>\"><tmpl_var addSpecification.label></a><p />\r\n</tmpl_if>\r\n<tmpl_loop specification_loop>\r\n  ∑<tmpl_if session.var.adminOn><tmpl_var specification.controls></tmpl_if><b><tmpl_var specification.label>:</b> <tmpl_var specification.specification> <tmpl_var specification.units><br />\r\n</tmpl_loop>\r\n<p/></td>\r\n\r\n  <td class=\"productAttributeSeperator\"><img src=\"^Extras;spacer.gif\" width=\"1\" height=\"1\"></td>\r\n\r\n  <td valign=\"top\" class=\"productAccessory\"><div class=\"productAccessoryHeader\">Accessories</div>\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addaccessory.url>\"><tmpl_var addaccessory.label></a><p />\r\n</tmpl_if>\r\n\r\n<tmpl_loop accessory_loop>\r\n  ∑<tmpl_if session.var.adminOn><tmpl_var accessory.controls></tmpl_if><a href=\"<tmpl_var accessory.url>\"><tmpl_var accessory.title></a><br />\r\n</tmpl_loop>\r\n<p/></td>\r\n\r\n  <td class=\"productAttributeSeperator\"><img src=\"^Extras;spacer.gif\" width=\"1\" height=\"1\"></td>\r\n\r\n  <td valign=\"top\" class=\"productRelated\"><div class=\"productRelatedHeader\">Related Products</div>\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addRelatedProduct.url>\"><tmpl_var addRelatedProduct.label></a><p />\r\n</tmpl_if>\r\n\r\n<tmpl_loop relatedproduct_loop>\r\n  ∑<tmpl_if session.var.adminOn><tmpl_var RelatedProduct.controls></tmpl_if><a href=\"<tmpl_var relatedproduct.url>\"><tmpl_var relatedproduct.title></a><br />\r\n</tmpl_loop>\r\n</td>\r\n\r\n</tr>\r\n</table>\r\n\r\n','Product',1,1);
INSERT INTO template VALUES ('2','Benefits Showcase','<style>\r\n.productOptions {\r\n  font-family: Helvetica, Arial, sans-serif;\r\n  font-size: 11px;\r\n}\r\n</style>\r\n\r\n<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n\r\n<tmpl_if image1>\r\n    <img src=\"<tmpl_var image1>\" border=\"0\" /><p />\r\n</tmpl_if>\r\n<table width=\"100%\" cellpadding=\"3\" cellspacing=\"0\" border=\"0\">\r\n<tr>\r\n  <td class=\"content\" valign=\"top\" width=\"66%\"><tmpl_if description>\r\n<tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n  <b>Benefits</b><br />\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addBenefit.url>\"><tmpl_var addBenefit.label></a><p />\r\n</tmpl_if>\r\n\r\n<tmpl_loop benefit_loop>\r\n  ∑<tmpl_if session.var.adminOn><tmpl_var benefit.controls></tmpl_if><tmpl_var benefit.benefit><br />\r\n</tmpl_loop>\r\n\r\n  </td>\r\n  <td valign=\"top\" width=\"34%\" class=\"productOptions\">\r\n\r\n<tmpl_if thumbnail2>\r\n    <a href=\"<tmpl_var image2>\"><img src=\"<tmpl_var thumbnail2>\" border=\"0\" /></a><p />\r\n</tmpl_if>\r\n\r\n<b>Specifications</b><br />\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addSpecification.url>\"><tmpl_var addSpecification.label></a><p />\r\n</tmpl_if>\r\n<tmpl_loop specification_loop>\r\n  ∑<tmpl_if session.var.adminOn><tmpl_var specification.controls></tmpl_if><b><tmpl_var specification.label>:</b> <tmpl_var specification.specification> <tmpl_var specification.units><br />\r\n</tmpl_loop>\r\n\r\n<b>Options</b><br />\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addaccessory.url>\"><tmpl_var addaccessory.label></a><p />\r\n</tmpl_if>\r\n\r\n<tmpl_loop accessory_loop>\r\n  ∑<tmpl_if session.var.adminOn><tmpl_var accessory.controls></tmpl_if><a href=\"<tmpl_var accessory.url>\"><tmpl_var accessory.title></a><br />\r\n</tmpl_loop>\r\n\r\n<b>Other Products</b><br />\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addRelatedProduct.url>\"><tmpl_var addRelatedProduct.label></a><p />\r\n</tmpl_if>\r\n<tmpl_loop relatedproduct_loop>\r\n  ∑<tmpl_if session.var.adminOn><tmpl_var RelatedProduct.controls></tmpl_if><a href=\"<tmpl_var relatedproduct.url>\"><tmpl_var relatedproduct.title></a><br />\r\n</tmpl_loop>\r\n\r\n  </td>\r\n</tr>\r\n</table>\r\n\r\n','Product',1,1);
INSERT INTO template VALUES ('3','Three Columns','<style>\r\n.productFeatureHeader,.productSpecificationHeader,.productRelatedHeader,.productAccessoryHeader, .productBenefitHeader  {\r\n   font-weight: bold;\r\n   font-size: 15px;\r\n}\r\n.productFeature,.productSpecification,.productRelated,.productAccessory, .productBenefit {\r\n   font-size: 12px;\r\n}\r\n\r\n</style>\r\n\r\n\r\n<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<table width=\"100%\" cellpadding=\"3\" cellspacing=\"0\" border=\"0\">\r\n<tr>\r\n  <td align=\"center\">\r\n<tmpl_if thumbnail1>\r\n    <a href=\"<tmpl_var image1>\"><img src=\"<tmpl_var thumbnail1>\" border=\"0\" /></a>\r\n</tmpl_if>\r\n</td>\r\n   <td align=\"center\">\r\n<tmpl_if thumbnail2>\r\n    <a href=\"<tmpl_var image2>\"><img src=\"<tmpl_var thumbnail2>\" border=\"0\" /></a>\r\n</tmpl_if>\r\n</td>\r\n  <td align=\"center\">\r\n<tmpl_if thumbnail3>\r\n    <a href=\"<tmpl_var image3>\"><img src=\"<tmpl_var thumbnail3>\" border=\"0\" /></a>\r\n</tmpl_if>\r\n</td>\r\n</tr>\r\n</table>\r\n<table border=\"0\" cellpadding=\"0\" cellspacing=\"5\" width=\"100%\">\r\n<tr>\r\n  <td valign=\"top\" class=\"tableData\" width=\"35%\">\r\n\r\n<b>Features</b><br />\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addfeature.url>\"><tmpl_var addfeature.label></a><p />\r\n</tmpl_if>\r\n<tmpl_loop feature_loop>\r\n  ∑<tmpl_if session.var.adminOn><tmpl_var feature.controls></tmpl_if><tmpl_var feature.feature><br />\r\n</tmpl_loop>\r\n<p />\r\n\r\n<b>Benefits</b><br/>\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addBenefit.url>\"><tmpl_var addBenefit.label></a><p />\r\n</tmpl_if>\r\n\r\n<tmpl_loop benefit_loop>\r\n  ∑<tmpl_if session.var.adminOn><tmpl_var benefit.controls></tmpl_if><tmpl_var benefit.benefit><br />\r\n</tmpl_loop>\r\n<p />\r\n\r\n</td>\r\n  <td valign=\"top\" class=\"tableData\" width=\"35%\">\r\n\r\n<b>Specifications</b><br />\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addSpecification.url>\"><tmpl_var addSpecification.label></a><p />\r\n</tmpl_if>\r\n<tmpl_loop specification_loop>\r\n  ∑<tmpl_if session.var.adminOn><tmpl_var specification.controls></tmpl_if><b><tmpl_var specification.label>:</b> <tmpl_var specification.specification> <tmpl_var specification.units><br />\r\n</tmpl_loop>\r\n<p />\r\n\r\n<b>Accessories</b><br />\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addaccessory.url>\"><tmpl_var addaccessory.label></a><p />\r\n</tmpl_if>\r\n\r\n<tmpl_loop accessory_loop>\r\n  ∑<tmpl_if session.var.adminOn><tmpl_var accessory.controls></tmpl_if><a href=\"<tmpl_var accessory.url>\"><tmpl_var accessory.title></a><br />\r\n</tmpl_loop>\r\n<p />\r\n\r\n<b>Related Products</b><br />\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addRelatedProduct.url>\"><tmpl_var addRelatedProduct.label></a><p />\r\n</tmpl_if>\r\n<tmpl_loop relatedproduct_loop>\r\n   ∑<tmpl_if session.var.adminOn><tmpl_var RelatedProduct.controls></tmpl_if><a href=\"<tmpl_var relatedproduct.url>\"><tmpl_var relatedproduct.title></a><br />\r\n</tmpl_loop>\r\n<p />\r\n</td>\r\n  <td class=\"tableData\" valign=\"top\" width=\"30%\">\r\n    <tmpl_if price> \r\n    <b>Price:</b> <tmpl_var price><br />\r\n</tmpl_if>\r\n\r\n<tmpl_if productnumber>\r\n    <b>Product Number:</b> <tmpl_var productNumber><br />\r\n</tmpl_if>\r\n<br />\r\n<tmpl_if brochure.url>\r\n    <a href=\"<tmpl_var brochure.url>\"><img src=\"<tmpl_var brochure.icon>\" border=0 align=\"absmiddle\" /><tmpl_var brochure.label></a><br />\r\n</tmpl_if>\r\n<tmpl_if manual.url>\r\n    <a href=\"<tmpl_var manual.url>\"><img src=\"<tmpl_var manual.icon>\" border=0 align=\"absmiddle\" /><tmpl_var manual.label></a><br />\r\n</tmpl_if>\r\n<tmpl_if warranty.url>\r\n    <a href=\"<tmpl_var warranty.url>\"><img src=\"<tmpl_var warranty.icon>\" border=0 align=\"absmiddle\" /><tmpl_var warranty.label></a><br />\r\n</tmpl_if>\r\n  </td>\r\n</tr>\r\n</table>\r\n\r\n\r\n','Product',1,1);
INSERT INTO template VALUES ('5','Left Column','\n		<tmpl_if session.var.adminOn>\n		<style>\n			div.wobject:hover {\n				border: 2px ridge gray;\n			}\n			div.wobject {\n				border: 2px hidden;\n			}\n			.dragable{\n  position: relative;\n}\n.dragTrigger{\n  position: relative;\n  cursor: move;\n}\n.dragging{\n  position: relative;\n  cursor: hand;\n  z-index: 2000; \n  background-image: url(\"^Extras;opaque.gif\");\n}\n.draggedOverTop{\n  position: relative;\n  border: 1px dotted #aaaaaa;\n  border-top: 8px #aaaaaa dotted;\n}\n.draggedOverBottom {\n  position: relative;\n  border: 1px dotted #aaaaaa;\n  border-bottom: 8px #aaaaaa dotted;\n}\n.hidden{\n  display: none;\n}\n.blank {\n  position: relative;\n  cursor: hand;\n  background-color: white;\n}\n.blankOver {\n  position: relative;\n  cursor: hand;\n  background-color: black;\n}\n.empty {\n  position: relative;\n  padding: 25px;\n  width: 50px;\n  height: 100px;\n  background-image: url(\"^Extras;opaque.gif\");\n}\n		</style>^JavaScript(\"<tmpl_var session.config.extrasURL>/draggable.js\");\n		</tmpl_if>\n		<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n			<tmpl_var page.controls>\n		</tmpl_if> </tmpl_if>\n		<table cellpadding=\"3\" cellspacing=\"0\" border=\"0\" width=\"100%\">\r\n<tr>\r\n  <td valign=\"top\" class=\"content\" width=\"34%\">	\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n<table border=0 id=\"position1\" class=\"content\">\n            <tbody>\n</tmpl_if> </tmpl_if>\n		<tmpl_loop position1_loop>\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n            <tr id=\"td<tmpl_var wobject.id>\">\n            <td>\n            <div id=\"td<tmpl_var wobject.id>_div\" class=\"dragable\">      \n</tmpl_if></tmpl_if>\n			<tmpl_if wobject.canView> \n				<div class=\"wobject\"> <div class=\"wobject<tmpl_var wobject.namespace>\" id=\"wobjectId<tmpl_var wobject.id>\">\n				<tmpl_if session.var.adminOn> <tmpl_if wobject.canEdit>\n					<tmpl_var wobject.controls><tmpl_if page.canEdit><tmpl_var wobject.controls.drag></tmpl_if>\n				</tmpl_if> </tmpl_if>\n				<tmpl_if wobject.isInDateRange>\n                      			<a name=\"<tmpl_var wobject.id>\"></a>\n					<tmpl_var wobject.content>\n				</tmpl_if wobject.isInDateRange> \n				</div> </div>\n			</tmpl_if>\n			<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n         </div>\n                </td>\n            </tr>\n</tmpl_if></tmpl_if>\n		</tmpl_loop>\n		<tmpl_if session.var.adminOn> \n            </tbody>\n        </table>\n</tmpl_if>\n	</td>\r\n  <td valign=\"top\" class=\"content\" width=\"66%\">	\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n<table border=0 id=\"position2\" class=\"content\">\n            <tbody>\n</tmpl_if> </tmpl_if>\n		<tmpl_loop position2_loop>\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n            <tr id=\"td<tmpl_var wobject.id>\">\n            <td>\n            <div id=\"td<tmpl_var wobject.id>_div\" class=\"dragable\">      \n</tmpl_if></tmpl_if>\n			<tmpl_if wobject.canView> \n				<div class=\"wobject\"> <div class=\"wobject<tmpl_var wobject.namespace>\" id=\"wobjectId<tmpl_var wobject.id>\">\n				<tmpl_if session.var.adminOn> <tmpl_if wobject.canEdit>\n					<tmpl_var wobject.controls><tmpl_if page.canEdit><tmpl_var wobject.controls.drag></tmpl_if>\n				</tmpl_if> </tmpl_if>\n				<tmpl_if wobject.isInDateRange>\n                      			<a name=\"<tmpl_var wobject.id>\"></a>\n					<tmpl_var wobject.content>\n				</tmpl_if wobject.isInDateRange> \n				</div> </div>\n			</tmpl_if>\n			<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n         </div>\n                </td>\n            </tr>\n</tmpl_if></tmpl_if>\n		</tmpl_loop>\n		<tmpl_if session.var.adminOn> \n            </tbody>\n        </table>\n</tmpl_if>\n	</td>\r\n</tr>\r\n</table>\n<tmpl_if session.var.adminOn> \n\n<table>\n<tr id=\"blank\" class=\"hidden\">\n<td>\n<div><div class=\"empty\">&nbsp;</div></div>\n</td>\n</tr>\n</table>\n<iframe id=\"dragSubmitter\" style=\"display: none;\"></iframe>\n<script>\ndragable_init(\"^\\;\");\n</script>\n</tmpl_if>\n		','page',1,1);
INSERT INTO template VALUES ('4','Left Column Collateral','<style>\r\n.productCollateral {\r\n   font-size: 11px;\r\n}\r\n</style>\r\n\r\n\r\n<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n\r\n<table width=\"100%\">\r\n<tr><td valign=\"top\" class=\"productCollateral\" width=\"100\">\r\n<img src=\"^Extras;spacer.gif\" width=\"100\" height=\"1\" /><br />\r\n<tmpl_if brochure.url>\r\n    <a href=\"<tmpl_var brochure.url>\"><img src=\"<tmpl_var brochure.icon>\" border=0 align=\"absmiddle\" /><tmpl_var brochure.label></a><br />\r\n</tmpl_if>\r\n<tmpl_if manual.url>\r\n    <a href=\"<tmpl_var manual.url>\"><img src=\"<tmpl_var manual.icon>\" border=0 align=\"absmiddle\" /><tmpl_var manual.label></a><br />\r\n</tmpl_if>\r\n<tmpl_if warranty.url>\r\n    <a href=\"<tmpl_var warranty.url>\"><img src=\"<tmpl_var warranty.icon>\" border=0 align=\"absmiddle\" /><tmpl_var warranty.label></a><br />\r\n</tmpl_if>\r\n<br/>\r\n<div align=\"center\">\r\n<tmpl_if thumbnail1>\r\n    <a href=\"<tmpl_var image1>\"><img src=\"<tmpl_var thumbnail1>\" border=\"0\" /></a><p />\r\n</tmpl_if>\r\n<tmpl_if thumbnail2>\r\n    <a href=\"<tmpl_var image2>\"><img src=\"<tmpl_var thumbnail2>\" border=\"0\" /></a><p />\r\n</tmpl_if>\r\n<tmpl_if thumbnail3>\r\n    <a href=\"<tmpl_var image3>\"><img src=\"<tmpl_var thumbnail3>\" border=\"0\" /></a><p />\r\n</tmpl_if>\r\n</div>\r\n</td><td valign=\"top\" class=\"content\" width=\"100%\">\r\n<tmpl_if description>\r\n<tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<b>Specs:</b><br/>\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addSpecification.url>\"><tmpl_var addSpecification.label></a><p />\r\n</tmpl_if>\r\n<tmpl_loop specification_loop>\r\n  ∑<tmpl_if session.var.adminOn><tmpl_var specification.controls></tmpl_if><b><tmpl_var specification.label>:</b> <tmpl_var specification.specification> <tmpl_var specification.units><br />\r\n</tmpl_loop>\r\n<p />\r\n\r\n<b>Features:</b><br/>\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addfeature.url>\"><tmpl_var addfeature.label></a><p />\r\n</tmpl_if>\r\n<tmpl_loop feature_loop>\r\n  ∑<tmpl_if session.var.adminOn><tmpl_var feature.controls></tmpl_if><tmpl_var feature.feature><br />\r\n</tmpl_loop>\r\n<p />\r\n\r\n<b>Options:</b><br />\r\n<tmpl_if session.var.adminOn>\r\n  <a href=\"<tmpl_var addaccessory.url>\"><tmpl_var addaccessory.label></a><p />\r\n</tmpl_if>\r\n<tmpl_loop accessory_loop>\r\n  &middot;<tmpl_if session.var.adminOn><tmpl_var accessory.controls></tmpl_if><a href=\"<tmpl_var accessory.url>\"><tmpl_var accessory.title></a><br />\r\n</tmpl_loop>\r\n\r\n</td></tr>\r\n</table>\r\n','Product',1,1);
INSERT INTO template VALUES ('4','Three Over One','\n		<tmpl_if session.var.adminOn>\n		<style>\n			div.wobject:hover {\n				border: 2px ridge gray;\n			}\n			div.wobject {\n				border: 2px hidden;\n			}\n			.dragable{\n  position: relative;\n}\n.dragTrigger{\n  position: relative;\n  cursor: move;\n}\n.dragging{\n  position: relative;\n  cursor: hand;\n  z-index: 2000; \n  background-image: url(\"^Extras;opaque.gif\");\n}\n.draggedOverTop{\n  position: relative;\n  border: 1px dotted #aaaaaa;\n  border-top: 8px #aaaaaa dotted;\n}\n.draggedOverBottom {\n  position: relative;\n  border: 1px dotted #aaaaaa;\n  border-bottom: 8px #aaaaaa dotted;\n}\n.hidden{\n  display: none;\n}\n.blank {\n  position: relative;\n  cursor: hand;\n  background-color: white;\n}\n.blankOver {\n  position: relative;\n  cursor: hand;\n  background-color: black;\n}\n.empty {\n  position: relative;\n  padding: 25px;\n  width: 50px;\n  height: 100px;\n  background-image: url(\"^Extras;opaque.gif\");\n}\n		</style>^JavaScript(\"<tmpl_var session.config.extrasURL>/draggable.js\");\n		</tmpl_if>\n		<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n			<tmpl_var page.controls>\n		</tmpl_if> </tmpl_if>\n		<table cellpadding=\"3\" cellspacing=\"0\" border=\"0\" width=\"100%\">\r\n<tr>\r\n  <td valign=\"top\" class=\"content\" width=\"33%\">	\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n<table border=0 id=\"position1\" class=\"content\">\n            <tbody>\n</tmpl_if> </tmpl_if>\n		<tmpl_loop position1_loop>\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n            <tr id=\"td<tmpl_var wobject.id>\">\n            <td>\n            <div id=\"td<tmpl_var wobject.id>_div\" class=\"dragable\">      \n</tmpl_if></tmpl_if>\n			<tmpl_if wobject.canView> \n				<div class=\"wobject\"> <div class=\"wobject<tmpl_var wobject.namespace>\" id=\"wobjectId<tmpl_var wobject.id>\">\n				<tmpl_if session.var.adminOn> <tmpl_if wobject.canEdit>\n					<tmpl_var wobject.controls><tmpl_if page.canEdit><tmpl_var wobject.controls.drag></tmpl_if>\n				</tmpl_if> </tmpl_if>\n				<tmpl_if wobject.isInDateRange>\n                      			<a name=\"<tmpl_var wobject.id>\"></a>\n					<tmpl_var wobject.content>\n				</tmpl_if wobject.isInDateRange> \n				</div> </div>\n			</tmpl_if>\n			<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n         </div>\n                </td>\n            </tr>\n</tmpl_if></tmpl_if>\n		</tmpl_loop>\n		<tmpl_if session.var.adminOn> \n            </tbody>\n        </table>\n</tmpl_if>\n	</td>\r\n  <td valign=\"top\" class=\"content\" width=\"34%\">	\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n<table border=0 id=\"position2\" class=\"content\">\n            <tbody>\n</tmpl_if> </tmpl_if>\n		<tmpl_loop position2_loop>\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n            <tr id=\"td<tmpl_var wobject.id>\">\n            <td>\n            <div id=\"td<tmpl_var wobject.id>_div\" class=\"dragable\">      \n</tmpl_if></tmpl_if>\n			<tmpl_if wobject.canView> \n				<div class=\"wobject\"> <div class=\"wobject<tmpl_var wobject.namespace>\" id=\"wobjectId<tmpl_var wobject.id>\">\n				<tmpl_if session.var.adminOn> <tmpl_if wobject.canEdit>\n					<tmpl_var wobject.controls><tmpl_if page.canEdit><tmpl_var wobject.controls.drag></tmpl_if>\n				</tmpl_if> </tmpl_if>\n				<tmpl_if wobject.isInDateRange>\n                      			<a name=\"<tmpl_var wobject.id>\"></a>\n					<tmpl_var wobject.content>\n				</tmpl_if wobject.isInDateRange> \n				</div> </div>\n			</tmpl_if>\n			<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n         </div>\n                </td>\n            </tr>\n</tmpl_if></tmpl_if>\n		</tmpl_loop>\n		<tmpl_if session.var.adminOn> \n            </tbody>\n        </table>\n</tmpl_if>\n	</td>\r\n  <td valign=\"top\" class=\"content\" width=\"33%\">	\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n<table border=0 id=\"position3\" class=\"content\">\n            <tbody>\n</tmpl_if> </tmpl_if>\n		<tmpl_loop position3_loop>\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n            <tr id=\"td<tmpl_var wobject.id>\">\n            <td>\n            <div id=\"td<tmpl_var wobject.id>_div\" class=\"dragable\">      \n</tmpl_if></tmpl_if>\n			<tmpl_if wobject.canView> \n				<div class=\"wobject\"> <div class=\"wobject<tmpl_var wobject.namespace>\" id=\"wobjectId<tmpl_var wobject.id>\">\n				<tmpl_if session.var.adminOn> <tmpl_if wobject.canEdit>\n					<tmpl_var wobject.controls><tmpl_if page.canEdit><tmpl_var wobject.controls.drag></tmpl_if>\n				</tmpl_if> </tmpl_if>\n				<tmpl_if wobject.isInDateRange>\n                      			<a name=\"<tmpl_var wobject.id>\"></a>\n					<tmpl_var wobject.content>\n				</tmpl_if wobject.isInDateRange> \n				</div> </div>\n			</tmpl_if>\n			<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n         </div>\n                </td>\n            </tr>\n</tmpl_if></tmpl_if>\n		</tmpl_loop>\n		<tmpl_if session.var.adminOn> \n            </tbody>\n        </table>\n</tmpl_if>\n	</td>\r\n</tr>\r\n<tr>\r\n  <td valign=\"top\" class=\"content\" colspan=\"3\">	\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n<table border=0 id=\"position4\" class=\"content\">\n            <tbody>\n</tmpl_if> </tmpl_if>\n		<tmpl_loop position4_loop>\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n            <tr id=\"td<tmpl_var wobject.id>\">\n            <td>\n            <div id=\"td<tmpl_var wobject.id>_div\" class=\"dragable\">      \n</tmpl_if></tmpl_if>\n			<tmpl_if wobject.canView> \n				<div class=\"wobject\"> <div class=\"wobject<tmpl_var wobject.namespace>\" id=\"wobjectId<tmpl_var wobject.id>\">\n				<tmpl_if session.var.adminOn> <tmpl_if wobject.canEdit>\n					<tmpl_var wobject.controls><tmpl_if page.canEdit><tmpl_var wobject.controls.drag></tmpl_if>\n				</tmpl_if> </tmpl_if>\n				<tmpl_if wobject.isInDateRange>\n                      			<a name=\"<tmpl_var wobject.id>\"></a>\n					<tmpl_var wobject.content>\n				</tmpl_if wobject.isInDateRange> \n				</div> </div>\n			</tmpl_if>\n			<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n         </div>\n                </td>\n            </tr>\n</tmpl_if></tmpl_if>\n		</tmpl_loop>\n		<tmpl_if session.var.adminOn> \n            </tbody>\n        </table>\n</tmpl_if>\n	</td>\r\n</tr>\r\n</table>\n<tmpl_if session.var.adminOn> \n\n<table>\n<tr id=\"blank\" class=\"hidden\">\n<td>\n<div><div class=\"empty\">&nbsp;</div></div>\n</td>\n</tr>\n</table>\n<iframe id=\"dragSubmitter\" style=\"display: none;\"></iframe>\n<script>\ndragable_init(\"^\\;\");\n</script>\n</tmpl_if>\n		','page',1,1);
INSERT INTO template VALUES ('3','One Over Three','\n		<tmpl_if session.var.adminOn>\n		<style>\n			div.wobject:hover {\n				border: 2px ridge gray;\n			}\n			div.wobject {\n				border: 2px hidden;\n			}\n			.dragable{\n  position: relative;\n}\n.dragTrigger{\n  position: relative;\n  cursor: move;\n}\n.dragging{\n  position: relative;\n  cursor: hand;\n  z-index: 2000; \n  background-image: url(\"^Extras;opaque.gif\");\n}\n.draggedOverTop{\n  position: relative;\n  border: 1px dotted #aaaaaa;\n  border-top: 8px #aaaaaa dotted;\n}\n.draggedOverBottom {\n  position: relative;\n  border: 1px dotted #aaaaaa;\n  border-bottom: 8px #aaaaaa dotted;\n}\n.hidden{\n  display: none;\n}\n.blank {\n  position: relative;\n  cursor: hand;\n  background-color: white;\n}\n.blankOver {\n  position: relative;\n  cursor: hand;\n  background-color: black;\n}\n.empty {\n  position: relative;\n  padding: 25px;\n  width: 50px;\n  height: 100px;\n  background-image: url(\"^Extras;opaque.gif\");\n}\n		</style>^JavaScript(\"<tmpl_var session.config.extrasURL>/draggable.js\");\n		</tmpl_if>\n		<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n			<tmpl_var page.controls>\n		</tmpl_if> </tmpl_if>\n		<table cellpadding=\"3\" cellspacing=\"0\" border=\"0\" width=\"100%\">\r\n<tr>\r\n  <td valign=\"top\" class=\"content\" colspan=\"3\">	\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n<table border=0 id=\"position1\" class=\"content\">\n            <tbody>\n</tmpl_if> </tmpl_if>\n		<tmpl_loop position1_loop>\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n            <tr id=\"td<tmpl_var wobject.id>\">\n            <td>\n            <div id=\"td<tmpl_var wobject.id>_div\" class=\"dragable\">      \n</tmpl_if></tmpl_if>\n			<tmpl_if wobject.canView> \n				<div class=\"wobject\"> <div class=\"wobject<tmpl_var wobject.namespace>\" id=\"wobjectId<tmpl_var wobject.id>\">\n				<tmpl_if session.var.adminOn> <tmpl_if wobject.canEdit>\n					<tmpl_var wobject.controls><tmpl_if page.canEdit><tmpl_var wobject.controls.drag></tmpl_if>\n				</tmpl_if> </tmpl_if>\n				<tmpl_if wobject.isInDateRange>\n                      			<a name=\"<tmpl_var wobject.id>\"></a>\n					<tmpl_var wobject.content>\n				</tmpl_if wobject.isInDateRange> \n				</div> </div>\n			</tmpl_if>\n			<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n         </div>\n                </td>\n            </tr>\n</tmpl_if></tmpl_if>\n		</tmpl_loop>\n		<tmpl_if session.var.adminOn> \n            </tbody>\n        </table>\n</tmpl_if>\n	</td>\r\n</tr>\r\n<tr>\r\n  <td valign=\"top\" class=\"content\" width=\"33%\">	\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n<table border=0 id=\"position2\" class=\"content\">\n            <tbody>\n</tmpl_if> </tmpl_if>\n		<tmpl_loop position2_loop>\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n            <tr id=\"td<tmpl_var wobject.id>\">\n            <td>\n            <div id=\"td<tmpl_var wobject.id>_div\" class=\"dragable\">      \n</tmpl_if></tmpl_if>\n			<tmpl_if wobject.canView> \n				<div class=\"wobject\"> <div class=\"wobject<tmpl_var wobject.namespace>\" id=\"wobjectId<tmpl_var wobject.id>\">\n				<tmpl_if session.var.adminOn> <tmpl_if wobject.canEdit>\n					<tmpl_var wobject.controls><tmpl_if page.canEdit><tmpl_var wobject.controls.drag></tmpl_if>\n				</tmpl_if> </tmpl_if>\n				<tmpl_if wobject.isInDateRange>\n                      			<a name=\"<tmpl_var wobject.id>\"></a>\n					<tmpl_var wobject.content>\n				</tmpl_if wobject.isInDateRange> \n				</div> </div>\n			</tmpl_if>\n			<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n         </div>\n                </td>\n            </tr>\n</tmpl_if></tmpl_if>\n		</tmpl_loop>\n		<tmpl_if session.var.adminOn> \n            </tbody>\n        </table>\n</tmpl_if>\n	</td>\r\n  <td valign=\"top\" class=\"content\" width=\"34%\">	\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n<table border=0 id=\"position3\" class=\"content\">\n            <tbody>\n</tmpl_if> </tmpl_if>\n		<tmpl_loop position3_loop>\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n            <tr id=\"td<tmpl_var wobject.id>\">\n            <td>\n            <div id=\"td<tmpl_var wobject.id>_div\" class=\"dragable\">      \n</tmpl_if></tmpl_if>\n			<tmpl_if wobject.canView> \n				<div class=\"wobject\"> <div class=\"wobject<tmpl_var wobject.namespace>\" id=\"wobjectId<tmpl_var wobject.id>\">\n				<tmpl_if session.var.adminOn> <tmpl_if wobject.canEdit>\n					<tmpl_var wobject.controls><tmpl_if page.canEdit><tmpl_var wobject.controls.drag></tmpl_if>\n				</tmpl_if> </tmpl_if>\n				<tmpl_if wobject.isInDateRange>\n                      			<a name=\"<tmpl_var wobject.id>\"></a>\n					<tmpl_var wobject.content>\n				</tmpl_if wobject.isInDateRange> \n				</div> </div>\n			</tmpl_if>\n			<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n         </div>\n                </td>\n            </tr>\n</tmpl_if></tmpl_if>\n		</tmpl_loop>\n		<tmpl_if session.var.adminOn> \n            </tbody>\n        </table>\n</tmpl_if>\n	</td>\r\n  <td valign=\"top\" class=\"content\" width=\"33%\">	\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n<table border=0 id=\"position4\" class=\"content\">\n            <tbody>\n</tmpl_if> </tmpl_if>\n		<tmpl_loop position4_loop>\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n            <tr id=\"td<tmpl_var wobject.id>\">\n            <td>\n            <div id=\"td<tmpl_var wobject.id>_div\" class=\"dragable\">      \n</tmpl_if></tmpl_if>\n			<tmpl_if wobject.canView> \n				<div class=\"wobject\"> <div class=\"wobject<tmpl_var wobject.namespace>\" id=\"wobjectId<tmpl_var wobject.id>\">\n				<tmpl_if session.var.adminOn> <tmpl_if wobject.canEdit>\n					<tmpl_var wobject.controls><tmpl_if page.canEdit><tmpl_var wobject.controls.drag></tmpl_if>\n				</tmpl_if> </tmpl_if>\n				<tmpl_if wobject.isInDateRange>\n                      			<a name=\"<tmpl_var wobject.id>\"></a>\n					<tmpl_var wobject.content>\n				</tmpl_if wobject.isInDateRange> \n				</div> </div>\n			</tmpl_if>\n			<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n         </div>\n                </td>\n            </tr>\n</tmpl_if></tmpl_if>\n		</tmpl_loop>\n		<tmpl_if session.var.adminOn> \n            </tbody>\n        </table>\n</tmpl_if>\n	</td>\r\n</tr>\r\n</table>\n<tmpl_if session.var.adminOn> \n\n<table>\n<tr id=\"blank\" class=\"hidden\">\n<td>\n<div><div class=\"empty\">&nbsp;</div></div>\n</td>\n</tr>\n</table>\n<iframe id=\"dragSubmitter\" style=\"display: none;\"></iframe>\n<script>\ndragable_init(\"^\\;\");\n</script>\n</tmpl_if>\n		','page',1,1);
INSERT INTO template VALUES ('2','News','\n		<tmpl_if session.var.adminOn>\n		<style>\n			div.wobject:hover {\n				border: 2px ridge gray;\n			}\n			div.wobject {\n				border: 2px hidden;\n			}\n			.dragable{\n  position: relative;\n}\n.dragTrigger{\n  position: relative;\n  cursor: move;\n}\n.dragging{\n  position: relative;\n  cursor: hand;\n  z-index: 2000; \n  background-image: url(\"^Extras;opaque.gif\");\n}\n.draggedOverTop{\n  position: relative;\n  border: 1px dotted #aaaaaa;\n  border-top: 8px #aaaaaa dotted;\n}\n.draggedOverBottom {\n  position: relative;\n  border: 1px dotted #aaaaaa;\n  border-bottom: 8px #aaaaaa dotted;\n}\n.hidden{\n  display: none;\n}\n.blank {\n  position: relative;\n  cursor: hand;\n  background-color: white;\n}\n.blankOver {\n  position: relative;\n  cursor: hand;\n  background-color: black;\n}\n.empty {\n  position: relative;\n  padding: 25px;\n  width: 50px;\n  height: 100px;\n  background-image: url(\"^Extras;opaque.gif\");\n}\n		</style>^JavaScript(\"<tmpl_var session.config.extrasURL>/draggable.js\");\n		</tmpl_if>\n		<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n			<tmpl_var page.controls>\n		</tmpl_if> </tmpl_if>\n		<table cellpadding=\"3\" cellspacing=\"0\" border=\"0\" width=\"100%\">\r\n<tr>\r\n  <td valign=\"top\" class=\"content\" colspan=\"2\" width=\"100%\">	\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n<table border=0 id=\"position1\" class=\"content\">\n            <tbody>\n</tmpl_if> </tmpl_if>\n		<tmpl_loop position1_loop>\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n            <tr id=\"td<tmpl_var wobject.id>\">\n            <td>\n            <div id=\"td<tmpl_var wobject.id>_div\" class=\"dragable\">      \n</tmpl_if></tmpl_if>\n			<tmpl_if wobject.canView> \n				<div class=\"wobject\"> <div class=\"wobject<tmpl_var wobject.namespace>\" id=\"wobjectId<tmpl_var wobject.id>\">\n				<tmpl_if session.var.adminOn> <tmpl_if wobject.canEdit>\n					<tmpl_var wobject.controls><tmpl_if page.canEdit><tmpl_var wobject.controls.drag></tmpl_if>\n				</tmpl_if> </tmpl_if>\n				<tmpl_if wobject.isInDateRange>\n                      			<a name=\"<tmpl_var wobject.id>\"></a>\n					<tmpl_var wobject.content>\n				</tmpl_if wobject.isInDateRange> \n				</div> </div>\n			</tmpl_if>\n			<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n         </div>\n                </td>\n            </tr>\n</tmpl_if></tmpl_if>\n		</tmpl_loop>\n		<tmpl_if session.var.adminOn> \n            </tbody>\n        </table>\n</tmpl_if>\n	</td></tr>\r\n<tr>\r\n  <td valign=\"top\" class=\"content\" width=\"50%\">	\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n<table border=0 id=\"position2\" class=\"content\">\n            <tbody>\n</tmpl_if> </tmpl_if>\n		<tmpl_loop position2_loop>\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n            <tr id=\"td<tmpl_var wobject.id>\">\n            <td>\n            <div id=\"td<tmpl_var wobject.id>_div\" class=\"dragable\">      \n</tmpl_if></tmpl_if>\n			<tmpl_if wobject.canView> \n				<div class=\"wobject\"> <div class=\"wobject<tmpl_var wobject.namespace>\" id=\"wobjectId<tmpl_var wobject.id>\">\n				<tmpl_if session.var.adminOn> <tmpl_if wobject.canEdit>\n					<tmpl_var wobject.controls><tmpl_if page.canEdit><tmpl_var wobject.controls.drag></tmpl_if>\n				</tmpl_if> </tmpl_if>\n				<tmpl_if wobject.isInDateRange>\n                      			<a name=\"<tmpl_var wobject.id>\"></a>\n					<tmpl_var wobject.content>\n				</tmpl_if wobject.isInDateRange> \n				</div> </div>\n			</tmpl_if>\n			<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n         </div>\n                </td>\n            </tr>\n</tmpl_if></tmpl_if>\n		</tmpl_loop>\n		<tmpl_if session.var.adminOn> \n            </tbody>\n        </table>\n</tmpl_if>\n	</td>\r\n  <td valign=\"top\" class=\"content\" width=\"50%\">	\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n<table border=0 id=\"position3\" class=\"content\">\n            <tbody>\n</tmpl_if> </tmpl_if>\n		<tmpl_loop position3_loop>\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n            <tr id=\"td<tmpl_var wobject.id>\">\n            <td>\n            <div id=\"td<tmpl_var wobject.id>_div\" class=\"dragable\">      \n</tmpl_if></tmpl_if>\n			<tmpl_if wobject.canView> \n				<div class=\"wobject\"> <div class=\"wobject<tmpl_var wobject.namespace>\" id=\"wobjectId<tmpl_var wobject.id>\">\n				<tmpl_if session.var.adminOn> <tmpl_if wobject.canEdit>\n					<tmpl_var wobject.controls><tmpl_if page.canEdit><tmpl_var wobject.controls.drag></tmpl_if>\n				</tmpl_if> </tmpl_if>\n				<tmpl_if wobject.isInDateRange>\n                      			<a name=\"<tmpl_var wobject.id>\"></a>\n					<tmpl_var wobject.content>\n				</tmpl_if wobject.isInDateRange> \n				</div> </div>\n			</tmpl_if>\n			<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n         </div>\n                </td>\n            </tr>\n</tmpl_if></tmpl_if>\n		</tmpl_loop>\n		<tmpl_if session.var.adminOn> \n            </tbody>\n        </table>\n</tmpl_if>\n	</td>\r\n</tr>\r\n<tr>\r\n  <td valign=\"top\" class=\"content\" colspan=\"2\" width=\"100%\">	\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n<table border=0 id=\"position4\" class=\"content\">\n            <tbody>\n</tmpl_if> </tmpl_if>\n		<tmpl_loop position4_loop>\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n            <tr id=\"td<tmpl_var wobject.id>\">\n            <td>\n            <div id=\"td<tmpl_var wobject.id>_div\" class=\"dragable\">      \n</tmpl_if></tmpl_if>\n			<tmpl_if wobject.canView> \n				<div class=\"wobject\"> <div class=\"wobject<tmpl_var wobject.namespace>\" id=\"wobjectId<tmpl_var wobject.id>\">\n				<tmpl_if session.var.adminOn> <tmpl_if wobject.canEdit>\n					<tmpl_var wobject.controls><tmpl_if page.canEdit><tmpl_var wobject.controls.drag></tmpl_if>\n				</tmpl_if> </tmpl_if>\n				<tmpl_if wobject.isInDateRange>\n                      			<a name=\"<tmpl_var wobject.id>\"></a>\n					<tmpl_var wobject.content>\n				</tmpl_if wobject.isInDateRange> \n				</div> </div>\n			</tmpl_if>\n			<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n         </div>\n                </td>\n            </tr>\n</tmpl_if></tmpl_if>\n		</tmpl_loop>\n		<tmpl_if session.var.adminOn> \n            </tbody>\n        </table>\n</tmpl_if>\n	</td>\r\n</tr>\r\n</table>\r\n\n<tmpl_if session.var.adminOn> \n\n<table>\n<tr id=\"blank\" class=\"hidden\">\n<td>\n<div><div class=\"empty\">&nbsp;</div></div>\n</td>\n</tr>\n</table>\n<iframe id=\"dragSubmitter\" style=\"display: none;\"></iframe>\n<script>\ndragable_init(\"^\\;\");\n</script>\n</tmpl_if>\n		','page',1,1);
INSERT INTO template VALUES ('7','Side By Side','\n		<tmpl_if session.var.adminOn>\n		<style>\n			div.wobject:hover {\n				border: 2px ridge gray;\n			}\n			div.wobject {\n				border: 2px hidden;\n			}\n			.dragable{\n  position: relative;\n}\n.dragTrigger{\n  position: relative;\n  cursor: move;\n}\n.dragging{\n  position: relative;\n  cursor: hand;\n  z-index: 2000; \n  background-image: url(\"^Extras;opaque.gif\");\n}\n.draggedOverTop{\n  position: relative;\n  border: 1px dotted #aaaaaa;\n  border-top: 8px #aaaaaa dotted;\n}\n.draggedOverBottom {\n  position: relative;\n  border: 1px dotted #aaaaaa;\n  border-bottom: 8px #aaaaaa dotted;\n}\n.hidden{\n  display: none;\n}\n.blank {\n  position: relative;\n  cursor: hand;\n  background-color: white;\n}\n.blankOver {\n  position: relative;\n  cursor: hand;\n  background-color: black;\n}\n.empty {\n  position: relative;\n  padding: 25px;\n  width: 50px;\n  height: 100px;\n  background-image: url(\"^Extras;opaque.gif\");\n}\n		</style>^JavaScript(\"<tmpl_var session.config.extrasURL>/draggable.js\");\n		</tmpl_if>\n		<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n			<tmpl_var page.controls>\n		</tmpl_if> </tmpl_if>\n		<table cellpadding=\"3\" cellspacing=\"0\" border=\"0\" width=\"100%\">\r\n<tr>\r\n  <td valign=\"top\" class=\"content\" width=\"50%\">	\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n<table border=0 id=\"position1\" class=\"content\">\n            <tbody>\n</tmpl_if> </tmpl_if>\n		<tmpl_loop position1_loop>\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n            <tr id=\"td<tmpl_var wobject.id>\">\n            <td>\n            <div id=\"td<tmpl_var wobject.id>_div\" class=\"dragable\">      \n</tmpl_if></tmpl_if>\n			<tmpl_if wobject.canView> \n				<div class=\"wobject\"> <div class=\"wobject<tmpl_var wobject.namespace>\" id=\"wobjectId<tmpl_var wobject.id>\">\n				<tmpl_if session.var.adminOn> <tmpl_if wobject.canEdit>\n					<tmpl_var wobject.controls><tmpl_if page.canEdit><tmpl_var wobject.controls.drag></tmpl_if>\n				</tmpl_if> </tmpl_if>\n				<tmpl_if wobject.isInDateRange>\n                      			<a name=\"<tmpl_var wobject.id>\"></a>\n					<tmpl_var wobject.content>\n				</tmpl_if wobject.isInDateRange> \n				</div> </div>\n			</tmpl_if>\n			<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n         </div>\n                </td>\n            </tr>\n</tmpl_if></tmpl_if>\n		</tmpl_loop>\n		<tmpl_if session.var.adminOn> \n            </tbody>\n        </table>\n</tmpl_if>\n	</td>\r\n  <td valign=\"top\" class=\"content\" width=\"50%\">	\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n<table border=0 id=\"position2\" class=\"content\">\n            <tbody>\n</tmpl_if> </tmpl_if>\n		<tmpl_loop position2_loop>\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n            <tr id=\"td<tmpl_var wobject.id>\">\n            <td>\n            <div id=\"td<tmpl_var wobject.id>_div\" class=\"dragable\">      \n</tmpl_if></tmpl_if>\n			<tmpl_if wobject.canView> \n				<div class=\"wobject\"> <div class=\"wobject<tmpl_var wobject.namespace>\" id=\"wobjectId<tmpl_var wobject.id>\">\n				<tmpl_if session.var.adminOn> <tmpl_if wobject.canEdit>\n					<tmpl_var wobject.controls><tmpl_if page.canEdit><tmpl_var wobject.controls.drag></tmpl_if>\n				</tmpl_if> </tmpl_if>\n				<tmpl_if wobject.isInDateRange>\n                      			<a name=\"<tmpl_var wobject.id>\"></a>\n					<tmpl_var wobject.content>\n				</tmpl_if wobject.isInDateRange> \n				</div> </div>\n			</tmpl_if>\n			<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n         </div>\n                </td>\n            </tr>\n</tmpl_if></tmpl_if>\n		</tmpl_loop>\n		<tmpl_if session.var.adminOn> \n            </tbody>\n        </table>\n</tmpl_if>\n	</td>\r\n</tr>\r\n</table>\r\n\n<tmpl_if session.var.adminOn> \n\n<table>\n<tr id=\"blank\" class=\"hidden\">\n<td>\n<div><div class=\"empty\">&nbsp;</div></div>\n</td>\n</tr>\n</table>\n<iframe id=\"dragSubmitter\" style=\"display: none;\"></iframe>\n<script>\ndragable_init(\"^\\;\");\n</script>\n</tmpl_if>\n		','page',1,1);
INSERT INTO template VALUES ('6','Right Column','\n		<tmpl_if session.var.adminOn>\n		<style>\n			div.wobject:hover {\n				border: 2px ridge gray;\n			}\n			div.wobject {\n				border: 2px hidden;\n			}\n			.dragable{\n  position: relative;\n}\n.dragTrigger{\n  position: relative;\n  cursor: move;\n}\n.dragging{\n  position: relative;\n  cursor: hand;\n  z-index: 2000; \n  background-image: url(\"^Extras;opaque.gif\");\n}\n.draggedOverTop{\n  position: relative;\n  border: 1px dotted #aaaaaa;\n  border-top: 8px #aaaaaa dotted;\n}\n.draggedOverBottom {\n  position: relative;\n  border: 1px dotted #aaaaaa;\n  border-bottom: 8px #aaaaaa dotted;\n}\n.hidden{\n  display: none;\n}\n.blank {\n  position: relative;\n  cursor: hand;\n  background-color: white;\n}\n.blankOver {\n  position: relative;\n  cursor: hand;\n  background-color: black;\n}\n.empty {\n  position: relative;\n  padding: 25px;\n  width: 50px;\n  height: 100px;\n  background-image: url(\"^Extras;opaque.gif\");\n}\n		</style>^JavaScript(\"<tmpl_var session.config.extrasURL>/draggable.js\");\n		</tmpl_if>\n		<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n			<tmpl_var page.controls>\n		</tmpl_if> </tmpl_if>\n		<table cellpadding=\"3\" cellspacing=\"0\" border=\"0\" width=\"100%\">\r\n<tr>\r\n  <td valign=\"top\" class=\"content\" width=\"66%\">	\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n<table border=0 id=\"position1\" class=\"content\">\n            <tbody>\n</tmpl_if> </tmpl_if>\n		<tmpl_loop position1_loop>\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n            <tr id=\"td<tmpl_var wobject.id>\">\n            <td>\n            <div id=\"td<tmpl_var wobject.id>_div\" class=\"dragable\">      \n</tmpl_if></tmpl_if>\n			<tmpl_if wobject.canView> \n				<div class=\"wobject\"> <div class=\"wobject<tmpl_var wobject.namespace>\" id=\"wobjectId<tmpl_var wobject.id>\">\n				<tmpl_if session.var.adminOn> <tmpl_if wobject.canEdit>\n					<tmpl_var wobject.controls><tmpl_if page.canEdit><tmpl_var wobject.controls.drag></tmpl_if>\n				</tmpl_if> </tmpl_if>\n				<tmpl_if wobject.isInDateRange>\n                      			<a name=\"<tmpl_var wobject.id>\"></a>\n					<tmpl_var wobject.content>\n				</tmpl_if wobject.isInDateRange> \n				</div> </div>\n			</tmpl_if>\n			<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n         </div>\n                </td>\n            </tr>\n</tmpl_if></tmpl_if>\n		</tmpl_loop>\n		<tmpl_if session.var.adminOn> \n            </tbody>\n        </table>\n</tmpl_if>\n	</td>\r\n  <td valign=\"top\" class=\"content\" width=\"34%\">	\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n<table border=0 id=\"position2\" class=\"content\">\n            <tbody>\n</tmpl_if> </tmpl_if>\n		<tmpl_loop position2_loop>\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n            <tr id=\"td<tmpl_var wobject.id>\">\n            <td>\n            <div id=\"td<tmpl_var wobject.id>_div\" class=\"dragable\">      \n</tmpl_if></tmpl_if>\n			<tmpl_if wobject.canView> \n				<div class=\"wobject\"> <div class=\"wobject<tmpl_var wobject.namespace>\" id=\"wobjectId<tmpl_var wobject.id>\">\n				<tmpl_if session.var.adminOn> <tmpl_if wobject.canEdit>\n					<tmpl_var wobject.controls><tmpl_if page.canEdit><tmpl_var wobject.controls.drag></tmpl_if>\n				</tmpl_if> </tmpl_if>\n				<tmpl_if wobject.isInDateRange>\n                      			<a name=\"<tmpl_var wobject.id>\"></a>\n					<tmpl_var wobject.content>\n				</tmpl_if wobject.isInDateRange> \n				</div> </div>\n			</tmpl_if>\n			<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n         </div>\n                </td>\n            </tr>\n</tmpl_if></tmpl_if>\n		</tmpl_loop>\n		<tmpl_if session.var.adminOn> \n            </tbody>\n        </table>\n</tmpl_if>\n	</td>\r\n</tr>\r\n</table>\r\n\n<tmpl_if session.var.adminOn> \n\n<table>\n<tr id=\"blank\" class=\"hidden\">\n<td>\n<div><div class=\"empty\">&nbsp;</div></div>\n</td>\n</tr>\n</table>\n<iframe id=\"dragSubmitter\" style=\"display: none;\"></iframe>\n<script>\ndragable_init(\"^\\;\");\n</script>\n</tmpl_if>\n		','page',1,1);
INSERT INTO template VALUES ('1','Default Page','\n		<tmpl_if session.var.adminOn>\n		<style>\n			div.wobject:hover {\n				border: 2px ridge gray;\n			}\n			div.wobject {\n				border: 2px hidden;\n			}\n			.dragable{\n  position: relative;\n}\n.dragTrigger{\n  position: relative;\n  cursor: move;\n}\n.dragging{\n  position: relative;\n  cursor: hand;\n  z-index: 2000; \n  background-image: url(\"^Extras;opaque.gif\");\n}\n.draggedOverTop{\n  position: relative;\n  border: 1px dotted #aaaaaa;\n  border-top: 8px #aaaaaa dotted;\n}\n.draggedOverBottom {\n  position: relative;\n  border: 1px dotted #aaaaaa;\n  border-bottom: 8px #aaaaaa dotted;\n}\n.hidden{\n  display: none;\n}\n.blank {\n  position: relative;\n  cursor: hand;\n  background-color: white;\n}\n.blankOver {\n  position: relative;\n  cursor: hand;\n  background-color: black;\n}\n.empty {\n  position: relative;\n  padding: 25px;\n  width: 50px;\n  height: 100px;\n  background-image: url(\"^Extras;opaque.gif\");\n}\n		</style>^JavaScript(\"<tmpl_var session.config.extrasURL>/draggable.js\");\n		</tmpl_if>\n		<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n			<tmpl_var page.controls>\n		</tmpl_if> </tmpl_if>\n		<table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" width=\"100%\">\r\n<tr>\r\n<td valign=\"top\" class=\"content\">	\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n<table border=0 id=\"position1\" class=\"content\">\n            <tbody>\n</tmpl_if> </tmpl_if>\n		<tmpl_loop position1_loop>\n<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n            <tr id=\"td<tmpl_var wobject.id>\">\n            <td>\n            <div id=\"td<tmpl_var wobject.id>_div\" class=\"dragable\">      \n</tmpl_if></tmpl_if>\n			<tmpl_if wobject.canView> \n				<div class=\"wobject\"> <div class=\"wobject<tmpl_var wobject.namespace>\" id=\"wobjectId<tmpl_var wobject.id>\">\n				<tmpl_if session.var.adminOn> <tmpl_if wobject.canEdit>\n					<tmpl_var wobject.controls><tmpl_if page.canEdit><tmpl_var wobject.controls.drag></tmpl_if>\n				</tmpl_if> </tmpl_if>\n				<tmpl_if wobject.isInDateRange>\n                      			<a name=\"<tmpl_var wobject.id>\"></a>\n					<tmpl_var wobject.content>\n				</tmpl_if wobject.isInDateRange> \n				</div> </div>\n			</tmpl_if>\n			<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>\n         </div>\n                </td>\n            </tr>\n</tmpl_if></tmpl_if>\n		</tmpl_loop>\n		<tmpl_if session.var.adminOn> \n            </tbody>\n        </table>\n</tmpl_if>\n	</td>\r\n</tr>\r\n</table>\r\n\n<tmpl_if session.var.adminOn> \n\n<table>\n<tr id=\"blank\" class=\"hidden\">\n<td>\n<div><div class=\"empty\">&nbsp;</div></div>\n</td>\n</tr>\n</table>\n<iframe id=\"dragSubmitter\" style=\"display: none;\"></iframe>\n<script>\ndragable_init(\"^\\;\");\n</script>\n</tmpl_if>\n		','page',1,1);
INSERT INTO template VALUES ('2','Descriptive Site Map','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_loop page_loop>\r\n  <tmpl_var page.indent><a href=\"<tmpl_var page.url>\"><tmpl_var page.title></a> \r\n   <tmpl_if page.synopsis>\r\n       - <tmpl_var page.synopsis>\r\n   </tmpl_if>\r\n <p />\r\n</tmpl_loop>','SiteMap',1,1);
INSERT INTO template VALUES ('6','Guest Book','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_if canPost>\r\n   <a href=\"<tmpl_var post.url>\"><tmpl_var post.label></a> <p />\r\n</tmpl_if>\r\n\r\n\r\n<tmpl_loop submissions_loop>\r\n\r\n<tmpl_if __odd__>\r\n<div class=\"highlight\">\r\n</tmpl_if>\r\n\r\n<b>On <tmpl_var submission.date> <a href=\"<tmpl_var submission.userProfile>\"><tmpl_var submission.username></a> from <a href=\"<tmpl_var submission.url>\">the <tmpl_var submission.title> department</a> wrote</b>, <i><tmpl_var submission.content></i>\r\n\r\n<tmpl_if __odd__>\r\n</div >\r\n</tmpl_if>\r\n\r\n<p/>\r\n\r\n</tmpl_loop>\r\n\r\n<tmpl_if pagination.pageCount.isMultiple>\r\n  <div class=\"pagination\">\r\n    <tmpl_var pagination.previousPage> ∑ <tmpl_var pagination.nextPage>\r\n  </div>\r\n</tmpl_if>\r\n','USS',1,1);
INSERT INTO template VALUES ('1','Default Syndicated Content','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<h1>\r\n<tmpl_if channel.link>\r\n     <a href=\"<tmpl_var channel.link>\" target=\"_blank\"><tmpl_var channel.title></a>    \r\n<tmpl_else>\r\n     <tmpl_var channel.title>\r\n</tmpl_if>\r\n</h1>\r\n\r\n<tmpl_if channel.description>\r\n    <tmpl_var channel.description><p />\r\n</tmpl_if>\r\n\r\n\r\n<tmpl_loop item_loop>\r\n<li>\r\n  <tmpl_if link>\r\n       <a href=\"<tmpl_var link>\" target=\"_blank\"><tmpl_var title></a>    \r\n    <tmpl_else>\r\n       <tmpl_var title>\r\n  </tmpl_if>\r\n     <tmpl_if description>\r\n        - <tmpl_var description>\r\n     </tmpl_if>\r\n     <br>\r\n\r\n</tmpl_loop>','SyndicatedContent',1,1);
INSERT INTO template VALUES ('1','Default Poll','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<span class=\"pollQuestion\"><tmpl_var question></span><br />\r\n\r\n<tmpl_if canVote>\r\n\r\n    <tmpl_var form.start>\r\n    <tmpl_loop answer_loop>\r\n         <tmpl_var answer.form> <tmpl_var answer.text><br />\r\n    </tmpl_loop>\r\n     <p />\r\n    <tmpl_var form.submit>\r\n    <tmpl_var form.end>\r\n\r\n<tmpl_else>\r\n\r\n    <tmpl_loop answer_loop>\r\n       <span class=\"pollAnswer\"><hr size=\"1\"><tmpl_var answer.text><br></span>\r\n       <table cellpadding=0 cellspacing=0 border=0><tr>\r\n           <td width=\"<tmpl_var answer.graphWidth>\" class=\"pollColor\"><img src=\"^Extras;spacer.gif\" height=\"1\" width=\"1\"></td>\r\n           <td class=\"pollAnswer\">&nbsp;&nbsp;<tmpl_var answer.percent>% (<tmpl_var answer.total>)</td>\r\n       </tr></table>\r\n    </tmpl_loop>\r\n    <span class=\"pollAnswer\"><hr size=\"1\"><b><tmpl_var responses.label>:</b> <tmpl_var responses.total></span>\r\n\r\n</tmpl_if>\r\n\r\n','Poll',1,1);
INSERT INTO template VALUES ('1','Mail Form','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if error_loop>\r\n<ul>\r\n<tmpl_loop error_loop>\r\n  <li><b><tmpl_var error.message></b>\r\n</tmpl_loop>\r\n</ul>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_if canEdit>\r\n      <a href=\"<tmpl_var entryList.url>\"><tmpl_var entryList.label></a>\r\n      &middot; <a href=\"<tmpl_var export.tab.url>\"><tmpl_var export.tab.label></a>\r\n      <tmpl_if entryId>\r\n        &middot; <a href=\"<tmpl_var delete.url>\"><tmpl_var delete.label></a>\r\n      </tmpl_if>\r\n      <tmpl_if session.var.adminOn>\r\n          &middot; <a href=\"<tmpl_var addField.url>\"><tmpl_var addField.label></a>\r\n			 &middot; <a href=\"<tmpl_var addTab.url>\"><tmpl_var addTab.label></a>\r\n     </tmpl_if>\r\n   <p /> \r\n</tmpl_if>\r\n\r\n<tmpl_var form.start>\r\n<table>\r\n<tmpl_loop field_loop>\r\n  <tmpl_unless field.isHidden>\r\n     <tr><td class=\"formDescription\" valign=\"top\">\r\n        <tmpl_if session.var.adminOn><tmpl_if canEdit><tmpl_var field.controls></tmpl_if></tmpl_if>\r\n        <tmpl_var field.label>\r\n     </td><td class=\"tableData\" valign=\"top\">\r\n       <tmpl_if field.isDisplayed>\r\n            <tmpl_var field.value>\r\n       <tmpl_else>\r\n            <tmpl_var field.form>\r\n       </tmpl_if>\r\n        <tmpl_if field.required>*</tmpl_if>\r\n        <span class=\"formSubtext\"><br /><tmpl_var field.subtext></span>\r\n     </td></tr>\r\n  </tmpl_unless>\r\n</tmpl_loop>\r\n<tr><td></td><td><tmpl_var form.send></td></tr>\r\n</table>\r\n\r\n<tmpl_var form.end>\r\n','DataForm',1,1);
INSERT INTO template VALUES ('2','Default Email','<tmpl_var edit.url>\n\n<tmpl_loop field_loop><tmpl_unless field.isMailField><tmpl_var field.label>:	 <tmpl_var field.value>\n</tmpl_unless></tmpl_loop>','DataForm',1,1);
INSERT INTO template VALUES ('3','Default Acknowledgement','<tmpl_var acknowledgement>\r\n<p />\r\n<table border=\"0\">\r\n<tmpl_loop field_loop>\r\n<tmpl_unless field.isMailField><tmpl_unless field.isHidden>\r\n  <tr><td class=\"tableHeader\"><tmpl_var field.label></td>\r\n  <td class=\"tableData\"><tmpl_var field.value></td></tr>\r\n</tmpl_unless></tmpl_unless>\r\n</tmpl_loop>\r\n</table>\r\n<p />\r\n<a href=\"<tmpl_var back.url>\"><tmpl_var back.label></a>','DataForm',1,1);
INSERT INTO template VALUES ('1','Data List','<a href=\"<tmpl_var back.url>\"><tmpl_var back.label></a>\n<p />\n<table width=\"100%\">\n<tr>\n<td class=\"tableHeader\">Entry ID</td>\n<tmpl_loop field_loop>\n  <tmpl_unless field.isMailField>\n    <td class=\"tableHeader\"><tmpl_var field.label></td>\n  </tmpl_unless field.isMailField>\n</tmpl_loop field_loop>\n<td class=\"tableHeader\">Submission Date</td>\n</tr>\n<tmpl_loop record_loop>\n<tr>\n  <td class=\"tableData\"><a href=\"<tmpl_var record.edit.url>\"><tmpl_var record.entryId></a></td>\n  <tmpl_loop record.data_loop>\n    <tmpl_unless record.data.isMailField>\n       <td class=\"tableData\"><tmpl_var record.data.value></td>\n     </tmpl_unless record.data.isMailField>\n  </tmpl_loop record.data_loop>\n  <td class=\"tableData\"><tmpl_var record.submissionDate.human></td>\n</tr>\n</tmpl_loop record_loop>\n</table>','DataForm/List',1,1);
INSERT INTO template VALUES ('1','Default HTTP Proxy','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_if search.for>\r\n  <tmpl_if content>\r\n    <!-- Display search string. Remove if unwanted -->\r\n    <tmpl_var search.for>\r\n  <tmpl_else>\r\n    <!-- Error: Starting point not found -->\r\n    <b>Error: Search string <i><tmpl_var search.for></i> not found in content.</b>\r\n  </tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_var content>\r\n\r\n<tmpl_if stop.at>\r\n  <tmpl_if content.trailing>\r\n    <!-- Display stop search string. Remove if unwanted -->\r\n    <tmpl_var stop.at>\r\n  <tmpl_else>\r\n    <!-- Warning: End point not found -->\r\n    <b>Warning: Ending search point <i><tmpl_var stop.at></i> not found in content.</b>\r\n  </tmpl_if>\r\n</tmpl_if>','HttpProxy',1,1);
INSERT INTO template VALUES ('1','Default Message Board','<tmpl_if displayTitle>\n    <h1><tmpl_var title></h1>\n</tmpl_if>\n\n<tmpl_if description>\n    <tmpl_var description><p />\n</tmpl_if>\n\n<tmpl_if session.var.adminOn>\n   <a href=\"<tmpl_var forum.add.url>\"><tmpl_var forum.add.label></a><p />\n</tmpl_if>\n\n<tmpl_if areMultipleForums>\n	<table width=\"100%\" cellpadding=\"3\" cellspacing=\"0\">\n		<tr>\n			<tmpl_if session.var.adminOn>\n				<td></td>\n			</tmpl_if>\n			<td class=\"tableHeader\"><tmpl_var title.label></td>\n			<td class=\"tableHeader\"><tmpl_var views.label></td>\n			<td class=\"tableHeader\"><tmpl_var rating.label></td>\n			<td class=\"tableHeader\"><tmpl_var threads.label></td>\n			<td class=\"tableHeader\"><tmpl_var replies.label></td>\n			<td class=\"tableHeader\"><tmpl_var lastpost.label></td>\n		</tr>\n		<tmpl_loop forum_loop>\n			<tr>\n				<tmpl_if session.var.adminOn>\n					<td><tmpl_var forum.controls></td>\n				</tmpl_if>\n				<td class=\"tableData\">\n					<a href=\"<tmpl_var forum.url>\"><tmpl_var forum.title></a><br />\n					<span style=\"font-size: 10px;\"><tmpl_var forum.description></span>\n				</td>\n				<td class=\"tableData\" align=\"center\"><tmpl_var forum.views></td>\n				<td class=\"tableData\" align=\"center\"><tmpl_var forum.rating></td>\n				<td class=\"tableData\" align=\"center\"><tmpl_var forum.threads></td>\n				<td class=\"tableData\" align=\"center\"><tmpl_var forum.replies></td>\n				<td class=\"tableData\"><span style=\"font-size: 10px;\">\n					<a href=\"<tmpl_var forum.lastpost.url>\"><tmpl_var forum.lastpost.subject></a>\n					by \n					<tmpl_if forum.lastpost.user.isVisitor>\n						<tmpl_var forum.lastpost.user.name>\n					<tmpl_else>\n						<a href=\"<tmpl_var forum.lastpost.user.profile>\"><tmpl_var forum.lastpost.user.name></a>\n					</tmpl_if>\n					on <tmpl_var forum.lastpost.date> @ <tmpl_var forum.lastpost.time>\n				</span></td>\n			</tr>\n		</tmpl_loop>\n	</table>\n<tmpl_else>\n	<h2><tmpl_var default.title></h2>\n	<tmpl_if session.var.adminOn>\n		<tmpl_var default.controls><br />\n	</tmpl_if>\n	<tmpl_var default.description><p />\n	<tmpl_var default.listing>\n</tmpl_if>','MessageBoard',1,1);
INSERT INTO template VALUES ('1','Default Post Form','<h1><tmpl_var newpost.header></h1>\n\n<tmpl_var form.begin>\n<table>\n\n<tmpl_if user.isVisitor>\n	<tr><td><tmpl_var visitorName.label></td><td><tmpl_var visitorName.form></td></tr>\n</tmpl_if>\n\n<tr><td><tmpl_var subject.label></td><td><tmpl_var subject.form></td></tr>\n<tr><td><tmpl_var message.label></td><td><tmpl_var message.form></td></tr>\n\n<tmpl_if newpost.isNewMessage>\n	<tmpl_unless user.isVisitor>\n		<tr><td><tmpl_var subscribe.label></td><td><tmpl_var subscribe.form></td></tr>\n	</tmpl_unless>\n	<tmpl_if user.isModerator>\n		<tr><td><tmpl_var lock.label></td><td><tmpl_var lock.form></td></tr>\n		<tr><td><tmpl_var sticky.label></td><td><tmpl_var sticky.form></td></tr>\n	</tmpl_if>\n</tmpl_if>\n\n<tr><td><tmpl_var contentType.label></td><td><tmpl_var contentType.form></td></tr>\n<tr><td></td><td><tmpl_var form.submit></td></tr>\n\n</table>\n<tmpl_var form.end>\n\n<p>\n<tmpl_var post.full>\n</p>','Forum/PostForm',1,1);
INSERT INTO template VALUES ('1','Default Post','<h1><tmpl_var post.subject></h1>\n\n<table width=\"100%\">\n<tr>\n<td class=\"content\" valign=\"top\">\n<tmpl_var post.message>\n<tmpl_unless post.isLocked>\n	<tmpl_if user.canPost>\n		<p />\n		<a href=\"<tmpl_var post.reply.url>\"><tmpl_var post.reply.label></a>\n		<tmpl_unless post.hasRated>\n			&bull; <tmpl_var post.rate.label>: [ <a href=\"<tmpl_var post.rate.url.1>\">1</a>, <a href=\"<tmpl_var post.rate.url.2>\">2</a>, \n				<a href=\"<tmpl_var post.rate.url.3>\">3</a>, <a href=\"<tmpl_var post.rate.url.4>\">4</a>, <a href=\"<tmpl_var post.rate.url.5>\">5</a> ]\n		</tmpl_unless>\n	</tmpl_if>\n	<tmpl_if post.canEdit>\n		 &bull; <a href=\"<tmpl_var post.edit.url>\"><tmpl_var post.edit.label></a>\n	 	&bull; <a href=\"<tmpl_var post.delete.url>\"><tmpl_var post.delete.label></a>\n	</tmpl_if>\n	<tmpl_if post.isModerator>\n		 &bull; <a href=\"<tmpl_var post.approve.url>\"><tmpl_var post.approve.label></a>\n	 	&bull; <a href=\"<tmpl_var post.deny.url>\"><tmpl_var post.deny.label></a>\n	</tmpl_if>\n</tmpl_unless>\n</td><td valign=\"top\" class=\"tableHeader\" width=\"170\" nowrap=\"1\">\n<b><tmpl_var post.date.label>:</b> <tmpl_var post.date.value> @ <tmpl_var post.time.value><br />\n<b><tmpl_var post.rating.label>:</b> <tmpl_var post.rating.value><br />\n<b><tmpl_var post.views.label>:</b> <tmpl_var post.views.value><br />\n<b><tmpl_var post.status.label>:</b> <tmpl_var post.status.value><br />\n<tmpl_if post.user.isVisitor>\n	<b><tmpl_var post.user.label>:</b> <tmpl_var post.user.name><br />\n<tmpl_else>\n	<b><tmpl_var post.user.label>:</b> <a href=\"<tmpl_var post.user.profile>\"><tmpl_var post.user.name></a><br />\n</tmpl_if>\n</td>\n</tr>\n</table>','Forum/Post',1,1);
INSERT INTO template VALUES ('1','Default Thread','<h1><tmpl_var forum.title></h1><div align=\"right\">\n<script language=\"JavaScript\" type=\"text/javascript\">	<!--\n	function goLayout(){\n		location = document.layout.layoutSelect.options[document.layout.layoutSelect.selectedIndex].value\n	}\n	//-->	</script>\n\n        <form name=\"layout\"><select name=\"layoutSelect\" size=\"1\" onChange=\"goLayout()\">\n		<option value=\"<tmpl_var thread.layout.flat.url>\" <tmpl_if thread.layout.isFlat>selected=\"1\"</tmpl_if>><tmpl_var thread.layout.flat.label></option>\n		<option value=\"<tmpl_var thread.layout.nested.url>\" <tmpl_if thread.layout.isNested>selected=\"1\"</tmpl_if>><tmpl_var thread.layout.nested.label></option>\n		<option value=\"<tmpl_var thread.layout.threaded.url>\" <tmpl_if thread.layout.isThreaded>selected=\"1\"</tmpl_if>><tmpl_var thread.layout.threaded.label></option>\n	</select> </form> \n</div>\n<tmpl_if thread.layout.isFlat>\n	<tmpl_loop post_loop>\n			<a name=\"<tmpl_var post.id>\"></a>\n			<tmpl_if __ODD__>\n				<div class=\"highlight\" <tmpl_if post.isCurrent>style=\"border: 4px dotted #aaaaaa; padding: 5px;\"</tmpl_if>>\n			<tmpl_else>\n				<div <tmpl_if post.isCurrent>style=\"border: 4px dotted #aaaaaa; padding: 5px;\"</tmpl_if>>\n			</tmpl_if>\n			<tmpl_var post.full>\n		</div>\n	</tmpl_loop>\n</tmpl_if>\n\n<tmpl_if thread.layout.isNested>\n	<tmpl_loop post_loop>\n		<table width=\"100%\" cellspacing=\"0\" cellpadding=\"3\" border=\"0\">\n			<tr>\n			<tmpl_loop post.indent_loop>\n				<td width=\"20\">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp;</td>\n			</tmpl_loop>\n			<td>\n				<a name=\"<tmpl_var post.id>\"></a>\n				<tmpl_if __ODD__>\n					<div class=\"highlight\" <tmpl_if post.isCurrent>style=\"border: 4px dotted #aaaaaa; padding: 5px;\"</tmpl_if>>\n				<tmpl_else>\n					<div <tmpl_if post.isCurrent>style=\"border: 4px dotted #aaaaaa; padding: 5px;\"</tmpl_if>>\n				</tmpl_if>\n					<tmpl_var post.full>\n				</div>\n			</td>\n		</tr>\n		</table>\n	</tmpl_loop>\n</tmpl_if>\n\n<tmpl_if thread.layout.isThreaded>\n	<tmpl_var post.full>\n	<table width=\"100%\" cellspacing=\"0\" cellpadding=\"3\" border=\"0\">\n	<tr>\n		<td class=\"tableHeader\"><tmpl_var thread.subject.label></td>\n		<td class=\"tableHeader\"><tmpl_var thread.user.label></td>\n		<td class=\"tableHeader\"><tmpl_var thread.date.label></td>\n	</tr>\n	<tmpl_loop post_loop>\n		<tmpl_if post.isCurrent>\n			<tr class=\"highlight\">\n		<tmpl_else>\n			<tr>\n		</tmpl_if>\n			<td class=\"tableData\"><tmpl_loop post.indent_loop>&nbsp;&nbsp;&nbsp;</tmpl_loop><a href=\"<tmpl_var post.url>\"><tmpl_var post.subject></a></td>\n			<tmpl_if thread.root.user.isVisitor>\n				<td class=\"tableData\"><tmpl_var post.user.name></td>\n			<tmpl_else>\n				<td class=\"tableData\"><a href=\"<tmpl_var post.user.profile>\"><tmpl_var post.user.name></a></td>\n			</tmpl_if>\n			<td class=\"tableData\"><tmpl_var post.date.value> @ <tmpl_var post.time.value></td>\n		</tr>\n	</tmpl_loop>\n	</table>\n</tmpl_if>\n\n<p />\n<a href=\"<tmpl_var thread.list.url>\"><tmpl_var thread.list.label></a> &bull;\n<a href=\"<tmpl_var thread.previous.url>\"><tmpl_var thread.previous.label></a> &bull;\n<a href=\"<tmpl_var thread.next.url>\"><tmpl_var thread.next.label></a> \n<tmpl_if user.canPost>\n	&bull; <a href=\"<tmpl_var thread.new.url>\"><tmpl_var thread.new.label></a>\n	<tmpl_unless user.isVisitor>\n		&bull;\n		<tmpl_if user.isSubscribed>\n			<a href=\"<tmpl_var thread.unsubscribe.url>\"><tmpl_var thread.unsubscribe.label></a>\n		<tmpl_else>\n			<a href=\"<tmpl_var thread.subscribe.url>\"><tmpl_var thread.subscribe.label></a>\n		</tmpl_if>\n	</tmpl_unless>\n	<tmpl_if user.isModerator>\n		&bull;\n		<tmpl_if thread.isSticky>\n			<a href=\"<tmpl_var thread.unstick.url>\"><tmpl_var thread.unstick.label></a>\n		<tmpl_else>\n			<a href=\"<tmpl_var thread.stick.url>\"><tmpl_var thread.stick.label></a>\n		</tmpl_if>\n		&bull;\n		<tmpl_if thread.isLocked>\n			<a href=\"<tmpl_var thread.unlock.url>\"><tmpl_var thread.unlock.label></a>\n		<tmpl_else>\n			<a href=\"<tmpl_var thread.lock.url>\"><tmpl_var thread.lock.label></a>\n		</tmpl_if>\n	</tmpl_if>\n</tmpl_if>\n\n<tmpl_if multiplePages>\n  <div class=\"pagination\">\n    <tmpl_var previousPage>  &middot; <tmpl_var pageList> &middot; <tmpl_var nextPage>\n  </div>\n</tmpl_if>\n\n<div align=\"center\">\n<a href=\"<tmpl_var callback.url>\">-=: <tmpl_var callback.label> :=-</a>\n</div>','Forum/Thread',1,1);
INSERT INTO template VALUES ('1','Default Forum Notification','<tmpl_var notify.subscription.message>\n\n<tmpl_var post.url>','Forum/Notification',1,1);
INSERT INTO template VALUES ('1','Default Forum Search','<tmpl_var form.begin>\n<table width=\"100%\" class=\"tableMenu\">\n<tr><td align=\"right\" width=\"15%\">\n	<h1><tmpl_var search.label></h1>\n	</td>\n	<td valign=\"top\" width=\"70%\" align=\"center\">\n		<table>\n			<tr><td class=\"tableData\"><tmpl_var all.label></td><td class=\"tableData\"><tmpl_var all.form></td></tr>\'\n			<tr><td class=\"tableData\"><tmpl_var exactphrase.label></td><td class=\"tableData\"><tmpl_var exactphrase.form></td></tr>\n			<tr><td class=\"tableData\"><tmpl_var atleastone.label></td><td class=\"tableData\"><tmpl_var atleastone.form></td></tr>\n			<tr><td class=\"tableData\"><tmpl_var without.label></td><td class=\"tableData\"><tmpl_var without.form></td></tr>\n			<tr><td class=\"tableData\"><tmpl_var results.label></td><td class=\"tableData\"><tmpl_var results.form></td></tr>\n		</table>\n	</td><td width=\"15%\">\n        		<tmpl_var form.search>\n	</td>\n</tr></table>\n<tmpl_var form.end>\n<tmpl_if doit>\n	<table width=\"100%\" cellspacing=\"0\" cellpadding=\"3\" border=\"0\">\n	<tr>\n		<td class=\"tableHeader\"><tmpl_var post.subject.label></td>\n		<td class=\"tableHeader\"><tmpl_var post.user.label></td>\n		<td class=\"tableHeader\"><tmpl_var post.date.label></td>\n	</tr>\n	<tmpl_loop post_loop>\n			<tr>\n			<td class=\"tableData\"><a href=\"<tmpl_var post.url>\"><tmpl_var post.subject></a></td>\n			<tmpl_if thread.root.user.isVisitor>\n				<td class=\"tableData\"><tmpl_var post.user.name></td>\n			<tmpl_else>\n				<td class=\"tableData\"><a href=\"<tmpl_var post.user.profile>\"><tmpl_var post.user.name></a></td>\n			</tmpl_if>\n			<td class=\"tableData\"><tmpl_var post.date> @ <tmpl_var post.time></td>\n		</tr>\n	</tmpl_loop>\n	</table>\n</tmpl_if>\n\n<tmpl_if multiplePages>\n  <div class=\"pagination\">\n    <tmpl_var previousPage>  &middot; <tmpl_var pageList> &middot; <tmpl_var nextPage>\n  </div>\n</tmpl_if>','Forum/Search',1,1);
INSERT INTO template VALUES ('1000','AutoGen ^t;','<tmpl_if session.var.adminOn>\n<tmpl_var config.button>\n</tmpl_if>\n<span class=\"horizontalMenu\">\n<tmpl_loop page_loop>\n<a class=\"horizontalMenu\"\n   <tmpl_if page.newWindow>target=\"_blank\"</tmpl_if>\n   href=\"<tmpl_var page.url>\"><tmpl_var page.menuTitle></a>\n   <tmpl_unless \"__last__\"> &middot; </tmpl_unless>\n</tmpl_loop>\n</span>','Navigation',1,1);
INSERT INTO template VALUES ('1001','AutoGen ^m;','<tmpl_if session.var.adminOn>\n<tmpl_var config.button>\n</tmpl_if>\n<span class=\"horizontalMenu\">\n<tmpl_loop page_loop>\n<a class=\"horizontalMenu\" \n   <tmpl_if page.newWindow>target=\"_blank\"</tmpl_if>\n   href=\"<tmpl_var page.url>\"><tmpl_var page.menuTitle></a>\n   <tmpl_unless \"__last__\"> &middot; </tmpl_unless>\n</tmpl_loop>\n</span>','Navigation',1,1);
INSERT INTO template VALUES ('1000','Syndicated Articles','<tmpl_if displayTitle>\n    <h1><tmpl_var title></h1>\n</tmpl_if>\n\n<tmpl_if description>\n    <tmpl_var description><p />\n</tmpl_if>\n\n<h1>\n<tmpl_if channel.link>\n     <a href=\"<tmpl_var channel.link>\" target=\"_blank\"><tmpl_var channel.title></a>    \n<tmpl_else>\n     <tmpl_var channel.title>\n</tmpl_if>\n</h1>\n\n<tmpl_if channel.description>\n    <tmpl_var channel.description><p />\n</tmpl_if>\n\n\n<tmpl_loop item_loop>\n\n       <b><tmpl_var title></b>\n     <tmpl_if description>\n        <br /><tmpl_var description>\n     </tmpl_if>\n  <tmpl_if link>\n       <br /><a href=\"<tmpl_var link>\" target=\"_blank\" style=\"font-size: 9px;\">Read More...</a>    \n   </tmpl_if>\n     <br /><br />\n\n</tmpl_loop>','SyndicatedContent',1,1);
INSERT INTO template VALUES ('1','Default Submission Form','<h1><tmpl_var submission.header.label></h1><tmpl_var form.header><table><tmpl_if user.isVisitor> <tmpl_if submission.isNew><tr><td><tmpl_var visitorName.label></td><td><tmpl_var visitorName.form></td></tr></tmpl_if> </tmpl_if><tr><td><tmpl_var title.label></td><td><tmpl_var title.form></td></tr><tr><td><tmpl_var body.label></td><td><tmpl_var body.form></td></tr><tr><td><tmpl_var image.label></td><td><tmpl_var image.form></td></tr><tr><td><tmpl_var attachment.label></td><td><tmpl_var attachment.form></td></tr><tr><td><tmpl_var contentType.label></td><td><tmpl_var contentType.form></td></tr><tr><td><tmpl_var startDate.label></td><td><tmpl_var startDate.form></td></tr><tr><td><tmpl_var endDate.label></td><td><tmpl_var endDate.form></td></tr><tr><td></td><td><tmpl_var form.submit></td></tr></table><tmpl_var form.footer>','USS/SubmissionForm',1,1);
INSERT INTO template VALUES ('2','FAQ Submission Form','<h1><tmpl_var question.header.label></h1>\n\n<tmpl_var form.header>\n	<table>\n	<tmpl_if user.isVisitor> <tmpl_if submission.isNew>\n		<tr><td><tmpl_var visitorName.label></td><td><tmpl_var visitorName.form></td></tr>\n	</tmpl_if> </tmpl_if>\n	<tr><td><tmpl_var question.label></td><td><tmpl_var title.form.textarea></td></tr>\n	<tr><td><tmpl_var answer.label></td><td><tmpl_var body.form></td></tr>\n	<tr><td><tmpl_var contentType.label></td><td><tmpl_var contentType.form></td></tr>\n	<tr><td></td><td><tmpl_var form.submit></td></tr>\n	</table>\n<tmpl_var form.footer>\n','USS/SubmissionForm',1,1);
INSERT INTO template VALUES ('3','Link List Submission Form','<h1><tmpl_var link.header.label></h1>\n\n<tmpl_var form.header>\n	<table>\n	<tmpl_if user.isVisitor> <tmpl_if submission.isNew>\n		<tr><td><tmpl_var visitorName.label></td><td><tmpl_var visitorName.form></td></tr>\n	</tmpl_if> </tmpl_if>\n	<tr><td><tmpl_var title.label></td><td><tmpl_var title.form></td></tr>\n	<tr><td><tmpl_var description.label></td><td><tmpl_var body.form.textarea></td></tr>\n	<tr><td><tmpl_var contentType.label></td><td><tmpl_var contentType.form></td></tr>\n	<tr><td><tmpl_var url.label></td><td><tmpl_var userDefined1.form></td></tr>\n	<tr><td><tmpl_var newWindow.label></td><td><tmpl_var userDefined2.form.yesNo></td></tr>\n	<tr><td></td><td><tmpl_var form.submit></td></tr>\n	</table>\n<tmpl_var form.footer>\n','USS/SubmissionForm',1,1);
INSERT INTO template VALUES ('1','Default Login Box','<div class=\"loginBox\">\n<tmpl_if user.isVisitor>\n	<tmpl_var form.header>\n             <span><tmpl_var username.label><br></span>\n             <tmpl_var username.form>\n             <span><br><tmpl_var password.label><br></span>\n             <tmpl_var password.form>\n             <span><br></span>\n             <tmpl_var form.login>\n	<tmpl_var form.footer>\n	<tmpl_if session.setting.anonymousRegistration>\n                        <p><a href=\"<tmpl_var account.create.url>\"><tmpl_var account.create.label></a></p>\n	</tmpl_if>	\n<tmpl_else>\n	<tmpl_unless customText>\n		<tmpl_var hello.label> <a href=\"<tmpl_var account.display.url>\"><tmpl_var session.user.username></a>.\n                          <tmpl_var logout.label>\n	<tmpl_else>\n		<tmpl_var customText>\n	</tmpl_unless>\n</tmpl_if>\n</div>\n','Macro/L_loginBox',1,1);
INSERT INTO template VALUES ('2','Horizontal Login Box','<div class=\"loginBox\">\n<tmpl_if user.isVisitor>\n	<tmpl_var form.header>\n	<table border=\"0\" class=\"loginBox\" cellpadding=\"1\" cellspacing=\"0\">\n	<tr>\n		<td><tmpl_var username.form></td>\n		<td><tmpl_var password.form></td>\n		<td><tmpl_var form.login></td>\n	</tr>\n	<tr>\n		<td><tmpl_var username.label></td>\n		<td><tmpl_var password.label></td>\n		<td></td>\n	</tr>\n	</table>             	<tmpl_if session.setting.anonymousRegistration>\n                        <a href=\"<tmpl_var account.create.url>\"><tmpl_var account.create.label></a>\n	</tmpl_if>		<tmpl_var form.footer> \n<tmpl_else>\n	<tmpl_unless customText>\n		<tmpl_var hello.label> <a href=\"<tmpl_var account.display.url>\"><tmpl_var session.user.username></a>.\n                          <tmpl_var logout.label><br />\n	<tmpl_else>\n		<tmpl_var customText>\n	</tmpl_unless>\n</tmpl_if>\n</div>\n','Macro/L_loginBox',1,1);
INSERT INTO template VALUES ('1','Default SQL Report','<tmpl_if displayTitle>\n    <h1><tmpl_var title></h1>\n</tmpl_if>\n\n<tmpl_if description>\n    <tmpl_var description><p />\n</tmpl_if>\n\n<tmpl_if debugMode>\n	<ul>\n	<tmpl_loop debug_loop>\n		<li><tmpl_var debug.output></li>\n	</tmpl_loop>\n	</ul>\n</tmpl_if>\n\n<table width=\"100%\">\n<tr>\n	<tmpl_loop columns_loop>\n		<td class=\"tableHeader\"><tmpl_var column.name></td>\n	</tmpl_loop>\n</tr>\n<tmpl_loop rows_loop>\n	<tr>\n		<tmpl_loop row.field_loop>\n			<td class=\"tableData\"><tmpl_var field.value></td>\n		</tmpl_loop>\n	</tr>\n</tmpl_loop>\n</table>\n\n<tmpl_if pagination.pageCount.isMultiple>\n  <div class=\"pagination\">\n    <tmpl_var pagination.previousPage>   <tmpl_var pagination.pageList.upTo20>  <tmpl_var pagination.nextPage>\n  </div>\n</tmpl_if>','SQLReport',1,1);
INSERT INTO template VALUES ('1','Default Messsage Log Display Template','<h1><tmpl_var displayTitle></h1>\r\n\r\n<table width=\"100%\" cellspacing=1 cellpadding=2 border=0>\r\n<tr>\r\n   <td class=\"tableHeader\">\r\n      <tmpl_var message.subject.label>\r\n   </td>\r\n   <td class=\"tableHeader\">\r\n      <tmpl_var message.status.label>\r\n   </td>\r\n   <td class=\"tableHeader\">\r\n      <tmpl_var message.dateOfEntry.label>\r\n   </td>\r\n</tr>\r\n<tmpl_if message.noresults>\r\n   <tr>\r\n       <td class=\"tableData\">\r\n          <tmpl_var message.noresults>\r\n       </td>\r\n       <td class=\"tableData\">\r\n          &nbsp;\r\n       </td>\r\n       <td class=\"tableData\">\r\n          &nbsp;\r\n       </td>\r\n   </tr>\r\n<tmpl_else>\r\n   <tmpl_loop message.loop>\r\n      <tr>\r\n         <td class=\"tableData\">\r\n            <tmpl_var message.subject>\r\n         </td>\r\n         <td class=\"tableData\">\r\n            <tmpl_var message.status>\r\n         </td>\r\n         <td class=\"tableData\">\r\n            <tmpl_var message.dateOfEntry>\r\n         </td>\r\n     </tr>\r\n  </tmpl_loop>\r\n</tmpl_if>\r\n</table>\r\n<tmpl_if message.multiplePages>\r\n  <div class=\"pagination\">\r\n    <tmpl_var message.previousPage>  &middot; <tmpl_var message.pageList> &middot; <tmpl_var message.nextPage>\r\n  </div>\r\n</tmpl_if>\r\n<div class=\"accountOptions\">\r\n   <ul>\r\n      <tmpl_loop message.accountOptions>\r\n         <li><tmpl_var options.display>\r\n      </tmpl_loop>\r\n   </ul>\r\n</div>','Operation/MessageLog/View',1,1);
INSERT INTO template VALUES ('1','Default MessageLog Message Template','<tmpl_var displayTitle>\r\n<b><tmpl_var message.subject></b><br>\r\n<tmpl_var message.dateOfEntry><br>\r\n<tmpl_var message.status><br><br>\r\n<tmpl_var message.text><p>\r\n\r\n<div class=\"accountOptions\">\r\n   <ul>\r\n      <tmpl_if message.takeAction>\r\n         <li><tmpl_var message.takeAction>\r\n      </tmpl_if>\r\n      <tmpl_loop message.accountOptions>\r\n         <li><tmpl_var options.display>\r\n      </tmpl_loop>\r\n   </ul>\r\n</div>\r\n\r\n\r\n','Operation/MessageLog/Message',1,1);
INSERT INTO template VALUES ('1','Default Edit Profile Template','<tmpl_var displayTitle>\r\n\r\n<tmpl_if profile.message>\r\n   <tmpl_var profile.message>\r\n</tmpl_if>\r\n\r\n<tmpl_var profile.form.header>\r\n<table >\r\n<tmpl_var profile.form.hidden>\r\n\r\n<tmpl_loop profile.form.elements>\r\n     <tr>\r\n       <td class=\"tableHeader\" valign=\"top\" colspan=\"2\">\r\n         <tmpl_var profile.form.category>\r\n       </td>\r\n     </tr>\r\n \r\n <tmpl_loop profile.form.category.loop>\r\n   <tr>\r\n    <td class=\"formDescription\" valign=\"top\">\r\n      <tmpl_var profile.form.element.label>\r\n    </td>\r\n    <td class=\"tableData\">\r\n      <tmpl_var profile.form.element>\r\n      <tmpl_if profile.form.element.subtext>\r\n        <span class=\"formSubtext\">\r\n         <tmpl_var profile.form.element.subtext>\r\n        </span>\r\n      </tmpl_if>\r\n    </td>\r\n   </tr>\r\n </tmpl_loop>\r\n</tmpl_loop>\r\n<tmpl_loop create.form.profile>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var profile.formElement.label></td>\r\n   <td class=\"tableData\"><tmpl_var profile.formElement></td>\r\n</tr>\r\n</tmpl_loop>\r\n<tr>\r\n <td class=\"formDescription\" valign=\"top\"></td>\r\n <td class=\"tableData\">\r\n     <tmpl_var profile.form.submit>\r\n </td>\r\n</tr>\r\n</table>\r\n<tmpl_var create.form.footer>\r\n\r\n<div class=\"accountOptions\">\r\n   <ul>\r\n      <tmpl_loop profile.accountOptions>\r\n         <li><tmpl_var options.display>\r\n      </tmpl_loop>\r\n   </ul>\r\n</div>','Operation/Profile/Edit',1,1);
INSERT INTO template VALUES ('1','Default Profile Display Template','<tmpl_var displayTitle>\r\n\r\n<table>\r\n  <tmpl_loop profile.elements>\r\n    <tr>\r\n    <tmpl_if profile.category>\r\n      <td colspan=\"2\" class=\"tableHeader\">\r\n        <tmpl_var profile.category>\r\n      </td>\r\n    <tmpl_else>\r\n      <td class=\"tableHeader\">\r\n         <tmpl_var profile.label>\r\n      </td>\r\n      <td class=\"tableData\">\r\n         <tmpl_var profile.value>\r\n      </td>\r\n    </tmpl_if>   \r\n    </tr>\r\n  </tmpl_loop>\r\n</table>\r\n<div class=\"accountOptions\">\r\n   <ul>\r\n      <tmpl_loop profile.accountOptions>\r\n         <li><tmpl_var options.display>\r\n      </tmpl_loop>\r\n   </ul>\r\n</div>','Operation/Profile/View',1,1);
INSERT INTO template VALUES ('1','HTMLArea','^JavaScript(\"<tmpl_var session.config.extrasURL>/textFix.js\");\r\n<tmpl_if htmlArea.supported>\r\n   <tmpl_if popup>\r\n      <script language=\"JavaScript\">\r\n	var formObj;\r\n        var extrasDir=\"<tmpl_var session.config.extrasURL>\";\r\n        function openEditWindow(obj) {\r\n           formObj = obj;\r\n           window.open(\"<tmpl_var session.config.extrasURL>/htmlArea/editor.html\",\"editWindow\",\"width=490,height=400,resizable=1\");\r\n        }\r\n        function setContent(content) {\r\n           formObj.value = content;\r\n        }\r\n      </script>\r\n   <tmpl_else>\r\n   ^JavaScript(\"<tmpl_var session.config.extrasURL>/htmlArea/editor.js\");\r\n   <script>\r\n var master = window;\n     _editor_url = \"<tmpl_var session.config.extrasURL>/htmlArea/\";\r\n   </script>      \r\n   </tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_var textarea>\r\n\r\n<tmpl_if htmlArea.supported>\r\n   <script language=\"Javascript1.2\">\r\n      editor_generate(\"<tmpl_var form.name>\");\r\n   </script>\r\n</tmpl_if>\r\n','richEditor',1,1);
INSERT INTO template VALUES ('5','lastResort','^JavaScript(\"<tmpl_var session.config.extrasURL>/textFix.js\");\r\n\r\n<script language=\"JavaScript\">\r\n      var formObj;\r\n      var extrasDir=\"<tmpl_var session.config.extrasURL>\";\r\n      function openEditWindow(obj) {\r\n         formObj = obj;\r\n         window.open(\"<tmpl_var session.config.extrasURL>/lastResortEdit.html\",\"editWindow\",\"width=500,height=410\");\r\n      }\r\n      function setContent(content) {\r\n         formObj.value = content;\r\n      } \r\n</script>\r\n\r\n<tmpl_var button>\r\n\r\n<tmpl_var textarea>','richEditor',1,1);
INSERT INTO template VALUES ('2','EditOnPro2','^JavaScript(\"<tmpl_var session.config.extrasURL>/textFix.js\");\r\n\r\n<script language=\"JavaScript\">\r\nvar formObj;\r\nfunction openEditWindow(obj) {\r\n   formObj = obj;\r\n   window.open(\"<tmpl_var session.config.extrasURL>/eopro.html\",\"editWindow\",\"width=720,height=450,resizable=1\");\r\n} \r\n</script>','richEditor',1,1);
INSERT INTO template VALUES ('6','HTMLArea 3 (Mozilla / IE)','^JavaScript(\"<tmpl_var session.config.extrasURL>/textFix.js\");\r\n<tmpl_if htmlArea3.supported> \r\n^RawHeadTags(\"\n<script type=\'text/javascript\'> \n _editor_url = \'<tmpl_var session.config.extrasURL>/htmlArea3/\'; \n _editor_lang = \'en\'; \n</script> \n\");\r\n^JavaScript(\"<tmpl_var session.config.extrasURL>/htmlArea3/htmlarea.js\"); \r\n^RawHeadTags(\"\n<script language=\'JavaScript\'> \r\n HTMLArea.loadPlugin(\'TableOperations\'); \r\n</script>\n\");\n<script language=\"JavaScript\"> \nfunction initEditor() { \r\n  editor = new HTMLArea(\"<tmpl_var form.name>\"); \r\n  editor.registerPlugin(TableOperations); \r\n\r\n  setTimeout(function() { \r\n   editor.generate(); \r\n   }, 500); \r\n  return false; \r\n} \r\nwindow.setTimeout(\"initEditor()\", 250); \r\n</script> \r\n</tmpl_if> \r\n\r\n<tmpl_var textarea> ','richEditor',1,1);
INSERT INTO template VALUES ('1','Default Overview Report','<h1><tmpl_var title></h1>\n\n<tmpl_if user.canViewReports>\n	<a href=\"<tmpl_var survey.url>\"><tmpl_var survey.label></a> \n	&bull;\n	<a href=\"<tmpl_var report.gradebook.url>\"><tmpl_var report.gradebook.label></a> \n	&bull;\n	<a href=\"<tmpl_var delete.all.responses.url>\"><tmpl_var delete.all.responses.label></a> \n	<br />\n	<a href=\"<tmpl_var export.answers.url>\"><tmpl_var export.answers.label></a> \n	&bull;\n	<a href=\"<tmpl_var export.questions.url>\"><tmpl_var export.questions.label></a> \n	&bull;\n	<a href=\"<tmpl_var export.responses.url>\"><tmpl_var export.responses.label></a> \n	&bull;\n	<a href=\"<tmpl_var export.composite.url>\"><tmpl_var export.composite.label></a> \n</tmpl_if>\n\n<br /> <br />\n\n<script>\nfunction toggleDiv(divId) {\n   if (document.getElementById(divId).style.visibility == \"none\") {\n	document.getElementById(divId).style.display = \"block\";\n   } else {\n	document.getElementById(divId).style.display = \"none\";	\n   }\n}\n</script>\n\n<tmpl_loop question_loop>\n	<b><tmpl_var question></b>\n              <tmpl_if question.isRadioList>\n                        <table class=\"tableData\">\n                        <tr class=\"tableHeader\"><td width=\"60%\"><tmpl_var answer.label></td>\n                                <td width=\"20%\"><tmpl_var response.count.label></td>\n                                <td width=\"20%\"><tmpl_var response.percent.label></td></tr>\n                        <tmpl_loop answer_loop>\n                                <tmpl_if answer.isCorrect>\n                                        <tr class=\"highlight\">\n                                <tmpl_else>\n                                        <tr>\n                                </tmpl_if>\n                                	<td><tmpl_var answer></td>\n                                	<td><tmpl_var answer.response.count></td>\n                                	<td><tmpl_var answer.response.percent></td>\n			<tmpl_if allowComment>\n                        			<td><a href=\"#\" onClick=\"toggle(\'comment<tmpl_var answer.id>\');\"><tmpl_var show.comments.label></a></td>\n			</tmpl_if>\n                               </tr>\n		<tmpl_if question.allowComment>\n			<tr id=\"comment<tmpl_var answer.id>\">\n				<td colspan=\"3\">\n					<tmpl_loop comment_loop>\n						<p>\n						<tmpl_var answer.comment>\n						</p>\n					</tmpl_loop>\n				</td>\n			</tr>\n		</tmpl_if>\n		</tmpl_loop>\n                        </table>\n               <tmpl_else>\n                        <br />\n		<a href=\"#\" onClick=\"toggle(\'response<tmpl_var question.id>\');\"><tmpl_var show.answers.label></a>\n		<br />\n		<div id=\"response<tmpl_var question.id>\">\n			<tmpl_loop answer_loop>\n				<p>\n				<tmpl_var answer.response>\n				</p>\n                			<tmpl_if question.allowComment>\n					<blockquote>\n					<tmpl_var answer.comment>\n					</blockquote>\n                			</tmpl_if>\n			</tmpl_loop>\n		</div>\n                </tmpl_if>\n	<br /><br /><br />\n\n</tmpl_loop>\n\n\n<tmpl_if pagination.pageCount.isMultiple>\n  <div class=\"pagination\">\n    <tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>\n  </div>\n</tmpl_if>\n\n','Survey/Overview',1,1);
INSERT INTO template VALUES ('1','Default Gradebook Report','<h1><tmpl_var title></h1>\n\n<tmpl_if user.canViewReports>\n	<a href=\"<tmpl_var survey.url>\"><tmpl_var survey.label></a> \n	&bull;\n	<a href=\"<tmpl_var report.overview.url>\"><tmpl_var report.overview.label></a> \n	&bull;\n	<a href=\"<tmpl_var delete.all.responses.url>\"><tmpl_var delete.all.responses.label></a> \n	<br />\n	<a href=\"<tmpl_var export.answers.url>\"><tmpl_var export.answers.label></a> \n	&bull;\n	<a href=\"<tmpl_var export.questions.url>\"><tmpl_var export.questions.label></a> \n	&bull;\n	<a href=\"<tmpl_var export.responses.url>\"><tmpl_var export.responses.label></a> \n	&bull;\n	<a href=\"<tmpl_var export.composite.url>\"><tmpl_var export.composite.label></a> \n</tmpl_if>\n\n<br /> <br />\n\n<table class=\"tableData\">\n<tr class=\"tableHeader\"><td width=\"60%\"><tmpl_var response.user.label></td>\n                <td width=\"20%\"><tmpl_var response.count.label></td>\n                <td width=\"20%\"><tmpl_var response.percent.label></td></tr>\n<tmpl_loop response_loop>\n<tr>\n	<td><a href=\"<tmpl_var response.url>\"><tmpl_var response.user.name></a></td>\n	<td><tmpl_var response.count.correct>/<tmpl_var question.count></td>\n             <td><tmpl_var response.percent>%</td>\n</tr>\n</tmpl_loop>\n</table>\n\n\n<tmpl_if pagination.pageCount.isMultiple>\n  <div class=\"pagination\">\n    <tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>\n  </div>\n</tmpl_if>\n','Survey/Gradebook',1,1);
INSERT INTO template VALUES ('1','Default Survey','<tmpl_if displayTitle>\n    <h1><tmpl_var title></h1>\n</tmpl_if>\n\n\n<tmpl_if description>\n  <tmpl_var description><p />\n</tmpl_if>\n\n\n<tmpl_if user.canTakeSurvey>\n	<tmpl_if response.isComplete>\n		<tmpl_if mode.isSurvey>\n			<tmpl_var thanks.survey.label>\n		<tmpl_else>\n			<tmpl_var thanks.quiz.label>\n			<div align=\"center\">\n				<b><tmpl_var questions.correct.count.label>:</b> <tmpl_var questions.correct.count> / <tmpl_var questions.total>\n				<br />\n				<b><tmpl_var questions.correct.percent.label>:</b><tmpl_var questions.correct.percent>% \n			</div>\n		</tmpl_if>\n		<tmpl_if user.canRespondAgain>\n			<br /> <br /> <a href=\"<tmpl_var start.newResponse.url>\"><tmpl_var start.newResponse.label></a>\n		</tmpl_if>\n	<tmpl_else>\n		<tmpl_if response.id>\n			<tmpl_var form.header>\n			<table width=\"100%\" cellpadding=\"3\" cellspacing=\"0\" border=\"0\" class=\"content\">\n				<tr>\n					<td valign=\"top\">\n					<tmpl_loop question_loop>\n						<p><tmpl_var question.question></p>\n						<tmpl_var question.answer.label><br />\n						<tmpl_var question.answer.field><br />\n						<br />\n						<tmpl_if question.allowComment>\n							<tmpl_var question.comment.label><br />\n							<tmpl_var question.comment.field><br />\n						</tmpl_if>\n					</tmpl_loop>\n					</td>\n					<td valign=\"top\" nowrap=\"1\">\n						<b><tmpl_var questions.sofar.label>:</b> <tmpl_var questions.sofar.count> / <tmpl_var questions.total> <br />\n						<tmpl_unless mode.isSurvey>\n							<b><tmpl_var questions.correct.count.label>:</b> <tmpl_var questions.correct.count> / <tmpl_var questions.sofar.count><br />\n							<b><tmpl_var questions.correct.percent.label>:</b><tmpl_var questions.correct.percent>% / 100%<br />\n						</tmpl_unless>\n					</td>\n				</tr>\n			</table>\n			<div align=\"center\"><tmpl_var form.submit></div>\n			<tmpl_var form.footer>\n		<tmpl_else>\n			<a href=\"<tmpl_var start.newResponse.url>\"><tmpl_var start.newResponse.label></a>\n		</tmpl_if>\n	</tmpl_if>\n<tmpl_else>\n	<tmpl_if mode.isSurvey>\n		<tmpl_var survey.noprivs.label>\n	<tmpl_else>\n		<tmpl_var quiz.noprivs.label>\n	</tmpl_if>\n</tmpl_if>\n<br />\n<br />\n<tmpl_if user.canViewReports>\n	<a href=\"<tmpl_var report.gradebook.url>\"><tmpl_var report.gradebook.label></a> \n	&bull;\n	<a href=\"<tmpl_var report.overview.url>\"><tmpl_var report.overview.label></a> \n	&bull;\n	<a href=\"<tmpl_var delete.all.responses.url>\"><tmpl_var delete.all.responses.label></a> \n	<br />\n	<a href=\"<tmpl_var export.answers.url>\"><tmpl_var export.answers.label></a> \n	&bull;\n	<a href=\"<tmpl_var export.questions.url>\"><tmpl_var export.questions.label></a> \n	&bull;\n	<a href=\"<tmpl_var export.responses.url>\"><tmpl_var export.responses.label></a> \n	&bull;\n	<a href=\"<tmpl_var export.composite.url>\"><tmpl_var export.composite.label></a> \n</tmpl_if>\n\n\n<tmpl_if session.var.adminOn>\n	<p>\n		<a href=\"<tmpl_var question.add.url>\"><tmpl_var question.add.label></a>\n	</p>\n	<tmpl_loop question.edit_loop>\n		<tmpl_var question.edit.controls>\n          	<tmpl_var question.edit.question>\n		<br />\n        </tmpl_loop>\n</tmpl_if>\n','Survey',1,1);
INSERT INTO template VALUES ('1','Default Response','<h1><tmpl_var title></h1>\n\n<tmpl_if user.canViewReports>\n	<a href=\"<tmpl_var survey.url>\"><tmpl_var survey.label></a> \n	&bull;\n	<a href=\"<tmpl_var report.overview.url>\"><tmpl_var report.overview.label></a> \n	&bull;\n	<a href=\"<tmpl_var report.gradebook.url>\"><tmpl_var report.gradebook.label></a> \n</tmpl_if>\n<a href=\"<tmpl_var delete.url>\"><tmpl_var delete.label></a><p/>\n<b><tmpl_var start.date.label>:</b> <tmpl_var start.date.human> <tmpl_var start.time.human><br />\n<b><tmpl_var end.date.label>:</b> <tmpl_var end.date.human> <tmpl_var end.time.human><br />\n<b><tmpl_var duration.label>:</b> <tmpl_var duration.minutes> <tmpl_var duration.minutes.label> <tmpl_var duration.seconds> <tmpl_var duration.seconds.label>\n\n<p/>\n<tmpl_loop question_loop>\n\n               <b><tmpl_var question></b><br />\n                  <table class=\"tableData\" width=\"100%\">\n<tmpl_if question.isRadioList>\n               \n    <tr><td valign=\"top\" class=\"tableHeader\" width=\"25%\">\n                               <tmpl_var answer.label></td><td width=\"75%\">\n                   <tmpl_var question.answer>                       \n</td></tr>\n        </tmpl_if>\n               <tr><td width=\"25%\" valign=\"top\" class=\"tableHeader\"><tmpl_var response.label></td>\n               \n<td width=\"75%\"><tmpl_var question.response></td></tr>\n                <tmpl_if question.comment>\n                        <tr><td valign=\"top\" class=\"tableHeader\">\n                                <tmpl_var comment.label> </td>\n                                <td><tmpl_var question.comment></td></tr>\n               </tmpl_if>\n\n       </table><p/>\n</tmpl_loop>','Survey/Response',1,1);
INSERT INTO template VALUES ('4','Tab Form','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if error_loop>\r\n	<ul>\r\n		<tmpl_loop error_loop>\r\n			<li><b><tmpl_var error.message></b>\r\n			</tmpl_loop>\r\n	</ul>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n	<tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_if canEdit>\r\n	<a href=\"<tmpl_var entryList.url>\"><tmpl_var entryList.label></a>\r\n		&middot; <a href=\"<tmpl_var export.tab.url>\"><tmpl_var export.tab.label></a>\r\n	<tmpl_if entryId>\r\n		&middot; <a href=\"<tmpl_var delete.url>\"><tmpl_var delete.label></a>\r\n	</tmpl_if>\r\n	<tmpl_if session.var.adminOn>\r\n		&middot; <a href=\"<tmpl_var addField.url>\"><tmpl_var addField.label></a>\r\n		&middot; <a href=\"<tmpl_var addTab.url>\"><tmpl_var addTab.label></a>\r\n	</tmpl_if>\r\n<p /> \r\n</tmpl_if>\r\n<tmpl_var form.start>\r\n<link href=\"/extras/tabs/tabs.css\" rel=\"stylesheet\" rev=\"stylesheet\" type=\"text/css\">\r\n<div class=\"tabs\">\r\n	<tmpl_loop tab_loop>\r\n		<span onclick=\"toggleTab(<tmpl_var tab.sequence>)\" id=\"tab<tmpl_var tab.sequence>\" class=\"tab\"><tmpl_var tab.label>\r\n		<tmpl_if session.var.adminOn>\r\n			<tmpl_if canEdit>\r\n				<tmpl_var tab.controls>\r\n			</tmpl_if>\r\n		</tmpl_if>\r\n		</span>\r\n	</tmpl_loop>\r\n</div>\r\n<tmpl_loop tab_loop>\r\n	<tmpl_var tab.start>\r\n		<table>\r\n			<tmpl_loop tab.field_loop>\r\n				<tmpl_unless tab.field.isHidden>\r\n						<tr>\r\n							<td class=\"formDescription\" valign=\"top\">\r\n								<tmpl_if session.var.adminOn>\r\n									<tmpl_if canEdit>\r\n										<tmpl_var tab.field.controls>\r\n									</tmpl_if>\r\n								</tmpl_if>\r\n								<tmpl_var tab.field.label>\r\n							</td>\r\n							<td class=\"tableData\" valign=\"top\">\r\n								<tmpl_if tab.field.isDisplayed>\r\n									<tmpl_var tab.field.value>\r\n								<tmpl_else>\r\n									<tmpl_var tab.field.form>\r\n								</tmpl_if>\r\n								<tmpl_if tab.field.isRequired>*</tmpl_if>\r\n								<span class=\"formSubtext\">\r\n									<br />\r\n									<tmpl_var tab.field.subtext>\r\n								</span>\r\n							</td>\r\n						</tr>\r\n				</tmpl_unless>\r\n			</tmpl_loop>\r\n			<tr>\r\n				<td colspan=\"2\">\r\n					<span class=\"tabSubtext\"><tmpl_var tab.subtext></span>\r\n				</td>\r\n			</tr>\r\n		</table>\r\n		<br>\r\n		<div><input type=\"submit\" value=\"save\"></div>\r\n	<tmpl_var tab.end>\r\n</tmpl_loop>\r\n<tmpl_var tab.init>\r\n<tmpl_var form.end>\r\n','DataForm',1,1);
INSERT INTO template VALUES ('1','Xmethods: getTemp','<h1><tmpl_var title></h1>\n\n<tmpl_if description>\n  <tmpl_var description><br /><br />\n</tmpl_if>\n\n\r\n<tmpl_if results>\r\n  <tmpl_loop results>\r\n    The current temp is: <tmpl_var result>\r\n  </tmpl_loop>\r\n<tmpl_else>\r\n  Failed to retrieve temp.\r\n</tmpl_if>','WSClient',1,1);
INSERT INTO template VALUES ('2','Google: doGoogleSearch','<style>\n.googleDetail {\n  font-size: 9px;\n}\n</style>\n\n<h1><tmpl_var title></h1>\n\n<tmpl_if description>\n  <tmpl_var description><br /><br />\n</tmpl_if>\n\n<form method=\"post\">\n <input type=\"hidden\" name=\"func\" value=\"view\">\n <input type=\"hidden\" name=\"wid\" value=\"<tmpl_var wobjectId>\">\n <input type=\"hidden\" name=\"targetWobjects\" value=\"doGoogleSearch\">\n <input type=\"text\" name=\"q\"><input type=\"submit\" value=\"Search\">\n</form>\n\n<tmpl_if results>\n  <tmpl_loop results>\n   <tmpl_if resultElements>\n      <p> You searched for <b><tmpl_var searchQuery></b>. We found around <tmpl_var estimatedTotalResultsCount> matching records.</p>\n   </tmpl_if>\n\n   <tmpl_loop resultElements>\n     <a href=\"<tmpl_var URL>\">\n	<tmpl_if title>\n		    <tmpl_var title>\n	<tmpl_else>\n                    <tmpl_var url>\n        </tmpl_if>\n     </a><br />\n        <tmpl_if snippet>\n            <tmpl_var snippet><br />\n        </tmpl_if>\n        <div class=\"googleDetail\">\n        <tmpl_if summary>\n            <b>Description:</b> <tmpl_var summary><br />\n        </tmpl_if>\n        <a href=\"<tmpl_var URL>\"><tmpl_var URL></a>\n     <tmpl_if cachedSize>\n           - <tmpl_var cachedSize>\n     </tmpl_if>\n     </div><br />\n    </tmpl_loop>\n  </tmpl_loop>\n<tmpl_else>\n   Could not retrieve results from Google.\n</tmpl_if>','WSClient',1,1);
INSERT INTO template VALUES ('1','Default Admin Bar','<script language=\"JavaScript\" type=\"text/javascript\">   <!--\r\n        function goContent(){\r\n                location = document.content.contentSelect.options[document.content.contentSelect.selectedIndex].value\r\n        }\r\n        function goAdmin(){\r\n                location = document.admin.adminSelect.options[document.admin.adminSelect.selectedIndex].value\r\n        }\r\n        //-->   </script>\r\n \r\n<div class=\"adminBar\">\r\n<table class=\"adminBar\" cellpadding=\"3\" cellspacing=\"0\" border=\"0\">\r\n	<tr>\r\n        		<form name=\"content\"> <td>\r\n<select name=\"contentSelect\" onChange=\"goContent()\">\r\n<option value=\"\"><tmpl_var addcontent.label></option>\r\n<option value=\"<tmpl_var addpage.url>\"><tmpl_var addpage.label></option>\r\n<optgroup label=\"<tmpl_var clipboard.label>\">	\r\n<tmpl_loop clipboard_loop>\r\n<option value=\"<tmpl_var clipboard.url>\"><tmpl_var clipboard.label></option>\r\n</tmpl_loop>\r\n</optgroup>\r\n<optgroup label=\"<tmpl_var contentTypes.label>\">	\r\n<tmpl_loop contentTypes_loop>\r\n<option value=\"<tmpl_var contentType.url>\"><tmpl_var contentType.label></option>\r\n</tmpl_loop>\r\n</optgroup>\r\n<optgroup label=\"<tmpl_var packages.label>\">	\r\n<tmpl_loop package_loop>\r\n<option value=\"<tmpl_var package.url>\"><tmpl_var package.label></option>\r\n</tmpl_loop>\r\n</optgroup>\r\n</select>\r\n		</td> </form>\r\n\r\n        		<form name=\"admin\"> <td align=\"center\">\r\n			<select name=\"adminSelect\" onChange=\"goAdmin()\">\r\n				<option value=\"\"><tmpl_var admin.label></option>\r\n				<tmpl_loop admin_loop>\r\n					<option value=\"<tmpl_var admin.url>\"><tmpl_var admin.label></option>\r\n				</tmpl_loop>\r\n			</select>\r\n		</td> </form>\r\n        	</tr>\r\n</table>\r\n</div>\r\n','Macro/AdminBar',1,1);
INSERT INTO template VALUES ('2','DHTML Admin Bar','^JavaScript(\"<tmpl_var session.config.extrasURL>/coolmenus/coolmenus4.js\");\r\n<style type=\"text/css\">\r\n                                                                                                                                                          \r\n.adminBarTop,.adminBarTopOver,.adminBarSub,.adminBarSubOver{position:absolute; overflow:hidden; cursor:pointer; cursor:hand}\r\n.adminBarTop,.adminBarTopOver{padding:4px; font-size:12px; font-weight:bold}\r\n.adminBarTop{color:white; border: 1px solid #aaaaaa; }\r\n.adminBarTopOver,.adminBarSubOver{color:#EC4300;}\r\n.adminBarSub,.adminBarSubOver{padding:2px; font-size:11px; font-weight:bold}\r\n.adminBarSub{color: white; background-color: #666666; layer-background-color: #666666;}\r\n.adminBarSubOver,.adminBarSubOver,.adminBarBorder,.adminBarBkg{layer-background-color: black; background-color: black;}\r\n.adminBarBorder{position:absolute; visibility:hidden; z-index:300}\r\n.adminBarBkg{position:absolute; width:10; height:10; visibility:hidden; }\r\n</style>\r\n\r\n<script language=\"JavaScript1.2\">\r\n/*****************************************************************************\nCopyright (c) 2001 Thomas Brattli (webmaster@dhtmlcentral.com)\n                                                                                                                                                             \nDHTML coolMenus - Get it at coolmenus.dhtmlcentral.com\nVersion 4.0_beta\nThis script can be used freely as long as all copyright messages are\nintact.\n                                                                                                                                                             \nExtra info - Coolmenus reference/help - Extra links to help files ****\nCSS help: http://192.168.1.31/projects/coolmenus/reference.asp?m=37\nGeneral: http://coolmenus.dhtmlcentral.com/reference.asp?m=35\nMenu properties: http://coolmenus.dhtmlcentral.com/properties.asp?m=47\nLevel properties: http://coolmenus.dhtmlcentral.com/properties.asp?m=48\nBackground bar properties: http://coolmenus.dhtmlcentral.com/properties.asp?m=49\nItem properties: http://coolmenus.dhtmlcentral.com/properties.asp?m=50\n******************************************************************************/\nadminBar=new makeCM(\"adminBar\"); \r\n\r\n//menu properties\r\nadminBar.resizeCheck=1; \r\nadminBar.rows=1;  \r\nadminBar.onlineRoot=\"\"; \r\nadminBar.pxBetween =0;\r\nadminBar.fillImg=\"\"; \r\nadminBar.fromTop=0; \r\nadminBar.fromLeft=30; \r\nadminBar.wait=600; \r\nadminBar.zIndex=10000;\r\nadminBar.menuPlacement=\"left\";\r\n\r\n//background bar properties\r\nadminBar.useBar=1; \r\nadminBar.barWidth=\"\"; \r\nadminBar.barHeight=\"menu\"; \r\nadminBar.barX=0;\r\nadminBar.barY=\"menu\"; \r\nadminBar.barClass=\"adminBarBkg\";\r\nadminBar.barBorderX=0; \r\nadminBar.barBorderY=0;\r\n\r\nadminBar.level[0]=new cm_makeLevel(160,20,\"adminBarTop\",\"adminBarTopOver\",1,1,\"adminBarBorder\",0,\"bottom\",0,0,0,0,0);\r\nadminBar.level[1]=new cm_makeLevel(160,18,\"adminBarSub\",\"adminBarSubOver\",1,1,\"adminBarBorder\",0,\"right\",0,5,\"menu_arrow.gif\",10,10);\r\n\r\n\r\nadminBar.makeMenu(\'addcontent\',\'\',\'<tmpl_var addcontent.label>\',\'\');\r\n\r\n\r\nadminBar.makeMenu(\'clipboard\',\'addcontent\',\'<tmpl_var clipboard.label> &raquo;\',\'\');\r\n<tmpl_loop clipboard_loop> \r\n	adminBar.makeMenu(\'clipboard<tmpl_var clipboard.count>\',\'clipboard\',\'<tmpl_var clipboard.label>\',\'<tmpl_var clipboard.url>\');\r\n</tmpl_loop>\r\n\r\n\r\nadminBar.makeMenu(\'contentTypes\',\'addcontent\',\'<tmpl_var contentTypes.label> &raquo;\',\'\');\r\n<tmpl_loop contentTypes_loop> \r\n	adminBar.makeMenu(\'contentTypes<tmpl_var contentType.count>\',\'contentTypes\',\'<tmpl_var contentType.label>\',\'<tmpl_var contentType.url>\');\r\n</tmpl_loop>\r\n\r\n<tmpl_if packages.canAdd>\r\nadminBar.makeMenu(\'packages\',\'addcontent\',\'<tmpl_var packages.label> &raquo;\',\'\');\r\n<tmpl_loop package_loop> \r\n	adminBar.makeMenu(\'package<tmpl_var package.count>\',\'packages\',\'<tmpl_var package.label>\',\'<tmpl_var package.url>\');\r\n</tmpl_loop>\r\n</tmpl_if>\r\n\r\nadminBar.makeMenu(\'page\',\'addcontent\',\'<tmpl_var addpage.label>\',\'<tmpl_var addpage.url>\');\r\n\r\nadminBar.makeMenu(\'admin\',\'\',\'<tmpl_var admin.label>\',\'\');\r\n<tmpl_loop admin_loop> \r\n	adminBar.makeMenu(\'admin<tmpl_var admin.count>\',\'admin\',\'<tmpl_var admin.label>\',\'<tmpl_var admin.url>\');\r\n</tmpl_loop>\r\n \r\nadminBar.construct()\r\n</script>\r\n','Macro/AdminBar',1,1);
INSERT INTO template VALUES ('2','crumbTrail','<tmpl_if session.var.adminOn>\r\n<tmpl_var config.button>\r\n</tmpl_if>\r\n<span class=\"crumbTrail\">\r\n<tmpl_loop page_loop>\r\n<a class=\"crumbTrail\" \r\n   <tmpl_if page.newWindow>target=\"_blank\"</tmpl_if>\r\n   href=\"<tmpl_var page.url>\"><tmpl_var page.menuTitle></a>\r\n   <tmpl_unless \"__last__\"> &gt; </tmpl_unless>\r\n</tmpl_loop>\r\n</span>','Navigation',1,1);
INSERT INTO template VALUES ('1','verticalMenu','<tmpl_if session.var.adminOn>\r\n<tmpl_var config.button><br>\r\n</tmpl_if>\r\n<span class=\"verticalMenu\">\r\n<tmpl_loop page_loop>\r\n<tmpl_var page.indent><a class=\"verticalMenu\" \r\n   <tmpl_if page.newWindow>target=\"_blank\"</tmpl_if> href=\"<tmpl_var page.url>\">\r\n   <tmpl_if page.isCurrent>\r\n      <span class=\"selectedMenuItem\"><tmpl_var page.menuTitle></span>\r\n   <tmpl_else><tmpl_var page.menuTitle></tmpl_if></a><br>\r\n</tmpl_loop>\r\n</span>','Navigation',1,1);
INSERT INTO template VALUES ('3','horizontalMenu','<tmpl_if session.var.adminOn>\r\n<tmpl_var config.button>\r\n</tmpl_if>\r\n<span class=\"horizontalMenu\">\r\n<tmpl_loop page_loop>\r\n<a class=\"horizontalMenu\" \r\n   <tmpl_if page.newWindow>target=\"_blank\"</tmpl_if>\r\n   href=\"<tmpl_var page.url>\"><tmpl_var page.menuTitle></a>\r\n   <tmpl_unless \"__last__\"> &middot; </tmpl_unless>\r\n</tmpl_loop>\r\n</span>','Navigation',1,1);
INSERT INTO template VALUES ('4','DropMenu','<script language=\"JavaScript\" type=\"text/javascript\">\r\nfunction go(formObj){\r\n   if (formObj.chooser.options[formObj.chooser.selectedIndex].value != \"none\") {\r\n	location = formObj.chooser.options[formObj.chooser.selectedIndex].value\r\n   }\r\n}\r\n</script>\r\n<form>\r\n<tmpl_if session.var.adminOn>\r\n<tmpl_var config.button>\r\n</tmpl_if>\r\n<select name=\"chooser\" size=1 onChange=\"go(this.form)\">\r\n<option value=none>Where do you want to go?</option>\r\n<tmpl_loop page_loop>\r\n<option value=\"<tmpl_var page.url>\"><tmpl_loop page.indent_loop>&nbsp;&nbsp;</tmpl_loop>- <tmpl_var page.menuTitle></option>\r\n</tmpl_loop>\r\n</select>\r\n</form>','Navigation',1,1);
INSERT INTO template VALUES ('5','Tabs','<tmpl_if session.var.adminOn>\r\n<tmpl_var config.button>\r\n</tmpl_if>\r\n<tmpl_loop page_loop>\r\n   <tmpl_if page.isCurrent>\r\n      <span class=\"rootTabOn\">\r\n   <tmpl_else>\r\n      <span class=\"rootTabOff\">\r\n   </tmpl_if>\r\n   <a <tmpl_if page.newWindow>target=\"_blank\"</tmpl_if> href=\"<tmpl_var page.url>\"><tmpl_var page.menuTitle></a>\r\n   </span>\r\n</tmpl_loop>','Navigation',1,1);
INSERT INTO template VALUES ('6','dtree','^StyleSheet(\"<tmpl_var session.config.extrasURL>/Navigation/dtree/dtree.css\");\r\n^JavaScript(\"<tmpl_var session.config.extrasURL>/Navigation/dtree/dtree.js\");\r\n\r\n<tmpl_if session.var.adminOn>\r\n<tmpl_var config.button>\r\n</tmpl_if>\r\n\r\n<script>\r\n// Path to dtree directory\r\n_dtree_url = \"<tmpl_var session.config.extrasURL>/Navigation/dtree/\";\r\n</script>\r\n\r\n<div class=\"dtree\">\r\n<script type=\"text/javascript\">\r\n<!--\r\n	d = new dTree(\'d\');\r\n	<tmpl_loop page_loop>\r\n	d.add(\r\n		\'<tmpl_var page.pageId>\',\r\n		<tmpl_if __first__>-99<tmpl_else>\'<tmpl_var page.parentId>\'</tmpl_if>,\r\n		\'<tmpl_var page.menuTitle>\',\r\n		\'<tmpl_var page.url>\',\r\n		\'<tmpl_var page.synopsis>\'\r\n		<tmpl_if page.newWindow>,\'_blank\'</tmpl_if>\r\n	);\r\n	</tmpl_loop>\r\n	document.write(d);\r\n//-->\r\n</script>\r\n\r\n</div>','Navigation',1,1);
INSERT INTO template VALUES ('1','Calendar Month (Big)','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_if session.var.adminOn>\r\n    <a href=\"<tmpl_var addevent.url>\"><tmpl_var addevent.label></a>\r\n    <p />\r\n</tmpl_if>\r\n\r\n<tmpl_loop month_loop>\n	<table border=\"1\" width=\"100%\">\n	<tr><td colspan=7 class=\"tableHeader\"><h2 align=\"center\"><tmpl_var month> <tmpl_var year></h2></td></tr>\n	<tr>\n	<tmpl_if session.user.firstDayOfWeek>\n		<th class=\"tableData\"><tmpl_var monday.label></th>\n		<th class=\"tableData\"><tmpl_var tuesday.label></th>\n		<th class=\"tableData\"><tmpl_var wednesday.label></th>\n		<th class=\"tableData\"><tmpl_var thursday.label></th>\n		<th class=\"tableData\"><tmpl_var friday.label></th>\n		<th class=\"tableData\"><tmpl_var saturday.label></th>\n		<th class=\"tableData\"><tmpl_var sunday.label></th>\n	<tmpl_else>\n		<th class=\"tableData\"><tmpl_var sunday.label></th>\n		<th class=\"tableData\"><tmpl_var monday.label></th>\n		<th class=\"tableData\"><tmpl_var tuesday.label></th>\n		<th class=\"tableData\"><tmpl_var wednesday.label></th>\n		<th class=\"tableData\"><tmpl_var thursday.label></th>\n		<th class=\"tableData\"><tmpl_var friday.label></th>\n		<th class=\"tableData\"><tmpl_var saturday.label></th>\n	</tmpl_if>\n	</tr><tr>\n	<tmpl_loop prepad_loop>\n		<td>&nbsp;</td>\n	</tmpl_loop>\n 	<tmpl_loop day_loop>\n		<tmpl_if isStartOfWeek>\n			<tr>\n		</tmpl_if>\n		<td class=\"table<tmpl_if isToday>Header<tmpl_else>Data</tmpl_if>\" width=\"14%\" valign=\"top\" align=\"left\"><p><b><tmpl_var day></b></p>\n		<tmpl_loop event_loop>\n			<tmpl_if name>\n				&middot;<a href=\"<tmpl_var url>\"><tmpl_var name></a><br />\n			</tmpl_if>\n		</tmpl_loop>\n		</td>\n		<tmpl_if isEndOfWeek>\n			</tr>\n		</tmpl_if>\n	</tmpl_loop>\n	<tmpl_loop postpad_loop>\n		<td>&nbsp;</td>\n	</tmpl_loop>\n	</tr>\n	</table>\n</tmpl_loop>\n\n\n<tmpl_if pagination.pageCount.isMultiple>\n  <div class=\"pagination\">\n    <tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>\n  </div>\n</tmpl_if>\n','EventsCalendar',1,1);
INSERT INTO template VALUES ('7','Cool Menus','<tmpl_if session.var.adminOn>\r\n<tmpl_var config.button>\r\n</tmpl_if>\r\n\r\n<style>\r\n/* CoolMenus 4 - default styles - do not edit */\r\n.cCMAbs{position:absolute; visibility:hidden; left:0; top:0}\r\n/* CoolMenus 4 - default styles - end */\r\n\r\n/*Styles for level 0*/\r\n.cLevel0,.cLevel0over{position:absolute; padding:2px; font-family:tahoma,arial,helvetica; font-size:12px; font-weight:bold;\r\n\r\n}\r\n.cLevel0{background-color:navy; layer-background-color:navy; color:white;\r\ntext-align: center;\r\n}\r\n.cLevel0over{background-color:navy; layer-background-color:navy; color:white; cursor:pointer; cursor:hand; \r\ntext-align: center; \r\n}\r\n\r\n.cLevel0border{position:absolute; visibility:hidden; background-color:#569635; layer-background-color:#006699; \r\n \r\n}\r\n\r\n\r\n/*Styles for level 1*/\r\n.cLevel1, .cLevel1over{position:absolute; padding:2px; font-family:tahoma, arial,helvetica; font-size:11px; font-weight:bold}\r\n.cLevel1{background-color:Navy; layer-background-color:Navy; color:white;}\r\n.cLevel1over{background-color:#336699; layer-background-color:#336699; color:Yellow; cursor:pointer; cursor:hand; }\r\n.cLevel1border{position:absolute; visibility:hidden; background-color:#006699; layer-background-color:#006699}\r\n\r\n/*Styles for level 2*/\r\n.cLevel2, .cLevel2over{position:absolute; padding:2px; font-family:tahoma,arial,helvetica; font-size:10px; font-weight:bold}\r\n.cLevel2{background-color:Navy; layer-background-color:Navy; color:white;}\r\n.cLevel2over{background-color:#0099cc; layer-background-color:#0099cc; color:Yellow; cursor:pointer; cursor:hand; }\r\n.cLevel2border{position:absolute; visibility:hidden; background-color:#006699; layer-background-color:#006699}\r\n\r\n</style>\r\n\r\n  \r\n\r\n^JavaScript(\"<tmpl_var session.config.extrasURL>/coolmenus/coolmenus4.js\");\r\n<script language=\"JavaScript\">\r\n/*****************************************************************************\nCopyright (c) 2001 Thomas Brattli (webmaster@dhtmlcentral.com)\n\nDHTML coolMenus - Get it at coolmenus.dhtmlcentral.com\nVersion 4.0_beta\nThis script can be used freely as long as all copyright messages are\nintact.\n\nExtra info - Coolmenus reference/help - Extra links to help files **** \nCSS help: http://coolmenus.dhtmlcentral.com/projects/coolmenus/reference.asp?m=37\nGeneral: http://coolmenus.dhtmlcentral.com/reference.asp?m=35\nMenu properties: http://coolmenus.dhtmlcentral.com/properties.asp?m=47\nLevel properties: http://coolmenus.dhtmlcentral.com/properties.asp?m=48\n\nBackground bar properties: http://coolmenus.dhtmlcentral.com/properties.asp?m=49\nItem properties: http://coolmenus.dhtmlcentral.com/properties.asp?m=50\n******************************************************************************/\n\r\n/*** \r\nThis is the menu creation code - place it right after you body tag\r\nFeel free to add this to a stand-alone js file and link it to your page.\r\n**/\r\n\r\n//Menu object creation\r\ncoolmenu=new makeCM(\"coolmenu\") //Making the menu object. Argument: menuname\r\n\r\ncoolmenu.frames = 0\r\n\r\n//Menu properties   \r\ncoolmenu.pxBetween=2\r\ncoolmenu.fromLeft=200 \r\ncoolmenu.fromTop=100   \r\ncoolmenu.rows=1\r\ncoolmenu.menuPlacement=\"center\"   //The whole menu alignment, left, center, or right\r\n                                                             \r\ncoolmenu.resizeCheck=1 \r\ncoolmenu.wait=1000 \r\ncoolmenu.fillImg=\"cm_fill.gif\"\r\ncoolmenu.zIndex=100\r\n\r\n//Background bar properties\r\ncoolmenu.useBar=0\r\ncoolmenu.barWidth=\"100%\"\r\ncoolmenu.barHeight=\"menu\" \r\ncoolmenu.barClass=\"cBar\"\r\ncoolmenu.barX=0 \r\ncoolmenu.barY=0\r\ncoolmenu.barBorderX=0\r\ncoolmenu.barBorderY=0\r\ncoolmenu.barBorderClass=\"\"\r\n\r\n//Level properties - ALL properties have to be spesified in level 0\r\ncoolmenu.level[0]=new cm_makeLevel() //Add this for each new level\r\ncoolmenu.level[0].width=110\r\ncoolmenu.level[0].height=21 \r\ncoolmenu.level[0].regClass=\"cLevel0\"\r\ncoolmenu.level[0].overClass=\"cLevel0over\"\r\ncoolmenu.level[0].borderX=1\r\ncoolmenu.level[0].borderY=1\r\ncoolmenu.level[0].borderClass=\"cLevel0border\"\r\ncoolmenu.level[0].offsetX=0\r\ncoolmenu.level[0].offsetY=0\r\ncoolmenu.level[0].rows=0\r\ncoolmenu.level[0].arrow=0\r\ncoolmenu.level[0].arrowWidth=0\r\ncoolmenu.level[0].arrowHeight=0\r\ncoolmenu.level[0].align=\"bottom\"\r\n\r\n//EXAMPLE SUB LEVEL[1] PROPERTIES - You have to specify the properties you want different from LEVEL[0] - If you want all items to look the same just remove this\r\ncoolmenu.level[1]=new cm_makeLevel() //Add this for each new level (adding one to the number)\r\ncoolmenu.level[1].width=coolmenu.level[0].width+20\r\ncoolmenu.level[1].height=25\r\ncoolmenu.level[1].regClass=\"cLevel1\"\r\ncoolmenu.level[1].overClass=\"cLevel1over\"\r\ncoolmenu.level[1].borderX=1\r\ncoolmenu.level[1].borderY=1\r\ncoolmenu.level[1].align=\"right\" \r\ncoolmenu.level[1].offsetX=0\r\ncoolmenu.level[1].offsetY=0\r\ncoolmenu.level[1].borderClass=\"cLevel1border\"\r\n\r\n\r\n//EXAMPLE SUB LEVEL[2] PROPERTIES - You have to spesify the properties you want different from LEVEL[1] OR LEVEL[0] - If you want all items to look the same just remove this\r\ncoolmenu.level[2]=new cm_makeLevel() //Add this for each new level (adding one to the number)\r\ncoolmenu.level[2].width=coolmenu.level[0].width+20\r\ncoolmenu.level[2].height=25\r\ncoolmenu.level[2].offsetX=0\r\ncoolmenu.level[2].offsetY=0\r\ncoolmenu.level[2].regClass=\"cLevel2\"\r\ncoolmenu.level[2].overClass=\"cLevel2over\"\r\ncoolmenu.level[2].borderClass=\"cLevel2border\"\r\n\r\n//EXAMPLE SUB LEVEL[2] PROPERTIES - You have to spesify the properties you want different from LEVEL[1] OR LEVEL[0] - If you want all items to look the same just remove this\r\ncoolmenu.level[3]=new cm_makeLevel() //Add this for each new level (adding one to the number)\r\ncoolmenu.level[3].width=coolmenu.level[0].width+20\r\ncoolmenu.level[3].height=25\r\ncoolmenu.level[3].offsetX=0\r\ncoolmenu.level[3].offsetY=0\r\ncoolmenu.level[3].regClass=\"cLevel2\"\r\ncoolmenu.level[3].overClass=\"cLevel2over\"\r\ncoolmenu.level[3].borderClass=\"cLevel2border\"\r\n\r\n\r\n\r\n<tmpl_loop page_loop>\r\ncoolmenu.makeMenu(\'coolmenu_<tmpl_var page.urlizedTitle>\',\'coolmenu_<tmpl_var page.mother.urlizedTitle>\',\'<tmpl_var page.menuTitle>\',\'<tmpl_var page.url>\'<tmpl_if page.newWindow>,\'_blank\'</tmpl_if>);\r\n</tmpl_loop>\r\n\r\n\r\ncoolmenu.construct();\r\n\r\n</script>','Navigation',1,1);
INSERT INTO template VALUES ('3','Midas','^JavaScript(\"<tmpl_var session.config.extrasURL>/textFix.js\");\r\n\r\n<tmpl_if midas.supported>\r\n   <script language=\"JavaScript\">\r\n      var formObj; \r\n      var extrasDir=\"<tmpl_var session.config.extrasURL\";\r\n      function openEditWindow(obj) {\r\n         formObj = obj;\r\n         window.open(\"<tmpl_var session.config.extrasURL>/midas/editor.html\",\"editWindow\",\"width=600,height=400,resizable=1\");                    }\r\n   </script>\r\n   <tmpl_var button>\r\n</tmpl_if>\r\n\r\n<tmpl_var textarea>\r\n','richEditor',1,1);
INSERT INTO template VALUES ('2','Advanced Search','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<table class=\"tableMenu\" width=\"100%\">\r\n  <tbody>\r\n    <tr>\r\n      <form method=\"post\" encType=\"multipart/form-data\">\r\n<input type=\"hidden\" name=\"func\" value=\"view\">\r\n<input type=\"hidden\" name=\"wid\" value=\"<tmpl_var wid>\">\r\n<td vAlign=\"top\" align=\"middle\">\r\n  <table>\r\n    <tbody>\r\n      <tr>\r\n<td class=\"tableData\"><b>Search for:</b></td>\r\n<td class=\"tableData\"><input maxLength=\"255\" size=\"25\" value=\'<tmpl_var query>\' name=\"query\"></td>\r\n<td class=\"tableData\">in</td>\r\n<td class=\"tableData\">\r\n   <select size=\"1\" name=\"namespaces\">\r\n   <tmpl_loop namespaces>\r\n      <option value=\"<tmpl_var value>\" <tmpl_if selected>selected</tmpl_if>><tmpl_var name></option>\r\n   </tmpl_loop>\r\n   </select>\r\n \r\n     </td>\r\n      </tr>\r\n      <tr>\r\n	<td class=\"tableData\" valign=top><b>Content in language:</b></td>\r\n	<td class=\"tableData\" valign=top>\r\n	   <tmpl_loop languages>\r\n		<input type=\"checkbox\" name=\"languages\" value=\"<tmpl_var value>\" \r\n			<tmpl_if selected>checked=\"1\"</tmpl_if> ><tmpl_var name><br>\r\n	   </tmpl_loop>\r\n	</td>\r\n          <td class=\"tableData\" valign=top><b>Created by:</b></td>\r\n          <td class=\"tableData\" valign=top>\r\n	   <select size=\"1\" name=\"users\">\r\n	   <tmpl_loop users>\r\n	      <option value=\"<tmpl_var value>\" <tmpl_if selected>selected</tmpl_if>><tmpl_var name></option>\r\n	   </tmpl_loop>\r\n	   </select>\r\n	 </td>\r\n     </td>\r\n      </tr>\r\n      <tr>\r\n          <td class=\"tableData\"><b>Type of content:</b></td>\r\n          <td class=\"tableData\">\r\n	   <select size=\"1\" name=\"contentTypes\">\r\n	   <tmpl_loop contentTypes>\r\n      <option value=\"<tmpl_var value>\" <tmpl_if selected>selected</tmpl_if>><tmpl_var name></option>\r\n   </tmpl_loop>\r\n   </select>\r\n   </td>\r\n<td class=\"tableData\"><b>Number of Results:</b></td>\r\n<td class=\"tableData\">\r\n	<select size=\"1\" name=\"paginateAfter\">\r\n	<option <tmpl_var select_10> >10</option>\r\n	<option <tmpl_var select_25> >25</option>\r\n	<option <tmpl_var select_50> >50</option>\r\n	<option <tmpl_var select_100 >>100</option>\r\n	</select>\r\n</td>\r\n      </tr>\r\n      <tr>\r\n	<td class=\"tableData\"></td>\r\n	<td class=\"tableData\"></td>\r\n<td class=\"tableData\"></td>\r\n<td class=\"tableData\"><input onclick=\"this.value=\'Please wait...\'\" type=\"submit\" value=\"search\"></td>\r\n      </tr>\r\n\r\n    </tbody>\r\n  </table>\r\n</td>\r\n<td></td>\r\n      </form>\r\n    </tr>\r\n  </tbody>\r\n</table>\r\n\r\n<p/>\r\n<tmpl_if numberOfResults>\r\n   <p>Results <tmpl_var startNr> - <tmpl_var endNr> of about <tmpl_var numberOfResults> \r\n   containing <b>\"<tmpl_var queryHighlighted>\"</b>. Search took <b><tmpl_var duration></b> seconds.</p>\r\n</tmpl_if>\r\n<ol style=\"Margin-Top: 0px; Margin-Bottom: 0px;\" start=\"<tmpl_var startNr>\">\r\n\r\n<tmpl_loop resultsLoop>\r\n   <li>\r\n	<a href=\"<tmpl_var location>\">\r\n	   <tmpl_if header><tmpl_var header><tmpl_else>No Title</tmpl_if></a>\r\n	<tmpl_if username>\r\n	   by <a href=\"<tmpl_var userProfile>\"><tmpl_var username></a>\r\n	</tmpl_if>\r\n	<div>\r\n	   <tmpl_if \"body\">\r\n		<span class=\"preview\"><tmpl_var \"body\"></span><br/>\r\n	   </tmpl_if>\r\n	   <span style=\"color:#666666;\"><tmpl_var location></span>\r\n	   <br/>\r\n	   <br/>\r\n	</div>\r\n   </li>\r\n</tmpl_loop>\r\n\r\n</ol>\r\n\n\n\n<tmpl_if pagination.pageCount.isMultiple>\n  <div class=\"pagination\">\n    <tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>\n  </div>\n</tmpl_if>\n','IndexedSearch',1,1);
INSERT INTO template VALUES ('3','Search in Help','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<table class=\"tableMenu\" width=\"100%\">\r\n  <tbody>\r\n    <tr>\r\n      <td align=\"center\" width=\"15%\">\r\n      <h1><tmpl_var int.search></h1>\r\n      </td>\r\n      <td vAlign=\"top\" align=\"middle\">\r\n      <table>\r\n      <form method=\"post\">\r\n      <input type=\"hidden\" name=\"contentTypes\" value=\"help\">\r\n      <input type=\"hidden\" name=\"func\" value=\"view\">\r\n      <input type=\"hidden\" name=\"wid\" value=\"<tmpl_var wid>\">\r\n      <tbody>\r\n      <tr>\r\n	<td align=center class=\"tableData\">\r\n	   <input maxLength=\"255\" size=\"30\" value=\'<tmpl_var query>\' name=\"query\">\r\n	</td>\r\n	<td class=\"tableData\"><tmpl_var submit></td>\r\n      </tr>\r\n      <tr>\r\n	<td align=center class=\"tableData\" valign=\"top\"><b>In namespace: </b>\r\n	   <select size=\"1\" name=\"namespaces\">\r\n	   <tmpl_loop namespaces>\r\n		<option value=\"<tmpl_var value>\" <tmpl_if selected>selected</tmpl_if>><tmpl_var name></option>\r\n	   </tmpl_loop>\r\n	   </select>\r\n	</td>\r\n      </tbody>\r\n      </table>\r\n      </td>\r\n      </form>\r\n    </tr>\r\n  </tbody>\r\n</table>\r\n\r\n<p/>\r\n<tmpl_if numberOfResults>\r\n   <p>Results <tmpl_var startNr> - <tmpl_var endNr> of about <tmpl_var numberOfResults> \r\n   containing <b>\"<tmpl_var queryHighlighted>\"</b>. Search took <b><tmpl_var duration></b> seconds.</p>\r\n</tmpl_if>\r\n<ol style=\"Margin-Top: 0px; Margin-Bottom: 0px;\" start=\"<tmpl_var startNr>\">\r\n\r\n<tmpl_loop resultsLoop>\r\n   <li>\r\n	<a href=\"<tmpl_var location>\">\r\n	   <tmpl_if header><tmpl_var header><tmpl_else>No Title</tmpl_if></a>\r\n	<div>\r\n	   <tmpl_if \"body\">\r\n		<span class=\"preview\"><tmpl_var \"body\"></span><br/>\r\n	   </tmpl_if>\r\n	   <span style=\"color:#666666;\">Namespace: <tmpl_var namespace></span>\r\n	   <br/>\r\n	   <br/>\r\n	</div>\r\n   </li>\r\n</tmpl_loop>\r\n\r\n</ol>\r\n\n\n\n<tmpl_if pagination.pageCount.isMultiple>\n  <div class=\"pagination\">\n    <tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>\n  </div>\n</tmpl_if>\n','IndexedSearch',1,1);
INSERT INTO template VALUES ('1','Default Search','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<table class=\"tableMenu\" width=\"100%\">\r\n  <tbody>\r\n    <tr>\r\n      <td align=\"center\" width=\"15%\">\r\n      <h1><tmpl_var int.search></h1>\r\n      </td>\r\n      <td vAlign=\"top\" align=\"middle\">\r\n      <table>\r\n      <form method=\"post\">\r\n      <input type=\"hidden\" name=\"func\" value=\"view\">\r\n      <input type=\"hidden\" name=\"wid\" value=\"<tmpl_var wid>\">\r\n      <tbody>\r\n      <tr>\r\n	<td colspan=\"2\" class=\"tableData\">\r\n	   <input maxLength=\"255\" size=\"30\" value=\'<tmpl_var query>\' name=\"query\">\r\n	</td>\r\n	<td class=\"tableData\"><tmpl_var submit></td>\r\n      </tr>\r\n      <tr>\r\n	<td class=\"tableData\" valign=\"top\">\r\n  	   <tmpl_loop languages>\r\n	     <input type=\"radio\" name=\"languages\" value=\"<tmpl_var value>\" \r\n	     <tmpl_if __FIRST__>\r\n		<tmpl_if query>\r\n		   <tmpl_if selected>\r\n			checked=\"1\"\r\n		   </tmpl_if>\r\n		<tmpl_else>\r\n		   checked=\"1\"\r\n	        </tmpl_if>\r\n             <tmpl_else>\r\n	     	<tmpl_if selected>checked=\"1\"</tmpl_if>\r\n	     </tmpl_if>\r\n	     ><tmpl_var name>\r\n	     <br>\r\n	   </tmpl_loop>\r\n	</td>\r\n	<td class=\"tableData\" valign=\"top\">\r\n	   <tmpl_loop contentTypesSimple>\r\n	     <tmpl_unless __FIRST__>\r\n	     	<input type=\"checkbox\" name=\"contentTypes\" value=\"<tmpl_var value>\"\r\n		<tmpl_if type_content>\r\n		   <tmpl_if query>\r\n			<tmpl_if selected>\r\n			   checked=\"1\"\r\n			</tmpl_if>\r\n		   <tmpl_else>\r\n			checked=\"1\"\r\n		   </tmpl_if>\r\n		<tmpl_else>\r\n		   <tmpl_if selected>checked=\"1\"</tmpl_if>\r\n		</tmpl_if>\r\n		><tmpl_var name>\r\n                <br>\r\n	     </tmpl_unless>\r\n	   </tmpl_loop>\r\n	</td>\r\n        <td></td>\r\n      </tbody>\r\n      </form>\r\n      </table>\r\n      </td>      \r\n    </tr>\r\n  </tbody>\r\n</table>\r\n\r\n<p/>\r\n<tmpl_if numberOfResults>\r\n   <p>Results <tmpl_var startNr> - <tmpl_var endNr> of about <tmpl_var numberOfResults> \r\n   containing <b>\"<tmpl_var queryHighlighted>\"</b>. Search took <b><tmpl_var duration></b> seconds.</p>\r\n   <ol style=\"Margin-Top: 0px; Margin-Bottom: 0px;\" start=\"<tmpl_var startNr>\">\r\n   <tmpl_loop resultsLoop>\r\n      <li>\r\n	   <a href=\"<tmpl_var location>\">\r\n	      <tmpl_if header><tmpl_var header><tmpl_else>No Title</tmpl_if></a>\r\n	   <div>\r\n	      <tmpl_if \"body\">\r\n		   <span class=\"preview\"><tmpl_var \"body\"></span><br/>\r\n	      </tmpl_if>\r\n	      <span style=\"color:#666666;\">Location: <tmpl_var crumbTrail></span>\r\n	      <br/>\r\n	      <br/>\r\n	   </div>\r\n      </li>\r\n   </tmpl_loop>\r\n   </ol>\r\n</tmpl_if> \n\n\n<tmpl_if pagination.pageCount.isMultiple>\n  <div class=\"pagination\">\n    <tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>\n  </div>\n</tmpl_if>\n','IndexedSearch',1,1);
INSERT INTO template VALUES ('14','Job Listing','<tmpl_if displayTitle>\n    <h1><tmpl_var title></h1>\n</tmpl_if>\n\n<tmpl_if description>\n    <tmpl_var description><p />\n</tmpl_if>\n\n<tmpl_if session.scratch.search>\n <tmpl_var search.form>\n</tmpl_if>\n\n<table width=\"100%\" cellpadding=2 cellspacing=1 border=0><tr>\n<td align=\"right\" class=\"tableMenu\">\n\n<tmpl_if canPost>\n   <a href=\"<tmpl_var post.url>\">Add a job.</a> &middot;\n</tmpl_if>\n\n<a href=\"<tmpl_var search.url>\"><tmpl_var search.label></a>\n\n</td></tr></table>\n\n<table width=\"100%\" cellspacing=1 cellpadding=2 border=0>\n<tr>\n<td class=\"tableHeader\">Job Title</td>\n<td class=\"tableHeader\">Location</td>\n<td class=\"tableHeader\">Compensation</td>\n<td class=\"tableHeader\">Date Posted</td>\n</tr>\n\n<tmpl_loop submissions_loop>\n\n<tr>\n<td class=\"tableData\">\n     <a href=\"<tmpl_var submission.URL>\">  <tmpl_var submission.title>\n</td>\n<td class=\"tableData\"><tmpl_var submission.userDefined2></td>\n<td class=\"tableData\"><tmpl_var submission.userDefined1></td>\n<td class=\"tableData\"><tmpl_var submission.date></td>\n</tr>\n\n</tmpl_loop>\n\n</table>\n\n<tmpl_if pagination.pageCount.isMultiple>\n  <div class=\"pagination\">\n    <tmpl_var pagination.previousPage>  &middot; <tmpl_var pagination.pageList.upTo20> &middot; <tmpl_var pagination.nextPage>\n  </div>\n</tmpl_if>\n','USS',1,1);
INSERT INTO template VALUES ('2','Job','<h1><tmpl_var title></h1>\n\n<tmpl_if content>\n<p>\n<b>Job Description</b><br />\n<tmpl_var content>\n</p>\n</tmpl_if>\n\n<tmpl_if userDefined3.value>\n<p>\n<b>Job Requirements</b><br />\n<tmpl_var userDefined3.value>\n</p>\n</tmpl_if>\n\n<table>\n<tr>\n  <td class=\"tableHeader\">Date Posted</td>\n  <td class=\"tableData\"><tmpl_var date.human></td>\n</tr>\n<tr>\n  <td  class=\"tableHeader\">Location</td>\n  <td class=\"tableData\"><tmpl_var userDefined2.value></td>\n</tr>\n<tr>\n  <td  class=\"tableHeader\">Compensation</td>\n  <td class=\"tableData\"><tmpl_var userDefined1.value></td>\n</tr>\n<tr>\n  <td  class=\"tableHeader\">Views</td>\n  <td class=\"tableData\"><tmpl_var views.count></td>\n</tr>\n</table>\n\n<p>\n<tmpl_if previous.more>\n   <a href=\"<tmpl_var previous.url>\">&laquo; Previous Job</a> &middot;\n</tmpl_if>\n<a href=\"<tmpl_var back.url>\">List All Jobs</a>\n<tmpl_if next.more>\n   &middot; <a href=\"<tmpl_var next.url>\">Next Job &raquo;</a>\n</tmpl_if>\n</p>\n\n\n<tmpl_if canEdit>\n<p>\n   <a href=\"<tmpl_var edit.url>\">Edit</a>\n   &middot;\n   <a href=\"<tmpl_var delete.url>\"><tmpl_var delete.label></a>\n</p>\n</tmpl_if>\n\n<tmpl_if canChangeStatus>\n <p>\n<b>Status:</b> <tmpl_var status.status> ||\n   <a href=\"<tmpl_var approve.url>\"><tmpl_var approve.label></a>\n   &middot;\n   <a href=\"<tmpl_var deny.url>\"><tmpl_var deny.label></a>\n </p>\n</tmpl_if>\n\n\n\n','USS/Submission',1,1);
INSERT INTO template VALUES ('4','Job Submission Form','<h1>Edit Job Posting</h1>\n\n<tmpl_var form.header>\n<input type=\"hidden\" name=\"contentType\" value=\"html\" />\n	<table>\n	<tmpl_if user.isVisitor> <tmpl_if submission.isNew>\n		<tr><td><tmpl_var visitorName.label></td><td><tmpl_var visitorName.form></td></tr>\n	</tmpl_if> </tmpl_if>\n	<tr><td>Job Title</td><td><tmpl_var title.form></td></tr>\n	<tr><td>Job Description</td><td><tmpl_var body.form></td></tr>\n	<tr><td>Job Requirements</td><td><tmpl_var userDefined3.form.htmlarea></td></tr>\n	<tr><td>Compensation</td><td><tmpl_var userDefined1.form></td></tr>\n	<tr><td>Location</td><td><tmpl_var userDefined2.form></td></tr>\n	<tr><td></td><td><tmpl_var form.submit></td></tr>\n	</table>\n<tmpl_var form.footer>\n','USS/SubmissionForm',1,1);
INSERT INTO template VALUES ('8','Synopsis','<div class=\"synopsis\">\r\n<tmpl_loop page_loop>\r\n   <div class=\"synopsis_title\">\r\n      <a href=\"<tmpl_var page.url>\"><tmpl_var page.menuTitle></a>\r\n   </div>\r\n   <tmpl_if page.indent>\r\n      <div class=\"synopsis_sub\">\r\n         <tmpl_var page.synopsis>\r\n      </div>\r\n   <tmpl_else>\r\n      <div class=\"synopsis_summary\">\r\n         <tmpl_var page.synopsis>\r\n      </div>\r\n   </tmpl_if>\r\n</tmpl_loop>\r\n</div>','Navigation',1,1);
INSERT INTO template VALUES ('1','Default WebGUI Login Template','<h1>\n   <tmpl_var title>\n</h1>\n\n<tmpl_if login.message>\r\n   <tmpl_var login.message>\r\n</tmpl_if>\r\n\r\n<tmpl_var login.form.header>\r\n<table >\r\n<tmpl_var login.form.hidden>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var login.form.username.label></td>\r\n   <td class=\"tableData\"><tmpl_var login.form.username></td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var login.form.password.label></td>\r\n   <td class=\"tableData\"><tmpl_var login.form.password></td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"></td>\r\n   <td class=\"tableData\"><tmpl_var login.form.submit></td>\r\n</tr>\r\n</table>\r\n<tmpl_var login.form.footer>\r\n\r\n<div class=\"accountOptions\">\r\n   <ul>\n     <tmpl_if recoverPassword.isAllowed>\n	     <li><a href=\"<tmpl_var recoverPassword.url>\"><tmpl_var recoverPassword.label></a></li>\n	  </tmpl_if>\n           <tmpl_if anonymousRegistration.isAllowed>\n	     <li><a href=\"<tmpl_var createAccount.url>\"><tmpl_var createAccount.label></a></li>\n	  </tmpl_if>\r\n   </ul>\r\n</div>','Auth/WebGUI/Login',1,1);
INSERT INTO template VALUES ('1','Default WebGUI Account Display Template','<h1>\n   <tmpl_var title>\n</h1>\n\n\n<tmpl_if account.message>\r\n   <tmpl_var account.message>\r\n</tmpl_if>\r\n\r\n<tmpl_var account.form.header>\r\n<table >\r\n\n<tmpl_if account.form.karma>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var account.form.karma.label></td>\r\n   <td class=\"tableData\"><tmpl_var account.form.karma></td>\r\n</tr>\r\n</tmpl_if>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var account.form.username.label></td>\r\n   <td class=\"tableData\"><tmpl_var account.form.username></td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var account.form.password.label></td>\r\n   <td class=\"tableData\"><tmpl_var account.form.password></td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var account.form.passwordConfirm.label></td>\r\n   <td class=\"tableData\"><tmpl_var account.form.passwordConfirm></td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"></td>\r\n   <td class=\"tableData\"><tmpl_var account.form.submit></td>\r\n</tr>\r\n</table>\r\n<tmpl_var account.form.footer>\r\n\r\n<div class=\"accountOptions\">\r\n   <ul>\r\n      <tmpl_loop account.options>\r\n         <li><tmpl_var options.display>\r\n      </tmpl_loop>\r\n   </ul>\r\n</div>','Auth/WebGUI/Account',1,1);
INSERT INTO template VALUES ('1','Default WebGUI Anonymous Registration Template','   <h1><tmpl_var title></h1>\r\n\n<tmpl_if create.message>\r\n   <tmpl_var create.message>\r\n</tmpl_if>\r\n\r\n<tmpl_var create.form.header>\r\n<table >\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var create.form.username.label></td>\r\n   <td class=\"tableData\"><tmpl_var create.form.username></td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var create.form.password.label></td>\r\n   <td class=\"tableData\"><tmpl_var create.form.password></td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var create.form.passwordConfirm.label></td>\r\n   <td class=\"tableData\"><tmpl_var create.form.passwordConfirm></td>\r\n</tr>\r\n<tmpl_loop create.form.profile>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var profile.formElement.label></td>\r\n   <td class=\"tableData\"><tmpl_var profile.formElement></td>\r\n</tr>\r\n</tmpl_loop>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"></td>\r\n   <td class=\"tableData\"><tmpl_var create.form.submit></td>\r\n</tr>\r\n</table>\r\n<tmpl_var create.form.footer>\r\n\r\n<div class=\"accountOptions\">\r\n   <ul>\r\n      <li><a href=\"<tmpl_var login.url>\"><tmpl_var login.label></a></li>\r\n      <tmpl_if recoverPassword.isAllowed>\r\n	     <li><a href=\"<tmpl_var recoverPassword.url>\"><tmpl_var recoverPassword.label></a></li>\n	  </tmpl_if>\r\n   </ul>\r\n</div>','Auth/WebGUI/Create',1,1);
INSERT INTO template VALUES ('1','Default WebGUI Password Recovery Template','<h1>\n   <tmpl_var title>\n</h1>\n\r\n\r\n<tmpl_if recover.message>\r\n   <tmpl_var recover.message>\r\n</tmpl_if>\r\n\r\n<tmpl_var recover.form.header>\r\n<table >\r\n<tmpl_var recover.form.hidden>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var recover.form.email.label></td>\r\n   <td class=\"tableData\"><tmpl_var recover.form.email></td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"></td>\r\n   <td class=\"tableData\"><tmpl_var recover.form.submit></td>\r\n</tr>\r\n</table>\r\n<tmpl_var recover.form.footer>\r\n\r\n\r\n<div class=\"accountOptions\">\r\n   <ul>\n       <tmpl_if anonymousRegistration.isAllowed>\n	     <li><a href=\"<tmpl_var createAccount.url>\"><tmpl_var createAccount.label></a></li>\n	  </tmpl_if>\n         <li><a href=\"<tmpl_var login.url>\"><tmpl_var login.label></a></li>\n      \r\n   </ul>\r\n</div>','Auth/WebGUI/Recovery',1,1);
INSERT INTO template VALUES ('1','Default WebGUI Password Reset Template','<h1>\n   <tmpl_var title>\n</h1>\n\r\n<tmpl_if expired.message>\r\n   <tmpl_var expired.message>\r\n</tmpl_if>\r\n\r\n<tmpl_var expired.form.header>\r\n<table >\r\n<tmpl_var expired.form.hidden>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\">\r\n      <tmpl_var expired.form.oldPassword.label>\r\n   </td>\r\n   <td class=\"tableData\">\r\n      <tmpl_var expired.form.oldPassword>\r\n   </td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\">\r\n      <tmpl_var expired.form.password.label>\r\n   </td>\r\n   <td class=\"tableData\">\r\n      <tmpl_var expired.form.password>\r\n   </td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\">\r\n  <tmpl_var expired.form.passwordConfirm.label>\r\n   </td>\r\n   <td class=\"tableData\">\r\n   <tmpl_var expired.form.passwordConfirm>\r\n   </td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"></td>\r\n   <td class=\"tableData\">\r\n   <tmpl_var expired.form.submit>\r\n   </td>\r\n</tr>\r\n</table>\r\n<tmpl_var expired.form.footer>','Auth/WebGUI/Expired',1,1);
INSERT INTO template VALUES ('1','Default LDAP Login Template','<h1>\n   <tmpl_var title>\n</h1>\r\n<tmpl_if login.message>\r\n   <tmpl_var login.message>\r\n</tmpl_if>\r\n\r\n<tmpl_var login.form.header>\r\n<table >\r\n<tmpl_var login.form.hidden>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var login.form.username.label></td>\r\n   <td class=\"tableData\"><tmpl_var login.form.username></td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var login.form.password.label></td>\r\n   <td class=\"tableData\"><tmpl_var login.form.password></td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"></td>\r\n   <td class=\"tableData\"><tmpl_var login.form.submit></td>\r\n</tr>\r\n</table>\r\n<tmpl_var login.form.footer>\r\n\r\n<div class=\"accountOptions\">\r\n   <ul>\r\n             <tmpl_if anonymousRegistration.isAllowed>\n	     <li><a href=\"<tmpl_var createAccount.url>\"><tmpl_var createAccount.label></a></li>\n	  </tmpl_if>\n\n   </ul>\r\n</div>','Auth/LDAP/Login',1,1);
INSERT INTO template VALUES ('1','Default LDAP Account Display Template','<h1>\n   <tmpl_var title>\n</h1>\n\n\r\n<tmpl_var account.message>\r\n<tmpl_if account.form.karma>\r\n<br><br>\r\n<table>\r\n<tr>\r\n  <td class=\"formDescription\">\r\n      <tmpl_var account.form.karma.label>\r\n  </td>\r\n  <td class=\"tableData\">\r\n       <tmpl_var account.form.karma>\r\n  </td>\r\n</tr>\r\n</table>\r\n</tmpl_if>\r\n\r\n<div class=\"accountOptions\">\r\n   <ul>\r\n      <tmpl_loop account.options>\r\n         <li><tmpl_var options.display>\r\n      </tmpl_loop>\r\n   </ul>\r\n</div>','Auth/LDAP/Account',1,1);
INSERT INTO template VALUES ('1','Default LDAP Anonymous Registration Template','<h1>\n   <tmpl_var title>\r\n</h1>\n<tmpl_if create.message>\r\n   <tmpl_var create.message>\r\n</tmpl_if>\r\n\r\n<tmpl_var create.form.header>\r\n<table >\r\n<tmpl_var create.form.hidden>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var create.form.ldapId.label></td>\r\n   <td class=\"tableData\"><tmpl_var create.form.ldapId></td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var create.form.password.label></td>\r\n   <td class=\"tableData\"><tmpl_var create.form.password></td>\r\n</tr>\r\n<tmpl_loop create.form.profile>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var profile.formElement.label></td>\r\n   <td class=\"tableData\"><tmpl_var profile.formElement></td>\r\n</tr>\r\n</tmpl_loop>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"></td>\r\n   <td class=\"tableData\"><tmpl_var create.form.submit></td>\r\n</tr>\r\n</table>\r\n<tmpl_var create.form.footer>\r\n\r\n\r\n<div class=\"accountOptions\">\r\n   <ul>\n     <li><a href=\"<tmpl_var login.url>\"><tmpl_var login.label></a></li>\n \n  </ul>\r\n</div>','Auth/LDAP/Create',1,1);
INSERT INTO template VALUES ('1','Default SMB Login Template','<h1>\n   <tmpl_var title>\n</h1>\n\n\r\n<tmpl_if login.message>\r\n   <tmpl_var login.message>\r\n</tmpl_if>\r\n\r\n<tmpl_var login.form.header>\r\n<table >\r\n<tmpl_var login.form.hidden>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var login.form.username.label></td>\r\n   <td class=\"tableData\"><tmpl_var login.form.username></td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var login.form.password.label></td>\r\n   <td class=\"tableData\"><tmpl_var login.form.password></td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"></td>\r\n   <td class=\"tableData\"><tmpl_var login.form.submit></td>\r\n</tr>\r\n</table>\r\n<tmpl_var login.form.footer>\r\n\r\n<div class=\"accountOptions\">\r\n   <ul>\n           <tmpl_if anonymousRegistration.isAllowed>\n	     <li><a href=\"<tmpl_var createAccount.url>\"><tmpl_var createAccount.label></a></li>\n	  </tmpl_if>\n   </ul>\r\n</div>','Auth/SMB/Login',1,1);
INSERT INTO template VALUES ('1','Default SMB Account Display Template','<h1>\n   <tmpl_var title>\n</h1>\n\n\r\n<tmpl_var account.message>\r\n<tmpl_if account.form.karma>\r\n<br><br>\r\n<table>\r\n<tr>\r\n  <td class=\"formDescription\">\r\n      <tmpl_var account.form.karma.label>\r\n  </td>\r\n  <td class=\"tableData\">\r\n       <tmpl_var account.form.karma>\r\n  </td>\r\n</tr>\r\n</table>\r\n</tmpl_if>\r\n<div class=\"accountOptions\">\r\n   <ul>\r\n      <tmpl_loop account.options>\r\n         <li><tmpl_var options.display>\r\n      </tmpl_loop>\r\n   </ul>\r\n</div>','Auth/SMB/Account',1,1);
INSERT INTO template VALUES ('1','Default SMB Anonymous Registration Template','<h1>  \n <tmpl_var title>\r\n</h1>\n<tmpl_if create.message>\r\n   <tmpl_var create.message>\r\n</tmpl_if>\r\n\r\n<tmpl_var create.form.header>\r\n<table >\r\n<tmpl_var create.form.hidden>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var create.form.loginId.label></td>\r\n   <td class=\"tableData\"><tmpl_var create.form.loginId></td>\r\n</tr>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var create.form.password.label></td>\r\n   <td class=\"tableData\"><tmpl_var create.form.password></td>\r\n</tr>\r\n<tmpl_loop create.form.profile>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"><tmpl_var profile.formElement.label></td>\r\n   <td class=\"tableData\"><tmpl_var profile.formElement></td>\r\n</tr>\r\n</tmpl_loop>\r\n<tr>\r\n   <td class=\"formDescription\" valign=\"top\"></td>\r\n   <td class=\"tableData\"><tmpl_var create.form.submit></td>\r\n</tr>\r\n</table>\r\n<tmpl_var create.form.footer>\r\n\r\n\r\n<div class=\"accountOptions\">\r\n   <ul>\r\n     <li><a href=\"<tmpl_var login.url>\"><tmpl_var login.label></a></li>\n\n       </ul>\r\n</div>','Auth/SMB/Create',1,1);
INSERT INTO template VALUES ('1','Default WebGUI Yes/No Prompt','<h1><tmpl_var title></h1>\n\n<p>\n<tmpl_var question>\n</p>\n\n<div align=\"center\">\n\n<a href=\"<tmpl_var yes.url>\"><tmpl_var yes.label></a>\n\n&nbsp;  &nbsp; &nbsp; &nbsp; &nbsp; \n\n<a href=\"<tmpl_var no.url>\"><tmpl_var no.label></a>\n\n</div>\n','prompt',1,1);
INSERT INTO template VALUES ('1','Fail Safe','<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n		<html>\n		<head>\n			<title><tmpl_var session.page.title> - <tmpl_var session.setting.companyName></title>\n			<tmpl_var head.tags>\n		<style>\r\n.adminBar {\r\n        background-color: #dddddd;\r\n        font-size: 8pt;\r\n        font-family: helvetica, arial;\r\n        color: #000055;\r\n}\r\n</style>\n		</head>\n		^AdminBar;\n\n<body>\r\n^H; / ^Navigation(TopLevelMenuHorizontal_1000); / ^Navigation(currentMenuHorizontal_1001); / ^a;\r\n<hr>\n\n\n			<tmpl_var body.content>\n		\n\n<hr>\r\n^H; / ^Navigation(TopLevelMenuHorizontal_1000); / ^Navigation(currentMenuHorizontal_1001); / ^a;\r\n</body>\n		</html>\n		','style',0,0);
INSERT INTO template VALUES ('1000','WebGUI 6 Admin Style','<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n		<html>\n		<head>\n			<title><tmpl_var session.page.title> - <tmpl_var session.setting.companyName></title>\n			<tmpl_var head.tags>\n		<style>\r\n\r\ninput:focus, textarea:focus {\r\n background-color: #D5E0E1;\r\n}\r\n\r\ninput, textarea, select {\r\n -moz-border-radius: 6px;\r\n background-color: #B9CDCF;\r\n border: ridge;\r\n}\r\n\r\n\r\n.content{\r\n	color: #000000;\r\n	font-family: Arial, Helvetica, sans-serif;\r\n	font-size: 10pt;\r\n	padding: 5px;\r\n}\r\n\r\nbody{\r\n	color: Black;\r\n	font-family: Arial, Helvetica, sans-serif;\r\n	font-size: 10pt;\r\n	padding: 0px;\r\n	background-position: top;\r\n	background-repeat: repeat-x;\r\n}\r\n\r\na {\r\n	color:#EC4300;\r\n	font-family: Arial, Helvetica, sans-serif;\r\n	font-weight: bold;\r\n	text-decoration: underline;\r\n}\r\n\r\na:hover{\r\n	color:#EC4300; \r\n	font-family: Arial, Helvetica, sans-serif;\r\n	font-weight: bold;\r\n	text-decoration: none;\r\n}\r\n\r\n.adminBar {\r\n  background-color: #CCCCCC;\r\n  font-family: helvetica, arial;\r\n}\r\n\r\n.tableMenu {\r\n  background-color: #CCCCCC;\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.tableMenu a {\r\n  font-size: 10pt;\r\n  text-decoration: none;\r\n}\r\n\r\n.tableHeader {\r\n  background-color: #CECECE;\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.tableData {\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n\r\n.pagination {\r\n  font-family: helvetica, arial;\r\n  font-size: 8pt;\r\n  text-align: center;\r\n}\r\n\r\n\r\nh1 {\r\n	font-size: 14pt;\r\n	font-family: helvetica, arial;\r\n	color: #EC4300;\r\n}\r\n\r\n.tab {\r\n  -moz-border-radius: 6px 6px 0px 0px;\r\n border: 1px solid black;\r\n   background-color: #eeeeee;\r\n}\r\n.tabBody {\r\n   border: 1px solid black;\r\n   border-top: 1px solid black;\r\n   border-left: 1px solid black;\r\n   background-color: #dddddd; \r\n}\r\ndiv.tabs {\r\n    line-height: 15px;\r\n    font-size: 14px;\r\n}\r\n.tabHover {\r\n   background-color: #cccccc;\r\n}\r\n.tabActive { \r\n   background-color: #dddddd; \r\n}\r\n\r\n</style>\r\n		\r\n\r\n\r\n\n		</head>\n				<body bgcolor=\"#D5E0E1\" leftmargin=\"0\" topmargin=\"0\" rightmargin=\"0\" bottommargin=\"0\" marginwidth=\"0\" marginheight=\"0\">\r\n\r\n^AdminBar(2);<br /> <br />\r\n\r\n<div class=\"content\" style=\"padding: 10px;\">\r\n  \n			<tmpl_var body.content>\n		\r\n</div>\r\n\r\n\r\n<div width=\"100%\" style=\"color: white; padding: 3px; background-color: black; text-align: center;\">^H; / ^PageTitle; / ^AdminToggle; / ^LoginToggle; / ^a;</div>\r\n</body>\r\n\r\n\r\n\r\n\r\n\r\n\n		</html>\n		','style',1,1);
INSERT INTO template VALUES ('4','Clipboard','<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n		<html>\n		<head>\n			<title><tmpl_var session.page.title> - <tmpl_var session.setting.companyName></title>\n			<tmpl_var head.tags>\n		<style>\r\n.adminBar {\r\n        background-color: #dddddd;\r\n        font-size: 8pt;\r\n        font-family: helvetica, arial;\r\n        color: #000055;\r\n}\r\n</style>\n		</head>\n		^AdminBar;\n\n<body>\r\n<table width=\"100%\">\r\n<tr><td><span style=\"font-size: 36pt;\">Clipboard</span>\r\n</td>\r\n<td align=\"right\">^H; / ^a;</td></tr>\r\n<tr><td bgcolor=\"#000000\" colspan=\"2\"><img src=\"^Extras;spacer.gif\" height=\"1\"></td></tr>\r\n</table>\r\n<table width=\"100%\"><tr><td valign=\"top\" width=\"30%\"><b>PAGES</b><br>^Navigation(FlexMenu_1002);</td><td width=\"1\" bgcolor=\"#000000\"><img src=\"^Extras;spacer.gif\" width=\"1\"></td><td valign=\"top\" width=\"70%\"><b>CONTENT</b><br>\n\n\n			<tmpl_var body.content>\n		\n\n</td></tr></table>\r\n<table width=\"100%\">\r\n<tr><td bgcolor=\"#000000\" colspan=\"2\"><img src=\"^Extras;spacer.gif\" height=\"1\"></td></tr>\r\n</table>\r\n^H; / ^a;\r\n</body>\n		</html>\n		','style',0,0);
INSERT INTO template VALUES ('1001','WebGUI 6','<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n		<html>\n		<head>\n			<title><tmpl_var session.page.title> - <tmpl_var session.setting.companyName></title>\n			<tmpl_var head.tags>\n		<style>\r\n\r\n.nav,  A.nav:hover, .verticalMenu {\r\n font-size: 10px;\r\n text-decoration: none;\r\n}\r\n\r\n.pageTitle, .pageTitle A {\r\n  font-size: 30px;\r\n}\r\n\r\ninput:focus, textarea:focus {\r\n background-color: #D5E0E1;\r\n}\r\n\r\ninput, textarea, select {\r\n -moz-border-radius: 6px;\r\n background-color: #B9CDCF;\r\n border: ridge;\r\n}\r\n\r\n.wgBoxTop{\r\n	background-image: url(\"^Extras;/styles/webgui6/hdr_bg_corner_right.jpg\");\r\n        width: 195px;\r\n        height: 93px;\r\n}\r\n.wgBoxBottom{\r\n	background-image: url(\"^Extras;/styles/webgui6/content_bg_clouds.jpg\");\r\n	padding-bottom: 21px;\r\n        width: 529px;\r\n        height: 88px;\r\n}\r\n.logo {\r\n	background-image: url(\"^Extras;/styles/webgui6/hdr_bg_corner_left.jpg\");\r\n	background-color: #F4F4F4;\r\n	width: 195px;\r\n        height: 93px;\r\n        padding-bottom: 25px;\r\n}\r\n.login {\r\n        width: 334px;\r\n        height: 93px;\r\n	background-image: url(\"^Extras;/styles/webgui6/hdr_bg_center.jpg\");\r\n	background-color: #C1D6D8;\r\n        padding-top: 5px;\r\n	font-family: Arial, Helvetica, sans-serif;\r\n	font-size: 10px;\r\n	font-weight: bold;\r\n	color: #EC4300;\r\n}\n  input.loginBoxField { \n font-size: 10px;\n background-color: white;\n }\n .loginBox {\n font-size: 10px;\n }\n input.loginBoxButton {\n font-size: 10px;\n }  \r\n.iconBox{\r\n	background-image: url(\"^Extras;/styles/webgui6/content_bg_corner_left_top.jpg\");\r\n        width: 195px;\r\n        height: 88px;\r\n        vertical-align: bottom;\r\n        text-align: center;\r\n}\r\n.dateLeft {\r\n	background-image: url(\"^Extras;/styles/webgui6/date_bg_left.jpg\");	\r\n     width: 53px;\r\n     height: 59px;\r\n}\r\n\r\n.dateRight {\r\n     width: 53px;\r\n     height: 59px;\r\n	background-image: url(\"^Extras;/styles/webgui6/date_right_bg.jpg\");	\r\n}\r\n\r\n.date {\r\n	color: #393C3C;\r\n	font-family: Arial, Helvetica, sans-serif;\r\n	font-size: 11px;\r\n	font-weight: bold;\r\n}\r\n\r\n.contentbgLeft {\r\n	background-image: url(\"^Extras;/styles/webgui6/content_bg_left.jpg\");	\r\n    width: 53px;\r\n	\r\n}\r\n.contentbgRight {\r\n	background-image: url(\"^Extras;/styles/webgui6/content_bg_right.jpg\");	\r\n	\r\n}\r\n\r\n\r\n.content{\r\n	color: #000000;\r\n	font-family: Arial, Helvetica, sans-serif;\r\n	font-size: 10pt;\r\n	padding: 5px;\r\n}\r\n\r\nbody{\r\n	color: Black;\r\n	font-family: Arial, Helvetica, sans-serif;\r\n	font-size: 10pt;\r\n	padding: 0px;\r\n        background-image: url(\"^Extras;/styles/webgui6/bg.gif\");\r\n	background-position: top;\r\n	background-repeat: repeat-x;\r\n}\r\n\r\na {\r\n	color:#EC4300;\r\n	font-family: Arial, Helvetica, sans-serif;\r\n	font-weight: bold;\r\n	text-decoration: underline;\r\n}\r\n\r\na:hover{\r\n	color:#EC4300; \r\n	font-family: Arial, Helvetica, sans-serif;\r\n	font-weight: bold;\r\n	text-decoration: none;\r\n}\r\n\r\n.adminBar {\r\n  background-color: #CCCCCC;\r\n  font-family: helvetica, arial;\r\n}\r\n.tableMenu {\r\n  background-color: #CCCCCC;\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n.tableMenu a {\r\n  font-size: 10pt;\r\n  text-decoration: none;\r\n}\r\n.tableHeader {\r\n  background-color: #CECECE;\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n.tableData {\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n.pollColor {\r\n  background-color: #CCCCCC;\r\n  border: thin solid #393C3C;\r\n}\r\n.pagination {\r\n  font-family: helvetica, arial;\r\n  font-size: 8pt;\r\n  text-align: center;\r\n}\r\n\r\nh1, h2, h3, h4, h5, h6 {\r\n   font-family: helvetica, arial;\r\n	color: #EC4300;\r\n}\r\n\r\nh1 {\r\n	font-size: 14pt;\r\n	font-family: helvetica, arial;\r\n	color: #EC4300;\r\n}\r\n\r\n.tab {\r\n  border: 1px solid black;\r\n   background-color: #eeeeee;\r\n}\r\n.tabBody {\r\n   border: 1px solid black;\r\n   border-top: 1px solid black;\r\n   border-left: 1px solid black;\r\n   background-color: #dddddd; \r\n}\r\ndiv.tabs {\r\n    line-height: 15px;\r\n    font-size: 14px;\r\n}\r\n.tabHover {\r\n   background-color: #cccccc;\r\n}\r\n.tabActive { \r\n   background-color: #dddddd; \r\n}\r\n\r\n</style>\r\n		\n		</head>\n		<body bgcolor=\"#D5E0E1\" leftmargin=\"0\" topmargin=\"0\" rightmargin=\"0\" bottommargin=\"0\" marginwidth=\"0\" marginheight=\"0\">\r\n^AdminBar(2);\r\n\r\n<!-- logo / login table starts here -->\r\n<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\" align=\"center\">\r\n	<tr>	\r\n		<td width=\"195\" align=\"center\" class=\"logo\"><a href=\"http://www.plainblack.com/webgui\"><img border=\"0\" src=\"^Extras;/styles/webgui6/wg_logo.gif\"></a></td>\r\n		<td width=\"334\" align=\"center\" valign=\"top\" class=\"login\">^L(17,\"\",2); ^AdminToggle;</td>\r\n		<td width=\"195\" align=\"center\" class=\"wgBoxTop\" valign=\"bottom\"><a href=\"http://www.plainblack.com/webgui\"><img border=\"0\" src=\"^Extras;/styles/webgui6/wg_box_top.gif\"></a></td>\r\n	</tr>\r\n</table>\r\n<!-- logo / login table ends here -->\r\n<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\" align=\"center\">\r\n	<tr>\r\n	<!-- print, email icons here -->\r\n		<td class=\"iconBox\">\n &nbsp; &nbsp; &nbsp; &nbsp; \r\n<a href=\"^H(linkonly);\"><img border=\"0\" src=\"^Extras;/styles/webgui6/icon_home.gif\" title=\"Go Home\" alt=\"home\" /></a> \n <a href=\"^/;tell_a_friend\"><img border=\"0\" src=\"^Extras;/styles/webgui6/icon_email.gif\" alt=\"Email\" title=\"Email a friend about this site.\" /></a>\r\n<a href=\"^r(linkonly);\"><img border=\"0\" src=\"^Extras;/styles/webgui6/icon_print.gif\" alt=\"Print\" title=\"Make page printable.\" /></a> \n <a href=\"site_map\"><img border=\"0\" src=\"^Extras;/styles/webgui6/icon_site_map.gif\" title=\"View the site map.\" ALT=\"Site Map\" /></a> <a href=\"http://www.plainblack.com\"><img border=\"0\" src=\"^Extras;/styles/webgui6/icon_pb.gif\" ALT=\"Plain Black Icon\" title=\"Visit plainblack.com.\" /></a>\r\n</td>\r\n	<!-- box clouds here -->\r\n		<td class=\"wgBoxBottom\">^Spacer(56,1);<a href=\"http://www.plainblack.com/what_is_webgui\"><img border=\"0\" src=\"^Extras;/styles/webgui6/txt_the_last.gif\"></a>^Spacer(26,1);<a href=\"http://www.plainblack.com/webgui\"><img border=\"0\" src=\"^Extras;/styles/webgui6/wg_box_bottom.gif\"></a></td>\r\n	</tr>\r\n</table>\r\n<!-- date & page title table start here -->\r\n<table width=\"724\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\" align=\"center\">\r\n	<tr>\r\n		<td class=\"dateLeft\">^Spacer(53,59);</td>\r\n		<td width=\"141\" bgcolor=\"#BDC6C7\" class=\"date\">^D(\"%c %D, %y\");</td>\r\n		<td><img border=\"0\" src=\"^Extras;/styles/webgui6/date_right_shadow.gif\"></td>\r\n		<td width=\"467\" bgcolor=\"#B9CDCF\"><div class=\"pageTitle\">^PageTitle;</div></td>\r\n		<td class=\"dateRight\">^Spacer(53,59);</td>\r\n	</tr>\r\n</table>\r\n<!-- date and page title table end here -->\r\n<!-- left nav & content table start here -->\r\n<table width=\"724\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\" align=\"center\">\r\n	<tr>\r\n		<td class=\"contentbgLeft\">^Spacer(53,1);</td>\r\n		<!-- nav column -->\r\n		<td width=\"142\" valign=\"top\" bgcolor=\"#E2E1E1\" style=\"width: 142px;\">\r\n<br /> <div class=\"nav\">\r\n^Navigation(FlexMenu_1002);\r\n</div> <br /> <br />\r\n<a href=\"http://www.plainblack.com/webgui\"><img border=\"0\" src=\"^Extras;/styles/webgui6/powered_by_aqua_blue.gif\"></a>\r\n</td>\r\n\r\n		<td valign=\"top\" bgcolor=\"#F4F4F4\"><img border=\"0\" src=\"^Extras;/styles/webgui6/lnav_shadow.jpg\"></td>\r\n		<!-- content column -->\r\n		<td width=\"466\" valign=\"top\" bgcolor=\"#F4F4F4\" class=\"content\">\n			<tmpl_var body.content>\n		</td>\r\n		<td class=\"contentbgRight\">^Spacer(53,1);</td>\r\n	</tr>\r\n</table>\r\n<!-- left nav & content table end here -->\r\n<!-- footer -->\r\n<table width=\"724\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\" align=\"center\">\r\n	<tr>\r\n		<td><img border=\"0\" src=\"^Extras;/styles/webgui6/footer.jpg\"></td>\r\n	</tr>\r\n        <tr>\r\n                <td align=\"center\"><a href=\"http://www.plainblack.com\"><img border=\"0\" src=\"^Extras;/styles/webgui6/logo_pb.gif\"></a><br /><span style=\"font-size: 11px;\"><a href=\"http://www.plainblack.com/design\">Design by Plain Black</a></span></td>\r\n        </tr>\r\n</table>\r\n</body>\n		</html>\n		','style',1,1);
INSERT INTO template VALUES ('3','Make Page Printable','<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n		<html>\n		<head>\n			<title><tmpl_var session.page.title> - <tmpl_var session.setting.companyName></title>\n			<tmpl_var head.tags>\n		<style>\r\n\r\n.content{\r\n  background-color: #ffffff;\r\n  color: #000000;\r\n  font-family: helvetica, arial;\r\n  font-size: 10pt;\r\n  padding: 10pt;\r\n}\r\n\r\nH1 {\r\n  font-family: helvetica, arial;\r\n  font-size: 16pt;\r\n}\r\n\r\nA {\r\n  color: #EF4200;\r\n}\r\n\r\n.pagination {\r\n  font-family: helvetica, arial;\r\n  font-size: 8pt;\r\n  text-align: center;\r\n}\r\n\r\n.formDescription {\r\n  font-family: helvetica, arial;\r\n  font-size: 10pt;\r\n  font-weight: bold;\r\n}\r\n\r\n.formSubtext {\r\n  font-family: helvetica, arial;\r\n  font-size: 8pt;\r\n}\r\n\r\n.highlight {\r\n  background-color: #dddddd;\r\n}\r\n\r\n.tableMenu {\r\n  background-color: #cccccc;\r\n  font-size: 8pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.tableMenu a {\r\n  text-decoration: none;\r\n}\r\n\r\n.tableHeader {\r\n  background-color: #cccccc;\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.tableData {\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.pollAnswer {\r\n  font-family: Helvetica, Arial;\r\n  font-size: 8pt;\r\n}\r\n\r\n.pollColor {\r\n  background-color: #444444;\r\n}\r\n\r\n.pollQuestion {\r\n  font-face: Helvetica, Arial;\r\n  font-weight: bold;\r\n}\r\n\r\n.faqQuestion {\r\n  font-size: 12pt;\r\n  font-weight: bold;\r\n  color: #000000;\r\n}\r\n\r\n</style>\n		</head>\n		^AdminBar;\n\n<body onLoad=\"window.print()\">\r\n<div align=\"center\"><a href=\"^\\;\"><img src=\"^Extras;plainblack.gif\" border=\"0\"></a></div>\n\n\n			<tmpl_var body.content>\n		\n\n<div align=\"center\">© 2001-2004 Plain Black LLC</div>\r\n</body>\n		</html>\n		','style',1,1);
INSERT INTO template VALUES ('5','Trash','<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n		<html>\n		<head>\n			<title><tmpl_var session.page.title> - <tmpl_var session.setting.companyName></title>\n			<tmpl_var head.tags>\n		<style>\r\n.adminBar {\r\n        background-color: #dddddd;\r\n        font-size: 8pt;\r\n        font-family: helvetica, arial;\r\n        color: #000055;\r\n}\r\n</style>\n		</head>\n		^AdminBar;\n\n<body>\r\n<table width=\"100%\">\r\n<tr><td><span style=\"font-size: 36pt;\">Trash</span>\r\n</td>\r\n<td align=\"right\">^H; / ^a; / <a href=\"^\\;?op=purgeTrash\">Empty Trash</a></td></tr>\r\n<tr><td bgcolor=\"#000000\" colspan=\"2\"><img src=\"^Extras;spacer.gif\" height=\"1\"></td></tr>\r\n</table>\r\n<table width=\"100%\"><tr><td valign=\"top\" width=\"30%\"><b>PAGES</b><br>^Navigation(FlexMenu_1002);</td><td width=\"1\" bgcolor=\"#000000\"><img src=\"^Extras;spacer.gif\" width=\"1\"></td><td valign=\"top\" width=\"70%\"><b>CONTENT</b><br>\n\n\n			<tmpl_var body.content>\n		\n\n</td></tr></table>\r\n<table width=\"100%\">\r\n<tr><td bgcolor=\"#000000\" colspan=\"2\"><img src=\"^Extras;spacer.gif\" height=\"1\"></td></tr>\r\n</table>\r\n^H; / ^a; / <a href=\"^\\;?op=purgeTrash\">Empty Trash</a>\r\n</body>\n		</html>\n		','style',0,0);
INSERT INTO template VALUES ('2','Packages','<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n		<html>\n		<head>\n			<title><tmpl_var session.page.title> - <tmpl_var session.setting.companyName></title>\n			<tmpl_var head.tags>\n		<style>\r\n.adminBar {\r\n        background-color: #dddddd;\r\n        font-size: 8pt;\r\n        font-family: helvetica, arial;\r\n        color: #000055;\r\n}\r\n</style>\n		</head>\n		^AdminBar;\n\n<body>\r\n<table width=\"100%\">\r\n<tr><td><span style=\"font-size: 36pt;\">Packages</span>\r\n</td>\r\n<td align=\"right\">^H; / ^a;</td></tr>\r\n<tr><td bgcolor=\"#000000\" colspan=\"2\"><img src=\"^Extras;spacer.gif\" height=\"1\"></td></tr>\r\n</table>\r\n<table width=\"100%\"><tr><td valign=\"top\" width=\"30%\"><b>PACKAGES</b><br>^Navigation(FlexMenu_1002);</td><td width=\"1\" bgcolor=\"#000000\"><img src=\"^Extras;spacer.gif\" width=\"1\"></td><td valign=\"top\" width=\"70%\"><b>CONTENT</b><br>\n\n\n			<tmpl_var body.content>\n		\n\n</td></tr></table>\r\n<table width=\"100%\">\r\n<tr><td bgcolor=\"#000000\" colspan=\"2\"><img src=\"^Extras;spacer.gif\" height=\"1\"></td></tr>\r\n</table>\r\n^H; / ^a;\r\n</body>\n		</html>\n		','style',0,0);
INSERT INTO template VALUES ('10','htmlArea Image Manager','<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n		<html>\n		<head>\n			<title><tmpl_var session.page.title> - <tmpl_var session.setting.companyName></title>\n			<tmpl_var head.tags>\n		<style type=\"text/css\">\r\nTD { font: 8pt \'MS Shell Dlg\', Helvetica, sans-serif; }\r\nTD.delete { font: italic 7pt \'MS Shell Dlg\', Helvetica, sans-serif; }\r\nTD.label { font: 8pt \'MS Shell Dlg\', Helvetica, sans-serif; background-color: #c0c0c0; }\r\nTD.none { font: italic 12pt \'MS Shell Dlg\', Helvetica, sans-serif; }\r\n\r\n</style>\r\n\n		</head>\n		<script language=\"javascript\">\r\nfunction findAncestor(element, name, type) {\r\n   while(element != null && (element.name != name || element.tagName != type))\r\n      element = element.parentElement;\r\n   return element;\r\n}\r\n</script>\r\n<script language=\"javascript\">\r\n\r\nfunction actionComplete(action, path, error, info) {\r\n   var manager = findAncestor(window.frameElement, \'manager\', \'TABLE\');\r\n   var wrapper = findAncestor(window.frameElement, \'wrapper\', \'TABLE\');\r\n\r\n   if(manager) {\r\n      if(error.length < 1) {\r\n         manager.all.actions.reset();\r\n         if(action == \'upload\') {\r\n            manager.all.actions.image.value = \'\';\r\n            manager.all.actions.name.value = \'\';\r\n           manager.all.actions.thumbnailSize.value = \'\';\r\n\r\n         }\r\n         if(action == \'create\')\r\n            manager.all.actions.folder.value = \'\';\r\n         if(action == \'delete\')\r\n            manager.all.txtFileName.value = \'\';\r\n      }\r\n      manager.all.actions.DPI.value = 96;\r\n      manager.all.actions.path.value = path;\r\n   }\r\n   if(wrapper)\r\n      wrapper.all.viewer.contentWindow.navigate(\'^/;?op=htmlAreaviewCollateral\');\r\n   if(error.length > 0)\r\n      alert(error);\r\n   else if(info.length > 0)\r\n      alert(info);\r\n}\r\n</script>\r\n\r\n<script language=\"javascript\">\r\nfunction deleteCollateral(options) {\r\n   var lister = findAncestor(window.frameElement, \'lister\', \'IFRAME\');\r\n\r\n   if(lister && confirm(\"Are you sure you want to delete this item ?\"))\r\n      lister.contentWindow.navigate(\'^/;?op=htmlAreaDelete&\' + options);\r\n}\r\n</script>\r\n</head>\r\n<body leftmargin=\"0\" topmargin=\"0\" marginwidth=\"0\" marginheight=\"0\">\r\n\n			<tmpl_var body.content>\n		\r\n</body>\n		</html>\n		','style',1,0);
INSERT INTO template VALUES ('6','Empty','<tmpl_var body.content>','style',0,0);
INSERT INTO template VALUES ('5','Item','<tmpl_if displaytitle>\r\n   <tmpl_if linkurl>\r\n       <a href=\"<tmpl_var linkurl>\">\r\n    </tmpl_if>\r\n     <span class=\"itemTitle\"><tmpl_var title></span>\r\n   <tmpl_if linkurl>\r\n      </a>\r\n    </tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_if attachment.name>\r\n   <tmpl_if displaytitle> - </tmpl_if>\r\n   <a href=\"<tmpl_var attachment.url>\"><img src=\"<tmpl_var attachment.Icon>\" border=\"0\" alt=\"<tmpl_var attachment.name>\" width=\"16\" height=\"16\" border=\"0\" align=\"middle\" /></a>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n  - <tmpl_var description>\r\n</tmpl_if>','Article',1,1);
INSERT INTO template VALUES ('6','Item w/pop-up Links','<tmpl_if displaytitle>\r\n   <tmpl_if linkurl>\r\n       <a href=\"<tmpl_var linkurl>\" target=\"_blank\">\r\n    </tmpl_if>\r\n     <span class=\"itemTitle\"><tmpl_var title></span>\r\n   <tmpl_if linkurl>\r\n      </a>\r\n    </tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_if attachment.name>\r\n   <tmpl_if displaytitle> - </tmpl_if>\r\n   <a href=\"<tmpl_var attachment.url>\" target=\"_blank\"><img src=\"<tmpl_var attachment.Icon>\" border=\"0\" alt=\"<tmpl_var attachment.name>\" width=\"16\" height=\"16\" border=\"0\" align=\"middle\" /></a>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n  - <tmpl_var description>\r\n</tmpl_if>','Article',1,1);
INSERT INTO template VALUES ('17','Q and A','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n <tmpl_if canPost>\n			<a href=\"<tmpl_var post.url>\"> <tmpl_var addquestion.label></a><p />\r\n</tmpl_if>\r\n\r\n\r\n<tmpl_loop submissions_loop>\r\n   \n		<tmpl_if submission.currentUser>\n			<tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var submission.edit.url>\"><tmpl_var submission.edit.label></a>]</tmpl_unless>\n		</tmpl_if>\n		<tmpl_if canModerate>\n			<tmpl_if session.var.adminOn><tmpl_var submission.controls><tmpl_else><tmpl_unless submission.currentUser><tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var submission.edit.url>\"><tmpl_var submission.edit.label></a>]</tmpl_unless></tmpl_unless></tmpl_if>\n		</tmpl_if>\n		\r\n  <b>Q: <tmpl_var submission.title></b><br />\r\n  A: <tmpl_var submission.content.full>\r\n  <p />\r\n</tmpl_loop>\r\n\r\n','USS',1,1);
INSERT INTO template VALUES ('20','Ordered List','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n <tmpl_if canPost>\n			<a href=\"<tmpl_var post.url>\"> <tmpl_var addlink.label></a><p />\r\n</tmpl_if>\r\n\r\n<ol>\r\n<tmpl_loop submissions_loop>\r\n  <li>\r\n   \n		<tmpl_if submission.currentUser>\n			<tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var submission.edit.url>\"><tmpl_var submission.edit.label></a>]</tmpl_unless>\n		</tmpl_if>\n		<tmpl_if canModerate>\n			<tmpl_if session.var.adminOn><tmpl_var submission.controls><tmpl_else><tmpl_unless submission.currentUser><tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var submission.edit.url>\"><tmpl_var submission.edit.label></a>]</tmpl_unless></tmpl_unless></tmpl_if>\n		</tmpl_if>\r\n\r\n   <a href=\"<tmpl_var submission.userDefined1>\"\r\n   <tmpl_if submission.userDefined2>\r\n          target=\"_blank\"\r\n    </tmpl_if>\r\n    ><span class=\"linkTitle\"><tmpl_var submission.title></span></a>\r\n\r\n    <tmpl_if submission.content.full>\r\n              - <tmpl_var submission.content.full>\r\n   </tmpl_if>\r\n  </li>\r\n</tmpl_loop>\r\n</ol>','USS',1,1);
INSERT INTO template VALUES ('21','Descriptive','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n <tmpl_if canPost>\n			<a href=\"<tmpl_var post.url>\"> <tmpl_var addlink.label></a><p />\r\n</tmpl_if>\r\n\r\n<tmpl_loop submissions_loop>\r\n   \n		<tmpl_if submission.currentUser>\n			<tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var submission.edit.url>\"><tmpl_var submission.edit.label></a>]</tmpl_unless>\n		</tmpl_if>\n		<tmpl_if canModerate>\n			<tmpl_if session.var.adminOn><tmpl_var submission.controls><tmpl_else><tmpl_unless submission.currentUser><tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var submission.edit.url>\"><tmpl_var submission.edit.label></a>]</tmpl_unless></tmpl_unless></tmpl_if>\n		<br />\r\n   </tmpl_if>\r\n\r\n  <a href=\"<tmpl_var submission.userDefined1>\"\r\n   <tmpl_if submission.userDefined2>\r\n          target=\"_blank\"\r\n    </tmpl_if>\r\n    ><span class=\"linkTitle\"><tmpl_var submission.title></span></a>\r\n\r\n    <tmpl_if submission.content.full>\r\n              - <tmpl_var submission.content.full>\r\n   </tmpl_if>\r\n   <p />\r\n</tmpl_loop>\r\n','USS',1,1);
INSERT INTO template VALUES ('1000','Titled Link List','<tmpl_if displayTitle>\n    <h1><tmpl_var title></h1>\n</tmpl_if>\n\n<tmpl_if description>\n    <tmpl_var description><p />\n</tmpl_if>\n\n <tmpl_if canPost>\n			<a href=\"<tmpl_var post.url>\"> <tmpl_var addlink.label></a><p />\n</tmpl_if>\n\n<tmpl_loop submissions_loop>\n   \n		<tmpl_if submission.currentUser>\n			<tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var submission.edit.url>\"><tmpl_var submission.edit.label></a>]</tmpl_unless>\n		</tmpl_if>\n		<tmpl_if canModerate>\n			<tmpl_if session.var.adminOn><tmpl_var submission.controls><tmpl_else><tmpl_unless submission.currentUser><tmpl_unless session.var.adminOn>[<a href=\"<tmpl_var submission.edit.url>\"><tmpl_var submission.edit.label></a>]</tmpl_unless></tmpl_unless></tmpl_if>\n		<br />\n   </tmpl_if>\n\n  <a href=\"<tmpl_var submission.userDefined1>\"\n   <tmpl_if submission.userDefined2>\n          target=\"_blank\"\n    </tmpl_if>\n    ><span class=\"linkTitle\"><tmpl_var submission.title></span></a>\n\n    <tmpl_if submission.content.full>\n              <br /> <tmpl_var submission.content.full>\n   </tmpl_if>\n   <p />\n</tmpl_loop>\n','USS',1,1);
INSERT INTO template VALUES ('3','Link','<h1><tmpl_var title></h1>\r\n\r\n<tmpl_if content>\r\n<p>\r\n<b>Link Description</b><br />\r\n<tmpl_var content>\r\n</p>\r\n</tmpl_if>\r\n\r\n<b>Link URL</b><br />\r\n<a href=\"<tmpl_var userDefined1.value>\"><tmpl_var userDefined1.value></a>\r\n\r\n<p>\r\n<a href=\"<tmpl_var back.url>\">List All Links</a>\r\n</p>\r\n\r\n\r\n<tmpl_if canEdit>\r\n<p>\r\n   <a href=\"<tmpl_var edit.url>\">Edit</a>\r\n   &middot;\r\n   <a href=\"<tmpl_var delete.url>\"><tmpl_var delete.label></a>\r\n</p>\r\n</tmpl_if>\r\n\r\n<tmpl_if canChangeStatus>\r\n <p>\r\n<b>Status:</b> <tmpl_var status.status> ||\r\n   <a href=\"<tmpl_var approve.url>\"><tmpl_var approve.label></a>\r\n   &middot;\r\n   <a href=\"<tmpl_var deny.url>\"><tmpl_var deny.label></a>\r\n </p>\r\n</tmpl_if>\r\n\r\n\r\n\r\n','USS/Submission',1,1);
INSERT INTO template VALUES ('1','Default Account Macro','<a class=\"myAccountLink\" href=\"<tmpl_var account.url>\"><tmpl_var account.text></a>','Macro/a_account',1,1);
INSERT INTO template VALUES ('1','Default Editable Toggle Macro','<a href=\"<tmpl_var toggle.url>\"><tmpl_var toggle.text></a>','Macro/EditableToggle',1,1);
INSERT INTO template VALUES ('1','Default Admin Toggle Macro','<a href=\"<tmpl_var toggle.url>\"><tmpl_var toggle.text></a>','Macro/AdminToggle',1,1);
INSERT INTO template VALUES ('1','Default File Macro','<a href=\"<tmpl_var file.url>\"><img src=\"<tmpl_var file.icon>\" align=\"middle\" border=\"0\" /><tmpl_var file.name></a>','Macro/File',1,1);
INSERT INTO template VALUES ('2','File no icon','<a href=\"<tmpl_var file.url>\"><tmpl_var file.name></a>','Macro/File',1,1);
INSERT INTO template VALUES ('3','File with size','<a href=\"<tmpl_var file.url>\"><img src=\"<tmpl_var file.icon>\" align=\"middle\" border=\"0\" /><tmpl_var file.name></a>(<tmpl_var file.size>)','Macro/File',1,1);
INSERT INTO template VALUES ('1','Default Group Add Macro','<a href=\"<tmpl_var group.url>\"><tmpl_var group.text></a>','Macro/GroupAdd',1,1);
INSERT INTO template VALUES ('1','Default Group Delete Macro','<a href=\"<tmpl_var group.url>\"><tmpl_var group.text></a>','Macro/GroupDelete',1,1);
INSERT INTO template VALUES ('1','Default Homelink','<a class=\"homeLink\" href=\"<tmpl_var homeLink.url>\"><tmpl_var homeLink.text></a>','Macro/H_homeLink',1,1);
INSERT INTO template VALUES ('1','Default Make Printable','<a class=\"makePrintableLink\" href=\"<tmpl_var printable.url>\"><tmpl_var printable.text></a>','Macro/r_printable',1,1);
INSERT INTO template VALUES ('1','Default LoginToggle','<a class=\"loginToggleLink\" href=\"<tmpl_var toggle.url>\"><tmpl_var toggle.text></a>','Macro/LoginToggle',1,1);
INSERT INTO template VALUES ('1','Attachment Box','<p>\r\n  <table cellpadding=3 cellspacing=0 border=1>\r\n  <tr>   \r\n    <td class=\"tableHeader\">\r\n<a href=\"<tmpl_var attachment.url>\"><img src=\"<tmpl_var session.config.extrasURL>/attachment.gif\" border=\"0\" alt=\"<tmpl_var attachment.name>\"></a></td><td>\r\n<a href=\"<tmpl_var attachment.url>\"><img src=\"<tmpl_var attachment.icon>\" align=\"middle\" width=\"16\" height=\"16\" border=\"0\" alt=\"<tmpl_var attachment.name>\"><tmpl_var attachment.name></a>\r\n    </td>\r\n  </tr>\r\n  </table>\r\n</p>\r\n','AttachmentBox',1,1);
INSERT INTO template VALUES ('1','Default Post Preview','<h2><tmpl_var newpost.header></h2>\n\n<h1><tmpl_var post.subject></h1>\n\n<table width=\"100%\">\n<tr>\n<td class=\"content\" valign=\"top\">\n<tmpl_var post.message>\n</td>\n</tr>\n</table>\n\n<tmpl_var form.begin>\n<input type=\"button\" value=\"cancel\" onclick=\"window.history.go(-1)\"><tmpl_var form.submit>\n<tmpl_var form.end>\n','Forum/PostPreview',1,1);
INSERT INTO template VALUES ('4','Classic','^JavaScript(\"<tmpl_var session.config.extrasURL>/textFix.js\");\r\n\r\n<tmpl_if classic.supported>\r\n   <script language=\"JavaScript\">\r\n      var formObj; var extrasDir=\"<tmpl_var session.config.extrasURL>\";\r\n      function openEditWindow(obj) {\r\n         formObj = obj;\r\n         window.open(\"<tmpl_var session.config.extrasURL>/ie5edit.html\",\"editWindow\",\"width=490,height=400,resizable=1\");\r\n      }\r\n      function setContent(content) { \r\n         formObj.value = content; \r\n      } \r\n   </script>\r\n   <tmpl_var button>\r\n</tmpl_if>\r\n\r\n<tmpl_var textarea>\r\n','richEditor',1,1);

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
INSERT INTO userProfileField VALUES ('richEditor','WebGUI::International::get(496)',1,0,'selectList','{\r\n6=>WebGUI::International::get(\'HTMLArea 3\'),\r\n1=>WebGUI::International::get(495), #htmlArea\r\n#2=>WebGUI::International::get(494), #editOnPro2\r\n3=>WebGUI::International::get(887), #midas\r\n4=>WebGUI::International::get(879), #classic\r\n5=>WebGUI::International::get(880),\r\nnone=>WebGUI::International::get(881)\r\n}','[1]',11,'4',0,1);
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


INSERT INTO userSession VALUES ('98Yu7abKPprhA',1094493565,1094489965,0,'','1');

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
INSERT INTO users VALUES ('3','Admin','WebGUI',1019867418,1019935552,0,'Active','1');

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


INSERT INTO webguiVersion VALUES ('6.2.3','initial install',unix_timestamp());

--
-- Table structure for table `wobject`
--

CREATE TABLE wobject (
  wobjectId varchar(22) NOT NULL default '',
  pageId varchar(22) default NULL,
  namespace varchar(35) default NULL,
  sequenceNumber int(11) NOT NULL default '1',
  title varchar(255) default NULL,
  displayTitle int(11) NOT NULL default '1',
  description mediumtext,
  dateAdded int(11) default NULL,
  addedBy varchar(22) default NULL,
  lastEdited int(11) default NULL,
  editedBy varchar(22) default NULL,
  templatePosition int(11) NOT NULL default '1',
  startDate int(11) NOT NULL default '946710000',
  endDate int(11) NOT NULL default '2114406000',
  userDefined1 varchar(255) default NULL,
  userDefined2 varchar(255) default NULL,
  userDefined3 varchar(255) default NULL,
  userDefined4 varchar(255) default NULL,
  userDefined5 varchar(255) default NULL,
  allowDiscussion int(11) NOT NULL default '0',
  bufferUserId varchar(22) default NULL,
  bufferDate int(11) default NULL,
  bufferPrevId varchar(22) default NULL,
  templateId varchar(22) default NULL,
  ownerId varchar(22) default NULL,
  groupIdEdit varchar(22) default NULL,
  groupIdView varchar(22) default NULL,
  forumId varchar(22) NOT NULL default '',
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table `wobject`
--


INSERT INTO wobject VALUES ('-1','4','SiteMap',0,'Page Not Found',1,'The page you were looking for could not be found on this system. Perhaps it has been deleted or renamed. The following list is a site map of this site. If you don\'t find what you\'re looking for on the site map, you can always start from the <a href=\"^/;\">Home Page</a>.',1001744792,'3',1016077239,'3',1,1001744792,1336444487,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,'2','3','3','7','1003');
INSERT INTO wobject VALUES ('1','1','Article',1,'Welcome',1,'Welcome to WebGUI. This is web done right.\n<br /><br />\nWebGUI is a user-friendly web site management system made by <a href=\"http://www.plainblack.com\">Plain Black</a>. It is designed to be easy to use for the average business user, but powerful enough to satisfy the needs of a large enterprise.\n<br /><br />\nThere are thousands of <a href=\"http://www.adinknetwork.com\" target=\"_blank\">small</a> and <a href=\"http://www.brunswickbowling.com\" target=\"_blank\">large</a> businesses, <a href=\"http://www.troy30c.org\" target=\"_blank\">schools</a>, <a href=\"http://goaggies.cameron.edu/\" target=\"_blank\">universities</a>, <a href=\"http://www.lambtononline.ca/\" target=\"_blank\">governments</a>, <a href=\"http://www.hetnieuweland.nl/\" target=\"_blank\">clubs</a>, <a href=\"http://www.k3b.org\" target=\"_blank\">projects</a>, <a href=\"http://www.cmsmatrix.org\" target=\"_blank\">communities</a>, and <a href=\"http://www.primaat.com\" target=\"_blank\">individuals</a> using WebGUI all over the world today. A brief list of some of them can be found <a href=\"http://www.plainblack.com/examples\">here</a>. There\'s no reason your site shouldn\'t be on that list.<br /><br />',1076701903,'3',1076707751,'3',1,946710000,2082783600,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,'1','3','3','7','1005');
INSERT INTO wobject VALUES ('2','1','Article',2,'Key Benefits',1,'<img src=\"^Extras;styles/webgui6/img_hands.jpg\" style=\"position: relative;\" align=\"right\" />\n<style>\ndt {\n font-weight: bold;\n}\n</style>\n\n<dl>\n\n<dt>Easy to Use</dt>\n<dd>If you can use a web browser, then you can manage a web site with WebGUI. WebGUI\'s unique WYSIWYG inline content editing interface ensures that you know where you are and what your content will look like while you\'re editing. In addition, you don\'t need to install and learn any complicated programs, you can edit everything with your trusty web browser.</dd>\n<br />\n\n<dt>Flexible Designs</dt>\n<dd>WebGUI\'s powerful templating system ensures that no two WebGUI sites ever need to look the same. You\'re not restricted in how your content is laid out or how your navigation functions.</dd>\n<br />\n\n<dt>Work Faster</dt>\n<dd>Though there is some pretty cool technology behind the scenes that makes WebGUI work, our first concern has always been usability and not technology. After all if it\'s not useful, why use it? With that in mind WebGUI has all kinds of wizards, short cuts, online help, and other aids to help you work faster.</dd>\n<br />\n\n<dt>Localized Content</dt>\n<dd>With WebGUI there\'s no need to limit yourself to one language or timezone. It\'s a snap to build a multi-lingual site with WebGUI. In fact, even WebGUI\'s built in functions and online help have been translated to more than 15 languages. User\'s can also adjust their local settings for dates, times, and other localized oddities. </dd>\n<br />\n\n<dt>Pluggable By Design</dt>\n<dd>When <a href=\"http://www.plainblack.com\">Plain Black</a> created WebGUI we knew we wouldn\'t be able to think of everything you want to use WebGUI for, so we made most of WebGUI\'s functions pluggable. This allows you to add new features to WebGUI and still be able to upgrade the core system without a fuss.</dd>\n\n</dl>',1076702850,'3',1076707868,'3',1,946710000,2082783600,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,'1','3','3','7','1007');
INSERT INTO wobject VALUES ('3','1000','Article',1,'Getting Started',0,'If you\'re reading this message it means that you\'ve got WebGUI up and running. Good job! The installation is not trivial.\n\n<p/>\n \nIn order to do anything useful with your new installation you\'ll need to log in as the default administrator account. Follow these steps to get started:\n\n<p/>\n\n<ol>\n<li><a href=\"^a(linkonly);\">Click here to log in.</a> (username: Admin password: 123qwe)\n<li><a href=\"^\\;?op=switchOnAdmin\">Click here to turn the administrative interface on.</a>\n</ol>\n<blockquote style=\"font-size: 10px;\">\n<b>NOTE:</b> You could have also done these steps using the block at the top of this page.\n</blockquote>\n\n<p/>\n\nNow that you\'re in as the administrator, you should <a href=\"^a(linkonly);\">change your password</a> so no one else can log in and mess with your site. You might also want to <a href=\"^\\;?op=listUsers\">create another account</a> for yourself with Administrative privileges in case you can\'t log in with the Admin account for some reason.\n\n<p/>\n \nYou\'ll now notice little buttons and menus on all the pages in your site. These controls help you administer your site. The \"Add content\" menu lets you add new content to your pages as well as paste content from the clipboard. The \"Administrative functions\" menu let\'s you control users and groups as well as many other admin settings. The little toolbars help you manipulate the content in your pages.\n\n\n<p/>\n\nFor more information about how to administer <a href=\"http://www.plainblack.com/webgui\">WebGUI</a> consider getting a copy of <a href=\"http://www.plainblack.com/ruling_webgui\">Ruling WebGUI</a>. <a href=\"http://www.plainblack.com\">Plain Black Software</a> also provides several <a href=\"http://www.plainblack.com/support_programs\">Support Programs</a> for WebGUI if you run into trouble.\n\n<p/>\n \nEnjoy your new WebGUI site!',1076704456,'3',1076704456,'3',1,946710000,2082783600,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,'1','3','3','7','1009');
INSERT INTO wobject VALUES ('5','1001','USS',2,'Your Next Step',0,' To learn more about WebGUI and how you can best implement WebGUI in your organization, please see the choices below.\n\n',1076705448,'3',1076706084,'3',1,946710000,2082783600,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,'1000','3','3','7','');
INSERT INTO wobject VALUES ('6','1002','SyndicatedContent',1,'The Latest News',0,'This is the latest news from Plain Black and WebGUI pulled directly from the site every hour.',1076708567,'3',1076709040,'3',1,946710000,2082783600,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,'1000','3','3','7','');
INSERT INTO wobject VALUES ('7','1003','DataForm',1,'Tell A Friend',0,'Tell a friend about WebGUI.',1076709292,'3',1076709522,'3',1,946710000,2082783600,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,'1','3','3','7','');
INSERT INTO wobject VALUES ('8','1004','SiteMap',0,'Site Map',0,'',1001744792,'3',1016077239,'3',1,1001744792,1336444487,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,'2','3','3','7','');

