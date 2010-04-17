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
use WebGUI::Session;
use WebGUI::Storage;
use Data::Dumper;
use WebGUI::Macro::FileUrl;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;
my $i18n = WebGUI::International->new($session, 'Macro_FileUrl');

##Add more Asset configurations here.  Each Asset is created and a reference
##is put into the "asset" key of the hash.
##The URL for the file the Asset contains is calculated and put
##in the "fileUrl" key of the hash.

my @testSets = (
	{
		comment => 'File Asset works with FileUrl',
		className => 'WebGUI::Asset::File',
		#          '1234567890123456789012'
		assetId => 'FileAsset00110011abc-e',
		title => 'Test File Asset',
		url => 'fileurltest-file',
		description => 'Test File Asset for the FileUrl macro test',
		pass => 1,
	},
	{
		comment => 'Image Asset works with FileUrl',
		className => 'WebGUI::Asset::File::Image',
		#          '1234567890123456789012'
		assetId => 'ImageAsset0110011abc-e',
		title => 'Test Image Asset',
		url => 'fileurltest-image',
		description => 'Test Image Asset for the FileUrl macro test',
		pass => 1,
	},
	{
		comment => 'ZipArchive Asset works with FileUrl',
		className => 'WebGUI::Asset::File::ZipArchive',
		#          '1234567890123456789012'
		assetId => 'ZipArchive0110011ZYWXV',
		title => 'Test ZipArchive Asset',
		url => 'fileurltest-ziparchive',
		description => 'Test ZipArchive Asset for the FileUrl macro test',
		pass => 1,
	},
	{
		comment => 'Snippet Asset does not store files',
		className => 'WebGUI::Asset::Snippet',
		#          '1234567890123456789012'
		assetId => 'SnippetAsset01011abc-e',
		title => 'Test Snippet Asset',
		url => 'fileurltest-snippet',
		description => 'Test Snippet Asset for the FileUrl macro test',
		snippet => 'Test Snippet Asset for the FileUrl macro test',
		pass => 0,
		output => $i18n->get('no storage'),
	},
	{
		comment => 'Article Asset does not have a filename property',
		className => 'WebGUI::Asset::Wobject::Article',
		#          '1234567890123456789012'
		assetId => 'ArticleAsset01011abc-e',
		title => 'Test Article Asset',
		url => 'fileurltest-article',
		description => 'Test Article Asset for the FileUrl macro test',
		pass => 0,
		output => $i18n->get('no filename'),
	},
);


my $numTests = scalar @testSets;
$numTests += 1; #non-existant URL

plan tests => $numTests;

my $homeAsset = WebGUI::Asset->getDefault($session);

my @testSets = setupTest($session, $homeAsset, @testSets);

foreach my $testSet (@testSets) {
	my $output = WebGUI::Macro::FileUrl::process($session, $testSet->{url});
	if ($testSet->{pass}) {
		is($output, $testSet->{fileUrl}, $testSet->{comment});
	}
	else {
		is($output, $testSet->{output}, $testSet->{comment});
	}
}

my $output = WebGUI::Macro::FileUrl::process($session, "non-existant-url");
is($output, $i18n->get('invalid url'), "Non-existant url returns error message");

sub setupTest {
	my ($session, $homeAsset, @testSets) = @_;
	my $versionTag = WebGUI::VersionTag->getWorking($session);
	$versionTag->set({name=>"FileUrl macro test"});
	my $testNum = 0;
	foreach my $testSet (@testSets) {

		my $storage = WebGUI::Storage->create($session);
        WebGUI::Test->storagesToDelete($storage);
		my $filename = join '.', 'fileName', $testNum;
		$testSet->{filename} = $filename;

		##Store the filename in the file, just for reference.
		$storage->addFileFromScalar($filename,$filename);
		$testSet->{fileUrl} = $storage->getUrl($filename);

		my %properties = %{ $testSet };

		my $asset = $homeAsset->addChild(\%properties, $properties{assetId});
		##It is not recommended that you create the asset with the
		##storageId and filename as properties.
		$asset->update({
				storageId => $storage->getId,
				filename => $filename,
				});
		$testSet->{asset} = $asset;
		++$testNum;
	}
	$versionTag->commit;
    addToCleanup($versionTag);
	return @testSets;
}
