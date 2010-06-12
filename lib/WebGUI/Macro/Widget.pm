package WebGUI::Macro::Widget;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Exception;
use WebGUI::Asset;
use WebGUI::Storage;

#-------------------------------------------------------------------

=head2 process 

=cut

sub process {

    # get passed parameters
    my $session         = shift;
    my $url             = shift;
    my $width           = shift || 600;
    my $height          = shift || 400;
    my $templateId      = shift || 'none';
    my $styleTemplateId = shift || 'none';

    # Get location for CSS and JS files
    my $conf            = $session->config;
    my $extras          = $session->url->make_urlmap_work($conf->get("extrasURL"));

    # add CSS and JS to the page
    my $style           = $session->style;
    $style->setLink($extras."/yui/build/container/assets/container.css",{
                        rel=>"stylesheet",
                        type=>"text/css",
                    }
    );
    
    # and the JS
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

    # construct the absolute URL and get the asset ID
    my $asset           = eval { WebGUI::Asset->newByUrl($session, $url); };
    if ( Exception::Class->caught() ) {
        return "Widget: Could not find asset with URL '$url'";
    }
    my $assetId         = $asset->getId;

    # ... and the full URL. If there's an exportWidget scratch variable, we're
    # exporting, and we need to use that URL.
    my($fullUrl, $wgWidgetPath);
    my $scratch         = $session->scratch;
    my $exportUrl       = $scratch->get('exportUrl');
    if($exportUrl) {
        my $storage         = WebGUI::Storage->get($session, $assetId);
        $fullUrl            = $exportUrl . $storage->getUrl("$assetId.html");
        $wgWidgetPath       = $exportUrl . $extras . '/wgwidget.js';
        $scratch->delete('exportUrl');
        my $viewContent    = $asset->view;
        if ($styleTemplateId ne '' && $styleTemplateId ne 'none') {
            $viewContent = $session->style->process($viewContent,$styleTemplateId);
        }
        my ($headTags, $bodyContent) = WebGUI::HTML::splitHeadBody($viewContent);

        WebGUI::Macro::process($session, \$viewContent);
        my $containerCss    = $extras . '/yui/build/container/assets/container.css';
        my $containerJs     = $extras . '/yui/build/container/container-min.js';
        my $yahooDomJs      = $extras . '/yui/build/yahoo-dom-event/yahoo-dom-event.js';
        my $wgWidgetJs      = $extras . '/wgwidget.js';
        my $wgWidgetPath    = $extras . '/wgwidget.js';

        my $fullHtmlOutput          = <<OUTPUT;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title></title>
        <link rel="stylesheet" type="text/css" href="$containerCss" />
        <script type='text/javascript' src='$yahooDomJs'></script>
        <script type='text/javascript' src='$containerJs'></script>
        <script type='text/javascript' src='$wgWidgetJs'></script>
        <script type='text/javascript'>
            function setupPage() {
                WebGUI.widgetBox.retargetLinksAndForms();
                WebGUI.widgetBox.initButton( { 'wgWidgetPath' : '$wgWidgetPath', 'fullUrl' : '$fullUrl', 'assetId' : '$assetId', 'width' : $width, 'height' : $height, 'templateId' : '$templateId', 'styleTemplateId' : $styleTemplateId } );
            }
            YAHOO.util.Event.addListener(window, 'load', setupPage);
        </script>
        $headTags
    </head>
    <body id="widget$assetId">
        $bodyContent
    </body>
</html>
OUTPUT
        $storage->addFileFromScalar("$assetId.html", $fullHtmlOutput);
    }
    else {
        $fullUrl            = "http://" . $conf->get("sitename")->[0] . $asset->getUrl;
        $wgWidgetPath       = 'http://' . $conf->get('sitename')->[0] . $extras . '/wgwidget.js';
    }

    # get the gear icon
    my $imgSrc          = $extras . '/gear.png';

    my $output          = <<EOHTML;
<a href="#$assetId" id="show$assetId" name="show$assetId"><img src="$imgSrc" /></a>
<script type="text/javascript">
YAHOO.util.Event.addListener(window, 'load', WebGUI.widgetBox.initButton, { 'wgWidgetPath' : '$wgWidgetPath', 'fullUrl' : '$fullUrl', 'assetId' : '$assetId', 'width' : $width, 'height' : $height, 'templateId' : '$templateId', 'styleTemplateId' : '$styleTemplateId' } );
</script>
EOHTML

    return $output;
}

1;
