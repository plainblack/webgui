insert into webguiVersion values ('5.5.0','upgrade',unix_timestamp());
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (1004,1,'WebGUI','Cache external groups for how long?',1057208065);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (1005,1,'WebGUI','SQL Query',1057208065);
delete from international where languageId=1 and namespace='WebGUI' and internationalId=622;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (622,1,'WebGUI','See <i>Manage Group</i> for a description of grouping functions and the default groups.\r\n<p>\r\n\r\n<b>Group Name</b><br>\r\nA name for the group. It is best if the name is descriptive so you know what it is at a glance.\r\n<p>\r\n\r\n<b>Description</b><br>\r\nA longer description of the group so that other admins and content managers (or you if you forget) will know what the purpose of this group is.\r\n<p>\r\n\r\n<b>Expire Offset</b><br>\r\nThe amount of time that a user will belong to this group before s/he is expired (or removed) from it. This is very useful for membership sites where users have certain privileges for a specific period of time. \r\n<p>\r\n<b>NOTE:</b> This can be overridden on a per-user basis.\r\n<p>\r\n\r\n<b>Notify user about expiration?</b><br>\r\nSet this value to yes if you want WebGUI to contact the user when they are about to be expired from the group.\r\n<p>\r\n\r\n<b>Expire Notification Offset</b><br>\r\nThe difference in the number of days from the expiration to the notification. You may set this to any valid integer. For instance, set this to "0" if you wish the notification to be sent on the same day that the grouping expires. Set it to "-7" if you want the notification to go out 7 days <b>before</b> the grouping expires. Set it to "7" if you wish the notification to be sent 7 days after the expiration.\r\n<p>\r\n\r\n<b>Expire Notification Message</b><br>\r\nType the message you wish to be sent to the user telling them about the expiration.\r\n<p>\r\n\r\n<b>Delete Offset</b><br>\r\nThe difference in the number of days from the expiration to the grouping being deleted from the system. You may set this to any valid integer. For instance, set this to "0" if you wish the grouping to be deleted on the same day that the grouping expires. Set it to "-7" if you want the grouping to be deleted 7 days <b>before</b> the grouping expires. Set it to "7" if you wish the grouping to be deleted 7 days after the expiration.\r\n<p>\r\n\r\n<b>IP Address</b><br>\r\nSpecify an IP address or an IP mask to match. If the user\'s IP address matches, they\'ll automatically be included in this group. An IP mask is simply the IP address minus an octet or two. You may also specify multiple IP masks separated by semicolons.\r\n<p>\r\n<i>IP Mask Example:</i> 10.;192.168.;101.42.200.142\r\n<p>\r\n\r\n<b>Karma Threshold</b><br>\r\nIf you\'ve enabled Karma, then you\'ll be able to set this value. Karma Threshold is the amount of karma a user must have to be considered part of this group.\r\n<p>\r\n\r\n\r\n<b>Users can add themselves?</b><br>\r\nDo you wish to let users add themselves to this group? See the GroupAdd macro for more info.\r\n<p>\r\n\r\n<b>Users can remove themselves?</b><br>\r\nDo you wish to let users remove themselves from this group? See the GroupDelete macro for more info.\r\n<p>\r\n\r\n<i>The following options are recommended only for advanced WebGUI administrators.</i>\r\n<p>\r\n\r\n<b>Database Link</b><br>\r\nIf you\'d like to have this group validate users using an external database, choose the database link to use.\r\n<p>\r\n\r\n<b>SQL Query</b><br>\r\nMany organizations have external databases that map users to groups; for example an HR database might map Employee ID to Health Care Plan.  To validate users against an external database, you need to construct a SQL statement that will return 1 if a user is in the group.  Make sure to begin your statement with "select 1".  You may use macros in this query to access data in a user\'s profile, such as Employee ID.  Here is an example that checks a user against a fictional HR database.  This assumes you have created an additional profile field called employeeId.<br>\r\n<br>\r\nselect 1 from employees, health_plans, empl_plan_map<br>\r\nwhere employees.employee_id = ^User("employeeId");<br>\r\nand health_plans.plan_name = \'HMO 1\'<br>\r\nand employees.employee_id = empl_plan_map.employee_id<br>\r\nand health_plans.health_plan_id = empl_plan_mp.health_plan_id<br>\r\n<br>\r\nThis group could then be named "Employees in HMO 1", and would allow you to restrict any page or wobject to only those users who are part of this health plan in the external database.\r\n<p>\r\n\r\n<b>Cache external groups for how long?</b><br>\r\nLarge sites using external group data will be making many calls to the external database.  To help reduce the load, you may select how long you\'d like to cache the results of the external database query within the WebGUI database.  More advanced background caching may be included in a future version of WebGUI.',1053779630);

