insert into webguiVersion values ('5.4.0','upgrade',unix_timestamp());
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (979,1,'WebGUI','Are you certain you wish to delete all items in this folder? They cannot be recovered once deleted. Items in sub-folders will not be removed.',1055908341);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (980,1,'WebGUI','Empty this folder.',1055908341);
alter table HttpProxy add column rewriteUrls int;
update HttpProxy set rewriteUrls = 1;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (12,1,'HttpProxy','Rewrite urls ?',1055908341);
