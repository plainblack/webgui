insert into webguiVersion values ('6.5.6','upgrade',unix_timestamp());
alter table metaData_values drop primary key;
alter table metaData_values add primary key (fieldId,assetId);

