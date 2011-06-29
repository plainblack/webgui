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

=head2 process ()

Opens a new tab for displaying the form and the output for exporting a branch.

=cut

sub process {
    my ($self) = @_;
    my $asset = $self->asset;
    my $session = $self->session;
    my $i18n = WebGUI::International->new($session, "Asset");
    if (! $asset->canEdit) {
        return {
            error => $i18n->get('38', 'WebGUI'),
        }
    }

    return {
        openDialog => $self->getUrl( 'export' ),
    };
}

#-------------------------------------------------------------------

=head2 www_export

Displays the export page administrative interface

=cut

sub www_export {
    my ($self) = @_;
    my $asset = $self->asset;
    my $session = $self->session;
    return $session->privilege->insufficient() unless ($session->user->isInGroup(13));
    my ( $style, $url ) = $session->quick(qw{ style url });
    $style->setCss( $url->extras('hoverhelp.css'));
    $style->setScript( $url->extras('yui/build/yahoo-dom-event/yahoo-dom-event.js') );
    $style->setScript( $url->extras('yui/build/container/container-min.js') );
    $style->setScript( $url->extras('hoverhelp.js') );
    $style->setRawHeadTags( <<'ENDHTML' );
<style type="text/css">
    label.formDescription { display: block; margin-top: 1em; font-weight: bold }
</style>
ENDHTML

    my $i18n    = WebGUI::International->new($session, "Asset");
    my $f       = $self->getForm( 'exportStatus' );
    $f->addField( "integer",
        label          => $i18n->get('Depth'),
        hoverHelp      => $i18n->get('Depth description'),
        name           => "depth",
        value          => 99,
    );
    $f->addField( "YesNo",
        label          => $i18n->get('Export Related Assets'),
        hoverHelp      => $i18n->get('Export Related Assets description'),
        name           => "exportRelated",
        value          => '',
    );
    $f->addField( "selectBox",
        label          => $i18n->get('Export as user'),
        hoverHelp      => $i18n->get('Export as user description'),
        name           => "userId",
        options        => $session->db->buildHashRef("select userId, username from users"),
        value          => [1],
    );
    $f->addField( "text",
        label          => $i18n->get("directory index"),
        hoverHelp      => $i18n->get("directory index description"),
        name           => "index",
        value          => "index.html"
    );

    $f->addField( "text",
        label          => $i18n->get("Export site root URL"),
        name           => 'exportUrl',
        value          => '',
        hoverHelp      => $i18n->get("Export site root URL description"),
    );

    # TODO: maybe add copy options to these boxes alongside symlink
    $f->addField( "selectBox",
        label          => $i18n->get('extrasUploads form label'),
        hoverHelp      => $i18n->get('extrasUploads form hoverHelp'),
        name           => "extrasUploadsAction",
        options        => { 
            'symlink'  => $i18n->get('extrasUploads form option symlink'),
            'none'     => $i18n->get('extrasUploads form option none') },
        value          => ['none'],
    );
    $f->addField( "selectBox",
        label          => $i18n->get('rootUrl form label'),
        hoverHelp      => $i18n->get('rootUrl form hoverHelp'),
        name           => "rootUrlAction",
        options        => {
            'symlink'  => $i18n->get('rootUrl form option symlinkDefault'),
            'none'     => $i18n->get('rootUrl form option none') },
        value          => ['none'],
    );
    $f->addField( "submit", name => "send" );
    my $message;
    eval { $asset->exportCheckPath };
    if($@) {
        $message = $@;
    }
    return $session->style->process( 
        $message . $f->toHtml,
        "PBtmpl0000000000000137"
    );
}


#-------------------------------------------------------------------

=head2 www_exportStatus

Displays the export status page

=cut

sub www_exportStatus {
    my ($self) = @_;
    my $asset = $self->asset;
    my $session = $self->session;
    return $session->privilege->insufficient
        unless $session->user->isInGroup(13);
    my $form    = $session->form;
    my @vars    = qw(
        index depth userId extrasUploadsAction rootUrlAction exportUrl exportRelated
    );
    $asset->forkWithStatusPage({
            plugin   => 'ProgressTree',
            title    => 'Page Export Status',
            method   => 'exportInFork',
            dialog   => 1,
            message  => 'Your assets have been exported!',
            groupId  => 13,
            args     => {
                assetId => $asset->getId,
                map { $_ => scalar $form->get($_) } @vars
            }
        }
    );
}

1;
