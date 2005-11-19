package WebGUI::Asset::FilePile;

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
use WebGUI::Asset::File;
use WebGUI::Asset::File::Image;
use WebGUI::HTTP;
use WebGUI::Icon;
use WebGUI::Session;
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
	my $tabform = WebGUI::TabForm->new();
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
	if ($session{form}{proceed}) {
		$tabform->hidden({
			name=>"proceed",
			value=>$session{form}{proceed}
			});
	}
	$tabform->addTab("properties",WebGUI::International::get("properties","Asset"));
	$tabform->getTab("properties")->yesNo(
               	-name=>"isHidden",
               	-value=>1,
               	-label=>WebGUI::International::get(886,"Asset_FilePile"),
               	-hoverHelp=>WebGUI::International::get('886 description',"Asset_FilePile"),
               	-uiLevel=>6
               	);
       	$tabform->getTab("properties")->yesNo(
                -name=>"newWindow",
       	        -value=>0,
               	-label=>WebGUI::International::get(940,"Asset_FilePile"),
               	-hoverHelp=>WebGUI::International::get('940 description',"Asset_FilePile"),
                -uiLevel=>6
       	        );
	$tabform->addTab("security",WebGUI::International::get(107,"Asset"),6);
	$tabform->getTab("security")->dateTime(
               	-name=>"startDate",
                -label=>WebGUI::International::get(497,"Asset_FilePile"),
                -hoverHelp=>WebGUI::International::get('497 description',"Asset_FilePile"),
       	        -value=>$self->get("startDate"),
               	-uiLevel=>6
                );
       	$tabform->getTab("security")->dateTime(
               	-name=>"endDate",
                -label=>WebGUI::International::get(498,"Asset_FilePile"),
                -hoverHelp=>WebGUI::International::get('498 description',"Asset_FilePile"),
       	        -value=>$self->get("endDate"),
               	-uiLevel=>6
               	);
	my $subtext;
       	if (WebGUI::Grouping::isInGroup(3)) {
               	 $subtext = manageIcon('op=listUsers');
        } else {
       	         $subtext = "";
       	}
       	my $clause;
       	if (WebGUI::Grouping::isInGroup(3)) {
               	my $contentManagers = WebGUI::Grouping::getUsersInGroup(4,1);
                push (@$contentManagers, $session{user}{userId});
       	        $clause = "userId in (".quoteAndJoin($contentManagers).")";
       	} else {
               	$clause = "userId=".quote($self->get("ownerUserId"));
       	}
       	my $users = WebGUI::SQL->buildHashRef("select userId,username from users where $clause order by username");
       	$tabform->getTab("security")->selectList(
       		-name=>"ownerUserId",
              	-options=>$users,
       	       	-label=>WebGUI::International::get(108,"Asset_FilePile"),
       	       	-hoverHelp=>WebGUI::International::get('108 description',"Asset_FilePile"),
       		-value=>[$self->get("ownerUserId")],
       		-subtext=>$subtext,
       		-uiLevel=>6
       		);
      	$tabform->getTab("security")->group(
       		-name=>"groupIdView",
       		-label=>WebGUI::International::get(872,"Asset_FilePile"),
       		-hoverHelp=>WebGUI::International::get('872 description',"Asset_FilePile"),
       		-value=>[$self->get("groupIdView")],
       		-uiLevel=>6
       		);
      	$tabform->getTab("security")->group(
       		-name=>"groupIdEdit",
       		-label=>WebGUI::International::get(871,"Asset_FilePile"),
       		-hoverHelp=>WebGUI::International::get('871 description',"Asset_FilePile"),
       		-value=>[$self->get("groupIdEdit")],
       		-excludeGroups=>[1,7],
       		-uiLevel=>6
       		);
	$tabform->getTab("properties")->file(
		-label=>WebGUI::International::get("upload files", "Asset_FilePile"),
		-hoverHelp=>WebGUI::International::get("upload files description", "Asset_FilePile"),
		-maxAttachments=>100
		);
        $self->getAdminConsole->setHelp("file pile add/edit","Asset_FilePile");
	return $self->getAdminConsole->render($tabform->print,WebGUI::International::get("add pile", "Asset_FilePile"));
}

#-------------------------------------------------------------------
sub editSave {
	my $class = shift;
	my $tempStorage = WebGUI::Storage->create;
	$tempStorage->addFileFromFormPost("file");
	foreach my $filename (@{$tempStorage->getFiles}) {
		my $storage = WebGUI::Storage::Image->create;
		$storage->addFileFromFilesystem($tempStorage->getPath($filename));
		$storage->setPrivileges($class->getParent->get("ownerUserId"),$class->getParent->get("groupIdView"),$class->getParent->get("groupIdEdit"));
		my %data;
		my $className = 'WebGUI::Asset::File';
		$className = "WebGUI::Asset::File::Image" if ($storage->isImage($filename));
		foreach my $definition (@{$className->definition}) {
			foreach my $property (keys %{$definition->{properties}}) {
				$data{$property} = WebGUI::FormProcessor::process(
					$property,
					$definition->{properties}{$property}{fieldType},
					$definition->{properties}{$property}{defaultValue}
					);
			}
		}
		$data{className} = $className;
		$data{storageId} = $storage->getId;
		$data{filename} = $data{title} = $data{menuTitle} = $filename;
		$data{templateId} = 'PBtmpl0000000000000024';
		$data{templateId} = 'PBtmpl0000000000000088' if ($className eq  "WebGUI::Asset::File::Image");
		$data{url} = $class->getParent->getUrl.'/'.$filename;
		my $newAsset = $class->getParent->addChild(\%data);
		delete $newAsset->{_storageLocation};
		$newAsset->setSize($storage->getFileSize($filename));
		$newAsset->generateThumbnail if ($className eq "WebGUI::Asset::File::Image");
	}
	$tempStorage->delete;
	return $class->getParent->www_manageAssets if ($session{form}{proceed} eq "manageAssets");
	return $class->getParent->www_view;
}

#-------------------------------------------------------------------
sub getIcon {
	my $self = shift;
	my $small = shift;
	if ($small) {
		return $session{config}{extrasURL}.'/assets/small/filePile.gif';
	}
	return $session{config}{extrasURL}.'/assets/filePile.gif';
}


#-------------------------------------------------------------------

=head2 getName 

Returns the displayable name of this asset.

=cut

sub getName {
        return WebGUI::International::get('assetName',"Asset_FilePile");
} 



#-------------------------------------------------------------------
sub www_edit {
	my $self = shift;
	unless ($session{form}{doit}) {
		return $self->edit;
	} else {
		return $self->editSave;
	}
}




1;

