insert into webguiVersion values ('5.2.0','upgrade',unix_timestamp());
alter table MailForm_field add column validation varchar(255) default NULL;
alter table MailForm_field add column subtext mediumtext default NULL;
alter table MailForm_field add column rows int(11) default NULL;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (27,1,'MailForm','Height', 1045210016);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (28,1,'MailForm','Optional for TextArea', 1045210016);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (29,1,'MailForm','is a required field.', 1045210016);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (30,1,'MailForm','has to be a number.', 1045210016);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (31,1,'MailForm','is not filled in correctly.', 1045210016);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (32,1,'MailForm','is not a valid email address.', 1045210016);
update international set message="Possible Values" where namespace = "MailForm" and internationalId = 24 and languageId=1;

