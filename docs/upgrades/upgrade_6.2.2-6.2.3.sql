insert into webguiVersion values ('6.2.3','upgrade',unix_timestamp());
update collateralFolder set parentId='-1' where collateralFolderId='0';

delete from template where namespace='Navigation' and templateId='6';

INSERT INTO template VALUES ('6','dtree','^StyleSheet(\"<tmpl_var session.config.extrasURL>/Navigation/dtree/dtree.css\");\r\n^JavaScript(\"<tmpl_var session.config.extrasURL>/Navigation/dtree/dtree.js\");\r\n\r\n<tmpl_if session.var.adminOn>\r\n<tmpl_var config.button>\r\n</tmpl_if>\r\n\r\n<script>\r\n// Path to dtree directory\r\n_dtree_url = \"<tmpl_var session.config.extrasURL>/Navigation/dtree/\";\r\n</script>\r\n\r\n<div class=\"dtree\">\r\n<script type=\"text/javascript\">\r\n<!--\r\n	d = new dTree(\'d\');\r\n	<tmpl_loop page_loop>\r\n	d.add(\r\n		\'<tmpl_var page.pageId>\',\r\n		<tmpl_if __first__>-99<tmpl_else>\'<tmpl_var page.parentId>\'</tmpl_if>,\r\n		\'<tmpl_var page.menuTitle>\',\r\n		\'<tmpl_var page.url>\',\r\n		\'<tmpl_var page.synopsis>\'\r\n		<tmpl_if page.newWindow>,\'_blank\'</tmpl_if>\r\n	);\r\n	</tmpl_loop>\r\n	document.write(d);\r\n//-->\r\n</script>\r\n\r\n</div>','Navigation',1,1);

