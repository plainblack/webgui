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
use WebGUI::Utility;

use WebGUI::Paginator;
use Test::More; # increment this value for each test you create
use Test::Deep;
use POSIX qw(ceil);
use Storable qw/dclone/;
use Data::Dumper;

my $session = WebGUI::Test->session;

plan tests => 32; # increment this value for each test you create

my $startingRowNum =   0;
my $endingRowNum   =  99;
my @paginatingData = ($startingRowNum..$endingRowNum);

my $rowCount        = $endingRowNum - $startingRowNum + 1;
my $NumberOfPages   = ceil($rowCount/25); ##Default page size=25
my $url             = "/home";

my $p = WebGUI::Paginator->new($session, $url);

isa_ok($p, 'WebGUI::Paginator', 'paginator object returned');

$p->setDataByArrayRef(\@paginatingData);

is($p->getRowCount,      $rowCount,      'all data returned by paginator');
is($p->getNumberOfPages, $NumberOfPages, 'paginator returns right number of pages (default setting)');

my $page1Data = $p->getPageData(1);
cmp_bag([0..24],  $p->getPageData(1), 'page 1 data correct');
cmp_bag([25..49], $p->getPageData(2), 'page 2 data correct');
cmp_bag([      ], $p->getPageData(5), 'page 5 data correct');

########################################################################
#
# getPageNumber, setPageNumber
#
########################################################################

my $p2 = WebGUI::Paginator->new($session, '/work');

is($p2->getPageNumber, 1, 'pageNumber set to 1 at object creation by default');
is($p2->setPageNumber(0), 0, 'setPageNumber returns the page number set');
is($p2->getPageNumber, 0, 'pageNumber set by setPageNumber');
is($p2->setPageNumber(3), 3, 'setPageNumber returns the page number set');
is($p2->getPageNumber, 3, 'pageNumber set by setPageNumber');

########################################################################
#
# getPageLinks
#
########################################################################

my $expectedPages;
$expectedPages = [  map { +{ 
            'pagination.text'   => ( $_ + 1 ), 
            'pagination.range'  => ( 25 * $_ + 1 ) . "-" . ( $_ * 25 + 25 <= $endingRowNum + 1 ? $_ * 25 + 25 : $endingRowNum + 1 ), # First row number - Last row number
            'pagination.url'    => ( $_ != 0 ? $url . '?pn=' . ( $_ + 1 ) : '' ), # Current page has no URL
        } } (0..$NumberOfPages-1) ];

$expectedPages->[0]->{'pagination.activePage'} = 'true';

cmp_deeply(
    ($p->getPageLinks)[0], 
    $expectedPages, 
    'page links correct',
);

$startingRowNum =   0;
$endingRowNum   = 100;
@paginatingData = ($startingRowNum..$endingRowNum);

$rowCount       = $endingRowNum - $startingRowNum + 1;
$NumberOfPages  = ceil($rowCount/25); ##Default page size=25

$p = WebGUI::Paginator->new($session, '/home');

$p->setDataByArrayRef(\@paginatingData);

is($p->getRowCount,      $rowCount,      '(101) paginator returns correct number of rows');
is($p->getNumberOfPages, $NumberOfPages, '(101) paginator returns right number of pages (default setting)');

$page1Data = $p->getPageData(1);
cmp_bag([0..24],  $p->getPageData(1), '(101) page 1 data correct');
cmp_bag([25..49], $p->getPageData(2), '(101) page 2 data correct');
cmp_bag([100   ], $p->getPageData(5), '(101) page 5 data correct');

is('100', $p->getPage(5), '(101) page 5 stringification okay');

is($p->getPageNumber, 1, 'Default page number is 1'); ##Additional page numbers are specified at instantiation

########################################################################
#
# getPageLinks with limits
#
########################################################################

$expectedPages = [  map { +{ 
            'pagination.text'   => ( $_ + 1 ), 
            'pagination.range'  => ( 25 * $_ + 1 ) . "-" . ( $_ * 25 + 25 <= $endingRowNum + 1 ? $_ * 25 + 25 : $endingRowNum + 1 ), # First row number - Last row number
            'pagination.url'    => ( $_ != 0 ? $url . '?pn=' . ( $_ + 1 ) : '' ), # Current page has no URL
        } } (0..$NumberOfPages-1) ];

$expectedPages->[0]->{'pagination.activePage'} = 'true';

cmp_deeply(
    ($p->getPageLinks)[0], 
    $expectedPages,
    'set of 5 pages looks right',
);

$startingRowNum =   0;
$endingRowNum   = 199;
@paginatingData = ($startingRowNum..$endingRowNum);


$p = WebGUI::Paginator->new($session, '/home', 10);

$rowCount       = $endingRowNum - $startingRowNum + 1;
$NumberOfPages  = ceil($rowCount/10); ##Default page size=25

$p->setDataByArrayRef(\@paginatingData);

