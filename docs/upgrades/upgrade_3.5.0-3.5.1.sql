create table webguiVersion (
webguiVersion varchar(10),
versionType varchar(30),
dateApplied int
);
insert into webguiVersion values ('3.5.1','upgrade',unix_timestamp());
