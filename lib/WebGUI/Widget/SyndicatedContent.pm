package WebGUI::Widget::SyndicatedContent;

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
use WebGUI::Macro;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;
use WebGUI::Widget;

#-------------------------------------------------------------------
sub purge {
        WebGUI::SQL->write("delete from SyndicatedContent where widgetId=$_[0]",$_[1]);
        purgeWidget($_[0],$_[1]);
}

#-------------------------------------------------------------------
sub widgetName {
	return "Syndicated Content";
}

#-------------------------------------------------------------------
sub www_add {
        my ($output);
      	if (WebGUI::Privilege::canEditPage()) {
                $output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=36"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a><h1>Add Syndicated Content</h1><form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("widget","SyndicatedContent");
                $output .= WebGUI::Form::hidden("func","addSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">Title</td><td>'.WebGUI::Form::text("title",20,30,'Syndicated Content').'</td></tr>';
                $output .= '<tr><td class="formDescription">Display the title?</td><td>'.WebGUI::Form::checkbox("displayTitle",1,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">Description</td><td>'.WebGUI::Form::textArea("description",'','','',1).'</td></tr>';
                $output .= '<tr><td class="formDescription">URL to RSS File</td><td>'.WebGUI::Form::text("rssUrl",20,2048).'</td></tr>';
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
	my ($widgetId);
	if (WebGUI::Privilege::canEditPage()) {
		$widgetId = create();
		WebGUI::SQL->write("insert into SyndicatedContent set widgetId=$widgetId, rssUrl=".quote($session{form}{rssUrl}).", content='Not yet fetched.'",$session{dbh});
		return "";
	} else {
		return WebGUI::Privilege::insufficient();
	}
}

#-------------------------------------------------------------------
sub www_edit {
        my ($output, %data);
        if (WebGUI::Privilege::canEditPage()) {
		%data = WebGUI::SQL->quickHash("select * from widget,SyndicatedContent where widget.widgetId=$session{form}{wid}",$session{dbh});
                $output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=37"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a><h1>Edit Syndicated Content</h1><form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","editSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">Title</td><td>'.WebGUI::Form::text("title",20,30,$data{title}).'</td></tr>';
                $output .= '<tr><td class="formDescription">Display the title?</td><td>'.WebGUI::Form::checkbox("displayTitle","1",$data{displayTitle}).'</td></tr>';
                $output .= '<tr><td class="formDescription">Description</td><td>'.WebGUI::Form::textArea("description",$data{description},50,10,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">URL to RSS File</td><td>'.WebGUI::Form::text("rssUrl",20,2048,$data{rssUrl}).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit("save").'</td></tr>';
		$output .= '<tr><td><br></td></tr>';
                $output .= '<tr><td class="formDescription">Last Fetched</td><td>'.$data{lastFetched}.'</td></tr>';
                $output .= '<tr><td class="formDescription">Current Content</td><td>'.$data{content}.'</td></tr>';
                $output .= '</table></form>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editSave {
        if (WebGUI::Privilege::canEditPage()) {
		update();
                WebGUI::SQL->write("update SyndicatedContent set rssUrl=".quote($session{form}{rssUrl})." where widgetId=$session{form}{wid}",$session{dbh});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_view {
	my (%data, $output, $widgetId);
	$widgetId = shift;
	%data = WebGUI::SQL->quickHash("select * from widget,SyndicatedContent where widget.widgetId=$widgetId",$session{dbh});
	if (defined %data) {
		if ($data{displayTitle} == 1) {
			$output = "<h1>".$data{title}."</h1>";
		}
		if ($data{description} ne "") {
			$output .= $data{description}.'<p>';
                }
		$output .= $data{content};
	}
	return $output;
}


1;
