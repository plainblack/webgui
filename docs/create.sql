# MySQL dump 8.13
#
# Host: localhost    Database: WebGUI
#--------------------------------------------------------
# Server version	3.23.36

#
# Table structure for table 'Article'
#

CREATE TABLE Article (
  widgetId int(11) NOT NULL default '0',
  startDate int(11) default NULL,
  endDate int(11) default NULL,
  body mediumtext,
  image varchar(255) default NULL,
  linkTitle varchar(255) default NULL,
  linkURL text,
  attachment varchar(255) default NULL,
  convertCarriageReturns int(11) NOT NULL default '0',
  alignImage varchar(30) NOT NULL default 'left',
  PRIMARY KEY  (widgetId)
) TYPE=MyISAM;

#
# Dumping data for table 'Article'
#


#
# Table structure for table 'DownloadManager'
#

CREATE TABLE DownloadManager (
  widgetId int(11) NOT NULL default '0',
  paginateAfter int(11) NOT NULL default '50',
  PRIMARY KEY  (widgetId)
) TYPE=MyISAM;

#
# Dumping data for table 'DownloadManager'
#


#
# Table structure for table 'DownloadManager_file'
#

CREATE TABLE DownloadManager_file (
  downloadId int(11) NOT NULL default '0',
  widgetId int(11) NOT NULL default '0',
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

#
# Dumping data for table 'DownloadManager_file'
#


#
# Table structure for table 'EventsCalendar'
#

CREATE TABLE EventsCalendar (
  widgetId int(11) NOT NULL default '0',
  calendarLayout varchar(30) NOT NULL default 'list',
  paginateAfter int(11) NOT NULL default '50',
  PRIMARY KEY  (widgetId)
) TYPE=MyISAM;

#
# Dumping data for table 'EventsCalendar'
#


#
# Table structure for table 'EventsCalendar_event'
#

CREATE TABLE EventsCalendar_event (
  eventId int(11) NOT NULL default '1',
  widgetId int(11) default NULL,
  name varchar(255) default NULL,
  description text,
  startDate int(11) default NULL,
  endDate int(11) default NULL,
  recurringEventId int(11) NOT NULL default '0',
  PRIMARY KEY  (eventId)
) TYPE=MyISAM;

#
# Dumping data for table 'EventsCalendar_event'
#


#
# Table structure for table 'ExtraColumn'
#

CREATE TABLE ExtraColumn (
  widgetId int(11) NOT NULL default '0',
  spacer int(11) default NULL,
  width int(11) default NULL,
  class varchar(50) default NULL,
  PRIMARY KEY  (widgetId)
) TYPE=MyISAM;

#
# Dumping data for table 'ExtraColumn'
#


#
# Table structure for table 'FAQ'
#

CREATE TABLE FAQ (
  widgetId int(11) NOT NULL default '0',
  PRIMARY KEY  (widgetId)
) TYPE=MyISAM;

#
# Dumping data for table 'FAQ'
#


#
# Table structure for table 'FAQ_question'
#

CREATE TABLE FAQ_question (
  widgetId int(11) default NULL,
  questionId int(11) NOT NULL default '0',
  question text,
  answer text,
  sequenceNumber int(11) NOT NULL default '0',
  PRIMARY KEY  (questionId)
) TYPE=MyISAM;

#
# Dumping data for table 'FAQ_question'
#


#
# Table structure for table 'Item'
#

CREATE TABLE Item (
  widgetId int(11) NOT NULL default '0',
  description text,
  linkURL text,
  attachment varchar(255) default NULL,
  PRIMARY KEY  (widgetId)
) TYPE=MyISAM;

#
# Dumping data for table 'Item'
#


#
# Table structure for table 'LinkList'
#

CREATE TABLE LinkList (
  widgetId int(11) NOT NULL default '0',
  indent int(11) NOT NULL default '0',
  lineSpacing int(11) NOT NULL default '1',
  bullet varchar(255) NOT NULL default '&middot;',
  PRIMARY KEY  (widgetId)
) TYPE=MyISAM;

#
# Dumping data for table 'LinkList'
#


#
# Table structure for table 'LinkList_link'
#

CREATE TABLE LinkList_link (
  widgetId int(11) default NULL,
  linkId int(11) NOT NULL default '0',
  name varchar(128) default NULL,
  url text,
  description text,
  sequenceNumber int(11) NOT NULL default '0',
  newWindow int(11) NOT NULL default '0',
  PRIMARY KEY  (linkId)
) TYPE=MyISAM;

#
# Dumping data for table 'LinkList_link'
#


#
# Table structure for table 'MessageBoard'
#

CREATE TABLE MessageBoard (
  widgetId int(11) NOT NULL default '0',
  groupToPost int(11) default NULL,
  messagesPerPage int(11) NOT NULL default '50',
  editTimeout int(11) default NULL,
  groupToModerate int(11) NOT NULL default '4',
  PRIMARY KEY  (widgetId)
) TYPE=MyISAM;

#
# Dumping data for table 'MessageBoard'
#


#
# Table structure for table 'Poll'
#

CREATE TABLE Poll (
  widgetId int(11) NOT NULL default '0',
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
  PRIMARY KEY  (widgetId)
) TYPE=MyISAM;

#
# Dumping data for table 'Poll'
#


#
# Table structure for table 'Poll_answer'
#

CREATE TABLE Poll_answer (
  widgetId int(11) NOT NULL default '0',
  answer char(3) default NULL,
  userId int(11) default NULL,
  ipAddress varchar(50) default NULL
) TYPE=MyISAM;

#
# Dumping data for table 'Poll_answer'
#


#
# Table structure for table 'SQLReport'
#

CREATE TABLE SQLReport (
  widgetId int(11) NOT NULL default '0',
  template text,
  dbQuery text,
  DSN varchar(255) default NULL,
  username varchar(255) default NULL,
  identifier varchar(255) default NULL,
  convertCarriageReturns int(11) NOT NULL default '0',
  paginateAfter int(11) NOT NULL default '50',
  PRIMARY KEY  (widgetId)
) TYPE=MyISAM;

#
# Dumping data for table 'SQLReport'
#


#
# Table structure for table 'SiteMap'
#

CREATE TABLE SiteMap (
  widgetId int(11) NOT NULL default '0',
  startAtThisLevel int(11) default NULL,
  depth int(11) NOT NULL default '0',
  indent int(11) NOT NULL default '5',
  bullet varchar(30) NOT NULL default '&middot',
  lineSpacing int(11) NOT NULL default '1',
  PRIMARY KEY  (widgetId)
) TYPE=MyISAM;

#
# Dumping data for table 'SiteMap'
#

INSERT INTO SiteMap VALUES (-1,0,0,5,'·',1);

#
# Table structure for table 'SyndicatedContent'
#

CREATE TABLE SyndicatedContent (
  widgetId int(11) NOT NULL default '0',
  rssUrl text,
  content text,
  lastFetched int(11) default NULL,
  PRIMARY KEY  (widgetId)
) TYPE=MyISAM;

#
# Dumping data for table 'SyndicatedContent'
#


#
# Table structure for table 'UserSubmission'
#

CREATE TABLE UserSubmission (
  widgetId int(11) NOT NULL default '0',
  groupToContribute int(11) default NULL,
  submissionsPerPage int(11) NOT NULL default '50',
  defaultStatus varchar(30) default 'Approved',
  groupToApprove int(11) NOT NULL default '4',
  PRIMARY KEY  (widgetId)
) TYPE=MyISAM;

#
# Dumping data for table 'UserSubmission'
#


#
# Table structure for table 'UserSubmission_submission'
#

CREATE TABLE UserSubmission_submission (
  widgetId int(11) default NULL,
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
  PRIMARY KEY  (submissionId)
) TYPE=MyISAM;

#
# Dumping data for table 'UserSubmission_submission'
#


#
# Table structure for table 'discussion'
#

CREATE TABLE discussion (
  messageId int(11) NOT NULL default '0',
  rid int(11) default NULL,
  widgetId int(11) default NULL,
  pid int(11) default NULL,
  userId int(11) default NULL,
  username varchar(30) default NULL,
  subject varchar(255) default NULL,
  message text,
  dateOfPost int(11) default NULL,
  subId int(11) default NULL,
  PRIMARY KEY  (messageId)
) TYPE=MyISAM;

#
# Dumping data for table 'discussion'
#


#
# Table structure for table 'groupings'
#

CREATE TABLE groupings (
  groupId int(11) NOT NULL default '0',
  userId int(11) NOT NULL default '0',
  expireDate int(11) NOT NULL default '2114402400',
  PRIMARY KEY  (groupId,userId)
) TYPE=MyISAM;

#
# Dumping data for table 'groupings'
#

INSERT INTO groupings VALUES (1,1,2114402400);
INSERT INTO groupings VALUES (5,3,2114402400);
INSERT INTO groupings VALUES (4,3,2114402400);
INSERT INTO groupings VALUES (3,3,2114402400);
INSERT INTO groupings VALUES (2,3,2114402400);
INSERT INTO groupings VALUES (6,3,2114402400);

#
# Table structure for table 'groups'
#

CREATE TABLE groups (
  groupId int(11) NOT NULL default '0',
  groupName varchar(30) default NULL,
  description varchar(255) default NULL,
  expireAfter int(11) NOT NULL default '314496000',
  PRIMARY KEY  (groupId)
) TYPE=MyISAM;

#
# Dumping data for table 'groups'
#

INSERT INTO groups VALUES (1,'Visitors','This is the public group that has no privileges.',314496000);
INSERT INTO groups VALUES (2,'Registered Users','All registered users belong to this group automatically. There are no associated privileges other than that the user has an account and is logged in.',314496000);
INSERT INTO groups VALUES (3,'Admins','Anyone who belongs to this group has privileges to do anything and everything.',314496000);
INSERT INTO groups VALUES (4,'Content Managers','Users that have privileges to edit content on this site. The user still needs to be added to a group that has editing privileges on specific pages.',314496000);
INSERT INTO groups VALUES (5,'Style Managers','Users that have privileges to edit styles for this site. These privileges do not allow the user to assign privileges to a page, just define them to be used.',314496000);
INSERT INTO groups VALUES (6,'Package Managers','Users that have privileges to add, edit, and delete packages of widgets and pages to deploy.',314496000);
INSERT INTO groups VALUES (7,'Reserved','',314496000);
INSERT INTO groups VALUES (8,'Reserved','',314496000);
INSERT INTO groups VALUES (9,'Reserved','',314496000);
INSERT INTO groups VALUES (10,'Reserved','',314496000);
INSERT INTO groups VALUES (11,'Reserved','',314496000);
INSERT INTO groups VALUES (12,'Reserved','',314496000);
INSERT INTO groups VALUES (13,'Reserved','',314496000);
INSERT INTO groups VALUES (14,'Reserved','',314496000);
INSERT INTO groups VALUES (15,'Reserved','',314496000);
INSERT INTO groups VALUES (16,'Reserved','',314496000);
INSERT INTO groups VALUES (17,'Reserved','',314496000);
INSERT INTO groups VALUES (18,'Reserved','',314496000);
INSERT INTO groups VALUES (19,'Reserved','',314496000);
INSERT INTO groups VALUES (20,'Reserved','',314496000);
INSERT INTO groups VALUES (21,'Reserved','',314496000);
INSERT INTO groups VALUES (22,'Reserved','',314496000);
INSERT INTO groups VALUES (23,'Reserved','',314496000);
INSERT INTO groups VALUES (24,'Reserved','',314496000);
INSERT INTO groups VALUES (25,'Reserved','',314496000);

#
# Table structure for table 'help'
#

CREATE TABLE help (
  helpId int(11) NOT NULL default '0',
  namespace varchar(30) NOT NULL default 'WebGUI',
  language varchar(30) NOT NULL default 'English',
  action varchar(30) default NULL,
  object varchar(30) default NULL,
  body text,
  seeAlso varchar(50) NOT NULL default '0',
  PRIMARY KEY  (helpId,namespace,language),
  KEY helpId (helpId,language)
) TYPE=MyISAM;

#
# Dumping data for table 'help'
#

INSERT INTO help VALUES (1,'WebGUI','English','Add/Edit','Page','Think of pages as containers for content. For instance, if you want to write a letter to the editor of your favorite magazine you\'d get out a notepad (or open a word processor) and start filling it with your thoughts. The same is true with WebGUI. Create a page, then add your content to the page.\r\n<p>\r\n<b>Title</b><br>\r\nThe title of the page is what your users will use to navigate through the site. Titles should be descriptive, but not very long.\r\n<p>\r\n<b>Page URL</b><br>\r\nWhen you create a page a URL for the page is generated based on the page title. If you are unhappy with the URL that was chosen, you can change it here.\r\n<p>\r\n<b>Template</b><br>\r\nBy default, WebGUI has one big content area to place widgets. However, by specifying a template other than the default you can sub-divide the content area into several sections.\r\n\r\n<p>\r\n<b>Meta Tags</b><br>\r\nMeta tags are used by some search engines to associate key words to a particular page. There is a great site called <a href=\"http://www.metatagbuilder.com/\">Meta Tag Builder</a> that will help you build meta tags if you\'ve never done it before.\r\n<p>\r\n<i>Advanced Users:</i> If you have other things (like JavaScript) you usually put in the &lt;head&gt; area of your pages, you may put them here as well.\r\n<p>\r\n<b>Use default meta tags?</b><br>\r\nIf you don\'t wish to specify meta tags yourself, WebGUI can generate meta tags based on the page title and your company\'s name. Check this box to enable the WebGUI-generated meta tags.\r\n<p>\r\n<b>Style</b><br>\r\nBy default, when you create a page, it inherits a few traits from its parent. One of those traits is style. Choose from the list of styles if you would like to change the appearance of this page. See <i>Add Style</i> for more details.\r\n<p>\r\nIf you check the box below the style pull-down menu, all of the pages below this page will take on the style you\'ve chosen for this page.\r\n<p>\r\n<b>Owner</b><br>\r\nThe owner of a page is usually the person who created the page.\r\n<p>\r\n<b>Owner can view?</b><br>\r\nCan the owner view the page or not?\r\n<p>\r\n<b>Owner can edit?</b><br>\r\nCan the owner edit the page or not? Be careful, if you decide that the owner cannot edit the page and you do not belong to the page group, then you\'ll lose the ability to edit this page.\r\n<p>\r\n<b>Group</b><br>\r\nA group is assigned to every page for additional privilege control. Pick a group from the pull-down menu.\r\n<p>\r\n<b>Group can view?</b><br>\r\nCan members of this group view this page?\r\n<p>\r\n<b>Group can edit?</b><br>\r\nCan members of this group edit this page?\r\n<p>\r\n<b>Anybody can view?</b><br>\r\nCan any visitor or member regardless of the group and owner view this page?\r\n<p>\r\n<b>Anybody can edit?</b><br>\r\nCan any visitor or member regardless of the group and owner edit this page?\r\n<p>\r\nYou can optionally give these privileges to all pages under this page.\r\n','0');
INSERT INTO help VALUES (3,'WebGUI','English','Delete','Page','Deleting a page can create a big mess if you are uncertain about what you are doing. When you delete a page you are also deleting the content it contains, all sub-pages connected to this page, and all the content they contain. Be certain that you have already moved all the content you wish to keep before you delete a page.\r\n<p>\r\nAs with any delete operation, you are prompted to be sure you wish to proceed with the delete. If you answer yes, the delete will proceed and there is no recovery possible. If you answer no you\'ll be returned to the prior screen.','0');
INSERT INTO help VALUES (4,'WebGUI','English','Delete','Style','When you delete a style all pages using that style will be reverted to the fail safe (default) style. To ensure uninterrupted viewing, you should be sure that no pages are using a style before you delete it.\r\n<p>\r\n\r\nAs with any delete operation, you are prompted to be sure you wish to proceed with the delete. If you answer yes, the delete will proceed and there is no recovery possible. If you answer no you\'ll be returned to the prior screen.','4,5');
INSERT INTO help VALUES (5,'WebGUI','English','Add/Edit','User','See <b>Manage Users</b> for additional details.\r\n<p>\r\n\r\n<b>Username</b><br>\r\nUsername is a unique identifier for a user. Sometimes called a handle, it is also how the user will be known on the site. (<i>Note:</i> Administrators have unlimited power in the WebGUI system. This also means they are capable of breaking the system. If you rename or create a user, be careful not to use a username already in existance.)\r\n<p>\r\n\r\n<b>Password</b><br>\r\nA password is used to ensure that the user is who s/he says s/he is.\r\n<p>\r\n\r\n<b>Authentication Method</b><br>\r\nSee <i>Edit Settings</i> for details.\r\n<p>\r\n\r\n<b>LDAP URL</b><br>\r\nSee <i>Edit Settings</i> for details.\r\n<p>\r\n\r\n<b>Connect DN</b><br>\r\nThe Connect DN is the <b>cn</b> (or common name) of a given user in your LDAP database. It should be specified as <b>cn=John Doe</b>. This is, in effect, the username that will be used to authenticate this user against your LDAP server.\r\n<p>\r\n\r\n<b>Email Address</b><br>\r\nThe user\'s email address. This must only be specified if the user will partake in functions that require email.\r\n<p>\r\n\r\n<b>Groups</b><br>\r\nGroups displays which groups the user is in. Groups that are highlighted are groups that the user is assigned to. Those that are not highlighted are other groups that can be assigned. Note that you must hold down CTRL to select multiple groups.\r\n<p>\r\n\r\n<b>Language</b><br>\r\nWhat language should be used to display system related messages.\r\n<p>\r\n\r\n<b>ICQ UIN</b><br>\r\nThe <a href=\"http://www.icq.com\">ICQ</a> UIN is the \"User ID Number\" on the ICQ network. ICQ is a very popular instant messaging platform.\r\n\r\n','0');
INSERT INTO help VALUES (7,'WebGUI','English','Delete','User','There is no need to ever actually delete a user. If you are concerned with locking out a user, then simply change their password. If you truely wish to delete a user, then please keep in mind that there are consequences. If you delete a user any content that they added to the site via widgets (like message boards and user contributions) will remain on the site. However, if another user tries to visit the deleted user\'s profile they will get an error message. Also if the user ever is welcomed back to the site, there is no way to give him/her access to his/her old content items except by re-adding the user to the users table manually.\r\n<p>\r\n\r\nAs with any delete operation, you are prompted to be sure you wish to proceed with the delete. If you answer yes, the delete will proceed and there is no recovery possible. If you answer no you\'ll be returned to the prior screen.','0');
INSERT INTO help VALUES (8,'WebGUI','English','Manage','User','Users are the accounts in the system that are given rights to do certain things. There are two default users built into the system: Admin and Visitor.\r\n<p>\r\n\r\n<b>Admin</b><br>\r\nAdmin is exactly what you\'d expect. It is a user with unlimited rights in the WebGUI environment. If it can be done, this user has the rights to do it.\r\n<p>\r\n\r\n<b>Visitor</b><br>\r\nVisitor is exactly the opposite of Admin. Visitor has no rights what-so-ever. By default any user who is not logged in is seen as the user Visitor.\r\n<p>\r\n\r\n<b>Add a new user.</b><br>\r\nClick on this to go to the add user screen.\r\n<p>\r\n\r\n<b>Search</b><br>\r\nYou can search users based on username and email address. You can do partial searches too if you like.','0');
INSERT INTO help VALUES (9,'WebGUI','English','Manage','Style','Styles are used to manage the look and feel of your WebGUI pages. With WebGUI, you can have an unlimited number of styles, so your site can take on as many looks as you like. You could have some pages that look like your company\'s brochure, and some pages that look like Yahoo!&reg;. You could even have some pages that look like pages in a book. Using style management, you have ultimate control over all your designs.\r\n<p>\r\n\r\nThere are several styles built into WebGUI. The first of these are used by WebGUI can should not be edited or deleted. The last few are simply example styles and may be edited or deleted as you please.\r\n<p>\r\n\r\n<b>Fail Safe</b><br>\r\nWhen you delete a style that is still in use on some pages, the Fail Safe style will be applied to those pages. This style has a white background and simple navigation.\r\n<p>\r\n\r\n<b>Make Page Printable</b><br>\r\nThis style is used if you place an <b>^r;</b> macro on your pages and the user clicks on it. This style allows you to put a simple logo and copyright message on your printable pages.\r\n<p>\r\n\r\n<b>Packages</b><br>\r\nThis style is used by the package management system.\r\n<p>\r\n\r\n<b>Trash / Clipboard</b><br>\r\nThis style is used by the trash and clipboard system.\r\n<p>\r\n\r\n<hr size=\"1\">\r\n<p>\r\n\r\n<b>Demo Style</b><br>\r\nThis is a sample design taken from a templates site (www.freewebtemplates.com).\r\n<p>\r\n\r\n<b>Plain Black Software (black) &amp; (white)</b><br>\r\nThese designs are used on the Plain Black site.\r\n<p>\r\n\r\n<b>Yahoo!&reg;</b><br>\r\nThis is the design of the Yahoo!&reg; site. (Used without permission.)\r\n<p>\r\n\r\n<b>WebGUI</b><br>\r\nThis is a simple design featuring WebGUI logos.\r\n\r\n','4,5');
INSERT INTO help VALUES (10,'WebGUI','English','Manage','Group','Groups are used to subdivide privileges and responsibilities within the WebGUI system. For instance, you may be building a site for a classroom situation. In that case you might set up a different group for each class that you teach. You would then apply those groups to the pages that are designed for each class.\r\n<p>\r\n\r\nThere are four groups built into WebGUI. They are Admins, Content Managers, Visitors, and Registered Users.\r\n<p>\r\n\r\n<b>Admins</b><br>\r\nAdmins are users who have unlimited privileges within WebGUI. A user should only be added to the admin group if they oversee the system. Usually only one to three people will be added to this group.\r\n<p>\r\n\r\n<b>Content Managers</b><br>\r\nContent managers are users who have privileges to add, edit, and delete content from various areas on the site. The content managers group should not be used to control individual content areas within the site, but to determine whether a user can edit content at all. You should set up additional groups to separate content areas on the site.\r\n<p>\r\n\r\n<b>Registered Users</b><br>\r\nWhen users are added to the system they are put into the registered users group. A user should only be removed from this group if their account is deleted or if you wish to punish a troublemaker.\r\n<p>\r\n\r\n<b>Visitors</b><br>\r\nVisitors are users who are not logged in using an account on the system. Also, if you wish to punish a registered user you could remove him/her from the Registered Users group and insert him/her into the Visitors group.','0');
INSERT INTO help VALUES (12,'WebGUI','English','Manage','Settings','Settings are items that allow you to adjust WebGUI to your particular needs.\r\n<p>\r\n\r\n<b>Edit Authentication Settings</b><br>\r\nSettings concerning user identification and login, such as LDAP.\r\n<p>\r\n\r\n<b>Edit Company Information</b><br>\r\nInformation specific about the company or individual who controls this installation of WebGUI.\r\n<p>\r\n\r\n<b>Edit File Settings</b><br>\r\nSettings concerning attachments and images.\r\n<p>\r\n\r\n<b>Edit Mail Settings</b><br>\r\nSettings concerning email and related functions.\r\n<p>\r\n\r\n<b>Edit Miscellaneous Settings</b><br>\r\nEverything else.\r\n\r\n','7,8,9.10,11,12');
INSERT INTO help VALUES (14,'WebGUI','English','Delete','Widget','This function permanently deletes the selected widget from a page. If you are unsure whether you wish to delete this content you may be better served to cut the content to the clipboard until you are certain you wish to delete it.\r\n<p>\r\n\r\nAs with any delete operation, you are prompted to be sure you wish to proceed with the delete. If you answer yes, the delete will proceed and there is no recovery possible. If you answer no you\'ll be returned to the prior screen.','0');
INSERT INTO help VALUES (15,'WebGUI','English','Delete','Group','As the function suggests you\'ll be deleting a group and removing all users from the group. Be careful not to orphan users from pages they should have access to by deleting a group that is in use.\r\n<p>\r\n\r\nAs with any delete operation, you are prompted to be sure you wish to proceed with the delete. If you answer yes, the delete will proceed and there is no recovery possible. If you answer no you\'ll be returned to the prior screen.','0');
INSERT INTO help VALUES (16,'WebGUI','English','Add/Edit','Style','Styles are WebGUI macro enabled. See <i>Using Macros</i> for more information.\r\n<p>\r\n\r\n<b>Style Name</b><br>\r\nA unique name to describe what this style looks like at a glance. The name has no effect on the actual look of the style.\r\n<p>\r\n\r\n<b>Header</b><br>\r\nThe header is the start of the look of your site. It is helpful to look at your design and cut it into three pieces. The top and left of your design is the header. The center part is the content, and the right and bottom is the footer. Cut the HTML from your header and paste it in the space provided.\r\n<p>\r\n\r\nIf you are in need of assistance for creating a look for your site, or if you need help cutting apart your design, <a href=\"http://www.plainblack.com\">Plain Black Software</a> provides support services for a small fee.\r\n<p>\r\n\r\nMany people will add WebGUI macros to their header for automated navigation, and other features.\r\n<p>\r\n\r\n<b>Footer</b><br>\r\nThe footer is the end of the look for your site. It is the right and bottom portion of your design. You may also place WebGUI macros in your footer.\r\n<p>\r\n\r\n<b>Style Sheet</b><br>\r\nPlace your style sheet entries here. Style sheets are used to control colors, sizes, and other properties of the elements on your site. See <i>Using Style Sheets</i> for more information.\r\n<p>\r\n\r\n<i>Advanced Users:</i> for greater performance create your stylesheet on the file system (call it something like webgui.css) and add an entry like this to this area: \r\n&lt;link href=\"/webgui.css\" rel=\"stylesheet\" rev=\"stylesheet\" type=\"text/css\"&gt;','4,5');
INSERT INTO help VALUES (17,'WebGUI','English','Add/Edit','Group','See <i>Manage Group</i> for a description of grouping functions and the default groups.\r\n<p>\r\n\r\n<b>Group Name</b><br>\r\nA name for the group. It is best if the name is descriptive so you know what it is at a glance.\r\n<p>\r\n\r\n<b>Description</b><br>\r\nA longer description of the group so that other admins and content managers (or you if you forget) will know what the purpose of this group is.','0');
INSERT INTO help VALUES (24,'WebGUI','English','Edit','Miscellaneous Settings','<b>Not Found Page</b><br>\r\nIf a page that a user requests is not found in the system, the user can be redirected to the home page or to an error page where they can attempt to find what they were looking for. You decide which is better for your users.\r\n<p>\r\n\r\n<b>Session Timeout</b><br>\r\nThe time (in seconds) that a user session remains active (before needing to log in again). This timeout is reset each time a visitor hits a page. Therefore if you set the timeout for 8 hours, a user would have to log in again if s/he hadn\'t visited the site for 8 hours.\r\n<p>\r\n\r\n1800 = half hour<br>\r\n3600 = 1 hour<br>\r\n28000 = 8 hours<br>\r\n86400 = 1 day<br>\r\n604800 = 1 week<br>\r\n1209600 = 2 weeks<br>\r\n\r\n<p>\r\n<b>Document Type Declaration</b><br>\r\nThis setting allows you to specify what type of HTML you\'re generating with WebGUI. This is usually useful for HTML validation or for gaining special functionality in certain browsers. Most people should leave this at the default setting.\r\n\r\n<p>\r\n<b>Prevent Proxy Caching</b><br>\r\nSome companies have proxy servers that cause problems with WebGUI. If you\'re experiencing problems with WebGUI, and you have a proxy server, you may want to set this setting to <i>Yes</i>. Beware that WebGUI\'s URLs will not be as user-friendly after this feature is turned on.','6');
INSERT INTO help VALUES (18,'WebGUI','English','Using','Style Sheets','<a href=\"http://www.w3.org/Style/CSS/\">Cascading Style Sheets (CSS)</a> are a great way to manage the look and feel of any web site. They are used extensively in WebGUI.\r\n<p>\r\n\r\nIf you are unfamiliar with how to use CSS, <a href=\"http://www.plainblack.com\">Plain Black Software</a> provides training classes on XHTML and CSS. Alternatively, Bradsoft makes an excellent CSS editor called <a href=\"http://www.bradsoft.com/topstyle/index.asp\">Top Style</a>.\r\n<p>\r\n\r\nThe following is a list of classes used to control the look of WebGUI:\r\n<p>\r\n\r\n<b>A</b><br>\r\nThe links throughout the style.\r\n<p>\r\n\r\n<b>BODY</b><br>\r\nThe default setup of all pages within a style.\r\n<p>\r\n\r\n<b>H1</b><br>\r\nThe headers on every page.\r\n<p>\r\n\r\n<b>.accountOptions</b><br>\r\nThe links that appear under the login and account update forms.\r\n<p>\r\n\r\n<b>.adminBar </b><br>\r\nThe bar that appears at the top of the page when you\'re in admin mode.\r\n<p>\r\n\r\n<b>.content</b><br>\r\nThe main content area on all pages of the style.\r\n<p>\r\n\r\n<b>.crumbTrail </b><br>\r\nThe crumb trail (if you\'re using that macro).\r\n<p>\r\n\r\n<b>.formDescription </b><br>\r\nThe tags on all forms next to the form elements. \r\n<p>\r\n\r\n<b>.formSubtext </b><br>\r\nThe tags below some form elements.\r\n<p>\r\n\r\n<b>.highlight </b><br>\r\nDenotes a highlighted item, such as which message you are viewing within a list.\r\n<p>\r\n\r\n<b>.homeLink</b><br>\r\nUsed by the my home (^H;) macro.\r\n<p>\r\n\r\n<b>.horizontalMenu </b><br>\r\nThe horizontal menu (if you use a horizontal menu macro).\r\n<p>\r\n\r\n<b>.loginBox</b><br>\r\nThe login box (^L;) macro.\r\n<p>\r\n\r\n<b>.makePrintableLink</b><br>\r\nUsed by the make printable (^r;) macro.\r\n<p>\r\n\r\n<b>.myAccountLink</b><br>\r\nUsed by the my account (^a;) macro.\r\n<p>\r\n\r\n<b>.pagination </b><br>\r\nThe Previous and Next links on pages with pagination.\r\n<p>\r\n\r\n<b>.searchBox</b><br>\r\nUsed by the search (^?;) macro.\r\n<p>\r\n\r\n<b>.selectedMenuItem</b><br>\r\nUsed by the FlexMenu (^FlexMenu;) macro.\r\n<p>\r\n\r\n<b>.tableData </b><br>\r\nThe data rows on things like message boards and user contributions.\r\n<p>\r\n\r\n<b>.tableHeader </b><br>\r\nThe headings of columns on things like message boards and user contributions.\r\n<p>\r\n\r\n<b>.tableMenu </b><br>\r\nThe menu on things like message boards and user submissions.\r\n<p>\r\n\r\n<b>.verticalMenu </b><br>\r\nThe vertical menu (if you use a verticall menu macro).\r\n<p>\r\n\r\n<i><b>Note:</b></i> Some widgets have their own unique styles.\r\n\r\n','0');
INSERT INTO help VALUES (19,'WebGUI','English','Using','Macros','WebGUI macros are used to create dynamic content within otherwise static content. For instance, you may wish to show which user is logged in on every page, or you may wish to have a dynamically built menu or crumb trail. \r\n<p>\r\nMacros always begin with a carat (^) and follow with at least one other character and ended with w semicolon (;). Some macros can be extended/configured by taking the format of ^<i>x</i>(\"<b>config text</b>\");. The following is a description of all the macros in the WebGUI system.\r\n<p>\r\n<b>^a; or ^a(); - My Account Link</b><br>\r\nA link to your account information. In addition you can change the link text by creating a macro like this <b>^a(\"Account Info\");</b>.\r\n<p>\r\n<b>^C; or ^C(); - Crumb Trail</b><br>\r\nA dynamically generated crumb trail to the current page. You can optionally specify a delimeter to be used between page names by using ^C(::);. The default delimeter is &gt;.\r\n<p>\r\n<b>^c; - Company Name</b><br>\r\nThe name of your company specified in the settings by your Administrator.\r\n<p>\r\n<b>^D; or ^D(); - Date</b><br>\r\nThe current date and time.\r\n<p>\r\nYou can configure the date by using date formatting symbols. For instance, if you created a macro like this <b>^D(\"%c %D, %y\");</b> it would output <b>September 26, 2001</b>. The following are the available date formatting symbols:\r\n<table>\r\n<tr><td>%% = %\r\n<tr><td>%y</td><td>4 digit year</td></tr>\r\n<tr><td>%Y</td><td>2 digit year</td></tr>\r\n<tr><td>%m</td><td>2 digit month</td></tr>\r\n<tr><td>%M</td><td>variable digit month</td></tr>\r\n<tr><td>%c</td><td>month name</td></tr>\r\n<tr><td>%d</td><td>2 digit day of month</td></tr>\r\n<tr><td>%D</td><td>variable digit day of month</td></tr>\r\n<tr><td>%w</td><td>day of week name</td></tr>\r\n<tr><td>%h</td><td>2 digit base 12 hour</td></tr>\r\n<tr><td>%H</td><td>variable digit base 12 hour</td></tr>\r\n<tr><td>%j</td><td>2 digit base 24 hour</td></tr>\r\n<tr><td>%J</td><td>variable digit base 24 hour</td></tr>\r\n<tr><td>%p</td><td>lower case am/pm</td></tr>\r\n<tr><td>%P</td><td>upper case AM/PM</td></tr>\r\n</table>\r\n<p>\r\n<b>^e; - Company Email Address</b><br>\r\nThe email address for your company specified in the settings by your Administrator.\r\n<p>\r\n<b>^Execute();</b><br>\r\nAllows a content manager or administrator to execute an external program. Takes the format of <b>^Execute(\"/this/file.sh\");</b>.\r\n<p>\r\n<b>^FlexMenu;</b><br>\r\nThis menu macro creates a top-level menu that expands as the user selects each menu item.\r\n<p>\r\n<b>^H; or ^H(); - Home Link</b><br>\r\nA link to the home page of this site.  In addition you can change the link text by creating a macro like this <b>^H(\"Go Home\");</b>.\r\n<p>\r\n<b>^I(); - Image Manager Image with Tag</b><br>\r\nThis macro returns an image tag with the parameters for an image defined in the image manager. Specify the name of the image using a tag like this <b>^I(\"imageName\")</b>;.\r\n<p>\r\n<b>^i(); - Image Manager Image Path</b><br>\r\nThis macro returns the path of an image uploaded using the Image Manager. Specify the name of the image using a tag like this <b>^i(\"imageName\");</b>.\r\n<p>\r\n<b>^Include();</b><br>\r\nAllows a content manager or administrator to include a file from the local filesystem. Takes the format of <b>^Include(\"/this/file.html\")</b>;\r\n<p>\r\n<b>^L; - Login</b><br>\r\nA small login form.\r\n<p>\r\n<b>^M; or ^M(); - Current Menu (Vertical)</b><br>\r\nA vertical menu containing the sub-pages at the current level. In addition, you may configure this macro by specifying how many levels deep the menu should go. By default it will show only the first level. To go three levels deep create a macro like this <b>^M(3);</b>. If you set the macro to \"0\" it will track the entire site tree.\r\n<p>\r\n<b>^m; - Current Menu (Horizontal)</b><br>\r\nA horizontal menu containing the sub-pages at the current level. You can optionally specify a delimeter to be used between page names by using ^m(:--:);. The default delimeter is &middot;.\r\n<p>\r\n<b>^P; or ^P(); - Previous Menu (Vertical)</b><br>\r\nA vertical menu containing the sub-pages at the previous level. In addition, you may configure this macro by specifying how many levels deep the menu should go. By default it will show only the first level. To go three levels deep create a macro like this <b>^P(3);</b>. If you set the macro to \"0\" it will track the entire site tree.\r\n<p>\r\n<b>^p; - Previous Menu (Horizontal)</b><br>\r\nA horizontal menu containing the sub-pages at the previous level. You can optionally specify a delimeter to be used between page names by using ^p(:--:);. The default delimeter is &middot;.\r\n<p>\r\n<b>^PageTitle;</b><br>\r\nDisplays the title of the current page.\r\n<p>\r\n<b>^r; or ^r(); - Make Page Printable</b><br>\r\nCreates a link to remove the style from a page to make it printable.  In addition, you can change the link text by creating a macro like this <b>^r(\"Print Me!\");</b>.\r\n<p>\r\n<b>^S(); - Specific SubMenu (Vertical)</b><br>\r\nThis macro allows you to get the submenu of any page, starting with the page you specified. For instance, you could get the home page submenu by creating a macro that looks like this <b>^S(\"home\",0);</b>. The first value is the urlized title of the page and the second value is the depth you\'d like the menu to go. By default it will show only the first level. To go three levels deep create a macro like this <b>^S(\"home\",3);</b>.\r\n<p>\r\n<b>^s(); - Specific SubMenu (Horizontal)</b><br>\r\nThis macro allows you to get the submenu of any page, starting with the page you specified. For instance, you could get the home page submenu by creating a macro that looks like this <b>^s(\"home\");</b>. The value is the urlized title of the page.  You can optionally specify a delimeter to be used between page names by using ^s(\"home\",\":--:\");. The default delimeter is &middot;.\r\n<p>\r\n<b>^T; or ^T(); - Top Level Menu (Vertical)</b><br>\r\nA vertical menu containing the main pages of the site (aka the sub-pages from the home page). In addition, you may configure this macro by specifying how many levels deep the menu should go. By default it will show only the first level. To go three levels deep create a macro like this <b>^T(3);</b>. If you set the macro to \"0\" it will track the entire site tree.\r\n<p>\r\n<b>^t; - Top Level Menu (Horizontal)</b><br>\r\nA vertical menu containing the main pages of the site (aka the sub-pages from the home page). You can optionally specify a delimeter to be used between page names by using ^t(:--:);. The default delimeter is &middot;.\r\n<p>\r\n<b>^u; - Company URL</b><br>\r\nThe URL for your company specified in the settings by your Administrator.\r\n<p>\r\n<b>^/; - System URL</b><br>\r\nThe URL to the gateway script (including the domain for this site). This is often used within pages so that if your development server is on a domain different than your production server that your URLs will still worked when moved.\r\n<p>\r\n<b>^\\; - Page URL</b><br>\r\nThe URL to the current page (including the domain for this site). This is often used within pages so that if your development server is on a domain different than your production server that your URLs will still worked when moved.\r\n<p>\r\n<b>^@; - Username</b><br>\r\nThe username of the currently logged in user.\r\n<p>\r\n<b>^?; - Search</b><br>\r\nAdd a search box.\r\n<p>\r\n<b>^#; - User ID</b><br>\r\nThe user id of the currently logged in user.\r\n<p>\r\n<b>^*; or ^*(); - Random Number</b><br>\r\nA randomly generated number. This is often used on images (such as banner ads) that you want to ensure do not cache. In addition, you may configure this macro like this <b>^*(100);</b> to create a random number between 0 and 100.\r\n<p>\r\n<b>^-;,^0;,^1;,^2;,^3;, etc.</b><br>\r\nThese macros are reserved for widget-specific functions as in the SQL Report widget.\r\n','0');
INSERT INTO help VALUES (1,'SQLReport','English','Add/Edit','SQL Report','SQL Reports are perhaps the most powerful widget in the WebGUI arsenal. They allow a user to query data from any database that they have access to. This is great for getting sales figures from your Accounting database or even summarizing all the message boards on your web site.\r\n<p>\r\n\r\n<b>Title</b><br>\r\nThe title of this report.\r\n<p>\r\n\r\n<b>Display the title?</b><br>\r\nDo you wish to disply the title?\r\n<p>\r\n\r\n<b>Process macros?</b><br>\r\nDo you wish to process WebGUI macros? Unchecking this box will not process macros and will speed up page execution.\r\n<p>\r\n\r\n<b>Position</b><br>\r\nSelect the position in the current page template where this widget should be placed.\r\n<p>\r\n\r\n<b>Description</b><br>\r\nDescribe the content of this report so your users will better understand what the report is all about.\r\n<p>\r\n\r\n<b>Template</b><br>\r\nLayout a template of how this report should look. Usually you\'ll use HTML tables to generate a report. An example is included below. If you leave this field blank a template will be generated based on your result set.\r\n<p>\r\n\r\nThere are special macro characters used in generating SQL Reports. They are ^-;, ^0;, ^1;, ^2;, ^3;, etc. These macros will be processed regardless of whether you checked the process macros box above. The ^- macro represents split points in the document where the report will begin and end looping. The numeric macros represent the data fields that will be returned from your query.\r\n<p>\r\n<pre>\r\n<i>Sample Template:</i>\r\n&lt;table&gt;\r\n&lt;tr&gt;&lt;th&gt;Employee Name&lt;/th&gt;&lt;th&gt;Employee #&lt;/th&gt;&lt;th&gt;Vacation Days Remaining&lt;/th&gt;&lt;th&gt;Monthly Salary&lt;/th&gt;&lt;/tr&gt;\r\n^-;\r\n&lt;tr&gt;&lt;td&gt;^0;&lt;/td&gt;&lt;td&gt;^1;&lt;/td&gt;&lt;td&gt;^2;&lt;/td&gt;&lt;td&gt;^3;&lt;/td&gt;&lt;/tr&gt;\r\n^-;\r\n&lt;/table&gt;\r\n</pre>\r\n<b>Query</b><br>\r\nThis is a standard SQL query. If you are unfamiliar with SQL, <a href=\"http://www.plainblack.com\">Plain Black Software</a> provides training courses in SQL and database management.\r\n<p>\r\n\r\n<b>DSN</b><br>\r\n<b>D</b>ata <b>S</b>ource <b>N</b>ame is the unique identifier that Perl uses to describe the location of your database. It takes the format of DBI:[driver]:[database name]:[host]. \r\n<p>\r\n\r\n<i>Example:</i> DBI:mysql:WebGUI:localhost\r\n<p>\r\n\r\n<b>Database User</b>\r\nThe username you use to connect to the DSN.\r\n<p>\r\n\r\n<b>Database Password</b>\r\nThe password you use to connect to the DSN.\r\n<p>\r\n\r\n<b>Paginate After</b>\r\nHow many rows should be displayed before splitting the results into separate pages? In other words, how many rows should be displayed per page?\r\n<p>\r\n\r\n<b>Convert carriage returns?</b>\r\nDo you wish to convert the carriage returns in the resultant data to HTML breaks (&lt;br&gt;).\r\n','1,2,3,4,5');
INSERT INTO help VALUES (21,'WebGUI','English','Using','Widget','Widgets are the true power of WebGUI. Widgets are tiny pluggable applications built to run under WebGUI. Message boards and polls are examples of widgets.\r\n<br><br>\r\nTo add a widget to a page, first go to that page, then select <i>Add Content...</i> from the upper left corner of your screen. Each widget has it\'s own help so be sure to read the help if you\'re not sure how to use a widget.\r\n','0');
INSERT INTO help VALUES (1,'Article','English','Add/Edit','Article','Articles are the Swiss Army knife of WebGUI. Most pieces of static content can be added via the Article widget.\r\n<br><br>\r\n<b>Title</b><br>\r\nWhat\'s the title for this content? Even if you don\'t wish the title to appear, it\'s a good idea to title your content so that if it is ever copied to the clipboard it will have a name.\r\n<br><br>\r\n<b>Display the title?</b><br>\r\nDo you wish to display the title?\r\n<br><br>\r\n<b>Process macros?</b><br>\r\nDo you wish to process WebGUI macros on this article? Unchecking this box will not process macros and will speed up page execution.\r\n<br><br>\r\n<b>Position</b><br>\r\nSelect the position in the current page template where this widget should be placed.\r\n<br><br>\r\n<b>Start Date</b><br>\r\nWhat date do you want this article to appear on the site? Dates are in the format of MM/DD/YYYY. You can use the JavaScript wizard to choose your date from a calendar by clicking on the <i>set date</i> button. By default the date is set to 01/01/2000.\r\n<br><br>\r\n<b>End Date</b><br>\r\nWhat date do you want this article to be removed from the site? By default the date is set to 100 years in the future, 01/01/2100.\r\n<br><br>\r\n<b>Body</b><br>\r\nThe body of the article is where all content is placed. You may feel free to add HTML tags as necessary to format your content. Be sure to put a &lt;p&gt; between paragraphs to add white space to your content.\r\n<br><br>\r\n<b>Image</b><br>\r\nChoose an image (.jpg, .gif, .png) file from your hard drive. This file will be uploaded to the server and displayed in the upper-right corner of your article.\r\n<br><br>\r\n<b>Link Title</b><br>\r\nIf you wish to add a link to your article, enter the title of the link in this field. \r\n<br><br>\r\n<i>Example:</i> Google\r\n<br><br>\r\n<b>Link URL</b><br>\r\nIf you added a link title, now add the URL (uniform resource locator) here. \r\n<br><br>\r\n<i>Example:</i> http://www.google.com\r\n<br><br>\r\n<b>Attachment</b><br>\r\nIf you wish to attach a word processor file, a zip file, or any other file for download by your users, then choose it from your hard drive.\r\n<br><br>\r\n<b>Convert carriage returns?</b><br>\r\nIf you\'re publishing HTML there\'s generally no need to check this option, but if you aren\'t using HTML and you want a carriage return every place you hit your \"Enter\" key, then check this option.\r\n','1,2,3,4,5');
INSERT INTO help VALUES (1,'ExtraColumn','English','Add/Edit','Extra Column','Extra columns allow you to change the layout of your page for one page only. If you wish to have multiple columns on all your pages. Perhaps you should consider altering the <i>style</i> applied to your pages. \r\n<br><br>\r\nColumns are always added from left to right. Therefore any existing content will be on the left of the new column.\r\n<br><br>\r\n<b>Position</b><br>\r\nSelect the position in the current page template where this widget should be placed.\r\n<br><br>\r\n<b>Spacer</b><br>\r\nSpacer is the amount of space between your existing content and your new column. It is measured in pixels.\r\n<br><br>\r\n<b>Width</b><br>\r\nWidth is the actual width of the new column to be added. Width is measured in pixels.\r\n<br><br>\r\n<b>StyleSheet Class</b><br>\r\nBy default the <i>content</i> style (which is the style the body of your site should be using) that is applied to all columns. However, if you\'ve created a style specifically for columns, then feel free to modify this class.\r\n','1,2,3,4,5');
INSERT INTO help VALUES (27,'WebGUI','English','Add/Edit','Widget','You can add widgets by selecting from the <i>Add Content</i> pulldown menu. You can edit them by clicking on the \"Edit\" button that appears directly above an instance of a particular widget.','0');
INSERT INTO help VALUES (1,'Poll','English','Add/Edit','Poll','Polls can be used to get the impressions of your users on various topics.\r\n<br><br>\r\n<b>Title</b><br>\r\nThe title of the Poll. Even if you don\'t wish to display the title you should fill out this field so this poll will have a name if it is ever placed in the clipboard.\r\n<br><br>\r\n<b>Display the title?</b><br>\r\nDo you wish to display the title?\r\n<br><br>\r\n<b>Process macros?</b><br>\r\nDo you wish to process WebGUI macros? Unchecking this box will not process macros and will speed up page execution.\r\n<br><br>\r\n<b>Position</b><br>\r\nSelect the position in the current page template where this widget should be placed.\r\n<br><br>\r\n<b>Description</b><br>\r\nYou may provide a description for this Poll, or give the user some background information.\r\n<br><br>\r\n<b>Active</b><br>\r\nIf this box is checked, then users will be able to vote. Otherwise they\'ll only be able to see the results of the poll.\r\n<br><br>\r\n<b>Who can vote?</b><br>\r\nChoose a group that can vote on this Poll.\r\n<br><br>\r\n<b>Graph Width</b><br>\r\nThe width of the poll results graph. The width is measured in pixels.\r\n<br><br>\r\n<b>Question</b><br>\r\nWhat is the question you\'d like to ask your users?\r\n<br><br>\r\n<b>Answers</b><br>\r\nEnter the possible answers to your question. Enter only one answer per line. Polls are only capable of 20 possible answers.\r\n<br><br>\r\n<b>Reset votes.</b><br>\r\nReset the votes on this Poll.\r\n<br><br>\r\n<hr size=1>\r\n<i><b>Note:</b></i> The following style sheet entries are custom to the Poll widget:\r\n<br><br>\r\n<b>.pollAnswer </b><br>\r\nAn answer on a poll.\r\n<br><br>\r\n<b>.pollColor </b>\r\nThe color of the percentage bar on a poll.\r\n<br><br>\r\n<b>.pollQuestion </b>\r\nThe question on a poll.\r\n\r\n','1,2,3,4,5');
INSERT INTO help VALUES (1,'SiteMap','English','Add/Edit','Site Map','Site maps are used to provide additional navigation in WebGUI. You could set up a traditional site map that would display a hierarchical view of all the pages in the site. On the other hand, you could use site maps to provide extra navigation at certain levels in your site.\r\n<br><br>\r\n<b>Title</b><br>\r\nWhat title would you give to this Site Map? You should fill this field out even if you don\'t wish it to be displayed.\r\n<br><br>\r\n<b>Display the title?</b><br>\r\nDo you wish to display the title?\r\n<br><br>\r\n<b>Process macros?</b><br>\r\nDo you wish to process WebGUI macros? Unchecking this box will not process macros and will speed up page execution.\r\n<br><br>\r\n<b>Position</b><br>\r\nSelect the position in the current page template where this widget should be placed.\r\n<br><br>\r\n<b>Description</b><br>\r\nEnter a description as to why this Site Map is here and what purpose it serves.\r\n<br><br>\r\n<b>Starting from this level?</b><br>\r\nIf the Site Map should display the page tree starting from this level, then check this box. If you wish the Site Map to start from the home page then uncheck it.\r\n<br><br>\r\n<b>Show only one level?</b><br>\r\nShould the Site Map display only the current level of pages or all pages from this point forward? \r\n','1,2,3,4,5');
INSERT INTO help VALUES (1,'MessageBoard','English','Add/Edit','Message Board','Message boards, also called Forums and/or Discussions, are a great way to add community to any site or intranet. Many companies use message boards internally to collaborate on projects.\r\n<br><br>\r\n<b>Title</b><br>\r\nThe name of this Message Board.\r\n<br><br>\r\n<b>Display the title?</b><br>\r\nDo you wish to display the title?\r\n<br><br>\r\n<b>Process macros?</b><br>\r\nDo you wish to process WebGUI macros? Unchecking this box will not process macros and will speed up page execution.\r\n<br><br>\r\n<b>Position</b><br>\r\nSelect the position in the current page template where this widget should be placed.\r\n<br><br>\r\n<b>Description</b><br>\r\nBriefly describe what should be displayed on this Message Board.\r\n<br><br>\r\n<b>Who can post?</b><br>\r\nWhat group can post to this Message Board?\r\n<br><br>\r\n<b>Messages Per Page</b><br>\r\nWhen a visitor first comes to a message board s/he will be presented with a listing of all the topics (a.k.a. threads) of the Message Board. If a board is popular, it will quickly have many topics. The Messages Per Page attribute allows you to specify how many topics should be shown on one page.\r\n<br><br>\r\n<b>Edit Timeout</b><br>\r\nEdit Timeout specifies how long a user\'s message will be available for him/her to edit. Timeout is measured in hours.\r\n<br><br>\r\n<i>Note:</i> Don\'t set this limit too high. One of the great things about message boards is that they are an accurate record of a discussion. If you allow editing for a long time, then a user has a chance to go back and change his/her mind a long time after the original statement was made.\r\n','1,2,3,4,5');
INSERT INTO help VALUES (1,'LinkList','English','Add/Edit','Link List','Link Lists are just what they sound like, a list of links. Many sites have a links section, and this widget just automates the process.\r\n<br><br>\r\n<b>Title</b><br>\r\nWhat is the title of this Link List?\r\n<br><br>\r\n<b>Display the title?</b><br>\r\nDo you wish to display the title?\r\n<br><br>\r\n<b>Process macros?</b><br>\r\nDo you wish to process WebGUI macros? Unchecking this box will not process macros and will speed up page execution.\r\n<br><br>\r\n<b>Position</b><br>\r\nSelect the position in the current page template where this widget should be placed.\r\n<br><br>\r\n<b>Description</b><br>\r\nDescribe the purpose of the links in this list.\r\n<br><br>\r\n<b>Proceed to add link?</b><br>\r\nLeave this checked if you want to add links to the Link List directly after creating it.\r\n<br><br>\r\n<b>Add / Edit Links</b><br>\r\nYou\'ll notice at the bottom of the Edit screen that there are some options to add, edit, delete and reorder the links in your link lists. This process works exactly as the process for doing the same with widgets and pages. The three properties of links are <i>Name</i>, <i>URL</i>, and <i>Description</i>.\r\n<br><br>\r\n<b>Style</b><br>\r\nAn extra StyleSheet class has been added to this widget: <b>linkTitle</b>.  Use this to bold, colorize, or otheriwise manipulate the title of each link.','1,2,3,4,5');
INSERT INTO help VALUES (13,'WebGUI','English','Edit','Mail Settings','<b>Recover Password Message</b><br>\r\nThe message that gets sent to a user when they use the \"recover password\" function.\r\n<br><br>\r\n<b>SMTP Server</b><br>\r\nThis is the address of your local mail server. It is needed for all features that use the Internet email system (such as password recovery).\r\n\r\n','6');
INSERT INTO help VALUES (1,'SyndicatedContent','English','Add/Edit','Syndicated Content','Syndicated content is content that is pulled from another site using the RDF/RSS specification. This technology is often used to pull headlines from various news sites like <a href=\"http://www.cnn.com\">CNN</a> and  <a href=\"http://slashdot.org\">Slashdot</a>. It can, of course, be used for other things like sports scores, stock market info, etc.\r\n<br><br>\r\nYou can find a list of syndicated content at <a href=\"http://my.userland.com\">http://my.userland.com</a>. You will need to register with an account to browse their listing of content. Also, the list contained there is by no means a complete list of all the syndicated content on the internet.\r\n<br><br>\r\n<b>Title</b><br>\r\nWhat is the title for this content? This is often the title of the site that the content comes from.\r\n<br><br>\r\n<b>Display the title?</b><br>\r\nDo you wish to disply the title?\r\n<br><br>\r\n<b>Process macros?</b><br>\r\nDo you wish to process WebGUI macros? Unchecking this box will not process macros and will speed up page execution.\r\n<br><br>\r\n<b>Position</b><br>\r\nSelect the position in the current page template where this widget should be placed.\r\n<br><br>\r\n<b>Description</b><br>\r\nBriefly describe the content being pulled so that your users will know what they are seeing.\r\n<br><br>\r\n<b>URL to RSS file</b><br>\r\nProvide the exact URL (starting with http://) to the syndicated content\'s RDF or RSS file. The syndicated content will be downloaded from this URL hourly.','1,2,3,4,5');
INSERT INTO help VALUES (1,'EventsCalendar','English','Add/Edit','Events Calendar','Events calendars are used on many intranets to keep track of internal dates that affect a whole organization. Also, Events Calendars on consumer sites are a great way to let your customers know what events you\'ll be attending and what promotions you\'ll be having.\r\n<br><br>\r\n<b>Title</b><br>\r\nWhat is the title of this Events Calendar?\r\n<br><br>\r\n<b>Display the title?</b><br>\r\nDo you wish to display the title?\r\n<br><br>\r\n<b>Process macros?</b><br>\r\nDo you wish to process WebGUI macros? Unchecking this box will not process macros and will speed up page execution.\r\n<br><br>\r\n<b>Position</b><br>\r\nSelect the position in the current page template where this widget should be placed.\r\n<br><br>\r\n<b>Description</b><br>\r\nBriefly describe this Events Calendar.\r\n<br><br>\r\n<b>Display Layout</b><br>\r\nThis can be set to <i>List</i> or <i>Calendar</i>. When set to <i>List</i> the events will be listed by date of occurence (and events that have already passed will not be displayed). This type of layout is best suited for Events Calendars that have only a few events per month. When set to <i>Calendar</i> the Events Calendar will display a traditional monthly Calendar, which can be paged through month-by-month. This type of layout is generally used when there are many events in each month.\r\n<br><br>\r\n<b>Paginate After</b><br>\r\nWhen using the list layout, how many events should be shown per page?\r\n<br><br>\r\n<b>Proceed to add event?</b><br>\r\nLeave this checked if you want to add events to the Events Calendar directly after creating it.\r\n<br><br>\r\n<b>Add / Edit Events</b><br>\r\nOn the edit screen you\'ll notice that there are options to add, edit, and delete the events in your events calendar. The properties for events are <i>Name</i>, <i>Description</i>, <i>Start Date</i>,  and <i>End Date</i>.\r\n<br><br>\r\n<i>Note:</i> Events that have already happened will not be displayed on the events calendar.\r\n<br><br>\r\n<hr size=1>\r\n<i><b>Note:</b></i> The following style is specific to the Events Calendar.\r\n<br><br>\r\n<b>.eventTitle </b><br>\r\nThe title of an individual event.\r\n\r\n','1,2,3,4,5');
INSERT INTO help VALUES (1,'FAQ','English','Add/Edit','FAQ','It seems that almost every web site, intranet, and extranet in the world has a Frequently Asked Questions area. This widget helps you build one, too.\r\n<br><br>\r\n<b>Title</b><br>\r\nWhat is the title for this FAQ section?\r\n<br><br>\r\n<b>Display the title?</b><br>\r\nDo you wish to display the title?\r\n<br><br>\r\n<b>Process macros?</b><br>\r\nDo you wish to process WebGUI macros? Unchecking this box will not process macros and will speed up page execution.\r\n<br><br>\r\n<b>Position</b><br>\r\nSelect the position in the current page template where this widget should be placed.\r\n<br><br>\r\n<b>Description</b><br>\r\nBriefly describe what this FAQ covers.\r\n<br><br>\r\n<b>Proceed to add question?</b><br>\r\nLeave this checked if you want to add questions to the FAQ directly after creating it.\r\n<br><br>\r\n<b>Add / Edit Questions</b><br>\r\nOn the edit screen you\'ll notice options for adding, editing, deleting, and reordering the questions in your FAQ. The two properties of FAQ questions are <i>Question</i> and <i>Answer</i>.\r\n<br><br>\r\n<hr size=1>\r\n<i><b>Note:</b></i> The following style is specific to the FAQ widget.\r\n<br><br>\r\n<b>.faqQuestion</b><br>\r\nAn F.A.Q. question. To distinguish it from an answer.\r\n\r\n','1,2,3,4,5');
INSERT INTO help VALUES (11,'WebGUI','English','Edit','File Settings','<b>Path to WebGUI Extras</b><br>\r\nThe web-path to the directory containing WebGUI images and javascript files.\r\n<br><br>\r\n<b>Maximum Attachment Size</b><br>\r\nThe maximum size of files allowed to be uploaded to this site. This applies to all widgets that allow uploaded files and images (like Article and User Contributions). This size is measured in kilobytes.\r\n<br><br>\r\n<b>Web Attachment Path</b><br>\r\nThe web-path of the directory where attachments are to be stored.\r\n<br><br>\r\n<b>Server Attachment Path</b><br>\r\nThe local path of the directory where attachments are to be stored. (Perhaps /var/www/public/uploads) Be sure that the web server has the rights to write to that directory.\r\n','6');
INSERT INTO help VALUES (2,'WebGUI','English','Edit','Authentication Settings','<b>Anonymous Registration</b><br>\r\nDo you wish visitors to your site to be able to register themselves?\r\n<br><br>\r\n<b>Authentication Method (default)</b><br>\r\nWhat should the default authentication method be for new accounts that are created? The two available options are WebGUI and LDAP. WebGUI authentication means that the users will authenticate against the username and password stored in the WebGUI database. LDAP authentication means that users will authenticate against an external LDAP server.\r\n<br><br>\r\n<i>Note:</i> Authentication settings can be customized on a per user basis.\r\n<br><br>\r\n<b>Username Binding</b><br>\r\nBind the WebGUI username to the LDAP Identity. This requires the user to have the same username in WebGUI as they specified during the Anonymous Registration process. It also means that they won\'t be able to change their username later. This only in effect if the user is authenticating against LDAP.\r\n<br><br>\r\n<b>LDAP URL (default)</b><br>\r\nThe default url to your LDAP server. The LDAP URL takes the form of <b>ldap://[server]:[port]/[base DN]</b>. Example: ldap://ldap.mycompany.com:389/o=MyCompany.\r\n<br><br>\r\n<b>LDAP Identity</b><br>\r\nThe LDAP Identity is the unique identifier in the LDAP server that the user will be identified against. Often this field is <b>shortname</b>, which takes the form of first initial + last name. Example: jdoe. Therefore if you specify the LDAP identity to be <i>shortname</i> then Jon Doe would enter <i>jdoe</i> during the registration process.\r\n<br><br>\r\n<b>LDAP Identity Name</b><br>\r\nThe label used to describe the LDAP Identity to the user. For instance, some companies use an LDAP server for their proxy server users to authenticate against. In the documentation or training already provided to their users, the LDAP identity is known as their <i>Web Username</b>. So you could enter that label here for consitency.\r\n<br><br>\r\n<b>LDAP Password Name</b><br>\r\nJust as the LDAP Identity Name is a label, so is the LDAP Password Name. Use this label as you would LDAP Identity Name.\r\n\r\n','6');
INSERT INTO help VALUES (1,'UserSubmission','English','Add/Edit','User Submission System','User Submission Systems are a great way to add a sense of community to any site as well as get free content from your users.\r\n<br><br>\r\n<b>Title</b><br>\r\nWhat is the title for this User Submission System?\r\n<br><br>\r\n<b>Display the title?</b><br>\r\nDo you wish to display the title?\r\n<br><br>\r\n<b>Process macros?</b><br>\r\nDo you wish to process WebGUI macros? Unchecking this box will not process macros and will speed up page execution.\r\n<br><br>\r\n<b>Position</b><br>\r\nSelect the position in the current page template where this widget should be placed.\r\n<br><br>\r\n<b>Description</b><br>\r\nBriefly describe why this User Submission System is here and what should be submitted to it.\r\n<br><br>\r\n<b>Who can approve?</b><br>\r\nWhat group is allowed to approve and deny content?\r\n<br><br>\r\n<b>Who can contribute?</b><br>\r\nWhat group is allowed to contribute content?\r\n<br><br>\r\n<b>Submissions Per Page</b><br>\r\nHow many submissions should be listed per page in the submissions index?\r\n<br><br>\r\n<b>Default Status</b><br>\r\nShould submissions be set to <i>Approved</i>, <i>Pending</i>, or <i>Denied</i> by default?\r\n<br><br>\r\n<i>Note:</i> If you set the default status to Pending, then be prepared to monitor your message log for new submissions.\r\n','1,2,3,4,5');
INSERT INTO help VALUES (6,'WebGUI','English','Edit','Company Information','<b>Company Name</b><br>\r\nThe name of your company. It will appear on all emails and anywhere you use the Company Name macro.\r\n<br><br>\r\n<b>Company Email Address</b><br>\r\nA general email address at your company. This is the address that all automated messages will come from. It can also be used via the WebGUI macro system.\r\n<br><br>\r\n<b>Company URL</b><br>\r\nThe primary URL of your company. This will appear on all automated emails sent from the WebGUI system. It is also available via the WebGUI macro system.\r\n','6');
INSERT INTO help VALUES (46,'WebGUI','English','Empty','Trash','If you choose to empty your trash, any items contained in it will be lost forever. If you\'re unsure about a few items, it might be best to cut them to your clipboard before you empty the trash.','0');
INSERT INTO help VALUES (22,'WebGUI','English','Edit','Profile Settings','Profiles are used to extend the information of a particular user. In some cases profiles are important to a site, in others they are not. Use the following switches to turn the various profile sections on and off.\r\n<br><br>\r\n<b>Allow real name?</b><br>\r\nDo you want users to enter and display their real names?\r\n<br><br>\r\n<b>Allow extra contact information?</b><br>\r\nDo you want users to enter and display their extra contact information such as Instant Messenger IDs, cell phone numbers, and pager numbers?\r\n<br><br>\r\n<b>Allow home information?</b><br>\r\nDo you want users to enter and display their home address and phone number?\r\n<br><br>\r\n<b>Allow business information?</b><br>\r\nDo you want users to enter and display their work address and phone number?\r\n<br><br>\r\n<b>Allow miscellaneous information?</b><br>\r\nDo you want users to enter and display any extra info such as gender, birthdate and home page?','6');
INSERT INTO help VALUES (25,'WebGUI','English','Using','Search Engine','Due to many requests by our customers, we\'ve built a small, but sturdy search engine into WebGUI. If you wish to use the internal search engine, you can use the ^?; macro or feel free to build your own form to access it.\r\n<br><br>\r\nWe do not recommend the built-in search engine\'s use on large sites as it can be very slow. There are many great search engines available around the Internet that can be used with WebGUI.\r\n<br><br>\r\n<a href=\"http://www.mnogosearch.org\">MnoGo Search</a> - A very powerful and very fast open-source search engine. We maintain an unsupported WebGUI widget on the <a href=\"http://www.plainblack.com\">Plain Black</a> site that will allow you to use MnoGo search directly within WebGUI or you can use the super-powerful external search engine it provides.\r\n<br><br>\r\n<a href=\"http://www.htdig.org/\">ht://Dig</a> - Another great open-source search engine. We\'ve used it in many instances and it always proves to be reliable and fast.','0');
INSERT INTO help VALUES (1,'Item','English','Add/Edit','Item','Like Articles, Items are the Swiss Army knife of WebGUI. Most pieces of static content can be added via the Item widget, though Items are usually used for smaller content than Articles.\r\n<br><br>\r\n<b>Title</b><br>\r\nWhat\'s the title for this content?\r\n<br><br>\r\n<b>Process macros?</b><br>\r\nDo you wish to process WebGUI macros? Unchecking this box will not process macros and will speed up page execution.\r\n<br><br>\r\n<b>Position</b><br>\r\nSelect the position in the current page template where this widget should be placed.\r\n<br><br>\r\n<b>Description</b><br>\r\nThe long description of this Item.\r\n<br><br>\r\n<b>Link URL</b><br>\r\nThis URL will be attached to the title of this Item.\r\n<br><br>\r\n<i>Example:</i> http://www.google.com\r\n<br><br>\r\n<b>Attachment</b><br>\r\nIf you wish to attach a word processor file, a zip file, or any other file for download by your users, then choose it from your hard drive.\r\n\r\n','1,2,3,4,5');
INSERT INTO help VALUES (30,'WebGUI','English','Select','Package','Packages are groups of pages and widgets that are predefined to be deployed together. A package manager may see the need to create a package several pages with a message board, an FAQ, and a Poll because that task is performed quite often. Packages are often defined to lessen the burden of repetitive tasks.\r\n<br><br>\r\nOne package that many people create is a Page/Article package. It is often the case that you want to add a page with an article on it for content. Instead of going through the steps of creating a page, going to the page, and then adding an article to the page, you may wish to simply create a package to do those steps all at once.','0');
INSERT INTO help VALUES (31,'WebGUI','English','Add/Edit','Package','To create a package follow these simple steps:\r\n<ol>\r\n<li> From the admin menu select \"View Packages.\"\r\n<li> Add a page and give it a name. The name of the page will be the name of the package.\r\n<li> Go to the new page you created and start adding pages and widgets. Any pages or widgets you add will be created each time this package is deployed. \r\n</ol>\r\n<b>Notes:</b><br>\r\nIn order to add, edit, or delete packages you must be in the Package Mangers group or in the Admins group.\r\n<br><br>\r\nIf you add content to any of the widgets, that content will automatically be copied also when the package is deployed.\r\n<br><br>\r\nPrivileges and styles assigned to pages in the package will not be copied when the package is deployed. Instead the pages will take the privileges and styles of the area to which they are deployed.','0');
INSERT INTO help VALUES (20,'WebGUI','English','Add/Edit','Image','<b>Name</b><br>\r\nThe label that this image will be referenced by to include it into pages.\r\n<p>\r\n\r\n<b>File</b><br>\r\nSelect a file from your local drive to upload to the server.\r\n<p>\r\n\r\n<b>Parameters</b><br>\r\nAdd any HTML &ltimg&rt; parameters that you wish to act as the defaults for this image.\r\n<p>\r\n<i>Example:</i><br>\r\nalign=\"right\"\r\nalt=\"This is an image\"','15');
INSERT INTO help VALUES (1,'DownloadManager','English','Add/Edit','Download Manager','The Download Manager is designed to help you manage file distribution on your site. It allows you to specify who may download files from your site.\r\n<p>\r\n<b>Title</b><br>\r\nWhat is the title of this Download Manager?\r\n<br><br>\r\n<b>Display the title?</b><br>\r\nDo you wish to display the title?\r\n<br><br>\r\n<b>Process macros?</b><br>\r\nDo you wish to process WebGUI macros? Unchecking this box will not process macros and will speed up page execution.\r\n<br><br>\r\n<b>Position</b><br>\r\nSelect the position in the current page template where this widget should be placed.\r\n<br><br>\r\n<b>Description</b><br>\r\nDescribe the purpose of this Download Manager.\r\n<p>\r\n\r\n<b>Paginate After</b><br>\r\nHow many files should be displayed before splitting the results into separate pages? In other words, how many files should be displayed per page?\r\n<p>\r\n\r\n<b>Proceed to add file?</b><br>\r\nIf you wish to start adding files to download right away, leave this checked.\r\n<p>\r\n\r\n<b>Adding Files</b><br>\r\nAfter you\'ve created a download manager you can add as many files as you wish to it. The properties for each file are <i>Download File</i>, <i>Alternate Version #1</i>, <i>Alternate Version #2</i>, <i>File Title</i>, <i>Brief Synopsis</i>, and <i>Group to Download</i>. All of these should be self explainatory except for the alternate versions. Alternate versions are used for when you\'re distributing different file formats of the same file, such as a Microsoft Word document and a PDF version. Or a JPEG, GIF, and TIFF.\r\n','0');
INSERT INTO help VALUES (23,'WebGUI','English','Delete','Image','When you delete an image it will be removed from the server and cannot be recovered. Therefore, be sure that you really wish to delete the image before you confirm the delete.','15');
INSERT INTO help VALUES (26,'WebGUI','English','Manage','Image','Using the built in image manager in WebGUI you can upload images to one central location for use anywhere else in the site with no need for any special software or knowledge.\r\n<p>\r\n To place the images you\'ve uploaded use the ^I(); and ^i(); macros. More information on them can be found in the Using Macros help.','15');

#
# Table structure for table 'helpSeeAlso'
#

CREATE TABLE helpSeeAlso (
  seeAlsoId int(11) NOT NULL default '0',
  helpId int(11) default NULL,
  namespace varchar(30) default NULL,
  PRIMARY KEY  (seeAlsoId)
) TYPE=MyISAM;

#
# Dumping data for table 'helpSeeAlso'
#

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

#
# Table structure for table 'images'
#

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

#
# Dumping data for table 'images'
#


#
# Table structure for table 'incrementer'
#

CREATE TABLE incrementer (
  incrementerId varchar(50) NOT NULL default '',
  nextValue int(11) NOT NULL default '1',
  PRIMARY KEY  (incrementerId)
) TYPE=MyISAM;

#
# Dumping data for table 'incrementer'
#

INSERT INTO incrementer VALUES ('groupId',26);
INSERT INTO incrementer VALUES ('messageId',1);
INSERT INTO incrementer VALUES ('pageId',26);
INSERT INTO incrementer VALUES ('styleId',26);
INSERT INTO incrementer VALUES ('userId',26);
INSERT INTO incrementer VALUES ('widgetId',1);
INSERT INTO incrementer VALUES ('eventId',1);
INSERT INTO incrementer VALUES ('linkId',1);
INSERT INTO incrementer VALUES ('questionId',1);
INSERT INTO incrementer VALUES ('submissionId',1);
INSERT INTO incrementer VALUES ('recurringEventId',1);
INSERT INTO incrementer VALUES ('messageLogId',1);
INSERT INTO incrementer VALUES ('downloadId',1);
INSERT INTO incrementer VALUES ('imageId',1);

#
# Table structure for table 'international'
#

CREATE TABLE international (
  internationalId int(11) NOT NULL default '0',
  namespace varchar(30) NOT NULL default 'WebGUI',
  language varchar(30) NOT NULL default 'English',
  message text,
  PRIMARY KEY  (internationalId,namespace,language)
) TYPE=MyISAM;

#
# Dumping data for table 'international'
#

INSERT INTO international VALUES (367,'WebGUI','English','Expire After');
INSERT INTO international VALUES (1,'Article','Deutsch','Artikel');
INSERT INTO international VALUES (1,'Article','Dutch','Artikel');
INSERT INTO international VALUES (1,'Article','English','Article');
INSERT INTO international VALUES (1,'Article','Español','Artículo');
INSERT INTO international VALUES (1,'Article','Português','Artigo');
INSERT INTO international VALUES (1,'EventsCalendar','Dutch','Doorgaan naar gebeurtenis toevoegen?');
INSERT INTO international VALUES (1,'EventsCalendar','English','Proceed to add event?');
INSERT INTO international VALUES (1,'EventsCalendar','Português','Proseguir com a adição do evento?');
INSERT INTO international VALUES (1,'ExtraColumn','Deutsch','Extra Spalte');
INSERT INTO international VALUES (1,'ExtraColumn','Dutch','Extra kolom');
INSERT INTO international VALUES (1,'ExtraColumn','English','Extra Column');
INSERT INTO international VALUES (1,'ExtraColumn','Español','Columna Extra');
INSERT INTO international VALUES (1,'ExtraColumn','Português','Coluna extra');
INSERT INTO international VALUES (1,'FAQ','Dutch','Doorgaan naar vraag toevoegen?');
INSERT INTO international VALUES (1,'FAQ','English','Proceed to add question?');
INSERT INTO international VALUES (1,'FAQ','Português','Proseguir com a adição da questão?');
INSERT INTO international VALUES (1,'Item','English','Link URL');
INSERT INTO international VALUES (1,'LinkList','Deutsch','Tabulator');
INSERT INTO international VALUES (1,'LinkList','Dutch','Inspringen');
INSERT INTO international VALUES (1,'LinkList','English','Indent');
INSERT INTO international VALUES (1,'LinkList','Português','Destaque');
INSERT INTO international VALUES (1,'MessageBoard','Deutsch','Diskussionsforum hinzufügen');
INSERT INTO international VALUES (1,'MessageBoard','Dutch','Voeg berichten bord toe');
INSERT INTO international VALUES (1,'MessageBoard','English','Add Message Board');
INSERT INTO international VALUES (1,'MessageBoard','Español','Agregar Tabla de Mensages');
INSERT INTO international VALUES (1,'MessageBoard','Português','Adicionar quadro de mensagens');
INSERT INTO international VALUES (1,'Poll','Deutsch','Abstimmung');
INSERT INTO international VALUES (1,'Poll','Dutch','Stemming');
INSERT INTO international VALUES (1,'Poll','English','Poll');
INSERT INTO international VALUES (1,'Poll','Español','Encuesta');
INSERT INTO international VALUES (1,'Poll','Português','Sondagem');
INSERT INTO international VALUES (1,'SiteMap','Dutch','Doorgaan met link toevoegen?');
INSERT INTO international VALUES (1,'SiteMap','English','Add Site Map');
INSERT INTO international VALUES (1,'SiteMap','Português','Adicionar mapa do site');
INSERT INTO international VALUES (1,'SQLReport','Deutsch','SQL Bericht');
INSERT INTO international VALUES (1,'SQLReport','Dutch','SQL rapport');
INSERT INTO international VALUES (1,'SQLReport','English','SQL Report');
INSERT INTO international VALUES (1,'SQLReport','Español','Reporte SQL');
INSERT INTO international VALUES (1,'SQLReport','Português','Relatório SQL');
INSERT INTO international VALUES (1,'SyndicatedContent','Deutsch','URL zur RSS-Datei');
INSERT INTO international VALUES (1,'SyndicatedContent','Dutch','URL naar RSS bestand');
INSERT INTO international VALUES (1,'SyndicatedContent','English','URL to RSS File');
INSERT INTO international VALUES (1,'SyndicatedContent','Português','Ficheiro de URL para RSS');
INSERT INTO international VALUES (1,'UserSubmission','Dutch','Wie kan goedkeuren?');
INSERT INTO international VALUES (1,'UserSubmission','English','Who can approve?');
INSERT INTO international VALUES (1,'UserSubmission','Português','Quem pode aprovar?');
INSERT INTO international VALUES (1,'WebGUI','Deutsch','Inhalt hinzufügen...');
INSERT INTO international VALUES (1,'WebGUI','Dutch','Inhoud toevoegen...');
INSERT INTO international VALUES (1,'WebGUI','English','Add content...');
INSERT INTO international VALUES (1,'WebGUI','Español','Agregar Contenido ...');
INSERT INTO international VALUES (1,'WebGUI','Português','Adicionar conteudo...');
INSERT INTO international VALUES (2,'Article','Deutsch','Artikel hinzufügen');
INSERT INTO international VALUES (2,'Article','Dutch','Artikel toevoegen');
INSERT INTO international VALUES (2,'Article','English','Add Article');
INSERT INTO international VALUES (2,'Article','Español','Agregar Artículo');
INSERT INTO international VALUES (2,'Article','Português','Adicionar artigo');
INSERT INTO international VALUES (2,'EventsCalendar','Deutsch','Veranstaltungskalender');
INSERT INTO international VALUES (2,'EventsCalendar','Dutch','Evenementen kalender');
INSERT INTO international VALUES (2,'EventsCalendar','English','Events Calendar');
INSERT INTO international VALUES (2,'EventsCalendar','Español','Calendario de Eventos');
INSERT INTO international VALUES (2,'EventsCalendar','Português','Calendário de eventos');
INSERT INTO international VALUES (2,'ExtraColumn','Deutsch','Extra Spalte hinzufügen');
INSERT INTO international VALUES (2,'ExtraColumn','Dutch','Voeg extra kolom toe');
INSERT INTO international VALUES (2,'ExtraColumn','English','Add Extra Column');
INSERT INTO international VALUES (2,'ExtraColumn','Español','Agregar Columna Extra');
INSERT INTO international VALUES (2,'ExtraColumn','Português','Adicinar coluna extra');
INSERT INTO international VALUES (2,'FAQ','Deutsch','F.A.Q.');
INSERT INTO international VALUES (2,'FAQ','Dutch','FAQ');
INSERT INTO international VALUES (2,'FAQ','English','F.A.Q.');
INSERT INTO international VALUES (2,'FAQ','Español','F.A.Q.');
INSERT INTO international VALUES (2,'FAQ','Português','Perguntas mais frequentes');
INSERT INTO international VALUES (2,'Item','English','Attachment');
INSERT INTO international VALUES (2,'LinkList','Deutsch','Zeilenabstand');
INSERT INTO international VALUES (2,'LinkList','Dutch','Regel afstand');
INSERT INTO international VALUES (2,'LinkList','English','Line Spacing');
INSERT INTO international VALUES (2,'LinkList','Português','Espaço entre linhas');
INSERT INTO international VALUES (2,'MessageBoard','Deutsch','Diskussionsforum');
INSERT INTO international VALUES (2,'MessageBoard','Dutch','Berichten bord');
INSERT INTO international VALUES (2,'MessageBoard','English','Message Board');
INSERT INTO international VALUES (2,'MessageBoard','Español','Table de Mensages');
INSERT INTO international VALUES (2,'MessageBoard','Português','Quadro de mensagens');
INSERT INTO international VALUES (2,'Poll','Deutsch','Abstimmung hinzufügen');
INSERT INTO international VALUES (2,'Poll','Dutch','Stemming toevoegen');
INSERT INTO international VALUES (2,'Poll','English','Add Poll');
INSERT INTO international VALUES (2,'Poll','Español','Agregar Encuesta');
INSERT INTO international VALUES (2,'Poll','Português','Adicionar sondagem');
INSERT INTO international VALUES (2,'SiteMap','Dutch','Site map');
INSERT INTO international VALUES (2,'SiteMap','English','Site Map');
INSERT INTO international VALUES (2,'SiteMap','Português','Mapa do site');
INSERT INTO international VALUES (2,'SQLReport','Deutsch','SQL Bericht hinzufügen');
INSERT INTO international VALUES (2,'SQLReport','Dutch','SQL rapport toevoegen');
INSERT INTO international VALUES (2,'SQLReport','English','Add SQL Report');
INSERT INTO international VALUES (2,'SQLReport','Español','Agregar Reporte SQL');
INSERT INTO international VALUES (2,'SQLReport','Português','Adicionar relatório SQL');
INSERT INTO international VALUES (2,'SyndicatedContent','Deutsch','Clipping-Dienst');
INSERT INTO international VALUES (2,'SyndicatedContent','Dutch','Syndicated content');
INSERT INTO international VALUES (2,'SyndicatedContent','English','Syndicated Content');
INSERT INTO international VALUES (2,'SyndicatedContent','Português','Conteudo sindical');
INSERT INTO international VALUES (2,'UserSubmission','Deutsch','Wer kann Beiträge schreiben?');
INSERT INTO international VALUES (2,'UserSubmission','Dutch','Wie kan bijdragen?');
INSERT INTO international VALUES (2,'UserSubmission','English','Who can contribute?');
INSERT INTO international VALUES (2,'UserSubmission','Español','Quiénes pueden contribuir?');
INSERT INTO international VALUES (2,'UserSubmission','Português','Quem pode contribuir?');
INSERT INTO international VALUES (2,'WebGUI','Deutsch','Seite');
INSERT INTO international VALUES (2,'WebGUI','Dutch','Pagina');
INSERT INTO international VALUES (2,'WebGUI','English','Page');
INSERT INTO international VALUES (2,'WebGUI','Español','Página');
INSERT INTO international VALUES (2,'WebGUI','Português','Página');
INSERT INTO international VALUES (3,'Article','Deutsch','Start Datum');
INSERT INTO international VALUES (3,'Article','Dutch','Start datum');
INSERT INTO international VALUES (3,'Article','English','Start Date');
INSERT INTO international VALUES (3,'Article','Español','Fecha Inicio');
INSERT INTO international VALUES (3,'Article','Português','Data de inicio');
INSERT INTO international VALUES (3,'EventsCalendar','Deutsch','Veranstaltungskalender hinzufügen');
INSERT INTO international VALUES (3,'EventsCalendar','Dutch','Voeg evenementen kalender toe');
INSERT INTO international VALUES (3,'EventsCalendar','English','Add Events Calendar');
INSERT INTO international VALUES (3,'EventsCalendar','Español','Agregar Calendario de Eventos');
INSERT INTO international VALUES (3,'EventsCalendar','Português','Adicionar calendário de eventos');
INSERT INTO international VALUES (3,'ExtraColumn','Deutsch','Platzhalter');
INSERT INTO international VALUES (3,'ExtraColumn','Dutch','Tussenruimte');
INSERT INTO international VALUES (3,'ExtraColumn','English','Spacer');
INSERT INTO international VALUES (3,'ExtraColumn','Español','Espaciador');
INSERT INTO international VALUES (3,'ExtraColumn','Português','Espaçamento');
INSERT INTO international VALUES (3,'FAQ','Deutsch','F.A.Q. hinzufügen');
INSERT INTO international VALUES (3,'FAQ','Dutch','Voeg FAQ toe');
INSERT INTO international VALUES (3,'FAQ','English','Add F.A.Q.');
INSERT INTO international VALUES (3,'FAQ','Español','Agregar F.A.Q.');
INSERT INTO international VALUES (3,'FAQ','Português','Adicionar perguntas mais frequentes');
INSERT INTO international VALUES (3,'Item','English','Delete Attachment');
INSERT INTO international VALUES (3,'LinkList','Deutsch','In neuem Fenster öffnen?');
INSERT INTO international VALUES (3,'LinkList','Dutch','Open in nieuw venster?');
INSERT INTO international VALUES (3,'LinkList','English','Open in new window?');
INSERT INTO international VALUES (3,'LinkList','Português','Abrir numa nova janela?');
INSERT INTO international VALUES (3,'MessageBoard','Deutsch','Wer kann Beiträge schreiben?');
INSERT INTO international VALUES (3,'MessageBoard','Dutch','Wie kan posten');
INSERT INTO international VALUES (3,'MessageBoard','English','Who can post?');
INSERT INTO international VALUES (3,'MessageBoard','Español','Quienes pueden mandar?');
INSERT INTO international VALUES (3,'MessageBoard','Português','Quem pode colocar novas?');
INSERT INTO international VALUES (3,'Poll','Deutsch','Aktiv');
INSERT INTO international VALUES (3,'Poll','Dutch','Aktief');
INSERT INTO international VALUES (3,'Poll','English','Active');
INSERT INTO international VALUES (3,'Poll','Español','Activar');
INSERT INTO international VALUES (3,'Poll','Português','Activo');
INSERT INTO international VALUES (3,'SiteMap','Dutch','Op dit niveau beginnen?');
INSERT INTO international VALUES (3,'SiteMap','English','Starting from this level?');
INSERT INTO international VALUES (3,'SiteMap','Português','Iniciando neste nível?');
INSERT INTO international VALUES (3,'SQLReport','Deutsch','Schablone');
INSERT INTO international VALUES (3,'SQLReport','Dutch','Sjabloon');
INSERT INTO international VALUES (3,'SQLReport','English','Template');
INSERT INTO international VALUES (3,'SQLReport','Español','Modelo');
INSERT INTO international VALUES (3,'SQLReport','Português','Template');
INSERT INTO international VALUES (3,'SyndicatedContent','Deutsch','Clipping-Dienst hinzufügen');
INSERT INTO international VALUES (3,'SyndicatedContent','Dutch','Syndicated content toevoegen');
INSERT INTO international VALUES (3,'SyndicatedContent','English','Add Syndicated Content');
INSERT INTO international VALUES (3,'SyndicatedContent','Português','Adicionar conteudo sindical');
INSERT INTO international VALUES (3,'UserSubmission','Dutch','U heeft een nieuwe bijdrage om goed te keuren.');
INSERT INTO international VALUES (3,'UserSubmission','English','You have a new user submission to approve.');
INSERT INTO international VALUES (3,'UserSubmission','Português','Tem nova submissão para aprovar.');
INSERT INTO international VALUES (3,'WebGUI','Deutsch','Aus Zwischenablage einfügen...');
INSERT INTO international VALUES (3,'WebGUI','Dutch','Plakken van het klemboord...');
INSERT INTO international VALUES (3,'WebGUI','English','Paste from clipboard...');
INSERT INTO international VALUES (3,'WebGUI','Español','Pegar desde el Portapapeles...');
INSERT INTO international VALUES (3,'WebGUI','Português','Colar do clipboard...');
INSERT INTO international VALUES (4,'Article','Deutsch','Ende Datum');
INSERT INTO international VALUES (4,'Article','Dutch','Eind datum');
INSERT INTO international VALUES (4,'Article','English','End Date');
INSERT INTO international VALUES (4,'Article','Español','Fecha finalización');
INSERT INTO international VALUES (4,'Article','Português','Data de fim');
INSERT INTO international VALUES (4,'EventsCalendar','Deutsch','Einmaliges Ereignis');
INSERT INTO international VALUES (4,'EventsCalendar','Dutch','Gebeurt maar een keer.');
INSERT INTO international VALUES (4,'EventsCalendar','English','Happens only once.');
INSERT INTO international VALUES (4,'EventsCalendar','Español','Sucede solo una vez.');
INSERT INTO international VALUES (4,'EventsCalendar','Português','Apenas uma vez.');
INSERT INTO international VALUES (4,'ExtraColumn','Deutsch','Breite');
INSERT INTO international VALUES (4,'ExtraColumn','Dutch','Wijdte');
INSERT INTO international VALUES (4,'ExtraColumn','English','Width');
INSERT INTO international VALUES (4,'ExtraColumn','Español','Ancho');
INSERT INTO international VALUES (4,'ExtraColumn','Português','Largura');
INSERT INTO international VALUES (4,'FAQ','Deutsch','Frage hinzufügen');
INSERT INTO international VALUES (4,'FAQ','Dutch','Voeg vraag toe');
INSERT INTO international VALUES (4,'FAQ','English','Add Question');
INSERT INTO international VALUES (4,'FAQ','Español','Agregar Pregunta');
INSERT INTO international VALUES (4,'FAQ','Português','Adicionar questão');
INSERT INTO international VALUES (4,'Item','English','Item');
INSERT INTO international VALUES (4,'LinkList','Deutsch','Kugel');
INSERT INTO international VALUES (4,'LinkList','Dutch','Opsommingsteken');
INSERT INTO international VALUES (4,'LinkList','English','Bullet');
INSERT INTO international VALUES (4,'LinkList','Português','Marca');
INSERT INTO international VALUES (4,'MessageBoard','Deutsch','Beiträge pro Seite');
INSERT INTO international VALUES (4,'MessageBoard','Dutch','Berichten per pagina');
INSERT INTO international VALUES (4,'MessageBoard','English','Messages Per Page');
INSERT INTO international VALUES (4,'MessageBoard','Español','Mensages por página');
INSERT INTO international VALUES (4,'MessageBoard','Português','Mensagens por página');
INSERT INTO international VALUES (4,'Poll','Deutsch','Wer kann abstimmen?');
INSERT INTO international VALUES (4,'Poll','Dutch','Wie kan stemmen?');
INSERT INTO international VALUES (4,'Poll','English','Who can vote?');
INSERT INTO international VALUES (4,'Poll','Español','Quiénes pueden votar?');
INSERT INTO international VALUES (4,'Poll','Português','Quem pode votar?');
INSERT INTO international VALUES (4,'SiteMap','Dutch','Diepte niveau');
INSERT INTO international VALUES (4,'SiteMap','English','Depth To Traverse');
INSERT INTO international VALUES (4,'SiteMap','Português','profundidade a travessar');
INSERT INTO international VALUES (4,'SQLReport','Deutsch','Abfrage');
INSERT INTO international VALUES (4,'SQLReport','Dutch','Query');
INSERT INTO international VALUES (4,'SQLReport','English','Query');
INSERT INTO international VALUES (4,'SQLReport','Español','Consulta');
INSERT INTO international VALUES (4,'SQLReport','Português','Query');
INSERT INTO international VALUES (4,'SyndicatedContent','Deutsch','Clipping-Dienst bearbeiten');
INSERT INTO international VALUES (4,'SyndicatedContent','Dutch','Bewerk syndicated content');
INSERT INTO international VALUES (4,'SyndicatedContent','English','Edit Syndicated Content');
INSERT INTO international VALUES (4,'SyndicatedContent','Português','Modificar conteudo sindical');
INSERT INTO international VALUES (4,'UserSubmission','Dutch','Uw bijdrage is goedgekeurd.');
INSERT INTO international VALUES (4,'UserSubmission','English','Your submission has been approved.');
INSERT INTO international VALUES (4,'UserSubmission','Português','A sua submissão foi aprovada.');
INSERT INTO international VALUES (4,'WebGUI','Deutsch','Einstellungen verwalten');
INSERT INTO international VALUES (4,'WebGUI','Dutch','Beheer instellingen.');
INSERT INTO international VALUES (4,'WebGUI','English','Manage settings.');
INSERT INTO international VALUES (4,'WebGUI','Español','Configurar Opciones.');
INSERT INTO international VALUES (4,'WebGUI','Português','Organizar preferências.');
INSERT INTO international VALUES (5,'Article','Deutsch','Text');
INSERT INTO international VALUES (5,'Article','Dutch','Inhoud');
INSERT INTO international VALUES (5,'Article','English','Body');
INSERT INTO international VALUES (5,'Article','Español','Cuerpo');
INSERT INTO international VALUES (5,'Article','Português','Corpo');
INSERT INTO international VALUES (5,'EventsCalendar','Deutsch','Tag');
INSERT INTO international VALUES (5,'EventsCalendar','Dutch','Dag');
INSERT INTO international VALUES (5,'EventsCalendar','English','Day');
INSERT INTO international VALUES (5,'EventsCalendar','Español','Día');
INSERT INTO international VALUES (5,'EventsCalendar','Português','Dia');
INSERT INTO international VALUES (5,'ExtraColumn','Deutsch','StyleSheet Class');
INSERT INTO international VALUES (5,'ExtraColumn','Dutch','Style sheet klasse (class)');
INSERT INTO international VALUES (5,'ExtraColumn','English','StyleSheet Class');
INSERT INTO international VALUES (5,'ExtraColumn','Español','Clase StyleSheet');
INSERT INTO international VALUES (5,'ExtraColumn','Português','StyleSheet Class');
INSERT INTO international VALUES (5,'FAQ','Deutsch','Frage');
INSERT INTO international VALUES (5,'FAQ','Dutch','Vraag');
INSERT INTO international VALUES (5,'FAQ','English','Question');
INSERT INTO international VALUES (5,'FAQ','Español','Pregunta');
INSERT INTO international VALUES (5,'FAQ','Português','Questão');
INSERT INTO international VALUES (5,'Item','English','Download Attachment');
INSERT INTO international VALUES (5,'LinkList','Dutch','Doorgaan met link toevoegen?');
INSERT INTO international VALUES (5,'LinkList','English','Proceed to add link?');
INSERT INTO international VALUES (5,'LinkList','Português','Proseguir com a adição do hiperlink?');
INSERT INTO international VALUES (5,'MessageBoard','Deutsch','Timeout zum bearbeiten');
INSERT INTO international VALUES (5,'MessageBoard','Dutch','Bewerk timeout');
INSERT INTO international VALUES (5,'MessageBoard','English','Edit Timeout');
INSERT INTO international VALUES (5,'MessageBoard','Español','Timeout de edición');
INSERT INTO international VALUES (5,'MessageBoard','Português','Modificar Timeout');
INSERT INTO international VALUES (5,'Poll','Deutsch','Breite der Grafik');
INSERT INTO international VALUES (5,'Poll','Dutch','Grafiek wijdte');
INSERT INTO international VALUES (5,'Poll','English','Graph Width');
INSERT INTO international VALUES (5,'Poll','Español','Ancho del gráfico');
INSERT INTO international VALUES (5,'Poll','Português','Largura do gráfico');
INSERT INTO international VALUES (5,'SiteMap','Dutch','Bewerk site map');
INSERT INTO international VALUES (5,'SiteMap','English','Edit Site Map');
INSERT INTO international VALUES (5,'SiteMap','Português','Editar mapa do site');
INSERT INTO international VALUES (5,'SQLReport','Deutsch','DSN (Data Source Name)');
INSERT INTO international VALUES (5,'SQLReport','Dutch','DSN');
INSERT INTO international VALUES (5,'SQLReport','English','DSN');
INSERT INTO international VALUES (5,'SQLReport','Español','DSN');
INSERT INTO international VALUES (5,'SQLReport','Português','DSN');
INSERT INTO international VALUES (5,'SyndicatedContent','Deutsch','zuletzt geholt');
INSERT INTO international VALUES (5,'SyndicatedContent','Dutch','Laatste keer bijgewerkt');
INSERT INTO international VALUES (5,'SyndicatedContent','English','Last Fetched');
INSERT INTO international VALUES (5,'SyndicatedContent','Português','Ultima retirada');
INSERT INTO international VALUES (5,'UserSubmission','Dutch','Uw bijdrage is afgekeurd.');
INSERT INTO international VALUES (5,'UserSubmission','English','Your submission has been denied.');
INSERT INTO international VALUES (5,'UserSubmission','Português','A sua submissão não foi aprovada.');
INSERT INTO international VALUES (5,'WebGUI','Deutsch','Gruppen verwalten');
INSERT INTO international VALUES (5,'WebGUI','Dutch','Beheer groepen.');
INSERT INTO international VALUES (5,'WebGUI','English','Manage groups.');
INSERT INTO international VALUES (5,'WebGUI','Español','Configurar Grupos.');
INSERT INTO international VALUES (5,'WebGUI','Português','Organizar grupos.');
INSERT INTO international VALUES (6,'Article','Deutsch','Bild');
INSERT INTO international VALUES (6,'Article','Dutch','Plaatje');
INSERT INTO international VALUES (6,'Article','English','Image');
INSERT INTO international VALUES (6,'Article','Español','Imagen');
INSERT INTO international VALUES (6,'Article','Português','Imagem');
INSERT INTO international VALUES (6,'EventsCalendar','Deutsch','Woche');
INSERT INTO international VALUES (6,'EventsCalendar','Dutch','Week');
INSERT INTO international VALUES (6,'EventsCalendar','English','Week');
INSERT INTO international VALUES (6,'EventsCalendar','Español','Semana');
INSERT INTO international VALUES (6,'EventsCalendar','Português','Semana');
INSERT INTO international VALUES (6,'ExtraColumn','Deutsch','Extra Spalte bearbeiten');
INSERT INTO international VALUES (6,'ExtraColumn','Dutch','Bewerk extra kolom');
INSERT INTO international VALUES (6,'ExtraColumn','English','Edit Extra Column');
INSERT INTO international VALUES (6,'ExtraColumn','Español','Editar Columna Extra');
INSERT INTO international VALUES (6,'ExtraColumn','Português','Modificar coluna extra');
INSERT INTO international VALUES (6,'FAQ','Deutsch','Antwort');
INSERT INTO international VALUES (6,'FAQ','Dutch','Andwoord');
INSERT INTO international VALUES (6,'FAQ','English','Answer');
INSERT INTO international VALUES (6,'FAQ','Español','Respuesta');
INSERT INTO international VALUES (6,'FAQ','Português','Resposta');
INSERT INTO international VALUES (6,'LinkList','Deutsch','Link Liste');
INSERT INTO international VALUES (6,'LinkList','Dutch','Link lijst');
INSERT INTO international VALUES (6,'LinkList','English','Link List');
INSERT INTO international VALUES (6,'LinkList','Español','Lista de Enlaces');
INSERT INTO international VALUES (6,'LinkList','Português','Lista de hiperlinks');
INSERT INTO international VALUES (6,'MessageBoard','Deutsch','Diskussionsforum bearbeiten');
INSERT INTO international VALUES (6,'MessageBoard','Dutch','Bewerk berichten bord');
INSERT INTO international VALUES (6,'MessageBoard','English','Edit Message Board');
INSERT INTO international VALUES (6,'MessageBoard','Español','Editar Tabla de Mensages');
INSERT INTO international VALUES (6,'MessageBoard','Português','Modificar quadro de mensagens');
INSERT INTO international VALUES (6,'Poll','Deutsch','Frage');
INSERT INTO international VALUES (6,'Poll','Dutch','Vraag');
INSERT INTO international VALUES (6,'Poll','English','Question');
INSERT INTO international VALUES (6,'Poll','Español','Pregunta');
INSERT INTO international VALUES (6,'Poll','Português','Questão');
INSERT INTO international VALUES (6,'SiteMap','Dutch','Inspringen');
INSERT INTO international VALUES (6,'SiteMap','English','Indent');
INSERT INTO international VALUES (6,'SiteMap','Português','Destaque');
INSERT INTO international VALUES (6,'SQLReport','Deutsch','Datenbankbenutzer');
INSERT INTO international VALUES (6,'SQLReport','Dutch','Database gebruiker');
INSERT INTO international VALUES (6,'SQLReport','English','Database User');
INSERT INTO international VALUES (6,'SQLReport','Español','Usuario de la Base de Datos');
INSERT INTO international VALUES (6,'SQLReport','Português','User da base de dados');
INSERT INTO international VALUES (6,'SyndicatedContent','Deutsch','Aktueller Inhalt');
INSERT INTO international VALUES (6,'SyndicatedContent','Dutch','Huidige inhoud');
INSERT INTO international VALUES (6,'SyndicatedContent','English','Current Content');
INSERT INTO international VALUES (6,'SyndicatedContent','Português','Conteudo actual');
INSERT INTO international VALUES (6,'UserSubmission','Deutsch','Beiträge pro Seite');
INSERT INTO international VALUES (6,'UserSubmission','Dutch','Bijdrages per pagina');
INSERT INTO international VALUES (6,'UserSubmission','English','Submissions Per Page');
INSERT INTO international VALUES (6,'UserSubmission','Español','Contribuciones por página');
INSERT INTO international VALUES (6,'UserSubmission','Português','Submissões por página');
INSERT INTO international VALUES (6,'WebGUI','Deutsch','Stile verwalten');
INSERT INTO international VALUES (6,'WebGUI','Dutch','Beheer stijlen.');
INSERT INTO international VALUES (6,'WebGUI','English','Manage styles.');
INSERT INTO international VALUES (6,'WebGUI','Español','Configurar Estilos');
INSERT INTO international VALUES (6,'WebGUI','Português','Organizar estilos.');
INSERT INTO international VALUES (7,'Article','Deutsch','Link Titel');
INSERT INTO international VALUES (7,'Article','Dutch','Link titel');
INSERT INTO international VALUES (7,'Article','English','Link Title');
INSERT INTO international VALUES (7,'Article','Español','Link Título');
INSERT INTO international VALUES (7,'Article','Português','Titulo da hiperlink');
INSERT INTO international VALUES (7,'EventsCalendar','Deutsch','Termin hinzufügen');
INSERT INTO international VALUES (7,'EventsCalendar','Dutch','Evenement toevoegen');
INSERT INTO international VALUES (7,'EventsCalendar','English','Add Event');
INSERT INTO international VALUES (7,'EventsCalendar','Español','Agregar Evento');
INSERT INTO international VALUES (7,'EventsCalendar','Português','Adicionar evento');
INSERT INTO international VALUES (7,'FAQ','Deutsch','Sind Sie sicher, dass Sie diese Frage löschen wollen?');
INSERT INTO international VALUES (7,'FAQ','Dutch','Weet u zeker dat u deze vraag wilt verwijderen?');
INSERT INTO international VALUES (7,'FAQ','English','Are you certain that you want to delete this question?');
INSERT INTO international VALUES (7,'FAQ','Español','Está seguro de querer eliminar ésta pregunta?');
INSERT INTO international VALUES (7,'FAQ','Português','Tem a certeza que quer apagar esta questão?');
INSERT INTO international VALUES (7,'LinkList','Deutsch','Link hinzufügen');
INSERT INTO international VALUES (7,'LinkList','Dutch','Voeg link toe');
INSERT INTO international VALUES (7,'LinkList','English','Add Link');
INSERT INTO international VALUES (7,'LinkList','Español','Agregar Enlace');
INSERT INTO international VALUES (7,'LinkList','Português','Adicionar hiperlink');
INSERT INTO international VALUES (7,'MessageBoard','Deutsch','Autor:');
INSERT INTO international VALUES (7,'MessageBoard','Dutch','Naam:');
INSERT INTO international VALUES (7,'MessageBoard','English','Author:');
INSERT INTO international VALUES (7,'MessageBoard','Español','Autor:');
INSERT INTO international VALUES (7,'MessageBoard','Português','Autor:');
INSERT INTO international VALUES (7,'Poll','Deutsch','Antworten');
INSERT INTO international VALUES (7,'Poll','Dutch','Antwoorden');
INSERT INTO international VALUES (7,'Poll','English','Answers');
INSERT INTO international VALUES (7,'Poll','Español','Respuestas');
INSERT INTO international VALUES (7,'Poll','Português','Respostas');
INSERT INTO international VALUES (7,'SiteMap','Dutch','Opsommingsteken');
INSERT INTO international VALUES (7,'SiteMap','English','Bullet');
INSERT INTO international VALUES (7,'SiteMap','Português','Marca');
INSERT INTO international VALUES (7,'SQLReport','Deutsch','Datenbankpasswort');
INSERT INTO international VALUES (7,'SQLReport','Dutch','Database wachtwoord');
INSERT INTO international VALUES (7,'SQLReport','English','Database Password');
INSERT INTO international VALUES (7,'SQLReport','Español','Password de la Base de Datos');
INSERT INTO international VALUES (7,'SQLReport','Português','Password da base de dados');
INSERT INTO international VALUES (7,'UserSubmission','Deutsch','Erlaubt');
INSERT INTO international VALUES (7,'UserSubmission','Dutch','Goedgekeurd');
INSERT INTO international VALUES (7,'UserSubmission','English','Approved');
INSERT INTO international VALUES (7,'UserSubmission','Español','Aprobado');
INSERT INTO international VALUES (7,'UserSubmission','Português','Aprovado');
INSERT INTO international VALUES (7,'WebGUI','Deutsch','Benutzer verwalten');
INSERT INTO international VALUES (7,'WebGUI','Dutch','Beheer gebruikers');
INSERT INTO international VALUES (7,'WebGUI','English','Manage users.');
INSERT INTO international VALUES (7,'WebGUI','Español','Configurar Usuarios');
INSERT INTO international VALUES (7,'WebGUI','Português','Organizar utilizadores.');
INSERT INTO international VALUES (8,'Article','Deutsch','Link URL');
INSERT INTO international VALUES (8,'Article','Dutch','Link URL');
INSERT INTO international VALUES (8,'Article','English','Link URL');
INSERT INTO international VALUES (8,'Article','Español','Link URL');
INSERT INTO international VALUES (8,'Article','Português','URL da hiperlink');
INSERT INTO international VALUES (8,'EventsCalendar','Deutsch','Wiederholt sich');
INSERT INTO international VALUES (8,'EventsCalendar','Dutch','Herhaalt elke');
INSERT INTO international VALUES (8,'EventsCalendar','English','Recurs every');
INSERT INTO international VALUES (8,'EventsCalendar','Español','Se repite cada');
INSERT INTO international VALUES (8,'EventsCalendar','Português','Repetição');
INSERT INTO international VALUES (8,'FAQ','Deutsch','F.A.Q. bearbeiten');
INSERT INTO international VALUES (8,'FAQ','Dutch','Bewerk FAQ');
INSERT INTO international VALUES (8,'FAQ','English','Edit F.A.Q.');
INSERT INTO international VALUES (8,'FAQ','Español','Editar F.A.Q.');
INSERT INTO international VALUES (8,'FAQ','Português','Modificar perguntas mais frequentes');
INSERT INTO international VALUES (8,'LinkList','Deutsch','URL');
INSERT INTO international VALUES (8,'LinkList','Dutch','URL');
INSERT INTO international VALUES (8,'LinkList','English','URL');
INSERT INTO international VALUES (8,'LinkList','Español','URL');
INSERT INTO international VALUES (8,'LinkList','Português','URL');
INSERT INTO international VALUES (8,'MessageBoard','Deutsch','Datum:');
INSERT INTO international VALUES (8,'MessageBoard','Dutch','Datum:');
INSERT INTO international VALUES (8,'MessageBoard','English','Date:');
INSERT INTO international VALUES (8,'MessageBoard','Español','Fecha:');
INSERT INTO international VALUES (8,'MessageBoard','Português','Data:');
INSERT INTO international VALUES (8,'Poll','Deutsch','(Eine Antwort pro Zeile. Bitte nicht mehr als 20 verschiedene Antworten)');
INSERT INTO international VALUES (8,'Poll','Dutch','(Enter een antwoord per lijn. Niet meer dan 20.)');
INSERT INTO international VALUES (8,'Poll','English','(Enter one answer per line. No more than 20.)');
INSERT INTO international VALUES (8,'Poll','Español','(Ingrese una por línea. No más de 20)');
INSERT INTO international VALUES (8,'Poll','Português','(Introduza uma resposta por linha. Não passe das 20.)');
INSERT INTO international VALUES (8,'SiteMap','Dutch','Regel afstand');
INSERT INTO international VALUES (8,'SiteMap','English','Line Spacing');
INSERT INTO international VALUES (8,'SiteMap','Português','Espaçamento de linha');
INSERT INTO international VALUES (8,'SQLReport','Deutsch','SQL Bericht bearbeiten');
INSERT INTO international VALUES (8,'SQLReport','Dutch','Bewerk SQL rapport');
INSERT INTO international VALUES (8,'SQLReport','English','Edit SQL Report');
INSERT INTO international VALUES (8,'SQLReport','Español','Editar Reporte SQL');
INSERT INTO international VALUES (8,'SQLReport','Português','Modificar o relaório SQL');
INSERT INTO international VALUES (8,'UserSubmission','Deutsch','Verboten');
INSERT INTO international VALUES (8,'UserSubmission','Dutch','Afgekeurd');
INSERT INTO international VALUES (8,'UserSubmission','English','Denied');
INSERT INTO international VALUES (8,'UserSubmission','Español','Denegado');
INSERT INTO international VALUES (8,'UserSubmission','Português','Negado');
INSERT INTO international VALUES (8,'WebGUI','Deutsch','\"Seite nicht gefunden\" anschauen');
INSERT INTO international VALUES (8,'WebGUI','Dutch','Bekijk \'pagina niet gevonden\'.');
INSERT INTO international VALUES (8,'WebGUI','English','View page not found.');
INSERT INTO international VALUES (8,'WebGUI','Español','Ver Página No Encontrada');
INSERT INTO international VALUES (8,'WebGUI','Português','Ver página não encontrada.');
INSERT INTO international VALUES (9,'Article','Deutsch','Dateianhang');
INSERT INTO international VALUES (9,'Article','Dutch','Bijlage');
INSERT INTO international VALUES (9,'Article','English','Attachment');
INSERT INTO international VALUES (9,'Article','Español','Adjuntar');
INSERT INTO international VALUES (9,'Article','Português','Anexar');
INSERT INTO international VALUES (9,'EventsCalendar','Deutsch','bis');
INSERT INTO international VALUES (9,'EventsCalendar','Dutch','Tot');
INSERT INTO international VALUES (9,'EventsCalendar','English','until');
INSERT INTO international VALUES (9,'EventsCalendar','Español','hasta');
INSERT INTO international VALUES (9,'EventsCalendar','Português','até');
INSERT INTO international VALUES (9,'FAQ','Deutsch','Neue Frage hinzufügen');
INSERT INTO international VALUES (9,'FAQ','Dutch','Voeg een nieuwe vraag toe');
INSERT INTO international VALUES (9,'FAQ','English','Add a new question.');
INSERT INTO international VALUES (9,'FAQ','Español','Agregar nueva pregunta.');
INSERT INTO international VALUES (9,'FAQ','Português','Adicionar nova questão.');
INSERT INTO international VALUES (9,'LinkList','Deutsch','Sind Sie sicher, dass Sie diesen Link löschen wollen?');
INSERT INTO international VALUES (9,'LinkList','Dutch','Weet u zeker dat u deze link wilt verwijderen?');
INSERT INTO international VALUES (9,'LinkList','English','Are you certain that you want to delete this link?');
INSERT INTO international VALUES (9,'LinkList','Español','Está seguro de querer eliminar éste enlace?');
INSERT INTO international VALUES (9,'LinkList','Português','Tem a certeza que quer apagar esta hiperlink?');
INSERT INTO international VALUES (9,'MessageBoard','Deutsch','Beitrags ID:');
INSERT INTO international VALUES (9,'MessageBoard','Dutch','Bericht ID:');
INSERT INTO international VALUES (9,'MessageBoard','English','Message ID:');
INSERT INTO international VALUES (9,'MessageBoard','Español','ID del mensage:');
INSERT INTO international VALUES (9,'MessageBoard','Português','ID da mensagem:');
INSERT INTO international VALUES (9,'Poll','Deutsch','Abstimmung bearbeiten');
INSERT INTO international VALUES (9,'Poll','Dutch','Bewerk stemming');
INSERT INTO international VALUES (9,'Poll','English','Edit Poll');
INSERT INTO international VALUES (9,'Poll','Español','Editar Encuesta');
INSERT INTO international VALUES (9,'Poll','Português','Modificar sondagem');
INSERT INTO international VALUES (9,'SQLReport','Deutsch','Fehler: Die DSN besitzt das falsche Format.');
INSERT INTO international VALUES (9,'SQLReport','Dutch','Fout: De ingevoerde DSN is van een verkeerd formaat.');
INSERT INTO international VALUES (9,'SQLReport','English','Error: The DSN specified is of an improper format.');
INSERT INTO international VALUES (9,'SQLReport','Español','Error: El DSN especificado está en un formato incorrecto.');
INSERT INTO international VALUES (9,'SQLReport','Português','Erro: O DSN especificado tem um formato impróprio.');
INSERT INTO international VALUES (9,'UserSubmission','Deutsch','Ausstehend');
INSERT INTO international VALUES (9,'UserSubmission','Dutch','Lopend');
INSERT INTO international VALUES (9,'UserSubmission','English','Pending');
INSERT INTO international VALUES (9,'UserSubmission','Español','Pendiente');
INSERT INTO international VALUES (9,'UserSubmission','Português','Pendente');
INSERT INTO international VALUES (9,'WebGUI','Deutsch','Zwischenablage anschauen');
INSERT INTO international VALUES (9,'WebGUI','Dutch','Bekijk klemboord.');
INSERT INTO international VALUES (9,'WebGUI','English','View clipboard.');
INSERT INTO international VALUES (9,'WebGUI','Español','Ver Portapapeles');
INSERT INTO international VALUES (9,'WebGUI','Português','Ver o clipboard.');
INSERT INTO international VALUES (10,'Article','Deutsch','Carriage Return beachten?');
INSERT INTO international VALUES (10,'Article','Dutch','Enter converteren?');
INSERT INTO international VALUES (10,'Article','English','Convert carriage returns?');
INSERT INTO international VALUES (10,'Article','Español','Convertir saltos de carro?');
INSERT INTO international VALUES (10,'Article','Português','Converter o caracter de retorno (CR) ?');
INSERT INTO international VALUES (10,'EventsCalendar','Deutsch','Sind Sie sicher, dass Sie diesen Termin');
INSERT INTO international VALUES (10,'EventsCalendar','Dutch','Weet u zeker dat u dit evenement wilt verwijderen?');
INSERT INTO international VALUES (10,'EventsCalendar','English','Are you certain that you want to delete this event');
INSERT INTO international VALUES (10,'EventsCalendar','Español','Está segugo de querer eliminar éste evento');
INSERT INTO international VALUES (10,'EventsCalendar','Português','Tem a certeza que quer apagar este evento?');
INSERT INTO international VALUES (10,'FAQ','Deutsch','Frage bearbeiten');
INSERT INTO international VALUES (10,'FAQ','Dutch','Bewerk vraag');
INSERT INTO international VALUES (10,'FAQ','English','Edit Question');
INSERT INTO international VALUES (10,'FAQ','Español','Editar Pregunta');
INSERT INTO international VALUES (10,'FAQ','Português','Modificar questão');
INSERT INTO international VALUES (10,'LinkList','Deutsch','Link Liste bearbeiten');
INSERT INTO international VALUES (10,'LinkList','Dutch','Bewerk link lijst');
INSERT INTO international VALUES (10,'LinkList','English','Edit Link List');
INSERT INTO international VALUES (10,'LinkList','Español','Editar Lista de Enlaces');
INSERT INTO international VALUES (10,'LinkList','Português','Modificar lista de hiperlinks');
INSERT INTO international VALUES (10,'MessageBoard','Deutsch','Vorherige Diskussion');
INSERT INTO international VALUES (10,'MessageBoard','Dutch','Vorige thread');
INSERT INTO international VALUES (10,'MessageBoard','English','Previous Thread');
INSERT INTO international VALUES (10,'MessageBoard','Español','Anterior');
INSERT INTO international VALUES (10,'MessageBoard','Português','Anterior');
INSERT INTO international VALUES (10,'Poll','Dutch','Reset stemmen');
INSERT INTO international VALUES (10,'Poll','English','Reset votes.');
INSERT INTO international VALUES (10,'Poll','Português','Reinicializar os votos.');
INSERT INTO international VALUES (10,'SQLReport','Deutsch','Fehler: Das SQL-Statement ist im falschen Format.');
INSERT INTO international VALUES (10,'SQLReport','Dutch','Fout: De ingevoerde SQL instructie is van een verkeerd formaat.');
INSERT INTO international VALUES (10,'SQLReport','English','Error: The SQL specified is of an improper format.');
INSERT INTO international VALUES (10,'SQLReport','Español','Error: El SQL especificado está en un formato incorrecto.');
INSERT INTO international VALUES (10,'SQLReport','Português','Erro: O SQL especificado tem um formato impróprio.');
INSERT INTO international VALUES (10,'UserSubmission','Deutsch','Standard status');
INSERT INTO international VALUES (10,'UserSubmission','Dutch','Standaard status');
INSERT INTO international VALUES (10,'UserSubmission','English','Default Status');
INSERT INTO international VALUES (10,'UserSubmission','Español','Estado por defecto');
INSERT INTO international VALUES (10,'UserSubmission','Português','Estado por defeito');
INSERT INTO international VALUES (10,'WebGUI','Deutsch','Mülleimer anschauen');
INSERT INTO international VALUES (10,'WebGUI','Dutch','Bekijk prullenbak.');
INSERT INTO international VALUES (10,'WebGUI','English','View trash.');
INSERT INTO international VALUES (10,'WebGUI','Español','Ver Papelera');
INSERT INTO international VALUES (10,'WebGUI','Português','Ver o caixote do lixo.');
INSERT INTO international VALUES (11,'Article','Deutsch','(Bitte anklicken, falls Sie nicht &lt;br&gt; in Ihrem Text hinzufügen.)');
INSERT INTO international VALUES (11,'Article','Dutch','(Vink aan als u geen &lt;br&gt; manueel gebruikt.)');
INSERT INTO international VALUES (11,'Article','English','(Check if you aren\'t adding &lt;br&gt; manually.)');
INSERT INTO international VALUES (11,'Article','Español','(marque si no está agregando &lt;br&gt; manualmente.)');
INSERT INTO international VALUES (11,'Article','Português','(escolher se não adicionar &lt;br&gt; manualmente.)');
INSERT INTO international VALUES (11,'EventsCalendar','Deutsch','<b>und</b> alle seine Wiederholungen löschen wollen?');
INSERT INTO international VALUES (11,'EventsCalendar','Dutch','<b> en</b> alle herhaalde evenementen');
INSERT INTO international VALUES (11,'EventsCalendar','English','<b>and</b> all of its recurring events');
INSERT INTO international VALUES (11,'EventsCalendar','Español','<b>y</b> todos las recurrencias del mismo');
INSERT INTO international VALUES (11,'EventsCalendar','Português','<b>e</b> todos os recurrentes');
INSERT INTO international VALUES (11,'LinkList','Deutsch','Link Liste hinzufügen');
INSERT INTO international VALUES (11,'LinkList','Dutch','Voeg link lijst toe');
INSERT INTO international VALUES (11,'LinkList','English','Add Link List');
INSERT INTO international VALUES (11,'LinkList','Español','Agregar Lista de Enlaces');
INSERT INTO international VALUES (11,'LinkList','Português','Adicionar lista de hiperlinks');
INSERT INTO international VALUES (11,'MessageBoard','Deutsch','Zurück zur Beitragsliste');
INSERT INTO international VALUES (11,'MessageBoard','Dutch','Terug naar berichten lijst');
INSERT INTO international VALUES (11,'MessageBoard','English','Back To Message List');
INSERT INTO international VALUES (11,'MessageBoard','Español','Volver a la Lista de Mensages');
INSERT INTO international VALUES (11,'MessageBoard','Português','Voltar á lista de mensagens');
INSERT INTO international VALUES (11,'SQLReport','Deutsch','Fehler: Es gab ein Problem mit der Abfrage.');
INSERT INTO international VALUES (11,'SQLReport','Dutch','Fout: Er was een probleem met de query');
INSERT INTO international VALUES (11,'SQLReport','English','Error: There was a problem with the query.');
INSERT INTO international VALUES (11,'SQLReport','Español','Error: Hay un problema con la consulta.');
INSERT INTO international VALUES (11,'SQLReport','Português','Erro: Houve um problema com a query.');
INSERT INTO international VALUES (11,'UserSubmission','Deutsch','Beitrag hinzufügen');
INSERT INTO international VALUES (11,'UserSubmission','Dutch','Bijdrage toevoegen');
INSERT INTO international VALUES (11,'UserSubmission','English','Add Submission');
INSERT INTO international VALUES (11,'UserSubmission','Español','Contribuir');
INSERT INTO international VALUES (11,'UserSubmission','Português','Adicionar submissão');
INSERT INTO international VALUES (11,'WebGUI','Deutsch','Mülleimer leeren');
INSERT INTO international VALUES (11,'WebGUI','Dutch','Leeg prullenbak.');
INSERT INTO international VALUES (11,'WebGUI','English','Empy trash.');
INSERT INTO international VALUES (11,'WebGUI','Español','Vaciar Papelera');
INSERT INTO international VALUES (11,'WebGUI','Português','Esvaziar o caixote do lixo.');
INSERT INTO international VALUES (12,'Article','Deutsch','Artikel bearbeiten');
INSERT INTO international VALUES (12,'Article','Dutch','Bewerk artikel');
INSERT INTO international VALUES (12,'Article','English','Edit Article');
INSERT INTO international VALUES (12,'Article','Español','Editar Artículo');
INSERT INTO international VALUES (12,'Article','Português','Modificar artigo');
INSERT INTO international VALUES (12,'EventsCalendar','Deutsch','Veranstaltungskalender bearbeiten');
INSERT INTO international VALUES (12,'EventsCalendar','Dutch','Bewerk evenementen kalender');
INSERT INTO international VALUES (12,'EventsCalendar','English','Edit Events Calendar');
INSERT INTO international VALUES (12,'EventsCalendar','Español','Editar Calendario de Eventos');
INSERT INTO international VALUES (12,'EventsCalendar','Português','Modificar calendário de eventos');
INSERT INTO international VALUES (12,'LinkList','Deutsch','Link bearbeiten');
INSERT INTO international VALUES (12,'LinkList','Dutch','Bewerk link');
INSERT INTO international VALUES (12,'LinkList','English','Edit Link');
INSERT INTO international VALUES (12,'LinkList','Español','Editar Enlace');
INSERT INTO international VALUES (12,'LinkList','Português','Modificar hiperlink');
INSERT INTO international VALUES (12,'MessageBoard','Deutsch','Beitrag bearbeiten');
INSERT INTO international VALUES (12,'MessageBoard','Dutch','Bewerk bericht');
INSERT INTO international VALUES (12,'MessageBoard','English','Edit Message');
INSERT INTO international VALUES (12,'MessageBoard','Español','Editar mensage');
INSERT INTO international VALUES (12,'MessageBoard','Português','Modificar mensagem');
INSERT INTO international VALUES (12,'SQLReport','Deutsch','Fehler: Datenbankverbindung konnte nicht aufgebaut werden.');
INSERT INTO international VALUES (12,'SQLReport','Dutch','Fout: Kon niet met de database verbinden.');
INSERT INTO international VALUES (12,'SQLReport','English','Error: Could not connect to the database.');
INSERT INTO international VALUES (12,'SQLReport','Español','Error: No se puede conectar a la base de datos.');
INSERT INTO international VALUES (12,'SQLReport','Português','Erro: Não é possível ligar á base de dados.');
INSERT INTO international VALUES (12,'UserSubmission','Deutsch','(Bitte ausklicken, wenn Ihr Beitrag in HTML geschrieben ist)');
INSERT INTO international VALUES (12,'UserSubmission','Dutch','(niet aanvinken als u een HTML bijdrage levert.)');
INSERT INTO international VALUES (12,'UserSubmission','English','(Uncheck if you\'re writing an HTML submission.)');
INSERT INTO international VALUES (12,'UserSubmission','Español','(desmarque si está escribiendo la contribución en HTML.)');
INSERT INTO international VALUES (12,'UserSubmission','Português','(deixar em branco se a submissão for em HTML.)');
INSERT INTO international VALUES (12,'WebGUI','Deutsch','Administrationsmodus abschalten');
INSERT INTO international VALUES (12,'WebGUI','Dutch','Zet beheermode uit.');
INSERT INTO international VALUES (12,'WebGUI','English','Turn admin off.');
INSERT INTO international VALUES (12,'WebGUI','Español','Apagar Admin');
INSERT INTO international VALUES (12,'WebGUI','Português','Desligar o modo administrativo.');
INSERT INTO international VALUES (13,'Article','Deutsch','Löschen');
INSERT INTO international VALUES (13,'Article','Dutch','Verwijder');
INSERT INTO international VALUES (13,'Article','English','Delete');
INSERT INTO international VALUES (13,'Article','Español','Eliminar');
INSERT INTO international VALUES (13,'Article','Português','Apagar');
INSERT INTO international VALUES (13,'EventsCalendar','Deutsch','Veranstaltung bearbeiten');
INSERT INTO international VALUES (13,'EventsCalendar','Dutch','Bewerk evenement');
INSERT INTO international VALUES (13,'EventsCalendar','English','Edit Event');
INSERT INTO international VALUES (13,'EventsCalendar','Español','Editar Evento');
INSERT INTO international VALUES (13,'EventsCalendar','Português','Modificar evento');
INSERT INTO international VALUES (13,'LinkList','Deutsch','Neuen Link hinzufügen');
INSERT INTO international VALUES (13,'LinkList','Dutch','Voeg een nieuwe link toe.');
INSERT INTO international VALUES (13,'LinkList','English','Add a new link.');
INSERT INTO international VALUES (13,'LinkList','Español','Agregar nuevo Enlace');
INSERT INTO international VALUES (13,'LinkList','Português','Adicionar nova hiperlink.');
INSERT INTO international VALUES (13,'MessageBoard','Deutsch','Antwort schicken');
INSERT INTO international VALUES (13,'MessageBoard','Dutch','Post antwoord');
INSERT INTO international VALUES (13,'MessageBoard','English','Post Reply');
INSERT INTO international VALUES (13,'MessageBoard','Español','Responder');
INSERT INTO international VALUES (13,'MessageBoard','Português','Responder');
INSERT INTO international VALUES (13,'UserSubmission','Deutsch','Erstellungsdatum');
INSERT INTO international VALUES (13,'UserSubmission','Dutch','Invoerdatum');
INSERT INTO international VALUES (13,'UserSubmission','English','Date Submitted');
INSERT INTO international VALUES (13,'UserSubmission','Español','Fecha Contribución');
INSERT INTO international VALUES (13,'UserSubmission','Português','Data de submissão');
INSERT INTO international VALUES (13,'WebGUI','Deutsch','Hilfe anschauen');
INSERT INTO international VALUES (13,'WebGUI','Dutch','Laat help index zien.');
INSERT INTO international VALUES (13,'WebGUI','English','View help index.');
INSERT INTO international VALUES (13,'WebGUI','Español','Ver índice de Ayuda');
INSERT INTO international VALUES (13,'WebGUI','Português','Ver o indice da ajuda.');
INSERT INTO international VALUES (14,'Article','English','Align Image');
INSERT INTO international VALUES (14,'MessageBoard','Deutsch','Nächste Diskussion');
INSERT INTO international VALUES (14,'MessageBoard','Dutch','Volgende thread');
INSERT INTO international VALUES (14,'MessageBoard','English','Next Thread');
INSERT INTO international VALUES (14,'MessageBoard','Español','Siguiente');
INSERT INTO international VALUES (14,'MessageBoard','Português','Próxima');
INSERT INTO international VALUES (14,'UserSubmission','Deutsch','Status');
INSERT INTO international VALUES (14,'UserSubmission','Dutch','Status');
INSERT INTO international VALUES (14,'UserSubmission','English','Status');
INSERT INTO international VALUES (14,'UserSubmission','Español','Estado');
INSERT INTO international VALUES (14,'UserSubmission','Português','Estado');
INSERT INTO international VALUES (14,'WebGUI','Deutsch','Ausstehende Beiträge anschauen');
INSERT INTO international VALUES (14,'WebGUI','Dutch','Laat lopende aanmeldingen zien.');
INSERT INTO international VALUES (14,'WebGUI','English','View pending submissions.');
INSERT INTO international VALUES (14,'WebGUI','Español','Ver contribuciones pendientes.');
INSERT INTO international VALUES (14,'WebGUI','Português','Ver submissões pendentes.');
INSERT INTO international VALUES (15,'MessageBoard','Deutsch','Autor');
INSERT INTO international VALUES (15,'MessageBoard','Dutch','Afzender');
INSERT INTO international VALUES (15,'MessageBoard','English','Author');
INSERT INTO international VALUES (15,'MessageBoard','Español','Autor');
INSERT INTO international VALUES (15,'MessageBoard','Português','Autor');
INSERT INTO international VALUES (15,'UserSubmission','Deutsch','Bearbeiten/Löschen');
INSERT INTO international VALUES (15,'UserSubmission','Dutch','bewerk/Verwijder');
INSERT INTO international VALUES (15,'UserSubmission','English','Edit/Delete');
INSERT INTO international VALUES (15,'UserSubmission','Español','Editar/Eliminar');
INSERT INTO international VALUES (15,'UserSubmission','Português','Modificar/Apagar');
INSERT INTO international VALUES (15,'WebGUI','Deutsch','Januar');
INSERT INTO international VALUES (15,'WebGUI','Dutch','januari');
INSERT INTO international VALUES (15,'WebGUI','English','January');
INSERT INTO international VALUES (15,'WebGUI','Español','Enero');
INSERT INTO international VALUES (15,'WebGUI','Português','Janeiro');
INSERT INTO international VALUES (16,'MessageBoard','Deutsch','Datum');
INSERT INTO international VALUES (16,'MessageBoard','Dutch','Datum');
INSERT INTO international VALUES (16,'MessageBoard','English','Date');
INSERT INTO international VALUES (16,'MessageBoard','Español','Fecha');
INSERT INTO international VALUES (16,'MessageBoard','Português','Data');
INSERT INTO international VALUES (16,'UserSubmission','Deutsch','Ohne Titel');
INSERT INTO international VALUES (16,'UserSubmission','Dutch','Zonder titel');
INSERT INTO international VALUES (16,'UserSubmission','English','Untitled');
INSERT INTO international VALUES (16,'UserSubmission','Español','Sin título');
INSERT INTO international VALUES (16,'UserSubmission','Português','Sem titulo');
INSERT INTO international VALUES (16,'WebGUI','Deutsch','Februar');
INSERT INTO international VALUES (16,'WebGUI','Dutch','februari');
INSERT INTO international VALUES (16,'WebGUI','English','February');
INSERT INTO international VALUES (16,'WebGUI','Español','Febrero');
INSERT INTO international VALUES (16,'WebGUI','Português','Fevereiro');
INSERT INTO international VALUES (17,'MessageBoard','Deutsch','Neuen Beitrag schreiben');
INSERT INTO international VALUES (17,'MessageBoard','Dutch','Post nieuw bericht');
INSERT INTO international VALUES (17,'MessageBoard','English','Post New Message');
INSERT INTO international VALUES (17,'MessageBoard','Español','Mandar Nuevo Mensage');
INSERT INTO international VALUES (17,'MessageBoard','Português','Colocar nova mensagem');
INSERT INTO international VALUES (17,'UserSubmission','Deutsch','Sind Sie sicher, dass Sie diesen Beitrag löschen wollen?');
INSERT INTO international VALUES (17,'UserSubmission','Dutch','Weet u zeker dat u deze bijdrage wilt verwijderen?');
INSERT INTO international VALUES (17,'UserSubmission','English','Are you certain you wish to delete this submission?');
INSERT INTO international VALUES (17,'UserSubmission','Español','Está seguro de querer eliminar ésta contribución?');
INSERT INTO international VALUES (17,'UserSubmission','Português','Tem a certeza que quer apagar esta submissão?');
INSERT INTO international VALUES (17,'WebGUI','Deutsch','März');
INSERT INTO international VALUES (17,'WebGUI','Dutch','maart');
INSERT INTO international VALUES (17,'WebGUI','English','March');
INSERT INTO international VALUES (17,'WebGUI','Español','Marzo');
INSERT INTO international VALUES (17,'WebGUI','Português','Março');
INSERT INTO international VALUES (18,'MessageBoard','Deutsch','Diskussion begonnen');
INSERT INTO international VALUES (18,'MessageBoard','Dutch','Tread gestart');
INSERT INTO international VALUES (18,'MessageBoard','English','Thread Started');
INSERT INTO international VALUES (18,'MessageBoard','Español','Inicio');
INSERT INTO international VALUES (18,'MessageBoard','Português','Inicial');
INSERT INTO international VALUES (18,'UserSubmission','Deutsch','Benutzer Beitragssystem bearbeiten');
INSERT INTO international VALUES (18,'UserSubmission','Dutch','Bewerk gebruikers bijdrage systeem');
INSERT INTO international VALUES (18,'UserSubmission','English','Edit User Submission System');
INSERT INTO international VALUES (18,'UserSubmission','Español','Editar Sistema de Contribución de Usuarios');
INSERT INTO international VALUES (18,'UserSubmission','Português','Modificar sistema de submissão do utilizador');
INSERT INTO international VALUES (18,'WebGUI','Deutsch','April');
INSERT INTO international VALUES (18,'WebGUI','Dutch','april');
INSERT INTO international VALUES (18,'WebGUI','English','April');
INSERT INTO international VALUES (18,'WebGUI','Español','Abril');
INSERT INTO international VALUES (18,'WebGUI','Português','Abril');
INSERT INTO international VALUES (19,'MessageBoard','Deutsch','Antworten');
INSERT INTO international VALUES (19,'MessageBoard','Dutch','Antwoorden');
INSERT INTO international VALUES (19,'MessageBoard','English','Replies');
INSERT INTO international VALUES (19,'MessageBoard','Español','Respuestas');
INSERT INTO international VALUES (19,'MessageBoard','Português','Respostas');
INSERT INTO international VALUES (19,'UserSubmission','Deutsch','Beitrag bearbeiten');
INSERT INTO international VALUES (19,'UserSubmission','Dutch','Bewerk bijdrage');
INSERT INTO international VALUES (19,'UserSubmission','English','Edit Submission');
INSERT INTO international VALUES (19,'UserSubmission','Español','Editar Contribución');
INSERT INTO international VALUES (19,'UserSubmission','Português','Modificar submissão');
INSERT INTO international VALUES (19,'WebGUI','Deutsch','Mai');
INSERT INTO international VALUES (19,'WebGUI','Dutch','mei');
INSERT INTO international VALUES (19,'WebGUI','English','May');
INSERT INTO international VALUES (19,'WebGUI','Español','Mayo');
INSERT INTO international VALUES (19,'WebGUI','Português','Maio');
INSERT INTO international VALUES (20,'MessageBoard','Deutsch','Letzte Antwort');
INSERT INTO international VALUES (20,'MessageBoard','Dutch','Laatste antwoord');
INSERT INTO international VALUES (20,'MessageBoard','English','Last Reply');
INSERT INTO international VALUES (20,'MessageBoard','Español','Última respuesta');
INSERT INTO international VALUES (20,'MessageBoard','Português','Ultima resposta');
INSERT INTO international VALUES (20,'UserSubmission','Deutsch','Neuen Beitrag schreiben');
INSERT INTO international VALUES (20,'UserSubmission','Dutch','Post nieuwe bijdrage');
INSERT INTO international VALUES (20,'UserSubmission','English','Post New Submission');
INSERT INTO international VALUES (20,'UserSubmission','Español','Nueva Contribución');
INSERT INTO international VALUES (20,'UserSubmission','Português','Colocar nova submissão');
INSERT INTO international VALUES (20,'WebGUI','Deutsch','Juni');
INSERT INTO international VALUES (20,'WebGUI','Dutch','juni');
INSERT INTO international VALUES (20,'WebGUI','English','June');
INSERT INTO international VALUES (20,'WebGUI','Español','Junio');
INSERT INTO international VALUES (20,'WebGUI','Português','Junho');
INSERT INTO international VALUES (21,'UserSubmission','Deutsch','Erstellt von');
INSERT INTO international VALUES (21,'UserSubmission','Dutch','Ingevoerd door');
INSERT INTO international VALUES (21,'UserSubmission','English','Submitted By');
INSERT INTO international VALUES (21,'UserSubmission','Español','Contribuida por');
INSERT INTO international VALUES (21,'UserSubmission','Português','Submetido por');
INSERT INTO international VALUES (21,'WebGUI','Deutsch','Juli');
INSERT INTO international VALUES (21,'WebGUI','Dutch','juli');
INSERT INTO international VALUES (21,'WebGUI','English','July');
INSERT INTO international VALUES (21,'WebGUI','Español','Julio');
INSERT INTO international VALUES (21,'WebGUI','Português','Julho');
INSERT INTO international VALUES (22,'UserSubmission','Deutsch','Erstellt von:');
INSERT INTO international VALUES (22,'UserSubmission','Dutch','ingevoerd door:');
INSERT INTO international VALUES (22,'UserSubmission','English','Submitted By:');
INSERT INTO international VALUES (22,'UserSubmission','Español','Contribuida por:');
INSERT INTO international VALUES (22,'UserSubmission','Português','Submetido por:');
INSERT INTO international VALUES (22,'WebGUI','Deutsch','August');
INSERT INTO international VALUES (22,'WebGUI','Dutch','augustus');
INSERT INTO international VALUES (22,'WebGUI','English','August');
INSERT INTO international VALUES (22,'WebGUI','Español','Agosto');
INSERT INTO international VALUES (22,'WebGUI','Português','Agosto');
INSERT INTO international VALUES (23,'UserSubmission','Deutsch','Erstellungsdatum:');
INSERT INTO international VALUES (23,'UserSubmission','Dutch','Invoer datum:');
INSERT INTO international VALUES (23,'UserSubmission','English','Date Submitted:');
INSERT INTO international VALUES (23,'UserSubmission','Español','Fecha Contribución:');
INSERT INTO international VALUES (23,'UserSubmission','Português','Data de submissão:');
INSERT INTO international VALUES (23,'WebGUI','Deutsch','September');
INSERT INTO international VALUES (23,'WebGUI','Dutch','september');
INSERT INTO international VALUES (23,'WebGUI','English','September');
INSERT INTO international VALUES (23,'WebGUI','Español','Septiembre');
INSERT INTO international VALUES (23,'WebGUI','Português','Setembro');
INSERT INTO international VALUES (24,'UserSubmission','Deutsch','Erlauben');
INSERT INTO international VALUES (24,'UserSubmission','Dutch','Keur goed');
INSERT INTO international VALUES (24,'UserSubmission','English','Approve');
INSERT INTO international VALUES (24,'UserSubmission','Español','Aprobar');
INSERT INTO international VALUES (24,'UserSubmission','Português','Aprovar');
INSERT INTO international VALUES (24,'WebGUI','Deutsch','Oktober');
INSERT INTO international VALUES (24,'WebGUI','Dutch','oktober');
INSERT INTO international VALUES (24,'WebGUI','English','October');
INSERT INTO international VALUES (24,'WebGUI','Español','Octubre');
INSERT INTO international VALUES (24,'WebGUI','Português','Outubro');
INSERT INTO international VALUES (25,'UserSubmission','Deutsch','Ausstehend verlassen');
INSERT INTO international VALUES (25,'UserSubmission','Dutch','Laat in behandeling');
INSERT INTO international VALUES (25,'UserSubmission','English','Leave Pending');
INSERT INTO international VALUES (25,'UserSubmission','Español','Dejan pendiente');
INSERT INTO international VALUES (25,'UserSubmission','Português','Deixar pendente');
INSERT INTO international VALUES (25,'WebGUI','Deutsch','November');
INSERT INTO international VALUES (25,'WebGUI','Dutch','november');
INSERT INTO international VALUES (25,'WebGUI','English','November');
INSERT INTO international VALUES (25,'WebGUI','Español','Noviembre');
INSERT INTO international VALUES (25,'WebGUI','Português','Novembro');
INSERT INTO international VALUES (26,'UserSubmission','Deutsch','Verbieten');
INSERT INTO international VALUES (26,'UserSubmission','Dutch','Keur af');
INSERT INTO international VALUES (26,'UserSubmission','English','Deny');
INSERT INTO international VALUES (26,'UserSubmission','Español','Denegar');
INSERT INTO international VALUES (26,'UserSubmission','Português','Negar');
INSERT INTO international VALUES (26,'WebGUI','Deutsch','Dezember');
INSERT INTO international VALUES (26,'WebGUI','Dutch','december');
INSERT INTO international VALUES (26,'WebGUI','English','December');
INSERT INTO international VALUES (26,'WebGUI','Español','Diciembre');
INSERT INTO international VALUES (26,'WebGUI','Português','Dezembro');
INSERT INTO international VALUES (27,'UserSubmission','Deutsch','Bearbeiten');
INSERT INTO international VALUES (27,'UserSubmission','Dutch','Bewerk');
INSERT INTO international VALUES (27,'UserSubmission','English','Edit');
INSERT INTO international VALUES (27,'UserSubmission','Español','Editar');
INSERT INTO international VALUES (27,'UserSubmission','Português','Modificar');
INSERT INTO international VALUES (27,'WebGUI','Deutsch','Sonntag');
INSERT INTO international VALUES (27,'WebGUI','Dutch','zondag');
INSERT INTO international VALUES (27,'WebGUI','English','Sunday');
INSERT INTO international VALUES (27,'WebGUI','Español','Domingo');
INSERT INTO international VALUES (27,'WebGUI','Português','Domingo');
INSERT INTO international VALUES (28,'UserSubmission','Deutsch','Zurück zur Beitragsliste');
INSERT INTO international VALUES (28,'UserSubmission','Dutch','Ga terug naar bijdrage lijst');
INSERT INTO international VALUES (28,'UserSubmission','English','Return To Submissions List');
INSERT INTO international VALUES (28,'UserSubmission','Español','Regresar a lista de contribuciones');
INSERT INTO international VALUES (28,'UserSubmission','Português','Voltar á lista de submissões');
INSERT INTO international VALUES (28,'WebGUI','Deutsch','Montag');
INSERT INTO international VALUES (28,'WebGUI','Dutch','maandag');
INSERT INTO international VALUES (28,'WebGUI','English','Monday');
INSERT INTO international VALUES (28,'WebGUI','Español','Lunes');
INSERT INTO international VALUES (28,'WebGUI','Português','Segunda');
INSERT INTO international VALUES (29,'UserSubmission','Deutsch','Benutzer Beitragssystem');
INSERT INTO international VALUES (29,'UserSubmission','Dutch','Gebruikers bijdrage systeem');
INSERT INTO international VALUES (29,'UserSubmission','English','User Submission System');
INSERT INTO international VALUES (29,'UserSubmission','Español','Sistema de Contribución de Usuarios');
INSERT INTO international VALUES (29,'UserSubmission','Português','Sistema de submissão do utilizador');
INSERT INTO international VALUES (29,'WebGUI','Deutsch','Dienstag');
INSERT INTO international VALUES (29,'WebGUI','Dutch','dinsdag');
INSERT INTO international VALUES (29,'WebGUI','English','Tuesday');
INSERT INTO international VALUES (29,'WebGUI','Español','Martes');
INSERT INTO international VALUES (29,'WebGUI','Português','Terça');
INSERT INTO international VALUES (30,'UserSubmission','Deutsch','Benutzer Beitragssystem hinzufügen');
INSERT INTO international VALUES (30,'UserSubmission','Dutch','Gebruikers bijdrage systeem toevoegen');
INSERT INTO international VALUES (30,'UserSubmission','English','Add User Submission System');
INSERT INTO international VALUES (30,'UserSubmission','Español','Agregar Sistema de Contribución de Usuarios');
INSERT INTO international VALUES (30,'UserSubmission','Português','Adicionar sistema de submissão do utilizador');
INSERT INTO international VALUES (30,'WebGUI','Deutsch','Mittwoch');
INSERT INTO international VALUES (30,'WebGUI','Dutch','woensdag');
INSERT INTO international VALUES (30,'WebGUI','English','Wednesday');
INSERT INTO international VALUES (30,'WebGUI','Español','Miércoles');
INSERT INTO international VALUES (30,'WebGUI','Português','Quarta');
INSERT INTO international VALUES (31,'WebGUI','Deutsch','Donnerstag');
INSERT INTO international VALUES (31,'WebGUI','Dutch','donderdag');
INSERT INTO international VALUES (31,'WebGUI','English','Thursday');
INSERT INTO international VALUES (31,'WebGUI','Español','Jueves');
INSERT INTO international VALUES (31,'WebGUI','Português','Quinta');
INSERT INTO international VALUES (32,'WebGUI','Deutsch','Freitag');
INSERT INTO international VALUES (32,'WebGUI','Dutch','vrijdag');
INSERT INTO international VALUES (32,'WebGUI','English','Friday');
INSERT INTO international VALUES (32,'WebGUI','Español','Viernes');
INSERT INTO international VALUES (32,'WebGUI','Português','Sexta');
INSERT INTO international VALUES (33,'WebGUI','Deutsch','Samstag');
INSERT INTO international VALUES (33,'WebGUI','Dutch','zaterdag');
INSERT INTO international VALUES (33,'WebGUI','English','Saturday');
INSERT INTO international VALUES (33,'WebGUI','Español','Sabado');
INSERT INTO international VALUES (33,'WebGUI','Português','Sabado');
INSERT INTO international VALUES (34,'WebGUI','Deutsch','Datum setzen');
INSERT INTO international VALUES (34,'WebGUI','Dutch','Zet datum');
INSERT INTO international VALUES (34,'WebGUI','English','set date');
INSERT INTO international VALUES (34,'WebGUI','Español','fijar fecha');
INSERT INTO international VALUES (34,'WebGUI','Português','acertar a data');
INSERT INTO international VALUES (35,'WebGUI','Deutsch','Administrative Funktion');
INSERT INTO international VALUES (35,'WebGUI','Dutch','Administratieve functie');
INSERT INTO international VALUES (35,'WebGUI','English','Administrative Function');
INSERT INTO international VALUES (35,'WebGUI','Español','Funciones Administrativas');
INSERT INTO international VALUES (35,'WebGUI','Português','Função administrativa');
INSERT INTO international VALUES (36,'WebGUI','Deutsch','Um diese Funktion ausführen zu können, müssen Sie Administrator sein. Eine der folgenden Personen kann Sie zum Administrator machen:');
INSERT INTO international VALUES (36,'WebGUI','Dutch','U moet een behherder zijn om deze functie uit te voeren. Neem contact op met een van de beheerders:');
INSERT INTO international VALUES (36,'WebGUI','English','You must be an administrator to perform this function. Please contact one of your administrators. The following is a list of the administrators for this system:');
INSERT INTO international VALUES (36,'WebGUI','Español','Debe ser administrador para realizar esta tarea. Por favor contacte a uno de los administradores. La siguiente es una lista de los administradores de éste sistema:');
INSERT INTO international VALUES (36,'WebGUI','Português','Função reservada a administradores. Fale com um dos seguintes administradores:');
INSERT INTO international VALUES (37,'WebGUI','Deutsch','Zugriff verweigert!');
INSERT INTO international VALUES (37,'WebGUI','Dutch','Geen toegang!');
INSERT INTO international VALUES (37,'WebGUI','English','Permission Denied!');
INSERT INTO international VALUES (37,'WebGUI','Español','Permiso Denegado!');
INSERT INTO international VALUES (37,'WebGUI','Português','Permissão negada!');
INSERT INTO international VALUES (38,'WebGUI','Deutsch','Sie sind nicht berechtigt, diese Aktion auszuführen. ^a(Melden Sie sich bitte mit einem Benutzernamen an);, der über ausreichende Rechte verfügt.');
INSERT INTO international VALUES (38,'WebGUI','Dutch','U heeft niet voldoende privileges om deze operatie te doen. ^a(Log in); als een gebruiker met voldoende privileges.');
INSERT INTO international VALUES (38,'WebGUI','English','You do not have sufficient privileges to perform this operation. Please ^a(log in with an account); that has sufficient privileges before attempting this operation.');
INSERT INTO international VALUES (38,'WebGUI','Español','\"No tiene privilegios suficientes para realizar ésta operación. Por favor ^a(ingrese con una cuenta); que posea los privilegios suficientes antes de intentar ésta operación.\"');
INSERT INTO international VALUES (38,'WebGUI','Português','\"Não tem privilégios para essa operação. ^a(Identifique-se na entrada); com uma conta que permita essa operação.\"');
INSERT INTO international VALUES (39,'WebGUI','Deutsch','Sie sind nicht berechtigt, diese Seite anzuschauen.');
INSERT INTO international VALUES (39,'WebGUI','Dutch','U heeft niet voldoende privileges om deze pagina op te vragen.');
INSERT INTO international VALUES (39,'WebGUI','English','You do not have sufficient privileges to access this page.');
INSERT INTO international VALUES (39,'WebGUI','Español','No tiene suficientes privilegios para ingresar a ésta página.');
INSERT INTO international VALUES (39,'WebGUI','Português','Não tem privilégios para aceder a essa página.');
INSERT INTO international VALUES (40,'WebGUI','Deutsch','Notwendiger Bestandteil');
INSERT INTO international VALUES (40,'WebGUI','Dutch','Vitaal component');
INSERT INTO international VALUES (40,'WebGUI','English','Vital Component');
INSERT INTO international VALUES (40,'WebGUI','Español','Componente Vital');
INSERT INTO international VALUES (40,'WebGUI','Português','Componente vital');
INSERT INTO international VALUES (41,'WebGUI','Deutsch','Sie versuchen einen notwendigen Bestandteil des Systems zu löschen. WebGUI wird nach dieser Aktion möglicherweise nicht mehr richtig funktionieren.');
INSERT INTO international VALUES (41,'WebGUI','Dutch','U probeert een vitaal component van het WebGUI systeem te verwijderen. Als u dit zou mogen dan zou WebGUI waarschijnlijk niet meer werken.');
INSERT INTO international VALUES (41,'WebGUI','English','You\'re attempting to remove a vital component of the WebGUI system. If you were allowed to continue WebGUI may cease to function.');
INSERT INTO international VALUES (41,'WebGUI','Español','Esta intentando eliminar un componente vital del sistema WebGUI. Si continúa puede causar un mal funcionamiento de WebGUI.');
INSERT INTO international VALUES (41,'WebGUI','Português','Está a tentar remover um componente vital do WebGUI. Se continuar pode haver um erro grave.');
INSERT INTO international VALUES (42,'WebGUI','Deutsch','Bitte bestätigen Sie');
INSERT INTO international VALUES (42,'WebGUI','Dutch','Alstublieft bevestigen');
INSERT INTO international VALUES (42,'WebGUI','English','Please Confirm');
INSERT INTO international VALUES (42,'WebGUI','Español','Por favor confirme');
INSERT INTO international VALUES (42,'WebGUI','Português','Confirma');
INSERT INTO international VALUES (43,'WebGUI','Deutsch','Sind Sie sicher, dass Sie diesen Inhalt löschen möchten?');
INSERT INTO international VALUES (43,'WebGUI','Dutch','Weet u zeker dat u deze inhoud wilt verwijderen?');
INSERT INTO international VALUES (43,'WebGUI','English','Are you certain that you wish to delete this content?');
INSERT INTO international VALUES (43,'WebGUI','Español','Está seguro de querer eliminar éste contenido?');
INSERT INTO international VALUES (43,'WebGUI','Português','Tem a certeza que quer apagar este conteudo?');
INSERT INTO international VALUES (44,'WebGUI','Deutsch','Ja, ich bin mir sicher.');
INSERT INTO international VALUES (44,'WebGUI','Dutch','\"Ja, ik weet het zeker.\"');
INSERT INTO international VALUES (44,'WebGUI','English','Yes, I\'m sure.');
INSERT INTO international VALUES (44,'WebGUI','Español','Si');
INSERT INTO international VALUES (44,'WebGUI','Português','\"Sim, tenho a certeza.\"');
INSERT INTO international VALUES (45,'WebGUI','Deutsch','Nein, ich habe einen Fehler gemacht.');
INSERT INTO international VALUES (45,'WebGUI','Dutch','\"Nee, ik heb een foutje gemaakt.\"');
INSERT INTO international VALUES (45,'WebGUI','English','No, I made a mistake.');
INSERT INTO international VALUES (45,'WebGUI','Español','No');
INSERT INTO international VALUES (45,'WebGUI','Português','\"Não, enganei-me.\"');
INSERT INTO international VALUES (46,'WebGUI','Deutsch','Mein Benutzerkonto');
INSERT INTO international VALUES (46,'WebGUI','Dutch','Mijn account');
INSERT INTO international VALUES (46,'WebGUI','English','My Account');
INSERT INTO international VALUES (46,'WebGUI','Español','Mi Cuenta');
INSERT INTO international VALUES (46,'WebGUI','Português','Minha Conta');
INSERT INTO international VALUES (47,'WebGUI','Deutsch','Startseite');
INSERT INTO international VALUES (47,'WebGUI','Dutch','Home');
INSERT INTO international VALUES (47,'WebGUI','English','Home');
INSERT INTO international VALUES (47,'WebGUI','Español','Home');
INSERT INTO international VALUES (47,'WebGUI','Português','Inicio');
INSERT INTO international VALUES (48,'WebGUI','Deutsch','Hallo');
INSERT INTO international VALUES (48,'WebGUI','Dutch','Hallo');
INSERT INTO international VALUES (48,'WebGUI','English','Hello');
INSERT INTO international VALUES (48,'WebGUI','Español','Hola');
INSERT INTO international VALUES (48,'WebGUI','Português','Ola');
INSERT INTO international VALUES (49,'WebGUI','Deutsch','Hier können Sie sich <a href=\"^\\;?op=logout\">abmelden</a>.');
INSERT INTO international VALUES (49,'WebGUI','Dutch','Klik <a href=\"^\\;?op=logout\">hier</a> om uit te loggen.');
INSERT INTO international VALUES (49,'WebGUI','English','Click <a href=\"^\\;?op=logout\">here</a> to log out.');
INSERT INTO international VALUES (49,'WebGUI','Español','Click <a href=\"^\\;?op=logout\">aquí</a> para salir.');
INSERT INTO international VALUES (49,'WebGUI','Português','Clique <a href=\"^\\;?op=logout\">aqui</a> para sair.');
INSERT INTO international VALUES (50,'WebGUI','Deutsch','Benutzername');
INSERT INTO international VALUES (50,'WebGUI','Dutch','Gebruikersnaam');
INSERT INTO international VALUES (50,'WebGUI','English','Username');
INSERT INTO international VALUES (50,'WebGUI','Español','Nombre usuario');
INSERT INTO international VALUES (50,'WebGUI','Português','Username');
INSERT INTO international VALUES (51,'WebGUI','Deutsch','Passwort');
INSERT INTO international VALUES (51,'WebGUI','Dutch','Wachtwoord');
INSERT INTO international VALUES (51,'WebGUI','English','Password');
INSERT INTO international VALUES (51,'WebGUI','Español','Password');
INSERT INTO international VALUES (51,'WebGUI','Português','Password');
INSERT INTO international VALUES (52,'WebGUI','Deutsch','Anmelden');
INSERT INTO international VALUES (52,'WebGUI','Dutch','Login');
INSERT INTO international VALUES (52,'WebGUI','English','login');
INSERT INTO international VALUES (52,'WebGUI','Español','ingresar');
INSERT INTO international VALUES (52,'WebGUI','Português','entrar');
INSERT INTO international VALUES (53,'WebGUI','Deutsch','Druckerbares Format');
INSERT INTO international VALUES (53,'WebGUI','Dutch','Maak pagina printbaar');
INSERT INTO international VALUES (53,'WebGUI','English','Make Page Printable');
INSERT INTO international VALUES (53,'WebGUI','Español','Hacer página imprimible');
INSERT INTO international VALUES (53,'WebGUI','Português','Versão para impressão');
INSERT INTO international VALUES (54,'WebGUI','Deutsch','Benutzerkonto anlegen');
INSERT INTO international VALUES (54,'WebGUI','Dutch','Creëer account');
INSERT INTO international VALUES (54,'WebGUI','English','Create Account');
INSERT INTO international VALUES (54,'WebGUI','Español','Crear Cuenta');
INSERT INTO international VALUES (54,'WebGUI','Português','Criar conta');
INSERT INTO international VALUES (55,'WebGUI','Deutsch','Passwort (bestätigen)');
INSERT INTO international VALUES (55,'WebGUI','Dutch','Wachtwoord (bevestigen)');
INSERT INTO international VALUES (55,'WebGUI','English','Password (confirm)');
INSERT INTO international VALUES (55,'WebGUI','Español','Password (confirmar)');
INSERT INTO international VALUES (55,'WebGUI','Português','Password (confirmar)');
INSERT INTO international VALUES (56,'WebGUI','Deutsch','Email Adresse');
INSERT INTO international VALUES (56,'WebGUI','Dutch','Email adres');
INSERT INTO international VALUES (56,'WebGUI','English','Email Address');
INSERT INTO international VALUES (56,'WebGUI','Español','Dirección de e-mail');
INSERT INTO international VALUES (56,'WebGUI','Português','Endereço de e-mail');
INSERT INTO international VALUES (57,'WebGUI','Deutsch','(Dies ist nur notwendig, wenn Sie Eigenschaften benutzen möchten die eine Emailadresse voraussetzen)');
INSERT INTO international VALUES (57,'WebGUI','Dutch','Dit is alleen nodig als er functies gebruikt worden die Email nodig hebben.');
INSERT INTO international VALUES (57,'WebGUI','English','This is only necessary if you wish to use features that require Email.');
INSERT INTO international VALUES (57,'WebGUI','Español','Solo es necesaria si desea usar opciones que requieren e-mail.');
INSERT INTO international VALUES (57,'WebGUI','Português','Apenas é necessário se pretender utilizar as funcionalidade que envolvam e-mail.');
INSERT INTO international VALUES (58,'WebGUI','Deutsch','Ich besitze bereits ein Benutzerkonto.');
INSERT INTO international VALUES (58,'WebGUI','Dutch','Ik heb al een account.');
INSERT INTO international VALUES (58,'WebGUI','English','I already have an account.');
INSERT INTO international VALUES (58,'WebGUI','Español','Ya tengo una cuenta!');
INSERT INTO international VALUES (58,'WebGUI','Português','Já tenho uma conta.');
INSERT INTO international VALUES (59,'WebGUI','Deutsch','Ich habe mein Passwort vergessen');
INSERT INTO international VALUES (59,'WebGUI','Dutch','Ik ben mijn wachtwoord vergeten.');
INSERT INTO international VALUES (59,'WebGUI','English','I forgot my password.');
INSERT INTO international VALUES (59,'WebGUI','Español','Perdí mi password');
INSERT INTO international VALUES (59,'WebGUI','Português','Esqueci a minha password.');
INSERT INTO international VALUES (60,'WebGUI','Deutsch','Sind Sie sicher, dass Sie dieses Benutzerkonto deaktivieren möchten? Wenn Sie fortfahren sind Ihre Konteninformationen endgültig verloren.');
INSERT INTO international VALUES (60,'WebGUI','Dutch','Weet u zeker dat u uw account wilt deaktiveren? Als u doorgaat gaat alle account informatie voorgoed verloren.');
INSERT INTO international VALUES (60,'WebGUI','English','Are you certain you want to deactivate your account. If you proceed your account information will be lost permanently.');
INSERT INTO international VALUES (60,'WebGUI','Español','Está seguro que quiere desactivar su cuenta. Si continúa su información se perderá permanentemente.');
INSERT INTO international VALUES (60,'WebGUI','Português','Tem a certeza que quer desactivar a sua conta. Se o fizer é permanente!');
INSERT INTO international VALUES (61,'WebGUI','Deutsch','Benutzerkontendetails aktualisieren');
INSERT INTO international VALUES (61,'WebGUI','Dutch','Account informatie bijwerken');
INSERT INTO international VALUES (61,'WebGUI','English','Update Account Information');
INSERT INTO international VALUES (61,'WebGUI','Español','Actualizar información de la Cuenta');
INSERT INTO international VALUES (61,'WebGUI','Português','Actualizar as informações da conta');
INSERT INTO international VALUES (62,'WebGUI','Deutsch','sichern');
INSERT INTO international VALUES (62,'WebGUI','Dutch','Bewaar');
INSERT INTO international VALUES (62,'WebGUI','English','save');
INSERT INTO international VALUES (62,'WebGUI','Español','guardar');
INSERT INTO international VALUES (62,'WebGUI','Português','gravar');
INSERT INTO international VALUES (63,'WebGUI','Deutsch','Administrationsmodus einschalten');
INSERT INTO international VALUES (63,'WebGUI','Dutch','Zet beheermode aan');
INSERT INTO international VALUES (63,'WebGUI','English','Turn admin on.');
INSERT INTO international VALUES (63,'WebGUI','Español','Encender Admin');
INSERT INTO international VALUES (63,'WebGUI','Português','Ligar modo administrativo.');
INSERT INTO international VALUES (64,'WebGUI','Deutsch','Abmelden');
INSERT INTO international VALUES (64,'WebGUI','Dutch','Log uit.');
INSERT INTO international VALUES (64,'WebGUI','English','Log out.');
INSERT INTO international VALUES (64,'WebGUI','Español','Salir');
INSERT INTO international VALUES (64,'WebGUI','Português','Sair.');
INSERT INTO international VALUES (65,'WebGUI','Deutsch','Benutzerkonto endgültig deaktivieren');
INSERT INTO international VALUES (65,'WebGUI','Dutch','Deaktiveer mijn account voorgoed.');
INSERT INTO international VALUES (65,'WebGUI','English','Please deactivate my account permanently.');
INSERT INTO international VALUES (65,'WebGUI','Español','Por favor desactive mi cuenta permanentemente');
INSERT INTO international VALUES (65,'WebGUI','Português','Desactivar a minha conta permanentemente.');
INSERT INTO international VALUES (66,'WebGUI','Deutsch','Anmelden');
INSERT INTO international VALUES (66,'WebGUI','Dutch','Log in');
INSERT INTO international VALUES (66,'WebGUI','English','Log In');
INSERT INTO international VALUES (66,'WebGUI','Español','Ingresar');
INSERT INTO international VALUES (66,'WebGUI','Português','Entrar');
INSERT INTO international VALUES (67,'WebGUI','Deutsch','Neues Benutzerkonto einrichten');
INSERT INTO international VALUES (67,'WebGUI','Dutch','Creëer een nieuw account');
INSERT INTO international VALUES (67,'WebGUI','English','Create a new account.');
INSERT INTO international VALUES (67,'WebGUI','Español','Crear nueva Cuenta');
INSERT INTO international VALUES (67,'WebGUI','Português','Criar nova conta.');
INSERT INTO international VALUES (68,'WebGUI','Deutsch','Die Benutzerkontoinformationen die Sie eingegeben haben, sind ungültig.  Entweder existiert das Konto nicht, oder die Kombination aus Benutzername und Passwort  ist falsch.');
INSERT INTO international VALUES (68,'WebGUI','Dutch','De account informatie is niet geldig. Het account bestaat niet of de gebruikersnaam/wachtwoord was fout.');
INSERT INTO international VALUES (68,'WebGUI','English','The account information you supplied is invalid. Either the account does not exist or the username/password combination was incorrect.');
INSERT INTO international VALUES (68,'WebGUI','Español','La información de su cuenta no es válida. O la cuenta no existe');
INSERT INTO international VALUES (68,'WebGUI','Português','As informações da sua conta não foram encontradas. Não existe ou a combinação username/password está incorrecta.');
INSERT INTO international VALUES (69,'WebGUI','Deutsch','Bitten Sie Ihren Systemadministrator um Hilfe.');
INSERT INTO international VALUES (69,'WebGUI','Dutch','Vraag uw systeembeheerder om assistentie.');
INSERT INTO international VALUES (69,'WebGUI','English','Please contact your system administrator for assistance.');
INSERT INTO international VALUES (69,'WebGUI','Español','Por favor contacte a su administrador por asistencia.');
INSERT INTO international VALUES (69,'WebGUI','Português','Contacte o seu administrador de sistemas para assistência.');
INSERT INTO international VALUES (70,'WebGUI','Deutsch','Fehler');
INSERT INTO international VALUES (70,'WebGUI','Dutch','Fout');
INSERT INTO international VALUES (70,'WebGUI','English','Error');
INSERT INTO international VALUES (70,'WebGUI','Español','Error');
INSERT INTO international VALUES (70,'WebGUI','Português','Erro');
INSERT INTO international VALUES (71,'WebGUI','Deutsch','Passwort wiederherstellen');
INSERT INTO international VALUES (71,'WebGUI','Dutch','Wachtwoord terugvinden');
INSERT INTO international VALUES (71,'WebGUI','English','Recover password');
INSERT INTO international VALUES (71,'WebGUI','Español','Recuperar password');
INSERT INTO international VALUES (71,'WebGUI','Português','Recuperar password');
INSERT INTO international VALUES (72,'WebGUI','Deutsch','wiederherstellen');
INSERT INTO international VALUES (72,'WebGUI','Dutch','Terugvinden');
INSERT INTO international VALUES (72,'WebGUI','English','recover');
INSERT INTO international VALUES (72,'WebGUI','Español','recuperar');
INSERT INTO international VALUES (72,'WebGUI','Português','recoperar');
INSERT INTO international VALUES (73,'WebGUI','Deutsch','Anmelden');
INSERT INTO international VALUES (73,'WebGUI','Dutch','Log in.');
INSERT INTO international VALUES (73,'WebGUI','English','Log in.');
INSERT INTO international VALUES (73,'WebGUI','Español','Ingresar.');
INSERT INTO international VALUES (73,'WebGUI','Português','Entrar.');
INSERT INTO international VALUES (74,'WebGUI','Deutsch','Benutzerkonteninformation');
INSERT INTO international VALUES (74,'WebGUI','Dutch','Account informatie');
INSERT INTO international VALUES (74,'WebGUI','English','Account Information');
INSERT INTO international VALUES (74,'WebGUI','Español','Información de la Cuenta');
INSERT INTO international VALUES (74,'WebGUI','Português','Informações da sua conta');
INSERT INTO international VALUES (75,'WebGUI','Deutsch','Ihre Benutzerkonteninformation wurde an Ihre Emailadresse geschickt');
INSERT INTO international VALUES (75,'WebGUI','Dutch','Uw account informatie is naar uw email adres verzonden.');
INSERT INTO international VALUES (75,'WebGUI','English','Your account information has been sent to your email address.');
INSERT INTO international VALUES (75,'WebGUI','Español','La información de su cuenta ha sido enviada a su e-mail-');
INSERT INTO international VALUES (75,'WebGUI','Português','As informações da sua conta foram envidas para o seu e-mail.');
INSERT INTO international VALUES (76,'WebGUI','Deutsch','Ihre Emailadresse ist nicht in unserer Datenbank.');
INSERT INTO international VALUES (76,'WebGUI','Dutch','Dat email adresis niet in onze database aanwezig.');
INSERT INTO international VALUES (76,'WebGUI','English','That email address is not in our databases.');
INSERT INTO international VALUES (76,'WebGUI','Español','El e-mail no está en nuestra base de datos');
INSERT INTO international VALUES (76,'WebGUI','Português','Esse endereço de e-mail não foi encontrado nas nossas bases de dados');
INSERT INTO international VALUES (77,'WebGUI','Deutsch','Ein anderes Mitglied dieser Seiten benutzt bereits diesen Namen. Bitte wählen Sie einen anderen Benutzernamen. Hier sind einige Vorschläge:');
INSERT INTO international VALUES (77,'WebGUI','Dutch','Deze account naam wordt al gebruikt door een andere gebruiker van dit systeem. Probeer een andere naam. We hebben de volgende suggesties:');
INSERT INTO international VALUES (77,'WebGUI','English','That account name is already in use by another member of this site. Please try a different username. The following are some suggestions:');
INSERT INTO international VALUES (77,'WebGUI','Español','El nombre de cuenta ya está en uso por otro miembro. Por favor trate con otro nombre de usuario.  Los siguiente son algunas sugerencias:');
INSERT INTO international VALUES (77,'WebGUI','Português','\"Esse nome de conta já existe, tente outro. Veja as nossas sugestões:\"');
INSERT INTO international VALUES (78,'WebGUI','Deutsch','Die Passworte unterscheiden sich. Bitte versuchen Sie es noch einmal.');
INSERT INTO international VALUES (78,'WebGUI','Dutch','De wachtwoorden waren niet gelijk. Probeer opnieuw.');
INSERT INTO international VALUES (78,'WebGUI','English','Your passwords did not match. Please try again.');
INSERT INTO international VALUES (78,'WebGUI','Español','Su password no concuerda. Trate de nuevo.');
INSERT INTO international VALUES (78,'WebGUI','Português','\"As suas passwords não coincidem, tente novamente.\"');
INSERT INTO international VALUES (79,'WebGUI','Deutsch','Verbindung zum LDAP-Server konnte nicht hergestellt werden.');
INSERT INTO international VALUES (79,'WebGUI','Dutch','Kan niet verbinden met LDAP server.');
INSERT INTO international VALUES (79,'WebGUI','English','Cannot connect to LDAP server.');
INSERT INTO international VALUES (79,'WebGUI','Español','No se puede conectar con el servidor LDAP');
INSERT INTO international VALUES (79,'WebGUI','Português','Impossivel ligar ao LDAP.');
INSERT INTO international VALUES (80,'WebGUI','Deutsch','Benutzerkonto wurde angelegt');
INSERT INTO international VALUES (80,'WebGUI','Dutch','Account is aangemaakt!');
INSERT INTO international VALUES (80,'WebGUI','English','Account created successfully!');
INSERT INTO international VALUES (80,'WebGUI','Español','La cuenta se ha creado con éxito!');
INSERT INTO international VALUES (80,'WebGUI','Português','Conta criada com sucesso!');
INSERT INTO international VALUES (81,'WebGUI','Deutsch','Benutzerkonto wurde aktualisiert');
INSERT INTO international VALUES (81,'WebGUI','Dutch','Account is aangepast!');
INSERT INTO international VALUES (81,'WebGUI','English','Account updated successfully!');
INSERT INTO international VALUES (81,'WebGUI','Español','La cuenta se actualizó con éxito!');
INSERT INTO international VALUES (81,'WebGUI','Português','Conta actualizada com sucesso!');
INSERT INTO international VALUES (82,'WebGUI','Deutsch','Administrative Funktionen ...');
INSERT INTO international VALUES (82,'WebGUI','Dutch','Administratieve functies...');
INSERT INTO international VALUES (82,'WebGUI','English','Administrative functions...');
INSERT INTO international VALUES (82,'WebGUI','Español','Funciones Administrativas...');
INSERT INTO international VALUES (82,'WebGUI','Português','Funções administrativas...');
INSERT INTO international VALUES (83,'WebGUI','Deutsch','Gruppe hinzufügen');
INSERT INTO international VALUES (83,'WebGUI','Dutch','Voeg groep toe');
INSERT INTO international VALUES (83,'WebGUI','English','Add Group');
INSERT INTO international VALUES (83,'WebGUI','Español','Agregar Grupo');
INSERT INTO international VALUES (83,'WebGUI','Português','Adicionar grupo');
INSERT INTO international VALUES (84,'WebGUI','Deutsch','Gruppenname');
INSERT INTO international VALUES (84,'WebGUI','Dutch','Groep naam');
INSERT INTO international VALUES (84,'WebGUI','English','Group Name');
INSERT INTO international VALUES (84,'WebGUI','Español','Nombre del Grupo');
INSERT INTO international VALUES (84,'WebGUI','Português','Nome do grupo');
INSERT INTO international VALUES (85,'WebGUI','Deutsch','Beschreibung');
INSERT INTO international VALUES (85,'WebGUI','Dutch','Beschrijving');
INSERT INTO international VALUES (85,'WebGUI','English','Description');
INSERT INTO international VALUES (85,'WebGUI','Español','Descripción');
INSERT INTO international VALUES (85,'WebGUI','Português','Descrição');
INSERT INTO international VALUES (86,'WebGUI','Deutsch','Sind Sie sicher, dass Sie diese Gruppe löschen möchten? Denken Sie daran, dass diese Gruppe und die zugehörige Rechtesstruktur endgültig gelöscht wird.');
INSERT INTO international VALUES (86,'WebGUI','Dutch','Weet u zeker dat u deze groep wilt verwijderen? Denk er aan dat een groep verwijderen permanent en alle privileges geassocieerd met de groep verwijdert worden.');
INSERT INTO international VALUES (86,'WebGUI','English','Are you certain you wish to delete this group? Beware that deleting a group is permanent and will remove all privileges associated with this group.');
INSERT INTO international VALUES (86,'WebGUI','Español','Está segugo de querer eliminar éste grupo? Tenga en cuenta que la eliminación es permanente y removerá todos los privilegios asociados con el grupo.');
INSERT INTO international VALUES (86,'WebGUI','Português','Tem a certeza que quer apagar este grupo. Se o fizer apaga-o permanentemente e a todos os seus provilégios.');
INSERT INTO international VALUES (87,'WebGUI','Deutsch','Gruppe bearbeiten');
INSERT INTO international VALUES (87,'WebGUI','Dutch','Bewerk groep');
INSERT INTO international VALUES (87,'WebGUI','English','Edit Group');
INSERT INTO international VALUES (87,'WebGUI','Español','Editar Grupo');
INSERT INTO international VALUES (87,'WebGUI','Português','Modificar grupo');
INSERT INTO international VALUES (88,'WebGUI','Deutsch','Benutzer in dieser Gruppe');
INSERT INTO international VALUES (88,'WebGUI','Dutch','Grebruikers in groep');
INSERT INTO international VALUES (88,'WebGUI','English','Users In Group');
INSERT INTO international VALUES (88,'WebGUI','Español','Usuarios en Grupo');
INSERT INTO international VALUES (88,'WebGUI','Português','Utilizadores no grupo');
INSERT INTO international VALUES (89,'WebGUI','Deutsch','Gruppen');
INSERT INTO international VALUES (89,'WebGUI','Dutch','Groepen');
INSERT INTO international VALUES (89,'WebGUI','English','Groups');
INSERT INTO international VALUES (89,'WebGUI','Español','Grupos');
INSERT INTO international VALUES (89,'WebGUI','Português','Grupos');
INSERT INTO international VALUES (90,'WebGUI','Deutsch','Neue Gruppe hinzufügen');
INSERT INTO international VALUES (90,'WebGUI','Dutch','Voeg nieuwe groep toe.');
INSERT INTO international VALUES (90,'WebGUI','English','Add new group.');
INSERT INTO international VALUES (90,'WebGUI','Español','Agregar nuevo grupo');
INSERT INTO international VALUES (90,'WebGUI','Português','Adicionar novo grupo.');
INSERT INTO international VALUES (91,'WebGUI','Deutsch','Vorherige Seite');
INSERT INTO international VALUES (91,'WebGUI','Dutch','Vorige pagina');
INSERT INTO international VALUES (91,'WebGUI','English','Previous Page');
INSERT INTO international VALUES (91,'WebGUI','Español','Página previa');
INSERT INTO international VALUES (91,'WebGUI','Português','Página anterior');
INSERT INTO international VALUES (92,'WebGUI','Deutsch','Nächste Seite');
INSERT INTO international VALUES (92,'WebGUI','Dutch','Volgende pagina');
INSERT INTO international VALUES (92,'WebGUI','English','Next Page');
INSERT INTO international VALUES (92,'WebGUI','Español','Siguiente página');
INSERT INTO international VALUES (92,'WebGUI','Português','Próxima página');
INSERT INTO international VALUES (93,'WebGUI','Deutsch','Hilfe');
INSERT INTO international VALUES (93,'WebGUI','Dutch','Help');
INSERT INTO international VALUES (93,'WebGUI','English','Help');
INSERT INTO international VALUES (93,'WebGUI','Español','Ayuda');
INSERT INTO international VALUES (93,'WebGUI','Português','Ajuda');
INSERT INTO international VALUES (94,'WebGUI','Deutsch','Siehe auch');
INSERT INTO international VALUES (94,'WebGUI','Dutch','Zie ook');
INSERT INTO international VALUES (94,'WebGUI','English','See also');
INSERT INTO international VALUES (94,'WebGUI','Español','Vea también');
INSERT INTO international VALUES (94,'WebGUI','Português','Ver tembém');
INSERT INTO international VALUES (95,'WebGUI','Deutsch','Hilfe');
INSERT INTO international VALUES (95,'WebGUI','Dutch','Help index');
INSERT INTO international VALUES (95,'WebGUI','English','Help Index');
INSERT INTO international VALUES (95,'WebGUI','Español','Índice de Ayuda');
INSERT INTO international VALUES (95,'WebGUI','Português','Indice da ajuda');
INSERT INTO international VALUES (96,'WebGUI','Deutsch','Sortiert nach Aktion');
INSERT INTO international VALUES (96,'WebGUI','Dutch','Gesorteerd op acti');
INSERT INTO international VALUES (96,'WebGUI','English','Sorted By Action');
INSERT INTO international VALUES (96,'WebGUI','Español','Ordenar por Acción');
INSERT INTO international VALUES (96,'WebGUI','Português','Ordenar por acção');
INSERT INTO international VALUES (97,'WebGUI','Deutsch','Sortiert nach Objekt');
INSERT INTO international VALUES (97,'WebGUI','Dutch','Gesorteerd op object');
INSERT INTO international VALUES (97,'WebGUI','English','Sorted by Object');
INSERT INTO international VALUES (97,'WebGUI','Español','Ordenar por Objeto');
INSERT INTO international VALUES (97,'WebGUI','Português','Ordenar por objecto');
INSERT INTO international VALUES (98,'WebGUI','Deutsch','Seite hinzufügen');
INSERT INTO international VALUES (98,'WebGUI','Dutch','Pagina toevoegen');
INSERT INTO international VALUES (98,'WebGUI','English','Add Page');
INSERT INTO international VALUES (98,'WebGUI','Español','Agregar Página');
INSERT INTO international VALUES (98,'WebGUI','Português','Adicionar página');
INSERT INTO international VALUES (99,'WebGUI','Deutsch','Titel');
INSERT INTO international VALUES (99,'WebGUI','Dutch','Titel');
INSERT INTO international VALUES (99,'WebGUI','English','Title');
INSERT INTO international VALUES (99,'WebGUI','Español','Título');
INSERT INTO international VALUES (99,'WebGUI','Português','Titulo');
INSERT INTO international VALUES (100,'WebGUI','Deutsch','Meta Tags');
INSERT INTO international VALUES (100,'WebGUI','Dutch','Meta tags');
INSERT INTO international VALUES (100,'WebGUI','English','Meta Tags');
INSERT INTO international VALUES (100,'WebGUI','Español','Meta Tags');
INSERT INTO international VALUES (100,'WebGUI','Português','Meta Tags');
INSERT INTO international VALUES (101,'WebGUI','Deutsch','Sind Sie sicher, dass Sie diese Seite und ihren kompletten Inhalt darunter löschen möchten?');
INSERT INTO international VALUES (101,'WebGUI','Dutch','Weet u zeker dat u deze pagina wilt verwijderen en alle inhoud en objecten erachter?');
INSERT INTO international VALUES (101,'WebGUI','English','Are you certain that you wish to delete this page, its content, and all items under it?');
INSERT INTO international VALUES (101,'WebGUI','Español','Está seguro de querer eliminar ésta página');
INSERT INTO international VALUES (101,'WebGUI','Português','\"Tem a certeza que quer apagar esta página, o seu conteudo e tudo que está abaixo?\"');
INSERT INTO international VALUES (102,'WebGUI','Deutsch','Seite bearbeiten');
INSERT INTO international VALUES (102,'WebGUI','Dutch','Bewerk pagina');
INSERT INTO international VALUES (102,'WebGUI','English','Edit Page');
INSERT INTO international VALUES (102,'WebGUI','Español','Editar Página');
INSERT INTO international VALUES (102,'WebGUI','Português','Modificar a página');
INSERT INTO international VALUES (103,'WebGUI','Deutsch','Seitenspezifikation');
INSERT INTO international VALUES (103,'WebGUI','Dutch','Pagina specifiek');
INSERT INTO international VALUES (103,'WebGUI','English','Page Specifics');
INSERT INTO international VALUES (103,'WebGUI','Español','Propio de la página');
INSERT INTO international VALUES (103,'WebGUI','Português','Especificações da página');
INSERT INTO international VALUES (104,'WebGUI','Deutsch','URL der Seite');
INSERT INTO international VALUES (104,'WebGUI','Dutch','Pagina URL');
INSERT INTO international VALUES (104,'WebGUI','English','Page URL');
INSERT INTO international VALUES (104,'WebGUI','Español','URL de la página');
INSERT INTO international VALUES (104,'WebGUI','Português','URL da página');
INSERT INTO international VALUES (105,'WebGUI','Deutsch','Stil');
INSERT INTO international VALUES (105,'WebGUI','Dutch','Stijl');
INSERT INTO international VALUES (105,'WebGUI','English','Style');
INSERT INTO international VALUES (105,'WebGUI','Español','Estilo');
INSERT INTO international VALUES (105,'WebGUI','Português','Estilo');
INSERT INTO international VALUES (106,'WebGUI','Deutsch','Stil an alle nachfolgenden Seiten weitergeben.');
INSERT INTO international VALUES (106,'WebGUI','Dutch','Aanvinken om deze stijl in alle pagina\'s te gebruiiken.');
INSERT INTO international VALUES (106,'WebGUI','English','Check to give this style to all sub-pages.');
INSERT INTO international VALUES (106,'WebGUI','Español','Marque para dar éste estilo a todas las sub-páginas.');
INSERT INTO international VALUES (106,'WebGUI','Português','Escolha para atribuir este estilo a todas as sub-páginas');
INSERT INTO international VALUES (107,'WebGUI','Deutsch','Rechte');
INSERT INTO international VALUES (107,'WebGUI','Dutch','Privileges');
INSERT INTO international VALUES (107,'WebGUI','English','Privileges');
INSERT INTO international VALUES (107,'WebGUI','Español','Privilegios');
INSERT INTO international VALUES (107,'WebGUI','Português','Privilégios');
INSERT INTO international VALUES (108,'WebGUI','Deutsch','Besitzer');
INSERT INTO international VALUES (108,'WebGUI','Dutch','Eigenaar');
INSERT INTO international VALUES (108,'WebGUI','English','Owner');
INSERT INTO international VALUES (108,'WebGUI','Español','Dueño');
INSERT INTO international VALUES (108,'WebGUI','Português','Dono');
INSERT INTO international VALUES (109,'WebGUI','Deutsch','Besitzer kann anschauen?');
INSERT INTO international VALUES (109,'WebGUI','Dutch','Eigenaar kan bekijken?');
INSERT INTO international VALUES (109,'WebGUI','English','Owner can view?');
INSERT INTO international VALUES (109,'WebGUI','Español','Dueño puede ver?');
INSERT INTO international VALUES (109,'WebGUI','Português','O dono pode ver?');
INSERT INTO international VALUES (110,'WebGUI','Deutsch','Besitzer kann bearbeiten?');
INSERT INTO international VALUES (110,'WebGUI','Dutch','Gebruiker kan bewerken?');
INSERT INTO international VALUES (110,'WebGUI','English','Owner can edit?');
INSERT INTO international VALUES (110,'WebGUI','Español','Dueño puede editar?');
INSERT INTO international VALUES (110,'WebGUI','Português','O dono pode modificar?');
INSERT INTO international VALUES (111,'WebGUI','Deutsch','Gruppe');
INSERT INTO international VALUES (111,'WebGUI','Dutch','Groep');
INSERT INTO international VALUES (111,'WebGUI','English','Group');
INSERT INTO international VALUES (111,'WebGUI','Español','Grupo');
INSERT INTO international VALUES (111,'WebGUI','Português','Grupo');
INSERT INTO international VALUES (112,'WebGUI','Deutsch','Gruppe kann anschauen?');
INSERT INTO international VALUES (112,'WebGUI','Dutch','Groep kan bekijken?');
INSERT INTO international VALUES (112,'WebGUI','English','Group can view?');
INSERT INTO international VALUES (112,'WebGUI','Español','Grupo puede ver?');
INSERT INTO international VALUES (112,'WebGUI','Português','O grupo pode ver?');
INSERT INTO international VALUES (113,'WebGUI','Deutsch','Gruppe kann bearbeiten?');
INSERT INTO international VALUES (113,'WebGUI','Dutch','Groep kan bewerken?');
INSERT INTO international VALUES (113,'WebGUI','English','Group can edit?');
INSERT INTO international VALUES (113,'WebGUI','Español','Grupo puede editar?');
INSERT INTO international VALUES (113,'WebGUI','Português','O grupo pode modificar?');
INSERT INTO international VALUES (114,'WebGUI','Deutsch','Kann jeder anschauen?');
INSERT INTO international VALUES (114,'WebGUI','Dutch','Iedereen kan bekijken?');
INSERT INTO international VALUES (114,'WebGUI','English','Anybody can view?');
INSERT INTO international VALUES (114,'WebGUI','Español','Cualquiera puede ver?');
INSERT INTO international VALUES (114,'WebGUI','Português','Qualquer pessoa pode ver?');
INSERT INTO international VALUES (115,'WebGUI','Deutsch','Kann jeder bearbeiten?');
INSERT INTO international VALUES (115,'WebGUI','Dutch','Iedereen kan bewerken?');
INSERT INTO international VALUES (115,'WebGUI','English','Anybody can edit?');
INSERT INTO international VALUES (115,'WebGUI','Español','Cualquiera puede editar?');
INSERT INTO international VALUES (115,'WebGUI','Português','Qualquer pessoa pode modificar?');
INSERT INTO international VALUES (116,'WebGUI','Deutsch','Rechte an alle nachfolgenden Seiten weitergeben.');
INSERT INTO international VALUES (116,'WebGUI','Dutch','Aanvinken om deze privileges aan alle sub pagina\'s te geven.');
INSERT INTO international VALUES (116,'WebGUI','English','Check to give these privileges to all sub-pages.');
INSERT INTO international VALUES (116,'WebGUI','Español','Marque para dar éstos privilegios a todas las sub-páginas.');
INSERT INTO international VALUES (116,'WebGUI','Português','Escolher para atribuir estes privilégios a todas as sub-páginas.');
INSERT INTO international VALUES (117,'WebGUI','Deutsch','Authentifizierungseinstellungen bearbeiten');
INSERT INTO international VALUES (117,'WebGUI','Dutch','Bewerk toegangs controle instellingen');
INSERT INTO international VALUES (117,'WebGUI','English','Edit Authentication Settings');
INSERT INTO international VALUES (117,'WebGUI','Español','Editar Opciones de Auntentificación');
INSERT INTO international VALUES (117,'WebGUI','Português','Modificar preferências de autenticação');
INSERT INTO international VALUES (118,'WebGUI','Deutsch','anonyme Registrierung');
INSERT INTO international VALUES (118,'WebGUI','Dutch','Anonieme registratie');
INSERT INTO international VALUES (118,'WebGUI','English','Anonymous Registration');
INSERT INTO international VALUES (118,'WebGUI','Español','Registración Anónima');
INSERT INTO international VALUES (118,'WebGUI','Português','Registo anónimo');
INSERT INTO international VALUES (119,'WebGUI','Deutsch','Authentifizierungsmethode (Standard)');
INSERT INTO international VALUES (119,'WebGUI','Dutch','Toegangs controle methode (standaard)');
INSERT INTO international VALUES (119,'WebGUI','English','Authentication Method (default)');
INSERT INTO international VALUES (119,'WebGUI','Español','Método de Autentificación (por defecto)');
INSERT INTO international VALUES (119,'WebGUI','Português','Método de autenticação (defeito)');
INSERT INTO international VALUES (120,'WebGUI','Deutsch','LDAP URL (Standard)');
INSERT INTO international VALUES (120,'WebGUI','Dutch','LDAP URL (standaard)');
INSERT INTO international VALUES (120,'WebGUI','English','LDAP URL (default)');
INSERT INTO international VALUES (120,'WebGUI','Español','URL LDAP (por defecto)');
INSERT INTO international VALUES (120,'WebGUI','Português','URL LDAP (defeito)');
INSERT INTO international VALUES (121,'WebGUI','Deutsch','LDAP Identität (Standard)');
INSERT INTO international VALUES (121,'WebGUI','Dutch','LDAP identiteit (standaard)');
INSERT INTO international VALUES (121,'WebGUI','English','LDAP Identity (default)');
INSERT INTO international VALUES (121,'WebGUI','Español','Identidad LDAP (por defecto)');
INSERT INTO international VALUES (121,'WebGUI','Português','Identidade LDAP (defeito)');
INSERT INTO international VALUES (122,'WebGUI','Deutsch','LDAP Identitäts-Name');
INSERT INTO international VALUES (122,'WebGUI','Dutch','LDAP identiteit naam');
INSERT INTO international VALUES (122,'WebGUI','English','LDAP Identity Name');
INSERT INTO international VALUES (122,'WebGUI','Español','Nombre Identidad LDAP');
INSERT INTO international VALUES (122,'WebGUI','Português','Nome da entidade LDAP');
INSERT INTO international VALUES (123,'WebGUI','Deutsch','LDAP Passwort Name');
INSERT INTO international VALUES (123,'WebGUI','Dutch','LDAP wachtwoord naam');
INSERT INTO international VALUES (123,'WebGUI','English','LDAP Password Name');
INSERT INTO international VALUES (123,'WebGUI','Español','Password LDAP');
INSERT INTO international VALUES (123,'WebGUI','Português','Nome da password LDAP');
INSERT INTO international VALUES (124,'WebGUI','Deutsch','Firmeninformationen bearbeiten');
INSERT INTO international VALUES (124,'WebGUI','Dutch','Bewerk bedrijfsinformatie');
INSERT INTO international VALUES (124,'WebGUI','English','Edit Company Information');
INSERT INTO international VALUES (124,'WebGUI','Español','Editar Información de la Companía');
INSERT INTO international VALUES (124,'WebGUI','Português','Modificar informação da empresa');
INSERT INTO international VALUES (125,'WebGUI','Deutsch','Firmenname');
INSERT INTO international VALUES (125,'WebGUI','Dutch','Bedrijfsnaam');
INSERT INTO international VALUES (125,'WebGUI','English','Company Name');
INSERT INTO international VALUES (125,'WebGUI','Español','Nombre de la Companía');
INSERT INTO international VALUES (125,'WebGUI','Português','Nome da empresa');
INSERT INTO international VALUES (126,'WebGUI','Deutsch','Emailadresse der Firma');
INSERT INTO international VALUES (126,'WebGUI','Dutch','Email adres bedrijf');
INSERT INTO international VALUES (126,'WebGUI','English','Company Email Address');
INSERT INTO international VALUES (126,'WebGUI','Español','E-mail de la Companía');
INSERT INTO international VALUES (126,'WebGUI','Português','Moarada da empresa');
INSERT INTO international VALUES (127,'WebGUI','Deutsch','Webseite der Firma');
INSERT INTO international VALUES (127,'WebGUI','Dutch','URL bedrijf');
INSERT INTO international VALUES (127,'WebGUI','English','Company URL');
INSERT INTO international VALUES (127,'WebGUI','Español','URL de la Companía');
INSERT INTO international VALUES (127,'WebGUI','Português','URL da empresa');
INSERT INTO international VALUES (128,'WebGUI','Deutsch','Dateieinstellungen bearbeiten');
INSERT INTO international VALUES (128,'WebGUI','Dutch','Bewerk bestandsinstellingen');
INSERT INTO international VALUES (128,'WebGUI','English','Edit File Settings');
INSERT INTO international VALUES (128,'WebGUI','Español','Editar Opciones de Archivos');
INSERT INTO international VALUES (128,'WebGUI','Português','Modificar preferências de ficheiros');
INSERT INTO international VALUES (129,'WebGUI','Deutsch','Pfad zu WebGUI Extras');
INSERT INTO international VALUES (129,'WebGUI','Dutch','Pad naar WebGUI extra\'s');
INSERT INTO international VALUES (129,'WebGUI','English','Path to WebGUI Extras');
INSERT INTO international VALUES (129,'WebGUI','Español','Camino a Extras de WebGUI');
INSERT INTO international VALUES (129,'WebGUI','Português','Caminho para os extras do WebGUI');
INSERT INTO international VALUES (130,'WebGUI','Deutsch','Maximale Dateigröße für Anhänge');
INSERT INTO international VALUES (130,'WebGUI','Dutch','Maximum grootte bijlagen');
INSERT INTO international VALUES (130,'WebGUI','English','Maximum Attachment Size');
INSERT INTO international VALUES (130,'WebGUI','Español','Tamaño máximo de adjuntos');
INSERT INTO international VALUES (130,'WebGUI','Português','Tamanho máximo dos anexos');
INSERT INTO international VALUES (131,'WebGUI','Deutsch','Pfad für Dateianhänge im Web');
INSERT INTO international VALUES (131,'WebGUI','Dutch','Web bijlage pad');
INSERT INTO international VALUES (131,'WebGUI','English','Web Attachment Path');
INSERT INTO international VALUES (131,'WebGUI','Español','Camino Web de los archivos adjuntos');
INSERT INTO international VALUES (131,'WebGUI','Português','caminho de anexos via web');
INSERT INTO international VALUES (132,'WebGUI','Deutsch','Pfad für Dateianhänge auf dem Server');
INSERT INTO international VALUES (132,'WebGUI','Dutch','Server bijlage pad');
INSERT INTO international VALUES (132,'WebGUI','English','Server Attachment Path');
INSERT INTO international VALUES (132,'WebGUI','Español','Camino en server de los archivos adjuntos');
INSERT INTO international VALUES (132,'WebGUI','Português','Caminho de anexos no servidor');
INSERT INTO international VALUES (133,'WebGUI','Deutsch','Maileinstellungen bearbeiten');
INSERT INTO international VALUES (133,'WebGUI','Dutch','Bewerk email instellingen');
INSERT INTO international VALUES (133,'WebGUI','English','Edit Mail Settings');
INSERT INTO international VALUES (133,'WebGUI','Español','Editar configuración de e-mail');
INSERT INTO international VALUES (133,'WebGUI','Português','Modificar preferências de e-mail');
INSERT INTO international VALUES (134,'WebGUI','Deutsch','Passwortmeldung wiederherstellen');
INSERT INTO international VALUES (134,'WebGUI','Dutch','Bericht om wachtwoord terug te vinden');
INSERT INTO international VALUES (134,'WebGUI','English','Recover Password Message');
INSERT INTO international VALUES (134,'WebGUI','Español','Mensage de Recuperar Password');
INSERT INTO international VALUES (134,'WebGUI','Português','Mensagem de recuperação de password');
INSERT INTO international VALUES (135,'WebGUI','Deutsch','SMTP Server');
INSERT INTO international VALUES (135,'WebGUI','Dutch','SMTP server');
INSERT INTO international VALUES (135,'WebGUI','English','SMTP Server');
INSERT INTO international VALUES (135,'WebGUI','Español','Servidor SMTP');
INSERT INTO international VALUES (135,'WebGUI','Português','Servidor SMTP');
INSERT INTO international VALUES (136,'WebGUI','Deutsch','Homepage');
INSERT INTO international VALUES (136,'WebGUI','Dutch','Home pagina');
INSERT INTO international VALUES (136,'WebGUI','English','Home Page');
INSERT INTO international VALUES (136,'WebGUI','Español','Página de Inicio');
INSERT INTO international VALUES (136,'WebGUI','Português','Página inicial');
INSERT INTO international VALUES (137,'WebGUI','Deutsch','\"Seite wurde nicht gefunden\" Seite');
INSERT INTO international VALUES (137,'WebGUI','Dutch','Pagina niet gevonden\' pagina');
INSERT INTO international VALUES (137,'WebGUI','English','Page Not Found Page');
INSERT INTO international VALUES (137,'WebGUI','Español','Página: Página No Encontrada');
INSERT INTO international VALUES (137,'WebGUI','Português','Página de página não encontrada');
INSERT INTO international VALUES (138,'WebGUI','Deutsch','Ja');
INSERT INTO international VALUES (138,'WebGUI','Dutch','Ja');
INSERT INTO international VALUES (138,'WebGUI','English','Yes');
INSERT INTO international VALUES (138,'WebGUI','Español','Si');
INSERT INTO international VALUES (138,'WebGUI','Português','Sim');
INSERT INTO international VALUES (139,'WebGUI','Deutsch','Nein');
INSERT INTO international VALUES (139,'WebGUI','Dutch','Nee');
INSERT INTO international VALUES (139,'WebGUI','English','No');
INSERT INTO international VALUES (139,'WebGUI','Español','No');
INSERT INTO international VALUES (139,'WebGUI','Português','Não');
INSERT INTO international VALUES (140,'WebGUI','Deutsch','Sonstige Einstellungen bearbeiten');
INSERT INTO international VALUES (140,'WebGUI','Dutch','Bewerk allerlei instellingen');
INSERT INTO international VALUES (140,'WebGUI','English','Edit Miscellaneous Settings');
INSERT INTO international VALUES (140,'WebGUI','Español','Editar configuraciones misceláneas');
INSERT INTO international VALUES (140,'WebGUI','Português','Modificar preferências mistas');
INSERT INTO international VALUES (141,'WebGUI','Deutsch','\"Nicht gefunden Seite\"');
INSERT INTO international VALUES (141,'WebGUI','Dutch','Niet gevonden pagina');
INSERT INTO international VALUES (141,'WebGUI','English','Not Found Page');
INSERT INTO international VALUES (141,'WebGUI','Español','Página no encontrada');
INSERT INTO international VALUES (141,'WebGUI','Português','Página não encontrada');
INSERT INTO international VALUES (142,'WebGUI','Deutsch','Sitzungs Zeitüberschreitung');
INSERT INTO international VALUES (142,'WebGUI','Dutch','Sessie time out');
INSERT INTO international VALUES (142,'WebGUI','English','Session Timeout');
INSERT INTO international VALUES (142,'WebGUI','Español','Timeout de sesión');
INSERT INTO international VALUES (142,'WebGUI','Português','Timeout de sessão');
INSERT INTO international VALUES (143,'WebGUI','Deutsch','Einstellungen verwalten');
INSERT INTO international VALUES (143,'WebGUI','Dutch','Beheer instellingen.');
INSERT INTO international VALUES (143,'WebGUI','English','Manage Settings');
INSERT INTO international VALUES (143,'WebGUI','Español','Configurar Opciones');
INSERT INTO international VALUES (143,'WebGUI','Português','Organizar preferências');
INSERT INTO international VALUES (144,'WebGUI','Deutsch','Auswertungen anschauen');
INSERT INTO international VALUES (144,'WebGUI','Dutch','Bekijk statistieken');
INSERT INTO international VALUES (144,'WebGUI','English','View statistics.');
INSERT INTO international VALUES (144,'WebGUI','Español','Ver estadísticas');
INSERT INTO international VALUES (144,'WebGUI','Português','Ver estatisticas.');
INSERT INTO international VALUES (145,'WebGUI','Deutsch','WebGUI Build Version');
INSERT INTO international VALUES (145,'WebGUI','Dutch','WebGUI versie');
INSERT INTO international VALUES (145,'WebGUI','English','WebGUI Build Version');
INSERT INTO international VALUES (145,'WebGUI','Español','Versión de WebGUI');
INSERT INTO international VALUES (145,'WebGUI','Português','WebGUI versão');
INSERT INTO international VALUES (146,'WebGUI','Deutsch','Aktive Sitzungen');
INSERT INTO international VALUES (146,'WebGUI','Dutch','Aktieve sessies');
INSERT INTO international VALUES (146,'WebGUI','English','Active Sessions');
INSERT INTO international VALUES (146,'WebGUI','Español','Sesiones activas');
INSERT INTO international VALUES (146,'WebGUI','Português','Sessões activas');
INSERT INTO international VALUES (147,'WebGUI','Deutsch','sichtbare Seiten');
INSERT INTO international VALUES (147,'WebGUI','Dutch','Zichtbare pagina\'s');
INSERT INTO international VALUES (147,'WebGUI','English','Viewable Pages');
INSERT INTO international VALUES (147,'WebGUI','Español','Páginas Visibles');
INSERT INTO international VALUES (147,'WebGUI','Português','páginas visiveis');
INSERT INTO international VALUES (148,'WebGUI','Deutsch','sichtbare Widgets');
INSERT INTO international VALUES (148,'WebGUI','Dutch','Zichtbare widgets');
INSERT INTO international VALUES (148,'WebGUI','English','Viewable Widgets');
INSERT INTO international VALUES (148,'WebGUI','Español','Widgets Visibles');
INSERT INTO international VALUES (148,'WebGUI','Português','Widgets visiveis');
INSERT INTO international VALUES (149,'WebGUI','Deutsch','Benutzer');
INSERT INTO international VALUES (149,'WebGUI','Dutch','Gebruikers');
INSERT INTO international VALUES (149,'WebGUI','English','Users');
INSERT INTO international VALUES (149,'WebGUI','Español','Usuarios');
INSERT INTO international VALUES (149,'WebGUI','Português','Utilizadores');
INSERT INTO international VALUES (150,'WebGUI','Deutsch','Stil hinzufügen');
INSERT INTO international VALUES (150,'WebGUI','Dutch','Stijl toevoegen');
INSERT INTO international VALUES (150,'WebGUI','English','Add Style');
INSERT INTO international VALUES (150,'WebGUI','Español','Agregar Estilo');
INSERT INTO international VALUES (150,'WebGUI','Português','Adicionar estilo');
INSERT INTO international VALUES (151,'WebGUI','Deutsch','Stil Name');
INSERT INTO international VALUES (151,'WebGUI','Dutch','Stijl naam');
INSERT INTO international VALUES (151,'WebGUI','English','Style Name');
INSERT INTO international VALUES (151,'WebGUI','Español','Nombre del Estilo');
INSERT INTO international VALUES (151,'WebGUI','Português','Nome do estilo');
INSERT INTO international VALUES (152,'WebGUI','Deutsch','Kopfzeile');
INSERT INTO international VALUES (152,'WebGUI','Dutch','Koptekst');
INSERT INTO international VALUES (152,'WebGUI','English','Header');
INSERT INTO international VALUES (152,'WebGUI','Español','Encabezado');
INSERT INTO international VALUES (152,'WebGUI','Português','Cabeçalho');
INSERT INTO international VALUES (153,'WebGUI','Deutsch','Fußzeile');
INSERT INTO international VALUES (153,'WebGUI','Dutch','Voettekst');
INSERT INTO international VALUES (153,'WebGUI','English','Footer');
INSERT INTO international VALUES (153,'WebGUI','Español','Pie');
INSERT INTO international VALUES (153,'WebGUI','Português','Rodapé');
INSERT INTO international VALUES (154,'WebGUI','Deutsch','Style Sheet');
INSERT INTO international VALUES (154,'WebGUI','Dutch','Style sheet');
INSERT INTO international VALUES (154,'WebGUI','English','Style Sheet');
INSERT INTO international VALUES (154,'WebGUI','Español','Hoja de Estilo');
INSERT INTO international VALUES (154,'WebGUI','Português','Estilo de página');
INSERT INTO international VALUES (155,'WebGUI','Deutsch','Sind Sie sicher, dass Sie diesen Stil löschen und alle Seiten die diesen Stil benutzen in den Stil \"Fail Safe\" überführen wollen?');
INSERT INTO international VALUES (155,'WebGUI','Dutch','Weet u zeker dat u deze stijl wilt verwijderen en migreer alle pagina\'s met de “fail safe” stijl?');
INSERT INTO international VALUES (155,'WebGUI','English','Are you certain you wish to delete this style and migrate all pages using this style to the \"Fail Safe\" style?');
INSERT INTO international VALUES (155,'WebGUI','Español','\"Está seguro de querer eliminar éste estilo y migrar todas la páginas que lo usen al estilo \"\"Fail Safe\"\"?\"');
INSERT INTO international VALUES (155,'WebGUI','Português','\"Tem a certeza que quer apagar este estilo e migrar todas as páginas para o estilo \"\"Fail Safe\"\"?\"');
INSERT INTO international VALUES (156,'WebGUI','Deutsch','Stil bearbeiten');
INSERT INTO international VALUES (156,'WebGUI','Dutch','Bewerk stijl');
INSERT INTO international VALUES (156,'WebGUI','English','Edit Style');
INSERT INTO international VALUES (156,'WebGUI','Español','Editar Estilo');
INSERT INTO international VALUES (156,'WebGUI','Português','Modificar estilo');
INSERT INTO international VALUES (157,'WebGUI','Deutsch','Stile');
INSERT INTO international VALUES (157,'WebGUI','Dutch','Stijlen');
INSERT INTO international VALUES (157,'WebGUI','English','Styles');
INSERT INTO international VALUES (157,'WebGUI','Español','Estilos');
INSERT INTO international VALUES (157,'WebGUI','Português','Estilos');
INSERT INTO international VALUES (158,'WebGUI','Deutsch','Neuen Stil hinzufügen');
INSERT INTO international VALUES (158,'WebGUI','Dutch','Een nieuwe stijl toevoegen.');
INSERT INTO international VALUES (158,'WebGUI','English','Add a new style.');
INSERT INTO international VALUES (158,'WebGUI','Español','Agregar nuevo Estilo');
INSERT INTO international VALUES (158,'WebGUI','Português','Adicionar novo estilo.');
INSERT INTO international VALUES (159,'WebGUI','Deutsch','Ausstehende Beiträge');
INSERT INTO international VALUES (159,'WebGUI','Dutch','Berichten log');
INSERT INTO international VALUES (159,'WebGUI','English','Message Log');
INSERT INTO international VALUES (159,'WebGUI','Español','Contribuciones Pendientes');
INSERT INTO international VALUES (159,'WebGUI','Português','Log das mensagens');
INSERT INTO international VALUES (160,'WebGUI','Deutsch','Erstellungsdatum');
INSERT INTO international VALUES (160,'WebGUI','Dutch','Invoer datum');
INSERT INTO international VALUES (160,'WebGUI','English','Date Submitted');
INSERT INTO international VALUES (160,'WebGUI','Español','Fecha Contribución');
INSERT INTO international VALUES (160,'WebGUI','Português','Data de submissão');
INSERT INTO international VALUES (161,'WebGUI','Deutsch','Erstellt von');
INSERT INTO international VALUES (161,'WebGUI','Dutch','Ingevoerd door');
INSERT INTO international VALUES (161,'WebGUI','English','Submitted By');
INSERT INTO international VALUES (161,'WebGUI','Español','Contribuido por');
INSERT INTO international VALUES (161,'WebGUI','Português','Submetido por');
INSERT INTO international VALUES (162,'WebGUI','Deutsch','Sind Sie sicher, dass Sie alle Seiten und Widgets im Mülleimer löschen möchten?');
INSERT INTO international VALUES (162,'WebGUI','Dutch','Weet u zeker dat u alle pagina\'s en widgets uit de prullenbak wilt verwijderen?');
INSERT INTO international VALUES (162,'WebGUI','English','Are you certain that you wish to purge all the pages and widgets in the trash?');
INSERT INTO international VALUES (162,'WebGUI','Español','Está seguro de querer eliminar todos los elementos de la papelera?');
INSERT INTO international VALUES (162,'WebGUI','Português','Tem a certeza que quer limpar todas as páginas e widgets para o caixote do lixo?');
INSERT INTO international VALUES (163,'WebGUI','Deutsch','Benutzer hinzufügen');
INSERT INTO international VALUES (163,'WebGUI','Dutch','Gebruiker toevoegen');
INSERT INTO international VALUES (163,'WebGUI','English','Add User');
INSERT INTO international VALUES (163,'WebGUI','Español','Agregar usuario');
INSERT INTO international VALUES (163,'WebGUI','Português','Adicionar utilizador');
INSERT INTO international VALUES (164,'WebGUI','Deutsch','Authentifizierungsmethode');
INSERT INTO international VALUES (164,'WebGUI','Dutch','Toegangs controle methode');
INSERT INTO international VALUES (164,'WebGUI','English','Authentication Method');
INSERT INTO international VALUES (164,'WebGUI','Español','Método de Auntentificación');
INSERT INTO international VALUES (164,'WebGUI','Português','Metodo de autenticação');
INSERT INTO international VALUES (165,'WebGUI','Deutsch','LDAP URL');
INSERT INTO international VALUES (165,'WebGUI','Dutch','LDAP URL');
INSERT INTO international VALUES (165,'WebGUI','English','LDAP URL');
INSERT INTO international VALUES (165,'WebGUI','Español','LDAP URL');
INSERT INTO international VALUES (165,'WebGUI','Português','LDAP URL');
INSERT INTO international VALUES (166,'WebGUI','Deutsch','Connect DN');
INSERT INTO international VALUES (166,'WebGUI','Dutch','Verbindt DN');
INSERT INTO international VALUES (166,'WebGUI','English','Connect DN');
INSERT INTO international VALUES (166,'WebGUI','Español','Connect DN');
INSERT INTO international VALUES (166,'WebGUI','Português','Connectar DN');
INSERT INTO international VALUES (167,'WebGUI','Deutsch','Sind Sie sicher, dass sie diesen Benutzer löschen möchten? Die Benutzerinformation geht damit endgültig verloren!');
INSERT INTO international VALUES (167,'WebGUI','Dutch','Weet u zeker dat u deze gebruiker wilt verwijderen? Alle gebruikersinformatie wordt permanent verwijdert als u door gaat.');
INSERT INTO international VALUES (167,'WebGUI','English','Are you certain you want to delete this user? Be warned that all this user\'s information will be lost permanently if you choose to proceed.');
INSERT INTO international VALUES (167,'WebGUI','Español','Está seguro de querer eliminar éste usuario? Tenga en cuenta que toda la información del usuario será eliminada permanentemente si procede.');
INSERT INTO international VALUES (167,'WebGUI','Português','Tem a certeza que quer apagar este utilizador? Se o fizer perde todas as informações do utilizador.');
INSERT INTO international VALUES (168,'WebGUI','Deutsch','Benutzer bearbeiten');
INSERT INTO international VALUES (168,'WebGUI','Dutch','Bewerk gebruiker');
INSERT INTO international VALUES (168,'WebGUI','English','Edit User');
INSERT INTO international VALUES (168,'WebGUI','Español','Editar Usuario');
INSERT INTO international VALUES (168,'WebGUI','Português','Modificar utilizador');
INSERT INTO international VALUES (169,'WebGUI','Deutsch','Neuen Benutzer hinzufügen');
INSERT INTO international VALUES (169,'WebGUI','Dutch','Een nieuwe gebruiker toevoegen.');
INSERT INTO international VALUES (169,'WebGUI','English','Add a new user.');
INSERT INTO international VALUES (169,'WebGUI','Español','Agregar nuevo usuario');
INSERT INTO international VALUES (169,'WebGUI','Português','Adicionar utilizador.');
INSERT INTO international VALUES (170,'WebGUI','Deutsch','suchen');
INSERT INTO international VALUES (170,'WebGUI','Dutch','Zoeken');
INSERT INTO international VALUES (170,'WebGUI','English','search');
INSERT INTO international VALUES (170,'WebGUI','Español','buscar');
INSERT INTO international VALUES (170,'WebGUI','Português','procurar');
INSERT INTO international VALUES (171,'WebGUI','Deutsch','Bearbeiten mit Attributen');
INSERT INTO international VALUES (171,'WebGUI','Dutch','Rich edit');
INSERT INTO international VALUES (171,'WebGUI','English','rich edit');
INSERT INTO international VALUES (171,'WebGUI','Español','rich edit');
INSERT INTO international VALUES (171,'WebGUI','Português','rich edit');
INSERT INTO international VALUES (174,'WebGUI','Deutsch','Titel anzeigen?');
INSERT INTO international VALUES (174,'WebGUI','Dutch','Titel laten zien?');
INSERT INTO international VALUES (174,'WebGUI','English','Display the title?');
INSERT INTO international VALUES (174,'WebGUI','Español','Mostrar el título?');
INSERT INTO international VALUES (174,'WebGUI','Português','Mostrar o titulo?');
INSERT INTO international VALUES (175,'WebGUI','Deutsch','Makros ausführen?');
INSERT INTO international VALUES (175,'WebGUI','Dutch','Macro\'s uitvoeren?');
INSERT INTO international VALUES (175,'WebGUI','English','Process macros?');
INSERT INTO international VALUES (175,'WebGUI','Español','Procesar macros?');
INSERT INTO international VALUES (175,'WebGUI','Português','Processar macros?');
INSERT INTO international VALUES (228,'WebGUI','Deutsch','Beiträge bearbeiten ...');
INSERT INTO international VALUES (228,'WebGUI','Dutch','Bewerk bericht...');
INSERT INTO international VALUES (228,'WebGUI','English','Editing Message...');
INSERT INTO international VALUES (228,'WebGUI','Español','Editar Mensage...');
INSERT INTO international VALUES (228,'WebGUI','Português','Modificando mensagem...');
INSERT INTO international VALUES (229,'WebGUI','Deutsch','Betreff');
INSERT INTO international VALUES (229,'WebGUI','Dutch','Onderwerp');
INSERT INTO international VALUES (229,'WebGUI','English','Subject');
INSERT INTO international VALUES (229,'WebGUI','Español','Asunto');
INSERT INTO international VALUES (229,'WebGUI','Português','Assunto');
INSERT INTO international VALUES (230,'WebGUI','Deutsch','Beitrag');
INSERT INTO international VALUES (230,'WebGUI','Dutch','Bericht');
INSERT INTO international VALUES (230,'WebGUI','English','Message');
INSERT INTO international VALUES (230,'WebGUI','Español','Mensage');
INSERT INTO international VALUES (230,'WebGUI','Português','Mensagem');
INSERT INTO international VALUES (231,'WebGUI','Deutsch','Neuen Beitrag schreiben...');
INSERT INTO international VALUES (231,'WebGUI','Dutch','Bezig met bericht posten...');
INSERT INTO international VALUES (231,'WebGUI','English','Posting New Message...');
INSERT INTO international VALUES (231,'WebGUI','Español','Mandando Nuevo Mensage ...');
INSERT INTO international VALUES (231,'WebGUI','Português','Colocando nova mensagem...');
INSERT INTO international VALUES (232,'WebGUI','Deutsch','kein Betreff');
INSERT INTO international VALUES (232,'WebGUI','Dutch','Geen onderwerp');
INSERT INTO international VALUES (232,'WebGUI','English','no subject');
INSERT INTO international VALUES (232,'WebGUI','Español','sin título');
INSERT INTO international VALUES (232,'WebGUI','Português','sem assunto');
INSERT INTO international VALUES (233,'WebGUI','Deutsch','(eom)');
INSERT INTO international VALUES (233,'WebGUI','Dutch','(einde)');
INSERT INTO international VALUES (233,'WebGUI','English','(eom)');
INSERT INTO international VALUES (233,'WebGUI','Español','(eom)');
INSERT INTO international VALUES (233,'WebGUI','Português','(eom)');
INSERT INTO international VALUES (234,'WebGUI','Deutsch','Antworten...');
INSERT INTO international VALUES (234,'WebGUI','Dutch','Bezig met antwoord posten');
INSERT INTO international VALUES (234,'WebGUI','English','Posting Reply...');
INSERT INTO international VALUES (234,'WebGUI','Español','Respondiendo...');
INSERT INTO international VALUES (234,'WebGUI','Português','Respondendo...');
INSERT INTO international VALUES (237,'WebGUI','Deutsch','Betreff:');
INSERT INTO international VALUES (237,'WebGUI','Dutch','Onderwerp:');
INSERT INTO international VALUES (237,'WebGUI','English','Subject:');
INSERT INTO international VALUES (237,'WebGUI','Español','Asunto:');
INSERT INTO international VALUES (237,'WebGUI','Português','Assunto:');
INSERT INTO international VALUES (238,'WebGUI','Deutsch','Autor:');
INSERT INTO international VALUES (238,'WebGUI','Dutch','Naam:');
INSERT INTO international VALUES (238,'WebGUI','English','Author:');
INSERT INTO international VALUES (238,'WebGUI','Español','Autor:');
INSERT INTO international VALUES (238,'WebGUI','Português','Autor:');
INSERT INTO international VALUES (239,'WebGUI','Deutsch','Datum:');
INSERT INTO international VALUES (239,'WebGUI','Dutch','Datum:');
INSERT INTO international VALUES (239,'WebGUI','English','Date:');
INSERT INTO international VALUES (239,'WebGUI','Español','Fecha:');
INSERT INTO international VALUES (239,'WebGUI','Português','Data:');
INSERT INTO international VALUES (240,'WebGUI','Deutsch','Beitrags ID:');
INSERT INTO international VALUES (240,'WebGUI','Dutch','Bericht ID:');
INSERT INTO international VALUES (240,'WebGUI','English','Message ID:');
INSERT INTO international VALUES (240,'WebGUI','Español','ID del mensage:');
INSERT INTO international VALUES (240,'WebGUI','Português','ID da mensagem:');
INSERT INTO international VALUES (244,'WebGUI','Deutsch','Autor');
INSERT INTO international VALUES (244,'WebGUI','Dutch','Afzender');
INSERT INTO international VALUES (244,'WebGUI','English','Author');
INSERT INTO international VALUES (244,'WebGUI','Español','Autor');
INSERT INTO international VALUES (244,'WebGUI','Português','Autor');
INSERT INTO international VALUES (245,'WebGUI','Deutsch','Datum');
INSERT INTO international VALUES (245,'WebGUI','Dutch','Datum');
INSERT INTO international VALUES (245,'WebGUI','English','Date');
INSERT INTO international VALUES (245,'WebGUI','Español','Fecha');
INSERT INTO international VALUES (245,'WebGUI','Português','Data');
INSERT INTO international VALUES (304,'WebGUI','Deutsch','Sprache');
INSERT INTO international VALUES (304,'WebGUI','Dutch','Taal');
INSERT INTO international VALUES (304,'WebGUI','English','Language');
INSERT INTO international VALUES (304,'WebGUI','Español','Idioma');
INSERT INTO international VALUES (304,'WebGUI','Português','Lingua');
INSERT INTO international VALUES (306,'WebGUI','Deutsch','Benutze LDAP Benutzername');
INSERT INTO international VALUES (306,'WebGUI','Dutch','Bind gebruikersnaam');
INSERT INTO international VALUES (306,'WebGUI','English','Username Binding');
INSERT INTO international VALUES (306,'WebGUI','Português','Ligação ao username');
INSERT INTO international VALUES (307,'WebGUI','Deutsch','Standard Meta Tags benutzen?');
INSERT INTO international VALUES (307,'WebGUI','Dutch','Gebruik standaard metag tags?');
INSERT INTO international VALUES (307,'WebGUI','English','Use default meta tags?');
INSERT INTO international VALUES (307,'WebGUI','Português','Usar as meta tags de defeito?');
INSERT INTO international VALUES (308,'WebGUI','Deutsch','Profil bearbeiten');
INSERT INTO international VALUES (308,'WebGUI','Dutch','Bewerk profiel instellingen');
INSERT INTO international VALUES (308,'WebGUI','English','Edit Profile Settings');
INSERT INTO international VALUES (308,'WebGUI','Português','Modificar as preferências do perfil');
INSERT INTO international VALUES (309,'WebGUI','Deutsch','Name anzeigen?');
INSERT INTO international VALUES (309,'WebGUI','Dutch','Sta echte naam toe?');
INSERT INTO international VALUES (309,'WebGUI','English','Allow real name?');
INSERT INTO international VALUES (309,'WebGUI','Português','Permitir o nome real?');
INSERT INTO international VALUES (310,'WebGUI','Deutsch','Kontaktinformationen anzeigen?');
INSERT INTO international VALUES (310,'WebGUI','Dutch','Sta extra contact informatie toe?');
INSERT INTO international VALUES (310,'WebGUI','English','Allow extra contact information?');
INSERT INTO international VALUES (310,'WebGUI','Português','Permitir informação extra de contacto?');
INSERT INTO international VALUES (311,'WebGUI','Deutsch','Privatadresse anzeigen?');
INSERT INTO international VALUES (311,'WebGUI','Dutch','Sta thuis informatie toe?');
INSERT INTO international VALUES (311,'WebGUI','English','Allow home information?');
INSERT INTO international VALUES (311,'WebGUI','Português','Permitir informação de casa?');
INSERT INTO international VALUES (312,'WebGUI','Deutsch','Geschäftsadresse anzeigen?');
INSERT INTO international VALUES (312,'WebGUI','Dutch','Sta bedrijfs informatie toe?');
INSERT INTO international VALUES (312,'WebGUI','English','Allow business information?');
INSERT INTO international VALUES (312,'WebGUI','Português','Permitir informação do emprego?');
INSERT INTO international VALUES (313,'WebGUI','Deutsch','Zusätzliche Informationen anzeigen?');
INSERT INTO international VALUES (313,'WebGUI','Dutch','Sta andere informatie toe?');
INSERT INTO international VALUES (313,'WebGUI','English','Allow miscellaneous information?');
INSERT INTO international VALUES (313,'WebGUI','Português','Permitir informaçao mista?');
INSERT INTO international VALUES (314,'WebGUI','Deutsch','Vorname');
INSERT INTO international VALUES (314,'WebGUI','Dutch','Voornaam');
INSERT INTO international VALUES (314,'WebGUI','English','First Name');
INSERT INTO international VALUES (314,'WebGUI','Português','Nome');
INSERT INTO international VALUES (315,'WebGUI','Deutsch','Zweiter Vorname');
INSERT INTO international VALUES (315,'WebGUI','Dutch','Tussenvoegsel');
INSERT INTO international VALUES (315,'WebGUI','English','Middle Name');
INSERT INTO international VALUES (315,'WebGUI','Português','segundo(s) nome(s)');
INSERT INTO international VALUES (316,'WebGUI','Deutsch','Nachname');
INSERT INTO international VALUES (316,'WebGUI','Dutch','Achternaam');
INSERT INTO international VALUES (316,'WebGUI','English','Last Name');
INSERT INTO international VALUES (316,'WebGUI','Português','Apelido');
INSERT INTO international VALUES (317,'WebGUI','Deutsch','<a href=\"\"http://www.icq.com\"\">ICQ</a> UIN');
INSERT INTO international VALUES (317,'WebGUI','Dutch','\"<a href=\"\"http://www.icq.com\"\">ICQ</a> UIN\"');
INSERT INTO international VALUES (317,'WebGUI','English','<a href=\"http://www.icq.com\">ICQ</a> UIN');
INSERT INTO international VALUES (317,'WebGUI','Português','\"<a href=\"\"http://www.icq.com\"\">ICQ</a> UIN\"');
INSERT INTO international VALUES (318,'WebGUI','Deutsch','<a href=\"\"http://www.aol.com/aim/homenew.adp\"\">AIM</a> Id');
INSERT INTO international VALUES (318,'WebGUI','Dutch','\"<a href=\"\"http://www.aol.com/aim/homenew.adp\"\">AIM</a> Id\"');
INSERT INTO international VALUES (318,'WebGUI','English','<a href=\"http://www.aol.com/aim/homenew.adp\">AIM</a> Id');
INSERT INTO international VALUES (318,'WebGUI','Português','\"<a href=\"\"http://www.aol.com/aim/homenew.adp\"\">AIM</a> Id\"');
INSERT INTO international VALUES (319,'WebGUI','Deutsch','<a href=\"\"http://messenger.msn.com/\"\">MSN Messenger</a> Id');
INSERT INTO international VALUES (319,'WebGUI','Dutch','\"<a href=\"\"http://messenger.msn.com/\"\">MSN Messenger</a> Id\"');
INSERT INTO international VALUES (319,'WebGUI','English','<a href=\"http://messenger.msn.com/\">MSN Messenger</a> Id');
INSERT INTO international VALUES (319,'WebGUI','Português','\"<a href=\"\"http://messenger.msn.com/\"\">MSN Messenger</a> Id\"');
INSERT INTO international VALUES (320,'WebGUI','Deutsch','<a href=\"\"http://messenger.yahoo.com/\"\">Yahoo! Messenger</a> Id');
INSERT INTO international VALUES (320,'WebGUI','Dutch','\"<a href=\"\"http://messenger.yahoo.com/\"\">Yahoo! Messenger</a> Id\"');
INSERT INTO international VALUES (320,'WebGUI','English','<a href=\"http://messenger.yahoo.com/\">Yahoo! Messenger</a> Id');
INSERT INTO international VALUES (320,'WebGUI','Português','\"<a href=\"\"http://messenger.yahoo.com/\"\">Yahoo! Messenger</a> Id\"');
INSERT INTO international VALUES (321,'WebGUI','Deutsch','Mobiltelefon');
INSERT INTO international VALUES (321,'WebGUI','Dutch','Mobiel nummer');
INSERT INTO international VALUES (321,'WebGUI','English','Cell Phone');
INSERT INTO international VALUES (321,'WebGUI','Português','Telemóvel');
INSERT INTO international VALUES (322,'WebGUI','Deutsch','Pager');
INSERT INTO international VALUES (322,'WebGUI','Dutch','Pager');
INSERT INTO international VALUES (322,'WebGUI','English','Pager');
INSERT INTO international VALUES (322,'WebGUI','Português','Pager');
INSERT INTO international VALUES (323,'WebGUI','Deutsch','Strasse (privat)');
INSERT INTO international VALUES (323,'WebGUI','Dutch','Thuis adres');
INSERT INTO international VALUES (323,'WebGUI','English','Home Address');
INSERT INTO international VALUES (323,'WebGUI','Português','Morada (de casa)');
INSERT INTO international VALUES (324,'WebGUI','Deutsch','Ort (privat)');
INSERT INTO international VALUES (324,'WebGUI','Dutch','Thuis plaats');
INSERT INTO international VALUES (324,'WebGUI','English','Home City');
INSERT INTO international VALUES (324,'WebGUI','Português','Cidade (de casa)');
INSERT INTO international VALUES (325,'WebGUI','Deutsch','Bundesland (privat)');
INSERT INTO international VALUES (325,'WebGUI','Dutch','Thuis staat');
INSERT INTO international VALUES (325,'WebGUI','English','Home State');
INSERT INTO international VALUES (325,'WebGUI','Português','Concelho (de casa)');
INSERT INTO international VALUES (326,'WebGUI','Deutsch','Postleitzahl (privat)');
INSERT INTO international VALUES (326,'WebGUI','Dutch','Thuis postcode');
INSERT INTO international VALUES (326,'WebGUI','English','Home Zip Code');
INSERT INTO international VALUES (326,'WebGUI','Português','Código postal (de casa)');
INSERT INTO international VALUES (327,'WebGUI','Deutsch','Land (privat)');
INSERT INTO international VALUES (327,'WebGUI','Dutch','Thuis land');
INSERT INTO international VALUES (327,'WebGUI','English','Home Country');
INSERT INTO international VALUES (327,'WebGUI','Português','País (de casa)');
INSERT INTO international VALUES (328,'WebGUI','Deutsch','Telefon (privat)');
INSERT INTO international VALUES (328,'WebGUI','Dutch','Thuis telefoon');
INSERT INTO international VALUES (328,'WebGUI','English','Home Phone');
INSERT INTO international VALUES (328,'WebGUI','Português','Telefone (de casa)');
INSERT INTO international VALUES (329,'WebGUI','Deutsch','Strasse (Büro)');
INSERT INTO international VALUES (329,'WebGUI','Dutch','Werk adres');
INSERT INTO international VALUES (329,'WebGUI','English','Work Address');
INSERT INTO international VALUES (329,'WebGUI','Português','Morada (do emprego)');
INSERT INTO international VALUES (330,'WebGUI','Deutsch','Ort (Büro)');
INSERT INTO international VALUES (330,'WebGUI','Dutch','Werk stad');
INSERT INTO international VALUES (330,'WebGUI','English','Work City');
INSERT INTO international VALUES (330,'WebGUI','Português','Cidade (do emprego)');
INSERT INTO international VALUES (331,'WebGUI','Deutsch','Bundesland (Büro)');
INSERT INTO international VALUES (331,'WebGUI','Dutch','Werk staat');
INSERT INTO international VALUES (331,'WebGUI','English','Work State');
INSERT INTO international VALUES (331,'WebGUI','Português','Concelho (do emprego)');
INSERT INTO international VALUES (332,'WebGUI','Deutsch','Postleitzahl (Büro)');
INSERT INTO international VALUES (332,'WebGUI','Dutch','Werk postcode');
INSERT INTO international VALUES (332,'WebGUI','English','Work Zip Code');
INSERT INTO international VALUES (332,'WebGUI','Português','Código postal (do emprego)');
INSERT INTO international VALUES (333,'WebGUI','Deutsch','Land (Büro)');
INSERT INTO international VALUES (333,'WebGUI','Dutch','Werk land');
INSERT INTO international VALUES (333,'WebGUI','English','Work Country');
INSERT INTO international VALUES (333,'WebGUI','Português','País (do emprego)');
INSERT INTO international VALUES (334,'WebGUI','Deutsch','Telefon (Büro)');
INSERT INTO international VALUES (334,'WebGUI','Dutch','Werk telefoon');
INSERT INTO international VALUES (334,'WebGUI','English','Work Phone');
INSERT INTO international VALUES (334,'WebGUI','Português','Telefone (do emprego)');
INSERT INTO international VALUES (335,'WebGUI','Deutsch','Geschlecht');
INSERT INTO international VALUES (335,'WebGUI','Dutch','Sexe');
INSERT INTO international VALUES (335,'WebGUI','English','Gender');
INSERT INTO international VALUES (335,'WebGUI','Português','Sexo');
INSERT INTO international VALUES (336,'WebGUI','Deutsch','Geburtstag');
INSERT INTO international VALUES (336,'WebGUI','Dutch','Geboortedatum');
INSERT INTO international VALUES (336,'WebGUI','English','Birth Date');
INSERT INTO international VALUES (336,'WebGUI','Português','Data de nascimento');
INSERT INTO international VALUES (337,'WebGUI','Deutsch','Homepage URL');
INSERT INTO international VALUES (337,'WebGUI','Dutch','Home pagina URL');
INSERT INTO international VALUES (337,'WebGUI','English','Homepage URL');
INSERT INTO international VALUES (337,'WebGUI','Português','Endereço da Homepage');
INSERT INTO international VALUES (338,'WebGUI','Deutsch','Profil bearbeiten');
INSERT INTO international VALUES (338,'WebGUI','Dutch','Bewerk profiel');
INSERT INTO international VALUES (338,'WebGUI','English','Edit Profile');
INSERT INTO international VALUES (338,'WebGUI','Português','Modificar perfil');
INSERT INTO international VALUES (339,'WebGUI','Deutsch','männlich');
INSERT INTO international VALUES (339,'WebGUI','Dutch','Man');
INSERT INTO international VALUES (339,'WebGUI','English','Male');
INSERT INTO international VALUES (339,'WebGUI','Português','Masculino');
INSERT INTO international VALUES (340,'WebGUI','Deutsch','weiblich');
INSERT INTO international VALUES (340,'WebGUI','Dutch','Vrouw');
INSERT INTO international VALUES (340,'WebGUI','English','Female');
INSERT INTO international VALUES (340,'WebGUI','Português','Feminino');
INSERT INTO international VALUES (341,'WebGUI','Deutsch','Profil bearbeiten.');
INSERT INTO international VALUES (341,'WebGUI','Dutch','Bewerk profiel.');
INSERT INTO international VALUES (341,'WebGUI','English','Edit profile.');
INSERT INTO international VALUES (341,'WebGUI','Português','Modificar o perfil.');
INSERT INTO international VALUES (342,'WebGUI','Deutsch','Benutzerkonto bearbeiten.');
INSERT INTO international VALUES (342,'WebGUI','Dutch','Bewerk account informatie.');
INSERT INTO international VALUES (342,'WebGUI','English','Edit account information.');
INSERT INTO international VALUES (342,'WebGUI','Português','Modificar as informações da conta.');
INSERT INTO international VALUES (343,'WebGUI','Deutsch','Profil anschauen.');
INSERT INTO international VALUES (343,'WebGUI','Dutch','Bekijk profiel.');
INSERT INTO international VALUES (343,'WebGUI','English','View profile.');
INSERT INTO international VALUES (343,'WebGUI','Português','Ver perfil.');
INSERT INTO international VALUES (344,'WebGUI','Dutch','Bekijk berichten log.');
INSERT INTO international VALUES (344,'WebGUI','English','View message log.');
INSERT INTO international VALUES (344,'WebGUI','Português','Ver log de mensagens');
INSERT INTO international VALUES (345,'WebGUI','Deutsch','Kein Mitglied');
INSERT INTO international VALUES (345,'WebGUI','Dutch','Geen lid');
INSERT INTO international VALUES (345,'WebGUI','English','Not A Member');
INSERT INTO international VALUES (345,'WebGUI','Português','Não é membro');
INSERT INTO international VALUES (346,'WebGUI','Deutsch','Dieser Benutzer ist kein Mitglied. Wir haben keine weiteren Informationen über ihn.');
INSERT INTO international VALUES (346,'WebGUI','Dutch','Deze gebruiker in geen lid meer van onze site. We hebben geen informatie meer over deze gebruiker.');
INSERT INTO international VALUES (346,'WebGUI','English','This user is no longer a member of our site. We have no further information about this user.');
INSERT INTO international VALUES (346,'WebGUI','Português','Esse utilizador já não é membro do site. Não existe mais informação.');
INSERT INTO international VALUES (347,'WebGUI','Deutsch','Profil anschauen von');
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
INSERT INTO international VALUES (351,'WebGUI','English','Message Log Entry');
INSERT INTO international VALUES (351,'WebGUI','Português','Entrada no log de mensagens');
INSERT INTO international VALUES (352,'WebGUI','Dutch','Datum van toevoeging');
INSERT INTO international VALUES (352,'WebGUI','English','Date Of Entry');
INSERT INTO international VALUES (352,'WebGUI','Português','Data de entrada');
INSERT INTO international VALUES (353,'WebGUI','Dutch','U heeft nu geen berichten log toevoegingen.');
INSERT INTO international VALUES (353,'WebGUI','English','You have no message log entries at this time.');
INSERT INTO international VALUES (353,'WebGUI','Português','Actualmente não tem entradas no log de mensagens.');
INSERT INTO international VALUES (354,'WebGUI','Dutch','Bekijk berichten log.');
INSERT INTO international VALUES (354,'WebGUI','English','View message log.');
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
INSERT INTO international VALUES (374,'WebGUI','English','View packages.');
INSERT INTO international VALUES (375,'WebGUI','English','Select Package To Deploy');
INSERT INTO international VALUES (376,'WebGUI','English','Package');
INSERT INTO international VALUES (377,'WebGUI','English','No packages have been defined by your package manager(s) or administrator(s).');
INSERT INTO international VALUES (11,'Poll','English','Vote!');
INSERT INTO international VALUES (31,'UserSubmission','English','Content');
INSERT INTO international VALUES (32,'UserSubmission','English','Image');
INSERT INTO international VALUES (33,'UserSubmission','English','Attachement');
INSERT INTO international VALUES (34,'UserSubmission','English','Convert Carriage Returns');
INSERT INTO international VALUES (35,'UserSubmission','English','Title');
INSERT INTO international VALUES (36,'UserSubmission','English','Delete file.');
INSERT INTO international VALUES (378,'WebGUI','English','User ID');
INSERT INTO international VALUES (379,'WebGUI','English','Group ID');
INSERT INTO international VALUES (380,'WebGUI','English','Style ID');
INSERT INTO international VALUES (381,'WebGUI','English','WebGUI received a malformed request and was unable to continue. Proprietary characters being passed through a form typically cause this. Please feel free to hit your back button and try again.');
INSERT INTO international VALUES (1,'DownloadManager','English','Download Manager');
INSERT INTO international VALUES (2,'DownloadManager','English','Add Download Manager');
INSERT INTO international VALUES (3,'DownloadManager','English','Proceed to add file?');
INSERT INTO international VALUES (4,'DownloadManager','English','Add Download');
INSERT INTO international VALUES (5,'DownloadManager','English','File Title');
INSERT INTO international VALUES (6,'DownloadManager','English','Download File');
INSERT INTO international VALUES (7,'DownloadManager','English','Group to Download');
INSERT INTO international VALUES (8,'DownloadManager','English','Brief Synopsis');
INSERT INTO international VALUES (9,'DownloadManager','English','Edit Download Manager');
INSERT INTO international VALUES (10,'DownloadManager','English','Edit Download');
INSERT INTO international VALUES (11,'DownloadManager','English','Add a new download.');
INSERT INTO international VALUES (12,'DownloadManager','English','Are you certain that you wish to delete this download?');
INSERT INTO international VALUES (13,'DownloadManager','English','Delete attached file.');
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
INSERT INTO international VALUES (382,'WebGUI','English','Add Image');
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

#
# Table structure for table 'messageLog'
#

CREATE TABLE messageLog (
  messageLogId int(11) NOT NULL default '0',
  userId int(11) NOT NULL default '0',
  message text,
  url text,
  dateOfEntry int(11) default NULL,
  PRIMARY KEY  (messageLogId,userId)
) TYPE=MyISAM;

#
# Dumping data for table 'messageLog'
#


#
# Table structure for table 'page'
#

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
  template varchar(30) NOT NULL default 'Default',
  PRIMARY KEY  (pageId)
) TYPE=MyISAM;

