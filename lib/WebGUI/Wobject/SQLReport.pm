package WebGUI::Wobject::SQLReport;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::ErrorHandler;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Utility;
use WebGUI::Wobject;

our @ISA = qw(WebGUI::Wobject);
our $namespace = "SQLReport";
our $name = WebGUI::International::get(1,$namespace);

#-------------------------------------------------------------------
sub duplicate {
        my ($w);
	$w = $_[0]->SUPER::duplicate($_[1]);
        $w = WebGUI::Wobject::SQLReport->new({wobjectId=>$w,namespace=>$namespace});
        $w->set({
		template=>$_[0]->get("template"),
		dbQuery=>$_[0]->get("dbQuery"),
		DSN=>$_[0]->get("DSN"),
		username=>$_[0]->get("username"),
		identifier=>$_[0]->get("identifier"),
		convertCarriageReturns=>$_[0]->get("convertCarriageReturns"),
		paginateAfter=>$_[0]->get("paginateAfter"),
		preprocessMacros=>$_[0]->get("preprocessMacros"),
		debugMode=>$_[0]->get("debugMode")
		});
}

#-------------------------------------------------------------------
sub set {
        $_[0]->SUPER::set($_[1],[qw(template dbQuery DSN username identifier convertCarriageReturns paginateAfter preprocessMacros debugMode)]);
}

#-------------------------------------------------------------------
sub uiLevel {
	return 9;
}

#-------------------------------------------------------------------
sub www_edit {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
        my ($output, $f, $dsn, $username, $paginateAfter);
	$dsn = $_[0]->get("DSN") || $session{config}{dsn};
	$username = $_[0]->get("username") || $session{config}{dbuser};
	$paginateAfter = $_[0]->get("paginateAfter") || 50;
	$f = WebGUI::HTMLForm->new;
        $output = helpIcon(1,$namespace);
        $output .= '<h1>'.WebGUI::International::get(8,$namespace).'</h1>';
	$f->yesNo("preprocessMacros",WebGUI::International::get(15,$namespace),$_[0]->get("preprocessMacros"));
        $f->yesNo("debugMode",WebGUI::International::get(16,$namespace),$_[0]->get("debugMode"));
	$f->textarea("dbQuery",WebGUI::International::get(4,$namespace),$_[0]->get("dbQuery"));
       	$f->textarea("template",WebGUI::International::get(3,$namespace),$_[0]->get("template"));        
        $f->text("DSN",WebGUI::International::get(5,$namespace),$dsn);
	$f->text("username",WebGUI::International::get(6,$namespace),$username);
	$f->password("identifier",WebGUI::International::get(7,$namespace),$_[0]->get("identifier"));
	$f->integer("paginateAfter",WebGUI::International::get(14,$namespace),$paginateAfter);
	$f->yesNo("convertCarriageReturns",WebGUI::International::get(13,$namespace),$_[0]->get("convertCarriageReturns"));
	$output .= $_[0]->SUPER::www_edit($f->printRowsOnly);
        return $output;
}

#-------------------------------------------------------------------
sub www_editSave {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
	$_[0]->SUPER::www_editSave({
		template=>$session{form}{template},
		dbQuery=>$session{form}{dbQuery},
		convertCarriageReturns=>$session{form}{convertCarriageReturns},
		DSN=>$session{form}{DSN},
		username=>$session{form}{username},
		identifier=>$session{form}{identifier},
		paginateAfter=>$session{form}{paginateAfter},
		preprocessMacros=>$session{form}{preprocessMacros},
		debugMode=>$session{form}{debugMode}
		});
        return "";
}

#-------------------------------------------------------------------
sub www_view {
	my ($dsn, $query, @row, $i, $rownum, $p, $ouch, $output, $sth, $dbh, @result, @template, $temp, $col, $errorMessage, $url);
	if ($_[0]->get("preprocessMacros")) {
		$query = WebGUI::Macro::process($_[0]->get("dbQuery"));
	} else {
		$query = $_[0]->get("dbQuery");
	}
	$dsn = $_[0]->get("DSN");
	$output = $_[0]->displayTitle;
        $output .= $_[0]->description;
	$output .= WebGUI::International::get(17,$namespace)." ".$query."<p>" if ($_[0]->get("debugMode"));
	if ($dsn eq $session{config}{dsn}) {
		$dbh = $session{dbh};
	} elsif ($dsn =~ /\DBI\:\w+\:\w+/) {
                eval{$dbh = DBI->connect($dsn,$_[0]->get("username"),$_[0]->get("identifier"))};
		if ($@) {
			WebGUI::ErrorHandler::warn("SQL Report [".$_[0]->get("wobjectId")."] ".$@);
			undef $dbh;
		}
       	} else {
               	$output .= WebGUI::International::get(9,$namespace).'<p>' if ($_[0]->get("debugMode"));
		WebGUI::ErrorHandler::warn("SQLReport [".$_[0]->get("wobjectId")."] The DSN specified is of an improper format.");
        }
	if (defined $dbh) {
		if ($query =~ /select/i || $query =~ /show/i || $query =~ /describe/i) {
			$sth = WebGUI::SQL->unconditionalRead($query,$dbh);
			unless ($sth->errorCode < 1) {
				$errorMessage = $sth->errorMessage;
                               	$output .= WebGUI::International::get(11,$namespace).' : '.$errorMessage.'<p>' if ($_[0]->get("debugMode"));
                               	WebGUI::ErrorHandler::warn("There was a problem with the query: ".$errorMessage);
			} else {
				if ($_[0]->get("template") ne "") {
					@template = split(/\^\-\;/,$_[0]->get("template"));
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
					$temp =~ s/\^(\d*)\;/$result[$1]/g;	# Shouldn't this be \d+ ?
					$rownum = $i + 1;
					$temp =~ s/\^rownum\;/$rownum/g;
					if ($_[0]->get("convertCarriageReturns")) {
						$temp =~ s/\n/\<br\>/g;
					}
					$row[$i] = $temp;	
					$i++;
				}
                       		if ($sth->rows < 1) {
	               			$output .= $template[2];
                               		$output .= WebGUI::International::get(18,$namespace).'<p>';
               	        	} else {
					$url = WebGUI::URL::page('&wid='.$_[0]->get("wobjectId").'&func=view');
					foreach (keys %{$session{form}}) {
						unless ($_ eq "pn" || $_ eq "wid" || $_ eq "func") {
							$url = WebGUI::URL::append($url, WebGUI::URL::escape($_)
								.'='.WebGUI::URL::escape($session{form}{$_}));
						}
					}
               				$p = WebGUI::Paginator->new($url,\@row,$_[0]->get("paginateAfter"));
               				$output .= $p->getPage($session{form}{pn});
    	       	    			$output .= $template[2];
                			$output .= $p->getBar($session{form}{pn});
				}
				$sth->finish;
			}
               	} else {
               		$output .= WebGUI::International::get(10,$namespace).'<p>' if ($_[0]->get("debugMode"));
                        WebGUI::ErrorHandler::warn("SQLReport [".$_[0]->get("wobjectId")."] The SQL query is improperly formatted.");
                }
		$dbh->disconnect() unless ($dsn eq $session{config}{dsn});
	} else {
		$output .= WebGUI::International::get(12,$namespace).'<p>' if ($_[0]->get("debugMode"));
		WebGUI::ErrorHandler::warn("SQLReport [".$_[0]->get("wobjectId")."] Could not connect to database.");
	}	
	return $_[0]->processMacros($output);
}







1;
