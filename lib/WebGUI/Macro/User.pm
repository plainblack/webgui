package WebGUI::Macro::User;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;

=head1 NAME

Package WebGUI::Macro::User

=head1 DESCRIPTION

Macro for displaying information from the a User's profile.

=head2 process( field [, userId] )

This macro tries to return the profile field passed in for the user
passed in.  If not user is passed in, the current user in session
will be used.  

=head3 field

field to return

=head3 userId

optional userId of the user to return the field for.  If this field is
empty, the profile field for the default user will be returned

=cut

#-------------------------------------------------------------------
sub process {
	my $session    = shift;
    my $field      = shift;
    my $userId     = shift;

    return undef unless ($field);
    
    my $user       = ($userId)
                   ? WebGUI::User->new($session,$userId)
                   : $session->user
                   ;

	return  $user->get($field);
}

1;
