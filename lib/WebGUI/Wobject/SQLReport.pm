package WebGUI::Wobject::SQLReport;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black Corporation.
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
			paginateAfter=>{
				defaultValue=>50
				},
			dbQuery1=>{}, 
			preprocessMacros1=>{
				defaultValue=>0
				},
			placeholderParams1=>{},
                        databaseLinkId1=>{
                                defaultValue=>0
                        },
			dbQuery2=>{},
                        preprocessMacros2=>{
                                defaultValue=>0
                                },
                        placeholderParams2=>{},
                        databaseLinkId2=>{
                                defaultValue=>0
                        },
			dbQuery3=>{},
                        preprocessMacros3=>{
                                defaultValue=>0
                                },
                        placeholderParams3=>{},
                        databaseLinkId3=>{
                                defaultValue=>0
                        },
			dbQuery4=>{},
                        preprocessMacros4=>{
                                defaultValue=>0
                                },
                        placeholderParams4=>{},
                        databaseLinkId4=>{
                                defaultValue=>0
                        },
			dbQuery5=>{},
                        preprocessMacros5=>{
                                defaultValue=>0
                                },
                        placeholderParams5=>{},
                        databaseLinkId5=>{
                                defaultValue=>0
                        },
			debugMode=>{
				defaultValue=>0
				},
			},
		-useTemplate=>1,
		-useMetaData=>1
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
                -name=>"debugMode",
                -label=>WebGUI::International::get(16,$_[0]->get("namespace")),
                -value=>$_[0]->getValue("debugMode")
                );

	# Add toggleQuery javascript
	$properties->raw(qq|
		<script language="javascript">
		function toggleQuery(Id) {
			queryClass = "query" + Id;
			var tr = document.getElementsByTagName("tr");
			if (tr == null) return;
			for (i=0; i < tr.length; i++) {
			   if(tr[i].className == queryClass) {
				if(tr[i].style.display == 'none') {
				   tr[i].style.display = '';
				} else {
				   tr[i].style.display = 'none';
				}
			   } 
			}
		}
		</script>	
		|);

	for my $nr (1..5) {
	   # Set TR class for this query properties
	   $properties->trClass("query".$nr);

	   $properties->readOnly(
		   -value=>"<hr>",
                   -label=>"<b>query".$nr.":</b>",
		   ); 
	   $properties->yesNo(
	  	   -name=>"preprocessMacros".$nr,
		   -label=>WebGUI::International::get(15,$_[0]->get("namespace")),
		   -value=>$_[0]->getValue("preprocessMacros".$nr)
		   );
	   $properties->textarea(
                   -name=>"placeholderParams".$nr,
                   -label=>WebGUI::International::get('Placeholder Parameters',$_[0]->get("namespace")),
                   -value=>$_[0]->getValue("placeholderParams".$nr)
                   );
	   $properties->textarea(
		   -name=>"dbQuery".$nr,
		   -label=>WebGUI::International::get(4,$_[0]->get("namespace")),
		   -value=>$_[0]->getValue("dbQuery".$nr)
		   );
	   $properties->databaseLink(
		   -name=>"databaseLinkId".$nr,
		   -value=>$_[0]->getValue("databaseLinkId".$nr)
		   );

	   # Add a "Add another query" button
	   if ($nr < 5	and ($_[0]->get("dbQuery".($nr+1)) eq "" || ($_[0]->get("dbQuery".($nr)) eq "" and $_[0]->get("dbQuery".($nr+1)) ne ""))) {
	           $properties->button(
        	           -value=>WebGUI::International::get('Add another query',$_[0]->get("namespace")),
                	   -extras=>'onClick="toggleQuery(\''.($nr+1).'\'); this.style.display=\'none\';"',
	                   -noWait=>1
        	           );
	   }

	   # Make empty query blocks invisible
           if ($nr > 1 && ($_[0]->get("dbQuery".$nr) eq "" || $_[0]->get("dbQuery".($nr-1)) eq "")) {
		$properties->raw(qq|
                        <script language="javascript">
                                toggleQuery('$nr');
                        </script>
                        |);
           }

	}
	# Undefine TR class
	$properties->trClass();

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
		-helpId=>"sql report add/edit"
		);
}

#-------------------------------------------------------------------
sub www_view {
	my $self = shift;
        $self->logView() if ($session{setting}{passiveProfilingEnabled});

        # Initiate an empty debug loop
        $self->{_debug_loop} = [] ;
	
	# Store queries in class
	$self->_storeQueries();

	# Process the quer(y|ies)
	my $var = $self->_processQuery();
	
	# Add debug loop to template vars
	$var->{'debug_loop'} = $self->{_debug_loop};
	#use Data::Dumper; return '<pre>'.Dumper($var).'</pre>';
	return $self->processTemplate($self->get("templateId"),$var);
}

#-------------------------------------------------------------------
sub _storeQueries {
	my $self = shift;
        for my $nr (1..5) {
                if($self->get("dbQuery".$nr)) {
                        $self->{_query}{$nr} = {
                                dbQuery => $self->get("dbQuery".$nr),
                                databaseLinkId => $self->get("databaseLinkId".$nr),
                                preprocessMacros => $self->get("preprocessMacros".$nr),
                                placeholderParams => $self->get("placeholderParams".$nr),
                                rowData => {},
                                };
                }
        }
}

