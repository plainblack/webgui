package WebGUI::Widget::SQLReport;

our $namespace = "SQLReport";

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
use WebGUI::ErrorHandler;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::Shortcut;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Utility;
use WebGUI::Widget;

#-------------------------------------------------------------------
sub duplicate {
        my (%data, $newWidgetId, $pageId);
        tie %data, 'Tie::CPHash';
        %data = getProperties($namespace,$_[0]);
	$pageId = $_[1] || $data{pageId};
        $newWidgetId = create($pageId,$namespace,$data{title},$data{displayTitle},
		$data{description},$data{processMacros},$data{templatePosition});
	WebGUI::SQL->write("insert into SQLReport values($newWidgetId, ".quote($data{template}).", ".
		quote($data{dbQuery}).", ".quote($data{DSN}).", ".quote($data{username}).", ".
		quote($data{identifier}).", '$data{convertCarriageReturns}', '$data{paginateAfter}')");
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
	tie %hash, 'Tie::IxHash';
      	if (WebGUI::Privilege::canEditPage()) {
                $output = helpLink(1,$namespace);
		$output .= '<h1>'.WebGUI::International::get(2,$namespace).'</h1>';
		$output .= formHeader();
                $output .= WebGUI::Form::hidden("widget",$namespace);
                $output .= WebGUI::Form::hidden("func","addSave");
                $output .= '<table>';
                $output .= tableFormRow(WebGUI::International::get(99),
			WebGUI::Form::text("title",20,128,widgetName()));
                $output .= tableFormRow(WebGUI::International::get(174),
			WebGUI::Form::checkbox("displayTitle",1,1));
                $output .= tableFormRow(WebGUI::International::get(175),
			WebGUI::Form::checkbox("processMacros",1,1));
		%hash = WebGUI::Widget::getPositions();
                $output .= tableFormRow(WebGUI::International::get(363),
			WebGUI::Form::selectList("templatePosition",\%hash));
                $output .= tableFormRow(WebGUI::International::get(85),
			WebGUI::Form::textArea("description",'','','',1));
                $output .= tableFormRow(WebGUI::International::get(3,$namespace),
			WebGUI::Form::textArea("template",'','','',1));
                $output .= tableFormRow(WebGUI::International::get(4,$namespace),
			WebGUI::Form::textArea("dbQuery",''));
                $output .= tableFormRow(WebGUI::International::get(5,$namespace),
			WebGUI::Form::text("DSN",20,255,$session{config}{dsn}));
                $output .= tableFormRow(WebGUI::International::get(6,$namespace),
			WebGUI::Form::text("username",20,255,$session{config}{dbuser}));
                $output .= tableFormRow(WebGUI::International::get(7,$namespace),
			WebGUI::Form::password("identifier",20,255));
                $output .= tableFormRow(WebGUI::International::get(14,$namespace),
                        WebGUI::Form::text("paginateAfter",20,30,50));
                $output .= tableFormRow(WebGUI::International::get(13,$namespace),
			WebGUI::Form::checkbox("convertCarriageReturns",1));
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
	my ($widgetId);
	if (WebGUI::Privilege::canEditPage()) {
		$widgetId = create($session{page}{pageId},$session{form}{widget},
			$session{form}{title},$session{form}{displayTitle},
			$session{form}{description},$session{form}{processMacros},
			$session{form}{templatePosition});
		WebGUI::SQL->write("insert into SQLReport values($widgetId, ".
			quote($session{form}{template}).", ".quote($session{form}{dbQuery}).", ".
			quote($session{form}{DSN}).", ".quote($session{form}{username}).", ".
			quote($session{form}{identifier}).
			", '$session{form}{convertCarriageReturns}', '$session{form}{paginateAfter}')");
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
                $output .= '<h1>'.WebGUI::International::get(8,$namespace).'</h1>';
		$output .= formHeader();
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","editSave");
                $output .= '<table>';
                $output .= tableFormRow(WebGUI::International::get(99),
			WebGUI::Form::text("title",20,128,$data{title}));
                $output .= tableFormRow(WebGUI::International::get(174),
			WebGUI::Form::checkbox("displayTitle","1",$data{displayTitle}));
                $output .= tableFormRow(WebGUI::International::get(175),
			WebGUI::Form::checkbox("processMacros","1",$data{processMacros}));
		%hash = WebGUI::Widget::getPositions();
                $array[0] = $data{templatePosition};
                $output .= tableFormRow(WebGUI::International::get(363),
			WebGUI::Form::selectList("templatePosition",\%hash,\@array));
                $output .= tableFormRow(WebGUI::International::get(85),
			WebGUI::Form::textArea("description",$data{description},50,10,1));
                $output .= tableFormRow(WebGUI::International::get(3,$namespace),
			WebGUI::Form::textArea("template",$data{template},50,10,1));
                $output .= tableFormRow(WebGUI::International::get(4,$namespace),
			WebGUI::Form::textArea("dbQuery",$data{dbQuery},50,10));
                $output .= tableFormRow(WebGUI::International::get(5,$namespace),
			WebGUI::Form::text("DSN",20,255,$data{DSN}));
                $output .= tableFormRow(WebGUI::International::get(6,$namespace),
			WebGUI::Form::text("username",20,255,$data{username}));
                $output .= tableFormRow(WebGUI::International::get(7,$namespace),
			WebGUI::Form::password("identifier",20,255,$data{identifier}));
                $output .= tableFormRow(WebGUI::International::get(14,$namespace),
                        WebGUI::Form::text("paginateAfter",20,30,$data{paginateAfter}));
                $output .= tableFormRow(WebGUI::International::get(13,$namespace),
			WebGUI::Form::checkbox("convertCarriageReturns",1,$data{convertCarriageReturns}));
                $output .= formSave();
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
                WebGUI::SQL->write("update SQLReport set template=".quote($session{form}{template}).
			", dbQuery=".quote($session{form}{dbQuery}).
			", convertCarriageReturns='$session{form}{convertCarriageReturns}', DSN=".
			quote($session{form}{DSN}).", username=".quote($session{form}{username}).
			", identifier=".quote($session{form}{identifier}).
			", paginateAfter='$session{form}{paginateAfter}' where widgetId=$session{form}{wid}");
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_view {
	my (@row, $i, $p, $ouch, %data, $output, $sth, $dbh, @result, 
		@template, $temp, $col);
	tie %data, 'Tie::CPHash';
	%data = getProperties($namespace,$_[0]);
	if (defined %data) {
		if ($data{displayTitle} == 1) {
			$output = "<h1>".$data{title}."</h1>";
		}
		if ($data{description} ne "") {
			$output .= $data{description}.'<p>';
                }
	        if ($data{DSN} =~ /\DBI\:\w+\:\w+/) {
        	        $dbh = DBI->connect($data{DSN},$data{username},$data{identifier});
       	 	} else {
                	$output .= WebGUI::International::get(9,$namespace).'<p>';
			WebGUI::ErrorHandler::warn("SQLReport [$_[0]] The DSN specified is of an improper format.");
        	}
		if (defined $dbh) {
			if ($data{dbQuery} =~ /select/i) {
				$sth = WebGUI::SQL->unconditionalRead($data{dbQuery},$dbh);
			} else {
				$output .= WebGUI::International::get(10,$namespace).'<p>';
				WebGUI::ErrorHandler::warn("SQLReport [$_[0]] The SQL query is improperly formatted.");
			}
			if ($sth->rows > 0) {
				if ($data{template} ne "") {
					@template = split(/\^\-\;/,$data{template});
				} else {
					$i = 0;
					$template[0] = '<table width="100%"><tr>';
					$template[1] = '<tr>';
					foreach $col ($sth->getColumnNames) {
						$template[0] .= '<td class="tableHeader">'.$col.'</td>';
						$template[1] .= '<td class="tableData">^'.$i.';</td>';
						$i++;
					}
					$template[0] .= '</tr>';
					$template[1] .= '</tr>';
					$template[2] = '</table>';
					$i = 0;
				}
				$output .= $template[0];
				while (@result = $sth->array) {
					$temp = $template[1];
					$temp =~ s/\^(\d*)\;/$result[$1]/g;
					if ($data{convertCarriageReturns}) {
						$temp =~ s/\n/\<br\>/g;
					}
					$row[$i] = $temp;	
					$i++;
				}
				$sth->finish;
                		$p = WebGUI::Paginator->new(WebGUI::URL::page(),\@row,$data{paginateAfter});
                		$output .= $p->getPage($session{form}{pn});
                		$output .= $template[2];
                		$output .= $p->getBar($session{form}{pn});
			} else {
				$output .= WebGUI::International::get(11,$namespace).'<p>';
				WebGUI::ErrorHandler::warn("SQLReport [$_[0]] There was a problem with the query.");
			}
			$dbh->disconnect();
		} else {
			$output .= WebGUI::International::get(12,$namespace).'<p>';
			WebGUI::ErrorHandler::warn("SQLReport [$_[0]] Could not connect to remote database.");
		}	
	}
	if ($data{processMacros} == 1) {
		$output = WebGUI::Macro::process($output);
	}
	return $output;
}







1;
