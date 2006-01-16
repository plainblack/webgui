package WebGUI::Macro::c_companyName;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;

=head1 NAME

Package WebGUI::Macro::c_companyName

=head1 DESCRIPTION

Macro for displaying the Company Name entered into the WebGUI site settings

=head2 process ( )

returns the companyName from the session variable.

=cut

#-------------------------------------------------------------------
sub process {
	my $session = shift; use WebGUI; WebGUI::dumpSession($session);
        return $session->setting->get("companyName");
}

1;

