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
			dbQuery=>{}, 
			databaseLinkId=>{
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
			},
		-useTemplate=>1
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
	$privileges->databaseLink(
		-value=>$_[0]->getValue("databaseLinkId")
		);
	$layout->integer(
		-name=>"paginateAfter",
		-label=>WebGUI::International::get(14,$_[0]->get("namespace")),
		-value=>$_[0]->getValue("paginateAfter")
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
	my ($query, %var, @debug);
	if ($_[0]->get("preprocessMacros")) {
		$query = WebGUI::Macro::process($_[0]->get("dbQuery"));
	} else {
		$query = $_[0]->get("dbQuery");
	}
	push(@debug,{'debug.output'=>WebGUI::International::get(17,$_[0]->get("namespace")).$query});
	my $dbLink = WebGUI::DatabaseLink->new($_[0]->get("databaseLinkId"));
	my $dbh = $dbLink->dbh;
	if (defined $dbh) {
		if ($query =~ /^select/i || $query =~ /^show/i || $query =~ /^describe/i) {
			my $url = WebGUI::URL::page('&wid='.$_[0]->get("wobjectId").'&func=view');
			foreach (keys %{$session{form}}) {
				unless ($_ eq "pn" || $_ eq "wid" || $_ eq "func") {
					$url = WebGUI::URL::append($url, WebGUI::URL::escape($_)
						.'='.WebGUI::URL::escape($session{form}{$_}));
				}
			}
			my $p = WebGUI::Paginator->new($url,$_[0]->get("paginateAfter"));
			my $error = $p->setDataByQuery($query,$dbh,1);
			if ($error ne "") {
                               	WebGUI::ErrorHandler::warn("There was a problem with the query: ".$error);
				push(@debug,{'debug.output'=>WebGUI::International::get(11,$_[0]->get("namespace"))." ".$error});
			} else {
				my $first = 1;
				my @columns;
				my @rows;
				my $rownum = 1;
				my $rowdata = $p->getPageData;
				foreach my $data (@$rowdata) {
					my %row;
					my $colnum = 1;
					my @fields;
					foreach my $name (keys %{$data}) {
						if ($first) {
							push(@columns,{
								'column.number'=>$colnum,
								'column.name'=>$name
								});	
						}
						push(@fields,{
							'field.number'=>$colnum,
							'field.name'=>$name,
							'field.value'=>$data->{$name}
							});
						$colnum++;
						$row{'row.field.'.$name.'.value'} = $data->{$name};
					}
					$row{'row.number'} = $rownum;
                                        $row{'row.field_loop'} = \@fields;
					push(@rows,\%row);
					$first = 0;
					$rownum++;
				}
				$var{columns_loop} = \@columns;
				$var{rows_loop} = \@rows;
				$var{'rows.count'} = $p->getRowCount;
				$var{'rows.count.isZero'} = ($p->getRowCount < 1);
				$var{'rows.count.isZero.label'} = WebGUI::International::get(18,$_[0]->get("namespace"));
				$var{firstPage} = $p->getFirstPageLink;
        			$var{lastPage} = $p->getLastPageLink;
        			$var{nextPage} = $p->getNextPageLink;
        			$var{pageList} = $p->getPageLinks;
        			$var{previousPage} = $p->getPreviousPageLink;
        			$var{multiplePages} = ($p->getNumberOfPages > 1);
        			$var{numberOfPages} = $p->getNumberOfPages;
        			$var{pageNumber} = $p->getPageNumber;
			}
               	} else {
			push(@debug,{'debug.output'=>WebGUI::International::get(10,$_[0]->get("namespace"))});
                        WebGUI::ErrorHandler::warn("SQLReport [".$_[0]->get("wobjectId")."] The SQL query is improperly formatted.");
                }
		$dbLink->disconnect;
	} else {
		push(@debug,{'debug.output'=>WebGUI::International::get(12,$_[0]->get("namespace"))});
		WebGUI::ErrorHandler::warn("SQLReport [".$_[0]->get("wobjectId")."] Could not connect to database.");
	}	
	$var{'debug_loop'} = \@debug;
	return $_[0]->processTemplate($_[0]->get("templateId"),\%var);
}







1;