#
# Dumping data for table 'page'
#

INSERT INTO page VALUES (1,0,'Home',-3,3,1,1,1,1,0,1,0,1,'','home',1,'Default');
INSERT INTO page VALUES (6,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL,0,'Default');
INSERT INTO page VALUES (7,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL,0,'Default');
INSERT INTO page VALUES (8,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL,0,'Default');
INSERT INTO page VALUES (9,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL,0,'Default');
INSERT INTO page VALUES (10,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL,0,'Default');
INSERT INTO page VALUES (11,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL,0,'Default');
INSERT INTO page VALUES (12,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL,0,'Default');
INSERT INTO page VALUES (13,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL,0,'Default');
INSERT INTO page VALUES (14,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL,0,'Default');
INSERT INTO page VALUES (15,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL,0,'Default');
INSERT INTO page VALUES (16,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL,0,'Default');
INSERT INTO page VALUES (17,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL,0,'Default');
INSERT INTO page VALUES (18,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL,0,'Default');
INSERT INTO page VALUES (19,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL,0,'Default');
INSERT INTO page VALUES (20,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL,0,'Default');
INSERT INTO page VALUES (21,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL,0,'Default');
INSERT INTO page VALUES (22,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL,0,'Default');
INSERT INTO page VALUES (23,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL,0,'Default');
INSERT INTO page VALUES (24,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL,0,'Default');
INSERT INTO page VALUES (25,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL,0,'Default');
INSERT INTO page VALUES (4,0,'Page Not Found',-3,3,1,1,1,1,0,1,0,1,'','page_not_found',0,'Default');
INSERT INTO page VALUES (3,0,'Trash',4,3,1,1,3,1,1,0,0,1,'','trash',0,'Default');
INSERT INTO page VALUES (2,0,'Clipboard',4,3,1,1,4,1,1,0,0,1,'','clipboard',0,'Default');
INSERT INTO page VALUES (5,0,'Packages',1,3,0,0,6,1,1,0,0,1,'','packages',0,'Default');

