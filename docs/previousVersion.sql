# MySQL dump 8.13
#
# Host: localhost    Database: WebGUI
#--------------------------------------------------------
# Server version	3.23.36

#
# Table structure for table 'Article'
#

CREATE TABLE Article (
  widgetId int(11) default NULL,
  startDate int(11) default NULL,
  endDate int(11) default NULL,
  body mediumtext,
  image varchar(255) default NULL,
  linkTitle varchar(255) default NULL,
  linkURL text,
  attachment varchar(255) default NULL,
  convertCarriageReturns int(11) NOT NULL default '0'
) TYPE=MyISAM;

#
# Dumping data for table 'Article'
#


#
# Table structure for table 'EventsCalendar'
#

CREATE TABLE EventsCalendar (
  widgetId int(11) NOT NULL default '0',
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
  widgetId int(11) default NULL,
  groupToPost int(11) default NULL,
  messagesPerPage int(11) NOT NULL default '50',
  editTimeout int(11) default NULL
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
  showOnlyThisLevel int(11) default NULL,
  PRIMARY KEY  (widgetId)
) TYPE=MyISAM;

#
# Dumping data for table 'SiteMap'
#

INSERT INTO SiteMap VALUES (-1,0,0);

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
# Table structure for table 'groupings'
#

CREATE TABLE groupings (
  groupId int(11) NOT NULL default '0',
  userId int(11) NOT NULL default '0',
  PRIMARY KEY  (groupId,userId)
) TYPE=MyISAM;

#
# Dumping data for table 'groupings'
#

INSERT INTO groupings VALUES (1,1);
INSERT INTO groupings VALUES (2,3);
INSERT INTO groupings VALUES (3,3);
INSERT INTO groupings VALUES (4,3);

#
# Table structure for table 'groups'
#

CREATE TABLE groups (
  groupId int(11) NOT NULL default '0',
  groupName varchar(30) default NULL,
  description varchar(255) default NULL,
  PRIMARY KEY  (groupId)
) TYPE=MyISAM;

#
# Dumping data for table 'groups'
#

INSERT INTO groups VALUES (1,'Visitors','This is the public group that has no privileges.');
INSERT INTO groups VALUES (2,'Registered Users','All registered users belong to this group automatically.');
INSERT INTO groups VALUES (3,'Admins','Anyone who belongs to this group has privileges to everything.');
INSERT INTO groups VALUES (4,'Content Managers','Users that have privileges to edit content on this site. The user still needs to be added to a group that has editing privileges on specific pages.');
INSERT INTO groups VALUES (5,'Reserved','');
INSERT INTO groups VALUES (6,'Reserved','');
INSERT INTO groups VALUES (7,'Reserved','');
INSERT INTO groups VALUES (8,'Reserved','');
INSERT INTO groups VALUES (9,'Reserved','');
INSERT INTO groups VALUES (10,'Reserved','');
INSERT INTO groups VALUES (11,'Reserved','');
INSERT INTO groups VALUES (12,'Reserved','');
INSERT INTO groups VALUES (13,'Reserved','');
INSERT INTO groups VALUES (14,'Reserved','');
INSERT INTO groups VALUES (15,'Reserved','');
INSERT INTO groups VALUES (16,'Reserved','');
INSERT INTO groups VALUES (17,'Reserved','');
INSERT INTO groups VALUES (18,'Reserved','');
INSERT INTO groups VALUES (19,'Reserved','');
INSERT INTO groups VALUES (20,'Reserved','');
INSERT INTO groups VALUES (21,'Reserved','');
INSERT INTO groups VALUES (22,'Reserved','');
INSERT INTO groups VALUES (23,'Reserved','');
INSERT INTO groups VALUES (24,'Reserved','');
INSERT INTO groups VALUES (25,'Reserved','');

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

