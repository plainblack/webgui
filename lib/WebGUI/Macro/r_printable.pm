package WebGUI::Macro::r_printable;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::International;
use WebGUI::Session;
use WebGUI::Asset::Template;
use WebGUI::URL;
use WebGUI::Utility;

#-------------------------------------------------------------------
sub process {
        my ($temp, @param, $styleId);
        @param = @_;
	my $append = 'op=makePrintable';
	if ($session{env}{REQUEST_URI} =~ /op\=/) {
		$append = 'op2='.WebGUI::URL::escape($append);
	}
	$temp = WebGUI::URL::gateway($session{wguri},$append);
        $temp =~ s/\/\//\//;
        $temp = WebGUI::URL::append($temp,$session{env}{QUERY_STRING});
	if ($param[1] ne "") {
		$temp = WebGUI::URL::append($temp,'styleId='.$param[1]);
	}
	if ($param[0] ne "linkonly") {
		my %var;
		$var{'printable.url'} = $temp;
       		if ($param[0] ne "") {
               		$var{'printable.text'} = $param[0];
       		} else {
               		$var{'printable.text'} = WebGUI::International::get(53,'Macro_r_printable');
       		}
		if ($param[2]) {
         		$temp =  WebGUI::Asset::Template->newByUrl($param[2])->process(\%var);
		} else {
         		$temp =  WebGUI::Asset::Template->new("PBtmpl0000000000000045")->process(\%var);
		}
	}
	return $temp;
}


1;

