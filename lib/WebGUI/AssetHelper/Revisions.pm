package WebGUI::AssetHelper::Revisions;

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

Package WebGUI::AssetHelper::Revisions

=head1 DESCRIPTION

Displays the revisions for this asset.

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 process ( $class, $asset )

Opens a new tab for displaying revisions of this asset.

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
        open_tab => $asset->getUrl('op=assetHelper;className=WebGUI::AssetHelper::Revisions;func=manageRevisions'),
    };
}

#-------------------------------------------------------------------

=head2 www_manageRevisions ( $class, $asset )

Displays a table of revision data for this asset, along with links to edit each revision, view it, or delete it.

=cut

sub www_manageRevisions {
    my ($class, $asset) = @_;
    my $session = $asset->session;
    my $i18n    = WebGUI::International->new($session, "Asset");
    if (! $asset->canEdit) {
        return {
            error => $i18n->get('38', 'WebGUI'),
        }
    }
    my $output = sprintf qq{<table style="width: 100%;" class="content">\n
        <tr><th></th><th>%s</th><th>%s</th><th>%s</th></tr>\n},
        $i18n->get('revision date'), $i18n->get('revised by'), $i18n->get('tag name');
    my $sth = $session->db->read("select ad.revisionDate, ad.revisedBy, at.name, ad.tagId from assetData as ad
		left join assetVersionTag as at on ad.tagId=at.tagId where ad.assetId=? order by revisionDate desc", [$asset->getId]);
    my $url = $asset->get('url');
    while (my ($date, $userId, $tagName, $tagId) = $sth->array) {
        my $user = WebGUI::User->new($session, $userId);
        $output .= WebGUI::HTML::arrayToRow(
			 $session->icon->delete("func=purgeRevision;revisionDate=".$date, $url, $i18n->get("purge revision prompt"))
			.$session->icon->view( "func=view;revision=" . $date )
            .$session->icon->edit( "func=edit;revision=" . $date ), 
			$session->datetime->epochToHuman($date),
			$user->username,
			'<a href="'.$asset->getUrl("op=manageRevisionsInTag;tagId=".$tagId).'">'.$tagName.'</a>'
        );
    }
    $sth->finish;
    $output .= '</table>';
    return $output;
}

1;
