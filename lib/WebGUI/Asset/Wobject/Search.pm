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
use base "WebGUI::Asset::Wobject";
use Tie::IxHash;
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

=head2 definition ( class, definition )

This method defines all properties of a Search and is used to autogenerate most methods.

=head3 class

$class is used to make sure that inheritance works on Assets and Wobjects.

=head3 definition

Definition hashref from subclasses.

=head3 Search specific properties

These properties are added just for this asset.

=head4 templateId

ID of a tempate from the Search namespace to display the search results.

=head4 searchRoot

An asset id of the point at which a search should start.

=head4 classLimiter

An array reference of asset classnames that are valid for the search.

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my $i18n = WebGUI::International->new($session,'Asset_Search');
	my %properties;
	tie %properties, 'Tie::IxHash';
	%properties = (
			templateId => {
				fieldType       => "template",
				defaultValue    => 'PBtmpl0000000000000200',	
				tab             => "display",
				namespace       => "Search",
                hoverHelp       => $i18n->get('search template description'),
                label           => $i18n->get('search template')
				},
			searchRoot => {
				fieldType       => "asset",
				defaultValue    => $session->setting->get("defaultPage"),
				tab             => "properties",
				hoverHelp       => $i18n->get("search root description"),
				label           => $i18n->get('search root')
				},
			classLimiter => {
				fieldType       => "checkList",
				defaultValue    => undef,
				vertical        => 1,
				tab             => "properties",
				hoverHelp       => $i18n->get("class limiter description"),
				label           => $i18n->get("class limiter"),
				options         => $session->db->buildHashRef("select distinct(className) from asset"),
                showSelectAll   => 1,
				},
            useContainers => {
                tab             => "properties",
                hoverHelp       => $i18n->get("useContainers help"),
                label           => $i18n->get("useContainers"),
                fieldType       => "yesNo",
                defaultValue    => 0,
                },
			paginateAfter => {
				hoverHelp       => $i18n->get("paginate after help"),
				label           => $i18n->get("paginate after"),
				tab             => "display",
				fieldType       => "integer",
				defaultValue    => 25,
				},
 		);

	push(@{$definition}, {
		assetName=>$i18n->get('assetName'),
		icon=>'search.gif',
		autoGenerateForms=>1,
		tableName=>'search',
		className=>'WebGUI::Asset::Wobject::Search',
		properties=>\%properties
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
    my $searchRoot = $self->getValue('searchRoot');
    if (my $searchOverride = $form->get('searchroot', 'asset')) {
        $searchRoot = $searchOverride;
    }
	
    if ($form->get("doit")) {
		my $search = WebGUI::Search->new($session);
		my %rules   = (
			keywords =>$keywords, 
			lineage  =>[
                WebGUI::Asset->newByDynamicClass($session, $searchRoot)->get("lineage"),
            ],
		);
		my @classes     = split("\n",$self->get("classLimiter"));
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
			$self->get("paginateAfter"),
        );

        my @results   = ();
        foreach my $data (@{$p->getPageData}) {
            next unless (
                $user->userId eq $data->{ownerUserId}
                || $user->isInGroup($data->{groupIdView})
                || $user->isInGroup($data->{groupIdEdit})
            );

            my $asset = WebGUI::Asset->new($session, $data->{assetId}, $data->{className});
            if (defined $asset) {
                my $properties = $asset->get;
                if ($self->get("useContainers")) {
                    $properties->{url} = $asset->isa('WebGUI::Asset::Post::Thread') ? $asset->getCSLinkUrl()
                                       :                                              $asset->getContainer->get("url");
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

