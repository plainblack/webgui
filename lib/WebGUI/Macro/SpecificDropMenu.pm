package WebGUI::Macro::SpecificDropMenu;

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
use WebGUI::Macro;
use WebGUI::Navigation;
use WebGUI::Session;
use WebGUI::SQL;

#-------------------------------------------------------------------
sub _draw {
        my ($output, $i, $padding, $pageId);
        my ($tree, $indent, $maxDepth, $currentDepth) = @_;
	unless ($currentDepth >= $maxDepth) {
        	for ($i=1;$i<=$indent;$i++) {
                	$padding .= "&nbsp;&nbsp;";
        	}
        	foreach $pageId (keys %{$tree}) {
                	$output .= '<option value="'.$tree->{$pageId}{url}.'">';
                	$output .= $padding."- ".$tree->{$pageId}{title};
                	$output .= '</option>';
                	$output .= _draw($tree->{$pageId}{sub}, ($indent+1), $maxDepth, ($currentDepth+1));
        	}
	}
        return $output;
}

#-------------------------------------------------------------------
sub process {
        my ($temp, @param, $pageId, $tree);
        @param = WebGUI::Macro::getParams($_[0]);
        ($pageId) = WebGUI::SQL->quickArray("select pageId from page where urlizedTitle='$param[0]'");
        if (defined $pageId) {
		$param[2] = 99 unless ($param[2]);
		if ($param[1] ne "") {
			$tree = WebGUI::Navigation::tree($pageId,$param[1]);
		} else {
			$tree = WebGUI::Navigation::tree($pageId,1);
		}
		$temp = '<script language="JavaScript" type="text/javascript">
			function go(formObj){
				if (formObj.chooser.options[formObj.chooser.selectedIndex].value != "none") {
					location = formObj.chooser.options[formObj.chooser.selectedIndex].value
				}
			}
		</script>';
		$temp .= '<form><select name="chooser" size=1 onChange="go(this.form)">';
		$temp .= '<option value=none>Where do you want to go?';
		$temp .= _draw($tree,0,$param[2]);
		$temp .= '</select></form>';
        } else {
		$temp = "No page specified.";
	}
	return $temp;
}


1;


