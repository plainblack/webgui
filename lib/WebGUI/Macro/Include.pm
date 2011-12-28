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
use FileHandle;
use WebGUI::International;

=head1 NAME

Package WebGUI::Macro::Include

=head1 DESCRIPTION

Macro for returning the contents of a file from the filesystem.

=head2 process ( filename )

process will return internationalized error messages if an illegal file
is read (password, group of config file) or if the file could not be found.

=head3 filename

The complete path to a file in the local filesystem.

=cut


#-------------------------------------------------------------------
sub process {
	my $session = shift;
        my (@param, $temp, $file);
        @param = @_;
	my $i18n = WebGUI::International->new($session,'Macro_Include');
	if ($param[0] =~ /passwd/i || $param[0] =~ /shadow/i || $param[0] =~ m{\.conf$}i) {
                return $i18n->get('security');
        }
	$file = FileHandle->new($param[0],"r");
	if ($file) {
		local $/;
		$temp = $file->getline();
		$file->close;
	} else {
		$temp = $i18n->get('not found');
	}
        return $temp;
}


1;


