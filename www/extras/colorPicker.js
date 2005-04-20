/**
* MiniColorPicker v0.3
* 	By: me [at] daantje [dot] nl
*
* 	Last updated: Thu Sep 16 12:59:10 CEST 2004
*
*	Documentation:
*		A realy small Photoshop like color picker in DHTML.
*		It should be compatible with MSIE and Mozilla based
*		browsers.
*
*	License:
*		GPL
*
*	Support:
*		Not realy.
*/


//Config ammount of colors
var bit = 16; //increase to make picker bigger (and slower)


//define globals, don't change!
bit = Math.round(255 / bit);
var ConvArray = new Array(0,1,2,3,4,5,6,7,8,9,'A','B','C','D','E','F');
var picked = new Array();
var pickedColorRGB = new Array();
var toolbarShow = new Array();
var donePickerInits = 0;
var clickedPicker;
var tmr = null;


//this function is written by Guido Socher, guido at linuxfocus dot org
function dec2hex(value){
    var retval = '';
    var intnum;
    var tmpnum;
    var i = 0;

    intnum = parseInt(value,10);
    if (isNaN(intnum)){
        retval = 'NaN';
    }else{
        while (intnum > 0.9){
            i++;
            tmpnum = intnum;
            // cancatinate return string with new digit:
            retval = ConvArray[tmpnum % 16] + retval;  
            intnum = Math.floor(tmpnum / 16);
            if (i > 100){
                // break infinite loops
                retval = 'NaN';
                break;
            }
        }
    }
	if(retval.length == 1)
		retval = '0' + retval;
	else if(retval.length == 0)
		retval = '00';
    return retval;
}


function HEXcolor2RGB(value){
	value = value.replace('#','');
	pickedColorRGB[0] = value.substr(0,2);
	pickedColorRGB[1] = value.substr(2,2);
	pickedColorRGB[2] = value.substr(4,2);
	for(i=0;i<3;i++){
		pickedColorRGB[i] = parseInt(pickedColorRGB[i],16);
	}
	return pickedColorRGB;
}


function buildPicker(){
	htmlStr = "<table border=0 cellpadding=0 cellspacing=0 width="+Math.round((255/bit) * 5)+" height="+Math.round((255/bit) * 5)+"><tr>";
	//palet
	for(x=0;x<=255;x=x+bit){
		for(y=0;y<=255;y=y+bit){
			htmlStr+= "<td id='"+x+","+y+"' onclick=\"pickColor(picked[clickedPicker],"+x+","+y+")\" unselectable=on width=5 height=5></td>";
		}
		htmlStr+= "</tr><tr>";
	}
	//grays
	for(x=0;x<=255;x=x+bit){
		c = dec2hex(x)+dec2hex(x)+dec2hex(x);
		htmlStr+= "<td bgcolor=\"#"+c+"\" onclick=\"pickColor("+x+","+x+","+x+")\" unselectable=on width=5 height=5></td>";
	} 
	htmlStr+= "</tr></table>";
	
	return htmlStr;
}


function changePallet(R){
	for(G=0;G<=255;G=G+bit){
		for(B=0;B<=255;B=B+bit){
			document.getElementById(G+','+B).style.backgroundColor = '#'+dec2hex(R)+dec2hex(G)+dec2hex(B);
		}	
	}
	picked[clickedPicker] = R;
}


function changePickerHue(){
	g = 0;
	b = 255;
	gS = 0;
	bS = 1;
	htmlStr = "<table border=0 cellpadding=0 cellspacing=0 width=5 height="+((255/bit) * 5)+">";
	for(r=0;r<=255;r=r+bit){
		c = dec2hex(r)+dec2hex(g)+dec2hex(b);
		htmlStr+= "<tr><td bgcolor=\"#"+c+"\" onclick=\"changePallet("+r+")\" width=5 height=5></td></tr>";
		
		if(g == 255) gS = 1;
		else if(g == 0) gS = 0;
		
		if(b == 255) bS = 1;
		else if(b == 0) bS = 0;
		
		if(gS == 0)
			g = g + (bit * 2);
		else
			g = g - (bit * 2);
		
		if(bS == 0)
			b = b + (bit * 4);
		else
			b = b - (bit * 4);
	} 
	htmlStr+= "<tr><td bgcolor=\"#ffffff\" onclick=\"changePallet(255)\" width=5 height=5></td></tr>";
	htmlStr+= "</table>";
	
	return htmlStr;
}


