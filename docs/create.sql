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
  startDate datetime default NULL,
  endDate datetime default NULL,
  body text,
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
# Table structure for table 'SearchMnoGo'
#

CREATE TABLE SearchMnoGo (
  widgetId int(11) NOT NULL default '0',
  DSN varchar(255) default NULL,
  username varchar(255) default NULL,
  identifier varchar(255) default NULL,
  PRIMARY KEY  (widgetId)
) TYPE=MyISAM;

#
# Dumping data for table 'SearchMnoGo'
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


#
# Table structure for table 'SyndicatedContent'
#

CREATE TABLE SyndicatedContent (
  widgetId int(11) NOT NULL default '0',
  rssUrl text,
  content text,
  lastFetched datetime NOT NULL default '0000-00-00 00:00:00',
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
# Table structure for table 'dict'
#

CREATE TABLE dict (
  url_id int(11) NOT NULL default '0',
  word varchar(32) NOT NULL default '',
  intag int(11) NOT NULL default '0',
  KEY url_id (url_id),
  KEY word_url (word)
) TYPE=MyISAM;

#
# Dumping data for table 'dict'
#


#
# Table structure for table 'event'
#

CREATE TABLE event (
  eventId int(11) NOT NULL default '1',
  widgetId int(11) default NULL,
  name varchar(255) default NULL,
  description text,
  startDate datetime default NULL,
  endDate datetime default NULL,
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

INSERT INTO help VALUES (1,'US English','Add','Page','Think of pages as containers for content. For instance, if you want to write a letter to the editor of your favorite magazine you\'d get out a notepad (or open a word processor) and start filling it with your thoughts. The same is true with WebGUI. Create a page, then add your content to the page.\r\n\r\n<b>Title</b>\r\nThe title of the page is what your users will use to navigate through the site. Titles should be descriptive, but not very long.\r\n\r\n<b>Meta Tags</b>\r\nMeta tags are used by some search engines to associate key words to a particular page. There is a great site called <a href=\"http://www.metatagbuilder.com/\">Meta Tag Builder</a> that will help you build meta tags if you\'ve never done it before.\r\n\r\n<i>Advanced Users:</i> If you have other things (like JavaScript) you usually put in the &lt;head&gt; area of your pages, you may put them here as well.','0');
INSERT INTO help VALUES (2,'US English','Edit','Page','<b>Title</b>\r\nSee <i>Add Page</i> for details.\r\n\r\n<b>Meta Tags</b>\r\nSee <i>Add Page</i> for details.\r\n\r\n<b>Style</b>\r\nBy default, when you create a page, it inherits a few traits from its parent. One of those traits is style. Choose from the list of styles if you would like to change the appearance of this page. See <i>Add Style</i> for more details.\r\n\r\nIf you check the box next to the style pull-down menu, all of the pages below this page will take on the style you\'ve chosen for this page.\r\n\r\n<b>Page URL</b>\r\nWhen you create a page a url for the page is generated based on the page title. If you are unhappy with the url that was chosen, you can change it here.\r\n\r\n<b>Owner</b>\r\nThe owner of a page is usually the person who created the page. If you\'d like to give ownership of a page to a different content manager, then change the name here. Be careful though, once you change ownership of the page, you won\'t be able to get it back unless you are an administrator.\r\n\r\n<b>Owner can view?</b>\r\nCan the owner view the page or not?\r\n\r\n<b>Owner can edit?</b>\r\nCan the owner edit the page or not? Be careful, if you decide that the owner cannot edit the page and you do not belong to the page group, then you\'ll lose the ability to edit this page.\r\n\r\n<b>Group</b>\r\nA group is assigned to every page for additional privilege control. Pick a group from the pull-down menu.\r\n\r\n<b>Group can view?</b>\r\nCan members of this group view this page?\r\n\r\n<b>Group can edit?</b>\r\nCan members of this group edit this page?\r\n\r\n<b>Anybody can view?</b>\r\nCan any visitor or member regardless of the group and owner view this page?\r\n\r\n<b>Anybody can edit?</b>\r\nCan any visitor or member regardless of the group and owner edit this page?\r\n\r\n','9');
INSERT INTO help VALUES (3,'US English','Delete','Page','Deleting a page can create a big mess if you are uncertain about what you are doing. When you delete a page you are also deleting the content it contains, all sub-pages connected to this page, and all the content they contain. Be certain that you have already moved all the content you wish to keep before you delete a page.\r\n\r\nAs with any delete operation, you are prompted to be sure you wish to proceed with the delete. If you answer yes, the delete will proceed and there is no recovery possible. If you answer no you\'ll be returned to the prior screen.','0');
INSERT INTO help VALUES (4,'US English','Delete','Style','When you delete a style all pages using that style will be reverted to the fail safe (default) style. To ensure uninterrupted viewing, you should be sure that no pages are using a style before you delete it.\r\n\r\nAs with any delete operation, you are prompted to be sure you wish to proceed with the delete. If you answer yes, the delete will proceed and there is no recovery possible. If you answer no you\'ll be returned to the prior screen.','0');
INSERT INTO help VALUES (5,'US English','Add','User','See <b>Manage Users</b> for additional details.\r\n\r\n<b>Username</b>\r\nUsername is a unique identifier for a user. Sometimes called a handle, it is also how the user will be known on the site. (<i>Note:</i> Administrators have unlimited power in the WebGUI system. This also means they are capable of breaking the system. If you rename or create a user, be careful not to use a username already in existance.)\r\n\r\n<b>Password</b>\r\nA password is used to ensure that the user is who s/he says s/he is.\r\n\r\n<b>Authentication Method</b>\r\nSee <i>Edit Settings</i> for details.\r\n\r\n<b>LDAP URL</b>\r\nSee <i>Edit Settings</i> for details.\r\n\r\n<b>Connect DN</b>\r\nThe Connect DN is the <b>cn</b> (or common name) of a given user in your LDAP database. It should be specified as <b>cn=John Doe</b>. This is, in effect, the username that will be used to authenticate this user against your LDAP server.\r\n\r\n<b>Email Address</b>\r\nThe user\'s email address. This must only be specified if the user will partake in functions that require email.\r\n\r\n<b>ICQ UIN</b>\r\nThe <a href=\"http://www.icq.com\">ICQ</a> UIN is the \"User ID Number\" on the ICQ network. ICQ is a very popular instant messaging platform.\r\n\r\n<b>Groups</b>\r\nGroups displays which groups the user is in. Groups that are highlighted are groups that the user is assigned to. Those that are not highlighted are other groups that can be assigned. Note that you must hold down CTRL to select multiple groups.','0');
INSERT INTO help VALUES (6,'US English','Edit','User','<b>Username</b>\r\nSee <i>Add User</i> for details.\r\n\r\n<b>Password</b>\r\nSee <i>Add User</i> for details.\r\n\r\n<b>Authentication Method</b>\r\nSee <i>Edit Settings</i> for details.\r\n\r\n<b>LDAP URL</b>\r\nSee <i>Edit Settings</i> for details.\r\n\r\n<b>Connect DN</b>\r\nSee <i>Add User</i> for details.\r\n\r\n<b>Email Address</b>\r\nSee <i>Add User</i> for details.\r\n\r\n<b>ICQ UIN</b>\r\nSee <i>Add User</i> for details.\r\n\r\n<b>Groups</b>\r\nSee <i>Add User</i> for details.\r\n\r\n','12');
INSERT INTO help VALUES (7,'US English','Delete','User','There is no need to ever actually delete a user. If you are concerned with locking out a user, then simply change their password. If you truely wish to delete a user, then please keep in mind that there are consequences. If you delete a user any content that they added to the site via widgets (like message boards and user contributions) will remain on the site. However, if another user tries to visit the deleted user\'s profile they will get an error message. Also if the user ever is welcomed back to the site, there is no way to give him/her access to his/her old content items except by re-adding the user to the users table manually.\r\nAs with any delete operation, you are prompted to be sure you wish to proceed with the delete. If you answer yes, the delete will proceed and there is no recovery possible. If you answer no you\'ll be returned to the prior screen.','0');
INSERT INTO help VALUES (8,'US English','Manage','User','Users are the accounts in the system that are given rights to do certain things. There are two default users built into the system: Admin and Visitor.\r\n\r\n<b>Admin</b>\r\nAdmin is exactly what you\'d expect. It is a user with unlimited rights in the WebGUI environment. If it can be done, this user has the rights to do it.\r\n\r\n<b>Visitor</b>\r\nVisitor is exactly the opposite of Admin. Visitor has no rights what-so-ever. By default any user who is not logged in is seen as the user Visitor.','0');
INSERT INTO help VALUES (9,'US English','Manage','Style','Styles are used to manage the look and feel of your WebGUI pages. With WebGUI, you can have an unlimited number of styles, so your site can take on as many looks as you like. You could have some pages that look like your company\'s brochure, and some pages that look like Yahoo!&reg;. You could even have some pages that look like pages in a book. Using style management, you have ultimate control over all your designs.\r\n\r\nThere are three styles built in to WebGUI: Fail Safe, Plain Black Software, and Yahoo!&reg;. These styles are not meant to be edited, but rather to give you samples of what\'s possible.\r\n\r\n<b>Fail Safe</b>\r\nWhen you delete a style that is still in use on some pages, the Fail Safe style will be applied to those pages. This style has a white background and simple navigation.\r\n\r\n<b>Plain Black Software</b>\r\nThis is the simple design used on the Plain Black Software site.\r\n\r\n<b>Yahoo!&reg;</b>\r\nThis is the design of the Yahoo!&reg; site. (Yahoo!&reg; has not given us permission to use their design. It is simply an example.)','0');
INSERT INTO help VALUES (10,'US English','Manage','Group','Groups are used to subdivide privileges and responsibilities within the WebGUI system. For instance, you may be building a site for a classroom situation. In that case you might set up a different group for each class that you teach. You would then apply those groups to the pages that are designed for each class.\r\n\r\nThere are four groups built into WebGUI. They are Admins, Content Managers, Visitors, and Registered Users.\r\n\r\n<b>Admins</b>\r\nAdmins are users who have unlimited privileges within WebGUI. A user should only be added to the admin group if they oversee the system. Usually only one to three people will be added to this group.\r\n\r\n<b>Content Managers</b>\r\nContent managers are users who have privileges to add, edit, and delete content from various areas on the site. The content managers group should not be used to control individual content areas within the site, but to determine whether a user can edit content at all. You should set up additional groups to separate content areas on the site.\r\n\r\n<b>Registered Users</b>\r\nWhen users are added to the system they are put into the registered users group. A user should only be removed from this group if their account is deleted or if you wish to punish a troublemaker.\r\n\r\n<b>Visitors</b>\r\nVisitors are users who are not logged in using an account on the system. Also, if you wish to punish a registered user you could remove him/her from the Registered Users group and insert him/her into the Visitors group.','0');
INSERT INTO help VALUES (11,'US English','Edit','Style','<b>Style Name</b>\r\nSee <i>Add Style</i> for details.\r\n\r\n<b>Header</b>\r\nSee <i>Add Style</i> for details.\r\n\r\n<b>Footer</b>\r\nSee <i>Add Style</i> for details.\r\n\r\n<b>Style Sheet</b>\r\nSee <i>Add Style</i> for details.\r\n\r\n','18,19');
INSERT INTO help VALUES (12,'US English','Edit','Settings','Settings are items that allow you to adjust WebGUI to your particular needs.\r\n\r\n<b>Path to WebGUI Extras</b>\r\nThe web-path to the directory containing WebGUI images and javascript files.\r\n\r\n<b>Maximum Attachment Size</b>\r\nThe maximum size of files allowed to be uploaded to this site. This applies to all widgets that allow uploaded files and images (like Article and User Contributions). This size is measured in kilobytes.\r\n\r\n<b>Web Attachment Path</b>\r\nThe web-path of the directory where attachments are to be stored.\r\n\r\n<b>Server Attachment Path</b>\r\nThe local path of the directory where attachments are to be stored. (Perhaps /var/www/public/uploads) Be sure that the web server has the rights to write to that directory.\r\n\r\n<b>Company Name</b>\r\nThe name of your company. It will appear on all emails and anywhere you use the Company Name macro.\r\n\r\n<b>Company Email Address</b>\r\nA general email address at your company. This is the address that all automated messages will come from. It can also be used via the WebGUI macro system.\r\n\r\n<b>Company URL</b>\r\nThe primary URL of your company. This will appear on all automated emails sent from the WebGUI system. It is also available via the WebGUI macro system.\r\n\r\n<b>Authentication Method (default)</b>\r\nWhat should the default authentication method be for new accounts that are created? The two available options are WebGUI and LDAP. WebGUI authentication means that the users will authenticate against the username and password stored in the WebGUI database. LDAP authentication means that users will authenticate against an external LDAP server.\r\n\r\n<i>Note:</i> Authentication settings can be customized on a per user basis.\r\n\r\n<b>LDAP URL (default)</b>\r\nThe default url to your LDAP server. The LDAP URL takes the form of <b>ldap://[server]:[port]/[base DN]</b>. Example: ldap://ldap.mycompany.com:389/o=MyCompany.\r\n\r\n<b>LDAP Identity</b>\r\nThe LDAP Identity is the unique identifier in the LDAP server that the user will be identified against. Often this field is <b>shortname</b>, which takes the form of first initial + last name. Example: jdoe. Therefore if you specify the LDAP identity to be <i>shortname</i> then Jon Doe would enter <i>jdoe</i> during the registration process.\r\n\r\n<b>LDAP Identity Name</b>\r\nThe label used to describe the LDAP Identity to the user. For instance, some companies use an LDAP server for their proxy server users to authenticate against. In the documentation or training already provided to their users, the LDAP identity is known as their <i>Web Username</b>. So you could enter that label here for consitency.\r\n\r\n<b>LDAP Password Name</b>\r\nJust as the LDAP Identity Name is a label, so is the LDAP Password Name. Use this label as you would LDAP Identity Name.\r\n\r\n<b>Session Timeout</b>\r\nThe time (in seconds) that a user session remains active (before needing to log in again). This timeout is reset each time a visitor hits a page. Therefore if you set the timeout for 8 hours, a user would have to log in again if s/he hadn\'t visited the site for 8 hours.\r\n\r\n1800 = half hour\r\n3600 = 1 hour\r\n28000 = 8 hours\r\n86400 = 1 day\r\n604800 = 1 week\r\n1209600 = 2 weeks\r\n\r\n<b>SMTP Server</b>\r\nThis is the address of your local mail server. It is needed for all features that use the Internet email system (such as password recovery).\r\n\r\n\r\n','19');
INSERT INTO help VALUES (13,'US English','Edit','Group','<b>Group Name</b>\r\nSee <i>Add Group</i> for details.\r\n\r\n<b>Description</b>\r\nSee <i>Add Group</i> for details.\r\n','0');
INSERT INTO help VALUES (14,'US English','Delete','Widget','This function permanently deletes the selected widget from a page. If you are unsure whether you wish to delete this content you may be better served to cut the content to the clipboard until you are certain you wish to delete it.\r\n\r\nAs with any delete operation, you are prompted to be sure you wish to proceed with the delete. If you answer yes, the delete will proceed and there is no recovery possible. If you answer no you\'ll be returned to the prior screen.','0');
INSERT INTO help VALUES (15,'US English','Delete','Group','As the function suggests you\'ll be deleting a group and removing all users from the group. Be careful not to orphan users from pages they should have access to by deleting a group that is in use.\r\n\r\nAs with any delete operation, you are prompted to be sure you wish to proceed with the delete. If you answer yes, the delete will proceed and there is no recovery possible. If you answer no you\'ll be returned to the prior screen.','0');
INSERT INTO help VALUES (16,'US English','Add','Style','Styles are WebGUI macro enabled. See <i>Using Macros</i> for more information.\r\n\r\n<b>Style Name</b>\r\nA unique name to describe what this style looks like at a glance. The name has no effect on the actual look of the style.\r\n\r\n<b>Header</b>\r\nThe header is the start of the look of your site. It is helpful to look at your design and cut it into three pieces. The top and left of your design is the header. The center part is the content, and the right and bottom is the footer. Cut the HTML from your header and paste it in the space provided.\r\n\r\nIf you are in need of assistance for creating a look for your site, or if you need help cutting apart your design, <a href=\"http://www.plainblack.com\">Plain Black Software</a> provides support services for a small fee.\r\n\r\nMany people will add WebGUI macros to their header for automated navigation, and other features.\r\n\r\n<b>Footer</b>\r\nThe footer is the end of the look for your site. It is the right and bottom portion of your design. You may also place WebGUI macros in your footer.\r\n\r\n<b>Style Sheet</b>\r\nPlace your style sheet entries here. Style sheets are used to control colors, sizes, and other properties of the elements on your site. See <i>Using Style Sheets</i> for more information.\r\n\r\n<i>Advanced Users:</i> for greater performance create your stylesheet on the file system (call it something like webgui.css) and add an entry like this to this area: \r\n&lt;link href=\"/webgui.css\" rel=\"stylesheet\" rev=\"stylesheet\" type=\"text/css\"&gt;','18,19');
INSERT INTO help VALUES (17,'US English','Add','Group','See <i>Manage Group</i> for a description of grouping functions and the default groups.\r\n\r\n<b>Group Name</b>\r\nA name for the group. It is best if the name is descriptive so you know what it is at a glance.\r\n\r\n<b>Description</b>\r\nA longer description of the group so that other admins and content managers (or you if you forget) will know what the purpose of this group is.','0');
INSERT INTO help VALUES (22,'US English','Edit','SQL Report','<b>Title</b>\r\nSee <i>Add SQL Report</i> for details.\r\n\r\n<b>Display Title?</b>\r\nSee <i>Add SQL Report</i> for details.\r\n\r\n<b>Process Macros</b>\r\nSee <i>Add SQL Report</i> for details.\r\n\r\n<b>Description</b>\r\nSee <i>Add SQL Report</i> for details.\r\n\r\n<b>Template</b>\r\nSee <i>Add SQL Report</i> for details.\r\n\r\n<b>Query</b>\r\nSee <i>Add SQL Report</i> for details.\r\n\r\n<b>DSN</b>\r\nSee <i>Add SQL Report</i> for details.\r\n\r\n<b>Database User</b>\r\nSee <i>Add SQL Report</i> for details.\r\n\r\n<b>Database Password</b>\r\nSee <i>Add SQL Report</i> for details.\r\n\r\n<b>Convert carriage returns?</b>\r\nSee <i>Add SQL Report</i> for details.\r\n\r\n','19,14,21');
INSERT INTO help VALUES (18,'US English','Using','Style Sheets','<a href=\"http://www.w3.org/Style/CSS/\">Cascading Style Sheets (CSS)</a> are a great way to manage the look and feel of any web site. They are used extensively in WebGUI.\r\n\r\nIf you are unfamiliar with how to use CSS, <a href=\"http://www.plainblack.com\">Plain Black Software</a> provides training classes on XHTML and CSS. Alternatively, Bradsoft makes an excellent CSS editor called <a href=\"http://www.bradsoft.com/topstyle/index.asp\">Top Style</a>.\r\n\r\nThe following is a list of classes used to control the look of WebGUI:\r\n\r\n<b>A</b>\r\nThe links throughout the style.\r\n\r\n<b>BODY</b>\r\nThe default setup of all pages within a style.\r\n\r\n<b>H1</b>\r\nThe headers on every page.\r\n\r\n<b>.accountOptions</b>\r\nThe links that appear under the login and account update forms.\r\n\r\n<b>.adminBar </b>\r\nThe bar that appears at the top of the page when you\'re in admin mode.\r\n\r\n<b>.boardMenu </b>\r\nThe menu on the message boards.\r\n\r\n<b>.boardMessage </b>\r\nThe full message text.\r\n\r\n<b>.boardTitle </b>\r\nThe title of the message board.\r\n\r\n<b>.content</b>\r\nThe main content area on all pages of the style.\r\n\r\n<b>.crumbTrail </b>\r\nThe crumb trail (if you\'re using that macro).\r\n\r\n<b>.eventTitle </b>\r\nThe title of an individual event.\r\n\r\n<b>.faqQuestion</b>\r\nAn F.A.Q. question. To distinguish it from an answer.\r\n\r\n<b>.formDescription </b>\r\nThe tags on all forms next to the form elements. \r\n\r\n<b>.formSubtext </b>\r\nThe tags below some form elements.\r\n\r\n<b>.highlight </b>\r\nDenotes a highlighted item, such as which message you are viewing within a list.\r\n\r\n<b>.horizontalMenu </b>\r\nThe horizontal menu (if you use a horizontal menu macro).\r\n\r\n<b>.loginBox</b>\r\nThe login box macro.\r\n\r\n<b>.pagination </b>\r\nThe Previous and Next links on pages with pagination.\r\n\r\n<b>.pollAnswer </b>\r\nAn answer on a poll.\r\n\r\n<b>.pollColor </b>\r\nThe color of the percentage bar on a poll.\r\n\r\n<b>.pollQuestion </b>\r\nThe question on a poll.\r\n\r\n<b>.tableData </b>\r\nThe data rows on things like message boards and user contributions.\r\n\r\n<b>.tableHeader </b>\r\nThe headings of columns on things like message boards and user contributions.\r\n\r\n<b>.verticalMenu </b>\r\nThe vertical menu (if you use a verticall menu macro).\r\n\r\n','11,16');
INSERT INTO help VALUES (19,'US English','Using','Macros','WebGUI macros are used to create dynamic content within otherwise static content. For instance, you may wish to show which user is logged in on every page, or you may wish to have a dynamically built menu or crumb trail. \r\n\r\nMacros always begin with a carat (^) and follow with one other character. The following is a description of all the macros in the WebGUI system.\r\n\r\n<b>^^ - Carat</b>\r\nSince the carat symbol is used to start all macros, this macro is in place just in case you really wanted to use a carat somewhere.\r\n\r\n<b>^/ - System URL</b>\r\nThe URL to the gateway script (including the domain for this site). This is often used within pages so that if your development server is on a domain different than your production server that your URLs will still worked when moved.\r\n\r\n<b>^\\ - Page URL</b>\r\nThe URL to the current page (including the domain for this site). This is often used within pages so that if your development server is on a domain different than your production server that your URLs will still worked when moved.\r\n\r\n<b>^@ - Username</b>\r\nThe username of the currently logged in user.\r\n\r\n<b>^# - User ID</b>\r\nThe user id of the currently logged in user.\r\n\r\n<b>^* - Random Number</b>\r\nA randomly generated number. This is often used on images (such as banner ads) that you want to ensure do not cache.\r\n\r\n<b>^a - My Account Link</b>\r\nA link to your account information.\r\n\r\n<b>^C - Crumb Trail</b>\r\nA dynamically generated crumb trail to the current page.\r\n\r\n<b>^D - Date</b>\r\nThe current date and time.\r\n\r\n<b>^f - Full Menu (Vertical)</b>\r\nDisplays a complete menu listing for all pages on the site, sort of like a site map.\r\n\r\n<b>^F - 2 Level Menu (Vertical)</b>\r\nDisplays the first two levels of the menuing hierarchy at all times.\r\n\r\n<b>^h - 3 Level Menu (Vertical)</b>\r\nDisplays the first three levels of the menuing hierarchy at all times.\r\n\r\n<b>^H - Home Link</b>\r\nA link to the home page of this site.\r\n\r\n<b>^j - 2 Level, Current Level Menu (Vertical)</b>\r\nDisplays the next two levels of the menuing hierarchy.\r\n\r\n<b>^J - 3 Level, Current Level Menu (Vertical)</b>\r\nDisplays the next three levels of the menuing hierarchy.\r\n\r\n<b>^L - Login</b>\r\nA small login form.\r\n\r\n<b>^M - Current Menu (Vertical)</b>\r\nA vertical menu containing the sub-pages at the current level.\r\n\r\n<b>^m - Current Menu (Horizontal)</b>\r\nA horizontal menu containing the sub-pages at the current level.\r\n\r\n<b>^P - Previous Menu (Vertical)</b>\r\nA vertical menu containing the sub-pages at the previous level.\r\n\r\n<b>^p - Previous Menu (Horizontal)</b>\r\nA horizontal menu containing the sub-pages at the previous level.\r\n\r\n<b>^r - Make Page Printable</b>\r\nCreates a link to remove the style from a page to make it printable.\r\n\r\n<b>^T - Top Level Menu (Vertical)</b>\r\nA vertical menu containing the main pages of the site (aka the sub-pages from the home page).\r\n\r\n<b>^t - Top Level Menu (Horizontal)</b>\r\nA vertical menu containing the main pages of the site (aka the sub-pages from the home page).\r\n\r\n','11,16,12');
INSERT INTO help VALUES (20,'US English','Add','SQL Report','SQL Reports are perhaps the most powerful widget in the WebGUI arsenal. They allow a user to query data from any database that they have access to. This is great for getting sales figures from your Accounting database or even summarizing all the message boards on your web site.\r\n\r\n<b>Title</b>\r\nThe title of this report.\r\n\r\n<b>Display Title?</b>\r\nDo you wish to display the title of the report? If so, check the box.\r\n\r\n<b>Process Macros</b>\r\nDo you wish to process WebGUI Macros on this report? If so, check the box.\r\n\r\n<b>Description</b>\r\nDescribe the content of this report so your users will better understand what the report is all about.\r\n\r\n<b>Template</b>\r\nLayout a template of how this report should look. Usually you\'ll use HTML tables to generate a report. An example is included below.\r\n\r\nThere are 11 special macro characters used in generating SQL Reports. They are ^-, ^0, ^1, ^2, ^3, ^4, ^5, ^6, ^7, ^8, and ^9. These macros will be processed regardless of whether you checked the process macros box above. The ^- macro represents split points in the document where the report will begin and end looping. The numeric macros represent the data fields that will be returned from your query. Note that you may only have 10 fields returned per row in your query.\r\n\r\n<i>Sample Template:</i>\r\n&lt;table&gt;\r\n&lt;tr&gt;&lt;th&gt;Employee Name&lt;/th&gt;&lt;th&gt;Employee #&lt;/th&gt;&lt;th&gt;Vacation Days Remaining&lt;/th&gt;&lt;th&gt;Monthly Salary&lt;/th&gt;&lt;/tr&gt;\r\n^-\r\n&lt;tr&gt;&lt;td&gt;^0&lt;/td&gt;&lt;td&gt;^1&lt;/td&gt;&lt;td&gt;^2&lt;/td&gt;&lt;td&gt;^3&lt;/td&gt;&lt;/tr&gt;\r\n^-\r\n&lt;/table&gt;\r\n\r\n<b>Query</b>\r\nThis is a standard SQL query. If you are unfamiliar with SQL, <a href=\"http://www.plainblack.com\">Plain Black Software</a> provides training courses in SQL and database management.\r\n\r\n<b>DSN</b>\r\n<b>D</b>ata <b>S</b>ource <b>N</b>ame is the unique identifier that Perl uses to describe the location of your database. It takes the format of DBI:[driver]:[database name]:[host]. \r\n\r\n<i>Example:</i> DBI:mysql:WebGUI:localhost\r\n\r\n<b>Database User</b>\r\nThe username you use to connect to the DSN.\r\n\r\n<b>Database Password</b>\r\nThe password you use to connect to the DSN.\r\n\r\n<b>Convert carriage returns?</b>\r\nDo you wish to convert the carriage returns in the resultant data to HTML breaks (&lt;br&gt;).\r\n','19,14,21');
INSERT INTO help VALUES (21,'US English','Using','Widget','Widgets are the true power of WebGUI. Widgets are tiny pluggable applications built to run under WebGUI. Message boards and polls are examples of widgets.\r\n\r\nTo add a widget to a page, first go to that page, then select <i>Add Content...</i> from the upper left corner of your screen. Each widget has it\'s own help so be sure to read the help if you\'re not sure how to use a widget.\r\n','0');
INSERT INTO help VALUES (23,'US English','Add','Article','Articles are the Swiss Army knife of WebGUI. Most pieces of static content can be added via the Article widget.\r\n\r\n<b>Title</b>\r\nWhat\'s the title for this content? Even if you don\'t wish the title to appear, it\'s a good idea to title your content so that if it is ever copied to the clipboard it will have a name.\r\n\r\n<b>Display the title?</b>\r\nDo you wish to display the title listed above?\r\n\r\n<b>Process macros?</b>\r\nDo you wish to process WebGUI macros on this article? Unchecking this box will not process macros and will speed up page execution.\r\n\r\n<b>Start Date</b>\r\nWhat date do you want this article to appear on the site? Dates are in the format of MM/DD/YYYY. You can use the JavaScript wizard to choose your date from a calendar by clicking on the <i>set date</i> button. By default the date is set to 01/01/2000.\r\n\r\n<b>End Date</b>\r\nWhat date do you want this article to be removed from the site? By default the date is set to 100 years in the future, 01/01/2100.\r\n\r\n<b>Body</b>\r\nThe body of the article is where all the content goes. You may feel free to add HTML tags as necessary to format your content. Be sure to put a &lt;p&gt; between paragraphs to add white space to your content.\r\n\r\n<b>Image</b>\r\nChoose an image (.jpg, .gif, .png) file from your hard drive. This file will be uploaded to the server and displayed in the upper-right corner of your article.\r\n\r\n<b>Link Title</b>\r\nIf you wish to add a link to your article, enter the title of the link in this field. \r\n\r\n<i>Example:</i> Google\r\n\r\n<b>Link URL</b>\r\nIf you added a link title, now add the URL (uniform resource locator) here. \r\n\r\n<i>Example:</i> http://www.google.com\r\n\r\n<b>Attachment</b>\r\nIf you wish to attach a word processor file, a zip file, or any other file for download by your users, then choose it from your hard drive.\r\n','14,21');
INSERT INTO help VALUES (24,'US English','Edit','Article','<b>Title</b>\r\nSee <i>Add Article</i> for details.\r\n\r\n<b>Display the title?</b>\r\nSee <i>Add Article</i> for details.\r\n\r\n<b>Process macros?</b>\r\nSee <i>Add Article</i> for details.\r\n\r\n<b>Start Date</b>\r\nSee <i>Add Article</i> for details.\r\n\r\n<b>End Date</b>\r\nSee <i>Add Article</i> for details.\r\n\r\n<b>Body</b>\r\nSee <i>Add Article</i> for details.\r\n\r\n<b>Image</b>\r\nSee <i>Add Article</i> for details.\r\n\r\n<b>Link Title</b>\r\nSee <i>Add Article</i> for details.\r\n\r\n<b>Link URL</b>\r\nSee <i>Add Article</i> for details.\r\n\r\n<b>Attachment</b>\r\nSee <i>Add Article</i> for details.\r\n','14,21');
INSERT INTO help VALUES (25,'US English','Add','Extra Column','Extra columns allow you to change the layout of your page for one page only. If you wish to have multiple columns on all your pages. Perhaps you should consider altering the <i>style</i> applied to your pages. \r\n\r\nColumns are always added from left to right. Therefore any existing content will be on the left of the new column.\r\n\r\n<b>Spacer</b>\r\nSpacer is the amount of space between your existing content and your new column. It is measured in pixels.\r\n\r\n<b>Width</b>\r\nWidth is the actual width of the new column to be added. Width is measured in pixels.\r\n\r\n<b>StyleSheet Class</b>\r\nBy default the <i>content</i> style (which is the style the body of your site should be using) that is applied to all columns. However, if you\'ve created a style specifically for columns, then feel free to modify this class.\r\n','14,21,9,18');
INSERT INTO help VALUES (26,'US English','Edit','Extra Column','<b>Spacer</b>\r\nSee <i>Add Extra Column</b> for details.\r\n\r\n<b>Width</b>\r\nSee <i>Add Extra Column</b> for details.\r\n\r\n<b>StyleSheet Class</b>\r\nSee <i>Add Extra Column</b> for details.\r\n','14,21,9,18');
INSERT INTO help VALUES (27,'US English','Add','Widget','You can add widgets by selecting from the <i>Add Content</i> pulldown menu.','0');
INSERT INTO help VALUES (28,'US English','Add','Poll','Polls can be used to get the impressions of your users on various topics.\r\n\r\n<b>Title</b>\r\nThe title of the poll. Even if you don\'t wish to display the title you should fill out this field so this poll will have a name if it is ever placed in the clipboard.\r\n\r\n<b>Display the title?</b>\r\nDo you wish to disply the title?\r\n\r\n<b>Description</b>\r\nYou may provide a description for this poll, or give the user some background information.\r\n\r\n<b>Active</b>\r\nIf this box is checked, then users will be able to vote. Otherwise they\'ll only be able to see the results of the poll.\r\n\r\n<b>Who can vote?</b>\r\nChoose a group that can vote on this poll.\r\n\r\n<b>Graph Width</b>\r\nThe width of the poll results graph. The width is measured in pixels.\r\n\r\n<b>Question</b>\r\nWhat is the question you\'d like to ask your users?\r\n\r\n<b>Answers</b>\r\nEnter the possible answers to your question. Enter only one answer per line. Polls are only capable of 20 possible answers.\r\n','14,21,19');
INSERT INTO help VALUES (29,'US English','Edit','Poll','<b>Title</b>\r\nSee <i>Add Poll</i> for details.\r\n\r\n<b>Display the title?</b>\r\nSee <i>Add Poll</i> for details.\r\n\r\n<b>Description</b>\r\nSee <i>Add Poll</i> for details.\r\n\r\n<b>Active</b>\r\nSee <i>Add Poll</i> for details.\r\n\r\n<b>Who can vote?</b>\r\nSee <i>Add Poll</i> for details.\r\n\r\n<b>Graph Width</b>\r\nSee <i>Add Poll</i> for details.\r\n\r\n<b>Question</b>\r\nSee <i>Add Poll</i> for details.\r\n\r\n<b>Answers</b>\r\nSee <i>Add Poll</i> for details.\r\n','14,21,19');
INSERT INTO help VALUES (30,'US English','Add','Site Map','Site maps are used to provide additional navigation in WebGUI. You could set up a traditional site map that would display a hierarchical view of all the pages in the site. On the other hand, you could use site maps to provide extra navigation at certain levels in your site.\r\n\r\n<b>Title</b>\r\nWhat title would you give to this site map? You should fill this field out even if you don\'t wish it to be displayed.\r\n\r\n<b>Display Title</b>\r\nShould the title be displayed?\r\n\r\n<b>Description</b>\r\nEnter a description as to why this site map is here and what purpose it serves.\r\n\r\n<b>Starting from this level?</b>\r\nIf the site map should display the page tree starting from this level, then check this box. If you wish the site map to start from the home page then uncheck it.\r\n\r\n<b>Show only one level?</b>\r\nShould the site map display only the current level of pages or all pages from this point forward? \r\n','14,21,19');
INSERT INTO help VALUES (31,'US English','Edit','Site Map','<b>Title</b>\r\nSee <i>Add Site Map</i> for details.\r\n\r\n<b>Display Title</b>\r\nSee <i>Add Site Map</i> for details.\r\n\r\n<b>Description</b>\r\nSee <i>Add Site Map</i> for details.\r\n\r\n<b>Starting from this level?</b>\r\nSee <i>Add Site Map</i> for details.\r\n\r\n<b>Show only one level?</b>\r\nSee <i>Add Site Map</i> for details.\r\n','14,21,19');
INSERT INTO help VALUES (32,'US English','Add','Message Board','Message boards, also called Forums and/or Discussions, are a great way to add community to any site or intranets. Many companies use message boards internally to collaborate on projects.\r\n\r\n<b>Title</b>\r\nThe name of this board.\r\n\r\n<b>Display the title?</b>\r\nDo you wish to display the title?\r\n\r\n<b>Description</b>\r\nBriefly describe what should be displayed on this message board.\r\n\r\n<b>Who can post?</b>\r\nWhat group can post to this message board?\r\n\r\n<b>Messages Per Page</b>\r\nWhen a visitor first comes to a message board s/he will be presented with a listing of all the topics (aka threads) of the message board. If a board is popular, it will quickly have many topics. The messages per page attribute allows you to specify how many topics should be shown on one page.\r\n\r\n<b>Edit Timeout</b>\r\nHow long after a user has posted to the board will their message be available for them to edit. This timeout is measured in hours.\r\n\r\n<i>Note:</i> Don\'t set this limit too high. One of the great things about message boards is that they are an accurate record of a discussion. If you allow editing for a long time, then a user has a chance to go back and change his/her mind a long time after the original statement was made.\r\n','14,21,19');
INSERT INTO help VALUES (33,'US English','Edit','Message Board','<b>Title</b>\r\nSee <i>Add Message Board</i> for details.\r\n\r\n<b>Display the title?</b>\r\nSee <i>Add Message Board</i> for details.\r\n\r\n<b>Description</b>\r\nSee <i>Add Message Board</i> for details.\r\n\r\n<b>Who can post?</b>\r\nSee <i>Add Message Board</i> for details.\r\n\r\n<b>Messages Per Page</b>\r\nSee <i>Add Message Board</i> for details.\r\n\r\n<b>Edit Timeout</b>\r\nSee <i>Add Message Board</i> for details.\r\n','14,21,19');
INSERT INTO help VALUES (34,'US English','Add','Link List','Link lists are just what they sound like, a list of links. Many sites have a links section, and this just automates the process.\r\n\r\n<b>Title</b>\r\nWhat is the title of this link list?\r\n\r\n<b>Display the title?</b>\r\nDo you wish to display the title of this list?\r\n\r\n<b>Process macros?</b>\r\nDo you wish to process macros on the contents of this link list? Turning this off will increase performance slightly on busy sites.\r\n\r\n<b>Description</b>\r\nDescribe the purpose of the links in this list.','14,21,19');
INSERT INTO help VALUES (35,'US English','Edit','Link List','<b>Title</b>\r\nSee <i>Add Link List</i> for details.\r\n\r\n<b>Display the title?</b>\r\nSee <i>Add Link List</i> for details.\r\n\r\n<b>Process macros?</b>\r\nSee <i>Add Link List</i> for details.\r\n\r\n<b>Description</b>\r\nSee <i>Add Link List</i> for details.\r\n\r\n<b>Adding / Editing Links</b>\r\nYou\'ll notice at the bottom of the Edit screen that there are some options to add, edit, delete and reorder the links in your link lists. This process works exactly as the process for doing the same with widgets and pages. The three properties of links are <i>name</i>, <i>url</i>, and <i>description</i>.\r\n','14,21,19');
INSERT INTO help VALUES (36,'US English','Add','Syndicated Content','Syndicated content is content that is pulled from another site using the RDF/RSS specification. This technology is often used to pull headlines from various news sites like <a href=\"http://www.cnn.com\">CNN</a> and  <a href=\"http://slashdot.org\">Slashdot</a>. It can, of course, be used for other things like sports scores, stock market info, etc.\r\n\r\nYou can find a list of syndicated content at <a href=\"http://my.userland.com\">http://my.userland.com</a>. You will need to register with an account to browse their listing of content. Also, the list contained there is by no means a complete list of all the syndicated content on the internet.\r\n\r\n<b>Title</b>\r\nWhat is the title for this content? This is often the title of the site that the content comes from.\r\n\r\n<b>Display the title?</b>\r\nDo you wish to display the title?\r\n\r\n<b>Description</b>\r\nBriefly describe the content being pulled so that your users will know what they are seeing.\r\n\r\n<b>URL to RSS file</b>\r\nProvide the exact URL (starting with http://) to the syndicated content\'s RDF or RSS file. The syndicated content will be downloaded from this URL hourly.','14,21');
INSERT INTO help VALUES (37,'US English','Edit','Syndicated Content','<b>Title</b>\r\nSee <i>Add Syndicated Content</i> for details.\r\n\r\n<b>Display the title?</b>\r\nSee <i>Add Syndicated Content</i> for details.\r\n\r\n<b>Description</b>\r\nSee <i>Add Syndicated Content</i> for details.\r\n\r\n<b>URL to RSS file</b>\r\nSee <i>Add Syndicated Content</i> for details.\r\n','14,21');
INSERT INTO help VALUES (38,'US English','Add','Events Calendar','Events calendars are used on many intranets to keep track of internal dates that affect a whole organization. Also events calendars on consumer sites are a great way to let your customers know what events you\'ll be attending and what promotions you\'ll be having.\r\n\r\n<b>Title</b>\r\nWhat is the title of this events calendar?\r\n\r\n<b>Display the title?</b>\r\nDo you want the title to be displayed?\r\n\r\n<b>Process macros?</b>\r\nDo you wish to process WebGUI macros in the content of the events calendar? Turning this off can increase performance on busy sites.\r\n\r\n<b>Description</b>\r\nBriefly describe what this events calendar details.\r\n','14,21,19');
INSERT INTO help VALUES (39,'US English','Edit','Events Calendar','<b>Title</b>\r\nSee <i>Add Events Calendar</i> for details.\r\n\r\n<b>Display the title?</b>\r\nSee <i>Add Events Calendar</i> for details.\r\n\r\n<b>Process macros?</b>\r\nSee <i>Add Events Calendar</i> for details.\r\n\r\n<b>Description</b>\r\nSee <i>Add Events Calendar</i> for details.\r\n\r\n<b>Add / Edit Events</b>\r\nOn the edit screen you\'ll notice that there are options to add, edit, and delete the events in your events calendar. The properties for events are <i>name</i>, <i>description</i>, <i>start date</i>,  and <i>end date</i>.\r\n\r\n<i>Note:</i> Events that have already happened will not be displayed on the events calendar.','14,21,19');
INSERT INTO help VALUES (40,'US English','Add','F.A.Q.','It seems that almost every web site, intranet, and extranet in the world has a frequently asked questions area. This widget helps you build one too.\r\n\r\n<b>Title</b>\r\nWhat is the title for this FAQ section?\r\n\r\n<b>Display the title?</b>\r\nDo you wish to display the title?\r\n\r\n<b>Process macros?</b>\r\nDo you wish to process macros contained in the FAQ content? Turning this off will increase performance on busy sites.\r\n\r\n<b>Description</b>\r\nBriefly describe what this FAQ covers.\r\n','14,21,19');
INSERT INTO help VALUES (41,'US English','Edit','F.A.Q.','<b>Title</b>\r\nSee <i>Add F.A.Q.</i> for details.\r\n\r\n<b>Display the title?</b>\r\nSee <i>Add F.A.Q.</i> for details.\r\n\r\n<b>Process macros?</b>\r\nSee <i>Add F.A.Q.</i> for details.\r\n\r\n<b>Description</b>\r\nSee <i>Add F.A.Q.</i> for details.\r\n\r\n<b>Add / Edit Questions</b>\r\nOn the edit screen you\'ll notice options for adding, editing, deleting, and reordering the questions in your FAQ. The two properties of FAQ questions are <i>question</i> and <i>answer</i>.\r\n\r\n','14,21,19');
INSERT INTO help VALUES (42,'US English','Add','Search (MnoGo)','The <a href=\"http://www.mnogosearch.org\">Mno Go Search engine</a> is one of the most popular and powerful open-source search engines on the market. It is so good that we figured that there was no reason to reinvent the wheel so we incorperated it into WebGUI.\r\n\r\n<b>Title</b>\r\nWhat is the title of this search?\r\n\r\n<b>Display the title?</b>\r\nDo you want to display the title?\r\n\r\n<b>Description</b>\r\nBriefly describe what is available through this search engine.\r\n\r\n<b>DSN</b>\r\n<b>D</b>ata <b>S</b>ource <b>N</b>ame is the unique identifier that Perl uses to describe the location of your database. It takes the format of DBI:[driver]:[database name]:[host]. This DSN needs to point to where your Mno Go Indexer stored the spider results. If you are uncertain how to set up the Mno Go Search Engine and Indexer <a href=\"http://www.plainblack.com\">Plain Black Software</a> provides support and training services.\r\n\r\n<i>Example:</i> DBI:mysql:WebGUI:localhost\r\n\r\n<b>Database User</b>\r\nThe username you use to connect to the DSN.\r\n\r\n<b>Database Password</b>\r\nThe password you use to connect to the DSN.\r\n','14,21');
INSERT INTO help VALUES (43,'US English','Edit','Search (MnoGo)','<b>Title</b>\r\nSee <i>Add Search (MnoGo)</i> for details.\r\n\r\n<b>Display the title?</b>\r\nSee <i>Add Search (MnoGo)</i> for details.\r\n\r\n<b>Description</b>\r\nSee <i>Add Search (MnoGo)</i> for details.\r\n\r\n<b>DSN</b>\r\nSee <i>Add Search (MnoGo)</i> for details.\r\n\r\n<b>Database User</b>\r\nSee <i>Add Search (MnoGo)</i> for details.\r\n\r\n<b>Database Password</b>\r\nSee <i>Add Search (MnoGo)</i> for details.\r\n','14,21');
INSERT INTO help VALUES (44,'US English','Add','User Submission System','User submission systems are a great way to add a sense of community to any site as well as get free content from your users.\r\n\r\n<b>Title</b>\r\nWhat is the title for this user submission system?\r\n\r\n<b>Display the title?</b>\r\nWould you like the title displayed?\r\n\r\n<b>Description</b>\r\nBriefly describe why this user submission system is here and what should be submitted to it.\r\n\r\n<b>Who can contribute?</b>\r\nWhat group is allowed to contribute content?\r\n\r\n<b>Submissions Per Page</b>\r\nHow many submissions should be listed per page in the submissions index?\r\n\r\n<b>Default Status</b>\r\nShould submissions be set to <i>approved</i>, <i>pending</i>, or <i>denied</i> by default?\r\n\r\n<i>Note:</i> If you set the default status to pending, then be prepared to monitor the pending queue under the Admin menu.\r\n','14,21');
INSERT INTO help VALUES (45,'US English','Edit','User Submission System','<b>Title</b>\r\nSee <i>Add User Submission System</i> for details.\r\n\r\n<b>Display the title?</b>\r\nSee <i>Add User Submission System</i> for details.\r\n\r\n<b>Description</b>\r\nSee <i>Add User Submission System</i> for details.\r\n\r\n<b>Who can contribute?</b>\r\nSee <i>Add User Submission System</i> for details.\r\n\r\n<b>Submissions Per Page</b>\r\nSee <i>Add User Submission System</i> for details.\r\n\r\n<b>Default Status</b>\r\nSee <i>Add User Submission System</i> for details.\r\n','14,21');
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
  dateOfPost datetime default NULL,
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
  PRIMARY KEY  (pageId)
) TYPE=MyISAM;

#
# Dumping data for table 'page'
#

INSERT INTO page VALUES (1,0,'Home',3,3,1,1,1,1,0,1,0,1,'','home');
INSERT INTO page VALUES (6,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL);
INSERT INTO page VALUES (7,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL);
INSERT INTO page VALUES (8,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL);
INSERT INTO page VALUES (9,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL);
INSERT INTO page VALUES (10,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL);
INSERT INTO page VALUES (11,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL);
INSERT INTO page VALUES (12,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL);
INSERT INTO page VALUES (13,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL);
INSERT INTO page VALUES (14,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL);
INSERT INTO page VALUES (15,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL);
INSERT INTO page VALUES (16,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL);
INSERT INTO page VALUES (17,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL);
INSERT INTO page VALUES (18,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL);
INSERT INTO page VALUES (19,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL);
INSERT INTO page VALUES (20,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL);
INSERT INTO page VALUES (21,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL);
INSERT INTO page VALUES (22,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL);
INSERT INTO page VALUES (23,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL);
INSERT INTO page VALUES (24,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL);
INSERT INTO page VALUES (25,0,'Reserved',0,0,1,1,NULL,1,0,1,0,1,NULL,NULL);
INSERT INTO page VALUES (4,0,'Reserved',1,0,1,1,0,1,0,1,0,1,NULL,NULL);
INSERT INTO page VALUES (3,0,'Trash',2,45,1,1,3,1,1,0,0,1,'','trash');
INSERT INTO page VALUES (2,0,'Clipboard',2,45,1,1,4,1,1,0,0,1,'','clipboard');

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
# Table structure for table 'robots'
#

CREATE TABLE robots (
  hostinfo varchar(127) NOT NULL default '',
  path varchar(127) NOT NULL default ''
) TYPE=MyISAM;

#
# Dumping data for table 'robots'
#


#
# Table structure for table 'session'
#

CREATE TABLE session (
  sessionId varchar(60) NOT NULL default '',
  expires datetime default NULL,
  lastPageView datetime default NULL,
  adminOn int(11) NOT NULL default '0',
  lastIP varchar(50) default NULL,
  PRIMARY KEY  (sessionId)
) TYPE=MyISAM;

#
# Dumping data for table 'session'
#

INSERT INTO session VALUES ('3|yJFcoK2pMVyHw','2001-09-16 03:09:06','2001-09-15 19:22:26',1,'10.0.0.20');

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
INSERT INTO settings VALUES ('smtpServer','smtp.mycompany.com');
INSERT INTO settings VALUES ('companyEmail','info@mycompany.com');
INSERT INTO settings VALUES ('ldapURL','ldap://ldap.mycompany.com:389/o=MyCompany');
INSERT INTO settings VALUES ('companyName','My Company');
INSERT INTO settings VALUES ('companyURL','http://www.mycompany.com');
INSERT INTO settings VALUES ('ldapId','shortname');
INSERT INTO settings VALUES ('ldapIdName','LDAP Shortname');
INSERT INTO settings VALUES ('ldapPasswordName','LDAP Password');
INSERT INTO settings VALUES ('authMethod','WebGUI');

#
# Table structure for table 'stopword'
#

CREATE TABLE stopword (
  word char(32) NOT NULL default '',
  lang char(2) NOT NULL default '',
  PRIMARY KEY  (word,lang)
) TYPE=MyISAM;

#
# Dumping data for table 'stopword'
#

INSERT INTO stopword VALUES ('a','en');
INSERT INTO stopword VALUES ('about','en');
INSERT INTO stopword VALUES ('above','en');
INSERT INTO stopword VALUES ('abst','en');
INSERT INTO stopword VALUES ('accordance','en');
INSERT INTO stopword VALUES ('according','en');
INSERT INTO stopword VALUES ('accordingly','en');
INSERT INTO stopword VALUES ('across','en');
INSERT INTO stopword VALUES ('act','en');
INSERT INTO stopword VALUES ('actually','en');
INSERT INTO stopword VALUES ('added','en');
INSERT INTO stopword VALUES ('adj','en');
INSERT INTO stopword VALUES ('adopted','en');
INSERT INTO stopword VALUES ('affected','en');
INSERT INTO stopword VALUES ('affecting','en');
INSERT INTO stopword VALUES ('affects','en');
INSERT INTO stopword VALUES ('after','en');
INSERT INTO stopword VALUES ('afterwards','en');
INSERT INTO stopword VALUES ('again','en');
INSERT INTO stopword VALUES ('against','en');
INSERT INTO stopword VALUES ('ah','en');
INSERT INTO stopword VALUES ('all','en');
INSERT INTO stopword VALUES ('almost','en');
INSERT INTO stopword VALUES ('alone','en');
INSERT INTO stopword VALUES ('along','en');
INSERT INTO stopword VALUES ('already','en');
INSERT INTO stopword VALUES ('also','en');
INSERT INTO stopword VALUES ('although','en');
INSERT INTO stopword VALUES ('always','en');
INSERT INTO stopword VALUES ('am','en');
INSERT INTO stopword VALUES ('among','en');
INSERT INTO stopword VALUES ('amongst','en');
INSERT INTO stopword VALUES ('an','en');
INSERT INTO stopword VALUES ('and','en');
INSERT INTO stopword VALUES ('announce','en');
INSERT INTO stopword VALUES ('another','en');
INSERT INTO stopword VALUES ('any','en');
INSERT INTO stopword VALUES ('anyhow','en');
INSERT INTO stopword VALUES ('anymore','en');
INSERT INTO stopword VALUES ('anyone','en');
INSERT INTO stopword VALUES ('anything','en');
INSERT INTO stopword VALUES ('anywhere','en');
INSERT INTO stopword VALUES ('apparently','en');
INSERT INTO stopword VALUES ('approximately','en');
INSERT INTO stopword VALUES ('are','en');
INSERT INTO stopword VALUES ('aren','en');
INSERT INTO stopword VALUES ('arent','en');
INSERT INTO stopword VALUES ('arise','en');
INSERT INTO stopword VALUES ('around','en');
INSERT INTO stopword VALUES ('as','en');
INSERT INTO stopword VALUES ('aside','en');
INSERT INTO stopword VALUES ('at','en');
INSERT INTO stopword VALUES ('auth','en');
INSERT INTO stopword VALUES ('available','en');
INSERT INTO stopword VALUES ('away','en');
INSERT INTO stopword VALUES ('b','en');
INSERT INTO stopword VALUES ('back','en');
INSERT INTO stopword VALUES ('be','en');
INSERT INTO stopword VALUES ('became','en');
INSERT INTO stopword VALUES ('because','en');
INSERT INTO stopword VALUES ('become','en');
INSERT INTO stopword VALUES ('becomes','en');
INSERT INTO stopword VALUES ('becoming','en');
INSERT INTO stopword VALUES ('been','en');
INSERT INTO stopword VALUES ('before','en');
INSERT INTO stopword VALUES ('beforehand','en');
INSERT INTO stopword VALUES ('begin','en');
INSERT INTO stopword VALUES ('beginning','en');
INSERT INTO stopword VALUES ('beginnings','en');
INSERT INTO stopword VALUES ('begins','en');
INSERT INTO stopword VALUES ('behind','en');
INSERT INTO stopword VALUES ('being','en');
INSERT INTO stopword VALUES ('below','en');
INSERT INTO stopword VALUES ('beside','en');
INSERT INTO stopword VALUES ('besides','en');
INSERT INTO stopword VALUES ('between','en');
INSERT INTO stopword VALUES ('beyond','en');
INSERT INTO stopword VALUES ('billion','en');
INSERT INTO stopword VALUES ('biol','en');
INSERT INTO stopword VALUES ('both','en');
INSERT INTO stopword VALUES ('briefly','en');
INSERT INTO stopword VALUES ('but','en');
INSERT INTO stopword VALUES ('by','en');
INSERT INTO stopword VALUES ('c','en');
INSERT INTO stopword VALUES ('ca','en');
INSERT INTO stopword VALUES ('came','en');
INSERT INTO stopword VALUES ('can','en');
INSERT INTO stopword VALUES ('cannot','en');
INSERT INTO stopword VALUES ('cant','en');
INSERT INTO stopword VALUES ('certain','en');
INSERT INTO stopword VALUES ('certainly','en');
INSERT INTO stopword VALUES ('co','en');
INSERT INTO stopword VALUES ('co.','en');
INSERT INTO stopword VALUES ('come','en');
INSERT INTO stopword VALUES ('contains','en');
INSERT INTO stopword VALUES ('could','en');
INSERT INTO stopword VALUES ('couldnt','en');
INSERT INTO stopword VALUES ('d','en');
INSERT INTO stopword VALUES ('date','en');
INSERT INTO stopword VALUES ('did','en');
INSERT INTO stopword VALUES ('didnt','en');
INSERT INTO stopword VALUES ('different','en');
INSERT INTO stopword VALUES ('do','en');
INSERT INTO stopword VALUES ('does','en');
INSERT INTO stopword VALUES ('doesnt','en');
INSERT INTO stopword VALUES ('doing','en');
INSERT INTO stopword VALUES ('done','en');
INSERT INTO stopword VALUES ('dont','en');
INSERT INTO stopword VALUES ('down','en');
INSERT INTO stopword VALUES ('due','en');
INSERT INTO stopword VALUES ('during','en');
INSERT INTO stopword VALUES ('e','en');
INSERT INTO stopword VALUES ('each','en');
INSERT INTO stopword VALUES ('ed','en');
INSERT INTO stopword VALUES ('effect','en');
INSERT INTO stopword VALUES ('eg','en');
INSERT INTO stopword VALUES ('eight','en');
INSERT INTO stopword VALUES ('eighty','en');
INSERT INTO stopword VALUES ('either','en');
INSERT INTO stopword VALUES ('else','en');
INSERT INTO stopword VALUES ('elsewhere','en');
INSERT INTO stopword VALUES ('end','en');
INSERT INTO stopword VALUES ('ending','en');
INSERT INTO stopword VALUES ('enough','en');
INSERT INTO stopword VALUES ('especially','en');
INSERT INTO stopword VALUES ('et-al','en');
INSERT INTO stopword VALUES ('etc','en');
INSERT INTO stopword VALUES ('even','en');
INSERT INTO stopword VALUES ('ever','en');
INSERT INTO stopword VALUES ('every','en');
INSERT INTO stopword VALUES ('everyone','en');
INSERT INTO stopword VALUES ('everything','en');
INSERT INTO stopword VALUES ('everywhere','en');
INSERT INTO stopword VALUES ('except','en');
INSERT INTO stopword VALUES ('f','en');
INSERT INTO stopword VALUES ('far','en');
INSERT INTO stopword VALUES ('few','en');
INSERT INTO stopword VALUES ('ff','en');
INSERT INTO stopword VALUES ('first','en');
INSERT INTO stopword VALUES ('five','en');
INSERT INTO stopword VALUES ('fix','en');
INSERT INTO stopword VALUES ('followed','en');
INSERT INTO stopword VALUES ('following','en');
INSERT INTO stopword VALUES ('for','en');
INSERT INTO stopword VALUES ('former','en');
INSERT INTO stopword VALUES ('formerly','en');
INSERT INTO stopword VALUES ('found','en');
INSERT INTO stopword VALUES ('from','en');
INSERT INTO stopword VALUES ('further','en');
INSERT INTO stopword VALUES ('g','en');
INSERT INTO stopword VALUES ('gave','en');
INSERT INTO stopword VALUES ('get','en');
INSERT INTO stopword VALUES ('gets','en');
INSERT INTO stopword VALUES ('give','en');
INSERT INTO stopword VALUES ('given','en');
INSERT INTO stopword VALUES ('giving','en');
INSERT INTO stopword VALUES ('go','en');
INSERT INTO stopword VALUES ('goes','en');
INSERT INTO stopword VALUES ('gone','en');
INSERT INTO stopword VALUES ('got','en');
INSERT INTO stopword VALUES ('h','en');
INSERT INTO stopword VALUES ('had','en');
INSERT INTO stopword VALUES ('hardly','en');
INSERT INTO stopword VALUES ('has','en');
INSERT INTO stopword VALUES ('hasnt','en');
INSERT INTO stopword VALUES ('have','en');
INSERT INTO stopword VALUES ('havent','en');
INSERT INTO stopword VALUES ('having','en');
INSERT INTO stopword VALUES ('he','en');
INSERT INTO stopword VALUES ('hed','en');
INSERT INTO stopword VALUES ('hence','en');
INSERT INTO stopword VALUES ('her','en');
INSERT INTO stopword VALUES ('here','en');
INSERT INTO stopword VALUES ('hereafter','en');
INSERT INTO stopword VALUES ('hereby','en');
INSERT INTO stopword VALUES ('herein','en');
INSERT INTO stopword VALUES ('heres','en');
INSERT INTO stopword VALUES ('hereupon','en');
INSERT INTO stopword VALUES ('hers','en');
INSERT INTO stopword VALUES ('herself','en');
INSERT INTO stopword VALUES ('hes','en');
INSERT INTO stopword VALUES ('hid','en');
INSERT INTO stopword VALUES ('him','en');
INSERT INTO stopword VALUES ('himself','en');
INSERT INTO stopword VALUES ('his','en');
INSERT INTO stopword VALUES ('home','en');
INSERT INTO stopword VALUES ('how','en');
INSERT INTO stopword VALUES ('however','en');
INSERT INTO stopword VALUES ('hundred','en');
INSERT INTO stopword VALUES ('i','en');
INSERT INTO stopword VALUES ('id','en');
INSERT INTO stopword VALUES ('ie','en');
INSERT INTO stopword VALUES ('if','en');
INSERT INTO stopword VALUES ('ill','en');
INSERT INTO stopword VALUES ('im','en');
INSERT INTO stopword VALUES ('immediately','en');
INSERT INTO stopword VALUES ('importance','en');
INSERT INTO stopword VALUES ('important','en');
INSERT INTO stopword VALUES ('in','en');
INSERT INTO stopword VALUES ('inc','en');
INSERT INTO stopword VALUES ('inc.','en');
INSERT INTO stopword VALUES ('indeed','en');
INSERT INTO stopword VALUES ('index','en');
INSERT INTO stopword VALUES ('information','en');
INSERT INTO stopword VALUES ('instead','en');
INSERT INTO stopword VALUES ('into','en');
INSERT INTO stopword VALUES ('invention','en');
INSERT INTO stopword VALUES ('is','en');
INSERT INTO stopword VALUES ('isnt','en');
INSERT INTO stopword VALUES ('it','en');
INSERT INTO stopword VALUES ('its','en');
INSERT INTO stopword VALUES ('itself','en');
INSERT INTO stopword VALUES ('ive','en');
INSERT INTO stopword VALUES ('j','en');
INSERT INTO stopword VALUES ('just','en');
INSERT INTO stopword VALUES ('k','en');
INSERT INTO stopword VALUES ('keep','en');
INSERT INTO stopword VALUES ('kept','en');
INSERT INTO stopword VALUES ('keys','en');
INSERT INTO stopword VALUES ('kg','en');
INSERT INTO stopword VALUES ('km','en');
INSERT INTO stopword VALUES ('l','en');
INSERT INTO stopword VALUES ('largely','en');
INSERT INTO stopword VALUES ('last','en');
INSERT INTO stopword VALUES ('later','en');
INSERT INTO stopword VALUES ('latter','en');
INSERT INTO stopword VALUES ('latterly','en');
INSERT INTO stopword VALUES ('least','en');
INSERT INTO stopword VALUES ('let','en');
INSERT INTO stopword VALUES ('lets','en');
INSERT INTO stopword VALUES ('like','en');
INSERT INTO stopword VALUES ('likely','en');
INSERT INTO stopword VALUES ('line','en');
INSERT INTO stopword VALUES ('ll','en');
INSERT INTO stopword VALUES ('ltd','en');
INSERT INTO stopword VALUES ('m','en');
INSERT INTO stopword VALUES ('made','en');
INSERT INTO stopword VALUES ('mainly','en');
INSERT INTO stopword VALUES ('make','en');
INSERT INTO stopword VALUES ('makes','en');
INSERT INTO stopword VALUES ('many','en');
INSERT INTO stopword VALUES ('may','en');
INSERT INTO stopword VALUES ('maybe','en');
INSERT INTO stopword VALUES ('me','en');
INSERT INTO stopword VALUES ('means','en');
INSERT INTO stopword VALUES ('meantime','en');
INSERT INTO stopword VALUES ('meanwhile','en');
INSERT INTO stopword VALUES ('mg','en');
INSERT INTO stopword VALUES ('might','en');
INSERT INTO stopword VALUES ('million','en');
INSERT INTO stopword VALUES ('miss','en');
INSERT INTO stopword VALUES ('ml','en');
INSERT INTO stopword VALUES ('more','en');
INSERT INTO stopword VALUES ('moreover','en');
INSERT INTO stopword VALUES ('most','en');
INSERT INTO stopword VALUES ('mostly','en');
INSERT INTO stopword VALUES ('mr','en');
INSERT INTO stopword VALUES ('mrs','en');
INSERT INTO stopword VALUES ('much','en');
INSERT INTO stopword VALUES ('mug','en');
INSERT INTO stopword VALUES ('must','en');
INSERT INTO stopword VALUES ('my','en');
INSERT INTO stopword VALUES ('myself','en');
INSERT INTO stopword VALUES ('n','en');
INSERT INTO stopword VALUES ('na','en');
INSERT INTO stopword VALUES ('namely','en');
INSERT INTO stopword VALUES ('nay','en');
INSERT INTO stopword VALUES ('near','en');
INSERT INTO stopword VALUES ('nearly','en');
INSERT INTO stopword VALUES ('necessarily','en');
INSERT INTO stopword VALUES ('neither','en');
INSERT INTO stopword VALUES ('never','en');
INSERT INTO stopword VALUES ('nevertheless','en');
INSERT INTO stopword VALUES ('new','en');
INSERT INTO stopword VALUES ('next','en');
INSERT INTO stopword VALUES ('nine','en');
INSERT INTO stopword VALUES ('ninety','en');
INSERT INTO stopword VALUES ('no','en');
INSERT INTO stopword VALUES ('nobody','en');
INSERT INTO stopword VALUES ('none','en');
INSERT INTO stopword VALUES ('nonetheless','en');
INSERT INTO stopword VALUES ('noone','en');
INSERT INTO stopword VALUES ('nor','en');
INSERT INTO stopword VALUES ('normally','en');
INSERT INTO stopword VALUES ('nos','en');
INSERT INTO stopword VALUES ('not','en');
INSERT INTO stopword VALUES ('noted','en');
INSERT INTO stopword VALUES ('nothing','en');
INSERT INTO stopword VALUES ('now','en');
INSERT INTO stopword VALUES ('nowhere','en');
INSERT INTO stopword VALUES ('o','en');
INSERT INTO stopword VALUES ('obtain','en');
INSERT INTO stopword VALUES ('obtained','en');
INSERT INTO stopword VALUES ('of','en');
INSERT INTO stopword VALUES ('off','en');
INSERT INTO stopword VALUES ('often','en');
INSERT INTO stopword VALUES ('oh','en');
INSERT INTO stopword VALUES ('omitted','en');
INSERT INTO stopword VALUES ('on','en');
INSERT INTO stopword VALUES ('once','en');
INSERT INTO stopword VALUES ('one','en');
INSERT INTO stopword VALUES ('ones','en');
INSERT INTO stopword VALUES ('only','en');
INSERT INTO stopword VALUES ('onto','en');
INSERT INTO stopword VALUES ('or','en');
INSERT INTO stopword VALUES ('ord','en');
INSERT INTO stopword VALUES ('other','en');
INSERT INTO stopword VALUES ('others','en');
INSERT INTO stopword VALUES ('otherwise','en');
INSERT INTO stopword VALUES ('ought','en');
INSERT INTO stopword VALUES ('our','en');
INSERT INTO stopword VALUES ('ours','en');
INSERT INTO stopword VALUES ('ourselves','en');
INSERT INTO stopword VALUES ('out','en');
INSERT INTO stopword VALUES ('over','en');
INSERT INTO stopword VALUES ('overall','en');
INSERT INTO stopword VALUES ('owing','en');
INSERT INTO stopword VALUES ('own','en');
INSERT INTO stopword VALUES ('p','en');
INSERT INTO stopword VALUES ('page','en');
INSERT INTO stopword VALUES ('pages','en');
INSERT INTO stopword VALUES ('part','en');
INSERT INTO stopword VALUES ('particularly','en');
INSERT INTO stopword VALUES ('past','en');
INSERT INTO stopword VALUES ('per','en');
INSERT INTO stopword VALUES ('perhaps','en');
INSERT INTO stopword VALUES ('please','en');
INSERT INTO stopword VALUES ('poorly','en');
INSERT INTO stopword VALUES ('possible','en');
INSERT INTO stopword VALUES ('possibly','en');
INSERT INTO stopword VALUES ('potentially','en');
INSERT INTO stopword VALUES ('pp','en');
INSERT INTO stopword VALUES ('predominantly','en');
INSERT INTO stopword VALUES ('present','en');
INSERT INTO stopword VALUES ('previously','en');
INSERT INTO stopword VALUES ('primarily','en');
INSERT INTO stopword VALUES ('probably','en');
INSERT INTO stopword VALUES ('promptly','en');
INSERT INTO stopword VALUES ('proud','en');
INSERT INTO stopword VALUES ('put','en');
INSERT INTO stopword VALUES ('q','en');
INSERT INTO stopword VALUES ('quickly','en');
INSERT INTO stopword VALUES ('quite','en');
INSERT INTO stopword VALUES ('r','en');
INSERT INTO stopword VALUES ('ran','en');
INSERT INTO stopword VALUES ('rather','en');
INSERT INTO stopword VALUES ('re','en');
INSERT INTO stopword VALUES ('readily','en');
INSERT INTO stopword VALUES ('really','en');
INSERT INTO stopword VALUES ('recent','en');
INSERT INTO stopword VALUES ('recently','en');
INSERT INTO stopword VALUES ('ref','en');
INSERT INTO stopword VALUES ('refs','en');
INSERT INTO stopword VALUES ('regardless','en');
INSERT INTO stopword VALUES ('related','en');
INSERT INTO stopword VALUES ('relatively','en');
INSERT INTO stopword VALUES ('research','en');
INSERT INTO stopword VALUES ('respectively','en');
INSERT INTO stopword VALUES ('resulted','en');
INSERT INTO stopword VALUES ('resulting','en');
INSERT INTO stopword VALUES ('results','en');
INSERT INTO stopword VALUES ('run','en');
INSERT INTO stopword VALUES ('s','en');
INSERT INTO stopword VALUES ('said','en');
INSERT INTO stopword VALUES ('same','en');
INSERT INTO stopword VALUES ('say','en');
INSERT INTO stopword VALUES ('sec','en');
INSERT INTO stopword VALUES ('section','en');
INSERT INTO stopword VALUES ('seem','en');
INSERT INTO stopword VALUES ('seemed','en');
INSERT INTO stopword VALUES ('seeming','en');
INSERT INTO stopword VALUES ('seems','en');
INSERT INTO stopword VALUES ('seen','en');
INSERT INTO stopword VALUES ('seven','en');
INSERT INTO stopword VALUES ('several','en');
INSERT INTO stopword VALUES ('shall','en');
INSERT INTO stopword VALUES ('she','en');
INSERT INTO stopword VALUES ('shed','en');
INSERT INTO stopword VALUES ('shell','en');
INSERT INTO stopword VALUES ('shes','en');
INSERT INTO stopword VALUES ('should','en');
INSERT INTO stopword VALUES ('shouldnt','en');
INSERT INTO stopword VALUES ('show','en');
INSERT INTO stopword VALUES ('showed','en');
INSERT INTO stopword VALUES ('shown','en');
INSERT INTO stopword VALUES ('showns','en');
INSERT INTO stopword VALUES ('shows','en');
INSERT INTO stopword VALUES ('significant','en');
INSERT INTO stopword VALUES ('significantly','en');
INSERT INTO stopword VALUES ('similar','en');
INSERT INTO stopword VALUES ('similarly','en');
INSERT INTO stopword VALUES ('since','en');
INSERT INTO stopword VALUES ('six','en');
INSERT INTO stopword VALUES ('slightly','en');
INSERT INTO stopword VALUES ('so','en');
INSERT INTO stopword VALUES ('some','en');
INSERT INTO stopword VALUES ('somehow','en');
INSERT INTO stopword VALUES ('someone','en');
INSERT INTO stopword VALUES ('somethan','en');
INSERT INTO stopword VALUES ('something','en');
INSERT INTO stopword VALUES ('sometime','en');
INSERT INTO stopword VALUES ('sometimes','en');
INSERT INTO stopword VALUES ('somewhat','en');
INSERT INTO stopword VALUES ('somewhere','en');
INSERT INTO stopword VALUES ('soon','en');
INSERT INTO stopword VALUES ('specifically','en');
INSERT INTO stopword VALUES ('state','en');
INSERT INTO stopword VALUES ('states','en');
INSERT INTO stopword VALUES ('still','en');
INSERT INTO stopword VALUES ('stop','en');
INSERT INTO stopword VALUES ('strongly','en');
INSERT INTO stopword VALUES ('substantially','en');
INSERT INTO stopword VALUES ('successfully','en');
INSERT INTO stopword VALUES ('such','en');
INSERT INTO stopword VALUES ('sufficiently','en');
INSERT INTO stopword VALUES ('suggest','en');
INSERT INTO stopword VALUES ('t','en');
INSERT INTO stopword VALUES ('taking','en');
INSERT INTO stopword VALUES ('than','en');
INSERT INTO stopword VALUES ('that','en');
INSERT INTO stopword VALUES ('thatll','en');
INSERT INTO stopword VALUES ('thats','en');
INSERT INTO stopword VALUES ('thatve','en');
INSERT INTO stopword VALUES ('the','en');
INSERT INTO stopword VALUES ('their','en');
INSERT INTO stopword VALUES ('theirs','en');
INSERT INTO stopword VALUES ('them','en');
INSERT INTO stopword VALUES ('themselves','en');
INSERT INTO stopword VALUES ('then','en');
INSERT INTO stopword VALUES ('thence','en');
INSERT INTO stopword VALUES ('there','en');
INSERT INTO stopword VALUES ('thereafter','en');
INSERT INTO stopword VALUES ('thereby','en');
INSERT INTO stopword VALUES ('thered','en');
INSERT INTO stopword VALUES ('therefore','en');
INSERT INTO stopword VALUES ('therein','en');
INSERT INTO stopword VALUES ('therell','en');
INSERT INTO stopword VALUES ('thereof','en');
INSERT INTO stopword VALUES ('therere','en');
INSERT INTO stopword VALUES ('theres','en');
INSERT INTO stopword VALUES ('thereto','en');
INSERT INTO stopword VALUES ('thereupon','en');
INSERT INTO stopword VALUES ('thereve','en');
INSERT INTO stopword VALUES ('these','en');
INSERT INTO stopword VALUES ('they','en');
INSERT INTO stopword VALUES ('theyd','en');
INSERT INTO stopword VALUES ('theyll','en');
INSERT INTO stopword VALUES ('theyre','en');
INSERT INTO stopword VALUES ('theyve','en');
INSERT INTO stopword VALUES ('this','en');
INSERT INTO stopword VALUES ('those','en');
INSERT INTO stopword VALUES ('thou','en');
INSERT INTO stopword VALUES ('though','en');
INSERT INTO stopword VALUES ('thoughh','en');
INSERT INTO stopword VALUES ('thousand','en');
INSERT INTO stopword VALUES ('throug','en');
INSERT INTO stopword VALUES ('through','en');
INSERT INTO stopword VALUES ('throughout','en');
INSERT INTO stopword VALUES ('thru','en');
INSERT INTO stopword VALUES ('thus','en');
INSERT INTO stopword VALUES ('til','en');
INSERT INTO stopword VALUES ('tip','en');
INSERT INTO stopword VALUES ('to','en');
INSERT INTO stopword VALUES ('together','en');
INSERT INTO stopword VALUES ('too','en');
INSERT INTO stopword VALUES ('toward','en');
INSERT INTO stopword VALUES ('towards','en');
INSERT INTO stopword VALUES ('trillion','en');
INSERT INTO stopword VALUES ('try','en');
INSERT INTO stopword VALUES ('two','en');
INSERT INTO stopword VALUES ('u','en');
INSERT INTO stopword VALUES ('under','en');
INSERT INTO stopword VALUES ('unless','en');
INSERT INTO stopword VALUES ('unlike','en');
INSERT INTO stopword VALUES ('unlikely','en');
INSERT INTO stopword VALUES ('until','en');
INSERT INTO stopword VALUES ('unto','en');
INSERT INTO stopword VALUES ('up','en');
INSERT INTO stopword VALUES ('upon','en');
INSERT INTO stopword VALUES ('ups','en');
INSERT INTO stopword VALUES ('us','en');
INSERT INTO stopword VALUES ('use','en');
INSERT INTO stopword VALUES ('used','en');
INSERT INTO stopword VALUES ('usefully','en');
INSERT INTO stopword VALUES ('usefulness','en');
INSERT INTO stopword VALUES ('using','en');
INSERT INTO stopword VALUES ('usually','en');
INSERT INTO stopword VALUES ('v','en');
INSERT INTO stopword VALUES ('various','en');
INSERT INTO stopword VALUES ('ve','en');
INSERT INTO stopword VALUES ('very','en');
INSERT INTO stopword VALUES ('via','en');
INSERT INTO stopword VALUES ('vol','en');
INSERT INTO stopword VALUES ('vols','en');
INSERT INTO stopword VALUES ('vs','en');
INSERT INTO stopword VALUES ('w','en');
INSERT INTO stopword VALUES ('was','en');
INSERT INTO stopword VALUES ('wasnt','en');
INSERT INTO stopword VALUES ('way','en');
INSERT INTO stopword VALUES ('we','en');
INSERT INTO stopword VALUES ('web','en');
INSERT INTO stopword VALUES ('wed','en');
INSERT INTO stopword VALUES ('well','en');
INSERT INTO stopword VALUES ('were','en');
INSERT INTO stopword VALUES ('werent','en');
INSERT INTO stopword VALUES ('weve','en');
INSERT INTO stopword VALUES ('what','en');
INSERT INTO stopword VALUES ('whatever','en');
INSERT INTO stopword VALUES ('whatll','en');
INSERT INTO stopword VALUES ('whats','en');
INSERT INTO stopword VALUES ('whatve','en');
INSERT INTO stopword VALUES ('when','en');
INSERT INTO stopword VALUES ('whence','en');
INSERT INTO stopword VALUES ('whenever','en');
INSERT INTO stopword VALUES ('where','en');
INSERT INTO stopword VALUES ('whereafter','en');
INSERT INTO stopword VALUES ('whereas','en');
INSERT INTO stopword VALUES ('whereby','en');
INSERT INTO stopword VALUES ('wherein','en');
INSERT INTO stopword VALUES ('wheres','en');
INSERT INTO stopword VALUES ('whereupon','en');
INSERT INTO stopword VALUES ('wherever','en');
INSERT INTO stopword VALUES ('whether','en');
INSERT INTO stopword VALUES ('which','en');
INSERT INTO stopword VALUES ('while','en');
INSERT INTO stopword VALUES ('whim','en');
INSERT INTO stopword VALUES ('whither','en');
INSERT INTO stopword VALUES ('who','en');
INSERT INTO stopword VALUES ('whod','en');
INSERT INTO stopword VALUES ('whoever','en');
INSERT INTO stopword VALUES ('whole','en');
INSERT INTO stopword VALUES ('wholl','en');
INSERT INTO stopword VALUES ('whom','en');
INSERT INTO stopword VALUES ('whomever','en');
INSERT INTO stopword VALUES ('whos','en');
INSERT INTO stopword VALUES ('whose','en');
INSERT INTO stopword VALUES ('why','en');
INSERT INTO stopword VALUES ('widely','en');
INSERT INTO stopword VALUES ('will','en');
INSERT INTO stopword VALUES ('with','en');
INSERT INTO stopword VALUES ('within','en');
INSERT INTO stopword VALUES ('without','en');
INSERT INTO stopword VALUES ('wont','en');
INSERT INTO stopword VALUES ('words','en');
INSERT INTO stopword VALUES ('world','en');
INSERT INTO stopword VALUES ('would','en');
INSERT INTO stopword VALUES ('wouldnt','en');
INSERT INTO stopword VALUES ('www','en');
INSERT INTO stopword VALUES ('x','en');
INSERT INTO stopword VALUES ('y','en');
INSERT INTO stopword VALUES ('yes','en');
INSERT INTO stopword VALUES ('yet','en');
INSERT INTO stopword VALUES ('you','en');
INSERT INTO stopword VALUES ('youd','en');
INSERT INTO stopword VALUES ('youll','en');
INSERT INTO stopword VALUES ('your','en');
INSERT INTO stopword VALUES ('youre','en');
INSERT INTO stopword VALUES ('yours','en');
INSERT INTO stopword VALUES ('yourself','en');
INSERT INTO stopword VALUES ('yourselves','en');
INSERT INTO stopword VALUES ('youve','en');
INSERT INTO stopword VALUES ('z','en');

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
  dateSubmitted datetime default NULL,
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
# Table structure for table 'url'
#

CREATE TABLE url (
  rec_id int(11) NOT NULL auto_increment,
  status int(11) NOT NULL default '0',
  url varchar(128) NOT NULL default '',
  content_type varchar(48) NOT NULL default '',
  title varchar(128) NOT NULL default '',
  txt varchar(255) NOT NULL default '',
  docsize int(11) NOT NULL default '0',
  last_index_time int(11) NOT NULL default '0',
  next_index_time int(11) NOT NULL default '0',
  last_mod_time int(11) NOT NULL default '0',
  referrer int(11) NOT NULL default '0',
  tag varchar(11) NOT NULL default '0',
  hops int(11) NOT NULL default '0',
  category varchar(11) NOT NULL default '',
  keywords varchar(255) NOT NULL default '',
  description varchar(100) NOT NULL default '',
  crc32 int(11) NOT NULL default '0',
  lang char(2) NOT NULL default '',
  PRIMARY KEY  (rec_id),
  UNIQUE KEY url (url),
  KEY key_crc (crc32)
) TYPE=MyISAM;

#
# Dumping data for table 'url'
#


#
# Table structure for table 'user'
#

CREATE TABLE user (
  userId int(11) NOT NULL default '0',
  username varchar(35) default NULL,
  identifier varchar(35) default NULL,
  email varchar(255) default NULL,
  icq varchar(30) default NULL,
  authMethod varchar(30) NOT NULL default 'WebGUI',
  ldapURL text,
  connectDN varchar(255) default NULL,
  PRIMARY KEY  (userId)
) TYPE=MyISAM;

#
# Dumping data for table 'user'
#

INSERT INTO user VALUES (1,'Visitor','No Login','','','WebGUI',NULL,NULL);
INSERT INTO user VALUES (2,'Reserved','No Login',NULL,NULL,'WebGUI',NULL,NULL);
INSERT INTO user VALUES (3,'Admin','RvlMjeFPs2aAhQdo/xt/Kg','','','WebGUI',NULL,NULL);
INSERT INTO user VALUES (4,'Reserved','No Login',NULL,NULL,'WebGUI',NULL,NULL);
INSERT INTO user VALUES (5,'Reserved','No Login',NULL,NULL,'WebGUI',NULL,NULL);
INSERT INTO user VALUES (6,'Reserved','No Login',NULL,NULL,'WebGUI',NULL,NULL);
INSERT INTO user VALUES (7,'Reserved','No Login',NULL,NULL,'WebGUI',NULL,NULL);
INSERT INTO user VALUES (8,'Reserved','No Login',NULL,NULL,'WebGUI',NULL,NULL);
INSERT INTO user VALUES (9,'Reserved','No Login',NULL,NULL,'WebGUI',NULL,NULL);
INSERT INTO user VALUES (10,'Reserved','No Login',NULL,NULL,'WebGUI',NULL,NULL);
INSERT INTO user VALUES (11,'Reserved','No Login',NULL,NULL,'WebGUI',NULL,NULL);
INSERT INTO user VALUES (12,'Reserved','No Login',NULL,NULL,'WebGUI',NULL,NULL);
INSERT INTO user VALUES (13,'Reserved','No Login',NULL,NULL,'WebGUI',NULL,NULL);
INSERT INTO user VALUES (14,'Reserved','No Login',NULL,NULL,'WebGUI',NULL,NULL);
INSERT INTO user VALUES (15,'Reserved','No Login',NULL,NULL,'WebGUI',NULL,NULL);
INSERT INTO user VALUES (16,'Reserved','No Login',NULL,NULL,'WebGUI',NULL,NULL);
INSERT INTO user VALUES (17,'Reserved','No Login',NULL,NULL,'WebGUI',NULL,NULL);
INSERT INTO user VALUES (18,'Reserved','No Login',NULL,NULL,'WebGUI',NULL,NULL);
INSERT INTO user VALUES (19,'Reserved','No Login',NULL,NULL,'WebGUI',NULL,NULL);
INSERT INTO user VALUES (20,'Reserved','No Login',NULL,NULL,'WebGUI',NULL,NULL);
INSERT INTO user VALUES (21,'Reserved','No Login',NULL,NULL,'WebGUI',NULL,NULL);
INSERT INTO user VALUES (22,'Reserved','No Login',NULL,NULL,'WebGUI',NULL,NULL);
INSERT INTO user VALUES (23,'Reserved','No Login',NULL,NULL,'WebGUI',NULL,NULL);
INSERT INTO user VALUES (24,'Reserved','No Login',NULL,NULL,'WebGUI',NULL,NULL);
INSERT INTO user VALUES (25,'Reserved','No Login',NULL,NULL,'WebGUI',NULL,NULL);

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
  dateAdded datetime default NULL,
  addedBy int(11) default NULL,
  lastEdited datetime default NULL,
  editedBy int(11) default NULL,
  PRIMARY KEY  (widgetId)
) TYPE=MyISAM;

#
# Dumping data for table 'widget'
#


