insert into webguiVersion values ('5.2.3','upgrade',unix_timestamp());
delete from template where templateId=2 and namespace='Item';
INSERT INTO template VALUES (2,'Item w/pop-up Links','<tmpl_if displaytitle>\r\n   <tmpl_if linkurl>\r\n       <a href=\"<tmpl_var linkurl>\" target=\"_blank\">\r\n    </tmpl_if>\r\n     <span class=\"itemTitle\"><tmpl_var title></span>\r\n   <tmpl_if linkurl>\r\n      </a>\r\n    </tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_if attachment.name>\r\n   <tmpl_if displaytitle> - </tmpl_if>\r\n   <a href=\"<tmpl_var attachment.url>\" target=\"_blank\"><img src=\"<tmpl_var attachment.Icon>\" border=\"0\" alt=\"<tmpl_var attachment.name>\" width=\"16\" height=\"16\" border=\"0\" align=\"middle\" /></a>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n  - <tmpl_var description>\r\n</tmpl_if>','Item');
delete from international where languageId=2 and namespace='Survey' and internationalId=66;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (66,2,'Survey','Geantwortet', 1049146849);
delete from international where languageId=2 and namespace='Survey' and internationalId=53;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (53,2,'Survey','Geantwortet', 1049146653);
delete from international where languageId=2 and namespace='Survey' and internationalId=69;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (69,2,'Survey','Antworten dieses Benutzers löschen.', 1049146361);
delete from international where languageId=2 and namespace='Survey' and internationalId=70;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (70,2,'Survey','Individuelle Antworten', 1049146347);
delete from international where languageId=2 and namespace='Survey' and internationalId=72;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (72,2,'Survey','Sind Sie sicher, dass Sie die Antworten dieses Benutzers löschen möchten?', 1049146334);
delete from international where languageId=2 and namespace='Survey' and internationalId=55;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (55,2,'Survey','Antworten anschauen.', 1049146220);
delete from international where languageId=2 and namespace='Survey' and internationalId=74;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (74,2,'Survey','Sind Sie sicher, dass Sie alle Antworten löschen möchten?', 1049146085);
delete from international where languageId=2 and namespace='Survey' and internationalId=73;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (73,2,'Survey','Alle Antworten löschen.', 1049146069);
delete from international where languageId=2 and namespace='WebGUI' and internationalId=891;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (891,2,'WebGUI','Nur Makros blockieren.', 1049099974);
delete from international where languageId=2 and namespace='WebGUI' and internationalId=526;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (526,2,'WebGUI','JavaScript entfernen und blockiere Makros.', 1049099918);