create table forum (
  forumId int not null primary key,
  addEditStampToPosts int not null default 1,
  filterPosts varchar(30) default 'javascript',
  karmaPerPost int not null default 0,
  groupToPost int not null default 2,
  editTimeout int not null default 3600,
  moderatePosts int not null default 0,
  groupToModerate int not null default 4,
  attachmentsPerPost int not null default 0,
  allowRichEdit int not null default 1,
  allowReplacements int not null default 1
);

create table forumReplacement (
  forumReplacementId int not null primary key,
  pattern varchar(255),
  replaceWith varchar(255)
);

create table forumPost (
  forumPostId int not null primary key,
  parentId int not null default 0,
  forumThreadId int not null,
  userId int not null,
  username varchar(30),
  subject varchar(255),
  message text,
  dateOfPost int,
  views int not null default 0,
  status varchar(30) not null default 'approved',
  contentType varchar(30) not null default 'some html'
);

create table forumPostAttachment (
  forumPostAttachmentId int not null primary key,
  forumPostId int not null,
  filename varchar(255)
);

create table forumThread (
  forumThreadId int not null primary key,
  forumId int not null,
  rootPostId int not null,
  views int not null,
  replies int not null,
  lastPostId int not null,
  lastPostDate int not null,
  isLocked int not null,
  isSticky int not null
);

create table forumRead (
  userId int not null,
  forumPostId int not null,
  forumThreadId int not null,
  lastRead int not null,
  primary key (userId, forumPostId)
);

create table forumBookmark (
  userId int not null,
  forumPostId int not null,
  primary key (userId, forumPostId)
);

create table forumThreadSubscription (
   forumThreadId int not null,
   userId int not null,
   primary key (forumThreadId, userId)
);

create table forumSubscription (
   forumId int not null,
   userId int not null,
   primary key (forumId, userId)
);


alter table groups add column databaseLinkId int not null default 0;
alter table groups add column dbCacheTimeout int not null default 3600;
alter table groups add column dbQuery text;

