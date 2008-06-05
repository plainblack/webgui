# Tests WebGUI::Flux::Expression::Builder
#
#

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Test::More;
use Test::Deep;
use Data::Dumper;
use Readonly;
use WebGUI::Test;    # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests
my $tests = 1;
plan tests => $tests;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Flux::Expression::Builder');

# TODO: Add some tests once WebGUI::Flux::Expression::Builder is built..

#----------------------------------------------------------------------------
# Cleanup
END {

}
