package WebGUI::International;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
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
        my ($output, $language, $namespace);
	if ($_[2] ne "") {
		$language = $_[2];
	} elsif ($session{user}{language} ne "") {
		$language = $session{user}{language};
	} else {
		$language = "English";
	}
	if ($_[1] ne "") {
		$namespace = $_[1];
	} else {
		$namespace = "WebGUI";
	}
	if (defined $international{$language}{$_[0]}) { 		# a little caching never hurts =)
		$output = $international{$language}{$_[0]};
	} else {
		($output) = WebGUI::SQL->quickArray("select message from international where internationalId=$_[0] and namespace='$namespace' and language='$language'");
		if ($output eq "" && $language ne "English") {
			$output = get($_[0],$namespace,"English");
		}
	}
	return $output;
}

1;

