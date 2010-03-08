if (typeof WebGUI == "undefined" || !WebGUI) {
    var WebGUI = {};
}

WebGUI.FieldCheck = function (fieldId,fieldType,required) {
  this.fieldId=fieldId;
  this.fieldType=fieldType;
  this.required=required;
  var obj = this;

  this.i18nObj = new WebGUI.i18n( {
    namespaces : {
      'Form' : ['field required']
    },
    onpreload : {
      fn       : this.initialize,
      obj      : this,
      override : true
    }
  } );
  this.i18n = function (key) {
    return this.i18nObj.get('Form',key)
  };

  return this;
}

WebGUI.FieldCheck.prototype.initialize = function() {
  var fieldId=this.fieldId;
  var fieldType=this.fieldType;
  var required=this.required;
  var field=document.getElementById(fieldId);
  var input=field.value;

  var myAjaxEvent = new WebGUI.FieldCheck.AjaxEvent();
  myAjaxEvent.startThrobber(fieldId);

  if (required && !input) {
    var imgEltId=fieldId+"_Img";
    var imgElt=document.getElementById(imgEltId);
    var extras = getWebguiProperty("extrasURL");
    imgElt.setAttribute('src',extras+'/form/cross.png');
    alert(this.i18n('field required'));
    return false;
  }

  myAjaxEvent.connect(fieldId,'/?op=formHelper;sub=check;class='+fieldType+';input='+input);
}

WebGUI.FieldCheck.AjaxEvent = function() {
  return this;
}

WebGUI.FieldCheck.AjaxEvent.prototype = {
  extras: getWebguiProperty("extrasURL"),
  startThrobber: function(fieldId) {
    this.field = document.getElementById(fieldId);
    var imgEltId=fieldId+"_Img";
    var imgElt;
    if(document.getElementById(imgEltId)==undefined){
      var formElt=this.field.parentNode;
      var imgElt=document.createElement('img');
      imgElt.setAttribute('id',imgEltId);
      WebGUI.FieldCheck.insertAfter(imgElt,this.field);
    }else{
      var imgElt=document.getElementById(imgEltId);
    }
    imgElt.setAttribute('src',this.extras+'/form/throbber.gif');
  },
  connect: function(fieldId,sUri) {
    if (!sUri && !this.sUri) {
      return false;
    } else {
      this.sUri = (!sUri) ? this.sUri : sUri;
      YAHOO.util.Connect.asyncRequest('GET', this.sUri, {
        success: function (o) {
          var oJSON = eval("(" + o.responseText + ")");
          var imgEltId=fieldId+"_Img";
          var imgElt=document.getElementById(imgEltId);
          document.getElementById(imgEltId);
          if(oJSON.error == ""){
            imgElt.setAttribute('src',this.extras+'/form/tick.png');
          }else{
            imgElt.setAttribute('src',this.extras+'/form/cross.png');
            alert(oJSON.error);
          }
        },
        scope: this
      });
    }
  }
};

WebGUI.FieldCheck.insertAfter = function(newElement,targetElement) {
  var parent = targetElement.parentNode;
  if(parent.lastchild == targetElement) {
    parent.appendChild(newElement);
  }else{
    parent.insertBefore(newElement, targetElement.nextSibling);
  }
};
