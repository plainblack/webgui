package WebGUI::Macro::AdminToggle;

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
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::Asset::Template;
use WebGUI::URL;

#-------------------------------------------------------------------
sub process {
         if (WebGUI::Grouping::isInGroup(12)) {
        	my %var;
                 my ($turnOn,$turnOff,$templateName) = WebGUI::Macro::getParams($_[0]);
              $turnOn ||= WebGUI::International::get(516,'Macro_AdminToggle');
              $turnOff ||= WebGUI::International::get(517,'Macro_AdminToggle');
                 if (WebGUI::Session::isAdminOn()) {
                      $var{'toggle.url'} = WebGUI::URL::page('op=switchOffAdmin');
                      $var{'toggle.text'} = $turnOff;
                 } else {
                      $var{'toggle.url'} = WebGUI::URL::page('op=switchOnAdmin');
                      $var{'toggle.text'} = $turnOn;
                 }
		return WebGUI::Asset::Template->newByUrl($templateName || "default_admin_toggle_macro")->process(\%var);
	}
       return "";
}

1;


