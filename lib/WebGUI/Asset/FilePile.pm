package WebGUI::Asset::FilePile;

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
use WebGUI::Icon;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Storage;
use WebGUI::Template;
use WebGUI::Utility;

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
	if ($session{form}{afterEdit}) {
		$tabform->hidden({
			name=>"afterEdit",
			value=>$session{form}{afterEdit}
			});
	}
	$tabform->addTab("properties",WebGUI::International::get("properties","Asset"));
	$tabform->getTab("properties")->yesNo(
               	-name=>"hideFromNavigation",
               	-value=>1,
               	-label=>WebGUI::International::get(886),
               	-uiLevel=>6
               	);
       	$tabform->getTab("properties")->yesNo(
                -name=>"newWindow",
       	        -value=>0,
               	-label=>WebGUI::International::get(940),
                -uiLevel=>6
       	        );
	$tabform->addTab("privileges",WebGUI::International::get(107),6);
	$tabform->getTab("security")->dateTime(
               	-name=>"startDate",
                -label=>WebGUI::International::get(497),
       	        -value=>$self->get("startDate"),
               	-uiLevel=>6
                );
       	$tabform->getTab("security")->dateTime(
               	-name=>"endDate",
                -label=>WebGUI::International::get(498),
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
       	       	-label=>WebGUI::International::get(108),
       		-value=>[$self->get("ownerUserId")],
       		-subtext=>$subtext,
       		-uiLevel=>6
       		);
      	$tabform->getTab("security")->group(
       		-name=>"groupIdView",
       		-label=>WebGUI::International::get(872),
       		-value=>[$self->get("groupIdView")],
       		-uiLevel=>6
       		);
      	$tabform->getTab("security")->group(
       		-name=>"groupIdEdit",
       		-label=>WebGUI::International::get(871),
       		-value=>[$self->get("groupIdEdit")],
       		-excludeGroups=>[1,7],
       		-uiLevel=>6
       		);
	$tabform->getTab("properties")->file(
		-name=>"file",
		-label=>"Upload File"
		);
	$tabform->getTab("properties")->file(
		-name=>"file",
		-label=>"Upload File"
		);
	$tabform->getTab("properties")->file(
		-name=>"file",
		-label=>"Upload File"
		);
	$tabform->getTab("properties")->file(
		-name=>"file",
		-label=>"Upload File"
		);
	$tabform->getTab("properties")->file(
		-name=>"file",
		-label=>"Upload File"
		);
	$tabform->getTab("properties")->file(
		-name=>"file",
		-label=>"Upload File"
		);
	$tabform->getTab("properties")->file(
		-name=>"file",
		-label=>"Upload File"
		);
	$tabform->getTab("properties")->file(
		-name=>"file",
		-label=>"Upload File"
		);
	$tabform->getTab("properties")->file(
		-name=>"file",
		-label=>"Upload File"
		);
	$tabform->getTab("properties")->file(
		-name=>"file",
		-label=>"Upload File"
		);
	return $self->getAdminConsole->render($tabform->print,"Add a Pile of Files");
}

sub editSave {
	my $self = shift;
	my $parent = WebGUI::Asset->newByUrl;
	my $tempStorage = WebGUI::Storage->create;
	$tempStorage->addFileFromFormPost("file");
	foreach my $filename (@{$tempStorage->getFiles}) {
		my $storage = WebGUI::Storage->create;
		$storage->addFileFromFilesystem($tempStorage->getPath($filename));
		my %data;
		my $class = 'WebGUI::Asset::File';
		$class = "WebGUI::Asset::File::Image" if (isIn($storage->getFileExtension($filename),qw(jpg jpeg gif png)));
		my $newAsset = $parent->addChild({className=>$class});
		foreach my $definition (@{$self->definition}) {
			foreach my $property (keys %{$definition->{properties}}) {
				$data{$property} = WebGUI::FormProcessor::process(
					$property,
					$definition->{properties}{$property}{fieldType},
					$definition->{properties}{$property}{defaultValue}
					);
			}
		}
		$data{filename} = $filename;
		$data{storageId} = $storage->getId;
		$data{title} = $data{menuTitle} = $filename;
		$data{url} = $parent->getUrl.'/'.$filename;
		$newAsset->update(\%data);
		$newAsset->setSize($storage->getFileSize($filename));
		$newAsset->generateThumbnail if ($class eq "WebGUI::Asset::File::Image");
	}
	$tempStorage->delete;
	return $parent->www_manageAssets if ($session{form}{afterEdit} eq "assetManager");
	return $parent->www_view;
}

#-------------------------------------------------------------------
sub getIcon {
	my $self = shift;
	my $small = shift;
	if ($small) {
		return $session{config}{extrasURL}.'/assets/small/folder.gif';
	}
	return $session{config}{extrasURL}.'/assets/folder.gif';
}


#-------------------------------------------------------------------

=head2 getName 

Returns the displayable name of this asset.

=cut

sub getName {
	return "File Pile";
} 

sub www_edit {
	my $self = shift;
	unless ($session{form}{doit}) {
		return $self->edit;
	} else {
		return $self->editSave;
	}
}




1;

