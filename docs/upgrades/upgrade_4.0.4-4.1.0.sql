insert into webguiVersion values ('4.1.0','upgrade',unix_timestamp());
alter table users add column karma int not null default 0;
alter table groups add column karmaThreshold int not null default 1000000000;
create table karmaLog (
 userId int not null,
 amount int not null default 1,
 source varchar(255),
 description text
);
INSERT INTO international VALUES (537,'WebGUI','English','Karma');
INSERT INTO international VALUES (538,'WebGUI','English','Karma Threshold');
delete from groupings where groupId=1 or groupId=2 or groupId=7;
INSERT INTO international VALUES (539,'WebGUI','English','Enable Karma?');
INSERT INTO international VALUES (540,'WebGUI','English','Karma Per Login');
INSERT INTO settings VALUES ('useKarma','0');
INSERT INTO settings VALUES ('karmaPerLogin','1');
alter table Poll add column karmaPerVote int not null default 0;
INSERT INTO international VALUES (20,'Poll','English','Karma Per Vote');
INSERT INTO international VALUES (541,'WebGUI','English','Karma Per Post');
INSERT INTO international VALUES (30,'UserSubmission','English','Karma Per Submission');
alter table UserSubmission add column karmaPerSubmission int not null default 0;
alter table UserSubmission add column karmaPerPost int not null default 0;
alter table MessageBoard add column karmaPerPost int not null default 0;
alter table Article add column karmaPerPost int not null default 0;
CREATE TABLE imageGroup (
  imageGroupId int(11) NOT NULL auto_increment,
  name varchar(128) NOT NULL default 'untitled',
  parentId int(11) NOT NULL default '0',
  description varchar(255) default NULL,
  PRIMARY KEY  (imageGroupId),
  UNIQUE KEY imageGroupId (imageGroupId)
);
INSERT INTO incrementer VALUES('imageGroupId',1);
INSERT INTO imageGroup (imageGroupId, name, parentId, description) VALUES (0, 'Root', 0, 'Top level');
alter table images add column imageGroupId int not null default 0;
INSERT INTO groups (groupId, groupName, description) VALUES (9, 'Image Managers', 'Users that have privileges to add, edit, and delete images from the image manager. Content managers can view by default');
INSERT INTO international VALUES (542,'WebGUI','English','Previous..');
INSERT INTO international VALUES (543,'WebGUI','English','Add a new group');
INSERT INTO international VALUES (544,'WebGUI','English','Are you certain you wish to delete this group?');
INSERT INTO international VALUES (545,'WebGUI','English','Editing Image group');
INSERT INTO international VALUES (546,'WebGUI','English','Group Id');
INSERT INTO international VALUES (547,'WebGUI','English','Parent group');
INSERT INTO international VALUES (548,'WebGUI','English','Group name');
INSERT INTO international VALUES (549,'WebGUI','English','Group description');
INSERT INTO international VALUES (550,'WebGUI','English','View Image group');
INSERT INTO international VALUES (382,'WebGUI','English','Edit Image');

