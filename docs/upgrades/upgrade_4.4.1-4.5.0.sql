insert into webguiVersion values ('4.5.0','upgrade',unix_timestamp());
insert into international values (72,'Poll',1,'Randomize answers?');
alter table Poll add column randomizeAnswers int not null default 0;
insert into userProfileField values ('firstDayOfWeek','WebGUI::International::get(699,"WebGUI");',1,0,'select','{0=>WebGUI::International::get(27,"WebGUI"),1=>WebGUI::International::get(28,"WebGUI")}','[0]',2,4,1);
update userProfileField set sequenceNumber=sequenceNumber+1 where profileCategoryId=4 and sequenceNumber>=2;
insert into international values (699,"WebGUI",1,"First Day Of Week");
update international set message='Calendar Month' where internationalId=18 and namespace='EventsCalendar';
insert into international values (74,'EventsCalendar',1,'Calendar Month (Small)');
update EventsCalendar set calendarLayout='calendarMonth' where calendarLayout='calendar';













