insert into webguiVersion values ('6.1.0','upgrade',unix_timestamp());
drop table language;
drop table international;
drop table help;
alter table WSClient add sharedCache tinyint unsigned not null default '0';
alter table WSClient add cacheTTL smallint(5) unsigned NOT NULL default '60';
INSERT INTO template VALUES (1,'Default Account','<a class="myAccountLink" href="<tmpl_var account.url>"><tmpl_var account.text></a>','Macro/a_account',1,1);
INSERT INTO template VALUES (1,'Default Editable Toggle','<a href="<tmpl_var toggle.url>"><tmpl_var toggle.text></a>','Macro/EditableToggle',1,1);
INSERT INTO template VALUES (1,'Default Admin Toggle','<a href="<tmpl_var toggle.url>"><tmpl_var toggle.text></a>','Macro/AdminToggle',1,1);

