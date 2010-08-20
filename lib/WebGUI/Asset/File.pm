package WebGUI::Asset::File;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use Carp;

use Number::Format ();
use Moose;
use WebGUI::Definition::Asset;
extends 'WebGUI::Asset';

define assetName => ['assetName', 'Asset_File'];
define tableName => 'FileAsset';
property cacheTimeout => (
                tab       => "display",
                fieldType => "interval",
                default   => 3600,
                uiLevel   => 8,
                label     => ["cache timeout", 'Asset_File'],
                hoverHelp => ["cache timeout help", 'Asset_File'],
         );
property filename => (
                noFormPost => 1,
                fieldType  => 'hidden',
                default    => '',
         );
property storageId => (
                noFormPost => 1,
                fieldType  => 'hidden',
                default    => '',
                trigger    => \&_set_storageId,
         );
sub _set_storageId {
    my ($self, $new, $old) = @_;
    if ($new ne $old) {
		$self->setStorageLocation;
    }
}
property templateId => (
                fieldType => 'template',
                default   => 'PBtmpl0000000000000024',
                label     => ['file template', 'Asset_File'],
                hoverHelp => ['file template description', 'Asset_File'],
                namespace => "FileAsset",
                tab       => 'display',
         );

with 'WebGUI::Role::Asset::SetStoragePermissions';

use WebGUI::Storage;
use WebGUI::SQL;
use WebGUI::Utility;


=head1 NAME

Package WebGUI::Asset::File

=head1 DESCRIPTION

Provides a mechanism to upload files to WebGUI.

=head1 SYNOPSIS

use WebGUI::Asset::File;


=head1 METHODS

These methods are available from this class:

=cut



#-------------------------------------------------------------------

=head2 addRevision

Override the default method in order to deal with attachments.

=cut

override addRevision => sub {
    my $self    = shift;
    my $newSelf = super();

    if ($newSelf->storageId && $newSelf->storageId eq $self->storageId) {
        my $newStorage = $self->getStorageClass->get($self->session, $self->storageId)->copy;
        $newSelf->update({storageId => $newStorage->getId});
        $newSelf->applyConstraints;
    }

    return $newSelf;
};

#-------------------------------------------------------------------

=head2 applyConstraints ( options )

Enforce certain things when new files are uploaded.

=head3 options

A hash reference of optional parameters. None at this time.

=cut

sub applyConstraints {
    my $self = shift;
    $self->setPrivileges;
    $self->setSize;
}

sub setPrivileges {
    my $self = shift;
    $self->getStorageLocation->setPrivileges(
        $self->ownerUserId,
        $self->groupIdView,
        $self->groupIdEdit,
    );
}


#-------------------------------------------------------------------

=head2 duplicate 

Extend the master method to duplicate the storage location.

=cut

override duplicate => sub {
	my $self = shift;
	my $newAsset = super();
	my $newStorage = $self->getStorageLocation->copy;
	$newAsset->update({storageId=>$newStorage->getId});
	return $newAsset;
};


#-------------------------------------------------------------------

=head2 exportAssetData ( )

See WebGUI::AssetPackage::exportAssetData() for details.

=cut

override exportAssetData => sub {
	my $self = shift;
	my $data = super();
	push(@{$data->{storage}}, $self->storageId) if ($self->storageId ne "");
	return $data;
};

#-------------------------------------------------------------------

=head2 exportWriteFile 

Places a copy of the file from storage into the right location during an export.

=cut

sub exportWriteFile {
    my $self = shift;

    # we have no assurance whether the exportPath is valid or not, so check it.
    WebGUI::Asset->exportCheckPath($self->session);

    # if we're still here, everything is well with the export path. let's make
    # sure that this user can view the asset that we want to export.
    unless($self->canView) {
        WebGUI::Error->throw(error => "user can't view asset at " .  $self->getUrl . " to export it");
    }

    # if we're still here, everything is well with the export path. let's get
    # our destination FS path and then make any required directories.

    my $dest = $self->exportGetUrlAsPath;
    my $parent = $dest->parent;

    eval { File::Path::mkpath($parent->absolute->stringify) };
    if($@) {
        WebGUI::Error->throw(error => "could not make directory " . $parent->absolute->stringify);
    }

    if ( ! File::Copy::copy($self->getStorageLocation->getPath($self->filename), $dest->stringify) ) {
        WebGUI::Error->throw(error => "can't copy " . $self->getStorageLocation->getPath($self->filename)
            . ' to ' . $dest->absolute->stringify . ": $!");
    }
}

#-------------------------------------------------------------------

=head2 getEditForm ( )

Returns the TabForm object that will be used in generating the edit page for this asset.

=cut