INSERT INTO help VALUES (1,'WebGUI','English','Add/Edit','Page','Think of pages as containers for content. For instance, if you want to write a letter to the editor of your favorite magazine you\'d get out a notepad (or open a word processor) and start filling it with your thoughts. The same is true with WebGUI. Create a page, then add your content to the page.\r\n\r\n<b>Title</b>\r\nThe title of the page is what your users will use to navigate through the site. Titles should be descriptive, but not very long.\r\n\r\n<b>Page URL</b>\r\nWhen you create a page a url for the page is generated based on the page title. If you are unhappy with the url that was chosen, you can change it here.\r\n\r\n<b>Meta Tags</b>\r\nMeta tags are used by some search engines to associate key words to a particular page. There is a great site called <a href=\"http://www.metatagbuilder.com/\">Meta Tag Builder</a> that will help you build meta tags if you\'ve never done it before.\r\n\r\n<i>Advanced Users:</i> If you have other things (like JavaScript) you usually put in the &lt;head&gt; area of your pages, you may put them here as well.\r\n\r\n<b>Use default meta tags?</b>\r\nIf you don\'t wish to specify meta tags yourself, WebGUI can generate meta tags based on the page title and your company\'s name. Check this box to enable the defaultly generated meta tags.\r\n\r\n<b>Style</b>\r\nBy default, when you create a page, it inherits a few traits from its parent. One of those traits is style. Choose from the list of styles if you would like to change the appearance of this page. See <i>Add Style</i> for more details.\r\n\r\nIf you check the box below to the style pull-down menu, all of the pages below this page will take on the style you\'ve chosen for this page.\r\n\r\n<b>Owner</b>\r\nThe owner of a page is usually the person who created the page.\r\n\r\n<b>Owner can view?</b>\r\nCan the owner view the page or not?\r\n\r\n<b>Owner can edit?</b>\r\nCan the owner edit the page or not? Be careful, if you decide that the owner cannot edit the page and you do not belong to the page group, then you\'ll lose the ability to edit this page.\r\n\r\n<b>Group</b>\r\nA group is assigned to every page for additional privilege control. Pick a group from the pull-down menu.\r\n\r\n<b>Group can view?</b>\r\nCan members of this group view this page?\r\n\r\n<b>Group can edit?</b>\r\nCan members of this group edit this page?\r\n\r\n<b>Anybody can view?</b>\r\nCan any visitor or member regardless of the group and owner view this page?\r\n\r\n<b>Anybody can edit?</b>\r\nCan any visitor or member regardless of the group and owner edit this page?\r\n\r\nYou can optionally give these privileges to all pages under this page.\r\n','0');
INSERT INTO help VALUES (3,'WebGUI','English','Delete','Page','Deleting a page can create a big mess if you are uncertain about what you are doing. When you delete a page you are also deleting the content it contains, all sub-pages connected to this page, and all the content they contain. Be certain that you have already moved all the content you wish to keep before you delete a page.\r\n\r\nAs with any delete operation, you are prompted to be sure you wish to proceed with the delete. If you answer yes, the delete will proceed and there is no recovery possible. If you answer no you\'ll be returned to the prior screen.','0');
INSERT INTO help VALUES (4,'WebGUI','English','Delete','Style','When you delete a style all pages using that style will be reverted to the fail safe (default) style. To ensure uninterrupted viewing, you should be sure that no pages are using a style before you delete it.\r\n\r\nAs with any delete operation, you are prompted to be sure you wish to proceed with the delete. If you answer yes, the delete will proceed and there is no recovery possible. If you answer no you\'ll be returned to the prior screen.','4,5');
INSERT INTO help VALUES (5,'WebGUI','English','Add/Edit','User','See <b>Manage Users</b> for additional details.\r\n\r\n<b>Username</b>\r\nUsername is a unique identifier for a user. Sometimes called a handle, it is also how the user will be known on the site. (<i>Note:</i> Administrators have unlimited power in the WebGUI system. This also means they are capable of breaking the system. If you rename or create a user, be careful not to use a username already in existance.)\r\n\r\n<b>Password</b>\r\nA password is used to ensure that the user is who s/he says s/he is.\r\n\r\n<b>Authentication Method</b>\r\nSee <i>Edit Settings</i> for details.\r\n\r\n<b>LDAP URL</b>\r\nSee <i>Edit Settings</i> for details.\r\n\r\n<b>Connect DN</b>\r\nThe Connect DN is the <b>cn</b> (or common name) of a given user in your LDAP database. It should be specified as <b>cn=John Doe</b>. This is, in effect, the username that will be used to authenticate this user against your LDAP server.\r\n\r\n<b>Email Address</b>\r\nThe user\'s email address. This must only be specified if the user will partake in functions that require email.\r\n\r\n<b>Groups</b>\r\nGroups displays which groups the user is in. Groups that are highlighted are groups that the user is assigned to. Those that are not highlighted are other groups that can be assigned. Note that you must hold down CTRL to select multiple groups.\r\n\r\n<b>Language</b>\r\nWhat language should be used to display system related messages.\r\n\r\n<b>ICQ UIN</b>\r\nThe <a href=\"http://www.icq.com\">ICQ</a> UIN is the \"User ID Number\" on the ICQ network. ICQ is a very popular instant messaging platform.\r\n\r\n','0');
INSERT INTO help VALUES (7,'WebGUI','English','Delete','User','There is no need to ever actually delete a user. If you are concerned with locking out a user, then simply change their password. If you truely wish to delete a user, then please keep in mind that there are consequences. If you delete a user any content that they added to the site via widgets (like message boards and user contributions) will remain on the site. However, if another user tries to visit the deleted user\'s profile they will get an error message. Also if the user ever is welcomed back to the site, there is no way to give him/her access to his/her old content items except by re-adding the user to the users table manually.\r\n\r\nAs with any delete operation, you are prompted to be sure you wish to proceed with the delete. If you answer yes, the delete will proceed and there is no recovery possible. If you answer no you\'ll be returned to the prior screen.','0');
INSERT INTO help VALUES (8,'WebGUI','English','Manage','User','Users are the accounts in the system that are given rights to do certain things. There are two default users built into the system: Admin and Visitor.\r\n\r\n<b>Admin</b>\r\nAdmin is exactly what you\'d expect. It is a user with unlimited rights in the WebGUI environment. If it can be done, this user has the rights to do it.\r\n\r\n<b>Visitor</b>\r\nVisitor is exactly the opposite of Admin. Visitor has no rights what-so-ever. By default any user who is not logged in is seen as the user Visitor.\r\n\r\n<b>Add a new user.</b>\r\nClick on this to go to the add user screen.\r\n\r\n<b>Search</b>\r\nYou can search users based on username and email address. You can do partial searches too if you like.','0');
INSERT INTO help VALUES (9,'WebGUI','English','Manage','Style','Styles are used to manage the look and feel of your WebGUI pages. With WebGUI, you can have an unlimited number of styles, so your site can take on as many looks as you like. You could have some pages that look like your company\'s brochure, and some pages that look like Yahoo!&reg;. You could even have some pages that look like pages in a book. Using style management, you have ultimate control over all your designs.\r\n\r\nThere are three styles built in to WebGUI: Fail Safe, Plain Black Software, and Yahoo!&reg;. These styles are not meant to be edited, but rather to give you samples of what\'s possible.\r\n\r\n<b>Fail Safe</b>\r\nWhen you delete a style that is still in use on some pages, the Fail Safe style will be applied to those pages. This style has a white background and simple navigation.\r\n\r\n<b>Plain Black Software</b>\r\nThis is the simple design used on the Plain Black Software site.\r\n\r\n<b>Yahoo!&reg;</b>\r\nThis is the design of the Yahoo!&reg; site. (Yahoo!&reg; has not given us permission to use their design. It is simply an example.)','4,5');
INSERT INTO help VALUES (10,'WebGUI','English','Manage','Group','Groups are used to subdivide privileges and responsibilities within the WebGUI system. For instance, you may be building a site for a classroom situation. In that case you might set up a different group for each class that you teach. You would then apply those groups to the pages that are designed for each class.\r\n\r\nThere are four groups built into WebGUI. They are Admins, Content Managers, Visitors, and Registered Users.\r\n\r\n<b>Admins</b>\r\nAdmins are users who have unlimited privileges within WebGUI. A user should only be added to the admin group if they oversee the system. Usually only one to three people will be added to this group.\r\n\r\n<b>Content Managers</b>\r\nContent managers are users who have privileges to add, edit, and delete content from various areas on the site. The content managers group should not be used to control individual content areas within the site, but to determine whether a user can edit content at all. You should set up additional groups to separate content areas on the site.\r\n\r\n<b>Registered Users</b>\r\nWhen users are added to the system they are put into the registered users group. A user should only be removed from this group if their account is deleted or if you wish to punish a troublemaker.\r\n\r\n<b>Visitors</b>\r\nVisitors are users who are not logged in using an account on the system. Also, if you wish to punish a registered user you could remove him/her from the Registered Users group and insert him/her into the Visitors group.','0');
INSERT INTO help VALUES (12,'WebGUI','English','Manage','Settings','Settings are items that allow you to adjust WebGUI to your particular needs.\r\n\r\n<b>Edit Authentication Settings</b>\r\nSettings concerning user identification and login, such as LDAP.\r\n\r\n<b>Edit Company Information</b>\r\nInformation specific about the company or individual who controls this installation of WebGUI.\r\n\r\n<b>Edit File Settings</b>\r\nSettings concerning attachments and images.\r\n\r\n<b>Edit Mail Settings</b>\r\nSettings concerning email and related functions.\r\n\r\n<b>Edit Miscellaneous Settings</b>\r\nEverything else.\r\n\r\n','7,8,9.10,11,12');
INSERT INTO help VALUES (14,'WebGUI','English','Delete','Widget','This function permanently deletes the selected widget from a page. If you are unsure whether you wish to delete this content you may be better served to cut the content to the clipboard until you are certain you wish to delete it.\r\n\r\nAs with any delete operation, you are prompted to be sure you wish to proceed with the delete. If you answer yes, the delete will proceed and there is no recovery possible. If you answer no you\'ll be returned to the prior screen.','0');
INSERT INTO help VALUES (15,'WebGUI','English','Delete','Group','As the function suggests you\'ll be deleting a group and removing all users from the group. Be careful not to orphan users from pages they should have access to by deleting a group that is in use.\r\n\r\nAs with any delete operation, you are prompted to be sure you wish to proceed with the delete. If you answer yes, the delete will proceed and there is no recovery possible. If you answer no you\'ll be returned to the prior screen.','0');
INSERT INTO help VALUES (16,'WebGUI','English','Add/Edit','Style','Styles are WebGUI macro enabled. See <i>Using Macros</i> for more information.\r\n\r\n<b>Style Name</b>\r\nA unique name to describe what this style looks like at a glance. The name has no effect on the actual look of the style.\r\n\r\n<b>Header</b>\r\nThe header is the start of the look of your site. It is helpful to look at your design and cut it into three pieces. The top and left of your design is the header. The center part is the content, and the right and bottom is the footer. Cut the HTML from your header and paste it in the space provided.\r\n\r\nIf you are in need of assistance for creating a look for your site, or if you need help cutting apart your design, <a href=\"http://www.plainblack.com\">Plain Black Software</a> provides support services for a small fee.\r\n\r\nMany people will add WebGUI macros to their header for automated navigation, and other features.\r\n\r\n<b>Footer</b>\r\nThe footer is the end of the look for your site. It is the right and bottom portion of your design. You may also place WebGUI macros in your footer.\r\n\r\n<b>Style Sheet</b>\r\nPlace your style sheet entries here. Style sheets are used to control colors, sizes, and other properties of the elements on your site. See <i>Using Style Sheets</i> for more information.\r\n\r\n<i>Advanced Users:</i> for greater performance create your stylesheet on the file system (call it something like webgui.css) and add an entry like this to this area: \r\n&lt;link href=\"/webgui.css\" rel=\"stylesheet\" rev=\"stylesheet\" type=\"text/css\"&gt;','4,5');
INSERT INTO help VALUES (17,'WebGUI','English','Add/Edit','Group','See <i>Manage Group</i> for a description of grouping functions and the default groups.\r\n\r\n<b>Group Name</b>\r\nA name for the group. It is best if the name is descriptive so you know what it is at a glance.\r\n\r\n<b>Description</b>\r\nA longer description of the group so that other admins and content managers (or you if you forget) will know what the purpose of this group is.','0');
INSERT INTO help VALUES (24,'WebGUI','English','Edit','Miscellaneous Settings','<b>Not Found Page</b>\r\nIf a page that a user requests is not found in the system, the user can be redirected to the home page or to an error page where they can attempt to find what they were looking for. You decide which is better for your users.\r\n\r\n<b>Session Timeout</b>\r\nThe time (in seconds) that a user session remains active (before needing to log in again). This timeout is reset each time a visitor hits a page. Therefore if you set the timeout for 8 hours, a user would have to log in again if s/he hadn\'t visited the site for 8 hours.\r\n\r\n1800 = half hour\r\n3600 = 1 hour\r\n28000 = 8 hours\r\n86400 = 1 day\r\n604800 = 1 week\r\n1209600 = 2 weeks\r\n','6');
INSERT INTO help VALUES (18,'WebGUI','English','Using','Style Sheets','<a href=\"http://www.w3.org/Style/CSS/\">Cascading Style Sheets (CSS)</a> are a great way to manage the look and feel of any web site. They are used extensively in WebGUI.\r\n\r\nIf you are unfamiliar with how to use CSS, <a href=\"http://www.plainblack.com\">Plain Black Software</a> provides training classes on XHTML and CSS. Alternatively, Bradsoft makes an excellent CSS editor called <a href=\"http://www.bradsoft.com/topstyle/index.asp\">Top Style</a>.\r\n\r\nThe following is a list of classes used to control the look of WebGUI:\r\n\r\n<b>A</b>\r\nThe links throughout the style.\r\n\r\n<b>BODY</b>\r\nThe default setup of all pages within a style.\r\n\r\n<b>H1</b>\r\nThe headers on every page.\r\n\r\n<b>.accountOptions</b>\r\nThe links that appear under the login and account update forms.\r\n\r\n<b>.adminBar </b>\r\nThe bar that appears at the top of the page when you\'re in admin mode.\r\n\r\n<b>.content</b>\r\nThe main content area on all pages of the style.\r\n\r\n<b>.crumbTrail </b>\r\nThe crumb trail (if you\'re using that macro).\r\n\r\n<b>.eventTitle </b>\r\nThe title of an individual event.\r\n\r\n<b>.faqQuestion</b>\r\nAn F.A.Q. question. To distinguish it from an answer.\r\n\r\n<b>.formDescription </b>\r\nThe tags on all forms next to the form elements. \r\n\r\n<b>.formSubtext </b>\r\nThe tags below some form elements.\r\n\r\n<b>.highlight </b>\r\nDenotes a highlighted item, such as which message you are viewing within a list.\r\n\r\n<b>.homeLink</b>\r\nUsed by the my home (^H) macro.\r\n\r\n<b>.horizontalMenu </b>\r\nThe horizontal menu (if you use a horizontal menu macro).\r\n\r\n<b>.loginBox</b>\r\nThe login box (^L) macro.\r\n\r\n<b>.makePrintableLink</b>\r\nUsed by the make printable (^r) macro.\r\n\r\n<b>.myAccountLink</b>\r\nUsed by the my account (^a) macro.\r\n\r\n<b>.pagination </b>\r\nThe Previous and Next links on pages with pagination.\r\n\r\n<b>.pollAnswer </b>\r\nAn answer on a poll.\r\n\r\n<b>.pollColor </b>\r\nThe color of the percentage bar on a poll.\r\n\r\n<b>.pollQuestion </b>\r\nThe question on a poll.\r\n\r\n<b>.tableData </b>\r\nThe data rows on things like message boards and user contributions.\r\n\r\n<b>.tableHeader </b>\r\nThe headings of columns on things like message boards and user contributions.\r\n\r\n<b>.tableMenu </b>\r\nThe menu on things like message boards and user submissions.\r\n\r\n<b>.verticalMenu </b>\r\nThe vertical menu (if you use a verticall menu macro).\r\n\r\n','0');
INSERT INTO help VALUES (19,'WebGUI','English','Using','Macros','WebGUI macros are used to create dynamic content within otherwise static content. For instance, you may wish to show which user is logged in on every page, or you may wish to have a dynamically built menu or crumb trail. \r\n\r\nMacros always begin with a carat (^) and follow with one other character. Some macros can be extended/configured by taking the format of ^<i>x</i><b>config text</b>^/<i>x</i>. The following is a description of all the macros in the WebGUI system.\r\n\r\n<b>^a or ^a^/a - My Account Link</b>\r\nA link to your account information. In addition you can change the link text by creating a macro like this <b>^aAccount Info^/a</b>.\r\n\r\n<b>^C - Crumb Trail</b>\r\nA dynamically generated crumb trail to the current page.\r\n\r\n<b>^c - Company Name</b>\r\nThe name of your company specified in the settings by your Administrator.\r\n\r\n<b>^D or ^D^/D - Date</b>\r\nThe current date and time.\r\n\r\nYou can configure the date by using date formatting symbols. For instance, if you created a macro like this <b>^D%c %D, %y^/D</b> it would output <b>September 26, 2001</b>. The following are the available date formatting symbols:\r\n<span style=\"font-family: courier;\">\r\n    %% = %\r\n    %y = 4 digit year\r\n    %Y = 2 digit year\r\n    %m = 2 digit month\r\n    %M = variable digit month\r\n    %c = month name\r\n    %d = 2 digit day of month\r\n    %D = variable digit day of month\r\n    %w = day of week name\r\n    %h = 2 digit base 12 hour\r\n    %H = variable digit base 12 hour\r\n    %j = 2 digit base 24 hour\r\n    %J = variable digit base 24 hour\r\n    %p = lower case am/pm\r\n    %P = upper case AM/PM\r\n</span>\r\n<b>^e - Company Email Address</b>\r\nThe email address for your company specified in the settings by your Administrator.\r\n\r\n<b>^H or ^H^/H - Home Link</b>\r\nA link to the home page of this site.  In addition you can change the link text by creating a macro like this <b>^HGo Home^/H</b>.\r\n\r\n<b>^L - Login</b>\r\nA small login form.\r\n\r\n<b>^M or ^M^/M - Current Menu (Vertical)</b>\r\nA vertical menu containing the sub-pages at the current level. In addition, you may configure this macro by specifying how many levels deep the menu should go. By default it will show only the first level. To go three levels deep create a macro like this <b>^M3^/M</b>. If you set the macro to \"0\" it will track the entire site tree.\r\n\r\n<b>^m - Current Menu (Horizontal)</b>\r\nA horizontal menu containing the sub-pages at the current level.\r\n\r\n<b>^P or ^P^/P - Previous Menu (Vertical)</b>\r\nA vertical menu containing the sub-pages at the previous level. In addition, you may configure this macro by specifying how many levels deep the menu should go. By default it will show only the first level. To go three levels deep create a macro like this <b>^TP^/P</b>. If you set the macro to \"0\" it will track the entire site tree.\r\n\r\n<b>^p - Previous Menu (Horizontal)</b>\r\nA horizontal menu containing the sub-pages at the previous level.\r\n\r\n<b>^r or ^r^/r - Make Page Printable</b>\r\nCreates a link to remove the style from a page to make it printable.  In addition, you can change the link text by creating a macro like this <b>^rPRINT!^/r</b>.\r\n\r\n<b>^S^/S - Specific SubMenu (Vertical)</b>\r\nThis macro allows you to get the submenu of any page, starting with the page you specified. For instance, you could get the home page submenu by creating a macro that looks like this <b>^Shome,0^/S</b>. The first value is the urlized title of the page and the second value is the depth you\'d like the menu to go. By default it will show only the first level. To go three levels deep create a macro like this <b>^Shome,3^/S</b>.\r\n\r\n<b>^s^/s - Specific SubMenu (Horizontal)</b>\r\nThis macro allows you to get the submenu of any page, starting with the page you specified. For instance, you could get the home page submenu by creating a macro that looks like this <b>^shome^/s</b>. The value is the urlized title of the page.\r\n\r\n<b>^T or ^T^/T - Top Level Menu (Vertical)</b>\r\nA vertical menu containing the main pages of the site (aka the sub-pages from the home page). In addition, you may configure this macro by specifying how many levels deep the menu should go. By default it will show only the first level. To go three levels deep create a macro like this <b>^T3^/T</b>. If you set the macro to \"0\" it will track the entire site tree.\r\n\r\n<b>^t - Top Level Menu (Horizontal)</b>\r\nA vertical menu containing the main pages of the site (aka the sub-pages from the home page).\r\n\r\n<b>^u - Company URL</b>\r\nThe URL for your company specified in the settings by your Administrator.\r\n\r\n<b>^^ - Carat</b>\r\nSince the carat symbol is used to start all macros, this macro is in place just in case you really wanted to use a carat somewhere.\r\n\r\n<b>^/ - System URL</b>\r\nThe URL to the gateway script (including the domain for this site). This is often used within pages so that if your development server is on a domain different than your production server that your URLs will still worked when moved.\r\n\r\n<b>^\\ - Page URL</b>\r\nThe URL to the current page (including the domain for this site). This is often used within pages so that if your development server is on a domain different than your production server that your URLs will still worked when moved.\r\n\r\n<b>^@ - Username</b>\r\nThe username of the currently logged in user.\r\n\r\n<b>^# - User ID</b>\r\nThe user id of the currently logged in user.\r\n\r\n<b>^* or ^*^/* - Random Number</b>\r\nA randomly generated number. This is often used on images (such as banner ads) that you want to ensure do not cache. In addition, you may configure this macro like this <b>^*100^/*</b> to create a random number between 0 and 100.\r\n\r\n<b>^0,^1,^2,^3,^4,^5,^6,^7,^8,^9, ^-</b>\r\nThese macros are reserved for widget-specific functions as in the SQL Report widget.\r\n','0');
INSERT INTO help VALUES (1,'SQLReport','English','Add/Edit','SQL Report','SQL Reports are perhaps the most powerful widget in the WebGUI arsenal. They allow a user to query data from any database that they have access to. This is great for getting sales figures from your Accounting database or even summarizing all the message boards on your web site.\r\n\r\n<b>Title</b>\r\nThe title of this report.\r\n\r\n<b>Display the title?</b>\r\nDo you wish to disply the title?\r\n\r\n<b>Process macros?</b>\r\nDo you wish to process WebGUI macros? Unchecking this box will not process macros and will speed up page execution.\r\n\r\n<b>Description</b>\r\nDescribe the content of this report so your users will better understand what the report is all about.\r\n\r\n<b>Template</b>\r\nLayout a template of how this report should look. Usually you\'ll use HTML tables to generate a report. An example is included below.\r\n\r\nThere are 11 special macro characters used in generating SQL Reports. They are ^-, ^0, ^1, ^2, ^3, ^4, ^5, ^6, ^7, ^8, and ^9. These macros will be processed regardless of whether you checked the process macros box above. The ^- macro represents split points in the document where the report will begin and end looping. The numeric macros represent the data fields that will be returned from your query. Note that you may only have 10 fields returned per row in your query.\r\n\r\n<i>Sample Template:</i>\r\n&lt;table&gt;\r\n&lt;tr&gt;&lt;th&gt;Employee Name&lt;/th&gt;&lt;th&gt;Employee #&lt;/th&gt;&lt;th&gt;Vacation Days Remaining&lt;/th&gt;&lt;th&gt;Monthly Salary&lt;/th&gt;&lt;/tr&gt;\r\n^-\r\n&lt;tr&gt;&lt;td&gt;^0&lt;/td&gt;&lt;td&gt;^1&lt;/td&gt;&lt;td&gt;^2&lt;/td&gt;&lt;td&gt;^3&lt;/td&gt;&lt;/tr&gt;\r\n^-\r\n&lt;/table&gt;\r\n\r\n<b>Query</b>\r\nThis is a standard SQL query. If you are unfamiliar with SQL, <a href=\"http://www.plainblack.com\">Plain Black Software</a> provides training courses in SQL and database management.\r\n\r\n<b>DSN</b>\r\n<b>D</b>ata <b>S</b>ource <b>N</b>ame is the unique identifier that Perl uses to describe the location of your database. It takes the format of DBI:[driver]:[database name]:[host]. \r\n\r\n<i>Example:</i> DBI:mysql:WebGUI:localhost\r\n\r\n<b>Database User</b>\r\nThe username you use to connect to the DSN.\r\n\r\n<b>Database Password</b>\r\nThe password you use to connect to the DSN.\r\n\r\n<b>Convert carriage returns?</b>\r\nDo you wish to convert the carriage returns in the resultant data to HTML breaks (&lt;br&gt;).\r\n','1,2,3,4,5');
INSERT INTO help VALUES (21,'WebGUI','English','Using','Widget','Widgets are the true power of WebGUI. Widgets are tiny pluggable applications built to run under WebGUI. Message boards and polls are examples of widgets.\r\n\r\nTo add a widget to a page, first go to that page, then select <i>Add Content...</i> from the upper left corner of your screen. Each widget has it\'s own help so be sure to read the help if you\'re not sure how to use a widget.\r\n','0');
INSERT INTO help VALUES (1,'Article','English','Add/Edit','Article','Articles are the Swiss Army knife of WebGUI. Most pieces of static content can be added via the Article widget.\r\n\r\n<b>Title</b>\r\nWhat\'s the title for this content? Even if you don\'t wish the title to appear, it\'s a good idea to title your content so that if it is ever copied to the clipboard it will have a name.\r\n\r\n<b>Display the title?</b>\r\nDo you wish to display the title listed above?\r\n\r\n<b>Process macros?</b>\r\nDo you wish to process WebGUI macros on this article? Unchecking this box will not process macros and will speed up page execution.\r\n\r\n<b>Start Date</b>\r\nWhat date do you want this article to appear on the site? Dates are in the format of MM/DD/YYYY. You can use the JavaScript wizard to choose your date from a calendar by clicking on the <i>set date</i> button. By default the date is set to 01/01/2000.\r\n\r\n<b>End Date</b>\r\nWhat date do you want this article to be removed from the site? By default the date is set to 100 years in the future, 01/01/2100.\r\n\r\n<b>Body</b>\r\nThe body of the article is where all the content goes. You may feel free to add HTML tags as necessary to format your content. Be sure to put a &lt;p&gt; between paragraphs to add white space to your content.\r\n\r\n<b>Image</b>\r\nChoose an image (.jpg, .gif, .png) file from your hard drive. This file will be uploaded to the server and displayed in the upper-right corner of your article.\r\n\r\n<b>Link Title</b>\r\nIf you wish to add a link to your article, enter the title of the link in this field. \r\n\r\n<i>Example:</i> Google\r\n\r\n<b>Link URL</b>\r\nIf you added a link title, now add the URL (uniform resource locator) here. \r\n\r\n<i>Example:</i> http://www.google.com\r\n\r\n<b>Attachment</b>\r\nIf you wish to attach a word processor file, a zip file, or any other file for download by your users, then choose it from your hard drive.\r\n\r\n<b>Convert carriage returns?</b>\r\nIf you\'re publishin HTML there\'s generally no need to check this option, but if you aren\'t using HTML and you want a carriage return every place you hit your \"Enter\" key, then check this option.\r\n','1,2,3,4,5');
INSERT INTO help VALUES (1,'ExtraColumn','English','Add/Edit','Extra Column','Extra columns allow you to change the layout of your page for one page only. If you wish to have multiple columns on all your pages. Perhaps you should consider altering the <i>style</i> applied to your pages. \r\n\r\nColumns are always added from left to right. Therefore any existing content will be on the left of the new column.\r\n\r\n<b>Spacer</b>\r\nSpacer is the amount of space between your existing content and your new column. It is measured in pixels.\r\n\r\n<b>Width</b>\r\nWidth is the actual width of the new column to be added. Width is measured in pixels.\r\n\r\n<b>StyleSheet Class</b>\r\nBy default the <i>content</i> style (which is the style the body of your site should be using) that is applied to all columns. However, if you\'ve created a style specifically for columns, then feel free to modify this class.\r\n','1,2,3,4,5');
INSERT INTO help VALUES (27,'WebGUI','English','Add/Edit','Widget','You can add widgets by selecting from the <i>Add Content</i> pulldown menu. You can edit them by clicking on the \"Edit\" button that appears directly above an instance of a particular widget.','0');
INSERT INTO help VALUES (1,'Poll','English','Add/Edit','Poll','Polls can be used to get the impressions of your users on various topics.\r\n\r\n<b>Title</b>\r\nThe title of the poll. Even if you don\'t wish to display the title you should fill out this field so this poll will have a name if it is ever placed in the clipboard.\r\n\r\n<b>Display the title?</b>\r\nDo you wish to disply the title?\r\n\r\n<b>Process macros?</b>\r\nDo you wish to process WebGUI macros? Unchecking this box will not process macros and will speed up page execution.\r\n\r\n<b>Description</b>\r\nYou may provide a description for this poll, or give the user some background information.\r\n\r\n<b>Active</b>\r\nIf this box is checked, then users will be able to vote. Otherwise they\'ll only be able to see the results of the poll.\r\n\r\n<b>Who can vote?</b>\r\nChoose a group that can vote on this poll.\r\n\r\n<b>Graph Width</b>\r\nThe width of the poll results graph. The width is measured in pixels.\r\n\r\n<b>Question</b>\r\nWhat is the question you\'d like to ask your users?\r\n\r\n<b>Answers</b>\r\nEnter the possible answers to your question. Enter only one answer per line. Polls are only capable of 20 possible answers.\r\n\r\n<b>Reset votes.</b>\r\nReset the votes on this poll.','1,2,3,4,5');
INSERT INTO help VALUES (1,'SiteMap','English','Add/Edit','Site Map','Site maps are used to provide additional navigation in WebGUI. You could set up a traditional site map that would display a hierarchical view of all the pages in the site. On the other hand, you could use site maps to provide extra navigation at certain levels in your site.\r\n\r\n<b>Title</b>\r\nWhat title would you give to this site map? You should fill this field out even if you don\'t wish it to be displayed.\r\n\r\n<b>Display the title?</b>\r\nDo you wish to disply the title?\r\n\r\n<b>Process macros?</b>\r\nDo you wish to process WebGUI macros? Unchecking this box will not process macros and will speed up page execution.\r\n\r\n<b>Description</b>\r\nEnter a description as to why this site map is here and what purpose it serves.\r\n\r\n<b>Starting from this level?</b>\r\nIf the site map should display the page tree starting from this level, then check this box. If you wish the site map to start from the home page then uncheck it.\r\n\r\n<b>Show only one level?</b>\r\nShould the site map display only the current level of pages or all pages from this point forward? \r\n','1,2,3,4,5');
INSERT INTO help VALUES (1,'MessageBoard','English','Add/Edit','Message Board','Message boards, also called Forums and/or Discussions, are a great way to add community to any site or intranets. Many companies use message boards internally to collaborate on projects.\r\n\r\n<b>Title</b>\r\nThe name of this board.\r\n\r\n<b>Display the title?</b>\r\nDo you wish to disply the title?\r\n\r\n<b>Process macros?</b>\r\nDo you wish to process WebGUI macros? Unchecking this box will not process macros and will speed up page execution.\r\n\r\n<b>Description</b>\r\nBriefly describe what should be displayed on this message board.\r\n\r\n<b>Who can post?</b>\r\nWhat group can post to this message board?\r\n\r\n<b>Messages Per Page</b>\r\nWhen a visitor first comes to a message board s/he will be presented with a listing of all the topics (aka threads) of the message board. If a board is popular, it will quickly have many topics. The messages per page attribute allows you to specify how many topics should be shown on one page.\r\n\r\n<b>Edit Timeout</b>\r\nHow long after a user has posted to the board will their message be available for them to edit. This timeout is measured in hours.\r\n\r\n<i>Note:</i> Don\'t set this limit too high. One of the great things about message boards is that they are an accurate record of a discussion. If you allow editing for a long time, then a user has a chance to go back and change his/her mind a long time after the original statement was made.\r\n','1,2,3,4,5');
INSERT INTO help VALUES (1,'LinkList','English','Add/Edit','Link List','Link lists are just what they sound like, a list of links. Many sites have a links section, and this just automates the process.\r\n\r\n<b>Title</b>\r\nWhat is the title of this link list?\r\n\r\n<b>Display the title?</b>\r\nDo you wish to disply the title?\r\n\r\n<b>Process macros?</b>\r\nDo you wish to process WebGUI macros? Unchecking this box will not process macros and will speed up page execution.\r\n\r\n<b>Description</b>\r\nDescribe the purpose of the links in this list.\r\n\r\n<b>Proceed to add link?</b>\r\nLeave this checked if you want to add links to the link list directly after creating it.\r\n\r\n<b>Adding / Editing Links</b>\r\nYou\'ll notice at the bottom of the Edit screen that there are some options to add, edit, delete and reorder the links in your link lists. This process works exactly as the process for doing the same with widgets and pages. The three properties of links are <i>name</i>, <i>url</i>, and <i>description</i>.\r\n','1,2,3,4,5');
INSERT INTO help VALUES (13,'WebGUI','English','Edit','Mail Settings','<b>Recover Password Message</b>\r\nThe message that gets sent to a user when they use the \"recover password\" function.\r\n\r\n<b>SMTP Server</b>\r\nThis is the address of your local mail server. It is needed for all features that use the Internet email system (such as password recovery).\r\n\r\n','6');
INSERT INTO help VALUES (1,'SyndicatedContent','English','Add/Edit','Syndicated Content','Syndicated content is content that is pulled from another site using the RDF/RSS specification. This technology is often used to pull headlines from various news sites like <a href=\"http://www.cnn.com\">CNN</a> and  <a href=\"http://slashdot.org\">Slashdot</a>. It can, of course, be used for other things like sports scores, stock market info, etc.\r\n\r\nYou can find a list of syndicated content at <a href=\"http://my.userland.com\">http://my.userland.com</a>. You will need to register with an account to browse their listing of content. Also, the list contained there is by no means a complete list of all the syndicated content on the internet.\r\n\r\n<b>Title</b>\r\nWhat is the title for this content? This is often the title of the site that the content comes from.\r\n\r\n<b>Display the title?</b>\r\nDo you wish to disply the title?\r\n\r\n<b>Process macros?</b>\r\nDo you wish to process WebGUI macros? Unchecking this box will not process macros and will speed up page execution.\r\n\r\n<b>Description</b>\r\nBriefly describe the content being pulled so that your users will know what they are seeing.\r\n\r\n<b>URL to RSS file</b>\r\nProvide the exact URL (starting with http://) to the syndicated content\'s RDF or RSS file. The syndicated content will be downloaded from this URL hourly.','1,2,3,4,5');
INSERT INTO help VALUES (1,'EventsCalendar','English','Add/Edit','Events Calendar','Events calendars are used on many intranets to keep track of internal dates that affect a whole organization. Also events calendars on consumer sites are a great way to let your customers know what events you\'ll be attending and what promotions you\'ll be having.\r\n\r\n<b>Title</b>\r\nWhat is the title of this events calendar?\r\n\r\n<b>Display the title?</b>\r\nDo you wish to disply the title?\r\n\r\n<b>Process macros?</b>\r\nDo you wish to process WebGUI macros? Unchecking this box will not process macros and will speed up page execution.\r\n\r\n<b>Description</b>\r\nBriefly describe what this events calendar details.\r\n\r\n<b>Proceed to add event?</b>\r\nLeave this checked if you want to add events to the events calendar directly after creating it.\r\n\r\n<b>Add / Edit Events</b>\r\nOn the edit screen you\'ll notice that there are options to add, edit, and delete the events in your events calendar. The properties for events are <i>name</i>, <i>description</i>, <i>start date</i>,  and <i>end date</i>.\r\n\r\n<i>Note:</i> Events that have already happened will not be displayed on the events calendar.','1,2,3,4,5');
INSERT INTO help VALUES (1,'FAQ','English','Add/Edit','F.A.Q.','It seems that almost every web site, intranet, and extranet in the world has a frequently asked questions area. This widget helps you build one too.\r\n\r\n<b>Title</b>\r\nWhat is the title for this FAQ section?\r\n\r\n<b>Display the title?</b>\r\nDo you wish to disply the title?\r\n\r\n<b>Process macros?</b>\r\nDo you wish to process WebGUI macros? Unchecking this box will not process macros and will speed up page execution.\r\n\r\n<b>Description</b>\r\nBriefly describe what this FAQ covers.\r\n\r\n<b>Proceed to add question?</b>\r\nLeave this checked if you want to add questions to the FAQ directly after creating it.\r\n\r\n<b>Add / Edit Questions</b>\r\nOn the edit screen you\'ll notice options for adding, editing, deleting, and reordering the questions in your FAQ. The two properties of FAQ questions are <i>question</i> and <i>answer</i>.\r\n','1,2,3,4,5');
INSERT INTO help VALUES (11,'WebGUI','English','Edit','File Settings','<b>Path to WebGUI Extras</b>\r\nThe web-path to the directory containing WebGUI images and javascript files.\r\n\r\n<b>Maximum Attachment Size</b>\r\nThe maximum size of files allowed to be uploaded to this site. This applies to all widgets that allow uploaded files and images (like Article and User Contributions). This size is measured in kilobytes.\r\n\r\n<b>Web Attachment Path</b>\r\nThe web-path of the directory where attachments are to be stored.\r\n\r\n<b>Server Attachment Path</b>\r\nThe local path of the directory where attachments are to be stored. (Perhaps /var/www/public/uploads) Be sure that the web server has the rights to write to that directory.\r\n','6');
INSERT INTO help VALUES (2,'WebGUI','English','Edit','Authentication Settings','<b>Anonymous Registration</b>\r\nDo you wish visitors to your site to be able to register themselves?\r\n\r\n<b>Authentication Method (default)</b>\r\nWhat should the default authentication method be for new accounts that are created? The two available options are WebGUI and LDAP. WebGUI authentication means that the users will authenticate against the username and password stored in the WebGUI database. LDAP authentication means that users will authenticate against an external LDAP server.\r\n\r\n<i>Note:</i> Authentication settings can be customized on a per user basis.\r\n\r\n<b>Username Binding</b>\r\nBind the WebGUI username to the LDAP Identity. This requires the user to have the same username in WebGUI as they specified during the Anonymous Registration process. It also means that they won\'t be able to change their username later. This only in effect if the user is authenticating against LDAP.\r\n\r\n<b>LDAP URL (default)</b>\r\nThe default url to your LDAP server. The LDAP URL takes the form of <b>ldap://[server]:[port]/[base DN]</b>. Example: ldap://ldap.mycompany.com:389/o=MyCompany.\r\n\r\n<b>LDAP Identity</b>\r\nThe LDAP Identity is the unique identifier in the LDAP server that the user will be identified against. Often this field is <b>shortname</b>, which takes the form of first initial + last name. Example: jdoe. Therefore if you specify the LDAP identity to be <i>shortname</i> then Jon Doe would enter <i>jdoe</i> during the registration process.\r\n\r\n<b>LDAP Identity Name</b>\r\nThe label used to describe the LDAP Identity to the user. For instance, some companies use an LDAP server for their proxy server users to authenticate against. In the documentation or training already provided to their users, the LDAP identity is known as their <i>Web Username</b>. So you could enter that label here for consitency.\r\n\r\n<b>LDAP Password Name</b>\r\nJust as the LDAP Identity Name is a label, so is the LDAP Password Name. Use this label as you would LDAP Identity Name.\r\n\r\n','6');
INSERT INTO help VALUES (1,'UserSubmission','English','Add/Edit','User Submission System','User submission systems are a great way to add a sense of community to any site as well as get free content from your users.\r\n\r\n<b>Title</b>\r\nWhat is the title for this user submission system?\r\n\r\n<b>Display the title?</b>\r\nDo you wish to disply the title?\r\n\r\n<b>Process macros?</b>\r\nDo you wish to process WebGUI macros? Unchecking this box will not process macros and will speed up page execution.\r\n\r\n<b>Description</b>\r\nBriefly describe why this user submission system is here and what should be submitted to it.\r\n\r\n<b>Who can contribute?</b>\r\nWhat group is allowed to contribute content?\r\n\r\n<b>Submissions Per Page</b>\r\nHow many submissions should be listed per page in the submissions index?\r\n\r\n<b>Default Status</b>\r\nShould submissions be set to <i>approved</i>, <i>pending</i>, or <i>denied</i> by default?\r\n\r\n<i>Note:</i> If you set the default status to pending, then be prepared to monitor the pending queue under the Admin menu.\r\n','1,2,3,4,5');
INSERT INTO help VALUES (6,'WebGUI','English','Edit','Company Information','<b>Company Name</b>\r\nThe name of your company. It will appear on all emails and anywhere you use the Company Name macro.\r\n\r\n<b>Company Email Address</b>\r\nA general email address at your company. This is the address that all automated messages will come from. It can also be used via the WebGUI macro system.\r\n\r\n<b>Company URL</b>\r\nThe primary URL of your company. This will appear on all automated emails sent from the WebGUI system. It is also available via the WebGUI macro system.\r\n','6');
INSERT INTO help VALUES (46,'WebGUI','English','Empty','Trash','If you choose to empty your trash, any items contained in it will be lost forever. If you\'re unsure about a few items, it might be best to cut them to your clipboard before you empty the trash.','0');
INSERT INTO help VALUES (22,'WebGUI','English','Edit','Profile Settings','Profiles are used to extend the information of a particular user. In some cases profiles are important to a site, in others they are not. Use the following switches to turn the various profile sections on and off.\r\n\r\n<b>Allow real name?</b>\r\nDo you want users to enter and display their real names?\r\n\r\n<b>Allow extra contact information?</b>\r\nDo you want users to enter and display their extra contact information such as Instant Messenger IDs, cell phone numbers, and pager numbers?\r\n\r\n<b>Allow home information?</b>\r\nDo you want users to enter and display their home address and phone number?\r\n\r\n<b>Allow business information?</b>\r\nDo you want users to enter and display their work address and phone number?\r\n\r\n<b>Allow miscellaneous information?</b>\r\nDo you want users to enter and display any extra info such as gender, birthdate and home page?','6');

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

