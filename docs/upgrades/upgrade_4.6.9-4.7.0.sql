insert into webguiVersion values ('4.7.0','upgrade',unix_timestamp());
update international set internationalId=728, namespace='WebGUI' where internationalId=12 and namespace='Product';
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (739,1,'WebGUI','UI Level', 1033832377);
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
INSERT INTO userProfileField VALUES ('uiLevel','WebGUI::International::get(739,\"WebGUI\");',0,0,'select','{\r\n0=>WebGUI::International::get(729,\"WebGUI\"),\r\n1=>WebGUI::International::get(730,\"WebGUI\"),\r\n2=>WebGUI::International::get(731,\"WebGUI\"),\r\n3=>WebGUI::International::get(732,\"WebGUI\"),\r\n4=>WebGUI::International::get(733,\"WebGUI\"),\r\n5=>WebGUI::International::get(734,\"WebGUI\"),\r\n6=>WebGUI::International::get(735,\"WebGUI\"),\r\n7=>WebGUI::International::get(736,\"WebGUI\"),\r\n8=>WebGUI::International::get(737,\"WebGUI\"),\r\n9=>WebGUI::International::get(738,\"WebGUI\")\r\n}','[5]',8,4,1);
INSERT INTO userProfileData VALUES (3,'uiLevel','9');
update incrementer set incrementerId='FAQ_questionId' where incrementerId='questionId';
update incrementer set incrementerId='LinkList_linkId' where incrementerId='linkId';
update incrementer set incrementerId='EventsCalendar_eventId' where incrementerId='eventId';
update incrementer set incrementerId='EventsCalendar_recurringEventId' where incrementerId='recurringEventId';
alter table FAQ_question change questionId FAQ_questionId int not null;
alter table LinkList_link change linkId LinkList_linkId int not null;
alter table EventsCalendar_event change eventId EventsCalendar_eventId int not null;
alter table EventsCalendar_event change recurringEventId EventsCalendar_recurringEventId int not null;
update incrementer set incrementerId='FileManager_fileId' where incrementerId='fileId';
update incrementer set incrementerId='USS_submissionId' where incrementerId='submissionId';
alter table DownloadManager_file change downloadId FileManager_fileId int not null;
alter table DownloadManager rename FileManager;
alter table DownloadManager_file rename FileManager_file;
update wobject set namespace='USS' where namespace='UserSubmission';
update help set namespace='USS' where namespace='UserSubmission';
update international set namespace='USS' where namespace='UserSubmission';
update international set namespace='FileManager' where namespace='DownloadManager';
update help set namespace='FileManager' where namespace='DownloadManager';
update wobject set namespace='FileManager' where namespace='DownloadManager';
alter table UserSubmission rename USS;
alter table UserSubmission_submission rename USS_submission;
alter table USS_submission change submissionId USS_submissionId int not null;
update incrementer set nextValue=nextValue+999 where incrementerId='EventsCalendar_eventId';
update incrementer set nextValue=nextValue+999 where incrementerId='EventsCalendar_recurringEventId';
update EventsCalendar_event set EventsCalendar_eventId=EventsCalendar_eventId+999;
update EventsCalendar_event set EventsCalendar_recurringEventId=EventsCalendar_recurringEventId+999;
update FAQ_question set FAQ_questionId=FAQ_questionId+999;
update LinkList_link set LinkList_linkId=LinkList_linkId+999;
update incrementer set nextValue=nextValue+999 where incrementerId='FAQ_questionId';
update incrementer set nextValue=nextValue+999 where incrementerId='LinkList_linkId';
update incrementer set nextValue=nextValue+974 where incrementerId='pageId';
update page set pageId=pageId+974 where pageId>25;
update page set parentId=parentId+974 where parentId>25;
update page set styleId=styleId+974 where styleId>25;
update incrementer set nextValue=nextValue+974 where incrementerId='styleId';
update style set styleId=styleId+974 where styleId>25;
update discussion set messageId=messageId+999;
update discussion set rid=rid+999;
update discussion set pid=pid+999 where pid<>0;
update incrementer set nextValue=nextValue+999 where incrementerId='messageId';
update messageLog set messageLogId=messageLogId+999;
update incrementer set nextValue=nextValue+999 where incrementerId='messageLogId';
update incrementer set nextValue=nextValue+999 where incrementerId='imageGroupId';
update imageGroup set imageGroupId=imageGroupId+999 where imageGroupId>0;
update images set imageGroupId=imageGroupId+999 where imageGroupId>0;
update incrementer set incrementerId='MailForm_fieldId' where incrementerId='mailFieldId';
update incrementer set incrementerId='MailForm_entryId' where incrementerId='mailEntryId';
alter table MailForm_entry change entryId MailForm_entryId int not null;
alter table MailForm_field change mailfieldId MailForm_fieldId int not null;
alter table MailForm_entry_data rename MailForm_entryData;
alter table MailForm_entryData change entryId MailForm_entryId int not null;
update incrementer set incrementerId='FileManager_fileId' where incrementerId='downloadId';
update incrementer set incrementerId='Product_featureId' where incrementerId='productFeatureId';
update incrementer set incrementerId='Product_benefitId' where incrementerId='productBenefitId';
update incrementer set incrementerId='Product_templateId' where incrementerId='productTemplateId';
update incrementer set incrementerId='Product_specificationId' where incrementerId='productSpecificationId';
alter table Product_template change productTemplateId Product_templateId int not null;
alter table Product change productTemplateId Product_templateId int not null default 1;
alter table Product_benefit change productBenefitId Product_benefitId int not null;
alter table Product_feature change productFeatureId Product_featureId int not null;
alter table Product_specification change productSpecificationId Product_specificationId int not null;













