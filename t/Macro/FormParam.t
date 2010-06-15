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
use WebGUI::Macro::FormParam;

use Test::More; # increment this value for each test you create
use Test::MockObject;

my $session = WebGUI::Test->session;

my @testSets = (
	{
		key => 'FormParam1',
		testValue => 'a',
		expected  => 'EQUAL',
		comment   => 'scalar data, alpha',
		dataType  => 'SCALAR'
	},
	{
		key => 'FormParam2',
		testValue => 100,
		expected  => 'EQUAL',
		comment   => 'scalar data, numeric',
		dataType  => 'SCALAR'
	},
	{
		key => 'FormParam3',
		testValue => [qw/a b c/],
		expected  => "a",
		comment   => 'array data, alpha',
		dataType  => 'SCALAR'
	},
	{
		key => 'FormParam4',
		testValue => [qw/b c a/],
		expected  => "b",
		comment   => 'array data, alpha, non-alpha order',
		dataType  => 'SCALAR'
	},
);

my $numTests = scalar @testSets;

$numTests += 1; ##testBlock has no name collisions
$numTests += 3; ##TODO block

plan tests => $numTests;

auto_check($session, \@testSets);

TODO: {
	local $TODO = "Tests to write later";
	ok(0, "What will this do with a non-existant form param?");
	ok(0, "Also try null");
	ok(0, "Also try undef");
}

sub auto_check {
	my ($session, $testBlock) = @_;

	##Create a by-name interface to the test to simplify the
	##mocked request.
	my %tests = map { $_->{key} => $_ } @{ $testBlock };
	is(scalar keys %tests, scalar @{ $testBlock }, 'no collisions in testBlock');

    my $param_hash = Hash::MultiValue->from_mixed(
        map { $_->{key} => $_->{testValue} } @{ $testBlock }
    );
    local $session->request->env->{'plack.request.query'} = $param_hash;
    local $session->request->env->{'plack.request.body'} = $param_hash;
    local $session->request->env->{'plack.request.merged'} = $param_hash;

	foreach my $test ( @{ $testBlock } ) {
		$test->{expected} = $test->{testValue} if $test->{expected} eq 'EQUAL';
		my $value = WebGUI::Macro::FormParam::process($session, $test->{key});
		is($value, $test->{expected}, $test->{comment});
	}
}