INSERT INTO international VALUES (1,'WebGUI','English','Add content...');
INSERT INTO international VALUES (2,'WebGUI','English','Page');
INSERT INTO international VALUES (3,'WebGUI','English','Paste from clipboard...');
INSERT INTO international VALUES (4,'WebGUI','English','Manage settings.');
INSERT INTO international VALUES (5,'WebGUI','English','Manage groups.');
INSERT INTO international VALUES (6,'WebGUI','English','Manage styles.');
INSERT INTO international VALUES (7,'WebGUI','English','Manage users.');
INSERT INTO international VALUES (8,'WebGUI','English','View page not found.');
INSERT INTO international VALUES (9,'WebGUI','English','View clipboard.');
INSERT INTO international VALUES (10,'WebGUI','English','View trash.');
INSERT INTO international VALUES (11,'WebGUI','English','Empy trash.');
INSERT INTO international VALUES (12,'WebGUI','English','Turn admin off.');
INSERT INTO international VALUES (13,'WebGUI','English','View help index.');
INSERT INTO international VALUES (14,'WebGUI','English','View pending submissions.');
INSERT INTO international VALUES (15,'WebGUI','English','January');
INSERT INTO international VALUES (16,'WebGUI','English','February');
INSERT INTO international VALUES (17,'WebGUI','English','March');
INSERT INTO international VALUES (18,'WebGUI','English','April');
INSERT INTO international VALUES (19,'WebGUI','English','May');
INSERT INTO international VALUES (20,'WebGUI','English','June');
INSERT INTO international VALUES (21,'WebGUI','English','July');
INSERT INTO international VALUES (22,'WebGUI','English','August');
INSERT INTO international VALUES (23,'WebGUI','English','September');
INSERT INTO international VALUES (24,'WebGUI','English','October');
INSERT INTO international VALUES (25,'WebGUI','English','November');
INSERT INTO international VALUES (26,'WebGUI','English','December');
INSERT INTO international VALUES (27,'WebGUI','English','Sunday');
INSERT INTO international VALUES (28,'WebGUI','English','Monday');
INSERT INTO international VALUES (29,'WebGUI','English','Tuesday');
INSERT INTO international VALUES (30,'WebGUI','English','Wednesday');
INSERT INTO international VALUES (31,'WebGUI','English','Thursday');
INSERT INTO international VALUES (32,'WebGUI','English','Friday');
INSERT INTO international VALUES (33,'WebGUI','English','Saturday');
INSERT INTO international VALUES (34,'WebGUI','English','set date');
INSERT INTO international VALUES (35,'WebGUI','English','Administrative Function');
INSERT INTO international VALUES (36,'WebGUI','English','You must be an administrator to perform this function. Please contact one of your administrators. The following is a list of the administrators for this system:');
INSERT INTO international VALUES (37,'WebGUI','English','Permission Denied!');
INSERT INTO international VALUES (38,'WebGUI','English','You do not have sufficient privileges to perform this operation. Please <a href=\"^\\?op=displayLogin\">log in with an account</a> that has sufficient privileges before attempting this operation.');
INSERT INTO international VALUES (39,'WebGUI','English','You do not have sufficient privileges to access this page.');
INSERT INTO international VALUES (41,'WebGUI','English','You\'re attempting to remove a vital component of the WebGUI system. If you were allowed to continue WebGUI may cease to function.');
INSERT INTO international VALUES (40,'WebGUI','English','Vital Component');
INSERT INTO international VALUES (42,'WebGUI','English','Please Confirm');
INSERT INTO international VALUES (43,'WebGUI','English','Are you certain that you wish to delete this content?');
INSERT INTO international VALUES (44,'WebGUI','English','Yes, I\'m sure.');
INSERT INTO international VALUES (45,'WebGUI','English','No, I made a mistake.');
INSERT INTO international VALUES (46,'WebGUI','English','My Account');
INSERT INTO international VALUES (47,'WebGUI','English','Home');
INSERT INTO international VALUES (48,'WebGUI','English','Hello');
INSERT INTO international VALUES (49,'WebGUI','English','Click <a href=\"^\\?op=logout\">here</a> to log out.');
INSERT INTO international VALUES (50,'WebGUI','English','Username');
INSERT INTO international VALUES (51,'WebGUI','English','Password');
INSERT INTO international VALUES (52,'WebGUI','English','login');
INSERT INTO international VALUES (53,'WebGUI','English','Make Page Printable');
INSERT INTO international VALUES (54,'WebGUI','English','Create Account');
INSERT INTO international VALUES (55,'WebGUI','English','Password (confirm)');
INSERT INTO international VALUES (56,'WebGUI','English','Email Address');
INSERT INTO international VALUES (57,'WebGUI','English','This is only necessary if you wish to use features that require Email.');
INSERT INTO international VALUES (58,'WebGUI','English','I already have an account.');
INSERT INTO international VALUES (59,'WebGUI','English','I forgot my password.');
INSERT INTO international VALUES (60,'WebGUI','English','Are you certain you want to deactivate your account. If you proceed your account information will be lost permanently.');
INSERT INTO international VALUES (61,'WebGUI','English','Update Account Information');
INSERT INTO international VALUES (62,'WebGUI','English','save');
INSERT INTO international VALUES (63,'WebGUI','English','Turn admin on.');
INSERT INTO international VALUES (64,'WebGUI','English','Log out.');
INSERT INTO international VALUES (65,'WebGUI','English','Please deactivate my account permanently.');
INSERT INTO international VALUES (66,'WebGUI','English','Log In');
INSERT INTO international VALUES (67,'WebGUI','English','Create a new account.');
INSERT INTO international VALUES (68,'WebGUI','English','The account information you supplied is invalid. Either the account does not exist or the username/password combination was incorrect.');
INSERT INTO international VALUES (69,'WebGUI','English','Please contact your system administrator for assistance.');
INSERT INTO international VALUES (70,'WebGUI','English','Error');
INSERT INTO international VALUES (71,'WebGUI','English','Recover password');
INSERT INTO international VALUES (72,'WebGUI','English','recover');
INSERT INTO international VALUES (73,'WebGUI','English','Log in.');
INSERT INTO international VALUES (74,'WebGUI','English','Account Information');
INSERT INTO international VALUES (75,'WebGUI','English','Your account information has been sent to your email address.');
INSERT INTO international VALUES (76,'WebGUI','English','That email address is not in our databases.');
INSERT INTO international VALUES (77,'WebGUI','English','That account name is already in use by another member of this site. Please try a different username. The following are some suggestions:');
INSERT INTO international VALUES (78,'WebGUI','English','Your passwords did not match. Please try again.');
INSERT INTO international VALUES (79,'WebGUI','English','Cannot connect to LDAP server.');
INSERT INTO international VALUES (80,'WebGUI','English','Account created successfully!');
INSERT INTO international VALUES (81,'WebGUI','English','Account updated successfully!');
INSERT INTO international VALUES (82,'WebGUI','English','Administrative functions...');
INSERT INTO international VALUES (83,'WebGUI','English','Add Group');
INSERT INTO international VALUES (84,'WebGUI','English','Group Name');
INSERT INTO international VALUES (85,'WebGUI','English','Description');
INSERT INTO international VALUES (86,'WebGUI','English','Are you certain you wish to delete this group? Beware that deleting a group is permanent and will remove all privileges associated with this group.');
INSERT INTO international VALUES (87,'WebGUI','English','Edit Group');
INSERT INTO international VALUES (88,'WebGUI','English','Users In Group');
INSERT INTO international VALUES (89,'WebGUI','English','Groups');
INSERT INTO international VALUES (90,'WebGUI','English','Add new group.');
INSERT INTO international VALUES (91,'WebGUI','English','Previous Page');
INSERT INTO international VALUES (92,'WebGUI','English','Next Page');
INSERT INTO international VALUES (93,'WebGUI','English','Help');
INSERT INTO international VALUES (94,'WebGUI','English','See also');
INSERT INTO international VALUES (95,'WebGUI','English','Help Index');
INSERT INTO international VALUES (96,'WebGUI','English','Sorted By Action');
INSERT INTO international VALUES (97,'WebGUI','English','Sorted by Object');
INSERT INTO international VALUES (98,'WebGUI','English','Add Page');
INSERT INTO international VALUES (99,'WebGUI','English','Title');
INSERT INTO international VALUES (100,'WebGUI','English','Meta Tags');
INSERT INTO international VALUES (101,'WebGUI','English','Are you certain that you wish to delete this page, its content, and all items under it?');
INSERT INTO international VALUES (102,'WebGUI','English','Edit Page');
INSERT INTO international VALUES (103,'WebGUI','English','Page Specifics');
INSERT INTO international VALUES (104,'WebGUI','English','Page URL');
INSERT INTO international VALUES (105,'WebGUI','English','Style');
INSERT INTO international VALUES (106,'WebGUI','English','Check to give this style to all sub-pages.');
INSERT INTO international VALUES (107,'WebGUI','English','Privileges');
INSERT INTO international VALUES (108,'WebGUI','English','Owner');
INSERT INTO international VALUES (109,'WebGUI','English','Owner can view?');
INSERT INTO international VALUES (110,'WebGUI','English','Owner can edit?');
INSERT INTO international VALUES (111,'WebGUI','English','Group');
INSERT INTO international VALUES (112,'WebGUI','English','Group can view?');
INSERT INTO international VALUES (113,'WebGUI','English','Group can edit?');
INSERT INTO international VALUES (114,'WebGUI','English','Anybody can view?');
INSERT INTO international VALUES (115,'WebGUI','English','Anybody can edit?');
INSERT INTO international VALUES (116,'WebGUI','English','Check to give these privileges to all sub-pages.');
INSERT INTO international VALUES (117,'WebGUI','English','Edit Authentication Settings');
INSERT INTO international VALUES (118,'WebGUI','English','Anonymous Registration');
INSERT INTO international VALUES (119,'WebGUI','English','Authentication Method (default)');
INSERT INTO international VALUES (120,'WebGUI','English','LDAP URL (default)');
INSERT INTO international VALUES (121,'WebGUI','English','LDAP Identity (default)');
INSERT INTO international VALUES (122,'WebGUI','English','LDAP Identity Name');
INSERT INTO international VALUES (123,'WebGUI','English','LDAP Password Name');
INSERT INTO international VALUES (124,'WebGUI','English','Edit Company Information');
INSERT INTO international VALUES (125,'WebGUI','English','Company Name');
INSERT INTO international VALUES (126,'WebGUI','English','Company Email Address');
INSERT INTO international VALUES (127,'WebGUI','English','Company URL');
INSERT INTO international VALUES (128,'WebGUI','English','Edit File Settings');
INSERT INTO international VALUES (129,'WebGUI','English','Path to WebGUI Extras');
INSERT INTO international VALUES (130,'WebGUI','English','Maximum Attachment Size');
INSERT INTO international VALUES (131,'WebGUI','English','Web Attachment Path');
INSERT INTO international VALUES (132,'WebGUI','English','Server Attachment Path');
INSERT INTO international VALUES (133,'WebGUI','English','Edit Mail Settings');
INSERT INTO international VALUES (134,'WebGUI','English','Recover Password Message');
INSERT INTO international VALUES (135,'WebGUI','English','SMTP Server');
INSERT INTO international VALUES (136,'WebGUI','English','Home Page');
INSERT INTO international VALUES (137,'WebGUI','English','Page Not Found Page');
INSERT INTO international VALUES (138,'WebGUI','English','Yes');
INSERT INTO international VALUES (139,'WebGUI','English','No');
INSERT INTO international VALUES (140,'WebGUI','English','Edit Miscellaneous Settings');
INSERT INTO international VALUES (141,'WebGUI','English','Not Found Page');
INSERT INTO international VALUES (142,'WebGUI','English','Session Timeout');
INSERT INTO international VALUES (143,'WebGUI','English','Manage Settings');
INSERT INTO international VALUES (144,'WebGUI','English','View statistics.');
INSERT INTO international VALUES (145,'WebGUI','English','WebGUI Build Version');
INSERT INTO international VALUES (146,'WebGUI','English','Active Sessions');
INSERT INTO international VALUES (147,'WebGUI','English','Viewable Pages');
INSERT INTO international VALUES (148,'WebGUI','English','Viewable Widgets');
INSERT INTO international VALUES (149,'WebGUI','English','Users');
INSERT INTO international VALUES (150,'WebGUI','English','Add Style');
INSERT INTO international VALUES (151,'WebGUI','English','Style Name');
INSERT INTO international VALUES (152,'WebGUI','English','Header');
INSERT INTO international VALUES (153,'WebGUI','English','Footer');
INSERT INTO international VALUES (154,'WebGUI','English','Style Sheet');
INSERT INTO international VALUES (155,'WebGUI','English','Are you certain you wish to delete this style and migrate all pages using this style to the \"Fail Safe\" style?');
INSERT INTO international VALUES (156,'WebGUI','English','Edit Style');
INSERT INTO international VALUES (157,'WebGUI','English','Styles');
INSERT INTO international VALUES (158,'WebGUI','English','Add a new style.');
INSERT INTO international VALUES (159,'WebGUI','English','Pending Submissions');
INSERT INTO international VALUES (160,'WebGUI','English','Date Submitted');
INSERT INTO international VALUES (161,'WebGUI','English','Submitted By');
INSERT INTO international VALUES (162,'WebGUI','English','Are you certain that you wish to purge all the pages and widgets in the trash?');
INSERT INTO international VALUES (163,'WebGUI','English','Add User');
INSERT INTO international VALUES (164,'WebGUI','English','Authentication Method');
INSERT INTO international VALUES (165,'WebGUI','English','LDAP URL');
INSERT INTO international VALUES (166,'WebGUI','English','Connect DN');
INSERT INTO international VALUES (167,'WebGUI','English','Are you certain you want to delete this user? Be warned that all this user\'s information will be lost permanently if you choose to proceed.');
INSERT INTO international VALUES (168,'WebGUI','English','Edit User');
INSERT INTO international VALUES (169,'WebGUI','English','Add a new user.');
INSERT INTO international VALUES (170,'WebGUI','English','search');
INSERT INTO international VALUES (171,'WebGUI','English','rich edit');
INSERT INTO international VALUES (172,'WebGUI','English','Article');
INSERT INTO international VALUES (173,'WebGUI','English','Add Article');
INSERT INTO international VALUES (174,'WebGUI','English','Display the title?');
INSERT INTO international VALUES (175,'WebGUI','English','Process macros?');
INSERT INTO international VALUES (176,'WebGUI','English','Start Date');
INSERT INTO international VALUES (177,'WebGUI','English','End Date');
INSERT INTO international VALUES (178,'WebGUI','English','Body');
INSERT INTO international VALUES (179,'WebGUI','English','Image');
INSERT INTO international VALUES (180,'WebGUI','English','Link Title');
INSERT INTO international VALUES (181,'WebGUI','English','Link URL');
INSERT INTO international VALUES (182,'WebGUI','English','Attachment');
INSERT INTO international VALUES (183,'WebGUI','English','Convert carriage returns?');
INSERT INTO international VALUES (184,'WebGUI','English','(Check if you aren\'t adding &lt;br&gt; manually.)');
INSERT INTO international VALUES (185,'WebGUI','English','Edit Article');
INSERT INTO international VALUES (186,'WebGUI','English','Delete');
INSERT INTO international VALUES (187,'WebGUI','English','Events Calendar');
INSERT INTO international VALUES (188,'WebGUI','English','Add Events Calendar');
INSERT INTO international VALUES (189,'WebGUI','English','Happens only once.');
INSERT INTO international VALUES (190,'WebGUI','English','Day');
INSERT INTO international VALUES (191,'WebGUI','English','Week');
INSERT INTO international VALUES (192,'WebGUI','English','Add Event');
INSERT INTO international VALUES (193,'WebGUI','English','Recurs every');
INSERT INTO international VALUES (194,'WebGUI','English','until');
INSERT INTO international VALUES (195,'WebGUI','English','Are you certain that you want to delete this event');
INSERT INTO international VALUES (197,'WebGUI','English','Edit Events Calendar');
INSERT INTO international VALUES (196,'WebGUI','English','<b>and</b> all of its recurring events');
INSERT INTO international VALUES (198,'WebGUI','English','Edit Event');
INSERT INTO international VALUES (199,'WebGUI','English','Extra Column');
INSERT INTO international VALUES (200,'WebGUI','English','Add Extra Column');
INSERT INTO international VALUES (201,'WebGUI','English','Spacer');
INSERT INTO international VALUES (202,'WebGUI','English','Width');
INSERT INTO international VALUES (203,'WebGUI','English','StyleSheet Class');
INSERT INTO international VALUES (204,'WebGUI','English','Edit Extra Column');
INSERT INTO international VALUES (205,'WebGUI','English','F.A.Q.');
INSERT INTO international VALUES (206,'WebGUI','English','Add F.A.Q.');
INSERT INTO international VALUES (207,'WebGUI','English','Add Question');
INSERT INTO international VALUES (208,'WebGUI','English','Question');
INSERT INTO international VALUES (209,'WebGUI','English','Answer');
INSERT INTO international VALUES (211,'WebGUI','English','Edit F.A.Q.');
INSERT INTO international VALUES (210,'WebGUI','English','Are you certain that you want to delete this question?');
INSERT INTO international VALUES (212,'WebGUI','English','Add a new question.');
INSERT INTO international VALUES (213,'WebGUI','English','Edit Question');
INSERT INTO international VALUES (214,'WebGUI','English','Link List');
INSERT INTO international VALUES (215,'WebGUI','English','Add Link');
INSERT INTO international VALUES (216,'WebGUI','English','URL');
INSERT INTO international VALUES (217,'WebGUI','English','Are you certain that you want to delete this link?');
INSERT INTO international VALUES (218,'WebGUI','English','Edit Link List');
INSERT INTO international VALUES (219,'WebGUI','English','Add Link List');
INSERT INTO international VALUES (220,'WebGUI','English','Edit Link');
INSERT INTO international VALUES (221,'WebGUI','English','Add a new link.');
INSERT INTO international VALUES (222,'WebGUI','English','Add Message Board');
INSERT INTO international VALUES (223,'WebGUI','English','Message Board');
INSERT INTO international VALUES (224,'WebGUI','English','Who can post?');
INSERT INTO international VALUES (225,'WebGUI','English','Messages Per Page');
INSERT INTO international VALUES (226,'WebGUI','English','Edit Timeout');
INSERT INTO international VALUES (227,'WebGUI','English','Edit Message Board');
INSERT INTO international VALUES (228,'WebGUI','English','Editing Message...');
INSERT INTO international VALUES (229,'WebGUI','English','Subject');
INSERT INTO international VALUES (230,'WebGUI','English','Message');
INSERT INTO international VALUES (231,'WebGUI','English','Posting New Message...');
INSERT INTO international VALUES (232,'WebGUI','English','no subject');
INSERT INTO international VALUES (233,'WebGUI','English','(eom)');
INSERT INTO international VALUES (234,'WebGUI','English','Posting Reply...');
INSERT INTO international VALUES (235,'WebGUI','English','Edit Message');
INSERT INTO international VALUES (236,'WebGUI','English','Post Reply');
INSERT INTO international VALUES (237,'WebGUI','English','Subject:');
INSERT INTO international VALUES (238,'WebGUI','English','Author:');
INSERT INTO international VALUES (239,'WebGUI','English','Date:');
INSERT INTO international VALUES (240,'WebGUI','English','Message ID:');
INSERT INTO international VALUES (241,'WebGUI','English','Previous Thread');
INSERT INTO international VALUES (242,'WebGUI','English','Back To Message List');
INSERT INTO international VALUES (243,'WebGUI','English','Next Thread');
INSERT INTO international VALUES (244,'WebGUI','English','Author');
INSERT INTO international VALUES (245,'WebGUI','English','Date');
INSERT INTO international VALUES (246,'WebGUI','English','Post New Message');
INSERT INTO international VALUES (247,'WebGUI','English','Thread Started');
INSERT INTO international VALUES (248,'WebGUI','English','Replies');
INSERT INTO international VALUES (249,'WebGUI','English','Last Reply');
INSERT INTO international VALUES (250,'WebGUI','English','Poll');
INSERT INTO international VALUES (251,'WebGUI','English','Add Poll');
INSERT INTO international VALUES (252,'WebGUI','English','Active');
INSERT INTO international VALUES (253,'WebGUI','English','Who can vote?');
INSERT INTO international VALUES (254,'WebGUI','English','Graph Width');
INSERT INTO international VALUES (255,'WebGUI','English','Question');
INSERT INTO international VALUES (256,'WebGUI','English','Answers');
INSERT INTO international VALUES (257,'WebGUI','English','(Enter one answer per line. No more than 20.)');
INSERT INTO international VALUES (258,'WebGUI','English','Edit Poll');
INSERT INTO international VALUES (259,'WebGUI','English','SQL Report');
INSERT INTO international VALUES (260,'WebGUI','English','Add SQL Report');
INSERT INTO international VALUES (261,'WebGUI','English','Template');
INSERT INTO international VALUES (262,'WebGUI','English','Query');
INSERT INTO international VALUES (263,'WebGUI','English','DSN');
INSERT INTO international VALUES (264,'WebGUI','English','Database User');
INSERT INTO international VALUES (265,'WebGUI','English','Database Password');
INSERT INTO international VALUES (266,'WebGUI','English','Edit SQL Report');
INSERT INTO international VALUES (267,'WebGUI','English','Error: The DSN specified is of an improper format.');
INSERT INTO international VALUES (268,'WebGUI','English','Error: The SQL specified is of an improper format.');
INSERT INTO international VALUES (269,'WebGUI','English','Error: There was a problem with the query.');
INSERT INTO international VALUES (270,'WebGUI','English','Error: Could not connect to the database.');
INSERT INTO international VALUES (271,'WebGUI','English','Syndicated Content');
INSERT INTO international VALUES (272,'WebGUI','English','Add Syndicated Content');
INSERT INTO international VALUES (273,'WebGUI','English','URL to RSS File');
INSERT INTO international VALUES (274,'WebGUI','English','Edit Syndicated Content');
INSERT INTO international VALUES (275,'WebGUI','English','Last Fetched');
INSERT INTO international VALUES (276,'WebGUI','English','Current Content');
INSERT INTO international VALUES (277,'WebGUI','English','User Submission System');
INSERT INTO international VALUES (278,'WebGUI','English','Add User Submission System');
INSERT INTO international VALUES (279,'WebGUI','English','Who can contribute?');
INSERT INTO international VALUES (280,'WebGUI','English','Submissions Per Page');
INSERT INTO international VALUES (281,'WebGUI','English','Approved');
INSERT INTO international VALUES (282,'WebGUI','English','Denied');
INSERT INTO international VALUES (283,'WebGUI','English','Pending');
INSERT INTO international VALUES (284,'WebGUI','English','Default Status');
INSERT INTO international VALUES (285,'WebGUI','English','Add Submission');
INSERT INTO international VALUES (286,'WebGUI','English','(Uncheck if you\'re writing an HTML submission.)');
INSERT INTO international VALUES (287,'WebGUI','English','Date Submitted');
INSERT INTO international VALUES (288,'WebGUI','English','Status');
INSERT INTO international VALUES (289,'WebGUI','English','Edit/Delete');
INSERT INTO international VALUES (290,'WebGUI','English','Untitiled');
INSERT INTO international VALUES (291,'WebGUI','English','Are you certain you wish to delete this submission?');
INSERT INTO international VALUES (292,'WebGUI','English','Edit User Submission System');
INSERT INTO international VALUES (293,'WebGUI','English','Edit Submission');
INSERT INTO international VALUES (294,'WebGUI','English','Post New Submission');
INSERT INTO international VALUES (295,'WebGUI','English','Date Submitted');
INSERT INTO international VALUES (296,'WebGUI','English','Submitted By');
INSERT INTO international VALUES (297,'WebGUI','English','Submitted By:');
INSERT INTO international VALUES (298,'WebGUI','English','Date Submitted:');
INSERT INTO international VALUES (299,'WebGUI','English','Approve');
INSERT INTO international VALUES (300,'WebGUI','English','Leave Pending');
INSERT INTO international VALUES (301,'WebGUI','English','Deny');
INSERT INTO international VALUES (302,'WebGUI','English','Edit');
INSERT INTO international VALUES (303,'WebGUI','English','Return To Submissions List');
INSERT INTO international VALUES (304,'WebGUI','English','Language');
INSERT INTO international VALUES (305,'WebGUI','English','Reset votes.');
INSERT INTO international VALUES (284,'WebGUI','Deutsch','Standardstatus');
INSERT INTO international VALUES (283,'WebGUI','Deutsch','Ausstehend');
INSERT INTO international VALUES (282,'WebGUI','Deutsch','Verboten');
INSERT INTO international VALUES (281,'WebGUI','Deutsch','Erlaubt');
INSERT INTO international VALUES (280,'WebGUI','Deutsch','Beiträge pro Seite');
INSERT INTO international VALUES (279,'WebGUI','Deutsch','Wer kann Beiträge schreiben?');
INSERT INTO international VALUES (277,'WebGUI','Deutsch','Benutzer Beitragssystem');
INSERT INTO international VALUES (278,'WebGUI','Deutsch','Benutzer Beitragssystem hinzufügen');
INSERT INTO international VALUES (276,'WebGUI','Deutsch','Aktueller Inhalt');
INSERT INTO international VALUES (275,'WebGUI','Deutsch','zuletzt geholt');
INSERT INTO international VALUES (274,'WebGUI','Deutsch','Clipping-Dienst bearbeiten');
INSERT INTO international VALUES (273,'WebGUI','Deutsch','URL zur RSS-Datei');
INSERT INTO international VALUES (272,'WebGUI','Deutsch','Clipping-Dienst hinzufügen');
INSERT INTO international VALUES (271,'WebGUI','Deutsch','Clipping-Dienst');
INSERT INTO international VALUES (270,'WebGUI','Deutsch','Fehler: Datenbankverbindung konnte nicht aufgebaut werden.');
INSERT INTO international VALUES (269,'WebGUI','Deutsch','Fehler: Es gab ein Problem mit der Abfrage.');
INSERT INTO international VALUES (267,'WebGUI','Deutsch','Fehler: Die DSN besitzt das falsche Format.');
INSERT INTO international VALUES (268,'WebGUI','Deutsch','Fehler: Das SQL-Statement ist im falschen Format.');
INSERT INTO international VALUES (266,'WebGUI','Deutsch','SQL Bericht bearbeiten');
INSERT INTO international VALUES (265,'WebGUI','Deutsch','Datenbankpasswort');
INSERT INTO international VALUES (264,'WebGUI','Deutsch','Datenbankbenutzer');
INSERT INTO international VALUES (263,'WebGUI','Deutsch','DSN (Data Source Name)');
INSERT INTO international VALUES (262,'WebGUI','Deutsch','Abfrage');
INSERT INTO international VALUES (261,'WebGUI','Deutsch','Schablone');
INSERT INTO international VALUES (260,'WebGUI','Deutsch','SQL Bericht hinzufügen');
INSERT INTO international VALUES (259,'WebGUI','Deutsch','SQL Bericht');
INSERT INTO international VALUES (258,'WebGUI','Deutsch','Abstimmung bearbeiten');
INSERT INTO international VALUES (257,'WebGUI','Deutsch','(Eine Antwort pro Zeile. Bitte nicht mehr als 20 verschiedene Antworten)');
INSERT INTO international VALUES (253,'WebGUI','Deutsch','Wer kann abstimmen?');
INSERT INTO international VALUES (256,'WebGUI','Deutsch','Antworten');
INSERT INTO international VALUES (255,'WebGUI','Deutsch','Frage');
INSERT INTO international VALUES (254,'WebGUI','Deutsch','Breite der Grafik');
INSERT INTO international VALUES (248,'WebGUI','Deutsch','Antworten');
INSERT INTO international VALUES (249,'WebGUI','Deutsch','Letzte Antwort');
INSERT INTO international VALUES (250,'WebGUI','Deutsch','Abstimmung');
INSERT INTO international VALUES (251,'WebGUI','Deutsch','Abstimmung hinzufügen');
INSERT INTO international VALUES (252,'WebGUI','Deutsch','Aktiv');
INSERT INTO international VALUES (247,'WebGUI','Deutsch','Diskussion begonnen');
INSERT INTO international VALUES (245,'WebGUI','Deutsch','Datum');
INSERT INTO international VALUES (246,'WebGUI','Deutsch','Neuen Beitrag schreiben');
INSERT INTO international VALUES (244,'WebGUI','Deutsch','Autor');
INSERT INTO international VALUES (241,'WebGUI','Deutsch','Vorherige Diskussion');
INSERT INTO international VALUES (242,'WebGUI','Deutsch','Zurück zur Beitragsliste');
INSERT INTO international VALUES (243,'WebGUI','Deutsch','Nächste Diskussion');
INSERT INTO international VALUES (240,'WebGUI','Deutsch','Beitrags ID:');
INSERT INTO international VALUES (238,'WebGUI','Deutsch','Autor:');
INSERT INTO international VALUES (239,'WebGUI','Deutsch','Datum:');
INSERT INTO international VALUES (237,'WebGUI','Deutsch','Betreff:');
INSERT INTO international VALUES (236,'WebGUI','Deutsch','Antwort schicken');
INSERT INTO international VALUES (230,'WebGUI','Deutsch','Beitrag');
INSERT INTO international VALUES (231,'WebGUI','Deutsch','Neuen Beitrag schreiben...');
INSERT INTO international VALUES (232,'WebGUI','Deutsch','kein Betreff');
INSERT INTO international VALUES (233,'WebGUI','Deutsch','(eom)');
INSERT INTO international VALUES (234,'WebGUI','Deutsch','Antworten...');
INSERT INTO international VALUES (235,'WebGUI','Deutsch','Beitrag bearbeiten');
INSERT INTO international VALUES (229,'WebGUI','Deutsch','Betreff');
INSERT INTO international VALUES (228,'WebGUI','Deutsch','Beiträge bearbeiten ...');
INSERT INTO international VALUES (227,'WebGUI','Deutsch','Diskussionsforum bearbeiten');
INSERT INTO international VALUES (225,'WebGUI','Deutsch','Beiträge pro Seite');
INSERT INTO international VALUES (226,'WebGUI','Deutsch','Timeout zum bearbeiten');
INSERT INTO international VALUES (223,'WebGUI','Deutsch','Diskussionsforum');
INSERT INTO international VALUES (224,'WebGUI','Deutsch','Wer kann Beiträge schreiben?');
INSERT INTO international VALUES (222,'WebGUI','Deutsch','Diskussionsforum hinzufügen');
INSERT INTO international VALUES (221,'WebGUI','Deutsch','Neuen Link hinzufügen');
INSERT INTO international VALUES (220,'WebGUI','Deutsch','Link bearbeiten');
INSERT INTO international VALUES (219,'WebGUI','Deutsch','Link Liste hinzufügen');
INSERT INTO international VALUES (218,'WebGUI','Deutsch','Link Liste bearbeiten');
INSERT INTO international VALUES (217,'WebGUI','Deutsch','Sind Sie sicher, dass Sie diesen Link löschen wollen?');
INSERT INTO international VALUES (215,'WebGUI','Deutsch','Link hinzufügen');
INSERT INTO international VALUES (216,'WebGUI','Deutsch','URL');
INSERT INTO international VALUES (213,'WebGUI','Deutsch','Frage bearbeiten');
INSERT INTO international VALUES (214,'WebGUI','Deutsch','Link Liste');
INSERT INTO international VALUES (212,'WebGUI','Deutsch','Neue Frage hinzufügen');
INSERT INTO international VALUES (211,'WebGUI','Deutsch','F.A.Q. bearbeiten');
INSERT INTO international VALUES (209,'WebGUI','Deutsch','Antwort');
INSERT INTO international VALUES (210,'WebGUI','Deutsch','Sind Sie sicher, dass Sie diese Frage löschen wollen?');
INSERT INTO international VALUES (208,'WebGUI','Deutsch','Frage');
INSERT INTO international VALUES (204,'WebGUI','Deutsch','Extra Spalte bearbeiten');
INSERT INTO international VALUES (205,'WebGUI','Deutsch','F.A.Q.');
INSERT INTO international VALUES (206,'WebGUI','Deutsch','F.A.Q. hinzufügen');
INSERT INTO international VALUES (207,'WebGUI','Deutsch','Frage hinzufügen');
INSERT INTO international VALUES (2,'WebGUI','Deutsch','Seite');
INSERT INTO international VALUES (1,'WebGUI','Deutsch','Inhalt hinzufügen...');
INSERT INTO international VALUES (3,'WebGUI','Deutsch','Aus Zwischenablage einfügen...');
INSERT INTO international VALUES (4,'WebGUI','Deutsch','Einstellungen verwalten');
INSERT INTO international VALUES (5,'WebGUI','Deutsch','Gruppen verwalten');
INSERT INTO international VALUES (7,'WebGUI','Deutsch','Benutzer verwalten');
INSERT INTO international VALUES (6,'WebGUI','Deutsch','Stile verwalten');
INSERT INTO international VALUES (8,'WebGUI','Deutsch','\"Seite nicht gefunden\" anschauen');
INSERT INTO international VALUES (11,'WebGUI','Deutsch','Mülleimer leeren');
INSERT INTO international VALUES (10,'WebGUI','Deutsch','Mülleimer anschauen');
INSERT INTO international VALUES (9,'WebGUI','Deutsch','Zwischenablage anschauen');
INSERT INTO international VALUES (13,'WebGUI','Deutsch','Hilfe anschauen');
INSERT INTO international VALUES (12,'WebGUI','Deutsch','Administrationsmodus abschalten');
INSERT INTO international VALUES (14,'WebGUI','Deutsch','Ausstehende Beiträge anschauen');
INSERT INTO international VALUES (15,'WebGUI','Deutsch','Januar');
INSERT INTO international VALUES (16,'WebGUI','Deutsch','Februar');
INSERT INTO international VALUES (18,'WebGUI','Deutsch','April');
INSERT INTO international VALUES (17,'WebGUI','Deutsch','März');
INSERT INTO international VALUES (19,'WebGUI','Deutsch','Mai');
INSERT INTO international VALUES (20,'WebGUI','Deutsch','Juni');
INSERT INTO international VALUES (22,'WebGUI','Deutsch','August');
INSERT INTO international VALUES (21,'WebGUI','Deutsch','Juli');
INSERT INTO international VALUES (24,'WebGUI','Deutsch','Oktober');
INSERT INTO international VALUES (23,'WebGUI','Deutsch','September');
INSERT INTO international VALUES (25,'WebGUI','Deutsch','November');
INSERT INTO international VALUES (26,'WebGUI','Deutsch','Dezember');
INSERT INTO international VALUES (27,'WebGUI','Deutsch','Sonntag');
INSERT INTO international VALUES (28,'WebGUI','Deutsch','Montag');
INSERT INTO international VALUES (29,'WebGUI','Deutsch','Dienstag');
INSERT INTO international VALUES (30,'WebGUI','Deutsch','Mittwoch');
INSERT INTO international VALUES (31,'WebGUI','Deutsch','Donnerstag');
INSERT INTO international VALUES (33,'WebGUI','Deutsch','Samstag');
INSERT INTO international VALUES (32,'WebGUI','Deutsch','Freitag');
INSERT INTO international VALUES (35,'WebGUI','Deutsch','Administrative Funktion');
INSERT INTO international VALUES (34,'WebGUI','Deutsch','Datum setzen');
INSERT INTO international VALUES (36,'WebGUI','Deutsch','Um diese Funktion ausführen zu können, müssen Sie Administrator sein. Eine der folgenden Personen kann Sie zum Administrator machen:');
INSERT INTO international VALUES (37,'WebGUI','Deutsch','Zugriff verweigert!');
INSERT INTO international VALUES (38,'WebGUI','Deutsch','Sie sind nicht berechtigt, diese Aktion auszuführen. <a href=\"^?op=displayLogin\">Melden Sie sich bitte mit einem Benutzernamen an</a>, der über ausreichende Rechte verfügt.');
INSERT INTO international VALUES (39,'WebGUI','Deutsch','Sie sind nicht berechtigt, diese Seite anzuschauen.');
INSERT INTO international VALUES (40,'WebGUI','Deutsch','Notwendiger Bestandteil');
INSERT INTO international VALUES (43,'WebGUI','Deutsch','Sind Sie sicher, dass Sie diesen Inhalt löschen möchten?');
INSERT INTO international VALUES (42,'WebGUI','Deutsch','Bitte bestätigen Sie');
INSERT INTO international VALUES (41,'WebGUI','Deutsch','Sie versuchen einen notwendigen Bestandteil des Systems zu löschen. WebGUI wird nach dieser Aktion möglicherweise nicht mehr richtig funktionieren.');
INSERT INTO international VALUES (44,'WebGUI','Deutsch','Ja, ich bin mir sicher.');
INSERT INTO international VALUES (47,'WebGUI','Deutsch','Startseite');
INSERT INTO international VALUES (46,'WebGUI','Deutsch','Mein Benutzerkonto');
INSERT INTO international VALUES (45,'WebGUI','Deutsch','Nein, ich habe einen Fehler gemacht.');
INSERT INTO international VALUES (48,'WebGUI','Deutsch','Hallo');
INSERT INTO international VALUES (50,'WebGUI','Deutsch','Benutzername');
INSERT INTO international VALUES (49,'WebGUI','Deutsch','Hier können Sie sich <a href=\"^?op=logout\">abmelden</a>.');
INSERT INTO international VALUES (52,'WebGUI','Deutsch','Anmelden');
INSERT INTO international VALUES (51,'WebGUI','Deutsch','Passwort');
INSERT INTO international VALUES (54,'WebGUI','Deutsch','Benutzerkonto anlegen');
INSERT INTO international VALUES (53,'WebGUI','Deutsch','Druckerbares Format');
INSERT INTO international VALUES (56,'WebGUI','Deutsch','Email Adresse');
INSERT INTO international VALUES (55,'WebGUI','Deutsch','Passwort (bestätigen)');
INSERT INTO international VALUES (58,'WebGUI','Deutsch','Ich besitze bereits ein Benutzerkonto.');
INSERT INTO international VALUES (57,'WebGUI','Deutsch','(Dies ist nur notwendig, wenn Sie Eigenschaften benutzen möchten die eine Emailadresse voraussetzen)');
INSERT INTO international VALUES (59,'WebGUI','Deutsch','Ich habe mein Passwort vergessen');
INSERT INTO international VALUES (60,'WebGUI','Deutsch','Sind Sie sicher, dass Sie dieses Benutzerkonto deaktivieren möchten? Wenn Sie fortfahren sind Ihre Konteninformationen endgültig verloren.');
INSERT INTO international VALUES (65,'WebGUI','Deutsch','Benutzerkonto endgültig deaktivieren');
INSERT INTO international VALUES (64,'WebGUI','Deutsch','Abmelden');
INSERT INTO international VALUES (62,'WebGUI','Deutsch','sichern');
INSERT INTO international VALUES (63,'WebGUI','Deutsch','Administrationsmodus einschalten');
INSERT INTO international VALUES (61,'WebGUI','Deutsch','Benutzerkontendetails aktualisieren');
INSERT INTO international VALUES (66,'WebGUI','Deutsch','Anmelden');
INSERT INTO international VALUES (67,'WebGUI','Deutsch','Neues Benutzerkonto einrichten');
INSERT INTO international VALUES (68,'WebGUI','Deutsch','Die Benutzerkontoinformationen die Sie eingegeben haben, sind ungültig.  Entweder existiert das Konto nicht, oder die Kombination aus Benutzername und Passwort  ist falsch.');
INSERT INTO international VALUES (70,'WebGUI','Deutsch','Fehler');
INSERT INTO international VALUES (69,'WebGUI','Deutsch','Bitten Sie Ihren Systemadministrator um Hilfe.');
INSERT INTO international VALUES (74,'WebGUI','Deutsch','Benutzerkonteninformation');
INSERT INTO international VALUES (73,'WebGUI','Deutsch','Anmelden');
INSERT INTO international VALUES (72,'WebGUI','Deutsch','wiederherstellen');
INSERT INTO international VALUES (71,'WebGUI','Deutsch','Passwort wiederherstellen');
INSERT INTO international VALUES (75,'WebGUI','Deutsch','Ihre Benutzerkonteninformation wurde an Ihre Emailadresse geschickt');
INSERT INTO international VALUES (76,'WebGUI','Deutsch','Ihre Emailadresse ist nicht in unserer Datenbank.');
INSERT INTO international VALUES (77,'WebGUI','Deutsch','Ein anderes Mitglied dieser Seiten benutzt bereits diesen Namen. Bitte wählen Sie einen anderen Benutzernamen. Hier sind einige Vorschläge:');
INSERT INTO international VALUES (78,'WebGUI','Deutsch','Die Passworte unterscheiden sich. Bitte versuchen Sie es noch einmal.');
INSERT INTO international VALUES (79,'WebGUI','Deutsch','Verbindung zum LDAP-Server konnte nicht hergestellt werden.');
INSERT INTO international VALUES (80,'WebGUI','Deutsch','Benutzerkonto wurde angelegt');
INSERT INTO international VALUES (83,'WebGUI','Deutsch','Gruppe hinzufügen');
INSERT INTO international VALUES (81,'WebGUI','Deutsch','Benutzerkonto wurde aktualisiert');
INSERT INTO international VALUES (82,'WebGUI','Deutsch','Administrative Funktionen ...');
INSERT INTO international VALUES (84,'WebGUI','Deutsch','Gruppenname');
INSERT INTO international VALUES (85,'WebGUI','Deutsch','Beschreibung');
INSERT INTO international VALUES (87,'WebGUI','Deutsch','Gruppe bearbeiten');
INSERT INTO international VALUES (86,'WebGUI','Deutsch','Sind Sie sicher, dass Sie diese Gruppe löschen möchten? Denken Sie daran, dass diese Gruppe und die zugehörige Rechtesstruktur endgültig gelöscht wird.');
INSERT INTO international VALUES (88,'WebGUI','Deutsch','Benutzer in dieser Gruppe');
INSERT INTO international VALUES (93,'WebGUI','Deutsch','Hilfe');
INSERT INTO international VALUES (92,'WebGUI','Deutsch','Nächste Seite');
INSERT INTO international VALUES (91,'WebGUI','Deutsch','Vorherige Seite');
INSERT INTO international VALUES (90,'WebGUI','Deutsch','Neue Gruppe hinzufügen');
INSERT INTO international VALUES (89,'WebGUI','Deutsch','Gruppen');
INSERT INTO international VALUES (94,'WebGUI','Deutsch','Siehe auch');
INSERT INTO international VALUES (96,'WebGUI','Deutsch','Sortiert nach Aktion');
INSERT INTO international VALUES (95,'WebGUI','Deutsch','Hilfe');
INSERT INTO international VALUES (100,'WebGUI','Deutsch','Meta Tags');
INSERT INTO international VALUES (99,'WebGUI','Deutsch','Titel');
INSERT INTO international VALUES (98,'WebGUI','Deutsch','Seite hinzufügen');
INSERT INTO international VALUES (97,'WebGUI','Deutsch','Sortiert nach Objekt');
INSERT INTO international VALUES (105,'WebGUI','Deutsch','Stil');
INSERT INTO international VALUES (104,'WebGUI','Deutsch','URL der Seite');
INSERT INTO international VALUES (103,'WebGUI','Deutsch','Seitenspezifikation');
INSERT INTO international VALUES (102,'WebGUI','Deutsch','Seite bearbeiten');
INSERT INTO international VALUES (101,'WebGUI','Deutsch','Sind Sie sicher, dass Sie diese Seite und ihren kompletten Inhalt darunter löschen möchten?');
INSERT INTO international VALUES (106,'WebGUI','Deutsch','Stil an alle nachfolgenden Seiten weitergeben.');
INSERT INTO international VALUES (107,'WebGUI','Deutsch','Rechte');
INSERT INTO international VALUES (108,'WebGUI','Deutsch','Besitzer');
INSERT INTO international VALUES (109,'WebGUI','Deutsch','Besitzer kann anschauen?');
INSERT INTO international VALUES (111,'WebGUI','Deutsch','Gruppe');
INSERT INTO international VALUES (110,'WebGUI','Deutsch','Besitzer kann bearbeiten?');
INSERT INTO international VALUES (112,'WebGUI','Deutsch','Gruppe kann anschauen?');
INSERT INTO international VALUES (113,'WebGUI','Deutsch','Gruppe kann bearbeiten?');
INSERT INTO international VALUES (114,'WebGUI','Deutsch','Kann jeder anschauen?');
INSERT INTO international VALUES (115,'WebGUI','Deutsch','Kann jeder bearbeiten?');
INSERT INTO international VALUES (116,'WebGUI','Deutsch','Rechte an alle nachfolgenden Seiten weitergeben.');
INSERT INTO international VALUES (117,'WebGUI','Deutsch','Authentifizierungseinstellungen bearbeiten');
INSERT INTO international VALUES (118,'WebGUI','Deutsch','anonyme Registrierung');
INSERT INTO international VALUES (119,'WebGUI','Deutsch','Authentifizierungsmethode (Standard)');
INSERT INTO international VALUES (120,'WebGUI','Deutsch','LDAP URL (Standard)');
INSERT INTO international VALUES (121,'WebGUI','Deutsch','LDAP Identität (Standard)');
INSERT INTO international VALUES (123,'WebGUI','Deutsch','LDAP Passwort Name');
INSERT INTO international VALUES (122,'WebGUI','Deutsch','LDAP Identitäts-Name');
INSERT INTO international VALUES (124,'WebGUI','Deutsch','Firmeninformationen bearbeiten');
INSERT INTO international VALUES (125,'WebGUI','Deutsch','Firmenname');
INSERT INTO international VALUES (126,'WebGUI','Deutsch','Emailadresse der Firma');
INSERT INTO international VALUES (128,'WebGUI','Deutsch','Dateieinstellungen bearbeiten');
INSERT INTO international VALUES (127,'WebGUI','Deutsch','Webseite der Firma');
INSERT INTO international VALUES (130,'WebGUI','Deutsch','Maximale Dateigröße für Anhänge');
INSERT INTO international VALUES (129,'WebGUI','Deutsch','Pfad zu WebGUI Extras');
INSERT INTO international VALUES (131,'WebGUI','Deutsch','Pfad für Dateianhänge im Web');
INSERT INTO international VALUES (132,'WebGUI','Deutsch','Pfad für Dateianhänge auf dem Server');
INSERT INTO international VALUES (133,'WebGUI','Deutsch','Maileinstellungen bearbeiten');
INSERT INTO international VALUES (134,'WebGUI','Deutsch','Passwortmeldung wiederherstellen');
INSERT INTO international VALUES (136,'WebGUI','Deutsch','Homepage');
INSERT INTO international VALUES (135,'WebGUI','Deutsch','SMTP Server');
INSERT INTO international VALUES (137,'WebGUI','Deutsch','\"Seite wurde nicht gefunden\" Seite');
INSERT INTO international VALUES (140,'WebGUI','Deutsch','Sonstige Einstellungen bearbeiten');
INSERT INTO international VALUES (139,'WebGUI','Deutsch','Nein');
INSERT INTO international VALUES (138,'WebGUI','Deutsch','Ja');
INSERT INTO international VALUES (141,'WebGUI','Deutsch','\"Nicht gefunden Seite\"');
INSERT INTO international VALUES (142,'WebGUI','Deutsch','Sitzungs Zeitüberschreitung');
INSERT INTO international VALUES (143,'WebGUI','Deutsch','Einstellungen verwalten');
INSERT INTO international VALUES (144,'WebGUI','Deutsch','Auswertungen anschauen');
INSERT INTO international VALUES (145,'WebGUI','Deutsch','WebGUI Build Version');
INSERT INTO international VALUES (146,'WebGUI','Deutsch','Aktive Sitzungen');
INSERT INTO international VALUES (147,'WebGUI','Deutsch','sichtbare Seiten');
INSERT INTO international VALUES (150,'WebGUI','Deutsch','Stil hinzufügen');
INSERT INTO international VALUES (149,'WebGUI','Deutsch','Benutzer');
INSERT INTO international VALUES (148,'WebGUI','Deutsch','sichtbare Widgets');
INSERT INTO international VALUES (151,'WebGUI','Deutsch','Stil Name');
INSERT INTO international VALUES (152,'WebGUI','Deutsch','Kopfzeile');
INSERT INTO international VALUES (153,'WebGUI','Deutsch','Fußzeile');
INSERT INTO international VALUES (154,'WebGUI','Deutsch','Style Sheet');
INSERT INTO international VALUES (155,'WebGUI','Deutsch','Sind Sie sicher, dass Sie diesen Stil löschen und alle Seiten die diesen Stil benutzen in den Stil \"Fail Safe\" überführen wollen?');
INSERT INTO international VALUES (157,'WebGUI','Deutsch','Stile');
INSERT INTO international VALUES (156,'WebGUI','Deutsch','Stil bearbeiten');
INSERT INTO international VALUES (158,'WebGUI','Deutsch','Neuen Stil hinzufügen');
INSERT INTO international VALUES (159,'WebGUI','Deutsch','Ausstehende Beiträge');
INSERT INTO international VALUES (161,'WebGUI','Deutsch','Erstellt von');
INSERT INTO international VALUES (160,'WebGUI','Deutsch','Erstellungsdatum');
INSERT INTO international VALUES (162,'WebGUI','Deutsch','Sind Sie sicher, dass Sie alle Seiten und Widgets im Mülleimer löschen möchten?');
INSERT INTO international VALUES (163,'WebGUI','Deutsch','Benutzer hinzufügen');
INSERT INTO international VALUES (164,'WebGUI','Deutsch','Authentifizierungsmethode');
INSERT INTO international VALUES (165,'WebGUI','Deutsch','LDAP URL');
INSERT INTO international VALUES (166,'WebGUI','Deutsch','Connect DN');
INSERT INTO international VALUES (167,'WebGUI','Deutsch','Sind Sie sicher, dass sie diesen Benutzer löschen möchten? Die Benutzerinformation geht damit endgültig verloren!');
INSERT INTO international VALUES (168,'WebGUI','Deutsch','Benutzer bearbeiten');
INSERT INTO international VALUES (169,'WebGUI','Deutsch','Neuen Benutzer hinzufügen');
INSERT INTO international VALUES (172,'WebGUI','Deutsch','Artikel');
INSERT INTO international VALUES (171,'WebGUI','Deutsch','Bearbeiten mit Attributen');
INSERT INTO international VALUES (170,'WebGUI','Deutsch','suchen');
INSERT INTO international VALUES (173,'WebGUI','Deutsch','Artikel hinzufügen');
INSERT INTO international VALUES (174,'WebGUI','Deutsch','Titel anzeigen?');
INSERT INTO international VALUES (178,'WebGUI','Deutsch','Text');
INSERT INTO international VALUES (177,'WebGUI','Deutsch','Ende Datum');
INSERT INTO international VALUES (176,'WebGUI','Deutsch','Start Datum');
INSERT INTO international VALUES (179,'WebGUI','Deutsch','Bild');
INSERT INTO international VALUES (175,'WebGUI','Deutsch','Makros ausführen?');
INSERT INTO international VALUES (182,'WebGUI','Deutsch','Dateianhang');
INSERT INTO international VALUES (181,'WebGUI','Deutsch','Link URL');
INSERT INTO international VALUES (180,'WebGUI','Deutsch','Link Titel');
INSERT INTO international VALUES (183,'WebGUI','Deutsch','Carriage Return beachten?');
INSERT INTO international VALUES (184,'WebGUI','Deutsch','(Bitte anklicken, falls Sie nicht &lt;br&gt; in Ihrem Text hinzufügen.)');
INSERT INTO international VALUES (185,'WebGUI','Deutsch','Artikel bearbeiten');
INSERT INTO international VALUES (186,'WebGUI','Deutsch','Löschen');
INSERT INTO international VALUES (187,'WebGUI','Deutsch','Veranstaltungskalender');
INSERT INTO international VALUES (188,'WebGUI','Deutsch','Veranstaltungskalender hinzufügen');
INSERT INTO international VALUES (189,'WebGUI','Deutsch','Einmaliges Ereignis');
INSERT INTO international VALUES (191,'WebGUI','Deutsch','Woche');
INSERT INTO international VALUES (190,'WebGUI','Deutsch','Tag');
INSERT INTO international VALUES (192,'WebGUI','Deutsch','Termin hinzufügen');
INSERT INTO international VALUES (193,'WebGUI','Deutsch','Wiederholt sich');
INSERT INTO international VALUES (194,'WebGUI','Deutsch','bis');
INSERT INTO international VALUES (195,'WebGUI','Deutsch','Sind Sie sicher, dass Sie diesen Termin');
INSERT INTO international VALUES (196,'WebGUI','Deutsch','<b>und</b> alle seine Wiederholungen löschen wollen?');
INSERT INTO international VALUES (197,'WebGUI','Deutsch','Veranstaltungskalender bearbeiten');
INSERT INTO international VALUES (198,'WebGUI','Deutsch','Veranstaltung bearbeiten');
INSERT INTO international VALUES (199,'WebGUI','Deutsch','Extra Spalte');
INSERT INTO international VALUES (200,'WebGUI','Deutsch','Extra Spalte hinzufügen');
INSERT INTO international VALUES (201,'WebGUI','Deutsch','Platzhalter');
INSERT INTO international VALUES (202,'WebGUI','Deutsch','Breite');
INSERT INTO international VALUES (203,'WebGUI','Deutsch','StyleSheet Class');
INSERT INTO international VALUES (306,'WebGUI','English','Username Binding');
INSERT INTO international VALUES (3,'LinkList','English','Open in new window?');
INSERT INTO international VALUES (307,'WebGUI','English','Use default meta tags?');
INSERT INTO international VALUES (285,'WebGUI','Deutsch','Beitrag hinzufügen');
INSERT INTO international VALUES (286,'WebGUI','Deutsch','(Bitte ausklicken, wenn Ihr Beitrag in HTML geschrieben ist)');
INSERT INTO international VALUES (287,'WebGUI','Deutsch','Erstellungsdatum');
INSERT INTO international VALUES (288,'WebGUI','Deutsch','Status');
INSERT INTO international VALUES (289,'WebGUI','Deutsch','Bearbeiten/Löschen');
INSERT INTO international VALUES (290,'WebGUI','Deutsch','Ohne Titel');
INSERT INTO international VALUES (291,'WebGUI','Deutsch','Sind Sie sicher, dass Sie diesen Beitrag löschen wollen?');
INSERT INTO international VALUES (292,'WebGUI','Deutsch','Benutzer Beitragssystem bearbeiten');
INSERT INTO international VALUES (293,'WebGUI','Deutsch','Beitrag bearbeiten');
INSERT INTO international VALUES (294,'WebGUI','Deutsch','Neuen Beitrag schreiben');
INSERT INTO international VALUES (295,'WebGUI','Deutsch','Erstellungsdatum');
INSERT INTO international VALUES (296,'WebGUI','Deutsch','Erstellt von');
INSERT INTO international VALUES (297,'WebGUI','Deutsch','Erstellt von:');
INSERT INTO international VALUES (298,'WebGUI','Deutsch','Erstellungsdatum:');
INSERT INTO international VALUES (299,'WebGUI','Deutsch','Erlauben');
INSERT INTO international VALUES (300,'WebGUI','Deutsch','Ausstehend verlassen');
INSERT INTO international VALUES (301,'WebGUI','Deutsch','Verbieten');
INSERT INTO international VALUES (302,'WebGUI','Deutsch','Bearbeiten');
INSERT INTO international VALUES (303,'WebGUI','Deutsch','Zurück zur Beitragsliste');
INSERT INTO international VALUES (304,'WebGUI','Deutsch','Sprache');
INSERT INTO international VALUES (306,'WebGUI','Deutsch','Benutze LDAP Benutzername');
INSERT INTO international VALUES (307,'WebGUI','Deutsch','Standard Meta Tags benutzen?');
INSERT INTO international VALUES (1,'LinkList','English','Indent');
INSERT INTO international VALUES (2,'LinkList','English','Line Spacing');
INSERT INTO international VALUES (4,'LinkList','English','Bullet');
INSERT INTO international VALUES (2,'LinkList','Deutsch','Zeilenabstand');
INSERT INTO international VALUES (4,'LinkList','Deutsch','Kugel');
INSERT INTO international VALUES (3,'LinkList','Deutsch','In neuem Fenster öffnen?');
INSERT INTO international VALUES (1,'LinkList','Deutsch','Tabulator');
INSERT INTO international VALUES (308,'WebGUI','English','Edit Profile Settings');
INSERT INTO international VALUES (309,'WebGUI','English','Allow real name?');
INSERT INTO international VALUES (310,'WebGUI','English','Allow extra contact information?');
INSERT INTO international VALUES (311,'WebGUI','English','Allow home information?');
INSERT INTO international VALUES (312,'WebGUI','English','Allow business information?');
INSERT INTO international VALUES (313,'WebGUI','English','Allow miscellaneous information?');
INSERT INTO international VALUES (314,'WebGUI','English','First Name');
INSERT INTO international VALUES (315,'WebGUI','English','Middle Name');
INSERT INTO international VALUES (316,'WebGUI','English','Last Name');
INSERT INTO international VALUES (317,'WebGUI','English','<a href=\"http://www.icq.com\">ICQ</a> UIN');
INSERT INTO international VALUES (318,'WebGUI','English','<a href=\"http://www.aol.com/aim/homenew.adp\">AIM</a> Id');
INSERT INTO international VALUES (319,'WebGUI','English','<a href=\"http://messenger.msn.com/\">MSN Messenger</a> Id');
INSERT INTO international VALUES (320,'WebGUI','English','<a href=\"http://messenger.yahoo.com/\">Yahoo! Messenger</a> Id');
INSERT INTO international VALUES (321,'WebGUI','English','Cell Phone');
INSERT INTO international VALUES (322,'WebGUI','English','Pager');
INSERT INTO international VALUES (323,'WebGUI','English','Home Address');
INSERT INTO international VALUES (324,'WebGUI','English','Home City');
INSERT INTO international VALUES (325,'WebGUI','English','Home State');
INSERT INTO international VALUES (326,'WebGUI','English','Home Zip Code');
INSERT INTO international VALUES (327,'WebGUI','English','Home Country');
INSERT INTO international VALUES (328,'WebGUI','English','Home Phone');
INSERT INTO international VALUES (329,'WebGUI','English','Work Address');
INSERT INTO international VALUES (330,'WebGUI','English','Work City');
INSERT INTO international VALUES (331,'WebGUI','English','Work State');
INSERT INTO international VALUES (332,'WebGUI','English','Work Zip Code');
INSERT INTO international VALUES (333,'WebGUI','English','Work Country');
INSERT INTO international VALUES (334,'WebGUI','English','Work Phone');
INSERT INTO international VALUES (335,'WebGUI','English','Gender');
INSERT INTO international VALUES (336,'WebGUI','English','Birth Date');
INSERT INTO international VALUES (337,'WebGUI','English','Homepage URL');
INSERT INTO international VALUES (338,'WebGUI','English','Edit Profile');
INSERT INTO international VALUES (339,'WebGUI','English','Male');
INSERT INTO international VALUES (340,'WebGUI','English','Female');
INSERT INTO international VALUES (341,'WebGUI','English','Edit profile.');
INSERT INTO international VALUES (342,'WebGUI','English','Edit account information.');
INSERT INTO international VALUES (343,'WebGUI','English','View profile.');
INSERT INTO international VALUES (344,'WebGUI','English','View message log.');
INSERT INTO international VALUES (345,'WebGUI','English','Not A Member');
INSERT INTO international VALUES (346,'WebGUI','English','This user is no longer a member of our site. We have no further information about this user.');
INSERT INTO international VALUES (347,'WebGUI','English','View Profile For');
INSERT INTO international VALUES (348,'WebGUI','English','Name');
INSERT INTO international VALUES (308,'WebGUI','Deutsch','Profil bearbeiten');
INSERT INTO international VALUES (309,'WebGUI','Deutsch','Name anzeigen?');
INSERT INTO international VALUES (310,'WebGUI','Deutsch','Kontaktinformationen anzeigen?');
INSERT INTO international VALUES (311,'WebGUI','Deutsch','Privatadresse anzeigen?');
INSERT INTO international VALUES (312,'WebGUI','Deutsch','Geschäftsadresse anzeigen?');
INSERT INTO international VALUES (313,'WebGUI','Deutsch','Zusätzliche Informationen anzeigen?');
INSERT INTO international VALUES (314,'WebGUI','Deutsch','Vorname');
INSERT INTO international VALUES (315,'WebGUI','Deutsch','Zweiter Vorname');
INSERT INTO international VALUES (316,'WebGUI','Deutsch','Nachname');
INSERT INTO international VALUES (317,'WebGUI','Deutsch','<a href=\"\"http://www.icq.com\"\">ICQ</a> UIN');
INSERT INTO international VALUES (318,'WebGUI','Deutsch','<a href=\"\"http://www.aol.com/aim/homenew.adp\"\">AIM</a> Id');
INSERT INTO international VALUES (319,'WebGUI','Deutsch','<a href=\"\"http://messenger.msn.com/\"\">MSN Messenger</a> Id');
INSERT INTO international VALUES (320,'WebGUI','Deutsch','<a href=\"\"http://messenger.yahoo.com/\"\">Yahoo! Messenger</a> Id');
INSERT INTO international VALUES (321,'WebGUI','Deutsch','Mobiltelefon');
INSERT INTO international VALUES (322,'WebGUI','Deutsch','Pager');
INSERT INTO international VALUES (323,'WebGUI','Deutsch','Strasse (privat)');
INSERT INTO international VALUES (324,'WebGUI','Deutsch','Ort (privat)');
INSERT INTO international VALUES (325,'WebGUI','Deutsch','Bundesland (privat)');
INSERT INTO international VALUES (326,'WebGUI','Deutsch','Postleitzahl (privat)');
INSERT INTO international VALUES (327,'WebGUI','Deutsch','Land (privat)');
INSERT INTO international VALUES (328,'WebGUI','Deutsch','Telefon (privat)');
INSERT INTO international VALUES (329,'WebGUI','Deutsch','Strasse (Büro)');
INSERT INTO international VALUES (330,'WebGUI','Deutsch','Ort (Büro)');
INSERT INTO international VALUES (331,'WebGUI','Deutsch','Bundesland (Büro)');
INSERT INTO international VALUES (332,'WebGUI','Deutsch','Postleitzahl (Büro)');
INSERT INTO international VALUES (333,'WebGUI','Deutsch','Land (Büro)');
INSERT INTO international VALUES (334,'WebGUI','Deutsch','Telefon (Büro)');
INSERT INTO international VALUES (335,'WebGUI','Deutsch','Geschlecht');
INSERT INTO international VALUES (336,'WebGUI','Deutsch','Geburtstag');
INSERT INTO international VALUES (337,'WebGUI','Deutsch','Homepage URL');
INSERT INTO international VALUES (338,'WebGUI','Deutsch','Profil bearbeiten');
INSERT INTO international VALUES (339,'WebGUI','Deutsch','männlich');
INSERT INTO international VALUES (340,'WebGUI','Deutsch','weiblich');
INSERT INTO international VALUES (341,'WebGUI','Deutsch','Profil bearbeiten.');
INSERT INTO international VALUES (342,'WebGUI','Deutsch','Benutzerkonto bearbeiten.');
INSERT INTO international VALUES (343,'WebGUI','Deutsch','Profil anschauen.');
INSERT INTO international VALUES (345,'WebGUI','Deutsch','Kein Mitglied');
INSERT INTO international VALUES (346,'WebGUI','Deutsch','Dieser Benutzer ist kein Mitglied. Wir haben keine weiteren Informationen über ihn.');
INSERT INTO international VALUES (347,'WebGUI','Deutsch','Profil anschauen von');
INSERT INTO international VALUES (349,'WebGUI','English','Latest version available');
INSERT INTO international VALUES (259,'WebGUI','Español','Reporte SQL');
INSERT INTO international VALUES (258,'WebGUI','Español','Editar Encuesta');
INSERT INTO international VALUES (257,'WebGUI','Español','(Ingrese una por línea. No más de 20)');
INSERT INTO international VALUES (255,'WebGUI','Español','Pregunta');
INSERT INTO international VALUES (256,'WebGUI','Español','Respuestas');
INSERT INTO international VALUES (254,'WebGUI','Español','Ancho del gráfico');
INSERT INTO international VALUES (253,'WebGUI','Español','Quiénes pueden votar?');
INSERT INTO international VALUES (251,'WebGUI','Español','Agregar Encuesta');
INSERT INTO international VALUES (252,'WebGUI','Español','Activar');
INSERT INTO international VALUES (250,'WebGUI','Español','Encuesta');
INSERT INTO international VALUES (249,'WebGUI','Español','Última respuesta');
INSERT INTO international VALUES (247,'WebGUI','Español','Inicio');
INSERT INTO international VALUES (248,'WebGUI','Español','Respuestas');
INSERT INTO international VALUES (246,'WebGUI','Español','Mandar Nuevo Mensage');
INSERT INTO international VALUES (244,'WebGUI','Español','Autor');
INSERT INTO international VALUES (245,'WebGUI','Español','Fecha');
INSERT INTO international VALUES (243,'WebGUI','Español','Siguiente');
INSERT INTO international VALUES (241,'WebGUI','Español','Anterior');
INSERT INTO international VALUES (242,'WebGUI','Español','Volver a la Lista de Mensages');
INSERT INTO international VALUES (239,'WebGUI','Español','Fecha:');
INSERT INTO international VALUES (240,'WebGUI','Español','ID del mensage:');
INSERT INTO international VALUES (237,'WebGUI','Español','Asunto:');
INSERT INTO international VALUES (238,'WebGUI','Español','Autor:');
INSERT INTO international VALUES (235,'WebGUI','Español','Editar mensage');
INSERT INTO international VALUES (236,'WebGUI','Español','Responder');
INSERT INTO international VALUES (234,'WebGUI','Español','Respondiendo...');
INSERT INTO international VALUES (232,'WebGUI','Español','sin título');
INSERT INTO international VALUES (233,'WebGUI','Español','(eom)');
INSERT INTO international VALUES (231,'WebGUI','Español','Mandando Nuevo Mensage ...');
INSERT INTO international VALUES (229,'WebGUI','Español','Asunto');
INSERT INTO international VALUES (230,'WebGUI','Español','Mensage');
INSERT INTO international VALUES (228,'WebGUI','Español','Editar Mensage...');
INSERT INTO international VALUES (227,'WebGUI','Español','Editar Tabla de Mensages');
INSERT INTO international VALUES (226,'WebGUI','Español','Timeout de edición');
INSERT INTO international VALUES (225,'WebGUI','Español','Mensages por página');
INSERT INTO international VALUES (224,'WebGUI','Español','Quienes pueden mandar?');
INSERT INTO international VALUES (223,'WebGUI','Español','Table de Mensages');
INSERT INTO international VALUES (222,'WebGUI','Español','Agregar Tabla de Mensages');
INSERT INTO international VALUES (221,'WebGUI','Español','Agregar nuevo Enlace');
INSERT INTO international VALUES (220,'WebGUI','Español','Editar Enlace');
INSERT INTO international VALUES (218,'WebGUI','Español','Editar Lista de Enlaces');
INSERT INTO international VALUES (219,'WebGUI','Español','Agregar Lista de Enlaces');
INSERT INTO international VALUES (217,'WebGUI','Español','Está seguro de querer eliminar éste enlace?');
INSERT INTO international VALUES (216,'WebGUI','Español','URL');
INSERT INTO international VALUES (215,'WebGUI','Español','Agregar Enlace');
INSERT INTO international VALUES (214,'WebGUI','Español','Lista de Enlaces');
INSERT INTO international VALUES (213,'WebGUI','Español','Editar Pregunta');
INSERT INTO international VALUES (212,'WebGUI','Español','Agregar nueva pregunta.');
INSERT INTO international VALUES (211,'WebGUI','Español','Editar F.A.Q.');
INSERT INTO international VALUES (209,'WebGUI','Español','Respuesta');
INSERT INTO international VALUES (210,'WebGUI','Español','Está seguro de querer eliminar ésta pregunta?');
INSERT INTO international VALUES (208,'WebGUI','Español','Pregunta');
INSERT INTO international VALUES (207,'WebGUI','Español','Agregar Pregunta');
INSERT INTO international VALUES (206,'WebGUI','Español','Agregar F.A.Q.');
INSERT INTO international VALUES (205,'WebGUI','Español','F.A.Q.');
INSERT INTO international VALUES (204,'WebGUI','Español','Editar Columna Extra');
INSERT INTO international VALUES (203,'WebGUI','Español','Clase StyleSheet');
INSERT INTO international VALUES (202,'WebGUI','Español','Ancho');
INSERT INTO international VALUES (201,'WebGUI','Español','Espaciador');
INSERT INTO international VALUES (200,'WebGUI','Español','Agregar Columna Extra');
INSERT INTO international VALUES (199,'WebGUI','Español','Columna Extra');
INSERT INTO international VALUES (198,'WebGUI','Español','Editar Evento');
INSERT INTO international VALUES (197,'WebGUI','Español','Editar Calendario de Eventos');
INSERT INTO international VALUES (196,'WebGUI','Español','<b>y</b> todos las recurrencias del mismo');
INSERT INTO international VALUES (195,'WebGUI','Español','Está segugo de querer eliminar éste evento');
INSERT INTO international VALUES (194,'WebGUI','Español','hasta');
INSERT INTO international VALUES (193,'WebGUI','Español','Se repite cada');
INSERT INTO international VALUES (192,'WebGUI','Español','Agregar Evento');
INSERT INTO international VALUES (191,'WebGUI','Español','Semana');
INSERT INTO international VALUES (187,'WebGUI','Español','Calendario de Eventos');
INSERT INTO international VALUES (188,'WebGUI','Español','Agregar Calendario de Eventos');
INSERT INTO international VALUES (189,'WebGUI','Español','Sucede solo una vez.');
INSERT INTO international VALUES (190,'WebGUI','Español','Día');
INSERT INTO international VALUES (186,'WebGUI','Español','Eliminar');
INSERT INTO international VALUES (185,'WebGUI','Español','Editar Artículo');
INSERT INTO international VALUES (184,'WebGUI','Español','(marque si no está agregando &lt;br&gt; manualmente.)');
INSERT INTO international VALUES (183,'WebGUI','Español','Convertir saltos de carro?');
INSERT INTO international VALUES (181,'WebGUI','Español','Link URL');
INSERT INTO international VALUES (182,'WebGUI','Español','Adjuntar');
INSERT INTO international VALUES (179,'WebGUI','Español','Imagen');
INSERT INTO international VALUES (180,'WebGUI','Español','Link Título');
INSERT INTO international VALUES (178,'WebGUI','Español','Cuerpo');
INSERT INTO international VALUES (173,'WebGUI','Español','Agregar Artículo');
INSERT INTO international VALUES (174,'WebGUI','Español','Mostrar el título?');
INSERT INTO international VALUES (175,'WebGUI','Español','Procesar macros?');
INSERT INTO international VALUES (176,'WebGUI','Español','Fecha Inicio');
INSERT INTO international VALUES (177,'WebGUI','Español','Fecha finalización');
INSERT INTO international VALUES (171,'WebGUI','Español','rich edit');
INSERT INTO international VALUES (172,'WebGUI','Español','Artículo');
INSERT INTO international VALUES (170,'WebGUI','Español','buscar');
INSERT INTO international VALUES (169,'WebGUI','Español','Agregar nuevo usuario');
INSERT INTO international VALUES (168,'WebGUI','Español','Editar Usuario');
INSERT INTO international VALUES (166,'WebGUI','Español','Connect DN');
INSERT INTO international VALUES (167,'WebGUI','Español','Está seguro de querer eliminar éste usuario? Tenga en cuenta que toda la información del usuario será eliminada permanentemente si procede.');
INSERT INTO international VALUES (164,'WebGUI','Español','Método de Auntentificación');
INSERT INTO international VALUES (165,'WebGUI','Español','LDAP URL');
INSERT INTO international VALUES (163,'WebGUI','Español','Agregar usuario');
INSERT INTO international VALUES (162,'WebGUI','Español','Está seguro de querer eliminar todos los elementos de la papelera?');
INSERT INTO international VALUES (161,'WebGUI','Español','Contribuido por');
INSERT INTO international VALUES (160,'WebGUI','Español','Fecha Contribución');
INSERT INTO international VALUES (159,'WebGUI','Español','Contribuciones Pendientes');
INSERT INTO international VALUES (156,'WebGUI','Español','Editar Estilo');
INSERT INTO international VALUES (157,'WebGUI','Español','Estilos');
INSERT INTO international VALUES (158,'WebGUI','Español','Agregar nuevo Estilo');
INSERT INTO international VALUES (155,'WebGUI','Español','\"Está seguro de querer eliminar éste estilo y migrar todas la páginas que lo usen al estilo \"\"Fail Safe\"\"?\"');
INSERT INTO international VALUES (152,'WebGUI','Español','Encabezado');
INSERT INTO international VALUES (153,'WebGUI','Español','Pie');
INSERT INTO international VALUES (154,'WebGUI','Español','Hoja de Estilo');
INSERT INTO international VALUES (151,'WebGUI','Español','Nombre del Estilo');
INSERT INTO international VALUES (150,'WebGUI','Español','Agregar Estilo');
INSERT INTO international VALUES (149,'WebGUI','Español','Usuarios');
INSERT INTO international VALUES (148,'WebGUI','Español','Widgets Visibles');
INSERT INTO international VALUES (147,'WebGUI','Español','Páginas Visibles');
INSERT INTO international VALUES (146,'WebGUI','Español','Sesiones activas');
INSERT INTO international VALUES (145,'WebGUI','Español','Versión de WebGUI');
INSERT INTO international VALUES (144,'WebGUI','Español','Ver estadísticas');
INSERT INTO international VALUES (143,'WebGUI','Español','Configurar Opciones');
INSERT INTO international VALUES (142,'WebGUI','Español','Timeout de sesión');
INSERT INTO international VALUES (141,'WebGUI','Español','Página no encontrada');
INSERT INTO international VALUES (139,'WebGUI','Español','No');
INSERT INTO international VALUES (140,'WebGUI','Español','Editar configuraciones misceláneas');
INSERT INTO international VALUES (138,'WebGUI','Español','Si');
INSERT INTO international VALUES (135,'WebGUI','Español','Servidor SMTP');
INSERT INTO international VALUES (136,'WebGUI','Español','Página de Inicio');
INSERT INTO international VALUES (137,'WebGUI','Español','Página: Página No Encontrada');
INSERT INTO international VALUES (133,'WebGUI','Español','Editar configuración de e-mail');
INSERT INTO international VALUES (134,'WebGUI','Español','Mensage de Recuperar Password');
INSERT INTO international VALUES (129,'WebGUI','Español','Camino a Extras de WebGUI');
INSERT INTO international VALUES (130,'WebGUI','Español','Tamaño máximo de adjuntos');
INSERT INTO international VALUES (131,'WebGUI','Español','Camino Web de los archivos adjuntos');
INSERT INTO international VALUES (132,'WebGUI','Español','Camino en server de los archivos adjuntos');
INSERT INTO international VALUES (128,'WebGUI','Español','Editar Opciones de Archivos');
INSERT INTO international VALUES (124,'WebGUI','Español','Editar Información de la Companía');
INSERT INTO international VALUES (125,'WebGUI','Español','Nombre de la Companía');
INSERT INTO international VALUES (126,'WebGUI','Español','E-mail de la Companía');
INSERT INTO international VALUES (127,'WebGUI','Español','URL de la Companía');
INSERT INTO international VALUES (123,'WebGUI','Español','Password LDAP');
INSERT INTO international VALUES (122,'WebGUI','Español','Nombre Identidad LDAP');
INSERT INTO international VALUES (121,'WebGUI','Español','Identidad LDAP (por defecto)');
INSERT INTO international VALUES (120,'WebGUI','Español','URL LDAP (por defecto)');
INSERT INTO international VALUES (119,'WebGUI','Español','Método de Autentificación (por defecto)');
INSERT INTO international VALUES (118,'WebGUI','Español','Registración Anónima');
INSERT INTO international VALUES (117,'WebGUI','Español','Editar Opciones de Auntentificación');
INSERT INTO international VALUES (116,'WebGUI','Español','Marque para dar éstos privilegios a todas las sub-páginas.');
INSERT INTO international VALUES (115,'WebGUI','Español','Cualquiera puede editar?');
INSERT INTO international VALUES (114,'WebGUI','Español','Cualquiera puede ver?');
INSERT INTO international VALUES (113,'WebGUI','Español','Grupo puede editar?');
INSERT INTO international VALUES (112,'WebGUI','Español','Grupo puede ver?');
INSERT INTO international VALUES (111,'WebGUI','Español','Grupo');
INSERT INTO international VALUES (110,'WebGUI','Español','Dueño puede editar?');
INSERT INTO international VALUES (109,'WebGUI','Español','Dueño puede ver?');
INSERT INTO international VALUES (108,'WebGUI','Español','Dueño');
INSERT INTO international VALUES (107,'WebGUI','Español','Privilegios');
INSERT INTO international VALUES (106,'WebGUI','Español','Marque para dar éste estilo a todas las sub-páginas.');
INSERT INTO international VALUES (105,'WebGUI','Español','Estilo');
INSERT INTO international VALUES (104,'WebGUI','Español','URL de la página');
INSERT INTO international VALUES (103,'WebGUI','Español','Propio de la página');
INSERT INTO international VALUES (102,'WebGUI','Español','Editar Página');
INSERT INTO international VALUES (101,'WebGUI','Español','Está seguro de querer eliminar ésta página');
INSERT INTO international VALUES (100,'WebGUI','Español','Meta Tags');
INSERT INTO international VALUES (98,'WebGUI','Español','Agregar Página');
INSERT INTO international VALUES (99,'WebGUI','Español','Título');
INSERT INTO international VALUES (97,'WebGUI','Español','Ordenar por Objeto');
INSERT INTO international VALUES (96,'WebGUI','Español','Ordenar por Acción');
INSERT INTO international VALUES (94,'WebGUI','Español','Vea también');
INSERT INTO international VALUES (95,'WebGUI','Español','Índice de Ayuda');
INSERT INTO international VALUES (93,'WebGUI','Español','Ayuda');
INSERT INTO international VALUES (92,'WebGUI','Español','Siguiente página');
INSERT INTO international VALUES (91,'WebGUI','Español','Página previa');
INSERT INTO international VALUES (90,'WebGUI','Español','Agregar nuevo grupo');
INSERT INTO international VALUES (89,'WebGUI','Español','Grupos');
INSERT INTO international VALUES (88,'WebGUI','Español','Usuarios en Grupo');
INSERT INTO international VALUES (87,'WebGUI','Español','Editar Grupo');
INSERT INTO international VALUES (86,'WebGUI','Español','Está segugo de querer eliminar éste grupo? Tenga en cuenta que la eliminación es permanente y removerá todos los privilegios asociados con el grupo.');
INSERT INTO international VALUES (85,'WebGUI','Español','Descripción');
INSERT INTO international VALUES (84,'WebGUI','Español','Nombre del Grupo');
INSERT INTO international VALUES (83,'WebGUI','Español','Agregar Grupo');
INSERT INTO international VALUES (82,'WebGUI','Español','Funciones Administrativas...');
INSERT INTO international VALUES (81,'WebGUI','Español','La cuenta se actualizó con éxito!');
INSERT INTO international VALUES (80,'WebGUI','Español','La cuenta se ha creado con éxito!');
INSERT INTO international VALUES (78,'WebGUI','Español','Su password no concuerda. Trate de nuevo.');
INSERT INTO international VALUES (79,'WebGUI','Español','No se puede conectar con el servidor LDAP');
INSERT INTO international VALUES (77,'WebGUI','Español','El nombre de cuenta ya está en uso por otro miembro. Por favor trate con otro nombre de usuario.  Los siguiente son algunas sugerencias:');
INSERT INTO international VALUES (76,'WebGUI','Español','El e-mail no está en nuestra base de datos');
INSERT INTO international VALUES (75,'WebGUI','Español','La información de su cuenta ha sido enviada a su e-mail-');
INSERT INTO international VALUES (74,'WebGUI','Español','Información de la Cuenta');
INSERT INTO international VALUES (73,'WebGUI','Español','Ingresar.');
INSERT INTO international VALUES (72,'WebGUI','Español','recuperar');
INSERT INTO international VALUES (71,'WebGUI','Español','Recuperar password');
INSERT INTO international VALUES (70,'WebGUI','Español','Error');
INSERT INTO international VALUES (69,'WebGUI','Español','Por favor contacte a su administrador por asistencia.');
INSERT INTO international VALUES (68,'WebGUI','Español','La información de su cuenta no es válida. O la cuenta no existe');
INSERT INTO international VALUES (67,'WebGUI','Español','Crear nueva Cuenta');
INSERT INTO international VALUES (66,'WebGUI','Español','Ingresar');
INSERT INTO international VALUES (65,'WebGUI','Español','Por favor desactive mi cuenta permanentemente');
INSERT INTO international VALUES (64,'WebGUI','Español','Salir');
INSERT INTO international VALUES (63,'WebGUI','Español','Encender Admin');
INSERT INTO international VALUES (62,'WebGUI','Español','guardar');
INSERT INTO international VALUES (61,'WebGUI','Español','Actualizar información de la Cuenta');
INSERT INTO international VALUES (60,'WebGUI','Español','Está seguro que quiere desactivar su cuenta. Si continúa su información se perderá permanentemente.');
INSERT INTO international VALUES (59,'WebGUI','Español','Perdí mi password');
INSERT INTO international VALUES (58,'WebGUI','Español','Ya tengo una cuenta!');
INSERT INTO international VALUES (57,'WebGUI','Español','Solo es necesaria si desea usar opciones que requieren e-mail.');
INSERT INTO international VALUES (56,'WebGUI','Español','Dirección de e-mail');
INSERT INTO international VALUES (55,'WebGUI','Español','Password (confirmar)');
INSERT INTO international VALUES (54,'WebGUI','Español','Crear Cuenta');
INSERT INTO international VALUES (53,'WebGUI','Español','Hacer página imprimible');
INSERT INTO international VALUES (52,'WebGUI','Español','ingresar');
INSERT INTO international VALUES (51,'WebGUI','Español','Password');
INSERT INTO international VALUES (50,'WebGUI','Español','Nombre usuario');
INSERT INTO international VALUES (49,'WebGUI','Español','\"Click <a href=\"\"^\\?op=logout\"\">aquí</a> para salir.\"');
INSERT INTO international VALUES (48,'WebGUI','Español','Hola');
INSERT INTO international VALUES (47,'WebGUI','Español','Home');
INSERT INTO international VALUES (46,'WebGUI','Español','Mi Cuenta');
INSERT INTO international VALUES (45,'WebGUI','Español','No');
INSERT INTO international VALUES (44,'WebGUI','Español','Si');
INSERT INTO international VALUES (43,'WebGUI','Español','Está seguro de querer eliminar éste contenido?');
INSERT INTO international VALUES (42,'WebGUI','Español','Por favor confirme');
INSERT INTO international VALUES (41,'WebGUI','Español','Esta intentando eliminar un componente vital del sistema WebGUI. Si continúa puede causar un mal funcionamiento de WebGUI.');
INSERT INTO international VALUES (40,'WebGUI','Español','Componente Vital');
INSERT INTO international VALUES (39,'WebGUI','Español','No tiene suficientes privilegios para ingresar a ésta página.');
INSERT INTO international VALUES (38,'WebGUI','Español','\"No tiene privilegios suficientes para realizar ésta operación. Por favor <a href=\"\"^\\?op=displayLogin\"\">ingrese con una cuenta</a> que posea los privilegios suficientes antes de intentar ésta operación.\"');
INSERT INTO international VALUES (37,'WebGUI','Español','Permiso Denegado!');
INSERT INTO international VALUES (36,'WebGUI','Español','Debe ser administrador para realizar esta tarea. Por favor contacte a uno de los administradores. La siguiente es una lista de los administradores de éste sistema:');
INSERT INTO international VALUES (35,'WebGUI','Español','Funciones Administrativas');
INSERT INTO international VALUES (34,'WebGUI','Español','fijar fecha');
INSERT INTO international VALUES (33,'WebGUI','Español','Sabado');
INSERT INTO international VALUES (32,'WebGUI','Español','Viernes');
INSERT INTO international VALUES (31,'WebGUI','Español','Jueves');
INSERT INTO international VALUES (30,'WebGUI','Español','Miércoles');
INSERT INTO international VALUES (29,'WebGUI','Español','Martes');
INSERT INTO international VALUES (28,'WebGUI','Español','Lunes');
INSERT INTO international VALUES (26,'WebGUI','Español','Diciembre');
INSERT INTO international VALUES (27,'WebGUI','Español','Domingo');
INSERT INTO international VALUES (24,'WebGUI','Español','Octubre');
INSERT INTO international VALUES (25,'WebGUI','Español','Noviembre');
INSERT INTO international VALUES (23,'WebGUI','Español','Septiembre');
INSERT INTO international VALUES (22,'WebGUI','Español','Agosto');
INSERT INTO international VALUES (21,'WebGUI','Español','Julio');
INSERT INTO international VALUES (20,'WebGUI','Español','Junio');
INSERT INTO international VALUES (19,'WebGUI','Español','Mayo');
INSERT INTO international VALUES (18,'WebGUI','Español','Abril');
INSERT INTO international VALUES (17,'WebGUI','Español','Marzo');
INSERT INTO international VALUES (16,'WebGUI','Español','Febrero');
INSERT INTO international VALUES (15,'WebGUI','Español','Enero');
INSERT INTO international VALUES (14,'WebGUI','Español','Ver contribuciones pendientes.');
INSERT INTO international VALUES (13,'WebGUI','Español','Ver índice de Ayuda');
INSERT INTO international VALUES (12,'WebGUI','Español','Apagar Admin');
INSERT INTO international VALUES (11,'WebGUI','Español','Vaciar Papelera');
INSERT INTO international VALUES (10,'WebGUI','Español','Ver Papelera');
INSERT INTO international VALUES (9,'WebGUI','Español','Ver Portapapeles');
INSERT INTO international VALUES (8,'WebGUI','Español','Ver Página No Encontrada');
INSERT INTO international VALUES (7,'WebGUI','Español','Configurar Usuarios');
INSERT INTO international VALUES (6,'WebGUI','Español','Configurar Estilos');
INSERT INTO international VALUES (5,'WebGUI','Español','Configurar Grupos.');
INSERT INTO international VALUES (4,'WebGUI','Español','Configurar Opciones.');
INSERT INTO international VALUES (3,'WebGUI','Español','Pegar desde el Portapapeles...');
INSERT INTO international VALUES (2,'WebGUI','Español','Página');
INSERT INTO international VALUES (1,'WebGUI','Español','Agregar Contenido ...');
INSERT INTO international VALUES (260,'WebGUI','Español','Agregar Reporte SQL');
INSERT INTO international VALUES (261,'WebGUI','Español','Modelo');
INSERT INTO international VALUES (262,'WebGUI','Español','Consulta');
INSERT INTO international VALUES (263,'WebGUI','Español','DSN');
INSERT INTO international VALUES (264,'WebGUI','Español','Usuario de la Base de Datos');
INSERT INTO international VALUES (265,'WebGUI','Español','Password de la Base de Datos');
INSERT INTO international VALUES (266,'WebGUI','Español','Editar Reporte SQL');
INSERT INTO international VALUES (267,'WebGUI','Español','Error: El DSN especificado está en un formato incorrecto.');
INSERT INTO international VALUES (268,'WebGUI','Español','Error: El SQL especificado está en un formato incorrecto.');
INSERT INTO international VALUES (269,'WebGUI','Español','Error: Hay un problema con la consulta.');
INSERT INTO international VALUES (270,'WebGUI','Español','Error: No se puede conectar a la base de datos.');
INSERT INTO international VALUES (277,'WebGUI','Español','Sistema de Contribución de Usuarios');
INSERT INTO international VALUES (278,'WebGUI','Español','Agregar Sistema de Contribución de Usuarios');
INSERT INTO international VALUES (279,'WebGUI','Español','Quiénes pueden contribuir?');
INSERT INTO international VALUES (280,'WebGUI','Español','Contribuciones por página');
INSERT INTO international VALUES (281,'WebGUI','Español','Aprobado');
INSERT INTO international VALUES (282,'WebGUI','Español','Denegado');
INSERT INTO international VALUES (283,'WebGUI','Español','Pendiente');
INSERT INTO international VALUES (284,'WebGUI','Español','Estado por defecto');
INSERT INTO international VALUES (285,'WebGUI','Español','Contribuir');
INSERT INTO international VALUES (286,'WebGUI','Español','(desmarque si está escribiendo la contribución en HTML.)');
INSERT INTO international VALUES (287,'WebGUI','Español','Fecha Contribución');
INSERT INTO international VALUES (288,'WebGUI','Español','Estado');
INSERT INTO international VALUES (289,'WebGUI','Español','Editar/Eliminar');
INSERT INTO international VALUES (290,'WebGUI','Español','Sin título');
INSERT INTO international VALUES (291,'WebGUI','Español','Está seguro de querer eliminar ésta contribución?');
INSERT INTO international VALUES (292,'WebGUI','Español','Editar Sistema de Contribución de Usuarios');
INSERT INTO international VALUES (293,'WebGUI','Español','Editar Contribución');
INSERT INTO international VALUES (294,'WebGUI','Español','Nueva Contribución');
INSERT INTO international VALUES (295,'WebGUI','Español','Fecha Contribución');
INSERT INTO international VALUES (296,'WebGUI','Español','Contribuida por');
INSERT INTO international VALUES (297,'WebGUI','Español','Contribuida por:');
INSERT INTO international VALUES (298,'WebGUI','Español','Fecha Contribución:');
INSERT INTO international VALUES (299,'WebGUI','Español','Aprobar');
INSERT INTO international VALUES (300,'WebGUI','Español','Dejan pendiente');
INSERT INTO international VALUES (301,'WebGUI','Español','Denegar');
INSERT INTO international VALUES (302,'WebGUI','Español','Editar');
INSERT INTO international VALUES (303,'WebGUI','Español','Regresar a lista de contribuciones');
INSERT INTO international VALUES (304,'WebGUI','Español','Idioma');
INSERT INTO international VALUES (1,'FAQ','English','Proceed to add question?');
INSERT INTO international VALUES (5,'LinkList','English','Proceed to add link?');
INSERT INTO international VALUES (1,'EventsCalendar','English','Proceed to add event?');

