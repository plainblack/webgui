package WebGUI::Macro::StorageUrl; # edit this line to match your own macro name

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;

=head1 NAME

Package WebGUI::Macro::StorageUrl

=head1 DESCRIPTION

This macro gets the URL to a storage location, optionally adding a filename. 

=head2 process( session, storageId [, returnType, filename ] )

=over 4

=item *

A session variable

=item *

The ID to a storage location

=item *

Optional: One of the following strings:

 file       - Default: Get the url to the file
 thumb      - Get the url to the thumbnail of an image
              Only works with images

=item *

Optional: A filename to get the URL for. If not supplied, will 
get the first file asciibetically in the storage location.

=back

=cut


#-------------------------------------------------------------------
sub process {
	my $session = shift;
    my $storageId = shift;
    my $wantThumbnail = ( shift eq "thumb" ) ? 1 : 0;
    my $filename = shift;
	my $output = ""; 

    # Use WebGUI::Storage because we might be getting an image
    my $storage = WebGUI::Storage->get( $session, $storageId );
    return "" if !$storage;

    if ( !$filename ) {
        $filename   = $storage->getFiles->[0];
    }
    return "" if !$filename;

    if ( $wantThumbnail && $storage->isImage( $filename ) ) {
        return $storage->getThumbnailUrl( $filename );
    }
    else {
        return $storage->getUrl( $filename );
    }
}

1;

#vim:ft=perl
