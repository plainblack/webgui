-- MySQL dump 8.21
--
-- Host: localhost    Database: WebGUI
---------------------------------------------------------
-- Server version	3.23.49

--
-- Table structure for table 'Article'
--

CREATE TABLE Article (
  wobjectId int(11) NOT NULL default '0',
  image varchar(255) default NULL,
  linkTitle varchar(255) default NULL,
  linkURL text,
  attachment varchar(255) default NULL,
  convertCarriageReturns int(11) NOT NULL default '0',
  alignImage varchar(30) NOT NULL default 'left',
  allowDiscussion int(11) NOT NULL default '0',
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table 'Article'
--


INSERT INTO Article VALUES (-2,NULL,'','',NULL,0,'right',0);

--
-- Table structure for table 'DownloadManager'
--

CREATE TABLE DownloadManager (
  wobjectId int(11) NOT NULL default '0',
  paginateAfter int(11) NOT NULL default '50',
  displayThumbnails int(11) NOT NULL default '0',
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table 'DownloadManager'
--



--
-- Table structure for table 'DownloadManager_file'
--

CREATE TABLE DownloadManager_file (
  downloadId int(11) NOT NULL default '0',
  wobjectId int(11) NOT NULL default '0',
  fileTitle varchar(128) NOT NULL default 'untitled',
  downloadFile varchar(255) default NULL,
  groupToView int(11) NOT NULL default '2',
  briefSynopsis varchar(255) default NULL,
  dateUploaded int(11) default NULL,
  sequenceNumber int(11) NOT NULL default '1',
  alternateVersion1 varchar(255) default NULL,
  alternateVersion2 varchar(255) default NULL,
  PRIMARY KEY  (downloadId)
) TYPE=MyISAM;

--
-- Dumping data for table 'DownloadManager_file'
--



--
-- Table structure for table 'EventsCalendar'
--

CREATE TABLE EventsCalendar (
  wobjectId int(11) NOT NULL default '0',
  calendarLayout varchar(30) NOT NULL default 'list',
  paginateAfter int(11) NOT NULL default '50',
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table 'EventsCalendar'
--



--
-- Table structure for table 'EventsCalendar_event'
--

CREATE TABLE EventsCalendar_event (
  eventId int(11) NOT NULL default '1',
  wobjectId int(11) NOT NULL default '0',
  name varchar(255) default NULL,
  description text,
  startDate int(11) default NULL,
  endDate int(11) default NULL,
  recurringEventId int(11) NOT NULL default '0',
  PRIMARY KEY  (eventId)
) TYPE=MyISAM;

--
-- Dumping data for table 'EventsCalendar_event'
--



--
-- Table structure for table 'ExtraColumn'
--

CREATE TABLE ExtraColumn (
  wobjectId int(11) NOT NULL default '0',
  spacer int(11) default NULL,
  width int(11) default NULL,
  class varchar(50) default NULL,
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table 'ExtraColumn'
--



--
-- Table structure for table 'FAQ'
--

CREATE TABLE FAQ (
  wobjectId int(11) NOT NULL default '0',
  tocOn int(11) NOT NULL default '1',
  topOn int(11) NOT NULL default '0',
  qaOn int(11) NOT NULL default '0',
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table 'FAQ'
--



--
-- Table structure for table 'FAQ_question'
--

CREATE TABLE FAQ_question (
  wobjectId int(11) NOT NULL default '0',
  questionId int(11) NOT NULL default '0',
  question text,
  answer text,
  sequenceNumber int(11) NOT NULL default '0',
  PRIMARY KEY  (questionId)
) TYPE=MyISAM;

--
-- Dumping data for table 'FAQ_question'
--



--
-- Table structure for table 'Item'
--

CREATE TABLE Item (
  wobjectId int(11) NOT NULL default '0',
  linkURL text,
  attachment varchar(255) default NULL,
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table 'Item'
--



--
-- Table structure for table 'LinkList'
--

CREATE TABLE LinkList (
  wobjectId int(11) NOT NULL default '0',
  indent int(11) NOT NULL default '0',
  lineSpacing int(11) NOT NULL default '1',
  bullet varchar(255) NOT NULL default '&middot;',
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table 'LinkList'
--



--
-- Table structure for table 'LinkList_link'
--

CREATE TABLE LinkList_link (
  wobjectId int(11) NOT NULL default '0',
  linkId int(11) NOT NULL default '0',
  name varchar(128) default NULL,
  url text,
  description text,
  sequenceNumber int(11) NOT NULL default '0',
  newWindow int(11) NOT NULL default '0',
  PRIMARY KEY  (linkId)
) TYPE=MyISAM;

--
-- Dumping data for table 'LinkList_link'
--



--
-- Table structure for table 'MailForm'
--

CREATE TABLE MailForm (
  wobjectId int(11) NOT NULL default '0',
  width int(11) NOT NULL default '0',
  fromField text,
  fromStatus char(1) default '0',
  toField text,
  toStatus char(1) default '0',
  ccField text,
  ccStatus char(1) default '0',
  bccField text,
  bccStatus char(1) default '0',
  subjectField text,
  subjectStatus char(1) default '0',
  acknowledgement text,
  storeEntries char(1) default NULL
) TYPE=MyISAM;

--
-- Dumping data for table 'MailForm'
--



--
-- Table structure for table 'MailForm_entry'
--

CREATE TABLE MailForm_entry (
  entryId int(11) NOT NULL default '0',
  wobjectId int(11) NOT NULL default '0',
  userId int(11) default NULL,
  username varchar(255) default NULL,
  ipAddress varchar(255) default NULL,
  submissionDate int(11) NOT NULL default '0',
  PRIMARY KEY  (entryId)
) TYPE=MyISAM;

--
-- Dumping data for table 'MailForm_entry'
--



--
-- Table structure for table 'MailForm_entry_data'
--

CREATE TABLE MailForm_entry_data (
  entryId int(11) NOT NULL default '0',
  wobjectId int(11) NOT NULL default '0',
  sequenceNumber int(11) NOT NULL default '0',
  name varchar(255) NOT NULL default '',
  value text
) TYPE=MyISAM;

--
-- Dumping data for table 'MailForm_entry_data'
--



--
-- Table structure for table 'MailForm_field'
--

CREATE TABLE MailForm_field (
  wobjectId int(11) NOT NULL default '0',
  mailFieldId int(11) NOT NULL default '0',
  sequenceNumber int(11) NOT NULL default '0',
  name varchar(255) NOT NULL default '',
  status char(1) NOT NULL default '0',
  type varchar(30) NOT NULL default '',
  possibleValues text,
  defaultValue text,
  PRIMARY KEY  (mailFieldId)
) TYPE=MyISAM;

--
-- Dumping data for table 'MailForm_field'
--



--
-- Table structure for table 'MessageBoard'
--

CREATE TABLE MessageBoard (
  wobjectId int(11) NOT NULL default '0',
  messagesPerPage int(11) NOT NULL default '50',
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table 'MessageBoard'
--



--
-- Table structure for table 'Poll'
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
-- Dumping data for table 'Poll'
--



--
-- Table structure for table 'Poll_answer'
--

CREATE TABLE Poll_answer (
  wobjectId int(11) NOT NULL default '0',
  answer char(3) default NULL,
  userId int(11) default NULL,
  ipAddress varchar(50) default NULL
) TYPE=MyISAM;

--
-- Dumping data for table 'Poll_answer'
--



--
-- Table structure for table 'Product'
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
  productTemplateId int(11) NOT NULL default '1',
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table 'Product'
--



--
-- Table structure for table 'Product_accessory'
--

CREATE TABLE Product_accessory (
  wobjectId int(11) NOT NULL default '0',
  AccessoryWobjectId int(11) NOT NULL default '0',
  sequenceNumber int(11) NOT NULL default '0',
  PRIMARY KEY  (wobjectId,AccessoryWobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table 'Product_accessory'
--



--
-- Table structure for table 'Product_benefit'
--

CREATE TABLE Product_benefit (
  wobjectId int(11) NOT NULL default '0',
  productBenefitId int(11) NOT NULL default '0',
  benefit varchar(255) default NULL,
  sequenceNumber int(11) NOT NULL default '0',
  PRIMARY KEY  (productBenefitId)
) TYPE=MyISAM;

--
-- Dumping data for table 'Product_benefit'
--



--
-- Table structure for table 'Product_feature'
--

CREATE TABLE Product_feature (
  wobjectId int(11) NOT NULL default '0',
  productFeatureId int(11) NOT NULL default '0',
  feature varchar(255) default NULL,
  sequenceNumber int(11) NOT NULL default '0',
  PRIMARY KEY  (productFeatureId)
) TYPE=MyISAM;

--
-- Dumping data for table 'Product_feature'
--



--
-- Table structure for table 'Product_related'
--

CREATE TABLE Product_related (
  wobjectId int(11) NOT NULL default '0',
  RelatedWobjectId int(11) NOT NULL default '0',
  sequenceNumber int(11) NOT NULL default '0',
  PRIMARY KEY  (wobjectId,RelatedWobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table 'Product_related'
--



--
-- Table structure for table 'Product_specification'
--

CREATE TABLE Product_specification (
  wobjectId int(11) NOT NULL default '0',
  productSpecificationId int(11) NOT NULL default '0',
  name varchar(255) default NULL,
  value varchar(255) default NULL,
  units varchar(255) default NULL,
  sequenceNumber int(11) NOT NULL default '0',
  PRIMARY KEY  (productSpecificationId)
) TYPE=MyISAM;

--
-- Dumping data for table 'Product_specification'
--



--
-- Table structure for table 'Product_template'
--

CREATE TABLE Product_template (
  productTemplateId int(11) NOT NULL default '0',
  name varchar(255) default NULL,
  template text,
  PRIMARY KEY  (productTemplateId)
) TYPE=MyISAM;

--
-- Dumping data for table 'Product_template'
--


INSERT INTO Product_template VALUES (1,'Default','<style>\r\n.productFeatureHeader,.productSpecificationHeader,.productRelatedHeader,.productAccessoryHeader, .productBenefitHeader  {\r\n font-weight: bold;\r\n font-size: 15px;\r\n}\r\n.productFeature,.productSpecification,.productRelated,.productAccessory, .productBenefit {\r\n font-size: 12px;\r\n}\r\n.productAttributeSeperator {\r\n background-color: black;\r\n}\r\n\r\n\r\n</style>\r\n<table width=\"100%\" cellpadding=\"3\" cellspacing=\"0\" border=\"0\">\r\n<tr>\r\n  <td class=\"content\" valign=\"top\">^Product_Description;<p>\r\n    <b>Price:</b> ^Product_Price;<br>\r\n    <b>Product Number:</b> ^Product_Number;<p>\r\n    ^Product_Brochure;<br>\r\n    ^Product_Manual;<br>\r\n    ^Product_Warranty;<br>\r\n  </td>\r\n  <td valign=\"top\">\r\n    ^Product_Thumbnail1;<p>\r\n    ^Product_Thumbnail2;<p>\r\n    ^Product_Thumbnail3;<p>\r\n  </td>\r\n</tr>\r\n</table>\r\n<table border=\"0\" cellpadding=\"0\" cellspacing=\"5\">\r\n<tr>\r\n  <td valign=\"top\" class=\"productFeature\"><div class=\"productFeatureHeader\">Features</div>^Product_Features;<p/></td>\r\n  <td class=\"productAttributeSeperator\"><img src=\"^Extras;spacer.gif\" width=\"1\" height=\"1\"></td>\r\n  <td valign=\"top\" class=\"productBenefit\"><div class=\"productBenefitHeader\">Benefits</div>^Product_Benefits;<p/></td>\r\n  <td class=\"productAttributeSeperator\"><img src=\"^Extras;spacer.gif\" width=\"1\" height=\"1\"></td>\r\n  <td valign=\"top\" class=\"productSpecification\"><div class=\"productSpecificationHeader\">Specifications</div>^Product_Specifications;<p/></td>\r\n  <td class=\"productAttributeSeperator\"><img src=\"^Extras;spacer.gif\" width=\"1\" height=\"1\"></td>\r\n  <td valign=\"top\" class=\"productAccessory\"><div class=\"productAccessoryHeader\">Accessories</div>^Product_Accessories;<p/></td>\r\n  <td class=\"productAttributeSeperator\"><img src=\"^Extras;spacer.gif\" width=\"1\" height=\"1\"></td>\r\n  <td valign=\"top\" class=\"productRelated\"><div class=\"productRelatedHeader\">Related Products</div>^Product_Related;</td>\r\n</tr>\r\n</table>\r\n\r\n');
INSERT INTO Product_template VALUES (2,'Benefits Showcase','<style>\r\n.productOptions {\r\n  font-family: Helvetica, Arial, sans-serif;\r\n  font-size: 11px;\r\n}\r\n</style>\r\n\r\n^Product_Image1;\r\n<table width=\"100%\" cellpadding=\"3\" cellspacing=\"0\" border=\"0\">\r\n<tr>\r\n  <td class=\"content\" valign=\"top\" width=\"66%\">^Product_Description;<p>\r\n  <b>Benefits</b><br>\r\n^Product_Benefits;\r\n  </td>\r\n  <td valign=\"top\" width=\"34%\" class=\"productOptions\">\r\n^Product_Thumbnail2;<p>\r\n<b>Specifications</b><br>\r\n^Product_Specifications;<p>\r\n<b>Options</b><br>\r\n^Product_Accessories;<p>\r\n<b>Other Products</b><br>\r\n^Product_Related;<p>\r\n  </td>\r\n</tr>\r\n</table>\r\n\r\n');
INSERT INTO Product_template VALUES (3,'Three Columns','<style>\r\n.productFeatureHeader,.productSpecificationHeader,.productRelatedHeader,.productAccessoryHeader, .productBenefitHeader  {\r\n font-weight: bold;\r\n font-size: 15px;\r\n}\r\n.productFeature,.productSpecification,.productRelated,.productAccessory, .productBenefit {\r\n font-size: 12px;\r\n}\r\n\r\n</style>\r\n^Product_Description;<p>\r\n\r\n<table width=\"100%\" cellpadding=\"3\" cellspacing=\"0\" border=\"0\">\r\n<tr>\r\n  <td align=\"center\">^Product_Thumbnail1;</td>\r\n   <td align=\"center\">^Product_Thumbnail2;</td>\r\n  <td align=\"center\">^Product_Thumbnail3;</td>\r\n</tr>\r\n</table>\r\n<table border=\"0\" cellpadding=\"0\" cellspacing=\"5\" width=\"100%\">\r\n<tr>\r\n  <td valign=\"top\" class=\"tableData\" width=\"35%\">\r\n<b>Features</b><br>^Product_Features;<p/>\r\n<b>Benefits</b><br>^Product_Benefits;<p/>\r\n</td>\r\n  <td valign=\"top\" class=\"tableData\" width=\"35%\">\r\n<b>Specifications</b><br>^Product_Specifications;<p/>\r\n<b>Accessories</b><br>^Product_Accessories;<p/>\r\n<b>Related Products</b><br>^Product_Related;<p/>\r\n</td>\r\n  <td class=\"tableData\" valign=\"top\" width=\"30%\">\r\n    <b>Price:</b> ^Product_Price;<br>\r\n    <b>Product Number:</b> ^Product_Number;<p>\r\n    ^Product_Brochure;<br>\r\n    ^Product_Manual;<br>\r\n    ^Product_Warranty;<br>\r\n  </td>\r\n</tr>\r\n</table>\r\n\r\n');
INSERT INTO Product_template VALUES (4,'Left Column Collateral','<style>\r\n.productCollateral {\r\n font-size: 11px;\r\n}\r\n</style>\r\n<table width=\"100%\">\r\n<tr><td valign=\"top\" class=\"productCollateral\" width=\"100\">\r\n<img src=\"^Extras;spacer.gif\" width=\"100\" height=\"1\"><br>\r\n^Product_Brochure;<br>\r\n^Product_Manual;<br>\r\n^Product_Warranty;<br>\r\n<br>\r\n<div align=\"center\">\r\n^Product_Thumbnail1;<p>\r\n^Product_Thumbnail2;<p>\r\n^Product_Thumbnail3;<p>\r\n</div>\r\n</td><td valign=\"top\" class=\"content\" width=\"100%\">\r\n^Product_Description;<p>\r\n<b>Specs:</b><br>\r\n^Product_Specifications;<p>\r\n<b>Features:</b><br>\r\n^Product_Features;<p>\r\n<b>Options:</b><br>\r\n^Product_Accessories;<p>\r\n</td></tr>\r\n</table>');

--
-- Table structure for table 'SQLReport'
--

CREATE TABLE SQLReport (
  wobjectId int(11) NOT NULL default '0',
  template text,
  dbQuery text,
  DSN varchar(255) default NULL,
  username varchar(255) default NULL,
  identifier varchar(255) default NULL,
  convertCarriageReturns int(11) NOT NULL default '0',
  paginateAfter int(11) NOT NULL default '50',
  preprocessMacros int(11) NOT NULL default '0',
  debugMode int(11) NOT NULL default '0',
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table 'SQLReport'
--



--
-- Table structure for table 'SiteMap'
--

CREATE TABLE SiteMap (
  wobjectId int(11) NOT NULL default '0',
  startAtThisLevel int(11) default NULL,
  depth int(11) NOT NULL default '0',
  indent int(11) NOT NULL default '5',
  bullet varchar(30) NOT NULL default '&middot',
  lineSpacing int(11) NOT NULL default '1',
  displaySynopsis int(11) NOT NULL default '0',
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table 'SiteMap'
--


INSERT INTO SiteMap VALUES (-1,0,0,5,'&middot;',1,1);

--
-- Table structure for table 'SyndicatedContent'
--

CREATE TABLE SyndicatedContent (
  wobjectId int(11) NOT NULL default '0',
  rssUrl text,
  content text,
  lastFetched int(11) default NULL,
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table 'SyndicatedContent'
--



--
-- Table structure for table 'UserSubmission'
--

CREATE TABLE UserSubmission (
  wobjectId int(11) NOT NULL default '0',
  groupToContribute int(11) default NULL,
  submissionsPerPage int(11) NOT NULL default '50',
  defaultStatus varchar(30) default 'Approved',
  groupToApprove int(11) NOT NULL default '4',
  allowDiscussion int(11) NOT NULL default '0',
  displayThumbnails int(11) NOT NULL default '0',
  layout varchar(30) NOT NULL default 'traditional',
  karmaPerSubmission int(11) NOT NULL default '0',
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table 'UserSubmission'
--



--
-- Table structure for table 'UserSubmission_submission'
--

CREATE TABLE UserSubmission_submission (
  wobjectId int(11) NOT NULL default '0',
  submissionId int(11) NOT NULL default '0',
  title varchar(128) default NULL,
  dateSubmitted int(11) default NULL,
  username varchar(30) default NULL,
  userId int(11) default NULL,
  content text,
  image varchar(255) default NULL,
  attachment varchar(255) default NULL,
  status varchar(30) default NULL,
  convertCarriageReturns int(11) NOT NULL default '0',
  views int(11) NOT NULL default '0',
  PRIMARY KEY  (submissionId)
) TYPE=MyISAM;

--
-- Dumping data for table 'UserSubmission_submission'
--



--
-- Table structure for table 'WobjectProxy'
--

CREATE TABLE WobjectProxy (
  wobjectId int(11) NOT NULL default '0',
  proxiedWobjectId int(11) NOT NULL default '0',
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table 'WobjectProxy'
--



--
-- Table structure for table 'discussion'
--

CREATE TABLE discussion (
  messageId int(11) NOT NULL default '0',
  rid int(11) default NULL,
  wobjectId int(11) NOT NULL default '0',
  pid int(11) default NULL,
  userId int(11) default NULL,
  username varchar(30) default NULL,
  subject varchar(255) default NULL,
  message text,
  dateOfPost int(11) default NULL,
  subId int(11) default NULL,
  views int(11) NOT NULL default '0',
  locked int(11) NOT NULL default '0',
  status varchar(30) NOT NULL default 'Approved',
  PRIMARY KEY  (messageId)
) TYPE=MyISAM;

--
-- Dumping data for table 'discussion'
--



--
-- Table structure for table 'groupings'
--

CREATE TABLE groupings (
  groupId int(11) NOT NULL default '0',
  userId int(11) NOT NULL default '0',
  expireDate int(11) NOT NULL default '2114402400',
  PRIMARY KEY  (groupId,userId)
) TYPE=MyISAM;

--
-- Dumping data for table 'groupings'
--


INSERT INTO groupings VALUES (5,3,2114402400);
INSERT INTO groupings VALUES (4,3,2114402400);
INSERT INTO groupings VALUES (3,3,2114402400);
INSERT INTO groupings VALUES (6,3,2114402400);

--
-- Table structure for table 'groups'
--

CREATE TABLE groups (
  groupId int(11) NOT NULL default '0',
  groupName varchar(30) default NULL,
  description varchar(255) default NULL,
  expireAfter int(11) NOT NULL default '314496000',
  karmaThreshold int(11) NOT NULL default '1000000000',
  PRIMARY KEY  (groupId)
) TYPE=MyISAM;

--
-- Dumping data for table 'groups'
--


INSERT INTO groups VALUES (1,'Visitors','This is the public group that has no privileges.',314496000,1000000000);
INSERT INTO groups VALUES (2,'Registered Users','All registered users belong to this group automatically. There are no associated privileges other than that the user has an account and is logged in.',314496000,1000000000);
INSERT INTO groups VALUES (3,'Admins','Anyone who belongs to this group has privileges to do anything and everything.',314496000,1000000000);
INSERT INTO groups VALUES (4,'Content Managers','Users that have privileges to edit content on this site. The user still needs to be added to a group that has editing privileges on specific pages.',314496000,1000000000);
INSERT INTO groups VALUES (5,'Style Managers','Users that have privileges to edit styles for this site. These privileges do not allow the user to assign privileges to a page, just define them to be used.',314496000,1000000000);
INSERT INTO groups VALUES (6,'Package Managers','Users that have privileges to add, edit, and delete packages of wobjects and pages to deploy.',314496000,1000000000);
INSERT INTO groups VALUES (7,'Everyone','A group that automatically includes all users including Visitors.',314496000,1000000000);
INSERT INTO groups VALUES (8,'Template Managers','Users that have privileges to edit templates for this site.',314496000,1000000000);
INSERT INTO groups VALUES (9,'Image Managers','Users that have privileges to add, edit, and delete images from the image manager. Content managers can view by default',314496000,1000000000);

--
-- Table structure for table 'help'
--

CREATE TABLE help (
  helpId int(11) NOT NULL default '0',
  namespace varchar(30) NOT NULL default 'WebGUI',
  titleId int(11) default NULL,
  bodyId int(11) default NULL,
  seeAlso text,
  PRIMARY KEY  (helpId,namespace),
  KEY helpId (helpId)
) TYPE=MyISAM;

--
-- Dumping data for table 'help'
--


INSERT INTO help VALUES (20,'WebGUI',670,625,'26,WebGUI;');
INSERT INTO help VALUES (1,'DownloadManager',61,71,'2,DownloadManager;21,WebGUI;');
INSERT INTO help VALUES (23,'WebGUI',673,628,'26,WebGUI;');
INSERT INTO help VALUES (26,'WebGUI',676,631,'36,WebGUI;20,WebGUI;23,WebGUI;');
INSERT INTO help VALUES (28,'WebGUI',678,633,'1,WebGUI;3,WebGUI;');
INSERT INTO help VALUES (31,'WebGUI',681,636,'30,WebGUI;1,WebGUI;3,WebGUI;');
INSERT INTO help VALUES (30,'WebGUI',680,635,'31,WebGUI;');
INSERT INTO help VALUES (25,'WebGUI',675,630,NULL);
INSERT INTO help VALUES (1,'Item',61,71,'21,WebGUI;');
INSERT INTO help VALUES (6,'WebGUI',656,611,'12,WebGUI;');
INSERT INTO help VALUES (46,'WebGUI',696,651,NULL);
INSERT INTO help VALUES (22,'WebGUI',672,627,'12,WebGUI;');
INSERT INTO help VALUES (1,'UserSubmission',61,71,'21,WebGUI;');
INSERT INTO help VALUES (24,'WebGUI',674,629,'12,WebGUI;');
INSERT INTO help VALUES (1,'FAQ',61,71,'2,FAQ;21,WebGUI;');
INSERT INTO help VALUES (13,'WebGUI',663,618,'12,WebGUI;');
INSERT INTO help VALUES (1,'SyndicatedContent',61,71,'21,WebGUI;');
INSERT INTO help VALUES (1,'EventsCalendar',61,71,'2,EventsCalendar;21,WebGUI;');
INSERT INTO help VALUES (1,'MessageBoard',61,71,'21,WebGUI;');
INSERT INTO help VALUES (1,'LinkList',61,71,'2,LinkList;21,WebGUI;');
INSERT INTO help VALUES (21,'WebGUI',671,626,'1,Article;1,DownloadManager;1,EventsCalendar;1,ExtraColumn;1,FAQ;1,Item;1,LinkList;19,WebGUI;1,MailForm;1,MessageBoard;1,Poll;1,Product;1,SiteMap;1,SQLReport;18,WebGUI;1,SyndicatedContent;1,UserSubmission;1,WobjectProxy;27,WebGUI;14,WebGUI;');
INSERT INTO help VALUES (1,'Article',61,71,'21,WebGUI;');
INSERT INTO help VALUES (1,'ExtraColumn',61,71,'21,WebGUI;');
INSERT INTO help VALUES (27,'WebGUI',677,632,'21,WebGUI;');
INSERT INTO help VALUES (1,'Poll',61,71,'21,WebGUI;');
INSERT INTO help VALUES (1,'SiteMap',61,71,'21,WebGUI;');
INSERT INTO help VALUES (1,'SQLReport',61,71,'21,WebGUI;');
INSERT INTO help VALUES (18,'WebGUI',668,623,NULL);
INSERT INTO help VALUES (17,'WebGUI',667,622,'10,WebGUI;');
INSERT INTO help VALUES (2,'WebGUI',652,607,'12,WebGUI;');
INSERT INTO help VALUES (15,'WebGUI',665,620,'10,WebGUI;');
INSERT INTO help VALUES (16,'WebGUI',666,621,'9,WebGUI;');
INSERT INTO help VALUES (14,'WebGUI',664,619,'21,WebGUI;');
INSERT INTO help VALUES (12,'WebGUI',662,617,'6,WebGUI;29,WebGUI;13,WebGUI;24,WebGUI;22,WebGUI;2,WebGUI;');
INSERT INTO help VALUES (10,'WebGUI',660,615,'17,WebGUI;15,WebGUI;8,WebGUI;');
INSERT INTO help VALUES (8,'WebGUI',658,613,'10,WebGUI;32,WebGUI;5,WebGUI;7,WebGUI;');
INSERT INTO help VALUES (9,'WebGUI',659,614,'19,WebGUI;18,WebGUI;16,WebGUI;4,WebGUI;');
INSERT INTO help VALUES (7,'WebGUI',657,612,'8,WebGUI;');
INSERT INTO help VALUES (32,'WebGUI',682,637,'8,WebGUI;');
INSERT INTO help VALUES (5,'WebGUI',655,610,'8,WebGUI;');
INSERT INTO help VALUES (3,'WebGUI',653,608,'1,WebGUI;');
INSERT INTO help VALUES (4,'WebGUI',654,609,'9,WebGUI;');
INSERT INTO help VALUES (1,'WebGUI',642,606,'3,WebGUI;');
INSERT INTO help VALUES (29,'WebGUI',679,634,'12,WebGUI;');
INSERT INTO help VALUES (33,'WebGUI',683,638,'34,WebGUI;35,WebGUI;');
INSERT INTO help VALUES (34,'WebGUI',684,639,'33,WebGUI;');
INSERT INTO help VALUES (35,'WebGUI',685,640,'33,WebGUI;');
INSERT INTO help VALUES (19,'WebGUI',669,624,'9,WebGUI;21,WebGUI;');
INSERT INTO help VALUES (1,'MailForm',61,71,'21,WebGUI;');
INSERT INTO help VALUES (2,'MailForm',62,72,'1,MailForm;');
INSERT INTO help VALUES (36,'WebGUI',686,641,'26,WebGUI;');
INSERT INTO help VALUES (2,'DownloadManager',72,73,'1,DownloadManager;');
INSERT INTO help VALUES (2,'EventsCalendar',72,73,'1,EventsCalendar;');
INSERT INTO help VALUES (2,'FAQ',72,73,'1,FAQ;');
INSERT INTO help VALUES (2,'LinkList',72,73,'1,LinkList;');
INSERT INTO help VALUES (47,'WebGUI',697,698,'1,Article;17,WebGUI;1,MessageBoard;1,Poll;2,WebGUI;1,UserSubmission;');
INSERT INTO help VALUES (1,'WobjectProxy',5,6,'21,WebGUI;');
INSERT INTO help VALUES (1,'Product',38,39,'5,Product;4,Product;6,Product;2,Product;3,Product;7,Product;21,WebGUI;');
INSERT INTO help VALUES (2,'Product',40,41,'6,Product;1,Product;');
INSERT INTO help VALUES (3,'Product',42,43,'1,Product;');
INSERT INTO help VALUES (4,'Product',44,45,'1,Product;');
INSERT INTO help VALUES (5,'Product',46,47,'1,Product;');
INSERT INTO help VALUES (48,'WebGUI',708,709,'12,WebGUI;');
INSERT INTO help VALUES (6,'Product',49,50,'2,Product;1,Product;');
INSERT INTO help VALUES (7,'Product',62,63,'1,Product;');

--
-- Table structure for table 'imageGroup'
--

CREATE TABLE imageGroup (
  imageGroupId int(11) NOT NULL default '0',
  name varchar(128) NOT NULL default 'untitled',
  parentId int(11) NOT NULL default '0',
  description varchar(255) default NULL
) TYPE=MyISAM;

--
-- Dumping data for table 'imageGroup'
--


INSERT INTO imageGroup VALUES (0,'Root',0,'Top level');

--
-- Table structure for table 'images'
--

CREATE TABLE images (
  imageId int(11) NOT NULL default '0',
  name varchar(128) NOT NULL default 'untitled',
  filename varchar(255) default NULL,
  parameters varchar(255) default NULL,
  userId int(11) default NULL,
  username varchar(128) default NULL,
  dateUploaded int(11) default NULL,
  imageGroupId int(11) NOT NULL default '0',
  PRIMARY KEY  (imageId)
) TYPE=MyISAM;

--
-- Dumping data for table 'images'
--



--
-- Table structure for table 'incrementer'
--

CREATE TABLE incrementer (
  incrementerId varchar(50) NOT NULL default '',
  nextValue int(11) NOT NULL default '1',
  PRIMARY KEY  (incrementerId)
) TYPE=MyISAM;

--
-- Dumping data for table 'incrementer'
--


INSERT INTO incrementer VALUES ('groupId',26);
INSERT INTO incrementer VALUES ('messageId',1);
INSERT INTO incrementer VALUES ('pageId',26);
INSERT INTO incrementer VALUES ('styleId',26);
INSERT INTO incrementer VALUES ('userId',26);
INSERT INTO incrementer VALUES ('wobjectId',1);
INSERT INTO incrementer VALUES ('eventId',1);
INSERT INTO incrementer VALUES ('linkId',1);
INSERT INTO incrementer VALUES ('questionId',1);
INSERT INTO incrementer VALUES ('submissionId',1);
INSERT INTO incrementer VALUES ('recurringEventId',1);
INSERT INTO incrementer VALUES ('messageLogId',1);
INSERT INTO incrementer VALUES ('downloadId',1);
INSERT INTO incrementer VALUES ('imageId',1);
INSERT INTO incrementer VALUES ('profileCategoryId',1000);
INSERT INTO incrementer VALUES ('templateId',1000);
INSERT INTO incrementer VALUES ('imageGroupId',1);
INSERT INTO incrementer VALUES ('productFeatureId',1000);
INSERT INTO incrementer VALUES ('productSpecificationId',1000);
INSERT INTO incrementer VALUES ('languageId',1000);
INSERT INTO incrementer VALUES ('mailFieldId',1000);
INSERT INTO incrementer VALUES ('mailEntryId',1000);
INSERT INTO incrementer VALUES ('productBenefitId',1000);
INSERT INTO incrementer VALUES ('productTemplateId',1000);

--
-- Table structure for table 'international'
--

CREATE TABLE international (
  internationalId int(11) NOT NULL default '0',
  namespace varchar(30) NOT NULL default 'WebGUI',
  languageId int(11) NOT NULL default '1',
  message mediumtext,
  lastUpdated int(11) default NULL,
  PRIMARY KEY  (internationalId,namespace,languageId)
) TYPE=MyISAM;

--
-- Dumping data for table 'international'
--


INSERT INTO international VALUES (367,'WebGUI',1,'Expire After',1031514049);
INSERT INTO international VALUES (39,'UserSubmission',3,'Post een reactie',1031510000);
INSERT INTO international VALUES (1,'Article',1,'Article',1031514049);
INSERT INTO international VALUES (1,'Article',4,'Artículo',1031510000);
INSERT INTO international VALUES (1,'Article',5,'Artigo',1031510000);
INSERT INTO international VALUES (37,'UserSubmission',3,'Verwijder',1031510000);
INSERT INTO international VALUES (1,'EventsCalendar',1,'Proceed to add event?',1031514049);
INSERT INTO international VALUES (1,'EventsCalendar',5,'Proseguir com a adição do evento?',1031510000);
INSERT INTO international VALUES (10,'LinkList',2,'Link Liste\nbearbeiten',1031510000);
INSERT INTO international VALUES (35,'UserSubmission',3,'Titel',1031510000);
INSERT INTO international VALUES (1,'ExtraColumn',1,'Extra Column',1031514049);
INSERT INTO international VALUES (1,'ExtraColumn',4,'Columna Extra',1031510000);
INSERT INTO international VALUES (1,'ExtraColumn',5,'Coluna extra',1031510000);
INSERT INTO international VALUES (34,'UserSubmission',3,'Return converteren',1031510000);
INSERT INTO international VALUES (1,'FAQ',1,'Proceed to add question?',1031514049);
INSERT INTO international VALUES (1,'FAQ',5,'Proseguir com a adição da questão?',1031510000);
INSERT INTO international VALUES (1,'Item',1,'Link URL',1031514049);
INSERT INTO international VALUES (1,'LinkList',1,'Indent',1031514049);
INSERT INTO international VALUES (1,'LinkList',5,'Destaque',1031510000);
INSERT INTO international VALUES (5,'ExtraColumn',6,'StyleSheet Class',1031510000);
INSERT INTO international VALUES (700,'WebGUI',6,'Dag',1031510000);
INSERT INTO international VALUES (5,'Article',6,'Body',1031510000);
INSERT INTO international VALUES (4,'WebGUI',6,'Kontrolera inställningar.',1031510000);
INSERT INTO international VALUES (10,'Poll',2,'Abstimmung\nzurücksetzen',1031510000);
INSERT INTO international VALUES (33,'UserSubmission',3,'Bijlage',1031510000);
INSERT INTO international VALUES (1,'Poll',1,'Poll',1031514049);
INSERT INTO international VALUES (1,'Poll',4,'Encuesta',1031510000);
INSERT INTO international VALUES (1,'Poll',5,'Sondagem',1031510000);
INSERT INTO international VALUES (4,'UserSubmission',6,'Ditt medelande har blivit validerat.',1031510000);
INSERT INTO international VALUES (4,'SyndicatedContent',6,'Redigera Syndicated inehåll',1031510000);
INSERT INTO international VALUES (563,'WebGUI',2,'Standard\nstatus',1031510000);
INSERT INTO international VALUES (32,'UserSubmission',3,'Plaatje',1031510000);
INSERT INTO international VALUES (1,'SQLReport',1,'SQL Report',1031514049);
INSERT INTO international VALUES (1,'SQLReport',4,'Reporte SQL',1031510000);
INSERT INTO international VALUES (1,'SQLReport',5,'Relatório SQL',1031510000);
INSERT INTO international VALUES (31,'UserSubmission',3,'Inhoud',1031510000);
INSERT INTO international VALUES (1,'SyndicatedContent',1,'URL to RSS File',1031514049);
INSERT INTO international VALUES (1,'SyndicatedContent',5,'Ficheiro de URL para RSS',1031510000);
INSERT INTO international VALUES (1,'UserSubmission',1,'Who can approve?',1031514049);
INSERT INTO international VALUES (1,'UserSubmission',5,'Quem pode aprovar?',1031510000);
INSERT INTO international VALUES (18,'SQLReport',3,'Er waren geen resultaten voor deze query',1031510000);
INSERT INTO international VALUES (1,'WebGUI',1,'Add content...',1031514049);
INSERT INTO international VALUES (1,'WebGUI',4,'Agregar Contenido ...',1031510000);
INSERT INTO international VALUES (1,'WebGUI',5,'Adicionar conteudo...',1031510000);
INSERT INTO international VALUES (2,'EventsCalendar',1,'Events Calendar',1031514049);
INSERT INTO international VALUES (2,'EventsCalendar',4,'Calendario de Eventos',1031510000);
INSERT INTO international VALUES (2,'EventsCalendar',5,'Calendário de eventos',1031510000);
INSERT INTO international VALUES (4,'SiteMap',6,'Nivåer att traversera',1031510000);
INSERT INTO international VALUES (4,'Poll',6,'Vem kan rösta?',1031510000);
INSERT INTO international VALUES (4,'MessageBoard',6,'Meddelanden per sida',1031510000);
INSERT INTO international VALUES (4,'LinkList',6,'Kula',1031510000);
INSERT INTO international VALUES (10,'SQLReport',2,'Fehler: Das\nSQL-Statement ist im falschen Format.',1031510000);
INSERT INTO international VALUES (17,'SQLReport',3,'Debug: Query:',1031510000);
INSERT INTO international VALUES (2,'FAQ',1,'F.A.Q.',1031514049);
INSERT INTO international VALUES (2,'FAQ',4,'F.A.Q.',1031510000);
INSERT INTO international VALUES (2,'FAQ',5,'Perguntas mais frequentes',1031510000);
INSERT INTO international VALUES (2,'Item',1,'Attachment',1031514049);
INSERT INTO international VALUES (16,'SQLReport',3,'Debug?',1031510000);
INSERT INTO international VALUES (2,'LinkList',1,'Line Spacing',1031514049);
INSERT INTO international VALUES (2,'LinkList',5,'Espaço entre linhas',1031510000);
INSERT INTO international VALUES (1,'Article',10,'Artikel',1031510000);
INSERT INTO international VALUES (2,'MessageBoard',1,'Message Board',1031514049);
INSERT INTO international VALUES (2,'MessageBoard',4,'Table de Mensages',1031510000);
INSERT INTO international VALUES (2,'MessageBoard',5,'Quadro de mensagens',1031510000);
INSERT INTO international VALUES (4,'FAQ',6,'Lägg till fråga',1031510000);
INSERT INTO international VALUES (4,'ExtraColumn',6,'Bredd',1031510000);
INSERT INTO international VALUES (15,'SQLReport',3,'Verwerk macros voor query?',1031510000);
INSERT INTO international VALUES (2,'SiteMap',1,'Site Map',1031514049);
INSERT INTO international VALUES (2,'SiteMap',5,'Mapa do site',1031510000);
INSERT INTO international VALUES (10,'WebGUI',2,'Mülleimer\nanschauen',1031510000);
INSERT INTO international VALUES (4,'Article',6,'Slut datum',1031510000);
INSERT INTO international VALUES (3,'WebGUI',6,'Klistra in från klippbord...',1031510000);
INSERT INTO international VALUES (14,'SQLReport',3,'Breek pagina af na',1031510000);
INSERT INTO international VALUES (2,'SyndicatedContent',1,'Syndicated Content',1031514049);
INSERT INTO international VALUES (2,'SyndicatedContent',5,'Conteudo sindical',1031510000);
INSERT INTO international VALUES (2,'UserSubmission',1,'Who can contribute?',1031514049);
INSERT INTO international VALUES (2,'UserSubmission',4,'Quiénes pueden contribuir?',1031510000);
INSERT INTO international VALUES (2,'UserSubmission',5,'Quem pode contribuir?',1031510000);
INSERT INTO international VALUES (13,'SQLReport',3,'Converteer Return?',1031510000);
INSERT INTO international VALUES (2,'WebGUI',1,'Page',1031514049);
INSERT INTO international VALUES (2,'WebGUI',4,'Página',1031510000);
INSERT INTO international VALUES (2,'WebGUI',5,'Página',1031510000);
INSERT INTO international VALUES (3,'Article',1,'Start Date',1031514049);
INSERT INTO international VALUES (3,'Article',4,'Fecha Inicio',1031510000);
INSERT INTO international VALUES (3,'Article',5,'Data de inicio',1031510000);
INSERT INTO international VALUES (11,'Article',2,'(Bitte anklicken,\nfalls Sie nicht &lt;br&gt; in Ihrem Text hinzufügen.)',1031510000);
INSERT INTO international VALUES (3,'SyndicatedContent',6,'Lägg till Syndicated inehåll',1031510000);
INSERT INTO international VALUES (3,'SQLReport',6,'Rapport Mall',1031510000);
INSERT INTO international VALUES (3,'SiteMap',6,'Starta från denna nivå?',1031510000);
INSERT INTO international VALUES (3,'Poll',6,'Aktiv',1031510000);
INSERT INTO international VALUES (9,'SiteMap',3,'Omschrijving laten zien?',1031510000);
INSERT INTO international VALUES (3,'ExtraColumn',1,'Spacer',1031514049);
INSERT INTO international VALUES (3,'ExtraColumn',4,'Espaciador',1031510000);
INSERT INTO international VALUES (3,'ExtraColumn',5,'Espaçamento',1031510000);
INSERT INTO international VALUES (564,'WebGUI',6,'Vem kan posta?',1031510000);
INSERT INTO international VALUES (3,'LinkList',6,'Öppna i ny ruta?',1031510000);
INSERT INTO international VALUES (3,'Item',1,'Delete Attachment',1031514049);
INSERT INTO international VALUES (11,'DownloadManager',2,'Neuen\nDownload hinzufügen.',1031510000);
INSERT INTO international VALUES (11,'Poll',3,'Stem!',1031510000);
INSERT INTO international VALUES (3,'LinkList',1,'Open in new window?',1031514049);
INSERT INTO international VALUES (3,'LinkList',5,'Abrir numa nova janela?',1031510000);
INSERT INTO international VALUES (564,'WebGUI',1,'Who can post?',1031514049);
INSERT INTO international VALUES (564,'WebGUI',4,'Quienes pueden mandar?',1031510000);
INSERT INTO international VALUES (564,'WebGUI',5,'Quem pode colocar novas?',1031510000);
INSERT INTO international VALUES (22,'MessageBoard',3,'Verwijder bericht',1031510000);
INSERT INTO international VALUES (3,'Poll',1,'Active',1031514049);
INSERT INTO international VALUES (3,'Poll',4,'Activar',1031510000);
INSERT INTO international VALUES (3,'Poll',5,'Activo',1031510000);
INSERT INTO international VALUES (3,'SiteMap',1,'Starting from this level?',1031514049);
INSERT INTO international VALUES (3,'SiteMap',5,'Iniciando neste nível?',1031510000);
INSERT INTO international VALUES (565,'WebGUI',3,'Wie kan bewerken?',1031510000);
INSERT INTO international VALUES (3,'SQLReport',1,'Report Template',1031514049);
INSERT INTO international VALUES (3,'SQLReport',4,'Modelo',1031510000);
INSERT INTO international VALUES (3,'SQLReport',5,'Template',1031510000);
INSERT INTO international VALUES (3,'ExtraColumn',6,'Mellanrumm',1031510000);
INSERT INTO international VALUES (3,'EventsCalendar',6,'Lägg till händelse kalender',1031510000);
INSERT INTO international VALUES (3,'Article',6,'Start datum',1031510000);
INSERT INTO international VALUES (4,'Item',3,'Item',1031510000);
INSERT INTO international VALUES (5,'Item',3,'Download bijlage',1031510000);
INSERT INTO international VALUES (3,'UserSubmission',1,'You have a new user submission to approve.',1031514049);
INSERT INTO international VALUES (3,'UserSubmission',5,'Tem nova submissão para aprovar.',1031510000);
INSERT INTO international VALUES (3,'WebGUI',1,'Paste from clipboard...',1031514049);
INSERT INTO international VALUES (3,'WebGUI',4,'Pegar desde el Portapapeles...',1031510000);
INSERT INTO international VALUES (3,'WebGUI',5,'Colar do clipboard...',1031510000);
INSERT INTO international VALUES (11,'Poll',2,'Abstimmen',1031510000);
INSERT INTO international VALUES (11,'MessageBoard',2,'Zurück zur\nBeitragsliste',1031510000);
INSERT INTO international VALUES (3,'Item',3,'Verwijder bijlage',1031510000);
INSERT INTO international VALUES (4,'Article',1,'End Date',1031514049);
INSERT INTO international VALUES (4,'Article',4,'Fecha finalización',1031510000);
INSERT INTO international VALUES (4,'Article',5,'Data de fim',1031510000);
INSERT INTO international VALUES (2,'Item',3,'Bijlage',1031510000);
INSERT INTO international VALUES (4,'EventsCalendar',1,'Happens only once.',1031514049);
INSERT INTO international VALUES (4,'EventsCalendar',4,'Sucede solo una vez.',1031510000);
INSERT INTO international VALUES (4,'EventsCalendar',5,'Apenas uma vez.',1031510000);
INSERT INTO international VALUES (1,'Item',3,'Link URL',1031510000);
INSERT INTO international VALUES (4,'ExtraColumn',1,'Width',1031514049);
INSERT INTO international VALUES (4,'ExtraColumn',4,'Ancho',1031510000);
INSERT INTO international VALUES (4,'ExtraColumn',5,'Largura',1031510000);
INSERT INTO international VALUES (2,'UserSubmission',6,'Vem kan göra inlägg?',1031510000);
INSERT INTO international VALUES (2,'SyndicatedContent',6,'Syndicated inehåll',1031510000);
INSERT INTO international VALUES (4,'Item',1,'Item',1031514049);
INSERT INTO international VALUES (16,'FAQ',3,'[top]',1031510000);
INSERT INTO international VALUES (4,'LinkList',1,'Bullet',1031514049);
INSERT INTO international VALUES (4,'LinkList',5,'Marca',1031510000);
INSERT INTO international VALUES (15,'FAQ',3,'A',1031510000);
INSERT INTO international VALUES (4,'MessageBoard',1,'Messages Per Page',1031514049);
INSERT INTO international VALUES (4,'MessageBoard',4,'Mensages por página',1031510000);
INSERT INTO international VALUES (4,'MessageBoard',5,'Mensagens por página',1031510000);
INSERT INTO international VALUES (14,'FAQ',3,'V',1031510000);
INSERT INTO international VALUES (4,'Poll',1,'Who can vote?',1031514049);
INSERT INTO international VALUES (4,'Poll',4,'Quiénes pueden votar?',1031510000);
INSERT INTO international VALUES (4,'Poll',5,'Quem pode votar?',1031510000);
INSERT INTO international VALUES (13,'FAQ',3,'Zet [top] link aan?',1031510000);
INSERT INTO international VALUES (4,'SiteMap',1,'Depth To Traverse',1031514049);
INSERT INTO international VALUES (4,'SiteMap',5,'profundidade a travessar',1031510000);
INSERT INTO international VALUES (11,'SQLReport',2,'Fehler: Es gab\nein Problem mit der Abfrage.',1031510000);
INSERT INTO international VALUES (12,'FAQ',3,'Zet V/A aan?',1031510000);
INSERT INTO international VALUES (4,'SQLReport',1,'Query',1031514049);
INSERT INTO international VALUES (4,'SQLReport',4,'Consulta',1031510000);
INSERT INTO international VALUES (4,'SQLReport',5,'Query',1031510000);
INSERT INTO international VALUES (11,'FAQ',3,'Zet inhoud aan?',1031510000);
INSERT INTO international VALUES (4,'SyndicatedContent',1,'Edit Syndicated Content',1031514049);
INSERT INTO international VALUES (4,'SyndicatedContent',5,'Modificar conteudo sindical',1031510000);
INSERT INTO international VALUES (19,'EventsCalendar',3,'Breek pagina af na',1031510000);
INSERT INTO international VALUES (4,'UserSubmission',1,'Your submission has been approved.',1031514049);
INSERT INTO international VALUES (4,'UserSubmission',5,'A sua submissão foi aprovada.',1031510000);
INSERT INTO international VALUES (4,'WebGUI',1,'Manage settings.',1031514049);
INSERT INTO international VALUES (4,'WebGUI',4,'Configurar Opciones.',1031510000);
INSERT INTO international VALUES (4,'WebGUI',5,'Organizar preferências.',1031510000);
INSERT INTO international VALUES (11,'WebGUI',2,'Mülleimer\nleeren',1031510000);
INSERT INTO international VALUES (38,'UserSubmission',1,'(Select \"No\" if you\'re writing an HTML/Rich Edit submission.)',1031514049);
INSERT INTO international VALUES (20,'EventsCalendar',1,'Add an event.',1031514049);
INSERT INTO international VALUES (18,'EventsCalendar',3,'Calendar Month',1031510000);
INSERT INTO international VALUES (700,'WebGUI',1,'Day(s)',1031514049);
INSERT INTO international VALUES (700,'WebGUI',4,'Día',1031510000);
INSERT INTO international VALUES (700,'WebGUI',5,'Dia',1031510000);
INSERT INTO international VALUES (5,'ExtraColumn',1,'StyleSheet Class',1031514049);
INSERT INTO international VALUES (5,'ExtraColumn',4,'Clase StyleSheet',1031510000);
INSERT INTO international VALUES (5,'ExtraColumn',5,'StyleSheet Class',1031510000);
INSERT INTO international VALUES (17,'EventsCalendar',3,'Lijst',1031510000);
INSERT INTO international VALUES (5,'FAQ',1,'Question',1031514049);
INSERT INTO international VALUES (5,'FAQ',4,'Pregunta',1031510000);
INSERT INTO international VALUES (5,'FAQ',5,'Questão',1031510000);
INSERT INTO international VALUES (5,'Item',1,'Download Attachment',1031514049);
INSERT INTO international VALUES (16,'EventsCalendar',3,'Kalender layout',1031510000);
INSERT INTO international VALUES (5,'LinkList',1,'Proceed to add link?',1031514049);
INSERT INTO international VALUES (5,'LinkList',5,'Proseguir com a adição do hiperlink?',1031510000);
INSERT INTO international VALUES (566,'WebGUI',1,'Edit Timeout',1031514049);
INSERT INTO international VALUES (566,'WebGUI',4,'Timeout de edición',1031510000);
INSERT INTO international VALUES (566,'WebGUI',5,'Modificar Timeout',1031510000);
INSERT INTO international VALUES (12,'Article',2,'Artikel\nbearbeiten',1031510000);
INSERT INTO international VALUES (15,'EventsCalendar',3,'Eind datum',1031510000);
INSERT INTO international VALUES (5,'Poll',1,'Graph Width',1031514049);
INSERT INTO international VALUES (5,'Poll',4,'Ancho del gráfico',1031510000);
INSERT INTO international VALUES (5,'Poll',5,'Largura do gráfico',1031510000);
INSERT INTO international VALUES (5,'SiteMap',1,'Edit Site Map',1031514049);
INSERT INTO international VALUES (5,'SiteMap',5,'Editar mapa do site',1031510000);
INSERT INTO international VALUES (14,'EventsCalendar',3,'Start datum',1031510000);
INSERT INTO international VALUES (5,'SQLReport',1,'DSN',1031514049);
INSERT INTO international VALUES (5,'SQLReport',4,'DSN',1031510000);
INSERT INTO international VALUES (5,'SQLReport',5,'DSN',1031510000);
INSERT INTO international VALUES (5,'SyndicatedContent',1,'Last Fetched',1031514049);
INSERT INTO international VALUES (5,'SyndicatedContent',5,'Ultima retirada',1031510000);
INSERT INTO international VALUES (21,'EventsCalendar',3,'Doorgaan met evenement toevoegen?',1031510000);
INSERT INTO international VALUES (5,'UserSubmission',1,'Your submission has been denied.',1031514049);
INSERT INTO international VALUES (5,'UserSubmission',5,'A sua submissão não foi aprovada.',1031510000);
INSERT INTO international VALUES (5,'WebGUI',1,'Manage groups.',1031514049);
INSERT INTO international VALUES (5,'WebGUI',4,'Configurar Grupos.',1031510000);
INSERT INTO international VALUES (5,'WebGUI',5,'Organizar grupos.',1031510000);
INSERT INTO international VALUES (6,'Article',1,'Image',1031514049);
INSERT INTO international VALUES (6,'Article',4,'Imagen',1031510000);
INSERT INTO international VALUES (6,'Article',5,'Imagem',1031510000);
INSERT INTO international VALUES (20,'EventsCalendar',3,'Evenement toevoegen',1031510000);
INSERT INTO international VALUES (701,'WebGUI',1,'Week(s)',1031514049);
INSERT INTO international VALUES (701,'WebGUI',4,'Semana',1031510000);
INSERT INTO international VALUES (701,'WebGUI',5,'Semana',1031510000);
INSERT INTO international VALUES (6,'ExtraColumn',1,'Edit Extra Column',1031514049);
INSERT INTO international VALUES (6,'ExtraColumn',4,'Editar Columna Extra',1031510000);
INSERT INTO international VALUES (6,'ExtraColumn',5,'Modificar coluna extra',1031510000);
INSERT INTO international VALUES (6,'FAQ',1,'Answer',1031514049);
INSERT INTO international VALUES (6,'FAQ',4,'Respuesta',1031510000);
INSERT INTO international VALUES (6,'FAQ',5,'Resposta',1031510000);
INSERT INTO international VALUES (12,'DownloadManager',2,'Sind Sie\nsicher, dass Sie diesen Download löschen möchten?',1031510000);
INSERT INTO international VALUES (22,'DownloadManager',3,'Doorgaan met download toevoegen',1031510000);
INSERT INTO international VALUES (6,'LinkList',1,'Link List',1031514049);
INSERT INTO international VALUES (6,'LinkList',4,'Lista de Enlaces',1031510000);
INSERT INTO international VALUES (6,'LinkList',5,'Lista de hiperlinks',1031510000);
INSERT INTO international VALUES (6,'MessageBoard',1,'Edit Message Board',1031514049);
INSERT INTO international VALUES (6,'MessageBoard',4,'Editar Tabla de Mensages',1031510000);
INSERT INTO international VALUES (6,'MessageBoard',5,'Modificar quadro de mensagens',1031510000);
INSERT INTO international VALUES (21,'DownloadManager',3,'Miniaturen weergeven?',1031510000);
INSERT INTO international VALUES (6,'Poll',1,'Question',1031514049);
INSERT INTO international VALUES (6,'Poll',4,'Pregunta',1031510000);
INSERT INTO international VALUES (6,'Poll',5,'Questão',1031510000);
INSERT INTO international VALUES (6,'SiteMap',1,'Indent',1031514049);
INSERT INTO international VALUES (6,'SiteMap',5,'Destaque',1031510000);
INSERT INTO international VALUES (12,'EventsCalendar',2,'Veranstaltungskalender bearbeiten',1031510000);
INSERT INTO international VALUES (20,'DownloadManager',3,'Kap pagina af na',1031510000);
INSERT INTO international VALUES (6,'SQLReport',1,'Database User',1031514049);
INSERT INTO international VALUES (6,'SQLReport',4,'Usuario de la Base de Datos',1031510000);
INSERT INTO international VALUES (6,'SQLReport',5,'User da base de dados',1031510000);
INSERT INTO international VALUES (6,'SyndicatedContent',1,'Current Content',1031514049);
INSERT INTO international VALUES (6,'SyndicatedContent',5,'Conteudo actual',1031510000);
INSERT INTO international VALUES (12,'LinkList',2,'Link\nbearbeiten',1031510000);
INSERT INTO international VALUES (19,'DownloadManager',3,'U heeft geen bestanden te downloaden',1031510000);
INSERT INTO international VALUES (6,'UserSubmission',1,'Submissions Per Page',1031514049);
INSERT INTO international VALUES (6,'UserSubmission',4,'Contribuciones por página',1031510000);
INSERT INTO international VALUES (6,'UserSubmission',5,'Submissões por página',1031510000);
INSERT INTO international VALUES (6,'WebGUI',1,'Manage styles.',1031514049);
INSERT INTO international VALUES (6,'WebGUI',4,'Configurar Estilos',1031510000);
INSERT INTO international VALUES (6,'WebGUI',5,'Organizar estilos.',1031510000);
INSERT INTO international VALUES (18,'DownloadManager',3,'Alternatieve Versie #2',1031510000);
INSERT INTO international VALUES (7,'Article',1,'Link Title',1031514049);
INSERT INTO international VALUES (7,'Article',4,'Link Título',1031510000);
INSERT INTO international VALUES (7,'Article',5,'Titulo da hiperlink',1031510000);
INSERT INTO international VALUES (2,'SiteMap',6,'Site Karta',1031510000);
INSERT INTO international VALUES (2,'Poll',6,'Lägg till fråga',1031510000);
INSERT INTO international VALUES (2,'MessageBoard',6,'Meddelande Forum',1031510000);
INSERT INTO international VALUES (12,'MessageBoard',2,'Beitrag\nbearbeiten',1031510000);
INSERT INTO international VALUES (7,'FAQ',1,'Are you certain that you want to delete this question?',1031514049);
INSERT INTO international VALUES (7,'FAQ',4,'Está seguro de querer eliminar ésta pregunta?',1031510000);
INSERT INTO international VALUES (7,'FAQ',5,'Tem a certeza que quer apagar esta questão?',1031510000);
INSERT INTO international VALUES (2,'Item',6,'Bilagor',1031510000);
INSERT INTO international VALUES (2,'FAQ',6,'F.A.Q.',1031510000);
INSERT INTO international VALUES (2,'ExtraColumn',6,'Lägg till Extra Column',1031510000);
INSERT INTO international VALUES (17,'DownloadManager',3,'Alternatieve Versie #1',1031510000);
INSERT INTO international VALUES (7,'MessageBoard',1,'Author:',1031514049);
INSERT INTO international VALUES (7,'MessageBoard',4,'Autor:',1031510000);
INSERT INTO international VALUES (7,'MessageBoard',5,'Autor:',1031510000);
INSERT INTO international VALUES (12,'SQLReport',2,'Fehler:\nDatenbankverbindung konnte nicht aufgebaut werden.',1031510000);
INSERT INTO international VALUES (7,'Poll',1,'Answers',1031514049);
INSERT INTO international VALUES (7,'Poll',4,'Respuestas',1031510000);
INSERT INTO international VALUES (7,'Poll',5,'Respostas',1031510000);
INSERT INTO international VALUES (16,'DownloadManager',3,'Upload datum',1031510000);
INSERT INTO international VALUES (7,'SiteMap',1,'Bullet',1031514049);
INSERT INTO international VALUES (7,'SiteMap',5,'Marca',1031510000);
INSERT INTO international VALUES (7,'SQLReport',1,'Database Password',1031514049);
INSERT INTO international VALUES (7,'SQLReport',4,'Password de la Base de Datos',1031510000);
INSERT INTO international VALUES (7,'SQLReport',5,'Password da base de dados',1031510000);
INSERT INTO international VALUES (15,'DownloadManager',3,'Beschrijving',1031510000);
INSERT INTO international VALUES (560,'WebGUI',1,'Approved',1031514049);
INSERT INTO international VALUES (560,'WebGUI',4,'Aprobado',1031510000);
INSERT INTO international VALUES (560,'WebGUI',5,'Aprovado',1031510000);
INSERT INTO international VALUES (14,'DownloadManager',3,'Bestand',1031510000);
INSERT INTO international VALUES (7,'WebGUI',1,'Manage users.',1031514049);
INSERT INTO international VALUES (7,'WebGUI',4,'Configurar Usuarios',1031510000);
INSERT INTO international VALUES (7,'WebGUI',5,'Organizar utilizadores.',1031510000);
INSERT INTO international VALUES (8,'Article',1,'Link URL',1031514049);
INSERT INTO international VALUES (8,'Article',4,'Link URL',1031510000);
INSERT INTO international VALUES (8,'Article',5,'URL da hiperlink',1031510000);
INSERT INTO international VALUES (8,'EventsCalendar',1,'Recurs every',1031514049);
INSERT INTO international VALUES (8,'EventsCalendar',4,'Se repite cada',1031510000);
INSERT INTO international VALUES (8,'EventsCalendar',5,'Repetição',1031510000);
INSERT INTO international VALUES (8,'FAQ',1,'Edit F.A.Q.',1031514049);
INSERT INTO international VALUES (8,'FAQ',4,'Editar F.A.Q.',1031510000);
INSERT INTO international VALUES (8,'FAQ',5,'Modificar perguntas mais frequentes',1031510000);
INSERT INTO international VALUES (12,'DownloadManager',3,'Weet u zeker dat u deze download wilt verwijderen?',1031510000);
INSERT INTO international VALUES (8,'LinkList',1,'URL',1031514049);
INSERT INTO international VALUES (8,'LinkList',4,'URL',1031510000);
INSERT INTO international VALUES (8,'LinkList',5,'URL',1031510000);
INSERT INTO international VALUES (12,'UserSubmission',2,'(Bitte\nausklicken, wenn Ihr Beitrag in HTML geschrieben ist)',1031510000);
INSERT INTO international VALUES (8,'MessageBoard',1,'Date:',1031514049);
INSERT INTO international VALUES (8,'MessageBoard',4,'Fecha:',1031510000);
INSERT INTO international VALUES (8,'MessageBoard',5,'Data:',1031510000);
INSERT INTO international VALUES (11,'DownloadManager',3,'Nieuwe download toevoegen',1031510000);
INSERT INTO international VALUES (8,'Poll',1,'(Enter one answer per line. No more than 20.)',1031514049);
INSERT INTO international VALUES (8,'Poll',4,'(Ingrese una por línea. No más de 20)',1031510000);
INSERT INTO international VALUES (8,'Poll',5,'(Introduza uma resposta por linha. Não passe das 20.)',1031510000);
INSERT INTO international VALUES (10,'DownloadManager',3,'Bewerk Download',1031510000);
INSERT INTO international VALUES (8,'SiteMap',1,'Line Spacing',1031514049);
INSERT INTO international VALUES (8,'SiteMap',5,'Espaçamento de linha',1031510000);
INSERT INTO international VALUES (8,'SQLReport',1,'Edit SQL Report',1031514049);
INSERT INTO international VALUES (8,'SQLReport',4,'Editar Reporte SQL',1031510000);
INSERT INTO international VALUES (8,'SQLReport',5,'Modificar o relaório SQL',1031510000);
INSERT INTO international VALUES (9,'DownloadManager',3,'Bewerk download Manager',1031510000);
INSERT INTO international VALUES (561,'WebGUI',1,'Denied',1031514049);
INSERT INTO international VALUES (561,'WebGUI',4,'Denegado',1031510000);
INSERT INTO international VALUES (561,'WebGUI',5,'Negado',1031510000);
INSERT INTO international VALUES (8,'WebGUI',1,'View page not found.',1031514049);
INSERT INTO international VALUES (8,'WebGUI',4,'Ver Página No Encontrada',1031510000);
INSERT INTO international VALUES (8,'WebGUI',5,'Ver página não encontrada.',1031510000);
INSERT INTO international VALUES (12,'WebGUI',2,'Administrationsmodus abschalten',1031510000);
INSERT INTO international VALUES (8,'DownloadManager',3,'Korte Omschrijving',1031510000);
INSERT INTO international VALUES (9,'Article',1,'Attachment',1031514049);
INSERT INTO international VALUES (9,'Article',4,'Adjuntar',1031510000);
INSERT INTO international VALUES (9,'Article',5,'Anexar',1031510000);
INSERT INTO international VALUES (9,'EventsCalendar',1,'until',1031514049);
INSERT INTO international VALUES (9,'EventsCalendar',4,'hasta',1031510000);
INSERT INTO international VALUES (9,'EventsCalendar',5,'até',1031510000);
INSERT INTO international VALUES (13,'Article',2,'Löschen',1031510000);
INSERT INTO international VALUES (7,'DownloadManager',3,'Groep om te downloaden',1031510000);
INSERT INTO international VALUES (9,'FAQ',1,'Add a new question.',1031514049);
INSERT INTO international VALUES (9,'FAQ',4,'Agregar nueva pregunta.',1031510000);
INSERT INTO international VALUES (9,'FAQ',5,'Adicionar nova questão.',1031510000);
INSERT INTO international VALUES (12,'Product',1,'Are you certain you wish to delete this file?',1031514049);
INSERT INTO international VALUES (6,'DownloadManager',3,'Download bestand',1031510000);
INSERT INTO international VALUES (9,'LinkList',1,'Are you certain that you want to delete this link?',1031514049);
INSERT INTO international VALUES (9,'LinkList',4,'Está seguro de querer eliminar éste enlace?',1031510000);
INSERT INTO international VALUES (9,'LinkList',5,'Tem a certeza que quer apagar esta hiperlink?',1031510000);
INSERT INTO international VALUES (9,'MessageBoard',1,'Message ID:',1031514049);
INSERT INTO international VALUES (9,'MessageBoard',4,'ID del mensage:',1031510000);
INSERT INTO international VALUES (9,'MessageBoard',5,'ID da mensagem:',1031510000);
INSERT INTO international VALUES (5,'DownloadManager',3,'Bestand Titel',1031510000);
INSERT INTO international VALUES (9,'Poll',1,'Edit Poll',1031514049);
INSERT INTO international VALUES (9,'Poll',4,'Editar Encuesta',1031510000);
INSERT INTO international VALUES (9,'Poll',5,'Modificar sondagem',1031510000);
INSERT INTO international VALUES (3,'DownloadManager',3,'Verder gaan met bestand toevoegen?',1031510000);
INSERT INTO international VALUES (9,'SQLReport',1,'<b>Debug:</b> Error: The DSN specified is of an improper format.',1031514049);
INSERT INTO international VALUES (9,'SQLReport',4,'Error: El DSN especificado está en un formato incorrecto.',1031510000);
INSERT INTO international VALUES (9,'SQLReport',5,'Erro: O DSN especificado tem um formato impróprio.',1031510000);
INSERT INTO international VALUES (13,'EventsCalendar',2,'Veranstaltung bearbeiten',1031510000);
INSERT INTO international VALUES (562,'WebGUI',1,'Pending',1031514049);
INSERT INTO international VALUES (562,'WebGUI',4,'Pendiente',1031510000);
INSERT INTO international VALUES (562,'WebGUI',5,'Pendente',1031510000);
INSERT INTO international VALUES (1,'DownloadManager',3,'Download Manager',1031510000);
INSERT INTO international VALUES (9,'WebGUI',1,'View clipboard.',1031514049);
INSERT INTO international VALUES (9,'WebGUI',4,'Ver Portapapeles',1031510000);
INSERT INTO international VALUES (9,'WebGUI',5,'Ver o clipboard.',1031510000);
INSERT INTO international VALUES (10,'Article',1,'Convert carriage returns?',1031514049);
INSERT INTO international VALUES (10,'Article',4,'Convertir saltos de carro?',1031510000);
INSERT INTO international VALUES (10,'Article',5,'Converter o caracter de retorno (CR) ?',1031510000);
INSERT INTO international VALUES (13,'LinkList',2,'Neuen Link\nhinzufügen',1031510000);
INSERT INTO international VALUES (577,'WebGUI',2,'Antwort\nschicken',1031510000);
INSERT INTO international VALUES (28,'Article',3,'Bekijk reacties',1031510000);
INSERT INTO international VALUES (10,'FAQ',1,'Edit Question',1031514049);
INSERT INTO international VALUES (10,'FAQ',4,'Editar Pregunta',1031510000);
INSERT INTO international VALUES (10,'FAQ',5,'Modificar questão',1031510000);
INSERT INTO international VALUES (10,'LinkList',1,'Edit Link List',1031514049);
INSERT INTO international VALUES (10,'LinkList',4,'Editar Lista de Enlaces',1031510000);
INSERT INTO international VALUES (10,'LinkList',5,'Modificar lista de hiperlinks',1031510000);
INSERT INTO international VALUES (394,'WebGUI',2,'Grafiken\nverwalten',1031510000);
INSERT INTO international VALUES (6,'Article',10,'Billede',1031510000);
INSERT INTO international VALUES (5,'Article',10,'Brødtekst',1031510000);
INSERT INTO international VALUES (4,'Article',10,'Til dato',1031510000);
INSERT INTO international VALUES (3,'Article',10,'Fra dato',1031510000);
INSERT INTO international VALUES (27,'Article',3,'Terug naar artikel',1031510000);
INSERT INTO international VALUES (10,'Poll',1,'Reset votes.',1031514049);
INSERT INTO international VALUES (10,'Poll',5,'Reinicializar os votos.',1031510000);
INSERT INTO international VALUES (23,'Article',3,'Datum',1031510000);
INSERT INTO international VALUES (24,'Article',3,'Post reactie',1031510000);
INSERT INTO international VALUES (10,'SQLReport',1,'<b>Debug:</b> Error: The SQL specified is of an improper format.',1031514049);
INSERT INTO international VALUES (10,'SQLReport',4,'Error: El SQL especificado está en un formato incorrecto.',1031510000);
INSERT INTO international VALUES (10,'SQLReport',5,'Erro: O SQL especificado tem um formato impróprio.',1031510000);
INSERT INTO international VALUES (22,'Article',3,'Auteur',1031510000);
INSERT INTO international VALUES (563,'WebGUI',1,'Default Status',1031514049);
INSERT INTO international VALUES (563,'WebGUI',4,'Estado por defecto',1031510000);
INSERT INTO international VALUES (563,'WebGUI',5,'Estado por defeito',1031510000);
INSERT INTO international VALUES (18,'Article',3,'Discussie toelaten?',1031510000);
INSERT INTO international VALUES (10,'WebGUI',1,'Manage trash.',1031514049);
INSERT INTO international VALUES (10,'WebGUI',4,'Ver Papelera',1031510000);
INSERT INTO international VALUES (10,'WebGUI',5,'Ver o caixote do lixo.',1031510000);
INSERT INTO international VALUES (17,'Article',3,'Centreren',1031510000);
INSERT INTO international VALUES (11,'Article',1,'(Select \"Yes\" only if you aren\'t adding &lt;br&gt; manually.)',1031514049);
INSERT INTO international VALUES (11,'Article',4,'(marque si no está agregando &lt;br&gt; manualmente.)',1031510000);
INSERT INTO international VALUES (11,'Article',5,'(escolher se não adicionar &lt;br&gt; manualmente.)',1031510000);
INSERT INTO international VALUES (392,'WebGUI',2,'Sind Sie sicher,\ndass Sie diese Grafik löschen wollen?',1031510000);
INSERT INTO international VALUES (58,'Product',1,'Edit Product Template',1031514049);
INSERT INTO international VALUES (707,'WebGUI',1,'Show debugging?',1031514049);
INSERT INTO international VALUES (78,'EventsCalendar',1,'Don\'t delete anything, I made a mistake.',1031514049);
INSERT INTO international VALUES (393,'WebGUI',2,'Grafiken\nverwalten',1031510000);
INSERT INTO international VALUES (2,'EventsCalendar',6,'Händelse Kalender',1031510000);
INSERT INTO international VALUES (2,'Article',6,'Lägg till artikel',1031510000);
INSERT INTO international VALUES (1,'WebGUI',6,'Lägg till innehåll....',1031510000);
INSERT INTO international VALUES (1,'UserSubmission',6,'Vem kan validera?',1031510000);
INSERT INTO international VALUES (16,'Article',3,'links',1031510000);
INSERT INTO international VALUES (11,'MessageBoard',1,'Back To Message List',1031514049);
INSERT INTO international VALUES (11,'MessageBoard',4,'Volver a la Lista de Mensages',1031510000);
INSERT INTO international VALUES (11,'MessageBoard',5,'Voltar á lista de mensagens',1031510000);
INSERT INTO international VALUES (15,'Article',3,'Rechts',1031510000);
INSERT INTO international VALUES (11,'SQLReport',1,'<b>Debug:</b> Error: There was a problem with the query.',1031514049);
INSERT INTO international VALUES (11,'SQLReport',4,'Error: Hay un problema con la consulta.',1031510000);
INSERT INTO international VALUES (11,'SQLReport',5,'Erro: Houve um problema com a query.',1031510000);
INSERT INTO international VALUES (391,'WebGUI',2,'Anhang löschen',1031510000);
INSERT INTO international VALUES (1,'SQLReport',6,'SQL Rapport',1031510000);
INSERT INTO international VALUES (1,'SiteMap',6,'Läggtill Site Karta',1031510000);
INSERT INTO international VALUES (1,'Poll',6,'Fråga',1031510000);
INSERT INTO international VALUES (14,'Article',3,'Plaatje uitlijnen',1031510000);
INSERT INTO international VALUES (11,'WebGUI',1,'Empy trash.',1031514049);
INSERT INTO international VALUES (11,'WebGUI',4,'Vaciar Papelera',1031510000);
INSERT INTO international VALUES (11,'WebGUI',5,'Esvaziar o caixote do lixo.',1031510000);
INSERT INTO international VALUES (355,'WebGUI',3,'Standaard',1031510000);
INSERT INTO international VALUES (12,'Article',1,'Edit Article',1031514049);
INSERT INTO international VALUES (12,'Article',4,'Editar Artículo',1031510000);
INSERT INTO international VALUES (12,'Article',5,'Modificar artigo',1031510000);
INSERT INTO international VALUES (354,'WebGUI',3,'Bekijk berichten log.',1031510000);
INSERT INTO international VALUES (12,'EventsCalendar',1,'Edit Events Calendar',1031514049);
INSERT INTO international VALUES (12,'EventsCalendar',4,'Editar Calendario de Eventos',1031510000);
INSERT INTO international VALUES (12,'EventsCalendar',5,'Modificar calendário de eventos',1031510000);
INSERT INTO international VALUES (12,'LinkList',1,'Edit Link',1031514049);
INSERT INTO international VALUES (12,'LinkList',4,'Editar Enlace',1031510000);
INSERT INTO international VALUES (12,'LinkList',5,'Modificar hiperlink',1031510000);
INSERT INTO international VALUES (353,'WebGUI',3,'U heeft nu geen berichten log toevoegingen.',1031510000);
INSERT INTO international VALUES (12,'MessageBoard',1,'Edit Message',1031514049);
INSERT INTO international VALUES (12,'MessageBoard',4,'Editar mensage',1031510000);
INSERT INTO international VALUES (12,'MessageBoard',5,'Modificar mensagem',1031510000);
INSERT INTO international VALUES (390,'WebGUI',2,'Grafik anzeigen\n...',1031510000);
INSERT INTO international VALUES (352,'WebGUI',3,'Datum van toevoeging',1031510000);
INSERT INTO international VALUES (12,'SQLReport',1,'<b>Debug:</b> Error: Could not connect to the database.',1031514049);
INSERT INTO international VALUES (12,'SQLReport',4,'Error: No se puede conectar a la base de datos.',1031510000);
INSERT INTO international VALUES (12,'SQLReport',5,'Erro: Não é possível ligar á base de dados.',1031510000);
INSERT INTO international VALUES (389,'WebGUI',2,'Grafik Id',1031510000);
INSERT INTO international VALUES (350,'WebGUI',3,'Klaar',1031510000);
INSERT INTO international VALUES (351,'WebGUI',3,'Bericht',1031510000);
INSERT INTO international VALUES (12,'UserSubmission',1,'(Uncheck if you\'re writing an HTML submission.)',1031514049);
INSERT INTO international VALUES (12,'UserSubmission',4,'(desmarque si está escribiendo la contribución en HTML.)',1031510000);
INSERT INTO international VALUES (12,'UserSubmission',5,'(deixar em branco se a submissão for em HTML.)',1031510000);
INSERT INTO international VALUES (388,'WebGUI',2,'Upload Datum',1031510000);
INSERT INTO international VALUES (12,'WebGUI',1,'Turn admin off.',1031514049);
INSERT INTO international VALUES (12,'WebGUI',4,'Apagar Admin',1031510000);
INSERT INTO international VALUES (12,'WebGUI',5,'Desligar o modo administrativo.',1031510000);
INSERT INTO international VALUES (349,'WebGUI',3,'Laatst beschikbare versie',1031510000);
INSERT INTO international VALUES (13,'Article',1,'Delete',1031514049);
INSERT INTO international VALUES (13,'Article',4,'Eliminar',1031510000);
INSERT INTO international VALUES (13,'Article',5,'Apagar',1031510000);
INSERT INTO international VALUES (348,'WebGUI',3,'Naam',1031510000);
INSERT INTO international VALUES (13,'EventsCalendar',1,'Edit Event',1031514049);
INSERT INTO international VALUES (13,'EventsCalendar',4,'Editar Evento',1031510000);
INSERT INTO international VALUES (13,'EventsCalendar',5,'Modificar evento',1031510000);
INSERT INTO international VALUES (387,'WebGUI',2,'Zur Verfügung\ngestellt von',1031510000);
INSERT INTO international VALUES (13,'LinkList',1,'Add a new link.',1031514049);
INSERT INTO international VALUES (13,'LinkList',4,'Agregar nuevo Enlace',1031510000);
INSERT INTO international VALUES (13,'LinkList',5,'Adicionar nova hiperlink.',1031510000);
INSERT INTO international VALUES (385,'WebGUI',2,'Parameter',1031510000);
INSERT INTO international VALUES (347,'WebGUI',3,'Bekijk profiel van',1031510000);
INSERT INTO international VALUES (577,'WebGUI',1,'Post Reply',1031514049);
INSERT INTO international VALUES (577,'WebGUI',4,'Responder',1031510000);
INSERT INTO international VALUES (577,'WebGUI',5,'Responder',1031510000);
INSERT INTO international VALUES (13,'UserSubmission',1,'Date Submitted',1031514049);
INSERT INTO international VALUES (13,'UserSubmission',4,'Fecha Contribución',1031510000);
INSERT INTO international VALUES (13,'UserSubmission',5,'Data de submissão',1031510000);
INSERT INTO international VALUES (386,'WebGUI',2,'Bild\nbearbeiten',1031510000);
INSERT INTO international VALUES (13,'WebGUI',1,'View help index.',1031514049);
INSERT INTO international VALUES (13,'WebGUI',4,'Ver índice de Ayuda',1031510000);
INSERT INTO international VALUES (13,'WebGUI',5,'Ver o indice da ajuda.',1031510000);
INSERT INTO international VALUES (14,'Article',1,'Align Image',1031514049);
INSERT INTO international VALUES (384,'WebGUI',2,'Datei',1031510000);
INSERT INTO international VALUES (516,'WebGUI',1,'Turn Admin On!',1031514049);
INSERT INTO international VALUES (517,'WebGUI',1,'Turn Admin Off!',1031514049);
INSERT INTO international VALUES (515,'WebGUI',1,'Add edit stamp to posts?',1031514049);
INSERT INTO international VALUES (383,'WebGUI',2,'Name',1031510000);
INSERT INTO international VALUES (14,'UserSubmission',1,'Status',1031514049);
INSERT INTO international VALUES (14,'UserSubmission',4,'Estado',1031510000);
INSERT INTO international VALUES (14,'UserSubmission',5,'Estado',1031510000);
INSERT INTO international VALUES (346,'WebGUI',3,'Deze gebruiker in geen lid meer van onze site. We hebben geen informatie meer over deze gebruiker.',1031510000);
INSERT INTO international VALUES (14,'WebGUI',1,'View pending submissions.',1031514049);
INSERT INTO international VALUES (14,'WebGUI',4,'Ver contribuciones pendientes.',1031510000);
INSERT INTO international VALUES (14,'WebGUI',5,'Ver submissões pendentes.',1031510000);
INSERT INTO international VALUES (345,'WebGUI',3,'Geen lid',1031510000);
INSERT INTO international VALUES (15,'MessageBoard',1,'Author',1031514049);
INSERT INTO international VALUES (15,'MessageBoard',4,'Autor',1031510000);
INSERT INTO international VALUES (15,'MessageBoard',5,'Autor',1031510000);
INSERT INTO international VALUES (343,'WebGUI',3,'Bekijk profiel.',1031510000);
INSERT INTO international VALUES (15,'UserSubmission',1,'Edit/Delete',1031514049);
INSERT INTO international VALUES (15,'UserSubmission',4,'Editar/Eliminar',1031510000);
INSERT INTO international VALUES (15,'UserSubmission',5,'Modificar/Apagar',1031510000);
INSERT INTO international VALUES (15,'WebGUI',1,'January',1031514049);
INSERT INTO international VALUES (15,'WebGUI',4,'Enero',1031510000);
INSERT INTO international VALUES (15,'WebGUI',5,'Janeiro',1031510000);
INSERT INTO international VALUES (379,'WebGUI',2,'Gruppen ID',1031510000);
INSERT INTO international VALUES (342,'WebGUI',3,'Bewerk account informatie.',1031510000);
INSERT INTO international VALUES (16,'MessageBoard',1,'Date',1031514049);
INSERT INTO international VALUES (16,'MessageBoard',4,'Fecha',1031510000);
INSERT INTO international VALUES (16,'MessageBoard',5,'Data',1031510000);
INSERT INTO international VALUES (341,'WebGUI',3,'Bewerk profiel.',1031510000);
INSERT INTO international VALUES (16,'UserSubmission',1,'Untitled',1031514049);
INSERT INTO international VALUES (16,'UserSubmission',4,'Sin título',1031510000);
INSERT INTO international VALUES (16,'UserSubmission',5,'Sem titulo',1031510000);
INSERT INTO international VALUES (380,'WebGUI',2,'Stil ID',1031510000);
INSERT INTO international VALUES (340,'WebGUI',3,'Vrouw',1031510000);
INSERT INTO international VALUES (16,'WebGUI',1,'February',1031514049);
INSERT INTO international VALUES (16,'WebGUI',4,'Febrero',1031510000);
INSERT INTO international VALUES (16,'WebGUI',5,'Fevereiro',1031510000);
INSERT INTO international VALUES (339,'WebGUI',3,'Man',1031510000);
INSERT INTO international VALUES (17,'MessageBoard',1,'Post New Message',1031514049);
INSERT INTO international VALUES (17,'MessageBoard',4,'Mandar Nuevo Mensage',1031510000);
INSERT INTO international VALUES (17,'MessageBoard',5,'Colocar nova mensagem',1031510000);
INSERT INTO international VALUES (338,'WebGUI',3,'Bewerk profiel',1031510000);
INSERT INTO international VALUES (17,'UserSubmission',1,'Are you certain you wish to delete this submission?',1031514049);
INSERT INTO international VALUES (17,'UserSubmission',4,'Está seguro de querer eliminar ésta contribución?',1031510000);
INSERT INTO international VALUES (17,'UserSubmission',5,'Tem a certeza que quer apagar esta submissão?',1031510000);
INSERT INTO international VALUES (337,'WebGUI',3,'Home pagina URL',1031510000);
INSERT INTO international VALUES (17,'WebGUI',1,'March',1031514049);
INSERT INTO international VALUES (17,'WebGUI',4,'Marzo',1031510000);
INSERT INTO international VALUES (17,'WebGUI',5,'Março',1031510000);
INSERT INTO international VALUES (336,'WebGUI',3,'Geboortedatum',1031510000);
INSERT INTO international VALUES (18,'MessageBoard',1,'Thread Started',1031514049);
INSERT INTO international VALUES (18,'MessageBoard',4,'Inicio',1031510000);
INSERT INTO international VALUES (18,'MessageBoard',5,'Inicial',1031510000);
INSERT INTO international VALUES (59,'UserSubmission',1,'Next Submission',1031514049);
INSERT INTO international VALUES (335,'WebGUI',3,'Sexe',1031510000);
INSERT INTO international VALUES (18,'UserSubmission',1,'Edit User Submission System',1031514049);
INSERT INTO international VALUES (18,'UserSubmission',4,'Editar Sistema de Contribución de Usuarios',1031510000);
INSERT INTO international VALUES (18,'UserSubmission',5,'Modificar sistema de submissão do utilizador',1031510000);
INSERT INTO international VALUES (334,'WebGUI',3,'Werk telefoon',1031510000);
INSERT INTO international VALUES (18,'WebGUI',1,'April',1031514049);
INSERT INTO international VALUES (18,'WebGUI',4,'Abril',1031510000);
INSERT INTO international VALUES (18,'WebGUI',5,'Abril',1031510000);
INSERT INTO international VALUES (333,'WebGUI',3,'Werk land',1031510000);
INSERT INTO international VALUES (19,'MessageBoard',1,'Replies',1031514049);
INSERT INTO international VALUES (19,'MessageBoard',4,'Respuestas',1031510000);
INSERT INTO international VALUES (19,'MessageBoard',5,'Respostas',1031510000);
INSERT INTO international VALUES (19,'UserSubmission',1,'Edit Submission',1031514049);
INSERT INTO international VALUES (19,'UserSubmission',4,'Editar Contribución',1031510000);
INSERT INTO international VALUES (19,'UserSubmission',5,'Modificar submissão',1031510000);
INSERT INTO international VALUES (332,'WebGUI',3,'Werk postcode',1031510000);
INSERT INTO international VALUES (19,'WebGUI',1,'May',1031514049);
INSERT INTO international VALUES (19,'WebGUI',4,'Mayo',1031510000);
INSERT INTO international VALUES (19,'WebGUI',5,'Maio',1031510000);
INSERT INTO international VALUES (331,'WebGUI',3,'Werk staat',1031510000);
INSERT INTO international VALUES (20,'MessageBoard',1,'Last Reply',1031514049);
INSERT INTO international VALUES (20,'MessageBoard',4,'Última respuesta',1031510000);
INSERT INTO international VALUES (20,'MessageBoard',5,'Ultima resposta',1031510000);
INSERT INTO international VALUES (20,'UserSubmission',1,'Post New Submission',1031514049);
INSERT INTO international VALUES (20,'UserSubmission',4,'Nueva Contribución',1031510000);
INSERT INTO international VALUES (20,'UserSubmission',5,'Colocar nova submissão',1031510000);
INSERT INTO international VALUES (330,'WebGUI',3,'Werk stad',1031510000);
INSERT INTO international VALUES (20,'WebGUI',1,'June',1031514049);
INSERT INTO international VALUES (20,'WebGUI',4,'Junio',1031510000);
INSERT INTO international VALUES (20,'WebGUI',5,'Junho',1031510000);
INSERT INTO international VALUES (21,'UserSubmission',1,'Submitted By',1031514049);
INSERT INTO international VALUES (21,'UserSubmission',4,'Contribuida por',1031510000);
INSERT INTO international VALUES (21,'UserSubmission',5,'Submetido por',1031510000);
INSERT INTO international VALUES (329,'WebGUI',3,'Werk adres',1031510000);
INSERT INTO international VALUES (21,'WebGUI',1,'July',1031514049);
INSERT INTO international VALUES (21,'WebGUI',4,'Julio',1031510000);
INSERT INTO international VALUES (21,'WebGUI',5,'Julho',1031510000);
INSERT INTO international VALUES (22,'UserSubmission',1,'Submitted By:',1031514049);
INSERT INTO international VALUES (22,'UserSubmission',4,'Contribuida por:',1031510000);
INSERT INTO international VALUES (22,'UserSubmission',5,'Submetido por:',1031510000);
INSERT INTO international VALUES (328,'WebGUI',3,'Thuis telefoon',1031510000);
INSERT INTO international VALUES (22,'WebGUI',1,'August',1031514049);
INSERT INTO international VALUES (22,'WebGUI',4,'Agosto',1031510000);
INSERT INTO international VALUES (22,'WebGUI',5,'Agosto',1031510000);
INSERT INTO international VALUES (23,'UserSubmission',1,'Date Submitted:',1031514049);
INSERT INTO international VALUES (23,'UserSubmission',4,'Fecha Contribución:',1031510000);
INSERT INTO international VALUES (23,'UserSubmission',5,'Data de submissão:',1031510000);
INSERT INTO international VALUES (327,'WebGUI',3,'Thuis land',1031510000);
INSERT INTO international VALUES (23,'WebGUI',1,'September',1031514049);
INSERT INTO international VALUES (23,'WebGUI',4,'Septiembre',1031510000);
INSERT INTO international VALUES (23,'WebGUI',5,'Setembro',1031510000);
INSERT INTO international VALUES (572,'WebGUI',1,'Approve',1031514049);
INSERT INTO international VALUES (572,'WebGUI',4,'Aprobar',1031510000);
INSERT INTO international VALUES (572,'WebGUI',5,'Aprovar',1031510000);
INSERT INTO international VALUES (326,'WebGUI',3,'Thuis postcode',1031510000);
INSERT INTO international VALUES (24,'WebGUI',1,'October',1031514049);
INSERT INTO international VALUES (24,'WebGUI',4,'Octubre',1031510000);
INSERT INTO international VALUES (24,'WebGUI',5,'Outubro',1031510000);
INSERT INTO international VALUES (381,'WebGUI',2,'WebGUI hat eine\nverstümmelte Anfrage erhalten und kann nicht weitermachen. Üblicherweise\nwird das durch Sonderzeichen verursacht. Nutzen Sie bitte den \"Zurück\"\nButton Ihres Browsers und versuchen Sie es noch einmal.',1031510000);
INSERT INTO international VALUES (573,'WebGUI',1,'Leave Pending',1031514049);
INSERT INTO international VALUES (573,'WebGUI',4,'Dejan pendiente',1031510000);
INSERT INTO international VALUES (573,'WebGUI',5,'Deixar pendente',1031510000);
INSERT INTO international VALUES (325,'WebGUI',3,'Thuis staat',1031510000);
INSERT INTO international VALUES (25,'WebGUI',1,'November',1031514049);
INSERT INTO international VALUES (25,'WebGUI',4,'Noviembre',1031510000);
INSERT INTO international VALUES (25,'WebGUI',5,'Novembro',1031510000);
INSERT INTO international VALUES (574,'WebGUI',1,'Deny',1031514049);
INSERT INTO international VALUES (574,'WebGUI',4,'Denegar',1031510000);
INSERT INTO international VALUES (574,'WebGUI',5,'Negar',1031510000);
INSERT INTO international VALUES (378,'WebGUI',2,'Benutzer ID',1031510000);
INSERT INTO international VALUES (324,'WebGUI',3,'Thuis plaats',1031510000);
INSERT INTO international VALUES (26,'WebGUI',1,'December',1031514049);
INSERT INTO international VALUES (26,'WebGUI',4,'Diciembre',1031510000);
INSERT INTO international VALUES (26,'WebGUI',5,'Dezembro',1031510000);
INSERT INTO international VALUES (323,'WebGUI',3,'Thuis adres',1031510000);
INSERT INTO international VALUES (27,'UserSubmission',1,'Edit',1031514049);
INSERT INTO international VALUES (27,'UserSubmission',4,'Editar',1031510000);
INSERT INTO international VALUES (27,'UserSubmission',5,'Modificar',1031510000);
INSERT INTO international VALUES (322,'WebGUI',3,'Pager',1031510000);
INSERT INTO international VALUES (27,'WebGUI',1,'Sunday',1031514049);
INSERT INTO international VALUES (27,'WebGUI',4,'Domingo',1031510000);
INSERT INTO international VALUES (27,'WebGUI',5,'Domingo',1031510000);
INSERT INTO international VALUES (321,'WebGUI',3,'Mobiel nummer',1031510000);
INSERT INTO international VALUES (28,'UserSubmission',1,'Return To Submissions List',1031514049);
INSERT INTO international VALUES (28,'UserSubmission',4,'Regresar a lista de contribuciones',1031510000);
INSERT INTO international VALUES (28,'UserSubmission',5,'Voltar á lista de submissões',1031510000);
INSERT INTO international VALUES (376,'WebGUI',2,'Paket',1031510000);
INSERT INTO international VALUES (28,'WebGUI',1,'Monday',1031514049);
INSERT INTO international VALUES (28,'WebGUI',4,'Lunes',1031510000);
INSERT INTO international VALUES (28,'WebGUI',5,'Segunda',1031510000);
INSERT INTO international VALUES (29,'UserSubmission',1,'User Submission System',1031514049);
INSERT INTO international VALUES (29,'UserSubmission',4,'Sistema de Contribución de Usuarios',1031510000);
INSERT INTO international VALUES (29,'UserSubmission',5,'Sistema de submissão do utilizador',1031510000);
INSERT INTO international VALUES (320,'WebGUI',3,'\"<a href=\"\"http://messenger.yahoo.com/\"\">Yahoo! Messenger</a> Id\"',1031510000);
INSERT INTO international VALUES (29,'WebGUI',1,'Tuesday',1031514049);
INSERT INTO international VALUES (29,'WebGUI',4,'Martes',1031510000);
INSERT INTO international VALUES (29,'WebGUI',5,'Terça',1031510000);
INSERT INTO international VALUES (1,'LinkList',6,'Indentering',1031510000);
INSERT INTO international VALUES (1,'Item',6,'Länk URL',1031510000);
INSERT INTO international VALUES (1,'FAQ',6,'Fortsätt med att lägga till en fråga?',1031510000);
INSERT INTO international VALUES (1,'ExtraColumn',6,'Extra Column',1031510000);
INSERT INTO international VALUES (30,'WebGUI',1,'Wednesday',1031514049);
INSERT INTO international VALUES (30,'WebGUI',4,'Miércoles',1031510000);
INSERT INTO international VALUES (30,'WebGUI',5,'Quarta',1031510000);
INSERT INTO international VALUES (31,'WebGUI',1,'Thursday',1031514049);
INSERT INTO international VALUES (31,'WebGUI',4,'Jueves',1031510000);
INSERT INTO international VALUES (31,'WebGUI',5,'Quinta',1031510000);
INSERT INTO international VALUES (377,'WebGUI',2,'Von Ihren (Paket)\n-Administratoren wurden keine Pakete bereitgestellt.',1031510000);
INSERT INTO international VALUES (32,'WebGUI',1,'Friday',1031514049);
INSERT INTO international VALUES (32,'WebGUI',4,'Viernes',1031510000);
INSERT INTO international VALUES (32,'WebGUI',5,'Sexta',1031510000);
INSERT INTO international VALUES (319,'WebGUI',3,'\"<a href=\"\"http://messenger.msn.com/\"\">MSN Messenger</a> Id\"',1031510000);
INSERT INTO international VALUES (33,'WebGUI',1,'Saturday',1031514049);
INSERT INTO international VALUES (33,'WebGUI',4,'Sabado',1031510000);
INSERT INTO international VALUES (33,'WebGUI',5,'Sabado',1031510000);
INSERT INTO international VALUES (34,'WebGUI',1,'set date',1031514049);
INSERT INTO international VALUES (34,'WebGUI',4,'fijar fecha',1031510000);
INSERT INTO international VALUES (34,'WebGUI',5,'acertar a data',1031510000);
INSERT INTO international VALUES (1,'MessageBoard',6,'Läggtill Meddelande Forum',1031510000);
INSERT INTO international VALUES (35,'WebGUI',1,'Administrative Function',1031514049);
INSERT INTO international VALUES (35,'WebGUI',4,'Funciones Administrativas',1031510000);
INSERT INTO international VALUES (35,'WebGUI',5,'Função administrativa',1031510000);
INSERT INTO international VALUES (317,'WebGUI',3,'\"<a href=\"\"http://www.icq.com\"\">ICQ</a> UIN\"',1031510000);
INSERT INTO international VALUES (318,'WebGUI',3,'\"<a href=\"\"http://www.aol.com/aim/homenew.adp\"\">AIM</a> Id\"',1031510000);
INSERT INTO international VALUES (36,'WebGUI',1,'You must be an administrator to perform this function. Please contact one of your administrators. The following is a list of the administrators for this system:',1031514049);
INSERT INTO international VALUES (36,'WebGUI',4,'Debe ser administrador para realizar esta tarea. Por favor contacte a uno de los administradores. La siguiente es una lista de los administradores de éste sistema:',1031510000);
INSERT INTO international VALUES (36,'WebGUI',5,'Função reservada a administradores. Fale com um dos seguintes administradores:',1031510000);
INSERT INTO international VALUES (316,'WebGUI',3,'Achternaam',1031510000);
INSERT INTO international VALUES (37,'WebGUI',1,'Permission Denied!',1031514049);
INSERT INTO international VALUES (37,'WebGUI',4,'Permiso Denegado!',1031510000);
INSERT INTO international VALUES (37,'WebGUI',5,'Permissão negada!',1031510000);
INSERT INTO international VALUES (38,'WebGUI',5,'\"Não tem privilégios para essa operação. ^a(Identifique-se na entrada); com uma conta que permita essa operação.\"',1031510000);
INSERT INTO international VALUES (404,'WebGUI',1,'First Page',1031514049);
INSERT INTO international VALUES (38,'WebGUI',4,'\"No tiene privilegios suficientes para realizar ésta operación. Por favor ^a(ingrese con una cuenta); que posea los privilegios suficientes antes de intentar ésta operación.\"',1031510000);
INSERT INTO international VALUES (314,'WebGUI',3,'Voornaam',1031510000);
INSERT INTO international VALUES (315,'WebGUI',3,'Tussenvoegsel',1031510000);
INSERT INTO international VALUES (38,'WebGUI',1,'You do not have sufficient privileges to perform this operation. Please ^a(log in with an account); that has sufficient privileges before attempting this operation.',1031514049);
INSERT INTO international VALUES (375,'WebGUI',2,'Paket auswählen,\ndas verteilt werden soll',1031510000);
INSERT INTO international VALUES (374,'WebGUI',2,'Pakete\nanschauen',1031510000);
INSERT INTO international VALUES (313,'WebGUI',3,'Sta andere informatie toe?',1031510000);
INSERT INTO international VALUES (39,'WebGUI',1,'You do not have sufficient privileges to access this page.',1031514049);
INSERT INTO international VALUES (39,'WebGUI',4,'No tiene suficientes privilegios para ingresar a ésta página.',1031510000);
INSERT INTO international VALUES (39,'WebGUI',5,'Não tem privilégios para aceder a essa página.',1031510000);
INSERT INTO international VALUES (372,'WebGUI',2,'Gruppen eines\nBenutzers bearbeiten',1031510000);
INSERT INTO international VALUES (312,'WebGUI',3,'Sta bedrijfs informatie toe?',1031510000);
INSERT INTO international VALUES (40,'WebGUI',1,'Vital Component',1031514049);
INSERT INTO international VALUES (40,'WebGUI',4,'Componente Vital',1031510000);
INSERT INTO international VALUES (40,'WebGUI',5,'Componente vital',1031510000);
INSERT INTO international VALUES (371,'WebGUI',2,'Gruppierung\nhinzufügen',1031510000);
INSERT INTO international VALUES (310,'WebGUI',3,'Sta extra contact informatie toe?',1031510000);
INSERT INTO international VALUES (311,'WebGUI',3,'Sta thuis informatie toe?',1031510000);
INSERT INTO international VALUES (41,'WebGUI',1,'You\'re attempting to remove a vital component of the WebGUI system. If you were allowed to continue WebGUI may cease to function.',1031514049);
INSERT INTO international VALUES (41,'WebGUI',4,'Esta intentando eliminar un componente vital del sistema WebGUI. Si continúa puede causar un mal funcionamiento de WebGUI.',1031510000);
INSERT INTO international VALUES (41,'WebGUI',5,'Está a tentar remover um componente vital do WebGUI. Se continuar pode haver um erro grave.',1031510000);
INSERT INTO international VALUES (42,'WebGUI',1,'Please Confirm',1031514049);
INSERT INTO international VALUES (42,'WebGUI',4,'Por favor confirme',1031510000);
INSERT INTO international VALUES (42,'WebGUI',5,'Confirma',1031510000);
INSERT INTO international VALUES (309,'WebGUI',3,'Sta echte naam toe?',1031510000);
INSERT INTO international VALUES (43,'WebGUI',1,'Are you certain that you wish to delete this content?',1031514049);
INSERT INTO international VALUES (43,'WebGUI',4,'Está seguro de querer eliminar éste contenido?',1031510000);
INSERT INTO international VALUES (43,'WebGUI',5,'Tem a certeza que quer apagar este conteudo?',1031510000);
INSERT INTO international VALUES (368,'WebGUI',2,'Diesem Benutzer\neine neue Gruppe hinzufügen.',1031510000);
INSERT INTO international VALUES (308,'WebGUI',3,'Bewerk profiel instellingen',1031510000);
INSERT INTO international VALUES (44,'WebGUI',1,'Yes, I\'m sure.',1031514049);
INSERT INTO international VALUES (44,'WebGUI',4,'Si',1031510000);
INSERT INTO international VALUES (44,'WebGUI',5,'\"Sim, tenho a certeza.\"',1031510000);
INSERT INTO international VALUES (45,'WebGUI',1,'No, I made a mistake.',1031514049);
INSERT INTO international VALUES (45,'WebGUI',4,'No',1031510000);
INSERT INTO international VALUES (45,'WebGUI',5,'\"Não, enganei-me.\"',1031510000);
INSERT INTO international VALUES (46,'WebGUI',1,'My Account',1031514049);
INSERT INTO international VALUES (46,'WebGUI',4,'Mi Cuenta',1031510000);
INSERT INTO international VALUES (46,'WebGUI',5,'Minha Conta',1031510000);
INSERT INTO international VALUES (307,'WebGUI',3,'Gebruik standaard metag tags?',1031510000);
INSERT INTO international VALUES (47,'WebGUI',1,'Home',1031514049);
INSERT INTO international VALUES (47,'WebGUI',4,'Home',1031510000);
INSERT INTO international VALUES (47,'WebGUI',5,'Inicio',1031510000);
INSERT INTO international VALUES (48,'WebGUI',1,'Hello',1031514049);
INSERT INTO international VALUES (48,'WebGUI',4,'Hola',1031510000);
INSERT INTO international VALUES (48,'WebGUI',5,'Ola',1031510000);
INSERT INTO international VALUES (304,'WebGUI',3,'Taal',1031510000);
INSERT INTO international VALUES (306,'WebGUI',3,'Bind gebruikersnaam',1031510000);
INSERT INTO international VALUES (49,'WebGUI',1,'Click <a href=\"^\\;?op=logout\">here</a> to log out.',1031514049);
INSERT INTO international VALUES (49,'WebGUI',4,'Click <a href=\"^\\;?op=logout\">aquí</a> para salir.',1031510000);
INSERT INTO international VALUES (49,'WebGUI',5,'Clique <a href=\"^\\;?op=logout\">aqui</a> para sair.',1031510000);
INSERT INTO international VALUES (245,'WebGUI',3,'Datum',1031510000);
INSERT INTO international VALUES (50,'WebGUI',1,'Username',1031514049);
INSERT INTO international VALUES (50,'WebGUI',4,'Nombre usuario',1031510000);
INSERT INTO international VALUES (50,'WebGUI',5,'Username',1031510000);
INSERT INTO international VALUES (51,'WebGUI',1,'Password',1031514049);
INSERT INTO international VALUES (51,'WebGUI',4,'Password',1031510000);
INSERT INTO international VALUES (51,'WebGUI',5,'Password',1031510000);
INSERT INTO international VALUES (244,'WebGUI',3,'Afzender',1031510000);
INSERT INTO international VALUES (52,'WebGUI',1,'login',1031514049);
INSERT INTO international VALUES (52,'WebGUI',4,'ingresar',1031510000);
INSERT INTO international VALUES (52,'WebGUI',5,'entrar',1031510000);
INSERT INTO international VALUES (367,'WebGUI',2,'verfällt nach',1031510000);
INSERT INTO international VALUES (370,'WebGUI',2,'Gruppierung\nbearbeiten',1031510000);
INSERT INTO international VALUES (369,'WebGUI',2,'Verfallsdatum',1031510000);
INSERT INTO international VALUES (240,'WebGUI',3,'Bericht ID:',1031510000);
INSERT INTO international VALUES (53,'WebGUI',1,'Make Page Printable',1031514049);
INSERT INTO international VALUES (53,'WebGUI',4,'Hacer página imprimible',1031510000);
INSERT INTO international VALUES (53,'WebGUI',5,'Versão para impressão',1031510000);
INSERT INTO international VALUES (239,'WebGUI',3,'Datum:',1031510000);
INSERT INTO international VALUES (54,'WebGUI',1,'Create Account',1031514049);
INSERT INTO international VALUES (54,'WebGUI',4,'Crear Cuenta',1031510000);
INSERT INTO international VALUES (54,'WebGUI',5,'Criar conta',1031510000);
INSERT INTO international VALUES (238,'WebGUI',3,'Naam:',1031510000);
INSERT INTO international VALUES (55,'WebGUI',1,'Password (confirm)',1031514049);
INSERT INTO international VALUES (55,'WebGUI',4,'Password (confirmar)',1031510000);
INSERT INTO international VALUES (55,'WebGUI',5,'Password (confirmar)',1031510000);
INSERT INTO international VALUES (237,'WebGUI',3,'Onderwerp:',1031510000);
INSERT INTO international VALUES (56,'WebGUI',1,'Email Address',1031514049);
INSERT INTO international VALUES (56,'WebGUI',4,'Dirección de e-mail',1031510000);
INSERT INTO international VALUES (56,'WebGUI',5,'Endereço de e-mail',1031510000);
INSERT INTO international VALUES (233,'WebGUI',3,'(einde)',1031510000);
INSERT INTO international VALUES (234,'WebGUI',3,'Bezig met antwoord posten',1031510000);
INSERT INTO international VALUES (57,'WebGUI',1,'This is only necessary if you wish to use features that require Email.',1031514049);
INSERT INTO international VALUES (57,'WebGUI',4,'Solo es necesaria si desea usar opciones que requieren e-mail.',1031510000);
INSERT INTO international VALUES (57,'WebGUI',5,'Apenas é necessário se pretender utilizar as funcionalidade que envolvam e-mail.',1031510000);
INSERT INTO international VALUES (232,'WebGUI',3,'Geen onderwerp',1031510000);
INSERT INTO international VALUES (58,'WebGUI',1,'I already have an account.',1031514049);
INSERT INTO international VALUES (58,'WebGUI',4,'Ya tengo una cuenta!',1031510000);
INSERT INTO international VALUES (58,'WebGUI',5,'Já tenho uma conta.',1031510000);
INSERT INTO international VALUES (59,'WebGUI',1,'I forgot my password.',1031514049);
INSERT INTO international VALUES (59,'WebGUI',4,'Perdí mi password',1031510000);
INSERT INTO international VALUES (59,'WebGUI',5,'Esqueci a minha password.',1031510000);
INSERT INTO international VALUES (363,'WebGUI',2,'Position des\nTemplates',1031510000);
INSERT INTO international VALUES (365,'WebGUI',2,'Ergebnisse der\nAbfrage',1031510000);
INSERT INTO international VALUES (366,'WebGUI',2,'Es wurden keine\nSeiten gefunden, die zu Ihrer Abfrage passen.',1031510000);
INSERT INTO international VALUES (229,'WebGUI',3,'Onderwerp',1031510000);
INSERT INTO international VALUES (230,'WebGUI',3,'Bericht',1031510000);
INSERT INTO international VALUES (231,'WebGUI',3,'Bezig met bericht posten...',1031510000);
INSERT INTO international VALUES (60,'WebGUI',1,'Are you certain you want to deactivate your account. If you proceed your account information will be lost permanently.',1031514049);
INSERT INTO international VALUES (60,'WebGUI',4,'Está seguro que quiere desactivar su cuenta. Si continúa su información se perderá permanentemente.',1031510000);
INSERT INTO international VALUES (60,'WebGUI',5,'Tem a certeza que quer desactivar a sua conta. Se o fizer é permanente!',1031510000);
INSERT INTO international VALUES (61,'WebGUI',1,'Update Account Information',1031514049);
INSERT INTO international VALUES (61,'WebGUI',4,'Actualizar información de la Cuenta',1031510000);
INSERT INTO international VALUES (61,'WebGUI',5,'Actualizar as informações da conta',1031510000);
INSERT INTO international VALUES (228,'WebGUI',3,'Bewerk bericht...',1031510000);
INSERT INTO international VALUES (62,'WebGUI',1,'save',1031514049);
INSERT INTO international VALUES (62,'WebGUI',4,'guardar',1031510000);
INSERT INTO international VALUES (62,'WebGUI',5,'gravar',1031510000);
INSERT INTO international VALUES (63,'WebGUI',1,'Turn admin on.',1031514049);
INSERT INTO international VALUES (63,'WebGUI',4,'Encender Admin',1031510000);
INSERT INTO international VALUES (63,'WebGUI',5,'Ligar modo administrativo.',1031510000);
INSERT INTO international VALUES (175,'WebGUI',3,'Macro\'s uitvoeren?',1031510000);
INSERT INTO international VALUES (64,'WebGUI',1,'Log out.',1031514049);
INSERT INTO international VALUES (64,'WebGUI',4,'Salir',1031510000);
INSERT INTO international VALUES (64,'WebGUI',5,'Sair.',1031510000);
INSERT INTO international VALUES (364,'WebGUI',2,'Suchen',1031510000);
INSERT INTO international VALUES (362,'WebGUI',2,'Nebeneinander',1031510000);
INSERT INTO international VALUES (65,'WebGUI',1,'Please deactivate my account permanently.',1031514049);
INSERT INTO international VALUES (65,'WebGUI',4,'Por favor desactive mi cuenta permanentemente',1031510000);
INSERT INTO international VALUES (65,'WebGUI',5,'Desactivar a minha conta permanentemente.',1031510000);
INSERT INTO international VALUES (174,'WebGUI',3,'Titel laten zien?',1031510000);
INSERT INTO international VALUES (66,'WebGUI',1,'Log In',1031514049);
INSERT INTO international VALUES (66,'WebGUI',4,'Ingresar',1031510000);
INSERT INTO international VALUES (66,'WebGUI',5,'Entrar',1031510000);
INSERT INTO international VALUES (171,'WebGUI',3,'Rich edit',1031510000);
INSERT INTO international VALUES (67,'WebGUI',1,'Create a new account.',1031514049);
INSERT INTO international VALUES (67,'WebGUI',4,'Crear nueva Cuenta',1031510000);
INSERT INTO international VALUES (67,'WebGUI',5,'Criar nova conta.',1031510000);
INSERT INTO international VALUES (169,'WebGUI',3,'Een nieuwe gebruiker toevoegen.',1031510000);
INSERT INTO international VALUES (170,'WebGUI',3,'Zoeken',1031510000);
INSERT INTO international VALUES (68,'WebGUI',1,'The account information you supplied is invalid. Either the account does not exist or the username/password combination was incorrect.',1031514049);
INSERT INTO international VALUES (68,'WebGUI',4,'La información de su cuenta no es válida. O la cuenta no existe',1031510000);
INSERT INTO international VALUES (68,'WebGUI',5,'As informações da sua conta não foram encontradas. Não existe ou a combinação username/password está incorrecta.',1031510000);
INSERT INTO international VALUES (69,'WebGUI',1,'Please contact your system administrator for assistance.',1031514049);
INSERT INTO international VALUES (69,'WebGUI',4,'Por favor contacte a su administrador por asistencia.',1031510000);
INSERT INTO international VALUES (69,'WebGUI',5,'Contacte o seu administrador de sistemas para assistência.',1031510000);
INSERT INTO international VALUES (361,'WebGUI',2,'Drei über\neinem',1031510000);
INSERT INTO international VALUES (360,'WebGUI',2,'Einer über\ndrei',1031510000);
INSERT INTO international VALUES (357,'WebGUI',2,'Nachrichten',1031510000);
INSERT INTO international VALUES (358,'WebGUI',2,'Linke Spalte',1031510000);
INSERT INTO international VALUES (168,'WebGUI',3,'Bewerk gebruiker',1031510000);
INSERT INTO international VALUES (70,'WebGUI',1,'Error',1031514049);
INSERT INTO international VALUES (70,'WebGUI',4,'Error',1031510000);
INSERT INTO international VALUES (70,'WebGUI',5,'Erro',1031510000);
INSERT INTO international VALUES (71,'WebGUI',1,'Recover password',1031514049);
INSERT INTO international VALUES (71,'WebGUI',4,'Recuperar password',1031510000);
INSERT INTO international VALUES (71,'WebGUI',5,'Recuperar password',1031510000);
INSERT INTO international VALUES (72,'WebGUI',1,'recover',1031514049);
INSERT INTO international VALUES (72,'WebGUI',4,'recuperar',1031510000);
INSERT INTO international VALUES (72,'WebGUI',5,'recoperar',1031510000);
INSERT INTO international VALUES (73,'WebGUI',1,'Log in.',1031514049);
INSERT INTO international VALUES (73,'WebGUI',4,'Ingresar.',1031510000);
INSERT INTO international VALUES (73,'WebGUI',5,'Entrar.',1031510000);
INSERT INTO international VALUES (359,'WebGUI',2,'Rechte Spalte',1031510000);
INSERT INTO international VALUES (74,'WebGUI',1,'Account Information',1031514049);
INSERT INTO international VALUES (74,'WebGUI',4,'Información de la Cuenta',1031510000);
INSERT INTO international VALUES (74,'WebGUI',5,'Informações da sua conta',1031510000);
INSERT INTO international VALUES (354,'WebGUI',2,'Beitrags Log\nanschauen.',1031510000);
INSERT INTO international VALUES (166,'WebGUI',3,'Verbindt DN',1031510000);
INSERT INTO international VALUES (167,'WebGUI',3,'Weet u zeker dat u deze gebruiker wilt verwijderen? Alle gebruikersinformatie wordt permanent verwijdert als u door gaat.',1031510000);
INSERT INTO international VALUES (75,'WebGUI',1,'Your account information has been sent to your email address.',1031514049);
INSERT INTO international VALUES (75,'WebGUI',4,'La información de su cuenta ha sido enviada a su e-mail-',1031510000);
INSERT INTO international VALUES (75,'WebGUI',5,'As informações da sua conta foram envidas para o seu e-mail.',1031510000);
INSERT INTO international VALUES (165,'WebGUI',3,'LDAP URL',1031510000);
INSERT INTO international VALUES (76,'WebGUI',1,'That email address is not in our databases.',1031514049);
INSERT INTO international VALUES (76,'WebGUI',4,'El e-mail no está en nuestra base de datos',1031510000);
INSERT INTO international VALUES (76,'WebGUI',5,'Esse endereço de e-mail não foi encontrado nas nossas bases de dados',1031510000);
INSERT INTO international VALUES (356,'WebGUI',2,'Vorlage',1031510000);
INSERT INTO international VALUES (355,'WebGUI',2,'Standard',1031510000);
INSERT INTO international VALUES (163,'WebGUI',3,'Gebruiker toevoegen',1031510000);
INSERT INTO international VALUES (164,'WebGUI',3,'Toegangs controle methode',1031510000);
INSERT INTO international VALUES (77,'WebGUI',1,'That account name is already in use by another member of this site. Please try a different username. The following are some suggestions:',1031514049);
INSERT INTO international VALUES (77,'WebGUI',4,'El nombre de cuenta ya está en uso por otro miembro. Por favor trate con otro nombre de usuario.  Los siguiente son algunas sugerencias:',1031510000);
INSERT INTO international VALUES (77,'WebGUI',5,'\"Esse nome de conta já existe, tente outro. Veja as nossas sugestões:\"',1031510000);
INSERT INTO international VALUES (162,'WebGUI',3,'Weet u zeker dat u alle pagina\'s en wobjects uit de prullenbak wilt verwijderen?',1031510000);
INSERT INTO international VALUES (78,'WebGUI',1,'Your passwords did not match. Please try again.',1031514049);
INSERT INTO international VALUES (78,'WebGUI',4,'Su password no concuerda. Trate de nuevo.',1031510000);
INSERT INTO international VALUES (78,'WebGUI',5,'\"As suas passwords não coincidem, tente novamente.\"',1031510000);
INSERT INTO international VALUES (161,'WebGUI',3,'Ingevoerd door',1031510000);
INSERT INTO international VALUES (79,'WebGUI',1,'Cannot connect to LDAP server.',1031514049);
INSERT INTO international VALUES (79,'WebGUI',4,'No se puede conectar con el servidor LDAP',1031510000);
INSERT INTO international VALUES (79,'WebGUI',5,'Impossivel ligar ao LDAP.',1031510000);
INSERT INTO international VALUES (160,'WebGUI',3,'Invoer datum',1031510000);
INSERT INTO international VALUES (80,'WebGUI',1,'Account created successfully!',1031514049);
INSERT INTO international VALUES (80,'WebGUI',4,'La cuenta se ha creado con éxito!',1031510000);
INSERT INTO international VALUES (80,'WebGUI',5,'Conta criada com sucesso!',1031510000);
INSERT INTO international VALUES (159,'WebGUI',3,'Berichten log',1031510000);
INSERT INTO international VALUES (81,'WebGUI',1,'Account updated successfully!',1031514049);
INSERT INTO international VALUES (81,'WebGUI',4,'La cuenta se actualizó con éxito!',1031510000);
INSERT INTO international VALUES (81,'WebGUI',5,'Conta actualizada com sucesso!',1031510000);
INSERT INTO international VALUES (82,'WebGUI',1,'Administrative functions...',1031514049);
INSERT INTO international VALUES (82,'WebGUI',4,'Funciones Administrativas...',1031510000);
INSERT INTO international VALUES (82,'WebGUI',5,'Funções administrativas...',1031510000);
INSERT INTO international VALUES (353,'WebGUI',2,'Zur Zeit sind\nkeine ausstehenden Beiträge vorhanden.',1031510000);
INSERT INTO international VALUES (350,'WebGUI',2,'Abgeschlossen',1031510000);
INSERT INTO international VALUES (158,'WebGUI',3,'Een nieuwe stijl toevoegen.',1031510000);
INSERT INTO international VALUES (84,'WebGUI',1,'Group Name',1031514049);
INSERT INTO international VALUES (84,'WebGUI',4,'Nombre del Grupo',1031510000);
INSERT INTO international VALUES (84,'WebGUI',5,'Nome do grupo',1031510000);
INSERT INTO international VALUES (351,'WebGUI',2,'Beitragseingang',1031510000);
INSERT INTO international VALUES (157,'WebGUI',3,'Stijlen',1031510000);
INSERT INTO international VALUES (85,'WebGUI',1,'Description',1031514049);
INSERT INTO international VALUES (85,'WebGUI',4,'Descripción',1031510000);
INSERT INTO international VALUES (85,'WebGUI',5,'Descrição',1031510000);
INSERT INTO international VALUES (352,'WebGUI',2,'Beitragsdatum',1031510000);
INSERT INTO international VALUES (155,'WebGUI',3,'Weet u zeker dat u deze stijl wilt verwijderen en migreer alle pagina\'s met de “fail safe” stijl?',1031510000);
INSERT INTO international VALUES (156,'WebGUI',3,'Bewerk stijl',1031510000);
INSERT INTO international VALUES (86,'WebGUI',1,'Are you certain you wish to delete this group? Beware that deleting a group is permanent and will remove all privileges associated with this group.',1031514049);
INSERT INTO international VALUES (86,'WebGUI',4,'Está segugo de querer eliminar éste grupo? Tenga en cuenta que la eliminación es permanente y removerá todos los privilegios asociados con el grupo.',1031510000);
INSERT INTO international VALUES (86,'WebGUI',5,'Tem a certeza que quer apagar este grupo. Se o fizer apaga-o permanentemente e a todos os seus provilégios.',1031510000);
INSERT INTO international VALUES (348,'WebGUI',2,'Name',1031510000);
INSERT INTO international VALUES (154,'WebGUI',3,'Style sheet',1031510000);
INSERT INTO international VALUES (87,'WebGUI',1,'Edit Group',1031514049);
INSERT INTO international VALUES (87,'WebGUI',4,'Editar Grupo',1031510000);
INSERT INTO international VALUES (87,'WebGUI',5,'Modificar grupo',1031510000);
INSERT INTO international VALUES (88,'WebGUI',1,'Users In Group',1031514049);
INSERT INTO international VALUES (88,'WebGUI',4,'Usuarios en Grupo',1031510000);
INSERT INTO international VALUES (88,'WebGUI',5,'Utilizadores no grupo',1031510000);
INSERT INTO international VALUES (349,'WebGUI',2,'Aktuelle\nVersion',1031510000);
INSERT INTO international VALUES (151,'WebGUI',3,'Stijl naam',1031510000);
INSERT INTO international VALUES (89,'WebGUI',1,'Groups',1031514049);
INSERT INTO international VALUES (89,'WebGUI',4,'Grupos',1031510000);
INSERT INTO international VALUES (89,'WebGUI',5,'Grupos',1031510000);
INSERT INTO international VALUES (149,'WebGUI',3,'Gebruikers',1031510000);
INSERT INTO international VALUES (90,'WebGUI',1,'Add new group.',1031514049);
INSERT INTO international VALUES (90,'WebGUI',4,'Agregar nuevo grupo',1031510000);
INSERT INTO international VALUES (90,'WebGUI',5,'Adicionar novo grupo.',1031510000);
INSERT INTO international VALUES (148,'WebGUI',3,'Wobjects',1031510000);
INSERT INTO international VALUES (91,'WebGUI',1,'Previous Page',1031514049);
INSERT INTO international VALUES (91,'WebGUI',4,'Página previa',1031510000);
INSERT INTO international VALUES (91,'WebGUI',5,'Página anterior',1031510000);
INSERT INTO international VALUES (147,'WebGUI',3,'Pagina\'s',1031510000);
INSERT INTO international VALUES (92,'WebGUI',1,'Next Page',1031514049);
INSERT INTO international VALUES (92,'WebGUI',4,'Siguiente página',1031510000);
INSERT INTO international VALUES (92,'WebGUI',5,'Próxima página',1031510000);
INSERT INTO international VALUES (93,'WebGUI',1,'Help',1031514049);
INSERT INTO international VALUES (93,'WebGUI',4,'Ayuda',1031510000);
INSERT INTO international VALUES (93,'WebGUI',5,'Ajuda',1031510000);
INSERT INTO international VALUES (146,'WebGUI',3,'Aktieve sessies',1031510000);
INSERT INTO international VALUES (94,'WebGUI',1,'See also',1031514049);
INSERT INTO international VALUES (94,'WebGUI',4,'Vea también',1031510000);
INSERT INTO international VALUES (94,'WebGUI',5,'Ver tembém',1031510000);
INSERT INTO international VALUES (347,'WebGUI',2,'Profil anschauen\nvon',1031510000);
INSERT INTO international VALUES (145,'WebGUI',3,'WebGUI versie',1031510000);
INSERT INTO international VALUES (95,'WebGUI',1,'Help Index',1031514049);
INSERT INTO international VALUES (95,'WebGUI',4,'Índice de Ayuda',1031510000);
INSERT INTO international VALUES (95,'WebGUI',5,'Indice da ajuda',1031510000);
INSERT INTO international VALUES (5,'LinkList',6,'Fortsätt med att lägga till en länk?',1031510000);
INSERT INTO international VALUES (5,'Item',6,'Ladda ned bilaga',1031510000);
INSERT INTO international VALUES (346,'WebGUI',2,'Dieser Benutzer\nist kein Mitglied. Wir haben keine weiteren Informationen über ihn.',1031510000);
INSERT INTO international VALUES (99,'WebGUI',1,'Title',1031514049);
INSERT INTO international VALUES (99,'WebGUI',4,'Título',1031510000);
INSERT INTO international VALUES (99,'WebGUI',5,'Titulo',1031510000);
INSERT INTO international VALUES (144,'WebGUI',3,'Bekijk statistieken',1031510000);
INSERT INTO international VALUES (100,'WebGUI',1,'Meta Tags',1031514049);
INSERT INTO international VALUES (100,'WebGUI',4,'Meta Tags',1031510000);
INSERT INTO international VALUES (100,'WebGUI',5,'Meta Tags',1031510000);
INSERT INTO international VALUES (345,'WebGUI',2,'Kein Mitglied',1031510000);
INSERT INTO international VALUES (142,'WebGUI',3,'Sessie time out',1031510000);
INSERT INTO international VALUES (143,'WebGUI',3,'Beheer instellingen.',1031510000);
INSERT INTO international VALUES (101,'WebGUI',1,'Are you certain that you wish to delete this page, its content, and all items under it?',1031514049);
INSERT INTO international VALUES (101,'WebGUI',4,'Está seguro de querer eliminar ésta página',1031510000);
INSERT INTO international VALUES (101,'WebGUI',5,'\"Tem a certeza que quer apagar esta página, o seu conteudo e tudo que está abaixo?\"',1031510000);
INSERT INTO international VALUES (102,'WebGUI',1,'Edit Page',1031514049);
INSERT INTO international VALUES (102,'WebGUI',4,'Editar Página',1031510000);
INSERT INTO international VALUES (102,'WebGUI',5,'Modificar a página',1031510000);
INSERT INTO international VALUES (141,'WebGUI',3,'Niet gevonden pagina',1031510000);
INSERT INTO international VALUES (103,'WebGUI',1,'Page Specifics',1031514049);
INSERT INTO international VALUES (103,'WebGUI',4,'Propio de la página',1031510000);
INSERT INTO international VALUES (103,'WebGUI',5,'Especificações da página',1031510000);
INSERT INTO international VALUES (104,'WebGUI',1,'Page URL',1031514049);
INSERT INTO international VALUES (104,'WebGUI',4,'URL de la página',1031510000);
INSERT INTO international VALUES (104,'WebGUI',5,'URL da página',1031510000);
INSERT INTO international VALUES (140,'WebGUI',3,'Bewerk allerlei instellingen',1031510000);
INSERT INTO international VALUES (105,'WebGUI',1,'Style',1031514049);
INSERT INTO international VALUES (105,'WebGUI',4,'Estilo',1031510000);
INSERT INTO international VALUES (105,'WebGUI',5,'Estilo',1031510000);
INSERT INTO international VALUES (342,'WebGUI',2,'Benutzerkonto\nbearbeiten.',1031510000);
INSERT INTO international VALUES (341,'WebGUI',2,'Profil\nbearbeiten.',1031510000);
INSERT INTO international VALUES (340,'WebGUI',2,'weiblich',1031510000);
INSERT INTO international VALUES (138,'WebGUI',3,'Ja',1031510000);
INSERT INTO international VALUES (139,'WebGUI',3,'Nee',1031510000);
INSERT INTO international VALUES (106,'WebGUI',1,'Select \"Yes\" to change all the pages under this page to this style.',1031514049);
INSERT INTO international VALUES (106,'WebGUI',4,'Marque para dar éste estilo a todas las sub-páginas.',1031510000);
INSERT INTO international VALUES (106,'WebGUI',5,'Escolha para atribuir este estilo a todas as sub-páginas',1031510000);
INSERT INTO international VALUES (135,'WebGUI',3,'SMTP server',1031510000);
INSERT INTO international VALUES (107,'WebGUI',1,'Privileges',1031514049);
INSERT INTO international VALUES (107,'WebGUI',4,'Privilegios',1031510000);
INSERT INTO international VALUES (107,'WebGUI',5,'Privilégios',1031510000);
INSERT INTO international VALUES (108,'WebGUI',1,'Owner',1031514049);
INSERT INTO international VALUES (108,'WebGUI',4,'Dueño',1031510000);
INSERT INTO international VALUES (108,'WebGUI',5,'Dono',1031510000);
INSERT INTO international VALUES (134,'WebGUI',3,'Bericht om wachtwoord terug te vinden',1031510000);
INSERT INTO international VALUES (109,'WebGUI',1,'Owner can view?',1031514049);
INSERT INTO international VALUES (109,'WebGUI',4,'Dueño puede ver?',1031510000);
INSERT INTO international VALUES (109,'WebGUI',5,'O dono pode ver?',1031510000);
INSERT INTO international VALUES (110,'WebGUI',1,'Owner can edit?',1031514049);
INSERT INTO international VALUES (110,'WebGUI',4,'Dueño puede editar?',1031510000);
INSERT INTO international VALUES (110,'WebGUI',5,'O dono pode modificar?',1031510000);
INSERT INTO international VALUES (343,'WebGUI',2,'Profil\nanschauen.',1031510000);
INSERT INTO international VALUES (133,'WebGUI',3,'Bewerk email instellingen',1031510000);
INSERT INTO international VALUES (111,'WebGUI',1,'Group',1031514049);
INSERT INTO international VALUES (111,'WebGUI',4,'Grupo',1031510000);
INSERT INTO international VALUES (111,'WebGUI',5,'Grupo',1031510000);
INSERT INTO international VALUES (112,'WebGUI',1,'Group can view?',1031514049);
INSERT INTO international VALUES (112,'WebGUI',4,'Grupo puede ver?',1031510000);
INSERT INTO international VALUES (112,'WebGUI',5,'O grupo pode ver?',1031510000);
INSERT INTO international VALUES (130,'WebGUI',3,'Maximum grootte bijlagen',1031510000);
INSERT INTO international VALUES (113,'WebGUI',1,'Group can edit?',1031514049);
INSERT INTO international VALUES (113,'WebGUI',4,'Grupo puede editar?',1031510000);
INSERT INTO international VALUES (113,'WebGUI',5,'O grupo pode modificar?',1031510000);
INSERT INTO international VALUES (338,'WebGUI',2,'Profil\nbearbeiten',1031510000);
INSERT INTO international VALUES (127,'WebGUI',3,'URL bedrijf',1031510000);
INSERT INTO international VALUES (114,'WebGUI',1,'Anybody can view?',1031514049);
INSERT INTO international VALUES (114,'WebGUI',4,'Cualquiera puede ver?',1031510000);
INSERT INTO international VALUES (114,'WebGUI',5,'Qualquer pessoa pode ver?',1031510000);
INSERT INTO international VALUES (115,'WebGUI',1,'Anybody can edit?',1031514049);
INSERT INTO international VALUES (115,'WebGUI',4,'Cualquiera puede editar?',1031510000);
INSERT INTO international VALUES (115,'WebGUI',5,'Qualquer pessoa pode modificar?',1031510000);
INSERT INTO international VALUES (339,'WebGUI',2,'männlich',1031510000);
INSERT INTO international VALUES (125,'WebGUI',3,'Bedrijfsnaam',1031510000);
INSERT INTO international VALUES (126,'WebGUI',3,'Email adres bedrijf',1031510000);
INSERT INTO international VALUES (116,'WebGUI',1,'Select \"Yes\" to change the privileges of all pages under this page to these privileges.',1031514049);
INSERT INTO international VALUES (116,'WebGUI',4,'Marque para dar éstos privilegios a todas las sub-páginas.',1031510000);
INSERT INTO international VALUES (116,'WebGUI',5,'Escolher para atribuir estes privilégios a todas as sub-páginas.',1031510000);
INSERT INTO international VALUES (117,'WebGUI',1,'Edit User Settings',1031514049);
INSERT INTO international VALUES (117,'WebGUI',4,'Editar Opciones de Auntentificación',1031510000);
INSERT INTO international VALUES (117,'WebGUI',5,'Modificar preferências de autenticação',1031510000);
INSERT INTO international VALUES (337,'WebGUI',2,'Homepage URL',1031510000);
INSERT INTO international VALUES (124,'WebGUI',3,'Bewerk bedrijfsinformatie',1031510000);
INSERT INTO international VALUES (118,'WebGUI',1,'Anonymous Registration',1031514049);
INSERT INTO international VALUES (118,'WebGUI',4,'Registración Anónima',1031510000);
INSERT INTO international VALUES (118,'WebGUI',5,'Registo anónimo',1031510000);
INSERT INTO international VALUES (123,'WebGUI',3,'LDAP wachtwoord naam',1031510000);
INSERT INTO international VALUES (119,'WebGUI',1,'Authentication Method (default)',1031514049);
INSERT INTO international VALUES (119,'WebGUI',4,'Método de Autentificación (por defecto)',1031510000);
INSERT INTO international VALUES (119,'WebGUI',5,'Método de autenticação (defeito)',1031510000);
INSERT INTO international VALUES (122,'WebGUI',3,'LDAP identiteit naam',1031510000);
INSERT INTO international VALUES (120,'WebGUI',1,'LDAP URL (default)',1031514049);
INSERT INTO international VALUES (120,'WebGUI',4,'URL LDAP (por defecto)',1031510000);
INSERT INTO international VALUES (120,'WebGUI',5,'URL LDAP (defeito)',1031510000);
INSERT INTO international VALUES (121,'WebGUI',1,'LDAP Identity (default)',1031514049);
INSERT INTO international VALUES (121,'WebGUI',4,'Identidad LDAP (por defecto)',1031510000);
INSERT INTO international VALUES (121,'WebGUI',5,'Identidade LDAP (defeito)',1031510000);
INSERT INTO international VALUES (121,'WebGUI',3,'LDAP identiteit (standaard)',1031510000);
INSERT INTO international VALUES (122,'WebGUI',1,'LDAP Identity Name',1031514049);
INSERT INTO international VALUES (122,'WebGUI',4,'Nombre Identidad LDAP',1031510000);
INSERT INTO international VALUES (122,'WebGUI',5,'Nome da entidade LDAP',1031510000);
INSERT INTO international VALUES (120,'WebGUI',3,'LDAP URL (standaard)',1031510000);
INSERT INTO international VALUES (123,'WebGUI',1,'LDAP Password Name',1031514049);
INSERT INTO international VALUES (123,'WebGUI',4,'Password LDAP',1031510000);
INSERT INTO international VALUES (123,'WebGUI',5,'Nome da password LDAP',1031510000);
INSERT INTO international VALUES (124,'WebGUI',1,'Edit Company Information',1031514049);
INSERT INTO international VALUES (124,'WebGUI',4,'Editar Información de la Companía',1031510000);
INSERT INTO international VALUES (124,'WebGUI',5,'Modificar informação da empresa',1031510000);
INSERT INTO international VALUES (119,'WebGUI',3,'Toegangs controle methode (standaard)',1031510000);
INSERT INTO international VALUES (125,'WebGUI',1,'Company Name',1031514049);
INSERT INTO international VALUES (125,'WebGUI',4,'Nombre de la Companía',1031510000);
INSERT INTO international VALUES (125,'WebGUI',5,'Nome da empresa',1031510000);
INSERT INTO international VALUES (118,'WebGUI',3,'Anonieme registratie',1031510000);
INSERT INTO international VALUES (126,'WebGUI',1,'Company Email Address',1031514049);
INSERT INTO international VALUES (126,'WebGUI',4,'E-mail de la Companía',1031510000);
INSERT INTO international VALUES (126,'WebGUI',5,'Moarada da empresa',1031510000);
INSERT INTO international VALUES (333,'WebGUI',2,'Land (Büro)',1031510000);
INSERT INTO international VALUES (335,'WebGUI',2,'Geschlecht',1031510000);
INSERT INTO international VALUES (334,'WebGUI',2,'Telefon (Büro)',1031510000);
INSERT INTO international VALUES (336,'WebGUI',2,'Geburtstag',1031510000);
INSERT INTO international VALUES (127,'WebGUI',1,'Company URL',1031514049);
INSERT INTO international VALUES (127,'WebGUI',4,'URL de la Companía',1031510000);
INSERT INTO international VALUES (127,'WebGUI',5,'URL da empresa',1031510000);
INSERT INTO international VALUES (331,'WebGUI',2,'Bundesland\n(Büro)',1031510000);
INSERT INTO international VALUES (117,'WebGUI',3,'Bewerk toegangs controle instellingen',1031510000);
INSERT INTO international VALUES (130,'WebGUI',1,'Maximum Attachment Size',1031514049);
INSERT INTO international VALUES (130,'WebGUI',4,'Tamaño máximo de adjuntos',1031510000);
INSERT INTO international VALUES (130,'WebGUI',5,'Tamanho máximo dos anexos',1031510000);
INSERT INTO international VALUES (330,'WebGUI',2,'Ort (Büro)',1031510000);
INSERT INTO international VALUES (133,'WebGUI',1,'Edit Mail Settings',1031514049);
INSERT INTO international VALUES (133,'WebGUI',4,'Editar configuración de e-mail',1031510000);
INSERT INTO international VALUES (133,'WebGUI',5,'Modificar preferências de e-mail',1031510000);
INSERT INTO international VALUES (332,'WebGUI',2,'Postleitzahl\n(Büro)',1031510000);
INSERT INTO international VALUES (116,'WebGUI',3,'Aanvinken om deze privileges aan alle sub pagina\'s te geven.',1031510000);
INSERT INTO international VALUES (134,'WebGUI',1,'Recover Password Message',1031514049);
INSERT INTO international VALUES (134,'WebGUI',4,'Mensage de Recuperar Password',1031510000);
INSERT INTO international VALUES (134,'WebGUI',5,'Mensagem de recuperação de password',1031510000);
INSERT INTO international VALUES (135,'WebGUI',1,'SMTP Server',1031514049);
INSERT INTO international VALUES (135,'WebGUI',4,'Servidor SMTP',1031510000);
INSERT INTO international VALUES (135,'WebGUI',5,'Servidor SMTP',1031510000);
INSERT INTO international VALUES (326,'WebGUI',2,'Postleitzahl\n(privat)',1031510000);
INSERT INTO international VALUES (327,'WebGUI',2,'Land (privat)',1031510000);
INSERT INTO international VALUES (138,'WebGUI',1,'Yes',1031514049);
INSERT INTO international VALUES (138,'WebGUI',4,'Si',1031510000);
INSERT INTO international VALUES (138,'WebGUI',5,'Sim',1031510000);
INSERT INTO international VALUES (115,'WebGUI',3,'Iedereen kan bewerken?',1031510000);
INSERT INTO international VALUES (139,'WebGUI',1,'No',1031514049);
INSERT INTO international VALUES (139,'WebGUI',4,'No',1031510000);
INSERT INTO international VALUES (139,'WebGUI',5,'Não',1031510000);
INSERT INTO international VALUES (329,'WebGUI',2,'Strasse (Büro)',1031510000);
INSERT INTO international VALUES (328,'WebGUI',2,'Telefon\n(privat)',1031510000);
INSERT INTO international VALUES (114,'WebGUI',3,'Iedereen kan bekijken?',1031510000);
INSERT INTO international VALUES (140,'WebGUI',1,'Edit Miscellaneous Settings',1031514049);
INSERT INTO international VALUES (140,'WebGUI',4,'Editar configuraciones misceláneas',1031510000);
INSERT INTO international VALUES (140,'WebGUI',5,'Modificar preferências mistas',1031510000);
INSERT INTO international VALUES (141,'WebGUI',1,'Not Found Page',1031514049);
INSERT INTO international VALUES (141,'WebGUI',4,'Página no encontrada',1031510000);
INSERT INTO international VALUES (141,'WebGUI',5,'Página não encontrada',1031510000);
INSERT INTO international VALUES (113,'WebGUI',3,'Groep kan bewerken?',1031510000);
INSERT INTO international VALUES (142,'WebGUI',1,'Session Timeout',1031514049);
INSERT INTO international VALUES (142,'WebGUI',4,'Timeout de sesión',1031510000);
INSERT INTO international VALUES (142,'WebGUI',5,'Timeout de sessão',1031510000);
INSERT INTO international VALUES (325,'WebGUI',2,'Bundesland\n(privat)',1031510000);
INSERT INTO international VALUES (112,'WebGUI',3,'Groep kan bekijken?',1031510000);
INSERT INTO international VALUES (143,'WebGUI',1,'Manage Settings',1031514049);
INSERT INTO international VALUES (143,'WebGUI',4,'Configurar Opciones',1031510000);
INSERT INTO international VALUES (143,'WebGUI',5,'Organizar preferências',1031510000);
INSERT INTO international VALUES (111,'WebGUI',3,'Groep',1031510000);
INSERT INTO international VALUES (144,'WebGUI',1,'View statistics.',1031514049);
INSERT INTO international VALUES (144,'WebGUI',4,'Ver estadísticas',1031510000);
INSERT INTO international VALUES (144,'WebGUI',5,'Ver estatisticas.',1031510000);
INSERT INTO international VALUES (145,'WebGUI',1,'WebGUI Build Version',1031514049);
INSERT INTO international VALUES (145,'WebGUI',4,'Versión de WebGUI',1031510000);
INSERT INTO international VALUES (145,'WebGUI',5,'WebGUI versão',1031510000);
INSERT INTO international VALUES (323,'WebGUI',2,'Strasse\n(privat)',1031510000);
INSERT INTO international VALUES (110,'WebGUI',3,'Gebruiker kan bewerken?',1031510000);
INSERT INTO international VALUES (146,'WebGUI',1,'Active Sessions',1031514049);
INSERT INTO international VALUES (146,'WebGUI',4,'Sesiones activas',1031510000);
INSERT INTO international VALUES (146,'WebGUI',5,'Sessões activas',1031510000);
INSERT INTO international VALUES (147,'WebGUI',1,'Pages',1031514049);
INSERT INTO international VALUES (147,'WebGUI',4,'Páginas',1031510000);
INSERT INTO international VALUES (147,'WebGUI',5,'Páginas',1031510000);
INSERT INTO international VALUES (109,'WebGUI',3,'Eigenaar kan bekijken?',1031510000);
INSERT INTO international VALUES (148,'WebGUI',1,'Wobjects',1031514049);
INSERT INTO international VALUES (148,'WebGUI',4,'Wobjects',1031510000);
INSERT INTO international VALUES (148,'WebGUI',5,'Wobjects',1031510000);
INSERT INTO international VALUES (108,'WebGUI',3,'Eigenaar',1031510000);
INSERT INTO international VALUES (149,'WebGUI',1,'Users',1031514049);
INSERT INTO international VALUES (149,'WebGUI',4,'Usuarios',1031510000);
INSERT INTO international VALUES (149,'WebGUI',5,'Utilizadores',1031510000);
INSERT INTO international VALUES (107,'WebGUI',3,'Privileges',1031510000);
INSERT INTO international VALUES (151,'WebGUI',1,'Style Name',1031514049);
INSERT INTO international VALUES (151,'WebGUI',4,'Nombre del Estilo',1031510000);
INSERT INTO international VALUES (151,'WebGUI',5,'Nome do estilo',1031510000);
INSERT INTO international VALUES (505,'WebGUI',1,'Add a new template.',1031514049);
INSERT INTO international VALUES (504,'WebGUI',1,'Template',1031514049);
INSERT INTO international VALUES (503,'WebGUI',1,'Template ID',1031514049);
INSERT INTO international VALUES (502,'WebGUI',1,'Are you certain you wish to delete this template and set all pages using this template to the default template?',1031514049);
INSERT INTO international VALUES (154,'WebGUI',1,'Style Sheet',1031514049);
INSERT INTO international VALUES (154,'WebGUI',4,'Hoja de Estilo',1031510000);
INSERT INTO international VALUES (154,'WebGUI',5,'Estilo de página',1031510000);
INSERT INTO international VALUES (322,'WebGUI',2,'Pager',1031510000);
INSERT INTO international VALUES (321,'WebGUI',2,'Mobiltelefon',1031510000);
INSERT INTO international VALUES (324,'WebGUI',2,'Ort (privat)',1031510000);
INSERT INTO international VALUES (320,'WebGUI',2,'<a href=\"\"\nhttp://messenger.yahoo.com/\"\">Yahoo! Messenger</a> Id',1031510000);
INSERT INTO international VALUES (105,'WebGUI',3,'Stijl',1031510000);
INSERT INTO international VALUES (106,'WebGUI',3,'Aanvinken om deze stijl in alle pagina\'s te gebruiiken.',1031510000);
INSERT INTO international VALUES (155,'WebGUI',1,'Are you certain you wish to delete this style and migrate all pages using this style to the \"Fail Safe\" style?',1031514049);
INSERT INTO international VALUES (155,'WebGUI',4,'\"Está seguro de querer eliminar éste estilo y migrar todas la páginas que lo usen al estilo \"\"Fail Safe\"\"?\"',1031510000);
INSERT INTO international VALUES (155,'WebGUI',5,'\"Tem a certeza que quer apagar este estilo e migrar todas as páginas para o estilo \"\"Fail Safe\"\"?\"',1031510000);
INSERT INTO international VALUES (156,'WebGUI',1,'Edit Style',1031514049);
INSERT INTO international VALUES (156,'WebGUI',4,'Editar Estilo',1031510000);
INSERT INTO international VALUES (156,'WebGUI',5,'Modificar estilo',1031510000);
INSERT INTO international VALUES (104,'WebGUI',3,'Pagina URL',1031510000);
INSERT INTO international VALUES (157,'WebGUI',1,'Styles',1031514049);
INSERT INTO international VALUES (157,'WebGUI',4,'Estilos',1031510000);
INSERT INTO international VALUES (157,'WebGUI',5,'Estilos',1031510000);
INSERT INTO international VALUES (103,'WebGUI',3,'Pagina specifiek',1031510000);
INSERT INTO international VALUES (158,'WebGUI',1,'Add a new style.',1031514049);
INSERT INTO international VALUES (158,'WebGUI',4,'Agregar nuevo Estilo',1031510000);
INSERT INTO international VALUES (158,'WebGUI',5,'Adicionar novo estilo.',1031510000);
INSERT INTO international VALUES (102,'WebGUI',3,'Bewerk pagina',1031510000);
INSERT INTO international VALUES (471,'WebGUI',10,'Rediger bruger profil felt',1031510000);
INSERT INTO international VALUES (159,'WebGUI',4,'Contribuciones Pendientes',1031510000);
INSERT INTO international VALUES (159,'WebGUI',5,'Log das mensagens',1031510000);
INSERT INTO international VALUES (160,'WebGUI',1,'Date Submitted',1031514049);
INSERT INTO international VALUES (160,'WebGUI',4,'Fecha Contribución',1031510000);
INSERT INTO international VALUES (160,'WebGUI',5,'Data de submissão',1031510000);
INSERT INTO international VALUES (319,'WebGUI',2,'<a href=\"\"\nhttp://messenger.msn.com/\"\">MSN Messenger</a> Id',1031510000);
INSERT INTO international VALUES (161,'WebGUI',1,'Submitted By',1031514049);
INSERT INTO international VALUES (161,'WebGUI',4,'Contribuido por',1031510000);
INSERT INTO international VALUES (161,'WebGUI',5,'Submetido por',1031510000);
INSERT INTO international VALUES (100,'WebGUI',3,'Meta tags',1031510000);
INSERT INTO international VALUES (101,'WebGUI',3,'Weet u zeker dat u deze pagina wilt verwijderen en alle inhoud en objecten erachter?',1031510000);
INSERT INTO international VALUES (162,'WebGUI',1,'Are you certain that you wish to purge all the pages and wobjects in the trash?',1031514049);
INSERT INTO international VALUES (162,'WebGUI',4,'Está seguro de querer eliminar todos los elementos de la papelera?',1031510000);
INSERT INTO international VALUES (162,'WebGUI',5,'Tem a certeza que quer limpar todas as páginas e wobjects para o caixote do lixo?',1031510000);
INSERT INTO international VALUES (99,'WebGUI',3,'Titel',1031510000);
INSERT INTO international VALUES (163,'WebGUI',1,'Add User',1031514049);
INSERT INTO international VALUES (163,'WebGUI',4,'Agregar usuario',1031510000);
INSERT INTO international VALUES (163,'WebGUI',5,'Adicionar utilizador',1031510000);
INSERT INTO international VALUES (95,'WebGUI',3,'Help index',1031510000);
INSERT INTO international VALUES (164,'WebGUI',1,'Authentication Method',1031514049);
INSERT INTO international VALUES (164,'WebGUI',4,'Método de Auntentificación',1031510000);
INSERT INTO international VALUES (164,'WebGUI',5,'Metodo de autenticação',1031510000);
INSERT INTO international VALUES (94,'WebGUI',3,'Zie ook',1031510000);
INSERT INTO international VALUES (165,'WebGUI',1,'LDAP URL',1031514049);
INSERT INTO international VALUES (165,'WebGUI',4,'LDAP URL',1031510000);
INSERT INTO international VALUES (165,'WebGUI',5,'LDAP URL',1031510000);
INSERT INTO international VALUES (317,'WebGUI',2,'<a href=\"\"\nhttp://www.icq.com\"\">ICQ</a> UIN',1031510000);
INSERT INTO international VALUES (93,'WebGUI',3,'Help',1031510000);
INSERT INTO international VALUES (166,'WebGUI',1,'Connect DN',1031514049);
INSERT INTO international VALUES (166,'WebGUI',4,'Connect DN',1031510000);
INSERT INTO international VALUES (166,'WebGUI',5,'Connectar DN',1031510000);
INSERT INTO international VALUES (91,'WebGUI',3,'Vorige pagina',1031510000);
INSERT INTO international VALUES (92,'WebGUI',3,'Volgende pagina',1031510000);
INSERT INTO international VALUES (167,'WebGUI',1,'Are you certain you want to delete this user? Be warned that all this user\'s information will be lost permanently if you choose to proceed.',1031514049);
INSERT INTO international VALUES (167,'WebGUI',4,'Está seguro de querer eliminar éste usuario? Tenga en cuenta que toda la información del usuario será eliminada permanentemente si procede.',1031510000);
INSERT INTO international VALUES (167,'WebGUI',5,'Tem a certeza que quer apagar este utilizador? Se o fizer perde todas as informações do utilizador.',1031510000);
INSERT INTO international VALUES (90,'WebGUI',3,'Voeg nieuwe groep toe.',1031510000);
INSERT INTO international VALUES (168,'WebGUI',1,'Edit User',1031514049);
INSERT INTO international VALUES (168,'WebGUI',4,'Editar Usuario',1031510000);
INSERT INTO international VALUES (168,'WebGUI',5,'Modificar utilizador',1031510000);
INSERT INTO international VALUES (89,'WebGUI',3,'Groepen',1031510000);
INSERT INTO international VALUES (169,'WebGUI',1,'Add a new user.',1031514049);
INSERT INTO international VALUES (169,'WebGUI',4,'Agregar nuevo usuario',1031510000);
INSERT INTO international VALUES (169,'WebGUI',5,'Adicionar utilizador.',1031510000);
INSERT INTO international VALUES (170,'WebGUI',1,'search',1031514049);
INSERT INTO international VALUES (170,'WebGUI',4,'buscar',1031510000);
INSERT INTO international VALUES (170,'WebGUI',5,'procurar',1031510000);
INSERT INTO international VALUES (88,'WebGUI',3,'Gebruikers in groep',1031510000);
INSERT INTO international VALUES (171,'WebGUI',1,'rich edit',1031514049);
INSERT INTO international VALUES (171,'WebGUI',4,'rich edit',1031510000);
INSERT INTO international VALUES (171,'WebGUI',5,'rich edit',1031510000);
INSERT INTO international VALUES (318,'WebGUI',2,'<a href=\"\"\nhttp://www.aol.com/aim/homenew.adp\"\">AIM</a> Id',1031510000);
INSERT INTO international VALUES (87,'WebGUI',3,'Bewerk groep',1031510000);
INSERT INTO international VALUES (174,'WebGUI',1,'Display the title?',1031514049);
INSERT INTO international VALUES (174,'WebGUI',4,'Mostrar el título?',1031510000);
INSERT INTO international VALUES (174,'WebGUI',5,'Mostrar o titulo?',1031510000);
INSERT INTO international VALUES (175,'WebGUI',1,'Process macros?',1031514049);
INSERT INTO international VALUES (175,'WebGUI',4,'Procesar macros?',1031510000);
INSERT INTO international VALUES (175,'WebGUI',5,'Processar macros?',1031510000);
INSERT INTO international VALUES (228,'WebGUI',1,'Editing Message...',1031514049);
INSERT INTO international VALUES (228,'WebGUI',4,'Editar Mensage...',1031510000);
INSERT INTO international VALUES (228,'WebGUI',5,'Modificando mensagem...',1031510000);
INSERT INTO international VALUES (229,'WebGUI',1,'Subject',1031514049);
INSERT INTO international VALUES (229,'WebGUI',4,'Asunto',1031510000);
INSERT INTO international VALUES (229,'WebGUI',5,'Assunto',1031510000);
INSERT INTO international VALUES (230,'WebGUI',1,'Message',1031514049);
INSERT INTO international VALUES (230,'WebGUI',4,'Mensage',1031510000);
INSERT INTO international VALUES (230,'WebGUI',5,'Mensagem',1031510000);
INSERT INTO international VALUES (231,'WebGUI',1,'Posting New Message...',1031514049);
INSERT INTO international VALUES (231,'WebGUI',4,'Mandando Nuevo Mensage ...',1031510000);
INSERT INTO international VALUES (231,'WebGUI',5,'Colocando nova mensagem...',1031510000);
INSERT INTO international VALUES (232,'WebGUI',1,'no subject',1031514049);
INSERT INTO international VALUES (232,'WebGUI',4,'sin título',1031510000);
INSERT INTO international VALUES (232,'WebGUI',5,'sem assunto',1031510000);
INSERT INTO international VALUES (86,'WebGUI',3,'Weet u zeker dat u deze groep wilt verwijderen? Denk er aan dat een groep verwijderen permanent en alle privileges geassocieerd met de groep verwijdert worden.',1031510000);
INSERT INTO international VALUES (233,'WebGUI',1,'(eom)',1031514049);
INSERT INTO international VALUES (233,'WebGUI',4,'(eom)',1031510000);
INSERT INTO international VALUES (233,'WebGUI',5,'(eom)',1031510000);
INSERT INTO international VALUES (85,'WebGUI',3,'Beschrijving',1031510000);
INSERT INTO international VALUES (234,'WebGUI',1,'Posting Reply...',1031514049);
INSERT INTO international VALUES (234,'WebGUI',4,'Respondiendo...',1031510000);
INSERT INTO international VALUES (234,'WebGUI',5,'Respondendo...',1031510000);
INSERT INTO international VALUES (315,'WebGUI',2,'Zweiter\nVorname',1031510000);
INSERT INTO international VALUES (314,'WebGUI',2,'Vorname',1031510000);
INSERT INTO international VALUES (316,'WebGUI',2,'Nachname',1031510000);
INSERT INTO international VALUES (237,'WebGUI',1,'Subject:',1031514049);
INSERT INTO international VALUES (237,'WebGUI',4,'Asunto:',1031510000);
INSERT INTO international VALUES (237,'WebGUI',5,'Assunto:',1031510000);
INSERT INTO international VALUES (84,'WebGUI',3,'Groep naam',1031510000);
INSERT INTO international VALUES (238,'WebGUI',1,'Author:',1031514049);
INSERT INTO international VALUES (238,'WebGUI',4,'Autor:',1031510000);
INSERT INTO international VALUES (238,'WebGUI',5,'Autor:',1031510000);
INSERT INTO international VALUES (239,'WebGUI',1,'Date:',1031514049);
INSERT INTO international VALUES (239,'WebGUI',4,'Fecha:',1031510000);
INSERT INTO international VALUES (239,'WebGUI',5,'Data:',1031510000);
INSERT INTO international VALUES (313,'WebGUI',2,'Zusätzliche\nInformationen anzeigen?',1031510000);
INSERT INTO international VALUES (82,'WebGUI',3,'Administratieve functies...',1031510000);
INSERT INTO international VALUES (240,'WebGUI',1,'Message ID:',1031514049);
INSERT INTO international VALUES (240,'WebGUI',4,'ID del mensage:',1031510000);
INSERT INTO international VALUES (240,'WebGUI',5,'ID da mensagem:',1031510000);
INSERT INTO international VALUES (244,'WebGUI',1,'Author',1031514049);
INSERT INTO international VALUES (244,'WebGUI',4,'Autor',1031510000);
INSERT INTO international VALUES (244,'WebGUI',5,'Autor',1031510000);
INSERT INTO international VALUES (81,'WebGUI',3,'Account is aangepast!',1031510000);
INSERT INTO international VALUES (245,'WebGUI',1,'Date',1031514049);
INSERT INTO international VALUES (245,'WebGUI',4,'Fecha',1031510000);
INSERT INTO international VALUES (245,'WebGUI',5,'Data',1031510000);
INSERT INTO international VALUES (304,'WebGUI',1,'Language',1031514049);
INSERT INTO international VALUES (304,'WebGUI',4,'Idioma',1031510000);
INSERT INTO international VALUES (304,'WebGUI',5,'Lingua',1031510000);
INSERT INTO international VALUES (312,'WebGUI',2,'Geschäftsadresse\nanzeigen?',1031510000);
INSERT INTO international VALUES (80,'WebGUI',3,'Account is aangemaakt!',1031510000);
INSERT INTO international VALUES (306,'WebGUI',1,'Username Binding',1031514049);
INSERT INTO international VALUES (306,'WebGUI',5,'Ligação ao username',1031510000);
INSERT INTO international VALUES (307,'WebGUI',1,'Use default meta tags?',1031514049);
INSERT INTO international VALUES (307,'WebGUI',5,'Usar as meta tags de defeito?',1031510000);
INSERT INTO international VALUES (79,'WebGUI',3,'Kan niet verbinden met LDAP server.',1031510000);
INSERT INTO international VALUES (308,'WebGUI',1,'Edit Profile Settings',1031514049);
INSERT INTO international VALUES (308,'WebGUI',5,'Modificar as preferências do perfil',1031510000);
INSERT INTO international VALUES (309,'WebGUI',1,'Allow real name?',1031514049);
INSERT INTO international VALUES (309,'WebGUI',5,'Permitir o nome real?',1031510000);
INSERT INTO international VALUES (311,'WebGUI',2,'Privatadresse\nanzeigen?',1031510000);
INSERT INTO international VALUES (78,'WebGUI',3,'De wachtwoorden waren niet gelijk. Probeer opnieuw.',1031510000);
INSERT INTO international VALUES (310,'WebGUI',1,'Allow extra contact information?',1031514049);
INSERT INTO international VALUES (310,'WebGUI',5,'Permitir informação extra de contacto?',1031510000);
INSERT INTO international VALUES (311,'WebGUI',1,'Allow home information?',1031514049);
INSERT INTO international VALUES (311,'WebGUI',5,'Permitir informação de casa?',1031510000);
INSERT INTO international VALUES (309,'WebGUI',2,'Name anzeigen?',1031510000);
INSERT INTO international VALUES (312,'WebGUI',1,'Allow business information?',1031514049);
INSERT INTO international VALUES (312,'WebGUI',5,'Permitir informação do emprego?',1031510000);
INSERT INTO international VALUES (313,'WebGUI',1,'Allow miscellaneous information?',1031514049);
INSERT INTO international VALUES (313,'WebGUI',5,'Permitir informaçao mista?',1031510000);
INSERT INTO international VALUES (314,'WebGUI',1,'First Name',1031514049);
INSERT INTO international VALUES (314,'WebGUI',5,'Nome',1031510000);
INSERT INTO international VALUES (77,'WebGUI',3,'Deze account naam wordt al gebruikt door een andere gebruiker van dit systeem. Probeer een andere naam. We hebben de volgende suggesties:',1031510000);
INSERT INTO international VALUES (315,'WebGUI',1,'Middle Name',1031514049);
INSERT INTO international VALUES (315,'WebGUI',5,'segundo(s) nome(s)',1031510000);
INSERT INTO international VALUES (316,'WebGUI',1,'Last Name',1031514049);
INSERT INTO international VALUES (316,'WebGUI',5,'Apelido',1031510000);
INSERT INTO international VALUES (76,'WebGUI',3,'Dat email adresis niet in onze database aanwezig.',1031510000);
INSERT INTO international VALUES (317,'WebGUI',1,'<a href=\"http://www.icq.com\">ICQ</a> UIN',1031514049);
INSERT INTO international VALUES (317,'WebGUI',5,'\"<a href=\"\"http://www.icq.com\"\">ICQ</a> UIN\"',1031510000);
INSERT INTO international VALUES (75,'WebGUI',3,'Uw account informatie is naar uw email adres verzonden.',1031510000);
INSERT INTO international VALUES (318,'WebGUI',1,'<a href=\"http://www.aol.com/aim/homenew.adp\">AIM</a> Id',1031514049);
INSERT INTO international VALUES (318,'WebGUI',5,'\"<a href=\"\"http://www.aol.com/aim/homenew.adp\"\">AIM</a> Id\"',1031510000);
INSERT INTO international VALUES (310,'WebGUI',2,'Kontaktinformationen anzeigen?',1031510000);
INSERT INTO international VALUES (566,'WebGUI',6,'Redigera Timeout',1031510000);
INSERT INTO international VALUES (74,'WebGUI',3,'Account informatie',1031510000);
INSERT INTO international VALUES (319,'WebGUI',1,'<a href=\"http://messenger.msn.com/\">MSN Messenger</a> Id',1031514049);
INSERT INTO international VALUES (319,'WebGUI',5,'\"<a href=\"\"http://messenger.msn.com/\"\">MSN Messenger</a> Id\"',1031510000);
INSERT INTO international VALUES (72,'WebGUI',3,'Terugvinden',1031510000);
INSERT INTO international VALUES (73,'WebGUI',3,'Log in.',1031510000);
INSERT INTO international VALUES (320,'WebGUI',1,'<a href=\"http://messenger.yahoo.com/\">Yahoo! Messenger</a> Id',1031514049);
INSERT INTO international VALUES (320,'WebGUI',5,'\"<a href=\"\"http://messenger.yahoo.com/\"\">Yahoo! Messenger</a> Id\"',1031510000);
INSERT INTO international VALUES (321,'WebGUI',1,'Cell Phone',1031514049);
INSERT INTO international VALUES (321,'WebGUI',5,'Telemóvel',1031510000);
INSERT INTO international VALUES (71,'WebGUI',3,'Wachtwoord terugvinden',1031510000);
INSERT INTO international VALUES (322,'WebGUI',1,'Pager',1031514049);
INSERT INTO international VALUES (322,'WebGUI',5,'Pager',1031510000);
INSERT INTO international VALUES (70,'WebGUI',3,'Fout',1031510000);
INSERT INTO international VALUES (323,'WebGUI',1,'Home Address',1031514049);
INSERT INTO international VALUES (323,'WebGUI',5,'Morada (de casa)',1031510000);
INSERT INTO international VALUES (307,'WebGUI',2,'Standard Meta\nTags benutzen?',1031510000);
INSERT INTO international VALUES (324,'WebGUI',1,'Home City',1031514049);
INSERT INTO international VALUES (324,'WebGUI',5,'Cidade (de casa)',1031510000);
INSERT INTO international VALUES (308,'WebGUI',2,'Profil\nbearbeiten',1031510000);
INSERT INTO international VALUES (325,'WebGUI',1,'Home State',1031514049);
INSERT INTO international VALUES (325,'WebGUI',5,'Concelho (de casa)',1031510000);
INSERT INTO international VALUES (69,'WebGUI',3,'Vraag uw systeembeheerder om assistentie.',1031510000);
INSERT INTO international VALUES (326,'WebGUI',1,'Home Zip Code',1031514049);
INSERT INTO international VALUES (326,'WebGUI',5,'Código postal (de casa)',1031510000);
INSERT INTO international VALUES (327,'WebGUI',1,'Home Country',1031514049);
INSERT INTO international VALUES (327,'WebGUI',5,'País (de casa)',1031510000);
INSERT INTO international VALUES (328,'WebGUI',1,'Home Phone',1031514049);
INSERT INTO international VALUES (328,'WebGUI',5,'Telefone (de casa)',1031510000);
INSERT INTO international VALUES (329,'WebGUI',1,'Work Address',1031514049);
INSERT INTO international VALUES (329,'WebGUI',5,'Morada (do emprego)',1031510000);
INSERT INTO international VALUES (306,'WebGUI',2,'Benutze LDAP\nBenutzername',1031510000);
INSERT INTO international VALUES (330,'WebGUI',1,'Work City',1031514049);
INSERT INTO international VALUES (330,'WebGUI',5,'Cidade (do emprego)',1031510000);
INSERT INTO international VALUES (68,'WebGUI',3,'De account informatie is niet geldig. Het account bestaat niet of de gebruikersnaam/wachtwoord was fout.',1031510000);
INSERT INTO international VALUES (331,'WebGUI',1,'Work State',1031514049);
INSERT INTO international VALUES (331,'WebGUI',5,'Concelho (do emprego)',1031510000);
INSERT INTO international VALUES (239,'WebGUI',2,'Datum:',1031510000);
INSERT INTO international VALUES (332,'WebGUI',1,'Work Zip Code',1031514049);
INSERT INTO international VALUES (332,'WebGUI',5,'Código postal (do emprego)',1031510000);
INSERT INTO international VALUES (67,'WebGUI',3,'Creëer een nieuw account',1031510000);
INSERT INTO international VALUES (333,'WebGUI',1,'Work Country',1031514049);
INSERT INTO international VALUES (333,'WebGUI',5,'País (do emprego)',1031510000);
INSERT INTO international VALUES (334,'WebGUI',1,'Work Phone',1031514049);
INSERT INTO international VALUES (334,'WebGUI',5,'Telefone (do emprego)',1031510000);
INSERT INTO international VALUES (66,'WebGUI',3,'Log in',1031510000);
INSERT INTO international VALUES (335,'WebGUI',1,'Gender',1031514049);
INSERT INTO international VALUES (335,'WebGUI',5,'Sexo',1031510000);
INSERT INTO international VALUES (244,'WebGUI',2,'Autor',1031510000);
INSERT INTO international VALUES (336,'WebGUI',1,'Birth Date',1031514049);
INSERT INTO international VALUES (336,'WebGUI',5,'Data de nascimento',1031510000);
INSERT INTO international VALUES (65,'WebGUI',3,'Deaktiveer mijn account voorgoed.',1031510000);
INSERT INTO international VALUES (337,'WebGUI',1,'Homepage URL',1031514049);
INSERT INTO international VALUES (337,'WebGUI',5,'Endereço da Homepage',1031510000);
INSERT INTO international VALUES (338,'WebGUI',1,'Edit Profile',1031514049);
INSERT INTO international VALUES (338,'WebGUI',5,'Modificar perfil',1031510000);
INSERT INTO international VALUES (64,'WebGUI',3,'Log uit.',1031510000);
INSERT INTO international VALUES (339,'WebGUI',1,'Male',1031514049);
INSERT INTO international VALUES (339,'WebGUI',5,'Masculino',1031510000);
INSERT INTO international VALUES (240,'WebGUI',2,'Beitrags ID:',1031510000);
INSERT INTO international VALUES (340,'WebGUI',1,'Female',1031514049);
INSERT INTO international VALUES (340,'WebGUI',5,'Feminino',1031510000);
INSERT INTO international VALUES (63,'WebGUI',3,'Zet beheermode aan',1031510000);
INSERT INTO international VALUES (341,'WebGUI',1,'Edit profile.',1031514049);
INSERT INTO international VALUES (341,'WebGUI',5,'Modificar o perfil.',1031510000);
INSERT INTO international VALUES (245,'WebGUI',2,'Datum',1031510000);
INSERT INTO international VALUES (62,'WebGUI',3,'Bewaar',1031510000);
INSERT INTO international VALUES (342,'WebGUI',1,'Edit account information.',1031514049);
INSERT INTO international VALUES (342,'WebGUI',5,'Modificar as informações da conta.',1031510000);
INSERT INTO international VALUES (304,'WebGUI',2,'Sprache',1031510000);
INSERT INTO international VALUES (343,'WebGUI',1,'View profile.',1031514049);
INSERT INTO international VALUES (343,'WebGUI',5,'Ver perfil.',1031510000);
INSERT INTO international VALUES (351,'WebGUI',1,'Message',1031514049);
INSERT INTO international VALUES (468,'WebGUI',10,'Rediger bruger profil kategori',1031510000);
INSERT INTO international VALUES (61,'WebGUI',3,'Account informatie bijwerken',1031510000);
INSERT INTO international VALUES (345,'WebGUI',1,'Not A Member',1031514049);
INSERT INTO international VALUES (345,'WebGUI',5,'Não é membro',1031510000);
INSERT INTO international VALUES (233,'WebGUI',2,'(eom)',1031510000);
INSERT INTO international VALUES (234,'WebGUI',2,'Antworten...',1031510000);
INSERT INTO international VALUES (346,'WebGUI',1,'This user is no longer a member of our site. We have no further information about this user.',1031514049);
INSERT INTO international VALUES (346,'WebGUI',5,'Esse utilizador já não é membro do site. Não existe mais informação.',1031510000);
INSERT INTO international VALUES (237,'WebGUI',2,'Betreff:',1031510000);
INSERT INTO international VALUES (347,'WebGUI',1,'View Profile For',1031514049);
INSERT INTO international VALUES (347,'WebGUI',5,'Ver o perfil de',1031510000);
INSERT INTO international VALUES (60,'WebGUI',3,'Weet u zeker dat u uw account wilt deaktiveren? Als u doorgaat gaat alle account informatie voorgoed verloren.',1031510000);
INSERT INTO international VALUES (348,'WebGUI',1,'Name',1031514049);
INSERT INTO international VALUES (348,'WebGUI',5,'Nome',1031510000);
INSERT INTO international VALUES (349,'WebGUI',1,'Latest version available',1031514049);
INSERT INTO international VALUES (349,'WebGUI',5,'Ultima versão disponível',1031510000);
INSERT INTO international VALUES (59,'WebGUI',3,'Ik ben mijn wachtwoord vergeten.',1031510000);
INSERT INTO international VALUES (350,'WebGUI',1,'Completed',1031514049);
INSERT INTO international VALUES (350,'WebGUI',5,'Completo',1031510000);
INSERT INTO international VALUES (351,'WebGUI',5,'Entrada no log de mensagens',1031510000);
INSERT INTO international VALUES (58,'WebGUI',3,'Ik heb al een account.',1031510000);
INSERT INTO international VALUES (352,'WebGUI',1,'Date Of Entry',1031514049);
INSERT INTO international VALUES (352,'WebGUI',5,'Data de entrada',1031510000);
INSERT INTO international VALUES (471,'WebGUI',6,'Redigera Användar Profil Attribut',1031510000);
INSERT INTO international VALUES (353,'WebGUI',5,'Actualmente não tem entradas no log de mensagens.',1031510000);
INSERT INTO international VALUES (471,'WebGUI',1,'Edit User Profile Field',1031514049);
INSERT INTO international VALUES (354,'WebGUI',5,'Ver o log das mensagens.',1031510000);
INSERT INTO international VALUES (57,'WebGUI',3,'Dit is alleen nodig als er functies gebruikt worden die email nodig hebben.',1031510000);
INSERT INTO international VALUES (355,'WebGUI',1,'Default',1031514049);
INSERT INTO international VALUES (355,'WebGUI',5,'Por defeito',1031510000);
INSERT INTO international VALUES (356,'WebGUI',1,'Template',1031514049);
INSERT INTO international VALUES (357,'WebGUI',1,'News',1031514049);
INSERT INTO international VALUES (358,'WebGUI',1,'Left Column',1031514049);
INSERT INTO international VALUES (359,'WebGUI',1,'Right Column',1031514049);
INSERT INTO international VALUES (360,'WebGUI',1,'One Over Three',1031514049);
INSERT INTO international VALUES (361,'WebGUI',1,'Three Over One',1031514049);
INSERT INTO international VALUES (362,'WebGUI',1,'SideBySide',1031514049);
INSERT INTO international VALUES (363,'WebGUI',1,'Template Position',1031514049);
INSERT INTO international VALUES (364,'WebGUI',1,'Search',1031514049);
INSERT INTO international VALUES (365,'WebGUI',1,'Search results...',1031514049);
INSERT INTO international VALUES (366,'WebGUI',1,'No  pages were found with content that matched your query.',1031514049);
INSERT INTO international VALUES (368,'WebGUI',1,'Add a new group to this user.',1031514049);
INSERT INTO international VALUES (369,'WebGUI',1,'Expire Date',1031514049);
INSERT INTO international VALUES (370,'WebGUI',1,'Edit Grouping',1031514049);
INSERT INTO international VALUES (371,'WebGUI',1,'Add Grouping',1031514049);
INSERT INTO international VALUES (372,'WebGUI',1,'Edit User\'s Groups',1031514049);
INSERT INTO international VALUES (374,'WebGUI',1,'Manage packages.',1031514049);
INSERT INTO international VALUES (375,'WebGUI',1,'Select Package To Deploy',1031514049);
INSERT INTO international VALUES (376,'WebGUI',1,'Package',1031514049);
INSERT INTO international VALUES (377,'WebGUI',1,'No packages have been defined by your package manager(s) or administrator(s).',1031514049);
INSERT INTO international VALUES (11,'Poll',1,'Vote!',1031514049);
INSERT INTO international VALUES (31,'UserSubmission',1,'Content',1031514049);
INSERT INTO international VALUES (32,'UserSubmission',1,'Image',1031514049);
INSERT INTO international VALUES (33,'UserSubmission',1,'Attachment',1031514049);
INSERT INTO international VALUES (34,'UserSubmission',1,'Convert Carriage Returns',1031514049);
INSERT INTO international VALUES (35,'UserSubmission',1,'Title',1031514049);
INSERT INTO international VALUES (21,'EventsCalendar',1,'Proceed to add event?',1031514049);
INSERT INTO international VALUES (378,'WebGUI',1,'User ID',1031514049);
INSERT INTO international VALUES (379,'WebGUI',1,'Group ID',1031514049);
INSERT INTO international VALUES (380,'WebGUI',1,'Style ID',1031514049);
INSERT INTO international VALUES (381,'WebGUI',1,'WebGUI received a malformed request and was unable to continue. Proprietary characters being passed through a form typically cause this. Please feel free to hit your back button and try again.',1031514049);
INSERT INTO international VALUES (1,'DownloadManager',1,'Download Manager',1031514049);
INSERT INTO international VALUES (1,'EventsCalendar',6,'Fortsätt med att lägga till en händelse?',1031510000);
INSERT INTO international VALUES (3,'DownloadManager',1,'Proceed to add file?',1031514049);
INSERT INTO international VALUES (367,'WebGUI',6,'Bäst före',1031510000);
INSERT INTO international VALUES (5,'DownloadManager',1,'File Title',1031514049);
INSERT INTO international VALUES (6,'DownloadManager',1,'Download File',1031514049);
INSERT INTO international VALUES (7,'DownloadManager',1,'Group to Download',1031514049);
INSERT INTO international VALUES (8,'DownloadManager',1,'Brief Synopsis',1031514049);
INSERT INTO international VALUES (9,'DownloadManager',1,'Edit Download Manager',1031514049);
INSERT INTO international VALUES (10,'DownloadManager',1,'Edit Download',1031514049);
INSERT INTO international VALUES (11,'DownloadManager',1,'Add a new download.',1031514049);
INSERT INTO international VALUES (12,'DownloadManager',1,'Are you certain that you wish to delete this download?',1031514049);
INSERT INTO international VALUES (22,'DownloadManager',1,'Proceed to add download?',1031514049);
INSERT INTO international VALUES (14,'DownloadManager',1,'File',1031514049);
INSERT INTO international VALUES (15,'DownloadManager',1,'Description',1031514049);
INSERT INTO international VALUES (16,'DownloadManager',1,'Date Uploaded',1031514049);
INSERT INTO international VALUES (15,'Article',1,'Right',1031514049);
INSERT INTO international VALUES (16,'Article',1,'Left',1031514049);
INSERT INTO international VALUES (17,'Article',1,'Center',1031514049);
INSERT INTO international VALUES (37,'UserSubmission',1,'Delete',1031514049);
INSERT INTO international VALUES (13,'SQLReport',1,'Convert carriage returns?',1031514049);
INSERT INTO international VALUES (17,'DownloadManager',1,'Alternate Version #1',1031514049);
INSERT INTO international VALUES (18,'DownloadManager',1,'Alternate Version #2',1031514049);
INSERT INTO international VALUES (19,'DownloadManager',1,'You have no files available for download.',1031514049);
INSERT INTO international VALUES (14,'EventsCalendar',1,'Start Date',1031514049);
INSERT INTO international VALUES (15,'EventsCalendar',1,'End Date',1031514049);
INSERT INTO international VALUES (20,'DownloadManager',1,'Paginate After',1031514049);
INSERT INTO international VALUES (14,'SQLReport',1,'Paginate After',1031514049);
INSERT INTO international VALUES (16,'EventsCalendar',1,'Calendar Layout',1031514049);
INSERT INTO international VALUES (17,'EventsCalendar',1,'List',1031514049);
INSERT INTO international VALUES (18,'EventsCalendar',1,'Calendar Month',1031514049);
INSERT INTO international VALUES (19,'EventsCalendar',1,'Paginate After',1031514049);
INSERT INTO international VALUES (383,'WebGUI',1,'Name',1031514049);
INSERT INTO international VALUES (384,'WebGUI',1,'File',1031514049);
INSERT INTO international VALUES (385,'WebGUI',1,'Parameters',1031514049);
INSERT INTO international VALUES (386,'WebGUI',1,'Edit Image',1031514049);
INSERT INTO international VALUES (387,'WebGUI',1,'Uploaded By',1031514049);
INSERT INTO international VALUES (388,'WebGUI',1,'Upload Date',1031514049);
INSERT INTO international VALUES (389,'WebGUI',1,'Image Id',1031514049);
INSERT INTO international VALUES (390,'WebGUI',1,'Displaying Image...',1031514049);
INSERT INTO international VALUES (391,'WebGUI',1,'Delete attached file.',1031514049);
INSERT INTO international VALUES (392,'WebGUI',1,'Are you certain that you wish to delete this image?',1031514049);
INSERT INTO international VALUES (393,'WebGUI',1,'Manage Images',1031514049);
INSERT INTO international VALUES (394,'WebGUI',1,'Manage images.',1031514049);
INSERT INTO international VALUES (395,'WebGUI',1,'Add a new image.',1031514049);
INSERT INTO international VALUES (396,'WebGUI',1,'View Image',1031514049);
INSERT INTO international VALUES (397,'WebGUI',1,'Back to image list.',1031514049);
INSERT INTO international VALUES (398,'WebGUI',1,'Document Type Declaration',1031514049);
INSERT INTO international VALUES (399,'WebGUI',1,'Validate this page.',1031514049);
INSERT INTO international VALUES (400,'WebGUI',1,'Prevent Proxy Caching',1031514049);
INSERT INTO international VALUES (401,'WebGUI',1,'Are you certain you wish to delete this message and all messages under it in this thread?',1031514049);
INSERT INTO international VALUES (565,'WebGUI',1,'Who can moderate?',1031514049);
INSERT INTO international VALUES (22,'MessageBoard',1,'Delete Message',1031514049);
INSERT INTO international VALUES (402,'WebGUI',1,'The message you requested does not exist.',1031514049);
INSERT INTO international VALUES (403,'WebGUI',1,'Prefer not to say.',1031514049);
INSERT INTO international VALUES (405,'WebGUI',1,'Last Page',1031514049);
INSERT INTO international VALUES (406,'WebGUI',1,'Thumbnail Size',1031514049);
INSERT INTO international VALUES (21,'DownloadManager',1,'Display thumbnails?',1031514049);
INSERT INTO international VALUES (407,'WebGUI',1,'Click here to register.',1031514049);
INSERT INTO international VALUES (15,'SQLReport',1,'Preprocess macros on query?',1031514049);
INSERT INTO international VALUES (16,'SQLReport',1,'Debug?',1031514049);
INSERT INTO international VALUES (17,'SQLReport',1,'<b>Debug:</b> Query:',1031514049);
INSERT INTO international VALUES (18,'SQLReport',1,'There were no results for this query.',1031514049);
INSERT INTO international VALUES (231,'WebGUI',2,'Neuen Beitrag\nschreiben...',1031510000);
INSERT INTO international VALUES (238,'WebGUI',2,'Autor:',1031510000);
INSERT INTO international VALUES (230,'WebGUI',2,'Beitrag',1031510000);
INSERT INTO international VALUES (229,'WebGUI',2,'Betreff',1031510000);
INSERT INTO international VALUES (232,'WebGUI',2,'kein Betreff',1031510000);
INSERT INTO international VALUES (175,'WebGUI',2,'Makros\nausführen?',1031510000);
INSERT INTO international VALUES (228,'WebGUI',2,'Beiträge\nbearbeiten ...',1031510000);
INSERT INTO international VALUES (169,'WebGUI',2,'Neuen Benutzer\nhinzufügen',1031510000);
INSERT INTO international VALUES (171,'WebGUI',2,'Bearbeiten mit\nAttributen',1031510000);
INSERT INTO international VALUES (170,'WebGUI',2,'suchen',1031510000);
INSERT INTO international VALUES (174,'WebGUI',2,'Titel\nanzeigen?',1031510000);
INSERT INTO international VALUES (168,'WebGUI',2,'Benutzer\nbearbeiten',1031510000);
INSERT INTO international VALUES (167,'WebGUI',2,'Sind Sie sicher,\ndass sie diesen Benutzer löschen möchten? Die Benutzerinformation geht\ndamit endgültig verloren!',1031510000);
INSERT INTO international VALUES (166,'WebGUI',2,'Connect DN',1031510000);
INSERT INTO international VALUES (165,'WebGUI',2,'LDAP URL',1031510000);
INSERT INTO international VALUES (164,'WebGUI',2,'Authentifizierungsmethode',1031510000);
INSERT INTO international VALUES (163,'WebGUI',2,'Benutzer\nhinzufügen',1031510000);
INSERT INTO international VALUES (162,'WebGUI',2,'Sind Sie sicher,\ndass Sie alle Seiten und Widgets im Mülleimer löschen möchten?',1031510000);
INSERT INTO international VALUES (160,'WebGUI',2,'Erstellungsdatum',1031510000);
INSERT INTO international VALUES (161,'WebGUI',2,'Erstellt von',1031510000);
INSERT INTO international VALUES (158,'WebGUI',2,'Neuen Stil\nhinzufügen',1031510000);
INSERT INTO international VALUES (506,'WebGUI',1,'Manage Templates',1031514049);
INSERT INTO international VALUES (159,'WebGUI',2,'Ausstehende\nBeiträge',1031510000);
INSERT INTO international VALUES (157,'WebGUI',2,'Stile',1031510000);
INSERT INTO international VALUES (156,'WebGUI',2,'Stil\nbearbeiten',1031510000);
INSERT INTO international VALUES (155,'WebGUI',2,'Sind Sie sicher,\ndass Sie diesen Stil löschen und alle Seiten die diesen Stil benutzen in\nden Stil \"Fail Safe\" überführen wollen?',1031510000);
INSERT INTO international VALUES (154,'WebGUI',2,'Style Sheet',1031510000);
INSERT INTO international VALUES (151,'WebGUI',2,'Stil Name',1031510000);
INSERT INTO international VALUES (149,'WebGUI',2,'Benutzer',1031510000);
INSERT INTO international VALUES (146,'WebGUI',2,'Aktive\nSitzungen',1031510000);
INSERT INTO international VALUES (148,'WebGUI',2,'Widgets',1031510000);
INSERT INTO international VALUES (147,'WebGUI',2,'sichtbare\nSeiten',1031510000);
INSERT INTO international VALUES (145,'WebGUI',2,'WebGUI Build\nVersion',1031510000);
INSERT INTO international VALUES (140,'WebGUI',2,'Sonstige\nEinstellungen bearbeiten',1031510000);
INSERT INTO international VALUES (144,'WebGUI',2,'Auswertungen\nanschauen',1031510000);
INSERT INTO international VALUES (141,'WebGUI',2,'\"Nicht gefunden\nSeite\"',1031510000);
INSERT INTO international VALUES (142,'WebGUI',2,'Sitzungs\nZeitüberschreitung',1031510000);
INSERT INTO international VALUES (143,'WebGUI',2,'Einstellungen\nverwalten',1031510000);
INSERT INTO international VALUES (139,'WebGUI',2,'Nein',1031510000);
INSERT INTO international VALUES (138,'WebGUI',2,'Ja',1031510000);
INSERT INTO international VALUES (135,'WebGUI',2,'SMTP Server',1031510000);
INSERT INTO international VALUES (134,'WebGUI',2,'Passwortmeldung\nwiederherstellen',1031510000);
INSERT INTO international VALUES (133,'WebGUI',2,'Maileinstellungen\nbearbeiten',1031510000);
INSERT INTO international VALUES (130,'WebGUI',2,'Maximale\nDateigröße für Anhänge',1031510000);
INSERT INTO international VALUES (125,'WebGUI',2,'Firmenname',1031510000);
INSERT INTO international VALUES (126,'WebGUI',2,'Emailadresse der\nFirma',1031510000);
INSERT INTO international VALUES (127,'WebGUI',2,'Webseite der\nFirma',1031510000);
INSERT INTO international VALUES (124,'WebGUI',2,'Firmeninformationen bearbeiten',1031510000);
INSERT INTO international VALUES (122,'WebGUI',2,'LDAP\nIdentitäts-Name',1031510000);
INSERT INTO international VALUES (123,'WebGUI',2,'LDAP Passwort\nName',1031510000);
INSERT INTO international VALUES (121,'WebGUI',2,'LDAP Identität\n(Standard)',1031510000);
INSERT INTO international VALUES (119,'WebGUI',2,'Authentifizierungsmethode (Standard)',1031510000);
INSERT INTO international VALUES (120,'WebGUI',2,'LDAP URL\n(Standard)',1031510000);
INSERT INTO international VALUES (117,'WebGUI',2,'Authentifizierungseinstellungen bearbeiten',1031510000);
INSERT INTO international VALUES (118,'WebGUI',2,'anonyme\nRegistrierung',1031510000);
INSERT INTO international VALUES (115,'WebGUI',2,'Kann jeder\nbearbeiten?',1031510000);
INSERT INTO international VALUES (116,'WebGUI',2,'Rechte an alle\nnachfolgenden Seiten weitergeben.',1031510000);
INSERT INTO international VALUES (114,'WebGUI',2,'Kann jeder\nanschauen?',1031510000);
INSERT INTO international VALUES (111,'WebGUI',2,'Gruppe',1031510000);
INSERT INTO international VALUES (113,'WebGUI',2,'Gruppe kann\nbearbeiten?',1031510000);
INSERT INTO international VALUES (110,'WebGUI',2,'Besitzer kann\nbearbeiten?',1031510000);
INSERT INTO international VALUES (112,'WebGUI',2,'Gruppe kann\nanschauen?',1031510000);
INSERT INTO international VALUES (108,'WebGUI',2,'Besitzer',1031510000);
INSERT INTO international VALUES (109,'WebGUI',2,'Besitzer kann\nanschauen?',1031510000);
INSERT INTO international VALUES (107,'WebGUI',2,'Rechte',1031510000);
INSERT INTO international VALUES (105,'WebGUI',2,'Stil',1031510000);
INSERT INTO international VALUES (106,'WebGUI',2,'Stil an alle\nnachfolgenden Seiten weitergeben.',1031510000);
INSERT INTO international VALUES (104,'WebGUI',2,'URL der Seite',1031510000);
INSERT INTO international VALUES (103,'WebGUI',2,'Seitenspezifikation',1031510000);
INSERT INTO international VALUES (102,'WebGUI',2,'Seite\nbearbeiten',1031510000);
INSERT INTO international VALUES (100,'WebGUI',2,'Meta Tags',1031510000);
INSERT INTO international VALUES (353,'WebGUI',1,'You have no messages in your Inbox at this time.',1031514049);
INSERT INTO international VALUES (101,'WebGUI',2,'Sind Sie sicher,\ndass Sie diese Seite und ihren kompletten Inhalt darunter löschen\nmöchten?',1031510000);
INSERT INTO international VALUES (99,'WebGUI',2,'Titel',1031510000);
INSERT INTO international VALUES (93,'WebGUI',2,'Hilfe',1031510000);
INSERT INTO international VALUES (94,'WebGUI',2,'Siehe auch',1031510000);
INSERT INTO international VALUES (92,'WebGUI',2,'Nächste Seite',1031510000);
INSERT INTO international VALUES (95,'WebGUI',2,'Hilfe',1031510000);
INSERT INTO international VALUES (91,'WebGUI',2,'Vorherige Seite',1031510000);
INSERT INTO international VALUES (89,'WebGUI',2,'Gruppen',1031510000);
INSERT INTO international VALUES (90,'WebGUI',2,'Neue Gruppe\nhinzufügen',1031510000);
INSERT INTO international VALUES (88,'WebGUI',2,'Benutzer in dieser\nGruppe',1031510000);
INSERT INTO international VALUES (87,'WebGUI',2,'Gruppe\nbearbeiten',1031510000);
INSERT INTO international VALUES (86,'WebGUI',2,'Sind Sie sicher,\ndass Sie diese Gruppe löschen möchten? Denken Sie daran, dass diese Gruppe\nund die zugehörige Rechtesstruktur endgültig gelöscht wird.',1031510000);
INSERT INTO international VALUES (85,'WebGUI',2,'Beschreibung',1031510000);
INSERT INTO international VALUES (84,'WebGUI',2,'Gruppenname',1031510000);
INSERT INTO international VALUES (82,'WebGUI',2,'Administrative\nFunktionen ...',1031510000);
INSERT INTO international VALUES (81,'WebGUI',2,'Benutzerkonto\nwurde aktualisiert',1031510000);
INSERT INTO international VALUES (80,'WebGUI',2,'Benutzerkonto\nwurde angelegt',1031510000);
INSERT INTO international VALUES (78,'WebGUI',2,'Die Passworte\nunterscheiden sich. Bitte versuchen Sie es noch einmal.',1031510000);
INSERT INTO international VALUES (79,'WebGUI',2,'Verbindung zum\nLDAP-Server konnte nicht hergestellt werden.',1031510000);
INSERT INTO international VALUES (77,'WebGUI',2,'Ein anderes\nMitglied dieser Seiten benutzt bereits diesen Namen. Bitte wählen Sie einen\nanderen Benutzernamen. Hier sind einige Vorschläge:',1031510000);
INSERT INTO international VALUES (74,'WebGUI',2,'Benutzerkonteninformation',1031510000);
INSERT INTO international VALUES (73,'WebGUI',2,'Anmelden',1031510000);
INSERT INTO international VALUES (76,'WebGUI',2,'Ihre Emailadresse\nist nicht in unserer Datenbank.',1031510000);
INSERT INTO international VALUES (75,'WebGUI',2,'Ihre\nBenutzerkonteninformation wurde an Ihre Emailadresse geschickt',1031510000);
INSERT INTO international VALUES (72,'WebGUI',2,'wiederherstellen',1031510000);
INSERT INTO international VALUES (71,'WebGUI',2,'Passwort\nwiederherstellen',1031510000);
INSERT INTO international VALUES (70,'WebGUI',2,'Fehler',1031510000);
INSERT INTO international VALUES (69,'WebGUI',2,'Bitten Sie Ihren\nSystemadministrator um Hilfe.',1031510000);
INSERT INTO international VALUES (66,'WebGUI',2,'Anmelden',1031510000);
INSERT INTO international VALUES (67,'WebGUI',2,'Neues\nBenutzerkonto einrichten',1031510000);
INSERT INTO international VALUES (408,'WebGUI',1,'Manage Roots',1031514049);
INSERT INTO international VALUES (409,'WebGUI',1,'Add a new root.',1031514049);
INSERT INTO international VALUES (410,'WebGUI',1,'Manage roots.',1031514049);
INSERT INTO international VALUES (411,'WebGUI',1,'Menu Title',1031514049);
INSERT INTO international VALUES (412,'WebGUI',1,'Synopsis',1031514049);
INSERT INTO international VALUES (9,'SiteMap',1,'Display synopsis?',1031514049);
INSERT INTO international VALUES (18,'Article',1,'Allow discussion?',1031514049);
INSERT INTO international VALUES (10,'Product',1,'Price',1031514049);
INSERT INTO international VALUES (22,'Article',1,'Author',1031514049);
INSERT INTO international VALUES (23,'Article',1,'Date',1031514049);
INSERT INTO international VALUES (24,'Article',1,'Post Response',1031514049);
INSERT INTO international VALUES (58,'UserSubmission',1,'Previous Submission',1031514049);
INSERT INTO international VALUES (27,'Article',1,'Back To Article',1031514049);
INSERT INTO international VALUES (28,'Article',1,'View Responses',1031514049);
INSERT INTO international VALUES (55,'Product',1,'Add a benefit.',1031514049);
INSERT INTO international VALUES (416,'WebGUI',1,'<h1>Problem With Request</h1>We have encountered a problem with your request. Please use your back button and try again. If this problem persists, please contact us with what you were trying to do and the time and date of the problem.',1031514049);
INSERT INTO international VALUES (417,'WebGUI',1,'<h1>Security Violation</h1>You attempted to access a wobject not associated with this page. This incident has been reported.',1031514049);
INSERT INTO international VALUES (418,'WebGUI',1,'Filter Contributed HTML',1031514049);
INSERT INTO international VALUES (419,'WebGUI',1,'Remove all tags.',1031514049);
INSERT INTO international VALUES (420,'WebGUI',1,'Leave as is.',1031514049);
INSERT INTO international VALUES (421,'WebGUI',1,'Remove all but basic formating.',1031514049);
INSERT INTO international VALUES (422,'WebGUI',1,'<h1>Login Failed</h1>The information supplied does not match the account.',1031514049);
INSERT INTO international VALUES (423,'WebGUI',1,'View active sessions.',1031514049);
INSERT INTO international VALUES (424,'WebGUI',1,'View login history.',1031514049);
INSERT INTO international VALUES (425,'WebGUI',1,'Active Sessions',1031514049);
INSERT INTO international VALUES (426,'WebGUI',1,'Login History',1031514049);
INSERT INTO international VALUES (427,'WebGUI',1,'Styles',1031514049);
INSERT INTO international VALUES (428,'WebGUI',1,'User (ID)',1031514049);
INSERT INTO international VALUES (429,'WebGUI',1,'Login Time',1031514049);
INSERT INTO international VALUES (430,'WebGUI',1,'Last Page View',1031514049);
INSERT INTO international VALUES (431,'WebGUI',1,'IP Address',1031514049);
INSERT INTO international VALUES (432,'WebGUI',1,'Expires',1031514049);
INSERT INTO international VALUES (433,'WebGUI',1,'User Agent',1031514049);
INSERT INTO international VALUES (434,'WebGUI',1,'Status',1031514049);
INSERT INTO international VALUES (435,'WebGUI',1,'Session Signature',1031514049);
INSERT INTO international VALUES (436,'WebGUI',1,'Kill Session',1031514049);
INSERT INTO international VALUES (437,'WebGUI',1,'Statistics',1031514049);
INSERT INTO international VALUES (438,'WebGUI',1,'Your Name',1031514049);
INSERT INTO international VALUES (68,'WebGUI',2,'Die\nBenutzerkontoinformationen die Sie eingegeben haben, sind ungültig.\nEntweder existiert das Konto nicht, oder die Kombination aus Benutzername\nund Passwort ist falsch.',1031510000);
INSERT INTO international VALUES (65,'WebGUI',2,'Benutzerkonto\nendgültig deaktivieren',1031510000);
INSERT INTO international VALUES (62,'WebGUI',2,'sichern',1031510000);
INSERT INTO international VALUES (64,'WebGUI',2,'Abmelden',1031510000);
INSERT INTO international VALUES (63,'WebGUI',2,'Administrationsmodus einschalten',1031510000);
INSERT INTO international VALUES (61,'WebGUI',2,'Benutzerkontendetails aktualisieren',1031510000);
INSERT INTO international VALUES (60,'WebGUI',2,'Sind Sie sicher,\ndass Sie dieses Benutzerkonto deaktivieren möchten? Wenn Sie fortfahren\nsind Ihre Konteninformationen endgültig verloren.',1031510000);
INSERT INTO international VALUES (1,'SyndicatedContent',6,'URL till RSS filen',1031510000);
INSERT INTO international VALUES (59,'WebGUI',2,'Ich habe mein\nPasswort vergessen',1031510000);
INSERT INTO international VALUES (58,'WebGUI',2,'Ich besitze\nbereits ein Benutzerkonto.',1031510000);
INSERT INTO international VALUES (59,'Product',1,'Name',1031514049);
INSERT INTO international VALUES (60,'Product',1,'Template',1031514049);
INSERT INTO international VALUES (56,'WebGUI',2,'Email Adresse',1031510000);
INSERT INTO international VALUES (57,'WebGUI',2,'(Dies ist nur\nnotwendig, wenn Sie Eigenschaften benutzen möchten die eine Emailadresse\nvoraussetzen)',1031510000);
INSERT INTO international VALUES (55,'WebGUI',2,'Passwort\n(bestätigen)',1031510000);
INSERT INTO international VALUES (54,'WebGUI',2,'Benutzerkonto\nanlegen',1031510000);
INSERT INTO international VALUES (7,'Article',10,'Titel på henvisning',1031510000);
INSERT INTO international VALUES (53,'WebGUI',2,'Druckerbares\nFormat',1031510000);
INSERT INTO international VALUES (51,'WebGUI',2,'Passwort',1031510000);
INSERT INTO international VALUES (49,'WebGUI',2,'Hier können Sie\nsich <a href=\"^;?op=logout\">abmelden</a>.',1031510000);
INSERT INTO international VALUES (52,'WebGUI',2,'Anmelden',1031510000);
INSERT INTO international VALUES (50,'WebGUI',2,'Benutzername',1031510000);
INSERT INTO international VALUES (48,'WebGUI',2,'Hallo',1031510000);
INSERT INTO international VALUES (47,'WebGUI',2,'Startseite',1031510000);
INSERT INTO international VALUES (46,'WebGUI',2,'Mein\nBenutzerkonto',1031510000);
INSERT INTO international VALUES (45,'WebGUI',2,'Nein, ich habe\neinen Fehler gemacht.',1031510000);
INSERT INTO international VALUES (44,'WebGUI',2,'Ja, ich bin mir\nsicher.',1031510000);
INSERT INTO international VALUES (43,'WebGUI',2,'Sind Sie sicher,\ndass Sie diesen Inhalt löschen möchten?',1031510000);
INSERT INTO international VALUES (42,'WebGUI',2,'Bitte bestätigen\nSie',1031510000);
INSERT INTO international VALUES (41,'WebGUI',2,'Sie versuchen\neinen notwendigen Bestandteil des Systems zu löschen. WebGUI wird nach\ndieser Aktion möglicherweise nicht mehr richtig funktionieren.',1031510000);
INSERT INTO international VALUES (39,'WebGUI',2,'Sie sind nicht\nberechtigt, diese Seite anzuschauen.',1031510000);
INSERT INTO international VALUES (40,'WebGUI',2,'Notwendiger\nBestandteil',1031510000);
INSERT INTO international VALUES (38,'WebGUI',2,'Sie sind nicht\nberechtigt, diese Aktion auszuführen. ^a(Melden Sie sich bitte mit einem\nBenutzernamen an);, der über ausreichende Rechte verfügt.',1031510000);
INSERT INTO international VALUES (2,'LinkList',6,'Avstånd mellan rader',1031510000);
INSERT INTO international VALUES (37,'WebGUI',2,'Zugriff\nverweigert!',1031510000);
INSERT INTO international VALUES (2,'SQLReport',6,'Lägg till SQL rapport',1031510000);
INSERT INTO international VALUES (37,'UserSubmission',2,'Löschen',1031510000);
INSERT INTO international VALUES (36,'WebGUI',2,'Um diese Funktion\nausführen zu können, müssen Sie Administrator sein. Eine der folgenden\nPersonen kann Sie zum Administrator machen:',1031510000);
INSERT INTO international VALUES (35,'WebGUI',2,'Administrative\nFunktion',1031510000);
INSERT INTO international VALUES (35,'UserSubmission',2,'Titel',1031510000);
INSERT INTO international VALUES (34,'WebGUI',2,'Datum setzen',1031510000);
INSERT INTO international VALUES (34,'UserSubmission',2,'Carriage\nReturn beachten?',1031510000);
INSERT INTO international VALUES (33,'WebGUI',2,'Samstag',1031510000);
INSERT INTO international VALUES (32,'WebGUI',2,'Freitag',1031510000);
INSERT INTO international VALUES (33,'UserSubmission',2,'Anhang',1031510000);
INSERT INTO international VALUES (32,'UserSubmission',2,'Grafik',1031510000);
INSERT INTO international VALUES (31,'WebGUI',2,'Donnerstag',1031510000);
INSERT INTO international VALUES (30,'WebGUI',2,'Mittwoch',1031510000);
INSERT INTO international VALUES (31,'UserSubmission',2,'Inhalt',1031510000);
INSERT INTO international VALUES (29,'WebGUI',2,'Dienstag',1031510000);
INSERT INTO international VALUES (28,'WebGUI',2,'Montag',1031510000);
INSERT INTO international VALUES (29,'UserSubmission',2,'Benutzer\nBeitragssystem',1031510000);
INSERT INTO international VALUES (28,'UserSubmission',2,'Zurück zur\nBeitragsliste',1031510000);
INSERT INTO international VALUES (28,'Article',2,'Kommentare\nanschauen',1031510000);
INSERT INTO international VALUES (27,'WebGUI',2,'Sonntag',1031510000);
INSERT INTO international VALUES (27,'UserSubmission',2,'Bearbeiten',1031510000);
INSERT INTO international VALUES (27,'Article',2,'Zurück zum\nArtikel',1031510000);
INSERT INTO international VALUES (26,'WebGUI',2,'Dezember',1031510000);
INSERT INTO international VALUES (2,'WebGUI',6,'Sida',1031510000);
INSERT INTO international VALUES (574,'WebGUI',2,'Verbieten',1031510000);
INSERT INTO international VALUES (25,'WebGUI',2,'November',1031510000);
INSERT INTO international VALUES (573,'WebGUI',2,'Ausstehend\nverlassen',1031510000);
INSERT INTO international VALUES (24,'WebGUI',2,'Oktober',1031510000);
INSERT INTO international VALUES (24,'Article',2,'Kommentar\nschreiben',1031510000);
INSERT INTO international VALUES (1,'Article',6,'Artikel',1031510000);
INSERT INTO international VALUES (572,'WebGUI',2,'Erlauben',1031510000);
INSERT INTO international VALUES (23,'WebGUI',2,'September',1031510000);
INSERT INTO international VALUES (23,'UserSubmission',2,'Erstellungsdatum:',1031510000);
INSERT INTO international VALUES (3,'FAQ',6,'Lägg till F.A.Q.',1031510000);
INSERT INTO international VALUES (23,'Article',2,'Datum',1031510000);
INSERT INTO international VALUES (22,'WebGUI',2,'August',1031510000);
INSERT INTO international VALUES (22,'UserSubmission',2,'Erstellt\nvon:',1031510000);
INSERT INTO international VALUES (22,'Article',2,'Autor',1031510000);
INSERT INTO international VALUES (22,'MessageBoard',2,'Beitrag\nlöschen',1031510000);
INSERT INTO international VALUES (3,'UserSubmission',6,'Du har ett nytt medelande att validera.',1031510000);
INSERT INTO international VALUES (21,'WebGUI',2,'Juli',1031510000);
INSERT INTO international VALUES (21,'UserSubmission',2,'Erstellt\nvon',1031510000);
INSERT INTO international VALUES (565,'WebGUI',2,'Wer kann\nmoderieren?',1031510000);
INSERT INTO international VALUES (4,'EventsCalendar',6,'Inträffar endast en gång.',1031510000);
INSERT INTO international VALUES (21,'DownloadManager',2,'Vorschaubilder anzeigen?',1031510000);
INSERT INTO international VALUES (20,'WebGUI',2,'Juni',1031510000);
INSERT INTO international VALUES (20,'UserSubmission',2,'Neuen\nBeitrag schreiben',1031510000);
INSERT INTO international VALUES (20,'MessageBoard',2,'Letzte\nAntwort',1031510000);
INSERT INTO international VALUES (4,'Item',6,'Post',1031510000);
INSERT INTO international VALUES (4,'SQLReport',6,'Query',1031510000);
INSERT INTO international VALUES (20,'DownloadManager',2,'Später\nmit Seitenzahlen versehen',1031510000);
INSERT INTO international VALUES (19,'WebGUI',2,'Mai',1031510000);
INSERT INTO international VALUES (19,'UserSubmission',2,'Beitrag\nbearbeiten',1031510000);
INSERT INTO international VALUES (19,'MessageBoard',2,'Antworten',1031510000);
INSERT INTO international VALUES (5,'FAQ',6,'Fråga',1031510000);
INSERT INTO international VALUES (19,'EventsCalendar',2,'Später mit\nSeitenzahlen versehen',1031510000);
INSERT INTO international VALUES (19,'DownloadManager',2,'Sie\nbesitzen keine Dateien, die zum Download bereitstehen.',1031510000);
INSERT INTO international VALUES (18,'WebGUI',2,'April',1031510000);
INSERT INTO international VALUES (18,'UserSubmission',2,'Benutzer\nBeitragssystem bearbeiten',1031510000);
INSERT INTO international VALUES (18,'SQLReport',2,'Diese Abfrage\nliefert keine Ergebnisse.',1031510000);
INSERT INTO international VALUES (18,'MessageBoard',2,'Diskussion\nbegonnen',1031510000);
INSERT INTO international VALUES (18,'DownloadManager',2,'Alternative #2',1031510000);
INSERT INTO international VALUES (17,'WebGUI',2,'März',1031510000);
INSERT INTO international VALUES (18,'EventsCalendar',2,'Kalendermonat',1031510000);
INSERT INTO international VALUES (18,'Article',2,'Diskussion\nerlauben?',1031510000);
INSERT INTO international VALUES (17,'UserSubmission',2,'Sind Sie\nsicher, dass Sie diesen Beitrag löschen wollen?',1031510000);
INSERT INTO international VALUES (17,'SQLReport',2,'<b>Debug:</b>\nAbfrage:',1031510000);
INSERT INTO international VALUES (17,'MessageBoard',2,'Neuen\nBeitrag schreiben',1031510000);
INSERT INTO international VALUES (17,'EventsCalendar',2,'Liste',1031510000);
INSERT INTO international VALUES (17,'DownloadManager',2,'Alternative #1',1031510000);
INSERT INTO international VALUES (16,'WebGUI',2,'Februar',1031510000);
INSERT INTO international VALUES (16,'UserSubmission',2,'Ohne\nTitel',1031510000);
INSERT INTO international VALUES (48,'Product',1,'Are you certain you wish to delete this benefit? It cannot be recovered once it has been deleted.',1031514049);
INSERT INTO international VALUES (16,'DownloadManager',2,'Upload\nDatum',1031510000);
INSERT INTO international VALUES (16,'EventsCalendar',2,'Kalender\nLayout',1031510000);
INSERT INTO international VALUES (16,'SQLReport',2,'debuggen?',1031510000);
INSERT INTO international VALUES (16,'MessageBoard',2,'Datum',1031510000);
INSERT INTO international VALUES (17,'Article',2,'Zentrum',1031510000);
INSERT INTO international VALUES (15,'UserSubmission',2,'Bearbeiten/Löschen',1031510000);
INSERT INTO international VALUES (15,'WebGUI',2,'Januar',1031510000);
INSERT INTO international VALUES (16,'Article',2,'Links',1031510000);
INSERT INTO international VALUES (15,'SQLReport',2,'Sollen die\nMakros in der Abfrage vorverarbeitet werden?',1031510000);
INSERT INTO international VALUES (15,'MessageBoard',2,'Autor',1031510000);
INSERT INTO international VALUES (15,'EventsCalendar',2,'Ende\nDatum',1031510000);
INSERT INTO international VALUES (14,'WebGUI',2,'Ausstehende\nBeiträge anschauen',1031510000);
INSERT INTO international VALUES (15,'DownloadManager',2,'Beschreibung',1031510000);
INSERT INTO international VALUES (15,'Article',2,'Rechts',1031510000);
INSERT INTO international VALUES (14,'UserSubmission',2,'Status',1031510000);
INSERT INTO international VALUES (14,'SQLReport',2,'Später mit\nSeitenzahlen versehen',1031510000);
INSERT INTO international VALUES (14,'EventsCalendar',2,'Start\nDatum',1031510000);
INSERT INTO international VALUES (14,'DownloadManager',2,'Datei',1031510000);
INSERT INTO international VALUES (14,'Article',2,'Anhang\nherunterladen',1031510000);
INSERT INTO international VALUES (13,'WebGUI',2,'Hilfe anschauen',1031510000);
INSERT INTO international VALUES (13,'UserSubmission',2,'Erstellungsdatum',1031510000);
INSERT INTO international VALUES (13,'SQLReport',2,'Carriage Return\nbeachten?',1031510000);
INSERT INTO international VALUES (439,'WebGUI',1,'Personal Information',1031514049);
INSERT INTO international VALUES (440,'WebGUI',1,'Contact Information',1031514049);
INSERT INTO international VALUES (441,'WebGUI',1,'Email To Pager Gateway',1031514049);
INSERT INTO international VALUES (442,'WebGUI',1,'Work Information',1031514049);
INSERT INTO international VALUES (443,'WebGUI',1,'Home Information',1031514049);
INSERT INTO international VALUES (444,'WebGUI',1,'Demographic Information',1031514049);
INSERT INTO international VALUES (445,'WebGUI',1,'Preferences',1031514049);
INSERT INTO international VALUES (446,'WebGUI',1,'Work Web Site',1031514049);
INSERT INTO international VALUES (447,'WebGUI',1,'Manage page tree.',1031514049);
INSERT INTO international VALUES (448,'WebGUI',1,'Page Tree',1031514049);
INSERT INTO international VALUES (449,'WebGUI',1,'Miscellaneous Information',1031514049);
INSERT INTO international VALUES (450,'WebGUI',1,'Work Name (Company Name)',1031514049);
INSERT INTO international VALUES (451,'WebGUI',1,'is required.',1031514049);
INSERT INTO international VALUES (452,'WebGUI',1,'Please wait...',1031514049);
INSERT INTO international VALUES (453,'WebGUI',1,'Date Created',1031514049);
INSERT INTO international VALUES (454,'WebGUI',1,'Last Updated',1031514049);
INSERT INTO international VALUES (455,'WebGUI',1,'Edit User\'s Profile',1031514049);
INSERT INTO international VALUES (456,'WebGUI',1,'Back to user list.',1031514049);
INSERT INTO international VALUES (457,'WebGUI',1,'Edit this user\'s account.',1031514049);
INSERT INTO international VALUES (458,'WebGUI',1,'Edit this user\'s groups.',1031514049);
INSERT INTO international VALUES (459,'WebGUI',1,'Edit this user\'s profile.',1031514049);
INSERT INTO international VALUES (460,'WebGUI',1,'Time Offset',1031514049);
INSERT INTO international VALUES (461,'WebGUI',1,'Date Format',1031514049);
INSERT INTO international VALUES (462,'WebGUI',1,'Time Format',1031514049);
INSERT INTO international VALUES (463,'WebGUI',1,'Text Area Rows',1031514049);
INSERT INTO international VALUES (464,'WebGUI',1,'Text Area Columns',1031514049);
INSERT INTO international VALUES (465,'WebGUI',1,'Text Box Size',1031514049);
INSERT INTO international VALUES (466,'WebGUI',1,'Are you certain you wish to delete this category and move all of its fields to the Miscellaneous category?',1031514049);
INSERT INTO international VALUES (467,'WebGUI',1,'Are you certain you wish to delete this field and all user data attached to it?',1031514049);
INSERT INTO international VALUES (468,'WebGUI',6,'Redigera Användar Profil Kattegorier',1031510000);
INSERT INTO international VALUES (469,'WebGUI',1,'Id',1031514049);
INSERT INTO international VALUES (470,'WebGUI',1,'Name',1031514049);
INSERT INTO international VALUES (472,'WebGUI',1,'Label',1031514049);
INSERT INTO international VALUES (473,'WebGUI',1,'Visible?',1031514049);
INSERT INTO international VALUES (474,'WebGUI',1,'Required?',1031514049);
INSERT INTO international VALUES (475,'WebGUI',1,'Text',1031514049);
INSERT INTO international VALUES (476,'WebGUI',1,'Text Area',1031514049);
INSERT INTO international VALUES (477,'WebGUI',1,'HTML Area',1031514049);
INSERT INTO international VALUES (478,'WebGUI',1,'URL',1031514049);
INSERT INTO international VALUES (479,'WebGUI',1,'Date',1031514049);
INSERT INTO international VALUES (480,'WebGUI',1,'Email Address',1031514049);
INSERT INTO international VALUES (481,'WebGUI',1,'Telephone Number',1031514049);
INSERT INTO international VALUES (482,'WebGUI',1,'Number (Integer)',1031514049);
INSERT INTO international VALUES (483,'WebGUI',1,'Yes or No',1031514049);
INSERT INTO international VALUES (484,'WebGUI',1,'Select List',1031514049);
INSERT INTO international VALUES (485,'WebGUI',1,'Boolean (Checkbox)',1031514049);
INSERT INTO international VALUES (486,'WebGUI',1,'Data Type',1031514049);
INSERT INTO international VALUES (487,'WebGUI',1,'Possible Values',1031514049);
INSERT INTO international VALUES (488,'WebGUI',1,'Default Value(s)',1031514049);
INSERT INTO international VALUES (489,'WebGUI',1,'Profile Category',1031514049);
INSERT INTO international VALUES (490,'WebGUI',1,'Add a profile category.',1031514049);
INSERT INTO international VALUES (491,'WebGUI',1,'Add a profile field.',1031514049);
INSERT INTO international VALUES (492,'WebGUI',1,'Profile fields list.',1031514049);
INSERT INTO international VALUES (493,'WebGUI',1,'Back to site.',1031514049);
INSERT INTO international VALUES (495,'WebGUI',1,'Built-In Editor',1031514049);
INSERT INTO international VALUES (496,'WebGUI',1,'Editor To Use',1031514049);
INSERT INTO international VALUES (494,'WebGUI',1,'Real Objects Edit-On Pro',1031514049);
INSERT INTO international VALUES (497,'WebGUI',1,'Start Date',1031514049);
INSERT INTO international VALUES (498,'WebGUI',1,'End Date',1031514049);
INSERT INTO international VALUES (499,'WebGUI',1,'Wobject ID',1031514049);
INSERT INTO international VALUES (500,'WebGUI',1,'Page ID',1031514049);
INSERT INTO international VALUES (5,'Poll',6,'Bred på staplar',1031510000);
INSERT INTO international VALUES (5,'SiteMap',6,'Redigera Site Kartan',1031510000);
INSERT INTO international VALUES (5,'SQLReport',6,'DSN',1031510000);
INSERT INTO international VALUES (5,'SyndicatedContent',6,'Senast hämtad',1031510000);
INSERT INTO international VALUES (5,'UserSubmission',6,'Ditt medelande har blivit nekat validering.',1031510000);
INSERT INTO international VALUES (5,'WebGUI',6,'Kontrolera grupper.',1031510000);
INSERT INTO international VALUES (6,'Article',6,'Bild',1031510000);
INSERT INTO international VALUES (701,'WebGUI',6,'Vecka',1031510000);
INSERT INTO international VALUES (6,'ExtraColumn',6,'Lägg till extra column',1031510000);
INSERT INTO international VALUES (6,'FAQ',6,'Svar',1031510000);
INSERT INTO international VALUES (6,'LinkList',6,'Länk Lista',1031510000);
INSERT INTO international VALUES (6,'MessageBoard',6,'Redigera Meddelande Forum',1031510000);
INSERT INTO international VALUES (6,'Poll',6,'Fråga',1031510000);
INSERT INTO international VALUES (6,'SiteMap',6,'Indentering',1031510000);
INSERT INTO international VALUES (6,'SQLReport',6,'Database Användare',1031510000);
INSERT INTO international VALUES (6,'SyndicatedContent',6,'Nuvarande inehåll',1031510000);
INSERT INTO international VALUES (6,'UserSubmission',6,'Inlägg per sida',1031510000);
INSERT INTO international VALUES (6,'WebGUI',6,'Kontrolera stilar.',1031510000);
INSERT INTO international VALUES (7,'Article',6,'Länk Titel',1031510000);
INSERT INTO international VALUES (7,'EventsCalendar',6,'Lägg till händelse',1031510000);
INSERT INTO international VALUES (7,'FAQ',6,'Är du säker på att du vill radera denna fråga?',1031510000);
INSERT INTO international VALUES (7,'LinkList',6,'Lägg till länk',1031510000);
INSERT INTO international VALUES (7,'MessageBoard',6,'Författare:',1031510000);
INSERT INTO international VALUES (7,'Poll',6,'Svar',1031510000);
INSERT INTO international VALUES (7,'SiteMap',6,'Kula',1031510000);
INSERT INTO international VALUES (7,'SQLReport',6,'Database Lösenord',1031510000);
INSERT INTO international VALUES (560,'WebGUI',6,'Godkännt',1031510000);
INSERT INTO international VALUES (7,'WebGUI',6,'Kontrolera användare.',1031510000);
INSERT INTO international VALUES (8,'Article',6,'Länk URL',1031510000);
INSERT INTO international VALUES (8,'EventsCalendar',6,'Recurs every',1031510000);
INSERT INTO international VALUES (8,'FAQ',6,'Redigera F.A.Q.',1031510000);
INSERT INTO international VALUES (8,'LinkList',6,'URL',1031510000);
INSERT INTO international VALUES (8,'MessageBoard',6,'Datum:',1031510000);
INSERT INTO international VALUES (8,'Poll',6,'(Mata in ett svar per rad. Max 20.)',1031510000);
INSERT INTO international VALUES (8,'SiteMap',6,'Avstånd mellan rader',1031510000);
INSERT INTO international VALUES (8,'SQLReport',6,'Redigera SQL Rapport',1031510000);
INSERT INTO international VALUES (561,'WebGUI',6,'Nekat',1031510000);
INSERT INTO international VALUES (8,'WebGUI',6,'Visa page not found.',1031510000);
INSERT INTO international VALUES (9,'Article',6,'Bilagor',1031510000);
INSERT INTO international VALUES (9,'EventsCalendar',6,'until',1031510000);
INSERT INTO international VALUES (9,'FAQ',6,'Lägg till ny fråga.',1031510000);
INSERT INTO international VALUES (9,'LinkList',6,'Är du säker att du vill radera denna länk?',1031510000);
INSERT INTO international VALUES (9,'MessageBoard',6,'Meddelande ID:',1031510000);
INSERT INTO international VALUES (9,'Poll',6,'Redigera fråga',1031510000);
INSERT INTO international VALUES (9,'SQLReport',6,'&lt;b&gt;Debug:&lt;/b&gt; Error: The DSN specified is of an improper format.',1031510000);
INSERT INTO international VALUES (562,'WebGUI',6,'Väntande',1031510000);
INSERT INTO international VALUES (9,'WebGUI',6,'Visa klippbord.',1031510000);
INSERT INTO international VALUES (10,'Article',6,'Konvertera radbrytning?',1031510000);
INSERT INTO international VALUES (10,'FAQ',6,'Redigera fråga',1031510000);
INSERT INTO international VALUES (10,'LinkList',6,'Redigera Länk Lista',1031510000);
INSERT INTO international VALUES (2,'Article',10,'Tilføj artikel',1031510000);
INSERT INTO international VALUES (10,'Poll',6,'Återställ röster.',1031510000);
INSERT INTO international VALUES (10,'SQLReport',6,'&lt;b&gt;Debug:&lt;/b&gt; Error: The SQL specified is of an improper format.',1031510000);
INSERT INTO international VALUES (563,'WebGUI',6,'Default Status',1031510000);
INSERT INTO international VALUES (10,'WebGUI',6,'Hantera skräpkorgen.',1031510000);
INSERT INTO international VALUES (11,'Article',6,'(Kryssa i om du inte skriver &amp;lt;br&amp;gt; manuelt.)',1031510000);
INSERT INTO international VALUES (77,'EventsCalendar',1,'Delete this event <b>and</b> all of its recurrences.',1031514049);
INSERT INTO international VALUES (11,'LinkList',6,'Lägg till Länk Lista',1031510000);
INSERT INTO international VALUES (11,'MessageBoard',6,'Tillbaka till meddelande lista',1031510000);
INSERT INTO international VALUES (11,'SQLReport',6,'&lt;b&gt;Debug:&lt;/b&gt; Error: There was a problem with the query.',1031510000);
INSERT INTO international VALUES (11,'UserSubmission',6,'Lägg till inlägg',1031510000);
INSERT INTO international VALUES (11,'WebGUI',6,'Töm skräpkoren.',1031510000);
INSERT INTO international VALUES (12,'Article',6,'Redigera Artikel',1031510000);
INSERT INTO international VALUES (12,'EventsCalendar',6,'Edit Events Calendar',1031510000);
INSERT INTO international VALUES (12,'LinkList',6,'Redigera Länk',1031510000);
INSERT INTO international VALUES (12,'MessageBoard',6,'Redigera meddelande',1031510000);
INSERT INTO international VALUES (12,'SQLReport',6,'&lt;b&gt;Debug:&lt;/b&gt; Error: Could not connect to the database.',1031510000);
INSERT INTO international VALUES (12,'UserSubmission',6,'(Avkryssa om du skriver ett HTML inlägg.)',1031510000);
INSERT INTO international VALUES (12,'WebGUI',6,'Stäng av adminverktyg.',1031510000);
INSERT INTO international VALUES (13,'Article',6,'Radera',1031510000);
INSERT INTO international VALUES (13,'EventsCalendar',6,'Lägg till händelse',1031510000);
INSERT INTO international VALUES (13,'LinkList',6,'Lägg till en ny länk.',1031510000);
INSERT INTO international VALUES (577,'WebGUI',6,'Skicka svar',1031510000);
INSERT INTO international VALUES (13,'UserSubmission',6,'Inlagt den',1031510000);
INSERT INTO international VALUES (13,'WebGUI',6,'Visa hjälpindex.',1031510000);
INSERT INTO international VALUES (14,'Article',6,'Justera Bild',1031510000);
INSERT INTO international VALUES (514,'WebGUI',1,'Views',1031514049);
INSERT INTO international VALUES (14,'UserSubmission',6,'Status',1031510000);
INSERT INTO international VALUES (14,'WebGUI',6,'Visa väntande meddelanden.',1031510000);
INSERT INTO international VALUES (15,'MessageBoard',6,'Författare',1031510000);
INSERT INTO international VALUES (15,'UserSubmission',6,'Redigera/Ta bort',1031510000);
INSERT INTO international VALUES (15,'WebGUI',6,'Januari',1031510000);
INSERT INTO international VALUES (16,'MessageBoard',6,'Datum',1031510000);
INSERT INTO international VALUES (16,'UserSubmission',6,'Namnlös',1031510000);
INSERT INTO international VALUES (16,'WebGUI',6,'Februari',1031510000);
INSERT INTO international VALUES (17,'MessageBoard',6,'Skicka nytt meddelande',1031510000);
INSERT INTO international VALUES (17,'UserSubmission',6,'Är du säger du vill ta bort detta inlägg?',1031510000);
INSERT INTO international VALUES (17,'WebGUI',6,'Mars',1031510000);
INSERT INTO international VALUES (18,'MessageBoard',6,'Tråd startad',1031510000);
INSERT INTO international VALUES (18,'UserSubmission',6,'Regigera inläggs system',1031510000);
INSERT INTO international VALUES (18,'WebGUI',6,'April',1031510000);
INSERT INTO international VALUES (19,'MessageBoard',6,'Svar',1031510000);
INSERT INTO international VALUES (19,'UserSubmission',6,'Redigera inlägg',1031510000);
INSERT INTO international VALUES (19,'WebGUI',6,'Maj',1031510000);
INSERT INTO international VALUES (20,'MessageBoard',6,'Senaste svar',1031510000);
INSERT INTO international VALUES (20,'UserSubmission',6,'Skicka nytt inlägg',1031510000);
INSERT INTO international VALUES (20,'WebGUI',6,'Juni',1031510000);
INSERT INTO international VALUES (21,'UserSubmission',6,'Skrivet av',1031510000);
INSERT INTO international VALUES (21,'WebGUI',6,'Juli',1031510000);
INSERT INTO international VALUES (22,'UserSubmission',6,'Skrivet av:',1031510000);
INSERT INTO international VALUES (22,'WebGUI',6,'Augusti',1031510000);
INSERT INTO international VALUES (23,'UserSubmission',6,'Inläggsdatum:',1031510000);
INSERT INTO international VALUES (23,'WebGUI',6,'September',1031510000);
INSERT INTO international VALUES (572,'WebGUI',6,'Godkänn',1031510000);
INSERT INTO international VALUES (24,'WebGUI',6,'Oktober',1031510000);
INSERT INTO international VALUES (573,'WebGUI',6,'Lämna i vänteläge',1031510000);
INSERT INTO international VALUES (25,'WebGUI',6,'November',1031510000);
INSERT INTO international VALUES (574,'WebGUI',6,'Neka',1031510000);
INSERT INTO international VALUES (26,'WebGUI',6,'December',1031510000);
INSERT INTO international VALUES (27,'UserSubmission',6,'Redigera',1031510000);
INSERT INTO international VALUES (27,'WebGUI',6,'Söndag',1031510000);
INSERT INTO international VALUES (28,'UserSubmission',6,'Återgå till inläggslistan',1031510000);
INSERT INTO international VALUES (28,'WebGUI',6,'Måndag',1031510000);
INSERT INTO international VALUES (29,'UserSubmission',6,'Användar-inläggs system',1031510000);
INSERT INTO international VALUES (29,'WebGUI',6,'Tisdag',1031510000);
INSERT INTO international VALUES (576,'WebGUI',1,'Delete',1031514049);
INSERT INTO international VALUES (30,'WebGUI',6,'Onsdag',1031510000);
INSERT INTO international VALUES (31,'WebGUI',6,'Torsdag',1031510000);
INSERT INTO international VALUES (32,'WebGUI',6,'Fredag',1031510000);
INSERT INTO international VALUES (33,'WebGUI',6,'Lördag',1031510000);
INSERT INTO international VALUES (34,'WebGUI',6,'sätt datum',1031510000);
INSERT INTO international VALUES (35,'WebGUI',6,'Administrativa funktioner',1031510000);
INSERT INTO international VALUES (36,'WebGUI',6,'Du måste vara administratör för att utföra denna funktion. Var vänlig kontakta någon av administratörerna. Följande är en lista av administratörer i systemet:',1031510000);
INSERT INTO international VALUES (37,'WebGUI',6,'Åtkomst nekas!',1031510000);
INSERT INTO international VALUES (404,'WebGUI',6,'Första Sidan',1031510000);
INSERT INTO international VALUES (38,'WebGUI',6,'Du har inte rättigheter att utföra denna operation. Var vänlig och ^a(logga in); på ett konto med tillräckliga rättigheter.',1031510000);
INSERT INTO international VALUES (39,'WebGUI',6,'Åtkomst nekas, du har inte tillräckliga previlegier.',1031510000);
INSERT INTO international VALUES (40,'WebGUI',6,'Vital komponent',1031510000);
INSERT INTO international VALUES (41,'WebGUI',6,'Du håller på att ta bort en vital komponent från WebGUI systemet. Om du hade varit tillåten att göra detta, hade WebGUI slutat fungera !',1031510000);
INSERT INTO international VALUES (42,'WebGUI',6,'Var vänlig konfirmera',1031510000);
INSERT INTO international VALUES (43,'WebGUI',6,'Är du säker att du vill ta bort detta inehåll?',1031510000);
INSERT INTO international VALUES (44,'WebGUI',6,'Ja, jag är säker.',1031510000);
INSERT INTO international VALUES (45,'WebGUI',6,'Nej, jag gjorde ett misstag.',1031510000);
INSERT INTO international VALUES (46,'WebGUI',6,'Mitt konto',1031510000);
INSERT INTO international VALUES (47,'WebGUI',6,'Hem',1031510000);
INSERT INTO international VALUES (48,'WebGUI',6,'Hej',1031510000);
INSERT INTO international VALUES (49,'WebGUI',6,'Klicka &lt;a href=unknown://\"^\\;?op=logout\" TARGET=\"_blank\"&gt;här&lt;/a&gt; för att logga ur.',1031510000);
INSERT INTO international VALUES (50,'WebGUI',6,'Användarnamn',1031510000);
INSERT INTO international VALUES (51,'WebGUI',6,'Lösenord',1031510000);
INSERT INTO international VALUES (52,'WebGUI',6,'logga in',1031510000);
INSERT INTO international VALUES (53,'WebGUI',6,'Utskrifts version',1031510000);
INSERT INTO international VALUES (54,'WebGUI',6,'Skapa konto',1031510000);
INSERT INTO international VALUES (55,'WebGUI',6,'Lösenord (kontroll)',1031510000);
INSERT INTO international VALUES (56,'WebGUI',6,'Email adress',1031510000);
INSERT INTO international VALUES (57,'WebGUI',6,'Detta krävs endas om du vill använda tjänster som kräver Email.',1031510000);
INSERT INTO international VALUES (58,'WebGUI',6,'Jag har redan ett konto.',1031510000);
INSERT INTO international VALUES (59,'WebGUI',6,'Jag har glömt mitt lösenord.',1031510000);
INSERT INTO international VALUES (60,'WebGUI',6,'ÄR du säker på att du vill stänga ned ditt konto ? Om du fortsätter kommer all information att vara permanent förlorad.',1031510000);
INSERT INTO international VALUES (61,'WebGUI',6,'Uppdatera konto information',1031510000);
INSERT INTO international VALUES (62,'WebGUI',6,'spara',1031510000);
INSERT INTO international VALUES (63,'WebGUI',6,'Slå på admin-verktyg.',1031510000);
INSERT INTO international VALUES (64,'WebGUI',6,'Logga ut.',1031510000);
INSERT INTO international VALUES (65,'WebGUI',6,'Var vänlig och radera mitt konto permanent.',1031510000);
INSERT INTO international VALUES (66,'WebGUI',6,'Logga in.',1031510000);
INSERT INTO international VALUES (67,'WebGUI',6,'Skapa ett konto.',1031510000);
INSERT INTO international VALUES (68,'WebGUI',6,'Informationen du gav var felaktig. Antingen så finns ingen sådan användare eller också så gav du fellösenords.',1031510000);
INSERT INTO international VALUES (69,'WebGUI',6,'Var vänlig kontakta system administratören för vidare hjälp.',1031510000);
INSERT INTO international VALUES (70,'WebGUI',6,'Fel',1031510000);
INSERT INTO international VALUES (71,'WebGUI',6,'Rädda lösenord',1031510000);
INSERT INTO international VALUES (72,'WebGUI',6,'rädda',1031510000);
INSERT INTO international VALUES (73,'WebGUI',6,'Logga in.',1031510000);
INSERT INTO international VALUES (74,'WebGUI',6,'Konto information',1031510000);
INSERT INTO international VALUES (75,'WebGUI',6,'Din kontoinformation har skickats till din Email adress.',1031510000);
INSERT INTO international VALUES (76,'WebGUI',6,'Den Email adressen finns inte i vårt system.',1031510000);
INSERT INTO international VALUES (77,'WebGUI',6,'Det kontonamnet du valde används redan på denna site. Var vänlig välj ett annat. Här kommer några ideer som du kan använda:',1031510000);
INSERT INTO international VALUES (78,'WebGUI',6,'Ditt lösenord stämde inte. Var vänlig försök igen.',1031510000);
INSERT INTO international VALUES (79,'WebGUI',6,'Cannot connect to LDAP server.',1031510000);
INSERT INTO international VALUES (80,'WebGUI',6,'Kontot skapades utan problem!',1031510000);
INSERT INTO international VALUES (81,'WebGUI',6,'Kontot uppdaterat utan problem!',1031510000);
INSERT INTO international VALUES (82,'WebGUI',6,'Administrativa funktioner...',1031510000);
INSERT INTO international VALUES (84,'WebGUI',6,'Grupp namn',1031510000);
INSERT INTO international VALUES (85,'WebGUI',6,'Beskrivning',1031510000);
INSERT INTO international VALUES (86,'WebGUI',6,'Är du säker på att du vill radera denna grupp? Var medveten om att alla rättigheter associerade med denna grupp kommer att raderas.',1031510000);
INSERT INTO international VALUES (87,'WebGUI',6,'Ändra grupp',1031510000);
INSERT INTO international VALUES (88,'WebGUI',6,'Användare i gruppen',1031510000);
INSERT INTO international VALUES (89,'WebGUI',6,'Grupper',1031510000);
INSERT INTO international VALUES (90,'WebGUI',6,'Lägg till grupp.',1031510000);
INSERT INTO international VALUES (91,'WebGUI',6,'Föregående sida',1031510000);
INSERT INTO international VALUES (92,'WebGUI',6,'Nästa sida',1031510000);
INSERT INTO international VALUES (93,'WebGUI',6,'Hjälp',1031510000);
INSERT INTO international VALUES (94,'WebGUI',6,'Se vidare',1031510000);
INSERT INTO international VALUES (95,'WebGUI',6,'Hjälp index',1031510000);
INSERT INTO international VALUES (98,'WebGUI',6,'Lägg till sida',1031510000);
INSERT INTO international VALUES (99,'WebGUI',6,'Titel',1031510000);
INSERT INTO international VALUES (100,'WebGUI',6,'Meta Tag',1031510000);
INSERT INTO international VALUES (101,'WebGUI',6,'Är du säker på att du vill radera denna sita, dess inehåll och underligande objekt?',1031510000);
INSERT INTO international VALUES (102,'WebGUI',6,'Editera sida',1031510000);
INSERT INTO international VALUES (103,'WebGUI',6,'Sidspecifikation',1031510000);
INSERT INTO international VALUES (104,'WebGUI',6,'Sidans URL',1031510000);
INSERT INTO international VALUES (105,'WebGUI',6,'Stil',1031510000);
INSERT INTO international VALUES (106,'WebGUI',6,'Ge samma stil till underliggande sidor.',1031510000);
INSERT INTO international VALUES (107,'WebGUI',6,'Previlegier',1031510000);
INSERT INTO international VALUES (108,'WebGUI',6,'Ägare',1031510000);
INSERT INTO international VALUES (109,'WebGUI',6,'Ägaren kan se?',1031510000);
INSERT INTO international VALUES (110,'WebGUI',6,'Ägaren kan editera?',1031510000);
INSERT INTO international VALUES (111,'WebGUI',6,'Grupp',1031510000);
INSERT INTO international VALUES (112,'WebGUI',6,'Gruppen kan se?',1031510000);
INSERT INTO international VALUES (113,'WebGUI',6,'Gruppen kan editera?',1031510000);
INSERT INTO international VALUES (114,'WebGUI',6,'Vemsomhelst kan titta?',1031510000);
INSERT INTO international VALUES (115,'WebGUI',6,'Kan vem som helst redigera?',1031510000);
INSERT INTO international VALUES (116,'WebGUI',6,'Kryssa här för att kopiera dessa previlegier till undersidor.',1031510000);
INSERT INTO international VALUES (117,'WebGUI',6,'Redigera Autentiserings inställningar',1031510000);
INSERT INTO international VALUES (118,'WebGUI',6,'Anonyma registreringar',1031510000);
INSERT INTO international VALUES (119,'WebGUI',6,'Authentiserings metod(default)',1031510000);
INSERT INTO international VALUES (120,'WebGUI',6,'LDAP URL (default)',1031510000);
INSERT INTO international VALUES (121,'WebGUI',6,'LDAP Identity (default)',1031510000);
INSERT INTO international VALUES (122,'WebGUI',6,'LDAP Identity Name',1031510000);
INSERT INTO international VALUES (123,'WebGUI',6,'LDAP Password Name',1031510000);
INSERT INTO international VALUES (124,'WebGUI',6,'Edit Company Information',1031510000);
INSERT INTO international VALUES (125,'WebGUI',6,'Företags namn',1031510000);
INSERT INTO international VALUES (126,'WebGUI',6,'Företags Email adress',1031510000);
INSERT INTO international VALUES (127,'WebGUI',6,'Företags URL',1031510000);
INSERT INTO international VALUES (130,'WebGUI',6,'Maximal storlek på bilagor',1031510000);
INSERT INTO international VALUES (133,'WebGUI',6,'Redigera Mail Inställningar',1031510000);
INSERT INTO international VALUES (134,'WebGUI',6,'Rädda lösenords meddelande',1031510000);
INSERT INTO international VALUES (135,'WebGUI',6,'SMTP Server',1031510000);
INSERT INTO international VALUES (527,'WebGUI',1,'Default Home Page',1031514049);
INSERT INTO international VALUES (138,'WebGUI',6,'Ja',1031510000);
INSERT INTO international VALUES (139,'WebGUI',6,'Nej',1031510000);
INSERT INTO international VALUES (140,'WebGUI',6,'Redigera övriga inställningar',1031510000);
INSERT INTO international VALUES (141,'WebGUI',6,'Not Found Page',1031510000);
INSERT INTO international VALUES (142,'WebGUI',6,'Session Timeout',1031510000);
INSERT INTO international VALUES (143,'WebGUI',6,'Kontrolera inställningar',1031510000);
INSERT INTO international VALUES (144,'WebGUI',6,'Visa statistik.',1031510000);
INSERT INTO international VALUES (145,'WebGUI',6,'WebGUI Build Version',1031510000);
INSERT INTO international VALUES (146,'WebGUI',6,'Aktiva sessioner',1031510000);
INSERT INTO international VALUES (147,'WebGUI',6,'Sidor',1031510000);
INSERT INTO international VALUES (148,'WebGUI',6,'Wobjects',1031510000);
INSERT INTO international VALUES (149,'WebGUI',6,'Användare',1031510000);
INSERT INTO international VALUES (151,'WebGUI',6,'Stil namn',1031510000);
INSERT INTO international VALUES (501,'WebGUI',1,'Body',1031514049);
INSERT INTO international VALUES (154,'WebGUI',6,'Stil schema (Style Sheet)',1031510000);
INSERT INTO international VALUES (155,'WebGUI',6,'Är du säker på att du vill radera denna stil och vilket resulterar i att alla sidor som använder den stilen kommer använda \"Fail Safe\" stilen?',1031510000);
INSERT INTO international VALUES (156,'WebGUI',6,'Redigera stil',1031510000);
INSERT INTO international VALUES (157,'WebGUI',6,'Stilar',1031510000);
INSERT INTO international VALUES (158,'WebGUI',6,'Lägg till en ny stil.',1031510000);
INSERT INTO international VALUES (159,'WebGUI',6,'Medelande log',1031510000);
INSERT INTO international VALUES (160,'WebGUI',6,'Inlagt den',1031510000);
INSERT INTO international VALUES (161,'WebGUI',6,'Skrivet av',1031510000);
INSERT INTO international VALUES (162,'WebGUI',6,'Är du säker på att du vill ta bort allt ur skräpkorgen?',1031510000);
INSERT INTO international VALUES (163,'WebGUI',6,'Lägg till användare',1031510000);
INSERT INTO international VALUES (164,'WebGUI',6,'Autentiserings metod',1031510000);
INSERT INTO international VALUES (165,'WebGUI',6,'LDAP URL',1031510000);
INSERT INTO international VALUES (166,'WebGUI',6,'Connect DN',1031510000);
INSERT INTO international VALUES (167,'WebGUI',6,'Är du absolut säker att du vill radera denna användare? Var medveten om att all information om denna användare kommer att vara permanent förlorade om du fortsätter.',1031510000);
INSERT INTO international VALUES (168,'WebGUI',6,'Redigera Användare',1031510000);
INSERT INTO international VALUES (169,'WebGUI',6,'Lägg till en ny användare.',1031510000);
INSERT INTO international VALUES (170,'WebGUI',6,'sök',1031510000);
INSERT INTO international VALUES (171,'WebGUI',6,'rich edit',1031510000);
INSERT INTO international VALUES (174,'WebGUI',6,'Visa titel?',1031510000);
INSERT INTO international VALUES (175,'WebGUI',6,'Berarbeta makron?',1031510000);
INSERT INTO international VALUES (228,'WebGUI',6,'Redigerar Meddelande...',1031510000);
INSERT INTO international VALUES (229,'WebGUI',6,'Subject',1031510000);
INSERT INTO international VALUES (230,'WebGUI',6,'Meddelande',1031510000);
INSERT INTO international VALUES (231,'WebGUI',6,'Skickar nytt meddelande...',1031510000);
INSERT INTO international VALUES (232,'WebGUI',6,'no subject',1031510000);
INSERT INTO international VALUES (233,'WebGUI',6,'(eom)',1031510000);
INSERT INTO international VALUES (234,'WebGUI',6,'Skickar svar...',1031510000);
INSERT INTO international VALUES (237,'WebGUI',6,'Subject:',1031510000);
INSERT INTO international VALUES (238,'WebGUI',6,'Författare:',1031510000);
INSERT INTO international VALUES (239,'WebGUI',6,'Datum:',1031510000);
INSERT INTO international VALUES (240,'WebGUI',6,'Meddelande ID:',1031510000);
INSERT INTO international VALUES (244,'WebGUI',6,'Författare',1031510000);
INSERT INTO international VALUES (245,'WebGUI',6,'Datum',1031510000);
INSERT INTO international VALUES (304,'WebGUI',6,'Språk',1031510000);
INSERT INTO international VALUES (306,'WebGUI',6,'Username Binding',1031510000);
INSERT INTO international VALUES (307,'WebGUI',6,'Använd den vanliga meta tagen?',1031510000);
INSERT INTO international VALUES (308,'WebGUI',6,'Redigera profilinställningar',1031510000);
INSERT INTO international VALUES (309,'WebGUI',6,'Tillåt riktigt namn?',1031510000);
INSERT INTO international VALUES (310,'WebGUI',6,'Tillåt extra kontaktinformation?',1031510000);
INSERT INTO international VALUES (311,'WebGUI',6,'Tillåt heminformation?',1031510000);
INSERT INTO international VALUES (312,'WebGUI',6,'Tillåt företagsinformation?',1031510000);
INSERT INTO international VALUES (313,'WebGUI',6,'Tillåt extra informaiton?',1031510000);
INSERT INTO international VALUES (314,'WebGUI',6,'Förnamn',1031510000);
INSERT INTO international VALUES (315,'WebGUI',6,'Mellannamn',1031510000);
INSERT INTO international VALUES (316,'WebGUI',6,'Efternamn',1031510000);
INSERT INTO international VALUES (317,'WebGUI',6,'ICQ UIN',1031510000);
INSERT INTO international VALUES (318,'WebGUI',6,'AIM Id',1031510000);
INSERT INTO international VALUES (319,'WebGUI',6,'MSN Messenger Id',1031510000);
INSERT INTO international VALUES (320,'WebGUI',6,'Yahoo! Messenger Id',1031510000);
INSERT INTO international VALUES (321,'WebGUI',6,'Mobil nummer',1031510000);
INSERT INTO international VALUES (322,'WebGUI',6,'Personsökare',1031510000);
INSERT INTO international VALUES (323,'WebGUI',6,'Hem adress',1031510000);
INSERT INTO international VALUES (324,'WebGUI',6,'Hem stad',1031510000);
INSERT INTO international VALUES (325,'WebGUI',6,'Hem län',1031510000);
INSERT INTO international VALUES (326,'WebGUI',6,'Hem postnummer',1031510000);
INSERT INTO international VALUES (327,'WebGUI',6,'Hem land',1031510000);
INSERT INTO international VALUES (328,'WebGUI',6,'Hem telefon',1031510000);
INSERT INTO international VALUES (329,'WebGUI',6,'Arbets adress',1031510000);
INSERT INTO international VALUES (330,'WebGUI',6,'Arbets stad',1031510000);
INSERT INTO international VALUES (331,'WebGUI',6,'Arbets län',1031510000);
INSERT INTO international VALUES (332,'WebGUI',6,'Arbets postnummer',1031510000);
INSERT INTO international VALUES (333,'WebGUI',6,'Arbets land',1031510000);
INSERT INTO international VALUES (334,'WebGUI',6,'Arbets telefon',1031510000);
INSERT INTO international VALUES (335,'WebGUI',6,'Kön',1031510000);
INSERT INTO international VALUES (336,'WebGUI',6,'Födelsedatum',1031510000);
INSERT INTO international VALUES (337,'WebGUI',6,'Hemside URL',1031510000);
INSERT INTO international VALUES (338,'WebGUI',6,'Redigera profil',1031510000);
INSERT INTO international VALUES (339,'WebGUI',6,'Man',1031510000);
INSERT INTO international VALUES (340,'WebGUI',6,'Kvinna',1031510000);
INSERT INTO international VALUES (341,'WebGUI',6,'Redigera profil.',1031510000);
INSERT INTO international VALUES (342,'WebGUI',6,'Redigera kontoinformation.',1031510000);
INSERT INTO international VALUES (343,'WebGUI',6,'Visa profil.',1031510000);
INSERT INTO international VALUES (345,'WebGUI',6,'Inte en medlem',1031510000);
INSERT INTO international VALUES (346,'WebGUI',6,'Denna användare är inte längre medlem på vår site. Vi har ingen vidare information om användaren.',1031510000);
INSERT INTO international VALUES (347,'WebGUI',6,'Visa profilen för',1031510000);
INSERT INTO international VALUES (348,'WebGUI',6,'Namn',1031510000);
INSERT INTO international VALUES (349,'WebGUI',6,'Senaste tillgängliga version',1031510000);
INSERT INTO international VALUES (350,'WebGUI',6,'Avslutad',1031510000);
INSERT INTO international VALUES (351,'WebGUI',6,'Medelandelog Post',1031510000);
INSERT INTO international VALUES (352,'WebGUI',6,'Skapat datum',1031510000);
INSERT INTO international VALUES (353,'WebGUI',6,'Du har inga nya logmedelanden just nu.',1031510000);
INSERT INTO international VALUES (354,'WebGUI',6,'Visa medelande log.',1031510000);
INSERT INTO international VALUES (355,'WebGUI',6,'Standard',1031510000);
INSERT INTO international VALUES (356,'WebGUI',6,'Mall',1031510000);
INSERT INTO international VALUES (357,'WebGUI',6,'Nyheter',1031510000);
INSERT INTO international VALUES (358,'WebGUI',6,'Vänster kolumn',1031510000);
INSERT INTO international VALUES (359,'WebGUI',6,'Höger kolumn',1031510000);
INSERT INTO international VALUES (360,'WebGUI',6,'En över tre',1031510000);
INSERT INTO international VALUES (361,'WebGUI',6,'Tre över en',1031510000);
INSERT INTO international VALUES (362,'WebGUI',6,'SidaVidSida',1031510000);
INSERT INTO international VALUES (363,'WebGUI',6,'Mall position',1031510000);
INSERT INTO international VALUES (364,'WebGUI',6,'Sök',1031510000);
INSERT INTO international VALUES (365,'WebGUI',6,'Sökresultaten..',1031510000);
INSERT INTO international VALUES (366,'WebGUI',6,'Inga sidor hittades som stämde med din förfrågan.',1031510000);
INSERT INTO international VALUES (368,'WebGUI',6,'Lägg till en ny grupp till denna användare.',1031510000);
INSERT INTO international VALUES (369,'WebGUI',6,'Bästföre datum',1031510000);
INSERT INTO international VALUES (370,'WebGUI',6,'Redigera gruppering',1031510000);
INSERT INTO international VALUES (371,'WebGUI',6,'Lägg till gruppering',1031510000);
INSERT INTO international VALUES (372,'WebGUI',6,'Redigera Användares Grupper',1031510000);
INSERT INTO international VALUES (374,'WebGUI',6,'Hantera paket.',1031510000);
INSERT INTO international VALUES (375,'WebGUI',6,'Välj ett paket att använda',1031510000);
INSERT INTO international VALUES (376,'WebGUI',6,'Paket',1031510000);
INSERT INTO international VALUES (377,'WebGUI',6,'Inga paket har definierats av din packet hanterare eller administratör.',1031510000);
INSERT INTO international VALUES (11,'Poll',6,'Rösta!',1031510000);
INSERT INTO international VALUES (31,'UserSubmission',6,'Inehåll',1031510000);
INSERT INTO international VALUES (32,'UserSubmission',6,'Bild',1031510000);
INSERT INTO international VALUES (33,'UserSubmission',6,'Bilag',1031510000);
INSERT INTO international VALUES (34,'UserSubmission',6,'Konvertera radbrytningar',1031510000);
INSERT INTO international VALUES (35,'UserSubmission',6,'Titel',1031510000);
INSERT INTO international VALUES (36,'UserSubmission',6,'Radera fil.',1031510000);
INSERT INTO international VALUES (378,'WebGUI',6,'Användar ID',1031510000);
INSERT INTO international VALUES (379,'WebGUI',6,'Grupp ID',1031510000);
INSERT INTO international VALUES (380,'WebGUI',6,'Stil ID',1031510000);
INSERT INTO international VALUES (381,'WebGUI',6,'WebGUI fick in en felformulerad förfrågan och kunde inte fortsätta. Oftast beror detta på ovanliga tecken som skickas från ett formulär. Du kan försöka med att gå tillbaka och försöka igen.',1031510000);
INSERT INTO international VALUES (1,'DownloadManager',6,'Filhanterare',1031510000);
INSERT INTO international VALUES (2,'DownloadManager',6,'Lägg till en Filhanterare',1031510000);
INSERT INTO international VALUES (3,'DownloadManager',6,'Fortsätt med att lägga till fil?',1031510000);
INSERT INTO international VALUES (4,'DownloadManager',6,'Läggtill Nedladdning',1031510000);
INSERT INTO international VALUES (5,'DownloadManager',6,'Fil Titel',1031510000);
INSERT INTO international VALUES (6,'DownloadManager',6,'Ladda ned fil',1031510000);
INSERT INTO international VALUES (7,'DownloadManager',6,'Grupp för nedladdning',1031510000);
INSERT INTO international VALUES (8,'DownloadManager',6,'Kort Beskrivning',1031510000);
INSERT INTO international VALUES (9,'DownloadManager',6,'Redigera Filhanterare',1031510000);
INSERT INTO international VALUES (10,'DownloadManager',6,'Redigera Nedladdning',1031510000);
INSERT INTO international VALUES (11,'DownloadManager',6,'Lägg till en ny nedladdning.',1031510000);
INSERT INTO international VALUES (12,'DownloadManager',6,'Är du säker på att du vill ta bort denna nedladdning?',1031510000);
INSERT INTO international VALUES (13,'DownloadManager',6,'Radera',1031510000);
INSERT INTO international VALUES (14,'DownloadManager',6,'Fil',1031510000);
INSERT INTO international VALUES (15,'DownloadManager',6,'Beskrivning',1031510000);
INSERT INTO international VALUES (16,'DownloadManager',6,'Uppladat den',1031510000);
INSERT INTO international VALUES (15,'Article',6,'Höger',1031510000);
INSERT INTO international VALUES (16,'Article',6,'Vänster',1031510000);
INSERT INTO international VALUES (17,'Article',6,'Centrera',1031510000);
INSERT INTO international VALUES (37,'UserSubmission',6,'Radera',1031510000);
INSERT INTO international VALUES (13,'SQLReport',6,'Konvertera radbrytning?',1031510000);
INSERT INTO international VALUES (17,'DownloadManager',6,'Alternativ Version #1',1031510000);
INSERT INTO international VALUES (18,'DownloadManager',6,'Alternativ Version #2',1031510000);
INSERT INTO international VALUES (19,'DownloadManager',6,'Du har inga filer att ladda ned.',1031510000);
INSERT INTO international VALUES (14,'EventsCalendar',6,'Start datum',1031510000);
INSERT INTO international VALUES (15,'EventsCalendar',6,'Slut datum',1031510000);
INSERT INTO international VALUES (20,'DownloadManager',6,'Sidbrytning efter',1031510000);
INSERT INTO international VALUES (14,'SQLReport',6,'Sidbrytning efter',1031510000);
INSERT INTO international VALUES (16,'EventsCalendar',6,'Kalender utseende',1031510000);
INSERT INTO international VALUES (17,'EventsCalendar',6,'Lista',1031510000);
INSERT INTO international VALUES (18,'EventsCalendar',6,'Calendar Month',1031510000);
INSERT INTO international VALUES (19,'EventsCalendar',6,'Sidbrytning efter',1031510000);
INSERT INTO international VALUES (354,'WebGUI',1,'View Inbox.',1031514049);
INSERT INTO international VALUES (383,'WebGUI',6,'Namn',1031510000);
INSERT INTO international VALUES (384,'WebGUI',6,'Fil',1031510000);
INSERT INTO international VALUES (385,'WebGUI',6,'Parametrar',1031510000);
INSERT INTO international VALUES (386,'WebGUI',6,'Redigera Bild',1031510000);
INSERT INTO international VALUES (387,'WebGUI',6,'Uppladat av',1031510000);
INSERT INTO international VALUES (388,'WebGUI',6,'Uppladat den',1031510000);
INSERT INTO international VALUES (389,'WebGUI',6,'Bild ID',1031510000);
INSERT INTO international VALUES (390,'WebGUI',6,'Visar bild...',1031510000);
INSERT INTO international VALUES (391,'WebGUI',6,'Radera',1031510000);
INSERT INTO international VALUES (392,'WebGUI',6,'Är du säker på att du vill radera denna bild?',1031510000);
INSERT INTO international VALUES (393,'WebGUI',6,'Hantera Bilder',1031510000);
INSERT INTO international VALUES (394,'WebGUI',6,'Hantera bilder.',1031510000);
INSERT INTO international VALUES (395,'WebGUI',6,'Lägg till en ny bild.',1031510000);
INSERT INTO international VALUES (396,'WebGUI',6,'Visa bild',1031510000);
INSERT INTO international VALUES (397,'WebGUI',6,'Tillbaka till bildlistan.',1031510000);
INSERT INTO international VALUES (398,'WebGUI',6,'Dokument Typ Deklaration',1031510000);
INSERT INTO international VALUES (399,'WebGUI',6,'Validera denna sida.',1031510000);
INSERT INTO international VALUES (400,'WebGUI',6,'Blokera Proxy Caching',1031510000);
INSERT INTO international VALUES (401,'WebGUI',6,'Är du säker på att du vill radera medelandet och alla undermedelanden i denna tråd?',1031510000);
INSERT INTO international VALUES (565,'WebGUI',6,'Vem kan moderera?',1031510000);
INSERT INTO international VALUES (22,'MessageBoard',6,'Radera Medelandet',1031510000);
INSERT INTO international VALUES (402,'WebGUI',6,'Medelandet du frågade efter existerar inte.',1031510000);
INSERT INTO international VALUES (403,'WebGUI',6,'Föredrar att inte säga.',1031510000);
INSERT INTO international VALUES (405,'WebGUI',6,'Sista sidan',1031510000);
INSERT INTO international VALUES (407,'WebGUI',6,'Klicka här för att registrera.',1031510000);
INSERT INTO international VALUES (15,'SQLReport',6,'Förbearbeta macron vid förfrågan?',1031510000);
INSERT INTO international VALUES (16,'SQLReport',6,'Debug?',1031510000);
INSERT INTO international VALUES (17,'SQLReport',6,'&lt;b&gt;Debug:&lt;/b&gt; Förfrågan(query):',1031510000);
INSERT INTO international VALUES (18,'SQLReport',6,'Det fanns inga resultat för denna förfrågan.',1031510000);
INSERT INTO international VALUES (408,'WebGUI',6,'Hantera bassidor(Roots)',1031510000);
INSERT INTO international VALUES (409,'WebGUI',6,'Lägg till en ny bassida.',1031510000);
INSERT INTO international VALUES (410,'WebGUI',6,'Hantera bassidor.',1031510000);
INSERT INTO international VALUES (411,'WebGUI',6,'Huvud titel',1031510000);
INSERT INTO international VALUES (412,'WebGUI',6,'Synopsis',1031510000);
INSERT INTO international VALUES (9,'SiteMap',6,'Visa synopsis?',1031510000);
INSERT INTO international VALUES (18,'Article',6,'Tillåt diskusion',1031510000);
INSERT INTO international VALUES (6,'Product',1,'Edit Product',1031514049);
INSERT INTO international VALUES (4,'Product',1,'Are you certain you wish to delete the relationship to this related product?',1031514049);
INSERT INTO international VALUES (22,'Article',6,'Författare',1031510000);
INSERT INTO international VALUES (23,'Article',6,'Datum',1031510000);
INSERT INTO international VALUES (24,'Article',6,'Skicka svar',1031510000);
INSERT INTO international VALUES (578,'WebGUI',1,'You have a pending message to approve.',1031514049);
INSERT INTO international VALUES (27,'Article',6,'Tillbaka till artikel',1031510000);
INSERT INTO international VALUES (28,'Article',6,'Visa svar',1031510000);
INSERT INTO international VALUES (54,'Product',1,'Benefits',1031514049);
INSERT INTO international VALUES (416,'WebGUI',6,'&lt;h1&gt;Problem Med Förfrågan&lt;/h1&gt;\r\nVi har stött på ett problem med din förfrågan. Var vänlig och gå tillbaka och fösök igen. Om problemet kvarstår var vänlig och rapportera detta till oss med tid och datum samt vad du försökte göra.',1031510000);
INSERT INTO international VALUES (417,'WebGUI',6,'&lt;h1&gt;Säkerhets Överträdelse&lt;/h1&gt;\r\nDu försökte att komma åt en wobject som inte associeras med denna sida. Denna incident har rapporterats.',1031510000);
INSERT INTO international VALUES (418,'WebGUI',6,'Ta bort inmatad HTML',1031510000);
INSERT INTO international VALUES (419,'WebGUI',6,'Ta bort alla taggar.',1031510000);
INSERT INTO international VALUES (420,'WebGUI',6,'Lämna som den är.',1031510000);
INSERT INTO international VALUES (421,'WebGUI',6,'Ta bort allt utom grundformateringen.',1031510000);
INSERT INTO international VALUES (422,'WebGUI',6,'&lt;h1&gt;Inloggning misslyckades&lt;/h1&gt;\r\nInformationen du gav stämmer inte med kontot.',1031510000);
INSERT INTO international VALUES (423,'WebGUI',6,'Visa aktiva sessioner.',1031510000);
INSERT INTO international VALUES (424,'WebGUI',6,'Visa logginhistorik.',1031510000);
INSERT INTO international VALUES (425,'WebGUI',6,'Aktiva sessioner',1031510000);
INSERT INTO international VALUES (426,'WebGUI',6,'Inloggnings historik',1031510000);
INSERT INTO international VALUES (427,'WebGUI',6,'Stilar',1031510000);
INSERT INTO international VALUES (428,'WebGUI',6,'Användar (ID)',1031510000);
INSERT INTO international VALUES (429,'WebGUI',6,'Inloggnings tid',1031510000);
INSERT INTO international VALUES (430,'WebGUI',6,'Senaste sida visad',1031510000);
INSERT INTO international VALUES (431,'WebGUI',6,'IP Adress',1031510000);
INSERT INTO international VALUES (432,'WebGUI',6,'Bäst före',1031510000);
INSERT INTO international VALUES (433,'WebGUI',6,'Användar Klient (Browser)',1031510000);
INSERT INTO international VALUES (434,'WebGUI',6,'Status',1031510000);
INSERT INTO international VALUES (435,'WebGUI',6,'Sessions signatur',1031510000);
INSERT INTO international VALUES (436,'WebGUI',6,'Avsluta session',1031510000);
INSERT INTO international VALUES (437,'WebGUI',6,'Statistik',1031510000);
INSERT INTO international VALUES (438,'WebGUI',6,'Ditt namn',1031510000);
INSERT INTO international VALUES (439,'WebGUI',6,'Personlig Information',1031510000);
INSERT INTO international VALUES (440,'WebGUI',6,'Kontakt Information',1031510000);
INSERT INTO international VALUES (441,'WebGUI',6,'E-Mail till personsökar-gateway',1031510000);
INSERT INTO international VALUES (442,'WebGUI',6,'Arbets Information',1031510000);
INSERT INTO international VALUES (443,'WebGUI',6,'Hem Information',1031510000);
INSERT INTO international VALUES (444,'WebGUI',6,'Demografisk Information',1031510000);
INSERT INTO international VALUES (445,'WebGUI',6,'Inställningar',1031510000);
INSERT INTO international VALUES (446,'WebGUI',6,'Arbetets Website',1031510000);
INSERT INTO international VALUES (447,'WebGUI',6,'Hantera sidträd.',1031510000);
INSERT INTO international VALUES (448,'WebGUI',6,'Sid träd',1031510000);
INSERT INTO international VALUES (449,'WebGUI',6,'Övrig information',1031510000);
INSERT INTO international VALUES (450,'WebGUI',6,'Jobb Namn (Namn på företaget)',1031510000);
INSERT INTO international VALUES (451,'WebGUI',6,'är obligatoriskt.',1031510000);
INSERT INTO international VALUES (452,'WebGUI',6,'Var god vänta...',1031510000);
INSERT INTO international VALUES (453,'WebGUI',6,'Skapad den',1031510000);
INSERT INTO international VALUES (454,'WebGUI',6,'Senast Uppdaterad',1031510000);
INSERT INTO international VALUES (455,'WebGUI',6,'Redigera Användar Profil',1031510000);
INSERT INTO international VALUES (456,'WebGUI',6,'Tillbaka till användarlistan.',1031510000);
INSERT INTO international VALUES (457,'WebGUI',6,'Redigera denna användares konto.',1031510000);
INSERT INTO international VALUES (458,'WebGUI',6,'Redigera denna användares grupper.',1031510000);
INSERT INTO international VALUES (459,'WebGUI',6,'Redigera denna användares profil.',1031510000);
INSERT INTO international VALUES (460,'WebGUI',6,'Tidsoffset',1031510000);
INSERT INTO international VALUES (461,'WebGUI',6,'Datum Format',1031510000);
INSERT INTO international VALUES (462,'WebGUI',6,'Tids Format',1031510000);
INSERT INTO international VALUES (463,'WebGUI',6,'Text Fält Rader',1031510000);
INSERT INTO international VALUES (464,'WebGUI',6,'Text Fält Kolumner',1031510000);
INSERT INTO international VALUES (465,'WebGUI',6,'Text Box Storlek',1031510000);
INSERT INTO international VALUES (466,'WebGUI',6,'Är du säker på att du vill ta bort denna kategori och flytta alla dess attribut till Övrigt kattegorin.',1031510000);
INSERT INTO international VALUES (467,'WebGUI',6,'Är du säker på att du vill ta bort detta attribut och all användar data som finns i det ?',1031510000);
INSERT INTO international VALUES (468,'WebGUI',1,'Edit User Profile Category',1031514049);
INSERT INTO international VALUES (469,'WebGUI',6,'Id',1031510000);
INSERT INTO international VALUES (470,'WebGUI',6,'Namn',1031510000);
INSERT INTO international VALUES (159,'WebGUI',1,'Inbox',1031514049);
INSERT INTO international VALUES (472,'WebGUI',6,'Märke',1031510000);
INSERT INTO international VALUES (473,'WebGUI',6,'Synligt?',1031510000);
INSERT INTO international VALUES (474,'WebGUI',6,'Obligatoriskt?',1031510000);
INSERT INTO international VALUES (475,'WebGUI',6,'Text',1031510000);
INSERT INTO international VALUES (476,'WebGUI',6,'Text Område',1031510000);
INSERT INTO international VALUES (477,'WebGUI',6,'HTML Område',1031510000);
INSERT INTO international VALUES (478,'WebGUI',6,'URL',1031510000);
INSERT INTO international VALUES (479,'WebGUI',6,'Datum',1031510000);
INSERT INTO international VALUES (480,'WebGUI',6,'Email adress',1031510000);
INSERT INTO international VALUES (481,'WebGUI',6,'Telefånnummer',1031510000);
INSERT INTO international VALUES (482,'WebGUI',6,'Nummer (Heltal)',1031510000);
INSERT INTO international VALUES (483,'WebGUI',6,'Ja eller Nej',1031510000);
INSERT INTO international VALUES (484,'WebGUI',6,'Vallista',1031510000);
INSERT INTO international VALUES (485,'WebGUI',6,'Boolean (Kryssbox)',1031510000);
INSERT INTO international VALUES (486,'WebGUI',6,'Data typ',1031510000);
INSERT INTO international VALUES (487,'WebGUI',6,'Möjliga värden',1031510000);
INSERT INTO international VALUES (488,'WebGUI',6,'Standar värden',1031510000);
INSERT INTO international VALUES (489,'WebGUI',6,'Profil kategorier.',1031510000);
INSERT INTO international VALUES (490,'WebGUI',6,'Lägg till en profilkategori.',1031510000);
INSERT INTO international VALUES (491,'WebGUI',6,'Lägg till profilattribut.',1031510000);
INSERT INTO international VALUES (492,'WebGUI',6,'Profil attribut lista.',1031510000);
INSERT INTO international VALUES (493,'WebGUI',6,'Tillbaka till siten.',1031510000);
INSERT INTO international VALUES (507,'WebGUI',1,'Edit Template',1031514049);
INSERT INTO international VALUES (508,'WebGUI',1,'Manage templates.',1031514049);
INSERT INTO international VALUES (39,'UserSubmission',1,'Post a Reply',1031514049);
INSERT INTO international VALUES (40,'UserSubmission',1,'Posted by',1031514049);
INSERT INTO international VALUES (41,'UserSubmission',1,'Date',1031514049);
INSERT INTO international VALUES (8,'Product',1,'Product Image 2',1031514049);
INSERT INTO international VALUES (1,'Product',1,'Product',1031514049);
INSERT INTO international VALUES (45,'UserSubmission',1,'Return to Submission',1031514049);
INSERT INTO international VALUES (46,'UserSubmission',1,'Read more...',1031514049);
INSERT INTO international VALUES (47,'UserSubmission',1,'Post a Response',1031514049);
INSERT INTO international VALUES (48,'UserSubmission',1,'Allow discussion?',1031514049);
INSERT INTO international VALUES (571,'WebGUI',1,'Unlock Thread',1031514049);
INSERT INTO international VALUES (569,'WebGUI',1,'Moderation Type',1031514049);
INSERT INTO international VALUES (567,'WebGUI',1,'Pre-emptive',1031514049);
INSERT INTO international VALUES (51,'UserSubmission',1,'Display thumbnails?',1031514049);
INSERT INTO international VALUES (52,'UserSubmission',1,'Thumbnail',1031514049);
INSERT INTO international VALUES (53,'UserSubmission',1,'Layout',1031514049);
INSERT INTO international VALUES (54,'UserSubmission',1,'Web Log',1031514049);
INSERT INTO international VALUES (55,'UserSubmission',1,'Traditional',1031514049);
INSERT INTO international VALUES (56,'UserSubmission',1,'Photo Gallery',1031514049);
INSERT INTO international VALUES (57,'UserSubmission',1,'Responses',1031514049);
INSERT INTO international VALUES (11,'FAQ',1,'Turn TOC on?',1031514049);
INSERT INTO international VALUES (12,'FAQ',1,'Turn Q/A on?',1031514049);
INSERT INTO international VALUES (13,'FAQ',1,'Turn [top] link on?',1031514049);
INSERT INTO international VALUES (14,'FAQ',1,'Q',1031514049);
INSERT INTO international VALUES (15,'FAQ',1,'A',1031514049);
INSERT INTO international VALUES (16,'FAQ',1,'[top]',1031514049);
INSERT INTO international VALUES (509,'WebGUI',1,'Discussion Layout',1031514049);
INSERT INTO international VALUES (510,'WebGUI',1,'Flat',1031514049);
INSERT INTO international VALUES (511,'WebGUI',1,'Threaded',1031514049);
INSERT INTO international VALUES (512,'WebGUI',1,'Next Thread',1031514049);
INSERT INTO international VALUES (513,'WebGUI',1,'Previous Thread',1031514049);
INSERT INTO international VALUES (8,'Article',10,'henvisning URL',1031510000);
INSERT INTO international VALUES (9,'Article',10,'Vis besvarelser',1031510000);
INSERT INTO international VALUES (10,'Article',10,'Konverter linieskift?',1031510000);
INSERT INTO international VALUES (11,'Article',10,'\"(Kontroller at du ikke tilføjer &lt;br&gt; manuelt.)\"',1031510000);
INSERT INTO international VALUES (12,'Article',10,'rediger artikel',1031510000);
INSERT INTO international VALUES (13,'Article',10,'Slet',1031510000);
INSERT INTO international VALUES (14,'Article',10,'Placer billede',1031510000);
INSERT INTO international VALUES (15,'Article',10,'Højre',1031510000);
INSERT INTO international VALUES (16,'Article',10,'Venstre',1031510000);
INSERT INTO international VALUES (17,'Article',10,'Centreret',1031510000);
INSERT INTO international VALUES (18,'Article',10,'Tillad diskussion?',1031510000);
INSERT INTO international VALUES (3,'Product',1,'Are you certain you wish to delete this feature?',1031514049);
INSERT INTO international VALUES (22,'Article',10,'Forfatter',1031510000);
INSERT INTO international VALUES (23,'Article',10,'Dato',1031510000);
INSERT INTO international VALUES (24,'Article',10,'Send respons',1031510000);
INSERT INTO international VALUES (580,'WebGUI',1,'Your message has been denied.',1031514049);
INSERT INTO international VALUES (27,'Article',10,'Tilbage til artikel',1031510000);
INSERT INTO international VALUES (28,'Article',10,'Vis respons',1031510000);
INSERT INTO international VALUES (1,'DownloadManager',10,'Download Manager',1031510000);
INSERT INTO international VALUES (2,'DownloadManager',10,'Tilføj Download Manager',1031510000);
INSERT INTO international VALUES (3,'DownloadManager',10,'Fortsæt med at tilføje fil?',1031510000);
INSERT INTO international VALUES (4,'DownloadManager',10,'Tilføj Download',1031510000);
INSERT INTO international VALUES (5,'DownloadManager',10,'Navn på fil',1031510000);
INSERT INTO international VALUES (6,'DownloadManager',10,'Hent fil',1031510000);
INSERT INTO international VALUES (7,'DownloadManager',10,'Gruppe til Download',1031510000);
INSERT INTO international VALUES (8,'DownloadManager',10,'Kort beskrivelse',1031510000);
INSERT INTO international VALUES (9,'DownloadManager',10,'rediger Download Manager',1031510000);
INSERT INTO international VALUES (10,'DownloadManager',10,'rediger Download  ',1031510000);
INSERT INTO international VALUES (11,'DownloadManager',10,'Tilføj ny Download',1031510000);
INSERT INTO international VALUES (12,'DownloadManager',10,'Er du sikker på du vil slette denne Download?',1031510000);
INSERT INTO international VALUES (13,'DownloadManager',10,'Slet tilføjet fil?',1031510000);
INSERT INTO international VALUES (14,'DownloadManager',10,'Fil',1031510000);
INSERT INTO international VALUES (15,'DownloadManager',10,'Beskrivelse',1031510000);
INSERT INTO international VALUES (16,'DownloadManager',10,'Oprettelsesdato',1031510000);
INSERT INTO international VALUES (17,'DownloadManager',10,'Alternativ version nr. 1',1031510000);
INSERT INTO international VALUES (18,'DownloadManager',10,'Alternativ version nr. 2',1031510000);
INSERT INTO international VALUES (19,'DownloadManager',10,'Du har ikke nogen filer til Download',1031510000);
INSERT INTO international VALUES (20,'DownloadManager',10,'Slet efter',1031510000);
INSERT INTO international VALUES (21,'DownloadManager',10,'Hvis miniature?',1031510000);
INSERT INTO international VALUES (1,'EventsCalendar',10,'Fortsæt med at tilføje begivenhed?',1031510000);
INSERT INTO international VALUES (2,'EventsCalendar',10,'Begivenheds kalender',1031510000);
INSERT INTO international VALUES (3,'EventsCalendar',10,'Tilføj begivenheds kalender',1031510000);
INSERT INTO international VALUES (4,'EventsCalendar',10,'Begivenhed sker én gang',1031510000);
INSERT INTO international VALUES (700,'WebGUI',10,'dag',1031510000);
INSERT INTO international VALUES (701,'WebGUI',10,'uge',1031510000);
INSERT INTO international VALUES (7,'EventsCalendar',10,'Tilføj begivenhed ',1031510000);
INSERT INTO international VALUES (8,'EventsCalendar',10,'Gentages hver',1031510000);
INSERT INTO international VALUES (9,'EventsCalendar',10,'indtil',1031510000);
INSERT INTO international VALUES (61,'Product',1,'Product Template',1031514049);
INSERT INTO international VALUES (12,'EventsCalendar',10,'rediger begivenheds kalender',1031510000);
INSERT INTO international VALUES (13,'EventsCalendar',10,'rediger begivenhed ',1031510000);
INSERT INTO international VALUES (14,'EventsCalendar',10,'Fra dato',1031510000);
INSERT INTO international VALUES (15,'EventsCalendar',10,'Til dato',1031510000);
INSERT INTO international VALUES (16,'EventsCalendar',10,'Kalender layout',1031510000);
INSERT INTO international VALUES (17,'EventsCalendar',10,'Liste',1031510000);
INSERT INTO international VALUES (18,'EventsCalendar',10,'Calendar Month',1031510000);
INSERT INTO international VALUES (19,'EventsCalendar',10,'Slet efter ',1031510000);
INSERT INTO international VALUES (1,'ExtraColumn',10,'Ekstra kolonne',1031510000);
INSERT INTO international VALUES (2,'ExtraColumn',10,'Tilføj ekstra kolonne',1031510000);
INSERT INTO international VALUES (3,'ExtraColumn',10,'Mellemrum',1031510000);
INSERT INTO international VALUES (4,'ExtraColumn',10,'Bredde',1031510000);
INSERT INTO international VALUES (5,'ExtraColumn',10,'stilarter klasse',1031510000);
INSERT INTO international VALUES (6,'ExtraColumn',10,'rediger ekstra kolonne',1031510000);
INSERT INTO international VALUES (1,'FAQ',10,'Fortsæt med at tilføje spørgsmål?',1031510000);
INSERT INTO international VALUES (2,'FAQ',10,'Ofte stillede spørgsmål (F.A.Q.)',1031510000);
INSERT INTO international VALUES (3,'FAQ',10,'Tilføj F.A.Q.',1031510000);
INSERT INTO international VALUES (4,'FAQ',10,'Tilføj spørgsmål',1031510000);
INSERT INTO international VALUES (5,'FAQ',10,'Spørgsmål',1031510000);
INSERT INTO international VALUES (6,'FAQ',10,'Svar',1031510000);
INSERT INTO international VALUES (7,'FAQ',10,'Er du sikker på du vil slette dette spørgsmål',1031510000);
INSERT INTO international VALUES (8,'FAQ',10,'Rediger F.A.Q.',1031510000);
INSERT INTO international VALUES (9,'FAQ',10,'Tilføj nyt spørgsmål',1031510000);
INSERT INTO international VALUES (10,'FAQ',10,'rediger spørgsmål',1031510000);
INSERT INTO international VALUES (1,'Item',10,'henvisning URL',1031510000);
INSERT INTO international VALUES (2,'Item',10,'Vedhæft',1031510000);
INSERT INTO international VALUES (3,'Item',10,'Slet vedhæft',1031510000);
INSERT INTO international VALUES (4,'Item',10,'Item',1031510000);
INSERT INTO international VALUES (5,'Item',10,'Hent vedhæftet',1031510000);
INSERT INTO international VALUES (1,'LinkList',10,'Indryk',1031510000);
INSERT INTO international VALUES (2,'LinkList',10,'Linie afstand',1031510000);
INSERT INTO international VALUES (3,'LinkList',10,'Skal der åbnes i nyt vindue?',1031510000);
INSERT INTO international VALUES (4,'LinkList',10,'Punkt',1031510000);
INSERT INTO international VALUES (5,'LinkList',10,'Fortsæt med at tilføje henvisning',1031510000);
INSERT INTO international VALUES (6,'LinkList',10,'Liste over henvisning',1031510000);
INSERT INTO international VALUES (7,'LinkList',10,'Tilføj henvisning',1031510000);
INSERT INTO international VALUES (8,'LinkList',10,'URL',1031510000);
INSERT INTO international VALUES (9,'LinkList',10,'Er du sikker på du vil slette denne henvisning',1031510000);
INSERT INTO international VALUES (10,'LinkList',10,'Rediger henvisnings liste',1031510000);
INSERT INTO international VALUES (11,'LinkList',10,'Tilføj henvisnings liste',1031510000);
INSERT INTO international VALUES (12,'LinkList',10,'Rediger henvisning  ',1031510000);
INSERT INTO international VALUES (13,'LinkList',10,'Tilføj ny henvisning',1031510000);
INSERT INTO international VALUES (1,'MessageBoard',10,'Tilføj opslagstavle',1031510000);
INSERT INTO international VALUES (2,'MessageBoard',10,'Opslagstavle',1031510000);
INSERT INTO international VALUES (564,'WebGUI',10,'Hvem kan komme med indlæg?',1031510000);
INSERT INTO international VALUES (4,'MessageBoard',10,'Antal beskeder pr. side',1031510000);
INSERT INTO international VALUES (566,'WebGUI',10,'Rediger Timeout',1031510000);
INSERT INTO international VALUES (6,'MessageBoard',10,'Rediger opslagstavle',1031510000);
INSERT INTO international VALUES (7,'MessageBoard',10,'Forfatter:',1031510000);
INSERT INTO international VALUES (8,'MessageBoard',10,'Dato:',1031510000);
INSERT INTO international VALUES (9,'MessageBoard',10,'Besked nr.:',1031510000);
INSERT INTO international VALUES (10,'MessageBoard',10,'Forrige tråd',1031510000);
INSERT INTO international VALUES (11,'MessageBoard',10,'Tilbage til oversigt',1031510000);
INSERT INTO international VALUES (12,'MessageBoard',10,'Rediger meddelelses',1031510000);
INSERT INTO international VALUES (577,'WebGUI',10,'Send respons',1031510000);
INSERT INTO international VALUES (14,'MessageBoard',10,'Næste tråd',1031510000);
INSERT INTO international VALUES (15,'MessageBoard',10,'Forfatter',1031510000);
INSERT INTO international VALUES (16,'MessageBoard',10,'Dato',1031510000);
INSERT INTO international VALUES (17,'MessageBoard',10,'Ny meddelelse',1031510000);
INSERT INTO international VALUES (18,'MessageBoard',10,'Tråd startet',1031510000);
INSERT INTO international VALUES (19,'MessageBoard',10,'Antal svar',1031510000);
INSERT INTO international VALUES (20,'MessageBoard',10,'Seneste svar',1031510000);
INSERT INTO international VALUES (565,'WebGUI',10,'Hvem kan moderere?',1031510000);
INSERT INTO international VALUES (22,'MessageBoard',10,'Slet besked',1031510000);
INSERT INTO international VALUES (1,'Poll',10,'Afstemning',1031510000);
INSERT INTO international VALUES (2,'Poll',10,'Tilføj afstemning',1031510000);
INSERT INTO international VALUES (3,'Poll',10,'Aktiv',1031510000);
INSERT INTO international VALUES (4,'Poll',10,'Hvem kan stemme',1031510000);
INSERT INTO international VALUES (5,'Poll',10,'Bredde på graf',1031510000);
INSERT INTO international VALUES (6,'Poll',10,'Spørgsmål',1031510000);
INSERT INTO international VALUES (7,'Poll',10,'Svar',1031510000);
INSERT INTO international VALUES (8,'Poll',10,'(Indtast ét svar pr. linie. Ikke mere end 20.)',1031510000);
INSERT INTO international VALUES (9,'Poll',10,'Rediger afstemning',1031510000);
INSERT INTO international VALUES (10,'Poll',10,'Nulstil afstemning',1031510000);
INSERT INTO international VALUES (11,'Poll',10,'Stem!',1031510000);
INSERT INTO international VALUES (1,'SiteMap',10,'Tilføj Site oversigt',1031510000);
INSERT INTO international VALUES (2,'SiteMap',10,'Site oversigt',1031510000);
INSERT INTO international VALUES (3,'SiteMap',10,'Startende fra dette niveau',1031510000);
INSERT INTO international VALUES (4,'SiteMap',10,'Dybde?',1031510000);
INSERT INTO international VALUES (5,'SiteMap',10,'Rediger Site oversigt',1031510000);
INSERT INTO international VALUES (6,'SiteMap',10,'Indryk',1031510000);
INSERT INTO international VALUES (7,'SiteMap',10,'Punkt',1031510000);
INSERT INTO international VALUES (8,'SiteMap',10,'Linie afstand',1031510000);
INSERT INTO international VALUES (9,'SiteMap',10,'Vis synopsis?',1031510000);
INSERT INTO international VALUES (1,'SQLReport',10,'SQL rapport',1031510000);
INSERT INTO international VALUES (2,'SQLReport',10,'Tilføj SQL rapport',1031510000);
INSERT INTO international VALUES (3,'SQLReport',10,'Rapport template',1031510000);
INSERT INTO international VALUES (4,'SQLReport',10,'Query',1031510000);
INSERT INTO international VALUES (5,'SQLReport',10,'DSN',1031510000);
INSERT INTO international VALUES (6,'SQLReport',10,'Database bruger',1031510000);
INSERT INTO international VALUES (7,'SQLReport',10,'Database Password',1031510000);
INSERT INTO international VALUES (8,'SQLReport',10,'Rediger SQL rapport',1031510000);
INSERT INTO international VALUES (9,'SQLReport',10,'<b>Debug:</b> Error: The DSN specified is of an improper format.',1031510000);
INSERT INTO international VALUES (10,'SQLReport',10,'<b>Debug:</b> Error: The SQL specified is of an improper format.',1031510000);
INSERT INTO international VALUES (11,'SQLReport',10,'<b>Debug:</b> Error: There was a problem with the query.',1031510000);
INSERT INTO international VALUES (12,'SQLReport',10,'<b>Debug:</b> Error: Could not connect to the database.',1031510000);
INSERT INTO international VALUES (13,'SQLReport',10,'Konverter linieskift?',1031510000);
INSERT INTO international VALUES (14,'SQLReport',10,'Slet efter',1031510000);
INSERT INTO international VALUES (15,'SQLReport',10,'Udfør makroer ved forespørgsel?',1031510000);
INSERT INTO international VALUES (16,'SQLReport',10,'Debut?',1031510000);
INSERT INTO international VALUES (17,'SQLReport',10,'<b>Debug:</b> Query:',1031510000);
INSERT INTO international VALUES (18,'SQLReport',10,'Der var ikke nogen svar til denne forespørgsel!',1031510000);
INSERT INTO international VALUES (1,'SyndicatedContent',10,'URL til RSS fil',1031510000);
INSERT INTO international VALUES (2,'SyndicatedContent',10,'Syndicated Content',1031510000);
INSERT INTO international VALUES (3,'SyndicatedContent',10,'Tilføj Syndicated Content',1031510000);
INSERT INTO international VALUES (4,'SyndicatedContent',10,'Rediger Syndicated Content',1031510000);
INSERT INTO international VALUES (5,'SyndicatedContent',10,'Sidst opdateret',1031510000);
INSERT INTO international VALUES (6,'SyndicatedContent',10,'Gældende indhold',1031510000);
INSERT INTO international VALUES (1,'UserSubmission',10,'Hvem kan godkende indlæg?',1031510000);
INSERT INTO international VALUES (2,'UserSubmission',10,'Hvem kan tilføje indlæg?',1031510000);
INSERT INTO international VALUES (3,'UserSubmission',10,'Du har nye indlæg til godkendelse',1031510000);
INSERT INTO international VALUES (4,'UserSubmission',10,'Dit indlæg er godkendt',1031510000);
INSERT INTO international VALUES (5,'UserSubmission',10,'Dit indlæg er afvist',1031510000);
INSERT INTO international VALUES (6,'UserSubmission',10,'Antal indlæg pr. side',1031510000);
INSERT INTO international VALUES (560,'WebGUI',10,'Godkendt',1031510000);
INSERT INTO international VALUES (561,'WebGUI',10,'Afvist',1031510000);
INSERT INTO international VALUES (562,'WebGUI',10,'Afventer',1031510000);
INSERT INTO international VALUES (563,'WebGUI',10,'Default Status',1031510000);
INSERT INTO international VALUES (11,'UserSubmission',10,'Tilføj indlæg',1031510000);
INSERT INTO international VALUES (12,'UserSubmission',10,'(Kryds ikke hvis du laver et HTML indlæg.)',1031510000);
INSERT INTO international VALUES (13,'UserSubmission',10,'Tilføjet dato',1031510000);
INSERT INTO international VALUES (14,'UserSubmission',10,'Status',1031510000);
INSERT INTO international VALUES (15,'UserSubmission',10,'Rediger/Slet',1031510000);
INSERT INTO international VALUES (16,'UserSubmission',10,'Ingen titel',1031510000);
INSERT INTO international VALUES (17,'UserSubmission',10,'Er du sikker på du vil slette dette indlæg?',1031510000);
INSERT INTO international VALUES (18,'UserSubmission',10,'Rediger User Submission System',1031510000);
INSERT INTO international VALUES (19,'UserSubmission',10,'Rediger indlæg',1031510000);
INSERT INTO international VALUES (20,'UserSubmission',10,'Lav nyt indlæg',1031510000);
INSERT INTO international VALUES (21,'UserSubmission',10,'Indsendt af',1031510000);
INSERT INTO international VALUES (22,'UserSubmission',10,'Indsendt af:',1031510000);
INSERT INTO international VALUES (23,'UserSubmission',10,'Indsendt dato:',1031510000);
INSERT INTO international VALUES (572,'WebGUI',10,'Godkendt',1031510000);
INSERT INTO international VALUES (573,'WebGUI',10,'Afvent ',1031510000);
INSERT INTO international VALUES (574,'WebGUI',10,'Afvist',1031510000);
INSERT INTO international VALUES (27,'UserSubmission',10,'Rediger',1031510000);
INSERT INTO international VALUES (28,'UserSubmission',10,'Tilbage til Submission oversigt',1031510000);
INSERT INTO international VALUES (29,'UserSubmission',10,'Bruger Indlæg',1031510000);
INSERT INTO international VALUES (31,'UserSubmission',10,'Indhold',1031510000);
INSERT INTO international VALUES (32,'UserSubmission',10,'Billede',1031510000);
INSERT INTO international VALUES (33,'UserSubmission',10,'Tillæg',1031510000);
INSERT INTO international VALUES (34,'UserSubmission',10,'Konverter linieskift?',1031510000);
INSERT INTO international VALUES (35,'UserSubmission',10,'Titel',1031510000);
INSERT INTO international VALUES (36,'UserSubmission',10,'Slet fil.',1031510000);
INSERT INTO international VALUES (37,'UserSubmission',10,'Slet',1031510000);
INSERT INTO international VALUES (1,'WebGUI',10,'Tilføj indhold',1031510000);
INSERT INTO international VALUES (2,'WebGUI',10,'Side',1031510000);
INSERT INTO international VALUES (3,'WebGUI',10,'Kopier fra udklipsholder',1031510000);
INSERT INTO international VALUES (4,'WebGUI',10,'administrer indstillinger',1031510000);
INSERT INTO international VALUES (5,'WebGUI',10,'administrer grupper',1031510000);
INSERT INTO international VALUES (6,'WebGUI',10,'administrer Stilarter',1031510000);
INSERT INTO international VALUES (7,'WebGUI',10,'administrer brugere',1031510000);
INSERT INTO international VALUES (8,'WebGUI',10,'Vis side_ikke_fundet',1031510000);
INSERT INTO international VALUES (9,'WebGUI',10,'Vis udklipsholder',1031510000);
INSERT INTO international VALUES (10,'WebGUI',10,'administrer skraldespand',1031510000);
INSERT INTO international VALUES (11,'WebGUI',10,'Tøm skraldespand',1031510000);
INSERT INTO international VALUES (12,'WebGUI',10,'Slå administration fra',1031510000);
INSERT INTO international VALUES (13,'WebGUI',10,'Vis hjælpe indeks',1031510000);
INSERT INTO international VALUES (14,'WebGUI',10,'Vis afventende indlæg',1031510000);
INSERT INTO international VALUES (15,'WebGUI',10,'Januar',1031510000);
INSERT INTO international VALUES (16,'WebGUI',10,'Februar',1031510000);
INSERT INTO international VALUES (17,'WebGUI',10,'Marts',1031510000);
INSERT INTO international VALUES (18,'WebGUI',10,'April',1031510000);
INSERT INTO international VALUES (19,'WebGUI',10,'Maj',1031510000);
INSERT INTO international VALUES (20,'WebGUI',10,'Juni',1031510000);
INSERT INTO international VALUES (21,'WebGUI',10,'Juli',1031510000);
INSERT INTO international VALUES (22,'WebGUI',10,'August',1031510000);
INSERT INTO international VALUES (23,'WebGUI',10,'September',1031510000);
INSERT INTO international VALUES (24,'WebGUI',10,'Oktober',1031510000);
INSERT INTO international VALUES (25,'WebGUI',10,'November',1031510000);
INSERT INTO international VALUES (26,'WebGUI',10,'December',1031510000);
INSERT INTO international VALUES (27,'WebGUI',10,'Søndag',1031510000);
INSERT INTO international VALUES (28,'WebGUI',10,'Mandag',1031510000);
INSERT INTO international VALUES (29,'WebGUI',10,'Tirsdag',1031510000);
INSERT INTO international VALUES (30,'WebGUI',10,'Onsdag',1031510000);
INSERT INTO international VALUES (31,'WebGUI',10,'Torsdag',1031510000);
INSERT INTO international VALUES (32,'WebGUI',10,'Fredag',1031510000);
INSERT INTO international VALUES (33,'WebGUI',10,'Lørdag',1031510000);
INSERT INTO international VALUES (34,'WebGUI',10,'Sæt dato',1031510000);
INSERT INTO international VALUES (35,'WebGUI',10,'Administrative funktioner',1031510000);
INSERT INTO international VALUES (36,'WebGUI',10,'Du skal være administrator for at udføre denne funktion. Kontakt en af følgende personer der er administratorer:',1031510000);
INSERT INTO international VALUES (37,'WebGUI',10,'Adgang nægtet!',1031510000);
INSERT INTO international VALUES (38,'WebGUI',10,'\"Du har ikke nødvendige rettigheder til at udføre denne funktion. Venligst log in ^a(log in med en konto); med nødvendige rettigheder før du prøver dette.\"',1031510000);
INSERT INTO international VALUES (39,'WebGUI',10,'Du har ikke rettigheder til at få adgang til denne side.',1031510000);
INSERT INTO international VALUES (40,'WebGUI',10,'Vital komponent',1031510000);
INSERT INTO international VALUES (41,'WebGUI',10,'DU forsøger at fjerne en VITAL system komponent. Hvis du fik lov til dette, ville systemet ikke virke mere …..',1031510000);
INSERT INTO international VALUES (42,'WebGUI',10,'Venligst bekræft',1031510000);
INSERT INTO international VALUES (43,'WebGUI',10,'Er du sikker på du vil slette dette indhold?',1031510000);
INSERT INTO international VALUES (44,'WebGUI',10,'Ja, jeg er sikker!',1031510000);
INSERT INTO international VALUES (45,'WebGUI',10,'Nej, jeg lavede en fejl',1031510000);
INSERT INTO international VALUES (46,'WebGUI',10,'Min konto',1031510000);
INSERT INTO international VALUES (47,'WebGUI',10,'Hjem',1031510000);
INSERT INTO international VALUES (48,'WebGUI',10,'Hej',1031510000);
INSERT INTO international VALUES (49,'WebGUI',10,'\"Klik <a href=\"\"^\\;?op=logout\"\">her</a> for at logge ud.\"',1031510000);
INSERT INTO international VALUES (50,'WebGUI',10,'Brugernavn',1031510000);
INSERT INTO international VALUES (51,'WebGUI',10,'Kodeord',1031510000);
INSERT INTO international VALUES (52,'WebGUI',10,'Login',1031510000);
INSERT INTO international VALUES (53,'WebGUI',10,'Print side',1031510000);
INSERT INTO international VALUES (54,'WebGUI',10,'Opret konto',1031510000);
INSERT INTO international VALUES (55,'WebGUI',10,'Kodeord (bekræft)',1031510000);
INSERT INTO international VALUES (56,'WebGUI',10,'Email Adresse',1031510000);
INSERT INTO international VALUES (57,'WebGUI',10,'Dette er kun nødvendigt hvis du bruger en funktion der kræver Email',1031510000);
INSERT INTO international VALUES (58,'WebGUI',10,'Jeg har allerede en konto',1031510000);
INSERT INTO international VALUES (59,'WebGUI',10,'Jeg har glemt mit kodeord (igen)',1031510000);
INSERT INTO international VALUES (60,'WebGUI',10,'Er du sikker på du vil deaktivere din konto. Kontoen kan IKKE åbnes igen.',1031510000);
INSERT INTO international VALUES (61,'WebGUI',10,'Opdater konto information',1031510000);
INSERT INTO international VALUES (62,'WebGUI',10,'Gem',1031510000);
INSERT INTO international VALUES (63,'WebGUI',10,'Slå administration til.',1031510000);
INSERT INTO international VALUES (64,'WebGUI',10,'Log ud.',1031510000);
INSERT INTO international VALUES (65,'WebGUI',10,'Venligst de-aktiver min konto permanent.',1031510000);
INSERT INTO international VALUES (66,'WebGUI',10,'Log In',1031510000);
INSERT INTO international VALUES (67,'WebGUI',10,'Opret ny konto',1031510000);
INSERT INTO international VALUES (68,'WebGUI',10,'Konto informationen er ikke gyldig. Enten eksisterer kontoen ikke, eller også er brugernavn/kodeord forkert',1031510000);
INSERT INTO international VALUES (69,'WebGUI',10,'Kontakt venligst systemadministratoren for yderligere hjælp!',1031510000);
INSERT INTO international VALUES (70,'WebGUI',10,'Fejl',1031510000);
INSERT INTO international VALUES (71,'WebGUI',10,'Genskab kodeord',1031510000);
INSERT INTO international VALUES (72,'WebGUI',10,'Genskab  ',1031510000);
INSERT INTO international VALUES (73,'WebGUI',10,'Log in.',1031510000);
INSERT INTO international VALUES (74,'WebGUI',10,'Konto information.',1031510000);
INSERT INTO international VALUES (75,'WebGUI',10,'Din konto information er sendt til den oplyste Email adresse',1031510000);
INSERT INTO international VALUES (76,'WebGUI',10,'Email adressen er ikke registreret i systemet',1031510000);
INSERT INTO international VALUES (77,'WebGUI',10,'Det brugernavn er desværre allerede brugt af en anden. Prøv evt. en af disse:',1031510000);
INSERT INTO international VALUES (78,'WebGUI',10,'Du har indtastet to forskellige kodeord - prøv igen!',1031510000);
INSERT INTO international VALUES (79,'WebGUI',10,'Kan ikke forbinde til LDAP server',1031510000);
INSERT INTO international VALUES (80,'WebGUI',10,'Konto er nu oprettet!',1031510000);
INSERT INTO international VALUES (81,'WebGUI',10,'Konto er nu opdateret.',1031510000);
INSERT INTO international VALUES (82,'WebGUI',10,'Administrative funktioner',1031510000);
INSERT INTO international VALUES (84,'WebGUI',10,'Gruppe navn',1031510000);
INSERT INTO international VALUES (85,'WebGUI',10,'Beskrivelse',1031510000);
INSERT INTO international VALUES (86,'WebGUI',10,'Er du sikker på du vil slette denne gruppe? - og dermed alle rettigheder der er knyttet hertil',1031510000);
INSERT INTO international VALUES (87,'WebGUI',10,'Rediger gruppe',1031510000);
INSERT INTO international VALUES (88,'WebGUI',10,'brugere i gruppe',1031510000);
INSERT INTO international VALUES (89,'WebGUI',10,'Grupper',1031510000);
INSERT INTO international VALUES (90,'WebGUI',10,'Tilføj gruppe',1031510000);
INSERT INTO international VALUES (91,'WebGUI',10,'Forrige side',1031510000);
INSERT INTO international VALUES (92,'WebGUI',10,'Næste side',1031510000);
INSERT INTO international VALUES (93,'WebGUI',10,'Hjælp',1031510000);
INSERT INTO international VALUES (94,'WebGUI',10,'Se også',1031510000);
INSERT INTO international VALUES (95,'WebGUI',10,'Hjælpe indeks',1031510000);
INSERT INTO international VALUES (98,'WebGUI',10,'Tilføj side',1031510000);
INSERT INTO international VALUES (99,'WebGUI',10,'Titel',1031510000);
INSERT INTO international VALUES (100,'WebGUI',10,'Meta Tags',1031510000);
INSERT INTO international VALUES (101,'WebGUI',10,'Er du sikker på du vil slette denne side, og alt indhold derunder?',1031510000);
INSERT INTO international VALUES (102,'WebGUI',10,'Rediger side',1031510000);
INSERT INTO international VALUES (103,'WebGUI',10,'Side specifikationer',1031510000);
INSERT INTO international VALUES (104,'WebGUI',10,'Side URL',1031510000);
INSERT INTO international VALUES (105,'WebGUI',10,'Stil',1031510000);
INSERT INTO international VALUES (106,'WebGUI',10,'Sæt kryds for at give denne stil til alle undersider',1031510000);
INSERT INTO international VALUES (107,'WebGUI',10,'Rettigheder',1031510000);
INSERT INTO international VALUES (108,'WebGUI',10,'Ejer',1031510000);
INSERT INTO international VALUES (109,'WebGUI',10,'Ejer kan se?',1031510000);
INSERT INTO international VALUES (110,'WebGUI',10,'Ejer kan redigere?',1031510000);
INSERT INTO international VALUES (111,'WebGUI',10,'Gruppe',1031510000);
INSERT INTO international VALUES (112,'WebGUI',10,'Gruppe kan se?',1031510000);
INSERT INTO international VALUES (113,'WebGUI',10,'Gruppe kan redigere?',1031510000);
INSERT INTO international VALUES (114,'WebGUI',10,'Alle kan se?',1031510000);
INSERT INTO international VALUES (115,'WebGUI',10,'Alle kan redigere?',1031510000);
INSERT INTO international VALUES (116,'WebGUI',10,'Sæt kryds for at give disse rettigheder til alle undersider',1031510000);
INSERT INTO international VALUES (117,'WebGUI',10,'Rediger autorisations indstillinger',1031510000);
INSERT INTO international VALUES (118,'WebGUI',10,'Anonym registrering',1031510000);
INSERT INTO international VALUES (119,'WebGUI',10,'autorisations metode (default)',1031510000);
INSERT INTO international VALUES (120,'WebGUI',10,'LDAP URL (default)',1031510000);
INSERT INTO international VALUES (121,'WebGUI',10,'LDAP Identitet (default)',1031510000);
INSERT INTO international VALUES (122,'WebGUI',10,'LDAP Identitets navn',1031510000);
INSERT INTO international VALUES (123,'WebGUI',10,'LDAP kodeord',1031510000);
INSERT INTO international VALUES (124,'WebGUI',10,'Rediger firma information',1031510000);
INSERT INTO international VALUES (125,'WebGUI',10,'Firma/organisations navn',1031510000);
INSERT INTO international VALUES (126,'WebGUI',10,'Firma/organisations Email',1031510000);
INSERT INTO international VALUES (127,'WebGUI',10,'Firma/organisation URL',1031510000);
INSERT INTO international VALUES (130,'WebGUI',10,'Maksimal størrelse på vedhæftede filer',1031510000);
INSERT INTO international VALUES (133,'WebGUI',10,'Rediger Mail indstillinger',1031510000);
INSERT INTO international VALUES (134,'WebGUI',10,'Besked for genskab adgangskode',1031510000);
INSERT INTO international VALUES (135,'WebGUI',10,'SMTP Server',1031510000);
INSERT INTO international VALUES (138,'WebGUI',10,'Ja',1031510000);
INSERT INTO international VALUES (139,'WebGUI',10,'Nej ',1031510000);
INSERT INTO international VALUES (140,'WebGUI',10,'Rediger diverse indstillinger',1031510000);
INSERT INTO international VALUES (141,'WebGUI',10,'Ikke fundet side',1031510000);
INSERT INTO international VALUES (142,'WebGUI',10,'Session Timeout',1031510000);
INSERT INTO international VALUES (143,'WebGUI',10,'administrer indstillinger',1031510000);
INSERT INTO international VALUES (144,'WebGUI',10,'Vis statistik',1031510000);
INSERT INTO international VALUES (145,'WebGUI',10,'WebGUI Build Version',1031510000);
INSERT INTO international VALUES (146,'WebGUI',10,'Aktive sessioner',1031510000);
INSERT INTO international VALUES (147,'WebGUI',10,'Sider',1031510000);
INSERT INTO international VALUES (148,'WebGUI',10,'Wobjects',1031510000);
INSERT INTO international VALUES (149,'WebGUI',10,'brugere i gruppe',1031510000);
INSERT INTO international VALUES (151,'WebGUI',10,'Navn på stilart',1031510000);
INSERT INTO international VALUES (152,'WebGUI',10,'Hoved',1031510000);
INSERT INTO international VALUES (153,'WebGUI',10,'Fod',1031510000);
INSERT INTO international VALUES (154,'WebGUI',10,'Stilart Sheet',1031510000);
INSERT INTO international VALUES (155,'WebGUI',10,'\"Er du sikker på du vil slette denne stilart og overføre alle sider der bruger denne til \"\"Fail Safe\"\" stilarten ?\"',1031510000);
INSERT INTO international VALUES (156,'WebGUI',10,'Rediger stilart',1031510000);
INSERT INTO international VALUES (157,'WebGUI',10,'stilarter',1031510000);
INSERT INTO international VALUES (158,'WebGUI',10,'Tilføj ny stilart',1031510000);
INSERT INTO international VALUES (159,'WebGUI',10,'Meddelelses log',1031510000);
INSERT INTO international VALUES (160,'WebGUI',10,'Dato oprettet',1031510000);
INSERT INTO international VALUES (161,'WebGUI',10,'Oprettet af',1031510000);
INSERT INTO international VALUES (162,'WebGUI',10,'Er du sikker på du vil tømme skraldespanden?',1031510000);
INSERT INTO international VALUES (163,'WebGUI',10,'Tilføj bruger  ',1031510000);
INSERT INTO international VALUES (164,'WebGUI',10,'Metode for autorisation',1031510000);
INSERT INTO international VALUES (165,'WebGUI',10,'LDAP URL',1031510000);
INSERT INTO international VALUES (166,'WebGUI',10,'Connect DN',1031510000);
INSERT INTO international VALUES (167,'WebGUI',10,'Er du sikker på du vil slette denne bruger? (Du kan ikke fortryde)',1031510000);
INSERT INTO international VALUES (168,'WebGUI',10,'Rediger bruger',1031510000);
INSERT INTO international VALUES (169,'WebGUI',10,'Tilføj ny bruger',1031510000);
INSERT INTO international VALUES (170,'WebGUI',10,'Søg',1031510000);
INSERT INTO international VALUES (171,'WebGUI',10,'Avanceret redigering',1031510000);
INSERT INTO international VALUES (174,'WebGUI',10,'Vis titel på siden?',1031510000);
INSERT INTO international VALUES (175,'WebGUI',10,'Udfør makroer?',1031510000);
INSERT INTO international VALUES (228,'WebGUI',10,'Rediger besked…',1031510000);
INSERT INTO international VALUES (229,'WebGUI',10,'Emne',1031510000);
INSERT INTO international VALUES (230,'WebGUI',10,'Besked  ',1031510000);
INSERT INTO international VALUES (231,'WebGUI',10,'Oprettet ny besked …',1031510000);
INSERT INTO international VALUES (232,'WebGUI',10,'Intet emne',1031510000);
INSERT INTO international VALUES (233,'WebGUI',10,'(eom)',1031510000);
INSERT INTO international VALUES (234,'WebGUI',10,'Oprettet svar …',1031510000);
INSERT INTO international VALUES (237,'WebGUI',10,'Emne:',1031510000);
INSERT INTO international VALUES (238,'WebGUI',10,'Forfatter:',1031510000);
INSERT INTO international VALUES (239,'WebGUI',10,'Dato:',1031510000);
INSERT INTO international VALUES (240,'WebGUI',10,'Besked ID:',1031510000);
INSERT INTO international VALUES (244,'WebGUI',10,'Forfatter ',1031510000);
INSERT INTO international VALUES (245,'WebGUI',10,'Dato',1031510000);
INSERT INTO international VALUES (304,'WebGUI',10,'Sprog',1031510000);
INSERT INTO international VALUES (306,'WebGUI',10,'Brugernavn binding',1031510000);
INSERT INTO international VALUES (307,'WebGUI',10,'Brug standard meta tags?',1031510000);
INSERT INTO international VALUES (308,'WebGUI',10,'Rediger profil indstillinger',1031510000);
INSERT INTO international VALUES (309,'WebGUI',10,'Tillad rigtige navne?',1031510000);
INSERT INTO international VALUES (310,'WebGUI',10,'Tillad ekstra kontakt information?',1031510000);
INSERT INTO international VALUES (311,'WebGUI',10,'Tillad hjemme information?',1031510000);
INSERT INTO international VALUES (312,'WebGUI',10,'Tillad arbejds information?',1031510000);
INSERT INTO international VALUES (313,'WebGUI',10,'Tillad diverse information?',1031510000);
INSERT INTO international VALUES (314,'WebGUI',10,'Fornavn',1031510000);
INSERT INTO international VALUES (315,'WebGUI',10,'Mellemnavn',1031510000);
INSERT INTO international VALUES (316,'WebGUI',10,'Efternavn',1031510000);
INSERT INTO international VALUES (317,'WebGUI',10,'\"<a href=\"\"http://www.icq.com\"\">ICQ</a> UIN\"',1031510000);
INSERT INTO international VALUES (318,'WebGUI',10,'\"<a href=\"\"http://www.aol.com/aim/homenew.adp\"\">AIM</a> Id\"',1031510000);
INSERT INTO international VALUES (319,'WebGUI',10,'\"<a href=\"\"http://messenger.msn.com/\"\">MSN Messenger</a> Id\"',1031510000);
INSERT INTO international VALUES (320,'WebGUI',10,'\"<a href=\"\"http://messenger.yahoo.com/\"\">Yahoo! Messenger</a> Id\"',1031510000);
INSERT INTO international VALUES (321,'WebGUI',10,'Bil tlf.',1031510000);
INSERT INTO international VALUES (322,'WebGUI',10,'OPS',1031510000);
INSERT INTO international VALUES (323,'WebGUI',10,'Hjemme adresse',1031510000);
INSERT INTO international VALUES (324,'WebGUI',10,'Hjemme by',1031510000);
INSERT INTO international VALUES (325,'WebGUI',10,'Hjemme stat',1031510000);
INSERT INTO international VALUES (326,'WebGUI',10,'Hjemme postnr.',1031510000);
INSERT INTO international VALUES (327,'WebGUI',10,'Hjemme amt',1031510000);
INSERT INTO international VALUES (328,'WebGUI',10,'Hjemme tlf.',1031510000);
INSERT INTO international VALUES (329,'WebGUI',10,'Arbejds adresse',1031510000);
INSERT INTO international VALUES (330,'WebGUI',10,'Arbejds by',1031510000);
INSERT INTO international VALUES (331,'WebGUI',10,'Arbejds stat',1031510000);
INSERT INTO international VALUES (332,'WebGUI',10,'Arbejds postnr.',1031510000);
INSERT INTO international VALUES (333,'WebGUI',10,'Arbejds amt',1031510000);
INSERT INTO international VALUES (334,'WebGUI',10,'Arbejds tlf.',1031510000);
INSERT INTO international VALUES (335,'WebGUI',10,'M/K',1031510000);
INSERT INTO international VALUES (336,'WebGUI',10,'Fødselsdag',1031510000);
INSERT INTO international VALUES (337,'WebGUI',10,'Hjemmeside URL',1031510000);
INSERT INTO international VALUES (338,'WebGUI',10,'Rediger profil  ',1031510000);
INSERT INTO international VALUES (339,'WebGUI',10,'Mand',1031510000);
INSERT INTO international VALUES (340,'WebGUI',10,'Kvinde',1031510000);
INSERT INTO international VALUES (341,'WebGUI',10,'Rediger profil',1031510000);
INSERT INTO international VALUES (342,'WebGUI',10,'Rediger konto information',1031510000);
INSERT INTO international VALUES (343,'WebGUI',10,'Vis profil',1031510000);
INSERT INTO international VALUES (345,'WebGUI',10,'Ikke medlem',1031510000);
INSERT INTO international VALUES (346,'WebGUI',10,'Denne bruger findes ikke længere på dette system. Jeg har ikke yderligere oplysninger om denne bruger',1031510000);
INSERT INTO international VALUES (347,'WebGUI',10,'Vis profil for',1031510000);
INSERT INTO international VALUES (348,'WebGUI',10,'Navn  ',1031510000);
INSERT INTO international VALUES (349,'WebGUI',10,'Seneste version',1031510000);
INSERT INTO international VALUES (350,'WebGUI',10,'Gennemført',1031510000);
INSERT INTO international VALUES (351,'WebGUI',10,'Message Log Entry',1031510000);
INSERT INTO international VALUES (352,'WebGUI',10,'Dato',1031510000);
INSERT INTO international VALUES (353,'WebGUI',10,'Du har ingen meddelelser i øjeblikket',1031510000);
INSERT INTO international VALUES (354,'WebGUI',10,'Vis meddelelses log',1031510000);
INSERT INTO international VALUES (355,'WebGUI',10,'Standard',1031510000);
INSERT INTO international VALUES (356,'WebGUI',10,'Template',1031510000);
INSERT INTO international VALUES (357,'WebGUI',10,'Nyheder',1031510000);
INSERT INTO international VALUES (358,'WebGUI',10,'Venstre kolonne',1031510000);
INSERT INTO international VALUES (359,'WebGUI',10,'Højre kolonne',1031510000);
INSERT INTO international VALUES (360,'WebGUI',10,'En over tre',1031510000);
INSERT INTO international VALUES (361,'WebGUI',10,'Tre over en',1031510000);
INSERT INTO international VALUES (362,'WebGUI',10,'Side ved side',1031510000);
INSERT INTO international VALUES (363,'WebGUI',10,'Template position',1031510000);
INSERT INTO international VALUES (364,'WebGUI',10,'Søg',1031510000);
INSERT INTO international VALUES (365,'WebGUI',10,'Søge resultater …',1031510000);
INSERT INTO international VALUES (366,'WebGUI',10,'Jeg fandt desværre ingen sider med de(t) søgeord',1031510000);
INSERT INTO international VALUES (367,'WebGUI',10,'Udløber efter',1031510000);
INSERT INTO international VALUES (368,'WebGUI',10,'Tilføj en ny gruppen til denne bruger.',1031510000);
INSERT INTO international VALUES (369,'WebGUI',10,'Udløbs dato',1031510000);
INSERT INTO international VALUES (370,'WebGUI',10,'Rediger gruppering',1031510000);
INSERT INTO international VALUES (371,'WebGUI',10,'Tilføj gruppering',1031510000);
INSERT INTO international VALUES (372,'WebGUI',10,'Rediger brugers gruppe',1031510000);
INSERT INTO international VALUES (374,'WebGUI',10,'administrer packages',1031510000);
INSERT INTO international VALUES (375,'WebGUI',10,'Vælg package der skal tages i brug',1031510000);
INSERT INTO international VALUES (376,'WebGUI',10,'Package',1031510000);
INSERT INTO international VALUES (377,'WebGUI',10,'\"Der er endnu ikke defineret nogle \"\"Packages\"\".\"',1031510000);
INSERT INTO international VALUES (378,'WebGUI',10,'Bruger ID',1031510000);
INSERT INTO international VALUES (379,'WebGUI',10,'Gruppe ID',1031510000);
INSERT INTO international VALUES (380,'WebGUI',10,'Stilart ID',1031510000);
INSERT INTO international VALUES (381,'WebGUI',10,'WebGUI modtog en fejlformateret besked og kan ikke fortsætte - dette skyldes typisk eb speciel karakter. Prøv evt. at trykke tilbage og prøv igen.',1031510000);
INSERT INTO international VALUES (383,'WebGUI',10,'Navn',1031510000);
INSERT INTO international VALUES (384,'WebGUI',10,'Fil  ',1031510000);
INSERT INTO international VALUES (385,'WebGUI',10,'Parametre',1031510000);
INSERT INTO international VALUES (386,'WebGUI',10,'Rediger billede',1031510000);
INSERT INTO international VALUES (387,'WebGUI',10,'Tilføjet af',1031510000);
INSERT INTO international VALUES (388,'WebGUI',10,'Tilføjet dato',1031510000);
INSERT INTO international VALUES (389,'WebGUI',10,'Billede ID',1031510000);
INSERT INTO international VALUES (390,'WebGUI',10,'Viser billede …',1031510000);
INSERT INTO international VALUES (391,'WebGUI',10,'Sletter vedhæftet fil',1031510000);
INSERT INTO international VALUES (392,'WebGUI',10,'Er du sikker på du vil slette dette billede',1031510000);
INSERT INTO international VALUES (393,'WebGUI',10,'administrer billeder',1031510000);
INSERT INTO international VALUES (394,'WebGUI',10,'administrer billeder.',1031510000);
INSERT INTO international VALUES (395,'WebGUI',10,'Tilføj nyt billede',1031510000);
INSERT INTO international VALUES (396,'WebGUI',10,'Vis billede',1031510000);
INSERT INTO international VALUES (397,'WebGUI',10,'Tilbage til billede oversigt',1031510000);
INSERT INTO international VALUES (398,'WebGUI',10,'Dokument type deklarering',1031510000);
INSERT INTO international VALUES (399,'WebGUI',10,'Valider denne side.',1031510000);
INSERT INTO international VALUES (400,'WebGUI',10,'Forhindre Proxy Caching',1031510000);
INSERT INTO international VALUES (401,'WebGUI',10,'Er du sikker på du vil slette denne besked, og alle under beskeder i tråden?',1031510000);
INSERT INTO international VALUES (402,'WebGUI',10,'Beskeden findes ikke',1031510000);
INSERT INTO international VALUES (403,'WebGUI',10,'Det foretrækker jeg ikke at oplyse',1031510000);
INSERT INTO international VALUES (404,'WebGUI',10,'Første side',1031510000);
INSERT INTO international VALUES (405,'WebGUI',10,'Sidste side',1031510000);
INSERT INTO international VALUES (406,'WebGUI',10,'Miniature størrelse',1031510000);
INSERT INTO international VALUES (407,'WebGUI',10,'Klik her for at registrere',1031510000);
INSERT INTO international VALUES (408,'WebGUI',10,'administrer rod',1031510000);
INSERT INTO international VALUES (409,'WebGUI',10,'Tilføj ny rod',1031510000);
INSERT INTO international VALUES (410,'WebGUI',10,'Administrer rod',1031510000);
INSERT INTO international VALUES (411,'WebGUI',10,'Menu titel',1031510000);
INSERT INTO international VALUES (412,'WebGUI',10,'Synopsis',1031510000);
INSERT INTO international VALUES (51,'Product',1,'Benefit',1031514049);
INSERT INTO international VALUES (56,'Product',1,'Add a product template.',1031514049);
INSERT INTO international VALUES (416,'WebGUI',10,'<h1>Problem med forespørgsel</h1>Oops, jeg har lidt problemer med din forespørgsel. Tryk tilbage og prøv igen. Hvis problemet fortsætte vil jeg være glad hvis du vil kontakte os og fortælle hvad du prøver, på forhånd tak.',1031510000);
INSERT INTO international VALUES (417,'WebGUI',10,'<h1>Sikkerhedsbrud</h1>Du forsøgte at få adgang med en Wobject der ikke hører til her. Jeg har rapporteret dit forsøg.',1031510000);
INSERT INTO international VALUES (418,'WebGUI',10,'Filter Contributed HTML',1031510000);
INSERT INTO international VALUES (419,'WebGUI',10,'Fjern alle tags',1031510000);
INSERT INTO international VALUES (420,'WebGUI',10,'Lad det være',1031510000);
INSERT INTO international VALUES (421,'WebGUI',10,'Fjerne alt bortset fra basal formatering',1031510000);
INSERT INTO international VALUES (422,'WebGUI',10,'<h1>Login mislykkedes</h1>Dine informationer stemmer ikke med mine oplysninger',1031510000);
INSERT INTO international VALUES (423,'WebGUI',10,'Vis aktive sessioner',1031510000);
INSERT INTO international VALUES (424,'WebGUI',10,'Vis login historik',1031510000);
INSERT INTO international VALUES (425,'WebGUI',10,'Aktive sessioner',1031510000);
INSERT INTO international VALUES (426,'WebGUI',10,'Login historik',1031510000);
INSERT INTO international VALUES (427,'WebGUI',10,'stilarter',1031510000);
INSERT INTO international VALUES (428,'WebGUI',10,'Bruger (ID)',1031510000);
INSERT INTO international VALUES (429,'WebGUI',10,'Login tid',1031510000);
INSERT INTO international VALUES (430,'WebGUI',10,'Sidste side vist',1031510000);
INSERT INTO international VALUES (431,'WebGUI',10,'IP Adresse',1031510000);
INSERT INTO international VALUES (432,'WebGUI',10,'Udløber efter',1031510000);
INSERT INTO international VALUES (433,'WebGUI',10,'Bruger agent:',1031510000);
INSERT INTO international VALUES (434,'WebGUI',10,'Status',1031510000);
INSERT INTO international VALUES (435,'WebGUI',10,'Session Signatur',1031510000);
INSERT INTO international VALUES (436,'WebGUI',10,'Afbryd Session',1031510000);
INSERT INTO international VALUES (437,'WebGUI',10,'Statistik',1031510000);
INSERT INTO international VALUES (438,'WebGUI',10,'Dit navn',1031510000);
INSERT INTO international VALUES (439,'WebGUI',10,'Personlig information',1031510000);
INSERT INTO international VALUES (440,'WebGUI',10,'Kontakt information',1031510000);
INSERT INTO international VALUES (441,'WebGUI',10,'Email  til OPS Gateway',1031510000);
INSERT INTO international VALUES (442,'WebGUI',10,'Arbejdsinformation',1031510000);
INSERT INTO international VALUES (443,'WebGUI',10,'Hjemme information',1031510000);
INSERT INTO international VALUES (444,'WebGUI',10,'Demografisk information',1031510000);
INSERT INTO international VALUES (445,'WebGUI',10,'Præferencer',1031510000);
INSERT INTO international VALUES (446,'WebGUI',10,'Arbejds hjemmeside',1031510000);
INSERT INTO international VALUES (447,'WebGUI',10,'Administrer træ struktur',1031510000);
INSERT INTO international VALUES (448,'WebGUI',10,'Træ struktur',1031510000);
INSERT INTO international VALUES (449,'WebGUI',10,'Diverse information',1031510000);
INSERT INTO international VALUES (450,'WebGUI',10,'Arbejdsnavn (Firma navn)',1031510000);
INSERT INTO international VALUES (451,'WebGUI',10,'er påkrævet',1031510000);
INSERT INTO international VALUES (452,'WebGUI',10,'Vent venligst …',1031510000);
INSERT INTO international VALUES (453,'WebGUI',10,'Dato oprettet',1031510000);
INSERT INTO international VALUES (454,'WebGUI',10,'Sidste opdateret',1031510000);
INSERT INTO international VALUES (455,'WebGUI',10,'Rediger bruger profil',1031510000);
INSERT INTO international VALUES (456,'WebGUI',10,'Tilbage til bruger liste',1031510000);
INSERT INTO international VALUES (457,'WebGUI',10,'Rediger denne brugers konto',1031510000);
INSERT INTO international VALUES (458,'WebGUI',10,'Rediger denne bruger gruppe',1031510000);
INSERT INTO international VALUES (459,'WebGUI',10,'Rediger denne brugers profil',1031510000);
INSERT INTO international VALUES (460,'WebGUI',10,'Tidsforskel',1031510000);
INSERT INTO international VALUES (461,'WebGUI',10,'Dato format',1031510000);
INSERT INTO international VALUES (462,'WebGUI',10,'Tids format',1031510000);
INSERT INTO international VALUES (463,'WebGUI',10,'Tekst Area Rows',1031510000);
INSERT INTO international VALUES (464,'WebGUI',10,'Tekst Area Columns',1031510000);
INSERT INTO international VALUES (465,'WebGUI',10,'Tekst Box Size',1031510000);
INSERT INTO international VALUES (466,'WebGUI',10,'Er du sikker på du vil slette denne kategori og flytte indholdet over i diverse kategorien?',1031510000);
INSERT INTO international VALUES (467,'WebGUI',10,'Er du sikker på du vil slette dette felt, og alle relaterede brugerdata?',1031510000);
INSERT INTO international VALUES (469,'WebGUI',10,'Id',1031510000);
INSERT INTO international VALUES (470,'WebGUI',10,'Navn',1031510000);
INSERT INTO international VALUES (472,'WebGUI',10,'Label',1031510000);
INSERT INTO international VALUES (473,'WebGUI',10,'Synlig?',1031510000);
INSERT INTO international VALUES (474,'WebGUI',10,'Påkrævet?',1031510000);
INSERT INTO international VALUES (475,'WebGUI',10,'Tekst',1031510000);
INSERT INTO international VALUES (476,'WebGUI',10,'Tekst område',1031510000);
INSERT INTO international VALUES (477,'WebGUI',10,'HTML område',1031510000);
INSERT INTO international VALUES (478,'WebGUI',10,'URL',1031510000);
INSERT INTO international VALUES (479,'WebGUI',10,'Dato',1031510000);
INSERT INTO international VALUES (480,'WebGUI',10,'Email Adresse',1031510000);
INSERT INTO international VALUES (481,'WebGUI',10,'Tlf. nr.',1031510000);
INSERT INTO international VALUES (482,'WebGUI',10,'Heltal',1031510000);
INSERT INTO international VALUES (483,'WebGUI',10,'Ja eller Nej',1031510000);
INSERT INTO international VALUES (484,'WebGUI',10,'Vælg fra list',1031510000);
INSERT INTO international VALUES (485,'WebGUI',10,'Logisk (Checkboks)',1031510000);
INSERT INTO international VALUES (486,'WebGUI',10,'Data type',1031510000);
INSERT INTO international VALUES (487,'WebGUI',10,'Mulige værdier',1031510000);
INSERT INTO international VALUES (488,'WebGUI',10,'Standard værdi',1031510000);
INSERT INTO international VALUES (489,'WebGUI',10,'Profil kategori',1031510000);
INSERT INTO international VALUES (490,'WebGUI',10,'Tilføj en profil kategori',1031510000);
INSERT INTO international VALUES (491,'WebGUI',10,'Tilføj et profil felt',1031510000);
INSERT INTO international VALUES (492,'WebGUI',10,'Liste over profil felter',1031510000);
INSERT INTO international VALUES (493,'WebGUI',10,'Tilbage til Site',1031510000);
INSERT INTO international VALUES (494,'WebGUI',10,'Real Objects Edit-On Pro',1031510000);
INSERT INTO international VALUES (495,'WebGUI',10,'Indbygget editor',1031510000);
INSERT INTO international VALUES (496,'WebGUI',10,'Hvilken editor bruges',1031510000);
INSERT INTO international VALUES (497,'WebGUI',10,'Start dato',1031510000);
INSERT INTO international VALUES (498,'WebGUI',10,'Slut dato',1031510000);
INSERT INTO international VALUES (499,'WebGUI',10,'Wobject ID',1031510000);
INSERT INTO international VALUES (518,'WebGUI',1,'Inbox Notifications',1031514049);
INSERT INTO international VALUES (519,'WebGUI',1,'I would not like to be notified.',1031514049);
INSERT INTO international VALUES (520,'WebGUI',1,'I would like to be notified via email.',1031514049);
INSERT INTO international VALUES (521,'WebGUI',1,'I would like to be notified via email to pager.',1031514049);
INSERT INTO international VALUES (522,'WebGUI',1,'I would like to be notified via ICQ.',1031514049);
INSERT INTO international VALUES (523,'WebGUI',1,'Notification',1031514049);
INSERT INTO international VALUES (524,'WebGUI',1,'Add edit stamp to posts?',1031514049);
INSERT INTO international VALUES (525,'WebGUI',1,'Edit Content Settings',1031514049);
INSERT INTO international VALUES (526,'WebGUI',1,'Remove only JavaScript.',1031514049);
INSERT INTO international VALUES (528,'WebGUI',1,'Template Name',1031514049);
INSERT INTO international VALUES (529,'WebGUI',1,'results',1031514049);
INSERT INTO international VALUES (530,'WebGUI',1,'with <b>all</b> the words',1031514049);
INSERT INTO international VALUES (531,'WebGUI',1,'with the <b>exact phrase</b>',1031514049);
INSERT INTO international VALUES (532,'WebGUI',1,'with <b>at least one</b> of the words',1031514049);
INSERT INTO international VALUES (533,'WebGUI',1,'<b>without</b> the words',1031514049);
INSERT INTO international VALUES (535,'WebGUI',1,'Group To Alert On New User',1031514049);
INSERT INTO international VALUES (534,'WebGUI',1,'Alert on new user?',1031514049);
INSERT INTO international VALUES (536,'WebGUI',1,'A new user named ^@; has joined the site.',1031514049);
INSERT INTO international VALUES (56,'WebGUI',3,'Emailadres',1031510000);
INSERT INTO international VALUES (55,'WebGUI',3,'Wachtwoord (bevestigen)',1031510000);
INSERT INTO international VALUES (11,'Product',1,'Product Number',1031514049);
INSERT INTO international VALUES (2,'Product',1,'Are you certain you wish to delete the relationship to this accessory?',1031514049);
INSERT INTO international VALUES (54,'WebGUI',3,'Creëer account',1031510000);
INSERT INTO international VALUES (53,'WebGUI',3,'Maak pagina printbaar',1031510000);
INSERT INTO international VALUES (579,'WebGUI',1,'Your message has been approved.',1031514049);
INSERT INTO international VALUES (52,'WebGUI',3,'Login',1031510000);
INSERT INTO international VALUES (51,'WebGUI',3,'Wachtwoord',1031510000);
INSERT INTO international VALUES (50,'WebGUI',3,'Gebruikersnaam',1031510000);
INSERT INTO international VALUES (49,'WebGUI',3,'Klik <a href=\"^\\;?op=logout\">hier</a> om uit te loggen.',1031510000);
INSERT INTO international VALUES (48,'WebGUI',3,'Hallo',1031510000);
INSERT INTO international VALUES (47,'WebGUI',3,'Home',1031510000);
INSERT INTO international VALUES (46,'WebGUI',3,'Mijn account',1031510000);
INSERT INTO international VALUES (45,'WebGUI',3,'\"Nee, ik heb een foutje gemaakt.\"',1031510000);
INSERT INTO international VALUES (44,'WebGUI',3,'\"Ja, ik weet het zeker.\"',1031510000);
INSERT INTO international VALUES (43,'WebGUI',3,'Weet u zeker dat u deze inhoud wilt verwijderen?',1031510000);
INSERT INTO international VALUES (42,'WebGUI',3,'Alstublieft bevestigen',1031510000);
INSERT INTO international VALUES (41,'WebGUI',3,'U probeert een vitaal component van het WebGUI systeem te verwijderen. Als u dit zou mogen dan zou WebGUI waarschijnlijk niet meer werken.',1031510000);
INSERT INTO international VALUES (40,'WebGUI',3,'Vitaal component',1031510000);
INSERT INTO international VALUES (39,'WebGUI',3,'U heeft niet voldoende privileges om deze pagina op te vragen.',1031510000);
INSERT INTO international VALUES (38,'WebGUI',3,'U heeft niet voldoende privileges om deze bewerking uit te voeren. ^a(Log in); als een gebruiker met voldoende privileges.',1031510000);
INSERT INTO international VALUES (37,'WebGUI',3,'Geen toegang!',1031510000);
INSERT INTO international VALUES (36,'WebGUI',3,'U moet een beheerder zijn om deze functie uit te voeren. Neem contact op met een van de beheerders:',1031510000);
INSERT INTO international VALUES (35,'WebGUI',3,'Administratieve functie',1031510000);
INSERT INTO international VALUES (34,'WebGUI',3,'Zet datum',1031510000);
INSERT INTO international VALUES (33,'WebGUI',3,'zaterdag',1031510000);
INSERT INTO international VALUES (32,'WebGUI',3,'vrijdag',1031510000);
INSERT INTO international VALUES (31,'WebGUI',3,'donderdag',1031510000);
INSERT INTO international VALUES (30,'WebGUI',3,'woensdag',1031510000);
INSERT INTO international VALUES (29,'WebGUI',3,'dinsdag',1031510000);
INSERT INTO international VALUES (29,'UserSubmission',3,'Gebruikers bijdrage systeem',1031510000);
INSERT INTO international VALUES (28,'WebGUI',3,'maandag',1031510000);
INSERT INTO international VALUES (28,'UserSubmission',3,'Ga terug naar bijdrage lijst',1031510000);
INSERT INTO international VALUES (27,'WebGUI',3,'zondag',1031510000);
INSERT INTO international VALUES (27,'UserSubmission',3,'Bewerk',1031510000);
INSERT INTO international VALUES (26,'WebGUI',3,'december',1031510000);
INSERT INTO international VALUES (574,'WebGUI',3,'Keur af',1031510000);
INSERT INTO international VALUES (25,'WebGUI',3,'november',1031510000);
INSERT INTO international VALUES (573,'WebGUI',3,'Laat in behandeling',1031510000);
INSERT INTO international VALUES (24,'WebGUI',3,'oktober',1031510000);
INSERT INTO international VALUES (572,'WebGUI',3,'Keur goed',1031510000);
INSERT INTO international VALUES (23,'WebGUI',3,'september',1031510000);
INSERT INTO international VALUES (23,'UserSubmission',3,'Invoer datum:',1031510000);
INSERT INTO international VALUES (22,'WebGUI',3,'augustus',1031510000);
INSERT INTO international VALUES (9,'Product',1,'Product Image 3',1031514049);
INSERT INTO international VALUES (7,'Product',1,'Product Image 1',1031514049);
INSERT INTO international VALUES (22,'UserSubmission',3,'ingevoerd door:',1031510000);
INSERT INTO international VALUES (21,'WebGUI',3,'juli',1031510000);
INSERT INTO international VALUES (21,'UserSubmission',3,'Ingevoerd door',1031510000);
INSERT INTO international VALUES (20,'WebGUI',3,'juni',1031510000);
INSERT INTO international VALUES (575,'WebGUI',1,'Edit',1031514049);
INSERT INTO international VALUES (570,'WebGUI',1,'Lock Thread',1031514049);
INSERT INTO international VALUES (568,'WebGUI',1,'After-the-fact',1031514049);
INSERT INTO international VALUES (20,'UserSubmission',3,'Post nieuwe bijdrage',1031510000);
INSERT INTO international VALUES (20,'MessageBoard',3,'Laatste antwoord',1031510000);
INSERT INTO international VALUES (19,'WebGUI',3,'mei',1031510000);
INSERT INTO international VALUES (19,'UserSubmission',3,'Bewerk bijdrage',1031510000);
INSERT INTO international VALUES (19,'MessageBoard',3,'Antwoorden',1031510000);
INSERT INTO international VALUES (18,'WebGUI',3,'april',1031510000);
INSERT INTO international VALUES (18,'UserSubmission',3,'Bewerk gebruikers bijdrage systeem',1031510000);
INSERT INTO international VALUES (18,'MessageBoard',3,'Tread gestart',1031510000);
INSERT INTO international VALUES (17,'WebGUI',3,'maart',1031510000);
INSERT INTO international VALUES (16,'WebGUI',3,'februari',1031510000);
INSERT INTO international VALUES (17,'MessageBoard',3,'Post nieuw bericht',1031510000);
INSERT INTO international VALUES (17,'UserSubmission',3,'Weet u zeker dat u deze bijdrage wilt verwijderen?',1031510000);
INSERT INTO international VALUES (16,'UserSubmission',3,'Zonder titel',1031510000);
INSERT INTO international VALUES (16,'MessageBoard',3,'Datum',1031510000);
INSERT INTO international VALUES (15,'WebGUI',3,'januari',1031510000);
INSERT INTO international VALUES (15,'UserSubmission',3,'bewerk/Verwijder',1031510000);
INSERT INTO international VALUES (15,'MessageBoard',3,'Afzender',1031510000);
INSERT INTO international VALUES (14,'WebGUI',3,'Laat lopende aanmeldingen zien.',1031510000);
INSERT INTO international VALUES (14,'UserSubmission',3,'Status',1031510000);
INSERT INTO international VALUES (13,'WebGUI',3,'Laat help index zien.',1031510000);
INSERT INTO international VALUES (13,'UserSubmission',3,'Invoerdatum',1031510000);
INSERT INTO international VALUES (577,'WebGUI',3,'Post antwoord',1031510000);
INSERT INTO international VALUES (13,'LinkList',3,'Voeg een nieuwe link toe.',1031510000);
INSERT INTO international VALUES (13,'EventsCalendar',3,'Bewerk evenement',1031510000);
INSERT INTO international VALUES (13,'Article',3,'Verwijder',1031510000);
INSERT INTO international VALUES (12,'WebGUI',3,'Zet beheermode uit.',1031510000);
INSERT INTO international VALUES (12,'UserSubmission',3,'(niet aanvinken als u een HTML bijdrage levert.)',1031510000);
INSERT INTO international VALUES (12,'SQLReport',3,'Fout: Kon niet met de database verbinden.',1031510000);
INSERT INTO international VALUES (12,'EventsCalendar',3,'Bewerk evenementen kalender',1031510000);
INSERT INTO international VALUES (12,'LinkList',3,'Bewerk link',1031510000);
INSERT INTO international VALUES (12,'MessageBoard',3,'Bewerk bericht',1031510000);
INSERT INTO international VALUES (12,'Article',3,'Bewerk artikel',1031510000);
INSERT INTO international VALUES (11,'WebGUI',3,'Leeg prullenbak.',1031510000);
INSERT INTO international VALUES (11,'SQLReport',3,'Fout: Er was een probleem met de query',1031510000);
INSERT INTO international VALUES (11,'MessageBoard',3,'Terug naar berichten lijst',1031510000);
INSERT INTO international VALUES (11,'Article',3,'(Vink aan als u geen &lt;br&gt; manueel gebruikt.)',1031510000);
INSERT INTO international VALUES (10,'WebGUI',3,'Bekijk prullenbak.',1031510000);
INSERT INTO international VALUES (563,'WebGUI',3,'Standaard status',1031510000);
INSERT INTO international VALUES (10,'SQLReport',3,'Fout: De ingevoerde SQL instructie is van een verkeerd formaat.',1031510000);
INSERT INTO international VALUES (10,'Poll',3,'Begin opnieuw met stemmen',1031510000);
INSERT INTO international VALUES (10,'LinkList',3,'Bewerk link lijst',1031510000);
INSERT INTO international VALUES (10,'FAQ',3,'Bewerk vraag',1031510000);
INSERT INTO international VALUES (10,'Article',3,'Enter converteren?',1031510000);
INSERT INTO international VALUES (562,'WebGUI',3,'Lopend',1031510000);
INSERT INTO international VALUES (9,'WebGUI',3,'Bekijk klembord.',1031510000);
INSERT INTO international VALUES (9,'SQLReport',3,'Fout: De ingevoerde DSN is van een verkeerd formaat.',1031510000);
INSERT INTO international VALUES (9,'Poll',3,'Bewerk stemming',1031510000);
INSERT INTO international VALUES (9,'MessageBoard',3,'Bericht ID:',1031510000);
INSERT INTO international VALUES (9,'LinkList',3,'Weet u zeker dat u deze link wilt verwijderen?',1031510000);
INSERT INTO international VALUES (9,'FAQ',3,'Voeg een nieuwe vraag toe',1031510000);
INSERT INTO international VALUES (9,'EventsCalendar',3,'Tot',1031510000);
INSERT INTO international VALUES (9,'Article',3,'Bijlage',1031510000);
INSERT INTO international VALUES (713,'WebGUI',1,'Style Managers Group',1031514049);
INSERT INTO international VALUES (714,'WebGUI',1,'Template Managers Group',1031514049);
INSERT INTO international VALUES (8,'SiteMap',3,'Regelafstand',1031510000);
INSERT INTO international VALUES (8,'SQLReport',3,'Bewerk SQL rapport',1031510000);
INSERT INTO international VALUES (561,'WebGUI',3,'Afgekeurd',1031510000);
INSERT INTO international VALUES (8,'WebGUI',3,'Bekijk \'pagina niet gevonden\'.',1031510000);
INSERT INTO international VALUES (8,'LinkList',3,'URL',1031510000);
INSERT INTO international VALUES (8,'MessageBoard',3,'Datum:',1031510000);
INSERT INTO international VALUES (8,'Poll',3,'(Voer een antwoord per regel in. Niet meer dan 20.)',1031510000);
INSERT INTO international VALUES (8,'FAQ',3,'Bewerk FAQ',1031510000);
INSERT INTO international VALUES (8,'EventsCalendar',3,'Herhaalt elke',1031510000);
INSERT INTO international VALUES (8,'Article',3,'Link URL',1031510000);
INSERT INTO international VALUES (7,'WebGUI',3,'Beheer gebruikers',1031510000);
INSERT INTO international VALUES (7,'SQLReport',3,'Database wachtwoord',1031510000);
INSERT INTO international VALUES (560,'WebGUI',3,'Goedgekeurd',1031510000);
INSERT INTO international VALUES (7,'SiteMap',3,'Opsommingsteken',1031510000);
INSERT INTO international VALUES (7,'Poll',3,'Antwoorden',1031510000);
INSERT INTO international VALUES (7,'MessageBoard',3,'Naam:',1031510000);
INSERT INTO international VALUES (7,'FAQ',3,'Weet u zeker dat u deze vraag wilt verwijderen?',1031510000);
INSERT INTO international VALUES (7,'Article',3,'Link titel',1031510000);
INSERT INTO international VALUES (6,'WebGUI',3,'Beheer stijlen.',1031510000);
INSERT INTO international VALUES (6,'UserSubmission',3,'Bijdrages per pagina',1031510000);
INSERT INTO international VALUES (6,'SyndicatedContent',3,'Huidige inhoud',1031510000);
INSERT INTO international VALUES (6,'SQLReport',3,'Database gebruiker',1031510000);
INSERT INTO international VALUES (6,'SiteMap',3,'Inspringen',1031510000);
INSERT INTO international VALUES (6,'Poll',3,'Vraag',1031510000);
INSERT INTO international VALUES (6,'MessageBoard',3,'Bewerk berichten bord',1031510000);
INSERT INTO international VALUES (6,'LinkList',3,'Link lijst',1031510000);
INSERT INTO international VALUES (6,'FAQ',3,'Andwoord',1031510000);
INSERT INTO international VALUES (6,'ExtraColumn',3,'Bewerk extra kolom',1031510000);
INSERT INTO international VALUES (701,'WebGUI',3,'Week',1031510000);
INSERT INTO international VALUES (6,'Article',3,'Plaatje',1031510000);
INSERT INTO international VALUES (5,'WebGUI',3,'Beheer groepen.',1031510000);
INSERT INTO international VALUES (5,'UserSubmission',3,'Uw bijdrage is afgekeurd.',1031510000);
INSERT INTO international VALUES (5,'SyndicatedContent',3,'Laatste keer bijgewerkt',1031510000);
INSERT INTO international VALUES (5,'SQLReport',3,'DSN',1031510000);
INSERT INTO international VALUES (5,'SiteMap',3,'Bewerk sitemap',1031510000);
INSERT INTO international VALUES (5,'Poll',3,'Grafiek breedte',1031510000);
INSERT INTO international VALUES (566,'WebGUI',3,'Bewerk timeout',1031510000);
INSERT INTO international VALUES (5,'LinkList',3,'Doorgaan met link toevoegen?',1031510000);
INSERT INTO international VALUES (5,'FAQ',3,'Vraag',1031510000);
INSERT INTO international VALUES (5,'ExtraColumn',3,'Style sheet klasse (class)',1031510000);
INSERT INTO international VALUES (700,'WebGUI',3,'Dag',1031510000);
INSERT INTO international VALUES (4,'WebGUI',3,'Beheer instellingen.',1031510000);
INSERT INTO international VALUES (4,'UserSubmission',3,'Uw bijdrage is goedgekeurd.',1031510000);
INSERT INTO international VALUES (4,'SQLReport',3,'Query',1031510000);
INSERT INTO international VALUES (4,'SyndicatedContent',3,'Bewerk syndicated content',1031510000);
INSERT INTO international VALUES (4,'Poll',3,'Wie kan stemmen?',1031510000);
INSERT INTO international VALUES (4,'SiteMap',3,'Diepteniveau',1031510000);
INSERT INTO international VALUES (4,'MessageBoard',3,'Berichten per pagina',1031510000);
INSERT INTO international VALUES (4,'LinkList',3,'Opsommingsteken',1031510000);
INSERT INTO international VALUES (4,'ExtraColumn',3,'Breedte',1031510000);
INSERT INTO international VALUES (4,'EventsCalendar',3,'Gebeurt maar een keer.',1031510000);
INSERT INTO international VALUES (4,'Article',3,'Eind datum',1031510000);
INSERT INTO international VALUES (3,'WebGUI',3,'Plakken van het klemboord...',1031510000);
INSERT INTO international VALUES (3,'UserSubmission',3,'U heeft een nieuwe bijdrage om goed te keuren.',1031510000);
INSERT INTO international VALUES (3,'SQLReport',3,'Sjabloon',1031510000);
INSERT INTO international VALUES (3,'SiteMap',3,'Op dit niveau beginnen?',1031510000);
INSERT INTO international VALUES (3,'Poll',3,'Aktief',1031510000);
INSERT INTO international VALUES (564,'WebGUI',3,'Wie kan posten',1031510000);
INSERT INTO international VALUES (3,'LinkList',3,'Open in nieuw venster?',1031510000);
INSERT INTO international VALUES (3,'ExtraColumn',3,'Tussenruimte',1031510000);
INSERT INTO international VALUES (3,'Article',3,'Begindatum',1031510000);
INSERT INTO international VALUES (2,'WebGUI',3,'Pagina',1031510000);
INSERT INTO international VALUES (2,'UserSubmission',3,'Wie kan bijdragen?',1031510000);
INSERT INTO international VALUES (2,'SyndicatedContent',3,'Syndicated content',1031510000);
INSERT INTO international VALUES (2,'SiteMap',3,'Sitemap',1031510000);
INSERT INTO international VALUES (2,'MessageBoard',3,'Berichtenbord',1031510000);
INSERT INTO international VALUES (2,'LinkList',3,'Regelafstand',1031510000);
INSERT INTO international VALUES (2,'FAQ',3,'FAQ',1031510000);
INSERT INTO international VALUES (2,'EventsCalendar',3,'Evenementen kalender',1031510000);
INSERT INTO international VALUES (1,'WebGUI',3,'Inhoud toevoegen...',1031510000);
INSERT INTO international VALUES (1,'UserSubmission',3,'Wie kan goedkeuren?',1031510000);
INSERT INTO international VALUES (1,'SyndicatedContent',3,'URL naar RSS bestand',1031510000);
INSERT INTO international VALUES (1,'SQLReport',3,'SQL rapport',1031510000);
INSERT INTO international VALUES (1,'Poll',3,'Stemming',1031510000);
INSERT INTO international VALUES (1,'LinkList',3,'Inspringen',1031510000);
INSERT INTO international VALUES (1,'FAQ',3,'Doorgaan naar vraag toevoegen?',1031510000);
INSERT INTO international VALUES (1,'ExtraColumn',3,'Extra kolom',1031510000);
INSERT INTO international VALUES (1,'EventsCalendar',3,'Doorgaan naar gebeurtenis toevoegen?',1031510000);
INSERT INTO international VALUES (1,'Article',3,'Artikel',1031510000);
INSERT INTO international VALUES (537,'WebGUI',1,'Karma',1031514049);
INSERT INTO international VALUES (538,'WebGUI',1,'Karma Threshold',1031514049);
INSERT INTO international VALUES (539,'WebGUI',1,'Enable Karma?',1031514049);
INSERT INTO international VALUES (540,'WebGUI',1,'Karma Per Login',1031514049);
INSERT INTO international VALUES (20,'Poll',1,'Karma Per Vote',1031514049);
INSERT INTO international VALUES (541,'WebGUI',1,'Karma Per Post',1031514049);
INSERT INTO international VALUES (5,'Product',1,'Are you certain you wish to delete this specification?',1031514049);
INSERT INTO international VALUES (542,'WebGUI',1,'Previous..',1031514049);
INSERT INTO international VALUES (543,'WebGUI',1,'Add a new image group.',1031514049);
INSERT INTO international VALUES (544,'WebGUI',1,'Are you certain you wish to delete this group?',1031514049);
INSERT INTO international VALUES (545,'WebGUI',1,'Edit Image Group',1031514049);
INSERT INTO international VALUES (546,'WebGUI',1,'Group Id',1031514049);
INSERT INTO international VALUES (547,'WebGUI',1,'Parent group',1031514049);
INSERT INTO international VALUES (548,'WebGUI',1,'Group name',1031514049);
INSERT INTO international VALUES (549,'WebGUI',1,'Group description',1031514049);
INSERT INTO international VALUES (550,'WebGUI',1,'View Image group',1031514049);
INSERT INTO international VALUES (382,'WebGUI',1,'Edit Image',1031514049);
INSERT INTO international VALUES (551,'WebGUI',1,'Notice',1031514049);
INSERT INTO international VALUES (552,'WebGUI',1,'Pending',1031514049);
INSERT INTO international VALUES (553,'WebGUI',1,'Status',1031514049);
INSERT INTO international VALUES (554,'WebGUI',1,'Take Action',1031514049);
INSERT INTO international VALUES (555,'WebGUI',1,'Edit this user\'s karma.',1031514049);
INSERT INTO international VALUES (556,'WebGUI',1,'Amount',1031514049);
INSERT INTO international VALUES (557,'WebGUI',1,'Description',1031514049);
INSERT INTO international VALUES (558,'WebGUI',1,'Edit User\'s Karma',1031514049);
INSERT INTO international VALUES (6,'Item',1,'Edit Item',1031514049);
INSERT INTO international VALUES (559,'WebGUI',1,'Run On Registration',1031514049);
INSERT INTO international VALUES (13,'Product',1,'Brochure',1031514049);
INSERT INTO international VALUES (14,'Product',1,'Manual',1031514049);
INSERT INTO international VALUES (15,'Product',1,'Warranty',1031514049);
INSERT INTO international VALUES (16,'Product',1,'Add Accessory',1031514049);
INSERT INTO international VALUES (17,'Product',1,'Accessory',1031514049);
INSERT INTO international VALUES (18,'Product',1,'Add another accessory?',1031514049);
INSERT INTO international VALUES (21,'Product',1,'Add another related product?',1031514049);
INSERT INTO international VALUES (19,'Product',1,'Add Related Product',1031514049);
INSERT INTO international VALUES (20,'Product',1,'Related Product',1031514049);
INSERT INTO international VALUES (22,'Product',1,'Edit Feature',1031514049);
INSERT INTO international VALUES (23,'Product',1,'Feature',1031514049);
INSERT INTO international VALUES (24,'Product',1,'Add another feature?',1031514049);
INSERT INTO international VALUES (25,'Product',1,'Edit Specification',1031514049);
INSERT INTO international VALUES (26,'Product',1,'Label',1031514049);
INSERT INTO international VALUES (27,'Product',1,'Specification',1031514049);
INSERT INTO international VALUES (28,'Product',1,'Add another specification?',1031514049);
INSERT INTO international VALUES (29,'Product',1,'Units',1031514049);
INSERT INTO international VALUES (30,'Product',1,'Features',1031514049);
INSERT INTO international VALUES (31,'Product',1,'Specifications',1031514049);
INSERT INTO international VALUES (32,'Product',1,'Accessories',1031514049);
INSERT INTO international VALUES (33,'Product',1,'Related Products',1031514049);
INSERT INTO international VALUES (34,'Product',1,'Add a feature.',1031514049);
INSERT INTO international VALUES (35,'Product',1,'Add a specification.',1031514049);
INSERT INTO international VALUES (36,'Product',1,'Add an accessory.',1031514049);
INSERT INTO international VALUES (37,'Product',1,'Add a related product.',1031514049);
INSERT INTO international VALUES (581,'WebGUI',1,'Add New Value',1031514049);
INSERT INTO international VALUES (582,'WebGUI',1,'Leave Blank',1031514049);
INSERT INTO international VALUES (583,'WebGUI',1,'Max Image Size',1031514049);
INSERT INTO international VALUES (1,'WobjectProxy',1,'Wobject To Proxy',1031514049);
INSERT INTO international VALUES (2,'WobjectProxy',1,'Edit Wobject Proxy',1031514049);
INSERT INTO international VALUES (3,'WobjectProxy',1,'Wobject Proxy',1031514049);
INSERT INTO international VALUES (4,'WobjectProxy',1,'Wobject proxying failed. Perhaps the proxied wobject has been deleted.',1031514049);
INSERT INTO international VALUES (5,'UserSubmission',7,'ÄúµÄÍ¶¸å±»¾Ü¾ø¡£',1031510000);
INSERT INTO international VALUES (5,'SyndicatedContent',7,'×îºóÌáÈ¡ÓÚ',1031510000);
INSERT INTO international VALUES (5,'SQLReport',7,'DSN',1031510000);
INSERT INTO international VALUES (5,'SiteMap',7,'±à¼­ÍøÕ¾µØÍ¼',1031510000);
INSERT INTO international VALUES (5,'Poll',7,'Í¼ÐÎ¿í¶È',1031510000);
INSERT INTO international VALUES (5,'MessageBoard',7,'±à¼­³¬Ê±',1031510000);
INSERT INTO international VALUES (5,'LinkList',7,'ÊÇ·ñÖ´ÐÐÌí¼ÓÁ´½Ó£¿',1031510000);
INSERT INTO international VALUES (5,'Item',7,'ÏÂÔØ¸½¼þ',1031510000);
INSERT INTO international VALUES (5,'FAQ',7,'ÎÊÌâ',1031510000);
INSERT INTO international VALUES (5,'ExtraColumn',7,'·ç¸ñµ¥ Class',1031510000);
INSERT INTO international VALUES (700,'WebGUI',7,'Ìì',1031510000);
INSERT INTO international VALUES (20,'EventsCalendar',7,'Ìí¼ÓÊÂÎñ¡£',1031510000);
INSERT INTO international VALUES (38,'UserSubmission',7,'(Èç¹ûÄúÊ¹ÓÃÁË³¬ÎÄ±¾ÓïÑÔ£¬ÇëÑ¡Ôñ¡°·ñ¡±¡£)',1031510000);
INSERT INTO international VALUES (4,'WebGUI',7,'¹ÜÀíÉèÖÃ¡£',1031510000);
INSERT INTO international VALUES (4,'UserSubmission',7,'ÄúµÄÍ¶¸åÒÑÍ¨¹ýÉóºË¡£',1031510000);
INSERT INTO international VALUES (4,'SyndicatedContent',7,'±à¼­Í¬²½ÄÚÈÝ',1031510000);
INSERT INTO international VALUES (4,'SQLReport',7,'²éÑ¯',1031510000);
INSERT INTO international VALUES (4,'SiteMap',7,'Õ¹¿ªÉî¶È',1031510000);
INSERT INTO international VALUES (4,'Poll',7,'Í¶Æ±È¨ÏÞ£¿',1031510000);
INSERT INTO international VALUES (4,'MessageBoard',7,'Ã¿Ò³ÏÔÊ¾',1031510000);
INSERT INTO international VALUES (4,'LinkList',7,'Ç°×º×Ö·û',1031510000);
INSERT INTO international VALUES (4,'Item',7,'ÏîÄ¿',1031510000);
INSERT INTO international VALUES (4,'ExtraColumn',7,'¿í¶È',1031510000);
INSERT INTO international VALUES (4,'EventsCalendar',7,'Ö»·¢ÉúÒ»´Î¡£',1031510000);
INSERT INTO international VALUES (4,'Article',7,'½áÊøÈÕÆÚ',1031510000);
INSERT INTO international VALUES (3,'WebGUI',7,'´Ó¼ôÌù°åÖÐÕ³Ìù...',1031510000);
INSERT INTO international VALUES (3,'UserSubmission',7,'ÄúÓÐÒ»ÆªÐÂµÄÓÃ»§Í¶¸åµÈ´ýÉóºË¡£',1031510000);
INSERT INTO international VALUES (3,'SQLReport',7,'±¨¸æÄ£°å',1031510000);
INSERT INTO international VALUES (3,'SiteMap',7,'ÊÇ·ñ´Ó´Ë¼¶±ð¿ªÊ¼£¿',1031510000);
INSERT INTO international VALUES (3,'Poll',7,'¼¤»î',1031510000);
INSERT INTO international VALUES (3,'MessageBoard',7,'·¢±íÈ¨ÏÞ£¿',1031510000);
INSERT INTO international VALUES (3,'LinkList',7,'ÊÇ·ñÔÚÐÂ´°¿ÚÖÐ´ò¿ª£¿',1031510000);
INSERT INTO international VALUES (3,'Item',7,'É¾³ý¸½¼þ',1031510000);
INSERT INTO international VALUES (3,'ExtraColumn',7,'¿Õ°×',1031510000);
INSERT INTO international VALUES (3,'Article',7,'¿ªÊ¼ÈÕÆÚ',1031510000);
INSERT INTO international VALUES (2,'WebGUI',7,'Ò³',1031510000);
INSERT INTO international VALUES (2,'UserSubmission',7,'Í¶¸åÈ¨ÏÞ£¿',1031510000);
INSERT INTO international VALUES (2,'SyndicatedContent',7,'Í¬²½ÄÚÈÝ',1031510000);
INSERT INTO international VALUES (2,'SiteMap',7,'ÍøÕ¾µØÍ¼',1031510000);
INSERT INTO international VALUES (2,'MessageBoard',7,'¹«¸æÀ¸',1031510000);
INSERT INTO international VALUES (2,'LinkList',7,'ÐÐ¼ä¾à',1031510000);
INSERT INTO international VALUES (2,'Item',7,'¸½¼þ',1031510000);
INSERT INTO international VALUES (2,'FAQ',7,'F.A.Q.',1031510000);
INSERT INTO international VALUES (2,'EventsCalendar',7,'ÐÐÊÂÀú',1031510000);
INSERT INTO international VALUES (507,'WebGUI',7,'±à¼­Ä£°å',1031510000);
INSERT INTO international VALUES (1,'WebGUI',7,'Ìí¼ÓÄÚÈÝ...',1031510000);
INSERT INTO international VALUES (1,'UserSubmission',7,'ÉóºËÈ¨ÏÞ£¿',1031510000);
INSERT INTO international VALUES (1,'SyndicatedContent',7,'RSS ÎÄ¼þÁ´½Ó',1031510000);
INSERT INTO international VALUES (1,'SQLReport',7,'SQL ±¨¸æ',1031510000);
INSERT INTO international VALUES (1,'Poll',7,'µ÷²é',1031510000);
INSERT INTO international VALUES (1,'LinkList',7,'Ëõ½ø',1031510000);
INSERT INTO international VALUES (1,'Item',7,'Á´½Ó URL',1031510000);
INSERT INTO international VALUES (1,'FAQ',7,'ÊÇ·ñÖ´ÐÐÌí¼ÓÎÊÌâ£¿',1031510000);
INSERT INTO international VALUES (1,'ExtraColumn',7,'À©Õ¹ÁÐ',1031510000);
INSERT INTO international VALUES (1,'EventsCalendar',7,'ÊÇ·ñÖ´ÐÐÌí¼ÓÊÂÎñ£¿',1031510000);
INSERT INTO international VALUES (1,'Article',7,'ÎÄÕÂ',1031510000);
INSERT INTO international VALUES (367,'WebGUI',7,'¹ýÆÚÊ±¼ä',1031510000);
INSERT INTO international VALUES (5,'WebGUI',7,'¹ÜÀíÓÃ»§×é¡£',1031510000);
INSERT INTO international VALUES (6,'Article',7,'Í¼Æ¬',1031510000);
INSERT INTO international VALUES (701,'WebGUI',7,'ÐÇÆÚ',1031510000);
INSERT INTO international VALUES (6,'ExtraColumn',7,'±à¼­À©Õ¹ÁÐ',1031510000);
INSERT INTO international VALUES (6,'FAQ',7,'»Ø´ð',1031510000);
INSERT INTO international VALUES (6,'LinkList',7,'Á´½ÓÁÐ±í',1031510000);
INSERT INTO international VALUES (6,'MessageBoard',7,'±à¼­¹«¸æÀ¸',1031510000);
INSERT INTO international VALUES (6,'Poll',7,'ÎÊÌâ',1031510000);
INSERT INTO international VALUES (6,'SiteMap',7,'Ëõ½ø',1031510000);
INSERT INTO international VALUES (6,'SQLReport',7,'Êý¾Ý¿âÓÃ»§',1031510000);
INSERT INTO international VALUES (6,'SyndicatedContent',7,'µ±Ç°ÄÚÈÝ',1031510000);
INSERT INTO international VALUES (6,'UserSubmission',7,'Ã¿Ò³Í¶¸åÊý',1031510000);
INSERT INTO international VALUES (6,'WebGUI',7,'¹ÜÀí·ç¸ñ',1031510000);
INSERT INTO international VALUES (7,'Article',7,'Á¬½Ó±êÌâ',1031510000);
INSERT INTO international VALUES (7,'FAQ',7,'ÄúÊÇ·ñÈ·ÐÅÄúÒªÉ¾³ýÕâ¸öÎÊÌâ£¿',1031510000);
INSERT INTO international VALUES (7,'MessageBoard',7,'×÷Õß£º',1031510000);
INSERT INTO international VALUES (7,'Poll',7,'»Ø´ð',1031510000);
INSERT INTO international VALUES (7,'SiteMap',7,'Ç°×º×Ö·û',1031510000);
INSERT INTO international VALUES (7,'SQLReport',7,'Êý¾Ý¿âÃÜÂë',1031510000);
INSERT INTO international VALUES (7,'UserSubmission',7,'Í¨¹ý',1031510000);
INSERT INTO international VALUES (7,'WebGUI',7,'¹ÜÀíÓÃ»§¡£',1031510000);
INSERT INTO international VALUES (8,'Article',7,'Á´½Ó URL',1031510000);
INSERT INTO international VALUES (8,'EventsCalendar',7,'ÖØ¸´ÖÜÆÚ',1031510000);
INSERT INTO international VALUES (8,'FAQ',7,'±à¼­ F.A.Q.',1031510000);
INSERT INTO international VALUES (8,'LinkList',7,'URL',1031510000);
INSERT INTO international VALUES (8,'MessageBoard',7,'ÈÕÆÚ£º',1031510000);
INSERT INTO international VALUES (8,'Poll',7,'£¨Ã¿ÐÐÊäÈëÒ»Ìõ´ð°¸¡£×î¶à²»³¬¹ý20Ìõ¡££©',1031510000);
INSERT INTO international VALUES (9,'MessageBoard',7,'ÎÄÕÂ ID:',1031510000);
INSERT INTO international VALUES (11,'MessageBoard',7,'·µ»ØÎÄÕÂÁÐ±í',1031510000);
INSERT INTO international VALUES (12,'MessageBoard',7,'±à¼­ÎÄÕÂ',1031510000);
INSERT INTO international VALUES (13,'MessageBoard',7,'·¢±í»Ø¸´',1031510000);
INSERT INTO international VALUES (15,'MessageBoard',7,'×÷Õß',1031510000);
INSERT INTO international VALUES (16,'MessageBoard',7,'ÈÕÆÚ',1031510000);
INSERT INTO international VALUES (17,'MessageBoard',7,'·¢±íÐÂÎÄÕÂ',1031510000);
INSERT INTO international VALUES (18,'MessageBoard',7,'ÏßË÷¿ªÊ¼',1031510000);
INSERT INTO international VALUES (19,'MessageBoard',7,'»Ø¸´',1031510000);
INSERT INTO international VALUES (20,'MessageBoard',7,'×îºó»Ø¸´',1031510000);
INSERT INTO international VALUES (21,'MessageBoard',7,'¹ÜÀíÈ¨ÏÞ£¿',1031510000);
INSERT INTO international VALUES (22,'MessageBoard',7,'É¾³ýÎÄÕÂ',1031510000);
INSERT INTO international VALUES (9,'Poll',7,'±à¼­µ÷²é',1031510000);
INSERT INTO international VALUES (10,'Poll',7,'³õÊ¼»¯Í¶Æ±¡£',1031510000);
INSERT INTO international VALUES (11,'Poll',7,'Í¶Æ±£¡',1031510000);
INSERT INTO international VALUES (8,'SiteMap',7,'ÐÐ¾à',1031510000);
INSERT INTO international VALUES (8,'SQLReport',7,'Edit SQL Report',1031510000);
INSERT INTO international VALUES (8,'UserSubmission',7,'±»¾Ü¾ø',1031510000);
INSERT INTO international VALUES (8,'WebGUI',7,'Äú²é¿´µÄÒ³Ãæ²»´æÔÚ¡£',1031510000);
INSERT INTO international VALUES (9,'Article',7,'¸½¼þ',1031510000);
INSERT INTO international VALUES (9,'EventsCalendar',7,'Ö±µ½',1031510000);
INSERT INTO international VALUES (9,'FAQ',7,'Ìí¼ÓÐÂÎÊÌâ¡£',1031510000);
INSERT INTO international VALUES (9,'LinkList',7,'ÄúÊÇ·ñÈ·¶¨ÒªÉ¾³ý´ËÁ´½Ó£¿',1031510000);
INSERT INTO international VALUES (9,'SQLReport',7,'<b>Debug:</b> Error: The DSN specified is of an improper format.',1031510000);
INSERT INTO international VALUES (9,'UserSubmission',7,'ÉóºËÖÐ',1031510000);
INSERT INTO international VALUES (9,'WebGUI',7,'²é¿´¼ôÌù°å',1031510000);
INSERT INTO international VALUES (10,'Article',7,'ÊÇ·ñ×ª»»»Ø³µ·û£¿',1031510000);
INSERT INTO international VALUES (10,'FAQ',7,'±à¼­ÎÊÌâ',1031510000);
INSERT INTO international VALUES (10,'LinkList',7,'±à¼­Á´½ÓÁÐ±í',1031510000);
INSERT INTO international VALUES (10,'SQLReport',7,'<b>Debug:</b> Error: The SQL specified is of an improper format.',1031510000);
INSERT INTO international VALUES (10,'UserSubmission',7,'Ä¬ÈÏ×´Ì¬',1031510000);
INSERT INTO international VALUES (10,'WebGUI',7,'¹ÜÀíÀ¬»øÏä',1031510000);
INSERT INTO international VALUES (11,'Article',7,'(Èç¹ûÄúÃ»ÓÐÊÖ¶¯ÊäÈë&lt;br&gt;£¬ÇëÑ¡Ôñ¡°ÊÇ¡±)',1031510000);
INSERT INTO international VALUES (76,'EventsCalendar',1,'Delete only this event.',1031514049);
INSERT INTO international VALUES (11,'SQLReport',7,'<b>Debug:</b> Error: There was a problem with the query.',1031510000);
INSERT INTO international VALUES (11,'WebGUI',7,'Çå¿ÕÀ¬»øÏä',1031510000);
INSERT INTO international VALUES (12,'Article',7,'±à¼­ÎÄÕÂ',1031510000);
INSERT INTO international VALUES (12,'EventsCalendar',7,'±à¼­ÐÐÊÂÀú',1031510000);
INSERT INTO international VALUES (12,'LinkList',7,'±à¼­Á´½Ó',1031510000);
INSERT INTO international VALUES (12,'SQLReport',7,'<b>Debug:</b> Error: Could not connect to the database.',1031510000);
INSERT INTO international VALUES (12,'UserSubmission',7,'(Èç¹ûÄúÊ¹ÓÃÁË³¬ÎÄ±¾ÓïÑÔ£¬Çë²»ÒªÑ¡Ôñ´ËÏî)',1031510000);
INSERT INTO international VALUES (12,'WebGUI',7,'ÍË³ö¹ÜÀí',1031510000);
INSERT INTO international VALUES (13,'Article',7,'É¾³ý',1031510000);
INSERT INTO international VALUES (13,'EventsCalendar',7,'±à¼­ÊÂÎñ',1031510000);
INSERT INTO international VALUES (13,'LinkList',7,'Ìí¼ÓÐÂÁ´½Ó¡£',1031510000);
INSERT INTO international VALUES (13,'UserSubmission',7,'Í¶¸åÊ±¼ä',1031510000);
INSERT INTO international VALUES (13,'WebGUI',7,'²é¿´°ïÖúË÷Òý',1031510000);
INSERT INTO international VALUES (14,'Article',7,'Í¼Æ¬Î»ÖÃ',1031510000);
INSERT INTO international VALUES (516,'WebGUI',7,'½øÈë¹ÜÀí',1031510000);
INSERT INTO international VALUES (517,'WebGUI',7,'ÍË³ö¹ÜÀí',1031510000);
INSERT INTO international VALUES (515,'WebGUI',7,'ÊÇ·ñÌí¼Ó±à¼­´Á£¿',1031510000);
INSERT INTO international VALUES (14,'UserSubmission',7,'×´Ì¬',1031510000);
INSERT INTO international VALUES (14,'WebGUI',7,'²é¿´µÈ´ýÉóºËµÄÍ¶¸å',1031510000);
INSERT INTO international VALUES (15,'UserSubmission',7,'±à¼­/É¾³ý',1031510000);
INSERT INTO international VALUES (15,'WebGUI',7,'Ò»ÔÂ',1031510000);
INSERT INTO international VALUES (16,'UserSubmission',7,'ÎÞ±êÌâ',1031510000);
INSERT INTO international VALUES (16,'WebGUI',7,'¶þÔÂ',1031510000);
INSERT INTO international VALUES (17,'UserSubmission',7,'ÄúÈ·¶¨ÒªÉ¾³ý´Ë¸å¼þÂð£¿',1031510000);
INSERT INTO international VALUES (17,'WebGUI',7,'ÈýÔÂ',1031510000);
INSERT INTO international VALUES (18,'UserSubmission',7,'±à¼­ÓÃ»§Í¶¸åÏµÍ³',1031510000);
INSERT INTO international VALUES (18,'WebGUI',7,'ËÄÔÂ',1031510000);
INSERT INTO international VALUES (19,'UserSubmission',7,'±à¼­Í¶¸å',1031510000);
INSERT INTO international VALUES (19,'WebGUI',7,'ÎåÔÂ',1031510000);
INSERT INTO international VALUES (20,'UserSubmission',7,'ÎÒÒªÍ¶¸å',1031510000);
INSERT INTO international VALUES (20,'WebGUI',7,'ÁùÔÂ',1031510000);
INSERT INTO international VALUES (21,'UserSubmission',7,'·¢±íÈË',1031510000);
INSERT INTO international VALUES (21,'WebGUI',7,'ÆßÔÂ',1031510000);
INSERT INTO international VALUES (22,'UserSubmission',7,'·¢±íÈË£º',1031510000);
INSERT INTO international VALUES (22,'WebGUI',7,'°ËÔÂ',1031510000);
INSERT INTO international VALUES (23,'UserSubmission',7,'Í¶¸åÊ±¼ä',1031510000);
INSERT INTO international VALUES (23,'WebGUI',7,'¾ÅÔÂ',1031510000);
INSERT INTO international VALUES (24,'UserSubmission',7,'Í¨¹ý',1031510000);
INSERT INTO international VALUES (24,'WebGUI',7,'Ê®ÔÂ',1031510000);
INSERT INTO international VALUES (25,'UserSubmission',7,'¼ÌÐøÉóºË',1031510000);
INSERT INTO international VALUES (25,'WebGUI',7,'Ê®Ò»ÔÂ',1031510000);
INSERT INTO international VALUES (26,'UserSubmission',7,'¾Ü¾ø',1031510000);
INSERT INTO international VALUES (26,'WebGUI',7,'Ê®¶þÔÂ',1031510000);
INSERT INTO international VALUES (27,'UserSubmission',7,'±à¼­',1031510000);
INSERT INTO international VALUES (27,'WebGUI',7,'ÐÇÆÚÈÕ',1031510000);
INSERT INTO international VALUES (28,'UserSubmission',7,'·µ»Ø¸å¼þÁÐ±í',1031510000);
INSERT INTO international VALUES (28,'WebGUI',7,'ÐÇÆÚÒ»',1031510000);
INSERT INTO international VALUES (29,'UserSubmission',7,'ÓÃ»§Í¶¸åÏµÍ³',1031510000);
INSERT INTO international VALUES (29,'WebGUI',7,'ÐÇÆÚ¶þ',1031510000);
INSERT INTO international VALUES (30,'WebGUI',7,'ÐÇÆÚÈý',1031510000);
INSERT INTO international VALUES (31,'WebGUI',7,'ÐÇÆÚËÄ',1031510000);
INSERT INTO international VALUES (32,'WebGUI',7,'ÐÇÆÚÎå',1031510000);
INSERT INTO international VALUES (33,'WebGUI',7,'ÐÇÆÚÁù',1031510000);
INSERT INTO international VALUES (34,'WebGUI',7,'ÉèÖÃÈÕÆÚ',1031510000);
INSERT INTO international VALUES (35,'WebGUI',7,'¹ÜÀí¹¦ÄÜ',1031510000);
INSERT INTO international VALUES (36,'WebGUI',7,'Äú±ØÐëÊÇÏµÍ³¹ÜÀíÔ±²ÅÄÜÊ¹ÓÃ´Ë¹¦ÄÜ¡£ÇëÁªÏµÄúµÄÏµÍ³¹ÜÀíÔ±¡£ÒÔÏÂÊÇ±¾ÏµÍ³µÄÏµÍ³¹ÜÀíÔ±Çåµ¥£º',1031510000);
INSERT INTO international VALUES (37,'WebGUI',7,'È¨ÏÞ±»¾Ü¾ø£¡',1031510000);
INSERT INTO international VALUES (404,'WebGUI',7,'µÚÒ»Ò³',1031510000);
INSERT INTO international VALUES (38,'WebGUI',7,'ÄúÃ»ÓÐ×ã¹»µÄÈ¨ÏÞÖ´ÐÐ´ËÏî²Ù×÷¡£Çë^a(µÇÂ¼);È»ºóÔÙÊÔÒ»´Î¡£',1031510000);
INSERT INTO international VALUES (39,'WebGUI',7,'¶Ô²»Æð£¬ÄúÃ»ÓÐ×ã¹»µÄÈ¨ÏÞ·ÃÎÊÒ»Ò³¡£',1031510000);
INSERT INTO international VALUES (40,'WebGUI',7,'ÏµÍ³×é¼þ',1031510000);
INSERT INTO international VALUES (41,'WebGUI',7,'Äú½«ÒªÉ¾³ýÒ»¸öÏµÍ³×é¼þ¡£Èç¹ûÄú¼ÌÐø£¬ÏµÍ³¹¦ÄÜ¿ÉÄÜ»áÊÜµ½Ó°Ïì¡£',1031510000);
INSERT INTO international VALUES (42,'WebGUI',7,'ÇëÈ·ÈÏ',1031510000);
INSERT INTO international VALUES (43,'WebGUI',7,'ÄúÊÇ·ñÈ·¶¨ÒªÉ¾³ý´ËÄÚÈÝÂð£¿',1031510000);
INSERT INTO international VALUES (44,'WebGUI',7,'ÊÇµÄ£¬ÎÒÈ·¶¨¡£',1031510000);
INSERT INTO international VALUES (45,'WebGUI',7,'²»£¬ÎÒ°´´íÁË¡£',1031510000);
INSERT INTO international VALUES (46,'WebGUI',7,'ÎÒµÄÕÊ»§',1031510000);
INSERT INTO international VALUES (47,'WebGUI',7,'Ê×Ò³',1031510000);
INSERT INTO international VALUES (48,'WebGUI',7,'»¶Ó­£¡',1031510000);
INSERT INTO international VALUES (49,'WebGUI',7,'µã»÷ <a href=\"^;?op=logout\">´Ë´¦</a> ÍË³öµÇÂ¼¡£',1031510000);
INSERT INTO international VALUES (50,'WebGUI',7,'ÕÊ»§',1031510000);
INSERT INTO international VALUES (51,'WebGUI',7,'ÃÜÂë',1031510000);
INSERT INTO international VALUES (52,'WebGUI',7,'µÇÂ¼',1031510000);
INSERT INTO international VALUES (53,'WebGUI',7,'´òÓ¡±¾Ò³',1031510000);
INSERT INTO international VALUES (54,'WebGUI',7,'´´½¨ÕÊ»§',1031510000);
INSERT INTO international VALUES (55,'WebGUI',7,'ÃÜÂë£¨È·ÈÏ£©',1031510000);
INSERT INTO international VALUES (56,'WebGUI',7,'µç×ÓÓÊ¼þ',1031510000);
INSERT INTO international VALUES (57,'WebGUI',7,'´ËÏîÖ»ÔÚÄúÏ£ÍûÊ¹ÓÃµ½ÐèÒªµç×ÓÓÊ¼þµÄ¹¦ÄÜµÄÊ±ºòÓÐÓÃ¡£',1031510000);
INSERT INTO international VALUES (58,'WebGUI',7,'ÎÒÒÑ¾­ÓÐÁËÒ»¸öÕÊ»§¡£',1031510000);
INSERT INTO international VALUES (59,'WebGUI',7,'ÎÒÍü¼ÇÁËÃÜÂë¡£',1031510000);
INSERT INTO international VALUES (60,'WebGUI',7,'ÄúÊÇ·ñÕæµÄÏ£Íû×¢ÏúÄúµÄÕÊ»§£¿Èç¹ûÄú¼ÌÐø£¬ÄúµÄÕÊ»§ÐÅÏ¢½«±»ÓÀ¾ÃÉ¾³ý¡£',1031510000);
INSERT INTO international VALUES (61,'WebGUI',7,'¸üÐÂÕÊ»§ÐÅÏ¢',1031510000);
INSERT INTO international VALUES (62,'WebGUI',7,'±£´æ',1031510000);
INSERT INTO international VALUES (63,'WebGUI',7,'½øÈë¹ÜÀí¡£',1031510000);
INSERT INTO international VALUES (64,'WebGUI',7,'ÍË³öµÇÂ¼¡£',1031510000);
INSERT INTO international VALUES (65,'WebGUI',7,'ÇëÉ¾³ýÎÒµÄÕÊ»§¡£',1031510000);
INSERT INTO international VALUES (66,'WebGUI',7,'ÓÃ»§µÇÂ¼',1031510000);
INSERT INTO international VALUES (67,'WebGUI',7,'´´½¨ÐÂÕÊ»§¡£',1031510000);
INSERT INTO international VALUES (68,'WebGUI',7,'ÄúÊäÈëµÄÕÊ»§ÐÅÏ¢ÎÞÐ§¡£¿ÉÄÜÊÇÄúÊäÈëµÄÕÊ»§²»´æÔÚ£¬»òÊäÈëÁË´íÎóµÄÃÜÂë¡£',1031510000);
INSERT INTO international VALUES (69,'WebGUI',7,'Èç¹ûÄúÐèÒªÐ­Öú£¬ÇëÁªÏµÏµÍ³¹ÜÀíÔ±¡£',1031510000);
INSERT INTO international VALUES (70,'WebGUI',7,'´íÎó',1031510000);
INSERT INTO international VALUES (71,'WebGUI',7,'»Ö¸´ÃÜÂë',1031510000);
INSERT INTO international VALUES (72,'WebGUI',7,'»Ö¸´',1031510000);
INSERT INTO international VALUES (73,'WebGUI',7,'ÓÃ»§µÇÂ¼',1031510000);
INSERT INTO international VALUES (74,'WebGUI',7,'ÕÊ»§ÐÅÏ¢',1031510000);
INSERT INTO international VALUES (75,'WebGUI',7,'ÄúµÄÕÊ»§ÐÅÏ¢ÒÑ¾­·¢ËÍµ½ÄúµÄµç×ÓÓÊ¼þÖÐ¡£',1031510000);
INSERT INTO international VALUES (76,'WebGUI',7,'¶Ô²»Æð£¬´Ëµç×ÓÓÊ¼þµØÖ·²»ÔÚÏµÍ³Êý¾Ý¿âÖÐ¡£',1031510000);
INSERT INTO international VALUES (77,'WebGUI',7,'¶Ô²»Æð£¬´ËÕÊ»§ÃûÒÑ±»ÆäËûÓÃ»§Ê¹ÓÃ¡£ÇëÁíÍâÑ¡ÔñÒ»¸öÓÃ»§Ãû¡£ÎÒÃÇ½¨ÒéÄúÊ¹ÓÃÒÔÏÂÃû×Ö×÷ÎªµÇÂ¼Ãû£º',1031510000);
INSERT INTO international VALUES (78,'WebGUI',7,'ÄúÊäÈëµÄÃÜÂë²»Ò»ÖÂ£¬ÇëÖØÐÂÊäÈë¡£',1031510000);
INSERT INTO international VALUES (79,'WebGUI',7,'²»ÄÜÁ¬½Óµ½Ä¿Â¼·þÎñÆ÷¡£',1031510000);
INSERT INTO international VALUES (80,'WebGUI',7,'´´½¨ÕÊ»§³É¹¦£¡',1031510000);
INSERT INTO international VALUES (81,'WebGUI',7,'¸üÐÂÕÊ»§³É¹¦£¡',1031510000);
INSERT INTO international VALUES (82,'WebGUI',7,'¹ÜÀí¹¦ÄÜ...',1031510000);
INSERT INTO international VALUES (536,'WebGUI',7,'ÐÂÓÃ»§ ^@; ¸Õ¼ÓÈë±¾Õ¾¡£',1031510000);
INSERT INTO international VALUES (84,'WebGUI',7,'ÓÃ»§×é',1031510000);
INSERT INTO international VALUES (85,'WebGUI',7,'ÃèÊö',1031510000);
INSERT INTO international VALUES (86,'WebGUI',7,'ÄúÈ·ÐÅÒªÉ¾³ý´ËÓÃ»§×éÂð£¿´ËÏî²Ù×÷½«ÓÀ¾ÃÉ¾³ý´ËÓÃ»§×é£¬²¢È¡Ïû´ËÓÃ»§×éËùÓÐÏà¹ØÈ¨ÏÞ¡£',1031510000);
INSERT INTO international VALUES (87,'WebGUI',7,'±à¼­ÓÃ»§×é',1031510000);
INSERT INTO international VALUES (88,'WebGUI',7,'ÓÃ»§×é³ÉÔ±',1031510000);
INSERT INTO international VALUES (89,'WebGUI',7,'ÓÃ»§×é',1031510000);
INSERT INTO international VALUES (90,'WebGUI',7,'Ìí¼ÓÐÂ×é¡£',1031510000);
INSERT INTO international VALUES (91,'WebGUI',7,'ÉÏÒ»Ò³',1031510000);
INSERT INTO international VALUES (92,'WebGUI',7,'ÏÂÒ»Ò³',1031510000);
INSERT INTO international VALUES (93,'WebGUI',7,'°ïÖú',1031510000);
INSERT INTO international VALUES (94,'WebGUI',7,'²Î¿¼',1031510000);
INSERT INTO international VALUES (95,'WebGUI',7,'°ïÖúË÷Òý',1031510000);
INSERT INTO international VALUES (99,'WebGUI',7,'±êÌâ',1031510000);
INSERT INTO international VALUES (100,'WebGUI',7,'Meta ±êÊ¶',1031510000);
INSERT INTO international VALUES (101,'WebGUI',7,'ÄúÈ·ÐÅÒªÉ¾³ý´ËÒ³ÃæÒÔ¼°Ò³ÃæÄÚµÄËùÓÐÄÚÈÝºÍ×é¼þÂð£¿',1031510000);
INSERT INTO international VALUES (102,'WebGUI',7,'±à¼­Ò³Ãæ',1031510000);
INSERT INTO international VALUES (103,'WebGUI',7,'Ò³ÃæÃèÊö',1031510000);
INSERT INTO international VALUES (104,'WebGUI',7,'Ò³Ãæ URL',1031510000);
INSERT INTO international VALUES (105,'WebGUI',7,'·ç¸ñ',1031510000);
INSERT INTO international VALUES (106,'WebGUI',7,'Ñ¡Ôñ¡°ÊÇ¡±½«±¾Ò³ÃæÏÂ¼¶ËùÓÐÒ³Ãæ·ç¸ñ¸ÄÎª´Ë·ç¸ñ¡£',1031510000);
INSERT INTO international VALUES (107,'WebGUI',7,'È¨ÏÞÉèÖÃ',1031510000);
INSERT INTO international VALUES (108,'WebGUI',7,'ÓµÓÐÕß',1031510000);
INSERT INTO international VALUES (109,'WebGUI',7,'ÓµÓÐÕß·ÃÎÊÈ¨ÏÞ£¿',1031510000);
INSERT INTO international VALUES (110,'WebGUI',7,'ÓµÓÐÕß±à¼­È¨ÏÞ£¿',1031510000);
INSERT INTO international VALUES (111,'WebGUI',7,'ÓÃ»§×é',1031510000);
INSERT INTO international VALUES (112,'WebGUI',7,'ÓÃ»§×é·ÃÎÊÈ¨ÏÞ£¿',1031510000);
INSERT INTO international VALUES (113,'WebGUI',7,'ÓÃ»§×é±à¼­È¨ÏÞ£¿',1031510000);
INSERT INTO international VALUES (114,'WebGUI',7,'ÈÎºÎÈË¿É·ÃÎÊ£¿',1031510000);
INSERT INTO international VALUES (115,'WebGUI',7,'ÈÎºÎÈË¿É±à¼­£¿',1031510000);
INSERT INTO international VALUES (116,'WebGUI',7,'Ñ¡Ôñ¡°ÊÇ¡±½«±¾Ò³ÃæÏÂ¼¶ËùÓÐÒ³ÃæÈ¨ÏÞ¸ÄÎª´ËÈ¨ÏÞÉèÖÃ¡£',1031510000);
INSERT INTO international VALUES (117,'WebGUI',7,'±à¼­ÓÃ»§ÉèÖÃ',1031510000);
INSERT INTO international VALUES (118,'WebGUI',7,'ÄäÃûÓÃ»§×¢²á',1031510000);
INSERT INTO international VALUES (119,'WebGUI',7,'Ä¬ÈÏÓÃ»§ÈÏÖ¤·½Ê½',1031510000);
INSERT INTO international VALUES (120,'WebGUI',7,'Ä¬ÈÏ LDAP URL',1031510000);
INSERT INTO international VALUES (121,'WebGUI',7,'Ä¬ÈÏ LDAP Identity',1031510000);
INSERT INTO international VALUES (122,'WebGUI',7,'LDAP Identity Ãû',1031510000);
INSERT INTO international VALUES (123,'WebGUI',7,'LDAP Password Ãû',1031510000);
INSERT INTO international VALUES (124,'WebGUI',7,'±à¼­¹«Ë¾ÐÅÏ¢',1031510000);
INSERT INTO international VALUES (125,'WebGUI',7,'¹«Ë¾Ãû',1031510000);
INSERT INTO international VALUES (126,'WebGUI',7,'¹«Ë¾µç×ÓÓÊ¼þµØÖ·',1031510000);
INSERT INTO international VALUES (127,'WebGUI',7,'¹«Ë¾Á´½Ó',1031510000);
INSERT INTO international VALUES (130,'WebGUI',7,'×î´ó¸½¼þ´óÐ¡',1031510000);
INSERT INTO international VALUES (133,'WebGUI',7,'±à¼­ÓÊ¼þÉèÖÃ',1031510000);
INSERT INTO international VALUES (134,'WebGUI',7,'»Ö¸´ÃÜÂëÓÊ¼þÄÚÈÝ',1031510000);
INSERT INTO international VALUES (135,'WebGUI',7,'ÓÊ¼þ·þÎñÆ÷',1031510000);
INSERT INTO international VALUES (138,'WebGUI',7,'ÊÇ',1031510000);
INSERT INTO international VALUES (139,'WebGUI',7,'·ñ',1031510000);
INSERT INTO international VALUES (140,'WebGUI',7,'±à¼­Ò»°ãÉèÖÃ',1031510000);
INSERT INTO international VALUES (141,'WebGUI',7,'Ä¬ÈÏÎ´ÕÒµ½Ò³Ãæ',1031510000);
INSERT INTO international VALUES (142,'WebGUI',7,'¶Ô»°³¬Ê±',1031510000);
INSERT INTO international VALUES (143,'WebGUI',7,'¹ÜÀíÉèÖÃ',1031510000);
INSERT INTO international VALUES (144,'WebGUI',7,'²é¿´Í³¼ÆÐÅÏ¢¡£',1031510000);
INSERT INTO international VALUES (145,'WebGUI',7,'ÏµÍ³°æ±¾',1031510000);
INSERT INTO international VALUES (146,'WebGUI',7,'»î¶¯¶Ô»°',1031510000);
INSERT INTO international VALUES (147,'WebGUI',7,'Ò³ÃæÊý',1031510000);
INSERT INTO international VALUES (148,'WebGUI',7,'×é¼þÊý',1031510000);
INSERT INTO international VALUES (149,'WebGUI',7,'ÓÃ»§Êý',1031510000);
INSERT INTO international VALUES (533,'WebGUI',7,'<b>²»°üÀ¨</b>ËÑË÷×Ö',1031510000);
INSERT INTO international VALUES (532,'WebGUI',7,'°üÀ¨<b>ÖÁÉÙÒ»¸ö</b>ËÑË÷×Ö',1031510000);
INSERT INTO international VALUES (151,'WebGUI',7,'·ç¸ñÃû',1031510000);
INSERT INTO international VALUES (505,'WebGUI',7,'Ìí¼ÓÒ»¸öÐÂÄ£°å',1031510000);
INSERT INTO international VALUES (504,'WebGUI',7,'Ä£°å',1031510000);
INSERT INTO international VALUES (502,'WebGUI',7,'ÄúÈ·ÐÅÒªÉ¾³ý´ËÄ£°å£¬²¢½«ËùÓÐÊ¹ÓÃ´ËÄ£°åµÄÒ³ÃæÉèÎªÄ¬ÈÏÄ£°å£¿',1031510000);
INSERT INTO international VALUES (154,'WebGUI',7,'·ç¸ñµ¥',1031510000);
INSERT INTO international VALUES (155,'WebGUI',7,'ÄúÈ·¶¨ÒªÉ¾³ý´ËÒ³Ãæ·ç¸ñ£¬²¢½«ËùÓÐÊ¹ÓÃ´Ë·ç¸ñµÄÒ³Ãæ·ç¸ñÉèÎª¡°°²È«Ä£Ê½¡±·ç¸ñ£¿',1031510000);
INSERT INTO international VALUES (156,'WebGUI',7,'±à¼­·ç¸ñ',1031510000);
INSERT INTO international VALUES (157,'WebGUI',7,'·ç¸ñ',1031510000);
INSERT INTO international VALUES (158,'WebGUI',7,'Ìí¼ÓÐÂ·ç¸ñ¡£',1031510000);
INSERT INTO international VALUES (160,'WebGUI',7,'Ìá½»ÈÕÆÚ',1031510000);
INSERT INTO international VALUES (161,'WebGUI',7,'Ìá½»ÈË',1031510000);
INSERT INTO international VALUES (162,'WebGUI',7,'ÄúÊÇ·ñÈ·¶¨ÒªÇå¿ÕÀ¬»øÏäÖÐËùÓÐÒ³ÃæºÍ×é¼þÂð£¿',1031510000);
INSERT INTO international VALUES (163,'WebGUI',7,'Ìí¼ÓÓÃ»§',1031510000);
INSERT INTO international VALUES (164,'WebGUI',7,'ÓÃ»§ÈÏÖ¤·½Ê½',1031510000);
INSERT INTO international VALUES (165,'WebGUI',7,'LDAP URL',1031510000);
INSERT INTO international VALUES (166,'WebGUI',7,'Á¬½Ó DN',1031510000);
INSERT INTO international VALUES (167,'WebGUI',7,'ÄúÊÇ·ñÈ·¶¨ÒªÉ¾³ý´ËÓÃ»§Âð£¿×¢ÒâÉ¾³ýÓÃ»§½«ÓÀ¾ÃÉ¾³ý¸ÃÓÃ»§µÄËùÓÐÐÅÏ¢¡£',1031510000);
INSERT INTO international VALUES (168,'WebGUI',7,'±à¼­ÓÃ»§',1031510000);
INSERT INTO international VALUES (169,'WebGUI',7,'Ìí¼ÓÐÂÓÃ»§¡£',1031510000);
INSERT INTO international VALUES (170,'WebGUI',7,'ËÑË÷',1031510000);
INSERT INTO international VALUES (171,'WebGUI',7,'¿ÉÊÓ»¯±à¼­',1031510000);
INSERT INTO international VALUES (174,'WebGUI',7,'ÊÇ·ñÏÔÊ¾±êÌâ£¿',1031510000);
INSERT INTO international VALUES (175,'WebGUI',7,'ÊÇ·ñÖ´ÐÐºêÃüÁî£¿',1031510000);
INSERT INTO international VALUES (228,'WebGUI',7,'±à¼­ÏûÏ¢...',1031510000);
INSERT INTO international VALUES (229,'WebGUI',7,'±êÌâ',1031510000);
INSERT INTO international VALUES (230,'WebGUI',7,'ÏûÏ¢',1031510000);
INSERT INTO international VALUES (231,'WebGUI',7,'·¢²¼ÐÂÏûÏ¢...',1031510000);
INSERT INTO international VALUES (232,'WebGUI',7,'ÎÞ±êÌâ',1031510000);
INSERT INTO international VALUES (233,'WebGUI',7,'(eom)',1031510000);
INSERT INTO international VALUES (234,'WebGUI',7,'·¢±í»ØÓ¦...',1031510000);
INSERT INTO international VALUES (237,'WebGUI',7,'±êÌâ£º',1031510000);
INSERT INTO international VALUES (238,'WebGUI',7,'×÷Õß£º',1031510000);
INSERT INTO international VALUES (239,'WebGUI',7,'ÈÕÆÚ£º',1031510000);
INSERT INTO international VALUES (240,'WebGUI',7,'ÏûÏ¢ ID:',1031510000);
INSERT INTO international VALUES (244,'WebGUI',7,'×÷Õß',1031510000);
INSERT INTO international VALUES (245,'WebGUI',7,'ÈÕÆÚ',1031510000);
INSERT INTO international VALUES (304,'WebGUI',7,'ÓïÑÔ',1031510000);
INSERT INTO international VALUES (306,'WebGUI',7,'ÓÃ»§Ãû°ó¶¨',1031510000);
INSERT INTO international VALUES (307,'WebGUI',7,'ÊÇ·ñÊ¹ÓÃÄ¬ÈÏ meta ±êÊ¶·û£¿',1031510000);
INSERT INTO international VALUES (308,'WebGUI',7,'±à¼­ÓÃ»§ÊôÐÔÉèÖÃ',1031510000);
INSERT INTO international VALUES (309,'WebGUI',7,'ÊÇ·ñÔÊÐíÊ¹ÓÃÕæÊµÐÕÃû£¿',1031510000);
INSERT INTO international VALUES (310,'WebGUI',7,'ÊÇ·ñÔÊÐíÊ¹ÓÃÀ©Õ¹ÁªÏµÐÅÏ¢£¿',1031510000);
INSERT INTO international VALUES (311,'WebGUI',7,'ÊÇ·ñÔÊÐíÊ¹ÓÃ¼ÒÍ¥ÐÅÏ¢£¿',1031510000);
INSERT INTO international VALUES (312,'WebGUI',7,'ÊÇ·ñÔÊÐíÊ¹ÓÃÉÌÒµÐÅÏ¢£¿',1031510000);
INSERT INTO international VALUES (313,'WebGUI',7,'ÊÇ·ñÔÊÐíÊ¹ÓÃÆäËûÐÅÏ¢£¿',1031510000);
INSERT INTO international VALUES (314,'WebGUI',7,'ÐÕ',1031510000);
INSERT INTO international VALUES (315,'WebGUI',7,'ÖÐ¼äÃû',1031510000);
INSERT INTO international VALUES (316,'WebGUI',7,'Ãû',1031510000);
INSERT INTO international VALUES (317,'WebGUI',7,'<a href=\"http://www.icq.com\">ICQ</a> UIN',1031510000);
INSERT INTO international VALUES (318,'WebGUI',7,'<a href=\"http://www.aol.com/aim/homenew.adp\">AIM</a> ID',1031510000);
INSERT INTO international VALUES (319,'WebGUI',7,'<a href=\"http://messenger.msn.com/\">MSN Messenger</a> ID',1031510000);
INSERT INTO international VALUES (320,'WebGUI',7,'<a href=\"http://messenger.yahoo.com/\">Yahoo! Messenger</a> ID',1031510000);
INSERT INTO international VALUES (321,'WebGUI',7,'ÒÆ¶¯µç»°',1031510000);
INSERT INTO international VALUES (322,'WebGUI',7,'´«ºô',1031510000);
INSERT INTO international VALUES (323,'WebGUI',7,'¼ÒÍ¥×¡Ö·',1031510000);
INSERT INTO international VALUES (324,'WebGUI',7,'³ÇÊÐ',1031510000);
INSERT INTO international VALUES (325,'WebGUI',7,'Ê¡·Ý',1031510000);
INSERT INTO international VALUES (326,'WebGUI',7,'ÓÊÕþ±àÂë',1031510000);
INSERT INTO international VALUES (327,'WebGUI',7,'¹ú¼Ò',1031510000);
INSERT INTO international VALUES (328,'WebGUI',7,'×¡Õ¬µç»°',1031510000);
INSERT INTO international VALUES (329,'WebGUI',7,'µ¥Î»µØÖ·',1031510000);
INSERT INTO international VALUES (330,'WebGUI',7,'³ÇÊÐ',1031510000);
INSERT INTO international VALUES (331,'WebGUI',7,'Ê¡·Ý',1031510000);
INSERT INTO international VALUES (332,'WebGUI',7,'ÓÊÕþ±àÂë',1031510000);
INSERT INTO international VALUES (333,'WebGUI',7,'¹ú¼Ò',1031510000);
INSERT INTO international VALUES (334,'WebGUI',7,'µ¥Î»µç»°',1031510000);
INSERT INTO international VALUES (335,'WebGUI',7,'ÐÔ±ð',1031510000);
INSERT INTO international VALUES (336,'WebGUI',7,'ÉúÈÕ',1031510000);
INSERT INTO international VALUES (337,'WebGUI',7,'¸öÈËÍøÒ³',1031510000);
INSERT INTO international VALUES (338,'WebGUI',7,'±à¼­ÓÃ»§ÊôÐÔ',1031510000);
INSERT INTO international VALUES (339,'WebGUI',7,'ÄÐ',1031510000);
INSERT INTO international VALUES (340,'WebGUI',7,'Å®',1031510000);
INSERT INTO international VALUES (341,'WebGUI',7,'±à¼­ÓÃ»§ÊôÐÔ¡£',1031510000);
INSERT INTO international VALUES (342,'WebGUI',7,'±à¼­ÕÊ»§ÐÅÏ¢',1031510000);
INSERT INTO international VALUES (343,'WebGUI',7,'²é¿´ÓÃ»§ÊôÐÔ¡£',1031510000);
INSERT INTO international VALUES (351,'WebGUI',7,'ÏûÏ¢',1031510000);
INSERT INTO international VALUES (345,'WebGUI',7,'²»ÊÇ±¾Õ¾ÓÃ»§',1031510000);
INSERT INTO international VALUES (346,'WebGUI',7,'´ËÓÃ»§²»ÔÙÊÇ±¾Õ¾ÓÃ»§¡£ÎÞ·¨Ìá¹©´ËÓÃ»§µÄ¸ü¶àÐÅÏ¢¡£',1031510000);
INSERT INTO international VALUES (347,'WebGUI',7,'²é¿´ÓÃ»§ÊôÐÔ£º',1031510000);
INSERT INTO international VALUES (348,'WebGUI',7,'ÐÕÃû',1031510000);
INSERT INTO international VALUES (349,'WebGUI',7,'×îÐÂ°æ±¾',1031510000);
INSERT INTO international VALUES (350,'WebGUI',7,'½áÊø',1031510000);
INSERT INTO international VALUES (352,'WebGUI',7,'·¢³öÈÕÆÚ',1031510000);
INSERT INTO international VALUES (471,'WebGUI',7,'±à¼­ÓÃ»§ÊôÐÔÏî',1031510000);
INSERT INTO international VALUES (355,'WebGUI',7,'Ä¬ÈÏ',1031510000);
INSERT INTO international VALUES (356,'WebGUI',7,'Ä£°å',1031510000);
INSERT INTO international VALUES (357,'WebGUI',7,'ÐÂÎÅ',1031510000);
INSERT INTO international VALUES (358,'WebGUI',7,'×óµ¼º½',1031510000);
INSERT INTO international VALUES (359,'WebGUI',7,'ÓÒµ¼º½',1031510000);
INSERT INTO international VALUES (360,'WebGUI',7,'Ò»¼ÓÈý',1031510000);
INSERT INTO international VALUES (361,'WebGUI',7,'Èý¼ÓÒ»',1031510000);
INSERT INTO international VALUES (362,'WebGUI',7,'Æ½·Ö',1031510000);
INSERT INTO international VALUES (363,'WebGUI',7,'Ä£°å¶¨Î»',1031510000);
INSERT INTO international VALUES (364,'WebGUI',7,'ËÑË÷',1031510000);
INSERT INTO international VALUES (365,'WebGUI',7,'ËÑË÷½á¹û...',1031510000);
INSERT INTO international VALUES (366,'WebGUI',7,'Ã»ÓÐÕÒµ½·ûºÏËÑË÷Ìõ¼þµÄÒ³Ãæ¡£',1031510000);
INSERT INTO international VALUES (368,'WebGUI',7,'½«´ËÓÃ»§¼ÓÈëÐÂÓÃ»§×é¡£',1031510000);
INSERT INTO international VALUES (369,'WebGUI',7,'¹ýÆÚÈÕÆÚ',1031510000);
INSERT INTO international VALUES (370,'WebGUI',7,'±à¼­ÓÃ»§·Ö×é',1031510000);
INSERT INTO international VALUES (371,'WebGUI',7,'Ìí¼ÓÓÃ»§·Ö×é',1031510000);
INSERT INTO international VALUES (372,'WebGUI',7,'±à¼­ÓÃ»§ËùÊô×éÈº',1031510000);
INSERT INTO international VALUES (605,'WebGUI',1,'Add Groups',1031514049);
INSERT INTO international VALUES (374,'WebGUI',7,'¹ÜÀí°ü¹ü¡£',1031510000);
INSERT INTO international VALUES (375,'WebGUI',7,'Ñ¡ÔñÒªÕ¹¿ªµÄ°ü¹ü¡£',1031510000);
INSERT INTO international VALUES (376,'WebGUI',7,'°ü¹ü',1031510000);
INSERT INTO international VALUES (377,'WebGUI',7,'°ü¹ü¹ÜÀíÔ±»òÏµÍ³¹ÜÀíÔ±Ã»ÓÐ¶¨Òå°ü¹ü¡£',1031510000);
INSERT INTO international VALUES (31,'UserSubmission',7,'ÄÚÈÝ',1031510000);
INSERT INTO international VALUES (32,'UserSubmission',7,'Í¼Æ¬',1031510000);
INSERT INTO international VALUES (33,'UserSubmission',7,'¸½¼þ',1031510000);
INSERT INTO international VALUES (34,'UserSubmission',7,'×ª»»»Ø³µ',1031510000);
INSERT INTO international VALUES (35,'UserSubmission',7,'±êÌâ',1031510000);
INSERT INTO international VALUES (21,'EventsCalendar',7,'ÊÇ·ñÖ´ÐÐÌí¼ÓÊÂÎñ£¿',1031510000);
INSERT INTO international VALUES (378,'WebGUI',7,'ÓÃ»§ ID',1031510000);
INSERT INTO international VALUES (379,'WebGUI',7,'ÓÃ»§×é ID',1031510000);
INSERT INTO international VALUES (380,'WebGUI',7,'·ç¸ñ ID',1031510000);
INSERT INTO international VALUES (381,'WebGUI',7,'ÏµÍ³ÊÕµ½Ò»¸öÎÞÐ§µÄ±íµ¥ÇëÇó£¬ÎÞ·¨¼ÌÐø¡£µ±Í¨¹ý±íµ¥ÊäÈëÁËÒ»Ð©·Ç·¨×Ö·û£¬Í¨³£»áµ¼ÖÂÕâ¸ö½á¹û¡£Çë°´ä¯ÀÀÆ÷µÄ·µ»Ø°´Å¦·µ»ØÉÏÒ³ÖØÐÂÊäÈë¡£',1031510000);
INSERT INTO international VALUES (1,'DownloadManager',7,'ÏÂÔØ¹ÜÀí',1031510000);
INSERT INTO international VALUES (3,'DownloadManager',7,'ÊÇ·ñÖ´ÐÐÌí¼ÓÎÄ¼þ£¿',1031510000);
INSERT INTO international VALUES (5,'DownloadManager',7,'ÎÄ¼þ±êÌâ',1031510000);
INSERT INTO international VALUES (6,'DownloadManager',7,'ÏÂÔØÎÄ¼þ',1031510000);
INSERT INTO international VALUES (7,'DownloadManager',7,'ÏÂÔØÓÃ»§×é',1031510000);
INSERT INTO international VALUES (8,'DownloadManager',7,'¼ò½é',1031510000);
INSERT INTO international VALUES (9,'DownloadManager',7,'±à¼­ÏÂÔØ¹ÜÀíÔ±',1031510000);
INSERT INTO international VALUES (10,'DownloadManager',7,'±à¼­ÏÂÔØ',1031510000);
INSERT INTO international VALUES (11,'DownloadManager',7,'Ìí¼ÓÐÂÏÂÔØ',1031510000);
INSERT INTO international VALUES (12,'DownloadManager',7,'ÄúÊÇ·ñÈ·¶¨ÒªÉ¾³ý´ËÏÂÔØÏîÂð£¿',1031510000);
INSERT INTO international VALUES (22,'DownloadManager',7,'ÊÇ·ñÖ´ÐÐÌí¼ÓÏÂÔØ£¿',1031510000);
INSERT INTO international VALUES (14,'DownloadManager',7,'ÎÄ¼þ',1031510000);
INSERT INTO international VALUES (15,'DownloadManager',7,'ÃèÊö',1031510000);
INSERT INTO international VALUES (16,'DownloadManager',7,'ÉÏÔØÈÕÆÚ',1031510000);
INSERT INTO international VALUES (15,'Article',7,'¿¿ÓÒ',1031510000);
INSERT INTO international VALUES (16,'Article',7,'¿¿×ó',1031510000);
INSERT INTO international VALUES (17,'Article',7,'¾ÓÖÐ',1031510000);
INSERT INTO international VALUES (37,'UserSubmission',7,'É¾³ý',1031510000);
INSERT INTO international VALUES (13,'SQLReport',7,'Convert carriage returns?',1031510000);
INSERT INTO international VALUES (17,'DownloadManager',7,'ÆäËû°æ±¾ #1',1031510000);
INSERT INTO international VALUES (18,'DownloadManager',7,'ÆäËû°æ±¾ #2',1031510000);
INSERT INTO international VALUES (19,'DownloadManager',7,'Ã»ÓÐÄú¿ÉÒÔÏÂÔØµÄÎÄ¼þ¡£',1031510000);
INSERT INTO international VALUES (14,'EventsCalendar',7,'¿ªÊ¼ÈÕÆÚ',1031510000);
INSERT INTO international VALUES (15,'EventsCalendar',7,'½áÊøÈÕÆÚ',1031510000);
INSERT INTO international VALUES (20,'DownloadManager',7,'ÔÚºóÃæ±ê×¢Ò³Âë',1031510000);
INSERT INTO international VALUES (14,'SQLReport',7,'Paginate After',1031510000);
INSERT INTO international VALUES (16,'EventsCalendar',7,'ÐÐÊÂÀú²¼¾Ö',1031510000);
INSERT INTO international VALUES (17,'EventsCalendar',7,'ÁÐ±í·½Ê½',1031510000);
INSERT INTO international VALUES (18,'EventsCalendar',7,'Calendar Month',1031510000);
INSERT INTO international VALUES (19,'EventsCalendar',7,'ÔÚºóÃæ±ê×¢Ò³Âë',1031510000);
INSERT INTO international VALUES (529,'WebGUI',7,'½á¹û',1031510000);
INSERT INTO international VALUES (383,'WebGUI',7,'Ãû×Ö',1031510000);
INSERT INTO international VALUES (384,'WebGUI',7,'ÎÄ¼þ',1031510000);
INSERT INTO international VALUES (385,'WebGUI',7,'²ÎÊý',1031510000);
INSERT INTO international VALUES (386,'WebGUI',7,'±à¼­Í¼Ïó',1031510000);
INSERT INTO international VALUES (387,'WebGUI',7,'ÉÏÔØÈË',1031510000);
INSERT INTO international VALUES (388,'WebGUI',7,'ÉÏÔØÈÕÆÚ',1031510000);
INSERT INTO international VALUES (389,'WebGUI',7,'Í¼Ïó ID',1031510000);
INSERT INTO international VALUES (390,'WebGUI',7,'ÏÔÊ¾Í¼Ïó...',1031510000);
INSERT INTO international VALUES (391,'WebGUI',7,'É¾³ý¸½¼ÓÎÄ¼þ¡£',1031510000);
INSERT INTO international VALUES (392,'WebGUI',7,'ÄúÈ·¶¨ÒªÉ¾³ý´ËÍ¼ÏóÂð£¿',1031510000);
INSERT INTO international VALUES (393,'WebGUI',7,'¹ÜÀíÍ¼Ïó',1031510000);
INSERT INTO international VALUES (394,'WebGUI',7,'¹ÜÀíÍ¼Ïó¡£',1031510000);
INSERT INTO international VALUES (395,'WebGUI',7,'Ìí¼ÓÐÂÍ¼Ïó¡£',1031510000);
INSERT INTO international VALUES (396,'WebGUI',7,'²é¿´Í¼Ïó',1031510000);
INSERT INTO international VALUES (397,'WebGUI',7,'·µ»ØÍ¼ÏóÁÐ±í¡£',1031510000);
INSERT INTO international VALUES (398,'WebGUI',7,'ÎÄµµÀàÐÍ¶¨Òå',1031510000);
INSERT INTO international VALUES (399,'WebGUI',7,'·ÖÎö±¾Ò³Ãæ¡£',1031510000);
INSERT INTO international VALUES (400,'WebGUI',7,'ÊÇ·ñ×èÖ¹´úÀí»º´æ£¿',1031510000);
INSERT INTO international VALUES (401,'WebGUI',7,'ÄúÊÇ·ñÈ·¶¨ÒªÉ¾³ý´ËÌõÏûÏ¢ÒÔ¼°´ËÌõÏûÏ¢µÄËùÓÐÏßË÷£¿',1031510000);
INSERT INTO international VALUES (402,'WebGUI',7,'ÄúÒªÔÄ¶ÁµÄÏûÏ¢²»´æÔÚ¡£',1031510000);
INSERT INTO international VALUES (403,'WebGUI',7,'²»¸æËßÄã',1031510000);
INSERT INTO international VALUES (405,'WebGUI',7,'×îºóÒ»Ò³',1031510000);
INSERT INTO international VALUES (406,'WebGUI',7,'¿ìÕÕ´óÐ¡',1031510000);
INSERT INTO international VALUES (21,'DownloadManager',7,'ÏÔÊ¾¿ìÕÕ',1031510000);
INSERT INTO international VALUES (407,'WebGUI',7,'µã»÷´Ë´¦×¢²á¡£',1031510000);
INSERT INTO international VALUES (15,'SQLReport',7,'Preprocess macros on query?',1031510000);
INSERT INTO international VALUES (16,'SQLReport',7,'Debug?',1031510000);
INSERT INTO international VALUES (17,'SQLReport',7,'<b>Debug:</b> Query:',1031510000);
INSERT INTO international VALUES (18,'SQLReport',7,'There were no results for this query.',1031510000);
INSERT INTO international VALUES (506,'WebGUI',7,'¹ÜÀíÄ£°å',1031510000);
INSERT INTO international VALUES (535,'WebGUI',7,'µ±ÐÂÓÃ»§×¢²áÊ±Í¨ÖªÓÃ»§×é',1031510000);
INSERT INTO international VALUES (353,'WebGUI',7,'ÏÖÔÚÄúµÄÊÕ¼þÏäÖÐÃ»ÓÐÏûÏ¢¡£',1031510000);
INSERT INTO international VALUES (530,'WebGUI',7,'ËÑË÷<b>ËùÓÐ</b>¹Ø¼ü×Ö',1031510000);
INSERT INTO international VALUES (408,'WebGUI',7,'¹ÜÀí¸ùÒ³Ãæ',1031510000);
INSERT INTO international VALUES (409,'WebGUI',7,'Ìí¼ÓÐÂ¸ùÒ³Ãæ¡£',1031510000);
INSERT INTO international VALUES (410,'WebGUI',7,'¹ÜÀí¸ùÒ³Ãæ¡£',1031510000);
INSERT INTO international VALUES (411,'WebGUI',7,'Ä¿Â¼±êÌâ',1031510000);
INSERT INTO international VALUES (412,'WebGUI',7,'Ò³ÃæÃèÊö',1031510000);
INSERT INTO international VALUES (9,'SiteMap',7,'ÏÔÊ¾¼ò½é£¿',1031510000);
INSERT INTO international VALUES (18,'Article',7,'ÊÇ·ñÔÊÐíÌÖÂÛ£¿',1031510000);
INSERT INTO international VALUES (19,'Article',7,'Ë­¿ÉÒÔ·¢±í£¿',1031510000);
INSERT INTO international VALUES (20,'Article',7,'Ë­¿ÉÒÔ¹ÜÀí£¿',1031510000);
INSERT INTO international VALUES (21,'Article',7,'±à¼­³¬Ê±',1031510000);
INSERT INTO international VALUES (22,'Article',7,'×÷Õß',1031510000);
INSERT INTO international VALUES (23,'Article',7,'ÈÕÆÚ',1031510000);
INSERT INTO international VALUES (24,'Article',7,'·¢±í»ØÓ¦',1031510000);
INSERT INTO international VALUES (25,'Article',7,'±à¼­»ØÓ¦',1031510000);
INSERT INTO international VALUES (26,'Article',7,'É¾³ý»ØÓ¦',1031510000);
INSERT INTO international VALUES (27,'Article',7,'·µ»ØÎÄÕÂ',1031510000);
INSERT INTO international VALUES (711,'WebGUI',1,'Image Managers Group',1031514049);
INSERT INTO international VALUES (28,'Article',7,'²é¿´»ØÓ¦',1031510000);
INSERT INTO international VALUES (57,'Product',1,'Are you certain you wish to delete this template and set all the products using it to the default template?',1031514049);
INSERT INTO international VALUES (53,'Product',1,'Edit Benefit',1031514049);
INSERT INTO international VALUES (416,'WebGUI',7,'<h1>ÄúµÄÇëÇó³öÏÖÎÊÌâ</h1> \r\nÄúµÄÇëÇó³öÏÖÒ»¸ö´íÎó¡£Çë°´ä¯ÀÀÆ÷µÄ·µ»Ø°´Å¥·µ»ØÉÏÒ»Ò³ÖØÊÔÒ»´Î¡£Èç¹û´ËÏî´íÎó¼ÌÐø´æÔÚ£¬ÇëÁªÏµÎÒÃÇ£¬Í¬Ê±¸æËßÎÒÃÇÄúÔÚÊ²Ã´Ê±¼äÊ¹ÓÃÊ²Ã´¹¦ÄÜµÄÊ±ºò³öÏÖµÄÕâ¸ö´íÎó¡£Ð»Ð»£¡',1031510000);
INSERT INTO international VALUES (417,'WebGUI',7,'<h1>°²È«¾¯±¨</h1>\r\n Äú·ÃÎÊµÄ×é¼þ²»ÔÚÕâÒ»Ò³ÉÏ¡£´ËÐÅÏ¢ÒÑ¾­·¢ËÍ¸øÏµÍ³¹ÜÀíÔ±¡£',1031510000);
INSERT INTO international VALUES (418,'WebGUI',7,'HTML ¹ýÂË',1031510000);
INSERT INTO international VALUES (419,'WebGUI',7,'Çå³ýËùÓÐµÄ±êÊ¶·û¡£',1031510000);
INSERT INTO international VALUES (420,'WebGUI',7,'±£ÁôËùÓÐµÄ±êÊ¶·û¡£',1031510000);
INSERT INTO international VALUES (421,'WebGUI',7,'±£Áô»ù±¾µÄ±êÊ¶·û¡£',1031510000);
INSERT INTO international VALUES (422,'WebGUI',7,'<h1>µÇÂ¼Ê§°Ü</h1>\r\nÄúÊäÈëµÄÕÊ»§ÐÅÏ¢ÓÐÎó¡£',1031510000);
INSERT INTO international VALUES (423,'WebGUI',7,'²é¿´»î¶¯¶Ô»°¡£',1031510000);
INSERT INTO international VALUES (424,'WebGUI',7,'²é¿´µÇÂ¼ÀúÊ·¼ÇÂ¼¡£',1031510000);
INSERT INTO international VALUES (425,'WebGUI',7,'»î¶¯¶Ô»°',1031510000);
INSERT INTO international VALUES (426,'WebGUI',7,'µÇÂ¼ÀúÊ·¼ÇÂ¼',1031510000);
INSERT INTO international VALUES (427,'WebGUI',7,'·ç¸ñ',1031510000);
INSERT INTO international VALUES (428,'WebGUI',7,'ÓÃ»§ (ID)',1031510000);
INSERT INTO international VALUES (429,'WebGUI',7,'µÇÂ¼Ê±¼ä',1031510000);
INSERT INTO international VALUES (430,'WebGUI',7,'×îºó·ÃÎÊÒ³Ãæ',1031510000);
INSERT INTO international VALUES (431,'WebGUI',7,'IP µØÖ·',1031510000);
INSERT INTO international VALUES (432,'WebGUI',7,'¹ýÆÚ',1031510000);
INSERT INTO international VALUES (433,'WebGUI',7,'ÓÃ»§¶Ë',1031510000);
INSERT INTO international VALUES (434,'WebGUI',7,'×´Ì¬',1031510000);
INSERT INTO international VALUES (435,'WebGUI',7,'¶Ô»°ÐÅºÅ',1031510000);
INSERT INTO international VALUES (436,'WebGUI',7,'É±µô´Ë¶Ô»°',1031510000);
INSERT INTO international VALUES (437,'WebGUI',7,'Í³¼ÆÐÅÏ¢',1031510000);
INSERT INTO international VALUES (438,'WebGUI',7,'ÄúµÄÃû×Ö',1031510000);
INSERT INTO international VALUES (439,'WebGUI',7,'¸öÈËÐÅÏ¢',1031510000);
INSERT INTO international VALUES (440,'WebGUI',7,'ÁªÏµÐÅÏ¢',1031510000);
INSERT INTO international VALUES (441,'WebGUI',7,'µç×ÓÓÊ¼þµ½´«ºôÍø¹Ø',1031510000);
INSERT INTO international VALUES (442,'WebGUI',7,'¹¤×÷ÐÅÏ¢',1031510000);
INSERT INTO international VALUES (443,'WebGUI',7,'¼ÒÍ¥ÐÅÏ¢',1031510000);
INSERT INTO international VALUES (444,'WebGUI',7,'¸öÈËÒþË½',1031510000);
INSERT INTO international VALUES (445,'WebGUI',7,'Ï²ºÃÉèÖÃ',1031510000);
INSERT INTO international VALUES (446,'WebGUI',7,'µ¥Î»ÍøÕ¾',1031510000);
INSERT INTO international VALUES (447,'WebGUI',7,'¹ÜÀíÒ³ÃæÊ÷',1031510000);
INSERT INTO international VALUES (448,'WebGUI',7,'Ò³ÃæÊ÷',1031510000);
INSERT INTO international VALUES (449,'WebGUI',7,'Ò»°ãÐÅÏ¢',1031510000);
INSERT INTO international VALUES (450,'WebGUI',7,'µ¥Î»Ãû³Æ',1031510000);
INSERT INTO international VALUES (451,'WebGUI',7,'±ØÐè',1031510000);
INSERT INTO international VALUES (452,'WebGUI',7,'½øÈëÖÐ...',1031510000);
INSERT INTO international VALUES (453,'WebGUI',7,'´´½¨ÈÕÆÚ',1031510000);
INSERT INTO international VALUES (454,'WebGUI',7,'×îºó¸üÐÂ',1031510000);
INSERT INTO international VALUES (455,'WebGUI',7,'±à¼­ÓÃ»§ÐÅÏ¢¡£',1031510000);
INSERT INTO international VALUES (456,'WebGUI',7,'·µ»ØÓÃ»§ÁÐ±í¡£',1031510000);
INSERT INTO international VALUES (457,'WebGUI',7,'±à¼­´ËÓÃ»§ÕÊ»§¡£',1031510000);
INSERT INTO international VALUES (458,'WebGUI',7,'±à¼­´ËÓÃ»§×éÈº¡£',1031510000);
INSERT INTO international VALUES (459,'WebGUI',7,'±à¼­´ËÓÃ»§ÊôÐÔ¡£',1031510000);
INSERT INTO international VALUES (460,'WebGUI',7,'Ê±Çø',1031510000);
INSERT INTO international VALUES (461,'WebGUI',7,'ÈÕÆÚ¸ñÊ½',1031510000);
INSERT INTO international VALUES (462,'WebGUI',7,'Ê±¼ä¸ñÊ½',1031510000);
INSERT INTO international VALUES (463,'WebGUI',7,'ÎÄ±¾ÊäÈëÇøÐÐÊý',1031510000);
INSERT INTO international VALUES (464,'WebGUI',7,'ÎÄ±¾ÊäÈëÇøÁÐÊý',1031510000);
INSERT INTO international VALUES (465,'WebGUI',7,'ÎÄ±¾¿ò´óÐ¡',1031510000);
INSERT INTO international VALUES (466,'WebGUI',7,'ÄúÈ·¶¨ÒªÉ¾³ý´ËÀà±ð²¢ÇÒ½«´ËÀà±ðÏÂËùÓÐÀ¸Ä¿ÒÆ¶¯µ½Ò»°ãÀà±ðÂð£¿',1031510000);
INSERT INTO international VALUES (467,'WebGUI',7,'ÄúÈ·¶¨ÒªÉ¾³ý´ËÀ¸Ä¿£¬²¢ÇÒËùÓÐ¹ØÓÚ´ËÀ¸Ä¿µÄÓÃ»§ÐÅÏ¢Âð£¿',1031510000);
INSERT INTO international VALUES (469,'WebGUI',7,'ID',1031510000);
INSERT INTO international VALUES (470,'WebGUI',7,'Ãû×Ö',1031510000);
INSERT INTO international VALUES (472,'WebGUI',7,'±êÌâ',1031510000);
INSERT INTO international VALUES (473,'WebGUI',7,'¿É¼û£¿',1031510000);
INSERT INTO international VALUES (474,'WebGUI',7,'±ØÐë£¿',1031510000);
INSERT INTO international VALUES (475,'WebGUI',7,'ÎÄ×Ö',1031510000);
INSERT INTO international VALUES (476,'WebGUI',7,'ÎÄ×ÖÇø',1031510000);
INSERT INTO international VALUES (477,'WebGUI',7,'HTML Çø',1031510000);
INSERT INTO international VALUES (478,'WebGUI',7,'URL',1031510000);
INSERT INTO international VALUES (479,'WebGUI',7,'ÈÕÆÚ',1031510000);
INSERT INTO international VALUES (480,'WebGUI',7,'µç×ÓÓÊ¼þµØÖ·',1031510000);
INSERT INTO international VALUES (481,'WebGUI',7,'µç»°ºÅÂë',1031510000);
INSERT INTO international VALUES (482,'WebGUI',7,'Êý×Ö (ÕûÊý)',1031510000);
INSERT INTO international VALUES (483,'WebGUI',7,'ÊÇ»ò·ñ',1031510000);
INSERT INTO international VALUES (484,'WebGUI',7,'Ñ¡ÔñÁÐ±í',1031510000);
INSERT INTO international VALUES (485,'WebGUI',7,'²¼¶ûÖµ (Ñ¡Ôñ¿ò)',1031510000);
INSERT INTO international VALUES (486,'WebGUI',7,'Êý¾ÝÀàÐÍ',1031510000);
INSERT INTO international VALUES (487,'WebGUI',7,'¿ÉÑ¡Öµ',1031510000);
INSERT INTO international VALUES (488,'WebGUI',7,'Ä¬ÈÏÖµ',1031510000);
INSERT INTO international VALUES (489,'WebGUI',7,'ÊôÐÔÀà',1031510000);
INSERT INTO international VALUES (490,'WebGUI',7,'Ìí¼ÓÒ»¸öÊôÐÔÀà¡£',1031510000);
INSERT INTO international VALUES (491,'WebGUI',7,'Ìí¼ÓÒ»¸öÊôÐÔÀ¸¡£',1031510000);
INSERT INTO international VALUES (492,'WebGUI',7,'ÊôÐÔÀ¸ÁÐ±í¡£',1031510000);
INSERT INTO international VALUES (493,'WebGUI',7,'·µ»ØÍøÕ¾¡£',1031510000);
INSERT INTO international VALUES (495,'WebGUI',7,'ÄÚÖÃ±à¼­Æ÷',1031510000);
INSERT INTO international VALUES (496,'WebGUI',7,'Ê¹ÓÃ',1031510000);
INSERT INTO international VALUES (494,'WebGUI',7,'Real Objects Edit-On Pro',1031510000);
INSERT INTO international VALUES (497,'WebGUI',7,'¿ªÊ¼ÈÕÆÚ',1031510000);
INSERT INTO international VALUES (498,'WebGUI',7,'½áÊøÈÕÆÚ',1031510000);
INSERT INTO international VALUES (499,'WebGUI',7,'×é¼þ ID',1031510000);
INSERT INTO international VALUES (500,'WebGUI',7,'Ò³Ãæ ID',1031510000);
INSERT INTO international VALUES (514,'WebGUI',7,'·ÃÎÊ',1031510000);
INSERT INTO international VALUES (527,'WebGUI',7,'Ä¬ÈÏÊ×Ò³',1031510000);
INSERT INTO international VALUES (503,'WebGUI',7,'Ä£°å ID',1031510000);
INSERT INTO international VALUES (501,'WebGUI',7,'Ö÷Ìå',1031510000);
INSERT INTO international VALUES (528,'WebGUI',7,'Ä£°åÃû³Æ',1031510000);
INSERT INTO international VALUES (468,'WebGUI',7,'±à¼­ÓÃ»§ÊôÐÔÀà',1031510000);
INSERT INTO international VALUES (159,'WebGUI',7,'ÊÕ¼þÏä',1031510000);
INSERT INTO international VALUES (508,'WebGUI',7,'¹ÜÀíÄ£°å¡£',1031510000);
INSERT INTO international VALUES (39,'UserSubmission',7,'·¢±í»Ø¸´',1031510000);
INSERT INTO international VALUES (40,'UserSubmission',7,'×÷Õß',1031510000);
INSERT INTO international VALUES (41,'UserSubmission',7,'ÈÕÆÚ',1031510000);
INSERT INTO international VALUES (42,'UserSubmission',7,'±à¼­»ØÓ¦',1031510000);
INSERT INTO international VALUES (43,'UserSubmission',7,'É¾³ý»ØÓ¦',1031510000);
INSERT INTO international VALUES (45,'UserSubmission',7,'·µ»ØÍ¶¸åÏµÍ³',1031510000);
INSERT INTO international VALUES (46,'UserSubmission',7,'¸ü¶à...',1031510000);
INSERT INTO international VALUES (47,'UserSubmission',7,'»Ø¸´',1031510000);
INSERT INTO international VALUES (48,'UserSubmission',7,'ÊÇ·ñÔÊÐíÌÖÂÛ£¿',1031510000);
INSERT INTO international VALUES (49,'UserSubmission',7,'±à¼­³¬Ê±',1031510000);
INSERT INTO international VALUES (50,'UserSubmission',7,'ÔÊÐí·¢±íµÄÓÃ»§×é',1031510000);
INSERT INTO international VALUES (44,'UserSubmission',7,'ÔÊÐí¹ÜÀíµÄÓÃ»§×é',1031510000);
INSERT INTO international VALUES (51,'UserSubmission',7,'ÏÔÊ¾¿ìÕÕ£¿',1031510000);
INSERT INTO international VALUES (52,'UserSubmission',7,'¿ìÕÕ',1031510000);
INSERT INTO international VALUES (53,'UserSubmission',7,'²¼¾Ö',1031510000);
INSERT INTO international VALUES (54,'UserSubmission',7,'ÁôÑÔÄ£Ê½',1031510000);
INSERT INTO international VALUES (55,'UserSubmission',7,'ÁÐ±íÄ£Ê½',1031510000);
INSERT INTO international VALUES (56,'UserSubmission',7,'Ïà²á',1031510000);
INSERT INTO international VALUES (57,'UserSubmission',7,'»ØÓ¦',1031510000);
INSERT INTO international VALUES (11,'FAQ',7,'ÊÇ·ñ´ò¿ª TOC £¿',1031510000);
INSERT INTO international VALUES (12,'FAQ',7,'ÊÇ·ñ´ò¿ª Q/A £¿',1031510000);
INSERT INTO international VALUES (13,'FAQ',7,'ÊÇ·ñ´ò¿ª [top] Á¬½Ó£¿',1031510000);
INSERT INTO international VALUES (14,'FAQ',7,'Q',1031510000);
INSERT INTO international VALUES (15,'FAQ',7,'A',1031510000);
INSERT INTO international VALUES (16,'FAQ',7,'[·µ»Ø¶¥¶Ë]',1031510000);
INSERT INTO international VALUES (509,'WebGUI',7,'ÌÖÂÛ²¼¾Ö',1031510000);
INSERT INTO international VALUES (510,'WebGUI',7,'Æ½ÆÌ',1031510000);
INSERT INTO international VALUES (511,'WebGUI',7,'ÏßË÷',1031510000);
INSERT INTO international VALUES (512,'WebGUI',7,'ÏÂÒ»ÌõÏßË÷',1031510000);
INSERT INTO international VALUES (513,'WebGUI',7,'ÉÏÒ»ÌõÏßË÷',1031510000);
INSERT INTO international VALUES (534,'WebGUI',7,'ÐÂÓÃ»§ÌáÊ¾£¿',1031510000);
INSERT INTO international VALUES (354,'WebGUI',7,'²é¿´ÊÕ¼þÏä¡£',1031510000);
INSERT INTO international VALUES (531,'WebGUI',7,'°üÀ¨<b>ÍêÕûµÄÆ´Ð´</b>',1031510000);
INSERT INTO international VALUES (518,'WebGUI',7,'ÊÕ¼þÏäÌáÊ¾',1031510000);
INSERT INTO international VALUES (519,'WebGUI',7,'ÎÒÏ£Íû±»ÌáÐÑ¡£',1031510000);
INSERT INTO international VALUES (520,'WebGUI',7,'ÎÒÏ£ÍûÍ¨¹ýµç×ÓÓÊ¼þµÄ·½Ê½ÌáÐÑ¡£',1031510000);
INSERT INTO international VALUES (521,'WebGUI',7,'ÎÒÏ£ÍûÍ¨¹ýµç×ÓÓÊ¼þµ½´«ºôµÄ·½Ê½ÌáÐÑ¡£',1031510000);
INSERT INTO international VALUES (522,'WebGUI',7,'ÎÒÏ£ÍûÍ¨¹ý ICQ µÄ·½Ê½ÌáÐÑ¡£',1031510000);
INSERT INTO international VALUES (523,'WebGUI',7,'ÌáÐÑ',1031510000);
INSERT INTO international VALUES (524,'WebGUI',7,'ÊÇ·ñÌí¼Ó±à¼­´Á£¿',1031510000);
INSERT INTO international VALUES (525,'WebGUI',7,'±à¼­ÄÚÈÝÉèÖÃ',1031510000);
INSERT INTO international VALUES (526,'WebGUI',7,'Ö»Çå³ý JavaScript ¡£',1031510000);
INSERT INTO international VALUES (584,'WebGUI',1,'Add a new language.',1031514049);
INSERT INTO international VALUES (585,'WebGUI',1,'Manage translations.',1031514049);
INSERT INTO international VALUES (586,'WebGUI',1,'Languages',1031514049);
INSERT INTO international VALUES (587,'WebGUI',1,'Are you certain you wish to delete this language and all the help and international messages that go with it?',1031514049);
INSERT INTO international VALUES (589,'WebGUI',1,'Edit Language',1031514049);
INSERT INTO international VALUES (590,'WebGUI',1,'Language ID',1031514049);
INSERT INTO international VALUES (591,'WebGUI',1,'Language',1031514049);
INSERT INTO international VALUES (592,'WebGUI',1,'Character Set',1031514049);
INSERT INTO international VALUES (595,'WebGUI',1,'International Messages',1031514049);
INSERT INTO international VALUES (596,'WebGUI',1,'MISSING',1031514049);
INSERT INTO international VALUES (597,'WebGUI',1,'Edit International Message',1031514049);
INSERT INTO international VALUES (598,'WebGUI',1,'Edit language.',1031514049);
INSERT INTO international VALUES (601,'WebGUI',1,'International ID',1031514049);
INSERT INTO international VALUES (1,'MailForm',1,'Mail Form',1031514049);
INSERT INTO international VALUES (2,'MailForm',1,'Your email subject here',1031514049);
INSERT INTO international VALUES (3,'MailForm',1,'Thank you for your feedback!',1031514049);
INSERT INTO international VALUES (4,'MailForm',1,'Hidden',1031514049);
INSERT INTO international VALUES (5,'MailForm',1,'Displayed',1031514049);
INSERT INTO international VALUES (6,'MailForm',1,'Modifiable',1031514049);
INSERT INTO international VALUES (7,'MailForm',1,'Edit Mail Form',1031514049);
INSERT INTO international VALUES (8,'MailForm',1,'Width',1031514049);
INSERT INTO international VALUES (9,'MailForm',1,'Add Field',1031514049);
INSERT INTO international VALUES (10,'MailForm',1,'From',1031514049);
INSERT INTO international VALUES (11,'MailForm',1,'To (email, username, or group name)',1031514049);
INSERT INTO international VALUES (12,'MailForm',1,'Cc',1031514049);
INSERT INTO international VALUES (13,'MailForm',1,'Bcc',1031514049);
INSERT INTO international VALUES (14,'MailForm',1,'Subject',1031514049);
INSERT INTO international VALUES (15,'MailForm',1,'Proceed to add more fields?',1031514049);
INSERT INTO international VALUES (16,'MailForm',1,'Acknowledgement',1031514049);
INSERT INTO international VALUES (17,'MailForm',1,'Mail Sent',1031514049);
INSERT INTO international VALUES (18,'MailForm',1,'Go back!',1031514049);
INSERT INTO international VALUES (19,'MailForm',1,'Are you certain that you want to delete this field?',1031514049);
INSERT INTO international VALUES (20,'MailForm',1,'Edit Field',1031514049);
INSERT INTO international VALUES (21,'MailForm',1,'Field Name',1031514049);
INSERT INTO international VALUES (22,'MailForm',1,'Status',1031514049);
INSERT INTO international VALUES (23,'MailForm',1,'Type',1031514049);
INSERT INTO international VALUES (24,'MailForm',1,'Possible Values (Drop-Down Box only)',1031514049);
INSERT INTO international VALUES (25,'MailForm',1,'Default Value (optional)',1031514049);
INSERT INTO international VALUES (26,'MailForm',1,'Store Entries?',1031514049);
INSERT INTO international VALUES (491,'WebGUI',8,'Aggiungi un campo al profilo.',1031510000);
INSERT INTO international VALUES (490,'WebGUI',8,'Aggiungi una categoria al profilo.',1031510000);
INSERT INTO international VALUES (489,'WebGUI',8,'Categoria Profilo',1031510000);
INSERT INTO international VALUES (488,'WebGUI',8,'Valore(i) di Default',1031510000);
INSERT INTO international VALUES (487,'WebGUI',8,'Valori Possibili',1031510000);
INSERT INTO international VALUES (486,'WebGUI',8,'Tipo Data',1031510000);
INSERT INTO international VALUES (484,'WebGUI',8,'Seleziona Lista',1031510000);
INSERT INTO international VALUES (485,'WebGUI',8,'Booleano (Checkbox)',1031510000);
INSERT INTO international VALUES (483,'WebGUI',8,'Si o No',1031510000);
INSERT INTO international VALUES (482,'WebGUI',8,'Numero (Intero)',1031510000);
INSERT INTO international VALUES (481,'WebGUI',8,'Telefono',1031510000);
INSERT INTO international VALUES (479,'WebGUI',8,'Data',1031510000);
INSERT INTO international VALUES (480,'WebGUI',8,'Indirizzo Email',1031510000);
INSERT INTO international VALUES (476,'WebGUI',8,'Text Area',1031510000);
INSERT INTO international VALUES (477,'WebGUI',8,'HTML Area',1031510000);
INSERT INTO international VALUES (478,'WebGUI',8,'URL',1031510000);
INSERT INTO international VALUES (475,'WebGUI',8,'Text',1031510000);
INSERT INTO international VALUES (473,'WebGUI',8,'Visibile?',1031510000);
INSERT INTO international VALUES (474,'WebGUI',8,'Campo Richisto?',1031510000);
INSERT INTO international VALUES (470,'WebGUI',8,'Nome',1031510000);
INSERT INTO international VALUES (472,'WebGUI',8,'Etichetta',1031510000);
INSERT INTO international VALUES (469,'WebGUI',8,'Id',1031510000);
INSERT INTO international VALUES (468,'WebGUI',8,'Modifica categoria profilo utenti',1031510000);
INSERT INTO international VALUES (467,'WebGUI',8,'Sei certo di voler cancellare questo campo e tutti i dati ad esso relativi?',1031510000);
INSERT INTO international VALUES (466,'WebGUI',8,'Sei certo di voler cancellare questa categoria e spostare il suo contenuto nella categoria Varie?',1031510000);
INSERT INTO international VALUES (465,'WebGUI',8,'Dimensione Text Box',1031510000);
INSERT INTO international VALUES (464,'WebGUI',8,'Colonne Text Area',1031510000);
INSERT INTO international VALUES (463,'WebGUI',8,'Righe Text Area',1031510000);
INSERT INTO international VALUES (462,'WebGUI',8,'Formato ora',1031510000);
INSERT INTO international VALUES (461,'WebGUI',8,'Formato data',1031510000);
INSERT INTO international VALUES (460,'WebGUI',8,'Time Offset',1031510000);
INSERT INTO international VALUES (459,'WebGUI',8,'Modifica il profilo di questo utente.',1031510000);
INSERT INTO international VALUES (458,'WebGUI',8,'Modifica il gruppo di questo utente.',1031510000);
INSERT INTO international VALUES (457,'WebGUI',8,'Modifica l\'account di questo utente.',1031510000);
INSERT INTO international VALUES (456,'WebGUI',8,'Indietro alla lista degli utenti.',1031510000);
INSERT INTO international VALUES (455,'WebGUI',8,'Modifica il profilo utente',1031510000);
INSERT INTO international VALUES (454,'WebGUI',8,'Ultimo aggiornamento',1031510000);
INSERT INTO international VALUES (452,'WebGUI',8,'Attendi...',1031510000);
INSERT INTO international VALUES (453,'WebGUI',8,'Data di creazione',1031510000);
INSERT INTO international VALUES (450,'WebGUI',8,'Professione (Azienda)',1031510000);
INSERT INTO international VALUES (451,'WebGUI',8,'é richiesto.',1031510000);
INSERT INTO international VALUES (448,'WebGUI',8,'Albero di Navigazione',1031510000);
INSERT INTO international VALUES (449,'WebGUI',8,'Informazioni varie',1031510000);
INSERT INTO international VALUES (447,'WebGUI',8,'Gestisci albero di navigazione.',1031510000);
INSERT INTO international VALUES (446,'WebGUI',8,'Web Site',1031510000);
INSERT INTO international VALUES (445,'WebGUI',8,'Preferenze',1031510000);
INSERT INTO international VALUES (444,'WebGUI',8,'Informazioni Geografiche',1031510000);
INSERT INTO international VALUES (443,'WebGUI',8,'Informazioni Tempo Libero',1031510000);
INSERT INTO international VALUES (441,'WebGUI',8,'Email al Pager ',1031510000);
INSERT INTO international VALUES (442,'WebGUI',8,'Informazioni Professionali',1031510000);
INSERT INTO international VALUES (440,'WebGUI',8,'Contatti',1031510000);
INSERT INTO international VALUES (439,'WebGUI',8,'Informazioni Personali',1031510000);
INSERT INTO international VALUES (438,'WebGUI',8,'Il tuo nome',1031510000);
INSERT INTO international VALUES (436,'WebGUI',8,'Uccidi Sessione',1031510000);
INSERT INTO international VALUES (437,'WebGUI',8,'Statistiche',1031510000);
INSERT INTO international VALUES (435,'WebGUI',8,'Firma di Sessione',1031510000);
INSERT INTO international VALUES (434,'WebGUI',8,'Stato',1031510000);
INSERT INTO international VALUES (433,'WebGUI',8,'User Agent',1031510000);
INSERT INTO international VALUES (432,'WebGUI',8,'Scade',1031510000);
INSERT INTO international VALUES (431,'WebGUI',8,'Indirizzo IP',1031510000);
INSERT INTO international VALUES (430,'WebGUI',8,'Ultima pagina vista',1031510000);
INSERT INTO international VALUES (429,'WebGUI',8,'Ultimo Login',1031510000);
INSERT INTO international VALUES (427,'WebGUI',8,'Stili',1031510000);
INSERT INTO international VALUES (428,'WebGUI',8,'Utente (ID)',1031510000);
INSERT INTO international VALUES (426,'WebGUI',8,'Storico Login',1031510000);
INSERT INTO international VALUES (425,'WebGUI',8,'Sessioni Attive',1031510000);
INSERT INTO international VALUES (424,'WebGUI',8,'Visualizza Storico Login.',1031510000);
INSERT INTO international VALUES (423,'WebGUI',8,'Visualizza Sessioni Attive.',1031510000);
INSERT INTO international VALUES (422,'WebGUI',8,'<h1>Login Fallito!</h1>\r\nLe informazioni che hai provvisto non corrispondono all\'account.',1031510000);
INSERT INTO international VALUES (421,'WebGUI',8,'Rimuovi tutto tranne che la formattazione basilare.',1031510000);
INSERT INTO international VALUES (420,'WebGUI',8,'Lascia com\'è.',1031510000);
INSERT INTO international VALUES (419,'WebGUI',8,'Rimuovi tutti i tag.',1031510000);
INSERT INTO international VALUES (418,'WebGUI',8,'Filtra l\'HTML nei contributi degli utenti',1031510000);
INSERT INTO international VALUES (417,'WebGUI',8,'<h1>Violazione della Sicurezza</h1>\r\nHai cercato di accedere ad un widget non associato a questa pagina. Questo incidente è stato registrato.',1031510000);
INSERT INTO international VALUES (52,'Product',1,'Add another benefit?',1031514049);
INSERT INTO international VALUES (416,'WebGUI',8,'<h1>Problemi con la richiesta</h1>\r\nci sono stati dei problemi con la tua richiesta. Prego clicca sul bottone \"indietro\" del browser e riprova. Se questo problema persiste, contattaci specificando quello che stai tentando di fare e la data dell\'errore.',1031510000);
INSERT INTO international VALUES (28,'Article',8,'Visualizza Risposte',1031510000);
INSERT INTO international VALUES (27,'Article',8,'Torna all\'articolo',1031510000);
INSERT INTO international VALUES (710,'WebGUI',1,'Edit Privilege Settings',1031514049);
INSERT INTO international VALUES (26,'Article',8,'Cancella Risposta',1031510000);
INSERT INTO international VALUES (25,'Article',8,'Modifica Risposta',1031510000);
INSERT INTO international VALUES (24,'Article',8,'Invia Risposta',1031510000);
INSERT INTO international VALUES (21,'Article',8,'Modifica Timeout',1031510000);
INSERT INTO international VALUES (22,'Article',8,'Autore',1031510000);
INSERT INTO international VALUES (23,'Article',8,'Data',1031510000);
INSERT INTO international VALUES (20,'Article',8,'Chi può moderare?',1031510000);
INSERT INTO international VALUES (19,'Article',8,'Chi può postare?',1031510000);
INSERT INTO international VALUES (18,'Article',8,'Consenti discussione?',1031510000);
INSERT INTO international VALUES (9,'SiteMap',8,'Visualizza Descrizione?',1031510000);
INSERT INTO international VALUES (411,'WebGUI',8,'Titolo nel Menu',1031510000);
INSERT INTO international VALUES (412,'WebGUI',8,'Descrizione',1031510000);
INSERT INTO international VALUES (410,'WebGUI',8,'Gestisci roots.',1031510000);
INSERT INTO international VALUES (409,'WebGUI',8,'Aggiungi una nuova root.',1031510000);
INSERT INTO international VALUES (408,'WebGUI',8,'Gestisci Roots',1031510000);
INSERT INTO international VALUES (18,'SQLReport',8,'Non ci sono risultati per questa query.',1031510000);
INSERT INTO international VALUES (16,'SQLReport',8,'Debug?',1031510000);
INSERT INTO international VALUES (17,'SQLReport',8,'<b>Debug:</b> Query:',1031510000);
INSERT INTO international VALUES (15,'SQLReport',8,'Preprocessa le macro nella query?',1031510000);
INSERT INTO international VALUES (46,'WebGUI',8,'Il mio account',1031510000);
INSERT INTO international VALUES (407,'WebGUI',8,'Clicca qui per registrarti.',1031510000);
INSERT INTO international VALUES (21,'DownloadManager',8,'Visualizza i  thumbnails?',1031510000);
INSERT INTO international VALUES (406,'WebGUI',8,'Grandezza del Thumbnail',1031510000);
INSERT INTO international VALUES (405,'WebGUI',8,'Ultima Pagina',1031510000);
INSERT INTO international VALUES (403,'WebGUI',8,'Preferisco non dirlo.',1031510000);
INSERT INTO international VALUES (402,'WebGUI',8,'Il messaggio che hai richiesto non esiste.',1031510000);
INSERT INTO international VALUES (22,'MessageBoard',8,'Cancella Messaggio',1031510000);
INSERT INTO international VALUES (21,'MessageBoard',8,'Chi può moderare?',1031510000);
INSERT INTO international VALUES (60,'WebGUI',8,'Sei sicuro di voler disattivare il tuo account? Se continui le informazioni del tuo account saranno perse permanentemente.',1031510000);
INSERT INTO international VALUES (401,'WebGUI',8,'Sei sicuro di voler cancellare questo messaggio e tutti i messaggi sotto di esso in questo thread?',1031510000);
INSERT INTO international VALUES (400,'WebGUI',8,'Impedisci la Cache del Proxy',1031510000);
INSERT INTO international VALUES (399,'WebGUI',8,'Valida questa pagina.',1031510000);
INSERT INTO international VALUES (398,'WebGUI',8,'Document Type Declaration',1031510000);
INSERT INTO international VALUES (394,'WebGUI',8,'Gestisci Immagini.',1031510000);
INSERT INTO international VALUES (395,'WebGUI',8,'Aggiungi una nuova Immagine.',1031510000);
INSERT INTO international VALUES (396,'WebGUI',8,'Visualizza Immagine',1031510000);
INSERT INTO international VALUES (397,'WebGUI',8,'Indietro alla lista delle Immagini.',1031510000);
INSERT INTO international VALUES (393,'WebGUI',8,'Gestisci Immagini',1031510000);
INSERT INTO international VALUES (391,'WebGUI',8,'Cancella il file Allegato.',1031510000);
INSERT INTO international VALUES (392,'WebGUI',8,'Sei sicuro di voler cancellare questa Immagine?',1031510000);
INSERT INTO international VALUES (390,'WebGUI',8,'Visualizza Immagine...',1031510000);
INSERT INTO international VALUES (389,'WebGUI',8,'Id Immagine',1031510000);
INSERT INTO international VALUES (387,'WebGUI',8,'Uploadato Da',1031510000);
INSERT INTO international VALUES (388,'WebGUI',8,'Data di Upload',1031510000);
INSERT INTO international VALUES (386,'WebGUI',8,'Modifica Immagine',1031510000);
INSERT INTO international VALUES (385,'WebGUI',8,'Parametri',1031510000);
INSERT INTO international VALUES (384,'WebGUI',8,'File',1031510000);
INSERT INTO international VALUES (19,'EventsCalendar',8,'Cambio Pagina dopo',1031510000);
INSERT INTO international VALUES (383,'WebGUI',8,'Nome',1031510000);
INSERT INTO international VALUES (18,'EventsCalendar',8,'Calendar Month',1031510000);
INSERT INTO international VALUES (16,'EventsCalendar',8,'Layout del Calendario',1031510000);
INSERT INTO international VALUES (17,'EventsCalendar',8,'Lista',1031510000);
INSERT INTO international VALUES (20,'DownloadManager',8,'Cambio Pagina dopo',1031510000);
INSERT INTO international VALUES (14,'SQLReport',8,'Cambio Pagina dopo',1031510000);
INSERT INTO international VALUES (14,'EventsCalendar',8,'Data di Inizio',1031510000);
INSERT INTO international VALUES (15,'EventsCalendar',8,'Data di Fine',1031510000);
INSERT INTO international VALUES (19,'DownloadManager',8,'Non hai files disponibili per il download.',1031510000);
INSERT INTO international VALUES (18,'DownloadManager',8,'Versione Alternativa #2',1031510000);
INSERT INTO international VALUES (17,'DownloadManager',8,'Versione Alternativa #1',1031510000);
INSERT INTO international VALUES (13,'SQLReport',8,'Converti gli a capo?',1031510000);
INSERT INTO international VALUES (37,'UserSubmission',8,'Cancella',1031510000);
INSERT INTO international VALUES (17,'Article',8,'Centro',1031510000);
INSERT INTO international VALUES (15,'Article',8,'Destra',1031510000);
INSERT INTO international VALUES (16,'Article',8,'Sinistra',1031510000);
INSERT INTO international VALUES (16,'DownloadManager',8,'Uploadato in Data',1031510000);
INSERT INTO international VALUES (15,'DownloadManager',8,'Descrizione',1031510000);
INSERT INTO international VALUES (14,'DownloadManager',8,'File',1031510000);
INSERT INTO international VALUES (9,'DownloadManager',8,'Modifica Download Manager',1031510000);
INSERT INTO international VALUES (10,'DownloadManager',8,'Modifica Download',1031510000);
INSERT INTO international VALUES (11,'DownloadManager',8,'Aggiungi un nuovo download',1031510000);
INSERT INTO international VALUES (12,'DownloadManager',8,'Sei sicuro di voler cancellare questo download?',1031510000);
INSERT INTO international VALUES (8,'DownloadManager',8,'Breve Descrizione',1031510000);
INSERT INTO international VALUES (7,'DownloadManager',8,'Group to Download',1031510000);
INSERT INTO international VALUES (6,'DownloadManager',8,'Download File',1031510000);
INSERT INTO international VALUES (3,'DownloadManager',8,'Continua aggiungendo un  file?',1031510000);
INSERT INTO international VALUES (5,'DownloadManager',8,'Titolo del File',1031510000);
INSERT INTO international VALUES (1,'DownloadManager',8,'Download Manager',1031510000);
INSERT INTO international VALUES (380,'WebGUI',8,'ID Stile',1031510000);
INSERT INTO international VALUES (381,'WebGUI',8,'Il sistema ha ricevuto un richiesta non valida. Utilizza il tasto bagk del browser e prova ancora',1031510000);
INSERT INTO international VALUES (35,'UserSubmission',8,'Titolo',1031510000);
INSERT INTO international VALUES (378,'WebGUI',8,'ID utente',1031510000);
INSERT INTO international VALUES (379,'WebGUI',8,'ID Gruppo',1031510000);
INSERT INTO international VALUES (34,'UserSubmission',8,'Converti gli a capo',1031510000);
INSERT INTO international VALUES (33,'UserSubmission',8,'Allegato',1031510000);
INSERT INTO international VALUES (32,'UserSubmission',8,'Immagine',1031510000);
INSERT INTO international VALUES (31,'UserSubmission',8,'Contenuto',1031510000);
INSERT INTO international VALUES (377,'WebGUI',8,'Nessun packages è stato definito dal tuo package manager o amministratore.',1031510000);
INSERT INTO international VALUES (11,'Poll',8,'Vota!',1031510000);
INSERT INTO international VALUES (374,'WebGUI',8,'Visualizza packages.',1031510000);
INSERT INTO international VALUES (375,'WebGUI',8,'Seleziona Package da svolgere',1031510000);
INSERT INTO international VALUES (376,'WebGUI',8,'Package',1031510000);
INSERT INTO international VALUES (373,'WebGUI',8,'<b>Attenzione:</b> modificando la lista dei gruppi sottostante, si resetta ogni informazione sulla scadenza di ogni gruppo ai nuovi defaults.',1031510000);
INSERT INTO international VALUES (371,'WebGUI',8,'Aggiungi Grouping',1031510000);
INSERT INTO international VALUES (372,'WebGUI',8,'Modifica i gruppi dell\'utente',1031510000);
INSERT INTO international VALUES (370,'WebGUI',8,'Modifica Grouping',1031510000);
INSERT INTO international VALUES (369,'WebGUI',8,'Data di scadenza',1031510000);
INSERT INTO international VALUES (368,'WebGUI',8,'Aggiungi un nuovo gruppo a questo utente.',1031510000);
INSERT INTO international VALUES (365,'WebGUI',8,'Risultati della ricerca...',1031510000);
INSERT INTO international VALUES (366,'WebGUI',8,'Non sono state trovate pagine che soddisfano la tua richiesta.',1031510000);
INSERT INTO international VALUES (364,'WebGUI',8,'Cerca',1031510000);
INSERT INTO international VALUES (362,'WebGUI',8,'Fianco a fianco',1031510000);
INSERT INTO international VALUES (363,'WebGUI',8,'Posizione nel Template',1031510000);
INSERT INTO international VALUES (361,'WebGUI',8,'Tre su Una',1031510000);
INSERT INTO international VALUES (359,'WebGUI',8,'Colonna Destra',1031510000);
INSERT INTO international VALUES (360,'WebGUI',8,'Una su Tre',1031510000);
INSERT INTO international VALUES (358,'WebGUI',8,'Colonna Sinistra',1031510000);
INSERT INTO international VALUES (357,'WebGUI',8,'News',1031510000);
INSERT INTO international VALUES (356,'WebGUI',8,'Template',1031510000);
INSERT INTO international VALUES (355,'WebGUI',8,'Default',1031510000);
INSERT INTO international VALUES (471,'WebGUI',8,'Modifica campi profilo utenti',1031510000);
INSERT INTO international VALUES (352,'WebGUI',8,'Data dell\'Elemento',1031510000);
INSERT INTO international VALUES (159,'WebGUI',8,'Inbox',1031510000);
INSERT INTO international VALUES (349,'WebGUI',8,'Ultima Versione Disponibile',1031510000);
INSERT INTO international VALUES (351,'WebGUI',8,'Messaggio',1031510000);
INSERT INTO international VALUES (350,'WebGUI',8,'Completato',1031510000);
INSERT INTO international VALUES (348,'WebGUI',8,'Nome',1031510000);
INSERT INTO international VALUES (347,'WebGUI',8,'Visualizza il Profilo per',1031510000);
INSERT INTO international VALUES (343,'WebGUI',8,'Visualizza Profilo.',1031510000);
INSERT INTO international VALUES (345,'WebGUI',8,'Non membro',1031510000);
INSERT INTO international VALUES (346,'WebGUI',8,'Questo utente non è più membro del nostro sito. Non abbiamo altre informazioni su questo utente.',1031510000);
INSERT INTO international VALUES (341,'WebGUI',8,'Modifica Profilo.',1031510000);
INSERT INTO international VALUES (342,'WebGUI',8,'Modifica le informazioni dell\'account.',1031510000);
INSERT INTO international VALUES (337,'WebGUI',8,'Homepage URL',1031510000);
INSERT INTO international VALUES (338,'WebGUI',8,'Modifica  Profilo',1031510000);
INSERT INTO international VALUES (339,'WebGUI',8,'Maschio',1031510000);
INSERT INTO international VALUES (340,'WebGUI',8,'Femmina',1031510000);
INSERT INTO international VALUES (336,'WebGUI',8,'Data di nascita',1031510000);
INSERT INTO international VALUES (335,'WebGUI',8,'Genere',1031510000);
INSERT INTO international VALUES (331,'WebGUI',8,'Stato lavoro',1031510000);
INSERT INTO international VALUES (332,'WebGUI',8,'CAP lavoro',1031510000);
INSERT INTO international VALUES (333,'WebGUI',8,'Provincia lavoro',1031510000);
INSERT INTO international VALUES (334,'WebGUI',8,'Telefono lavoro',1031510000);
INSERT INTO international VALUES (330,'WebGUI',8,'Città lavoro',1031510000);
INSERT INTO international VALUES (329,'WebGUI',8,'Indirizzo lavoro',1031510000);
INSERT INTO international VALUES (328,'WebGUI',8,'Telefono casa',1031510000);
INSERT INTO international VALUES (327,'WebGUI',8,'Provincia casa',1031510000);
INSERT INTO international VALUES (326,'WebGUI',8,'CAP casa',1031510000);
INSERT INTO international VALUES (324,'WebGUI',8,'Città casa',1031510000);
INSERT INTO international VALUES (325,'WebGUI',8,'Stato casa',1031510000);
INSERT INTO international VALUES (323,'WebGUI',8,'Indirizzo casa',1031510000);
INSERT INTO international VALUES (322,'WebGUI',8,'Pager',1031510000);
INSERT INTO international VALUES (321,'WebGUI',8,'Telefono Cellulare',1031510000);
INSERT INTO international VALUES (320,'WebGUI',8,'<a href=\"http://messenger.yahoo.com/\">Yahoo! Messenger</a> Id',1031510000);
INSERT INTO international VALUES (319,'WebGUI',8,'<a href=\"http://messenger.msn.com/\">MSN Messenger</a> Id',1031510000);
INSERT INTO international VALUES (318,'WebGUI',8,'<a href=\"http://www.aol.com/aim/homenew.adp\">AIM</a> Id',1031510000);
INSERT INTO international VALUES (317,'WebGUI',8,'<a href=\"http://www.icq.com\">ICQ</a> UIN',1031510000);
INSERT INTO international VALUES (316,'WebGUI',8,'Cognome',1031510000);
INSERT INTO international VALUES (315,'WebGUI',8,'Altro Nome',1031510000);
INSERT INTO international VALUES (314,'WebGUI',8,'Nome',1031510000);
INSERT INTO international VALUES (313,'WebGUI',8,'Consenti informazioni varie?',1031510000);
INSERT INTO international VALUES (312,'WebGUI',8,'Consenti informazioni business?',1031510000);
INSERT INTO international VALUES (311,'WebGUI',8,'Consenti informazioni home?',1031510000);
INSERT INTO international VALUES (310,'WebGUI',8,'Consenti informazioni extra sugli account?',1031510000);
INSERT INTO international VALUES (309,'WebGUI',8,'Consenti il nome reale?',1031510000);
INSERT INTO international VALUES (307,'WebGUI',8,'Usa i meta tags di default?',1031510000);
INSERT INTO international VALUES (308,'WebGUI',8,'Modifica i settaggi del profilo',1031510000);
INSERT INTO international VALUES (306,'WebGUI',8,'Binding del Nome Utente',1031510000);
INSERT INTO international VALUES (245,'WebGUI',8,'Data',1031510000);
INSERT INTO international VALUES (304,'WebGUI',8,'Lingua',1031510000);
INSERT INTO international VALUES (244,'WebGUI',8,'Autore',1031510000);
INSERT INTO international VALUES (239,'WebGUI',8,'Data:',1031510000);
INSERT INTO international VALUES (240,'WebGUI',8,'ID Messaggio:',1031510000);
INSERT INTO international VALUES (238,'WebGUI',8,'Autore:',1031510000);
INSERT INTO international VALUES (237,'WebGUI',8,'Oggetto:',1031510000);
INSERT INTO international VALUES (234,'WebGUI',8,'Inviare una Risposta...',1031510000);
INSERT INTO international VALUES (233,'WebGUI',8,'(eom)',1031510000);
INSERT INTO international VALUES (232,'WebGUI',8,'Senza Oggetto',1031510000);
INSERT INTO international VALUES (231,'WebGUI',8,'Inviare un nuovo Messaggio...',1031510000);
INSERT INTO international VALUES (230,'WebGUI',8,'Messaggio',1031510000);
INSERT INTO international VALUES (229,'WebGUI',8,'Oggetto',1031510000);
INSERT INTO international VALUES (228,'WebGUI',8,'Modifica Messaggio...',1031510000);
INSERT INTO international VALUES (175,'WebGUI',8,'Processa le macro?',1031510000);
INSERT INTO international VALUES (174,'WebGUI',8,'Visualizza il Titolo?',1031510000);
INSERT INTO international VALUES (170,'WebGUI',8,'cerca',1031510000);
INSERT INTO international VALUES (171,'WebGUI',8,'Assistente per la creazione del testo',1031510000);
INSERT INTO international VALUES (169,'WebGUI',8,'Aggiungi un nuovo Utente.',1031510000);
INSERT INTO international VALUES (168,'WebGUI',8,'Modifica Utente',1031510000);
INSERT INTO international VALUES (167,'WebGUI',8,'Sei sicuro di voler cancellare questo utente? Sappi che tutte le informazioni associate all\'utente saranno cancellate se procedi.',1031510000);
INSERT INTO international VALUES (165,'WebGUI',8,'LDAP URL',1031510000);
INSERT INTO international VALUES (166,'WebGUI',8,'Connect DN',1031510000);
INSERT INTO international VALUES (163,'WebGUI',8,'Aggiungi Utente',1031510000);
INSERT INTO international VALUES (164,'WebGUI',8,'Metodo di autenticazione',1031510000);
INSERT INTO international VALUES (162,'WebGUI',8,'Sei sicuro di voler cancellare tutte le pagine e i widgets nel cestino?',1031510000);
INSERT INTO international VALUES (161,'WebGUI',8,'Inviato Da',1031510000);
INSERT INTO international VALUES (160,'WebGUI',8,'Inviato in Data',1031510000);
INSERT INTO international VALUES (158,'WebGUI',8,'Aggiungi un nuovo stile.',1031510000);
INSERT INTO international VALUES (353,'WebGUI',8,'Non hai messaggi in Inbox attualmente.',1031510000);
INSERT INTO international VALUES (157,'WebGUI',8,'Stili',1031510000);
INSERT INTO international VALUES (156,'WebGUI',8,'Modifica Stile',1031510000);
INSERT INTO international VALUES (155,'WebGUI',8,'Sei sicuro di voler cancellare questo stile ed assegnare a tutte le pagine che lo usano lo stile \"Fail Safe\" ?',1031510000);
INSERT INTO international VALUES (151,'WebGUI',8,'Nome dello stile',1031510000);
INSERT INTO international VALUES (154,'WebGUI',8,'Style Sheet',1031510000);
INSERT INTO international VALUES (149,'WebGUI',8,'Utenti',1031510000);
INSERT INTO international VALUES (148,'WebGUI',8,'Widgets Visualizzabili',1031510000);
INSERT INTO international VALUES (147,'WebGUI',8,'Pagine Visualizzabili',1031510000);
INSERT INTO international VALUES (144,'WebGUI',8,'Visualizza statistiche.',1031510000);
INSERT INTO international VALUES (145,'WebGUI',8,'Versione',1031510000);
INSERT INTO international VALUES (146,'WebGUI',8,'Sessioni Attive',1031510000);
INSERT INTO international VALUES (143,'WebGUI',8,'Gestisci i settaggi',1031510000);
INSERT INTO international VALUES (142,'WebGUI',8,'Timeout della Sessione',1031510000);
INSERT INTO international VALUES (141,'WebGUI',8,'Pagina non trovata',1031510000);
INSERT INTO international VALUES (140,'WebGUI',8,'Modifica settaggi vari',1031510000);
INSERT INTO international VALUES (134,'WebGUI',8,'Messaggio di Recupero Password',1031510000);
INSERT INTO international VALUES (135,'WebGUI',8,'SMTP Server',1031510000);
INSERT INTO international VALUES (138,'WebGUI',8,'Sì',1031510000);
INSERT INTO international VALUES (139,'WebGUI',8,'No',1031510000);
INSERT INTO international VALUES (133,'WebGUI',8,'Modifica i settaggi della Mail',1031510000);
INSERT INTO international VALUES (130,'WebGUI',8,'Massima Dimensione Allegato',1031510000);
INSERT INTO international VALUES (127,'WebGUI',8,'URL dell\'Azienda',1031510000);
INSERT INTO international VALUES (126,'WebGUI',8,'Indirizzo Email dell\'Azienda',1031510000);
INSERT INTO international VALUES (125,'WebGUI',8,'Nome dell\'Azienda',1031510000);
INSERT INTO international VALUES (124,'WebGUI',8,'Modifica informazioni sull\'Azienda',1031510000);
INSERT INTO international VALUES (123,'WebGUI',8,'LDAP Password Name',1031510000);
INSERT INTO international VALUES (122,'WebGUI',8,'LDAP Identity Name',1031510000);
INSERT INTO international VALUES (121,'WebGUI',8,'LDAP Identity (default)',1031510000);
INSERT INTO international VALUES (120,'WebGUI',8,'LDAP URL (default)',1031510000);
INSERT INTO international VALUES (118,'WebGUI',8,'Registrazione Anonima',1031510000);
INSERT INTO international VALUES (119,'WebGUI',8,'Authentication Method (default)',1031510000);
INSERT INTO international VALUES (117,'WebGUI',8,'Modifica settaggi Utente',1031510000);
INSERT INTO international VALUES (116,'WebGUI',8,'Seleziona \"Si\" per dare a tutte le sottopagine gli stessi privilegi di questa.',1031510000);
INSERT INTO international VALUES (115,'WebGUI',8,'Chiunque può modificare?',1031510000);
INSERT INTO international VALUES (113,'WebGUI',8,'Il gruppo può modificare?',1031510000);
INSERT INTO international VALUES (114,'WebGUI',8,'Chiunque può visualizzare?',1031510000);
INSERT INTO international VALUES (112,'WebGUI',8,'Il gruppo può visualizzare?',1031510000);
INSERT INTO international VALUES (111,'WebGUI',8,'Gruppo',1031510000);
INSERT INTO international VALUES (110,'WebGUI',8,'Il proprietario può modificare?',1031510000);
INSERT INTO international VALUES (109,'WebGUI',8,'Il proprietario può visualizzare?',1031510000);
INSERT INTO international VALUES (108,'WebGUI',8,'Proprietario',1031510000);
INSERT INTO international VALUES (107,'WebGUI',8,'Privilegi',1031510000);
INSERT INTO international VALUES (106,'WebGUI',8,'Seleziona \"Si\" per dare a tutte le sottopagine lo stesso stile di questa.',1031510000);
INSERT INTO international VALUES (105,'WebGUI',8,'Stile',1031510000);
INSERT INTO international VALUES (104,'WebGUI',8,'URL della Pagina',1031510000);
INSERT INTO international VALUES (102,'WebGUI',8,'Modifica Pagina',1031510000);
INSERT INTO international VALUES (103,'WebGUI',8,'Specifiche della Pagina',1031510000);
INSERT INTO international VALUES (101,'WebGUI',8,'Sei sicuro di voler cancellare questa pagina, il suo contenuto, e tutti gli elementi sotto di essa?',1031510000);
INSERT INTO international VALUES (100,'WebGUI',8,'Meta Tags',1031510000);
INSERT INTO international VALUES (99,'WebGUI',8,'Titolo',1031510000);
INSERT INTO international VALUES (642,'WebGUI',1,'Page, Add/Edit',1031514049);
INSERT INTO international VALUES (95,'WebGUI',8,'Indice Aiuto',1031510000);
INSERT INTO international VALUES (94,'WebGUI',8,'Vedi anche',1031510000);
INSERT INTO international VALUES (93,'WebGUI',8,'Aiuto',1031510000);
INSERT INTO international VALUES (92,'WebGUI',8,'Pagina Successiva',1031510000);
INSERT INTO international VALUES (91,'WebGUI',8,'Pagina Precedente',1031510000);
INSERT INTO international VALUES (89,'WebGUI',8,'Gruppi',1031510000);
INSERT INTO international VALUES (90,'WebGUI',8,'Aggiungi nuovo gruppo.',1031510000);
INSERT INTO international VALUES (88,'WebGUI',8,'Utenti nel Gruppo',1031510000);
INSERT INTO international VALUES (87,'WebGUI',8,'Modifica Gruppo',1031510000);
INSERT INTO international VALUES (86,'WebGUI',8,'Sei sicuro di voler cancellare questo gruppo? Sappi che cancellare un gruppo è permanente e rimuoverà tutti i privilrgi associati a questo gruppo.',1031510000);
INSERT INTO international VALUES (84,'WebGUI',8,'Nome del Gruppo',1031510000);
INSERT INTO international VALUES (85,'WebGUI',8,'Corpo del testo',1031510000);
INSERT INTO international VALUES (82,'WebGUI',8,'Funzioni Amministrative...',1031510000);
INSERT INTO international VALUES (81,'WebGUI',8,'Account aggiornato con successo!',1031510000);
INSERT INTO international VALUES (80,'WebGUI',8,'Account creato con successo!',1031510000);
INSERT INTO international VALUES (79,'WebGUI',8,'Cannot connect to LDAP server.',1031510000);
INSERT INTO international VALUES (78,'WebGUI',8,'Le tue password non corrispondono. Prego prova di nuovo.',1031510000);
INSERT INTO international VALUES (77,'WebGUI',8,'Questo nome di account è già in uso da un altro membro di questo sito. Prego scegli un nuovo nome utente. Ecco alcuni suggerimenti:',1031510000);
INSERT INTO international VALUES (76,'WebGUI',8,'Questo indirizzo di email non è nei nostri database.',1031510000);
INSERT INTO international VALUES (75,'WebGUI',8,'Le Informazioni sul tuo account sono state inviate al tuo indirizzo di email.',1031510000);
INSERT INTO international VALUES (74,'WebGUI',8,'Informazioni Account',1031510000);
INSERT INTO international VALUES (73,'WebGUI',8,'Entra.',1031510000);
INSERT INTO international VALUES (72,'WebGUI',8,'recupera',1031510000);
INSERT INTO international VALUES (70,'WebGUI',8,'Errore',1031510000);
INSERT INTO international VALUES (71,'WebGUI',8,'Recupera password',1031510000);
INSERT INTO international VALUES (69,'WebGUI',8,'Prego contatta il tuo amministratore di sistema per assistenza.',1031510000);
INSERT INTO international VALUES (68,'WebGUI',8,'Le informazioni sul\' account non sono valide. O l\'account non esiste oppure hai fornito una combinazione errata di Nome Utente/Password.',1031510000);
INSERT INTO international VALUES (67,'WebGUI',8,'Crea un nuovo account.',1031510000);
INSERT INTO international VALUES (66,'WebGUI',8,'Entra',1031510000);
INSERT INTO international VALUES (65,'WebGUI',8,'Prego disattiva il mio account permanentemente.',1031510000);
INSERT INTO international VALUES (64,'WebGUI',8,'Esci.',1031510000);
INSERT INTO international VALUES (63,'WebGUI',8,'Attiva l\'Interfaccia Amministrativa.',1031510000);
INSERT INTO international VALUES (62,'WebGUI',8,'Salva',1031510000);
INSERT INTO international VALUES (61,'WebGUI',8,'Aggiorna Informazioni dell\'Account',1031510000);
INSERT INTO international VALUES (492,'WebGUI',8,'Lista dei campi del profilo.',1031510000);
INSERT INTO international VALUES (59,'WebGUI',8,'Ho dimenticato la password.',1031510000);
INSERT INTO international VALUES (58,'WebGUI',8,'Ho già un account.',1031510000);
INSERT INTO international VALUES (57,'WebGUI',8,'E\' necessario solo se vuoi usare funzioni che richiedono l\'email.',1031510000);
INSERT INTO international VALUES (56,'WebGUI',8,'Indirizzo Email',1031510000);
INSERT INTO international VALUES (55,'WebGUI',8,'Password (conferma)',1031510000);
INSERT INTO international VALUES (54,'WebGUI',8,'Crea Account',1031510000);
INSERT INTO international VALUES (51,'WebGUI',8,'Password',1031510000);
INSERT INTO international VALUES (52,'WebGUI',8,'login',1031510000);
INSERT INTO international VALUES (53,'WebGUI',8,'Rendi Pagina Stampabile',1031510000);
INSERT INTO international VALUES (50,'WebGUI',8,'Nome Utente',1031510000);
INSERT INTO international VALUES (48,'WebGUI',8,'Ciao',1031510000);
INSERT INTO international VALUES (49,'WebGUI',8,'<br>Clicca <a href=\"^\\;?op=logout\">qui</a> per uscire.',1031510000);
INSERT INTO international VALUES (47,'WebGUI',8,'Home',1031510000);
INSERT INTO international VALUES (45,'WebGUI',8,'No, ho fatto uno sbaglio.',1031510000);
INSERT INTO international VALUES (44,'WebGUI',8,'Sì, sono sicuro.',1031510000);
INSERT INTO international VALUES (43,'WebGUI',8,'Sei sicuro di voler cancellare questo contenuto?',1031510000);
INSERT INTO international VALUES (42,'WebGUI',8,'Prego Conferma',1031510000);
INSERT INTO international VALUES (41,'WebGUI',8,'Hai cercato di rimuovere un componente vitale del sistema. Se continui può\r\ncessare di funzionare.',1031510000);
INSERT INTO international VALUES (40,'WebGUI',8,'Componente Vitale',1031510000);
INSERT INTO international VALUES (39,'WebGUI',8,'Non hai abbastanza privilegi per accedere a questa pagina.',1031510000);
INSERT INTO international VALUES (38,'WebGUI',8,'Non hai abbastanza privilegi per questa operazione. Prego ^a(entra con un account); che ha sufficenti privilegi prima di eseguire questa operazione.',1031510000);
INSERT INTO international VALUES (404,'WebGUI',8,'Prima Pagina',1031510000);
INSERT INTO international VALUES (37,'WebGUI',8,'Permesso negato!',1031510000);
INSERT INTO international VALUES (36,'WebGUI',8,'Devi essere un amministratore per usare questa funzione. Per favore contatta uno degli amministratori. Questa è una lista degli amministratori di questo sistema:',1031510000);
INSERT INTO international VALUES (35,'WebGUI',8,'Funzioni Amministrative',1031510000);
INSERT INTO international VALUES (34,'WebGUI',8,'imposta la data (mm/gg/aaaa)',1031510000);
INSERT INTO international VALUES (33,'WebGUI',8,'Sabato',1031510000);
INSERT INTO international VALUES (31,'WebGUI',8,'Giovedì',1031510000);
INSERT INTO international VALUES (32,'WebGUI',8,'Venerdì',1031510000);
INSERT INTO international VALUES (30,'WebGUI',8,'Mercoledì',1031510000);
INSERT INTO international VALUES (29,'WebGUI',8,'Martedì',1031510000);
INSERT INTO international VALUES (29,'UserSubmission',8,'Sistema di Contributi degli Utenti',1031510000);
INSERT INTO international VALUES (28,'WebGUI',8,'Lunedì',1031510000);
INSERT INTO international VALUES (28,'UserSubmission',8,'Ritorna alla lista dei Contributi',1031510000);
INSERT INTO international VALUES (27,'WebGUI',8,'Domenica',1031510000);
INSERT INTO international VALUES (27,'UserSubmission',8,'Modifica',1031510000);
INSERT INTO international VALUES (26,'WebGUI',8,'Dicembre',1031510000);
INSERT INTO international VALUES (26,'UserSubmission',8,'Rifiuta',1031510000);
INSERT INTO international VALUES (25,'WebGUI',8,'Novembre',1031510000);
INSERT INTO international VALUES (25,'UserSubmission',8,'Lascia Pendenti',1031510000);
INSERT INTO international VALUES (24,'WebGUI',8,'Ottobre',1031510000);
INSERT INTO international VALUES (24,'UserSubmission',8,'Approva',1031510000);
INSERT INTO international VALUES (23,'WebGUI',8,'Settembre',1031510000);
INSERT INTO international VALUES (23,'UserSubmission',8,'Mandato in Data:',1031510000);
INSERT INTO international VALUES (22,'WebGUI',8,'Agosto',1031510000);
INSERT INTO international VALUES (22,'UserSubmission',8,'Mandato da:',1031510000);
INSERT INTO international VALUES (21,'WebGUI',8,'Luglio',1031510000);
INSERT INTO international VALUES (21,'UserSubmission',8,'Mandato da',1031510000);
INSERT INTO international VALUES (20,'WebGUI',8,'Giugno',1031510000);
INSERT INTO international VALUES (20,'UserSubmission',8,'Manda un nuovo Contributo',1031510000);
INSERT INTO international VALUES (19,'WebGUI',8,'Maggio',1031510000);
INSERT INTO international VALUES (20,'MessageBoard',8,'Ultima Risposta',1031510000);
INSERT INTO international VALUES (19,'UserSubmission',8,'Modifica Contributo',1031510000);
INSERT INTO international VALUES (19,'MessageBoard',8,'Risposte',1031510000);
INSERT INTO international VALUES (18,'WebGUI',8,'Aprile',1031510000);
INSERT INTO international VALUES (18,'UserSubmission',8,'Modifica il sistema di contributi degli utenti',1031510000);
INSERT INTO international VALUES (18,'MessageBoard',8,'Thread Iniziato',1031510000);
INSERT INTO international VALUES (17,'WebGUI',8,'Marzo',1031510000);
INSERT INTO international VALUES (17,'UserSubmission',8,'Sei sicuro di voler cancellare questo contributo?',1031510000);
INSERT INTO international VALUES (17,'MessageBoard',8,'Manda un nuovo Messaggio',1031510000);
INSERT INTO international VALUES (16,'WebGUI',8,'Febbraio',1031510000);
INSERT INTO international VALUES (16,'UserSubmission',8,'Senza Titolo',1031510000);
INSERT INTO international VALUES (16,'MessageBoard',8,'Data',1031510000);
INSERT INTO international VALUES (15,'WebGUI',8,'Gennaio',1031510000);
INSERT INTO international VALUES (15,'UserSubmission',8,'Modifica/Cancella',1031510000);
INSERT INTO international VALUES (15,'MessageBoard',8,'Autore',1031510000);
INSERT INTO international VALUES (14,'WebGUI',8,'Visualizza i contributi pendenti.',1031510000);
INSERT INTO international VALUES (14,'UserSubmission',8,'Stato',1031510000);
INSERT INTO international VALUES (14,'Article',8,'Allinea Immagine',1031510000);
INSERT INTO international VALUES (13,'WebGUI',8,'Visualizza indice dell\'aiuto.',1031510000);
INSERT INTO international VALUES (13,'UserSubmission',8,'Data',1031510000);
INSERT INTO international VALUES (13,'MessageBoard',8,'Rispondi',1031510000);
INSERT INTO international VALUES (13,'LinkList',8,'Aggiungi un nuovo link.',1031510000);
INSERT INTO international VALUES (13,'EventsCalendar',8,'Modifica Evento',1031510000);
INSERT INTO international VALUES (13,'Article',8,'Cancella',1031510000);
INSERT INTO international VALUES (12,'WebGUI',8,'Spegni interfaccia amministrativa.',1031510000);
INSERT INTO international VALUES (12,'UserSubmission',8,'(deseleziona se scrivi in HTML)',1031510000);
INSERT INTO international VALUES (12,'EventsCalendar',8,'Modifica Calendario Eventi',1031510000);
INSERT INTO international VALUES (12,'LinkList',8,'Modifica Link',1031510000);
INSERT INTO international VALUES (12,'MessageBoard',8,'Modifica Messaggio',1031510000);
INSERT INTO international VALUES (12,'SQLReport',8,'Error: Could not connect to the database.',1031510000);
INSERT INTO international VALUES (11,'WebGUI',8,'Svuota il cestino',1031510000);
INSERT INTO international VALUES (12,'Article',8,'Modifica Articolo',1031510000);
INSERT INTO international VALUES (11,'SQLReport',8,'<b>Debug:</b> Errore: c\'è stato un problema con la query.',1031510000);
INSERT INTO international VALUES (11,'MessageBoard',8,'Torna alla lista dei messaggi',1031510000);
INSERT INTO international VALUES (75,'EventsCalendar',1,'Which do you wish to do?',1031514049);
INSERT INTO international VALUES (11,'Article',8,'(Seleziona \"Si\" solo se non hai aggiunto &lt;br&gt; manualmente.)',1031510000);
INSERT INTO international VALUES (10,'WebGUI',8,'Visualizza il cestino.',1031510000);
INSERT INTO international VALUES (10,'UserSubmission',8,'Stato predefinito',1031510000);
INSERT INTO international VALUES (10,'SQLReport',8,'Error: The SQL specified is of an improper format.',1031510000);
INSERT INTO international VALUES (10,'Poll',8,'Azzera i voti.',1031510000);
INSERT INTO international VALUES (10,'LinkList',8,'Modifica Lista di Link',1031510000);
INSERT INTO international VALUES (10,'FAQ',8,'Modifica Domanda',1031510000);
INSERT INTO international VALUES (715,'WebGUI',1,'Redirect URL',1031514049);
INSERT INTO international VALUES (10,'Article',8,'Converti gli \'a capo\'?',1031510000);
INSERT INTO international VALUES (9,'WebGUI',8,'Visualizza appunti.',1031510000);
INSERT INTO international VALUES (9,'UserSubmission',8,'Pendente',1031510000);
INSERT INTO international VALUES (9,'SQLReport',8,'Error: The DSN specified is of an improper format.',1031510000);
INSERT INTO international VALUES (9,'Poll',8,'Modifica Sondaggio',1031510000);
INSERT INTO international VALUES (9,'MessageBoard',8,'ID Messaggio:',1031510000);
INSERT INTO international VALUES (9,'LinkList',8,'Sei sicuro di voler cancellare questo link?',1031510000);
INSERT INTO international VALUES (9,'FAQ',8,'Aggiungi una nuova domanda.',1031510000);
INSERT INTO international VALUES (9,'EventsCalendar',8,'finché',1031510000);
INSERT INTO international VALUES (9,'Article',8,'Allegato',1031510000);
INSERT INTO international VALUES (8,'WebGUI',8,'Visualizza pagina non trovata.',1031510000);
INSERT INTO international VALUES (8,'UserSubmission',8,'Respinto',1031510000);
INSERT INTO international VALUES (8,'SQLReport',8,'Modifica SQL Report',1031510000);
INSERT INTO international VALUES (8,'SiteMap',8,'Spaziatura di linea',1031510000);
INSERT INTO international VALUES (8,'Poll',8,'(Aggiungi una risposta per linea. Non più di 20)',1031510000);
INSERT INTO international VALUES (8,'MessageBoard',8,'Data:',1031510000);
INSERT INTO international VALUES (8,'LinkList',8,'URL',1031510000);
INSERT INTO international VALUES (8,'FAQ',8,'Modifica F.A.Q.',1031510000);
INSERT INTO international VALUES (8,'EventsCalendar',8,'Ricorre ogni',1031510000);
INSERT INTO international VALUES (8,'Article',8,'URL del Link',1031510000);
INSERT INTO international VALUES (7,'WebGUI',8,'Gestisci gli utenti.',1031510000);
INSERT INTO international VALUES (7,'SQLReport',8,'Password Database',1031510000);
INSERT INTO international VALUES (7,'UserSubmission',8,'Approvato',1031510000);
INSERT INTO international VALUES (7,'SiteMap',8,'Bullet',1031510000);
INSERT INTO international VALUES (7,'Poll',8,'Risposte',1031510000);
INSERT INTO international VALUES (7,'MessageBoard',8,'Autore:',1031510000);
INSERT INTO international VALUES (7,'FAQ',8,'Sei sicuro di voler cancellare questa domanda?',1031510000);
INSERT INTO international VALUES (7,'Article',8,'Titolo del link',1031510000);
INSERT INTO international VALUES (6,'WebGUI',8,'Gestisci gli stili.',1031510000);
INSERT INTO international VALUES (6,'UserSubmission',8,'Contributi per pagina',1031510000);
INSERT INTO international VALUES (6,'SyndicatedContent',8,'Contenuto Attuale',1031510000);
INSERT INTO international VALUES (6,'SQLReport',8,'Utente Database',1031510000);
INSERT INTO international VALUES (6,'SiteMap',8,'Rientro',1031510000);
INSERT INTO international VALUES (6,'Poll',8,'Domanda',1031510000);
INSERT INTO international VALUES (6,'MessageBoard',8,'Modifica Forum',1031510000);
INSERT INTO international VALUES (6,'LinkList',8,'Lista di Link',1031510000);
INSERT INTO international VALUES (6,'FAQ',8,'Risposta',1031510000);
INSERT INTO international VALUES (6,'ExtraColumn',8,'Modifica Colonna Extra',1031510000);
INSERT INTO international VALUES (701,'WebGUI',8,'Settimana',1031510000);
INSERT INTO international VALUES (6,'Article',8,'Immagine',1031510000);
INSERT INTO international VALUES (5,'WebGUI',8,'Gestisci i gruppi.',1031510000);
INSERT INTO international VALUES (5,'UserSubmission',8,'Il tuo contributo è stato respinto.',1031510000);
INSERT INTO international VALUES (5,'SyndicatedContent',8,'Ultimo preso',1031510000);
INSERT INTO international VALUES (5,'SQLReport',8,'DSN',1031510000);
INSERT INTO international VALUES (5,'SiteMap',8,'Modifica la mappa del sito',1031510000);
INSERT INTO international VALUES (5,'Poll',8,'Larghezza del grafico',1031510000);
INSERT INTO international VALUES (5,'MessageBoard',8,'Modifica Timeout',1031510000);
INSERT INTO international VALUES (5,'LinkList',8,'Continua aggiungendo un link?',1031510000);
INSERT INTO international VALUES (5,'ExtraColumn',8,'StyleSheet Class',1031510000);
INSERT INTO international VALUES (5,'FAQ',8,'Domanda',1031510000);
INSERT INTO international VALUES (5,'Item',8,'Scarica allegato',1031510000);
INSERT INTO international VALUES (700,'WebGUI',8,'Giorno',1031510000);
INSERT INTO international VALUES (4,'WebGUI',8,'Gestisci i settaggi.',1031510000);
INSERT INTO international VALUES (4,'UserSubmission',8,'Il tuo contributo è stato approvato.',1031510000);
INSERT INTO international VALUES (4,'SyndicatedContent',8,'Modifica Contenuto di altri siti',1031510000);
INSERT INTO international VALUES (4,'SQLReport',8,'Query',1031510000);
INSERT INTO international VALUES (4,'SiteMap',8,'Profondità',1031510000);
INSERT INTO international VALUES (4,'Poll',8,'Chi può votare?',1031510000);
INSERT INTO international VALUES (4,'MessageBoard',8,'Messaggi Per Pagina',1031510000);
INSERT INTO international VALUES (4,'LinkList',8,'Bullet',1031510000);
INSERT INTO international VALUES (4,'Item',8,'Item',1031510000);
INSERT INTO international VALUES (4,'ExtraColumn',8,'Larghezza',1031510000);
INSERT INTO international VALUES (4,'EventsCalendar',8,'Accade solo una volta.',1031510000);
INSERT INTO international VALUES (4,'Article',8,'Data di fine',1031510000);
INSERT INTO international VALUES (3,'WebGUI',8,'Incolla dagli appunti...',1031510000);
INSERT INTO international VALUES (3,'UserSubmission',8,'Hai nuovi contenuti degli utenti da approvare.',1031510000);
INSERT INTO international VALUES (3,'SQLReport',8,'Template',1031510000);
INSERT INTO international VALUES (3,'SiteMap',8,'Partire da questo livello?',1031510000);
INSERT INTO international VALUES (3,'Poll',8,'Attivo',1031510000);
INSERT INTO international VALUES (3,'MessageBoard',8,'Chi può postare?',1031510000);
INSERT INTO international VALUES (3,'LinkList',8,'Apri in nuova finestra?',1031510000);
INSERT INTO international VALUES (3,'Item',8,'Cancella allegato',1031510000);
INSERT INTO international VALUES (3,'ExtraColumn',8,'Spaziatore',1031510000);
INSERT INTO international VALUES (3,'Article',8,'Data di inizio',1031510000);
INSERT INTO international VALUES (2,'WebGUI',8,'Pagina',1031510000);
INSERT INTO international VALUES (2,'UserSubmission',8,'Chi può contribuire?',1031510000);
INSERT INTO international VALUES (2,'SyndicatedContent',8,'Contenuto da altri siti',1031510000);
INSERT INTO international VALUES (2,'SiteMap',8,'Mappa del sito',1031510000);
INSERT INTO international VALUES (2,'MessageBoard',8,'Forum',1031510000);
INSERT INTO international VALUES (2,'LinkList',8,'Spaziatura di linea',1031510000);
INSERT INTO international VALUES (2,'Item',8,'Allegato',1031510000);
INSERT INTO international VALUES (2,'FAQ',8,'F.A.Q.',1031510000);
INSERT INTO international VALUES (2,'EventsCalendar',8,'Calendario Eventi',1031510000);
INSERT INTO international VALUES (1,'WebGUI',8,'Aggiungi contenuto...',1031510000);
INSERT INTO international VALUES (1,'UserSubmission',8,'Chi può approvare?',1031510000);
INSERT INTO international VALUES (1,'SyndicatedContent',8,'URL del file RSS',1031510000);
INSERT INTO international VALUES (1,'SQLReport',8,'SQL Report',1031510000);
INSERT INTO international VALUES (1,'Poll',8,'Sondaggio',1031510000);
INSERT INTO international VALUES (1,'LinkList',8,'Indentazione',1031510000);
INSERT INTO international VALUES (1,'Item',8,'URL del link',1031510000);
INSERT INTO international VALUES (1,'FAQ',8,'Continua aggiungendo una domanda?',1031510000);
INSERT INTO international VALUES (1,'ExtraColumn',8,'Colonna Extra',1031510000);
INSERT INTO international VALUES (1,'EventsCalendar',8,'Continua aggiungendo un evento?',1031510000);
INSERT INTO international VALUES (1,'Article',8,'Articolo',1031510000);
INSERT INTO international VALUES (367,'WebGUI',8,'Scade dopo',1031510000);
INSERT INTO international VALUES (493,'WebGUI',8,'Torna al sito.',1031510000);
INSERT INTO international VALUES (495,'WebGUI',8,'Assistente creazione del testo',1031510000);
INSERT INTO international VALUES (496,'WebGUI',8,'Editor da utilizzare',1031510000);
INSERT INTO international VALUES (494,'WebGUI',8,'Real Objects Edit-On Pro',1031510000);
INSERT INTO international VALUES (497,'WebGUI',8,'Data di pubblicazione',1031510000);
INSERT INTO international VALUES (498,'WebGUI',8,'Data di oscuramento',1031510000);
INSERT INTO international VALUES (499,'WebGUI',8,'Wobject ID',1031510000);
INSERT INTO international VALUES (22,'DownloadManager',8,'Continua aggiungendo un download?',1031510000);
INSERT INTO international VALUES (21,'EventsCalendar',8,'Continua aggiungendo un evento?',1031510000);
INSERT INTO international VALUES (20,'EventsCalendar',8,'Aggiungi un evento.',1031510000);
INSERT INTO international VALUES (38,'UserSubmission',8,'(Seleziona \"No\" solo se hai usato l\'assistente per la creazione del testo.)',1031510000);
INSERT INTO international VALUES (500,'WebGUI',8,'ID pagina',1031510000);
INSERT INTO international VALUES (501,'WebGUI',8,'Body',1031510000);
INSERT INTO international VALUES (502,'WebGUI',8,'Sei sicuro di voler cancellare questo template e attribuire a tutte le pagine che lo usano il template di default?',1031510000);
INSERT INTO international VALUES (503,'WebGUI',8,'Template ID',1031510000);
INSERT INTO international VALUES (504,'WebGUI',8,'Template',1031510000);
INSERT INTO international VALUES (505,'WebGUI',8,'Aggiungi un nuovo template.',1031510000);
INSERT INTO international VALUES (506,'WebGUI',8,'Gestisci i Templates',1031510000);
INSERT INTO international VALUES (507,'WebGUI',8,'Modifica Template',1031510000);
INSERT INTO international VALUES (508,'WebGUI',8,'Gestisci templates.',1031510000);
INSERT INTO international VALUES (39,'UserSubmission',8,'Rispondi',1031510000);
INSERT INTO international VALUES (40,'UserSubmission',8,'Inviato da',1031510000);
INSERT INTO international VALUES (41,'UserSubmission',8,'Data',1031510000);
INSERT INTO international VALUES (42,'UserSubmission',8,'Modifica Risposta',1031510000);
INSERT INTO international VALUES (43,'UserSubmission',8,'Cancella Risposta',1031510000);
INSERT INTO international VALUES (45,'UserSubmission',8,'Torna ad invio',1031510000);
INSERT INTO international VALUES (46,'UserSubmission',8,'Leggi di piu\'...',1031510000);
INSERT INTO international VALUES (47,'UserSubmission',8,'Rispondi',1031510000);
INSERT INTO international VALUES (48,'UserSubmission',8,'Consenti Discussioni?',1031510000);
INSERT INTO international VALUES (49,'UserSubmission',8,'Modifica il Timeout',1031510000);
INSERT INTO international VALUES (50,'UserSubmission',8,'Chi può postare',1031510000);
INSERT INTO international VALUES (44,'UserSubmission',8,'Chi può Moderare',1031510000);
INSERT INTO international VALUES (51,'UserSubmission',8,'Visualizza thumbnails?',1031510000);
INSERT INTO international VALUES (52,'UserSubmission',8,'Thumbnail',1031510000);
INSERT INTO international VALUES (53,'UserSubmission',8,'Layout',1031510000);
INSERT INTO international VALUES (54,'UserSubmission',8,'Web Log',1031510000);
INSERT INTO international VALUES (55,'UserSubmission',8,'Tradizionale',1031510000);
INSERT INTO international VALUES (56,'UserSubmission',8,'Photo Gallery',1031510000);
INSERT INTO international VALUES (57,'UserSubmission',8,'Risposte',1031510000);
INSERT INTO international VALUES (11,'FAQ',8,'Attiva elenco domande con link?',1031510000);
INSERT INTO international VALUES (12,'FAQ',8,'Attiva D/R ?',1031510000);
INSERT INTO international VALUES (13,'FAQ',8,'Attiva [top] link?',1031510000);
INSERT INTO international VALUES (14,'FAQ',8,'D',1031510000);
INSERT INTO international VALUES (15,'FAQ',8,'R',1031510000);
INSERT INTO international VALUES (16,'FAQ',8,'[top]',1031510000);
INSERT INTO international VALUES (509,'WebGUI',8,'Layout Discussioni',1031510000);
INSERT INTO international VALUES (510,'WebGUI',8,'Flat',1031510000);
INSERT INTO international VALUES (511,'WebGUI',8,'Threaded',1031510000);
INSERT INTO international VALUES (512,'WebGUI',8,'Prossimo Thread',1031510000);
INSERT INTO international VALUES (513,'WebGUI',8,'Thread Precedente',1031510000);
INSERT INTO international VALUES (514,'WebGUI',8,'Visto',1031510000);
INSERT INTO international VALUES (515,'WebGUI',8,'Aggiungi la data di modifica nei posts?',1031510000);
INSERT INTO international VALUES (517,'WebGUI',8,'Spegni Admin!',1031510000);
INSERT INTO international VALUES (516,'WebGUI',8,'Attiva Admin!',1031510000);
INSERT INTO international VALUES (518,'WebGUI',8,'Inbox Notifiche',1031510000);
INSERT INTO international VALUES (519,'WebGUI',8,'Non voglio ricevere notifiche.',1031510000);
INSERT INTO international VALUES (520,'WebGUI',8,'Voglio ricevere notifiche via email.',1031510000);
INSERT INTO international VALUES (521,'WebGUI',8,'Voglio ricevere notifiche via email al pager.',1031510000);
INSERT INTO international VALUES (522,'WebGUI',8,'Voglio ricevere notifiche via ICQ.',1031510000);
INSERT INTO international VALUES (523,'WebGUI',8,'Notification',1031510000);
INSERT INTO international VALUES (524,'WebGUI',8,'Aggiungi la data di modifica nei post?',1031510000);
INSERT INTO international VALUES (525,'WebGUI',8,'Modifica Settaggi Contenuti',1031510000);
INSERT INTO international VALUES (526,'WebGUI',8,'Filtra solo JavaScript.',1031510000);
INSERT INTO international VALUES (527,'WebGUI',8,'Home Page di default',1031510000);
INSERT INTO international VALUES (354,'WebGUI',8,'Visualizza Inbox.',1031510000);
INSERT INTO international VALUES (528,'WebGUI',8,'Nome Template',1031510000);
INSERT INTO international VALUES (529,'WebGUI',8,'Risultati',1031510000);
INSERT INTO international VALUES (530,'WebGUI',8,'con <b>tutte</b> le parole',1031510000);
INSERT INTO international VALUES (531,'WebGUI',8,'con la <b>frase esatta</b>',1031510000);
INSERT INTO international VALUES (532,'WebGUI',8,'con <b>almeno</b> queste parole',1031510000);
INSERT INTO international VALUES (533,'WebGUI',8,'<b>senza</b> le parole',1031510000);
INSERT INTO international VALUES (535,'WebGUI',8,'Gruppo a cui notificare un nuovo utente',1031510000);
INSERT INTO international VALUES (534,'WebGUI',8,'Notifica quando si iscrive un nuovo utente?',1031510000);
INSERT INTO international VALUES (536,'WebGUI',8,'Il nuovo utente ^@; si è iscritto al sito.',1031510000);
INSERT INTO international VALUES (537,'WebGUI',8,'Karma',1031510000);
INSERT INTO international VALUES (538,'WebGUI',8,'Soglia del Karma',1031510000);
INSERT INTO international VALUES (539,'WebGUI',8,'Abilita Karma?',1031510000);
INSERT INTO international VALUES (540,'WebGUI',8,'Karma Per Login',1031510000);
INSERT INTO international VALUES (20,'Poll',8,'Karma Per Voto',1031510000);
INSERT INTO international VALUES (541,'WebGUI',8,'Karma Per Post',1031510000);
INSERT INTO international VALUES (30,'UserSubmission',8,'Karma Per Contributo',1031510000);
INSERT INTO international VALUES (542,'WebGUI',8,'Precedente..',1031510000);
INSERT INTO international VALUES (543,'WebGUI',8,'Aggiungi un nuovo gruppo',1031510000);
INSERT INTO international VALUES (544,'WebGUI',8,'Sei sicuro di voler cancellare questo gruppo?',1031510000);
INSERT INTO international VALUES (545,'WebGUI',8,'Modifica i Gruppi di Immagini',1031510000);
INSERT INTO international VALUES (546,'WebGUI',8,'Id Gruppo',1031510000);
INSERT INTO international VALUES (547,'WebGUI',8,'Gruppo Genitore',1031510000);
INSERT INTO international VALUES (548,'WebGUI',8,'Nome del Gruppo',1031510000);
INSERT INTO international VALUES (549,'WebGUI',8,'Descrizione del Gruppo',1031510000);
INSERT INTO international VALUES (550,'WebGUI',8,'Visualizza Gruppo di Immagini',1031510000);
INSERT INTO international VALUES (382,'WebGUI',8,'Modifica Immagine',1031510000);
INSERT INTO international VALUES (551,'WebGUI',8,'Avviso',1031510000);
INSERT INTO international VALUES (552,'WebGUI',8,'Pendente',1031510000);
INSERT INTO international VALUES (553,'WebGUI',8,'Stato',1031510000);
INSERT INTO international VALUES (554,'WebGUI',8,'Agisci',1031510000);
INSERT INTO international VALUES (555,'WebGUI',8,'Modifica il karma di questo utente.',1031510000);
INSERT INTO international VALUES (556,'WebGUI',8,'Ammontare',1031510000);
INSERT INTO international VALUES (557,'WebGUI',8,'Descrizione',1031510000);
INSERT INTO international VALUES (558,'WebGUI',8,'Modifica il karma dell\'utente',1031510000);
INSERT INTO international VALUES (61,'DownloadManager',1,'Download Manager, Add/Edit',1031514049);
INSERT INTO international VALUES (61,'Item',1,'Item, Add/Edit',1031514049);
INSERT INTO international VALUES (61,'FAQ',1,'FAQ, Add/Edit',1031514049);
INSERT INTO international VALUES (61,'SyndicatedContent',1,'Syndicated Content, Add/Edit',1031514049);
INSERT INTO international VALUES (61,'EventsCalendar',1,'Events Calendar, Add/Edit',1031514049);
INSERT INTO international VALUES (61,'MessageBoard',1,'Message Board, Add/Edit',1031514049);
INSERT INTO international VALUES (61,'LinkList',1,'Link List, Add/Edit',1031514049);
INSERT INTO international VALUES (61,'Article',1,'Article, Add/Edit',1031514049);
INSERT INTO international VALUES (61,'ExtraColumn',1,'Extra Column, Add/Edit',1031514049);
INSERT INTO international VALUES (61,'Poll',1,'Poll, Add/Edit',1031514049);
INSERT INTO international VALUES (61,'SiteMap',1,'Site Map, Add/Edit',1031514049);
INSERT INTO international VALUES (61,'SQLReport',1,'SQL Report, Add/Edit',1031514049);
INSERT INTO international VALUES (61,'MailForm',1,'Mail Form, Add/Edit',1031514049);
INSERT INTO international VALUES (62,'MailForm',1,'Mail Form Fields, Add/Edit',1031514049);
INSERT INTO international VALUES (71,'DownloadManager',1,'The Download Manager is designed to help you manage file distribution on your site. It allows you to specify who may download files from your site.\r\n<p>\r\n\r\n<b>Paginate After</b><br>\r\nHow many files should be displayed before splitting the results into separate pages? In other words, how many files should be displayed per page?\r\n<p>\r\n\r\n<b>Display thumbnails?</b><br>\r\nCheck this if you want to display thumbnails for any images that are uploaded. Note that the thumbnail is only displayed for the main attachment, not the alternate versions.\r\n<p>\r\n\r\n<b>Proceed to add download?</b><br>\r\nIf you wish to start adding files to download right away, leave this checked.\r\n<p>\r\n\r\n',1031514049);
INSERT INTO international VALUES (71,'Item',1,'Like Articles, Items are the Swiss Army knife of WebGUI. Most pieces of static content can be added via the Item, though Items are usually used for smaller content than Articles.\r\n<br><br>\r\n\r\n<b>Link URL</b><br>\r\nThis URL will be attached to the title of this Item.\r\n<br><br>\r\n<i>Example:</i> http://www.google.com\r\n<br><br>\r\n\r\n<b>Attachment</b><br>\r\nIf you wish to attach a word processor file, a zip file, or any other file for download by your users, then choose it from your hard drive.\r\n\r\n',1031514049);
INSERT INTO international VALUES (71,'FAQ',1,'It seems that almost every web site, intranet, and extranet in the world has a Frequently Asked Questions area. This wobject helps you build one, too.\r\n<br><br>\r\n\r\n<b>Turn TOC on?</b><br>\r\nDo you wish to display a TOC (or Table of Contents) for this FAQ? A TOC is a list of links (questions) at the top of the FAQ that link down the answers.\r\n<p>\r\n\r\n<b>Turn Q/A on?</b><br>\r\nSome people wish to display a <b>Q:</b> in front of each question and an <b>A:</b> in front of each answer. This switch enables that.\r\n<p>\r\n\r\n<b>Turn [top] link on?</b><br>\r\nDo you wish to display a link after each answer that takes you back to the top of the page?\r\n<p>\r\n\r\n<b>Proceed to add question?</b><br>\r\nLeave this checked if you want to add questions to the FAQ directly after creating it.\r\n<br><br>\r\n\r\n<hr size=\"1\">\r\n<i><b>Note:</b></i> The following style is specific to the FAQ.\r\n<br><br>\r\n<b>.faqQuestion</b><br>\r\nAn F.A.Q. question. To distinguish it from an answer.\r\n\r\n',1031514049);
INSERT INTO international VALUES (71,'SyndicatedContent',1,'Syndicated content is content that is pulled from another site using the RDF/RSS specification. This technology is often used to pull headlines from various news sites like <a href=\"http://www.cnn.com/\">CNN</a> and  <a href=\"http://slashdot.org/\">Slashdot</a>. It can, of course, be used for other things like sports scores, stock market info, etc.\r\n<br><br>\r\n\r\n<b>URL to RSS file</b><br>\r\nProvide the exact URL (starting with http://) to the syndicated content\'s RDF or RSS file. The syndicated content will be downloaded from this URL hourly.\r\n<br><br>\r\nYou can find syndicated content at the following locations:\r\n</p><ul>\r\n<li><a href=\"http://www.newsisfree.com/\">http://www.newsisfree.com</a>\r\n</li><li><a href=\"http://www.syndic8.com/\">http://www.syndic8.com</a>\r\n</li><li><a href=\"http://www.voidstar.com/node.php?id=144\">http://www.voidstar.com/node.php?id=144</a>\r\n</li><li><a href=\"http://my.userland.com/\">http://my.userland.com</a>\r\n</li><li><a href=\"http://www.webreference.com/services/news/\">http://www.webreference.com/services/news/</a>\r\n</li><li><a href=\"http://www.xmltree.com/\">http://www.xmltree.com</a>\r\n</li><li><a href=\"http://w.moreover.com/\">http://w.moreover.com/</a>\r\n</li></ul>',1031514049);
INSERT INTO international VALUES (71,'EventsCalendar',1,'Events calendars are used on many intranets to keep track of internal dates that affect a whole organization. Also, Events Calendars on consumer sites are a great way to let your customers know what events you\'ll be attending and what promotions you\'ll be having.\r\n<br><br>\r\n\r\n<b>Display Layout</b><br>\r\nThis can be set to <i>List</i> or <i>Calendar</i>. When set to <i>List</i> the events will be listed by date of occurence (and events that have already passed will not be displayed). This type of layout is best suited for Events Calendars that have only a few events per month. When set to <i>Calendar</i> the Events Calendar will display a traditional monthly Calendar, which can be paged through month-by-month. This type of layout is generally used when there are many events in each month.\r\n<br><br>\r\n\r\n<b>Paginate After</b><br>\r\nWhen using the list layout, how many events should be shown per page?\r\n<br><br>\r\n<b>Proceed to add event?</b><br>\r\nLeave this set to yes if you want to add events to the Events Calendar directly after creating it.\r\n<br><br>\r\n\r\n<i>Note:</i> Events that have already happened will not be displayed on the events calendar.\r\n<br><br>\r\n<hr size=\"1\">\r\n<i><b>Note:</b></i> The following style is specific to the Events Calendar.\r\n<br><br>\r\n<b>.eventTitle </b><br>\r\nThe title of an individual event.\r\n\r\n',1031514049);
INSERT INTO international VALUES (71,'MessageBoard',1,'Message boards, also called Forums and/or Discussions, are a great way to add community to any site or intranet. Many companies use message boards internally to collaborate on projects.\r\n<br><br>\r\n\r\n<b>Messages Per Page</b><br>\r\nWhen a visitor first comes to a message board s/he will be presented with a listing of all the topics (a.k.a. threads) of the Message Board. If a board is popular, it will quickly have many topics. The Messages Per Page attribute allows you to specify how many topics should be shown on one page.\r\n<p>\r\n\r\n<b>Who can post?</b><br>\r\nSelect the group that is allowed to post to this discussion.\r\n<p>\r\n\r\n<b>Edit Timeout</b><br>\r\nHow long should a user be able to edit their post before editing is locked to them?\r\n<p>\r\n<i>Note:</i> Don\'t set this limit too high. One of the great things about discussions is that they are an accurate record of who said what. If you allow editing for a long time, then a user has a chance to go back and change his/her mind a long time after the original statement was made.\r\n<p>\r\n\r\n<b>Karma Per Post</b><br>\r\nHow much karma should be given to a user when they post to this discussion?\r\n<p>\r\n\r\n<b>Who can moderate?</b><br>\r\nSelect the group that is allowed to moderate this discussion.\r\n<p>\r\n\r\n<b>Moderation Type?</b><br>\r\nYou can select what type of moderation you\'d like for your users. <i>After-the-fact</i> means that when a user posts a message it is displayed publically right away. <i>Pre-emptive</i> means that a moderator must preview and approve users posts before allowing them to be publically visible. Alerts for new posts will automatically show up in the moderator\'s WebGUI Inbox.\r\n<p>\r\nNote: In both types of moderation the moderator can always edit or delete the messages posted by your users.\r\n<p>\r\n',1031514049);
INSERT INTO international VALUES (71,'LinkList',1,'Link Lists are just what they sound like, a list of links. Many sites have a links section, and this wobject just automates the process.\r\n<br><br>\r\n\r\n<b>Indent</b><br>\r\nHow many characters should indent each link?\r\n<p>\r\n\r\n<b>Line Spacing</b><br>\r\nHow many carriage returns should be placed between each link?\r\n<p>\r\n\r\n\r\n<b>Bullet</b><br>\r\nSpecify what bullet should be used before each line item. You can leave this blank if you want to. You can also specify HTML bullets like · and ». You can even use images from the image manager by specifying a macro like this ^I(bullet);.\r\n<p>\r\n\r\n\r\n<b>Proceed to add link?</b><br>\r\nLeave this set to yes if you want to add links to the Link List directly after creating it.\r\n<br><br>\r\n\r\n<b>Style</b><br>\r\nAn extra StyleSheet class has been added to this wobject: <b>.linkTitle</b>.  Use this to bold, colorize, or otheriwise manipulate the title of each link.\r\n</p><p>',1031514049);
INSERT INTO international VALUES (71,'Article',1,'Articles are the Swiss Army knife of WebGUI. Most pieces of static content can be added via the Article.\r\n<br><br>\r\n<b>Image</b><br>\r\nChoose an image (.jpg, .gif, .png) file from your hard drive. This file will be uploaded to the server and displayed in your article.\r\n<br><br>\r\n\r\n<b>Align Image</b><br>\r\nChoose where you\'d like to position the image specified above.\r\n</p><p>\r\n\r\n<b>Attachment</b><br>\r\nIf you wish to attach a word processor file, a zip file, or any other file for download by your users, then choose it from your hard drive.\r\n<br><br>\r\n\r\n<b>Link Title</b><br>\r\nIf you wish to add a link to your article, enter the title of the link in this field. \r\n<br><br>\r\n<i>Example:</i> Google\r\n<br><br>\r\n\r\n<b>Link URL</b><br>\r\nIf you added a link title, now add the URL (uniform resource locator) here. \r\n<br><br>\r\n<i>Example:</i> http://www.google.com\r\n\r\n<br><br>\r\n\r\n<b>Convert carriage returns?</b><br>\r\nIf you\'re publishing HTML there\'s generally no need to check this option, but if you aren\'t using HTML and you want a carriage return every place you hit your \"Enter\" key, then check this option.\r\n<p>\r\n\r\n<b>Allow discussion?</b><br>\r\nChecking this box will enable responses to your article much like Articles on Slashdot.org.\r\n<p>\r\n\r\n<b>Who can post?</b><br>\r\nSelect the group that is allowed to post to this discussion.\r\n<p>\r\n\r\n<b>Edit Timeout</b><br>\r\nHow long should a user be able to edit their post before editing is locked to them?\r\n<p>\r\n<i>Note:</i> Don\'t set this limit too high. One of the great things about discussions is that they are an accurate record of who said what. If you allow editing for a long time, then a user has a chance to go back and change his/her mind a long time after the original statement was made.\r\n<p>\r\n\r\n<b>Karma Per Post</b><br>\r\nHow much karma should be given to a user when they post to this discussion?\r\n<p>\r\n\r\n<b>Who can moderate?</b><br>\r\nSelect the group that is allowed to moderate this discussion.\r\n<p>\r\n\r\n<b>Moderation Type?</b><br>\r\nYou can select what type of moderation you\'d like for your users. <i>After-the-fact</i> means that when a user posts a message it is displayed publically right away. <i>Pre-emptive</i> means that a moderator must preview and approve users posts before allowing them to be publically visible. Alerts for new posts will automatically show up in the moderator\'s WebGUI Inbox.\r\n<p>\r\nNote: In both types of moderation the moderator can always edit or delete the messages posted by your users.\r\n<p>\r\n',1031514049);
INSERT INTO international VALUES (71,'ExtraColumn',1,'Extra columns allow you to change the layout of your page for one page only. If you wish to have multiple columns on all your pages, perhaps you should consider altering the <i>style</i> applied to your pages or use a Template instead of an Extra Column. \r\n<br><br>\r\nColumns are always added from left to right. Therefore any existing content will be on the left of the new column.\r\n<br><br>\r\n<b>Spacer</b><br>\r\nSpacer is the amount of space between your existing content and your new column. It is measured in pixels.\r\n<br><br>\r\n<b>Width</b><br>\r\nWidth is the actual width of the new column to be added. Width is measured in pixels.\r\n<br><br>\r\n<b>StyleSheet Class</b><br>\r\nBy default the <i>content</i> style (which is the style the body of your site should be using) that is applied to all columns. However, if you\'ve created a style specifically for columns, then feel free to modify this class.\r\n',1031514049);
INSERT INTO international VALUES (71,'Poll',1,'Polls can be used to get the impressions of your users on various topics.\r\n<br><br>\r\n<b>Active</b><br>\r\nIf this box is checked, then users will be able to vote. Otherwise they\'ll only be able to see the results of the poll.\r\n<br><br>\r\n\r\n<b>Who can vote?</b><br>\r\nChoose a group that can vote on this Poll.\r\n<br><br>\r\n\r\n<b>Karma Per Vote</b><br>\r\nHow much karma should be given to a user when they vote?\r\n<p>\r\n\r\n<b>Graph Width</b><br>\r\nThe width of the poll results graph. The width is measured in pixels.\r\n<br><br>\r\n\r\n<b>Question</b><br>\r\nWhat is the question you\'d like to ask your users?\r\n<br><br>\r\n\r\n<b>Answers</b><br>\r\nEnter the possible answers to your question. Enter only one answer per line. Polls are only capable of 20 possible answers.\r\n<br><br>\r\n\r\n<b>Randomize answers?</b><br>\r\nIn order to be sure that the ordering of the answers in the poll does not bias your users, it is often helpful to present the options in a random order each time they are shown. Select \"yes\" to randomize the answers on the poll.\r\n<p>\r\n\r\n<b>Reset votes.</b><br>\r\nReset the votes on this Poll.\r\n<br><br>\r\n\r\n<hr size=\"1\">\r\n<i><b>Note:</b></i> The following style sheet entries are custom to the Poll wobject:\r\n<br><br>\r\n\r\n<b>.pollAnswer </b><br>\r\nAn answer on a poll.\r\n<p>\r\n\r\n<b>.pollColor </b>\r\nThe color of the percentage bar on a poll.\r\n<p>\r\n\r\n<b>.pollQuestion </b>\r\nThe question on a poll.\r\n\r\n',1031514049);
INSERT INTO international VALUES (71,'SiteMap',1,'Site maps are used to provide additional navigation in WebGUI. You could set up a traditional site map that would display a hierarchical view of all the pages in the site. On the other hand, you could use site maps to provide extra navigation at certain levels in your site.\r\n<br><br>\r\n\r\n<b>Display synopsis?</b><br>\r\nDo you wish to display page sysnopsis along-side the links to each page? Note that in order for this option to be valid, pages must have synopsis defined.\r\n<br><br>\r\n\r\n<b>Starting from this level?</b><br>\r\nIf the Site Map should display the page tree starting from this level, then check this box. If you wish the Site Map to start from the home page then uncheck it.\r\n<br><br>\r\n\r\n<b>Depth To Traverse</b><br>\r\nHow many levels deep of navigation should the Site Map show? If 0 (zero) is specified, it will show as many levels as there are.\r\n<p>\r\n\r\n<b>Indent\r\nHow many characters should indent each level?\r\n</b></p><p><b>\r\n\r\n<b>Bullet</b><br>\r\nSpecify what bullet should be used before each line item. You can leave this blank if you want to. You can also specify HTML bullets like &middot; and &raquo;. You can even use images from the image manager by specifying a macro like this ^I(bullet);.\r\n</b></p><p><b>\r\n\r\n<b>Line Spacing</b><br>\r\nSpecify how many carriage returns should go between each item in the Site Map. This should be set to 1 or higher.\r\n</b></p><p><b>',1031514049);
INSERT INTO international VALUES (71,'SQLReport',1,'SQL Reports are perhaps the most powerful wobject in the WebGUI arsenal. They allow a user to query data from any database that they have access to. This is great for getting sales figures from your Accounting database or even summarizing all the message boards on your web site.\r\n<p>\r\n\r\n\r\n<b>Preprocess macros on query?</b><br>\r\nIf you\'re using WebGUI macros in your query you\'ll want to check this box.\r\n<p>\r\n\r\n\r\n<b>Debug?</b><br>\r\nIf you want to display debugging and error messages on the page, check this box.\r\n<p>\r\n\r\n\r\n<b>Query</b><br>\r\nThis is a standard SQL query. If you are unfamiliar with SQL, <a href=\"http://www.plainblack.com/\">Plain Black Software</a> provides training courses in SQL and database management. You can make your queries more dynamic by using the ^FormParam(); macro.\r\n<p>\r\n\r\n\r\n<b>Report Template</b><br>\r\nLayout a template of how this report should look. Usually you\'ll use HTML tables to generate a report. An example is included below. If you leave this field blank a template will be generated based on your result set.\r\n<p>\r\n\r\n\r\nThere are special macro characters used in generating SQL Reports. They are ^-;, ^0;, ^1;, ^2;, ^3;, etc. These macros will be processed regardless of whether you checked the process macros box above. The ^- macro represents split points in the document where the report will begin and end looping. The numeric macros represent the data fields that will be returned from your query. There is an additional macro, ^rownum; that counts the rows of the query starting at 1 for use where the lines of the output need to be numbered.\r\n<p>\r\n\r\n\r\n<b>DSN</b><br>\r\n<b>D</b>ata <b>S</b>ource <b>N</b>ame is the unique identifier that Perl uses to describe the location of your database. It takes the format of DBI:[driver]:[database name]:[host]. \r\n<p>\r\n\r\n\r\n<i>Example:</i> DBI:mysql:WebGUI:localhost\r\n<p>\r\n\r\n\r\n<b>Database User</b>\r\nThe username you use to connect to the DSN.\r\n<p>\r\n\r\n\r\n<b>Database Password</b>\r\nThe password you use to connect to the DSN.\r\n<p>\r\n\r\n\r\n<b>Paginate After</b>\r\nHow many rows should be displayed before splitting the results into separate pages? In other words, how many rows should be displayed per page?\r\n<p>\r\n\r\n\r\n<b>Convert carriage returns?</b>\r\nDo you wish to convert the carriage returns in the resultant data to HTML breaks (<br>).\r\n<p>\r\n\r\n',1031514049);
INSERT INTO international VALUES (71,'MailForm',1,'This wobject creates a simple form that will email an email address when it is filled out.\r\n<br><br>\r\n\r\n<b>Width</b><br>\r\nThe width of all fields in the form.  The default value is 45.\r\n<p>\r\n\r\n<b>From, To, Cc, Bcc, Subject</b><br>\r\nThese fields control how the email will look when sent, and who it is sent to.  You can give your site visitors the ability to modify some or all of these fields, but typically the only fields you will want the user to be able to modify are From and Subject.  Use the drop-down options by each field to choose whether or not the user can see or modify that field.<br>\r\n<br>\r\nYou may also choose to enter a WebGUI username or group in the To field, and the email will be sent to the corresponding user or group.\r\n<p>\r\n\r\n<b>Acknowledgement</b><br>\r\nThis message will be displayed to the user after they click \"Send\".\r\n<p>\r\n\r\n<b>Store Entries?</b><br>\r\nIf set to yes, when your mail form is submitted the entries will be saved to the database for later viewing.  The tool to view these entries is not yet available, but when it is you will be able to view all entries from your form in a centralized location.\r\n<p>\r\n\r\n<b>Proceed to add more fields?</b><br>\r\nLeave this checked if you want to add additional fields to your form directly after creating it.',1031514049);
INSERT INTO international VALUES (72,'MailForm',1,'You may add as many additional fields to your Mail Form as you like.\r\n<br><br>\r\n\r\n<b>Field Name</b><br>\r\nThe name of this field.  It must be unique among all of the other fields on your form.\r\n<p>\r\n\r\n<b>Status</b><br>\r\nHidden fields will not be visible to the user, but will be sent in the email.<br>\r\nDisplayed fields can be seen by the user but not modified.<br>\r\nModifiable fields can be filled in by the user.<br>\r\nIf you choose Hidden or Displayed, be sure to fill in a Default Value.\r\n<p>\r\n\r\n<b>Type</b><br>\r\nChoose the type of form element for this field.  The following field types are supported:<br>\r\nURL: A textbox that will auto-format URL\'s entered.<br>\r\nTextbox: A standard textbox.<br>\r\nDate: A textbox field with a popup window to select a date.<br>\r\nYes/No: A set of yes/no radio buttons.<br>\r\nEmail Address: A textbox that requires the user to enter a valid email address.<br>\r\nTextarea: A simple textarea.<br>\r\nCheckbox: A single checkbox.<br>\r\nDrop-Down Box: A drop-down box. Use the Possible Values field to enter each option to be displayed in the box.  Enter one option per line.\r\n<p>\r\n\r\n<b>Possible Values</b><br>\r\nThis field is only used for the Drop-Down Box type.  Enter the values you wish to appear in your drop-down box, one per line.\r\n<p>\r\n\r\n<b>Default Value (optional)</b><br>\r\nEnter the default value (if any) for the field.  For Yes/No fields, enter \"yes\" to select \"Yes\" and \"no\" to select \"No\".\r\nFor Checkbox fields, enter \"checked\" to check the box.\r\n<p>\r\n\r\n<b>Proceed to add more fields?</b><br>\r\nLeave this checked if you want to add additional fields to your form directly after creating this field.\r\n<p>\r\n',1031514049);
INSERT INTO international VALUES (625,'WebGUI',1,'<b>Name</b><br>\r\nThe label that this image will be referenced by to include it into pages.\r\n<p>\r\n\r\n<b>File</b><br>\r\nSelect a file from your local drive to upload to the server.\r\n<p>\r\n\r\n<b>Parameters</b><br>\r\nAdd any HTML &ltimg&rt; parameters that you wish to act as the defaults for this image.\r\n<p>\r\n\r\n<i>Example:</i><br>\r\nalign=\"right\"<br>\r\nalt=\"This is an image\"<br>\r\n',1031514049);
INSERT INTO international VALUES (628,'WebGUI',1,'When you delete an image it will be removed from the server and cannot be recovered. Therefore, be sure that you really wish to delete the image before you confirm the delete.\r\n<p>\r\n',1031514049);
INSERT INTO international VALUES (631,'WebGUI',1,'Using the built in image manager in WebGUI you can upload images to one central location for use anywhere else in the site with no need for any special software or knowledge.\r\nYou can also create image groups to help organize your images. To do so, simply click \"Add a new group.\"\r\n<p>\r\n\r\nTo place the images you\'ve uploaded use the ^I(); and ^i(); macros. More information on them can be found in the Using Macros help.\r\n\r\n<p>\r\n<i>Tip:</i> You can use the ^I(); macro (and therefore the images from the image manager) in places you may not have conisdered. For instance, you could place images in the titles of your wobjects. Or in wobjects like Link List and Site Map that use bullets, you could use image manager images as the bullets.\r\n<p>\r\n',1031514049);
INSERT INTO international VALUES (633,'WebGUI',1,'Simply put, roots are pages with no parent. The first and most important root in WebGUI is the \"Home\" page. Many people will never add any additional roots, but a few power users will. Those power users will create new roots for many different reasons. Perhaps they\'ll create a staging area for content managers. Or maybe a hidden area for Admin tools. Or possibly even a new root just to place their search engine.\r\n<p>\r\n\r\n',1031514049);
INSERT INTO international VALUES (636,'WebGUI',1,'To create a package follow these simple steps:\r\n\r\n<ol>\r\n<li> From the admin menu select \"Manage packages.\"\r\n</li>\r\n\r\n<li> Add a page and give it a name. The name of the page will be the name of the package.\r\n</li>\r\n\r\n<li> Go to the new page you created and start adding pages and wobjects. Any pages or wobjects you add will be created each time this package is deployed. \r\n</li>\r\n</ol>\r\n\r\n<b>Notes:</b><br>\r\nIn order to add, edit, or delete packages you must be in the Package Mangers group or in the Admins group.\r\n<br><br>\r\n\r\nIf you add content to any of the wobjects, that content will automatically be copied when the package is deployed.\r\n<br><br>\r\n\r\nPrivileges and styles assigned to pages in the package will not be copied when the package is deployed. Instead the pages will take the privileges and styles of the area to which they are deployed.\r\n<p>\r\n',1031514049);
INSERT INTO international VALUES (635,'WebGUI',1,'Packages are groups of pages and wobjects that are predefined to be deployed together. A package manager may see the need to create a package several pages with a message board, an FAQ, and a Poll because that task is performed quite often. Packages are often defined to lessen the burden of repetitive tasks.\r\n<br><br>\r\nOne package that many people create is a Page/Article package. It is often the case that you want to add a page with an article on it for content. Instead of going through the steps of creating a page, going to the page, and then adding an article to the page, you may wish to simply create a package to do those steps all at once.',1031514049);
INSERT INTO international VALUES (630,'WebGUI',1,'WebGUI has a small, but sturdy real-time search engine built-in. If you wish to use the internal search engine, you can use the ^?; macro, or by adding <i>?op=search</i> to the end of any URL, or feel free to build your own form to access it.\r\n<p>\r\nMany people need a search engine to index their WebGUI site, plus many others. Or they have more advanced needs than what WebGUI\'s search engine allows. In those cases we recommend <a href=\"http://www.mnogosearch.org/\">MnoGo Search</a> or <a href=\"http://www.htdig.org/\">ht://Dig</a>.\r\n<p>\r\n\r\n',1031514049);
INSERT INTO international VALUES (611,'WebGUI',1,'<b>Company Name</b><br>\r\nThe name of your company. It will appear on all emails and anywhere you use the Company Name macro.\r\n<br><br>\r\n\r\n<b>Company Email Address</b><br>\r\nA general email address at your company. This is the address that all automated messages will come from. It can also be used via the WebGUI macro system.\r\n<br><br>\r\n\r\n<b>Company URL</b><br>\r\nThe primary URL of your company. This will appear on all automated emails sent from the WebGUI system. It is also available via the WebGUI macro system.\r\n',1031514049);
INSERT INTO international VALUES (651,'WebGUI',1,'If you choose to empty your trash, any items contained in it will be lost forever. If you\'re unsure about a few items, it might be best to cut them to your clipboard before you empty the trash.\r\n<p>\r\n\r\n',1031514049);
INSERT INTO international VALUES (627,'WebGUI',1,'Profiles are used to extend the information of a particular user. In some cases profiles are important to a site, in others they are not. The profiles system is completely extensible. You can add as much information to the users profile as you like.\r\n<p>\r\n\r\n',1031514049);
INSERT INTO international VALUES (629,'WebGUI',1,'<b>Prevent Proxy Caching</b><br>\r\nSome companies have proxy servers that cause problems with WebGUI. If you\'re experiencing problems with WebGUI, and you have a proxy server, you may want to set this setting to <i>Yes</i>. Beware that WebGUI\'s URLs will not be as user-friendly after this feature is turned on.\r\n<p>\r\n\r\n<b>On Critical Error</b><br>\r\nWhat do you want WebGUI to do if a critical error occurs. It can be a security risk to show debugging information, but you may want to show it if you are in development.\r\n<p>\r\n\r\n',1031514049);
INSERT INTO international VALUES (616,'WebGUI',1,'<b>Path to WebGUI Extras</b><br>\r\nThe web-path to the directory containing WebGUI images and javascript files.\r\n<br><br>\r\n\r\n<b>Maximum Attachment Size</b><br>\r\nThe maximum size of files allowed to be uploaded to this site. This applies to all wobjects that allow uploaded files and images (like Article and User Contributions). This size is measured in kilobytes.\r\n<br><br>\r\n\r\n<b>Thumbnail Size</b><br>\r\nThe size of the longest side of thumbnails. The thumbnail generation maintains the aspect ratio of the image. Therefore, if this value is set to 100, and you have an image that\'s 400 pixels wide and 200 pixels tall, the thumbnail will be 100 pixels wide and 50 pixels tall.\r\n<p>\r\n<i>Note:</i> Thumbnails are automatically generated as images are uploaded to the system.\r\n<p>\r\n\r\n<b>Web Attachment Path</b><br>\r\nThe web-path of the directory where attachments are to be stored.\r\n<br><br>\r\n\r\n<b>Server Attachment Path</b><br>\r\nThe local path of the directory where attachments are to be stored. (Perhaps /var/www/public/uploads) Be sure that the web server has the rights to write to that directory.\r\n',1031514049);
INSERT INTO international VALUES (618,'WebGUI',1,'<b>Recover Password Message</b><br>\r\nThe message that gets sent to a user when they use the \"recover password\" function.\r\n<br><br>\r\n\r\n<b>SMTP Server</b><br>\r\nThis is the address of your local mail server. It is needed for all features that use the Internet email system (such as password recovery).\r\n<p>\r\nOptionally, if you are running a sendmail server on the same machine as WebGUI, you can also specify a path to your sendmail executable. On most Linux systems this can be found at \"/usr/lib/sendmail\".\r\n\r\n',1031514049);
INSERT INTO international VALUES (626,'WebGUI',1,'Wobjects (fomerly known as Widgets) are the true power of WebGUI. Wobjects are tiny pluggable applications built to run under WebGUI. Message boards and polls are examples of wobjects.\r\n<p>\r\n\r\nTo add a wobject to a page, first go to that page, then select <i>Add Content...</i> from the upper left corner of your screen. Each wobject has it\'s own help so be sure to read the help if you\'re not sure how to use it.\r\n<p>\r\n\r\n\r\n<i>Style Sheets</i>: All wobjects have a style-sheet class and id attached to them. \r\n<p>\r\n\r\nThe style-sheet class is the word \"wobject\" plus the type of wobject it is. So for a poll the class would be \"wobjectPoll\". The class pertains to all wobjects of that type in the system. \r\n<p>\r\n\r\nThe style-sheet id is the word \"wobjectId\" plus the Wobject Id for that wobject instance. So if you had an Article with a Wobject Id of 94, then the id would be \"wobjectId94\".\r\n<p>\r\n\r\n',1031514049);
INSERT INTO international VALUES (632,'WebGUI',1,'You can add wobjects by selecting from the <i>Add Content</i> pulldown menu. You can edit them by clicking on the \"Edit\" button that appears directly above an instance of a particular wobject.\r\n<p>\r\n\r\nAlmost all wobjects share some properties. Those properties are:\r\n<p>\r\n\r\n<b>Wobject ID</b><br>\r\nThis is the unique identifier WebGUI uses to keep track of this wobject instance. Normal users should never need to be concerned with the Wobject ID, but some advanced users may need to know it for things like SQL Reports.\r\n<p>\r\n\r\n\r\n<b>Title</b>\r\nThe title of the wobject. This is typically displayed at the top of each wobject.\r\n<p>\r\n\r\n<i>Note:</i> You should always specify a title even if you are going to turn it off (with the next property). This is because the title shows up in the trash and clipboard and you\'ll want to be able to distinguish which wobject is which.\r\n<p>\r\n\r\n\r\n<b>Display title?</b><br>\r\nDo you wish to display the title you specified? On some sites, displaying the title is not necessary.\r\n<p>\r\n\r\n\r\n<b>Process macros?</b><br>\r\nDo you wish to process macros in the content of this wobject? Sometimes you\'ll want to do this, but more often than not you\'ll want to say \"no\" to this question. By disabling the processing of macros on the wobjects that don\'t use them, you\'ll speed up your web server slightly.\r\n<p>\r\n\r\n\r\n<b>Template Position</b><br>\r\nTemplate positions range from 0 (zero) to any number. How many are available depends upon the Template associated with this page. The default template has only one template position, others may have more. By selecting a template position, you\'re specifying where this wobject should be placed within the template.\r\n<p>\r\n\r\n\r\n<b>Start Date</b><br>\r\nOn what date should this wobject become visible? Before this date, the wobject will only be displayed to Content Managers.\r\n<p>\r\n\r\n\r\n<b>End Date</b><br>\r\nOn what date should this wobject become invisible? After this date, the wobject will only be displayed to Content Managers.\r\n<p>\r\n\r\n\r\n<b>Description</b><br>\r\nA content area in which you can place as much content as you wish. For instance, even before an FAQ there is usually a paragraph describing what is contained in the FAQ.\r\n<p>\r\n\r\n',1031514049);
INSERT INTO international VALUES (623,'WebGUI',1,'<a href=\"http://www.w3.org/Style/CSS/\">Cascading Style Sheets (CSS)</a> are a great way to manage the look and feel of any web site. They are used extensively in WebGUI.\r\n<p>\r\n\r\n\r\nIf you are unfamiliar with how to use CSS, <a href=\"http://www.plainblack.com/\">Plain Black Software</a> provides training classes on XHTML and CSS. Alternatively, Bradsoft makes an excellent CSS editor called <a href=\"http://www.bradsoft.com/topstyle/index.asp\">Top Style</a>.\r\n<p>\r\n\r\n\r\nThe following is a list of classes used to control the look of WebGUI:\r\n<p>\r\n\r\n\r\n<b>A</b><br>\r\nThe links throughout the style.\r\n<p>\r\n\r\n\r\n<b>BODY</b><br>\r\nThe default setup of all pages within a style.\r\n<p>\r\n\r\n\r\n<b>H1</b><br>\r\nThe headers on every page.\r\n<p>\r\n\r\n\r\n<b>.accountOptions</b><br>\r\nThe links that appear under the login and account update forms.\r\n<p>\r\n\r\n\r\n<b>.adminBar </b><br>\r\nThe bar that appears at the top of the page when you\'re in admin mode.\r\n<p>\r\n\r\n\r\n<b>.content</b><br>\r\nThe main content area on all pages of the style.\r\n<p>\r\n\r\n\r\n<b>.formDescription </b><br>\r\nThe tags on all forms next to the form elements. \r\n<p>\r\n\r\n\r\n<b>.formSubtext </b><br>\r\nThe tags below some form elements.\r\n<p>\r\n\r\n\r\n<b>.highlight </b><br>\r\nDenotes a highlighted item, such as which message you are viewing within a list.\r\n<p>\r\n\r\n\r\n<b>.horizontalMenu </b><br>\r\nThe horizontal menu (if you use a horizontal menu macro).\r\n<p>\r\n\r\n\r\n<b>.pagination </b><br>\r\nThe Previous and Next links on pages with pagination.\r\n<p>\r\n\r\n\r\n<b>.selectedMenuItem</b><br>\r\nUse this class to highlight the current page in any of the menu macros.\r\n<p>\r\n\r\n\r\n<b>.tableData </b><br>\r\nThe data rows on things like message boards and user contributions.\r\n<p>\r\n\r\n\r\n<b>.tableHeader </b><br>\r\nThe headings of columns on things like message boards and user contributions.\r\n<p>\r\n\r\n\r\n<b>.tableMenu </b><br>\r\nThe menu on things like message boards and user submissions.\r\n<p>\r\n\r\n\r\n<b>.verticalMenu </b><br>\r\nThe vertical menu (if you use a vertical menu macro).\r\n<p>\r\n\r\n\r\n<i><b>Note:</b></i> Some wobjects and macros have their own unique styles sheet classes, which are documented in their individual help files.\r\n<p>\r\n\r\n\r\n',1031514049);
INSERT INTO international VALUES (622,'WebGUI',1,'See <i>Manage Group</i> for a description of grouping functions and the default groups.\r\n<p>\r\n\r\n<b>Group Name</b><br>\r\nA name for the group. It is best if the name is descriptive so you know what it is at a glance.\r\n<p>\r\n\r\n<b>Description</b><br>\r\nA longer description of the group so that other admins and content managers (or you if you forget) will know what the purpose of this group is.\r\n<p>\r\n\r\n<b>Expire After</b><br>\r\nThe amount of time that a user will belong to this group before s/he is expired (or removed) from it. This is very useful for membership sites where users have certain privileges for a specific period of time. Note that this can be overridden on a per-user basis.\r\n<p>\r\n\r\n<b>Karma Threshold</b><br>\r\nIf you\'ve enabled Karma, then you\'ll be able to set this value. Karma Threshold is the amount of karma a user must have to be considered part of this group.\r\n<p>\r\n',1031514049);
INSERT INTO international VALUES (607,'WebGUI',1,'<b>Anonymous Registration</b><br>\r\nDo you wish visitors to your site to be able to register themselves?\r\n<br><br>\r\n\r\n<b>Run On Registration</b><br>\r\nIf there is a command line specified here, it will be executed each time a user registers anonymously.\r\n<p>\r\n\r\n<b>Alert on new user?</b><br>\r\nShould someone be alerted when a new user registers anonymously?\r\n<p>\r\n\r\n<b>Group To Alert On New User</b><br>\r\nWhat group should be alerted when a new user registers?\r\n<p>\r\n\r\n<b>Enable Karma?</b><br>\r\nShould karma be enabled?\r\n<p>\r\n\r\n<b>Karma Per Login</b><br>\r\nThe amount of karma a user should be given when they log in. This only takes affect if karma is enabled.\r\n<p>\r\n\r\n<b>Session Timeout</b><br>\r\nThe amount of time that a user session remains active (before needing to log in again). This timeout is reset each time a user views a page. Therefore if you set the timeout for 8 hours, a user would have to log in again if s/he hadn\'t visited the site for 8 hours.\r\n<p>\r\n\r\n<b>Authentication Method (default)</b><br>\r\nWhat should the default authentication method be for new accounts that are created? The two available options are WebGUI and LDAP. WebGUI authentication means that the users will authenticate against the username and password stored in the WebGUI database. LDAP authentication means that users will authenticate against an external LDAP server.\r\n<br><br>\r\n<i>Note:</i> Authentication settings can be customized on a per user basis.\r\n<br><br>\r\n\r\n<b>Username Binding</b><br>\r\nBind the WebGUI username to the LDAP Identity. This requires the user to have the same username in WebGUI as they specified during the Anonymous Registration process. It also means that they won\'t be able to change their username later. This only in effect if the user is authenticating against LDAP.\r\n<br><br>\r\n\r\n<b>LDAP URL (default)</b><br>\r\nThe default url to your LDAP server. The LDAP URL takes the form of <b>ldap://[server]:[port]/[base DN]</b>. Example: ldap://ldap.mycompany.com:389/o=MyCompany.\r\n<br><br>\r\n\r\n<b>LDAP Identity</b><br>\r\nThe LDAP Identity is the unique identifier in the LDAP server that the user will be identified against. Often this field is <b>shortname</b>, which takes the form of first initial + last name. Example: jdoe. Therefore if you specify the LDAP identity to be <i>shortname</i> then Jon Doe would enter <i>jdoe</i> during the registration process.\r\n<br><br>\r\n\r\n<b>LDAP Identity Name</b><br>\r\nThe label used to describe the LDAP Identity to the user. For instance, some companies use an LDAP server for their proxy server users to authenticate against. In the documentation or training already provided to their users, the LDAP identity is known as their <i>Web Username</i></b><i>. So you could enter that label here for consitency.\r\n<br><br>\r\n\r\n<b>LDAP Password Name</b><br>\r\nJust as the LDAP Identity Name is a label, so is the LDAP Password Name. Use this label as you would LDAP Identity Name.\r\n<p>\r\n\r\n',1031514049);
INSERT INTO international VALUES (620,'WebGUI',1,'As the function suggests you\'ll be deleting a group and removing all users from the group. Be careful not to orphan users from pages they should have access to by deleting a group that is in use.\r\n<p>\r\n\r\nAs with any delete operation, you are prompted to be sure you wish to proceed with the delete. If you answer yes, the delete will proceed and there is no recovery possible. If you answer no you\'ll be returned to the prior screen.',1031514049);
INSERT INTO international VALUES (621,'WebGUI',1,'Styles are WebGUI macro enabled. See <i>Using Macros</i> for more information.\r\n<p>\r\n\r\n\r\n<b>Style Name</b><br>\r\nA unique name to describe what this style looks like at a glance. The name has no effect on the actual look of the style.\r\n<p>\r\n\r\n\r\n<b>Body</b><br>\r\nThe body is quite literally the HTML body of your site. It defines how the page navigation will be laid out and many other things like logo, copyright, etc. At bare minimum a body must consist of a few things, the ^AdminBar; macro and the ^-; (seperator) macro. The ^AdminBar; macro tells WebGUI where to display admin functions. The ^-; (splitter) macro tells WebGUI where to put the content of your page.\r\n<p>\r\n\r\n\r\nIf you are in need of assistance for creating a look for your site, or if you need help cutting apart your design, <a href=\"http://www.plainblack.com/\">Plain Black Software</a> provides support services for a small fee.\r\n<p>\r\n\r\n\r\nMany people will add WebGUI macros to their body for automated navigation, and other features.\r\n<p>\r\n\r\n\r\n<b>Style Sheet</b><br>\r\nPlace your style sheet entries here. Style sheets are used to control colors, sizes, and other properties of the elements on your site. See <i>Using Style Sheets</i> for more information.\r\n<p>\r\n\r\n\r\n<i>Advanced Users:</i> for greater performance create your stylesheet on the file system (call it something like webgui.css) and add an entry like this to this area: \r\n<link href=\"/webgui.css\" rel=\"stylesheet\" rev=\"stylesheet\" type=\"text/css\">\r\n<p>\r\n\r\n',1031514049);
INSERT INTO international VALUES (619,'WebGUI',1,'This function permanently deletes the selected wobject from a page. If you are unsure whether you wish to delete this content you may be better served to cut the content to the clipboard until you are certain you wish to delete it.\r\n<p>\r\n\r\n\r\nAs with any delete operation, you are prompted to be sure you wish to proceed with the delete. If you answer yes, the delete will proceed and there is no recovery possible. If you answer no you\'ll be returned to the prior screen.\r\n<p>\r\n\r\n',1031514049);
INSERT INTO international VALUES (617,'WebGUI',1,'Settings are items that allow you to adjust WebGUI to your particular needs.\r\n<p>\r\n\r\n\r\n<b>Edit Company Information</b><br>\r\nInformation specific about the company or individual who controls this installation of WebGUI.\r\n<p>\r\n\r\n\r\n<b>Edit Content Settings</b><br>\r\nSettings related to content and content management.\r\n<p>\r\n\r\n\r\n<b>Edit Mail Settings</b><br>\r\nSettings concerning email and related functions.\r\n<p>\r\n\r\n\r\n<b>Edit Miscellaneous Settings</b><br>\r\nAnything we couldn\'t find a place for.\r\n<p>\r\n\r\n\r\n<b>Edit Profile Settings</b><br>\r\nDefine what user profiles look like and what the users have the ability to edit.\r\n<p>\r\n\r\n\r\n<b>Edit User Settings</b><br>\r\nSettings relating to users (beyond profile information), like authentication information, and registration options.\r\n<p>\r\n\r\n\r\n',1031514049);
INSERT INTO international VALUES (615,'WebGUI',1,'Groups are used to subdivide privileges and responsibilities within the WebGUI system. For instance, you may be building a site for a classroom situation. In that case you might set up a different group for each class that you teach. You would then apply those groups to the pages that are designed for each class.\r\n<p>\r\n\r\nThere are several groups built into WebGUI. They are as follows:\r\n<p>\r\n\r\n<b>Admins</b><br>\r\nAdmins are users who have unlimited privileges within WebGUI. A user should only be added to the admin group if they oversee the system. Usually only one to three people will be added to this group.\r\n<p>\r\n\r\n<b>Content Managers</b><br>\r\nContent managers are users who have privileges to add, edit, and delete content from various areas on the site. The content managers group should not be used to control individual content areas within the site, but to determine whether a user can edit content at all. You should set up additional groups to separate content areas on the site.\r\n<p>\r\n\r\n<b>Everyone</b><br>\r\nEveryone is a magic group in that no one is ever physically inserted into it, but yet all members of the site are part of it. If you want to open up your site to both visitors and registered users, use this group to do it.\r\n<p>\r\n\r\n<b>Package Managers</b><br>\r\nUsers that have privileges to add, edit, and delete packages of wobjects and pages to deploy.\r\n<p>\r\n\r\n<b>Registered Users</b><br>\r\nWhen users are added to the system they are put into the registered users group. A user should only be removed from this group if their account is deleted or if you wish to punish a troublemaker.\r\n<p>\r\n\r\n<b>Style Managers</b><br>\r\nUsers that have privileges to edit styles for this site. These privileges do not allow the user to assign privileges to a page, just define them to be used.\r\n<p>\r\n\r\n<b>Template Managers</b><br>\r\nUsers that have privileges to edit templates for this site.\r\n<p>\r\n\r\n<b>Visitors</b><br>\r\nVisitors are users who are not logged in using an account on the system. Also, if you wish to punish a registered user you could remove him/her from the Registered Users group and insert him/her into the Visitors group.\r\n<p>\r\n',1031514049);
INSERT INTO international VALUES (613,'WebGUI',1,'Users are the accounts in the system that are given rights to do certain things. There are two default users built into the system: Admin and Visitor.\r\n</i></p><p><i>\r\n\r\n<b>Admin</b><br>\r\nAdmin is exactly what you\'d expect. It is a user with unlimited rights in the WebGUI environment. If it can be done, this user has the rights to do it.\r\n</i></p><p><i>\r\n\r\n<b>Visitor</b><br>\r\nVisitor is exactly the opposite of Admin. Visitor has no rights what-so-ever. By default any user who is not logged in is seen as the user Visitor.\r\n</i></p><p><i>\r\n\r\n<b>Add a new user.</b><br>\r\nClick on this to go to the add user screen.\r\n</i></p><p><i>\r\n\r\n<b>Search</b><br>\r\nYou can search users based on username and email address. You can do partial searches too if you like.',1031514049);
INSERT INTO international VALUES (614,'WebGUI',1,'Styles are used to manage the look and feel of your WebGUI pages. With WebGUI, you can have an unlimited number of styles, so your site can take on as many looks as you like. You could have some pages that look like your company\'s brochure, and some pages that look like Yahoo!®. You could even have some pages that look like pages in a book. Using style management, you have ultimate control over all your designs.\r\n<p>\r\n\r\nThere are several styles built into WebGUI. The first of these are used by WebGUI can should not be edited or deleted. The last few are simply example styles and may be edited or deleted as you please.\r\n<p>\r\n\r\n\r\n<b>Clipboard</b><br>\r\nThis style is used by the clipboard system.\r\n<p>\r\n\r\n\r\n<b>Fail Safe</b><br>\r\nWhen you delete a style that is still in use on some pages, the Fail Safe style will be applied to those pages. This style has a white background and simple navigation.\r\n<p>\r\n\r\n\r\n<b>Make Page Printable</b><br>\r\nThis style is used if you place an <b>^r;</b> macro on your pages and the user clicks on it. This style allows you to put a simple logo and copyright message on your printable pages.\r\n<p>\r\n\r\n\r\n<b>Packages</b><br>\r\nThis style is used by the package management system.\r\n<p>\r\n\r\n\r\n<b>Trash</b><br>\r\nThis style is used by the trash system.\r\n<p>\r\n\r\n\r\n<hr>\r\n\r\n<b>Demo Style</b><br>\r\nThis is a sample design taken from a templates site (www.freewebtemplates.com).\r\n<p>\r\n\r\n\r\n<b>Plain Black Software (black) & (white)</b><br>\r\nThese designs are used on the Plain Black site.\r\n<p>\r\n\r\n\r\n<b>Yahoo!®</b><br>\r\nThis is the design of the Yahoo!® site. (Used without permission.)\r\n<p>\r\n\r\n\r\n<b>WebGUI</b><br>\r\nThis is a simple design featuring WebGUI logos.\r\n<p>\r\n\r\n<b>WebGUI 4</b><br>\r\nThis style was added to WebGUI as of version 4.0.0. It is now the default style and has superceded the \"WebGUI\" style.\r\n<p>\r\n\r\n',1031514049);
INSERT INTO international VALUES (612,'WebGUI',1,'There is no need to ever actually delete a user. If you are concerned with locking out a user, then simply change their password. If you truely wish to delete a user, then please keep in mind that there are consequences. If you delete a user any content that they added to the site via wobjects (like message boards and user contributions) will remain on the site. However, if another user tries to visit the deleted user\'s profile they will get an error message. Also if the user ever is welcomed back to the site, there is no way to give him/her access to his/her old content items except by re-adding the user to the users table manually.\r\n<p>\r\n\r\n\r\nAs with any delete operation, you are prompted to be sure you wish to proceed with the delete. If you answer yes, the delete will proceed and there is no recovery possible. If you answer no you\'ll be returned to the prior screen.\r\n<p>\r\n\r\n',1031514049);
INSERT INTO international VALUES (637,'WebGUI',1,'<b>First Name</b><br>\r\nThe given name of this user.\r\n<p>\r\n\r\n<b>Middle Name</b><br>\r\nThe middle name of this user.\r\n<p>\r\n\r\n<b>Last Name</b><br>\r\nThe surname (or family name) of this user.\r\n<p>\r\n\r\n<b>Email Address</b><br>\r\nThe user\'s email address. This must only be specified if the user will partake in functions that require email.\r\n<p>\r\n\r\n<b>ICQ UIN</b><br>\r\nThe <a href=\"http://www.icq.com/\">ICQ</a> UIN is the \"User ID Number\" on the ICQ network. ICQ is a very popular instant messaging platform.\r\n<p>\r\n\r\n<b>AIM Id</b><br>\r\nThe account id for the <a href=\"http://www.aim.com/\">AOL Instant Messenger</a> system.\r\n<p>\r\n\r\n<b>MSN Messenger Id</b><br>\r\nThe account id for the <a href=\"http://messenger.msn.com/\">Microsoft Network Instant Messenger</b> system.\r\n<p>\r\n\r\n<b>Yahoo! Messenger Id</b><br>\r\nThe account id for the <a href=\"http://messenger.yahoo.com/\">Yahoo! Instant Messenger</a> system.\r\n<p>\r\n\r\n<b>Cell Phone</b><br>\r\nThis user\'s cellular telephone number.\r\n<p>\r\n\r\n<b>Pager</b><br>\r\nThis user\'s pager telephone number.\r\n<p>\r\n\r\n<b>Email To Pager Gateway</b><br>\r\nThis user\'s text pager email address.\r\n<p>\r\n\r\n<b>Home Information</b><br>\r\nThe postal (or street) address for this user\'s home.\r\n<p>\r\n\r\n<b>Work Information</b><br>\r\nThe postal (or street) address for this user\'s company.\r\n<p>\r\n\r\n<b>Gender</b><br>\r\nThis user\'s sex.\r\n<p>\r\n\r\n<b>Birth Date</b><br>\r\nThis user\'s date of birth.\r\n\r\n<b>Language</b><br>\r\nWhat language should be used to display system related messages.\r\n<p>\r\n\r\n<b>Time Offset</b><br>\r\nA number of hours (plus or minus) different this user\'s time is from the server. This is used to adjust for time zones.\r\n<p>\r\n\r\n<b>First Day Of Week</b><br>\r\nThe first day of the week on this user\'s local calendar. For instance, in the United States the first day of the week is Sunday, but in many places in Europe, the first day of the week is Monday.\r\n<p>\r\n\r\n<b>Date Format</b><br>\r\nWhat format should dates on this site appear in?\r\n<p>\r\n\r\n<b>Time Format</b><br>\r\nWhat format should times on this site appear in? \r\n<p>\r\n\r\n<b>Discussion Layout</b><br>\r\nShould discussions be laid out flat or threaded? Flat puts all replies on one page in the order they were created. Threaded shows the heirarchical list of replies as they were created.\r\n<p>\r\n\r\n<b>Inbox Notifications</b><br>\r\nHow should this user be notified when they get a new WebGUI message?\r\n\r\n',1031514049);
INSERT INTO international VALUES (610,'WebGUI',1,'See <b>Manage Users</b> for additional details.\r\n<p>\r\n\r\n<b>Username</b><br>\r\nUsername is a unique identifier for a user. Sometimes called a handle, it is also how the user will be known on the site. (<i>Note:</i> Administrators have unlimited power in the WebGUI system. This also means they are capable of breaking the system. If you rename or create a user, be careful not to use a username already in existance.)\r\n<p>\r\n\r\n\r\n<b>Password</b><br>\r\nA password is used to ensure that the user is who s/he says s/he is.\r\n<p>\r\n\r\n\r\n<b>Authentication Method</b><br>\r\nSee <i>Edit Settings</i> for details.\r\n<p>\r\n\r\n\r\n<b>LDAP URL</b><br>\r\nSee <i>Edit Settings</i> for details.\r\n<p>\r\n\r\n\r\n<b>Connect DN</b><br>\r\nThe Connect DN is the <b>cn</b> (or common name) of a given user in your LDAP database. It should be specified as <b>cn=John Doe</b>. This is, in effect, the username that will be used to authenticate this user against your LDAP server.\r\n<p>\r\n\r\n\r\n',1031514049);
INSERT INTO international VALUES (608,'WebGUI',1,'Deleting a page can create a big mess if you are uncertain about what you are doing. When you delete a page you are also deleting the content it contains, all sub-pages connected to this page, and all the content they contain. Be certain that you have already moved all the content you wish to keep before you delete a page.\r\n<p>\r\n\r\nAs with any delete operation, you are prompted to be sure you wish to proceed with the delete. If you answer yes, the delete will proceed and there is no recovery possible. If you answer no you\'ll be returned to the prior screen.\r\n<p>\r\n',1031514049);
INSERT INTO international VALUES (609,'WebGUI',1,'When you delete a style all pages using that style will be reverted to the fail safe (default) style. To ensure uninterrupted viewing, you should be sure that no pages are using a style before you delete it.\r\n<p>\r\n\r\n\r\nAs with any delete operation, you are prompted to be sure you wish to proceed with the delete. If you answer yes, the delete will proceed and there is no recovery possible. If you answer no you\'ll be returned to the prior screen.\r\n<p>\r\n\r\n',1031514049);
INSERT INTO international VALUES (606,'WebGUI',1,'Think of pages as containers for content. For instance, if you want to write a letter to the editor of your favorite magazine you\'d get out a notepad (or open a word processor) and start filling it with your thoughts. The same is true with WebGUI. Create a page, then add your content to the page.\r\n<p>\r\n\r\n<b>Title</b><br>\r\nThe title of the page is what your users will use to navigate through the site. Titles should be descriptive, but not very long.\r\n<p>\r\n\r\n\r\n<b>Menu Title</b><br>\r\nA shorter or altered title to appear in navigation. If left blank this will default to <i>Title</i>.\r\n<p>\r\n\r\n<b>Page URL</b><br>\r\nWhen you create a page a URL for the page is generated based on the page title. If you are unhappy with the URL that was chosen, you can change it here.\r\n<p>\r\n\r\n<b>Redirect URL</b><br>\r\nWhen this page is visited, the user will be redirected to the URL specified here. In order to edit this page in the future, you\'ll have to access it from the \"Manage page tree.\" menu under \"Administrative functions...\"\r\n<p>\r\n\r\n<b>Template</b><br>\r\nBy default, WebGUI has one big content area to place wobjects. However, by specifying a template other than the default you can sub-divide the content area into several sections.\r\n<p>\r\n\r\n<b>Synopsis</b><br>\r\nA short description of a page. It is used to populate default descriptive meta tags as well as to provide descriptions on Site Maps.\r\n<p>\r\n\r\n<b>Meta Tags</b><br>\r\nMeta tags are used by some search engines to associate key words to a particular page. There is a great site called <a href=\"http://www.metatagbuilder.com/\">Meta Tag Builder</a> that will help you build meta tags if you\'ve never done it before.\r\n<p>\r\n\r\n<i>Advanced Users:</i> If you have other things (like JavaScript) you usually put in the  area of your pages, you may put them here as well.\r\n<p>\r\n\r\n<b>Use default meta tags?</b><br>\r\nIf you don\'t wish to specify meta tags yourself, WebGUI can generate meta tags based on the page title and your company\'s name. Check this box to enable the WebGUI-generated meta tags.\r\n<p>\r\n\r\n\r\n<b>Style</b><br>\r\nBy default, when you create a page, it inherits a few traits from its parent. One of those traits is style. Choose from the list of styles if you would like to change the appearance of this page. See <i>Add Style</i> for more details.\r\n<p>\r\n\r\nIf you select \"Yes\" below the style pull-down menu, all of the pages below this page will take on the style you\'ve chosen for this page.\r\n<p>\r\n\r\n<b>Start Date</b><br>\r\nThe date when users may begin viewing this page. Note that before this date only content managers with the rights to edit this page will see it.\r\n<p>\r\n\r\n<b>End Date</b><br>\r\nThe date when users will stop viewing this page. Note that after this date only content managers with the rights to edit this page will see it.\r\n<p>\r\n\r\n\r\n<b>Owner</b><br>\r\nThe owner of a page is usually the person who created the page.\r\n<p>\r\n\r\n<b>Owner can view?</b><br>\r\nCan the owner view the page or not?\r\n<p>\r\n\r\n<b>Owner can edit?</b><br>\r\nCan the owner edit the page or not? Be careful, if you decide that the owner cannot edit the page and you do not belong to the page group, then you\'ll lose the ability to edit this page.\r\n<p>\r\n\r\n<b>Group</b><br>\r\nA group is assigned to every page for additional privilege control. Pick a group from the pull-down menu.\r\n<p>\r\n\r\n<b>Group can view?</b><br>\r\nCan members of this group view this page?\r\n<p>\r\n\r\n<b>Group can edit?</b><br>\r\nCan members of this group edit this page?\r\n<p>\r\n\r\n<b>Anybody can view?</b><br>\r\nCan any visitor or member regardless of the group and owner view this page?\r\n<p>\r\n\r\n<b>Anybody can edit?</b><br>\r\nCan any visitor or member regardless of the group and owner edit this page?\r\n<p>\r\n\r\nYou can optionally recursively give these privileges to all pages under this page.\r\n<p>\r\n',1031514049);
INSERT INTO international VALUES (634,'WebGUI',1,'<b>Default Home Page</b><br>\r\nSome really small sites don\'t have a home page, but instead like to use one of their internal pages like \"About Us\" or \"Company Information\" as their home page. For that reason, you can set the default page of your site to any page in the site. That page will be the one people go to if they type in just your URL http://www.mywebguisite.com, or if they click on the Home link generated by the ^H; macro.\r\n<p>\r\n\r\n<b>Not Found Page</b><br>\r\nIf a page that a user requests is not found in the system, the user can be redirected to the home page or to an error page where they can attempt to find what they were looking for. You decide which is better for your users.\r\n<p>\r\n\r\n<b>Document Type Declaration</b><br>\r\nThese days it is very common to have a wide array of browsers accessing your site, including automated browsers like search engine spiders. Many of those browsers want to know what kind of content you are serving. The doctype tag allows you to specify that. By default WebGUI generates HTML 4.0 compliant content.\r\n<p>\r\n\r\n<b>Add edit stamp to posts?</b><br>\r\nTypically if a user edits a post on a message board, a stamp is added to that post to identify who made the edit, and at what time. On some sites that information is not necessary, therefore you can turn it off here.\r\n<p>\r\n\r\n<b>Filter Contributed HTML</b><br>\r\nEspecially when running a public site where anybody can post to your message boards or user submission systems, it is often a good idea to filter their content for malicious code that can harm the viewing experience of your visitors; And in some circumstances, it can even cause security problems. Use this setting to select the level of filtering you wish to apply.\r\n<p>\r\n\r\n<b>Maximum Attachment Size</b><br>\r\nThe size (in kilobytes) of the maximum allowable attachment to be uploaded to your system.\r\n<p>\r\n\r\n<b>Max Image Size</b><br>\r\nIf images are uploaded to your system that are bigger than the max image size, then they will be resized to the max image size. The max image size is measured in pixels and will use the size of the longest side of the image to determine if the limit has been reached.\r\n<p>\r\n\r\n<b>Thumbnail Size</b><br>\r\nWhen images are uploaded to your system, they will automatically have thumbnails generated at the size specified here. Thumbnail size is measured in pixels.\r\n<p>\r\n\r\n<b>Text Area Rows</b><br>\r\nSome sites wish to control the size of the forms that WebGUI generates. With this setting you can specify how many rows of characters will be displayed in textareas on the site.\r\n<p>\r\n\r\n<b>Text Area Columns</b><br>\r\nSome sites wish to control the size of the forms that WebGUI generates. With this setting you can specify how many columns of characters will be displayed in textareas on the site.\r\n<p>\r\n\r\n<b>Text Box Size</b><br>\r\nSome sites wish to control the size of the forms that WebGUI generates. With this setting you can specify how characters can be displayed at once in text boxes on the site.\r\n<p>\r\n\r\n<b>Editor To Use</b><br>\r\nWebGUI has a very sophisticated Rich Editor that allows users to fomat content as though they were in Microsoft Word® or some other word processor. To use that functionality, select \"Built-In Editor\". Sometimes web sites have the need for even more complex rich editors for things like Spell Check. For that reason you can install an 3rd party editor called <a href=\"http://www.realobjects.de/\"><i>Real Objects Edit-On Pro®</i></a> rich text editor. After you\'ve installed it change this option. If you need detailed instructions on how to integrate <i>Edit-On Pro®)</i>, you can find them in <a href=\"http://www.plainblack.com/ruling_webgui\"><i>Ruling WebGUI</i></a>.\r\n<p>\r\n',1031514049);
INSERT INTO international VALUES (638,'WebGUI',1,'Templates are used to affect how pages are laid out in WebGUI. For instance, most sites these days have more than just a menu and one big text area. Many of them have three or four columns preceeded by several headers and/or banner areas. WebGUI accomodates complex layouts through the use of Templates. There are several templates that come with WebGUI to make life easier for you, but you can create as many as you\'d like.\r\n<p>\r\n\r\n',1031514049);
INSERT INTO international VALUES (639,'WebGUI',1,'<b>Template Name</b><br>\r\nGive this template a descriptive name so that you\'ll know what it is when you\'re applying the template to a page.\r\n<p>\r\n\r\n\r\n<b>Template</b><br>\r\nCreate your template by placing the special macros ^0; ^1; ^2;  and so on in your template to represent the different content areas. Typically this is done by using a table to position the content. Be sure to take a look at the templates that come with WebGUI for ideas.\r\n<p>\r\n\r\n',1031514049);
INSERT INTO international VALUES (640,'WebGUI',1,'It is not a good idea to delete templates as you never know what kind of adverse affect it may have on your site (some pages may still be using the template). If you should choose to delete a template, all the pages still using the template will be set to the \"Default\" template.\r\n<p>\r\n\r\n',1031514049);
INSERT INTO international VALUES (624,'WebGUI',1,'WebGUI macros are used to create dynamic content within otherwise static content. For instance, you may wish to show which user is logged in on every page, or you may wish to have a dynamically built menu or crumb trail. \r\n<p>\r\n\r\nMacros always begin with a carat (^) and follow with at least one other character and ended with w semicolon (;). Some macros can be extended/configured by taking the format of ^<i>x</i>(\"<b>config text</b>\");. The following is a description of all the macros in the WebGUI system.\r\n<p>\r\n\r\n<b>^a; or ^a(); - My Account Link</b><br>\r\nA link to your account information. In addition you can change the link text by creating a macro like this <b>^a(\"Account Info\");</b>. \r\n<p>\r\n\r\n<i>Notes:</i> You can also use the special case ^a(linkonly); to return only the URL to the account page and nothing more. Also, the .myAccountLink style sheet class is tied to this macro.\r\n<p>\r\n\r\n<b>^AdminBar;</b><br>\r\nPlaces the administrative tool bar on the page. This is a required element in the \"body\" segment of the Style Manager.\r\n<p>\r\n\r\n<b>^AdminText();</b><br>\r\nDisplays a small text message to a user who is in admin mode. Example: ^AdminText(\"You are in admin mode!\");\r\n<p>\r\n\r\n<b>^AdminToggle; or ^AdminToggle();</b><br>\r\nPlaces a link on the page which is only visible to content managers and adminstrators. The link toggles on/off admin mode. You can optionally specify other messages to display like this: ^AdminToggle(\"Edit On\",\"Edit Off\");\r\n<p>\r\n\r\n<b>^C; or ^C(); - Crumb Trail</b><br>\r\nA dynamically generated crumb trail to the current page. You can optionally specify a delimeter to be used between page names by using ^C(::);. The default delimeter is >.\r\n<p>\r\n\r\n<i>Note:</i> The .crumbTrail style sheet class is tied to this macro.\r\n<p>\r\n\r\n<b>^c; - Company Name</b><br>\r\nThe name of your company specified in the settings by your Administrator.\r\n<p>\r\n\r\n\r\n<b>^D; or ^D(); - Date</b><br>\r\nThe current date and time.\r\n<p>\r\n\r\nYou can configure the date by using date formatting symbols. For instance, if you created a macro like this <b>^D(\"%c %D, %y\");</b> it would output <b>September 26, 2001</b>. The following are the available date formatting symbols:\r\n<p>\r\n\r\n<table><tbody><tr><td>%%</td><td>%</td></tr><tr><td>%y</td><td>4 digit year</td></tr><tr><td>%Y</td><td>2 digit year</td></tr><tr><td>%m</td><td>2 digit month</td></tr><tr><td>%M</td><td>variable digit month</td></tr><tr><td>%c</td><td>month name</td></tr><tr><td>%d</td><td>2 digit day of month</td></tr><tr><td>%D</td><td>variable digit day of month</td></tr><tr><td>%w</td><td>day of week name</td></tr><tr><td>%h</td><td>2 digit base 12 hour</td></tr><tr><td>%H</td><td>variable digit base 12 hour</td></tr><tr><td>%j</td><td>2 digit base 24 hour</td></tr><tr><td>%J</td><td>variable digit base 24 hour</td></tr><tr><td>%p</td><td>lower case am/pm</td></tr><tr><td>%P</td><td>upper case AM/PM</td></tr><tr><td>%z</td><td>user preference date format</td></tr><tr><td>%Z</td><td>user preference time format</td></tr></tbody></table>\r\n<p>\r\n\r\n\r\n<b>^e; - Company Email Address</b><br>\r\nThe email address for your company specified in the settings by your Administrator.\r\n<p>\r\n\r\n<b>^Env()</b><br>\r\nCan be used to display a web server environment variable on a page. The environment variables available on each server are different, but you can find out which ones your web server has by going to: http://www.yourwebguisite.com/env.pl\r\n<p>\r\n\r\nThe macro should be specified like this ^Env(\"REMOTE_ADDR\");\r\n<p>\r\n\r\n<b>^Execute();</b><br>\r\nAllows a content manager or administrator to execute an external program. Takes the format of <b>^Execute(\"/this/file.sh\");</b>.\r\n<p>\r\n\r\n\r\n<b>^Extras;</b><br>\r\nReturns the path to the WebGUI \"extras\" folder, which contains things like WebGUI icons.\r\n<p>\r\n\r\n\r\n<b>^FlexMenu;</b><br>\r\nThis menu macro creates a top-level menu that expands as the user selects each menu item.\r\n<p>\r\n\r\n<b>^FormParam();</b><br>\r\nThis macro is mainly used in generating dynamic queries in SQL Reports. Using this macro you can pull the value of any form field simply by specifing the name of the form field, like this: ^FormParam(\"phoneNumber\");\r\n<p>\r\n\r\n<b>^GroupText();</b><br>\r\nDisplays a small text message to the user if they belong to the specified group. Example: ^GroupText(\"Visitors\",\"You need an account to do anything cool on this site!\");\r\n<p>\r\n\r\n\r\n<b>^H; or ^H(); - Home Link</b><br>\r\nA link to the home page of this site.  In addition you can change the link text by creating a macro like this <b>^H(\"Go Home\");</b>.\r\n<p>\r\n\r\n<i>Notes:</i> You can also use the special case ^H(linkonly); to return only the URL to the home page and nothing more. Also, the .homeLink style sheet class is tied to this macro.\r\n<p>\r\n\r\n<b>^I(); - Image Manager Image with Tag</b><br>\r\nThis macro returns an image tag with the parameters for an image defined in the image manager. Specify the name of the image using a tag like this <b>^I(\"imageName\")</b>;.\r\n<p>\r\n\r\n<b>^i(); - Image Manager Image Path</b><br>\r\nThis macro returns the path of an image uploaded using the Image Manager. Specify the name of the image using a tag like this <b>^i(\"imageName\");</b>.\r\n<p>\r\n\r\n<b>^Include();</b><br>\r\nAllows a content manager or administrator to include a file from the local filesystem. Takes the format of <b>^Include(\"/this/file.html\")</b>;\r\n<p>\r\n\r\n<b>^L; or ^L(); - Login</b><br>\r\nA small login form. You can also configure this macro. You can set the width of the login box like this ^L(20);. You can also set the message displayed after the user is logged in like this ^L(20,Hi ^a(^@;);. Click %here% if you wanna log out!)\r\n<p>\r\n\r\n<i>Note:</i> The .loginBox style sheet class is tied to this macro.\r\n<p>\r\n\r\n<b>^LoginToggle; or ^LoginToggle();</b><br>\r\nDisplays a \"Login\" or \"Logout\" message depending upon whether the user is logged in or not. You can optionally specify other messages like this: ^LoginToggle(\"Click here to log in.\",\"Click here to log out.\");\r\n<p>\r\n\r\n<b>^M; or ^M(); - Current Menu (Vertical)</b><br>\r\nA vertical menu containing the sub-pages at the current level. In addition, you may configure this macro by specifying how many levels deep the menu should go. By default it will show only the first level. To go three levels deep create a macro like this <b>^M(3);</b>. If you set the macro to \"0\" it will track the entire site tree.\r\n<p>\r\n\r\n<b>^m; - Current Menu (Horizontal)</b><br>\r\nA horizontal menu containing the sub-pages at the current level. You can optionally specify a delimeter to be used between page names by using ^m(:--:);. The default delimeter is ·.\r\n<p>\r\n\r\n<b>^P; or ^P(); - Previous Menu (Vertical)</b><br>\r\nA vertical menu containing the sub-pages at the previous level. In addition, you may configure this macro by specifying how many levels deep the menu should go. By default it will show only the first level. To go three levels deep create a macro like this <b>^P(3);</b>. If you set the macro to \"0\" it will track the entire site tree.\r\n<p>\r\n\r\n<b>^p; - Previous Menu (Horizontal)</b><br>\r\nA horizontal menu containing the sub-pages at the previous level. You can optionally specify a delimeter to be used between page names by using ^p(:--:);. The default delimeter is ·.\r\n<p>\r\n\r\n<b>^Page();</b><br>\r\nThis can be used to retrieve information about the current page. For instance it could be used to get the page URL like this ^Page(\"urlizedTitle\"); or to get the menu title like this ^Page(\"menuTitle\");.\r\n<p>\r\n\r\n<b>^PageTitle;</b><br>\r\nDisplays the title of the current page.\r\n<p>\r\n\r\n<i>Note:</i> If you begin using admin functions or the indepth functions of any wobject, the page title will become a link that will quickly bring you back to the page.\r\n<p>\r\n\r\n<b>^r; or ^r(); - Make Page Printable</b><br>\r\nCreates a link to remove the style from a page to make it printable.  In addition, you can change the link text by creating a macro like this <b>^r(\"Print Me!\");</b>.\r\n<p>\r\n\r\nBy default, when this link is clicked, the current page\'s style is replaced with the \"Make Page Printable\" style in the Style Manager. However, that can be overridden by specifying the name of another style as the second parameter, like this: ^r(\"Print!\",\"WebGUI\");\r\n<p>\r\n\r\n<i>Notes:</i> You can also use the special case ^r(linkonly); to return only the URL to the make printable page and nothing more. Also, the .makePrintableLink style sheet class is tied to this macro.\r\n<p>\r\n\r\n<b>^rootmenu; or ^rootmenu(); (Horizontal)</b><br>\r\nCreates a horizontal menu of the various roots on your system (except for the WebGUI system roots). You can optionally specify a menu delimiter like this: ^rootmenu(|);\r\n<p>\r\n\r\n\r\n<b>^RootTitle;</b><br>\r\nReturns the title of the root of the current page. For instance, the main root in WebGUI is the \"Home\" page. Many advanced sites have many roots and thus need a way to display to the user which root they are in.\r\n<p>\r\n\r\n<b>^S(); - Specific SubMenu (Vertical)</b><br>\r\nThis macro allows you to get the submenu of any page, starting with the page you specified. For instance, you could get the home page submenu by creating a macro that looks like this <b>^S(\"home\",0);</b>. The first value is the urlized title of the page and the second value is the depth you\'d like the menu to go. By default it will show only the first level. To go three levels deep create a macro like this <b>^S(\"home\",3);</b>.\r\n<p>\r\n\r\n\r\n<b>^s(); - Specific SubMenu (Horizontal)</b><br>\r\nThis macro allows you to get the submenu of any page, starting with the page you specified. For instance, you could get the home page submenu by creating a macro that looks like this <b>^s(\"home\");</b>. The value is the urlized title of the page.  You can optionally specify a delimeter to be used between page names by using ^s(\"home\",\":--:\");. The default delimeter is ·.\r\n<p>\r\n\r\n<b>^SQL();</b><br>\r\nA one line SQL report. Sometimes you just need to pull something back from the database quickly. This macro is also useful in extending the SQL Report wobject. It uses the numeric macros (^0; ^1; ^2; etc) to position data and can also use the ^rownum; macro just like the SQL Report wobject. Examples:<p>\r\n ^SQL(\"select count(*) from users\",\"There are ^0; users on this system.\");\r\n<p>\r\n^SQL(\"select userId,username from users order by username\",\"&lt;a href=\'^/;?op=viewProfile&uid=^0;\'&gt;^1;&lt;/a&gt;&lt;br&gt;\");\r\n<p>\r\n\r\n<b>^Synopsis; or ^Synopsis(); Menu</b><br>\r\nThis macro allows you to get the submenu of a page along with the synopsis of each link. You may specify an integer to specify how many levels deep to traverse the page tree.\r\n<p>\r\n\r\n<i>Notes:</i> The .synopsis_sub, .synopsis_summary, and .synopsis_title style sheet classes are tied to this macro.\r\n<p>\r\n\r\n<b>^T; or ^T(); - Top Level Menu (Vertical)</b><br>\r\nA vertical menu containing the main pages of the site (aka the sub-pages from the home page). In addition, you may configure this macro by specifying how many levels deep the menu should go. By default it will show only the first level. To go three levels deep create a macro like this <b>^T(3);</b>. If you set the macro to \"0\" it will track the entire site tree.\r\n<p>\r\n\r\n<b>^t; - Top Level Menu (Horizontal)</b><br>\r\nA vertical menu containing the main pages of the site (aka the sub-pages from the home page). You can optionally specify a delimeter to be used between page names by using ^t(:--:);. The default delimeter is ·.\r\n<p>\r\n\r\n<b>^Thumbnail();</b><br>\r\nReturns the URL of a thumbnail for an image from the image manager. Specify the name of the image like this <b>^Thumbnail(\"imageName\");</b>.\r\n<p>\r\n\r\n<b>^ThumbnailLinker();</b><br>\r\nThis is a good way to create a quick and dirty screenshots page or a simple photo gallery. Simply specify the name of an image in the Image Manager like this: ^ThumbnailLinker(\"My Grandmother\"); and this macro will create a thumnail image with a title under it that links to the full size version of the image.\r\n<p>\r\n\r\n<b>^u; - Company URL</b><br>\r\nThe URL for your company specified in the settings by your Administrator.\r\n<p>\r\n\r\n<b>^URLEncode();</b><br>\r\nThis macro is mainly useful in SQL reports, but it could be useful elsewhere as well. It takes the input of a string and URL Encodes it so that the string can be passed through a URL. It\'s syntax looks like this: ^URLEncode(\"Is this my string?\");\r\n<p>\r\n\r\n\r\n<b>^User();</b><br>\r\nThis macro will allow you to display any information from a user\'s account or profile. For instance, if you wanted to display a user\'s email address you\'d create this macro: ^User(\"email\");\r\n<p>\r\n\r\n<b>^/; - System URL</b><br>\r\nThe URL to the gateway script (example: <i>/index.pl/</i>).\r\n<p>\r\n\r\n<b>^\\; - Page URL</b><br>\r\nThe URL to the current page (example: <i>/index.pl/pagename</i>).\r\n<p>\r\n\r\n<b>^@; - Username</b><br>\r\nThe username of the currently logged in user.\r\n<p>\r\n\r\n<b>^?; - Search</b><br>\r\nAdd a search box to the page. The search box is tied to WebGUI\'s built-in search engine.\r\n<p>\r\n\r\n<i>Note:</i> The .searchBox style sheet class is tied to this macro.\r\n<p>\r\n\r\n<b>^#; - User ID</b><br>\r\nThe user id of the currently logged in user.\r\n<p>\r\n\r\n<b>^*; or ^*(); - Random Number</b><br>\r\nA randomly generated number. This is often used on images (such as banner ads) that you want to ensure do not cache. In addition, you may configure this macro like this <b>^*(100);</b> to create a random number between 0 and 100.\r\n<p>\r\n\r\n<b>^-;,^0;,^1;,^2;,^3;, etc.</b><br>\r\nThese macros are reserved for system/wobject-specific functions as in the SQL Report wobject and the Body in the Style Manager.\r\n<p>\r\n',1031514049);
INSERT INTO international VALUES (62,'Product',1,'Product Template, Add/Edit',1031514049);
INSERT INTO international VALUES (63,'Product',1,'Product templates are used to control how your product presented to your customer, in much the same way that other templates in WebGUI layout content. There are a few templates provided for you as reference, but you should create a template that\'s right for your product. \r\n<p>\r\nChances are you won\'t need all of the fields that WebGUI\'s product manager gives you. When creating your template, be sure to remove those fields for faster operation.\r\n<p>\r\n<b>NOTE:</b> You shouldn\'t edit the default templates, but rather make copies of them if you wish to edit them. This is because the templates may be changed in future releases of WebGUI and then your changes would be lost at upgrade time. If you make copies, or create your own templates, you won\'t have to worry about losing your changes.\r\n<p>\r\nThere are many custom macros to use in your product templates. They are as follows:\r\n<p>\r\n<b>^Product_Accessories;</b><br>\r\nDisplays the list of accessories associated with this product.\r\n<p>\r\n<b>^Product_Benefits;</b><br>\r\nDisplays the list of benefits associated with this product.\r\n<p>\r\n<b>^Product_Description;</b><br>\r\nDisplays the product\'s description.\r\n<p>\r\n<b>^Product_Features;</b><br>\r\nDisplays the list of features associated with this product.\r\n<p>\r\n<b>^Product_Image1;</b><br>\r\nDisplays the first image you uploaded with this product (if any).\r\n<p>\r\n<b>^Product_Image2;</b><br>\r\nDisplays the second image you uploaded with this product (if any).\r\n<p>\r\n<b>^Product_Image2;</b><br>\r\nDisplays the third image you uploaded with this product (if any).\r\n<p>\r\n<b>^Product_Number;</b><br>\r\nDisplays the product\'s number field or SKU.\r\n<p>\r\n<b>^Product_Price;</b><br>\r\nDisplays the product\'s price field.\r\n<p>\r\n<b>^Product_Related;</b><br>\r\nDisplays the list of related products associated with this product.\r\n<p>\r\n<b>^Product_Specifications;</b><br>\r\nDisplays the list of specifications associated with this product.\r\n<p>\r\n<b>^Product_Thumbnail1;</b><br>\r\nDisplays the thumbnail of the first image you uploaded with this product (if any) along with a link to view the full size image.\r\n<p>\r\n<b>^Product_Thumbnail2;</b><br>\r\nDisplays the thumbnail of the second image you uploaded with this product (if any) along with a link to view the full size image.\r\n<p>\r\n<b>^Product_Thumbnail3;</b><br>\r\nDisplays the thumbnail of the third image you uploaded with this product (if any) along with a link to view the full size image.\r\n<p>\r\n<b>^Product_Title;</b><br>\r\nDisplays the title of the product. Note that if you use this macro, you\'ll likely want to turn off the default title by selecting \"No\" on the \"Display title?\" field.\r\n<p>\r\n',1031514049);
INSERT INTO international VALUES (670,'WebGUI',1,'Image, Add/Edit',1031514049);
INSERT INTO international VALUES (673,'WebGUI',1,'Image, Delete',1031514049);
INSERT INTO international VALUES (676,'WebGUI',1,'Images, Manage',1031514049);
INSERT INTO international VALUES (678,'WebGUI',1,'Root, Manage',1031514049);
INSERT INTO international VALUES (681,'WebGUI',1,'Packages, Creating',1031514049);
INSERT INTO international VALUES (680,'WebGUI',1,'Package, Add',1031514049);
INSERT INTO international VALUES (675,'WebGUI',1,'Search Engine, Using',1031514049);
INSERT INTO international VALUES (656,'WebGUI',1,'Company Information, Edit',1031514049);
INSERT INTO international VALUES (696,'WebGUI',1,'Trash, Empty',1031514049);
INSERT INTO international VALUES (672,'WebGUI',1,'Profile Settings, Edit',1031514049);
INSERT INTO international VALUES (674,'WebGUI',1,'Miscellaneous Settings, Edit',1031514049);
INSERT INTO international VALUES (661,'WebGUI',1,'File Settings, Edit',1031514049);
INSERT INTO international VALUES (663,'WebGUI',1,'Mail Settings, Edit',1031514049);
INSERT INTO international VALUES (671,'WebGUI',1,'Wobjects, Using',1031514049);
INSERT INTO international VALUES (677,'WebGUI',1,'Wobject, Add/Edit',1031514049);
INSERT INTO international VALUES (668,'WebGUI',1,'Style Sheets, Using',1031514049);
INSERT INTO international VALUES (667,'WebGUI',1,'Group, Add/Edit',1031514049);
INSERT INTO international VALUES (652,'WebGUI',1,'User Settings, Edit',1031514049);
INSERT INTO international VALUES (665,'WebGUI',1,'Group, Delete',1031514049);
INSERT INTO international VALUES (666,'WebGUI',1,'Style, Add/Edit',1031514049);
INSERT INTO international VALUES (664,'WebGUI',1,'Wobject, Delete',1031514049);
INSERT INTO international VALUES (662,'WebGUI',1,'Settings, Manage',1031514049);
INSERT INTO international VALUES (660,'WebGUI',1,'Groups, Manage',1031514049);
INSERT INTO international VALUES (658,'WebGUI',1,'Users, Manage',1031514049);
INSERT INTO international VALUES (659,'WebGUI',1,'Styles, Manage',1031514049);
INSERT INTO international VALUES (657,'WebGUI',1,'User, Delete',1031514049);
INSERT INTO international VALUES (682,'WebGUI',1,'User Profile, Edit',1031514049);
INSERT INTO international VALUES (655,'WebGUI',1,'User, Add/Edit',1031514049);
INSERT INTO international VALUES (653,'WebGUI',1,'Page, Delete',1031514049);
INSERT INTO international VALUES (654,'WebGUI',1,'Style, Delete',1031514049);
INSERT INTO international VALUES (679,'WebGUI',1,'Content Settings, Edit',1031514049);
INSERT INTO international VALUES (683,'WebGUI',1,'Templates, Manage',1031514049);
INSERT INTO international VALUES (684,'WebGUI',1,'Template, Add/Edit',1031514049);
INSERT INTO international VALUES (685,'WebGUI',1,'Template, Delete',1031514049);
INSERT INTO international VALUES (669,'WebGUI',1,'Macros, Using',1031514049);
INSERT INTO international VALUES (686,'WebGUI',1,'Image Group, Add',1031514049);
INSERT INTO international VALUES (641,'WebGUI',1,'Image groups are like folders that are used to organize your images. The use of image groups is not required, but on large sites it is definitely useful.\r\n<p>\r\n\r\n<b>Group Name</b><br>\r\nThe name that will be displayed as you\'re browsing through your images.\r\n<p>\r\n\r\n<b>Group Description</b><br>\r\nBriefly describe what this image group is used for.\r\n<p>\r\n',1031514049);
INSERT INTO international VALUES (72,'DownloadManager',1,'Download, Add/Edit',1031514049);
INSERT INTO international VALUES (73,'DownloadManager',1,'<b>File Title</b><br>\r\nThe title that will be displayed for this download.\r\n<p>\r\n\r\n<b>Download File</b><br>\r\nChoose the file from your hard drive that you wish to upload to this download manager.\r\n<p>\r\n\r\n<b>Alternate Version #1</b><br>\r\nAn alternate version of the Download File. For instance, if the download file was a JPEG, perhaps the alternate version would be a TIFF or a BMP.\r\n<p>\r\n\r\n<b>Alternate Version #2</b><br>\r\nAn alternate version of the Download File. For instance, if the download file was a JPEG, perhaps the alternate version would be a TIFF or a BMP.\r\n<p>\r\n\r\n<b>Brief Synopsis</b><br>\r\nA short description of this file. Be sure to include keywords that users may try to search for.\r\n<p>\r\n\r\n<b>Group To Download</b><br>\r\nChoose the group that may download this file.\r\n<p>\r\n\r\n<b>Proceed to add download?</b><br>\r\nChoose \"Yes\" if you have another file to add to this download manager.\r\n<p>\r\n',1031514049);
INSERT INTO international VALUES (72,'EventsCalendar',1,'Event, Add/Edit',1031514049);
INSERT INTO international VALUES (73,'EventsCalendar',1,'<b>Title</b><br>\r\nThe title for this event.\r\n<p>\r\n\r\n<b>Description</b><br>\r\nDescribe the activities of this event or information about where the event is to be held.\r\n<p>\r\n\r\n<b>Start Date</b><br>\r\nOn what date will this event begin?\r\n<p>\r\n\r\n<b>End Date</b><br>\r\nOn what date will this event end?\r\n<p>\r\n\r\n<b>Recurs every<b><br>\r\nSelect a recurrence interval for this event. \r\n\r\n<p>\r\n\r\n<b>Proceed to add event?</b><br>\r\nIf you\'d like to add another event, select \"Yes\".\r\n<p>\r\n',1031514049);
INSERT INTO international VALUES (72,'FAQ',1,'Question, Add/Edit',1031514049);
INSERT INTO international VALUES (73,'FAQ',1,'<b>Question</b><br>\r\nAdd the question you\'d like to appear on the FAQ.\r\n<p>\r\n\r\n\r\n<b>Answer</b><br>\r\nAdd the answer for the question you entered above.\r\n<p>\r\n\r\n\r\n<b>Proceed to add question?</b><br>\r\nIf you have another question to add, select \"Yes\".\r\n<p>\r\n\r\n',1031514049);
INSERT INTO international VALUES (50,'Product',1,'Benefits are typically the result of the features of your product. They are why your product is so good. If you add benefits, you may also wish to consider adding some features.\r\n<p>\r\n\r\n<b>Benefit</b><br>\r\nYou may enter a new benefit, or select from one you\'ve already entered.\r\n<p>\r\n\r\n<b>Add another benefit?</b><br>\r\nIf you\'d like to add another benefit right away, select \"Yes\".\r\n<p>\r\n',1031514049);
INSERT INTO international VALUES (72,'LinkList',1,'Link, Add/Edit',1031514049);
INSERT INTO international VALUES (73,'LinkList',1,'<b>Title</b><br>\r\nThe text that will be linked.\r\n<p>\r\n\r\n<b>URL</b><br>\r\nThe web site to link to.\r\n<p>\r\n\r\n<b>Open in new window?</b><br>\r\nSelect yes if you\'d like this link to pop-up into a new window.\r\n<p>\r\n\r\n<b>Description</b><br>\r\nDescribe the site you\'re linking to. You can omit this if you\'d like.\r\n<p>\r\n\r\n<b>Proceed to add link?</b>\r\nIf you have another link to add, select \"Yes\".\r\n<p>\r\n',1031514049);
INSERT INTO international VALUES (49,'Product',1,'Product Benefit, Add/Edit',1031514049);
INSERT INTO international VALUES (697,'WebGUI',1,'Karma, Using',1031514049);
INSERT INTO international VALUES (698,'WebGUI',1,'Karma is a method of tracking the activity of your users, and potentially rewarding or punishing them for their level of activity. Once karma has been enabled, you\'ll notice that the menus of many things in WebGUI change to reflect karma.\r\n<p>\r\n\r\nYou can track whether users are logging in, and how much they contribute to your site. And you can allow them access to additional features by the level of their karma.\r\n<p>\r\n\r\nYou can find out more about karma in <a href=\"http://www.plainblack.com/ruling_webgui\">Ruling WebGUI</a>.',1031514049);
INSERT INTO international VALUES (5,'WobjectProxy',1,'Wobject Proxy, Add/Edit',1031514049);
INSERT INTO international VALUES (6,'WobjectProxy',1,'With the Wobject Proxy you can mirror a wobject from another page to any other page. This is useful if you want to reuse the same content in multiple sections of your site.\r\n<p>\r\n\r\n\r\n<b>Wobject To Proxy</b><br>\r\nSelect the wobject from your system that you\'d like to proxy. The select box takes the format of \"<b>Page Title</b> / <b>Wobject Name</b> (<b>Wobject Id</b>) so that you can quickly and accurately find the wobject you\'re looking for.\r\n<p>\r\n\r\n',1031514049);
INSERT INTO international VALUES (38,'Product',1,'Product, Add/Edit',1031514049);
INSERT INTO international VALUES (39,'Product',1,'WebGUI has a product management system built in to enable you to publish your products and services to your site quickly and easily.\r\n<p>\r\n\r\n<b>Price</b><br>\r\nThe price of this product. You may optionally enter text like \"call for pricing\" if you wish, or you may leave it blank.\r\n<p>\r\n\r\n<b>Product Number</b><br>\r\nThe product number, SKU, ISBN, or other identifier for this product.\r\n<p>\r\n\r\n<b>Product Image 1</b><br>\r\nAn image of this product.\r\n<p>\r\n\r\n<b>Product Image 2</b><br>\r\nAn image of this product.\r\n<p>\r\n\r\n<b>Product Image 3</b><br>\r\nAn image of this product.\r\n<p>\r\n\r\n<b>Brochure</b><br>\r\nThe brochure for this product.\r\n<p>\r\n\r\n<b>Manual</b><br>\r\nThe product, user, or service manual for this product.\r\n<p>\r\n\r\n<b>Warranty</b><br>\r\nThe warranty for this product.\r\n<p>\r\n',1031514049);
INSERT INTO international VALUES (40,'Product',1,'Product Feature, Add/Edit',1031514049);
INSERT INTO international VALUES (41,'Product',1,'Features are selling points for a product. IE: Reasons to buy your product. Features often result in benefits, so you may want to also add some benefits to this product.\r\n<p>\r\n\r\n<b>Feature</b><br>\r\nYou may enter a new feature, or select one you entered for another product in the system.\r\n<p>\r\n\r\n<b>Add another feature?</b><br>\r\nIf you\'d like to add another feature right away, select \"Yes\".\r\n<p>\r\n',1031514049);
INSERT INTO international VALUES (42,'Product',1,'Product Specification, Add/Edit',1031514049);
INSERT INTO international VALUES (43,'Product',1,'Specifications are the technical details of your product.\r\n<p>\r\n\r\n\r\n<b>Label</b><br>\r\nThe type of specification. For instance, height, weight,   or color. You may select one you\'ve entered for another product, or type in a new specification.\r\n<p>\r\n\r\n\r\n<b>Specification</b><br>\r\nThe actual specification value. For instance, if you chose height as the Label, then you\'d enter a numeric value like \"18\".\r\n<p>\r\n\r\n\r\n<b>Units</b><br>\r\nThe unit of measurement for this specification. For instance, if you chose height for your label, perhaps the units would be \"meters\".\r\n<p>\r\n\r\n\r\n<b>Add another specification?</b><br>\r\nIf you\'d like to add another specification, select \"Yes\".\r\n<p>\r\n\r\n',1031514049);
INSERT INTO international VALUES (709,'WebGUI',1,'<b>Image Managers Group</b><br>\r\nSelect the group that should have control over adding, editing, and deleting images.\r\n<p>\r\n\r\n<b>Style Managers Group</b><br>\r\nSelect the group that should have control over adding, editing, and deleting styles.\r\n<p>\r\n\r\n<b>Template Managers Group</b><br>\r\nSelect the group that should have control over adding, editing, and deleting templates.\r\n<p>\r\n',1031514049);
INSERT INTO international VALUES (44,'Product',1,'Product Accessory, Add/Edit',1031514049);
INSERT INTO international VALUES (45,'Product',1,'Accessories are products that enhance other products.\r\n<p>\r\n\r\n<b>Accessory</b><br>\r\nChoose from the list of products you\'ve already entered.\r\n<p>\r\n\r\n<b>Add another accessory?</b><br>\r\nSelect \"Yes\" if you have another accessory to add.\r\n<p>\r\n',1031514049);
INSERT INTO international VALUES (46,'Product',1,'Product (Related), Add/Edit',1031514049);
INSERT INTO international VALUES (47,'Product',1,'Related products are products that are comparable or complimentary to other products.\r\n<p>\r\n\r\n\r\n<b>Related products</b><br>\r\nChoose from the list of products you\'ve already entered.\r\n<p>\r\n\r\n\r\n<b>Add another related product?</b><br>\r\nSelect \"Yes\" if you have another related product to add.\r\n<p>\r\n\r\n',1031514049);
INSERT INTO international VALUES (708,'WebGUI',1,'Privilege Settings, Manage',1031514049);
INSERT INTO international VALUES (30,'UserSubmission',1,'Karma Per Submission',1031514049);
INSERT INTO international VALUES (72,'Poll',1,'Randomize answers?',1031514049);
INSERT INTO international VALUES (699,'WebGUI',1,'First Day Of Week',1031514049);
INSERT INTO international VALUES (74,'EventsCalendar',1,'Calendar Month (Small)',1031514049);
INSERT INTO international VALUES (702,'WebGUI',1,'Month(s)',1031514049);
INSERT INTO international VALUES (703,'WebGUI',1,'Year(s)',1031514049);
INSERT INTO international VALUES (704,'WebGUI',1,'Second(s)',1031514049);
INSERT INTO international VALUES (705,'WebGUI',1,'Minute(s)',1031514049);
INSERT INTO international VALUES (706,'WebGUI',1,'Hour(s)',1031514049);
INSERT INTO international VALUES (716,'WebGUI',1,'Login',1031514049);
INSERT INTO international VALUES (717,'WebGUI',1,'Logout',1031514049);
INSERT INTO international VALUES (40,'UserSubmission',3,'Gepost door',1031510000);
INSERT INTO international VALUES (41,'UserSubmission',3,'Datum',1031510000);
INSERT INTO international VALUES (45,'UserSubmission',3,'Ga terug naar bijdrages',1031510000);
INSERT INTO international VALUES (46,'UserSubmission',3,'Lees meer...',1031510000);
INSERT INTO international VALUES (47,'UserSubmission',3,'Post een reactie',1031510000);
INSERT INTO international VALUES (48,'UserSubmission',3,'Discussie toestaan?',1031510000);
INSERT INTO international VALUES (51,'UserSubmission',3,'Miniaturen weergeven',1031510000);
INSERT INTO international VALUES (52,'UserSubmission',3,'Miniatuur',1031510000);
INSERT INTO international VALUES (53,'UserSubmission',3,'Layout',1031510000);
INSERT INTO international VALUES (54,'UserSubmission',3,'Web Log',1031510000);
INSERT INTO international VALUES (55,'UserSubmission',3,'Traditioneel',1031510000);
INSERT INTO international VALUES (56,'UserSubmission',3,'Foto gallerij',1031510000);
INSERT INTO international VALUES (57,'UserSubmission',3,'Reacties',1031510000);
INSERT INTO international VALUES (516,'WebGUI',3,'Zet beheermode aan!',1031510000);
INSERT INTO international VALUES (517,'WebGUI',3,'Zet beheermode uit!',1031510000);
INSERT INTO international VALUES (515,'WebGUI',3,'Bewerkings stempel toevoegen?',1031510000);
INSERT INTO international VALUES (532,'WebGUI',3,'Met minstens 1 van de worden',1031510000);
INSERT INTO international VALUES (531,'WebGUI',3,'met de exacte zin',1031510000);
INSERT INTO international VALUES (505,'WebGUI',3,'Een niewe template toevoegen',1031510000);
INSERT INTO international VALUES (504,'WebGUI',3,'Sjabloon',1031510000);
INSERT INTO international VALUES (503,'WebGUI',3,'Sjabloon ID',1031510000);
INSERT INTO international VALUES (502,'WebGUI',3,'Weet u zeker dat u deze sjabloon wilt verwijderen? Elke pagina die de template gebruikt zal de standaard template krijgen!',1031510000);
INSERT INTO international VALUES (536,'WebGUI',3,'Een nieuwe gebruiker genaamd ^@; is bij de site aangemeld',1031510000);
INSERT INTO international VALUES (356,'WebGUI',3,'Sjabloon',1031510000);
INSERT INTO international VALUES (357,'WebGUI',3,'Nieuws',1031510000);
INSERT INTO international VALUES (358,'WebGUI',3,'Linker kolom',1031510000);
INSERT INTO international VALUES (359,'WebGUI',3,'Rechter kolom',1031510000);
INSERT INTO international VALUES (360,'WebGUI',3,'Een boven drie',1031510000);
INSERT INTO international VALUES (361,'WebGUI',3,'Drie boven een',1031510000);
INSERT INTO international VALUES (362,'WebGUI',3,'Zij aan zij',1031510000);
INSERT INTO international VALUES (363,'WebGUI',3,'Sjabloon positie',1031510000);
INSERT INTO international VALUES (364,'WebGUI',3,'Zoeken',1031510000);
INSERT INTO international VALUES (365,'WebGUI',3,'Zoek resultaten',1031510000);
INSERT INTO international VALUES (366,'WebGUI',3,'Er is geen pagina die aan uw vraag voldoet',1031510000);
INSERT INTO international VALUES (368,'WebGUI',3,'Voeg een nieuwe groep aan deze gebruiker toe',1031510000);
INSERT INTO international VALUES (369,'WebGUI',3,'Verloop datum',1031510000);
INSERT INTO international VALUES (370,'WebGUI',3,'Bewerk groeperen',1031510000);
INSERT INTO international VALUES (371,'WebGUI',3,'Groeperen toevoegen',1031510000);
INSERT INTO international VALUES (372,'WebGUI',3,'Bewerk gebruiker groep',1031510000);
INSERT INTO international VALUES (374,'WebGUI',3,'Beheer pakketten',1031510000);
INSERT INTO international VALUES (375,'WebGUI',3,'Selecteer pakket',1031510000);
INSERT INTO international VALUES (376,'WebGUI',3,'Pakket',1031510000);
INSERT INTO international VALUES (377,'WebGUI',3,'Er zijn geen pakketten gedefinieerd door uw pakket manager of beheerder.',1031510000);
INSERT INTO international VALUES (378,'WebGUI',3,'Gebruikers ID',1031510000);
INSERT INTO international VALUES (379,'WebGUI',3,'Groep ID',1031510000);
INSERT INTO international VALUES (380,'WebGUI',3,'Stijl ID',1031510000);
INSERT INTO international VALUES (381,'WebGUI',3,'WebGUI heeft een verkeerde vraag gekregen en kan niet verder gaan. Bepaalde karakters op de pagina kunnen de oorzaak zijn. Probeer terug te gaan naar de vorige pagina en probeer het opnieuw.',1031510000);
INSERT INTO international VALUES (528,'WebGUI',3,'Sjabloon naam',1031510000);
INSERT INTO international VALUES (383,'WebGUI',3,'Naam',1031510000);
INSERT INTO international VALUES (384,'WebGUI',3,'Bestand',1031510000);
INSERT INTO international VALUES (385,'WebGUI',3,'Parameters',1031510000);
INSERT INTO international VALUES (386,'WebGUI',3,'Bewerk plaatje',1031510000);
INSERT INTO international VALUES (387,'WebGUI',3,'Geleverd door',1031510000);
INSERT INTO international VALUES (388,'WebGUI',3,'Upload datum',1031510000);
INSERT INTO international VALUES (389,'WebGUI',3,'Plaatje ID',1031510000);
INSERT INTO international VALUES (390,'WebGUI',3,'Plaatje laten zien......',1031510000);
INSERT INTO international VALUES (391,'WebGUI',3,'Verwijder bijgevoegd bestand',1031510000);
INSERT INTO international VALUES (392,'WebGUI',3,'Weet u zeker dat u dit plaatje wilt verwijderen?',1031510000);
INSERT INTO international VALUES (393,'WebGUI',3,'Beheer plaatjes',1031510000);
INSERT INTO international VALUES (394,'WebGUI',3,'Beheer plaatjes.',1031510000);
INSERT INTO international VALUES (395,'WebGUI',3,'Een nieuw plaatje toevoegen',1031510000);
INSERT INTO international VALUES (396,'WebGUI',3,'Plaatje laten zien',1031510000);
INSERT INTO international VALUES (397,'WebGUI',3,'Terug naar plaatjes lijst',1031510000);
INSERT INTO international VALUES (398,'WebGUI',3,'Document type declaratie',1031510000);
INSERT INTO international VALUES (399,'WebGUI',3,'Valideer deze pagina',1031510000);
INSERT INTO international VALUES (400,'WebGUI',3,'Voorkom Proxy Caching',1031510000);
INSERT INTO international VALUES (401,'WebGUI',3,'Weet u zeker dat u dit bericht wilt verwijderen en alle berichten onder deze thread?',1031510000);
INSERT INTO international VALUES (402,'WebGUI',3,'Het bericht wat u vroeg bestaat niet.',1031510000);
INSERT INTO international VALUES (403,'WebGUI',3,'Geen mening',1031510000);
INSERT INTO international VALUES (405,'WebGUI',3,'Laatste pagina',1031510000);
INSERT INTO international VALUES (406,'WebGUI',3,'Miniatuur grootte',1031510000);
INSERT INTO international VALUES (407,'WebGUI',3,'Klik hier om te registreren',1031510000);
INSERT INTO international VALUES (506,'WebGUI',3,'Beheer Sjablonen',1031510000);
INSERT INTO international VALUES (408,'WebGUI',3,'Beheer roots',1031510000);
INSERT INTO international VALUES (409,'WebGUI',3,'Een nieuwe root toevoegen',1031510000);
INSERT INTO international VALUES (410,'WebGUI',3,'Beheer roots.',1031510000);
INSERT INTO international VALUES (411,'WebGUI',3,'Menu Titel',1031510000);
INSERT INTO international VALUES (412,'WebGUI',3,'Omschrijving',1031510000);
INSERT INTO international VALUES (416,'WebGUI',3,'<h1>Probleem met aanvraag</h1><br> We hebben een probleemm gevonden met de aanvraag van deze pagina. Ga terug naar de vorige pagina en probeer het opnieuw. Mocht het probleem zich blijven voordoen wendt u dan tot de beheerder.',1031510000);
INSERT INTO international VALUES (417,'WebGUI',3,'<h1>Beveiligings probleem</h1><br> U probeerde een widget op te vragen die niet bij deze pagina hoort. Het incident is gerapporteerd.',1031510000);
INSERT INTO international VALUES (418,'WebGUI',3,'Filter Contributed HTML',1031510000);
INSERT INTO international VALUES (419,'WebGUI',3,'Verwijder alle tags',1031510000);
INSERT INTO international VALUES (420,'WebGUI',3,'Laat het zoals het is',1031510000);
INSERT INTO international VALUES (421,'WebGUI',3,'Verwijder alles behalve de basis formaten',1031510000);
INSERT INTO international VALUES (422,'WebGUI',3,'<h1>Login Fout</h1><br>De informatie komt niet overeen met het account',1031510000);
INSERT INTO international VALUES (423,'WebGUI',3,'Laat aktieve sessies zien',1031510000);
INSERT INTO international VALUES (424,'WebGUI',3,'Laat login historie zien',1031510000);
INSERT INTO international VALUES (425,'WebGUI',3,'Aktieve sessies',1031510000);
INSERT INTO international VALUES (426,'WebGUI',3,'Login historie',1031510000);
INSERT INTO international VALUES (427,'WebGUI',3,'Stijlen',1031510000);
INSERT INTO international VALUES (428,'WebGUI',3,'Gebruiker (ID)',1031510000);
INSERT INTO international VALUES (429,'WebGUI',3,'Login tijd',1031510000);
INSERT INTO international VALUES (430,'WebGUI',3,'Laatst bekeken pagina',1031510000);
INSERT INTO international VALUES (431,'WebGUI',3,'IP Adres',1031510000);
INSERT INTO international VALUES (432,'WebGUI',3,'Verloopt',1031510000);
INSERT INTO international VALUES (433,'WebGUI',3,'Gebruikers applicatie',1031510000);
INSERT INTO international VALUES (434,'WebGUI',3,'Status',1031510000);
INSERT INTO international VALUES (435,'WebGUI',3,'Sessie handtekening',1031510000);
INSERT INTO international VALUES (436,'WebGUI',3,'Vermoord sessie',1031510000);
INSERT INTO international VALUES (437,'WebGUI',3,'Statistieken',1031510000);
INSERT INTO international VALUES (438,'WebGUI',3,'Uw naam',1031510000);
INSERT INTO international VALUES (441,'WebGUI',3,'Email naar pager gateway',1031510000);
INSERT INTO international VALUES (442,'WebGUI',3,'Bedrijfs informatie',1031510000);
INSERT INTO international VALUES (443,'WebGUI',3,'Thuis informatie',1031510000);
INSERT INTO international VALUES (439,'WebGUI',3,'Persoonlijke informatie',1031510000);
INSERT INTO international VALUES (440,'WebGUI',3,'Contact informatie',1031510000);
INSERT INTO international VALUES (444,'WebGUI',3,'Demografische informatie',1031510000);
INSERT INTO international VALUES (445,'WebGUI',3,'Voorkeuren',1031510000);
INSERT INTO international VALUES (446,'WebGUI',3,'Bedrijfs website',1031510000);
INSERT INTO international VALUES (447,'WebGUI',3,'Beheer pagina boom',1031510000);
INSERT INTO international VALUES (448,'WebGUI',3,'Pagina boom',1031510000);
INSERT INTO international VALUES (449,'WebGUI',3,'Overige informatie',1031510000);
INSERT INTO international VALUES (450,'WebGUI',3,'Werk naam (Bedrijfsnaam)',1031510000);
INSERT INTO international VALUES (451,'WebGUI',3,'is vereist',1031510000);
INSERT INTO international VALUES (452,'WebGUI',3,'Even wachten alstublieft....',1031510000);
INSERT INTO international VALUES (453,'WebGUI',3,'Creatie datum',1031510000);
INSERT INTO international VALUES (454,'WebGUI',3,'Laatst veranderd',1031510000);
INSERT INTO international VALUES (455,'WebGUI',3,'Bewerk gebruikersprofiel',1031510000);
INSERT INTO international VALUES (456,'WebGUI',3,'Terug naar gebruikers lijst',1031510000);
INSERT INTO international VALUES (457,'WebGUI',3,'Bewerk het account van deze gebruiker',1031510000);
INSERT INTO international VALUES (458,'WebGUI',3,'Bewerk de groepen van deze gebruiker',1031510000);
INSERT INTO international VALUES (459,'WebGUI',3,'Bewerk het profiel van deze gebruiker',1031510000);
INSERT INTO international VALUES (460,'WebGUI',3,'Tijd offset',1031510000);
INSERT INTO international VALUES (461,'WebGUI',3,'Datum formaat',1031510000);
INSERT INTO international VALUES (462,'WebGUI',3,'Tijd formaat',1031510000);
INSERT INTO international VALUES (463,'WebGUI',3,'Tekst vlak rijen',1031510000);
INSERT INTO international VALUES (464,'WebGUI',3,'Tekst vlak kolommen',1031510000);
INSERT INTO international VALUES (465,'WebGUI',3,'Tekst blok grootte',1031510000);
INSERT INTO international VALUES (466,'WebGUI',3,'Weet u zeker dat u deze categorie wilt verwijderen en alle velden naar de overige categorie wilt verplaatsen?',1031510000);
INSERT INTO international VALUES (467,'WebGUI',3,'Weet u zeker dat u dit veld wilt verwijderen en daarmee ook alle data die er aan vast zit?',1031510000);
INSERT INTO international VALUES (469,'WebGUI',3,'Id',1031510000);
INSERT INTO international VALUES (470,'WebGUI',3,'Naam',1031510000);
INSERT INTO international VALUES (472,'WebGUI',3,'Label',1031510000);
INSERT INTO international VALUES (473,'WebGUI',3,'Zichtbaar?',1031510000);
INSERT INTO international VALUES (474,'WebGUI',3,'Verplicht?',1031510000);
INSERT INTO international VALUES (475,'WebGUI',3,'Tekst',1031510000);
INSERT INTO international VALUES (476,'WebGUI',3,'Tekst vlak',1031510000);
INSERT INTO international VALUES (477,'WebGUI',3,'HTML vlak',1031510000);
INSERT INTO international VALUES (478,'WebGUI',3,'URL',1031510000);
INSERT INTO international VALUES (479,'WebGUI',3,'Datum',1031510000);
INSERT INTO international VALUES (480,'WebGUI',3,'Email adres',1031510000);
INSERT INTO international VALUES (481,'WebGUI',3,'Telefoon nummer',1031510000);
INSERT INTO international VALUES (482,'WebGUI',3,'Nummer (Geheel getal)',1031510000);
INSERT INTO international VALUES (483,'WebGUI',3,'Ja of nee',1031510000);
INSERT INTO international VALUES (484,'WebGUI',3,'Selecteer lijst',1031510000);
INSERT INTO international VALUES (485,'WebGUI',3,'Booleaanse waarde (Checkbox)',1031510000);
INSERT INTO international VALUES (486,'WebGUI',3,'Data type',1031510000);
INSERT INTO international VALUES (487,'WebGUI',3,'Mogelijke waardes',1031510000);
INSERT INTO international VALUES (488,'WebGUI',3,'Standaard waarde(s)',1031510000);
INSERT INTO international VALUES (489,'WebGUI',3,'Profiel categorie',1031510000);
INSERT INTO international VALUES (490,'WebGUI',3,'Profiel categorie toevoegen',1031510000);
INSERT INTO international VALUES (491,'WebGUI',3,'Profiel veld toevoegen',1031510000);
INSERT INTO international VALUES (492,'WebGUI',3,'Profiel veld lijst',1031510000);
INSERT INTO international VALUES (493,'WebGUI',3,'terug naar de site',1031510000);
INSERT INTO international VALUES (496,'WebGUI',3,'Ingebouwde editor',1031510000);
INSERT INTO international VALUES (494,'WebGUI',3,'Te gebruiken Editor',1031510000);
INSERT INTO international VALUES (497,'WebGUI',3,'Start datum',1031510000);
INSERT INTO international VALUES (498,'WebGUI',3,'Eind Datum',1031510000);
INSERT INTO international VALUES (499,'WebGUI',3,'Wobject ID',1031510000);
INSERT INTO international VALUES (500,'WebGUI',3,'Pagina ID',1031510000);
INSERT INTO international VALUES (514,'WebGUI',3,'Bekeken',1031510000);
INSERT INTO international VALUES (527,'WebGUI',3,'Standaard home pagina',1031510000);
INSERT INTO international VALUES (530,'WebGUI',3,'Met alle woorden',1031510000);
INSERT INTO international VALUES (501,'WebGUI',3,'Body',1031510000);
INSERT INTO international VALUES (468,'WebGUI',3,'Bewerk gebruikers profiel categorie',1031510000);
INSERT INTO international VALUES (507,'WebGUI',3,'Bewerk sjabloon',1031510000);
INSERT INTO international VALUES (508,'WebGUI',3,'Beheer sjablonen',1031510000);
INSERT INTO international VALUES (509,'WebGUI',3,'Discussie layout',1031510000);
INSERT INTO international VALUES (510,'WebGUI',3,'Plat',1031510000);
INSERT INTO international VALUES (511,'WebGUI',3,'threaded',1031510000);
INSERT INTO international VALUES (512,'WebGUI',3,'Volgende thread',1031510000);
INSERT INTO international VALUES (513,'WebGUI',3,'Vorige thread',1031510000);
INSERT INTO international VALUES (533,'WebGUI',3,'Zonder de woorden',1031510000);
INSERT INTO international VALUES (529,'WebGUI',3,'Resultaten',1031510000);
INSERT INTO international VALUES (518,'WebGUI',3,'Inbox notificaties',1031510000);
INSERT INTO international VALUES (519,'WebGUI',3,'Ik wil geen notificatie krijgen',1031510000);
INSERT INTO international VALUES (520,'WebGUI',3,'Ik wil notificatie via email',1031510000);
INSERT INTO international VALUES (521,'WebGUI',3,'Ik wil notificatie via email naar pager',1031510000);
INSERT INTO international VALUES (522,'WebGUI',3,'Ik wil notificatie via ICQ',1031510000);
INSERT INTO international VALUES (523,'WebGUI',3,'Notificatie',1031510000);
INSERT INTO international VALUES (524,'WebGUI',3,'Voeg bewerk stempel toe aan post',1031510000);
INSERT INTO international VALUES (525,'WebGUI',3,'Bewerk inhoud Settings',1031510000);
INSERT INTO international VALUES (526,'WebGUI',3,'Verwijder alleen javascript',1031510000);
INSERT INTO international VALUES (72,'EventsCalendar',3,'Gebeurtenis, Toevoegen/aanpassen',1031510000);
INSERT INTO international VALUES (9,'Product',3,'Product plaatje 3',1031510000);
INSERT INTO international VALUES (9,'MailForm',3,'Voeg veld toe',1031510000);
INSERT INTO international VALUES (8,'Product',3,'Product plaatje 2',1031510000);
INSERT INTO international VALUES (8,'MailForm',3,'Breedte',1031510000);
INSERT INTO international VALUES (78,'EventsCalendar',3,'Niets weggooien, ik heb een foutje gemaakt.',1031510000);
INSERT INTO international VALUES (77,'EventsCalendar',3,'Gooi deze gebeurtenis weg <b>en</b> alle herhalingen hiervan.',1031510000);
INSERT INTO international VALUES (76,'EventsCalendar',3,'Gooi alleen deze gebeurtenis weg.',1031510000);
INSERT INTO international VALUES (75,'EventsCalendar',3,'Welke van deze keuzes wilt u uitvoeren?',1031510000);
INSERT INTO international VALUES (74,'EventsCalendar',3,'Maandkalender (klein)',1031510000);
INSERT INTO international VALUES (73,'LinkList',3,'<b>Titel</b><br>\r\nText die gelinked zal worden.\r\n<p>\r\n<b>URL</b><br>\r\nDe Website waarnaar gelinked wordt.\r\n<p>\r\n\r\n<b>In een nieuw venster openen?</b><br>\r\nSelecteer ja als u wilt dat deze link in een nieuw opkomend venster geopend wordt.\r\n<p>\r\n\r\n<b>Omschrijving</b><br>\r\nBeschrijf de site waar u naar linkt. Dit kan weggelaten worden als u dat wilt.\r\n<p>\r\n\r\n<b>Nog een link toevoegen?</b><br>\r\nAls u nog een link toe wilt voegen, selecteer dan ja.\r\n<p>\r\n',1031510000);
INSERT INTO international VALUES (73,'FAQ',3,'<b>Vraag</b><br>\r\nVoer de vraag in die u in de FAQ wilt laten verschijnen.\r\n<p>\r\n\r\n\r\n<b>Antwoord</b><br>\r\nVoer het antwoord in voor de vraag die u hierboven heeft ingevuld.\r\n<p>\r\n\r\n\r\n<b>Nog een vraag toevoegen?</b><br>\r\nAls u nog een vraag wilt toevoegen, selecteer dan ja.\r\n<p>\r\n',1031510000);
INSERT INTO international VALUES (73,'EventsCalendar',3,'<b>Titel</b><br>\r\nDe titel voor deze gebeurtenis.\r\n<p>\r\n\r\n<b>Beschrijving</b><br>\r\nOmschrijf de activiteit van deze gebeurtenis of voer informatie in over waar deze gebeurtenis plaatsvind.\r\n<p>\r\n\r\n<b>Begindatum</b><br>\r\nWanneer begint deze gebeurtenis?\r\n<p>\r\n\r\n<b>Einddatum</b><br>\r\nOp welke datum zal deze gebeurtenis plaatsvinden?\r\n<p>\r\n\r\n<b>Gebeurt iedere</b><br>\r\nSelecteer een interval waarin deze gebeurtenis opnieuw plaatsvind.\r\n<p>\r\n\r\n<b>Nog een gebeurtenis toevoegen?</b><br>\r\nAls u nog een gebeurtenis toe wilt voegen, selecteer dan ja.\r\n<p>',1031510000);
INSERT INTO international VALUES (72,'Poll',3,'Antwoorden in willekeurige volgorde weergeven?',1031510000);
INSERT INTO international VALUES (72,'LinkList',3,'Link, Toevoegen/Aanpassen',1031510000);
INSERT INTO international VALUES (72,'FAQ',3,'Vraag, Toevoegen/Aanpasssen',1031510000);
INSERT INTO international VALUES (72,'DownloadManager',3,'Download, Toevoegen/Aanpassen',1031510000);
INSERT INTO international VALUES (717,'WebGUI',3,'Uitloggen',1031510000);
INSERT INTO international VALUES (716,'WebGUI',3,'Inloggen',1031510000);
INSERT INTO international VALUES (715,'WebGUI',3,'Redirect URL',1031510000);
INSERT INTO international VALUES (714,'WebGUI',3,'Sjabloonbeheer groep',1031510000);
INSERT INTO international VALUES (713,'WebGUI',3,'Stijlbeheer groep',1031510000);
INSERT INTO international VALUES (711,'WebGUI',3,'Plaatjesbeheer groep',1031510000);
INSERT INTO international VALUES (710,'WebGUI',3,'Pas privilege instellingen aan',1031510000);
INSERT INTO international VALUES (654,'WebGUI',3,'Stijl, Verwijder',1031510000);
INSERT INTO international VALUES (471,'WebGUI',3,'Pas gebruikers profielveld aan',1031510000);
INSERT INTO international VALUES (36,'Product',3,'Voeg een accesoire toe',1031510000);
INSERT INTO international VALUES (585,'WebGUI',3,'Beheer vertalingen.',1031510000);
INSERT INTO international VALUES (708,'WebGUI',3,'Privilege instellingen, Beheren',1031510000);
INSERT INTO international VALUES (707,'WebGUI',3,'Laat debugging zien?',1031510000);
INSERT INTO international VALUES (706,'WebGUI',3,'Uren',1031510000);
INSERT INTO international VALUES (705,'WebGUI',3,'Minuten',1031510000);
INSERT INTO international VALUES (704,'WebGUI',3,'Seconden',1031510000);
INSERT INTO international VALUES (703,'WebGUI',3,'Jaren',1031510000);
INSERT INTO international VALUES (702,'WebGUI',3,'Maanden',1031510000);
INSERT INTO international VALUES (7,'Product',3,'Product plaatje 1',1031510000);
INSERT INTO international VALUES (5,'WobjectProxy',3,'Wobject proxy, Toevoegen/aanpassen',1031510000);
INSERT INTO international VALUES (699,'WebGUI',3,'Eerste dag van de week',1031510000);
INSERT INTO international VALUES (696,'WebGUI',3,'Prullenbak, Legen',1031510000);
INSERT INTO international VALUES (697,'WebGUI',3,'Karma, Gebruiken',1031510000);
INSERT INTO international VALUES (686,'WebGUI',3,'Plaatjesgroep, Toevoegen',1031510000);
INSERT INTO international VALUES (685,'WebGUI',3,'Sjabloon, verwijderen',1031510000);
INSERT INTO international VALUES (684,'WebGUI',3,'Template, Toevoegen/aanpassen',1031510000);
INSERT INTO international VALUES (598,'WebGUI',3,'Taal aanpassen.',1031510000);
INSERT INTO international VALUES (596,'WebGUI',3,'NIET AANWEZIG',1031510000);
INSERT INTO international VALUES (605,'WebGUI',3,'Voeg groepen toe',1031510000);
INSERT INTO international VALUES (601,'WebGUI',3,'International ID',1031510000);
INSERT INTO international VALUES (597,'WebGUI',3,'Pas internationaal bericht aan',1031510000);
INSERT INTO international VALUES (594,'WebGUI',3,'Vertaal internationale berichten',1031510000);
INSERT INTO international VALUES (593,'WebGUI',3,'Verstuur vertaling naar Plain Black',1031510000);
INSERT INTO international VALUES (595,'WebGUI',3,'Internationale berichten',1031510000);
INSERT INTO international VALUES (591,'WebGUI',3,'Taal',1031510000);
INSERT INTO international VALUES (590,'WebGUI',3,'Taal ID',1031510000);
INSERT INTO international VALUES (589,'WebGUI',3,'Pas taal aan',1031510000);
INSERT INTO international VALUES (586,'WebGUI',3,'Talen',1031510000);
INSERT INTO international VALUES (584,'WebGUI',3,'Voeg een nieuwe taal toe',1031510000);
INSERT INTO international VALUES (575,'WebGUI',3,'Pas aan',1031510000);
INSERT INTO international VALUES (576,'WebGUI',3,'Verwijder',1031510000);
INSERT INTO international VALUES (582,'WebGUI',3,'Laat leeg',1031510000);
INSERT INTO international VALUES (683,'WebGUI',3,'Sjablonen, beheer',1031510000);
INSERT INTO international VALUES (682,'WebGUI',3,'Gebruikersprofiel, Aanpassen',1031510000);
INSERT INTO international VALUES (681,'WebGUI',3,'Pakketten, Maken',1031510000);
INSERT INTO international VALUES (680,'WebGUI',3,'Pakket, Toevoegen',1031510000);
INSERT INTO international VALUES (679,'WebGUI',3,'Inhoudsinstellingen, Aanpassen',1031510000);
INSERT INTO international VALUES (677,'WebGUI',3,'Wobject, Toevoegen/Aanpassen',1031510000);
INSERT INTO international VALUES (1,'MailForm',3,'E-mail formulier',1031510000);
INSERT INTO international VALUES (10,'MailForm',3,'Van',1031510000);
INSERT INTO international VALUES (11,'MailForm',3,'Aan (email, gebruikersnaam of groepsnaam)',1031510000);
INSERT INTO international VALUES (23,'MailForm',3,'Type',1031510000);
INSERT INTO international VALUES (13,'MailForm',3,'Bcc (Onzichtbare kopie naar)',1031510000);
INSERT INTO international VALUES (12,'MailForm',3,'Cc (Kopie naar)',1031510000);
INSERT INTO international VALUES (22,'MailForm',3,'Status',1031510000);
INSERT INTO international VALUES (21,'MailForm',3,'Veldnaam',1031510000);
INSERT INTO international VALUES (20,'MailForm',3,'Pas veld aan',1031510000);
INSERT INTO international VALUES (2,'MailForm',3,'Uw email onderwerp hier',1031510000);
INSERT INTO international VALUES (14,'MailForm',3,'Onderwerp',1031510000);
INSERT INTO international VALUES (15,'MailForm',3,'Doorgaan met meer velden toevoegen?',1031510000);
INSERT INTO international VALUES (18,'MailForm',3,'Ga terug!',1031510000);
INSERT INTO international VALUES (16,'MailForm',3,'Bevestigingsbericht',1031510000);
INSERT INTO international VALUES (17,'MailForm',3,'Mail is verstuurd',1031510000);
INSERT INTO international VALUES (19,'MailForm',3,'Weet u zeker dat u dit veld wilt verwijderen?',1031510000);
INSERT INTO international VALUES (61,'Article',3,'Artikel, Toevoegen/Aanpassen',1031510000);
INSERT INTO international VALUES (24,'MailForm',3,'Mogelijke waarden (alleen voor \'drop-down box\')',1031510000);
INSERT INTO international VALUES (25,'MailForm',3,'Standaard waarde (optioneel)',1031510000);
INSERT INTO international VALUES (7,'MailForm',3,'Pas email formulier aan',1031510000);
INSERT INTO international VALUES (6,'MailForm',3,'Aanpasbaar',1031510000);
INSERT INTO international VALUES (62,'MailForm',3,'Email formulier velden, toevoegen/aanpassen',1031510000);
INSERT INTO international VALUES (61,'MailForm',3,'Email formulier, toevoegen/aanpassen',1031510000);
INSERT INTO international VALUES (5,'MailForm',3,'Zichtbaar(niet aanpasbaar)',1031510000);
INSERT INTO international VALUES (4,'MailForm',3,'Verborgen',1031510000);
INSERT INTO international VALUES (26,'MailForm',3,'Inzendingen opslaan?',1031510000);
INSERT INTO international VALUES (3,'MailForm',3,'Bedankt voor uw bericht!',1031510000);
INSERT INTO international VALUES (588,'WebGUI',3,'Weet u zeker dat u deze vertaling naar Plain Black wilt versturen voor bundeling in de standaarddistributie? Door op de \'ja\' link te klikken snapt u dat u Plain Black een onbeperkte licentie geeft om de vertaling in haar software verspreidingen te gebruiken.',1031510000);
INSERT INTO international VALUES (581,'WebGUI',3,'Voeg een nieuwe waarde toe',1031510000);
INSERT INTO international VALUES (543,'WebGUI',3,'Voeg een nieuwe plaatjesgroep toe.',1031510000);
INSERT INTO international VALUES (583,'WebGUI',3,'Maximale plaatjesgrootte',1031510000);
INSERT INTO international VALUES (547,'WebGUI',3,'Ouder groep',1031510000);
INSERT INTO international VALUES (546,'WebGUI',3,'Groep Id',1031510000);
INSERT INTO international VALUES (542,'WebGUI',3,'Vorige..',1031510000);
INSERT INTO international VALUES (544,'WebGUI',3,'Weet u zeker dat u deze groep wilt verwijderen? ',1031510000);
INSERT INTO international VALUES (5,'UserSubmission',9,'±zªº±i¶K¤å³¹³Q©Úµ´',1031510000);
INSERT INTO international VALUES (5,'SyndicatedContent',9,'³Ì«á´£¨ú¤_',1031510000);
INSERT INTO international VALUES (5,'SQLReport',9,'DSN',1031510000);
INSERT INTO international VALUES (5,'SiteMap',9,'½s¿èºô¯¸¦a¹Ï',1031510000);
INSERT INTO international VALUES (5,'Poll',9,'¹Ï§Î¼e«×',1031510000);
INSERT INTO international VALUES (5,'MessageBoard',9,'½s¿è¶W®É',1031510000);
INSERT INTO international VALUES (5,'LinkList',9,'¬O§_°õ¦æ¼W¥[¶W³sµ²',1031510000);
INSERT INTO international VALUES (5,'Item',9,'¤U¸üªþ¥ó',1031510000);
INSERT INTO international VALUES (5,'FAQ',9,'°ÝÃD',1031510000);
INSERT INTO international VALUES (5,'ExtraColumn',9,'Style Class',1031510000);
INSERT INTO international VALUES (5,'EventsCalendar',9,'¤Ñ',1031510000);
INSERT INTO international VALUES (20,'EventsCalendar',9,'¼W¥[¨Æ°È',1031510000);
INSERT INTO international VALUES (38,'UserSubmission',9,'(¦pªG±z¨Ï¥Î¤F¶W¤å¥»»y¨¥¡A½Ð¿ï¾Ü¡§§_Çµz)',1031510000);
INSERT INTO international VALUES (4,'WebGUI',9,'ºÞ²z³]¸m',1031510000);
INSERT INTO international VALUES (4,'UserSubmission',9,'±zªº±i¶K¤å³¹¤w³q¹L¼f®Ö',1031510000);
INSERT INTO international VALUES (4,'SyndicatedContent',9,'½s¿è¦P¨B¤º®e',1031510000);
INSERT INTO international VALUES (4,'SQLReport',9,'¬d¸ß',1031510000);
INSERT INTO international VALUES (4,'SiteMap',9,'®i¶}²`«×',1031510000);
INSERT INTO international VALUES (4,'Poll',9,'§ë²¼Åv­­',1031510000);
INSERT INTO international VALUES (4,'MessageBoard',9,'¨C­¶Åã¥Ü',1031510000);
INSERT INTO international VALUES (4,'LinkList',9,'«eºó¦r²Å',1031510000);
INSERT INTO international VALUES (4,'Item',9,'¶µ¥Ø',1031510000);
INSERT INTO international VALUES (4,'ExtraColumn',9,'¼e«×',1031510000);
INSERT INTO international VALUES (4,'EventsCalendar',9,'¥uµo¥Í¤@¦¸',1031510000);
INSERT INTO international VALUES (4,'Article',9,'µ²§ô¤é´Á',1031510000);
INSERT INTO international VALUES (3,'WebGUI',9,'±q°Å¶KªO¤¤Öß¶K...',1031510000);
INSERT INTO international VALUES (3,'UserSubmission',9,'±z¦³¤@½g·sªº¨Ï¥ÎªÌ±i¶K¤å³¹µ¥«Ý¼f®Ö',1031510000);
INSERT INTO international VALUES (3,'SQLReport',9,'³ø§i¼ÒªO',1031510000);
INSERT INTO international VALUES (3,'SiteMap',9,'¬O§_±q¦¹¯Å§O¶}©l',1031510000);
INSERT INTO international VALUES (3,'Poll',9,'¿E¬¡',1031510000);
INSERT INTO international VALUES (3,'MessageBoard',9,'µoªíÅv­­',1031510000);
INSERT INTO international VALUES (3,'LinkList',9,'¬O§_¦b·sµ¡¤f¤¤¥´¶}',1031510000);
INSERT INTO international VALUES (3,'Item',9,'§R°£ªþ¥ó',1031510000);
INSERT INTO international VALUES (3,'ExtraColumn',9,'ªÅ¥Õ',1031510000);
INSERT INTO international VALUES (3,'Article',9,'¶}©l¤é´Á',1031510000);
INSERT INTO international VALUES (2,'WebGUI',9,'­¶',1031510000);
INSERT INTO international VALUES (2,'UserSubmission',9,'±i¶K¤å³¹Åv­­',1031510000);
INSERT INTO international VALUES (2,'SyndicatedContent',9,'¦P¨B¤º®e',1031510000);
INSERT INTO international VALUES (2,'SiteMap',9,'ºô¯¸¦a¹Ï',1031510000);
INSERT INTO international VALUES (2,'MessageBoard',9,'¤½§iÄæ',1031510000);
INSERT INTO international VALUES (2,'LinkList',9,'¦æ¶¡¶Z',1031510000);
INSERT INTO international VALUES (2,'Item',9,'ªþ¥ó',1031510000);
INSERT INTO international VALUES (2,'FAQ',9,'F.A.Q.',1031510000);
INSERT INTO international VALUES (2,'EventsCalendar',9,'¦æ¨Æ¾ä',1031510000);
INSERT INTO international VALUES (507,'WebGUI',9,'½s¿è¼ÒªO',1031510000);
INSERT INTO international VALUES (1,'WebGUI',9,'¼W¥[¤º®e...',1031510000);
INSERT INTO international VALUES (1,'UserSubmission',9,'¼f®ÖÅv­­',1031510000);
INSERT INTO international VALUES (1,'SyndicatedContent',9,'RSS ¤å¥ó¶W³sµ²',1031510000);
INSERT INTO international VALUES (1,'SQLReport',9,'SQL ³ø§i',1031510000);
INSERT INTO international VALUES (1,'Poll',9,'½Õ¬d',1031510000);
INSERT INTO international VALUES (1,'LinkList',9,'ÁY¶i',1031510000);
INSERT INTO international VALUES (1,'Item',9,'¶W³sµ² URL',1031510000);
INSERT INTO international VALUES (1,'FAQ',9,'¬O§_°õ¦æ¼W¥[°ÝÃD',1031510000);
INSERT INTO international VALUES (1,'ExtraColumn',9,'ÂX®i¦C',1031510000);
INSERT INTO international VALUES (1,'EventsCalendar',9,'¬O§_°õ¦æ¼W¥[¨Æ°È',1031510000);
INSERT INTO international VALUES (1,'Article',9,'¤å³¹',1031510000);
INSERT INTO international VALUES (367,'WebGUI',9,'¹L´Á®É¶¡',1031510000);
INSERT INTO international VALUES (5,'WebGUI',9,'ºÞ²z¨Ï¥ÎªÌ²Õ',1031510000);
INSERT INTO international VALUES (6,'Article',9,'¹Ï¤ù',1031510000);
INSERT INTO international VALUES (6,'EventsCalendar',9,'¬P´Á',1031510000);
INSERT INTO international VALUES (6,'ExtraColumn',9,'½s¿èÂX®i¦C',1031510000);
INSERT INTO international VALUES (6,'FAQ',9,'¦^µª',1031510000);
INSERT INTO international VALUES (6,'LinkList',9,'¶W³sµ²¦Cªí',1031510000);
INSERT INTO international VALUES (6,'MessageBoard',9,'½s¿è¤½§iÄæ',1031510000);
INSERT INTO international VALUES (6,'Poll',9,'°ÝÃD',1031510000);
INSERT INTO international VALUES (6,'SiteMap',9,'ÁY¶i',1031510000);
INSERT INTO international VALUES (6,'SQLReport',9,'¸ê®Æ®w¨Ï¥ÎªÌ',1031510000);
INSERT INTO international VALUES (6,'SyndicatedContent',9,'·í«e¤º®e',1031510000);
INSERT INTO international VALUES (6,'UserSubmission',9,'¨C­¶±i¶K¤å³¹¼Æ',1031510000);
INSERT INTO international VALUES (6,'WebGUI',9,'ºÞ²zStyle',1031510000);
INSERT INTO international VALUES (7,'Article',9,'³s±µ¼ÐÃD',1031510000);
INSERT INTO international VALUES (7,'FAQ',9,'±z¬O§_½T©w±z­n§R°£³o­Ó°ÝÃD',1031510000);
INSERT INTO international VALUES (7,'MessageBoard',9,'§@ªÌ¡G',1031510000);
INSERT INTO international VALUES (7,'Poll',9,'¦^µª',1031510000);
INSERT INTO international VALUES (7,'SiteMap',9,'«eºó¦r²Å',1031510000);
INSERT INTO international VALUES (7,'SQLReport',9,'¸ê®Æ®w±K½X',1031510000);
INSERT INTO international VALUES (7,'UserSubmission',9,'³q¹L',1031510000);
INSERT INTO international VALUES (7,'WebGUI',9,'ºÞ²z¨Ï¥ÎªÌ',1031510000);
INSERT INTO international VALUES (8,'Article',9,'¶W³sµ² URL',1031510000);
INSERT INTO international VALUES (8,'EventsCalendar',9,'­«ÂÐ©P´Á',1031510000);
INSERT INTO international VALUES (8,'FAQ',9,'½s¿è F.A.Q.',1031510000);
INSERT INTO international VALUES (8,'LinkList',9,'URL',1031510000);
INSERT INTO international VALUES (8,'MessageBoard',9,'¤é´Á¡G',1031510000);
INSERT INTO international VALUES (8,'Poll',9,'¡]¨C¦æ¿é¤J¤@±øµª®×¡C³Ì¦h¤£¶W¹L20±ø¡C¡^',1031510000);
INSERT INTO international VALUES (9,'MessageBoard',9,'¤å³¹ ID:',1031510000);
INSERT INTO international VALUES (11,'MessageBoard',9,'ªð¦^¤å³¹¦Cªí',1031510000);
INSERT INTO international VALUES (12,'MessageBoard',9,'½s¿è¤å³¹',1031510000);
INSERT INTO international VALUES (13,'MessageBoard',9,'µoªí¦^ÂÐ',1031510000);
INSERT INTO international VALUES (15,'MessageBoard',9,'§@ªÌ',1031510000);
INSERT INTO international VALUES (16,'MessageBoard',9,'¤é´Á',1031510000);
INSERT INTO international VALUES (17,'MessageBoard',9,'µoªí·s¤å³¹',1031510000);
INSERT INTO international VALUES (18,'MessageBoard',9,'½u¯Á¶}©l',1031510000);
INSERT INTO international VALUES (19,'MessageBoard',9,'¦^ÂÐ',1031510000);
INSERT INTO international VALUES (20,'MessageBoard',9,'³Ì«á¦^ÂÐ',1031510000);
INSERT INTO international VALUES (21,'MessageBoard',9,'ºÞ²zÅv­­',1031510000);
INSERT INTO international VALUES (22,'MessageBoard',9,'§R°£¤å³¹',1031510000);
INSERT INTO international VALUES (9,'Poll',9,'½s¿è½Õ¬d',1031510000);
INSERT INTO international VALUES (10,'Poll',9,'ªì©l¤Æ§ë²¼',1031510000);
INSERT INTO international VALUES (11,'Poll',9,'§ë²¼¡I',1031510000);
INSERT INTO international VALUES (8,'SiteMap',9,'¦æ¶Z',1031510000);
INSERT INTO international VALUES (8,'SQLReport',9,'Edit SQL Report',1031510000);
INSERT INTO international VALUES (8,'UserSubmission',9,'³Q©Úµ´',1031510000);
INSERT INTO international VALUES (8,'WebGUI',9,'±z¬d¬Ýªº­¶­±¤£¦s¦b',1031510000);
INSERT INTO international VALUES (9,'Article',9,'ªþ¥ó',1031510000);
INSERT INTO international VALUES (9,'EventsCalendar',9,'ª½¨ì',1031510000);
INSERT INTO international VALUES (9,'FAQ',9,'¼W¥[·s°ÝÃD',1031510000);
INSERT INTO international VALUES (9,'LinkList',9,'±z¬O§_½T©w­n§R°£¦¹¶W³sµ²',1031510000);
INSERT INTO international VALUES (9,'SQLReport',9,'<b>Debug:</b> Error: The DSN specified is of an improper format.',1031510000);
INSERT INTO international VALUES (9,'UserSubmission',9,'¼f®Ö¤¤',1031510000);
INSERT INTO international VALUES (9,'WebGUI',9,'¬d¬Ý°Å¶KªO',1031510000);
INSERT INTO international VALUES (10,'Article',9,'¬O§_Âà´«¦^¨®²Å',1031510000);
INSERT INTO international VALUES (10,'EventsCalendar',9,'±z¬O§_½T©w­n§R°£¦¹¶µ¨Æ°È',1031510000);
INSERT INTO international VALUES (10,'FAQ',9,'½s¿è°ÝÃD',1031510000);
INSERT INTO international VALUES (10,'LinkList',9,'½s¿è¶W³sµ²¦Cªí',1031510000);
INSERT INTO international VALUES (10,'SQLReport',9,'<b>Debug:</b> Error: The SQL specified is of an improper format.',1031510000);
INSERT INTO international VALUES (10,'UserSubmission',9,'Àq»{ª¬ºA',1031510000);
INSERT INTO international VALUES (10,'WebGUI',9,'ºÞ²z©U§£±í',1031510000);
INSERT INTO international VALUES (11,'Article',9,'(¦pªG±z¨S¦³¤â°Ê¿é¤J&lt;br&gt;¡A½Ð¿ï¾Ü¡§¬O\")',1031510000);
INSERT INTO international VALUES (11,'EventsCalendar',9,'<b>©M</b>©Ò¦³¬ÛÃö¨Æ°È',1031510000);
INSERT INTO international VALUES (11,'SQLReport',9,'<b>Debug:</b> Error: There was a problem with the query.',1031510000);
INSERT INTO international VALUES (11,'WebGUI',9,'²MªÅ©U§£±í',1031510000);
INSERT INTO international VALUES (12,'Article',9,'½s¿è¤å³¹',1031510000);
INSERT INTO international VALUES (12,'EventsCalendar',9,'½s¿è¦æ¨Æ¾ä',1031510000);
INSERT INTO international VALUES (12,'LinkList',9,'½s¿è¶W³sµ²',1031510000);
INSERT INTO international VALUES (12,'SQLReport',9,'<b>Debug:</b> Error: Could not connect to the database.',1031510000);
INSERT INTO international VALUES (12,'UserSubmission',9,'(¦pªG±z¨Ï¥Î¤F¶W¤å¥»»y¨¥¡A½Ð¤£­n¿ï¾Ü¦¹¶µ)',1031510000);
INSERT INTO international VALUES (12,'WebGUI',9,'°h¥XºÞ²z',1031510000);
INSERT INTO international VALUES (13,'Article',9,'§R°£',1031510000);
INSERT INTO international VALUES (13,'EventsCalendar',9,'½s¿è¨Æ°È',1031510000);
INSERT INTO international VALUES (13,'LinkList',9,'¼W¥[·s¶W³sµ²',1031510000);
INSERT INTO international VALUES (13,'UserSubmission',9,'±i¶K¤å³¹®É¶¡',1031510000);
INSERT INTO international VALUES (13,'WebGUI',9,'¬d¬ÝÀ°§U¯Á¤Þ',1031510000);
INSERT INTO international VALUES (14,'Article',9,'¹Ï¤ù¦ì¸m',1031510000);
INSERT INTO international VALUES (516,'WebGUI',9,'¶i¤JºÞ²z',1031510000);
INSERT INTO international VALUES (517,'WebGUI',9,'°h¥XºÞ²z',1031510000);
INSERT INTO international VALUES (515,'WebGUI',9,'¬O§_¼W¥[½s¿èÂW',1031510000);
INSERT INTO international VALUES (14,'UserSubmission',9,'ª¬ºA',1031510000);
INSERT INTO international VALUES (14,'WebGUI',9,'¬d¬Ýµ¥«Ý¼f®Öªº±i¶K¤å³¹',1031510000);
INSERT INTO international VALUES (15,'UserSubmission',9,'½s¿è/§R°£',1031510000);
INSERT INTO international VALUES (15,'WebGUI',9,'¤@¤ë',1031510000);
INSERT INTO international VALUES (16,'UserSubmission',9,'µL¼ÐÃD',1031510000);
INSERT INTO international VALUES (16,'WebGUI',9,'¤G¤ë',1031510000);
INSERT INTO international VALUES (17,'UserSubmission',9,'±z½T©w­n§R°£¦¹½Z¥ó¶Ü',1031510000);
INSERT INTO international VALUES (17,'WebGUI',9,'¤T¤ë',1031510000);
INSERT INTO international VALUES (18,'UserSubmission',9,'½s¿è¨Ï¥ÎªÌ±i¶K¤å³¹¨t²Î',1031510000);
INSERT INTO international VALUES (18,'WebGUI',9,'¥|¤ë',1031510000);
INSERT INTO international VALUES (19,'UserSubmission',9,'½s¿è±i¶K¤å³¹',1031510000);
INSERT INTO international VALUES (19,'WebGUI',9,'¤­¤ë',1031510000);
INSERT INTO international VALUES (20,'UserSubmission',9,'§Ú­n±i¶K¤å³¹',1031510000);
INSERT INTO international VALUES (20,'WebGUI',9,'¤»¤ë',1031510000);
INSERT INTO international VALUES (21,'UserSubmission',9,'µoªí¤H',1031510000);
INSERT INTO international VALUES (21,'WebGUI',9,'¤C¤ë',1031510000);
INSERT INTO international VALUES (22,'UserSubmission',9,'µoªí¤H¡G',1031510000);
INSERT INTO international VALUES (22,'WebGUI',9,'¤K¤ë',1031510000);
INSERT INTO international VALUES (23,'UserSubmission',9,'±i¶K¤å³¹®É¶¡',1031510000);
INSERT INTO international VALUES (23,'WebGUI',9,'¤E¤ë',1031510000);
INSERT INTO international VALUES (24,'UserSubmission',9,'³q¹L',1031510000);
INSERT INTO international VALUES (24,'WebGUI',9,'¤Q¤ë',1031510000);
INSERT INTO international VALUES (25,'UserSubmission',9,'Ä~Äò¼f®Ö',1031510000);
INSERT INTO international VALUES (25,'WebGUI',9,'¤Q¤@¤ë',1031510000);
INSERT INTO international VALUES (26,'UserSubmission',9,'©Úµ´',1031510000);
INSERT INTO international VALUES (26,'WebGUI',9,'¤Q¤G¤ë',1031510000);
INSERT INTO international VALUES (27,'UserSubmission',9,'½s¿è',1031510000);
INSERT INTO international VALUES (27,'WebGUI',9,'¬P´Á¤é',1031510000);
INSERT INTO international VALUES (28,'UserSubmission',9,'ªð¦^½Z¥ó¦Cªí',1031510000);
INSERT INTO international VALUES (28,'WebGUI',9,'¬P´Á¤@',1031510000);
INSERT INTO international VALUES (29,'UserSubmission',9,'¨Ï¥ÎªÌ±i¶K¤å³¹¨t²Î',1031510000);
INSERT INTO international VALUES (29,'WebGUI',9,'¬P´Á¤G',1031510000);
INSERT INTO international VALUES (30,'WebGUI',9,'¬P´Á¤T',1031510000);
INSERT INTO international VALUES (31,'WebGUI',9,'¬P´Á¥|',1031510000);
INSERT INTO international VALUES (32,'WebGUI',9,'¬P´Á¤­',1031510000);
INSERT INTO international VALUES (33,'WebGUI',9,'¬P´Á¤»',1031510000);
INSERT INTO international VALUES (34,'WebGUI',9,'³]¸m¤é´Á',1031510000);
INSERT INTO international VALUES (35,'WebGUI',9,'ºÞ²z¥¯à',1031510000);
INSERT INTO international VALUES (36,'WebGUI',9,'±z¥²¶·¬O¨t²ÎºÞ²z­û¤~¯à¨Ï¥Î¦¹¥¯à¡C½ÐÁp¨t±zªº¨t²ÎºÞ²z­û¡C¥H¤U¬O¥»¨t²Îªº¨t²ÎºÞ²z­û²M³æ¡G',1031510000);
INSERT INTO international VALUES (37,'WebGUI',9,'Åv­­³Q©Úµ´¡I',1031510000);
INSERT INTO international VALUES (404,'WebGUI',9,'²Ä¤@­¶',1031510000);
INSERT INTO international VALUES (38,'WebGUI',9,'±z¨S¦³¨¬°÷ªºÅv­­°õ¦æ¦¹¶µ¾Þ§@¡C½Ð^a(µn¿ý);µM«á¦A¸Õ¤@¦¸',1031510000);
INSERT INTO international VALUES (39,'WebGUI',9,'¹ï¤£°_¡A±z¨S¦³¨¬°÷ªºÅv­­³X°Ý¤@­¶',1031510000);
INSERT INTO international VALUES (40,'WebGUI',9,'¨t²Î²Õ¥ó',1031510000);
INSERT INTO international VALUES (41,'WebGUI',9,'±z±N­n§R°£¤@­Ó¨t²Î²Õ¥ó¡C¦pªG±zÄ~Äò¡A¨t²Î¥¯à¥i¯à·|¨ü¨ì¼vÅT',1031510000);
INSERT INTO international VALUES (42,'WebGUI',9,'½Ð½T»{',1031510000);
INSERT INTO international VALUES (43,'WebGUI',9,'±z¬O§_½T©w­n§R°£¦¹¤º®e¶Ü',1031510000);
INSERT INTO international VALUES (44,'WebGUI',9,'¬Oªº¡A§Ú½T©w',1031510000);
INSERT INTO international VALUES (45,'WebGUI',9,'¤£¡A§Ú«ö¿ù¤F',1031510000);
INSERT INTO international VALUES (46,'WebGUI',9,'§Úªº±b¤á',1031510000);
INSERT INTO international VALUES (47,'WebGUI',9,'­º­¶',1031510000);
INSERT INTO international VALUES (48,'WebGUI',9,'Åwªï¡I',1031510000);
INSERT INTO international VALUES (49,'WebGUI',9,'ÂIÀ» <a href=\"^;?op=logout\">¦¹³B</a> °h¥Xµn¿ý',1031510000);
INSERT INTO international VALUES (50,'WebGUI',9,'±b¤á',1031510000);
INSERT INTO international VALUES (51,'WebGUI',9,'±K½X',1031510000);
INSERT INTO international VALUES (52,'WebGUI',9,'µn¿ý',1031510000);
INSERT INTO international VALUES (53,'WebGUI',9,'¥´¦L¥»­¶',1031510000);
INSERT INTO international VALUES (54,'WebGUI',9,'·s«Ø±b¤á',1031510000);
INSERT INTO international VALUES (55,'WebGUI',9,'±K½X¡]½T»{¡^',1031510000);
INSERT INTO international VALUES (56,'WebGUI',9,'¹q¤l¶l¥ó',1031510000);
INSERT INTO international VALUES (57,'WebGUI',9,'¦¹¶µ¥u¦b±z§Æ±æ¨Ï¥Î¨ì»Ý­n¹q¤l¶l¥óªº¥¯àªº®É­Ô¦³¥Î',1031510000);
INSERT INTO international VALUES (58,'WebGUI',9,'§Ú¤w¸g¦³¤F¤@­Ó±b¤á',1031510000);
INSERT INTO international VALUES (59,'WebGUI',9,'§Ú§Ñ°O¤F±K½X',1031510000);
INSERT INTO international VALUES (60,'WebGUI',9,'±z¬O§_¯uªº§Æ±æµù¾P±zªº±b¤á¡H¦pªG±zÄ~Äò¡A±zªº±b¤á¸ê°T±N³Q¥Ã¤[§R°£',1031510000);
INSERT INTO international VALUES (61,'WebGUI',9,'§ó·s±b¤á¸ê°T',1031510000);
INSERT INTO international VALUES (62,'WebGUI',9,'«O¦s',1031510000);
INSERT INTO international VALUES (63,'WebGUI',9,'¶i¤JºÞ²z',1031510000);
INSERT INTO international VALUES (64,'WebGUI',9,'°h¥Xµn¿ý',1031510000);
INSERT INTO international VALUES (65,'WebGUI',9,'½Ð§R°£§Úªº±b¤á',1031510000);
INSERT INTO international VALUES (66,'WebGUI',9,'¨Ï¥ÎªÌµn¿ý',1031510000);
INSERT INTO international VALUES (67,'WebGUI',9,'³Ð«Ø·s±b¤á',1031510000);
INSERT INTO international VALUES (68,'WebGUI',9,'±z¿é¤Jªº±b¤á¸ê°TµL®Ä¡C¥i¯à¬O±z¿é¤Jªº±b¤á¤£¦s¦b¡A©Î¿é¤J¤F¿ù»~ªº±K½X',1031510000);
INSERT INTO international VALUES (69,'WebGUI',9,'¦pªG±z»Ý­n¨ó§U¡A½ÐÁp¨t¨t²ÎºÞ²z­û',1031510000);
INSERT INTO international VALUES (70,'WebGUI',9,'¿ù»~',1031510000);
INSERT INTO international VALUES (71,'WebGUI',9,'«ìÂÐ±K½X',1031510000);
INSERT INTO international VALUES (72,'WebGUI',9,'«ìÂÐ',1031510000);
INSERT INTO international VALUES (73,'WebGUI',9,'¨Ï¥ÎªÌµn¿ý',1031510000);
INSERT INTO international VALUES (74,'WebGUI',9,'±b¤á¸ê°T',1031510000);
INSERT INTO international VALUES (75,'WebGUI',9,'±zªº±b¤á¸ê°T¤w¸gµo°e¨ì±zªº¹q¤l¶l¥ó¤¤',1031510000);
INSERT INTO international VALUES (76,'WebGUI',9,'¹ï¤£°_¡A¦¹¹q¤l¶l¥ó¦a§}¤£¦b¨t²Î¸ê®Æ®w¤¤',1031510000);
INSERT INTO international VALUES (77,'WebGUI',9,'¹ï¤£°_¡A¦¹±b¤á¦W¤w³Q¨ä¥L¨Ï¥ÎªÌ¨Ï¥Î¡C½Ð¥t¥~¿ï¾Ü¤@­Ó¨Ï¥ÎªÌ¦W¡C§Ú­Ì«ØÄ³±z¨Ï¥Î¥H¤U¦W¦r§@¬°µn¿ý¦W¡G',1031510000);
INSERT INTO international VALUES (78,'WebGUI',9,'±z¿é¤Jªº±K½X¤£¤@­P¡A½Ð­«·s¿é¤J',1031510000);
INSERT INTO international VALUES (79,'WebGUI',9,'¤£¯à³s±µ¨ì¥Ø¿ýªA°È¾¹',1031510000);
INSERT INTO international VALUES (80,'WebGUI',9,'³Ð«Ø±b¤á¦¨¥¡I',1031510000);
INSERT INTO international VALUES (81,'WebGUI',9,'§ó·s±b¤á¦¨¥¡I',1031510000);
INSERT INTO international VALUES (82,'WebGUI',9,'ºÞ²z¥¯à...',1031510000);
INSERT INTO international VALUES (536,'WebGUI',9,'·s¨Ï¥ÎªÌ ^@; ­è¥[¤J¥»¯¸',1031510000);
INSERT INTO international VALUES (84,'WebGUI',9,'¨Ï¥ÎªÌ²Õ',1031510000);
INSERT INTO international VALUES (85,'WebGUI',9,'´y­z',1031510000);
INSERT INTO international VALUES (86,'WebGUI',9,'±z½T©w­n§R°£¦¹¨Ï¥ÎªÌ²Õ¶Ü¡H¦¹¶µ¾Þ§@±N¥Ã¤[§R°£¦¹¨Ï¥ÎªÌ²Õ¡A¦}¨ú®ø¦¹¨Ï¥ÎªÌ²Õ©Ò¦³¬ÛÃöÅv­­',1031510000);
INSERT INTO international VALUES (87,'WebGUI',9,'½s¿è¨Ï¥ÎªÌ²Õ',1031510000);
INSERT INTO international VALUES (88,'WebGUI',9,'¨Ï¥ÎªÌ²Õ¦¨­û',1031510000);
INSERT INTO international VALUES (89,'WebGUI',9,'¨Ï¥ÎªÌ²Õ',1031510000);
INSERT INTO international VALUES (90,'WebGUI',9,'¼W¥[·s²Õ',1031510000);
INSERT INTO international VALUES (91,'WebGUI',9,'¤W¤@­¶',1031510000);
INSERT INTO international VALUES (92,'WebGUI',9,'¤U¤@­¶',1031510000);
INSERT INTO international VALUES (93,'WebGUI',9,'À°§U',1031510000);
INSERT INTO international VALUES (94,'WebGUI',9,'°Ñ¦Ò',1031510000);
INSERT INTO international VALUES (95,'WebGUI',9,'À°§U¯Á¤Þ',1031510000);
INSERT INTO international VALUES (99,'WebGUI',9,'¼ÐÃD',1031510000);
INSERT INTO international VALUES (100,'WebGUI',9,'Meta ¼ÐÃÑ',1031510000);
INSERT INTO international VALUES (101,'WebGUI',9,'±z½T©w­n§R°£¦¹­¶­±¥H¤Î­¶­±¤ºªº©Ò¦³¤º®e©M²Õ¥ó¶Ü',1031510000);
INSERT INTO international VALUES (102,'WebGUI',9,'½s¿è­¶­±',1031510000);
INSERT INTO international VALUES (103,'WebGUI',9,'­¶­±´y­z',1031510000);
INSERT INTO international VALUES (104,'WebGUI',9,'­¶­± URL',1031510000);
INSERT INTO international VALUES (105,'WebGUI',9,'­·®æ',1031510000);
INSERT INTO international VALUES (106,'WebGUI',9,'Select \"Yes\" to change all the pages under this page to this style.',1031510000);
INSERT INTO international VALUES (107,'WebGUI',9,'Åv­­³]¸m',1031510000);
INSERT INTO international VALUES (108,'WebGUI',9,'¾Ö¦³ªÌ',1031510000);
INSERT INTO international VALUES (109,'WebGUI',9,'¾Ö¦³ªÌ³X°ÝÅv­­',1031510000);
INSERT INTO international VALUES (110,'WebGUI',9,'¾Ö¦³ªÌ½s¿èÅv­­',1031510000);
INSERT INTO international VALUES (111,'WebGUI',9,'¨Ï¥ÎªÌ²Õ',1031510000);
INSERT INTO international VALUES (112,'WebGUI',9,'¨Ï¥ÎªÌ²Õ³X°ÝÅv­­',1031510000);
INSERT INTO international VALUES (113,'WebGUI',9,'¨Ï¥ÎªÌ²Õ½s¿èÅv­­',1031510000);
INSERT INTO international VALUES (114,'WebGUI',9,'¥ô¦ó¤H¥i³X°Ý',1031510000);
INSERT INTO international VALUES (115,'WebGUI',9,'¥ô¦ó¤H¥i½s¿è',1031510000);
INSERT INTO international VALUES (116,'WebGUI',9,'Select \"Yes\" to change the privileges of all pages under this page to these privileges.',1031510000);
INSERT INTO international VALUES (117,'WebGUI',9,'½s¿è¨Ï¥ÎªÌ³]¸m',1031510000);
INSERT INTO international VALUES (118,'WebGUI',9,'°Î¦W¨Ï¥ÎªÌµù¥U',1031510000);
INSERT INTO international VALUES (119,'WebGUI',9,'Àq»{¨Ï¥ÎªÌ»{µý¤è¦¡',1031510000);
INSERT INTO international VALUES (120,'WebGUI',9,'Àq»{ LDAP URL',1031510000);
INSERT INTO international VALUES (121,'WebGUI',9,'Àq»{ LDAP Identity',1031510000);
INSERT INTO international VALUES (122,'WebGUI',9,'LDAP Identity ¦W',1031510000);
INSERT INTO international VALUES (123,'WebGUI',9,'LDAP Password ¦W',1031510000);
INSERT INTO international VALUES (124,'WebGUI',9,'½s¿è¤½¥q¸ê°T',1031510000);
INSERT INTO international VALUES (125,'WebGUI',9,'¤½¥q¦W',1031510000);
INSERT INTO international VALUES (126,'WebGUI',9,'¤½¥q¹q¤l¶l¥ó¦a§}',1031510000);
INSERT INTO international VALUES (127,'WebGUI',9,'¤½¥q¶W³sµ²',1031510000);
INSERT INTO international VALUES (130,'WebGUI',9,'³Ì¤jªþ¥ó¤j¤p',1031510000);
INSERT INTO international VALUES (133,'WebGUI',9,'½s¿è¶l¥ó³]¸m',1031510000);
INSERT INTO international VALUES (134,'WebGUI',9,'«ìÂÐ±K½X¶l¥ó¤º®e',1031510000);
INSERT INTO international VALUES (135,'WebGUI',9,'¶l¥óªA°È¾¹',1031510000);
INSERT INTO international VALUES (138,'WebGUI',9,'¬O',1031510000);
INSERT INTO international VALUES (139,'WebGUI',9,'§_',1031510000);
INSERT INTO international VALUES (140,'WebGUI',9,'½s¿è¤@¯ë³]¸m',1031510000);
INSERT INTO international VALUES (141,'WebGUI',9,'Àq»{¥¼§ä¨ì­¶­±',1031510000);
INSERT INTO international VALUES (142,'WebGUI',9,'¹ï¸Ü¶W®É',1031510000);
INSERT INTO international VALUES (143,'WebGUI',9,'ºÞ²z³]¸m',1031510000);
INSERT INTO international VALUES (144,'WebGUI',9,'¬d¬Ý²Î­p¸ê°T',1031510000);
INSERT INTO international VALUES (145,'WebGUI',9,'¨t²Îª©¥»',1031510000);
INSERT INTO international VALUES (146,'WebGUI',9,'¬¡°Ê¹ï¸Ü',1031510000);
INSERT INTO international VALUES (147,'WebGUI',9,'­¶­±¼Æ',1031510000);
INSERT INTO international VALUES (148,'WebGUI',9,'²Õ¥ó¼Æ',1031510000);
INSERT INTO international VALUES (149,'WebGUI',9,'¨Ï¥ÎªÌ¼Æ',1031510000);
INSERT INTO international VALUES (533,'WebGUI',9,'<b>¤£¥]¬A</b>·j¯Á¦r',1031510000);
INSERT INTO international VALUES (532,'WebGUI',9,'¥]¬A<b>¦Ü¤Ö¤@­Ó</b>·j¯Á¦r',1031510000);
INSERT INTO international VALUES (151,'WebGUI',9,'­·®æ¦W',1031510000);
INSERT INTO international VALUES (505,'WebGUI',9,'¼W¥[¤@­Ó·s¼ÒªO',1031510000);
INSERT INTO international VALUES (504,'WebGUI',9,'¼ÒªO',1031510000);
INSERT INTO international VALUES (502,'WebGUI',9,'±z½T©w­n§R°£¦¹¼ÒªO¡A¦}±N©Ò¦³¨Ï¥Î¦¹¼ÒªOªº­¶­±³]¬°Àq»{¼ÒªO',1031510000);
INSERT INTO international VALUES (154,'WebGUI',9,'­·®æ³æ',1031510000);
INSERT INTO international VALUES (155,'WebGUI',9,'±z½T©w­n§R°£¦¹­¶­±­·®æ¡A¦}±N©Ò¦³¨Ï¥Î¦¹­·®æªº­¶­±­·®æ³]¬°¡§¦w¥þ¼Ò¦¡Ç½ãqöôA',1031510000);
INSERT INTO international VALUES (156,'WebGUI',9,'½s¿è­·®æ',1031510000);
INSERT INTO international VALUES (157,'WebGUI',9,'­·®æ',1031510000);
INSERT INTO international VALUES (158,'WebGUI',9,'¼W¥[·s­·®æ',1031510000);
INSERT INTO international VALUES (160,'WebGUI',9,'´£¥æ¤é´Á',1031510000);
INSERT INTO international VALUES (161,'WebGUI',9,'´£¥æ¤H',1031510000);
INSERT INTO international VALUES (162,'WebGUI',9,'±z¬O§_½T©w­n²MªÅ©U§£±í¤¤©Ò¦³­¶­±©M²Õ¥ó¶Ü',1031510000);
INSERT INTO international VALUES (163,'WebGUI',9,'¼W¥[¨Ï¥ÎªÌ',1031510000);
INSERT INTO international VALUES (164,'WebGUI',9,'¨Ï¥ÎªÌ»{µý¤è¦¡',1031510000);
INSERT INTO international VALUES (165,'WebGUI',9,'LDAP URL',1031510000);
INSERT INTO international VALUES (166,'WebGUI',9,'³s±µ DN',1031510000);
INSERT INTO international VALUES (167,'WebGUI',9,'±z¬O§_½T©w­n§R°£¦¹¨Ï¥ÎªÌ¶Ü¡Hª`·N§R°£¨Ï¥ÎªÌ±N¥Ã¤[§R°£¸Ó¨Ï¥ÎªÌªº©Ò¦³¸ê°T',1031510000);
INSERT INTO international VALUES (168,'WebGUI',9,'½s¿è¨Ï¥ÎªÌ',1031510000);
INSERT INTO international VALUES (169,'WebGUI',9,'¼W¥[·s¨Ï¥ÎªÌ',1031510000);
INSERT INTO international VALUES (170,'WebGUI',9,'·j¯Á',1031510000);
INSERT INTO international VALUES (171,'WebGUI',9,'¥iµø¤Æ½s¿è',1031510000);
INSERT INTO international VALUES (174,'WebGUI',9,'¬O§_Åã¥Ü¼ÐÃD',1031510000);
INSERT INTO international VALUES (175,'WebGUI',9,'¬O§_°õ¦æ§»©R¥O',1031510000);
INSERT INTO international VALUES (228,'WebGUI',9,'½s¿è®ø®§...',1031510000);
INSERT INTO international VALUES (229,'WebGUI',9,'¼ÐÃD',1031510000);
INSERT INTO international VALUES (230,'WebGUI',9,'®ø®§',1031510000);
INSERT INTO international VALUES (231,'WebGUI',9,'µo¥¬·s®ø®§...',1031510000);
INSERT INTO international VALUES (232,'WebGUI',9,'µL¼ÐÃD',1031510000);
INSERT INTO international VALUES (233,'WebGUI',9,'(eom)',1031510000);
INSERT INTO international VALUES (234,'WebGUI',9,'µoªí¦^À³...',1031510000);
INSERT INTO international VALUES (237,'WebGUI',9,'¼ÐÃD¡G',1031510000);
INSERT INTO international VALUES (238,'WebGUI',9,'§@ªÌ¡G',1031510000);
INSERT INTO international VALUES (239,'WebGUI',9,'¤é´Á¡G',1031510000);
INSERT INTO international VALUES (240,'WebGUI',9,'®ø®§ ID:',1031510000);
INSERT INTO international VALUES (244,'WebGUI',9,'§@ªÌ',1031510000);
INSERT INTO international VALUES (245,'WebGUI',9,'¤é´Á',1031510000);
INSERT INTO international VALUES (304,'WebGUI',9,'»y¨¥',1031510000);
INSERT INTO international VALUES (306,'WebGUI',9,'¨Ï¥ÎªÌ¦W¸j©w',1031510000);
INSERT INTO international VALUES (307,'WebGUI',9,'¬O§_¨Ï¥ÎÀq»{ meta ¼ÐÃÑ',1031510000);
INSERT INTO international VALUES (308,'WebGUI',9,'½s¿è¨Ï¥ÎªÌÄÝ©Ê³]¸m',1031510000);
INSERT INTO international VALUES (309,'WebGUI',9,'¬O§_¤¹³¨Ï¥Î¯u¹ê©m¦W',1031510000);
INSERT INTO international VALUES (310,'WebGUI',9,'¬O§_¤¹³¨Ï¥ÎÂX®iÁp¨t¸ê°T',1031510000);
INSERT INTO international VALUES (311,'WebGUI',9,'¬O§_¤¹³¨Ï¥Î®a®x¸ê°T',1031510000);
INSERT INTO international VALUES (312,'WebGUI',9,'¬O§_¤¹³¨Ï¥Î°Ó·~¸ê°T',1031510000);
INSERT INTO international VALUES (313,'WebGUI',9,'¬O§_¤¹³¨Ï¥Î¨ä¥L¸ê°T',1031510000);
INSERT INTO international VALUES (314,'WebGUI',9,'©m',1031510000);
INSERT INTO international VALUES (315,'WebGUI',9,'¤¤¶¡¦W',1031510000);
INSERT INTO international VALUES (316,'WebGUI',9,'¦W',1031510000);
INSERT INTO international VALUES (317,'WebGUI',9,'<a href=\"http://www.icq.com\">ICQ</a> UIN',1031510000);
INSERT INTO international VALUES (318,'WebGUI',9,'<a href=\"http://www.aol.com/aim/homenew.adp\">AIM</a> ID',1031510000);
INSERT INTO international VALUES (319,'WebGUI',9,'<a href=\"http://messenger.msn.com/\">MSN Messenger</a> ID',1031510000);
INSERT INTO international VALUES (320,'WebGUI',9,'<a href=\"http://messenger.yahoo.com/\">Yahoo! Messenger</a> ID',1031510000);
INSERT INTO international VALUES (321,'WebGUI',9,'²¾°Ê¹q¸Ü',1031510000);
INSERT INTO international VALUES (322,'WebGUI',9,'¶Ç©I',1031510000);
INSERT INTO international VALUES (323,'WebGUI',9,'®a®x¦í§}',1031510000);
INSERT INTO international VALUES (324,'WebGUI',9,'«°¥«',1031510000);
INSERT INTO international VALUES (325,'WebGUI',9,'¬Ù¥÷',1031510000);
INSERT INTO international VALUES (326,'WebGUI',9,'¶l¬F½s½X',1031510000);
INSERT INTO international VALUES (327,'WebGUI',9,'°ê®a',1031510000);
INSERT INTO international VALUES (328,'WebGUI',9,'¦í¦v¹q¸Ü',1031510000);
INSERT INTO international VALUES (329,'WebGUI',9,'³æ¦ì¦a§}',1031510000);
INSERT INTO international VALUES (330,'WebGUI',9,'«°¥«',1031510000);
INSERT INTO international VALUES (331,'WebGUI',9,'¬Ù¥÷',1031510000);
INSERT INTO international VALUES (332,'WebGUI',9,'¶l¬F½s½X',1031510000);
INSERT INTO international VALUES (333,'WebGUI',9,'°ê®a',1031510000);
INSERT INTO international VALUES (334,'WebGUI',9,'³æ¦ì¹q¸Ü',1031510000);
INSERT INTO international VALUES (335,'WebGUI',9,'©Ê§O',1031510000);
INSERT INTO international VALUES (336,'WebGUI',9,'¥Í¤é',1031510000);
INSERT INTO international VALUES (337,'WebGUI',9,'­Ó¤Hºô­¶',1031510000);
INSERT INTO international VALUES (338,'WebGUI',9,'½s¿è¨Ï¥ÎªÌÄÝ©Ê',1031510000);
INSERT INTO international VALUES (339,'WebGUI',9,'¨k',1031510000);
INSERT INTO international VALUES (340,'WebGUI',9,'¤k',1031510000);
INSERT INTO international VALUES (341,'WebGUI',9,'½s¿è¨Ï¥ÎªÌÄÝ©Ê',1031510000);
INSERT INTO international VALUES (342,'WebGUI',9,'½s¿è±b¤á¸ê°T',1031510000);
INSERT INTO international VALUES (343,'WebGUI',9,'¬d¬Ý¨Ï¥ÎªÌÄÝ©Ê',1031510000);
INSERT INTO international VALUES (351,'WebGUI',9,'®ø®§',1031510000);
INSERT INTO international VALUES (345,'WebGUI',9,'¤£¬O¥»¯¸¨Ï¥ÎªÌ',1031510000);
INSERT INTO international VALUES (346,'WebGUI',9,'¦¹¨Ï¥ÎªÌ¤£¦A¬O¥»¯¸¨Ï¥ÎªÌ¡CµLªk´£¨Ñ¦¹¨Ï¥ÎªÌªº§ó¦h¸ê°T',1031510000);
INSERT INTO international VALUES (347,'WebGUI',9,'¬d¬Ý¨Ï¥ÎªÌÄÝ©Ê¡G',1031510000);
INSERT INTO international VALUES (348,'WebGUI',9,'©m¦W',1031510000);
INSERT INTO international VALUES (349,'WebGUI',9,'³Ì·sª©¥»',1031510000);
INSERT INTO international VALUES (350,'WebGUI',9,'µ²§ô',1031510000);
INSERT INTO international VALUES (352,'WebGUI',9,'µo¥X¤é´Á',1031510000);
INSERT INTO international VALUES (471,'WebGUI',9,'½s¿è¨Ï¥ÎªÌÄÝ©Ê¶µ',1031510000);
INSERT INTO international VALUES (355,'WebGUI',9,'Àq»{',1031510000);
INSERT INTO international VALUES (356,'WebGUI',9,'¼ÒªO',1031510000);
INSERT INTO international VALUES (357,'WebGUI',9,'·s»D',1031510000);
INSERT INTO international VALUES (358,'WebGUI',9,'¥ª¾É¯è',1031510000);
INSERT INTO international VALUES (359,'WebGUI',9,'¥k¾É¯è',1031510000);
INSERT INTO international VALUES (360,'WebGUI',9,'¤@¥[¤T',1031510000);
INSERT INTO international VALUES (361,'WebGUI',9,'¤T¥[¤@',1031510000);
INSERT INTO international VALUES (362,'WebGUI',9,'¥­¤À',1031510000);
INSERT INTO international VALUES (363,'WebGUI',9,'¼ÒªO©w¦ì',1031510000);
INSERT INTO international VALUES (364,'WebGUI',9,'·j¯Á',1031510000);
INSERT INTO international VALUES (365,'WebGUI',9,'·j¯Áµ²ªG...',1031510000);
INSERT INTO international VALUES (366,'WebGUI',9,'¨S¦³§ä¨ì²Å¦X·j¯Á±ø¥óªº­¶­±',1031510000);
INSERT INTO international VALUES (368,'WebGUI',9,'±N¦¹¨Ï¥ÎªÌ¥[¤J·s¨Ï¥ÎªÌ²Õ',1031510000);
INSERT INTO international VALUES (369,'WebGUI',9,'¹L´Á¤é´Á',1031510000);
INSERT INTO international VALUES (370,'WebGUI',9,'½s¿è¨Ï¥ÎªÌ¤À²Õ',1031510000);
INSERT INTO international VALUES (371,'WebGUI',9,'¼W¥[¨Ï¥ÎªÌ¤À²Õ',1031510000);
INSERT INTO international VALUES (372,'WebGUI',9,'½s¿è¨Ï¥ÎªÌ©ÒÄÝ²Õ¸s',1031510000);
INSERT INTO international VALUES (605,'WebGUI',9,'·s¼W¸s²Õ',1031510000);
INSERT INTO international VALUES (374,'WebGUI',9,'ºÞ²z¥]»q',1031510000);
INSERT INTO international VALUES (375,'WebGUI',9,'¿ï¾Ü­n®i¶}ªº¥]»q',1031510000);
INSERT INTO international VALUES (376,'WebGUI',9,'¥]»q',1031510000);
INSERT INTO international VALUES (377,'WebGUI',9,'¥]»qºÞ²z­û©Î¨t²ÎºÞ²z­û¨S¦³©w¸q¥]»q',1031510000);
INSERT INTO international VALUES (31,'UserSubmission',9,'¤º®e',1031510000);
INSERT INTO international VALUES (32,'UserSubmission',9,'¹Ï¤ù',1031510000);
INSERT INTO international VALUES (33,'UserSubmission',9,'ªþ¥ó',1031510000);
INSERT INTO international VALUES (34,'UserSubmission',9,'Âà´«¦^¨®',1031510000);
INSERT INTO international VALUES (35,'UserSubmission',9,'¼ÐÃD',1031510000);
INSERT INTO international VALUES (21,'EventsCalendar',9,'¬O§_°õ¦æ¼W¥[¨Æ°È',1031510000);
INSERT INTO international VALUES (378,'WebGUI',9,'¨Ï¥ÎªÌ ID',1031510000);
INSERT INTO international VALUES (379,'WebGUI',9,'¨Ï¥ÎªÌ²Õ ID',1031510000);
INSERT INTO international VALUES (380,'WebGUI',9,'­·®æ ID',1031510000);
INSERT INTO international VALUES (381,'WebGUI',9,'¨t²Î¦¬¨ì¤@­ÓµL®Äªºªí³æ½Ð¨D¡AµLªkÄ~Äò¡C·í³q¹Lªí³æ¿é¤J¤F¤@¨Ç«Dªk¦r²Å¡A³q±`·|¾É­P³o­Óµ²ªG¡C½Ð«öÂsÄý¾¹ªºªð¦^«ö¯Ãªð¦^¤W­¶­«·s¿é¤J',1031510000);
INSERT INTO international VALUES (1,'DownloadManager',9,'¤U¸üºÞ²z',1031510000);
INSERT INTO international VALUES (3,'DownloadManager',9,'¬O§_°õ¦æ¼W¥[¤å¥ó',1031510000);
INSERT INTO international VALUES (5,'DownloadManager',9,'¤å¥ó¼ÐÃD',1031510000);
INSERT INTO international VALUES (6,'DownloadManager',9,'¤U¸ü¤å¥ó',1031510000);
INSERT INTO international VALUES (7,'DownloadManager',9,'¤U¸ü¨Ï¥ÎªÌ²Õ',1031510000);
INSERT INTO international VALUES (8,'DownloadManager',9,'Â²¤¶',1031510000);
INSERT INTO international VALUES (9,'DownloadManager',9,'½s¿è¤U¸üºÞ²z­û',1031510000);
INSERT INTO international VALUES (10,'DownloadManager',9,'½s¿è¤U¸ü',1031510000);
INSERT INTO international VALUES (11,'DownloadManager',9,'¼W¥[·s¤U¸ü',1031510000);
INSERT INTO international VALUES (12,'DownloadManager',9,'±z¬O§_½T©w­n§R°£¦¹¤U¸ü¶µ¶Ü',1031510000);
INSERT INTO international VALUES (22,'DownloadManager',9,'¬O§_°õ¦æ¼W¥[¤U¸ü',1031510000);
INSERT INTO international VALUES (14,'DownloadManager',9,'¤å¥ó',1031510000);
INSERT INTO international VALUES (15,'DownloadManager',9,'´y­z',1031510000);
INSERT INTO international VALUES (16,'DownloadManager',9,'¤W¸ü¤é´Á',1031510000);
INSERT INTO international VALUES (15,'Article',9,'¾a¥k',1031510000);
INSERT INTO international VALUES (16,'Article',9,'¾a¥ª',1031510000);
INSERT INTO international VALUES (17,'Article',9,'©~¤¤',1031510000);
INSERT INTO international VALUES (37,'UserSubmission',9,'§R°£',1031510000);
INSERT INTO international VALUES (13,'SQLReport',9,'Convert carriage returns?',1031510000);
INSERT INTO international VALUES (17,'DownloadManager',9,'¨ä¥Lª©¥» #1',1031510000);
INSERT INTO international VALUES (18,'DownloadManager',9,'¨ä¥Lª©¥» #2',1031510000);
INSERT INTO international VALUES (19,'DownloadManager',9,'¨S¦³±z¥i¥H¤U¸üªº¤å¥ó',1031510000);
INSERT INTO international VALUES (14,'EventsCalendar',9,'¶}©l¤é´Á',1031510000);
INSERT INTO international VALUES (15,'EventsCalendar',9,'µ²§ô¤é´Á',1031510000);
INSERT INTO international VALUES (20,'DownloadManager',9,'¦b«á­±¼Ðª`­¶½X',1031510000);
INSERT INTO international VALUES (14,'SQLReport',9,'Paginate After',1031510000);
INSERT INTO international VALUES (16,'EventsCalendar',9,'¦æ¨Æ¾ä¥¬§½',1031510000);
INSERT INTO international VALUES (17,'EventsCalendar',9,'¦Cªí¤è¦¡',1031510000);
INSERT INTO international VALUES (18,'EventsCalendar',9,'¤é¾ú¤è¦¡',1031510000);
INSERT INTO international VALUES (19,'EventsCalendar',9,'¦b«á­±¼Ðª`­¶½X',1031510000);
INSERT INTO international VALUES (529,'WebGUI',9,'µ²ªG',1031510000);
INSERT INTO international VALUES (383,'WebGUI',9,'¦W¦r',1031510000);
INSERT INTO international VALUES (384,'WebGUI',9,'¤å¥ó',1031510000);
INSERT INTO international VALUES (385,'WebGUI',9,'°Ñ¼Æ',1031510000);
INSERT INTO international VALUES (386,'WebGUI',9,'½s¿è¹Ï¤ù',1031510000);
INSERT INTO international VALUES (387,'WebGUI',9,'¤W¸ü¤H',1031510000);
INSERT INTO international VALUES (388,'WebGUI',9,'¤W¸ü¤é´Á',1031510000);
INSERT INTO international VALUES (389,'WebGUI',9,'¹Ï¤ù ID',1031510000);
INSERT INTO international VALUES (390,'WebGUI',9,'Åã¥Ü¹Ï¤ù...',1031510000);
INSERT INTO international VALUES (391,'WebGUI',9,'§R°£ªþ¥[¤å¥ó',1031510000);
INSERT INTO international VALUES (392,'WebGUI',9,'±z½T©w­n§R°£¦¹¹Ï¤ù¶Ü',1031510000);
INSERT INTO international VALUES (393,'WebGUI',9,'ºÞ²z¹Ï¤ù',1031510000);
INSERT INTO international VALUES (394,'WebGUI',9,'ºÞ²z¹Ï¤ù',1031510000);
INSERT INTO international VALUES (395,'WebGUI',9,'¼W¥[·s¹Ï¤ù',1031510000);
INSERT INTO international VALUES (396,'WebGUI',9,'¬d¬Ý¹Ï¤ù',1031510000);
INSERT INTO international VALUES (397,'WebGUI',9,'ªð¦^¹Ï¤ù¦Cªí',1031510000);
INSERT INTO international VALUES (398,'WebGUI',9,'¤åÀÉÃþ«¬©w¸q',1031510000);
INSERT INTO international VALUES (399,'WebGUI',9,'¤ÀªR¥»­¶­±',1031510000);
INSERT INTO international VALUES (400,'WebGUI',9,'¬O§_ªý¤î¥N²z½w¦s',1031510000);
INSERT INTO international VALUES (401,'WebGUI',9,'±z¬O§_½T©w­n§R°£¦¹±ø®ø®§¥H¤Î¦¹±ø®ø®§ªº©Ò¦³½u¯Á',1031510000);
INSERT INTO international VALUES (402,'WebGUI',9,'±z­n¾Åªªº®ø®§¤£¦s¦b',1031510000);
INSERT INTO international VALUES (403,'WebGUI',9,'¤£§i¶D§A',1031510000);
INSERT INTO international VALUES (405,'WebGUI',9,'³Ì«á¤@­¶',1031510000);
INSERT INTO international VALUES (406,'WebGUI',9,'§Ö·Ó¤j¤p',1031510000);
INSERT INTO international VALUES (21,'DownloadManager',9,'Åã¥Ü§Ö·Ó',1031510000);
INSERT INTO international VALUES (407,'WebGUI',9,'ÂIÀ»¦¹³Bµù¥U',1031510000);
INSERT INTO international VALUES (15,'SQLReport',9,'Preprocess macros on query?',1031510000);
INSERT INTO international VALUES (16,'SQLReport',9,'Debug?',1031510000);
INSERT INTO international VALUES (17,'SQLReport',9,'<b>Debug:</b> Query:',1031510000);
INSERT INTO international VALUES (18,'SQLReport',9,'There were no results for this query.',1031510000);
INSERT INTO international VALUES (506,'WebGUI',9,'ºÞ²z¼ÒªO',1031510000);
INSERT INTO international VALUES (535,'WebGUI',9,'·í·s¨Ï¥ÎªÌµù¥U®É³qª¾¨Ï¥ÎªÌ²Õ',1031510000);
INSERT INTO international VALUES (353,'WebGUI',9,'²{¦b±zªº¦¬¥ó½c¤¤¨S¦³®ø®§',1031510000);
INSERT INTO international VALUES (530,'WebGUI',9,'·j¯Á<b>©Ò¦³</b>ÃöÁä¦r',1031510000);
INSERT INTO international VALUES (408,'WebGUI',9,'ºÞ²z®Ú­¶­±',1031510000);
INSERT INTO international VALUES (409,'WebGUI',9,'¼W¥[·s®Ú­¶­±',1031510000);
INSERT INTO international VALUES (410,'WebGUI',9,'ºÞ²z®Ú­¶­±',1031510000);
INSERT INTO international VALUES (411,'WebGUI',9,'¥Ø¿ý¼ÐÃD',1031510000);
INSERT INTO international VALUES (412,'WebGUI',9,'­¶­±´y­z',1031510000);
INSERT INTO international VALUES (9,'SiteMap',9,'Åã¥ÜÂ²¤¶',1031510000);
INSERT INTO international VALUES (18,'Article',9,'¬O§_¤¹³°Q½×',1031510000);
INSERT INTO international VALUES (19,'Article',9,'½Ö¥i¥Hµoªí',1031510000);
INSERT INTO international VALUES (20,'Article',9,'½Ö¥i¥HºÞ²z',1031510000);
INSERT INTO international VALUES (21,'Article',9,'½s¿è¶W®É',1031510000);
INSERT INTO international VALUES (22,'Article',9,'§@ªÌ',1031510000);
INSERT INTO international VALUES (23,'Article',9,'¤é´Á',1031510000);
INSERT INTO international VALUES (24,'Article',9,'µoªí¦^À³',1031510000);
INSERT INTO international VALUES (25,'Article',9,'½s¿è¦^À³',1031510000);
INSERT INTO international VALUES (26,'Article',9,'§R°£¦^À³',1031510000);
INSERT INTO international VALUES (27,'Article',9,'ªð¦^¤å³¹',1031510000);
INSERT INTO international VALUES (413,'WebGUI',9,'¹J¨ìÄY­«¿ù»~®É',1031510000);
INSERT INTO international VALUES (28,'Article',9,'¬d¬Ý¦^À³',1031510000);
INSERT INTO international VALUES (414,'WebGUI',9,'Åã¥Ü°£¿ù¸ê°T',1031510000);
INSERT INTO international VALUES (415,'WebGUI',9,'Åã¥Ü¤Í¦n¸ê°T',1031510000);
INSERT INTO international VALUES (416,'WebGUI',9,'<h1>±zªº½Ð¨D¥X²{°ÝÃD</h1> \r\n±zªº½Ð¨D¥X²{¤@­Ó¿ù»~¡C½Ð«öÂsÄý¾¹ªºªð¦^«ö¶sªð¦^¤W¤@­¶­«¸Õ¤@¦¸¡C¦pªG¦¹¶µ¿ù»~Ä~Äò¦s¦b¡A½ÐÁp¨t§Ú­Ì¡A¦P®É§i¶D§Ú­Ì±z¦b¤°»ò®É¶¡¨Ï¥Î¤°»ò¥¯àªº®É­Ô¥X²{ªº³o­Ó¿ù»~¡CÁÂÁÂ¡I',1031510000);
INSERT INTO international VALUES (417,'WebGUI',9,'<h1>¦w¥þÄµ³ø</h1>\r\n ±z³X°Ýªº²Õ¥ó¤£¦b³o¤@­¶¤W¡C¦¹¸ê°T¤w¸gµo°eµ¹¨t²ÎºÞ²z­û',1031510000);
INSERT INTO international VALUES (418,'WebGUI',9,'HTML ¹LÂo',1031510000);
INSERT INTO international VALUES (419,'WebGUI',9,'²M°£©Ò¦³ªº¼ÐÃÑ',1031510000);
INSERT INTO international VALUES (420,'WebGUI',9,'«O¯d©Ò¦³ªº¼ÐÃÑ',1031510000);
INSERT INTO international VALUES (421,'WebGUI',9,'«O¯d°ò¥»ªº¼ÐÃÑ',1031510000);
INSERT INTO international VALUES (422,'WebGUI',9,'<h1>µn¿ý¥¢±Ñ</h1>\r\n±z¿é¤Jªº±b¤á¸ê°T¦³»~',1031510000);
INSERT INTO international VALUES (423,'WebGUI',9,'¬d¬Ý¬¡°Ê¹ï¸Ü',1031510000);
INSERT INTO international VALUES (424,'WebGUI',9,'¬d¬Ýµn¿ý¾ú¥v°O¿ý',1031510000);
INSERT INTO international VALUES (425,'WebGUI',9,'¬¡°Ê¹ï¸Ü',1031510000);
INSERT INTO international VALUES (426,'WebGUI',9,'µn¿ý¾ú¥v°O¿ý',1031510000);
INSERT INTO international VALUES (427,'WebGUI',9,'­·®æ',1031510000);
INSERT INTO international VALUES (428,'WebGUI',9,'¨Ï¥ÎªÌ (ID)',1031510000);
INSERT INTO international VALUES (429,'WebGUI',9,'µn¿ý®É¶¡',1031510000);
INSERT INTO international VALUES (430,'WebGUI',9,'³Ì«á³X°Ý­¶­±',1031510000);
INSERT INTO international VALUES (431,'WebGUI',9,'IP ¦a§}',1031510000);
INSERT INTO international VALUES (432,'WebGUI',9,'¹L´Á',1031510000);
INSERT INTO international VALUES (433,'WebGUI',9,'¨Ï¥ÎªÌºÝ',1031510000);
INSERT INTO international VALUES (434,'WebGUI',9,'ª¬ºA',1031510000);
INSERT INTO international VALUES (435,'WebGUI',9,'¹ï¸Ü«H¸¹',1031510000);
INSERT INTO international VALUES (436,'WebGUI',9,'¬å±¼¦¹¹ï¸Ü',1031510000);
INSERT INTO international VALUES (437,'WebGUI',9,'²Î­p¸ê°T',1031510000);
INSERT INTO international VALUES (438,'WebGUI',9,'±zªº¦W¦r',1031510000);
INSERT INTO international VALUES (439,'WebGUI',9,'­Ó¤H¸ê°T',1031510000);
INSERT INTO international VALUES (440,'WebGUI',9,'Áp¨t¸ê°T',1031510000);
INSERT INTO international VALUES (441,'WebGUI',9,'¹q¤l¶l¥ó¨ì¶Ç©IºôÃö',1031510000);
INSERT INTO international VALUES (442,'WebGUI',9,'¤u§@¸ê°T',1031510000);
INSERT INTO international VALUES (443,'WebGUI',9,'®a®x¸ê°T',1031510000);
INSERT INTO international VALUES (444,'WebGUI',9,'­Ó¤HÁô¨p',1031510000);
INSERT INTO international VALUES (445,'WebGUI',9,'³ß¦n³]¸m',1031510000);
INSERT INTO international VALUES (446,'WebGUI',9,'³æ¦ìºô¯¸',1031510000);
INSERT INTO international VALUES (447,'WebGUI',9,'ºÞ²z­¶­±¾ð',1031510000);
INSERT INTO international VALUES (448,'WebGUI',9,'­¶­±¾ð',1031510000);
INSERT INTO international VALUES (449,'WebGUI',9,'¤@¯ë¸ê°T',1031510000);
INSERT INTO international VALUES (450,'WebGUI',9,'³æ¦ì¦WºÙ',1031510000);
INSERT INTO international VALUES (451,'WebGUI',9,'¥²»Ý',1031510000);
INSERT INTO international VALUES (452,'WebGUI',9,'¶i¤J¤¤...',1031510000);
INSERT INTO international VALUES (453,'WebGUI',9,'³Ð«Ø¤é´Á',1031510000);
INSERT INTO international VALUES (454,'WebGUI',9,'³Ì«á§ó·s',1031510000);
INSERT INTO international VALUES (455,'WebGUI',9,'½s¿è¨Ï¥ÎªÌ¸ê°T',1031510000);
INSERT INTO international VALUES (456,'WebGUI',9,'ªð¦^¨Ï¥ÎªÌ¦Cªí',1031510000);
INSERT INTO international VALUES (457,'WebGUI',9,'½s¿è¦¹¨Ï¥ÎªÌ±b¤á',1031510000);
INSERT INTO international VALUES (458,'WebGUI',9,'½s¿è¦¹¨Ï¥ÎªÌ²Õ¸s',1031510000);
INSERT INTO international VALUES (459,'WebGUI',9,'½s¿è¦¹¨Ï¥ÎªÌÄÝ©Ê',1031510000);
INSERT INTO international VALUES (460,'WebGUI',9,'®É°Ï',1031510000);
INSERT INTO international VALUES (461,'WebGUI',9,'¤é´Á®æ¦¡',1031510000);
INSERT INTO international VALUES (462,'WebGUI',9,'®É¶¡®æ¦¡',1031510000);
INSERT INTO international VALUES (463,'WebGUI',9,'¤å¥»¿é¤J°Ï¦æ¼Æ',1031510000);
INSERT INTO international VALUES (464,'WebGUI',9,'¤å¥»¿é¤J°Ï¦C¼Æ',1031510000);
INSERT INTO international VALUES (465,'WebGUI',9,'¤å¥»®Ø¤j¤p',1031510000);
INSERT INTO international VALUES (466,'WebGUI',9,'±z½T©w­n§R°£¦¹Ãþ§O¨Ã¥B±N¦¹Ãþ§O¤U©Ò¦³Äæ¥Ø²¾°Ê¨ì¤@¯ëÃþ§O¶Ü',1031510000);
INSERT INTO international VALUES (467,'WebGUI',9,'±z½T©w­n§R°£¦¹Äæ¥Ø¡A¨Ã¥B©Ò¦³Ãö©ó¦¹Äæ¥Øªº¨Ï¥ÎªÌ¸ê°T¶Ü',1031510000);
INSERT INTO international VALUES (469,'WebGUI',9,'ID',1031510000);
INSERT INTO international VALUES (470,'WebGUI',9,'¦W¦r',1031510000);
INSERT INTO international VALUES (472,'WebGUI',9,'¼ÐÃD',1031510000);
INSERT INTO international VALUES (473,'WebGUI',9,'¥i¨£',1031510000);
INSERT INTO international VALUES (474,'WebGUI',9,'¥²¶·',1031510000);
INSERT INTO international VALUES (475,'WebGUI',9,'¤å¦r',1031510000);
INSERT INTO international VALUES (476,'WebGUI',9,'¤å¦r°Ï',1031510000);
INSERT INTO international VALUES (477,'WebGUI',9,'HTML °Ï',1031510000);
INSERT INTO international VALUES (478,'WebGUI',9,'URL',1031510000);
INSERT INTO international VALUES (479,'WebGUI',9,'¤é´Á',1031510000);
INSERT INTO international VALUES (480,'WebGUI',9,'¹q¤l¶l¥ó¦a§}',1031510000);
INSERT INTO international VALUES (481,'WebGUI',9,'¹q¸Ü¸¹½X',1031510000);
INSERT INTO international VALUES (482,'WebGUI',9,'¼Æ¦r (¾ã¼Æ)',1031510000);
INSERT INTO international VALUES (483,'WebGUI',9,'¬O©Î§_',1031510000);
INSERT INTO international VALUES (484,'WebGUI',9,'¿ï¾Ü¦Cªí',1031510000);
INSERT INTO international VALUES (485,'WebGUI',9,'¥¬º¸­È (¿ï¾Ü®Ø)',1031510000);
INSERT INTO international VALUES (486,'WebGUI',9,'¼ÆÕuÃþ«¬',1031510000);
INSERT INTO international VALUES (487,'WebGUI',9,'¥i¿ï­È',1031510000);
INSERT INTO international VALUES (488,'WebGUI',9,'Àq»{­È',1031510000);
INSERT INTO international VALUES (489,'WebGUI',9,'ÄÝ©ÊÃþ',1031510000);
INSERT INTO international VALUES (490,'WebGUI',9,'¼W¥[¤@­ÓÄÝ©ÊÃþ',1031510000);
INSERT INTO international VALUES (491,'WebGUI',9,'¼W¥[¤@­ÓÄÝ©ÊÄæ',1031510000);
INSERT INTO international VALUES (492,'WebGUI',9,'ÄÝ©ÊÄæ¦Cªí',1031510000);
INSERT INTO international VALUES (493,'WebGUI',9,'ªð¦^ºô¯¸',1031510000);
INSERT INTO international VALUES (495,'WebGUI',9,'¤º¸m½s¿è¾¹',1031510000);
INSERT INTO international VALUES (496,'WebGUI',9,'¨Ï¥Î',1031510000);
INSERT INTO international VALUES (494,'WebGUI',9,'Real Objects Edit-On Pro',1031510000);
INSERT INTO international VALUES (497,'WebGUI',9,'¶}©l¤é´Á',1031510000);
INSERT INTO international VALUES (498,'WebGUI',9,'µ²§ô¤é´Á',1031510000);
INSERT INTO international VALUES (499,'WebGUI',9,'²Õ¥ó ID',1031510000);
INSERT INTO international VALUES (500,'WebGUI',9,'­¶­± ID',1031510000);
INSERT INTO international VALUES (514,'WebGUI',9,'³X°Ý',1031510000);
INSERT INTO international VALUES (527,'WebGUI',9,'Àq»{­º­¶',1031510000);
INSERT INTO international VALUES (503,'WebGUI',9,'¼ÒªO ID',1031510000);
INSERT INTO international VALUES (501,'WebGUI',9,'¥DÊ^',1031510000);
INSERT INTO international VALUES (528,'WebGUI',9,'¼ÒªO¦WºÙ',1031510000);
INSERT INTO international VALUES (468,'WebGUI',9,'½s¿è¨Ï¥ÎªÌÄÝ©ÊÃþ',1031510000);
INSERT INTO international VALUES (159,'WebGUI',9,'¦¬¥ó½c',1031510000);
INSERT INTO international VALUES (508,'WebGUI',9,'ºÞ²z¼ÒªO',1031510000);
INSERT INTO international VALUES (39,'UserSubmission',9,'µoªí¦^ÂÐ',1031510000);
INSERT INTO international VALUES (40,'UserSubmission',9,'§@ªÌ',1031510000);
INSERT INTO international VALUES (41,'UserSubmission',9,'¤é´Á',1031510000);
INSERT INTO international VALUES (42,'UserSubmission',9,'½s¿è¦^À³',1031510000);
INSERT INTO international VALUES (43,'UserSubmission',9,'§R°£¦^À³',1031510000);
INSERT INTO international VALUES (45,'UserSubmission',9,'ªð¦^±i¶K¤å³¹¨t²Î',1031510000);
INSERT INTO international VALUES (46,'UserSubmission',9,'§ó¦h...',1031510000);
INSERT INTO international VALUES (47,'UserSubmission',9,'¦^ÂÐ',1031510000);
INSERT INTO international VALUES (48,'UserSubmission',9,'¬O§_¤¹³°Q½×',1031510000);
INSERT INTO international VALUES (49,'UserSubmission',9,'½s¿è¶W®É',1031510000);
INSERT INTO international VALUES (50,'UserSubmission',9,'¤¹³µoªíªº¨Ï¥ÎªÌ²Õ',1031510000);
INSERT INTO international VALUES (44,'UserSubmission',9,'¤¹³ºÞ²zªº¨Ï¥ÎªÌ²Õ',1031510000);
INSERT INTO international VALUES (51,'UserSubmission',9,'Åã¥Ü§Ö·Ó',1031510000);
INSERT INTO international VALUES (52,'UserSubmission',9,'§Ö·Ó',1031510000);
INSERT INTO international VALUES (53,'UserSubmission',9,'¥¬§½',1031510000);
INSERT INTO international VALUES (54,'UserSubmission',9,'¯d¨¥¼Ò¦¡',1031510000);
INSERT INTO international VALUES (55,'UserSubmission',9,'¦Cªí¼Ò¦¡',1031510000);
INSERT INTO international VALUES (56,'UserSubmission',9,'¬Û¥U',1031510000);
INSERT INTO international VALUES (57,'UserSubmission',9,'¦^À³',1031510000);
INSERT INTO international VALUES (11,'FAQ',9,'¬O§_¥´¶} TOC ',1031510000);
INSERT INTO international VALUES (12,'FAQ',9,'¬O§_¥´¶} Q/A ',1031510000);
INSERT INTO international VALUES (13,'FAQ',9,'¬O§_¥´¶} [top] ³s±µ',1031510000);
INSERT INTO international VALUES (14,'FAQ',9,'Q',1031510000);
INSERT INTO international VALUES (15,'FAQ',9,'A',1031510000);
INSERT INTO international VALUES (16,'FAQ',9,'[ªð¦^³»ºÝ]',1031510000);
INSERT INTO international VALUES (509,'WebGUI',9,'°Q½×¥¬§½',1031510000);
INSERT INTO international VALUES (510,'WebGUI',9,'¥­¾Q',1031510000);
INSERT INTO international VALUES (511,'WebGUI',9,'½u¯Á',1031510000);
INSERT INTO international VALUES (512,'WebGUI',9,'¤U¤@±ø½u¯Á',1031510000);
INSERT INTO international VALUES (513,'WebGUI',9,'¤W¤@±ø½u¯Á',1031510000);
INSERT INTO international VALUES (534,'WebGUI',9,'·s¨Ï¥ÎªÌ´£¥Ü',1031510000);
INSERT INTO international VALUES (354,'WebGUI',9,'¬d¬Ý¦¬¥ó½c',1031510000);
INSERT INTO international VALUES (531,'WebGUI',9,'¥]¬A<b>§¹¾ãªº«÷¼g</b>',1031510000);
INSERT INTO international VALUES (518,'WebGUI',9,'¦¬¥ó½c´£¥Ü',1031510000);
INSERT INTO international VALUES (519,'WebGUI',9,'§Ú§Æ±æ³Q´£¿ô',1031510000);
INSERT INTO international VALUES (520,'WebGUI',9,'§Ú§Æ±æ³q¹L¹q¤l¶l¥óªº¤è¦¡´£¿ô',1031510000);
INSERT INTO international VALUES (521,'WebGUI',9,'§Ú§Æ±æ³q¹L¹q¤l¶l¥ó¨ì¶Ç©Iªº¤è¦¡´£¿ô',1031510000);
INSERT INTO international VALUES (522,'WebGUI',9,'§Ú§Æ±æ³q¹L ICQ ªº¤è¦¡´£¿ô',1031510000);
INSERT INTO international VALUES (523,'WebGUI',9,'´£¿ô',1031510000);
INSERT INTO international VALUES (524,'WebGUI',9,'¬O§_¼W¥[½s¿èÂW',1031510000);
INSERT INTO international VALUES (525,'WebGUI',9,'½s¿è¤º®e³]¸m',1031510000);
INSERT INTO international VALUES (10,'FAQ',2,'Frage bearbeiten',1031510000);
INSERT INTO international VALUES (10,'DownloadManager',2,'Download\nbearbeiten',1031510000);
INSERT INTO international VALUES (10,'Article',2,'Carriage Return\nbeachten?',1031510000);
INSERT INTO international VALUES (562,'WebGUI',2,'Ausstehend',1031510000);
INSERT INTO international VALUES (9,'WebGUI',2,'Zwischenablage\nanschauen',1031510000);
INSERT INTO international VALUES (9,'SQLReport',2,'Fehler: Die DSN\nbesitzt das falsche Format.',1031510000);
INSERT INTO international VALUES (9,'SiteMap',2,'Übersicht\nanzeigen?',1031510000);
INSERT INTO international VALUES (9,'Poll',2,'Abstimmung\nbearbeiten',1031510000);
INSERT INTO international VALUES (9,'MessageBoard',2,'Beitrags\nID:',1031510000);
INSERT INTO international VALUES (9,'LinkList',2,'Sind Sie sicher,\ndass Sie diesen Link löschen wollen?',1031510000);
INSERT INTO international VALUES (9,'FAQ',2,'Neue Frage\nhinzufügen',1031510000);
INSERT INTO international VALUES (9,'EventsCalendar',2,'bis',1031510000);
INSERT INTO international VALUES (9,'DownloadManager',2,'Download\nManager bearbeiten',1031510000);
INSERT INTO international VALUES (9,'Article',2,'Dateianhang',1031510000);
INSERT INTO international VALUES (8,'WebGUI',2,'\"Seite nicht\ngefunden\" anschauen',1031510000);
INSERT INTO international VALUES (561,'WebGUI',2,'Verboten',1031510000);
INSERT INTO international VALUES (8,'SQLReport',2,'SQL Bericht\nbearbeiten',1031510000);
INSERT INTO international VALUES (8,'SiteMap',2,'Zeilenabstand',1031510000);
INSERT INTO international VALUES (8,'Poll',2,'(Eine Antwort pro\nZeile. Bitte nicht mehr als 20 verschiedene Antworten)',1031510000);
INSERT INTO international VALUES (8,'MessageBoard',2,'Datum:',1031510000);
INSERT INTO international VALUES (8,'LinkList',2,'URL',1031510000);
INSERT INTO international VALUES (8,'FAQ',2,'F.A.Q. bearbeiten',1031510000);
INSERT INTO international VALUES (8,'EventsCalendar',2,'Wiederholt\nsich',1031510000);
INSERT INTO international VALUES (8,'DownloadManager',2,'Kurze\nBeschreibung',1031510000);
INSERT INTO international VALUES (7,'WebGUI',2,'Benutzer\nverwalten',1031510000);
INSERT INTO international VALUES (8,'Article',2,'Link URL',1031510000);
INSERT INTO international VALUES (560,'WebGUI',2,'Erlaubt',1031510000);
INSERT INTO international VALUES (7,'SQLReport',2,'Datenbankpasswort',1031510000);
INSERT INTO international VALUES (7,'SiteMap',2,'Kugel',1031510000);
INSERT INTO international VALUES (7,'Poll',2,'Antworten',1031510000);
INSERT INTO international VALUES (7,'MessageBoard',2,'Autor:',1031510000);
INSERT INTO international VALUES (7,'FAQ',2,'Sind Sie sicher, dass\nSie diese Frage löschen wollen?',1031510000);
INSERT INTO international VALUES (7,'DownloadManager',2,'Gruppe,\ndie Download benutzen kann',1031510000);
INSERT INTO international VALUES (7,'Article',2,'Link Titel',1031510000);
INSERT INTO international VALUES (6,'WebGUI',2,'Stile verwalten',1031510000);
INSERT INTO international VALUES (6,'UserSubmission',2,'Beiträge\npro Seite',1031510000);
INSERT INTO international VALUES (6,'SyndicatedContent',2,'Aktueller Inhalt',1031510000);
INSERT INTO international VALUES (6,'SQLReport',2,'Datenbankbenutzer',1031510000);
INSERT INTO international VALUES (6,'SiteMap',2,'Zweck',1031510000);
INSERT INTO international VALUES (6,'MessageBoard',2,'Diskussionsforum bearbeiten',1031510000);
INSERT INTO international VALUES (6,'Poll',2,'Frage',1031510000);
INSERT INTO international VALUES (6,'LinkList',2,'Link Liste',1031510000);
INSERT INTO international VALUES (6,'FAQ',2,'Antwort',1031510000);
INSERT INTO international VALUES (6,'ExtraColumn',2,'Extra Spalte\nbearbeiten',1031510000);
INSERT INTO international VALUES (701,'WebGUI',2,'Woche',1031510000);
INSERT INTO international VALUES (6,'DownloadManager',2,'Dateiname',1031510000);
INSERT INTO international VALUES (6,'Article',2,'Bild',1031510000);
INSERT INTO international VALUES (5,'WebGUI',2,'Gruppen\nverwalten',1031510000);
INSERT INTO international VALUES (5,'UserSubmission',2,'Ihr Beitrag\nwurde abgelehnt.',1031510000);
INSERT INTO international VALUES (5,'SyndicatedContent',2,'zuletzt\ngeholt',1031510000);
INSERT INTO international VALUES (5,'SQLReport',2,'DSN (Data Source\nName)',1031510000);
INSERT INTO international VALUES (5,'SiteMap',2,'Site Map\nbearbeiten',1031510000);
INSERT INTO international VALUES (5,'Poll',2,'Breite der Grafik',1031510000);
INSERT INTO international VALUES (566,'WebGUI',2,'Timeout zum\nbearbeiten',1031510000);
INSERT INTO international VALUES (5,'LinkList',2,'Wollen Sie einen\nLink hinzufügen?',1031510000);
INSERT INTO international VALUES (5,'Item',2,'Anhang\nherunterladen',1031510000);
INSERT INTO international VALUES (5,'FAQ',2,'Frage',1031510000);
INSERT INTO international VALUES (5,'ExtraColumn',2,'StyleSheet\nClass',1031510000);
INSERT INTO international VALUES (700,'WebGUI',2,'Tag',1031510000);
INSERT INTO international VALUES (5,'DownloadManager',2,'Dateititel',1031510000);
INSERT INTO international VALUES (4,'WebGUI',2,'Einstellungen\nverwalten',1031510000);
INSERT INTO international VALUES (4,'UserSubmission',2,'Ihr Betrag\nwurde angenommen.',1031510000);
INSERT INTO international VALUES (4,'SQLReport',2,'Abfrage',1031510000);
INSERT INTO international VALUES (4,'SyndicatedContent',2,'Clipping-Dienst bearbeiten',1031510000);
INSERT INTO international VALUES (4,'SiteMap',2,'Tiefe',1031510000);
INSERT INTO international VALUES (4,'Poll',2,'Wer kann\nabstimmen?',1031510000);
INSERT INTO international VALUES (4,'Item',2,'Kleiner Artikel',1031510000);
INSERT INTO international VALUES (4,'LinkList',2,'Kugel',1031510000);
INSERT INTO international VALUES (4,'MessageBoard',2,'Beiträge pro\nSeite',1031510000);
INSERT INTO international VALUES (4,'ExtraColumn',2,'Breite',1031510000);
INSERT INTO international VALUES (4,'EventsCalendar',2,'Einmaliges\nEreignis',1031510000);
INSERT INTO international VALUES (4,'Article',2,'Ende Datum',1031510000);
INSERT INTO international VALUES (3,'WebGUI',2,'Aus Zwischenablage\neinfügen...',1031510000);
INSERT INTO international VALUES (3,'UserSubmission',2,'Sie sollten\neinen neuen Beitrag genehmigen.',1031510000);
INSERT INTO international VALUES (3,'SQLReport',2,'Schablone',1031510000);
INSERT INTO international VALUES (3,'SiteMap',2,'Auf dieser Ebene\nStarten?',1031510000);
INSERT INTO international VALUES (3,'Poll',2,'Aktiv',1031510000);
INSERT INTO international VALUES (564,'WebGUI',2,'Wer kann\nBeiträge schreiben?',1031510000);
INSERT INTO international VALUES (3,'LinkList',2,'In neuem Fenster\nöffnen?',1031510000);
INSERT INTO international VALUES (3,'Item',2,'Anhang löschen',1031510000);
INSERT INTO international VALUES (3,'ExtraColumn',2,'Platzhalter',1031510000);
INSERT INTO international VALUES (3,'DownloadManager',2,'Fortfahren\ndie Datei hinzuzufügen?',1031510000);
INSERT INTO international VALUES (3,'Article',2,'Start Datum',1031510000);
INSERT INTO international VALUES (2,'WebGUI',2,'Seite',1031510000);
INSERT INTO international VALUES (2,'UserSubmission',2,'Wer kann\nBeiträge schreiben?',1031510000);
INSERT INTO international VALUES (2,'SyndicatedContent',2,'Clipping-Dienst',1031510000);
INSERT INTO international VALUES (2,'SiteMap',2,'Site\nMap/Übersicht',1031510000);
INSERT INTO international VALUES (2,'FAQ',2,'F.A.Q.',1031510000);
INSERT INTO international VALUES (2,'Item',2,'Anhang',1031510000);
INSERT INTO international VALUES (2,'LinkList',2,'Zeilenabstand',1031510000);
INSERT INTO international VALUES (2,'MessageBoard',2,'Diskussionsforum',1031510000);
INSERT INTO international VALUES (2,'EventsCalendar',2,'Veranstaltungskalender',1031510000);
INSERT INTO international VALUES (1,'WebGUI',2,'Inhalt\nhinzufügen...',1031510000);
INSERT INTO international VALUES (1,'SyndicatedContent',2,'URL zur\nRSS-Datei',1031510000);
INSERT INTO international VALUES (1,'UserSubmission',2,'Wer kann\ngenehmigen?',1031510000);
INSERT INTO international VALUES (1,'SQLReport',2,'SQL Bericht',1031510000);
INSERT INTO international VALUES (1,'Poll',2,'Abstimmung',1031510000);
INSERT INTO international VALUES (1,'LinkList',2,'Tabulator',1031510000);
INSERT INTO international VALUES (1,'Item',2,'Link URL',1031510000);
INSERT INTO international VALUES (1,'FAQ',2,'Frage hinzufügen?',1031510000);
INSERT INTO international VALUES (1,'ExtraColumn',2,'Extra\nSpalte',1031510000);
INSERT INTO international VALUES (1,'EventsCalendar',2,'Termin\nhinzufügen?',1031510000);
INSERT INTO international VALUES (1,'DownloadManager',2,'Download\nManager',1031510000);
INSERT INTO international VALUES (1,'Article',2,'Artikel',1031510000);
INSERT INTO international VALUES (395,'WebGUI',2,'Neue Grafik\nhinzufügen.',1031510000);
INSERT INTO international VALUES (396,'WebGUI',2,'Grafik\nanschauen',1031510000);
INSERT INTO international VALUES (397,'WebGUI',2,'Zurück zur\nGrafikübersicht.',1031510000);
INSERT INTO international VALUES (398,'WebGUI',2,'Dokumententyp\nBeschreibung',1031510000);
INSERT INTO international VALUES (399,'WebGUI',2,'Diese Seite\nüberprüfen.',1031510000);
INSERT INTO international VALUES (400,'WebGUI',2,'Caching\nverhindern',1031510000);
INSERT INTO international VALUES (401,'WebGUI',2,'Sind Sie sicher,\ndass Sie diese Nachrichten und alle darunterliegenden löschen wollen?',1031510000);
INSERT INTO international VALUES (402,'WebGUI',2,'Die Nachricht die\nsie abfragen wollten existiert leider nicht.',1031510000);
INSERT INTO international VALUES (403,'WebGUI',2,'Ich teile es\nlieber nicht mit.',1031510000);
INSERT INTO international VALUES (404,'WebGUI',2,'Erste Seite',1031510000);
INSERT INTO international VALUES (405,'WebGUI',2,'Letzte Seite',1031510000);
INSERT INTO international VALUES (406,'WebGUI',2,'Größe der kleinen\nBilder',1031510000);
INSERT INTO international VALUES (407,'WebGUI',2,'Klicken Sie hier,\num sich zu registrieren',1031510000);
INSERT INTO international VALUES (408,'WebGUI',2,'Startseiten\nbearbeiten',1031510000);
INSERT INTO international VALUES (409,'WebGUI',2,'Neue Startseite\nanlegen',1031510000);
INSERT INTO international VALUES (410,'WebGUI',2,'Startseiten\nbearbeiten',1031510000);
INSERT INTO international VALUES (411,'WebGUI',2,'Menü Titel',1031510000);
INSERT INTO international VALUES (412,'WebGUI',2,'Synopse',1031510000);
INSERT INTO international VALUES (416,'WebGUI',2,'<h1>Abfrageproblem</h1> Ihre Anfrage macht dem\nSystem Probleme. Bitte betätigen Sie den Zurückbutton im Browser und\nversuchen Sie es nochmal. Sollte dieses Problem weiterbestehen, teilen Sie\nuns bitte mit, was Sie wo im System wann gemacht haben.',1031510000);
INSERT INTO international VALUES (417,'WebGUI',2,'<h1>Sicherheitsverstoß</h1> Sie haben versucht\nauf einen Systemteil zuzugreifen, der Ihnen nicht erlaubt ist. Der Verstoß\nwurde gemeldet.',1031510000);
INSERT INTO international VALUES (418,'WebGUI',2,'HTML filtern',1031510000);
INSERT INTO international VALUES (419,'WebGUI',2,'Alle\nBeschreibungselemente entfernen',1031510000);
INSERT INTO international VALUES (420,'WebGUI',2,'Nicht\nverändern',1031510000);
INSERT INTO international VALUES (421,'WebGUI',2,'Nur einfache\nFormatierungen beibehalten',1031510000);
INSERT INTO international VALUES (422,'WebGUI',2,'<h1>Anmeldung ist\nfehlgeschlagen!</h1> Die eingegebenen Zugansdaten stimmen mit keinen\nBenutzerdaten überein.',1031510000);
INSERT INTO international VALUES (423,'WebGUI',2,'Aktive Sitzungen\nanschauen',1031510000);
INSERT INTO international VALUES (424,'WebGUI',2,'Anmeldungshistorie anschauen',1031510000);
INSERT INTO international VALUES (425,'WebGUI',2,'Aktive\nSitzungen',1031510000);
INSERT INTO international VALUES (426,'WebGUI',2,'Anmeldungshistorie',1031510000);
INSERT INTO international VALUES (427,'WebGUI',2,'Stile',1031510000);
INSERT INTO international VALUES (428,'WebGUI',2,'Benutzername',1031510000);
INSERT INTO international VALUES (429,'WebGUI',2,'Anmeldungszeit',1031510000);
INSERT INTO international VALUES (430,'WebGUI',2,'Seite wurde das\nletzte mal angeschaut',1031510000);
INSERT INTO international VALUES (431,'WebGUI',2,'IP Adresse',1031510000);
INSERT INTO international VALUES (432,'WebGUI',2,'läuft ab',1031510000);
INSERT INTO international VALUES (434,'WebGUI',2,'Status',1031510000);
INSERT INTO international VALUES (435,'WebGUI',2,'Sitzungssignatur',1031510000);
INSERT INTO international VALUES (436,'WebGUI',2,'Sitzung\nbeenden',1031510000);
INSERT INTO international VALUES (437,'WebGUI',2,'Statistiken',1031510000);
INSERT INTO international VALUES (438,'WebGUI',2,'Ihr Name',1031510000);
INSERT INTO international VALUES (51,'UserSubmission',2,'Bildvorschau anzeigen?',1031510000);
INSERT INTO international VALUES (1,'Product',2,'Produkt',1031510000);
INSERT INTO international VALUES (10,'MailForm',2,'Von',1031510000);
INSERT INTO international VALUES (10,'Product',2,'Preis',1031510000);
INSERT INTO international VALUES (11,'FAQ',2,'Inhaltsverzeichnis einschalten?',1031510000);
INSERT INTO international VALUES (11,'MailForm',2,'senden an (Email, Benutzername oder Gruppenname)',1031510000);
INSERT INTO international VALUES (11,'Product',2,'Produktnummer',1031510000);
INSERT INTO international VALUES (12,'FAQ',2,'Frage/Antwort einschalten?',1031510000);
INSERT INTO international VALUES (12,'MailForm',2,'Kopie',1031510000);
INSERT INTO international VALUES (12,'Product',2,'Sind Sie sicher, daß Sie diese Datei löschen wollen?',1031510000);
INSERT INTO international VALUES (13,'FAQ',2,'[top] Link einschalten?',1031510000);
INSERT INTO international VALUES (13,'MailForm',2,'Blindkopie',1031510000);
INSERT INTO international VALUES (13,'Product',2,'Broschüre',1031510000);
INSERT INTO international VALUES (14,'FAQ',2,'Frage',1031510000);
INSERT INTO international VALUES (14,'MailForm',2,'Betreff',1031510000);
INSERT INTO international VALUES (15,'FAQ',2,'Antwort',1031510000);
INSERT INTO international VALUES (15,'MailForm',2,'Mehr Felder hinzufügen?',1031510000);
INSERT INTO international VALUES (15,'Product',2,'Garantie',1031510000);
INSERT INTO international VALUES (16,'FAQ',2,'zum Seitenanfang',1031510000);
INSERT INTO international VALUES (9,'MailForm',2,'Feld hinzufügen',1031510000);
INSERT INTO international VALUES (8,'MailForm',2,'Breite',1031510000);
INSERT INTO international VALUES (1,'MailForm',2,'Mail Vorlage',1031510000);
INSERT INTO international VALUES (16,'MailForm',2,'Wissen',1031510000);
INSERT INTO international VALUES (17,'MailForm',2,'E-mail wurde gesendet',1031510000);
INSERT INTO international VALUES (463,'WebGUI',2,'Zeilen des Textfeldes',1031510000);
INSERT INTO international VALUES (462,'WebGUI',2,'Zeitformat',1031510000);
INSERT INTO international VALUES (461,'WebGUI',2,'Format des Datums',1031510000);
INSERT INTO international VALUES (460,'WebGUI',2,'Zeitabweichung',1031510000);
INSERT INTO international VALUES (46,'UserSubmission',2,'Lesen Sie mehr...',1031510000);
INSERT INTO international VALUES (46,'Product',2,'Produkt (verwandt), hinzufügen oder bearbeiten',1031510000);
INSERT INTO international VALUES (459,'WebGUI',2,'Das Profil dieses Benutzers bearbeiten.',1031510000);
INSERT INTO international VALUES (458,'WebGUI',2,'Gruppen dieses Benuzters bearbeiten',1031510000);
INSERT INTO international VALUES (457,'WebGUI',2,'Konto des Benutzers bearbeiten',1031510000);
INSERT INTO international VALUES (456,'WebGUI',2,'zurück zur Benutzerübersicht',1031510000);
INSERT INTO international VALUES (455,'WebGUI',2,'Profil des Benutzers bearbeiten',1031510000);
INSERT INTO international VALUES (454,'WebGUI',2,'letztes Update',1031510000);
INSERT INTO international VALUES (453,'WebGUI',2,'Erstelldatum',1031510000);
INSERT INTO international VALUES (452,'WebGUI',2,'Bitte warten...',1031510000);
INSERT INTO international VALUES (451,'WebGUI',2,'ist erforderlich.',1031510000);
INSERT INTO international VALUES (450,'WebGUI',2,'Firmenname',1031510000);
INSERT INTO international VALUES (45,'UserSubmission',2,'zurück zur Submission',1031510000);
INSERT INTO international VALUES (449,'WebGUI',2,'sonstige Informationen',1031510000);
INSERT INTO international VALUES (448,'WebGUI',2,'Baumstruktur der Seite',1031510000);
INSERT INTO international VALUES (447,'WebGUI',2,'Baumstruktur der Seite verwalten',1031510000);
INSERT INTO international VALUES (445,'WebGUI',2,'Präferenzen',1031510000);
INSERT INTO international VALUES (444,'WebGUI',2,'demografische Informationen',1031510000);
INSERT INTO international VALUES (439,'WebGUI',2,'persönliche Informationen',1031510000);
INSERT INTO international VALUES (39,'UserSubmission',2,'Antwort schreiben',1031510000);
INSERT INTO international VALUES (4,'MailForm',2,'unsichtbar',1031510000);
INSERT INTO international VALUES (40,'Product',2,'Produkteigenschaft hinzuügen/bearbeiten',1031510000);
INSERT INTO international VALUES (40,'UserSubmission',2,'aufgegeben von',1031510000);
INSERT INTO international VALUES (41,'UserSubmission',2,'Datum',1031510000);
INSERT INTO international VALUES (18,'MailForm',2,'Zurück!',1031510000);
INSERT INTO international VALUES (21,'Product',2,'Add another related product?',1031510000);
INSERT INTO international VALUES (8,'Product',2,'Produktgrafik 3',1031510000);
INSERT INTO international VALUES (78,'EventsCalendar',2,'Löschen Sie nichts, ich habe einen Fehler verursacht.',1031510000);
INSERT INTO international VALUES (73,'LinkList',2,'Title\r\nThe text that will be linked. \r\nURL\r\nThe web site to link to. \r\n\r\nOpen in new window?\r\nSelect yes if you\'d like this link to pop-up into a new window. \r\n\r\nDescription\r\nDescribe the site you\'re linking to. You can omit this if you\'d like. \r\n\r\nProceed to add link? If you have another link to add, select \"Yes\". \r\n',1031510000);
INSERT INTO international VALUES (76,'EventsCalendar',2,'Nur dieses Ereignis löschen',1031510000);
INSERT INTO international VALUES (77,'EventsCalendar',2,'Dieses Ereignis und alle Wiederholungen löschen.',1031510000);
INSERT INTO international VALUES (75,'EventsCalendar',2,'Was möchten Sie gerne tun?',1031510000);
INSERT INTO international VALUES (74,'EventsCalendar',2,'Kalendermonat (klein)',1031510000);
INSERT INTO international VALUES (72,'Poll',2,'Antworten zufällig anordnen?',1031510000);
INSERT INTO international VALUES (72,'LinkList',2,'Link hinzufügen oder bearbeiten',1031510000);
INSERT INTO international VALUES (72,'FAQ',2,'Frage hinzufügen oder bearbeiten',1031510000);
INSERT INTO international VALUES (72,'EventsCalendar',2,'Ereignis hinzufügen oder bearbeiten',1031510000);
INSERT INTO international VALUES (72,'DownloadManager',2,'Download hinzufügen oder bearbeiten',1031510000);
INSERT INTO international VALUES (717,'WebGUI',2,'Abmelden',1031510000);
INSERT INTO international VALUES (716,'WebGUI',2,'Anmelden',1031510000);
INSERT INTO international VALUES (715,'WebGUI',2,'Redirect URL',1031510000);
INSERT INTO international VALUES (710,'WebGUI',2,'privilegierte Einstellungen bearbeiten',1031510000);
INSERT INTO international VALUES (27,'Product',2,'Spezifikation',1031510000);
INSERT INTO international VALUES (26,'Product',2,'Label',1031510000);
INSERT INTO international VALUES (25,'Product',2,'Spezifikation bearbeiten',1031510000);
INSERT INTO international VALUES (25,'MailForm',2,'Standartwert (optional)',1031510000);
INSERT INTO international VALUES (24,'Product',2,'Ein weitere Eigenschaft hinzufügen?',1031510000);
INSERT INTO international VALUES (2,'WobjectProxy',2,'Wobject Proxy bearbeiten',1031510000);
INSERT INTO international VALUES (26,'MailForm',2,'Eintragungen speichern?',1031510000);
INSERT INTO international VALUES (24,'MailForm',2,'Mögliche Werte der Drop-Down Box',1031510000);
INSERT INTO international VALUES (23,'Product',2,'Eigenschaft',1031510000);
INSERT INTO international VALUES (23,'MailForm',2,'Art',1031510000);
INSERT INTO international VALUES (22,'Product',2,'Eigenschaft bearbeiten',1031510000);
INSERT INTO international VALUES (22,'MailForm',2,'Status',1031510000);
INSERT INTO international VALUES (22,'DownloadManager',2,'Einen weiteren Download hinzufügen?',1031510000);
INSERT INTO international VALUES (21,'MailForm',2,'Feldname',1031510000);
INSERT INTO international VALUES (21,'EventsCalendar',2,'Ein weiteres Ereignis hinzufügen?',1031510000);
INSERT INTO international VALUES (20,'Product',2,'ähnliches Produkt',1031510000);
INSERT INTO international VALUES (20,'MailForm',2,'Feld bearbeiten',1031510000);
INSERT INTO international VALUES (2,'MailForm',2,'Hier Betreff ihrer Email eingeben',1031510000);
INSERT INTO international VALUES (14,'Product',2,'Handbuch',1031510000);
INSERT INTO international VALUES (20,'EventsCalendar',2,'ein Ereignis hinzufügen',1031510000);
INSERT INTO international VALUES (19,'Product',2,'ähnliches produkt hinzufügen',1031510000);
INSERT INTO international VALUES (19,'MailForm',2,'Sind Sie sich sicher, dass Sie dieses Feld löschen möchten?',1031510000);
INSERT INTO international VALUES (520,'WebGUI',2,'Ich möchte gern per Email benachrichtigt werden.',1031510000);
INSERT INTO international VALUES (52,'Product',2,'Einen weiteren Gewinn (benefit) hinzufügen?',1031510000);
INSERT INTO international VALUES (519,'WebGUI',2,'Ich möchte nicht benachrichtigt werden.',1031510000);
INSERT INTO international VALUES (517,'WebGUI',2,'Administrationsmodus ausschalten!',1031510000);
INSERT INTO international VALUES (516,'WebGUI',2,'Administrationsmodus einschalten!',1031510000);
INSERT INTO international VALUES (514,'WebGUI',2,'Ansichten (views)',1031510000);
INSERT INTO international VALUES (51,'Product',2,'Gewinn (benefit)',1031510000);
INSERT INTO international VALUES (508,'WebGUI',2,'Vorlagen verwalten',1031510000);
INSERT INTO international VALUES (507,'WebGUI',2,'Vorlage bearbeiten',1031510000);
INSERT INTO international VALUES (506,'WebGUI',2,'Vorlagen verwalten',1031510000);
INSERT INTO international VALUES (505,'WebGUI',2,'neue Vorlage hinzufügen',1031510000);
INSERT INTO international VALUES (504,'WebGUI',2,'Vorlage',1031510000);
INSERT INTO international VALUES (503,'WebGUI',2,'ID der Vorlage',1031510000);
INSERT INTO international VALUES (502,'WebGUI',2,'Sind Sie sich sicher, dass Sie diese Vorlage löschen möchten und alle Seiten, die diese Vorlage benutzen somit auf die Standartvorlage setzen?',1031510000);
INSERT INTO international VALUES (500,'WebGUI',2,'ID der Seite',1031510000);
INSERT INTO international VALUES (5,'Product',2,'Sind Sie sich sicher, dass Sie diese Spezifikation löschen möchten?',1031510000);
INSERT INTO international VALUES (5,'MailForm',2,'Displayed',1031510000);
INSERT INTO international VALUES (499,'WebGUI',2,'Wobject ID',1031510000);
INSERT INTO international VALUES (498,'WebGUI',2,'Enddatum',1031510000);
INSERT INTO international VALUES (497,'WebGUI',2,'Anfangsdatum',1031510000);
INSERT INTO international VALUES (493,'WebGUI',2,'Zurück zur Seite.',1031510000);
INSERT INTO international VALUES (49,'Product',2,'Produktgewinn (benefit) hinzufügen oder bearbeiten',1031510000);
INSERT INTO international VALUES (488,'WebGUI',2,'Standartwert(e)',1031510000);
INSERT INTO international VALUES (487,'WebGUI',2,'mögliche Werte',1031510000);
INSERT INTO international VALUES (486,'WebGUI',2,'Datentyp',1031510000);
INSERT INTO international VALUES (483,'WebGUI',2,'Ja oder Nein',1031510000);
INSERT INTO international VALUES (482,'WebGUI',2,'Zahl (Integer)',1031510000);
INSERT INTO international VALUES (481,'WebGUI',2,'Telefonnummer',1031510000);
INSERT INTO international VALUES (480,'WebGUI',2,'Emailadresse',1031510000);
INSERT INTO international VALUES (48,'UserSubmission',2,'Diskussion zulassen?',1031510000);
INSERT INTO international VALUES (48,'Product',2,'Sind Sie sich sicher, dass Sie diesen Gewinn (benefit) löschen möchten? Er kann, wenn er einmal gelöscht wurde, nicht mehr wiederhergestellt werden.',1031510000);
INSERT INTO international VALUES (479,'WebGUI',2,'Datum',1031510000);
INSERT INTO international VALUES (478,'WebGUI',2,'URL',1031510000);
INSERT INTO international VALUES (477,'WebGUI',2,'HTML Bereich',1031510000);
INSERT INTO international VALUES (476,'WebGUI',2,'Textfeld',1031510000);
INSERT INTO international VALUES (475,'WebGUI',2,'Text',1031510000);
INSERT INTO international VALUES (474,'WebGUI',2,'Erforderlich?',1031510000);
INSERT INTO international VALUES (473,'WebGUI',2,'sichtbar?',1031510000);
INSERT INTO international VALUES (472,'WebGUI',2,'Label',1031510000);
INSERT INTO international VALUES (471,'WebGUI',2,'Benutzerprofilfeld bearbeiten',1031510000);
INSERT INTO international VALUES (470,'WebGUI',2,'Name',1031510000);
INSERT INTO international VALUES (47,'UserSubmission',2,'eine Antwort schreiben',1031510000);
INSERT INTO international VALUES (469,'WebGUI',2,'Id',1031510000);
INSERT INTO international VALUES (467,'WebGUI',2,'Sind Sie sich sicher, dass Sie dieses Feld und alle daraufbezogenen Benutzerdaten löschen möchten?',1031510000);
INSERT INTO international VALUES (466,'WebGUI',2,'Sind sie sich sicher, dass Sie diese Kategorie löschen möchten und alle ihre Felder in die Kategorie \'sonstiges\' verschieben möchten?',1031510000);
INSERT INTO international VALUES (465,'WebGUI',2,'Größe der Textbox',1031510000);
INSERT INTO international VALUES (464,'WebGUI',2,'Spalten des Textfeldes',1031510000);
INSERT INTO international VALUES (628,'WebGUI',2,'Wenn Sie ein Bild löschen, wird es endgültig gelöscht und kann nicht mehr wiederhergestellt werden. Sie sollten sich ganz sicher sein bevor Sie bestätigen, daß ein Bild gelöscht werden kann.',1031510000);
INSERT INTO international VALUES (696,'WebGUI',2,'Mülleimer leeren',1031510000);
INSERT INTO international VALUES (684,'WebGUI',2,'Vorlagen hinzufügen oder bearbeiten',1031510000);
INSERT INTO international VALUES (683,'WebGUI',2,'Vorlagen verwalten',1031510000);
INSERT INTO international VALUES (682,'WebGUI',2,'Benutzerpofil bearbeiten',1031510000);
INSERT INTO international VALUES (681,'WebGUI',2,'Packages, Creating',1031510000);
INSERT INTO international VALUES (680,'WebGUI',2,'\'Package\' hinzufügen',1031510000);
INSERT INTO international VALUES (686,'WebGUI',2,'Gruppe von Grafiken hinzufügen',1031510000);
INSERT INTO international VALUES (679,'WebGUI',2,'inhaltliche Einstellungen bearbeiten',1031510000);
INSERT INTO international VALUES (677,'WebGUI',2,'Wobject hinzufügen oder bearbeiten',1031510000);
INSERT INTO international VALUES (708,'WebGUI',2,'Sondereinstellungen verwalten',1031510000);
INSERT INTO international VALUES (706,'WebGUI',2,'Stunde(n)',1031510000);
INSERT INTO international VALUES (707,'WebGUI',2,'Fehlersuche anzeigen?',1031510000);
INSERT INTO international VALUES (699,'WebGUI',2,'Erster Tag der Woche',1031510000);
INSERT INTO international VALUES (702,'WebGUI',2,'Monat(e)',1031510000);
INSERT INTO international VALUES (703,'WebGUI',2,'Jahr(e)',1031510000);
INSERT INTO international VALUES (704,'WebGUI',2,'Sekunde(n)',1031510000);
INSERT INTO international VALUES (7,'MailForm',2,'Emailformular bearbeiten',1031510000);
INSERT INTO international VALUES (685,'WebGUI',2,'Vorlage löschen',1031510000);
INSERT INTO international VALUES (678,'WebGUI',2,'Hauptverzeichns verwalten',1031510000);
INSERT INTO international VALUES (676,'WebGUI',2,'Grafiken verwalten',1031510000);
INSERT INTO international VALUES (673,'WebGUI',2,'Grafik löschen',1031510000);
INSERT INTO international VALUES (675,'WebGUI',2,'Suchmaschine benutzen',1031510000);
INSERT INTO international VALUES (674,'WebGUI',2,'sonstige Einstellungen bearbeiten',1031510000);
INSERT INTO international VALUES (672,'WebGUI',2,'Profileinstellungen bearbeiten',1031510000);
INSERT INTO international VALUES (669,'WebGUI',2,'Makros verwenden',1031510000);
INSERT INTO international VALUES (668,'WebGUI',2,'\'Style Sheets\' verwenden',1031510000);
INSERT INTO international VALUES (697,'WebGUI',2,'\'Karma\' verwenden',1031510000);
INSERT INTO international VALUES (670,'WebGUI',2,'Grafik hinzufügen oder bearbeiten',1031510000);
INSERT INTO international VALUES (666,'WebGUI',2,'Gestaltung hinzufügen oder bearbeiten',1031510000);
INSERT INTO international VALUES (665,'WebGUI',2,'Gruppe löschen',1031510000);
INSERT INTO international VALUES (662,'WebGUI',2,'Einstellungen verwalten',1031510000);
INSERT INTO international VALUES (663,'WebGUI',2,'Email-Einstellungen bearbeiten',1031510000);
INSERT INTO international VALUES (705,'WebGUI',2,'Minute(n)',1031510000);
INSERT INTO international VALUES (661,'WebGUI',2,'DateiEinstellungen bearbeiten',1031510000);
INSERT INTO international VALUES (659,'WebGUI',2,'Gestaltungen verwalten',1031510000);
INSERT INTO international VALUES (658,'WebGUI',2,'Benutzer verwalten',1031510000);
INSERT INTO international VALUES (660,'WebGUI',2,'Gruppen verwalten',1031510000);
INSERT INTO international VALUES (655,'WebGUI',2,'Benutzer hinzufügen oder bearbeiten',1031510000);
INSERT INTO international VALUES (652,'WebGUI',2,'Benutzereinstelungen bearbeiten',1031510000);
INSERT INTO international VALUES (671,'WebGUI',2,'Wobjects benutzen',1031510000);
INSERT INTO international VALUES (657,'WebGUI',2,'Benutzer löschen',1031510000);
INSERT INTO international VALUES (667,'WebGUI',2,'Gruppe hinzufügen oder bearbeiten',1031510000);
INSERT INTO international VALUES (653,'WebGUI',2,'Seite löschen',1031510000);
INSERT INTO international VALUES (656,'WebGUI',2,'Informationen über das Unternehemen bearbeiten',1031510000);
INSERT INTO international VALUES (651,'WebGUI',2,'Falls Sie Ihren Mülleimer leeren, werden alle Posten darin unwiderruflich gelöscht. Wenn Sie sich über einige Posten nicht sicher sind, wäre es am besten, sie mittels \'ausschneiden\' in die Zwischenablage zu legen bevor Sie den Mülleimer leeren.',1031510000);
INSERT INTO international VALUES (664,'WebGUI',2,'Wobject löschen',1031510000);
INSERT INTO international VALUES (640,'WebGUI',2,'Es ist nicht sinnvoll Vorlagen zu löschen, da man nie weiß, welche ungünstige Auswirkung es auf die Seite haben kann (manche Seiten nutzen diese Vorlage eventuell noch). Wenn Sie eine Vorlage löschen, werden alle Seiten, die diese Vorlage noch benutzen, auf die Standardcorlage gesetzt.',1031510000);
INSERT INTO international VALUES (7,'Product',2,'Produktgrafik 3',1031510000);
INSERT INTO international VALUES (526,'WebGUI',2,'nur JavaScript entfernen',1031510000);
INSERT INTO international VALUES (547,'WebGUI',2,'Hauptgruppe',1031510000);
INSERT INTO international VALUES (552,'WebGUI',2,'Ausstehend',1031510000);
INSERT INTO international VALUES (551,'WebGUI',2,'Notiz/Bemerkung',1031510000);
INSERT INTO international VALUES (550,'WebGUI',2,'Gruppe von Grafiken ansehen',1031510000);
INSERT INTO international VALUES (542,'WebGUI',2,'Vorhergerige(r)',1031510000);
INSERT INTO international VALUES (55,'Product',2,'Gewinn (benefit) hinzufügen',1031510000);
INSERT INTO international VALUES (55,'UserSubmission',2,'traditionell',1031510000);
INSERT INTO international VALUES (549,'WebGUI',2,'Beschreibung der Gruppe',1031510000);
INSERT INTO international VALUES (548,'WebGUI',2,'Gruppenname',1031510000);
INSERT INTO international VALUES (539,'WebGUI',2,'\'Karma\' aktivieren?',1031510000);
INSERT INTO international VALUES (546,'WebGUI',2,'Id der Gruppe',1031510000);
INSERT INTO international VALUES (545,'WebGUI',2,'Gruppe von Grafiken bearbeiten',1031510000);
INSERT INTO international VALUES (535,'WebGUI',2,'Group To Alert On New User',1031510000);
INSERT INTO international VALUES (534,'WebGUI',2,'Bei neuem Benutzer benachrichtigen?',1031510000);
INSERT INTO international VALUES (536,'WebGUI',2,'Ein neuer Nebutzer mit dem Namen ^@, hat die Seite betreten',1031510000);
INSERT INTO international VALUES (544,'WebGUI',2,'Sind Sie sich sicher, dass Sie diese Gruppe löschen möchten?',1031510000);
INSERT INTO international VALUES (543,'WebGUI',2,'neue Gruppe von Bildern hinzufügen',1031510000);
INSERT INTO international VALUES (541,'WebGUI',2,'Karma Per Post',1031510000);
INSERT INTO international VALUES (537,'WebGUI',2,'Karma',1031510000);
INSERT INTO international VALUES (540,'WebGUI',2,'Karma Per Login',1031510000);
INSERT INTO international VALUES (54,'UserSubmission',2,'Web Log',1031510000);
INSERT INTO international VALUES (54,'Product',2,'Gewinne (benefits)',1031510000);
INSERT INTO international VALUES (533,'WebGUI',2,'ohne die Wörter',1031510000);
INSERT INTO international VALUES (525,'WebGUI',2,'inhaltliche Einstellungen bearbeiten',1031510000);
INSERT INTO international VALUES (522,'WebGUI',2,'Ich möchte über ICQ benachrichtigt werden.',1031510000);
INSERT INTO international VALUES (527,'WebGUI',2,'Standard Startseite',1031510000);
INSERT INTO international VALUES (528,'WebGUI',2,'Name der Vorlage',1031510000);
INSERT INTO international VALUES (523,'WebGUI',2,'Benachrichtigung',1031510000);
INSERT INTO international VALUES (38,'Product',2,'Produkt hinzufügen oder bearbeiten',1031510000);
INSERT INTO international VALUES (532,'WebGUI',2,'mit mindestens einem der Wörter',1031510000);
INSERT INTO international VALUES (36,'Product',2,'Zubehör hinzufügen',1031510000);
INSERT INTO international VALUES (531,'WebGUI',2,'mit genau dem Satz',1031510000);
INSERT INTO international VALUES (530,'WebGUI',2,'mit all diesen Wörtern',1031510000);
INSERT INTO international VALUES (433,'WebGUI',2,'Benutzeragent',1031510000);
INSERT INTO international VALUES (53,'UserSubmission',2,'Layout',1031510000);
INSERT INTO international VALUES (31,'Product',2,'Spezifikationen',1031510000);
INSERT INTO international VALUES (53,'Product',2,'Gewinn (benefit) bearbeiten',1031510000);
INSERT INTO international VALUES (30,'Product',2,'Eigenschaften',1031510000);
INSERT INTO international VALUES (3,'MailForm',2,'Vielen Dank für Ihren Beitrag!',1031510000);
INSERT INTO international VALUES (29,'Product',2,'Einheiten',1031510000);
INSERT INTO international VALUES (28,'Product',2,'Eine weitere Spezifikation hinzufügen?',1031510000);
INSERT INTO international VALUES (3,'Product',2,'Sind Sie sich sicher, dass Sie diese Eigenschaft löschen möchten?',1031510000);
INSERT INTO international VALUES (382,'WebGUI',2,'Grafik bearbeiten',1031510000);
INSERT INTO international VALUES (32,'Product',2,'Zubehör',1031510000);
INSERT INTO international VALUES (33,'Product',2,'Verwandte Produkte',1031510000);
INSERT INTO international VALUES (34,'Product',2,'Eine Eigenschaft hinzufügen',1031510000);
INSERT INTO international VALUES (61,'UserSubmission',2,'Benutzerbeitragssystem hinzufügen oder bearbeiten',1031510000);
INSERT INTO international VALUES (61,'SiteMap',2,'Site Map/Übersicht hinzufügen oder bearbeiten',1031510000);
INSERT INTO international VALUES (61,'SQLReport',2,'SQL Bericht hinzufügen oder bearbeiten',1031510000);
INSERT INTO international VALUES (61,'Product',2,'Produktvorlage',1031510000);
INSERT INTO international VALUES (61,'Poll',2,'Abstimmung hinzufügen oder bearbeiten',1031510000);
INSERT INTO international VALUES (61,'MessageBoard',2,'\'Diskussionsforum\' hinzufügen oder bearbeiten',1031510000);
INSERT INTO international VALUES (61,'LinkList',2,'Linkliste hinzufügen oder bearbeiten',1031510000);
INSERT INTO international VALUES (61,'Item',2,'Posten hinzufügen oder bearbeiten',1031510000);
INSERT INTO international VALUES (61,'FAQ',2,'FAQ hinzufügen oder bearbeiten',1031510000);
INSERT INTO international VALUES (61,'ExtraColumn',2,'zusätzliche Spalte hinzufügen oder bearbeiten',1031510000);
INSERT INTO international VALUES (61,'EventsCalendar',2,'Ereigniskalender hinzufügen oder bearbeiten',1031510000);
INSERT INTO international VALUES (61,'DownloadManager',2,'Download Manager hinzufügen/bearebiten',1031510000);
INSERT INTO international VALUES (61,'Article',2,'Artikel hinzufügen oder bearbeiten',1031510000);
INSERT INTO international VALUES (61,'MailForm',2,'Emailformular hinzufügen oder bearbeiten',1031510000);
INSERT INTO international VALUES (60,'Product',2,'Vorlage',1031510000);
INSERT INTO international VALUES (6,'Product',2,'Produkt bearbeiten',1031510000);
INSERT INTO international VALUES (6,'MailForm',2,'veränderbar',1031510000);
INSERT INTO international VALUES (6,'Item',2,'Posten bearbeiten',1031510000);
INSERT INTO international VALUES (597,'WebGUI',2,'Übersetzung bearbeiten',1031510000);
INSERT INTO international VALUES (596,'WebGUI',2,'fehlende Übersetzung',1031510000);
INSERT INTO international VALUES (598,'WebGUI',2,'Sprache bearbeiten',1031510000);
INSERT INTO international VALUES (594,'WebGUI',2,'Übersetzen',1031510000);
INSERT INTO international VALUES (593,'WebGUI',2,'Übersetzung zu Plain Black übermitteln',1031510000);
INSERT INTO international VALUES (592,'WebGUI',2,'Zeichensatz',1031510000);
INSERT INTO international VALUES (591,'WebGUI',2,'Sprache',1031510000);
INSERT INTO international VALUES (590,'WebGUI',2,'ID der Sprache',1031510000);
INSERT INTO international VALUES (595,'WebGUI',2,'Übersetzungen',1031510000);
INSERT INTO international VALUES (59,'Product',2,'Name',1031510000);
INSERT INTO international VALUES (589,'WebGUI',2,'Sprache bearbeiten',1031510000);
INSERT INTO international VALUES (588,'WebGUI',2,'Sind Sie sich sicher, dass Sie diese Übersetzung an Plain Black zur Einbeziehung in die Standardverteilung übermitteln wollen?\r\nWenn Sie den \'Ja\'-Link anklicken, erklären Sie sich damit einverstanden, dass Sie Plain Black eine unbeschränkte Lizenz zur Verwendung der Übersetzung in seiner Softwareverteilung geben.',1031510000);
INSERT INTO international VALUES (587,'WebGUI',2,'Sind Sie sich sicher, dass Sie diese Sprache und somit auch alle damit verbundene internationale und Hilfe -Nachrichten löschen möchten?',1031510000);
INSERT INTO international VALUES (586,'WebGUI',2,'Sprachen',1031510000);
INSERT INTO international VALUES (585,'WebGUI',2,'Übersetzungen bearbeiten',1031510000);
INSERT INTO international VALUES (584,'WebGUI',2,'Eine neue Sprache hinzufügen.',1031510000);
INSERT INTO international VALUES (35,'Product',2,'Spezifikation hinzufügen',1031510000);
INSERT INTO international VALUES (654,'WebGUI',2,'Gestaltung löschen',1031510000);
INSERT INTO international VALUES (581,'WebGUI',2,'neuen Wert hinzufügen',1031510000);
INSERT INTO international VALUES (642,'WebGUI',2,'Seite hinzufügen oder bearbeiten',1031510000);
INSERT INTO international VALUES (62,'Product',2,'Produktvorlage hinzufügen oder bearbeiten',1031510000);
INSERT INTO international VALUES (62,'MailForm',2,'Emailformularfelder hinzufügen oder bearbeiten',1031510000);
INSERT INTO international VALUES (605,'WebGUI',2,'Gruppen hinzufügen',1031510000);
INSERT INTO international VALUES (59,'UserSubmission',2,'nächster Beitrag',1031510000);
INSERT INTO international VALUES (583,'WebGUI',2,'maximale Größe einer Grafik',1031510000);
INSERT INTO international VALUES (582,'WebGUI',2,'freilassen',1031510000);
INSERT INTO international VALUES (580,'WebGUI',2,'Ihre Nachricht wurde abgelehnt.',1031510000);
INSERT INTO international VALUES (58,'UserSubmission',2,'vorheriger Beitrag',1031510000);
INSERT INTO international VALUES (58,'Product',2,'Produktvorlage bearbeiten',1031510000);
INSERT INTO international VALUES (579,'WebGUI',2,'Ihre Nachricht wurde akzeptiert.',1031510000);
INSERT INTO international VALUES (576,'WebGUI',2,'Löschen',1031510000);
INSERT INTO international VALUES (575,'WebGUI',2,'Bearbeiten',1031510000);
INSERT INTO international VALUES (57,'UserSubmission',2,'Antworten',1031510000);
INSERT INTO international VALUES (57,'Product',2,'Sind Sie sich sicher, dass Sie diese Vorlage löschen nud alle Produkte, die sie benutzen auf die Standardvorlage setzen möchten?',1031510000);
INSERT INTO international VALUES (569,'WebGUI',2,'Moderationsart',1031510000);
INSERT INTO international VALUES (56,'UserSubmission',2,'Fotogalerie',1031510000);
INSERT INTO international VALUES (56,'Product',2,'Eine Produktvorlage hinzufügen.',1031510000);
INSERT INTO international VALUES (557,'WebGUI',2,'Beschreibung',1031510000);
INSERT INTO international VALUES (556,'WebGUI',2,'Betrag',1031510000);
INSERT INTO international VALUES (553,'WebGUI',2,'Status',1031510000);
INSERT INTO international VALUES (529,'WebGUI',2,'Ergebnisse',1031510000);
INSERT INTO international VALUES (588,'WebGUI',1,'Are you certain you wish to submit this translation to Plain Black for inclusion in the official distribution of WebGUI? By clicking on the yes link you understand that you\'re giving Plain Black an unlimited license to use the translation in its software distributions.',1031514630);
INSERT INTO international VALUES (593,'WebGUI',1,'Submit translation.',1031514223);
INSERT INTO international VALUES (594,'WebGUI',1,'Translate messages.',1031514314);
INSERT INTO international VALUES (61,'UserSubmission',1,'User Submission System, Add/Edit',1031517089);
INSERT INTO international VALUES (71,'UserSubmission',1,'User Submission Systems are a great way to add a sense of community to any site as well as get free content from your users.\r\n<br><br>\r\n\r\n<b>Layout</b><br>\r\nWhat should this user submission system look like? Currently these are the views available:\r\n<ul>\r\n<li><b>Traditional</b> - Creates a simple spreadsheet style table that lists off each submission and is sorted by date. \r\n</li>\r\n<li><b>Web Log</b> - Creates a view that looks like the news site <a href=\"http://slashdot.org/\">Slashdot</a>. Incidentally, Slashdot invented the web log format, which has since become very popular on news oriented sites. To limit the amount of the article shown on the main page, place the separator macro ^-; where you\'d like the front page content to stop.\r\n</li>\r\n<li><b>Photo Gallery</b> - Creates a matrix of thumbnails that can be clicked on to view the full image.\r\n</li></ul>\r\n\r\n<b>Who can approve?</b><br>\r\nWhat group is allowed to approve and deny content?\r\n<br><br>\r\n\r\n<b>Who can contribute?</b><br>\r\nWhat group is allowed to contribute content?\r\n<br><br>\r\n\r\n<b>Submissions Per Page</b><br>\r\nHow many submissions should be listed per page in the submissions index?\r\n<br><br>\r\n\r\n<b>Default Status</b><br>\r\nShould submissions be set to <i>Approved</i>, <i>Pending</i>, or <i>Denied</i> by default?\r\n<br><br>\r\n<i>Note:</i> If you set the default status to Pending, then be prepared to monitor your message log for new submissions.\r\n<p>\r\n\r\n<b>Karma Per Submission</b><br>\r\nHow much karma should be given to a user when they contribute to this user submission system?\r\n<p>\r\n\r\n\r\n<b>Display thumbnails?</b><br>\r\nIf there is an image present in the submission, the thumbnail will be displayed in the Layout (see above).\r\n<p>\r\n\r\n<b>Allow discussion?</b><br>\r\nDo you wish to attach a discussion to this user submission system? If you do, users will be able to comment on each submission.\r\n<p>\r\n\r\n<b>Who can post?</b><br>\r\nSelect the group that is allowed to post to this discussion.\r\n<p>\r\n\r\n<b>Edit Timeout</b><br>\r\nHow long should a user be able to edit their post before editing is locked to them?\r\n<p>\r\n<i>Note:</i> Don\'t set this limit too high. One of the great things about discussions is that they are an accurate record of who said what. If you allow editing for a long time, then a user has a chance to go back and change his/her mind a long time after the original statement was made.\r\n<p>\r\n\r\n<b>Karma Per Post</b><br>\r\nHow much karma should be given to a user when they post to this discussion?\r\n<p>\r\n\r\n<b>Who can moderate?</b><br>\r\nSelect the group that is allowed to moderate this discussion.\r\n<p>\r\n\r\n<b>Moderation Type?</b><br>\r\nYou can select what type of moderation you\'d like for your users. <i>After-the-fact</i> means that when a user posts a message it is displayed publically right away. <i>Pre-emptive</i> means that a moderator must preview and approve users posts before allowing them to be publically visible. Alerts for new posts will automatically show up in the moderator\'s WebGUI Inbox.\r\n<p>\r\nNote: In both types of moderation the moderator can always edit or delete the messages posted by your users.\r\n<p>\r\n',1031517089);
INSERT INTO international VALUES (722,'WebGUI',1,'Id',1031517195);
INSERT INTO international VALUES (721,'WebGUI',1,'Namespace',1031515005);
INSERT INTO international VALUES (720,'WebGUI',1,'OK',1031514777);
INSERT INTO international VALUES (719,'WebGUI',1,'Out of Date',1031514679);
INSERT INTO international VALUES (718,'WebGUI',1,'Export translation.',1031514184);
INSERT INTO international VALUES (12,'Poll',1,'Total Votes:',1031514049);
INSERT INTO international VALUES (12,'Poll',7,'×ÜÍ¶Æ±ÈËÊý:',1031514049);
INSERT INTO international VALUES (723,'WebGUI',1,'Deprecated',1031800566);
INSERT INTO international VALUES (727,'WebGUI',1,'Your password cannot be \"password\".',1031880154);
INSERT INTO international VALUES (725,'WebGUI',1,'Your username cannot be blank.',1031879612);
INSERT INTO international VALUES (724,'WebGUI',1,'Your username cannot begin or end with a space.',1031879593);
INSERT INTO international VALUES (726,'WebGUI',1,'Your password cannot be blank.',1031879567);

--
-- Table structure for table 'karmaLog'
--

CREATE TABLE karmaLog (
  userId int(11) NOT NULL default '0',
  amount int(11) NOT NULL default '1',
  source varchar(255) default NULL,
  description text,
  dateModified int(11) NOT NULL default '1026097656'
) TYPE=MyISAM;

--
-- Dumping data for table 'karmaLog'
--



--
-- Table structure for table 'language'
--

CREATE TABLE language (
  languageId int(11) NOT NULL default '0',
  language varchar(255) default NULL,
  characterSet varchar(255) default NULL,
  PRIMARY KEY  (languageId)
) TYPE=MyISAM;

--
-- Dumping data for table 'language'
--


INSERT INTO language VALUES (1,'English','ISO-8859-1');
INSERT INTO language VALUES (2,'Deutsch','ISO-8859-1');
INSERT INTO language VALUES (3,'Nederlands','ISO-8859-1');
INSERT INTO language VALUES (4,'Español','ISO-8859-1');
INSERT INTO language VALUES (5,'Português','ISO-8859-1');
INSERT INTO language VALUES (6,'Svenska','ISO-8859-1');
INSERT INTO language VALUES (7,'¼òÌåÖÐÎÄ (Chinese Simple)','gb2312');
INSERT INTO language VALUES (8,'Italiano','ISO-8859-1');
INSERT INTO language VALUES (9,'ÁcÊ^¤¤¤å (Chinese Traditional)','BIG5');
INSERT INTO language VALUES (10,'Dansk','ISO-8859-1');

--
-- Table structure for table 'messageLog'
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
-- Dumping data for table 'messageLog'
--



--
-- Table structure for table 'page'
--

CREATE TABLE page (
  pageId int(11) NOT NULL default '0',
  parentId int(11) NOT NULL default '0',
  title varchar(255) default NULL,
  styleId int(11) NOT NULL default '0',
  ownerId int(11) NOT NULL default '0',
  ownerView int(11) NOT NULL default '1',
  ownerEdit int(11) NOT NULL default '1',
  groupId int(11) default NULL,
  groupView int(11) NOT NULL default '1',
  groupEdit int(11) NOT NULL default '0',
  worldView int(11) NOT NULL default '1',
  worldEdit int(11) NOT NULL default '0',
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
  PRIMARY KEY  (pageId)
) TYPE=MyISAM;

--
-- Dumping data for table 'page'
--


INSERT INTO page VALUES (1,0,'Home',-6,3,1,1,1,1,0,1,0,0,'','home',1,'Home',NULL,1,946710000,2082783600,NULL);
INSERT INTO page VALUES (4,0,'Page Not Found',-6,3,1,1,1,1,0,1,0,21,'','page_not_found',0,'Page Not Found',NULL,1,946710000,2082783600,NULL);
INSERT INTO page VALUES (3,0,'Trash',5,3,1,1,3,1,1,0,0,22,'','trash',0,'Trash',NULL,1,946710000,2082783600,NULL);
INSERT INTO page VALUES (2,0,'Clipboard',4,3,1,1,4,1,1,0,0,23,'','clipboard',0,'Clipboard',NULL,1,946710000,2082783600,NULL);
INSERT INTO page VALUES (5,0,'Packages',1,3,0,0,6,1,1,0,0,24,'','packages',0,'Packages',NULL,1,946710000,2082783600,NULL);

--
-- Table structure for table 'settings'
--

CREATE TABLE settings (
  name varchar(255) NOT NULL default '',
  value text,
  PRIMARY KEY  (name)
) TYPE=MyISAM;

--
-- Dumping data for table 'settings'
--


INSERT INTO settings VALUES ('maxAttachmentSize','300');
INSERT INTO settings VALUES ('sessionTimeout','28000');
INSERT INTO settings VALUES ('smtpServer','localhost');
INSERT INTO settings VALUES ('companyEmail','info@mycompany.com');
INSERT INTO settings VALUES ('ldapURL','ldap://ldap.mycompany.com:389/o=MyCompany');
INSERT INTO settings VALUES ('companyName','My Company');
INSERT INTO settings VALUES ('companyURL','http://www.mycompany.com');
INSERT INTO settings VALUES ('ldapId','shortname');
INSERT INTO settings VALUES ('ldapIdName','LDAP Shortname');
INSERT INTO settings VALUES ('ldapPasswordName','LDAP Password');
INSERT INTO settings VALUES ('authMethod','WebGUI');
INSERT INTO settings VALUES ('anonymousRegistration','1');
INSERT INTO settings VALUES ('notFoundPage','1');
INSERT INTO settings VALUES ('recoverPasswordEmail','Someone (probably you) requested your account information be sent. Your password has been reset. The following represents your new account information:');
INSERT INTO settings VALUES ('usernameBinding','0');
INSERT INTO settings VALUES ('profileName','1');
INSERT INTO settings VALUES ('profileExtraContact','1');
INSERT INTO settings VALUES ('profileMisc','1');
INSERT INTO settings VALUES ('profileHome','0');
INSERT INTO settings VALUES ('profileWork','0');
INSERT INTO settings VALUES ('docTypeDec','<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">');
INSERT INTO settings VALUES ('preventProxyCache','0');
INSERT INTO settings VALUES ('thumbnailSize','50');
INSERT INTO settings VALUES ('filterContributedHTML','most');
INSERT INTO settings VALUES ('textAreaRows','5');
INSERT INTO settings VALUES ('textAreaCols','50');
INSERT INTO settings VALUES ('textBoxSize','30');
INSERT INTO settings VALUES ('richEditor','built-in');
INSERT INTO settings VALUES ('addEditStampToPosts','1');
INSERT INTO settings VALUES ('defaultPage','1');
INSERT INTO settings VALUES ('onNewUserAlertGroup','3');
INSERT INTO settings VALUES ('alertOnNewUser','0');
INSERT INTO settings VALUES ('useKarma','0');
INSERT INTO settings VALUES ('karmaPerLogin','1');
INSERT INTO settings VALUES ('runOnRegistration','');
INSERT INTO settings VALUES ('maxImageSize','100000');
INSERT INTO settings VALUES ('imageManagersGroup','9');
INSERT INTO settings VALUES ('showDebug','0');
INSERT INTO settings VALUES ('styleManagersGroup','5');
INSERT INTO settings VALUES ('templateManagersGroup','8');

--
-- Table structure for table 'style'
--

CREATE TABLE style (
  styleId int(11) NOT NULL default '0',
  name varchar(255) default NULL,
  styleSheet text,
  body text,
  PRIMARY KEY  (styleId)
) TYPE=MyISAM;

--
-- Dumping data for table 'style'
--


INSERT INTO style VALUES (-3,'WebGUI','<style>\r\n\r\n.content, body {\r\n  background-color: #000000;\r\n  color: #C9E200;\r\n  font-family: helvetica, arial;\r\n  font-size: 10pt;\r\n  scrollbar-base-color: #000000;\r\n  scrollbar-track-color: #444444;\r\n  scrollbar-face-color: #000000;\r\n  scrollbar-highlight-color: #555555;\r\n  scrollbar-3dlight-color: #444444;\r\n  scrollbar-darkshadow-color: #222222;\r\n  scrollbar-shadow-color: #333333;\r\n  scrollbar-arrow-color: #ED4400;\r\n}\r\n\r\nselect, input, textarea {\r\n  color: #000000;\r\n  background-color: #C9E200;\r\n}\r\n\r\nA {\r\n  color: #ED4400;\r\n}\r\n\r\nA:visited {\r\n  color: #ffffff;\r\n}\r\n\r\n.verticalMenu {\r\n  font-size: 10pt;\r\n}\r\n\r\n.verticalMenu A, .verticalMenu A:visited {\r\n  color: #000000;\r\n}\r\n\r\n.verticalMenu A:hover {\r\n  color: #ED4400;\r\n}\r\n\r\n.selectedMenuItem A,.selectedMenuItem A:visited {\r\n  color: #ED4400;\r\n}\r\n\r\n.loginBox {\r\n  font-size: 10pt;\r\n}\r\n\r\nH1 {\r\n  font-family: helvetica, arial;\r\n  font-size: 16pt;\r\n}\r\n\r\nsearchBox {\r\n  font-size: 10pt;\r\n}\r\n\r\n.pagination {\r\n  font-family: helvetica, arial;\r\n  font-size: 8pt;\r\n  text-align: center;\r\n}\r\n\r\n.adminBar {\r\n        background-color: #dddddd;\r\n        font-size: 8pt;\r\n        font-family: helvetica, arial;\r\n        color: #000055;\r\n}\r\n\r\n.formDescription {\r\n  font-family: helvetica, arial;\r\n  font-size: 10pt;\r\n  font-weight: bold;\r\n}\r\n\r\n.formSubtext {\r\n  font-family: helvetica, arial;\r\n  font-size: 8pt;\r\n}\r\n\r\n.highlight {\r\n  background-color: #444444;\r\n}\r\n\r\n.tableMenu {\r\n  background-color: #444444;\r\n  font-size: 8pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.tableMenu a {\r\n  text-decoration: none;\r\n}\r\n\r\n.tableHeader {\r\n  background-color: #555555;\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.tableData {\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.pollAnswer {\r\n  font-family: Helvetica, Arial;\r\n  font-size: 8pt;\r\n}\r\n\r\n.pollColor {\r\n  background-color: #C9E200;\r\n}\r\n\r\n.pollQuestion {\r\n  font-face: Helvetica, Arial;\r\n  font-weight: bold;\r\n}\r\n\r\n.faqQuestion {\r\n  font-size: 12pt;\r\n  color: #aaaaaa;\r\n}\r\n</style>','^AdminBar;\r\n\r\n<body bgcolor=\"#000000\" text=\"#C9E200\" link=\"#ED4400\" marginwidth=\"0\" leftmargin=\"0\">\r\n<table width=\"100%\" cellpadding=0 cellspacing=0 border=0>\r\n<tr><td valign=\"top\" width=\"200\">\r\n<a href=\"/\"><img src=\"^Extras;styles/webgui/logo.gif\" border=0></a>\r\n<table cellpadding=0 border=0 cellspacing=0>\r\n<tr><td colspan=3><img src=\"^Extras;styles/webgui/menuTop.gif\" width=\"200\"></td></tr>\r\n<tr>\r\n  <td bgcolor=\"#C9E200\"><img src=\"^Extras;spacer.gif\" width=5></td>\r\n  <td bgcolor=\"#C9E200\">^FlexMenu;</td>\r\n  <td bgcolor=\"#C9E200\"><img src=\"^Extras;spacer.gif\" width=5></td>\r\n</tr>\r\n<tr><td colspan=3><img src=\"^Extras;styles/webgui/menuBottom.gif\" width=\"200\"></td></tr>\r\n</table>\r\n^L;\r\n</td>\r\n<td><img src=\"^Extras;spacer.gif\" width=20></td>\r\n<td valign=\"top\" width=\"100%\">\r\n\r\n\r\n\r\n^-;\r\n\r\n</td></tr></table>\r\n<p>\r\n<div align=\"center\">\r\n<a href=\"/\"><img src=\"^Extras;styles/webgui/icon.gif\" border=0></a><br>\r\n©2001-2002 Plain Black Software<br>\r\n</div>\r\n</body>');
INSERT INTO style VALUES (2,'Fail Safe','<style>\r\n.adminBar {\r\n        background-color: #dddddd;\r\n        font-size: 8pt;\r\n        font-family: helvetica, arial;\r\n        color: #000055;\r\n}\r\n</style>','^AdminBar;\n\n<body>\r\n^H; / ^t; / ^m; / ^a;\r\n<hr>\n\n^-;\n\n<hr>\r\n^H; / ^t; / ^m; / ^a;\r\n</body>');
INSERT INTO style VALUES (-2,'Plain Black Software (black)','<style>\r\n\r\n.content{\r\n  background-color: #000000;\r\n  color: #ffffff;\r\n  font-family: helvetica, arial;\r\n  font-size: 10pt;\r\n  padding: 10pt;\r\n}\r\n\r\n.sideMenu {\r\n  filter:DropShadow(OffX=2,OffY=2,color:#000000);\r\n  font-size: 10pt;\r\n  padding: 5pt;\r\n  font-family: helvetica, arial;\r\n  color: #000000;\r\n}\r\n\r\n.sideMenu A {\r\n  text-decoration: none;\r\n  color: #ffffff;\r\n}\r\n\r\n.sideMenu A:hover {\r\n  color: #EF4200;\r\n  text-decoration: underline;\r\n}\r\n\r\nH1 {\r\n  font-family: helvetica, arial;\r\n  font-size: 16pt;\r\n  color: #cee700;\r\n}\r\n\r\nsearchBox {\r\n  font-size: 10pt;\r\n}\r\n\r\nA {\r\n  color: #EF4200;\r\n}\r\n\r\n.pagination {\r\n  font-family: helvetica, arial;\r\n  font-size: 8pt;\r\n  text-align: center;\r\n}\r\n\r\n.adminBar {\r\n  background-color: #dddddd;\r\n  font-size: 8pt;\r\n  font-family: helvetica, arial;\r\n  color: #000055;\r\n}\r\n\r\n.crumbTrail {\r\n  font-family: helvetica, arial;\r\n  color: #cee700;\r\n  font-size: 8pt;\r\n}\r\n\r\n.crumbTrail A,.crumbTrail A:visited {\r\n  color: #ffffff;\r\n}\r\n\r\n.formDescription {\r\n  font-family: helvetica, arial;\r\n  font-size: 10pt;\r\n  font-weight: bold;\r\n}\r\n\r\n.formSubtext {\r\n  font-family: helvetica, arial;\r\n  font-size: 8pt;\r\n}\r\n\r\n.highlight {\r\n  background-color: #535558;\r\n}\r\n\r\n.tableMenu {\r\n  background-color: #38393C;\r\n  font-size: 8pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.tableMenu a {\r\n  text-decoration: none;\r\n}\r\n\r\n.tableHeader {\r\n  background-color: #38393C;\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.tableData {\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.pollAnswer {\r\n  font-family: Helvetica, Arial;\r\n  font-size: 8pt;\r\n}\r\n\r\n.pollColor {\r\n  background-color: #cee700;\r\n  border: thin solid #ffffff;\r\n}\r\n\r\n.pollQuestion {\r\n  font-face: Helvetica, Arial;\r\n  font-weight: bold;\r\n}\r\n\r\n.faqQuestion {\r\n  font-size: 12pt;\r\n  color: #cee700;\r\n}\r\n\r\n</style>','^AdminBar;\n\n<body text=\"#ffffff\" link=\"#EF4200\" vlink=\"#EF4200\" bgcolor=\"#535558\" marginwidth=0 marginheight=0 leftmargin=0 rightmargin=0 topmargin=0 bottommargin=0>\r\n\r\n<table cellspacing=0 cellpadding=0 border=0 width=\"100%\">\r\n<tr>\r\n	<td width=\"200\" rowspan=\"2\" bgcolor=\"#ffffff\"><a href=\"/\"><img src=\"^Extras;styles/plainblack/logo-white.gif\" width=\"200\" height=\"50\" alt=\"Plain Black Software\" border=\"0\"></a></td>\r\n	<td width=\"70%\" bgcolor=\"#38393C\" valign=\"bottom\"><img src=\"^Extras;spacer.gif\" width=\"5\"><img src=\"^Extras;styles/plainblack/user.gif\" width=\"41\" height=\"25\" alt=\"User:\" border=\"0\"> <a href=\"^\\;?op=displayAccount\" style=\"font-family: courier; color: #cee700; text-decoration: none; vertical-align: middle;\">^@;</a></td>\r\n	<td width=\"30%\" align=\"right\" bgcolor=\"#38393C\" valign=\"bottom\"><a href=\"^\\;?op=displayAccount\"><img src=\"^Extras;styles/plainblack/myaccount.gif\" width=\"84\" height=\"25\" alt=\"My Account\" border=\"0\"></a><img src=\"^Extras;styles/plainblack/darkbar.gif\" width=\"11\" height=\"25\" alt=\"|\" border=\"0\"><a href=\"^/;/download\"><img src=\"^Extras;styles/plainblack/download.gif\" width=\"75\" height=\"25\" alt=\"Download\" border=\"0\"></a><img src=\"^Extras;styles/plainblack/darkbar.gif\" width=\"11\" height=\"25\" alt=\"|\" border=\"0\"><a href=\"/\"><img src=\"^Extras;styles/plainblack/home.gif\" width=\"40\" height=\"25\" alt=\"Home\" border=\"0\"></a><img src=\"^Extras;spacer.gif\" width=\"5\"></td>\r\n</tr>\r\n<tr>\r\n	<td width=\"70%\" bgcolor=\"#535558\"><img src=\"^Extras;spacer.gif\" width=\"5\">^C;</td>\r\n	<td width=\"30%\" align=\"right\" bgcolor=\"#535558\" style=\"font-family: courier; color: #cee700;\">^D(\"%c %D, %y\");<img src=\"^Extras;spacer.gif\" width=\"5\"></td>\r\n</tr>\r\n</table>\r\n<table cellspacing=0 cellpadding=0 border=0 width=\"100%\" bgcolor=\"#38393C\">\r\n<tr>\r\n	<td width=\"200\" valign=\"top\" class=\"sideMenu\">^T(2);</td>\r\n	<td width=\"100%\" bgcolor=\"#000000\" rowspan=\"2\" valign=\"top\">\n\n^-;\n\n</td>\r\n</tr>\r\n<tr>\r\n	<td width=\"200\" bgcolor=\"#38393C\" align=\"center\" valign=\"bottom\"><p><img src=\"^Extras;styles/plainblack/webgui.gif\" width=\"200\" height=\"84\" alt=\"\" border=\"0\"><p></td>\r\n</tr>\r\n</table>\r\n<table cellspacing=0 cellpadding=0 border=0 width=\"100%\">\r\n<tr>\r\n	<td width=\"50%\" bgcolor=\"#535558\"><img src=\"^Extras;styles/plainblack/copyright.gif\" width=\"223\" height=\"25\" alt=\"Copyright 2001-2002 Plain Black Software\" border=\"0\"></td>\r\n	<td width=\"50%\" align=\"right\" bgcolor=\"#535558\"><a href=\"^r(linkonly);\"><img src=\"^Extras;styles/plainblack/makepageprintable.gif\" width=\"149\" height=\"25\" alt=\"Make Page Printable\" border=\"0\"></a></td>\r\n</tr>\r\n</table>\r\n</body>\r\n');
INSERT INTO style VALUES (4,'Clipboard','<style>\r\n.adminBar {\r\n        background-color: #dddddd;\r\n        font-size: 8pt;\r\n        font-family: helvetica, arial;\r\n        color: #000055;\r\n}\r\n</style>','^AdminBar;\n\n<body>\r\n<table width=\"100%\">\r\n<tr><td><span style=\"font-size: 36pt;\">Clipboard</span>\r\n</td>\r\n<td align=\"right\">^H; / ^a;</td></tr>\r\n<tr><td bgcolor=\"#000000\" colspan=\"2\"><img src=\"^Extras;spacer.gif\" height=\"1\"></td></tr>\r\n</table>\r\n<table width=\"100%\"><tr><td valign=\"top\" width=\"30%\"><b>PAGES</b><br>^FlexMenu;</td><td width=\"1\" bgcolor=\"#000000\"><img src=\"^Extras;spacer.gif\" width=\"1\"></td><td valign=\"top\" width=\"70%\"><b>CONTENT</b><br>\n\n^-;\n\n</td></tr></table>\r\n<table width=\"100%\">\r\n<tr><td bgcolor=\"#000000\" colspan=\"2\"><img src=\"^Extras;spacer.gif\" height=\"1\"></td></tr>\r\n</table>\r\n^H; / ^a;\r\n</body>');
INSERT INTO style VALUES (-1,'Yahoo!','','^AdminBar;\n\n<html><head><title>Yahoo!</title><meta http-equiv=\"PICS-Label\" content=\'(PICS-1.1 \"http://www.rsac.org/ratingsv01.html\" l gen true for \"http://www.yahoo.com\" r (n 0 s 0 v 0 l 0))\'></head><body>\r\n<script language=javascript><!--\r\nfunction f(){\r\nvar f,m,p,a,i,k,o,e,l,c,d;\r\nf=\"0123456789abcdefghijklmnopqrstuvwxyz\";\r\nm=new Array;\r\np=\"claim-your-name\";\r\na=10;\r\nfor(i=0;i<36;i++){\r\n if(i==26)a=-26;\r\n m[f.charAt(i)]=f.charAt(i+a);\r\n}\r\nk=document.cookie;\r\nif((o=k.indexOf(\"Y=\"))==-1)return p;\r\nif((o=k.indexOf(\"l=\",o+2))==-1)return p;\r\nif((e=k.indexOf(\"/\",o+2))==-1)return p;\r\nif(e>o+18)e=o+18;\r\nl=k.substring(o+2,e);\r\np=\"\";\r\nfor(i=0;i<l.length;i++){\r\n c=l.charAt(i);\r\n if(m[c])p+=m[c];else p+=\'-\';\r\n}\r\nreturn p;\r\n}\r\nd=f();//-->\r\n</script>\r\n<center><form name=f action=http://search.yahoo.com/bin/search><map name=m><area coords=\"0,0,52,52\" href=r/c1><area coords=\"53,0,121,52\" href=r/p1><area coords=\"122,0,191,52\" href=r/m1><area coords=\"441,0,510,52\" href=r/wn><area coords=\"511,0,579,52\" href=r/i1><area coords=\"580,0,637,52\" href=r/hw></map><img width=638 height=53 border=0 usemap=\"#m\" src=http://us.a1.yimg.com/us.yimg.com/i/ww/m5v5.gif alt=Yahoo><br><table border=0 cellspacing=0 cellpadding=3 width=640><tr><td align=center width=205>\r\n<font color=ff0020>new!</font> <a href=\"http://www.yahoo.com/homet/?http://new.domains.yahoo.com\"><b>Y! Domains</b></a><br><small>reserve .biz & .info domains</small></td><td align=center><a href=\"http://rd.yahoo.com/M=77122.1317476.2909345.220161/D=yahoo_top/S=2716149:NP/A=656341/?http://website.yahoo.com/\" target=\"_top\"><img width=230 height=33 src=\"http://us.a1.yimg.com/us.yimg.com/a/pr/promo/anchor/hp_website2.gif\" alt=\"\" border=0></a></td><td align=center width=205><a href=\"http://www.yahoo.com//homet/?http://mail.yahoo.com\"><b>Yahoo! Mail</b></a><br>you@yahoo.com</td></tr><tr><td colspan=3 align=center><input size=30 name=p>\r\n<input type=submit value=Search> <a href=http://www.yahoo.com/r/so>advanced search</a></td></tr></table>\r\n</form>\r\n<div align=\"left\">\r\n\n\n^-;\n\n</div>\r\n<hr noshade size=1 width=640><small><a href=http://www.yahoo.com/r/ad>How to Suggest a Site</a> -\r\n<a href=http://www.yahoo.com/r/cp>Company Info</a> -\r\n<a href=http://www.yahoo.com/r/cy>Copyright Policy</a> -\r\n<a href=http://www.yahoo.com/r/ts>Terms of Service</a> -\r\n<a href=http://www.yahoo.com/r/cb>Contributors</a> -\r\n<a href=http://www.yahoo.com/r/hr>Jobs</a> -\r\n<a href=http://www.yahoo.com/r/ao>Advertising</a><p>Copyright © 2001 Yahoo! Inc. All rights reserved.</small><br><a href=http://www.yahoo.com/r/pv>Privacy Policy</a></form></center></body></html>\r\n');
INSERT INTO style VALUES (-4,'Demo Style','<style>\r\n\r\n.homeLink, .myAccountLink, {\r\n  color: #ffffff;\r\n  font-size: 8pt;\r\n}\r\n\r\n.verticalMenu A, .verticalMenu A:visited {\r\n  color: #ffffff;\r\n  font-weight: bold;\r\n}\r\n\r\nbody {\r\n  font-family:arial; \r\n  font-size: 12px; \r\n  color: black;\r\n  background: #666666;\r\n}\r\n\r\ntd { \r\n  font-size: 11px;\r\n}\r\n\r\nH1 {\r\n  MARGIN-TOP: 3px;\r\n  MARGIN-BOTTOM: 3px;\r\n  font-size: 16pt;\r\n}\r\n\r\nH3 {\r\n  MARGIN-TOP: 3px;\r\n  MARGIN-BOTTOM: 3px;\r\n}\r\n\r\nH4 {\r\n  MARGIN-TOP: 3px;\r\n  MARGIN-BOTTOM: 3px;\r\n}\r\n\r\nH5 {\r\n  MARGIN-TOP: 3px;\r\n  MARGIN-BOTTOM: 3px;\r\n}\r\n\r\nul { \r\n  MARGIN-TOP: 3px; \r\n  MARGIN-BOTTOM: 3px \r\n}\r\n\r\nA {\r\n  color: #800000;\r\n  TEXT-DECORATION: underline\r\n}\r\n\r\nA:hover {\r\n  color: #990000;\r\n  TEXT-DECORATION: none;\r\n}\r\n\r\n.pagination {\r\n  font-family: helvetica, arial;\r\n  text-align: center;\r\n  font-size: 8pt;\r\n}\r\n\r\n.horizontalMenu {\r\n  font-size: 8pt;\r\n  padding: 5px;\r\n  font-weight: bold;\r\n  color: #aaaaaa;\r\n}\r\n\r\n.horizontalMenu A, .horizontalMenu A:visited {\r\n  color: #ffffff;\r\n}\r\n\r\n.adminBar {\r\n        background-color: #dddddd;\r\n        font-size: 8pt;\r\n        font-family: helvetica, arial;\r\n        color: #000055;\r\n}\r\n\r\n.highlight {\r\n  background-color: #EAEAEA;\r\n}\r\n\r\n.formDescription {\r\n  font-size: 10pt;\r\n}\r\n\r\n.formSubtext {\r\n  font-size: 8pt;\r\n}\r\n\r\n.tableMenu {\r\n  font-size: 8pt;\r\n  background-color: #F5DFDF;\r\n}\r\n.tableMenu a {\r\n  text-decoration: none;\r\n}\r\n\r\n.tableHeader {\r\n  background-color: #F5DFDF;\r\n  font-size: 10pt;\r\n}\r\n\r\n.tableData {\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.pollAnswer {\r\n  font-family: Helvetica, Arial;\r\n  font-size: 8pt;\r\n}\r\n\r\n.pollColor {\r\n  background-color: #ffddbb;\r\n}\r\n\r\n.pollQuestion {\r\n  font-face: Helvetica, Arial;\r\n  font-weight: bold;\r\n}\r\n\r\n.faqQuestion {\r\n  color: #000000;\r\n  font-weight: bold;\r\n  text-decoration: none;\r\n}\r\n\r\n</style>','^AdminBar;\n\n<body bgcolor=\"#666666\">\r\n\r\n<table border=\"0\" width=\"700\" background=\"^Extras;styles/demo/topbg-3.gif\" cellspacing=\"0\" cellpadding=\"0\" align=\"center\">\r\n<tr>\r\n    <td width=\"324\" height=\"80\"><img src=\"^Extras;styles/demo/top-3.jpg\" border=0 width=\"324\"></td>\r\n    <td width=\"100%\"><h3 style=\"color:white\">Your Company Name Here</h3><div style=\"color:white\">Address: 1903 Sunrise St. City, State 65977<br>\r\nTel: 915.888.8888<br>\r\nEmail: service@company.com</div></td>\r\n  </tr>\r\n</table>\r\n<table border=\"0\" width=\"700\"  height=\"21\" cellspacing=\"0\" cellpadding=\"0\" bgcolor=\"#000000\" align=center>\r\n  <tr>\r\n    <td><img src=\"^Extras;styles/demo/mid-3.jpg\" border=0 width=\"140\" height=\"21\"></td>\r\n    <td width=\"100%\">^t;</td>\r\n  </tr>\r\n</table>\r\n<table border=\"0\" width=\"700\"  height=\"500\" cellspacing=\"0\" cellpadding=\"0\" align=center>\r\n  <tr>\r\n    <td bgcolor=\"#990000\" width=\"140\" style=\"background-image: url(\'^Extras;styles/demo/leftbg-3.jpg\'); background-repeat: no-repeat; background-position: left top\" valign=\"top\"><img src=\"^Extras;spacer.gif\" height=\"10\" width=\"140\" border=0>\r\n<table cellpadding=4><tr><td>\r\n^M;\r\n</td></tr></table>\r\n    </td>\r\n    <td width=\"100%\" align=\"right\" height=\"100%\" valign=\"top\"><img src=\"^Extras;styles/demo/x.gif\" height=\"4\" width=\"560\"><br>\r\n    <table  width=\"99%\" height=\"99%\" border=\"0\" bgcolor=\"black\" cellpadding=\"3\" cellspacing=\"1\">\r\n    	<tr><td bgcolor=\"#f9ecec\" style=\"background-image: url(\'^Extras;styles/demo/contentbg-3.gif\'); background-repeat: no-repeat; background-position: right bottom\" height=\"100%\" valign=\"top\">\r\n    	\n\n^-;\n\n	</td></tr>\r\n    </table>\r\n    </td>\r\n  </tr>\r\n</table>\r\n<table border=\"0\" width=\"700\" cellspacing=\"0\" cellpadding=\"0\" align=\"center\">\r\n<tr><td align=\"right\">^H; · ^a;</td></tr>\r\n</table>\r\n\r\n\r\n</body>\r\n');
INSERT INTO style VALUES (3,'Make Page Printable','<style>\r\n\r\n.content{\r\n  background-color: #ffffff;\r\n  color: #000000;\r\n  font-family: helvetica, arial;\r\n  font-size: 10pt;\r\n  padding: 10pt;\r\n}\r\n\r\nH1 {\r\n  font-family: helvetica, arial;\r\n  font-size: 16pt;\r\n}\r\n\r\nA {\r\n  color: #EF4200;\r\n}\r\n\r\n.pagination {\r\n  font-family: helvetica, arial;\r\n  font-size: 8pt;\r\n  text-align: center;\r\n}\r\n\r\n.formDescription {\r\n  font-family: helvetica, arial;\r\n  font-size: 10pt;\r\n  font-weight: bold;\r\n}\r\n\r\n.formSubtext {\r\n  font-family: helvetica, arial;\r\n  font-size: 8pt;\r\n}\r\n\r\n.highlight {\r\n  background-color: #dddddd;\r\n}\r\n\r\n.tableMenu {\r\n  background-color: #cccccc;\r\n  font-size: 8pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.tableMenu a {\r\n  text-decoration: none;\r\n}\r\n\r\n.tableHeader {\r\n  background-color: #cccccc;\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.tableData {\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.pollAnswer {\r\n  font-family: Helvetica, Arial;\r\n  font-size: 8pt;\r\n}\r\n\r\n.pollColor {\r\n  background-color: #444444;\r\n}\r\n\r\n.pollQuestion {\r\n  font-face: Helvetica, Arial;\r\n  font-weight: bold;\r\n}\r\n\r\n.faqQuestion {\r\n  font-size: 12pt;\r\n  font-weight: bold;\r\n  color: #000000;\r\n}\r\n\r\n</style>','^AdminBar;\n\n<body onLoad=\"window.print()\">\r\n<div align=\"center\"><a href=\"^\\;\"><img src=\"^Extras;styles/plainblack/logo-white.gif\" border=\"0\"></a></div>\n\n^-;\n\n<div align=\"center\">© 2001-2002 Plain Black Software</div>\r\n</body>');
INSERT INTO style VALUES (-5,'Plain Black Software (white)','<style>\r\n\r\n.content{\r\n  background-color: #ffffff;\r\n  color: #000000;\r\n  font-family: helvetica, arial;\r\n  font-size: 10pt;\r\n  padding: 10pt;\r\n}\r\n\r\n.sideMenu {\r\n  filter:DropShadow(OffX=2,OffY=2,color:#000000);\r\n  font-size: 10pt;\r\n  padding: 5pt;\r\n  font-family: helvetica, arial;\r\n  color: #000000;\r\n}\r\n\r\n.sideMenu A {\r\n  text-decoration: none;\r\n  color: #ffffff;\r\n}\r\n\r\n.sideMenu A:hover {\r\n  color: #EF4200;\r\n  text-decoration: underline;\r\n}\r\n\r\nH1 {\r\n  font-family: helvetica, arial;\r\n  font-size: 16pt;\r\n  color: #38393C;\r\n}\r\n\r\nsearchBox {\r\n  font-size: 10pt;\r\n}\r\n\r\nA {\r\n  color: #EF4200;\r\n}\r\n\r\n.pagination {\r\n  font-family: helvetica, arial;\r\n  font-size: 8pt;\r\n  text-align: center;\r\n}\r\n\r\n.adminBar {\r\n  background-color: #dddddd;\r\n  font-size: 8pt;\r\n  font-family: helvetica, arial;\r\n  color: #000055;\r\n}\r\n\r\n.crumbTrail {\r\n  font-family: helvetica, arial;\r\n  color: #cee700;\r\n  font-size: 8pt;\r\n}\r\n\r\n.crumbTrail A,.crumbTrail A:visited {\r\n  color: #ffffff;\r\n}\r\n\r\n.formDescription {\r\n  font-family: helvetica, arial;\r\n  font-size: 10pt;\r\n  font-weight: bold;\r\n}\r\n\r\n.formSubtext {\r\n  font-family: helvetica, arial;\r\n  font-size: 8pt;\r\n}\r\n\r\n.highlight {\r\n  background-color: #cccccc;\r\n}\r\n\r\n.tableMenu {\r\n  background-color: #cee700;\r\n  font-size: 8pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.tableMenu a {\r\n  text-decoration: none;\r\n}\r\n\r\n.tableHeader {\r\n  background-color: #cee700;\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.tableData {\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.pollAnswer {\r\n  font-family: Helvetica, Arial;\r\n  font-size: 8pt;\r\n}\r\n\r\n.pollColor {\r\n  background-color: #cee700;\r\n  border: thin solid #000000;\r\n}\r\n\r\n.pollQuestion {\r\n  font-face: Helvetica, Arial;\r\n  font-weight: bold;\r\n}\r\n\r\n.faqQuestion {\r\n  font-size: 12pt;\r\n  color: #38393C;\r\n  font-weight: bold;\r\n}\r\n\r\n</style>','^AdminBar;\n\n<body text=\"#000000\" link=\"#EF4200\" vlink=\"#EF4200\" bgcolor=\"#535558\" marginwidth=0 marginheight=0 leftmargin=0 rightmargin=0 topmargin=0 bottommargin=0>\r\n\r\n<table cellspacing=0 cellpadding=0 border=0 width=\"100%\">\r\n<tr>\r\n	<td width=\"200\" rowspan=\"2\" bgcolor=\"#000000\"><a href=\"/\"><img src=\"^Extras;styles/plainblack/logo-black.gif\" width=\"200\" height=\"50\" alt=\"Plain Black Software\" border=\"0\"></a></td>\r\n	<td width=\"70%\" bgcolor=\"#38393C\" valign=\"bottom\"><img src=\"^Extras;spacer.gif\" width=\"5\"><img src=\"^Extras;styles/plainblack/user.gif\" width=\"41\" height=\"25\" alt=\"User:\" border=\"0\"> <a href=\"^\\;?op=displayAccount\" style=\"font-family: courier; color: #cee700; text-decoration: none; vertical-align: middle;\">^@;</a></td>\r\n	<td width=\"30%\" align=\"right\" bgcolor=\"#38393C\" valign=\"bottom\"><a href=\"^\\;?op=displayAccount\"><img src=\"^Extras;styles/plainblack/myaccount.gif\" width=\"84\" height=\"25\" alt=\"My Account\" border=\"0\"></a><img src=\"^Extras;styles/plainblack/darkbar.gif\" width=\"11\" height=\"25\" alt=\"|\" border=\"0\"><a href=\"^/;/download\"><img src=\"^Extras;styles/plainblack/download.gif\" width=\"75\" height=\"25\" alt=\"Download\" border=\"0\"></a><img src=\"^Extras;styles/plainblack/darkbar.gif\" width=\"11\" height=\"25\" alt=\"|\" border=\"0\"><a href=\"/\"><img src=\"^Extras;styles/plainblack/home.gif\" width=\"40\" height=\"25\" alt=\"Home\" border=\"0\"></a><img src=\"^Extras;spacer.gif\" width=\"5\"></td>\r\n</tr>\r\n<tr>\r\n	<td width=\"70%\" bgcolor=\"#535558\"><img src=\"^Extras;spacer.gif\" width=\"5\">^C;</td>\r\n	<td width=\"30%\" align=\"right\" bgcolor=\"#535558\" style=\"font-family: courier; color: #cee700;\">^D(\"%c %D, %y\");<img src=\"^Extras;spacer.gif\" width=\"5\"></td>\r\n</tr>\r\n</table>\r\n<table cellspacing=0 cellpadding=0 border=0 width=\"100%\" bgcolor=\"#38393C\">\r\n<tr>\r\n	<td width=\"200\" valign=\"top\" class=\"sideMenu\">^T(2);</td>\r\n	<td width=\"100%\" bgcolor=\"#ffffff\" rowspan=\"2\" valign=\"top\">\n\n^-;\n\n</td>\r\n</tr>\r\n<tr>\r\n	<td width=\"200\" bgcolor=\"#38393C\" align=\"center\" valign=\"bottom\"><p><img src=\"^Extras;styles/plainblack/webgui.gif\" width=\"200\" height=\"84\" alt=\"\" border=\"0\"><p></td>\r\n</tr>\r\n</table>\r\n<table cellspacing=0 cellpadding=0 border=0 width=\"100%\">\r\n<tr>\r\n	<td width=\"50%\" bgcolor=\"#535558\"><img src=\"^Extras;styles/plainblack/copyright.gif\" width=\"223\" height=\"25\" alt=\"Copyright 2001-2002 Plain Black Software\" border=\"0\"></td>\r\n	<td width=\"50%\" align=\"right\" bgcolor=\"#535558\"><a href=\"^r(linkonly);\"><img src=\"^Extras;styles/plainblack/makepageprintable.gif\" width=\"149\" height=\"25\" alt=\"Make Page Printable\" border=\"0\"></a></td>\r\n</tr>\r\n</table>\r\n</body>\r\n');
INSERT INTO style VALUES (5,'Trash','<style>\r\n.adminBar {\r\n        background-color: #dddddd;\r\n        font-size: 8pt;\r\n        font-family: helvetica, arial;\r\n        color: #000055;\r\n}\r\n</style>','^AdminBar;\n\n<body>\r\n<table width=\"100%\">\r\n<tr><td><span style=\"font-size: 36pt;\">Trash</span>\r\n</td>\r\n<td align=\"right\">^H; / ^a; / <a href=\"^\\;?op=purgeTrash\">Empty Trash</a></td></tr>\r\n<tr><td bgcolor=\"#000000\" colspan=\"2\"><img src=\"^Extras;spacer.gif\" height=\"1\"></td></tr>\r\n</table>\r\n<table width=\"100%\"><tr><td valign=\"top\" width=\"30%\"><b>PAGES</b><br>^FlexMenu;</td><td width=\"1\" bgcolor=\"#000000\"><img src=\"^Extras;spacer.gif\" width=\"1\"></td><td valign=\"top\" width=\"70%\"><b>CONTENT</b><br>\n\n^-;\n\n</td></tr></table>\r\n<table width=\"100%\">\r\n<tr><td bgcolor=\"#000000\" colspan=\"2\"><img src=\"^Extras;spacer.gif\" height=\"1\"></td></tr>\r\n</table>\r\n^H; / ^a; / <a href=\"^\\;?op=purgeTrash\">Empty Trash</a>\r\n</body>');
INSERT INTO style VALUES (1,'Packages','<style>\r\n.adminBar {\r\n        background-color: #dddddd;\r\n        font-size: 8pt;\r\n        font-family: helvetica, arial;\r\n        color: #000055;\r\n}\r\n</style>','^AdminBar;\n\n<body>\r\n<table width=\"100%\">\r\n<tr><td><span style=\"font-size: 36pt;\">Packages</span>\r\n</td>\r\n<td align=\"right\">^H; / ^a;</td></tr>\r\n<tr><td bgcolor=\"#000000\" colspan=\"2\"><img src=\"^Extras;spacer.gif\" height=\"1\"></td></tr>\r\n</table>\r\n<table width=\"100%\"><tr><td valign=\"top\" width=\"30%\"><b>PACKAGES</b><br>^FlexMenu;</td><td width=\"1\" bgcolor=\"#000000\"><img src=\"^Extras;spacer.gif\" width=\"1\"></td><td valign=\"top\" width=\"70%\"><b>CONTENT</b><br>\n\n^-;\n\n</td></tr></table>\r\n<table width=\"100%\">\r\n<tr><td bgcolor=\"#000000\" colspan=\"2\"><img src=\"^Extras;spacer.gif\" height=\"1\"></td></tr>\r\n</table>\r\n^H; / ^a;\r\n</body>');
INSERT INTO style VALUES (-6,'WebGUI 4','<META NAME=\"Keywords\" CONTENT=\"WebGUI Content Management System\">\r\n<style>\r\n<!--\r\nbody {font-family: Arial, Helvetica, sans-serif; }\r\na:active {color: #00CCCC; text-decoration: none; background-color: #FFFFCC; }\r\na:visited {color: #003399; text-decoration: none; }\r\na:link {color: #003399; text-decoration: none; }\r\n.myAccountLink {font-weight: bold; }\r\n.verticalMenu, .tableMenu {font-family: \"Times New Roman\", Times, serif; font-style: italic; }\r\n.crumbTrail {color: #990000; font-weight: bold; }\r\nh1 {color: #990000; }\r\nh2 {color: #990000; }\r\nh3 {color: #990000; }\r\nhr {size: 2px; color: #003399;}\r\n\r\n\r\n.highlight {\r\n  background-color: #cccccc;\r\n}\r\n\r\n.tableHeader {\r\n  background-color: #eeeeee;\r\n  font-size: 13px;\r\n}\r\n\r\n.tableData {\r\n  font-size: 13px;\r\n  background-color: #fafafa;\r\n}\r\n\r\n.pollAnswer {\r\n  font-family: Helvetica, Arial;\r\n  font-size: 11px;\r\n}\r\n\r\n.pollColor {\r\n  background-color: #ae2155;\r\n  border: thin solid #000000;\r\n}\r\n\r\n.pollQuestion {\r\n  font-weight: bold;\r\n}\r\n\r\n.faqQuestion {\r\n  font-size: 12pt;\r\n  font-weight: bold;\r\n}\r\n.faqQuestion A {\r\n  text-decoration: none;\r\n  color: black;\r\n}\r\n\r\n-->\r\n</style>','<body bgcolor=\"#FFFFFF\" text=\"#000000\" leftmargin=\"0\" topmargin=\"0\">\r\n<table width=\"100%\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\" align=\"center\">\r\n<tr><!-- top row -->\r\n<td align=\"left\" valign=\"top\"><a href=\"^H(linkonly);\"><img\r\n\r\n    src=\"^Extras;styles/webgui/webgui4.jpg\"\r\n    width=\"142\"\r\n    height=\"48\"\r\n    alt=\"WebGUI\" border=\"0\"></a></td>\r\n<td valign=\"top\">^AdminBar;</td>\r\n<td align=\"right\">\r\n<a href=\"^r(linkonly);\"><img src=\"^Extras;styles/webgui/print.png\" border=\"0\" alt=\"Print!\"></a>\r\n</td>\r\n</tr><tr>\r\n</tr>\r\n</table>\r\n<table width=\"100%\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\" align=\"center\">\r\n<tr>\r\n <td colspan=\"2\" height=\"1\"\r\n     background=\"^Extras;styles/webgui/purplepixel.jpg\">\r\n </td>\r\n</tr>\r\n<tr><!-- row for username and crumbtrail -->\r\n <td width=\"120\"\r\n     height=\"20\"\r\n     align=\"left\"\r\n     valign=\"middle\"><table border=\"0\"><tr><td><strong>User:</strong>\r\n     ^a(^@;);</td></tr></table></td>\r\n <td align=\"left\"\r\n     valign=\"middle\"><strong>Location:</strong> ^C;</td>\r\n</tr>\r\n<tr>\r\n <td colspan=\"2\" height=\"1\"\r\n     background=\"^Extras;styles/webgui/purplepixel.jpg\">\r\n </td>\r\n</tr>\r\n</table>\r\n<table width=\"100%\" border=\"0\" cellspacing=\"0\" height=\"50%\" cellpadding=\"0\" align=\"center\">\r\n<tr><!-- row for verticalmenu and content -->\r\n <td width=\"120\"\r\n     align=\"left\"\r\n     valign=\"top\">\r\n   <!-- extra table -->\r\n   <table border=\"0\">\r\n   <tr><td>^FlexMenu;</td></tr>\r\n   <tr><td height=\"30\"></td></tr>\r\n   </table>\r\n   <!-- /extra table -->\r\n </td>\r\n <td align=\"left\"\r\n     valign=\"top\">\r\n\r\n\r\n^-;\r\n\r\n\r\n\r\n<p>\r\n</td>\r\n</tr>\r\n<tr>\r\n <td colspan=\"2\" height=\"1\"\r\n     background=\"^Extras;styles/webgui/purplepixel.jpg\">\r\n </td>\r\n</tr>\r\n<tr><!-- row for date, printable and WebGUI link -->\r\n <td height=\"20\"\r\n     align=\"center\">^D(\"%c %D %y\");</td><td align=\"center\">Powered by <a href=\"http://www.plainblack.com/webgui\">WebGUI</a></td>\r\n</tr>\r\n</table>\r\n</body>\r\n\r\n');

--
-- Table structure for table 'template'
--

CREATE TABLE template (
  templateId int(11) NOT NULL default '0',
  name varchar(255) default NULL,
  template text,
  PRIMARY KEY  (templateId)
) TYPE=MyISAM;

--
-- Dumping data for table 'template'
--


INSERT INTO template VALUES (1,'Default','<table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" width=\"100%\">\r\n<tr>\r\n  <td valign=\"top\" class=\"content\">^0;</td>\r\n</tr>\r\n</table>');
INSERT INTO template VALUES (2,'News','<table cellpadding=\"3\" cellspacing=\"0\" border=\"0\" width=\"100%\">\r\n<tr>\r\n  <td valign=\"top\" class=\"content\" colspan=\"2\" width=\"100%\">^0;</td></tr>\r\n<tr>\r\n  <td valign=\"top\" class=\"content\" width=\"50%\">^1;</td>\r\n  <td valign=\"top\" class=\"content\" width=\"50%\">^2;</td>\r\n</tr>\r\n<tr>\r\n  <td valign=\"top\" class=\"content\" colspan=\"2\" width=\"100%\">^3;</td>\r\n</tr>\r\n</table>\r\n');
INSERT INTO template VALUES (3,'One Over Three','<table cellpadding=\"3\" cellspacing=\"0\" border=\"0\" width=\"100%\">\r\n<tr>\r\n  <td valign=\"top\" class=\"content\" colspan=\"3\">^0;</td>\r\n</tr>\r\n<tr>\r\n  <td valign=\"top\" class=\"content\" width=\"33%\">^1;</td>\r\n  <td valign=\"top\" class=\"content\" width=\"34%\">^2;</td>\r\n  <td valign=\"top\" class=\"content\" width=\"33%\">^3;</td>\r\n</tr>\r\n</table>');
INSERT INTO template VALUES (4,'Three Over One','<table cellpadding=\"3\" cellspacing=\"0\" border=\"0\" width=\"100%\">\r\n<tr>\r\n  <td valign=\"top\" class=\"content\" width=\"33%\">^0;</td>\r\n  <td valign=\"top\" class=\"content\" width=\"34%\">^1;</td>\r\n  <td valign=\"top\" class=\"content\" width=\"33%\">^2;</td>\r\n</tr>\r\n<tr>\r\n  <td valign=\"top\" class=\"content\" colspan=\"3\">^3;</td>\r\n</tr>\r\n</table>');
INSERT INTO template VALUES (5,'Left Column','<table cellpadding=\"3\" cellspacing=\"0\" border=\"0\" width=\"100%\">\r\n<tr>\r\n  <td valign=\"top\" class=\"content\" width=\"34%\">^0;</td>\r\n  <td valign=\"top\" class=\"content\" width=\"66%\">^1;</td>\r\n</tr>\r\n</table>');
INSERT INTO template VALUES (6,'Right Column','<table cellpadding=\"3\" cellspacing=\"0\" border=\"0\" width=\"100%\">\r\n<tr>\r\n  <td valign=\"top\" class=\"content\" width=\"66%\">^0;</td>\r\n  <td valign=\"top\" class=\"content\" width=\"34%\">^1;</td>\r\n</tr>\r\n</table>\r\n');
INSERT INTO template VALUES (7,'Side By Side','<table cellpadding=\"3\" cellspacing=\"0\" border=\"0\" width=\"100%\">\r\n<tr>\r\n  <td valign=\"top\" class=\"content\" width=\"50%\">^0;</td>\r\n  <td valign=\"top\" class=\"content\" width=\"50%\">^1;</td>\r\n</tr>\r\n</table>\r\n');

--
-- Table structure for table 'userLoginLog'
--

CREATE TABLE userLoginLog (
  userId int(11) default NULL,
  status varchar(30) default NULL,
  timeStamp int(11) default NULL,
  ipAddress varchar(128) default NULL,
  userAgent text
) TYPE=MyISAM;

--
-- Dumping data for table 'userLoginLog'
--



--
-- Table structure for table 'userProfileCategory'
--

CREATE TABLE userProfileCategory (
  profileCategoryId int(11) NOT NULL default '0',
  categoryName varchar(255) default NULL,
  sequenceNumber int(11) NOT NULL default '1',
  PRIMARY KEY  (profileCategoryId)
) TYPE=MyISAM;

--
-- Dumping data for table 'userProfileCategory'
--


INSERT INTO userProfileCategory VALUES (1,'WebGUI::International::get(449,\"WebGUI\");',6);
INSERT INTO userProfileCategory VALUES (2,'WebGUI::International::get(440,\"WebGUI\");',2);
INSERT INTO userProfileCategory VALUES (3,'WebGUI::International::get(439,\"WebGUI\");',1);
INSERT INTO userProfileCategory VALUES (4,'WebGUI::International::get(445,\"WebGUI\");',7);
INSERT INTO userProfileCategory VALUES (5,'WebGUI::International::get(443,\"WebGUI\");',3);
INSERT INTO userProfileCategory VALUES (6,'WebGUI::International::get(442,\"WebGUI\");',4);
INSERT INTO userProfileCategory VALUES (7,'WebGUI::International::get(444,\"WebGUI\");',5);

--
-- Table structure for table 'userProfileData'
--

CREATE TABLE userProfileData (
  userId int(11) NOT NULL default '0',
  fieldName varchar(128) NOT NULL default '',
  fieldData text,
  PRIMARY KEY  (userId,fieldName)
) TYPE=MyISAM;

--
-- Dumping data for table 'userProfileData'
--


INSERT INTO userProfileData VALUES (1,'language','1');
INSERT INTO userProfileData VALUES (3,'language','1');

--
-- Table structure for table 'userProfileField'
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
  PRIMARY KEY  (fieldName)
) TYPE=MyISAM;

--
-- Dumping data for table 'userProfileField'
--


INSERT INTO userProfileField VALUES ('email','WebGUI::International::get(56,\"WebGUI\");',1,1,'email',NULL,NULL,1,2,1);
INSERT INTO userProfileField VALUES ('firstName','WebGUI::International::get(314,\"WebGUI\");',1,0,'text',NULL,NULL,1,3,1);
INSERT INTO userProfileField VALUES ('middleName','WebGUI::International::get(315,\"WebGUI\");',1,0,'text',NULL,NULL,2,3,1);
INSERT INTO userProfileField VALUES ('lastName','WebGUI::International::get(316,\"WebGUI\");',1,0,'text',NULL,NULL,3,3,1);
INSERT INTO userProfileField VALUES ('icq','WebGUI::International::get(317,\"WebGUI\");',1,0,'text',NULL,NULL,2,2,1);
INSERT INTO userProfileField VALUES ('aim','WebGUI::International::get(318,\"WebGUI\");',1,0,'text',NULL,NULL,3,2,1);
INSERT INTO userProfileField VALUES ('msnIM','WebGUI::International::get(319,\"WebGUI\");',1,0,'text',NULL,NULL,4,2,1);
INSERT INTO userProfileField VALUES ('yahooIM','WebGUI::International::get(320,\"WebGUI\");',1,0,'text',NULL,NULL,5,2,1);
INSERT INTO userProfileField VALUES ('cellPhone','WebGUI::International::get(321,\"WebGUI\");',1,0,'phone',NULL,NULL,6,2,1);
INSERT INTO userProfileField VALUES ('pager','WebGUI::International::get(322,\"WebGUI\");',1,0,'phone',NULL,NULL,7,2,1);
INSERT INTO userProfileField VALUES ('emailToPager','WebGUI::International::get(441,\"WebGUI\");',1,0,'email',NULL,NULL,8,2,1);
INSERT INTO userProfileField VALUES ('language','WebGUI::International::get(304,\"WebGUI\");',1,0,'select','WebGUI::International::getLanguages()','[1]',1,4,1);
INSERT INTO userProfileField VALUES ('homeAddress','WebGUI::International::get(323,\"WebGUI\");',1,0,'text',NULL,NULL,1,5,1);
INSERT INTO userProfileField VALUES ('homeCity','WebGUI::International::get(324,\"WebGUI\");',1,0,'text',NULL,NULL,2,5,1);
INSERT INTO userProfileField VALUES ('homeState','WebGUI::International::get(325,\"WebGUI\");',1,0,'text',NULL,NULL,3,5,1);
INSERT INTO userProfileField VALUES ('homeZip','WebGUI::International::get(326,\"WebGUI\");',1,0,'zipcode',NULL,NULL,4,5,1);
INSERT INTO userProfileField VALUES ('homeCountry','WebGUI::International::get(327,\"WebGUI\");',1,0,'text',NULL,NULL,5,5,1);
INSERT INTO userProfileField VALUES ('homePhone','WebGUI::International::get(328,\"WebGUI\");',1,0,'phone',NULL,NULL,6,5,1);
INSERT INTO userProfileField VALUES ('workAddress','WebGUI::International::get(329,\"WebGUI\");',1,0,'text',NULL,NULL,2,6,1);
INSERT INTO userProfileField VALUES ('workCity','WebGUI::International::get(330,\"WebGUI\");',1,0,'text',NULL,NULL,3,6,1);
INSERT INTO userProfileField VALUES ('workState','WebGUI::International::get(331,\"WebGUI\");',1,0,'text',NULL,NULL,4,6,1);
INSERT INTO userProfileField VALUES ('workZip','WebGUI::International::get(332,\"WebGUI\");',1,0,'zipcode',NULL,NULL,5,6,1);
INSERT INTO userProfileField VALUES ('workCountry','WebGUI::International::get(333,\"WebGUI\");',1,0,'text',NULL,NULL,6,6,1);
INSERT INTO userProfileField VALUES ('workPhone','WebGUI::International::get(334,\"WebGUI\");',1,0,'phone',NULL,NULL,7,6,1);
INSERT INTO userProfileField VALUES ('gender','WebGUI::International::get(335,\"WebGUI\");',1,0,'select','{\r\n  \'neuter\'=>WebGUI::International::get(403),\r\n  \'male\'=>WebGUI::International::get(339),\r\n  \'female\'=>WebGUI::International::get(340)\r\n}','[\'neuter\']',1,7,1);
INSERT INTO userProfileField VALUES ('birthdate','WebGUI::International::get(336,\"WebGUI\");',1,0,'text',NULL,NULL,2,7,1);
INSERT INTO userProfileField VALUES ('homeURL','WebGUI::International::get(337,\"WebGUI\");',1,0,'url',NULL,NULL,7,5,1);
INSERT INTO userProfileField VALUES ('workURL','WebGUI::International::get(446,\"WebGUI\");',1,0,'url',NULL,NULL,8,6,1);
INSERT INTO userProfileField VALUES ('workName','WebGUI::International::get(450,\"WebGUI\");',1,0,'text',NULL,NULL,1,6,1);
INSERT INTO userProfileField VALUES ('timeOffset','WebGUI::International::get(460,\"WebGUI\");',1,0,'text',NULL,'\'0\'',3,4,1);
INSERT INTO userProfileField VALUES ('dateFormat','WebGUI::International::get(461,\"WebGUI\");',1,0,'select','{\r\n \'%M/%D/%y\'=>WebGUI::DateTime::epochToHuman(\"\",\"%M/%D/%y\"),\r\n \'%y-%m-%d\'=>WebGUI::DateTime::epochToHuman(\"\",\"%y-%m-%d\"),\r\n \'%D-%c-%y\'=>WebGUI::DateTime::epochToHuman(\"\",\"%D-%c-%y\"),\r\n \'%c %D, %y\'=>WebGUI::DateTime::epochToHuman(\"\",\"%c %D, %y\")\r\n}\r\n','[\'%M/%D/%y\']',4,4,1);
INSERT INTO userProfileField VALUES ('timeFormat','WebGUI::International::get(462,\"WebGUI\");',1,0,'select','{\r\n \'%H:%n %p\'=>WebGUI::DateTime::epochToHuman(\"\",\"%H:%n %p\"),\r\n \'%H:%n:%s %p\'=>WebGUI::DateTime::epochToHuman(\"\",\"%H:%n:%s %p\"),\r\n \'%j:%n\'=>WebGUI::DateTime::epochToHuman(\"\",\"%j:%n\"),\r\n \'%j:%n:%s\'=>WebGUI::DateTime::epochToHuman(\"\",\"%j:%n:%s\")\r\n}\r\n','[\'%H:%n %p\']',5,4,1);
INSERT INTO userProfileField VALUES ('discussionLayout','WebGUI::International::get(509)',1,0,'select','{\r\n  threaded=>WebGUI::International::get(511),\r\n  flat=>WebGUI::International::get(510)\r\n}','[\'threaded\']',6,4,0);
INSERT INTO userProfileField VALUES ('INBOXNotifications','WebGUI::International::get(518)',1,0,'select','{ \r\n  none=>WebGUI::International::get(519),\r\n email=>WebGUI::International::get(520),\r\n  emailToPager=>WebGUI::International::get(521),\r\n  icq=>WebGUI::International::get(522)\r\n}','[\'email\']',7,4,0);
INSERT INTO userProfileField VALUES ('firstDayOfWeek','WebGUI::International::get(699,\"WebGUI\");',1,0,'select','{0=>WebGUI::International::get(27,\"WebGUI\"),1=>WebGUI::International::get(28,\"WebGUI\")}','[0]',3,4,1);

--
-- Table structure for table 'userSession'
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
-- Dumping data for table 'userSession'
--



--
-- Table structure for table 'users'
--

CREATE TABLE users (
  userId int(11) NOT NULL default '0',
  username varchar(35) default NULL,
  identifier varchar(128) default NULL,
  authMethod varchar(30) NOT NULL default 'WebGUI',
  ldapURL text,
  connectDN varchar(255) default NULL,
  dateCreated int(11) NOT NULL default '1019867418',
  lastUpdated int(11) NOT NULL default '1019867418',
  karma int(11) NOT NULL default '0',
  PRIMARY KEY  (userId)
) TYPE=MyISAM;

--
-- Dumping data for table 'users'
--


INSERT INTO users VALUES (1,'Visitor','No Login','WebGUI',NULL,NULL,1019867418,1019867418,0);
INSERT INTO users VALUES (3,'Admin','RvlMjeFPs2aAhQdo/xt/Kg','WebGUI','','',1019867418,1019935552,0);

--
-- Table structure for table 'webguiVersion'
--

CREATE TABLE webguiVersion (
  webguiVersion varchar(10) default NULL,
  versionType varchar(30) default NULL,
  dateApplied int(11) default NULL
) TYPE=MyISAM;

--
-- Dumping data for table 'webguiVersion'
--


INSERT INTO webguiVersion VALUES ('4.6.8','initial install',unix_timestamp());

--
-- Table structure for table 'wobject'
--

CREATE TABLE wobject (
  wobjectId int(11) NOT NULL default '0',
  pageId int(11) default NULL,
  namespace varchar(35) default NULL,
  sequenceNumber int(11) NOT NULL default '1',
  title varchar(255) default NULL,
  displayTitle int(11) NOT NULL default '1',
  description mediumtext,
  processMacros int(11) NOT NULL default '0',
  dateAdded int(11) default NULL,
  addedBy int(11) default NULL,
  lastEdited int(11) default NULL,
  editedBy int(11) default NULL,
  templatePosition int(11) NOT NULL default '0',
  startDate int(11) default NULL,
  endDate int(11) default NULL,
  groupToPost int(11) NOT NULL default '2',
  editTimeout int(11) NOT NULL default '1',
  groupToModerate int(11) NOT NULL default '4',
  karmaPerPost int(11) NOT NULL default '0',
  moderationType varchar(30) NOT NULL default 'after',
  userDefined1 varchar(255) default NULL,
  userDefined2 varchar(255) default NULL,
  userDefined3 varchar(255) default NULL,
  userDefined4 varchar(255) default NULL,
  userDefined5 varchar(255) default NULL,
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table 'wobject'
--


INSERT INTO wobject VALUES (-1,4,'SiteMap',0,'Page Not Found',1,'The page you were looking for could not be found on this system. Perhaps it has been deleted or renamed. The following list is a site map of this site. If you don\'t find what you\'re looking for on the site map, you can always start from the <a href=\"^/;\">Home Page</a>.',1,1001744792,3,1016077239,3,0,1001744792,1336444487,2,3600,4,0,'after',NULL,NULL,NULL,NULL,NULL);
INSERT INTO wobject VALUES (-2,1,'Article',1,'Welcome to WebGUI!',1,'<DIV>\r\n<P class=MsoNormal style=\"MARGIN: 0in 0in 0pt\">If you’re reading this message it means that you’ve got WebGUI up and running. Good job! The installation is not trivial.</P>\r\n<P class=MsoNormal style=\"MARGIN: 0in 0in 0pt\"> <?xml:namespace prefix = o ns = \"urn:schemas-microsoft-com:office:office\" /><o:p></o:p></P>\r\n<P class=MsoNormal style=\"MARGIN: 0in 0in 0pt\">In order to do anything useful with your new installation you’ll need to log in as the default administrator account. Follow these steps to get started:</P>\r\n<P class=MsoNormal style=\"MARGIN: 0in 0in 0pt\"> <o:p></o:p></P>\r\n<OL style=\"MARGIN-TOP: 0in\" type=1>\r\n<LI class=MsoNormal style=\"MARGIN: 0in 0in 0pt; mso-list: l1 level1 lfo2; tab-stops: list .5in\"><A href=\"^\\;?op=displayLogin\">Click here to log in.</A> (username: Admin password: 123qwe) \r\n<LI class=MsoNormal style=\"MARGIN: 0in 0in 0pt; mso-list: l1 level1 lfo2; tab-stops: list .5in\"><A href=\"^\\;?op=switchOnAdmin\">Click here to turn the administrative interface on.</A></LI></OL>\r\n<P class=MsoNormal style=\"MARGIN: 0in 0in 0pt\"> Now that you’re in as the administrator, you should <A href=\"^\\;?op=displayAccount\">change your password</A> so no one else can log in and mess with your site. You might also want to <A href=\"^\\;?op=addUser\">create another account </A>for yourself with Administrative privileges in case you can\'t log in with the Admin account for some reason.</P>\r\n<P class=MsoNormal style=\"MARGIN: 0in 0in 0pt\"> <o:p></o:p></P>\r\n<P class=MsoNormal style=\"MARGIN: 0in 0in 0pt\">You’ll notice three menus at the top of your screen. Those are your administrative menus. Going from left to right they are <I>Content</I>, <I>Clipboard</I>, and <I>Admin</I>. The content menu allows you to add new pages and content to your site. The clipboard menu is currently empty, but if you cut or copy anything from any of your pages, it will end up there. The admin menu controls things like system settings and users.</P>\r\n<P class=MsoNormal style=\"MARGIN: 0in 0in 0pt\"> <o:p></o:p></P>\r\n<P class=MsoNormal style=\"MARGIN: 0in 0in 0pt\">For more information about how to administer WebGUI consider getting a copy of <I><A href=\"http://www.plainblack.com/ruling_webgui\">Ruling WebGUI</A></I>. Plain Black Software also provides several <A href=\"http://www.plainblack.com/support_programs\">Support Programs </A>for WebGUI if you run into trouble.</P>\r\n<P class=MsoNormal style=\"MARGIN: 0in 0in 0pt\"> <o:p></o:p></P>Enjoy your new WebGUI site!\r\n</DIV>',1,1023555430,3,1023555630,3,0,1023512400,1338872400,2,3600,4,0,'after',NULL,NULL,NULL,NULL,NULL);

