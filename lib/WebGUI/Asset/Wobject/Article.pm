package WebGUI::Asset::Wobject::Article;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::IxHash;
use WebGUI::International;
use WebGUI::Cache;
use WebGUI::Paginator;
use WebGUI::Asset::Wobject;
use WebGUI::Storage;
use WebGUI::HTML;

our @ISA = qw(WebGUI::Asset::Wobject);

=head1 NAME

Package WebGUI::Asset::Wobject::Article

=head1 DESCRIPTION

Asset to display content to the user.  Most content in WebGUI sites
will be Articles.

Articles are Wobjects, so they inherit all the methods and properties of
Wobjects.

=head2 definition ( $class, $definition )

This method defines all properties of an Article and is used to autogenerate
most methods used by the Article.

=head3 $class

$class is used to make sure that inheritance works on Assets and Wobjects.

=head3 $definition

Definition hashref from subclasses.

=head3 Article specific properties

=over 4

=item templateId

ID of a tempate from the Article namespace to display the contents of the Article.

=item linkTitle

The text displayed to the user as a hyperlink to the linkURL.

=back

=cut

#-------------------------------------------------------------------

=head2 addRevision

Override the default method in order to deal with attachments.

=cut

sub addRevision {
    my $self = shift;
    my $newSelf = $self->SUPER::addRevision(@_);
    if ($newSelf->get("storageId") && $newSelf->get("storageId") eq $self->get('storageId')) {
        my $newStorage = WebGUI::Storage->get($self->session,$self->get("storageId"))->copy;
        $newSelf->update({storageId => $newStorage->getId});
    }
    return $newSelf;
}

#-------------------------------------------------------------------
sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my $i18n = WebGUI::International->new($session,'Asset_Article');
	my %properties;
	tie %properties, 'Tie::IxHash';
	%properties = (
			cacheTimeout => {
				tab => "display",
				fieldType => "interval",
				defaultValue => 3600,
				uiLevel => 8,
				label => $i18n->get("cache timeout"),
				hoverHelp => $i18n->get("cache timeout help")
				},
			templateId =>{
				fieldType=>"template",
				defaultValue=>'PBtmpl0000000000000002',	
				tab=>"display",
				namespace=>"Article",
                		hoverHelp=>$i18n->get('article template description'),
                		label=>$i18n->get(72)
				},
			linkTitle=>{
				tab=>"properties",
				fieldType=>'text',
				defaultValue=>undef,
				label=>$i18n->get(7),
                		hoverHelp=>$i18n->get('link title description'),
                		uiLevel=>3
				},
			linkURL=>{
				tab=>"properties",
				fieldType=>'url',
				defaultValue=>undef,
				label=>$i18n->get(8),
                		hoverHelp=>$i18n->get('link url description'),
                		uiLevel=>3
				},
			storageId=>{
				tab=>"properties",
				fieldType=>"image",
				deleteFileUrl=>$session->url->page("func=deleteFile;filename="),
				maxAttachments=>2,
                persist => 1,
				defaultValue=>undef,
				label=>$i18n->get("attachments"),
				hoverHelp=>$i18n->get("attachments help")
				}
		);
	push(@{$definition}, {
		assetName=>$i18n->get('assetName'),
		icon=>'article.gif',
		autoGenerateForms=>1,
		tableName=>'Article',
		className=>'WebGUI::Asset::Wobject::Article',
		properties=>\%properties
		});
        return $class->SUPER::definition($session, $definition);
}


#-------------------------------------------------------------------

=head2 duplicate ( )

Extend the super class to duplicate the storage location.

=cut

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

=head2 getStorageLocation ( )

Fetches the storage location for this asset.  If it does not have one,
then make one.  Build an internal cache of the storage object.

=cut

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

Indexing the content of attachments and user defined fields. See WebGUI::Asset::indexContent() for additonal details.

=cut

sub indexContent {
	my $self = shift;
	my $indexer = $self->SUPER::indexContent;
	$indexer->addKeywords($self->get("linkTitle"));
	$indexer->addKeywords($self->get("linkUrl"));
	my $storage = $self->getStorageLocation;
	foreach my $file (@{$storage->getFiles}) {
               $indexer->addFile($storage->getPath($file));
	}
}

