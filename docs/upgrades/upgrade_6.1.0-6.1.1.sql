insert into webguiVersion values ('6.1.1','upgrade',unix_timestamp());
delete from groups where groupId=10;
delete from groupings where groupId=10;
delete from groupGroupings where groupId=10 or inGroup=10; 

