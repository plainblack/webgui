insert into webguiVersion values ('4.7.0','upgrade',unix_timestamp());
update international set internationalId=728, namespace='WebGUI' where internationalId=12 and namespace='Product';
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (728,1,'WebGUI','UI Level', 1033832377);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (738,1,'WebGUI','9 Guru', 1033836704);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (737,1,'WebGUI','8 Master', 1033836698);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (736,1,'WebGUI','7 Expert', 1033836692);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (735,1,'WebGUI','6 Professional', 1033836686);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (734,1,'WebGUI','5 Adept', 1033836678);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (733,1,'WebGUI','4 Skilled', 1033836668);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (732,1,'WebGUI','3 Rookie', 1033836660);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (731,1,'WebGUI','2 Trained', 1033836651);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (730,1,'WebGUI','1 Novice', 1033836642);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (729,1,'WebGUI','0 Beginner', 1033836631);
INSERT INTO userProfileField VALUES ('uiLevel','WebGUI::International::get(728,\"WebGUI\");',0,0,'select','{\r\n0=>WebGUI::International::get(729,\"WebGUI\"),\r\n1=>WebGUI::International::get(730,\"WebGUI\"),\r\n2=>WebGUI::International::get(731,\"WebGUI\"),\r\n3=>WebGUI::International::get(732,\"WebGUI\"),\r\n4=>WebGUI::International::get(733,\"WebGUI\"),\r\n5=>WebGUI::International::get(734,\"WebGUI\"),\r\n6=>WebGUI::International::get(735,\"WebGUI\"),\r\n7=>WebGUI::International::get(736,\"WebGUI\"),\r\n8=>WebGUI::International::get(737,\"WebGUI\"),\r\n9=>WebGUI::International::get(738,\"WebGUI\")\r\n}','[5]',8,4,1);
INSERT INTO userProfileData VALUES (3,'uiLevel','9');




