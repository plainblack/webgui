insert into webguiVersion values ('3.7.0','upgrade',unix_timestamp());

update settings set value=1 where value='yes';
update settings set value=0 where value='no';
INSERT INTO settings VALUES ('textAreaRows','5');
INSERT INTO settings VALUES ('textAreaCols','50');
INSERT INTO settings VALUES ('textBoxSize','30');

delete from users where username='Reserved';
delete from groups where groupName='Reserved';
delete from page where title='Reserved';
delete from style where name='Reserved';
INSERT INTO incrementer VALUES ('profileCategoryId',1000);



CREATE TABLE userProfileData (
  userId int(11) NOT NULL default '0',
  fieldName varchar(128) NOT NULL default '',
  fieldData text,
  PRIMARY KEY  (userId,fieldName)
) TYPE=MyISAM;

insert into userProfileData select userId,'email',email from users;
insert into userProfileData select userId,'firstName',firstName from users;
insert into userProfileData select userId,'middleName',middleName from users;
insert into userProfileData select userId,'lastName',lastName from users;
insert into userProfileData select userId,'icq',icq from users;
insert into userProfileData select userId,'aim',aim from users;
insert into userProfileData select userId,'msnIM',msnIM from users;
insert into userProfileData select userId,'yahooIM',yahooIM from users;
insert into userProfileData select userId,'cellPhone',cellPhone from users;
insert into userProfileData select userId,'pager',pager from users;
insert into userProfileData select userId,'language',language from users;
insert into userProfileData select userId,'homeAddress',homeAddress from users;
insert into userProfileData select userId,'homeCity',homeCity from users;
insert into userProfileData select userId,'homeState',homeState from users;
insert into userProfileData select userId,'homeZip',homeZip from users;
insert into userProfileData select userId,'homeCountry',homeCountry from users;
insert into userProfileData select userId,'homePhone',homePhone from users;
insert into userProfileData select userId,'workAddress',workAddress from users;
insert into userProfileData select userId,'workCity',workCity from users;
insert into userProfileData select userId,'workState',workState from users;
insert into userProfileData select userId,'workZip',workZip from users;
insert into userProfileData select userId,'workCountry',workCountry from users;
insert into userProfileData select userId,'workPhone',workPhone from users;
insert into userProfileData select userId,'gender',gender from users;
insert into userProfileData select userId,'birthdate',birthdate from users;
insert into userProfileData select userId,'homeURL',homepage from users;

alter table users drop column email;
alter table users drop column language;
alter table users drop column firstName;
alter table users drop column middleName;
alter table users drop column lastName;
alter table users drop column icq;
alter table users drop column aim;
alter table users drop column msnIM;
alter table users drop column yahooIM;
alter table users drop column homeAddress;
alter table users drop column homeCity;
alter table users drop column homeState;
alter table users drop column homeZip;
alter table users drop column homeCountry;
alter table users drop column homePhone;
alter table users drop column workAddress;
alter table users drop column workCity;
alter table users drop column workState;
alter table users drop column workZip;
alter table users drop column workCountry;
alter table users drop column workPhone;
alter table users drop column cellPhone;
alter table users drop column pager;
alter table users drop column gender;
alter table users drop column birthdate;
alter table users drop column homepage;

alter table users add column dateCreated int not null default '1019867418';
alter table users add column lastUpdated int not null default '1019867418';

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
INSERT INTO international VALUES (468,'WebGUI','English','Add/Edit User Profile Category');
INSERT INTO international VALUES (469,'WebGUI','English','Id');
INSERT INTO international VALUES (470,'WebGUI','English','Name');
INSERT INTO international VALUES (471,'WebGUI','English','Add/Edit User Profile Field');
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

CREATE TABLE userProfileCategory (
  profileCategoryId int(11) NOT NULL default '0',
  categoryName varchar(255) default NULL,
  sequenceNumber int(11) NOT NULL default '1',
  PRIMARY KEY  (profileCategoryId)
) TYPE=MyISAM;
INSERT INTO userProfileCategory VALUES (1,'WebGUI::International::get(449,\"WebGUI\");',6);
INSERT INTO userProfileCategory VALUES (2,'WebGUI::International::get(440,\"WebGUI\");',2);
INSERT INTO userProfileCategory VALUES (3,'WebGUI::International::get(439,\"WebGUI\");',1);
INSERT INTO userProfileCategory VALUES (4,'WebGUI::International::get(445,\"WebGUI\");',7);
INSERT INTO userProfileCategory VALUES (5,'WebGUI::International::get(443,\"WebGUI\");',3);
INSERT INTO userProfileCategory VALUES (6,'WebGUI::International::get(442,\"WebGUI\");',4);
INSERT INTO userProfileCategory VALUES (7,'WebGUI::International::get(444,\"WebGUI\");',5);

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


