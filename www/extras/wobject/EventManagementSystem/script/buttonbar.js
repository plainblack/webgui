/********************************************************************************************
* BlueShoes Framework; This file is part of the php application framework.
* NOTE: This code is stripped (obfuscated). To get the clean documented code goto 
*       www.blueshoes.org and register for the free open source *DEVELOPER* version or 
*       buy the commercial version.
*       
*       In case you've already got the developer version, then this is one of the few 
*       packages/classes that is only available to *PAYING* customers.
*       To get it go to www.blueshoes.org and buy a commercial version.
* 
* @copyright www.blueshoes.org
* @author    Samuel Blume <sam at blueshoes dot org>
* @author    Andrej Arn <andrej at blueshoes dot org>
*/
if (!Bs_Objects) {var Bs_Objects = [];};

function Bs_ButtonBar() {
   this._id;
   this._objectId;
   this.imgPath = '/_bsImages/buttons/';
   this.useHelpBar;
   this.alignment = 'hor';
   this.ignoreEvents = false;
   this.helpBarStyle = "font-family:arial; font-size:11px; height:16px;";
   this._buttons = new Array;
   this._parentButton;
   this._constructor = function() {
      this._id = Bs_Objects.length;
	  Bs_Objects[this._id] = this;
	  this._objectId = "Bs_ButtonBar_"+this._id;
   }
   
   this.addButton = function(btn, helpBarText) {
      btn._buttonBar = this;
	  this._buttons[this._buttons.length] = new Array(btn, helpBarText);
   }
   
   this.newGroup = function() {
      this._buttons[this._buttons.length] = '|';
   }
   
   this.render = function() {
      var out = new Array;
	  if (this._isGecko()) {
         out[out.length] = '<div style="background-color: menu; padding: 2px">';
	  } else {
         out[out.length] = '<div style="background-color:menu;">';
	  }
      out[out.length] = '<div>';
	  for (var i=0; i<this._buttons.length; i++) {
         if (this.alignment != 'hor') {
            out[out.length] = '<div>';
	     }
         if (this._buttons[i] == '|') {
            out[out.length] = '<span class="' + ((this.alignment == 'hor') ? 'separatorForHorizontal' : 'separatorForVertical') + '"></span>';
		 } else {
            var btn = this._buttons[i][0];
			var helpBarDiv = false;
			if (typeof(this.useHelpBar) == 'string') {
               var helpBarDiv = this.useHelpBar;
			} else if (this.useHelpBar) {
               var helpBarDiv = this._objectId + '_helpBarDiv';
			}
            if (helpBarDiv != false) {
               btn.attachEvent("document.getElementById('" + helpBarDiv + "').innerHTML = \"" + this._buttons[i][1] + "\";", 'over');
			   btn.attachEvent("document.getElementById('" + helpBarDiv + "').innerHTML = \"\";", 'out');
			}
            out[out.length] = btn.render();
	     }
         if (this.alignment != 'hor') {
            out[out.length] = '</div>';
	     }
      }
      out[out.length] = '</div>';
	  if (this.useHelpBar) {
         if (this.useHelpBar == 2) {
            out[out.length] = '<div style="' + this.helpBarStyle + '">';
			out[out.length] = '<img align="middle" src="' + this.imgPath + 'bs_info.gif" border="0" onMouseOver="document.getElementById(\'' + helpBarDiv + '\').innerHTML = \'Move your mouse over the buttons to see the description here.\';" onMouseOut="document.getElementById(\'' + helpBarDiv + '\').innerHTML = \'\';"> ';
			out[out.length] = '<span id="' + helpBarDiv + '"></span></div>';
	     } else if (this.useHelpBar == true) {
            out[out.length] = '<div id="' + helpBarDiv + '" style="' + this.helpBarStyle + '"></div>';
		 }
      }
      out[out.length] = '</div>';
      return out.join('');
   }
this.drawOut = function() {
document.writeln(this.render());}
this.drawInto = function(elm) {
if (typeof(elm) == 'string') {
elm = document.getElementById(elm);}
if (elm) {
elm.innerHTML = this.render();}
}
this._isGecko = function() {
if (navigator.appName == "Microsoft Internet Explorer") return false;    var x = navigator.userAgent.match(/gecko/i);
return (x);return false;}
this._constructor();}
