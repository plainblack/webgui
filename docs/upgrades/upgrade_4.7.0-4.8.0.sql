insert into webguiVersion values ('4.8.0','upgrade',unix_timestamp());
update incrementer set nextValue=100000 where incrementerId='messageId';
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (748,1,'WebGUI','User Count', 1036553016);