override getEditForm => sub {
    my $self        = shift;
    my $f           = super();
    my $i18n        = WebGUI::International->new($self->session, 'Asset_File');

    # Add field to upload file
    if ($self->filename ne "") {
        $f->getTab("properties")->addField( 
            "ReadOnly", 
            name        => "viewFile",
            value       => '<p style="display:inline;vertical-align:middle;"><a href="'.$self->getFileUrl.'"><img src="'.$self->getFileIconUrl.'" alt="'.$self->filename.'" style="border-style:none;vertical-align:middle;" /> '.$self->filename.'</a></p>',
        );
    }

    $f->getTab( "properties" )->addField( 
        "File", 
        name        => 'newFile',
        label       => $i18n->get('new file'),
        hoverHelp   => $i18n->get('new file description'),
    );

    return $f;
};

#-------------------------------------------------------------------

=head2 getFileUrl 

Returns the URL for the file stored in the storage location.

=cut

sub getFileUrl {
	my $self = shift;
	#return $self->get("url");
	return $self->getStorageLocation->getUrl($self->filename);
}

#-------------------------------------------------------------------

=head2 getFileIconUrl 

Returns the icon for the file stored in the storage location.  If there's no
file, then it returns undef.

=cut

sub getFileIconUrl {
    my $self = shift;
    return undef unless $self->filename; ## Why do I have to do this when creating new Files?
    return $self->getStorageLocation->getFileIconUrl($self->filename);
}



#-------------------------------------------------------------------

=head2 getIcon ($small)

Return an icon indicating what type of file this is.  If the $small flag is set,
then the icon returned is a file type icon, rather than an asset icon.

=head3 $small

Indicates that a small icon should be returned.

=cut

sub getIcon {
	my $self = shift;
	my $small = shift;
	if ($small && $self->get("dummy")) {
		return $self->session->url->extras('assets/small/file.gif');
	} elsif ($small) {
		return $self->getFileIconUrl;	
	}
	return $self->session->url->extras('assets/file.gif');
}


#----------------------------------------------------------------------------

=head2 getStorageClass

Get the full classname of the WebGUI::Storage we should use for this asset.

=cut

sub getStorageClass {
    return 'WebGUI::Storage';
}

#-------------------------------------------------------------------

=head2 getStorageFromPost

Get the storage location created by the form post.

=cut

sub getStorageFromPost {
    my $self      = shift;
    my $storageId = shift;
    my $fileStorageId = WebGUI::Form::File->new($self->session, {name => 'newFile', value=>$storageId })->getValue;
    $self->session->errorHandler->info( "File Storage Id: $fileStorageId" );
    return $self->getStorageClass->get($self->session, $fileStorageId);
}


#-------------------------------------------------------------------

=head2 getStorageLocation 

Returns the storage location for this asset.  If one does not exist, then it
is created.

=cut

sub getStorageLocation {
	my $self = shift;
	unless (exists $self->{_storageLocation}) {
		$self->setStorageLocation;
	}
	return $self->{_storageLocation};
}


#-------------------------------------------------------------------

=head2 indexContent ( )

Indexing the content of the attachment. See WebGUI::Asset::indexContent() for additonal details. 

=cut

around indexContent => sub {
	my $orig = shift;
	my $self = shift;
	my $indexer = $self->$orig(@_);
	$indexer->addFile($self->getStorageLocation->getPath($self->filename));
    return $indexer;
};


#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

override prepareView => sub {
	my $self = shift;
	super();
	my $template = WebGUI::Asset::Template->newById($self->session, $self->templateId);
	$template->prepare($self->getMetaDataAsTemplateVariables);
	$self->{_viewTemplate} = $template;
};


#-------------------------------------------------------------------

=head2 processEditForm 

Extend the master method to handle file uploads and applying constraints.

=cut

override processEditForm => sub {
    my $self    = shift;
    my $session = $self->session;

    my $errors  = super() || [];
    return $errors if @$errors;

    if (my $storageId = $session->form->get('newFile','File')) {
        $session->errorHandler->info("Got a new file for asset " . $self->getId);
        my $storage     = $self->getStorageClass->get( $session, $storageId);
        my $filePath    = $storage->getPath( $storage->getFiles->[0] );
        $self->setFile( $filePath );
        $storage->delete;
    }
    else {
        $self->applyConstraints;
    }

    return undef;
};


#-------------------------------------------------------------------

=head2 purge 

Extends the master method to delete all storage locations associated with this asset.

=cut

override purge => sub {
	my $self = shift;
	my $sth = $self->session->db->read("select storageId from FileAsset where assetId=".$self->session->db->quote($self->getId));
	while (my ($storageId) = $sth->array) {
		$self->getStorageClass->get($self->session,$storageId)->delete;
	}
	$sth->finish;
	return super();
};

#-------------------------------------------------------------------

=head2 purgeCache ( )

Extends the master method to clear the view cache.

=cut

override purgeCache => sub {
	my $self = shift;
	$self->session->cache->remove("view_".$self->getId);
	super();
};

#-------------------------------------------------------------------

=head2 purgeRevision 

Extends the master method to delete the storage location for this asset.

=cut

