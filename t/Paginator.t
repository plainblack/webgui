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
my $endingRowNum   =  99;
my @paginatingData = ($startingRowNum..$endingRowNum);

plan tests => 13; # increment this value for each test you create

my $rowCount       = $endingRowNum - $startingRowNum + 1;
my $NumberOfPages  = ceil($rowCount/25); ##Default page size=25

my $p = WebGUI::Paginator->new($session, '/home');

isa_ok($p, 'WebGUI::Paginator', 'paginator object returned');

$p->setDataByArrayRef(\@paginatingData);

is($p->getRowCount,      $rowCount,      'all data returned by paginator');
is($p->getNumberOfPages, $NumberOfPages, 'paginator returns right number of pages (default setting)');

my $page1Data = $p->getPageData(1);
cmp_bag([0..24],  $p->getPageData(1), 'page 1 data correct');
cmp_bag([25..49], $p->getPageData(2), 'page 2 data correct');
cmp_bag([      ], $p->getPageData(5), 'page 5 data correct');

$startingRowNum =   0;
$endingRowNum   = 100;
@paginatingData = ($startingRowNum..$endingRowNum);

$rowCount       = $endingRowNum - $startingRowNum + 1;
$NumberOfPages  = ceil($rowCount/25); ##Default page size=25

$p = WebGUI::Paginator->new($session, '/home');

$p->setDataByArrayRef(\@paginatingData);

is($p->getRowCount,      $rowCount,      '(101) paginator returns correct number of rows');
is($p->getNumberOfPages, $NumberOfPages, '(101) paginator returns right number of pages (default setting)');

my $page1Data = $p->getPageData(1);
cmp_bag([0..24],  $p->getPageData(1), '(101) page 1 data correct');
cmp_bag([25..49], $p->getPageData(2), '(101) page 2 data correct');
cmp_bag([100   ], $p->getPageData(5), '(101) page 5 data correct');

is('100', $p->getPage(5), '(101) page 5 stringification okay');

is($p->getPageNumber, 1, 'Default page number is 1'); ##Additional page numbers are specified at instantiation
