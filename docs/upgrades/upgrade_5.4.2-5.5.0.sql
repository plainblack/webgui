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
  parentId int not null,
  forumThreadId int not null,
  userId int not null,
  username varchar(30),
  subject varchar(255),
  message text,
  dateOfPost int,
  views int,
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
