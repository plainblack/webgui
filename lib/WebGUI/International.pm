package WebGUI::International;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Session;
use WebGUI::SQL;

my %international;

#-------------------------------------------------------------------
sub get {
        my ($output, $language);
	if ($session{user}{language} ne "") {
		$language = $session{user}{language};
	} elsif ($_[1] ne "") {
		$language = $_[1];
	} else {
		$language = "English";
	}
	if (defined $international{$language}{$_[0]}) { 		# a little caching never hurts =)
		$output = $international{$language}{$_[0]};
	} else {
		($output) = WebGUI::SQL->quickArray("select message from international where internationalId=$_[0] and language='$language'",$session{dbh});
		if ($output eq "" && $language ne "English") {
			$output = get($_[0],"English");
		}
	}
	return $output;
}

1;

