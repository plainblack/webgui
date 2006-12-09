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
use WebGUI::Cache;
use WebGUI::Storage;
use WebGUI::SQL;
use WebGUI::Utility;
use FileHandle;

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
			cacheTimeout => {
				tab => "display",
				fieldType => "interval",
				defaultValue => 3600,
				uiLevel => 8,
				label => $i18n->get("cache timeout"),
				hoverHelp => $i18n->get("cache timeout help")
				},
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
	my $newAsset = $self->SUPER::duplicate(@_);
	my $newStorage = $self->getStorageLocation->copy;
	$newAsset->update({storageId=>$newStorage->getId});
	return $newAsset;
}


#-------------------------------------------------------------------

=head2 exportAssetData ( )

See WebGUI::AssetPackage::exportAssetData() for details.

=cut

sub exportAssetData {
	my $self = shift;
	my $data = $self->SUPER::exportAssetData;
	push(@{$data->{storage}}, $self->get("storageId")) if ($self->get("storageId") ne "");
	return $data;
}


#-------------------------------------------------------------------

=head2 getEditForm ( )

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
			-value=>'<p style="display:inline;vertical-align:middle;"><a href="'.$self->getFileUrl.'"><img src="'.$self->getFileIconUrl.'" alt="'.$self->get("filename").'" style="border-style:none;vertical-align:middle;" /> '.$self->get("filename").'</a></p>'
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
	#return $self->get("url");
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
		return $self->session->url->extras('assets/small/file.gif');
	} elsif ($small) {
		return $self->getFileIconUrl;	
	}
	return $self->session->url->extras('assets/file.gif');
}


#-------------------------------------------------------------------

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

sub indexContent {
	my $self = shift;
	my $indexer = $self->SUPER::indexContent;
	$indexer->addFile($self->getStorageLocation->getPath($self->get("filename")));
}


#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
	my $self = shift;
	$self->SUPER::prepareView();
	my $template = WebGUI::Asset::Template->new($self->session, $self->get("templateId"));
	$template->prepare;
	$self->{_viewTemplate} = $template;
}


#-------------------------------------------------------------------
sub processPropertiesFromFormPost {
	my $self = shift;
	$self->SUPER::processPropertiesFromFormPost;
	delete $self->{_storageLocation};
	my $storage = $self->getStorageLocation;
	my $filename = $storage->addFileFromFormPost("file",1);
	$storage->setPrivileges($self->get('ownerUserId'), $self->get('groupIdView'), $self->get('groupIdEdit'));
	if (defined $filename && $filename ne $self->get("filename")) {
		my %data;
		$data{filename} = $filename;
		$data{storageId} = $storage->getId;
		$data{title} = $filename unless ($self->session->form->process("title"));
		$data{menuTitle} = $filename unless ($self->session->form->process("menuTitle"));
		$data{url} = $self->getParent->get('url').'/'.$filename unless ($self->session->form->process("url"));
		$self->update(\%data);
		$self->setSize($storage->getFileSize($filename));
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

=head2 purgeCache ( )

See WebGUI::Asset::purgeCache() for details.

=cut

sub purgeCache {
	my $self = shift;
	WebGUI::Cache->new($self->session,"view_".$self->getId)->delete;
	$self->SUPER::purgeCache;
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

sub setStorageLocation {
	my $self = shift;
	if ($self->get("storageId") eq "") {
		$self->{_storageLocation} = WebGUI::Storage->create($self->session);
		$self->update({storageId=>$self->{_storageLocation}->getId});
	} else {
		$self->{_storageLocation} = WebGUI::Storage->get($self->session,$self->get("storageId"));
	}
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
		edit => $self->get("groupIdEdit"),
		storageId => $self->get('storageId'),
	);
	$self->SUPER::update(@_);
	##update may have entered a new storageId.  Reset the cached one just in case.
	if ($self->get("storageId") ne $before{storageId}) {
		$self->setStorageLocation;
	}
	if ($self->get("ownerUserId") ne $before{owner} || $self->get("groupIdEdit") ne $before{edit} || $self->get("groupIdView") ne $before{view}) {
		$self->getStorageLocation->setPrivileges($self->get("ownerUserId"),$self->get("groupIdView"),$self->get("groupIdEdit"));
	}
}

#-------------------------------------------------------------------
sub view {
	my $self = shift;
	if (!$self->session->var->isAdminOn && $self->get("cacheTimeout") > 10) {
		my $out = WebGUI::Cache->new($self->session,"view_".$self->getId)->get;
		return $out if $out;
	}
	my %var = %{$self->get};
	$var{controls} = $self->getToolbar;
	$var{fileUrl} = $self->getFileUrl;
	$var{fileIcon} = $self->getFileIconUrl;
	$var{fileSize} = formatBytes($self->get("assetSize"));
       	my $out = $self->processTemplate(\%var,undef,$self->{_viewTemplate});
	if (!$self->session->var->isAdminOn && $self->get("cacheTimeout") > 10) {
		WebGUI::Cache->new($self->session,"view_".$self->getId)->set($out,$self->get("cacheTimeout"));
	}
       	return $out;
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
	my $addEdit = ($self->session->form->process("func") eq 'add') ? $i18n->get('add','Asset_Wobject') : $i18n->get('edit','Asset_Wobject');
	return $self->getAdminConsole->render($tabform->print,$addEdit.' '.$self->getName);
}

#-------------------------------------------------------------------

# setStreamedFile and setRedirect do not interact well with the
# exporter.  We have a separate method for this now.
sub exportHtml_view {
	my $self = shift;
	return $self->session->privilege->noAccess() unless $self->canView;

	my $path = $self->getStorageLocation->getPath($self->get('filename'));
	my $fh = eval { FileHandle->new($path) };
	defined($fh) or return "";
	binmode $fh or ($fh->close, return "");
	my $block;
	while (read($fh, $block, 16384) > 0) {
		$self->session->output->print($block, 1);
	}
	$fh->close;
	return 'chunked';
}

sub www_view {
	my $self = shift;
	return $self->session->privilege->noAccess() unless $self->canView;

	$self->session->http->setRedirect($self->getFileUrl);
    	$self->session->http->setStreamedFile($self->getStorageLocation->getPath($self->get("filename")));
	return 'chunked';
}


1;
