package WebGUI::Macro::EditableToggle;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black LLC.
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
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::URL;

#-------------------------------------------------------------------
sub process {
       my ($temp, @param, $turnOn, $turnOff);
       if (WebGUI::Privilege::canEditPage() && WebGUI::Privilege::isInGroup(5)) {
               @param = WebGUI::Macro::getParams($_[0]);
               if ($session{var}{adminOn}) {
                       $turnOff = $param[1] || WebGUI::International::get(517);
                       $temp = '<a href="'.WebGUI::URL::page('op=switchOffAdmin').'">'.$turnOff.'</a>';
               } else {
                       $turnOn = $param[0] || WebGUI::International::get(516);
                       $temp = '<a href="'.WebGUI::URL::page('op=switchOnAdmin').'">'.$turnOn.'</a>';
               }
       }
       return $temp;
}

1;


