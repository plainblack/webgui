#!/usr/bin/perl

use lib "../../lib";
use Getopt::Long;
use strict;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Asset;
use WebGUI::Asset::Wobject::Folder;

my $configFile;
my $quiet;

GetOptions(
    'configFile=s'=>\$configFile,
	'quiet'=>\$quiet
);

WebGUI::Session::open("../..",$configFile);

#--------------------------------------------
print "\tSorting templates under the Import Node into folders by namespace.\n" unless ($quiet);
my ($templateFolder) = WebGUI::SQL->quickArray("select assetId from asset where parentId='PBasset000000000000002' and className='WebGUI::Asset::Wobject::Folder' and title='Templates' limit 1");
my $namespacesQuery = "select distinct template.namespace from asset, template where asset.parentId='".$templateFolder."' and asset.assetId=template.assetId and asset.className='WebGUI::Asset::Template' order by template.namespace";
my $parent = WebGUI::Asset->new($templateFolder);
my $sth = WebGUI::SQL->read($namespacesQuery);
my $folder;
while (my $namespace = $sth->hashRef) {
	#create a folder for each namespace
	print "\t\tMoving ".$namespace->{namespace}." Templates.\n" unless ($quiet);
	my $newUrl = lc('templates/'.$namespace->{namespace});
	$folder = $parent->addChild({
		className=>"WebGUI::Asset::Wobject::Folder",
		title=>$namespace->{namespace},
		isHidden=>1,
		menuTitle=>$namespace->{namespace},
		url=>$newUrl,
		description=>$namespace,
		templateId=>'PBtmpl0000000000000078',
		styleTemplateId=>'PBtmpl0000000000000060',
		printableStyleTemplateId=>'PBtmpl0000000000000111',
		groupIdView=>'4',
		groupIdEdit=>'3',
		description=>''
	});
	my $templatesquery = "select * from asset, template where asset.parentId='".$templateFolder."' and asset.assetId=template.assetId and asset.className='WebGUI::Asset::Template' and template.namespace='".$namespace->{namespace}."' order by title asc";
	my $newParentId = $folder->getId;
	my $sth2 = WebGUI::SQL->read($templatesquery);
	my $first = 1;
	while (my $template = $sth2->hashRef) {
		print "\t\t\tMoving ".$template->{title}." to Templates/".$namespace->{namespace}."\n" unless ($quiet);
		my $newLineage = getNextLineage($newParentId);
		my $templateAssetId = $template->{assetId};
		my $templateObject = WebGUI::Asset->new($templateAssetId);
		my $newUrl2 = $newUrl.$templateObject->getUrl;
		my $result = WebGUI::SQL->write("update asset set lineage='$newLineage', parentId='$newParentId', url='$newUrl2' where assetId='$templateAssetId'");
	}
	$sth2->finish;
}
$sth->finish;

#Lock down permissions on viewing templates.  There's no reason "everyone"
#should be allowed to view them if the www_view method returns the parent 
#container anyway...!
WebGUI::SQL->write("update asset set groupIdView='4' where className='WebGUI::Asset::Template'");

WebGUI::Session::close();


sub getNextLineage {
	my $assetId = shift;
	my ($startLineage) = WebGUI::SQL->quickArray("select lineage from asset where parentId='".$assetId."' order by lineage desc limit 1");
	my $asset=WebGUI::Asset->new($assetId);
	my $depth=length($asset->get("lineage"));
	unless ($startLineage) {
		#return lineage of first unborn child.
		my ($parentLineage) = WebGUI::SQL->quickArray("select lineage from asset where assetId='".$assetId."'");
		return $parentLineage.'000001';
	}
	#return lineage of next unborn child.
	my $rank = substr($startLineage,$depth,6);
	my $parentLineage = substr($startLineage,0,$depth);
	return $parentLineage.sprintf("%06d",($rank+1));
}