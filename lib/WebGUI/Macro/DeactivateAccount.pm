package WebGUI::Macro::DeactivateAccount;

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

Package WebGUI::Macro::DeactivateAccount

=head1 DESCRIPTION

Macro for displaying a url to the user for deactivating their account, if
the setting is turned on.

=head2 process ( deactivateText )

process takes two optional parameters for customizing the content and layout
of the self deactivation link.

=head3 deactivateText

The text displayed to the user for this link.  If this is blank an internationalized default is used.

=head3 linkonly

If true, it will return only the URL for deactivating a user account.

=cut

#-------------------------------------------------------------------
sub process {
    my $session = shift;
    my ($deactivateText, $linkonly) = @_;

    return "" unless ($session->setting->get("selfDeactivation") && !$session->user->isAdmin);

    my $deactivateUrl = $session->url->page('op=auth;method=deactivateAccount');

    return $deactivateUrl if($linkonly);

    my $i18n           = WebGUI::International->new($session);
    my $format         = q{<a href="%s">%s</a>};
    $deactivateText    = $i18n->get(65) unless ($deactivateText);
    
    return sprintf($format,$deactivateUrl,$deactivateText);
}

1;