#
# Table structure for table 'session'
#

CREATE TABLE session (
  sessionId varchar(60) NOT NULL default '',
  expires int(11) default NULL,
  lastPageView int(11) default NULL,
  adminOn int(11) NOT NULL default '0',
  lastIP varchar(50) default NULL,
  userId int(11) default NULL,
  PRIMARY KEY  (sessionId)
) TYPE=MyISAM;

#
# Dumping data for table 'session'
#


#
# Table structure for table 'settings'
#

CREATE TABLE settings (
  name varchar(255) NOT NULL default '',
  value text,
  PRIMARY KEY  (name)
) TYPE=MyISAM;

#
# Dumping data for table 'settings'
#

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
INSERT INTO settings VALUES ('anonymousRegistration','yes');
INSERT INTO settings VALUES ('notFoundPage','1');
INSERT INTO settings VALUES ('recoverPasswordEmail','Someone (probably you) requested your account information be sent. Your password has been reset. The following represents your new account information:');
INSERT INTO settings VALUES ('usernameBinding','no');
INSERT INTO settings VALUES ('profileName','1');
INSERT INTO settings VALUES ('profileExtraContact','1');
INSERT INTO settings VALUES ('profileMisc','1');
INSERT INTO settings VALUES ('profileHome','0');
INSERT INTO settings VALUES ('profileWork','0');
INSERT INTO settings VALUES ('docTypeDec','<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">');
INSERT INTO settings VALUES ('preventProxyCache','0');

