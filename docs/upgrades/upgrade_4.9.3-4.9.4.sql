insert into webguiVersion values ('4.9.4','upgrade',unix_timestamp());
delete from international where languageId=3 and namespace='SiteMap' and internationalId=73;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (73,3,'SiteMap','De volgende sjabloon variabelen zijn beschikbaar om uw sitemap aan te passen.<br>\r\n \r\n<p>  <b>page_loop</b><br>\r\nDeze lus bevat alle pagina\'s in de sitemap. </p>\r\n  <b>page.indent</b><br>\r\nHet opsommingsteken voor deze pagina die de diepte in de paginaboom aangeeft. \r\n<p>  <b>page.url</b><br>\r\nDe URL naar de pagina. </p>\r\n<p>  <b>page.id</b><br>\r\nDe unieke waarde waaraan deze pagina in WebGUI intern gerefereerd wordt. </p>\r\n<p>  <b>page.title</b><br>\r\nDe titel van deze pagina. </p>\r\n<p>  <b>page.menutitle</b><br>\r\nDe titel van deze pagina die in de navigatie wordt getoond. </p>\r\n<p>  <b>page.synopsis</b><br>\r\nDe beschrijving van de inhoud van deze pagina (als die bestaat). </p>\r\n<p>  <b>page.isRoot</b><br>\r\nEen conditie die aangeeft of deze pagina een root is. </p>\r\n', 1039989891);
delete from international where languageId=3 and namespace='SiteMap' and internationalId=71;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (71,3,'SiteMap','Een sitemap wordt gebruikt om extra navigatie te bieden in WebGUI. \r\nEen traditioneel overzicht kan gemaakt worden dat een hierarchisch beeld geeft\r\nvan alle paginas in de webpagina. Ook kunnen pagian overzichten gebruikt worden\r\nom extra navigatie te bieden in een bepaalde niveauvan de pagina.<br>\r\n <br>\r\n <b>Sjabloon</b><br>\r\nKies een layout voor deze sitemap.<br>\r\n <br>\r\n <b>Beginnen met</b><br>\r\nSelecteer de pagina waarmee deze sitemap moet beginnen.<br>\r\n <br>\r\n <b>Aantal niveaus weer te geven</b><br>\r\n Hoeveel niveaus moet het pagina overzicht laten zien. Wanneer 0 is ingevoerd \r\nzullen alle onderliggende niveaus getoond worden.<br>', 1039989792);
delete from international where languageId=3 and namespace='SiteMap' and internationalId=3;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (3,3,'SiteMap','Beginnen met', 1039989710);
delete from international where languageId=3 and namespace='WebGUI' and internationalId=855;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (855,3,'WebGUI','Geef een lijst van alle sjablonen.', 1039989692);
delete from international where languageId=3 and namespace='WebGUI' and internationalId=854;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (854,3,'WebGUI','Geef een lijst met alle sjablonen zoals deze.', 1039989672);
delete from international where languageId=3 and namespace='WebGUI' and internationalId=853;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (853,3,'WebGUI','Verwijder dit sjabloon.', 1039989646);
delete from international where languageId=3 and namespace='WebGUI' and internationalId=852;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (852,3,'WebGUI','Kopieer dit sjabloon.', 1039989629);
delete from international where languageId=3 and namespace='WebGUI' and internationalId=851;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (851,3,'WebGUI','Bewerk dit sjabloon.', 1039989612);
delete from international where languageId=3 and namespace='WebGUI' and internationalId=848;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (848,3,'WebGUI','Er zit een syntax fout in dit sjabloon. Corrigeer dit a.u.b.', 1039989596);
delete from international where languageId=3 and namespace='SiteMap' and internationalId=75;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (75,3,'SiteMap','Alle roots', 1039989564);
delete from international where languageId=3 and namespace='SiteMap' and internationalId=74;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (74,3,'SiteMap','Deze pagina', 1039989549);







