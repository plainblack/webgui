insert into webguiVersion values ('4.5.0','upgrade',unix_timestamp());
insert into international values (72,'Poll',1,'Randomize answers?');
alter table Poll add column randomizeAnswers int not null default 0;


