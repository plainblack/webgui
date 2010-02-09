(function() {
    var Dom = YAHOO.util.Dom,
        Event = YAHOO.util.Event,
        Lang = YAHOO.lang
        ;
    
    YAHOO.widget.CodeEditor = function (id, cfg) {
        // Disable Editor configs that don't apply
        cfg["animate"] = false;
        cfg["dompath"] = false;

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

    };
    Lang.extend( YAHOO.widget.CodeEditor, YAHOO.widget.Editor, {
        /**
        * @property _defaultCSS
        * @description The default CSS used in the config for 'css'. This way you can add to the config like this: { css: YAHOO.widget.SimpleEditor.prototype._defaultCSS + 'ADD MYY CSS HERE' }
        * @type String
        */
        _defaultCSS: 'html { height: 95%; } body { background-color: #fff; font:13px/1.22 arial,helvetica,clean,sans-serif;*font-size:small;*font:x-small; } a, a:visited, a:hover { color: blue !important; text-decoration: underline !important; cursor: text !important; } .warning-localfile { border-bottom: 1px dashed red !important; } .yui-busy { cursor: wait !important; } img.selected { border: 2px dotted #808080; } img { cursor: pointer !important; border: none; } body.ptags.webkit div { margin: 11px 0; }'
    });
    
    YAHOO.widget.CodeEditor.prototype._cleanIncomingHTML = function(str) {
        // Workaround for bug in Lang.substitute
        str = str.replace(/{/gi, 'RIGHT_BRACKET');
        str = str.replace(/}/gi, 'LEFT_BRACKET');

        // &nbsp; before <br> for IE8 so lines show up correctly
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
        this.saveHTML();
        return;
    };
    /* End override to fix problem */
   
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
    
    YAHOO.widget.CodeEditor.prototype.cleanHTML = function (html) {
        if (!html) { 
            html = this.getEditorHTML();
        }
        html = html.replace(/(&nbsp;){4}/g,"\t");   // TODO: make softtabs configurable
        html = html.replace(/&nbsp;/g," ");
        // Remove spaces at end of lines
        html = html.replace(/\s ?<br>/gi,'\n');
        html = html.replace(/<[^>]+>/g,'');

        // If, after all this, we are left with only a \n, user didn't add anything
        //      (editor adds a <br> if it starts blank)
        if ( html == "\n" ) {
            html = "";
        }

        return html;
    };

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

    YAHOO.widget.CodeEditor.prototype.getEditorText
    = function () {
        return this.cleanHTML( this.getEditorHTML() );
    };

    YAHOO.widget.CodeEditor.prototype.highlight = function(focus) {

        // Opera support is not working yet
        if ( this.browser.opera ) {
            return;
        }
        // Firefox < 3 support is not working yet
        if ( this.browser.gecko && this.browser.gecko <= 1.8 ) {
            return;
        }

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
        var html = '';
        html = this._getDoc().body.innerHTML;
        //if (this.browser.opera) {
        //    html = html.replace(/<(?!span|\/span|br).*?>/gi,'');
        //} else
        if (this.browser.webkit) {
            //YAHOO.log('1: ' + html);
            html = html.replace(/<\/div>/ig, '');
            html = html.replace(/<br><div>/ig, '<br>');
            html = html.replace(/<div>/ig, '<br>');
            html = html.replace(/<br>/ig,'\n');
            html = html.replace(/<[^>]*>/g,'');
            html = html.replace(/\r?\n/g,'<br>');
            //YAHOO.log('2: ' + html);
        } else {
            if (this.browser.ie) {
                html = html.replace(/<SPAN><\/SPAN>/ig, '');
            }
            YAHOO.log(html);
            // &nbsp; before <br> for IE7
            html = html.replace(/(&nbsp;)?<br[^>]*>/gi,'$1\n');
            html = html.replace(/<\/div>/ig, '');
            html = html.replace(/<br><div>/ig, '<br>');
            html = html.replace(/<div>/ig, '<br>');
            html = html.replace(/<br>/ig,'\n');
            html = html.replace(/<[^>]*>/g,'');
            html = html.replace(/\r?\n/g,'<br>');
            // &nbsp; between <br> for IE6
            html = html.replace(/<br[^>]*><br[^>]*>/gi, '<br>$1&nbsp;<br>');
            YAHOO.log(html);
        }
        for (var i = 0; i < this.keywords.length; i++) {
            html = html.replace(this.keywords[i].code, this.keywords[i].tag);
        }
        YAHOO.log("AFTER HIGHLIGHT:" + html);
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

