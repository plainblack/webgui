insert into webguiVersion values ('5.1.1','upgrade',unix_timestamp());
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (888,1,'WebGUI','Snippet Preview Length', 1045312362);
delete from international where internationalId=148 and namespace='WebGUI' and languageId=1;
INSERT INTO international VALUES (148,'WebGUI',1,'Wobjects',1045312362);
