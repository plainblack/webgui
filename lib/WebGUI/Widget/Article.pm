package WebGUI::Widget::Article;

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
use WebGUI::DateTime;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;
use WebGUI::Widget;

#-------------------------------------------------------------------
sub purge {
	WebGUI::SQL->write("delete from Article where widgetId=$_[0]",$_[1]);
	purgeWidget($_[0],$_[1]);
}

#-------------------------------------------------------------------
sub widgetName {
	return WebGUI::International::get(172);
}

#-------------------------------------------------------------------
sub www_add {
        my ($output);
      	if (WebGUI::Privilege::canEditPage()) {
                $output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=23"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
		$output .= '<h1>'.WebGUI::International::get(173).'</h1>';
		$output .= '<form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("widget","Article");
                $output .= WebGUI::Form::hidden("func","addSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(99).'</td><td>'.WebGUI::Form::text("title",20,30,'Article').'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(174).'</td><td>'.WebGUI::Form::checkbox("displayTitle",1,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(175).'</td><td>'.WebGUI::Form::checkbox("processMacros",1,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(176).'</td><td>'.WebGUI::Form::text("startDate",20,30,epochToSet(time()),1).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(177).'</td><td>'.WebGUI::Form::text("endDate",20,30,'01/01/2037',1).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(178).'</td><td>'.WebGUI::Form::textArea("body",'',50,10,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(179).'</td><td>'.WebGUI::Form::file("image").'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(180).'</td><td>'.WebGUI::Form::text("linkTitle",20,30).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(181).'</td><td>'.WebGUI::Form::text("linkURL",20,2048).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(182).'</td><td>'.WebGUI::Form::file("attachment").'</td></tr>';
		$output .= '<tr><td class="formDescription">'.WebGUI::International::get(183).'</td><td>'.WebGUI::Form::checkbox("convertCarriageReturns",1).' <span style="font-size: 8pt;">'.WebGUI::International::get(184).'</span></td></tr>';
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
	my ($widgetId, $image, $attachment);
	if (WebGUI::Privilege::canEditPage()) {
		$widgetId = create();
		$image = saveAttachment("image",$widgetId);
		$attachment = saveAttachment("attachment",$widgetId);
		WebGUI::SQL->write("insert into Article values ($widgetId, '".setToEpoch($session{form}{startDate})."', '".setToEpoch($session{form}{endDate})."', ".quote($session{form}{body}).", ".quote($image).", ".quote($session{form}{linkTitle}).", ".quote($session{form}{linkURL}).", ".quote($attachment).", '$session{form}{convertCarriageReturns}')",$session{dbh});
		return "";
	} else {
		return WebGUI::Privilege::insufficient();
	}
}

#-------------------------------------------------------------------
sub www_deleteAttachment {
        if (WebGUI::Privilege::canEditPage()) {
		WebGUI::SQL->write("update Article set attachment='' where widgetId=$session{form}{wid}",$session{dbh});
		return www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteImage {
        if (WebGUI::Privilege::canEditPage()) {
                WebGUI::SQL->write("update Article set image='' where widgetId=$session{form}{wid}",$session{dbh});
                return www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_edit {
        my ($output, %article);
	tie %article, 'Tie::CPHash';
        if (WebGUI::Privilege::canEditPage()) {
		%article = WebGUI::SQL->quickHash("select * from widget,Article where widget.widgetId=Article.widgetId and widget.widgetId=$session{form}{wid}",$session{dbh});
                $output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=23"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
		$output .= '<h1>'.WebGUI::International::get(185).'</h1>';
		$output .= '<form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","editSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(99).'</td><td>'.WebGUI::Form::text("title",20,30,$article{title}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(174).'</td><td>'.WebGUI::Form::checkbox("displayTitle","1",$article{displayTitle}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(175).'</td><td>'.WebGUI::Form::checkbox("processMacros","1",$article{processMacros}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(176).'</td><td>'.WebGUI::Form::text("startDate",20,30,epochToSet($article{startDate}),1).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(177).'</td><td>'.WebGUI::Form::text("endDate",20,30,epochToSet($article{endDate}),1).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(178).'</td><td>'.WebGUI::Form::textArea("body",$article{body},50,10,1).'</td></tr>';
		if ($article{image} ne "") {
                	$output .= '<tr><td class="formDescription">'.WebGUI::International::get(179).'</td><td><a href="'.$session{page}{url}.'?func=deleteImage&wid='.$session{form}{wid}.'">'.WebGUI::International::get(186).'</a></td></tr>';
		} else {
                	$output .= '<tr><td class="formDescription">'.WebGUI::International::get(179).'</td><td>'.WebGUI::Form::file("image").'</td></tr>';
		}
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(180).'</td><td>'.WebGUI::Form::text("linkTitle",20,30,$article{linkTitle}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(181).'</td><td>'.WebGUI::Form::text("linkURL",20,2048,$article{linkURL}).'</td></tr>';
		if ($article{attachment} ne "") {
                	$output .= '<tr><td class="formDescription">'.WebGUI::International::get(182).'</td><td><a href="'.$session{page}{url}.'?func=deleteAttachment&wid='.$session{form}{wid}.'">'.WebGUI::International::get(186).'</a></td></tr>';
		} else {
                	$output .= '<tr><td class="formDescription">'.WebGUI::International::get(182).'</td><td>'.WebGUI::Form::file("attachment").'</td></tr>';
		}
		$output .= '<tr><td class="formDescription">'.WebGUI::International::get(183).'</td><td>'.WebGUI::Form::checkbox("convertCarriageReturns",1,$article{convertCarriageReturns}).' <span style="font-size: 8pt;">'.WebGUI::International::get(184).'</span></td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(62)).'</td></tr>';
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
                $image = saveAttachment("image",$session{form}{wid});
		if ($image ne "") {
			$image = ', image='.quote($image);
		}
                $attachment = saveAttachment("attachment",$session{form}{wid});
		if ($attachment ne "") {
                        $attachment = ', attachment='.quote($attachment);
                }
                WebGUI::SQL->write("update Article set startDate='".setToEpoch($session{form}{startDate})."', endDate='".setToEpoch($session{form}{endDate})."', convertCarriageReturns='$session{form}{convertCarriageReturns}', body=".quote($session{form}{body}).", linkTitle=".quote($session{form}{linkTitle}).", linkURL=".quote($session{form}{linkURL}).$attachment.$image." where widgetId=$session{form}{wid}",$session{dbh});
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
	%data = WebGUI::SQL->quickHash("select widget.title, widget.displayTitle, widget.processMacros, Article.body, Article.image, Article.linkTitle, Article.linkURL, Article.attachment, Article.convertCarriageReturns from widget,Article where widget.widgetId='$widgetId' and widget.WidgetId=Article.widgetId and Article.startDate<".time()." and Article.endDate>".time()."",$session{dbh});
	if (defined %data) {
		if ($data{displayTitle} == 1) {
			$output = "<h1>".$data{title}."</h1>";
		}
		if ($data{image} ne "") {
			$output .= '<img src="'.$session{setting}{attachmentDirectoryWeb}.'/'.$widgetId.'/'.$data{image}.'" border="0" align="right">';
		}
		if ($data{convertCarriageReturns}) {
			$data{body} =~ s/\n/\<br\>/g;
		}
		$output .= $data{body};
                if ($data{linkURL} ne "" && $data{linkTitle} ne "") {
                        $output .= '<p><a href="'.$data{linkURL}.'">'.$data{linkTitle}.'</a>';
                }
		if ($data{attachment} ne "") {
			$output .= '<p><a href="'.$session{setting}{attachmentDirectoryWeb}.'/'.$widgetId.'/'.$data{attachment}.'"><img src="'.$session{setting}{lib}.'/attachment.gif" border=0 alt="Download Attachment"></a>';
		}
	}
	if ($data{processMacros} == 1) {
		$output = WebGUI::Macro::process($output);
	}
	return $output;
}




1;

