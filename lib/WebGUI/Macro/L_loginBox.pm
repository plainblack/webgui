package WebGUI::Macro::L_loginBox;

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
use WebGUI::HTMLForm;
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
	my ($temp,$boxSize,@param,$text,$f);
	@param = WebGUI::Macro::getParams($_[0]);
        $temp = '<div class="loginBox">';
        if ($session{user}{userId} <> 1) {
		$text = $param[1];
		if (not defined $text){
			$temp .= WebGUI::International::get(48);
                	$temp .= ' <a href="'.WebGUI::URL::page('op=displayAccount').
				'">'.$session{user}{username}.'</a>. ';
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
		$f = WebGUI::HTMLForm->new(1);
		$f->hidden("op","login");
		$f->raw('<span class="formSubtext">'.WebGUI::International::get(50).'<br></span>');
                $f->text("username",'','','','','',$boxSize);
		$f->raw('<span class="formSubtext"><br>'.WebGUI::International::get(51).'<br></span>');
                $f->password("identifier",'','','','','',$boxSize);
		$f->raw('<span class="formSubtext"><br></span>');
		$f->submit(WebGUI::International::get(52));
		$temp .= $f->print;
		if ($session{setting}{anonymousRegistration}) {
                	$temp .= '<a href="'.WebGUI::URL::page('op=createAccount').'">'.WebGUI::International::get(407).'</a>';
		}
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

