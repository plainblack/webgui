package WebGUI::Macro::AdminToggle;

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
use WebGUI::Grouping;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::Template;
use WebGUI::URL;

#-------------------------------------------------------------------
sub process {
         if (WebGUI::Grouping::isInGroup(12)) {
        	my %var;
                 my @param = WebGUI::Macro::getParams($_[0]);
              my $templateId = 1;  ##Set default template in the namespace
              ##1 param means use my template with default text
              my ($turnOff, $turnOn) = (WebGUI::International::get(517),WebGUI::International::get(516));
              if (@param == 1) {
			$templateId = WebGUI::Template::getIdByName($param[0],"Macro/AdminToggle");
              }
              ##2 params means use my text with the default template
              elsif (@param == 2) {
                      ($turnOff, $turnOn) = @param;
              }
              ##3 or more params means use my text and template, other args ignored
              elsif (@param >= 3) {
                      ($turnOff, $turnOn) = @param[1,2];
			$templateId = WebGUI::Template::getIdByName($param[0],"Macro/AdminToggle");
              }
                 if ($session{var}{adminOn}) {
                      $var{'toggle.url'} = WebGUI::URL::page('op=switchOffAdmin');
                      $var{'toggle.text'} = $turnOff;
                 } else {
                      $var{'toggle.url'} = WebGUI::URL::page('op=switchOnAdmin');
                      $var{'toggle.text'} = $turnOn;
                 }
              $templateId = 1 if $templateId == 0;
                return WebGUI::Template::process($templateId,"Macro/AdminToggle",\%var);
	}
       return "";
}

1;