#-------------------------------------------------------------------
sub _parsePlaceholderParams {
	my $self = shift;
	my $params = shift;
	my @placeholderParams;
	foreach my $param (split /\s*,\s*/, $params) {
		if($param =~ /^form:/) {
			$param = $session{form}{$'};
		} elsif ($param =~ /^query(\d):/) {
			$param = $self->{_query}{$1}{rowData}{$'};
		}
		$param = WebGUI::Macro::process($param);
		push(@placeholderParams, $param);
	}
	return \@placeholderParams;
}


#-------------------------------------------------------------------

sub _processQuery {
	my $self = shift;	
	my $nr = shift || 1;
        my ($query, %var, $prefix);

	if($nr > 1) {
		$prefix = 'query'.$nr.'.';
	}

	# Parse placeholder parameters
	my $placeholderParams = $self->_parsePlaceholderParams($self->{_query}{$nr}{placeholderParams});
	
	# Preprocess macros
        if ($self->{_query}{$nr}{preprocessMacros}) {
                $query = WebGUI::Macro::process($self->{_query}{$nr}{dbQuery});
        } else {
                $query = $self->{_query}{$nr}{dbQuery};
        }
	
        push(@{$self->{_debug_loop}},{'debug.output'=>WebGUI::International::get(17,$self->get("namespace")).$query});
        push(@{$self->{_debug_loop}},{'debug.output'=>WebGUI::International::get('debug placeholder parameters',$self->get("namespace")).join(",",@$placeholderParams)});
        my $dbLink = WebGUI::DatabaseLink->new($self->{_query}{$nr}{databaseLinkId});
        my $dbh = $dbLink->dbh;
        if (defined $dbh) {
                if ($query =~ /^select/i || $query =~ /^show/i || $query =~ /^describe/i) {
                        my $url = WebGUI::URL::page('&wid='.$self->get("wobjectId").'&func=view');
                        foreach (keys %{$session{form}}) {
                                unless ($_ eq "pn" || $_ eq "wid" || $_ eq "func" || $_ =~ /identifier/i || $_ =~ /password/i) {
                                        $url = WebGUI::URL::append($url, WebGUI::URL::escape($_)
                                                .'='.WebGUI::URL::escape($session{form}{$_}));
                                }
                        }
			my $paginateAfter = $self->get("paginateAfter");
			$paginateAfter = 1000 if($nr > 1);
                        my $p = WebGUI::Paginator->new($url,$paginateAfter);
                        my $error = $p->setDataByQuery($query,$dbh,1,$placeholderParams);
                        if ($error ne "") {
                                WebGUI::ErrorHandler::warn("There was a problem with the query: ".$error);
                                push(@{$self->{_debug_loop}},{'debug.output'=>WebGUI::International::get(11,$self->get("namespace"))." ".$error});
                        } else {
                                my $first = 1;
                                my @columns;
                                my @rows;
                                my $rownum = 1;
                                my $rowdata = $p->getPageData;
                                foreach my $data (@$rowdata) {
					$self->{_query}{$nr}{rowData} = $data;
                                        my %row;
                                        my $colnum = 1;
                                        my @fields;
                                        foreach my $name ($p->getColumnNames) {
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
                                                $row{$prefix.'row.field.'.$name.'.value'} = $data->{$name};
                                        }
					# Process nested query
                                        if($self->{_query}{$nr + 1}{dbQuery}) {
                                                my $nest = $self->_processQuery($nr+1);
						%row = (%row , %$nest);
						$row{$prefix.'hasNest'} = $nest->{'query'.($nr+1).'.rows.count'};
                                        }
                                        $row{$prefix.'row.number'} = $rownum;
                                        $row{$prefix.'row.field_loop'} = \@fields;
                                        push(@rows,\%row);
                                        $first = 0;
                                        $rownum++;
                                }
                                $var{$prefix.'columns_loop'} = \@columns;
                                $var{$prefix.'rows_loop'} = \@rows;
				$var{$prefix.'columns.count'} = scalar(@columns);
                                $var{$prefix.'rows.count'} = $p->getRowCount;
                                $var{$prefix.'rows.count.isZero'} = ($p->getRowCount < 1);
                                $var{$prefix.'rows.count.isZero.label'} = WebGUI::International::get(18,$self->get("namespace"));
                                $p->appendTemplateVars(\%var) if ($nr == 1);
                        }
                } else {
                        push(@{$self->{_debug_loop}},{'debug.output'=>WebGUI::International::get(10,$self->get("namespace"))});
                        WebGUI::ErrorHandler::warn("SQLReport [".$self->get("wobjectId")."] The SQL query is improperly formatted.");
                }
                $dbLink->disconnect;
        } else {
                push(@{$self->{_debug_loop}},{'debug.output'=>WebGUI::International::get(12,$self->get("namespace"))});
                WebGUI::ErrorHandler::warn("SQLReport [".$self->get("wobjectId")."] Could not connect to database.");
        }
	return \%var;
}
1;

