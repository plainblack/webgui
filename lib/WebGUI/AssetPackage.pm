package WebGUI::Asset;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2008 Plain Black Corporation.
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
		$storage->addFileFromScalar($data->{properties}{lineage}.".json", JSON->new->pretty->encode($data));
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
    my $self        = shift;
    my $data        = shift;
    my $error       = $self->session->errorHandler;
    my $id          = $data->{properties}{assetId};
    my $class       = $data->{properties}{className};
    my $version     = $data->{properties}{revisionDate};

    # Load the class
    WebGUI::Asset->loadModule( $self->session, $class );

    my $asset;
    my $revisionExists = WebGUI::Asset->assetExists($self->session, $id, $class, $version);
    if ($revisionExists) { # update an existing revision
        $asset = WebGUI::Asset->new($self->session, $id, $class, $version);
        $error->info("Updating an existing revision of asset $id");	
        $asset->update($data->{properties});
        ##Pending assets are assigned a new version tag
        if ($data->{properties}->{status} eq 'pending') {
            $self->session->db->write(
                'update assetData set tagId=? where assetId=? and revisionDate='.$data->{properties}->{revisionDate},
                [WebGUI::VersionTag->getWorking($self->session)->getId, $data->{properties}->{assetId}]
            );
        }
    }
    else {
        eval {
            $asset = WebGUI::Asset->newPending($self->session, $id, $class);
        };
        if (defined $asset) {   # create a new revision of an existing asset
            $error->info("Creating a new revision of asset $id");
            $asset = $asset->addRevision($data->{properties}, $version, {skipAutoCommitWorkflows => 1});
        }
        else {  # add an entirely new asset
            $error->info("Adding $id that didn't previously exist.");
            $asset = $self->addChild($data->{properties}, $id, $version, {skipAutoCommitWorkflows => 1});
        }
    }

    # If the asset is in the trash, re-publish it
    if ( $asset->isInTrash ) {
        $asset->publish;
    }

    return $asset;
}

#-------------------------------------------------------------------

=head2 importAssetCollateralData ( data )

Allows you to import collateral data that is exported with your asset. 

=head3 data

Hashref containing the assets exported data.

=cut

sub importAssetCollateralData {
    # This is an interface method only. It is to be overloaded if needed.
}

#-------------------------------------------------------------------

=head2 importPackage ( storageLocation )

Imports the data from a webgui package file.

=head3 storageLocation

A reference to a WebGUI::Storage object that contains a webgui package file.

=cut

sub importPackage {
    my $self            = shift;
    my $storage         = shift;
    my $decompressed    = $storage->untar($storage->getFiles->[0]);
    return undef
        if $storage->getErrorCount;
    my %assets          = ();               # All the assets we've imported
    my $package         = undef;            # The asset package
    my $error           = $self->session->errorHandler;
    $error->info("Importing package.");
    foreach my $file (sort(@{$decompressed->getFiles})) {
        next unless ($decompressed->getFileExtension($file) eq "json");
        $error->info("Found data file $file");
        my $data = eval{
            JSON->new->relaxed(1)->decode($decompressed->getFileContentsAsScalar($file))
        };
        if ($@ || $data->{properties}{assetId} eq "" || $data->{properties}{className} eq "" || $data->{properties}{revisionDate} eq "") {
            $error->error("package corruption: ".$@) if ($@);
            return "corrupt";
        }
        $error->info("Data file $file is valid and represents asset ".$data->{properties}{assetId});
        foreach my $storageId (@{$data->{storage}}) {
            my $assetStorage = WebGUI::Storage->get($self->session, $storageId);
            $decompressed->untar($storageId.".storage", $assetStorage);
        }
        my $asset = $assets{$data->{properties}{parentId}} || $self;
        my $newAsset = $asset->importAssetData($data);
        $newAsset->importAssetCollateralData($data);
        $assets{$newAsset->getId} = $newAsset;
        # First imported asset must be the "package"

        unless ($package) {
            $package            = $newAsset;
        }
    }

    return $package
        if $package;
    return 'corrupt';
}

#-------------------------------------------------------------------

=head2 www_deployPackage ( ) 

Deploys the package referenced by the query parameter 'assetId' as a
new child of the current asset.  Requires edit privileges on the
current asset.

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
		 	return undef;
		}
		my $masterLineage = $packageMasterAsset->get("lineage");
                if (defined $packageMasterAsset && $packageMasterAsset->canView && $self->get("lineage") !~ /^$masterLineage/) {
			my $deployedTreeMaster = $packageMasterAsset->duplicateBranch;
			$deployedTreeMaster->setParent($self);
			$deployedTreeMaster->update({isPackage=>0, styleTemplateId=>$self->get("styleTemplateId")});
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

	##This is a hack.  It should use the WebGUI::Form::File API to insulate
	##us from future form name changes.
	$storage->addFileFromFormPost("packageFile",1);

	my $error = "";
	if ($storage->getFileExtension($storage->getFiles->[0]) eq "wgpkg") {
		$error = $self->importPackage($storage);
	}
	if (!blessed $error) {
		my $i18n = WebGUI::International->new($self->session, "Asset");
        if ($error eq 'corrupt') {
            return $self->session->style->userStyle($i18n->get("package corrupt"));
        }
        else {
            return $self->session->style->userStyle($i18n->get("package extract error"));
        }
	}
    # Handle autocommit workflows
    if ($self->session->setting->get("autoRequestCommit")) {
        if ($self->session->setting->get("skipCommitComments")) {
            WebGUI::VersionTag->getWorking($self->session)->requestCommit;
        } 
        else {
            $self->session->http->setRedirect($self->getUrl("op=commitVersionTag;tagId=".WebGUI::VersionTag->getWorking($self->session)->getId));
            return undef;
        }
    }

    return $self->www_manageAssets();
}

1;

