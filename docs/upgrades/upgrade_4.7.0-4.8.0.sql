insert into webguiVersion values ('4.8.0','upgrade',unix_timestamp());
update incrementer set nextValue=100000 where incrementerId='messageId';
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (748,1,'WebGUI','User Count', 1036553016);
INSERT INTO template VALUES (5,'Classifieds','<tmpl_var searchForm>\r\n\r\n<tmpl_if post>\r\n    <tmpl_var post> ·\r\n</tmpl_if>\r\n<tmpl_var search><p/>\r\n\r\n<table width=\"100%\" cellpadding=3 cellspacing=0 border=0>\r\n<tr>\r\n<tmpl_loop submissions_loop>\r\n\r\n<td valign=\"top\" class=\"tableData\" width=\"33%\" style=\"border: 1px dotted black; padding: 10px;\">\r\n  <h2><a href=\"<tmpl_var submission.url>\"><tmpl_var submission.title></a></h2>\r\n  <tmpl_if submission.currentUser>\r\n    (<tmpl_var submission.status>)\r\n  </tmpl_if>\r\n<br/>\r\n  <tmpl_if submission.thumbnail>\r\n       <a href=\"<tmpl_var submission.url>\"><img src=\"<tmpl_var submission.thumbnail>\" border=\"0\"/ align=\"right\"></a><br/>\r\n  </tmpl_if>\r\n<tmpl_var submission.content>\r\n</td>\r\n\r\n<tmpl_if submission.thirdColumn>\r\n  </tr><tr>\r\n</tmpl_if>\r\n\r\n</tmpl_loop>\r\n</tr>\r\n</table>\r\n\r\n<tmpl_if multiplePages>\r\n  <div class=\"pagination\">\r\n    <tmpl_var previousPage>  · <tmpl_var pageList> · <tmpl_var nextPage>\r\n  </div>\r\n</tmpl_if>\r\n','USS');
INSERT INTO template VALUES (6,'Guest Book','<tmpl_if post>\r\n    <tmpl_var post><p>\r\n</tmpl_if>\r\n\r\n<tmpl_loop submissions_loop>\r\n\r\n<tmpl_if __odd__>\r\n<div class=\"highlight\">\r\n</tmpl_if>\r\n\r\n<b>On <tmpl_var submission.date> <a href=\"<tmpl_var submission.userProfile>\"><tmpl_var submission.username></a> from <a href=\"<tmpl_var submission.url>\">the <tmpl_var submission.title> department</a> wrote</b>, <i><tmpl_var submission.content></i>\r\n\r\n<tmpl_if __odd__>\r\n</div >\r\n</tmpl_if>\r\n\r\n<p/>\r\n\r\n</tmpl_loop>\r\n\r\n<tmpl_if multiplePages>\r\n  <div class=\"pagination\">\r\n    <tmpl_var previousPage> · <tmpl_var nextPage>\r\n  </div>\r\n</tmpl_if>\r\n','USS');
delete from international where namespace='Article' and internationalId=14;
delete from international where namespace='Article' and internationalId=15;
delete from international where namespace='Article' and internationalId=16;
delete from international where namespace='Article' and internationalId=17;
alter table Article add column templateId int not null default 1;
update Article set templateId=2 where alignImage='center';
update Article set templateId=3 where alignImage='left';
alter table Article drop column alignImage;
INSERT INTO template VALUES (1,'Default Article','<tmpl_if image>\r\n  <table width=\"100%\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\"><tr><td class=\"content\">\r\n  <img src=\"<tmpl_var image>\" align=\"right\" border=\"0\">\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n  <tmpl_var description><p/>\r\n</tmpl_if>\r\n\r\n<tmpl_if link.url>\r\n  <tmpl_if link.title>\r\n    <p><a href=\"<tmpl_var linkUrl>\"><tmpl_var linkTitle></a>\r\n  </tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_var attachment.box>\r\n\r\n<tmpl_if image>\r\n  </td></tr></table>\r\n</tmpl_if>\r\n\r\n<tmpl_if allowDiscussion>\r\n  <p><table width=\"100%\" cellspacing=\"2\" cellpadding=\"1\" border=\"0\">\r\n  <tr><td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var replies.URL>\"><tmpl_var replies.label> (<tmpl_var replies.count>)</a></td>\r\n  <td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var post.url>\"><tmpl_var post.label></a></td></tr>\r\n  </table>\r\n</tmpl_if>\r\n','Article');
INSERT INTO template VALUES (2,'Center Image','<tmpl_if image>\r\n  <div align=\"center\"><img src=\"<tmpl_var image>\" border=\"0\"></div>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n  <tmpl_var description><p/>\r\n</tmpl_if>\r\n\r\n<tmpl_if link.url>\r\n  <tmpl_if link.title>\r\n    <p><a href=\"<tmpl_var linkUrl>\"><tmpl_var linkTitle></a>\r\n  </tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_var attachment.box>\r\n\r\n\r\n<tmpl_if allowDiscussion>\r\n  <p><table width=\"100%\" cellspacing=\"2\" cellpadding=\"1\" border=\"0\">\r\n  <tr><td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var replies.URL>\"><tmpl_var replies.label> (<tmpl_var replies.count>)</a></td>\r\n  <td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var post.url>\"><tmpl_var post.label></a></td></tr>\r\n  </table>\r\n</tmpl_if>\r\n','Article');
INSERT INTO template VALUES (3,'Left Align Image','<tmpl_if image>\r\n  <table width=\"100%\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\"><tr><td class=\"content\">\r\n  <img src=\"<tmpl_var image>\" align=\"left\" border=\"0\">\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n  <tmpl_var description><p/>\r\n</tmpl_if>\r\n\r\n<tmpl_if link.url>\r\n  <tmpl_if link.title>\r\n    <p><a href=\"<tmpl_var linkUrl>\"><tmpl_var linkTitle></a>\r\n  </tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_var attachment.box>\r\n\r\n<tmpl_if image>\r\n  </td></tr></table>\r\n</tmpl_if>\r\n\r\n<tmpl_if allowDiscussion>\r\n  <p><table width=\"100%\" cellspacing=\"2\" cellpadding=\"1\" border=\"0\">\r\n  <tr><td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var replies.URL>\"><tmpl_var replies.label> (<tmpl_var replies.count>)</a></td>\r\n  <td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var post.url>\"><tmpl_var post.label></a></td></tr>\r\n  </table>\r\n</tmpl_if>\r\n','Article');
create table userSessionScratch (sessionId varchar(60), name varchar(35), value varchar(255));
create table pageStatistics (
dateStamp int,
userId int,
username varchar(35),
ipAddress varchar(15),
userAgent varchar(255),
referer text,
pageId int,
pageTitle varchar(255)
);
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (749,1,'WebGUI','Track page statistics?', 1036736182);
insert into settings values ("trackPageStatistics",0);
alter table pageStatistics add column wobjectId int;
alter table pageStatistics add column function varchar(60);




