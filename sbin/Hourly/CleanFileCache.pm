package Hourly::CleanFileCache;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Session;
use WebGUI::Cache::FileCache;
use File::Path;

#-------------------------------------------------------------------
sub process {
	traverse(WebGUI::Cache::FileCache->getCacheRoot);	
}

#-------------------------------------------------------------------
sub traverse {
	my $path = shift;
	if (opendir(DIR,$path)) {
        	my @files = readdir(DIR);
                foreach my $file (@files) {
                        unless ($file eq "." || $file eq "..") {
				if (open(FILE,"<".$path."/expires")) {
					my $expires = <FILE>;
					close(FILE);
					rmtree($path) if ($expires < time());
				} else {
                                	traverse($path."/".$file);
				}
                        }
                }
                closedir(DIR);
        }
}

1;

