package WebGUI::Widget::SQLReport;

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
	return "SQL Report";
}

#-------------------------------------------------------------------
sub www_add {
        my ($output);
      	if (WebGUI::Privilege::canEditPage()) {
                $output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=20"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a><h1>Add SQL Report</h1><form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("widget","SQLReport");
                $output .= WebGUI::Form::hidden("func","addSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">Title</td><td>'.WebGUI::Form::text("title",20,30,'SQL Report').'</td></tr>';
                $output .= '<tr><td class="formDescription">Display the title?</td><td>'.WebGUI::Form::checkbox("displayTitle",1,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">Process macros?</td><td>'.WebGUI::Form::checkbox("processMacros",1,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">Description</td><td>'.WebGUI::Form::textArea("description",'','','',1).'</td></tr>';
                $output .= '<tr><td class="formDescription">Template</td><td>'.WebGUI::Form::textArea("template",'','','',1).'</td></tr>';
                $output .= '<tr><td class="formDescription">Query</td><td>'.WebGUI::Form::textArea("dbQuery",'').'</td></tr>';
                $output .= '<tr><td class="formDescription">DSN</td><td>'.WebGUI::Form::text("DSN",20,255,$session{config}{dsn}).'</td></tr>';
                $output .= '<tr><td class="formDescription">Database User</td><td>'.WebGUI::Form::text("username",20,255,$session{config}{dbuser}).'</td></tr>';
                $output .= '<tr><td class="formDescription">Database Password</td><td>'.WebGUI::Form::password("identifier",20,255).'</td></tr>';
                $output .= '<tr><td class="formDescription">Convert carriage returns?</td><td>'.WebGUI::Form::checkbox("convertCarriageReturns",1).'</td></tr>';
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
		WebGUI::SQL->write("insert into SQLReport set widgetId=$widgetId, convertCarriageReturns='$session{form}{convertCarriageReturns}', template=".quote($session{form}{template}).", dBquery=".quote($session{form}{dbQuery}).", DSN=".quote($session{form}{DSN}).", username=".quote($session{form}{username}).", identifier=".quote($session{form}{identifier}),$session{dbh});
		return "";
	} else {
		return WebGUI::Privilege::insufficient();
	}
}

#-------------------------------------------------------------------
sub www_edit {
        my ($output, %data);
        if (WebGUI::Privilege::canEditPage()) {
		%data = WebGUI::SQL->quickHash("select * from widget,SQLReport where widget.widgetId=$session{form}{wid} and widget.widgetId=SQLReport.widgetId",$session{dbh});
                $output = '<h1>Edit SQL Report</h1><form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","editSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">Title</td><td>'.WebGUI::Form::text("title",20,30,$data{title}).'</td></tr>';
                $output .= '<tr><td class="formDescription">Display the title?</td><td>'.WebGUI::Form::checkbox("displayTitle","1",$data{displayTitle}).'</td></tr>';
                $output .= '<tr><td class="formDescription">Process macros?</td><td>'.WebGUI::Form::checkbox("processMacros","1",$data{processMacros}).'</td></tr>';
                $output .= '<tr><td class="formDescription">Description</td><td>'.WebGUI::Form::textArea("description",$data{description},50,10,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">Template</td><td>'.WebGUI::Form::textArea("template",$data{template},50,10,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">Query</td><td>'.WebGUI::Form::textArea("dbQuery",$data{dbQuery},50,10,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">DSN</td><td>'.WebGUI::Form::text("DSN",20,255,$data{DSN}).'</td></tr>';
                $output .= '<tr><td class="formDescription">Database User</td><td>'.WebGUI::Form::text("username",20,255,$data{username}).'</td></tr>';
                $output .= '<tr><td class="formDescription">Database Password</td><td>'.WebGUI::Form::password("identifier",20,255,$data{identifier}).'</td></tr>';
                $output .= '<tr><td class="formDescription">Convert carriage returns?</td><td>'.WebGUI::Form::checkbox("convertCarriageReturns",1,$data{convertCarriageReturns}).'</td></tr>';
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
                WebGUI::SQL->write("update SQLReport set template=".quote($session{form}{template}).", dbQuery=".quote($session{form}{dbQuery}).", convertCarriageReturns='$session{form}{convertCarriageReturns}', DSN=".quote($session{form}{DSN}).", username=".quote($session{form}{username}).", identifier=".quote($session{form}{identifier})." where widgetId=$session{form}{wid}",$session{dbh});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_view {
	my (%data, $output, $widgetId, $sth, $dbh, @result, @template, $temp);
	$widgetId = shift;
	%data = WebGUI::SQL->quickHash("select * from widget,SQLReport where widget.widgetId=$widgetId and widget.widgetId=SQLReport.widgetId",$session{dbh});
	if (defined %data) {
		if ($data{displayTitle} == 1) {
			$output = "<h1>".$data{title}."</h1>";
		}
		if ($data{description} ne "") {
			$output .= $data{description}.'<p>';
                }
		@template = split(/\^\-/,$data{template});
		$output .= $template[0];
	        if ($data{DSN} =~ /\DBI\:\w+\:\w+/) {
        	        $dbh = DBI->connect($data{DSN},$data{username},$data{identifier});
       	 	} else {
                	$output .= '<b>Error</b>: The DSN specified is of an improper format.<p>';
			WebGUI::ErrorHandler::warn("SQLReport [$widgetId] The DSN specified is of an improper format.");
        	}
		if (defined $dbh) {
			if ($data{dbQuery} =~ /select/i) {
				$sth = WebGUI::SQL->read($data{dbQuery},$dbh);
			} else {
				$output .= '<b>Error</b>: The SQL query is improperly formatted.<p>';
				WebGUI::ErrorHandler::warn("SQLReport [$widgetId] The SQL query is improperly formatted.");
			}
			if (defined $sth) {
				while (@result = $sth->array) {
					$temp = $template[1];
					$temp =~ s/\^(\d)/$result[$1]/g;
					if ($data{convertCarriageReturns}) {
						$temp =~ s/\n/\<br\>/g;
					}
					$output .= $temp;	
				}
				$sth->finish;
			} else {
				$output .= '<b>Error</b>: There was a problem with the query.<p>';
				WebGUI::ErrorHandler::warn("SQLReport [$widgetId] There was a problem with the query.");
			}
			$dbh->disconnect();
		} else {
			$output .= '<b>Error</b>: Could not connect to remote database.<p>';
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
