package WebGUI::Macro::Shared;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use Exporter;
use Tie::CPHash;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;

our @ISA = qw(Exporter);
our @EXPORT = qw(&traversePageTree);

#-------------------------------------------------------------------
sub process {
	return $_[0];
}

#-------------------------------------------------------------------
sub traversePageTree {
        my ($sth, @data, $output, $depth, $i, $toLevel);
	if ($_[2] > 0) {
		$toLevel = $_[2];
	} else {
		$toLevel = 99;
	}
        for ($i=1;$i<=$_[1];$i++) {
                $depth .= "&nbsp;&nbsp;&nbsp;";
        }
	if ($_[1] < $toLevel) {
        	$sth = WebGUI::SQL->read("select urlizedTitle, title, pageId from page where parentId='$_[0]' order by sequenceNumber");
        	while (@data = $sth->array) {
                	if (WebGUI::Privilege::canViewPage($data[2])) {
                        	$output .= $depth.'<a class="verticalMenu" href="'.$session{env}{SCRIPT_NAME}.'/'.$data[0].'">'.$data[1].'</a><br>';
                        	$output .= traversePageTree($data[2],$_[1]+1,$toLevel);
                	}
        	}
        	$sth->finish;
	}
        return $output;
}


1;
