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
use WebGUI::Macro;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;
use WebGUI::Widget;

#-------------------------------------------------------------------
sub widgetName {
	return "Article";
}

#-------------------------------------------------------------------
sub www_add {
        my ($output);
      	if (WebGUI::Privilege::canEditPage()) {
                $output = '<h1>Add Article</h1><form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("widget","Article");
                $output .= WebGUI::Form::hidden("func","addSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">Title</td><td>'.WebGUI::Form::text("title",20,30).'</td></tr>';
                $output .= '<tr><td class="formDescription">Display the title?</td><td>'.WebGUI::Form::checkbox("displayTitle",1).'</td></tr>';
                $output .= '<tr><td class="formDescription">Process macros?</td><td>'.WebGUI::Form::checkbox("processMacros",1,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">Start Date</td><td>'.WebGUI::Form::text("startDate",20,30,'01/01/2000',1).'</td></tr>';
                $output .= '<tr><td class="formDescription">End Date</td><td>'.WebGUI::Form::text("endDate",20,30,'01/01/2100',1).'</td></tr>';
                $output .= '<tr><td class="formDescription">Body</td><td>'.WebGUI::Form::textArea("body",'',50,10,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">Image</td><td>'.WebGUI::Form::file("image").'</td></tr>';
                $output .= '<tr><td class="formDescription">Link Title</td><td>'.WebGUI::Form::text("linkTitle",20,30).'</td></tr>';
                $output .= '<tr><td class="formDescription">Link URL</td><td>'.WebGUI::Form::text("linkURL",20,2048).'</td></tr>';
                $output .= '<tr><td class="formDescription">Attachment</td><td>'.WebGUI::Form::file("attachment").'</td></tr>';
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
		$image = saveAttachment("image",$widgetId);
		$attachment = saveAttachment("attachment",$widgetId);
		WebGUI::SQL->write("insert into Article set widgetId=$widgetId, startDate='".humanToMysqlDate($session{form}{startDate})."', endDate='".humanToMysqlDate($session{form}{endDate})."', body=".quote($session{form}{body}).", image=".quote($image).", linkTitle=".quote($session{form}{linkTitle}).", linkURL=".quote($session{form}{linkURL}).", attachment=".quote($attachment),$session{dbh});
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
        if (WebGUI::Privilege::canEditPage()) {
		%article = WebGUI::SQL->quickHash("select widget.title, widget.displayTitle, date_format(Article.startDate,'%m/%d/%Y') as start, date_format(Article.endDate,'%m/%d/%Y') as end, Article.body, Article.image, Article.linkTitle, Article.linkURL, Article.attachment, widget.processMacros from widget left join Article on (widget.widgetId=Article.widgetId) where widget.widgetId=$session{form}{wid}",$session{dbh});
                $output = '<h1>Edit Article</h1><form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","editSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">Title</td><td>'.WebGUI::Form::text("title",20,30,$article{title}).'</td></tr>';
                $output .= '<tr><td class="formDescription">Display the title?</td><td>'.WebGUI::Form::checkbox("displayTitle","1",$article{displayTitle}).'</td></tr>';
                $output .= '<tr><td class="formDescription">Process macros?</td><td>'.WebGUI::Form::checkbox("processMacros","1",$article{processMacros}).'</td></tr>';
                $output .= '<tr><td class="formDescription">Start Date</td><td>'.WebGUI::Form::text("startDate",20,30,$article{start},1).'</td></tr>';
                $output .= '<tr><td class="formDescription">End Date</td><td>'.WebGUI::Form::text("endDate",20,30,$article{end},1).'</td></tr>';
                $output .= '<tr><td class="formDescription">Body</td><td>'.WebGUI::Form::textArea("body",$article{body},50,10,1).'</td></tr>';
		if ($article{image} ne "") {
                	$output .= '<tr><td class="formDescription">Image</td><td><a href="'.$session{page}{url}.'?func=deleteImage&wid='.$session{form}{wid}.'">Delete Image</a></td></tr>';
		} else {
                	$output .= '<tr><td class="formDescription">Image</td><td>'.WebGUI::Form::file("image").'</td></tr>';
		}
                $output .= '<tr><td class="formDescription">Link Title</td><td>'.WebGUI::Form::text("linkTitle",20,30,$article{linkTitle}).'</td></tr>';
                $output .= '<tr><td class="formDescription">Link URL</td><td>'.WebGUI::Form::text("linkURL",20,2048,$article{linkURL}).'</td></tr>';
		if ($article{attachment} ne "") {
                	$output .= '<tr><td class="formDescription">Attachment</td><td><a href="'.$session{page}{url}.'?func=deleteAttachment&wid='.$session{form}{wid}.'">Delete Attachment</a></td></tr>';
		} else {
                	$output .= '<tr><td class="formDescription">Attachment</td><td>'.WebGUI::Form::file("attachment").'</td></tr>';
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
        my ($widgetId, $displayTitle, $image, $attachment);
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
                WebGUI::SQL->write("update Article set startDate='".humanToMysqlDate($session{form}{startDate})."', endDate='".humanToMysqlDate($session{form}{endDate})."', body=".quote($session{form}{body}).", linkTitle=".quote($session{form}{linkTitle}).", linkURL=".quote($session{form}{linkURL}).$attachment.$image." where widgetId=$session{form}{wid}",$session{dbh});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_view {
	my (%data, @test, $output, $widgetId);
	$widgetId = shift;
	%data = WebGUI::SQL->quickHash("select widget.title, widget.displayTitle, widget.processMacros, Article.body, Article.image, Article.linkTitle, Article.linkURL, Article.attachment from widget,Article where widget.widgetId='$widgetId' and widget.WidgetId=Article.widgetId and Article.startDate<now() and Article.endDate>now()",$session{dbh});
	if (defined %data) {
		if ($data{displayTitle} == 1) {
			$output = "<h2>".$data{title}."</h2>";
		}
		if ($data{image} ne "") {
			$output .= '<img src="'.$session{setting}{attachmentDirectoryWeb}.'/'.$widgetId.'/'.$data{image}.'" border="0" align="right">';
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
