package WebGUI::Operation::Shared;


#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use Exporter;
use strict;
use WebGUI::International;
use WebGUI::Session;
use WebGUI::SQL;

our @ISA = qw(Exporter);
our @EXPORT = qw(&menuWrapper);

#-------------------------------------------------------------------
sub menuWrapper {
        my ($output, $key);
        $output = '<table width="100%" border="0" cellpadding="5" cellspacing="0">
		<tr><td width="70%" class="tableData" valign="top">';
        $output .= $_[0];
        $output .= '</td><td width="30%" class="tableMenu" valign="top">';
	foreach $key (keys %{$_[1]}) {
        	$output .= '<li><a href="'.$key.'">'.$_[1]->{$key}.'</a>';
	}
        $output .= '<li><a href="'.WebGUI::URL::page().'">'.WebGUI::International::get(493).'</a>';
        $output .= '</td></tr></table>';
        return $output;
}

1;
