package WebGUI::Style;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::CPHash;
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Template;

#-------------------------------------------------------------------
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
        $header = $session{setting}{docTypeDec}."\n".'<!-- WebGUI '.$WebGUI::VERSION.' --> <html> <head> <title>';
        $header .= $session{page}{title}.' - '.$session{setting}{companyName};
        $header .= '</title><link REL="icon" HREF="'.$session{config}{extras}.'/favicon.png" TYPE="image/png">'
                .$style{styleSheet}.$session{page}{metaTags};
        if ($session{var}{adminOn}) {
                # This "triple incantation" panders to the delicate tastes of various browsers for reliable cache suppression.
                $header .= '<META HTTP-EQUIV="Pragma" CONTENT="no-cache">';
                $header .= '<META HTTP-EQUIV="Cache-Control" CONTENT="no-cache, must-revalidate, max_age=0">';
                $header .= '<META HTTP-EQUIV="Expires" CONTENT="0">';
        }
        if ($session{page}{defaultMetaTags}) {
                $header .= '<meta http-equiv="Keywords" name="Keywords" content="'.$session{page}{title}
                        .', '.$session{setting}{companyName}.'">';
                $header .= '<meta http-equiv="Description" name="Description" content="'.$session{page}{synopsis}.'">';

        }
        $header .= '</head>'.$body[0];
        $footer = $body[1].' </html>';
        return $header.$_[0].$footer;
}





1;