insert into settings (name, value) values('encryptLogin', 0);
insert into international (internationalId, namespace, languageId, message, lastUpdated) values(1006, 'WebGUI', 1, 'Encrypt Login?', 1057208065);
delete from international where languageId=1 and namespace='WebGUI' and internationalId=607;
INSERT INTO international VALUES (607,'WebGUI',1,'<b>Anonymous Registration</b><br>\r\nDo you wish visitors to your site to be able to register themselves?\r\n<br><br>\r\n\r\n<b>Run On Registration</b><br>\r\nIf there is a command line specified here, it will be executed each time a user registers anonymously.\r\n<p>\r\n\r\n<b>Enable Karma?</b><br>\r\nShould karma be enabled?\r\n<p>\r\n\r\n<b>Karma Per Login</b><br>\r\nThe amount of karma a user should be given when they log in. This only takes affect if karma is enabled.\r\n<p>\r\n\r\n<b>Session Timeout</b><br>\r\nThe amount of time that a user session remains active (before needing to log in again). This timeout is reset each time a user views a page. Therefore if you set the timeout for 8 hours, a user would have to log in again if s/he hadn\'t visited the site for 8 hours.\r\n<p>\r\n\r\n<b>Allow users to deactivate their account?</b><br>\r\nDo you wish to provide your users with a means to deactivate their account without your intervention?\r\n<p>\r\n\r\n<b>Authentication Method (default)</b><br>\r\nWhat should the default authentication method be for new accounts that are created? The two available options are WebGUI and LDAP. WebGUI authentication means that the users will authenticate against the username and password stored in the WebGUI database. LDAP authentication means that users will authenticate against an external LDAP server.\r\n<br><br>\r\n\r\n<i>NOTE:</i> Authentication settings can be customized on a per user basis.\r\n\r\n\r\n\r\n<p>\r\n<b>NOTE:</b> Depending upon what authentication modules you have installed in your system you\'ll see any number of options after this point. The following are the options for the two defaultly installed authentication methods.\r\n<p>\r\n\r\n<b>Encrypt Login?</b><br>\r\nShould the system use the https protocol for the login form?  Note that setting this option to true will only encrypt the authentication itself, not anything else before or after the authentication.\r\n<p>\r\n\r\n<h2>WebGUI Authentication Options</h2>\r\n\r\n<b>Send welcome message?</b><br>\r\nDo you wish WebGUI to automatically send users a welcome message when they register for your site? \r\n<p>\r\n<b>NOTE:</b> In addition to the message you specify below, the user\'s account information will be included in the message.\r\n<p>\r\n\r\n<b>Welcome Message</b> <br>\r\nType the message that you\'d like to be sent to users upon registration.\r\n<p>\r\n\r\n<b>Recover Password Message</b><br>\r\nType a message that will be sent to your users if they try to recover their WebGUI password.\r\n<p>\r\n\r\n<h2>LDAP Authentication Options</h2>\r\n\r\n<b>LDAP URL (default)</b><br>\r\nThe default url to your LDAP server. The LDAP URL takes the form of <b>ldap://[server]:[port]/[base DN]</b>. Example: ldap://ldap.mycompany.com:389/o=MyCompany.\r\n<br><br>\r\n\r\n\r\n\r\n\r\n<b>LDAP Identity</b><br>\r\nThe LDAP Identity is the unique identifier in the LDAP server that the user will be identified against. Often this field is <b>shortname</b>, which takes the form of first initial + last name. Example: jdoe. Therefore if you specify the LDAP identity to be <i>shortname</i> then Jon Doe would enter <i>jdoe</i> during the registration process.\r\n<br><br>\r\n\r\n<b>LDAP Identity Name</b><br>\r\nThe label used to describe the LDAP Identity to the user. For instance, some companies use an LDAP server for their proxy server users to authenticate against. In the documentation or training already provided to their users, the LDAP identity is known as their <i>Web Username</i></b><i>. So you could enter that label here for consitency.\r\n<br><br>\r\n\r\n<b>LDAP Password Name</b><br>\r\nJust as the LDAP Identity Name is a label, so is the LDAP Password Name. Use this label as you would LDAP Identity Name.\r\n<p>\r\n\r\n',1044708602,NULL);

insert into international (internationalId,languageId,namespace,message,lastUpdated) values (81,1,'Survey','Anonymous responses?',1059069492);
delete from international where languageId=1 and namespace='Survey' and internationalId=4;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (4,1,'Survey','Surveys allow you to gather information from your users. In the case of WebGUI surveys, you can also use them to test your user\'s knowledge.\r\n<p/>\r\n\r\n<b>Question Order</b><br/>\r\nThe order the questions will be asked. Sequential displays the questions in the order you create them. Random displays the questions randomly. Response driven displays the questions in order based on the responses of the users.\r\n<p/>\r\n\r\n<b>Mode</b><br/>\r\nBy default the Survey is in survey mode. This allows it to ask questions of your users. However, if you switch to Quiz mode, you can have a self-correcting test of your user\'s knowledge.\r\n<p/>\r\n\r\n<b>Anonymous responses?</b><br/>\r\nSelect whether or not the survey will record and display information that can identify a user and their responses.  If left at the default value of "No", the survey will record the user\'s IP address as well as their WebGUI User ID and Username if logged in.  This info will then be available in the survey\'s reports.  If set to "Yes", these three fields will contain scrambled data that can not be traced to a particular user.\r\n<p/>\r\n\r\n<b>Who can take the survey?</b><br/>\r\nWhich users can participate in the survey?\r\n<p/>\r\n\r\n\r\n<b>Who can view reports?</b><br/>\r\nWho can view the results of the survey?\r\n<p/>\r\n\r\n\r\n<b>What next?</b><br/>\r\nIf you leave this set at its default, then you will add a question directly after adding the survey.\r\n<p/>\r\n',1059069492);
alter table Survey add column anonymous char(1) not null default 0;
alter table Survey_response change userId userId varchar(11);