override purgeRevision => sub {
	my $self = shift;
	$self->getStorageLocation->delete;
	return super();
};

#----------------------------------------------------------------------------

=head2 setFile ( [pathtofile] )

Tells the asset to do all the postprocessing on the file (setting privs, thubnails, or whatever).

=head3 pathtofile

If specified will copy a new file into the storage location from this path and delete any existing file.


=cut

sub setFile {
    my $self        = shift;
    my $filename    = shift;

	if ($filename) {
	    my $storage     = $self->getStorageLocation;
		# Clear the old file if any
		$storage->clear;
	
		$storage->addFileFromFilesystem($filename) 
			|| croak "Couldn't setFile: " . join(", ",@{ $storage->getErrors });
			# NOTE: We should not croak here, the WebGUI::Storage should croak for us.
			
	}

    $self->updatePropertiesFromStorage;
    $self->applyConstraints;
}

#-------------------------------------------------------------------

=head2 setSize ( fileSize )

Set the size of this asset by including all the files in its storage
location. C<fileSize> is an integer of additional bytes to include in
the asset size.

=cut

around setSize => sub {
    my $orig        = shift;
    my $self        = shift;
    my $fileSize    = shift || 0;
    my $storage     = $self->getStorageLocation;
    if (defined $storage) {	
        foreach my $file (@{$storage->getFiles}) {
            $fileSize += $storage->getFileSize($file);
        }
    }
    return $self->$orig($fileSize);
};

#-------------------------------------------------------------------

=head2 setStorageLocation ($storage)

Updates the locally cached storage location.  If this asset does not have a
storage location, then one is created.  Otherwise, the storage location's storageId
is fetched from the db and used to create a storage location which is then placed
in the local object cache.

=head3 $storage

If defined, the locally cached storage location is set to this object.

=cut

sub setStorageLocation {
    my $self    = shift;
    my $storage = shift;
    if (defined $storage) {
        $self->{_storageLocation} = $storage;
    }
    elsif ($self->get("storageId") eq "") {
        $self->{_storageLocation} = $self->getStorageClass->create($self->session);
        $self->update({storageId=>$self->{_storageLocation}->getId});
    }
    else {
        $self->{_storageLocation} = $self->getStorageClass->get($self->session,$self->storageId);
    }
}

#----------------------------------------------------------------------------

=head2 updatePropertiesFromStorage ( )

Updates the asset properties from the file tracked by this asset. Should be
called every time the file is changed to ensure the correct filename is
in the asset properties.

=cut

sub updatePropertiesFromStorage {
    my $self        = shift;
    my $storage     = $self->getStorageLocation; 
    my $filename    = $storage->getFiles->[0];
    $self->session->errorHandler->info("Updating file asset filename to $filename");
    $self->update({
        filename        => $filename,
    });
    return undef;
}

#-------------------------------------------------------------------

=head2 view 

Generate the view method for the Asset, and handle caching.

=cut

sub view {
	my $self = shift;
	if (!$self->session->var->isAdminOn && $self->get("cacheTimeout") > 10) {
		my $out = $self->session->cache->get($self->getViewCacheKey);
		return $out if $out;
	}
	my %var = %{$self->get};
	$var{controls} = $self->getToolbar;
	$var{fileUrl} = $self->getFileUrl;
	$var{fileIcon} = $self->getFileIconUrl;
	$var{fileSize} = Number::Format::format_bytes($self->get("assetSize"));
    my $out = $self->processTemplate(\%var,undef,$self->{_viewTemplate});
	if (!$self->session->var->isAdminOn && $self->get("cacheTimeout") > 10) {
		$self->session->cache->set($self->getViewCacheKey, $out, $self->get("cacheTimeout"));
	}
    return $out;
}


#-------------------------------------------------------------------

=head2 www_edit 

Display the edit form to the user.  Manually handles the template for displaying
the inline view of the asset.

=cut

sub www_edit {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	return $self->session->privilege->locked() unless $self->canEditIfLocked;
	my $i18n = WebGUI::International->new($self->session);
	my $f = $self->getEditForm;
	return $self->getAdminConsole->render($f->print,$self->addEditLabel);
}

#-------------------------------------------------------------------

=head2 www_view 

When viewed directly, stream the stored file to the user.

=cut

sub www_view {
	my $self    = shift;
    my $session = $self->session;
	return $session->privilege->noAccess() unless $self->canView;

	# Check to make sure it's not in the trash or some other weird place
	if ($self->state ne "published") {
		my $i18n = WebGUI::International->new($session,'Asset_File');
		$session->http->setStatus(404);
		return sprintf($i18n->get("file not found"), $self->getUrl());
	}

    $session->http->setRedirect($self->getFileUrl) unless $session->config->get('enableStreamingUploads');
    $session->http->setStreamedFile($self->getStorageLocation->getPath($self->filename));
    $session->http->sendHeader;
    return 'chunked';
}

__PACKAGE__->meta->make_immutable;
1;
