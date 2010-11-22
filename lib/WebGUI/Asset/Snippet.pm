package WebGUI::Asset::Snippet;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use Moose;
use WebGUI::Definition::Asset;
extends 'WebGUI::Asset';
use WebGUI::Asset::Template;
use WebGUI::Macro;
use HTML::Packer;
use JavaScript::Packer;
use CSS::Packer;

define assetName  => ['assetName','Asset_Snippet'];
define icon       => 'snippet.gif';
define tableName  => 'snippet';

property snippet => (
    fieldType       => 'codearea',
	tab             => "properties",
	label           => ['assetName','Asset_Snippet'],
	hoverHelp       => ['snippet description','Asset_Snippet'],
    default         => undef,
    trigger         => \&_trigger_snippet,
);
sub _trigger_snippet {
    my $self = shift;
    my ($new, $old) = @_;
    if ($new ne $old) {
        $self->_clear_snippetPacked;
    }
}
property snippetPacked => (
    fieldType       => "hidden",
    noFormPost      => 1,
    lazy            => 1,
    clearer         => '_clear_snippetPacked',
    builder         => '_build_snippetPacked',
);

sub _build_snippetPacked {
    my $self = shift;
    my $snippet = $self->snippet;
    if ( !defined $snippet ) {
        # do nothing
    }
    elsif ( $self->mimeType eq "text/html" ) {
        HTML::Packer::minify( \$snippet, {
            do_javascript       => "shrink",
            do_stylesheet       => "minify",
        } );
    }
    elsif ( $self->mimeType eq "text/css" ) {
        CSS::Packer::minify( \$snippet, {
            compress            => 'minify',
        });
    }
    elsif ( $self->mimeType eq 'text/javascript' ) {
        JavaScript::Packer::minify( \$snippet, {
            compress            => "shrink",
        });
    }
    $snippet;
}

property usePacked => (
    tab             => 'properties',
    fieldType       => 'yesNo',
    label           => ['usePacked label','Asset_Snippet'],
    hoverHelp       => ['usePacked description','Asset_Snippet'],
    default         => 0,
);
property cacheTimeout => (
	tab             => "display",
	fieldType       => "interval",
	default         => 3600,
	uiLevel         => 8,
	label           => ["cache timeout",'Asset_Snippet'],
	hoverHelp       => ["cache timeout help",'Asset_Snippet'],
);
property processAsTemplate => (
   	fieldType       => 'yesNo',
	label           => ['process as template','Asset_Snippet'],
	hoverHelp       => ['process as template description','Asset_Snippet'],
	tab             => "properties",
    default         => 0,
);
property mimeType => (
	tab             => "properties",
	hoverHelp       => ['mimeType description','Asset_Snippet'],
	label           => ['mimeType','Asset_Snippet'],
   	fieldType       => 'mimeType',
    default         => 'text/html',
);
has '+uiLevel' => (
    default         => 5,
);


=head1 NAME

Package WebGUI::Asset::Snippet

=head1 DESCRIPTION

Provides a mechanism to publish arbitrary code snippets to WebGUI for reuse
in other pages. Can be used for things like HTML segments, javascript, and
cascading style sheets. You can also specify the MIME type of the snippet,
allowing you to serve XML, CSS and other text files directly from the WebGUI
asset system and have browsers recognize them correctly.

=head1 SYNOPSIS

use WebGUI::Asset::Snippet;

=head1 METHODS

These methods are available from this class:

=cut



#-------------------------------------------------------------------

=head2 exportGetUrlAsPath ( index )

Translates a URL into an appropriate path and filename for exporting.
Overridden here to return a filename corresponding to the URL of this asset
as-is.

=head3 index

index filename passed from exportAsHtml

=cut

