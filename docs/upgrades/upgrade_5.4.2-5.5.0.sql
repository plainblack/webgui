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

insert into international (internationalId,languageId,namespace,message,lastUpdated) values (81,1,'Survey','Anonymous responses?',1059069492);
delete from international where languageId=1 and namespace='Survey' and internationalId=4;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (4,1,'Survey','Surveys allow you to gather information from your users. In the case of WebGUI surveys, you can also use them to test your user\'s knowledge.\r\n<p/>\r\n\r\n<b>Question Order</b><br/>\r\nThe order the questions will be asked. Sequential displays the questions in the order you create them. Random displays the questions randomly. Response driven displays the questions in order based on the responses of the users.\r\n<p/>\r\n\r\n<b>Mode</b><br/>\r\nBy default the Survey is in survey mode. This allows it to ask questions of your users. However, if you switch to Quiz mode, you can have a self-correcting test of your user\'s knowledge.\r\n<p/>\r\n\r\n<b>Anonymous responses?</b><br/>\r\nSelect whether or not the survey will record and display information that can identify a user and their responses.  If left at the default value of "No", the survey will record the user\'s IP address as well as their WebGUI User ID and Username if logged in.  This info will then be available in the survey\'s reports.  If set to "Yes", these three fields will contain scrambled data that can not be traced to a particular user.\r\n<p/>\r\n\r\n<b>Who can take the survey?</b><br/>\r\nWhich users can participate in the survey?\r\n<p/>\r\n\r\n\r\n<b>Who can view reports?</b><br/>\r\nWho can view the results of the survey?\r\n<p/>\r\n\r\n\r\n<b>What next?</b><br/>\r\nIf you leave this set at its default, then you will add a question directly after adding the survey.\r\n<p/>\r\n',1059069492);
alter table Survey add column anonymous char(1) not null default 0;
alter table Survey_response change userId userId varchar(11);

