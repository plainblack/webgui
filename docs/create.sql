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
# Table structure for table 'event'
#

CREATE TABLE event (
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
# Dumping data for table 'event'
#


#
# Table structure for table 'faqQuestion'
#

CREATE TABLE faqQuestion (
  widgetId int(11) default NULL,
  questionId int(11) NOT NULL default '0',
  question text,
  answer text,
  sequenceNumber int(11) NOT NULL default '0',
  PRIMARY KEY  (questionId)
) TYPE=MyISAM;

#
# Dumping data for table 'faqQuestion'
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
  language varchar(30) NOT NULL default 'US English',
  action varchar(30) default NULL,
  object varchar(30) default NULL,
  body text,
  seeAlso varchar(50) NOT NULL default '0',
  KEY helpId (helpId,language)
) TYPE=MyISAM;

#
# Dumping data for table 'help'
#

INSERT INTO help VALUES (1,'US English','Add/Edit','Page','Think of pages as containers for content. For instance, if you want to write a letter to the editor of your favorite magazine you\'d get out a notepad (or open a word processor) and start filling it with your thoughts. The same is true with WebGUI. Create a page, then add your content to the page.\r\n\r\n<b>Title</b>\r\nThe title of the page is what your users will use to navigate through the site. Titles should be descriptive, but not very long.\r\n\r\n<b>Page URL</b>\r\nWhen you create a page a url for the page is generated based on the page title. If you are unhappy with the url that was chosen, you can change it here.\r\n\r\n<b>Meta Tags</b>\r\nMeta tags are used by some search engines to associate key words to a particular page. There is a great site called <a href=\"http://www.metatagbuilder.com/\">Meta Tag Builder</a> that will help you build meta tags if you\'ve never done it before.\r\n\r\n<i>Advanced Users:</i> If you have other things (like JavaScript) you usually put in the &lt;head&gt; area of your pages, you may put them here as well.\r\n\r\n<b>Use default meta tags?</b>\r\nIf you don\'t wish to specify meta tags yourself, WebGUI can generate meta tags based on the page title and your company\'s name. Check this box to enable the defaultly generated meta tags.\r\n\r\n<b>Style</b>\r\nBy default, when you create a page, it inherits a few traits from its parent. One of those traits is style. Choose from the list of styles if you would like to change the appearance of this page. See <i>Add Style</i> for more details.\r\n\r\nIf you check the box below to the style pull-down menu, all of the pages below this page will take on the style you\'ve chosen for this page.\r\n\r\n<b>Owner</b>\r\nThe owner of a page is usually the person who created the page.\r\n\r\n<b>Owner can view?</b>\r\nCan the owner view the page or not?\r\n\r\n<b>Owner can edit?</b>\r\nCan the owner edit the page or not? Be careful, if you decide that the owner cannot edit the page and you do not belong to the page group, then you\'ll lose the ability to edit this page.\r\n\r\n<b>Group</b>\r\nA group is assigned to every page for additional privilege control. Pick a group from the pull-down menu.\r\n\r\n<b>Group can view?</b>\r\nCan members of this group view this page?\r\n\r\n<b>Group can edit?</b>\r\nCan members of this group edit this page?\r\n\r\n<b>Anybody can view?</b>\r\nCan any visitor or member regardless of the group and owner view this page?\r\n\r\n<b>Anybody can edit?</b>\r\nCan any visitor or member regardless of the group and owner edit this page?\r\n\r\nYou can optionally give these privileges to all pages under this page.\r\n','0');
INSERT INTO help VALUES (3,'US English','Delete','Page','Deleting a page can create a big mess if you are uncertain about what you are doing. When you delete a page you are also deleting the content it contains, all sub-pages connected to this page, and all the content they contain. Be certain that you have already moved all the content you wish to keep before you delete a page.\r\n\r\nAs with any delete operation, you are prompted to be sure you wish to proceed with the delete. If you answer yes, the delete will proceed and there is no recovery possible. If you answer no you\'ll be returned to the prior screen.','0');
INSERT INTO help VALUES (4,'US English','Delete','Style','When you delete a style all pages using that style will be reverted to the fail safe (default) style. To ensure uninterrupted viewing, you should be sure that no pages are using a style before you delete it.\r\n\r\nAs with any delete operation, you are prompted to be sure you wish to proceed with the delete. If you answer yes, the delete will proceed and there is no recovery possible. If you answer no you\'ll be returned to the prior screen.','0');
INSERT INTO help VALUES (5,'US English','Add/Edit','User','See <b>Manage Users</b> for additional details.\r\n\r\n<b>Username</b>\r\nUsername is a unique identifier for a user. Sometimes called a handle, it is also how the user will be known on the site. (<i>Note:</i> Administrators have unlimited power in the WebGUI system. This also means they are capable of breaking the system. If you rename or create a user, be careful not to use a username already in existance.)\r\n\r\n<b>Password</b>\r\nA password is used to ensure that the user is who s/he says s/he is.\r\n\r\n<b>Authentication Method</b>\r\nSee <i>Edit Settings</i> for details.\r\n\r\n<b>LDAP URL</b>\r\nSee <i>Edit Settings</i> for details.\r\n\r\n<b>Connect DN</b>\r\nThe Connect DN is the <b>cn</b> (or common name) of a given user in your LDAP database. It should be specified as <b>cn=John Doe</b>. This is, in effect, the username that will be used to authenticate this user against your LDAP server.\r\n\r\n<b>Email Address</b>\r\nThe user\'s email address. This must only be specified if the user will partake in functions that require email.\r\n\r\n<b>Groups</b>\r\nGroups displays which groups the user is in. Groups that are highlighted are groups that the user is assigned to. Those that are not highlighted are other groups that can be assigned. Note that you must hold down CTRL to select multiple groups.\r\n\r\n<b>Language</b>\r\nWhat language should be used to display system related messages.\r\n\r\n<b>ICQ UIN</b>\r\nThe <a href=\"http://www.icq.com\">ICQ</a> UIN is the \"User ID Number\" on the ICQ network. ICQ is a very popular instant messaging platform.\r\n\r\n','0');
INSERT INTO help VALUES (7,'US English','Delete','User','There is no need to ever actually delete a user. If you are concerned with locking out a user, then simply change their password. If you truely wish to delete a user, then please keep in mind that there are consequences. If you delete a user any content that they added to the site via widgets (like message boards and user contributions) will remain on the site. However, if another user tries to visit the deleted user\'s profile they will get an error message. Also if the user ever is welcomed back to the site, there is no way to give him/her access to his/her old content items except by re-adding the user to the users table manually.\r\nAs with any delete operation, you are prompted to be sure you wish to proceed with the delete. If you answer yes, the delete will proceed and there is no recovery possible. If you answer no you\'ll be returned to the prior screen.','0');
INSERT INTO help VALUES (8,'US English','Manage','User','Users are the accounts in the system that are given rights to do certain things. There are two default users built into the system: Admin and Visitor.\r\n\r\n<b>Admin</b>\r\nAdmin is exactly what you\'d expect. It is a user with unlimited rights in the WebGUI environment. If it can be done, this user has the rights to do it.\r\n\r\n<b>Visitor</b>\r\nVisitor is exactly the opposite of Admin. Visitor has no rights what-so-ever. By default any user who is not logged in is seen as the user Visitor.\r\n\r\n<b>Add a new user.</b>\r\nClick on this to go to the add user screen.\r\n\r\n<b>Search</b>\r\nYou can search users based on username and email address. You can do partial searches too if you like.','0');
INSERT INTO help VALUES (9,'US English','Manage','Style','Styles are used to manage the look and feel of your WebGUI pages. With WebGUI, you can have an unlimited number of styles, so your site can take on as many looks as you like. You could have some pages that look like your company\'s brochure, and some pages that look like Yahoo!&reg;. You could even have some pages that look like pages in a book. Using style management, you have ultimate control over all your designs.\r\n\r\nThere are three styles built in to WebGUI: Fail Safe, Plain Black Software, and Yahoo!&reg;. These styles are not meant to be edited, but rather to give you samples of what\'s possible.\r\n\r\n<b>Fail Safe</b>\r\nWhen you delete a style that is still in use on some pages, the Fail Safe style will be applied to those pages. This style has a white background and simple navigation.\r\n\r\n<b>Plain Black Software</b>\r\nThis is the simple design used on the Plain Black Software site.\r\n\r\n<b>Yahoo!&reg;</b>\r\nThis is the design of the Yahoo!&reg; site. (Yahoo!&reg; has not given us permission to use their design. It is simply an example.)','0');
INSERT INTO help VALUES (10,'US English','Manage','Group','Groups are used to subdivide privileges and responsibilities within the WebGUI system. For instance, you may be building a site for a classroom situation. In that case you might set up a different group for each class that you teach. You would then apply those groups to the pages that are designed for each class.\r\n\r\nThere are four groups built into WebGUI. They are Admins, Content Managers, Visitors, and Registered Users.\r\n\r\n<b>Admins</b>\r\nAdmins are users who have unlimited privileges within WebGUI. A user should only be added to the admin group if they oversee the system. Usually only one to three people will be added to this group.\r\n\r\n<b>Content Managers</b>\r\nContent managers are users who have privileges to add, edit, and delete content from various areas on the site. The content managers group should not be used to control individual content areas within the site, but to determine whether a user can edit content at all. You should set up additional groups to separate content areas on the site.\r\n\r\n<b>Registered Users</b>\r\nWhen users are added to the system they are put into the registered users group. A user should only be removed from this group if their account is deleted or if you wish to punish a troublemaker.\r\n\r\n<b>Visitors</b>\r\nVisitors are users who are not logged in using an account on the system. Also, if you wish to punish a registered user you could remove him/her from the Registered Users group and insert him/her into the Visitors group.','0');
INSERT INTO help VALUES (12,'US English','Manage','Settings','Settings are items that allow you to adjust WebGUI to your particular needs.\r\n\r\n<b>Edit Authentication Settings</b>\r\nSettings concerning user identification and login, such as LDAP.\r\n\r\n<b>Edit Company Information</b>\r\nInformation specific about the company or individual who controls this installation of WebGUI.\r\n\r\n<b>Edit File Settings</b>\r\nSettings concerning attachments and images.\r\n\r\n<b>Edit Mail Settings</b>\r\nSettings concerning email and related functions.\r\n\r\n<b>Edit Miscellaneous Settings</b>\r\nEverything else.\r\n\r\n','2,6,11,13,24');
INSERT INTO help VALUES (14,'US English','Delete','Widget','This function permanently deletes the selected widget from a page. If you are unsure whether you wish to delete this content you may be better served to cut the content to the clipboard until you are certain you wish to delete it.\r\n\r\nAs with any delete operation, you are prompted to be sure you wish to proceed with the delete. If you answer yes, the delete will proceed and there is no recovery possible. If you answer no you\'ll be returned to the prior screen.','0');
INSERT INTO help VALUES (15,'US English','Delete','Group','As the function suggests you\'ll be deleting a group and removing all users from the group. Be careful not to orphan users from pages they should have access to by deleting a group that is in use.\r\n\r\nAs with any delete operation, you are prompted to be sure you wish to proceed with the delete. If you answer yes, the delete will proceed and there is no recovery possible. If you answer no you\'ll be returned to the prior screen.','0');
INSERT INTO help VALUES (16,'US English','Add/Edit','Style','Styles are WebGUI macro enabled. See <i>Using Macros</i> for more information.\r\n\r\n<b>Style Name</b>\r\nA unique name to describe what this style looks like at a glance. The name has no effect on the actual look of the style.\r\n\r\n<b>Header</b>\r\nThe header is the start of the look of your site. It is helpful to look at your design and cut it into three pieces. The top and left of your design is the header. The center part is the content, and the right and bottom is the footer. Cut the HTML from your header and paste it in the space provided.\r\n\r\nIf you are in need of assistance for creating a look for your site, or if you need help cutting apart your design, <a href=\"http://www.plainblack.com\">Plain Black Software</a> provides support services for a small fee.\r\n\r\nMany people will add WebGUI macros to their header for automated navigation, and other features.\r\n\r\n<b>Footer</b>\r\nThe footer is the end of the look for your site. It is the right and bottom portion of your design. You may also place WebGUI macros in your footer.\r\n\r\n<b>Style Sheet</b>\r\nPlace your style sheet entries here. Style sheets are used to control colors, sizes, and other properties of the elements on your site. See <i>Using Style Sheets</i> for more information.\r\n\r\n<i>Advanced Users:</i> for greater performance create your stylesheet on the file system (call it something like webgui.css) and add an entry like this to this area: \r\n&lt;link href=\"/webgui.css\" rel=\"stylesheet\" rev=\"stylesheet\" type=\"text/css\"&gt;','18,19');
INSERT INTO help VALUES (17,'US English','Add/Edit','Group','See <i>Manage Group</i> for a description of grouping functions and the default groups.\r\n\r\n<b>Group Name</b>\r\nA name for the group. It is best if the name is descriptive so you know what it is at a glance.\r\n\r\n<b>Description</b>\r\nA longer description of the group so that other admins and content managers (or you if you forget) will know what the purpose of this group is.','0');
INSERT INTO help VALUES (24,'US English','Edit','Miscellaneous Settings','<b>Not Found Page</b>\r\nIf a page that a user requests is not found in the system, the user can be redirected to the home page or to an error page where they can attempt to find what they were looking for. You decide which is better for your users.\r\n\r\n<b>Session Timeout</b>\r\nThe time (in seconds) that a user session remains active (before needing to log in again). This timeout is reset each time a visitor hits a page. Therefore if you set the timeout for 8 hours, a user would have to log in again if s/he hadn\'t visited the site for 8 hours.\r\n\r\n1800 = half hour\r\n3600 = 1 hour\r\n28000 = 8 hours\r\n86400 = 1 day\r\n604800 = 1 week\r\n1209600 = 2 weeks\r\n','12');
INSERT INTO help VALUES (18,'US English','Using','Style Sheets','<a href=\"http://www.w3.org/Style/CSS/\">Cascading Style Sheets (CSS)</a> are a great way to manage the look and feel of any web site. They are used extensively in WebGUI.\r\n\r\nIf you are unfamiliar with how to use CSS, <a href=\"http://www.plainblack.com\">Plain Black Software</a> provides training classes on XHTML and CSS. Alternatively, Bradsoft makes an excellent CSS editor called <a href=\"http://www.bradsoft.com/topstyle/index.asp\">Top Style</a>.\r\n\r\nThe following is a list of classes used to control the look of WebGUI:\r\n\r\n<b>A</b>\r\nThe links throughout the style.\r\n\r\n<b>BODY</b>\r\nThe default setup of all pages within a style.\r\n\r\n<b>H1</b>\r\nThe headers on every page.\r\n\r\n<b>.accountOptions</b>\r\nThe links that appear under the login and account update forms.\r\n\r\n<b>.adminBar </b>\r\nThe bar that appears at the top of the page when you\'re in admin mode.\r\n\r\n<b>.boardMenu </b>\r\nThe menu on the message boards.\r\n\r\n<b>.boardMessage </b>\r\nThe full message text.\r\n\r\n<b>.boardTitle </b>\r\nThe title of the message board.\r\n\r\n<b>.content</b>\r\nThe main content area on all pages of the style.\r\n\r\n<b>.crumbTrail </b>\r\nThe crumb trail (if you\'re using that macro).\r\n\r\n<b>.eventTitle </b>\r\nThe title of an individual event.\r\n\r\n<b>.faqQuestion</b>\r\nAn F.A.Q. question. To distinguish it from an answer.\r\n\r\n<b>.formDescription </b>\r\nThe tags on all forms next to the form elements. \r\n\r\n<b>.formSubtext </b>\r\nThe tags below some form elements.\r\n\r\n<b>.highlight </b>\r\nDenotes a highlighted item, such as which message you are viewing within a list.\r\n\r\n<b>.homeLink</b>\r\nUsed by the my home (^H) macro.\r\n\r\n<b>.horizontalMenu </b>\r\nThe horizontal menu (if you use a horizontal menu macro).\r\n\r\n<b>.loginBox</b>\r\nThe login box (^L) macro.\r\n\r\n<b>.makePrintableLink</b>\r\nUsed by the make printable (^r) macro.\r\n\r\n<b>.myAccountLink</b>\r\nUsed by the my account (^a) macro.\r\n\r\n<b>.pagination </b>\r\nThe Previous and Next links on pages with pagination.\r\n\r\n<b>.pollAnswer </b>\r\nAn answer on a poll.\r\n\r\n<b>.pollColor </b>\r\nThe color of the percentage bar on a poll.\r\n\r\n<b>.pollQuestion </b>\r\nThe question on a poll.\r\n\r\n<b>.tableData </b>\r\nThe data rows on things like message boards and user contributions.\r\n\r\n<b>.tableHeader </b>\r\nThe headings of columns on things like message boards and user contributions.\r\n\r\n<b>.verticalMenu </b>\r\nThe vertical menu (if you use a verticall menu macro).\r\n\r\n','11,16');
INSERT INTO help VALUES (19,'US English','Using','Macros','WebGUI macros are used to create dynamic content within otherwise static content. For instance, you may wish to show which user is logged in on every page, or you may wish to have a dynamically built menu or crumb trail. \r\n\r\nMacros always begin with a carat (^) and follow with one other character. Some macros can be extended/configured by taking the format of ^<i>x</i><b>config text</b>^/<i>x</i>. The following is a description of all the macros in the WebGUI system.\r\n\r\n<b>^A^/A - Any SubMenu</b>\r\nThis macro allows you to get the submenu of any page, starting with the page you specified. For instance, you could get the home page submenu by creating a macro that looks like this <b>^Ahome,0</b>. The first value is the urlized title of the page and the second value is the depth you\'d like the menu to go. By default it will show only the first level. To go three levels deep create a macro like this <b>^A3^/A</b>. If you set the macro to \"0\" it will track the entire site tree.\r\n\r\n<b>^a or ^a^/a - My Account Link</b>\r\nA link to your account information. In addition you can change the link text by creating a macro like this <b>^aAccount Info^/a</b>.\r\n\r\n<b>^C - Crumb Trail</b>\r\nA dynamically generated crumb trail to the current page.\r\n\r\n<b>^c - Company Name</b>\r\nThe name of your company specified in the settings by your Administrator.\r\n\r\n<b>^D or ^D^/D - Date</b>\r\nThe current date and time.\r\n\r\nYou can configure the date by using date formatting symbols. For instance, if you created a macro like this <b>^D%c %D, %y^/D</b> it would output <b>September 26, 2001</b>. The following are the available date formatting symbols:\r\n<span style=\"font-family: courier;\">\r\n    %% = %\r\n    %y = 4 digit year\r\n    %Y = 2 digit year\r\n    %m = 2 digit month\r\n    %M = variable digit month\r\n    %c = month name\r\n    %d = 2 digit day of month\r\n    %D = variable digit day of month\r\n    %w = day of week name\r\n    %h = 2 digit base 12 hour\r\n    %H = variable digit base 12 hour\r\n    %j = 2 digit base 24 hour\r\n    %J = variable digit base 24 hour\r\n    %p = lower case am/pm\r\n    %P = upper case AM/PM\r\n</span>\r\n<b>^e - Company Email Address</b>\r\nThe email address for your company specified in the settings by your Administrator.\r\n\r\n<b>^H or ^H^/H - Home Link</b>\r\nA link to the home page of this site.  In addition you can change the link text by creating a macro like this <b>^HGo Home^/H</b>.\r\n\r\n<b>^L - Login</b>\r\nA small login form.\r\n\r\n<b>^M or ^M^/M - Current Menu (Vertical)</b>\r\nA vertical menu containing the sub-pages at the current level. In addition, you may configure this macro by specifying how many levels deep the menu should go. By default it will show only the first level. To go three levels deep create a macro like this <b>^M3^/M</b>. If you set the macro to \"0\" it will track the entire site tree.\r\n\r\n<b>^m - Current Menu (Horizontal)</b>\r\nA horizontal menu containing the sub-pages at the current level.\r\n\r\n<b>^P or ^P^/P - Previous Menu (Vertical)</b>\r\nA vertical menu containing the sub-pages at the previous level. In addition, you may configure this macro by specifying how many levels deep the menu should go. By default it will show only the first level. To go three levels deep create a macro like this <b>^TP^/P</b>. If you set the macro to \"0\" it will track the entire site tree.\r\n\r\n<b>^p - Previous Menu (Horizontal)</b>\r\nA horizontal menu containing the sub-pages at the previous level.\r\n\r\n<b>^r or ^r^/r - Make Page Printable</b>\r\nCreates a link to remove the style from a page to make it printable.  In addition, you can change the link text by creating a macro like this <b>^rPRINT!^/r</b>.\r\n\r\n<b>^T or ^T^/T - Top Level Menu (Vertical)</b>\r\nA vertical menu containing the main pages of the site (aka the sub-pages from the home page). In addition, you may configure this macro by specifying how many levels deep the menu should go. By default it will show only the first level. To go three levels deep create a macro like this <b>^T3^/T</b>. If you set the macro to \"0\" it will track the entire site tree.\r\n\r\n<b>^t - Top Level Menu (Horizontal)</b>\r\nA vertical menu containing the main pages of the site (aka the sub-pages from the home page).\r\n\r\n<b>^u - Company URL</b>\r\nThe URL for your company specified in the settings by your Administrator.\r\n\r\n<b>^^ - Carat</b>\r\nSince the carat symbol is used to start all macros, this macro is in place just in case you really wanted to use a carat somewhere.\r\n\r\n<b>^/ - System URL</b>\r\nThe URL to the gateway script (including the domain for this site). This is often used within pages so that if your development server is on a domain different than your production server that your URLs will still worked when moved.\r\n\r\n<b>^\\ - Page URL</b>\r\nThe URL to the current page (including the domain for this site). This is often used within pages so that if your development server is on a domain different than your production server that your URLs will still worked when moved.\r\n\r\n<b>^@ - Username</b>\r\nThe username of the currently logged in user.\r\n\r\n<b>^# - User ID</b>\r\nThe user id of the currently logged in user.\r\n\r\n<b>^* or ^*^/* - Random Number</b>\r\nA randomly generated number. This is often used on images (such as banner ads) that you want to ensure do not cache. In addition, you may configure this macro like this <b>^*100^/*</b> to create a random number between 0 and 100.\r\n\r\n<b>^0,^1,^2,^3,^4,^5,^6,^7,^8,^9, ^-</b>\r\nThese macros are reserved for widget-specific functions as in the SQL Report widget.\r\n','11,16,12');
INSERT INTO help VALUES (20,'US English','Add/Edit','SQL Report','SQL Reports are perhaps the most powerful widget in the WebGUI arsenal. They allow a user to query data from any database that they have access to. This is great for getting sales figures from your Accounting database or even summarizing all the message boards on your web site.\r\n\r\n<b>Title</b>\r\nThe title of this report.\r\n\r\n<b>Display the title?</b>\r\nDo you wish to disply the title?\r\n\r\n<b>Process macros?</b>\r\nDo you wish to process WebGUI macros? Unchecking this box will not process macros and will speed up page execution.\r\n\r\n<b>Description</b>\r\nDescribe the content of this report so your users will better understand what the report is all about.\r\n\r\n<b>Template</b>\r\nLayout a template of how this report should look. Usually you\'ll use HTML tables to generate a report. An example is included below.\r\n\r\nThere are 11 special macro characters used in generating SQL Reports. They are ^-, ^0, ^1, ^2, ^3, ^4, ^5, ^6, ^7, ^8, and ^9. These macros will be processed regardless of whether you checked the process macros box above. The ^- macro represents split points in the document where the report will begin and end looping. The numeric macros represent the data fields that will be returned from your query. Note that you may only have 10 fields returned per row in your query.\r\n\r\n<i>Sample Template:</i>\r\n&lt;table&gt;\r\n&lt;tr&gt;&lt;th&gt;Employee Name&lt;/th&gt;&lt;th&gt;Employee #&lt;/th&gt;&lt;th&gt;Vacation Days Remaining&lt;/th&gt;&lt;th&gt;Monthly Salary&lt;/th&gt;&lt;/tr&gt;\r\n^-\r\n&lt;tr&gt;&lt;td&gt;^0&lt;/td&gt;&lt;td&gt;^1&lt;/td&gt;&lt;td&gt;^2&lt;/td&gt;&lt;td&gt;^3&lt;/td&gt;&lt;/tr&gt;\r\n^-\r\n&lt;/table&gt;\r\n\r\n<b>Query</b>\r\nThis is a standard SQL query. If you are unfamiliar with SQL, <a href=\"http://www.plainblack.com\">Plain Black Software</a> provides training courses in SQL and database management.\r\n\r\n<b>DSN</b>\r\n<b>D</b>ata <b>S</b>ource <b>N</b>ame is the unique identifier that Perl uses to describe the location of your database. It takes the format of DBI:[driver]:[database name]:[host]. \r\n\r\n<i>Example:</i> DBI:mysql:WebGUI:localhost\r\n\r\n<b>Database User</b>\r\nThe username you use to connect to the DSN.\r\n\r\n<b>Database Password</b>\r\nThe password you use to connect to the DSN.\r\n\r\n<b>Convert carriage returns?</b>\r\nDo you wish to convert the carriage returns in the resultant data to HTML breaks (&lt;br&gt;).\r\n','19,14,21');
INSERT INTO help VALUES (21,'US English','Using','Widget','Widgets are the true power of WebGUI. Widgets are tiny pluggable applications built to run under WebGUI. Message boards and polls are examples of widgets.\r\n\r\nTo add a widget to a page, first go to that page, then select <i>Add Content...</i> from the upper left corner of your screen. Each widget has it\'s own help so be sure to read the help if you\'re not sure how to use a widget.\r\n','0');
INSERT INTO help VALUES (23,'US English','Add/Edit','Article','Articles are the Swiss Army knife of WebGUI. Most pieces of static content can be added via the Article widget.\r\n\r\n<b>Title</b>\r\nWhat\'s the title for this content? Even if you don\'t wish the title to appear, it\'s a good idea to title your content so that if it is ever copied to the clipboard it will have a name.\r\n\r\n<b>Display the title?</b>\r\nDo you wish to display the title listed above?\r\n\r\n<b>Process macros?</b>\r\nDo you wish to process WebGUI macros on this article? Unchecking this box will not process macros and will speed up page execution.\r\n\r\n<b>Start Date</b>\r\nWhat date do you want this article to appear on the site? Dates are in the format of MM/DD/YYYY. You can use the JavaScript wizard to choose your date from a calendar by clicking on the <i>set date</i> button. By default the date is set to 01/01/2000.\r\n\r\n<b>End Date</b>\r\nWhat date do you want this article to be removed from the site? By default the date is set to 100 years in the future, 01/01/2100.\r\n\r\n<b>Body</b>\r\nThe body of the article is where all the content goes. You may feel free to add HTML tags as necessary to format your content. Be sure to put a &lt;p&gt; between paragraphs to add white space to your content.\r\n\r\n<b>Image</b>\r\nChoose an image (.jpg, .gif, .png) file from your hard drive. This file will be uploaded to the server and displayed in the upper-right corner of your article.\r\n\r\n<b>Link Title</b>\r\nIf you wish to add a link to your article, enter the title of the link in this field. \r\n\r\n<i>Example:</i> Google\r\n\r\n<b>Link URL</b>\r\nIf you added a link title, now add the URL (uniform resource locator) here. \r\n\r\n<i>Example:</i> http://www.google.com\r\n\r\n<b>Attachment</b>\r\nIf you wish to attach a word processor file, a zip file, or any other file for download by your users, then choose it from your hard drive.\r\n\r\n<b>Convert carriage returns?</b>\r\nIf you\'re publishin HTML there\'s generally no need to check this option, but if you aren\'t using HTML and you want a carriage return every place you hit your \"Enter\" key, then check this option.\r\n','14,21');
INSERT INTO help VALUES (25,'US English','Add/Edit','Extra Column','Extra columns allow you to change the layout of your page for one page only. If you wish to have multiple columns on all your pages. Perhaps you should consider altering the <i>style</i> applied to your pages. \r\n\r\nColumns are always added from left to right. Therefore any existing content will be on the left of the new column.\r\n\r\n<b>Spacer</b>\r\nSpacer is the amount of space between your existing content and your new column. It is measured in pixels.\r\n\r\n<b>Width</b>\r\nWidth is the actual width of the new column to be added. Width is measured in pixels.\r\n\r\n<b>StyleSheet Class</b>\r\nBy default the <i>content</i> style (which is the style the body of your site should be using) that is applied to all columns. However, if you\'ve created a style specifically for columns, then feel free to modify this class.\r\n','14,21,9,18');
INSERT INTO help VALUES (27,'US English','Add/Edit','Widget','You can add widgets by selecting from the <i>Add Content</i> pulldown menu. You can edit them by clicking on the \"Edit\" button that appears directly above an instance of a particular widget.','0');
INSERT INTO help VALUES (28,'US English','Add/Edit','Poll','Polls can be used to get the impressions of your users on various topics.\r\n\r\n<b>Title</b>\r\nThe title of the poll. Even if you don\'t wish to display the title you should fill out this field so this poll will have a name if it is ever placed in the clipboard.\r\n\r\n<b>Display the title?</b>\r\nDo you wish to disply the title?\r\n\r\n<b>Process macros?</b>\r\nDo you wish to process WebGUI macros? Unchecking this box will not process macros and will speed up page execution.\r\n\r\n<b>Description</b>\r\nYou may provide a description for this poll, or give the user some background information.\r\n\r\n<b>Active</b>\r\nIf this box is checked, then users will be able to vote. Otherwise they\'ll only be able to see the results of the poll.\r\n\r\n<b>Who can vote?</b>\r\nChoose a group that can vote on this poll.\r\n\r\n<b>Graph Width</b>\r\nThe width of the poll results graph. The width is measured in pixels.\r\n\r\n<b>Question</b>\r\nWhat is the question you\'d like to ask your users?\r\n\r\n<b>Answers</b>\r\nEnter the possible answers to your question. Enter only one answer per line. Polls are only capable of 20 possible answers.\r\n\r\n<b>Reset votes.</b>\r\nReset the votes on this poll.','14,21,19');
INSERT INTO help VALUES (30,'US English','Add/Edit','Site Map','Site maps are used to provide additional navigation in WebGUI. You could set up a traditional site map that would display a hierarchical view of all the pages in the site. On the other hand, you could use site maps to provide extra navigation at certain levels in your site.\r\n\r\n<b>Title</b>\r\nWhat title would you give to this site map? You should fill this field out even if you don\'t wish it to be displayed.\r\n\r\n<b>Display the title?</b>\r\nDo you wish to disply the title?\r\n\r\n<b>Process macros?</b>\r\nDo you wish to process WebGUI macros? Unchecking this box will not process macros and will speed up page execution.\r\n\r\n<b>Description</b>\r\nEnter a description as to why this site map is here and what purpose it serves.\r\n\r\n<b>Starting from this level?</b>\r\nIf the site map should display the page tree starting from this level, then check this box. If you wish the site map to start from the home page then uncheck it.\r\n\r\n<b>Show only one level?</b>\r\nShould the site map display only the current level of pages or all pages from this point forward? \r\n','14,21,19');
INSERT INTO help VALUES (32,'US English','Add/Edit','Message Board','Message boards, also called Forums and/or Discussions, are a great way to add community to any site or intranets. Many companies use message boards internally to collaborate on projects.\r\n\r\n<b>Title</b>\r\nThe name of this board.\r\n\r\n<b>Display the title?</b>\r\nDo you wish to disply the title?\r\n\r\n<b>Process macros?</b>\r\nDo you wish to process WebGUI macros? Unchecking this box will not process macros and will speed up page execution.\r\n\r\n<b>Description</b>\r\nBriefly describe what should be displayed on this message board.\r\n\r\n<b>Who can post?</b>\r\nWhat group can post to this message board?\r\n\r\n<b>Messages Per Page</b>\r\nWhen a visitor first comes to a message board s/he will be presented with a listing of all the topics (aka threads) of the message board. If a board is popular, it will quickly have many topics. The messages per page attribute allows you to specify how many topics should be shown on one page.\r\n\r\n<b>Edit Timeout</b>\r\nHow long after a user has posted to the board will their message be available for them to edit. This timeout is measured in hours.\r\n\r\n<i>Note:</i> Don\'t set this limit too high. One of the great things about message boards is that they are an accurate record of a discussion. If you allow editing for a long time, then a user has a chance to go back and change his/her mind a long time after the original statement was made.\r\n','14,21,19');
INSERT INTO help VALUES (34,'US English','Add/Edit','Link List','Link lists are just what they sound like, a list of links. Many sites have a links section, and this just automates the process.\r\n\r\n<b>Title</b>\r\nWhat is the title of this link list?\r\n\r\n<b>Display the title?</b>\r\nDo you wish to disply the title?\r\n\r\n<b>Process macros?</b>\r\nDo you wish to process WebGUI macros? Unchecking this box will not process macros and will speed up page execution.\r\n\r\n<b>Description</b>\r\nDescribe the purpose of the links in this list.\r\n\r\n<b>Adding / Editing Links</b>\r\nYou\'ll notice at the bottom of the Edit screen that there are some options to add, edit, delete and reorder the links in your link lists. This process works exactly as the process for doing the same with widgets and pages. The three properties of links are <i>name</i>, <i>url</i>, and <i>description</i>.\r\n','14,21,19');
INSERT INTO help VALUES (13,'US English','Edit','Mail Settings','<b>Recover Password Message</b>\r\nThe message that gets sent to a user when they use the \"recover password\" function.\r\n\r\n<b>SMTP Server</b>\r\nThis is the address of your local mail server. It is needed for all features that use the Internet email system (such as password recovery).\r\n\r\n','12');
INSERT INTO help VALUES (36,'US English','Add/Edit','Syndicated Content','Syndicated content is content that is pulled from another site using the RDF/RSS specification. This technology is often used to pull headlines from various news sites like <a href=\"http://www.cnn.com\">CNN</a> and  <a href=\"http://slashdot.org\">Slashdot</a>. It can, of course, be used for other things like sports scores, stock market info, etc.\r\n\r\nYou can find a list of syndicated content at <a href=\"http://my.userland.com\">http://my.userland.com</a>. You will need to register with an account to browse their listing of content. Also, the list contained there is by no means a complete list of all the syndicated content on the internet.\r\n\r\n<b>Title</b>\r\nWhat is the title for this content? This is often the title of the site that the content comes from.\r\n\r\n<b>Display the title?</b>\r\nDo you wish to disply the title?\r\n\r\n<b>Process macros?</b>\r\nDo you wish to process WebGUI macros? Unchecking this box will not process macros and will speed up page execution.\r\n\r\n<b>Description</b>\r\nBriefly describe the content being pulled so that your users will know what they are seeing.\r\n\r\n<b>URL to RSS file</b>\r\nProvide the exact URL (starting with http://) to the syndicated content\'s RDF or RSS file. The syndicated content will be downloaded from this URL hourly.','14,21');
INSERT INTO help VALUES (38,'US English','Add/Edit','Events Calendar','Events calendars are used on many intranets to keep track of internal dates that affect a whole organization. Also events calendars on consumer sites are a great way to let your customers know what events you\'ll be attending and what promotions you\'ll be having.\r\n\r\n<b>Title</b>\r\nWhat is the title of this events calendar?\r\n\r\n<b>Display the title?</b>\r\nDo you wish to disply the title?\r\n\r\n<b>Process macros?</b>\r\nDo you wish to process WebGUI macros? Unchecking this box will not process macros and will speed up page execution.\r\n\r\n<b>Description</b>\r\nBriefly describe what this events calendar details.\r\n\r\n<b>Add / Edit Events</b>\r\nOn the edit screen you\'ll notice that there are options to add, edit, and delete the events in your events calendar. The properties for events are <i>name</i>, <i>description</i>, <i>start date</i>,  and <i>end date</i>.\r\n\r\n<i>Note:</i> Events that have already happened will not be displayed on the events calendar.','14,21,19');
INSERT INTO help VALUES (40,'US English','Add/Edit','F.A.Q.','It seems that almost every web site, intranet, and extranet in the world has a frequently asked questions area. This widget helps you build one too.\r\n\r\n<b>Title</b>\r\nWhat is the title for this FAQ section?\r\n\r\n<b>Display the title?</b>\r\nDo you wish to disply the title?\r\n\r\n<b>Process macros?</b>\r\nDo you wish to process WebGUI macros? Unchecking this box will not process macros and will speed up page execution.\r\n\r\n<b>Description</b>\r\nBriefly describe what this FAQ covers.\r\n\r\n<b>Add / Edit Questions</b>\r\nOn the edit screen you\'ll notice options for adding, editing, deleting, and reordering the questions in your FAQ. The two properties of FAQ questions are <i>question</i> and <i>answer</i>.\r\n','14,21,19');
INSERT INTO help VALUES (11,'US English','Edit','File Settings','<b>Path to WebGUI Extras</b>\r\nThe web-path to the directory containing WebGUI images and javascript files.\r\n\r\n<b>Maximum Attachment Size</b>\r\nThe maximum size of files allowed to be uploaded to this site. This applies to all widgets that allow uploaded files and images (like Article and User Contributions). This size is measured in kilobytes.\r\n\r\n<b>Web Attachment Path</b>\r\nThe web-path of the directory where attachments are to be stored.\r\n\r\n<b>Server Attachment Path</b>\r\nThe local path of the directory where attachments are to be stored. (Perhaps /var/www/public/uploads) Be sure that the web server has the rights to write to that directory.\r\n','12');
INSERT INTO help VALUES (2,'US English','Edit','Authentication Settings','<b>Anonymous Registration</b>\r\nDo you wish visitors to your site to be able to register themselves?\r\n\r\n<b>Authentication Method (default)</b>\r\nWhat should the default authentication method be for new accounts that are created? The two available options are WebGUI and LDAP. WebGUI authentication means that the users will authenticate against the username and password stored in the WebGUI database. LDAP authentication means that users will authenticate against an external LDAP server.\r\n\r\n<i>Note:</i> Authentication settings can be customized on a per user basis.\r\n\r\n<b>Username Binding</b>\r\nBind the WebGUI username to the LDAP Identity. This requires the user to have the same username in WebGUI as they specified during the Anonymous Registration process. It also means that they won\'t be able to change their username later. This only in effect if the user is authenticating against LDAP.\r\n\r\n<b>LDAP URL (default)</b>\r\nThe default url to your LDAP server. The LDAP URL takes the form of <b>ldap://[server]:[port]/[base DN]</b>. Example: ldap://ldap.mycompany.com:389/o=MyCompany.\r\n\r\n<b>LDAP Identity</b>\r\nThe LDAP Identity is the unique identifier in the LDAP server that the user will be identified against. Often this field is <b>shortname</b>, which takes the form of first initial + last name. Example: jdoe. Therefore if you specify the LDAP identity to be <i>shortname</i> then Jon Doe would enter <i>jdoe</i> during the registration process.\r\n\r\n<b>LDAP Identity Name</b>\r\nThe label used to describe the LDAP Identity to the user. For instance, some companies use an LDAP server for their proxy server users to authenticate against. In the documentation or training already provided to their users, the LDAP identity is known as their <i>Web Username</b>. So you could enter that label here for consitency.\r\n\r\n<b>LDAP Password Name</b>\r\nJust as the LDAP Identity Name is a label, so is the LDAP Password Name. Use this label as you would LDAP Identity Name.\r\n\r\n','12');
INSERT INTO help VALUES (44,'US English','Add/Edit','User Submission System','User submission systems are a great way to add a sense of community to any site as well as get free content from your users.\r\n\r\n<b>Title</b>\r\nWhat is the title for this user submission system?\r\n\r\n<b>Display the title?</b>\r\nDo you wish to disply the title?\r\n\r\n<b>Process macros?</b>\r\nDo you wish to process WebGUI macros? Unchecking this box will not process macros and will speed up page execution.\r\n\r\n<b>Description</b>\r\nBriefly describe why this user submission system is here and what should be submitted to it.\r\n\r\n<b>Who can contribute?</b>\r\nWhat group is allowed to contribute content?\r\n\r\n<b>Submissions Per Page</b>\r\nHow many submissions should be listed per page in the submissions index?\r\n\r\n<b>Default Status</b>\r\nShould submissions be set to <i>approved</i>, <i>pending</i>, or <i>denied</i> by default?\r\n\r\n<i>Note:</i> If you set the default status to pending, then be prepared to monitor the pending queue under the Admin menu.\r\n','14,21');
INSERT INTO help VALUES (6,'US English','Edit','Company Information','<b>Company Name</b>\r\nThe name of your company. It will appear on all emails and anywhere you use the Company Name macro.\r\n\r\n<b>Company Email Address</b>\r\nA general email address at your company. This is the address that all automated messages will come from. It can also be used via the WebGUI macro system.\r\n\r\n<b>Company URL</b>\r\nThe primary URL of your company. This will appear on all automated emails sent from the WebGUI system. It is also available via the WebGUI macro system.\r\n','12');
INSERT INTO help VALUES (46,'US English','Empty','Trash','If you choose to empty your trash, any items contained in it will be lost forever. If you\'re unsure about a few items, it might be best to cut them to your clipboard before you empty the trash.','0');

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
  language varchar(30) NOT NULL default 'English',
  message text,
  PRIMARY KEY  (internationalId,language)
) TYPE=MyISAM;

