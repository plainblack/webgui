package WebGUI::Style;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2003 Plain Black LLC.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut


use strict;
use Tie::CPHash;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Template;


=head1 NAME

Package WebGUI::Style

=head1 DESCRIPTION

This package contains utility methods for WebGUI's style system.

=head1 SYNOPSIS

 use WebGUI::Style;
 $style = WebGUI::Style::get();

=head1 METHODS

These subroutines are available from this package:

=cut


#-------------------------------------------------------------------

=head2 get ( )

Returns a style based upon the current WebGUI session information.

=cut

sub get {
        my ($header, $footer, %style, $styleId, @body);
        tie %style, 'Tie::CPHash';
        if ($session{form}{makePrintable}) {
                $styleId = $session{form}{style} || 3;
        } else {
                $styleId = $session{page}{styleId} || 2;
        }
        %style = WebGUI::SQL->quickHash("select * from style where styleId=$styleId");
        @body = split(/\^\-\;/,$style{body});
        my $type = lc($session{setting}{siteicon});
        $type =~ s/.*\.(.*?)$/$1/;
        $header = $session{setting}{docTypeDec}.'
        <!-- WebGUI '.$WebGUI::VERSION.' -->
        <html> <head>
                <title>'.$session{page}{title}.' - '.$session{setting}{companyName}.'</title>
        ';
        $header .= $style{styleSheet}.$session{page}{metaTags};
	$header .= '
		<script>
			function getWebguiProperty (propName) {
				var props = new Array();
				props["extrasURL"] = "'.$session{config}{extrasURL}.'";
				props["pageURL"] = "'.$session{page}{url}.'";
				return props[propName];
			}
		</script>
		';
        if ($session{var}{adminOn}) {
                # This "triple incantation" panders to the delicate tastes of various browsers for reliable cache suppression.
                $header .= '<meta http-equiv="Pragma" content="no-cache" />';
                $header .= '<meta http-equiv="Cache-Control" content="no-cache, must-revalidate, max_age=0" />';
                $header .= '<meta http-equiv="Expires" content="0" />';
        }
        if ($session{page}{defaultMetaTags}) {
                $header .= '<meta http-equiv="Keywords" name="Keywords" content="'.$session{page}{title}
                        .', '.$session{setting}{companyName}.'" />';
                if ($session{page}{synopsis}) {
                        $header .= '<meta http-equiv="Description" name="Description" content="'.$session{page}{synopsis}.'" />';
                }
        }
        $header .= '
                <meta http-equiv="Content-Type"
                content="text/html; charset='.($session{header}{charset}||$session{language}{characterSet}||"ISO-8859-1").'" />
                <link rel="icon" href="'.$session{setting}{siteicon}.'" type="image/'.$type.'" />
                <link rel="SHORTCUT ICON" href="'.$session{setting}{favicon}.'" />
        </head>
        ';
        $header .= $body[0];
        $footer = $body[1].' </html>';
        return $header.$_[0].$footer;
}




1;

