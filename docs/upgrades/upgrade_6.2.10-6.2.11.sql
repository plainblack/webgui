insert into webguiVersion values ('6.2.11','upgrade',unix_timestamp());
update page set isSystem=0, parentId='0' where pageId='1';


