package WebGUI::Macro::I_imageWithTags;

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
	my (@param, $temp, %data, $image);
	tie %data, 'Tie::CPHash';
        @param = WebGUI::Macro::getParams($_[0]);
	%data = WebGUI::SQL->quickHash("select filename,parameters,collateralId from collateral where name=".quote($param[0]));
	$image = WebGUI::Attachment->new($data{filename},"images",$data{collateralId});
	$temp = '<img src="'.$image->getURL.'" '.$data{parameters}.' />'; 
	return $temp;
}

#-------------------------------------------------------------------
sub process {
	my ($output, $temp);
	$output = $_[0];
	$output =~ s/\^I\((.*?)\)\;/_replacement($1)/ge;
	return $output;
}

1;


