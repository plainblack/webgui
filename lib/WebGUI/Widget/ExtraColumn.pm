package WebGUI::Widget::ExtraColumn;

our $namespace = "ExtraColumn";

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
use Tie::CPHash;
use WebGUI::International;
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
	return WebGUI::International::get(199);
}

#-------------------------------------------------------------------
sub www_add {
        my ($output);
      	if (WebGUI::Privilege::canEditPage()) {
                $output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=1&namespace='.$namespace.'"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
		$output .= '<h1>'.WebGUI::International::get(200).'</h1>';
		$output .= '<form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("widget",$namespace);
                $output .= WebGUI::Form::hidden("func","addSave");
                $output .= WebGUI::Form::hidden("title","column");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(201).'</td><td>'.WebGUI::Form::text("spacer",20,3,10).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(202).'</td><td>'.WebGUI::Form::text("width",20,3,200).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(203).'</td><td>'.WebGUI::Form::text("class",20,50,"content").'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(62)).'</td></tr>';
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
		WebGUI::SQL->write("insert into ExtraColumn values ($widgetId, '$session{form}{spacer}', '$session{form}{width}', ".quote($session{form}{class}).")",$session{dbh});
		return "";
	} else {
		return WebGUI::Privilege::insufficient();
	}
}

#-------------------------------------------------------------------
sub www_edit {
        my ($output, %data);
	tie %data, 'Tie::CPHash';
        if (WebGUI::Privilege::canEditPage()) {
		%data = WebGUI::SQL->quickHash("select * from ExtraColumn where widgetId=$session{form}{wid}",$session{dbh});
                $output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=1&namespace='.$namespace.'"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
		$output .= '<h1>'.WebGUI::International::get(204).'</h1>';
		$output .= '<form method="post" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","editSave");
                $output .= WebGUI::Form::hidden("title","column");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(201).'</td><td>'.WebGUI::Form::text("spacer",20,3,$data{spacer}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(202).'</td><td>'.WebGUI::Form::text("width",20,3,$data{width}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(203).'</td><td>'.WebGUI::Form::text("class",20,50,$data{class}).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(204)).'</td></tr>';
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
	tie %data, 'Tie::CPHash';
	$widgetId = shift;
	%data = WebGUI::SQL->quickHash("select * from ExtraColumn where widgetId='$widgetId'",$session{dbh});
	if (defined %data) {
		$output = '</td><td width="'.$data{spacer}.'"></td><td width="'.$data{width}.'" class="'.$data{class}.'" valign="top">';
	}
	return $output;
}







1;
