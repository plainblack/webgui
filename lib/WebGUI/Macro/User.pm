package WebGUI::Macro::User;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
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

	return  $user->profileField($field);
}


1;


