package WebGUI::Widget::SiteMap;

our $namespace = "SiteMap";

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
use WebGUI::Macro;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;
use WebGUI::Widget;

#-------------------------------------------------------------------
sub _traversePageTree {
        my ($lineSpacing, $sth, @data, $output, $depth, $i, $toLevel);
        if ($_[2] > 0) {
                $toLevel = $_[2];
        } else {
                $toLevel = 99;
        }
        for ($i=1;$i<=$_[1]*$_[3];$i++) {
                $depth .= "&nbsp;";
        }
	for ($i=1;$i<=$_[5];$i++) {
		$lineSpacing .= "<br>";
	}
        if ($_[1] < $toLevel) {
                $sth = WebGUI::SQL->read("select urlizedTitle, title, pageId from page where parentId='$_[0]' order by sequenceNumber",$session{dbh});
                while (@data = $sth->array) {
                        if (WebGUI::Privilege::canViewPage($data[2])) {
                                $output .= $depth.$_[4].' <a href="'.$session{env}{SCRIPT_NAME}.'/'.$data[0].'">'.$data[1].'</a>';
				$output .= $lineSpacing;
                                $output .= _traversePageTree($data[2],$_[1]+1,$_[2],$_[3],$_[4],$_[5]);
                        }
                }
                $sth->finish;
        }
        return $output;
}

#-------------------------------------------------------------------
sub purge {
        WebGUI::SQL->write("delete from SiteMap where widgetId=$_[0]",$_[1]);
        purgeWidget($_[0],$_[1]);
}

#-------------------------------------------------------------------
sub widgetName {
	return WebGUI::International::get(2,$namespace);
}

#-------------------------------------------------------------------
sub www_add {
        my ($output, %hash);
	tie %hash, 'Tie::IxHash';
      	if (WebGUI::Privilege::canEditPage()) {
                $output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=1&namespace='.$namespace.'"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
		$output .= '<h1>'.WebGUI::International::get(1,$namespace).'</h1>';
		$output .= '<form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("widget",$namespace);
                $output .= WebGUI::Form::hidden("func","addSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(99).'</td><td>'.WebGUI::Form::text("title",20,128,'Site Map').'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(174).'</td><td>'.WebGUI::Form::checkbox("displayTitle",1,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(175).'</td><td>'.WebGUI::Form::checkbox("processMacros",1).'</td></tr>';
		%hash = WebGUI::Widget::getPositions();
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(363).'</td><td>'.WebGUI::Form::selectList("position",\%hash).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(85).'</td><td>'.WebGUI::Form::textArea("description",'',50,5,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(3,$namespace).'</td><td>'.WebGUI::Form::checkbox("startAtThisLevel",1,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(4,$namespace).'</td><td>'.WebGUI::Form::text("depth",20,2,0).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(6,$namespace).'</td><td>'.WebGUI::Form::text("indent",20,2,5).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(7,$namespace).'</td><td>'.WebGUI::Form::text("bullet",20,30,'&middot;').'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(8,$namespace).'</td><td>'.WebGUI::Form::text("bullet",20,1,1).'</td></tr>';
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
		WebGUI::SQL->write("insert into SiteMap values ($widgetId, '$session{form}{startAtThisLevel}', '$session{form}{depth}', '$session{form}{indent}', ".quote($session{form}{bullet}).", '$session{form}{lineSpacing}')",$session{dbh});
		return "";
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
		%data = WebGUI::SQL->quickHash("select * from widget,SiteMap where widget.widgetId=SiteMap.widgetId and widget.widgetId=$session{form}{wid}",$session{dbh});
                $output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=1&namespace='.$namespace.'"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
		$output .= '<h1>'.WebGUI::International::get(5,$namespace).'</h1>';
		$output .= '<form method="post" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","editSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(99).'</td><td>'.WebGUI::Form::text("title",20,128,$data{title}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(174).'</td><td>'.WebGUI::Form::checkbox("displayTitle",1,$data{displayTitle}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(175).'</td><td>'.WebGUI::Form::checkbox("processMacros",1,$data{processMacros}).'</td></tr>';
		%hash = WebGUI::Widget::getPositions();
                $array[0] = $data{position};
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(363).'</td><td>'.WebGUI::Form::selectList("position",\%hash,\@array).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(85).'</td><td>'.WebGUI::Form::textArea("description",$data{description},50,5,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(3,$namespace).'</td><td>'.WebGUI::Form::checkbox("startAtThisLevel",1,$data{startAtThisLevel}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(4,$namespace).'</td><td>'.WebGUI::Form::text("depth",20,2,$data{depth}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(6,$namespace).'</td><td>'.WebGUI::Form::text("indent",20,2,$data{indent}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(7,$namespace).'</td><td>'.WebGUI::Form::text("bullet",20,30,$data{bullet}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(8,$namespace).'</td><td>'.WebGUI::Form::text("lineSpacing",20,1,$data{lineSpacing}).'</td></tr>';
		$output .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(62)).'</td></tr>';
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
		WebGUI::SQL->write("update SiteMap set startAtThisLevel='$session{form}{startAtThisLevel}', depth='$session{form}{depth}', indent='$session{form}{indent}', bullet=".quote($session{form}{bullet}).", lineSpacing='$session{form}{lineSpacing}' where widgetId=$session{form}{wid}",$session{dbh});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_view {
	my (%data, $output, $parent);
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
		$output .= _traversePageTree($parent,0,$data{depth},$data{indent},$data{bullet},$data{lineSpacing});
		if ($data{processMacros}) {
			$output = WebGUI::Macro::process($output);
		}
	}
	return $output;
}







1;