sub exportGetUrlAsPath {
    my $self            = shift;

    # we don't use this, but get it anyway
    my $index           = shift || 'index.html';

    my $config          = $self->session->config;

    # make sure that the export path is valid
    WebGUI::Asset->exportCheckPath($self->session);

    # if we're still here, it's valid. get it.
    my $exportPath      = $config->get('exportPath');

    # get the asset's URL as a URI::URL object for easy parsing of components
    my $url             = URI::URL->new($config->get("sitename")->[0] . $self->getUrl);
    my @pathComponents  = $url->path_components;
    shift @pathComponents; # first item is the empty string
    my $filename        = pop @pathComponents;

    # return a path with the filename part of the URL. No fancy twiddling needed.
    return Path::Class::File->new($exportPath, @pathComponents, $filename);
}

#-------------------------------------------------------------------

=head2 getToolbar ( )

Returns a toolbar with a set of icons that hyperlink to functions that delete, edit, promote, demote, cut, and copy.

=cut

override getToolbar => sub {
	my $self = shift;
	return undef if ($self->getToolbarState);
	return '<p>'.super().'</p>';
};

#-------------------------------------------------------------------

=head2 indexContent ( )

Indexing the content of the snippet. See WebGUI::Asset::indexContent() for additonal details. 

=cut

around indexContent => sub {
	my $orig = shift;
	my $self = shift;
	my $indexer = $self->$orig(@_);
	$indexer->addKeywords($self->snippet);
	$indexer->setIsPublic(0);
};

#-------------------------------------------------------------------

=head2 purgeCache ( )

Extending purgeCache to handle caching of the rendered snippet

=cut

override purgeCache => sub {
	my $self = shift;
    my $cache = $self->session->cache;
	eval {
        $cache->remove("view__".$self->getId);
        $cache->remove("view_1_".$self->getId);
        $cache->remove("view__".$self->getId . '_ssl');
        $cache->remove("view_1_".$self->getId . '_ssl');
    };
	super();
};

#-------------------------------------------------------------------

=head2 snippet ( value )

Returns the snippet's content.

=head3 value

If specified, sets the value, and also packs the content and inserts it into packedSnippet.

=cut

#-------------------------------------------------------------------

=head2 view ( $calledAsWebMethod )

Override the base class to implement caching, template and macro processing.

=head3 $calledAsWebMethod

If this is true, then change the cache method, and do not display the
toolbar if in adminMode.

=cut

sub view {
	my $self              = shift;
	my $calledAsWebMethod = shift;
    my $session    = $self->session;
    my $versionTag = WebGUI::VersionTag->getWorking($session, 1);
    my $noCache =
        $session->isAdminOn
        || $self->cacheTimeout <= 10
        || ($versionTag && $versionTag->getId eq $self->tagId);
    my $cacheKey = $self->getWwwCacheKey('view', $calledAsWebMethod);
    unless ($noCache) {
        my $out = $session->cache->get( $cacheKey );
		return $out if $out;
	}
	my $output = $self->usePacked
               ? $self->snippetPacked
               : $self->snippet
               ;
	$output = $self->getToolbar.$output if ($session->isAdminOn && !$calledAsWebMethod);
	if ($self->processAsTemplate) {
		$output = WebGUI::Asset::Template->processRaw($session, $output, $self->get);
	}
	WebGUI::Macro::process($session,\$output);
    unless ($noCache) {
        $session->cache->set( $cacheKey, $output, $self->cacheTimeout);
	}
    return $output;
}

#-------------------------------------------------------------------

=head2 www_view

A web accessible version of the view method.

=cut

sub www_view {
    my $self = shift;
    return $self->session->privilege->insufficient() unless $self->canView;
    my $mimeType=$self->mimeType;
    $self->session->response->content_type($mimeType || 'text/html');
    $self->session->http->setCacheControl($self->cacheTimeout);
    my $output = $self->view(1);
    if (!defined $output) {
        $output = 'empty';
    }
    return $output;
}

__PACKAGE__->meta->make_immutable;
1;

