insert into webguiVersion values ('6.1.0','upgrade',unix_timestamp());
drop table language;
drop table international;
drop table help;
alter table WSClient add sharedCache tinyint unsigned not null default '0';
alter table WSClient add cacheTTL smallint(5) unsigned NOT NULL default '60';
INSERT INTO template VALUES (1,'Default Account Macro','<a class="myAccountLink" href="<tmpl_var account.url>"><tmpl_var account.text></a>','Macro/a_account',1,1);
INSERT INTO template VALUES (1,'Default Editable Toggle Macro','<a href="<tmpl_var toggle.url>"><tmpl_var toggle.text></a>','Macro/EditableToggle',1,1);
INSERT INTO template VALUES (1,'Default Admin Toggle Macro','<a href="<tmpl_var toggle.url>"><tmpl_var toggle.text></a>','Macro/AdminToggle',1,1);
INSERT INTO template VALUES (1,'Default File Macro','<a href="<tmpl_var file.url>"><img src="<tmpl_var file.icon>" align="middle" border="0" /><tmpl_var file.name></a>','Macro/File',1,1);
INSERT INTO template VALUES (2,'File no icon','<a href="<tmpl_var file.url>"><tmpl_var file.name></a>','Macro/File',1,1);
INSERT INTO template VALUES (3,'File with size','<a href="<tmpl_var file.url>"><img src="<tmpl_var file.icon>" align="middle" border="0" /><tmpl_var file.name></a>(<tmpl_var file.size>)','Macro/File',1,1);
INSERT INTO template VALUES (1,'Default Group Add Macro','<a href="<tmpl_var group.url>"><tmpl_var group.text></a>','Macro/GroupAdd',1,1);
INSERT INTO template VALUES (1,'Default Group Delete Macro','<a href="<tmpl_var group.url>"><tmpl_var group.text></a>','Macro/GroupDelete',1,1);
INSERT INTO template VALUES (1,'Default Homelink','<a class="homeLink" href="<tmpl_var homeLink.url>"><tmpl_var homeLink.text></a>','Macro/H_homeLink',1,1);
INSERT INTO template VALUES (1,'Default Make Printable','<a class="makePrintableLink" href="<tmpl_var printable.url>"><tmpl_var printable.text></a>','Macro/r_printable',1,1);
INSERT INTO template VALUES (1,'Default LoginToggle','<a class="loginToggleLink" href="<tmpl_var toggle.url>"><tmpl_var toggle.text></a>','Macro/LoginToggle',1,1);
INSERT INTO template VALUES (1, 'Attachment Box', '<p>\r\n  <table cellpadding=3 cellspacing=0 border=1>\r\n  <tr>   \r\n    <td class="tableHeader">\r\n<a href="<tmpl_var attachment.url>"><img src="<tmpl_var session.config.extrasURL>/attachment.gif" border="0" alt="<tmpl_var attachment.name>"></a></td><td>\r\n<a href="<tmpl_var attachment.url>"><img src="<tmpl_var attachment.icon>" align="middle" width="16" height="16" border="0" alt="<tmpl_var attachment.name>"><tmpl_var attachment.name></a>\r\n    </td>\r\n  </tr>\r\n  </table>\r\n</p>\r\n', 'AttachmentBox', 1, 1);
 

