package WebGUI::Macro::e_companyEmail;

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

Package WebGUI::Macro::e_companyEmail

=head1 DESCRIPTION

Macro for displaying the Company Email entered into the WebGUI site settings

=head2 process ( )

returns the companyEmail from the session object.

=cut

#-------------------------------------------------------------------
sub process {
	my $session = shift;
        return $session->setting->get("companyEmail");
}

1;