#
# Table structure for table 'style'
#

CREATE TABLE style (
  styleId int(11) NOT NULL default '0',
  name varchar(30) default NULL,
  header text,
  footer text,
  styleSheet text,
  PRIMARY KEY  (styleId)
) TYPE=MyISAM;

#
# Dumping data for table 'style'
#

INSERT INTO style VALUES (1,'Packages','<body>\r\n<table width=\"100%\"><tr><td valign=\"top\" width=\"30%\"><b>PACKAGES</b><br>^FlexMenu;</td><td valign=\"top\" width=\"70%\"><b>CONTENT</b><br>','</td></tr></table>\r\n<hr>\r\n^H; / ^a;\r\n</body>','<style>\r\n.adminBar {\r\n        background-color: #dddddd;\r\n        font-size: 8pt;\r\n        font-family: helvetica, arial;\r\n        color: #000055;\r\n}\r\n</style>');
INSERT INTO style VALUES (-3,'WebGUI','<body bgcolor=\"#000000\" text=\"#C9E200\" link=\"#ED4400\" marginwidth=\"0\" leftmargin=\"0\">\r\n<table width=\"100%\" cellpadding=0 cellspacing=0 border=0>\r\n<tr><td valign=\"top\" width=\"200\">\r\n<a href=\"/\"><img src=\"/extras/styles/webgui/logo.gif\" border=0></a>\r\n<table cellpadding=0 border=0 cellspacing=0>\r\n<tr><td colspan=3><img src=\"/extras/styles/webgui/menuTop.gif\" width=\"200\"></td></tr>\r\n<tr>\r\n  <td bgcolor=\"#C9E200\"><img src=\"/extras/spacer.gif\" width=5></td>\r\n  <td bgcolor=\"#C9E200\">^FlexMenu;</td>\r\n  <td bgcolor=\"#C9E200\"><img src=\"/extras/spacer.gif\" width=5></td>\r\n</tr>\r\n<tr><td colspan=3><img src=\"/extras/styles/webgui/menuBottom.gif\" width=\"200\"></td></tr>\r\n</table>\r\n^L;\r\n</td>\r\n<td><img src=\"/extras/spacer.gif\" width=20></td>\r\n<td valign=\"top\" width=\"100%\">\r\n\r\n','</td></tr></table>\r\n<p>\r\n<div align=\"center\">\r\n<a href=\"/\"><img src=\"/extras/styles/webgui/icon.gif\" border=0></a><br>\r\n©2001-2002 Plain Black Software<br>\r\n</div>\r\n</body>','<style>\r\n\r\n.content, body {\r\n  background-color: #000000;\r\n  color: #C9E200;\r\n  font-family: helvetica, arial;\r\n  font-size: 10pt;\r\n  scrollbar-base-color: #000000;\r\n  scrollbar-track-color: #444444;\r\n  scrollbar-face-color: #000000;\r\n  scrollbar-highlight-color: #555555;\r\n  scrollbar-3dlight-color: #444444;\r\n  scrollbar-darkshadow-color: #222222;\r\n  scrollbar-shadow-color: #333333;\r\n  scrollbar-arrow-color: #ED4400;\r\n}\r\n\r\nselect, input, textarea {\r\n  color: #000000;\r\n  background-color: #C9E200;\r\n}\r\n\r\nA {\r\n  color: #ED4400;\r\n}\r\n\r\nA:visited {\r\n  color: #ffffff;\r\n}\r\n\r\n.verticalMenu {\r\n  font-size: 10pt;\r\n}\r\n\r\n.verticalMenu A, .verticalMenu A:visited {\r\n  color: #000000;\r\n}\r\n\r\n.verticalMenu A:hover {\r\n  color: #ED4400;\r\n}\r\n\r\n.selectedMenuItem A,.selectedMenuItem A:visited {\r\n  color: #ED4400;\r\n}\r\n\r\n.loginBox {\r\n  font-size: 10pt;\r\n}\r\n\r\nH1 {\r\n  font-family: helvetica, arial;\r\n  font-size: 16pt;\r\n}\r\n\r\nsearchBox {\r\n  font-size: 10pt;\r\n}\r\n\r\n.pagination {\r\n  font-family: helvetica, arial;\r\n  font-size: 8pt;\r\n  text-align: center;\r\n}\r\n\r\n.adminBar {\r\n        background-color: #dddddd;\r\n        font-size: 8pt;\r\n        font-family: helvetica, arial;\r\n        color: #000055;\r\n}\r\n\r\n.formDescription {\r\n  font-family: helvetica, arial;\r\n  font-size: 10pt;\r\n  font-weight: bold;\r\n}\r\n\r\n.formSubtext {\r\n  font-family: helvetica, arial;\r\n  font-size: 8pt;\r\n}\r\n\r\n.highlight {\r\n  background-color: #444444;\r\n}\r\n\r\n.tableMenu {\r\n  background-color: #444444;\r\n  font-size: 8pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.tableMenu a {\r\n  text-decoration: none;\r\n}\r\n\r\n.tableHeader {\r\n  background-color: #555555;\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.tableData {\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.pollAnswer {\r\n  font-family: Helvetica, Arial;\r\n  font-size: 8pt;\r\n}\r\n\r\n.pollColor {\r\n  background-color: #C9E200;\r\n}\r\n\r\n.pollQuestion {\r\n  font-face: Helvetica, Arial;\r\n  font-weight: bold;\r\n}\r\n\r\n.faqQuestion {\r\n  font-size: 12pt;\r\n  color: #aaaaaa;\r\n}\r\n</style>');
INSERT INTO style VALUES (2,'Fail Safe','<body>\r\n^H; / ^t; / ^m; / ^a;\r\n<hr>','<hr>\r\n^H; / ^t; / ^m; / ^a;\r\n</body>','<style>\r\n.adminBar {\r\n        background-color: #dddddd;\r\n        font-size: 8pt;\r\n        font-family: helvetica, arial;\r\n        color: #000055;\r\n}\r\n</style>');
INSERT INTO style VALUES (-2,'Plain Black Software (black)','<body text=\"#ffffff\" link=\"#EF4200\" vlink=\"#EF4200\" bgcolor=\"#535558\" marginwidth=0 marginheight=0 leftmargin=0 rightmargin=0 topmargin=0 bottommargin=0>\r\n\r\n<table cellspacing=0 cellpadding=0 border=0 width=\"100%\">\r\n<tr>\r\n	<td width=\"200\" rowspan=\"2\" bgcolor=\"#ffffff\"><a href=\"/\"><img src=\"/extras/styles/plainblack/logo-white.gif\" width=\"200\" height=\"50\" alt=\"Plain Black Software\" border=\"0\"></a></td>\r\n	<td width=\"70%\" bgcolor=\"#38393C\" valign=\"bottom\"><img src=\"/extras/spacer.gif\" width=\"5\"><img src=\"/extras/styles/plainblack/user.gif\" width=\"41\" height=\"25\" alt=\"User:\" border=\"0\"> <a href=\"^\\;?op=displayAccount\" style=\"font-family: courier; color: #cee700; text-decoration: none; vertical-align: middle;\">^@;</a></td>\r\n	<td width=\"30%\" align=\"right\" bgcolor=\"#38393C\" valign=\"bottom\"><a href=\"^\\;?op=displayAccount\"><img src=\"/extras/styles/plainblack/myaccount.gif\" width=\"84\" height=\"25\" alt=\"My Account\" border=\"0\"></a><img src=\"/extras/styles/plainblack/darkbar.gif\" width=\"11\" height=\"25\" alt=\"|\" border=\"0\"><a href=\"^/;/download\"><img src=\"/extras/styles/plainblack/download.gif\" width=\"75\" height=\"25\" alt=\"Download\" border=\"0\"></a><img src=\"/extras/styles/plainblack/darkbar.gif\" width=\"11\" height=\"25\" alt=\"|\" border=\"0\"><a href=\"/\"><img src=\"/extras/styles/plainblack/home.gif\" width=\"40\" height=\"25\" alt=\"Home\" border=\"0\"></a><img src=\"/extras/spacer.gif\" width=\"5\"></td>\r\n</tr>\r\n<tr>\r\n	<td width=\"70%\" bgcolor=\"#535558\"><img src=\"/extras/spacer.gif\" width=\"5\">^C;</td>\r\n	<td width=\"30%\" align=\"right\" bgcolor=\"#535558\" style=\"font-family: courier; color: #cee700;\">^D(\"%c %D, %y\");<img src=\"/extras/spacer.gif\" width=\"5\"></td>\r\n</tr>\r\n</table>\r\n<table cellspacing=0 cellpadding=0 border=0 width=\"100%\" bgcolor=\"#38393C\">\r\n<tr>\r\n	<td width=\"200\" valign=\"top\" class=\"sideMenu\">^T(2);</td>\r\n	<td width=\"100%\" bgcolor=\"#000000\" rowspan=\"2\" valign=\"top\">','</td>\r\n</tr>\r\n<tr>\r\n	<td width=\"200\" bgcolor=\"#38393C\" align=\"center\" valign=\"bottom\"><p><img src=\"/extras/styles/plainblack/webgui.gif\" width=\"200\" height=\"84\" alt=\"\" border=\"0\"><p></td>\r\n</tr>\r\n</table>\r\n<table cellspacing=0 cellpadding=0 border=0 width=\"100%\">\r\n<tr>\r\n	<td width=\"50%\" bgcolor=\"#535558\"><img src=\"/extras/styles/plainblack/copyright.gif\" width=\"223\" height=\"25\" alt=\"Copyright 2001-2002 Plain Black Software\" border=\"0\"></td>\r\n	<td width=\"50%\" align=\"right\" bgcolor=\"#535558\">^r(\'<img src=\"/extras/styles/plainblack/makepageprintable.gif\" width=\"149\" height=\"25\" alt=\"Make Page Printable\" border=\"0\">\');</td>\r\n</tr>\r\n</table>\r\n</body>\r\n','<style>\r\n\r\n.content{\r\n  background-color: #000000;\r\n  color: #ffffff;\r\n  font-family: helvetica, arial;\r\n  font-size: 10pt;\r\n  padding: 10pt;\r\n}\r\n\r\n.sideMenu {\r\n  filter:DropShadow(OffX=2,OffY=2,color:#000000);\r\n  font-size: 10pt;\r\n  padding: 5pt;\r\n  font-family: helvetica, arial;\r\n  color: #000000;\r\n}\r\n\r\n.sideMenu A {\r\n  text-decoration: none;\r\n  color: #ffffff;\r\n}\r\n\r\n.sideMenu A:hover {\r\n  color: #EF4200;\r\n  text-decoration: underline;\r\n}\r\n\r\nH1 {\r\n  font-family: helvetica, arial;\r\n  font-size: 16pt;\r\n  color: #cee700;\r\n}\r\n\r\nsearchBox {\r\n  font-size: 10pt;\r\n}\r\n\r\nA {\r\n  color: #EF4200;\r\n}\r\n\r\n.pagination {\r\n  font-family: helvetica, arial;\r\n  font-size: 8pt;\r\n  text-align: center;\r\n}\r\n\r\n.adminBar {\r\n  background-color: #dddddd;\r\n  font-size: 8pt;\r\n  font-family: helvetica, arial;\r\n  color: #000055;\r\n}\r\n\r\n.crumbTrail {\r\n  font-family: helvetica, arial;\r\n  color: #cee700;\r\n  font-size: 8pt;\r\n}\r\n\r\n.crumbTrail A,.crumbTrail A:visited {\r\n  color: #ffffff;\r\n}\r\n\r\n.formDescription {\r\n  font-family: helvetica, arial;\r\n  font-size: 10pt;\r\n  font-weight: bold;\r\n}\r\n\r\n.formSubtext {\r\n  font-family: helvetica, arial;\r\n  font-size: 8pt;\r\n}\r\n\r\n.highlight {\r\n  background-color: #535558;\r\n}\r\n\r\n.tableMenu {\r\n  background-color: #38393C;\r\n  font-size: 8pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.tableMenu a {\r\n  text-decoration: none;\r\n}\r\n\r\n.tableHeader {\r\n  background-color: #38393C;\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.tableData {\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.pollAnswer {\r\n  font-family: Helvetica, Arial;\r\n  font-size: 8pt;\r\n}\r\n\r\n.pollColor {\r\n  background-color: #cee700;\r\n  border: thin solid #ffffff;\r\n}\r\n\r\n.pollQuestion {\r\n  font-face: Helvetica, Arial;\r\n  font-weight: bold;\r\n}\r\n\r\n.faqQuestion {\r\n  font-size: 12pt;\r\n  color: #cee700;\r\n}\r\n\r\n</style>');
INSERT INTO style VALUES (4,'Trash / Clipboard','<body>\r\n<table width=\"100%\"><tr><td valign=\"top\" width=\"30%\"><b>PAGES</b><br>^M(0);</td><td valign=\"top\" width=\"70%\"><b>CONTENT</b><br>','</td></tr></table>\r\n<hr>\r\n^H; / ^a;\r\n</body>','<style>\r\n.adminBar {\r\n        background-color: #dddddd;\r\n        font-size: 8pt;\r\n        font-family: helvetica, arial;\r\n        color: #000055;\r\n}\r\n</style>');
INSERT INTO style VALUES (5,'Reserved','<body>','</body></html>',NULL);
INSERT INTO style VALUES (6,'Reserved','<body>','</body></html>',NULL);
INSERT INTO style VALUES (7,'Reserved','<body>','</body></html>',NULL);
INSERT INTO style VALUES (8,'Reserved','<body>','</body></html>',NULL);
INSERT INTO style VALUES (9,'Reserved','<body>','</body></html>',NULL);
INSERT INTO style VALUES (10,'Reserved','<body>','</body></html>',NULL);
INSERT INTO style VALUES (11,'Reserved','<body>','</body></html>',NULL);
INSERT INTO style VALUES (12,'Reserved','<body>','</body></html>',NULL);
INSERT INTO style VALUES (13,'Reserved','<body>','</body></html>',NULL);
INSERT INTO style VALUES (14,'Reserved','<body>','</body></html>',NULL);
INSERT INTO style VALUES (15,'Reserved','<body>','</body></html>',NULL);
INSERT INTO style VALUES (16,'Reserved','<body>','</body></html>',NULL);
INSERT INTO style VALUES (17,'Reserved','<body>','</body></html>',NULL);
INSERT INTO style VALUES (18,'Reserved','<body>','</body></html>',NULL);
INSERT INTO style VALUES (19,'Reserved','<body>','</body></html>',NULL);
INSERT INTO style VALUES (20,'Reserved','<body>','</body></html>',NULL);
INSERT INTO style VALUES (21,'Reserved','<body>','</body></html>',NULL);
INSERT INTO style VALUES (22,'Reserved','<body>','</body></html>',NULL);
INSERT INTO style VALUES (23,'Reserved','<body>','</body></html>',NULL);
INSERT INTO style VALUES (24,'Reserved','<body>','</body></html>',NULL);
INSERT INTO style VALUES (-1,'Yahoo!','<html><head><title>Yahoo!</title><meta http-equiv=\"PICS-Label\" content=\'(PICS-1.1 \"http://www.rsac.org/ratingsv01.html\" l gen true for \"http://www.yahoo.com\" r (n 0 s 0 v 0 l 0))\'></head><body>\r\n<script language=javascript><!--\r\nfunction f(){\r\nvar f,m,p,a,i,k,o,e,l,c,d;\r\nf=\"0123456789abcdefghijklmnopqrstuvwxyz\";\r\nm=new Array;\r\np=\"claim-your-name\";\r\na=10;\r\nfor(i=0;i<36;i++){\r\n if(i==26)a=-26;\r\n m[f.charAt(i)]=f.charAt(i+a);\r\n}\r\nk=document.cookie;\r\nif((o=k.indexOf(\"Y=\"))==-1)return p;\r\nif((o=k.indexOf(\"l=\",o+2))==-1)return p;\r\nif((e=k.indexOf(\"/\",o+2))==-1)return p;\r\nif(e>o+18)e=o+18;\r\nl=k.substring(o+2,e);\r\np=\"\";\r\nfor(i=0;i<l.length;i++){\r\n c=l.charAt(i);\r\n if(m[c])p+=m[c];else p+=\'-\';\r\n}\r\nreturn p;\r\n}\r\nd=f();//-->\r\n</script>\r\n<center><form name=f action=http://search.yahoo.com/bin/search><map name=m><area coords=\"0,0,52,52\" href=r/c1><area coords=\"53,0,121,52\" href=r/p1><area coords=\"122,0,191,52\" href=r/m1><area coords=\"441,0,510,52\" href=r/wn><area coords=\"511,0,579,52\" href=r/i1><area coords=\"580,0,637,52\" href=r/hw></map><img width=638 height=53 border=0 usemap=\"#m\" src=http://us.a1.yimg.com/us.yimg.com/i/ww/m5v5.gif alt=Yahoo><br><table border=0 cellspacing=0 cellpadding=3 width=640><tr><td align=center width=205>\r\n<font color=ff0020>new!</font> <a href=\"http://www.yahoo.com/homet/?http://new.domains.yahoo.com\"><b>Y! Domains</b></a><br><small>reserve .biz & .info domains</small></td><td align=center><a href=\"http://rd.yahoo.com/M=77122.1317476.2909345.220161/D=yahoo_top/S=2716149:NP/A=656341/?http://website.yahoo.com/\" target=\"_top\"><img width=230 height=33 src=\"http://us.a1.yimg.com/us.yimg.com/a/pr/promo/anchor/hp_website2.gif\" alt=\"\" border=0></a></td><td align=center width=205><a href=\"http://www.yahoo.com//homet/?http://mail.yahoo.com\"><b>Yahoo! Mail</b></a><br>you@yahoo.com</td></tr><tr><td colspan=3 align=center><input size=30 name=p>\r\n<input type=submit value=Search> <a href=http://www.yahoo.com/r/so>advanced search</a></td></tr></table>\r\n</form>\r\n<div align=\"left\">\r\n','</div>\r\n<hr noshade size=1 width=640><small><a href=http://www.yahoo.com/r/ad>How to Suggest a Site</a> -\r\n<a href=http://www.yahoo.com/r/cp>Company Info</a> -\r\n<a href=http://www.yahoo.com/r/cy>Copyright Policy</a> -\r\n<a href=http://www.yahoo.com/r/ts>Terms of Service</a> -\r\n<a href=http://www.yahoo.com/r/cb>Contributors</a> -\r\n<a href=http://www.yahoo.com/r/hr>Jobs</a> -\r\n<a href=http://www.yahoo.com/r/ao>Advertising</a><p>Copyright © 2001 Yahoo! Inc. All rights reserved.</small><br><a href=http://www.yahoo.com/r/pv>Privacy Policy</a></form></center></body></html>\r\n','');
INSERT INTO style VALUES (-4,'Demo Style','<body bgcolor=\"#666666\">\r\n\r\n<table border=\"0\" width=\"700\" background=\"/extras/styles/demo/topbg-3.gif\" cellspacing=\"0\" cellpadding=\"0\" align=\"center\">\r\n<tr>\r\n    <td width=\"324\" height=\"80\"><img src=\"/extras/styles/demo/top-3.jpg\" border=0 width=\"324\"></td>\r\n    <td width=\"100%\"><h3 style=\"color:white\">Your Company Name Here</h3><div style=\"color:white\">Address: 1903 Sunrise St. City, State 65977<br>\r\nTel: 915.888.8888<br>\r\nEmail: service@company.com</div></td>\r\n  </tr>\r\n</table>\r\n<table border=\"0\" width=\"700\"  height=\"21\" cellspacing=\"0\" cellpadding=\"0\" bgcolor=\"#000000\" align=center>\r\n  <tr>\r\n    <td><img src=\"/extras/styles/demo/mid-3.jpg\" border=0 width=\"140\" height=\"21\"></td>\r\n    <td width=\"100%\">^t;</td>\r\n  </tr>\r\n</table>\r\n<table border=\"0\" width=\"700\"  height=\"500\" cellspacing=\"0\" cellpadding=\"0\" align=center>\r\n  <tr>\r\n    <td bgcolor=\"#990000\" width=\"140\" style=\"background-image: url(\'/extras/styles/demo/leftbg-3.jpg\'); background-repeat: no-repeat; background-position: left top\" valign=\"top\"><img src=\"/extras/spacer.gif\" height=\"10\" width=\"140\" border=0>\r\n<table cellpadding=4><tr><td>\r\n^M;\r\n</td></tr></table>\r\n    </td>\r\n    <td width=\"100%\" align=\"right\" height=\"100%\" valign=\"top\"><img src=\"/extras/styles/demo/x.gif\" height=\"4\" width=\"560\"><br>\r\n    <table  width=\"99%\" height=\"99%\" border=\"0\" bgcolor=\"black\" cellpadding=\"3\" cellspacing=\"1\">\r\n    	<tr><td bgcolor=\"#f9ecec\" style=\"background-image: url(\'/extras/styles/demo/contentbg-3.gif\'); background-repeat: no-repeat; background-position: right bottom\" height=\"100%\" valign=\"top\">\r\n    	','	</td></tr>\r\n    </table>\r\n    </td>\r\n  </tr>\r\n</table>\r\n<table border=\"0\" width=\"700\" cellspacing=\"0\" cellpadding=\"0\" align=\"center\">\r\n<tr><td align=\"right\">^H; · ^a;</td></tr>\r\n</table>\r\n\r\n\r\n</body>\r\n','<style>\r\n\r\n.homeLink, .myAccountLink, {\r\n  color: #ffffff;\r\n  font-size: 8pt;\r\n}\r\n\r\n.verticalMenu A, .verticalMenu A:visited {\r\n  color: #ffffff;\r\n  font-weight: bold;\r\n}\r\n\r\nbody {\r\n  font-family:arial; \r\n  font-size: 12px; \r\n  color: black;\r\n  background: #666666;\r\n}\r\n\r\ntd { \r\n  font-size: 11px;\r\n}\r\n\r\nH1 {\r\n  MARGIN-TOP: 3px;\r\n  MARGIN-BOTTOM: 3px;\r\n  font-size: 16pt;\r\n}\r\n\r\nH3 {\r\n  MARGIN-TOP: 3px;\r\n  MARGIN-BOTTOM: 3px;\r\n}\r\n\r\nH4 {\r\n  MARGIN-TOP: 3px;\r\n  MARGIN-BOTTOM: 3px;\r\n}\r\n\r\nH5 {\r\n  MARGIN-TOP: 3px;\r\n  MARGIN-BOTTOM: 3px;\r\n}\r\n\r\nul { \r\n  MARGIN-TOP: 3px; \r\n  MARGIN-BOTTOM: 3px \r\n}\r\n\r\nA {\r\n  color: #800000;\r\n  TEXT-DECORATION: underline\r\n}\r\n\r\nA:hover {\r\n  color: #990000;\r\n  TEXT-DECORATION: none;\r\n}\r\n\r\n.pagination {\r\n  font-family: helvetica, arial;\r\n  text-align: center;\r\n  font-size: 8pt;\r\n}\r\n\r\n.horizontalMenu {\r\n  font-size: 8pt;\r\n  padding: 5px;\r\n  font-weight: bold;\r\n  color: #aaaaaa;\r\n}\r\n\r\n.horizontalMenu A, .horizontalMenu A:visited {\r\n  color: #ffffff;\r\n}\r\n\r\n.adminBar {\r\n        background-color: #dddddd;\r\n        font-size: 8pt;\r\n        font-family: helvetica, arial;\r\n        color: #000055;\r\n}\r\n\r\n.highlight {\r\n  background-color: #EAEAEA;\r\n}\r\n\r\n.formDescription {\r\n  font-size: 10pt;\r\n}\r\n\r\n.formSubtext {\r\n  font-size: 8pt;\r\n}\r\n\r\n.tableMenu {\r\n  font-size: 8pt;\r\n  background-color: #F5DFDF;\r\n}\r\n.tableMenu a {\r\n  text-decoration: none;\r\n}\r\n\r\n.tableHeader {\r\n  background-color: #F5DFDF;\r\n  font-size: 10pt;\r\n}\r\n\r\n.tableData {\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.pollAnswer {\r\n  font-family: Helvetica, Arial;\r\n  font-size: 8pt;\r\n}\r\n\r\n.pollColor {\r\n  background-color: #ffddbb;\r\n}\r\n\r\n.pollQuestion {\r\n  font-face: Helvetica, Arial;\r\n  font-weight: bold;\r\n}\r\n\r\n.faqQuestion {\r\n  color: #000000;\r\n  font-weight: bold;\r\n  text-decoration: none;\r\n}\r\n\r\n</style>');
INSERT INTO style VALUES (3,'Make Page Printable','<body onLoad=\"window.print()\">\r\n<div align=\"center\"><a href=\"^\\;\"><img src=\"/extras/styles/plainblack/logo-white.gif\" border=\"0\"></a></div>','<div align=\"center\">© 2001-2002 Plain Black Software</div>\r\n</body>','<style>\r\n\r\n.content{\r\n  background-color: #ffffff;\r\n  color: #000000;\r\n  font-family: helvetica, arial;\r\n  font-size: 10pt;\r\n  padding: 10pt;\r\n}\r\n\r\nH1 {\r\n  font-family: helvetica, arial;\r\n  font-size: 16pt;\r\n}\r\n\r\nA {\r\n  color: #EF4200;\r\n}\r\n\r\n.pagination {\r\n  font-family: helvetica, arial;\r\n  font-size: 8pt;\r\n  text-align: center;\r\n}\r\n\r\n.formDescription {\r\n  font-family: helvetica, arial;\r\n  font-size: 10pt;\r\n  font-weight: bold;\r\n}\r\n\r\n.formSubtext {\r\n  font-family: helvetica, arial;\r\n  font-size: 8pt;\r\n}\r\n\r\n.highlight {\r\n  background-color: #dddddd;\r\n}\r\n\r\n.tableMenu {\r\n  background-color: #cccccc;\r\n  font-size: 8pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.tableMenu a {\r\n  text-decoration: none;\r\n}\r\n\r\n.tableHeader {\r\n  background-color: #cccccc;\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.tableData {\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.pollAnswer {\r\n  font-family: Helvetica, Arial;\r\n  font-size: 8pt;\r\n}\r\n\r\n.pollColor {\r\n  background-color: #444444;\r\n}\r\n\r\n.pollQuestion {\r\n  font-face: Helvetica, Arial;\r\n  font-weight: bold;\r\n}\r\n\r\n.faqQuestion {\r\n  font-size: 12pt;\r\n  font-weight: bold;\r\n  color: #000000;\r\n}\r\n\r\n</style>');
INSERT INTO style VALUES (25,'Reserved',NULL,NULL,NULL);
INSERT INTO style VALUES (-5,'Plain Black Software (white)','<body text=\"#000000\" link=\"#EF4200\" vlink=\"#EF4200\" bgcolor=\"#535558\" marginwidth=0 marginheight=0 leftmargin=0 rightmargin=0 topmargin=0 bottommargin=0>\r\n\r\n<table cellspacing=0 cellpadding=0 border=0 width=\"100%\">\r\n<tr>\r\n	<td width=\"200\" rowspan=\"2\" bgcolor=\"#000000\"><a href=\"/\"><img src=\"/extras/styles/plainblack/logo-black.gif\" width=\"200\" height=\"50\" alt=\"Plain Black Software\" border=\"0\"></a></td>\r\n	<td width=\"70%\" bgcolor=\"#38393C\" valign=\"bottom\"><img src=\"/extras/spacer.gif\" width=\"5\"><img src=\"/extras/styles/plainblack/user.gif\" width=\"41\" height=\"25\" alt=\"User:\" border=\"0\"> <a href=\"^\\;?op=displayAccount\" style=\"font-family: courier; color: #cee700; text-decoration: none; vertical-align: middle;\">^@;</a></td>\r\n	<td width=\"30%\" align=\"right\" bgcolor=\"#38393C\" valign=\"bottom\"><a href=\"^\\;?op=displayAccount\"><img src=\"/extras/styles/plainblack/myaccount.gif\" width=\"84\" height=\"25\" alt=\"My Account\" border=\"0\"></a><img src=\"/extras/styles/plainblack/darkbar.gif\" width=\"11\" height=\"25\" alt=\"|\" border=\"0\"><a href=\"^/;/download\"><img src=\"/extras/styles/plainblack/download.gif\" width=\"75\" height=\"25\" alt=\"Download\" border=\"0\"></a><img src=\"/extras/styles/plainblack/darkbar.gif\" width=\"11\" height=\"25\" alt=\"|\" border=\"0\"><a href=\"/\"><img src=\"/extras/styles/plainblack/home.gif\" width=\"40\" height=\"25\" alt=\"Home\" border=\"0\"></a><img src=\"/extras/spacer.gif\" width=\"5\"></td>\r\n</tr>\r\n<tr>\r\n	<td width=\"70%\" bgcolor=\"#535558\"><img src=\"/extras/spacer.gif\" width=\"5\">^C;</td>\r\n	<td width=\"30%\" align=\"right\" bgcolor=\"#535558\" style=\"font-family: courier; color: #cee700;\">^D(\"%c %D, %y\");<img src=\"/extras/spacer.gif\" width=\"5\"></td>\r\n</tr>\r\n</table>\r\n<table cellspacing=0 cellpadding=0 border=0 width=\"100%\" bgcolor=\"#38393C\">\r\n<tr>\r\n	<td width=\"200\" valign=\"top\" class=\"sideMenu\">^T(2);</td>\r\n	<td width=\"100%\" bgcolor=\"#ffffff\" rowspan=\"2\" valign=\"top\">','</td>\r\n</tr>\r\n<tr>\r\n	<td width=\"200\" bgcolor=\"#38393C\" align=\"center\" valign=\"bottom\"><p><img src=\"/extras/styles/plainblack/webgui.gif\" width=\"200\" height=\"84\" alt=\"\" border=\"0\"><p></td>\r\n</tr>\r\n</table>\r\n<table cellspacing=0 cellpadding=0 border=0 width=\"100%\">\r\n<tr>\r\n	<td width=\"50%\" bgcolor=\"#535558\"><img src=\"/extras/styles/plainblack/copyright.gif\" width=\"223\" height=\"25\" alt=\"Copyright 2001-2002 Plain Black Software\" border=\"0\"></td>\r\n	<td width=\"50%\" align=\"right\" bgcolor=\"#535558\">^r(\'<img src=\"/extras/styles/plainblack/makepageprintable.gif\" width=\"149\" height=\"25\" alt=\"Make Page Printable\" border=\"0\">\');</td>\r\n</tr>\r\n</table>\r\n</body>\r\n','<style>\r\n\r\n.content{\r\n  background-color: #ffffff;\r\n  color: #000000;\r\n  font-family: helvetica, arial;\r\n  font-size: 10pt;\r\n  padding: 10pt;\r\n}\r\n\r\n.sideMenu {\r\n  filter:DropShadow(OffX=2,OffY=2,color:#000000);\r\n  font-size: 10pt;\r\n  padding: 5pt;\r\n  font-family: helvetica, arial;\r\n  color: #000000;\r\n}\r\n\r\n.sideMenu A {\r\n  text-decoration: none;\r\n  color: #ffffff;\r\n}\r\n\r\n.sideMenu A:hover {\r\n  color: #EF4200;\r\n  text-decoration: underline;\r\n}\r\n\r\nH1 {\r\n  font-family: helvetica, arial;\r\n  font-size: 16pt;\r\n  color: #38393C;\r\n}\r\n\r\nsearchBox {\r\n  font-size: 10pt;\r\n}\r\n\r\nA {\r\n  color: #EF4200;\r\n}\r\n\r\n.pagination {\r\n  font-family: helvetica, arial;\r\n  font-size: 8pt;\r\n  text-align: center;\r\n}\r\n\r\n.adminBar {\r\n  background-color: #dddddd;\r\n  font-size: 8pt;\r\n  font-family: helvetica, arial;\r\n  color: #000055;\r\n}\r\n\r\n.crumbTrail {\r\n  font-family: helvetica, arial;\r\n  color: #cee700;\r\n  font-size: 8pt;\r\n}\r\n\r\n.crumbTrail A,.crumbTrail A:visited {\r\n  color: #ffffff;\r\n}\r\n\r\n.formDescription {\r\n  font-family: helvetica, arial;\r\n  font-size: 10pt;\r\n  font-weight: bold;\r\n}\r\n\r\n.formSubtext {\r\n  font-family: helvetica, arial;\r\n  font-size: 8pt;\r\n}\r\n\r\n.highlight {\r\n  background-color: #cccccc;\r\n}\r\n\r\n.tableMenu {\r\n  background-color: #cee700;\r\n  font-size: 8pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.tableMenu a {\r\n  text-decoration: none;\r\n}\r\n\r\n.tableHeader {\r\n  background-color: #cee700;\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.tableData {\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.pollAnswer {\r\n  font-family: Helvetica, Arial;\r\n  font-size: 8pt;\r\n}\r\n\r\n.pollColor {\r\n  background-color: #cee700;\r\n  border: thin solid #000000;\r\n}\r\n\r\n.pollQuestion {\r\n  font-face: Helvetica, Arial;\r\n  font-weight: bold;\r\n}\r\n\r\n.faqQuestion {\r\n  font-size: 12pt;\r\n  color: #38393C;\r\n  font-weight: bold;\r\n}\r\n\r\n</style>');

