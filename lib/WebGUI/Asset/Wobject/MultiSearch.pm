package WebGUI::Asset::Wobject::MultiSearch;

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

 Portions of the below are originally from Weather::Underground, 
 and are not included in this copyright.

=cut

use strict;

use JSON;
use WebGUI::International;
use WebGUI::SQL;
use WebGUI::Asset::Wobject;

use Moose;
use WebGUI::Definition::Asset;
extends 'WebGUI::Asset::Wobject';
define tableName => 'MultiSearch';
define assetName => ['assetName', 'Asset_MultiSearch'];
define icon      => 'multiSearch.gif';
property cacheTimeout => (
            tab           => "display",
            fieldType     => "interval",
            default       => 3600,
            uiLevel       => 8,
            label         => ["cache timeout", 'Asset_MultiSearch'],
            hoverHelp     => ["cache timeout help", 'Asset_MultiSearch'],
         );
property templateId => (
            fieldType     => "template",
            tab           => "display",
            default       => 'MultiSearchTmpl0000001',
            namespace     => "MultiSearch",
            hoverHelp     => ['MultiSearch Template description', 'Asset_MultiSearch'],
            label         => ['MultiSearch Template', 'Asset_MultiSearch'],
         );


#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
    my $self = shift;
    $self->SUPER::prepareView();
    my $template = WebGUI::Asset::Template->newById($self->session, $self->templateId);
    if (!$template) {
        WebGUI::Error::ObjectNotFound::Template->throw(
            error      => qq{Template not found},
            templateId => $self->templateId,
            assetId    => $self->getId,
        );
    }
    $template->prepare($self->getMetaDataAsTemplateVariables);
    $self->{_viewTemplate} = $template;
}


#-------------------------------------------------------------------

=head2 purgeCache ( )

See WebGUI::Asset::purgeCache() for details.

=cut

override purgeCache => sub {
	my $self = shift;
	eval{$self->session->cache->remove("view_".$self->getId)};
	super();
};

#-------------------------------------------------------------------

=head2 view ( )

method called by the www_view method.  Returns a processed template
to be displayed within the page style

=cut

sub view {
	my $self = shift;	
    my $cache = $self->session->cache;
    my $cacheKey = $self->getWwwCacheKey( 'view' );
    if (!$self->session->isAdminOn && $self->cacheTimeout > 10) {
        my $out = eval { $cache->get( $cacheKey ) };
		return $out if $out;
	}
	my $i18n = WebGUI::International->new($self->session, 'Asset_MultiSearch');

	#Set some template variables
	my %var;
	$var{'for'}    = $i18n->get('for');
	$var{'search'} = $i18n->get('search');
	$var{'submit'} = WebGUI::Form::Submit->new($self->session, {name=>'SearchSubmit',value=>$i18n->get('submit','WebGUI')})->toHtml();

       	my $out = $self->processTemplate(\%var,undef,$self->{_viewTemplate});
    if (!$self->session->isAdminOn && $self->cacheTimeout > 10) {
        eval { $cache->set( $cacheKey, $out, $self->cacheTimeout) };
    }
    return $out;
}

#-------------------------------------------------------------------

=head2 www_view ( )

See WebGUI::Asset::Wobject::www_view() for details.

=cut

override www_view => sub {
	my $self = shift;
	$self->session->response->setCacheControl($self->cacheTimeout);
	super();
};

__PACKAGE__->meta->make_immutable;
1;
