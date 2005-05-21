insert into webguiVersion values ('6.6.1','upgrade',unix_timestamp());
insert into settings values ('commerceSendDailyReportTo', '');
alter table Navigation change anscestorEndPoint ancestorEndPoint int not null default 55;
alter table groups add ldapGroup varchar(255) default NULL;
alter table groups add ldapGroupProperty varchar(255) default NULL;
alter table groups add ldapRecursiveProperty varchar(255) default NULL;
