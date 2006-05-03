package WebGUI::Asset;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use JSON;
use WebGUI::Storage;

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

=head2 exportAssetData ( )

Converts all the properties of this asset into a hash reference and then returns the hash reference. This method should be expanded upon by sub classes that have more data than just asset property data. Two nodes will be created: "properties" and "storage". Properties is a hash reference of the asset properties. Storage is an array reference of storage location ids. Storage will initially be empty, but if you have storage locations you want to include in this, then please push their ids onto this list when you override this method.

=cut

sub exportAssetData {
	my $self = shift;
	my %data = %{$self->get};
	my %hash = ( properties => \%data, storage=>[] );
	return \%hash;
}

#-------------------------------------------------------------------

=head2 exportPackage ( )

Turns this package into a package file and returns the storage location object of the package file.

=cut

sub exportPackage {
	my $self = shift;
	my $storage = WebGUI::Storage->createTemp($self->session);
	foreach my $asset (@{$self->getLineage(["self","descendants"],{returnObjects=>1})}) {
		my $data = $asset->exportAssetData;
		$storage->addFileFromScalar($data->{properties}{lineage}.".json", JSON::objToJson($data,{pretty => 1, indent => 4, autoconv=>0, skipinvalid=>1}));
		foreach my $storageId (@{$data->{storage}}) {
			my $assetStorage = WebGUI::Storage->get($self->session, $storageId);
			$assetStorage->tar($storageId.".storage", $storage);
		}
	}
	my $filename = $self->get("url").".wgpkg";
	$filename =~ s/\//_/g;
	return $storage->tar($filename);
}	

#-------------------------------------------------------------------

=head2 getPackageList ( )

Returns an array of hashes containing title, assetId, and className for all assets defined as packages.

=cut

sub getPackageList {
	my $self = shift;
	my @assets;
	my $sql = "
		select 
			asset.assetId, 
			assetData.revisionDate,
			asset.className
		from 
			asset 
		left join 
			assetData on asset.assetId=assetData.assetId 
		where 
			assetData.isPackage=1
			and assetData.revisionDate=(SELECT max(revisionDate) from assetData where assetData.assetId=asset.assetId and
				(assetData.status='approved'";
			$sql .= " or assetData.tagId=".$self->session->db->quote($self->session->scratch->get("versionTag")) if ($self->session->scratch->get("versionTag"));
			$sql .= ")) and asset.state='published' group by assetData.assetId order by assetData.title desc";
	my $sth = $self->session->db->read($sql);
	while (my ($id, $date, $class) = $sth->array) {
		my $asset = WebGUI::Asset->new($self->session, $id,$class);
		push(@assets, $asset) if ($asset->get("isPackage"));
	}
	$sth->finish;
	return \@assets;
}


#-------------------------------------------------------------------

=head2 importAssetData ( hashRef )

Imports the data exported by the exportAssetData method. If the asset already exists, a new revision will be created with these properties. If it doesn't exist then a child will be added to the current asset. Returns a reference to the created asset.

=head3 hashRef

A hash reference containing the exported data.

=cut

sub importAssetData {
	my $self = shift;
	my $data = shift;
	my $id = $data->{properties}{assetId};
	my $class = $data->{properties}{className};
	my $version = $data->{properties}{revisionDate};
	my $asset = WebGUI::Asset->new($self->session, $id, $class, $version);
	if (defined $asset) { # update an existing revision
		$asset->update($data->{properties});
	} else {
		$asset = WebGUI::Asset->new($self->session, $id, $class);
		if (defined $asset) { # create a new revision of an existing asset
			$asset = $asset->addRevision($data->{properties}, $version);
		} else { # add an entirely new asset
			$asset = $self->addChild($data->{properties}, $id, $version);
		}
	}
	return $asset;
}

#-------------------------------------------------------------------

=head2 importPackage ( storageLocation )

Imports the data from a webgui package file.

=head3 storageLocation

A reference to a WebGUI::Storage object that contains a webgui package file.

=cut

sub importPackage {
	my $self = shift;
	my $storage = shift;
	my $decompressed = $storage->untar($storage->getFiles->[0]);
	my %assets = ();
	foreach my $file (sort(@{$decompressed->getFiles})) {
		next unless ($decompressed->getFileExtension($file) eq "json");
		my $data = eval{JSON::jsonToObj($decompressed->getFileContentsAsScalar($file))};
		if ($@ || $data->{properties}{assetId} eq "" || $data->{properties}{className} eq "" || $data->{properties}{revisionDate} eq "") {
			$self->session->errorHandler->warn("package corruption: ".$@) if ($@);
			return "corrupt";
		}
		foreach my $storageId (@{$data->{storage}}) {
			my $assetStorage = WebGUI::Storage->get($self->session, $storageId);
			$decompressed->untar($storageId.".storage", $assetStorage);
		}
		my $asset = $assets{$data->{properties}{parentId}} || $self;
		my $newAsset = $asset->importAssetData($data);
		$assets{$newAsset->getId} = $newAsset;
	}
	return undef;
}

#-------------------------------------------------------------------

=head2 www_deployPackage ( ) 

Returns "". Deploys a Package. If canEdit is Fales, renders an insufficient Privilege page. 

=cut

sub www_deployPackage {
	my $self = shift;
	# Must have edit rights to the asset deploying the package.  Also, must be a Content Manager.
	# This protects against non content managers deploying packages using a post or similar trickery.
	return $self->session->privilege->insufficient() unless ($self->canEdit && $self->session->user->isInGroup(4));
	my $packageMasterAssetId = $self->session->form->param("assetId");
	if (defined $packageMasterAssetId) {
		my $packageMasterAsset = WebGUI::Asset->newByDynamicClass($self->session, $packageMasterAssetId);
		unless ($packageMasterAsset->getValue('isPackage')) { #only deploy packages
		 	$self->session->errorHandler->security('deploy an asset as a package which was not set as a package.');
		 	return;
		}
		my $masterLineage = $packageMasterAsset->get("lineage");
                if (defined $packageMasterAsset && $packageMasterAsset->canView && $self->get("lineage") !~ /^$masterLineage/) {
			my $deployedTreeMaster = $self->duplicateBranch($packageMasterAsset);
			$deployedTreeMaster->update({isPackage=>0});
		}
	}
	return "";
}

#-------------------------------------------------------------------

=head2 www_exportPackage ( )

Returns a tarball file for the user to download containing the package data.

=cut

sub www_exportPackage {
	my $self = shift;
	return $self->session->privilege->insufficient() unless ($self->get("isPackage") && $self->canEdit && $self->session->user->isInGroup(4));
	my $storage = $self->exportPackage;
	my $filename = $storage->getFiles->[0];
	$self->session->http->setRedirect($storage->getUrl($storage->getFiles->[0]));
	return "redirect";
}

#-------------------------------------------------------------------

=head2 www_importPackage ( )

=cut

sub www_importPackage {
	my $self = shift;
	return $self->session->privilege->insufficient() unless ($self->canEdit && $self->session->user->isInGroup(4));
	my $storage = WebGUI::Storage->createTemp($self->session);
	$storage->addFileFromFormPost("packageFile",1);
	my $error = $self->importPackage($storage) if ($storage->getFileExtension($storage->getFiles->[0]) eq "wgpkg");
	if ($error) {
		my $i18n = WebGUI::International->new($self->session, "Asset");
		return $self->session->style->userStyle($i18n->get("package corrupt"));
	}
	return $self->www_manageAssets();	
}

1;

