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
  PRIMARY KEY  (internationalId,namespace,languageId)
) TYPE=MyISAM;

--
-- Dumping data for table 'international'
--


INSERT INTO international VALUES (367,'WebGUI',1,'Expire After');
INSERT INTO international VALUES (1,'Article',3,'Artikel');
INSERT INTO international VALUES (1,'Article',1,'Article');
INSERT INTO international VALUES (1,'Article',4,'Artículo');
INSERT INTO international VALUES (1,'Article',5,'Artigo');
INSERT INTO international VALUES (1,'EventsCalendar',3,'Doorgaan naar gebeurtenis toevoegen?');
INSERT INTO international VALUES (1,'EventsCalendar',1,'Proceed to add event?');
INSERT INTO international VALUES (1,'EventsCalendar',5,'Proseguir com a adição do evento?');
INSERT INTO international VALUES (13,'SQLReport',2,'Carriage Return\r\nbeachten?');
INSERT INTO international VALUES (1,'ExtraColumn',3,'Extra kolom');
INSERT INTO international VALUES (1,'ExtraColumn',1,'Extra Column');
INSERT INTO international VALUES (1,'ExtraColumn',4,'Columna Extra');
INSERT INTO international VALUES (1,'ExtraColumn',5,'Coluna extra');
INSERT INTO international VALUES (1,'FAQ',3,'Doorgaan naar vraag toevoegen?');
INSERT INTO international VALUES (1,'FAQ',1,'Proceed to add question?');
INSERT INTO international VALUES (1,'FAQ',5,'Proseguir com a adição da questão?');
INSERT INTO international VALUES (1,'Item',1,'Link URL');
INSERT INTO international VALUES (1,'LinkList',3,'Inspringen');
INSERT INTO international VALUES (1,'LinkList',1,'Indent');
INSERT INTO international VALUES (1,'LinkList',5,'Destaque');
INSERT INTO international VALUES (5,'ExtraColumn',6,'StyleSheet Class');
INSERT INTO international VALUES (700,'WebGUI',6,'Dag');
INSERT INTO international VALUES (5,'Article',6,'Body');
INSERT INTO international VALUES (4,'WebGUI',6,'Kontrolera inställningar.');
INSERT INTO international VALUES (13,'UserSubmission',2,'Erstellungsdatum');
INSERT INTO international VALUES (1,'Poll',3,'Stemming');
INSERT INTO international VALUES (1,'Poll',1,'Poll');
INSERT INTO international VALUES (1,'Poll',4,'Encuesta');
INSERT INTO international VALUES (1,'Poll',5,'Sondagem');
INSERT INTO international VALUES (4,'UserSubmission',6,'Ditt medelande har blivit validerat.');
INSERT INTO international VALUES (4,'SyndicatedContent',6,'Redigera Syndicated inehåll');
INSERT INTO international VALUES (13,'WebGUI',2,'Hilfe anschauen');
INSERT INTO international VALUES (1,'SQLReport',3,'SQL rapport');
INSERT INTO international VALUES (1,'SQLReport',1,'SQL Report');
INSERT INTO international VALUES (1,'SQLReport',4,'Reporte SQL');
INSERT INTO international VALUES (1,'SQLReport',5,'Relatório SQL');
INSERT INTO international VALUES (1,'SyndicatedContent',3,'URL naar RSS bestand');
INSERT INTO international VALUES (1,'SyndicatedContent',1,'URL to RSS File');
INSERT INTO international VALUES (1,'SyndicatedContent',5,'Ficheiro de URL para RSS');
INSERT INTO international VALUES (1,'UserSubmission',3,'Wie kan goedkeuren?');
INSERT INTO international VALUES (1,'UserSubmission',1,'Who can approve?');
INSERT INTO international VALUES (1,'UserSubmission',5,'Quem pode aprovar?');
INSERT INTO international VALUES (14,'Article',2,'Anhang\r\nherunterladen');
INSERT INTO international VALUES (1,'WebGUI',3,'Inhoud toevoegen...');
INSERT INTO international VALUES (1,'WebGUI',1,'Add content...');
INSERT INTO international VALUES (1,'WebGUI',4,'Agregar Contenido ...');
INSERT INTO international VALUES (1,'WebGUI',5,'Adicionar conteudo...');
INSERT INTO international VALUES (14,'DownloadManager',2,'Datei');
INSERT INTO international VALUES (2,'EventsCalendar',3,'Evenementen kalender');
INSERT INTO international VALUES (2,'EventsCalendar',1,'Events Calendar');
INSERT INTO international VALUES (2,'EventsCalendar',4,'Calendario de Eventos');
INSERT INTO international VALUES (2,'EventsCalendar',5,'Calendário de eventos');
INSERT INTO international VALUES (4,'SiteMap',6,'Nivåer att traversera');
INSERT INTO international VALUES (4,'Poll',6,'Vem kan rösta?');
INSERT INTO international VALUES (4,'MessageBoard',6,'Meddelanden per sida');
INSERT INTO international VALUES (4,'LinkList',6,'Kula');
INSERT INTO international VALUES (14,'EventsCalendar',2,'Start\r\nDatum');
INSERT INTO international VALUES (2,'FAQ',3,'FAQ');
INSERT INTO international VALUES (2,'FAQ',1,'F.A.Q.');
INSERT INTO international VALUES (2,'FAQ',4,'F.A.Q.');
INSERT INTO international VALUES (2,'FAQ',5,'Perguntas mais frequentes');
INSERT INTO international VALUES (2,'Item',1,'Attachment');
INSERT INTO international VALUES (2,'LinkList',3,'Regel afstand');
INSERT INTO international VALUES (2,'LinkList',1,'Line Spacing');
INSERT INTO international VALUES (2,'LinkList',5,'Espaço entre linhas');
INSERT INTO international VALUES (1,'Article',0,'Artikel');
INSERT INTO international VALUES (2,'MessageBoard',3,'Berichten bord');
INSERT INTO international VALUES (2,'MessageBoard',1,'Message Board');
INSERT INTO international VALUES (2,'MessageBoard',4,'Table de Mensages');
INSERT INTO international VALUES (2,'MessageBoard',5,'Quadro de mensagens');
INSERT INTO international VALUES (4,'FAQ',6,'Lägg till fråga');
INSERT INTO international VALUES (4,'ExtraColumn',6,'Bredd');
INSERT INTO international VALUES (2,'SiteMap',3,'Site map');
INSERT INTO international VALUES (2,'SiteMap',1,'Site Map');
INSERT INTO international VALUES (2,'SiteMap',5,'Mapa do site');
INSERT INTO international VALUES (14,'SQLReport',2,'Später mit\r\nSeitenzahlen versehen');
INSERT INTO international VALUES (4,'Article',6,'Slut datum');
INSERT INTO international VALUES (3,'WebGUI',6,'Klistra in från klippbord...');
INSERT INTO international VALUES (14,'UserSubmission',2,'Status');
INSERT INTO international VALUES (2,'SyndicatedContent',3,'Syndicated content');
INSERT INTO international VALUES (2,'SyndicatedContent',1,'Syndicated Content');
INSERT INTO international VALUES (2,'SyndicatedContent',5,'Conteudo sindical');
INSERT INTO international VALUES (2,'UserSubmission',3,'Wie kan bijdragen?');
INSERT INTO international VALUES (2,'UserSubmission',1,'Who can contribute?');
INSERT INTO international VALUES (2,'UserSubmission',4,'Quiénes pueden contribuir?');
INSERT INTO international VALUES (2,'UserSubmission',5,'Quem pode contribuir?');
INSERT INTO international VALUES (15,'Article',2,'Rechts');
INSERT INTO international VALUES (2,'WebGUI',3,'Pagina');
INSERT INTO international VALUES (2,'WebGUI',1,'Page');
INSERT INTO international VALUES (2,'WebGUI',4,'Página');
INSERT INTO international VALUES (2,'WebGUI',5,'Página');
INSERT INTO international VALUES (3,'Article',3,'Start datum');
INSERT INTO international VALUES (3,'Article',1,'Start Date');
INSERT INTO international VALUES (3,'Article',4,'Fecha Inicio');
INSERT INTO international VALUES (3,'Article',5,'Data de inicio');
INSERT INTO international VALUES (14,'WebGUI',2,'Ausstehende\r\nBeiträge anschauen');
INSERT INTO international VALUES (3,'SyndicatedContent',6,'Lägg till Syndicated inehåll');
INSERT INTO international VALUES (3,'SQLReport',6,'Rapport Mall');
INSERT INTO international VALUES (3,'SiteMap',6,'Starta från denna nivå?');
INSERT INTO international VALUES (3,'Poll',6,'Aktiv');
INSERT INTO international VALUES (3,'ExtraColumn',3,'Tussenruimte');
INSERT INTO international VALUES (3,'ExtraColumn',1,'Spacer');
INSERT INTO international VALUES (3,'ExtraColumn',4,'Espaciador');
INSERT INTO international VALUES (3,'ExtraColumn',5,'Espaçamento');
INSERT INTO international VALUES (15,'DownloadManager',2,'Beschreibung');
INSERT INTO international VALUES (564,'WebGUI',6,'Vem kan posta?');
INSERT INTO international VALUES (3,'LinkList',6,'Öppna i ny ruta?');
INSERT INTO international VALUES (3,'Item',1,'Delete Attachment');
INSERT INTO international VALUES (15,'EventsCalendar',2,'Ende\r\nDatum');
INSERT INTO international VALUES (3,'LinkList',3,'Open in nieuw venster?');
INSERT INTO international VALUES (3,'LinkList',1,'Open in new window?');
INSERT INTO international VALUES (3,'LinkList',5,'Abrir numa nova janela?');
INSERT INTO international VALUES (564,'WebGUI',3,'Wie kan posten');
INSERT INTO international VALUES (564,'WebGUI',1,'Who can post?');
INSERT INTO international VALUES (564,'WebGUI',4,'Quienes pueden mandar?');
INSERT INTO international VALUES (564,'WebGUI',5,'Quem pode colocar novas?');
INSERT INTO international VALUES (3,'Poll',3,'Aktief');
INSERT INTO international VALUES (3,'Poll',1,'Active');
INSERT INTO international VALUES (3,'Poll',4,'Activar');
INSERT INTO international VALUES (3,'Poll',5,'Activo');
INSERT INTO international VALUES (3,'SiteMap',3,'Op dit niveau beginnen?');
INSERT INTO international VALUES (3,'SiteMap',1,'Starting from this level?');
INSERT INTO international VALUES (3,'SiteMap',5,'Iniciando neste nível?');
INSERT INTO international VALUES (15,'MessageBoard',2,'Autor');
INSERT INTO international VALUES (3,'SQLReport',3,'Sjabloon');
INSERT INTO international VALUES (3,'SQLReport',1,'Report Template');
INSERT INTO international VALUES (3,'SQLReport',4,'Modelo');
INSERT INTO international VALUES (3,'SQLReport',5,'Template');
INSERT INTO international VALUES (3,'ExtraColumn',6,'Mellanrumm');
INSERT INTO international VALUES (3,'EventsCalendar',6,'Lägg till händelse kalender');
INSERT INTO international VALUES (3,'Article',6,'Start datum');
INSERT INTO international VALUES (3,'UserSubmission',3,'U heeft een nieuwe bijdrage om goed te keuren.');
INSERT INTO international VALUES (3,'UserSubmission',1,'You have a new user submission to approve.');
INSERT INTO international VALUES (3,'UserSubmission',5,'Tem nova submissão para aprovar.');
INSERT INTO international VALUES (3,'WebGUI',3,'Plakken van het klemboord...');
INSERT INTO international VALUES (3,'WebGUI',1,'Paste from clipboard...');
INSERT INTO international VALUES (3,'WebGUI',4,'Pegar desde el Portapapeles...');
INSERT INTO international VALUES (3,'WebGUI',5,'Colar do clipboard...');
INSERT INTO international VALUES (15,'SQLReport',2,'Sollen die\r\nMakros in der Abfrage vorverarbeitet werden?');
INSERT INTO international VALUES (4,'Article',3,'Eind datum');
INSERT INTO international VALUES (4,'Article',1,'End Date');
INSERT INTO international VALUES (4,'Article',4,'Fecha finalización');
INSERT INTO international VALUES (4,'Article',5,'Data de fim');
INSERT INTO international VALUES (4,'EventsCalendar',3,'Gebeurt maar een keer.');
INSERT INTO international VALUES (4,'EventsCalendar',1,'Happens only once.');
INSERT INTO international VALUES (4,'EventsCalendar',4,'Sucede solo una vez.');
INSERT INTO international VALUES (4,'EventsCalendar',5,'Apenas uma vez.');
INSERT INTO international VALUES (4,'ExtraColumn',3,'Wijdte');
INSERT INTO international VALUES (4,'ExtraColumn',1,'Width');
INSERT INTO international VALUES (4,'ExtraColumn',4,'Ancho');
INSERT INTO international VALUES (4,'ExtraColumn',5,'Largura');
INSERT INTO international VALUES (2,'UserSubmission',6,'Vem kan göra inlägg?');
INSERT INTO international VALUES (2,'SyndicatedContent',6,'Syndicated inehåll');
INSERT INTO international VALUES (4,'Item',1,'Item');
INSERT INTO international VALUES (15,'UserSubmission',2,'Bearbeiten/Löschen');
INSERT INTO international VALUES (4,'LinkList',3,'Opsommingsteken');
INSERT INTO international VALUES (4,'LinkList',1,'Bullet');
INSERT INTO international VALUES (4,'LinkList',5,'Marca');
INSERT INTO international VALUES (15,'WebGUI',2,'Januar');
INSERT INTO international VALUES (4,'MessageBoard',3,'Berichten per pagina');
INSERT INTO international VALUES (4,'MessageBoard',1,'Messages Per Page');
INSERT INTO international VALUES (4,'MessageBoard',4,'Mensages por página');
INSERT INTO international VALUES (4,'MessageBoard',5,'Mensagens por página');
INSERT INTO international VALUES (4,'Poll',3,'Wie kan stemmen?');
INSERT INTO international VALUES (4,'Poll',1,'Who can vote?');
INSERT INTO international VALUES (4,'Poll',4,'Quiénes pueden votar?');
INSERT INTO international VALUES (4,'Poll',5,'Quem pode votar?');
INSERT INTO international VALUES (4,'SiteMap',3,'Diepte niveau');
INSERT INTO international VALUES (4,'SiteMap',1,'Depth To Traverse');
INSERT INTO international VALUES (4,'SiteMap',5,'profundidade a travessar');
INSERT INTO international VALUES (16,'Article',2,'Links');
INSERT INTO international VALUES (4,'SQLReport',3,'Query');
INSERT INTO international VALUES (4,'SQLReport',1,'Query');
INSERT INTO international VALUES (4,'SQLReport',4,'Consulta');
INSERT INTO international VALUES (4,'SQLReport',5,'Query');
INSERT INTO international VALUES (4,'SyndicatedContent',3,'Bewerk syndicated content');
INSERT INTO international VALUES (4,'SyndicatedContent',1,'Edit Syndicated Content');
INSERT INTO international VALUES (4,'SyndicatedContent',5,'Modificar conteudo sindical');
INSERT INTO international VALUES (4,'UserSubmission',3,'Uw bijdrage is goedgekeurd.');
INSERT INTO international VALUES (4,'UserSubmission',1,'Your submission has been approved.');
INSERT INTO international VALUES (4,'UserSubmission',5,'A sua submissão foi aprovada.');
INSERT INTO international VALUES (4,'WebGUI',3,'Beheer instellingen.');
INSERT INTO international VALUES (4,'WebGUI',1,'Manage settings.');
INSERT INTO international VALUES (4,'WebGUI',4,'Configurar Opciones.');
INSERT INTO international VALUES (4,'WebGUI',5,'Organizar preferências.');
INSERT INTO international VALUES (16,'DownloadManager',2,'Upload\r\nDatum');
INSERT INTO international VALUES (38,'UserSubmission',1,'(Select \"No\" if you\'re writing an HTML/Rich Edit submission.)');
INSERT INTO international VALUES (20,'EventsCalendar',1,'Add an event.');
INSERT INTO international VALUES (700,'WebGUI',3,'Dag');
INSERT INTO international VALUES (700,'WebGUI',1,'Day(s)');
INSERT INTO international VALUES (700,'WebGUI',4,'Día');
INSERT INTO international VALUES (700,'WebGUI',5,'Dia');
INSERT INTO international VALUES (16,'EventsCalendar',2,'Kalender\r\nLayout');
INSERT INTO international VALUES (5,'ExtraColumn',3,'Style sheet klasse (class)');
INSERT INTO international VALUES (5,'ExtraColumn',1,'StyleSheet Class');
INSERT INTO international VALUES (5,'ExtraColumn',4,'Clase StyleSheet');
INSERT INTO international VALUES (5,'ExtraColumn',5,'StyleSheet Class');
INSERT INTO international VALUES (5,'FAQ',3,'Vraag');
INSERT INTO international VALUES (5,'FAQ',1,'Question');
INSERT INTO international VALUES (5,'FAQ',4,'Pregunta');
INSERT INTO international VALUES (5,'FAQ',5,'Questão');
INSERT INTO international VALUES (5,'Item',1,'Download Attachment');
INSERT INTO international VALUES (5,'LinkList',3,'Doorgaan met link toevoegen?');
INSERT INTO international VALUES (5,'LinkList',1,'Proceed to add link?');
INSERT INTO international VALUES (5,'LinkList',5,'Proseguir com a adição do hiperlink?');
INSERT INTO international VALUES (566,'WebGUI',3,'Bewerk timeout');
INSERT INTO international VALUES (566,'WebGUI',1,'Edit Timeout');
INSERT INTO international VALUES (566,'WebGUI',4,'Timeout de edición');
INSERT INTO international VALUES (566,'WebGUI',5,'Modificar Timeout');
INSERT INTO international VALUES (16,'SQLReport',2,'Debug?');
INSERT INTO international VALUES (5,'Poll',3,'Grafiek wijdte');
INSERT INTO international VALUES (5,'Poll',1,'Graph Width');
INSERT INTO international VALUES (5,'Poll',4,'Ancho del gráfico');
INSERT INTO international VALUES (5,'Poll',5,'Largura do gráfico');
INSERT INTO international VALUES (5,'SiteMap',3,'Bewerk site map');
INSERT INTO international VALUES (5,'SiteMap',1,'Edit Site Map');
INSERT INTO international VALUES (5,'SiteMap',5,'Editar mapa do site');
INSERT INTO international VALUES (16,'MessageBoard',2,'Datum');
INSERT INTO international VALUES (5,'SQLReport',3,'DSN');
INSERT INTO international VALUES (5,'SQLReport',1,'DSN');
INSERT INTO international VALUES (5,'SQLReport',4,'DSN');
INSERT INTO international VALUES (5,'SQLReport',5,'DSN');
INSERT INTO international VALUES (5,'SyndicatedContent',3,'Laatste keer bijgewerkt');
INSERT INTO international VALUES (5,'SyndicatedContent',1,'Last Fetched');
INSERT INTO international VALUES (5,'SyndicatedContent',5,'Ultima retirada');
INSERT INTO international VALUES (5,'UserSubmission',3,'Uw bijdrage is afgekeurd.');
INSERT INTO international VALUES (5,'UserSubmission',1,'Your submission has been denied.');
INSERT INTO international VALUES (5,'UserSubmission',5,'A sua submissão não foi aprovada.');
INSERT INTO international VALUES (5,'WebGUI',3,'Beheer groepen.');
INSERT INTO international VALUES (5,'WebGUI',1,'Manage groups.');
INSERT INTO international VALUES (5,'WebGUI',4,'Configurar Grupos.');
INSERT INTO international VALUES (5,'WebGUI',5,'Organizar grupos.');
INSERT INTO international VALUES (6,'Article',3,'Plaatje');
INSERT INTO international VALUES (6,'Article',1,'Image');
INSERT INTO international VALUES (6,'Article',4,'Imagen');
INSERT INTO international VALUES (6,'Article',5,'Imagem');
INSERT INTO international VALUES (17,'Article',2,'Zentrum');
INSERT INTO international VALUES (16,'UserSubmission',2,'Ohne\r\nTitel');
INSERT INTO international VALUES (701,'WebGUI',3,'Week');
INSERT INTO international VALUES (701,'WebGUI',1,'Week(s)');
INSERT INTO international VALUES (701,'WebGUI',4,'Semana');
INSERT INTO international VALUES (701,'WebGUI',5,'Semana');
INSERT INTO international VALUES (6,'ExtraColumn',3,'Bewerk extra kolom');
INSERT INTO international VALUES (6,'ExtraColumn',1,'Edit Extra Column');
INSERT INTO international VALUES (6,'ExtraColumn',4,'Editar Columna Extra');
INSERT INTO international VALUES (6,'ExtraColumn',5,'Modificar coluna extra');
INSERT INTO international VALUES (6,'FAQ',3,'Andwoord');
INSERT INTO international VALUES (6,'FAQ',1,'Answer');
INSERT INTO international VALUES (6,'FAQ',4,'Respuesta');
INSERT INTO international VALUES (6,'FAQ',5,'Resposta');
INSERT INTO international VALUES (16,'WebGUI',2,'Februar');
INSERT INTO international VALUES (6,'LinkList',3,'Link lijst');
INSERT INTO international VALUES (6,'LinkList',1,'Link List');
INSERT INTO international VALUES (6,'LinkList',4,'Lista de Enlaces');
INSERT INTO international VALUES (6,'LinkList',5,'Lista de hiperlinks');
INSERT INTO international VALUES (6,'MessageBoard',3,'Bewerk berichten bord');
INSERT INTO international VALUES (6,'MessageBoard',1,'Edit Message Board');
INSERT INTO international VALUES (6,'MessageBoard',4,'Editar Tabla de Mensages');
INSERT INTO international VALUES (6,'MessageBoard',5,'Modificar quadro de mensagens');
INSERT INTO international VALUES (17,'DownloadManager',2,'Alternative #1');
INSERT INTO international VALUES (6,'Poll',3,'Vraag');
INSERT INTO international VALUES (6,'Poll',1,'Question');
INSERT INTO international VALUES (6,'Poll',4,'Pregunta');
INSERT INTO international VALUES (6,'Poll',5,'Questão');
INSERT INTO international VALUES (6,'SiteMap',3,'Inspringen');
INSERT INTO international VALUES (6,'SiteMap',1,'Indent');
INSERT INTO international VALUES (6,'SiteMap',5,'Destaque');
INSERT INTO international VALUES (17,'EventsCalendar',2,'Liste');
INSERT INTO international VALUES (6,'SQLReport',3,'Database gebruiker');
INSERT INTO international VALUES (6,'SQLReport',1,'Database User');
INSERT INTO international VALUES (6,'SQLReport',4,'Usuario de la Base de Datos');
INSERT INTO international VALUES (6,'SQLReport',5,'User da base de dados');
INSERT INTO international VALUES (6,'SyndicatedContent',3,'Huidige inhoud');
INSERT INTO international VALUES (6,'SyndicatedContent',1,'Current Content');
INSERT INTO international VALUES (6,'SyndicatedContent',5,'Conteudo actual');
INSERT INTO international VALUES (17,'MessageBoard',2,'Neuen\r\nBeitrag schreiben');
INSERT INTO international VALUES (6,'UserSubmission',3,'Bijdrages per pagina');
INSERT INTO international VALUES (6,'UserSubmission',1,'Submissions Per Page');
INSERT INTO international VALUES (6,'UserSubmission',4,'Contribuciones por página');
INSERT INTO international VALUES (6,'UserSubmission',5,'Submissões por página');
INSERT INTO international VALUES (6,'WebGUI',3,'Beheer stijlen.');
INSERT INTO international VALUES (6,'WebGUI',1,'Manage styles.');
INSERT INTO international VALUES (6,'WebGUI',4,'Configurar Estilos');
INSERT INTO international VALUES (6,'WebGUI',5,'Organizar estilos.');
INSERT INTO international VALUES (17,'SQLReport',2,'<b>Debug:</b>\r\nAbfrage:');
INSERT INTO international VALUES (7,'Article',3,'Link titel');
INSERT INTO international VALUES (7,'Article',1,'Link Title');
INSERT INTO international VALUES (7,'Article',4,'Link Título');
INSERT INTO international VALUES (7,'Article',5,'Titulo da hiperlink');
INSERT INTO international VALUES (2,'SiteMap',6,'Site Karta');
INSERT INTO international VALUES (2,'Poll',6,'Lägg till fråga');
INSERT INTO international VALUES (2,'MessageBoard',6,'Meddelande Forum');
INSERT INTO international VALUES (17,'UserSubmission',2,'Sind Sie\r\nsicher, dass Sie diesen Beitrag löschen wollen?');
INSERT INTO international VALUES (7,'FAQ',3,'Weet u zeker dat u deze vraag wilt verwijderen?');
INSERT INTO international VALUES (7,'FAQ',1,'Are you certain that you want to delete this question?');
INSERT INTO international VALUES (7,'FAQ',4,'Está seguro de querer eliminar ésta pregunta?');
INSERT INTO international VALUES (7,'FAQ',5,'Tem a certeza que quer apagar esta questão?');
INSERT INTO international VALUES (2,'Item',6,'Bilagor');
INSERT INTO international VALUES (2,'FAQ',6,'F.A.Q.');
INSERT INTO international VALUES (2,'ExtraColumn',6,'Lägg till Extra Column');
INSERT INTO international VALUES (18,'Article',2,'Diskussion\r\nerlauben?');
INSERT INTO international VALUES (7,'MessageBoard',3,'Naam:');
INSERT INTO international VALUES (7,'MessageBoard',1,'Author:');
INSERT INTO international VALUES (7,'MessageBoard',4,'Autor:');
INSERT INTO international VALUES (7,'MessageBoard',5,'Autor:');
INSERT INTO international VALUES (17,'WebGUI',2,'März');
INSERT INTO international VALUES (7,'Poll',3,'Antwoorden');
INSERT INTO international VALUES (7,'Poll',1,'Answers');
INSERT INTO international VALUES (7,'Poll',4,'Respuestas');
INSERT INTO international VALUES (7,'Poll',5,'Respostas');
INSERT INTO international VALUES (7,'SiteMap',3,'Opsommingsteken');
INSERT INTO international VALUES (7,'SiteMap',1,'Bullet');
INSERT INTO international VALUES (7,'SiteMap',5,'Marca');
INSERT INTO international VALUES (7,'SQLReport',3,'Database wachtwoord');
INSERT INTO international VALUES (7,'SQLReport',1,'Database Password');
INSERT INTO international VALUES (7,'SQLReport',4,'Password de la Base de Datos');
INSERT INTO international VALUES (7,'SQLReport',5,'Password da base de dados');
INSERT INTO international VALUES (18,'EventsCalendar',2,'Calendar Month');
INSERT INTO international VALUES (560,'WebGUI',3,'Goedgekeurd');
INSERT INTO international VALUES (560,'WebGUI',1,'Approved');
INSERT INTO international VALUES (560,'WebGUI',4,'Aprobado');
INSERT INTO international VALUES (560,'WebGUI',5,'Aprovado');
INSERT INTO international VALUES (7,'WebGUI',3,'Beheer gebruikers');
INSERT INTO international VALUES (7,'WebGUI',1,'Manage users.');
INSERT INTO international VALUES (7,'WebGUI',4,'Configurar Usuarios');
INSERT INTO international VALUES (7,'WebGUI',5,'Organizar utilizadores.');
INSERT INTO international VALUES (8,'Article',3,'Link URL');
INSERT INTO international VALUES (8,'Article',1,'Link URL');
INSERT INTO international VALUES (8,'Article',4,'Link URL');
INSERT INTO international VALUES (8,'Article',5,'URL da hiperlink');
INSERT INTO international VALUES (8,'EventsCalendar',3,'Herhaalt elke');
INSERT INTO international VALUES (8,'EventsCalendar',1,'Recurs every');
INSERT INTO international VALUES (8,'EventsCalendar',4,'Se repite cada');
INSERT INTO international VALUES (8,'EventsCalendar',5,'Repetição');
INSERT INTO international VALUES (18,'DownloadManager',2,'Alternative #2');
INSERT INTO international VALUES (8,'FAQ',3,'Bewerk FAQ');
INSERT INTO international VALUES (8,'FAQ',1,'Edit F.A.Q.');
INSERT INTO international VALUES (8,'FAQ',4,'Editar F.A.Q.');
INSERT INTO international VALUES (8,'FAQ',5,'Modificar perguntas mais frequentes');
INSERT INTO international VALUES (8,'LinkList',3,'URL');
INSERT INTO international VALUES (8,'LinkList',1,'URL');
INSERT INTO international VALUES (8,'LinkList',4,'URL');
INSERT INTO international VALUES (8,'LinkList',5,'URL');
INSERT INTO international VALUES (18,'MessageBoard',2,'Diskussion\r\nbegonnen');
INSERT INTO international VALUES (8,'MessageBoard',3,'Datum:');
INSERT INTO international VALUES (8,'MessageBoard',1,'Date:');
INSERT INTO international VALUES (8,'MessageBoard',4,'Fecha:');
INSERT INTO international VALUES (8,'MessageBoard',5,'Data:');
INSERT INTO international VALUES (8,'Poll',3,'(Enter een antwoord per lijn. Niet meer dan 20.)');
INSERT INTO international VALUES (8,'Poll',1,'(Enter one answer per line. No more than 20.)');
INSERT INTO international VALUES (8,'Poll',4,'(Ingrese una por línea. No más de 20)');
INSERT INTO international VALUES (8,'Poll',5,'(Introduza uma resposta por linha. Não passe das 20.)');
INSERT INTO international VALUES (8,'SiteMap',3,'Regel afstand');
INSERT INTO international VALUES (8,'SiteMap',1,'Line Spacing');
INSERT INTO international VALUES (8,'SiteMap',5,'Espaçamento de linha');
INSERT INTO international VALUES (18,'SQLReport',2,'Diese Abfrage\r\nliefert keine Ergebnisse.');
INSERT INTO international VALUES (8,'SQLReport',3,'Bewerk SQL rapport');
INSERT INTO international VALUES (8,'SQLReport',1,'Edit SQL Report');
INSERT INTO international VALUES (8,'SQLReport',4,'Editar Reporte SQL');
INSERT INTO international VALUES (8,'SQLReport',5,'Modificar o relaório SQL');
INSERT INTO international VALUES (561,'WebGUI',3,'Afgekeurd');
INSERT INTO international VALUES (561,'WebGUI',1,'Denied');
INSERT INTO international VALUES (561,'WebGUI',4,'Denegado');
INSERT INTO international VALUES (561,'WebGUI',5,'Negado');
INSERT INTO international VALUES (8,'WebGUI',3,'Bekijk \'pagina niet gevonden\'.');
INSERT INTO international VALUES (8,'WebGUI',1,'View page not found.');
INSERT INTO international VALUES (8,'WebGUI',4,'Ver Página No Encontrada');
INSERT INTO international VALUES (8,'WebGUI',5,'Ver página não encontrada.');
INSERT INTO international VALUES (18,'UserSubmission',2,'Benutzer\r\nBeitragssystem bearbeiten');
INSERT INTO international VALUES (9,'Article',3,'Bijlage');
INSERT INTO international VALUES (9,'Article',1,'Attachment');
INSERT INTO international VALUES (9,'Article',4,'Adjuntar');
INSERT INTO international VALUES (9,'Article',5,'Anexar');
INSERT INTO international VALUES (9,'EventsCalendar',3,'Tot');
INSERT INTO international VALUES (9,'EventsCalendar',1,'until');
INSERT INTO international VALUES (9,'EventsCalendar',4,'hasta');
INSERT INTO international VALUES (9,'EventsCalendar',5,'até');
INSERT INTO international VALUES (18,'WebGUI',2,'April');
INSERT INTO international VALUES (9,'FAQ',3,'Voeg een nieuwe vraag toe');
INSERT INTO international VALUES (9,'FAQ',1,'Add a new question.');
INSERT INTO international VALUES (9,'FAQ',4,'Agregar nueva pregunta.');
INSERT INTO international VALUES (9,'FAQ',5,'Adicionar nova questão.');
INSERT INTO international VALUES (12,'Product',1,'Are you certain you wish to delete this file?');
INSERT INTO international VALUES (9,'LinkList',3,'Weet u zeker dat u deze link wilt verwijderen?');
INSERT INTO international VALUES (9,'LinkList',1,'Are you certain that you want to delete this link?');
INSERT INTO international VALUES (9,'LinkList',4,'Está seguro de querer eliminar éste enlace?');
INSERT INTO international VALUES (9,'LinkList',5,'Tem a certeza que quer apagar esta hiperlink?');
INSERT INTO international VALUES (9,'MessageBoard',3,'Bericht ID:');
INSERT INTO international VALUES (9,'MessageBoard',1,'Message ID:');
INSERT INTO international VALUES (9,'MessageBoard',4,'ID del mensage:');
INSERT INTO international VALUES (9,'MessageBoard',5,'ID da mensagem:');
INSERT INTO international VALUES (9,'Poll',3,'Bewerk stemming');
INSERT INTO international VALUES (9,'Poll',1,'Edit Poll');
INSERT INTO international VALUES (9,'Poll',4,'Editar Encuesta');
INSERT INTO international VALUES (9,'Poll',5,'Modificar sondagem');
INSERT INTO international VALUES (9,'SQLReport',3,'Fout: De ingevoerde DSN is van een verkeerd formaat.');
INSERT INTO international VALUES (9,'SQLReport',1,'<b>Debug:</b> Error: The DSN specified is of an improper format.');
INSERT INTO international VALUES (9,'SQLReport',4,'Error: El DSN especificado está en un formato incorrecto.');
INSERT INTO international VALUES (9,'SQLReport',5,'Erro: O DSN especificado tem um formato impróprio.');
INSERT INTO international VALUES (19,'DownloadManager',2,'Sie\r\nbesitzen keine Dateien, die zum Download bereitstehen.');
INSERT INTO international VALUES (562,'WebGUI',3,'Lopend');
INSERT INTO international VALUES (562,'WebGUI',1,'Pending');
INSERT INTO international VALUES (562,'WebGUI',4,'Pendiente');
INSERT INTO international VALUES (562,'WebGUI',5,'Pendente');
INSERT INTO international VALUES (9,'WebGUI',3,'Bekijk klemboord.');
INSERT INTO international VALUES (9,'WebGUI',1,'View clipboard.');
INSERT INTO international VALUES (9,'WebGUI',4,'Ver Portapapeles');
INSERT INTO international VALUES (9,'WebGUI',5,'Ver o clipboard.');
INSERT INTO international VALUES (10,'Article',3,'Enter converteren?');
INSERT INTO international VALUES (10,'Article',1,'Convert carriage returns?');
INSERT INTO international VALUES (10,'Article',4,'Convertir saltos de carro?');
INSERT INTO international VALUES (10,'Article',5,'Converter o caracter de retorno (CR) ?');
INSERT INTO international VALUES (19,'EventsCalendar',2,'Später mit\r\nSeitenzahlen versehen');
INSERT INTO international VALUES (19,'MessageBoard',2,'Antworten');
INSERT INTO international VALUES (10,'FAQ',3,'Bewerk vraag');
INSERT INTO international VALUES (10,'FAQ',1,'Edit Question');
INSERT INTO international VALUES (10,'FAQ',4,'Editar Pregunta');
INSERT INTO international VALUES (10,'FAQ',5,'Modificar questão');
INSERT INTO international VALUES (10,'LinkList',3,'Bewerk link lijst');
INSERT INTO international VALUES (10,'LinkList',1,'Edit Link List');
INSERT INTO international VALUES (10,'LinkList',4,'Editar Lista de Enlaces');
INSERT INTO international VALUES (10,'LinkList',5,'Modificar lista de hiperlinks');
INSERT INTO international VALUES (19,'UserSubmission',2,'Beitrag\r\nbearbeiten');
INSERT INTO international VALUES (6,'Article',0,'Billede');
INSERT INTO international VALUES (5,'Article',0,'Brødtekst');
INSERT INTO international VALUES (4,'Article',0,'Til dato');
INSERT INTO international VALUES (3,'Article',0,'Fra dato');
INSERT INTO international VALUES (10,'Poll',3,'Reset stemmen');
INSERT INTO international VALUES (10,'Poll',1,'Reset votes.');
INSERT INTO international VALUES (10,'Poll',5,'Reinicializar os votos.');
INSERT INTO international VALUES (19,'WebGUI',2,'Mai');
INSERT INTO international VALUES (10,'SQLReport',3,'Fout: De ingevoerde SQL instructie is van een verkeerd formaat.');
INSERT INTO international VALUES (10,'SQLReport',1,'<b>Debug:</b> Error: The SQL specified is of an improper format.');
INSERT INTO international VALUES (10,'SQLReport',4,'Error: El SQL especificado está en un formato incorrecto.');
INSERT INTO international VALUES (10,'SQLReport',5,'Erro: O SQL especificado tem um formato impróprio.');
INSERT INTO international VALUES (563,'WebGUI',3,'Standaard status');
INSERT INTO international VALUES (563,'WebGUI',1,'Default Status');
INSERT INTO international VALUES (563,'WebGUI',4,'Estado por defecto');
INSERT INTO international VALUES (563,'WebGUI',5,'Estado por defeito');
INSERT INTO international VALUES (10,'WebGUI',3,'Bekijk prullenbak.');
INSERT INTO international VALUES (10,'WebGUI',1,'Manage trash.');
INSERT INTO international VALUES (10,'WebGUI',4,'Ver Papelera');
INSERT INTO international VALUES (10,'WebGUI',5,'Ver o caixote do lixo.');
INSERT INTO international VALUES (11,'Article',3,'(Vink aan als u geen &lt;br&gt; manueel gebruikt.)');
INSERT INTO international VALUES (11,'Article',1,'(Select \"Yes\" only if you aren\'t adding &lt;br&gt; manually.)');
INSERT INTO international VALUES (11,'Article',4,'(marque si no está agregando &lt;br&gt; manualmente.)');
INSERT INTO international VALUES (11,'Article',5,'(escolher se não adicionar &lt;br&gt; manualmente.)');
INSERT INTO international VALUES (20,'DownloadManager',2,'Später\r\nmit Seitenzahlen versehen');
INSERT INTO international VALUES (58,'Product',1,'Edit Product Template');
INSERT INTO international VALUES (707,'WebGUI',1,'Show debugging?');
INSERT INTO international VALUES (78,'EventsCalendar',1,'Don\'t delete anything, I made a mistake.');
INSERT INTO international VALUES (20,'MessageBoard',2,'Letzte\r\nAntwort');
INSERT INTO international VALUES (2,'EventsCalendar',6,'Händelse Kalender');
INSERT INTO international VALUES (2,'Article',6,'Lägg till artikel');
INSERT INTO international VALUES (1,'WebGUI',6,'Lägg till innehåll....');
INSERT INTO international VALUES (1,'UserSubmission',6,'Vem kan validera?');
INSERT INTO international VALUES (11,'MessageBoard',3,'Terug naar berichten lijst');
INSERT INTO international VALUES (11,'MessageBoard',1,'Back To Message List');
INSERT INTO international VALUES (11,'MessageBoard',4,'Volver a la Lista de Mensages');
INSERT INTO international VALUES (11,'MessageBoard',5,'Voltar á lista de mensagens');
INSERT INTO international VALUES (20,'UserSubmission',2,'Neuen\r\nBeitrag schreiben');
INSERT INTO international VALUES (11,'SQLReport',3,'Fout: Er was een probleem met de query');
INSERT INTO international VALUES (11,'SQLReport',1,'<b>Debug:</b> Error: There was a problem with the query.');
INSERT INTO international VALUES (11,'SQLReport',4,'Error: Hay un problema con la consulta.');
INSERT INTO international VALUES (11,'SQLReport',5,'Erro: Houve um problema com a query.');
INSERT INTO international VALUES (20,'WebGUI',2,'Juni');
INSERT INTO international VALUES (1,'SQLReport',6,'SQL Rapport');
INSERT INTO international VALUES (1,'SiteMap',6,'Läggtill Site Karta');
INSERT INTO international VALUES (1,'Poll',6,'Fråga');
INSERT INTO international VALUES (11,'WebGUI',3,'Leeg prullenbak.');
INSERT INTO international VALUES (11,'WebGUI',1,'Empy trash.');
INSERT INTO international VALUES (11,'WebGUI',4,'Vaciar Papelera');
INSERT INTO international VALUES (11,'WebGUI',5,'Esvaziar o caixote do lixo.');
INSERT INTO international VALUES (12,'Article',3,'Bewerk artikel');
INSERT INTO international VALUES (12,'Article',1,'Edit Article');
INSERT INTO international VALUES (12,'Article',4,'Editar Artículo');
INSERT INTO international VALUES (12,'Article',5,'Modificar artigo');
INSERT INTO international VALUES (12,'EventsCalendar',3,'Bewerk evenementen kalender');
INSERT INTO international VALUES (12,'EventsCalendar',1,'Edit Events Calendar');
INSERT INTO international VALUES (12,'EventsCalendar',4,'Editar Calendario de Eventos');
INSERT INTO international VALUES (12,'EventsCalendar',5,'Modificar calendário de eventos');
INSERT INTO international VALUES (12,'LinkList',3,'Bewerk link');
INSERT INTO international VALUES (12,'LinkList',1,'Edit Link');
INSERT INTO international VALUES (12,'LinkList',4,'Editar Enlace');
INSERT INTO international VALUES (12,'LinkList',5,'Modificar hiperlink');
INSERT INTO international VALUES (12,'MessageBoard',3,'Bewerk bericht');
INSERT INTO international VALUES (12,'MessageBoard',1,'Edit Message');
INSERT INTO international VALUES (12,'MessageBoard',4,'Editar mensage');
INSERT INTO international VALUES (12,'MessageBoard',5,'Modificar mensagem');
INSERT INTO international VALUES (21,'DownloadManager',2,'Vorschaubilder anzeigen?');
INSERT INTO international VALUES (12,'SQLReport',3,'Fout: Kon niet met de database verbinden.');
INSERT INTO international VALUES (12,'SQLReport',1,'<b>Debug:</b> Error: Could not connect to the database.');
INSERT INTO international VALUES (12,'SQLReport',4,'Error: No se puede conectar a la base de datos.');
INSERT INTO international VALUES (12,'SQLReport',5,'Erro: Não é possível ligar á base de dados.');
INSERT INTO international VALUES (565,'WebGUI',2,'Wer kann\r\nmoderieren?');
INSERT INTO international VALUES (12,'UserSubmission',3,'(niet aanvinken als u een HTML bijdrage levert.)');
INSERT INTO international VALUES (12,'UserSubmission',1,'(Uncheck if you\'re writing an HTML submission.)');
INSERT INTO international VALUES (12,'UserSubmission',4,'(desmarque si está escribiendo la contribución en HTML.)');
INSERT INTO international VALUES (12,'UserSubmission',5,'(deixar em branco se a submissão for em HTML.)');
INSERT INTO international VALUES (21,'UserSubmission',2,'Erstellt\r\nvon');
INSERT INTO international VALUES (12,'WebGUI',3,'Zet beheermode uit.');
INSERT INTO international VALUES (12,'WebGUI',1,'Turn admin off.');
INSERT INTO international VALUES (12,'WebGUI',4,'Apagar Admin');
INSERT INTO international VALUES (12,'WebGUI',5,'Desligar o modo administrativo.');
INSERT INTO international VALUES (21,'WebGUI',2,'Juli');
INSERT INTO international VALUES (13,'Article',3,'Verwijder');
INSERT INTO international VALUES (13,'Article',1,'Delete');
INSERT INTO international VALUES (13,'Article',4,'Eliminar');
INSERT INTO international VALUES (13,'Article',5,'Apagar');
INSERT INTO international VALUES (13,'EventsCalendar',3,'Bewerk evenement');
INSERT INTO international VALUES (13,'EventsCalendar',1,'Edit Event');
INSERT INTO international VALUES (13,'EventsCalendar',4,'Editar Evento');
INSERT INTO international VALUES (13,'EventsCalendar',5,'Modificar evento');
INSERT INTO international VALUES (22,'MessageBoard',2,'Beitrag\r\nlöschen');
INSERT INTO international VALUES (13,'LinkList',3,'Voeg een nieuwe link toe.');
INSERT INTO international VALUES (13,'LinkList',1,'Add a new link.');
INSERT INTO international VALUES (13,'LinkList',4,'Agregar nuevo Enlace');
INSERT INTO international VALUES (13,'LinkList',5,'Adicionar nova hiperlink.');
INSERT INTO international VALUES (22,'Article',2,'Autor');
INSERT INTO international VALUES (577,'WebGUI',3,'Post antwoord');
INSERT INTO international VALUES (577,'WebGUI',1,'Post Reply');
INSERT INTO international VALUES (577,'WebGUI',4,'Responder');
INSERT INTO international VALUES (577,'WebGUI',5,'Responder');
INSERT INTO international VALUES (13,'UserSubmission',3,'Invoerdatum');
INSERT INTO international VALUES (13,'UserSubmission',1,'Date Submitted');
INSERT INTO international VALUES (13,'UserSubmission',4,'Fecha Contribución');
INSERT INTO international VALUES (13,'UserSubmission',5,'Data de submissão');
INSERT INTO international VALUES (22,'UserSubmission',2,'Erstellt\r\nvon:');
INSERT INTO international VALUES (13,'WebGUI',3,'Laat help index zien.');
INSERT INTO international VALUES (13,'WebGUI',1,'View help index.');
INSERT INTO international VALUES (13,'WebGUI',4,'Ver índice de Ayuda');
INSERT INTO international VALUES (13,'WebGUI',5,'Ver o indice da ajuda.');
INSERT INTO international VALUES (14,'Article',1,'Align Image');
INSERT INTO international VALUES (22,'WebGUI',2,'August');
INSERT INTO international VALUES (516,'WebGUI',1,'Turn Admin On!');
INSERT INTO international VALUES (517,'WebGUI',1,'Turn Admin Off!');
INSERT INTO international VALUES (515,'WebGUI',1,'Add edit stamp to posts?');
INSERT INTO international VALUES (23,'Article',2,'Datum');
INSERT INTO international VALUES (14,'UserSubmission',3,'Status');
INSERT INTO international VALUES (14,'UserSubmission',1,'Status');
INSERT INTO international VALUES (14,'UserSubmission',4,'Estado');
INSERT INTO international VALUES (14,'UserSubmission',5,'Estado');
INSERT INTO international VALUES (14,'WebGUI',3,'Laat lopende aanmeldingen zien.');
INSERT INTO international VALUES (14,'WebGUI',1,'View pending submissions.');
INSERT INTO international VALUES (14,'WebGUI',4,'Ver contribuciones pendientes.');
INSERT INTO international VALUES (14,'WebGUI',5,'Ver submissões pendentes.');
INSERT INTO international VALUES (23,'UserSubmission',2,'Erstellungsdatum:');
INSERT INTO international VALUES (15,'MessageBoard',3,'Afzender');
INSERT INTO international VALUES (15,'MessageBoard',1,'Author');
INSERT INTO international VALUES (15,'MessageBoard',4,'Autor');
INSERT INTO international VALUES (15,'MessageBoard',5,'Autor');
INSERT INTO international VALUES (15,'UserSubmission',3,'bewerk/Verwijder');
INSERT INTO international VALUES (15,'UserSubmission',1,'Edit/Delete');
INSERT INTO international VALUES (15,'UserSubmission',4,'Editar/Eliminar');
INSERT INTO international VALUES (15,'UserSubmission',5,'Modificar/Apagar');
INSERT INTO international VALUES (15,'WebGUI',3,'januari');
INSERT INTO international VALUES (15,'WebGUI',1,'January');
INSERT INTO international VALUES (15,'WebGUI',4,'Enero');
INSERT INTO international VALUES (15,'WebGUI',5,'Janeiro');
INSERT INTO international VALUES (23,'WebGUI',2,'September');
INSERT INTO international VALUES (16,'MessageBoard',3,'Datum');
INSERT INTO international VALUES (16,'MessageBoard',1,'Date');
INSERT INTO international VALUES (16,'MessageBoard',4,'Fecha');
INSERT INTO international VALUES (16,'MessageBoard',5,'Data');
INSERT INTO international VALUES (16,'UserSubmission',3,'Zonder titel');
INSERT INTO international VALUES (16,'UserSubmission',1,'Untitled');
INSERT INTO international VALUES (16,'UserSubmission',4,'Sin título');
INSERT INTO international VALUES (16,'UserSubmission',5,'Sem titulo');
INSERT INTO international VALUES (572,'WebGUI',2,'Erlauben');
INSERT INTO international VALUES (16,'WebGUI',3,'februari');
INSERT INTO international VALUES (16,'WebGUI',1,'February');
INSERT INTO international VALUES (16,'WebGUI',4,'Febrero');
INSERT INTO international VALUES (16,'WebGUI',5,'Fevereiro');
INSERT INTO international VALUES (17,'MessageBoard',3,'Post nieuw bericht');
INSERT INTO international VALUES (17,'MessageBoard',1,'Post New Message');
INSERT INTO international VALUES (17,'MessageBoard',4,'Mandar Nuevo Mensage');
INSERT INTO international VALUES (17,'MessageBoard',5,'Colocar nova mensagem');
INSERT INTO international VALUES (24,'Article',2,'Kommentar\r\nschreiben');
INSERT INTO international VALUES (17,'UserSubmission',3,'Weet u zeker dat u deze bijdrage wilt verwijderen?');
INSERT INTO international VALUES (17,'UserSubmission',1,'Are you certain you wish to delete this submission?');
INSERT INTO international VALUES (17,'UserSubmission',4,'Está seguro de querer eliminar ésta contribución?');
INSERT INTO international VALUES (17,'UserSubmission',5,'Tem a certeza que quer apagar esta submissão?');
INSERT INTO international VALUES (17,'WebGUI',3,'maart');
INSERT INTO international VALUES (17,'WebGUI',1,'March');
INSERT INTO international VALUES (17,'WebGUI',4,'Marzo');
INSERT INTO international VALUES (17,'WebGUI',5,'Março');
INSERT INTO international VALUES (24,'WebGUI',2,'Oktober');
INSERT INTO international VALUES (18,'MessageBoard',3,'Tread gestart');
INSERT INTO international VALUES (18,'MessageBoard',1,'Thread Started');
INSERT INTO international VALUES (18,'MessageBoard',4,'Inicio');
INSERT INTO international VALUES (18,'MessageBoard',5,'Inicial');
INSERT INTO international VALUES (59,'UserSubmission',1,'Next Submission');
INSERT INTO international VALUES (18,'UserSubmission',3,'Bewerk gebruikers bijdrage systeem');
INSERT INTO international VALUES (18,'UserSubmission',1,'Edit User Submission System');
INSERT INTO international VALUES (18,'UserSubmission',4,'Editar Sistema de Contribución de Usuarios');
INSERT INTO international VALUES (18,'UserSubmission',5,'Modificar sistema de submissão do utilizador');
INSERT INTO international VALUES (18,'WebGUI',3,'april');
INSERT INTO international VALUES (18,'WebGUI',1,'April');
INSERT INTO international VALUES (18,'WebGUI',4,'Abril');
INSERT INTO international VALUES (18,'WebGUI',5,'Abril');
INSERT INTO international VALUES (19,'MessageBoard',3,'Antwoorden');
INSERT INTO international VALUES (19,'MessageBoard',1,'Replies');
INSERT INTO international VALUES (19,'MessageBoard',4,'Respuestas');
INSERT INTO international VALUES (19,'MessageBoard',5,'Respostas');
INSERT INTO international VALUES (573,'WebGUI',2,'Ausstehend\r\nverlassen');
INSERT INTO international VALUES (19,'UserSubmission',3,'Bewerk bijdrage');
INSERT INTO international VALUES (19,'UserSubmission',1,'Edit Submission');
INSERT INTO international VALUES (19,'UserSubmission',4,'Editar Contribución');
INSERT INTO international VALUES (19,'UserSubmission',5,'Modificar submissão');
INSERT INTO international VALUES (19,'WebGUI',3,'mei');
INSERT INTO international VALUES (19,'WebGUI',1,'May');
INSERT INTO international VALUES (19,'WebGUI',4,'Mayo');
INSERT INTO international VALUES (19,'WebGUI',5,'Maio');
INSERT INTO international VALUES (20,'MessageBoard',3,'Laatste antwoord');
INSERT INTO international VALUES (20,'MessageBoard',1,'Last Reply');
INSERT INTO international VALUES (20,'MessageBoard',4,'Última respuesta');
INSERT INTO international VALUES (20,'MessageBoard',5,'Ultima resposta');
INSERT INTO international VALUES (20,'UserSubmission',3,'Post nieuwe bijdrage');
INSERT INTO international VALUES (20,'UserSubmission',1,'Post New Submission');
INSERT INTO international VALUES (20,'UserSubmission',4,'Nueva Contribución');
INSERT INTO international VALUES (20,'UserSubmission',5,'Colocar nova submissão');
INSERT INTO international VALUES (25,'WebGUI',2,'November');
INSERT INTO international VALUES (20,'WebGUI',3,'juni');
INSERT INTO international VALUES (20,'WebGUI',1,'June');
INSERT INTO international VALUES (20,'WebGUI',4,'Junio');
INSERT INTO international VALUES (20,'WebGUI',5,'Junho');
INSERT INTO international VALUES (21,'UserSubmission',3,'Ingevoerd door');
INSERT INTO international VALUES (21,'UserSubmission',1,'Submitted By');
INSERT INTO international VALUES (21,'UserSubmission',4,'Contribuida por');
INSERT INTO international VALUES (21,'UserSubmission',5,'Submetido por');
INSERT INTO international VALUES (574,'WebGUI',2,'Verbieten');
INSERT INTO international VALUES (21,'WebGUI',3,'juli');
INSERT INTO international VALUES (21,'WebGUI',1,'July');
INSERT INTO international VALUES (21,'WebGUI',4,'Julio');
INSERT INTO international VALUES (21,'WebGUI',5,'Julho');
INSERT INTO international VALUES (22,'UserSubmission',3,'ingevoerd door:');
INSERT INTO international VALUES (22,'UserSubmission',1,'Submitted By:');
INSERT INTO international VALUES (22,'UserSubmission',4,'Contribuida por:');
INSERT INTO international VALUES (22,'UserSubmission',5,'Submetido por:');
INSERT INTO international VALUES (26,'WebGUI',2,'Dezember');
INSERT INTO international VALUES (22,'WebGUI',3,'augustus');
INSERT INTO international VALUES (22,'WebGUI',1,'August');
INSERT INTO international VALUES (22,'WebGUI',4,'Agosto');
INSERT INTO international VALUES (22,'WebGUI',5,'Agosto');
INSERT INTO international VALUES (23,'UserSubmission',3,'Invoer datum:');
INSERT INTO international VALUES (23,'UserSubmission',1,'Date Submitted:');
INSERT INTO international VALUES (23,'UserSubmission',4,'Fecha Contribución:');
INSERT INTO international VALUES (23,'UserSubmission',5,'Data de submissão:');
INSERT INTO international VALUES (27,'Article',2,'Zurück zum\r\nArtikel');
INSERT INTO international VALUES (23,'WebGUI',3,'september');
INSERT INTO international VALUES (23,'WebGUI',1,'September');
INSERT INTO international VALUES (23,'WebGUI',4,'Septiembre');
INSERT INTO international VALUES (23,'WebGUI',5,'Setembro');
INSERT INTO international VALUES (572,'WebGUI',3,'Keur goed');
INSERT INTO international VALUES (572,'WebGUI',1,'Approve');
INSERT INTO international VALUES (572,'WebGUI',4,'Aprobar');
INSERT INTO international VALUES (572,'WebGUI',5,'Aprovar');
INSERT INTO international VALUES (27,'UserSubmission',2,'Bearbeiten');
INSERT INTO international VALUES (24,'WebGUI',3,'oktober');
INSERT INTO international VALUES (24,'WebGUI',1,'October');
INSERT INTO international VALUES (24,'WebGUI',4,'Octubre');
INSERT INTO international VALUES (24,'WebGUI',5,'Outubro');
INSERT INTO international VALUES (27,'WebGUI',2,'Sonntag');
INSERT INTO international VALUES (573,'WebGUI',3,'Laat in behandeling');
INSERT INTO international VALUES (573,'WebGUI',1,'Leave Pending');
INSERT INTO international VALUES (573,'WebGUI',4,'Dejan pendiente');
INSERT INTO international VALUES (573,'WebGUI',5,'Deixar pendente');
INSERT INTO international VALUES (25,'WebGUI',3,'november');
INSERT INTO international VALUES (25,'WebGUI',1,'November');
INSERT INTO international VALUES (25,'WebGUI',4,'Noviembre');
INSERT INTO international VALUES (25,'WebGUI',5,'Novembro');
INSERT INTO international VALUES (574,'WebGUI',3,'Keur af');
INSERT INTO international VALUES (574,'WebGUI',1,'Deny');
INSERT INTO international VALUES (574,'WebGUI',4,'Denegar');
INSERT INTO international VALUES (574,'WebGUI',5,'Negar');
INSERT INTO international VALUES (28,'Article',2,'Kommentare\r\nanschauen');
INSERT INTO international VALUES (26,'WebGUI',3,'december');
INSERT INTO international VALUES (26,'WebGUI',1,'December');
INSERT INTO international VALUES (26,'WebGUI',4,'Diciembre');
INSERT INTO international VALUES (26,'WebGUI',5,'Dezembro');
INSERT INTO international VALUES (27,'UserSubmission',3,'Bewerk');
INSERT INTO international VALUES (27,'UserSubmission',1,'Edit');
INSERT INTO international VALUES (27,'UserSubmission',4,'Editar');
INSERT INTO international VALUES (27,'UserSubmission',5,'Modificar');
INSERT INTO international VALUES (27,'WebGUI',3,'zondag');
INSERT INTO international VALUES (27,'WebGUI',1,'Sunday');
INSERT INTO international VALUES (27,'WebGUI',4,'Domingo');
INSERT INTO international VALUES (27,'WebGUI',5,'Domingo');
INSERT INTO international VALUES (28,'UserSubmission',3,'Ga terug naar bijdrage lijst');
INSERT INTO international VALUES (28,'UserSubmission',1,'Return To Submissions List');
INSERT INTO international VALUES (28,'UserSubmission',4,'Regresar a lista de contribuciones');
INSERT INTO international VALUES (28,'UserSubmission',5,'Voltar á lista de submissões');
INSERT INTO international VALUES (28,'UserSubmission',2,'Zurück zur\r\nBeitragsliste');
INSERT INTO international VALUES (28,'WebGUI',3,'maandag');
INSERT INTO international VALUES (28,'WebGUI',1,'Monday');
INSERT INTO international VALUES (28,'WebGUI',4,'Lunes');
INSERT INTO international VALUES (28,'WebGUI',5,'Segunda');
INSERT INTO international VALUES (29,'UserSubmission',3,'Gebruikers bijdrage systeem');
INSERT INTO international VALUES (29,'UserSubmission',1,'User Submission System');
INSERT INTO international VALUES (29,'UserSubmission',4,'Sistema de Contribución de Usuarios');
INSERT INTO international VALUES (29,'UserSubmission',5,'Sistema de submissão do utilizador');
INSERT INTO international VALUES (29,'WebGUI',3,'dinsdag');
INSERT INTO international VALUES (29,'WebGUI',1,'Tuesday');
INSERT INTO international VALUES (29,'WebGUI',4,'Martes');
INSERT INTO international VALUES (29,'WebGUI',5,'Terça');
INSERT INTO international VALUES (29,'UserSubmission',2,'Benutzer\r\nBeitragssystem');
INSERT INTO international VALUES (1,'LinkList',6,'Indentering');
INSERT INTO international VALUES (1,'Item',6,'Länk URL');
INSERT INTO international VALUES (1,'FAQ',6,'Fortsätt med att lägga till en fråga?');
INSERT INTO international VALUES (1,'ExtraColumn',6,'Extra Column');
INSERT INTO international VALUES (28,'WebGUI',2,'Montag');
INSERT INTO international VALUES (30,'WebGUI',3,'woensdag');
INSERT INTO international VALUES (30,'WebGUI',1,'Wednesday');
INSERT INTO international VALUES (30,'WebGUI',4,'Miércoles');
INSERT INTO international VALUES (30,'WebGUI',5,'Quarta');
INSERT INTO international VALUES (31,'WebGUI',3,'donderdag');
INSERT INTO international VALUES (31,'WebGUI',1,'Thursday');
INSERT INTO international VALUES (31,'WebGUI',4,'Jueves');
INSERT INTO international VALUES (31,'WebGUI',5,'Quinta');
INSERT INTO international VALUES (29,'WebGUI',2,'Dienstag');
INSERT INTO international VALUES (32,'WebGUI',3,'vrijdag');
INSERT INTO international VALUES (32,'WebGUI',1,'Friday');
INSERT INTO international VALUES (32,'WebGUI',4,'Viernes');
INSERT INTO international VALUES (32,'WebGUI',5,'Sexta');
INSERT INTO international VALUES (33,'WebGUI',3,'zaterdag');
INSERT INTO international VALUES (33,'WebGUI',1,'Saturday');
INSERT INTO international VALUES (33,'WebGUI',4,'Sabado');
INSERT INTO international VALUES (33,'WebGUI',5,'Sabado');
INSERT INTO international VALUES (34,'WebGUI',3,'Zet datum');
INSERT INTO international VALUES (34,'WebGUI',1,'set date');
INSERT INTO international VALUES (34,'WebGUI',4,'fijar fecha');
INSERT INTO international VALUES (34,'WebGUI',5,'acertar a data');
INSERT INTO international VALUES (1,'MessageBoard',6,'Läggtill Meddelande Forum');
INSERT INTO international VALUES (35,'WebGUI',3,'Administratieve functie');
INSERT INTO international VALUES (35,'WebGUI',1,'Administrative Function');
INSERT INTO international VALUES (35,'WebGUI',4,'Funciones Administrativas');
INSERT INTO international VALUES (35,'WebGUI',5,'Função administrativa');
INSERT INTO international VALUES (31,'UserSubmission',2,'Inhalt');
INSERT INTO international VALUES (30,'WebGUI',2,'Mittwoch');
INSERT INTO international VALUES (36,'WebGUI',3,'U moet een behherder zijn om deze functie uit te voeren. Neem contact op met een van de beheerders:');
INSERT INTO international VALUES (36,'WebGUI',1,'You must be an administrator to perform this function. Please contact one of your administrators. The following is a list of the administrators for this system:');
INSERT INTO international VALUES (36,'WebGUI',4,'Debe ser administrador para realizar esta tarea. Por favor contacte a uno de los administradores. La siguiente es una lista de los administradores de éste sistema:');
INSERT INTO international VALUES (36,'WebGUI',5,'Função reservada a administradores. Fale com um dos seguintes administradores:');
INSERT INTO international VALUES (37,'WebGUI',3,'Geen toegang!');
INSERT INTO international VALUES (37,'WebGUI',1,'Permission Denied!');
INSERT INTO international VALUES (37,'WebGUI',4,'Permiso Denegado!');
INSERT INTO international VALUES (37,'WebGUI',5,'Permissão negada!');
INSERT INTO international VALUES (38,'WebGUI',5,'\"Não tem privilégios para essa operação. ^a(Identifique-se na entrada); com uma conta que permita essa operação.\"');
INSERT INTO international VALUES (404,'WebGUI',1,'First Page');
INSERT INTO international VALUES (38,'WebGUI',4,'\"No tiene privilegios suficientes para realizar ésta operación. Por favor ^a(ingrese con una cuenta); que posea los privilegios suficientes antes de intentar ésta operación.\"');
INSERT INTO international VALUES (38,'WebGUI',3,'U heeft niet voldoende privileges om deze operatie te doen. ^a(Log in); als een gebruiker met voldoende privileges.');
INSERT INTO international VALUES (38,'WebGUI',1,'You do not have sufficient privileges to perform this operation. Please ^a(log in with an account); that has sufficient privileges before attempting this operation.');
INSERT INTO international VALUES (31,'WebGUI',2,'Donnerstag');
INSERT INTO international VALUES (32,'UserSubmission',2,'Grafik');
INSERT INTO international VALUES (33,'UserSubmission',2,'Anhang');
INSERT INTO international VALUES (32,'WebGUI',2,'Freitag');
INSERT INTO international VALUES (39,'WebGUI',3,'U heeft niet voldoende privileges om deze pagina op te vragen.');
INSERT INTO international VALUES (39,'WebGUI',1,'You do not have sufficient privileges to access this page.');
INSERT INTO international VALUES (39,'WebGUI',4,'No tiene suficientes privilegios para ingresar a ésta página.');
INSERT INTO international VALUES (39,'WebGUI',5,'Não tem privilégios para aceder a essa página.');
INSERT INTO international VALUES (33,'WebGUI',2,'Samstag');
INSERT INTO international VALUES (40,'WebGUI',3,'Vitaal component');
INSERT INTO international VALUES (40,'WebGUI',1,'Vital Component');
INSERT INTO international VALUES (40,'WebGUI',4,'Componente Vital');
INSERT INTO international VALUES (40,'WebGUI',5,'Componente vital');
INSERT INTO international VALUES (34,'UserSubmission',2,'Carriage\r\nReturn beachten?');
INSERT INTO international VALUES (34,'WebGUI',2,'Datum setzen');
INSERT INTO international VALUES (41,'WebGUI',3,'U probeert een vitaal component van het WebGUI systeem te verwijderen. Als u dit zou mogen dan zou WebGUI waarschijnlijk niet meer werken.');
INSERT INTO international VALUES (41,'WebGUI',1,'You\'re attempting to remove a vital component of the WebGUI system. If you were allowed to continue WebGUI may cease to function.');
INSERT INTO international VALUES (41,'WebGUI',4,'Esta intentando eliminar un componente vital del sistema WebGUI. Si continúa puede causar un mal funcionamiento de WebGUI.');
INSERT INTO international VALUES (41,'WebGUI',5,'Está a tentar remover um componente vital do WebGUI. Se continuar pode haver um erro grave.');
INSERT INTO international VALUES (42,'WebGUI',3,'Alstublieft bevestigen');
INSERT INTO international VALUES (42,'WebGUI',1,'Please Confirm');
INSERT INTO international VALUES (42,'WebGUI',4,'Por favor confirme');
INSERT INTO international VALUES (42,'WebGUI',5,'Confirma');
INSERT INTO international VALUES (43,'WebGUI',3,'Weet u zeker dat u deze inhoud wilt verwijderen?');
INSERT INTO international VALUES (43,'WebGUI',1,'Are you certain that you wish to delete this content?');
INSERT INTO international VALUES (43,'WebGUI',4,'Está seguro de querer eliminar éste contenido?');
INSERT INTO international VALUES (43,'WebGUI',5,'Tem a certeza que quer apagar este conteudo?');
INSERT INTO international VALUES (35,'UserSubmission',2,'Titel');
INSERT INTO international VALUES (35,'WebGUI',2,'Administrative\r\nFunktion');
INSERT INTO international VALUES (44,'WebGUI',3,'\"Ja, ik weet het zeker.\"');
INSERT INTO international VALUES (44,'WebGUI',1,'Yes, I\'m sure.');
INSERT INTO international VALUES (44,'WebGUI',4,'Si');
INSERT INTO international VALUES (44,'WebGUI',5,'\"Sim, tenho a certeza.\"');
INSERT INTO international VALUES (45,'WebGUI',3,'\"Nee, ik heb een foutje gemaakt.\"');
INSERT INTO international VALUES (45,'WebGUI',1,'No, I made a mistake.');
INSERT INTO international VALUES (45,'WebGUI',4,'No');
INSERT INTO international VALUES (45,'WebGUI',5,'\"Não, enganei-me.\"');
INSERT INTO international VALUES (46,'WebGUI',3,'Mijn account');
INSERT INTO international VALUES (46,'WebGUI',1,'My Account');
INSERT INTO international VALUES (46,'WebGUI',4,'Mi Cuenta');
INSERT INTO international VALUES (46,'WebGUI',5,'Minha Conta');
INSERT INTO international VALUES (47,'WebGUI',3,'Home');
INSERT INTO international VALUES (47,'WebGUI',1,'Home');
INSERT INTO international VALUES (47,'WebGUI',4,'Home');
INSERT INTO international VALUES (47,'WebGUI',5,'Inicio');
INSERT INTO international VALUES (48,'WebGUI',3,'Hallo');
INSERT INTO international VALUES (48,'WebGUI',1,'Hello');
INSERT INTO international VALUES (48,'WebGUI',4,'Hola');
INSERT INTO international VALUES (48,'WebGUI',5,'Ola');
INSERT INTO international VALUES (49,'WebGUI',3,'Klik <a href=\"^\\;?op=logout\">hier</a> om uit te loggen.');
INSERT INTO international VALUES (49,'WebGUI',1,'Click <a href=\"^\\;?op=logout\">here</a> to log out.');
INSERT INTO international VALUES (49,'WebGUI',4,'Click <a href=\"^\\;?op=logout\">aquí</a> para salir.');
INSERT INTO international VALUES (49,'WebGUI',5,'Clique <a href=\"^\\;?op=logout\">aqui</a> para sair.');
INSERT INTO international VALUES (50,'WebGUI',3,'Gebruikersnaam');
INSERT INTO international VALUES (50,'WebGUI',1,'Username');
INSERT INTO international VALUES (50,'WebGUI',4,'Nombre usuario');
INSERT INTO international VALUES (50,'WebGUI',5,'Username');
INSERT INTO international VALUES (51,'WebGUI',3,'Wachtwoord');
INSERT INTO international VALUES (51,'WebGUI',1,'Password');
INSERT INTO international VALUES (51,'WebGUI',4,'Password');
INSERT INTO international VALUES (51,'WebGUI',5,'Password');
INSERT INTO international VALUES (52,'WebGUI',3,'Login');
INSERT INTO international VALUES (52,'WebGUI',1,'login');
INSERT INTO international VALUES (52,'WebGUI',4,'ingresar');
INSERT INTO international VALUES (52,'WebGUI',5,'entrar');
INSERT INTO international VALUES (36,'WebGUI',2,'Um diese Funktion\r\nausführen zu können, müssen Sie Administrator sein. Eine der folgenden\r\nPersonen kann Sie zum Administrator machen:');
INSERT INTO international VALUES (53,'WebGUI',3,'Maak pagina printbaar');
INSERT INTO international VALUES (53,'WebGUI',1,'Make Page Printable');
INSERT INTO international VALUES (53,'WebGUI',4,'Hacer página imprimible');
INSERT INTO international VALUES (53,'WebGUI',5,'Versão para impressão');
INSERT INTO international VALUES (54,'WebGUI',3,'Creëer account');
INSERT INTO international VALUES (54,'WebGUI',1,'Create Account');
INSERT INTO international VALUES (54,'WebGUI',4,'Crear Cuenta');
INSERT INTO international VALUES (54,'WebGUI',5,'Criar conta');
INSERT INTO international VALUES (55,'WebGUI',3,'Wachtwoord (bevestigen)');
INSERT INTO international VALUES (55,'WebGUI',1,'Password (confirm)');
INSERT INTO international VALUES (55,'WebGUI',4,'Password (confirmar)');
INSERT INTO international VALUES (55,'WebGUI',5,'Password (confirmar)');
INSERT INTO international VALUES (37,'UserSubmission',2,'Löschen');
INSERT INTO international VALUES (56,'WebGUI',3,'Email adres');
INSERT INTO international VALUES (56,'WebGUI',1,'Email Address');
INSERT INTO international VALUES (56,'WebGUI',4,'Dirección de e-mail');
INSERT INTO international VALUES (56,'WebGUI',5,'Endereço de e-mail');
INSERT INTO international VALUES (37,'WebGUI',2,'Zugriff\r\nverweigert!');
INSERT INTO international VALUES (57,'WebGUI',3,'Dit is alleen nodig als er functies gebruikt worden die Email nodig hebben.');
INSERT INTO international VALUES (57,'WebGUI',1,'This is only necessary if you wish to use features that require Email.');
INSERT INTO international VALUES (57,'WebGUI',4,'Solo es necesaria si desea usar opciones que requieren e-mail.');
INSERT INTO international VALUES (57,'WebGUI',5,'Apenas é necessário se pretender utilizar as funcionalidade que envolvam e-mail.');
INSERT INTO international VALUES (58,'WebGUI',3,'Ik heb al een account.');
INSERT INTO international VALUES (58,'WebGUI',1,'I already have an account.');
INSERT INTO international VALUES (58,'WebGUI',4,'Ya tengo una cuenta!');
INSERT INTO international VALUES (58,'WebGUI',5,'Já tenho uma conta.');
INSERT INTO international VALUES (59,'WebGUI',3,'Ik ben mijn wachtwoord vergeten.');
INSERT INTO international VALUES (59,'WebGUI',1,'I forgot my password.');
INSERT INTO international VALUES (59,'WebGUI',4,'Perdí mi password');
INSERT INTO international VALUES (59,'WebGUI',5,'Esqueci a minha password.');
INSERT INTO international VALUES (38,'WebGUI',2,'Sie sind nicht\r\nberechtigt, diese Aktion auszuführen. ^a(Melden Sie sich bitte mit einem\r\nBenutzernamen an);, der über ausreichende Rechte verfügt.');
INSERT INTO international VALUES (60,'WebGUI',3,'Weet u zeker dat u uw account wilt deaktiveren? Als u doorgaat gaat alle account informatie voorgoed verloren.');
INSERT INTO international VALUES (60,'WebGUI',1,'Are you certain you want to deactivate your account. If you proceed your account information will be lost permanently.');
INSERT INTO international VALUES (60,'WebGUI',4,'Está seguro que quiere desactivar su cuenta. Si continúa su información se perderá permanentemente.');
INSERT INTO international VALUES (60,'WebGUI',5,'Tem a certeza que quer desactivar a sua conta. Se o fizer é permanente!');
INSERT INTO international VALUES (61,'WebGUI',3,'Account informatie bijwerken');
INSERT INTO international VALUES (61,'WebGUI',1,'Update Account Information');
INSERT INTO international VALUES (61,'WebGUI',4,'Actualizar información de la Cuenta');
INSERT INTO international VALUES (61,'WebGUI',5,'Actualizar as informações da conta');
INSERT INTO international VALUES (62,'WebGUI',3,'Bewaar');
INSERT INTO international VALUES (62,'WebGUI',1,'save');
INSERT INTO international VALUES (62,'WebGUI',4,'guardar');
INSERT INTO international VALUES (62,'WebGUI',5,'gravar');
INSERT INTO international VALUES (63,'WebGUI',3,'Zet beheermode aan');
INSERT INTO international VALUES (63,'WebGUI',1,'Turn admin on.');
INSERT INTO international VALUES (63,'WebGUI',4,'Encender Admin');
INSERT INTO international VALUES (63,'WebGUI',5,'Ligar modo administrativo.');
INSERT INTO international VALUES (64,'WebGUI',3,'Log uit.');
INSERT INTO international VALUES (64,'WebGUI',1,'Log out.');
INSERT INTO international VALUES (64,'WebGUI',4,'Salir');
INSERT INTO international VALUES (64,'WebGUI',5,'Sair.');
INSERT INTO international VALUES (40,'WebGUI',2,'Notwendiger\r\nBestandteil');
INSERT INTO international VALUES (39,'WebGUI',2,'Sie sind nicht\r\nberechtigt, diese Seite anzuschauen.');
INSERT INTO international VALUES (65,'WebGUI',3,'Deaktiveer mijn account voorgoed.');
INSERT INTO international VALUES (65,'WebGUI',1,'Please deactivate my account permanently.');
INSERT INTO international VALUES (65,'WebGUI',4,'Por favor desactive mi cuenta permanentemente');
INSERT INTO international VALUES (65,'WebGUI',5,'Desactivar a minha conta permanentemente.');
INSERT INTO international VALUES (66,'WebGUI',3,'Log in');
INSERT INTO international VALUES (66,'WebGUI',1,'Log In');
INSERT INTO international VALUES (66,'WebGUI',4,'Ingresar');
INSERT INTO international VALUES (66,'WebGUI',5,'Entrar');
INSERT INTO international VALUES (67,'WebGUI',3,'Creëer een nieuw account');
INSERT INTO international VALUES (67,'WebGUI',1,'Create a new account.');
INSERT INTO international VALUES (67,'WebGUI',4,'Crear nueva Cuenta');
INSERT INTO international VALUES (67,'WebGUI',5,'Criar nova conta.');
INSERT INTO international VALUES (68,'WebGUI',3,'De account informatie is niet geldig. Het account bestaat niet of de gebruikersnaam/wachtwoord was fout.');
INSERT INTO international VALUES (68,'WebGUI',1,'The account information you supplied is invalid. Either the account does not exist or the username/password combination was incorrect.');
INSERT INTO international VALUES (68,'WebGUI',4,'La información de su cuenta no es válida. O la cuenta no existe');
INSERT INTO international VALUES (68,'WebGUI',5,'As informações da sua conta não foram encontradas. Não existe ou a combinação username/password está incorrecta.');
INSERT INTO international VALUES (69,'WebGUI',3,'Vraag uw systeembeheerder om assistentie.');
INSERT INTO international VALUES (69,'WebGUI',1,'Please contact your system administrator for assistance.');
INSERT INTO international VALUES (69,'WebGUI',4,'Por favor contacte a su administrador por asistencia.');
INSERT INTO international VALUES (69,'WebGUI',5,'Contacte o seu administrador de sistemas para assistência.');
INSERT INTO international VALUES (42,'WebGUI',2,'Bitte bestätigen\r\nSie');
INSERT INTO international VALUES (41,'WebGUI',2,'Sie versuchen\r\neinen notwendigen Bestandteil des Systems zu löschen. WebGUI wird nach\r\ndieser Aktion möglicherweise nicht mehr richtig funktionieren.');
INSERT INTO international VALUES (70,'WebGUI',3,'Fout');
INSERT INTO international VALUES (70,'WebGUI',1,'Error');
INSERT INTO international VALUES (70,'WebGUI',4,'Error');
INSERT INTO international VALUES (70,'WebGUI',5,'Erro');
INSERT INTO international VALUES (71,'WebGUI',3,'Wachtwoord terugvinden');
INSERT INTO international VALUES (71,'WebGUI',1,'Recover password');
INSERT INTO international VALUES (71,'WebGUI',4,'Recuperar password');
INSERT INTO international VALUES (71,'WebGUI',5,'Recuperar password');
INSERT INTO international VALUES (72,'WebGUI',3,'Terugvinden');
INSERT INTO international VALUES (72,'WebGUI',1,'recover');
INSERT INTO international VALUES (72,'WebGUI',4,'recuperar');
INSERT INTO international VALUES (72,'WebGUI',5,'recoperar');
INSERT INTO international VALUES (73,'WebGUI',3,'Log in.');
INSERT INTO international VALUES (73,'WebGUI',1,'Log in.');
INSERT INTO international VALUES (73,'WebGUI',4,'Ingresar.');
INSERT INTO international VALUES (73,'WebGUI',5,'Entrar.');
INSERT INTO international VALUES (43,'WebGUI',2,'Sind Sie sicher,\r\ndass Sie diesen Inhalt löschen möchten?');
INSERT INTO international VALUES (74,'WebGUI',3,'Account informatie');
INSERT INTO international VALUES (74,'WebGUI',1,'Account Information');
INSERT INTO international VALUES (74,'WebGUI',4,'Información de la Cuenta');
INSERT INTO international VALUES (74,'WebGUI',5,'Informações da sua conta');
INSERT INTO international VALUES (44,'WebGUI',2,'Ja, ich bin mir\r\nsicher.');
INSERT INTO international VALUES (75,'WebGUI',3,'Uw account informatie is naar uw email adres verzonden.');
INSERT INTO international VALUES (75,'WebGUI',1,'Your account information has been sent to your email address.');
INSERT INTO international VALUES (75,'WebGUI',4,'La información de su cuenta ha sido enviada a su e-mail-');
INSERT INTO international VALUES (75,'WebGUI',5,'As informações da sua conta foram envidas para o seu e-mail.');
INSERT INTO international VALUES (76,'WebGUI',3,'Dat email adresis niet in onze database aanwezig.');
INSERT INTO international VALUES (76,'WebGUI',1,'That email address is not in our databases.');
INSERT INTO international VALUES (76,'WebGUI',4,'El e-mail no está en nuestra base de datos');
INSERT INTO international VALUES (76,'WebGUI',5,'Esse endereço de e-mail não foi encontrado nas nossas bases de dados');
INSERT INTO international VALUES (45,'WebGUI',2,'Nein, ich habe\r\neinen Fehler gemacht.');
INSERT INTO international VALUES (46,'WebGUI',2,'Mein\r\nBenutzerkonto');
INSERT INTO international VALUES (77,'WebGUI',3,'Deze account naam wordt al gebruikt door een andere gebruiker van dit systeem. Probeer een andere naam. We hebben de volgende suggesties:');
INSERT INTO international VALUES (77,'WebGUI',1,'That account name is already in use by another member of this site. Please try a different username. The following are some suggestions:');
INSERT INTO international VALUES (77,'WebGUI',4,'El nombre de cuenta ya está en uso por otro miembro. Por favor trate con otro nombre de usuario.  Los siguiente son algunas sugerencias:');
INSERT INTO international VALUES (77,'WebGUI',5,'\"Esse nome de conta já existe, tente outro. Veja as nossas sugestões:\"');
INSERT INTO international VALUES (78,'WebGUI',3,'De wachtwoorden waren niet gelijk. Probeer opnieuw.');
INSERT INTO international VALUES (78,'WebGUI',1,'Your passwords did not match. Please try again.');
INSERT INTO international VALUES (78,'WebGUI',4,'Su password no concuerda. Trate de nuevo.');
INSERT INTO international VALUES (78,'WebGUI',5,'\"As suas passwords não coincidem, tente novamente.\"');
INSERT INTO international VALUES (47,'WebGUI',2,'Startseite');
INSERT INTO international VALUES (48,'WebGUI',2,'Hallo');
INSERT INTO international VALUES (79,'WebGUI',3,'Kan niet verbinden met LDAP server.');
INSERT INTO international VALUES (79,'WebGUI',1,'Cannot connect to LDAP server.');
INSERT INTO international VALUES (79,'WebGUI',4,'No se puede conectar con el servidor LDAP');
INSERT INTO international VALUES (79,'WebGUI',5,'Impossivel ligar ao LDAP.');
INSERT INTO international VALUES (50,'WebGUI',2,'Benutzername');
INSERT INTO international VALUES (80,'WebGUI',3,'Account is aangemaakt!');
INSERT INTO international VALUES (80,'WebGUI',1,'Account created successfully!');
INSERT INTO international VALUES (80,'WebGUI',4,'La cuenta se ha creado con éxito!');
INSERT INTO international VALUES (80,'WebGUI',5,'Conta criada com sucesso!');
INSERT INTO international VALUES (81,'WebGUI',3,'Account is aangepast!');
INSERT INTO international VALUES (81,'WebGUI',1,'Account updated successfully!');
INSERT INTO international VALUES (81,'WebGUI',4,'La cuenta se actualizó con éxito!');
INSERT INTO international VALUES (81,'WebGUI',5,'Conta actualizada com sucesso!');
INSERT INTO international VALUES (82,'WebGUI',3,'Administratieve functies...');
INSERT INTO international VALUES (82,'WebGUI',1,'Administrative functions...');
INSERT INTO international VALUES (82,'WebGUI',4,'Funciones Administrativas...');
INSERT INTO international VALUES (82,'WebGUI',5,'Funções administrativas...');
INSERT INTO international VALUES (52,'WebGUI',2,'Anmelden');
INSERT INTO international VALUES (49,'WebGUI',2,'Hier können Sie\r\nsich <a href=\"^;?op=logout\">abmelden</a>.');
INSERT INTO international VALUES (84,'WebGUI',3,'Groep naam');
INSERT INTO international VALUES (84,'WebGUI',1,'Group Name');
INSERT INTO international VALUES (84,'WebGUI',4,'Nombre del Grupo');
INSERT INTO international VALUES (84,'WebGUI',5,'Nome do grupo');
INSERT INTO international VALUES (51,'WebGUI',2,'Passwort');
INSERT INTO international VALUES (85,'WebGUI',3,'Beschrijving');
INSERT INTO international VALUES (85,'WebGUI',1,'Description');
INSERT INTO international VALUES (85,'WebGUI',4,'Descripción');
INSERT INTO international VALUES (85,'WebGUI',5,'Descrição');
INSERT INTO international VALUES (53,'WebGUI',2,'Druckerbares\r\nFormat');
INSERT INTO international VALUES (86,'WebGUI',3,'Weet u zeker dat u deze groep wilt verwijderen? Denk er aan dat een groep verwijderen permanent en alle privileges geassocieerd met de groep verwijdert worden.');
INSERT INTO international VALUES (86,'WebGUI',1,'Are you certain you wish to delete this group? Beware that deleting a group is permanent and will remove all privileges associated with this group.');
INSERT INTO international VALUES (86,'WebGUI',4,'Está segugo de querer eliminar éste grupo? Tenga en cuenta que la eliminación es permanente y removerá todos los privilegios asociados con el grupo.');
INSERT INTO international VALUES (86,'WebGUI',5,'Tem a certeza que quer apagar este grupo. Se o fizer apaga-o permanentemente e a todos os seus provilégios.');
INSERT INTO international VALUES (54,'WebGUI',2,'Benutzerkonto\r\nanlegen');
INSERT INTO international VALUES (87,'WebGUI',3,'Bewerk groep');
INSERT INTO international VALUES (87,'WebGUI',1,'Edit Group');
INSERT INTO international VALUES (87,'WebGUI',4,'Editar Grupo');
INSERT INTO international VALUES (87,'WebGUI',5,'Modificar grupo');
INSERT INTO international VALUES (88,'WebGUI',3,'Grebruikers in groep');
INSERT INTO international VALUES (88,'WebGUI',1,'Users In Group');
INSERT INTO international VALUES (88,'WebGUI',4,'Usuarios en Grupo');
INSERT INTO international VALUES (88,'WebGUI',5,'Utilizadores no grupo');
INSERT INTO international VALUES (55,'WebGUI',2,'Passwort\r\n(bestätigen)');
INSERT INTO international VALUES (89,'WebGUI',3,'Groepen');
INSERT INTO international VALUES (89,'WebGUI',1,'Groups');
INSERT INTO international VALUES (89,'WebGUI',4,'Grupos');
INSERT INTO international VALUES (89,'WebGUI',5,'Grupos');
INSERT INTO international VALUES (90,'WebGUI',3,'Voeg nieuwe groep toe.');
INSERT INTO international VALUES (90,'WebGUI',1,'Add new group.');
INSERT INTO international VALUES (90,'WebGUI',4,'Agregar nuevo grupo');
INSERT INTO international VALUES (90,'WebGUI',5,'Adicionar novo grupo.');
INSERT INTO international VALUES (91,'WebGUI',3,'Vorige pagina');
INSERT INTO international VALUES (91,'WebGUI',1,'Previous Page');
INSERT INTO international VALUES (91,'WebGUI',4,'Página previa');
INSERT INTO international VALUES (91,'WebGUI',5,'Página anterior');
INSERT INTO international VALUES (92,'WebGUI',3,'Volgende pagina');
INSERT INTO international VALUES (92,'WebGUI',1,'Next Page');
INSERT INTO international VALUES (92,'WebGUI',4,'Siguiente página');
INSERT INTO international VALUES (92,'WebGUI',5,'Próxima página');
INSERT INTO international VALUES (93,'WebGUI',3,'Help');
INSERT INTO international VALUES (93,'WebGUI',1,'Help');
INSERT INTO international VALUES (93,'WebGUI',4,'Ayuda');
INSERT INTO international VALUES (93,'WebGUI',5,'Ajuda');
INSERT INTO international VALUES (94,'WebGUI',3,'Zie ook');
INSERT INTO international VALUES (94,'WebGUI',1,'See also');
INSERT INTO international VALUES (94,'WebGUI',4,'Vea también');
INSERT INTO international VALUES (94,'WebGUI',5,'Ver tembém');
INSERT INTO international VALUES (57,'WebGUI',2,'(Dies ist nur\r\nnotwendig, wenn Sie Eigenschaften benutzen möchten die eine Emailadresse\r\nvoraussetzen)');
INSERT INTO international VALUES (95,'WebGUI',3,'Help index');
INSERT INTO international VALUES (95,'WebGUI',1,'Help Index');
INSERT INTO international VALUES (95,'WebGUI',4,'Índice de Ayuda');
INSERT INTO international VALUES (95,'WebGUI',5,'Indice da ajuda');
INSERT INTO international VALUES (56,'WebGUI',2,'Email Adresse');
INSERT INTO international VALUES (5,'LinkList',6,'Fortsätt med att lägga till en länk?');
INSERT INTO international VALUES (5,'Item',6,'Ladda ned bilaga');
INSERT INTO international VALUES (58,'WebGUI',2,'Ich besitze\r\nbereits ein Benutzerkonto.');
INSERT INTO international VALUES (99,'WebGUI',3,'Titel');
INSERT INTO international VALUES (99,'WebGUI',1,'Title');
INSERT INTO international VALUES (99,'WebGUI',4,'Título');
INSERT INTO international VALUES (99,'WebGUI',5,'Titulo');
INSERT INTO international VALUES (100,'WebGUI',3,'Meta tags');
INSERT INTO international VALUES (100,'WebGUI',1,'Meta Tags');
INSERT INTO international VALUES (100,'WebGUI',4,'Meta Tags');
INSERT INTO international VALUES (100,'WebGUI',5,'Meta Tags');
INSERT INTO international VALUES (59,'WebGUI',2,'Ich habe mein\r\nPasswort vergessen');
INSERT INTO international VALUES (101,'WebGUI',3,'Weet u zeker dat u deze pagina wilt verwijderen en alle inhoud en objecten erachter?');
INSERT INTO international VALUES (101,'WebGUI',1,'Are you certain that you wish to delete this page, its content, and all items under it?');
INSERT INTO international VALUES (101,'WebGUI',4,'Está seguro de querer eliminar ésta página');
INSERT INTO international VALUES (101,'WebGUI',5,'\"Tem a certeza que quer apagar esta página, o seu conteudo e tudo que está abaixo?\"');
INSERT INTO international VALUES (102,'WebGUI',3,'Bewerk pagina');
INSERT INTO international VALUES (102,'WebGUI',1,'Edit Page');
INSERT INTO international VALUES (102,'WebGUI',4,'Editar Página');
INSERT INTO international VALUES (102,'WebGUI',5,'Modificar a página');
INSERT INTO international VALUES (103,'WebGUI',3,'Pagina specifiek');
INSERT INTO international VALUES (103,'WebGUI',1,'Page Specifics');
INSERT INTO international VALUES (103,'WebGUI',4,'Propio de la página');
INSERT INTO international VALUES (103,'WebGUI',5,'Especificações da página');
INSERT INTO international VALUES (104,'WebGUI',3,'Pagina URL');
INSERT INTO international VALUES (104,'WebGUI',1,'Page URL');
INSERT INTO international VALUES (104,'WebGUI',4,'URL de la página');
INSERT INTO international VALUES (104,'WebGUI',5,'URL da página');
INSERT INTO international VALUES (105,'WebGUI',3,'Stijl');
INSERT INTO international VALUES (105,'WebGUI',1,'Style');
INSERT INTO international VALUES (105,'WebGUI',4,'Estilo');
INSERT INTO international VALUES (105,'WebGUI',5,'Estilo');
INSERT INTO international VALUES (60,'WebGUI',2,'Sind Sie sicher,\r\ndass Sie dieses Benutzerkonto deaktivieren möchten? Wenn Sie fortfahren\r\nsind Ihre Konteninformationen endgültig verloren.');
INSERT INTO international VALUES (106,'WebGUI',3,'Aanvinken om deze stijl in alle pagina\'s te gebruiiken.');
INSERT INTO international VALUES (106,'WebGUI',1,'Select \"Yes\" to change all the pages under this page to this style.');
INSERT INTO international VALUES (106,'WebGUI',4,'Marque para dar éste estilo a todas las sub-páginas.');
INSERT INTO international VALUES (106,'WebGUI',5,'Escolha para atribuir este estilo a todas as sub-páginas');
INSERT INTO international VALUES (107,'WebGUI',3,'Privileges');
INSERT INTO international VALUES (107,'WebGUI',1,'Privileges');
INSERT INTO international VALUES (107,'WebGUI',4,'Privilegios');
INSERT INTO international VALUES (107,'WebGUI',5,'Privilégios');
INSERT INTO international VALUES (108,'WebGUI',3,'Eigenaar');
INSERT INTO international VALUES (108,'WebGUI',1,'Owner');
INSERT INTO international VALUES (108,'WebGUI',4,'Dueño');
INSERT INTO international VALUES (108,'WebGUI',5,'Dono');
INSERT INTO international VALUES (61,'WebGUI',2,'Benutzerkontendetails aktualisieren');
INSERT INTO international VALUES (109,'WebGUI',3,'Eigenaar kan bekijken?');
INSERT INTO international VALUES (109,'WebGUI',1,'Owner can view?');
INSERT INTO international VALUES (109,'WebGUI',4,'Dueño puede ver?');
INSERT INTO international VALUES (109,'WebGUI',5,'O dono pode ver?');
INSERT INTO international VALUES (110,'WebGUI',3,'Gebruiker kan bewerken?');
INSERT INTO international VALUES (110,'WebGUI',1,'Owner can edit?');
INSERT INTO international VALUES (110,'WebGUI',4,'Dueño puede editar?');
INSERT INTO international VALUES (110,'WebGUI',5,'O dono pode modificar?');
INSERT INTO international VALUES (64,'WebGUI',2,'Abmelden');
INSERT INTO international VALUES (111,'WebGUI',3,'Groep');
INSERT INTO international VALUES (111,'WebGUI',1,'Group');
INSERT INTO international VALUES (111,'WebGUI',4,'Grupo');
INSERT INTO international VALUES (111,'WebGUI',5,'Grupo');
INSERT INTO international VALUES (112,'WebGUI',3,'Groep kan bekijken?');
INSERT INTO international VALUES (112,'WebGUI',1,'Group can view?');
INSERT INTO international VALUES (112,'WebGUI',4,'Grupo puede ver?');
INSERT INTO international VALUES (112,'WebGUI',5,'O grupo pode ver?');
INSERT INTO international VALUES (113,'WebGUI',3,'Groep kan bewerken?');
INSERT INTO international VALUES (113,'WebGUI',1,'Group can edit?');
INSERT INTO international VALUES (113,'WebGUI',4,'Grupo puede editar?');
INSERT INTO international VALUES (113,'WebGUI',5,'O grupo pode modificar?');
INSERT INTO international VALUES (63,'WebGUI',2,'Administrationsmodus einschalten');
INSERT INTO international VALUES (114,'WebGUI',3,'Iedereen kan bekijken?');
INSERT INTO international VALUES (114,'WebGUI',1,'Anybody can view?');
INSERT INTO international VALUES (114,'WebGUI',4,'Cualquiera puede ver?');
INSERT INTO international VALUES (114,'WebGUI',5,'Qualquer pessoa pode ver?');
INSERT INTO international VALUES (115,'WebGUI',3,'Iedereen kan bewerken?');
INSERT INTO international VALUES (115,'WebGUI',1,'Anybody can edit?');
INSERT INTO international VALUES (115,'WebGUI',4,'Cualquiera puede editar?');
INSERT INTO international VALUES (115,'WebGUI',5,'Qualquer pessoa pode modificar?');
INSERT INTO international VALUES (62,'WebGUI',2,'sichern');
INSERT INTO international VALUES (116,'WebGUI',3,'Aanvinken om deze privileges aan alle sub pagina\'s te geven.');
INSERT INTO international VALUES (116,'WebGUI',1,'Select \"Yes\" to change the privileges of all pages under this page to these privileges.');
INSERT INTO international VALUES (116,'WebGUI',4,'Marque para dar éstos privilegios a todas las sub-páginas.');
INSERT INTO international VALUES (116,'WebGUI',5,'Escolher para atribuir estes privilégios a todas as sub-páginas.');
INSERT INTO international VALUES (117,'WebGUI',3,'Bewerk toegangs controle instellingen');
INSERT INTO international VALUES (117,'WebGUI',1,'Edit User Settings');
INSERT INTO international VALUES (117,'WebGUI',4,'Editar Opciones de Auntentificación');
INSERT INTO international VALUES (117,'WebGUI',5,'Modificar preferências de autenticação');
INSERT INTO international VALUES (65,'WebGUI',2,'Benutzerkonto\r\nendgültig deaktivieren');
INSERT INTO international VALUES (118,'WebGUI',3,'Anonieme registratie');
INSERT INTO international VALUES (118,'WebGUI',1,'Anonymous Registration');
INSERT INTO international VALUES (118,'WebGUI',4,'Registración Anónima');
INSERT INTO international VALUES (118,'WebGUI',5,'Registo anónimo');
INSERT INTO international VALUES (119,'WebGUI',3,'Toegangs controle methode (standaard)');
INSERT INTO international VALUES (119,'WebGUI',1,'Authentication Method (default)');
INSERT INTO international VALUES (119,'WebGUI',4,'Método de Autentificación (por defecto)');
INSERT INTO international VALUES (119,'WebGUI',5,'Método de autenticação (defeito)');
INSERT INTO international VALUES (120,'WebGUI',3,'LDAP URL (standaard)');
INSERT INTO international VALUES (120,'WebGUI',1,'LDAP URL (default)');
INSERT INTO international VALUES (120,'WebGUI',4,'URL LDAP (por defecto)');
INSERT INTO international VALUES (120,'WebGUI',5,'URL LDAP (defeito)');
INSERT INTO international VALUES (121,'WebGUI',3,'LDAP identiteit (standaard)');
INSERT INTO international VALUES (121,'WebGUI',1,'LDAP Identity (default)');
INSERT INTO international VALUES (121,'WebGUI',4,'Identidad LDAP (por defecto)');
INSERT INTO international VALUES (121,'WebGUI',5,'Identidade LDAP (defeito)');
INSERT INTO international VALUES (122,'WebGUI',3,'LDAP identiteit naam');
INSERT INTO international VALUES (122,'WebGUI',1,'LDAP Identity Name');
INSERT INTO international VALUES (122,'WebGUI',4,'Nombre Identidad LDAP');
INSERT INTO international VALUES (122,'WebGUI',5,'Nome da entidade LDAP');
INSERT INTO international VALUES (123,'WebGUI',3,'LDAP wachtwoord naam');
INSERT INTO international VALUES (123,'WebGUI',1,'LDAP Password Name');
INSERT INTO international VALUES (123,'WebGUI',4,'Password LDAP');
INSERT INTO international VALUES (123,'WebGUI',5,'Nome da password LDAP');
INSERT INTO international VALUES (124,'WebGUI',3,'Bewerk bedrijfsinformatie');
INSERT INTO international VALUES (124,'WebGUI',1,'Edit Company Information');
INSERT INTO international VALUES (124,'WebGUI',4,'Editar Información de la Companía');
INSERT INTO international VALUES (124,'WebGUI',5,'Modificar informação da empresa');
INSERT INTO international VALUES (125,'WebGUI',3,'Bedrijfsnaam');
INSERT INTO international VALUES (125,'WebGUI',1,'Company Name');
INSERT INTO international VALUES (125,'WebGUI',4,'Nombre de la Companía');
INSERT INTO international VALUES (125,'WebGUI',5,'Nome da empresa');
INSERT INTO international VALUES (126,'WebGUI',3,'Email adres bedrijf');
INSERT INTO international VALUES (126,'WebGUI',1,'Company Email Address');
INSERT INTO international VALUES (126,'WebGUI',4,'E-mail de la Companía');
INSERT INTO international VALUES (126,'WebGUI',5,'Moarada da empresa');
INSERT INTO international VALUES (68,'WebGUI',2,'Die\r\nBenutzerkontoinformationen die Sie eingegeben haben, sind ungültig.\r\nEntweder existiert das Konto nicht, oder die Kombination aus Benutzername\r\nund Passwort ist falsch.');
INSERT INTO international VALUES (127,'WebGUI',3,'URL bedrijf');
INSERT INTO international VALUES (127,'WebGUI',1,'Company URL');
INSERT INTO international VALUES (127,'WebGUI',4,'URL de la Companía');
INSERT INTO international VALUES (127,'WebGUI',5,'URL da empresa');
INSERT INTO international VALUES (67,'WebGUI',2,'Neues\r\nBenutzerkonto einrichten');
INSERT INTO international VALUES (66,'WebGUI',2,'Anmelden');
INSERT INTO international VALUES (130,'WebGUI',3,'Maximum grootte bijlagen');
INSERT INTO international VALUES (130,'WebGUI',1,'Maximum Attachment Size');
INSERT INTO international VALUES (130,'WebGUI',4,'Tamaño máximo de adjuntos');
INSERT INTO international VALUES (130,'WebGUI',5,'Tamanho máximo dos anexos');
INSERT INTO international VALUES (69,'WebGUI',2,'Bitten Sie Ihren\r\nSystemadministrator um Hilfe.');
INSERT INTO international VALUES (133,'WebGUI',3,'Bewerk email instellingen');
INSERT INTO international VALUES (133,'WebGUI',1,'Edit Mail Settings');
INSERT INTO international VALUES (133,'WebGUI',4,'Editar configuración de e-mail');
INSERT INTO international VALUES (133,'WebGUI',5,'Modificar preferências de e-mail');
INSERT INTO international VALUES (70,'WebGUI',2,'Fehler');
INSERT INTO international VALUES (134,'WebGUI',3,'Bericht om wachtwoord terug te vinden');
INSERT INTO international VALUES (134,'WebGUI',1,'Recover Password Message');
INSERT INTO international VALUES (134,'WebGUI',4,'Mensage de Recuperar Password');
INSERT INTO international VALUES (134,'WebGUI',5,'Mensagem de recuperação de password');
INSERT INTO international VALUES (135,'WebGUI',3,'SMTP server');
INSERT INTO international VALUES (135,'WebGUI',1,'SMTP Server');
INSERT INTO international VALUES (135,'WebGUI',4,'Servidor SMTP');
INSERT INTO international VALUES (135,'WebGUI',5,'Servidor SMTP');
INSERT INTO international VALUES (71,'WebGUI',2,'Passwort\r\nwiederherstellen');
INSERT INTO international VALUES (72,'WebGUI',2,'wiederherstellen');
INSERT INTO international VALUES (138,'WebGUI',3,'Ja');
INSERT INTO international VALUES (138,'WebGUI',1,'Yes');
INSERT INTO international VALUES (138,'WebGUI',4,'Si');
INSERT INTO international VALUES (138,'WebGUI',5,'Sim');
INSERT INTO international VALUES (139,'WebGUI',3,'Nee');
INSERT INTO international VALUES (139,'WebGUI',1,'No');
INSERT INTO international VALUES (139,'WebGUI',4,'No');
INSERT INTO international VALUES (139,'WebGUI',5,'Não');
INSERT INTO international VALUES (75,'WebGUI',2,'Ihre\r\nBenutzerkonteninformation wurde an Ihre Emailadresse geschickt');
INSERT INTO international VALUES (140,'WebGUI',3,'Bewerk allerlei instellingen');
INSERT INTO international VALUES (140,'WebGUI',1,'Edit Miscellaneous Settings');
INSERT INTO international VALUES (140,'WebGUI',4,'Editar configuraciones misceláneas');
INSERT INTO international VALUES (140,'WebGUI',5,'Modificar preferências mistas');
INSERT INTO international VALUES (141,'WebGUI',3,'Niet gevonden pagina');
INSERT INTO international VALUES (141,'WebGUI',1,'Not Found Page');
INSERT INTO international VALUES (141,'WebGUI',4,'Página no encontrada');
INSERT INTO international VALUES (141,'WebGUI',5,'Página não encontrada');
INSERT INTO international VALUES (74,'WebGUI',2,'Benutzerkonteninformation');
INSERT INTO international VALUES (142,'WebGUI',3,'Sessie time out');
INSERT INTO international VALUES (142,'WebGUI',1,'Session Timeout');
INSERT INTO international VALUES (142,'WebGUI',4,'Timeout de sesión');
INSERT INTO international VALUES (142,'WebGUI',5,'Timeout de sessão');
INSERT INTO international VALUES (73,'WebGUI',2,'Anmelden');
INSERT INTO international VALUES (143,'WebGUI',3,'Beheer instellingen.');
INSERT INTO international VALUES (143,'WebGUI',1,'Manage Settings');
INSERT INTO international VALUES (143,'WebGUI',4,'Configurar Opciones');
INSERT INTO international VALUES (143,'WebGUI',5,'Organizar preferências');
INSERT INTO international VALUES (144,'WebGUI',3,'Bekijk statistieken');
INSERT INTO international VALUES (144,'WebGUI',1,'View statistics.');
INSERT INTO international VALUES (144,'WebGUI',4,'Ver estadísticas');
INSERT INTO international VALUES (144,'WebGUI',5,'Ver estatisticas.');
INSERT INTO international VALUES (145,'WebGUI',3,'WebGUI versie');
INSERT INTO international VALUES (145,'WebGUI',1,'WebGUI Build Version');
INSERT INTO international VALUES (145,'WebGUI',4,'Versión de WebGUI');
INSERT INTO international VALUES (145,'WebGUI',5,'WebGUI versão');
INSERT INTO international VALUES (76,'WebGUI',2,'Ihre Emailadresse\r\nist nicht in unserer Datenbank.');
INSERT INTO international VALUES (146,'WebGUI',3,'Aktieve sessies');
INSERT INTO international VALUES (146,'WebGUI',1,'Active Sessions');
INSERT INTO international VALUES (146,'WebGUI',4,'Sesiones activas');
INSERT INTO international VALUES (146,'WebGUI',5,'Sessões activas');
INSERT INTO international VALUES (147,'WebGUI',3,'Pagina\'s');
INSERT INTO international VALUES (147,'WebGUI',1,'Pages');
INSERT INTO international VALUES (147,'WebGUI',4,'Páginas');
INSERT INTO international VALUES (147,'WebGUI',5,'Páginas');
INSERT INTO international VALUES (148,'WebGUI',3,'Wobjects');
INSERT INTO international VALUES (148,'WebGUI',1,'Wobjects');
INSERT INTO international VALUES (148,'WebGUI',4,'Wobjects');
INSERT INTO international VALUES (148,'WebGUI',5,'Wobjects');
INSERT INTO international VALUES (149,'WebGUI',3,'Gebruikers');
INSERT INTO international VALUES (149,'WebGUI',1,'Users');
INSERT INTO international VALUES (149,'WebGUI',4,'Usuarios');
INSERT INTO international VALUES (149,'WebGUI',5,'Utilizadores');
INSERT INTO international VALUES (151,'WebGUI',3,'Stijl naam');
INSERT INTO international VALUES (151,'WebGUI',1,'Style Name');
INSERT INTO international VALUES (151,'WebGUI',4,'Nombre del Estilo');
INSERT INTO international VALUES (151,'WebGUI',5,'Nome do estilo');
INSERT INTO international VALUES (505,'WebGUI',1,'Add a new template.');
INSERT INTO international VALUES (504,'WebGUI',1,'Template');
INSERT INTO international VALUES (503,'WebGUI',1,'Template ID');
INSERT INTO international VALUES (502,'WebGUI',1,'Are you certain you wish to delete this template and set all pages using this template to the default template?');
INSERT INTO international VALUES (154,'WebGUI',3,'Style sheet');
INSERT INTO international VALUES (154,'WebGUI',1,'Style Sheet');
INSERT INTO international VALUES (154,'WebGUI',4,'Hoja de Estilo');
INSERT INTO international VALUES (154,'WebGUI',5,'Estilo de página');
INSERT INTO international VALUES (77,'WebGUI',2,'Ein anderes\r\nMitglied dieser Seiten benutzt bereits diesen Namen. Bitte wählen Sie einen\r\nanderen Benutzernamen. Hier sind einige Vorschläge:');
INSERT INTO international VALUES (79,'WebGUI',2,'Verbindung zum\r\nLDAP-Server konnte nicht hergestellt werden.');
INSERT INTO international VALUES (155,'WebGUI',3,'Weet u zeker dat u deze stijl wilt verwijderen en migreer alle pagina\'s met de “fail safe” stijl?');
INSERT INTO international VALUES (155,'WebGUI',1,'Are you certain you wish to delete this style and migrate all pages using this style to the \"Fail Safe\" style?');
INSERT INTO international VALUES (155,'WebGUI',4,'\"Está seguro de querer eliminar éste estilo y migrar todas la páginas que lo usen al estilo \"\"Fail Safe\"\"?\"');
INSERT INTO international VALUES (155,'WebGUI',5,'\"Tem a certeza que quer apagar este estilo e migrar todas as páginas para o estilo \"\"Fail Safe\"\"?\"');
INSERT INTO international VALUES (156,'WebGUI',3,'Bewerk stijl');
INSERT INTO international VALUES (156,'WebGUI',1,'Edit Style');
INSERT INTO international VALUES (156,'WebGUI',4,'Editar Estilo');
INSERT INTO international VALUES (156,'WebGUI',5,'Modificar estilo');
INSERT INTO international VALUES (157,'WebGUI',3,'Stijlen');
INSERT INTO international VALUES (157,'WebGUI',1,'Styles');
INSERT INTO international VALUES (157,'WebGUI',4,'Estilos');
INSERT INTO international VALUES (157,'WebGUI',5,'Estilos');
INSERT INTO international VALUES (158,'WebGUI',3,'Een nieuwe stijl toevoegen.');
INSERT INTO international VALUES (158,'WebGUI',1,'Add a new style.');
INSERT INTO international VALUES (158,'WebGUI',4,'Agregar nuevo Estilo');
INSERT INTO international VALUES (158,'WebGUI',5,'Adicionar novo estilo.');
INSERT INTO international VALUES (159,'WebGUI',3,'Berichten log');
INSERT INTO international VALUES (471,'WebGUI',0,'Rediger bruger profil felt');
INSERT INTO international VALUES (159,'WebGUI',4,'Contribuciones Pendientes');
INSERT INTO international VALUES (159,'WebGUI',5,'Log das mensagens');
INSERT INTO international VALUES (160,'WebGUI',3,'Invoer datum');
INSERT INTO international VALUES (160,'WebGUI',1,'Date Submitted');
INSERT INTO international VALUES (160,'WebGUI',4,'Fecha Contribución');
INSERT INTO international VALUES (160,'WebGUI',5,'Data de submissão');
INSERT INTO international VALUES (78,'WebGUI',2,'Die Passworte\r\nunterscheiden sich. Bitte versuchen Sie es noch einmal.');
INSERT INTO international VALUES (161,'WebGUI',3,'Ingevoerd door');
INSERT INTO international VALUES (161,'WebGUI',1,'Submitted By');
INSERT INTO international VALUES (161,'WebGUI',4,'Contribuido por');
INSERT INTO international VALUES (161,'WebGUI',5,'Submetido por');
INSERT INTO international VALUES (162,'WebGUI',3,'Weet u zeker dat u alle pagina\'s en wobjects uit de prullenbak wilt verwijderen?');
INSERT INTO international VALUES (162,'WebGUI',1,'Are you certain that you wish to purge all the pages and wobjects in the trash?');
INSERT INTO international VALUES (162,'WebGUI',4,'Está seguro de querer eliminar todos los elementos de la papelera?');
INSERT INTO international VALUES (162,'WebGUI',5,'Tem a certeza que quer limpar todas as páginas e wobjects para o caixote do lixo?');
INSERT INTO international VALUES (80,'WebGUI',2,'Benutzerkonto\r\nwurde angelegt');
INSERT INTO international VALUES (163,'WebGUI',3,'Gebruiker toevoegen');
INSERT INTO international VALUES (163,'WebGUI',1,'Add User');
INSERT INTO international VALUES (163,'WebGUI',4,'Agregar usuario');
INSERT INTO international VALUES (163,'WebGUI',5,'Adicionar utilizador');
INSERT INTO international VALUES (164,'WebGUI',3,'Toegangs controle methode');
INSERT INTO international VALUES (164,'WebGUI',1,'Authentication Method');
INSERT INTO international VALUES (164,'WebGUI',4,'Método de Auntentificación');
INSERT INTO international VALUES (164,'WebGUI',5,'Metodo de autenticação');
INSERT INTO international VALUES (165,'WebGUI',3,'LDAP URL');
INSERT INTO international VALUES (165,'WebGUI',1,'LDAP URL');
INSERT INTO international VALUES (165,'WebGUI',4,'LDAP URL');
INSERT INTO international VALUES (165,'WebGUI',5,'LDAP URL');
INSERT INTO international VALUES (81,'WebGUI',2,'Benutzerkonto\r\nwurde aktualisiert');
INSERT INTO international VALUES (166,'WebGUI',3,'Verbindt DN');
INSERT INTO international VALUES (166,'WebGUI',1,'Connect DN');
INSERT INTO international VALUES (166,'WebGUI',4,'Connect DN');
INSERT INTO international VALUES (166,'WebGUI',5,'Connectar DN');
INSERT INTO international VALUES (82,'WebGUI',2,'Administrative\r\nFunktionen ...');
INSERT INTO international VALUES (167,'WebGUI',3,'Weet u zeker dat u deze gebruiker wilt verwijderen? Alle gebruikersinformatie wordt permanent verwijdert als u door gaat.');
INSERT INTO international VALUES (167,'WebGUI',1,'Are you certain you want to delete this user? Be warned that all this user\'s information will be lost permanently if you choose to proceed.');
INSERT INTO international VALUES (167,'WebGUI',4,'Está seguro de querer eliminar éste usuario? Tenga en cuenta que toda la información del usuario será eliminada permanentemente si procede.');
INSERT INTO international VALUES (167,'WebGUI',5,'Tem a certeza que quer apagar este utilizador? Se o fizer perde todas as informações do utilizador.');
INSERT INTO international VALUES (168,'WebGUI',3,'Bewerk gebruiker');
INSERT INTO international VALUES (168,'WebGUI',1,'Edit User');
INSERT INTO international VALUES (168,'WebGUI',4,'Editar Usuario');
INSERT INTO international VALUES (168,'WebGUI',5,'Modificar utilizador');
INSERT INTO international VALUES (169,'WebGUI',3,'Een nieuwe gebruiker toevoegen.');
INSERT INTO international VALUES (169,'WebGUI',1,'Add a new user.');
INSERT INTO international VALUES (169,'WebGUI',4,'Agregar nuevo usuario');
INSERT INTO international VALUES (169,'WebGUI',5,'Adicionar utilizador.');
INSERT INTO international VALUES (84,'WebGUI',2,'Gruppenname');
INSERT INTO international VALUES (170,'WebGUI',3,'Zoeken');
INSERT INTO international VALUES (170,'WebGUI',1,'search');
INSERT INTO international VALUES (170,'WebGUI',4,'buscar');
INSERT INTO international VALUES (170,'WebGUI',5,'procurar');
INSERT INTO international VALUES (171,'WebGUI',3,'Rich edit');
INSERT INTO international VALUES (171,'WebGUI',1,'rich edit');
INSERT INTO international VALUES (171,'WebGUI',4,'rich edit');
INSERT INTO international VALUES (171,'WebGUI',5,'rich edit');
INSERT INTO international VALUES (85,'WebGUI',2,'Beschreibung');
INSERT INTO international VALUES (174,'WebGUI',3,'Titel laten zien?');
INSERT INTO international VALUES (174,'WebGUI',1,'Display the title?');
INSERT INTO international VALUES (174,'WebGUI',4,'Mostrar el título?');
INSERT INTO international VALUES (174,'WebGUI',5,'Mostrar o titulo?');
INSERT INTO international VALUES (175,'WebGUI',3,'Macro\'s uitvoeren?');
INSERT INTO international VALUES (175,'WebGUI',1,'Process macros?');
INSERT INTO international VALUES (175,'WebGUI',4,'Procesar macros?');
INSERT INTO international VALUES (175,'WebGUI',5,'Processar macros?');
INSERT INTO international VALUES (228,'WebGUI',3,'Bewerk bericht...');
INSERT INTO international VALUES (228,'WebGUI',1,'Editing Message...');
INSERT INTO international VALUES (228,'WebGUI',4,'Editar Mensage...');
INSERT INTO international VALUES (228,'WebGUI',5,'Modificando mensagem...');
INSERT INTO international VALUES (229,'WebGUI',3,'Onderwerp');
INSERT INTO international VALUES (229,'WebGUI',1,'Subject');
INSERT INTO international VALUES (229,'WebGUI',4,'Asunto');
INSERT INTO international VALUES (229,'WebGUI',5,'Assunto');
INSERT INTO international VALUES (230,'WebGUI',3,'Bericht');
INSERT INTO international VALUES (230,'WebGUI',1,'Message');
INSERT INTO international VALUES (230,'WebGUI',4,'Mensage');
INSERT INTO international VALUES (230,'WebGUI',5,'Mensagem');
INSERT INTO international VALUES (231,'WebGUI',3,'Bezig met bericht posten...');
INSERT INTO international VALUES (231,'WebGUI',1,'Posting New Message...');
INSERT INTO international VALUES (231,'WebGUI',4,'Mandando Nuevo Mensage ...');
INSERT INTO international VALUES (231,'WebGUI',5,'Colocando nova mensagem...');
INSERT INTO international VALUES (232,'WebGUI',3,'Geen onderwerp');
INSERT INTO international VALUES (232,'WebGUI',1,'no subject');
INSERT INTO international VALUES (232,'WebGUI',4,'sin título');
INSERT INTO international VALUES (232,'WebGUI',5,'sem assunto');
INSERT INTO international VALUES (233,'WebGUI',3,'(einde)');
INSERT INTO international VALUES (233,'WebGUI',1,'(eom)');
INSERT INTO international VALUES (233,'WebGUI',4,'(eom)');
INSERT INTO international VALUES (233,'WebGUI',5,'(eom)');
INSERT INTO international VALUES (234,'WebGUI',3,'Bezig met antwoord posten');
INSERT INTO international VALUES (234,'WebGUI',1,'Posting Reply...');
INSERT INTO international VALUES (234,'WebGUI',4,'Respondiendo...');
INSERT INTO international VALUES (234,'WebGUI',5,'Respondendo...');
INSERT INTO international VALUES (86,'WebGUI',2,'Sind Sie sicher,\r\ndass Sie diese Gruppe löschen möchten? Denken Sie daran, dass diese Gruppe\r\nund die zugehörige Rechtesstruktur endgültig gelöscht wird.');
INSERT INTO international VALUES (237,'WebGUI',3,'Onderwerp:');
INSERT INTO international VALUES (237,'WebGUI',1,'Subject:');
INSERT INTO international VALUES (237,'WebGUI',4,'Asunto:');
INSERT INTO international VALUES (237,'WebGUI',5,'Assunto:');
INSERT INTO international VALUES (238,'WebGUI',3,'Naam:');
INSERT INTO international VALUES (238,'WebGUI',1,'Author:');
INSERT INTO international VALUES (238,'WebGUI',4,'Autor:');
INSERT INTO international VALUES (238,'WebGUI',5,'Autor:');
INSERT INTO international VALUES (239,'WebGUI',3,'Datum:');
INSERT INTO international VALUES (239,'WebGUI',1,'Date:');
INSERT INTO international VALUES (239,'WebGUI',4,'Fecha:');
INSERT INTO international VALUES (239,'WebGUI',5,'Data:');
INSERT INTO international VALUES (87,'WebGUI',2,'Gruppe\r\nbearbeiten');
INSERT INTO international VALUES (240,'WebGUI',3,'Bericht ID:');
INSERT INTO international VALUES (240,'WebGUI',1,'Message ID:');
INSERT INTO international VALUES (240,'WebGUI',4,'ID del mensage:');
INSERT INTO international VALUES (240,'WebGUI',5,'ID da mensagem:');
INSERT INTO international VALUES (244,'WebGUI',3,'Afzender');
INSERT INTO international VALUES (244,'WebGUI',1,'Author');
INSERT INTO international VALUES (244,'WebGUI',4,'Autor');
INSERT INTO international VALUES (244,'WebGUI',5,'Autor');
INSERT INTO international VALUES (88,'WebGUI',2,'Benutzer in dieser\r\nGruppe');
INSERT INTO international VALUES (245,'WebGUI',3,'Datum');
INSERT INTO international VALUES (245,'WebGUI',1,'Date');
INSERT INTO international VALUES (245,'WebGUI',4,'Fecha');
INSERT INTO international VALUES (245,'WebGUI',5,'Data');
INSERT INTO international VALUES (304,'WebGUI',3,'Taal');
INSERT INTO international VALUES (304,'WebGUI',1,'Language');
INSERT INTO international VALUES (304,'WebGUI',4,'Idioma');
INSERT INTO international VALUES (304,'WebGUI',5,'Lingua');
INSERT INTO international VALUES (90,'WebGUI',2,'Neue Gruppe\r\nhinzufügen');
INSERT INTO international VALUES (306,'WebGUI',3,'Bind gebruikersnaam');
INSERT INTO international VALUES (306,'WebGUI',1,'Username Binding');
INSERT INTO international VALUES (306,'WebGUI',5,'Ligação ao username');
INSERT INTO international VALUES (307,'WebGUI',3,'Gebruik standaard metag tags?');
INSERT INTO international VALUES (307,'WebGUI',1,'Use default meta tags?');
INSERT INTO international VALUES (307,'WebGUI',5,'Usar as meta tags de defeito?');
INSERT INTO international VALUES (308,'WebGUI',3,'Bewerk profiel instellingen');
INSERT INTO international VALUES (308,'WebGUI',1,'Edit Profile Settings');
INSERT INTO international VALUES (308,'WebGUI',5,'Modificar as preferências do perfil');
INSERT INTO international VALUES (89,'WebGUI',2,'Gruppen');
INSERT INTO international VALUES (309,'WebGUI',3,'Sta echte naam toe?');
INSERT INTO international VALUES (309,'WebGUI',1,'Allow real name?');
INSERT INTO international VALUES (309,'WebGUI',5,'Permitir o nome real?');
INSERT INTO international VALUES (91,'WebGUI',2,'Vorherige Seite');
INSERT INTO international VALUES (310,'WebGUI',3,'Sta extra contact informatie toe?');
INSERT INTO international VALUES (310,'WebGUI',1,'Allow extra contact information?');
INSERT INTO international VALUES (310,'WebGUI',5,'Permitir informação extra de contacto?');
INSERT INTO international VALUES (92,'WebGUI',2,'Nächste Seite');
INSERT INTO international VALUES (311,'WebGUI',3,'Sta thuis informatie toe?');
INSERT INTO international VALUES (311,'WebGUI',1,'Allow home information?');
INSERT INTO international VALUES (311,'WebGUI',5,'Permitir informação de casa?');
INSERT INTO international VALUES (95,'WebGUI',2,'Hilfe');
INSERT INTO international VALUES (312,'WebGUI',3,'Sta bedrijfs informatie toe?');
INSERT INTO international VALUES (312,'WebGUI',1,'Allow business information?');
INSERT INTO international VALUES (312,'WebGUI',5,'Permitir informação do emprego?');
INSERT INTO international VALUES (94,'WebGUI',2,'Siehe auch');
INSERT INTO international VALUES (313,'WebGUI',3,'Sta andere informatie toe?');
INSERT INTO international VALUES (313,'WebGUI',1,'Allow miscellaneous information?');
INSERT INTO international VALUES (313,'WebGUI',5,'Permitir informaçao mista?');
INSERT INTO international VALUES (93,'WebGUI',2,'Hilfe');
INSERT INTO international VALUES (314,'WebGUI',3,'Voornaam');
INSERT INTO international VALUES (314,'WebGUI',1,'First Name');
INSERT INTO international VALUES (314,'WebGUI',5,'Nome');
INSERT INTO international VALUES (315,'WebGUI',3,'Tussenvoegsel');
INSERT INTO international VALUES (315,'WebGUI',1,'Middle Name');
INSERT INTO international VALUES (315,'WebGUI',5,'segundo(s) nome(s)');
INSERT INTO international VALUES (316,'WebGUI',3,'Achternaam');
INSERT INTO international VALUES (316,'WebGUI',1,'Last Name');
INSERT INTO international VALUES (316,'WebGUI',5,'Apelido');
INSERT INTO international VALUES (317,'WebGUI',3,'\"<a href=\"\"http://www.icq.com\"\">ICQ</a> UIN\"');
INSERT INTO international VALUES (317,'WebGUI',1,'<a href=\"http://www.icq.com\">ICQ</a> UIN');
INSERT INTO international VALUES (317,'WebGUI',5,'\"<a href=\"\"http://www.icq.com\"\">ICQ</a> UIN\"');
INSERT INTO international VALUES (318,'WebGUI',3,'\"<a href=\"\"http://www.aol.com/aim/homenew.adp\"\">AIM</a> Id\"');
INSERT INTO international VALUES (318,'WebGUI',1,'<a href=\"http://www.aol.com/aim/homenew.adp\">AIM</a> Id');
INSERT INTO international VALUES (318,'WebGUI',5,'\"<a href=\"\"http://www.aol.com/aim/homenew.adp\"\">AIM</a> Id\"');
INSERT INTO international VALUES (99,'WebGUI',2,'Titel');
INSERT INTO international VALUES (566,'WebGUI',6,'Redigera Timeout');
INSERT INTO international VALUES (319,'WebGUI',3,'\"<a href=\"\"http://messenger.msn.com/\"\">MSN Messenger</a> Id\"');
INSERT INTO international VALUES (319,'WebGUI',1,'<a href=\"http://messenger.msn.com/\">MSN Messenger</a> Id');
INSERT INTO international VALUES (319,'WebGUI',5,'\"<a href=\"\"http://messenger.msn.com/\"\">MSN Messenger</a> Id\"');
INSERT INTO international VALUES (320,'WebGUI',3,'\"<a href=\"\"http://messenger.yahoo.com/\"\">Yahoo! Messenger</a> Id\"');
INSERT INTO international VALUES (320,'WebGUI',1,'<a href=\"http://messenger.yahoo.com/\">Yahoo! Messenger</a> Id');
INSERT INTO international VALUES (320,'WebGUI',5,'\"<a href=\"\"http://messenger.yahoo.com/\"\">Yahoo! Messenger</a> Id\"');
INSERT INTO international VALUES (321,'WebGUI',3,'Mobiel nummer');
INSERT INTO international VALUES (321,'WebGUI',1,'Cell Phone');
INSERT INTO international VALUES (321,'WebGUI',5,'Telemóvel');
INSERT INTO international VALUES (322,'WebGUI',3,'Pager');
INSERT INTO international VALUES (322,'WebGUI',1,'Pager');
INSERT INTO international VALUES (322,'WebGUI',5,'Pager');
INSERT INTO international VALUES (323,'WebGUI',3,'Thuis adres');
INSERT INTO international VALUES (323,'WebGUI',1,'Home Address');
INSERT INTO international VALUES (323,'WebGUI',5,'Morada (de casa)');
INSERT INTO international VALUES (101,'WebGUI',2,'Sind Sie sicher,\r\ndass Sie diese Seite und ihren kompletten Inhalt darunter löschen\r\nmöchten?');
INSERT INTO international VALUES (324,'WebGUI',3,'Thuis plaats');
INSERT INTO international VALUES (324,'WebGUI',1,'Home City');
INSERT INTO international VALUES (324,'WebGUI',5,'Cidade (de casa)');
INSERT INTO international VALUES (100,'WebGUI',2,'Meta Tags');
INSERT INTO international VALUES (325,'WebGUI',3,'Thuis staat');
INSERT INTO international VALUES (325,'WebGUI',1,'Home State');
INSERT INTO international VALUES (325,'WebGUI',5,'Concelho (de casa)');
INSERT INTO international VALUES (326,'WebGUI',3,'Thuis postcode');
INSERT INTO international VALUES (326,'WebGUI',1,'Home Zip Code');
INSERT INTO international VALUES (326,'WebGUI',5,'Código postal (de casa)');
INSERT INTO international VALUES (327,'WebGUI',3,'Thuis land');
INSERT INTO international VALUES (327,'WebGUI',1,'Home Country');
INSERT INTO international VALUES (327,'WebGUI',5,'País (de casa)');
INSERT INTO international VALUES (102,'WebGUI',2,'Seite\r\nbearbeiten');
INSERT INTO international VALUES (328,'WebGUI',3,'Thuis telefoon');
INSERT INTO international VALUES (328,'WebGUI',1,'Home Phone');
INSERT INTO international VALUES (328,'WebGUI',5,'Telefone (de casa)');
INSERT INTO international VALUES (329,'WebGUI',3,'Werk adres');
INSERT INTO international VALUES (329,'WebGUI',1,'Work Address');
INSERT INTO international VALUES (329,'WebGUI',5,'Morada (do emprego)');
INSERT INTO international VALUES (103,'WebGUI',2,'Seitenspezifikation');
INSERT INTO international VALUES (330,'WebGUI',3,'Werk stad');
INSERT INTO international VALUES (330,'WebGUI',1,'Work City');
INSERT INTO international VALUES (330,'WebGUI',5,'Cidade (do emprego)');
INSERT INTO international VALUES (331,'WebGUI',3,'Werk staat');
INSERT INTO international VALUES (331,'WebGUI',1,'Work State');
INSERT INTO international VALUES (331,'WebGUI',5,'Concelho (do emprego)');
INSERT INTO international VALUES (104,'WebGUI',2,'URL der Seite');
INSERT INTO international VALUES (332,'WebGUI',3,'Werk postcode');
INSERT INTO international VALUES (332,'WebGUI',1,'Work Zip Code');
INSERT INTO international VALUES (332,'WebGUI',5,'Código postal (do emprego)');
INSERT INTO international VALUES (333,'WebGUI',3,'Werk land');
INSERT INTO international VALUES (333,'WebGUI',1,'Work Country');
INSERT INTO international VALUES (333,'WebGUI',5,'País (do emprego)');
INSERT INTO international VALUES (334,'WebGUI',3,'Werk telefoon');
INSERT INTO international VALUES (334,'WebGUI',1,'Work Phone');
INSERT INTO international VALUES (334,'WebGUI',5,'Telefone (do emprego)');
INSERT INTO international VALUES (335,'WebGUI',3,'Sexe');
INSERT INTO international VALUES (335,'WebGUI',1,'Gender');
INSERT INTO international VALUES (335,'WebGUI',5,'Sexo');
INSERT INTO international VALUES (106,'WebGUI',2,'Stil an alle\r\nnachfolgenden Seiten weitergeben.');
INSERT INTO international VALUES (336,'WebGUI',3,'Geboortedatum');
INSERT INTO international VALUES (336,'WebGUI',1,'Birth Date');
INSERT INTO international VALUES (336,'WebGUI',5,'Data de nascimento');
INSERT INTO international VALUES (337,'WebGUI',3,'Home pagina URL');
INSERT INTO international VALUES (337,'WebGUI',1,'Homepage URL');
INSERT INTO international VALUES (337,'WebGUI',5,'Endereço da Homepage');
INSERT INTO international VALUES (338,'WebGUI',3,'Bewerk profiel');
INSERT INTO international VALUES (338,'WebGUI',1,'Edit Profile');
INSERT INTO international VALUES (338,'WebGUI',5,'Modificar perfil');
INSERT INTO international VALUES (105,'WebGUI',2,'Stil');
INSERT INTO international VALUES (339,'WebGUI',3,'Man');
INSERT INTO international VALUES (339,'WebGUI',1,'Male');
INSERT INTO international VALUES (339,'WebGUI',5,'Masculino');
INSERT INTO international VALUES (107,'WebGUI',2,'Rechte');
INSERT INTO international VALUES (340,'WebGUI',3,'Vrouw');
INSERT INTO international VALUES (340,'WebGUI',1,'Female');
INSERT INTO international VALUES (340,'WebGUI',5,'Feminino');
INSERT INTO international VALUES (341,'WebGUI',3,'Bewerk profiel.');
INSERT INTO international VALUES (341,'WebGUI',1,'Edit profile.');
INSERT INTO international VALUES (341,'WebGUI',5,'Modificar o perfil.');
INSERT INTO international VALUES (109,'WebGUI',2,'Besitzer kann\r\nanschauen?');
INSERT INTO international VALUES (342,'WebGUI',3,'Bewerk account informatie.');
INSERT INTO international VALUES (342,'WebGUI',1,'Edit account information.');
INSERT INTO international VALUES (342,'WebGUI',5,'Modificar as informações da conta.');
INSERT INTO international VALUES (108,'WebGUI',2,'Besitzer');
INSERT INTO international VALUES (343,'WebGUI',3,'Bekijk profiel.');
INSERT INTO international VALUES (343,'WebGUI',1,'View profile.');
INSERT INTO international VALUES (343,'WebGUI',5,'Ver perfil.');
INSERT INTO international VALUES (351,'WebGUI',1,'Message');
INSERT INTO international VALUES (468,'WebGUI',0,'Rediger bruger profil kategori');
INSERT INTO international VALUES (345,'WebGUI',3,'Geen lid');
INSERT INTO international VALUES (345,'WebGUI',1,'Not A Member');
INSERT INTO international VALUES (345,'WebGUI',5,'Não é membro');
INSERT INTO international VALUES (112,'WebGUI',2,'Gruppe kann\r\nanschauen?');
INSERT INTO international VALUES (110,'WebGUI',2,'Besitzer kann\r\nbearbeiten?');
INSERT INTO international VALUES (346,'WebGUI',3,'Deze gebruiker in geen lid meer van onze site. We hebben geen informatie meer over deze gebruiker.');
INSERT INTO international VALUES (346,'WebGUI',1,'This user is no longer a member of our site. We have no further information about this user.');
INSERT INTO international VALUES (346,'WebGUI',5,'Esse utilizador já não é membro do site. Não existe mais informação.');
INSERT INTO international VALUES (111,'WebGUI',2,'Gruppe');
INSERT INTO international VALUES (347,'WebGUI',3,'Bekijk profiel van');
INSERT INTO international VALUES (347,'WebGUI',1,'View Profile For');
INSERT INTO international VALUES (347,'WebGUI',5,'Ver o perfil de');
INSERT INTO international VALUES (348,'WebGUI',3,'Naam');
INSERT INTO international VALUES (348,'WebGUI',1,'Name');
INSERT INTO international VALUES (348,'WebGUI',5,'Nome');
INSERT INTO international VALUES (349,'WebGUI',3,'Laatst beschikbare versie');
INSERT INTO international VALUES (349,'WebGUI',1,'Latest version available');
INSERT INTO international VALUES (349,'WebGUI',5,'Ultima versão disponível');
INSERT INTO international VALUES (350,'WebGUI',3,'Klaar');
INSERT INTO international VALUES (350,'WebGUI',1,'Completed');
INSERT INTO international VALUES (350,'WebGUI',5,'Completo');
INSERT INTO international VALUES (351,'WebGUI',3,'Bericht');
INSERT INTO international VALUES (351,'WebGUI',5,'Entrada no log de mensagens');
INSERT INTO international VALUES (352,'WebGUI',3,'Datum van toevoeging');
INSERT INTO international VALUES (352,'WebGUI',1,'Date Of Entry');
INSERT INTO international VALUES (352,'WebGUI',5,'Data de entrada');
INSERT INTO international VALUES (353,'WebGUI',3,'U heeft nu geen berichten log toevoegingen.');
INSERT INTO international VALUES (471,'WebGUI',6,'Redigera Användar Profil Attribut');
INSERT INTO international VALUES (353,'WebGUI',5,'Actualmente não tem entradas no log de mensagens.');
INSERT INTO international VALUES (354,'WebGUI',3,'Bekijk berichten log.');
INSERT INTO international VALUES (471,'WebGUI',1,'Edit User Profile Field');
INSERT INTO international VALUES (354,'WebGUI',5,'Ver o log das mensagens.');
INSERT INTO international VALUES (355,'WebGUI',3,'Standaard');
INSERT INTO international VALUES (355,'WebGUI',1,'Default');
INSERT INTO international VALUES (355,'WebGUI',5,'Por defeito');
INSERT INTO international VALUES (356,'WebGUI',1,'Template');
INSERT INTO international VALUES (357,'WebGUI',1,'News');
INSERT INTO international VALUES (358,'WebGUI',1,'Left Column');
INSERT INTO international VALUES (359,'WebGUI',1,'Right Column');
INSERT INTO international VALUES (360,'WebGUI',1,'One Over Three');
INSERT INTO international VALUES (361,'WebGUI',1,'Three Over One');
INSERT INTO international VALUES (362,'WebGUI',1,'SideBySide');
INSERT INTO international VALUES (363,'WebGUI',1,'Template Position');
INSERT INTO international VALUES (364,'WebGUI',1,'Search');
INSERT INTO international VALUES (365,'WebGUI',1,'Search results...');
INSERT INTO international VALUES (366,'WebGUI',1,'No  pages were found with content that matched your query.');
INSERT INTO international VALUES (368,'WebGUI',1,'Add a new group to this user.');
INSERT INTO international VALUES (369,'WebGUI',1,'Expire Date');
INSERT INTO international VALUES (370,'WebGUI',1,'Edit Grouping');
INSERT INTO international VALUES (371,'WebGUI',1,'Add Grouping');
INSERT INTO international VALUES (372,'WebGUI',1,'Edit User\'s Groups');
INSERT INTO international VALUES (374,'WebGUI',1,'Manage packages.');
INSERT INTO international VALUES (375,'WebGUI',1,'Select Package To Deploy');
INSERT INTO international VALUES (376,'WebGUI',1,'Package');
INSERT INTO international VALUES (377,'WebGUI',1,'No packages have been defined by your package manager(s) or administrator(s).');
INSERT INTO international VALUES (11,'Poll',1,'Vote!');
INSERT INTO international VALUES (31,'UserSubmission',1,'Content');
INSERT INTO international VALUES (32,'UserSubmission',1,'Image');
INSERT INTO international VALUES (33,'UserSubmission',1,'Attachment');
INSERT INTO international VALUES (34,'UserSubmission',1,'Convert Carriage Returns');
INSERT INTO international VALUES (35,'UserSubmission',1,'Title');
INSERT INTO international VALUES (21,'EventsCalendar',1,'Proceed to add event?');
INSERT INTO international VALUES (378,'WebGUI',1,'User ID');
INSERT INTO international VALUES (379,'WebGUI',1,'Group ID');
INSERT INTO international VALUES (380,'WebGUI',1,'Style ID');
INSERT INTO international VALUES (381,'WebGUI',1,'WebGUI received a malformed request and was unable to continue. Proprietary characters being passed through a form typically cause this. Please feel free to hit your back button and try again.');
INSERT INTO international VALUES (1,'DownloadManager',1,'Download Manager');
INSERT INTO international VALUES (1,'EventsCalendar',6,'Fortsätt med att lägga till en händelse?');
INSERT INTO international VALUES (3,'DownloadManager',1,'Proceed to add file?');
INSERT INTO international VALUES (367,'WebGUI',6,'Bäst före');
INSERT INTO international VALUES (5,'DownloadManager',1,'File Title');
INSERT INTO international VALUES (6,'DownloadManager',1,'Download File');
INSERT INTO international VALUES (7,'DownloadManager',1,'Group to Download');
INSERT INTO international VALUES (8,'DownloadManager',1,'Brief Synopsis');
INSERT INTO international VALUES (9,'DownloadManager',1,'Edit Download Manager');
INSERT INTO international VALUES (10,'DownloadManager',1,'Edit Download');
INSERT INTO international VALUES (11,'DownloadManager',1,'Add a new download.');
INSERT INTO international VALUES (12,'DownloadManager',1,'Are you certain that you wish to delete this download?');
INSERT INTO international VALUES (22,'DownloadManager',1,'Proceed to add download?');
INSERT INTO international VALUES (14,'DownloadManager',1,'File');
INSERT INTO international VALUES (15,'DownloadManager',1,'Description');
INSERT INTO international VALUES (16,'DownloadManager',1,'Date Uploaded');
INSERT INTO international VALUES (15,'Article',1,'Right');
INSERT INTO international VALUES (16,'Article',1,'Left');
INSERT INTO international VALUES (17,'Article',1,'Center');
INSERT INTO international VALUES (37,'UserSubmission',1,'Delete');
INSERT INTO international VALUES (13,'SQLReport',1,'Convert carriage returns?');
INSERT INTO international VALUES (17,'DownloadManager',1,'Alternate Version #1');
INSERT INTO international VALUES (18,'DownloadManager',1,'Alternate Version #2');
INSERT INTO international VALUES (19,'DownloadManager',1,'You have no files available for download.');
INSERT INTO international VALUES (14,'EventsCalendar',1,'Start Date');
INSERT INTO international VALUES (15,'EventsCalendar',1,'End Date');
INSERT INTO international VALUES (20,'DownloadManager',1,'Paginate After');
INSERT INTO international VALUES (14,'SQLReport',1,'Paginate After');
INSERT INTO international VALUES (16,'EventsCalendar',1,'Calendar Layout');
INSERT INTO international VALUES (17,'EventsCalendar',1,'List');
INSERT INTO international VALUES (18,'EventsCalendar',1,'Calendar Month');
INSERT INTO international VALUES (19,'EventsCalendar',1,'Paginate After');
INSERT INTO international VALUES (383,'WebGUI',1,'Name');
INSERT INTO international VALUES (384,'WebGUI',1,'File');
INSERT INTO international VALUES (385,'WebGUI',1,'Parameters');
INSERT INTO international VALUES (386,'WebGUI',1,'Edit Image');
INSERT INTO international VALUES (387,'WebGUI',1,'Uploaded By');
INSERT INTO international VALUES (388,'WebGUI',1,'Upload Date');
INSERT INTO international VALUES (389,'WebGUI',1,'Image Id');
INSERT INTO international VALUES (390,'WebGUI',1,'Displaying Image...');
INSERT INTO international VALUES (391,'WebGUI',1,'Delete attached file.');
INSERT INTO international VALUES (392,'WebGUI',1,'Are you certain that you wish to delete this image?');
INSERT INTO international VALUES (393,'WebGUI',1,'Manage Images');
INSERT INTO international VALUES (394,'WebGUI',1,'Manage images.');
INSERT INTO international VALUES (395,'WebGUI',1,'Add a new image.');
INSERT INTO international VALUES (396,'WebGUI',1,'View Image');
INSERT INTO international VALUES (397,'WebGUI',1,'Back to image list.');
INSERT INTO international VALUES (398,'WebGUI',1,'Document Type Declaration');
INSERT INTO international VALUES (399,'WebGUI',1,'Validate this page.');
INSERT INTO international VALUES (400,'WebGUI',1,'Prevent Proxy Caching');
INSERT INTO international VALUES (401,'WebGUI',1,'Are you certain you wish to delete this message and all messages under it in this thread?');
INSERT INTO international VALUES (565,'WebGUI',1,'Who can moderate?');
INSERT INTO international VALUES (22,'MessageBoard',1,'Delete Message');
INSERT INTO international VALUES (402,'WebGUI',1,'The message you requested does not exist.');
INSERT INTO international VALUES (403,'WebGUI',1,'Prefer not to say.');
INSERT INTO international VALUES (405,'WebGUI',1,'Last Page');
INSERT INTO international VALUES (406,'WebGUI',1,'Thumbnail Size');
INSERT INTO international VALUES (21,'DownloadManager',1,'Display thumbnails?');
INSERT INTO international VALUES (407,'WebGUI',1,'Click here to register.');
INSERT INTO international VALUES (15,'SQLReport',1,'Preprocess macros on query?');
INSERT INTO international VALUES (16,'SQLReport',1,'Debug?');
INSERT INTO international VALUES (17,'SQLReport',1,'<b>Debug:</b> Query:');
INSERT INTO international VALUES (18,'SQLReport',1,'There were no results for this query.');
INSERT INTO international VALUES (113,'WebGUI',2,'Gruppe kann\r\nbearbeiten?');
INSERT INTO international VALUES (114,'WebGUI',2,'Kann jeder\r\nanschauen?');
INSERT INTO international VALUES (116,'WebGUI',2,'Rechte an alle\r\nnachfolgenden Seiten weitergeben.');
INSERT INTO international VALUES (115,'WebGUI',2,'Kann jeder\r\nbearbeiten?');
INSERT INTO international VALUES (118,'WebGUI',2,'anonyme\r\nRegistrierung');
INSERT INTO international VALUES (117,'WebGUI',2,'Authentifizierungseinstellungen bearbeiten');
INSERT INTO international VALUES (120,'WebGUI',2,'LDAP URL\r\n(Standard)');
INSERT INTO international VALUES (119,'WebGUI',2,'Authentifizierungsmethode (Standard)');
INSERT INTO international VALUES (121,'WebGUI',2,'LDAP Identität\r\n(Standard)');
INSERT INTO international VALUES (123,'WebGUI',2,'LDAP Passwort\r\nName');
INSERT INTO international VALUES (122,'WebGUI',2,'LDAP\r\nIdentitäts-Name');
INSERT INTO international VALUES (124,'WebGUI',2,'Firmeninformationen bearbeiten');
INSERT INTO international VALUES (127,'WebGUI',2,'Webseite der\r\nFirma');
INSERT INTO international VALUES (126,'WebGUI',2,'Emailadresse der\r\nFirma');
INSERT INTO international VALUES (125,'WebGUI',2,'Firmenname');
INSERT INTO international VALUES (130,'WebGUI',2,'Maximale\r\nDateigröße für Anhänge');
INSERT INTO international VALUES (133,'WebGUI',2,'Maileinstellungen\r\nbearbeiten');
INSERT INTO international VALUES (134,'WebGUI',2,'Passwortmeldung\r\nwiederherstellen');
INSERT INTO international VALUES (135,'WebGUI',2,'SMTP Server');
INSERT INTO international VALUES (138,'WebGUI',2,'Ja');
INSERT INTO international VALUES (139,'WebGUI',2,'Nein');
INSERT INTO international VALUES (143,'WebGUI',2,'Einstellungen\r\nverwalten');
INSERT INTO international VALUES (142,'WebGUI',2,'Sitzungs\r\nZeitüberschreitung');
INSERT INTO international VALUES (141,'WebGUI',2,'\"Nicht gefunden\r\nSeite\"');
INSERT INTO international VALUES (140,'WebGUI',2,'Sonstige\r\nEinstellungen bearbeiten');
INSERT INTO international VALUES (144,'WebGUI',2,'Auswertungen\r\nanschauen');
INSERT INTO international VALUES (145,'WebGUI',2,'WebGUI Build\r\nVersion');
INSERT INTO international VALUES (147,'WebGUI',2,'sichtbare\r\nSeiten');
INSERT INTO international VALUES (146,'WebGUI',2,'Aktive\r\nSitzungen');
INSERT INTO international VALUES (148,'WebGUI',2,'Wobjects');
INSERT INTO international VALUES (149,'WebGUI',2,'Benutzer');
INSERT INTO international VALUES (506,'WebGUI',1,'Manage Templates');
INSERT INTO international VALUES (151,'WebGUI',2,'Stil Name');
INSERT INTO international VALUES (154,'WebGUI',2,'Style Sheet');
INSERT INTO international VALUES (155,'WebGUI',2,'Sind Sie sicher,\r\ndass Sie diesen Stil löschen und alle Seiten die diesen Stil benutzen in\r\nden Stil \"Fail Safe\" überführen wollen?');
INSERT INTO international VALUES (156,'WebGUI',2,'Stil\r\nbearbeiten');
INSERT INTO international VALUES (157,'WebGUI',2,'Stile');
INSERT INTO international VALUES (159,'WebGUI',2,'Ausstehende\r\nBeiträge');
INSERT INTO international VALUES (158,'WebGUI',2,'Neuen Stil\r\nhinzufügen');
INSERT INTO international VALUES (161,'WebGUI',2,'Erstellt von');
INSERT INTO international VALUES (160,'WebGUI',2,'Erstellungsdatum');
INSERT INTO international VALUES (162,'WebGUI',2,'Sind Sie sicher,\r\ndass Sie alle Seiten und Wobjects im Mülleimer löschen möchten?');
INSERT INTO international VALUES (163,'WebGUI',2,'Benutzer\r\nhinzufügen');
INSERT INTO international VALUES (164,'WebGUI',2,'Authentifizierungsmethode');
INSERT INTO international VALUES (165,'WebGUI',2,'LDAP URL');
INSERT INTO international VALUES (166,'WebGUI',2,'Connect DN');
INSERT INTO international VALUES (167,'WebGUI',2,'Sind Sie sicher,\r\ndass sie diesen Benutzer löschen möchten? Die Benutzerinformation geht\r\ndamit endgültig verloren!');
INSERT INTO international VALUES (168,'WebGUI',2,'Benutzer\r\nbearbeiten');
INSERT INTO international VALUES (174,'WebGUI',2,'Titel\r\nanzeigen?');
INSERT INTO international VALUES (170,'WebGUI',2,'suchen');
INSERT INTO international VALUES (171,'WebGUI',2,'Bearbeiten mit\r\nAttributen');
INSERT INTO international VALUES (169,'WebGUI',2,'Neuen Benutzer\r\nhinzufügen');
INSERT INTO international VALUES (228,'WebGUI',2,'Beiträge\r\nbearbeiten ...');
INSERT INTO international VALUES (175,'WebGUI',2,'Makros\r\nausführen?');
INSERT INTO international VALUES (232,'WebGUI',2,'kein Betreff');
INSERT INTO international VALUES (229,'WebGUI',2,'Betreff');
INSERT INTO international VALUES (230,'WebGUI',2,'Beitrag');
INSERT INTO international VALUES (238,'WebGUI',2,'Autor:');
INSERT INTO international VALUES (231,'WebGUI',2,'Neuen Beitrag\r\nschreiben...');
INSERT INTO international VALUES (237,'WebGUI',2,'Betreff:');
INSERT INTO international VALUES (234,'WebGUI',2,'Antworten...');
INSERT INTO international VALUES (233,'WebGUI',2,'(eom)');
INSERT INTO international VALUES (304,'WebGUI',2,'Sprache');
INSERT INTO international VALUES (245,'WebGUI',2,'Datum');
INSERT INTO international VALUES (240,'WebGUI',2,'Beitrags ID:');
INSERT INTO international VALUES (244,'WebGUI',2,'Autor');
INSERT INTO international VALUES (239,'WebGUI',2,'Datum:');
INSERT INTO international VALUES (306,'WebGUI',2,'Benutze LDAP\r\nBenutzername');
INSERT INTO international VALUES (308,'WebGUI',2,'Profil\r\nbearbeiten');
INSERT INTO international VALUES (307,'WebGUI',2,'Standard Meta\r\nTags benutzen?');
INSERT INTO international VALUES (310,'WebGUI',2,'Kontaktinformationen anzeigen?');
INSERT INTO international VALUES (309,'WebGUI',2,'Name anzeigen?');
INSERT INTO international VALUES (311,'WebGUI',2,'Privatadresse\r\nanzeigen?');
INSERT INTO international VALUES (312,'WebGUI',2,'Geschäftsadresse\r\nanzeigen?');
INSERT INTO international VALUES (313,'WebGUI',2,'Zusätzliche\r\nInformationen anzeigen?');
INSERT INTO international VALUES (315,'WebGUI',2,'Zweiter\r\nVorname');
INSERT INTO international VALUES (314,'WebGUI',2,'Vorname');
INSERT INTO international VALUES (316,'WebGUI',2,'Nachname');
INSERT INTO international VALUES (318,'WebGUI',2,'<a href=\"\"\r\nhttp://www.aol.com/aim/homenew.adp\"\">AIM</a> Id');
INSERT INTO international VALUES (317,'WebGUI',2,'<a href=\"\"\r\nhttp://www.icq.com\"\">ICQ</a> UIN');
INSERT INTO international VALUES (319,'WebGUI',2,'<a href=\"\"\r\nhttp://messenger.msn.com/\"\">MSN Messenger</a> Id');
INSERT INTO international VALUES (320,'WebGUI',2,'<a href=\"\"\r\nhttp://messenger.yahoo.com/\"\">Yahoo! Messenger</a> Id');
INSERT INTO international VALUES (322,'WebGUI',2,'Pager');
INSERT INTO international VALUES (321,'WebGUI',2,'Mobiltelefon');
INSERT INTO international VALUES (324,'WebGUI',2,'Ort (privat)');
INSERT INTO international VALUES (323,'WebGUI',2,'Strasse\r\n(privat)');
INSERT INTO international VALUES (325,'WebGUI',2,'Bundesland\r\n(privat)');
INSERT INTO international VALUES (329,'WebGUI',2,'Strasse (Büro)');
INSERT INTO international VALUES (328,'WebGUI',2,'Telefon\r\n(privat)');
INSERT INTO international VALUES (327,'WebGUI',2,'Land (privat)');
INSERT INTO international VALUES (326,'WebGUI',2,'Postleitzahl\r\n(privat)');
INSERT INTO international VALUES (332,'WebGUI',2,'Postleitzahl\r\n(Büro)');
INSERT INTO international VALUES (330,'WebGUI',2,'Ort (Büro)');
INSERT INTO international VALUES (331,'WebGUI',2,'Bundesland\r\n(Büro)');
INSERT INTO international VALUES (333,'WebGUI',2,'Land (Büro)');
INSERT INTO international VALUES (335,'WebGUI',2,'Geschlecht');
INSERT INTO international VALUES (334,'WebGUI',2,'Telefon (Büro)');
INSERT INTO international VALUES (336,'WebGUI',2,'Geburtstag');
INSERT INTO international VALUES (337,'WebGUI',2,'Homepage URL');
INSERT INTO international VALUES (339,'WebGUI',2,'männlich');
INSERT INTO international VALUES (338,'WebGUI',2,'Profil\r\nbearbeiten');
INSERT INTO international VALUES (343,'WebGUI',2,'Profil\r\nanschauen.');
INSERT INTO international VALUES (353,'WebGUI',1,'You have no messages in your Inbox at this time.');
INSERT INTO international VALUES (342,'WebGUI',2,'Benutzerkonto\r\nbearbeiten.');
INSERT INTO international VALUES (341,'WebGUI',2,'Profil\r\nbearbeiten.');
INSERT INTO international VALUES (340,'WebGUI',2,'weiblich');
INSERT INTO international VALUES (345,'WebGUI',2,'Kein Mitglied');
INSERT INTO international VALUES (346,'WebGUI',2,'Dieser Benutzer\r\nist kein Mitglied. Wir haben keine weiteren Informationen über ihn.');
INSERT INTO international VALUES (347,'WebGUI',2,'Profil anschauen\r\nvon');
INSERT INTO international VALUES (349,'WebGUI',2,'Aktuelle\r\nVersion');
INSERT INTO international VALUES (348,'WebGUI',2,'Name');
INSERT INTO international VALUES (352,'WebGUI',2,'Beitragsdatum');
INSERT INTO international VALUES (351,'WebGUI',2,'Beitragseingang');
INSERT INTO international VALUES (350,'WebGUI',2,'Abgeschlossen');
INSERT INTO international VALUES (353,'WebGUI',2,'Zur Zeit sind\r\nkeine ausstehenden Beiträge vorhanden.');
INSERT INTO international VALUES (355,'WebGUI',2,'Standard');
INSERT INTO international VALUES (356,'WebGUI',2,'Vorlage');
INSERT INTO international VALUES (354,'WebGUI',2,'Beitrags Log\r\nanschauen.');
INSERT INTO international VALUES (359,'WebGUI',2,'Rechte Spalte');
INSERT INTO international VALUES (360,'WebGUI',2,'Einer über\r\ndrei');
INSERT INTO international VALUES (357,'WebGUI',2,'Nachrichten');
INSERT INTO international VALUES (358,'WebGUI',2,'Linke Spalte');
INSERT INTO international VALUES (361,'WebGUI',2,'Drei über\r\neinem');
INSERT INTO international VALUES (362,'WebGUI',2,'Nebeneinander');
INSERT INTO international VALUES (364,'WebGUI',2,'Suchen');
INSERT INTO international VALUES (363,'WebGUI',2,'Position des\r\nTemplates');
INSERT INTO international VALUES (365,'WebGUI',2,'Ergebnisse der\r\nAbfrage');
INSERT INTO international VALUES (366,'WebGUI',2,'Es wurden keine\r\nSeiten gefunden, die zu Ihrer Abfrage passen.');
INSERT INTO international VALUES (367,'WebGUI',2,'verfällt nach');
INSERT INTO international VALUES (370,'WebGUI',2,'Gruppierung\r\nbearbeiten');
INSERT INTO international VALUES (369,'WebGUI',2,'Verfallsdatum');
INSERT INTO international VALUES (368,'WebGUI',2,'Diesem Benutzer\r\neine neue Gruppe hinzufügen.');
INSERT INTO international VALUES (371,'WebGUI',2,'Gruppierung\r\nhinzufügen');
INSERT INTO international VALUES (372,'WebGUI',2,'Gruppen eines\r\nBenutzers bearbeiten');
INSERT INTO international VALUES (374,'WebGUI',2,'Pakete\r\nanschauen');
INSERT INTO international VALUES (375,'WebGUI',2,'Paket auswählen,\r\ndas verteilt werden soll');
INSERT INTO international VALUES (377,'WebGUI',2,'Von Ihren (Paket)\r\n-Administratoren wurden keine Pakete bereitgestellt.');
INSERT INTO international VALUES (376,'WebGUI',2,'Paket');
INSERT INTO international VALUES (378,'WebGUI',2,'Benutzer ID');
INSERT INTO international VALUES (381,'WebGUI',2,'WebGUI hat eine\r\nverstümmelte Anfrage erhalten und kann nicht weitermachen. Üblicherweise\r\nwird das durch Sonderzeichen verursacht. Nutzen Sie bitte den \"Zurück\"\r\nButton Ihres Browsers und versuchen Sie es noch einmal.');
INSERT INTO international VALUES (380,'WebGUI',2,'Stil ID');
INSERT INTO international VALUES (379,'WebGUI',2,'Gruppen ID');
INSERT INTO international VALUES (383,'WebGUI',2,'Name');
INSERT INTO international VALUES (384,'WebGUI',2,'Datei');
INSERT INTO international VALUES (386,'WebGUI',2,'Bild\r\nbearbeiten');
INSERT INTO international VALUES (385,'WebGUI',2,'Parameter');
INSERT INTO international VALUES (387,'WebGUI',2,'Zur Verfügung\r\ngestellt von');
INSERT INTO international VALUES (388,'WebGUI',2,'Upload Datum');
INSERT INTO international VALUES (389,'WebGUI',2,'Grafik Id');
INSERT INTO international VALUES (390,'WebGUI',2,'Grafik anzeigen\r\n...');
INSERT INTO international VALUES (391,'WebGUI',2,'Anhang löschen');
INSERT INTO international VALUES (393,'WebGUI',2,'Grafiken\r\nverwalten');
INSERT INTO international VALUES (392,'WebGUI',2,'Sind Sie sicher,\r\ndass Sie diese Grafik löschen wollen?');
INSERT INTO international VALUES (394,'WebGUI',2,'Grafiken\r\nverwalten');
INSERT INTO international VALUES (408,'WebGUI',1,'Manage Roots');
INSERT INTO international VALUES (409,'WebGUI',1,'Add a new root.');
INSERT INTO international VALUES (410,'WebGUI',1,'Manage roots.');
INSERT INTO international VALUES (411,'WebGUI',1,'Menu Title');
INSERT INTO international VALUES (412,'WebGUI',1,'Synopsis');
INSERT INTO international VALUES (9,'SiteMap',1,'Display synopsis?');
INSERT INTO international VALUES (18,'Article',1,'Allow discussion?');
INSERT INTO international VALUES (10,'Product',1,'Price');
INSERT INTO international VALUES (22,'Article',1,'Author');
INSERT INTO international VALUES (23,'Article',1,'Date');
INSERT INTO international VALUES (24,'Article',1,'Post Response');
INSERT INTO international VALUES (58,'UserSubmission',1,'Previous Submission');
INSERT INTO international VALUES (27,'Article',1,'Back To Article');
INSERT INTO international VALUES (28,'Article',1,'View Responses');
INSERT INTO international VALUES (55,'Product',1,'Add a benefit.');
INSERT INTO international VALUES (416,'WebGUI',1,'<h1>Problem With Request</h1>We have encountered a problem with your request. Please use your back button and try again. If this problem persists, please contact us with what you were trying to do and the time and date of the problem.');
INSERT INTO international VALUES (417,'WebGUI',1,'<h1>Security Violation</h1>You attempted to access a wobject not associated with this page. This incident has been reported.');
INSERT INTO international VALUES (418,'WebGUI',1,'Filter Contributed HTML');
INSERT INTO international VALUES (419,'WebGUI',1,'Remove all tags.');
INSERT INTO international VALUES (420,'WebGUI',1,'Leave as is.');
INSERT INTO international VALUES (421,'WebGUI',1,'Remove all but basic formating.');
INSERT INTO international VALUES (422,'WebGUI',1,'<h1>Login Failed</h1>The information supplied does not match the account.');
INSERT INTO international VALUES (423,'WebGUI',1,'View active sessions.');
INSERT INTO international VALUES (424,'WebGUI',1,'View login history.');
INSERT INTO international VALUES (425,'WebGUI',1,'Active Sessions');
INSERT INTO international VALUES (426,'WebGUI',1,'Login History');
INSERT INTO international VALUES (427,'WebGUI',1,'Styles');
INSERT INTO international VALUES (428,'WebGUI',1,'User (ID)');
INSERT INTO international VALUES (429,'WebGUI',1,'Login Time');
INSERT INTO international VALUES (430,'WebGUI',1,'Last Page View');
INSERT INTO international VALUES (431,'WebGUI',1,'IP Address');
INSERT INTO international VALUES (432,'WebGUI',1,'Expires');
INSERT INTO international VALUES (433,'WebGUI',1,'User Agent');
INSERT INTO international VALUES (434,'WebGUI',1,'Status');
INSERT INTO international VALUES (435,'WebGUI',1,'Session Signature');
INSERT INTO international VALUES (436,'WebGUI',1,'Kill Session');
INSERT INTO international VALUES (437,'WebGUI',1,'Statistics');
INSERT INTO international VALUES (438,'WebGUI',1,'Your Name');
INSERT INTO international VALUES (577,'WebGUI',2,'Antwort\r\nschicken');
INSERT INTO international VALUES (13,'LinkList',2,'Neuen Link\r\nhinzufügen');
INSERT INTO international VALUES (13,'EventsCalendar',2,'Veranstaltung bearbeiten');
INSERT INTO international VALUES (13,'Article',2,'Löschen');
INSERT INTO international VALUES (12,'WebGUI',2,'Administrationsmodus abschalten');
INSERT INTO international VALUES (12,'UserSubmission',2,'(Bitte\r\nausklicken, wenn Ihr Beitrag in HTML geschrieben ist)');
INSERT INTO international VALUES (12,'SQLReport',2,'Fehler:\r\nDatenbankverbindung konnte nicht aufgebaut werden.');
INSERT INTO international VALUES (12,'MessageBoard',2,'Beitrag\r\nbearbeiten');
INSERT INTO international VALUES (12,'LinkList',2,'Link\r\nbearbeiten');
INSERT INTO international VALUES (12,'EventsCalendar',2,'Veranstaltungskalender bearbeiten');
INSERT INTO international VALUES (12,'DownloadManager',2,'Sind Sie\r\nsicher, dass Sie diesen Download löschen möchten?');
INSERT INTO international VALUES (12,'Article',2,'Artikel\r\nbearbeiten');
INSERT INTO international VALUES (11,'WebGUI',2,'Mülleimer\r\nleeren');
INSERT INTO international VALUES (1,'SyndicatedContent',6,'URL till RSS filen');
INSERT INTO international VALUES (11,'SQLReport',2,'Fehler: Es gab\r\nein Problem mit der Abfrage.');
INSERT INTO international VALUES (11,'Poll',2,'Abstimmen');
INSERT INTO international VALUES (11,'MessageBoard',2,'Zurück zur\r\nBeitragsliste');
INSERT INTO international VALUES (59,'Product',1,'Name');
INSERT INTO international VALUES (60,'Product',1,'Template');
INSERT INTO international VALUES (11,'DownloadManager',2,'Neuen\r\nDownload hinzufügen.');
INSERT INTO international VALUES (11,'Article',2,'(Bitte anklicken,\r\nfalls Sie nicht &lt;br&gt; in Ihrem Text hinzufügen.)');
INSERT INTO international VALUES (10,'WebGUI',2,'Mülleimer\r\nanschauen');
INSERT INTO international VALUES (10,'SQLReport',2,'Fehler: Das\r\nSQL-Statement ist im falschen Format.');
INSERT INTO international VALUES (563,'WebGUI',2,'Standard\r\nstatus');
INSERT INTO international VALUES (10,'Poll',2,'Abstimmung\r\nzurücksetzen');
INSERT INTO international VALUES (7,'Article',0,'Titel på henvisning');
INSERT INTO international VALUES (10,'LinkList',2,'Link Liste\r\nbearbeiten');
INSERT INTO international VALUES (10,'FAQ',2,'Frage bearbeiten');
INSERT INTO international VALUES (10,'DownloadManager',2,'Download\r\nbearbeiten');
INSERT INTO international VALUES (10,'Article',2,'Carriage Return\r\nbeachten?');
INSERT INTO international VALUES (562,'WebGUI',2,'Ausstehend');
INSERT INTO international VALUES (9,'WebGUI',2,'Zwischenablage\r\nanschauen');
INSERT INTO international VALUES (9,'SQLReport',2,'Fehler: Die DSN\r\nbesitzt das falsche Format.');
INSERT INTO international VALUES (9,'SiteMap',2,'Übersicht\r\nanzeigen?');
INSERT INTO international VALUES (9,'Poll',2,'Abstimmung\r\nbearbeiten');
INSERT INTO international VALUES (9,'MessageBoard',2,'Beitrags\r\nID:');
INSERT INTO international VALUES (9,'LinkList',2,'Sind Sie sicher,\r\ndass Sie diesen Link löschen wollen?');
INSERT INTO international VALUES (9,'FAQ',2,'Neue Frage\r\nhinzufügen');
INSERT INTO international VALUES (9,'EventsCalendar',2,'bis');
INSERT INTO international VALUES (9,'DownloadManager',2,'Download\r\nManager bearbeiten');
INSERT INTO international VALUES (9,'Article',2,'Dateianhang');
INSERT INTO international VALUES (8,'WebGUI',2,'\"Seite nicht\r\ngefunden\" anschauen');
INSERT INTO international VALUES (561,'WebGUI',2,'Verboten');
INSERT INTO international VALUES (8,'SQLReport',2,'SQL Bericht\r\nbearbeiten');
INSERT INTO international VALUES (8,'SiteMap',2,'Zeilenabstand');
INSERT INTO international VALUES (8,'Poll',2,'(Eine Antwort pro\r\nZeile. Bitte nicht mehr als 20 verschiedene Antworten)');
INSERT INTO international VALUES (8,'MessageBoard',2,'Datum:');
INSERT INTO international VALUES (8,'LinkList',2,'URL');
INSERT INTO international VALUES (8,'FAQ',2,'F.A.Q. bearbeiten');
INSERT INTO international VALUES (8,'EventsCalendar',2,'Wiederholt\r\nsich');
INSERT INTO international VALUES (8,'DownloadManager',2,'Kurze\r\nBeschreibung');
INSERT INTO international VALUES (7,'WebGUI',2,'Benutzer\r\nverwalten');
INSERT INTO international VALUES (8,'Article',2,'Link URL');
INSERT INTO international VALUES (560,'WebGUI',2,'Erlaubt');
INSERT INTO international VALUES (7,'SQLReport',2,'Datenbankpasswort');
INSERT INTO international VALUES (7,'SiteMap',2,'Kugel');
INSERT INTO international VALUES (7,'Poll',2,'Antworten');
INSERT INTO international VALUES (7,'MessageBoard',2,'Autor:');
INSERT INTO international VALUES (2,'LinkList',6,'Avstånd mellan rader');
INSERT INTO international VALUES (7,'FAQ',2,'Sind Sie sicher, dass\r\nSie diese Frage löschen wollen?');
INSERT INTO international VALUES (2,'SQLReport',6,'Lägg till SQL rapport');
INSERT INTO international VALUES (7,'DownloadManager',2,'Gruppe,\r\ndie Download benutzen kann');
INSERT INTO international VALUES (7,'Article',2,'Link Titel');
INSERT INTO international VALUES (6,'WebGUI',2,'Stile verwalten');
INSERT INTO international VALUES (6,'UserSubmission',2,'Beiträge\r\npro Seite');
INSERT INTO international VALUES (6,'SyndicatedContent',2,'Aktueller Inhalt');
INSERT INTO international VALUES (6,'SQLReport',2,'Datenbankbenutzer');
INSERT INTO international VALUES (6,'SiteMap',2,'Zweck');
INSERT INTO international VALUES (6,'MessageBoard',2,'Diskussionsforum bearbeiten');
INSERT INTO international VALUES (6,'Poll',2,'Frage');
INSERT INTO international VALUES (6,'LinkList',2,'Link Liste');
INSERT INTO international VALUES (6,'FAQ',2,'Antwort');
INSERT INTO international VALUES (6,'ExtraColumn',2,'Extra Spalte\r\nbearbeiten');
INSERT INTO international VALUES (701,'WebGUI',2,'Woche');
INSERT INTO international VALUES (6,'DownloadManager',2,'Dateiname');
INSERT INTO international VALUES (6,'Article',2,'Bild');
INSERT INTO international VALUES (5,'WebGUI',2,'Gruppen\r\nverwalten');
INSERT INTO international VALUES (5,'UserSubmission',2,'Ihr Beitrag\r\nwurde abgelehnt.');
INSERT INTO international VALUES (5,'SyndicatedContent',2,'zuletzt\r\ngeholt');
INSERT INTO international VALUES (5,'SQLReport',2,'DSN (Data Source\r\nName)');
INSERT INTO international VALUES (5,'SiteMap',2,'Site Map\r\nbearbeiten');
INSERT INTO international VALUES (5,'Poll',2,'Breite der Grafik');
INSERT INTO international VALUES (566,'WebGUI',2,'Timeout zum\r\nbearbeiten');
INSERT INTO international VALUES (5,'LinkList',2,'Wollen Sie einen\r\nLink hinzufügen?');
INSERT INTO international VALUES (5,'Item',2,'Anhang\r\nherunterladen');
INSERT INTO international VALUES (5,'FAQ',2,'Frage');
INSERT INTO international VALUES (5,'ExtraColumn',2,'StyleSheet\r\nClass');
INSERT INTO international VALUES (700,'WebGUI',2,'Tag');
INSERT INTO international VALUES (5,'DownloadManager',2,'Dateititel');
INSERT INTO international VALUES (4,'WebGUI',2,'Einstellungen\r\nverwalten');
INSERT INTO international VALUES (4,'UserSubmission',2,'Ihr Betrag\r\nwurde angenommen.');
INSERT INTO international VALUES (4,'SQLReport',2,'Abfrage');
INSERT INTO international VALUES (4,'SyndicatedContent',2,'Clipping-Dienst bearbeiten');
INSERT INTO international VALUES (4,'SiteMap',2,'Tiefe');
INSERT INTO international VALUES (4,'Poll',2,'Wer kann\r\nabstimmen?');
INSERT INTO international VALUES (2,'WebGUI',6,'Sida');
INSERT INTO international VALUES (4,'Item',2,'Kleiner Artikel');
INSERT INTO international VALUES (4,'LinkList',2,'Kugel');
INSERT INTO international VALUES (4,'MessageBoard',2,'Beiträge pro\r\nSeite');
INSERT INTO international VALUES (4,'ExtraColumn',2,'Breite');
INSERT INTO international VALUES (4,'EventsCalendar',2,'Einmaliges\r\nEreignis');
INSERT INTO international VALUES (1,'Article',6,'Artikel');
INSERT INTO international VALUES (4,'Article',2,'Ende Datum');
INSERT INTO international VALUES (3,'WebGUI',2,'Aus Zwischenablage\r\neinfügen...');
INSERT INTO international VALUES (3,'UserSubmission',2,'Sie sollten\r\neinen neuen Beitrag genehmigen.');
INSERT INTO international VALUES (3,'FAQ',6,'Lägg till F.A.Q.');
INSERT INTO international VALUES (3,'SQLReport',2,'Schablone');
INSERT INTO international VALUES (3,'SiteMap',2,'Auf dieser Ebene\r\nStarten?');
INSERT INTO international VALUES (3,'Poll',2,'Aktiv');
INSERT INTO international VALUES (564,'WebGUI',2,'Wer kann\r\nBeiträge schreiben?');
INSERT INTO international VALUES (3,'LinkList',2,'In neuem Fenster\r\nöffnen?');
INSERT INTO international VALUES (3,'Item',2,'Anhang löschen');
INSERT INTO international VALUES (3,'ExtraColumn',2,'Platzhalter');
INSERT INTO international VALUES (3,'UserSubmission',6,'Du har ett nytt medelande att validera.');
INSERT INTO international VALUES (3,'DownloadManager',2,'Fortfahren\r\ndie Datei hinzuzufügen?');
INSERT INTO international VALUES (3,'Article',2,'Start Datum');
INSERT INTO international VALUES (2,'WebGUI',2,'Seite');
INSERT INTO international VALUES (2,'UserSubmission',2,'Wer kann\r\nBeiträge schreiben?');
INSERT INTO international VALUES (2,'SyndicatedContent',2,'Clipping-Dienst');
INSERT INTO international VALUES (4,'EventsCalendar',6,'Inträffar endast en gång.');
INSERT INTO international VALUES (2,'SiteMap',2,'Site\r\nMap/Übersicht');
INSERT INTO international VALUES (2,'FAQ',2,'F.A.Q.');
INSERT INTO international VALUES (2,'Item',2,'Anhang');
INSERT INTO international VALUES (2,'LinkList',2,'Zeilenabstand');
INSERT INTO international VALUES (2,'MessageBoard',2,'Diskussionsforum');
INSERT INTO international VALUES (4,'Item',6,'Post');
INSERT INTO international VALUES (2,'EventsCalendar',2,'Veranstaltungskalender');
INSERT INTO international VALUES (4,'SQLReport',6,'Query');
INSERT INTO international VALUES (1,'WebGUI',2,'Inhalt\r\nhinzufügen...');
INSERT INTO international VALUES (1,'SyndicatedContent',2,'URL zur\r\nRSS-Datei');
INSERT INTO international VALUES (1,'UserSubmission',2,'Wer kann\r\ngenehmigen?');
INSERT INTO international VALUES (1,'SQLReport',2,'SQL Bericht');
INSERT INTO international VALUES (1,'Poll',2,'Abstimmung');
INSERT INTO international VALUES (5,'FAQ',6,'Fråga');
INSERT INTO international VALUES (1,'LinkList',2,'Tabulator');
INSERT INTO international VALUES (1,'Item',2,'Link URL');
INSERT INTO international VALUES (1,'FAQ',2,'Frage hinzufügen?');
INSERT INTO international VALUES (1,'ExtraColumn',2,'Extra\r\nSpalte');
INSERT INTO international VALUES (1,'EventsCalendar',2,'Termin\r\nhinzufügen?');
INSERT INTO international VALUES (1,'DownloadManager',2,'Download\r\nManager');
INSERT INTO international VALUES (1,'Article',2,'Artikel');
INSERT INTO international VALUES (395,'WebGUI',2,'Neue Grafik\r\nhinzufügen.');
INSERT INTO international VALUES (396,'WebGUI',2,'Grafik\r\nanschauen');
INSERT INTO international VALUES (397,'WebGUI',2,'Zurück zur\r\nGrafikübersicht.');
INSERT INTO international VALUES (398,'WebGUI',2,'Dokumententyp\r\nBeschreibung');
INSERT INTO international VALUES (399,'WebGUI',2,'Diese Seite\r\nüberprüfen.');
INSERT INTO international VALUES (400,'WebGUI',2,'Caching\r\nverhindern');
INSERT INTO international VALUES (401,'WebGUI',2,'Sind Sie sicher,\r\ndass Sie diese Nachrichten und alle darunterliegenden löschen wollen?');
INSERT INTO international VALUES (402,'WebGUI',2,'Die Nachricht die\r\nsie abfragen wollten existiert leider nicht.');
INSERT INTO international VALUES (403,'WebGUI',2,'Ich teile es\r\nlieber nicht mit.');
INSERT INTO international VALUES (404,'WebGUI',2,'Erste Seite');
INSERT INTO international VALUES (405,'WebGUI',2,'Letzte Seite');
INSERT INTO international VALUES (406,'WebGUI',2,'Größe der kleinen\r\nBilder');
INSERT INTO international VALUES (407,'WebGUI',2,'Klicken Sie hier,\r\num sich zu registrieren');
INSERT INTO international VALUES (408,'WebGUI',2,'Startseiten\r\nbearbeiten');
INSERT INTO international VALUES (409,'WebGUI',2,'Neue Startseite\r\nanlegen');
INSERT INTO international VALUES (410,'WebGUI',2,'Startseiten\r\nbearbeiten');
INSERT INTO international VALUES (411,'WebGUI',2,'Menü Titel');
INSERT INTO international VALUES (412,'WebGUI',2,'Synopse');
INSERT INTO international VALUES (48,'Product',1,'Are you certain you wish to delete this benefit? It cannot be recovered once it has been deleted.');
INSERT INTO international VALUES (416,'WebGUI',2,'<h1>Abfrageproblem</h1> Ihre Anfrage macht dem\r\nSystem Probleme. Bitte betätigen Sie den Zurückbutton im Browser und\r\nversuchen Sie es nochmal. Sollte dieses Problem weiterbestehen, teilen Sie\r\nuns bitte mit, was Sie wo im System wann gemacht haben.');
INSERT INTO international VALUES (417,'WebGUI',2,'<h1>Sicherheitsverstoß</h1> Sie haben versucht\r\nauf einen Systemteil zuzugreifen, der Ihnen nicht erlaubt ist. Der Verstoß\r\nwurde gemeldet.');
INSERT INTO international VALUES (418,'WebGUI',2,'HTML filtern');
INSERT INTO international VALUES (419,'WebGUI',2,'Alle\r\nBeschreibungselemente entfernen');
INSERT INTO international VALUES (420,'WebGUI',2,'Nicht\r\nverändern');
INSERT INTO international VALUES (421,'WebGUI',2,'Nur einfache\r\nFormatierungen beibehalten');
INSERT INTO international VALUES (422,'WebGUI',2,'<h1>Anmeldung ist\r\nfehlgeschlagen!</h1> Die eingegebenen Zugansdaten stimmen mit keinen\r\nBenutzerdaten überein.');
INSERT INTO international VALUES (423,'WebGUI',2,'Aktive Sitzungen\r\nanschauen');
INSERT INTO international VALUES (424,'WebGUI',2,'Anmeldungshistorie anschauen');
INSERT INTO international VALUES (425,'WebGUI',2,'Aktive\r\nSitzungen');
INSERT INTO international VALUES (426,'WebGUI',2,'Anmeldungshistorie');
INSERT INTO international VALUES (427,'WebGUI',2,'Stile');
INSERT INTO international VALUES (428,'WebGUI',2,'Benutzername');
INSERT INTO international VALUES (429,'WebGUI',2,'Anmeldungszeit');
INSERT INTO international VALUES (430,'WebGUI',2,'Seite wurde das\r\nletzte mal angeschaut');
INSERT INTO international VALUES (431,'WebGUI',2,'IP Adresse');
INSERT INTO international VALUES (432,'WebGUI',2,'läuft ab');
INSERT INTO international VALUES (434,'WebGUI',2,'Status');
INSERT INTO international VALUES (435,'WebGUI',2,'Sitzungssignatur');
INSERT INTO international VALUES (436,'WebGUI',2,'Sitzung\r\nbeenden');
INSERT INTO international VALUES (437,'WebGUI',2,'Statistiken');
INSERT INTO international VALUES (438,'WebGUI',2,'Ihr Name');
INSERT INTO international VALUES (439,'WebGUI',1,'Personal Information');
INSERT INTO international VALUES (440,'WebGUI',1,'Contact Information');
INSERT INTO international VALUES (441,'WebGUI',1,'Email To Pager Gateway');
INSERT INTO international VALUES (442,'WebGUI',1,'Work Information');
INSERT INTO international VALUES (443,'WebGUI',1,'Home Information');
INSERT INTO international VALUES (444,'WebGUI',1,'Demographic Information');
INSERT INTO international VALUES (445,'WebGUI',1,'Preferences');
INSERT INTO international VALUES (446,'WebGUI',1,'Work Web Site');
INSERT INTO international VALUES (447,'WebGUI',1,'Manage page tree.');
INSERT INTO international VALUES (448,'WebGUI',1,'Page Tree');
INSERT INTO international VALUES (449,'WebGUI',1,'Miscellaneous Information');
INSERT INTO international VALUES (450,'WebGUI',1,'Work Name (Company Name)');
INSERT INTO international VALUES (451,'WebGUI',1,'is required.');
INSERT INTO international VALUES (452,'WebGUI',1,'Please wait...');
INSERT INTO international VALUES (453,'WebGUI',1,'Date Created');
INSERT INTO international VALUES (454,'WebGUI',1,'Last Updated');
INSERT INTO international VALUES (455,'WebGUI',1,'Edit User\'s Profile');
INSERT INTO international VALUES (456,'WebGUI',1,'Back to user list.');
INSERT INTO international VALUES (457,'WebGUI',1,'Edit this user\'s account.');
INSERT INTO international VALUES (458,'WebGUI',1,'Edit this user\'s groups.');
INSERT INTO international VALUES (459,'WebGUI',1,'Edit this user\'s profile.');
INSERT INTO international VALUES (460,'WebGUI',1,'Time Offset');
INSERT INTO international VALUES (461,'WebGUI',1,'Date Format');
INSERT INTO international VALUES (462,'WebGUI',1,'Time Format');
INSERT INTO international VALUES (463,'WebGUI',1,'Text Area Rows');
INSERT INTO international VALUES (464,'WebGUI',1,'Text Area Columns');
INSERT INTO international VALUES (465,'WebGUI',1,'Text Box Size');
INSERT INTO international VALUES (466,'WebGUI',1,'Are you certain you wish to delete this category and move all of its fields to the Miscellaneous category?');
INSERT INTO international VALUES (467,'WebGUI',1,'Are you certain you wish to delete this field and all user data attached to it?');
INSERT INTO international VALUES (468,'WebGUI',6,'Redigera Användar Profil Kattegorier');
INSERT INTO international VALUES (469,'WebGUI',1,'Id');
INSERT INTO international VALUES (470,'WebGUI',1,'Name');
INSERT INTO international VALUES (472,'WebGUI',1,'Label');
INSERT INTO international VALUES (473,'WebGUI',1,'Visible?');
INSERT INTO international VALUES (474,'WebGUI',1,'Required?');
INSERT INTO international VALUES (475,'WebGUI',1,'Text');
INSERT INTO international VALUES (476,'WebGUI',1,'Text Area');
INSERT INTO international VALUES (477,'WebGUI',1,'HTML Area');
INSERT INTO international VALUES (478,'WebGUI',1,'URL');
INSERT INTO international VALUES (479,'WebGUI',1,'Date');
INSERT INTO international VALUES (480,'WebGUI',1,'Email Address');
INSERT INTO international VALUES (481,'WebGUI',1,'Telephone Number');
INSERT INTO international VALUES (482,'WebGUI',1,'Number (Integer)');
INSERT INTO international VALUES (483,'WebGUI',1,'Yes or No');
INSERT INTO international VALUES (484,'WebGUI',1,'Select List');
INSERT INTO international VALUES (485,'WebGUI',1,'Boolean (Checkbox)');
INSERT INTO international VALUES (486,'WebGUI',1,'Data Type');
INSERT INTO international VALUES (487,'WebGUI',1,'Possible Values');
INSERT INTO international VALUES (488,'WebGUI',1,'Default Value(s)');
INSERT INTO international VALUES (489,'WebGUI',1,'Profile Category');
INSERT INTO international VALUES (490,'WebGUI',1,'Add a profile category.');
INSERT INTO international VALUES (491,'WebGUI',1,'Add a profile field.');
INSERT INTO international VALUES (492,'WebGUI',1,'Profile fields list.');
INSERT INTO international VALUES (493,'WebGUI',1,'Back to site.');
INSERT INTO international VALUES (495,'WebGUI',1,'Built-In Editor');
INSERT INTO international VALUES (496,'WebGUI',1,'Editor To Use');
INSERT INTO international VALUES (494,'WebGUI',1,'Real Objects Edit-On Pro');
INSERT INTO international VALUES (497,'WebGUI',1,'Start Date');
INSERT INTO international VALUES (498,'WebGUI',1,'End Date');
INSERT INTO international VALUES (499,'WebGUI',1,'Wobject ID');
INSERT INTO international VALUES (500,'WebGUI',1,'Page ID');
INSERT INTO international VALUES (5,'Poll',6,'Bred på staplar');
INSERT INTO international VALUES (5,'SiteMap',6,'Redigera Site Kartan');
INSERT INTO international VALUES (5,'SQLReport',6,'DSN');
INSERT INTO international VALUES (5,'SyndicatedContent',6,'Senast hämtad');
INSERT INTO international VALUES (5,'UserSubmission',6,'Ditt medelande har blivit nekat validering.');
INSERT INTO international VALUES (5,'WebGUI',6,'Kontrolera grupper.');
INSERT INTO international VALUES (6,'Article',6,'Bild');
INSERT INTO international VALUES (701,'WebGUI',6,'Vecka');
INSERT INTO international VALUES (6,'ExtraColumn',6,'Lägg till extra column');
INSERT INTO international VALUES (6,'FAQ',6,'Svar');
INSERT INTO international VALUES (6,'LinkList',6,'Länk Lista');
INSERT INTO international VALUES (6,'MessageBoard',6,'Redigera Meddelande Forum');
INSERT INTO international VALUES (6,'Poll',6,'Fråga');
INSERT INTO international VALUES (6,'SiteMap',6,'Indentering');
INSERT INTO international VALUES (6,'SQLReport',6,'Database Användare');
INSERT INTO international VALUES (6,'SyndicatedContent',6,'Nuvarande inehåll');
INSERT INTO international VALUES (6,'UserSubmission',6,'Inlägg per sida');
INSERT INTO international VALUES (6,'WebGUI',6,'Kontrolera stilar.');
INSERT INTO international VALUES (7,'Article',6,'Länk Titel');
INSERT INTO international VALUES (7,'EventsCalendar',6,'Lägg till händelse');
INSERT INTO international VALUES (7,'FAQ',6,'Är du säker på att du vill radera denna fråga?');
INSERT INTO international VALUES (7,'LinkList',6,'Lägg till länk');
INSERT INTO international VALUES (7,'MessageBoard',6,'Författare:');
INSERT INTO international VALUES (7,'Poll',6,'Svar');
INSERT INTO international VALUES (7,'SiteMap',6,'Kula');
INSERT INTO international VALUES (7,'SQLReport',6,'Database Lösenord');
INSERT INTO international VALUES (560,'WebGUI',6,'Godkännt');
INSERT INTO international VALUES (7,'WebGUI',6,'Kontrolera användare.');
INSERT INTO international VALUES (8,'Article',6,'Länk URL');
INSERT INTO international VALUES (8,'EventsCalendar',6,'Recurs every');
INSERT INTO international VALUES (8,'FAQ',6,'Redigera F.A.Q.');
INSERT INTO international VALUES (8,'LinkList',6,'URL');
INSERT INTO international VALUES (8,'MessageBoard',6,'Datum:');
INSERT INTO international VALUES (8,'Poll',6,'(Mata in ett svar per rad. Max 20.)');
INSERT INTO international VALUES (8,'SiteMap',6,'Avstånd mellan rader');
INSERT INTO international VALUES (8,'SQLReport',6,'Redigera SQL Rapport');
INSERT INTO international VALUES (561,'WebGUI',6,'Nekat');
INSERT INTO international VALUES (8,'WebGUI',6,'Visa page not found.');
INSERT INTO international VALUES (9,'Article',6,'Bilagor');
INSERT INTO international VALUES (9,'EventsCalendar',6,'until');
INSERT INTO international VALUES (9,'FAQ',6,'Lägg till ny fråga.');
INSERT INTO international VALUES (9,'LinkList',6,'Är du säker att du vill radera denna länk?');
INSERT INTO international VALUES (9,'MessageBoard',6,'Meddelande ID:');
INSERT INTO international VALUES (9,'Poll',6,'Redigera fråga');
INSERT INTO international VALUES (9,'SQLReport',6,'&lt;b&gt;Debug:&lt;/b&gt; Error: The DSN specified is of an improper format.');
INSERT INTO international VALUES (562,'WebGUI',6,'Väntande');
INSERT INTO international VALUES (9,'WebGUI',6,'Visa klippbord.');
INSERT INTO international VALUES (10,'Article',6,'Konvertera radbrytning?');
INSERT INTO international VALUES (10,'FAQ',6,'Redigera fråga');
INSERT INTO international VALUES (10,'LinkList',6,'Redigera Länk Lista');
INSERT INTO international VALUES (2,'Article',0,'Tilføj artikel');
INSERT INTO international VALUES (10,'Poll',6,'Återställ röster.');
INSERT INTO international VALUES (10,'SQLReport',6,'&lt;b&gt;Debug:&lt;/b&gt; Error: The SQL specified is of an improper format.');
INSERT INTO international VALUES (563,'WebGUI',6,'Default Status');
INSERT INTO international VALUES (10,'WebGUI',6,'Hantera skräpkorgen.');
INSERT INTO international VALUES (11,'Article',6,'(Kryssa i om du inte skriver &amp;lt;br&amp;gt; manuelt.)');
INSERT INTO international VALUES (77,'EventsCalendar',1,'Delete this event <b>and</b> all of its recurrences.');
INSERT INTO international VALUES (11,'LinkList',6,'Lägg till Länk Lista');
INSERT INTO international VALUES (11,'MessageBoard',6,'Tillbaka till meddelande lista');
INSERT INTO international VALUES (11,'SQLReport',6,'&lt;b&gt;Debug:&lt;/b&gt; Error: There was a problem with the query.');
INSERT INTO international VALUES (11,'UserSubmission',6,'Lägg till inlägg');
INSERT INTO international VALUES (11,'WebGUI',6,'Töm skräpkoren.');
INSERT INTO international VALUES (12,'Article',6,'Redigera Artikel');
INSERT INTO international VALUES (12,'EventsCalendar',6,'Edit Events Calendar');
INSERT INTO international VALUES (12,'LinkList',6,'Redigera Länk');
INSERT INTO international VALUES (12,'MessageBoard',6,'Redigera meddelande');
INSERT INTO international VALUES (12,'SQLReport',6,'&lt;b&gt;Debug:&lt;/b&gt; Error: Could not connect to the database.');
INSERT INTO international VALUES (12,'UserSubmission',6,'(Avkryssa om du skriver ett HTML inlägg.)');
INSERT INTO international VALUES (12,'WebGUI',6,'Stäng av adminverktyg.');
INSERT INTO international VALUES (13,'Article',6,'Radera');
INSERT INTO international VALUES (13,'EventsCalendar',6,'Lägg till händelse');
INSERT INTO international VALUES (13,'LinkList',6,'Lägg till en ny länk.');
INSERT INTO international VALUES (577,'WebGUI',6,'Skicka svar');
INSERT INTO international VALUES (13,'UserSubmission',6,'Inlagt den');
INSERT INTO international VALUES (13,'WebGUI',6,'Visa hjälpindex.');
INSERT INTO international VALUES (14,'Article',6,'Justera Bild');
INSERT INTO international VALUES (514,'WebGUI',1,'Views');
INSERT INTO international VALUES (14,'UserSubmission',6,'Status');
INSERT INTO international VALUES (14,'WebGUI',6,'Visa väntande meddelanden.');
INSERT INTO international VALUES (15,'MessageBoard',6,'Författare');
INSERT INTO international VALUES (15,'UserSubmission',6,'Redigera/Ta bort');
INSERT INTO international VALUES (15,'WebGUI',6,'Januari');
INSERT INTO international VALUES (16,'MessageBoard',6,'Datum');
INSERT INTO international VALUES (16,'UserSubmission',6,'Namnlös');
INSERT INTO international VALUES (16,'WebGUI',6,'Februari');
INSERT INTO international VALUES (17,'MessageBoard',6,'Skicka nytt meddelande');
INSERT INTO international VALUES (17,'UserSubmission',6,'Är du säger du vill ta bort detta inlägg?');
INSERT INTO international VALUES (17,'WebGUI',6,'Mars');
INSERT INTO international VALUES (18,'MessageBoard',6,'Tråd startad');
INSERT INTO international VALUES (18,'UserSubmission',6,'Regigera inläggs system');
INSERT INTO international VALUES (18,'WebGUI',6,'April');
INSERT INTO international VALUES (19,'MessageBoard',6,'Svar');
INSERT INTO international VALUES (19,'UserSubmission',6,'Redigera inlägg');
INSERT INTO international VALUES (19,'WebGUI',6,'Maj');
INSERT INTO international VALUES (20,'MessageBoard',6,'Senaste svar');
INSERT INTO international VALUES (20,'UserSubmission',6,'Skicka nytt inlägg');
INSERT INTO international VALUES (20,'WebGUI',6,'Juni');
INSERT INTO international VALUES (21,'UserSubmission',6,'Skrivet av');
INSERT INTO international VALUES (21,'WebGUI',6,'Juli');
INSERT INTO international VALUES (22,'UserSubmission',6,'Skrivet av:');
INSERT INTO international VALUES (22,'WebGUI',6,'Augusti');
INSERT INTO international VALUES (23,'UserSubmission',6,'Inläggsdatum:');
INSERT INTO international VALUES (23,'WebGUI',6,'September');
INSERT INTO international VALUES (572,'WebGUI',6,'Godkänn');
INSERT INTO international VALUES (24,'WebGUI',6,'Oktober');
INSERT INTO international VALUES (573,'WebGUI',6,'Lämna i vänteläge');
INSERT INTO international VALUES (25,'WebGUI',6,'November');
INSERT INTO international VALUES (574,'WebGUI',6,'Neka');
INSERT INTO international VALUES (26,'WebGUI',6,'December');
INSERT INTO international VALUES (27,'UserSubmission',6,'Redigera');
INSERT INTO international VALUES (27,'WebGUI',6,'Söndag');
INSERT INTO international VALUES (28,'UserSubmission',6,'Återgå till inläggslistan');
INSERT INTO international VALUES (28,'WebGUI',6,'Måndag');
INSERT INTO international VALUES (29,'UserSubmission',6,'Användar-inläggs system');
INSERT INTO international VALUES (29,'WebGUI',6,'Tisdag');
INSERT INTO international VALUES (576,'WebGUI',1,'Delete');
INSERT INTO international VALUES (30,'WebGUI',6,'Onsdag');
INSERT INTO international VALUES (31,'WebGUI',6,'Torsdag');
INSERT INTO international VALUES (32,'WebGUI',6,'Fredag');
INSERT INTO international VALUES (33,'WebGUI',6,'Lördag');
INSERT INTO international VALUES (34,'WebGUI',6,'sätt datum');
INSERT INTO international VALUES (35,'WebGUI',6,'Administrativa funktioner');
INSERT INTO international VALUES (36,'WebGUI',6,'Du måste vara administratör för att utföra denna funktion. Var vänlig kontakta någon av administratörerna. Följande är en lista av administratörer i systemet:');
INSERT INTO international VALUES (37,'WebGUI',6,'Åtkomst nekas!');
INSERT INTO international VALUES (404,'WebGUI',6,'Första Sidan');
INSERT INTO international VALUES (38,'WebGUI',6,'Du har inte rättigheter att utföra denna operation. Var vänlig och ^a(logga in); på ett konto med tillräckliga rättigheter.');
INSERT INTO international VALUES (39,'WebGUI',6,'Åtkomst nekas, du har inte tillräckliga previlegier.');
INSERT INTO international VALUES (40,'WebGUI',6,'Vital komponent');
INSERT INTO international VALUES (41,'WebGUI',6,'Du håller på att ta bort en vital komponent från WebGUI systemet. Om du hade varit tillåten att göra detta, hade WebGUI slutat fungera !');
INSERT INTO international VALUES (42,'WebGUI',6,'Var vänlig konfirmera');
INSERT INTO international VALUES (43,'WebGUI',6,'Är du säker att du vill ta bort detta inehåll?');
INSERT INTO international VALUES (44,'WebGUI',6,'Ja, jag är säker.');
INSERT INTO international VALUES (45,'WebGUI',6,'Nej, jag gjorde ett misstag.');
INSERT INTO international VALUES (46,'WebGUI',6,'Mitt konto');
INSERT INTO international VALUES (47,'WebGUI',6,'Hem');
INSERT INTO international VALUES (48,'WebGUI',6,'Hej');
INSERT INTO international VALUES (49,'WebGUI',6,'Klicka &lt;a href=unknown://\"^\\;?op=logout\" TARGET=\"_blank\"&gt;här&lt;/a&gt; för att logga ur.');
INSERT INTO international VALUES (50,'WebGUI',6,'Användarnamn');
INSERT INTO international VALUES (51,'WebGUI',6,'Lösenord');
INSERT INTO international VALUES (52,'WebGUI',6,'logga in');
INSERT INTO international VALUES (53,'WebGUI',6,'Utskrifts version');
INSERT INTO international VALUES (54,'WebGUI',6,'Skapa konto');
INSERT INTO international VALUES (55,'WebGUI',6,'Lösenord (kontroll)');
INSERT INTO international VALUES (56,'WebGUI',6,'Email adress');
INSERT INTO international VALUES (57,'WebGUI',6,'Detta krävs endas om du vill använda tjänster som kräver Email.');
INSERT INTO international VALUES (58,'WebGUI',6,'Jag har redan ett konto.');
INSERT INTO international VALUES (59,'WebGUI',6,'Jag har glömt mitt lösenord.');
INSERT INTO international VALUES (60,'WebGUI',6,'ÄR du säker på att du vill stänga ned ditt konto ? Om du fortsätter kommer all information att vara permanent förlorad.');
INSERT INTO international VALUES (61,'WebGUI',6,'Uppdatera konto information');
INSERT INTO international VALUES (62,'WebGUI',6,'spara');
INSERT INTO international VALUES (63,'WebGUI',6,'Slå på admin-verktyg.');
INSERT INTO international VALUES (64,'WebGUI',6,'Logga ut.');
INSERT INTO international VALUES (65,'WebGUI',6,'Var vänlig och radera mitt konto permanent.');
INSERT INTO international VALUES (66,'WebGUI',6,'Logga in.');
INSERT INTO international VALUES (67,'WebGUI',6,'Skapa ett konto.');
INSERT INTO international VALUES (68,'WebGUI',6,'Informationen du gav var felaktig. Antingen så finns ingen sådan användare eller också så gav du fellösenords.');
INSERT INTO international VALUES (69,'WebGUI',6,'Var vänlig kontakta system administratören för vidare hjälp.');
INSERT INTO international VALUES (70,'WebGUI',6,'Fel');
INSERT INTO international VALUES (71,'WebGUI',6,'Rädda lösenord');
INSERT INTO international VALUES (72,'WebGUI',6,'rädda');
INSERT INTO international VALUES (73,'WebGUI',6,'Logga in.');
INSERT INTO international VALUES (74,'WebGUI',6,'Konto information');
INSERT INTO international VALUES (75,'WebGUI',6,'Din kontoinformation har skickats till din Email adress.');
INSERT INTO international VALUES (76,'WebGUI',6,'Den Email adressen finns inte i vårt system.');
INSERT INTO international VALUES (77,'WebGUI',6,'Det kontonamnet du valde används redan på denna site. Var vänlig välj ett annat. Här kommer några ideer som du kan använda:');
INSERT INTO international VALUES (78,'WebGUI',6,'Ditt lösenord stämde inte. Var vänlig försök igen.');
INSERT INTO international VALUES (79,'WebGUI',6,'Cannot connect to LDAP server.');
INSERT INTO international VALUES (80,'WebGUI',6,'Kontot skapades utan problem!');
INSERT INTO international VALUES (81,'WebGUI',6,'Kontot uppdaterat utan problem!');
INSERT INTO international VALUES (82,'WebGUI',6,'Administrativa funktioner...');
INSERT INTO international VALUES (84,'WebGUI',6,'Grupp namn');
INSERT INTO international VALUES (85,'WebGUI',6,'Beskrivning');
INSERT INTO international VALUES (86,'WebGUI',6,'Är du säker på att du vill radera denna grupp? Var medveten om att alla rättigheter associerade med denna grupp kommer att raderas.');
INSERT INTO international VALUES (87,'WebGUI',6,'Ändra grupp');
INSERT INTO international VALUES (88,'WebGUI',6,'Användare i gruppen');
INSERT INTO international VALUES (89,'WebGUI',6,'Grupper');
INSERT INTO international VALUES (90,'WebGUI',6,'Lägg till grupp.');
INSERT INTO international VALUES (91,'WebGUI',6,'Föregående sida');
INSERT INTO international VALUES (92,'WebGUI',6,'Nästa sida');
INSERT INTO international VALUES (93,'WebGUI',6,'Hjälp');
INSERT INTO international VALUES (94,'WebGUI',6,'Se vidare');
INSERT INTO international VALUES (95,'WebGUI',6,'Hjälp index');
INSERT INTO international VALUES (98,'WebGUI',6,'Lägg till sida');
INSERT INTO international VALUES (99,'WebGUI',6,'Titel');
INSERT INTO international VALUES (100,'WebGUI',6,'Meta Tag');
INSERT INTO international VALUES (101,'WebGUI',6,'Är du säker på att du vill radera denna sita, dess inehåll och underligande objekt?');
INSERT INTO international VALUES (102,'WebGUI',6,'Editera sida');
INSERT INTO international VALUES (103,'WebGUI',6,'Sidspecifikation');
INSERT INTO international VALUES (104,'WebGUI',6,'Sidans URL');
INSERT INTO international VALUES (105,'WebGUI',6,'Stil');
INSERT INTO international VALUES (106,'WebGUI',6,'Ge samma stil till underliggande sidor.');
INSERT INTO international VALUES (107,'WebGUI',6,'Previlegier');
INSERT INTO international VALUES (108,'WebGUI',6,'Ägare');
INSERT INTO international VALUES (109,'WebGUI',6,'Ägaren kan se?');
INSERT INTO international VALUES (110,'WebGUI',6,'Ägaren kan editera?');
INSERT INTO international VALUES (111,'WebGUI',6,'Grupp');
INSERT INTO international VALUES (112,'WebGUI',6,'Gruppen kan se?');
INSERT INTO international VALUES (113,'WebGUI',6,'Gruppen kan editera?');
INSERT INTO international VALUES (114,'WebGUI',6,'Vemsomhelst kan titta?');
INSERT INTO international VALUES (115,'WebGUI',6,'Kan vem som helst redigera?');
INSERT INTO international VALUES (116,'WebGUI',6,'Kryssa här för att kopiera dessa previlegier till undersidor.');
INSERT INTO international VALUES (117,'WebGUI',6,'Redigera Autentiserings inställningar');
INSERT INTO international VALUES (118,'WebGUI',6,'Anonyma registreringar');
INSERT INTO international VALUES (119,'WebGUI',6,'Authentiserings metod(default)');
INSERT INTO international VALUES (120,'WebGUI',6,'LDAP URL (default)');
INSERT INTO international VALUES (121,'WebGUI',6,'LDAP Identity (default)');
INSERT INTO international VALUES (122,'WebGUI',6,'LDAP Identity Name');
INSERT INTO international VALUES (123,'WebGUI',6,'LDAP Password Name');
INSERT INTO international VALUES (124,'WebGUI',6,'Edit Company Information');
INSERT INTO international VALUES (125,'WebGUI',6,'Företags namn');
INSERT INTO international VALUES (126,'WebGUI',6,'Företags Email adress');
INSERT INTO international VALUES (127,'WebGUI',6,'Företags URL');
INSERT INTO international VALUES (130,'WebGUI',6,'Maximal storlek på bilagor');
INSERT INTO international VALUES (133,'WebGUI',6,'Redigera Mail Inställningar');
INSERT INTO international VALUES (134,'WebGUI',6,'Rädda lösenords meddelande');
INSERT INTO international VALUES (135,'WebGUI',6,'SMTP Server');
INSERT INTO international VALUES (527,'WebGUI',1,'Default Home Page');
INSERT INTO international VALUES (138,'WebGUI',6,'Ja');
INSERT INTO international VALUES (139,'WebGUI',6,'Nej');
INSERT INTO international VALUES (140,'WebGUI',6,'Redigera övriga inställningar');
INSERT INTO international VALUES (141,'WebGUI',6,'Not Found Page');
INSERT INTO international VALUES (142,'WebGUI',6,'Session Timeout');
INSERT INTO international VALUES (143,'WebGUI',6,'Kontrolera inställningar');
INSERT INTO international VALUES (144,'WebGUI',6,'Visa statistik.');
INSERT INTO international VALUES (145,'WebGUI',6,'WebGUI Build Version');
INSERT INTO international VALUES (146,'WebGUI',6,'Aktiva sessioner');
INSERT INTO international VALUES (147,'WebGUI',6,'Sidor');
INSERT INTO international VALUES (148,'WebGUI',6,'Wobjects');
INSERT INTO international VALUES (149,'WebGUI',6,'Användare');
INSERT INTO international VALUES (151,'WebGUI',6,'Stil namn');
INSERT INTO international VALUES (501,'WebGUI',1,'Body');
INSERT INTO international VALUES (154,'WebGUI',6,'Stil schema (Style Sheet)');
INSERT INTO international VALUES (155,'WebGUI',6,'Är du säker på att du vill radera denna stil och vilket resulterar i att alla sidor som använder den stilen kommer använda \"Fail Safe\" stilen?');
INSERT INTO international VALUES (156,'WebGUI',6,'Redigera stil');
INSERT INTO international VALUES (157,'WebGUI',6,'Stilar');
INSERT INTO international VALUES (158,'WebGUI',6,'Lägg till en ny stil.');
INSERT INTO international VALUES (159,'WebGUI',6,'Medelande log');
INSERT INTO international VALUES (160,'WebGUI',6,'Inlagt den');
INSERT INTO international VALUES (161,'WebGUI',6,'Skrivet av');
INSERT INTO international VALUES (162,'WebGUI',6,'Är du säker på att du vill ta bort allt ur skräpkorgen?');
INSERT INTO international VALUES (163,'WebGUI',6,'Lägg till användare');
INSERT INTO international VALUES (164,'WebGUI',6,'Autentiserings metod');
INSERT INTO international VALUES (165,'WebGUI',6,'LDAP URL');
INSERT INTO international VALUES (166,'WebGUI',6,'Connect DN');
INSERT INTO international VALUES (167,'WebGUI',6,'Är du absolut säker att du vill radera denna användare? Var medveten om att all information om denna användare kommer att vara permanent förlorade om du fortsätter.');
INSERT INTO international VALUES (168,'WebGUI',6,'Redigera Användare');
INSERT INTO international VALUES (169,'WebGUI',6,'Lägg till en ny användare.');
INSERT INTO international VALUES (170,'WebGUI',6,'sök');
INSERT INTO international VALUES (171,'WebGUI',6,'rich edit');
INSERT INTO international VALUES (174,'WebGUI',6,'Visa titel?');
INSERT INTO international VALUES (175,'WebGUI',6,'Berarbeta makron?');
INSERT INTO international VALUES (228,'WebGUI',6,'Redigerar Meddelande...');
INSERT INTO international VALUES (229,'WebGUI',6,'Subject');
INSERT INTO international VALUES (230,'WebGUI',6,'Meddelande');
INSERT INTO international VALUES (231,'WebGUI',6,'Skickar nytt meddelande...');
INSERT INTO international VALUES (232,'WebGUI',6,'no subject');
INSERT INTO international VALUES (233,'WebGUI',6,'(eom)');
INSERT INTO international VALUES (234,'WebGUI',6,'Skickar svar...');
INSERT INTO international VALUES (237,'WebGUI',6,'Subject:');
INSERT INTO international VALUES (238,'WebGUI',6,'Författare:');
INSERT INTO international VALUES (239,'WebGUI',6,'Datum:');
INSERT INTO international VALUES (240,'WebGUI',6,'Meddelande ID:');
INSERT INTO international VALUES (244,'WebGUI',6,'Författare');
INSERT INTO international VALUES (245,'WebGUI',6,'Datum');
INSERT INTO international VALUES (304,'WebGUI',6,'Språk');
INSERT INTO international VALUES (306,'WebGUI',6,'Username Binding');
INSERT INTO international VALUES (307,'WebGUI',6,'Använd den vanliga meta tagen?');
INSERT INTO international VALUES (308,'WebGUI',6,'Redigera profilinställningar');
INSERT INTO international VALUES (309,'WebGUI',6,'Tillåt riktigt namn?');
INSERT INTO international VALUES (310,'WebGUI',6,'Tillåt extra kontaktinformation?');
INSERT INTO international VALUES (311,'WebGUI',6,'Tillåt heminformation?');
INSERT INTO international VALUES (312,'WebGUI',6,'Tillåt företagsinformation?');
INSERT INTO international VALUES (313,'WebGUI',6,'Tillåt extra informaiton?');
INSERT INTO international VALUES (314,'WebGUI',6,'Förnamn');
INSERT INTO international VALUES (315,'WebGUI',6,'Mellannamn');
INSERT INTO international VALUES (316,'WebGUI',6,'Efternamn');
INSERT INTO international VALUES (317,'WebGUI',6,'ICQ UIN');
INSERT INTO international VALUES (318,'WebGUI',6,'AIM Id');
INSERT INTO international VALUES (319,'WebGUI',6,'MSN Messenger Id');
INSERT INTO international VALUES (320,'WebGUI',6,'Yahoo! Messenger Id');
INSERT INTO international VALUES (321,'WebGUI',6,'Mobil nummer');
INSERT INTO international VALUES (322,'WebGUI',6,'Personsökare');
INSERT INTO international VALUES (323,'WebGUI',6,'Hem adress');
INSERT INTO international VALUES (324,'WebGUI',6,'Hem stad');
INSERT INTO international VALUES (325,'WebGUI',6,'Hem län');
INSERT INTO international VALUES (326,'WebGUI',6,'Hem postnummer');
INSERT INTO international VALUES (327,'WebGUI',6,'Hem land');
INSERT INTO international VALUES (328,'WebGUI',6,'Hem telefon');
INSERT INTO international VALUES (329,'WebGUI',6,'Arbets adress');
INSERT INTO international VALUES (330,'WebGUI',6,'Arbets stad');
INSERT INTO international VALUES (331,'WebGUI',6,'Arbets län');
INSERT INTO international VALUES (332,'WebGUI',6,'Arbets postnummer');
INSERT INTO international VALUES (333,'WebGUI',6,'Arbets land');
INSERT INTO international VALUES (334,'WebGUI',6,'Arbets telefon');
INSERT INTO international VALUES (335,'WebGUI',6,'Kön');
INSERT INTO international VALUES (336,'WebGUI',6,'Födelsedatum');
INSERT INTO international VALUES (337,'WebGUI',6,'Hemside URL');
INSERT INTO international VALUES (338,'WebGUI',6,'Redigera profil');
INSERT INTO international VALUES (339,'WebGUI',6,'Man');
INSERT INTO international VALUES (340,'WebGUI',6,'Kvinna');
INSERT INTO international VALUES (341,'WebGUI',6,'Redigera profil.');
INSERT INTO international VALUES (342,'WebGUI',6,'Redigera kontoinformation.');
INSERT INTO international VALUES (343,'WebGUI',6,'Visa profil.');
INSERT INTO international VALUES (345,'WebGUI',6,'Inte en medlem');
INSERT INTO international VALUES (346,'WebGUI',6,'Denna användare är inte längre medlem på vår site. Vi har ingen vidare information om användaren.');
INSERT INTO international VALUES (347,'WebGUI',6,'Visa profilen för');
INSERT INTO international VALUES (348,'WebGUI',6,'Namn');
INSERT INTO international VALUES (349,'WebGUI',6,'Senaste tillgängliga version');
INSERT INTO international VALUES (350,'WebGUI',6,'Avslutad');
INSERT INTO international VALUES (351,'WebGUI',6,'Medelandelog Post');
INSERT INTO international VALUES (352,'WebGUI',6,'Skapat datum');
INSERT INTO international VALUES (353,'WebGUI',6,'Du har inga nya logmedelanden just nu.');
INSERT INTO international VALUES (354,'WebGUI',6,'Visa medelande log.');
INSERT INTO international VALUES (355,'WebGUI',6,'Standard');
INSERT INTO international VALUES (356,'WebGUI',6,'Mall');
INSERT INTO international VALUES (357,'WebGUI',6,'Nyheter');
INSERT INTO international VALUES (358,'WebGUI',6,'Vänster kolumn');
INSERT INTO international VALUES (359,'WebGUI',6,'Höger kolumn');
INSERT INTO international VALUES (360,'WebGUI',6,'En över tre');
INSERT INTO international VALUES (361,'WebGUI',6,'Tre över en');
INSERT INTO international VALUES (362,'WebGUI',6,'SidaVidSida');
INSERT INTO international VALUES (363,'WebGUI',6,'Mall position');
INSERT INTO international VALUES (364,'WebGUI',6,'Sök');
INSERT INTO international VALUES (365,'WebGUI',6,'Sökresultaten..');
INSERT INTO international VALUES (366,'WebGUI',6,'Inga sidor hittades som stämde med din förfrågan.');
INSERT INTO international VALUES (368,'WebGUI',6,'Lägg till en ny grupp till denna användare.');
INSERT INTO international VALUES (369,'WebGUI',6,'Bästföre datum');
INSERT INTO international VALUES (370,'WebGUI',6,'Redigera gruppering');
INSERT INTO international VALUES (371,'WebGUI',6,'Lägg till gruppering');
INSERT INTO international VALUES (372,'WebGUI',6,'Redigera Användares Grupper');
INSERT INTO international VALUES (374,'WebGUI',6,'Hantera paket.');
INSERT INTO international VALUES (375,'WebGUI',6,'Välj ett paket att använda');
INSERT INTO international VALUES (376,'WebGUI',6,'Paket');
INSERT INTO international VALUES (377,'WebGUI',6,'Inga paket har definierats av din packet hanterare eller administratör.');
INSERT INTO international VALUES (11,'Poll',6,'Rösta!');
INSERT INTO international VALUES (31,'UserSubmission',6,'Inehåll');
INSERT INTO international VALUES (32,'UserSubmission',6,'Bild');
INSERT INTO international VALUES (33,'UserSubmission',6,'Bilag');
INSERT INTO international VALUES (34,'UserSubmission',6,'Konvertera radbrytningar');
INSERT INTO international VALUES (35,'UserSubmission',6,'Titel');
INSERT INTO international VALUES (36,'UserSubmission',6,'Radera fil.');
INSERT INTO international VALUES (378,'WebGUI',6,'Användar ID');
INSERT INTO international VALUES (379,'WebGUI',6,'Grupp ID');
INSERT INTO international VALUES (380,'WebGUI',6,'Stil ID');
INSERT INTO international VALUES (381,'WebGUI',6,'WebGUI fick in en felformulerad förfrågan och kunde inte fortsätta. Oftast beror detta på ovanliga tecken som skickas från ett formulär. Du kan försöka med att gå tillbaka och försöka igen.');
INSERT INTO international VALUES (1,'DownloadManager',6,'Filhanterare');
INSERT INTO international VALUES (2,'DownloadManager',6,'Lägg till en Filhanterare');
INSERT INTO international VALUES (3,'DownloadManager',6,'Fortsätt med att lägga till fil?');
INSERT INTO international VALUES (4,'DownloadManager',6,'Läggtill Nedladdning');
INSERT INTO international VALUES (5,'DownloadManager',6,'Fil Titel');
INSERT INTO international VALUES (6,'DownloadManager',6,'Ladda ned fil');
INSERT INTO international VALUES (7,'DownloadManager',6,'Grupp för nedladdning');
INSERT INTO international VALUES (8,'DownloadManager',6,'Kort Beskrivning');
INSERT INTO international VALUES (9,'DownloadManager',6,'Redigera Filhanterare');
INSERT INTO international VALUES (10,'DownloadManager',6,'Redigera Nedladdning');
INSERT INTO international VALUES (11,'DownloadManager',6,'Lägg till en ny nedladdning.');
INSERT INTO international VALUES (12,'DownloadManager',6,'Är du säker på att du vill ta bort denna nedladdning?');
INSERT INTO international VALUES (13,'DownloadManager',6,'Radera');
INSERT INTO international VALUES (14,'DownloadManager',6,'Fil');
INSERT INTO international VALUES (15,'DownloadManager',6,'Beskrivning');
INSERT INTO international VALUES (16,'DownloadManager',6,'Uppladat den');
INSERT INTO international VALUES (15,'Article',6,'Höger');
INSERT INTO international VALUES (16,'Article',6,'Vänster');
INSERT INTO international VALUES (17,'Article',6,'Centrera');
INSERT INTO international VALUES (37,'UserSubmission',6,'Radera');
INSERT INTO international VALUES (13,'SQLReport',6,'Konvertera radbrytning?');
INSERT INTO international VALUES (17,'DownloadManager',6,'Alternativ Version #1');
INSERT INTO international VALUES (18,'DownloadManager',6,'Alternativ Version #2');
INSERT INTO international VALUES (19,'DownloadManager',6,'Du har inga filer att ladda ned.');
INSERT INTO international VALUES (14,'EventsCalendar',6,'Start datum');
INSERT INTO international VALUES (15,'EventsCalendar',6,'Slut datum');
INSERT INTO international VALUES (20,'DownloadManager',6,'Sidbrytning efter');
INSERT INTO international VALUES (14,'SQLReport',6,'Sidbrytning efter');
INSERT INTO international VALUES (16,'EventsCalendar',6,'Kalender utseende');
INSERT INTO international VALUES (17,'EventsCalendar',6,'Lista');
INSERT INTO international VALUES (18,'EventsCalendar',6,'Calendar Month');
INSERT INTO international VALUES (19,'EventsCalendar',6,'Sidbrytning efter');
INSERT INTO international VALUES (354,'WebGUI',1,'View Inbox.');
INSERT INTO international VALUES (383,'WebGUI',6,'Namn');
INSERT INTO international VALUES (384,'WebGUI',6,'Fil');
INSERT INTO international VALUES (385,'WebGUI',6,'Parametrar');
INSERT INTO international VALUES (386,'WebGUI',6,'Redigera Bild');
INSERT INTO international VALUES (387,'WebGUI',6,'Uppladat av');
INSERT INTO international VALUES (388,'WebGUI',6,'Uppladat den');
INSERT INTO international VALUES (389,'WebGUI',6,'Bild ID');
INSERT INTO international VALUES (390,'WebGUI',6,'Visar bild...');
INSERT INTO international VALUES (391,'WebGUI',6,'Radera');
INSERT INTO international VALUES (392,'WebGUI',6,'Är du säker på att du vill radera denna bild?');
INSERT INTO international VALUES (393,'WebGUI',6,'Hantera Bilder');
INSERT INTO international VALUES (394,'WebGUI',6,'Hantera bilder.');
INSERT INTO international VALUES (395,'WebGUI',6,'Lägg till en ny bild.');
INSERT INTO international VALUES (396,'WebGUI',6,'Visa bild');
INSERT INTO international VALUES (397,'WebGUI',6,'Tillbaka till bildlistan.');
INSERT INTO international VALUES (398,'WebGUI',6,'Dokument Typ Deklaration');
INSERT INTO international VALUES (399,'WebGUI',6,'Validera denna sida.');
INSERT INTO international VALUES (400,'WebGUI',6,'Blokera Proxy Caching');
INSERT INTO international VALUES (401,'WebGUI',6,'Är du säker på att du vill radera medelandet och alla undermedelanden i denna tråd?');
INSERT INTO international VALUES (565,'WebGUI',6,'Vem kan moderera?');
INSERT INTO international VALUES (22,'MessageBoard',6,'Radera Medelandet');
INSERT INTO international VALUES (402,'WebGUI',6,'Medelandet du frågade efter existerar inte.');
INSERT INTO international VALUES (403,'WebGUI',6,'Föredrar att inte säga.');
INSERT INTO international VALUES (405,'WebGUI',6,'Sista sidan');
INSERT INTO international VALUES (407,'WebGUI',6,'Klicka här för att registrera.');
INSERT INTO international VALUES (15,'SQLReport',6,'Förbearbeta macron vid förfrågan?');
INSERT INTO international VALUES (16,'SQLReport',6,'Debug?');
INSERT INTO international VALUES (17,'SQLReport',6,'&lt;b&gt;Debug:&lt;/b&gt; Förfrågan(query):');
INSERT INTO international VALUES (18,'SQLReport',6,'Det fanns inga resultat för denna förfrågan.');
INSERT INTO international VALUES (408,'WebGUI',6,'Hantera bassidor(Roots)');
INSERT INTO international VALUES (409,'WebGUI',6,'Lägg till en ny bassida.');
INSERT INTO international VALUES (410,'WebGUI',6,'Hantera bassidor.');
INSERT INTO international VALUES (411,'WebGUI',6,'Huvud titel');
INSERT INTO international VALUES (412,'WebGUI',6,'Synopsis');
INSERT INTO international VALUES (9,'SiteMap',6,'Visa synopsis?');
INSERT INTO international VALUES (18,'Article',6,'Tillåt diskusion');
INSERT INTO international VALUES (6,'Product',1,'Edit Product');
INSERT INTO international VALUES (4,'Product',1,'Are you certain you wish to delete the relationship to this related product?');
INSERT INTO international VALUES (22,'Article',6,'Författare');
INSERT INTO international VALUES (23,'Article',6,'Datum');
INSERT INTO international VALUES (24,'Article',6,'Skicka svar');
INSERT INTO international VALUES (578,'WebGUI',1,'You have a pending message to approve.');
INSERT INTO international VALUES (27,'Article',6,'Tillbaka till artikel');
INSERT INTO international VALUES (28,'Article',6,'Visa svar');
INSERT INTO international VALUES (54,'Product',1,'Benefits');
INSERT INTO international VALUES (416,'WebGUI',6,'&lt;h1&gt;Problem Med Förfrågan&lt;/h1&gt;\r\nVi har stött på ett problem med din förfrågan. Var vänlig och gå tillbaka och fösök igen. Om problemet kvarstår var vänlig och rapportera detta till oss med tid och datum samt vad du försökte göra.');
INSERT INTO international VALUES (417,'WebGUI',6,'&lt;h1&gt;Säkerhets Överträdelse&lt;/h1&gt;\r\nDu försökte att komma åt en wobject som inte associeras med denna sida. Denna incident har rapporterats.');
INSERT INTO international VALUES (418,'WebGUI',6,'Ta bort inmatad HTML');
INSERT INTO international VALUES (419,'WebGUI',6,'Ta bort alla taggar.');
INSERT INTO international VALUES (420,'WebGUI',6,'Lämna som den är.');
INSERT INTO international VALUES (421,'WebGUI',6,'Ta bort allt utom grundformateringen.');
INSERT INTO international VALUES (422,'WebGUI',6,'&lt;h1&gt;Inloggning misslyckades&lt;/h1&gt;\r\nInformationen du gav stämmer inte med kontot.');
INSERT INTO international VALUES (423,'WebGUI',6,'Visa aktiva sessioner.');
INSERT INTO international VALUES (424,'WebGUI',6,'Visa logginhistorik.');
INSERT INTO international VALUES (425,'WebGUI',6,'Aktiva sessioner');
INSERT INTO international VALUES (426,'WebGUI',6,'Inloggnings historik');
INSERT INTO international VALUES (427,'WebGUI',6,'Stilar');
INSERT INTO international VALUES (428,'WebGUI',6,'Användar (ID)');
INSERT INTO international VALUES (429,'WebGUI',6,'Inloggnings tid');
INSERT INTO international VALUES (430,'WebGUI',6,'Senaste sida visad');
INSERT INTO international VALUES (431,'WebGUI',6,'IP Adress');
INSERT INTO international VALUES (432,'WebGUI',6,'Bäst före');
INSERT INTO international VALUES (433,'WebGUI',6,'Användar Klient (Browser)');
INSERT INTO international VALUES (434,'WebGUI',6,'Status');
INSERT INTO international VALUES (435,'WebGUI',6,'Sessions signatur');
INSERT INTO international VALUES (436,'WebGUI',6,'Avsluta session');
INSERT INTO international VALUES (437,'WebGUI',6,'Statistik');
INSERT INTO international VALUES (438,'WebGUI',6,'Ditt namn');
INSERT INTO international VALUES (439,'WebGUI',6,'Personlig Information');
INSERT INTO international VALUES (440,'WebGUI',6,'Kontakt Information');
INSERT INTO international VALUES (441,'WebGUI',6,'E-Mail till personsökar-gateway');
INSERT INTO international VALUES (442,'WebGUI',6,'Arbets Information');
INSERT INTO international VALUES (443,'WebGUI',6,'Hem Information');
INSERT INTO international VALUES (444,'WebGUI',6,'Demografisk Information');
INSERT INTO international VALUES (445,'WebGUI',6,'Inställningar');
INSERT INTO international VALUES (446,'WebGUI',6,'Arbetets Website');
INSERT INTO international VALUES (447,'WebGUI',6,'Hantera sidträd.');
INSERT INTO international VALUES (448,'WebGUI',6,'Sid träd');
INSERT INTO international VALUES (449,'WebGUI',6,'Övrig information');
INSERT INTO international VALUES (450,'WebGUI',6,'Jobb Namn (Namn på företaget)');
INSERT INTO international VALUES (451,'WebGUI',6,'är obligatoriskt.');
INSERT INTO international VALUES (452,'WebGUI',6,'Var god vänta...');
INSERT INTO international VALUES (453,'WebGUI',6,'Skapad den');
INSERT INTO international VALUES (454,'WebGUI',6,'Senast Uppdaterad');
INSERT INTO international VALUES (455,'WebGUI',6,'Redigera Användar Profil');
INSERT INTO international VALUES (456,'WebGUI',6,'Tillbaka till användarlistan.');
INSERT INTO international VALUES (457,'WebGUI',6,'Redigera denna användares konto.');
INSERT INTO international VALUES (458,'WebGUI',6,'Redigera denna användares grupper.');
INSERT INTO international VALUES (459,'WebGUI',6,'Redigera denna användares profil.');
INSERT INTO international VALUES (460,'WebGUI',6,'Tidsoffset');
INSERT INTO international VALUES (461,'WebGUI',6,'Datum Format');
INSERT INTO international VALUES (462,'WebGUI',6,'Tids Format');
INSERT INTO international VALUES (463,'WebGUI',6,'Text Fält Rader');
INSERT INTO international VALUES (464,'WebGUI',6,'Text Fält Kolumner');
INSERT INTO international VALUES (465,'WebGUI',6,'Text Box Storlek');
INSERT INTO international VALUES (466,'WebGUI',6,'Är du säker på att du vill ta bort denna kategori och flytta alla dess attribut till Övrigt kattegorin.');
INSERT INTO international VALUES (467,'WebGUI',6,'Är du säker på att du vill ta bort detta attribut och all användar data som finns i det ?');
INSERT INTO international VALUES (468,'WebGUI',1,'Edit User Profile Category');
INSERT INTO international VALUES (469,'WebGUI',6,'Id');
INSERT INTO international VALUES (470,'WebGUI',6,'Namn');
INSERT INTO international VALUES (159,'WebGUI',1,'Inbox');
INSERT INTO international VALUES (472,'WebGUI',6,'Märke');
INSERT INTO international VALUES (473,'WebGUI',6,'Synligt?');
INSERT INTO international VALUES (474,'WebGUI',6,'Obligatoriskt?');
INSERT INTO international VALUES (475,'WebGUI',6,'Text');
INSERT INTO international VALUES (476,'WebGUI',6,'Text Område');
INSERT INTO international VALUES (477,'WebGUI',6,'HTML Område');
INSERT INTO international VALUES (478,'WebGUI',6,'URL');
INSERT INTO international VALUES (479,'WebGUI',6,'Datum');
INSERT INTO international VALUES (480,'WebGUI',6,'Email adress');
INSERT INTO international VALUES (481,'WebGUI',6,'Telefånnummer');
INSERT INTO international VALUES (482,'WebGUI',6,'Nummer (Heltal)');
INSERT INTO international VALUES (483,'WebGUI',6,'Ja eller Nej');
INSERT INTO international VALUES (484,'WebGUI',6,'Vallista');
INSERT INTO international VALUES (485,'WebGUI',6,'Boolean (Kryssbox)');
INSERT INTO international VALUES (486,'WebGUI',6,'Data typ');
INSERT INTO international VALUES (487,'WebGUI',6,'Möjliga värden');
INSERT INTO international VALUES (488,'WebGUI',6,'Standar värden');
INSERT INTO international VALUES (489,'WebGUI',6,'Profil kategorier.');
INSERT INTO international VALUES (490,'WebGUI',6,'Lägg till en profilkategori.');
INSERT INTO international VALUES (491,'WebGUI',6,'Lägg till profilattribut.');
INSERT INTO international VALUES (492,'WebGUI',6,'Profil attribut lista.');
INSERT INTO international VALUES (493,'WebGUI',6,'Tillbaka till siten.');
INSERT INTO international VALUES (507,'WebGUI',1,'Edit Template');
INSERT INTO international VALUES (508,'WebGUI',1,'Manage templates.');
INSERT INTO international VALUES (39,'UserSubmission',1,'Post a Reply');
INSERT INTO international VALUES (40,'UserSubmission',1,'Posted by');
INSERT INTO international VALUES (41,'UserSubmission',1,'Date');
INSERT INTO international VALUES (8,'Product',1,'Product Image 2');
INSERT INTO international VALUES (1,'Product',1,'Product');
INSERT INTO international VALUES (45,'UserSubmission',1,'Return to Submission');
INSERT INTO international VALUES (46,'UserSubmission',1,'Read more...');
INSERT INTO international VALUES (47,'UserSubmission',1,'Post a Response');
INSERT INTO international VALUES (48,'UserSubmission',1,'Allow discussion?');
INSERT INTO international VALUES (571,'WebGUI',1,'Unlock Thread');
INSERT INTO international VALUES (569,'WebGUI',1,'Moderation Type');
INSERT INTO international VALUES (567,'WebGUI',1,'Pre-emptive');
INSERT INTO international VALUES (51,'UserSubmission',1,'Display thumbnails?');
INSERT INTO international VALUES (52,'UserSubmission',1,'Thumbnail');
INSERT INTO international VALUES (53,'UserSubmission',1,'Layout');
INSERT INTO international VALUES (54,'UserSubmission',1,'Web Log');
INSERT INTO international VALUES (55,'UserSubmission',1,'Traditional');
INSERT INTO international VALUES (56,'UserSubmission',1,'Photo Gallery');
INSERT INTO international VALUES (57,'UserSubmission',1,'Responses');
INSERT INTO international VALUES (11,'FAQ',1,'Turn TOC on?');
INSERT INTO international VALUES (12,'FAQ',1,'Turn Q/A on?');
INSERT INTO international VALUES (13,'FAQ',1,'Turn [top] link on?');
INSERT INTO international VALUES (14,'FAQ',1,'Q');
INSERT INTO international VALUES (15,'FAQ',1,'A');
INSERT INTO international VALUES (16,'FAQ',1,'[top]');
INSERT INTO international VALUES (509,'WebGUI',1,'Discussion Layout');
INSERT INTO international VALUES (510,'WebGUI',1,'Flat');
INSERT INTO international VALUES (511,'WebGUI',1,'Threaded');
INSERT INTO international VALUES (512,'WebGUI',1,'Next Thread');
INSERT INTO international VALUES (513,'WebGUI',1,'Previous Thread');
INSERT INTO international VALUES (8,'Article',0,'henvisning URL');
INSERT INTO international VALUES (9,'Article',0,'Vis besvarelser');
INSERT INTO international VALUES (10,'Article',0,'Konverter linieskift?');
INSERT INTO international VALUES (11,'Article',0,'\"(Kontroller at du ikke tilføjer &lt;br&gt; manuelt.)\"');
INSERT INTO international VALUES (12,'Article',0,'rediger artikel');
INSERT INTO international VALUES (13,'Article',0,'Slet');
INSERT INTO international VALUES (14,'Article',0,'Placer billede');
INSERT INTO international VALUES (15,'Article',0,'Højre');
INSERT INTO international VALUES (16,'Article',0,'Venstre');
INSERT INTO international VALUES (17,'Article',0,'Centreret');
INSERT INTO international VALUES (18,'Article',0,'Tillad diskussion?');
INSERT INTO international VALUES (3,'Product',1,'Are you certain you wish to delete this feature?');
INSERT INTO international VALUES (22,'Article',0,'Forfatter');
INSERT INTO international VALUES (23,'Article',0,'Dato');
INSERT INTO international VALUES (24,'Article',0,'Send respons');
INSERT INTO international VALUES (580,'WebGUI',1,'Your message has been denied.');
INSERT INTO international VALUES (27,'Article',0,'Tilbage til artikel');
INSERT INTO international VALUES (28,'Article',0,'Vis respons');
INSERT INTO international VALUES (1,'DownloadManager',0,'Download Manager');
INSERT INTO international VALUES (2,'DownloadManager',0,'Tilføj Download Manager');
INSERT INTO international VALUES (3,'DownloadManager',0,'Fortsæt med at tilføje fil?');
INSERT INTO international VALUES (4,'DownloadManager',0,'Tilføj Download');
INSERT INTO international VALUES (5,'DownloadManager',0,'Navn på fil');
INSERT INTO international VALUES (6,'DownloadManager',0,'Hent fil');
INSERT INTO international VALUES (7,'DownloadManager',0,'Gruppe til Download');
INSERT INTO international VALUES (8,'DownloadManager',0,'Kort beskrivelse');
INSERT INTO international VALUES (9,'DownloadManager',0,'rediger Download Manager');
INSERT INTO international VALUES (10,'DownloadManager',0,'rediger Download  ');
INSERT INTO international VALUES (11,'DownloadManager',0,'Tilføj ny Download');
INSERT INTO international VALUES (12,'DownloadManager',0,'Er du sikker på du vil slette denne Download?');
INSERT INTO international VALUES (13,'DownloadManager',0,'Slet tilføjet fil?');
INSERT INTO international VALUES (14,'DownloadManager',0,'Fil');
INSERT INTO international VALUES (15,'DownloadManager',0,'Beskrivelse');
INSERT INTO international VALUES (16,'DownloadManager',0,'Oprettelsesdato');
INSERT INTO international VALUES (17,'DownloadManager',0,'Alternativ version nr. 1');
INSERT INTO international VALUES (18,'DownloadManager',0,'Alternativ version nr. 2');
INSERT INTO international VALUES (19,'DownloadManager',0,'Du har ikke nogen filer til Download');
INSERT INTO international VALUES (20,'DownloadManager',0,'Slet efter');
INSERT INTO international VALUES (21,'DownloadManager',0,'Hvis miniature?');
INSERT INTO international VALUES (1,'EventsCalendar',0,'Fortsæt med at tilføje begivenhed?');
INSERT INTO international VALUES (2,'EventsCalendar',0,'Begivenheds kalender');
INSERT INTO international VALUES (3,'EventsCalendar',0,'Tilføj begivenheds kalender');
INSERT INTO international VALUES (4,'EventsCalendar',0,'Begivenhed sker én gang');
INSERT INTO international VALUES (700,'WebGUI',0,'dag');
INSERT INTO international VALUES (701,'WebGUI',0,'uge');
INSERT INTO international VALUES (7,'EventsCalendar',0,'Tilføj begivenhed ');
INSERT INTO international VALUES (8,'EventsCalendar',0,'Gentages hver');
INSERT INTO international VALUES (9,'EventsCalendar',0,'indtil');
INSERT INTO international VALUES (61,'Product',1,'Product Template');
INSERT INTO international VALUES (12,'EventsCalendar',0,'rediger begivenheds kalender');
INSERT INTO international VALUES (13,'EventsCalendar',0,'rediger begivenhed ');
INSERT INTO international VALUES (14,'EventsCalendar',0,'Fra dato');
INSERT INTO international VALUES (15,'EventsCalendar',0,'Til dato');
INSERT INTO international VALUES (16,'EventsCalendar',0,'Kalender layout');
INSERT INTO international VALUES (17,'EventsCalendar',0,'Liste');
INSERT INTO international VALUES (18,'EventsCalendar',0,'Calendar Month');
INSERT INTO international VALUES (19,'EventsCalendar',0,'Slet efter ');
INSERT INTO international VALUES (1,'ExtraColumn',0,'Ekstra kolonne');
INSERT INTO international VALUES (2,'ExtraColumn',0,'Tilføj ekstra kolonne');
INSERT INTO international VALUES (3,'ExtraColumn',0,'Mellemrum');
INSERT INTO international VALUES (4,'ExtraColumn',0,'Bredde');
INSERT INTO international VALUES (5,'ExtraColumn',0,'stilarter klasse');
INSERT INTO international VALUES (6,'ExtraColumn',0,'rediger ekstra kolonne');
INSERT INTO international VALUES (1,'FAQ',0,'Fortsæt med at tilføje spørgsmål?');
INSERT INTO international VALUES (2,'FAQ',0,'Ofte stillede spørgsmål (F.A.Q.)');
INSERT INTO international VALUES (3,'FAQ',0,'Tilføj F.A.Q.');
INSERT INTO international VALUES (4,'FAQ',0,'Tilføj spørgsmål');
INSERT INTO international VALUES (5,'FAQ',0,'Spørgsmål');
INSERT INTO international VALUES (6,'FAQ',0,'Svar');
INSERT INTO international VALUES (7,'FAQ',0,'Er du sikker på du vil slette dette spørgsmål');
INSERT INTO international VALUES (8,'FAQ',0,'Rediger F.A.Q.');
INSERT INTO international VALUES (9,'FAQ',0,'Tilføj nyt spørgsmål');
INSERT INTO international VALUES (10,'FAQ',0,'rediger spørgsmål');
INSERT INTO international VALUES (1,'Item',0,'henvisning URL');
INSERT INTO international VALUES (2,'Item',0,'Vedhæft');
INSERT INTO international VALUES (3,'Item',0,'Slet vedhæft');
INSERT INTO international VALUES (4,'Item',0,'Item');
INSERT INTO international VALUES (5,'Item',0,'Hent vedhæftet');
INSERT INTO international VALUES (1,'LinkList',0,'Indryk');
INSERT INTO international VALUES (2,'LinkList',0,'Linie afstand');
INSERT INTO international VALUES (3,'LinkList',0,'Skal der åbnes i nyt vindue?');
INSERT INTO international VALUES (4,'LinkList',0,'Punkt');
INSERT INTO international VALUES (5,'LinkList',0,'Fortsæt med at tilføje henvisning');
INSERT INTO international VALUES (6,'LinkList',0,'Liste over henvisning');
INSERT INTO international VALUES (7,'LinkList',0,'Tilføj henvisning');
INSERT INTO international VALUES (8,'LinkList',0,'URL');
INSERT INTO international VALUES (9,'LinkList',0,'Er du sikker på du vil slette denne henvisning');
INSERT INTO international VALUES (10,'LinkList',0,'Rediger henvisnings liste');
INSERT INTO international VALUES (11,'LinkList',0,'Tilføj henvisnings liste');
INSERT INTO international VALUES (12,'LinkList',0,'Rediger henvisning  ');
INSERT INTO international VALUES (13,'LinkList',0,'Tilføj ny henvisning');
INSERT INTO international VALUES (1,'MessageBoard',0,'Tilføj opslagstavle');
INSERT INTO international VALUES (2,'MessageBoard',0,'Opslagstavle');
INSERT INTO international VALUES (564,'WebGUI',0,'Hvem kan komme med indlæg?');
INSERT INTO international VALUES (4,'MessageBoard',0,'Antal beskeder pr. side');
INSERT INTO international VALUES (566,'WebGUI',0,'Rediger Timeout');
INSERT INTO international VALUES (6,'MessageBoard',0,'Rediger opslagstavle');
INSERT INTO international VALUES (7,'MessageBoard',0,'Forfatter:');
INSERT INTO international VALUES (8,'MessageBoard',0,'Dato:');
INSERT INTO international VALUES (9,'MessageBoard',0,'Besked nr.:');
INSERT INTO international VALUES (10,'MessageBoard',0,'Forrige tråd');
INSERT INTO international VALUES (11,'MessageBoard',0,'Tilbage til oversigt');
INSERT INTO international VALUES (12,'MessageBoard',0,'Rediger meddelelses');
INSERT INTO international VALUES (577,'WebGUI',0,'Send respons');
INSERT INTO international VALUES (14,'MessageBoard',0,'Næste tråd');
INSERT INTO international VALUES (15,'MessageBoard',0,'Forfatter');
INSERT INTO international VALUES (16,'MessageBoard',0,'Dato');
INSERT INTO international VALUES (17,'MessageBoard',0,'Ny meddelelse');
INSERT INTO international VALUES (18,'MessageBoard',0,'Tråd startet');
INSERT INTO international VALUES (19,'MessageBoard',0,'Antal svar');
INSERT INTO international VALUES (20,'MessageBoard',0,'Seneste svar');
INSERT INTO international VALUES (565,'WebGUI',0,'Hvem kan moderere?');
INSERT INTO international VALUES (22,'MessageBoard',0,'Slet besked');
INSERT INTO international VALUES (1,'Poll',0,'Afstemning');
INSERT INTO international VALUES (2,'Poll',0,'Tilføj afstemning');
INSERT INTO international VALUES (3,'Poll',0,'Aktiv');
INSERT INTO international VALUES (4,'Poll',0,'Hvem kan stemme');
INSERT INTO international VALUES (5,'Poll',0,'Bredde på graf');
INSERT INTO international VALUES (6,'Poll',0,'Spørgsmål');
INSERT INTO international VALUES (7,'Poll',0,'Svar');
INSERT INTO international VALUES (8,'Poll',0,'(Indtast ét svar pr. linie. Ikke mere end 20.)');
INSERT INTO international VALUES (9,'Poll',0,'Rediger afstemning');
INSERT INTO international VALUES (10,'Poll',0,'Nulstil afstemning');
INSERT INTO international VALUES (11,'Poll',0,'Stem!');
INSERT INTO international VALUES (1,'SiteMap',0,'Tilføj Site oversigt');
INSERT INTO international VALUES (2,'SiteMap',0,'Site oversigt');
INSERT INTO international VALUES (3,'SiteMap',0,'Startende fra dette niveau');
INSERT INTO international VALUES (4,'SiteMap',0,'Dybde?');
INSERT INTO international VALUES (5,'SiteMap',0,'Rediger Site oversigt');
INSERT INTO international VALUES (6,'SiteMap',0,'Indryk');
INSERT INTO international VALUES (7,'SiteMap',0,'Punkt');
INSERT INTO international VALUES (8,'SiteMap',0,'Linie afstand');
INSERT INTO international VALUES (9,'SiteMap',0,'Vis synopsis?');
INSERT INTO international VALUES (1,'SQLReport',0,'SQL rapport');
INSERT INTO international VALUES (2,'SQLReport',0,'Tilføj SQL rapport');
INSERT INTO international VALUES (3,'SQLReport',0,'Rapport template');
INSERT INTO international VALUES (4,'SQLReport',0,'Query');
INSERT INTO international VALUES (5,'SQLReport',0,'DSN');
INSERT INTO international VALUES (6,'SQLReport',0,'Database bruger');
INSERT INTO international VALUES (7,'SQLReport',0,'Database Password');
INSERT INTO international VALUES (8,'SQLReport',0,'Rediger SQL rapport');
INSERT INTO international VALUES (9,'SQLReport',0,'<b>Debug:</b> Error: The DSN specified is of an improper format.');
INSERT INTO international VALUES (10,'SQLReport',0,'<b>Debug:</b> Error: The SQL specified is of an improper format.');
INSERT INTO international VALUES (11,'SQLReport',0,'<b>Debug:</b> Error: There was a problem with the query.');
INSERT INTO international VALUES (12,'SQLReport',0,'<b>Debug:</b> Error: Could not connect to the database.');
INSERT INTO international VALUES (13,'SQLReport',0,'Konverter linieskift?');
INSERT INTO international VALUES (14,'SQLReport',0,'Slet efter');
INSERT INTO international VALUES (15,'SQLReport',0,'Udfør makroer ved forespørgsel?');
INSERT INTO international VALUES (16,'SQLReport',0,'Debut?');
INSERT INTO international VALUES (17,'SQLReport',0,'<b>Debug:</b> Query:');
INSERT INTO international VALUES (18,'SQLReport',0,'Der var ikke nogen svar til denne forespørgsel!');
INSERT INTO international VALUES (1,'SyndicatedContent',0,'URL til RSS fil');
INSERT INTO international VALUES (2,'SyndicatedContent',0,'Syndicated Content');
INSERT INTO international VALUES (3,'SyndicatedContent',0,'Tilføj Syndicated Content');
INSERT INTO international VALUES (4,'SyndicatedContent',0,'Rediger Syndicated Content');
INSERT INTO international VALUES (5,'SyndicatedContent',0,'Sidst opdateret');
INSERT INTO international VALUES (6,'SyndicatedContent',0,'Gældende indhold');
INSERT INTO international VALUES (1,'UserSubmission',0,'Hvem kan godkende indlæg?');
INSERT INTO international VALUES (2,'UserSubmission',0,'Hvem kan tilføje indlæg?');
INSERT INTO international VALUES (3,'UserSubmission',0,'Du har nye indlæg til godkendelse');
INSERT INTO international VALUES (4,'UserSubmission',0,'Dit indlæg er godkendt');
INSERT INTO international VALUES (5,'UserSubmission',0,'Dit indlæg er afvist');
INSERT INTO international VALUES (6,'UserSubmission',0,'Antal indlæg pr. side');
INSERT INTO international VALUES (560,'WebGUI',0,'Godkendt');
INSERT INTO international VALUES (561,'WebGUI',0,'Afvist');
INSERT INTO international VALUES (562,'WebGUI',0,'Afventer');
INSERT INTO international VALUES (563,'WebGUI',0,'Default Status');
INSERT INTO international VALUES (11,'UserSubmission',0,'Tilføj indlæg');
INSERT INTO international VALUES (12,'UserSubmission',0,'(Kryds ikke hvis du laver et HTML indlæg.)');
INSERT INTO international VALUES (13,'UserSubmission',0,'Tilføjet dato');
INSERT INTO international VALUES (14,'UserSubmission',0,'Status');
INSERT INTO international VALUES (15,'UserSubmission',0,'Rediger/Slet');
INSERT INTO international VALUES (16,'UserSubmission',0,'Ingen titel');
INSERT INTO international VALUES (17,'UserSubmission',0,'Er du sikker på du vil slette dette indlæg?');
INSERT INTO international VALUES (18,'UserSubmission',0,'Rediger User Submission System');
INSERT INTO international VALUES (19,'UserSubmission',0,'Rediger indlæg');
INSERT INTO international VALUES (20,'UserSubmission',0,'Lav nyt indlæg');
INSERT INTO international VALUES (21,'UserSubmission',0,'Indsendt af');
INSERT INTO international VALUES (22,'UserSubmission',0,'Indsendt af:');
INSERT INTO international VALUES (23,'UserSubmission',0,'Indsendt dato:');
INSERT INTO international VALUES (572,'WebGUI',0,'Godkendt');
INSERT INTO international VALUES (573,'WebGUI',0,'Afvent ');
INSERT INTO international VALUES (574,'WebGUI',0,'Afvist');
INSERT INTO international VALUES (27,'UserSubmission',0,'Rediger');
INSERT INTO international VALUES (28,'UserSubmission',0,'Tilbage til Submission oversigt');
INSERT INTO international VALUES (29,'UserSubmission',0,'Bruger Indlæg');
INSERT INTO international VALUES (31,'UserSubmission',0,'Indhold');
INSERT INTO international VALUES (32,'UserSubmission',0,'Billede');
INSERT INTO international VALUES (33,'UserSubmission',0,'Tillæg');
INSERT INTO international VALUES (34,'UserSubmission',0,'Konverter linieskift?');
INSERT INTO international VALUES (35,'UserSubmission',0,'Titel');
INSERT INTO international VALUES (36,'UserSubmission',0,'Slet fil.');
INSERT INTO international VALUES (37,'UserSubmission',0,'Slet');
INSERT INTO international VALUES (1,'WebGUI',0,'Tilføj indhold');
INSERT INTO international VALUES (2,'WebGUI',0,'Side');
INSERT INTO international VALUES (3,'WebGUI',0,'Kopier fra udklipsholder');
INSERT INTO international VALUES (4,'WebGUI',0,'administrer indstillinger');
INSERT INTO international VALUES (5,'WebGUI',0,'administrer grupper');
INSERT INTO international VALUES (6,'WebGUI',0,'administrer Stilarter');
INSERT INTO international VALUES (7,'WebGUI',0,'administrer brugere');
INSERT INTO international VALUES (8,'WebGUI',0,'Vis side_ikke_fundet');
INSERT INTO international VALUES (9,'WebGUI',0,'Vis udklipsholder');
INSERT INTO international VALUES (10,'WebGUI',0,'administrer skraldespand');
INSERT INTO international VALUES (11,'WebGUI',0,'Tøm skraldespand');
INSERT INTO international VALUES (12,'WebGUI',0,'Slå administration fra');
INSERT INTO international VALUES (13,'WebGUI',0,'Vis hjælpe indeks');
INSERT INTO international VALUES (14,'WebGUI',0,'Vis afventende indlæg');
INSERT INTO international VALUES (15,'WebGUI',0,'Januar');
INSERT INTO international VALUES (16,'WebGUI',0,'Februar');
INSERT INTO international VALUES (17,'WebGUI',0,'Marts');
INSERT INTO international VALUES (18,'WebGUI',0,'April');
INSERT INTO international VALUES (19,'WebGUI',0,'Maj');
INSERT INTO international VALUES (20,'WebGUI',0,'Juni');
INSERT INTO international VALUES (21,'WebGUI',0,'Juli');
INSERT INTO international VALUES (22,'WebGUI',0,'August');
INSERT INTO international VALUES (23,'WebGUI',0,'September');
INSERT INTO international VALUES (24,'WebGUI',0,'Oktober');
INSERT INTO international VALUES (25,'WebGUI',0,'November');
INSERT INTO international VALUES (26,'WebGUI',0,'December');
INSERT INTO international VALUES (27,'WebGUI',0,'Søndag');
INSERT INTO international VALUES (28,'WebGUI',0,'Mandag');
INSERT INTO international VALUES (29,'WebGUI',0,'Tirsdag');
INSERT INTO international VALUES (30,'WebGUI',0,'Onsdag');
INSERT INTO international VALUES (31,'WebGUI',0,'Torsdag');
INSERT INTO international VALUES (32,'WebGUI',0,'Fredag');
INSERT INTO international VALUES (33,'WebGUI',0,'Lørdag');
INSERT INTO international VALUES (34,'WebGUI',0,'Sæt dato');
INSERT INTO international VALUES (35,'WebGUI',0,'Administrative funktioner');
INSERT INTO international VALUES (36,'WebGUI',0,'Du skal være administrator for at udføre denne funktion. Kontakt en af følgende personer der er administratorer:');
INSERT INTO international VALUES (37,'WebGUI',0,'Adgang nægtet!');
INSERT INTO international VALUES (38,'WebGUI',0,'\"Du har ikke nødvendige rettigheder til at udføre denne funktion. Venligst log in ^a(log in med en konto); med nødvendige rettigheder før du prøver dette.\"');
INSERT INTO international VALUES (39,'WebGUI',0,'Du har ikke rettigheder til at få adgang til denne side.');
INSERT INTO international VALUES (40,'WebGUI',0,'Vital komponent');
INSERT INTO international VALUES (41,'WebGUI',0,'DU forsøger at fjerne en VITAL system komponent. Hvis du fik lov til dette, ville systemet ikke virke mere …..');
INSERT INTO international VALUES (42,'WebGUI',0,'Venligst bekræft');
INSERT INTO international VALUES (43,'WebGUI',0,'Er du sikker på du vil slette dette indhold?');
INSERT INTO international VALUES (44,'WebGUI',0,'Ja, jeg er sikker!');
INSERT INTO international VALUES (45,'WebGUI',0,'Nej, jeg lavede en fejl');
INSERT INTO international VALUES (46,'WebGUI',0,'Min konto');
INSERT INTO international VALUES (47,'WebGUI',0,'Hjem');
INSERT INTO international VALUES (48,'WebGUI',0,'Hej');
INSERT INTO international VALUES (49,'WebGUI',0,'\"Klik <a href=\"\"^\\;?op=logout\"\">her</a> for at logge ud.\"');
INSERT INTO international VALUES (50,'WebGUI',0,'Brugernavn');
INSERT INTO international VALUES (51,'WebGUI',0,'Kodeord');
INSERT INTO international VALUES (52,'WebGUI',0,'Login');
INSERT INTO international VALUES (53,'WebGUI',0,'Print side');
INSERT INTO international VALUES (54,'WebGUI',0,'Opret konto');
INSERT INTO international VALUES (55,'WebGUI',0,'Kodeord (bekræft)');
INSERT INTO international VALUES (56,'WebGUI',0,'Email Adresse');
INSERT INTO international VALUES (57,'WebGUI',0,'Dette er kun nødvendigt hvis du bruger en funktion der kræver Email');
INSERT INTO international VALUES (58,'WebGUI',0,'Jeg har allerede en konto');
INSERT INTO international VALUES (59,'WebGUI',0,'Jeg har glemt mit kodeord (igen)');
INSERT INTO international VALUES (60,'WebGUI',0,'Er du sikker på du vil deaktivere din konto. Kontoen kan IKKE åbnes igen.');
INSERT INTO international VALUES (61,'WebGUI',0,'Opdater konto information');
INSERT INTO international VALUES (62,'WebGUI',0,'Gem');
INSERT INTO international VALUES (63,'WebGUI',0,'Slå administration til.');
INSERT INTO international VALUES (64,'WebGUI',0,'Log ud.');
INSERT INTO international VALUES (65,'WebGUI',0,'Venligst de-aktiver min konto permanent.');
INSERT INTO international VALUES (66,'WebGUI',0,'Log In');
INSERT INTO international VALUES (67,'WebGUI',0,'Opret ny konto');
INSERT INTO international VALUES (68,'WebGUI',0,'Konto informationen er ikke gyldig. Enten eksisterer kontoen ikke, eller også er brugernavn/kodeord forkert');
INSERT INTO international VALUES (69,'WebGUI',0,'Kontakt venligst systemadministratoren for yderligere hjælp!');
INSERT INTO international VALUES (70,'WebGUI',0,'Fejl');
INSERT INTO international VALUES (71,'WebGUI',0,'Genskab kodeord');
INSERT INTO international VALUES (72,'WebGUI',0,'Genskab  ');
INSERT INTO international VALUES (73,'WebGUI',0,'Log in.');
INSERT INTO international VALUES (74,'WebGUI',0,'Konto information.');
INSERT INTO international VALUES (75,'WebGUI',0,'Din konto information er sendt til den oplyste Email adresse');
INSERT INTO international VALUES (76,'WebGUI',0,'Email adressen er ikke registreret i systemet');
INSERT INTO international VALUES (77,'WebGUI',0,'Det brugernavn er desværre allerede brugt af en anden. Prøv evt. en af disse:');
INSERT INTO international VALUES (78,'WebGUI',0,'Du har indtastet to forskellige kodeord - prøv igen!');
INSERT INTO international VALUES (79,'WebGUI',0,'Kan ikke forbinde til LDAP server');
INSERT INTO international VALUES (80,'WebGUI',0,'Konto er nu oprettet!');
INSERT INTO international VALUES (81,'WebGUI',0,'Konto er nu opdateret.');
INSERT INTO international VALUES (82,'WebGUI',0,'Administrative funktioner');
INSERT INTO international VALUES (84,'WebGUI',0,'Gruppe navn');
INSERT INTO international VALUES (85,'WebGUI',0,'Beskrivelse');
INSERT INTO international VALUES (86,'WebGUI',0,'Er du sikker på du vil slette denne gruppe? - og dermed alle rettigheder der er knyttet hertil');
INSERT INTO international VALUES (87,'WebGUI',0,'Rediger gruppe');
INSERT INTO international VALUES (88,'WebGUI',0,'brugere i gruppe');
INSERT INTO international VALUES (89,'WebGUI',0,'Grupper');
INSERT INTO international VALUES (90,'WebGUI',0,'Tilføj gruppe');
INSERT INTO international VALUES (91,'WebGUI',0,'Forrige side');
INSERT INTO international VALUES (92,'WebGUI',0,'Næste side');
INSERT INTO international VALUES (93,'WebGUI',0,'Hjælp');
INSERT INTO international VALUES (94,'WebGUI',0,'Se også');
INSERT INTO international VALUES (95,'WebGUI',0,'Hjælpe indeks');
INSERT INTO international VALUES (98,'WebGUI',0,'Tilføj side');
INSERT INTO international VALUES (99,'WebGUI',0,'Titel');
INSERT INTO international VALUES (100,'WebGUI',0,'Meta Tags');
INSERT INTO international VALUES (101,'WebGUI',0,'Er du sikker på du vil slette denne side, og alt indhold derunder?');
INSERT INTO international VALUES (102,'WebGUI',0,'Rediger side');
INSERT INTO international VALUES (103,'WebGUI',0,'Side specifikationer');
INSERT INTO international VALUES (104,'WebGUI',0,'Side URL');
INSERT INTO international VALUES (105,'WebGUI',0,'Stil');
INSERT INTO international VALUES (106,'WebGUI',0,'Sæt kryds for at give denne stil til alle undersider');
INSERT INTO international VALUES (107,'WebGUI',0,'Rettigheder');
INSERT INTO international VALUES (108,'WebGUI',0,'Ejer');
INSERT INTO international VALUES (109,'WebGUI',0,'Ejer kan se?');
INSERT INTO international VALUES (110,'WebGUI',0,'Ejer kan redigere?');
INSERT INTO international VALUES (111,'WebGUI',0,'Gruppe');
INSERT INTO international VALUES (112,'WebGUI',0,'Gruppe kan se?');
INSERT INTO international VALUES (113,'WebGUI',0,'Gruppe kan redigere?');
INSERT INTO international VALUES (114,'WebGUI',0,'Alle kan se?');
INSERT INTO international VALUES (115,'WebGUI',0,'Alle kan redigere?');
INSERT INTO international VALUES (116,'WebGUI',0,'Sæt kryds for at give disse rettigheder til alle undersider');
INSERT INTO international VALUES (117,'WebGUI',0,'Rediger autorisations indstillinger');
INSERT INTO international VALUES (118,'WebGUI',0,'Anonym registrering');
INSERT INTO international VALUES (119,'WebGUI',0,'autorisations metode (default)');
INSERT INTO international VALUES (120,'WebGUI',0,'LDAP URL (default)');
INSERT INTO international VALUES (121,'WebGUI',0,'LDAP Identitet (default)');
INSERT INTO international VALUES (122,'WebGUI',0,'LDAP Identitets navn');
INSERT INTO international VALUES (123,'WebGUI',0,'LDAP kodeord');
INSERT INTO international VALUES (124,'WebGUI',0,'Rediger firma information');
INSERT INTO international VALUES (125,'WebGUI',0,'Firma/organisations navn');
INSERT INTO international VALUES (126,'WebGUI',0,'Firma/organisations Email');
INSERT INTO international VALUES (127,'WebGUI',0,'Firma/organisation URL');
INSERT INTO international VALUES (130,'WebGUI',0,'Maksimal størrelse på vedhæftede filer');
INSERT INTO international VALUES (133,'WebGUI',0,'Rediger Mail indstillinger');
INSERT INTO international VALUES (134,'WebGUI',0,'Besked for genskab adgangskode');
INSERT INTO international VALUES (135,'WebGUI',0,'SMTP Server');
INSERT INTO international VALUES (138,'WebGUI',0,'Ja');
INSERT INTO international VALUES (139,'WebGUI',0,'Nej ');
INSERT INTO international VALUES (140,'WebGUI',0,'Rediger diverse indstillinger');
INSERT INTO international VALUES (141,'WebGUI',0,'Ikke fundet side');
INSERT INTO international VALUES (142,'WebGUI',0,'Session Timeout');
INSERT INTO international VALUES (143,'WebGUI',0,'administrer indstillinger');
INSERT INTO international VALUES (144,'WebGUI',0,'Vis statistik');
INSERT INTO international VALUES (145,'WebGUI',0,'WebGUI Build Version');
INSERT INTO international VALUES (146,'WebGUI',0,'Aktive sessioner');
INSERT INTO international VALUES (147,'WebGUI',0,'Sider');
INSERT INTO international VALUES (148,'WebGUI',0,'Wobjects');
INSERT INTO international VALUES (149,'WebGUI',0,'brugere i gruppe');
INSERT INTO international VALUES (151,'WebGUI',0,'Navn på stilart');
INSERT INTO international VALUES (152,'WebGUI',0,'Hoved');
INSERT INTO international VALUES (153,'WebGUI',0,'Fod');
INSERT INTO international VALUES (154,'WebGUI',0,'Stilart Sheet');
INSERT INTO international VALUES (155,'WebGUI',0,'\"Er du sikker på du vil slette denne stilart og overføre alle sider der bruger denne til \"\"Fail Safe\"\" stilarten ?\"');
INSERT INTO international VALUES (156,'WebGUI',0,'Rediger stilart');
INSERT INTO international VALUES (157,'WebGUI',0,'stilarter');
INSERT INTO international VALUES (158,'WebGUI',0,'Tilføj ny stilart');
INSERT INTO international VALUES (159,'WebGUI',0,'Meddelelses log');
INSERT INTO international VALUES (160,'WebGUI',0,'Dato oprettet');
INSERT INTO international VALUES (161,'WebGUI',0,'Oprettet af');
INSERT INTO international VALUES (162,'WebGUI',0,'Er du sikker på du vil tømme skraldespanden?');
INSERT INTO international VALUES (163,'WebGUI',0,'Tilføj bruger  ');
INSERT INTO international VALUES (164,'WebGUI',0,'Metode for autorisation');
INSERT INTO international VALUES (165,'WebGUI',0,'LDAP URL');
INSERT INTO international VALUES (166,'WebGUI',0,'Connect DN');
INSERT INTO international VALUES (167,'WebGUI',0,'Er du sikker på du vil slette denne bruger? (Du kan ikke fortryde)');
INSERT INTO international VALUES (168,'WebGUI',0,'Rediger bruger');
INSERT INTO international VALUES (169,'WebGUI',0,'Tilføj ny bruger');
INSERT INTO international VALUES (170,'WebGUI',0,'Søg');
INSERT INTO international VALUES (171,'WebGUI',0,'Avanceret redigering');
INSERT INTO international VALUES (174,'WebGUI',0,'Vis titel på siden?');
INSERT INTO international VALUES (175,'WebGUI',0,'Udfør makroer?');
INSERT INTO international VALUES (228,'WebGUI',0,'Rediger besked…');
INSERT INTO international VALUES (229,'WebGUI',0,'Emne');
INSERT INTO international VALUES (230,'WebGUI',0,'Besked  ');
INSERT INTO international VALUES (231,'WebGUI',0,'Oprettet ny besked …');
INSERT INTO international VALUES (232,'WebGUI',0,'Intet emne');
INSERT INTO international VALUES (233,'WebGUI',0,'(eom)');
INSERT INTO international VALUES (234,'WebGUI',0,'Oprettet svar …');
INSERT INTO international VALUES (237,'WebGUI',0,'Emne:');
INSERT INTO international VALUES (238,'WebGUI',0,'Forfatter:');
INSERT INTO international VALUES (239,'WebGUI',0,'Dato:');
INSERT INTO international VALUES (240,'WebGUI',0,'Besked ID:');
INSERT INTO international VALUES (244,'WebGUI',0,'Forfatter ');
INSERT INTO international VALUES (245,'WebGUI',0,'Dato');
INSERT INTO international VALUES (304,'WebGUI',0,'Sprog');
INSERT INTO international VALUES (306,'WebGUI',0,'Brugernavn binding');
INSERT INTO international VALUES (307,'WebGUI',0,'Brug standard meta tags?');
INSERT INTO international VALUES (308,'WebGUI',0,'Rediger profil indstillinger');
INSERT INTO international VALUES (309,'WebGUI',0,'Tillad rigtige navne?');
INSERT INTO international VALUES (310,'WebGUI',0,'Tillad ekstra kontakt information?');
INSERT INTO international VALUES (311,'WebGUI',0,'Tillad hjemme information?');
INSERT INTO international VALUES (312,'WebGUI',0,'Tillad arbejds information?');
INSERT INTO international VALUES (313,'WebGUI',0,'Tillad diverse information?');
INSERT INTO international VALUES (314,'WebGUI',0,'Fornavn');
INSERT INTO international VALUES (315,'WebGUI',0,'Mellemnavn');
INSERT INTO international VALUES (316,'WebGUI',0,'Efternavn');
INSERT INTO international VALUES (317,'WebGUI',0,'\"<a href=\"\"http://www.icq.com\"\">ICQ</a> UIN\"');
INSERT INTO international VALUES (318,'WebGUI',0,'\"<a href=\"\"http://www.aol.com/aim/homenew.adp\"\">AIM</a> Id\"');
INSERT INTO international VALUES (319,'WebGUI',0,'\"<a href=\"\"http://messenger.msn.com/\"\">MSN Messenger</a> Id\"');
INSERT INTO international VALUES (320,'WebGUI',0,'\"<a href=\"\"http://messenger.yahoo.com/\"\">Yahoo! Messenger</a> Id\"');
INSERT INTO international VALUES (321,'WebGUI',0,'Bil tlf.');
INSERT INTO international VALUES (322,'WebGUI',0,'OPS');
INSERT INTO international VALUES (323,'WebGUI',0,'Hjemme adresse');
INSERT INTO international VALUES (324,'WebGUI',0,'Hjemme by');
INSERT INTO international VALUES (325,'WebGUI',0,'Hjemme stat');
INSERT INTO international VALUES (326,'WebGUI',0,'Hjemme postnr.');
INSERT INTO international VALUES (327,'WebGUI',0,'Hjemme amt');
INSERT INTO international VALUES (328,'WebGUI',0,'Hjemme tlf.');
INSERT INTO international VALUES (329,'WebGUI',0,'Arbejds adresse');
INSERT INTO international VALUES (330,'WebGUI',0,'Arbejds by');
INSERT INTO international VALUES (331,'WebGUI',0,'Arbejds stat');
INSERT INTO international VALUES (332,'WebGUI',0,'Arbejds postnr.');
INSERT INTO international VALUES (333,'WebGUI',0,'Arbejds amt');
INSERT INTO international VALUES (334,'WebGUI',0,'Arbejds tlf.');
INSERT INTO international VALUES (335,'WebGUI',0,'M/K');
INSERT INTO international VALUES (336,'WebGUI',0,'Fødselsdag');
INSERT INTO international VALUES (337,'WebGUI',0,'Hjemmeside URL');
INSERT INTO international VALUES (338,'WebGUI',0,'Rediger profil  ');
INSERT INTO international VALUES (339,'WebGUI',0,'Mand');
INSERT INTO international VALUES (340,'WebGUI',0,'Kvinde');
INSERT INTO international VALUES (341,'WebGUI',0,'Rediger profil');
INSERT INTO international VALUES (342,'WebGUI',0,'Rediger konto information');
INSERT INTO international VALUES (343,'WebGUI',0,'Vis profil');
INSERT INTO international VALUES (345,'WebGUI',0,'Ikke medlem');
INSERT INTO international VALUES (346,'WebGUI',0,'Denne bruger findes ikke længere på dette system. Jeg har ikke yderligere oplysninger om denne bruger');
INSERT INTO international VALUES (347,'WebGUI',0,'Vis profil for');
INSERT INTO international VALUES (348,'WebGUI',0,'Navn  ');
INSERT INTO international VALUES (349,'WebGUI',0,'Seneste version');
INSERT INTO international VALUES (350,'WebGUI',0,'Gennemført');
INSERT INTO international VALUES (351,'WebGUI',0,'Message Log Entry');
INSERT INTO international VALUES (352,'WebGUI',0,'Dato');
INSERT INTO international VALUES (353,'WebGUI',0,'Du har ingen meddelelser i øjeblikket');
INSERT INTO international VALUES (354,'WebGUI',0,'Vis meddelelses log');
INSERT INTO international VALUES (355,'WebGUI',0,'Standard');
INSERT INTO international VALUES (356,'WebGUI',0,'Template');
INSERT INTO international VALUES (357,'WebGUI',0,'Nyheder');
INSERT INTO international VALUES (358,'WebGUI',0,'Venstre kolonne');
INSERT INTO international VALUES (359,'WebGUI',0,'Højre kolonne');
INSERT INTO international VALUES (360,'WebGUI',0,'En over tre');
INSERT INTO international VALUES (361,'WebGUI',0,'Tre over en');
INSERT INTO international VALUES (362,'WebGUI',0,'Side ved side');
INSERT INTO international VALUES (363,'WebGUI',0,'Template position');
INSERT INTO international VALUES (364,'WebGUI',0,'Søg');
INSERT INTO international VALUES (365,'WebGUI',0,'Søge resultater …');
INSERT INTO international VALUES (366,'WebGUI',0,'Jeg fandt desværre ingen sider med de(t) søgeord');
INSERT INTO international VALUES (367,'WebGUI',0,'Udløber efter');
INSERT INTO international VALUES (368,'WebGUI',0,'Tilføj en ny gruppen til denne bruger.');
INSERT INTO international VALUES (369,'WebGUI',0,'Udløbs dato');
INSERT INTO international VALUES (370,'WebGUI',0,'Rediger gruppering');
INSERT INTO international VALUES (371,'WebGUI',0,'Tilføj gruppering');
INSERT INTO international VALUES (372,'WebGUI',0,'Rediger brugers gruppe');
INSERT INTO international VALUES (374,'WebGUI',0,'administrer packages');
INSERT INTO international VALUES (375,'WebGUI',0,'Vælg package der skal tages i brug');
INSERT INTO international VALUES (376,'WebGUI',0,'Package');
INSERT INTO international VALUES (377,'WebGUI',0,'\"Der er endnu ikke defineret nogle \"\"Packages\"\".\"');
INSERT INTO international VALUES (378,'WebGUI',0,'Bruger ID');
INSERT INTO international VALUES (379,'WebGUI',0,'Gruppe ID');
INSERT INTO international VALUES (380,'WebGUI',0,'Stilart ID');
INSERT INTO international VALUES (381,'WebGUI',0,'WebGUI modtog en fejlformateret besked og kan ikke fortsætte - dette skyldes typisk eb speciel karakter. Prøv evt. at trykke tilbage og prøv igen.');
INSERT INTO international VALUES (383,'WebGUI',0,'Navn');
INSERT INTO international VALUES (384,'WebGUI',0,'Fil  ');
INSERT INTO international VALUES (385,'WebGUI',0,'Parametre');
INSERT INTO international VALUES (386,'WebGUI',0,'Rediger billede');
INSERT INTO international VALUES (387,'WebGUI',0,'Tilføjet af');
INSERT INTO international VALUES (388,'WebGUI',0,'Tilføjet dato');
INSERT INTO international VALUES (389,'WebGUI',0,'Billede ID');
INSERT INTO international VALUES (390,'WebGUI',0,'Viser billede …');
INSERT INTO international VALUES (391,'WebGUI',0,'Sletter vedhæftet fil');
INSERT INTO international VALUES (392,'WebGUI',0,'Er du sikker på du vil slette dette billede');
INSERT INTO international VALUES (393,'WebGUI',0,'administrer billeder');
INSERT INTO international VALUES (394,'WebGUI',0,'administrer billeder.');
INSERT INTO international VALUES (395,'WebGUI',0,'Tilføj nyt billede');
INSERT INTO international VALUES (396,'WebGUI',0,'Vis billede');
INSERT INTO international VALUES (397,'WebGUI',0,'Tilbage til billede oversigt');
INSERT INTO international VALUES (398,'WebGUI',0,'Dokument type deklarering');
INSERT INTO international VALUES (399,'WebGUI',0,'Valider denne side.');
INSERT INTO international VALUES (400,'WebGUI',0,'Forhindre Proxy Caching');
INSERT INTO international VALUES (401,'WebGUI',0,'Er du sikker på du vil slette denne besked, og alle under beskeder i tråden?');
INSERT INTO international VALUES (402,'WebGUI',0,'Beskeden findes ikke');
INSERT INTO international VALUES (403,'WebGUI',0,'Det foretrækker jeg ikke at oplyse');
INSERT INTO international VALUES (404,'WebGUI',0,'Første side');
INSERT INTO international VALUES (405,'WebGUI',0,'Sidste side');
INSERT INTO international VALUES (406,'WebGUI',0,'Miniature størrelse');
INSERT INTO international VALUES (407,'WebGUI',0,'Klik her for at registrere');
INSERT INTO international VALUES (408,'WebGUI',0,'administrer rod');
INSERT INTO international VALUES (409,'WebGUI',0,'Tilføj ny rod');
INSERT INTO international VALUES (410,'WebGUI',0,'Administrer rod');
INSERT INTO international VALUES (411,'WebGUI',0,'Menu titel');
INSERT INTO international VALUES (412,'WebGUI',0,'Synopsis');
INSERT INTO international VALUES (51,'Product',1,'Benefit');
INSERT INTO international VALUES (56,'Product',1,'Add a product template.');
INSERT INTO international VALUES (416,'WebGUI',0,'<h1>Problem med forespørgsel</h1>Oops, jeg har lidt problemer med din forespørgsel. Tryk tilbage og prøv igen. Hvis problemet fortsætte vil jeg være glad hvis du vil kontakte os og fortælle hvad du prøver, på forhånd tak.');
INSERT INTO international VALUES (417,'WebGUI',0,'<h1>Sikkerhedsbrud</h1>Du forsøgte at få adgang med en Wobject der ikke hører til her. Jeg har rapporteret dit forsøg.');
INSERT INTO international VALUES (418,'WebGUI',0,'Filter Contributed HTML');
INSERT INTO international VALUES (419,'WebGUI',0,'Fjern alle tags');
INSERT INTO international VALUES (420,'WebGUI',0,'Lad det være');
INSERT INTO international VALUES (421,'WebGUI',0,'Fjerne alt bortset fra basal formatering');
INSERT INTO international VALUES (422,'WebGUI',0,'<h1>Login mislykkedes</h1>Dine informationer stemmer ikke med mine oplysninger');
INSERT INTO international VALUES (423,'WebGUI',0,'Vis aktive sessioner');
INSERT INTO international VALUES (424,'WebGUI',0,'Vis login historik');
INSERT INTO international VALUES (425,'WebGUI',0,'Aktive sessioner');
INSERT INTO international VALUES (426,'WebGUI',0,'Login historik');
INSERT INTO international VALUES (427,'WebGUI',0,'stilarter');
INSERT INTO international VALUES (428,'WebGUI',0,'Bruger (ID)');
INSERT INTO international VALUES (429,'WebGUI',0,'Login tid');
INSERT INTO international VALUES (430,'WebGUI',0,'Sidste side vist');
INSERT INTO international VALUES (431,'WebGUI',0,'IP Adresse');
INSERT INTO international VALUES (432,'WebGUI',0,'Udløber efter');
INSERT INTO international VALUES (433,'WebGUI',0,'Bruger agent:');
INSERT INTO international VALUES (434,'WebGUI',0,'Status');
INSERT INTO international VALUES (435,'WebGUI',0,'Session Signatur');
INSERT INTO international VALUES (436,'WebGUI',0,'Afbryd Session');
INSERT INTO international VALUES (437,'WebGUI',0,'Statistik');
INSERT INTO international VALUES (438,'WebGUI',0,'Dit navn');
INSERT INTO international VALUES (439,'WebGUI',0,'Personlig information');
INSERT INTO international VALUES (440,'WebGUI',0,'Kontakt information');
INSERT INTO international VALUES (441,'WebGUI',0,'Email  til OPS Gateway');
INSERT INTO international VALUES (442,'WebGUI',0,'Arbejdsinformation');
INSERT INTO international VALUES (443,'WebGUI',0,'Hjemme information');
INSERT INTO international VALUES (444,'WebGUI',0,'Demografisk information');
INSERT INTO international VALUES (445,'WebGUI',0,'Præferencer');
INSERT INTO international VALUES (446,'WebGUI',0,'Arbejds hjemmeside');
INSERT INTO international VALUES (447,'WebGUI',0,'Administrer træ struktur');
INSERT INTO international VALUES (448,'WebGUI',0,'Træ struktur');
INSERT INTO international VALUES (449,'WebGUI',0,'Diverse information');
INSERT INTO international VALUES (450,'WebGUI',0,'Arbejdsnavn (Firma navn)');
INSERT INTO international VALUES (451,'WebGUI',0,'er påkrævet');
INSERT INTO international VALUES (452,'WebGUI',0,'Vent venligst …');
INSERT INTO international VALUES (453,'WebGUI',0,'Dato oprettet');
INSERT INTO international VALUES (454,'WebGUI',0,'Sidste opdateret');
INSERT INTO international VALUES (455,'WebGUI',0,'Rediger bruger profil');
INSERT INTO international VALUES (456,'WebGUI',0,'Tilbage til bruger liste');
INSERT INTO international VALUES (457,'WebGUI',0,'Rediger denne brugers konto');
INSERT INTO international VALUES (458,'WebGUI',0,'Rediger denne bruger gruppe');
INSERT INTO international VALUES (459,'WebGUI',0,'Rediger denne brugers profil');
INSERT INTO international VALUES (460,'WebGUI',0,'Tidsforskel');
INSERT INTO international VALUES (461,'WebGUI',0,'Dato format');
INSERT INTO international VALUES (462,'WebGUI',0,'Tids format');
INSERT INTO international VALUES (463,'WebGUI',0,'Tekst Area Rows');
INSERT INTO international VALUES (464,'WebGUI',0,'Tekst Area Columns');
INSERT INTO international VALUES (465,'WebGUI',0,'Tekst Box Size');
INSERT INTO international VALUES (466,'WebGUI',0,'Er du sikker på du vil slette denne kategori og flytte indholdet over i diverse kategorien?');
INSERT INTO international VALUES (467,'WebGUI',0,'Er du sikker på du vil slette dette felt, og alle relaterede brugerdata?');
INSERT INTO international VALUES (469,'WebGUI',0,'Id');
INSERT INTO international VALUES (470,'WebGUI',0,'Navn');
INSERT INTO international VALUES (472,'WebGUI',0,'Label');
INSERT INTO international VALUES (473,'WebGUI',0,'Synlig?');
INSERT INTO international VALUES (474,'WebGUI',0,'Påkrævet?');
INSERT INTO international VALUES (475,'WebGUI',0,'Tekst');
INSERT INTO international VALUES (476,'WebGUI',0,'Tekst område');
INSERT INTO international VALUES (477,'WebGUI',0,'HTML område');
INSERT INTO international VALUES (478,'WebGUI',0,'URL');
INSERT INTO international VALUES (479,'WebGUI',0,'Dato');
INSERT INTO international VALUES (480,'WebGUI',0,'Email Adresse');
INSERT INTO international VALUES (481,'WebGUI',0,'Tlf. nr.');
INSERT INTO international VALUES (482,'WebGUI',0,'Heltal');
INSERT INTO international VALUES (483,'WebGUI',0,'Ja eller Nej');
INSERT INTO international VALUES (484,'WebGUI',0,'Vælg fra list');
INSERT INTO international VALUES (485,'WebGUI',0,'Logisk (Checkboks)');
INSERT INTO international VALUES (486,'WebGUI',0,'Data type');
INSERT INTO international VALUES (487,'WebGUI',0,'Mulige værdier');
INSERT INTO international VALUES (488,'WebGUI',0,'Standard værdi');
INSERT INTO international VALUES (489,'WebGUI',0,'Profil kategori');
INSERT INTO international VALUES (490,'WebGUI',0,'Tilføj en profil kategori');
INSERT INTO international VALUES (491,'WebGUI',0,'Tilføj et profil felt');
INSERT INTO international VALUES (492,'WebGUI',0,'Liste over profil felter');
INSERT INTO international VALUES (493,'WebGUI',0,'Tilbage til Site');
INSERT INTO international VALUES (494,'WebGUI',0,'Real Objects Edit-On Pro');
INSERT INTO international VALUES (495,'WebGUI',0,'Indbygget editor');
INSERT INTO international VALUES (496,'WebGUI',0,'Hvilken editor bruges');
INSERT INTO international VALUES (497,'WebGUI',0,'Start dato');
INSERT INTO international VALUES (498,'WebGUI',0,'Slut dato');
INSERT INTO international VALUES (499,'WebGUI',0,'Wobject ID');
INSERT INTO international VALUES (518,'WebGUI',1,'Inbox Notifications');
INSERT INTO international VALUES (519,'WebGUI',1,'I would not like to be notified.');
INSERT INTO international VALUES (520,'WebGUI',1,'I would like to be notified via email.');
INSERT INTO international VALUES (521,'WebGUI',1,'I would like to be notified via email to pager.');
INSERT INTO international VALUES (522,'WebGUI',1,'I would like to be notified via ICQ.');
INSERT INTO international VALUES (523,'WebGUI',1,'Notification');
INSERT INTO international VALUES (524,'WebGUI',1,'Add edit stamp to posts?');
INSERT INTO international VALUES (525,'WebGUI',1,'Edit Content Settings');
INSERT INTO international VALUES (526,'WebGUI',1,'Remove only JavaScript.');
INSERT INTO international VALUES (528,'WebGUI',1,'Template Name');
INSERT INTO international VALUES (529,'WebGUI',1,'results');
INSERT INTO international VALUES (530,'WebGUI',1,'with <b>all</b> the words');
INSERT INTO international VALUES (531,'WebGUI',1,'with the <b>exact phrase</b>');
INSERT INTO international VALUES (532,'WebGUI',1,'with <b>at least one</b> of the words');
INSERT INTO international VALUES (533,'WebGUI',1,'<b>without</b> the words');
INSERT INTO international VALUES (535,'WebGUI',1,'Group To Alert On New User');
INSERT INTO international VALUES (534,'WebGUI',1,'Alert on new user?');
INSERT INTO international VALUES (536,'WebGUI',1,'A new user named ^@; has joined the site.');
INSERT INTO international VALUES (14,'Article',3,'Plaatje uitlijnen');
INSERT INTO international VALUES (15,'Article',3,'Rechts');
INSERT INTO international VALUES (16,'Article',3,'links');
INSERT INTO international VALUES (17,'Article',3,'Centreren');
INSERT INTO international VALUES (18,'Article',3,'Discussie toelaten?');
INSERT INTO international VALUES (11,'Product',1,'Product Number');
INSERT INTO international VALUES (2,'Product',1,'Are you certain you wish to delete the relationship to this accessory?');
INSERT INTO international VALUES (22,'Article',3,'Auteur');
INSERT INTO international VALUES (23,'Article',3,'Datum');
INSERT INTO international VALUES (24,'Article',3,'Post reactie');
INSERT INTO international VALUES (579,'WebGUI',1,'Your message has been approved.');
INSERT INTO international VALUES (27,'Article',3,'Terug naar artikel');
INSERT INTO international VALUES (28,'Article',3,'Bekijk reacties');
INSERT INTO international VALUES (1,'DownloadManager',3,'Download Manager');
INSERT INTO international VALUES (3,'DownloadManager',3,'Verder gaan met bestand toevoegen?');
INSERT INTO international VALUES (5,'DownloadManager',3,'Bestand Titel');
INSERT INTO international VALUES (6,'DownloadManager',3,'Download bestand');
INSERT INTO international VALUES (7,'DownloadManager',3,'Groep om te downloaden');
INSERT INTO international VALUES (8,'DownloadManager',3,'Korte Omschrijving');
INSERT INTO international VALUES (9,'DownloadManager',3,'Bewerk download Manager');
INSERT INTO international VALUES (10,'DownloadManager',3,'Bewerk Download');
INSERT INTO international VALUES (11,'DownloadManager',3,'Nieuwe download toevoegen');
INSERT INTO international VALUES (12,'DownloadManager',3,'Weet u zeker dat u deze download wilt verwijderen?');
INSERT INTO international VALUES (14,'DownloadManager',3,'Bestand');
INSERT INTO international VALUES (15,'DownloadManager',3,'Beschrijving');
INSERT INTO international VALUES (16,'DownloadManager',3,'Upload datum');
INSERT INTO international VALUES (17,'DownloadManager',3,'Alternatieve Versie #1');
INSERT INTO international VALUES (18,'DownloadManager',3,'Alternatieve Versie #2');
INSERT INTO international VALUES (19,'DownloadManager',3,'U heeft geen bestanden te downloaden');
INSERT INTO international VALUES (20,'DownloadManager',3,'Kap pagina af na');
INSERT INTO international VALUES (21,'DownloadManager',3,'Miniaturen weergeven?');
INSERT INTO international VALUES (22,'DownloadManager',3,'Doorgaan met download toevoegen');
INSERT INTO international VALUES (20,'EventsCalendar',3,'Evenement toevoegen');
INSERT INTO international VALUES (21,'EventsCalendar',3,'Doorgaan met evenement toevoegen?');
INSERT INTO international VALUES (14,'EventsCalendar',3,'Start datum');
INSERT INTO international VALUES (15,'EventsCalendar',3,'Eind datum');
INSERT INTO international VALUES (16,'EventsCalendar',3,'Kalender layout');
INSERT INTO international VALUES (17,'EventsCalendar',3,'Lijst');
INSERT INTO international VALUES (18,'EventsCalendar',3,'Calendar Month');
INSERT INTO international VALUES (19,'EventsCalendar',3,'Breek pagina af na');
INSERT INTO international VALUES (11,'FAQ',3,'Zet inhoud aan?');
INSERT INTO international VALUES (12,'FAQ',3,'Zet V/A aan?');
INSERT INTO international VALUES (13,'FAQ',3,'Zet [top] link aan?');
INSERT INTO international VALUES (14,'FAQ',3,'V');
INSERT INTO international VALUES (15,'FAQ',3,'A');
INSERT INTO international VALUES (16,'FAQ',3,'[top]');
INSERT INTO international VALUES (1,'Item',3,'Link URL');
INSERT INTO international VALUES (2,'Item',3,'Bijlage');
INSERT INTO international VALUES (3,'Item',3,'Verwijder bijlage');
INSERT INTO international VALUES (4,'Item',3,'Item');
INSERT INTO international VALUES (5,'Item',3,'Download bijlage');
INSERT INTO international VALUES (565,'WebGUI',3,'Wie kan bewerken?');
INSERT INTO international VALUES (22,'MessageBoard',3,'Verwijder bericht');
INSERT INTO international VALUES (11,'Poll',3,'Stem!');
INSERT INTO international VALUES (9,'SiteMap',3,'Omschrijving laten zien?');
INSERT INTO international VALUES (13,'SQLReport',3,'Converteer Return?');
INSERT INTO international VALUES (14,'SQLReport',3,'Breek pagina af na');
INSERT INTO international VALUES (15,'SQLReport',3,'Verwerk macros voor query?');
INSERT INTO international VALUES (16,'SQLReport',3,'Debug?');
INSERT INTO international VALUES (17,'SQLReport',3,'Debug: Query:');
INSERT INTO international VALUES (18,'SQLReport',3,'Er waren geen resultaten voor deze query');
INSERT INTO international VALUES (31,'UserSubmission',3,'Inhoud');
INSERT INTO international VALUES (32,'UserSubmission',3,'Plaatje');
INSERT INTO international VALUES (33,'UserSubmission',3,'Bijlage');
INSERT INTO international VALUES (34,'UserSubmission',3,'Return converteren');
INSERT INTO international VALUES (35,'UserSubmission',3,'Titel');
INSERT INTO international VALUES (37,'UserSubmission',3,'Verwijder');
INSERT INTO international VALUES (39,'UserSubmission',3,'Post een reactie');
INSERT INTO international VALUES (40,'UserSubmission',3,'Gepost door');
INSERT INTO international VALUES (41,'UserSubmission',3,'Datum');
INSERT INTO international VALUES (9,'Product',1,'Product Image 3');
INSERT INTO international VALUES (7,'Product',1,'Product Image 1');
INSERT INTO international VALUES (45,'UserSubmission',3,'Ga terug naar bijdrages');
INSERT INTO international VALUES (46,'UserSubmission',3,'Lees meer...');
INSERT INTO international VALUES (47,'UserSubmission',3,'Post een reactie');
INSERT INTO international VALUES (48,'UserSubmission',3,'Discussie toestaan?');
INSERT INTO international VALUES (575,'WebGUI',1,'Edit');
INSERT INTO international VALUES (570,'WebGUI',1,'Lock Thread');
INSERT INTO international VALUES (568,'WebGUI',1,'After-the-fact');
INSERT INTO international VALUES (51,'UserSubmission',3,'Miniaturen weergeven');
INSERT INTO international VALUES (52,'UserSubmission',3,'Miniatuur');
INSERT INTO international VALUES (53,'UserSubmission',3,'Layout');
INSERT INTO international VALUES (54,'UserSubmission',3,'Web Log');
INSERT INTO international VALUES (55,'UserSubmission',3,'Traditioneel');
INSERT INTO international VALUES (56,'UserSubmission',3,'Foto gallerij');
INSERT INTO international VALUES (57,'UserSubmission',3,'Reacties');
INSERT INTO international VALUES (516,'WebGUI',3,'Zet beheermode aan!');
INSERT INTO international VALUES (517,'WebGUI',3,'Zet beheermode uit!');
INSERT INTO international VALUES (515,'WebGUI',3,'Bewerkings stempel toevoegen?');
INSERT INTO international VALUES (532,'WebGUI',3,'Met minstens 1 van de worden');
INSERT INTO international VALUES (531,'WebGUI',3,'met de exacte zin');
INSERT INTO international VALUES (505,'WebGUI',3,'Een niewe template toevoegen');
INSERT INTO international VALUES (504,'WebGUI',3,'Sjabloon');
INSERT INTO international VALUES (503,'WebGUI',3,'Sjabloon ID');
INSERT INTO international VALUES (502,'WebGUI',3,'Weet u zeker dat u deze sjabloon wilt verwijderen? Elke pagina die de template gebruikt zal de standaard template krijgen!');
INSERT INTO international VALUES (536,'WebGUI',3,'Een nieuwe gebruiker genaamd ^@; is bij de site aangemeld');
INSERT INTO international VALUES (356,'WebGUI',3,'Sjabloon');
INSERT INTO international VALUES (357,'WebGUI',3,'Nieuws');
INSERT INTO international VALUES (358,'WebGUI',3,'Linker kolom');
INSERT INTO international VALUES (359,'WebGUI',3,'Rechter kolom');
INSERT INTO international VALUES (360,'WebGUI',3,'Een boven drie');
INSERT INTO international VALUES (361,'WebGUI',3,'Drie boven een');
INSERT INTO international VALUES (362,'WebGUI',3,'Zij aan zij');
INSERT INTO international VALUES (363,'WebGUI',3,'Sjabloon positie');
INSERT INTO international VALUES (364,'WebGUI',3,'Zoeken');
INSERT INTO international VALUES (365,'WebGUI',3,'Zoek resultaten');
INSERT INTO international VALUES (366,'WebGUI',3,'Er is geen pagina die aan uw vraag voldoet');
INSERT INTO international VALUES (368,'WebGUI',3,'Voeg een nieuwe groep aan deze gebruiker toe');
INSERT INTO international VALUES (369,'WebGUI',3,'Verloop datum');
INSERT INTO international VALUES (370,'WebGUI',3,'Bewerk groeperen');
INSERT INTO international VALUES (371,'WebGUI',3,'Groeperen toevoegen');
INSERT INTO international VALUES (372,'WebGUI',3,'Bewerk gebruiker groep');
INSERT INTO international VALUES (374,'WebGUI',3,'Beheer pakketten');
INSERT INTO international VALUES (375,'WebGUI',3,'Selecteer pakket');
INSERT INTO international VALUES (376,'WebGUI',3,'Pakket');
INSERT INTO international VALUES (377,'WebGUI',3,'Er zijn geen pakketten gedefinieerd door uw pakket manager of beheerder.');
INSERT INTO international VALUES (378,'WebGUI',3,'Gebruikers ID');
INSERT INTO international VALUES (379,'WebGUI',3,'Groep ID');
INSERT INTO international VALUES (380,'WebGUI',3,'Stijl ID');
INSERT INTO international VALUES (381,'WebGUI',3,'WebGUI heeft een verkeerde vraag gekregen en kan niet verder gaan. Bepaalde karakters op de pagina kunnen de oorzaak zijn. Probeer terug te gaan naar de vorige pagina en probeer het opnieuw.');
INSERT INTO international VALUES (528,'WebGUI',3,'Sjabloon naam');
INSERT INTO international VALUES (383,'WebGUI',3,'Naam');
INSERT INTO international VALUES (384,'WebGUI',3,'Bestand');
INSERT INTO international VALUES (385,'WebGUI',3,'Parameters');
INSERT INTO international VALUES (386,'WebGUI',3,'Bewerk plaatje');
INSERT INTO international VALUES (387,'WebGUI',3,'Geleverd door');
INSERT INTO international VALUES (388,'WebGUI',3,'Upload datum');
INSERT INTO international VALUES (389,'WebGUI',3,'Plaatje ID');
INSERT INTO international VALUES (390,'WebGUI',3,'Plaatje laten zien......');
INSERT INTO international VALUES (391,'WebGUI',3,'Verwijder bijgevoegd bestand');
INSERT INTO international VALUES (392,'WebGUI',3,'Weet u zeker dat u dit plaatje wilt verwijderen?');
INSERT INTO international VALUES (393,'WebGUI',3,'Beheer plaatjes');
INSERT INTO international VALUES (394,'WebGUI',3,'Beheer plaatjes.');
INSERT INTO international VALUES (395,'WebGUI',3,'Een nieuw plaatje toevoegen');
INSERT INTO international VALUES (396,'WebGUI',3,'Plaatje laten zien');
INSERT INTO international VALUES (397,'WebGUI',3,'Terug naar plaatjes lijst');
INSERT INTO international VALUES (398,'WebGUI',3,'Document type declaratie');
INSERT INTO international VALUES (399,'WebGUI',3,'Valideer deze pagina');
INSERT INTO international VALUES (400,'WebGUI',3,'Voorkom Proxy Caching');
INSERT INTO international VALUES (401,'WebGUI',3,'Weet u zeker dat u dit bericht wilt verwijderen en alle berichten onder deze thread?');
INSERT INTO international VALUES (402,'WebGUI',3,'Het bericht wat u vroeg bestaat niet.');
INSERT INTO international VALUES (403,'WebGUI',3,'Geen mening');
INSERT INTO international VALUES (405,'WebGUI',3,'Laatste pagina');
INSERT INTO international VALUES (406,'WebGUI',3,'Miniatuur grootte');
INSERT INTO international VALUES (407,'WebGUI',3,'Klik hier om te registreren');
INSERT INTO international VALUES (506,'WebGUI',3,'Beheer Sjablonen');
INSERT INTO international VALUES (408,'WebGUI',3,'Beheer roots');
INSERT INTO international VALUES (409,'WebGUI',3,'Een nieuwe root toevoegen');
INSERT INTO international VALUES (410,'WebGUI',3,'Beheer roots.');
INSERT INTO international VALUES (411,'WebGUI',3,'Menu Titel');
INSERT INTO international VALUES (412,'WebGUI',3,'Omschrijving');
INSERT INTO international VALUES (713,'WebGUI',1,'Style Managers Group');
INSERT INTO international VALUES (714,'WebGUI',1,'Template Managers Group');
INSERT INTO international VALUES (416,'WebGUI',3,'<h1>Probleem met aanvraag</h1><br> We hebben een probleemm gevonden met de aanvraag van deze pagina. Ga terug naar de vorige pagina en probeer het opnieuw. Mocht het probleem zich blijven voordoen wendt u dan tot de beheerder.');
INSERT INTO international VALUES (417,'WebGUI',3,'<h1>Beveiligings probleem</h1><br> U probeerde een widget op te vragen die niet bij deze pagina hoort. Het incident is gerapporteerd.');
INSERT INTO international VALUES (418,'WebGUI',3,'Filter Contributed HTML');
INSERT INTO international VALUES (419,'WebGUI',3,'Verwijder alle tags');
INSERT INTO international VALUES (420,'WebGUI',3,'Laat het zoals het is');
INSERT INTO international VALUES (421,'WebGUI',3,'Verwijder alles behalve de basis formaten');
INSERT INTO international VALUES (422,'WebGUI',3,'<h1>Login Fout</h1><br>De informatie komt niet overeen met het account');
INSERT INTO international VALUES (423,'WebGUI',3,'Laat aktieve sessies zien');
INSERT INTO international VALUES (424,'WebGUI',3,'Laat login historie zien');
INSERT INTO international VALUES (425,'WebGUI',3,'Aktieve sessies');
INSERT INTO international VALUES (426,'WebGUI',3,'Login historie');
INSERT INTO international VALUES (427,'WebGUI',3,'Stijlen');
INSERT INTO international VALUES (428,'WebGUI',3,'Gebruiker (ID)');
INSERT INTO international VALUES (429,'WebGUI',3,'Login tijd');
INSERT INTO international VALUES (430,'WebGUI',3,'Laatst bekeken pagina');
INSERT INTO international VALUES (431,'WebGUI',3,'IP Adres');
INSERT INTO international VALUES (432,'WebGUI',3,'Verloopt');
INSERT INTO international VALUES (433,'WebGUI',3,'Gebruikers applicatie');
INSERT INTO international VALUES (434,'WebGUI',3,'Status');
INSERT INTO international VALUES (435,'WebGUI',3,'Sessie handtekening');
INSERT INTO international VALUES (436,'WebGUI',3,'Vermoord sessie');
INSERT INTO international VALUES (437,'WebGUI',3,'Statistieken');
INSERT INTO international VALUES (438,'WebGUI',3,'Uw naam');
INSERT INTO international VALUES (441,'WebGUI',3,'Email naar pager gateway');
INSERT INTO international VALUES (442,'WebGUI',3,'Bedrijfs informatie');
INSERT INTO international VALUES (443,'WebGUI',3,'Thuis informatie');
INSERT INTO international VALUES (439,'WebGUI',3,'Persoonlijke informatie');
INSERT INTO international VALUES (440,'WebGUI',3,'Contact informatie');
INSERT INTO international VALUES (444,'WebGUI',3,'Demografische informatie');
INSERT INTO international VALUES (445,'WebGUI',3,'Voorkeuren');
INSERT INTO international VALUES (446,'WebGUI',3,'Bedrijfs website');
INSERT INTO international VALUES (447,'WebGUI',3,'Beheer pagina boom');
INSERT INTO international VALUES (448,'WebGUI',3,'Pagina boom');
INSERT INTO international VALUES (449,'WebGUI',3,'Overige informatie');
INSERT INTO international VALUES (450,'WebGUI',3,'Werk naam (Bedrijfsnaam)');
INSERT INTO international VALUES (451,'WebGUI',3,'is vereist');
INSERT INTO international VALUES (452,'WebGUI',3,'Even wachten alstublieft....');
INSERT INTO international VALUES (453,'WebGUI',3,'Creatie datum');
INSERT INTO international VALUES (454,'WebGUI',3,'Laatst veranderd');
INSERT INTO international VALUES (455,'WebGUI',3,'Bewerk gebruikersprofiel');
INSERT INTO international VALUES (456,'WebGUI',3,'Terug naar gebruikers lijst');
INSERT INTO international VALUES (457,'WebGUI',3,'Bewerk het account van deze gebruiker');
INSERT INTO international VALUES (458,'WebGUI',3,'Bewerk de groepen van deze gebruiker');
INSERT INTO international VALUES (459,'WebGUI',3,'Bewerk het profiel van deze gebruiker');
INSERT INTO international VALUES (460,'WebGUI',3,'Tijd offset');
INSERT INTO international VALUES (461,'WebGUI',3,'Datum formaat');
INSERT INTO international VALUES (462,'WebGUI',3,'Tijd formaat');
INSERT INTO international VALUES (463,'WebGUI',3,'Tekst vlak rijen');
INSERT INTO international VALUES (464,'WebGUI',3,'Tekst vlak kolommen');
INSERT INTO international VALUES (465,'WebGUI',3,'Tekst blok grootte');
INSERT INTO international VALUES (466,'WebGUI',3,'Weet u zeker dat u deze categorie wilt verwijderen en alle velden naar de overige categorie wilt verplaatsen?');
INSERT INTO international VALUES (467,'WebGUI',3,'Weet u zeker dat u dit veld wilt verwijderen en daarmee ook alle data die er aan vast zit?');
INSERT INTO international VALUES (469,'WebGUI',3,'Id');
INSERT INTO international VALUES (470,'WebGUI',3,'Naam');
INSERT INTO international VALUES (472,'WebGUI',3,'Label');
INSERT INTO international VALUES (473,'WebGUI',3,'Zichtbaar?');
INSERT INTO international VALUES (474,'WebGUI',3,'Verplicht?');
INSERT INTO international VALUES (475,'WebGUI',3,'Tekst');
INSERT INTO international VALUES (476,'WebGUI',3,'Tekst vlak');
INSERT INTO international VALUES (477,'WebGUI',3,'HTML vlak');
INSERT INTO international VALUES (478,'WebGUI',3,'URL');
INSERT INTO international VALUES (479,'WebGUI',3,'Datum');
INSERT INTO international VALUES (480,'WebGUI',3,'Email adres');
INSERT INTO international VALUES (481,'WebGUI',3,'Telefoon nummer');
INSERT INTO international VALUES (482,'WebGUI',3,'Nummer (Geheel getal)');
INSERT INTO international VALUES (483,'WebGUI',3,'Ja of nee');
INSERT INTO international VALUES (484,'WebGUI',3,'Selecteer lijst');
INSERT INTO international VALUES (485,'WebGUI',3,'Booleaanse waarde (Checkbox)');
INSERT INTO international VALUES (486,'WebGUI',3,'Data type');
INSERT INTO international VALUES (487,'WebGUI',3,'Mogelijke waardes');
INSERT INTO international VALUES (488,'WebGUI',3,'Standaard waarde(s)');
INSERT INTO international VALUES (489,'WebGUI',3,'Profiel categorie');
INSERT INTO international VALUES (490,'WebGUI',3,'Profiel categorie toevoegen');
INSERT INTO international VALUES (491,'WebGUI',3,'Profiel veld toevoegen');
INSERT INTO international VALUES (492,'WebGUI',3,'Profiel veld lijst');
INSERT INTO international VALUES (493,'WebGUI',3,'terug naar de site');
INSERT INTO international VALUES (496,'WebGUI',3,'Ingebouwde editor');
INSERT INTO international VALUES (494,'WebGUI',3,'Te gebruiken Editor');
INSERT INTO international VALUES (497,'WebGUI',3,'Start datum');
INSERT INTO international VALUES (498,'WebGUI',3,'Eind Datum');
INSERT INTO international VALUES (499,'WebGUI',3,'Wobject ID');
INSERT INTO international VALUES (500,'WebGUI',3,'Pagina ID');
INSERT INTO international VALUES (514,'WebGUI',3,'Bekeken');
INSERT INTO international VALUES (527,'WebGUI',3,'Standaard home pagina');
INSERT INTO international VALUES (530,'WebGUI',3,'Met alle woorden');
INSERT INTO international VALUES (501,'WebGUI',3,'Body');
INSERT INTO international VALUES (468,'WebGUI',3,'Bewerk gebruikers profiel categorie');
INSERT INTO international VALUES (507,'WebGUI',3,'Bewerk sjabloon');
INSERT INTO international VALUES (508,'WebGUI',3,'Beheer sjablonen');
INSERT INTO international VALUES (509,'WebGUI',3,'Discussie layout');
INSERT INTO international VALUES (510,'WebGUI',3,'Plat');
INSERT INTO international VALUES (511,'WebGUI',3,'threaded');
INSERT INTO international VALUES (512,'WebGUI',3,'Volgende thread');
INSERT INTO international VALUES (513,'WebGUI',3,'Vorige thread');
INSERT INTO international VALUES (533,'WebGUI',3,'Zonder de woorden');
INSERT INTO international VALUES (529,'WebGUI',3,'Resultaten');
INSERT INTO international VALUES (518,'WebGUI',3,'Inbox notificaties');
INSERT INTO international VALUES (519,'WebGUI',3,'Ik wil geen notificatie krijgen');
INSERT INTO international VALUES (520,'WebGUI',3,'Ik wil notificatie via email');
INSERT INTO international VALUES (521,'WebGUI',3,'Ik wil notificatie via email naar pager');
INSERT INTO international VALUES (522,'WebGUI',3,'Ik wil notificatie via ICQ');
INSERT INTO international VALUES (523,'WebGUI',3,'Notificatie');
INSERT INTO international VALUES (524,'WebGUI',3,'Voeg bewerk stempel toe aan post');
INSERT INTO international VALUES (525,'WebGUI',3,'Bewerk inhoud Settings');
INSERT INTO international VALUES (526,'WebGUI',3,'Verwijder alleen javascript');
INSERT INTO international VALUES (537,'WebGUI',1,'Karma');
INSERT INTO international VALUES (538,'WebGUI',1,'Karma Threshold');
INSERT INTO international VALUES (539,'WebGUI',1,'Enable Karma?');
INSERT INTO international VALUES (540,'WebGUI',1,'Karma Per Login');
INSERT INTO international VALUES (20,'Poll',1,'Karma Per Vote');
INSERT INTO international VALUES (541,'WebGUI',1,'Karma Per Post');
INSERT INTO international VALUES (5,'Product',1,'Are you certain you wish to delete this specification?');
INSERT INTO international VALUES (542,'WebGUI',1,'Previous..');
INSERT INTO international VALUES (543,'WebGUI',1,'Add a new image group.');
INSERT INTO international VALUES (544,'WebGUI',1,'Are you certain you wish to delete this group?');
INSERT INTO international VALUES (545,'WebGUI',1,'Edit Image Group');
INSERT INTO international VALUES (546,'WebGUI',1,'Group Id');
INSERT INTO international VALUES (547,'WebGUI',1,'Parent group');
INSERT INTO international VALUES (548,'WebGUI',1,'Group name');
INSERT INTO international VALUES (549,'WebGUI',1,'Group description');
INSERT INTO international VALUES (550,'WebGUI',1,'View Image group');
INSERT INTO international VALUES (382,'WebGUI',1,'Edit Image');
INSERT INTO international VALUES (551,'WebGUI',1,'Notice');
INSERT INTO international VALUES (552,'WebGUI',1,'Pending');
INSERT INTO international VALUES (553,'WebGUI',1,'Status');
INSERT INTO international VALUES (554,'WebGUI',1,'Take Action');
INSERT INTO international VALUES (555,'WebGUI',1,'Edit this user\'s karma.');
INSERT INTO international VALUES (556,'WebGUI',1,'Amount');
INSERT INTO international VALUES (557,'WebGUI',1,'Description');
INSERT INTO international VALUES (558,'WebGUI',1,'Edit User\'s Karma');
INSERT INTO international VALUES (6,'Item',1,'Edit Item');
INSERT INTO international VALUES (559,'WebGUI',1,'Run On Registration');
INSERT INTO international VALUES (13,'Product',1,'Brochure');
INSERT INTO international VALUES (14,'Product',1,'Manual');
INSERT INTO international VALUES (15,'Product',1,'Warranty');
INSERT INTO international VALUES (16,'Product',1,'Add Accessory');
INSERT INTO international VALUES (17,'Product',1,'Accessory');
INSERT INTO international VALUES (18,'Product',1,'Add another accessory?');
INSERT INTO international VALUES (21,'Product',1,'Add another related product?');
INSERT INTO international VALUES (19,'Product',1,'Add Related Product');
INSERT INTO international VALUES (20,'Product',1,'Related Product');
INSERT INTO international VALUES (22,'Product',1,'Edit Feature');
INSERT INTO international VALUES (23,'Product',1,'Feature');
INSERT INTO international VALUES (24,'Product',1,'Add another feature?');
INSERT INTO international VALUES (25,'Product',1,'Edit Specification');
INSERT INTO international VALUES (26,'Product',1,'Label');
INSERT INTO international VALUES (27,'Product',1,'Specification');
INSERT INTO international VALUES (28,'Product',1,'Add another specification?');
INSERT INTO international VALUES (29,'Product',1,'Units');
INSERT INTO international VALUES (30,'Product',1,'Features');
INSERT INTO international VALUES (31,'Product',1,'Specifications');
INSERT INTO international VALUES (32,'Product',1,'Accessories');
INSERT INTO international VALUES (33,'Product',1,'Related Products');
INSERT INTO international VALUES (34,'Product',1,'Add a feature.');
INSERT INTO international VALUES (35,'Product',1,'Add a specification.');
INSERT INTO international VALUES (36,'Product',1,'Add an accessory.');
INSERT INTO international VALUES (37,'Product',1,'Add a related product.');
INSERT INTO international VALUES (581,'WebGUI',1,'Add New Value');
INSERT INTO international VALUES (582,'WebGUI',1,'Leave Blank');
INSERT INTO international VALUES (583,'WebGUI',1,'Max Image Size');
INSERT INTO international VALUES (1,'WobjectProxy',1,'Wobject To Proxy');
INSERT INTO international VALUES (2,'WobjectProxy',1,'Edit Wobject Proxy');
INSERT INTO international VALUES (3,'WobjectProxy',1,'Wobject Proxy');
INSERT INTO international VALUES (4,'WobjectProxy',1,'Wobject proxying failed. Perhaps the proxied wobject has been deleted.');
INSERT INTO international VALUES (5,'UserSubmission',7,'ÄúµÄÍ¶¸å±»¾Ü¾ø¡£');
INSERT INTO international VALUES (5,'SyndicatedContent',7,'×îºóÌáÈ¡ÓÚ');
INSERT INTO international VALUES (5,'SQLReport',7,'DSN');
INSERT INTO international VALUES (5,'SiteMap',7,'±à¼­ÍøÕ¾µØÍ¼');
INSERT INTO international VALUES (5,'Poll',7,'Í¼ÐÎ¿í¶È');
INSERT INTO international VALUES (5,'MessageBoard',7,'±à¼­³¬Ê±');
INSERT INTO international VALUES (5,'LinkList',7,'ÊÇ·ñÖ´ÐÐÌí¼ÓÁ´½Ó£¿');
INSERT INTO international VALUES (5,'Item',7,'ÏÂÔØ¸½¼þ');
INSERT INTO international VALUES (5,'FAQ',7,'ÎÊÌâ');
INSERT INTO international VALUES (5,'ExtraColumn',7,'·ç¸ñµ¥ Class');
INSERT INTO international VALUES (700,'WebGUI',7,'Ìì');
INSERT INTO international VALUES (20,'EventsCalendar',7,'Ìí¼ÓÊÂÎñ¡£');
INSERT INTO international VALUES (38,'UserSubmission',7,'(Èç¹ûÄúÊ¹ÓÃÁË³¬ÎÄ±¾ÓïÑÔ£¬ÇëÑ¡Ôñ¡°·ñ¡±¡£)');
INSERT INTO international VALUES (4,'WebGUI',7,'¹ÜÀíÉèÖÃ¡£');
INSERT INTO international VALUES (4,'UserSubmission',7,'ÄúµÄÍ¶¸åÒÑÍ¨¹ýÉóºË¡£');
INSERT INTO international VALUES (4,'SyndicatedContent',7,'±à¼­Í¬²½ÄÚÈÝ');
INSERT INTO international VALUES (4,'SQLReport',7,'²éÑ¯');
INSERT INTO international VALUES (4,'SiteMap',7,'Õ¹¿ªÉî¶È');
INSERT INTO international VALUES (4,'Poll',7,'Í¶Æ±È¨ÏÞ£¿');
INSERT INTO international VALUES (4,'MessageBoard',7,'Ã¿Ò³ÏÔÊ¾');
INSERT INTO international VALUES (4,'LinkList',7,'Ç°×º×Ö·û');
INSERT INTO international VALUES (4,'Item',7,'ÏîÄ¿');
INSERT INTO international VALUES (4,'ExtraColumn',7,'¿í¶È');
INSERT INTO international VALUES (4,'EventsCalendar',7,'Ö»·¢ÉúÒ»´Î¡£');
INSERT INTO international VALUES (4,'Article',7,'½áÊøÈÕÆÚ');
INSERT INTO international VALUES (3,'WebGUI',7,'´Ó¼ôÌù°åÖÐÕ³Ìù...');
INSERT INTO international VALUES (3,'UserSubmission',7,'ÄúÓÐÒ»ÆªÐÂµÄÓÃ»§Í¶¸åµÈ´ýÉóºË¡£');
INSERT INTO international VALUES (3,'SQLReport',7,'±¨¸æÄ£°å');
INSERT INTO international VALUES (3,'SiteMap',7,'ÊÇ·ñ´Ó´Ë¼¶±ð¿ªÊ¼£¿');
INSERT INTO international VALUES (3,'Poll',7,'¼¤»î');
INSERT INTO international VALUES (3,'MessageBoard',7,'·¢±íÈ¨ÏÞ£¿');
INSERT INTO international VALUES (3,'LinkList',7,'ÊÇ·ñÔÚÐÂ´°¿ÚÖÐ´ò¿ª£¿');
INSERT INTO international VALUES (3,'Item',7,'É¾³ý¸½¼þ');
INSERT INTO international VALUES (3,'ExtraColumn',7,'¿Õ°×');
INSERT INTO international VALUES (3,'Article',7,'¿ªÊ¼ÈÕÆÚ');
INSERT INTO international VALUES (2,'WebGUI',7,'Ò³');
INSERT INTO international VALUES (2,'UserSubmission',7,'Í¶¸åÈ¨ÏÞ£¿');
INSERT INTO international VALUES (2,'SyndicatedContent',7,'Í¬²½ÄÚÈÝ');
INSERT INTO international VALUES (2,'SiteMap',7,'ÍøÕ¾µØÍ¼');
INSERT INTO international VALUES (2,'MessageBoard',7,'¹«¸æÀ¸');
INSERT INTO international VALUES (2,'LinkList',7,'ÐÐ¼ä¾à');
INSERT INTO international VALUES (2,'Item',7,'¸½¼þ');
INSERT INTO international VALUES (2,'FAQ',7,'F.A.Q.');
INSERT INTO international VALUES (2,'EventsCalendar',7,'ÐÐÊÂÀú');
INSERT INTO international VALUES (507,'WebGUI',7,'±à¼­Ä£°å');
INSERT INTO international VALUES (1,'WebGUI',7,'Ìí¼ÓÄÚÈÝ...');
INSERT INTO international VALUES (1,'UserSubmission',7,'ÉóºËÈ¨ÏÞ£¿');
INSERT INTO international VALUES (1,'SyndicatedContent',7,'RSS ÎÄ¼þÁ´½Ó');
INSERT INTO international VALUES (1,'SQLReport',7,'SQL ±¨¸æ');
INSERT INTO international VALUES (1,'Poll',7,'µ÷²é');
INSERT INTO international VALUES (1,'LinkList',7,'Ëõ½ø');
INSERT INTO international VALUES (1,'Item',7,'Á´½Ó URL');
INSERT INTO international VALUES (1,'FAQ',7,'ÊÇ·ñÖ´ÐÐÌí¼ÓÎÊÌâ£¿');
INSERT INTO international VALUES (1,'ExtraColumn',7,'À©Õ¹ÁÐ');
INSERT INTO international VALUES (1,'EventsCalendar',7,'ÊÇ·ñÖ´ÐÐÌí¼ÓÊÂÎñ£¿');
INSERT INTO international VALUES (1,'Article',7,'ÎÄÕÂ');
INSERT INTO international VALUES (367,'WebGUI',7,'¹ýÆÚÊ±¼ä');
INSERT INTO international VALUES (5,'WebGUI',7,'¹ÜÀíÓÃ»§×é¡£');
INSERT INTO international VALUES (6,'Article',7,'Í¼Æ¬');
INSERT INTO international VALUES (701,'WebGUI',7,'ÐÇÆÚ');
INSERT INTO international VALUES (6,'ExtraColumn',7,'±à¼­À©Õ¹ÁÐ');
INSERT INTO international VALUES (6,'FAQ',7,'»Ø´ð');
INSERT INTO international VALUES (6,'LinkList',7,'Á´½ÓÁÐ±í');
INSERT INTO international VALUES (6,'MessageBoard',7,'±à¼­¹«¸æÀ¸');
INSERT INTO international VALUES (6,'Poll',7,'ÎÊÌâ');
INSERT INTO international VALUES (6,'SiteMap',7,'Ëõ½ø');
INSERT INTO international VALUES (6,'SQLReport',7,'Êý¾Ý¿âÓÃ»§');
INSERT INTO international VALUES (6,'SyndicatedContent',7,'µ±Ç°ÄÚÈÝ');
INSERT INTO international VALUES (6,'UserSubmission',7,'Ã¿Ò³Í¶¸åÊý');
INSERT INTO international VALUES (6,'WebGUI',7,'¹ÜÀí·ç¸ñ');
INSERT INTO international VALUES (7,'Article',7,'Á¬½Ó±êÌâ');
INSERT INTO international VALUES (7,'FAQ',7,'ÄúÊÇ·ñÈ·ÐÅÄúÒªÉ¾³ýÕâ¸öÎÊÌâ£¿');
INSERT INTO international VALUES (7,'MessageBoard',7,'×÷Õß£º');
INSERT INTO international VALUES (7,'Poll',7,'»Ø´ð');
INSERT INTO international VALUES (7,'SiteMap',7,'Ç°×º×Ö·û');
INSERT INTO international VALUES (7,'SQLReport',7,'Êý¾Ý¿âÃÜÂë');
INSERT INTO international VALUES (7,'UserSubmission',7,'Í¨¹ý');
INSERT INTO international VALUES (7,'WebGUI',7,'¹ÜÀíÓÃ»§¡£');
INSERT INTO international VALUES (8,'Article',7,'Á´½Ó URL');
INSERT INTO international VALUES (8,'EventsCalendar',7,'ÖØ¸´ÖÜÆÚ');
INSERT INTO international VALUES (8,'FAQ',7,'±à¼­ F.A.Q.');
INSERT INTO international VALUES (8,'LinkList',7,'URL');
INSERT INTO international VALUES (8,'MessageBoard',7,'ÈÕÆÚ£º');
INSERT INTO international VALUES (8,'Poll',7,'£¨Ã¿ÐÐÊäÈëÒ»Ìõ´ð°¸¡£×î¶à²»³¬¹ý20Ìõ¡££©');
INSERT INTO international VALUES (9,'MessageBoard',7,'ÎÄÕÂ ID:');
INSERT INTO international VALUES (11,'MessageBoard',7,'·µ»ØÎÄÕÂÁÐ±í');
INSERT INTO international VALUES (12,'MessageBoard',7,'±à¼­ÎÄÕÂ');
INSERT INTO international VALUES (13,'MessageBoard',7,'·¢±í»Ø¸´');
INSERT INTO international VALUES (15,'MessageBoard',7,'×÷Õß');
INSERT INTO international VALUES (16,'MessageBoard',7,'ÈÕÆÚ');
INSERT INTO international VALUES (17,'MessageBoard',7,'·¢±íÐÂÎÄÕÂ');
INSERT INTO international VALUES (18,'MessageBoard',7,'ÏßË÷¿ªÊ¼');
INSERT INTO international VALUES (19,'MessageBoard',7,'»Ø¸´');
INSERT INTO international VALUES (20,'MessageBoard',7,'×îºó»Ø¸´');
INSERT INTO international VALUES (21,'MessageBoard',7,'¹ÜÀíÈ¨ÏÞ£¿');
INSERT INTO international VALUES (22,'MessageBoard',7,'É¾³ýÎÄÕÂ');
INSERT INTO international VALUES (9,'Poll',7,'±à¼­µ÷²é');
INSERT INTO international VALUES (10,'Poll',7,'³õÊ¼»¯Í¶Æ±¡£');
INSERT INTO international VALUES (11,'Poll',7,'Í¶Æ±£¡');
INSERT INTO international VALUES (8,'SiteMap',7,'ÐÐ¾à');
INSERT INTO international VALUES (8,'SQLReport',7,'Edit SQL Report');
INSERT INTO international VALUES (8,'UserSubmission',7,'±»¾Ü¾ø');
INSERT INTO international VALUES (8,'WebGUI',7,'Äú²é¿´µÄÒ³Ãæ²»´æÔÚ¡£');
INSERT INTO international VALUES (9,'Article',7,'¸½¼þ');
INSERT INTO international VALUES (9,'EventsCalendar',7,'Ö±µ½');
INSERT INTO international VALUES (9,'FAQ',7,'Ìí¼ÓÐÂÎÊÌâ¡£');
INSERT INTO international VALUES (9,'LinkList',7,'ÄúÊÇ·ñÈ·¶¨ÒªÉ¾³ý´ËÁ´½Ó£¿');
INSERT INTO international VALUES (9,'SQLReport',7,'<b>Debug:</b> Error: The DSN specified is of an improper format.');
INSERT INTO international VALUES (9,'UserSubmission',7,'ÉóºËÖÐ');
INSERT INTO international VALUES (9,'WebGUI',7,'²é¿´¼ôÌù°å');
INSERT INTO international VALUES (10,'Article',7,'ÊÇ·ñ×ª»»»Ø³µ·û£¿');
INSERT INTO international VALUES (10,'FAQ',7,'±à¼­ÎÊÌâ');
INSERT INTO international VALUES (10,'LinkList',7,'±à¼­Á´½ÓÁÐ±í');
INSERT INTO international VALUES (10,'SQLReport',7,'<b>Debug:</b> Error: The SQL specified is of an improper format.');
INSERT INTO international VALUES (10,'UserSubmission',7,'Ä¬ÈÏ×´Ì¬');
INSERT INTO international VALUES (10,'WebGUI',7,'¹ÜÀíÀ¬»øÏä');
INSERT INTO international VALUES (11,'Article',7,'(Èç¹ûÄúÃ»ÓÐÊÖ¶¯ÊäÈë&lt;br&gt;£¬ÇëÑ¡Ôñ¡°ÊÇ¡±)');
INSERT INTO international VALUES (76,'EventsCalendar',1,'Delete only this event.');
INSERT INTO international VALUES (11,'SQLReport',7,'<b>Debug:</b> Error: There was a problem with the query.');
INSERT INTO international VALUES (11,'WebGUI',7,'Çå¿ÕÀ¬»øÏä');
INSERT INTO international VALUES (12,'Article',7,'±à¼­ÎÄÕÂ');
INSERT INTO international VALUES (12,'EventsCalendar',7,'±à¼­ÐÐÊÂÀú');
INSERT INTO international VALUES (12,'LinkList',7,'±à¼­Á´½Ó');
INSERT INTO international VALUES (12,'SQLReport',7,'<b>Debug:</b> Error: Could not connect to the database.');
INSERT INTO international VALUES (12,'UserSubmission',7,'(Èç¹ûÄúÊ¹ÓÃÁË³¬ÎÄ±¾ÓïÑÔ£¬Çë²»ÒªÑ¡Ôñ´ËÏî)');
INSERT INTO international VALUES (12,'WebGUI',7,'ÍË³ö¹ÜÀí');
INSERT INTO international VALUES (13,'Article',7,'É¾³ý');
INSERT INTO international VALUES (13,'EventsCalendar',7,'±à¼­ÊÂÎñ');
INSERT INTO international VALUES (13,'LinkList',7,'Ìí¼ÓÐÂÁ´½Ó¡£');
INSERT INTO international VALUES (13,'UserSubmission',7,'Í¶¸åÊ±¼ä');
INSERT INTO international VALUES (13,'WebGUI',7,'²é¿´°ïÖúË÷Òý');
INSERT INTO international VALUES (14,'Article',7,'Í¼Æ¬Î»ÖÃ');
INSERT INTO international VALUES (516,'WebGUI',7,'½øÈë¹ÜÀí');
INSERT INTO international VALUES (517,'WebGUI',7,'ÍË³ö¹ÜÀí');
INSERT INTO international VALUES (515,'WebGUI',7,'ÊÇ·ñÌí¼Ó±à¼­´Á£¿');
INSERT INTO international VALUES (14,'UserSubmission',7,'×´Ì¬');
INSERT INTO international VALUES (14,'WebGUI',7,'²é¿´µÈ´ýÉóºËµÄÍ¶¸å');
INSERT INTO international VALUES (15,'UserSubmission',7,'±à¼­/É¾³ý');
INSERT INTO international VALUES (15,'WebGUI',7,'Ò»ÔÂ');
INSERT INTO international VALUES (16,'UserSubmission',7,'ÎÞ±êÌâ');
INSERT INTO international VALUES (16,'WebGUI',7,'¶þÔÂ');
INSERT INTO international VALUES (17,'UserSubmission',7,'ÄúÈ·¶¨ÒªÉ¾³ý´Ë¸å¼þÂð£¿');
INSERT INTO international VALUES (17,'WebGUI',7,'ÈýÔÂ');
INSERT INTO international VALUES (18,'UserSubmission',7,'±à¼­ÓÃ»§Í¶¸åÏµÍ³');
INSERT INTO international VALUES (18,'WebGUI',7,'ËÄÔÂ');
INSERT INTO international VALUES (19,'UserSubmission',7,'±à¼­Í¶¸å');
INSERT INTO international VALUES (19,'WebGUI',7,'ÎåÔÂ');
INSERT INTO international VALUES (20,'UserSubmission',7,'ÎÒÒªÍ¶¸å');
INSERT INTO international VALUES (20,'WebGUI',7,'ÁùÔÂ');
INSERT INTO international VALUES (21,'UserSubmission',7,'·¢±íÈË');
INSERT INTO international VALUES (21,'WebGUI',7,'ÆßÔÂ');
INSERT INTO international VALUES (22,'UserSubmission',7,'·¢±íÈË£º');
INSERT INTO international VALUES (22,'WebGUI',7,'°ËÔÂ');
INSERT INTO international VALUES (23,'UserSubmission',7,'Í¶¸åÊ±¼ä');
INSERT INTO international VALUES (23,'WebGUI',7,'¾ÅÔÂ');
INSERT INTO international VALUES (24,'UserSubmission',7,'Í¨¹ý');
INSERT INTO international VALUES (24,'WebGUI',7,'Ê®ÔÂ');
INSERT INTO international VALUES (25,'UserSubmission',7,'¼ÌÐøÉóºË');
INSERT INTO international VALUES (25,'WebGUI',7,'Ê®Ò»ÔÂ');
INSERT INTO international VALUES (26,'UserSubmission',7,'¾Ü¾ø');
INSERT INTO international VALUES (26,'WebGUI',7,'Ê®¶þÔÂ');
INSERT INTO international VALUES (27,'UserSubmission',7,'±à¼­');
INSERT INTO international VALUES (27,'WebGUI',7,'ÐÇÆÚÈÕ');
INSERT INTO international VALUES (28,'UserSubmission',7,'·µ»Ø¸å¼þÁÐ±í');
INSERT INTO international VALUES (28,'WebGUI',7,'ÐÇÆÚÒ»');
INSERT INTO international VALUES (29,'UserSubmission',7,'ÓÃ»§Í¶¸åÏµÍ³');
INSERT INTO international VALUES (29,'WebGUI',7,'ÐÇÆÚ¶þ');
INSERT INTO international VALUES (30,'WebGUI',7,'ÐÇÆÚÈý');
INSERT INTO international VALUES (31,'WebGUI',7,'ÐÇÆÚËÄ');
INSERT INTO international VALUES (32,'WebGUI',7,'ÐÇÆÚÎå');
INSERT INTO international VALUES (33,'WebGUI',7,'ÐÇÆÚÁù');
INSERT INTO international VALUES (34,'WebGUI',7,'ÉèÖÃÈÕÆÚ');
INSERT INTO international VALUES (35,'WebGUI',7,'¹ÜÀí¹¦ÄÜ');
INSERT INTO international VALUES (36,'WebGUI',7,'Äú±ØÐëÊÇÏµÍ³¹ÜÀíÔ±²ÅÄÜÊ¹ÓÃ´Ë¹¦ÄÜ¡£ÇëÁªÏµÄúµÄÏµÍ³¹ÜÀíÔ±¡£ÒÔÏÂÊÇ±¾ÏµÍ³µÄÏµÍ³¹ÜÀíÔ±Çåµ¥£º');
INSERT INTO international VALUES (37,'WebGUI',7,'È¨ÏÞ±»¾Ü¾ø£¡');
INSERT INTO international VALUES (404,'WebGUI',7,'µÚÒ»Ò³');
INSERT INTO international VALUES (38,'WebGUI',7,'ÄúÃ»ÓÐ×ã¹»µÄÈ¨ÏÞÖ´ÐÐ´ËÏî²Ù×÷¡£Çë^a(µÇÂ¼);È»ºóÔÙÊÔÒ»´Î¡£');
INSERT INTO international VALUES (39,'WebGUI',7,'¶Ô²»Æð£¬ÄúÃ»ÓÐ×ã¹»µÄÈ¨ÏÞ·ÃÎÊÒ»Ò³¡£');
INSERT INTO international VALUES (40,'WebGUI',7,'ÏµÍ³×é¼þ');
INSERT INTO international VALUES (41,'WebGUI',7,'Äú½«ÒªÉ¾³ýÒ»¸öÏµÍ³×é¼þ¡£Èç¹ûÄú¼ÌÐø£¬ÏµÍ³¹¦ÄÜ¿ÉÄÜ»áÊÜµ½Ó°Ïì¡£');
INSERT INTO international VALUES (42,'WebGUI',7,'ÇëÈ·ÈÏ');
INSERT INTO international VALUES (43,'WebGUI',7,'ÄúÊÇ·ñÈ·¶¨ÒªÉ¾³ý´ËÄÚÈÝÂð£¿');
INSERT INTO international VALUES (44,'WebGUI',7,'ÊÇµÄ£¬ÎÒÈ·¶¨¡£');
INSERT INTO international VALUES (45,'WebGUI',7,'²»£¬ÎÒ°´´íÁË¡£');
INSERT INTO international VALUES (46,'WebGUI',7,'ÎÒµÄÕÊ»§');
INSERT INTO international VALUES (47,'WebGUI',7,'Ê×Ò³');
INSERT INTO international VALUES (48,'WebGUI',7,'»¶Ó­£¡');
INSERT INTO international VALUES (49,'WebGUI',7,'µã»÷ <a href=\"^;?op=logout\">´Ë´¦</a> ÍË³öµÇÂ¼¡£');
INSERT INTO international VALUES (50,'WebGUI',7,'ÕÊ»§');
INSERT INTO international VALUES (51,'WebGUI',7,'ÃÜÂë');
INSERT INTO international VALUES (52,'WebGUI',7,'µÇÂ¼');
INSERT INTO international VALUES (53,'WebGUI',7,'´òÓ¡±¾Ò³');
INSERT INTO international VALUES (54,'WebGUI',7,'´´½¨ÕÊ»§');
INSERT INTO international VALUES (55,'WebGUI',7,'ÃÜÂë£¨È·ÈÏ£©');
INSERT INTO international VALUES (56,'WebGUI',7,'µç×ÓÓÊ¼þ');
INSERT INTO international VALUES (57,'WebGUI',7,'´ËÏîÖ»ÔÚÄúÏ£ÍûÊ¹ÓÃµ½ÐèÒªµç×ÓÓÊ¼þµÄ¹¦ÄÜµÄÊ±ºòÓÐÓÃ¡£');
INSERT INTO international VALUES (58,'WebGUI',7,'ÎÒÒÑ¾­ÓÐÁËÒ»¸öÕÊ»§¡£');
INSERT INTO international VALUES (59,'WebGUI',7,'ÎÒÍü¼ÇÁËÃÜÂë¡£');
INSERT INTO international VALUES (60,'WebGUI',7,'ÄúÊÇ·ñÕæµÄÏ£Íû×¢ÏúÄúµÄÕÊ»§£¿Èç¹ûÄú¼ÌÐø£¬ÄúµÄÕÊ»§ÐÅÏ¢½«±»ÓÀ¾ÃÉ¾³ý¡£');
INSERT INTO international VALUES (61,'WebGUI',7,'¸üÐÂÕÊ»§ÐÅÏ¢');
INSERT INTO international VALUES (62,'WebGUI',7,'±£´æ');
INSERT INTO international VALUES (63,'WebGUI',7,'½øÈë¹ÜÀí¡£');
INSERT INTO international VALUES (64,'WebGUI',7,'ÍË³öµÇÂ¼¡£');
INSERT INTO international VALUES (65,'WebGUI',7,'ÇëÉ¾³ýÎÒµÄÕÊ»§¡£');
INSERT INTO international VALUES (66,'WebGUI',7,'ÓÃ»§µÇÂ¼');
INSERT INTO international VALUES (67,'WebGUI',7,'´´½¨ÐÂÕÊ»§¡£');
INSERT INTO international VALUES (68,'WebGUI',7,'ÄúÊäÈëµÄÕÊ»§ÐÅÏ¢ÎÞÐ§¡£¿ÉÄÜÊÇÄúÊäÈëµÄÕÊ»§²»´æÔÚ£¬»òÊäÈëÁË´íÎóµÄÃÜÂë¡£');
INSERT INTO international VALUES (69,'WebGUI',7,'Èç¹ûÄúÐèÒªÐ­Öú£¬ÇëÁªÏµÏµÍ³¹ÜÀíÔ±¡£');
INSERT INTO international VALUES (70,'WebGUI',7,'´íÎó');
INSERT INTO international VALUES (71,'WebGUI',7,'»Ö¸´ÃÜÂë');
INSERT INTO international VALUES (72,'WebGUI',7,'»Ö¸´');
INSERT INTO international VALUES (73,'WebGUI',7,'ÓÃ»§µÇÂ¼');
INSERT INTO international VALUES (74,'WebGUI',7,'ÕÊ»§ÐÅÏ¢');
INSERT INTO international VALUES (75,'WebGUI',7,'ÄúµÄÕÊ»§ÐÅÏ¢ÒÑ¾­·¢ËÍµ½ÄúµÄµç×ÓÓÊ¼þÖÐ¡£');
INSERT INTO international VALUES (76,'WebGUI',7,'¶Ô²»Æð£¬´Ëµç×ÓÓÊ¼þµØÖ·²»ÔÚÏµÍ³Êý¾Ý¿âÖÐ¡£');
INSERT INTO international VALUES (77,'WebGUI',7,'¶Ô²»Æð£¬´ËÕÊ»§ÃûÒÑ±»ÆäËûÓÃ»§Ê¹ÓÃ¡£ÇëÁíÍâÑ¡ÔñÒ»¸öÓÃ»§Ãû¡£ÎÒÃÇ½¨ÒéÄúÊ¹ÓÃÒÔÏÂÃû×Ö×÷ÎªµÇÂ¼Ãû£º');
INSERT INTO international VALUES (78,'WebGUI',7,'ÄúÊäÈëµÄÃÜÂë²»Ò»ÖÂ£¬ÇëÖØÐÂÊäÈë¡£');
INSERT INTO international VALUES (79,'WebGUI',7,'²»ÄÜÁ¬½Óµ½Ä¿Â¼·þÎñÆ÷¡£');
INSERT INTO international VALUES (80,'WebGUI',7,'´´½¨ÕÊ»§³É¹¦£¡');
INSERT INTO international VALUES (81,'WebGUI',7,'¸üÐÂÕÊ»§³É¹¦£¡');
INSERT INTO international VALUES (82,'WebGUI',7,'¹ÜÀí¹¦ÄÜ...');
INSERT INTO international VALUES (536,'WebGUI',7,'ÐÂÓÃ»§ ^@; ¸Õ¼ÓÈë±¾Õ¾¡£');
INSERT INTO international VALUES (84,'WebGUI',7,'ÓÃ»§×é');
INSERT INTO international VALUES (85,'WebGUI',7,'ÃèÊö');
INSERT INTO international VALUES (86,'WebGUI',7,'ÄúÈ·ÐÅÒªÉ¾³ý´ËÓÃ»§×éÂð£¿´ËÏî²Ù×÷½«ÓÀ¾ÃÉ¾³ý´ËÓÃ»§×é£¬²¢È¡Ïû´ËÓÃ»§×éËùÓÐÏà¹ØÈ¨ÏÞ¡£');
INSERT INTO international VALUES (87,'WebGUI',7,'±à¼­ÓÃ»§×é');
INSERT INTO international VALUES (88,'WebGUI',7,'ÓÃ»§×é³ÉÔ±');
INSERT INTO international VALUES (89,'WebGUI',7,'ÓÃ»§×é');
INSERT INTO international VALUES (90,'WebGUI',7,'Ìí¼ÓÐÂ×é¡£');
INSERT INTO international VALUES (91,'WebGUI',7,'ÉÏÒ»Ò³');
INSERT INTO international VALUES (92,'WebGUI',7,'ÏÂÒ»Ò³');
INSERT INTO international VALUES (93,'WebGUI',7,'°ïÖú');
INSERT INTO international VALUES (94,'WebGUI',7,'²Î¿¼');
INSERT INTO international VALUES (95,'WebGUI',7,'°ïÖúË÷Òý');
INSERT INTO international VALUES (99,'WebGUI',7,'±êÌâ');
INSERT INTO international VALUES (100,'WebGUI',7,'Meta ±êÊ¶');
INSERT INTO international VALUES (101,'WebGUI',7,'ÄúÈ·ÐÅÒªÉ¾³ý´ËÒ³ÃæÒÔ¼°Ò³ÃæÄÚµÄËùÓÐÄÚÈÝºÍ×é¼þÂð£¿');
INSERT INTO international VALUES (102,'WebGUI',7,'±à¼­Ò³Ãæ');
INSERT INTO international VALUES (103,'WebGUI',7,'Ò³ÃæÃèÊö');
INSERT INTO international VALUES (104,'WebGUI',7,'Ò³Ãæ URL');
INSERT INTO international VALUES (105,'WebGUI',7,'·ç¸ñ');
INSERT INTO international VALUES (106,'WebGUI',7,'Ñ¡Ôñ¡°ÊÇ¡±½«±¾Ò³ÃæÏÂ¼¶ËùÓÐÒ³Ãæ·ç¸ñ¸ÄÎª´Ë·ç¸ñ¡£');
INSERT INTO international VALUES (107,'WebGUI',7,'È¨ÏÞÉèÖÃ');
INSERT INTO international VALUES (108,'WebGUI',7,'ÓµÓÐÕß');
INSERT INTO international VALUES (109,'WebGUI',7,'ÓµÓÐÕß·ÃÎÊÈ¨ÏÞ£¿');
INSERT INTO international VALUES (110,'WebGUI',7,'ÓµÓÐÕß±à¼­È¨ÏÞ£¿');
INSERT INTO international VALUES (111,'WebGUI',7,'ÓÃ»§×é');
INSERT INTO international VALUES (112,'WebGUI',7,'ÓÃ»§×é·ÃÎÊÈ¨ÏÞ£¿');
INSERT INTO international VALUES (113,'WebGUI',7,'ÓÃ»§×é±à¼­È¨ÏÞ£¿');
INSERT INTO international VALUES (114,'WebGUI',7,'ÈÎºÎÈË¿É·ÃÎÊ£¿');
INSERT INTO international VALUES (115,'WebGUI',7,'ÈÎºÎÈË¿É±à¼­£¿');
INSERT INTO international VALUES (116,'WebGUI',7,'Ñ¡Ôñ¡°ÊÇ¡±½«±¾Ò³ÃæÏÂ¼¶ËùÓÐÒ³ÃæÈ¨ÏÞ¸ÄÎª´ËÈ¨ÏÞÉèÖÃ¡£');
INSERT INTO international VALUES (117,'WebGUI',7,'±à¼­ÓÃ»§ÉèÖÃ');
INSERT INTO international VALUES (118,'WebGUI',7,'ÄäÃûÓÃ»§×¢²á');
INSERT INTO international VALUES (119,'WebGUI',7,'Ä¬ÈÏÓÃ»§ÈÏÖ¤·½Ê½');
INSERT INTO international VALUES (120,'WebGUI',7,'Ä¬ÈÏ LDAP URL');
INSERT INTO international VALUES (121,'WebGUI',7,'Ä¬ÈÏ LDAP Identity');
INSERT INTO international VALUES (122,'WebGUI',7,'LDAP Identity Ãû');
INSERT INTO international VALUES (123,'WebGUI',7,'LDAP Password Ãû');
INSERT INTO international VALUES (124,'WebGUI',7,'±à¼­¹«Ë¾ÐÅÏ¢');
INSERT INTO international VALUES (125,'WebGUI',7,'¹«Ë¾Ãû');
INSERT INTO international VALUES (126,'WebGUI',7,'¹«Ë¾µç×ÓÓÊ¼þµØÖ·');
INSERT INTO international VALUES (127,'WebGUI',7,'¹«Ë¾Á´½Ó');
INSERT INTO international VALUES (130,'WebGUI',7,'×î´ó¸½¼þ´óÐ¡');
INSERT INTO international VALUES (133,'WebGUI',7,'±à¼­ÓÊ¼þÉèÖÃ');
INSERT INTO international VALUES (134,'WebGUI',7,'»Ö¸´ÃÜÂëÓÊ¼þÄÚÈÝ');
INSERT INTO international VALUES (135,'WebGUI',7,'ÓÊ¼þ·þÎñÆ÷');
INSERT INTO international VALUES (138,'WebGUI',7,'ÊÇ');
INSERT INTO international VALUES (139,'WebGUI',7,'·ñ');
INSERT INTO international VALUES (140,'WebGUI',7,'±à¼­Ò»°ãÉèÖÃ');
INSERT INTO international VALUES (141,'WebGUI',7,'Ä¬ÈÏÎ´ÕÒµ½Ò³Ãæ');
INSERT INTO international VALUES (142,'WebGUI',7,'¶Ô»°³¬Ê±');
INSERT INTO international VALUES (143,'WebGUI',7,'¹ÜÀíÉèÖÃ');
INSERT INTO international VALUES (144,'WebGUI',7,'²é¿´Í³¼ÆÐÅÏ¢¡£');
INSERT INTO international VALUES (145,'WebGUI',7,'ÏµÍ³°æ±¾');
INSERT INTO international VALUES (146,'WebGUI',7,'»î¶¯¶Ô»°');
INSERT INTO international VALUES (147,'WebGUI',7,'Ò³ÃæÊý');
INSERT INTO international VALUES (148,'WebGUI',7,'×é¼þÊý');
INSERT INTO international VALUES (149,'WebGUI',7,'ÓÃ»§Êý');
INSERT INTO international VALUES (533,'WebGUI',7,'<b>²»°üÀ¨</b>ËÑË÷×Ö');
INSERT INTO international VALUES (532,'WebGUI',7,'°üÀ¨<b>ÖÁÉÙÒ»¸ö</b>ËÑË÷×Ö');
INSERT INTO international VALUES (151,'WebGUI',7,'·ç¸ñÃû');
INSERT INTO international VALUES (505,'WebGUI',7,'Ìí¼ÓÒ»¸öÐÂÄ£°å');
INSERT INTO international VALUES (504,'WebGUI',7,'Ä£°å');
INSERT INTO international VALUES (502,'WebGUI',7,'ÄúÈ·ÐÅÒªÉ¾³ý´ËÄ£°å£¬²¢½«ËùÓÐÊ¹ÓÃ´ËÄ£°åµÄÒ³ÃæÉèÎªÄ¬ÈÏÄ£°å£¿');
INSERT INTO international VALUES (154,'WebGUI',7,'·ç¸ñµ¥');
INSERT INTO international VALUES (155,'WebGUI',7,'ÄúÈ·¶¨ÒªÉ¾³ý´ËÒ³Ãæ·ç¸ñ£¬²¢½«ËùÓÐÊ¹ÓÃ´Ë·ç¸ñµÄÒ³Ãæ·ç¸ñÉèÎª¡°°²È«Ä£Ê½¡±·ç¸ñ£¿');
INSERT INTO international VALUES (156,'WebGUI',7,'±à¼­·ç¸ñ');
INSERT INTO international VALUES (157,'WebGUI',7,'·ç¸ñ');
INSERT INTO international VALUES (158,'WebGUI',7,'Ìí¼ÓÐÂ·ç¸ñ¡£');
INSERT INTO international VALUES (160,'WebGUI',7,'Ìá½»ÈÕÆÚ');
INSERT INTO international VALUES (161,'WebGUI',7,'Ìá½»ÈË');
INSERT INTO international VALUES (162,'WebGUI',7,'ÄúÊÇ·ñÈ·¶¨ÒªÇå¿ÕÀ¬»øÏäÖÐËùÓÐÒ³ÃæºÍ×é¼þÂð£¿');
INSERT INTO international VALUES (163,'WebGUI',7,'Ìí¼ÓÓÃ»§');
INSERT INTO international VALUES (164,'WebGUI',7,'ÓÃ»§ÈÏÖ¤·½Ê½');
INSERT INTO international VALUES (165,'WebGUI',7,'LDAP URL');
INSERT INTO international VALUES (166,'WebGUI',7,'Á¬½Ó DN');
INSERT INTO international VALUES (167,'WebGUI',7,'ÄúÊÇ·ñÈ·¶¨ÒªÉ¾³ý´ËÓÃ»§Âð£¿×¢ÒâÉ¾³ýÓÃ»§½«ÓÀ¾ÃÉ¾³ý¸ÃÓÃ»§µÄËùÓÐÐÅÏ¢¡£');
INSERT INTO international VALUES (168,'WebGUI',7,'±à¼­ÓÃ»§');
INSERT INTO international VALUES (169,'WebGUI',7,'Ìí¼ÓÐÂÓÃ»§¡£');
INSERT INTO international VALUES (170,'WebGUI',7,'ËÑË÷');
INSERT INTO international VALUES (171,'WebGUI',7,'¿ÉÊÓ»¯±à¼­');
INSERT INTO international VALUES (174,'WebGUI',7,'ÊÇ·ñÏÔÊ¾±êÌâ£¿');
INSERT INTO international VALUES (175,'WebGUI',7,'ÊÇ·ñÖ´ÐÐºêÃüÁî£¿');
INSERT INTO international VALUES (228,'WebGUI',7,'±à¼­ÏûÏ¢...');
INSERT INTO international VALUES (229,'WebGUI',7,'±êÌâ');
INSERT INTO international VALUES (230,'WebGUI',7,'ÏûÏ¢');
INSERT INTO international VALUES (231,'WebGUI',7,'·¢²¼ÐÂÏûÏ¢...');
INSERT INTO international VALUES (232,'WebGUI',7,'ÎÞ±êÌâ');
INSERT INTO international VALUES (233,'WebGUI',7,'(eom)');
INSERT INTO international VALUES (234,'WebGUI',7,'·¢±í»ØÓ¦...');
INSERT INTO international VALUES (237,'WebGUI',7,'±êÌâ£º');
INSERT INTO international VALUES (238,'WebGUI',7,'×÷Õß£º');
INSERT INTO international VALUES (239,'WebGUI',7,'ÈÕÆÚ£º');
INSERT INTO international VALUES (240,'WebGUI',7,'ÏûÏ¢ ID:');
INSERT INTO international VALUES (244,'WebGUI',7,'×÷Õß');
INSERT INTO international VALUES (245,'WebGUI',7,'ÈÕÆÚ');
INSERT INTO international VALUES (304,'WebGUI',7,'ÓïÑÔ');
INSERT INTO international VALUES (306,'WebGUI',7,'ÓÃ»§Ãû°ó¶¨');
INSERT INTO international VALUES (307,'WebGUI',7,'ÊÇ·ñÊ¹ÓÃÄ¬ÈÏ meta ±êÊ¶·û£¿');
INSERT INTO international VALUES (308,'WebGUI',7,'±à¼­ÓÃ»§ÊôÐÔÉèÖÃ');
INSERT INTO international VALUES (309,'WebGUI',7,'ÊÇ·ñÔÊÐíÊ¹ÓÃÕæÊµÐÕÃû£¿');
INSERT INTO international VALUES (310,'WebGUI',7,'ÊÇ·ñÔÊÐíÊ¹ÓÃÀ©Õ¹ÁªÏµÐÅÏ¢£¿');
INSERT INTO international VALUES (311,'WebGUI',7,'ÊÇ·ñÔÊÐíÊ¹ÓÃ¼ÒÍ¥ÐÅÏ¢£¿');
INSERT INTO international VALUES (312,'WebGUI',7,'ÊÇ·ñÔÊÐíÊ¹ÓÃÉÌÒµÐÅÏ¢£¿');
INSERT INTO international VALUES (313,'WebGUI',7,'ÊÇ·ñÔÊÐíÊ¹ÓÃÆäËûÐÅÏ¢£¿');
INSERT INTO international VALUES (314,'WebGUI',7,'ÐÕ');
INSERT INTO international VALUES (315,'WebGUI',7,'ÖÐ¼äÃû');
INSERT INTO international VALUES (316,'WebGUI',7,'Ãû');
INSERT INTO international VALUES (317,'WebGUI',7,'<a href=\"http://www.icq.com\">ICQ</a> UIN');
INSERT INTO international VALUES (318,'WebGUI',7,'<a href=\"http://www.aol.com/aim/homenew.adp\">AIM</a> ID');
INSERT INTO international VALUES (319,'WebGUI',7,'<a href=\"http://messenger.msn.com/\">MSN Messenger</a> ID');
INSERT INTO international VALUES (320,'WebGUI',7,'<a href=\"http://messenger.yahoo.com/\">Yahoo! Messenger</a> ID');
INSERT INTO international VALUES (321,'WebGUI',7,'ÒÆ¶¯µç»°');
INSERT INTO international VALUES (322,'WebGUI',7,'´«ºô');
INSERT INTO international VALUES (323,'WebGUI',7,'¼ÒÍ¥×¡Ö·');
INSERT INTO international VALUES (324,'WebGUI',7,'³ÇÊÐ');
INSERT INTO international VALUES (325,'WebGUI',7,'Ê¡·Ý');
INSERT INTO international VALUES (326,'WebGUI',7,'ÓÊÕþ±àÂë');
INSERT INTO international VALUES (327,'WebGUI',7,'¹ú¼Ò');
INSERT INTO international VALUES (328,'WebGUI',7,'×¡Õ¬µç»°');
INSERT INTO international VALUES (329,'WebGUI',7,'µ¥Î»µØÖ·');
INSERT INTO international VALUES (330,'WebGUI',7,'³ÇÊÐ');
INSERT INTO international VALUES (331,'WebGUI',7,'Ê¡·Ý');
INSERT INTO international VALUES (332,'WebGUI',7,'ÓÊÕþ±àÂë');
INSERT INTO international VALUES (333,'WebGUI',7,'¹ú¼Ò');
INSERT INTO international VALUES (334,'WebGUI',7,'µ¥Î»µç»°');
INSERT INTO international VALUES (335,'WebGUI',7,'ÐÔ±ð');
INSERT INTO international VALUES (336,'WebGUI',7,'ÉúÈÕ');
INSERT INTO international VALUES (337,'WebGUI',7,'¸öÈËÍøÒ³');
INSERT INTO international VALUES (338,'WebGUI',7,'±à¼­ÓÃ»§ÊôÐÔ');
INSERT INTO international VALUES (339,'WebGUI',7,'ÄÐ');
INSERT INTO international VALUES (340,'WebGUI',7,'Å®');
INSERT INTO international VALUES (341,'WebGUI',7,'±à¼­ÓÃ»§ÊôÐÔ¡£');
INSERT INTO international VALUES (342,'WebGUI',7,'±à¼­ÕÊ»§ÐÅÏ¢');
INSERT INTO international VALUES (343,'WebGUI',7,'²é¿´ÓÃ»§ÊôÐÔ¡£');
INSERT INTO international VALUES (351,'WebGUI',7,'ÏûÏ¢');
INSERT INTO international VALUES (345,'WebGUI',7,'²»ÊÇ±¾Õ¾ÓÃ»§');
INSERT INTO international VALUES (346,'WebGUI',7,'´ËÓÃ»§²»ÔÙÊÇ±¾Õ¾ÓÃ»§¡£ÎÞ·¨Ìá¹©´ËÓÃ»§µÄ¸ü¶àÐÅÏ¢¡£');
INSERT INTO international VALUES (347,'WebGUI',7,'²é¿´ÓÃ»§ÊôÐÔ£º');
INSERT INTO international VALUES (348,'WebGUI',7,'ÐÕÃû');
INSERT INTO international VALUES (349,'WebGUI',7,'×îÐÂ°æ±¾');
INSERT INTO international VALUES (350,'WebGUI',7,'½áÊø');
INSERT INTO international VALUES (352,'WebGUI',7,'·¢³öÈÕÆÚ');
INSERT INTO international VALUES (471,'WebGUI',7,'±à¼­ÓÃ»§ÊôÐÔÏî');
INSERT INTO international VALUES (355,'WebGUI',7,'Ä¬ÈÏ');
INSERT INTO international VALUES (356,'WebGUI',7,'Ä£°å');
INSERT INTO international VALUES (357,'WebGUI',7,'ÐÂÎÅ');
INSERT INTO international VALUES (358,'WebGUI',7,'×óµ¼º½');
INSERT INTO international VALUES (359,'WebGUI',7,'ÓÒµ¼º½');
INSERT INTO international VALUES (360,'WebGUI',7,'Ò»¼ÓÈý');
INSERT INTO international VALUES (361,'WebGUI',7,'Èý¼ÓÒ»');
INSERT INTO international VALUES (362,'WebGUI',7,'Æ½·Ö');
INSERT INTO international VALUES (363,'WebGUI',7,'Ä£°å¶¨Î»');
INSERT INTO international VALUES (364,'WebGUI',7,'ËÑË÷');
INSERT INTO international VALUES (365,'WebGUI',7,'ËÑË÷½á¹û...');
INSERT INTO international VALUES (366,'WebGUI',7,'Ã»ÓÐÕÒµ½·ûºÏËÑË÷Ìõ¼þµÄÒ³Ãæ¡£');
INSERT INTO international VALUES (368,'WebGUI',7,'½«´ËÓÃ»§¼ÓÈëÐÂÓÃ»§×é¡£');
INSERT INTO international VALUES (369,'WebGUI',7,'¹ýÆÚÈÕÆÚ');
INSERT INTO international VALUES (370,'WebGUI',7,'±à¼­ÓÃ»§·Ö×é');
INSERT INTO international VALUES (371,'WebGUI',7,'Ìí¼ÓÓÃ»§·Ö×é');
INSERT INTO international VALUES (372,'WebGUI',7,'±à¼­ÓÃ»§ËùÊô×éÈº');
INSERT INTO international VALUES (605,'WebGUI',1,'Add Groups');
INSERT INTO international VALUES (374,'WebGUI',7,'¹ÜÀí°ü¹ü¡£');
INSERT INTO international VALUES (375,'WebGUI',7,'Ñ¡ÔñÒªÕ¹¿ªµÄ°ü¹ü¡£');
INSERT INTO international VALUES (376,'WebGUI',7,'°ü¹ü');
INSERT INTO international VALUES (377,'WebGUI',7,'°ü¹ü¹ÜÀíÔ±»òÏµÍ³¹ÜÀíÔ±Ã»ÓÐ¶¨Òå°ü¹ü¡£');
INSERT INTO international VALUES (31,'UserSubmission',7,'ÄÚÈÝ');
INSERT INTO international VALUES (32,'UserSubmission',7,'Í¼Æ¬');
INSERT INTO international VALUES (33,'UserSubmission',7,'¸½¼þ');
INSERT INTO international VALUES (34,'UserSubmission',7,'×ª»»»Ø³µ');
INSERT INTO international VALUES (35,'UserSubmission',7,'±êÌâ');
INSERT INTO international VALUES (21,'EventsCalendar',7,'ÊÇ·ñÖ´ÐÐÌí¼ÓÊÂÎñ£¿');
INSERT INTO international VALUES (378,'WebGUI',7,'ÓÃ»§ ID');
INSERT INTO international VALUES (379,'WebGUI',7,'ÓÃ»§×é ID');
INSERT INTO international VALUES (380,'WebGUI',7,'·ç¸ñ ID');
INSERT INTO international VALUES (381,'WebGUI',7,'ÏµÍ³ÊÕµ½Ò»¸öÎÞÐ§µÄ±íµ¥ÇëÇó£¬ÎÞ·¨¼ÌÐø¡£µ±Í¨¹ý±íµ¥ÊäÈëÁËÒ»Ð©·Ç·¨×Ö·û£¬Í¨³£»áµ¼ÖÂÕâ¸ö½á¹û¡£Çë°´ä¯ÀÀÆ÷µÄ·µ»Ø°´Å¦·µ»ØÉÏÒ³ÖØÐÂÊäÈë¡£');
INSERT INTO international VALUES (1,'DownloadManager',7,'ÏÂÔØ¹ÜÀí');
INSERT INTO international VALUES (3,'DownloadManager',7,'ÊÇ·ñÖ´ÐÐÌí¼ÓÎÄ¼þ£¿');
INSERT INTO international VALUES (5,'DownloadManager',7,'ÎÄ¼þ±êÌâ');
INSERT INTO international VALUES (6,'DownloadManager',7,'ÏÂÔØÎÄ¼þ');
INSERT INTO international VALUES (7,'DownloadManager',7,'ÏÂÔØÓÃ»§×é');
INSERT INTO international VALUES (8,'DownloadManager',7,'¼ò½é');
INSERT INTO international VALUES (9,'DownloadManager',7,'±à¼­ÏÂÔØ¹ÜÀíÔ±');
INSERT INTO international VALUES (10,'DownloadManager',7,'±à¼­ÏÂÔØ');
INSERT INTO international VALUES (11,'DownloadManager',7,'Ìí¼ÓÐÂÏÂÔØ');
INSERT INTO international VALUES (12,'DownloadManager',7,'ÄúÊÇ·ñÈ·¶¨ÒªÉ¾³ý´ËÏÂÔØÏîÂð£¿');
INSERT INTO international VALUES (22,'DownloadManager',7,'ÊÇ·ñÖ´ÐÐÌí¼ÓÏÂÔØ£¿');
INSERT INTO international VALUES (14,'DownloadManager',7,'ÎÄ¼þ');
INSERT INTO international VALUES (15,'DownloadManager',7,'ÃèÊö');
INSERT INTO international VALUES (16,'DownloadManager',7,'ÉÏÔØÈÕÆÚ');
INSERT INTO international VALUES (15,'Article',7,'¿¿ÓÒ');
INSERT INTO international VALUES (16,'Article',7,'¿¿×ó');
INSERT INTO international VALUES (17,'Article',7,'¾ÓÖÐ');
INSERT INTO international VALUES (37,'UserSubmission',7,'É¾³ý');
INSERT INTO international VALUES (13,'SQLReport',7,'Convert carriage returns?');
INSERT INTO international VALUES (17,'DownloadManager',7,'ÆäËû°æ±¾ #1');
INSERT INTO international VALUES (18,'DownloadManager',7,'ÆäËû°æ±¾ #2');
INSERT INTO international VALUES (19,'DownloadManager',7,'Ã»ÓÐÄú¿ÉÒÔÏÂÔØµÄÎÄ¼þ¡£');
INSERT INTO international VALUES (14,'EventsCalendar',7,'¿ªÊ¼ÈÕÆÚ');
INSERT INTO international VALUES (15,'EventsCalendar',7,'½áÊøÈÕÆÚ');
INSERT INTO international VALUES (20,'DownloadManager',7,'ÔÚºóÃæ±ê×¢Ò³Âë');
INSERT INTO international VALUES (14,'SQLReport',7,'Paginate After');
INSERT INTO international VALUES (16,'EventsCalendar',7,'ÐÐÊÂÀú²¼¾Ö');
INSERT INTO international VALUES (17,'EventsCalendar',7,'ÁÐ±í·½Ê½');
INSERT INTO international VALUES (18,'EventsCalendar',7,'Calendar Month');
INSERT INTO international VALUES (19,'EventsCalendar',7,'ÔÚºóÃæ±ê×¢Ò³Âë');
INSERT INTO international VALUES (529,'WebGUI',7,'½á¹û');
INSERT INTO international VALUES (383,'WebGUI',7,'Ãû×Ö');
INSERT INTO international VALUES (384,'WebGUI',7,'ÎÄ¼þ');
INSERT INTO international VALUES (385,'WebGUI',7,'²ÎÊý');
INSERT INTO international VALUES (386,'WebGUI',7,'±à¼­Í¼Ïó');
INSERT INTO international VALUES (387,'WebGUI',7,'ÉÏÔØÈË');
INSERT INTO international VALUES (388,'WebGUI',7,'ÉÏÔØÈÕÆÚ');
INSERT INTO international VALUES (389,'WebGUI',7,'Í¼Ïó ID');
INSERT INTO international VALUES (390,'WebGUI',7,'ÏÔÊ¾Í¼Ïó...');
INSERT INTO international VALUES (391,'WebGUI',7,'É¾³ý¸½¼ÓÎÄ¼þ¡£');
INSERT INTO international VALUES (392,'WebGUI',7,'ÄúÈ·¶¨ÒªÉ¾³ý´ËÍ¼ÏóÂð£¿');
INSERT INTO international VALUES (393,'WebGUI',7,'¹ÜÀíÍ¼Ïó');
INSERT INTO international VALUES (394,'WebGUI',7,'¹ÜÀíÍ¼Ïó¡£');
INSERT INTO international VALUES (395,'WebGUI',7,'Ìí¼ÓÐÂÍ¼Ïó¡£');
INSERT INTO international VALUES (396,'WebGUI',7,'²é¿´Í¼Ïó');
INSERT INTO international VALUES (397,'WebGUI',7,'·µ»ØÍ¼ÏóÁÐ±í¡£');
INSERT INTO international VALUES (398,'WebGUI',7,'ÎÄµµÀàÐÍ¶¨Òå');
INSERT INTO international VALUES (399,'WebGUI',7,'·ÖÎö±¾Ò³Ãæ¡£');
INSERT INTO international VALUES (400,'WebGUI',7,'ÊÇ·ñ×èÖ¹´úÀí»º´æ£¿');
INSERT INTO international VALUES (401,'WebGUI',7,'ÄúÊÇ·ñÈ·¶¨ÒªÉ¾³ý´ËÌõÏûÏ¢ÒÔ¼°´ËÌõÏûÏ¢µÄËùÓÐÏßË÷£¿');
INSERT INTO international VALUES (402,'WebGUI',7,'ÄúÒªÔÄ¶ÁµÄÏûÏ¢²»´æÔÚ¡£');
INSERT INTO international VALUES (403,'WebGUI',7,'²»¸æËßÄã');
INSERT INTO international VALUES (405,'WebGUI',7,'×îºóÒ»Ò³');
INSERT INTO international VALUES (406,'WebGUI',7,'¿ìÕÕ´óÐ¡');
INSERT INTO international VALUES (21,'DownloadManager',7,'ÏÔÊ¾¿ìÕÕ');
INSERT INTO international VALUES (407,'WebGUI',7,'µã»÷´Ë´¦×¢²á¡£');
INSERT INTO international VALUES (15,'SQLReport',7,'Preprocess macros on query?');
INSERT INTO international VALUES (16,'SQLReport',7,'Debug?');
INSERT INTO international VALUES (17,'SQLReport',7,'<b>Debug:</b> Query:');
INSERT INTO international VALUES (18,'SQLReport',7,'There were no results for this query.');
INSERT INTO international VALUES (506,'WebGUI',7,'¹ÜÀíÄ£°å');
INSERT INTO international VALUES (535,'WebGUI',7,'µ±ÐÂÓÃ»§×¢²áÊ±Í¨ÖªÓÃ»§×é');
INSERT INTO international VALUES (353,'WebGUI',7,'ÏÖÔÚÄúµÄÊÕ¼þÏäÖÐÃ»ÓÐÏûÏ¢¡£');
INSERT INTO international VALUES (530,'WebGUI',7,'ËÑË÷<b>ËùÓÐ</b>¹Ø¼ü×Ö');
INSERT INTO international VALUES (408,'WebGUI',7,'¹ÜÀí¸ùÒ³Ãæ');
INSERT INTO international VALUES (409,'WebGUI',7,'Ìí¼ÓÐÂ¸ùÒ³Ãæ¡£');
INSERT INTO international VALUES (410,'WebGUI',7,'¹ÜÀí¸ùÒ³Ãæ¡£');
INSERT INTO international VALUES (411,'WebGUI',7,'Ä¿Â¼±êÌâ');
INSERT INTO international VALUES (412,'WebGUI',7,'Ò³ÃæÃèÊö');
INSERT INTO international VALUES (9,'SiteMap',7,'ÏÔÊ¾¼ò½é£¿');
INSERT INTO international VALUES (18,'Article',7,'ÊÇ·ñÔÊÐíÌÖÂÛ£¿');
INSERT INTO international VALUES (19,'Article',7,'Ë­¿ÉÒÔ·¢±í£¿');
INSERT INTO international VALUES (20,'Article',7,'Ë­¿ÉÒÔ¹ÜÀí£¿');
INSERT INTO international VALUES (21,'Article',7,'±à¼­³¬Ê±');
INSERT INTO international VALUES (22,'Article',7,'×÷Õß');
INSERT INTO international VALUES (23,'Article',7,'ÈÕÆÚ');
INSERT INTO international VALUES (24,'Article',7,'·¢±í»ØÓ¦');
INSERT INTO international VALUES (25,'Article',7,'±à¼­»ØÓ¦');
INSERT INTO international VALUES (26,'Article',7,'É¾³ý»ØÓ¦');
INSERT INTO international VALUES (27,'Article',7,'·µ»ØÎÄÕÂ');
INSERT INTO international VALUES (711,'WebGUI',1,'Image Managers Group');
INSERT INTO international VALUES (28,'Article',7,'²é¿´»ØÓ¦');
INSERT INTO international VALUES (57,'Product',1,'Are you certain you wish to delete this template and set all the products using it to the default template?');
INSERT INTO international VALUES (53,'Product',1,'Edit Benefit');
INSERT INTO international VALUES (416,'WebGUI',7,'<h1>ÄúµÄÇëÇó³öÏÖÎÊÌâ</h1> \r\nÄúµÄÇëÇó³öÏÖÒ»¸ö´íÎó¡£Çë°´ä¯ÀÀÆ÷µÄ·µ»Ø°´Å¥·µ»ØÉÏÒ»Ò³ÖØÊÔÒ»´Î¡£Èç¹û´ËÏî´íÎó¼ÌÐø´æÔÚ£¬ÇëÁªÏµÎÒÃÇ£¬Í¬Ê±¸æËßÎÒÃÇÄúÔÚÊ²Ã´Ê±¼äÊ¹ÓÃÊ²Ã´¹¦ÄÜµÄÊ±ºò³öÏÖµÄÕâ¸ö´íÎó¡£Ð»Ð»£¡');
INSERT INTO international VALUES (417,'WebGUI',7,'<h1>°²È«¾¯±¨</h1>\r\n Äú·ÃÎÊµÄ×é¼þ²»ÔÚÕâÒ»Ò³ÉÏ¡£´ËÐÅÏ¢ÒÑ¾­·¢ËÍ¸øÏµÍ³¹ÜÀíÔ±¡£');
INSERT INTO international VALUES (418,'WebGUI',7,'HTML ¹ýÂË');
INSERT INTO international VALUES (419,'WebGUI',7,'Çå³ýËùÓÐµÄ±êÊ¶·û¡£');
INSERT INTO international VALUES (420,'WebGUI',7,'±£ÁôËùÓÐµÄ±êÊ¶·û¡£');
INSERT INTO international VALUES (421,'WebGUI',7,'±£Áô»ù±¾µÄ±êÊ¶·û¡£');
INSERT INTO international VALUES (422,'WebGUI',7,'<h1>µÇÂ¼Ê§°Ü</h1>\r\nÄúÊäÈëµÄÕÊ»§ÐÅÏ¢ÓÐÎó¡£');
INSERT INTO international VALUES (423,'WebGUI',7,'²é¿´»î¶¯¶Ô»°¡£');
INSERT INTO international VALUES (424,'WebGUI',7,'²é¿´µÇÂ¼ÀúÊ·¼ÇÂ¼¡£');
INSERT INTO international VALUES (425,'WebGUI',7,'»î¶¯¶Ô»°');
INSERT INTO international VALUES (426,'WebGUI',7,'µÇÂ¼ÀúÊ·¼ÇÂ¼');
INSERT INTO international VALUES (427,'WebGUI',7,'·ç¸ñ');
INSERT INTO international VALUES (428,'WebGUI',7,'ÓÃ»§ (ID)');
INSERT INTO international VALUES (429,'WebGUI',7,'µÇÂ¼Ê±¼ä');
INSERT INTO international VALUES (430,'WebGUI',7,'×îºó·ÃÎÊÒ³Ãæ');
INSERT INTO international VALUES (431,'WebGUI',7,'IP µØÖ·');
INSERT INTO international VALUES (432,'WebGUI',7,'¹ýÆÚ');
INSERT INTO international VALUES (433,'WebGUI',7,'ÓÃ»§¶Ë');
INSERT INTO international VALUES (434,'WebGUI',7,'×´Ì¬');
INSERT INTO international VALUES (435,'WebGUI',7,'¶Ô»°ÐÅºÅ');
INSERT INTO international VALUES (436,'WebGUI',7,'É±µô´Ë¶Ô»°');
INSERT INTO international VALUES (437,'WebGUI',7,'Í³¼ÆÐÅÏ¢');
INSERT INTO international VALUES (438,'WebGUI',7,'ÄúµÄÃû×Ö');
INSERT INTO international VALUES (439,'WebGUI',7,'¸öÈËÐÅÏ¢');
INSERT INTO international VALUES (440,'WebGUI',7,'ÁªÏµÐÅÏ¢');
INSERT INTO international VALUES (441,'WebGUI',7,'µç×ÓÓÊ¼þµ½´«ºôÍø¹Ø');
INSERT INTO international VALUES (442,'WebGUI',7,'¹¤×÷ÐÅÏ¢');
INSERT INTO international VALUES (443,'WebGUI',7,'¼ÒÍ¥ÐÅÏ¢');
INSERT INTO international VALUES (444,'WebGUI',7,'¸öÈËÒþË½');
INSERT INTO international VALUES (445,'WebGUI',7,'Ï²ºÃÉèÖÃ');
INSERT INTO international VALUES (446,'WebGUI',7,'µ¥Î»ÍøÕ¾');
INSERT INTO international VALUES (447,'WebGUI',7,'¹ÜÀíÒ³ÃæÊ÷');
INSERT INTO international VALUES (448,'WebGUI',7,'Ò³ÃæÊ÷');
INSERT INTO international VALUES (449,'WebGUI',7,'Ò»°ãÐÅÏ¢');
INSERT INTO international VALUES (450,'WebGUI',7,'µ¥Î»Ãû³Æ');
INSERT INTO international VALUES (451,'WebGUI',7,'±ØÐè');
INSERT INTO international VALUES (452,'WebGUI',7,'½øÈëÖÐ...');
INSERT INTO international VALUES (453,'WebGUI',7,'´´½¨ÈÕÆÚ');
INSERT INTO international VALUES (454,'WebGUI',7,'×îºó¸üÐÂ');
INSERT INTO international VALUES (455,'WebGUI',7,'±à¼­ÓÃ»§ÐÅÏ¢¡£');
INSERT INTO international VALUES (456,'WebGUI',7,'·µ»ØÓÃ»§ÁÐ±í¡£');
INSERT INTO international VALUES (457,'WebGUI',7,'±à¼­´ËÓÃ»§ÕÊ»§¡£');
INSERT INTO international VALUES (458,'WebGUI',7,'±à¼­´ËÓÃ»§×éÈº¡£');
INSERT INTO international VALUES (459,'WebGUI',7,'±à¼­´ËÓÃ»§ÊôÐÔ¡£');
INSERT INTO international VALUES (460,'WebGUI',7,'Ê±Çø');
INSERT INTO international VALUES (461,'WebGUI',7,'ÈÕÆÚ¸ñÊ½');
INSERT INTO international VALUES (462,'WebGUI',7,'Ê±¼ä¸ñÊ½');
INSERT INTO international VALUES (463,'WebGUI',7,'ÎÄ±¾ÊäÈëÇøÐÐÊý');
INSERT INTO international VALUES (464,'WebGUI',7,'ÎÄ±¾ÊäÈëÇøÁÐÊý');
INSERT INTO international VALUES (465,'WebGUI',7,'ÎÄ±¾¿ò´óÐ¡');
INSERT INTO international VALUES (466,'WebGUI',7,'ÄúÈ·¶¨ÒªÉ¾³ý´ËÀà±ð²¢ÇÒ½«´ËÀà±ðÏÂËùÓÐÀ¸Ä¿ÒÆ¶¯µ½Ò»°ãÀà±ðÂð£¿');
INSERT INTO international VALUES (467,'WebGUI',7,'ÄúÈ·¶¨ÒªÉ¾³ý´ËÀ¸Ä¿£¬²¢ÇÒËùÓÐ¹ØÓÚ´ËÀ¸Ä¿µÄÓÃ»§ÐÅÏ¢Âð£¿');
INSERT INTO international VALUES (469,'WebGUI',7,'ID');
INSERT INTO international VALUES (470,'WebGUI',7,'Ãû×Ö');
INSERT INTO international VALUES (472,'WebGUI',7,'±êÌâ');
INSERT INTO international VALUES (473,'WebGUI',7,'¿É¼û£¿');
INSERT INTO international VALUES (474,'WebGUI',7,'±ØÐë£¿');
INSERT INTO international VALUES (475,'WebGUI',7,'ÎÄ×Ö');
INSERT INTO international VALUES (476,'WebGUI',7,'ÎÄ×ÖÇø');
INSERT INTO international VALUES (477,'WebGUI',7,'HTML Çø');
INSERT INTO international VALUES (478,'WebGUI',7,'URL');
INSERT INTO international VALUES (479,'WebGUI',7,'ÈÕÆÚ');
INSERT INTO international VALUES (480,'WebGUI',7,'µç×ÓÓÊ¼þµØÖ·');
INSERT INTO international VALUES (481,'WebGUI',7,'µç»°ºÅÂë');
INSERT INTO international VALUES (482,'WebGUI',7,'Êý×Ö (ÕûÊý)');
INSERT INTO international VALUES (483,'WebGUI',7,'ÊÇ»ò·ñ');
INSERT INTO international VALUES (484,'WebGUI',7,'Ñ¡ÔñÁÐ±í');
INSERT INTO international VALUES (485,'WebGUI',7,'²¼¶ûÖµ (Ñ¡Ôñ¿ò)');
INSERT INTO international VALUES (486,'WebGUI',7,'Êý¾ÝÀàÐÍ');
INSERT INTO international VALUES (487,'WebGUI',7,'¿ÉÑ¡Öµ');
INSERT INTO international VALUES (488,'WebGUI',7,'Ä¬ÈÏÖµ');
INSERT INTO international VALUES (489,'WebGUI',7,'ÊôÐÔÀà');
INSERT INTO international VALUES (490,'WebGUI',7,'Ìí¼ÓÒ»¸öÊôÐÔÀà¡£');
INSERT INTO international VALUES (491,'WebGUI',7,'Ìí¼ÓÒ»¸öÊôÐÔÀ¸¡£');
INSERT INTO international VALUES (492,'WebGUI',7,'ÊôÐÔÀ¸ÁÐ±í¡£');
INSERT INTO international VALUES (493,'WebGUI',7,'·µ»ØÍøÕ¾¡£');
INSERT INTO international VALUES (495,'WebGUI',7,'ÄÚÖÃ±à¼­Æ÷');
INSERT INTO international VALUES (496,'WebGUI',7,'Ê¹ÓÃ');
INSERT INTO international VALUES (494,'WebGUI',7,'Real Objects Edit-On Pro');
INSERT INTO international VALUES (497,'WebGUI',7,'¿ªÊ¼ÈÕÆÚ');
INSERT INTO international VALUES (498,'WebGUI',7,'½áÊøÈÕÆÚ');
INSERT INTO international VALUES (499,'WebGUI',7,'×é¼þ ID');
INSERT INTO international VALUES (500,'WebGUI',7,'Ò³Ãæ ID');
INSERT INTO international VALUES (514,'WebGUI',7,'·ÃÎÊ');
INSERT INTO international VALUES (527,'WebGUI',7,'Ä¬ÈÏÊ×Ò³');
INSERT INTO international VALUES (503,'WebGUI',7,'Ä£°å ID');
INSERT INTO international VALUES (501,'WebGUI',7,'Ö÷Ìå');
INSERT INTO international VALUES (528,'WebGUI',7,'Ä£°åÃû³Æ');
INSERT INTO international VALUES (468,'WebGUI',7,'±à¼­ÓÃ»§ÊôÐÔÀà');
INSERT INTO international VALUES (159,'WebGUI',7,'ÊÕ¼þÏä');
INSERT INTO international VALUES (508,'WebGUI',7,'¹ÜÀíÄ£°å¡£');
INSERT INTO international VALUES (39,'UserSubmission',7,'·¢±í»Ø¸´');
INSERT INTO international VALUES (40,'UserSubmission',7,'×÷Õß');
INSERT INTO international VALUES (41,'UserSubmission',7,'ÈÕÆÚ');
INSERT INTO international VALUES (42,'UserSubmission',7,'±à¼­»ØÓ¦');
INSERT INTO international VALUES (43,'UserSubmission',7,'É¾³ý»ØÓ¦');
INSERT INTO international VALUES (45,'UserSubmission',7,'·µ»ØÍ¶¸åÏµÍ³');
INSERT INTO international VALUES (46,'UserSubmission',7,'¸ü¶à...');
INSERT INTO international VALUES (47,'UserSubmission',7,'»Ø¸´');
INSERT INTO international VALUES (48,'UserSubmission',7,'ÊÇ·ñÔÊÐíÌÖÂÛ£¿');
INSERT INTO international VALUES (49,'UserSubmission',7,'±à¼­³¬Ê±');
INSERT INTO international VALUES (50,'UserSubmission',7,'ÔÊÐí·¢±íµÄÓÃ»§×é');
INSERT INTO international VALUES (44,'UserSubmission',7,'ÔÊÐí¹ÜÀíµÄÓÃ»§×é');
INSERT INTO international VALUES (51,'UserSubmission',7,'ÏÔÊ¾¿ìÕÕ£¿');
INSERT INTO international VALUES (52,'UserSubmission',7,'¿ìÕÕ');
INSERT INTO international VALUES (53,'UserSubmission',7,'²¼¾Ö');
INSERT INTO international VALUES (54,'UserSubmission',7,'ÁôÑÔÄ£Ê½');
INSERT INTO international VALUES (55,'UserSubmission',7,'ÁÐ±íÄ£Ê½');
INSERT INTO international VALUES (56,'UserSubmission',7,'Ïà²á');
INSERT INTO international VALUES (57,'UserSubmission',7,'»ØÓ¦');
INSERT INTO international VALUES (11,'FAQ',7,'ÊÇ·ñ´ò¿ª TOC £¿');
INSERT INTO international VALUES (12,'FAQ',7,'ÊÇ·ñ´ò¿ª Q/A £¿');
INSERT INTO international VALUES (13,'FAQ',7,'ÊÇ·ñ´ò¿ª [top] Á¬½Ó£¿');
INSERT INTO international VALUES (14,'FAQ',7,'Q');
INSERT INTO international VALUES (15,'FAQ',7,'A');
INSERT INTO international VALUES (16,'FAQ',7,'[·µ»Ø¶¥¶Ë]');
INSERT INTO international VALUES (509,'WebGUI',7,'ÌÖÂÛ²¼¾Ö');
INSERT INTO international VALUES (510,'WebGUI',7,'Æ½ÆÌ');
INSERT INTO international VALUES (511,'WebGUI',7,'ÏßË÷');
INSERT INTO international VALUES (512,'WebGUI',7,'ÏÂÒ»ÌõÏßË÷');
INSERT INTO international VALUES (513,'WebGUI',7,'ÉÏÒ»ÌõÏßË÷');
INSERT INTO international VALUES (534,'WebGUI',7,'ÐÂÓÃ»§ÌáÊ¾£¿');
INSERT INTO international VALUES (354,'WebGUI',7,'²é¿´ÊÕ¼þÏä¡£');
INSERT INTO international VALUES (531,'WebGUI',7,'°üÀ¨<b>ÍêÕûµÄÆ´Ð´</b>');
INSERT INTO international VALUES (518,'WebGUI',7,'ÊÕ¼þÏäÌáÊ¾');
INSERT INTO international VALUES (519,'WebGUI',7,'ÎÒÏ£Íû±»ÌáÐÑ¡£');
INSERT INTO international VALUES (520,'WebGUI',7,'ÎÒÏ£ÍûÍ¨¹ýµç×ÓÓÊ¼þµÄ·½Ê½ÌáÐÑ¡£');
INSERT INTO international VALUES (521,'WebGUI',7,'ÎÒÏ£ÍûÍ¨¹ýµç×ÓÓÊ¼þµ½´«ºôµÄ·½Ê½ÌáÐÑ¡£');
INSERT INTO international VALUES (522,'WebGUI',7,'ÎÒÏ£ÍûÍ¨¹ý ICQ µÄ·½Ê½ÌáÐÑ¡£');
INSERT INTO international VALUES (523,'WebGUI',7,'ÌáÐÑ');
INSERT INTO international VALUES (524,'WebGUI',7,'ÊÇ·ñÌí¼Ó±à¼­´Á£¿');
INSERT INTO international VALUES (525,'WebGUI',7,'±à¼­ÄÚÈÝÉèÖÃ');
INSERT INTO international VALUES (526,'WebGUI',7,'Ö»Çå³ý JavaScript ¡£');
INSERT INTO international VALUES (584,'WebGUI',1,'Add a new language.');
INSERT INTO international VALUES (585,'WebGUI',1,'Manage translations.');
INSERT INTO international VALUES (586,'WebGUI',1,'Languages');
INSERT INTO international VALUES (588,'WebGUI',1,'Are you certain you wish to submit this translation to Plain Black for inclusion in the default distribution? By clicking on the yes link you understand that you\'re giving Plain Black an unlimited license to use the translation in its software distributions.');
INSERT INTO international VALUES (587,'WebGUI',1,'Are you certain you wish to delete this language and all the help and international messages that go with it?');
INSERT INTO international VALUES (589,'WebGUI',1,'Edit Language');
INSERT INTO international VALUES (590,'WebGUI',1,'Language ID');
INSERT INTO international VALUES (591,'WebGUI',1,'Language');
INSERT INTO international VALUES (592,'WebGUI',1,'Character Set');
INSERT INTO international VALUES (593,'WebGUI',1,'Submit translation to Plain Black.');
INSERT INTO international VALUES (594,'WebGUI',1,'Translate international messages.');
INSERT INTO international VALUES (595,'WebGUI',1,'International Messages');
INSERT INTO international VALUES (596,'WebGUI',1,'MISSING');
INSERT INTO international VALUES (597,'WebGUI',1,'Edit International Message');
INSERT INTO international VALUES (598,'WebGUI',1,'Edit language.');
INSERT INTO international VALUES (601,'WebGUI',1,'International ID');
INSERT INTO international VALUES (1,'MailForm',1,'Mail Form');
INSERT INTO international VALUES (2,'MailForm',1,'Your email subject here');
INSERT INTO international VALUES (3,'MailForm',1,'Thank you for your feedback!');
INSERT INTO international VALUES (4,'MailForm',1,'Hidden');
INSERT INTO international VALUES (5,'MailForm',1,'Displayed');
INSERT INTO international VALUES (6,'MailForm',1,'Modifiable');
INSERT INTO international VALUES (7,'MailForm',1,'Edit Mail Form');
INSERT INTO international VALUES (8,'MailForm',1,'Width');
INSERT INTO international VALUES (9,'MailForm',1,'Add Field');
INSERT INTO international VALUES (10,'MailForm',1,'From');
INSERT INTO international VALUES (11,'MailForm',1,'To (email, username, or group name)');
INSERT INTO international VALUES (12,'MailForm',1,'Cc');
INSERT INTO international VALUES (13,'MailForm',1,'Bcc');
INSERT INTO international VALUES (14,'MailForm',1,'Subject');
INSERT INTO international VALUES (15,'MailForm',1,'Proceed to add more fields?');
INSERT INTO international VALUES (16,'MailForm',1,'Acknowledgement');
INSERT INTO international VALUES (17,'MailForm',1,'Mail Sent');
INSERT INTO international VALUES (18,'MailForm',1,'Go back!');
INSERT INTO international VALUES (19,'MailForm',1,'Are you certain that you want to delete this field?');
INSERT INTO international VALUES (20,'MailForm',1,'Edit Field');
INSERT INTO international VALUES (21,'MailForm',1,'Field Name');
INSERT INTO international VALUES (22,'MailForm',1,'Status');
INSERT INTO international VALUES (23,'MailForm',1,'Type');
INSERT INTO international VALUES (24,'MailForm',1,'Possible Values (Drop-Down Box only)');
INSERT INTO international VALUES (25,'MailForm',1,'Default Value (optional)');
INSERT INTO international VALUES (26,'MailForm',1,'Store Entries?');
INSERT INTO international VALUES (491,'WebGUI',8,'Aggiungi un campo al profilo.');
INSERT INTO international VALUES (490,'WebGUI',8,'Aggiungi una categoria al profilo.');
INSERT INTO international VALUES (489,'WebGUI',8,'Categoria Profilo');
INSERT INTO international VALUES (488,'WebGUI',8,'Valore(i) di Default');
INSERT INTO international VALUES (487,'WebGUI',8,'Valori Possibili');
INSERT INTO international VALUES (486,'WebGUI',8,'Tipo Data');
INSERT INTO international VALUES (484,'WebGUI',8,'Seleziona Lista');
INSERT INTO international VALUES (485,'WebGUI',8,'Booleano (Checkbox)');
INSERT INTO international VALUES (483,'WebGUI',8,'Si o No');
INSERT INTO international VALUES (482,'WebGUI',8,'Numero (Intero)');
INSERT INTO international VALUES (481,'WebGUI',8,'Telefono');
INSERT INTO international VALUES (479,'WebGUI',8,'Data');
INSERT INTO international VALUES (480,'WebGUI',8,'Indirizzo Email');
INSERT INTO international VALUES (476,'WebGUI',8,'Text Area');
INSERT INTO international VALUES (477,'WebGUI',8,'HTML Area');
INSERT INTO international VALUES (478,'WebGUI',8,'URL');
INSERT INTO international VALUES (475,'WebGUI',8,'Text');
INSERT INTO international VALUES (473,'WebGUI',8,'Visibile?');
INSERT INTO international VALUES (474,'WebGUI',8,'Campo Richisto?');
INSERT INTO international VALUES (470,'WebGUI',8,'Nome');
INSERT INTO international VALUES (472,'WebGUI',8,'Etichetta');
INSERT INTO international VALUES (469,'WebGUI',8,'Id');
INSERT INTO international VALUES (468,'WebGUI',8,'Modifica categoria profilo utenti');
INSERT INTO international VALUES (467,'WebGUI',8,'Sei certo di voler cancellare questo campo e tutti i dati ad esso relativi?');
INSERT INTO international VALUES (466,'WebGUI',8,'Sei certo di voler cancellare questa categoria e spostare il suo contenuto nella categoria Varie?');
INSERT INTO international VALUES (465,'WebGUI',8,'Dimensione Text Box');
INSERT INTO international VALUES (464,'WebGUI',8,'Colonne Text Area');
INSERT INTO international VALUES (463,'WebGUI',8,'Righe Text Area');
INSERT INTO international VALUES (462,'WebGUI',8,'Formato ora');
INSERT INTO international VALUES (461,'WebGUI',8,'Formato data');
INSERT INTO international VALUES (460,'WebGUI',8,'Time Offset');
INSERT INTO international VALUES (459,'WebGUI',8,'Modifica il profilo di questo utente.');
INSERT INTO international VALUES (458,'WebGUI',8,'Modifica il gruppo di questo utente.');
INSERT INTO international VALUES (457,'WebGUI',8,'Modifica l\'account di questo utente.');
INSERT INTO international VALUES (456,'WebGUI',8,'Indietro alla lista degli utenti.');
INSERT INTO international VALUES (455,'WebGUI',8,'Modifica il profilo utente');
INSERT INTO international VALUES (454,'WebGUI',8,'Ultimo aggiornamento');
INSERT INTO international VALUES (452,'WebGUI',8,'Attendi...');
INSERT INTO international VALUES (453,'WebGUI',8,'Data di creazione');
INSERT INTO international VALUES (450,'WebGUI',8,'Professione (Azienda)');
INSERT INTO international VALUES (451,'WebGUI',8,'é richiesto.');
INSERT INTO international VALUES (448,'WebGUI',8,'Albero di Navigazione');
INSERT INTO international VALUES (449,'WebGUI',8,'Informazioni varie');
INSERT INTO international VALUES (447,'WebGUI',8,'Gestisci albero di navigazione.');
INSERT INTO international VALUES (446,'WebGUI',8,'Web Site');
INSERT INTO international VALUES (445,'WebGUI',8,'Preferenze');
INSERT INTO international VALUES (444,'WebGUI',8,'Informazioni Geografiche');
INSERT INTO international VALUES (443,'WebGUI',8,'Informazioni Tempo Libero');
INSERT INTO international VALUES (441,'WebGUI',8,'Email al Pager ');
INSERT INTO international VALUES (442,'WebGUI',8,'Informazioni Professionali');
INSERT INTO international VALUES (440,'WebGUI',8,'Contatti');
INSERT INTO international VALUES (439,'WebGUI',8,'Informazioni Personali');
INSERT INTO international VALUES (438,'WebGUI',8,'Il tuo nome');
INSERT INTO international VALUES (436,'WebGUI',8,'Uccidi Sessione');
INSERT INTO international VALUES (437,'WebGUI',8,'Statistiche');
INSERT INTO international VALUES (435,'WebGUI',8,'Firma di Sessione');
INSERT INTO international VALUES (434,'WebGUI',8,'Stato');
INSERT INTO international VALUES (433,'WebGUI',8,'User Agent');
INSERT INTO international VALUES (432,'WebGUI',8,'Scade');
INSERT INTO international VALUES (431,'WebGUI',8,'Indirizzo IP');
INSERT INTO international VALUES (430,'WebGUI',8,'Ultima pagina vista');
INSERT INTO international VALUES (429,'WebGUI',8,'Ultimo Login');
INSERT INTO international VALUES (427,'WebGUI',8,'Stili');
INSERT INTO international VALUES (428,'WebGUI',8,'Utente (ID)');
INSERT INTO international VALUES (426,'WebGUI',8,'Storico Login');
INSERT INTO international VALUES (425,'WebGUI',8,'Sessioni Attive');
INSERT INTO international VALUES (424,'WebGUI',8,'Visualizza Storico Login.');
INSERT INTO international VALUES (423,'WebGUI',8,'Visualizza Sessioni Attive.');
INSERT INTO international VALUES (422,'WebGUI',8,'<h1>Login Fallito!</h1>\r\nLe informazioni che hai provvisto non corrispondono all\'account.');
INSERT INTO international VALUES (421,'WebGUI',8,'Rimuovi tutto tranne che la formattazione basilare.');
INSERT INTO international VALUES (420,'WebGUI',8,'Lascia com\'è.');
INSERT INTO international VALUES (419,'WebGUI',8,'Rimuovi tutti i tag.');
INSERT INTO international VALUES (418,'WebGUI',8,'Filtra l\'HTML nei contributi degli utenti');
INSERT INTO international VALUES (417,'WebGUI',8,'<h1>Violazione della Sicurezza</h1>\r\nHai cercato di accedere ad un widget non associato a questa pagina. Questo incidente è stato registrato.');
INSERT INTO international VALUES (52,'Product',1,'Add another benefit?');
INSERT INTO international VALUES (416,'WebGUI',8,'<h1>Problemi con la richiesta</h1>\r\nci sono stati dei problemi con la tua richiesta. Prego clicca sul bottone \"indietro\" del browser e riprova. Se questo problema persiste, contattaci specificando quello che stai tentando di fare e la data dell\'errore.');
INSERT INTO international VALUES (28,'Article',8,'Visualizza Risposte');
INSERT INTO international VALUES (27,'Article',8,'Torna all\'articolo');
INSERT INTO international VALUES (710,'WebGUI',1,'Edit Privilege Settings');
INSERT INTO international VALUES (26,'Article',8,'Cancella Risposta');
INSERT INTO international VALUES (25,'Article',8,'Modifica Risposta');
INSERT INTO international VALUES (24,'Article',8,'Invia Risposta');
INSERT INTO international VALUES (21,'Article',8,'Modifica Timeout');
INSERT INTO international VALUES (22,'Article',8,'Autore');
INSERT INTO international VALUES (23,'Article',8,'Data');
INSERT INTO international VALUES (20,'Article',8,'Chi può moderare?');
INSERT INTO international VALUES (19,'Article',8,'Chi può postare?');
INSERT INTO international VALUES (18,'Article',8,'Consenti discussione?');
INSERT INTO international VALUES (9,'SiteMap',8,'Visualizza Descrizione?');
INSERT INTO international VALUES (411,'WebGUI',8,'Titolo nel Menu');
INSERT INTO international VALUES (412,'WebGUI',8,'Descrizione');
INSERT INTO international VALUES (410,'WebGUI',8,'Gestisci roots.');
INSERT INTO international VALUES (409,'WebGUI',8,'Aggiungi una nuova root.');
INSERT INTO international VALUES (408,'WebGUI',8,'Gestisci Roots');
INSERT INTO international VALUES (18,'SQLReport',8,'Non ci sono risultati per questa query.');
INSERT INTO international VALUES (16,'SQLReport',8,'Debug?');
INSERT INTO international VALUES (17,'SQLReport',8,'<b>Debug:</b> Query:');
INSERT INTO international VALUES (15,'SQLReport',8,'Preprocessa le macro nella query?');
INSERT INTO international VALUES (46,'WebGUI',8,'Il mio account');
INSERT INTO international VALUES (407,'WebGUI',8,'Clicca qui per registrarti.');
INSERT INTO international VALUES (21,'DownloadManager',8,'Visualizza i  thumbnails?');
INSERT INTO international VALUES (406,'WebGUI',8,'Grandezza del Thumbnail');
INSERT INTO international VALUES (405,'WebGUI',8,'Ultima Pagina');
INSERT INTO international VALUES (403,'WebGUI',8,'Preferisco non dirlo.');
INSERT INTO international VALUES (402,'WebGUI',8,'Il messaggio che hai richiesto non esiste.');
INSERT INTO international VALUES (22,'MessageBoard',8,'Cancella Messaggio');
INSERT INTO international VALUES (21,'MessageBoard',8,'Chi può moderare?');
INSERT INTO international VALUES (60,'WebGUI',8,'Sei sicuro di voler disattivare il tuo account? Se continui le informazioni del tuo account saranno perse permanentemente.');
INSERT INTO international VALUES (401,'WebGUI',8,'Sei sicuro di voler cancellare questo messaggio e tutti i messaggi sotto di esso in questo thread?');
INSERT INTO international VALUES (400,'WebGUI',8,'Impedisci la Cache del Proxy');
INSERT INTO international VALUES (399,'WebGUI',8,'Valida questa pagina.');
INSERT INTO international VALUES (398,'WebGUI',8,'Document Type Declaration');
INSERT INTO international VALUES (394,'WebGUI',8,'Gestisci Immagini.');
INSERT INTO international VALUES (395,'WebGUI',8,'Aggiungi una nuova Immagine.');
INSERT INTO international VALUES (396,'WebGUI',8,'Visualizza Immagine');
INSERT INTO international VALUES (397,'WebGUI',8,'Indietro alla lista delle Immagini.');
INSERT INTO international VALUES (393,'WebGUI',8,'Gestisci Immagini');
INSERT INTO international VALUES (391,'WebGUI',8,'Cancella il file Allegato.');
INSERT INTO international VALUES (392,'WebGUI',8,'Sei sicuro di voler cancellare questa Immagine?');
INSERT INTO international VALUES (390,'WebGUI',8,'Visualizza Immagine...');
INSERT INTO international VALUES (389,'WebGUI',8,'Id Immagine');
INSERT INTO international VALUES (387,'WebGUI',8,'Uploadato Da');
INSERT INTO international VALUES (388,'WebGUI',8,'Data di Upload');
INSERT INTO international VALUES (386,'WebGUI',8,'Modifica Immagine');
INSERT INTO international VALUES (385,'WebGUI',8,'Parametri');
INSERT INTO international VALUES (384,'WebGUI',8,'File');
INSERT INTO international VALUES (19,'EventsCalendar',8,'Cambio Pagina dopo');
INSERT INTO international VALUES (383,'WebGUI',8,'Nome');
INSERT INTO international VALUES (18,'EventsCalendar',8,'Calendar Month');
INSERT INTO international VALUES (16,'EventsCalendar',8,'Layout del Calendario');
INSERT INTO international VALUES (17,'EventsCalendar',8,'Lista');
INSERT INTO international VALUES (20,'DownloadManager',8,'Cambio Pagina dopo');
INSERT INTO international VALUES (14,'SQLReport',8,'Cambio Pagina dopo');
INSERT INTO international VALUES (14,'EventsCalendar',8,'Data di Inizio');
INSERT INTO international VALUES (15,'EventsCalendar',8,'Data di Fine');
INSERT INTO international VALUES (19,'DownloadManager',8,'Non hai files disponibili per il download.');
INSERT INTO international VALUES (18,'DownloadManager',8,'Versione Alternativa #2');
INSERT INTO international VALUES (17,'DownloadManager',8,'Versione Alternativa #1');
INSERT INTO international VALUES (13,'SQLReport',8,'Converti gli a capo?');
INSERT INTO international VALUES (37,'UserSubmission',8,'Cancella');
INSERT INTO international VALUES (17,'Article',8,'Centro');
INSERT INTO international VALUES (15,'Article',8,'Destra');
INSERT INTO international VALUES (16,'Article',8,'Sinistra');
INSERT INTO international VALUES (16,'DownloadManager',8,'Uploadato in Data');
INSERT INTO international VALUES (15,'DownloadManager',8,'Descrizione');
INSERT INTO international VALUES (14,'DownloadManager',8,'File');
INSERT INTO international VALUES (9,'DownloadManager',8,'Modifica Download Manager');
INSERT INTO international VALUES (10,'DownloadManager',8,'Modifica Download');
INSERT INTO international VALUES (11,'DownloadManager',8,'Aggiungi un nuovo download');
INSERT INTO international VALUES (12,'DownloadManager',8,'Sei sicuro di voler cancellare questo download?');
INSERT INTO international VALUES (8,'DownloadManager',8,'Breve Descrizione');
INSERT INTO international VALUES (7,'DownloadManager',8,'Group to Download');
INSERT INTO international VALUES (6,'DownloadManager',8,'Download File');
INSERT INTO international VALUES (3,'DownloadManager',8,'Continua aggiungendo un  file?');
INSERT INTO international VALUES (5,'DownloadManager',8,'Titolo del File');
INSERT INTO international VALUES (1,'DownloadManager',8,'Download Manager');
INSERT INTO international VALUES (380,'WebGUI',8,'ID Stile');
INSERT INTO international VALUES (381,'WebGUI',8,'Il sistema ha ricevuto un richiesta non valida. Utilizza il tasto bagk del browser e prova ancora');
INSERT INTO international VALUES (35,'UserSubmission',8,'Titolo');
INSERT INTO international VALUES (378,'WebGUI',8,'ID utente');
INSERT INTO international VALUES (379,'WebGUI',8,'ID Gruppo');
INSERT INTO international VALUES (34,'UserSubmission',8,'Converti gli a capo');
INSERT INTO international VALUES (33,'UserSubmission',8,'Allegato');
INSERT INTO international VALUES (32,'UserSubmission',8,'Immagine');
INSERT INTO international VALUES (31,'UserSubmission',8,'Contenuto');
INSERT INTO international VALUES (377,'WebGUI',8,'Nessun packages è stato definito dal tuo package manager o amministratore.');
INSERT INTO international VALUES (11,'Poll',8,'Vota!');
INSERT INTO international VALUES (374,'WebGUI',8,'Visualizza packages.');
INSERT INTO international VALUES (375,'WebGUI',8,'Seleziona Package da svolgere');
INSERT INTO international VALUES (376,'WebGUI',8,'Package');
INSERT INTO international VALUES (373,'WebGUI',8,'<b>Attenzione:</b> modificando la lista dei gruppi sottostante, si resetta ogni informazione sulla scadenza di ogni gruppo ai nuovi defaults.');
INSERT INTO international VALUES (371,'WebGUI',8,'Aggiungi Grouping');
INSERT INTO international VALUES (372,'WebGUI',8,'Modifica i gruppi dell\'utente');
INSERT INTO international VALUES (370,'WebGUI',8,'Modifica Grouping');
INSERT INTO international VALUES (369,'WebGUI',8,'Data di scadenza');
INSERT INTO international VALUES (368,'WebGUI',8,'Aggiungi un nuovo gruppo a questo utente.');
INSERT INTO international VALUES (365,'WebGUI',8,'Risultati della ricerca...');
INSERT INTO international VALUES (366,'WebGUI',8,'Non sono state trovate pagine che soddisfano la tua richiesta.');
INSERT INTO international VALUES (364,'WebGUI',8,'Cerca');
INSERT INTO international VALUES (362,'WebGUI',8,'Fianco a fianco');
INSERT INTO international VALUES (363,'WebGUI',8,'Posizione nel Template');
INSERT INTO international VALUES (361,'WebGUI',8,'Tre su Una');
INSERT INTO international VALUES (359,'WebGUI',8,'Colonna Destra');
INSERT INTO international VALUES (360,'WebGUI',8,'Una su Tre');
INSERT INTO international VALUES (358,'WebGUI',8,'Colonna Sinistra');
INSERT INTO international VALUES (357,'WebGUI',8,'News');
INSERT INTO international VALUES (356,'WebGUI',8,'Template');
INSERT INTO international VALUES (355,'WebGUI',8,'Default');
INSERT INTO international VALUES (471,'WebGUI',8,'Modifica campi profilo utenti');
INSERT INTO international VALUES (352,'WebGUI',8,'Data dell\'Elemento');
INSERT INTO international VALUES (159,'WebGUI',8,'Inbox');
INSERT INTO international VALUES (349,'WebGUI',8,'Ultima Versione Disponibile');
INSERT INTO international VALUES (351,'WebGUI',8,'Messaggio');
INSERT INTO international VALUES (350,'WebGUI',8,'Completato');
INSERT INTO international VALUES (348,'WebGUI',8,'Nome');
INSERT INTO international VALUES (347,'WebGUI',8,'Visualizza il Profilo per');
INSERT INTO international VALUES (343,'WebGUI',8,'Visualizza Profilo.');
INSERT INTO international VALUES (345,'WebGUI',8,'Non membro');
INSERT INTO international VALUES (346,'WebGUI',8,'Questo utente non è più membro del nostro sito. Non abbiamo altre informazioni su questo utente.');
INSERT INTO international VALUES (341,'WebGUI',8,'Modifica Profilo.');
INSERT INTO international VALUES (342,'WebGUI',8,'Modifica le informazioni dell\'account.');
INSERT INTO international VALUES (337,'WebGUI',8,'Homepage URL');
INSERT INTO international VALUES (338,'WebGUI',8,'Modifica  Profilo');
INSERT INTO international VALUES (339,'WebGUI',8,'Maschio');
INSERT INTO international VALUES (340,'WebGUI',8,'Femmina');
INSERT INTO international VALUES (336,'WebGUI',8,'Data di nascita');
INSERT INTO international VALUES (335,'WebGUI',8,'Genere');
INSERT INTO international VALUES (331,'WebGUI',8,'Stato lavoro');
INSERT INTO international VALUES (332,'WebGUI',8,'CAP lavoro');
INSERT INTO international VALUES (333,'WebGUI',8,'Provincia lavoro');
INSERT INTO international VALUES (334,'WebGUI',8,'Telefono lavoro');
INSERT INTO international VALUES (330,'WebGUI',8,'Città lavoro');
INSERT INTO international VALUES (329,'WebGUI',8,'Indirizzo lavoro');
INSERT INTO international VALUES (328,'WebGUI',8,'Telefono casa');
INSERT INTO international VALUES (327,'WebGUI',8,'Provincia casa');
INSERT INTO international VALUES (326,'WebGUI',8,'CAP casa');
INSERT INTO international VALUES (324,'WebGUI',8,'Città casa');
INSERT INTO international VALUES (325,'WebGUI',8,'Stato casa');
INSERT INTO international VALUES (323,'WebGUI',8,'Indirizzo casa');
INSERT INTO international VALUES (322,'WebGUI',8,'Pager');
INSERT INTO international VALUES (321,'WebGUI',8,'Telefono Cellulare');
INSERT INTO international VALUES (320,'WebGUI',8,'<a href=\"http://messenger.yahoo.com/\">Yahoo! Messenger</a> Id');
INSERT INTO international VALUES (319,'WebGUI',8,'<a href=\"http://messenger.msn.com/\">MSN Messenger</a> Id');
INSERT INTO international VALUES (318,'WebGUI',8,'<a href=\"http://www.aol.com/aim/homenew.adp\">AIM</a> Id');
INSERT INTO international VALUES (317,'WebGUI',8,'<a href=\"http://www.icq.com\">ICQ</a> UIN');
INSERT INTO international VALUES (316,'WebGUI',8,'Cognome');
INSERT INTO international VALUES (315,'WebGUI',8,'Altro Nome');
INSERT INTO international VALUES (314,'WebGUI',8,'Nome');
INSERT INTO international VALUES (313,'WebGUI',8,'Consenti informazioni varie?');
INSERT INTO international VALUES (312,'WebGUI',8,'Consenti informazioni business?');
INSERT INTO international VALUES (311,'WebGUI',8,'Consenti informazioni home?');
INSERT INTO international VALUES (310,'WebGUI',8,'Consenti informazioni extra sugli account?');
INSERT INTO international VALUES (309,'WebGUI',8,'Consenti il nome reale?');
INSERT INTO international VALUES (307,'WebGUI',8,'Usa i meta tags di default?');
INSERT INTO international VALUES (308,'WebGUI',8,'Modifica i settaggi del profilo');
INSERT INTO international VALUES (306,'WebGUI',8,'Binding del Nome Utente');
INSERT INTO international VALUES (245,'WebGUI',8,'Data');
INSERT INTO international VALUES (304,'WebGUI',8,'Lingua');
INSERT INTO international VALUES (244,'WebGUI',8,'Autore');
INSERT INTO international VALUES (239,'WebGUI',8,'Data:');
INSERT INTO international VALUES (240,'WebGUI',8,'ID Messaggio:');
INSERT INTO international VALUES (238,'WebGUI',8,'Autore:');
INSERT INTO international VALUES (237,'WebGUI',8,'Oggetto:');
INSERT INTO international VALUES (234,'WebGUI',8,'Inviare una Risposta...');
INSERT INTO international VALUES (233,'WebGUI',8,'(eom)');
INSERT INTO international VALUES (232,'WebGUI',8,'Senza Oggetto');
INSERT INTO international VALUES (231,'WebGUI',8,'Inviare un nuovo Messaggio...');
INSERT INTO international VALUES (230,'WebGUI',8,'Messaggio');
INSERT INTO international VALUES (229,'WebGUI',8,'Oggetto');
INSERT INTO international VALUES (228,'WebGUI',8,'Modifica Messaggio...');
INSERT INTO international VALUES (175,'WebGUI',8,'Processa le macro?');
INSERT INTO international VALUES (174,'WebGUI',8,'Visualizza il Titolo?');
INSERT INTO international VALUES (170,'WebGUI',8,'cerca');
INSERT INTO international VALUES (171,'WebGUI',8,'Assistente per la creazione del testo');
INSERT INTO international VALUES (169,'WebGUI',8,'Aggiungi un nuovo Utente.');
INSERT INTO international VALUES (168,'WebGUI',8,'Modifica Utente');
INSERT INTO international VALUES (167,'WebGUI',8,'Sei sicuro di voler cancellare questo utente? Sappi che tutte le informazioni associate all\'utente saranno cancellate se procedi.');
INSERT INTO international VALUES (165,'WebGUI',8,'LDAP URL');
INSERT INTO international VALUES (166,'WebGUI',8,'Connect DN');
INSERT INTO international VALUES (163,'WebGUI',8,'Aggiungi Utente');
INSERT INTO international VALUES (164,'WebGUI',8,'Metodo di autenticazione');
INSERT INTO international VALUES (162,'WebGUI',8,'Sei sicuro di voler cancellare tutte le pagine e i widgets nel cestino?');
INSERT INTO international VALUES (161,'WebGUI',8,'Inviato Da');
INSERT INTO international VALUES (160,'WebGUI',8,'Inviato in Data');
INSERT INTO international VALUES (158,'WebGUI',8,'Aggiungi un nuovo stile.');
INSERT INTO international VALUES (353,'WebGUI',8,'Non hai messaggi in Inbox attualmente.');
INSERT INTO international VALUES (157,'WebGUI',8,'Stili');
INSERT INTO international VALUES (156,'WebGUI',8,'Modifica Stile');
INSERT INTO international VALUES (155,'WebGUI',8,'Sei sicuro di voler cancellare questo stile ed assegnare a tutte le pagine che lo usano lo stile \"Fail Safe\" ?');
INSERT INTO international VALUES (151,'WebGUI',8,'Nome dello stile');
INSERT INTO international VALUES (154,'WebGUI',8,'Style Sheet');
INSERT INTO international VALUES (149,'WebGUI',8,'Utenti');
INSERT INTO international VALUES (148,'WebGUI',8,'Widgets Visualizzabili');
INSERT INTO international VALUES (147,'WebGUI',8,'Pagine Visualizzabili');
INSERT INTO international VALUES (144,'WebGUI',8,'Visualizza statistiche.');
INSERT INTO international VALUES (145,'WebGUI',8,'Versione');
INSERT INTO international VALUES (146,'WebGUI',8,'Sessioni Attive');
INSERT INTO international VALUES (143,'WebGUI',8,'Gestisci i settaggi');
INSERT INTO international VALUES (142,'WebGUI',8,'Timeout della Sessione');
INSERT INTO international VALUES (141,'WebGUI',8,'Pagina non trovata');
INSERT INTO international VALUES (140,'WebGUI',8,'Modifica settaggi vari');
INSERT INTO international VALUES (134,'WebGUI',8,'Messaggio di Recupero Password');
INSERT INTO international VALUES (135,'WebGUI',8,'SMTP Server');
INSERT INTO international VALUES (138,'WebGUI',8,'Sì');
INSERT INTO international VALUES (139,'WebGUI',8,'No');
INSERT INTO international VALUES (133,'WebGUI',8,'Modifica i settaggi della Mail');
INSERT INTO international VALUES (130,'WebGUI',8,'Massima Dimensione Allegato');
INSERT INTO international VALUES (127,'WebGUI',8,'URL dell\'Azienda');
INSERT INTO international VALUES (126,'WebGUI',8,'Indirizzo Email dell\'Azienda');
INSERT INTO international VALUES (125,'WebGUI',8,'Nome dell\'Azienda');
INSERT INTO international VALUES (124,'WebGUI',8,'Modifica informazioni sull\'Azienda');
INSERT INTO international VALUES (123,'WebGUI',8,'LDAP Password Name');
INSERT INTO international VALUES (122,'WebGUI',8,'LDAP Identity Name');
INSERT INTO international VALUES (121,'WebGUI',8,'LDAP Identity (default)');
INSERT INTO international VALUES (120,'WebGUI',8,'LDAP URL (default)');
INSERT INTO international VALUES (118,'WebGUI',8,'Registrazione Anonima');
INSERT INTO international VALUES (119,'WebGUI',8,'Authentication Method (default)');
INSERT INTO international VALUES (117,'WebGUI',8,'Modifica settaggi Utente');
INSERT INTO international VALUES (116,'WebGUI',8,'Seleziona \"Si\" per dare a tutte le sottopagine gli stessi privilegi di questa.');
INSERT INTO international VALUES (115,'WebGUI',8,'Chiunque può modificare?');
INSERT INTO international VALUES (113,'WebGUI',8,'Il gruppo può modificare?');
INSERT INTO international VALUES (114,'WebGUI',8,'Chiunque può visualizzare?');
INSERT INTO international VALUES (112,'WebGUI',8,'Il gruppo può visualizzare?');
INSERT INTO international VALUES (111,'WebGUI',8,'Gruppo');
INSERT INTO international VALUES (110,'WebGUI',8,'Il proprietario può modificare?');
INSERT INTO international VALUES (109,'WebGUI',8,'Il proprietario può visualizzare?');
INSERT INTO international VALUES (108,'WebGUI',8,'Proprietario');
INSERT INTO international VALUES (107,'WebGUI',8,'Privilegi');
INSERT INTO international VALUES (106,'WebGUI',8,'Seleziona \"Si\" per dare a tutte le sottopagine lo stesso stile di questa.');
INSERT INTO international VALUES (105,'WebGUI',8,'Stile');
INSERT INTO international VALUES (104,'WebGUI',8,'URL della Pagina');
INSERT INTO international VALUES (102,'WebGUI',8,'Modifica Pagina');
INSERT INTO international VALUES (103,'WebGUI',8,'Specifiche della Pagina');
INSERT INTO international VALUES (101,'WebGUI',8,'Sei sicuro di voler cancellare questa pagina, il suo contenuto, e tutti gli elementi sotto di essa?');
INSERT INTO international VALUES (100,'WebGUI',8,'Meta Tags');
INSERT INTO international VALUES (99,'WebGUI',8,'Titolo');
INSERT INTO international VALUES (642,'WebGUI',1,'Page, Add/Edit');
INSERT INTO international VALUES (95,'WebGUI',8,'Indice Aiuto');
INSERT INTO international VALUES (94,'WebGUI',8,'Vedi anche');
INSERT INTO international VALUES (93,'WebGUI',8,'Aiuto');
INSERT INTO international VALUES (92,'WebGUI',8,'Pagina Successiva');
INSERT INTO international VALUES (91,'WebGUI',8,'Pagina Precedente');
INSERT INTO international VALUES (89,'WebGUI',8,'Gruppi');
INSERT INTO international VALUES (90,'WebGUI',8,'Aggiungi nuovo gruppo.');
INSERT INTO international VALUES (88,'WebGUI',8,'Utenti nel Gruppo');
INSERT INTO international VALUES (87,'WebGUI',8,'Modifica Gruppo');
INSERT INTO international VALUES (86,'WebGUI',8,'Sei sicuro di voler cancellare questo gruppo? Sappi che cancellare un gruppo è permanente e rimuoverà tutti i privilrgi associati a questo gruppo.');
INSERT INTO international VALUES (84,'WebGUI',8,'Nome del Gruppo');
INSERT INTO international VALUES (85,'WebGUI',8,'Corpo del testo');
INSERT INTO international VALUES (82,'WebGUI',8,'Funzioni Amministrative...');
INSERT INTO international VALUES (81,'WebGUI',8,'Account aggiornato con successo!');
INSERT INTO international VALUES (80,'WebGUI',8,'Account creato con successo!');
INSERT INTO international VALUES (79,'WebGUI',8,'Cannot connect to LDAP server.');
INSERT INTO international VALUES (78,'WebGUI',8,'Le tue password non corrispondono. Prego prova di nuovo.');
INSERT INTO international VALUES (77,'WebGUI',8,'Questo nome di account è già in uso da un altro membro di questo sito. Prego scegli un nuovo nome utente. Ecco alcuni suggerimenti:');
INSERT INTO international VALUES (76,'WebGUI',8,'Questo indirizzo di email non è nei nostri database.');
INSERT INTO international VALUES (75,'WebGUI',8,'Le Informazioni sul tuo account sono state inviate al tuo indirizzo di email.');
INSERT INTO international VALUES (74,'WebGUI',8,'Informazioni Account');
INSERT INTO international VALUES (73,'WebGUI',8,'Entra.');
INSERT INTO international VALUES (72,'WebGUI',8,'recupera');
INSERT INTO international VALUES (70,'WebGUI',8,'Errore');
INSERT INTO international VALUES (71,'WebGUI',8,'Recupera password');
INSERT INTO international VALUES (69,'WebGUI',8,'Prego contatta il tuo amministratore di sistema per assistenza.');
INSERT INTO international VALUES (68,'WebGUI',8,'Le informazioni sul\' account non sono valide. O l\'account non esiste oppure hai fornito una combinazione errata di Nome Utente/Password.');
INSERT INTO international VALUES (67,'WebGUI',8,'Crea un nuovo account.');
INSERT INTO international VALUES (66,'WebGUI',8,'Entra');
INSERT INTO international VALUES (65,'WebGUI',8,'Prego disattiva il mio account permanentemente.');
INSERT INTO international VALUES (64,'WebGUI',8,'Esci.');
INSERT INTO international VALUES (63,'WebGUI',8,'Attiva l\'Interfaccia Amministrativa.');
INSERT INTO international VALUES (62,'WebGUI',8,'Salva');
INSERT INTO international VALUES (61,'WebGUI',8,'Aggiorna Informazioni dell\'Account');
INSERT INTO international VALUES (492,'WebGUI',8,'Lista dei campi del profilo.');
INSERT INTO international VALUES (59,'WebGUI',8,'Ho dimenticato la password.');
INSERT INTO international VALUES (58,'WebGUI',8,'Ho già un account.');
INSERT INTO international VALUES (57,'WebGUI',8,'E\' necessario solo se vuoi usare funzioni che richiedono l\'email.');
INSERT INTO international VALUES (56,'WebGUI',8,'Indirizzo Email');
INSERT INTO international VALUES (55,'WebGUI',8,'Password (conferma)');
INSERT INTO international VALUES (54,'WebGUI',8,'Crea Account');
INSERT INTO international VALUES (51,'WebGUI',8,'Password');
INSERT INTO international VALUES (52,'WebGUI',8,'login');
INSERT INTO international VALUES (53,'WebGUI',8,'Rendi Pagina Stampabile');
INSERT INTO international VALUES (50,'WebGUI',8,'Nome Utente');
INSERT INTO international VALUES (48,'WebGUI',8,'Ciao');
INSERT INTO international VALUES (49,'WebGUI',8,'<br>Clicca <a href=\"^\\;?op=logout\">qui</a> per uscire.');
INSERT INTO international VALUES (47,'WebGUI',8,'Home');
INSERT INTO international VALUES (45,'WebGUI',8,'No, ho fatto uno sbaglio.');
INSERT INTO international VALUES (44,'WebGUI',8,'Sì, sono sicuro.');
INSERT INTO international VALUES (43,'WebGUI',8,'Sei sicuro di voler cancellare questo contenuto?');
INSERT INTO international VALUES (42,'WebGUI',8,'Prego Conferma');
INSERT INTO international VALUES (41,'WebGUI',8,'Hai cercato di rimuovere un componente vitale del sistema. Se continui può\r\ncessare di funzionare.');
INSERT INTO international VALUES (40,'WebGUI',8,'Componente Vitale');
INSERT INTO international VALUES (39,'WebGUI',8,'Non hai abbastanza privilegi per accedere a questa pagina.');
INSERT INTO international VALUES (38,'WebGUI',8,'Non hai abbastanza privilegi per questa operazione. Prego ^a(entra con un account); che ha sufficenti privilegi prima di eseguire questa operazione.');
INSERT INTO international VALUES (404,'WebGUI',8,'Prima Pagina');
INSERT INTO international VALUES (37,'WebGUI',8,'Permesso negato!');
INSERT INTO international VALUES (36,'WebGUI',8,'Devi essere un amministratore per usare questa funzione. Per favore contatta uno degli amministratori. Questa è una lista degli amministratori di questo sistema:');
INSERT INTO international VALUES (35,'WebGUI',8,'Funzioni Amministrative');
INSERT INTO international VALUES (34,'WebGUI',8,'imposta la data (mm/gg/aaaa)');
INSERT INTO international VALUES (33,'WebGUI',8,'Sabato');
INSERT INTO international VALUES (31,'WebGUI',8,'Giovedì');
INSERT INTO international VALUES (32,'WebGUI',8,'Venerdì');
INSERT INTO international VALUES (30,'WebGUI',8,'Mercoledì');
INSERT INTO international VALUES (29,'WebGUI',8,'Martedì');
INSERT INTO international VALUES (29,'UserSubmission',8,'Sistema di Contributi degli Utenti');
INSERT INTO international VALUES (28,'WebGUI',8,'Lunedì');
INSERT INTO international VALUES (28,'UserSubmission',8,'Ritorna alla lista dei Contributi');
INSERT INTO international VALUES (27,'WebGUI',8,'Domenica');
INSERT INTO international VALUES (27,'UserSubmission',8,'Modifica');
INSERT INTO international VALUES (26,'WebGUI',8,'Dicembre');
INSERT INTO international VALUES (26,'UserSubmission',8,'Rifiuta');
INSERT INTO international VALUES (25,'WebGUI',8,'Novembre');
INSERT INTO international VALUES (25,'UserSubmission',8,'Lascia Pendenti');
INSERT INTO international VALUES (24,'WebGUI',8,'Ottobre');
INSERT INTO international VALUES (24,'UserSubmission',8,'Approva');
INSERT INTO international VALUES (23,'WebGUI',8,'Settembre');
INSERT INTO international VALUES (23,'UserSubmission',8,'Mandato in Data:');
INSERT INTO international VALUES (22,'WebGUI',8,'Agosto');
INSERT INTO international VALUES (22,'UserSubmission',8,'Mandato da:');
INSERT INTO international VALUES (21,'WebGUI',8,'Luglio');
INSERT INTO international VALUES (21,'UserSubmission',8,'Mandato da');
INSERT INTO international VALUES (20,'WebGUI',8,'Giugno');
INSERT INTO international VALUES (20,'UserSubmission',8,'Manda un nuovo Contributo');
INSERT INTO international VALUES (19,'WebGUI',8,'Maggio');
INSERT INTO international VALUES (20,'MessageBoard',8,'Ultima Risposta');
INSERT INTO international VALUES (19,'UserSubmission',8,'Modifica Contributo');
INSERT INTO international VALUES (19,'MessageBoard',8,'Risposte');
INSERT INTO international VALUES (18,'WebGUI',8,'Aprile');
INSERT INTO international VALUES (18,'UserSubmission',8,'Modifica il sistema di contributi degli utenti');
INSERT INTO international VALUES (18,'MessageBoard',8,'Thread Iniziato');
INSERT INTO international VALUES (17,'WebGUI',8,'Marzo');
INSERT INTO international VALUES (17,'UserSubmission',8,'Sei sicuro di voler cancellare questo contributo?');
INSERT INTO international VALUES (17,'MessageBoard',8,'Manda un nuovo Messaggio');
INSERT INTO international VALUES (16,'WebGUI',8,'Febbraio');
INSERT INTO international VALUES (16,'UserSubmission',8,'Senza Titolo');
INSERT INTO international VALUES (16,'MessageBoard',8,'Data');
INSERT INTO international VALUES (15,'WebGUI',8,'Gennaio');
INSERT INTO international VALUES (15,'UserSubmission',8,'Modifica/Cancella');
INSERT INTO international VALUES (15,'MessageBoard',8,'Autore');
INSERT INTO international VALUES (14,'WebGUI',8,'Visualizza i contributi pendenti.');
INSERT INTO international VALUES (14,'UserSubmission',8,'Stato');
INSERT INTO international VALUES (14,'Article',8,'Allinea Immagine');
INSERT INTO international VALUES (13,'WebGUI',8,'Visualizza indice dell\'aiuto.');
INSERT INTO international VALUES (13,'UserSubmission',8,'Data');
INSERT INTO international VALUES (13,'MessageBoard',8,'Rispondi');
INSERT INTO international VALUES (13,'LinkList',8,'Aggiungi un nuovo link.');
INSERT INTO international VALUES (13,'EventsCalendar',8,'Modifica Evento');
INSERT INTO international VALUES (13,'Article',8,'Cancella');
INSERT INTO international VALUES (12,'WebGUI',8,'Spegni interfaccia amministrativa.');
INSERT INTO international VALUES (12,'UserSubmission',8,'(deseleziona se scrivi in HTML)');
INSERT INTO international VALUES (12,'EventsCalendar',8,'Modifica Calendario Eventi');
INSERT INTO international VALUES (12,'LinkList',8,'Modifica Link');
INSERT INTO international VALUES (12,'MessageBoard',8,'Modifica Messaggio');
INSERT INTO international VALUES (12,'SQLReport',8,'Error: Could not connect to the database.');
INSERT INTO international VALUES (11,'WebGUI',8,'Svuota il cestino');
INSERT INTO international VALUES (12,'Article',8,'Modifica Articolo');
INSERT INTO international VALUES (11,'SQLReport',8,'<b>Debug:</b> Errore: c\'è stato un problema con la query.');
INSERT INTO international VALUES (11,'MessageBoard',8,'Torna alla lista dei messaggi');
INSERT INTO international VALUES (75,'EventsCalendar',1,'Which do you wish to do?');
INSERT INTO international VALUES (11,'Article',8,'(Seleziona \"Si\" solo se non hai aggiunto &lt;br&gt; manualmente.)');
INSERT INTO international VALUES (10,'WebGUI',8,'Visualizza il cestino.');
INSERT INTO international VALUES (10,'UserSubmission',8,'Stato predefinito');
INSERT INTO international VALUES (10,'SQLReport',8,'Error: The SQL specified is of an improper format.');
INSERT INTO international VALUES (10,'Poll',8,'Azzera i voti.');
INSERT INTO international VALUES (10,'LinkList',8,'Modifica Lista di Link');
INSERT INTO international VALUES (10,'FAQ',8,'Modifica Domanda');
INSERT INTO international VALUES (715,'WebGUI',1,'Redirect URL');
INSERT INTO international VALUES (10,'Article',8,'Converti gli \'a capo\'?');
INSERT INTO international VALUES (9,'WebGUI',8,'Visualizza appunti.');
INSERT INTO international VALUES (9,'UserSubmission',8,'Pendente');
INSERT INTO international VALUES (9,'SQLReport',8,'Error: The DSN specified is of an improper format.');
INSERT INTO international VALUES (9,'Poll',8,'Modifica Sondaggio');
INSERT INTO international VALUES (9,'MessageBoard',8,'ID Messaggio:');
INSERT INTO international VALUES (9,'LinkList',8,'Sei sicuro di voler cancellare questo link?');
INSERT INTO international VALUES (9,'FAQ',8,'Aggiungi una nuova domanda.');
INSERT INTO international VALUES (9,'EventsCalendar',8,'finché');
INSERT INTO international VALUES (9,'Article',8,'Allegato');
INSERT INTO international VALUES (8,'WebGUI',8,'Visualizza pagina non trovata.');
INSERT INTO international VALUES (8,'UserSubmission',8,'Respinto');
INSERT INTO international VALUES (8,'SQLReport',8,'Modifica SQL Report');
INSERT INTO international VALUES (8,'SiteMap',8,'Spaziatura di linea');
INSERT INTO international VALUES (8,'Poll',8,'(Aggiungi una risposta per linea. Non più di 20)');
INSERT INTO international VALUES (8,'MessageBoard',8,'Data:');
INSERT INTO international VALUES (8,'LinkList',8,'URL');
INSERT INTO international VALUES (8,'FAQ',8,'Modifica F.A.Q.');
INSERT INTO international VALUES (8,'EventsCalendar',8,'Ricorre ogni');
INSERT INTO international VALUES (8,'Article',8,'URL del Link');
INSERT INTO international VALUES (7,'WebGUI',8,'Gestisci gli utenti.');
INSERT INTO international VALUES (7,'SQLReport',8,'Password Database');
INSERT INTO international VALUES (7,'UserSubmission',8,'Approvato');
INSERT INTO international VALUES (7,'SiteMap',8,'Bullet');
INSERT INTO international VALUES (7,'Poll',8,'Risposte');
INSERT INTO international VALUES (7,'MessageBoard',8,'Autore:');
INSERT INTO international VALUES (7,'FAQ',8,'Sei sicuro di voler cancellare questa domanda?');
INSERT INTO international VALUES (7,'Article',8,'Titolo del link');
INSERT INTO international VALUES (6,'WebGUI',8,'Gestisci gli stili.');
INSERT INTO international VALUES (6,'UserSubmission',8,'Contributi per pagina');
INSERT INTO international VALUES (6,'SyndicatedContent',8,'Contenuto Attuale');
INSERT INTO international VALUES (6,'SQLReport',8,'Utente Database');
INSERT INTO international VALUES (6,'SiteMap',8,'Rientro');
INSERT INTO international VALUES (6,'Poll',8,'Domanda');
INSERT INTO international VALUES (6,'MessageBoard',8,'Modifica Forum');
INSERT INTO international VALUES (6,'LinkList',8,'Lista di Link');
INSERT INTO international VALUES (6,'FAQ',8,'Risposta');
INSERT INTO international VALUES (6,'ExtraColumn',8,'Modifica Colonna Extra');
INSERT INTO international VALUES (701,'WebGUI',8,'Settimana');
INSERT INTO international VALUES (6,'Article',8,'Immagine');
INSERT INTO international VALUES (5,'WebGUI',8,'Gestisci i gruppi.');
INSERT INTO international VALUES (5,'UserSubmission',8,'Il tuo contributo è stato respinto.');
INSERT INTO international VALUES (5,'SyndicatedContent',8,'Ultimo preso');
INSERT INTO international VALUES (5,'SQLReport',8,'DSN');
INSERT INTO international VALUES (5,'SiteMap',8,'Modifica la mappa del sito');
INSERT INTO international VALUES (5,'Poll',8,'Larghezza del grafico');
INSERT INTO international VALUES (5,'MessageBoard',8,'Modifica Timeout');
INSERT INTO international VALUES (5,'LinkList',8,'Continua aggiungendo un link?');
INSERT INTO international VALUES (5,'ExtraColumn',8,'StyleSheet Class');
INSERT INTO international VALUES (5,'FAQ',8,'Domanda');
INSERT INTO international VALUES (5,'Item',8,'Scarica allegato');
INSERT INTO international VALUES (700,'WebGUI',8,'Giorno');
INSERT INTO international VALUES (4,'WebGUI',8,'Gestisci i settaggi.');
INSERT INTO international VALUES (4,'UserSubmission',8,'Il tuo contributo è stato approvato.');
INSERT INTO international VALUES (4,'SyndicatedContent',8,'Modifica Contenuto di altri siti');
INSERT INTO international VALUES (4,'SQLReport',8,'Query');
INSERT INTO international VALUES (4,'SiteMap',8,'Profondità');
INSERT INTO international VALUES (4,'Poll',8,'Chi può votare?');
INSERT INTO international VALUES (4,'MessageBoard',8,'Messaggi Per Pagina');
INSERT INTO international VALUES (4,'LinkList',8,'Bullet');
INSERT INTO international VALUES (4,'Item',8,'Item');
INSERT INTO international VALUES (4,'ExtraColumn',8,'Larghezza');
INSERT INTO international VALUES (4,'EventsCalendar',8,'Accade solo una volta.');
INSERT INTO international VALUES (4,'Article',8,'Data di fine');
INSERT INTO international VALUES (3,'WebGUI',8,'Incolla dagli appunti...');
INSERT INTO international VALUES (3,'UserSubmission',8,'Hai nuovi contenuti degli utenti da approvare.');
INSERT INTO international VALUES (3,'SQLReport',8,'Template');
INSERT INTO international VALUES (3,'SiteMap',8,'Partire da questo livello?');
INSERT INTO international VALUES (3,'Poll',8,'Attivo');
INSERT INTO international VALUES (3,'MessageBoard',8,'Chi può postare?');
INSERT INTO international VALUES (3,'LinkList',8,'Apri in nuova finestra?');
INSERT INTO international VALUES (3,'Item',8,'Cancella allegato');
INSERT INTO international VALUES (3,'ExtraColumn',8,'Spaziatore');
INSERT INTO international VALUES (3,'Article',8,'Data di inizio');
INSERT INTO international VALUES (2,'WebGUI',8,'Pagina');
INSERT INTO international VALUES (2,'UserSubmission',8,'Chi può contribuire?');
INSERT INTO international VALUES (2,'SyndicatedContent',8,'Contenuto da altri siti');
INSERT INTO international VALUES (2,'SiteMap',8,'Mappa del sito');
INSERT INTO international VALUES (2,'MessageBoard',8,'Forum');
INSERT INTO international VALUES (2,'LinkList',8,'Spaziatura di linea');
INSERT INTO international VALUES (2,'Item',8,'Allegato');
INSERT INTO international VALUES (2,'FAQ',8,'F.A.Q.');
INSERT INTO international VALUES (2,'EventsCalendar',8,'Calendario Eventi');
INSERT INTO international VALUES (1,'WebGUI',8,'Aggiungi contenuto...');
INSERT INTO international VALUES (1,'UserSubmission',8,'Chi può approvare?');
INSERT INTO international VALUES (1,'SyndicatedContent',8,'URL del file RSS');
INSERT INTO international VALUES (1,'SQLReport',8,'SQL Report');
INSERT INTO international VALUES (1,'Poll',8,'Sondaggio');
INSERT INTO international VALUES (1,'LinkList',8,'Indentazione');
INSERT INTO international VALUES (1,'Item',8,'URL del link');
INSERT INTO international VALUES (1,'FAQ',8,'Continua aggiungendo una domanda?');
INSERT INTO international VALUES (1,'ExtraColumn',8,'Colonna Extra');
INSERT INTO international VALUES (1,'EventsCalendar',8,'Continua aggiungendo un evento?');
INSERT INTO international VALUES (1,'Article',8,'Articolo');
INSERT INTO international VALUES (367,'WebGUI',8,'Scade dopo');
INSERT INTO international VALUES (493,'WebGUI',8,'Torna al sito.');
INSERT INTO international VALUES (495,'WebGUI',8,'Assistente creazione del testo');
INSERT INTO international VALUES (496,'WebGUI',8,'Editor da utilizzare');
INSERT INTO international VALUES (494,'WebGUI',8,'Real Objects Edit-On Pro');
INSERT INTO international VALUES (497,'WebGUI',8,'Data di pubblicazione');
INSERT INTO international VALUES (498,'WebGUI',8,'Data di oscuramento');
INSERT INTO international VALUES (499,'WebGUI',8,'Wobject ID');
INSERT INTO international VALUES (22,'DownloadManager',8,'Continua aggiungendo un download?');
INSERT INTO international VALUES (21,'EventsCalendar',8,'Continua aggiungendo un evento?');
INSERT INTO international VALUES (20,'EventsCalendar',8,'Aggiungi un evento.');
INSERT INTO international VALUES (38,'UserSubmission',8,'(Seleziona \"No\" solo se hai usato l\'assistente per la creazione del testo.)');
INSERT INTO international VALUES (500,'WebGUI',8,'ID pagina');
INSERT INTO international VALUES (501,'WebGUI',8,'Body');
INSERT INTO international VALUES (502,'WebGUI',8,'Sei sicuro di voler cancellare questo template e attribuire a tutte le pagine che lo usano il template di default?');
INSERT INTO international VALUES (503,'WebGUI',8,'Template ID');
INSERT INTO international VALUES (504,'WebGUI',8,'Template');
INSERT INTO international VALUES (505,'WebGUI',8,'Aggiungi un nuovo template.');
INSERT INTO international VALUES (506,'WebGUI',8,'Gestisci i Templates');
INSERT INTO international VALUES (507,'WebGUI',8,'Modifica Template');
INSERT INTO international VALUES (508,'WebGUI',8,'Gestisci templates.');
INSERT INTO international VALUES (39,'UserSubmission',8,'Rispondi');
INSERT INTO international VALUES (40,'UserSubmission',8,'Inviato da');
INSERT INTO international VALUES (41,'UserSubmission',8,'Data');
INSERT INTO international VALUES (42,'UserSubmission',8,'Modifica Risposta');
INSERT INTO international VALUES (43,'UserSubmission',8,'Cancella Risposta');
INSERT INTO international VALUES (45,'UserSubmission',8,'Torna ad invio');
INSERT INTO international VALUES (46,'UserSubmission',8,'Leggi di piu\'...');
INSERT INTO international VALUES (47,'UserSubmission',8,'Rispondi');
INSERT INTO international VALUES (48,'UserSubmission',8,'Consenti Discussioni?');
INSERT INTO international VALUES (49,'UserSubmission',8,'Modifica il Timeout');
INSERT INTO international VALUES (50,'UserSubmission',8,'Chi può postare');
INSERT INTO international VALUES (44,'UserSubmission',8,'Chi può Moderare');
INSERT INTO international VALUES (51,'UserSubmission',8,'Visualizza thumbnails?');
INSERT INTO international VALUES (52,'UserSubmission',8,'Thumbnail');
INSERT INTO international VALUES (53,'UserSubmission',8,'Layout');
INSERT INTO international VALUES (54,'UserSubmission',8,'Web Log');
INSERT INTO international VALUES (55,'UserSubmission',8,'Tradizionale');
INSERT INTO international VALUES (56,'UserSubmission',8,'Photo Gallery');
INSERT INTO international VALUES (57,'UserSubmission',8,'Risposte');
INSERT INTO international VALUES (11,'FAQ',8,'Attiva elenco domande con link?');
INSERT INTO international VALUES (12,'FAQ',8,'Attiva D/R ?');
INSERT INTO international VALUES (13,'FAQ',8,'Attiva [top] link?');
INSERT INTO international VALUES (14,'FAQ',8,'D');
INSERT INTO international VALUES (15,'FAQ',8,'R');
INSERT INTO international VALUES (16,'FAQ',8,'[top]');
INSERT INTO international VALUES (509,'WebGUI',8,'Layout Discussioni');
INSERT INTO international VALUES (510,'WebGUI',8,'Flat');
INSERT INTO international VALUES (511,'WebGUI',8,'Threaded');
INSERT INTO international VALUES (512,'WebGUI',8,'Prossimo Thread');
INSERT INTO international VALUES (513,'WebGUI',8,'Thread Precedente');
INSERT INTO international VALUES (514,'WebGUI',8,'Visto');
INSERT INTO international VALUES (515,'WebGUI',8,'Aggiungi la data di modifica nei posts?');
INSERT INTO international VALUES (517,'WebGUI',8,'Spegni Admin!');
INSERT INTO international VALUES (516,'WebGUI',8,'Attiva Admin!');
INSERT INTO international VALUES (518,'WebGUI',8,'Inbox Notifiche');
INSERT INTO international VALUES (519,'WebGUI',8,'Non voglio ricevere notifiche.');
INSERT INTO international VALUES (520,'WebGUI',8,'Voglio ricevere notifiche via email.');
INSERT INTO international VALUES (521,'WebGUI',8,'Voglio ricevere notifiche via email al pager.');
INSERT INTO international VALUES (522,'WebGUI',8,'Voglio ricevere notifiche via ICQ.');
INSERT INTO international VALUES (523,'WebGUI',8,'Notification');
INSERT INTO international VALUES (524,'WebGUI',8,'Aggiungi la data di modifica nei post?');
INSERT INTO international VALUES (525,'WebGUI',8,'Modifica Settaggi Contenuti');
INSERT INTO international VALUES (526,'WebGUI',8,'Filtra solo JavaScript.');
INSERT INTO international VALUES (527,'WebGUI',8,'Home Page di default');
INSERT INTO international VALUES (354,'WebGUI',8,'Visualizza Inbox.');
INSERT INTO international VALUES (528,'WebGUI',8,'Nome Template');
INSERT INTO international VALUES (529,'WebGUI',8,'Risultati');
INSERT INTO international VALUES (530,'WebGUI',8,'con <b>tutte</b> le parole');
INSERT INTO international VALUES (531,'WebGUI',8,'con la <b>frase esatta</b>');
INSERT INTO international VALUES (532,'WebGUI',8,'con <b>almeno</b> queste parole');
INSERT INTO international VALUES (533,'WebGUI',8,'<b>senza</b> le parole');
INSERT INTO international VALUES (535,'WebGUI',8,'Gruppo a cui notificare un nuovo utente');
INSERT INTO international VALUES (534,'WebGUI',8,'Notifica quando si iscrive un nuovo utente?');
INSERT INTO international VALUES (536,'WebGUI',8,'Il nuovo utente ^@; si è iscritto al sito.');
INSERT INTO international VALUES (537,'WebGUI',8,'Karma');
INSERT INTO international VALUES (538,'WebGUI',8,'Soglia del Karma');
INSERT INTO international VALUES (539,'WebGUI',8,'Abilita Karma?');
INSERT INTO international VALUES (540,'WebGUI',8,'Karma Per Login');
INSERT INTO international VALUES (20,'Poll',8,'Karma Per Voto');
INSERT INTO international VALUES (541,'WebGUI',8,'Karma Per Post');
INSERT INTO international VALUES (30,'UserSubmission',8,'Karma Per Contributo');
INSERT INTO international VALUES (542,'WebGUI',8,'Precedente..');
INSERT INTO international VALUES (543,'WebGUI',8,'Aggiungi un nuovo gruppo');
INSERT INTO international VALUES (544,'WebGUI',8,'Sei sicuro di voler cancellare questo gruppo?');
INSERT INTO international VALUES (545,'WebGUI',8,'Modifica i Gruppi di Immagini');
INSERT INTO international VALUES (546,'WebGUI',8,'Id Gruppo');
INSERT INTO international VALUES (547,'WebGUI',8,'Gruppo Genitore');
INSERT INTO international VALUES (548,'WebGUI',8,'Nome del Gruppo');
INSERT INTO international VALUES (549,'WebGUI',8,'Descrizione del Gruppo');
INSERT INTO international VALUES (550,'WebGUI',8,'Visualizza Gruppo di Immagini');
INSERT INTO international VALUES (382,'WebGUI',8,'Modifica Immagine');
INSERT INTO international VALUES (551,'WebGUI',8,'Avviso');
INSERT INTO international VALUES (552,'WebGUI',8,'Pendente');
INSERT INTO international VALUES (553,'WebGUI',8,'Stato');
INSERT INTO international VALUES (554,'WebGUI',8,'Agisci');
INSERT INTO international VALUES (555,'WebGUI',8,'Modifica il karma di questo utente.');
INSERT INTO international VALUES (556,'WebGUI',8,'Ammontare');
INSERT INTO international VALUES (557,'WebGUI',8,'Descrizione');
INSERT INTO international VALUES (558,'WebGUI',8,'Modifica il karma dell\'utente');
INSERT INTO international VALUES (61,'DownloadManager',1,'Download Manager, Add/Edit');
INSERT INTO international VALUES (61,'Item',1,'Item, Add/Edit');
INSERT INTO international VALUES (61,'UserSubmission',1,'User Submission System, Add/Edit');
INSERT INTO international VALUES (61,'FAQ',1,'FAQ, Add/Edit');
INSERT INTO international VALUES (61,'SyndicatedContent',1,'Syndicated Content, Add/Edit');
INSERT INTO international VALUES (61,'EventsCalendar',1,'Events Calendar, Add/Edit');
INSERT INTO international VALUES (61,'MessageBoard',1,'Message Board, Add/Edit');
INSERT INTO international VALUES (61,'LinkList',1,'Link List, Add/Edit');
INSERT INTO international VALUES (61,'Article',1,'Article, Add/Edit');
INSERT INTO international VALUES (61,'ExtraColumn',1,'Extra Column, Add/Edit');
INSERT INTO international VALUES (61,'Poll',1,'Poll, Add/Edit');
INSERT INTO international VALUES (61,'SiteMap',1,'Site Map, Add/Edit');
INSERT INTO international VALUES (61,'SQLReport',1,'SQL Report, Add/Edit');
INSERT INTO international VALUES (61,'MailForm',1,'Mail Form, Add/Edit');
INSERT INTO international VALUES (62,'MailForm',1,'Mail Form Fields, Add/Edit');
INSERT INTO international VALUES (71,'DownloadManager',1,'The Download Manager is designed to help you manage file distribution on your site. It allows you to specify who may download files from your site.\r\n<p>\r\n\r\n<b>Paginate After</b><br>\r\nHow many files should be displayed before splitting the results into separate pages? In other words, how many files should be displayed per page?\r\n<p>\r\n\r\n<b>Display thumbnails?</b><br>\r\nCheck this if you want to display thumbnails for any images that are uploaded. Note that the thumbnail is only displayed for the main attachment, not the alternate versions.\r\n<p>\r\n\r\n<b>Proceed to add download?</b><br>\r\nIf you wish to start adding files to download right away, leave this checked.\r\n<p>\r\n\r\n');
INSERT INTO international VALUES (71,'Item',1,'Like Articles, Items are the Swiss Army knife of WebGUI. Most pieces of static content can be added via the Item, though Items are usually used for smaller content than Articles.\r\n<br><br>\r\n\r\n<b>Link URL</b><br>\r\nThis URL will be attached to the title of this Item.\r\n<br><br>\r\n<i>Example:</i> http://www.google.com\r\n<br><br>\r\n\r\n<b>Attachment</b><br>\r\nIf you wish to attach a word processor file, a zip file, or any other file for download by your users, then choose it from your hard drive.\r\n\r\n');
INSERT INTO international VALUES (71,'UserSubmission',1,'User Submission Systems are a great way to add a sense of community to any site as well as get free content from your users.\r\n<br><br>\r\n\r\n<b>Layout</b><br>\r\nWhat should this user submission system look like? Currently these are the views available:\r\n<ul>\r\n<li><b>Traditional</b> - Creates a simple spreadsheet style table that lists off each submission and is sorted by date. \r\n</li><li><b>Web Log</b> - Creates a view that looks like the news site <a href=\"http://slashdot.org/\">Slashdot</a>. Incidentally, Slashdot invented the web log format, which has since become very popular on news oriented sites.\r\n</li><li><b>Photo Gallery</b> - Creates a matrix of thumbnails that can be clicked on to view the full image.\r\n</li></ul>\r\n\r\n<b>Who can approve?</b><br>\r\nWhat group is allowed to approve and deny content?\r\n<br><br>\r\n\r\n<b>Who can contribute?</b><br>\r\nWhat group is allowed to contribute content?\r\n<br><br>\r\n\r\n<b>Submissions Per Page</b><br>\r\nHow many submissions should be listed per page in the submissions index?\r\n<br><br>\r\n\r\n<b>Default Status</b><br>\r\nShould submissions be set to <i>Approved</i>, <i>Pending</i>, or <i>Denied</i> by default?\r\n<br><br>\r\n<i>Note:</i> If you set the default status to Pending, then be prepared to monitor your message log for new submissions.\r\n<p>\r\n\r\n<b>Karma Per Submission</b><br>\r\nHow much karma should be given to a user when they contribute to this user submission system?\r\n<p>\r\n\r\n\r\n<b>Display thumbnails?</b><br>\r\nIf there is an image present in the submission, the thumbnail will be displayed in the Layout (see above).\r\n<p>\r\n\r\n<b>Allow discussion?</b><br>\r\nDo you wish to attach a discussion to this user submission system? If you do, users will be able to comment on each submission.\r\n<p>\r\n\r\n<b>Who can post?</b><br>\r\nSelect the group that is allowed to post to this discussion.\r\n<p>\r\n\r\n<b>Edit Timeout</b><br>\r\nHow long should a user be able to edit their post before editing is locked to them?\r\n<p>\r\n<i>Note:</i> Don\'t set this limit too high. One of the great things about discussions is that they are an accurate record of who said what. If you allow editing for a long time, then a user has a chance to go back and change his/her mind a long time after the original statement was made.\r\n<p>\r\n\r\n<b>Karma Per Post</b><br>\r\nHow much karma should be given to a user when they post to this discussion?\r\n<p>\r\n\r\n<b>Who can moderate?</b><br>\r\nSelect the group that is allowed to moderate this discussion.\r\n<p>\r\n\r\n<b>Moderation Type?</b><br>\r\nYou can select what type of moderation you\'d like for your users. <i>After-the-fact</i> means that when a user posts a message it is displayed publically right away. <i>Pre-emptive</i> means that a moderator must preview and approve users posts before allowing them to be publically visible. Alerts for new posts will automatically show up in the moderator\'s WebGUI Inbox.\r\n<p>\r\nNote: In both types of moderation the moderator can always edit or delete the messages posted by your users.\r\n<p>\r\n');
INSERT INTO international VALUES (71,'FAQ',1,'It seems that almost every web site, intranet, and extranet in the world has a Frequently Asked Questions area. This wobject helps you build one, too.\r\n<br><br>\r\n\r\n<b>Turn TOC on?</b><br>\r\nDo you wish to display a TOC (or Table of Contents) for this FAQ? A TOC is a list of links (questions) at the top of the FAQ that link down the answers.\r\n<p>\r\n\r\n<b>Turn Q/A on?</b><br>\r\nSome people wish to display a <b>Q:</b> in front of each question and an <b>A:</b> in front of each answer. This switch enables that.\r\n<p>\r\n\r\n<b>Turn [top] link on?</b><br>\r\nDo you wish to display a link after each answer that takes you back to the top of the page?\r\n<p>\r\n\r\n<b>Proceed to add question?</b><br>\r\nLeave this checked if you want to add questions to the FAQ directly after creating it.\r\n<br><br>\r\n\r\n<hr size=\"1\">\r\n<i><b>Note:</b></i> The following style is specific to the FAQ.\r\n<br><br>\r\n<b>.faqQuestion</b><br>\r\nAn F.A.Q. question. To distinguish it from an answer.\r\n\r\n');
INSERT INTO international VALUES (71,'SyndicatedContent',1,'Syndicated content is content that is pulled from another site using the RDF/RSS specification. This technology is often used to pull headlines from various news sites like <a href=\"http://www.cnn.com/\">CNN</a> and  <a href=\"http://slashdot.org/\">Slashdot</a>. It can, of course, be used for other things like sports scores, stock market info, etc.\r\n<br><br>\r\n\r\n<b>URL to RSS file</b><br>\r\nProvide the exact URL (starting with http://) to the syndicated content\'s RDF or RSS file. The syndicated content will be downloaded from this URL hourly.\r\n<br><br>\r\nYou can find syndicated content at the following locations:\r\n</p><ul>\r\n<li><a href=\"http://www.newsisfree.com/\">http://www.newsisfree.com</a>\r\n</li><li><a href=\"http://www.syndic8.com/\">http://www.syndic8.com</a>\r\n</li><li><a href=\"http://www.voidstar.com/node.php?id=144\">http://www.voidstar.com/node.php?id=144</a>\r\n</li><li><a href=\"http://my.userland.com/\">http://my.userland.com</a>\r\n</li><li><a href=\"http://www.webreference.com/services/news/\">http://www.webreference.com/services/news/</a>\r\n</li><li><a href=\"http://www.xmltree.com/\">http://www.xmltree.com</a>\r\n</li><li><a href=\"http://w.moreover.com/\">http://w.moreover.com/</a>\r\n</li></ul>');
INSERT INTO international VALUES (71,'EventsCalendar',1,'Events calendars are used on many intranets to keep track of internal dates that affect a whole organization. Also, Events Calendars on consumer sites are a great way to let your customers know what events you\'ll be attending and what promotions you\'ll be having.\r\n<br><br>\r\n\r\n<b>Display Layout</b><br>\r\nThis can be set to <i>List</i> or <i>Calendar</i>. When set to <i>List</i> the events will be listed by date of occurence (and events that have already passed will not be displayed). This type of layout is best suited for Events Calendars that have only a few events per month. When set to <i>Calendar</i> the Events Calendar will display a traditional monthly Calendar, which can be paged through month-by-month. This type of layout is generally used when there are many events in each month.\r\n<br><br>\r\n\r\n<b>Paginate After</b><br>\r\nWhen using the list layout, how many events should be shown per page?\r\n<br><br>\r\n<b>Proceed to add event?</b><br>\r\nLeave this set to yes if you want to add events to the Events Calendar directly after creating it.\r\n<br><br>\r\n\r\n<i>Note:</i> Events that have already happened will not be displayed on the events calendar.\r\n<br><br>\r\n<hr size=\"1\">\r\n<i><b>Note:</b></i> The following style is specific to the Events Calendar.\r\n<br><br>\r\n<b>.eventTitle </b><br>\r\nThe title of an individual event.\r\n\r\n');
INSERT INTO international VALUES (71,'MessageBoard',1,'Message boards, also called Forums and/or Discussions, are a great way to add community to any site or intranet. Many companies use message boards internally to collaborate on projects.\r\n<br><br>\r\n\r\n<b>Messages Per Page</b><br>\r\nWhen a visitor first comes to a message board s/he will be presented with a listing of all the topics (a.k.a. threads) of the Message Board. If a board is popular, it will quickly have many topics. The Messages Per Page attribute allows you to specify how many topics should be shown on one page.\r\n<p>\r\n\r\n<b>Who can post?</b><br>\r\nSelect the group that is allowed to post to this discussion.\r\n<p>\r\n\r\n<b>Edit Timeout</b><br>\r\nHow long should a user be able to edit their post before editing is locked to them?\r\n<p>\r\n<i>Note:</i> Don\'t set this limit too high. One of the great things about discussions is that they are an accurate record of who said what. If you allow editing for a long time, then a user has a chance to go back and change his/her mind a long time after the original statement was made.\r\n<p>\r\n\r\n<b>Karma Per Post</b><br>\r\nHow much karma should be given to a user when they post to this discussion?\r\n<p>\r\n\r\n<b>Who can moderate?</b><br>\r\nSelect the group that is allowed to moderate this discussion.\r\n<p>\r\n\r\n<b>Moderation Type?</b><br>\r\nYou can select what type of moderation you\'d like for your users. <i>After-the-fact</i> means that when a user posts a message it is displayed publically right away. <i>Pre-emptive</i> means that a moderator must preview and approve users posts before allowing them to be publically visible. Alerts for new posts will automatically show up in the moderator\'s WebGUI Inbox.\r\n<p>\r\nNote: In both types of moderation the moderator can always edit or delete the messages posted by your users.\r\n<p>\r\n');
INSERT INTO international VALUES (71,'LinkList',1,'Link Lists are just what they sound like, a list of links. Many sites have a links section, and this wobject just automates the process.\r\n<br><br>\r\n\r\n<b>Indent</b><br>\r\nHow many characters should indent each link?\r\n<p>\r\n\r\n<b>Line Spacing</b><br>\r\nHow many carriage returns should be placed between each link?\r\n<p>\r\n\r\n\r\n<b>Bullet</b><br>\r\nSpecify what bullet should be used before each line item. You can leave this blank if you want to. You can also specify HTML bullets like · and ». You can even use images from the image manager by specifying a macro like this ^I(bullet);.\r\n<p>\r\n\r\n\r\n<b>Proceed to add link?</b><br>\r\nLeave this set to yes if you want to add links to the Link List directly after creating it.\r\n<br><br>\r\n\r\n<b>Style</b><br>\r\nAn extra StyleSheet class has been added to this wobject: <b>.linkTitle</b>.  Use this to bold, colorize, or otheriwise manipulate the title of each link.\r\n</p><p>');
INSERT INTO international VALUES (71,'Article',1,'Articles are the Swiss Army knife of WebGUI. Most pieces of static content can be added via the Article.\r\n<br><br>\r\n<b>Image</b><br>\r\nChoose an image (.jpg, .gif, .png) file from your hard drive. This file will be uploaded to the server and displayed in your article.\r\n<br><br>\r\n\r\n<b>Align Image</b><br>\r\nChoose where you\'d like to position the image specified above.\r\n</p><p>\r\n\r\n<b>Attachment</b><br>\r\nIf you wish to attach a word processor file, a zip file, or any other file for download by your users, then choose it from your hard drive.\r\n<br><br>\r\n\r\n<b>Link Title</b><br>\r\nIf you wish to add a link to your article, enter the title of the link in this field. \r\n<br><br>\r\n<i>Example:</i> Google\r\n<br><br>\r\n\r\n<b>Link URL</b><br>\r\nIf you added a link title, now add the URL (uniform resource locator) here. \r\n<br><br>\r\n<i>Example:</i> http://www.google.com\r\n\r\n<br><br>\r\n\r\n<b>Convert carriage returns?</b><br>\r\nIf you\'re publishing HTML there\'s generally no need to check this option, but if you aren\'t using HTML and you want a carriage return every place you hit your \"Enter\" key, then check this option.\r\n<p>\r\n\r\n<b>Allow discussion?</b><br>\r\nChecking this box will enable responses to your article much like Articles on Slashdot.org.\r\n<p>\r\n\r\n<b>Who can post?</b><br>\r\nSelect the group that is allowed to post to this discussion.\r\n<p>\r\n\r\n<b>Edit Timeout</b><br>\r\nHow long should a user be able to edit their post before editing is locked to them?\r\n<p>\r\n<i>Note:</i> Don\'t set this limit too high. One of the great things about discussions is that they are an accurate record of who said what. If you allow editing for a long time, then a user has a chance to go back and change his/her mind a long time after the original statement was made.\r\n<p>\r\n\r\n<b>Karma Per Post</b><br>\r\nHow much karma should be given to a user when they post to this discussion?\r\n<p>\r\n\r\n<b>Who can moderate?</b><br>\r\nSelect the group that is allowed to moderate this discussion.\r\n<p>\r\n\r\n<b>Moderation Type?</b><br>\r\nYou can select what type of moderation you\'d like for your users. <i>After-the-fact</i> means that when a user posts a message it is displayed publically right away. <i>Pre-emptive</i> means that a moderator must preview and approve users posts before allowing them to be publically visible. Alerts for new posts will automatically show up in the moderator\'s WebGUI Inbox.\r\n<p>\r\nNote: In both types of moderation the moderator can always edit or delete the messages posted by your users.\r\n<p>\r\n');
INSERT INTO international VALUES (71,'ExtraColumn',1,'Extra columns allow you to change the layout of your page for one page only. If you wish to have multiple columns on all your pages, perhaps you should consider altering the <i>style</i> applied to your pages or use a Template instead of an Extra Column. \r\n<br><br>\r\nColumns are always added from left to right. Therefore any existing content will be on the left of the new column.\r\n<br><br>\r\n<b>Spacer</b><br>\r\nSpacer is the amount of space between your existing content and your new column. It is measured in pixels.\r\n<br><br>\r\n<b>Width</b><br>\r\nWidth is the actual width of the new column to be added. Width is measured in pixels.\r\n<br><br>\r\n<b>StyleSheet Class</b><br>\r\nBy default the <i>content</i> style (which is the style the body of your site should be using) that is applied to all columns. However, if you\'ve created a style specifically for columns, then feel free to modify this class.\r\n');
INSERT INTO international VALUES (71,'Poll',1,'Polls can be used to get the impressions of your users on various topics.\r\n<br><br>\r\n<b>Active</b><br>\r\nIf this box is checked, then users will be able to vote. Otherwise they\'ll only be able to see the results of the poll.\r\n<br><br>\r\n\r\n<b>Who can vote?</b><br>\r\nChoose a group that can vote on this Poll.\r\n<br><br>\r\n\r\n<b>Karma Per Vote</b><br>\r\nHow much karma should be given to a user when they vote?\r\n<p>\r\n\r\n<b>Graph Width</b><br>\r\nThe width of the poll results graph. The width is measured in pixels.\r\n<br><br>\r\n\r\n<b>Question</b><br>\r\nWhat is the question you\'d like to ask your users?\r\n<br><br>\r\n\r\n<b>Answers</b><br>\r\nEnter the possible answers to your question. Enter only one answer per line. Polls are only capable of 20 possible answers.\r\n<br><br>\r\n\r\n<b>Randomize answers?</b><br>\r\nIn order to be sure that the ordering of the answers in the poll does not bias your users, it is often helpful to present the options in a random order each time they are shown. Select \"yes\" to randomize the answers on the poll.\r\n<p>\r\n\r\n<b>Reset votes.</b><br>\r\nReset the votes on this Poll.\r\n<br><br>\r\n\r\n<hr size=\"1\">\r\n<i><b>Note:</b></i> The following style sheet entries are custom to the Poll wobject:\r\n<br><br>\r\n\r\n<b>.pollAnswer </b><br>\r\nAn answer on a poll.\r\n<p>\r\n\r\n<b>.pollColor </b>\r\nThe color of the percentage bar on a poll.\r\n<p>\r\n\r\n<b>.pollQuestion </b>\r\nThe question on a poll.\r\n\r\n');
INSERT INTO international VALUES (71,'SiteMap',1,'Site maps are used to provide additional navigation in WebGUI. You could set up a traditional site map that would display a hierarchical view of all the pages in the site. On the other hand, you could use site maps to provide extra navigation at certain levels in your site.\r\n<br><br>\r\n\r\n<b>Display synopsis?</b><br>\r\nDo you wish to display page sysnopsis along-side the links to each page? Note that in order for this option to be valid, pages must have synopsis defined.\r\n<br><br>\r\n\r\n<b>Starting from this level?</b><br>\r\nIf the Site Map should display the page tree starting from this level, then check this box. If you wish the Site Map to start from the home page then uncheck it.\r\n<br><br>\r\n\r\n<b>Depth To Traverse</b><br>\r\nHow many levels deep of navigation should the Site Map show? If 0 (zero) is specified, it will show as many levels as there are.\r\n<p>\r\n\r\n<b>Indent\r\nHow many characters should indent each level?\r\n</b></p><p><b>\r\n\r\n<b>Bullet</b><br>\r\nSpecify what bullet should be used before each line item. You can leave this blank if you want to. You can also specify HTML bullets like &middot; and &raquo;. You can even use images from the image manager by specifying a macro like this ^I(bullet);.\r\n</b></p><p><b>\r\n\r\n<b>Line Spacing</b><br>\r\nSpecify how many carriage returns should go between each item in the Site Map. This should be set to 1 or higher.\r\n</b></p><p><b>');
INSERT INTO international VALUES (71,'SQLReport',1,'SQL Reports are perhaps the most powerful wobject in the WebGUI arsenal. They allow a user to query data from any database that they have access to. This is great for getting sales figures from your Accounting database or even summarizing all the message boards on your web site.\r\n<p>\r\n\r\n\r\n<b>Preprocess macros on query?</b><br>\r\nIf you\'re using WebGUI macros in your query you\'ll want to check this box.\r\n<p>\r\n\r\n\r\n<b>Debug?</b><br>\r\nIf you want to display debugging and error messages on the page, check this box.\r\n<p>\r\n\r\n\r\n<b>Query</b><br>\r\nThis is a standard SQL query. If you are unfamiliar with SQL, <a href=\"http://www.plainblack.com/\">Plain Black Software</a> provides training courses in SQL and database management. You can make your queries more dynamic by using the ^FormParam(); macro.\r\n<p>\r\n\r\n\r\n<b>Report Template</b><br>\r\nLayout a template of how this report should look. Usually you\'ll use HTML tables to generate a report. An example is included below. If you leave this field blank a template will be generated based on your result set.\r\n<p>\r\n\r\n\r\nThere are special macro characters used in generating SQL Reports. They are ^-;, ^0;, ^1;, ^2;, ^3;, etc. These macros will be processed regardless of whether you checked the process macros box above. The ^- macro represents split points in the document where the report will begin and end looping. The numeric macros represent the data fields that will be returned from your query. There is an additional macro, ^rownum; that counts the rows of the query starting at 1 for use where the lines of the output need to be numbered.\r\n<p>\r\n\r\n\r\n<b>DSN</b><br>\r\n<b>D</b>ata <b>S</b>ource <b>N</b>ame is the unique identifier that Perl uses to describe the location of your database. It takes the format of DBI:[driver]:[database name]:[host]. \r\n<p>\r\n\r\n\r\n<i>Example:</i> DBI:mysql:WebGUI:localhost\r\n<p>\r\n\r\n\r\n<b>Database User</b>\r\nThe username you use to connect to the DSN.\r\n<p>\r\n\r\n\r\n<b>Database Password</b>\r\nThe password you use to connect to the DSN.\r\n<p>\r\n\r\n\r\n<b>Paginate After</b>\r\nHow many rows should be displayed before splitting the results into separate pages? In other words, how many rows should be displayed per page?\r\n<p>\r\n\r\n\r\n<b>Convert carriage returns?</b>\r\nDo you wish to convert the carriage returns in the resultant data to HTML breaks (<br>).\r\n<p>\r\n\r\n');
INSERT INTO international VALUES (71,'MailForm',1,'This wobject creates a simple form that will email an email address when it is filled out.\r\n<br><br>\r\n\r\n<b>Width</b><br>\r\nThe width of all fields in the form.  The default value is 45.\r\n<p>\r\n\r\n<b>From, To, Cc, Bcc, Subject</b><br>\r\nThese fields control how the email will look when sent, and who it is sent to.  You can give your site visitors the ability to modify some or all of these fields, but typically the only fields you will want the user to be able to modify are From and Subject.  Use the drop-down options by each field to choose whether or not the user can see or modify that field.<br>\r\n<br>\r\nYou may also choose to enter a WebGUI username or group in the To field, and the email will be sent to the corresponding user or group.\r\n<p>\r\n\r\n<b>Acknowledgement</b><br>\r\nThis message will be displayed to the user after they click \"Send\".\r\n<p>\r\n\r\n<b>Store Entries?</b><br>\r\nIf set to yes, when your mail form is submitted the entries will be saved to the database for later viewing.  The tool to view these entries is not yet available, but when it is you will be able to view all entries from your form in a centralized location.\r\n<p>\r\n\r\n<b>Proceed to add more fields?</b><br>\r\nLeave this checked if you want to add additional fields to your form directly after creating it.');
INSERT INTO international VALUES (72,'MailForm',1,'You may add as many additional fields to your Mail Form as you like.\r\n<br><br>\r\n\r\n<b>Field Name</b><br>\r\nThe name of this field.  It must be unique among all of the other fields on your form.\r\n<p>\r\n\r\n<b>Status</b><br>\r\nHidden fields will not be visible to the user, but will be sent in the email.<br>\r\nDisplayed fields can be seen by the user but not modified.<br>\r\nModifiable fields can be filled in by the user.<br>\r\nIf you choose Hidden or Displayed, be sure to fill in a Default Value.\r\n<p>\r\n\r\n<b>Type</b><br>\r\nChoose the type of form element for this field.  The following field types are supported:<br>\r\nURL: A textbox that will auto-format URL\'s entered.<br>\r\nTextbox: A standard textbox.<br>\r\nDate: A textbox field with a popup window to select a date.<br>\r\nYes/No: A set of yes/no radio buttons.<br>\r\nEmail Address: A textbox that requires the user to enter a valid email address.<br>\r\nTextarea: A simple textarea.<br>\r\nCheckbox: A single checkbox.<br>\r\nDrop-Down Box: A drop-down box. Use the Possible Values field to enter each option to be displayed in the box.  Enter one option per line.\r\n<p>\r\n\r\n<b>Possible Values</b><br>\r\nThis field is only used for the Drop-Down Box type.  Enter the values you wish to appear in your drop-down box, one per line.\r\n<p>\r\n\r\n<b>Default Value (optional)</b><br>\r\nEnter the default value (if any) for the field.  For Yes/No fields, enter \"yes\" to select \"Yes\" and \"no\" to select \"No\".\r\nFor Checkbox fields, enter \"checked\" to check the box.\r\n<p>\r\n\r\n<b>Proceed to add more fields?</b><br>\r\nLeave this checked if you want to add additional fields to your form directly after creating this field.\r\n<p>\r\n');
INSERT INTO international VALUES (625,'WebGUI',1,'<b>Name</b><br>\r\nThe label that this image will be referenced by to include it into pages.\r\n<p>\r\n\r\n<b>File</b><br>\r\nSelect a file from your local drive to upload to the server.\r\n<p>\r\n\r\n<b>Parameters</b><br>\r\nAdd any HTML &ltimg&rt; parameters that you wish to act as the defaults for this image.\r\n<p>\r\n\r\n<i>Example:</i><br>\r\nalign=\"right\"<br>\r\nalt=\"This is an image\"<br>\r\n');
INSERT INTO international VALUES (628,'WebGUI',1,'When you delete an image it will be removed from the server and cannot be recovered. Therefore, be sure that you really wish to delete the image before you confirm the delete.\r\n<p>\r\n');
INSERT INTO international VALUES (631,'WebGUI',1,'Using the built in image manager in WebGUI you can upload images to one central location for use anywhere else in the site with no need for any special software or knowledge.\r\nYou can also create image groups to help organize your images. To do so, simply click \"Add a new group.\"\r\n<p>\r\n\r\nTo place the images you\'ve uploaded use the ^I(); and ^i(); macros. More information on them can be found in the Using Macros help.\r\n\r\n<p>\r\n<i>Tip:</i> You can use the ^I(); macro (and therefore the images from the image manager) in places you may not have conisdered. For instance, you could place images in the titles of your wobjects. Or in wobjects like Link List and Site Map that use bullets, you could use image manager images as the bullets.\r\n<p>\r\n');
INSERT INTO international VALUES (633,'WebGUI',1,'Simply put, roots are pages with no parent. The first and most important root in WebGUI is the \"Home\" page. Many people will never add any additional roots, but a few power users will. Those power users will create new roots for many different reasons. Perhaps they\'ll create a staging area for content managers. Or maybe a hidden area for Admin tools. Or possibly even a new root just to place their search engine.\r\n<p>\r\n\r\n');
INSERT INTO international VALUES (636,'WebGUI',1,'To create a package follow these simple steps:\r\n\r\n<ol>\r\n<li> From the admin menu select \"Manage packages.\"\r\n</li>\r\n\r\n<li> Add a page and give it a name. The name of the page will be the name of the package.\r\n</li>\r\n\r\n<li> Go to the new page you created and start adding pages and wobjects. Any pages or wobjects you add will be created each time this package is deployed. \r\n</li>\r\n</ol>\r\n\r\n<b>Notes:</b><br>\r\nIn order to add, edit, or delete packages you must be in the Package Mangers group or in the Admins group.\r\n<br><br>\r\n\r\nIf you add content to any of the wobjects, that content will automatically be copied when the package is deployed.\r\n<br><br>\r\n\r\nPrivileges and styles assigned to pages in the package will not be copied when the package is deployed. Instead the pages will take the privileges and styles of the area to which they are deployed.\r\n<p>\r\n');
INSERT INTO international VALUES (635,'WebGUI',1,'Packages are groups of pages and wobjects that are predefined to be deployed together. A package manager may see the need to create a package several pages with a message board, an FAQ, and a Poll because that task is performed quite often. Packages are often defined to lessen the burden of repetitive tasks.\r\n<br><br>\r\nOne package that many people create is a Page/Article package. It is often the case that you want to add a page with an article on it for content. Instead of going through the steps of creating a page, going to the page, and then adding an article to the page, you may wish to simply create a package to do those steps all at once.');
INSERT INTO international VALUES (630,'WebGUI',1,'WebGUI has a small, but sturdy real-time search engine built-in. If you wish to use the internal search engine, you can use the ^?; macro, or by adding <i>?op=search</i> to the end of any URL, or feel free to build your own form to access it.\r\n<p>\r\nMany people need a search engine to index their WebGUI site, plus many others. Or they have more advanced needs than what WebGUI\'s search engine allows. In those cases we recommend <a href=\"http://www.mnogosearch.org/\">MnoGo Search</a> or <a href=\"http://www.htdig.org/\">ht://Dig</a>.\r\n<p>\r\n\r\n');
INSERT INTO international VALUES (611,'WebGUI',1,'<b>Company Name</b><br>\r\nThe name of your company. It will appear on all emails and anywhere you use the Company Name macro.\r\n<br><br>\r\n\r\n<b>Company Email Address</b><br>\r\nA general email address at your company. This is the address that all automated messages will come from. It can also be used via the WebGUI macro system.\r\n<br><br>\r\n\r\n<b>Company URL</b><br>\r\nThe primary URL of your company. This will appear on all automated emails sent from the WebGUI system. It is also available via the WebGUI macro system.\r\n');
INSERT INTO international VALUES (651,'WebGUI',1,'If you choose to empty your trash, any items contained in it will be lost forever. If you\'re unsure about a few items, it might be best to cut them to your clipboard before you empty the trash.\r\n<p>\r\n\r\n');
INSERT INTO international VALUES (627,'WebGUI',1,'Profiles are used to extend the information of a particular user. In some cases profiles are important to a site, in others they are not. The profiles system is completely extensible. You can add as much information to the users profile as you like.\r\n<p>\r\n\r\n');
INSERT INTO international VALUES (629,'WebGUI',1,'<b>Prevent Proxy Caching</b><br>\r\nSome companies have proxy servers that cause problems with WebGUI. If you\'re experiencing problems with WebGUI, and you have a proxy server, you may want to set this setting to <i>Yes</i>. Beware that WebGUI\'s URLs will not be as user-friendly after this feature is turned on.\r\n<p>\r\n\r\n<b>On Critical Error</b><br>\r\nWhat do you want WebGUI to do if a critical error occurs. It can be a security risk to show debugging information, but you may want to show it if you are in development.\r\n<p>\r\n\r\n');
INSERT INTO international VALUES (616,'WebGUI',1,'<b>Path to WebGUI Extras</b><br>\r\nThe web-path to the directory containing WebGUI images and javascript files.\r\n<br><br>\r\n\r\n<b>Maximum Attachment Size</b><br>\r\nThe maximum size of files allowed to be uploaded to this site. This applies to all wobjects that allow uploaded files and images (like Article and User Contributions). This size is measured in kilobytes.\r\n<br><br>\r\n\r\n<b>Thumbnail Size</b><br>\r\nThe size of the longest side of thumbnails. The thumbnail generation maintains the aspect ratio of the image. Therefore, if this value is set to 100, and you have an image that\'s 400 pixels wide and 200 pixels tall, the thumbnail will be 100 pixels wide and 50 pixels tall.\r\n<p>\r\n<i>Note:</i> Thumbnails are automatically generated as images are uploaded to the system.\r\n<p>\r\n\r\n<b>Web Attachment Path</b><br>\r\nThe web-path of the directory where attachments are to be stored.\r\n<br><br>\r\n\r\n<b>Server Attachment Path</b><br>\r\nThe local path of the directory where attachments are to be stored. (Perhaps /var/www/public/uploads) Be sure that the web server has the rights to write to that directory.\r\n');
INSERT INTO international VALUES (618,'WebGUI',1,'<b>Recover Password Message</b><br>\r\nThe message that gets sent to a user when they use the \"recover password\" function.\r\n<br><br>\r\n\r\n<b>SMTP Server</b><br>\r\nThis is the address of your local mail server. It is needed for all features that use the Internet email system (such as password recovery).\r\n<p>\r\nOptionally, if you are running a sendmail server on the same machine as WebGUI, you can also specify a path to your sendmail executable. On most Linux systems this can be found at \"/usr/lib/sendmail\".\r\n\r\n');
INSERT INTO international VALUES (626,'WebGUI',1,'Wobjects (fomerly known as Widgets) are the true power of WebGUI. Wobjects are tiny pluggable applications built to run under WebGUI. Message boards and polls are examples of wobjects.\r\n<p>\r\n\r\nTo add a wobject to a page, first go to that page, then select <i>Add Content...</i> from the upper left corner of your screen. Each wobject has it\'s own help so be sure to read the help if you\'re not sure how to use it.\r\n<p>\r\n\r\n\r\n<i>Style Sheets</i>: All wobjects have a style-sheet class and id attached to them. \r\n<p>\r\n\r\nThe style-sheet class is the word \"wobject\" plus the type of wobject it is. So for a poll the class would be \"wobjectPoll\". The class pertains to all wobjects of that type in the system. \r\n<p>\r\n\r\nThe style-sheet id is the word \"wobjectId\" plus the Wobject Id for that wobject instance. So if you had an Article with a Wobject Id of 94, then the id would be \"wobjectId94\".\r\n<p>\r\n\r\n');
INSERT INTO international VALUES (632,'WebGUI',1,'You can add wobjects by selecting from the <i>Add Content</i> pulldown menu. You can edit them by clicking on the \"Edit\" button that appears directly above an instance of a particular wobject.\r\n<p>\r\n\r\nAlmost all wobjects share some properties. Those properties are:\r\n<p>\r\n\r\n<b>Wobject ID</b><br>\r\nThis is the unique identifier WebGUI uses to keep track of this wobject instance. Normal users should never need to be concerned with the Wobject ID, but some advanced users may need to know it for things like SQL Reports.\r\n<p>\r\n\r\n\r\n<b>Title</b>\r\nThe title of the wobject. This is typically displayed at the top of each wobject.\r\n<p>\r\n\r\n<i>Note:</i> You should always specify a title even if you are going to turn it off (with the next property). This is because the title shows up in the trash and clipboard and you\'ll want to be able to distinguish which wobject is which.\r\n<p>\r\n\r\n\r\n<b>Display title?</b><br>\r\nDo you wish to display the title you specified? On some sites, displaying the title is not necessary.\r\n<p>\r\n\r\n\r\n<b>Process macros?</b><br>\r\nDo you wish to process macros in the content of this wobject? Sometimes you\'ll want to do this, but more often than not you\'ll want to say \"no\" to this question. By disabling the processing of macros on the wobjects that don\'t use them, you\'ll speed up your web server slightly.\r\n<p>\r\n\r\n\r\n<b>Template Position</b><br>\r\nTemplate positions range from 0 (zero) to any number. How many are available depends upon the Template associated with this page. The default template has only one template position, others may have more. By selecting a template position, you\'re specifying where this wobject should be placed within the template.\r\n<p>\r\n\r\n\r\n<b>Start Date</b><br>\r\nOn what date should this wobject become visible? Before this date, the wobject will only be displayed to Content Managers.\r\n<p>\r\n\r\n\r\n<b>End Date</b><br>\r\nOn what date should this wobject become invisible? After this date, the wobject will only be displayed to Content Managers.\r\n<p>\r\n\r\n\r\n<b>Description</b><br>\r\nA content area in which you can place as much content as you wish. For instance, even before an FAQ there is usually a paragraph describing what is contained in the FAQ.\r\n<p>\r\n\r\n');
INSERT INTO international VALUES (623,'WebGUI',1,'<a href=\"http://www.w3.org/Style/CSS/\">Cascading Style Sheets (CSS)</a> are a great way to manage the look and feel of any web site. They are used extensively in WebGUI.\r\n<p>\r\n\r\n\r\nIf you are unfamiliar with how to use CSS, <a href=\"http://www.plainblack.com/\">Plain Black Software</a> provides training classes on XHTML and CSS. Alternatively, Bradsoft makes an excellent CSS editor called <a href=\"http://www.bradsoft.com/topstyle/index.asp\">Top Style</a>.\r\n<p>\r\n\r\n\r\nThe following is a list of classes used to control the look of WebGUI:\r\n<p>\r\n\r\n\r\n<b>A</b><br>\r\nThe links throughout the style.\r\n<p>\r\n\r\n\r\n<b>BODY</b><br>\r\nThe default setup of all pages within a style.\r\n<p>\r\n\r\n\r\n<b>H1</b><br>\r\nThe headers on every page.\r\n<p>\r\n\r\n\r\n<b>.accountOptions</b><br>\r\nThe links that appear under the login and account update forms.\r\n<p>\r\n\r\n\r\n<b>.adminBar </b><br>\r\nThe bar that appears at the top of the page when you\'re in admin mode.\r\n<p>\r\n\r\n\r\n<b>.content</b><br>\r\nThe main content area on all pages of the style.\r\n<p>\r\n\r\n\r\n<b>.formDescription </b><br>\r\nThe tags on all forms next to the form elements. \r\n<p>\r\n\r\n\r\n<b>.formSubtext </b><br>\r\nThe tags below some form elements.\r\n<p>\r\n\r\n\r\n<b>.highlight </b><br>\r\nDenotes a highlighted item, such as which message you are viewing within a list.\r\n<p>\r\n\r\n\r\n<b>.horizontalMenu </b><br>\r\nThe horizontal menu (if you use a horizontal menu macro).\r\n<p>\r\n\r\n\r\n<b>.pagination </b><br>\r\nThe Previous and Next links on pages with pagination.\r\n<p>\r\n\r\n\r\n<b>.selectedMenuItem</b><br>\r\nUse this class to highlight the current page in any of the menu macros.\r\n<p>\r\n\r\n\r\n<b>.tableData </b><br>\r\nThe data rows on things like message boards and user contributions.\r\n<p>\r\n\r\n\r\n<b>.tableHeader </b><br>\r\nThe headings of columns on things like message boards and user contributions.\r\n<p>\r\n\r\n\r\n<b>.tableMenu </b><br>\r\nThe menu on things like message boards and user submissions.\r\n<p>\r\n\r\n\r\n<b>.verticalMenu </b><br>\r\nThe vertical menu (if you use a vertical menu macro).\r\n<p>\r\n\r\n\r\n<i><b>Note:</b></i> Some wobjects and macros have their own unique styles sheet classes, which are documented in their individual help files.\r\n<p>\r\n\r\n\r\n');
INSERT INTO international VALUES (622,'WebGUI',1,'See <i>Manage Group</i> for a description of grouping functions and the default groups.\r\n<p>\r\n\r\n<b>Group Name</b><br>\r\nA name for the group. It is best if the name is descriptive so you know what it is at a glance.\r\n<p>\r\n\r\n<b>Description</b><br>\r\nA longer description of the group so that other admins and content managers (or you if you forget) will know what the purpose of this group is.\r\n<p>\r\n\r\n<b>Expire After</b><br>\r\nThe amount of time that a user will belong to this group before s/he is expired (or removed) from it. This is very useful for membership sites where users have certain privileges for a specific period of time. Note that this can be overridden on a per-user basis.\r\n<p>\r\n\r\n<b>Karma Threshold</b><br>\r\nIf you\'ve enabled Karma, then you\'ll be able to set this value. Karma Threshold is the amount of karma a user must have to be considered part of this group.\r\n<p>\r\n');
INSERT INTO international VALUES (607,'WebGUI',1,'<b>Anonymous Registration</b><br>\r\nDo you wish visitors to your site to be able to register themselves?\r\n<br><br>\r\n\r\n<b>Run On Registration</b><br>\r\nIf there is a command line specified here, it will be executed each time a user registers anonymously.\r\n<p>\r\n\r\n<b>Alert on new user?</b><br>\r\nShould someone be alerted when a new user registers anonymously?\r\n<p>\r\n\r\n<b>Group To Alert On New User</b><br>\r\nWhat group should be alerted when a new user registers?\r\n<p>\r\n\r\n<b>Enable Karma?</b><br>\r\nShould karma be enabled?\r\n<p>\r\n\r\n<b>Karma Per Login</b><br>\r\nThe amount of karma a user should be given when they log in. This only takes affect if karma is enabled.\r\n<p>\r\n\r\n<b>Session Timeout</b><br>\r\nThe amount of time that a user session remains active (before needing to log in again). This timeout is reset each time a user views a page. Therefore if you set the timeout for 8 hours, a user would have to log in again if s/he hadn\'t visited the site for 8 hours.\r\n<p>\r\n\r\n<b>Authentication Method (default)</b><br>\r\nWhat should the default authentication method be for new accounts that are created? The two available options are WebGUI and LDAP. WebGUI authentication means that the users will authenticate against the username and password stored in the WebGUI database. LDAP authentication means that users will authenticate against an external LDAP server.\r\n<br><br>\r\n<i>Note:</i> Authentication settings can be customized on a per user basis.\r\n<br><br>\r\n\r\n<b>Username Binding</b><br>\r\nBind the WebGUI username to the LDAP Identity. This requires the user to have the same username in WebGUI as they specified during the Anonymous Registration process. It also means that they won\'t be able to change their username later. This only in effect if the user is authenticating against LDAP.\r\n<br><br>\r\n\r\n<b>LDAP URL (default)</b><br>\r\nThe default url to your LDAP server. The LDAP URL takes the form of <b>ldap://[server]:[port]/[base DN]</b>. Example: ldap://ldap.mycompany.com:389/o=MyCompany.\r\n<br><br>\r\n\r\n<b>LDAP Identity</b><br>\r\nThe LDAP Identity is the unique identifier in the LDAP server that the user will be identified against. Often this field is <b>shortname</b>, which takes the form of first initial + last name. Example: jdoe. Therefore if you specify the LDAP identity to be <i>shortname</i> then Jon Doe would enter <i>jdoe</i> during the registration process.\r\n<br><br>\r\n\r\n<b>LDAP Identity Name</b><br>\r\nThe label used to describe the LDAP Identity to the user. For instance, some companies use an LDAP server for their proxy server users to authenticate against. In the documentation or training already provided to their users, the LDAP identity is known as their <i>Web Username</i></b><i>. So you could enter that label here for consitency.\r\n<br><br>\r\n\r\n<b>LDAP Password Name</b><br>\r\nJust as the LDAP Identity Name is a label, so is the LDAP Password Name. Use this label as you would LDAP Identity Name.\r\n<p>\r\n\r\n');
INSERT INTO international VALUES (620,'WebGUI',1,'As the function suggests you\'ll be deleting a group and removing all users from the group. Be careful not to orphan users from pages they should have access to by deleting a group that is in use.\r\n<p>\r\n\r\nAs with any delete operation, you are prompted to be sure you wish to proceed with the delete. If you answer yes, the delete will proceed and there is no recovery possible. If you answer no you\'ll be returned to the prior screen.');
INSERT INTO international VALUES (621,'WebGUI',1,'Styles are WebGUI macro enabled. See <i>Using Macros</i> for more information.\r\n<p>\r\n\r\n\r\n<b>Style Name</b><br>\r\nA unique name to describe what this style looks like at a glance. The name has no effect on the actual look of the style.\r\n<p>\r\n\r\n\r\n<b>Body</b><br>\r\nThe body is quite literally the HTML body of your site. It defines how the page navigation will be laid out and many other things like logo, copyright, etc. At bare minimum a body must consist of a few things, the ^AdminBar; macro and the ^-; (seperator) macro. The ^AdminBar; macro tells WebGUI where to display admin functions. The ^-; (splitter) macro tells WebGUI where to put the content of your page.\r\n<p>\r\n\r\n\r\nIf you are in need of assistance for creating a look for your site, or if you need help cutting apart your design, <a href=\"http://www.plainblack.com/\">Plain Black Software</a> provides support services for a small fee.\r\n<p>\r\n\r\n\r\nMany people will add WebGUI macros to their body for automated navigation, and other features.\r\n<p>\r\n\r\n\r\n<b>Style Sheet</b><br>\r\nPlace your style sheet entries here. Style sheets are used to control colors, sizes, and other properties of the elements on your site. See <i>Using Style Sheets</i> for more information.\r\n<p>\r\n\r\n\r\n<i>Advanced Users:</i> for greater performance create your stylesheet on the file system (call it something like webgui.css) and add an entry like this to this area: \r\n<link href=\"/webgui.css\" rel=\"stylesheet\" rev=\"stylesheet\" type=\"text/css\">\r\n<p>\r\n\r\n');
INSERT INTO international VALUES (619,'WebGUI',1,'This function permanently deletes the selected wobject from a page. If you are unsure whether you wish to delete this content you may be better served to cut the content to the clipboard until you are certain you wish to delete it.\r\n<p>\r\n\r\n\r\nAs with any delete operation, you are prompted to be sure you wish to proceed with the delete. If you answer yes, the delete will proceed and there is no recovery possible. If you answer no you\'ll be returned to the prior screen.\r\n<p>\r\n\r\n');
INSERT INTO international VALUES (617,'WebGUI',1,'Settings are items that allow you to adjust WebGUI to your particular needs.\r\n<p>\r\n\r\n\r\n<b>Edit Company Information</b><br>\r\nInformation specific about the company or individual who controls this installation of WebGUI.\r\n<p>\r\n\r\n\r\n<b>Edit Content Settings</b><br>\r\nSettings related to content and content management.\r\n<p>\r\n\r\n\r\n<b>Edit Mail Settings</b><br>\r\nSettings concerning email and related functions.\r\n<p>\r\n\r\n\r\n<b>Edit Miscellaneous Settings</b><br>\r\nAnything we couldn\'t find a place for.\r\n<p>\r\n\r\n\r\n<b>Edit Profile Settings</b><br>\r\nDefine what user profiles look like and what the users have the ability to edit.\r\n<p>\r\n\r\n\r\n<b>Edit User Settings</b><br>\r\nSettings relating to users (beyond profile information), like authentication information, and registration options.\r\n<p>\r\n\r\n\r\n');
INSERT INTO international VALUES (615,'WebGUI',1,'Groups are used to subdivide privileges and responsibilities within the WebGUI system. For instance, you may be building a site for a classroom situation. In that case you might set up a different group for each class that you teach. You would then apply those groups to the pages that are designed for each class.\r\n<p>\r\n\r\nThere are several groups built into WebGUI. They are as follows:\r\n<p>\r\n\r\n<b>Admins</b><br>\r\nAdmins are users who have unlimited privileges within WebGUI. A user should only be added to the admin group if they oversee the system. Usually only one to three people will be added to this group.\r\n<p>\r\n\r\n<b>Content Managers</b><br>\r\nContent managers are users who have privileges to add, edit, and delete content from various areas on the site. The content managers group should not be used to control individual content areas within the site, but to determine whether a user can edit content at all. You should set up additional groups to separate content areas on the site.\r\n<p>\r\n\r\n<b>Everyone</b><br>\r\nEveryone is a magic group in that no one is ever physically inserted into it, but yet all members of the site are part of it. If you want to open up your site to both visitors and registered users, use this group to do it.\r\n<p>\r\n\r\n<b>Package Managers</b><br>\r\nUsers that have privileges to add, edit, and delete packages of wobjects and pages to deploy.\r\n<p>\r\n\r\n<b>Registered Users</b><br>\r\nWhen users are added to the system they are put into the registered users group. A user should only be removed from this group if their account is deleted or if you wish to punish a troublemaker.\r\n<p>\r\n\r\n<b>Style Managers</b><br>\r\nUsers that have privileges to edit styles for this site. These privileges do not allow the user to assign privileges to a page, just define them to be used.\r\n<p>\r\n\r\n<b>Template Managers</b><br>\r\nUsers that have privileges to edit templates for this site.\r\n<p>\r\n\r\n<b>Visitors</b><br>\r\nVisitors are users who are not logged in using an account on the system. Also, if you wish to punish a registered user you could remove him/her from the Registered Users group and insert him/her into the Visitors group.\r\n<p>\r\n');
INSERT INTO international VALUES (613,'WebGUI',1,'Users are the accounts in the system that are given rights to do certain things. There are two default users built into the system: Admin and Visitor.\r\n</i></p><p><i>\r\n\r\n<b>Admin</b><br>\r\nAdmin is exactly what you\'d expect. It is a user with unlimited rights in the WebGUI environment. If it can be done, this user has the rights to do it.\r\n</i></p><p><i>\r\n\r\n<b>Visitor</b><br>\r\nVisitor is exactly the opposite of Admin. Visitor has no rights what-so-ever. By default any user who is not logged in is seen as the user Visitor.\r\n</i></p><p><i>\r\n\r\n<b>Add a new user.</b><br>\r\nClick on this to go to the add user screen.\r\n</i></p><p><i>\r\n\r\n<b>Search</b><br>\r\nYou can search users based on username and email address. You can do partial searches too if you like.');
INSERT INTO international VALUES (614,'WebGUI',1,'Styles are used to manage the look and feel of your WebGUI pages. With WebGUI, you can have an unlimited number of styles, so your site can take on as many looks as you like. You could have some pages that look like your company\'s brochure, and some pages that look like Yahoo!®. You could even have some pages that look like pages in a book. Using style management, you have ultimate control over all your designs.\r\n<p>\r\n\r\nThere are several styles built into WebGUI. The first of these are used by WebGUI can should not be edited or deleted. The last few are simply example styles and may be edited or deleted as you please.\r\n<p>\r\n\r\n\r\n<b>Clipboard</b><br>\r\nThis style is used by the clipboard system.\r\n<p>\r\n\r\n\r\n<b>Fail Safe</b><br>\r\nWhen you delete a style that is still in use on some pages, the Fail Safe style will be applied to those pages. This style has a white background and simple navigation.\r\n<p>\r\n\r\n\r\n<b>Make Page Printable</b><br>\r\nThis style is used if you place an <b>^r;</b> macro on your pages and the user clicks on it. This style allows you to put a simple logo and copyright message on your printable pages.\r\n<p>\r\n\r\n\r\n<b>Packages</b><br>\r\nThis style is used by the package management system.\r\n<p>\r\n\r\n\r\n<b>Trash</b><br>\r\nThis style is used by the trash system.\r\n<p>\r\n\r\n\r\n<hr>\r\n\r\n<b>Demo Style</b><br>\r\nThis is a sample design taken from a templates site (www.freewebtemplates.com).\r\n<p>\r\n\r\n\r\n<b>Plain Black Software (black) & (white)</b><br>\r\nThese designs are used on the Plain Black site.\r\n<p>\r\n\r\n\r\n<b>Yahoo!®</b><br>\r\nThis is the design of the Yahoo!® site. (Used without permission.)\r\n<p>\r\n\r\n\r\n<b>WebGUI</b><br>\r\nThis is a simple design featuring WebGUI logos.\r\n<p>\r\n\r\n<b>WebGUI 4</b><br>\r\nThis style was added to WebGUI as of version 4.0.0. It is now the default style and has superceded the \"WebGUI\" style.\r\n<p>\r\n\r\n');
INSERT INTO international VALUES (612,'WebGUI',1,'There is no need to ever actually delete a user. If you are concerned with locking out a user, then simply change their password. If you truely wish to delete a user, then please keep in mind that there are consequences. If you delete a user any content that they added to the site via wobjects (like message boards and user contributions) will remain on the site. However, if another user tries to visit the deleted user\'s profile they will get an error message. Also if the user ever is welcomed back to the site, there is no way to give him/her access to his/her old content items except by re-adding the user to the users table manually.\r\n<p>\r\n\r\n\r\nAs with any delete operation, you are prompted to be sure you wish to proceed with the delete. If you answer yes, the delete will proceed and there is no recovery possible. If you answer no you\'ll be returned to the prior screen.\r\n<p>\r\n\r\n');
INSERT INTO international VALUES (637,'WebGUI',1,'<b>First Name</b><br>\r\nThe given name of this user.\r\n<p>\r\n\r\n<b>Middle Name</b><br>\r\nThe middle name of this user.\r\n<p>\r\n\r\n<b>Last Name</b><br>\r\nThe surname (or family name) of this user.\r\n<p>\r\n\r\n<b>Email Address</b><br>\r\nThe user\'s email address. This must only be specified if the user will partake in functions that require email.\r\n<p>\r\n\r\n<b>ICQ UIN</b><br>\r\nThe <a href=\"http://www.icq.com/\">ICQ</a> UIN is the \"User ID Number\" on the ICQ network. ICQ is a very popular instant messaging platform.\r\n<p>\r\n\r\n<b>AIM Id</b><br>\r\nThe account id for the <a href=\"http://www.aim.com/\">AOL Instant Messenger</a> system.\r\n<p>\r\n\r\n<b>MSN Messenger Id</b><br>\r\nThe account id for the <a href=\"http://messenger.msn.com/\">Microsoft Network Instant Messenger</b> system.\r\n<p>\r\n\r\n<b>Yahoo! Messenger Id</b><br>\r\nThe account id for the <a href=\"http://messenger.yahoo.com/\">Yahoo! Instant Messenger</a> system.\r\n<p>\r\n\r\n<b>Cell Phone</b><br>\r\nThis user\'s cellular telephone number.\r\n<p>\r\n\r\n<b>Pager</b><br>\r\nThis user\'s pager telephone number.\r\n<p>\r\n\r\n<b>Email To Pager Gateway</b><br>\r\nThis user\'s text pager email address.\r\n<p>\r\n\r\n<b>Home Information</b><br>\r\nThe postal (or street) address for this user\'s home.\r\n<p>\r\n\r\n<b>Work Information</b><br>\r\nThe postal (or street) address for this user\'s company.\r\n<p>\r\n\r\n<b>Gender</b><br>\r\nThis user\'s sex.\r\n<p>\r\n\r\n<b>Birth Date</b><br>\r\nThis user\'s date of birth.\r\n\r\n<b>Language</b><br>\r\nWhat language should be used to display system related messages.\r\n<p>\r\n\r\n<b>Time Offset</b><br>\r\nA number of hours (plus or minus) different this user\'s time is from the server. This is used to adjust for time zones.\r\n<p>\r\n\r\n<b>First Day Of Week</b><br>\r\nThe first day of the week on this user\'s local calendar. For instance, in the United States the first day of the week is Sunday, but in many places in Europe, the first day of the week is Monday.\r\n<p>\r\n\r\n<b>Date Format</b><br>\r\nWhat format should dates on this site appear in?\r\n<p>\r\n\r\n<b>Time Format</b><br>\r\nWhat format should times on this site appear in? \r\n<p>\r\n\r\n<b>Discussion Layout</b><br>\r\nShould discussions be laid out flat or threaded? Flat puts all replies on one page in the order they were created. Threaded shows the heirarchical list of replies as they were created.\r\n<p>\r\n\r\n<b>Inbox Notifications</b><br>\r\nHow should this user be notified when they get a new WebGUI message?\r\n\r\n');
INSERT INTO international VALUES (610,'WebGUI',1,'See <b>Manage Users</b> for additional details.\r\n<p>\r\n\r\n<b>Username</b><br>\r\nUsername is a unique identifier for a user. Sometimes called a handle, it is also how the user will be known on the site. (<i>Note:</i> Administrators have unlimited power in the WebGUI system. This also means they are capable of breaking the system. If you rename or create a user, be careful not to use a username already in existance.)\r\n<p>\r\n\r\n\r\n<b>Password</b><br>\r\nA password is used to ensure that the user is who s/he says s/he is.\r\n<p>\r\n\r\n\r\n<b>Authentication Method</b><br>\r\nSee <i>Edit Settings</i> for details.\r\n<p>\r\n\r\n\r\n<b>LDAP URL</b><br>\r\nSee <i>Edit Settings</i> for details.\r\n<p>\r\n\r\n\r\n<b>Connect DN</b><br>\r\nThe Connect DN is the <b>cn</b> (or common name) of a given user in your LDAP database. It should be specified as <b>cn=John Doe</b>. This is, in effect, the username that will be used to authenticate this user against your LDAP server.\r\n<p>\r\n\r\n\r\n');
INSERT INTO international VALUES (608,'WebGUI',1,'Deleting a page can create a big mess if you are uncertain about what you are doing. When you delete a page you are also deleting the content it contains, all sub-pages connected to this page, and all the content they contain. Be certain that you have already moved all the content you wish to keep before you delete a page.\r\n<p>\r\n\r\nAs with any delete operation, you are prompted to be sure you wish to proceed with the delete. If you answer yes, the delete will proceed and there is no recovery possible. If you answer no you\'ll be returned to the prior screen.\r\n<p>\r\n');
INSERT INTO international VALUES (609,'WebGUI',1,'When you delete a style all pages using that style will be reverted to the fail safe (default) style. To ensure uninterrupted viewing, you should be sure that no pages are using a style before you delete it.\r\n<p>\r\n\r\n\r\nAs with any delete operation, you are prompted to be sure you wish to proceed with the delete. If you answer yes, the delete will proceed and there is no recovery possible. If you answer no you\'ll be returned to the prior screen.\r\n<p>\r\n\r\n');
INSERT INTO international VALUES (606,'WebGUI',1,'Think of pages as containers for content. For instance, if you want to write a letter to the editor of your favorite magazine you\'d get out a notepad (or open a word processor) and start filling it with your thoughts. The same is true with WebGUI. Create a page, then add your content to the page.\r\n<p>\r\n\r\n<b>Title</b><br>\r\nThe title of the page is what your users will use to navigate through the site. Titles should be descriptive, but not very long.\r\n<p>\r\n\r\n\r\n<b>Menu Title</b><br>\r\nA shorter or altered title to appear in navigation. If left blank this will default to <i>Title</i>.\r\n<p>\r\n\r\n<b>Page URL</b><br>\r\nWhen you create a page a URL for the page is generated based on the page title. If you are unhappy with the URL that was chosen, you can change it here.\r\n<p>\r\n\r\n<b>Redirect URL</b><br>\r\nWhen this page is visited, the user will be redirected to the URL specified here. In order to edit this page in the future, you\'ll have to access it from the \"Manage page tree.\" menu under \"Administrative functions...\"\r\n<p>\r\n\r\n<b>Template</b><br>\r\nBy default, WebGUI has one big content area to place wobjects. However, by specifying a template other than the default you can sub-divide the content area into several sections.\r\n<p>\r\n\r\n<b>Synopsis</b><br>\r\nA short description of a page. It is used to populate default descriptive meta tags as well as to provide descriptions on Site Maps.\r\n<p>\r\n\r\n<b>Meta Tags</b><br>\r\nMeta tags are used by some search engines to associate key words to a particular page. There is a great site called <a href=\"http://www.metatagbuilder.com/\">Meta Tag Builder</a> that will help you build meta tags if you\'ve never done it before.\r\n<p>\r\n\r\n<i>Advanced Users:</i> If you have other things (like JavaScript) you usually put in the  area of your pages, you may put them here as well.\r\n<p>\r\n\r\n<b>Use default meta tags?</b><br>\r\nIf you don\'t wish to specify meta tags yourself, WebGUI can generate meta tags based on the page title and your company\'s name. Check this box to enable the WebGUI-generated meta tags.\r\n<p>\r\n\r\n\r\n<b>Style</b><br>\r\nBy default, when you create a page, it inherits a few traits from its parent. One of those traits is style. Choose from the list of styles if you would like to change the appearance of this page. See <i>Add Style</i> for more details.\r\n<p>\r\n\r\nIf you select \"Yes\" below the style pull-down menu, all of the pages below this page will take on the style you\'ve chosen for this page.\r\n<p>\r\n\r\n<b>Start Date</b><br>\r\nThe date when users may begin viewing this page. Note that before this date only content managers with the rights to edit this page will see it.\r\n<p>\r\n\r\n<b>End Date</b><br>\r\nThe date when users will stop viewing this page. Note that after this date only content managers with the rights to edit this page will see it.\r\n<p>\r\n\r\n\r\n<b>Owner</b><br>\r\nThe owner of a page is usually the person who created the page.\r\n<p>\r\n\r\n<b>Owner can view?</b><br>\r\nCan the owner view the page or not?\r\n<p>\r\n\r\n<b>Owner can edit?</b><br>\r\nCan the owner edit the page or not? Be careful, if you decide that the owner cannot edit the page and you do not belong to the page group, then you\'ll lose the ability to edit this page.\r\n<p>\r\n\r\n<b>Group</b><br>\r\nA group is assigned to every page for additional privilege control. Pick a group from the pull-down menu.\r\n<p>\r\n\r\n<b>Group can view?</b><br>\r\nCan members of this group view this page?\r\n<p>\r\n\r\n<b>Group can edit?</b><br>\r\nCan members of this group edit this page?\r\n<p>\r\n\r\n<b>Anybody can view?</b><br>\r\nCan any visitor or member regardless of the group and owner view this page?\r\n<p>\r\n\r\n<b>Anybody can edit?</b><br>\r\nCan any visitor or member regardless of the group and owner edit this page?\r\n<p>\r\n\r\nYou can optionally recursively give these privileges to all pages under this page.\r\n<p>\r\n');
INSERT INTO international VALUES (634,'WebGUI',1,'<b>Default Home Page</b><br>\r\nSome really small sites don\'t have a home page, but instead like to use one of their internal pages like \"About Us\" or \"Company Information\" as their home page. For that reason, you can set the default page of your site to any page in the site. That page will be the one people go to if they type in just your URL http://www.mywebguisite.com, or if they click on the Home link generated by the ^H; macro.\r\n<p>\r\n\r\n<b>Not Found Page</b><br>\r\nIf a page that a user requests is not found in the system, the user can be redirected to the home page or to an error page where they can attempt to find what they were looking for. You decide which is better for your users.\r\n<p>\r\n\r\n<b>Document Type Declaration</b><br>\r\nThese days it is very common to have a wide array of browsers accessing your site, including automated browsers like search engine spiders. Many of those browsers want to know what kind of content you are serving. The doctype tag allows you to specify that. By default WebGUI generates HTML 4.0 compliant content.\r\n<p>\r\n\r\n<b>Add edit stamp to posts?</b><br>\r\nTypically if a user edits a post on a message board, a stamp is added to that post to identify who made the edit, and at what time. On some sites that information is not necessary, therefore you can turn it off here.\r\n<p>\r\n\r\n<b>Filter Contributed HTML</b><br>\r\nEspecially when running a public site where anybody can post to your message boards or user submission systems, it is often a good idea to filter their content for malicious code that can harm the viewing experience of your visitors; And in some circumstances, it can even cause security problems. Use this setting to select the level of filtering you wish to apply.\r\n<p>\r\n\r\n<b>Maximum Attachment Size</b><br>\r\nThe size (in kilobytes) of the maximum allowable attachment to be uploaded to your system.\r\n<p>\r\n\r\n<b>Max Image Size</b><br>\r\nIf images are uploaded to your system that are bigger than the max image size, then they will be resized to the max image size. The max image size is measured in pixels and will use the size of the longest side of the image to determine if the limit has been reached.\r\n<p>\r\n\r\n<b>Thumbnail Size</b><br>\r\nWhen images are uploaded to your system, they will automatically have thumbnails generated at the size specified here. Thumbnail size is measured in pixels.\r\n<p>\r\n\r\n<b>Text Area Rows</b><br>\r\nSome sites wish to control the size of the forms that WebGUI generates. With this setting you can specify how many rows of characters will be displayed in textareas on the site.\r\n<p>\r\n\r\n<b>Text Area Columns</b><br>\r\nSome sites wish to control the size of the forms that WebGUI generates. With this setting you can specify how many columns of characters will be displayed in textareas on the site.\r\n<p>\r\n\r\n<b>Text Box Size</b><br>\r\nSome sites wish to control the size of the forms that WebGUI generates. With this setting you can specify how characters can be displayed at once in text boxes on the site.\r\n<p>\r\n\r\n<b>Editor To Use</b><br>\r\nWebGUI has a very sophisticated Rich Editor that allows users to fomat content as though they were in Microsoft Word® or some other word processor. To use that functionality, select \"Built-In Editor\". Sometimes web sites have the need for even more complex rich editors for things like Spell Check. For that reason you can install an 3rd party editor called <a href=\"http://www.realobjects.de/\"><i>Real Objects Edit-On Pro®</i></a> rich text editor. After you\'ve installed it change this option. If you need detailed instructions on how to integrate <i>Edit-On Pro®)</i>, you can find them in <a href=\"http://www.plainblack.com/ruling_webgui\"><i>Ruling WebGUI</i></a>.\r\n<p>\r\n');
INSERT INTO international VALUES (638,'WebGUI',1,'Templates are used to affect how pages are laid out in WebGUI. For instance, most sites these days have more than just a menu and one big text area. Many of them have three or four columns preceeded by several headers and/or banner areas. WebGUI accomodates complex layouts through the use of Templates. There are several templates that come with WebGUI to make life easier for you, but you can create as many as you\'d like.\r\n<p>\r\n\r\n');
INSERT INTO international VALUES (639,'WebGUI',1,'<b>Template Name</b><br>\r\nGive this template a descriptive name so that you\'ll know what it is when you\'re applying the template to a page.\r\n<p>\r\n\r\n\r\n<b>Template</b><br>\r\nCreate your template by placing the special macros ^0; ^1; ^2;  and so on in your template to represent the different content areas. Typically this is done by using a table to position the content. Be sure to take a look at the templates that come with WebGUI for ideas.\r\n<p>\r\n\r\n');
INSERT INTO international VALUES (640,'WebGUI',1,'It is not a good idea to delete templates as you never know what kind of adverse affect it may have on your site (some pages may still be using the template). If you should choose to delete a template, all the pages still using the template will be set to the \"Default\" template.\r\n<p>\r\n\r\n');
INSERT INTO international VALUES (624,'WebGUI',1,'WebGUI macros are used to create dynamic content within otherwise static content. For instance, you may wish to show which user is logged in on every page, or you may wish to have a dynamically built menu or crumb trail. \r\n<p>\r\n\r\nMacros always begin with a carat (^) and follow with at least one other character and ended with w semicolon (;). Some macros can be extended/configured by taking the format of ^<i>x</i>(\"<b>config text</b>\");. The following is a description of all the macros in the WebGUI system.\r\n<p>\r\n\r\n<b>^a; or ^a(); - My Account Link</b><br>\r\nA link to your account information. In addition you can change the link text by creating a macro like this <b>^a(\"Account Info\");</b>. \r\n<p>\r\n\r\n<i>Notes:</i> You can also use the special case ^a(linkonly); to return only the URL to the account page and nothing more. Also, the .myAccountLink style sheet class is tied to this macro.\r\n<p>\r\n\r\n<b>^AdminBar;</b><br>\r\nPlaces the administrative tool bar on the page. This is a required element in the \"body\" segment of the Style Manager.\r\n<p>\r\n\r\n<b>^AdminText();</b><br>\r\nDisplays a small text message to a user who is in admin mode. Example: ^AdminText(\"You are in admin mode!\");\r\n<p>\r\n\r\n<b>^AdminToggle;</b><br>\r\nPlaces a link on the page which is only visible to content managers and adminstrators. The link toggles on/off admin mode.\r\n<p>\r\n\r\n<b>^C; or ^C(); - Crumb Trail</b><br>\r\nA dynamically generated crumb trail to the current page. You can optionally specify a delimeter to be used between page names by using ^C(::);. The default delimeter is >.\r\n<p>\r\n\r\n<i>Note:</i> The .crumbTrail style sheet class is tied to this macro.\r\n<p>\r\n\r\n<b>^c; - Company Name</b><br>\r\nThe name of your company specified in the settings by your Administrator.\r\n<p>\r\n\r\n\r\n<b>^D; or ^D(); - Date</b><br>\r\nThe current date and time.\r\n<p>\r\n\r\nYou can configure the date by using date formatting symbols. For instance, if you created a macro like this <b>^D(\"%c %D, %y\");</b> it would output <b>September 26, 2001</b>. The following are the available date formatting symbols:\r\n<p>\r\n\r\n<table><tbody><tr><td>%%</td><td>%</td></tr><tr><td>%y</td><td>4 digit year</td></tr><tr><td>%Y</td><td>2 digit year</td></tr><tr><td>%m</td><td>2 digit month</td></tr><tr><td>%M</td><td>variable digit month</td></tr><tr><td>%c</td><td>month name</td></tr><tr><td>%d</td><td>2 digit day of month</td></tr><tr><td>%D</td><td>variable digit day of month</td></tr><tr><td>%w</td><td>day of week name</td></tr><tr><td>%h</td><td>2 digit base 12 hour</td></tr><tr><td>%H</td><td>variable digit base 12 hour</td></tr><tr><td>%j</td><td>2 digit base 24 hour</td></tr><tr><td>%J</td><td>variable digit base 24 hour</td></tr><tr><td>%p</td><td>lower case am/pm</td></tr><tr><td>%P</td><td>upper case AM/PM</td></tr><tr><td>%z</td><td>user preference date format</td></tr><tr><td>%Z</td><td>user preference time format</td></tr></tbody></table>\r\n<p>\r\n\r\n\r\n<b>^e; - Company Email Address</b><br>\r\nThe email address for your company specified in the settings by your Administrator.\r\n<p>\r\n\r\n<b>^Env()</b><br>\r\nCan be used to display a web server environment variable on a page. The environment variables available on each server are different, but you can find out which ones your web server has by going to: http://www.yourwebguisite.com/env.pl\r\n<p>\r\n\r\nThe macro should be specified like this ^Env(\"REMOTE_ADDR\");\r\n<p>\r\n\r\n<b>^Execute();</b><br>\r\nAllows a content manager or administrator to execute an external program. Takes the format of <b>^Execute(\"/this/file.sh\");</b>.\r\n<p>\r\n\r\n\r\n<b>^Extras;</b><br>\r\nReturns the path to the WebGUI \"extras\" folder, which contains things like WebGUI icons.\r\n<p>\r\n\r\n\r\n<b>^FlexMenu;</b><br>\r\nThis menu macro creates a top-level menu that expands as the user selects each menu item.\r\n<p>\r\n\r\n<b>^FormParam();</b><br>\r\nThis macro is mainly used in generating dynamic queries in SQL Reports. Using this macro you can pull the value of any form field simply by specifing the name of the form field, like this: ^FormParam(\"phoneNumber\");\r\n<p>\r\n\r\n<b>^GroupText();</b><br>\r\nDisplays a small text message to the user if they belong to the specified group. Example: ^GroupText(\"Visitors\",\"You need an account to do anything cool on this site!\");\r\n<p>\r\n\r\n\r\n<b>^H; or ^H(); - Home Link</b><br>\r\nA link to the home page of this site.  In addition you can change the link text by creating a macro like this <b>^H(\"Go Home\");</b>.\r\n<p>\r\n\r\n<i>Notes:</i> You can also use the special case ^H(linkonly); to return only the URL to the home page and nothing more. Also, the .homeLink style sheet class is tied to this macro.\r\n<p>\r\n\r\n<b>^I(); - Image Manager Image with Tag</b><br>\r\nThis macro returns an image tag with the parameters for an image defined in the image manager. Specify the name of the image using a tag like this <b>^I(\"imageName\")</b>;.\r\n<p>\r\n\r\n<b>^i(); - Image Manager Image Path</b><br>\r\nThis macro returns the path of an image uploaded using the Image Manager. Specify the name of the image using a tag like this <b>^i(\"imageName\");</b>.\r\n<p>\r\n\r\n<b>^Include();</b><br>\r\nAllows a content manager or administrator to include a file from the local filesystem. Takes the format of <b>^Include(\"/this/file.html\")</b>;\r\n<p>\r\n\r\n<b>^L; or ^L(); - Login</b><br>\r\nA small login form. You can also configure this macro. You can set the width of the login box like this ^L(20);. You can also set the message displayed after the user is logged in like this ^L(20,Hi ^a(^@;);. Click %here% if you wanna log out!)\r\n<p>\r\n\r\n<i>Note:</i> The .loginBox style sheet class is tied to this macro.\r\n<p>\r\n\r\n<b>^M; or ^M(); - Current Menu (Vertical)</b><br>\r\nA vertical menu containing the sub-pages at the current level. In addition, you may configure this macro by specifying how many levels deep the menu should go. By default it will show only the first level. To go three levels deep create a macro like this <b>^M(3);</b>. If you set the macro to \"0\" it will track the entire site tree.\r\n<p>\r\n\r\n<b>^m; - Current Menu (Horizontal)</b><br>\r\nA horizontal menu containing the sub-pages at the current level. You can optionally specify a delimeter to be used between page names by using ^m(:--:);. The default delimeter is ·.\r\n<p>\r\n\r\n<b>^P; or ^P(); - Previous Menu (Vertical)</b><br>\r\nA vertical menu containing the sub-pages at the previous level. In addition, you may configure this macro by specifying how many levels deep the menu should go. By default it will show only the first level. To go three levels deep create a macro like this <b>^P(3);</b>. If you set the macro to \"0\" it will track the entire site tree.\r\n<p>\r\n\r\n<b>^p; - Previous Menu (Horizontal)</b><br>\r\nA horizontal menu containing the sub-pages at the previous level. You can optionally specify a delimeter to be used between page names by using ^p(:--:);. The default delimeter is ·.\r\n<p>\r\n\r\n<b>^Page();</b><br>\r\nThis can be used to retrieve information about the current page. For instance it could be used to get the page URL like this ^Page(\"urlizedTitle\"); or to get the menu title like this ^Page(\"menuTitle\");.\r\n<p>\r\n\r\n<b>^PageTitle;</b><br>\r\nDisplays the title of the current page.\r\n<p>\r\n\r\n<i>Note:</i> If you begin using admin functions or the indepth functions of any wobject, the page title will become a link that will quickly bring you back to the page.\r\n<p>\r\n\r\n<b>^r; or ^r(); - Make Page Printable</b><br>\r\nCreates a link to remove the style from a page to make it printable.  In addition, you can change the link text by creating a macro like this <b>^r(\"Print Me!\");</b>.\r\n<p>\r\n\r\nBy default, when this link is clicked, the current page\'s style is replaced with the \"Make Page Printable\" style in the Style Manager. However, that can be overridden by specifying the name of another style as the second parameter, like this: ^r(\"Print!\",\"WebGUI\");\r\n<p>\r\n\r\n<i>Notes:</i> You can also use the special case ^r(linkonly); to return only the URL to the make printable page and nothing more. Also, the .makePrintableLink style sheet class is tied to this macro.\r\n<p>\r\n\r\n<b>^rootmenu; or ^rootmenu(); (Horizontal)</b><br>\r\nCreates a horizontal menu of the various roots on your system (except for the WebGUI system roots). You can optionally specify a menu delimiter like this: ^rootmenu(|);\r\n<p>\r\n\r\n\r\n<b>^RootTitle;</b><br>\r\nReturns the title of the root of the current page. For instance, the main root in WebGUI is the \"Home\" page. Many advanced sites have many roots and thus need a way to display to the user which root they are in.\r\n<p>\r\n\r\n<b>^S(); - Specific SubMenu (Vertical)</b><br>\r\nThis macro allows you to get the submenu of any page, starting with the page you specified. For instance, you could get the home page submenu by creating a macro that looks like this <b>^S(\"home\",0);</b>. The first value is the urlized title of the page and the second value is the depth you\'d like the menu to go. By default it will show only the first level. To go three levels deep create a macro like this <b>^S(\"home\",3);</b>.\r\n<p>\r\n\r\n\r\n<b>^s(); - Specific SubMenu (Horizontal)</b><br>\r\nThis macro allows you to get the submenu of any page, starting with the page you specified. For instance, you could get the home page submenu by creating a macro that looks like this <b>^s(\"home\");</b>. The value is the urlized title of the page.  You can optionally specify a delimeter to be used between page names by using ^s(\"home\",\":--:\");. The default delimeter is ·.\r\n<p>\r\n\r\n<b>^Synopsis; or ^Synopsis(); Menu</b><br>\r\nThis macro allows you to get the submenu of a page along with the synopsis of each link. You may specify an integer to specify how many levels deep to traverse the page tree.\r\n<p>\r\n\r\n<i>Notes:</i> The .synopsis_sub, .synopsis_summary, and .synopsis_title style sheet classes are tied to this macro.\r\n<p>\r\n\r\n<b>^T; or ^T(); - Top Level Menu (Vertical)</b><br>\r\nA vertical menu containing the main pages of the site (aka the sub-pages from the home page). In addition, you may configure this macro by specifying how many levels deep the menu should go. By default it will show only the first level. To go three levels deep create a macro like this <b>^T(3);</b>. If you set the macro to \"0\" it will track the entire site tree.\r\n<p>\r\n\r\n<b>^t; - Top Level Menu (Horizontal)</b><br>\r\nA vertical menu containing the main pages of the site (aka the sub-pages from the home page). You can optionally specify a delimeter to be used between page names by using ^t(:--:);. The default delimeter is ·.\r\n<p>\r\n\r\n<b>^Thumbnail();</b><br>\r\nReturns the URL of a thumbnail for an image from the image manager. Specify the name of the image like this <b>^Thumbnail(\"imageName\");</b>.\r\n<p>\r\n\r\n<b>^ThumbnailLinker();</b><br>\r\nThis is a good way to create a quick and dirty screenshots page or a simple photo gallery. Simply specify the name of an image in the Image Manager like this: ^ThumbnailLinker(\"My Grandmother\"); and this macro will create a thumnail image with a title under it that links to the full size version of the image.\r\n<p>\r\n\r\n<b>^u; - Company URL</b><br>\r\nThe URL for your company specified in the settings by your Administrator.\r\n<p>\r\n\r\n<b>^URLEncode();</b><br>\r\nThis macro is mainly useful in SQL reports, but it could be useful elsewhere as well. It takes the input of a string and URL Encodes it so that the string can be passed through a URL. It\'s syntax looks like this: ^URLEncode(\"Is this my string?\");\r\n<p>\r\n\r\n\r\n<b>^User();</b><br>\r\nThis macro will allow you to display any information from a user\'s account or profile. For instance, if you wanted to display a user\'s email address you\'d create this macro: ^User(\"email\");\r\n<p>\r\n\r\n<b>^/; - System URL</b><br>\r\nThe URL to the gateway script (example: <i>/index.pl/</i>).\r\n<p>\r\n\r\n<b>^\\; - Page URL</b><br>\r\nThe URL to the current page (example: <i>/index.pl/pagename</i>).\r\n<p>\r\n\r\n<b>^@; - Username</b><br>\r\nThe username of the currently logged in user.\r\n<p>\r\n\r\n<b>^?; - Search</b><br>\r\nAdd a search box to the page. The search box is tied to WebGUI\'s built-in search engine.\r\n<p>\r\n\r\n<i>Note:</i> The .searchBox style sheet class is tied to this macro.\r\n<p>\r\n\r\n<b>^#; - User ID</b><br>\r\nThe user id of the currently logged in user.\r\n<p>\r\n\r\n<b>^*; or ^*(); - Random Number</b><br>\r\nA randomly generated number. This is often used on images (such as banner ads) that you want to ensure do not cache. In addition, you may configure this macro like this <b>^*(100);</b> to create a random number between 0 and 100.\r\n<p>\r\n\r\n<b>^-;,^0;,^1;,^2;,^3;, etc.</b><br>\r\nThese macros are reserved for system/wobject-specific functions as in the SQL Report wobject and the Body in the Style Manager.\r\n<p>\r\n');
INSERT INTO international VALUES (62,'Product',1,'Product Template, Add/Edit');
INSERT INTO international VALUES (63,'Product',1,'Product templates are used to control how your product presented to your customer, in much the same way that other templates in WebGUI layout content. There are a few templates provided for you as reference, but you should create a template that\'s right for your product. \r\n<p>\r\nChances are you won\'t need all of the fields that WebGUI\'s product manager gives you. When creating your template, be sure to remove those fields for faster operation.\r\n<p>\r\n<b>NOTE:</b> You shouldn\'t edit the default templates, but rather make copies of them if you wish to edit them. This is because the templates may be changed in future releases of WebGUI and then your changes would be lost at upgrade time. If you make copies, or create your own templates, you won\'t have to worry about losing your changes.\r\n<p>\r\nThere are many custom macros to use in your product templates. They are as follows:\r\n<p>\r\n<b>^Product_Accessories;</b><br>\r\nDisplays the list of accessories associated with this product.\r\n<p>\r\n<b>^Product_Benefits;</b><br>\r\nDisplays the list of benefits associated with this product.\r\n<p>\r\n<b>^Product_Description;</b><br>\r\nDisplays the product\'s description.\r\n<p>\r\n<b>^Product_Features;</b><br>\r\nDisplays the list of features associated with this product.\r\n<p>\r\n<b>^Product_Image1;</b><br>\r\nDisplays the first image you uploaded with this product (if any).\r\n<p>\r\n<b>^Product_Image2;</b><br>\r\nDisplays the second image you uploaded with this product (if any).\r\n<p>\r\n<b>^Product_Image2;</b><br>\r\nDisplays the third image you uploaded with this product (if any).\r\n<p>\r\n<b>^Product_Number;</b><br>\r\nDisplays the product\'s number field or SKU.\r\n<p>\r\n<b>^Product_Price;</b><br>\r\nDisplays the product\'s price field.\r\n<p>\r\n<b>^Product_Related;</b><br>\r\nDisplays the list of related products associated with this product.\r\n<p>\r\n<b>^Product_Specifications;</b><br>\r\nDisplays the list of specifications associated with this product.\r\n<p>\r\n<b>^Product_Thumbnail1;</b><br>\r\nDisplays the thumbnail of the first image you uploaded with this product (if any) along with a link to view the full size image.\r\n<p>\r\n<b>^Product_Thumbnail2;</b><br>\r\nDisplays the thumbnail of the second image you uploaded with this product (if any) along with a link to view the full size image.\r\n<p>\r\n<b>^Product_Thumbnail3;</b><br>\r\nDisplays the thumbnail of the third image you uploaded with this product (if any) along with a link to view the full size image.\r\n<p>\r\n<b>^Product_Title;</b><br>\r\nDisplays the title of the product. Note that if you use this macro, you\'ll likely want to turn off the default title by selecting \"No\" on the \"Display title?\" field.\r\n<p>\r\n');
INSERT INTO international VALUES (670,'WebGUI',1,'Image, Add/Edit');
INSERT INTO international VALUES (673,'WebGUI',1,'Image, Delete');
INSERT INTO international VALUES (676,'WebGUI',1,'Images, Manage');
INSERT INTO international VALUES (678,'WebGUI',1,'Root, Manage');
INSERT INTO international VALUES (681,'WebGUI',1,'Packages, Creating');
INSERT INTO international VALUES (680,'WebGUI',1,'Package, Add');
INSERT INTO international VALUES (675,'WebGUI',1,'Search Engine, Using');
INSERT INTO international VALUES (656,'WebGUI',1,'Company Information, Edit');
INSERT INTO international VALUES (696,'WebGUI',1,'Trash, Empty');
INSERT INTO international VALUES (672,'WebGUI',1,'Profile Settings, Edit');
INSERT INTO international VALUES (674,'WebGUI',1,'Miscellaneous Settings, Edit');
INSERT INTO international VALUES (661,'WebGUI',1,'File Settings, Edit');
INSERT INTO international VALUES (663,'WebGUI',1,'Mail Settings, Edit');
INSERT INTO international VALUES (671,'WebGUI',1,'Wobjects, Using');
INSERT INTO international VALUES (677,'WebGUI',1,'Wobject, Add/Edit');
INSERT INTO international VALUES (668,'WebGUI',1,'Style Sheets, Using');
INSERT INTO international VALUES (667,'WebGUI',1,'Group, Add/Edit');
INSERT INTO international VALUES (652,'WebGUI',1,'User Settings, Edit');
INSERT INTO international VALUES (665,'WebGUI',1,'Group, Delete');
INSERT INTO international VALUES (666,'WebGUI',1,'Style, Add/Edit');
INSERT INTO international VALUES (664,'WebGUI',1,'Wobject, Delete');
INSERT INTO international VALUES (662,'WebGUI',1,'Settings, Manage');
INSERT INTO international VALUES (660,'WebGUI',1,'Groups, Manage');
INSERT INTO international VALUES (658,'WebGUI',1,'Users, Manage');
INSERT INTO international VALUES (659,'WebGUI',1,'Styles, Manage');
INSERT INTO international VALUES (657,'WebGUI',1,'User, Delete');
INSERT INTO international VALUES (682,'WebGUI',1,'User Profile, Edit');
INSERT INTO international VALUES (655,'WebGUI',1,'User, Add/Edit');
INSERT INTO international VALUES (653,'WebGUI',1,'Page, Delete');
INSERT INTO international VALUES (654,'WebGUI',1,'Style, Delete');
INSERT INTO international VALUES (679,'WebGUI',1,'Content Settings, Edit');
INSERT INTO international VALUES (683,'WebGUI',1,'Templates, Manage');
INSERT INTO international VALUES (684,'WebGUI',1,'Template, Add/Edit');
INSERT INTO international VALUES (685,'WebGUI',1,'Template, Delete');
INSERT INTO international VALUES (669,'WebGUI',1,'Macros, Using');
INSERT INTO international VALUES (686,'WebGUI',1,'Image Group, Add');
INSERT INTO international VALUES (641,'WebGUI',1,'Image groups are like folders that are used to organize your images. The use of image groups is not required, but on large sites it is definitely useful.\r\n<p>\r\n\r\n<b>Group Name</b><br>\r\nThe name that will be displayed as you\'re browsing through your images.\r\n<p>\r\n\r\n<b>Group Description</b><br>\r\nBriefly describe what this image group is used for.\r\n<p>\r\n');
INSERT INTO international VALUES (72,'DownloadManager',1,'Download, Add/Edit');
INSERT INTO international VALUES (73,'DownloadManager',1,'<b>File Title</b><br>\r\nThe title that will be displayed for this download.\r\n<p>\r\n\r\n<b>Download File</b><br>\r\nChoose the file from your hard drive that you wish to upload to this download manager.\r\n<p>\r\n\r\n<b>Alternate Version #1</b><br>\r\nAn alternate version of the Download File. For instance, if the download file was a JPEG, perhaps the alternate version would be a TIFF or a BMP.\r\n<p>\r\n\r\n<b>Alternate Version #2</b><br>\r\nAn alternate version of the Download File. For instance, if the download file was a JPEG, perhaps the alternate version would be a TIFF or a BMP.\r\n<p>\r\n\r\n<b>Brief Synopsis</b><br>\r\nA short description of this file. Be sure to include keywords that users may try to search for.\r\n<p>\r\n\r\n<b>Group To Download</b><br>\r\nChoose the group that may download this file.\r\n<p>\r\n\r\n<b>Proceed to add download?</b><br>\r\nChoose \"Yes\" if you have another file to add to this download manager.\r\n<p>\r\n');
INSERT INTO international VALUES (72,'EventsCalendar',1,'Event, Add/Edit');
INSERT INTO international VALUES (73,'EventsCalendar',1,'<b>Title</b><br>\r\nThe title for this event.\r\n<p>\r\n\r\n<b>Description</b><br>\r\nDescribe the activities of this event or information about where the event is to be held.\r\n<p>\r\n\r\n<b>Start Date</b><br>\r\nOn what date will this event begin?\r\n<p>\r\n\r\n<b>End Date</b><br>\r\nOn what date will this event end?\r\n<p>\r\n\r\n<b>Recurs every<b><br>\r\nSelect a recurrence interval for this event. \r\n\r\n<p>\r\n\r\n<b>Proceed to add event?</b><br>\r\nIf you\'d like to add another event, select \"Yes\".\r\n<p>\r\n');
INSERT INTO international VALUES (72,'FAQ',1,'Question, Add/Edit');
INSERT INTO international VALUES (73,'FAQ',1,'<b>Question</b><br>\r\nAdd the question you\'d like to appear on the FAQ.\r\n<p>\r\n\r\n\r\n<b>Answer</b><br>\r\nAdd the answer for the question you entered above.\r\n<p>\r\n\r\n\r\n<b>Proceed to add question?</b><br>\r\nIf you have another question to add, select \"Yes\".\r\n<p>\r\n\r\n');
INSERT INTO international VALUES (50,'Product',1,'Benefits are typically the result of the features of your product. They are why your product is so good. If you add benefits, you may also wish to consider adding some features.\r\n<p>\r\n\r\n<b>Benefit</b><br>\r\nYou may enter a new benefit, or select from one you\'ve already entered.\r\n<p>\r\n\r\n<b>Add another benefit?</b><br>\r\nIf you\'d like to add another benefit right away, select \"Yes\".\r\n<p>\r\n');
INSERT INTO international VALUES (72,'LinkList',1,'Link, Add/Edit');
INSERT INTO international VALUES (73,'LinkList',1,'<b>Title</b><br>\r\nThe text that will be linked.\r\n<p>\r\n\r\n<b>URL</b><br>\r\nThe web site to link to.\r\n<p>\r\n\r\n<b>Open in new window?</b><br>\r\nSelect yes if you\'d like this link to pop-up into a new window.\r\n<p>\r\n\r\n<b>Description</b><br>\r\nDescribe the site you\'re linking to. You can omit this if you\'d like.\r\n<p>\r\n\r\n<b>Proceed to add link?</b>\r\nIf you have another link to add, select \"Yes\".\r\n<p>\r\n');
INSERT INTO international VALUES (49,'Product',1,'Product Benefit, Add/Edit');
INSERT INTO international VALUES (697,'WebGUI',1,'Karma, Using');
INSERT INTO international VALUES (698,'WebGUI',1,'Karma is a method of tracking the activity of your users, and potentially rewarding or punishing them for their level of activity. Once karma has been enabled, you\'ll notice that the menus of many things in WebGUI change to reflect karma.\r\n<p>\r\n\r\nYou can track whether users are logging in, and how much they contribute to your site. And you can allow them access to additional features by the level of their karma.\r\n<p>\r\n\r\nYou can find out more about karma in <a href=\"http://www.plainblack.com/ruling_webgui\">Ruling WebGUI</a>.');
INSERT INTO international VALUES (5,'WobjectProxy',1,'Wobject Proxy, Add/Edit');
INSERT INTO international VALUES (6,'WobjectProxy',1,'With the Wobject Proxy you can mirror a wobject from another page to any other page. This is useful if you want to reuse the same content in multiple sections of your site.\r\n<p>\r\n\r\n\r\n<b>Wobject To Proxy</b><br>\r\nSelect the wobject from your system that you\'d like to proxy. The select box takes the format of \"<b>Page Title</b> / <b>Wobject Name</b> (<b>Wobject Id</b>) so that you can quickly and accurately find the wobject you\'re looking for.\r\n<p>\r\n\r\n');
INSERT INTO international VALUES (38,'Product',1,'Product, Add/Edit');
INSERT INTO international VALUES (39,'Product',1,'WebGUI has a product management system built in to enable you to publish your products and services to your site quickly and easily.\r\n<p>\r\n\r\n<b>Price</b><br>\r\nThe price of this product. You may optionally enter text like \"call for pricing\" if you wish, or you may leave it blank.\r\n<p>\r\n\r\n<b>Product Number</b><br>\r\nThe product number, SKU, ISBN, or other identifier for this product.\r\n<p>\r\n\r\n<b>Product Image 1</b><br>\r\nAn image of this product.\r\n<p>\r\n\r\n<b>Product Image 2</b><br>\r\nAn image of this product.\r\n<p>\r\n\r\n<b>Product Image 3</b><br>\r\nAn image of this product.\r\n<p>\r\n\r\n<b>Brochure</b><br>\r\nThe brochure for this product.\r\n<p>\r\n\r\n<b>Manual</b><br>\r\nThe product, user, or service manual for this product.\r\n<p>\r\n\r\n<b>Warranty</b><br>\r\nThe warranty for this product.\r\n<p>\r\n');
INSERT INTO international VALUES (40,'Product',1,'Product Feature, Add/Edit');
INSERT INTO international VALUES (41,'Product',1,'Features are selling points for a product. IE: Reasons to buy your product. Features often result in benefits, so you may want to also add some benefits to this product.\r\n<p>\r\n\r\n<b>Feature</b><br>\r\nYou may enter a new feature, or select one you entered for another product in the system.\r\n<p>\r\n\r\n<b>Add another feature?</b><br>\r\nIf you\'d like to add another feature right away, select \"Yes\".\r\n<p>\r\n');
INSERT INTO international VALUES (42,'Product',1,'Product Specification, Add/Edit');
INSERT INTO international VALUES (43,'Product',1,'Specifications are the technical details of your product.\r\n<p>\r\n\r\n\r\n<b>Label</b><br>\r\nThe type of specification. For instance, height, weight,   or color. You may select one you\'ve entered for another product, or type in a new specification.\r\n<p>\r\n\r\n\r\n<b>Specification</b><br>\r\nThe actual specification value. For instance, if you chose height as the Label, then you\'d enter a numeric value like \"18\".\r\n<p>\r\n\r\n\r\n<b>Units</b><br>\r\nThe unit of measurement for this specification. For instance, if you chose height for your label, perhaps the units would be \"meters\".\r\n<p>\r\n\r\n\r\n<b>Add another specification?</b><br>\r\nIf you\'d like to add another specification, select \"Yes\".\r\n<p>\r\n\r\n');
INSERT INTO international VALUES (709,'WebGUI',1,'<b>Image Managers Group</b><br>\r\nSelect the group that should have control over adding, editing, and deleting images.\r\n<p>\r\n\r\n<b>Style Managers Group</b><br>\r\nSelect the group that should have control over adding, editing, and deleting styles.\r\n<p>\r\n\r\n<b>Template Managers Group</b><br>\r\nSelect the group that should have control over adding, editing, and deleting templates.\r\n<p>\r\n');
INSERT INTO international VALUES (44,'Product',1,'Product Accessory, Add/Edit');
INSERT INTO international VALUES (45,'Product',1,'Accessories are products that enhance other products.\r\n<p>\r\n\r\n<b>Accessory</b><br>\r\nChoose from the list of products you\'ve already entered.\r\n<p>\r\n\r\n<b>Add another accessory?</b><br>\r\nSelect \"Yes\" if you have another accessory to add.\r\n<p>\r\n');
INSERT INTO international VALUES (46,'Product',1,'Product (Related), Add/Edit');
INSERT INTO international VALUES (47,'Product',1,'Related products are products that are comparable or complimentary to other products.\r\n<p>\r\n\r\n\r\n<b>Related products</b><br>\r\nChoose from the list of products you\'ve already entered.\r\n<p>\r\n\r\n\r\n<b>Add another related product?</b><br>\r\nSelect \"Yes\" if you have another related product to add.\r\n<p>\r\n\r\n');
INSERT INTO international VALUES (708,'WebGUI',1,'Privilege Settings, Manage');
INSERT INTO international VALUES (30,'UserSubmission',1,'Karma Per Submission');
INSERT INTO international VALUES (72,'Poll',1,'Randomize answers?');
INSERT INTO international VALUES (699,'WebGUI',1,'First Day Of Week');
INSERT INTO international VALUES (74,'EventsCalendar',1,'Calendar Month (Small)');
INSERT INTO international VALUES (702,'WebGUI',1,'Month(s)');
INSERT INTO international VALUES (703,'WebGUI',1,'Year(s)');
INSERT INTO international VALUES (704,'WebGUI',1,'Second(s)');
INSERT INTO international VALUES (705,'WebGUI',1,'Minute(s)');
INSERT INTO international VALUES (706,'WebGUI',1,'Hour(s)');

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
INSERT INTO language VALUES (3,'Dutch','ISO-8859-1');
INSERT INTO language VALUES (4,'Español','ISO-8859-1');
INSERT INTO language VALUES (5,'Português','ISO-8859-1');
INSERT INTO language VALUES (6,'Svenska','ISO-8859-1');
INSERT INTO language VALUES (7,'¼òÌåÖÐÎÄ (Chinese Simple)','gb2312');
INSERT INTO language VALUES (8,'Italiano','ISO-8859-1');

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
  title varchar(255) NOT NULL default '',
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


INSERT INTO webguiVersion VALUES ('4.6.1','initial install',unix_timestamp());

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
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table 'wobject'
--


INSERT INTO wobject VALUES (-1,4,'SiteMap',0,'Page Not Found',1,'The page you were looking for could not be found on this system. Perhaps it has been deleted or renamed. The following list is a site map of this site. If you don\'t find what you\'re looking for on the site map, you can always start from the <a href=\"^/;\">Home Page</a>.',1,1001744792,3,1016077239,3,0,1001744792,1336444487,2,3600,4,0,'after');
INSERT INTO wobject VALUES (-2,1,'Article',1,'Welcome to WebGUI!',1,'<DIV>\r\n<P class=MsoNormal style=\"MARGIN: 0in 0in 0pt\">If you’re reading this message it means that you’ve got WebGUI up and running. Good job! The installation is not trivial.</P>\r\n<P class=MsoNormal style=\"MARGIN: 0in 0in 0pt\"> <?xml:namespace prefix = o ns = \"urn:schemas-microsoft-com:office:office\" /><o:p></o:p></P>\r\n<P class=MsoNormal style=\"MARGIN: 0in 0in 0pt\">In order to do anything useful with your new installation you’ll need to log in as the default administrator account. Follow these steps to get started:</P>\r\n<P class=MsoNormal style=\"MARGIN: 0in 0in 0pt\"> <o:p></o:p></P>\r\n<OL style=\"MARGIN-TOP: 0in\" type=1>\r\n<LI class=MsoNormal style=\"MARGIN: 0in 0in 0pt; mso-list: l1 level1 lfo2; tab-stops: list .5in\"><A href=\"^\\;?op=displayLogin\">Click here to log in.</A> (username: Admin password: 123qwe) \r\n<LI class=MsoNormal style=\"MARGIN: 0in 0in 0pt; mso-list: l1 level1 lfo2; tab-stops: list .5in\"><A href=\"^\\;?op=switchOnAdmin\">Click here to turn the administrative interface on.</A></LI></OL>\r\n<P class=MsoNormal style=\"MARGIN: 0in 0in 0pt\"> Now that you’re in as the administrator, you should <A href=\"^\\;?op=displayAccount\">change your password</A> so no one else can log in and mess with your site. You might also want to <A href=\"^\\;?op=addUser\">create another account </A>for yourself with Administrative privileges in case you can\'t log in with the Admin account for some reason.</P>\r\n<P class=MsoNormal style=\"MARGIN: 0in 0in 0pt\"> <o:p></o:p></P>\r\n<P class=MsoNormal style=\"MARGIN: 0in 0in 0pt\">You’ll notice three menus at the top of your screen. Those are your administrative menus. Going from left to right they are <I>Content</I>, <I>Clipboard</I>, and <I>Admin</I>. The content menu allows you to add new pages and content to your site. The clipboard menu is currently empty, but if you cut or copy anything from any of your pages, it will end up there. The admin menu controls things like system settings and users.</P>\r\n<P class=MsoNormal style=\"MARGIN: 0in 0in 0pt\"> <o:p></o:p></P>\r\n<P class=MsoNormal style=\"MARGIN: 0in 0in 0pt\">For more information about how to administer WebGUI consider getting a copy of <I><A href=\"http://www.plainblack.com/ruling_webgui\">Ruling WebGUI</A></I>. Plain Black Software also provides several <A href=\"http://www.plainblack.com/support_programs\">Support Programs </A>for WebGUI if you run into trouble.</P>\r\n<P class=MsoNormal style=\"MARGIN: 0in 0in 0pt\"> <o:p></o:p></P>Enjoy your new WebGUI site!\r\n</DIV>',1,1023555430,3,1023555630,3,0,1023512400,1338872400,2,3600,4,0,'after');

insert into international values (716,'WebGUI',1,'Login');
insert into international values (717,'WebGUI',1,'Logout');
delete from international where internationalId=624 and namespace='WebGUI' and languageId=1;
insert into international (internationalId,namespace,languageId,message) values (624, 'WebGUI',1,'WebGUI macros are used to create dynamic content within otherwise static content. For instance, you may wish to show which user is logged in on every page, or you may wish to have a dynamically built menu or crumb trail. \r\n<p>\r\n\r\nMacros always begin with a carat (^) and follow with at least one other character and ended with w semicolon (;). Some macros can be extended/configured by taking the format of ^<i>x</i>("<b>config text</b>");. The following is a description of all the macros in the WebGUI system.\r\n<p>\r\n\r\n<b>^a; or ^a(); - My Account Link</b><br>\r\nA link to your account information. In addition you can change the link text by creating a macro like this <b>^a("Account Info");</b>. \r\n<p>\r\n\r\n<i>Notes:</i> You can also use the special case ^a(linkonly); to return only the URL to the account page and nothing more. Also, the .myAccountLink style sheet class is tied to this macro.\r\n<p>\r\n\r\n<b>^AdminBar;</b><br>\r\nPlaces the administrative tool bar on the page. This is a required element in the "body" segment of the Style Manager.\r\n<p>\r\n\r\n<b>^AdminText();</b><br>\r\nDisplays a small text message to a user who is in admin mode. Example: ^AdminText("You are in admin mode!");\r\n<p>\r\n\r\n<b>^AdminToggle; or ^AdminToggle();</b><br>\r\nPlaces a link on the page which is only visible to content managers and adminstrators. The link toggles on/off admin mode. You can optionally specify other messages to display like this: ^AdminToggle("Edit On","Edit Off");\r\n<p>\r\n\r\n<b>^C; or ^C(); - Crumb Trail</b><br>\r\nA dynamically generated crumb trail to the current page. You can optionally specify a delimeter to be used between page names by using ^C(::);. The default delimeter is >.\r\n<p>\r\n\r\n<i>Note:</i> The .crumbTrail style sheet class is tied to this macro.\r\n<p>\r\n\r\n<b>^c; - Company Name</b><br>\r\nThe name of your company specified in the settings by your Administrator.\r\n<p>\r\n\r\n\r\n<b>^D; or ^D(); - Date</b><br>\r\nThe current date and time.\r\n<p>\r\n\r\nYou can configure the date by using date formatting symbols. For instance, if you created a macro like this <b>^D("%c %D, %y");</b> it would output <b>September 26, 2001</b>. The following are the available date formatting symbols:\r\n<p>\r\n\r\n<table><tbody><tr><td>%%</td><td>%</td></tr><tr><td>%y</td><td>4 digit year</td></tr><tr><td>%Y</td><td>2 digit year</td></tr><tr><td>%m</td><td>2 digit month</td></tr><tr><td>%M</td><td>variable digit month</td></tr><tr><td>%c</td><td>month name</td></tr><tr><td>%d</td><td>2 digit day of month</td></tr><tr><td>%D</td><td>variable digit day of month</td></tr><tr><td>%w</td><td>day of week name</td></tr><tr><td>%h</td><td>2 digit base 12 hour</td></tr><tr><td>%H</td><td>variable digit base 12 hour</td></tr><tr><td>%j</td><td>2 digit base 24 hour</td></tr><tr><td>%J</td><td>variable digit base 24 hour</td></tr><tr><td>%p</td><td>lower case am/pm</td></tr><tr><td>%P</td><td>upper case AM/PM</td></tr><tr><td>%z</td><td>user preference date format</td></tr><tr><td>%Z</td><td>user preference time format</td></tr></tbody></table>\r\n<p>\r\n\r\n\r\n<b>^e; - Company Email Address</b><br>\r\nThe email address for your company specified in the settings by your Administrator.\r\n<p>\r\n\r\n<b>^Env()</b><br>\r\nCan be used to display a web server environment variable on a page. The environment variables available on each server are different, but you can find out which ones your web server has by going to: http://www.yourwebguisite.com/env.pl\r\n<p>\r\n\r\nThe macro should be specified like this ^Env("REMOTE_ADDR");\r\n<p>\r\n\r\n<b>^Execute();</b><br>\r\nAllows a content manager or administrator to execute an external program. Takes the format of <b>^Execute("/this/file.sh");</b>.\r\n<p>\r\n\r\n\r\n<b>^Extras;</b><br>\r\nReturns the path to the WebGUI "extras" folder, which contains things like WebGUI icons.\r\n<p>\r\n\r\n\r\n<b>^FlexMenu;</b><br>\r\nThis menu macro creates a top-level menu that expands as the user selects each menu item.\r\n<p>\r\n\r\n<b>^FormParam();</b><br>\r\nThis macro is mainly used in generating dynamic queries in SQL Reports. Using this macro you can pull the value of any form field simply by specifing the name of the form field, like this: ^FormParam("phoneNumber");\r\n<p>\r\n\r\n<b>^GroupText();</b><br>\r\nDisplays a small text message to the user if they belong to the specified group. Example: ^GroupText("Visitors","You need an account to do anything cool on this site!");\r\n<p>\r\n\r\n\r\n<b>^H; or ^H(); - Home Link</b><br>\r\nA link to the home page of this site.  In addition you can change the link text by creating a macro like this <b>^H("Go Home");</b>.\r\n<p>\r\n\r\n<i>Notes:</i> You can also use the special case ^H(linkonly); to return only the URL to the home page and nothing more. Also, the .homeLink style sheet class is tied to this macro.\r\n<p>\r\n\r\n<b>^I(); - Image Manager Image with Tag</b><br>\r\nThis macro returns an image tag with the parameters for an image defined in the image manager. Specify the name of the image using a tag like this <b>^I("imageName")</b>;.\r\n<p>\r\n\r\n<b>^i(); - Image Manager Image Path</b><br>\r\nThis macro returns the path of an image uploaded using the Image Manager. Specify the name of the image using a tag like this <b>^i("imageName");</b>.\r\n<p>\r\n\r\n<b>^Include();</b><br>\r\nAllows a content manager or administrator to include a file from the local filesystem. Takes the format of <b>^Include("/this/file.html")</b>;\r\n<p>\r\n\r\n<b>^L; or ^L(); - Login</b><br>\r\nA small login form. You can also configure this macro. You can set the width of the login box like this ^L(20);. You can also set the message displayed after the user is logged in like this ^L(20,Hi ^a(^@;);. Click %here% if you wanna log out!)\r\n<p>\r\n\r\n<i>Note:</i> The .loginBox style sheet class is tied to this macro.\r\n<p>\r\n\r\n<b>^LoginToggle; or ^LoginToggle();</b><br>\r\nDisplays a "Login" or "Logout" message depending upon whether the user is logged in or not. You can optionally specify other messages like this: ^LoginToggle("Click here to log in.","Click here to log out.");\r\n<p>\r\n\r\n<b>^M; or ^M(); - Current Menu (Vertical)</b><br>\r\nA vertical menu containing the sub-pages at the current level. In addition, you may configure this macro by specifying how many levels deep the menu should go. By default it will show only the first level. To go three levels deep create a macro like this <b>^M(3);</b>. If you set the macro to "0" it will track the entire site tree.\r\n<p>\r\n\r\n<b>^m; - Current Menu (Horizontal)</b><br>\r\nA horizontal menu containing the sub-pages at the current level. You can optionally specify a delimeter to be used between page names by using ^m(:--:);. The default delimeter is ·.\r\n<p>\r\n\r\n<b>^P; or ^P(); - Previous Menu (Vertical)</b><br>\r\nA vertical menu containing the sub-pages at the previous level. In addition, you may configure this macro by specifying how many levels deep the menu should go. By default it will show only the first level. To go three levels deep create a macro like this <b>^P(3);</b>. If you set the macro to "0" it will track the entire site tree.\r\n<p>\r\n\r\n<b>^p; - Previous Menu (Horizontal)</b><br>\r\nA horizontal menu containing the sub-pages at the previous level. You can optionally specify a delimeter to be used between page names by using ^p(:--:);. The default delimeter is ·.\r\n<p>\r\n\r\n<b>^Page();</b><br>\r\nThis can be used to retrieve information about the current page. For instance it could be used to get the page URL like this ^Page("urlizedTitle"); or to get the menu title like this ^Page("menuTitle");.\r\n<p>\r\n\r\n<b>^PageTitle;</b><br>\r\nDisplays the title of the current page.\r\n<p>\r\n\r\n<i>Note:</i> If you begin using admin functions or the indepth functions of any wobject, the page title will become a link that will quickly bring you back to the page.\r\n<p>\r\n\r\n<b>^r; or ^r(); - Make Page Printable</b><br>\r\nCreates a link to remove the style from a page to make it printable.  In addition, you can change the link text by creating a macro like this <b>^r("Print Me!");</b>.\r\n<p>\r\n\r\nBy default, when this link is clicked, the current page\'s style is replaced with the "Make Page Printable" style in the Style Manager. However, that can be overridden by specifying the name of another style as the second parameter, like this: ^r("Print!","WebGUI");\r\n<p>\r\n\r\n<i>Notes:</i> You can also use the special case ^r(linkonly); to return only the URL to the make printable page and nothing more. Also, the .makePrintableLink style sheet class is tied to this macro.\r\n<p>\r\n\r\n<b>^rootmenu; or ^rootmenu(); (Horizontal)</b><br>\r\nCreates a horizontal menu of the various roots on your system (except for the WebGUI system roots). You can optionally specify a menu delimiter like this: ^rootmenu(|);\r\n<p>\r\n\r\n\r\n<b>^RootTitle;</b><br>\r\nReturns the title of the root of the current page. For instance, the main root in WebGUI is the "Home" page. Many advanced sites have many roots and thus need a way to display to the user which root they are in.\r\n<p>\r\n\r\n<b>^S(); - Specific SubMenu (Vertical)</b><br>\r\nThis macro allows you to get the submenu of any page, starting with the page you specified. For instance, you could get the home page submenu by creating a macro that looks like this <b>^S("home",0);</b>. The first value is the urlized title of the page and the second value is the depth you\'d like the menu to go. By default it will show only the first level. To go three levels deep create a macro like this <b>^S("home",3);</b>.\r\n<p>\r\n\r\n\r\n<b>^s(); - Specific SubMenu (Horizontal)</b><br>\r\nThis macro allows you to get the submenu of any page, starting with the page you specified. For instance, you could get the home page submenu by creating a macro that looks like this <b>^s("home");</b>. The value is the urlized title of the page.  You can optionally specify a delimeter to be used between page names by using ^s("home",":--:");. The default delimeter is ·.\r\n<p>\r\n\r\n<b>^SQL();</b><br>\r\nA one line SQL report. Sometimes you just need to pull something back from the database quickly. This macro is also useful in extending the SQL Report wobject. It uses the numeric macros (^0; ^1; ^2; etc) to position data and can also use the ^rownum; macro just like the SQL Report wobject. Examples:<p>\r\n ^SQL("select count(*) from users","There are ^0; users on this system.");\r\n<p>\r\n^SQL("select userId,username from users order by username","&lt;a href=\'^/;?op=viewProfile&uid=^0;\'&gt;^1;&lt;/a&gt;&lt;br&gt;");\r\n<p>\r\n\r\n<b>^Synopsis; or ^Synopsis(); Menu</b><br>\r\nThis macro allows you to get the submenu of a page along with the synopsis of each link. You may specify an integer to specify how many levels deep to traverse the page tree.\r\n<p>\r\n\r\n<i>Notes:</i> The .synopsis_sub, .synopsis_summary, and .synopsis_title style sheet classes are tied to this macro.\r\n<p>\r\n\r\n<b>^T; or ^T(); - Top Level Menu (Vertical)</b><br>\r\nA vertical menu containing the main pages of the site (aka the sub-pages from the home page). In addition, you may configure this macro by specifying how many levels deep the menu should go. By default it will show only the first level. To go three levels deep create a macro like this <b>^T(3);</b>. If you set the macro to "0" it will track the entire site tree.\r\n<p>\r\n\r\n<b>^t; - Top Level Menu (Horizontal)</b><br>\r\nA vertical menu containing the main pages of the site (aka the sub-pages from the home page). You can optionally specify a delimeter to be used between page names by using ^t(:--:);. The default delimeter is ·.\r\n<p>\r\n\r\n<b>^Thumbnail();</b><br>\r\nReturns the URL of a thumbnail for an image from the image manager. Specify the name of the image like this <b>^Thumbnail("imageName");</b>.\r\n<p>\r\n\r\n<b>^ThumbnailLinker();</b><br>\r\nThis is a good way to create a quick and dirty screenshots page or a simple photo gallery. Simply specify the name of an image in the Image Manager like this: ^ThumbnailLinker("My Grandmother"); and this macro will create a thumnail image with a title under it that links to the full size version of the image.\r\n<p>\r\n\r\n<b>^u; - Company URL</b><br>\r\nThe URL for your company specified in the settings by your Administrator.\r\n<p>\r\n\r\n<b>^URLEncode();</b><br>\r\nThis macro is mainly useful in SQL reports, but it could be useful elsewhere as well. It takes the input of a string and URL Encodes it so that the string can be passed through a URL. It\'s syntax looks like this: ^URLEncode("Is this my string?");\r\n<p>\r\n\r\n\r\n<b>^User();</b><br>\r\nThis macro will allow you to display any information from a user\'s account or profile. For instance, if you wanted to display a user\'s email address you\'d create this macro: ^User("email");\r\n<p>\r\n\r\n<b>^/; - System URL</b><br>\r\nThe URL to the gateway script (example: <i>/index.pl/</i>).\r\n<p>\r\n\r\n<b>^\\; - Page URL</b><br>\r\nThe URL to the current page (example: <i>/index.pl/pagename</i>).\r\n<p>\r\n\r\n<b>^@; - Username</b><br>\r\nThe username of the currently logged in user.\r\n<p>\r\n\r\n<b>^?; - Search</b><br>\r\nAdd a search box to the page. The search box is tied to WebGUI\'s built-in search engine.\r\n<p>\r\n\r\n<i>Note:</i> The .searchBox style sheet class is tied to this macro.\r\n<p>\r\n\r\n<b>^#; - User ID</b><br>\r\nThe user id of the currently logged in user.\r\n<p>\r\n\r\n<b>^*; or ^*(); - Random Number</b><br>\r\nA randomly generated number. This is often used on images (such as banner ads) that you want to ensure do not cache. In addition, you may configure this macro like this <b>^*(100);</b> to create a random number between 0 and 100.\r\n<p>\r\n\r\n<b>^-;,^0;,^1;,^2;,^3;, etc.</b><br>\r\nThese macros are reserved for system/wobject-specific functions as in the SQL Report wobject and the Body in the Style Manager.\r\n<p>\r\n');








