# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#------------------------------------------------------------------

# Write a little about what this script tests.
# 
#

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";
use Test::More qw(no_plan);
use Test::Deep;
use Exception::Class;
use Data::Dumper;

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Text;
use WebGUI::Shop::Cart;
use WebGUI::Shop::AddressBook;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

#----------------------------------------------------------------------------
# put your tests here

##Set up the tax information
my $taxer = WebGUI::Shop::Tax->new($session);
$taxer->importTaxData(
    WebGUI::Test->getTestCollateralPath('taxTables/largeTaxTable.csv')
);
