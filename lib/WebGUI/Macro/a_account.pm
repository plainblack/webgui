package WebGUI::Macro::a_account;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::Template;
use WebGUI::URL;

#-------------------------------------------------------------------
sub process {
       my %var;
         my  @param = WebGUI::Macro::getParams($_[0]);
       $var{'account.url'} = WebGUI::URL::page('op=displayAccount');
         my $templateId = 1;  ##Set default template in the namespace
       $var{'account.text'} = WebGUI::International::get(46);
       if    (@param == 1) {
               $var{'account.text'} = $param[0] if $param[0];
        }
       elsif (@param == 2) {
               $var{'account.text'} = $param[0] if $param[0];
		$templateId = WebGUI::Template::getIdByName($param[1],"Macro/a_account");
               $templateId = 1 if $templateId == 0;
       }
         return WebGUI::Template::process($templateId,"Macro/a_account",\%var);
}


1;


