package WebGUI::Asset::File;

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
use WebGUI::Asset;
use WebGUI::HTTP;
use WebGUI::Session;
use WebGUI::Storage;

our @ISA = qw(WebGUI::Asset);


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

=head2 definition ( definition )

Defines the properties of this asset.

=head3 definition

A hash reference passed in from a subclass definition.

=cut

sub definition {
        my $class = shift;
        my $definition = shift;
        push(@{$definition}, {
                tableName=>'FileAsset',
                className=>'WebGUI::Asset::File',
                properties=>{
                                filename=>{
                                        fieldType=>'hidden',
                                        defaultValue=>undef
                                        },
				storageId=>{
					fieldType=>'hidden',
					defaultValue=>undef
					},
				fileSize=>{
					fieldType=>'hidden',
					defaultValue=>undef
				},
				olderVersions=>{
					fieldType=>'hidden',
					defaultValue=>undef
					}
                        }
                });
        return $class->SUPER::definition($definition);
}


#-------------------------------------------------------------------

sub duplicate {
	my $self = shift;
	my $newAsset = $self->SUPER::duplicate(shift);
	my $newStorage = $self->getStorageLocation->copy;
	$newAsset->update({storageId=>$newStorage->getId,olderVersions=>''});
}


#-------------------------------------------------------------------
sub getBox {
	my $self = shift;
	my %var;
       	$var{"attachment.icon"} = $self->getFileIcon;
       	$var{"attachment.url"} = $self->getFileUrl;
       	$var{"attachment.name"} = $self->get("filename");
       	$var{"attachment.size"} = $self->getStorageLocation->getSize;
       	$var{"attachment.type"} = $self->getStorageLocation->getFileExtension;
       	return $self->processTemplate(\%var,"PBtmpl0000000000000003");
}

#-------------------------------------------------------------------

=head2 getEditForm ()

Returns the TabForm object that will be used in generating the edit page for this asset.

=cut

sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm();
	if ($self->get("filename") ne "") {
		$tabform->getTab("properties")->readOnly(
			-label=>WebGUI::International::get('current file', 'Asset'),
			-value=>'<a href="'.$self->getFileUrl.'"><img src="'.$self->getFileIconUrl.'" alt="'.$self->get("filename").'" border="0" align="middle" /> '.$self->get("filename").'</a>'
			);
		
	}
        $tabform->getTab("properties")->file(
               	-name=>"file",
		-label=>WebGUI::International::get('new file', 'Asset'),
               	);
	return $tabform;
}


#-------------------------------------------------------------------
sub getFileUrl {
	my $self = shift;
	return $self->getStorageLocation->getUrl($self->get("filename"));
}


#-------------------------------------------------------------------
sub getFileIconUrl {
	my $self = shift;
	return $self->getStorageLocation->getFileIconUrl($self->get("filename"));
}



#-------------------------------------------------------------------
sub getIcon {
	my $self = shift;
	my $small = shift;
	if ($small) {
		return $self->getFileIconUrl;	
	}
	return $session{config}{extrasURL}.'/assets/file.gif';
}


#-------------------------------------------------------------------

=head2 getName 

Returns the displayable name of this asset.

=cut

sub getName {
	return "File";
} 


#-------------------------------------------------------------------
sub getStorageLocation {
	my $self = shift;
	unless (exists $self->{_storageLocation}) {
		if ($self->get("storageId") eq "") {
			$self->{_storageLocation} = WebGUI::Storage->create;
			$self->update({storageId=>$self->{_storageLocation}->getId});
		} else {
			$self->{_storageLocation} = WebGUI::Storage->get($self->get("storageId"));
		}
	}
	return $self->{_storageLocation};
}


#-------------------------------------------------------------------
sub processPropertiesFromFormPost {
	my $self = shift;
	$self->SUPER::processPropertiesFromFormPost;
	my $storage = $self->getStorageLocation->create;
	my $filename = $storage->addFileFromFormPost("file");
	if (defined $filename) {
		my $oldVersions;
		if ($self->get("filename")) { # do file versioning
			my @old = split("\n",$self->get("olderVersions"));
			push(@old,$self->get("storageId")."|".$self->get("filename"));
			$oldVersions = join("\n",@old);
		}
		my %data;
		$data{filename} = $filename;
		$data{storageId} = $storage->getId;
		$data{olderVersions} = $oldVersions;
		$data{title} = $filename unless ($session{form}{title});
		$data{menuTitle} = $filename unless ($session{form}{menuTitle});
		$data{url} = $self->getParent->getUrl.'/'.$filename unless ($session{form}{url});
		$self->update(\%data);
		$self->setSize($storage->getFileSize($filename));
		$storage->setPrivileges($self->get("ownerUserId"), $self->get("groupIdView"), $self->get("groupIdEdit"));
		$self->{_storageLocation} = $storage;
	} else {
		$storage->delete;
		$self->getStorageLocation->setPrivileges($self->get("ownerUserId"), $self->get("groupIdView"), $self->get("groupIdEdit"));
	}
}


#-------------------------------------------------------------------

=head2 purge

=cut

sub purge {
	my $self = shift;
	my @old = split("\n",$self->get("olderVersions"));
	foreach my $oldone (@old) {
		my ($storageId, $filename) = split("|",$oldone);
		$self->getStorageLocation->delete;
	}
	$self->getStorageLocation->delete;
	return $self->SUPER::purge;
}


#-------------------------------------------------------------------
sub view {
	my $self = shift;
	my %var = %{$self->get};
	$var{controls} = $self->getToolbar;
	$var{fileUrl} = $self->getFileUrl;
	$var{fileIcon} = $self->getFileIconUrl;
	return $self->processTemplate(\%var,"PBtmpl0000000000000024");
}


#-------------------------------------------------------------------
sub www_edit {
        my $self = shift;
        return WebGUI::Privilege::insufficient() unless $self->canEdit;
        return $self->getAdminConsole->render($self->getEditForm->print,"Edit File");
}


sub www_view {
	my $self = shift;
	return WebGUI::Privilege::noAccess() unless $self->canView;
	if ($session{var}{adminOn}) {
		return $self->www_edit;
	}
	WebGUI::HTTP::setRedirect($self->getFileUrl);
	return "";
}


1;

