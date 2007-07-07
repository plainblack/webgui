#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2007 Plain Black Corporation.
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

$numTests += 1; ##use_ok
$numTests += 1; ##testBlock has no name collisions
$numTests += 3; ##TODO block

plan tests => $numTests;

my $macro = 'WebGUI::Macro::FormParam';
my $loaded = use_ok($macro);

SKIP: {

skip "Unable to load $macro", $numTests-1 unless $loaded;

auto_check($session, \@testSets);

}

TODO: {
	local $TODO = "Tests to write later";
	ok(0, "What will this do with a non-existant form param?");
	ok(0, "Also try null");
	ok(0, "Also try undef");
}

sub auto_check {
	my ($session, $testBlock) = @_;
	my $origSessionRequest = $session->{_request};

	##Create a by-name interface to the test to simplify the
	##mocked request.
	my %tests = map { $_->{key} => $_ } @{ $testBlock };
	is(scalar keys %tests, scalar @{ $testBlock }, 'no collisions in testBlock');

	my $request = Test::MockObject->new;
	$request->mock('body',
		sub {
			my ($self, $value) = @_;
			return unless exists $tests{$value};
			if (ref $tests{$value}->{testValue} eq "ARRAY") {
				return @{ $tests{$value}->{testValue} } ;
			}
			else {
				return $tests{$value}->{testValue};
			}
		}
	);

	$session->{_request} = $request;

	foreach my $test ( @{ $testBlock } ) {
		$test->{expected} = $test->{testValue} if $test->{expected} eq 'EQUAL';
		my $value = WebGUI::Macro::FormParam::process($session, $test->{key});
		is($value, $test->{expected}, $test->{comment});
	}

	$session->{_request} = $origSessionRequest;
}
