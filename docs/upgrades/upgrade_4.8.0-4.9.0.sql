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