#
# Dumping data for table 'international'
#

INSERT INTO international VALUES (1,'English','Add content...');
INSERT INTO international VALUES (2,'English','Page');
INSERT INTO international VALUES (3,'English','Paste from clipboard...');
INSERT INTO international VALUES (4,'English','Manage settings.');
INSERT INTO international VALUES (5,'English','Manage groups.');
INSERT INTO international VALUES (6,'English','Manage styles.');
INSERT INTO international VALUES (7,'English','Manage users.');
INSERT INTO international VALUES (8,'English','View page not found.');
INSERT INTO international VALUES (9,'English','View clipboard.');
INSERT INTO international VALUES (10,'English','View trash.');
INSERT INTO international VALUES (11,'English','Empy trash.');
INSERT INTO international VALUES (12,'English','Turn admin off.');
INSERT INTO international VALUES (13,'English','View help index.');
INSERT INTO international VALUES (14,'English','View pending submissions.');
INSERT INTO international VALUES (15,'English','January');
INSERT INTO international VALUES (16,'English','February');
INSERT INTO international VALUES (17,'English','March');
INSERT INTO international VALUES (18,'English','April');
INSERT INTO international VALUES (19,'English','May');
INSERT INTO international VALUES (20,'English','June');
INSERT INTO international VALUES (21,'English','July');
INSERT INTO international VALUES (22,'English','August');
INSERT INTO international VALUES (23,'English','September');
INSERT INTO international VALUES (24,'English','October');
INSERT INTO international VALUES (25,'English','November');
INSERT INTO international VALUES (26,'English','December');
INSERT INTO international VALUES (27,'English','Sunday');
INSERT INTO international VALUES (28,'English','Monday');
INSERT INTO international VALUES (29,'English','Tuesday');
INSERT INTO international VALUES (30,'English','Wednesday');
INSERT INTO international VALUES (31,'English','Thursday');
INSERT INTO international VALUES (32,'English','Friday');
INSERT INTO international VALUES (33,'English','Saturday');
INSERT INTO international VALUES (34,'English','set date');
INSERT INTO international VALUES (35,'English','Administrative Function');
INSERT INTO international VALUES (36,'English','You must be an administrator to perform this function. Please contact one of your administrators. The following is a list of the administrators for this system:');
INSERT INTO international VALUES (37,'English','Permission Denied!');
INSERT INTO international VALUES (38,'English','You do not have sufficient privileges to perform this operation. Please <a href=\"^\\?op=displayLogin\">log in with an account</a> that has sufficient privileges before attempting this operation.');
INSERT INTO international VALUES (39,'English','You do not have sufficient privileges to access this page.');
INSERT INTO international VALUES (41,'English','You\'re attempting to remove a vital component of the WebGUI system. If you were allowed to continue WebGUI may cease to function.');
INSERT INTO international VALUES (40,'English','Vital Component');
INSERT INTO international VALUES (42,'English','Please Confirm');
INSERT INTO international VALUES (43,'English','Are you certain that you wish to delete this content?');
INSERT INTO international VALUES (44,'English','Yes, I\'m sure.');
INSERT INTO international VALUES (45,'English','No, I made a mistake.');
INSERT INTO international VALUES (46,'English','My Account');
INSERT INTO international VALUES (47,'English','Home');
INSERT INTO international VALUES (48,'English','Hello');
INSERT INTO international VALUES (49,'English','Click <a href=\"^\\?op=logout\">here</a> to log out.');
INSERT INTO international VALUES (50,'English','Username');
INSERT INTO international VALUES (51,'English','Password');
INSERT INTO international VALUES (52,'English','login');
INSERT INTO international VALUES (53,'English','Make Page Printable');
INSERT INTO international VALUES (54,'English','Create Account');
INSERT INTO international VALUES (55,'English','Password (confirm)');
INSERT INTO international VALUES (56,'English','Email Address');
INSERT INTO international VALUES (57,'English','This is only necessary if you wish to use features that require Email.');
INSERT INTO international VALUES (58,'English','I already have an account.');
INSERT INTO international VALUES (59,'English','I forgot my password.');
INSERT INTO international VALUES (60,'English','Are you certain you want to deactivate your account. If you proceed your account information will be lost permanently.');
INSERT INTO international VALUES (61,'English','Update Account Information');
INSERT INTO international VALUES (62,'English','save');
INSERT INTO international VALUES (63,'English','Turn admin on.');
INSERT INTO international VALUES (64,'English','Log out.');
INSERT INTO international VALUES (65,'English','Please deactivate my account permanently.');
INSERT INTO international VALUES (66,'English','Log In');
INSERT INTO international VALUES (67,'English','Create a new account.');
INSERT INTO international VALUES (68,'English','The account information you supplied is invalid. Either the account does not exist or the username/password combination was incorrect.');
INSERT INTO international VALUES (69,'English','Please contact your system administrator for assistance.');
INSERT INTO international VALUES (70,'English','Error');
INSERT INTO international VALUES (71,'English','Recover password');
INSERT INTO international VALUES (72,'English','recover');
INSERT INTO international VALUES (73,'English','Log in.');
INSERT INTO international VALUES (74,'English','Account Information');
INSERT INTO international VALUES (75,'English','Your account information has been sent to your email address.');
INSERT INTO international VALUES (76,'English','That email address is not in our databases.');
INSERT INTO international VALUES (77,'English','That account name is already in use by another member of this site. Please try a different username. The following are some suggestions:');
INSERT INTO international VALUES (78,'English','Your passwords did not match. Please try again.');
INSERT INTO international VALUES (79,'English','Cannot connect to LDAP server.');
INSERT INTO international VALUES (80,'English','Account created successfully!');
INSERT INTO international VALUES (81,'English','Account updated successfully!');
INSERT INTO international VALUES (82,'English','Administrative functions...');
INSERT INTO international VALUES (83,'English','Add Group');
INSERT INTO international VALUES (84,'English','Group Name');
INSERT INTO international VALUES (85,'English','Description');
INSERT INTO international VALUES (86,'English','Are you certain you wish to delete this group? Beware that deleting a group is permanent and will remove all privileges associated with this group.');
INSERT INTO international VALUES (87,'English','Edit Group');
INSERT INTO international VALUES (88,'English','Users In Group');
INSERT INTO international VALUES (89,'English','Groups');
INSERT INTO international VALUES (90,'English','Add new group.');
INSERT INTO international VALUES (91,'English','Previous Page');
INSERT INTO international VALUES (92,'English','Next Page');
INSERT INTO international VALUES (93,'English','Help');
INSERT INTO international VALUES (94,'English','See also');
INSERT INTO international VALUES (95,'English','Help Index');
INSERT INTO international VALUES (96,'English','Sorted By Action');
INSERT INTO international VALUES (97,'English','Sorted by Object');
INSERT INTO international VALUES (98,'English','Add Page');
INSERT INTO international VALUES (99,'English','Title');
INSERT INTO international VALUES (100,'English','Meta Tags');
INSERT INTO international VALUES (101,'English','Are you certain that you wish to delete this page, its content, and all items under it?');
INSERT INTO international VALUES (102,'English','Edit Page');
INSERT INTO international VALUES (103,'English','Page Specifics');
INSERT INTO international VALUES (104,'English','Page URL');
INSERT INTO international VALUES (105,'English','Style');
INSERT INTO international VALUES (106,'English','Check to give this style to all sub-pages.');
INSERT INTO international VALUES (107,'English','Privileges');
INSERT INTO international VALUES (108,'English','Owner');
INSERT INTO international VALUES (109,'English','Owner can view?');
INSERT INTO international VALUES (110,'English','Owner can edit?');
INSERT INTO international VALUES (111,'English','Group');
INSERT INTO international VALUES (112,'English','Group can view?');
INSERT INTO international VALUES (113,'English','Group can edit?');
INSERT INTO international VALUES (114,'English','Anybody can view?');
INSERT INTO international VALUES (115,'English','Anybody can edit?');
INSERT INTO international VALUES (116,'English','Check to give these privileges to all sub-pages.');
INSERT INTO international VALUES (117,'English','Edit Authentication Settings');
INSERT INTO international VALUES (118,'English','Anonymous Registration');
INSERT INTO international VALUES (119,'English','Authentication Method (default)');
INSERT INTO international VALUES (120,'English','LDAP URL (default)');
INSERT INTO international VALUES (121,'English','LDAP Identity (default)');
INSERT INTO international VALUES (122,'English','LDAP Identity Name');
INSERT INTO international VALUES (123,'English','LDAP Password Name');
INSERT INTO international VALUES (124,'English','Edit Company Information');
INSERT INTO international VALUES (125,'English','Company Name');
INSERT INTO international VALUES (126,'English','Company Email Address');
INSERT INTO international VALUES (127,'English','Company URL');
INSERT INTO international VALUES (128,'English','Edit File Settings');
INSERT INTO international VALUES (129,'English','Path to WebGUI Extras');
INSERT INTO international VALUES (130,'English','Maximum Attachment Size');
INSERT INTO international VALUES (131,'English','Web Attachment Path');
INSERT INTO international VALUES (132,'English','Server Attachment Path');
INSERT INTO international VALUES (133,'English','Edit Mail Settings');
INSERT INTO international VALUES (134,'English','Recover Password Message');
INSERT INTO international VALUES (135,'English','SMTP Server');
INSERT INTO international VALUES (136,'English','Home Page');
INSERT INTO international VALUES (137,'English','Page Not Found Page');
INSERT INTO international VALUES (138,'English','Yes');
INSERT INTO international VALUES (139,'English','No');
INSERT INTO international VALUES (140,'English','Edit Miscellaneous Settings');
INSERT INTO international VALUES (141,'English','Not Found Page');
INSERT INTO international VALUES (142,'English','Session Timeout');
INSERT INTO international VALUES (143,'English','Manage Settings');
INSERT INTO international VALUES (144,'English','View statistics.');
INSERT INTO international VALUES (145,'English','WebGUI Build Version');
INSERT INTO international VALUES (146,'English','Active Sessions');
INSERT INTO international VALUES (147,'English','Viewable Pages');
INSERT INTO international VALUES (148,'English','Viewable Widgets');
INSERT INTO international VALUES (149,'English','Users');
INSERT INTO international VALUES (150,'English','Add Style');
INSERT INTO international VALUES (151,'English','Style Name');
INSERT INTO international VALUES (152,'English','Header');
INSERT INTO international VALUES (153,'English','Footer');
INSERT INTO international VALUES (154,'English','Style Sheet');
INSERT INTO international VALUES (155,'English','Are you certain you wish to delete this style and migrate all pages using this style to the \"Fail Safe\" style?');
INSERT INTO international VALUES (156,'English','Edit Style');
INSERT INTO international VALUES (157,'English','Styles');
INSERT INTO international VALUES (158,'English','Add a new style.');
INSERT INTO international VALUES (159,'English','Pending Submissions');
INSERT INTO international VALUES (160,'English','Date Submitted');
INSERT INTO international VALUES (161,'English','Submitted By');
INSERT INTO international VALUES (162,'English','Are you certain that you wish to purge all the pages and widgets in the trash?');
INSERT INTO international VALUES (163,'English','Add User');
INSERT INTO international VALUES (164,'English','Authentication Method');
INSERT INTO international VALUES (165,'English','LDAP URL');
INSERT INTO international VALUES (166,'English','Connect DN');
INSERT INTO international VALUES (167,'English','Are you certain you want to delete this user? Be warned that all this user\'s information will be lost permanently if you choose to proceed.');
INSERT INTO international VALUES (168,'English','Edit User');
INSERT INTO international VALUES (169,'English','Add a new user.');
INSERT INTO international VALUES (170,'English','search');
INSERT INTO international VALUES (171,'English','rich edit');
INSERT INTO international VALUES (172,'English','Article');
INSERT INTO international VALUES (173,'English','Add Article');
INSERT INTO international VALUES (174,'English','Display the title?');
INSERT INTO international VALUES (175,'English','Process macros?');
INSERT INTO international VALUES (176,'English','Start Date');
INSERT INTO international VALUES (177,'English','End Date');
INSERT INTO international VALUES (178,'English','Body');
INSERT INTO international VALUES (179,'English','Image');
INSERT INTO international VALUES (180,'English','Link Title');
INSERT INTO international VALUES (181,'English','Link URL');
INSERT INTO international VALUES (182,'English','Attachment');
INSERT INTO international VALUES (183,'English','Convert carriage returns?');
INSERT INTO international VALUES (184,'English','(Check if you aren\'t adding &lt;br&gt; manually.)');
INSERT INTO international VALUES (185,'English','Edit Article');
INSERT INTO international VALUES (186,'English','Delete');
INSERT INTO international VALUES (187,'English','Events Calendar');
INSERT INTO international VALUES (188,'English','Add Events Calendar');
INSERT INTO international VALUES (189,'English','Happens only once.');
INSERT INTO international VALUES (190,'English','Day');
INSERT INTO international VALUES (191,'English','Week');
INSERT INTO international VALUES (192,'English','Add Event');
INSERT INTO international VALUES (193,'English','Recurs every');
INSERT INTO international VALUES (194,'English','until');
INSERT INTO international VALUES (195,'English','Are you certain that you want to delete this event');
INSERT INTO international VALUES (197,'English','Edit Events Calendar');
INSERT INTO international VALUES (196,'English','<b>and</b> all of its recurring events');
INSERT INTO international VALUES (198,'English','Edit Event');
INSERT INTO international VALUES (199,'English','Extra Column');
INSERT INTO international VALUES (200,'English','Add Extra Column');
INSERT INTO international VALUES (201,'English','Spacer');
INSERT INTO international VALUES (202,'English','Width');
INSERT INTO international VALUES (203,'English','StyleSheet Class');
INSERT INTO international VALUES (204,'English','Edit Extra Column');
INSERT INTO international VALUES (205,'English','F.A.Q.');
INSERT INTO international VALUES (206,'English','Add F.A.Q.');
INSERT INTO international VALUES (207,'English','Add Question');
INSERT INTO international VALUES (208,'English','Question');
INSERT INTO international VALUES (209,'English','Answer');
INSERT INTO international VALUES (211,'English','Edit F.A.Q.');
INSERT INTO international VALUES (210,'English','Are you certain that you want to delete this question?');
INSERT INTO international VALUES (212,'English','Add a new question.');
INSERT INTO international VALUES (213,'English','Edit Question');
INSERT INTO international VALUES (214,'English','Link List');
INSERT INTO international VALUES (215,'English','Add Link');
INSERT INTO international VALUES (216,'English','URL');
INSERT INTO international VALUES (217,'English','Are you certain that you want to delete this link?');
INSERT INTO international VALUES (218,'English','Edit Link List');
INSERT INTO international VALUES (219,'English','Add Link List');
INSERT INTO international VALUES (220,'English','Edit Link');
INSERT INTO international VALUES (221,'English','Add a new link.');
INSERT INTO international VALUES (222,'English','Add Message Board');
INSERT INTO international VALUES (223,'English','Message Board');
INSERT INTO international VALUES (224,'English','Who can post?');
INSERT INTO international VALUES (225,'English','Messages Per Page');
INSERT INTO international VALUES (226,'English','Edit Timeout');
INSERT INTO international VALUES (227,'English','Edit Message Board');
INSERT INTO international VALUES (228,'English','Editing Message...');
INSERT INTO international VALUES (229,'English','Subject');
INSERT INTO international VALUES (230,'English','Message');
INSERT INTO international VALUES (231,'English','Posting New Message...');
INSERT INTO international VALUES (232,'English','no subject');
INSERT INTO international VALUES (233,'English','(eom)');
INSERT INTO international VALUES (234,'English','Posting Reply...');
INSERT INTO international VALUES (235,'English','Edit Message');
INSERT INTO international VALUES (236,'English','Post Reply');
INSERT INTO international VALUES (237,'English','Subject:');
INSERT INTO international VALUES (238,'English','Author:');
INSERT INTO international VALUES (239,'English','Date:');
INSERT INTO international VALUES (240,'English','Message ID:');
INSERT INTO international VALUES (241,'English','Previous Thread');
INSERT INTO international VALUES (242,'English','Back To Message List');
INSERT INTO international VALUES (243,'English','Next Thread');
INSERT INTO international VALUES (244,'English','Author');
INSERT INTO international VALUES (245,'English','Date');
INSERT INTO international VALUES (246,'English','Post New Message');
INSERT INTO international VALUES (247,'English','Thread Started');
INSERT INTO international VALUES (248,'English','Replies');
INSERT INTO international VALUES (249,'English','Last Reply');
INSERT INTO international VALUES (250,'English','Poll');
INSERT INTO international VALUES (251,'English','Add Poll');
INSERT INTO international VALUES (252,'English','Active');
INSERT INTO international VALUES (253,'English','Who can vote?');
INSERT INTO international VALUES (254,'English','Graph Width');
INSERT INTO international VALUES (255,'English','Question');
INSERT INTO international VALUES (256,'English','Answers');
INSERT INTO international VALUES (257,'English','(Enter one answer per line. No more than 20.)');
INSERT INTO international VALUES (258,'English','Edit Poll');
INSERT INTO international VALUES (259,'English','SQL Report');
INSERT INTO international VALUES (260,'English','Add SQL Report');
INSERT INTO international VALUES (261,'English','Template');
INSERT INTO international VALUES (262,'English','Query');
INSERT INTO international VALUES (263,'English','DSN');
INSERT INTO international VALUES (264,'English','Database User');
INSERT INTO international VALUES (265,'English','Database Password');
INSERT INTO international VALUES (266,'English','Edit SQL Report');
INSERT INTO international VALUES (267,'English','Error: The DSN specified is of an improper format.');
INSERT INTO international VALUES (268,'English','Error: The SQL specified is of an improper format.');
INSERT INTO international VALUES (269,'English','Error: There was a problem with the query.');
INSERT INTO international VALUES (270,'English','Error: Could not connect to the database.');
INSERT INTO international VALUES (271,'English','Syndicated Content');
INSERT INTO international VALUES (272,'English','Add Syndicated Content');
INSERT INTO international VALUES (273,'English','URL to RSS File');
INSERT INTO international VALUES (274,'English','Edit Syndicated Content');
INSERT INTO international VALUES (275,'English','Last Fetched');
INSERT INTO international VALUES (276,'English','Current Content');
INSERT INTO international VALUES (277,'English','User Submission System');
INSERT INTO international VALUES (278,'English','Add User Submission System');
INSERT INTO international VALUES (279,'English','Who can contribute?');
INSERT INTO international VALUES (280,'English','Submissions Per Page');
INSERT INTO international VALUES (281,'English','Approved');
INSERT INTO international VALUES (282,'English','Denied');
INSERT INTO international VALUES (283,'English','Pending');
INSERT INTO international VALUES (284,'English','Default Status');
INSERT INTO international VALUES (285,'English','Add Submission');
INSERT INTO international VALUES (286,'English','(Uncheck if you\'re writing an HTML submission.)');
INSERT INTO international VALUES (287,'English','Date Submitted');
INSERT INTO international VALUES (288,'English','Status');
INSERT INTO international VALUES (289,'English','Edit/Delete');
INSERT INTO international VALUES (290,'English','Untitiled');
INSERT INTO international VALUES (291,'English','Are you certain you wish to delete this submission?');
INSERT INTO international VALUES (292,'English','Edit User Submission System');
INSERT INTO international VALUES (293,'English','Edit Submission');
INSERT INTO international VALUES (294,'English','Post New Submission');
INSERT INTO international VALUES (295,'English','Date Submitted');
INSERT INTO international VALUES (296,'English','Submitted By');
INSERT INTO international VALUES (297,'English','Submitted By:');
INSERT INTO international VALUES (298,'English','Date Submitted:');
INSERT INTO international VALUES (299,'English','Approve');
INSERT INTO international VALUES (300,'English','Leave Pending');
INSERT INTO international VALUES (301,'English','Deny');
INSERT INTO international VALUES (302,'English','Edit');
INSERT INTO international VALUES (303,'English','Return To Submissions List');
INSERT INTO international VALUES (304,'English','Language');
INSERT INTO international VALUES (305,'English','Reset votes.');
INSERT INTO international VALUES (203,'Deutsche','StyleSheet Class');
INSERT INTO international VALUES (202,'Deutsche','Breite');
INSERT INTO international VALUES (201,'Deutsche','Platzhalter');
INSERT INTO international VALUES (200,'Deutsche','Extra Spalte hinzufügen');
INSERT INTO international VALUES (199,'Deutsche','Extra Spalte');
INSERT INTO international VALUES (198,'Deutsche','Veranstaltung bearbeiten');
INSERT INTO international VALUES (197,'Deutsche','Veranstaltungskalender bearbeiten');
INSERT INTO international VALUES (196,'Deutsche','<b>und</b> alle seine Wiederholungen löschen wollen?');
INSERT INTO international VALUES (195,'Deutsche','\"Sind Sie sicher, dass Sie diesen Termin\"');
INSERT INTO international VALUES (194,'Deutsche','bis');
INSERT INTO international VALUES (193,'Deutsche','Wiederholt sich');
INSERT INTO international VALUES (192,'Deutsche','Termin hinzufügen');
INSERT INTO international VALUES (191,'Deutsche','Woche');
INSERT INTO international VALUES (190,'Deutsche','Tag');
INSERT INTO international VALUES (189,'Deutsche','Einmaliges Ereignis');
INSERT INTO international VALUES (188,'Deutsche','Veranstaltungskalender hinzufügen');
INSERT INTO international VALUES (187,'Deutsche','Veranstaltungskalender');
INSERT INTO international VALUES (186,'Deutsche','Löschen');
INSERT INTO international VALUES (185,'Deutsche','Artikel bearbeiten');
INSERT INTO international VALUES (184,'Deutsche','\"(Bitte anklicken, falls Sie nicht &lt;br&gt; in Ihrem Text hinzufügen.)\"');
INSERT INTO international VALUES (183,'Deutsche','Carriage Return beachten?');
INSERT INTO international VALUES (180,'Deutsche','Link Titel');
INSERT INTO international VALUES (181,'Deutsche','Link URL');
INSERT INTO international VALUES (182,'Deutsche','Dateianhang');
INSERT INTO international VALUES (179,'Deutsche','Bild');
INSERT INTO international VALUES (175,'Deutsche','Makros ausführen?');
INSERT INTO international VALUES (176,'Deutsche','Start Datum');
INSERT INTO international VALUES (177,'Deutsche','Ende Datum');
INSERT INTO international VALUES (178,'Deutsche','Text');
INSERT INTO international VALUES (174,'Deutsche','Titel anzeigen?');
INSERT INTO international VALUES (173,'Deutsche','Artikel hinzufügen');
INSERT INTO international VALUES (170,'Deutsche','suchen');
INSERT INTO international VALUES (171,'Deutsche','Bearbeiten mit Attributen');
INSERT INTO international VALUES (172,'Deutsche','Artikel');
INSERT INTO international VALUES (169,'Deutsche','Neuen Benutzer hinzufügen');
INSERT INTO international VALUES (168,'Deutsche','Benutzer bearbeiten');
INSERT INTO international VALUES (167,'Deutsche','\"Sind Sie sicher, dass sie diesen Benutzer löschen möchten? Die Benutzerinformation geht damit endgültig verloren.\"');
INSERT INTO international VALUES (166,'Deutsche','Connect DN');
INSERT INTO international VALUES (165,'Deutsche','LDAP URL');
INSERT INTO international VALUES (164,'Deutsche','Authentifizierungsmethode');
INSERT INTO international VALUES (163,'Deutsche','Benutzer hinzufügen');
INSERT INTO international VALUES (162,'Deutsche','\"Sind Sie sicher, dass Sie alle Seiten und Widgets im Mülleimer löschen möchten?\"');
INSERT INTO international VALUES (160,'Deutsche','Erstellungsdatum');
INSERT INTO international VALUES (161,'Deutsche','Erstellt von');
INSERT INTO international VALUES (159,'Deutsche','Ausstehende Beiträge');
INSERT INTO international VALUES (158,'Deutsche','Neuen Stil hinzufügen');
INSERT INTO international VALUES (156,'Deutsche','Stil bearbeiten');
INSERT INTO international VALUES (157,'Deutsche','Stile');
INSERT INTO international VALUES (155,'Deutsche','\"Sind Sie sicher, dass Sie diesen Stil löschen und alle Seiten die diesen Stil benutzen in den Stil \"\"Fail Safe\"\" überführen wollen?\"');
INSERT INTO international VALUES (154,'Deutsche','Style Sheet');
INSERT INTO international VALUES (153,'Deutsche','Fußzeile');
INSERT INTO international VALUES (152,'Deutsche','Kopfzeile');
INSERT INTO international VALUES (151,'Deutsche','Stil Name');
INSERT INTO international VALUES (148,'Deutsche','sichtbare Widgets');
INSERT INTO international VALUES (149,'Deutsche','Benutzer');
INSERT INTO international VALUES (150,'Deutsche','Stil hinzufügen');
INSERT INTO international VALUES (147,'Deutsche','sichtbare Seiten');
INSERT INTO international VALUES (146,'Deutsche','Aktive Sitzungen');
INSERT INTO international VALUES (145,'Deutsche','WebGUI Build Version');
INSERT INTO international VALUES (144,'Deutsche','Auswertungen anschauen');
INSERT INTO international VALUES (143,'Deutsche','Einstellungen verwalten');
INSERT INTO international VALUES (142,'Deutsche','Sitzungs Zeitüberschreitung');
INSERT INTO international VALUES (141,'Deutsche','\"\"\"Nicht gefunden\"\" Seite\"');
INSERT INTO international VALUES (138,'Deutsche','Ja');
INSERT INTO international VALUES (139,'Deutsche','Nein');
INSERT INTO international VALUES (140,'Deutsche','Sonstige Einstellungen bearbeiten');
INSERT INTO international VALUES (137,'Deutsche','\"\"\"Seite wurde nicht gefunden\"\" Seite\"');
INSERT INTO international VALUES (135,'Deutsche','SMTP Server');
INSERT INTO international VALUES (136,'Deutsche','Homepage');
INSERT INTO international VALUES (134,'Deutsche','Passwortmeldung wiederherstellen');
INSERT INTO international VALUES (133,'Deutsche','Maileinstellungen bearbeiten');
INSERT INTO international VALUES (132,'Deutsche','Pfad für Dateianhänge auf dem Server');
INSERT INTO international VALUES (131,'Deutsche','Pfad für Dateianhänge im Web');
INSERT INTO international VALUES (129,'Deutsche','Pfad zu WebGUI Extras');
INSERT INTO international VALUES (130,'Deutsche','Maximale Dateigröße für Anhänge');
INSERT INTO international VALUES (128,'Deutsche','Dateieinstellungen bearbeiten');
INSERT INTO international VALUES (127,'Deutsche','Webseite der Firma');
INSERT INTO international VALUES (126,'Deutsche','Emailadresse der Firma');
INSERT INTO international VALUES (125,'Deutsche','Firmenname');
INSERT INTO international VALUES (124,'Deutsche','Firmeninformationen bearbeiten');
INSERT INTO international VALUES (123,'Deutsche','LDAP Passwort Name');
INSERT INTO international VALUES (122,'Deutsche','LDAP Identitäts-Name');
INSERT INTO international VALUES (121,'Deutsche','LDAP Identität (Standard)');
INSERT INTO international VALUES (120,'Deutsche','LDAP URL (Standard)');
INSERT INTO international VALUES (119,'Deutsche','Authentifizierungsmethode (Standard)');
INSERT INTO international VALUES (118,'Deutsche','anonyme Registrierung');
INSERT INTO international VALUES (117,'Deutsche','Authentifizierungseinstellungen bearbeiten');
INSERT INTO international VALUES (116,'Deutsche','Rechte an alle nachfolgenden Seiten weitergeben.');
INSERT INTO international VALUES (115,'Deutsche','Kann jeder bearbeiten?');
INSERT INTO international VALUES (114,'Deutsche','Kann jeder anschauen?');
INSERT INTO international VALUES (113,'Deutsche','Gruppe kann bearbeiten?');
INSERT INTO international VALUES (112,'Deutsche','Gruppe kann anschauen?');
INSERT INTO international VALUES (111,'Deutsche','Gruppe');
INSERT INTO international VALUES (110,'Deutsche','Besitzer kann bearbeiten?');
INSERT INTO international VALUES (109,'Deutsche','Besitzer kann anschauen?');
INSERT INTO international VALUES (108,'Deutsche','Besitzer');
INSERT INTO international VALUES (107,'Deutsche','Rechte');
INSERT INTO international VALUES (106,'Deutsche','Stil an alle nachfolgenden Seiten weitergeben.');
INSERT INTO international VALUES (105,'Deutsche','Stil');
INSERT INTO international VALUES (104,'Deutsche','URL der Seite');
INSERT INTO international VALUES (103,'Deutsche','Seitenspezifikation');
INSERT INTO international VALUES (102,'Deutsche','Seite bearbeiten');
INSERT INTO international VALUES (101,'Deutsche','\"Sind Sie sicher, dass Sie diese Seite und ihren kompletten Inhalt darunter löschen möchten?\"');
INSERT INTO international VALUES (100,'Deutsche','Meta Tags');
INSERT INTO international VALUES (99,'Deutsche','Titel');
INSERT INTO international VALUES (98,'Deutsche','Seite hinzufügen');
INSERT INTO international VALUES (97,'Deutsche','Sortiert nach Objekt');
INSERT INTO international VALUES (96,'Deutsche','Sortiert nach Aktion');
INSERT INTO international VALUES (95,'Deutsche','Hilfe');
INSERT INTO international VALUES (94,'Deutsche','Siehe auch');
INSERT INTO international VALUES (93,'Deutsche','Hilfe');
INSERT INTO international VALUES (92,'Deutsche','Nächste Seite');
INSERT INTO international VALUES (91,'Deutsche','Vorherige Seite');
INSERT INTO international VALUES (90,'Deutsche','Neue Gruppe hinzufügen');
INSERT INTO international VALUES (89,'Deutsche','Gruppen');
INSERT INTO international VALUES (88,'Deutsche','Benutzer in dieser Gruppe');
INSERT INTO international VALUES (87,'Deutsche','Gruppe bearbeiten');
INSERT INTO international VALUES (86,'Deutsche','\"Sind Sie sicher, dass Sie diese Gruppe löschen möchten? Denken Sie daran, dass diese Gruppe und die zugehörige Rechtesstruktur endgültig gelöscht wird.\"');
INSERT INTO international VALUES (85,'Deutsche','Beschreibung');
INSERT INTO international VALUES (84,'Deutsche','Gruppenname');
INSERT INTO international VALUES (82,'Deutsche','Administrative Funktionen ...');
INSERT INTO international VALUES (83,'Deutsche','Gruppe hinzufügen');
INSERT INTO international VALUES (81,'Deutsche','Benutzerkonto wurde aktualisiert');
INSERT INTO international VALUES (80,'Deutsche','Benutzerkonto wurde angelegt');
INSERT INTO international VALUES (79,'Deutsche','Verbindung zum LDAP-Server konnte nicht hergestellt werden.');
INSERT INTO international VALUES (78,'Deutsche','Die Passworte unterscheiden sich. Bitte versuchen Sie es noch einmal.');
INSERT INTO international VALUES (77,'Deutsche','Ein anderes Mitglied dieser Seiten benutzt bereits diesen Namen. Bitte wählen Sie einen anderen Benutzernamen. Hier sind einige Vorschläge:');
INSERT INTO international VALUES (76,'Deutsche','Ihre Emailadresse ist nicht in unserer Datenbank.');
INSERT INTO international VALUES (75,'Deutsche','Ihre Benutzerkonteninformation wurde an Ihre Emailadresse geschickt');
INSERT INTO international VALUES (74,'Deutsche','Benutzerkonteninformation');
INSERT INTO international VALUES (73,'Deutsche','Anmelden');
INSERT INTO international VALUES (72,'Deutsche','wiederherstellen');
INSERT INTO international VALUES (71,'Deutsche','Passwort wiederherstellen');
INSERT INTO international VALUES (70,'Deutsche','Fehler');
INSERT INTO international VALUES (69,'Deutsche','Bitten Sie Ihren Systemadministrator um Hilfe.');
INSERT INTO international VALUES (68,'Deutsche','\"Die Benutzerkontoinformationen die Sie eingegeben haben, sind ungültig.  Entweder existiert das Konto nicht, oder die Kombination aus Benutzername und Passwort  ist falsch.\"');
INSERT INTO international VALUES (67,'Deutsche','Neues Benutzerkonto einrichten');
INSERT INTO international VALUES (66,'Deutsche','Anmelden');
INSERT INTO international VALUES (65,'Deutsche','Benutzerkonto endgültig deaktivieren');
INSERT INTO international VALUES (64,'Deutsche','Abmelden');
INSERT INTO international VALUES (62,'Deutsche','sichern');
INSERT INTO international VALUES (63,'Deutsche','Administrationsmodus einschalten');
INSERT INTO international VALUES (61,'Deutsche','Benutzerkontendetails aktualisieren');
INSERT INTO international VALUES (60,'Deutsche','\"Sind Sie sicher, dass Sie dieses Benutzerkonto deaktivieren möchten? Wenn Sie fortfahren sind Ihre Konteninformationen endgültig verloren.\"');
INSERT INTO international VALUES (59,'Deutsche','Ich habe mein Passwort vergessen');
INSERT INTO international VALUES (58,'Deutsche','Ich besitze bereits ein Benutzerkonto.');
INSERT INTO international VALUES (57,'Deutsche','\"Dies ist nur notwendig, wenn Sie Eigenschaften benutzen möchten die eine Emailadresse voraussetzen\"');
INSERT INTO international VALUES (56,'Deutsche','Email Adresse');
INSERT INTO international VALUES (55,'Deutsche','Passwort (bestätigen)');
INSERT INTO international VALUES (54,'Deutsche','Benutzerkonto anlegen');
INSERT INTO international VALUES (53,'Deutsche','Druckerbares Format');
INSERT INTO international VALUES (52,'Deutsche','Anmelden');
INSERT INTO international VALUES (51,'Deutsche','Passwort');
INSERT INTO international VALUES (50,'Deutsche','Benutzername');
INSERT INTO international VALUES (49,'Deutsche','\"Hier können Sie sich  <a href=\"\"^\\?op=logout\"\">abmelden</a>.\"');
INSERT INTO international VALUES (48,'Deutsche','Hallo');
INSERT INTO international VALUES (47,'Deutsche','Startseite');
INSERT INTO international VALUES (46,'Deutsche','Mein Benutzerkonto');
INSERT INTO international VALUES (45,'Deutsche','\"Nein, ich habe einen Fehler gemacht.\"');
INSERT INTO international VALUES (44,'Deutsche','\"Ja, ich bin mir sicher.\"');
INSERT INTO international VALUES (43,'Deutsche','\"Sind Sie sicher, dass Sie diesen Inhalt löschen möchten?\"');
INSERT INTO international VALUES (42,'Deutsche','Bitte bestätigen Sie');
INSERT INTO international VALUES (41,'Deutsche','Sie versuchen einen notwendigen Bestandteil des Systems zu löschen. WebGUI wird nach dieser Aktion möglicherweise nicht mehr richtig funktionieren.');
INSERT INTO international VALUES (40,'Deutsche','Notwendiger Bestandteil');
INSERT INTO international VALUES (39,'Deutsche','\"Sie sind nicht berechtigt, diese Seite anzuschauen.\"');
INSERT INTO international VALUES (38,'Deutsche','\"Sie sind nicht berechtigt, diese Aktion auszuführen. <a href=\"\"^\\?op=displayLogin\"\">Melden Sie sich bitte mit einem Benutzernamen an</a>, der über ausreichende Rechte verfügt.\"');
INSERT INTO international VALUES (37,'Deutsche','Zugriff verweigert!');
INSERT INTO international VALUES (36,'Deutsche','\"Um diese Funktion ausführen zu können, müssen Sie Administrator sein. Eine der folgenden Personen kann Sie zum Administrator machen:\"');
INSERT INTO international VALUES (35,'Deutsche','Administrative Funktion');
INSERT INTO international VALUES (34,'Deutsche','Datum setzen');
INSERT INTO international VALUES (33,'Deutsche','Samstag');
INSERT INTO international VALUES (32,'Deutsche','Freitag');
INSERT INTO international VALUES (31,'Deutsche','Donnerstag');
INSERT INTO international VALUES (30,'Deutsche','Mittwoch');
INSERT INTO international VALUES (29,'Deutsche','Dienstag');
INSERT INTO international VALUES (27,'Deutsche','Sonntag');
INSERT INTO international VALUES (28,'Deutsche','Montag');
INSERT INTO international VALUES (26,'Deutsche','Dezember');
INSERT INTO international VALUES (25,'Deutsche','November');
INSERT INTO international VALUES (24,'Deutsche','Oktober');
INSERT INTO international VALUES (23,'Deutsche','September');
INSERT INTO international VALUES (22,'Deutsche','August');
INSERT INTO international VALUES (21,'Deutsche','Juli');
INSERT INTO international VALUES (20,'Deutsche','Juni');
INSERT INTO international VALUES (19,'Deutsche','Mai');
INSERT INTO international VALUES (18,'Deutsche','April');
INSERT INTO international VALUES (17,'Deutsche','März');
INSERT INTO international VALUES (16,'Deutsche','Februar');
INSERT INTO international VALUES (15,'Deutsche','Januar');
INSERT INTO international VALUES (14,'Deutsche','Ausstehende Beiträge anschauen');
INSERT INTO international VALUES (13,'Deutsche','Hilfe anschauen');
INSERT INTO international VALUES (12,'Deutsche','Administrationsmodus abschalten');
INSERT INTO international VALUES (11,'Deutsche','Mülleimer leeren');
INSERT INTO international VALUES (10,'Deutsche','Mülleimer anschauen');
INSERT INTO international VALUES (9,'Deutsche','Zwischenablage anschauen');
INSERT INTO international VALUES (8,'Deutsche','\"\"\"Seite nicht gefunden\"\" anschauen\"');
INSERT INTO international VALUES (7,'Deutsche','Benutzer verwalten');
INSERT INTO international VALUES (6,'Deutsche','Stile verwalten');
INSERT INTO international VALUES (5,'Deutsche','Gruppen verwalten');
INSERT INTO international VALUES (4,'Deutsche','Einstellungen verwalten');
INSERT INTO international VALUES (3,'Deutsche','Aus Zwischenablage einfügen...');
INSERT INTO international VALUES (2,'Deutsche','Seite');
INSERT INTO international VALUES (1,'Deutsche','Inhalt hinzufügen...');
INSERT INTO international VALUES (204,'Deutsche','Extra Spalte bearbeiten');
INSERT INTO international VALUES (205,'Deutsche','F.A.Q.');
INSERT INTO international VALUES (206,'Deutsche','F.A.Q. hinzufügen');
INSERT INTO international VALUES (207,'Deutsche','Frage hinzufügen');
INSERT INTO international VALUES (208,'Deutsche','Frage');
INSERT INTO international VALUES (209,'Deutsche','Antwort');
INSERT INTO international VALUES (210,'Deutsche','\"Sind Sie sicher, dass Sie diese Frage löschen wollen?\"');
INSERT INTO international VALUES (211,'Deutsche','F.A.Q. bearbeiten');
INSERT INTO international VALUES (212,'Deutsche','Neue Frage hinzufügen');
INSERT INTO international VALUES (213,'Deutsche','Frage bearbeiten');
INSERT INTO international VALUES (214,'Deutsche','Link Liste');
INSERT INTO international VALUES (215,'Deutsche','Link hinzufügen');
INSERT INTO international VALUES (216,'Deutsche','URL');
INSERT INTO international VALUES (217,'Deutsche','\"Sind Sie sicher, dass Sie diesen Link löschen wollen?\"');
INSERT INTO international VALUES (218,'Deutsche','Link Liste bearbeiten');
INSERT INTO international VALUES (219,'Deutsche','Link Liste hinzufügen');
INSERT INTO international VALUES (220,'Deutsche','Link bearbeiten');
INSERT INTO international VALUES (221,'Deutsche','Neuen Link hinzufügen');
INSERT INTO international VALUES (222,'Deutsche','Diskussionsforum hinzufügen');
INSERT INTO international VALUES (223,'Deutsche','Diskussionsforum');
INSERT INTO international VALUES (224,'Deutsche','Wer kann Beiträge schreiben?');
INSERT INTO international VALUES (225,'Deutsche','Beiträge pro Seite');
INSERT INTO international VALUES (226,'Deutsche','Timeout zum bearbeiten');
INSERT INTO international VALUES (227,'Deutsche','Diskussionsforum bearbeiten');
INSERT INTO international VALUES (228,'Deutsche','Beiträge bearbeiten ...');
INSERT INTO international VALUES (229,'Deutsche','Betreff');
INSERT INTO international VALUES (230,'Deutsche','Beitrag');
INSERT INTO international VALUES (231,'Deutsche','Neuen Beitrag schreiben...');
INSERT INTO international VALUES (232,'Deutsche','kein Betreff');
INSERT INTO international VALUES (233,'Deutsche','(eom)');
INSERT INTO international VALUES (234,'Deutsche','Antworten...');
INSERT INTO international VALUES (235,'Deutsche','Beitrag bearbeiten');
INSERT INTO international VALUES (236,'Deutsche','Antwort schicken');
INSERT INTO international VALUES (237,'Deutsche','Betreff:');
INSERT INTO international VALUES (238,'Deutsche','Autor:');
INSERT INTO international VALUES (239,'Deutsche','Datum:');
INSERT INTO international VALUES (240,'Deutsche','Beitrags ID:');
INSERT INTO international VALUES (241,'Deutsche','Vorherige Diskussion');
INSERT INTO international VALUES (242,'Deutsche','Zurück zur Beitragsliste');
INSERT INTO international VALUES (243,'Deutsche','Nächste Diskussion');
INSERT INTO international VALUES (244,'Deutsche','Autor');
INSERT INTO international VALUES (245,'Deutsche','Datum');
INSERT INTO international VALUES (246,'Deutsche','Neuen Beitrag schreiben');
INSERT INTO international VALUES (247,'Deutsche','Diskussion begonnen');
INSERT INTO international VALUES (248,'Deutsche','Antworten');
INSERT INTO international VALUES (249,'Deutsche','Letzte Antwort');
INSERT INTO international VALUES (250,'Deutsche','Abstimmung');
INSERT INTO international VALUES (251,'Deutsche','Abstimmung hinzufügen');
INSERT INTO international VALUES (252,'Deutsche','Aktiv');
INSERT INTO international VALUES (253,'Deutsche','Wer kann abstimmen?');
INSERT INTO international VALUES (254,'Deutsche','Breite der Grafik');
INSERT INTO international VALUES (255,'Deutsche','Frage');
INSERT INTO international VALUES (256,'Deutsche','Antworten');
INSERT INTO international VALUES (257,'Deutsche','(Eine Antwort pro Zeile. Bitte nicht mehr als 20 verschiedene Antworten)');
INSERT INTO international VALUES (258,'Deutsche','Abstimmung bearbeiten');
INSERT INTO international VALUES (259,'Deutsche','SQL Bericht');
INSERT INTO international VALUES (260,'Deutsche','SQL Bericht hinzufügen');
INSERT INTO international VALUES (261,'Deutsche','Schablone');
INSERT INTO international VALUES (262,'Deutsche','Abfrage');
INSERT INTO international VALUES (263,'Deutsche','DSN (Data Source Name)');
INSERT INTO international VALUES (264,'Deutsche','Datenbankbenutzer');
INSERT INTO international VALUES (265,'Deutsche','Datenbankpasswort');
INSERT INTO international VALUES (266,'Deutsche','SQL Bericht bearbeiten');
INSERT INTO international VALUES (267,'Deutsche','Fehler: Die DSN besitzt das falsche Format.');
INSERT INTO international VALUES (268,'Deutsche','Fehler: Das SQL-Statement ist im falschen Format.');
INSERT INTO international VALUES (269,'Deutsche','Fehler: Es gab ein Problem mit der Abfrage.');
INSERT INTO international VALUES (270,'Deutsche','Fehler: Datenbankverbindung konnte nicht aufgebaut werden.');
INSERT INTO international VALUES (271,'Deutsche','Clipping-Dienst');
INSERT INTO international VALUES (272,'Deutsche','Clipping-Dienst hinzufügen');
INSERT INTO international VALUES (273,'Deutsche','URL zur RSS-Datei');
INSERT INTO international VALUES (274,'Deutsche','Clipping-Dienst bearbeiten');
INSERT INTO international VALUES (275,'Deutsche','zuletzt geholt');
INSERT INTO international VALUES (276,'Deutsche','Aktueller Inhalt');
INSERT INTO international VALUES (277,'Deutsche','Benutzer Beitragssystem');
INSERT INTO international VALUES (278,'Deutsche','Benutzer Beitragssystem hinzufügen');
INSERT INTO international VALUES (279,'Deutsche','Wer kann Beiträge schreiben?');
INSERT INTO international VALUES (280,'Deutsche','Beiträge pro Seite');
INSERT INTO international VALUES (281,'Deutsche','Erlaubt');
INSERT INTO international VALUES (282,'Deutsche','Verboten');
INSERT INTO international VALUES (283,'Deutsche','Ausstehend');
INSERT INTO international VALUES (284,'Deutsche','Standardstatus');
INSERT INTO international VALUES (285,'Deutsche','Beitrag hinzufügen');
INSERT INTO international VALUES (286,'Deutsche','\"(Bitte ausklicken, wenn Ihr Beitrag in HTML geschrieben ist)\"');
INSERT INTO international VALUES (287,'Deutsche','Erstellungsdatum');
INSERT INTO international VALUES (288,'Deutsche','Status');
INSERT INTO international VALUES (289,'Deutsche','Bearbeiten/Löschen');
INSERT INTO international VALUES (290,'Deutsche','Ohne Titel');
INSERT INTO international VALUES (291,'Deutsche','\"Sind Sie sicher, dass Sie diesen Beitrag löschen wollen?\"');
INSERT INTO international VALUES (292,'Deutsche','Benutzer Beitragssystem bearbeiten');
INSERT INTO international VALUES (293,'Deutsche','Beitrag bearbeiten');
INSERT INTO international VALUES (294,'Deutsche','Neuen Beitrag schreiben');
INSERT INTO international VALUES (295,'Deutsche','Erstellungsdatum');
INSERT INTO international VALUES (296,'Deutsche','Erstellt von');
INSERT INTO international VALUES (297,'Deutsche','Erstellt von:');
INSERT INTO international VALUES (298,'Deutsche','Erstellungsdatum:');
INSERT INTO international VALUES (299,'Deutsche','Erlauben');
INSERT INTO international VALUES (300,'Deutsche','Ausstehend verlassen');
INSERT INTO international VALUES (301,'Deutsche','Verbieten');
INSERT INTO international VALUES (302,'Deutsche','Bearbeiten');
INSERT INTO international VALUES (303,'Deutsche','Zurück zur Beitragsliste');
INSERT INTO international VALUES (304,'Deutsche','Sprache');
INSERT INTO international VALUES (306,'English','Username Binding');
INSERT INTO international VALUES (307,'English','Use default meta tags?');

