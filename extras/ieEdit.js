// EDITOR PUBLIC (API)

// POPUP (Link, table and image popup need to be worked on)
function _CPopup_Init() 
{
var sz = "<HTML ID=popup><STYLE>"+document.styleSheets.defPopupSkin.cssText+"\n"+document.styleSheets.popupSkin.cssText+"</STYLE><SCRIPT>function IMAGELoaded(w) {parent._IMAGELoaded(w,self)}</SCRIPT>"+	"<BODY "+	"ONSCROLL=\"return false\" SCROLL=no TABINDEX=-1 "+	"ONSELECTSTART=\"return event.srcElement.tagName=='INPUT'\" "+	"><DIV ID=puRegion>"+	"<TABLE ID=header>"+	"<TR>"+	"<TH NOWRAP ID=caption></TH>"+	"<TH VALIGN=middle ALIGN=RIGHT><DIV ID=close ONCLICK=\"parent._CPopup_Hide()\">"+	L_CLOSEBUTTON_TEXT+	"</DIV></TH>"+	"</TR>"+	"</TABLE>"+	"<DIV ALIGN=CENTER ID=content></DIV>"+	"</DIV></BODY>"+ "</HTML>";
idPopup.document.open("text/html","replace");
idPopup.document.write(sz);
idPopup.document.close();
}


