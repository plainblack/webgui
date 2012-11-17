package WebGUI::Macro::Include;

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
use WebGUI::International;

=head1 NAME

Package WebGUI::Macro::Include

=head1 DESCRIPTION

Macro for returning the contents of a file from the filesystem.
This macro is an extreme security risk and you are advised not to
use it.

=head2 process ( filename )

process will return internationalized error messages if an illegal file
is read (password, group of config file) or if the file could not be found.

=head3 filename

The complete path to a file in the local filesystem.

=cut


#-------------------------------------------------------------------
sub process {
    my $session = shift;
    my $filename = shift;
    my $i18n = WebGUI::International->new($session,'Macro_Include');
    if ($filename =~ /passwd/i || $filename =~ /shadow/i || $filename =~ m{\.conf$}i) {
        return $i18n->get('security');
    }
    open my $fh, '<', $filename
        or return $i18n->get('not found');
    return scalar do { local $/; readline $fh };
}


1;


