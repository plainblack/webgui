insert into webguiVersion values ('6.0.3','upgrade',unix_timestamp());
delete from international where internationalId=981 and namespace='WebGUI';
INSERT INTO international VALUES (981,'WebGUI',1,'Manage database links.',1056151382,NULL);
delete from replacements where replacementId=0;


