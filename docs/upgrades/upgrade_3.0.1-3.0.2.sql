alter table widget change widgetType namespace varchar(35);

INSERT INTO international VALUES (381,'WebGUI','English','WebGUI received a malformed request and was unable to continue. Proprietary characters being passed through a form typically cause this. Please feel free to hit your back button and try again.');

alter table Article change widgetId widgetId int not null primary key;
alter table Item change widgetId widgetId int not null primary key;
alter table MessageBoard change widgetId widgetId int not null primary key;