function _CPopup_InsertDatabound(eSelect)
{
if (eSelect.selectedIndex != 0)
{
var sElemName = eSelect.options[eSelect.selectedIndex].text;
var iLen = sElemName.length
sElemName = sElemName.replace(/"/g, '&#034;')
insertHTML('<INPUT CLASS=DataBound SIZE=' + (iLen + 2) + ' NAME="' + sElemName +'" VALUE=" ' + sElemName + ' ">')
eSelect.selectedIndex = 0;
idEditbox.focus()	
}
}
function _CPopup_Hide() 
{
document.all.idPopup.style.zIndex=-1
document.all.idPopup.style.visibility = "hidden"	
idPopup.document._type = ""
idPopup.document.onkeydown=idPopup.document.onmouseover=idPopup.document.onclick = null
idEditbox.focus()
}
function _CPopup_Show(szType) 
{
var oRenderer, szCacheKey = "PopupRenderer." + szType
if (idPopup.document._type == szType)
_CPopup_Hide()
else
{
document.all.idPopup.style.zIndex = -1
oRenderer = g_state.aCache[szCacheKey]
if ((!oRenderer) || ("Link"==szType))
g_state.aCache[szCacheKey] = oRenderer = new _CPopupRenderer(szType)
// Force Sizing
document.all.idPopup.style.visibility = ""
idPopup.document.all.puRegion.style.pixelHeight = idPopup.document.all.puRegion.style.pixelWidth = 100
idPopup.document._type	= szType
idPopup.document._renderer	= oRenderer
idPopup.document.all.caption.innerText	= oRenderer.GetCaption()
idPopup.document.all.content.innerHTML	= oRenderer.GetHTML()
idPopup.document.onkeydown	= new Function("this._renderer.OnKeyDown()")
idPopup.document.onmouseover	= new Function("this._renderer.OnMouseOver()")
idPopup.document.onclick	= new Function("this._renderer.OnClick()")
oRenderer.ResetContext(idPopup.document)
setTimeout("_CPopupRenderer_Display('" + szType + "')",0)
}
}
function _CPopupRenderer_Display(szType) {
var oRenderer, szCacheKey = "PopupRenderer." + szType
oRenderer = g_state.aCache[szCacheKey]
if (oRenderer.autoSize) {	
idPopup.document.all.puRegion.style.pixelHeight = document.all.idPopup.style.pixelHeight = idPopup.document.all.puRegion.offsetHeight
idPopup.document.all.puRegion.style.pixelWidth = document.all.idPopup.style.pixelWidth = idPopup.document.all.puRegion.offsetWidth + 50
document.all.idPopup.style.pixelLeft = (document.body.clientWidth - idPopup.document.all.puRegion.offsetWidth) / 2
}
else { 
idPopup.document.all.puRegion.style.pixelHeight = document.all.idPopup.style.pixelHeight = document.body.clientHeight - idToolbar.offsetHeight- document.all.idMode.offsetHeight-20
idPopup.document.all.puRegion.style.pixelWidth = document.all.idPopup.style.pixelWidth = document.body.clientWidth - 50
document.all.idPopup.style.pixelLeft = 25
}
document.all.idPopup.style.zIndex=2
idPopup.focus()
}
function _CPopupRenderer(szType)
{
this.szType	= szType
this.elCurrent	= this.oDocument = null
this.ResetContext = _CPopupRenderer_ResetContext
this.GetCaption	= _CPopupRenderer_GetCaption	
this.GetHTML	= _CPopupRenderer_GetHTML
this.autoSize	= true
this.OnMouseOver = new Function()
this.OnKeyDown	= _CListPopupRenderer_GenericOnKeyDown
switch(szType)
{
case "formatblock":
case "font":
case "fontsize":
this.OnMouseOver= _CListPopupRenderer_OnMouseOver
this.OnKeyDown = _CListPopupRenderer_OnKeyDown
case "BackColor": 
case "ForeColor":
this.OnClick	= _CListPopupRenderer_OnClick
this.Highlight = _CListPopupRenderer_Highlight
this.Select	= _CListPopupRenderer_Select
break
default:
this.OnClick	= new Function()
break	
}
switch(szType)
{
case "formatblock":
this.szCaption	= L_PUTITLEPARAGRAPHSTYLE_TEXT
this.PrepareHTML	= _CFormatBlockPopupRenderer_PrepareHTML
this.szHTML	= this.PrepareHTML()
break
case "font":
this.szCaption	= L_PUTITLEFONTFACE_TEXT
this.PrepareHTML	= _CFontFacesPopupRenderer_PrepareHTML
this.szHTML	= this.PrepareHTML()
break
case "fontsize":
this.szCaption	= L_PUTITLEFONTSIZE_TEXT
this.PrepareHTML	=_CFontSizesPopupRenderer_PrepareHTML
this.szHTML	= this.PrepareHTML()
break
case "Link":
this.szCaption	= L_PUTITLELINK_TEXT
this.PrepareHTML	= _CLinkPopupRenderer_PrepareHTML
this.szHTML	= this.PrepareHTML()
break
case "Table": 
this.szCaption	= L_PUTITLENEWTABLE_TEXT
this.PrepareHTML	= _CTablePopupRenderer_PrepareHTML
this.szHTML	= this.PrepareHTML()
break
case "Image":
this.szCaption	= L_PUTITLEIMAGE_TEXT
this.PrepareHTML	= _CImagePopupRenderer_PrepareHTML
this.szHTML	= this.PrepareHTML()
this.autoSize	= false
break
case "BackColor": 
this.szCaption	= L_PUTITLEBGCOLOR_TEXT
this.szHTML	= "<DIV ID=ColorPopup ALIGN=CENTER>" + _CUtil_BuildColorTable("") + "</DIV>"
break
case "ForeColor":
this.szCaption	= L_PUTITLETEXTCOLOR_TEXT
this.szHTML	= "<DIV ID=ColorPopup ALIGN=CENTER>" + _CUtil_BuildColorTable("") + "</DIV>"
break
default:
this.szCaption	= ""
break
}
}
function _CPopupRenderer_ResetContext(oDoc)
{
this.oDocument = oDoc
this.elCurrent = null
if (this.szType=="Table") {
var oSel	= idEditbox.document.selection.createRange() 
var oBlock = (oSel.parentElement != null ? _CUtil_GetElement(oSel.parentElement(),"TABLE") : _CUtil_GetElement(oSel.item(0),"TABLE"))
if (oBlock!=null) {
oDoc.all.tabEdit.className=""
oDoc.all.tabEditBodytxtPadding.value = oBlock.cellPadding
oDoc.all.tabEditBodytxtSpacing.value = oBlock.cellSpacing
oDoc.all.tabEditBodytxtBorder.value = oBlock.border
oDoc.all.tabEditBodytxtBorderColor.value = oBlock.borderColor
oDoc.all.tabEditBodytxtBackgroundImage.value = oBlock.background
oDoc.all.tabEditBodytxtBackgroundColor.value = oBlock.bgColor
}
oDoc.elCurrent = oBlock
}
}
function _CPopupRenderer_GetCaption()
{
return this.szCaption
}
function _CPopupRenderer_GetHTML()
{
return this.szHTML
}
function _CFontSizesPopupRenderer_PrepareHTML()
{ 
var sz = "<TABLE ALIGN=center ID=idList CELLSPACING=0 CELLPADDING=0>"
for (var i=1; i <= 7; i++) 
{
sz += ""
+ "<TR>"
+	"<TD NOWRAP "
+	"_item=" + i + " "
+	"ALIGN=center "
+	"STYLE=\"margin:0pt;padding:0pt\""
+	">"
+	"<FONT SIZE=" + i + ">" 
+	L_STYLESAMPLE_TEXT
+	"</FONT>"
+	"</TD>"
+ "</TR>"
}	
sz += "</TABLE>"
return sz
}
function _CFontFacesPopupRenderer_PrepareHTML()
{ 
var sz = "<TABLE ALIGN=center ID=idList CELLSPACING=0 CELLPADDING=0>"
for (var i=0; i < defaultFonts.length; i++) 
{
sz += ""
+ "<TR>"
+	"<TD NOWRAP "
+	"_item=" + i + " "
+	"ALIGN=center "
+	"STYLE=\"margin:0pt;padding:0pt\""
+	">"
+	"<FONT FACE=\"" + defaultFonts[i][0] + "\">" 
+	"ABC abc 123"
// +	defaultFonts[i][1] 
+	"</FONT> "
+	(defaultFonts[i][2] ? ("(" + defaultFonts[i][1] + ")") : "")
+	"</TD>"
+ "</TR>"
}
//	sz += "<TR><TD ONCLICK=\"parent._CFontFacesPopupRenderer_InsertOther(this)\" ALIGN=center _item=\"custom\" STYLE=\"margin:0pt;padding:0pt\" NOWRAP><FONT ID=customFont>" + L_CUSTOMFONT_TEXT + "</FONT></TR>"
sz += "</TABLE>"
return sz
}
function _CFontFacesPopupRenderer_InsertOther(el) {
if (el._item=="custom") {
el._item = "input"
var sz = "<INPUT ONSELECTSTART=\"event.cancelBubble=true\" ONKEYDOWN=\"event.cancelBubble=true\" ONKEYPRESS=\"if (event.keyCode==13) {this.face=this.value;document._renderer.Select(this.parentElement)};event.cancelBubble=true\" VALUE=\"" + L_CUSTOMFONTENTRY_TEXT + "\" ONFOCUS=\"if (this.value==this.defaultValue) this.select()\" TYPE=text>"
el.innerHTML = sz
el.children[0].focus()
}
el.document.parentWindow.event.cancelBubble = true	
}
function _CFormatBlockPopupRenderer_PrepareHTML()
{ 
var sz, defaultParagraphs = new Array()
defaultParagraphs[0] = new Array("<P>", L_STYLENORMAL_TEXT)	
defaultParagraphs[1] = new Array("<PRE>", L_STYLEFORMATTED_TEXT)
for (var i=2; i <= 7; i++) 
defaultParagraphs[i] = new Array("<H"+(i-1)+">", L_STYLEHEADING_TEXT + (i-1))	
sz = "<TABLE CLASS=block ALIGN=center ID=idList CELLSPACING=0 CELLPADDING=0>"
for (var i=0; i < defaultParagraphs.length; i++) 
{
sz += ""
+ "<TR>"
+	"<TD NOWRAP "
+	"_item=" + i + " "
+	"ALIGN=center "
+	"STYLE=\"margin:0pt;padding:0pt\""
+	">"
+	defaultParagraphs[i][0] 
+	defaultParagraphs[i][1] 
+	"</" + defaultParagraphs[i][0].substring(1) 
+	"</TD>"
+ "</TR>"
}
sz += "</TABLE>"
return sz
}
function _CTablePopupRenderer_PrepareHTMLPage(szID,bDisplay) {
var sz=""
+ "<TABLE height=100% " + ((!bDisplay) ? " style=\"display: none\"" : "") + " width=100% CELLSPACING=0 CELLPADDING=0 ID=" + szID + ">"
+	"<TR ID=tableContents>"
+	"<TD ID=tableOptions VALIGN=TOP NOWRAP WIDTH=150 ROWSPAN=2>"
+	"<A HREF=\"javascript:parent._CTablePopupRenderer_Select(this,'" + szID + "','prop1')\">"
+	L_TABLEROWSANDCOLS_TEXT
+	"</A>"
+	"<BR>"
+	"<A HREF=\"javascript:parent._CTablePopupRenderer_Select(this,'" + szID + "','prop2')\">"
+	L_TABLEPADDINGANDSPACING_TEXT
+	"</A>"
+	"<BR>"
+	"<A HREF=\"javascript:parent._CTablePopupRenderer_Select(this,'" + szID + "','prop3')\">"
+	L_TABLEBORDERS_TEXT
+	"</A>"
+	"<BR>"
+	"<A HREF=\"javascript:parent._CTablePopupRenderer_Select(this,'" + szID + "','prop4')\">"
+	L_TABLEBG_TEXT
+	"</A>"
+	"<BR>"
+	"</TD>"
+	"<TD BGCOLOR=black ID=puDivider ROWSPAN=2>"
+	"</TD>"
+	"<TD ID=tableProps VALIGN=TOP>"
if (szID=="tabNewBody") {
sz+= "<DIV ID='" + szID + "prop1'>"
+	"<P CLASS=tablePropsTitle>" + L_TABLEROWSANDCOLS_TEXT + "</P>"
+ "<TABLE><TR><TD>"
+	L_TABLEINPUTROWS_TEXT
+	"</TD><TD><INPUT SIZE=2 TYPE=text ID=" + szID + "txtRows VALUE=2 >"
+	"</TD></TR><TR><TD>"
+	L_TABLEINPUTCOLUMNS_TEXT
+	"</TD><TD><INPUT SIZE=2 TYPE=text ID=" + szID + "txtColumns VALUE=2 >"
+	"</TD></TR></TABLE></DIV>" 
} 
else {
sz+= "<DIV ID='" + szID + "prop1'>"
+	"<P CLASS=tablePropsTitle>" + L_TABLEROWSANDCOLS_TEXT + "</P>"	
+ "<INPUT type=button ID=" + szID + "txtRows VALUE=\"" + L_TABLEINSERTROW_TEXT + "\" ONCLICK=\"parent._CTablePopupRenderer_AddRow(this)\"><P>"
+ "<INPUT type=button ID=" + szID + "txtCells VALUE=\"" + L_TABLEINSERTCELL_TEXT + "\" ONCLICK=\"parent._CTablePopupRenderer_AddCell(this)\"><BR>"
+	"</DIV>" 
}
sz +=	"<DIV ID='" + szID + "prop2' STYLE=\"display: none\">"
+	"<P CLASS=tablePropsTitle>" + L_TABLEPADDINGANDSPACING_TEXT + "</P>"
+	L_TABLEINPUTCELLPADDING_TEXT
+	"<INPUT SIZE=2 TYPE=text ID=" + szID + "txtPadding VALUE=0>"
+	"<BR>"
+	L_TABLEINPUTCELLSPACING_TEXT
+	"<INPUT SIZE=2 TYPE=text ID=" + szID + "txtSpacing VALUE=0>"
+	"</DIV>"
+	"<DIV ID=" + szID + "prop3 STYLE=\"display: none\">"
+	"<P CLASS=tablePropsTitle>" + L_TABLEBORDERS_TEXT + "</P>"
+	L_TABLEINPUTBORDER_TEXT
+	"<INPUT SIZE=2 TYPE=text ID=" + szID + "txtBorder VALUE=1>"
+	"<BR>"
+	L_TABLEINPUTBORDERCOLOR_TEXT
+	"<INPUT SIZE=4 TYPE=text ID=" + szID + "txtBorderColor value=#000000><BR>" 
+	_CUtil_BuildColorTable("idBorder"+szID, "", "parent._CTablePopupRenderer_ColorSelect(this,'" + szID + "txtBorderColor')") 
+	"</DIV>"
+	"<DIV ID=" + szID + "prop4 SIZE=12 STYLE=\"display: none\">"
+	"<P CLASS=tablePropsTitle>" + L_TABLEBG_TEXT + "</P>"
+	L_TABLEINPUTBGIMGURL_TEXT
+	"<INPUT TYPE=text ID=" + szID + "txtBackgroundImage SIZE=15>"
+	"<BR>"
+	L_TABLEINPUTBGCOLOR_TEXT	
+	"<INPUT TYPE=text SIZE=4 ID=" + szID + "txtBackgroundColor><BR>" 
+	_CUtil_BuildColorTable("idBackground"+szID, "", "parent._CTablePopupRenderer_ColorSelect(this,'" + szID + "txtBackgroundColor')") 
+	"</DIV>"
+	"</TD>"
+	"</TR><TR><TD align=center ID=tableButtons valign=bottom>"
if (szID=="tabNewBody") {
sz +=	"<INPUT TYPE=submit ONCLICK=\"parent._CTablePopupRenderer_BuildTable('" + szID + "',this.document)\" VALUE=\"" + L_TABLEINSERT_TEXT + "\">"
+ " <INPUT TYPE=reset VALUE=\"" + L_CANCEL_TEXT + "\" ONCLICK=\"parent._CPopup_Hide()\">"
} else {
sz +=	"<INPUT TYPE=submit ONCLICK=\"parent._CTablePopupRenderer_BuildTable('" + szID + "',this.document)\" VALUE=\"" + L_TABLEUPDATE_TEXT + "\">"
+ " <INPUT TYPE=reset VALUE=\"" + L_CANCEL_TEXT + "\" ONCLICK=\"parent._CPopup_Hide()\">"
}
sz+= "</TD></TR></TABLE>"
return sz
}
function _CTablePopupRenderer_PrepareHTML()
{ 
var sz = "<TABLE CLASS=tabBox ID=\"tabSelect\" CELLSPACING=0 CELLPADDING=0 WIDTH=95%><TR HEIGHT=15><TD CLASS=tabItem STYLE=\"border-bottom: none\" NOWRAP><DIV ONCLICK=\"if (tabEdit.className!='disabled') {this.className='selected';this.parentElement.style.borderBottom = tabEdit.className=tabNewBody.style.display='';tabEditBody.style.display='none';tabEdit.parentElement.style.borderBottom='1px black solid'}\" CLASS=selected ID=tabNew>New Table</DIV></TD>"
+ "<TD CLASS=tabItem NOWRAP><DIV ONCLICK=\"if (this.className!='disabled') {this.className='selected';this.parentElement.style.borderBottom = tabNew.className=tabEditBody.style.display='';tabNew.parentElement.style.borderBottom='1px black solid';tabNewBody.style.display='none'}\" CLASS=disabled ID=tabEdit>Edit Table</DIV></TD><TD CLASS=tabSpace WIDTH=100%>&nbsp;</TD></TR><TR><TD VALIGN=TOP CLASS=tabBody COLSPAN=3>"
+ _CTablePopupRenderer_PrepareHTMLPage("tabNewBody",true)
+ _CTablePopupRenderer_PrepareHTMLPage("tabEditBody",false)
+	"</TD></TR></TABLE>"
return sz
}
function _CTablePopupRenderer_Select(el,szID, id) 
{
var d = el.document
for (var i = 1; i < 5; i++)
d.all[szID + "prop" + i].style.display = "none"
d.all[szID + id].style.display = ""
}
function _CTablePopupRenderer_ColorSelect(el,id) 
{
el.document.all[id].value = el.bgColor
}	
function _CTablePopupRenderer_AddRow(el) {
var elRow = el.document.elCurrent.insertRow()
for (var i=0;i<el.document.elCurrent.rows[0].cells.length;i++) {
var elCell = elRow.insertCell()
elCell.innerHTML = "&nbsp;"
}
}
function _CTablePopupRenderer_AddCell(el) {
for (var i=0;i<el.document.elCurrent.rows.length;i++) {
var elCell = el.document.elCurrent.rows[i].insertCell()
elCell.innerHTML = "&nbsp;"
}
}
function _CTablePopupRenderer_BuildTable(szID, d) 
{
if (szID=="tabNewBody") {
var sz = ""
+ "<TABLE "
+ (((d.all[szID + "txtBorder"].value=="") || (d.all[szID + "txtBorder"].value=="0")) ? "class=\"NOBORDER\"" : "")
+	(d.all[szID + "txtPadding"].value != "" ? "cellPadding=\"" + d.all[szID + "txtPadding"].value + "\" " : "")
+	(d.all[szID + "txtSpacing"].value != "" ? "cellSpacing=\"" + d.all[szID + "txtSpacing"].value + "\" " : "")
+	(d.all[szID + "txtBorder"].value != "" ? "border=\"" + d.all[szID + "txtBorder"].value + "\" " : "")
+	(d.all[szID + "txtBorderColor"].value != "" ? "bordercolor=\"" + d.all[szID + "txtBorderColor"].value + "\" " : "")
+	(d.all[szID + "txtBackgroundImage"].value != "" ? "background=\"" + d.all[szID + "txtBackgroundImage"].value + "\" " : "")
+	(d.all[szID + "txtBackgroundColor"].value != "" ? "bgColor=\"" + d.all[szID + "txtBackgroundColor"].value + "\" " : "")
+ ">"
for (var r=0; r < d.all[szID + "txtRows"].value; r++) 
{
sz += "<TR>"
for (var c=0; c < d.all[szID + "txtColumns"].value; c++)
sz += "<TD>&nbsp;</TD>"
sz += "</TR>"
}
sz += "</TABLE>"
insertHTML(sz)
} else
if (d.elCurrent) {
d.elCurrent.cellPadding = d.all.tabEditBodytxtPadding.value
d.elCurrent.cellSpacing = d.all.tabEditBodytxtSpacing.value
d.elCurrent.border = d.all.tabEditBodytxtBorder.value
d.elCurrent.className = (d.elCurrent.border=="" || d.elCurrent.border==0) ? "NOBORDER" : ""
d.elCurrent.borderColor = d.all.tabEditBodytxtBorderColor.value
d.elCurrent.bgColor = d.all.tabEditBodytxtBackgroundColor.value
d.elCurrent.background = d.all.tabEditBodytxtBackgroundImage.value
}
_CPopup_Hide()	
}
function _CListPopupRenderer_OnClick() 
{
var elTD = _CUtil_GetElement(this.oDocument.parentWindow.event.srcElement, "TD") 
if (elTD && elTD._item) this.Select(elTD)
}
function _CListPopupRenderer_GenericOnKeyDown() {
var ev	= this.oDocument.parentWindow.event
if (ev.keyCode==27) _CPopup_Hide()
}
function _CListPopupRenderer_OnKeyDown() 
{
var el
var iRow = iCell	= 0
var ev	= this.oDocument.parentWindow.event
var idList = this.oDocument.all.idList
var elTR	= _CUtil_GetElement(this.elCurrent,"TR")
var elTD	= _CUtil_GetElement(this.elCurrent,"TD")
if (elTR != null) 
{
iRow	= elTR.rowIndex
iCell = elTD.cellIndex
}
switch (ev.keyCode) 
{
case 37:
iCell--
if (iCell < 0) 
iCell = idList.rows[iRow].cells.length-1
break
case 38:
iRow--
if (iRow < 0) 
iRow = idList.rows.length-1
break
case 39:
iCell++
if (iCell > idList.rows[iRow].cells.length-1) 
iCell = 0
break
case 40:
iRow++
if (iRow > idList.rows.length-1) 
iRow = 0
break
case 13:
break;
case 27:
_CPopup_Hide()
break;
default:
return;
}
el = idList.rows[iRow].cells[iCell]
if (el && el._item)
if (13 == ev.keyCode) {
ev.keyCode=0	
this.Select(el)
}
else
this.Highlight(el)
}
function _CListPopupRenderer_OnMouseOver() 
{
var el = _CUtil_GetElement(this.oDocument.parentWindow.event.srcElement, "TD") 
if (el && el._item && el != this.elCurrent)
this.Highlight(el)
}
function _CListPopupRenderer_Highlight(el) 
{
var elC = this.elCurrent
if (elC) elC.style.borderWidth = elC.style.borderColor = elC.style.borderStyle = ""
el.style.borderWidth	= "1px"
el.style.borderColor	= "green"
el.style.borderStyle	= "solid"
this.elCurrent	= el
}
function _CListPopupRenderer_Select(elTD) 
{
g_state.RestoreSelection()
var el = elTD.children[0]
switch (this.szType) 
{
case "font":
_Format("FontName",el.face)
break
case "fontsize":
_Format("FontSize",el.size)	
break
case "formatblock":
_Format("FormatBlock","<" + el.tagName + ">")
break
case "ForeColor":
_Format("ForeColor", elTD.bgColor)
break
case "BackColor":
_Format("BackColor",elTD.bgColor)
break
}
_CPopup_Hide()
}
function _CLinkPopupRenderer_AddLink(d) 
{
var szURL = d.all.urlValue.value
var szType = d.all.urlType[d.all.urlType.selectedIndex].text
var oSel = g_state.GetSelection()
var sType = oSel.type
szURL = ((0 == szURL.indexOf("mailto:") || 0 == szURL.indexOf("http://") || 0 == szURL.indexOf("ftp://")) ? "" : szType) + szURL
if (szURL!="") 
{
if ((oSel.parentElement) && (oSel.text=="")) 
{
oSel.expand("word")
if (oSel.text=="") 
{
var oStore = oSel.duplicate()
if (d.all.pageList) {
var idx = d.all.pageList.selectedIndex
if (d.all.pageList[idx].value==szURL)
oSel.text = d.all.pageList[idx].text
else
oSel.text = szURL
}
else
oSel.text = szURL	
oSel.setEndPoint("StartToStart",oStore)
} 
oSel.select()
sType="Text"
}
if ((oSel.item) && (oSel.item(0).tagName=="IMG")) 
{
oSel.item(0).width = oSel.item(0).offsetWidth
oSel.item(0).height = oSel.item(0).offsetHeight
oSel.item(0).border = (d.all.displayBorder.checked) ? 1 : ""
}
if (d.all.urlValue.value!="")
oSel.execCommand("CreateLink",false,szURL)	
else
oSel.execCommand("UnLink",false,szURL)	
}
idEditbox.focus()	
}
function _CLinkPopupRenderer__UpdateURL(oDoc,szURL) {
var szType = szURL.substring(0,szURL.indexOf(":"))
for (var i=0;i<oDoc.all.urlType.length;i++) 
if (oDoc.all.urlType[i].value==szType)
oDoc.all.urlType.selectedIndex = i
if (("http"==szType) || ("ftp"==szType)) 
szURL = szURL.substring(szURL.indexOf("//")+2)
else
szURL = szURL.substring(szURL.indexOf(":")+1)
oDoc.all.urlValue.value = szURL
}
function _CLinkPopupRenderer_PrepareHTML() 
{
var d = this.oDocument
var oSel = g_state.GetSelection()
var oEl, sType = oSel.type, bImg = false, szURL = sz = ""
if (oSel.parentElement) 
{
oEl = _CUtil_GetElement(oSel.parentElement(),"A")
}
else 
{
oEl = _CUtil_GetElement(oSel.item(0),"A")
bImg = oSel.item(0).tagName=="IMG"
}
if (oEl)
szURL = oEl.href
sz ="<TABLE ALIGN=center>" 
if (g_state.aLinks.length>0) 
{
sz += ""
+ "<TR>"
+	"<TD>" 
/*
+	L_LINKSELECT_TEXT 
+	"<SELECT ID=pageList ONCHANGE=\"parent._CLinkPopupRenderer__UpdateURL(this.document,this[this.selectedIndex].value)\">"

+	"<OPTION VALUE=''>" 
+	"=="
+	L_LINKSELECTPAGE_TEXT
+	"=="
+	"</OPTION>"
for (var i = 0; i < g_state.aLinks.length; i++) 
{
sz += ""
+ "<OPTION VALUE=\"" + g_state.aLinks[i][0] + "\" "
+	(oEl && (g_state.aLinks[i][0]==oEl.href) ? "SELECTED" : "")
+ ">"
+	g_state.aLinks[i][1]
+ "</OPTION>"
}
sz += "</SELECT>"
*/
}
var arTypes = new Array("http","ftp","mailto")
var arText = new Array("http://","ftp://","mailto:")
var szType = szURL.substring(0,szURL.indexOf(":"))
if (("http"==szType) || ("ftp"==szType)) 
szURL = szURL.substring(szURL.indexOf("//")+2)
else
szURL = szURL.substring(szURL.indexOf(":")+1)
sz += ""
+ "<BR>" 
+ L_LINKWEB_TEXT 
+ "<NOBR><SELECT ID=urlType>"
for (var i=0;i<arTypes.length;i++) {
sz+= "<OPTION VALUE='" + arTypes[i] + "' "
+	(arTypes[i]==szType ? " SELECTED " : "")
+ ">" + arText[i]
}
sz += "</SELECT><INPUT ID=urlValue SIZE=45 VALUE=\"" + szURL + "\" TYPE=text></NOBR>"
if (bImg)
{
sz += ""
+ "<BR>"
+ "<INPUT TYPE=checkbox ID=displayBorder " + ((oSel.item(0).border!=0) ? " checked " : "") + ">" 
+ L_LINKIMGBORDER_TEXT
}
sz += ""
+	"</TD>"
+	"</TR>"
+	"<TR>"
+	"<TD ALIGN=center>"
+	"<INPUT ONCLICK=\"parent._CLinkPopupRenderer_AddLink(this.document)\" TYPE=submit ID=idSave VALUE=\"" + L_INSERT_TEXT + "\"> <INPUT ONCLICK=\"parent._CPopup_Hide()\" TYPE=reset ID=idCancel VALUE=\"" + L_CANCEL_TEXT + "\">"
+	"</TD>"
+	"</TR>"
+ "</TABLE>"
return sz
}
// UTIL
function _CUtil_GetElement(oEl,sTag) 
{
while (oEl!=null && oEl.tagName!=sTag)
oEl = oEl.parentElement
return oEl
}
function _CUtil_BuildColorTable(sID,fmt,szClick) 
{
var sz, cPick = new Array("00","33","66","99","CC","FF"), iCnt=2
var iColors = cPick.length, szColor = ""
sz = "<TABLE CELLSPACING=0 CELLPADDING=0><TR><TD VALIGN=middle><DIV CLASS=currentColor ID=\"" + sID + "Current\">&nbsp;</DIV></TD><TD>"
+ "<TABLE ONMOUSEOUT=\"document.all." + sID + "Current.style.backgroundColor = ''\" ONMOUSEOVER=\"document.all." + sID + "Current.style.backgroundColor = event.srcElement.bgColor\" CLASS=colorTable CELLSPACING=0 CELLPADDING=0 ID=\"" + sID + "\">"
for (var r=0;r<iColors;r++) {
sz+="<TR>"
for (var g=iColors-1;g>=0;g--)
for (var b=iColors-1;b>=0;b--) {
szColor = cPick[r]+cPick[g]+cPick[b] 
sz+="<TD"
+ " BGCOLOR=\"#" + szColor + "\""
+ "_item=\"" + szColor + "\" "
+ "TITLE=\"#" + szColor + "\" "
+ (szClick ? "ONCLICK=\"" + szClick + "\" " : "")
+ ">&nbsp;</TD>"
}
sz+="</TR>"
}
sz+="</TABLE></TD></TR></TABLE>"
return sz
}
function _CUtil_GetBlock(oEl) 
{
var sBlocks = "|H1|H2|H3|H4|H5|H6|P|PRE|LI|TD|DIV|BLOCKQUOTE|DT|DD|TABLE|HR|IMG|"
while ((oEl!=null) && (sBlocks.indexOf("|"+oEl.tagName+"|")==-1))
oEl = oEl.parentElement
return oEl
}
