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
use WebGUI::DatabaseLink;
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


#-------------------------------------------------------------------
sub name {
        return WebGUI::International::get(1,$_[0]->get("namespace"));
}


#-------------------------------------------------------------------
sub new {
        my $class = shift;
        my $property = shift;
        my $self = WebGUI::Wobject->new(
                -properties=>$property,
                -extendedProperties=>{
			template=>{}, 
			dbQuery=>{}, 
			databaseLinkId=>{
				defaultValue=>0
			},
			DSN=>{
				defaultValue=>$session{config}{dsn}
				},
			username=>{
				defaultValue=>$session{config}{dbuser}
				},
			identifier=>{},
			convertCarriageReturns=>{
				defaultValue=>0
				}, 
			paginateAfter=>{
				defaultValue=>50
				},
			preprocessMacros=>{
				defaultValue=>0
				},
			debugMode=>{
				defaultValue=>0
				}
			}
                );
        bless $self, $class;
}

#-------------------------------------------------------------------
sub uiLevel {
	return 9;
}

#-------------------------------------------------------------------
sub www_edit {
	my $privileges = WebGUI::HTMLForm->new;
	my $layout = WebGUI::HTMLForm->new;
	my $properties = WebGUI::HTMLForm->new;
	$properties->yesNo(
		-name=>"preprocessMacros",
		-label=>WebGUI::International::get(15,$_[0]->get("namespace")),
		-value=>$_[0]->getValue("preprocessMacros")
		);
        $properties->yesNo(
		-name=>"debugMode",
		-label=>WebGUI::International::get(16,$_[0]->get("namespace")),
		-value=>$_[0]->getValue("debugMode")
		);
	$properties->textarea(
		-name=>"dbQuery",
		-label=>WebGUI::International::get(4,$_[0]->get("namespace")),
		-value=>$_[0]->getValue("dbQuery")
		);
       	$layout->textarea(
		-name=>"template",
		-label=>WebGUI::International::get(3,$_[0]->get("namespace")),
		-value=>$_[0]->getValue("template")
		);
	$privileges->selectList(
		-name=>"databaseLinkId",
		-options=>{
			"0"=>WebGUI::International::get(19,$_[0]->get("namespace")),
			WebGUI::DatabaseLink::getHash(),
		},
		-label=>WebGUI::International::get(20,$_[0]->get("namespace")),
		-value=>[$_[0]->getValue("databaseLinkId")],
		-subtext=>(WebGUI::Privilege::isInGroup(3)) ? '<a href="'.WebGUI::URL::page("op=listDatabaseLinks").'">'.WebGUI::International::get(981).'</a>' : ""
		);		
	$privileges->readOnly(
		-value=>WebGUI::International::get(21,$_[0]->get("namespace")),
		);
	$privileges->text(
		-name=>"DSN",
		-label=>WebGUI::International::get(5,$_[0]->get("namespace")),
		-value=>$_[0]->getValue("DSN")
		);
	$privileges->text(
		-name=>"username",
		-label=>WebGUI::International::get(6,$_[0]->get("namespace")),
		-value=>$_[0]->getValue("username")
		);
	$privileges->password(
		-name=>"identifier",
		-label=>WebGUI::International::get(7,$_[0]->get("namespace")),
		-value=>$_[0]->getValue("identifier")
		);
	$layout->integer(
		-name=>"paginateAfter",
		-label=>WebGUI::International::get(14,$_[0]->get("namespace")),
		-value=>$_[0]->getValue("paginateAfter")
		);
	$layout->yesNo(
		-name=>"convertCarriageReturns",
		-label=>WebGUI::International::get(13,$_[0]->get("namespace")),
		-value=>$_[0]->getValue("convertCarriageReturns")
		);
	return $_[0]->SUPER::www_edit(
		-layout=>$layout->printRowsOnly,
		-properties=>$properties->printRowsOnly,
		-privileges=>$privileges->printRowsOnly,
		-headingId=>8,
		-helpId=>1
		);
}


#-------------------------------------------------------------------
sub www_view {
	my ($dsn, $username, $identifier, $dbLink, $query, @row, $i, $rownum, $p, $ouch, $output, $sth, $dbh, @result, @template, $temp, $col, $errorMessage, $url);
	if ($_[0]->get("preprocessMacros")) {
		$query = WebGUI::Macro::process($_[0]->get("dbQuery"));
	} else {
		$query = $_[0]->get("dbQuery");
	}
	$dsn = $_[0]->get("DSN");
	$username = $_[0]->get("username");
	$identifier = $_[0]->get("identifier");	
	$output = $_[0]->displayTitle;
        $output .= $_[0]->description;
	$output .= WebGUI::International::get(17,$_[0]->get("namespace"))." ".$query."<p>" if ($_[0]->get("debugMode"));
	
	# connect to external database if used
	if ($_[0]->get("databaseLinkId")) {
		$dbLink = WebGUI::DatabaseLink->new($_[0]->get("databaseLinkId"));
		$dbh = $dbLink->dbh;
	} else {
		if ($dsn eq $session{config}{dsn}) {
			$dbh = $session{dbh};
		} elsif ($dsn =~ /\DBI\:\w+\:\w+/i) {
			eval{$dbh = DBI->connect($dsn,$username,$identifier)};
			if ($@) {
				WebGUI::ErrorHandler::warn("SQL Report [".$_[0]->get("wobjectId")."] ".$@);
				undef $dbh;
			}
		} else {
			$output .= WebGUI::International::get(9,$_[0]->get("namespace")).'<p>' if ($_[0]->get("debugMode"));
			WebGUI::ErrorHandler::warn("SQLReport [".$_[0]->get("wobjectId")."] The DSN specified is of an improper format.");
		}
	}
	if (defined $dbh) {
		if ($query =~ /^select/i || $query =~ /^show/i || $query =~ /^describe/i) {
			$sth = WebGUI::SQL->unconditionalRead($query,$dbh);
			unless ($sth->errorCode < 1) {
				$errorMessage = $sth->errorMessage;
                               	$output .= WebGUI::International::get(11,$_[0]->get("namespace")).' : '.$errorMessage.'<p>' if ($_[0]->get("debugMode"));
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
                               		$output .= WebGUI::International::get(18,$_[0]->get("namespace")).'<p>';
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
               		$output .= WebGUI::International::get(10,$_[0]->get("namespace")).'<p>' if ($_[0]->get("debugMode"));
                        WebGUI::ErrorHandler::warn("SQLReport [".$_[0]->get("wobjectId")."] The SQL query is improperly formatted.");
                }
		if ($dbLink) {
			$dbLink->disconnect;
		} else {
			$dbh->disconnect() unless ($dsn eq $session{config}{dsn});
		}
	} else {
		$output .= WebGUI::International::get(12,$_[0]->get("namespace")).'<p>' if ($_[0]->get("debugMode"));
		WebGUI::ErrorHandler::warn("SQLReport [".$_[0]->get("wobjectId")."] Could not connect to database.");
	}	
	return $output;
}







1;
