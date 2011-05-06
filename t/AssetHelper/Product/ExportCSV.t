
# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
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
use lib "$FindBin::Bin/lib";
use File::Slurp qw( read_file );
use File::Spec::Functions qw( catfile );
use Test::More;
use Test::Deep;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Storage;
use WebGUI::AssetHelper::Product::ExportCSV;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

my $root  = WebGUI::Test->asset;
my $class = 'WebGUI::Asset::Wobject::Shelf';
my $shelf = $root->addChild({className => $class});

my $soda = [
        {
            varSku    => 'soda-sweet',
            shortdesc => 'Sweet Soda',
            price     => 0.95,
            weight    => 0.95,
            quantity  => 500,
            variantId => $session->id->generate,
        },
    ];
my $shirts = [
        {
            varSku    => 'red-t-shirt',
            shortdesc => 'Red T-Shirt',
            price     => '5.00',
            weight    => '1.33',
            quantity  => '1000',
            variantId => $session->id->generate,
        },
        {
            varSku    => 'blue-t-shirt',
            shortdesc => 'Blue T-Shirt',
            price     => '5.25',
            weight    => '1.33',
            quantity  => '2000',
            variantId => $session->id->generate,
        },
    ];
$shelf->addChild({
        className       => 'WebGUI::Asset::Sku::Product',
        variantsJSON    => JSON->new->encode( $soda ),
        title           => 'Sweet Soda-bottled in Oregon',
        sku             => 'soda',
    });
$shelf->addChild({
        className       => 'WebGUI::Asset::Sku::Product',
        variantsJSON    => JSON->new->encode( $shirts ),
        title           => 'Shirts',
        sku             => 't-shirt',
    });
my $helper  = WebGUI::AssetHelper::Product::ExportCSV->new( 
    id => 'exportProducts',
    session => $session,
    asset => $shelf,
);
my $exportProducts  = \&WebGUI::AssetHelper::Product::ExportCSV::exportProducts;
my $process = Test::MockObject::Extends->new( WebGUI::Fork->create( $session ) );
addToCleanup( sub { $process->delete } );

$exportProducts->($process, {});
# Determine the storage location from the URL
my $status      = JSON->new->decode( $process->{delay}->() );
my ( $filePath )= $status->{ redirect } =~ m!^/uploads/(.+)$!;

my $productData = read_file catfile( $session->config->get('uploadsPath'), $filePath);
my @productData = split /\n/, $productData;
is(scalar @productData, 4, 'productData should have 4 entries, 1 header + 3 data');
is($productData[0], 'mastersku,title,varSku,shortdescription,price,weight,quantity', 'header line is okay');
@productData = map { [ WebGUI::Text::splitCSV($_) ] } @productData[1..3];
my ($sodas, $shirts) = ([], []);
foreach my $productData (@productData) {
    if ($productData->[0] eq 'soda') {
        push @{ $sodas }, $productData;
    }
    elsif ($productData->[0] eq 't-shirt') {
        push @{ $shirts }, $productData;
    }
}
is(scalar @{ $sodas },  1, 'just 1 soda');
is(scalar @{ $shirts }, 2, '2 shirts');

cmp_deeply(
    $sodas,
    [ ['soda', 'Sweet Soda-bottled in Oregon',
       'soda-sweet', 'Sweet Soda', 0.95, 0.95, 500] ],
    'soda data is okay'
);

done_testing;
#vim:ft=perl
