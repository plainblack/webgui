package WebGUI::Macro::LoginToggle;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::International;
use WebGUI::Session;
use WebGUI::Asset::Template;
use WebGUI::URL;

#-------------------------------------------------------------------
sub process {
        my @param = @_;
        my $login = $param[0] || WebGUI::International::get(716,'Macro_LoginToggle');
        my $logout = $param[1] || WebGUI::International::get(717,'Macro_LoginToggle');
	my %var;
        if ($session{user}{userId} eq '1') {
		return WebGUI::URL::page("op=auth;method=init") if ($param[0] eq "linkonly");
        	$var{'toggle.url'} = WebGUI::URL::page('op=auth;method=init');
               	$var{'toggle.text'} = $login;
        } else {
		return WebGUI::URL::page("op=auth;method=logout") if ($param[0] eq "linkonly");
                $var{'toggle.url'} = WebGUI::URL::page('op=auth;method=logout');
               	$var{'toggle.text'} = $logout;
        }
	if ($param[2]) {
		return  WebGUI::Asset::Template->newByUrl($param[2])->process(\%var);
	} else {
		return  WebGUI::Asset::Template->new("PBtmpl0000000000000043")->process(\%var);
	}
}


1;

