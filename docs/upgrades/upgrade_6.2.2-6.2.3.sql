insert into webguiVersion values ('6.2.3','upgrade',unix_timestamp());
update collateralFolder set parentId='-1' where parentId='0';

