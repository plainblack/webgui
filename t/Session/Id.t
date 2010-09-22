#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
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

use Test::More;

my @testSets = (
	{
		comment => 'too short',
		guid => 'tooShort',
		valid => '',
	},
	{
		comment => 'too long',
		guid => '12345678901234567890123',
		valid => '',
	},
	{
		comment => 'contains white space',
		guid => ' 23456	890123456789012',
		valid => '',
	},
	{
		comment => 'contains illegal punctuation',
		guid => '12#4%67*901234&678901.',
		valid => '',
	},
	{
		comment => 'MD5 style',
		guid => '==//abcdeZYXWV01234567',
		valid => '',
	},
	{
		comment => 'GUID style',
		guid => '--__abcdeZYXWV0123456A',
		valid => 1,
	},
);

my $session = WebGUI::Test->session;

plan tests => scalar(@testSets) + 6;

# generate
my $generateId = $session->id->generate();
is(length($generateId), 22, "generate() - length of 22 characters");
my @uniqueIds;
my $isUnique = 1;
my $isValid = 1;
for (1..2000) {
	last unless $isUnique;
	my $id = $session->id->generate();
	$isUnique = ($isUnique ? ! ($id ~~ @uniqueIds) : 0);
	$isValid = ($isValid ? $session->id->valid($id) : 0);
	push(@uniqueIds,$id);
}
ok($isUnique, "generate() - unique");
ok($isValid, "generate() - valid id generated");

foreach my $testSet (@testSets) {
	is($session->id->valid($testSet->{guid}), $testSet->{valid}, $testSet->{comment});
}

# 
# 

is($session->id->toHex('wjabZsKOb7kBBSiO3bQwzA'), 'c2369b66c28e6fb90105288eddb430cc', 'toHex works');
is($session->id->fromHex('c2369b66c28e6fb90105288eddb430cc'), 'wjabZsKOb7kBBSiO3bQwzA', 'fromHex works');

my $re = $session->id->getValidator;
is( ref $re, 'Regexp', 'getValidator returns a regexp object');