#
# Table structure for table 'link'
#

CREATE TABLE link (
  widgetId int(11) default NULL,
  linkId int(11) NOT NULL default '0',
  name varchar(30) default NULL,
  url text,
  description text,
  sequenceNumber int(11) NOT NULL default '0',
  PRIMARY KEY  (linkId)
) TYPE=MyISAM;

#
# Dumping data for table 'link'
#


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
INSERT INTO page VALUES (3,0,'Trash',2,45,1,1,3,1,1,0,0,1,'','trash',0);
INSERT INTO page VALUES (2,0,'Clipboard',2,45,1,1,4,1,1,0,0,1,'','clipboard',0);

#
# Table structure for table 'pollAnswer'
#

CREATE TABLE pollAnswer (
  widgetId int(11) NOT NULL default '0',
  answer char(3) default NULL,
  userId int(11) default NULL,
  ipAddress varchar(50) default NULL
) TYPE=MyISAM;

#
# Dumping data for table 'pollAnswer'
#


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
INSERT INTO style VALUES (2,'Fail Safe','<body>\r\n^H / ^t / ^m / ^a\r\n<hr>','<hr>\r\n^H / ^t / ^m / ^a\r\n</body></html>','<style>\r\n.adminBar {\r\n        background-color: #dddddd;\r\n        font-size: 8pt;\r\n        font-family: helvetica, arial;\r\n        color: #000055;\r\n}\r\n</style>');
INSERT INTO style VALUES (3,'Plain Black Software','<body bgcolor=\"#eaeaef\" text=\"#000000\" link=\"#5555ff\">\r\n<a href=\"/\"><img src=\"/extras/plainBlackSoftware.gif\" border=0></a>\r\n<table width=\"100%\"><tr><td>^C</td><td align=\"right\">^D</td></tr></table>\r\n<table width=\"100%\"><tr><td valign=\"top\" width=\"130\">\r\nuser: ^@\r\n<hr size=1>\r\n^T\r\n</td><td valign=\"top\">\r\n^m\r\n','</td></tr></table><hr size=1>\r\n<a href=\"/\"><img src=\"/extras/pbs.gif\" border=0 align=\"right\"></a>\r\n^H / ^a\r\n</body></html>','<style>\r\n/* WebGUI Default Style Sheet */\r\n\r\n.content, body {\r\n  background-color: #eaeaef;\r\n  color: #000000;\r\n  font-family: helvetica, arial;\r\n  font-size: 10pt;\r\n}\r\n\r\n.verticalMenu {\r\n  font-size: 10pt;\r\n}\r\nH1 {\r\n  font-family: helvetica, arial;\r\n}\r\n\r\nA {\r\n  color: #5555ff;\r\n}\r\n\r\n.pagination {\r\n  font-family: helvetica, arial;\r\n  text-align: center;\r\n  width: 100%;\r\n  font-size: 8pt;\r\n}\r\n\r\n.horizontalMenu {\r\n  font-size: 8pt;\r\n  background-color: #ffffff;\r\n  font-weight: bold;\r\n  border: 1px;\r\n  width: 100%;\r\n}\r\n\r\n.adminBar {\r\n        background-color: #dddddd;\r\n        font-size: 8pt;\r\n        font-family: helvetica, arial;\r\n        color: #000055;\r\n}\r\n\r\n.crumbTrail {\r\n        font-family: helvetica, arial;\r\n        color: #666666;\r\n        font-size: 8pt;\r\n}\r\n\r\n.crumbTrail A {\r\n        color: #555555;\r\n}\r\n\r\n.crumbTrail A:visited {\r\n        color: #666666;\r\n}\r\n\r\n.highlight {\r\n  background-color: #aaaaaa;\r\n}\r\n\r\n.formDescription {\r\n        font-family: helvetica, arial;\r\n        font-size: 10pt;\r\n}\r\n\r\n.formSubtext {\r\n        font-family: helvetica, arial;\r\n        font-size: 8pt;\r\n}\r\n\r\n.boardTitle {\r\n  font-family: helvetica, arial;\r\n  font-size: 16pt;\r\n}\r\n\r\n.boardMenu a {\r\n  font-size: 10pt;\r\n  text-decoration: none;\r\n}\r\n\r\n.tableHeader {\r\n  background-color: #cccccc;\r\n  font-size: 10pt;\r\n}\r\n\r\n.tableData {\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.boardMessage {\r\n  font-size: 10pt;\r\n  font-family: Helvetica, Arial;\r\n}\r\n\r\n.pollAnswer {\r\n  font-family: Helvetica, Arial;\r\n  font-size: 8pt;\r\n}\r\n\r\n.pollColor {\r\n  background-color: #ffddbb;\r\n}\r\n\r\n.pollQuestion {\r\n  font-face: Helvetica, Arial;\r\n  font-weight: bold;\r\n}\r\n\r\n</style>');
INSERT INTO style VALUES (4,'Reserved','<body>','</body></html>',NULL);
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
# Table structure for table 'submission'
#

