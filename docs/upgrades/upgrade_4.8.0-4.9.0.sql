insert into webguiVersion values ('4.9.0','upgrade',unix_timestamp());
create table authentication (userId int(11) not null, authMethod varchar(30) not null, fieldName varchar(128) not null, fieldData text, primary key (userId, authMethod, fieldName));
insert into authentication select userId,'LDAP','ldapUrl',ldapURL from users;
insert into authentication select userId,'LDAP','connectDN',connectDN from users;
insert into authentication select userId,'WebGUI','identifier',identifier from users;
alter table users drop column identifier;
alter table users drop column ldapURL;
alter table users drop column connectDN;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (814,1,'WebGUI','Back to styles.', 1038022043);
alter table collateral change parameters parameters text;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (815,1,'WebGUI','The file you tried to upload is too large.', 1038023800);
delete from international where languageId=1 and namespace='FileManager' and internationalId=9;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (9,1,'FileManager','Edit File Manager', 1038028499);
delete from international where languageId=1 and namespace='FileManager' and internationalId=61;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (61,1,'FileManager','File Manager, Add/Edit', 1038028480);
delete from international where languageId=1 and namespace='FileManager' and internationalId=1;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (1,1,'FileManager','File Manager', 1038028463);
alter table page add column userDefined1 varchar(255);
alter table page add column userDefined2 varchar(255);
alter table page add column userDefined3 varchar(255);
alter table page add column userDefined4 varchar(255);
alter table page add column userDefined5 varchar(255);
alter table discussion add column userDefined1 varchar(255);
alter table discussion add column userDefined2 varchar(255);
alter table discussion add column userDefined3 varchar(255);
alter table discussion add column userDefined4 varchar(255);
alter table discussion add column userDefined5 varchar(255);
delete from international where languageId=1 and namespace='WebGUI' and internationalId=495;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (495,1,'WebGUI','htmlArea (default)', 1038159820);
insert into settings (name,value) values ('smbPDC','your PDC');
insert into settings (name,value) values ('smbBDC','your BDC');
insert into settings (name,value) values ('smbDomain','your NT Domain');
insert into settings (name,value) values ('selfDeactivation',1);
delete from groups where groupId=9;
delete from groupings where groupId=9;
delete from groupGroupings where groupId=9;
delete from groupGroupings where inGroup=9;