function pickColor(r,g,b){
	c = '#'+dec2hex(r)+dec2hex(g)+dec2hex(b);
	document.getElementById(clickedPicker).style.backgroundColor = c;
	document.getElementById(clickedPicker+'Value').value = c;
	changePallet(r);
}


function setPickedColorFromForm(obj){
	c = HEXcolor2RGB(obj.value);
	changePallet(c[0]);
	document.getElementById(obj.id.replace('Value','')).style.backgroundColor = obj.value;
}


function placePickerToolbar(obj){
	lastClickedPicker = clickedPicker;
	clickedPicker = obj.id;
	if(tmr)
		clearTimeout(tmr);
	if(toolbarShow[obj.id] == 0){
		toolbarShow[obj.id] = 1;
		
		t = obj.offsetTop + parseInt(obj.style.height) + 3;
		l = obj.offsetLeft;
		while(obj.offsetParent){
			t+= obj.offsetParent.offsetTop;
			l+= obj.offsetParent.offsetLeft;
			obj = obj.offsetParent;
		}
		document.getElementById('colorPickerTools').style.top = t;
		document.getElementById('colorPickerTools').style.left = l;
		document.getElementById('colorPickerTools').style.display = 'block';
		if(picked[clickedPicker] == null){
			changePallet(255);
		}else{
			//changePallet(picked[clickedPicker]);
			setPickedColorFromForm(document.getElementById(clickedPicker+'Value'));
		}
	}else if(toolbarShow[obj.id] == 1){
		document.getElementById('colorPickerTools').style.display = 'none';
		toolbarShow[obj.id] = 0;
	}
}
	

function killColorPicker(sw){
	if(sw == 1 && clickedPicker){
		tmr = setTimeout('placePickerToolbar(document.getElementById(clickedPicker));',1000);
	}else if(tmr){
		clearTimeout(tmr);
	}
}


function initColorPicker(fieldName,fieldValue){
	pickerScreen = buildPicker();
	hueScreen = changePickerHue();
	if(!fieldValue)
		fieldValue = "";

	s = "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">";
	s+= "<td><div onmouseout=\"killColorPicker(1)\" onmouseover=\"killColorPicker(0)\" onclick=\"placePickerToolbar(this)\" style=\"width:15px;height:15px;border: 1px solid #000000;cursor:pointer;background-color:"+fieldValue+";\" id=pickedColor"+donePickerInits+"></div></td>";
	s+= "<td>&nbsp;<input type=\"text\" name=\""+fieldName+"\" id=pickedColor"+donePickerInits+"Value value=\""+fieldValue+"\" size=7 style=\"font-size:10px;\" onchange=\"setPickedColorFromForm(this)\"></td>";
	s+= "</table>";
	document.write(s);
	if(donePickerInits == 0){
		document.write("<div id=colorPickerTools onmouseout=\"killColorPicker(1)\" onmouseover=\"killColorPicker(0)\" style=\"z-Index:10000;display:none;cursor:crosshair;border:0px solid #000000;background-color:#ffffff;\"></div>");
		document.getElementById('colorPickerTools').innerHTML = '<table border=0 cellpadding=0 cellspacing=0><tr><td valign=top>'+pickerScreen+'</td><td valign=top style="border-left:1px solid #000000;">'+hueScreen+'</td></tr><tr><td colspan=2><table border=0 cellpadding=0 cellspacing=0 width=100%><tr><td width=50% style="background-color:#ffffff;" onclick="pickColor(255,255,255);" height=5></td><td width=50% style="background-color:#000000;" onclick="pickColor(0,0,0);" height=5></td></tr></table></td></tr></table>';
	}

	toolbarShow["pickedColor"+donePickerInits] = 0;
	donePickerInits++;
}
