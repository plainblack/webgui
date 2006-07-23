package WebGUI::Macro::FileUrl;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
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

Macro for displaying returning the file system URL to a File, Image or Snippet Asset,
identified by it's asset URL.

=head2 process ( url )

returns the file system URL if url is the URL for an Asset in the
system that has storageId and filename properties.  If no Asset
with that URL exists, then an internationalized error message will
be returned.

=head3 url

The URL to the Asset.

=cut


#-------------------------------------------------------------------
sub process {
	my $session = shift;
        my $url = shift;
	my $asset = WebGUI::Asset->newByUrl($session,$url);
	my $i18n = WebGUI::International->new($session, 'Macro_FileUrl');
	if (not defined $asset) {
		$session->errorHandler->warn("^FileUrl($url): asset not found");
		return $i18n->get('invalid url');
	}
	my $storageId = $asset->get('storageId');
	if (not defined $storageId) {
		$session->errorHandler->warn("^FileUrl($url): asset does not store files");
		return $i18n->get('no storage');
	}
	my $filename = $asset->get('filename');
	if (not defined $filename) {
		$session->errorHandler->warn("^FileUrl($url): asset does not have a 'filename' property");
		return $i18n->get('no filename');
	}
	my $storage = WebGUI::Storage->get($session,$storageId);
	return $storage->getUrl($asset->get("filename"));
}


1;