insert into international (internationalId,languageId,namespace,message,lastUpdated) values (7,1,'SiteMap','Alphabetic?',1057208065);
alter table SiteMap add column alphabetic int(11) not null default 0;
delete from international where languageId=1 and namespace='SiteMap' and internationalId=71;
insert into international values (71,'SiteMap',1,'Site maps are used to provide additional navigation in WebGUI. You could set up a traditional site map that would display a hierarchical view of all the pages in the site. On the other hand, you could use site maps to provide extra navigation at certain levels in your site.\r\n<br><br>\r\n\r\n<b>Template</b><br/>\r\nChoose a layout for this site map.\r\n<p/>\r\n\r\n<b>Start With</b><br>\r\nSelect the page that this site map should start from.\r\n<br><br>\r\n\r\n<b>Depth To Traverse</b><br>\r\nHow many levels deep of navigation should the Site Map show? If 0 (zero) is specified, it will show as many levels as there are.\r\n<p>\r\n\r\n<b>Indent</b><br>\r\nHow many characters should indent each level?\r\n<p>\r\n\r\n<b>Alphabetic?</b><br>\r\nIf this setting is true, site map entries are sorted alphabetically.  If this setting is false, site map entries are sorted by the page sequence order (editable via the up and down arrows in the page toolbar).\r\n<p>\r\n\r\n',1039908464,NULL);
delete from international where languageId=1 and namespace='WebGUI' and internationalId=606;
insert into international values (606,'WebGUI',1,'Think of pages as containers for content. For instance, if you want to write a letter to the editor of your favorite magazine you\'d get out a notepad (or open a word processor) and start filling it with your thoughts. The same is true with WebGUI. Create a page, then add your content to the page.\r\n<p>\r\n\r\n<b>Title</b><br>\r\nThe title of the page is what your users will use to navigate through the site. Titles should be descriptive, but not very long.\r\n<p>\r\n\r\n\r\n<b>Menu Title</b><br>\r\nA shorter or altered title to appear in navigation. If left blank this will default to <i>Title</i>.\r\n<p>\r\n\r\n<b>Page URL</b><br>\r\nWhen you create a page a URL for the page is generated based on the page title. If you are unhappy with the URL that was chosen, you can change it here.\r\n<p>\r\n\r\n<b>Redirect URL</b><br>\r\nWhen this page is visited, the user will be redirected to the URL specified here. \r\n<p>\r\n<b>NOTE:</b> The redirects will be disabled while in admin mode in order to make it easier to edit the properties of the page.\r\n<p>\r\n\r\n\r\n<b>Hide from navigation?</b><br>\r\nSelect yes to hide this page from the navigation menus and site maps.\r\n<p>\r\n<B>NOTE:</b> This will not hide the page from the page tree (Administrative functions... &gt; Manage page tree.), only from navigation macros and from site maps.\r\n<p>\r\n\r\n<b>Open in new window?</b><br>\r\nSelect yes to open this page in a new window. This is often used in conjunction with the <b>Redirect URL</b> parameter.\r\n<p>\r\n\r\n\r\n\r\n<b>Language</b><br/>\r\nChoose the default language for this page. All WebGUI generated messages will appear in that language and the character set will be changed to the character set for that language.\r\n<p/>\r\n\r\n<P><B>Cache Timeout</B><BR>The amount of time this page should remain cached for registered users. \r\n\r\n<P><B>Cache Timeout (Visitors)</B><BR>The amount of time this page should remain cached for visitors. \r\n\r\n<P><B>NOTE:</B> Page caching is only available if your administrator has installed the Cache::FileCache Perl module. Using page caching can improve site performance by as much as 1000%.&nbsp;\r\n\r\n\r\n<b>Template</b><br>\r\nBy default, WebGUI has one big content area to place wobjects. However, by specifying a template other than the default you can sub-divide the content area into several sections.\r\n<p>\r\n\r\n<b>Synopsis</b><br>\r\nA short description of a page. It is used to populate default descriptive meta tags as well as to provide descriptions on Site Maps.\r\n<p>\r\n\r\n<b>Meta Tags</b><br>\r\nMeta tags are used by some search engines to associate key words to a particular page. There is a great site called <a href=\"http://www.metatagbuilder.com/\">Meta Tag Builder</a> that will help you build meta tags if you\'ve never done it before.\r\n<p>\r\n\r\n<i>Advanced Users:</i> If you have other things (like JavaScript) you usually put in the  area of your pages, you may put them here as well.\r\n<p>\r\n\r\n<b>Use default meta tags?</b><br>\r\nIf you don\'t wish to specify meta tags yourself, WebGUI can generate meta tags based on the page title and your company\'s name. Check this box to enable the WebGUI-generated meta tags.\r\n<p>\r\n\r\n\r\n<b>Style</b><br>\r\nBy default, when you create a page, it inherits a few traits from its parent. One of those traits is style. Choose from the list of styles if you would like to change the appearance of this page. See <i>Add Style</i> for more details.\r\n<p>\r\n\r\nIf you select \"Yes\" below the style pull-down menu, all of the pages below this page will take on the style you\'ve chosen for this page.\r\n<p>\r\n\r\n<b>Start Date</b><br>\r\nThe date when users may begin viewing this page. Note that before this date only content managers with the rights to edit this page will see it.\r\n<p>\r\n\r\n<b>End Date</b><br>\r\nThe date when users will stop viewing this page. Note that after this date only content managers with the rights to edit this page will see it.\r\n<p>\r\n\r\n\r\n<b>Owner</b><br>\r\nThe owner of a page is usually the person who created the page. This user always has full edit and viewing rights on the page.\r\n<p>\r\n<b>NOTE:</b> The owner can only be changed by an administrator.\r\n<p>\r\n\r\n\r\n<b>Who can view?</b><br>\r\nChoose which group can view this page. If you want both visitors and registered users to be able to view the page then you should choose the \"Everybody\" group.\r\n<p>\r\n\r\n<b>Who can edit?</b><br>\r\nChoose the group that can edit this page. The group assigned editing rights can also always view the page.\r\n<p>\r\n\r\nYou can optionally recursively give these privileges to all pages under this page.\r\n<p>\r\n\r\n<b>What next?</b><br/>\r\nIf you leave this on the default setting you\'ll be redirected to the new page after creating it.\r\n<p/>',1056293101,NULL);

