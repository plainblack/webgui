insert into webguiVersion values ('6.6.2','upgrade',unix_timestamp());
alter table Shortcut add disableContentLock int(11) NOT NULL default '0';
