<%@LANGUAGE = "VBSCRIPT"%>
<html>
<head>
	<title>ASP example</title>
<style>
BODY{
  font-family:arial,helvetica;
  font-size:12px;
}
code,pre{
  color:red;
}
/* CoolMenus 4 - default styles - do not edit */
.clCMAbs{position:absolute; visibility:hidden; left:0; top:0}
/* CoolMenus 4 - default styles - end */
  
/*Style for the background-bar*/
.clBar{position:absolute; width:10; height:10; background-color:Navy; layer-background-color:Navy; visibility:hidden}

/*Styles for level 0*/
.clLevel0,.clLevel0over{position:absolute; padding:2px; font-family:tahoma,arial,helvetica; font-size:12px; font-weight:bold}
.clLevel0{background-color:Navy; layer-background-color:Navy; color:white;}
.clLevel0over{background-color:#336699; layer-background-color:#336699; color:Yellow; cursor:pointer; cursor:hand; }
.clLevel0border{position:absolute; visibility:hidden; background-color:#006699; layer-background-color:#006699}

/*Styles for level 1*/
.clLevel1, .clLevel1over{position:absolute; padding:2px; font-family:tahoma, arial,helvetica; font-size:11px; font-weight:bold}
.clLevel1{background-color:Navy; layer-background-color:Navy; color:white;}
.clLevel1over{background-color:#336699; layer-background-color:#336699; color:Yellow; cursor:pointer; cursor:hand; }
.clLevel1border{position:absolute; visibility:hidden; background-color:#006699; layer-background-color:#006699}

/*Styles for level 2*/
.clLevel2, .clLevel2over{position:absolute; padding:2px; font-family:tahoma,arial,helvetica; font-size:10px; font-weight:bold}
.clLevel2{background-color:Navy; layer-background-color:Navy; color:white;}
.clLevel2over{background-color:#0099cc; layer-background-color:#0099cc; color:Yellow; cursor:pointer; cursor:hand; }
.clLevel2border{position:absolute; visibility:hidden; background-color:#006699; layer-background-color:#006699}
</style>
<script language="JavaScript1.2" src="../coolmenus4.js">
/*****************************************************************************
Copyright (c) 2001 Thomas Brattli (webmaster@dhtmlcentral.com)

DHTML coolMenus - Get it at coolmenus.dhtmlcentral.com
Version 4.0_beta
This script can be used freely as long as all copyright messages are
intact.

Extra info - Coolmenus reference/help - Extra links to help files **** 
CSS help: http://192.168.1.31/projects/coolmenus/reference.asp?m=37
General: http://coolmenus.dhtmlcentral.com/reference.asp?m=35
Menu properties: http://coolmenus.dhtmlcentral.com/properties.asp?m=47
Level properties: http://coolmenus.dhtmlcentral.com/properties.asp?m=48
Background bar properties: http://coolmenus.dhtmlcentral.com/properties.asp?m=49
Item properties: http://coolmenus.dhtmlcentral.com/properties.asp?m=50
******************************************************************************/
</script>
</head>
<body>
<script>
/*** 
This is the menu creation code - place it right after you body tag
Feel free to add this to a stand-alone js file and link it to your page.
**/

//Menu object creation
oCMenu=new makeCM("oCMenu") //Making the menu object. Argument: menuname

//Menu properties   
oCMenu.pxBetween=30
oCMenu.fromLeft=20 
oCMenu.fromTop=0   
oCMenu.rows=1 
oCMenu.menuPlacement="center"
                                                             
oCMenu.offlineRoot="file:///C|/Inetpub/wwwroot/dhtmlcentral/" 
oCMenu.onlineRoot="/coolmenus/" 
oCMenu.resizeCheck=1 
oCMenu.wait=1000 
oCMenu.fillImg="cm_fill.gif"
oCMenu.zIndex=0

//Background bar properties
oCMenu.useBar=1
oCMenu.barWidth="100%"
oCMenu.barHeight="menu" 
oCMenu.barClass="clBar"
oCMenu.barX=0 
oCMenu.barY=0
oCMenu.barBorderX=0
oCMenu.barBorderY=0
oCMenu.barBorderClass=""

//Level properties - ALL properties have to be spesified in level 0
oCMenu.level[0]=new cm_makeLevel() //Add this for each new level
oCMenu.level[0].width=110
oCMenu.level[0].height=25 
oCMenu.level[0].regClass="clLevel0"
oCMenu.level[0].overClass="clLevel0over"
oCMenu.level[0].borderX=1
oCMenu.level[0].borderY=1
oCMenu.level[0].borderClass="clLevel0border"
oCMenu.level[0].offsetX=0
oCMenu.level[0].offsetY=0
oCMenu.level[0].rows=0
oCMenu.level[0].arrow=0
oCMenu.level[0].arrowWidth=0
oCMenu.level[0].arrowHeight=0
oCMenu.level[0].align="bottom"


//EXAMPLE SUB LEVEL[1] PROPERTIES - You have to specify the properties you want different from LEVEL[0] - If you want all items to look the same just remove this
oCMenu.level[1]=new cm_makeLevel() //Add this for each new level (adding one to the number)
oCMenu.level[1].width=oCMenu.level[0].width-2
oCMenu.level[1].height=22
oCMenu.level[1].regClass="clLevel1"
oCMenu.level[1].overClass="clLevel1over"
oCMenu.level[1].borderX=1
oCMenu.level[1].borderY=1
oCMenu.level[1].align="right" 
oCMenu.level[1].offsetX=-(oCMenu.level[0].width-2)/2+20
oCMenu.level[1].offsetY=0
oCMenu.level[1].borderClass="clLevel1border"


//EXAMPLE SUB LEVEL[2] PROPERTIES - You have to spesify the properties you want different from LEVEL[1] OR LEVEL[0] - If you want all items to look the same just remove this
oCMenu.level[2]=new cm_makeLevel() //Add this for each new level (adding one to the number)
oCMenu.level[2].width=150
oCMenu.level[2].height=20
oCMenu.level[2].offsetX=0
oCMenu.level[2].offsetY=0
oCMenu.level[2].regClass="clLevel2"
oCMenu.level[2].overClass="clLevel2over"
oCMenu.level[2].borderClass="clLevel2border"

/******************************************
Menu item creation:
myCoolMenu.makeMenu(name, parent_name, text, link, target, width, height, regImage, overImage, regClass, overClass , align, rows, nolink, onclick, onmouseover, onmouseout) 
*************************************/
<%
'*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'ASP CODE START - READING ITEMS FROM THE DATABASE
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Sub readItemsFromDatabase
  'The path to your database:
  Dim db,q,rs,rsarr,menuID,mName,mLink,parent,cols,max
	
	db ="Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" & Server.MapPath("menu.mdb")
  
  q = "SELECT menuID,mName,mLink,parent from tblMenu ORDER BY parent,menuID ASC"
  
  Set rs=Server.CreateObject("ADODB.Recordset")
  rs.CacheSize = 25 		' Cache data fetching
  rs.CursorType = 3
  rs.LockType = 3
  
  'Opening database --- --
  rs.Open q,db
  
  'Now using getRows because that's so sexy :}
  if NOT rs.EOF then
    rsarr = rs.GetRows()
		max = Ubound(rsarr,2)

  else 
		max = 0
  end if
  'Closing database, we don't need it anymore - we have the info in the array
  rs.close()
  Set rs = Nothing
  
	row=0
	do while(row<=max) 'Looping rows
    'Setting variables 
    menuID = "m" & rsarr(0,row)
    mName = rsarr(1,row)
    mLink = rsarr(2,row)
    if(mLink="null") then mLink="" 
    parent = rsarr(3,row)
    if(parent<>0) then
			parent = "m" & parent
    else 
			parent=""
    end if
		'Making menu item
    Response.write("oCMenu.makeMenu('" & menuID & "','" &parent & "','" & mName & "','" & mLink & "')" & vbcrlf)
  	row = row + 1
	loop
End Sub

'Calling sub
call readItemsFromDatabase

'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'ASP CODE END - READING ITEMS FROM THE DATABASE
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%>

//Leave this line - it constructs the menu
oCMenu.construct()		
</script>
<br>
<br>
<br>

This file is a simple example of how to get items from a access database. It's more or less
the same as the javascript example, only coded in VBSCRIPT. I will make a more advanced example later. The table consist of 4 simple columns:
<br>
<br>
<code>menuID</code> - Autonumber - the id of the menuitem.<br>
<code>mName</code> - String - The menu name<br>
<code>mLink</code> - String - The link<br>
<code>parent</code> - Number - a recursive relation to menuID.<br>
<br>
<br>
This can rather easily be converted to control the entire menu and by adding a server-side admin *anyone* could
easily change the menu. The new menumaker that I will hopefully soon have time 
to make will probably use something like this. 
<br>
<br>
On this site I use a similar approuch, the only difference is that I make a js file everytime I update, that way
I don't have to get the items from the database on every visit. I will try and make an example like that as well later.
<br>
<br>

ASP source-code:
<pre>
'*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'ASP CODE START - READING ITEMS FROM THE DATABASE
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Sub readItemsFromDatabase
  'The path to your database:
  Dim db,q,rs,rsarr,menuID,mName,mLink,parent,cols,max
	
	db ="Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" & Server.MapPath("menu.mdb")
  
  q = "SELECT menuID,mName,mLink,parent from tblMenu ORDER BY parent,menuID ASC"
  
  Set rs=Server.CreateObject("ADODB.Recordset")
  rs.CacheSize = 25 		' Cache data fetching
  rs.CursorType = 3
  rs.LockType = 3
  
  'Opening database --- --
  rs.Open q,db
  
  'Now using getRows because that's so sexy :}
  if NOT rs.EOF then
    rsarr = rs.GetRows()
		max = Ubound(rsarr,2)
  else 
		max = 0
  end if
  'Closing database, we don't need it anymore - we have the info in the array
  rs.close()
  Set rs = Nothing
  
	row=0
	do while(row&lt;=max) 'Looping rows
    'Setting variables 
    menuID = "m" & rsarr(0,row)
    mName = rsarr(1,row)
    mLink = rsarr(2,row)
    if(mLink="null") then mLink="" 
    parent = rsarr(3,row)
    if(parent&lt;&gt;0) then
			parent = "m" & parent
    else 
			parent=""
    end if
		'Making menu item
    Response.write("oCMenu.makeMenu('" & menuID & "','" &parent & "','" & mName & "','" & mLink & "')" & vbcrlf)
  	row = row + 1
	loop
End Sub

'Calling sub
call readItemsFromDatabase

'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'ASP CODE END - READING ITEMS FROM THE DATABASE
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
</pre>
</body>
</html>
