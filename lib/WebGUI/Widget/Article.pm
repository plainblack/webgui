package WebGUI::Widget::Article;

our $namespace = "Article";

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
use WebGUI::DateTime;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::Shortcut;
use WebGUI::SQL;
use WebGUI::Widget;

#-------------------------------------------------------------------
sub duplicate {
	my (%data, $newWidgetId, $pageId);
	tie %data, 'Tie::CPHash';
	%data = getProperties($namespace,$_[0]);
	$pageId = $_[1] || $data{pageId};
	$newWidgetId = create($pageId,$namespace,$data{title},$data{displayTitle},$data{description},$data{processMacros},$data{position});
	WebGUI::Attachment::copy($data{image},$_[0],$newWidgetId);
	WebGUI::Attachment::copy($data{attachment},$_[0],$newWidgetId);
	WebGUI::SQL->write("insert into Article values ($newWidgetId, $data{startDate}, $data{endDate}, ".quote($data{body}).", ".quote($data{image}).", ".quote($data{linkTitle}).", ".quote($data{linkURL}).", ".quote($data{attachment}).", '$data{convertCarriageReturns}')");
}

#-------------------------------------------------------------------
sub purge {
	purgeWidget($_[0],$_[1],$namespace);
}

#-------------------------------------------------------------------
sub widgetName {
	return WebGUI::International::get(1,$namespace);
}

