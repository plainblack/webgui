insert into webguiVersion values ('6.4.0','upgrade',unix_timestamp());
alter table asset add index state_parentId_lineage (state,parentId,lineage);


