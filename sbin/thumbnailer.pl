#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black LLC.
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

if ($ARGV[0] ne ""){
  $results = recurseFileSystem($ARGV[0]);
} else {
  print "Usage: $0 <uploadsPath> [<thumbnailSize (50)>]\n";
}

#-----------------------------------------
# isIn(string, listToCheck)
#-----------------------------------------
sub isIn {
        my ($i, @a, @b, @isect, %union, %isect, $e);
        foreach $e (@_) {
                if ($a[0] eq "") {
                        $a[0] = $e;
                } else {
                        $b[$i] = $e;
                        $i++;
                }
        }
        foreach $e (@a, @b) { $union{$e}++ && $isect{$e}++ }
        @isect = keys %isect;
        if (defined @isect) {
                undef @isect;
                return 1;
        } else {
                return 0;
        }
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



