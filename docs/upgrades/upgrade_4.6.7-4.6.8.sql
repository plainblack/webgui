insert into webguiVersion values ('4.6.8','upgrade',unix_timestamp());
delete from international where internationalId=12 and namespace='Poll');
INSERT INTO international VALUES (12,'Poll',1,'Total Votes:',1031514049);
INSERT INTO international VALUES (12,'Poll',7,'总投票人数:',1031514049);'
alter table page modify title varchar(255) null;
update international set lastUpdated='1031510000' where lastUpdated='1031516049';
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (723,1,'WebGUI','Deprecated', 1031800566);
delete from international where languageId=1 and namespace='WebGUI' and internationalId=727;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (727,1,'WebGUI','Your password cannot be "password".', 1031880154);
delete from international where languageId=1 and namespace='WebGUI' and internationalId=725;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (725,1,'WebGUI','Your username cannot be blank.', 1031879612);
delete from international where languageId=1 and namespace='WebGUI' and internationalId=724;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (724,1,'WebGUI','Your username cannot begin or end with a space.', 1031879593);
delete from international where languageId=1 and namespace='WebGUI' and internationalId=726;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (726,1,'WebGUI','Your password cannot be blank.', 1031879567);