#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
    my $self = shift;
    $self->SUPER::prepareView();
    my $templateId = $self->get("templateId");
    if ($self->session->form->process("overrideTemplateId") ne "") {
        $templateId = $self->session->form->process("overrideTemplateId");
    }
    my $template = WebGUI::Asset::Template->new($self->session, $templateId);
    if (!$template) {
        WebGUI::Error::ObjectNotFound::Template->throw(
            error      => qq{Template not found},
            templateId => $templateId,
            assetId    => $self->getId,
        );
    }
    $template->prepare($self->getMetaDataAsTemplateVariables);
    $self->{_viewTemplate} = $template;
}

#-------------------------------------------------------------------

=head2 processPropertiesFromFormPost ( )

Extend the super class to calculate total asset size from
any files stored in the storage location.

=cut

sub processPropertiesFromFormPost {
    my $self = shift;
    $self->SUPER::processPropertiesFromFormPost(@_);
    my $size = 0;
    my $storage = $self->getStorageLocation;
    foreach my $file (@{$storage->getFiles}) {
        $size += $storage->getFileSize($file);
    }
    $self->setSize($size);
}

#-------------------------------------------------------------------

=head2 update ( )

Extend the super class to handle the storage location.  Sets
the correct privileges and deletes the internally cached
Storage object.

=cut

sub update {
    my $self = shift;
    my $previousStorageId = $self->get('storageId');
    $self->SUPER::update(@_);
    ##update may have entered a new storageId.  Reset the cached one just in case.
    if ($self->get("storageId") ne $previousStorageId) {
        delete $self->{_storageLocation};
    }
    $self->getStorageLocation->setPrivileges(
        $self->get("ownerUserId"),
        $self->get("groupIdView"),
        $self->get("groupIdEdit"),
    );
}


#-------------------------------------------------------------------

=head2 purge ( )

Extend the super class to delete all storage locations.

=cut