#
# Table structure for table 'message'
#

CREATE TABLE message (
  messageId int(11) NOT NULL default '0',
  rid int(11) default NULL,
  widgetId int(11) default NULL,
  pid int(11) default NULL,
  userId int(11) default NULL,
  username varchar(30) default NULL,
  subject varchar(255) default NULL,
  message text,
  dateOfPost int(11) default NULL,
  PRIMARY KEY  (messageId)
) TYPE=MyISAM;

#
# Dumping data for table 'message'
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
  PRIMARY KEY  (pageId)
) TYPE=MyISAM;

#
# Dumping data for table 'page'
#

INSERT INTO page VALUES (1,0,'Home',3,3,1,1,1,1,0,1,0,1,'','home',1);
INSERT INTO page VALUES (6,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL,0);
INSERT INTO page VALUES (7,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL,0);
INSERT INTO page VALUES (8,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL,0);
INSERT INTO page VALUES (9,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL,0);
INSERT INTO page VALUES (10,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL,0);
INSERT INTO page VALUES (11,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL,0);
INSERT INTO page VALUES (12,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL,0);
INSERT INTO page VALUES (13,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL,0);
INSERT INTO page VALUES (14,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL,0);
INSERT INTO page VALUES (15,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL,0);
INSERT INTO page VALUES (16,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL,0);
INSERT INTO page VALUES (17,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL,0);
INSERT INTO page VALUES (18,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL,0);
INSERT INTO page VALUES (19,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL,0);
INSERT INTO page VALUES (20,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL,0);
INSERT INTO page VALUES (21,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL,0);
INSERT INTO page VALUES (22,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL,0);
INSERT INTO page VALUES (23,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL,0);
INSERT INTO page VALUES (24,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL,0);
INSERT INTO page VALUES (25,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL,0);
INSERT INTO page VALUES (4,0,'Page Not Found',3,1,1,1,1,1,0,1,0,1,NULL,'page_not_found',0);
INSERT INTO page VALUES (3,0,'Trash',4,3,1,1,3,1,1,0,0,1,'','trash',0);
INSERT INTO page VALUES (2,0,'Clipboard',4,3,1,1,4,1,1,0,0,1,'','clipboard',0);

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
INSERT INTO settings VALUES ('attachmentDirectoryLocal','/data/WebGUI/uploads');
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
INSERT INTO settings VALUES ('VERSION','2.3.4');

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

