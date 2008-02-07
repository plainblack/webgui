package WebGUI::Macro::Widget;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;

#-------------------------------------------------------------------
sub process {

    # get passed parameters
	my $session         = shift;
    my $assetId         = shift;
    my $width           = shift || 600;
    my $height          = shift || 400;
    my $templateId      = shift || 'none';

    # Get location for CSS and JS files
    my $conf            = $session->config;
    my $extras          = $conf->get("extrasURL");

    # add CSS and JS to the page
	my $style           = $session->style;
	$style->setLink($extras."/yui/build/container/assets/container.css",{
                        rel=>"stylesheet",
                        type=>"text/css",
                    }
    );
	$style->setScript($extras."/wgwidget.js",{ 
                          type=>"text/javascript" 
                      }
    );
	$style->setScript($extras."/yui/build/yahoo-dom-event/yahoo-dom-event.js",{ 
                          type=>"text/javascript" 
                      }
    );
	$style->setScript($extras."/yui/build/container/container-min.js",{ 
                          type=>"text/javascript" 
                      }
    );

    # construct the absolute URL
    my $asset           = WebGUI::Asset->new($session, $assetId);
    my $fullUrl         = "http://" . $conf->get("sitename")->[0] . $asset->getUrl;

    # construct path to wgwidget.js
    my $wgWidgetPath = 'http://' . $conf->get('sitename')->[0] . $extras . '/wgwidget.js';

    # and yahoo-dom-event.js
    my $yahooDomJsPath = 'http://' . $conf->get('sitename')->[0] . $extras . '/yui/build/yahoo-dom-event/yahoo-dom-event.js';
    
    my $imgSrc = $extras . '/gear.png';

    my $output          = <<"EOHTML";
<script>

var codeGeneratorButton;

var handleButtonShow = function() {
    codeGeneratorButton.show();
    var tag = document.getElementById('jsWidgetCode');
    tag.focus();
    tag.select();
}

function initButton() {

        var jsCode = ""; 
        jsCode += "&lt;script type='text/javascript' src='$wgWidgetPath'&gt; &lt;/script&gt;"; 
        jsCode += "&lt;script type='text/javascript'&gt;";
        jsCode += "document.write(WebGUI.widgetBox.widget('$fullUrl', '$assetId', $width, $height, '$templateId')); &lt;/script&gt;";

        // Instantiate the Dialog
        codeGeneratorButton = new YAHOO.widget.SimpleDialog("codeGeneratorButton", {
            width: "500px",
            height: "200px",
            fixedcenter: true,
            visible: false,
            draggable: true,
            close: true,
            text: "<textarea id='jsWidgetCode' rows='5' cols='50'>" + jsCode + "</textarea>",
            icon: YAHOO.widget.SimpleDialog.ICON_INFO,
            constraintoviewport: true,
            modal: true,
            zIndex: 9999,
            buttons: [{text: "Dismiss", handler:dismissButton, isDefault: true}]
            }
        );
        codeGeneratorButton.setHeader("Widget code");

        // Render the Dialog
        codeGeneratorButton.render(document.body);

        YAHOO.util.Event.addListener("show", "click", handleButtonShow, codeGeneratorButton, true);
}

var dismissButton = function () {
    this.hide();
}

YAHOO.util.Event.addListener(window, "load", initButton);

</script>


<!-- <button id="show">Get code for this content</button>  -->
<a href="#" id="show"><img src="$imgSrc" /></a>
EOHTML

	return $output;
}

1;
