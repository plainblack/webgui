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
use WebGUI::Session;
use WebGUI::Asset::Template;
use WebGUI::URL;

=head1 NAME

Package WebGUI::Macro::AdminToggle

=head1 DESCRIPTION

Macro for displaying a url to the user for turning Admin mode on and off.

=head2 process ( [turnOn,turnOff,template ] )

process takes two optional parameters for customizing the content and layout
of the account link.

=head3 turnOn

The text displayed to the user if Admin mode is turned off and they are in the
Turn On Admin group.  If this is blank an internationalized default is used.

=head3 turnOff

The text displayed to the user if Admin mode is turned on and they are in the
Turn On Admin group.  If this is blank an internationalized default is used.

=head3 template

A template to use for formatting the link.

=cut

#-------------------------------------------------------------------
sub process {
         if (WebGUI::Grouping::isInGroup(12)) {
        	my %var;
                 my ($turnOn,$turnOff,$templateName) = @_;
              $turnOn ||= WebGUI::International::get(516,'Macro_AdminToggle');
              $turnOff ||= WebGUI::International::get(517,'Macro_AdminToggle');
                 if (WebGUI::Session::isAdminOn()) {
                      $var{'toggle.url'} = WebGUI::URL::page('op=switchOffAdmin');
                      $var{'toggle.text'} = $turnOff;
                 } else {
                      $var{'toggle.url'} = WebGUI::URL::page('op=switchOnAdmin');
                      $var{'toggle.text'} = $turnOn;
                 }
		if ($templateName) {
         		return  WebGUI::Asset::Template->newByUrl($templateName)->process(\%var);
		} else {
         		return  WebGUI::Asset::Template->new("PBtmpl0000000000000036")->process(\%var);
		}
	}
       return "";
}

1;


