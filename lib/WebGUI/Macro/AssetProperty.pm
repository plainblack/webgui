package WebGUI::Macro::AssetProperty;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use warnings;
use strict;

=head1 NAME

WebGUI::Macro::AssetProperty

=head1 SYNOPSIS

    ^AssetProperty(sf76sd8f5s7f5s7618, title);
    ^AssetProperty(root/import, assetId);

=head2 process( $session, $url_or_assetId, $propertyName )

Equivalent to calling $asset->get($propertyName)

=cut

#-------------------------------------------------------------------
sub process {
    my ($session, $id, $name) = @_;
    my $asset = WebGUI::Asset->new($session, $id) if $session->id->valid($id);
    $asset  ||= WebGUI::Asset->newByUrl($session, $id);

    return $asset->get($name) if $asset;

    $session->log->error("Invalid assetId or URL in AssetProperty: $id");
    return '';
}

1;
