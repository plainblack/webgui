insert into webguiVersion values ('6.1.0','upgrade',unix_timestamp());
drop table language;
drop table international;
drop table help;
alter table WSClient add sharedCache tinyint unsigned not null default '0';
alter table WSClient add cacheTTL smallint(5) unsigned NOT NULL default '60';

