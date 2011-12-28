package WebGUI::Macro::u_companyUrl;

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

Package WebGUI::Macro::u_companyUrl

=head1 DESCRIPTION

Macro for displaying the Company URL entered into the WebGUI site settings

=head2 process ( )

returns the companyURL from the session object.

=cut


#-------------------------------------------------------------------
sub process {
	my $session = shift;
        return $session->setting->get("companyURL");
}

1;