INSERT INTO style VALUES (1,'Reserved','<body bgcolor=\"#000000\" text=\"#ffffff\">\r\n<table width=\"100%\"><tr><td>^C</td><td align=\"right\">^D</td></tr></table>\r\n<hr>\r\nhorizontal top level menu: ^t\r\n<hr>\r\nhorizontal current level menu: ^m\r\n<hr>\r\n<table width=\"100%\"><tr><td valign=\"top\" width=\"180\">\r\nvertical top level menu: ^T<br>\r\n<hr>\r\nvertical current level menu: ^M<br>\r\n\r\n\r\n</td><td valign=\"top\">\r\n\r\n','</td><td valign=\"top\" width=\"180\">\r\n^@<br>\r\n^#<br>\r\n^*<br>\r\n^?<br>\r\n</td></tr></table>\r\n</body>\r\n</html>\r\n','<style>\r\n/* WebGUI Default Style Sheet */\r\n\r\nH1 {\r\n  font-family: verdana, helvetica, arial;\r\n}\r\n\r\n.pagination {\r\n  font-family: helvetica, arial;\r\n  text-align: center;\r\n  width: 100%;\r\n  font-size: 8pt;\r\n}\r\n\r\n.adminBar {\r\n        background-color: #dddddd;\r\n        font-size: 8pt;\r\n        font-family: helvetica, arial;\r\n        color: #000055;\r\n}\r\n\r\n.crumbTrail {\r\n        font-family: helvetica, arial;\r\n        color: #dddddd;\r\n        font-size: 8pt;\r\n}\r\n\r\n.crumbTrail A {\r\n        color: #ffff00;\r\n}\r\n\r\n.crumbTrail A:visited {\r\n        color: #ffff00;\r\n}\r\n\r\n.verticalMenu {\r\n        font-family: helvetica, arial;\r\n        color: #dddddd;\r\n        font-size: 10pt;\r\n}\r\n\r\n.verticalMenu A {\r\n        color: #ffff00;\r\n}\r\n\r\n.verticalMenu A:visited {\r\n        color: #cccc00;\r\n}\r\n\r\n.highlight {\r\n  background-color: #800000;\r\n}\r\n\r\n.formDescription {\r\n        font-family: helvetica, arial;\r\n        color: #dddddd;\r\n        font-size: 10pt;\r\n}\r\n\r\n.formSubtext {\r\n        font-family: helvetica, arial;\r\n        color: #ffffff;\r\n        font-size: 8pt;\r\n}\r\n\r\n.boardTitle {\r\n  font-size: 16pt;\r\n}\r\n\r\n.boardMenu a {\r\n  color: #00ff00;\r\n  text-decoration: none;\r\n}\r\n\r\n.boardHeader {\r\n  font-weight: bold;\r\n  background-color: #008000\r\n}\r\n\r\n.boardData {\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.boardMessage {\r\n  font-style: italics;\r\n}\r\n</style>');
INSERT INTO style VALUES (2,'Fail Safe','<body>\r\n^H / ^t / ^m / ^a\r\n<hr>','<hr>\r\n^H / ^t / ^m / ^a\r\n</body>','<style>\r\n.adminBar {\r\n        background-color: #dddddd;\r\n        font-size: 8pt;\r\n        font-family: helvetica, arial;\r\n        color: #000055;\r\n}\r\n</style>');
INSERT INTO style VALUES (3,'Plain Black Software','<body bgcolor=\"#eaeaef\" text=\"#000000\" link=\"#5555ff\">\r\n<a href=\"/\"><img src=\"/extras/plainBlackSoftware.gif\" border=0></a>\r\n<table width=\"100%\"><tr><td>^C</td><td align=\"right\">^D</td></tr></table>\r\n<table width=\"100%\"><tr><td valign=\"top\" width=\"130\">\r\nuser: ^@\r\n<hr size=1>\r\n^T\r\n</td><td valign=\"top\">\r\n^m\r\n','</td></tr></table><hr size=1>\r\n<a href=\"/\"><img src=\"/extras/pbs.gif\" border=0 align=\"right\"></a>\r\n^H / ^a\r\n</body></html>','<style>\r\n/* WebGUI Default Style Sheet */\r\n\r\n.content, body {\r\n  background-color: #eaeaef;\r\n  color: #000000;\r\n  font-family: helvetica, arial;\r\n  font-size: 10pt;\r\n}\r\n\r\n.verticalMenu {\r\n  font-size: 10pt;\r\n}\r\nH1 {\r\n  font-family: helvetica, arial;\r\n}\r\n\r\nA {\r\n  color: #5555ff;\r\n}\r\n\r\n.pagination {\r\n  font-family: helvetica, arial;\r\n  font-size: 8pt;\r\n}\r\n\r\n.horizontalMenu {\r\n  font-size: 8pt;\r\n  background-color: #ffffff;\r\n  font-weight: bold;\r\n  border: 1px;\r\n}\r\n\r\n.adminBar {\r\n        background-color: #dddddd;\r\n        font-size: 8pt;\r\n        font-family: helvetica, arial;\r\n        color: #000055;\r\n}\r\n\r\n.crumbTrail {\r\n        font-family: helvetica, arial;\r\n        color: #666666;\r\n        font-size: 8pt;\r\n}\r\n\r\n.crumbTrail A {\r\n        color: #555555;\r\n}\r\n\r\n.crumbTrail A:visited {\r\n        color: #666666;\r\n}\r\n\r\n.formDescription {\r\n        font-family: helvetica, arial;\r\n        font-size: 10pt;\r\n}\r\n\r\n.formSubtext {\r\n        font-family: helvetica, arial;\r\n        font-size: 8pt;\r\n}\r\n\r\n.highlight {\r\n  background-color: #aaaaaa;\r\n}\r\n\r\n.tableMenu {\r\n  background-color: #dddddd;\r\n  font-size: 8pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.tableMenu a {\r\n  text-decoration: none;\r\n}\r\n\r\n.tableHeader {\r\n  background-color: #cccccc;\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.tableData {\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.pollAnswer {\r\n  font-family: Helvetica, Arial;\r\n  font-size: 8pt;\r\n}\r\n\r\n.pollColor {\r\n  background-color: #ffddbb;\r\n}\r\n\r\n.pollQuestion {\r\n  font-face: Helvetica, Arial;\r\n  font-weight: bold;\r\n}\r\n\r\n</style>');
INSERT INTO style VALUES (4,'Trash / Clipboard','<body>\r\n<table width=\"100%\"><tr><td valign=\"top\" width=\"30%\"><b>PAGES</b><br>^M0^/M</td><td valign=\"top\" width=\"70%\"><b>CONTENT</b><br>','</td></tr></table>\r\n<hr>\r\n^H / ^a\r\n</body>','<style>\r\n.adminBar {\r\n        background-color: #dddddd;\r\n        font-size: 8pt;\r\n        font-family: helvetica, arial;\r\n        color: #000055;\r\n}\r\n</style>');
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
INSERT INTO style VALUES (25,'Yahoo!','<html><head><title>Yahoo!</title><meta http-equiv=\"PICS-Label\" content=\'(PICS-1.1 \"http://www.rsac.org/ratingsv01.html\" l gen true for \"http://www.yahoo.com\" r (n 0 s 0 v 0 l 0))\'></head><body>\r\n<script language=javascript><!--\r\nfunction f(){\r\nvar f,m,p,a,i,k,o,e,l,c,d;\r\nf=\"0123456789abcdefghijklmnopqrstuvwxyz\";\r\nm=new Array;\r\np=\"claim-your-name\";\r\na=10;\r\nfor(i=0;i<36;i++){\r\n if(i==26)a=-26;\r\n m[f.charAt(i)]=f.charAt(i+a);\r\n}\r\nk=document.cookie;\r\nif((o=k.indexOf(\"Y=\"))==-1)return p;\r\nif((o=k.indexOf(\"l=\",o+2))==-1)return p;\r\nif((e=k.indexOf(\"/\",o+2))==-1)return p;\r\nif(e>o+18)e=o+18;\r\nl=k.substring(o+2,e);\r\np=\"\";\r\nfor(i=0;i<l.length;i++){\r\n c=l.charAt(i);\r\n if(m[c])p+=m[c];else p+=\'-\';\r\n}\r\nreturn p;\r\n}\r\nd=f();//-->\r\n</script>\r\n<center><form name=f action=http://search.yahoo.com/bin/search><map name=m><area coords=\"0,0,52,52\" href=r/c1><area coords=\"53,0,121,52\" href=r/p1><area coords=\"122,0,191,52\" href=r/m1><area coords=\"441,0,510,52\" href=r/wn><area coords=\"511,0,579,52\" href=r/i1><area coords=\"580,0,637,52\" href=r/hw></map><img width=638 height=53 border=0 usemap=\"#m\" src=http://us.a1.yimg.com/us.yimg.com/i/ww/m5v5.gif alt=Yahoo><br><table border=0 cellspacing=0 cellpadding=3 width=640><tr><td align=center width=205>\r\n<font color=ff0020>new!</font> <a href=\"http://www.yahoo.com/homet/?http://new.domains.yahoo.com\"><b>Y! Domains</b></a><br><small>reserve .biz & .info domains</small></td><td align=center><a href=\"http://rd.yahoo.com/M=77122.1317476.2909345.220161/D=yahoo_top/S=2716149:NP/A=656341/?http://website.yahoo.com/\" target=\"_top\"><img width=230 height=33 src=\"http://us.a1.yimg.com/us.yimg.com/a/pr/promo/anchor/hp_website2.gif\" alt=\"\" border=0></a></td><td align=center width=205><a href=\"http://www.yahoo.com//homet/?http://mail.yahoo.com\"><b>Yahoo! Mail</b></a><br>you@yahoo.com</td></tr><tr><td colspan=3 align=center><input size=30 name=p>\r\n<input type=submit value=Search> <a href=http://www.yahoo.com/r/so>advanced search</a></td></tr></table>\r\n</form>\r\n<div align=\"left\">\r\n','</div>\r\n<hr noshade size=1 width=640><small><a href=http://www.yahoo.com/r/ad>How to Suggest a Site</a> -\r\n<a href=http://www.yahoo.com/r/cp>Company Info</a> -\r\n<a href=http://www.yahoo.com/r/cy>Copyright Policy</a> -\r\n<a href=http://www.yahoo.com/r/ts>Terms of Service</a> -\r\n<a href=http://www.yahoo.com/r/cb>Contributors</a> -\r\n<a href=http://www.yahoo.com/r/hr>Jobs</a> -\r\n<a href=http://www.yahoo.com/r/ao>Advertising</a><p>Copyright © 2001 Yahoo! Inc. All rights reserved.</small><br><a href=http://www.yahoo.com/r/pv>Privacy Policy</a></form></center></body></html>\r\n','');

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
INSERT INTO users VALUES (3,'Admin','RvlMjeFPs2aAhQdo/xt/Kg','','WebGUI',NULL,NULL,'English',NULL,NULL,NULL,'',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
  widgetType varchar(35) default NULL,
  sequenceNumber int(11) NOT NULL default '1',
  title varchar(255) default NULL,
  displayTitle int(11) NOT NULL default '1',
  description text,
  processMacros int(11) NOT NULL default '0',
  dateAdded int(11) default NULL,
  addedBy int(11) default NULL,
  lastEdited int(11) default NULL,
  editedBy int(11) default NULL,
  PRIMARY KEY  (widgetId)
) TYPE=MyISAM;

#
# Dumping data for table 'widget'
#

INSERT INTO widget VALUES (-1,4,'SiteMap',0,'Page Not Found',1,'The page you were looking for could not be found on this system. Perhaps it has been deleted or renamed. The following list is a site map of this site. If you don\'t find what you\'re looking for on the site map, you can always start from the <a href=\"^/\">Home Page</a>.',1,1001744792,3,1001744968,3);

