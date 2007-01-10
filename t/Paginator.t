#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use strict;
use lib "$FindBin::Bin/lib";

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Utility;

use WebGUI::Paginator;
use Test::More; # increment this value for each test you create
use Test::Deep;
use POSIX qw(ceil);

my $session = WebGUI::Test->session;

my $startingRowNum =   0;
my $endingRowNum   = 100;

my @paginatingData = $startingRowNum .. $endingRowNum;

plan tests => 6; # increment this value for each test you create

my $rowCount       = $endingRowNum - $startingRowNum + 1;
my $NumberOfPages  = ceil($rowCount/25); ##Default page size=25

my $p = WebGUI::Paginator->new($session, '/home');

isa_ok($p, 'WebGUI::Paginator', 'paginator object returned');

$p->setDataByArrayRef(\@paginatingData);

is($p->getRowCount,      $rowCount,      'all data returned by paginator');
is($p->getNumberOfPages, $NumberOfPages, 'paginator returns right number of pages (default setting)');

my $page1Data = $p->getPageData(1);
cmp_bag([0..24], $page1Data, 'page 1 data correct');

use Data::Dumper;

my $page2Data = $p->getPageData(2);
cmp_bag([25..49], $page2Data, 'page 2 data correct');

my $page5Data = $p->getPageData(5);
cmp_bag([100], $page5Data, 'page 5 data correct');
