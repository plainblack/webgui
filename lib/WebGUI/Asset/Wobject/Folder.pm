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
		assetName=>WebGUI::International::get("assetName","Asset_Folder"),
		uiLevel => 5,
		icon=>'folder.gif',
                tableName=>'Folder',
                className=>'WebGUI::Asset::Wobject::Folder',
                properties=>{
			templateId =>{
				fieldType=>"template",
				defaultValue=>'PBtmpl0000000000000078'
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
      		-label=>WebGUI::International::get('folder template title', "Asset_Folder"),
      		-hoverHelp=>WebGUI::International::get('folder template description', "Asset_Folder"),
      		-namespace=>"Folder"
   		);
	if ($self->get("assetId") eq "new") {
               	$tabform->getTab("properties")->whatNext(
                       	-options=>{
                               	view=>WebGUI::International::get(823, "Asset_Folder"),
                      	 	"viewParent"=>WebGUI::International::get(847, "Asset_Folder")
                              	},
			-value=>"view"
			);
	}
	return $tabform;
}


#-------------------------------------------------------------------
sub view {
	my $self = shift;
	my $children = $self->getLineage( ["children"], { returnObjects=>1 });
	my %vars;
	foreach my $child (@{$children}) {
		if (ref($child) eq "WebGUI::Asset::Wobject::Folder") {
			push(@{$vars{"subfolder_loop"}}, {
				id => $child->getId,
				url => $child->getUrl,
				title => $child->get("title"),
				"icon.small"=>$child->getIcon(1),
				"icon.big"=>$child->getIcon
				});
		} else {
			my $isImage = (ref($child) =~ /^WebGUI::Asset::File::Image/);
			my $thumbnail = $child->getThumbnailUrl if ($isImage);
			my $isFile = (ref($child) =~ /^WebGUI::Asset::File/);
			my $file = $child->getFileUrl if ($isFile);
			push(@{$vars{"file_loop"}},{
				id=>$child->getId,
				title=>$child->get("title"),
				synopsis=>$child->get("synopsis"),
				size=>WebGUI::Utility::formatBytes($child->get("assetSize")),
				"date.epoch"=>$child->get("revisionDate"),
				"icon.small"=>$child->getIcon(1),
				"icon.big"=>$child->getIcon,
				type=>$child->getName,
				url=>$child->getUrl,
				isImage=>$isImage,
				canEdit=>$child->canEdit,
				controls=>$child->getToolbar,
				isFile=>$isFile,
				"thumbnail.url"=>$thumbnail,
				"file.url"=>$file
				});
		}
	}
	return $self->processTemplate(\%vars,$self->get("templateId"));
}


#sub www_edit {
#        my $self = shift;
#	return $self->session->privilege->insufficient() unless $self->canEdit;
#        $self->getAdminConsole->setHelp("folder add/edit","Asset_Folder");
#        return $self->getAdminConsole->render($self->getEditForm->print,"Edit Folder");
#}



1;

