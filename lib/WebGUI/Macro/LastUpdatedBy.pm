package WebGUI::Macro::LastUpdatedBy;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Asset;
use WebGUI::User;

=head1 NAME

Package WebGUI::Macro::LastUpdatedBy

=head1 DESCRIPTION

Macro for displaying the username of the user that made the most recent revision of current Asset.

=head2 process (  )

Display the username, if the user still exists in the system.  If not, of if the user does not
have a username, then display an internationalized label for "Unknown".

=cut


#-------------------------------------------------------------------
sub process {
    my $session = shift;
    return '' unless $session->asset;
    
    my $userId = $session->asset->getContentLastModifiedBy();
    my $user   = WebGUI::User->new($session, $userId);
    if ($user && $user->username) {
        return $user->username;
    }

    my $i18n = WebGUI::International->new($session,'Macro_LastModified');
    return $i18n->get('Unknown');
}

1;
