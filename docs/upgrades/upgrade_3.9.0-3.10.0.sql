insert into webguiVersion values ('3.10.0','upgrade',unix_timestamp());
alter table help change body body mediumtext;
INSERT INTO international VALUES (528,'WebGUI','English','Template Name');
INSERT INTO help VALUES (33,'WebGUI','English','Manage','Template','Templates are used to affect how pages are laid out in WebGUI. For instance, most sites these days have more than just a menu and one big text area. Many of them have three or four columns preceeded by several headers and/or banner areas. WebGUI accomodates complex layouts through the use of Templates. There are several templates that come with WebGUI to make life easier for you, but you can create as many as you\'d like.','0');
INSERT INTO help VALUES (34,'WebGUI','English','Add/Edit','Template','<b>Template Name</b><br>\r\nGive this template a descriptive name so that you\'ll know what it is when you\'re applying the template to a page.\r\n<p>\r\n\r\n<b>Template</b><br>\r\nCreate your template by placing the special macros ^0; ^1; ^2;  and so on in your template to represent the different content areas. Typically this is done by using a table to position the content. The following is an example of a template with two content areas side by side:\r\n<p>\r\n<pre>\r\n&lt;table&gt;\r\n  &lt;tr&gt;\r\n    &lt;td&gt;^0;&lt;/td&gt;\r\n    &lt;td&gt;^1;&lt;/td&gt;\r\n  &lt;/tr&gt;\r\n&lt;/table&gt;\r\n</pre>\r\n<p>\r\nAlso be sure to take a look at the templates that come with WebGUI for ideas.\r\n','0');
INSERT INTO help VALUES (35,'WebGUI','English','Delete','Template','It is not a good idea to delete templates as you never know what kind of adverse affect it may have on your site (some pages may still be using the template). If you should choose to delete a template, all the pages still using the template will be set to the \"Default\" template.','0');
alter table wobject change templatePosition templatePosition int not null default 0;






