package WebGUI::Macro::Question_search;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::HTMLForm;
use WebGUI::International;
use WebGUI::Session;
use WebGUI::URL;

#-------------------------------------------------------------------
sub process {
	my ($output, $temp, $f);
	$output = $_[0];
	$f = WebGUI::HTMLForm->new(1);
        $f->hidden("op","search");
        $f->text("atLeastOne",'',$session{form}{atLeastOne});
        $f->submit(WebGUI::International::get(364));
	$temp = $f->print;
        $output =~ s/\^\?\;/$temp/g;
	return $output;
}



1;
