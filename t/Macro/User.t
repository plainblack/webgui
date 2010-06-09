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
use WebGUI::Macro::User;
use WebGUI::Session;
use WebGUI::User;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

my @testSets = (
	{
		firstName => 'Joe',
		lastName => 'Bob',
		alias => 'joebob',
		aim => 'JOEBOB'
	},
	{
		firstName => 'Pete',
		lastName => 'Bob',
		alias => 'petebob',
		msnIM => 'PeteBob@msn'
	},
	{
		firstName => 'Tim',
		lastName => 'Bob',
		alias => 'timbob',
		yahooIM => 'tim the yahoo',
	},
);

my $numTests = 1;
foreach my $testSet (@testSets) {
	$numTests += scalar keys %{ $testSet };
}

plan tests => $numTests;

@testSets = setupTest($session, @testSets);
my @users = map { $_->{user} } @testSets;
WebGUI::Test->addToCleanup(@users);

foreach my $testSet (@testSets) {
	$session->user({ userId => $testSet->{user}->userId });
	foreach my $field (keys %{ $testSet }) {
		next if $field eq 'user';
		my $output = WebGUI::Macro::User::process($session, $field);
		my $comment = sprintf "Checking userid: %s, field: %s", $session->user->userId, $field;
		is($output, $testSet->{$field}, $comment);
	}
}

my $field = "NonExistantField";
my $output = WebGUI::Macro::User::process($session, $field);
my $comment = sprintf "Checking userid: %s, field: %s", $session->user->userId, $field;
is($output, undef, $comment);  ##Unprocessed macro returns macro

sub setupTest {
	my ($session, @testSets) = @_;
	foreach my $testSet (@testSets) {
		my $user = WebGUI::User->new($session, "new");
		foreach my $field (keys %{ $testSet} ) {
			$user->profileField($field, $testSet->{$field});
		}
		$testSet->{user} = $user;
	}
	return @testSets;
}
