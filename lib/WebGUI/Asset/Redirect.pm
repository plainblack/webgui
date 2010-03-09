package WebGUI::Asset::Redirect;

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
use WebGUI::Macro;

use Moose;
use WebGUI::Definition::Asset;
extends 'WebGUI::Asset';
define assetName => ['assetName', 'Asset_Redirect'];
define icon      => 'redirect.gif';
define tableName => 'redirect';
property redirectUrl => (
                tab          => "properties",
                label        => ['redirect url', 'Asset_Redirect'],
                hoverHelp    => ['redirect url description', 'Asset_Redirect'],
                fieldType    => 'url',
                default      => undef,
         );
property redirectType => (
                tab          => "properties",
                label        => ['Redirect Type', 'Asset_Redirect'],
                hoverHelp    => ['redirect type description', 'Asset_Redirect'],
                fieldType    => 'selectBox',
                default      => 302,
                options      => \&_redirectType_options,
         );
sub _redirectType_options {
    my $session = shift->session;
	my $i18n = WebGUI::International->new($session, "Asset_Redirect");
    return {
        302 => $i18n->get('302 Moved Temporarily'),       
        301 => $i18n->get('301 Moved Permanently'),       
    };
}
has +uiLevel => (
    default => 9,
);



=head1 NAME

Package WebGUI::Asset::Redirect 

=head1 DESCRIPTION

Provides a mechanism to redirect pages from the WebGUI site to external sites.

=head1 SYNOPSIS

use WebGUI::Asset::Redirect;


=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 exportHtml_view

Override the method from AssetExportHtml to handle the redirect.

=cut

sub exportHtml_view {
        my $self = shift;
        return $self->session->privilege->noAccess() unless $self->canView;
        my $url = $self->redirectUrl;
        WebGUI::Macro::process($self->session, \$url);
	return '' if ($url eq $self->url);
	$self->session->http->setRedirect($url);
	return $self->session->style->process('', 'PBtmpl0000000000000060');
}

#-------------------------------------------------------------------

=head2 view ( )

Display the redirect url when in admin mode.

=cut

sub view {
	my $self = shift;
	if ($self->session->var->isAdminOn) {
		return $self->getToolbar.' '.$self->getTitle.' '.$self->redirectUrl;
	}
    else {
		return "";
	}
}

#-------------------------------------------------------------------

=head2 www_view

A web executable method that redirects the user to the specified page, or displays the edit interface when admin mode is enabled.

=cut

sub www_view {
    my $self = shift;
    return $self->session->privilege->noAccess() unless $self->canView;
	my $i18n = WebGUI::International->new($self->session, "Asset_Redirect");
    my $url = $self->redirectUrl;
    WebGUI::Macro::process($self->session, \$url);
    if ($self->session->var->isAdminOn() && $self->canEdit) {
        return $self->getAdminConsole->render($i18n->get("what do you want to do with this redirect").'
            <ul>
                <li><a href="'.$url.'">'.$i18n->get("go to the redirect url").'</a></li>
                <li><a href="'.$self->getUrl("func=edit").'">'.$i18n->get("edit the redirect properties").'</a></li>
                <li><a href="'.$self->getParent->getUrl.'">'.$i18n->get("go to the redirect parent page").'</a></li>
             </ul>',$i18n->get("assetName"));
    }
    unless ($url eq $self->url) {
        $self->session->http->setRedirect($url,$self->redirectType);
		return undef;
	}
    return $i18n->get('self_referential');
}

1;