#-------------------------------------------------------------------
sub www_add {
        my ($output, %hash);
	tie %hash, "Tie::IxHash";
      	if (WebGUI::Privilege::canEditPage()) {
                $output = helpLink(1,$namespace);
		$output .= '<h1>'.WebGUI::International::get(2,$namespace).'</h1>';
		$output .= formHeader();
                $output .= WebGUI::Form::hidden("widget",$namespace);
                $output .= WebGUI::Form::hidden("func","addSave");
                $output .= '<table>';
                $output .= tableFormRow(WebGUI::International::get(99),WebGUI::Form::text("title",20,128,'Article'));
                $output .= tableFormRow(WebGUI::International::get(174),WebGUI::Form::checkbox("displayTitle",1,1));
                $output .= tableFormRow(WebGUI::International::get(175),WebGUI::Form::checkbox("processMacros",1,1));
		%hash = WebGUI::Widget::getPositions();
                $output .= tableFormRow(WebGUI::International::get(363),WebGUI::Form::selectList("position",\%hash));
                $output .= tableFormRow(WebGUI::International::get(3,$namespace),WebGUI::Form::text("startDate",20,30,epochToSet(time()),1));
                $output .= tableFormRow(WebGUI::International::get(4,$namespace),WebGUI::Form::text("endDate",20,30,'01/01/2037',1));
                $output .= tableFormRow(WebGUI::International::get(5,$namespace),WebGUI::Form::textArea("body",'',50,10,1));
                $output .= tableFormRow(WebGUI::International::get(6,$namespace),WebGUI::Form::file("image"));
                $output .= tableFormRow(WebGUI::International::get(7,$namespace),WebGUI::Form::text("linkTitle",20,128));
                $output .= tableFormRow(WebGUI::International::get(8,$namespace),WebGUI::Form::text("linkURL",20,2048));
                $output .= tableFormRow(WebGUI::International::get(9,$namespace),WebGUI::Form::file("attachment"));
		$output .= tableFormRow(WebGUI::International::get(10,$namespace),WebGUI::Form::checkbox("convertCarriageReturns",1).' <span style="font-size: 8pt;">'.WebGUI::International::get(11,$namespace).'</span>');
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
	my ($widgetId, $image, $attachment);
	if (WebGUI::Privilege::canEditPage()) {
		$widgetId = create($session{page}{pageId},$session{form}{widget},$session{form}{title},$session{form}{displayTitle},$session{form}{description},$session{form}{processMacros},$session{form}{position});
		$image = WebGUI::Attachment::save("image",$widgetId);
		$attachment = WebGUI::Attachment::save("attachment",$widgetId);
		WebGUI::SQL->write("insert into Article values ($widgetId, '".setToEpoch($session{form}{startDate})."', '".setToEpoch($session{form}{endDate})."', ".quote($session{form}{body}).", ".quote($image).", ".quote($session{form}{linkTitle}).", ".quote($session{form}{linkURL}).", ".quote($attachment).", '$session{form}{convertCarriageReturns}')");
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
		WebGUI::SQL->write("update Article set attachment='' where widgetId=$session{form}{wid}");
		return www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteImage {
        if (WebGUI::Privilege::canEditPage()) {
                WebGUI::SQL->write("update Article set image='' where widgetId=$session{form}{wid}");
                return www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_edit {
        my ($output, %data, %hash, @array);
	tie %hash, 'Tie::IxHash';
	tie %data, 'Tie::CPHash';
        if (WebGUI::Privilege::canEditPage()) {
		%data = getProperties($namespace,$session{form}{wid});
                $output = helpLink(1,$namespace);
		$output .= '<h1>'.WebGUI::International::get(12,$namespace).'</h1>';
		$output .= formHeader();
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","editSave");
                $output .= '<table>';
                $output .= tableFormRow(WebGUI::International::get(99),WebGUI::Form::text("title",20,128,$data{title}));
                $output .= tableFormRow(WebGUI::International::get(174),WebGUI::Form::checkbox("displayTitle","1",$data{displayTitle}));
                $output .= tableFormRow(WebGUI::International::get(175),WebGUI::Form::checkbox("processMacros","1",$data{processMacros}));
		%hash = WebGUI::Widget::getPositions();
		$array[0] = $data{position};
                $output .= tableFormRow(WebGUI::International::get(363),WebGUI::Form::selectList("position",\%hash,\@array));
                $output .= tableFormRow(WebGUI::International::get(3,$namespace),WebGUI::Form::text("startDate",20,30,epochToSet($data{startDate}),1));
                $output .= tableFormRow(WebGUI::International::get(4,$namespace),WebGUI::Form::text("endDate",20,30,epochToSet($data{endDate}),1));
                $output .= tableFormRow(WebGUI::International::get(5,$namespace),WebGUI::Form::textArea("body",$data{body},50,10,1));
		if ($data{image} ne "") {
                	$output .= tableFormRow(WebGUI::International::get(6,$namespace),'<a href="'.$session{page}{url}.'?func=deleteImage&wid='.$session{form}{wid}.'">'.WebGUI::International::get(13,$namespace).'</a>');
		} else {
                	$output .= tableFormRow(WebGUI::International::get(6,$namespace),WebGUI::Form::file("image"));
		}
                $output .= tableFormRow(WebGUI::International::get(7,$namespace),WebGUI::Form::text("linkTitle",20,128,$data{linkTitle}));
                $output .= tableFormRow(WebGUI::International::get(8,$namespace),WebGUI::Form::text("linkURL",20,2048,$data{linkURL}));
		if ($data{attachment} ne "") {
                	$output .= tableFormRow(WebGUI::International::get(9,$namespace),'<a href="'.$session{page}{url}.'?func=deleteAttachment&wid='.$session{form}{wid}.'">'.WebGUI::International::get(13,$namespace).'</a>');
		} else {
                	$output .= tableFormRow(WebGUI::International::get(9,$namespace),WebGUI::Form::file("attachment"));
		}
		$output .= tableFormRow(WebGUI::International::get(10,$namespace),WebGUI::Form::checkbox("convertCarriageReturns",1,$data{convertCarriageReturns}).' <span style="font-size: 8pt;">'.WebGUI::International::get(11,$namespace).'</span>');
                $output .= formSave();
                $output .= '</table></form>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editSave {
        my ($image, $attachment);
        if (WebGUI::Privilege::canEditPage()) {
		update();
                $image = WebGUI::Attachment::save("image",$session{form}{wid});
		if ($image ne "") {
			$image = ', image='.quote($image);
		}
                $attachment = WebGUI::Attachment::save("attachment",$session{form}{wid});
		if ($attachment ne "") {
                        $attachment = ', attachment='.quote($attachment);
                }
                WebGUI::SQL->write("update Article set startDate='".setToEpoch($session{form}{startDate})."', endDate='".setToEpoch($session{form}{endDate})."', convertCarriageReturns='$session{form}{convertCarriageReturns}', body=".quote($session{form}{body}).", linkTitle=".quote($session{form}{linkTitle}).", linkURL=".quote($session{form}{linkURL}).$attachment.$image." where widgetId=$session{form}{wid}");
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_view {
	my (%data, @test, $output);
	tie %data, 'Tie::CPHash';
	%data = getProperties($namespace,$_[0]);
	if ($data{startDate}<time() && $data{endDate}>time()) {
		if ($data{displayTitle} == 1) {
			$output = "<h1>".$data{title}."</h1>";
		}
		if ($data{image} ne "") {
			$output .= '<img src="'.$session{setting}{attachmentDirectoryWeb}.'/'.$_[0].'/'.$data{image}.'" border="0" align="right">';
		}
		if ($data{convertCarriageReturns}) {
			$data{body} =~ s/\n/\<br\>/g;
		}
		$output .= $data{body};
                if ($data{linkURL} ne "" && $data{linkTitle} ne "") {
                        $output .= '<p><a href="'.$data{linkURL}.'">'.$data{linkTitle}.'</a>';
                }
		if ($data{attachment} ne "") {
			$output .= '<p><a href="'.$session{setting}{attachmentDirectoryWeb}.'/'.$_[0].'/'.$data{attachment}.'"><img src="'.$session{setting}{lib}.'/attachment.gif" border=0 alt="'.WebGUI::International::get(14,$namespace).'"></a>';
		}
	}
	if ($data{processMacros} == 1) {
		$output = WebGUI::Macro::process($output);
	}
	return $output;
}




1;

