package WebGUI::Asset::File;

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
use WebGUI::Asset;
use WebGUI::Storage;
use WebGUI::SQL;

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

=head2 addRevision

Override the default method in order to deal with attachments.

=cut

sub addRevision {
	my $self = shift;
	my $newSelf = $self->SUPER::addRevision(@_);
	if ($self->get("storageId")) {
		my $newStorage = WebGUI::Storage->get($self->session,$self->get("storageId"))->copy;
		$newSelf->update({storageId=>$newStorage->getId});
	}
	return $newSelf;
}

#-------------------------------------------------------------------

=head2 definition ( definition )

Defines the properties of this asset.

=head3 definition

A hash reference passed in from a subclass definition.

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my $i18n = WebGUI::International->new($session,"Asset_File");
	push(@{$definition}, {
		assetName=>$i18n->get('assetName'),
		tableName=>'FileAsset',
		className=>'WebGUI::Asset::File',
		properties=>{
			filename=>{
				noFormPost=>1,
				fieldType=>'hidden',
				defaultValue=>undef
			},
			storageId=>{
				noFormPost=>1,
				fieldType=>'hidden',
				defaultValue=>undef
			},
			templateId=>{
				fieldType=>'template',
				defaultValue=>'PBtmpl0000000000000024'
			}
		}
	});
	return $class->SUPER::definition($session, $definition);
}


#-------------------------------------------------------------------

sub duplicate {
	my $self = shift;
	my $newAsset = $self->SUPER::duplicate(shift);
	my $newStorage = $self->getStorageLocation->copy;
	$newAsset->update({storageId=>$newStorage->getId});
	return $newAsset;
}


#-------------------------------------------------------------------
sub getBox {
	my $self = shift;
	my $var = {};
       	return $self->processTemplate($var,"PBtmpl0000000000000003");
}

#-------------------------------------------------------------------

=head2 getEditForm ()

Returns the TabForm object that will be used in generating the edit page for this asset.

=cut

sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm();
	my $i18n = WebGUI::International->new($self->session, 'Asset_File');
	if ($self->get("filename") ne "") {
		$tabform->getTab("properties")->readOnly(
			-label=>$i18n->get('current file'),
			-hoverHelp=>$i18n->get('current file description', 'Asset_File'),
			-value=>'<a href="'.$self->getFileUrl.'"><img src="'.$self->getFileIconUrl.'" alt="'.$self->get("filename").'" border="0" align="middle" /> '.$self->get("filename").'</a>'
		);

	}
	$tabform->getTab("properties")->file(
		-label=>$i18n->get('new file'),
		-hoverHelp=>$i18n->get('new file description'),
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
	if ($small && $self->get("dummy")) {
		return $self->session->config->get("extrasURL").'/assets/small/file.gif';
	} elsif ($small) {
		return $self->getFileIconUrl;	
	}
	return $self->session->config->get("extrasURL").'/assets/file.gif';
}


#-------------------------------------------------------------------
sub getStorageLocation {
	my $self = shift;
	unless (exists $self->{_storageLocation}) {
		if ($self->get("storageId") eq "") {
			$self->{_storageLocation} = WebGUI::Storage->create($self->session);
			$self->update({storageId=>$self->{_storageLocation}->getId});
		} else {
			$self->{_storageLocation} = WebGUI::Storage->get($self->session,$self->get("storageId"));
		}
	}
	return $self->{_storageLocation};
}


#-------------------------------------------------------------------

=head2 indexContent ( )

Indexing the content of the attachment. See WebGUI::Asset::indexContent() for additonal details. 

=cut

sub indexContent {
	my $self = shift;
	my $indexer = $self->SUPER::indexContent;
	$indexer->addFile($self->getStorageLocation->getPath($self->get("filename")));
}


#-------------------------------------------------------------------
sub processPropertiesFromFormPost {
	my $self = shift;
	$self->SUPER::processPropertiesFromFormPost;
	delete $self->{_storageLocation};
	my $storage = $self->getStorageLocation;
	my $filename = $storage->addFileFromFormPost("file",1);
	if (defined $filename && $filename ne $self->get("filename")) {
		my %data;
		$data{filename} = $filename;
		$data{storageId} = $storage->getId;
		$data{title} = $filename unless ($self->session->form->process("title"));
		$data{menuTitle} = $filename unless ($self->session->form->process("menuTitle"));
		$data{url} = $self->getParent->get('url').'/'.$filename unless ($self->session->form->process("url"));
		$self->update(\%data);
	}
}


#-------------------------------------------------------------------

sub purge {
	my $self = shift;
	my $sth = $self->session->db->read("select storageId from FileAsset where assetId=".$self->session->db->quote($self->getId));
	while (my ($storageId) = $sth->array) {
		WebGUI::Storage->get($self->session,$storageId)->delete;
	}
	$sth->finish;
	return $self->SUPER::purge;
}

#-------------------------------------------------------------------

sub purgeRevision {
	my $self = shift;
	$self->getStorageLocation->delete;
	return $self->SUPER::purgeRevision;
}

#-------------------------------------------------------------------
sub setSize {
	my $self = shift;
	my $fileSize = shift || 0;
	my $storage = $self->getStorageLocation;
	foreach my $file (@{$storage->getFiles}) {
		$fileSize += $storage->getFileSize($file);
	}
	$self->SUPER::setSize($fileSize);
}

#-------------------------------------------------------------------

=head2 update

We override the update method from WebGUI::Asset in order to handle file system privileges.

=cut

sub update {
	my $self = shift;
	my %before = (
		owner => $self->get("ownerUserId"),
		view => $self->get("groupIdView"),
		edit => $self->get("groupIdEdit")
	);
	$self->SUPER::update(@_);
	if ($self->get("ownerUserId") ne $before{owner} || $self->get("groupIdEdit") ne $before{edit} || $self->get("groupIdView") ne $before{view}) {
		$self->getStorageLocation->setPrivileges($self->get("ownerUserId"),$self->get("groupIdView"),$self->get("groupIdEdit"));
	}
}

#-------------------------------------------------------------------
sub view {
	my $self = shift;
	my %var = %{$self->get};
	$var{controls} = $self->getToolbar;
	$var{fileUrl} = $self->getFileUrl;
	$var{fileIcon} = $self->getFileIconUrl;
	return $self->processTemplate(\%var,$self->getValue("templateId"));
}


#-------------------------------------------------------------------
sub www_edit {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	my $i18n = WebGUI::International->new($self->session);
	my $tabform = $self->getEditForm;
	$tabform->getTab("display")->template(
		-value=>$self->getValue("templateId"),
		-hoverHelp=>$i18n->get('file template description','Asset_File'),
		-namespace=>"FileAsset"
	);
	$self->getAdminConsole->setHelp("file add/edit", "Asset_File");
	my $addEdit = ($self->session->form->process("func") eq 'add') ? $i18n->get('add','Wobject') : $i18n->get('edit','Wobject');
	return $self->getAdminConsole->render($tabform->print,$addEdit.' '.$self->getName);
}

#-------------------------------------------------------------------
sub www_view {
	my $self = shift;
	return $self->session->privilege->noAccess() unless $self->canView;
	if ($self->session->var->get("adminOn")) {
		return $self->getContainer->www_view;
	}
	$self->session->http->setRedirect($self->getFileUrl);
	return "";
}


1;