sub purge {
        my $self = shift;
        my $sth = $self->session->db->read("select storageId from Article where assetId=?",[$self->getId]);
        while (my ($storageId) = $sth->array) {
		my $storage = WebGUI::Storage->get($self->session,$storageId);
                $storage->delete if defined $storage;
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

=head2 purgeRevision ( )

Extend the super class to delete the storage location for this revision.

=cut

sub purgeRevision {
        my $self = shift;
        $self->getStorageLocation->delete;
        return $self->SUPER::purgeRevision;
}

#-------------------------------------------------------------------

=head2 view ( )

view defines all template variables, processes the template and
returns the output.

=cut

sub view {
	my $self = shift;
	if (!$self->session->var->isAdminOn && $self->get("cacheTimeout") > 10 && !$self->session->form->process("overrideTemplateId") &&
            !$self->session->form->process($self->paginateVar) && !$self->session->form->process("makePrintable")) {
        my $cache = $self->getCache;
        my $out   = $cache->get if defined $cache;
		return $out if $out;
	}
	my %var;
	if ($self->get("storageId")) {
		my $storage = $self->getStorageLocation;
		my @loop = ();
		foreach my $file (@{$storage->getFiles}) {
			if ($storage->isImage($file)) {
				$var{'image.url'} = $storage->getUrl($file);
				$var{'image.thumbnail'} = $storage->getThumbnailUrl($file);
			} else {
				$var{'attachment.icon'} = $storage->getFileIconUrl($file);
				$var{'attachment.url'} = $storage->getUrl($file);
				$var{'attachment.name'} = $file;
			}
			push(@{$var{attachment_loop}}, {
				filename => $file,
				extension => WebGUI::Storage->getFileExtension($file),
				isImage => $storage->isImage($file),
				url=> $storage->getUrl($file),
				thumbnailUrl => $storage->getThumbnailUrl($file),
				iconUrl => $storage->getFileIconUrl($file)
				});
		}
	}
    $var{description} = $self->get("description");
	$var{"new.template"} = $self->getUrl("func=view").";overrideTemplateId=";
	$var{"description.full"} = $var{description};
	$var{"description.full"} =~ s/\^\-\;//g;
	$var{"description.first.100words"} = $var{"description.full"};
	$var{"description.first.100words"} =~ s/(((\S+)\s+){100}).*/$1/s;
	$var{"description.first.75words"} = $var{"description.first.100words"};
	$var{"description.first.75words"} =~ s/(((\S+)\s+){75}).*/$1/s;
	$var{"description.first.50words"} = $var{"description.first.75words"};
	$var{"description.first.50words"} =~ s/(((\S+)\s+){50}).*/$1/s;
	$var{"description.first.25words"} = $var{"description.first.50words"};
	$var{"description.first.25words"} =~ s/(((\S+)\s+){25}).*/$1/s;
	$var{"description.first.10words"} = $var{"description.first.25words"};
	$var{"description.first.10words"} =~ s/(((\S+)\s+){10}).*/$1/s;
	$var{"description.first.2paragraphs"} = $var{"description.full"};
	$var{"description.first.2paragraphs"} =~ s/^((.*?\n){2}).*/$1/s;
	$var{"description.first.paragraph"} = $var{"description.first.2paragraphs"};
	$var{"description.first.paragraph"} =~ s/^(.*?\n).*/$1/s;
	$var{"description.first.4sentences"} = $var{"description.full"};
	$var{"description.first.4sentences"} =~ s/^((.*?\.){4}).*/$1/s;
	$var{"description.first.3sentences"} = $var{"description.first.4sentences"};
	$var{"description.first.3sentences"} =~ s/^((.*?\.){3}).*/$1/s;
	$var{"description.first.2sentences"} = $var{"description.first.3sentences"};
	$var{"description.first.2sentences"} =~ s/^((.*?\.){2}).*/$1/s;
	$var{"description.first.sentence"} = $var{"description.first.2sentences"};
	$var{"description.first.sentence"} =~ s/^(.*?\.).*/$1/s;
	my $p = WebGUI::Paginator->new($self->session,$self->getUrl,1,$self->paginateVar);
	if ($self->session->form->process("makePrintable") || $var{description} eq "") {
		$var{description} =~ s/\^\-\;//g;
		$p->setDataByArrayRef([$var{description}]);
	} else {
		my @pages = WebGUI::HTML::splitSeparator($var{description});
		$p->setDataByArrayRef(\@pages);
		$var{description} = $p->getPage;
	}
	$p->appendTemplateVars(\%var);
       	my $out = $self->processTemplate(\%var,undef,$self->{_viewTemplate});
	if (!$self->session->var->isAdminOn && $self->get("cacheTimeout") > 10 && !$self->session->form->process("overrideTemplateId") &&
            !$self->session->form->process($self->paginateVar) && !$self->session->form->process("makePrintable")) {
		WebGUI::Cache->new($self->session,"view_".$self->getId)->set($out,$self->get("cacheTimeout"));
	}
       	return $out;
}

#-------------------------------------------------------------------

=head2 paginateVar ( )

create a semi-unique variable for pagination based on the Asset Id

=cut

sub paginateVar {
     my $self = shift;
     my $id = $self->getId();
     return 'pn' . substr($id,0,2) . substr($id,-2,2) ;
}

#-------------------------------------------------------------------

=head2 www_deleteFile ( )

Deletes and attached file.

=cut

sub www_deleteFile {
	my $self = shift;
	return $self->session->privilege->insufficient unless $self->canEdit;
	if ($self->get("storageId") ne "") {
		my $storage = $self->getStorageLocation;
		$storage->deleteFile($self->session->form->param("filename"));
	}
	return $self->www_edit;
}

#-------------------------------------------------------------------

=head2 www_view ( )

See WebGUI::Asset::Wobject::www_view() for details.

=cut

sub www_view {
	my $self = shift;
	$self->session->http->setCacheControl($self->get("cacheTimeout"));
	$self->SUPER::www_view(@_);
}


1;

