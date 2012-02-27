package WebGUI::Macro::Env;

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

Package WebGUI::Macro::Env

=head1 DESCRIPTION

Macro for displaying fields from the Session env hash.

=head2 process ( key )

=head3 key

The key from the Session env hash to display.  If the key doesn't exist,
then the empty string will be returned.  This does not allow objects or data references
in the env hash to be accessed.

=cut

#-------------------------------------------------------------------
sub process {
	my $session = shift;
    my $key     = shift;
	return $session->request->env->{$key}.'';
}

1;


