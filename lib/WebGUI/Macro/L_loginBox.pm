package WebGUI::Macro::L_loginBox;

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
use WebGUI::Form;
use WebGUI::International;
use WebGUI::Macro::Backslash_pageUrl;
use WebGUI::Session;

#-------------------------------------------------------------------
sub _replacement {
	my ($temp);
        $temp = '<div class="loginBox">';
        if ($session{var}{sessionId}) {
		$temp .= WebGUI::International::get(48);
                $temp .= ' <a href="'.$session{page}{url}.'?op=displayAccount">'.$session{user}{username}.'</a>.';
                $temp .= WebGUI::International::get(49);
                $temp = WebGUI::Macro::Backslash_pageUrl::process($temp);
        } else {
        	$temp .= '<form method="post" action="'.$session{page}{url}.'"> ';
                $temp .= WebGUI::Form::hidden("op","login").'<span class="formSubtext">';
                $temp .= WebGUI::International::get(50);
                $temp .= '<br></span>';
                $temp .= WebGUI::Form::text("username",12,30).'<span class="formSubtext"><br>';
                $temp .= WebGUI::International::get(51);
                $temp .= '<br></span>';
                $temp .= WebGUI::Form::password("identifier",12,30).'<span class="formSubtext"><br></span>';
                $temp .= WebGUI::Form::submit(WebGUI::International::get(52));
                $temp .= '</form>';
                $temp .= '<a href="'.$session{page}{url}.'?op=createAccount">Click here to register.</a>';
        }
        $temp .= '</div>';
	return $temp;
}

#-------------------------------------------------------------------
sub process {
	my ($output, $temp);
	$output = $_[0];
        $output =~ s/\^L\;/_replacement()/ge;
	return $output;
}

1;

