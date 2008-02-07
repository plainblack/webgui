#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use strict;
use warnings;
use lib "$FindBin::Bin/../lib"; ##t/lib

use WebGUI::Test;
use WebGUI::AdminConsole;
use WebGUI::International;
use WebGUI::Session;

#The goal of this test is to verify all the i18n labels in
#the Admin Console functions

use Test::More; # increment this value for each test you create
my $numTests = 0;

my $session = WebGUI::Test->session;
my $lib = WebGUI::Test->lib;

# put your tests here

my $ac = WebGUI::AdminConsole->new($session);

my %consoleFuncs = %{ $ac->getAdminFunction('', 1) };


$numTests = scalar keys %consoleFuncs;

plan tests => $numTests;

my $i18n = WebGUI::International->new($session);

my ($label, $func);
while ( ($label, $func) = each %consoleFuncs ) {
	ok($i18n->get(@{ $func->{title} }{qw(id namespace )} ),
	sprintf "The title for %s, tag: %s, namespace: %s exists", $label, @{ $func->{title} }{'id', 'namespace'});
}


