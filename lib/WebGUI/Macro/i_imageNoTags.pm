package WebGUI::Macro::i_imageNoTags;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::CPHash;
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::SQL;

#-------------------------------------------------------------------
sub _replacement {
	my (@param, $temp, %data);
	tie %data, 'Tie::CPHash';
        @param = WebGUI::Macro::getParams($_[0]);
	%data = WebGUI::SQL->quickHash("select * from images where name='$param[0]'");
	$temp = $session{setting}{attachmentDirectoryWeb}.'/images/'.$data{imageId}.'/'.$data{filename};
	return $temp;
}

#-------------------------------------------------------------------
sub process {
	my ($output, $temp);
	$output = $_[0];
        $output =~ s/\^i\((.*?)\)\;/_replacement($1)/ge;
	return $output;
}

1;


