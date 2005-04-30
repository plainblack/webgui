insert into webguiVersion values ('6.6.0','upgrade',unix_timestamp());
update template set template='^StyleSheet(^Extras;/slidePanel/slidePanel.css);\r\n^JavaScript(^Extras;/slidePanel/slidePanel.js);\r\n\r\n<script type=\"text/javascript\">\r\n\r\n  var slider = new createSlidePanelBar(\'WebGUIAdminBar\');\r\n  var panel;\r\n\r\n  panel = new createPanel(\'adminconsole\',\'Admin Console\');\r\n<tmpl_loop adminConsole_loop>\r\n <tmpl_if canUse>\r\n	panel.addLink(\'<tmpl_var icon.small>\',\'<tmpl_var title>\',\"<tmpl_var url>\");\r\n </tmpl_if>\r\n</tmpl_loop>\r\n  slider.addPanel(panel);\r\n\r\n  panel = new createPanel(\'clipboard\',\'Clipboard\');\r\n<tmpl_loop clipboard_loop>\r\n	panel.addLink(\'<tmpl_var icon.small>\',\'<tmpl_var label>\',\"<tmpl_var url>\");\r\n</tmpl_loop>\r\n  slider.addPanel(panel);\r\n\r\n  panel = new createPanel(\'packages\',\'Packages\');\r\n<tmpl_loop package_loop>\r\n	panel.addLink(\'<tmpl_var icon.small>\',\'<tmpl_var label>\',\"<tmpl_var url>\");\r\n</tmpl_loop>\r\n  slider.addPanel(panel);\r\n\r\n\r\n  panel = new createPanel(\'assets\',\'New Content\');\r\n  <tmpl_loop container_loop>\r\n	panel.addLink(\'<tmpl_var icon.small>\',\'<tmpl_var label>\',\"<tmpl_var url>\");\r\n</tmpl_loop>\r\n panel.addLink(\'^Extras;/spacer.gif\',\'<hr>\',\"\");\n <tmpl_loop contentTypes_loop>\r\n	panel.addLink(\'<tmpl_var icon.small>\',\'<tmpl_var label>\',\"<tmpl_var url>\");\r\n</tmpl_loop>\r\n  slider.addPanel(panel);\r\n  slider.draw();\r\n\r\n\r\n</script>\r\n' where assetId='PBtmpl0000000000000090';

alter table DataForm add column defaultView int(11) DEFAULT 0 NOT NULL;

update template set template = '<a href=\"<tmpl_var back.url>\"><tmpl_var back.label></a>\n<tmpl_if session.var.adminOn>\n<p><tmpl_var controls></p>\n</tmpl_if><p />\n<table width=\"100%\">\n<tr>\n<td class=\"tableHeader\">Entry ID</td>\n<tmpl_loop field_loop>\n  <tmpl_unless field.isMailField>\n    <td class=\"tableHeader\"><tmpl_var field.label></td>\n  </tmpl_unless field.isMailField>\n</tmpl_loop field_loop>\n<td class=\"tableHeader\">Submission Date</td>\n</tr>\n<tmpl_loop record_loop>\n<tr>\n  <td class=\"tableData\"><a href=\"<tmpl_var record.edit.url>\"><tmpl_var record.entryId></a></td>\n  <tmpl_loop record.data_loop>\n    <tmpl_unless record.data.isMailField>\n       <td class=\"tableData\"><tmpl_var record.data.value></td>\n     </tmpl_unless record.data.isMailField>\n  </tmpl_loop record.data_loop>\n  <td class=\"tableData\"><tmpl_var record.submissionDate.human></td>\n</tr>\n</tmpl_loop record_loop>\n</table>' where assetId='PBtmpl0000000000000021';
alter table Navigation change endPoint descendantEndPoint int not null default 55;
alter table Navigation add column anscestorEndPoint int not null default 55;

create table productVariants (
	variantId	varchar(22) not null primary key,
	productId	varchar(22) not null,
	composition	mediumtext not null,
	sku		varchar(255),
	price		decimal(12,2) default 0,
	weight		decimal(8,3) default 0,
	skuOverride	tinyint(1) default 0,
	priceOverride	tinyint(1) default 0,
	weightOverride	tinyint(1) default 0,
	available	tinyint(1) default 1
);
create table products (
	productId	varchar(22) not null primary key,
	title		varchar(255) not null,
	description	mediumtext,
	price		decimal(12,2) not null,
	weight		decimal(8,3) not null,
	sku		varchar(255) not null,
	skuTemplate	varchar(255),
	templateId	varchar(22)
);
create table productParameters (
	parameterId	varchar(22) not null primary key,
	productId	varchar(22) not null,
	name		varchar(64) not null
);
create table productParameterOptions (
	optionId	varchar(22) not null primary key,
	parameterId	varchar(22) not null,
	value		varchar(64) not null,
	priceModifier	decimal(10,2) default 0,
	weightModifier	decimal(6,2) default 0,
	skuModifier	varchar(64)
);

alter table transaction add column shippingCost varchar(9) default '0.00';
alter table transaction add column shippingMethod varchar(15);
alter table transaction add column shippingOptions text;
alter table transaction add column shippingStatus varchar(15) default 'NotShipped';
alter table transaction add column trackingNumber varchar(255);
create table RichEdit (
	assetId varchar(22) not null primary key,
                        templateId varchar(22) not null default 'PBtmpl0000000000000180',
                        askAboutRichEdit int not null default 0,
                        preformated int not null default 0,
                        editorWidth int not null default 0,
                        editorHeight int not null default 0,
                        sourceEditorWidth int not null default 0,
                        sourceEditorHeight int not null default 0,
                        useBr int not null default 0,
                        convertNewLinesToBr int not null default 0,
                        removeLineBreaks int not null default 0,
                        npwrap int not null default 0,
                        directionality varchar(3) not null default 'ltr',
                        toolbarLocation varchar(6) not null default 'bottom',
                        cssFile varchar(255),
                        toolbarRow1 text,
                        toolbarRow2 text,
                        toolbarRow3 text,
                        enableContextMenu int not null default 0
);
