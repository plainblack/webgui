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
use WebGUI::Cache;
use WebGUI::Asset::Wobject;
use WebGUI::Utility;

our @ISA = qw(WebGUI::Asset::Wobject);


#-------------------------------------------------------------------

=head2 definition

defines wobject properties for MultiSearch instances

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my $i18n = WebGUI::International->new($session, "Asset_MultiSearch");
	my $properties = {
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
			tab=>"display",
			defaultValue=>'MultiSearchTmpl0000001',
			namespace=>"MultiSearch",
			hoverHelp=>$i18n->get('MultiSearch Template description'),
			label=>$i18n->get('MultiSearch Template')
		},
#		predefinedSearches=>{
#			fieldType=>"textarea",
#			defaultValue=>"WebGUI",
#			tab=>"properties",
#			hoverHelp=>$i18n->get('article template description','Asset_Article'),
#			label=>$i18n->get(72,"Asset_Article")
#		},
	};
	push(@{$definition}, {
		tableName=>'MultiSearch',
		className=>'WebGUI::Asset::Wobject::MultiSearch',
		assetName=>$i18n->get('assetName'),
		icon=>'multiSearch.gif',
		autoGenerateForms=>1,
		properties=>$properties
	});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
    my $self = shift;
    $self->SUPER::prepareView();
    my $template = WebGUI::Asset::Template->new($self->session, $self->get("templateId"));
    if (!$template) {
        WebGUI::Error::ObjectNotFound::Template->throw(
            error      => qq{Template not found},
            templateId => $self->get("templateId"),
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
	WebGUI::Cache->new($self->session,"view_".$self->getId)->delete;
	$self->SUPER::purgeCache;
}

#-------------------------------------------------------------------

=head2 view ( )

method called by the www_view method.  Returns a processed template
to be displayed within the page style

=cut

sub view {
	my $self = shift;	
	if (!$self->session->var->isAdminOn && $self->get("cacheTimeout") > 10) {
        my $cache = $self->getCache;
        my $out   = $cache->get if defined $cache;
		return $out if $out;
	}
	my $i18n = WebGUI::International->new($self->session, 'Asset_MultiSearch');

	#Set some template variables
	my %var;
	$var{'for'}    = $i18n->get('for');
	$var{'search'} = $i18n->get('search');
	$var{'submit'} = WebGUI::Form::Submit->new($self->session, {name=>'SearchSubmit',value=>$i18n->get('submit','WebGUI')})->toHtml();

       	my $out = $self->processTemplate(\%var,undef,$self->{_viewTemplate});
	if (!$self->session->var->isAdminOn && $self->get("cacheTimeout") > 10) {
		WebGUI::Cache->new($self->session,"view_".$self->getId)->set($out,$self->get("cacheTimeout"));
	}
       	return $out;
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
