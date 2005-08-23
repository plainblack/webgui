package WebGUI::Asset;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2005 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use WebGUI::Session;

=head1 NAME

Package WebGUI::Asset

=head1 DESCRIPTION

This is a mixin package for WebGUI::Asset that contains all package related functions.

=head1 SYNOPSIS

 use WebGUI::Asset;

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 getPackageList ( )

Returns an array of hashes containing title, assetId, and className for all assets defined as packages.

=cut

sub getPackageList {
	my $self = shift;
	my @assets;
	my $sth = WebGUI::SQL->read("
		select 
			asset.assetId, 
			max(assetData.revisionDate),
			asset.className
		from 
			asset 
		left join 
			assetData on asset.assetId=assetData.assetId 
		where 
			assetData.isPackage=1 and
			( 
				assetData.status='approved' or
  				assetData.tagId=".quote($session{scratch}{versionTag})."
			) and
			asset.state='published'	
		group by
			assetData.assetId
		order by 
			assetData.title desc
			");
	while (my ($id, $date, $class) = $sth->array) {
		my $asset = WebGUI::Asset->new($id,$class);
		push(@assets, $asset) if ($asset->get("isPackage"));
	}
	$sth->finish;
	return \@assets;
}


#-------------------------------------------------------------------

=head2 www_deployPackage ( ) 

Returns "". Deploys a Package. If canEdit is Fales, renders an insufficient Privilege page. 

=cut

sub www_deployPackage {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	my $packageMasterAssetId = $session{form}{assetId};
	if (defined $packageMasterAssetId) {
		my $packageMasterAsset = WebGUI::Asset->newByDynamicClass($packageMasterAssetId);
		my $masterLineage = $packageMasterAsset->get("lineage");
                if (defined $packageMasterAsset && $packageMasterAsset->canView && $self->get("lineage") !~ /^$masterLineage/) {
			my $deployedTreeMaster = $self->duplicateBranch($packageMasterAsset);
			$deployedTreeMaster->update({isPackage=>0});
		}
	}
	return "";
}


1;

