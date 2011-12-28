package WebGUI::Macro::SpectreCheck;

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
use WebGUI::Operation::Spectre;
use WebGUI::International;

=head1 NAME

Package WebGUI::Macro:SpectreCheck:

=head1 DESCRIPTION

A macro to return the status of Spectre.

=head2 process( )


=cut


#-------------------------------------------------------------------
sub process {
	my $session = shift;
    my $status = WebGUI::Operation::Spectre::spectreTest($session);
    my $i18n = WebGUI::International->new($session, "Macro_SpectreCheck");
    if (defined $status) {
        return $i18n->get('success') if($status eq 'success');
        return $i18n->get('subnet')  if($status eq 'subnet');
        return $i18n->get('spectre');
    }
    else {
        return $i18n->get('spectre');
    }
}

1;