#
# Table structure for table 'users'
#

CREATE TABLE users (
  userId int(11) NOT NULL default '0',
  username varchar(35) default NULL,
  identifier varchar(35) default NULL,
  email varchar(255) default NULL,
  authMethod varchar(30) NOT NULL default 'WebGUI',
  ldapURL text,
  connectDN varchar(255) default NULL,
  language varchar(30) NOT NULL default 'English',
  firstName varchar(50) default NULL,
  middleName varchar(50) default NULL,
  lastName varchar(50) default NULL,
  icq varchar(30) default NULL,
  aim varchar(30) default NULL,
  msnIM varchar(30) default NULL,
  yahooIM varchar(30) default NULL,
  homeAddress varchar(128) default NULL,
  homeCity varchar(30) default NULL,
  homeState varchar(30) default NULL,
  homeZip varchar(15) default NULL,
  homeCountry varchar(30) default NULL,
  homePhone varchar(30) default NULL,
  workAddress varchar(128) default NULL,
  workCity varchar(30) default NULL,
  workState varchar(30) default NULL,
  workZip varchar(15) default NULL,
  workCountry varchar(30) default NULL,
  workPhone varchar(30) default NULL,
  cellPhone varchar(30) default NULL,
  pager varchar(30) default NULL,
  gender varchar(6) default NULL,
  birthdate varchar(30) default NULL,
  homepage text,
  PRIMARY KEY  (userId)
) TYPE=MyISAM;

