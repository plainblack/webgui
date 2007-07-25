if (!Bs_Objects) {
   var Bs_Objects = [];
};

function Bs_TabSet(outerElmId) {
   var a = arguments;
   this._outerElmId = (a.length>1) ? a[1] :  a[0];
   this._id;
   this._objectId;
   this.tabs = new Array;
   this._activeTabIdx = 0;
   this._onTabSelectEvent;
   this._constructor = function(button) {
      this._id = Bs_Objects.length;
      Bs_Objects[this._id] = this;
	  this._objectId = "Bs_TabSet_"+this._id;
	  this._button = button;
   }
   
   this.addTab = function(caption, container) {
      if (typeof(caption) == 'object') {
         var o = caption;
	  } else {
         var o = new Object;
		 o.caption   = caption;
		 o.container = container;
	  }
      o.tabIdx = this.tabs.length;this.tabs[o.tabIdx] = o;
   }
   
   this.render = function() {
      var ret = new Array;
      ret[ret.length] = '<div class="tabsetTabsDiv">';
      ret[ret.length] = '<div style="width:2px; min-width:2px; display:inline;"></div>';
      for (var i=0; i<this.tabs.length; i++) {
         if (i == this._activeTabIdx) {
            var cls = 'bsTabsetActive';
	     } else {
            var cls = 'bsTabsetInactive';
		    if (this.tabs[i].container) this.tabs[i].container.style.display = 'none';
	     }
         ret[ret.length] = '<div unselectable="On" id="' + this._objectId + '_tabCap_' + i + '" class="bsTabset ' + cls + '" style="display:inline;" onclick="Bs_Objects['+this._id+'].switchTo(' + i + ');">' + this.tabs[i].caption + '</div>';
      }
	  ret[ret.length] = '<div style="width:50px; min-width:50px; display:inline;"></div>';
	  ret[ret.length] = '<div unselectable="On" style="display:inline;"><input type="submit" value="Save" class="tabButton"></div>'
      ret[ret.length] = '</div>';
      return ret.join('');
   }
   
   this.draw = function() {
      var elem = document.getElementById(this._outerElmId + '_tabs');
	  if (elem) elem.innerHTML = this.render();
   }
   
   this.switchTo = function(theReg) {
      newRegIdx = -1;
	  if (theReg=='') theReg = '0';
	  if (isNaN(parseInt(theReg))) {
         for (var i=0; i<this.tabs.length; i++) {
            if (this.tabs[i].caption == theReg) (newRegIdx = i);
		 }
      } else {
         newRegIdx = theReg;
	  }
      if (newRegIdx<0) return;
	  for (var i=0; i<this.tabs.length; i++) {
         var elem = document.getElementById(this._objectId + '_tabCap_' + i);
		 if (!elem) continue;if (newRegIdx == i) {
            this._activeTabIdx = i;
			elem.className = 'bsTabset bsTabsetActive';
			this.tabs[i].container.style.display = 'block';
			if (typeof(this.tabs[i].onFocus) != 'undefined') {
               this._triggerFunction(this.tabs[i].onFocus);
			}
            this.fireOnTabSelect();
		 } else {
            elem.className = 'bsTabset bsTabsetInactive';
			this.tabs[i].container.style.display = 'none';
			if (typeof(this.tabs[i].onBlur) != 'undefined') {
               this._triggerFunction(this.tabs[i].onBlur);
			}
         }
      }
   }

   this.getActiveTab = function() {
      return this.tabs[this._activeTabIdx];
   }
   
   this.onTabSelect = function(yourEvent) {
      this._onTabSelectEvent = yourEvent;
   }

   this.fireOnTabSelect = function() {
      if (this._onTabSelectEvent) {
         func = this._onTabSelectEvent;
	     if (this._onTabSelectEvent == 'string') {
            eval(func);
	     } else {
            func(this);
	     }
      }
      return true;
   }
   
   this._triggerFunction = function(func) {
      if (typeof(func) == 'function') {
         func();
	  } else if (typeof(func) == 'string') {
         eval(func);
	  }
   }
   
   this._constructor();
}
