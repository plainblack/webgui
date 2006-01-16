#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

# ---- BEGIN DO NOT EDIT ----
use strict;
use lib '../../lib';
use Getopt::Long;
use WebGUI::Session;
# ---- END DO NOT EDIT ----


use Test::More tests => 2; # increment this value for each test you create
use WebGUI::Utility;

my $session = initialize();  # this line is required

# generate
my $generateId = $session->id->generate();
is(length($generateId), 22, "generate() - length of 22 characters");
my @uniqueIds;
my $isUnique = 1;
for (1..2000) {
	last unless $isUnique;
	my $id = $session->id->generate();
	$isUnique = !isIn($id,@uniqueIds);
	push(@uniqueIds,$id);
}
ok($isUnique, "generate() - unique");

cleanup($session); # this line is required


# ---- DO NOT EDIT BELOW THIS LINE -----

sub initialize {
        $|=1; # disable output buffering
        my $configFile;
        GetOptions(
                'configFile=s'=>\$configFile
        );
        exit 1 unless ($configFile);
        my $session = WebGUI::Session->open("../..",$configFile);
}

sub cleanup {
        my $session = shift;
        $session->close();
}

