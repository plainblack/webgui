insert into webguiVersion values ('5.3.3','upgrade',unix_timestamp());
delete from international where internationalId=29 and namespace='DataForm' and languageId=1;
insert into international (internationalId,namespace,languageId,message,lastUpdated) values (29,'DataForm',1,'is required',1031515049);
delete from international where languageId=1 and namespace='WebGUI' and internationalId=775;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (775,1,'WebGUI','Are you certain you wish to delete this folder? It cannot be recovered once deleted.',1055877319);
