insert into webguiVersion values ('5.4.1','upgrade',unix_timestamp());
update SQLReport set databaseLinkId = 0 where databaseLinkId is null;
