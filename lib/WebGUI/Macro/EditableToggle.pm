package WebGUI::Macro::EditableToggle;

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
use WebGUI::Grouping;
use WebGUI::International;
use WebGUI::Session;
use WebGUI::Asset::Template;
use WebGUI::URL;

#-------------------------------------------------------------------
sub process {
         if (exists $session{asset} && $session{asset}->canEdit && WebGUI::Grouping::isInGroup(12)) {
        	my %var;
              my @param = @_;
              my $turnOn = $param[0] || WebGUI::International::get(516,'Macro_EditableToggle');
              my $turnOff = $param[1] || WebGUI::International::get(517,'Macro_EditableToggle');
                 if ($session{var}{adminOn}) {
                      $var{'toggle.url'} = WebGUI::URL::page('op=switchOffAdmin');
                      $var{'toggle.text'} = $turnOff;
                 } else {
                      $var{'toggle.url'} = WebGUI::URL::page('op=switchOnAdmin');
                      $var{'toggle.text'} = $turnOn;
                 }
		if ($param[2]) {
         		return  WebGUI::Asset::Template->newByUrl($param[2])->process(\%var);
		} else {
         		return  WebGUI::Asset::Template->new("PBtmpl0000000000000038")->process(\%var);
                }
       }
       return "";
}

1;


