oM=new makeCM("oM"); oM.resizeCheck=1; oM.rows=1;  oM.onlineRoot=""; oM.pxBetween =0; 
oM.fillImg="cm_fill.gif"; oM.fromTop=115; oM.fromLeft=155; oM.wait=300; oM.zIndex=400;
oM.useBar=1; oM.barWidth="100%"; oM.barHeight="menu"; oM.barX=0;oM.barY="menu"; oM.barClass="clBar";
oM.barBorderX=0; oM.barBorderY=0;
oM.level[0]=new cm_makeLevel(90,21,"clT","clTover",1,1,"clB",0,"bottom",0,0,0,0,0);
oM.level[1]=new cm_makeLevel(102,22,"clS","clSover",1,1,"clB",0,"right",0,0,"menu_arrow.gif",10,10);
oM.level[2]=new cm_makeLevel(110,22,"clS2","clS2over");
oM.level[3]=new cm_makeLevel(140,22);

oM.makeMenu('m1','','News','/news/?m=1');
oM.makeMenu('m2','','Projects','/projects/?m=2');
oM.makeMenu('m3','','Scripts','/script/?m=3');
oM.makeMenu('m4','','Tutorials','/tutorials/?m=4');
oM.makeMenu('m5','','Forums','/forums/?m=5');
oM.makeMenu('m6','','Resources','/resources/?m=6');
oM.makeMenu('m7','','dhtmlcentral','/dhtmlcentral/?m=7');
oM.makeMenu('m8','m1','Newest news','/news/?');
oM.makeMenu('m9','m1','Archive','/news/?archive=1');
oM.makeMenu('m10','m2','CoolMenus','/projects/coolmenus/?m=10','',120,0);
oM.makeMenu('m11','m2','DHTML Library','/projects/lib/?m=11','',120,0);
oM.makeMenu('m12','m2','DHTML Guestbook','/projects/guestbook/?m=12','',120,0);
oM.makeMenu('m13','m3','New scripts','/script/search.asp?new=1');
oM.makeMenu('m14','m3','All scripts','/script/?m=14');
oM.makeMenu('m15','m3','Categories','/txt/?m=15');
oM.makeMenu('m16','m15','Menu','/script/search.asp?category=menu');
oM.makeMenu('m17','m15','Text','/script/search.asp?category=text');
oM.makeMenu('m18','m15','Animation','/script/search.asp?category=animation');
oM.makeMenu('m19','m15','Other','/script/search.asp?category=other');
oM.makeMenu('m20','m5','CoolMenus 3','/forums/forum.asp?FORUM_ID=2&CAT_ID=1&Forum_Title=CoolMenus+3');
oM.makeMenu('m21','m5','General','/forums/forum.asp?FORUM_ID=6&CAT_ID=1&Forum_Title=General+DHTML+issues');
oM.makeMenu('m22','m5','Scripts','/forums/forum.asp?FORUM_ID=4&CAT_ID=1&Forum_Title=DHTML+Scripts');
oM.makeMenu('m23','m5','Crossbrowser','/forums/forum.asp?FORUM_ID=3&CAT_ID=1&Forum_Title=Crossbrowser+DHTML');
oM.makeMenu('m24','m5','dhtmlcentral.com','/forums/forum.asp?FORUM_ID=5&CAT_ID=1&Forum_Title=dhtmlcentral%2Ecom');
oM.makeMenu('m25','m5','Off topic','/forums/forum.asp?FORUM_ID=9&CAT_ID=1&Forum_Title=Off%2Dtopic');
oM.makeMenu('m27','m6','Links','/resources/default.asp?m=27');
oM.makeMenu('m28','m6','Web books','/resources/books.asp?m=28');
oM.makeMenu('m29','m6','Web software','/resources/software.asp?m=29');
oM.makeMenu('m39','m7','About','/txt/?m=39');
oM.makeMenu('m40','m7','Advertise','/txt/?m=40');
oM.makeMenu('m41','m7','Site sponsor','/txt/?m=41');
oM.makeMenu('m42','m7','Contributors','/dhtmlcentral/contributors.asp?m=42');
oM.makeMenu('m43','m7','Newsletter','/dhtmlcentral/newsletter.asp?m=43');
oM.makeMenu('m44','m7','Members','/forums/members.asp?m=44');
oM.makeMenu('m45','m7','Copyright','/txt/?m=45');
oM.makeMenu('m26','m5','Active topics','/forums/active.asp?m=26');

//var avail="190+((cmpage.x2-235)/7)";
//oM.menuPlacement=new Array(192,avail+"-11",avail+"*2-8",avail+"*3-12",avail+"*4-7",avail+"*5-9",avail+"*6+5")
oM.construct()
