package WebGUI::AssetHelper::Copy;

use strict;
use Class::C3;
use base qw/WebGUI::AssetHelper/;

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

Package WebGUI::AssetHelper::Copy

=head1 DESCRIPTION

Copy an Asset to the Clipboard, with no children.

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 duplicate ( $class, $asset )

Duplicates the asset.  Extracted out so that it can be subclassed by copy with children,
and copy with descendants.

=cut

sub duplicate {
    my ($class, $asset) = @_;
    return $asset->duplicate;
}

#-------------------------------------------------------------------

=head2 getMessage ( )

Returns the name of the i18n message to use

=cut

sub getMessage {
    return 'copied asset';
}

#-------------------------------------------------------------------

=head2 process ( $class, $asset )

Copies the asset to the clipboard.  There are no privilege or safety checks, since all operations
are done on the copy.

=cut

sub process {
    my ($class, $asset) = @_;
    my $session = $asset->session;
    my $i18n    = WebGUI::International->new($session, 'Asset');

    my $newAsset = $class->duplicate($asset);
    $newAsset->update({ title=>sprintf("%s (%s)",$asset->getTitle,$i18n->get('copy'))});
    $newAsset->cut;

    my $message = sprintf($i18n->get($class->getMessage()), $asset->getTitle);

    my $payload = {
        message => $message,
    };

    if (WebGUI::VersionTag->autoCommitWorkingIfEnabled($session, {
        allowComments   => 1,
        returnUrl       => $asset->getUrl,
    }) eq 'redirect') {
        $payload->{openDialog} = $session->http->getRedirectLocation;
    };

    return $payload;
}

1;
