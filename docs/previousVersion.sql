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
  groupToPost int(11) NOT NULL default '2',
  groupToModerate int(11) NOT NULL default '4',
  editTimeout int(11) NOT NULL default '1',
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table 'Article'
--



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
-- Table structure for table 'MessageBoard'
--

CREATE TABLE MessageBoard (
  wobjectId int(11) NOT NULL default '0',
  groupToPost int(11) default NULL,
  messagesPerPage int(11) NOT NULL default '50',
  editTimeout int(11) default NULL,
  groupToModerate int(11) NOT NULL default '4',
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
  editTimeout int(11) NOT NULL default '1',
  groupToPost int(11) NOT NULL default '2',
  groupToModerate int(11) NOT NULL default '4',
  displayThumbnails int(11) NOT NULL default '0',
  layout varchar(30) NOT NULL default 'traditional',
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


INSERT INTO groupings VALUES (1,1,2114402400);
INSERT INTO groupings VALUES (5,3,2114402400);
INSERT INTO groupings VALUES (4,3,2114402400);
INSERT INTO groupings VALUES (3,3,2114402400);
INSERT INTO groupings VALUES (2,3,2114402400);
INSERT INTO groupings VALUES (6,3,2114402400);

--
-- Table structure for table 'groups'
--

CREATE TABLE groups (
  groupId int(11) NOT NULL default '0',
  groupName varchar(30) default NULL,
  description varchar(255) default NULL,
  expireAfter int(11) NOT NULL default '314496000',
  PRIMARY KEY  (groupId)
) TYPE=MyISAM;

--
-- Dumping data for table 'groups'
--


INSERT INTO groups VALUES (1,'Visitors','This is the public group that has no privileges.',314496000);
INSERT INTO groups VALUES (2,'Registered Users','All registered users belong to this group automatically. There are no associated privileges other than that the user has an account and is logged in.',314496000);
INSERT INTO groups VALUES (3,'Admins','Anyone who belongs to this group has privileges to do anything and everything.',314496000);
INSERT INTO groups VALUES (4,'Content Managers','Users that have privileges to edit content on this site. The user still needs to be added to a group that has editing privileges on specific pages.',314496000);
INSERT INTO groups VALUES (5,'Style Managers','Users that have privileges to edit styles for this site. These privileges do not allow the user to assign privileges to a page, just define them to be used.',314496000);
INSERT INTO groups VALUES (6,'Package Managers','Users that have privileges to add, edit, and delete packages of wobjects and pages to deploy.',314496000);
INSERT INTO groups VALUES (7,'Everyone','A group that automatically includes all users including Visitors.',314496000);
INSERT INTO groups VALUES (8,'Template Managers','Users that have privileges to edit templates for this site.',314496000);

--
-- Table structure for table 'help'
--

CREATE TABLE help (
  helpId int(11) NOT NULL default '0',
  namespace varchar(30) NOT NULL default 'WebGUI',
  language varchar(30) NOT NULL default 'English',
  action varchar(30) default NULL,
  object varchar(30) default NULL,
  body mediumtext,
  seeAlso varchar(50) NOT NULL default '0',
  PRIMARY KEY  (helpId,namespace,language),
  KEY helpId (helpId,language)
) TYPE=MyISAM;

--
-- Dumping data for table 'help'
--


INSERT INTO help VALUES (20,'WebGUI','English','Add/Edit','Image','<b>Name</b><br>\r\nThe label that this image will be referenced by to include it into pages.\r\n<p>\r\n\r\n<b>File</b><br>\r\nSelect a file from your local drive to upload to the server.\r\n<p>\r\n\r\n<b>Parameters</b><br>\r\nAdd any HTML &ltimg&rt; parameters that you wish to act as the defaults for this image.\r\n<p>\r\n<i>Example:</i><br>\r\nalign=\"right\"\r\nalt=\"This is an image\"','15');
INSERT INTO help VALUES (1,'DownloadManager','English','Add/Edit','Download Manager','The Download Manager is designed to help you manage file distribution on your site. It allows you to specify who may download files from your site.\r\n<p>\r\n\r\n<b>Paginate After</b><br>\r\nHow many files should be displayed before splitting the results into separate pages? In other words, how many files should be displayed per page?\r\n<p>\r\n\r\n<b>Display thumbnails?</b><br>\r\nCheck this if you want to display thumbnails for any images that are uploaded. Note that the thumbnail is only displayed for the main attachment, not the alternate versions.\r\n<p>\r\n\r\n<b>Proceed to add file?</b><br>\r\nIf you wish to start adding files to download right away, leave this checked.\r\n<p>\r\n\r\n','1,2,3,4,5');
INSERT INTO help VALUES (23,'WebGUI','English','Delete','Image','When you delete an image it will be removed from the server and cannot be recovered. Therefore, be sure that you really wish to delete the image before you confirm the delete.','15');
INSERT INTO help VALUES (26,'WebGUI','English','Manage','Image','Using the built in image manager in WebGUI you can upload images to one central location for use anywhere else in the site with no need for any special software or knowledge.\r\n<p>\r\nTo place the images you\'ve uploaded use the ^I(); and ^i(); macros. More information on them can be found in the Using Macros help.\r\n<p>\r\n<i>Tip:</i> You can use the ^I(); macro (and therefore the images from the image manager) in places you may not have conisdered. For instance, you could place images in the titles of your wobjects. Or in wobjects like Link List and Site Map that use bullets, you could use image manager images as the bullets.','15');
INSERT INTO help VALUES (28,'WebGUI','English','Manage','Root','Simply put, roots are pages with no parent. The first and most important root in WebGUI is the \"Home\" page. Many people will never add any additional roots, but a few power users will. Those power users will create new roots for many different reasons. Perhaps they\'ll create a staging area for content managers. Or maybe a hidden area for Admin tools. Or possibly even a new root just to place their search engine.','0');
INSERT INTO help VALUES (31,'WebGUI','English','Add/Edit','Package','To create a package follow these simple steps:\r\n<ol>\r\n<li> From the admin menu select \"Manage packages.\"\r\n<li> Add a page and give it a name. The name of the page will be the name of the package.\r\n<li> Go to the new page you created and start adding pages and wobjects. Any pages or wobjects you add will be created each time this package is deployed. \r\n</ol>\r\n<b>Notes:</b><br>\r\nIn order to add, edit, or delete packages you must be in the Package Mangers group or in the Admins group.\r\n<br><br>\r\nIf you add content to any of the wobjects, that content will automatically be copied when the package is deployed.\r\n<br><br>\r\nPrivileges and styles assigned to pages in the package will not be copied when the package is deployed. Instead the pages will take the privileges and styles of the area to which they are deployed.','0');
INSERT INTO help VALUES (30,'WebGUI','English','Select','Package','Packages are groups of pages and wobjects that are predefined to be deployed together. A package manager may see the need to create a package several pages with a message board, an FAQ, and a Poll because that task is performed quite often. Packages are often defined to lessen the burden of repetitive tasks.\r\n<br><br>\r\nOne package that many people create is a Page/Article package. It is often the case that you want to add a page with an article on it for content. Instead of going through the steps of creating a page, going to the page, and then adding an article to the page, you may wish to simply create a package to do those steps all at once.','0');
INSERT INTO help VALUES (25,'WebGUI','English','Using','Search Engine','Due to many requests by our customers, we\'ve built a small, but sturdy search engine into WebGUI. If you wish to use the internal search engine, you can use the ^?; macro or feel free to build your own form to access it.\r\n<br><br>\r\nWe do not recommend the built-in search engine\'s use on large sites as it can be very slow, but it works great for small sites and intranets. There are many great search engines available around the Internet that can be used with WebGUI.\r\n<br><br>\r\n<a href=\"http://www.mnogosearch.org\">MnoGo Search</a> - A very powerful and very fast open-source search engine. We maintain an unsupported WebGUI wobject on the <a href=\"http://www.plainblack.com\">Plain Black</a> site that will allow you to use MnoGo search directly within WebGUI or you can use the super-powerful external search engine it provides.\r\n<br><br>\r\n<a href=\"http://www.htdig.org/\">ht://Dig</a> - Another great open-source search engine. We\'ve used it in many instances and it always proves to be reliable and fast.','0');
INSERT INTO help VALUES (1,'Item','English','Add/Edit','Item','Like Articles, Items are the Swiss Army knife of WebGUI. Most pieces of static content can be added via the Item, though Items are usually used for smaller content than Articles.\r\n<br><br>\r\n\r\n<b>Link URL</b><br>\r\nThis URL will be attached to the title of this Item.\r\n<br><br>\r\n<i>Example:</i> http://www.google.com\r\n<br><br>\r\n\r\n<b>Attachment</b><br>\r\nIf you wish to attach a word processor file, a zip file, or any other file for download by your users, then choose it from your hard drive.\r\n\r\n','1,2,3,4,5');
INSERT INTO help VALUES (6,'WebGUI','English','Edit','Company Information','<b>Company Name</b><br>\r\nThe name of your company. It will appear on all emails and anywhere you use the Company Name macro.\r\n<br><br>\r\n\r\n<b>Company Email Address</b><br>\r\nA general email address at your company. This is the address that all automated messages will come from. It can also be used via the WebGUI macro system.\r\n<br><br>\r\n\r\n<b>Company URL</b><br>\r\nThe primary URL of your company. This will appear on all automated emails sent from the WebGUI system. It is also available via the WebGUI macro system.\r\n','6');
INSERT INTO help VALUES (46,'WebGUI','English','Empty','Trash','If you choose to empty your trash, any items contained in it will be lost forever. If you\'re unsure about a few items, it might be best to cut them to your clipboard before you empty the trash.','0');
INSERT INTO help VALUES (22,'WebGUI','English','Edit','Profile Settings','Profiles are used to extend the information of a particular user. In some cases profiles are important to a site, in others they are not. The profiles system is completely extensible. You can add as much information to the users profile as you like.\r\n','6');
INSERT INTO help VALUES (1,'UserSubmission','English','Add/Edit','User Submission System','User Submission Systems are a great way to add a sense of community to any site as well as get free content from your users.\r\n<br><br>\r\n\r\n<b>Layout</b><br>\r\nWhat should this user submission system look like? Currently these are the views available:\r\n<ul>\r\n<li><b>Traditional</b> - Creates a simple spreadsheet style table that lists off each submission and is sorted by date. \r\n<li><b>Web Log</b> - Creates a view that looks like the news site <a href=\"http://slashdot.org\">Slashdot</a>. Incidentally, Slashdot invented the web log format, which has since become very popular on news oriented sites.\r\n<li><b>Photo Gallery</b> - Creates a matrix of thumbnails that can be clicked on to view the full image.\r\n</ul>\r\n\r\n<b>Who can approve?</b><br>\r\nWhat group is allowed to approve and deny content?\r\n<br><br>\r\n\r\n<b>Who can contribute?</b><br>\r\nWhat group is allowed to contribute content?\r\n<br><br>\r\n\r\n<b>Submissions Per Page</b><br>\r\nHow many submissions should be listed per page in the submissions index?\r\n<br><br>\r\n\r\n<b>Default Status</b><br>\r\nShould submissions be set to <i>Approved</i>, <i>Pending</i>, or <i>Denied</i> by default?\r\n<br><br>\r\n<i>Note:</i> If you set the default status to Pending, then be prepared to monitor your message log for new submissions.\r\n<p>\r\n\r\n<b>Display thumbnails?</b><br>\r\nIf there is an image present in the submission, the thumbnail will be displayed in the Layout (see above).\r\n<p>\r\n\r\n<b>Allow discussion?</b><br>\r\nDo you wish to attach a discussion to this user submission system? If you do, users will be able to comment on each submission.\r\n<p>\r\n\r\n<b>Edit Timeout</b><br>\r\nHow long (in hours) will you allow discussion responses to be editable? You shouldn\'t let this get too long or the true opinions of people will not be captured.\r\n<p>\r\n\r\n<b>Group To Post</b><br>\r\nWhich group of users should be allowed to contribute to the discussion?\r\n<p>\r\n\r\n<b>Group to Moderate</b><br>\r\nWhich group of users should be allowed to moderate the discussion?','1,2,3,4,5');
INSERT INTO help VALUES (24,'WebGUI','English','Edit','Miscellaneous Settings','<b>Prevent Proxy Caching</b><br>\r\nSome companies have proxy servers that cause problems with WebGUI. If you\'re experiencing problems with WebGUI, and you have a proxy server, you may want to set this setting to <i>Yes</i>. Beware that WebGUI\'s URLs will not be as user-friendly after this feature is turned on.\r\n\r\n\r\n<p>\r\n<b>On Critical Error</b><br>\r\nWhat do you want WebGUI to do if a critical error occurs. It can be a security risk to show debugging information, but you may want to show it if you are in development.\r\n\r\n','6');
INSERT INTO help VALUES (11,'WebGUI','English','Edit','File Settings','<b>Path to WebGUI Extras</b><br>\r\nThe web-path to the directory containing WebGUI images and javascript files.\r\n<br><br>\r\n\r\n<b>Maximum Attachment Size</b><br>\r\nThe maximum size of files allowed to be uploaded to this site. This applies to all wobjects that allow uploaded files and images (like Article and User Contributions). This size is measured in kilobytes.\r\n<br><br>\r\n\r\n<b>Thumbnail Size</b><br>\r\nThe size of the longest side of thumbnails. The thumbnail generation maintains the aspect ratio of the image. Therefore, if this value is set to 100, and you have an image that\'s 400 pixels wide and 200 pixels tall, the thumbnail will be 100 pixels wide and 50 pixels tall.\r\n<p>\r\n<i>Note:</i> Thumbnails are automatically generated as images are uploaded to the system.\r\n<p>\r\n\r\n<b>Web Attachment Path</b><br>\r\nThe web-path of the directory where attachments are to be stored.\r\n<br><br>\r\n\r\n<b>Server Attachment Path</b><br>\r\nThe local path of the directory where attachments are to be stored. (Perhaps /var/www/public/uploads) Be sure that the web server has the rights to write to that directory.\r\n','6');
INSERT INTO help VALUES (1,'FAQ','English','Add/Edit','FAQ','It seems that almost every web site, intranet, and extranet in the world has a Frequently Asked Questions area. This wobject helps you build one, too.\r\n<br><br>\r\n\r\n<b>Turn TOC on?</b><br>\r\nDo you wish to display a TOC (or Table of Contents) for this FAQ? A TOC is a list of links (questions) at the top of the FAQ that link down the answers.\r\n<p>\r\n\r\n<b>Turn Q/A on?</b><br>\r\nSome people wish to display a <b>Q:</b> in front of each question and an <b>A:</b> in front of each answer. This switch enables that.\r\n<p>\r\n\r\n<b>Turn [top] link on?</b><br>\r\nDo you wish to display a link after each answer that takes you back to the top of the page?\r\n<p>\r\n\r\n<b>Proceed to add question?</b><br>\r\nLeave this checked if you want to add questions to the FAQ directly after creating it.\r\n<br><br>\r\n\r\n<hr size=1>\r\n<i><b>Note:</b></i> The following style is specific to the FAQ.\r\n<br><br>\r\n<b>.faqQuestion</b><br>\r\nAn F.A.Q. question. To distinguish it from an answer.\r\n\r\n','1,2,3,4,5');
INSERT INTO help VALUES (13,'WebGUI','English','Edit','Mail Settings','<b>Recover Password Message</b><br>\r\nThe message that gets sent to a user when they use the \"recover password\" function.\r\n<br><br>\r\n<b>SMTP Server</b><br>\r\nThis is the address of your local mail server. It is needed for all features that use the Internet email system (such as password recovery).\r\n\r\n','6');
INSERT INTO help VALUES (1,'SyndicatedContent','English','Add/Edit','Syndicated Content','Syndicated content is content that is pulled from another site using the RDF/RSS specification. This technology is often used to pull headlines from various news sites like <a href=\"http://www.cnn.com\">CNN</a> and  <a href=\"http://slashdot.org\">Slashdot</a>. It can, of course, be used for other things like sports scores, stock market info, etc.\r\n<br><br>\r\n\r\n<b>URL to RSS file</b><br>\r\nProvide the exact URL (starting with http://) to the syndicated content\'s RDF or RSS file. The syndicated content will be downloaded from this URL hourly.\r\n<br><br>\r\nYou can find syndicated content at the following locations:\r\n<ul>\r\n<li><a href=\"http://www.newsisfree.com\">http://www.newsisfree.com</a>\r\n<li><a href=\"http://www.syndic8.com\">http://www.syndic8.com</a>\r\n<li><a href=\"http://www.voidstar.com/node.php?id=144\">http://www.voidstar.com/node.php?id=144</a>\r\n<li><a href=\"http://my.userland.com\">http://my.userland.com</a>\r\n<li><a href=\"http://www.webreference.com/services/news/\">http://www.webreference.com/services/news/</a>\r\n<li><a href=\"http://www.xmltree.com\">http://www.xmltree.com</a>\r\n<li><a href=\"http://w.moreover.com/\">http://w.moreover.com/</a>\r\n</ul>','1,2,3,4,5');
INSERT INTO help VALUES (1,'EventsCalendar','English','Add/Edit','Events Calendar','Events calendars are used on many intranets to keep track of internal dates that affect a whole organization. Also, Events Calendars on consumer sites are a great way to let your customers know what events you\'ll be attending and what promotions you\'ll be having.\r\n<br><br>\r\n\r\n<b>Display Layout</b><br>\r\nThis can be set to <i>List</i> or <i>Calendar</i>. When set to <i>List</i> the events will be listed by date of occurence (and events that have already passed will not be displayed). This type of layout is best suited for Events Calendars that have only a few events per month. When set to <i>Calendar</i> the Events Calendar will display a traditional monthly Calendar, which can be paged through month-by-month. This type of layout is generally used when there are many events in each month.\r\n<br><br>\r\n\r\n<b>Paginate After</b><br>\r\nWhen using the list layout, how many events should be shown per page?\r\n<br><br>\r\n<b>Proceed to add event?</b><br>\r\nLeave this set to yes if you want to add events to the Events Calendar directly after creating it.\r\n<br><br>\r\n\r\n<i>Note:</i> Events that have already happened will not be displayed on the events calendar.\r\n<br><br>\r\n<hr size=1>\r\n<i><b>Note:</b></i> The following style is specific to the Events Calendar.\r\n<br><br>\r\n<b>.eventTitle </b><br>\r\nThe title of an individual event.\r\n\r\n','1,2,3,4,5');
INSERT INTO help VALUES (1,'MessageBoard','English','Add/Edit','Message Board','Message boards, also called Forums and/or Discussions, are a great way to add community to any site or intranet. Many companies use message boards internally to collaborate on projects.\r\n<br><br>\r\n<b>Who can post?</b><br>\r\nWhat group can post to this Message Board?\r\n<br><br>\r\n<b>Messages Per Page</b><br>\r\nWhen a visitor first comes to a message board s/he will be presented with a listing of all the topics (a.k.a. threads) of the Message Board. If a board is popular, it will quickly have many topics. The Messages Per Page attribute allows you to specify how many topics should be shown on one page.\r\n<br><br>\r\n<b>Edit Timeout</b><br>\r\nEdit Timeout specifies how long a user\'s message will be available for him/her to edit. Edit Timeout is measured in hours.\r\n<br><br>\r\n<i>Note:</i> Don\'t set this limit too high. One of the great things about message boards is that they are an accurate record of a discussion. If you allow editing for a long time, then a user has a chance to go back and change his/her mind a long time after the original statement was made.\r\n','1,2,3,4,5');
INSERT INTO help VALUES (1,'LinkList','English','Add/Edit','Link List','Link Lists are just what they sound like, a list of links. Many sites have a links section, and this wobject just automates the process.\r\n<br><br>\r\n\r\n<b>Indent</b><br>\r\nHow many characters should indent each link?\r\n<p>\r\n\r\n<b>Line Spacing</b><br>\r\nHow many carriage returns should be placed between each link?\r\n<p>\r\n\r\n\r\n<b>Bullet</b><br>\r\nSpecify what bullet should be used before each line item. You can leave this blank if you want to. You can also specify HTML bullets like &amp;middot; and &amp;raquo;. You can even use images from the image manager by specifying a macro like this ^I(bullet);.\r\n<p>\r\n\r\n\r\n<b>Proceed to add link?</b><br>\r\nLeave this set to yes if you want to add links to the Link List directly after creating it.\r\n<br><br>\r\n\r\n<b>Style</b><br>\r\nAn extra StyleSheet class has been added to this wobject: <b>.linkTitle</b>.  Use this to bold, colorize, or otheriwise manipulate the title of each link.\r\n<p>','1,2,3,4,5');
INSERT INTO help VALUES (21,'WebGUI','English','Using','Wobject','Wobjects (fomerly known as Wobjects) are the true power of WebGUI. Wobjects are tiny pluggable applications built to run under WebGUI. Message boards and polls are examples of wobjects.\r\n<p>\r\nTo add a wobject to a page, first go to that page, then select <i>Add Content...</i> from the upper left corner of your screen. Each wobject has it\'s own help so be sure to read the help if you\'re not sure how to use it.\r\n','0');
INSERT INTO help VALUES (1,'Article','English','Add/Edit','Article','Articles are the Swiss Army knife of WebGUI. Most pieces of static content can be added via the Article.\r\n<br><br>\r\n<b>Image</b><br>\r\nChoose an image (.jpg, .gif, .png) file from your hard drive. This file will be uploaded to the server and displayed in your article.\r\n<br><br>\r\n\r\n<b>Align Image</b><br>\r\nChoose where you\'d like to position the image specified above.\r\n<p>\r\n\r\n<b>Attachment</b><br>\r\nIf you wish to attach a word processor file, a zip file, or any other file for download by your users, then choose it from your hard drive.\r\n<br><br>\r\n\r\n<b>Link Title</b><br>\r\nIf you wish to add a link to your article, enter the title of the link in this field. \r\n<br><br>\r\n<i>Example:</i> Google\r\n<br><br>\r\n\r\n<b>Link URL</b><br>\r\nIf you added a link title, now add the URL (uniform resource locator) here. \r\n<br><br>\r\n<i>Example:</i> http://www.google.com\r\n\r\n<br><br>\r\n<b>Convert carriage returns?</b><br>\r\nIf you\'re publishing HTML there\'s generally no need to check this option, but if you aren\'t using HTML and you want a carriage return every place you hit your \"Enter\" key, then check this option.\r\n<p>\r\n\r\n<b>Allow discussion?</b><br>\r\nChecking this box will enable responses to your article much like Articles on Slashdot.org.\r\n<p>\r\n\r\n<b>Who can post?</b><br>\r\nSelect the group that is allowed to respond to this article. By default it is registered users.\r\n<p>\r\n\r\n<b>Who can moderate?</b><br>\r\nSelect the group that is allowed to moderate the responses to this article. By default it is content managers.\r\n<p>\r\n\r\n<b>Edit Timeout</b><br>\r\nHow long (in hours) should a user be able to edit their response before editing is locked to them?\r\n','1,2,3,4,5');
INSERT INTO help VALUES (1,'ExtraColumn','English','Add/Edit','Extra Column','Extra columns allow you to change the layout of your page for one page only. If you wish to have multiple columns on all your pages, perhaps you should consider altering the <i>style</i> applied to your pages or use a Template instead of an Extra Column. \r\n<br><br>\r\nColumns are always added from left to right. Therefore any existing content will be on the left of the new column.\r\n<br><br>\r\n<b>Spacer</b><br>\r\nSpacer is the amount of space between your existing content and your new column. It is measured in pixels.\r\n<br><br>\r\n<b>Width</b><br>\r\nWidth is the actual width of the new column to be added. Width is measured in pixels.\r\n<br><br>\r\n<b>StyleSheet Class</b><br>\r\nBy default the <i>content</i> style (which is the style the body of your site should be using) that is applied to all columns. However, if you\'ve created a style specifically for columns, then feel free to modify this class.\r\n','1,2,3,4,5');
INSERT INTO help VALUES (27,'WebGUI','English','Add/Edit','Wobject','You can add wobjects by selecting from the <i>Add Content</i> pulldown menu. You can edit them by clicking on the \"Edit\" button that appears directly above an instance of a particular wobject.\r\n<p>\r\nAlmost all wobjects share some properties. Those properties are:\r\n\r\n<b>Wobject ID</b><br>\r\nThis is the unique identifier WebGUI uses to keep track of this wobject instance. Normal users should never need to be concerned with the Wobject ID, but some advanced users may need to know it for things like SQL Reports.\r\n<p>\r\n\r\n<b>Title</b>\r\nThe title of the wobject. This is typically displayed at the top of each wobject.\r\n<p>\r\n<i>Note:</i> You should always specify a title even if you are going to turn it off (with the next property). This is because the title shows up in the trash and clipboard and you\'ll want to be able to distinguish which wobject is which.\r\n<p>\r\n\r\n<b>Display title?</b><br>\r\nDo you wish to display the title you specified? On some sites, displaying the title is not necessary.\r\n<p>\r\n\r\n<b>Process macros?</b><br>\r\nDo you wish to process macros in the content of this wobject? Sometimes you\'ll want to do this, but more often than not you\'ll want to say \"no\" to this question. By disabling the processing of macros on the wobjects that don\'t use them, you\'ll speed up your web server slightly.\r\n<p>\r\n\r\n<b>Template Position</b><br>\r\nTemplate positions range from 0 (zero) to any number. How many are available depends upon the Template associated with this page. The default template has only one template position, others may have more. By selecting a template position, you\'re specifying where this wobject should be placed within the template.\r\n<p>\r\n\r\n<b>Start Date</b><br>\r\nOn what date should this wobject become visible? Before this date, the wobject will only be displayed to Content Managers.\r\n<p>\r\n\r\n<b>End Date</b><br>\r\nOn what date should this wobject become invisible? After this date, the wobject will only be displayed to Content Managers.\r\n<p>\r\n\r\n<b>Description</b><br>\r\nA content area in which you can place as much content as you wish. For instance, even before an FAQ there is usually a paragraph describing what is contained in the FAQ.\r\n<p>','0');
INSERT INTO help VALUES (1,'Poll','English','Add/Edit','Poll','Polls can be used to get the impressions of your users on various topics.\r\n<br><br>\r\n<b>Active</b><br>\r\nIf this box is checked, then users will be able to vote. Otherwise they\'ll only be able to see the results of the poll.\r\n<br><br>\r\n<b>Who can vote?</b><br>\r\nChoose a group that can vote on this Poll.\r\n<br><br>\r\n<b>Graph Width</b><br>\r\nThe width of the poll results graph. The width is measured in pixels.\r\n<br><br>\r\n<b>Question</b><br>\r\nWhat is the question you\'d like to ask your users?\r\n<br><br>\r\n<b>Answers</b><br>\r\nEnter the possible answers to your question. Enter only one answer per line. Polls are only capable of 20 possible answers.\r\n<br><br>\r\n<b>Reset votes.</b><br>\r\nReset the votes on this Poll.\r\n<br><br>\r\n<hr size=1>\r\n<i><b>Note:</b></i> The following style sheet entries are custom to the Poll wobject:\r\n<br><br>\r\n<b>.pollAnswer </b><br>\r\nAn answer on a poll.\r\n<br><br>\r\n<b>.pollColor </b>\r\nThe color of the percentage bar on a poll.\r\n<br><br>\r\n<b>.pollQuestion </b>\r\nThe question on a poll.\r\n\r\n','1,2,3,4,5');
INSERT INTO help VALUES (1,'SiteMap','English','Add/Edit','Site Map','Site maps are used to provide additional navigation in WebGUI. You could set up a traditional site map that would display a hierarchical view of all the pages in the site. On the other hand, you could use site maps to provide extra navigation at certain levels in your site.\r\n<br><br>\r\n\r\n<b>Display synopsis?</b><br>\r\nDo you wish to display page sysnopsis along-side the links to each page? Note that in order for this option to be valid, pages must have synopsis defined.\r\n<br><br>\r\n\r\n<b>Starting from this level?</b><br>\r\nIf the Site Map should display the page tree starting from this level, then check this box. If you wish the Site Map to start from the home page then uncheck it.\r\n<br><br>\r\n\r\n<b>Depth To Traverse</b><br>\r\nHow many levels deep of navigation should the Site Map show? If 0 (zero) is specified, it will show as many levels as there are.\r\n<p>\r\n\r\n<b>Indent</b<br>\r\nHow many characters should indent each level?\r\n<p>\r\n\r\n<b>Bullet</b><br>\r\nSpecify what bullet should be used before each line item. You can leave this blank if you want to. You can also specify HTML bullets like &amp;middot; and &amp;raquo;. You can even use images from the image manager by specifying a macro like this ^I(bullet);.\r\n<p>\r\n\r\n<b>Line Spacing</b><br>\r\nSpecify how many carriage returns should go between each item in the Site Map. This should be set to 1 or higher.\r\n<p>','1,2,3,4,5');
INSERT INTO help VALUES (1,'SQLReport','English','Add/Edit','SQL Report','SQL Reports are perhaps the most powerful wobject in the WebGUI arsenal. They allow a user to query data from any database that they have access to. This is great for getting sales figures from your Accounting database or even summarizing all the message boards on your web site.\r\n<p>\r\n\r\n<b>Preprocess macros on query?</b><br>\r\nIf you\'re using WebGUI macros in your query you\'ll want to check this box.\r\n<p>\r\n\r\n<b>Debug?</b><br>\r\nIf you want to display debugging and error messages on the page, check this box.\r\n<p>\r\n\r\n<b>Query</b><br>\r\nThis is a standard SQL query. If you are unfamiliar with SQL, <a href=\"http://www.plainblack.com\">Plain Black Software</a> provides training courses in SQL and database management. You can make your queries more dynamic by using the ^FormParam(); macro.\r\n<p>\r\n\r\n<b>Report Template</b><br>\r\nLayout a template of how this report should look. Usually you\'ll use HTML tables to generate a report. An example is included below. If you leave this field blank a template will be generated based on your result set.\r\n<p>\r\n\r\nThere are special macro characters used in generating SQL Reports. They are ^-;, ^0;, ^1;, ^2;, ^3;, etc. These macros will be processed regardless of whether you checked the process macros box above. The ^- macro represents split points in the document where the report will begin and end looping. The numeric macros represent the data fields that will be returned from your query. There is an additional macro, ^rownum; that counts the rows of the query starting at 1 for use where the lines of the output need to be numbered.\r\n<p>\r\n<pre>\r\n<i>Sample Template:</i>\r\n&lt;table&gt;\r\n&lt;tr&gt;&lt;th&gt;Employee Name&lt;/th&gt;&lt;th&gt;Employee #&lt;/th&gt;&lt;th&gt;Vacation Days Remaining&lt;/th&gt;&lt;th&gt;Monthly Salary&lt;/th&gt;&lt;/tr&gt;\r\n^-;\r\n&lt;tr&gt;&lt;td&gt;^0;&lt;/td&gt;&lt;td&gt;^1;&lt;/td&gt;&lt;td&gt;^2;&lt;/td&gt;&lt;td&gt;^3;&lt;/td&gt;&lt;/tr&gt;\r\n^-;\r\n&lt;/table&gt;\r\n</pre>\r\n<b>DSN</b><br>\r\n<b>D</b>ata <b>S</b>ource <b>N</b>ame is the unique identifier that Perl uses to describe the location of your database. It takes the format of DBI:[driver]:[database name]:[host]. \r\n<p>\r\n\r\n<i>Example:</i> DBI:mysql:WebGUI:localhost\r\n<p>\r\n\r\n<b>Database User</b>\r\nThe username you use to connect to the DSN.\r\n<p>\r\n\r\n<b>Database Password</b>\r\nThe password you use to connect to the DSN.\r\n<p>\r\n\r\n<b>Paginate After</b>\r\nHow many rows should be displayed before splitting the results into separate pages? In other words, how many rows should be displayed per page?\r\n<p>\r\n\r\n<b>Convert carriage returns?</b>\r\nDo you wish to convert the carriage returns in the resultant data to HTML breaks (&lt;br&gt;).\r\n','1,2,3,4,5');
INSERT INTO help VALUES (19,'WebGUI','English','Using','Macros','WebGUI macros are used to create dynamic content within otherwise static content. For instance, you may wish to show which user is logged in on every page, or you may wish to have a dynamically built menu or crumb trail. \r\n<p>\r\nMacros always begin with a carat (^) and follow with at least one other character and ended with w semicolon (;). Some macros can be extended/configured by taking the format of ^<i>x</i>(\"<b>config text</b>\");. The following is a description of all the macros in the WebGUI system.\r\n<p>\r\n\r\n<b>^a; or ^a(); - My Account Link</b><br>\r\nA link to your account information. In addition you can change the link text by creating a macro like this <b>^a(\"Account Info\");</b>. \r\n<p>\r\n<i>Notes:</i> You can also use the special case ^a(linkonly); to return only the URL to the account page and nothing more. Also, the .myAccountLink style sheet class is tied to this macro.\r\n<p>\r\n\r\n<b>^AdminBar;</b><br>\r\nPlaces the administrative tool bar on the page. This is a required element in the \"body\" segment of the Style Manager.\r\n<p>\r\n\r\n<b>^AdminToggle;</b><br>\r\nPlaces a link on the page which is only visible to content managers and adminstrators. The link toggles on/off admin mode.\r\n<p>\r\n\r\n<b>^C; or ^C(); - Crumb Trail</b><br>\r\nA dynamically generated crumb trail to the current page. You can optionally specify a delimeter to be used between page names by using ^C(::);. The default delimeter is &gt;.\r\n<p>\r\n<i>Note:</i> The .crumbTrail style sheet class is tied to this macro.\r\n<p>\r\n\r\n<b>^c; - Company Name</b><br>\r\nThe name of your company specified in the settings by your Administrator.\r\n<p>\r\n\r\n<b>^D; or ^D(); - Date</b><br>\r\nThe current date and time.\r\n<p>\r\nYou can configure the date by using date formatting symbols. For instance, if you created a macro like this <b>^D(\"%c %D, %y\");</b> it would output <b>September 26, 2001</b>. The following are the available date formatting symbols:\r\n<table>\r\n<tr><td>%%</td><td>%</td></tr>\r\n<tr><td>%y</td><td>4 digit year</td></tr>\r\n<tr><td>%Y</td><td>2 digit year</td></tr>\r\n<tr><td>%m</td><td>2 digit month</td></tr>\r\n<tr><td>%M</td><td>variable digit month</td></tr>\r\n<tr><td>%c</td><td>month name</td></tr>\r\n<tr><td>%d</td><td>2 digit day of month</td></tr>\r\n<tr><td>%D</td><td>variable digit day of month</td></tr>\r\n<tr><td>%w</td><td>day of week name</td></tr>\r\n<tr><td>%h</td><td>2 digit base 12 hour</td></tr>\r\n<tr><td>%H</td><td>variable digit base 12 hour</td></tr>\r\n<tr><td>%j</td><td>2 digit base 24 hour</td></tr>\r\n<tr><td>%J</td><td>variable digit base 24 hour</td></tr>\r\n<tr><td>%p</td><td>lower case am/pm</td></tr>\r\n<tr><td>%P</td><td>upper case AM/PM</td></tr>\r\n</table>\r\n<p>\r\n\r\n<b>^e; - Company Email Address</b><br>\r\nThe email address for your company specified in the settings by your Administrator.\r\n<p>\r\n\r\n<b>^Env()</b><br>\r\nCan be used to display a web server environment variable on a page. The environment variables available on each server are different, but you can find out which ones your web server has by going to: http://www.yourwebguisite.com/env.pl\r\n<p>\r\nThe macro should be specified like this ^Env(\"REMOTE_ADDR\");\r\n<p>\r\n\r\n<b>^Execute();</b><br>\r\nAllows a content manager or administrator to execute an external program. Takes the format of <b>^Execute(\"/this/file.sh\");</b>.\r\n<p>\r\n\r\n<b>^Extras;</b><br>\r\nReturns the path to the WebGUI \"extras\" folder, which contains things like WebGUI icons.\r\n<p>\r\n\r\n<b>^FlexMenu;</b><br>\r\nThis menu macro creates a top-level menu that expands as the user selects each menu item.\r\n<p>\r\n\r\n<b>^FormParam();</b><br>\r\nThis macro is mainly used in generating dynamic queries in SQL Reports. Using this macro you can pull the value of any form field simply by specifing the name of the form field, like this: ^FormParam(\"phoneNumber\");\r\n<p>\r\n\r\n<b>^H; or ^H(); - Home Link</b><br>\r\nA link to the home page of this site.  In addition you can change the link text by creating a macro like this <b>^H(\"Go Home\");</b>.\r\n<p>\r\n<i>Notes:</i> You can also use the special case ^H(linkonly); to return only the URL to the home page and nothing more. Also, the .homeLink style sheet class is tied to this macro.\r\n<p>\r\n\r\n<b>^I(); - Image Manager Image with Tag</b><br>\r\nThis macro returns an image tag with the parameters for an image defined in the image manager. Specify the name of the image using a tag like this <b>^I(\"imageName\")</b>;.\r\n<p>\r\n\r\n<b>^i(); - Image Manager Image Path</b><br>\r\nThis macro returns the path of an image uploaded using the Image Manager. Specify the name of the image using a tag like this <b>^i(\"imageName\");</b>.\r\n<p>\r\n\r\n<b>^Include();</b><br>\r\nAllows a content manager or administrator to include a file from the local filesystem. Takes the format of <b>^Include(\"/this/file.html\")</b>;\r\n<p>\r\n\r\n<b>^L; or ^L(); - Login</b><br>\r\nA small login form. You can also configure this macro. You can set the width of the login box like this ^L(20);. You can also set the message displayed after the user is logged in like this ^L(20,Hi ^a(^@;);. Click %here% if you wanna log out!)\r\n<p>\r\n<i>Note:</i> The .loginBox style sheet class is tied to this macro.\r\n<p>\r\n\r\n<b>^M; or ^M(); - Current Menu (Vertical)</b><br>\r\nA vertical menu containing the sub-pages at the current level. In addition, you may configure this macro by specifying how many levels deep the menu should go. By default it will show only the first level. To go three levels deep create a macro like this <b>^M(3);</b>. If you set the macro to \"0\" it will track the entire site tree.\r\n<p>\r\n\r\n<b>^m; - Current Menu (Horizontal)</b><br>\r\nA horizontal menu containing the sub-pages at the current level. You can optionally specify a delimeter to be used between page names by using ^m(:--:);. The default delimeter is &middot;.\r\n<p>\r\n\r\n<b>^P; or ^P(); - Previous Menu (Vertical)</b><br>\r\nA vertical menu containing the sub-pages at the previous level. In addition, you may configure this macro by specifying how many levels deep the menu should go. By default it will show only the first level. To go three levels deep create a macro like this <b>^P(3);</b>. If you set the macro to \"0\" it will track the entire site tree.\r\n<p>\r\n\r\n<b>^p; - Previous Menu (Horizontal)</b><br>\r\nA horizontal menu containing the sub-pages at the previous level. You can optionally specify a delimeter to be used between page names by using ^p(:--:);. The default delimeter is &middot;.\r\n<p>\r\n\r\n<b>^Page();</b><br>\r\nThis can be used to retrieve information about the current page. For instance it could be used to get the page URL like this ^Page(\"urlizedTitle\"); or to get the menu title like this ^Page(\"menuTitle\");.\r\n<p>\r\n\r\n<b>^PageTitle;</b><br>\r\nDisplays the title of the current page.\r\n<p>\r\n<i>Note:</i> If you begin using admin functions or the indepth functions of any wobject, the page title will become a link that will quickly bring you back to the page.\r\n<p>\r\n\r\n<b>^r; or ^r(); - Make Page Printable</b><br>\r\nCreates a link to remove the style from a page to make it printable.  In addition, you can change the link text by creating a macro like this <b>^r(\"Print Me!\");</b>.\r\n<p>\r\nBy default, when this link is clicked, the current page\'s style is replaced with the \"Make Page Printable\" style in the Style Manager. However, that can be overridden by specifying the name of another style as the second parameter, like this: ^r(\"Print!\",\"WebGUI\");\r\n<p>\r\n<i>Notes:</i> You can also use the special case ^r(linkonly); to return only the URL to the make printable page and nothing more. Also, the .makePrintableLink style sheet class is tied to this macro.\r\n<p>\r\n\r\n<b>^RootTitle;</b><br>\r\nReturns the title of the root of the current page. For instance, the main root in WebGUI is the \"Home\" page. Many advanced sites have many roots and thus need a way to display to the user which root they are in.\r\n<p>\r\n\r\n<b>^S(); - Specific SubMenu (Vertical)</b><br>\r\nThis macro allows you to get the submenu of any page, starting with the page you specified. For instance, you could get the home page submenu by creating a macro that looks like this <b>^S(\"home\",0);</b>. The first value is the urlized title of the page and the second value is the depth you\'d like the menu to go. By default it will show only the first level. To go three levels deep create a macro like this <b>^S(\"home\",3);</b>.\r\n<p>\r\n\r\n<b>^s(); - Specific SubMenu (Horizontal)</b><br>\r\nThis macro allows you to get the submenu of any page, starting with the page you specified. For instance, you could get the home page submenu by creating a macro that looks like this <b>^s(\"home\");</b>. The value is the urlized title of the page.  You can optionally specify a delimeter to be used between page names by using ^s(\"home\",\":--:\");. The default delimeter is &middot;.\r\n<p>\r\n\r\n<b>^Synopsis; or ^Synopsis(); Menu</b><br>\r\nThis macro allows you to get the submenu of a page along with the synopsis of each link. You may specify an integer to specify how many levels deep to traverse the page tree.\r\n<p>\r\n<i>Notes:</i> The .synopsis_sub, .synopsis_summary, and .synopsis_title style sheet classes are tied to this macro.\r\n<p>\r\n\r\n<b>^T; or ^T(); - Top Level Menu (Vertical)</b><br>\r\nA vertical menu containing the main pages of the site (aka the sub-pages from the home page). In addition, you may configure this macro by specifying how many levels deep the menu should go. By default it will show only the first level. To go three levels deep create a macro like this <b>^T(3);</b>. If you set the macro to \"0\" it will track the entire site tree.\r\n<p>\r\n\r\n<b>^t; - Top Level Menu (Horizontal)</b><br>\r\nA vertical menu containing the main pages of the site (aka the sub-pages from the home page). You can optionally specify a delimeter to be used between page names by using ^t(:--:);. The default delimeter is &middot;.\r\n<p>\r\n\r\n<b>^Thumbnail();</b><br>\r\nReturns the URL of a thumbnail for an image from the image manager. Specify the name of the image like this <b>^Thumbnail(\"imageName\");</b>.\r\n<p>\r\n\r\n<b>^ThumbnailLinker();</b><br>\r\nThis is a good way to create a quick and dirty screenshots page or a simple photo gallery. Simply specify the name of an image in the Image Manager like this: ^ThumbnailLinker(\"My Grandmother\"); and this macro will create a thumnail image with a title under it that links to the full size version of the image.\r\n<p>\r\n\r\n<b>^u; - Company URL</b><br>\r\nThe URL for your company specified in the settings by your Administrator.\r\n<p>\r\n\r\n<b>^URLEncode();</b><br>\r\nThis macro is mainly useful in SQL reports, but it could be useful elsewhere as well. It takes the input of a string and URL Encodes it so that the string can be passed through a URL. It\'s syntax looks like this: ^URLEncode(\"Is this my string?\");\r\n\r\n<b>^/; - System URL</b><br>\r\nThe URL to the gateway script (including the domain for this site). This is often used within pages so that if your development server is on a domain different than your production server that your URLs will still worked when moved.\r\n<p>\r\n\r\n<b>^\\; - Page URL</b><br>\r\nThe URL to the current page (including the domain for this site). This is often used within pages so that if your development server is on a domain different than your production server that your URLs will still worked when moved.\r\n<p>\r\n\r\n<b>^@; - Username</b><br>\r\nThe username of the currently logged in user.\r\n<p>\r\n\r\n<b>^?; - Search</b><br>\r\nAdd a search box to the page. The search box is tied to WebGUI\'s built-in search engine.\r\n<p>\r\n<i>Note:</b> The .searchBox style sheet class is tied to this macro.\r\n<p>\r\n\r\n<b>^#; - User ID</b><br>\r\nThe user id of the currently logged in user.\r\n<p>\r\n\r\n<b>^*; or ^*(); - Random Number</b><br>\r\nA randomly generated number. This is often used on images (such as banner ads) that you want to ensure do not cache. In addition, you may configure this macro like this <b>^*(100);</b> to create a random number between 0 and 100.\r\n<p>\r\n\r\n<b>^-;,^0;,^1;,^2;,^3;, etc.</b><br>\r\nThese macros are reserved for system/wobject-specific functions as in the SQL Report wobject and the Body in the Style Manager.\r\n','0');
INSERT INTO help VALUES (18,'WebGUI','English','Using','Style Sheets','<a href=\"http://www.w3.org/Style/CSS/\">Cascading Style Sheets (CSS)</a> are a great way to manage the look and feel of any web site. They are used extensively in WebGUI.\r\n<p>\r\n\r\nIf you are unfamiliar with how to use CSS, <a href=\"http://www.plainblack.com\">Plain Black Software</a> provides training classes on XHTML and CSS. Alternatively, Bradsoft makes an excellent CSS editor called <a href=\"http://www.bradsoft.com/topstyle/index.asp\">Top Style</a>.\r\n<p>\r\n\r\nThe following is a list of classes used to control the look of WebGUI:\r\n<p>\r\n\r\n<b>A</b><br>\r\nThe links throughout the style.\r\n<p>\r\n\r\n<b>BODY</b><br>\r\nThe default setup of all pages within a style.\r\n<p>\r\n\r\n<b>H1</b><br>\r\nThe headers on every page.\r\n<p>\r\n\r\n<b>.accountOptions</b><br>\r\nThe links that appear under the login and account update forms.\r\n<p>\r\n\r\n<b>.adminBar </b><br>\r\nThe bar that appears at the top of the page when you\'re in admin mode.\r\n<p>\r\n\r\n<b>.content</b><br>\r\nThe main content area on all pages of the style.\r\n<p>\r\n\r\n<b>.formDescription </b><br>\r\nThe tags on all forms next to the form elements. \r\n<p>\r\n\r\n<b>.formSubtext </b><br>\r\nThe tags below some form elements.\r\n<p>\r\n\r\n<b>.highlight </b><br>\r\nDenotes a highlighted item, such as which message you are viewing within a list.\r\n<p>\r\n\r\n<b>.horizontalMenu </b><br>\r\nThe horizontal menu (if you use a horizontal menu macro).\r\n<p>\r\n\r\n<b>.pagination </b><br>\r\nThe Previous and Next links on pages with pagination.\r\n<p>\r\n\r\n<b>.selectedMenuItem</b><br>\r\nUse this class to highlight the current page in any of the menu macros.\r\n<p>\r\n\r\n<b>.tableData </b><br>\r\nThe data rows on things like message boards and user contributions.\r\n<p>\r\n\r\n<b>.tableHeader </b><br>\r\nThe headings of columns on things like message boards and user contributions.\r\n<p>\r\n\r\n<b>.tableMenu </b><br>\r\nThe menu on things like message boards and user submissions.\r\n<p>\r\n\r\n<b>.verticalMenu </b><br>\r\nThe vertical menu (if you use a vertical menu macro).\r\n<p>\r\n\r\n<i><b>Note:</b></i> Some wobjects and macros have their own unique styles sheet classes, which are documented in their individual help files.\r\n\r\n','0');
INSERT INTO help VALUES (17,'WebGUI','English','Add/Edit','Group','See <i>Manage Group</i> for a description of grouping functions and the default groups.\r\n<p>\r\n\r\n<b>Group Name</b><br>\r\nA name for the group. It is best if the name is descriptive so you know what it is at a glance.\r\n<p>\r\n\r\n<b>Description</b><br>\r\nA longer description of the group so that other admins and content managers (or you if you forget) will know what the purpose of this group is.\r\n\r\n<b>Expire After</b><br>\r\nThe time (in seconds) that a user will belong to this group before s/he is expired (or removed) from it. This is very useful for membership sites where users have certain privileges for a specific period of time. Note that this can be overridden on a per-user basis.','0');
INSERT INTO help VALUES (2,'WebGUI','English','Edit','User Settings','<b>Session Timeout</b><br>\r\nThe time (in seconds) that a user session remains active (before needing to log in again). This timeout is reset each time a visitor hits a page. Therefore if you set the timeout for 8 hours, a user would have to log in again if s/he hadn\'t visited the site for 8 hours.\r\n<p>\r\n\r\n1800 = half hour<br>\r\n3600 = 1 hour<br>\r\n28000 = 8 hours<br>\r\n86400 = 1 day<br>\r\n604800 = 1 week<br>\r\n1209600 = 2 weeks<br>\r\n<p>\r\n\r\n<b>Alert on new user?</b><br>\r\nShould someone be alerted when a new user registers anonymously?\r\n<p>\r\n\r\n<b>Group To Alert On New User</b>\r\nWhat group should be alerted when a new user registers?\r\n<p>\r\n\r\n<b>Anonymous Registration</b><br>\r\nDo you wish visitors to your site to be able to register themselves?\r\n<br><br>\r\n<b>Authentication Method (default)</b><br>\r\nWhat should the default authentication method be for new accounts that are created? The two available options are WebGUI and LDAP. WebGUI authentication means that the users will authenticate against the username and password stored in the WebGUI database. LDAP authentication means that users will authenticate against an external LDAP server.\r\n<br><br>\r\n<i>Note:</i> Authentication settings can be customized on a per user basis.\r\n<br><br>\r\n<b>Username Binding</b><br>\r\nBind the WebGUI username to the LDAP Identity. This requires the user to have the same username in WebGUI as they specified during the Anonymous Registration process. It also means that they won\'t be able to change their username later. This only in effect if the user is authenticating against LDAP.\r\n<br><br>\r\n<b>LDAP URL (default)</b><br>\r\nThe default url to your LDAP server. The LDAP URL takes the form of <b>ldap://[server]:[port]/[base DN]</b>. Example: ldap://ldap.mycompany.com:389/o=MyCompany.\r\n<br><br>\r\n<b>LDAP Identity</b><br>\r\nThe LDAP Identity is the unique identifier in the LDAP server that the user will be identified against. Often this field is <b>shortname</b>, which takes the form of first initial + last name. Example: jdoe. Therefore if you specify the LDAP identity to be <i>shortname</i> then Jon Doe would enter <i>jdoe</i> during the registration process.\r\n<br><br>\r\n<b>LDAP Identity Name</b><br>\r\nThe label used to describe the LDAP Identity to the user. For instance, some companies use an LDAP server for their proxy server users to authenticate against. In the documentation or training already provided to their users, the LDAP identity is known as their <i>Web Username</b>. So you could enter that label here for consitency.\r\n<br><br>\r\n<b>LDAP Password Name</b><br>\r\nJust as the LDAP Identity Name is a label, so is the LDAP Password Name. Use this label as you would LDAP Identity Name.\r\n\r\n','6');
INSERT INTO help VALUES (15,'WebGUI','English','Delete','Group','As the function suggests you\'ll be deleting a group and removing all users from the group. Be careful not to orphan users from pages they should have access to by deleting a group that is in use.\r\n<p>\r\n\r\nAs with any delete operation, you are prompted to be sure you wish to proceed with the delete. If you answer yes, the delete will proceed and there is no recovery possible. If you answer no you\'ll be returned to the prior screen.','0');
INSERT INTO help VALUES (16,'WebGUI','English','Add/Edit','Style','Styles are WebGUI macro enabled. See <i>Using Macros</i> for more information.\r\n<p>\r\n\r\n<b>Style Name</b><br>\r\nA unique name to describe what this style looks like at a glance. The name has no effect on the actual look of the style.\r\n<p>\r\n\r\n<b>Body</b><br>\r\nThe body is quite literally the HTML body of your site. It defines how the page navigation will be laid out and many other things like logo, copyright, etc. At bare minimum a body must consist of a few things. The following is that bare minimum:\r\n<pre>\r\n&lt;body&gt;\r\n^AdminBar;\r\n^-;\r\n&lt;/body^gt;\r\n</pre>\r\n<p>\r\n\r\nThe ^AdminBar; macro tells WebGUI where to display admin functions. The ^-; (splitter) macro tells WebGUI where to put the content of your page.\r\n<p>\r\n\r\nIf you are in need of assistance for creating a look for your site, or if you need help cutting apart your design, <a href=\"http://www.plainblack.com\">Plain Black Software</a> provides support services for a small fee.\r\n<p>\r\n\r\nMany people will add WebGUI macros to their body for automated navigation, and other features.\r\n<p>\r\n\r\n<b>Style Sheet</b><br>\r\nPlace your style sheet entries here. Style sheets are used to control colors, sizes, and other properties of the elements on your site. See <i>Using Style Sheets</i> for more information.\r\n<p>\r\n\r\n<i>Advanced Users:</i> for greater performance create your stylesheet on the file system (call it something like webgui.css) and add an entry like this to this area: \r\n&lt;link href=\"/webgui.css\" rel=\"stylesheet\" rev=\"stylesheet\" type=\"text/css\"&gt;','4,5');
INSERT INTO help VALUES (14,'WebGUI','English','Delete','Wobject','This function permanently deletes the selected wobject from a page. If you are unsure whether you wish to delete this content you may be better served to cut the content to the clipboard until you are certain you wish to delete it.\r\n<p>\r\n\r\nAs with any delete operation, you are prompted to be sure you wish to proceed with the delete. If you answer yes, the delete will proceed and there is no recovery possible. If you answer no you\'ll be returned to the prior screen.','0');
INSERT INTO help VALUES (12,'WebGUI','English','Manage','Settings','Settings are items that allow you to adjust WebGUI to your particular needs.\r\n<p>\r\n\r\n<b>Edit Authentication Settings</b><br>\r\nSettings concerning user identification and login, such as LDAP.\r\n<p>\r\n\r\n<b>Edit Company Information</b><br>\r\nInformation specific about the company or individual who controls this installation of WebGUI.\r\n<p>\r\n\r\n<b>Edit Content Settings</b><br>\r\nSettings related to content and content management.\r\n<p>\r\n\r\n<b>Edit File Settings</b><br>\r\nSettings concerning attachments and images.\r\n<p>\r\n\r\n<b>Edit Mail Settings</b><br>\r\nSettings concerning email and related functions.\r\n<p>\r\n\r\n<b>Edit Miscellaneous Settings</b><br>\r\nEverything else.\r\n\r\n<b>Edit Profile Settings</b><br>\r\nDefine what user profiles look like and what the users have the ability to edit.\r\n','7,8,9.10,11,12');
INSERT INTO help VALUES (10,'WebGUI','English','Manage','Group','Groups are used to subdivide privileges and responsibilities within the WebGUI system. For instance, you may be building a site for a classroom situation. In that case you might set up a different group for each class that you teach. You would then apply those groups to the pages that are designed for each class.\r\n<p>\r\n\r\nThere are several groups built into WebGUI. They are as follows:\r\n<p>\r\n\r\n<b>Admins</b><br>\r\nAdmins are users who have unlimited privileges within WebGUI. A user should only be added to the admin group if they oversee the system. Usually only one to three people will be added to this group.\r\n<p>\r\n\r\n<b>Content Managers</b><br>\r\nContent managers are users who have privileges to add, edit, and delete content from various areas on the site. The content managers group should not be used to control individual content areas within the site, but to determine whether a user can edit content at all. You should set up additional groups to separate content areas on the site.\r\n<p>\r\n\r\n<b>Everyone</b><br>\r\nEveryone is a magic group in that no one is ever physically inserted into it, but yet all members of the site are part of it. If you want to open up your site to both visitors and registered users, use this group to do it.\r\n<p>\r\n\r\n<b>Package Managers</b><br>\r\nUsers that have privileges to add, edit, and delete packages of wobjects and pages to deploy.\r\n<p>\r\n\r\n<b>Registered Users</b><br>\r\nWhen users are added to the system they are put into the registered users group. A user should only be removed from this group if their account is deleted or if you wish to punish a troublemaker.\r\n<p>\r\n\r\n<b>Style Managers</b><br>\r\nUsers that have privileges to edit styles for this site. These privileges do not allow the user to assign privileges to a page, just define them to be used.\r\n<p>\r\n\r\n<b>Template Managers</b><br>\r\nUsers that have privileges to edit templates for this site.\r\n<p>\r\n\r\n<b>Visitors</b><br>\r\nVisitors are users who are not logged in using an account on the system. Also, if you wish to punish a registered user you could remove him/her from the Registered Users group and insert him/her into the Visitors group.','0');
INSERT INTO help VALUES (8,'WebGUI','English','Manage','User','Users are the accounts in the system that are given rights to do certain things. There are two default users built into the system: Admin and Visitor.\r\n<p>\r\n\r\n<b>Admin</b><br>\r\nAdmin is exactly what you\'d expect. It is a user with unlimited rights in the WebGUI environment. If it can be done, this user has the rights to do it.\r\n<p>\r\n\r\n<b>Visitor</b><br>\r\nVisitor is exactly the opposite of Admin. Visitor has no rights what-so-ever. By default any user who is not logged in is seen as the user Visitor.\r\n<p>\r\n\r\n<b>Add a new user.</b><br>\r\nClick on this to go to the add user screen.\r\n<p>\r\n\r\n<b>Search</b><br>\r\nYou can search users based on username and email address. You can do partial searches too if you like.','0');
INSERT INTO help VALUES (9,'WebGUI','English','Manage','Style','Styles are used to manage the look and feel of your WebGUI pages. With WebGUI, you can have an unlimited number of styles, so your site can take on as many looks as you like. You could have some pages that look like your company\'s brochure, and some pages that look like Yahoo!&reg;. You could even have some pages that look like pages in a book. Using style management, you have ultimate control over all your designs.\r\n<p>\r\n\r\nThere are several styles built into WebGUI. The first of these are used by WebGUI can should not be edited or deleted. The last few are simply example styles and may be edited or deleted as you please.\r\n<p>\r\n\r\n<b>Clipboard</b><br>\r\nThis style is used by the clipboard system.\r\n<p>\r\n\r\n<b>Fail Safe</b><br>\r\nWhen you delete a style that is still in use on some pages, the Fail Safe style will be applied to those pages. This style has a white background and simple navigation.\r\n<p>\r\n\r\n<b>Make Page Printable</b><br>\r\nThis style is used if you place an <b>^r;</b> macro on your pages and the user clicks on it. This style allows you to put a simple logo and copyright message on your printable pages.\r\n<p>\r\n\r\n<b>Packages</b><br>\r\nThis style is used by the package management system.\r\n<p>\r\n\r\n<b>Trash</b><br>\r\nThis style is used by the trash system.\r\n<p>\r\n\r\n<hr size=\"1\">\r\n<p>\r\n\r\n<b>Demo Style</b><br>\r\nThis is a sample design taken from a templates site (www.freewebtemplates.com).\r\n<p>\r\n\r\n<b>Plain Black Software (black) &amp; (white)</b><br>\r\nThese designs are used on the Plain Black site.\r\n<p>\r\n\r\n<b>Yahoo!&reg;</b><br>\r\nThis is the design of the Yahoo!&reg; site. (Used without permission.)\r\n<p>\r\n\r\n<b>WebGUI</b><br>\r\nThis is a simple design featuring WebGUI logos.\r\n\r\n','4,5');
INSERT INTO help VALUES (7,'WebGUI','English','Delete','User','There is no need to ever actually delete a user. If you are concerned with locking out a user, then simply change their password. If you truely wish to delete a user, then please keep in mind that there are consequences. If you delete a user any content that they added to the site via wobjects (like message boards and user contributions) will remain on the site. However, if another user tries to visit the deleted user\'s profile they will get an error message. Also if the user ever is welcomed back to the site, there is no way to give him/her access to his/her old content items except by re-adding the user to the users table manually.\r\n<p>\r\n\r\nAs with any delete operation, you are prompted to be sure you wish to proceed with the delete. If you answer yes, the delete will proceed and there is no recovery possible. If you answer no you\'ll be returned to the prior screen.','0');
INSERT INTO help VALUES (32,'WebGUI','English','Edit','User Profile','<b>Email Address</b><br>\r\nThe user\'s email address. This must only be specified if the user will partake in functions that require email.\r\n<p>\r\n\r\n<b>Language</b><br>\r\nWhat language should be used to display system related messages.\r\n<p>\r\n\r\n<b>ICQ UIN</b><br>\r\nThe <a href=\"http://www.icq.com\">ICQ</a> UIN is the \"User ID Number\" on the ICQ network. ICQ is a very popular instant messaging platform.\r\n','0');
INSERT INTO help VALUES (5,'WebGUI','English','Add/Edit','User','See <b>Manage Users</b> for additional details.\r\n<p>\r\n\r\n<b>Username</b><br>\r\nUsername is a unique identifier for a user. Sometimes called a handle, it is also how the user will be known on the site. (<i>Note:</i> Administrators have unlimited power in the WebGUI system. This also means they are capable of breaking the system. If you rename or create a user, be careful not to use a username already in existance.)\r\n<p>\r\n\r\n<b>Password</b><br>\r\nA password is used to ensure that the user is who s/he says s/he is.\r\n<p>\r\n\r\n<b>Authentication Method</b><br>\r\nSee <i>Edit Settings</i> for details.\r\n<p>\r\n\r\n<b>LDAP URL</b><br>\r\nSee <i>Edit Settings</i> for details.\r\n<p>\r\n\r\n<b>Connect DN</b><br>\r\nThe Connect DN is the <b>cn</b> (or common name) of a given user in your LDAP database. It should be specified as <b>cn=John Doe</b>. This is, in effect, the username that will be used to authenticate this user against your LDAP server.\r\n<p>\r\n\r\n\r\n\r\n','0');
INSERT INTO help VALUES (3,'WebGUI','English','Delete','Page','Deleting a page can create a big mess if you are uncertain about what you are doing. When you delete a page you are also deleting the content it contains, all sub-pages connected to this page, and all the content they contain. Be certain that you have already moved all the content you wish to keep before you delete a page.\r\n<p>\r\nAs with any delete operation, you are prompted to be sure you wish to proceed with the delete. If you answer yes, the delete will proceed and there is no recovery possible. If you answer no you\'ll be returned to the prior screen.','0');
INSERT INTO help VALUES (4,'WebGUI','English','Delete','Style','When you delete a style all pages using that style will be reverted to the fail safe (default) style. To ensure uninterrupted viewing, you should be sure that no pages are using a style before you delete it.\r\n<p>\r\n\r\nAs with any delete operation, you are prompted to be sure you wish to proceed with the delete. If you answer yes, the delete will proceed and there is no recovery possible. If you answer no you\'ll be returned to the prior screen.','4,5');
INSERT INTO help VALUES (1,'WebGUI','English','Add/Edit','Page','Think of pages as containers for content. For instance, if you want to write a letter to the editor of your favorite magazine you\'d get out a notepad (or open a word processor) and start filling it with your thoughts. The same is true with WebGUI. Create a page, then add your content to the page.\r\n<p>\r\n<b>Title</b><br>\r\nThe title of the page is what your users will use to navigate through the site. Titles should be descriptive, but not very long.\r\n<p>\r\n<b>Menu Title</b><br>\r\nA shorter or altered title to appear in navigation. If left blank this will default to <i>Title</i>.\r\n<p>\r\n<b>Page URL</b><br>\r\nWhen you create a page a URL for the page is generated based on the page title. If you are unhappy with the URL that was chosen, you can change it here.\r\n<p>\r\n<b>Template</b><br>\r\nBy default, WebGUI has one big content area to place wobjects. However, by specifying a template other than the default you can sub-divide the content area into several sections.\r\n<p>\r\n<b>Synopsis</b><br>\r\nA short description of a page. It is used to populate default descriptive meta tags as well as to provide descriptions on Site Maps.\r\n<p>\r\n<b>Meta Tags</b><br>\r\nMeta tags are used by some search engines to associate key words to a particular page. There is a great site called <a href=\"http://www.metatagbuilder.com/\">Meta Tag Builder</a> that will help you build meta tags if you\'ve never done it before.\r\n<p>\r\n<i>Advanced Users:</i> If you have other things (like JavaScript) you usually put in the &lt;head&gt; area of your pages, you may put them here as well.\r\n<p>\r\n<b>Use default meta tags?</b><br>\r\nIf you don\'t wish to specify meta tags yourself, WebGUI can generate meta tags based on the page title and your company\'s name. Check this box to enable the WebGUI-generated meta tags.\r\n<p>\r\n<b>Style</b><br>\r\nBy default, when you create a page, it inherits a few traits from its parent. One of those traits is style. Choose from the list of styles if you would like to change the appearance of this page. See <i>Add Style</i> for more details.\r\n<p>\r\nIf you check the box below the style pull-down menu, all of the pages below this page will take on the style you\'ve chosen for this page.\r\n<p>\r\n<b>Owner</b><br>\r\nThe owner of a page is usually the person who created the page.\r\n<p>\r\n<b>Owner can view?</b><br>\r\nCan the owner view the page or not?\r\n<p>\r\n<b>Owner can edit?</b><br>\r\nCan the owner edit the page or not? Be careful, if you decide that the owner cannot edit the page and you do not belong to the page group, then you\'ll lose the ability to edit this page.\r\n<p>\r\n<b>Group</b><br>\r\nA group is assigned to every page for additional privilege control. Pick a group from the pull-down menu.\r\n<p>\r\n<b>Group can view?</b><br>\r\nCan members of this group view this page?\r\n<p>\r\n<b>Group can edit?</b><br>\r\nCan members of this group edit this page?\r\n<p>\r\n<b>Anybody can view?</b><br>\r\nCan any visitor or member regardless of the group and owner view this page?\r\n<p>\r\n<b>Anybody can edit?</b><br>\r\nCan any visitor or member regardless of the group and owner edit this page?\r\n<p>\r\nYou can optionally give these privileges to all pages under this page.\r\n','0');
INSERT INTO help VALUES (29,'WebGUI','English','Edit','Content Settings','<b>Default Home Page</b><br>\r\nSome really small sites don\'t have a home page, but instead like to use one of their internal pages like \"About Us\" or \"Company Information\" as their home page. For that reason, you can set the default page of your site to any page in the site. That page will be the one people go to if they type in just your URL http://www.mywebguisite.com, or if they click on the Home link generated by the ^H; macro.\r\n<p>\r\n\r\n<b>Not Found Page</b><br>\r\nIf a page that a user requests is not found in the system, the user can be redirected to the home page or to an error page where they can attempt to find what they were looking for. You decide which is better for your users.\r\n<p>\r\n\r\n<b>Document Type Declaration</b><br>\r\nThese days it is very common to have a wide array of browsers accessing your site, including automated browsers like search engine spiders. Many of those browsers want to know what kind of content you are serving. The doctype tag allows you to specify that. By default WebGUI generates HTML 4.0 compliant content.\r\n<p>\r\n\r\n<b>Add edit stamp to posts?</b><br>\r\nTypically if a user edits a post on a message board, a stamp is added to that post to identify who made the edit, and at what time. On some sites that information is not necessary, therefore you can turn it off here.\r\n<p>\r\n\r\n<b>Filter Contributed HTML</b><br>\r\nEspecially when running a public site where anybody can post to your message boards or user submission systems, it is often a good idea to filter their content for malicious code that can harm the viewing experience of your visitors; And in some circumstances, it can even cause security problems. Use this setting to select the level of filtering you wish to apply.\r\n<p>\r\n\r\n<b>Text Area Rows</b><br>\r\nSome sites wish to control the size of the forms that WebGUI generates. With this setting you can specify how many rows of characters will be displayed in textareas on the site.\r\n<p>\r\n\r\n<b>Text Area Columns</b><br>\r\nSome sites wish to control the size of the forms that WebGUI generates. With this setting you can specify how many columns of characters will be displayed in textareas on the site.\r\n<p>\r\n\r\n<b>Text Box Size</b><br>\r\nSome sites wish to control the size of the forms that WebGUI generates. With this setting you can specify how characters can be displayed at once in text boxes on the site.\r\n<p>\r\n\r\n<b>Editor To Use</b><br>\r\nWebGUI has a very sophisticated Rich Editor that allows users to fomat content as though they were in Microsoft Word&reg; or some other word processor. To use that functionality, select \"Built-In Editor\". Sometimes web sites have the need for even more complex rich editors for things like Spell Check. For that reason you can install an 3rd party editor called <a href=\"http://www.realobjects.de\"><i>Real Objects Edit-On Pro&reg;</i></a> rich text editor. After you\'ve installed it change this option. If you need detailed instructions on how to integrate <i>Edit-On Pro&reg;)</i>, you can find them in <a href=\"http://www.plainblack.com/ruling_webgui\"><i>Ruling WebGUI</i></a>.\r\n<p>\r\n','6');
INSERT INTO help VALUES (33,'WebGUI','English','Manage','Template','Templates are used to affect how pages are laid out in WebGUI. For instance, most sites these days have more than just a menu and one big text area. Many of them have three or four columns preceeded by several headers and/or banner areas. WebGUI accomodates complex layouts through the use of Templates. There are several templates that come with WebGUI to make life easier for you, but you can create as many as you\'d like.','0');
INSERT INTO help VALUES (34,'WebGUI','English','Add/Edit','Template','<b>Template Name</b><br>\r\nGive this template a descriptive name so that you\'ll know what it is when you\'re applying the template to a page.\r\n<p>\r\n\r\n<b>Template</b><br>\r\nCreate your template by placing the special macros ^0; ^1; ^2;  and so on in your template to represent the different content areas. Typically this is done by using a table to position the content. The following is an example of a template with two content areas side by side:\r\n<p>\r\n<pre>\r\n&lt;table&gt;\r\n  &lt;tr&gt;\r\n    &lt;td&gt;^0;&lt;/td&gt;\r\n    &lt;td&gt;^1;&lt;/td&gt;\r\n  &lt;/tr&gt;\r\n&lt;/table&gt;\r\n</pre>\r\n<p>\r\nAlso be sure to take a look at the templates that come with WebGUI for ideas.\r\n','0');
INSERT INTO help VALUES (35,'WebGUI','English','Delete','Template','It is not a good idea to delete templates as you never know what kind of adverse affect it may have on your site (some pages may still be using the template). If you should choose to delete a template, all the pages still using the template will be set to the \"Default\" template.','0');

--
-- Table structure for table 'helpSeeAlso'
--

CREATE TABLE helpSeeAlso (
  seeAlsoId int(11) NOT NULL default '0',
  helpId int(11) default NULL,
  namespace varchar(30) default NULL,
  PRIMARY KEY  (seeAlsoId)
) TYPE=MyISAM;

--
-- Dumping data for table 'helpSeeAlso'
--


INSERT INTO helpSeeAlso VALUES (1,21,'WebGUI');
INSERT INTO helpSeeAlso VALUES (2,27,'WebGUI');
INSERT INTO helpSeeAlso VALUES (3,14,'WebGUI');
INSERT INTO helpSeeAlso VALUES (4,18,'WebGUI');
INSERT INTO helpSeeAlso VALUES (5,19,'WebGUI');
INSERT INTO helpSeeAlso VALUES (6,12,'WebGUI');
INSERT INTO helpSeeAlso VALUES (7,2,'WebGUI');
INSERT INTO helpSeeAlso VALUES (8,6,'WebGUI');
INSERT INTO helpSeeAlso VALUES (9,11,'WebGUI');
INSERT INTO helpSeeAlso VALUES (10,13,'WebGUI');
INSERT INTO helpSeeAlso VALUES (11,24,'WebGUI');
INSERT INTO helpSeeAlso VALUES (12,22,'WebGUI');

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

--
-- Table structure for table 'international'
--

CREATE TABLE international (
  internationalId int(11) NOT NULL default '0',
  namespace varchar(30) NOT NULL default 'WebGUI',
  language varchar(30) NOT NULL default 'English',
  message text,
  PRIMARY KEY  (internationalId,namespace,language)
) TYPE=MyISAM;

--
-- Dumping data for table 'international'
--


INSERT INTO international VALUES (367,'WebGUI','English','Expire After');
INSERT INTO international VALUES (1,'Article','Dutch','Artikel');
INSERT INTO international VALUES (1,'Article','English','Article');
INSERT INTO international VALUES (1,'Article','Español','Artículo');
INSERT INTO international VALUES (1,'Article','Português','Artigo');
INSERT INTO international VALUES (1,'EventsCalendar','Dutch','Doorgaan naar gebeurtenis toevoegen?');
INSERT INTO international VALUES (1,'EventsCalendar','English','Proceed to add event?');
INSERT INTO international VALUES (1,'EventsCalendar','Português','Proseguir com a adição do evento?');
INSERT INTO international VALUES (13,'SQLReport','Deutsch','Carriage Return\r\nbeachten?');
INSERT INTO international VALUES (1,'ExtraColumn','Dutch','Extra kolom');
INSERT INTO international VALUES (1,'ExtraColumn','English','Extra Column');
INSERT INTO international VALUES (1,'ExtraColumn','Español','Columna Extra');
INSERT INTO international VALUES (1,'ExtraColumn','Português','Coluna extra');
INSERT INTO international VALUES (1,'FAQ','Dutch','Doorgaan naar vraag toevoegen?');
INSERT INTO international VALUES (1,'FAQ','English','Proceed to add question?');
INSERT INTO international VALUES (1,'FAQ','Português','Proseguir com a adição da questão?');
INSERT INTO international VALUES (1,'Item','English','Link URL');
INSERT INTO international VALUES (1,'LinkList','Dutch','Inspringen');
INSERT INTO international VALUES (1,'LinkList','English','Indent');
INSERT INTO international VALUES (1,'LinkList','Português','Destaque');
INSERT INTO international VALUES (5,'ExtraColumn','Svenska','StyleSheet Class');
INSERT INTO international VALUES (5,'EventsCalendar','Svenska','Dag');
INSERT INTO international VALUES (5,'Article','Svenska','Body');
INSERT INTO international VALUES (4,'WebGUI','Svenska','Kontrolera inställningar.');
INSERT INTO international VALUES (13,'UserSubmission','Deutsch','Erstellungsdatum');
INSERT INTO international VALUES (1,'Poll','Dutch','Stemming');
INSERT INTO international VALUES (1,'Poll','English','Poll');
INSERT INTO international VALUES (1,'Poll','Español','Encuesta');
INSERT INTO international VALUES (1,'Poll','Português','Sondagem');
INSERT INTO international VALUES (4,'UserSubmission','Svenska','Ditt medelande har blivit validerat.');
INSERT INTO international VALUES (4,'SyndicatedContent','Svenska','Redigera Syndicated inehåll');
INSERT INTO international VALUES (13,'WebGUI','Deutsch','Hilfe anschauen');
INSERT INTO international VALUES (1,'SQLReport','Dutch','SQL rapport');
INSERT INTO international VALUES (1,'SQLReport','English','SQL Report');
INSERT INTO international VALUES (1,'SQLReport','Español','Reporte SQL');
INSERT INTO international VALUES (1,'SQLReport','Português','Relatório SQL');
INSERT INTO international VALUES (1,'SyndicatedContent','Dutch','URL naar RSS bestand');
INSERT INTO international VALUES (1,'SyndicatedContent','English','URL to RSS File');
INSERT INTO international VALUES (1,'SyndicatedContent','Português','Ficheiro de URL para RSS');
INSERT INTO international VALUES (1,'UserSubmission','Dutch','Wie kan goedkeuren?');
INSERT INTO international VALUES (1,'UserSubmission','English','Who can approve?');
INSERT INTO international VALUES (1,'UserSubmission','Português','Quem pode aprovar?');
INSERT INTO international VALUES (14,'Article','Deutsch','Anhang\r\nherunterladen');
INSERT INTO international VALUES (1,'WebGUI','Dutch','Inhoud toevoegen...');
INSERT INTO international VALUES (1,'WebGUI','English','Add content...');
INSERT INTO international VALUES (1,'WebGUI','Español','Agregar Contenido ...');
INSERT INTO international VALUES (1,'WebGUI','Português','Adicionar conteudo...');
INSERT INTO international VALUES (14,'DownloadManager','Deutsch','Datei');
INSERT INTO international VALUES (2,'EventsCalendar','Dutch','Evenementen kalender');
INSERT INTO international VALUES (2,'EventsCalendar','English','Events Calendar');
INSERT INTO international VALUES (2,'EventsCalendar','Español','Calendario de Eventos');
INSERT INTO international VALUES (2,'EventsCalendar','Português','Calendário de eventos');
INSERT INTO international VALUES (4,'SiteMap','Svenska','Nivåer att traversera');
INSERT INTO international VALUES (4,'Poll','Svenska','Vem kan rösta?');
INSERT INTO international VALUES (4,'MessageBoard','Svenska','Meddelanden per sida');
INSERT INTO international VALUES (4,'LinkList','Svenska','Kula');
INSERT INTO international VALUES (14,'EventsCalendar','Deutsch','Start\r\nDatum');
INSERT INTO international VALUES (2,'FAQ','Dutch','FAQ');
INSERT INTO international VALUES (2,'FAQ','English','F.A.Q.');
INSERT INTO international VALUES (2,'FAQ','Español','F.A.Q.');
INSERT INTO international VALUES (2,'FAQ','Português','Perguntas mais frequentes');
INSERT INTO international VALUES (2,'Item','English','Attachment');
INSERT INTO international VALUES (2,'LinkList','Dutch','Regel afstand');
INSERT INTO international VALUES (2,'LinkList','English','Line Spacing');
INSERT INTO international VALUES (2,'LinkList','Português','Espaço entre linhas');
INSERT INTO international VALUES (1,'Article','Dansk','Artikel');
INSERT INTO international VALUES (2,'MessageBoard','Dutch','Berichten bord');
INSERT INTO international VALUES (2,'MessageBoard','English','Message Board');
INSERT INTO international VALUES (2,'MessageBoard','Español','Table de Mensages');
INSERT INTO international VALUES (2,'MessageBoard','Português','Quadro de mensagens');
INSERT INTO international VALUES (4,'FAQ','Svenska','Lägg till fråga');
INSERT INTO international VALUES (4,'ExtraColumn','Svenska','Bredd');
INSERT INTO international VALUES (2,'SiteMap','Dutch','Site map');
INSERT INTO international VALUES (2,'SiteMap','English','Site Map');
INSERT INTO international VALUES (2,'SiteMap','Português','Mapa do site');
INSERT INTO international VALUES (14,'SQLReport','Deutsch','Später mit\r\nSeitenzahlen versehen');
INSERT INTO international VALUES (4,'Article','Svenska','Slut datum');
INSERT INTO international VALUES (3,'WebGUI','Svenska','Klistra in från klippbord...');
INSERT INTO international VALUES (14,'UserSubmission','Deutsch','Status');
INSERT INTO international VALUES (2,'SyndicatedContent','Dutch','Syndicated content');
INSERT INTO international VALUES (2,'SyndicatedContent','English','Syndicated Content');
INSERT INTO international VALUES (2,'SyndicatedContent','Português','Conteudo sindical');
INSERT INTO international VALUES (2,'UserSubmission','Dutch','Wie kan bijdragen?');
INSERT INTO international VALUES (2,'UserSubmission','English','Who can contribute?');
INSERT INTO international VALUES (2,'UserSubmission','Español','Quiénes pueden contribuir?');
INSERT INTO international VALUES (2,'UserSubmission','Português','Quem pode contribuir?');
INSERT INTO international VALUES (15,'Article','Deutsch','Rechts');
INSERT INTO international VALUES (2,'WebGUI','Dutch','Pagina');
INSERT INTO international VALUES (2,'WebGUI','English','Page');
INSERT INTO international VALUES (2,'WebGUI','Español','Página');
INSERT INTO international VALUES (2,'WebGUI','Português','Página');
INSERT INTO international VALUES (3,'Article','Dutch','Start datum');
INSERT INTO international VALUES (3,'Article','English','Start Date');
INSERT INTO international VALUES (3,'Article','Español','Fecha Inicio');
INSERT INTO international VALUES (3,'Article','Português','Data de inicio');
INSERT INTO international VALUES (14,'WebGUI','Deutsch','Ausstehende\r\nBeiträge anschauen');
INSERT INTO international VALUES (3,'SyndicatedContent','Svenska','Lägg till Syndicated inehåll');
INSERT INTO international VALUES (3,'SQLReport','Svenska','Rapport Mall');
INSERT INTO international VALUES (3,'SiteMap','Svenska','Starta från denna nivå?');
INSERT INTO international VALUES (3,'Poll','Svenska','Aktiv');
INSERT INTO international VALUES (3,'ExtraColumn','Dutch','Tussenruimte');
INSERT INTO international VALUES (3,'ExtraColumn','English','Spacer');
INSERT INTO international VALUES (3,'ExtraColumn','Español','Espaciador');
INSERT INTO international VALUES (3,'ExtraColumn','Português','Espaçamento');
INSERT INTO international VALUES (15,'DownloadManager','Deutsch','Beschreibung');
INSERT INTO international VALUES (3,'MessageBoard','Svenska','Vem kan posta?');
INSERT INTO international VALUES (3,'LinkList','Svenska','Öppna i ny ruta?');
INSERT INTO international VALUES (3,'Item','English','Delete Attachment');
INSERT INTO international VALUES (15,'EventsCalendar','Deutsch','Ende\r\nDatum');
INSERT INTO international VALUES (3,'LinkList','Dutch','Open in nieuw venster?');
INSERT INTO international VALUES (3,'LinkList','English','Open in new window?');
INSERT INTO international VALUES (3,'LinkList','Português','Abrir numa nova janela?');
INSERT INTO international VALUES (3,'MessageBoard','Dutch','Wie kan posten');
INSERT INTO international VALUES (3,'MessageBoard','English','Who can post?');
INSERT INTO international VALUES (3,'MessageBoard','Español','Quienes pueden mandar?');
INSERT INTO international VALUES (3,'MessageBoard','Português','Quem pode colocar novas?');
INSERT INTO international VALUES (3,'Poll','Dutch','Aktief');
INSERT INTO international VALUES (3,'Poll','English','Active');
INSERT INTO international VALUES (3,'Poll','Español','Activar');
INSERT INTO international VALUES (3,'Poll','Português','Activo');
INSERT INTO international VALUES (3,'SiteMap','Dutch','Op dit niveau beginnen?');
INSERT INTO international VALUES (3,'SiteMap','English','Starting from this level?');
INSERT INTO international VALUES (3,'SiteMap','Português','Iniciando neste nível?');
INSERT INTO international VALUES (15,'MessageBoard','Deutsch','Autor');
INSERT INTO international VALUES (3,'SQLReport','Dutch','Sjabloon');
INSERT INTO international VALUES (3,'SQLReport','English','Report Template');
INSERT INTO international VALUES (3,'SQLReport','Español','Modelo');
INSERT INTO international VALUES (3,'SQLReport','Português','Template');
INSERT INTO international VALUES (3,'ExtraColumn','Svenska','Mellanrumm');
INSERT INTO international VALUES (3,'EventsCalendar','Svenska','Lägg till händelse kalender');
INSERT INTO international VALUES (3,'Article','Svenska','Start datum');
INSERT INTO international VALUES (3,'UserSubmission','Dutch','U heeft een nieuwe bijdrage om goed te keuren.');
INSERT INTO international VALUES (3,'UserSubmission','English','You have a new user submission to approve.');
INSERT INTO international VALUES (3,'UserSubmission','Português','Tem nova submissão para aprovar.');
INSERT INTO international VALUES (3,'WebGUI','Dutch','Plakken van het klemboord...');
INSERT INTO international VALUES (3,'WebGUI','English','Paste from clipboard...');
INSERT INTO international VALUES (3,'WebGUI','Español','Pegar desde el Portapapeles...');
INSERT INTO international VALUES (3,'WebGUI','Português','Colar do clipboard...');
INSERT INTO international VALUES (15,'SQLReport','Deutsch','Sollen die\r\nMakros in der Abfrage vorverarbeitet werden?');
INSERT INTO international VALUES (4,'Article','Dutch','Eind datum');
INSERT INTO international VALUES (4,'Article','English','End Date');
INSERT INTO international VALUES (4,'Article','Español','Fecha finalización');
INSERT INTO international VALUES (4,'Article','Português','Data de fim');
INSERT INTO international VALUES (4,'EventsCalendar','Dutch','Gebeurt maar een keer.');
INSERT INTO international VALUES (4,'EventsCalendar','English','Happens only once.');
INSERT INTO international VALUES (4,'EventsCalendar','Español','Sucede solo una vez.');
INSERT INTO international VALUES (4,'EventsCalendar','Português','Apenas uma vez.');
INSERT INTO international VALUES (4,'ExtraColumn','Dutch','Wijdte');
INSERT INTO international VALUES (4,'ExtraColumn','English','Width');
INSERT INTO international VALUES (4,'ExtraColumn','Español','Ancho');
INSERT INTO international VALUES (4,'ExtraColumn','Português','Largura');
INSERT INTO international VALUES (2,'UserSubmission','Svenska','Vem kan göra inlägg?');
INSERT INTO international VALUES (2,'SyndicatedContent','Svenska','Syndicated inehåll');
INSERT INTO international VALUES (4,'Item','English','Item');
INSERT INTO international VALUES (15,'UserSubmission','Deutsch','Bearbeiten/Löschen');
INSERT INTO international VALUES (4,'LinkList','Dutch','Opsommingsteken');
INSERT INTO international VALUES (4,'LinkList','English','Bullet');
INSERT INTO international VALUES (4,'LinkList','Português','Marca');
INSERT INTO international VALUES (15,'WebGUI','Deutsch','Januar');
INSERT INTO international VALUES (4,'MessageBoard','Dutch','Berichten per pagina');
INSERT INTO international VALUES (4,'MessageBoard','English','Messages Per Page');
INSERT INTO international VALUES (4,'MessageBoard','Español','Mensages por página');
INSERT INTO international VALUES (4,'MessageBoard','Português','Mensagens por página');
INSERT INTO international VALUES (4,'Poll','Dutch','Wie kan stemmen?');
INSERT INTO international VALUES (4,'Poll','English','Who can vote?');
INSERT INTO international VALUES (4,'Poll','Español','Quiénes pueden votar?');
INSERT INTO international VALUES (4,'Poll','Português','Quem pode votar?');
INSERT INTO international VALUES (4,'SiteMap','Dutch','Diepte niveau');
INSERT INTO international VALUES (4,'SiteMap','English','Depth To Traverse');
INSERT INTO international VALUES (4,'SiteMap','Português','profundidade a travessar');
INSERT INTO international VALUES (16,'Article','Deutsch','Links');
INSERT INTO international VALUES (4,'SQLReport','Dutch','Query');
INSERT INTO international VALUES (4,'SQLReport','English','Query');
INSERT INTO international VALUES (4,'SQLReport','Español','Consulta');
INSERT INTO international VALUES (4,'SQLReport','Português','Query');
INSERT INTO international VALUES (4,'SyndicatedContent','Dutch','Bewerk syndicated content');
INSERT INTO international VALUES (4,'SyndicatedContent','English','Edit Syndicated Content');
INSERT INTO international VALUES (4,'SyndicatedContent','Português','Modificar conteudo sindical');
INSERT INTO international VALUES (4,'UserSubmission','Dutch','Uw bijdrage is goedgekeurd.');
INSERT INTO international VALUES (4,'UserSubmission','English','Your submission has been approved.');
INSERT INTO international VALUES (4,'UserSubmission','Português','A sua submissão foi aprovada.');
INSERT INTO international VALUES (4,'WebGUI','Dutch','Beheer instellingen.');
INSERT INTO international VALUES (4,'WebGUI','English','Manage settings.');
INSERT INTO international VALUES (4,'WebGUI','Español','Configurar Opciones.');
INSERT INTO international VALUES (4,'WebGUI','Português','Organizar preferências.');
INSERT INTO international VALUES (16,'DownloadManager','Deutsch','Upload\r\nDatum');
INSERT INTO international VALUES (38,'UserSubmission','English','(Select \"No\" if you\'re writing an HTML/Rich Edit submission.)');
INSERT INTO international VALUES (20,'EventsCalendar','English','Add an event.');
INSERT INTO international VALUES (5,'EventsCalendar','Dutch','Dag');
INSERT INTO international VALUES (5,'EventsCalendar','English','Day');
INSERT INTO international VALUES (5,'EventsCalendar','Español','Día');
INSERT INTO international VALUES (5,'EventsCalendar','Português','Dia');
INSERT INTO international VALUES (16,'EventsCalendar','Deutsch','Kalender\r\nLayout');
INSERT INTO international VALUES (5,'ExtraColumn','Dutch','Style sheet klasse (class)');
INSERT INTO international VALUES (5,'ExtraColumn','English','StyleSheet Class');
INSERT INTO international VALUES (5,'ExtraColumn','Español','Clase StyleSheet');
INSERT INTO international VALUES (5,'ExtraColumn','Português','StyleSheet Class');
INSERT INTO international VALUES (5,'FAQ','Dutch','Vraag');
INSERT INTO international VALUES (5,'FAQ','English','Question');
INSERT INTO international VALUES (5,'FAQ','Español','Pregunta');
INSERT INTO international VALUES (5,'FAQ','Português','Questão');
INSERT INTO international VALUES (5,'Item','English','Download Attachment');
INSERT INTO international VALUES (5,'LinkList','Dutch','Doorgaan met link toevoegen?');
INSERT INTO international VALUES (5,'LinkList','English','Proceed to add link?');
INSERT INTO international VALUES (5,'LinkList','Português','Proseguir com a adição do hiperlink?');
INSERT INTO international VALUES (5,'MessageBoard','Dutch','Bewerk timeout');
INSERT INTO international VALUES (5,'MessageBoard','English','Edit Timeout');
INSERT INTO international VALUES (5,'MessageBoard','Español','Timeout de edición');
INSERT INTO international VALUES (5,'MessageBoard','Português','Modificar Timeout');
INSERT INTO international VALUES (16,'SQLReport','Deutsch','Debug?');
INSERT INTO international VALUES (5,'Poll','Dutch','Grafiek wijdte');
INSERT INTO international VALUES (5,'Poll','English','Graph Width');
INSERT INTO international VALUES (5,'Poll','Español','Ancho del gráfico');
INSERT INTO international VALUES (5,'Poll','Português','Largura do gráfico');
INSERT INTO international VALUES (5,'SiteMap','Dutch','Bewerk site map');
INSERT INTO international VALUES (5,'SiteMap','English','Edit Site Map');
INSERT INTO international VALUES (5,'SiteMap','Português','Editar mapa do site');
INSERT INTO international VALUES (16,'MessageBoard','Deutsch','Datum');
INSERT INTO international VALUES (5,'SQLReport','Dutch','DSN');
INSERT INTO international VALUES (5,'SQLReport','English','DSN');
INSERT INTO international VALUES (5,'SQLReport','Español','DSN');
INSERT INTO international VALUES (5,'SQLReport','Português','DSN');
INSERT INTO international VALUES (5,'SyndicatedContent','Dutch','Laatste keer bijgewerkt');
INSERT INTO international VALUES (5,'SyndicatedContent','English','Last Fetched');
INSERT INTO international VALUES (5,'SyndicatedContent','Português','Ultima retirada');
INSERT INTO international VALUES (5,'UserSubmission','Dutch','Uw bijdrage is afgekeurd.');
INSERT INTO international VALUES (5,'UserSubmission','English','Your submission has been denied.');
INSERT INTO international VALUES (5,'UserSubmission','Português','A sua submissão não foi aprovada.');
INSERT INTO international VALUES (5,'WebGUI','Dutch','Beheer groepen.');
INSERT INTO international VALUES (5,'WebGUI','English','Manage groups.');
INSERT INTO international VALUES (5,'WebGUI','Español','Configurar Grupos.');
INSERT INTO international VALUES (5,'WebGUI','Português','Organizar grupos.');
INSERT INTO international VALUES (6,'Article','Dutch','Plaatje');
INSERT INTO international VALUES (6,'Article','English','Image');
INSERT INTO international VALUES (6,'Article','Español','Imagen');
INSERT INTO international VALUES (6,'Article','Português','Imagem');
INSERT INTO international VALUES (17,'Article','Deutsch','Zentrum');
INSERT INTO international VALUES (16,'UserSubmission','Deutsch','Ohne\r\nTitel');
INSERT INTO international VALUES (6,'EventsCalendar','Dutch','Week');
INSERT INTO international VALUES (6,'EventsCalendar','English','Week');
INSERT INTO international VALUES (6,'EventsCalendar','Español','Semana');
INSERT INTO international VALUES (6,'EventsCalendar','Português','Semana');
INSERT INTO international VALUES (6,'ExtraColumn','Dutch','Bewerk extra kolom');
INSERT INTO international VALUES (6,'ExtraColumn','English','Edit Extra Column');
INSERT INTO international VALUES (6,'ExtraColumn','Español','Editar Columna Extra');
INSERT INTO international VALUES (6,'ExtraColumn','Português','Modificar coluna extra');
INSERT INTO international VALUES (6,'FAQ','Dutch','Andwoord');
INSERT INTO international VALUES (6,'FAQ','English','Answer');
INSERT INTO international VALUES (6,'FAQ','Español','Respuesta');
INSERT INTO international VALUES (6,'FAQ','Português','Resposta');
INSERT INTO international VALUES (16,'WebGUI','Deutsch','Februar');
INSERT INTO international VALUES (6,'LinkList','Dutch','Link lijst');
INSERT INTO international VALUES (6,'LinkList','English','Link List');
INSERT INTO international VALUES (6,'LinkList','Español','Lista de Enlaces');
INSERT INTO international VALUES (6,'LinkList','Português','Lista de hiperlinks');
INSERT INTO international VALUES (6,'MessageBoard','Dutch','Bewerk berichten bord');
INSERT INTO international VALUES (6,'MessageBoard','English','Edit Message Board');
INSERT INTO international VALUES (6,'MessageBoard','Español','Editar Tabla de Mensages');
INSERT INTO international VALUES (6,'MessageBoard','Português','Modificar quadro de mensagens');
INSERT INTO international VALUES (17,'DownloadManager','Deutsch','Alternative #1');
INSERT INTO international VALUES (6,'Poll','Dutch','Vraag');
INSERT INTO international VALUES (6,'Poll','English','Question');
INSERT INTO international VALUES (6,'Poll','Español','Pregunta');
INSERT INTO international VALUES (6,'Poll','Português','Questão');
INSERT INTO international VALUES (6,'SiteMap','Dutch','Inspringen');
INSERT INTO international VALUES (6,'SiteMap','English','Indent');
INSERT INTO international VALUES (6,'SiteMap','Português','Destaque');
INSERT INTO international VALUES (17,'EventsCalendar','Deutsch','Liste');
INSERT INTO international VALUES (6,'SQLReport','Dutch','Database gebruiker');
INSERT INTO international VALUES (6,'SQLReport','English','Database User');
INSERT INTO international VALUES (6,'SQLReport','Español','Usuario de la Base de Datos');
INSERT INTO international VALUES (6,'SQLReport','Português','User da base de dados');
INSERT INTO international VALUES (6,'SyndicatedContent','Dutch','Huidige inhoud');
INSERT INTO international VALUES (6,'SyndicatedContent','English','Current Content');
INSERT INTO international VALUES (6,'SyndicatedContent','Português','Conteudo actual');
INSERT INTO international VALUES (17,'MessageBoard','Deutsch','Neuen\r\nBeitrag schreiben');
INSERT INTO international VALUES (6,'UserSubmission','Dutch','Bijdrages per pagina');
INSERT INTO international VALUES (6,'UserSubmission','English','Submissions Per Page');
INSERT INTO international VALUES (6,'UserSubmission','Español','Contribuciones por página');
INSERT INTO international VALUES (6,'UserSubmission','Português','Submissões por página');
INSERT INTO international VALUES (6,'WebGUI','Dutch','Beheer stijlen.');
INSERT INTO international VALUES (6,'WebGUI','English','Manage styles.');
INSERT INTO international VALUES (6,'WebGUI','Español','Configurar Estilos');
INSERT INTO international VALUES (6,'WebGUI','Português','Organizar estilos.');
INSERT INTO international VALUES (17,'SQLReport','Deutsch','<b>Debug:</b>\r\nAbfrage:');
INSERT INTO international VALUES (7,'Article','Dutch','Link titel');
INSERT INTO international VALUES (7,'Article','English','Link Title');
INSERT INTO international VALUES (7,'Article','Español','Link Título');
INSERT INTO international VALUES (7,'Article','Português','Titulo da hiperlink');
INSERT INTO international VALUES (2,'SiteMap','Svenska','Site Karta');
INSERT INTO international VALUES (2,'Poll','Svenska','Lägg till fråga');
INSERT INTO international VALUES (2,'MessageBoard','Svenska','Meddelande Forum');
INSERT INTO international VALUES (17,'UserSubmission','Deutsch','Sind Sie\r\nsicher, dass Sie diesen Beitrag löschen wollen?');
INSERT INTO international VALUES (7,'FAQ','Dutch','Weet u zeker dat u deze vraag wilt verwijderen?');
INSERT INTO international VALUES (7,'FAQ','English','Are you certain that you want to delete this question?');
INSERT INTO international VALUES (7,'FAQ','Español','Está seguro de querer eliminar ésta pregunta?');
INSERT INTO international VALUES (7,'FAQ','Português','Tem a certeza que quer apagar esta questão?');
INSERT INTO international VALUES (2,'Item','Svenska','Bilagor');
INSERT INTO international VALUES (2,'FAQ','Svenska','F.A.Q.');
INSERT INTO international VALUES (2,'ExtraColumn','Svenska','Lägg till Extra Column');
INSERT INTO international VALUES (18,'Article','Deutsch','Diskussion\r\nerlauben?');
INSERT INTO international VALUES (7,'MessageBoard','Dutch','Naam:');
INSERT INTO international VALUES (7,'MessageBoard','English','Author:');
INSERT INTO international VALUES (7,'MessageBoard','Español','Autor:');
INSERT INTO international VALUES (7,'MessageBoard','Português','Autor:');
INSERT INTO international VALUES (17,'WebGUI','Deutsch','März');
INSERT INTO international VALUES (7,'Poll','Dutch','Antwoorden');
INSERT INTO international VALUES (7,'Poll','English','Answers');
INSERT INTO international VALUES (7,'Poll','Español','Respuestas');
INSERT INTO international VALUES (7,'Poll','Português','Respostas');
INSERT INTO international VALUES (7,'SiteMap','Dutch','Opsommingsteken');
INSERT INTO international VALUES (7,'SiteMap','English','Bullet');
INSERT INTO international VALUES (7,'SiteMap','Português','Marca');
INSERT INTO international VALUES (7,'SQLReport','Dutch','Database wachtwoord');
INSERT INTO international VALUES (7,'SQLReport','English','Database Password');
INSERT INTO international VALUES (7,'SQLReport','Español','Password de la Base de Datos');
INSERT INTO international VALUES (7,'SQLReport','Português','Password da base de dados');
INSERT INTO international VALUES (18,'EventsCalendar','Deutsch','Kalender');
INSERT INTO international VALUES (7,'UserSubmission','Dutch','Goedgekeurd');
INSERT INTO international VALUES (7,'UserSubmission','English','Approved');
INSERT INTO international VALUES (7,'UserSubmission','Español','Aprobado');
INSERT INTO international VALUES (7,'UserSubmission','Português','Aprovado');
INSERT INTO international VALUES (7,'WebGUI','Dutch','Beheer gebruikers');
INSERT INTO international VALUES (7,'WebGUI','English','Manage users.');
INSERT INTO international VALUES (7,'WebGUI','Español','Configurar Usuarios');
INSERT INTO international VALUES (7,'WebGUI','Português','Organizar utilizadores.');
INSERT INTO international VALUES (8,'Article','Dutch','Link URL');
INSERT INTO international VALUES (8,'Article','English','Link URL');
INSERT INTO international VALUES (8,'Article','Español','Link URL');
INSERT INTO international VALUES (8,'Article','Português','URL da hiperlink');
INSERT INTO international VALUES (8,'EventsCalendar','Dutch','Herhaalt elke');
INSERT INTO international VALUES (8,'EventsCalendar','English','Recurs every');
INSERT INTO international VALUES (8,'EventsCalendar','Español','Se repite cada');
INSERT INTO international VALUES (8,'EventsCalendar','Português','Repetição');
INSERT INTO international VALUES (18,'DownloadManager','Deutsch','Alternative #2');
INSERT INTO international VALUES (8,'FAQ','Dutch','Bewerk FAQ');
INSERT INTO international VALUES (8,'FAQ','English','Edit F.A.Q.');
INSERT INTO international VALUES (8,'FAQ','Español','Editar F.A.Q.');
INSERT INTO international VALUES (8,'FAQ','Português','Modificar perguntas mais frequentes');
INSERT INTO international VALUES (8,'LinkList','Dutch','URL');
INSERT INTO international VALUES (8,'LinkList','English','URL');
INSERT INTO international VALUES (8,'LinkList','Español','URL');
INSERT INTO international VALUES (8,'LinkList','Português','URL');
INSERT INTO international VALUES (18,'MessageBoard','Deutsch','Diskussion\r\nbegonnen');
INSERT INTO international VALUES (8,'MessageBoard','Dutch','Datum:');
INSERT INTO international VALUES (8,'MessageBoard','English','Date:');
INSERT INTO international VALUES (8,'MessageBoard','Español','Fecha:');
INSERT INTO international VALUES (8,'MessageBoard','Português','Data:');
INSERT INTO international VALUES (8,'Poll','Dutch','(Enter een antwoord per lijn. Niet meer dan 20.)');
INSERT INTO international VALUES (8,'Poll','English','(Enter one answer per line. No more than 20.)');
INSERT INTO international VALUES (8,'Poll','Español','(Ingrese una por línea. No más de 20)');
INSERT INTO international VALUES (8,'Poll','Português','(Introduza uma resposta por linha. Não passe das 20.)');
INSERT INTO international VALUES (8,'SiteMap','Dutch','Regel afstand');
INSERT INTO international VALUES (8,'SiteMap','English','Line Spacing');
INSERT INTO international VALUES (8,'SiteMap','Português','Espaçamento de linha');
INSERT INTO international VALUES (18,'SQLReport','Deutsch','Diese Abfrage\r\nliefert keine Ergebnisse.');
INSERT INTO international VALUES (8,'SQLReport','Dutch','Bewerk SQL rapport');
INSERT INTO international VALUES (8,'SQLReport','English','Edit SQL Report');
INSERT INTO international VALUES (8,'SQLReport','Español','Editar Reporte SQL');
INSERT INTO international VALUES (8,'SQLReport','Português','Modificar o relaório SQL');
INSERT INTO international VALUES (8,'UserSubmission','Dutch','Afgekeurd');
INSERT INTO international VALUES (8,'UserSubmission','English','Denied');
INSERT INTO international VALUES (8,'UserSubmission','Español','Denegado');
INSERT INTO international VALUES (8,'UserSubmission','Português','Negado');
INSERT INTO international VALUES (8,'WebGUI','Dutch','Bekijk \'pagina niet gevonden\'.');
INSERT INTO international VALUES (8,'WebGUI','English','View page not found.');
INSERT INTO international VALUES (8,'WebGUI','Español','Ver Página No Encontrada');
INSERT INTO international VALUES (8,'WebGUI','Português','Ver página não encontrada.');
INSERT INTO international VALUES (18,'UserSubmission','Deutsch','Benutzer\r\nBeitragssystem bearbeiten');
INSERT INTO international VALUES (9,'Article','Dutch','Bijlage');
INSERT INTO international VALUES (9,'Article','English','Attachment');
INSERT INTO international VALUES (9,'Article','Español','Adjuntar');
INSERT INTO international VALUES (9,'Article','Português','Anexar');
INSERT INTO international VALUES (9,'EventsCalendar','Dutch','Tot');
INSERT INTO international VALUES (9,'EventsCalendar','English','until');
INSERT INTO international VALUES (9,'EventsCalendar','Español','hasta');
INSERT INTO international VALUES (9,'EventsCalendar','Português','até');
INSERT INTO international VALUES (18,'WebGUI','Deutsch','April');
INSERT INTO international VALUES (9,'FAQ','Dutch','Voeg een nieuwe vraag toe');
INSERT INTO international VALUES (9,'FAQ','English','Add a new question.');
INSERT INTO international VALUES (9,'FAQ','Español','Agregar nueva pregunta.');
INSERT INTO international VALUES (9,'FAQ','Português','Adicionar nova questão.');
INSERT INTO international VALUES (19,'Article','Deutsch','Wer kann\r\nschreiben?');
INSERT INTO international VALUES (9,'LinkList','Dutch','Weet u zeker dat u deze link wilt verwijderen?');
INSERT INTO international VALUES (9,'LinkList','English','Are you certain that you want to delete this link?');
INSERT INTO international VALUES (9,'LinkList','Español','Está seguro de querer eliminar éste enlace?');
INSERT INTO international VALUES (9,'LinkList','Português','Tem a certeza que quer apagar esta hiperlink?');
INSERT INTO international VALUES (9,'MessageBoard','Dutch','Bericht ID:');
INSERT INTO international VALUES (9,'MessageBoard','English','Message ID:');
INSERT INTO international VALUES (9,'MessageBoard','Español','ID del mensage:');
INSERT INTO international VALUES (9,'MessageBoard','Português','ID da mensagem:');
INSERT INTO international VALUES (9,'Poll','Dutch','Bewerk stemming');
INSERT INTO international VALUES (9,'Poll','English','Edit Poll');
INSERT INTO international VALUES (9,'Poll','Español','Editar Encuesta');
INSERT INTO international VALUES (9,'Poll','Português','Modificar sondagem');
INSERT INTO international VALUES (9,'SQLReport','Dutch','Fout: De ingevoerde DSN is van een verkeerd formaat.');
INSERT INTO international VALUES (9,'SQLReport','English','<b>Debug:</b> Error: The DSN specified is of an improper format.');
INSERT INTO international VALUES (9,'SQLReport','Español','Error: El DSN especificado está en un formato incorrecto.');
INSERT INTO international VALUES (9,'SQLReport','Português','Erro: O DSN especificado tem um formato impróprio.');
INSERT INTO international VALUES (19,'DownloadManager','Deutsch','Sie\r\nbesitzen keine Dateien, die zum Download bereitstehen.');
INSERT INTO international VALUES (9,'UserSubmission','Dutch','Lopend');
INSERT INTO international VALUES (9,'UserSubmission','English','Pending');
INSERT INTO international VALUES (9,'UserSubmission','Español','Pendiente');
INSERT INTO international VALUES (9,'UserSubmission','Português','Pendente');
INSERT INTO international VALUES (9,'WebGUI','Dutch','Bekijk klemboord.');
INSERT INTO international VALUES (9,'WebGUI','English','View clipboard.');
INSERT INTO international VALUES (9,'WebGUI','Español','Ver Portapapeles');
INSERT INTO international VALUES (9,'WebGUI','Português','Ver o clipboard.');
INSERT INTO international VALUES (10,'Article','Dutch','Enter converteren?');
INSERT INTO international VALUES (10,'Article','English','Convert carriage returns?');
INSERT INTO international VALUES (10,'Article','Español','Convertir saltos de carro?');
INSERT INTO international VALUES (10,'Article','Português','Converter o caracter de retorno (CR) ?');
INSERT INTO international VALUES (19,'EventsCalendar','Deutsch','Später mit\r\nSeitenzahlen versehen');
INSERT INTO international VALUES (10,'EventsCalendar','Dutch','Weet u zeker dat u dit evenement wilt verwijderen?');
INSERT INTO international VALUES (10,'EventsCalendar','English','Are you certain that you want to delete this event');
INSERT INTO international VALUES (10,'EventsCalendar','Español','Está segugo de querer eliminar éste evento');
INSERT INTO international VALUES (10,'EventsCalendar','Português','Tem a certeza que quer apagar este evento?');
INSERT INTO international VALUES (19,'MessageBoard','Deutsch','Antworten');
INSERT INTO international VALUES (10,'FAQ','Dutch','Bewerk vraag');
INSERT INTO international VALUES (10,'FAQ','English','Edit Question');
INSERT INTO international VALUES (10,'FAQ','Español','Editar Pregunta');
INSERT INTO international VALUES (10,'FAQ','Português','Modificar questão');
INSERT INTO international VALUES (10,'LinkList','Dutch','Bewerk link lijst');
INSERT INTO international VALUES (10,'LinkList','English','Edit Link List');
INSERT INTO international VALUES (10,'LinkList','Español','Editar Lista de Enlaces');
INSERT INTO international VALUES (10,'LinkList','Português','Modificar lista de hiperlinks');
INSERT INTO international VALUES (19,'UserSubmission','Deutsch','Beitrag\r\nbearbeiten');
INSERT INTO international VALUES (6,'Article','Dansk','Billede');
INSERT INTO international VALUES (5,'Article','Dansk','Brødtekst');
INSERT INTO international VALUES (4,'Article','Dansk','Til dato');
INSERT INTO international VALUES (3,'Article','Dansk','Fra dato');
INSERT INTO international VALUES (10,'Poll','Dutch','Reset stemmen');
INSERT INTO international VALUES (10,'Poll','English','Reset votes.');
INSERT INTO international VALUES (10,'Poll','Português','Reinicializar os votos.');
INSERT INTO international VALUES (19,'WebGUI','Deutsch','Mai');
INSERT INTO international VALUES (10,'SQLReport','Dutch','Fout: De ingevoerde SQL instructie is van een verkeerd formaat.');
INSERT INTO international VALUES (10,'SQLReport','English','<b>Debug:</b> Error: The SQL specified is of an improper format.');
INSERT INTO international VALUES (10,'SQLReport','Español','Error: El SQL especificado está en un formato incorrecto.');
INSERT INTO international VALUES (10,'SQLReport','Português','Erro: O SQL especificado tem um formato impróprio.');
INSERT INTO international VALUES (10,'UserSubmission','Dutch','Standaard status');
INSERT INTO international VALUES (10,'UserSubmission','English','Default Status');
INSERT INTO international VALUES (10,'UserSubmission','Español','Estado por defecto');
INSERT INTO international VALUES (10,'UserSubmission','Português','Estado por defeito');
INSERT INTO international VALUES (20,'Article','Deutsch','Wer kann\r\nmoderieren?');
INSERT INTO international VALUES (10,'WebGUI','Dutch','Bekijk prullenbak.');
INSERT INTO international VALUES (10,'WebGUI','English','Manage trash.');
INSERT INTO international VALUES (10,'WebGUI','Español','Ver Papelera');
INSERT INTO international VALUES (10,'WebGUI','Português','Ver o caixote do lixo.');
INSERT INTO international VALUES (11,'Article','Dutch','(Vink aan als u geen &lt;br&gt; manueel gebruikt.)');
INSERT INTO international VALUES (11,'Article','English','(Select \"Yes\" only if you aren\'t adding &lt;br&gt; manually.)');
INSERT INTO international VALUES (11,'Article','Español','(marque si no está agregando &lt;br&gt; manualmente.)');
INSERT INTO international VALUES (11,'Article','Português','(escolher se não adicionar &lt;br&gt; manualmente.)');
INSERT INTO international VALUES (20,'DownloadManager','Deutsch','Später\r\nmit Seitenzahlen versehen');
INSERT INTO international VALUES (11,'EventsCalendar','Dutch','<b> en</b> alle herhaalde evenementen');
INSERT INTO international VALUES (11,'EventsCalendar','English','<b>and</b> all of its recurring events');
INSERT INTO international VALUES (11,'EventsCalendar','Español','<b>y</b> todos las recurrencias del mismo');
INSERT INTO international VALUES (11,'EventsCalendar','Português','<b>e</b> todos os recurrentes');
INSERT INTO international VALUES (20,'MessageBoard','Deutsch','Letzte\r\nAntwort');
INSERT INTO international VALUES (2,'EventsCalendar','Svenska','Händelse Kalender');
INSERT INTO international VALUES (2,'Article','Svenska','Lägg till artikel');
INSERT INTO international VALUES (1,'WebGUI','Svenska','Lägg till innehåll....');
INSERT INTO international VALUES (1,'UserSubmission','Svenska','Vem kan validera?');
INSERT INTO international VALUES (11,'MessageBoard','Dutch','Terug naar berichten lijst');
INSERT INTO international VALUES (11,'MessageBoard','English','Back To Message List');
INSERT INTO international VALUES (11,'MessageBoard','Español','Volver a la Lista de Mensages');
INSERT INTO international VALUES (11,'MessageBoard','Português','Voltar á lista de mensagens');
INSERT INTO international VALUES (20,'UserSubmission','Deutsch','Neuen\r\nBeitrag schreiben');
INSERT INTO international VALUES (11,'SQLReport','Dutch','Fout: Er was een probleem met de query');
INSERT INTO international VALUES (11,'SQLReport','English','<b>Debug:</b> Error: There was a problem with the query.');
INSERT INTO international VALUES (11,'SQLReport','Español','Error: Hay un problema con la consulta.');
INSERT INTO international VALUES (11,'SQLReport','Português','Erro: Houve um problema com a query.');
INSERT INTO international VALUES (20,'WebGUI','Deutsch','Juni');
INSERT INTO international VALUES (1,'SQLReport','Svenska','SQL Rapport');
INSERT INTO international VALUES (1,'SiteMap','Svenska','Läggtill Site Karta');
INSERT INTO international VALUES (1,'Poll','Svenska','Fråga');
INSERT INTO international VALUES (11,'WebGUI','Dutch','Leeg prullenbak.');
INSERT INTO international VALUES (11,'WebGUI','English','Empy trash.');
INSERT INTO international VALUES (11,'WebGUI','Español','Vaciar Papelera');
INSERT INTO international VALUES (11,'WebGUI','Português','Esvaziar o caixote do lixo.');
INSERT INTO international VALUES (21,'Article','Deutsch','Timeout\r\nbearbeiten');
INSERT INTO international VALUES (12,'Article','Dutch','Bewerk artikel');
INSERT INTO international VALUES (12,'Article','English','Edit Article');
INSERT INTO international VALUES (12,'Article','Español','Editar Artículo');
INSERT INTO international VALUES (12,'Article','Português','Modificar artigo');
INSERT INTO international VALUES (12,'EventsCalendar','Dutch','Bewerk evenementen kalender');
INSERT INTO international VALUES (12,'EventsCalendar','English','Edit Events Calendar');
INSERT INTO international VALUES (12,'EventsCalendar','Español','Editar Calendario de Eventos');
INSERT INTO international VALUES (12,'EventsCalendar','Português','Modificar calendário de eventos');
INSERT INTO international VALUES (12,'LinkList','Dutch','Bewerk link');
INSERT INTO international VALUES (12,'LinkList','English','Edit Link');
INSERT INTO international VALUES (12,'LinkList','Español','Editar Enlace');
INSERT INTO international VALUES (12,'LinkList','Português','Modificar hiperlink');
INSERT INTO international VALUES (12,'MessageBoard','Dutch','Bewerk bericht');
INSERT INTO international VALUES (12,'MessageBoard','English','Edit Message');
INSERT INTO international VALUES (12,'MessageBoard','Español','Editar mensage');
INSERT INTO international VALUES (12,'MessageBoard','Português','Modificar mensagem');
INSERT INTO international VALUES (21,'DownloadManager','Deutsch','Vorschaubilder anzeigen?');
INSERT INTO international VALUES (12,'SQLReport','Dutch','Fout: Kon niet met de database verbinden.');
INSERT INTO international VALUES (12,'SQLReport','English','<b>Debug:</b> Error: Could not connect to the database.');
INSERT INTO international VALUES (12,'SQLReport','Español','Error: No se puede conectar a la base de datos.');
INSERT INTO international VALUES (12,'SQLReport','Português','Erro: Não é possível ligar á base de dados.');
INSERT INTO international VALUES (21,'MessageBoard','Deutsch','Wer kann\r\nmoderieren?');
INSERT INTO international VALUES (12,'UserSubmission','Dutch','(niet aanvinken als u een HTML bijdrage levert.)');
INSERT INTO international VALUES (12,'UserSubmission','English','(Uncheck if you\'re writing an HTML submission.)');
INSERT INTO international VALUES (12,'UserSubmission','Español','(desmarque si está escribiendo la contribución en HTML.)');
INSERT INTO international VALUES (12,'UserSubmission','Português','(deixar em branco se a submissão for em HTML.)');
INSERT INTO international VALUES (21,'UserSubmission','Deutsch','Erstellt\r\nvon');
INSERT INTO international VALUES (12,'WebGUI','Dutch','Zet beheermode uit.');
INSERT INTO international VALUES (12,'WebGUI','English','Turn admin off.');
INSERT INTO international VALUES (12,'WebGUI','Español','Apagar Admin');
INSERT INTO international VALUES (12,'WebGUI','Português','Desligar o modo administrativo.');
INSERT INTO international VALUES (21,'WebGUI','Deutsch','Juli');
INSERT INTO international VALUES (13,'Article','Dutch','Verwijder');
INSERT INTO international VALUES (13,'Article','English','Delete');
INSERT INTO international VALUES (13,'Article','Español','Eliminar');
INSERT INTO international VALUES (13,'Article','Português','Apagar');
INSERT INTO international VALUES (13,'EventsCalendar','Dutch','Bewerk evenement');
INSERT INTO international VALUES (13,'EventsCalendar','English','Edit Event');
INSERT INTO international VALUES (13,'EventsCalendar','Español','Editar Evento');
INSERT INTO international VALUES (13,'EventsCalendar','Português','Modificar evento');
INSERT INTO international VALUES (22,'MessageBoard','Deutsch','Beitrag\r\nlöschen');
INSERT INTO international VALUES (13,'LinkList','Dutch','Voeg een nieuwe link toe.');
INSERT INTO international VALUES (13,'LinkList','English','Add a new link.');
INSERT INTO international VALUES (13,'LinkList','Español','Agregar nuevo Enlace');
INSERT INTO international VALUES (13,'LinkList','Português','Adicionar nova hiperlink.');
INSERT INTO international VALUES (22,'Article','Deutsch','Autor');
INSERT INTO international VALUES (13,'MessageBoard','Dutch','Post antwoord');
INSERT INTO international VALUES (13,'MessageBoard','English','Post Reply');
INSERT INTO international VALUES (13,'MessageBoard','Español','Responder');
INSERT INTO international VALUES (13,'MessageBoard','Português','Responder');
INSERT INTO international VALUES (13,'UserSubmission','Dutch','Invoerdatum');
INSERT INTO international VALUES (13,'UserSubmission','English','Date Submitted');
INSERT INTO international VALUES (13,'UserSubmission','Español','Fecha Contribución');
INSERT INTO international VALUES (13,'UserSubmission','Português','Data de submissão');
INSERT INTO international VALUES (22,'UserSubmission','Deutsch','Erstellt\r\nvon:');
INSERT INTO international VALUES (13,'WebGUI','Dutch','Laat help index zien.');
INSERT INTO international VALUES (13,'WebGUI','English','View help index.');
INSERT INTO international VALUES (13,'WebGUI','Español','Ver índice de Ayuda');
INSERT INTO international VALUES (13,'WebGUI','Português','Ver o indice da ajuda.');
INSERT INTO international VALUES (14,'Article','English','Align Image');
INSERT INTO international VALUES (22,'WebGUI','Deutsch','August');
INSERT INTO international VALUES (516,'WebGUI','English','Turn Admin On!');
INSERT INTO international VALUES (517,'WebGUI','English','Turn Admin Off!');
INSERT INTO international VALUES (515,'WebGUI','English','Add edit stamp to posts?');
INSERT INTO international VALUES (23,'Article','Deutsch','Datum');
INSERT INTO international VALUES (14,'UserSubmission','Dutch','Status');
INSERT INTO international VALUES (14,'UserSubmission','English','Status');
INSERT INTO international VALUES (14,'UserSubmission','Español','Estado');
INSERT INTO international VALUES (14,'UserSubmission','Português','Estado');
INSERT INTO international VALUES (14,'WebGUI','Dutch','Laat lopende aanmeldingen zien.');
INSERT INTO international VALUES (14,'WebGUI','English','View pending submissions.');
INSERT INTO international VALUES (14,'WebGUI','Español','Ver contribuciones pendientes.');
INSERT INTO international VALUES (14,'WebGUI','Português','Ver submissões pendentes.');
INSERT INTO international VALUES (23,'UserSubmission','Deutsch','Erstellungsdatum:');
INSERT INTO international VALUES (15,'MessageBoard','Dutch','Afzender');
INSERT INTO international VALUES (15,'MessageBoard','English','Author');
INSERT INTO international VALUES (15,'MessageBoard','Español','Autor');
INSERT INTO international VALUES (15,'MessageBoard','Português','Autor');
INSERT INTO international VALUES (15,'UserSubmission','Dutch','bewerk/Verwijder');
INSERT INTO international VALUES (15,'UserSubmission','English','Edit/Delete');
INSERT INTO international VALUES (15,'UserSubmission','Español','Editar/Eliminar');
INSERT INTO international VALUES (15,'UserSubmission','Português','Modificar/Apagar');
INSERT INTO international VALUES (15,'WebGUI','Dutch','januari');
INSERT INTO international VALUES (15,'WebGUI','English','January');
INSERT INTO international VALUES (15,'WebGUI','Español','Enero');
INSERT INTO international VALUES (15,'WebGUI','Português','Janeiro');
INSERT INTO international VALUES (23,'WebGUI','Deutsch','September');
INSERT INTO international VALUES (16,'MessageBoard','Dutch','Datum');
INSERT INTO international VALUES (16,'MessageBoard','English','Date');
INSERT INTO international VALUES (16,'MessageBoard','Español','Fecha');
INSERT INTO international VALUES (16,'MessageBoard','Português','Data');
INSERT INTO international VALUES (16,'UserSubmission','Dutch','Zonder titel');
INSERT INTO international VALUES (16,'UserSubmission','English','Untitled');
INSERT INTO international VALUES (16,'UserSubmission','Español','Sin título');
INSERT INTO international VALUES (16,'UserSubmission','Português','Sem titulo');
INSERT INTO international VALUES (24,'UserSubmission','Deutsch','Erlauben');
INSERT INTO international VALUES (16,'WebGUI','Dutch','februari');
INSERT INTO international VALUES (16,'WebGUI','English','February');
INSERT INTO international VALUES (16,'WebGUI','Español','Febrero');
INSERT INTO international VALUES (16,'WebGUI','Português','Fevereiro');
INSERT INTO international VALUES (17,'MessageBoard','Dutch','Post nieuw bericht');
INSERT INTO international VALUES (17,'MessageBoard','English','Post New Message');
INSERT INTO international VALUES (17,'MessageBoard','Español','Mandar Nuevo Mensage');
INSERT INTO international VALUES (17,'MessageBoard','Português','Colocar nova mensagem');
INSERT INTO international VALUES (24,'Article','Deutsch','Kommentar\r\nschreiben');
INSERT INTO international VALUES (17,'UserSubmission','Dutch','Weet u zeker dat u deze bijdrage wilt verwijderen?');
INSERT INTO international VALUES (17,'UserSubmission','English','Are you certain you wish to delete this submission?');
INSERT INTO international VALUES (17,'UserSubmission','Español','Está seguro de querer eliminar ésta contribución?');
INSERT INTO international VALUES (17,'UserSubmission','Português','Tem a certeza que quer apagar esta submissão?');
INSERT INTO international VALUES (17,'WebGUI','Dutch','maart');
INSERT INTO international VALUES (17,'WebGUI','English','March');
INSERT INTO international VALUES (17,'WebGUI','Español','Marzo');
INSERT INTO international VALUES (17,'WebGUI','Português','Março');
INSERT INTO international VALUES (24,'WebGUI','Deutsch','Oktober');
INSERT INTO international VALUES (18,'MessageBoard','Dutch','Tread gestart');
INSERT INTO international VALUES (18,'MessageBoard','English','Thread Started');
INSERT INTO international VALUES (18,'MessageBoard','Español','Inicio');
INSERT INTO international VALUES (18,'MessageBoard','Português','Inicial');
INSERT INTO international VALUES (25,'Article','Deutsch','Kommentar\r\nbearbeiten');
INSERT INTO international VALUES (18,'UserSubmission','Dutch','Bewerk gebruikers bijdrage systeem');
INSERT INTO international VALUES (18,'UserSubmission','English','Edit User Submission System');
INSERT INTO international VALUES (18,'UserSubmission','Español','Editar Sistema de Contribución de Usuarios');
INSERT INTO international VALUES (18,'UserSubmission','Português','Modificar sistema de submissão do utilizador');
INSERT INTO international VALUES (18,'WebGUI','Dutch','april');
INSERT INTO international VALUES (18,'WebGUI','English','April');
INSERT INTO international VALUES (18,'WebGUI','Español','Abril');
INSERT INTO international VALUES (18,'WebGUI','Português','Abril');
INSERT INTO international VALUES (19,'MessageBoard','Dutch','Antwoorden');
INSERT INTO international VALUES (19,'MessageBoard','English','Replies');
INSERT INTO international VALUES (19,'MessageBoard','Español','Respuestas');
INSERT INTO international VALUES (19,'MessageBoard','Português','Respostas');
INSERT INTO international VALUES (25,'UserSubmission','Deutsch','Ausstehend\r\nverlassen');
INSERT INTO international VALUES (19,'UserSubmission','Dutch','Bewerk bijdrage');
INSERT INTO international VALUES (19,'UserSubmission','English','Edit Submission');
INSERT INTO international VALUES (19,'UserSubmission','Español','Editar Contribución');
INSERT INTO international VALUES (19,'UserSubmission','Português','Modificar submissão');
INSERT INTO international VALUES (19,'WebGUI','Dutch','mei');
INSERT INTO international VALUES (19,'WebGUI','English','May');
INSERT INTO international VALUES (19,'WebGUI','Español','Mayo');
INSERT INTO international VALUES (19,'WebGUI','Português','Maio');
INSERT INTO international VALUES (26,'Article','Deutsch','Kommentar\r\nlöschen');
INSERT INTO international VALUES (20,'MessageBoard','Dutch','Laatste antwoord');
INSERT INTO international VALUES (20,'MessageBoard','English','Last Reply');
INSERT INTO international VALUES (20,'MessageBoard','Español','Última respuesta');
INSERT INTO international VALUES (20,'MessageBoard','Português','Ultima resposta');
INSERT INTO international VALUES (20,'UserSubmission','Dutch','Post nieuwe bijdrage');
INSERT INTO international VALUES (20,'UserSubmission','English','Post New Submission');
INSERT INTO international VALUES (20,'UserSubmission','Español','Nueva Contribución');
INSERT INTO international VALUES (20,'UserSubmission','Português','Colocar nova submissão');
INSERT INTO international VALUES (25,'WebGUI','Deutsch','November');
INSERT INTO international VALUES (20,'WebGUI','Dutch','juni');
INSERT INTO international VALUES (20,'WebGUI','English','June');
INSERT INTO international VALUES (20,'WebGUI','Español','Junio');
INSERT INTO international VALUES (20,'WebGUI','Português','Junho');
INSERT INTO international VALUES (21,'UserSubmission','Dutch','Ingevoerd door');
INSERT INTO international VALUES (21,'UserSubmission','English','Submitted By');
INSERT INTO international VALUES (21,'UserSubmission','Español','Contribuida por');
INSERT INTO international VALUES (21,'UserSubmission','Português','Submetido por');
INSERT INTO international VALUES (26,'UserSubmission','Deutsch','Verbieten');
INSERT INTO international VALUES (21,'WebGUI','Dutch','juli');
INSERT INTO international VALUES (21,'WebGUI','English','July');
INSERT INTO international VALUES (21,'WebGUI','Español','Julio');
INSERT INTO international VALUES (21,'WebGUI','Português','Julho');
INSERT INTO international VALUES (22,'UserSubmission','Dutch','ingevoerd door:');
INSERT INTO international VALUES (22,'UserSubmission','English','Submitted By:');
INSERT INTO international VALUES (22,'UserSubmission','Español','Contribuida por:');
INSERT INTO international VALUES (22,'UserSubmission','Português','Submetido por:');
INSERT INTO international VALUES (26,'WebGUI','Deutsch','Dezember');
INSERT INTO international VALUES (22,'WebGUI','Dutch','augustus');
INSERT INTO international VALUES (22,'WebGUI','English','August');
INSERT INTO international VALUES (22,'WebGUI','Español','Agosto');
INSERT INTO international VALUES (22,'WebGUI','Português','Agosto');
INSERT INTO international VALUES (23,'UserSubmission','Dutch','Invoer datum:');
INSERT INTO international VALUES (23,'UserSubmission','English','Date Submitted:');
INSERT INTO international VALUES (23,'UserSubmission','Español','Fecha Contribución:');
INSERT INTO international VALUES (23,'UserSubmission','Português','Data de submissão:');
INSERT INTO international VALUES (27,'Article','Deutsch','Zurück zum\r\nArtikel');
INSERT INTO international VALUES (23,'WebGUI','Dutch','september');
INSERT INTO international VALUES (23,'WebGUI','English','September');
INSERT INTO international VALUES (23,'WebGUI','Español','Septiembre');
INSERT INTO international VALUES (23,'WebGUI','Português','Setembro');
INSERT INTO international VALUES (24,'UserSubmission','Dutch','Keur goed');
INSERT INTO international VALUES (24,'UserSubmission','English','Approve');
INSERT INTO international VALUES (24,'UserSubmission','Español','Aprobar');
INSERT INTO international VALUES (24,'UserSubmission','Português','Aprovar');
INSERT INTO international VALUES (27,'UserSubmission','Deutsch','Bearbeiten');
INSERT INTO international VALUES (24,'WebGUI','Dutch','oktober');
INSERT INTO international VALUES (24,'WebGUI','English','October');
INSERT INTO international VALUES (24,'WebGUI','Español','Octubre');
INSERT INTO international VALUES (24,'WebGUI','Português','Outubro');
INSERT INTO international VALUES (27,'WebGUI','Deutsch','Sonntag');
INSERT INTO international VALUES (25,'UserSubmission','Dutch','Laat in behandeling');
INSERT INTO international VALUES (25,'UserSubmission','English','Leave Pending');
INSERT INTO international VALUES (25,'UserSubmission','Español','Dejan pendiente');
INSERT INTO international VALUES (25,'UserSubmission','Português','Deixar pendente');
INSERT INTO international VALUES (25,'WebGUI','Dutch','november');
INSERT INTO international VALUES (25,'WebGUI','English','November');
INSERT INTO international VALUES (25,'WebGUI','Español','Noviembre');
INSERT INTO international VALUES (25,'WebGUI','Português','Novembro');
INSERT INTO international VALUES (26,'UserSubmission','Dutch','Keur af');
INSERT INTO international VALUES (26,'UserSubmission','English','Deny');
INSERT INTO international VALUES (26,'UserSubmission','Español','Denegar');
INSERT INTO international VALUES (26,'UserSubmission','Português','Negar');
INSERT INTO international VALUES (28,'Article','Deutsch','Kommentare\r\nanschauen');
INSERT INTO international VALUES (26,'WebGUI','Dutch','december');
INSERT INTO international VALUES (26,'WebGUI','English','December');
INSERT INTO international VALUES (26,'WebGUI','Español','Diciembre');
INSERT INTO international VALUES (26,'WebGUI','Português','Dezembro');
INSERT INTO international VALUES (27,'UserSubmission','Dutch','Bewerk');
INSERT INTO international VALUES (27,'UserSubmission','English','Edit');
INSERT INTO international VALUES (27,'UserSubmission','Español','Editar');
INSERT INTO international VALUES (27,'UserSubmission','Português','Modificar');
INSERT INTO international VALUES (27,'WebGUI','Dutch','zondag');
INSERT INTO international VALUES (27,'WebGUI','English','Sunday');
INSERT INTO international VALUES (27,'WebGUI','Español','Domingo');
INSERT INTO international VALUES (27,'WebGUI','Português','Domingo');
INSERT INTO international VALUES (28,'UserSubmission','Dutch','Ga terug naar bijdrage lijst');
INSERT INTO international VALUES (28,'UserSubmission','English','Return To Submissions List');
INSERT INTO international VALUES (28,'UserSubmission','Español','Regresar a lista de contribuciones');
INSERT INTO international VALUES (28,'UserSubmission','Português','Voltar á lista de submissões');
INSERT INTO international VALUES (28,'UserSubmission','Deutsch','Zurück zur\r\nBeitragsliste');
INSERT INTO international VALUES (28,'WebGUI','Dutch','maandag');
INSERT INTO international VALUES (28,'WebGUI','English','Monday');
INSERT INTO international VALUES (28,'WebGUI','Español','Lunes');
INSERT INTO international VALUES (28,'WebGUI','Português','Segunda');
INSERT INTO international VALUES (29,'UserSubmission','Dutch','Gebruikers bijdrage systeem');
INSERT INTO international VALUES (29,'UserSubmission','English','User Submission System');
INSERT INTO international VALUES (29,'UserSubmission','Español','Sistema de Contribución de Usuarios');
INSERT INTO international VALUES (29,'UserSubmission','Português','Sistema de submissão do utilizador');
INSERT INTO international VALUES (29,'WebGUI','Dutch','dinsdag');
INSERT INTO international VALUES (29,'WebGUI','English','Tuesday');
INSERT INTO international VALUES (29,'WebGUI','Español','Martes');
INSERT INTO international VALUES (29,'WebGUI','Português','Terça');
INSERT INTO international VALUES (29,'UserSubmission','Deutsch','Benutzer\r\nBeitragssystem');
INSERT INTO international VALUES (1,'LinkList','Svenska','Indentering');
INSERT INTO international VALUES (1,'Item','Svenska','Länk URL');
INSERT INTO international VALUES (1,'FAQ','Svenska','Fortsätt med att lägga till en fråga?');
INSERT INTO international VALUES (1,'ExtraColumn','Svenska','Extra Column');
INSERT INTO international VALUES (28,'WebGUI','Deutsch','Montag');
INSERT INTO international VALUES (30,'WebGUI','Dutch','woensdag');
INSERT INTO international VALUES (30,'WebGUI','English','Wednesday');
INSERT INTO international VALUES (30,'WebGUI','Español','Miércoles');
INSERT INTO international VALUES (30,'WebGUI','Português','Quarta');
INSERT INTO international VALUES (31,'WebGUI','Dutch','donderdag');
INSERT INTO international VALUES (31,'WebGUI','English','Thursday');
INSERT INTO international VALUES (31,'WebGUI','Español','Jueves');
INSERT INTO international VALUES (31,'WebGUI','Português','Quinta');
INSERT INTO international VALUES (29,'WebGUI','Deutsch','Dienstag');
INSERT INTO international VALUES (32,'WebGUI','Dutch','vrijdag');
INSERT INTO international VALUES (32,'WebGUI','English','Friday');
INSERT INTO international VALUES (32,'WebGUI','Español','Viernes');
INSERT INTO international VALUES (32,'WebGUI','Português','Sexta');
INSERT INTO international VALUES (33,'WebGUI','Dutch','zaterdag');
INSERT INTO international VALUES (33,'WebGUI','English','Saturday');
INSERT INTO international VALUES (33,'WebGUI','Español','Sabado');
INSERT INTO international VALUES (33,'WebGUI','Português','Sabado');
INSERT INTO international VALUES (34,'WebGUI','Dutch','Zet datum');
INSERT INTO international VALUES (34,'WebGUI','English','set date');
INSERT INTO international VALUES (34,'WebGUI','Español','fijar fecha');
INSERT INTO international VALUES (34,'WebGUI','Português','acertar a data');
INSERT INTO international VALUES (1,'MessageBoard','Svenska','Läggtill Meddelande Forum');
INSERT INTO international VALUES (35,'WebGUI','Dutch','Administratieve functie');
INSERT INTO international VALUES (35,'WebGUI','English','Administrative Function');
INSERT INTO international VALUES (35,'WebGUI','Español','Funciones Administrativas');
INSERT INTO international VALUES (35,'WebGUI','Português','Função administrativa');
INSERT INTO international VALUES (31,'UserSubmission','Deutsch','Inhalt');
INSERT INTO international VALUES (30,'WebGUI','Deutsch','Mittwoch');
INSERT INTO international VALUES (36,'WebGUI','Dutch','U moet een behherder zijn om deze functie uit te voeren. Neem contact op met een van de beheerders:');
INSERT INTO international VALUES (36,'WebGUI','English','You must be an administrator to perform this function. Please contact one of your administrators. The following is a list of the administrators for this system:');
INSERT INTO international VALUES (36,'WebGUI','Español','Debe ser administrador para realizar esta tarea. Por favor contacte a uno de los administradores. La siguiente es una lista de los administradores de éste sistema:');
INSERT INTO international VALUES (36,'WebGUI','Português','Função reservada a administradores. Fale com um dos seguintes administradores:');
INSERT INTO international VALUES (37,'WebGUI','Dutch','Geen toegang!');
INSERT INTO international VALUES (37,'WebGUI','English','Permission Denied!');
INSERT INTO international VALUES (37,'WebGUI','Español','Permiso Denegado!');
INSERT INTO international VALUES (37,'WebGUI','Português','Permissão negada!');
INSERT INTO international VALUES (38,'WebGUI','Português','\"Não tem privilégios para essa operação. ^a(Identifique-se na entrada); com uma conta que permita essa operação.\"');
INSERT INTO international VALUES (404,'WebGUI','English','First Page');
INSERT INTO international VALUES (38,'WebGUI','Español','\"No tiene privilegios suficientes para realizar ésta operación. Por favor ^a(ingrese con una cuenta); que posea los privilegios suficientes antes de intentar ésta operación.\"');
INSERT INTO international VALUES (38,'WebGUI','Dutch','U heeft niet voldoende privileges om deze operatie te doen. ^a(Log in); als een gebruiker met voldoende privileges.');
INSERT INTO international VALUES (38,'WebGUI','English','You do not have sufficient privileges to perform this operation. Please ^a(log in with an account); that has sufficient privileges before attempting this operation.');
INSERT INTO international VALUES (31,'WebGUI','Deutsch','Donnerstag');
INSERT INTO international VALUES (32,'UserSubmission','Deutsch','Grafik');
INSERT INTO international VALUES (33,'UserSubmission','Deutsch','Anhang');
INSERT INTO international VALUES (32,'WebGUI','Deutsch','Freitag');
INSERT INTO international VALUES (39,'WebGUI','Dutch','U heeft niet voldoende privileges om deze pagina op te vragen.');
INSERT INTO international VALUES (39,'WebGUI','English','You do not have sufficient privileges to access this page.');
INSERT INTO international VALUES (39,'WebGUI','Español','No tiene suficientes privilegios para ingresar a ésta página.');
INSERT INTO international VALUES (39,'WebGUI','Português','Não tem privilégios para aceder a essa página.');
INSERT INTO international VALUES (33,'WebGUI','Deutsch','Samstag');
INSERT INTO international VALUES (40,'WebGUI','Dutch','Vitaal component');
INSERT INTO international VALUES (40,'WebGUI','English','Vital Component');
INSERT INTO international VALUES (40,'WebGUI','Español','Componente Vital');
INSERT INTO international VALUES (40,'WebGUI','Português','Componente vital');
INSERT INTO international VALUES (34,'UserSubmission','Deutsch','Carriage\r\nReturn beachten?');
INSERT INTO international VALUES (34,'WebGUI','Deutsch','Datum setzen');
INSERT INTO international VALUES (41,'WebGUI','Dutch','U probeert een vitaal component van het WebGUI systeem te verwijderen. Als u dit zou mogen dan zou WebGUI waarschijnlijk niet meer werken.');
INSERT INTO international VALUES (41,'WebGUI','English','You\'re attempting to remove a vital component of the WebGUI system. If you were allowed to continue WebGUI may cease to function.');
INSERT INTO international VALUES (41,'WebGUI','Español','Esta intentando eliminar un componente vital del sistema WebGUI. Si continúa puede causar un mal funcionamiento de WebGUI.');
INSERT INTO international VALUES (41,'WebGUI','Português','Está a tentar remover um componente vital do WebGUI. Se continuar pode haver um erro grave.');
INSERT INTO international VALUES (42,'WebGUI','Dutch','Alstublieft bevestigen');
INSERT INTO international VALUES (42,'WebGUI','English','Please Confirm');
INSERT INTO international VALUES (42,'WebGUI','Español','Por favor confirme');
INSERT INTO international VALUES (42,'WebGUI','Português','Confirma');
INSERT INTO international VALUES (43,'WebGUI','Dutch','Weet u zeker dat u deze inhoud wilt verwijderen?');
INSERT INTO international VALUES (43,'WebGUI','English','Are you certain that you wish to delete this content?');
INSERT INTO international VALUES (43,'WebGUI','Español','Está seguro de querer eliminar éste contenido?');
INSERT INTO international VALUES (43,'WebGUI','Português','Tem a certeza que quer apagar este conteudo?');
INSERT INTO international VALUES (35,'UserSubmission','Deutsch','Titel');
INSERT INTO international VALUES (35,'WebGUI','Deutsch','Administrative\r\nFunktion');
INSERT INTO international VALUES (44,'WebGUI','Dutch','\"Ja, ik weet het zeker.\"');
INSERT INTO international VALUES (44,'WebGUI','English','Yes, I\'m sure.');
INSERT INTO international VALUES (44,'WebGUI','Español','Si');
INSERT INTO international VALUES (44,'WebGUI','Português','\"Sim, tenho a certeza.\"');
INSERT INTO international VALUES (45,'WebGUI','Dutch','\"Nee, ik heb een foutje gemaakt.\"');
INSERT INTO international VALUES (45,'WebGUI','English','No, I made a mistake.');
INSERT INTO international VALUES (45,'WebGUI','Español','No');
INSERT INTO international VALUES (45,'WebGUI','Português','\"Não, enganei-me.\"');
INSERT INTO international VALUES (46,'WebGUI','Dutch','Mijn account');
INSERT INTO international VALUES (46,'WebGUI','English','My Account');
INSERT INTO international VALUES (46,'WebGUI','Español','Mi Cuenta');
INSERT INTO international VALUES (46,'WebGUI','Português','Minha Conta');
INSERT INTO international VALUES (47,'WebGUI','Dutch','Home');
INSERT INTO international VALUES (47,'WebGUI','English','Home');
INSERT INTO international VALUES (47,'WebGUI','Español','Home');
INSERT INTO international VALUES (47,'WebGUI','Português','Inicio');
INSERT INTO international VALUES (48,'WebGUI','Dutch','Hallo');
INSERT INTO international VALUES (48,'WebGUI','English','Hello');
INSERT INTO international VALUES (48,'WebGUI','Español','Hola');
INSERT INTO international VALUES (48,'WebGUI','Português','Ola');
INSERT INTO international VALUES (49,'WebGUI','Dutch','Klik <a href=\"^\\;?op=logout\">hier</a> om uit te loggen.');
INSERT INTO international VALUES (49,'WebGUI','English','Click <a href=\"^\\;?op=logout\">here</a> to log out.');
INSERT INTO international VALUES (49,'WebGUI','Español','Click <a href=\"^\\;?op=logout\">aquí</a> para salir.');
INSERT INTO international VALUES (49,'WebGUI','Português','Clique <a href=\"^\\;?op=logout\">aqui</a> para sair.');
INSERT INTO international VALUES (50,'WebGUI','Dutch','Gebruikersnaam');
INSERT INTO international VALUES (50,'WebGUI','English','Username');
INSERT INTO international VALUES (50,'WebGUI','Español','Nombre usuario');
INSERT INTO international VALUES (50,'WebGUI','Português','Username');
INSERT INTO international VALUES (51,'WebGUI','Dutch','Wachtwoord');
INSERT INTO international VALUES (51,'WebGUI','English','Password');
INSERT INTO international VALUES (51,'WebGUI','Español','Password');
INSERT INTO international VALUES (51,'WebGUI','Português','Password');
INSERT INTO international VALUES (52,'WebGUI','Dutch','Login');
INSERT INTO international VALUES (52,'WebGUI','English','login');
INSERT INTO international VALUES (52,'WebGUI','Español','ingresar');
INSERT INTO international VALUES (52,'WebGUI','Português','entrar');
INSERT INTO international VALUES (36,'WebGUI','Deutsch','Um diese Funktion\r\nausführen zu können, müssen Sie Administrator sein. Eine der folgenden\r\nPersonen kann Sie zum Administrator machen:');
INSERT INTO international VALUES (53,'WebGUI','Dutch','Maak pagina printbaar');
INSERT INTO international VALUES (53,'WebGUI','English','Make Page Printable');
INSERT INTO international VALUES (53,'WebGUI','Español','Hacer página imprimible');
INSERT INTO international VALUES (53,'WebGUI','Português','Versão para impressão');
INSERT INTO international VALUES (54,'WebGUI','Dutch','Creëer account');
INSERT INTO international VALUES (54,'WebGUI','English','Create Account');
INSERT INTO international VALUES (54,'WebGUI','Español','Crear Cuenta');
INSERT INTO international VALUES (54,'WebGUI','Português','Criar conta');
INSERT INTO international VALUES (55,'WebGUI','Dutch','Wachtwoord (bevestigen)');
INSERT INTO international VALUES (55,'WebGUI','English','Password (confirm)');
INSERT INTO international VALUES (55,'WebGUI','Español','Password (confirmar)');
INSERT INTO international VALUES (55,'WebGUI','Português','Password (confirmar)');
INSERT INTO international VALUES (37,'UserSubmission','Deutsch','Löschen');
INSERT INTO international VALUES (56,'WebGUI','Dutch','Email adres');
INSERT INTO international VALUES (56,'WebGUI','English','Email Address');
INSERT INTO international VALUES (56,'WebGUI','Español','Dirección de e-mail');
INSERT INTO international VALUES (56,'WebGUI','Português','Endereço de e-mail');
INSERT INTO international VALUES (37,'WebGUI','Deutsch','Zugriff\r\nverweigert!');
INSERT INTO international VALUES (57,'WebGUI','Dutch','Dit is alleen nodig als er functies gebruikt worden die Email nodig hebben.');
INSERT INTO international VALUES (57,'WebGUI','English','This is only necessary if you wish to use features that require Email.');
INSERT INTO international VALUES (57,'WebGUI','Español','Solo es necesaria si desea usar opciones que requieren e-mail.');
INSERT INTO international VALUES (57,'WebGUI','Português','Apenas é necessário se pretender utilizar as funcionalidade que envolvam e-mail.');
INSERT INTO international VALUES (58,'WebGUI','Dutch','Ik heb al een account.');
INSERT INTO international VALUES (58,'WebGUI','English','I already have an account.');
INSERT INTO international VALUES (58,'WebGUI','Español','Ya tengo una cuenta!');
INSERT INTO international VALUES (58,'WebGUI','Português','Já tenho uma conta.');
INSERT INTO international VALUES (59,'WebGUI','Dutch','Ik ben mijn wachtwoord vergeten.');
INSERT INTO international VALUES (59,'WebGUI','English','I forgot my password.');
INSERT INTO international VALUES (59,'WebGUI','Español','Perdí mi password');
INSERT INTO international VALUES (59,'WebGUI','Português','Esqueci a minha password.');
INSERT INTO international VALUES (38,'WebGUI','Deutsch','Sie sind nicht\r\nberechtigt, diese Aktion auszuführen. ^a(Melden Sie sich bitte mit einem\r\nBenutzernamen an);, der über ausreichende Rechte verfügt.');
INSERT INTO international VALUES (60,'WebGUI','Dutch','Weet u zeker dat u uw account wilt deaktiveren? Als u doorgaat gaat alle account informatie voorgoed verloren.');
INSERT INTO international VALUES (60,'WebGUI','English','Are you certain you want to deactivate your account. If you proceed your account information will be lost permanently.');
INSERT INTO international VALUES (60,'WebGUI','Español','Está seguro que quiere desactivar su cuenta. Si continúa su información se perderá permanentemente.');
INSERT INTO international VALUES (60,'WebGUI','Português','Tem a certeza que quer desactivar a sua conta. Se o fizer é permanente!');
INSERT INTO international VALUES (61,'WebGUI','Dutch','Account informatie bijwerken');
INSERT INTO international VALUES (61,'WebGUI','English','Update Account Information');
INSERT INTO international VALUES (61,'WebGUI','Español','Actualizar información de la Cuenta');
INSERT INTO international VALUES (61,'WebGUI','Português','Actualizar as informações da conta');
INSERT INTO international VALUES (62,'WebGUI','Dutch','Bewaar');
INSERT INTO international VALUES (62,'WebGUI','English','save');
INSERT INTO international VALUES (62,'WebGUI','Español','guardar');
INSERT INTO international VALUES (62,'WebGUI','Português','gravar');
INSERT INTO international VALUES (63,'WebGUI','Dutch','Zet beheermode aan');
INSERT INTO international VALUES (63,'WebGUI','English','Turn admin on.');
INSERT INTO international VALUES (63,'WebGUI','Español','Encender Admin');
INSERT INTO international VALUES (63,'WebGUI','Português','Ligar modo administrativo.');
INSERT INTO international VALUES (64,'WebGUI','Dutch','Log uit.');
INSERT INTO international VALUES (64,'WebGUI','English','Log out.');
INSERT INTO international VALUES (64,'WebGUI','Español','Salir');
INSERT INTO international VALUES (64,'WebGUI','Português','Sair.');
INSERT INTO international VALUES (40,'WebGUI','Deutsch','Notwendiger\r\nBestandteil');
INSERT INTO international VALUES (39,'WebGUI','Deutsch','Sie sind nicht\r\nberechtigt, diese Seite anzuschauen.');
INSERT INTO international VALUES (65,'WebGUI','Dutch','Deaktiveer mijn account voorgoed.');
INSERT INTO international VALUES (65,'WebGUI','English','Please deactivate my account permanently.');
INSERT INTO international VALUES (65,'WebGUI','Español','Por favor desactive mi cuenta permanentemente');
INSERT INTO international VALUES (65,'WebGUI','Português','Desactivar a minha conta permanentemente.');
INSERT INTO international VALUES (66,'WebGUI','Dutch','Log in');
INSERT INTO international VALUES (66,'WebGUI','English','Log In');
INSERT INTO international VALUES (66,'WebGUI','Español','Ingresar');
INSERT INTO international VALUES (66,'WebGUI','Português','Entrar');
INSERT INTO international VALUES (67,'WebGUI','Dutch','Creëer een nieuw account');
INSERT INTO international VALUES (67,'WebGUI','English','Create a new account.');
INSERT INTO international VALUES (67,'WebGUI','Español','Crear nueva Cuenta');
INSERT INTO international VALUES (67,'WebGUI','Português','Criar nova conta.');
INSERT INTO international VALUES (68,'WebGUI','Dutch','De account informatie is niet geldig. Het account bestaat niet of de gebruikersnaam/wachtwoord was fout.');
INSERT INTO international VALUES (68,'WebGUI','English','The account information you supplied is invalid. Either the account does not exist or the username/password combination was incorrect.');
INSERT INTO international VALUES (68,'WebGUI','Español','La información de su cuenta no es válida. O la cuenta no existe');
INSERT INTO international VALUES (68,'WebGUI','Português','As informações da sua conta não foram encontradas. Não existe ou a combinação username/password está incorrecta.');
INSERT INTO international VALUES (69,'WebGUI','Dutch','Vraag uw systeembeheerder om assistentie.');
INSERT INTO international VALUES (69,'WebGUI','English','Please contact your system administrator for assistance.');
INSERT INTO international VALUES (69,'WebGUI','Español','Por favor contacte a su administrador por asistencia.');
INSERT INTO international VALUES (69,'WebGUI','Português','Contacte o seu administrador de sistemas para assistência.');
INSERT INTO international VALUES (42,'WebGUI','Deutsch','Bitte bestätigen\r\nSie');
INSERT INTO international VALUES (41,'WebGUI','Deutsch','Sie versuchen\r\neinen notwendigen Bestandteil des Systems zu löschen. WebGUI wird nach\r\ndieser Aktion möglicherweise nicht mehr richtig funktionieren.');
INSERT INTO international VALUES (70,'WebGUI','Dutch','Fout');
INSERT INTO international VALUES (70,'WebGUI','English','Error');
INSERT INTO international VALUES (70,'WebGUI','Español','Error');
INSERT INTO international VALUES (70,'WebGUI','Português','Erro');
INSERT INTO international VALUES (71,'WebGUI','Dutch','Wachtwoord terugvinden');
INSERT INTO international VALUES (71,'WebGUI','English','Recover password');
INSERT INTO international VALUES (71,'WebGUI','Español','Recuperar password');
INSERT INTO international VALUES (71,'WebGUI','Português','Recuperar password');
INSERT INTO international VALUES (72,'WebGUI','Dutch','Terugvinden');
INSERT INTO international VALUES (72,'WebGUI','English','recover');
INSERT INTO international VALUES (72,'WebGUI','Español','recuperar');
INSERT INTO international VALUES (72,'WebGUI','Português','recoperar');
INSERT INTO international VALUES (73,'WebGUI','Dutch','Log in.');
INSERT INTO international VALUES (73,'WebGUI','English','Log in.');
INSERT INTO international VALUES (73,'WebGUI','Español','Ingresar.');
INSERT INTO international VALUES (73,'WebGUI','Português','Entrar.');
INSERT INTO international VALUES (43,'WebGUI','Deutsch','Sind Sie sicher,\r\ndass Sie diesen Inhalt löschen möchten?');
INSERT INTO international VALUES (74,'WebGUI','Dutch','Account informatie');
INSERT INTO international VALUES (74,'WebGUI','English','Account Information');
INSERT INTO international VALUES (74,'WebGUI','Español','Información de la Cuenta');
INSERT INTO international VALUES (74,'WebGUI','Português','Informações da sua conta');
INSERT INTO international VALUES (44,'WebGUI','Deutsch','Ja, ich bin mir\r\nsicher.');
INSERT INTO international VALUES (75,'WebGUI','Dutch','Uw account informatie is naar uw email adres verzonden.');
INSERT INTO international VALUES (75,'WebGUI','English','Your account information has been sent to your email address.');
INSERT INTO international VALUES (75,'WebGUI','Español','La información de su cuenta ha sido enviada a su e-mail-');
INSERT INTO international VALUES (75,'WebGUI','Português','As informações da sua conta foram envidas para o seu e-mail.');
INSERT INTO international VALUES (76,'WebGUI','Dutch','Dat email adresis niet in onze database aanwezig.');
INSERT INTO international VALUES (76,'WebGUI','English','That email address is not in our databases.');
INSERT INTO international VALUES (76,'WebGUI','Español','El e-mail no está en nuestra base de datos');
INSERT INTO international VALUES (76,'WebGUI','Português','Esse endereço de e-mail não foi encontrado nas nossas bases de dados');
INSERT INTO international VALUES (45,'WebGUI','Deutsch','Nein, ich habe\r\neinen Fehler gemacht.');
INSERT INTO international VALUES (46,'WebGUI','Deutsch','Mein\r\nBenutzerkonto');
INSERT INTO international VALUES (77,'WebGUI','Dutch','Deze account naam wordt al gebruikt door een andere gebruiker van dit systeem. Probeer een andere naam. We hebben de volgende suggesties:');
INSERT INTO international VALUES (77,'WebGUI','English','That account name is already in use by another member of this site. Please try a different username. The following are some suggestions:');
INSERT INTO international VALUES (77,'WebGUI','Español','El nombre de cuenta ya está en uso por otro miembro. Por favor trate con otro nombre de usuario.  Los siguiente son algunas sugerencias:');
INSERT INTO international VALUES (77,'WebGUI','Português','\"Esse nome de conta já existe, tente outro. Veja as nossas sugestões:\"');
INSERT INTO international VALUES (78,'WebGUI','Dutch','De wachtwoorden waren niet gelijk. Probeer opnieuw.');
INSERT INTO international VALUES (78,'WebGUI','English','Your passwords did not match. Please try again.');
INSERT INTO international VALUES (78,'WebGUI','Español','Su password no concuerda. Trate de nuevo.');
INSERT INTO international VALUES (78,'WebGUI','Português','\"As suas passwords não coincidem, tente novamente.\"');
INSERT INTO international VALUES (47,'WebGUI','Deutsch','Startseite');
INSERT INTO international VALUES (48,'WebGUI','Deutsch','Hallo');
INSERT INTO international VALUES (79,'WebGUI','Dutch','Kan niet verbinden met LDAP server.');
INSERT INTO international VALUES (79,'WebGUI','English','Cannot connect to LDAP server.');
INSERT INTO international VALUES (79,'WebGUI','Español','No se puede conectar con el servidor LDAP');
INSERT INTO international VALUES (79,'WebGUI','Português','Impossivel ligar ao LDAP.');
INSERT INTO international VALUES (50,'WebGUI','Deutsch','Benutzername');
INSERT INTO international VALUES (80,'WebGUI','Dutch','Account is aangemaakt!');
INSERT INTO international VALUES (80,'WebGUI','English','Account created successfully!');
INSERT INTO international VALUES (80,'WebGUI','Español','La cuenta se ha creado con éxito!');
INSERT INTO international VALUES (80,'WebGUI','Português','Conta criada com sucesso!');
INSERT INTO international VALUES (81,'WebGUI','Dutch','Account is aangepast!');
INSERT INTO international VALUES (81,'WebGUI','English','Account updated successfully!');
INSERT INTO international VALUES (81,'WebGUI','Español','La cuenta se actualizó con éxito!');
INSERT INTO international VALUES (81,'WebGUI','Português','Conta actualizada com sucesso!');
INSERT INTO international VALUES (82,'WebGUI','Dutch','Administratieve functies...');
INSERT INTO international VALUES (82,'WebGUI','English','Administrative functions...');
INSERT INTO international VALUES (82,'WebGUI','Español','Funciones Administrativas...');
INSERT INTO international VALUES (82,'WebGUI','Português','Funções administrativas...');
INSERT INTO international VALUES (52,'WebGUI','Deutsch','Anmelden');
INSERT INTO international VALUES (49,'WebGUI','Deutsch','Hier können Sie\r\nsich <a href=\"^;?op=logout\">abmelden</a>.');
INSERT INTO international VALUES (84,'WebGUI','Dutch','Groep naam');
INSERT INTO international VALUES (84,'WebGUI','English','Group Name');
INSERT INTO international VALUES (84,'WebGUI','Español','Nombre del Grupo');
INSERT INTO international VALUES (84,'WebGUI','Português','Nome do grupo');
INSERT INTO international VALUES (51,'WebGUI','Deutsch','Passwort');
INSERT INTO international VALUES (85,'WebGUI','Dutch','Beschrijving');
INSERT INTO international VALUES (85,'WebGUI','English','Description');
INSERT INTO international VALUES (85,'WebGUI','Español','Descripción');
INSERT INTO international VALUES (85,'WebGUI','Português','Descrição');
INSERT INTO international VALUES (53,'WebGUI','Deutsch','Druckerbares\r\nFormat');
INSERT INTO international VALUES (86,'WebGUI','Dutch','Weet u zeker dat u deze groep wilt verwijderen? Denk er aan dat een groep verwijderen permanent en alle privileges geassocieerd met de groep verwijdert worden.');
INSERT INTO international VALUES (86,'WebGUI','English','Are you certain you wish to delete this group? Beware that deleting a group is permanent and will remove all privileges associated with this group.');
INSERT INTO international VALUES (86,'WebGUI','Español','Está segugo de querer eliminar éste grupo? Tenga en cuenta que la eliminación es permanente y removerá todos los privilegios asociados con el grupo.');
INSERT INTO international VALUES (86,'WebGUI','Português','Tem a certeza que quer apagar este grupo. Se o fizer apaga-o permanentemente e a todos os seus provilégios.');
INSERT INTO international VALUES (54,'WebGUI','Deutsch','Benutzerkonto\r\nanlegen');
INSERT INTO international VALUES (87,'WebGUI','Dutch','Bewerk groep');
INSERT INTO international VALUES (87,'WebGUI','English','Edit Group');
INSERT INTO international VALUES (87,'WebGUI','Español','Editar Grupo');
INSERT INTO international VALUES (87,'WebGUI','Português','Modificar grupo');
INSERT INTO international VALUES (88,'WebGUI','Dutch','Grebruikers in groep');
INSERT INTO international VALUES (88,'WebGUI','English','Users In Group');
INSERT INTO international VALUES (88,'WebGUI','Español','Usuarios en Grupo');
INSERT INTO international VALUES (88,'WebGUI','Português','Utilizadores no grupo');
INSERT INTO international VALUES (55,'WebGUI','Deutsch','Passwort\r\n(bestätigen)');
INSERT INTO international VALUES (89,'WebGUI','Dutch','Groepen');
INSERT INTO international VALUES (89,'WebGUI','English','Groups');
INSERT INTO international VALUES (89,'WebGUI','Español','Grupos');
INSERT INTO international VALUES (89,'WebGUI','Português','Grupos');
INSERT INTO international VALUES (90,'WebGUI','Dutch','Voeg nieuwe groep toe.');
INSERT INTO international VALUES (90,'WebGUI','English','Add new group.');
INSERT INTO international VALUES (90,'WebGUI','Español','Agregar nuevo grupo');
INSERT INTO international VALUES (90,'WebGUI','Português','Adicionar novo grupo.');
INSERT INTO international VALUES (91,'WebGUI','Dutch','Vorige pagina');
INSERT INTO international VALUES (91,'WebGUI','English','Previous Page');
INSERT INTO international VALUES (91,'WebGUI','Español','Página previa');
INSERT INTO international VALUES (91,'WebGUI','Português','Página anterior');
INSERT INTO international VALUES (92,'WebGUI','Dutch','Volgende pagina');
INSERT INTO international VALUES (92,'WebGUI','English','Next Page');
INSERT INTO international VALUES (92,'WebGUI','Español','Siguiente página');
INSERT INTO international VALUES (92,'WebGUI','Português','Próxima página');
INSERT INTO international VALUES (93,'WebGUI','Dutch','Help');
INSERT INTO international VALUES (93,'WebGUI','English','Help');
INSERT INTO international VALUES (93,'WebGUI','Español','Ayuda');
INSERT INTO international VALUES (93,'WebGUI','Português','Ajuda');
INSERT INTO international VALUES (94,'WebGUI','Dutch','Zie ook');
INSERT INTO international VALUES (94,'WebGUI','English','See also');
INSERT INTO international VALUES (94,'WebGUI','Español','Vea también');
INSERT INTO international VALUES (94,'WebGUI','Português','Ver tembém');
INSERT INTO international VALUES (57,'WebGUI','Deutsch','(Dies ist nur\r\nnotwendig, wenn Sie Eigenschaften benutzen möchten die eine Emailadresse\r\nvoraussetzen)');
INSERT INTO international VALUES (95,'WebGUI','Dutch','Help index');
INSERT INTO international VALUES (95,'WebGUI','English','Help Index');
INSERT INTO international VALUES (95,'WebGUI','Español','Índice de Ayuda');
INSERT INTO international VALUES (95,'WebGUI','Português','Indice da ajuda');
INSERT INTO international VALUES (56,'WebGUI','Deutsch','Email Adresse');
INSERT INTO international VALUES (96,'WebGUI','Dutch','Gesorteerd op acti');
INSERT INTO international VALUES (96,'WebGUI','English','Sorted By Action');
INSERT INTO international VALUES (96,'WebGUI','Español','Ordenar por Acción');
INSERT INTO international VALUES (96,'WebGUI','Português','Ordenar por acção');
INSERT INTO international VALUES (97,'WebGUI','Dutch','Gesorteerd op object');
INSERT INTO international VALUES (97,'WebGUI','English','Sorted by Object');
INSERT INTO international VALUES (97,'WebGUI','Español','Ordenar por Objeto');
INSERT INTO international VALUES (97,'WebGUI','Português','Ordenar por objecto');
INSERT INTO international VALUES (5,'LinkList','Svenska','Fortsätt med att lägga till en länk?');
INSERT INTO international VALUES (5,'Item','Svenska','Ladda ned bilaga');
INSERT INTO international VALUES (58,'WebGUI','Deutsch','Ich besitze\r\nbereits ein Benutzerkonto.');
INSERT INTO international VALUES (99,'WebGUI','Dutch','Titel');
INSERT INTO international VALUES (99,'WebGUI','English','Title');
INSERT INTO international VALUES (99,'WebGUI','Español','Título');
INSERT INTO international VALUES (99,'WebGUI','Português','Titulo');
INSERT INTO international VALUES (100,'WebGUI','Dutch','Meta tags');
INSERT INTO international VALUES (100,'WebGUI','English','Meta Tags');
INSERT INTO international VALUES (100,'WebGUI','Español','Meta Tags');
INSERT INTO international VALUES (100,'WebGUI','Português','Meta Tags');
INSERT INTO international VALUES (59,'WebGUI','Deutsch','Ich habe mein\r\nPasswort vergessen');
INSERT INTO international VALUES (101,'WebGUI','Dutch','Weet u zeker dat u deze pagina wilt verwijderen en alle inhoud en objecten erachter?');
INSERT INTO international VALUES (101,'WebGUI','English','Are you certain that you wish to delete this page, its content, and all items under it?');
INSERT INTO international VALUES (101,'WebGUI','Español','Está seguro de querer eliminar ésta página');
INSERT INTO international VALUES (101,'WebGUI','Português','\"Tem a certeza que quer apagar esta página, o seu conteudo e tudo que está abaixo?\"');
INSERT INTO international VALUES (102,'WebGUI','Dutch','Bewerk pagina');
INSERT INTO international VALUES (102,'WebGUI','English','Edit Page');
INSERT INTO international VALUES (102,'WebGUI','Español','Editar Página');
INSERT INTO international VALUES (102,'WebGUI','Português','Modificar a página');
INSERT INTO international VALUES (103,'WebGUI','Dutch','Pagina specifiek');
INSERT INTO international VALUES (103,'WebGUI','English','Page Specifics');
INSERT INTO international VALUES (103,'WebGUI','Español','Propio de la página');
INSERT INTO international VALUES (103,'WebGUI','Português','Especificações da página');
INSERT INTO international VALUES (104,'WebGUI','Dutch','Pagina URL');
INSERT INTO international VALUES (104,'WebGUI','English','Page URL');
INSERT INTO international VALUES (104,'WebGUI','Español','URL de la página');
INSERT INTO international VALUES (104,'WebGUI','Português','URL da página');
INSERT INTO international VALUES (105,'WebGUI','Dutch','Stijl');
INSERT INTO international VALUES (105,'WebGUI','English','Style');
INSERT INTO international VALUES (105,'WebGUI','Español','Estilo');
INSERT INTO international VALUES (105,'WebGUI','Português','Estilo');
INSERT INTO international VALUES (60,'WebGUI','Deutsch','Sind Sie sicher,\r\ndass Sie dieses Benutzerkonto deaktivieren möchten? Wenn Sie fortfahren\r\nsind Ihre Konteninformationen endgültig verloren.');
INSERT INTO international VALUES (106,'WebGUI','Dutch','Aanvinken om deze stijl in alle pagina\'s te gebruiiken.');
INSERT INTO international VALUES (106,'WebGUI','English','Select \"Yes\" to change all the pages under this page to this style.');
INSERT INTO international VALUES (106,'WebGUI','Español','Marque para dar éste estilo a todas las sub-páginas.');
INSERT INTO international VALUES (106,'WebGUI','Português','Escolha para atribuir este estilo a todas as sub-páginas');
INSERT INTO international VALUES (107,'WebGUI','Dutch','Privileges');
INSERT INTO international VALUES (107,'WebGUI','English','Privileges');
INSERT INTO international VALUES (107,'WebGUI','Español','Privilegios');
INSERT INTO international VALUES (107,'WebGUI','Português','Privilégios');
INSERT INTO international VALUES (108,'WebGUI','Dutch','Eigenaar');
INSERT INTO international VALUES (108,'WebGUI','English','Owner');
INSERT INTO international VALUES (108,'WebGUI','Español','Dueño');
INSERT INTO international VALUES (108,'WebGUI','Português','Dono');
INSERT INTO international VALUES (61,'WebGUI','Deutsch','Benutzerkontendetails aktualisieren');
INSERT INTO international VALUES (109,'WebGUI','Dutch','Eigenaar kan bekijken?');
INSERT INTO international VALUES (109,'WebGUI','English','Owner can view?');
INSERT INTO international VALUES (109,'WebGUI','Español','Dueño puede ver?');
INSERT INTO international VALUES (109,'WebGUI','Português','O dono pode ver?');
INSERT INTO international VALUES (110,'WebGUI','Dutch','Gebruiker kan bewerken?');
INSERT INTO international VALUES (110,'WebGUI','English','Owner can edit?');
INSERT INTO international VALUES (110,'WebGUI','Español','Dueño puede editar?');
INSERT INTO international VALUES (110,'WebGUI','Português','O dono pode modificar?');
INSERT INTO international VALUES (64,'WebGUI','Deutsch','Abmelden');
INSERT INTO international VALUES (111,'WebGUI','Dutch','Groep');
INSERT INTO international VALUES (111,'WebGUI','English','Group');
INSERT INTO international VALUES (111,'WebGUI','Español','Grupo');
INSERT INTO international VALUES (111,'WebGUI','Português','Grupo');
INSERT INTO international VALUES (112,'WebGUI','Dutch','Groep kan bekijken?');
INSERT INTO international VALUES (112,'WebGUI','English','Group can view?');
INSERT INTO international VALUES (112,'WebGUI','Español','Grupo puede ver?');
INSERT INTO international VALUES (112,'WebGUI','Português','O grupo pode ver?');
INSERT INTO international VALUES (113,'WebGUI','Dutch','Groep kan bewerken?');
INSERT INTO international VALUES (113,'WebGUI','English','Group can edit?');
INSERT INTO international VALUES (113,'WebGUI','Español','Grupo puede editar?');
INSERT INTO international VALUES (113,'WebGUI','Português','O grupo pode modificar?');
INSERT INTO international VALUES (63,'WebGUI','Deutsch','Administrationsmodus einschalten');
INSERT INTO international VALUES (114,'WebGUI','Dutch','Iedereen kan bekijken?');
INSERT INTO international VALUES (114,'WebGUI','English','Anybody can view?');
INSERT INTO international VALUES (114,'WebGUI','Español','Cualquiera puede ver?');
INSERT INTO international VALUES (114,'WebGUI','Português','Qualquer pessoa pode ver?');
INSERT INTO international VALUES (115,'WebGUI','Dutch','Iedereen kan bewerken?');
INSERT INTO international VALUES (115,'WebGUI','English','Anybody can edit?');
INSERT INTO international VALUES (115,'WebGUI','Español','Cualquiera puede editar?');
INSERT INTO international VALUES (115,'WebGUI','Português','Qualquer pessoa pode modificar?');
INSERT INTO international VALUES (62,'WebGUI','Deutsch','sichern');
INSERT INTO international VALUES (116,'WebGUI','Dutch','Aanvinken om deze privileges aan alle sub pagina\'s te geven.');
INSERT INTO international VALUES (116,'WebGUI','English','Select \"Yes\" to change the privileges of all pages under this page to these privileges.');
INSERT INTO international VALUES (116,'WebGUI','Español','Marque para dar éstos privilegios a todas las sub-páginas.');
INSERT INTO international VALUES (116,'WebGUI','Português','Escolher para atribuir estes privilégios a todas as sub-páginas.');
INSERT INTO international VALUES (117,'WebGUI','Dutch','Bewerk toegangs controle instellingen');
INSERT INTO international VALUES (117,'WebGUI','English','Edit User Settings');
INSERT INTO international VALUES (117,'WebGUI','Español','Editar Opciones de Auntentificación');
INSERT INTO international VALUES (117,'WebGUI','Português','Modificar preferências de autenticação');
INSERT INTO international VALUES (65,'WebGUI','Deutsch','Benutzerkonto\r\nendgültig deaktivieren');
INSERT INTO international VALUES (118,'WebGUI','Dutch','Anonieme registratie');
INSERT INTO international VALUES (118,'WebGUI','English','Anonymous Registration');
INSERT INTO international VALUES (118,'WebGUI','Español','Registración Anónima');
INSERT INTO international VALUES (118,'WebGUI','Português','Registo anónimo');
INSERT INTO international VALUES (119,'WebGUI','Dutch','Toegangs controle methode (standaard)');
INSERT INTO international VALUES (119,'WebGUI','English','Authentication Method (default)');
INSERT INTO international VALUES (119,'WebGUI','Español','Método de Autentificación (por defecto)');
INSERT INTO international VALUES (119,'WebGUI','Português','Método de autenticação (defeito)');
INSERT INTO international VALUES (120,'WebGUI','Dutch','LDAP URL (standaard)');
INSERT INTO international VALUES (120,'WebGUI','English','LDAP URL (default)');
INSERT INTO international VALUES (120,'WebGUI','Español','URL LDAP (por defecto)');
INSERT INTO international VALUES (120,'WebGUI','Português','URL LDAP (defeito)');
INSERT INTO international VALUES (121,'WebGUI','Dutch','LDAP identiteit (standaard)');
INSERT INTO international VALUES (121,'WebGUI','English','LDAP Identity (default)');
INSERT INTO international VALUES (121,'WebGUI','Español','Identidad LDAP (por defecto)');
INSERT INTO international VALUES (121,'WebGUI','Português','Identidade LDAP (defeito)');
INSERT INTO international VALUES (122,'WebGUI','Dutch','LDAP identiteit naam');
INSERT INTO international VALUES (122,'WebGUI','English','LDAP Identity Name');
INSERT INTO international VALUES (122,'WebGUI','Español','Nombre Identidad LDAP');
INSERT INTO international VALUES (122,'WebGUI','Português','Nome da entidade LDAP');
INSERT INTO international VALUES (123,'WebGUI','Dutch','LDAP wachtwoord naam');
INSERT INTO international VALUES (123,'WebGUI','English','LDAP Password Name');
INSERT INTO international VALUES (123,'WebGUI','Español','Password LDAP');
INSERT INTO international VALUES (123,'WebGUI','Português','Nome da password LDAP');
INSERT INTO international VALUES (124,'WebGUI','Dutch','Bewerk bedrijfsinformatie');
INSERT INTO international VALUES (124,'WebGUI','English','Edit Company Information');
INSERT INTO international VALUES (124,'WebGUI','Español','Editar Información de la Companía');
INSERT INTO international VALUES (124,'WebGUI','Português','Modificar informação da empresa');
INSERT INTO international VALUES (125,'WebGUI','Dutch','Bedrijfsnaam');
INSERT INTO international VALUES (125,'WebGUI','English','Company Name');
INSERT INTO international VALUES (125,'WebGUI','Español','Nombre de la Companía');
INSERT INTO international VALUES (125,'WebGUI','Português','Nome da empresa');
INSERT INTO international VALUES (126,'WebGUI','Dutch','Email adres bedrijf');
INSERT INTO international VALUES (126,'WebGUI','English','Company Email Address');
INSERT INTO international VALUES (126,'WebGUI','Español','E-mail de la Companía');
INSERT INTO international VALUES (126,'WebGUI','Português','Moarada da empresa');
INSERT INTO international VALUES (68,'WebGUI','Deutsch','Die\r\nBenutzerkontoinformationen die Sie eingegeben haben, sind ungültig.\r\nEntweder existiert das Konto nicht, oder die Kombination aus Benutzername\r\nund Passwort ist falsch.');
INSERT INTO international VALUES (127,'WebGUI','Dutch','URL bedrijf');
INSERT INTO international VALUES (127,'WebGUI','English','Company URL');
INSERT INTO international VALUES (127,'WebGUI','Español','URL de la Companía');
INSERT INTO international VALUES (127,'WebGUI','Português','URL da empresa');
INSERT INTO international VALUES (128,'WebGUI','Dutch','Bewerk bestandsinstellingen');
INSERT INTO international VALUES (128,'WebGUI','English','Edit File Settings');
INSERT INTO international VALUES (128,'WebGUI','Español','Editar Opciones de Archivos');
INSERT INTO international VALUES (128,'WebGUI','Português','Modificar preferências de ficheiros');
INSERT INTO international VALUES (67,'WebGUI','Deutsch','Neues\r\nBenutzerkonto einrichten');
INSERT INTO international VALUES (129,'WebGUI','Dutch','Pad naar WebGUI extra\'s');
INSERT INTO international VALUES (129,'WebGUI','English','Path to WebGUI Extras');
INSERT INTO international VALUES (129,'WebGUI','Español','Camino a Extras de WebGUI');
INSERT INTO international VALUES (129,'WebGUI','Português','Caminho para os extras do WebGUI');
INSERT INTO international VALUES (66,'WebGUI','Deutsch','Anmelden');
INSERT INTO international VALUES (130,'WebGUI','Dutch','Maximum grootte bijlagen');
INSERT INTO international VALUES (130,'WebGUI','English','Maximum Attachment Size');
INSERT INTO international VALUES (130,'WebGUI','Español','Tamaño máximo de adjuntos');
INSERT INTO international VALUES (130,'WebGUI','Português','Tamanho máximo dos anexos');
INSERT INTO international VALUES (131,'WebGUI','Dutch','Web bijlage pad');
INSERT INTO international VALUES (131,'WebGUI','English','Web Attachment Path');
INSERT INTO international VALUES (131,'WebGUI','Español','Camino Web de los archivos adjuntos');
INSERT INTO international VALUES (131,'WebGUI','Português','caminho de anexos via web');
INSERT INTO international VALUES (132,'WebGUI','Dutch','Server bijlage pad');
INSERT INTO international VALUES (132,'WebGUI','English','Server Attachment Path');
INSERT INTO international VALUES (132,'WebGUI','Español','Camino en server de los archivos adjuntos');
INSERT INTO international VALUES (132,'WebGUI','Português','Caminho de anexos no servidor');
INSERT INTO international VALUES (69,'WebGUI','Deutsch','Bitten Sie Ihren\r\nSystemadministrator um Hilfe.');
INSERT INTO international VALUES (133,'WebGUI','Dutch','Bewerk email instellingen');
INSERT INTO international VALUES (133,'WebGUI','English','Edit Mail Settings');
INSERT INTO international VALUES (133,'WebGUI','Español','Editar configuración de e-mail');
INSERT INTO international VALUES (133,'WebGUI','Português','Modificar preferências de e-mail');
INSERT INTO international VALUES (70,'WebGUI','Deutsch','Fehler');
INSERT INTO international VALUES (134,'WebGUI','Dutch','Bericht om wachtwoord terug te vinden');
INSERT INTO international VALUES (134,'WebGUI','English','Recover Password Message');
INSERT INTO international VALUES (134,'WebGUI','Español','Mensage de Recuperar Password');
INSERT INTO international VALUES (134,'WebGUI','Português','Mensagem de recuperação de password');
INSERT INTO international VALUES (135,'WebGUI','Dutch','SMTP server');
INSERT INTO international VALUES (135,'WebGUI','English','SMTP Server');
INSERT INTO international VALUES (135,'WebGUI','Español','Servidor SMTP');
INSERT INTO international VALUES (135,'WebGUI','Português','Servidor SMTP');
INSERT INTO international VALUES (71,'WebGUI','Deutsch','Passwort\r\nwiederherstellen');
INSERT INTO international VALUES (72,'WebGUI','Deutsch','wiederherstellen');
INSERT INTO international VALUES (138,'WebGUI','Dutch','Ja');
INSERT INTO international VALUES (138,'WebGUI','English','Yes');
INSERT INTO international VALUES (138,'WebGUI','Español','Si');
INSERT INTO international VALUES (138,'WebGUI','Português','Sim');
INSERT INTO international VALUES (139,'WebGUI','Dutch','Nee');
INSERT INTO international VALUES (139,'WebGUI','English','No');
INSERT INTO international VALUES (139,'WebGUI','Español','No');
INSERT INTO international VALUES (139,'WebGUI','Português','Não');
INSERT INTO international VALUES (75,'WebGUI','Deutsch','Ihre\r\nBenutzerkonteninformation wurde an Ihre Emailadresse geschickt');
INSERT INTO international VALUES (140,'WebGUI','Dutch','Bewerk allerlei instellingen');
INSERT INTO international VALUES (140,'WebGUI','English','Edit Miscellaneous Settings');
INSERT INTO international VALUES (140,'WebGUI','Español','Editar configuraciones misceláneas');
INSERT INTO international VALUES (140,'WebGUI','Português','Modificar preferências mistas');
INSERT INTO international VALUES (141,'WebGUI','Dutch','Niet gevonden pagina');
INSERT INTO international VALUES (141,'WebGUI','English','Not Found Page');
INSERT INTO international VALUES (141,'WebGUI','Español','Página no encontrada');
INSERT INTO international VALUES (141,'WebGUI','Português','Página não encontrada');
INSERT INTO international VALUES (74,'WebGUI','Deutsch','Benutzerkonteninformation');
INSERT INTO international VALUES (142,'WebGUI','Dutch','Sessie time out');
INSERT INTO international VALUES (142,'WebGUI','English','Session Timeout');
INSERT INTO international VALUES (142,'WebGUI','Español','Timeout de sesión');
INSERT INTO international VALUES (142,'WebGUI','Português','Timeout de sessão');
INSERT INTO international VALUES (73,'WebGUI','Deutsch','Anmelden');
INSERT INTO international VALUES (143,'WebGUI','Dutch','Beheer instellingen.');
INSERT INTO international VALUES (143,'WebGUI','English','Manage Settings');
INSERT INTO international VALUES (143,'WebGUI','Español','Configurar Opciones');
INSERT INTO international VALUES (143,'WebGUI','Português','Organizar preferências');
INSERT INTO international VALUES (144,'WebGUI','Dutch','Bekijk statistieken');
INSERT INTO international VALUES (144,'WebGUI','English','View statistics.');
INSERT INTO international VALUES (144,'WebGUI','Español','Ver estadísticas');
INSERT INTO international VALUES (144,'WebGUI','Português','Ver estatisticas.');
INSERT INTO international VALUES (145,'WebGUI','Dutch','WebGUI versie');
INSERT INTO international VALUES (145,'WebGUI','English','WebGUI Build Version');
INSERT INTO international VALUES (145,'WebGUI','Español','Versión de WebGUI');
INSERT INTO international VALUES (145,'WebGUI','Português','WebGUI versão');
INSERT INTO international VALUES (76,'WebGUI','Deutsch','Ihre Emailadresse\r\nist nicht in unserer Datenbank.');
INSERT INTO international VALUES (146,'WebGUI','Dutch','Aktieve sessies');
INSERT INTO international VALUES (146,'WebGUI','English','Active Sessions');
INSERT INTO international VALUES (146,'WebGUI','Español','Sesiones activas');
INSERT INTO international VALUES (146,'WebGUI','Português','Sessões activas');
INSERT INTO international VALUES (147,'WebGUI','Dutch','Pagina\'s');
INSERT INTO international VALUES (147,'WebGUI','English','Pages');
INSERT INTO international VALUES (147,'WebGUI','Español','Páginas');
INSERT INTO international VALUES (147,'WebGUI','Português','Páginas');
INSERT INTO international VALUES (148,'WebGUI','Dutch','Wobjects');
INSERT INTO international VALUES (148,'WebGUI','English','Wobjects');
INSERT INTO international VALUES (148,'WebGUI','Español','Wobjects');
INSERT INTO international VALUES (148,'WebGUI','Português','Wobjects');
INSERT INTO international VALUES (149,'WebGUI','Dutch','Gebruikers');
INSERT INTO international VALUES (149,'WebGUI','English','Users');
INSERT INTO international VALUES (149,'WebGUI','Español','Usuarios');
INSERT INTO international VALUES (149,'WebGUI','Português','Utilizadores');
INSERT INTO international VALUES (151,'WebGUI','Dutch','Stijl naam');
INSERT INTO international VALUES (151,'WebGUI','English','Style Name');
INSERT INTO international VALUES (151,'WebGUI','Español','Nombre del Estilo');
INSERT INTO international VALUES (151,'WebGUI','Português','Nome do estilo');
INSERT INTO international VALUES (505,'WebGUI','English','Add a new template.');
INSERT INTO international VALUES (504,'WebGUI','English','Template');
INSERT INTO international VALUES (503,'WebGUI','English','Template ID');
INSERT INTO international VALUES (502,'WebGUI','English','Are you certain you wish to delete this template and set all pages using this template to the default template?');
INSERT INTO international VALUES (154,'WebGUI','Dutch','Style sheet');
INSERT INTO international VALUES (154,'WebGUI','English','Style Sheet');
INSERT INTO international VALUES (154,'WebGUI','Español','Hoja de Estilo');
INSERT INTO international VALUES (154,'WebGUI','Português','Estilo de página');
INSERT INTO international VALUES (77,'WebGUI','Deutsch','Ein anderes\r\nMitglied dieser Seiten benutzt bereits diesen Namen. Bitte wählen Sie einen\r\nanderen Benutzernamen. Hier sind einige Vorschläge:');
INSERT INTO international VALUES (79,'WebGUI','Deutsch','Verbindung zum\r\nLDAP-Server konnte nicht hergestellt werden.');
INSERT INTO international VALUES (155,'WebGUI','Dutch','Weet u zeker dat u deze stijl wilt verwijderen en migreer alle pagina\'s met de “fail safe” stijl?');
INSERT INTO international VALUES (155,'WebGUI','English','Are you certain you wish to delete this style and migrate all pages using this style to the \"Fail Safe\" style?');
INSERT INTO international VALUES (155,'WebGUI','Español','\"Está seguro de querer eliminar éste estilo y migrar todas la páginas que lo usen al estilo \"\"Fail Safe\"\"?\"');
INSERT INTO international VALUES (155,'WebGUI','Português','\"Tem a certeza que quer apagar este estilo e migrar todas as páginas para o estilo \"\"Fail Safe\"\"?\"');
INSERT INTO international VALUES (156,'WebGUI','Dutch','Bewerk stijl');
INSERT INTO international VALUES (156,'WebGUI','English','Edit Style');
INSERT INTO international VALUES (156,'WebGUI','Español','Editar Estilo');
INSERT INTO international VALUES (156,'WebGUI','Português','Modificar estilo');
INSERT INTO international VALUES (157,'WebGUI','Dutch','Stijlen');
INSERT INTO international VALUES (157,'WebGUI','English','Styles');
INSERT INTO international VALUES (157,'WebGUI','Español','Estilos');
INSERT INTO international VALUES (157,'WebGUI','Português','Estilos');
INSERT INTO international VALUES (158,'WebGUI','Dutch','Een nieuwe stijl toevoegen.');
INSERT INTO international VALUES (158,'WebGUI','English','Add a new style.');
INSERT INTO international VALUES (158,'WebGUI','Español','Agregar nuevo Estilo');
INSERT INTO international VALUES (158,'WebGUI','Português','Adicionar novo estilo.');
INSERT INTO international VALUES (159,'WebGUI','Dutch','Berichten log');
INSERT INTO international VALUES (471,'WebGUI','Dansk','Rediger bruger profil felt');
INSERT INTO international VALUES (159,'WebGUI','Español','Contribuciones Pendientes');
INSERT INTO international VALUES (159,'WebGUI','Português','Log das mensagens');
INSERT INTO international VALUES (160,'WebGUI','Dutch','Invoer datum');
INSERT INTO international VALUES (160,'WebGUI','English','Date Submitted');
INSERT INTO international VALUES (160,'WebGUI','Español','Fecha Contribución');
INSERT INTO international VALUES (160,'WebGUI','Português','Data de submissão');
INSERT INTO international VALUES (78,'WebGUI','Deutsch','Die Passworte\r\nunterscheiden sich. Bitte versuchen Sie es noch einmal.');
INSERT INTO international VALUES (161,'WebGUI','Dutch','Ingevoerd door');
INSERT INTO international VALUES (161,'WebGUI','English','Submitted By');
INSERT INTO international VALUES (161,'WebGUI','Español','Contribuido por');
INSERT INTO international VALUES (161,'WebGUI','Português','Submetido por');
INSERT INTO international VALUES (162,'WebGUI','Dutch','Weet u zeker dat u alle pagina\'s en wobjects uit de prullenbak wilt verwijderen?');
INSERT INTO international VALUES (162,'WebGUI','English','Are you certain that you wish to purge all the pages and wobjects in the trash?');
INSERT INTO international VALUES (162,'WebGUI','Español','Está seguro de querer eliminar todos los elementos de la papelera?');
INSERT INTO international VALUES (162,'WebGUI','Português','Tem a certeza que quer limpar todas as páginas e wobjects para o caixote do lixo?');
INSERT INTO international VALUES (80,'WebGUI','Deutsch','Benutzerkonto\r\nwurde angelegt');
INSERT INTO international VALUES (163,'WebGUI','Dutch','Gebruiker toevoegen');
INSERT INTO international VALUES (163,'WebGUI','English','Add User');
INSERT INTO international VALUES (163,'WebGUI','Español','Agregar usuario');
INSERT INTO international VALUES (163,'WebGUI','Português','Adicionar utilizador');
INSERT INTO international VALUES (164,'WebGUI','Dutch','Toegangs controle methode');
INSERT INTO international VALUES (164,'WebGUI','English','Authentication Method');
INSERT INTO international VALUES (164,'WebGUI','Español','Método de Auntentificación');
INSERT INTO international VALUES (164,'WebGUI','Português','Metodo de autenticação');
INSERT INTO international VALUES (165,'WebGUI','Dutch','LDAP URL');
INSERT INTO international VALUES (165,'WebGUI','English','LDAP URL');
INSERT INTO international VALUES (165,'WebGUI','Español','LDAP URL');
INSERT INTO international VALUES (165,'WebGUI','Português','LDAP URL');
INSERT INTO international VALUES (81,'WebGUI','Deutsch','Benutzerkonto\r\nwurde aktualisiert');
INSERT INTO international VALUES (166,'WebGUI','Dutch','Verbindt DN');
INSERT INTO international VALUES (166,'WebGUI','English','Connect DN');
INSERT INTO international VALUES (166,'WebGUI','Español','Connect DN');
INSERT INTO international VALUES (166,'WebGUI','Português','Connectar DN');
INSERT INTO international VALUES (82,'WebGUI','Deutsch','Administrative\r\nFunktionen ...');
INSERT INTO international VALUES (167,'WebGUI','Dutch','Weet u zeker dat u deze gebruiker wilt verwijderen? Alle gebruikersinformatie wordt permanent verwijdert als u door gaat.');
INSERT INTO international VALUES (167,'WebGUI','English','Are you certain you want to delete this user? Be warned that all this user\'s information will be lost permanently if you choose to proceed.');
INSERT INTO international VALUES (167,'WebGUI','Español','Está seguro de querer eliminar éste usuario? Tenga en cuenta que toda la información del usuario será eliminada permanentemente si procede.');
INSERT INTO international VALUES (167,'WebGUI','Português','Tem a certeza que quer apagar este utilizador? Se o fizer perde todas as informações do utilizador.');
INSERT INTO international VALUES (168,'WebGUI','Dutch','Bewerk gebruiker');
INSERT INTO international VALUES (168,'WebGUI','English','Edit User');
INSERT INTO international VALUES (168,'WebGUI','Español','Editar Usuario');
INSERT INTO international VALUES (168,'WebGUI','Português','Modificar utilizador');
INSERT INTO international VALUES (169,'WebGUI','Dutch','Een nieuwe gebruiker toevoegen.');
INSERT INTO international VALUES (169,'WebGUI','English','Add a new user.');
INSERT INTO international VALUES (169,'WebGUI','Español','Agregar nuevo usuario');
INSERT INTO international VALUES (169,'WebGUI','Português','Adicionar utilizador.');
INSERT INTO international VALUES (84,'WebGUI','Deutsch','Gruppenname');
INSERT INTO international VALUES (170,'WebGUI','Dutch','Zoeken');
INSERT INTO international VALUES (170,'WebGUI','English','search');
INSERT INTO international VALUES (170,'WebGUI','Español','buscar');
INSERT INTO international VALUES (170,'WebGUI','Português','procurar');
INSERT INTO international VALUES (171,'WebGUI','Dutch','Rich edit');
INSERT INTO international VALUES (171,'WebGUI','English','rich edit');
INSERT INTO international VALUES (171,'WebGUI','Español','rich edit');
INSERT INTO international VALUES (171,'WebGUI','Português','rich edit');
INSERT INTO international VALUES (85,'WebGUI','Deutsch','Beschreibung');
INSERT INTO international VALUES (174,'WebGUI','Dutch','Titel laten zien?');
INSERT INTO international VALUES (174,'WebGUI','English','Display the title?');
INSERT INTO international VALUES (174,'WebGUI','Español','Mostrar el título?');
INSERT INTO international VALUES (174,'WebGUI','Português','Mostrar o titulo?');
INSERT INTO international VALUES (175,'WebGUI','Dutch','Macro\'s uitvoeren?');
INSERT INTO international VALUES (175,'WebGUI','English','Process macros?');
INSERT INTO international VALUES (175,'WebGUI','Español','Procesar macros?');
INSERT INTO international VALUES (175,'WebGUI','Português','Processar macros?');
INSERT INTO international VALUES (228,'WebGUI','Dutch','Bewerk bericht...');
INSERT INTO international VALUES (228,'WebGUI','English','Editing Message...');
INSERT INTO international VALUES (228,'WebGUI','Español','Editar Mensage...');
INSERT INTO international VALUES (228,'WebGUI','Português','Modificando mensagem...');
INSERT INTO international VALUES (229,'WebGUI','Dutch','Onderwerp');
INSERT INTO international VALUES (229,'WebGUI','English','Subject');
INSERT INTO international VALUES (229,'WebGUI','Español','Asunto');
INSERT INTO international VALUES (229,'WebGUI','Português','Assunto');
INSERT INTO international VALUES (230,'WebGUI','Dutch','Bericht');
INSERT INTO international VALUES (230,'WebGUI','English','Message');
INSERT INTO international VALUES (230,'WebGUI','Español','Mensage');
INSERT INTO international VALUES (230,'WebGUI','Português','Mensagem');
INSERT INTO international VALUES (231,'WebGUI','Dutch','Bezig met bericht posten...');
INSERT INTO international VALUES (231,'WebGUI','English','Posting New Message...');
INSERT INTO international VALUES (231,'WebGUI','Español','Mandando Nuevo Mensage ...');
INSERT INTO international VALUES (231,'WebGUI','Português','Colocando nova mensagem...');
INSERT INTO international VALUES (232,'WebGUI','Dutch','Geen onderwerp');
INSERT INTO international VALUES (232,'WebGUI','English','no subject');
INSERT INTO international VALUES (232,'WebGUI','Español','sin título');
INSERT INTO international VALUES (232,'WebGUI','Português','sem assunto');
INSERT INTO international VALUES (233,'WebGUI','Dutch','(einde)');
INSERT INTO international VALUES (233,'WebGUI','English','(eom)');
INSERT INTO international VALUES (233,'WebGUI','Español','(eom)');
INSERT INTO international VALUES (233,'WebGUI','Português','(eom)');
INSERT INTO international VALUES (234,'WebGUI','Dutch','Bezig met antwoord posten');
INSERT INTO international VALUES (234,'WebGUI','English','Posting Reply...');
INSERT INTO international VALUES (234,'WebGUI','Español','Respondiendo...');
INSERT INTO international VALUES (234,'WebGUI','Português','Respondendo...');
INSERT INTO international VALUES (86,'WebGUI','Deutsch','Sind Sie sicher,\r\ndass Sie diese Gruppe löschen möchten? Denken Sie daran, dass diese Gruppe\r\nund die zugehörige Rechtesstruktur endgültig gelöscht wird.');
INSERT INTO international VALUES (237,'WebGUI','Dutch','Onderwerp:');
INSERT INTO international VALUES (237,'WebGUI','English','Subject:');
INSERT INTO international VALUES (237,'WebGUI','Español','Asunto:');
INSERT INTO international VALUES (237,'WebGUI','Português','Assunto:');
INSERT INTO international VALUES (238,'WebGUI','Dutch','Naam:');
INSERT INTO international VALUES (238,'WebGUI','English','Author:');
INSERT INTO international VALUES (238,'WebGUI','Español','Autor:');
INSERT INTO international VALUES (238,'WebGUI','Português','Autor:');
INSERT INTO international VALUES (239,'WebGUI','Dutch','Datum:');
INSERT INTO international VALUES (239,'WebGUI','English','Date:');
INSERT INTO international VALUES (239,'WebGUI','Español','Fecha:');
INSERT INTO international VALUES (239,'WebGUI','Português','Data:');
INSERT INTO international VALUES (87,'WebGUI','Deutsch','Gruppe\r\nbearbeiten');
INSERT INTO international VALUES (240,'WebGUI','Dutch','Bericht ID:');
INSERT INTO international VALUES (240,'WebGUI','English','Message ID:');
INSERT INTO international VALUES (240,'WebGUI','Español','ID del mensage:');
INSERT INTO international VALUES (240,'WebGUI','Português','ID da mensagem:');
INSERT INTO international VALUES (244,'WebGUI','Dutch','Afzender');
INSERT INTO international VALUES (244,'WebGUI','English','Author');
INSERT INTO international VALUES (244,'WebGUI','Español','Autor');
INSERT INTO international VALUES (244,'WebGUI','Português','Autor');
INSERT INTO international VALUES (88,'WebGUI','Deutsch','Benutzer in dieser\r\nGruppe');
INSERT INTO international VALUES (245,'WebGUI','Dutch','Datum');
INSERT INTO international VALUES (245,'WebGUI','English','Date');
INSERT INTO international VALUES (245,'WebGUI','Español','Fecha');
INSERT INTO international VALUES (245,'WebGUI','Português','Data');
INSERT INTO international VALUES (304,'WebGUI','Dutch','Taal');
INSERT INTO international VALUES (304,'WebGUI','English','Language');
INSERT INTO international VALUES (304,'WebGUI','Español','Idioma');
INSERT INTO international VALUES (304,'WebGUI','Português','Lingua');
INSERT INTO international VALUES (90,'WebGUI','Deutsch','Neue Gruppe\r\nhinzufügen');
INSERT INTO international VALUES (306,'WebGUI','Dutch','Bind gebruikersnaam');
INSERT INTO international VALUES (306,'WebGUI','English','Username Binding');
INSERT INTO international VALUES (306,'WebGUI','Português','Ligação ao username');
INSERT INTO international VALUES (307,'WebGUI','Dutch','Gebruik standaard metag tags?');
INSERT INTO international VALUES (307,'WebGUI','English','Use default meta tags?');
INSERT INTO international VALUES (307,'WebGUI','Português','Usar as meta tags de defeito?');
INSERT INTO international VALUES (308,'WebGUI','Dutch','Bewerk profiel instellingen');
INSERT INTO international VALUES (308,'WebGUI','English','Edit Profile Settings');
INSERT INTO international VALUES (308,'WebGUI','Português','Modificar as preferências do perfil');
INSERT INTO international VALUES (89,'WebGUI','Deutsch','Gruppen');
INSERT INTO international VALUES (309,'WebGUI','Dutch','Sta echte naam toe?');
INSERT INTO international VALUES (309,'WebGUI','English','Allow real name?');
INSERT INTO international VALUES (309,'WebGUI','Português','Permitir o nome real?');
INSERT INTO international VALUES (91,'WebGUI','Deutsch','Vorherige Seite');
INSERT INTO international VALUES (310,'WebGUI','Dutch','Sta extra contact informatie toe?');
INSERT INTO international VALUES (310,'WebGUI','English','Allow extra contact information?');
INSERT INTO international VALUES (310,'WebGUI','Português','Permitir informação extra de contacto?');
INSERT INTO international VALUES (92,'WebGUI','Deutsch','Nächste Seite');
INSERT INTO international VALUES (311,'WebGUI','Dutch','Sta thuis informatie toe?');
INSERT INTO international VALUES (311,'WebGUI','English','Allow home information?');
INSERT INTO international VALUES (311,'WebGUI','Português','Permitir informação de casa?');
INSERT INTO international VALUES (95,'WebGUI','Deutsch','Hilfe');
INSERT INTO international VALUES (312,'WebGUI','Dutch','Sta bedrijfs informatie toe?');
INSERT INTO international VALUES (312,'WebGUI','English','Allow business information?');
INSERT INTO international VALUES (312,'WebGUI','Português','Permitir informação do emprego?');
INSERT INTO international VALUES (94,'WebGUI','Deutsch','Siehe auch');
INSERT INTO international VALUES (313,'WebGUI','Dutch','Sta andere informatie toe?');
INSERT INTO international VALUES (313,'WebGUI','English','Allow miscellaneous information?');
INSERT INTO international VALUES (313,'WebGUI','Português','Permitir informaçao mista?');
INSERT INTO international VALUES (93,'WebGUI','Deutsch','Hilfe');
INSERT INTO international VALUES (314,'WebGUI','Dutch','Voornaam');
INSERT INTO international VALUES (314,'WebGUI','English','First Name');
INSERT INTO international VALUES (314,'WebGUI','Português','Nome');
INSERT INTO international VALUES (315,'WebGUI','Dutch','Tussenvoegsel');
INSERT INTO international VALUES (315,'WebGUI','English','Middle Name');
INSERT INTO international VALUES (315,'WebGUI','Português','segundo(s) nome(s)');
INSERT INTO international VALUES (96,'WebGUI','Deutsch','Sortiert nach\r\nAktion');
INSERT INTO international VALUES (316,'WebGUI','Dutch','Achternaam');
INSERT INTO international VALUES (316,'WebGUI','English','Last Name');
INSERT INTO international VALUES (316,'WebGUI','Português','Apelido');
INSERT INTO international VALUES (97,'WebGUI','Deutsch','Sortiert nach\r\nObjekt');
INSERT INTO international VALUES (317,'WebGUI','Dutch','\"<a href=\"\"http://www.icq.com\"\">ICQ</a> UIN\"');
INSERT INTO international VALUES (317,'WebGUI','English','<a href=\"http://www.icq.com\">ICQ</a> UIN');
INSERT INTO international VALUES (317,'WebGUI','Português','\"<a href=\"\"http://www.icq.com\"\">ICQ</a> UIN\"');
INSERT INTO international VALUES (318,'WebGUI','Dutch','\"<a href=\"\"http://www.aol.com/aim/homenew.adp\"\">AIM</a> Id\"');
INSERT INTO international VALUES (318,'WebGUI','English','<a href=\"http://www.aol.com/aim/homenew.adp\">AIM</a> Id');
INSERT INTO international VALUES (318,'WebGUI','Português','\"<a href=\"\"http://www.aol.com/aim/homenew.adp\"\">AIM</a> Id\"');
INSERT INTO international VALUES (99,'WebGUI','Deutsch','Titel');
INSERT INTO international VALUES (5,'MessageBoard','Svenska','Redigera Timeout');
INSERT INTO international VALUES (319,'WebGUI','Dutch','\"<a href=\"\"http://messenger.msn.com/\"\">MSN Messenger</a> Id\"');
INSERT INTO international VALUES (319,'WebGUI','English','<a href=\"http://messenger.msn.com/\">MSN Messenger</a> Id');
INSERT INTO international VALUES (319,'WebGUI','Português','\"<a href=\"\"http://messenger.msn.com/\"\">MSN Messenger</a> Id\"');
INSERT INTO international VALUES (320,'WebGUI','Dutch','\"<a href=\"\"http://messenger.yahoo.com/\"\">Yahoo! Messenger</a> Id\"');
INSERT INTO international VALUES (320,'WebGUI','English','<a href=\"http://messenger.yahoo.com/\">Yahoo! Messenger</a> Id');
INSERT INTO international VALUES (320,'WebGUI','Português','\"<a href=\"\"http://messenger.yahoo.com/\"\">Yahoo! Messenger</a> Id\"');
INSERT INTO international VALUES (321,'WebGUI','Dutch','Mobiel nummer');
INSERT INTO international VALUES (321,'WebGUI','English','Cell Phone');
INSERT INTO international VALUES (321,'WebGUI','Português','Telemóvel');
INSERT INTO international VALUES (322,'WebGUI','Dutch','Pager');
INSERT INTO international VALUES (322,'WebGUI','English','Pager');
INSERT INTO international VALUES (322,'WebGUI','Português','Pager');
INSERT INTO international VALUES (323,'WebGUI','Dutch','Thuis adres');
INSERT INTO international VALUES (323,'WebGUI','English','Home Address');
INSERT INTO international VALUES (323,'WebGUI','Português','Morada (de casa)');
INSERT INTO international VALUES (101,'WebGUI','Deutsch','Sind Sie sicher,\r\ndass Sie diese Seite und ihren kompletten Inhalt darunter löschen\r\nmöchten?');
INSERT INTO international VALUES (324,'WebGUI','Dutch','Thuis plaats');
INSERT INTO international VALUES (324,'WebGUI','English','Home City');
INSERT INTO international VALUES (324,'WebGUI','Português','Cidade (de casa)');
INSERT INTO international VALUES (100,'WebGUI','Deutsch','Meta Tags');
INSERT INTO international VALUES (325,'WebGUI','Dutch','Thuis staat');
INSERT INTO international VALUES (325,'WebGUI','English','Home State');
INSERT INTO international VALUES (325,'WebGUI','Português','Concelho (de casa)');
INSERT INTO international VALUES (326,'WebGUI','Dutch','Thuis postcode');
INSERT INTO international VALUES (326,'WebGUI','English','Home Zip Code');
INSERT INTO international VALUES (326,'WebGUI','Português','Código postal (de casa)');
INSERT INTO international VALUES (327,'WebGUI','Dutch','Thuis land');
INSERT INTO international VALUES (327,'WebGUI','English','Home Country');
INSERT INTO international VALUES (327,'WebGUI','Português','País (de casa)');
INSERT INTO international VALUES (102,'WebGUI','Deutsch','Seite\r\nbearbeiten');
INSERT INTO international VALUES (328,'WebGUI','Dutch','Thuis telefoon');
INSERT INTO international VALUES (328,'WebGUI','English','Home Phone');
INSERT INTO international VALUES (328,'WebGUI','Português','Telefone (de casa)');
INSERT INTO international VALUES (329,'WebGUI','Dutch','Werk adres');
INSERT INTO international VALUES (329,'WebGUI','English','Work Address');
INSERT INTO international VALUES (329,'WebGUI','Português','Morada (do emprego)');
INSERT INTO international VALUES (103,'WebGUI','Deutsch','Seitenspezifikation');
INSERT INTO international VALUES (330,'WebGUI','Dutch','Werk stad');
INSERT INTO international VALUES (330,'WebGUI','English','Work City');
INSERT INTO international VALUES (330,'WebGUI','Português','Cidade (do emprego)');
INSERT INTO international VALUES (331,'WebGUI','Dutch','Werk staat');
INSERT INTO international VALUES (331,'WebGUI','English','Work State');
INSERT INTO international VALUES (331,'WebGUI','Português','Concelho (do emprego)');
INSERT INTO international VALUES (104,'WebGUI','Deutsch','URL der Seite');
INSERT INTO international VALUES (332,'WebGUI','Dutch','Werk postcode');
INSERT INTO international VALUES (332,'WebGUI','English','Work Zip Code');
INSERT INTO international VALUES (332,'WebGUI','Português','Código postal (do emprego)');
INSERT INTO international VALUES (333,'WebGUI','Dutch','Werk land');
INSERT INTO international VALUES (333,'WebGUI','English','Work Country');
INSERT INTO international VALUES (333,'WebGUI','Português','País (do emprego)');
INSERT INTO international VALUES (334,'WebGUI','Dutch','Werk telefoon');
INSERT INTO international VALUES (334,'WebGUI','English','Work Phone');
INSERT INTO international VALUES (334,'WebGUI','Português','Telefone (do emprego)');
INSERT INTO international VALUES (335,'WebGUI','Dutch','Sexe');
INSERT INTO international VALUES (335,'WebGUI','English','Gender');
INSERT INTO international VALUES (335,'WebGUI','Português','Sexo');
INSERT INTO international VALUES (106,'WebGUI','Deutsch','Stil an alle\r\nnachfolgenden Seiten weitergeben.');
INSERT INTO international VALUES (336,'WebGUI','Dutch','Geboortedatum');
INSERT INTO international VALUES (336,'WebGUI','English','Birth Date');
INSERT INTO international VALUES (336,'WebGUI','Português','Data de nascimento');
INSERT INTO international VALUES (337,'WebGUI','Dutch','Home pagina URL');
INSERT INTO international VALUES (337,'WebGUI','English','Homepage URL');
INSERT INTO international VALUES (337,'WebGUI','Português','Endereço da Homepage');
INSERT INTO international VALUES (338,'WebGUI','Dutch','Bewerk profiel');
INSERT INTO international VALUES (338,'WebGUI','English','Edit Profile');
INSERT INTO international VALUES (338,'WebGUI','Português','Modificar perfil');
INSERT INTO international VALUES (105,'WebGUI','Deutsch','Stil');
INSERT INTO international VALUES (339,'WebGUI','Dutch','Man');
INSERT INTO international VALUES (339,'WebGUI','English','Male');
INSERT INTO international VALUES (339,'WebGUI','Português','Masculino');
INSERT INTO international VALUES (107,'WebGUI','Deutsch','Rechte');
INSERT INTO international VALUES (340,'WebGUI','Dutch','Vrouw');
INSERT INTO international VALUES (340,'WebGUI','English','Female');
INSERT INTO international VALUES (340,'WebGUI','Português','Feminino');
INSERT INTO international VALUES (341,'WebGUI','Dutch','Bewerk profiel.');
INSERT INTO international VALUES (341,'WebGUI','English','Edit profile.');
INSERT INTO international VALUES (341,'WebGUI','Português','Modificar o perfil.');
INSERT INTO international VALUES (109,'WebGUI','Deutsch','Besitzer kann\r\nanschauen?');
INSERT INTO international VALUES (342,'WebGUI','Dutch','Bewerk account informatie.');
INSERT INTO international VALUES (342,'WebGUI','English','Edit account information.');
INSERT INTO international VALUES (342,'WebGUI','Português','Modificar as informações da conta.');
INSERT INTO international VALUES (108,'WebGUI','Deutsch','Besitzer');
INSERT INTO international VALUES (343,'WebGUI','Dutch','Bekijk profiel.');
INSERT INTO international VALUES (343,'WebGUI','English','View profile.');
INSERT INTO international VALUES (343,'WebGUI','Português','Ver perfil.');
INSERT INTO international VALUES (351,'WebGUI','English','Message');
INSERT INTO international VALUES (468,'WebGUI','Dansk','Rediger bruger profil kategori');
INSERT INTO international VALUES (345,'WebGUI','Dutch','Geen lid');
INSERT INTO international VALUES (345,'WebGUI','English','Not A Member');
INSERT INTO international VALUES (345,'WebGUI','Português','Não é membro');
INSERT INTO international VALUES (112,'WebGUI','Deutsch','Gruppe kann\r\nanschauen?');
INSERT INTO international VALUES (110,'WebGUI','Deutsch','Besitzer kann\r\nbearbeiten?');
INSERT INTO international VALUES (346,'WebGUI','Dutch','Deze gebruiker in geen lid meer van onze site. We hebben geen informatie meer over deze gebruiker.');
INSERT INTO international VALUES (346,'WebGUI','English','This user is no longer a member of our site. We have no further information about this user.');
INSERT INTO international VALUES (346,'WebGUI','Português','Esse utilizador já não é membro do site. Não existe mais informação.');
INSERT INTO international VALUES (111,'WebGUI','Deutsch','Gruppe');
INSERT INTO international VALUES (347,'WebGUI','Dutch','Bekijk profiel van');
INSERT INTO international VALUES (347,'WebGUI','English','View Profile For');
INSERT INTO international VALUES (347,'WebGUI','Português','Ver o perfil de');
INSERT INTO international VALUES (348,'WebGUI','Dutch','Naam');
INSERT INTO international VALUES (348,'WebGUI','English','Name');
INSERT INTO international VALUES (348,'WebGUI','Português','Nome');
INSERT INTO international VALUES (349,'WebGUI','Dutch','Laatst beschikbare versie');
INSERT INTO international VALUES (349,'WebGUI','English','Latest version available');
INSERT INTO international VALUES (349,'WebGUI','Português','Ultima versão disponível');
INSERT INTO international VALUES (350,'WebGUI','Dutch','Klaar');
INSERT INTO international VALUES (350,'WebGUI','English','Completed');
INSERT INTO international VALUES (350,'WebGUI','Português','Completo');
INSERT INTO international VALUES (351,'WebGUI','Dutch','Berichten log toevoeging');
INSERT INTO international VALUES (351,'WebGUI','Português','Entrada no log de mensagens');
INSERT INTO international VALUES (352,'WebGUI','Dutch','Datum van toevoeging');
INSERT INTO international VALUES (352,'WebGUI','English','Date Of Entry');
INSERT INTO international VALUES (352,'WebGUI','Português','Data de entrada');
INSERT INTO international VALUES (353,'WebGUI','Dutch','U heeft nu geen berichten log toevoegingen.');
INSERT INTO international VALUES (471,'WebGUI','Svenska','Redigera Användar Profil Attribut');
INSERT INTO international VALUES (353,'WebGUI','Português','Actualmente não tem entradas no log de mensagens.');
INSERT INTO international VALUES (354,'WebGUI','Dutch','Bekijk berichten log.');
INSERT INTO international VALUES (471,'WebGUI','English','Edit User Profile Field');
INSERT INTO international VALUES (354,'WebGUI','Português','Ver o log das mensagens.');
INSERT INTO international VALUES (355,'WebGUI','Dutch','Standaar');
INSERT INTO international VALUES (355,'WebGUI','English','Default');
INSERT INTO international VALUES (355,'WebGUI','Português','Por defeito');
INSERT INTO international VALUES (356,'WebGUI','English','Template');
INSERT INTO international VALUES (357,'WebGUI','English','News');
INSERT INTO international VALUES (358,'WebGUI','English','Left Column');
INSERT INTO international VALUES (359,'WebGUI','English','Right Column');
INSERT INTO international VALUES (360,'WebGUI','English','One Over Three');
INSERT INTO international VALUES (361,'WebGUI','English','Three Over One');
INSERT INTO international VALUES (362,'WebGUI','English','SideBySide');
INSERT INTO international VALUES (363,'WebGUI','English','Template Position');
INSERT INTO international VALUES (364,'WebGUI','English','Search');
INSERT INTO international VALUES (365,'WebGUI','English','Search results...');
INSERT INTO international VALUES (366,'WebGUI','English','No  pages were found with content that matched your query.');
INSERT INTO international VALUES (368,'WebGUI','English','Add a new group to this user.');
INSERT INTO international VALUES (369,'WebGUI','English','Expire Date');
INSERT INTO international VALUES (370,'WebGUI','English','Edit Grouping');
INSERT INTO international VALUES (371,'WebGUI','English','Add Grouping');
INSERT INTO international VALUES (372,'WebGUI','English','Edit User\'s Groups');
INSERT INTO international VALUES (373,'WebGUI','English','<b>Warning:</b> By editing the group list above, you\'ll reset all expiry information for each group to their new defaults.');
INSERT INTO international VALUES (374,'WebGUI','English','Manage packages.');
INSERT INTO international VALUES (375,'WebGUI','English','Select Package To Deploy');
INSERT INTO international VALUES (376,'WebGUI','English','Package');
INSERT INTO international VALUES (377,'WebGUI','English','No packages have been defined by your package manager(s) or administrator(s).');
INSERT INTO international VALUES (11,'Poll','English','Vote!');
INSERT INTO international VALUES (31,'UserSubmission','English','Content');
INSERT INTO international VALUES (32,'UserSubmission','English','Image');
INSERT INTO international VALUES (33,'UserSubmission','English','Attachement');
INSERT INTO international VALUES (34,'UserSubmission','English','Convert Carriage Returns');
INSERT INTO international VALUES (35,'UserSubmission','English','Title');
INSERT INTO international VALUES (21,'EventsCalendar','English','Proceed to add event?');
INSERT INTO international VALUES (378,'WebGUI','English','User ID');
INSERT INTO international VALUES (379,'WebGUI','English','Group ID');
INSERT INTO international VALUES (380,'WebGUI','English','Style ID');
INSERT INTO international VALUES (381,'WebGUI','English','WebGUI received a malformed request and was unable to continue. Proprietary characters being passed through a form typically cause this. Please feel free to hit your back button and try again.');
INSERT INTO international VALUES (1,'DownloadManager','English','Download Manager');
INSERT INTO international VALUES (1,'EventsCalendar','Svenska','Fortsätt med att lägga till en händelse?');
INSERT INTO international VALUES (3,'DownloadManager','English','Proceed to add file?');
INSERT INTO international VALUES (367,'WebGUI','Svenska','Bäst före');
INSERT INTO international VALUES (5,'DownloadManager','English','File Title');
INSERT INTO international VALUES (6,'DownloadManager','English','Download File');
INSERT INTO international VALUES (7,'DownloadManager','English','Group to Download');
INSERT INTO international VALUES (8,'DownloadManager','English','Brief Synopsis');
INSERT INTO international VALUES (9,'DownloadManager','English','Edit Download Manager');
INSERT INTO international VALUES (10,'DownloadManager','English','Edit Download');
INSERT INTO international VALUES (11,'DownloadManager','English','Add a new download.');
INSERT INTO international VALUES (12,'DownloadManager','English','Are you certain that you wish to delete this download?');
INSERT INTO international VALUES (22,'DownloadManager','English','Proceed to add download?');
INSERT INTO international VALUES (14,'DownloadManager','English','File');
INSERT INTO international VALUES (15,'DownloadManager','English','Description');
INSERT INTO international VALUES (16,'DownloadManager','English','Date Uploaded');
INSERT INTO international VALUES (15,'Article','English','Right');
INSERT INTO international VALUES (16,'Article','English','Left');
INSERT INTO international VALUES (17,'Article','English','Center');
INSERT INTO international VALUES (37,'UserSubmission','English','Delete');
INSERT INTO international VALUES (13,'SQLReport','English','Convert carriage returns?');
INSERT INTO international VALUES (17,'DownloadManager','English','Alternate Version #1');
INSERT INTO international VALUES (18,'DownloadManager','English','Alternate Version #2');
INSERT INTO international VALUES (19,'DownloadManager','English','You have no files available for download.');
INSERT INTO international VALUES (14,'EventsCalendar','English','Start Date');
INSERT INTO international VALUES (15,'EventsCalendar','English','End Date');
INSERT INTO international VALUES (20,'DownloadManager','English','Paginate After');
INSERT INTO international VALUES (14,'SQLReport','English','Paginate After');
INSERT INTO international VALUES (16,'EventsCalendar','English','Calendar Layout');
INSERT INTO international VALUES (17,'EventsCalendar','English','List');
INSERT INTO international VALUES (18,'EventsCalendar','English','Calendar');
INSERT INTO international VALUES (19,'EventsCalendar','English','Paginate After');
INSERT INTO international VALUES (383,'WebGUI','English','Name');
INSERT INTO international VALUES (384,'WebGUI','English','File');
INSERT INTO international VALUES (385,'WebGUI','English','Parameters');
INSERT INTO international VALUES (386,'WebGUI','English','Edit Image');
INSERT INTO international VALUES (387,'WebGUI','English','Uploaded By');
INSERT INTO international VALUES (388,'WebGUI','English','Upload Date');
INSERT INTO international VALUES (389,'WebGUI','English','Image Id');
INSERT INTO international VALUES (390,'WebGUI','English','Displaying Image...');
INSERT INTO international VALUES (391,'WebGUI','English','Delete attached file.');
INSERT INTO international VALUES (392,'WebGUI','English','Are you certain that you wish to delete this image?');
INSERT INTO international VALUES (393,'WebGUI','English','Manage Images');
INSERT INTO international VALUES (394,'WebGUI','English','Manage images.');
INSERT INTO international VALUES (395,'WebGUI','English','Add a new image.');
INSERT INTO international VALUES (396,'WebGUI','English','View Image');
INSERT INTO international VALUES (397,'WebGUI','English','Back to image list.');
INSERT INTO international VALUES (398,'WebGUI','English','Document Type Declaration');
INSERT INTO international VALUES (399,'WebGUI','English','Validate this page.');
INSERT INTO international VALUES (400,'WebGUI','English','Prevent Proxy Caching');
INSERT INTO international VALUES (401,'WebGUI','English','Are you certain you wish to delete this message and all messages under it in this thread?');
INSERT INTO international VALUES (21,'MessageBoard','English','Who can moderate?');
INSERT INTO international VALUES (22,'MessageBoard','English','Delete Message');
INSERT INTO international VALUES (402,'WebGUI','English','The message you requested does not exist.');
INSERT INTO international VALUES (403,'WebGUI','English','Prefer not to say.');
INSERT INTO international VALUES (405,'WebGUI','English','Last Page');
INSERT INTO international VALUES (406,'WebGUI','English','Thumbnail Size');
INSERT INTO international VALUES (21,'DownloadManager','English','Display thumbnails?');
INSERT INTO international VALUES (407,'WebGUI','English','Click here to register.');
INSERT INTO international VALUES (15,'SQLReport','English','Preprocess macros on query?');
INSERT INTO international VALUES (16,'SQLReport','English','Debug?');
INSERT INTO international VALUES (17,'SQLReport','English','<b>Debug:</b> Query:');
INSERT INTO international VALUES (18,'SQLReport','English','There were no results for this query.');
INSERT INTO international VALUES (113,'WebGUI','Deutsch','Gruppe kann\r\nbearbeiten?');
INSERT INTO international VALUES (114,'WebGUI','Deutsch','Kann jeder\r\nanschauen?');
INSERT INTO international VALUES (116,'WebGUI','Deutsch','Rechte an alle\r\nnachfolgenden Seiten weitergeben.');
INSERT INTO international VALUES (115,'WebGUI','Deutsch','Kann jeder\r\nbearbeiten?');
INSERT INTO international VALUES (118,'WebGUI','Deutsch','anonyme\r\nRegistrierung');
INSERT INTO international VALUES (117,'WebGUI','Deutsch','Authentifizierungseinstellungen bearbeiten');
INSERT INTO international VALUES (120,'WebGUI','Deutsch','LDAP URL\r\n(Standard)');
INSERT INTO international VALUES (119,'WebGUI','Deutsch','Authentifizierungsmethode (Standard)');
INSERT INTO international VALUES (121,'WebGUI','Deutsch','LDAP Identität\r\n(Standard)');
INSERT INTO international VALUES (123,'WebGUI','Deutsch','LDAP Passwort\r\nName');
INSERT INTO international VALUES (122,'WebGUI','Deutsch','LDAP\r\nIdentitäts-Name');
INSERT INTO international VALUES (124,'WebGUI','Deutsch','Firmeninformationen bearbeiten');
INSERT INTO international VALUES (127,'WebGUI','Deutsch','Webseite der\r\nFirma');
INSERT INTO international VALUES (126,'WebGUI','Deutsch','Emailadresse der\r\nFirma');
INSERT INTO international VALUES (125,'WebGUI','Deutsch','Firmenname');
INSERT INTO international VALUES (129,'WebGUI','Deutsch','Pfad zu WebGUI\r\nExtras');
INSERT INTO international VALUES (128,'WebGUI','Deutsch','Dateieinstellungen bearbeiten');
INSERT INTO international VALUES (130,'WebGUI','Deutsch','Maximale\r\nDateigröße für Anhänge');
INSERT INTO international VALUES (132,'WebGUI','Deutsch','Pfad für\r\nDateianhänge auf dem Server');
INSERT INTO international VALUES (131,'WebGUI','Deutsch','Pfad für\r\nDateianhänge im Web');
INSERT INTO international VALUES (133,'WebGUI','Deutsch','Maileinstellungen\r\nbearbeiten');
INSERT INTO international VALUES (134,'WebGUI','Deutsch','Passwortmeldung\r\nwiederherstellen');
INSERT INTO international VALUES (135,'WebGUI','Deutsch','SMTP Server');
INSERT INTO international VALUES (138,'WebGUI','Deutsch','Ja');
INSERT INTO international VALUES (139,'WebGUI','Deutsch','Nein');
INSERT INTO international VALUES (143,'WebGUI','Deutsch','Einstellungen\r\nverwalten');
INSERT INTO international VALUES (142,'WebGUI','Deutsch','Sitzungs\r\nZeitüberschreitung');
INSERT INTO international VALUES (141,'WebGUI','Deutsch','\"Nicht gefunden\r\nSeite\"');
INSERT INTO international VALUES (140,'WebGUI','Deutsch','Sonstige\r\nEinstellungen bearbeiten');
INSERT INTO international VALUES (144,'WebGUI','Deutsch','Auswertungen\r\nanschauen');
INSERT INTO international VALUES (145,'WebGUI','Deutsch','WebGUI Build\r\nVersion');
INSERT INTO international VALUES (147,'WebGUI','Deutsch','sichtbare\r\nSeiten');
INSERT INTO international VALUES (146,'WebGUI','Deutsch','Aktive\r\nSitzungen');
INSERT INTO international VALUES (148,'WebGUI','Deutsch','Wobjects');
INSERT INTO international VALUES (149,'WebGUI','Deutsch','Benutzer');
INSERT INTO international VALUES (506,'WebGUI','English','Manage Templates');
INSERT INTO international VALUES (151,'WebGUI','Deutsch','Stil Name');
INSERT INTO international VALUES (154,'WebGUI','Deutsch','Style Sheet');
INSERT INTO international VALUES (155,'WebGUI','Deutsch','Sind Sie sicher,\r\ndass Sie diesen Stil löschen und alle Seiten die diesen Stil benutzen in\r\nden Stil \"Fail Safe\" überführen wollen?');
INSERT INTO international VALUES (156,'WebGUI','Deutsch','Stil\r\nbearbeiten');
INSERT INTO international VALUES (157,'WebGUI','Deutsch','Stile');
INSERT INTO international VALUES (159,'WebGUI','Deutsch','Ausstehende\r\nBeiträge');
INSERT INTO international VALUES (158,'WebGUI','Deutsch','Neuen Stil\r\nhinzufügen');
INSERT INTO international VALUES (161,'WebGUI','Deutsch','Erstellt von');
INSERT INTO international VALUES (160,'WebGUI','Deutsch','Erstellungsdatum');
INSERT INTO international VALUES (162,'WebGUI','Deutsch','Sind Sie sicher,\r\ndass Sie alle Seiten und Wobjects im Mülleimer löschen möchten?');
INSERT INTO international VALUES (163,'WebGUI','Deutsch','Benutzer\r\nhinzufügen');
INSERT INTO international VALUES (164,'WebGUI','Deutsch','Authentifizierungsmethode');
INSERT INTO international VALUES (165,'WebGUI','Deutsch','LDAP URL');
INSERT INTO international VALUES (166,'WebGUI','Deutsch','Connect DN');
INSERT INTO international VALUES (167,'WebGUI','Deutsch','Sind Sie sicher,\r\ndass sie diesen Benutzer löschen möchten? Die Benutzerinformation geht\r\ndamit endgültig verloren!');
INSERT INTO international VALUES (168,'WebGUI','Deutsch','Benutzer\r\nbearbeiten');
INSERT INTO international VALUES (174,'WebGUI','Deutsch','Titel\r\nanzeigen?');
INSERT INTO international VALUES (170,'WebGUI','Deutsch','suchen');
INSERT INTO international VALUES (171,'WebGUI','Deutsch','Bearbeiten mit\r\nAttributen');
INSERT INTO international VALUES (169,'WebGUI','Deutsch','Neuen Benutzer\r\nhinzufügen');
INSERT INTO international VALUES (228,'WebGUI','Deutsch','Beiträge\r\nbearbeiten ...');
INSERT INTO international VALUES (175,'WebGUI','Deutsch','Makros\r\nausführen?');
INSERT INTO international VALUES (232,'WebGUI','Deutsch','kein Betreff');
INSERT INTO international VALUES (229,'WebGUI','Deutsch','Betreff');
INSERT INTO international VALUES (230,'WebGUI','Deutsch','Beitrag');
INSERT INTO international VALUES (238,'WebGUI','Deutsch','Autor:');
INSERT INTO international VALUES (231,'WebGUI','Deutsch','Neuen Beitrag\r\nschreiben...');
INSERT INTO international VALUES (237,'WebGUI','Deutsch','Betreff:');
INSERT INTO international VALUES (234,'WebGUI','Deutsch','Antworten...');
INSERT INTO international VALUES (233,'WebGUI','Deutsch','(eom)');
INSERT INTO international VALUES (304,'WebGUI','Deutsch','Sprache');
INSERT INTO international VALUES (245,'WebGUI','Deutsch','Datum');
INSERT INTO international VALUES (240,'WebGUI','Deutsch','Beitrags ID:');
INSERT INTO international VALUES (244,'WebGUI','Deutsch','Autor');
INSERT INTO international VALUES (239,'WebGUI','Deutsch','Datum:');
INSERT INTO international VALUES (306,'WebGUI','Deutsch','Benutze LDAP\r\nBenutzername');
INSERT INTO international VALUES (308,'WebGUI','Deutsch','Profil\r\nbearbeiten');
INSERT INTO international VALUES (307,'WebGUI','Deutsch','Standard Meta\r\nTags benutzen?');
INSERT INTO international VALUES (310,'WebGUI','Deutsch','Kontaktinformationen anzeigen?');
INSERT INTO international VALUES (309,'WebGUI','Deutsch','Name anzeigen?');
INSERT INTO international VALUES (311,'WebGUI','Deutsch','Privatadresse\r\nanzeigen?');
INSERT INTO international VALUES (312,'WebGUI','Deutsch','Geschäftsadresse\r\nanzeigen?');
INSERT INTO international VALUES (313,'WebGUI','Deutsch','Zusätzliche\r\nInformationen anzeigen?');
INSERT INTO international VALUES (315,'WebGUI','Deutsch','Zweiter\r\nVorname');
INSERT INTO international VALUES (314,'WebGUI','Deutsch','Vorname');
INSERT INTO international VALUES (316,'WebGUI','Deutsch','Nachname');
INSERT INTO international VALUES (318,'WebGUI','Deutsch','<a href=\"\"\r\nhttp://www.aol.com/aim/homenew.adp\"\">AIM</a> Id');
INSERT INTO international VALUES (317,'WebGUI','Deutsch','<a href=\"\"\r\nhttp://www.icq.com\"\">ICQ</a> UIN');
INSERT INTO international VALUES (319,'WebGUI','Deutsch','<a href=\"\"\r\nhttp://messenger.msn.com/\"\">MSN Messenger</a> Id');
INSERT INTO international VALUES (320,'WebGUI','Deutsch','<a href=\"\"\r\nhttp://messenger.yahoo.com/\"\">Yahoo! Messenger</a> Id');
INSERT INTO international VALUES (322,'WebGUI','Deutsch','Pager');
INSERT INTO international VALUES (321,'WebGUI','Deutsch','Mobiltelefon');
INSERT INTO international VALUES (324,'WebGUI','Deutsch','Ort (privat)');
INSERT INTO international VALUES (323,'WebGUI','Deutsch','Strasse\r\n(privat)');
INSERT INTO international VALUES (325,'WebGUI','Deutsch','Bundesland\r\n(privat)');
INSERT INTO international VALUES (329,'WebGUI','Deutsch','Strasse (Büro)');
INSERT INTO international VALUES (328,'WebGUI','Deutsch','Telefon\r\n(privat)');
INSERT INTO international VALUES (327,'WebGUI','Deutsch','Land (privat)');
INSERT INTO international VALUES (326,'WebGUI','Deutsch','Postleitzahl\r\n(privat)');
INSERT INTO international VALUES (332,'WebGUI','Deutsch','Postleitzahl\r\n(Büro)');
INSERT INTO international VALUES (330,'WebGUI','Deutsch','Ort (Büro)');
INSERT INTO international VALUES (331,'WebGUI','Deutsch','Bundesland\r\n(Büro)');
INSERT INTO international VALUES (333,'WebGUI','Deutsch','Land (Büro)');
INSERT INTO international VALUES (335,'WebGUI','Deutsch','Geschlecht');
INSERT INTO international VALUES (334,'WebGUI','Deutsch','Telefon (Büro)');
INSERT INTO international VALUES (336,'WebGUI','Deutsch','Geburtstag');
INSERT INTO international VALUES (337,'WebGUI','Deutsch','Homepage URL');
INSERT INTO international VALUES (339,'WebGUI','Deutsch','männlich');
INSERT INTO international VALUES (338,'WebGUI','Deutsch','Profil\r\nbearbeiten');
INSERT INTO international VALUES (343,'WebGUI','Deutsch','Profil\r\nanschauen.');
INSERT INTO international VALUES (353,'WebGUI','English','You have no messages in your Inbox at this time.');
INSERT INTO international VALUES (342,'WebGUI','Deutsch','Benutzerkonto\r\nbearbeiten.');
INSERT INTO international VALUES (341,'WebGUI','Deutsch','Profil\r\nbearbeiten.');
INSERT INTO international VALUES (340,'WebGUI','Deutsch','weiblich');
INSERT INTO international VALUES (345,'WebGUI','Deutsch','Kein Mitglied');
INSERT INTO international VALUES (346,'WebGUI','Deutsch','Dieser Benutzer\r\nist kein Mitglied. Wir haben keine weiteren Informationen über ihn.');
INSERT INTO international VALUES (347,'WebGUI','Deutsch','Profil anschauen\r\nvon');
INSERT INTO international VALUES (349,'WebGUI','Deutsch','Aktuelle\r\nVersion');
INSERT INTO international VALUES (348,'WebGUI','Deutsch','Name');
INSERT INTO international VALUES (352,'WebGUI','Deutsch','Beitragsdatum');
INSERT INTO international VALUES (351,'WebGUI','Deutsch','Beitragseingang');
INSERT INTO international VALUES (350,'WebGUI','Deutsch','Abgeschlossen');
INSERT INTO international VALUES (353,'WebGUI','Deutsch','Zur Zeit sind\r\nkeine ausstehenden Beiträge vorhanden.');
INSERT INTO international VALUES (355,'WebGUI','Deutsch','Standard');
INSERT INTO international VALUES (356,'WebGUI','Deutsch','Vorlage');
INSERT INTO international VALUES (354,'WebGUI','Deutsch','Beitrags Log\r\nanschauen.');
INSERT INTO international VALUES (359,'WebGUI','Deutsch','Rechte Spalte');
INSERT INTO international VALUES (360,'WebGUI','Deutsch','Einer über\r\ndrei');
INSERT INTO international VALUES (357,'WebGUI','Deutsch','Nachrichten');
INSERT INTO international VALUES (358,'WebGUI','Deutsch','Linke Spalte');
INSERT INTO international VALUES (361,'WebGUI','Deutsch','Drei über\r\neinem');
INSERT INTO international VALUES (362,'WebGUI','Deutsch','Nebeneinander');
INSERT INTO international VALUES (364,'WebGUI','Deutsch','Suchen');
INSERT INTO international VALUES (363,'WebGUI','Deutsch','Position des\r\nTemplates');
INSERT INTO international VALUES (365,'WebGUI','Deutsch','Ergebnisse der\r\nAbfrage');
INSERT INTO international VALUES (366,'WebGUI','Deutsch','Es wurden keine\r\nSeiten gefunden, die zu Ihrer Abfrage passen.');
INSERT INTO international VALUES (367,'WebGUI','Deutsch','verfällt nach');
INSERT INTO international VALUES (370,'WebGUI','Deutsch','Gruppierung\r\nbearbeiten');
INSERT INTO international VALUES (369,'WebGUI','Deutsch','Verfallsdatum');
INSERT INTO international VALUES (368,'WebGUI','Deutsch','Diesem Benutzer\r\neine neue Gruppe hinzufügen.');
INSERT INTO international VALUES (371,'WebGUI','Deutsch','Gruppierung\r\nhinzufügen');
INSERT INTO international VALUES (372,'WebGUI','Deutsch','Gruppen eines\r\nBenutzers bearbeiten');
INSERT INTO international VALUES (373,'WebGUI','Deutsch','<b>Warnung:</b>\r\nWenn Sie obige Gruppenliste editieren, werden die Verfallsdaten jeder\r\nGruppe auf neue Standartwerte gesetzt.');
INSERT INTO international VALUES (374,'WebGUI','Deutsch','Pakete\r\nanschauen');
INSERT INTO international VALUES (375,'WebGUI','Deutsch','Paket auswählen,\r\ndas verteilt werden soll');
INSERT INTO international VALUES (377,'WebGUI','Deutsch','Von Ihren (Paket)\r\n-Administratoren wurden keine Pakete bereitgestellt.');
INSERT INTO international VALUES (376,'WebGUI','Deutsch','Paket');
INSERT INTO international VALUES (378,'WebGUI','Deutsch','Benutzer ID');
INSERT INTO international VALUES (381,'WebGUI','Deutsch','WebGUI hat eine\r\nverstümmelte Anfrage erhalten und kann nicht weitermachen. Üblicherweise\r\nwird das durch Sonderzeichen verursacht. Nutzen Sie bitte den \"Zurück\"\r\nButton Ihres Browsers und versuchen Sie es noch einmal.');
INSERT INTO international VALUES (380,'WebGUI','Deutsch','Stil ID');
INSERT INTO international VALUES (379,'WebGUI','Deutsch','Gruppen ID');
INSERT INTO international VALUES (383,'WebGUI','Deutsch','Name');
INSERT INTO international VALUES (384,'WebGUI','Deutsch','Datei');
INSERT INTO international VALUES (386,'WebGUI','Deutsch','Bild\r\nbearbeiten');
INSERT INTO international VALUES (385,'WebGUI','Deutsch','Parameter');
INSERT INTO international VALUES (387,'WebGUI','Deutsch','Zur Verfügung\r\ngestellt von');
INSERT INTO international VALUES (388,'WebGUI','Deutsch','Upload Datum');
INSERT INTO international VALUES (389,'WebGUI','Deutsch','Grafik Id');
INSERT INTO international VALUES (390,'WebGUI','Deutsch','Grafik anzeigen\r\n...');
INSERT INTO international VALUES (391,'WebGUI','Deutsch','Anhang löschen');
INSERT INTO international VALUES (393,'WebGUI','Deutsch','Grafiken\r\nverwalten');
INSERT INTO international VALUES (392,'WebGUI','Deutsch','Sind Sie sicher,\r\ndass Sie diese Grafik löschen wollen?');
INSERT INTO international VALUES (394,'WebGUI','Deutsch','Grafiken\r\nverwalten');
INSERT INTO international VALUES (408,'WebGUI','English','Manage Roots');
INSERT INTO international VALUES (409,'WebGUI','English','Add a new root.');
INSERT INTO international VALUES (410,'WebGUI','English','Manage roots.');
INSERT INTO international VALUES (411,'WebGUI','English','Menu Title');
INSERT INTO international VALUES (412,'WebGUI','English','Synopsis');
INSERT INTO international VALUES (9,'SiteMap','English','Display synopsis?');
INSERT INTO international VALUES (18,'Article','English','Allow discussion?');
INSERT INTO international VALUES (19,'Article','English','Who can post?');
INSERT INTO international VALUES (20,'Article','English','Who can moderate?');
INSERT INTO international VALUES (21,'Article','English','Edit Timeout');
INSERT INTO international VALUES (22,'Article','English','Author');
INSERT INTO international VALUES (23,'Article','English','Date');
INSERT INTO international VALUES (24,'Article','English','Post Response');
INSERT INTO international VALUES (25,'Article','English','Edit Response');
INSERT INTO international VALUES (26,'Article','English','Delete Response');
INSERT INTO international VALUES (27,'Article','English','Back To Article');
INSERT INTO international VALUES (413,'WebGUI','English','On Critical Error');
INSERT INTO international VALUES (28,'Article','English','View Responses');
INSERT INTO international VALUES (414,'WebGUI','English','Display debugging information.');
INSERT INTO international VALUES (415,'WebGUI','English','Display a friendly message.');
INSERT INTO international VALUES (416,'WebGUI','English','<h1>Problem With Request</h1>We have encountered a problem with your request. Please use your back button and try again. If this problem persists, please contact us with what you were trying to do and the time and date of the problem.');
INSERT INTO international VALUES (417,'WebGUI','English','<h1>Security Violation</h1>You attempted to access a wobject not associated with this page. This incident has been reported.');
INSERT INTO international VALUES (418,'WebGUI','English','Filter Contributed HTML');
INSERT INTO international VALUES (419,'WebGUI','English','Remove all tags.');
INSERT INTO international VALUES (420,'WebGUI','English','Leave as is.');
INSERT INTO international VALUES (421,'WebGUI','English','Remove all but basic formating.');
INSERT INTO international VALUES (422,'WebGUI','English','<h1>Login Failed</h1>The information supplied does not match the account.');
INSERT INTO international VALUES (423,'WebGUI','English','View active sessions.');
INSERT INTO international VALUES (424,'WebGUI','English','View login history.');
INSERT INTO international VALUES (425,'WebGUI','English','Active Sessions');
INSERT INTO international VALUES (426,'WebGUI','English','Login History');
INSERT INTO international VALUES (427,'WebGUI','English','Styles');
INSERT INTO international VALUES (428,'WebGUI','English','User (ID)');
INSERT INTO international VALUES (429,'WebGUI','English','Login Time');
INSERT INTO international VALUES (430,'WebGUI','English','Last Page View');
INSERT INTO international VALUES (431,'WebGUI','English','IP Address');
INSERT INTO international VALUES (432,'WebGUI','English','Expires');
INSERT INTO international VALUES (433,'WebGUI','English','User Agent');
INSERT INTO international VALUES (434,'WebGUI','English','Status');
INSERT INTO international VALUES (435,'WebGUI','English','Session Signature');
INSERT INTO international VALUES (436,'WebGUI','English','Kill Session');
INSERT INTO international VALUES (437,'WebGUI','English','Statistics');
INSERT INTO international VALUES (438,'WebGUI','English','Your Name');
INSERT INTO international VALUES (13,'MessageBoard','Deutsch','Antwort\r\nschicken');
INSERT INTO international VALUES (13,'LinkList','Deutsch','Neuen Link\r\nhinzufügen');
INSERT INTO international VALUES (13,'EventsCalendar','Deutsch','Veranstaltung bearbeiten');
INSERT INTO international VALUES (13,'Article','Deutsch','Löschen');
INSERT INTO international VALUES (12,'WebGUI','Deutsch','Administrationsmodus abschalten');
INSERT INTO international VALUES (12,'UserSubmission','Deutsch','(Bitte\r\nausklicken, wenn Ihr Beitrag in HTML geschrieben ist)');
INSERT INTO international VALUES (12,'SQLReport','Deutsch','Fehler:\r\nDatenbankverbindung konnte nicht aufgebaut werden.');
INSERT INTO international VALUES (12,'MessageBoard','Deutsch','Beitrag\r\nbearbeiten');
INSERT INTO international VALUES (12,'LinkList','Deutsch','Link\r\nbearbeiten');
INSERT INTO international VALUES (12,'EventsCalendar','Deutsch','Veranstaltungskalender bearbeiten');
INSERT INTO international VALUES (12,'DownloadManager','Deutsch','Sind Sie\r\nsicher, dass Sie diesen Download löschen möchten?');
INSERT INTO international VALUES (12,'Article','Deutsch','Artikel\r\nbearbeiten');
INSERT INTO international VALUES (11,'WebGUI','Deutsch','Mülleimer\r\nleeren');
INSERT INTO international VALUES (1,'SyndicatedContent','Svenska','URL till RSS filen');
INSERT INTO international VALUES (11,'SQLReport','Deutsch','Fehler: Es gab\r\nein Problem mit der Abfrage.');
INSERT INTO international VALUES (11,'Poll','Deutsch','Abstimmen');
INSERT INTO international VALUES (11,'MessageBoard','Deutsch','Zurück zur\r\nBeitragsliste');
INSERT INTO international VALUES (11,'EventsCalendar','Deutsch','<b>und</b>\r\nalle seine Wiederholungen löschen wollen?');
INSERT INTO international VALUES (11,'DownloadManager','Deutsch','Neuen\r\nDownload hinzufügen.');
INSERT INTO international VALUES (11,'Article','Deutsch','(Bitte anklicken,\r\nfalls Sie nicht &lt;br&gt; in Ihrem Text hinzufügen.)');
INSERT INTO international VALUES (10,'WebGUI','Deutsch','Mülleimer\r\nanschauen');
INSERT INTO international VALUES (10,'SQLReport','Deutsch','Fehler: Das\r\nSQL-Statement ist im falschen Format.');
INSERT INTO international VALUES (10,'UserSubmission','Deutsch','Standard\r\nstatus');
INSERT INTO international VALUES (10,'Poll','Deutsch','Abstimmung\r\nzurücksetzen');
INSERT INTO international VALUES (7,'Article','Dansk','Titel på henvisning');
INSERT INTO international VALUES (10,'LinkList','Deutsch','Link Liste\r\nbearbeiten');
INSERT INTO international VALUES (10,'FAQ','Deutsch','Frage bearbeiten');
INSERT INTO international VALUES (10,'EventsCalendar','Deutsch','Sind Sie\r\nsicher, dass Sie diesen Termin');
INSERT INTO international VALUES (10,'DownloadManager','Deutsch','Download\r\nbearbeiten');
INSERT INTO international VALUES (10,'Article','Deutsch','Carriage Return\r\nbeachten?');
INSERT INTO international VALUES (9,'UserSubmission','Deutsch','Ausstehend');
INSERT INTO international VALUES (9,'WebGUI','Deutsch','Zwischenablage\r\nanschauen');
INSERT INTO international VALUES (9,'SQLReport','Deutsch','Fehler: Die DSN\r\nbesitzt das falsche Format.');
INSERT INTO international VALUES (9,'SiteMap','Deutsch','Übersicht\r\nanzeigen?');
INSERT INTO international VALUES (9,'Poll','Deutsch','Abstimmung\r\nbearbeiten');
INSERT INTO international VALUES (9,'MessageBoard','Deutsch','Beitrags\r\nID:');
INSERT INTO international VALUES (9,'LinkList','Deutsch','Sind Sie sicher,\r\ndass Sie diesen Link löschen wollen?');
INSERT INTO international VALUES (9,'FAQ','Deutsch','Neue Frage\r\nhinzufügen');
INSERT INTO international VALUES (9,'EventsCalendar','Deutsch','bis');
INSERT INTO international VALUES (9,'DownloadManager','Deutsch','Download\r\nManager bearbeiten');
INSERT INTO international VALUES (9,'Article','Deutsch','Dateianhang');
INSERT INTO international VALUES (8,'WebGUI','Deutsch','\"Seite nicht\r\ngefunden\" anschauen');
INSERT INTO international VALUES (8,'UserSubmission','Deutsch','Verboten');
INSERT INTO international VALUES (8,'SQLReport','Deutsch','SQL Bericht\r\nbearbeiten');
INSERT INTO international VALUES (8,'SiteMap','Deutsch','Zeilenabstand');
INSERT INTO international VALUES (8,'Poll','Deutsch','(Eine Antwort pro\r\nZeile. Bitte nicht mehr als 20 verschiedene Antworten)');
INSERT INTO international VALUES (8,'MessageBoard','Deutsch','Datum:');
INSERT INTO international VALUES (8,'LinkList','Deutsch','URL');
INSERT INTO international VALUES (8,'FAQ','Deutsch','F.A.Q. bearbeiten');
INSERT INTO international VALUES (8,'EventsCalendar','Deutsch','Wiederholt\r\nsich');
INSERT INTO international VALUES (8,'DownloadManager','Deutsch','Kurze\r\nBeschreibung');
INSERT INTO international VALUES (7,'WebGUI','Deutsch','Benutzer\r\nverwalten');
INSERT INTO international VALUES (8,'Article','Deutsch','Link URL');
INSERT INTO international VALUES (7,'UserSubmission','Deutsch','Erlaubt');
INSERT INTO international VALUES (7,'SQLReport','Deutsch','Datenbankpasswort');
INSERT INTO international VALUES (7,'SiteMap','Deutsch','Kugel');
INSERT INTO international VALUES (7,'Poll','Deutsch','Antworten');
INSERT INTO international VALUES (7,'MessageBoard','Deutsch','Autor:');
INSERT INTO international VALUES (2,'LinkList','Svenska','Avstånd mellan rader');
INSERT INTO international VALUES (7,'FAQ','Deutsch','Sind Sie sicher, dass\r\nSie diese Frage löschen wollen?');
INSERT INTO international VALUES (2,'SQLReport','Svenska','Lägg till SQL rapport');
INSERT INTO international VALUES (7,'DownloadManager','Deutsch','Gruppe,\r\ndie Download benutzen kann');
INSERT INTO international VALUES (7,'Article','Deutsch','Link Titel');
INSERT INTO international VALUES (6,'WebGUI','Deutsch','Stile verwalten');
INSERT INTO international VALUES (6,'UserSubmission','Deutsch','Beiträge\r\npro Seite');
INSERT INTO international VALUES (6,'SyndicatedContent','Deutsch','Aktueller Inhalt');
INSERT INTO international VALUES (6,'SQLReport','Deutsch','Datenbankbenutzer');
INSERT INTO international VALUES (6,'SiteMap','Deutsch','Zweck');
INSERT INTO international VALUES (6,'MessageBoard','Deutsch','Diskussionsforum bearbeiten');
INSERT INTO international VALUES (6,'Poll','Deutsch','Frage');
INSERT INTO international VALUES (6,'LinkList','Deutsch','Link Liste');
INSERT INTO international VALUES (6,'FAQ','Deutsch','Antwort');
INSERT INTO international VALUES (6,'ExtraColumn','Deutsch','Extra Spalte\r\nbearbeiten');
INSERT INTO international VALUES (6,'EventsCalendar','Deutsch','Woche');
INSERT INTO international VALUES (6,'DownloadManager','Deutsch','Dateiname');
INSERT INTO international VALUES (6,'Article','Deutsch','Bild');
INSERT INTO international VALUES (5,'WebGUI','Deutsch','Gruppen\r\nverwalten');
INSERT INTO international VALUES (5,'UserSubmission','Deutsch','Ihr Beitrag\r\nwurde abgelehnt.');
INSERT INTO international VALUES (5,'SyndicatedContent','Deutsch','zuletzt\r\ngeholt');
INSERT INTO international VALUES (5,'SQLReport','Deutsch','DSN (Data Source\r\nName)');
INSERT INTO international VALUES (5,'SiteMap','Deutsch','Site Map\r\nbearbeiten');
INSERT INTO international VALUES (5,'Poll','Deutsch','Breite der Grafik');
INSERT INTO international VALUES (5,'MessageBoard','Deutsch','Timeout zum\r\nbearbeiten');
INSERT INTO international VALUES (5,'LinkList','Deutsch','Wollen Sie einen\r\nLink hinzufügen?');
INSERT INTO international VALUES (5,'Item','Deutsch','Anhang\r\nherunterladen');
INSERT INTO international VALUES (5,'FAQ','Deutsch','Frage');
INSERT INTO international VALUES (5,'ExtraColumn','Deutsch','StyleSheet\r\nClass');
INSERT INTO international VALUES (5,'EventsCalendar','Deutsch','Tag');
INSERT INTO international VALUES (5,'DownloadManager','Deutsch','Dateititel');
INSERT INTO international VALUES (4,'WebGUI','Deutsch','Einstellungen\r\nverwalten');
INSERT INTO international VALUES (4,'UserSubmission','Deutsch','Ihr Betrag\r\nwurde angenommen.');
INSERT INTO international VALUES (4,'SQLReport','Deutsch','Abfrage');
INSERT INTO international VALUES (4,'SyndicatedContent','Deutsch','Clipping-Dienst bearbeiten');
INSERT INTO international VALUES (4,'SiteMap','Deutsch','Tiefe');
INSERT INTO international VALUES (4,'Poll','Deutsch','Wer kann\r\nabstimmen?');
INSERT INTO international VALUES (2,'WebGUI','Svenska','Sida');
INSERT INTO international VALUES (4,'Item','Deutsch','Kleiner Artikel');
INSERT INTO international VALUES (4,'LinkList','Deutsch','Kugel');
INSERT INTO international VALUES (4,'MessageBoard','Deutsch','Beiträge pro\r\nSeite');
INSERT INTO international VALUES (4,'ExtraColumn','Deutsch','Breite');
INSERT INTO international VALUES (4,'EventsCalendar','Deutsch','Einmaliges\r\nEreignis');
INSERT INTO international VALUES (1,'Article','Svenska','Artikel');
INSERT INTO international VALUES (4,'Article','Deutsch','Ende Datum');
INSERT INTO international VALUES (3,'WebGUI','Deutsch','Aus Zwischenablage\r\neinfügen...');
INSERT INTO international VALUES (3,'UserSubmission','Deutsch','Sie sollten\r\neinen neuen Beitrag genehmigen.');
INSERT INTO international VALUES (3,'FAQ','Svenska','Lägg till F.A.Q.');
INSERT INTO international VALUES (3,'SQLReport','Deutsch','Schablone');
INSERT INTO international VALUES (3,'SiteMap','Deutsch','Auf dieser Ebene\r\nStarten?');
INSERT INTO international VALUES (3,'Poll','Deutsch','Aktiv');
INSERT INTO international VALUES (3,'MessageBoard','Deutsch','Wer kann\r\nBeiträge schreiben?');
INSERT INTO international VALUES (3,'LinkList','Deutsch','In neuem Fenster\r\nöffnen?');
INSERT INTO international VALUES (3,'Item','Deutsch','Anhang löschen');
INSERT INTO international VALUES (3,'ExtraColumn','Deutsch','Platzhalter');
INSERT INTO international VALUES (3,'UserSubmission','Svenska','Du har ett nytt medelande att validera.');
INSERT INTO international VALUES (3,'DownloadManager','Deutsch','Fortfahren\r\ndie Datei hinzuzufügen?');
INSERT INTO international VALUES (3,'Article','Deutsch','Start Datum');
INSERT INTO international VALUES (2,'WebGUI','Deutsch','Seite');
INSERT INTO international VALUES (2,'UserSubmission','Deutsch','Wer kann\r\nBeiträge schreiben?');
INSERT INTO international VALUES (2,'SyndicatedContent','Deutsch','Clipping-Dienst');
INSERT INTO international VALUES (4,'EventsCalendar','Svenska','Inträffar endast en gång.');
INSERT INTO international VALUES (2,'SiteMap','Deutsch','Site\r\nMap/Übersicht');
INSERT INTO international VALUES (2,'FAQ','Deutsch','F.A.Q.');
INSERT INTO international VALUES (2,'Item','Deutsch','Anhang');
INSERT INTO international VALUES (2,'LinkList','Deutsch','Zeilenabstand');
INSERT INTO international VALUES (2,'MessageBoard','Deutsch','Diskussionsforum');
INSERT INTO international VALUES (4,'Item','Svenska','Post');
INSERT INTO international VALUES (2,'EventsCalendar','Deutsch','Veranstaltungskalender');
INSERT INTO international VALUES (4,'SQLReport','Svenska','Query');
INSERT INTO international VALUES (1,'WebGUI','Deutsch','Inhalt\r\nhinzufügen...');
INSERT INTO international VALUES (1,'SyndicatedContent','Deutsch','URL zur\r\nRSS-Datei');
INSERT INTO international VALUES (1,'UserSubmission','Deutsch','Wer kann\r\ngenehmigen?');
INSERT INTO international VALUES (1,'SQLReport','Deutsch','SQL Bericht');
INSERT INTO international VALUES (1,'Poll','Deutsch','Abstimmung');
INSERT INTO international VALUES (5,'FAQ','Svenska','Fråga');
INSERT INTO international VALUES (1,'LinkList','Deutsch','Tabulator');
INSERT INTO international VALUES (1,'Item','Deutsch','Link URL');
INSERT INTO international VALUES (1,'FAQ','Deutsch','Frage hinzufügen?');
INSERT INTO international VALUES (1,'ExtraColumn','Deutsch','Extra\r\nSpalte');
INSERT INTO international VALUES (1,'EventsCalendar','Deutsch','Termin\r\nhinzufügen?');
INSERT INTO international VALUES (1,'DownloadManager','Deutsch','Download\r\nManager');
INSERT INTO international VALUES (1,'Article','Deutsch','Artikel');
INSERT INTO international VALUES (395,'WebGUI','Deutsch','Neue Grafik\r\nhinzufügen.');
INSERT INTO international VALUES (396,'WebGUI','Deutsch','Grafik\r\nanschauen');
INSERT INTO international VALUES (397,'WebGUI','Deutsch','Zurück zur\r\nGrafikübersicht.');
INSERT INTO international VALUES (398,'WebGUI','Deutsch','Dokumententyp\r\nBeschreibung');
INSERT INTO international VALUES (399,'WebGUI','Deutsch','Diese Seite\r\nüberprüfen.');
INSERT INTO international VALUES (400,'WebGUI','Deutsch','Caching\r\nverhindern');
INSERT INTO international VALUES (401,'WebGUI','Deutsch','Sind Sie sicher,\r\ndass Sie diese Nachrichten und alle darunterliegenden löschen wollen?');
INSERT INTO international VALUES (402,'WebGUI','Deutsch','Die Nachricht die\r\nsie abfragen wollten existiert leider nicht.');
INSERT INTO international VALUES (403,'WebGUI','Deutsch','Ich teile es\r\nlieber nicht mit.');
INSERT INTO international VALUES (404,'WebGUI','Deutsch','Erste Seite');
INSERT INTO international VALUES (405,'WebGUI','Deutsch','Letzte Seite');
INSERT INTO international VALUES (406,'WebGUI','Deutsch','Größe der kleinen\r\nBilder');
INSERT INTO international VALUES (407,'WebGUI','Deutsch','Klicken Sie hier,\r\num sich zu registrieren');
INSERT INTO international VALUES (408,'WebGUI','Deutsch','Startseiten\r\nbearbeiten');
INSERT INTO international VALUES (409,'WebGUI','Deutsch','Neue Startseite\r\nanlegen');
INSERT INTO international VALUES (410,'WebGUI','Deutsch','Startseiten\r\nbearbeiten');
INSERT INTO international VALUES (411,'WebGUI','Deutsch','Menü Titel');
INSERT INTO international VALUES (412,'WebGUI','Deutsch','Synopse');
INSERT INTO international VALUES (413,'WebGUI','Deutsch','Bei kritischem\r\nFehler');
INSERT INTO international VALUES (414,'WebGUI','Deutsch','Debuginformationen anzeigen');
INSERT INTO international VALUES (415,'WebGUI','Deutsch','benutzerfreundlich anzeigen');
INSERT INTO international VALUES (416,'WebGUI','Deutsch','<h1>Abfrageproblem</h1> Ihre Anfrage macht dem\r\nSystem Probleme. Bitte betätigen Sie den Zurückbutton im Browser und\r\nversuchen Sie es nochmal. Sollte dieses Problem weiterbestehen, teilen Sie\r\nuns bitte mit, was Sie wo im System wann gemacht haben.');
INSERT INTO international VALUES (417,'WebGUI','Deutsch','<h1>Sicherheitsverstoß</h1> Sie haben versucht\r\nauf einen Systemteil zuzugreifen, der Ihnen nicht erlaubt ist. Der Verstoß\r\nwurde gemeldet.');
INSERT INTO international VALUES (418,'WebGUI','Deutsch','HTML filtern');
INSERT INTO international VALUES (419,'WebGUI','Deutsch','Alle\r\nBeschreibungselemente entfernen');
INSERT INTO international VALUES (420,'WebGUI','Deutsch','Nicht\r\nverändern');
INSERT INTO international VALUES (421,'WebGUI','Deutsch','Nur einfache\r\nFormatierungen beibehalten');
INSERT INTO international VALUES (422,'WebGUI','Deutsch','<h1>Anmeldung ist\r\nfehlgeschlagen!</h1> Die eingegebenen Zugansdaten stimmen mit keinen\r\nBenutzerdaten überein.');
INSERT INTO international VALUES (423,'WebGUI','Deutsch','Aktive Sitzungen\r\nanschauen');
INSERT INTO international VALUES (424,'WebGUI','Deutsch','Anmeldungshistorie anschauen');
INSERT INTO international VALUES (425,'WebGUI','Deutsch','Aktive\r\nSitzungen');
INSERT INTO international VALUES (426,'WebGUI','Deutsch','Anmeldungshistorie');
INSERT INTO international VALUES (427,'WebGUI','Deutsch','Stile');
INSERT INTO international VALUES (428,'WebGUI','Deutsch','Benutzername');
INSERT INTO international VALUES (429,'WebGUI','Deutsch','Anmeldungszeit');
INSERT INTO international VALUES (430,'WebGUI','Deutsch','Seite wurde das\r\nletzte mal angeschaut');
INSERT INTO international VALUES (431,'WebGUI','Deutsch','IP Adresse');
INSERT INTO international VALUES (432,'WebGUI','Deutsch','läuft ab');
INSERT INTO international VALUES (434,'WebGUI','Deutsch','Status');
INSERT INTO international VALUES (435,'WebGUI','Deutsch','Sitzungssignatur');
INSERT INTO international VALUES (436,'WebGUI','Deutsch','Sitzung\r\nbeenden');
INSERT INTO international VALUES (437,'WebGUI','Deutsch','Statistiken');
INSERT INTO international VALUES (438,'WebGUI','Deutsch','Ihr Name');
INSERT INTO international VALUES (439,'WebGUI','English','Personal Information');
INSERT INTO international VALUES (440,'WebGUI','English','Contact Information');
INSERT INTO international VALUES (441,'WebGUI','English','Email To Pager Gateway');
INSERT INTO international VALUES (442,'WebGUI','English','Work Information');
INSERT INTO international VALUES (443,'WebGUI','English','Home Information');
INSERT INTO international VALUES (444,'WebGUI','English','Demographic Information');
INSERT INTO international VALUES (445,'WebGUI','English','Preferences');
INSERT INTO international VALUES (446,'WebGUI','English','Work Web Site');
INSERT INTO international VALUES (447,'WebGUI','English','Manage page tree.');
INSERT INTO international VALUES (448,'WebGUI','English','Page Tree');
INSERT INTO international VALUES (449,'WebGUI','English','Miscellaneous Information');
INSERT INTO international VALUES (450,'WebGUI','English','Work Name (Company Name)');
INSERT INTO international VALUES (451,'WebGUI','English','is required.');
INSERT INTO international VALUES (452,'WebGUI','English','Please wait...');
INSERT INTO international VALUES (453,'WebGUI','English','Date Created');
INSERT INTO international VALUES (454,'WebGUI','English','Last Updated');
INSERT INTO international VALUES (455,'WebGUI','English','Edit User\'s Profile');
INSERT INTO international VALUES (456,'WebGUI','English','Back to user list.');
INSERT INTO international VALUES (457,'WebGUI','English','Edit this user\'s account.');
INSERT INTO international VALUES (458,'WebGUI','English','Edit this user\'s groups.');
INSERT INTO international VALUES (459,'WebGUI','English','Edit this user\'s profile.');
INSERT INTO international VALUES (460,'WebGUI','English','Time Offset');
INSERT INTO international VALUES (461,'WebGUI','English','Date Format');
INSERT INTO international VALUES (462,'WebGUI','English','Time Format');
INSERT INTO international VALUES (463,'WebGUI','English','Text Area Rows');
INSERT INTO international VALUES (464,'WebGUI','English','Text Area Columns');
INSERT INTO international VALUES (465,'WebGUI','English','Text Box Size');
INSERT INTO international VALUES (466,'WebGUI','English','Are you certain you wish to delete this category and move all of its fields to the Miscellaneous category?');
INSERT INTO international VALUES (467,'WebGUI','English','Are you certain you wish to delete this field and all user data attached to it?');
INSERT INTO international VALUES (468,'WebGUI','Svenska','Redigera Användar Profil Kattegorier');
INSERT INTO international VALUES (469,'WebGUI','English','Id');
INSERT INTO international VALUES (470,'WebGUI','English','Name');
INSERT INTO international VALUES (472,'WebGUI','English','Label');
INSERT INTO international VALUES (473,'WebGUI','English','Visible?');
INSERT INTO international VALUES (474,'WebGUI','English','Required?');
INSERT INTO international VALUES (475,'WebGUI','English','Text');
INSERT INTO international VALUES (476,'WebGUI','English','Text Area');
INSERT INTO international VALUES (477,'WebGUI','English','HTML Area');
INSERT INTO international VALUES (478,'WebGUI','English','URL');
INSERT INTO international VALUES (479,'WebGUI','English','Date');
INSERT INTO international VALUES (480,'WebGUI','English','Email Address');
INSERT INTO international VALUES (481,'WebGUI','English','Telephone Number');
INSERT INTO international VALUES (482,'WebGUI','English','Number (Integer)');
INSERT INTO international VALUES (483,'WebGUI','English','Yes or No');
INSERT INTO international VALUES (484,'WebGUI','English','Select List');
INSERT INTO international VALUES (485,'WebGUI','English','Boolean (Checkbox)');
INSERT INTO international VALUES (486,'WebGUI','English','Data Type');
INSERT INTO international VALUES (487,'WebGUI','English','Possible Values');
INSERT INTO international VALUES (488,'WebGUI','English','Default Value(s)');
INSERT INTO international VALUES (489,'WebGUI','English','Profile Category');
INSERT INTO international VALUES (490,'WebGUI','English','Add a profile category.');
INSERT INTO international VALUES (491,'WebGUI','English','Add a profile field.');
INSERT INTO international VALUES (492,'WebGUI','English','Profile fields list.');
INSERT INTO international VALUES (493,'WebGUI','English','Back to site.');
INSERT INTO international VALUES (495,'WebGUI','English','Built-In Editor');
INSERT INTO international VALUES (496,'WebGUI','English','Editor To Use');
INSERT INTO international VALUES (494,'WebGUI','English','Real Objects Edit-On Pro');
INSERT INTO international VALUES (497,'WebGUI','English','Start Date');
INSERT INTO international VALUES (498,'WebGUI','English','End Date');
INSERT INTO international VALUES (499,'WebGUI','English','Wobject ID');
INSERT INTO international VALUES (500,'WebGUI','English','Page ID');
INSERT INTO international VALUES (5,'Poll','Svenska','Bred på staplar');
INSERT INTO international VALUES (5,'SiteMap','Svenska','Redigera Site Kartan');
INSERT INTO international VALUES (5,'SQLReport','Svenska','DSN');
INSERT INTO international VALUES (5,'SyndicatedContent','Svenska','Senast hämtad');
INSERT INTO international VALUES (5,'UserSubmission','Svenska','Ditt medelande har blivit nekat validering.');
INSERT INTO international VALUES (5,'WebGUI','Svenska','Kontrolera grupper.');
INSERT INTO international VALUES (6,'Article','Svenska','Bild');
INSERT INTO international VALUES (6,'EventsCalendar','Svenska','Vecka');
INSERT INTO international VALUES (6,'ExtraColumn','Svenska','Lägg till extra column');
INSERT INTO international VALUES (6,'FAQ','Svenska','Svar');
INSERT INTO international VALUES (6,'LinkList','Svenska','Länk Lista');
INSERT INTO international VALUES (6,'MessageBoard','Svenska','Redigera Meddelande Forum');
INSERT INTO international VALUES (6,'Poll','Svenska','Fråga');
INSERT INTO international VALUES (6,'SiteMap','Svenska','Indentering');
INSERT INTO international VALUES (6,'SQLReport','Svenska','Database Användare');
INSERT INTO international VALUES (6,'SyndicatedContent','Svenska','Nuvarande inehåll');
INSERT INTO international VALUES (6,'UserSubmission','Svenska','Inlägg per sida');
INSERT INTO international VALUES (6,'WebGUI','Svenska','Kontrolera stilar.');
INSERT INTO international VALUES (7,'Article','Svenska','Länk Titel');
INSERT INTO international VALUES (7,'EventsCalendar','Svenska','Lägg till händelse');
INSERT INTO international VALUES (7,'FAQ','Svenska','Är du säker på att du vill radera denna fråga?');
INSERT INTO international VALUES (7,'LinkList','Svenska','Lägg till länk');
INSERT INTO international VALUES (7,'MessageBoard','Svenska','Författare:');
INSERT INTO international VALUES (7,'Poll','Svenska','Svar');
INSERT INTO international VALUES (7,'SiteMap','Svenska','Kula');
INSERT INTO international VALUES (7,'SQLReport','Svenska','Database Lösenord');
INSERT INTO international VALUES (7,'UserSubmission','Svenska','Godkännt');
INSERT INTO international VALUES (7,'WebGUI','Svenska','Kontrolera användare.');
INSERT INTO international VALUES (8,'Article','Svenska','Länk URL');
INSERT INTO international VALUES (8,'EventsCalendar','Svenska','Recurs every');
INSERT INTO international VALUES (8,'FAQ','Svenska','Redigera F.A.Q.');
INSERT INTO international VALUES (8,'LinkList','Svenska','URL');
INSERT INTO international VALUES (8,'MessageBoard','Svenska','Datum:');
INSERT INTO international VALUES (8,'Poll','Svenska','(Mata in ett svar per rad. Max 20.)');
INSERT INTO international VALUES (8,'SiteMap','Svenska','Avstånd mellan rader');
INSERT INTO international VALUES (8,'SQLReport','Svenska','Redigera SQL Rapport');
INSERT INTO international VALUES (8,'UserSubmission','Svenska','Nekat');
INSERT INTO international VALUES (8,'WebGUI','Svenska','Visa page not found.');
INSERT INTO international VALUES (9,'Article','Svenska','Bilagor');
INSERT INTO international VALUES (9,'EventsCalendar','Svenska','until');
INSERT INTO international VALUES (9,'FAQ','Svenska','Lägg till ny fråga.');
INSERT INTO international VALUES (9,'LinkList','Svenska','Är du säker att du vill radera denna länk?');
INSERT INTO international VALUES (9,'MessageBoard','Svenska','Meddelande ID:');
INSERT INTO international VALUES (9,'Poll','Svenska','Redigera fråga');
INSERT INTO international VALUES (9,'SQLReport','Svenska','&lt;b&gt;Debug:&lt;/b&gt; Error: The DSN specified is of an improper format.');
INSERT INTO international VALUES (9,'UserSubmission','Svenska','Väntande');
INSERT INTO international VALUES (9,'WebGUI','Svenska','Visa klippbord.');
INSERT INTO international VALUES (10,'Article','Svenska','Konvertera radbrytning?');
INSERT INTO international VALUES (10,'EventsCalendar','Svenska','Är du säker på att du vill radera denna händelse');
INSERT INTO international VALUES (10,'FAQ','Svenska','Redigera fråga');
INSERT INTO international VALUES (10,'LinkList','Svenska','Redigera Länk Lista');
INSERT INTO international VALUES (2,'Article','Dansk','Tilføj artikel');
INSERT INTO international VALUES (10,'Poll','Svenska','Återställ röster.');
INSERT INTO international VALUES (10,'SQLReport','Svenska','&lt;b&gt;Debug:&lt;/b&gt; Error: The SQL specified is of an improper format.');
INSERT INTO international VALUES (10,'UserSubmission','Svenska','Default Status');
INSERT INTO international VALUES (10,'WebGUI','Svenska','Hantera skräpkorgen.');
INSERT INTO international VALUES (11,'Article','Svenska','(Kryssa i om du inte skriver &amp;lt;br&amp;gt; manuelt.)');
INSERT INTO international VALUES (11,'EventsCalendar','Svenska','&lt;b&gt;and&lt;/b&gt; all of its recurring events');
INSERT INTO international VALUES (11,'LinkList','Svenska','Lägg till Länk Lista');
INSERT INTO international VALUES (11,'MessageBoard','Svenska','Tillbaka till meddelande lista');
INSERT INTO international VALUES (11,'SQLReport','Svenska','&lt;b&gt;Debug:&lt;/b&gt; Error: There was a problem with the query.');
INSERT INTO international VALUES (11,'UserSubmission','Svenska','Lägg till inlägg');
INSERT INTO international VALUES (11,'WebGUI','Svenska','Töm skräpkoren.');
INSERT INTO international VALUES (12,'Article','Svenska','Redigera Artikel');
INSERT INTO international VALUES (12,'EventsCalendar','Svenska','Edit Events Calendar');
INSERT INTO international VALUES (12,'LinkList','Svenska','Redigera Länk');
INSERT INTO international VALUES (12,'MessageBoard','Svenska','Redigera meddelande');
INSERT INTO international VALUES (12,'SQLReport','Svenska','&lt;b&gt;Debug:&lt;/b&gt; Error: Could not connect to the database.');
INSERT INTO international VALUES (12,'UserSubmission','Svenska','(Avkryssa om du skriver ett HTML inlägg.)');
INSERT INTO international VALUES (12,'WebGUI','Svenska','Stäng av adminverktyg.');
INSERT INTO international VALUES (13,'Article','Svenska','Radera');
INSERT INTO international VALUES (13,'EventsCalendar','Svenska','Lägg till händelse');
INSERT INTO international VALUES (13,'LinkList','Svenska','Lägg till en ny länk.');
INSERT INTO international VALUES (13,'MessageBoard','Svenska','Skicka svar');
INSERT INTO international VALUES (13,'UserSubmission','Svenska','Inlagt den');
INSERT INTO international VALUES (13,'WebGUI','Svenska','Visa hjälpindex.');
INSERT INTO international VALUES (14,'Article','Svenska','Justera Bild');
INSERT INTO international VALUES (514,'WebGUI','English','Views');
INSERT INTO international VALUES (14,'UserSubmission','Svenska','Status');
INSERT INTO international VALUES (14,'WebGUI','Svenska','Visa väntande meddelanden.');
INSERT INTO international VALUES (15,'MessageBoard','Svenska','Författare');
INSERT INTO international VALUES (15,'UserSubmission','Svenska','Redigera/Ta bort');
INSERT INTO international VALUES (15,'WebGUI','Svenska','Januari');
INSERT INTO international VALUES (16,'MessageBoard','Svenska','Datum');
INSERT INTO international VALUES (16,'UserSubmission','Svenska','Namnlös');
INSERT INTO international VALUES (16,'WebGUI','Svenska','Februari');
INSERT INTO international VALUES (17,'MessageBoard','Svenska','Skicka nytt meddelande');
INSERT INTO international VALUES (17,'UserSubmission','Svenska','Är du säger du vill ta bort detta inlägg?');
INSERT INTO international VALUES (17,'WebGUI','Svenska','Mars');
INSERT INTO international VALUES (18,'MessageBoard','Svenska','Tråd startad');
INSERT INTO international VALUES (18,'UserSubmission','Svenska','Regigera inläggs system');
INSERT INTO international VALUES (18,'WebGUI','Svenska','April');
INSERT INTO international VALUES (19,'MessageBoard','Svenska','Svar');
INSERT INTO international VALUES (19,'UserSubmission','Svenska','Redigera inlägg');
INSERT INTO international VALUES (19,'WebGUI','Svenska','Maj');
INSERT INTO international VALUES (20,'MessageBoard','Svenska','Senaste svar');
INSERT INTO international VALUES (20,'UserSubmission','Svenska','Skicka nytt inlägg');
INSERT INTO international VALUES (20,'WebGUI','Svenska','Juni');
INSERT INTO international VALUES (21,'UserSubmission','Svenska','Skrivet av');
INSERT INTO international VALUES (21,'WebGUI','Svenska','Juli');
INSERT INTO international VALUES (22,'UserSubmission','Svenska','Skrivet av:');
INSERT INTO international VALUES (22,'WebGUI','Svenska','Augusti');
INSERT INTO international VALUES (23,'UserSubmission','Svenska','Inläggsdatum:');
INSERT INTO international VALUES (23,'WebGUI','Svenska','September');
INSERT INTO international VALUES (24,'UserSubmission','Svenska','Godkänn');
INSERT INTO international VALUES (24,'WebGUI','Svenska','Oktober');
INSERT INTO international VALUES (25,'UserSubmission','Svenska','Lämna i vänteläge');
INSERT INTO international VALUES (25,'WebGUI','Svenska','November');
INSERT INTO international VALUES (26,'UserSubmission','Svenska','Neka');
INSERT INTO international VALUES (26,'WebGUI','Svenska','December');
INSERT INTO international VALUES (27,'UserSubmission','Svenska','Redigera');
INSERT INTO international VALUES (27,'WebGUI','Svenska','Söndag');
INSERT INTO international VALUES (28,'UserSubmission','Svenska','Återgå till inläggslistan');
INSERT INTO international VALUES (28,'WebGUI','Svenska','Måndag');
INSERT INTO international VALUES (29,'UserSubmission','Svenska','Användar-inläggs system');
INSERT INTO international VALUES (29,'WebGUI','Svenska','Tisdag');
INSERT INTO international VALUES (30,'UserSubmission','Svenska','Läggtill använda-inläggs system');
INSERT INTO international VALUES (30,'WebGUI','Svenska','Onsdag');
INSERT INTO international VALUES (31,'WebGUI','Svenska','Torsdag');
INSERT INTO international VALUES (32,'WebGUI','Svenska','Fredag');
INSERT INTO international VALUES (33,'WebGUI','Svenska','Lördag');
INSERT INTO international VALUES (34,'WebGUI','Svenska','sätt datum');
INSERT INTO international VALUES (35,'WebGUI','Svenska','Administrativa funktioner');
INSERT INTO international VALUES (36,'WebGUI','Svenska','Du måste vara administratör för att utföra denna funktion. Var vänlig kontakta någon av administratörerna. Följande är en lista av administratörer i systemet:');
INSERT INTO international VALUES (37,'WebGUI','Svenska','Åtkomst nekas!');
INSERT INTO international VALUES (404,'WebGUI','Svenska','Första Sidan');
INSERT INTO international VALUES (38,'WebGUI','Svenska','Du har inte rättigheter att utföra denna operation. Var vänlig och ^a(logga in); på ett konto med tillräckliga rättigheter.');
INSERT INTO international VALUES (39,'WebGUI','Svenska','Åtkomst nekas, du har inte tillräckliga previlegier.');
INSERT INTO international VALUES (40,'WebGUI','Svenska','Vital komponent');
INSERT INTO international VALUES (41,'WebGUI','Svenska','Du håller på att ta bort en vital komponent från WebGUI systemet. Om du hade varit tillåten att göra detta, hade WebGUI slutat fungera !');
INSERT INTO international VALUES (42,'WebGUI','Svenska','Var vänlig konfirmera');
INSERT INTO international VALUES (43,'WebGUI','Svenska','Är du säker att du vill ta bort detta inehåll?');
INSERT INTO international VALUES (44,'WebGUI','Svenska','Ja, jag är säker.');
INSERT INTO international VALUES (45,'WebGUI','Svenska','Nej, jag gjorde ett misstag.');
INSERT INTO international VALUES (46,'WebGUI','Svenska','Mitt konto');
INSERT INTO international VALUES (47,'WebGUI','Svenska','Hem');
INSERT INTO international VALUES (48,'WebGUI','Svenska','Hej');
INSERT INTO international VALUES (49,'WebGUI','Svenska','Klicka &lt;a href=unknown://\"^\\;?op=logout\" TARGET=\"_blank\"&gt;här&lt;/a&gt; för att logga ur.');
INSERT INTO international VALUES (50,'WebGUI','Svenska','Användarnamn');
INSERT INTO international VALUES (51,'WebGUI','Svenska','Lösenord');
INSERT INTO international VALUES (52,'WebGUI','Svenska','logga in');
INSERT INTO international VALUES (53,'WebGUI','Svenska','Utskrifts version');
INSERT INTO international VALUES (54,'WebGUI','Svenska','Skapa konto');
INSERT INTO international VALUES (55,'WebGUI','Svenska','Lösenord (kontroll)');
INSERT INTO international VALUES (56,'WebGUI','Svenska','Email adress');
INSERT INTO international VALUES (57,'WebGUI','Svenska','Detta krävs endas om du vill använda tjänster som kräver Email.');
INSERT INTO international VALUES (58,'WebGUI','Svenska','Jag har redan ett konto.');
INSERT INTO international VALUES (59,'WebGUI','Svenska','Jag har glömt mitt lösenord.');
INSERT INTO international VALUES (60,'WebGUI','Svenska','ÄR du säker på att du vill stänga ned ditt konto ? Om du fortsätter kommer all information att vara permanent förlorad.');
INSERT INTO international VALUES (61,'WebGUI','Svenska','Uppdatera konto information');
INSERT INTO international VALUES (62,'WebGUI','Svenska','spara');
INSERT INTO international VALUES (63,'WebGUI','Svenska','Slå på admin-verktyg.');
INSERT INTO international VALUES (64,'WebGUI','Svenska','Logga ut.');
INSERT INTO international VALUES (65,'WebGUI','Svenska','Var vänlig och radera mitt konto permanent.');
INSERT INTO international VALUES (66,'WebGUI','Svenska','Logga in.');
INSERT INTO international VALUES (67,'WebGUI','Svenska','Skapa ett konto.');
INSERT INTO international VALUES (68,'WebGUI','Svenska','Informationen du gav var felaktig. Antingen så finns ingen sådan användare eller också så gav du fellösenords.');
INSERT INTO international VALUES (69,'WebGUI','Svenska','Var vänlig kontakta system administratören för vidare hjälp.');
INSERT INTO international VALUES (70,'WebGUI','Svenska','Fel');
INSERT INTO international VALUES (71,'WebGUI','Svenska','Rädda lösenord');
INSERT INTO international VALUES (72,'WebGUI','Svenska','rädda');
INSERT INTO international VALUES (73,'WebGUI','Svenska','Logga in.');
INSERT INTO international VALUES (74,'WebGUI','Svenska','Konto information');
INSERT INTO international VALUES (75,'WebGUI','Svenska','Din kontoinformation har skickats till din Email adress.');
INSERT INTO international VALUES (76,'WebGUI','Svenska','Den Email adressen finns inte i vårt system.');
INSERT INTO international VALUES (77,'WebGUI','Svenska','Det kontonamnet du valde används redan på denna site. Var vänlig välj ett annat. Här kommer några ideer som du kan använda:');
INSERT INTO international VALUES (78,'WebGUI','Svenska','Ditt lösenord stämde inte. Var vänlig försök igen.');
INSERT INTO international VALUES (79,'WebGUI','Svenska','Cannot connect to LDAP server.');
INSERT INTO international VALUES (80,'WebGUI','Svenska','Kontot skapades utan problem!');
INSERT INTO international VALUES (81,'WebGUI','Svenska','Kontot uppdaterat utan problem!');
INSERT INTO international VALUES (82,'WebGUI','Svenska','Administrativa funktioner...');
INSERT INTO international VALUES (84,'WebGUI','Svenska','Grupp namn');
INSERT INTO international VALUES (85,'WebGUI','Svenska','Beskrivning');
INSERT INTO international VALUES (86,'WebGUI','Svenska','Är du säker på att du vill radera denna grupp? Var medveten om att alla rättigheter associerade med denna grupp kommer att raderas.');
INSERT INTO international VALUES (87,'WebGUI','Svenska','Ändra grupp');
INSERT INTO international VALUES (88,'WebGUI','Svenska','Användare i gruppen');
INSERT INTO international VALUES (89,'WebGUI','Svenska','Grupper');
INSERT INTO international VALUES (90,'WebGUI','Svenska','Lägg till grupp.');
INSERT INTO international VALUES (91,'WebGUI','Svenska','Föregående sida');
INSERT INTO international VALUES (92,'WebGUI','Svenska','Nästa sida');
INSERT INTO international VALUES (93,'WebGUI','Svenska','Hjälp');
INSERT INTO international VALUES (94,'WebGUI','Svenska','Se vidare');
INSERT INTO international VALUES (95,'WebGUI','Svenska','Hjälp index');
INSERT INTO international VALUES (96,'WebGUI','Svenska','Sortera på åtgärd');
INSERT INTO international VALUES (97,'WebGUI','Svenska','Sortera på objekt');
INSERT INTO international VALUES (98,'WebGUI','Svenska','Lägg till sida');
INSERT INTO international VALUES (99,'WebGUI','Svenska','Titel');
INSERT INTO international VALUES (100,'WebGUI','Svenska','Meta Tag');
INSERT INTO international VALUES (101,'WebGUI','Svenska','Är du säker på att du vill radera denna sita, dess inehåll och underligande objekt?');
INSERT INTO international VALUES (102,'WebGUI','Svenska','Editera sida');
INSERT INTO international VALUES (103,'WebGUI','Svenska','Sidspecifikation');
INSERT INTO international VALUES (104,'WebGUI','Svenska','Sidans URL');
INSERT INTO international VALUES (105,'WebGUI','Svenska','Stil');
INSERT INTO international VALUES (106,'WebGUI','Svenska','Ge samma stil till underliggande sidor.');
INSERT INTO international VALUES (107,'WebGUI','Svenska','Previlegier');
INSERT INTO international VALUES (108,'WebGUI','Svenska','Ägare');
INSERT INTO international VALUES (109,'WebGUI','Svenska','Ägaren kan se?');
INSERT INTO international VALUES (110,'WebGUI','Svenska','Ägaren kan editera?');
INSERT INTO international VALUES (111,'WebGUI','Svenska','Grupp');
INSERT INTO international VALUES (112,'WebGUI','Svenska','Gruppen kan se?');
INSERT INTO international VALUES (113,'WebGUI','Svenska','Gruppen kan editera?');
INSERT INTO international VALUES (114,'WebGUI','Svenska','Vemsomhelst kan titta?');
INSERT INTO international VALUES (115,'WebGUI','Svenska','Kan vem som helst redigera?');
INSERT INTO international VALUES (116,'WebGUI','Svenska','Kryssa här för att kopiera dessa previlegier till undersidor.');
INSERT INTO international VALUES (117,'WebGUI','Svenska','Redigera Autentiserings inställningar');
INSERT INTO international VALUES (118,'WebGUI','Svenska','Anonyma registreringar');
INSERT INTO international VALUES (119,'WebGUI','Svenska','Authentiserings metod(default)');
INSERT INTO international VALUES (120,'WebGUI','Svenska','LDAP URL (default)');
INSERT INTO international VALUES (121,'WebGUI','Svenska','LDAP Identity (default)');
INSERT INTO international VALUES (122,'WebGUI','Svenska','LDAP Identity Name');
INSERT INTO international VALUES (123,'WebGUI','Svenska','LDAP Password Name');
INSERT INTO international VALUES (124,'WebGUI','Svenska','Edit Company Information');
INSERT INTO international VALUES (125,'WebGUI','Svenska','Företags namn');
INSERT INTO international VALUES (126,'WebGUI','Svenska','Företags Email adress');
INSERT INTO international VALUES (127,'WebGUI','Svenska','Företags URL');
INSERT INTO international VALUES (128,'WebGUI','Svenska','Redigera Fil inställningar');
INSERT INTO international VALUES (129,'WebGUI','Svenska','Path till WebGUI Extras');
INSERT INTO international VALUES (130,'WebGUI','Svenska','Maximal storlek på bilagor');
INSERT INTO international VALUES (131,'WebGUI','Svenska','Web Attachment Path');
INSERT INTO international VALUES (132,'WebGUI','Svenska','Server Attachment Path');
INSERT INTO international VALUES (133,'WebGUI','Svenska','Redigera Mail Inställningar');
INSERT INTO international VALUES (134,'WebGUI','Svenska','Rädda lösenords meddelande');
INSERT INTO international VALUES (135,'WebGUI','Svenska','SMTP Server');
INSERT INTO international VALUES (527,'WebGUI','English','Default Home Page');
INSERT INTO international VALUES (138,'WebGUI','Svenska','Ja');
INSERT INTO international VALUES (139,'WebGUI','Svenska','Nej');
INSERT INTO international VALUES (140,'WebGUI','Svenska','Redigera övriga inställningar');
INSERT INTO international VALUES (141,'WebGUI','Svenska','Not Found Page');
INSERT INTO international VALUES (142,'WebGUI','Svenska','Session Timeout');
INSERT INTO international VALUES (143,'WebGUI','Svenska','Kontrolera inställningar');
INSERT INTO international VALUES (144,'WebGUI','Svenska','Visa statistik.');
INSERT INTO international VALUES (145,'WebGUI','Svenska','WebGUI Build Version');
INSERT INTO international VALUES (146,'WebGUI','Svenska','Aktiva sessioner');
INSERT INTO international VALUES (147,'WebGUI','Svenska','Sidor');
INSERT INTO international VALUES (148,'WebGUI','Svenska','Wobjects');
INSERT INTO international VALUES (149,'WebGUI','Svenska','Användare');
INSERT INTO international VALUES (151,'WebGUI','Svenska','Stil namn');
INSERT INTO international VALUES (501,'WebGUI','English','Body');
INSERT INTO international VALUES (154,'WebGUI','Svenska','Stil schema (Style Sheet)');
INSERT INTO international VALUES (155,'WebGUI','Svenska','Är du säker på att du vill radera denna stil och vilket resulterar i att alla sidor som använder den stilen kommer använda \"Fail Safe\" stilen?');
INSERT INTO international VALUES (156,'WebGUI','Svenska','Redigera stil');
INSERT INTO international VALUES (157,'WebGUI','Svenska','Stilar');
INSERT INTO international VALUES (158,'WebGUI','Svenska','Lägg till en ny stil.');
INSERT INTO international VALUES (159,'WebGUI','Svenska','Medelande log');
INSERT INTO international VALUES (160,'WebGUI','Svenska','Inlagt den');
INSERT INTO international VALUES (161,'WebGUI','Svenska','Skrivet av');
INSERT INTO international VALUES (162,'WebGUI','Svenska','Är du säker på att du vill ta bort allt ur skräpkorgen?');
INSERT INTO international VALUES (163,'WebGUI','Svenska','Lägg till användare');
INSERT INTO international VALUES (164,'WebGUI','Svenska','Autentiserings metod');
INSERT INTO international VALUES (165,'WebGUI','Svenska','LDAP URL');
INSERT INTO international VALUES (166,'WebGUI','Svenska','Connect DN');
INSERT INTO international VALUES (167,'WebGUI','Svenska','Är du absolut säker att du vill radera denna användare? Var medveten om att all information om denna användare kommer att vara permanent förlorade om du fortsätter.');
INSERT INTO international VALUES (168,'WebGUI','Svenska','Redigera Användare');
INSERT INTO international VALUES (169,'WebGUI','Svenska','Lägg till en ny användare.');
INSERT INTO international VALUES (170,'WebGUI','Svenska','sök');
INSERT INTO international VALUES (171,'WebGUI','Svenska','rich edit');
INSERT INTO international VALUES (174,'WebGUI','Svenska','Visa titel?');
INSERT INTO international VALUES (175,'WebGUI','Svenska','Berarbeta makron?');
INSERT INTO international VALUES (228,'WebGUI','Svenska','Redigerar Meddelande...');
INSERT INTO international VALUES (229,'WebGUI','Svenska','Subject');
INSERT INTO international VALUES (230,'WebGUI','Svenska','Meddelande');
INSERT INTO international VALUES (231,'WebGUI','Svenska','Skickar nytt meddelande...');
INSERT INTO international VALUES (232,'WebGUI','Svenska','no subject');
INSERT INTO international VALUES (233,'WebGUI','Svenska','(eom)');
INSERT INTO international VALUES (234,'WebGUI','Svenska','Skickar svar...');
INSERT INTO international VALUES (237,'WebGUI','Svenska','Subject:');
INSERT INTO international VALUES (238,'WebGUI','Svenska','Författare:');
INSERT INTO international VALUES (239,'WebGUI','Svenska','Datum:');
INSERT INTO international VALUES (240,'WebGUI','Svenska','Meddelande ID:');
INSERT INTO international VALUES (244,'WebGUI','Svenska','Författare');
INSERT INTO international VALUES (245,'WebGUI','Svenska','Datum');
INSERT INTO international VALUES (304,'WebGUI','Svenska','Språk');
INSERT INTO international VALUES (306,'WebGUI','Svenska','Username Binding');
INSERT INTO international VALUES (307,'WebGUI','Svenska','Använd den vanliga meta tagen?');
INSERT INTO international VALUES (308,'WebGUI','Svenska','Redigera profilinställningar');
INSERT INTO international VALUES (309,'WebGUI','Svenska','Tillåt riktigt namn?');
INSERT INTO international VALUES (310,'WebGUI','Svenska','Tillåt extra kontaktinformation?');
INSERT INTO international VALUES (311,'WebGUI','Svenska','Tillåt heminformation?');
INSERT INTO international VALUES (312,'WebGUI','Svenska','Tillåt företagsinformation?');
INSERT INTO international VALUES (313,'WebGUI','Svenska','Tillåt extra informaiton?');
INSERT INTO international VALUES (314,'WebGUI','Svenska','Förnamn');
INSERT INTO international VALUES (315,'WebGUI','Svenska','Mellannamn');
INSERT INTO international VALUES (316,'WebGUI','Svenska','Efternamn');
INSERT INTO international VALUES (317,'WebGUI','Svenska','ICQ UIN');
INSERT INTO international VALUES (318,'WebGUI','Svenska','AIM Id');
INSERT INTO international VALUES (319,'WebGUI','Svenska','MSN Messenger Id');
INSERT INTO international VALUES (320,'WebGUI','Svenska','Yahoo! Messenger Id');
INSERT INTO international VALUES (321,'WebGUI','Svenska','Mobil nummer');
INSERT INTO international VALUES (322,'WebGUI','Svenska','Personsökare');
INSERT INTO international VALUES (323,'WebGUI','Svenska','Hem adress');
INSERT INTO international VALUES (324,'WebGUI','Svenska','Hem stad');
INSERT INTO international VALUES (325,'WebGUI','Svenska','Hem län');
INSERT INTO international VALUES (326,'WebGUI','Svenska','Hem postnummer');
INSERT INTO international VALUES (327,'WebGUI','Svenska','Hem land');
INSERT INTO international VALUES (328,'WebGUI','Svenska','Hem telefon');
INSERT INTO international VALUES (329,'WebGUI','Svenska','Arbets adress');
INSERT INTO international VALUES (330,'WebGUI','Svenska','Arbets stad');
INSERT INTO international VALUES (331,'WebGUI','Svenska','Arbets län');
INSERT INTO international VALUES (332,'WebGUI','Svenska','Arbets postnummer');
INSERT INTO international VALUES (333,'WebGUI','Svenska','Arbets land');
INSERT INTO international VALUES (334,'WebGUI','Svenska','Arbets telefon');
INSERT INTO international VALUES (335,'WebGUI','Svenska','Kön');
INSERT INTO international VALUES (336,'WebGUI','Svenska','Födelsedatum');
INSERT INTO international VALUES (337,'WebGUI','Svenska','Hemside URL');
INSERT INTO international VALUES (338,'WebGUI','Svenska','Redigera profil');
INSERT INTO international VALUES (339,'WebGUI','Svenska','Man');
INSERT INTO international VALUES (340,'WebGUI','Svenska','Kvinna');
INSERT INTO international VALUES (341,'WebGUI','Svenska','Redigera profil.');
INSERT INTO international VALUES (342,'WebGUI','Svenska','Redigera kontoinformation.');
INSERT INTO international VALUES (343,'WebGUI','Svenska','Visa profil.');
INSERT INTO international VALUES (345,'WebGUI','Svenska','Inte en medlem');
INSERT INTO international VALUES (346,'WebGUI','Svenska','Denna användare är inte längre medlem på vår site. Vi har ingen vidare information om användaren.');
INSERT INTO international VALUES (347,'WebGUI','Svenska','Visa profilen för');
INSERT INTO international VALUES (348,'WebGUI','Svenska','Namn');
INSERT INTO international VALUES (349,'WebGUI','Svenska','Senaste tillgängliga version');
INSERT INTO international VALUES (350,'WebGUI','Svenska','Avslutad');
INSERT INTO international VALUES (351,'WebGUI','Svenska','Medelandelog Post');
INSERT INTO international VALUES (352,'WebGUI','Svenska','Skapat datum');
INSERT INTO international VALUES (353,'WebGUI','Svenska','Du har inga nya logmedelanden just nu.');
INSERT INTO international VALUES (354,'WebGUI','Svenska','Visa medelande log.');
INSERT INTO international VALUES (355,'WebGUI','Svenska','Standard');
INSERT INTO international VALUES (356,'WebGUI','Svenska','Mall');
INSERT INTO international VALUES (357,'WebGUI','Svenska','Nyheter');
INSERT INTO international VALUES (358,'WebGUI','Svenska','Vänster kolumn');
INSERT INTO international VALUES (359,'WebGUI','Svenska','Höger kolumn');
INSERT INTO international VALUES (360,'WebGUI','Svenska','En över tre');
INSERT INTO international VALUES (361,'WebGUI','Svenska','Tre över en');
INSERT INTO international VALUES (362,'WebGUI','Svenska','SidaVidSida');
INSERT INTO international VALUES (363,'WebGUI','Svenska','Mall position');
INSERT INTO international VALUES (364,'WebGUI','Svenska','Sök');
INSERT INTO international VALUES (365,'WebGUI','Svenska','Sökresultaten..');
INSERT INTO international VALUES (366,'WebGUI','Svenska','Inga sidor hittades som stämde med din förfrågan.');
INSERT INTO international VALUES (368,'WebGUI','Svenska','Lägg till en ny grupp till denna användare.');
INSERT INTO international VALUES (369,'WebGUI','Svenska','Bästföre datum');
INSERT INTO international VALUES (370,'WebGUI','Svenska','Redigera gruppering');
INSERT INTO international VALUES (371,'WebGUI','Svenska','Lägg till gruppering');
INSERT INTO international VALUES (372,'WebGUI','Svenska','Redigera Användares Grupper');
INSERT INTO international VALUES (373,'WebGUI','Svenska','&lt;b&gt;Varning:&lt;/b&gt; Genom att redigera listan ovan så kommer du att återställa alla bästföre datum för varje grupp till standard värdet.');
INSERT INTO international VALUES (374,'WebGUI','Svenska','Hantera paket.');
INSERT INTO international VALUES (375,'WebGUI','Svenska','Välj ett paket att använda');
INSERT INTO international VALUES (376,'WebGUI','Svenska','Paket');
INSERT INTO international VALUES (377,'WebGUI','Svenska','Inga paket har definierats av din packet hanterare eller administratör.');
INSERT INTO international VALUES (11,'Poll','Svenska','Rösta!');
INSERT INTO international VALUES (31,'UserSubmission','Svenska','Inehåll');
INSERT INTO international VALUES (32,'UserSubmission','Svenska','Bild');
INSERT INTO international VALUES (33,'UserSubmission','Svenska','Bilag');
INSERT INTO international VALUES (34,'UserSubmission','Svenska','Konvertera radbrytningar');
INSERT INTO international VALUES (35,'UserSubmission','Svenska','Titel');
INSERT INTO international VALUES (36,'UserSubmission','Svenska','Radera fil.');
INSERT INTO international VALUES (378,'WebGUI','Svenska','Användar ID');
INSERT INTO international VALUES (379,'WebGUI','Svenska','Grupp ID');
INSERT INTO international VALUES (380,'WebGUI','Svenska','Stil ID');
INSERT INTO international VALUES (381,'WebGUI','Svenska','WebGUI fick in en felformulerad förfrågan och kunde inte fortsätta. Oftast beror detta på ovanliga tecken som skickas från ett formulär. Du kan försöka med att gå tillbaka och försöka igen.');
INSERT INTO international VALUES (1,'DownloadManager','Svenska','Filhanterare');
INSERT INTO international VALUES (2,'DownloadManager','Svenska','Lägg till en Filhanterare');
INSERT INTO international VALUES (3,'DownloadManager','Svenska','Fortsätt med att lägga till fil?');
INSERT INTO international VALUES (4,'DownloadManager','Svenska','Läggtill Nedladdning');
INSERT INTO international VALUES (5,'DownloadManager','Svenska','Fil Titel');
INSERT INTO international VALUES (6,'DownloadManager','Svenska','Ladda ned fil');
INSERT INTO international VALUES (7,'DownloadManager','Svenska','Grupp för nedladdning');
INSERT INTO international VALUES (8,'DownloadManager','Svenska','Kort Beskrivning');
INSERT INTO international VALUES (9,'DownloadManager','Svenska','Redigera Filhanterare');
INSERT INTO international VALUES (10,'DownloadManager','Svenska','Redigera Nedladdning');
INSERT INTO international VALUES (11,'DownloadManager','Svenska','Lägg till en ny nedladdning.');
INSERT INTO international VALUES (12,'DownloadManager','Svenska','Är du säker på att du vill ta bort denna nedladdning?');
INSERT INTO international VALUES (13,'DownloadManager','Svenska','Radera');
INSERT INTO international VALUES (14,'DownloadManager','Svenska','Fil');
INSERT INTO international VALUES (15,'DownloadManager','Svenska','Beskrivning');
INSERT INTO international VALUES (16,'DownloadManager','Svenska','Uppladat den');
INSERT INTO international VALUES (15,'Article','Svenska','Höger');
INSERT INTO international VALUES (16,'Article','Svenska','Vänster');
INSERT INTO international VALUES (17,'Article','Svenska','Centrera');
INSERT INTO international VALUES (37,'UserSubmission','Svenska','Radera');
INSERT INTO international VALUES (13,'SQLReport','Svenska','Konvertera radbrytning?');
INSERT INTO international VALUES (17,'DownloadManager','Svenska','Alternativ Version #1');
INSERT INTO international VALUES (18,'DownloadManager','Svenska','Alternativ Version #2');
INSERT INTO international VALUES (19,'DownloadManager','Svenska','Du har inga filer att ladda ned.');
INSERT INTO international VALUES (14,'EventsCalendar','Svenska','Start datum');
INSERT INTO international VALUES (15,'EventsCalendar','Svenska','Slut datum');
INSERT INTO international VALUES (20,'DownloadManager','Svenska','Sidbrytning efter');
INSERT INTO international VALUES (14,'SQLReport','Svenska','Sidbrytning efter');
INSERT INTO international VALUES (16,'EventsCalendar','Svenska','Kalender utseende');
INSERT INTO international VALUES (17,'EventsCalendar','Svenska','Lista');
INSERT INTO international VALUES (18,'EventsCalendar','Svenska','Kalender');
INSERT INTO international VALUES (19,'EventsCalendar','Svenska','Sidbrytning efter');
INSERT INTO international VALUES (354,'WebGUI','English','View Inbox.');
INSERT INTO international VALUES (383,'WebGUI','Svenska','Namn');
INSERT INTO international VALUES (384,'WebGUI','Svenska','Fil');
INSERT INTO international VALUES (385,'WebGUI','Svenska','Parametrar');
INSERT INTO international VALUES (386,'WebGUI','Svenska','Redigera Bild');
INSERT INTO international VALUES (387,'WebGUI','Svenska','Uppladat av');
INSERT INTO international VALUES (388,'WebGUI','Svenska','Uppladat den');
INSERT INTO international VALUES (389,'WebGUI','Svenska','Bild ID');
INSERT INTO international VALUES (390,'WebGUI','Svenska','Visar bild...');
INSERT INTO international VALUES (391,'WebGUI','Svenska','Radera');
INSERT INTO international VALUES (392,'WebGUI','Svenska','Är du säker på att du vill radera denna bild?');
INSERT INTO international VALUES (393,'WebGUI','Svenska','Hantera Bilder');
INSERT INTO international VALUES (394,'WebGUI','Svenska','Hantera bilder.');
INSERT INTO international VALUES (395,'WebGUI','Svenska','Lägg till en ny bild.');
INSERT INTO international VALUES (396,'WebGUI','Svenska','Visa bild');
INSERT INTO international VALUES (397,'WebGUI','Svenska','Tillbaka till bildlistan.');
INSERT INTO international VALUES (398,'WebGUI','Svenska','Dokument Typ Deklaration');
INSERT INTO international VALUES (399,'WebGUI','Svenska','Validera denna sida.');
INSERT INTO international VALUES (400,'WebGUI','Svenska','Blokera Proxy Caching');
INSERT INTO international VALUES (401,'WebGUI','Svenska','Är du säker på att du vill radera medelandet och alla undermedelanden i denna tråd?');
INSERT INTO international VALUES (21,'MessageBoard','Svenska','Vem kan moderera?');
INSERT INTO international VALUES (22,'MessageBoard','Svenska','Radera Medelandet');
INSERT INTO international VALUES (402,'WebGUI','Svenska','Medelandet du frågade efter existerar inte.');
INSERT INTO international VALUES (403,'WebGUI','Svenska','Föredrar att inte säga.');
INSERT INTO international VALUES (405,'WebGUI','Svenska','Sista sidan');
INSERT INTO international VALUES (407,'WebGUI','Svenska','Klicka här för att registrera.');
INSERT INTO international VALUES (15,'SQLReport','Svenska','Förbearbeta macron vid förfrågan?');
INSERT INTO international VALUES (16,'SQLReport','Svenska','Debug?');
INSERT INTO international VALUES (17,'SQLReport','Svenska','&lt;b&gt;Debug:&lt;/b&gt; Förfrågan(query):');
INSERT INTO international VALUES (18,'SQLReport','Svenska','Det fanns inga resultat för denna förfrågan.');
INSERT INTO international VALUES (408,'WebGUI','Svenska','Hantera bassidor(Roots)');
INSERT INTO international VALUES (409,'WebGUI','Svenska','Lägg till en ny bassida.');
INSERT INTO international VALUES (410,'WebGUI','Svenska','Hantera bassidor.');
INSERT INTO international VALUES (411,'WebGUI','Svenska','Huvud titel');
INSERT INTO international VALUES (412,'WebGUI','Svenska','Synopsis');
INSERT INTO international VALUES (9,'SiteMap','Svenska','Visa synopsis?');
INSERT INTO international VALUES (18,'Article','Svenska','Tillåt diskusion');
INSERT INTO international VALUES (19,'Article','Svenska','Vem kan posta?');
INSERT INTO international VALUES (20,'Article','Svenska','Vem kan moderera?');
INSERT INTO international VALUES (21,'Article','Svenska','Redigera Timeout');
INSERT INTO international VALUES (22,'Article','Svenska','Författare');
INSERT INTO international VALUES (23,'Article','Svenska','Datum');
INSERT INTO international VALUES (24,'Article','Svenska','Skicka svar');
INSERT INTO international VALUES (25,'Article','Svenska','Redigera svar');
INSERT INTO international VALUES (26,'Article','Svenska','Radera svar');
INSERT INTO international VALUES (27,'Article','Svenska','Tillbaka till artikel');
INSERT INTO international VALUES (413,'WebGUI','Svenska','Vid kritiskta fel');
INSERT INTO international VALUES (28,'Article','Svenska','Visa svar');
INSERT INTO international VALUES (414,'WebGUI','Svenska','Visa debugg information.');
INSERT INTO international VALUES (415,'WebGUI','Svenska','Visa ett användarvänligt medelande.');
INSERT INTO international VALUES (416,'WebGUI','Svenska','&lt;h1&gt;Problem Med Förfrågan&lt;/h1&gt;\r\nVi har stött på ett problem med din förfrågan. Var vänlig och gå tillbaka och fösök igen. Om problemet kvarstår var vänlig och rapportera detta till oss med tid och datum samt vad du försökte göra.');
INSERT INTO international VALUES (417,'WebGUI','Svenska','&lt;h1&gt;Säkerhets Överträdelse&lt;/h1&gt;\r\nDu försökte att komma åt en wobject som inte associeras med denna sida. Denna incident har rapporterats.');
INSERT INTO international VALUES (418,'WebGUI','Svenska','Ta bort inmatad HTML');
INSERT INTO international VALUES (419,'WebGUI','Svenska','Ta bort alla taggar.');
INSERT INTO international VALUES (420,'WebGUI','Svenska','Lämna som den är.');
INSERT INTO international VALUES (421,'WebGUI','Svenska','Ta bort allt utom grundformateringen.');
INSERT INTO international VALUES (422,'WebGUI','Svenska','&lt;h1&gt;Inloggning misslyckades&lt;/h1&gt;\r\nInformationen du gav stämmer inte med kontot.');
INSERT INTO international VALUES (423,'WebGUI','Svenska','Visa aktiva sessioner.');
INSERT INTO international VALUES (424,'WebGUI','Svenska','Visa logginhistorik.');
INSERT INTO international VALUES (425,'WebGUI','Svenska','Aktiva sessioner');
INSERT INTO international VALUES (426,'WebGUI','Svenska','Inloggnings historik');
INSERT INTO international VALUES (427,'WebGUI','Svenska','Stilar');
INSERT INTO international VALUES (428,'WebGUI','Svenska','Användar (ID)');
INSERT INTO international VALUES (429,'WebGUI','Svenska','Inloggnings tid');
INSERT INTO international VALUES (430,'WebGUI','Svenska','Senaste sida visad');
INSERT INTO international VALUES (431,'WebGUI','Svenska','IP Adress');
INSERT INTO international VALUES (432,'WebGUI','Svenska','Bäst före');
INSERT INTO international VALUES (433,'WebGUI','Svenska','Användar Klient (Browser)');
INSERT INTO international VALUES (434,'WebGUI','Svenska','Status');
INSERT INTO international VALUES (435,'WebGUI','Svenska','Sessions signatur');
INSERT INTO international VALUES (436,'WebGUI','Svenska','Avsluta session');
INSERT INTO international VALUES (437,'WebGUI','Svenska','Statistik');
INSERT INTO international VALUES (438,'WebGUI','Svenska','Ditt namn');
INSERT INTO international VALUES (439,'WebGUI','Svenska','Personlig Information');
INSERT INTO international VALUES (440,'WebGUI','Svenska','Kontakt Information');
INSERT INTO international VALUES (441,'WebGUI','Svenska','E-Mail till personsökar-gateway');
INSERT INTO international VALUES (442,'WebGUI','Svenska','Arbets Information');
INSERT INTO international VALUES (443,'WebGUI','Svenska','Hem Information');
INSERT INTO international VALUES (444,'WebGUI','Svenska','Demografisk Information');
INSERT INTO international VALUES (445,'WebGUI','Svenska','Inställningar');
INSERT INTO international VALUES (446,'WebGUI','Svenska','Arbetets Website');
INSERT INTO international VALUES (447,'WebGUI','Svenska','Hantera sidträd.');
INSERT INTO international VALUES (448,'WebGUI','Svenska','Sid träd');
INSERT INTO international VALUES (449,'WebGUI','Svenska','Övrig information');
INSERT INTO international VALUES (450,'WebGUI','Svenska','Jobb Namn (Namn på företaget)');
INSERT INTO international VALUES (451,'WebGUI','Svenska','är obligatoriskt.');
INSERT INTO international VALUES (452,'WebGUI','Svenska','Var god vänta...');
INSERT INTO international VALUES (453,'WebGUI','Svenska','Skapad den');
INSERT INTO international VALUES (454,'WebGUI','Svenska','Senast Uppdaterad');
INSERT INTO international VALUES (455,'WebGUI','Svenska','Redigera Användar Profil');
INSERT INTO international VALUES (456,'WebGUI','Svenska','Tillbaka till användarlistan.');
INSERT INTO international VALUES (457,'WebGUI','Svenska','Redigera denna användares konto.');
INSERT INTO international VALUES (458,'WebGUI','Svenska','Redigera denna användares grupper.');
INSERT INTO international VALUES (459,'WebGUI','Svenska','Redigera denna användares profil.');
INSERT INTO international VALUES (460,'WebGUI','Svenska','Tidsoffset');
INSERT INTO international VALUES (461,'WebGUI','Svenska','Datum Format');
INSERT INTO international VALUES (462,'WebGUI','Svenska','Tids Format');
INSERT INTO international VALUES (463,'WebGUI','Svenska','Text Fält Rader');
INSERT INTO international VALUES (464,'WebGUI','Svenska','Text Fält Kolumner');
INSERT INTO international VALUES (465,'WebGUI','Svenska','Text Box Storlek');
INSERT INTO international VALUES (466,'WebGUI','Svenska','Är du säker på att du vill ta bort denna kategori och flytta alla dess attribut till Övrigt kattegorin.');
INSERT INTO international VALUES (467,'WebGUI','Svenska','Är du säker på att du vill ta bort detta attribut och all användar data som finns i det ?');
INSERT INTO international VALUES (468,'WebGUI','English','Edit User Profile Category');
INSERT INTO international VALUES (469,'WebGUI','Svenska','Id');
INSERT INTO international VALUES (470,'WebGUI','Svenska','Namn');
INSERT INTO international VALUES (159,'WebGUI','English','Inbox');
INSERT INTO international VALUES (472,'WebGUI','Svenska','Märke');
INSERT INTO international VALUES (473,'WebGUI','Svenska','Synligt?');
INSERT INTO international VALUES (474,'WebGUI','Svenska','Obligatoriskt?');
INSERT INTO international VALUES (475,'WebGUI','Svenska','Text');
INSERT INTO international VALUES (476,'WebGUI','Svenska','Text Område');
INSERT INTO international VALUES (477,'WebGUI','Svenska','HTML Område');
INSERT INTO international VALUES (478,'WebGUI','Svenska','URL');
INSERT INTO international VALUES (479,'WebGUI','Svenska','Datum');
INSERT INTO international VALUES (480,'WebGUI','Svenska','Email adress');
INSERT INTO international VALUES (481,'WebGUI','Svenska','Telefånnummer');
INSERT INTO international VALUES (482,'WebGUI','Svenska','Nummer (Heltal)');
INSERT INTO international VALUES (483,'WebGUI','Svenska','Ja eller Nej');
INSERT INTO international VALUES (484,'WebGUI','Svenska','Vallista');
INSERT INTO international VALUES (485,'WebGUI','Svenska','Boolean (Kryssbox)');
INSERT INTO international VALUES (486,'WebGUI','Svenska','Data typ');
INSERT INTO international VALUES (487,'WebGUI','Svenska','Möjliga värden');
INSERT INTO international VALUES (488,'WebGUI','Svenska','Standar värden');
INSERT INTO international VALUES (489,'WebGUI','Svenska','Profil kategorier.');
INSERT INTO international VALUES (490,'WebGUI','Svenska','Lägg till en profilkategori.');
INSERT INTO international VALUES (491,'WebGUI','Svenska','Lägg till profilattribut.');
INSERT INTO international VALUES (492,'WebGUI','Svenska','Profil attribut lista.');
INSERT INTO international VALUES (493,'WebGUI','Svenska','Tillbaka till siten.');
INSERT INTO international VALUES (507,'WebGUI','English','Edit Template');
INSERT INTO international VALUES (508,'WebGUI','English','Manage templates.');
INSERT INTO international VALUES (39,'UserSubmission','English','Post a Reply');
INSERT INTO international VALUES (40,'UserSubmission','English','Posted by');
INSERT INTO international VALUES (41,'UserSubmission','English','Date');
INSERT INTO international VALUES (42,'UserSubmission','English','Edit Response');
INSERT INTO international VALUES (43,'UserSubmission','English','Delete Response');
INSERT INTO international VALUES (45,'UserSubmission','English','Return to Submission');
INSERT INTO international VALUES (46,'UserSubmission','English','Read more...');
INSERT INTO international VALUES (47,'UserSubmission','English','Post a Response');
INSERT INTO international VALUES (48,'UserSubmission','English','Allow discussion?');
INSERT INTO international VALUES (49,'UserSubmission','English','Edit Timeout');
INSERT INTO international VALUES (50,'UserSubmission','English','Group To Post');
INSERT INTO international VALUES (44,'UserSubmission','English','Group To Moderate');
INSERT INTO international VALUES (51,'UserSubmission','English','Display thumbnails?');
INSERT INTO international VALUES (52,'UserSubmission','English','Thumbnail');
INSERT INTO international VALUES (53,'UserSubmission','English','Layout');
INSERT INTO international VALUES (54,'UserSubmission','English','Web Log');
INSERT INTO international VALUES (55,'UserSubmission','English','Traditional');
INSERT INTO international VALUES (56,'UserSubmission','English','Photo Gallery');
INSERT INTO international VALUES (57,'UserSubmission','English','Responses');
INSERT INTO international VALUES (11,'FAQ','English','Turn TOC on?');
INSERT INTO international VALUES (12,'FAQ','English','Turn Q/A on?');
INSERT INTO international VALUES (13,'FAQ','English','Turn [top] link on?');
INSERT INTO international VALUES (14,'FAQ','English','Q');
INSERT INTO international VALUES (15,'FAQ','English','A');
INSERT INTO international VALUES (16,'FAQ','English','[top]');
INSERT INTO international VALUES (509,'WebGUI','English','Discussion Layout');
INSERT INTO international VALUES (510,'WebGUI','English','Flat');
INSERT INTO international VALUES (511,'WebGUI','English','Threaded');
INSERT INTO international VALUES (512,'WebGUI','English','Next Thread');
INSERT INTO international VALUES (513,'WebGUI','English','Previous Thread');
INSERT INTO international VALUES (8,'Article','Dansk','henvisning URL');
INSERT INTO international VALUES (9,'Article','Dansk','Vis besvarelser');
INSERT INTO international VALUES (10,'Article','Dansk','Konverter linieskift?');
INSERT INTO international VALUES (11,'Article','Dansk','\"(Kontroller at du ikke tilføjer &lt;br&gt; manuelt.)\"');
INSERT INTO international VALUES (12,'Article','Dansk','rediger artikel');
INSERT INTO international VALUES (13,'Article','Dansk','Slet');
INSERT INTO international VALUES (14,'Article','Dansk','Placer billede');
INSERT INTO international VALUES (15,'Article','Dansk','Højre');
INSERT INTO international VALUES (16,'Article','Dansk','Venstre');
INSERT INTO international VALUES (17,'Article','Dansk','Centreret');
INSERT INTO international VALUES (18,'Article','Dansk','Tillad diskussion?');
INSERT INTO international VALUES (19,'Article','Dansk','Hvem kan oprette indlæg?');
INSERT INTO international VALUES (20,'Article','Dansk','Hvem kan moderere?');
INSERT INTO international VALUES (21,'Article','Dansk','Rediger Timeout');
INSERT INTO international VALUES (22,'Article','Dansk','Forfatter');
INSERT INTO international VALUES (23,'Article','Dansk','Dato');
INSERT INTO international VALUES (24,'Article','Dansk','Send respons');
INSERT INTO international VALUES (25,'Article','Dansk','Rediger respons');
INSERT INTO international VALUES (26,'Article','Dansk','Slet respons');
INSERT INTO international VALUES (27,'Article','Dansk','Tilbage til artikel');
INSERT INTO international VALUES (28,'Article','Dansk','Vis respons');
INSERT INTO international VALUES (1,'DownloadManager','Dansk','Download Manager');
INSERT INTO international VALUES (2,'DownloadManager','Dansk','Tilføj Download Manager');
INSERT INTO international VALUES (3,'DownloadManager','Dansk','Fortsæt med at tilføje fil?');
INSERT INTO international VALUES (4,'DownloadManager','Dansk','Tilføj Download');
INSERT INTO international VALUES (5,'DownloadManager','Dansk','Navn på fil');
INSERT INTO international VALUES (6,'DownloadManager','Dansk','Hent fil');
INSERT INTO international VALUES (7,'DownloadManager','Dansk','Gruppe til Download');
INSERT INTO international VALUES (8,'DownloadManager','Dansk','Kort beskrivelse');
INSERT INTO international VALUES (9,'DownloadManager','Dansk','rediger Download Manager');
INSERT INTO international VALUES (10,'DownloadManager','Dansk','rediger Download  ');
INSERT INTO international VALUES (11,'DownloadManager','Dansk','Tilføj ny Download');
INSERT INTO international VALUES (12,'DownloadManager','Dansk','Er du sikker på du vil slette denne Download?');
INSERT INTO international VALUES (13,'DownloadManager','Dansk','Slet tilføjet fil?');
INSERT INTO international VALUES (14,'DownloadManager','Dansk','Fil');
INSERT INTO international VALUES (15,'DownloadManager','Dansk','Beskrivelse');
INSERT INTO international VALUES (16,'DownloadManager','Dansk','Oprettelsesdato');
INSERT INTO international VALUES (17,'DownloadManager','Dansk','Alternativ version nr. 1');
INSERT INTO international VALUES (18,'DownloadManager','Dansk','Alternativ version nr. 2');
INSERT INTO international VALUES (19,'DownloadManager','Dansk','Du har ikke nogen filer til Download');
INSERT INTO international VALUES (20,'DownloadManager','Dansk','Slet efter');
INSERT INTO international VALUES (21,'DownloadManager','Dansk','Hvis miniature?');
INSERT INTO international VALUES (1,'EventsCalendar','Dansk','Fortsæt med at tilføje begivenhed?');
INSERT INTO international VALUES (2,'EventsCalendar','Dansk','Begivenheds kalender');
INSERT INTO international VALUES (3,'EventsCalendar','Dansk','Tilføj begivenheds kalender');
INSERT INTO international VALUES (4,'EventsCalendar','Dansk','Begivenhed sker én gang');
INSERT INTO international VALUES (5,'EventsCalendar','Dansk','dag');
INSERT INTO international VALUES (6,'EventsCalendar','Dansk','uge');
INSERT INTO international VALUES (7,'EventsCalendar','Dansk','Tilføj begivenhed ');
INSERT INTO international VALUES (8,'EventsCalendar','Dansk','Gentages hver');
INSERT INTO international VALUES (9,'EventsCalendar','Dansk','indtil');
INSERT INTO international VALUES (10,'EventsCalendar','Dansk','Er du sikker på du vil slette denne begivenhed');
INSERT INTO international VALUES (11,'EventsCalendar','Dansk','<b>og</b> alle gentagelser af begivenhed');
INSERT INTO international VALUES (12,'EventsCalendar','Dansk','rediger begivenheds kalender');
INSERT INTO international VALUES (13,'EventsCalendar','Dansk','rediger begivenhed ');
INSERT INTO international VALUES (14,'EventsCalendar','Dansk','Fra dato');
INSERT INTO international VALUES (15,'EventsCalendar','Dansk','Til dato');
INSERT INTO international VALUES (16,'EventsCalendar','Dansk','Kalender layout');
INSERT INTO international VALUES (17,'EventsCalendar','Dansk','Liste');
INSERT INTO international VALUES (18,'EventsCalendar','Dansk','Kalender  ');
INSERT INTO international VALUES (19,'EventsCalendar','Dansk','Slet efter ');
INSERT INTO international VALUES (1,'ExtraColumn','Dansk','Ekstra kolonne');
INSERT INTO international VALUES (2,'ExtraColumn','Dansk','Tilføj ekstra kolonne');
INSERT INTO international VALUES (3,'ExtraColumn','Dansk','Mellemrum');
INSERT INTO international VALUES (4,'ExtraColumn','Dansk','Bredde');
INSERT INTO international VALUES (5,'ExtraColumn','Dansk','stilarter klasse');
INSERT INTO international VALUES (6,'ExtraColumn','Dansk','rediger ekstra kolonne');
INSERT INTO international VALUES (1,'FAQ','Dansk','Fortsæt med at tilføje spørgsmål?');
INSERT INTO international VALUES (2,'FAQ','Dansk','Ofte stillede spørgsmål (F.A.Q.)');
INSERT INTO international VALUES (3,'FAQ','Dansk','Tilføj F.A.Q.');
INSERT INTO international VALUES (4,'FAQ','Dansk','Tilføj spørgsmål');
INSERT INTO international VALUES (5,'FAQ','Dansk','Spørgsmål');
INSERT INTO international VALUES (6,'FAQ','Dansk','Svar');
INSERT INTO international VALUES (7,'FAQ','Dansk','Er du sikker på du vil slette dette spørgsmål');
INSERT INTO international VALUES (8,'FAQ','Dansk','Rediger F.A.Q.');
INSERT INTO international VALUES (9,'FAQ','Dansk','Tilføj nyt spørgsmål');
INSERT INTO international VALUES (10,'FAQ','Dansk','rediger spørgsmål');
INSERT INTO international VALUES (1,'Item','Dansk','henvisning URL');
INSERT INTO international VALUES (2,'Item','Dansk','Vedhæft');
INSERT INTO international VALUES (3,'Item','Dansk','Slet vedhæft');
INSERT INTO international VALUES (4,'Item','Dansk','Item');
INSERT INTO international VALUES (5,'Item','Dansk','Hent vedhæftet');
INSERT INTO international VALUES (1,'LinkList','Dansk','Indryk');
INSERT INTO international VALUES (2,'LinkList','Dansk','Linie afstand');
INSERT INTO international VALUES (3,'LinkList','Dansk','Skal der åbnes i nyt vindue?');
INSERT INTO international VALUES (4,'LinkList','Dansk','Punkt');
INSERT INTO international VALUES (5,'LinkList','Dansk','Fortsæt med at tilføje henvisning');
INSERT INTO international VALUES (6,'LinkList','Dansk','Liste over henvisning');
INSERT INTO international VALUES (7,'LinkList','Dansk','Tilføj henvisning');
INSERT INTO international VALUES (8,'LinkList','Dansk','URL');
INSERT INTO international VALUES (9,'LinkList','Dansk','Er du sikker på du vil slette denne henvisning');
INSERT INTO international VALUES (10,'LinkList','Dansk','Rediger henvisnings liste');
INSERT INTO international VALUES (11,'LinkList','Dansk','Tilføj henvisnings liste');
INSERT INTO international VALUES (12,'LinkList','Dansk','Rediger henvisning  ');
INSERT INTO international VALUES (13,'LinkList','Dansk','Tilføj ny henvisning');
INSERT INTO international VALUES (1,'MessageBoard','Dansk','Tilføj opslagstavle');
INSERT INTO international VALUES (2,'MessageBoard','Dansk','Opslagstavle');
INSERT INTO international VALUES (3,'MessageBoard','Dansk','Hvem kan komme med indlæg?');
INSERT INTO international VALUES (4,'MessageBoard','Dansk','Antal beskeder pr. side');
INSERT INTO international VALUES (5,'MessageBoard','Dansk','Rediger Timeout');
INSERT INTO international VALUES (6,'MessageBoard','Dansk','Rediger opslagstavle');
INSERT INTO international VALUES (7,'MessageBoard','Dansk','Forfatter:');
INSERT INTO international VALUES (8,'MessageBoard','Dansk','Dato:');
INSERT INTO international VALUES (9,'MessageBoard','Dansk','Besked nr.:');
INSERT INTO international VALUES (10,'MessageBoard','Dansk','Forrige tråd');
INSERT INTO international VALUES (11,'MessageBoard','Dansk','Tilbage til oversigt');
INSERT INTO international VALUES (12,'MessageBoard','Dansk','Rediger meddelelses');
INSERT INTO international VALUES (13,'MessageBoard','Dansk','Send respons');
INSERT INTO international VALUES (14,'MessageBoard','Dansk','Næste tråd');
INSERT INTO international VALUES (15,'MessageBoard','Dansk','Forfatter');
INSERT INTO international VALUES (16,'MessageBoard','Dansk','Dato');
INSERT INTO international VALUES (17,'MessageBoard','Dansk','Ny meddelelse');
INSERT INTO international VALUES (18,'MessageBoard','Dansk','Tråd startet');
INSERT INTO international VALUES (19,'MessageBoard','Dansk','Antal svar');
INSERT INTO international VALUES (20,'MessageBoard','Dansk','Seneste svar');
INSERT INTO international VALUES (21,'MessageBoard','Dansk','Hvem kan moderere?');
INSERT INTO international VALUES (22,'MessageBoard','Dansk','Slet besked');
INSERT INTO international VALUES (1,'Poll','Dansk','Afstemning');
INSERT INTO international VALUES (2,'Poll','Dansk','Tilføj afstemning');
INSERT INTO international VALUES (3,'Poll','Dansk','Aktiv');
INSERT INTO international VALUES (4,'Poll','Dansk','Hvem kan stemme');
INSERT INTO international VALUES (5,'Poll','Dansk','Bredde på graf');
INSERT INTO international VALUES (6,'Poll','Dansk','Spørgsmål');
INSERT INTO international VALUES (7,'Poll','Dansk','Svar');
INSERT INTO international VALUES (8,'Poll','Dansk','(Indtast ét svar pr. linie. Ikke mere end 20.)');
INSERT INTO international VALUES (9,'Poll','Dansk','Rediger afstemning');
INSERT INTO international VALUES (10,'Poll','Dansk','Nulstil afstemning');
INSERT INTO international VALUES (11,'Poll','Dansk','Stem!');
INSERT INTO international VALUES (1,'SiteMap','Dansk','Tilføj Site oversigt');
INSERT INTO international VALUES (2,'SiteMap','Dansk','Site oversigt');
INSERT INTO international VALUES (3,'SiteMap','Dansk','Startende fra dette niveau');
INSERT INTO international VALUES (4,'SiteMap','Dansk','Dybde?');
INSERT INTO international VALUES (5,'SiteMap','Dansk','Rediger Site oversigt');
INSERT INTO international VALUES (6,'SiteMap','Dansk','Indryk');
INSERT INTO international VALUES (7,'SiteMap','Dansk','Punkt');
INSERT INTO international VALUES (8,'SiteMap','Dansk','Linie afstand');
INSERT INTO international VALUES (9,'SiteMap','Dansk','Vis synopsis?');
INSERT INTO international VALUES (1,'SQLReport','Dansk','SQL rapport');
INSERT INTO international VALUES (2,'SQLReport','Dansk','Tilføj SQL rapport');
INSERT INTO international VALUES (3,'SQLReport','Dansk','Rapport template');
INSERT INTO international VALUES (4,'SQLReport','Dansk','Query');
INSERT INTO international VALUES (5,'SQLReport','Dansk','DSN');
INSERT INTO international VALUES (6,'SQLReport','Dansk','Database bruger');
INSERT INTO international VALUES (7,'SQLReport','Dansk','Database Password');
INSERT INTO international VALUES (8,'SQLReport','Dansk','Rediger SQL rapport');
INSERT INTO international VALUES (9,'SQLReport','Dansk','<b>Debug:</b> Error: The DSN specified is of an improper format.');
INSERT INTO international VALUES (10,'SQLReport','Dansk','<b>Debug:</b> Error: The SQL specified is of an improper format.');
INSERT INTO international VALUES (11,'SQLReport','Dansk','<b>Debug:</b> Error: There was a problem with the query.');
INSERT INTO international VALUES (12,'SQLReport','Dansk','<b>Debug:</b> Error: Could not connect to the database.');
INSERT INTO international VALUES (13,'SQLReport','Dansk','Konverter linieskift?');
INSERT INTO international VALUES (14,'SQLReport','Dansk','Slet efter');
INSERT INTO international VALUES (15,'SQLReport','Dansk','Udfør makroer ved forespørgsel?');
INSERT INTO international VALUES (16,'SQLReport','Dansk','Debut?');
INSERT INTO international VALUES (17,'SQLReport','Dansk','<b>Debug:</b> Query:');
INSERT INTO international VALUES (18,'SQLReport','Dansk','Der var ikke nogen svar til denne forespørgsel!');
INSERT INTO international VALUES (1,'SyndicatedContent','Dansk','URL til RSS fil');
INSERT INTO international VALUES (2,'SyndicatedContent','Dansk','Syndicated Content');
INSERT INTO international VALUES (3,'SyndicatedContent','Dansk','Tilføj Syndicated Content');
INSERT INTO international VALUES (4,'SyndicatedContent','Dansk','Rediger Syndicated Content');
INSERT INTO international VALUES (5,'SyndicatedContent','Dansk','Sidst opdateret');
INSERT INTO international VALUES (6,'SyndicatedContent','Dansk','Gældende indhold');
INSERT INTO international VALUES (1,'UserSubmission','Dansk','Hvem kan godkende indlæg?');
INSERT INTO international VALUES (2,'UserSubmission','Dansk','Hvem kan tilføje indlæg?');
INSERT INTO international VALUES (3,'UserSubmission','Dansk','Du har nye indlæg til godkendelse');
INSERT INTO international VALUES (4,'UserSubmission','Dansk','Dit indlæg er godkendt');
INSERT INTO international VALUES (5,'UserSubmission','Dansk','Dit indlæg er afvist');
INSERT INTO international VALUES (6,'UserSubmission','Dansk','Antal indlæg pr. side');
INSERT INTO international VALUES (7,'UserSubmission','Dansk','Godkendt');
INSERT INTO international VALUES (8,'UserSubmission','Dansk','Afvist');
INSERT INTO international VALUES (9,'UserSubmission','Dansk','Afventer');
INSERT INTO international VALUES (10,'UserSubmission','Dansk','Default Status');
INSERT INTO international VALUES (11,'UserSubmission','Dansk','Tilføj indlæg');
INSERT INTO international VALUES (12,'UserSubmission','Dansk','(Kryds ikke hvis du laver et HTML indlæg.)');
INSERT INTO international VALUES (13,'UserSubmission','Dansk','Tilføjet dato');
INSERT INTO international VALUES (14,'UserSubmission','Dansk','Status');
INSERT INTO international VALUES (15,'UserSubmission','Dansk','Rediger/Slet');
INSERT INTO international VALUES (16,'UserSubmission','Dansk','Ingen titel');
INSERT INTO international VALUES (17,'UserSubmission','Dansk','Er du sikker på du vil slette dette indlæg?');
INSERT INTO international VALUES (18,'UserSubmission','Dansk','Rediger User Submission System');
INSERT INTO international VALUES (19,'UserSubmission','Dansk','Rediger indlæg');
INSERT INTO international VALUES (20,'UserSubmission','Dansk','Lav nyt indlæg');
INSERT INTO international VALUES (21,'UserSubmission','Dansk','Indsendt af');
INSERT INTO international VALUES (22,'UserSubmission','Dansk','Indsendt af:');
INSERT INTO international VALUES (23,'UserSubmission','Dansk','Indsendt dato:');
INSERT INTO international VALUES (24,'UserSubmission','Dansk','Godkendt');
INSERT INTO international VALUES (25,'UserSubmission','Dansk','Afvent ');
INSERT INTO international VALUES (26,'UserSubmission','Dansk','Afvist');
INSERT INTO international VALUES (27,'UserSubmission','Dansk','Rediger');
INSERT INTO international VALUES (28,'UserSubmission','Dansk','Tilbage til Submission oversigt');
INSERT INTO international VALUES (29,'UserSubmission','Dansk','Bruger Indlæg');
INSERT INTO international VALUES (30,'UserSubmission','Dansk','Tilføj bruger indlæg System');
INSERT INTO international VALUES (31,'UserSubmission','Dansk','Indhold');
INSERT INTO international VALUES (32,'UserSubmission','Dansk','Billede');
INSERT INTO international VALUES (33,'UserSubmission','Dansk','Tillæg');
INSERT INTO international VALUES (34,'UserSubmission','Dansk','Konverter linieskift?');
INSERT INTO international VALUES (35,'UserSubmission','Dansk','Titel');
INSERT INTO international VALUES (36,'UserSubmission','Dansk','Slet fil.');
INSERT INTO international VALUES (37,'UserSubmission','Dansk','Slet');
INSERT INTO international VALUES (1,'WebGUI','Dansk','Tilføj indhold');
INSERT INTO international VALUES (2,'WebGUI','Dansk','Side');
INSERT INTO international VALUES (3,'WebGUI','Dansk','Kopier fra udklipsholder');
INSERT INTO international VALUES (4,'WebGUI','Dansk','administrer indstillinger');
INSERT INTO international VALUES (5,'WebGUI','Dansk','administrer grupper');
INSERT INTO international VALUES (6,'WebGUI','Dansk','administrer Stilarter');
INSERT INTO international VALUES (7,'WebGUI','Dansk','administrer brugere');
INSERT INTO international VALUES (8,'WebGUI','Dansk','Vis side_ikke_fundet');
INSERT INTO international VALUES (9,'WebGUI','Dansk','Vis udklipsholder');
INSERT INTO international VALUES (10,'WebGUI','Dansk','administrer skraldespand');
INSERT INTO international VALUES (11,'WebGUI','Dansk','Tøm skraldespand');
INSERT INTO international VALUES (12,'WebGUI','Dansk','Slå administration fra');
INSERT INTO international VALUES (13,'WebGUI','Dansk','Vis hjælpe indeks');
INSERT INTO international VALUES (14,'WebGUI','Dansk','Vis afventende indlæg');
INSERT INTO international VALUES (15,'WebGUI','Dansk','Januar');
INSERT INTO international VALUES (16,'WebGUI','Dansk','Februar');
INSERT INTO international VALUES (17,'WebGUI','Dansk','Marts');
INSERT INTO international VALUES (18,'WebGUI','Dansk','April');
INSERT INTO international VALUES (19,'WebGUI','Dansk','Maj');
INSERT INTO international VALUES (20,'WebGUI','Dansk','Juni');
INSERT INTO international VALUES (21,'WebGUI','Dansk','Juli');
INSERT INTO international VALUES (22,'WebGUI','Dansk','August');
INSERT INTO international VALUES (23,'WebGUI','Dansk','September');
INSERT INTO international VALUES (24,'WebGUI','Dansk','Oktober');
INSERT INTO international VALUES (25,'WebGUI','Dansk','November');
INSERT INTO international VALUES (26,'WebGUI','Dansk','December');
INSERT INTO international VALUES (27,'WebGUI','Dansk','Søndag');
INSERT INTO international VALUES (28,'WebGUI','Dansk','Mandag');
INSERT INTO international VALUES (29,'WebGUI','Dansk','Tirsdag');
INSERT INTO international VALUES (30,'WebGUI','Dansk','Onsdag');
INSERT INTO international VALUES (31,'WebGUI','Dansk','Torsdag');
INSERT INTO international VALUES (32,'WebGUI','Dansk','Fredag');
INSERT INTO international VALUES (33,'WebGUI','Dansk','Lørdag');
INSERT INTO international VALUES (34,'WebGUI','Dansk','Sæt dato');
INSERT INTO international VALUES (35,'WebGUI','Dansk','Administrative funktioner');
INSERT INTO international VALUES (36,'WebGUI','Dansk','Du skal være administrator for at udføre denne funktion. Kontakt en af følgende personer der er administratorer:');
INSERT INTO international VALUES (37,'WebGUI','Dansk','Adgang nægtet!');
INSERT INTO international VALUES (38,'WebGUI','Dansk','\"Du har ikke nødvendige rettigheder til at udføre denne funktion. Venligst log in ^a(log in med en konto); med nødvendige rettigheder før du prøver dette.\"');
INSERT INTO international VALUES (39,'WebGUI','Dansk','Du har ikke rettigheder til at få adgang til denne side.');
INSERT INTO international VALUES (40,'WebGUI','Dansk','Vital komponent');
INSERT INTO international VALUES (41,'WebGUI','Dansk','DU forsøger at fjerne en VITAL system komponent. Hvis du fik lov til dette, ville systemet ikke virke mere …..');
INSERT INTO international VALUES (42,'WebGUI','Dansk','Venligst bekræft');
INSERT INTO international VALUES (43,'WebGUI','Dansk','Er du sikker på du vil slette dette indhold?');
INSERT INTO international VALUES (44,'WebGUI','Dansk','Ja, jeg er sikker!');
INSERT INTO international VALUES (45,'WebGUI','Dansk','Nej, jeg lavede en fejl');
INSERT INTO international VALUES (46,'WebGUI','Dansk','Min konto');
INSERT INTO international VALUES (47,'WebGUI','Dansk','Hjem');
INSERT INTO international VALUES (48,'WebGUI','Dansk','Hej');
INSERT INTO international VALUES (49,'WebGUI','Dansk','\"Klik <a href=\"\"^\\;?op=logout\"\">her</a> for at logge ud.\"');
INSERT INTO international VALUES (50,'WebGUI','Dansk','Brugernavn');
INSERT INTO international VALUES (51,'WebGUI','Dansk','Kodeord');
INSERT INTO international VALUES (52,'WebGUI','Dansk','Login');
INSERT INTO international VALUES (53,'WebGUI','Dansk','Print side');
INSERT INTO international VALUES (54,'WebGUI','Dansk','Opret konto');
INSERT INTO international VALUES (55,'WebGUI','Dansk','Kodeord (bekræft)');
INSERT INTO international VALUES (56,'WebGUI','Dansk','Email Adresse');
INSERT INTO international VALUES (57,'WebGUI','Dansk','Dette er kun nødvendigt hvis du bruger en funktion der kræver Email');
INSERT INTO international VALUES (58,'WebGUI','Dansk','Jeg har allerede en konto');
INSERT INTO international VALUES (59,'WebGUI','Dansk','Jeg har glemt mit kodeord (igen)');
INSERT INTO international VALUES (60,'WebGUI','Dansk','Er du sikker på du vil deaktivere din konto. Kontoen kan IKKE åbnes igen.');
INSERT INTO international VALUES (61,'WebGUI','Dansk','Opdater konto information');
INSERT INTO international VALUES (62,'WebGUI','Dansk','Gem');
INSERT INTO international VALUES (63,'WebGUI','Dansk','Slå administration til.');
INSERT INTO international VALUES (64,'WebGUI','Dansk','Log ud.');
INSERT INTO international VALUES (65,'WebGUI','Dansk','Venligst de-aktiver min konto permanent.');
INSERT INTO international VALUES (66,'WebGUI','Dansk','Log In');
INSERT INTO international VALUES (67,'WebGUI','Dansk','Opret ny konto');
INSERT INTO international VALUES (68,'WebGUI','Dansk','Konto informationen er ikke gyldig. Enten eksisterer kontoen ikke, eller også er brugernavn/kodeord forkert');
INSERT INTO international VALUES (69,'WebGUI','Dansk','Kontakt venligst systemadministratoren for yderligere hjælp!');
INSERT INTO international VALUES (70,'WebGUI','Dansk','Fejl');
INSERT INTO international VALUES (71,'WebGUI','Dansk','Genskab kodeord');
INSERT INTO international VALUES (72,'WebGUI','Dansk','Genskab  ');
INSERT INTO international VALUES (73,'WebGUI','Dansk','Log in.');
INSERT INTO international VALUES (74,'WebGUI','Dansk','Konto information.');
INSERT INTO international VALUES (75,'WebGUI','Dansk','Din konto information er sendt til den oplyste Email adresse');
INSERT INTO international VALUES (76,'WebGUI','Dansk','Email adressen er ikke registreret i systemet');
INSERT INTO international VALUES (77,'WebGUI','Dansk','Det brugernavn er desværre allerede brugt af en anden. Prøv evt. en af disse:');
INSERT INTO international VALUES (78,'WebGUI','Dansk','Du har indtastet to forskellige kodeord - prøv igen!');
INSERT INTO international VALUES (79,'WebGUI','Dansk','Kan ikke forbinde til LDAP server');
INSERT INTO international VALUES (80,'WebGUI','Dansk','Konto er nu oprettet!');
INSERT INTO international VALUES (81,'WebGUI','Dansk','Konto er nu opdateret.');
INSERT INTO international VALUES (82,'WebGUI','Dansk','Administrative funktioner');
INSERT INTO international VALUES (84,'WebGUI','Dansk','Gruppe navn');
INSERT INTO international VALUES (85,'WebGUI','Dansk','Beskrivelse');
INSERT INTO international VALUES (86,'WebGUI','Dansk','Er du sikker på du vil slette denne gruppe? - og dermed alle rettigheder der er knyttet hertil');
INSERT INTO international VALUES (87,'WebGUI','Dansk','Rediger gruppe');
INSERT INTO international VALUES (88,'WebGUI','Dansk','brugere i gruppe');
INSERT INTO international VALUES (89,'WebGUI','Dansk','Grupper');
INSERT INTO international VALUES (90,'WebGUI','Dansk','Tilføj gruppe');
INSERT INTO international VALUES (91,'WebGUI','Dansk','Forrige side');
INSERT INTO international VALUES (92,'WebGUI','Dansk','Næste side');
INSERT INTO international VALUES (93,'WebGUI','Dansk','Hjælp');
INSERT INTO international VALUES (94,'WebGUI','Dansk','Se også');
INSERT INTO international VALUES (95,'WebGUI','Dansk','Hjælpe indeks');
INSERT INTO international VALUES (96,'WebGUI','Dansk','Sorteret efter aktion');
INSERT INTO international VALUES (97,'WebGUI','Dansk','Sorteret efter objekt');
INSERT INTO international VALUES (98,'WebGUI','Dansk','Tilføj side');
INSERT INTO international VALUES (99,'WebGUI','Dansk','Titel');
INSERT INTO international VALUES (100,'WebGUI','Dansk','Meta Tags');
INSERT INTO international VALUES (101,'WebGUI','Dansk','Er du sikker på du vil slette denne side, og alt indhold derunder?');
INSERT INTO international VALUES (102,'WebGUI','Dansk','Rediger side');
INSERT INTO international VALUES (103,'WebGUI','Dansk','Side specifikationer');
INSERT INTO international VALUES (104,'WebGUI','Dansk','Side URL');
INSERT INTO international VALUES (105,'WebGUI','Dansk','Stil');
INSERT INTO international VALUES (106,'WebGUI','Dansk','Sæt kryds for at give denne stil til alle undersider');
INSERT INTO international VALUES (107,'WebGUI','Dansk','Rettigheder');
INSERT INTO international VALUES (108,'WebGUI','Dansk','Ejer');
INSERT INTO international VALUES (109,'WebGUI','Dansk','Ejer kan se?');
INSERT INTO international VALUES (110,'WebGUI','Dansk','Ejer kan redigere?');
INSERT INTO international VALUES (111,'WebGUI','Dansk','Gruppe');
INSERT INTO international VALUES (112,'WebGUI','Dansk','Gruppe kan se?');
INSERT INTO international VALUES (113,'WebGUI','Dansk','Gruppe kan redigere?');
INSERT INTO international VALUES (114,'WebGUI','Dansk','Alle kan se?');
INSERT INTO international VALUES (115,'WebGUI','Dansk','Alle kan redigere?');
INSERT INTO international VALUES (116,'WebGUI','Dansk','Sæt kryds for at give disse rettigheder til alle undersider');
INSERT INTO international VALUES (117,'WebGUI','Dansk','Rediger autorisations indstillinger');
INSERT INTO international VALUES (118,'WebGUI','Dansk','Anonym registrering');
INSERT INTO international VALUES (119,'WebGUI','Dansk','autorisations metode (default)');
INSERT INTO international VALUES (120,'WebGUI','Dansk','LDAP URL (default)');
INSERT INTO international VALUES (121,'WebGUI','Dansk','LDAP Identitet (default)');
INSERT INTO international VALUES (122,'WebGUI','Dansk','LDAP Identitets navn');
INSERT INTO international VALUES (123,'WebGUI','Dansk','LDAP kodeord');
INSERT INTO international VALUES (124,'WebGUI','Dansk','Rediger firma information');
INSERT INTO international VALUES (125,'WebGUI','Dansk','Firma/organisations navn');
INSERT INTO international VALUES (126,'WebGUI','Dansk','Firma/organisations Email');
INSERT INTO international VALUES (127,'WebGUI','Dansk','Firma/organisation URL');
INSERT INTO international VALUES (128,'WebGUI','Dansk','Rediger fil indstillinger');
INSERT INTO international VALUES (129,'WebGUI','Dansk','Sti til WebGUI Extras');
INSERT INTO international VALUES (130,'WebGUI','Dansk','Maksimal størrelse på vedhæftede filer');
INSERT INTO international VALUES (131,'WebGUI','Dansk','Web Attachment sti');
INSERT INTO international VALUES (132,'WebGUI','Dansk','Server Attachment sti');
INSERT INTO international VALUES (133,'WebGUI','Dansk','Rediger Mail indstillinger');
INSERT INTO international VALUES (134,'WebGUI','Dansk','Besked for genskab adgangskode');
INSERT INTO international VALUES (135,'WebGUI','Dansk','SMTP Server');
INSERT INTO international VALUES (138,'WebGUI','Dansk','Ja');
INSERT INTO international VALUES (139,'WebGUI','Dansk','Nej ');
INSERT INTO international VALUES (140,'WebGUI','Dansk','Rediger diverse indstillinger');
INSERT INTO international VALUES (141,'WebGUI','Dansk','Ikke fundet side');
INSERT INTO international VALUES (142,'WebGUI','Dansk','Session Timeout');
INSERT INTO international VALUES (143,'WebGUI','Dansk','administrer indstillinger');
INSERT INTO international VALUES (144,'WebGUI','Dansk','Vis statistik');
INSERT INTO international VALUES (145,'WebGUI','Dansk','WebGUI Build Version');
INSERT INTO international VALUES (146,'WebGUI','Dansk','Aktive sessioner');
INSERT INTO international VALUES (147,'WebGUI','Dansk','Sider');
INSERT INTO international VALUES (148,'WebGUI','Dansk','Wobjects');
INSERT INTO international VALUES (149,'WebGUI','Dansk','brugere i gruppe');
INSERT INTO international VALUES (151,'WebGUI','Dansk','Navn på stilart');
INSERT INTO international VALUES (152,'WebGUI','Dansk','Hoved');
INSERT INTO international VALUES (153,'WebGUI','Dansk','Fod');
INSERT INTO international VALUES (154,'WebGUI','Dansk','Stilart Sheet');
INSERT INTO international VALUES (155,'WebGUI','Dansk','\"Er du sikker på du vil slette denne stilart og overføre alle sider der bruger denne til \"\"Fail Safe\"\" stilarten ?\"');
INSERT INTO international VALUES (156,'WebGUI','Dansk','Rediger stilart');
INSERT INTO international VALUES (157,'WebGUI','Dansk','stilarter');
INSERT INTO international VALUES (158,'WebGUI','Dansk','Tilføj ny stilart');
INSERT INTO international VALUES (159,'WebGUI','Dansk','Meddelelses log');
INSERT INTO international VALUES (160,'WebGUI','Dansk','Dato oprettet');
INSERT INTO international VALUES (161,'WebGUI','Dansk','Oprettet af');
INSERT INTO international VALUES (162,'WebGUI','Dansk','Er du sikker på du vil tømme skraldespanden?');
INSERT INTO international VALUES (163,'WebGUI','Dansk','Tilføj bruger  ');
INSERT INTO international VALUES (164,'WebGUI','Dansk','Metode for autorisation');
INSERT INTO international VALUES (165,'WebGUI','Dansk','LDAP URL');
INSERT INTO international VALUES (166,'WebGUI','Dansk','Connect DN');
INSERT INTO international VALUES (167,'WebGUI','Dansk','Er du sikker på du vil slette denne bruger? (Du kan ikke fortryde)');
INSERT INTO international VALUES (168,'WebGUI','Dansk','Rediger bruger');
INSERT INTO international VALUES (169,'WebGUI','Dansk','Tilføj ny bruger');
INSERT INTO international VALUES (170,'WebGUI','Dansk','Søg');
INSERT INTO international VALUES (171,'WebGUI','Dansk','Avanceret redigering');
INSERT INTO international VALUES (174,'WebGUI','Dansk','Vis titel på siden?');
INSERT INTO international VALUES (175,'WebGUI','Dansk','Udfør makroer?');
INSERT INTO international VALUES (228,'WebGUI','Dansk','Rediger besked…');
INSERT INTO international VALUES (229,'WebGUI','Dansk','Emne');
INSERT INTO international VALUES (230,'WebGUI','Dansk','Besked  ');
INSERT INTO international VALUES (231,'WebGUI','Dansk','Oprettet ny besked …');
INSERT INTO international VALUES (232,'WebGUI','Dansk','Intet emne');
INSERT INTO international VALUES (233,'WebGUI','Dansk','(eom)');
INSERT INTO international VALUES (234,'WebGUI','Dansk','Oprettet svar …');
INSERT INTO international VALUES (237,'WebGUI','Dansk','Emne:');
INSERT INTO international VALUES (238,'WebGUI','Dansk','Forfatter:');
INSERT INTO international VALUES (239,'WebGUI','Dansk','Dato:');
INSERT INTO international VALUES (240,'WebGUI','Dansk','Besked ID:');
INSERT INTO international VALUES (244,'WebGUI','Dansk','Forfatter ');
INSERT INTO international VALUES (245,'WebGUI','Dansk','Dato');
INSERT INTO international VALUES (304,'WebGUI','Dansk','Sprog');
INSERT INTO international VALUES (306,'WebGUI','Dansk','Brugernavn binding');
INSERT INTO international VALUES (307,'WebGUI','Dansk','Brug standard meta tags?');
INSERT INTO international VALUES (308,'WebGUI','Dansk','Rediger profil indstillinger');
INSERT INTO international VALUES (309,'WebGUI','Dansk','Tillad rigtige navne?');
INSERT INTO international VALUES (310,'WebGUI','Dansk','Tillad ekstra kontakt information?');
INSERT INTO international VALUES (311,'WebGUI','Dansk','Tillad hjemme information?');
INSERT INTO international VALUES (312,'WebGUI','Dansk','Tillad arbejds information?');
INSERT INTO international VALUES (313,'WebGUI','Dansk','Tillad diverse information?');
INSERT INTO international VALUES (314,'WebGUI','Dansk','Fornavn');
INSERT INTO international VALUES (315,'WebGUI','Dansk','Mellemnavn');
INSERT INTO international VALUES (316,'WebGUI','Dansk','Efternavn');
INSERT INTO international VALUES (317,'WebGUI','Dansk','\"<a href=\"\"http://www.icq.com\"\">ICQ</a> UIN\"');
INSERT INTO international VALUES (318,'WebGUI','Dansk','\"<a href=\"\"http://www.aol.com/aim/homenew.adp\"\">AIM</a> Id\"');
INSERT INTO international VALUES (319,'WebGUI','Dansk','\"<a href=\"\"http://messenger.msn.com/\"\">MSN Messenger</a> Id\"');
INSERT INTO international VALUES (320,'WebGUI','Dansk','\"<a href=\"\"http://messenger.yahoo.com/\"\">Yahoo! Messenger</a> Id\"');
INSERT INTO international VALUES (321,'WebGUI','Dansk','Bil tlf.');
INSERT INTO international VALUES (322,'WebGUI','Dansk','OPS');
INSERT INTO international VALUES (323,'WebGUI','Dansk','Hjemme adresse');
INSERT INTO international VALUES (324,'WebGUI','Dansk','Hjemme by');
INSERT INTO international VALUES (325,'WebGUI','Dansk','Hjemme stat');
INSERT INTO international VALUES (326,'WebGUI','Dansk','Hjemme postnr.');
INSERT INTO international VALUES (327,'WebGUI','Dansk','Hjemme amt');
INSERT INTO international VALUES (328,'WebGUI','Dansk','Hjemme tlf.');
INSERT INTO international VALUES (329,'WebGUI','Dansk','Arbejds adresse');
INSERT INTO international VALUES (330,'WebGUI','Dansk','Arbejds by');
INSERT INTO international VALUES (331,'WebGUI','Dansk','Arbejds stat');
INSERT INTO international VALUES (332,'WebGUI','Dansk','Arbejds postnr.');
INSERT INTO international VALUES (333,'WebGUI','Dansk','Arbejds amt');
INSERT INTO international VALUES (334,'WebGUI','Dansk','Arbejds tlf.');
INSERT INTO international VALUES (335,'WebGUI','Dansk','M/K');
INSERT INTO international VALUES (336,'WebGUI','Dansk','Fødselsdag');
INSERT INTO international VALUES (337,'WebGUI','Dansk','Hjemmeside URL');
INSERT INTO international VALUES (338,'WebGUI','Dansk','Rediger profil  ');
INSERT INTO international VALUES (339,'WebGUI','Dansk','Mand');
INSERT INTO international VALUES (340,'WebGUI','Dansk','Kvinde');
INSERT INTO international VALUES (341,'WebGUI','Dansk','Rediger profil');
INSERT INTO international VALUES (342,'WebGUI','Dansk','Rediger konto information');
INSERT INTO international VALUES (343,'WebGUI','Dansk','Vis profil');
INSERT INTO international VALUES (345,'WebGUI','Dansk','Ikke medlem');
INSERT INTO international VALUES (346,'WebGUI','Dansk','Denne bruger findes ikke længere på dette system. Jeg har ikke yderligere oplysninger om denne bruger');
INSERT INTO international VALUES (347,'WebGUI','Dansk','Vis profil for');
INSERT INTO international VALUES (348,'WebGUI','Dansk','Navn  ');
INSERT INTO international VALUES (349,'WebGUI','Dansk','Seneste version');
INSERT INTO international VALUES (350,'WebGUI','Dansk','Gennemført');
INSERT INTO international VALUES (351,'WebGUI','Dansk','Message Log Entry');
INSERT INTO international VALUES (352,'WebGUI','Dansk','Dato');
INSERT INTO international VALUES (353,'WebGUI','Dansk','Du har ingen meddelelser i øjeblikket');
INSERT INTO international VALUES (354,'WebGUI','Dansk','Vis meddelelses log');
INSERT INTO international VALUES (355,'WebGUI','Dansk','Standard');
INSERT INTO international VALUES (356,'WebGUI','Dansk','Template');
INSERT INTO international VALUES (357,'WebGUI','Dansk','Nyheder');
INSERT INTO international VALUES (358,'WebGUI','Dansk','Venstre kolonne');
INSERT INTO international VALUES (359,'WebGUI','Dansk','Højre kolonne');
INSERT INTO international VALUES (360,'WebGUI','Dansk','En over tre');
INSERT INTO international VALUES (361,'WebGUI','Dansk','Tre over en');
INSERT INTO international VALUES (362,'WebGUI','Dansk','Side ved side');
INSERT INTO international VALUES (363,'WebGUI','Dansk','Template position');
INSERT INTO international VALUES (364,'WebGUI','Dansk','Søg');
INSERT INTO international VALUES (365,'WebGUI','Dansk','Søge resultater …');
INSERT INTO international VALUES (366,'WebGUI','Dansk','Jeg fandt desværre ingen sider med de(t) søgeord');
INSERT INTO international VALUES (367,'WebGUI','Dansk','Udløber efter');
INSERT INTO international VALUES (368,'WebGUI','Dansk','Tilføj en ny gruppen til denne bruger.');
INSERT INTO international VALUES (369,'WebGUI','Dansk','Udløbs dato');
INSERT INTO international VALUES (370,'WebGUI','Dansk','Rediger gruppering');
INSERT INTO international VALUES (371,'WebGUI','Dansk','Tilføj gruppering');
INSERT INTO international VALUES (372,'WebGUI','Dansk','Rediger brugers gruppe');
INSERT INTO international VALUES (373,'WebGUI','Dansk','<b>Advarsel</b> Når du retter ovenstående liste, vil du nulstille all udløbsinformation til den nye standard.');
INSERT INTO international VALUES (374,'WebGUI','Dansk','administrer packages');
INSERT INTO international VALUES (375,'WebGUI','Dansk','Vælg package der skal tages i brug');
INSERT INTO international VALUES (376,'WebGUI','Dansk','Package');
INSERT INTO international VALUES (377,'WebGUI','Dansk','\"Der er endnu ikke defineret nogle \"\"Packages\"\".\"');
INSERT INTO international VALUES (378,'WebGUI','Dansk','Bruger ID');
INSERT INTO international VALUES (379,'WebGUI','Dansk','Gruppe ID');
INSERT INTO international VALUES (380,'WebGUI','Dansk','Stilart ID');
INSERT INTO international VALUES (381,'WebGUI','Dansk','WebGUI modtog en fejlformateret besked og kan ikke fortsætte - dette skyldes typisk eb speciel karakter. Prøv evt. at trykke tilbage og prøv igen.');
INSERT INTO international VALUES (383,'WebGUI','Dansk','Navn');
INSERT INTO international VALUES (384,'WebGUI','Dansk','Fil  ');
INSERT INTO international VALUES (385,'WebGUI','Dansk','Parametre');
INSERT INTO international VALUES (386,'WebGUI','Dansk','Rediger billede');
INSERT INTO international VALUES (387,'WebGUI','Dansk','Tilføjet af');
INSERT INTO international VALUES (388,'WebGUI','Dansk','Tilføjet dato');
INSERT INTO international VALUES (389,'WebGUI','Dansk','Billede ID');
INSERT INTO international VALUES (390,'WebGUI','Dansk','Viser billede …');
INSERT INTO international VALUES (391,'WebGUI','Dansk','Sletter vedhæftet fil');
INSERT INTO international VALUES (392,'WebGUI','Dansk','Er du sikker på du vil slette dette billede');
INSERT INTO international VALUES (393,'WebGUI','Dansk','administrer billeder');
INSERT INTO international VALUES (394,'WebGUI','Dansk','administrer billeder.');
INSERT INTO international VALUES (395,'WebGUI','Dansk','Tilføj nyt billede');
INSERT INTO international VALUES (396,'WebGUI','Dansk','Vis billede');
INSERT INTO international VALUES (397,'WebGUI','Dansk','Tilbage til billede oversigt');
INSERT INTO international VALUES (398,'WebGUI','Dansk','Dokument type deklarering');
INSERT INTO international VALUES (399,'WebGUI','Dansk','Valider denne side.');
INSERT INTO international VALUES (400,'WebGUI','Dansk','Forhindre Proxy Caching');
INSERT INTO international VALUES (401,'WebGUI','Dansk','Er du sikker på du vil slette denne besked, og alle under beskeder i tråden?');
INSERT INTO international VALUES (402,'WebGUI','Dansk','Beskeden findes ikke');
INSERT INTO international VALUES (403,'WebGUI','Dansk','Det foretrækker jeg ikke at oplyse');
INSERT INTO international VALUES (404,'WebGUI','Dansk','Første side');
INSERT INTO international VALUES (405,'WebGUI','Dansk','Sidste side');
INSERT INTO international VALUES (406,'WebGUI','Dansk','Miniature størrelse');
INSERT INTO international VALUES (407,'WebGUI','Dansk','Klik her for at registrere');
INSERT INTO international VALUES (408,'WebGUI','Dansk','administrer rod');
INSERT INTO international VALUES (409,'WebGUI','Dansk','Tilføj ny rod');
INSERT INTO international VALUES (410,'WebGUI','Dansk','Administrer rod');
INSERT INTO international VALUES (411,'WebGUI','Dansk','Menu titel');
INSERT INTO international VALUES (412,'WebGUI','Dansk','Synopsis');
INSERT INTO international VALUES (413,'WebGUI','Dansk','Ved kritisk fejl');
INSERT INTO international VALUES (414,'WebGUI','Dansk','Vis debug information');
INSERT INTO international VALUES (415,'WebGUI','Dansk','Vis brugervenlig besked');
INSERT INTO international VALUES (416,'WebGUI','Dansk','<h1>Problem med forespørgsel</h1>Oops, jeg har lidt problemer med din forespørgsel. Tryk tilbage og prøv igen. Hvis problemet fortsætte vil jeg være glad hvis du vil kontakte os og fortælle hvad du prøver, på forhånd tak.');
INSERT INTO international VALUES (417,'WebGUI','Dansk','<h1>Sikkerhedsbrud</h1>Du forsøgte at få adgang med en Wobject der ikke hører til her. Jeg har rapporteret dit forsøg.');
INSERT INTO international VALUES (418,'WebGUI','Dansk','Filter Contributed HTML');
INSERT INTO international VALUES (419,'WebGUI','Dansk','Fjern alle tags');
INSERT INTO international VALUES (420,'WebGUI','Dansk','Lad det være');
INSERT INTO international VALUES (421,'WebGUI','Dansk','Fjerne alt bortset fra basal formatering');
INSERT INTO international VALUES (422,'WebGUI','Dansk','<h1>Login mislykkedes</h1>Dine informationer stemmer ikke med mine oplysninger');
INSERT INTO international VALUES (423,'WebGUI','Dansk','Vis aktive sessioner');
INSERT INTO international VALUES (424,'WebGUI','Dansk','Vis login historik');
INSERT INTO international VALUES (425,'WebGUI','Dansk','Aktive sessioner');
INSERT INTO international VALUES (426,'WebGUI','Dansk','Login historik');
INSERT INTO international VALUES (427,'WebGUI','Dansk','stilarter');
INSERT INTO international VALUES (428,'WebGUI','Dansk','Bruger (ID)');
INSERT INTO international VALUES (429,'WebGUI','Dansk','Login tid');
INSERT INTO international VALUES (430,'WebGUI','Dansk','Sidste side vist');
INSERT INTO international VALUES (431,'WebGUI','Dansk','IP Adresse');
INSERT INTO international VALUES (432,'WebGUI','Dansk','Udløber efter');
INSERT INTO international VALUES (433,'WebGUI','Dansk','Bruger agent:');
INSERT INTO international VALUES (434,'WebGUI','Dansk','Status');
INSERT INTO international VALUES (435,'WebGUI','Dansk','Session Signatur');
INSERT INTO international VALUES (436,'WebGUI','Dansk','Afbryd Session');
INSERT INTO international VALUES (437,'WebGUI','Dansk','Statistik');
INSERT INTO international VALUES (438,'WebGUI','Dansk','Dit navn');
INSERT INTO international VALUES (439,'WebGUI','Dansk','Personlig information');
INSERT INTO international VALUES (440,'WebGUI','Dansk','Kontakt information');
INSERT INTO international VALUES (441,'WebGUI','Dansk','Email  til OPS Gateway');
INSERT INTO international VALUES (442,'WebGUI','Dansk','Arbejdsinformation');
INSERT INTO international VALUES (443,'WebGUI','Dansk','Hjemme information');
INSERT INTO international VALUES (444,'WebGUI','Dansk','Demografisk information');
INSERT INTO international VALUES (445,'WebGUI','Dansk','Præferencer');
INSERT INTO international VALUES (446,'WebGUI','Dansk','Arbejds hjemmeside');
INSERT INTO international VALUES (447,'WebGUI','Dansk','Administrer træ struktur');
INSERT INTO international VALUES (448,'WebGUI','Dansk','Træ struktur');
INSERT INTO international VALUES (449,'WebGUI','Dansk','Diverse information');
INSERT INTO international VALUES (450,'WebGUI','Dansk','Arbejdsnavn (Firma navn)');
INSERT INTO international VALUES (451,'WebGUI','Dansk','er påkrævet');
INSERT INTO international VALUES (452,'WebGUI','Dansk','Vent venligst …');
INSERT INTO international VALUES (453,'WebGUI','Dansk','Dato oprettet');
INSERT INTO international VALUES (454,'WebGUI','Dansk','Sidste opdateret');
INSERT INTO international VALUES (455,'WebGUI','Dansk','Rediger bruger profil');
INSERT INTO international VALUES (456,'WebGUI','Dansk','Tilbage til bruger liste');
INSERT INTO international VALUES (457,'WebGUI','Dansk','Rediger denne brugers konto');
INSERT INTO international VALUES (458,'WebGUI','Dansk','Rediger denne bruger gruppe');
INSERT INTO international VALUES (459,'WebGUI','Dansk','Rediger denne brugers profil');
INSERT INTO international VALUES (460,'WebGUI','Dansk','Tidsforskel');
INSERT INTO international VALUES (461,'WebGUI','Dansk','Dato format');
INSERT INTO international VALUES (462,'WebGUI','Dansk','Tids format');
INSERT INTO international VALUES (463,'WebGUI','Dansk','Tekst Area Rows');
INSERT INTO international VALUES (464,'WebGUI','Dansk','Tekst Area Columns');
INSERT INTO international VALUES (465,'WebGUI','Dansk','Tekst Box Size');
INSERT INTO international VALUES (466,'WebGUI','Dansk','Er du sikker på du vil slette denne kategori og flytte indholdet over i diverse kategorien?');
INSERT INTO international VALUES (467,'WebGUI','Dansk','Er du sikker på du vil slette dette felt, og alle relaterede brugerdata?');
INSERT INTO international VALUES (469,'WebGUI','Dansk','Id');
INSERT INTO international VALUES (470,'WebGUI','Dansk','Navn');
INSERT INTO international VALUES (472,'WebGUI','Dansk','Label');
INSERT INTO international VALUES (473,'WebGUI','Dansk','Synlig?');
INSERT INTO international VALUES (474,'WebGUI','Dansk','Påkrævet?');
INSERT INTO international VALUES (475,'WebGUI','Dansk','Tekst');
INSERT INTO international VALUES (476,'WebGUI','Dansk','Tekst område');
INSERT INTO international VALUES (477,'WebGUI','Dansk','HTML område');
INSERT INTO international VALUES (478,'WebGUI','Dansk','URL');
INSERT INTO international VALUES (479,'WebGUI','Dansk','Dato');
INSERT INTO international VALUES (480,'WebGUI','Dansk','Email Adresse');
INSERT INTO international VALUES (481,'WebGUI','Dansk','Tlf. nr.');
INSERT INTO international VALUES (482,'WebGUI','Dansk','Heltal');
INSERT INTO international VALUES (483,'WebGUI','Dansk','Ja eller Nej');
INSERT INTO international VALUES (484,'WebGUI','Dansk','Vælg fra list');
INSERT INTO international VALUES (485,'WebGUI','Dansk','Logisk (Checkboks)');
INSERT INTO international VALUES (486,'WebGUI','Dansk','Data type');
INSERT INTO international VALUES (487,'WebGUI','Dansk','Mulige værdier');
INSERT INTO international VALUES (488,'WebGUI','Dansk','Standard værdi');
INSERT INTO international VALUES (489,'WebGUI','Dansk','Profil kategori');
INSERT INTO international VALUES (490,'WebGUI','Dansk','Tilføj en profil kategori');
INSERT INTO international VALUES (491,'WebGUI','Dansk','Tilføj et profil felt');
INSERT INTO international VALUES (492,'WebGUI','Dansk','Liste over profil felter');
INSERT INTO international VALUES (493,'WebGUI','Dansk','Tilbage til Site');
INSERT INTO international VALUES (494,'WebGUI','Dansk','Real Objects Edit-On Pro');
INSERT INTO international VALUES (495,'WebGUI','Dansk','Indbygget editor');
INSERT INTO international VALUES (496,'WebGUI','Dansk','Hvilken editor bruges');
INSERT INTO international VALUES (497,'WebGUI','Dansk','Start dato');
INSERT INTO international VALUES (498,'WebGUI','Dansk','Slut dato');
INSERT INTO international VALUES (499,'WebGUI','Dansk','Wobject ID');
INSERT INTO international VALUES (518,'WebGUI','English','Inbox Notifications');
INSERT INTO international VALUES (519,'WebGUI','English','I would not like to be notified.');
INSERT INTO international VALUES (520,'WebGUI','English','I would like to be notified via email.');
INSERT INTO international VALUES (521,'WebGUI','English','I would like to be notified via email to pager.');
INSERT INTO international VALUES (522,'WebGUI','English','I would like to be notified via ICQ.');
INSERT INTO international VALUES (523,'WebGUI','English','Notification');
INSERT INTO international VALUES (524,'WebGUI','English','Add edit stamp to posts?');
INSERT INTO international VALUES (525,'WebGUI','English','Edit Content Settings');
INSERT INTO international VALUES (526,'WebGUI','English','Remove only JavaScript.');
INSERT INTO international VALUES (528,'WebGUI','English','Template Name');
INSERT INTO international VALUES (529,'WebGUI','English','results');
INSERT INTO international VALUES (530,'WebGUI','English','with <b>all</b> the words');
INSERT INTO international VALUES (531,'WebGUI','English','with the <b>exact phrase</b>');
INSERT INTO international VALUES (532,'WebGUI','English','with <b>at least one</b> of the words');
INSERT INTO international VALUES (533,'WebGUI','English','<b>without</b> the words');
INSERT INTO international VALUES (535,'WebGUI','English','Group To Alert On New User');
INSERT INTO international VALUES (534,'WebGUI','English','Alert on new user?');
INSERT INTO international VALUES (536,'WebGUI','English','A new user named ^@; has joined the site.');

--
-- Table structure for table 'messageLog'
--

CREATE TABLE messageLog (
  messageLogId int(11) NOT NULL default '0',
  userId int(11) NOT NULL default '0',
  message text,
  url text,
  dateOfEntry int(11) default NULL,
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
  PRIMARY KEY  (pageId)
) TYPE=MyISAM;

--
-- Dumping data for table 'page'
--


INSERT INTO page VALUES (1,0,'Home',-3,3,1,1,1,1,0,1,0,0,'','home',1,'Home',NULL,1);
INSERT INTO page VALUES (4,0,'Page Not Found',-3,3,1,1,1,1,0,1,0,21,'','page_not_found',0,'Page Not Found',NULL,1);
INSERT INTO page VALUES (3,0,'Trash',5,3,1,1,3,1,1,0,0,22,'','trash',0,'Trash',NULL,1);
INSERT INTO page VALUES (2,0,'Clipboard',4,3,1,1,4,1,1,0,0,23,'','clipboard',0,'Clipboard',NULL,1);
INSERT INTO page VALUES (5,0,'Packages',1,3,0,0,6,1,1,0,0,24,'','packages',0,'Packages',NULL,1);

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


INSERT INTO settings VALUES ('attachmentDirectoryWeb','/uploads');
INSERT INTO settings VALUES ('maxAttachmentSize','300');
INSERT INTO settings VALUES ('lib','/extras');
INSERT INTO settings VALUES ('sessionTimeout','28000');
INSERT INTO settings VALUES ('attachmentDirectoryLocal','/data/WebGUI/www/uploads');
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
INSERT INTO settings VALUES ('onCriticalError','friendly');
INSERT INTO settings VALUES ('filterContributedHTML','most');
INSERT INTO settings VALUES ('textAreaRows','5');
INSERT INTO settings VALUES ('textAreaCols','50');
INSERT INTO settings VALUES ('textBoxSize','30');
INSERT INTO settings VALUES ('richEditor','built-in');
INSERT INTO settings VALUES ('addEditStampToPosts','1');
INSERT INTO settings VALUES ('defaultPage','1');
INSERT INTO settings VALUES ('onNewUserAlertGroup','3');
INSERT INTO settings VALUES ('alertOnNewUser','0');

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


INSERT INTO userProfileData VALUES (1,'language','English');
INSERT INTO userProfileData VALUES (3,'language','English');

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
INSERT INTO userProfileField VALUES ('language','WebGUI::International::get(304,\"WebGUI\");',1,0,'select','WebGUI::International::getLanguages()','[\'English\']',1,4,1);
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
INSERT INTO userProfileField VALUES ('timeOffset','WebGUI::International::get(460,\"WebGUI\");',1,0,'text',NULL,'\'0\'',2,4,1);
INSERT INTO userProfileField VALUES ('dateFormat','WebGUI::International::get(461,\"WebGUI\");',1,0,'select','{\r\n \'%M/%D/%y\'=>WebGUI::DateTime::epochToHuman(\"\",\"%M/%D/%y\"),\r\n \'%y-%m-%d\'=>WebGUI::DateTime::epochToHuman(\"\",\"%y-%m-%d\"),\r\n \'%D-%c-%y\'=>WebGUI::DateTime::epochToHuman(\"\",\"%D-%c-%y\"),\r\n \'%c %D, %y\'=>WebGUI::DateTime::epochToHuman(\"\",\"%c %D, %y\")\r\n}\r\n','[\'%M/%D/%y\']',3,4,1);
INSERT INTO userProfileField VALUES ('timeFormat','WebGUI::International::get(462,\"WebGUI\");',1,0,'select','{\r\n \'%H:%n %p\'=>WebGUI::DateTime::epochToHuman(\"\",\"%H:%n %p\"),\r\n \'%H:%n:%s %p\'=>WebGUI::DateTime::epochToHuman(\"\",\"%H:%n:%s %p\"),\r\n \'%j:%n\'=>WebGUI::DateTime::epochToHuman(\"\",\"%j:%n\"),\r\n \'%j:%n:%s\'=>WebGUI::DateTime::epochToHuman(\"\",\"%j:%n:%s\")\r\n}\r\n','[\'%H:%n %p\']',4,4,1);
INSERT INTO userProfileField VALUES ('discussionLayout','WebGUI::International::get(509)',1,0,'select','{\r\n  threaded=>WebGUI::International::get(511),\r\n  flat=>WebGUI::International::get(510)\r\n}','[\'threaded\']',5,4,0);
INSERT INTO userProfileField VALUES ('INBOXNotifications','WebGUI::International::get(518)',1,0,'select','{ \r\n  none=>WebGUI::International::get(519),\r\n email=>WebGUI::International::get(520),\r\n  emailToPager=>WebGUI::International::get(521),\r\n  icq=>WebGUI::International::get(522)\r\n}','[\'email\']',6,4,0);

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
  PRIMARY KEY  (userId)
) TYPE=MyISAM;

--
-- Dumping data for table 'users'
--


INSERT INTO users VALUES (1,'Visitor','No Login','WebGUI',NULL,NULL,1019867418,1019867418);
INSERT INTO users VALUES (3,'Admin','RvlMjeFPs2aAhQdo/xt/Kg','WebGUI','','',1019867418,1019935552);

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


INSERT INTO webguiVersion VALUES ('3.10.1','intitial install',unix_timestamp());

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
  PRIMARY KEY  (wobjectId)
) TYPE=MyISAM;

--
-- Dumping data for table 'wobject'
--


INSERT INTO wobject VALUES (-1,4,'SiteMap',0,'Page Not Found',1,'The page you were looking for could not be found on this system. Perhaps it has been deleted or renamed. The following list is a site map of this site. If you don\'t find what you\'re looking for on the site map, you can always start from the <a href=\"^/;\">Home Page</a>.',1,1001744792,3,1016077239,3,0,1001744792,1336444487);


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

