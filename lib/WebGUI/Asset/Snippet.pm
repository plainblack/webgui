package WebGUI::Asset::Snippet;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2007 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use WebGUI::Asset;
use WebGUI::Asset::Template;
use WebGUI::Macro;

our @ISA = qw(WebGUI::Asset);


=head1 NAME

Package WebGUI::Asset::Snippet

=head1 DESCRIPTION

Provides a mechanism to publish arbitrary code snippets to WebGUI for reuse in other pages. Can be used for things like HTML segments, javascript, and cascading style sheets. You can also specify the MIME type of the snippet, allowing you to serve XML, CSS and other text files directly from the WebGUI asset system and have browsers recognize them correctly.

=head1 SYNOPSIS

use WebGUI::Asset::Snippet;


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
	my $i18n = WebGUI::International->new($session,"Asset_Snippet");
	my %properties;
	tie %properties, 'Tie::IxHash';
	%properties = (
 			snippet=>{
                        	fieldType=>'codearea',
				tab=>"properties",
				label=>$i18n->get('assetName'),
				hoverHelp=>$i18n->get('snippet description'),
                                defaultValue=>undef
                                },
			cacheTimeout => {
				tab => "display",
				fieldType => "interval",
				defaultValue => 3600,
				uiLevel => 8,
				label => $i18n->get("cache timeout"),
				hoverHelp => $i18n->get("cache timeout help")
				},
 			processAsTemplate=>{
                        	fieldType=>'yesNo',
				label=>$i18n->get('process as template'),
				hoverHelp=>$i18n->get('process as template description'),
				tab=>"properties",
                                defaultValue=>0
                                },
			mimeType=>{
				tab=>"properties",
				hoverHelp=>$i18n->get('mimeType description'),
				label=>$i18n->get('mimeType'),
                        	fieldType=>'mimeType',
                                defaultValue=>'text/html'
                                }

                        );
        push(@{$definition}, {
		assetName=>$i18n->get('assetName'),
		uiLevel => 5,
		icon=>'snippet.gif',
		autoGenerateForms=>1,
                tableName=>'snippet',
                className=>'WebGUI::Asset::Snippet',
                properties=>\%properties
                });
        return $class->SUPER::definition($session,$definition);
}


#-------------------------------------------------------------------

=head2 getToolbar ( )

Returns a toolbar with a set of icons that hyperlink to functions that delete, edit, promote, demote, cut, and copy.

=cut

sub getToolbar {
	my $self = shift;
	return undef if ($self->getToolbarState);
	return '<p>'.$self->SUPER::getToolbar().'</p>';
}

#-------------------------------------------------------------------

=head2 indexContent ( )

Indexing the content of the snippet. See WebGUI::Asset::indexContent() for additonal details. 

=cut

sub indexContent {
	my $self = shift;
	my $indexer = $self->SUPER::indexContent;
	$indexer->addKeywords($self->get("snippet"));
	$indexer->setIsPublic(0);
}

#-------------------------------------------------------------------

=head2 purgeCache ( )

Extending purgeCache to handle caching of the rendered snippet

=cut

sub purgeCache {
	my $self = shift;

	WebGUI::Cache->new($self->session,"view__".$self->getId)->delete;
	WebGUI::Cache->new($self->session,"view_1_".$self->getId)->delete;	
	$self->SUPER::purgeCache();
}

#-------------------------------------------------------------------
sub view {
	my $self = shift;
	my $calledAsWebMethod = shift;
	if (!$self->session->var->isAdminOn && $self->get("cacheTimeout") > 10) {
		my $out = WebGUI::Cache->new($self->session,"view_".$calledAsWebMethod."_".$self->getId)->get;
		return $out if $out;
	}
	my $output = $self->get("snippet");
	WebGUI::Macro::process($self->session,\$output);
	$output = $self->getToolbar.$output if ($self->session->var->get("adminOn") && !$calledAsWebMethod);
	if ($self->getValue("processAsTemplate")) {
		$output = WebGUI::Asset::Template->processRaw($self->session, $output, $self->get);
	}
	if (!$self->session->var->isAdminOn && $self->get("cacheTimeout") > 10) {
		WebGUI::Cache->new($self->session,"view_".$calledAsWebMethod."_".$self->getId)->set($output,$self->get("cacheTimeout"));
	}
       	return $output;
}

#-------------------------------------------------------------------
sub www_edit {
    my $self = shift;
    return $self->session->privilege->insufficient() unless $self->canEdit;
    return $self->session->privilege->locked() unless $self->canEditIfLocked;
    $self->getAdminConsole->setHelp("snippet add/edit","Asset_Snippet");
    my $i18n = WebGUI::International->new($self->session, 'Asset_Snippet');
    return $self->getAdminConsole->render($self->getEditForm->print,$i18n->get('snippet add/edit title'));
}

#-------------------------------------------------------------------

=head2 www_view

A web accessible version of the view method.

=cut

sub www_view {
	my $self = shift;
        return $self->session->privilege->insufficient() unless $self->canView;
	my $mimeType=$self->getValue('mimeType');
	$self->session->http->setMimeType($mimeType || 'text/html');
	$self->session->http->setCacheControl($self->get("cacheTimeout"));
	return $self->view(1);
}


1;

