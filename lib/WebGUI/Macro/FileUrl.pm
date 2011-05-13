package WebGUI::Macro::FileUrl;

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
use WebGUI::Asset;
use WebGUI::Storage;
use WebGUI::International;
use WebGUI::Exception;

=head1 NAME

Package WebGUI::Macro::FileUrl

=head1 DESCRIPTION

Macro for returning the file system URL to a File or Image Asset,
identified by it's asset URL.

#-------------------------------------------------------------------

=head2 process ( url )

returns the file system URL if url is the URL for an Asset in the
system that has storageId and filename properties.  If no Asset
with that URL exists, then an internationalized error message will
be returned.

=head3 url

The URL to the Asset.

=cut

sub process {
    my $session = shift;
    my $url = shift;
    my $asset = eval { WebGUI::Asset->newByUrl($session,$url); };
    my $i18n = WebGUI::International->new($session, 'Macro_FileUrl');
    if (Exception::Class->caught()) {
        $session->log->warn("Invalid Asset URL for url: " . $url);
        return $i18n->get('invalid url');
    }
    my $storageId = $asset->can('storageId') ? $asset->storageId : undef;
    if (not defined $storageId) {
        $session->log->warn("No Storage Location for assetId: " . $asset->getId . " url: $url");
        return $i18n->get('no storage');
    }
    my $filename = $asset->can('filename') ? $asset->filename : undef;
    if (not defined $filename) {
        $session->log->warn("No Filename for assetId: " . $asset->getId . " url: $url");
        return $i18n->get('no filename');
    }
    my $storage = WebGUI::Storage->get($session,$storageId);
    return $storage->getUrl($filename);
}


1;
