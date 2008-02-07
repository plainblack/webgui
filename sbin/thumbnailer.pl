#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
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

use Carp qw(croak);
use File::stat;
use File::Find ();
use Getopt::Long;

my $graphicsPackage;
BEGIN {
    if (eval { require Graphics::Magick; 1 }) {
        $graphicsPackage = 'Graphics::Magick';
    }
    elsif (eval { require Image::Magick; 1 }) {
        $graphicsPackage = 'Image::Magick';
    }
    else {
        croak "You must have either Graphics::Magick or Image::Magick installed to run WebGUI.\n";
    }
}

use lib "../lib";
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

if ($help || !($path && $ok) ) {
  print <<USAGE;
Usage: perl $0 --path=/path/to/files [--size=thumbnailSize] [--missing]

--path is the complete path to your uploads directory

--size=thumbSize allows you to override the default thumbnail size of 50.

--missing says to only create thumbnails for images that are missing thumbnails.

USAGE

exit 0;
}

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
        $image = $graphicsPackage->new;
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
