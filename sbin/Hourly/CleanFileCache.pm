package Hourly::CleanFileCache;

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
use WebGUI::Session;
use WebGUI::Cache::FileCache;

#-------------------------------------------------------------------
sub process {
	my $size = $session{config}{fileCacheSizeLimit} + 10;
	my $expiresModifier = 0;
	my $cache = WebGUI::Cache::FileCache->new;
	while ($size > $session{config}{fileCacheSizeLimit}) {
		$size = $cache->getNamespaceSize($expiresModifier);	
		$expiresModifier += 600; # add 10 minutes each pass
	}
}


1;

