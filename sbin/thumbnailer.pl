#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
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

use File::stat;
use Image::Magick;
use lib "../lib";
use WebGUI::Utility;


if ($ARGV[0] ne ""){
  $results = recurseFileSystem($ARGV[0]);
} else {
  print "Usage: perl $0 <uploadsPath> [<thumbnailSize (50)>]\n";
}

#-----------------------------------------
# getType(filename)
#-----------------------------------------
sub getType {
        my ($extension);
        $extension = $_[0];
        $extension =~ s/.*\.(.*?)$/$1/;
        return lc($extension);
}

#-----------------------------------------
# createThumbnail(filename,path)
#-----------------------------------------
sub createThumbnail {
        my ($image, $x, $y, $r, $n, $type);
	$type = getType($_[0]);
        if (isIn($type, qw(jpg jpeg gif png tif tiff bmp)) && !($_[0] =~ m/thumb-/)) {
		print "Nailing: $_[1]/$_[0]\n";
                $image = Image::Magick->new;
                $image->Read($_[1].'/'.$_[0]);
                ($x, $y) = $image->Get('width','height');
                $n = $ARGV[1] || 50;
                $r = $x>$y ? $x / $n : $y / $n;
                $image->Scale(width=>($x/$r),height=>($y/$r)) if ($r > 0);
                if (isIn($type, qw(tif tiff bmp))) {
                        $image->Write($_[1].'/thumb-'.$_[0].'.png');
                } else {
                        $image->Write($_[1].'/thumb-'.$_[0]);
                }
        }
}

#-----------------------------------------
# recurseFileSystem(path)
#-----------------------------------------
sub recurseFileSystem {
	my (@filelist, $file);
  	if (opendir(DIR,$_[0])) {
    		@filelist = readdir(DIR);
    		foreach $file (@filelist) {
      			unless ($file eq "." || $file eq "..") {
        			recurseFileSystem($_[0]."/".$file);
        			createThumbnail($file,$_[0]);
      			}
    		}
    		closedir(DIR);
  	}
}



