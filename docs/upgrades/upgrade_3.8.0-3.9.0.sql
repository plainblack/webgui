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







