package WebGUI::Asset::Wobject::Folder;

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
use WebGUI::Asset::Wobject;
use WebGUI::Cache;
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
	my $session = shift;
        my $definition = shift;
	my $i18n = WebGUI::International->new($session,"Asset_Folder");
        push(@{$definition}, {
		assetName => $i18n->get("assetName"),
		uiLevel => 5,
		icon => 'folder.gif',
                tableName => 'Folder',
                className => 'WebGUI::Asset::Wobject::Folder',
		autoGenerateForms => 1,
                properties => {
			visitorCacheTimeout => {
				tab => "display",
				fieldType => "interval",
				defaultValue => 3600,
				uiLevel => 8,
				label => $i18n->get("visitor cache timeout"),
				hoverHelp => $i18n->get("visitor cache timeout help")
				},

			sortAlphabetically => {
				fieldType => "yesNo",
				defaultValue => 0,
				tab => 'display',
				label => $i18n->get('sort alphabetically'),
			        hoverHelp => $i18n->get('sort alphabetically help'),
				},

			templateId => {
				fieldType => "template",
				defaultValue => 'PBtmpl0000000000000078',
                                namespace => 'Folder',
				tab => 'display',
				label => $i18n->get('folder template title'),
				hoverHelp => $i18n->get('folder template description'),
				}
                        }
                });
        return $class->SUPER::definition($session, $definition);
}



#-------------------------------------------------------------------

=head2 getEditForm ( )

Returns the TabForm object that will be used in generating the edit page for this asset.

=cut

sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm();
	my $i18n = WebGUI::International->new($self->session,"Asset_Folder");
	if ($self->get("assetId") eq "new") {
               	$tabform->getTab("properties")->whatNext(
                       	-options=>{
                               	view=>$i18n->get(823),
                      	 	"viewParent"=>$i18n->get(847)
                              	},
			-value=>"view"
			);
	}
	return $tabform;
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

=head2 purgeCache ( )

See WebGUI::Asset::purgeCache() for details.

=cut

sub purgeCache {
	my $self = shift;
	WebGUI::Cache->new($self->session,"view_".$self->getId)->delete;
	$self->SUPER::purgeCache;
}

#-------------------------------------------------------------------
sub view {
	my $self = shift;

	my $i18n = WebGUI::International->new($self->session, 'Asset_Folder');
	
	if ($self->session->user->userId eq '1') {
		my $out = WebGUI::Cache->new($self->session,"view_".$self->getId)->get;
		return $out if $out;
	}
	my %rules = ( returnObjects => 1);
	$rules{orderByClause} = 'assetData.title' if ($self->get("sortAlphabetically"));
	my $children = $self->getLineage( ["children"], \%rules);
	my %vars;
	foreach my $child (@{$children}) {
		if (ref($child) eq "WebGUI::Asset::Wobject::Folder") {
			push(@{$vars{"subfolder_loop"}}, {
				id => $child->getId,
				url => $child->getUrl,
				title => $child->get("title"),
				canView => $child->canView(),
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
				canView => $child->canView(),
				title=>$child->get("title"),
				synopsis=>$child->get("synopsis") || '',
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
	
	$vars{'addFile.label'} = $i18n->get('add file label');
	$vars{'addFile.url'} = $self->getUrl('func=add;class=WebGUI::Asset::FilePile');
	
       	my $out = $self->processTemplate(\%vars,undef,$self->{_viewTemplate});
	if ($self->session->user->userId eq '1') {
		WebGUI::Cache->new($self->session,"view_".$self->getId)->set($out,$self->get("visitorCacheTimeout"));
	}
       	return $out;
}


#-------------------------------------------------------------------

=head2 www_view ( )

See WebGUI::Asset::Wobject::www_view() for details.

=cut

sub www_view {
	my $self = shift;
	$self->session->http->setCacheControl($self->get("visitorCacheTimeout")) if ($self->session->user->userId eq "1");
	$self->SUPER::www_view(@_);
}


1;

