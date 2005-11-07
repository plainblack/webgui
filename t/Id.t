#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

# ---- BEGIN DO NOT EDIT ----
use strict;
use lib '../lib';
use Getopt::Long;
use WebGUI::Session;
# ---- END DO NOT EDIT ----


use Test::More tests => 2; # increment this value for each test you create
use WebGUI::Id;
use WebGUI::Utility;

initialize();  # this line is required

# generate
my $generateId = WebGUI::Id::generate();
is(length($generateId), 22, "generate() - length of 22 characters");
my @uniqueIds;
my $isUnique = 1;
for (1..2000) {
	last unless $isUnique;
	my $id = WebGUI::Id::generate();
	$isUnique = !isIn($id,@uniqueIds);
	push(@uniqueIds,$id);
}
ok($isUnique, "generate() - unique");

cleanup(); # this line is required


# ---- DO NOT EDIT BELOW THIS LINE -----

sub initialize {
	$|=1; # disable output buffering
	my $configFile;
	GetOptions(
        	'configFile=s'=>\$configFile
	);
	exit 1 unless ($configFile);
	WebGUI::Session::open("..",$configFile);
}

sub cleanup {
	WebGUI::Session::close();
}