$expectedPages = [  map { +{ 
            'pagination.text'   => ( $_ + 1 ), 
            'pagination.range'  => ( 10 * $_ + 1 ) . "-" . ( $_ * 10 + 10 <= $endingRowNum + 1 ? $_ * 10 + 10 : $endingRowNum + 1 ), # First row number - Last row number
            'pagination.url'    => ( '/home?pn=' . ( $_ + 1 ) ), # Current page has no URL
        } } (0..$NumberOfPages-1) ];


my $copy;
$copy = dclone($expectedPages);
$copy->[0]->{'pagination.activePage'} = 'true';
$copy->[0]->{'pagination.url'}        = '';

cmp_deeply(
    ($p->getPageLinks)[0], 
    $copy,
    'set of 20 pages looks right',
);

my @pageWindow;
$copy = dclone($expectedPages);
$copy->[0]->{'pagination.activePage'} = 'true';
$copy->[0]->{'pagination.url'}        = '';
@pageWindow = @{ $copy }[0..9];

cmp_deeply(
    ($p->getPageLinks(10))[0], 
    \@pageWindow,
    'set of first 10 pages selected correctly',
);

$p->setPageNumber(10);
my $copy = dclone($expectedPages);
$copy->[9]->{'pagination.activePage'} = 'true';
$copy->[9]->{'pagination.url'} = '';
@pageWindow = @{ $copy }[4..13];

cmp_deeply(
    ($p->getPageLinks(10))[0], 
    \@pageWindow,
    'set of middle 10 pages @10 selected correctly',
);

$p->setPageNumber(3);
my $copy = dclone($expectedPages);
$copy->[2]->{'pagination.activePage'} = 'true';
$copy->[2]->{'pagination.url'} = '';
delete $copy->[0]->{'pagination.activePage'};
@pageWindow = @{ $copy }[0..9];

cmp_deeply(
    ($p->getPageLinks(10))[0], 
    \@pageWindow,
    'set of 10 pages selected correctly, with off edge page number (3/20)',
);

$p->setPageNumber(17);
my $copy = dclone($expectedPages);
$copy->[16]->{'pagination.activePage'} = 'true';
$copy->[16]->{'pagination.url'} = '';
@pageWindow = @{ $copy }[10..19];

cmp_deeply(
    ($p->getPageLinks(10))[0], 
    \@pageWindow,
    'set of last 10 pages selected correctly, (17/20)',
);

$p->setPageNumber(20);
my $copy = dclone($expectedPages);
$copy->[19]->{'pagination.activePage'} = 'true';
$copy->[19]->{'pagination.url'} = '';
@pageWindow = @{ $copy }[10..19];

cmp_deeply(
    ($p->getPageLinks(10))[0], 
    \@pageWindow,
    'set of last 10 pages selected correctly, (20/20)',
);

########################################################################
#
# iterator based paginator
#
########################################################################

my $callback = sub {
    my ($start, $rowsPerPage) = @_;
    my $state   = $start * 2;
    my $counter = 0;
    my $iterator = sub {
        return 50 if $_[0] eq 'rowCount';
        return if ($counter >= $rowsPerPage);
        $state += 2;
        ++$counter;
        return if $state > 50;
        return $state;
    };
    return $iterator;
};

my $p1 = WebGUI::Paginator->new($session, '/neighborhood', 5);
$p1->setDataByCallback($callback);
my $pIterator = $p1->getPageIterator;
isa_ok($pIterator, 'CODE', 'getPageIterator');
is($pIterator->('rowCount'), 50, 'generated iterator returns the correct maximum number of rows');
is($p1->getNumberOfPages, 10, 'getNumberOfPages works with an iterator');

cmp_deeply(drainIterator($pIterator, 10), [2, 4, 6, 8, 10], 'setDataByCallback: iterator returned page 1 data');

$p1->setPageNumber(2);
$p1->setDataByCallback($callback);
$pIterator = $p1->getPageIterator;

cmp_deeply(drainIterator($pIterator, 10), [12, 14, 16, 18, 20], '... iterator returned page 2 data');

$expectedPages = [  map { +{ 
            'pagination.text'   => ( $_ + 1 ), 
            'pagination.range'  => ( 5 * $_ + 1 ) . "-" . ( ($_+1) * 5 ), # First row number - Last row number
            'pagination.url'    => ( $_ != 1 ? '/neighborhood' . '?pn=' . ( $_ + 1 ) : '' ), # Current page has no URL
        } } (0..9) ];

$expectedPages->[1]->{'pagination.activePage'} = 'true';

cmp_deeply(
    ($p1->getPageLinks())[0],
    $expectedPages,
    'getPageLinks works with a paginator'
);

sub drainIterator {
    my $iterator      = shift;
    my $terminalCount = shift; 
    my $pageData = [];
    my $infiniteLoopCount = 0;
    while (defined(my $item = $pIterator->())) {
        push @{ $pageData }, $item;
        last if ++$infiniteLoopCount >= $terminalCount;
    }
    return $pageData;
}