CREATE TABLE submission (
  widgetId int(11) default NULL,
  submissionId int(11) NOT NULL default '0',
  title varchar(30) default NULL,
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
# Dumping data for table 'submission'
#


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
  icq varchar(30) default NULL,
  PRIMARY KEY  (userId)
) TYPE=MyISAM;

#
# Dumping data for table 'users'
#

INSERT INTO users VALUES (1,'Visitor','No Login','','WebGUI',NULL,NULL,'English','');
INSERT INTO users VALUES (2,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL);
INSERT INTO users VALUES (3,'Admin','RvlMjeFPs2aAhQdo/xt/Kg','','WebGUI',NULL,NULL,'English','');
INSERT INTO users VALUES (4,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL);
INSERT INTO users VALUES (5,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL);
INSERT INTO users VALUES (6,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL);
INSERT INTO users VALUES (7,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL);
INSERT INTO users VALUES (8,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL);
INSERT INTO users VALUES (9,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL);
INSERT INTO users VALUES (10,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL);
INSERT INTO users VALUES (11,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL);
INSERT INTO users VALUES (12,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL);
INSERT INTO users VALUES (13,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL);
INSERT INTO users VALUES (14,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL);
INSERT INTO users VALUES (15,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL);
INSERT INTO users VALUES (16,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL);
INSERT INTO users VALUES (17,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL);
INSERT INTO users VALUES (18,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL);
INSERT INTO users VALUES (19,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL);
INSERT INTO users VALUES (20,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL);
INSERT INTO users VALUES (21,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL);
INSERT INTO users VALUES (22,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL);
INSERT INTO users VALUES (23,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL);
INSERT INTO users VALUES (24,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL);
INSERT INTO users VALUES (25,'Reserved','No Login',NULL,'WebGUI',NULL,NULL,'English',NULL);

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