alter table SyndicatedContent add column maxHeadlines int(11) not null default 0;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (3,1,'SyndicatedContent','Maximum Number of Headlines',1057208065); 
delete from international where languageId=1 and namespace='SyndicatedContent' and internationalId=71;
INSERT INTO international VALUES (71,'SyndicatedContent',1,'Syndicated content is content that is pulled from another site using the RDF/RSS specification. This technology is often used to pull headlines from various news sites like <a href=\"http://www.cnn.com/\">CNN</a> and  <a href=\"http://slashdot.org/\">Slashdot</a>. It can, of course, be used for other things like sports scores, stock market info, etc.\r\n<br><br>\r\n\r\n<b>URL to RSS file</b><br>\r\nProvide the exact URL (starting with http://) to the syndicated content\'s RDF or RSS file. The syndicated content will be downloaded from this URL hourly.\r\n<br><br>\r\nYou can find syndicated content at the following locations:\r\n</p><ul>\r\n<li><a href=\"http://www.newsisfree.com/\">http://www.newsisfree.com</a>\r\n</li><li><a href=\"http://www.syndic8.com/\">http://www.syndic8.com</a>\r\n</li><li><a href=\"http://www.voidstar.com/node.php?id=144\">http://www.voidstar.com/node.php?id=144</a>\r\n</li><li><a href=\"http://my.userland.com/\">http://my.userland.com</a>\r\n</li><li><a href=\"http://www.webreference.com/services/news/\">http://www.webreference.com/services/news/</a>\r\n</li><li><a href=\"http://www.xmltree.com/\">http://www.xmltree.com</a>\r\n</li><li><a href=\"http://w.moreover.com/\">http://w.moreover.com/</a>\r\n</li></ul>\r\n\r\n<p>\r\n\r\nTo create an aggregate RSS feed, include a list of space separated urls instead of a single url.  For an aggregate feed, the system will display an equal number of headlines from each source, sorted by the date the system first received the story.<p>\r\n\r\n<b>Template</b><br>\r\nSelect a template for this content.\r\n<p><b>Maximum Headlines</b><br>\r\nEnter the maximum number of headlines that should be displayed.  For an aggregate feed, the system will display an equal number of headlines from each source, even if doing so requires displaying more than the requested maximum number of headlines.  Set to zero to allow any number of headlines.\r\n<p>',1047855741,NULL);

