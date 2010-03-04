package WebGUI::AssetHelper::ChangeUrl;

use strict;
use Class::C3;
use base qw/WebGUI::AssetHelper/;
use WebGUI::Session;

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

=head1 NAME

Package WebGUI::AssetHelper::ChangeUrl

=head1 DESCRIPTION

Changes the current URL for this Asset, and delete all previous versions of the
asset so that it only exists via this URL.

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 process ( $class, $asset )

Opens a new tab for displaying the form to change the Asset's URL.

=cut

sub process {
    my ($class, $asset) = @_;
    my $session = $asset->session;
    my $i18n = WebGUI::International->new($session, "Asset");
    if (! $asset->canEdit) {
        return {
            error => $i18n->get('38', 'WebGUI'),
        }
    }

    return {
        open_tab => $asset->getUrl('op=assetHelper;className=WebGUI::AssetHelper::ChangeUrl;func=changeUrl'),
    };
}

#-------------------------------------------------------------------

=head2 www_changeUrl ( $class, $asset )

Displays a form to change the URL for this asset.

=cut

sub www_changeUrl {
    my ($class, $asset) = @_;
    my $session = $asset->session;
    my $i18n    = WebGUI::International->new($session, "Asset");
    if (! $asset->canEdit) {
        return {
            error => $i18n->get('38', 'WebGUI'),
        }
    }
    my $f = WebGUI::HTMLForm->new($session, action=>$asset->getUrl);
    $f->hidden(name=>"func",    value=>"changeUrlSave");
    $f->hidden(name=>"proceed", value=>$session->form->param("proceed"));
    $f->text(
        name     => "url",
        value    => $asset->get('url'),
        label    => $i18n->get("104"),
        hoverHelp=> $i18n->get('104 description'),
    );
    $f->yesNo(
        name     => "confirm",
        value    => 0,
        label    => $i18n->get("confirm change"),
        hoverHelp=> $i18n->get("confirm change url message"),
        subtext  => '<br />'.$i18n->get("confirm change url message")
    );
    $f->submit;
    return $f->print;
}

#-------------------------------------------------------------------

=head2 www_changeUrlSave ( )

This actually does the change url of the www_changeUrl() function.

=cut

sub www_changeUrlSave {
    my ($class, $asset) = @_;
    my $session = $asset->session;
    my $i18n    = WebGUI::International->new($session, "Asset");
    if (! $asset->canEdit) {
        return {
            error => $i18n->get('38', 'WebGUI'),
        }
    }
    $asset->_invokeWorkflowOnExportedFiles($session->setting->get('changeUrlWorkflow'), 1);

    my $newUrl = $session->form->process("url","text");
    if ($session->form->process("confirm","yesNo") && $newUrl) {
        $asset->update({url => $newUrl});
        my $rs = $session->db->read("select revisionDate from assetData where assetId=? and revisionDate<>?",[$asset->getId, $asset->get("revisionDate")]);
        while (my ($version) = $rs->array) {
            my $old = eval { WebGUI::Asset->newById($session, $asset->getId, $version); };
            $old->purgeRevision if ! Exception::Class->caught();
        }
    }

    if ($session->form->param("proceed") eq "manageAssets") {
        $session->http->setRedirect($asset->getManagerUrl);
    }
    else {
        $session->http->setRedirect($asset->getUrl());
    }

    return undef;
}


1;
