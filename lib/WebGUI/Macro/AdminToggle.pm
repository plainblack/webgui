package WebGUI::Macro::AdminToggle;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::International;
use WebGUI::Asset::Template;

=head1 NAME

Package WebGUI::Macro::AdminToggle

=head1 DESCRIPTION

Macro for displaying a url to the user for turning Admin mode on and off.

=head2 process ( [turnOn,turnOff,template ] )

process takes three optional parameters for customizing the content and layout
of the account link.

=head3 turnOn

The text displayed to the user if Admin mode is turned off and they are in the
Turn On Admin group.  If this is blank an internationalized default is used.

=head3 turnOff

The text displayed to the user if Admin mode is turned on and they are in the
Turn On Admin group.  If this is blank an internationalized default is used.

=head3 template

The URL of a template from the Macro/AdminToggle namespace to use for formatting the link.

=cut

#-------------------------------------------------------------------
sub process {
    my $session = shift;
    return ""
        unless $session->user->canUseAdminMode;
    my ($turnOn, $templateName) = @_;
    my $i18n = WebGUI::International->new($session,'Macro_AdminToggle');
    my %var;
    $var{'toggle_text'} = $turnOn || $i18n->get(516);
    if ($session->var->isAdminOn) {
        $var{'toggle_url'} = '#'
    }
    else {
        $var{'toggle_url'} = $session->url->page('op=admin');
    }
    my $template = $templateName    ? WebGUI::Asset::Template->newByUrl($session, $templateName)
                                    : WebGUI::Asset::Template->newById($session, "PBtmpl0000000000000036");
    return $template->process(\%var);
}

1;


