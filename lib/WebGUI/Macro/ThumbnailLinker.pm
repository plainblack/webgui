package WebGUI::Macro::ThumbnailLinker;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::CPHash;
use WebGUI::Attachment;
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::SQL;

#-------------------------------------------------------------------
sub _replacement {
	my (@param, %data, $image, $output);
	tie %data, 'Tie::CPHash';
        @param = WebGUI::Macro::getParams($_[0]);
	%data = WebGUI::SQL->quickHash("select * from images where name='$param[0]'");
	$image = WebGUI::Attachment->new($data{filename},"images",$data{imageId});
	$output = '<a href="'.$image->getURL.'"><img src="'.$image->getThumbnail.
		'" border="0"></a><br><b>'.$param[0].'</b><p>';
	return $output;
}

#-------------------------------------------------------------------
sub process {
	my ($output, $temp);
	$output = $_[0];
        $output =~ s/\^ThumbnailLinker\((.*?)\)\;/_replacement($1)/ge;
	return $output;
}

1;


