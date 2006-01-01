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
use WebGUI::Asset::Template;

=head1 NAME

Package WebGUI::Macro::EditableToggle

=head1 DESCRIPTION

Macro for displaying a url to the user for turning Admin mode on and off if they
have editing rights to the current Asset.

=head2 process ( [turnOn,turnOff,template ] )

process takes three optional parameters for customizing the content and layout
of the account link.

=head3 turnOn

The text displayed to the user if Admin mode is turned off, they are in the
Turn On Admin group and they have editing rights to this Asset.
If this is blank an internationalized default is used.

=head3 turnOff

The text displayed to the user if Admin mode is turned on, they are in
the Turn On Admin group and they have editing rights to this Asset..
If this is blank an internationalized default is used.

=head3 template

A template from the Macro/EditableToggle namespace to use for formatting the link.

=cut

#-------------------------------------------------------------------
sub process {
	my $session = shift;
         if (exists $session->asset && $session->asset->canEdit && WebGUI::Grouping::isInGroup(12)) {
        	my %var;
              my @param = @_;
              my $turnOn = $param[0] || WebGUI::International::get(516,'Macro_EditableToggle');
              my $turnOff = $param[1] || WebGUI::International::get(517,'Macro_EditableToggle');
                 if ($session->var->get("adminOn")) {
                      $var{'toggle.url'} = $session->url->page('op=switchOffAdmin');
                      $var{'toggle.text'} = $turnOff;
                 } else {
                      $var{'toggle.url'} = $session->url->page('op=switchOnAdmin');
                      $var{'toggle.text'} = $turnOn;
                 }
		if ($param[2]) {
         		return  WebGUI::Asset::Template->newByUrl($session,$param[2])->process(\%var);
		} else {
         		return  WebGUI::Asset::Template->new($session,"PBtmpl0000000000000038")->process(\%var);
                }
       }
       return "";
}

1;


