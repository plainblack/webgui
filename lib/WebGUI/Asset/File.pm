package WebGUI::Asset::File;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2004 Plain Black Corporation.
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
use WebGUI::Template;

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

=head2 getEditForm ()

Returns the TabForm object that will be used in generating the edit page for this asset.

=cut

sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm();
	if ($self->get("filename") ne "") {
		my $storage = WebGUI::Storage->get($self->get("storageId"));
		$tabform->getTab("properties")->readOnly(
			-label=>"Current File",
			-value=>'<a href="'.$storage->getUrl($self->get("filename")).'"><img src="'.$storage->getFileIconUrl($self->get("filename")).'" alt="'.$self->get("filename").'" border="0" align="middle" /> '.$self->get("filename").'</a>'
			);
		
	}
        $tabform->getTab("properties")->file(
               	-name=>"file",
               	-label=>"New File To Upload"
               	);
	return $tabform;
}


#-------------------------------------------------------------------
sub getIcon {
	my $self = shift;
	my $small = shift;
	if ($small) {
		my $storage = WebGUI::Storage->get($self->get("storageId"));
		return $storage->getFileIconUrl($self->get("filename"));	
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


sub processPropertiesFromFormPost {
	my $self = shift;
	$self->SUPER::processPropertiesFromFormPost;
	my $storage = WebGUI::Storage->create;
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
	} else {
		$storage->delete;
		my $storage = WebGUI::Storage->get($self->get("storageId"));
		$storage->setPrivileges($self->get("ownerUserId"), $self->get("groupIdView"), $self->get("groupIdEdit"));
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
		my $storage = WebGUI::Storage->get($storageId);
		$storage->delete;
	}
	my $storage = WebGUI::Storage->get($self->get("storageId"));
	$storage->delete;
	return $self->SUPER::purge;
}


sub view {
	my $self = shift;
	my $storage = WebGUI::Storage->get($self->get("storageId"));
	my %var = %{$self->get};
	$var{controls} = $self->getToolbar;
	$var{fileUrl} = $storage->getUrl($self->get("filename"));
	$var{fileIcon} = $storage->getFileIconUrl($self->get("filename"));
	return WebGUI::Template::process("1","FileAsset",\%var);
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
	my $storage = WebGUI::Storage->get($self->get("storageId"));
	WebGUI::HTTP::setRedirect($storage->getUrl($self->get("filename")));
	return "";
}


1;

