package WebGUI::Macro::L;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Form;
use WebGUI::Session;

#-------------------------------------------------------------------
sub process {
	my ($output, $temp);
	$output = $_[0];
  #---login box---
	if ($output =~ /\^L/) {
		$temp = '<div class="loginBox">';
        	if ($session{var}{sessionId}) {
                	$temp .= 'Hello '.$session{user}{username}.'. Click <a href="'.$session{page}{url}.'?op=logout">here</a> to log out.';
        	} else {
                	$temp .= '<form method="post" action="'.$session{page}{url}.'"> ';
                	$temp .= WebGUI::Form::hidden("op","login").'<span class="formSubtext">Username:<br></span>';
                	$temp .= WebGUI::Form::text("username",12,30).'<span class="formSubtext"><br>Password:<br></span>';
			$temp .= WebGUI::Form::password("identifier",12,30).'<span class="formSubtext"><br></span>';
                	$temp .= WebGUI::Form::submit("login");
                	$temp .= '</form>';
        	}
        	$temp .= '</div>';
        	$output =~ s/\^L/$temp/g;
	}
	return $output;
}

1;

