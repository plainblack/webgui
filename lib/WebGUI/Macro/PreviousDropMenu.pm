package WebGUI::Macro::PreviousDropMenu;

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
        my ($temp, @param, $tree);
        @param = WebGUI::Macro::getParams($_[0]);
	$param[1] = 99 unless ($param[1]);
	if ($param[0] ne "") {
               	$tree = WebGUI::Navigation::tree($session{page}{parentId},$param[0]);
        } else {
               	$tree = WebGUI::Navigation::tree($session{page}{parentId},1);
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
	$temp .= _draw($tree,0,$param[1]);
	$temp .= '</select></form>';
	return $temp;
}


1;


