insert into webguiVersion values ('4.1.0','upgrade',unix_timestamp());
alter table users add column karma int not null default 0;
alter table groups add column karmaThreshold int not null default 1000000000;
create table karmaLog (
 userId int not null,
 amount int not null default 1,
 source varchar(255),
 description text
);
INSERT INTO international VALUES (537,'WebGUI','English','Karma');
INSERT INTO international VALUES (538,'WebGUI','English','Karma Threshold');
delete from groupings where groupId=1 or groupId=2 or groupId=7;
INSERT INTO international VALUES (539,'WebGUI','English','Enable Karma?');
INSERT INTO international VALUES (540,'WebGUI','English','Karma Per Login');
INSERT INTO settings VALUES ('useKarma','0');
INSERT INTO settings VALUES ('karmaPerLogin','1');


