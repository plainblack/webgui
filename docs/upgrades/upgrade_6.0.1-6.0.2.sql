insert into webguiVersion values ('6.0.2','upgrade',unix_timestamp());
update language set toolbar='german' where languageId=2;
alter table language change toolbar toolbar varchar(35) not null default 'metal';

