package WebGUI::Asset::Wobject::Folder;

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
use WebGUI::Asset::Wobject;
use WebGUI::Icon;
use WebGUI::Session;
use WebGUI::Utility;

our @ISA = qw(WebGUI::Asset::Wobject);

=head1 NAME

Package WebGUI::Asset::Wobject::Folder

=head1 DESCRIPTION

Display a list of assets and sub folders just like in an operating system filesystem.

=head1 SYNOPSIS

use WebGUI::Asset::Wobject::Folder;


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
                tableName=>'Folder',
                className=>'WebGUI::Asset::Wobject::Folder',
                properties=>{
			templateId =>{
				fieldType=>"template",
				defaultValue=>'PBtmpl0000000000000054'
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
   	$tabform->getTab("display")->template(
      		-value=>$self->getValue('templateId'),
      		-namespace=>"Folder"
   		);
	if ($self->get("assetId") eq "new") {
               	$tabform->getTab("properties")->whatNext(
                       	-options=>{
                               	view=>WebGUI::International::get(823),
                      	 	""=>WebGUI::International::get(847)
                              	},
			-value=>"view"
			);
	}
	return $tabform;
}


#-------------------------------------------------------------------
sub getIcon {
	my $self = shift;
	my $small = shift;
	return $session{config}{extrasURL}.'/assets/small/folder.gif' if ($small);
	return $session{config}{extrasURL}.'/assets/folder.gif';
}

#-------------------------------------------------------------------

=head2 getName ()

Returns the displayable name of this asset.

=cut

sub getName {
	return "Folder";
} 


#-------------------------------------------------------------------

=head2 getUiLevel ()

Returns the UI level of this asset.

=cut

sub getUiLevel {
	return 5;
}


#-------------------------------------------------------------------
sub view {
	my $self = shift;
	my $children = $self->getLineage( ["children"], { returnObjects=>1 });
	my %vars;
	foreach my $child (@{$children}) {
		if (ref $child eq "WebGUI::Asset::Wobject::Folder") {
			push(@{$vars{"subfolder_loop"}}, {
				id => $child->getId,
				url => $child->getUrl,
				title => $child->get("title")
				});
		} else {
			my $isImage = (ref $child =~ /^WebGUI::Asset::File::Image/);
			my $thumbnail = $child->getThumbnailUrl if ($isImage);
			my $isFile = (ref $child =~ /^WebGUI::Asset::File/);
			my $file = $child->getFileUrl if ($isFile);
			push(@{$vars{"file_loop"}},{
				id=>$child->getId,
				title=>$child->get("title"),
				size=>WebGUI::Utility::formatBytes($child->get("assetSize")),
				"date.epoch"=>$child->get("dateStamp"),
				"icon.small"=>$child->getIcon(1),
				"icon.big"=>$child->getIcon,
				type=>$child->getName,
				url=>$child->getUrl,
				isImage=>$isImage,
				isImage=>$isFile,
				"thumbnail.url"=>$thumbnail,
				"file.url"=>$file
				});
		}
	}
	return $self->processTemplate(\%vars,$self->get("templateId"));
}


sub www_edit {
        my $self = shift;
	return $self->getAdminConsole->render(WebGUI::Privilege::insufficient()) unless $self->canEdit;
        return $self->getAdminConsole->render($self->getEditForm->print,"Edit Folder");
}



1;

