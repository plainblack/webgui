package WebGUI::Widget::SearchMnoGo;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use DBI;
use strict;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;
use WebGUI::Widget;

#-------------------------------------------------------------------
sub _mnogoSearch {
	my ($i, %match, $key, $sth, $dbh, $urlId, %data, $output, @keyword, $word, %result);
	%data = @_;
	@keyword = split(/ /,$session{form}{query});
	if ($data{DSN} =~ /\DBI\:\w+\:\w+/) {
		$dbh = DBI->connect($data{DSN},$data{username},$data{identifier});
	} else {
		$output .= '<b>Error</b>: The DSN specified is of an improper format.<p>';
		WebGUI::ErrorHandler::warn("Search (MnoGo) The DSN specified is of an improper format.");
	}
	if (defined $dbh) {
		foreach $word (@keyword) {
			$sth = WebGUI::SQL->read("select url_id from dict where soundex(word)=soundex(lcase('$word'))",$dbh);
			if (defined $sth) {
				while (($urlId) = $sth->array) {
					$result{$urlId}++;
				}
				$sth->finish;
			} else {
				$output .= '<b>Error</b>: There was a problem with the query.<p>';
				WebGUI::ErrorHandler::warn("Search (MnoGo) There was a problem with the query.");
			}
		}
		foreach $key (sort {$result{$b} <=> $result{$a}} keys %result) {
			if ($i < 50) {
				%match = WebGUI::SQL->quickHash("select url,title,txt from url where rec_id=$key",$dbh);
				$output .= '<a href="'.$match{url}.'">'.$match{title}.'</a> ('.$result{$key}.')<br>'.$match{txt}.'<br><a href="'.$match{url}.'">'.$match{url}.'</a><p>';
			} 
			$i++;	
		}
		$dbh->disconnect();
	} else {
		$output .= '<b>Error</b>: Could not connect to remote database.<p>';
		WebGUI::ErrorHandler::warn("Search (MnoGo) Could not connect to remote database.");
	}
	return $output;
}

#-------------------------------------------------------------------
sub purge {
        WebGUI::SQL->write("delete from SearchMnoGo where widgetId=$_[0]",$_[1]);
        purgeWidget($_[0],$_[1]);
}

#-------------------------------------------------------------------
sub widgetName {
	return "Search (MnoGo)";
}

#-------------------------------------------------------------------
sub www_add {
        my ($output);
      	if (WebGUI::Privilege::canEditPage()) {
                $output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=42"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a><h1>Add Search (MnoGo)</h1><form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("widget","SearchMnoGo");
                $output .= WebGUI::Form::hidden("func","addSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">Title</td><td>'.WebGUI::Form::text("title",20,30,'Search (MnoGo)').'</td></tr>';
                $output .= '<tr><td class="formDescription">Display the title?</td><td>'.WebGUI::Form::checkbox("displayTitle",1).'</td></tr>';
                $output .= '<tr><td class="formDescription">Description</td><td>'.WebGUI::Form::textArea("description",'',50,5,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">DSN</td><td>'.WebGUI::Form::text("DSN",20,255,$session{config}{dsn}).'</td></tr>';
                $output .= '<tr><td class="formDescription">Database User</td><td>'.WebGUI::Form::text("username",20,255,$session{config}{dbuser}).'</td></tr>';
                $output .= '<tr><td class="formDescription">Database Password</td><td>'.WebGUI::Form::password("identifier",20,255).'</td></tr>';
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
		WebGUI::SQL->write("insert into SearchMnoGo values ($widgetId, ".quote($session{form}{DSN}).", ".quote($session{form}{username}).", ".quote($session{form}{identifier}).")",$session{dbh});
		return "";
	} else {
		return WebGUI::Privilege::insufficient();
	}
}

#-------------------------------------------------------------------
sub www_edit {
        my ($output, %data);
        if (WebGUI::Privilege::canEditPage()) {
		%data = WebGUI::SQL->quickHash("select * from widget,SearchMnoGo where widget.widgetId=SearchMnoGo.widgetId and widget.widgetId=$session{form}{wid}",$session{dbh});
                $output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=43"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a><h1>Edit Search (MnoGo)</h1><form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","editSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">Title</td><td>'.WebGUI::Form::text("title",20,30,$data{title}).'</td></tr>';
                $output .= '<tr><td class="formDescription">Display the title?</td><td>'.WebGUI::Form::checkbox("displayTitle","1",$data{displayTitle}).'</td></tr>';
                $output .= '<tr><td class="formDescription">Description</td><td>'.WebGUI::Form::textArea("description",$data{description},50,10,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">DSN</td><td>'.WebGUI::Form::text("DSN",20,255,$data{DSN}).'</td></tr>';
                $output .= '<tr><td class="formDescription">Database Username</td><td>'.WebGUI::Form::text("username",20,255,$data{username}).'</td></tr>';
                $output .= '<tr><td class="formDescription">Database Password</td><td>'.WebGUI::Form::password("identifier",20,255,$data{identifier}).'</td></tr>';
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
                WebGUI::SQL->write("update SearchMnoGo set DSN=".quote($session{form}{DSN}).", username=".quote($session{form}{username}).", identifier=".quote($session{form}{identifier})." where widgetId=$session{form}{wid}",$session{dbh});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_view {
	my (%data, @test, $output, $widgetId);
	$widgetId = shift;
	%data = WebGUI::SQL->quickHash("select * from widget,SearchMnoGo where widget.widgetId='$widgetId' and widget.WidgetId=SearchMnoGo.widgetId",$session{dbh});
	if (%data) {
		if ($data{displayTitle} == 1) {
			$output = "<h1>".$data{title}."</h1>";
		}
		if ($data{description} ne "") {
			$output .= $data{description}.'<p>';
		}
		$output .= '<form method="post" action="'.$session{page}{url}.'">';
		$output .= WebGUI::Form::text("query",20,255,$session{form}{query});
		$output .= WebGUI::Form::submit("search");
		$output .= '</form>';
		$output .= _mnogoSearch(%data);
	}
	return $output;
}




1;
