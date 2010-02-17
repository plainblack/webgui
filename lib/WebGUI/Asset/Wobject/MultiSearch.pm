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

use Tie::CPHash;
use Tie::IxHash;
use JSON;
use WebGUI::International;
use WebGUI::SQL;
use WebGUI::Asset::Wobject;
use WebGUI::Utility;

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
    my $template = WebGUI::Asset::Template->new($self->session, $self->templateId);
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

sub purgeCache {
	my $self = shift;
	eval{$self->session->cache->delete("view_".$self->getId)};
	$self->SUPER::purgeCache;
}

#-------------------------------------------------------------------

=head2 view ( )

method called by the www_view method.  Returns a processed template
to be displayed within the page style

=cut

sub view {
	my $self = shift;	
    my $cache = $self->session->cache;
	if (!$self->session->var->isAdminOn && $self->cacheTimeout > 10) {
		my $out = eval{$cache->get("view_".$self->getId)};
		return $out if $out;
	}
	my $i18n = WebGUI::International->new($self->session, 'Asset_MultiSearch');

	#Set some template variables
	my %var;
	$var{'for'}    = $i18n->get('for');
	$var{'search'} = $i18n->get('search');
	$var{'submit'} = WebGUI::Form::Submit->new($self->session, {name=>'SearchSubmit',value=>$i18n->get('submit','WebGUI')})->toHtml();

       	my $out = $self->processTemplate(\%var,undef,$self->{_viewTemplate});
	if (!$self->session->var->isAdminOn && $self->cacheTimeout > 10) {
		eval{$cache->set("view_".$self->getId, $out, $self->cacheTimeout)};
	}
       	return $out;
}

#-------------------------------------------------------------------

=head2 www_view ( )

See WebGUI::Asset::Wobject::www_view() for details.

=cut

sub www_view {
	my $self = shift;
	$self->session->http->setCacheControl($self->cacheTimeout);
	$self->SUPER::www_view(@_);
}

1;
