insert into webguiVersion values ('6.2.6','upgrade',unix_timestamp());
update collateralFolder set parentId='0' where parentId='-1' and collateralFolderId<>'0';
alter table WSClient change call callMethod text;

