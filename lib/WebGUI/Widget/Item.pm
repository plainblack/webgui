package WebGUI::Widget::Item;

our $namespace = "Item";

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
use WebGUI::Attachment;
use WebGUI::Form;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::Shortcut;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Widget;

#-------------------------------------------------------------------
sub duplicate {
        my (%data, $newWidgetId, $pageId, $file);
        tie %data, 'Tie::CPHash';
        %data = getProperties($namespace,$_[0]);
	$pageId = $_[1] || $data{pageId};
        $newWidgetId = create($pageId,$namespace,$data{title},
		$data{displayTitle},$data{description},$data{processMacros},$data{templatePosition});
	$file = WebGUI::Attachment->new($data{attachment},$_[0]);
	$file->copy($newWidgetId);
	WebGUI::SQL->write("insert into Item values ($newWidgetId, ".
		quote($data{description}).", ".quote($data{linkURL}).", ".quote($data{attachment}).")");
}

#-------------------------------------------------------------------
sub purge {
	purgeWidget($_[0],$_[1],$namespace);
}

#-------------------------------------------------------------------
sub widgetName {
	return WebGUI::International::get(4,$namespace);
}

#-------------------------------------------------------------------
sub www_add {
        my ($output, %hash);
	tie %hash,'Tie::IxHash';
      	if (WebGUI::Privilege::canEditPage()) {
		$output = helpLink(1,$namespace);
		$output .= '<h1>'.WebGUI::International::get(4,$namespace).'</h1>';
		$output .= formHeader();
                $output .= WebGUI::Form::hidden("widget",$namespace);
                $output .= WebGUI::Form::hidden("func","addSave");
                $output .= '<table>';
                $output .= tableFormRow(WebGUI::International::get(99),WebGUI::Form::text("title",20,30,widgetName()));
		$output .= tableFormRow(WebGUI::International::get(175),WebGUI::Form::checkbox("processMacros",1,1));
		%hash = WebGUI::Widget::getPositions();
                $output .= tableFormRow(WebGUI::International::get(363),WebGUI::Form::selectList("templatePosition",\%hash));
                $output .= tableFormRow(WebGUI::International::get(85),WebGUI::Form::textArea("description",''));
                $output .= tableFormRow(WebGUI::International::get(1,$namespace),WebGUI::Form::text("linkURL",20,2048));
                $output .= tableFormRow(WebGUI::International::get(2,$namespace),WebGUI::Form::file("attachment"));
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
	my ($widgetId, $attachment);
	if (WebGUI::Privilege::canEditPage()) {
		$widgetId = create($session{page}{pageId},$session{form}{widget},$session{form}{title},$session{form}{displayTitle},$session{form}{description},$session{form}{processMacros},$session{form}{templatePosition});
		$attachment = WebGUI::Attachment->new("",$widgetId);
		$attachment->save("attachment");
		WebGUI::SQL->write("insert into Item values ($widgetId, ".quote($session{form}{description}).", ".quote($session{form}{linkURL}).", ".quote($attachment).")");
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
sub www_deleteAttachment {
        if (WebGUI::Privilege::canEditPage()) {
		WebGUI::SQL->write("update Item set attachment='' where widgetId=$session{form}{wid}");
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
		%data = getProperties($namespace,$session{form}{wid});
		$output .= helpLink(1,$namespace);
		$output .= '<h1>'.WebGUI::International::get(4,$namespace).'</h1>';
		$output .= formHeader();
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","editSave");
                $output .= '<table>';
                $output .= tableFormRow(WebGUI::International::get(99),WebGUI::Form::text("title",20,30,$data{title}));
		$output .= tableFormRow(WebGUI::International::get(175),
			WebGUI::Form::checkbox("processMacros","1",$data{processMacros}));
		%hash = WebGUI::Widget::getPositions();
                $array[0] = $data{templatePosition};
                $output .= tableFormRow(WebGUI::International::get(363),
			WebGUI::Form::selectList("templatePosition",\%hash,\@array));
                $output .= tableFormRow(WebGUI::International::get(85),
			WebGUI::Form::textArea("description",$data{description}));
                $output .= tableFormRow(WebGUI::International::get(1,$namespace),
			WebGUI::Form::text("linkURL",20,2048,$data{linkURL}));
		if ($data{attachment} ne "") {
                	$output .= tableFormRow(WebGUI::International::get(2,$namespace),'<a href="'.
				WebGUI::URL::page('func=deleteAttachment&wid='.$session{form}{wid})
				.'">'.WebGUI::International::get(3,$namespace).'</a>');
		} else {
                	$output .= tableFormRow(WebGUI::International::get(2,$namespace),
				WebGUI::Form::file("attachment"));
		}
                $output .= formSave();
                $output .= '</table></form>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editSave {
        my ($attachment, $sqlAdd);
        if (WebGUI::Privilege::canEditPage()) {
		update();
                $attachment = WebGUI::Attachment->new("",$session{form}{wid});
		$attachment->save("attachment");
		if ($attachment->getFilename ne "") {
                        $sqlAdd = ', attachment='.quote($attachment->getFilename);
                }
                WebGUI::SQL->write("update Item set description=".quote($session{form}{description}).
			", linkURL=".quote($session{form}{linkURL}).
			$sqlAdd." where widgetId=$session{form}{wid}");
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_view {
	my (%data, @test, $output, $file);
	tie %data, 'Tie::CPHash';
	%data = getProperties($namespace,$_[0]);
	if (defined %data) {
                if ($data{linkURL} ne "") {
                        $output .= '<a href="'.$data{linkURL}.'"><span class="itemTitle">'.$data{title}.'</span></a>';
                } else {
			$output .= '<span class="itemTitle">'.$data{title}.'</span>';
		}
		if ($data{attachment} ne "") {
			$file = WebGUI::Attachment->new($data{attachment},$_[0]);
			$output .= ' - <a href="'.$file->getURL.'"><img src="'.$file->getIcon.'" border=0 alt="'.
				$data{attachment}.'" width=16 height=16 border=0 align="middle"></a>';
		}
		if ($data{description} ne "") {
			$output .= ' - '.$data{description};
		}
	}
        if ($data{processMacros} == 1) {
                $output = WebGUI::Macro::process($output);
        }
	return $output;
}




1;

