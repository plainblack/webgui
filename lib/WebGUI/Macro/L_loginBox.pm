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
use WebGUI::URL;

#-------------------------------------------------------------------
sub _createURL {
	return '<a href="'.WebGUI::URL::page("op=logout").'">'.$_[0].'</a>';
}

#-------------------------------------------------------------------
sub _replacement {
	my ($temp,$boxSize,@param,$text);
	@param = WebGUI::Macro::getParams($_[0]);
        $temp = '<div class="loginBox">';
        if ($session{var}{sessionId}) {
		$text = $param[1];
		if (not defined $text){
			$temp .= WebGUI::International::get(48);
                	$temp .= ' <a href="'.WebGUI::URL::page('op=displayAccount').
				'">'.$session{user}{username}.'</a>.';
                	$temp .= WebGUI::International::get(49);
                	$temp = WebGUI::Macro::Backslash_pageUrl::process($temp);
		} else {
			$text =~ s/%(.*?)%/_createURL($1)/ge;
	  		$temp .= WebGUI::Macro::Backslash_pageUrl::process($text);
		}
        } else {
		$boxSize = $param[0];
		if (not defined $boxSize) {
			$boxSize = 12;
		}
		if (index(lc($ENV{HTTP_USER_AGENT}),"msie") < 0) { 
	   		$boxSize = int($boxSize=$boxSize*2/3);	
		}
        	$temp .= '<form method="post" action="'.WebGUI::URL::page().'"> ';
                $temp .= WebGUI::Form::hidden("op","login").'<span class="formSubtext">';
                $temp .= WebGUI::International::get(50);
                $temp .= '<br></span>';
                $temp .= WebGUI::Form::text("username",$boxSize,30).'<span class="formSubtext"><br>';
                $temp .= WebGUI::International::get(51);
                $temp .= '<br></span>';
                $temp .= WebGUI::Form::password("identifier",$boxSize,30).'<span class="formSubtext"><br></span>';
                $temp .= WebGUI::Form::submit(WebGUI::International::get(52));
                $temp .= '</form>';
                $temp .= '<a href="'.WebGUI::URL::page('op=createAccount').'">'.WebGUI::International::get(407).'</a>';
        }
        $temp .= '</div>';
	return $temp;
}

#-------------------------------------------------------------------
sub process {
	my ($output, $temp);
	$output = $_[0];
	$output =~ s/\^L\((.*?)\)\;/_replacement($1)/ge;
        $output =~ s/\^L\;/_replacement()/ge;
	return $output;
}

1;

