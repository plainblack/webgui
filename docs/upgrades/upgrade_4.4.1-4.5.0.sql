insert into webguiVersion values ('4.5.0','upgrade',unix_timestamp());
insert into international values (72,'Poll',1,'Randomize answers?');
alter table Poll add column randomizeAnswers int not null default 0;
insert into userProfileField values ('firstDayOfWeek','WebGUI::International::get(699,"WebGUI");',1,0,'select','{0=>WebGUI::International::get(27,"WebGUI"),1=>WebGUI::International::get(28,"WebGUI")}','[0]',2,4,1);
update userProfileField set sequenceNumber=sequenceNumber+1 where profileCategoryId=4 and sequenceNumber>=2;
insert into international values (699,"WebGUI",1,"First Day Of Week");
update international set message='Calendar Month' where internationalId=18 and namespace='EventsCalendar';
insert into international values (74,'EventsCalendar',1,'Calendar Month (Small)');
update EventsCalendar set calendarLayout='calendarMonth' where calendarLayout='calendar';
insert into international values (75,'EventsCalendar',1,'Month');
insert into international values (76,'EventsCalendar',1,'Year');
update international set internationalId=700, namespace='WebGUI' where internationalId='5' and namespace='EventsCalendar';
update international set internationalId=701, namespace='WebGUI' where internationalId='6' and namespace='EventsCalendar';
update international set internationalId=702, namespace='WebGUI' where internationalId='75' and namespace='EventsCalendar';
update international set internationalId=703, namespace='WebGUI' where internationalId='76' and namespace='EventsCalendar';
update international set message='Day(s)' where internationalId=700 and languageId=1;
update international set message='Week(s)' where internationalId=701 and languageId=1;
update international set message='Month(s)' where internationalId=702 and languageId=1;
update international set message='Year(s)' where internationalId=703 and languageId=1;
insert into international values (704,'WebGUI',1,'Second(s)');
insert into international values (705,'WebGUI',1,'Minute(s)');
insert into international values (706,'WebGUI',1,'Hour(s)');
delete from international where namespace='EventsCalendar' and internationalId=10;
delete from international where namespace='EventsCalendar' and internationalId=11;
insert into international values (75,'EventsCalendar',1,'Which do you wish to do?');
insert into international values (76,'EventsCalendar',1,'Delete only this event.');
insert into international values (77,'EventsCalendar',1,'Delete this event <b>and</b> all of its recurrences.');
insert into international values (78,'EventsCalendar',1,'Don\'t delete anything, I made a mistake.');
update wobject set editTimeout=editTimeout*3600;
insert into international values (707,"WebGUI",1,"Show debugging?");
insert into settings values ('showDebug',0);
update settings set name='imageManagersGroup' where name='groupToManageImages';
insert into settings values ('styleManagersGroup',5);
insert into settings values ('templateManagersGroup',8);
delete from international where internationalId=414 and namespace='WebGUI';
delete from international where internationalId=415 and namespace='WebGUI';
delete from international where internationalId=413 and namespace='WebGUI';
insert into international values (710,'WebGUI',1,'Edit Privilege Settings');
insert into international values (711,'WebGUI',1,'Image Managers Group');
insert into international values (713,'WebGUI',1,'Style Managers Group');
insert into international values (714,'WebGUI',1,'Template Managers Group');
delete from settings where name='onCriticalError';
update international set message='Add a new image group.' where internationalId=543 and namespace='WebGUI' and languageId=1;
insert into international values (48,'Product',1,'Are you certain you wish to delete this benefit? It cannot be recovered once it has been deleted.');
insert into incrementer values ('productBenefitId',1000);
insert into incrementer values ('productTemplateId',1000);
create table Product_benefit (wobjectId int not null, productBenefitId int not null primary key, benefit varchar(255), sequenceNumber int not null);
insert into international values (51,'Product',1,'Benefit');
insert into international values (52,'Product',1,'Add another benefit?');
insert into international values (53,'Product',1,'Edit Benefit');
insert into international values (54,'Product',1,'Benefits');
insert into international values (55,'Product',1,'Add a benefit.');
insert into international values (56,'Product',1,'Add a product template.');
insert into international values (57,'Product',1,'Are you certain you wish to delete this template and set all the products using it to the default template?');
insert into international values (58,'Product',1,'Edit Product Template');
insert into international values (59,'Product',1,'Name');
insert into international values (60,'Product',1,'Template');
alter table Product add column productTemplateId int not null default 1;
insert into international values (61,'Product',1,'Product Template');
create table Product_template (productTemplateId int not null primary key, name varchar(255), template text);
INSERT INTO Product_template VALUES (1,'Default','<style>\r\n.productFeatureHeader,.productSpecificationHeader,.productRelatedHeader,.productAccessoryHeader, .productBenefitHeader  {\r\n font-weight: bold;\r\n font-size: 15px;\r\n}\r\n.productFeature,.productSpecification,.productRelated,.productAccessory, .productBenefit {\r\n font-size: 12px;\r\n}\r\n.productAttributeSeperator {\r\n background-color: black;\r\n}\r\n\r\n\r\n</style>\r\n<table width=\"100%\" cellpadding=\"3\" cellspacing=\"0\" border=\"0\">\r\n<tr>\r\n  <td class=\"content\" valign=\"top\">^Product_Description;<p>\r\n    <b>Price:</b> ^Product_Price;<br>\r\n    <b>Product Number:</b> ^Product_Number;<p>\r\n    ^Product_Brochure;<br>\r\n    ^Product_Manual;<br>\r\n    ^Product_Warranty;<br>\r\n  </td>\r\n  <td valign=\"top\">\r\n    ^Product_Thumbnail1;<p>\r\n    ^Product_Thumbnail2;<p>\r\n    ^Product_Thumbnail3;<p>\r\n  </td>\r\n</tr>\r\n</table>\r\n<table border=\"0\" cellpadding=\"0\" cellspacing=\"5\">\r\n<tr>\r\n  <td valign=\"top\" class=\"productFeature\"><div class=\"productFeatureHeader\">Features</div>^Product_Features;<p/></td>\r\n  <td class=\"productAttributeSeperator\"><img src=\"^Extras;spacer.gif\" width=\"1\" height=\"1\"></td>\r\n  <td valign=\"top\" class=\"productBenefit\"><div class=\"productBenefitHeader\">Benefits</div>^Product_Benefits;<p/></td>\r\n  <td class=\"productAttributeSeperator\"><img src=\"^Extras;spacer.gif\" width=\"1\" height=\"1\"></td>\r\n  <td valign=\"top\" class=\"productSpecification\"><div class=\"productSpecificationHeader\">Specifications</div>^Product_Specifications;<p/></td>\r\n  <td class=\"productAttributeSeperator\"><img src=\"^Extras;spacer.gif\" width=\"1\" height=\"1\"></td>\r\n  <td valign=\"top\" class=\"productAccessory\"><div class=\"productAccessoryHeader\">Accessories</div>^Product_Accessories;<p/></td>\r\n  <td class=\"productAttributeSeperator\"><img src=\"^Extras;spacer.gif\" width=\"1\" height=\"1\"></td>\r\n  <td valign=\"top\" class=\"productRelated\"><div class=\"productRelatedHeader\">Related Products</div>^Product_Related;</td>\r\n</tr>\r\n</table>\r\n\r\n');
INSERT INTO Product_template VALUES (2,'Benefits Showcase','<style>\r\n.productOptions {\r\n  font-family: Helvetica, Arial, sans-serif;\r\n  font-size: 11px;\r\n}\r\n</style>\r\n\r\n^Product_Image1;\r\n<table width=\"100%\" cellpadding=\"3\" cellspacing=\"0\" border=\"0\">\r\n<tr>\r\n  <td class=\"content\" valign=\"top\" width=\"66%\">^Product_Description;<p>\r\n  <b>Benefits</b><br>\r\n^Product_Benefits;\r\n  </td>\r\n  <td valign=\"top\" width=\"34%\" class=\"productOptions\">\r\n^Product_Thumbnail2;<p>\r\n<b>Specifications</b><br>\r\n^Product_Specifications;<p>\r\n<b>Options</b><br>\r\n^Product_Accessories;<p>\r\n<b>Other Products</b><br>\r\n^Product_Related;<p>\r\n  </td>\r\n</tr>\r\n</table>\r\n\r\n');
INSERT INTO Product_template VALUES (3,'Three Columns','<style>\r\n.productFeatureHeader,.productSpecificationHeader,.productRelatedHeader,.productAccessoryHeader, .productBenefitHeader  {\r\n font-weight: bold;\r\n font-size: 15px;\r\n}\r\n.productFeature,.productSpecification,.productRelated,.productAccessory, .productBenefit {\r\n font-size: 12px;\r\n}\r\n\r\n</style>\r\n^Product_Description;<p>\r\n\r\n<table width=\"100%\" cellpadding=\"3\" cellspacing=\"0\" border=\"0\">\r\n<tr>\r\n  <td align=\"center\">^Product_Thumbnail1;</td>\r\n   <td align=\"center\">^Product_Thumbnail2;</td>\r\n  <td align=\"center\">^Product_Thumbnail3;</td>\r\n</tr>\r\n</table>\r\n<table border=\"0\" cellpadding=\"0\" cellspacing=\"5\" width=\"100%\">\r\n<tr>\r\n  <td valign=\"top\" class=\"tableData\" width=\"35%\">\r\n<b>Features</b><br>^Product_Features;<p/>\r\n<b>Benefits</b><br>^Product_Benefits;<p/>\r\n</td>\r\n  <td valign=\"top\" class=\"tableData\" width=\"35%\">\r\n<b>Specifications</b><br>^Product_Specifications;<p/>\r\n<b>Accessories</b><br>^Product_Accessories;<p/>\r\n<b>Related Products</b><br>^Product_Related;<p/>\r\n</td>\r\n  <td class=\"tableData\" valign=\"top\" width=\"30%\">\r\n    <b>Price:</b> ^Product_Price;<br>\r\n    <b>Product Number:</b> ^Product_Number;<p>\r\n    ^Product_Brochure;<br>\r\n    ^Product_Manual;<br>\r\n    ^Product_Warranty;<br>\r\n  </td>\r\n</tr>\r\n</table>\r\n\r\n');
INSERT INTO Product_template VALUES (4,'Left Column Collateral','<style>\r\n.productCollateral {\r\n font-size: 11px;\r\n}\r\n</style>\r\n<table width=\"100%\">\r\n<tr><td valign=\"top\" class=\"productCollateral\" width=\"100\">\r\n<img src=\"^Extras;spacer.gif\" width=\"100\" height=\"1\"><br>\r\n^Product_Brochure;<br>\r\n^Product_Manual;<br>\r\n^Product_Warranty;<br>\r\n<br>\r\n<div align=\"center\">\r\n^Product_Thumbnail1;<p>\r\n^Product_Thumbnail2;<p>\r\n^Product_Thumbnail3;<p>\r\n</div>\r\n</td><td valign=\"top\" class=\"content\" width=\"100%\">\r\n^Product_Description;<p>\r\n<b>Specs:</b><br>\r\n^Product_Specifications;<p>\r\n<b>Features:</b><br>\r\n^Product_Features;<p>\r\n<b>Options:</b><br>\r\n^Product_Accessories;<p>\r\n</td></tr>\r\n</table>');






















