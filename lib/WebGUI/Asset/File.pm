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
		my $storage = WebGUI::Storage->new($self->get("storageId"));
		
	}
        $tabform->getTab("properties")->url(
               	-name=>"file",
               	-label=>"File To Upload"
               	);
}


#-------------------------------------------------------------------

=head2 getName 

Returns the displayable name of this asset.

=cut

sub getName {
	return "File";
} 


#-------------------------------------------------------------------

=head2 purge

=cut

sub purge {
	my $self = shift;
	my @old = split("\n",$self->get("olderVersions"));
	foreach my $oldone (@old) {
		my ($storageId, $filename) = split("|",$oldone);
		my $storage = WebGUI::Storage->new($storageId);
		$storage->delete;
	}
	my $storage = WebGUI::Storage->new($self->get("storageId"));
	$storage->delete;
	return $self->SUPER::purge;
}


#-------------------------------------------------------------------

=head2 www_editSave

Gathers data from www_edit and persists it.

=cut

sub www_editSave {
	my $self = shift;
	$self->SUPER::www_editSave();
	my $storage = WebGUI::Storage->create;
	my $filename = $storage->addFileFromFormPost("file");
	if (defined $filename) {
		my $oldVersions;
		if ($self->get($filename)) { # do file versioning
			my @old = split("\n",$self->get("olderVersions"));
			push(@old,$self->get{"storageId")."|".$self->get("filename"));
			$oldVersions = join("\n",@old);
		}
		$self->update({
			filename=>$filename,
			storageId=>$storage->getId,
			fileSize=>$storage->getFileSize,
			olderVersions=>$oldVersions
			});
	} else {
		$storage->delete;
	}
	return "";
}


#-------------------------------------------------------------------

=head2 www_view

A web executable method that redirects the user to the specified page, or displays the edit interface when admin mode is enabled.

=cut

sub www_view {
	my $self = shift;
	if ($session{var}{adminOn}) {
		return $self->www_edit;
	}
	my $storage = WebGUI::Storage->new($self->get("storageId"));
	WebGUI::HTTP::setRedirect($storage->getUrl($self->get("filename")));
	return "";
}


1;

