package WebGUI::Macro::TopDropMenu;

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
use WebGUI::Navigation;
use WebGUI::Session;

#-------------------------------------------------------------------
sub process {
        my ($temp, $tree, $pageId);
	$tree = WebGUI::Navigation::tree(1,1);
	$temp = '<script language="JavaScript" type="text/javascript">
		function go(formObj){
			if (formObj.chooser.options[formObj.chooser.selectedIndex].value != "none") {
				location = formObj.chooser.options[formObj.chooser.selectedIndex].value
			}
		}
	</script>';
	$temp .= '<form><select name="chooser" size=1 onChange="go(this.form)">';
	$temp .= '<option value=none>Where do you want to go?';
        foreach $pageId (keys %{$tree}) {
		$temp .= '<option value="'.$tree->{$pageId}{url}.'">'.$tree->{$pageId}{title};
        }
	$temp .= '</select></form>';
	return $temp;
}


1;


