package WebGUI::Macro::Question_search;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
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
	my ($f);
	$f = WebGUI::HTMLForm->new(1);
        $f->hidden("op","search");
        $f->text("atLeastOne",'',$session{form}{atLeastOne});
        $f->submit(WebGUI::International::get(364));
	return $f->print;
}


1;
