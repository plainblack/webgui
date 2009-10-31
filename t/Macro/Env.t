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
use Data::Dumper;
use WebGUI::Macro::Env;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

##The test will scan the ENV hash and make sure that any key found in it
##can be retrieved via the macro.  There are also tests for null, undef,
##and non-existant keys.

my %env = %{ $session->env->{_env} };
my @keys = keys %env;

my $numTests = 3 + scalar keys %env;

plan tests => $numTests;

my $output;

$output =  WebGUI::Macro::Env::process($session, '');
is($output, undef, 'null key');

$output =  WebGUI::Macro::Env::process($session, undef);
is($output, undef, 'undef key');

$output =  WebGUI::Macro::Env::process($session, 'KEY DOES NOT EXIST');
is($output, undef, 'non existent key');

foreach my $key (keys %env) {
	my $output =  WebGUI::Macro::Env::process($session, $key);
	is($output, $env{$key}, 'Fetching: '.$key);
}
