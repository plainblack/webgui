/*
 * HTML Parser By John Resig (ejohn.org)
 * Original code by Erik Arvidsson, Mozilla Public License
 * http://erik.eae.net/simplehtmlparser/simplehtmlparser.js
 *
 * // Use like so:
 * HTMLParser(htmlString, {
 *     start: function(tag, attrs, unary) {},
 *     end: function(tag) {},
 *     chars: function(text) {},
 *     comment: function(text) {}
 * });
 *
 * // or to get an XML string:
 * HTMLtoXML(htmlString);
 *
 * // or to get an XML DOM Document
 * HTMLtoDOM(htmlString);
 *
 * // or to inject into an existing document/DOM node
 * HTMLtoDOM(htmlString, document);
 * HTMLtoDOM(htmlString, document.body);
 *
 */

(function(){

	// Regular Expressions for parsing tags and attributes
	var startTag = /^<(\w+)((?:\s+\w+(?:\s*=\s*(?:(?:"[^"]*")|(?:'[^']*')|[^>\s]+))?)*)\s*(\/?)>/,
		endTag = /^<\/(\w+)[^>]*>/,
		attr = /(\w+)(?:\s*=\s*(?:(?:"((?:\\.|[^"])*)")|(?:'((?:\\.|[^'])*)')|([^>\s]+)))?/g;
		
	// Empty Elements - HTML 4.01
	var empty = makeMap("area,base,basefont,br,col,frame,hr,img,input,isindex,link,meta,param,embed");

	// Block Elements - HTML 4.01
	var block = makeMap("address,applet,blockquote,button,center,dd,del,dir,div,dl,dt,fieldset,form,frameset,hr,iframe,ins,isindex,li,map,menu,noframes,noscript,object,ol,p,pre,script,table,tbody,td,tfoot,th,thead,tr,ul");

	// Inline Elements - HTML 4.01
	var inline = makeMap("a,abbr,acronym,applet,b,basefont,bdo,big,br,button,cite,code,del,dfn,em,font,i,iframe,img,input,ins,kbd,label,map,object,q,s,samp,script,select,small,span,strike,strong,sub,sup,textarea,tt,u,var");

	// Elements that you can, intentionally, leave open
	// (and which close themselves)
	var closeSelf = makeMap("colgroup,dd,dt,li,options,p,td,tfoot,th,thead,tr");

	// Attributes that have their values filled in disabled="disabled"
	var fillAttrs = makeMap("checked,compact,declare,defer,disabled,ismap,multiple,nohref,noresize,noshade,nowrap,readonly,selected");

	// Special Elements (can contain anything)
	var special = makeMap("script,style");

	var HTMLParser = this.HTMLParser = function( html, handler ) {
		var index, chars, match, stack = [], last = html;
		stack.last = function(){
			return this[ this.length - 1 ];
		};

		while ( html ) {
			chars = true;

			// Make sure we're not in a script or style element
			if ( !stack.last() || !special[ stack.last() ] ) {

				// Comment
				if ( html.indexOf("<!--") == 0 ) {
					index = html.indexOf("-->");
	
					if ( index >= 0 ) {
						if ( handler.comment )
							handler.comment( html.substring( 4, index ) );
						html = html.substring( index + 3 );
						chars = false;
					}
	
				// end tag
				} else if ( html.indexOf("</") == 0 ) {
					match = html.match( endTag );
	
					if ( match ) {
						html = html.substring( match[0].length );
						match[0].replace( endTag, parseEndTag );
						chars = false;
					}
	
				// start tag
				} else if ( html.indexOf("<") == 0 ) {
					match = html.match( startTag );
	
					if ( match ) {
						html = html.substring( match[0].length );
						match[0].replace( startTag, parseStartTag );
						chars = false;
					}
				}

				if ( chars ) {
					index = html.indexOf("<");
					
					var text = index < 0 ? html : html.substring( 0, index );
					html = index < 0 ? "" : html.substring( index );
					
					if ( handler.chars )
						handler.chars( text );
				}

			} else {
				html = html.replace(new RegExp("(.*)<\/" + stack.last() + "[^>]*>"), function(all, text){
					text = text.replace(/<!--(.*?)-->/g, "$1")
						.replace(/<!\[CDATA\[(.*?)]]>/g, "$1");

					if ( handler.chars )
						handler.chars( text );

					return "";
				});

				parseEndTag( "", stack.last() );
			}

			if ( html == last )
				throw "Parse Error: " + html;
			last = html;
		}
		
		// Clean up any remaining tags
		parseEndTag();

		function parseStartTag( tag, tagName, rest, unary ) {
			if ( block[ tagName ] ) {
				while ( stack.last() && inline[ stack.last() ] ) {
					parseEndTag( "", stack.last() );
				}
			}

			if ( closeSelf[ tagName ] && stack.last() == tagName ) {
				parseEndTag( "", tagName );
			}

			unary = empty[ tagName ] || !!unary;

			if ( !unary )
				stack.push( tagName );
			
			if ( handler.start ) {
				var attrs = [];
	
				rest.replace(attr, function(match, name) {
					var value = arguments[2] ? arguments[2] :
						arguments[3] ? arguments[3] :
						arguments[4] ? arguments[4] :
						fillAttrs[name] ? name : "";
					
					attrs.push({
						name: name,
						value: value,
						escaped: value.replace(/(^|[^\\])"/g, '$1\\\"') //"
					});
				});
	
				if ( handler.start )
					handler.start( tagName, attrs, unary );
			}
		}

		function parseEndTag( tag, tagName ) {
			// If no tag name is provided, clean shop
			if ( !tagName )
				var pos = 0;
				
			// Find the closest opened tag of the same type
			else
				for ( var pos = stack.length - 1; pos >= 0; pos-- )
					if ( stack[ pos ] == tagName )
						break;
			
			if ( pos >= 0 ) {
				// Close all the open elements, up the stack
				for ( var i = stack.length - 1; i >= pos; i-- )
					if ( handler.end )
						handler.end( stack[ i ] );
				
				// Remove the open elements from the stack
				stack.length = pos;
			}
		}
	};
	
	this.HTMLtoXML = function( html ) {
		var results = "";
		
		HTMLParser(html, {
			start: function( tag, attrs, unary ) {
				results += "<" + tag;
		
				for ( var i = 0; i < attrs.length; i++ )
					results += " " + attrs[i].name + '="' + attrs[i].escaped + '"';
		
				results += (unary ? "/" : "") + ">";
			},
			end: function( tag ) {
				results += "</" + tag + ">";
			},
			chars: function( text ) {
				results += text;
			},
			comment: function( text ) {
				results += "<!--" + text + "-->";
			}
		});
		
		return results;
	};
	
	this.HTMLtoDOM = function( html, doc ) {
		// There can be only one of these elements
		var one = makeMap("html,head,body,title");
		
		// Enforce a structure for the document
		var structure = {
			link: "head",
			base: "head"
		};
	
		if ( !doc ) {
			if ( typeof DOMDocument != "undefined" )
				doc = new DOMDocument();
			else if ( typeof document != "undefined" && document.implementation && document.implementation.createDocument )
				doc = document.implementation.createDocument("", "", null);
			else if ( typeof ActiveX != "undefined" )
				doc = new ActiveXObject("Msxml.DOMDocument");
			
		} else
			doc = doc.ownerDocument ||
				doc.getOwnerDocument && doc.getOwnerDocument() ||
				doc;
		
		var elems = [],
			documentElement = doc.documentElement ||
				doc.getDocumentElement && doc.getDocumentElement();
				
		// If we're dealing with an empty document then we
		// need to pre-populate it with the HTML document structure
		if ( !documentElement && doc.createElement ) (function(){
			var html = doc.createElement("html");
			var head = doc.createElement("head");
			head.appendChild( doc.createElement("title") );
			html.appendChild( head );
			html.appendChild( doc.createElement("body") );
			doc.appendChild( html );
		})();
		
		// Find all the unique elements
		if ( doc.getElementsByTagName )
			for ( var i in one )
				one[ i ] = doc.getElementsByTagName( i )[0];
		
		// If we're working with a document, inject contents into
		// the body element
		var curParentNode = one.body;
		
		HTMLParser( html, {
			start: function( tagName, attrs, unary ) {
				// If it's a pre-built element, then we can ignore
				// its construction
				if ( one[ tagName ] ) {
					curParentNode = one[ tagName ];
					return;
				}
			
				var elem = doc.createElement( tagName );
				
				for ( var attr in attrs )
					elem.setAttribute( attrs[ attr ].name, attrs[ attr ].value );
				
				if ( structure[ tagName ] && typeof one[ structure[ tagName ] ] != "boolean" )
					one[ structure[ tagName ] ].appendChild( elem );
				
				else if ( curParentNode && curParentNode.appendChild )
					curParentNode.appendChild( elem );
					
				if ( !unary ) {
					elems.push( elem );
					curParentNode = elem;
				}
			},
			end: function( tag ) {
				elems.length -= 1;
				
				// Init the new parentNode
				curParentNode = elems[ elems.length - 1 ];
			},
			chars: function( text ) {
				curParentNode.appendChild( doc.createTextNode( text ) );
			},
			comment: function( text ) {
				// create comment node
			}
		});
		
		return doc;
	};

	function makeMap(str){
		var obj = {}, items = str.split(",");
		for ( var i = 0; i < items.length; i++ )
			obj[ items[i] ] = true;
		return obj;
	}
})();


(function() {
    var Dom = YAHOO.util.Dom,
        Event = YAHOO.util.Event,
        Lang = YAHOO.lang
        ;
    
    YAHOO.widget.CodeEditor = function (id, cfg) {
        // TODO: Make a cfg for off by default
        this.editorState = "on";

        // Disable Editor configs that don't apply
        cfg["animate"] = false;
        cfg["dompath"] = false;
        cfg["focusAtStart"] = false;

        // Default toolbar is different
        cfg["toolbar"] = cfg["toolbar"] || {
            titlebar : "Code Editor",
            buttons : []
        };

        YAHOO.widget.CodeEditor.superclass.constructor.call(this, id, cfg);

        // Allow us to have no buttons
        // This will be fixed in a future version of YUI Editor
        YAHOO.widget.Toolbar.prototype.disableAllButtons
        = function () {
            if (!this._buttonList) {
                this._buttonList = [];
            }
            if (this.get('disabled')) {
                return false;
            }
            var len = this._buttonList.length;
            for (var i = 0; i < len; i++) {
                this.disableButton(this._buttonList[i]);
            }
        };
        // End allow us to have no buttons

        this.on('editorContentLoaded', function() {
            // Add the code stylesheet
            var link = this._getDoc().createElement('link');
            link.rel = "stylesheet";
            link.type = "text/css";
            link.href = this.get('css_url');
            this._getDoc().getElementsByTagName('head')[0].appendChild(link);
            // Highlight the initial value
            if ( this.getEditorText() != this.old_text ) {
                Lang.later(10, this, function () { this.highlight(true) } );
                if ( this.status ) {
                    Lang.later(100, this, this._writeStatus);
                }
                this.old_text = this.getEditorText();
            }
            // Setup resize
            if ( this.status ) {
                this._setupResize();
            }
        }, this, true);

        this.on('editorKeyUp', function(ev) {
            // Highlight only if content has changed
            if ( this.getEditorText() != this.old_text ) {
                Lang.later(10, this, this.highlight);
                if ( this.status ) {
                    Lang.later(100, this, this._writeStatus);
                }
                this.old_text = this.getEditorText();
            }
        }, this, true);
        

        //Borrowed this from CodePress: http://codepress.sourceforge.net
        this.cc = '\u2009'; // carret char
        // TODO: Make this configurable based on a syntax definition
        this.keywords = [
            { code: /(&lt;DOCTYPE.*?--&gt.)/g, tag: '<ins>$1</ins>' }, // comments
            { code: /(&lt;[^!]*?&gt;)/g, tag: '<b>$1</b>'	}, // all tags
            { code: /(&lt;!--.*?--&gt.)/g, tag: '<ins>$1</ins>' }, // comments
            { code: /\b(YAHOO|widget|util|Dom|Event|lang)\b/g, tag: '<cite>$1</cite>' }, // reserved words
            { code: /\b(break|continue|do|for|new|this|void|case|default|else|function|return|typeof|while|if|label|switch|var|with|catch|boolean|int|try|false|throws|null|true|goto)\b/g, tag: '<b>$1</b>' }, // reserved words
            { code: /\"(.*?)(\"|<br>|<\/P>)/gi, tag: '<s>"$1$2</s>' }, // strings double quote
            { code: /\'(.*?)(\'|<br>|<\/P>)/gi, tag: '<s>\'$1$2</s>' }, // strings single quote
            { code: /\b(alert|isNaN|parent|Array|parseFloat|parseInt|blur|clearTimeout|prompt|prototype|close|confirm|length|Date|location|Math|document|element|name|self|elements|setTimeout|navigator|status|String|escape|Number|submit|eval|Object|event|onblur|focus|onerror|onfocus|onclick|top|onload|toString|onunload|unescape|open|valueOf|window|onmouseover|innerHTML)\b/g, tag: '<u>$1</u>' }, // special words
            { code: /([^:]|^)\/\/(.*?)(<br|<\/P)/gi, tag: '$1<i>//$2</i>$3' }, // comments //
            { code: /\/\*(.*?)\*\//g, tag: '<i>/*$1*/</i>' } // comments / * */
        ];
        //End Borrowed Content
        

        if ( cfg["toggleButton"] ) {
            var editor  = this;

            // Add toggle button
            var button  = document.createElement("input");
            
            button.type         = "button";
            button.value        = "Toggle Editor";

            Event.addListener( button, "click", function () {
                if ( editor.editorState == "off" ) {
                    editor.editorState = "on";
                    var fc = editor.get('element').previousSibling,
                        el = editor.get('element');

                    Dom.setStyle(fc, 'position', 'static');
                    Dom.setStyle(fc, 'top', '0');
                    Dom.setStyle(fc, 'left', '0');
                    Dom.setStyle(el, 'visibility', 'hidden');
                    Dom.setStyle(el, 'top', '-9999px');
                    Dom.setStyle(el, 'left', '-9999px');
                    Dom.setStyle(el, 'position', 'absolute');
                    editor.get('element_cont').addClass('yui-editor-container');
                    YAHOO.log('Reset designMode on the Editor', 'info', 'example');
                    editor._setDesignMode('on');
                    YAHOO.log('Inject the HTML from the textarea into the editor', 'info', 'example');
                    
                    // Escape HTML
                    var div = document.createElement("div");
                    var text =  editor.get('textarea').value;
                    // IE truncates whitespace internally, so go line by line
                    var lines   = text.split(/\n/);
                    for ( var i = 0; i < lines.length; i++ ) {
                        var line = lines[i];
                        YAHOO.log( i + ": " + line, "info", "CodeEditor" );
                        div.appendChild( document.createTextNode( line ) );
                        div.appendChild( document.createElement( "br" ) );
                    }
                    var html = div.innerHTML;
                    // We have <br>, not \n
                    html = html.replace(/\n/g,"");

                    YAHOO.log( html, "info", "CodeEditor" );
                    editor.setEditorHTML(html);
                    editor.highlight();
                }
                else {
                    editor.editorState = "off";
                    editor.saveHTML();
                    var fc = editor.get('element').previousSibling,
                        el = editor.get('element');

                    Dom.setStyle(fc, 'position', 'absolute');
                    Dom.setStyle(fc, 'top', '-9999px');
                    Dom.setStyle(fc, 'left', '-9999px');
                    editor.get('element_cont').removeClass('yui-editor-container');
                    Dom.setStyle(el, 'visibility', 'visible');
                    Dom.setStyle(el, 'top', '');
                    Dom.setStyle(el, 'left', '');
                    Dom.setStyle(el, 'position', 'static');

                    // Unescape HTML
                    var div = document.createElement("div");
                    var text = editor.getEditorText();
                    // IE truncates all whitespace internally, so add HTML for it
                    if ( editor.browser.ie && editor.browser.ie <= 8 ) {
                        text = text.replace(/\n/g, "&nbsp;<br>");
                        text = text.replace(/\t/g, "&nbsp;&nbsp;&nbsp;&nbsp;");
                    }
                    div.innerHTML = text;
                    editor.get('element').value = "";
                    for ( var i = 0; i < div.childNodes.length; i++ ) {
                        if ( div.childNodes[i].nodeName == "#text" ) {
                            editor.get('element').value = editor.get('element').value 
                                                        + div.childNodes[i].nodeValue
                                                        + "\n"
                                                        ;
                        }
                    }
                    YAHOO.log( editor.getEditorText(), "info", "CodeEditor" );
                    YAHOO.log( div.childNodes[0].nodeValue, "info", "CodeEditor" );
                    YAHOO.log( editor.get('element').value, "info", "CodeEditor" );
                }
            } );
            
            // Put it right after the text area
            var ta = document.getElementById( id );
            if ( ta.nextSibling ) {
                ta.parentNode.insertBefore( button, ta.nextSibling );
            }
            else {
                ta.parentNode.appendChild( button );
            }
        }
    };
    Lang.extend( YAHOO.widget.CodeEditor, YAHOO.widget.SimpleEditor, {
        /**
        * @property _defaultCSS
        * @description The default CSS used in the config for 'css'. This way you can add to the config like this: { css: YAHOO.widget.SimpleEditor.prototype._defaultCSS + 'ADD MYY CSS HERE' }
        * @type String
        */
        _defaultCSS: 'html { height: 95%; } body { background-color: #fff; font:13px/1.22 arial,helvetica,clean,sans-serif;*font-size:small;*font:x-small; } a, a:visited, a:hover { color: blue !important; text-decoration: underline !important; cursor: text !important; } .warning-localfile { border-bottom: 1px dashed red !important; } .yui-busy { cursor: wait !important; } img.selected { border: 2px dotted #808080; } img { cursor: pointer !important; border: none; } body.ptags.webkit div { margin: 11px 0; }'
    });
    
    /**
    * @private
    * @method _cleanIncomingHTML
    * @description Clean up the HTML that the textarea starts with
    */
    YAHOO.widget.CodeEditor.prototype._cleanIncomingHTML = function(str) {
        // Workaround for bug in Lang.substitute
        str = str.replace(/{/gi, 'RIGHT_BRACKET');
        str = str.replace(/}/gi, 'LEFT_BRACKET');

        // &nbsp; before <br> for IE8- so lines show up correctly
        if ( this.browser.ie && this.browser.ie <= 8 ) {
            str = str.replace(/\r?\n/g, "&nbsp;<br>");
        }

        // Fix tabs into softtabs
        str = str.replace(/\t/g, '&nbsp;&nbsp;&nbsp;&nbsp;'); // TODO: Make softtabs configurable

        return str;
    };

    /* Override to fix problem with the rest of what the normal _handleFormSubmit does 
     * ( it doesn't properly click the correct submit button )
     */
    YAHOO.widget.CodeEditor.prototype._handleFormSubmit = function () {
        if ( this.editorState == "on" ) {
            this.saveHTML();
        }
        return;
    };
    /* End override to fix problem */
   
    /**
    * @private
    * @method _writeStatus
    * @description Write the number of Characters and Lines to the status line
    */
    YAHOO.widget.CodeEditor.prototype._writeStatus = function () {
        if ( this.status ) {
            var text = this.getEditorText();
            this.status.innerHTML
                = 'C: ' + text.length
                + ' L: ' + text.split(/\r?\n/).length
                ;
        }
    };

    /**
    * @private
    * @method _setupResize
    * @description Creates the Resize instance and binds its events.
    */
    YAHOO.widget.CodeEditor.prototype._setupResize 
    = function() {
        if (!YAHOO.util.DD || !YAHOO.util.Resize) { return false; }
        if (this.get('resize')) {
            var config = {};
            Lang.augmentObject(config, this._resizeConfig); //Break the config reference
            this.resize = new YAHOO.util.Resize(this.get('element_cont').get('element'), config);
            this.resize.on('resize', function(args) {
                var anim = this.get('animate');
                this.set('animate', false);
                this.set('width', args.width + 'px');
                var h = args.height,
                    th = (this.toolbar.get('element').clientHeight + 2),
                    dh = 0;
                if (this.status) {
                    dh = (this.status.clientHeight + 1); //It has a 1px top border..
                }
                var newH = (h - th - dh);
                this.set('height', newH + 'px');
                this.get('element_cont').setStyle('height', '');
                this.set('animate', anim);
            }, this, true);
        }
    };
    
    /* 
     * @method cleanHTML
     * @description Reduce the HTML in the editor to plain text to be put back in the
     *      textarea. Called by saveHTML()
     */
    YAHOO.widget.CodeEditor.prototype.cleanHTML = function (html) {
        if (!html) { 
            html = this.getEditorHTML();
        }

        // Handle special-case HTML
        html = html.replace(/(&nbsp;){4}/g,"\t");   // TODO: make softtabs configurable
        html = html.replace(/&nbsp;/g," ");
        // Remove spaces at end of lines
        html = html.replace(/ ?<br>/gi,'\n');

        // Parse the text out of the remaining HTML
        text = "";
        HTMLParser( html, {
            chars   : function (t) { text += t }
        } );
        
        // If, after all this, we are left with only a \n, user didn't add anything
        //      (editor adds a <br> if it starts blank)
        if ( text == "\n" ) {
            text = "";
        }

        return text;
    };

    /* 
     * @method focusCaret
     * @description I don't actually know what this does, it was like this when I got here
     */
    YAHOO.widget.CodeEditor.prototype.focusCaret = function() {
        if (this.browser.gecko) {
            if (this._getWindow().find(this.cc)) {
                this._getSelection().getRangeAt(0).deleteContents();
            }
        } else if (this.browser.webkit || this.browser.ie || this.browser.opera) {
            var cur = this._getDoc().getElementById('cur');
            if ( cur ) {
                cur.id = '';
                cur.innerHTML = '';
                this._selectNode(cur);
            }
        }
    };

    /**
    * @method getEditorText
    * @description Get the text inside the editor, removing any HTML used for highlighting
    */
    YAHOO.widget.CodeEditor.prototype.getEditorText
    = function () {
        var html = this.getEditorHTML();
        var text = this.cleanHTML( html );
        return text;
    };

    /**
    * @method highlight
    * @description Apply the syntax highlighting to the content of the editor
    * @param {Boolean} focus If true, editor currently has focus
    */
    YAHOO.widget.CodeEditor.prototype.highlight = function(focus) {

        // Opera support is not working yet
        if ( this.browser.opera ) {
            return;
        }
        // Firefox < 3 support is not working yet
        if ( this.browser.gecko && this.browser.gecko <= 1.8 ) {
            return;
        }

        // Keep track of where the cursor is right now
        if (!focus) {
            if (this.browser.gecko) {
                this._getSelection().getRangeAt(0).insertNode(this._getDoc().createTextNode(this.cc));
            } else if (this.browser.webkit || this.browser.ie || this.browser.opera) {
                try {
                    this.execCommand('inserthtml', this.cc);
                }
                catch (e) {}
            }
        }

        // Remove existing highlighting
        var html = this.getEditorText();

        // Fix line breaks
        html = html.replace( /\t/g, "&nbsp;&nbsp;&nbsp;&nbsp;" );
        if ( this.browser.ie ) {
            html = html.replace( /\n/g, "&nbsp;<br>" );
        }
        else {
            html = html.replace( /\n/g, "<br>");
        }

        // Apply new highlighting
        for (var i = 0; i < this.keywords.length; i++) {
            html = html.replace(this.keywords[i].code, this.keywords[i].tag);
        }

        // Replace cursor
        if ( !this.browser.gecko ) {
            html = html.replace(this.cc, '<span id="cur">|</span>');
        }

        this._getDoc().body.innerHTML = html;
        if (!focus) {
            this.focusCaret();
        }
    };

    /**
    * @method initAttributes
    * @description Initializes all of the configuration attributes used to create 
    * the editor.
    * @param {Object} attr Object literal specifying a set of 
    * configuration attributes used to create the editor.
    */
    YAHOO.widget.CodeEditor.prototype.initAttributes 
    = function(attr) {
        YAHOO.widget.CodeEditor.superclass.initAttributes.call(this, attr);
        var self = this;
        /**
        * @attribute status 
        * @description Toggle the display of a status line below the editor
        * @default false
        * @type Boolean
        */            
        this.setAttributeConfig('status', {
            value: attr.status || false,
            method: function(status) {
                if (status && !this.status) {
                    this.status = document.createElement('DIV');
                    this.status.id = this.get('id') + '_status';
                    Dom.addClass(this.status, 'dompath'); // Piggy-back on Editor's dompath
                    this.get('element_cont').get('firstChild').appendChild(this.status);
                    if (this.get('iframe')) {
                        this._writeStatus();
                    }
                } else if (!status && this.status) {
                    this.status.parentNode.removeChild(this.status);
                    this.status = null;
                }
            }
        });
        /**
        * @attribute css_url 
        * @description The URL to the CSS file for the inside of the code editor
        * @default 'code.css'
        * @type String
        */            
        this.setAttributeConfig('css_url', {
            value: attr.css_url || 'code.css'
        } );
    };

})();

