insert into webguiVersion values ('3.9.0','upgrade',unix_timestamp());
alter table style add column body text;
update style set body=concat('^AdminBar;\n\n',header,'\n\n^-;\n\n',footer);
alter table style drop column header;
alter table style drop column footer;
delete from international where internationalId=152 and namespace='WebGUI';
delete from international where internationalId=153 and namespace='WebGUI';
INSERT INTO international VALUES (501,'WebGUI','English','Body');
alter table style change name name varchar(255);
create table template (
  templateId int not null primary key,
  name varchar(255),
  template text
);
INSERT INTO international VALUES (502,'WebGUI','English','Are you certain you wish to delete this template and set all pages using this template to the default template?');
INSERT INTO international VALUES (503,'WebGUI','English','Template ID');
INSERT INTO international VALUES (504,'WebGUI','English','Template');
INSERT INTO international VALUES (505,'WebGUI','English','Add a new template.');
INSERT INTO groups VALUES (8,'Template Managers','Users that have privileges to edit templates for this site.',314496000);
INSERT INTO international VALUES (506,'WebGUI','English','Manage Templates');
INSERT INTO international VALUES (507,'WebGUI','English','Edit Template');
INSERT INTO international VALUES (508,'WebGUI','English','Manage templates.');
INSERT INTO incrementer VALUES ('templateId',1000);
INSERT INTO template VALUES (1,'Default','<table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" width=\"100%\">\r\n<tr>\r\n  <td valign=\"top\" class=\"content\">^0;</td>\r\n</tr>\r\n</table>');
INSERT INTO template VALUES (2,'News','<table cellpadding=\"3\" cellspacing=\"0\" border=\"0\" width=\"100%\">\r\n<tr>\r\n  <td valign=\"top\" class=\"content\" colspan=\"2\" width=\"100%\">^0;</td></tr>\r\n<tr>\r\n  <td valign=\"top\" class=\"content\" width=\"50%\">^1;</td>\r\n  <td valign=\"top\" class=\"content\" width=\"50%\">^2;</td>\r\n</tr>\r\n<tr>\r\n  <td valign=\"top\" class=\"content\" colspan=\"2\" width=\"100%\">^3;</td>\r\n</tr>\r\n</table>\r\n');
INSERT INTO template VALUES (3,'One Over Three','<table cellpadding=\"3\" cellspacing=\"0\" border=\"0\" width=\"100%\">\r\n<tr>\r\n  <td valign=\"top\" class=\"content\" colspan=\"3\">^0;</td>\r\n</tr>\r\n<tr>\r\n  <td valign=\"top\" class=\"content\" width=\"33%\">^1;</td>\r\n  <td valign=\"top\" class=\"content\" width=\"34%\">^2;</td>\r\n  <td valign=\"top\" class=\"content\" width=\"33%\">^3;</td>\r\n</tr>\r\n</table>');
INSERT INTO template VALUES (4,'Three Over One','<table cellpadding=\"3\" cellspacing=\"0\" border=\"0\" width=\"100%\">\r\n<tr>\r\n  <td valign=\"top\" class=\"content\" width=\"33%\">^0;</td>\r\n  <td valign=\"top\" class=\"content\" width=\"34%\">^1;</td>\r\n  <td valign=\"top\" class=\"content\" width=\"33%\">^2;</td>\r\n</tr>\r\n<tr>\r\n  <td valign=\"top\" class=\"content\" colspan=\"3\">^3;</td>\r\n</tr>\r\n</table>');
INSERT INTO template VALUES (5,'Left Column','<table cellpadding=\"3\" cellspacing=\"0\" border=\"0\" width=\"100%\">\r\n<tr>\r\n  <td valign=\"top\" class=\"content\" width=\"34%\">^0;</td>\r\n  <td valign=\"top\" class=\"content\" width=\"66%\">^1;</td>\r\n</tr>\r\n</table>');
INSERT INTO template VALUES (6,'Right Column','<table cellpadding=\"3\" cellspacing=\"0\" border=\"0\" width=\"100%\">\r\n<tr>\r\n  <td valign=\"top\" class=\"content\" width=\"66%\">^0;</td>\r\n  <td valign=\"top\" class=\"content\" width=\"34%\">^1;</td>\r\n</tr>\r\n</table>\r\n');
INSERT INTO template VALUES (7,'Side By Side','<table cellpadding=\"3\" cellspacing=\"0\" border=\"0\" width=\"100%\">\r\n<tr>\r\n  <td valign=\"top\" class=\"content\" width=\"50%\">^0;</td>\r\n  <td valign=\"top\" class=\"content\" width=\"50%\">^1;</td>\r\n</tr>\r\n</table>\r\n');
alter table page add column templateId int not null default 1;
update page set templateId=1 where template='Default';
update page set templateId=1 where template='A';
update page set templateId=2 where template='News';
update page set templateId=3 where template='OneOverThree';
update page set templateId=3 where template='One Over Three';
update page set templateId=4 where template='ThreeOverOne';
update page set templateId=4 where template='Three Over One';
update page set templateId=5 where template='LeftColumn';
update page set templateId=5 where template='Left Column';
update page set templateId=6 where template='RightColumn';
update page set templateId=6 where template='Right Column';
update page set templateId=7 where template='SideBySide';
update page set templateId=7 where template='Side By Side';
alter table page drop column template;
update wobject set templatePosition=0 where templatePosition='A';
update wobject set templatePosition=1 where templatePosition='B';
update wobject set templatePosition=2 where templatePosition='C';
update wobject set templatePosition=3 where templatePosition='D';
alter table UserSubmission add column allowDiscussion int not null default 0;
alter table UserSubmission add column editTimeout int not null default 1;
alter table UserSubmission add column groupToPost int not null default 2;
alter table UserSubmission add column groupToApprove int not null default 4;
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
alter table UserSubmission add column displayThumbnails int not null default 0;
INSERT INTO international VALUES (52,'UserSubmission','English','Thumbnail');
alter table UserSubmission add column layout varchar(30) not null default 'traditional';
INSERT INTO international VALUES (53,'UserSubmission','English','Layout');
INSERT INTO international VALUES (54,'UserSubmission','English','Web Log');
INSERT INTO international VALUES (55,'UserSubmission','English','Traditional');
INSERT INTO international VALUES (56,'UserSubmission','English','Photo Gallery');
INSERT INTO international VALUES (57,'UserSubmission','English','Responses');
alter table FAQ add column tocOn int not null default 1;
alter table FAQ add column topOn int not null default 0;
alter table FAQ add column qaOn int not null default 0;
INSERT INTO international VALUES (11,'FAQ','English','Turn TOC on?');
INSERT INTO international VALUES (12,'FAQ','English','Turn Q/A on?');
INSERT INTO international VALUES (13,'FAQ','English','Turn [top] link on?');
INSERT INTO international VALUES (14,'FAQ','English','Q');
INSERT INTO international VALUES (15,'FAQ','English','A');
INSERT INTO international VALUES (16,'FAQ','English','[top]');
INSERT INTO international VALUES (509,'WebGUI','English','Discussion Layout');
INSERT INTO international VALUES (510,'WebGUI','English','Flat');
INSERT INTO international VALUES (511,'WebGUI','English','Threaded');
INSERT INTO userProfileField VALUES ('discussionLayout','WebGUI::International::get(509)',1,0,'select','{\r\n  threaded=>WebGUI::International::get(511),\r\n  flat=>WebGUI::International::get(510)\r\n}','[threaded]',5,4,0);
INSERT INTO international VALUES (512,'WebGUI','English','Next Thread');
INSERT INTO international VALUES (513,'WebGUI','English','Previous Thread');
delete from international where internationalId=10 and namespace='MessageBoard';
delete from international where internationalId=14 and namespace='MessageBoard';