insert into international (internationalId,languageId,namespace,message,lastUpdated) values (90,1,'DataForm','Delete this entry.',1057208065);
delete from template where templateId=1 and namespace='DataForm';
INSERT INTO template VALUES (1,'Mail Form','<tmpl_if displayTitle>\n    <h1><tmpl_var title></h1>\n</tmpl_if>\n\n<tmpl_loop error_loop>\n  <li><b><tmpl_var error.message></b>\n</tmpl_loop>\n\n\n<tmpl_if description>\n    <tmpl_var description><p />\n</tmpl_if>\n\n<tmpl_if canEdit>\n      <a href=\"<tmpl_var entryList.url>\"><tmpl_var entryList.label></a>\n      &middot; <a href=\"<tmpl_var export.tab.url>\"><tmpl_var export.tab.label></a>\n      <tmpl_if entryId>\n        &middot; <a href=\"<tmpl_var delete.url>\"><tmpl_var delete.label></a>\n      </tmpl_if>\n      <tmpl_if session.var.adminOn>\n          &middot; <a href=\"<tmpl_var addField.url>\"><tmpl_var addField.label></a>\n     </tmpl_if>\n   <p /> \n</tmpl_if>\n\n<tmpl_var form.start>\n<table>\n<tmpl_loop field_loop>\n  <tmpl_unless field.isHidden>\n     <tr><td class=\"formDescription\" valign=\"top\">\n        <tmpl_if session.var.adminOn><tmpl_if canEdit><tmpl_var field.controls></tmpl_if></tmpl_if>\n        <tmpl_var field.label>\n     </td><td class=\"tableData\" valign=\"top\">\n       <tmpl_if field.isDisplayed>\n            <tmpl_var field.value>\n       <tmpl_else>\n            <tmpl_var field.form>\n       </tmpl_if>\n        <tmpl_if field.required>*</tmpl_if>\n        <span class=\"formSubtext\"><br /><tmpl_var field.subtext></span>\n     </td></tr>\n  </tmpl_unless>\n</tmpl_loop>\n<tr><td></td><td><tmpl_var form.send></td></tr>\n</table>\n\n<tmpl_var form.end>\n','DataForm');