#
# Dumping data for table 'users'
#

INSERT INTO users VALUES (1,'Visitor','No Login','','WebGUI',NULL,NULL,'English',NULL,NULL,NULL,'',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO users VALUES (2,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO users VALUES (3,'Admin','RvlMjeFPs2aAhQdo/xt/Kg','','WebGUI','','','English','','','','','','','','','','','','','','','','','','','','','','male','','');
INSERT INTO users VALUES (4,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO users VALUES (5,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO users VALUES (6,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO users VALUES (7,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO users VALUES (8,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO users VALUES (9,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO users VALUES (10,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO users VALUES (11,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO users VALUES (12,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO users VALUES (13,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO users VALUES (14,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO users VALUES (15,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO users VALUES (16,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO users VALUES (17,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO users VALUES (18,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO users VALUES (19,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO users VALUES (20,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO users VALUES (21,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO users VALUES (22,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO users VALUES (23,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO users VALUES (24,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO users VALUES (25,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

#
# Table structure for table 'widget'
#

CREATE TABLE widget (
  widgetId int(11) NOT NULL default '0',
  pageId int(11) default NULL,
  namespace varchar(35) default NULL,
  sequenceNumber int(11) NOT NULL default '1',
  title varchar(255) default NULL,
  displayTitle int(11) NOT NULL default '1',
  description text,
  processMacros int(11) NOT NULL default '0',
  dateAdded int(11) default NULL,
  addedBy int(11) default NULL,
  lastEdited int(11) default NULL,
  editedBy int(11) default NULL,
  templatePosition char(1) NOT NULL default 'A',
  PRIMARY KEY  (widgetId)
) TYPE=MyISAM;

#
# Dumping data for table 'widget'
#

INSERT INTO widget VALUES (-1,4,'SiteMap',0,'Page Not Found',1,'The page you were looking for could not be found on this system. Perhaps it has been deleted or renamed. The following list is a site map of this site. If you don\'t find what you\'re looking for on the site map, you can always start from the <a href=\"^/;\">Home Page</a>.',1,1001744792,3,1013215663,3,'A');

