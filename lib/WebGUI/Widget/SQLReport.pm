package WebGUI::Widget::SQLReport;

our $namespace = "SQLReport";

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
use WebGUI::ErrorHandler;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;
use WebGUI::Widget;

#-------------------------------------------------------------------
sub purge {
        WebGUI::SQL->write("delete from SQLReport where widgetId=$_[0]",$_[1]);
        purgeWidget($_[0],$_[1]);
}

#-------------------------------------------------------------------
sub widgetName {
	return WebGUI::International::get(259);
}

#-------------------------------------------------------------------
sub www_add {
        my ($output, %hash);
	tie %hash, 'Tie::IxHash';
      	if (WebGUI::Privilege::canEditPage()) {
                $output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=1&namespace='.$namespace.'"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
		$output .= '<h1>'.WebGUI::International::get(260).'</h1>';
		$output .= '<form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("widget",$namespace);
                $output .= WebGUI::Form::hidden("func","addSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(99).'</td><td>'.WebGUI::Form::text("title",20,128,'SQL Report').'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(174).'</td><td>'.WebGUI::Form::checkbox("displayTitle",1,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(175).'</td><td>'.WebGUI::Form::checkbox("processMacros",1,1).'</td></tr>';
		%hash = WebGUI::Widget::getPositions();
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(363).'</td><td>'.WebGUI::Form::selectList("position",\%hash).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(85).'</td><td>'.WebGUI::Form::textArea("description",'','','',1).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(261).'</td><td>'.WebGUI::Form::textArea("template",'','','',1).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(262).'</td><td>'.WebGUI::Form::textArea("dbQuery",'').'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(263).'</td><td>'.WebGUI::Form::text("DSN",20,255,$session{config}{dsn}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(264).'</td><td>'.WebGUI::Form::text("username",20,255,$session{config}{dbuser}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(265).'</td><td>'.WebGUI::Form::password("identifier",20,255).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(183).'</td><td>'.WebGUI::Form::checkbox("convertCarriageReturns",1).'</td></tr>';
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
	my ($widgetId);
	if (WebGUI::Privilege::canEditPage()) {
		$widgetId = create();
		WebGUI::SQL->write("insert into SQLReport values($widgetId, ".quote($session{form}{template}).", ".quote($session{form}{dbQuery}).", ".quote($session{form}{DSN}).", ".quote($session{form}{username}).", ".quote($session{form}{identifier}).", '$session{form}{convertCarriageReturns}')",$session{dbh});
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
		%data = WebGUI::SQL->quickHash("select * from widget,SQLReport where widget.widgetId=$session{form}{wid} and widget.widgetId=SQLReport.widgetId",$session{dbh});
                $output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=1&namespace='.$namespace.'"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
                $output .= '<h1>'.WebGUI::International::get(266).'</h1>';
		$output .= '<form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","editSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(99).'</td><td>'.WebGUI::Form::text("title",20,128,$data{title}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(174).'</td><td>'.WebGUI::Form::checkbox("displayTitle","1",$data{displayTitle}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(175).'</td><td>'.WebGUI::Form::checkbox("processMacros","1",$data{processMacros}).'</td></tr>';
		%hash = WebGUI::Widget::getPositions();
                $array[0] = $data{position};
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(363).'</td><td>'.WebGUI::Form::selectList("position",\%hash,\@array).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(85).'</td><td>'.WebGUI::Form::textArea("description",$data{description},50,10,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(261).'</td><td>'.WebGUI::Form::textArea("template",$data{template},50,10,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">Query</td><td>'.WebGUI::Form::textArea("dbQuery",$data{dbQuery},50,10,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(262).'</td><td>'.WebGUI::Form::text("DSN",20,255,$data{DSN}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(263).'</td><td>'.WebGUI::Form::text("username",20,255,$data{username}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(264).'</td><td>'.WebGUI::Form::password("identifier",20,255,$data{identifier}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(183).'</td><td>'.WebGUI::Form::checkbox("convertCarriageReturns",1,$data{convertCarriageReturns}).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(62)).'</td></tr>';
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
                WebGUI::SQL->write("update SQLReport set template=".quote($session{form}{template}).", dbQuery=".quote($session{form}{dbQuery}).", convertCarriageReturns='$session{form}{convertCarriageReturns}', DSN=".quote($session{form}{DSN}).", username=".quote($session{form}{username}).", identifier=".quote($session{form}{identifier})." where widgetId=$session{form}{wid}",$session{dbh});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_view {
	my ($ouch, %data, $output, $widgetId, $sth, $dbh, @result, @template, $temp);
	tie %data, 'Tie::CPHash';
	$widgetId = shift;
	%data = WebGUI::SQL->quickHash("select * from widget,SQLReport where widget.widgetId=$widgetId and widget.widgetId=SQLReport.widgetId",$session{dbh});
	if (defined %data) {
		if ($data{displayTitle} == 1) {
			$output = "<h1>".$data{title}."</h1>";
		}
		if ($data{description} ne "") {
			$output .= $data{description}.'<p>';
                }
		@template = split(/\^\-\;/,$data{template});
		$output .= $template[0];
	        if ($data{DSN} =~ /\DBI\:\w+\:\w+/) {
        	        $dbh = DBI->connect($data{DSN},$data{username},$data{identifier});
       	 	} else {
                	$output .= WebGUI::International::get(267).'<p>';
			WebGUI::ErrorHandler::warn("SQLReport [$widgetId] The DSN specified is of an improper format.");
        	}
		if (defined $dbh) {
			if ($data{dbQuery} =~ /select/i) {
				$sth = WebGUI::SQL->unconditionalRead($data{dbQuery},$dbh);
			} else {
				$output .= WebGUI::International::get(268).'<p>';
				WebGUI::ErrorHandler::warn("SQLReport [$widgetId] The SQL query is improperly formatted.");
			}
			if ($sth->rows > 0) {
				while (@result = $sth->array) {
					$temp = $template[1];
					$temp =~ s/\^(\d)\;/$result[$1]/g;
					if ($data{convertCarriageReturns}) {
						$temp =~ s/\n/\<br\>/g;
					}
					$output .= $temp;	
				}
				$sth->finish;
			} else {
				$output .= WebGUI::International::get(269).'<p>';
				WebGUI::ErrorHandler::warn("SQLReport [$widgetId] There was a problem with the query.");
			}
			$dbh->disconnect();
		} else {
			$output .= WebGUI::International::get(270).'<p>';
			WebGUI::ErrorHandler::warn("SQLReport [$widgetId] Could not connect to remote database.");
		}	
		$output .= $template[2];
	}
	if ($data{processMacros} == 1) {
		$output = WebGUI::Macro::process($output);
	}
	return $output;
}







1;
