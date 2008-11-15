package WebGUI::Macro::FileUrl;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
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

=head1 NAME

Package WebGUI::Macro::FileUrl

=head1 DESCRIPTION

Macro for returning the file system URL to a File or Image Asset,
identified by it's asset URL.

#-------------------------------------------------------------------

=head2 process ( url, id, isStorageId, filename )

returns the file system URL if url is the URL for an Asset in the
system that has storageId and filename properties.  If no Asset
with that URL exists, then an internationalized error message will
be returned.

=head3 url

The URL to the Asset.

head3 id

If id is passed in, the macro will attempt to retrive the storageId using the
Id of the Asset instead of by the url

=head3 isStorageId

If id is passed in and the isStorageId flag is set, the macro will forgo
the asset and simply return the url of the first file it finds

=head3 filename

If id is passed in and the isStorageId flag is set, you may pass in filename
to specify the name of the file you'd like returned.

head3 isImage

If id is passed in and the isImage flag is set, the first image will be returned

=cut

sub process {
	my $session     = shift;
    my $url         = shift;
    my $id          = shift;
    my $isStorageId = shift;
    my $filename    = shift;
    my $isImage     = shift;
    my $i18n        = WebGUI::International->new($session, 'Macro_FileUrl');
    
    #Handle storageId case
    if($isStorageId && $id) {
        my $store = undef;
        if($isImage) {
            $store = WebGUI::Storage::Image->get($session,$id);
        }
        else {
            $store = WebGUI::Storage->get($session,$id);
        }
        $filename = $store->getFiles->[0] unless ($filename);
        return "" unless ($filename);
        return $store->getUrl($filename);
    }
    
	my $asset = ($id)
              ? WebGUI::Asset->newByDynamicClass($session,$id)
              : WebGUI::Asset->newByUrl($session,$url);

	if (not defined $asset) {
		return $i18n->get('invalid url');
	}
	my $storageId = $asset->get('storageId');
	if (not defined $storageId) {
		return $i18n->get('no storage');
	}
	my $filename = $asset->get('filename');
	if (not defined $filename) {
		return $i18n->get('no filename');
	}
	my $storage = WebGUI::Storage->get($session,$storageId);
	return $storage->getUrl($filename);
}


1;