insert into incrementer values ('forumId',1000);
insert into incrementer values ('forumThreadId',1000);
insert into incrementer values ('forumPostId',1000);
delete from international where languageId=1 and namespace='WebGUI' and internationalId=1010;
insert into international (internationalId,languageId,namespace,message,lastUpdated,context) values (1010,1,'WebGUI','Text', 1060433369,'A content type of text.');
delete from international where languageId=1 and namespace='WebGUI' and internationalId=1011;
insert into international (internationalId,languageId,namespace,message,lastUpdated,context) values (1011,1,'WebGUI','Code', 1060433339,'A content type of source code.');
delete from international where languageId=1 and namespace='WebGUI' and internationalId=1009;
insert into international (internationalId,languageId,namespace,message,lastUpdated,context) values (1009,1,'WebGUI','HTML', 1060433286,'A content type of HTML.');
delete from international where languageId=1 and namespace='WebGUI' and internationalId=1008;
insert into international (internationalId,languageId,namespace,message,lastUpdated,context) values (1008,1,'WebGUI','Mixed Text and HTML', 1060433234,'A content type of mixed HTML and text.');
delete from international where languageId=1 and namespace='WebGUI' and internationalId=1007;
insert into international (internationalId,languageId,namespace,message,lastUpdated,context) values (1007,1,'WebGUI','Content Type', 1060432032,'The type of content to be posted, like HTML, source code, text, etc.');
delete from international where languageId=1 and namespace='WebGUI' and internationalId=1013;
insert into international (internationalId,languageId,namespace,message,lastUpdated,context) values (1013,1,'WebGUI','Make sticky?', 1060434033,'A message indicating whether the moderator wants to make this message stay at the top of the discussion.');
delete from international where languageId=1 and namespace='WebGUI' and internationalId=1012;
insert into international (internationalId,languageId,namespace,message,lastUpdated,context) values (1012,1,'WebGUI','Lock this thread?', 1060433963,'A message indicating whether the moderator wants to lock the thread as he posts.');
alter table HttpProxy add column searchFor varchar(255);
alter table HttpProxy add column stopAt varchar(255);
insert into international (internationalId,languageId,namespace,message,lastUpdated,context) values (13,1,'HttpProxy','Search for', 1060433963,'A string used as starting point when proxying parts of remote content.');
insert into international (internationalId,languageId,namespace,message,lastUpdated,context) values (14,1,'HttpProxy','Stop at', 1060433963,'A string used as ending point when proxying parts of remote content.');
INSERT INTO template VALUES (1,'Default HTTP Proxy','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n    <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_if search.for>\r\n  <tmpl_if content>\r\n    <!-- Display search string. Remove if unwanted -->\r\n    <tmpl_var search.for>\r\n  <tmpl_else>\r\n    <!-- Error: Starting point not found -->\r\n    <b>Error: Search string <i><tmpl_var search.for></i> not found in content.</b>\r\n  </tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_var content>\r\n\r\n<tmpl_if stop.at>\r\n  <tmpl_if content.trailing>\r\n    <!-- Display stop search string. Remove if unwanted -->\r\n    <tmpl_var stop.at>\r\n  <tmpl_else>\r\n    <!-- Warning: End point not found -->\r\n    <b>Warning: Ending search point <i><tmpl_var stop.at></i> not found in content.</b>\r\n  </tmpl_if>\r\n</tmpl_if>','HttpProxy');
UPDATE international set message = 'The HTTP Proxy wobject is a very powerful tool. It enables you to embed external sites and applications into your site. For example, if you have a web mail system that you wish your staff could access through the intranet, then you could use the HTTP Proxy to accomplish that.\r\n\r\n<p>\r\n\r\n<b>URL</b><br>\r\nThe starting URL for the proxy.\r\n<p>\r\n\r\n<b>Follow redirects?</b><br>\r\nSometimes the URL to a page, is actually a redirection to another page. Do you wish to follow those redirections when they occur?\r\n<p>\r\n\r\n<b>Rewrite urls?</b><br>\r\nSwitch this to No if you want to deeplink an external page.\r\n<p>\r\n\r\n<b>Timeout</b><br>\r\nThe amount of time (in seconds) that WebGUI should wait for a connection before giving up on an external page.\r\n<p>\r\n\r\n<b>Remove style?</b><br>\r\nDo you wish to remove the stylesheet from the proxied content in favor of the stylesheet from your site?\r\n<p>\r\n\r\n<b>Filter Content</b><br>\r\nChoose the level of HTML filtering you wish to apply to the proxied content.\r\n<p>\r\n\r\n<b>Search for</b><br>\r\nA search string used as starting point. Use this when you want to display only a part of the proxied content. Content before this point is not displayed\r\n<p>\r\n\r\n<b>Stop at</b><br>\r\nA search string used as ending point. Content after this point is not displayed.\r\n<p>\r\n<i>Note: The <b>Search for</b> and <b>Stop at</b> strings are included in the content. You can change this by editing the template for HttpProxy.</i>\r\n<p>\r\n\r\n<b>Allow proxying of other domains?</b><br>\r\nIf you proxy a site like Yahoo! that links to other domains, do you wish to allow the user to follow the links to those other domains, or should the proxy stop them as they try to leave the original site you specified?\r\n<p>\r\n' where internationalId = 11 and namespace = 'HttpProxy' and languageId = 1;
update international set internationalId=1014, namespace='WebGUI' where internationalId='17' and namespace='MessageBoard';
update international set internationalId=1015, namespace='WebGUI' where internationalId='11' and namespace='MessageBoard';
alter table users add column referringAffiliate int not null default 0;
update users set referringAffiliate=1 where userId<>1;
delete from international where namespace='WebGUI' and internationalId=573;
update international set internationalId=1016, namespace='WebGUI' where internationalId=19 and namespace='MessageBoard';
update international set internationalId=1017, namespace='WebGUI' where internationalId=20 and namespace='MessageBoard';
delete from international where namespace='WebGUI' and internationalId=237;
delete from international where namespace='WebGUI' and internationalId=238;
delete from international where namespace='WebGUI' and internationalId=239;
delete from international where namespace='WebGUI' and internationalId=1014;
delete from international where namespace='WebGUI' and internationalId=1015;
delete from international where languageId=1 and namespace='WebGUI' and internationalId=512;
insert into international (internationalId,languageId,namespace,message,lastUpdated,context) values (512,1,'WebGUI','Go to next thread.', 1065280309,NULL);
delete from international where languageId=1 and namespace='WebGUI' and internationalId=513;
insert into international (internationalId,languageId,namespace,message,lastUpdated,context) values (513,1,'WebGUI','Go to previous thread.', 1065280287,NULL);
insert into international (internationalId,languageId,namespace,message,lastUpdated,context) values (1019,1,'WebGUI','Back to thread list.', 1065280160,'Return to the list of threads in a discussion.');
insert into international (internationalId,languageId,namespace,message,lastUpdated,context) values (1018,1,'WebGUI','Start a new thread.', 1065279960,'Add a new line of discussion to a forum.');
insert into international (internationalId,languageId,namespace,message,lastUpdated,context) values (1020,1,'WebGUI','Rating', 1065280882,'How useful/interesting a user thinks another poster\'s post is.');
alter table forumThread add column status varchar(30) not null default 'approved';
create table forumPostRating ( forumPostId int not null, userId int not null, ipAddress varchar(16), dateOfRating int, rating int not null);
alter table forumPost add column rating int not null default 0;
insert into international (internationalId,languageId,namespace,message,lastUpdated,context) values (1021,1,'WebGUI','Rate Message', 1065356764,'A label indicating that the following links are to be used for discussion post ratings.');
alter table forumThread add column rating int not null;
delete from international where languageId=1 and namespace='WebGUI' and internationalId=875;
insert into international (internationalId,languageId,namespace,message,lastUpdated,context) values (875,1,'WebGUI','A new message has been posted to one of your subscriptions.', 1065874019,NULL);
insert into international (internationalId,languageId,namespace,message,lastUpdated,context) values (1023,1,'WebGUI','Unsubscribe from discussion.', 1065875186,'A label for a link that unsubscribes the user from the discussion they are currently viewing.');
insert into international (internationalId,languageId,namespace,message,lastUpdated,context) values (1022,1,'WebGUI','Subscribe to discussion.', 1065875027,'A label for a link that subscribes the user to the discussion they are currently viewing.');
delete from international where languageId=1 and namespace='WebGUI' and internationalId=874;
insert into international (internationalId,languageId,namespace,message,lastUpdated,context) values (874,1,'WebGUI','Unsubscribe from thread.', 1065876868,NULL);
delete from international where languageId=1 and namespace='WebGUI' and internationalId=873;
insert into international (internationalId,languageId,namespace,message,lastUpdated,context) values (873,1,'WebGUI','Subscribe to thread.', 1065876827,NULL);
alter table forum add column views int not null default 0;
alter table forum add column replies int not null default 0;
alter table forum add column rating int not null default 0;
alter table wobject add column forumId int;
delete from international where languageId=1 and namespace='WebGUI' and internationalId=567;
delete from international where languageId=1 and namespace='WebGUI' and internationalId=568;
delete from international where languageId=1 and namespace='WebGUI' and internationalId=569;
update international set internationalId=1024, namespace='WebGUI' where internationalId=1 and namespace='Discussion';
update international set internationalId=1025, namespace='WebGUI' where internationalId=524 and namespace='Discussion';
insert into international (internationalId,languageId,namespace,message,lastUpdated,context) values (1028,1,'WebGUI','Moderate posts?', 1065966284,'Asking the admin whether they wish to moderate the posts in a discussion or just allow all posts to go out.');
insert into international (internationalId,languageId,namespace,message,lastUpdated,context) values (1027,1,'WebGUI','Allow replacements?', 1065966244,'Asking the admin whether they wish to allow text replacements in a discussion.');
insert into international (internationalId,languageId,namespace,message,lastUpdated,context) values (1026,1,'WebGUI','Allow rich edit?', 1065966219,'Asking the admin whether they wish to allow rich edit in a discussion.');
update international set internationalId=1029, namespace='WebGUI' where internationalId=525 and namespace='Discussion';
update international set internationalId=1030, namespace='WebGUI' where internationalId=526 and namespace='Discussion';


