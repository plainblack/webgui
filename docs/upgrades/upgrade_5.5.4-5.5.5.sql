insert into webguiVersion values ('5.5.4','upgrade',unix_timestamp());


delete from international where internationalId=416 and namespace='WebGUI';

