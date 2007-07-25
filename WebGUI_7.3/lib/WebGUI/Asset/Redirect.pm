package WebGUI::Asset::Redirect;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
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
use WebGUI::Macro;

our @ISA = qw(WebGUI::Asset);


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

=head2 definition ( definition )

Defines the properties of this asset.

=head3 definition

A hash reference passed in from a subclass definition.

=cut

sub definition {
        my $class = shift;
        my $session = shift;
        my $definition = shift;
	my $i18n = WebGUI::International->new($session,"Asset_Redirect");
        push(@{$definition}, {
		assetName=>$i18n->get('assetName'),
		uiLevel => 9,
		autoGenerateForms=>1,
		icon=>'redirect.gif',
                tableName=>'redirect',
                className=>'WebGUI::Asset::Redirect',
                properties=>{
                                redirectUrl=>{
					tab=>"properties",
                			label=>$i18n->get('redirect url'),
                			hoverHelp=>$i18n->get('redirect url description'),
                                        fieldType=>'url',
                                        defaultValue=>undef
                                        }
                        }
                });
        return $class->SUPER::definition($session,$definition);
}


#-------------------------------------------------------------------
sub www_edit {
    my $self = shift;
    return $self->session->privilege->insufficient() unless $self->canEdit;
    return $self->session->privilege->locked() unless $self->canEditIfLocked;
    $self->getAdminConsole->setHelp("redirect add/edit", "Asset_Redirect");
	my $i18n = WebGUI::International->new($self->session, 'Asset_Redirect');
    return $self->getAdminConsole->render($self->getEditForm->print,$i18n->get('redirect add/edit title'));
}

#-------------------------------------------------------------------

=head2 exportHtml_view

Override the method from AssetExportHtml to handle the redirect.

=cut

sub exportHtml_view {
        my $self = shift;
        return $self->session->privilege->noAccess() unless $self->canView;
        my $url = $self->get("redirectUrl");
        WebGUI::Macro::process($self->session, \$url);
	return '' if ($url eq $self->get("url"));
	$self->session->http->setRedirect($url);
	return $self->session->style->process('', 'PBtmpl0000000000000060');
}

#-------------------------------------------------------------------

=head2 www_view

A web executable method that redirects the user to the specified page, or displays the edit interface when admin mode is enabled.

=cut

sub www_view {
        my $self = shift;
        return $self->session->privilege->noAccess() unless $self->canView;
	my $i18n = WebGUI::International->new($self->session, "Asset_Redirect");
        my $url = $self->get("redirectUrl");
        WebGUI::Macro::process($self->session, \$url);
        if ($self->session->var->isAdminOn() && $self->canEdit) {
                return $self->getAdminConsole->render($i18n->get("what do you want to do with this redirect").'
                        <ul>
                        <li><a href="'.$url.'">'.$i18n->get("go to the redirect url").'</a></li>
                        <li><a href="'.$self->getUrl("func=edit").'">'.$i18n->get("edit the redirect properties").'</a></li>
                        <li><a href="'.$self->getParent->getUrl.'">'.$i18n->get("go to the redirect parent page").'</a></li>
                        </ul>',$i18n->get("assetName"));
        }
        unless ($url eq $self->get("url")) {
        	$self->session->http->setRedirect($url);
		return 1;
	}
        return $i18n->get('self_referential');
}

1;

