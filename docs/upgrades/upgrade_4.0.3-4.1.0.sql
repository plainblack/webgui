insert into webguiVersion values ('4.1.0','upgrade',unix_timestamp());
alter table users add column karma int not null default 0;
alter table groups add column karmaThreshold int not null default 99999999999;
create table karmaLog (
 userId int not null,
 amount int not null default 1,
 source varchar(255),
 description text
);

