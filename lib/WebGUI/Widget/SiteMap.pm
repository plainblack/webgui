package WebGUI::Widget::SiteMap;

our $namespace = "SiteMap";

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
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
use WebGUI::Shortcut;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Widget;

#-------------------------------------------------------------------
sub _traversePageTree {
        my ($lineSpacing, $sth, @data, $output, $depth, $i, $toLevel);
        if ($_[2] > 0) {
                $toLevel = $_[2];
        } else {
                $toLevel = 99;
        }
        for ($i=1;$i<=($_[1]*$_[3]);$i++) {
                $depth .= "&nbsp;";
        }
	for ($i=1;$i<=$_[5];$i++) {
		$lineSpacing .= "<br>";
	}
        if ($_[1] < $toLevel) {
                $sth = WebGUI::SQL->read("select urlizedTitle, title, pageId, synopsis from page where parentId='$_[0]' order by sequenceNumber");
                while (@data = $sth->array) {
                        if (WebGUI::Privilege::canViewPage($data[2])) {
                                $output .= $depth.$_[4].' <a href="'.WebGUI::URL::gateway($data[0])
					.'">'.$data[1].'</a>';
				if ($data[3] ne "" && $_[6]) {
					$output .= ' - '.$data[3];
				}
				$output .= $lineSpacing;
                                $output .= _traversePageTree($data[2],($_[1]+1),$_[2],$_[3],$_[4],$_[5],$_[6]);
                        }
                }
                $sth->finish;
        }
        return $output;
}

#-------------------------------------------------------------------
sub duplicate {
        my (%data, $newWidgetId, $pageId);
        tie %data, 'Tie::CPHash';
        %data = getProperties($namespace,$_[0]);
	$pageId = $_[1] || $data{pageId};
        $newWidgetId = create($pageId,$namespace,$data{title},$data{displayTitle},$data{description},$data{processMacros},$data{templatePosition});
	WebGUI::SQL->write("insert into SiteMap values ($newWidgetId, '$data{startAtThisLevel}', '$data{depth}', '$data{indent}', ".quote($data{bullet}).", '$data{lineSpacing}', '$data{displaySynopsis}')");
}

#-------------------------------------------------------------------
sub purge {
        purgeWidget($_[0],$_[1],$namespace);
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
                $output = helpLink(1,$namespace);
		$output .= '<h1>'.WebGUI::International::get(1,$namespace).'</h1>';
		$output .= formHeader();
                $output .= WebGUI::Form::hidden("widget",$namespace);
                $output .= WebGUI::Form::hidden("func","addSave");
                $output .= '<table>';
                $output .= tableFormRow(WebGUI::International::get(99),WebGUI::Form::text("title",20,128,'Site Map'));
                $output .= tableFormRow(WebGUI::International::get(174),WebGUI::Form::checkbox("displayTitle",1,1));
                $output .= tableFormRow(WebGUI::International::get(175),WebGUI::Form::checkbox("processMacros",1));
		%hash = WebGUI::Widget::getPositions();
                $output .= tableFormRow(WebGUI::International::get(363),
			WebGUI::Form::selectList("templatePosition",\%hash));
                $output .= tableFormRow(WebGUI::International::get(85),WebGUI::Form::textArea("description",'',50,5,1));
                $output .= tableFormRow(WebGUI::International::get(9,$namespace),
			WebGUI::Form::checkbox("displaySynopsis",1,1));
                $output .= tableFormRow(WebGUI::International::get(3,$namespace),
			WebGUI::Form::checkbox("startAtThisLevel",1,1));
                $output .= tableFormRow(WebGUI::International::get(4,$namespace),WebGUI::Form::text("depth",20,2,0));
                $output .= tableFormRow(WebGUI::International::get(6,$namespace),WebGUI::Form::text("indent",20,2,5));
                $output .= tableFormRow(WebGUI::International::get(7,$namespace),
			WebGUI::Form::text("bullet",20,30,'&middot;'));
                $output .= tableFormRow(WebGUI::International::get(8,$namespace),
			WebGUI::Form::text("lineSpacing",20,1,1));
                $output .= formSave();
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
		$widgetId = create($session{page}{pageId},$session{form}{widget},$session{form}{title},$session{form}{displayTitle},$session{form}{description},$session{form}{processMacros},$session{form}{templatePosition});
		WebGUI::SQL->write("insert into SiteMap values ($widgetId, '$session{form}{startAtThisLevel}', '$session{form}{depth}', '$session{form}{indent}', ".quote($session{form}{bullet}).", '$session{form}{lineSpacing}', '$session{form}{displaySynopsis}')");
		return "";
	} else {
		return WebGUI::Privilege::insufficient();
	}
}

#-------------------------------------------------------------------
sub www_copy {
        if (WebGUI::Privilege::canEditPage()) {
                duplicate($session{form}{wid});
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
		%data = getProperties($namespace,$session{form}{wid});
                $output = helpLink(1,$namespace);
		$output .= '<h1>'.WebGUI::International::get(5,$namespace).'</h1>';
		$output .= formHeader();
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","editSave");
                $output .= '<table>';
                $output .= tableFormRow(WebGUI::International::get(99),
			WebGUI::Form::text("title",20,128,$data{title}));
                $output .= tableFormRow(WebGUI::International::get(174),
			WebGUI::Form::checkbox("displayTitle",1,$data{displayTitle}));
                $output .= tableFormRow(WebGUI::International::get(175),
			WebGUI::Form::checkbox("processMacros",1,$data{processMacros}));
		%hash = WebGUI::Widget::getPositions();
                $array[0] = $data{templatePosition};
                $output .= tableFormRow(WebGUI::International::get(363),
			WebGUI::Form::selectList("templatePosition",\%hash,\@array));
                $output .= tableFormRow(WebGUI::International::get(85),
			WebGUI::Form::textArea("description",$data{description},50,5,1));
                $output .= tableFormRow(WebGUI::International::get(9,$namespace),
                        WebGUI::Form::checkbox("displaySynopsis",1,$data{displaySynopsis}));
                $output .= tableFormRow(WebGUI::International::get(3,$namespace),
			WebGUI::Form::checkbox("startAtThisLevel",1,$data{startAtThisLevel}));
                $output .= tableFormRow(WebGUI::International::get(4,$namespace),
			WebGUI::Form::text("depth",20,2,$data{depth}));
                $output .= tableFormRow(WebGUI::International::get(6,$namespace),
			WebGUI::Form::text("indent",20,2,$data{indent}));
                $output .= tableFormRow(WebGUI::International::get(7,$namespace),
			WebGUI::Form::text("bullet",20,30,$data{bullet}));
                $output .= tableFormRow(WebGUI::International::get(8,$namespace),
			WebGUI::Form::text("lineSpacing",20,1,$data{lineSpacing}));
		$output .= formSave();
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
		WebGUI::SQL->write("update SiteMap set startAtThisLevel='$session{form}{startAtThisLevel}', depth='$session{form}{depth}', indent='$session{form}{indent}', bullet=".quote($session{form}{bullet}).", lineSpacing='$session{form}{lineSpacing}' where widgetId=$session{form}{wid}");
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_view {
	my (%data, $output, $parent);
	tie %data, 'Tie::CPHash';
	%data = getProperties($namespace,$_[0]);
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
		$output .= _traversePageTree($parent,0,$data{depth},$data{indent},$data{bullet},$data{lineSpacing},$data{displaySynopsis});
		if ($data{processMacros}) {
			$output = WebGUI::Macro::process($output);
		}
	}
	return $output;
}







1;
