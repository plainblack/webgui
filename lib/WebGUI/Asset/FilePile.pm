package WebGUI::Asset::FilePile;

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
use WebGUI::Asset::File;
use WebGUI::Asset::File::Image;
use WebGUI::SQL;
use WebGUI::Storage::Image;
use WebGUI::TabForm;
use WebGUI::Utility;

our @ISA = qw(WebGUI::Asset);


=head1 NAME

Package WebGUI::Asset::FilePile

=head1 DESCRIPTION

Provides a mechanism to upload files to WebGUI.

=head1 SYNOPSIS

use WebGUI::Asset::FilePile;


=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------
sub edit {
	my $self = shift;
	my $tabform = WebGUI::TabForm->new($self->session,);
	my $i18n = WebGUI::International->new($self->session, 'Asset_FilePile');
	$tabform->hidden({
		name=>"func",
		value=>"add"
		});
	$tabform->hidden({
		name=>"doit",
		value=>"1"
		});
	$tabform->hidden({
		name=>"class",
		value=>"WebGUI::Asset::FilePile"
		});
	if ($self->session->form->process("proceed")) {
		$tabform->hidden({
			name=>"proceed",
			value=>$self->session->form->process("proceed")
			});
	}
	$tabform->addTab("properties",$i18n->get("properties","Asset"));
	$tabform->getTab("properties")->yesNo(
               	-name=>"isHidden",
               	-value=>1,
               	-label=>$i18n->get(886),
               	-hoverHelp=>$i18n->get('886 description'),
               	-uiLevel=>6
               	);
       	$tabform->getTab("properties")->yesNo(
                -name=>"newWindow",
       	        -value=>0,
               	-label=>$i18n->get(940),
               	-hoverHelp=>$i18n->get('940 description'),
                -uiLevel=>6
       	        );
	$tabform->addTab("security",$i18n->get(107,"Asset"),6);
	$tabform->getTab("security")->dateTime(
               	-name=>"startDate",
                -label=>$i18n->get(497),
                -hoverHelp=>$i18n->get('497 description'),
       	        -value=>$self->get("startDate"),
               	-uiLevel=>6
                );
       	$tabform->getTab("security")->dateTime(
               	-name=>"endDate",
                -label=>$i18n->get(498),
                -hoverHelp=>$i18n->get('498 description'),
       	        -value=>$self->get("endDate"),
               	-uiLevel=>6
               	);
	my $subtext;
       	if ($self->session->user->isInGroup(3)) {
               	 $subtext = $self->session->icon->manage('op=listUsers');
        } else {
       	         $subtext = "";
       	}
       	my $clause;
       	if ($self->session->user->isInGroup(3)) {
       		my $group = WebGUI::Group->new($self->session,4);
               	my $contentManagers = $group->getUsers(1);
                push (@$contentManagers, $self->session->user->userId);
       	        $clause = "userId in (".$self->session->db->quoteAndJoin($contentManagers).")";
       	} else {
               	$clause = "userId=".$self->session->db->quote($self->get("ownerUserId"));
       	}
       	my $users = $self->session->db->buildHashRef("select userId,username from users where $clause order by username");
       	$tabform->getTab("security")->selectBox(
       		-name=>"ownerUserId",
              	-options=>$users,
       	       	-label=>$i18n->get(108),
       	       	-hoverHelp=>$i18n->get('108 description'),
       		-value=>[$self->get("ownerUserId")],
       		-subtext=>$subtext,
       		-uiLevel=>6
       		);
      	$tabform->getTab("security")->group(
       		-name=>"groupIdView",
       		-label=>$i18n->get(872),
       		-hoverHelp=>$i18n->get('872 description'),
       		-value=>[$self->get("groupIdView")],
       		-uiLevel=>6
       		);
      	$tabform->getTab("security")->group(
       		-name=>"groupIdEdit",
       		-label=>$i18n->get(871),
       		-hoverHelp=>$i18n->get('871 description'),
       		-value=>[$self->get("groupIdEdit")],
       		-excludeGroups=>[1,7],
       		-uiLevel=>6
       		);
	$tabform->getTab("properties")->file(
		-label=>$i18n->get("upload files"),
		-hoverHelp=>$i18n->get("upload files description"),
		-maxAttachments=>100
		);
        $self->getAdminConsole->setHelp("file pile add/edit","Asset_FilePile");
	return $self->getAdminConsole->render($tabform->print,$i18n->get("add pile"));
}

#-------------------------------------------------------------------
sub editSave {
	my $self = shift;
	my $tempStorage = WebGUI::Storage->create($self->session);
	$tempStorage->addFileFromFormPost("file");
	foreach my $filename (@{$tempStorage->getFiles}) {
		my $storage = WebGUI::Storage::Image->create($self->session);
		$storage->addFileFromFilesystem($tempStorage->getPath($filename));
		$storage->setPrivileges($self->getParent->get("ownerUserId"),$self->getParent->get("groupIdView"),$self->getParent->get("groupIdEdit"));
		my %data;
		my $selfName = 'WebGUI::Asset::File';
		$selfName = "WebGUI::Asset::File::Image" if ($storage->isImage($filename));
		foreach my $definition (@{$selfName->definition($self->session)}) {
			foreach my $property (keys %{$definition->{properties}}) {
				$data{$property} = $self->session->form->process(
					$property,
					$definition->{properties}{$property}{fieldType},
					$definition->{properties}{$property}{defaultValue}
					);
			}
		}
		$data{className} = $selfName;
		$data{storageId} = $storage->getId;
		$data{filename} = $data{title} = $data{menuTitle} = $filename;
		$data{templateId} = 'PBtmpl0000000000000024';
		$data{templateId} = 'PBtmpl0000000000000088' if ($selfName eq  "WebGUI::Asset::File::Image");
		$data{url} = $self->getParent->get('url').'/'.$filename;
		my $newAsset = $self->getParent->addChild(\%data);
		delete $newAsset->{_storageLocation};
		$newAsset->setSize($storage->getFileSize($filename));
		$newAsset->generateThumbnail if ($selfName eq "WebGUI::Asset::File::Image");
		$newAsset->commit;
	}
	$tempStorage->delete;
	return $self->getParent->www_manageAssets if ($self->session->form->process("proceed") eq "manageAssets");
	return $self->getParent->www_view;
}

#-------------------------------------------------------------------
sub getIcon {
	my $self = shift;
	my $small = shift;
	if ($small) {
		return $self->session->config->get("extrasURL").'/assets/small/filePile.gif';
	}
	return $self->session->config->get("extrasURL").'/assets/filePile.gif';
}


#-------------------------------------------------------------------

=head2 getName 

Returns the displayable name of this asset.

=cut

sub getName {
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session);
        return $i18n->get('assetName',"Asset_FilePile");
} 



#-------------------------------------------------------------------
sub www_edit {
	my $self = shift;
	unless ($self->session->form->process("doit")) {
		return $self->edit;
	} else {
		return $self->editSave;
	}
}




1;

