#!/usr/bin/env perl

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

#-----------------------------------------
# A little utility to generate WebGUI
# thumbnails. 
#-----------------------------------------

use strict;
use File::stat;
use File::Find ();
use Getopt::Long;
use Pod::Usage;
use Image::Magick;


use WebGUI::Paths -inc;
use WebGUI::Utility;

my $thumbnailSize;
my $onlyMissingThumbnails;
my $help;
my $path;

my $ok = GetOptions(
        'size=i'=>\$thumbnailSize,
        'missing'=>\$onlyMissingThumbnails,
        'help'=>\$help,
	'path=s'=>\$path
);

pod2usage( verbose => 2 ) if $help;
pod2usage() unless $path;

$thumbnailSize ||= 50; ##set default

File::Find::find(\&findThumbs, $path);

#-----------------------------------------
sub findThumbs {
    ##Remember, by default we are chdir'ed to the directory with the files in it.
    ##Skip directories
    return if -d $_;
    
    ##Only Thumbnail files that we should.
    return unless shouldThumbnail($_);

    createThumbnail($_, $File::Find::dir);

    return 1;  ##Just for cleanliness
}


#-----------------------------------------
# createThumbnail(filename,path)
#-----------------------------------------
sub createThumbnail {
        my ($image, $x, $y, $r, $n, $type);
        my ($fileName, $fileDir) = @_;
        print "Nailing: $fileDir/$fileName\n";
        $image = Image::Magick->new;
        $image->Read($fileName);
        ($x, $y) = $image->Get('width','height');
        $r = $x>$y ? $x / $thumbnailSize : $y / $thumbnailSize;
        $image->Scale(width=>($x/$r),height=>($y/$r)) if ($r > 0);
        if (isIn($type, qw(tif tiff bmp))) {
                $image->Write('thumb-'.$fileName.'.png');
        } else {
                $image->Write($_[1].'/thumb-'.$fileName);
        }
}

sub shouldThumbnail {
    my ($fileName) = @_;
    
    my $fileType = getType($fileName);

    ##I am a thumbnail, skip me
    return 0 if $fileName =~ m/thumb-/;

    ##I am not a graphics file, skip me
    return 0 if !isIn($fileType, qw(jpg jpeg gif png tif tiff bmp));

    ##My thumbnail already exists and I was told not to do it again
    return 0 if ($onlyMissingThumbnails && -e 'thumb-'.$fileName);

    return 1;
}

#-----------------------------------------
# getType(filename)
#-----------------------------------------
sub getType {
        my ($fileName) = @_;
        my ($extension) = $fileName =~ m/(\w+)$/;
        return lc($extension);
}

__END__

=head1 NAME

thumbnailer - Create thumbnails for WebGUI's uploaded graphic files

=head1 SYNOPSIS

 thumbnailer --path path
             [--size thumbnailSize]
	     [--missing]

 thumbnailer --help

=head1 DESCRIPTION

This WebGUI utility script generates thumbnails for WebGUI's uploaded
graphic files. The script finds all the graphic files recursively
starting from the specified path; it will skip those files that already
have thumbnails, and create PNG thumbnails for the rest.

Files with JPG, JPEG, GIF, PNG, TIF, TIFF and BMP extensions are
regarded as graphic files.

The thumbnails are created using L<Image::Magick>
for image transformations.

=over

=item B<--path path>

Specifies the absolute B<path> to WebGUI's uploads directory.
This parameter is required.

=item B<--size thumbSize>

Specify the size in pixels of the largest dimension of the thumbanils.
If left unspecified, it defaults to 50 pixels.

=item B<--missing>

Use this option to create thumbnails only for those images that are
missing thumbnails.

=item B<--help>

Shows this documentation, then exits.

=back

=head1 AUTHOR

Copyright 2001-2009 Plain Black Corporation.

=cut
