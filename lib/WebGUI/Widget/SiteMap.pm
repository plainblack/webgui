package WebGUI::Widget::SiteMap;

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
use WebGUI::Macro;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;
use WebGUI::Widget;

#-------------------------------------------------------------------
sub _traversePageTree {
        my ($sth, @data, $output, $depth, $i);
        for ($i=0;$i<=$_[1];$i++) {
                $depth .= "&nbsp;&nbsp;";
        }
	$sth = WebGUI::SQL->read("select urlizedTitle, title, pageId from page where parentId='$_[0]' order by sequenceNumber",$session{dbh});	
        while (@data = $sth->array) {
		if (WebGUI::Privilege::canViewPage($data[2])) {
                	$output .= $depth.'&middot; <a href="'.$session{env}{SCRIPT_NAME}.'/'.$data[0].'">'.$data[1].'</a><br>';
                	$output .= _traversePageTree($data[2],$_[1]+1);
		}
        }
        $sth->finish;
        return $output;
}

#-------------------------------------------------------------------
sub purge {
        WebGUI::SQL->write("delete from SiteMap where widgetId=$_[0]",$_[1]);
        purgeWidget($_[0],$_[1]);
}

#-------------------------------------------------------------------
sub widgetName {
	return "Site Map";
}

#-------------------------------------------------------------------
sub www_add {
        my ($output);
      	if (WebGUI::Privilege::canEditPage()) {
                $output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=30"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a><h1>Add Site Map</h1><form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("widget","SiteMap");
                $output .= WebGUI::Form::hidden("func","addSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">Title</td><td>'.WebGUI::Form::text("title",20,30,'Site Map').'</td></tr>';
                $output .= '<tr><td class="formDescription">Display title?</td><td>'.WebGUI::Form::checkbox("displayTitle",1).'</td></tr>';
                $output .= '<tr><td class="formDescription">Process Macros?</td><td>'.WebGUI::Form::checkbox("processMacros",1).'</td></tr>';
                $output .= '<tr><td class="formDescription">Description</td><td>'.WebGUI::Form::textArea("description",'').'</td></tr>';
                $output .= '<tr><td class="formDescription">Starting from this level?</td><td>'.WebGUI::Form::checkbox("startAtThisLevel",1,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">Show only one level?</td><td>'.WebGUI::Form::checkbox("showOnlyThisLevel",1,1).'</td></tr>';
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
		WebGUI::SQL->write("insert into SiteMap values ($widgetId, '$session{form}{startAtThisLevel}', '$session{form}{showOnlyThisLevel}')",$session{dbh});
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
		%data = WebGUI::SQL->quickHash("select * from widget,SiteMap where widget.widgetId=SiteMap.widgetId and widget.widgetId=$session{form}{wid}",$session{dbh});
                $output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=31"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a><h1>Edit Site Map</h1><form method="post" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","editSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">Title</td><td>'.WebGUI::Form::text("title",20,30,$data{title}).'</td></tr>';
                $output .= '<tr><td class="formDescription">Display title?</td><td>'.WebGUI::Form::checkbox("displayTitle",1,$data{displayTitle}).'</td></tr>';
                $output .= '<tr><td class="formDescription">Process Macros?</td><td>'.WebGUI::Form::checkbox("processMacros",1,$data{processMacros}).'</td></tr>';
                $output .= '<tr><td class="formDescription">Description</td><td>'.WebGUI::Form::textArea("description",$data{description}).'</td></tr>';
                $output .= '<tr><td class="formDescription">Starting from this level?</td><td>'.WebGUI::Form::checkbox("startAtThisLevel",1,$data{startAtThisLevel}).'</td></tr>';
                $output .= '<tr><td class="formDescription">Show only one level?</td><td>'.WebGUI::Form::checkbox("showOnlyThisLevel",1,$data{showOnlyThisLevel}).'</td></tr>';
		$output .= '<tr><td></td><td>'.WebGUI::Form::submit("save").'</td></tr>';
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
		WebGUI::SQL->write("update SiteMap set startAtThisLevel='$session{form}{startAtThisLevel}', showOnlyThisLevel='$session{form}{showOnlyThisLevel}' where widgetId=$session{form}{wid}",$session{dbh});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_view {
	my (%data, $output, $sth, @root, $parent);
	tie %data, 'Tie::CPHash';
	%data = WebGUI::SQL->quickHash("select * from widget,SiteMap where widget.widgetId=SiteMap.widgetId and widget.widgetId='$_[0]'",$session{dbh});
	if (defined %data) {
		if ($data{displayTitle} eq 1) {
			$output = '<h1>'.$data{title}.'</h1>';
		}
		$output .= $data{description}.'<p>';
		if ($data{startAtThisLevel} eq 1) {
			$parent = $session{page}{pageId};
		} else {
			$parent = 1;
		}
		$sth = WebGUI::SQL->read("select urlizedTitle, title, pageId from page where parentId='$parent' order by sequenceNumber",$session{dbh});	
		while (@root = $sth->array) {	
			if (WebGUI::Privilege::canViewPage($root[2])) {
				$output .= '&middot; <a href="'.$session{env}{SCRIPT_NAME}.'/'.$root[0].'">'.$root[1].'</a><br>';
				unless ($data{showOnlyThisLevel} eq 1) {
					$output .= _traversePageTree($root[2],1);
				}
			}
		}
		$sth->finish;
		if ($data{processMacros}) {
			$output = WebGUI::Macro::process($output);
		}
	}
	return $output;
}







1;
