package WebGUI::Macro::a_account;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::Template;
use WebGUI::URL;

#-------------------------------------------------------------------
sub process {
       my %var;
         my  @param = WebGUI::Macro::getParams($_[0]);
	return WebGUI::URL::page("op=displayAccount") if ($param[0] eq "linkonly");
       $var{'account.url'} = WebGUI::URL::page('op=displayAccount');
       $var{'account.text'} = $param[0] || WebGUI::International::get(46);
         return WebGUI::Template::process(WebGUI::Template::getIdByName($param[1],"Macro/a_account"),"Macro/a_account",\%var);
}


1;


