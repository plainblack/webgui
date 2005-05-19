insert into webguiVersion values ('6.6.1','upgrade',unix_timestamp());
insert into settings values ('commerceSendDailyReportTo', '');
ALTER TABLE navigation CHANGE COLUMN anscestorEndPoint ancestorEndPoint INTEGER NOT NULL DEFAULT 55;
alter table groups add ldapGroup varchar(255) default NULL;
alter table groups add ldapGroupProperty varchar(255) default NULL;
alter table groups add ldapRecursiveProperty varchar(255) default NULL; 