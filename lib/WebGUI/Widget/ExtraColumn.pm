package WebGUI::Widget::ExtraColumn;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;
use WebGUI::Widget;

#-------------------------------------------------------------------
sub purge {
        WebGUI::SQL->write("delete from ExtraColumn where widgetId=$_[0]",$_[1]);
        purgeWidget($_[0],$_[1]);
}

#-------------------------------------------------------------------
sub widgetName {
	return "Extra Column";
}

#-------------------------------------------------------------------
sub www_add {
        my ($output);
      	if (WebGUI::Privilege::canEditPage()) {
                $output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=25"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a><h1>Add Column</h1><form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("widget","ExtraColumn");
                $output .= WebGUI::Form::hidden("func","addSave");
                $output .= WebGUI::Form::hidden("title","column");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">Spacer</td><td>'.WebGUI::Form::text("spacer",20,3,10).'</td></tr>';
                $output .= '<tr><td class="formDescription">Width</td><td>'.WebGUI::Form::text("width",20,3,200).'</td></tr>';
                $output .= '<tr><td class="formDescription">StyleSheet Class</td><td>'.WebGUI::Form::text("class",20,50,"content").'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit("save").'</td></tr>';
                $output .= '</table></form>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
	return $output;
}

#-------------------------------------------------------------------
sub www_addSave {
	my ($widgetId, $displayTitle, $image, $attachment);
	if (WebGUI::Privilege::canEditPage()) {
		$widgetId = create();
		WebGUI::SQL->write("insert into ExtraColumn set widgetId=$widgetId, spacer='$session{form}{spacer}', width='$session{form}{width}', class=".quote($session{form}{class}),$session{dbh});
		return "";
	} else {
		return WebGUI::Privilege::insufficient();
	}
}

#-------------------------------------------------------------------
sub www_edit {
        my ($output, %data);
        if (WebGUI::Privilege::canEditPage()) {
		%data = WebGUI::SQL->quickHash("select * from ExtraColumn where widgetId=$session{form}{wid}",$session{dbh});
                $output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=26"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a><h1>Edit Column</h1><form method="post" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","editSave");
                $output .= WebGUI::Form::hidden("title","column");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">Spacer</td><td>'.WebGUI::Form::text("spacer",20,3,$data{spacer}).'</td></tr>';
                $output .= '<tr><td class="formDescription">Width</td><td>'.WebGUI::Form::text("width",20,3,$data{width}).'</td></tr>';
                $output .= '<tr><td class="formDescription">StyleSheet Class</td><td>'.WebGUI::Form::text("class",20,30,$data{class}).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit("save").'</td></tr>';
                $output .= '</table></form>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editSave {
        my ($widgetId, $displayTitle);
        if (WebGUI::Privilege::canEditPage()) {
                WebGUI::SQL->write("update ExtraColumn set spacer='$session{form}{spacer}', width='$session{form}{width}', class=".quote($session{form}{class})." where widgetId=$session{form}{wid}",$session{dbh});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_view {
	my (%data, @test, $output, $widgetId);
	$widgetId = shift;
	%data = WebGUI::SQL->quickHash("select * from ExtraColumn where widgetId='$widgetId'",$session{dbh});
	if (defined %data) {
		$output = '</td><td width="'.$data{spacer}.'"></td><td width="'.$data{width}.'" class="'.$data{class}.'" valign="top">';
	}
	return $output;
}







1;
