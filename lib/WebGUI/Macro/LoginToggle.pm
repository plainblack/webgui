package WebGUI::Macro::LoginToggle;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::Template;
use WebGUI::URL;

#-------------------------------------------------------------------
sub process {
        my @param = WebGUI::Macro::getParams($_[0]);
        my $login = $param[0] || WebGUI::International::get(716);
        my $logout = $param[1] || WebGUI::International::get(717);
	my %var;
        if ($session{user}{userId} == 1) {
		return WebGUI::URL::page("op=displayLogin") if ($param[0] eq "linkonly");
        	$var{'toggle.url'} = WebGUI::URL::page('op=displayLogin');
               	$var{'toggle.text'} = $login;
        } else {
		return WebGUI::URL::page("op=logout") if ($param[0] eq "linkonly");
                $var{'toggle.url'} = WebGUI::URL::page('op=logout');
               	$var{'toggle.text'} = $logout;
        }
        return  WebGUI::Template::process(WebGUI::Template::getIdByName($param[3],"Macro/LoginToggle"), "Macro/LoginToggle", \%var);
}


1;

