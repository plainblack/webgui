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

use WebGUI::Test;
use WebGUI::Session;
use Data::Dumper;
use WebGUI::Macro::Env;
use Scalar::Util qw/blessed/;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

##The test will scan the ENV hash and make sure that any key found in it
##can be retrieved via the macro.  There are also tests for null, undef,
##and non-existant keys.

my %env = %{ $session->request->env };
my @keys = keys %env;

my $output;

$output =  WebGUI::Macro::Env::process($session, '');
is($output, '', 'null key');

$output =  WebGUI::Macro::Env::process($session, undef);
is($output, '', 'undef key');

$output =  WebGUI::Macro::Env::process($session, 'KEY DOES NOT EXIST');
is($output, '', 'non existent key');

foreach my $key (@keys) {
	my $output =  WebGUI::Macro::Env::process($session, $key);
	is($output, $env{$key}, 'Fetching: '.$key);
}

##Checking for object access
$session->request->env->{'webgui.session'} = $session;
my $neo_session = WebGUI::Macro::Env::process($session, 'webgui.session');
ok ! ref $neo_session, 'did not get a reference back';

done_testing;
