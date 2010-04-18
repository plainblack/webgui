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
use WebGUI::International;
use WebGUI::Paginator;

use Moose;
use WebGUI::Definition::Asset;
extends 'WebGUI::Asset::Wobject';
define assetName => ['assetName', 'Asset_Article'];
define icon      => 'article.gif';
define tableName => 'Article';
property cacheTimeout => (
                tab       => "display",
                fieldType => "interval",
                default   => 3600,
                uiLevel   => 8,
                label     => ["cache timeout", 'Asset_Article'],
                hoverHelp => ["cache timeout help", 'Asset_Article'],
         );
property templateId => (
                tab        => "display",
                fieldType  => "template",
                default    => 'PBtmpl0000000000000002',    
                namespace  => "Article",
                hoverHelp  => ['article template description', 'Asset_Article'],
                label      => ['72', 'Asset_Article'],
         );
property linkTitle => (
                tab       => "properties",
                fieldType => 'text',
                default   => undef,
                label     => ['7', 'Asset_Article'],
                hoverHelp => ['link title description', 'Asset_Article'],
                uiLevel   => 3
         );
property linkURL => (
                tab       => "properties",
                fieldType => 'url',
                default   => undef,
                label     => ['8', 'Asset_Article'],
                hoverHelp => ['link url description', 'Asset_Article'],
                uiLevel   => 3
         );
property storageId => (
                tab            => "properties",
                fieldType      => "image",
                deleteFileUrl  => \&_storageId_deleteFileUrl,
                maxAttachments => 2,
                persist        => 1,
                default        => undef,
                label          => ["attachments", 'Asset_Article'],
                hoverHelp      => ["attachments help", 'Asset_Article'],
                trigger        => \&_set_storageId,
         );
sub _set_storageId {
    my ($self, $new, $old) = @_;
    if ($new ne $old) {
        delete $self->{_storageLocation};
    }
}
sub _storageid_deleteFileUrl {
    return shift->session->url->page("func=deleteFile;filename=");
}

with 'WebGUI::Role::Asset::SetStoragePermissions';

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

override addRevision => sub {
    my $self = shift;
    my $newSelf = super();
    if ($newSelf->storageId && $newSelf->storageId eq $self->storageId) {
        my $newStorage = WebGUI::Storage->get($self->session,$self->storageId)->copy;
        $newSelf->update({storageId => $newStorage->getId});
    }
    return $newSelf;
};

#-------------------------------------------------------------------

=head2 duplicate ( )

Extend the super class to duplicate the storage location.

=cut

override duplicate => sub {
	my $self = shift;
	my $newAsset   = super();
	my $newStorage = $self->getStorageLocation->copy;
	$newAsset->update({storageId=>$newStorage->getId});
	return $newAsset;
};

#-------------------------------------------------------------------

=head2 exportAssetData ( )

See WebGUI::AssetPackage::exportAssetData() for details.

=cut

override exportAssetData => sub {
	my $self = shift;
	my $data = super();
	push(@{$data->{storage}}, $self->storageId) if ($self->storageId ne "");
	return $data;
};


#-------------------------------------------------------------------

=head2 getStorageLocation ( )

Fetches the storage location for this asset.  If it does not have one,
then make one.  Build an internal cache of the storage object.

=cut

sub getStorageLocation {
	my $self = shift;
	unless (exists $self->{_storageLocation}) {
		if ($self->storageId eq "") {
            my $storage = WebGUI::Storage->create($self->session);
			$self->update({ storageId => $storage->getId });
			$self->{_storageLocation} = $storage;
		}
        else {
			$self->{_storageLocation} = WebGUI::Storage->get($self->session,$self->storageId);
		}
	}
	return $self->{_storageLocation};
}

#-------------------------------------------------------------------

=head2 indexContent ( )

Indexing the content of attachments and user defined fields. See WebGUI::Asset::indexContent() for additonal details.

=cut

override indexContent => sub {
    my $self = shift;
    my $indexer = super();
    $indexer->addKeywords($self->linkTitle);
    $indexer->addKeywords($self->linkURL);
    my $storage = $self->getStorageLocation;
    foreach my $file (@{$storage->getFiles}) {
        $indexer->addFile($storage->getPath($file));
    }
};

#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
    my $self = shift;
    $self->SUPER::prepareView();
    my $templateId = $self->templateId;
    if ($self->session->form->process("overrideTemplateId") ne "") {
        $templateId = $self->session->form->process("overrideTemplateId");
    }
    my $template = WebGUI::Asset::Template->newById($self->session, $templateId);
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

override processPropertiesFromFormPost => sub {
    my $self = shift;
    super();
    my $size = 0;
    my $storage = $self->getStorageLocation;
    foreach my $file (@{$storage->getFiles}) {
        $size += $storage->getFileSize($file);
    }
    $self->setSize($size);
};

#-------------------------------------------------------------------

=head2 purge ( )

Extend the super class to delete all storage locations.

=cut

override purge => sub {
    my $self = shift;
    my $sth = $self->session->db->read("select storageId from Article where assetId=?",[$self->getId]);
    while (my ($storageId) = $sth->array) {
    my $storage = WebGUI::Storage->get($self->session,$storageId);
        $storage->delete if defined $storage;
    }
    $sth->finish;
    return super();
};

#-------------------------------------------------------------------

=head2 purgeCache ( )

See WebGUI::Asset::purgeCache() for details.

=cut

override purgeCache => sub {
	my $self = shift;
	eval{$self->session->cache->delete("view_".$self->getId)};
	super();
};

#-------------------------------------------------------------------

=head2 purgeRevision ( )

Extend the super class to delete the storage location for this revision.

=cut

override purgeRevision => sub {
        my $self = shift;
        $self->getStorageLocation->delete;
        return super();
};

#-------------------------------------------------------------------

=head2 view ( )

view defines all template variables, processes the template and
returns the output.

=cut

sub view {
	my $self = shift;
    my $cache = $self->session->cache;
	if (!$self->session->var->isAdminOn && $self->cacheTimeout > 10 && !$self->session->form->process("overrideTemplateId") &&
            !$self->session->form->process($self->paginateVar) && !$self->session->form->process("makePrintable")) {
		my $out = eval{$cache->get($self->getViewCacheKey)};
		return $out if $out;
	}
	my %var;
	if ($self->storageId) {
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
				isImage => $storage->isImage($file),
				url=> $storage->getUrl($file),
				thumbnailUrl => $storage->getThumbnailUrl($file),
				iconUrl => $storage->getFileIconUrl($file)
				});
		}
	}
    $var{description} = $self->description;
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
	if (!$self->session->var->isAdminOn && $self->cacheTimeout > 10 && !$self->session->form->process("overrideTemplateId") &&
            !$self->session->form->process($self->paginateVar) && !$self->session->form->process("makePrintable")) {
		eval{$cache->set($self->getViewCacheKey, $out, $self->cacheTimeout)};
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
	if ($self->storageId ne "") {
		my $storage = $self->getStorageLocation;
		$storage->deleteFile($self->session->form->param("filename"));
	}
	return $self->www_edit;
}

#-------------------------------------------------------------------

=head2 www_view ( )

See WebGUI::Asset::Wobject::www_view() for details.

=cut

override www_view => sub {
	my $self = shift;
	$self->session->http->setCacheControl($self->cacheTimeout);
	super();
};


__PACKAGE__->meta->make_immutable;
1;

