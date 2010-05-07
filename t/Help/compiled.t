#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Pluggable;
use WebGUI::Operation::Help;

#The goal of this test is to verify that all entries in the lib/WebGUI/Help
#directory compile.  This test is necessary because WebGUI::Operation::Help
#will return an empty hash if it won't compile, and the help will simply
#disappear.

use Test::More;
my $numTests = 0;

my $session = WebGUI::Test->session;

my @helpFileSet = WebGUI::Pluggable::findAndLoad('WebGUI::Help');

$numTests = scalar @helpFileSet; #One for each help compile

plan tests => $numTests;

foreach my $helpFile (@helpFileSet) {
    my ($namespace) = $helpFile =~ m{WebGUI::Help::(.+$)};
    my $help = WebGUI::Operation::Help::_load($session, $namespace);
    ok(keys %{ $help }, "$namespace compiled");
}
