package WebGUI::Macro::File;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
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
	my (@param, $temp, %data, $file);
	tie %data, 'Tie::CPHash';
        @param = WebGUI::Macro::getParams($_[0]);
	%data = WebGUI::SQL->quickHash("select collateralId,filename,name from collateral where name=".quote($param[0]));
	$file = WebGUI::Attachment->new($data{filename},"images",$data{collateralId});
	$temp = '<a href="'.$file->getURL.'"><img src="'.$file->getIcon.'" align="middle" border="0" /> '.$data{name}.'</a>'; 
	return $temp;
}

#-------------------------------------------------------------------
sub process {
	my ($output, $temp);
	$output = $_[0];
	$output =~ s/\^File\((.*?)\)\;/_replacement($1)/ge;
	return $output;
}

1;


