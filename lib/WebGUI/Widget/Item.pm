package WebGUI::Widget::Item;

our $namespace = "Item";

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
use WebGUI::Form;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;
use WebGUI::Widget;

#-------------------------------------------------------------------
sub purge {
	WebGUI::SQL->write("delete from Item where widgetId=$_[0]",$_[1]);
	purgeWidget($_[0],$_[1]);
}

#-------------------------------------------------------------------
sub widgetName {
	return "Item";
}

#-------------------------------------------------------------------
sub www_add {
        my ($output, %hash);
	tie %hash,'Tie::IxHash';
      	if (WebGUI::Privilege::canEditPage()) {
		$output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=1&namespace='.$namespace.'"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
		$output .= '<h1>Add '.widgetName().'</h1>';
		$output .= '<form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("widget","Item");
                $output .= WebGUI::Form::hidden("func","addSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(99).'</td><td>'.WebGUI::Form::text("title",20,30,widgetName()).'</td></tr>';
		$output .= '<tr><td class="formDescription">'.WebGUI::International::get(175).'</td><td>'.WebGUI::Form::checkbox("processMacros",1,1).'</td></tr>';
		%hash = WebGUI::Widget::getPositions();
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(363).'</td><td>'.WebGUI::Form::selectList("position",\%hash).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(85).'</td><td>'.WebGUI::Form::textArea("description",'').'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(1,$namespace).'</td><td>'.WebGUI::Form::text("linkURL",20,2048).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(2,$namespace).'</td><td>'.WebGUI::Form::file("attachment").'</td></tr>';
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
	my ($widgetId, $attachment);
	if (WebGUI::Privilege::canEditPage()) {
		$widgetId = create();
		$attachment = saveAttachment("attachment",$widgetId);
		WebGUI::SQL->write("insert into Item values ($widgetId, ".quote($session{form}{description}).", ".quote($session{form}{linkURL}).", ".quote($attachment).")",$session{dbh});
		return "";
	} else {
		return WebGUI::Privilege::insufficient();
	}
}

#-------------------------------------------------------------------
sub www_deleteAttachment {
        if (WebGUI::Privilege::canEditPage()) {
		WebGUI::SQL->write("update Item set attachment='' where widgetId=$session{form}{wid}",$session{dbh});
		return www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_edit {
        my ($output, %data, %hash, @array);
	tie %data, 'Tie::CPHash';
	tie %hash, 'Tie::IxHash';
        if (WebGUI::Privilege::canEditPage()) {
		%data = WebGUI::SQL->quickHash("select * from widget,Item where widget.widgetId=Item.widgetId and widget.widgetId=$session{form}{wid}",$session{dbh});
		$output .= '<h1>Edit '.widgetName().'</h1>';
		$output .= '<form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","editSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(99).'</td><td>'.WebGUI::Form::text("title",20,30,$data{title}).'</td></tr>';
		$output .= '<tr><td class="formDescription">'.WebGUI::International::get(175).'</td><td>'.WebGUI::Form::checkbox("processMacros","1",$data{processMacros}).'</td></tr>';
		%hash = WebGUI::Widget::getPositions();
                $array[0] = $data{position};
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(363).'</td><td>'.WebGUI::Form::selectList("position",\%hash,\@array).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(85).'</td><td>'.WebGUI::Form::textArea("description",$data{description}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(1,$namespace).'</td><td>'.WebGUI::Form::text("linkURL",20,2048,$data{linkURL}).'</td></tr>';
		if ($data{attachment} ne "") {
                	$output .= '<tr><td class="formDescription">'.WebGUI::International::get(2,$namespace).'</td><td><a href="'.$session{page}{url}.'?func=deleteAttachment&wid='.$session{form}{wid}.'">'.WebGUI::International::get(3,$namespace).'</a></td></tr>';
		} else {
                	$output .= '<tr><td class="formDescription">'.WebGUI::International::get(2,$namespace).'</td><td>'.WebGUI::Form::file("attachment").'</td></tr>';
		}
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit("save").'</td></tr>';
                $output .= '</table></form>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editSave {
        my ($attachment);
        if (WebGUI::Privilege::canEditPage()) {
		update();
                $attachment = saveAttachment("attachment",$session{form}{wid});
		if ($attachment ne "") {
                        $attachment = ', attachment='.quote($attachment);
                }
                WebGUI::SQL->write("update Item set description=".quote($session{form}{description}).", linkURL=".quote($session{form}{linkURL}).$attachment." where widgetId=$session{form}{wid}",$session{dbh});
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
	%data = WebGUI::SQL->quickHash("select * from widget,Item where widget.widgetId='$widgetId' and widget.WidgetId=Item.widgetId",$session{dbh});
	if (defined %data) {
                if ($data{linkURL} ne "") {
                        $output .= '<a href="'.$data{linkURL}.'"><span class="itemTitle">'.$data{title}.'</span></a>';
                } else {
			$output .= '<span class="itemTitle">'.$data{title}.'</span>';
		}
		if ($data{attachment} ne "") {
			$output .= ' - <a href="'.$session{setting}{attachmentDirectoryWeb}.'/'.$widgetId.'/'.$data{attachment}.'"><img src="'.$session{setting}{lib}.'/smallAttachment.gif" border=0 alt="Download Attachment"></a>';
		}
		if ($data{description} ne "") {
			$output .= ' - '.$data{description};
		}
	}
	return $output;
}







1;
