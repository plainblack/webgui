package WebGUI::AssetHelper::ExportHtml;

use strict;
use Class::C3;
use base qw/WebGUI::AssetHelper/;
use WebGUI::User;
use WebGUI::HTML;

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

Package WebGUI::AssetHelper::ExportHtml

=head1 DESCRIPTION

Export this assets, and all children as HTML.

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 process ( $class, $asset )

Opens a new tab for displaying the form and the output for exporting a branch.

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
        open_tab => $asset->getUrl('op=assetHelper;className=WebGUI::AssetHelper::Export;func=editBranch'),
    };
}

#-------------------------------------------------------------------

=head2 www_export

Displays the export page administrative interface

=cut

sub www_export {
    my ($class, $asset) = @_;
    my $session = $asset->session;
    return $session->privilege->insufficient() unless ($session->user->isInGroup(13));
    my $i18n    = WebGUI::International->new($session, "Asset");
    my $f       = WebGUI::HTMLForm->new($session, -action => $asset->getUrl);
    $f->hidden(
        name           => "func",
        value          => "exportStatus"
    );
    $f->integer(
        label          => $i18n->get('Depth'),
        hoverHelp      => $i18n->get('Depth description'),
        name           => "depth",
        value          => 99,
    );
    $f->selectBox(
        label          => $i18n->get('Export as user'),
        hoverHelp      => $i18n->get('Export as user description'),
        name           => "userId",
        options        => $session->db->buildHashRef("select userId, username from users"),
        value          => [1],
    );
    $f->text(
        label          => $i18n->get("directory index"),
        hoverHelp      => $i18n->get("directory index description"),
        name           => "index",
        value          => "index.html"
    );

    $f->text(
        label          => $i18n->get("Export site root URL"),
        name           => 'exportUrl',
        value          => '',
        hoverHelp      => $i18n->get("Export site root URL description"),
    );

    # TODO: maybe add copy options to these boxes alongside symlink
    $f->selectBox(
        label          => $i18n->get('extrasUploads form label'),
        hoverHelp      => $i18n->get('extrasUploads form hoverHelp'),
        name           => "extrasUploadsAction",
        options        => { 
            'symlink'  => $i18n->get('extrasUploads form option symlink'),
            'none'     => $i18n->get('extrasUploads form option none') },
        value          => ['none'],
    );
    $f->selectBox(
        label          => $i18n->get('rootUrl form label'),
        hoverHelp      => $i18n->get('rootUrl form hoverHelp'),
        name           => "rootUrlAction",
        options        => {
            'symlink'  => $i18n->get('rootUrl form option symlinkDefault'),
            'none'     => $i18n->get('rootUrl form option none') },
        value          => ['none'],
    );
    $f->submit;
    my $message;
    eval { $asset->exportCheckPath };
    if($@) {
        $message = $@;
    }
    return $message . $f->print;
}


#-------------------------------------------------------------------

=head2 www_exportStatus

Displays the export status page

=cut

sub www_exportStatus {
    my ($class, $asset) = @_;
    my $session = $asset->session;
    return $session->privilege->insufficient() unless ($session->user->isInGroup(13));
    my $i18n        = WebGUI::International->new($session, "Asset");
    my $iframeUrl   = $self->getUrl('func=exportGenerate');
    foreach my $formVar (qw/index depth userId extrasUploadsAction rootUrlAction exportUrl/) {
        $iframeUrl  = $session->url->append($iframeUrl, $formVar . '=' . $session->form->process($formVar));
    }

    my $output      = '<iframe src="' . $iframeUrl . '" title="' . $i18n->get('Page Export Status') . '" width="100%" height="500"></iframe>';
    return $output;
}

1;
