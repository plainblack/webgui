insert into webguiVersion values ('6.5.0','upgrade',unix_timestamp());
alter table asset add column isPrototype int not null default 0;
alter table asset add index isPrototype_className_assetId (isPrototype,className,assetId);
update Folder set templateId='PBtmpl0000000000000078' where templateId='';
