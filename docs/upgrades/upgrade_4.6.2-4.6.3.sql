insert into webguiVersion values ('4.6.3','upgrade',unix_timestamp());
delete from international where internationalId=716 and namespace='WebGUI' and languageId=1;
delete from international where internationalId=717 and namespace='WebGUI' and languageId=1;
insert into international values (716,'WebGUI',1,'Login');
insert into international values (717,'WebGUI',1,'Logout');
delete from international where internationalId=624 and namespace='WebGUI' and languageId=1;







