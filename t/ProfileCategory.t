#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
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

use WebGUI::ProfileCategory;

use Test::More tests => 1; # increment this value for each test you create
use Test::Deep;

my $session = WebGUI::Test->session;

###################################################################
#
# getCategories
#
###################################################################

my $categories = WebGUI::ProfileCategory->getCategories($session);

my @labels = map { $_->getLabel } @{ $categories };

my %originalProperties = %{ $categories->[0]->get };
my %properties = %originalProperties;
WebGUI::Test->addToCleanup(sub { $categories->[0]->set(\%originalProperties); });
$properties{visible} = 0;
$categories->[0]->set(\%properties);

my $newCategories = WebGUI::ProfileCategory->getCategories($session);
my @newLabels     = map { $_->getLabel } @{ $newCategories };

cmp_bag(\@newLabels, \@labels, 'Setting a category to not be visible does not change its availability through getCategories, with no options');

#vim:ft=perl
