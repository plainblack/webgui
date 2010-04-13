package WebGUI::Asset::Wobject::Search;

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
use Moose;
use WebGUI::Definition::Asset;
extends "WebGUI::Asset::Wobject";
define assetName => ['assetName', 'Asset_Search'];
define icon      => 'search.gif';
define tableName => 'search';
property templateId => (
                fieldType       => "template",
                default         => 'PBtmpl0000000000000200',    
                tab             => "display",
                namespace       => "Search",
                hoverHelp       => ['search template description', 'Asset_Search'],
                label           => ['search template', 'Asset_Search'],
         );
property searchRoot => (
                fieldType       => "asset",
                builder         => '_searchRoot_builder',
                tab             => "properties",
                hoverHelp       => ["search root description", 'Asset_Search'],
                label           => ['search root', 'Asset_Search'],
         );
sub _searchRoot_builder {
    my $session = shift->session;
    return $session->setting->get("defaultPage");
}
property classLimiter => (
                fieldType       => "checkList",
                default         => undef,
                vertical        => 1,
                tab             => "properties",
                hoverHelp       => ["class limiter description", 'Asset_Search'],
                label           => ["class limiter", 'Asset_Search'],
                options         => \&_classLimiter_options,
                showSelectAll   => 1,
         );
sub _classLimiter_options {
    my $session = shift->session;
    return $session->db->buildHashRef("select distinct(className) from asset");
}
property useContainers => (
                tab             => "properties",
                hoverHelp       => ["useContainers help", 'Asset_Search'],
                label           => ["useContainers", 'Asset_Search'],
                fieldType       => "yesNo",
                default         => 0,
         );
property paginateAfter => (
                hoverHelp       => ["paginate after help", 'Asset_Search'],
                label           => ["paginate after", 'Asset_Search'],
                tab             => "display",
                fieldType       => "integer",
                default         => 25,
         );



use WebGUI::International;
use WebGUI::Paginator;
use WebGUI::Search;
use HTML::Highlight;

=head1 NAME

Package WebGUI::Asset::Wobject::Search

=head1 DESCRIPTION

Asset used to search WebGUI content.

=head1 METHODS

These methods are available from this package:

=cut


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

=head2 view ( )

Display search interface and results.

=cut

sub view {
	my $self    = shift;
    my $session = $self->session;
    my $form    = $session->form;
    my $user    = $session->user;
	my $i18n    = WebGUI::International->new($self->session, "Asset_Search");

    my $keywords = $form->get("keywords");
	my %var;
	
    $var{'form_header'  } = WebGUI::Form::formHeader($session, {
        action => $self->getUrl,
        method => "GET"
		})
    .WebGUI::Form::hidden($self->session,{name=>"doit", value=>"1"});
	$var{'form_footer'  } = WebGUI::Form::formFooter($session);
	$var{'form_submit'  } = WebGUI::Form::submit($session, {
        value=>$i18n->get("search")
    });
	$var{'form_keywords'} = WebGUI::Form::text($session, {
        name=>"keywords",
        value=>$keywords
    });
	$var{'no_results'   } = $i18n->get("no results");
    my $searchRoot = $self->searchRoot;
    if (my $searchOverride = $form->get('searchroot', 'asset')) {
        $searchRoot = $searchOverride;
    }
	
    if ($form->get("doit")) {
		my $search = WebGUI::Search->new($session);
		my %rules   = (
			keywords =>$keywords, 
			lineage  =>[
                WebGUI::Asset->newById($session,$searchRoot)->get("lineage")
            ],
		);
		my @classes     = split("\n",$self->classLimiter);
		$rules{classes} = \@classes if (scalar(@classes));
		$search->search(\%rules);
		
        #Instantiate the highlighter
        my @words     = grep { $_ ne '' } map { tr/+?*//d; $_; } split(/\s+/,$keywords);
        my @wildcards = map { "%" } @words;
        my $hl = HTML::Highlight->new(
            words     => \@words,
            wildcards => \@wildcards
        );

        #Set up the paginator
        my $p         = $search->getPaginatorResultSet (
            $self->getUrl('doit=1;keywords='.$session->url->escape($keywords)),
			$self->paginateAfter,
        );

        my @results   = ();
        foreach my $data (@{$p->getPageData}) {
            next unless (
                $user->userId eq $data->{ownerUserId}
                || $user->isInGroup($data->{groupIdView})
                || $user->isInGroup($data->{groupIdEdit})
            );

            my $asset = WebGUI::Asset->newById($session, $data->{assetId});
            if (defined $asset) {
                my $properties = $asset->get;
                if ($self->useContainers) {
                    $properties->{url} = $asset->isa('WebGUI::Asset::Post::Thread') ? $asset->getCSLinkUrl()
                                       :                                              $asset->getContainer->url;
                }
                #Add highlighting
                $properties->{'title'               } = $hl->highlight($properties->{title} || '');
                $properties->{'title_nohighlight'   } = $properties->{title};
                my $synopsis = $data->{'synopsis'} || '';
                WebGUI::Macro::process($self->session, \$synopsis);
                $properties->{'synopsis'            } = $hl->highlight($synopsis);
                $properties->{'synopsis_nohighlight'} = $synopsis;
                push(@results, $properties);
                $var{results_found} = 1;
            } 
		}

        $var{result_set} = \@results;
        $p->appendTemplateVars(\%var);
		
	}
	return $self->processTemplate(\%var, undef, $self->{_viewTemplate});
}

1;

