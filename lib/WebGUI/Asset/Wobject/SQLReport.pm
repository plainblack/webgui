package WebGUI::Asset::Wobject::SQLReport;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
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
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Utility;
use WebGUI::Asset::Wobject;

our @ISA = qw(WebGUI::Asset::Wobject);



#-------------------------------------------------------------------
sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my $i18n = WebGUI::International->new($session,"Asset_SQLReport");
	push(@{$definition}, {
		assetName=>$i18n->get('assetName'),
		uiLevel => 9,
		icon=>'sqlReport.gif',
		tableName=>'SQLReport',
		className=>'WebGUI::Asset::Wobject::SQLReport',
		properties=>{
			templateId =>{
				fieldType=>"template",
				defaultValue=>'PBtmpl0000000000000059'
				},
			paginateAfter=>{
				fieldType=>"integer",
				defaultValue=>50
				},
			dbQuery1=>{
				fieldType=>"codearea",
				defaultValue=>undef
				}, 
			preprocessMacros1=>{
				fieldType=>"yesNo",
				defaultValue=>0
				},
			placeholderParams1=>{
				fieldType=>"textarea",
				defaultValue=>undef
				},
                        databaseLinkId1=>{
				fieldType=>"databaseLink",
                                defaultValue=>0
                        },
			dbQuery2=>{
                                fieldType=>"codearea",
                                defaultValue=>undef
                                },
                        preprocessMacros2=>{
				fieldType=>"yesNo",
                                defaultValue=>0
                                },
                        placeholderParams2=>{
                                fieldType=>"textarea",
                                defaultValue=>undef
                                },
                        databaseLinkId2=>{
				fieldType=>"databaseLink",
                                defaultValue=>0
                        },
			dbQuery3=>{
                                fieldType=>"codearea",
                                defaultValue=>undef
                                },
                        preprocessMacros3=>{
				fieldType=>"yesNo",
                                defaultValue=>0
                                },
                        placeholderParams3=>{
                                fieldType=>"textarea",
                                defaultValue=>undef
                                },
                        databaseLinkId3=>{
				fieldType=>"databaseLink",
                                defaultValue=>0
                        },
			dbQuery4=>{
                                fieldType=>"codearea",
                                defaultValue=>undef
                                },
                        preprocessMacros4=>{
				fieldType=>"yesNo",
                                defaultValue=>0
                                },
                        placeholderParams4=>{
                                fieldType=>"textarea",
                                defaultValue=>undef
                                },
                        databaseLinkId4=>{
				fieldType=>"databaseLink",
                                defaultValue=>0
                        },
			dbQuery5=>{
                                fieldType=>"codearea",
                                defaultValue=>undef
                                },
                        preprocessMacros5=>{
				fieldType=>"yesNo",
                                defaultValue=>0
                                },
                        placeholderParams5=>{
                                fieldType=>"textarea",
                                defaultValue=>undef
                                },
                        databaseLinkId5=>{
				fieldType=>"databaseLink",
                                defaultValue=>0
                        },
			debugMode=>{
				fieldType=>"yesNo",
				defaultValue=>0
				},
                        }
                });
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------
sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm();
	my $i18n = WebGUI::International->new($self->session,"Asset_SQLReport");
   	$tabform->getTab("display")->template(
      		-value=>$self->getValue('templateId'),
                -label=>$i18n->get(72),
                -hoverHelp=>$i18n->get('72 description'),
      		-namespace=>"SQLReport"
   		);
        $tabform->getTab("properties")->yesNo(
                -name=>"debugMode",
                -label=>$i18n->get(16),
                -hoverHelp=>$i18n->get('16 description'),
                -value=>$self->getValue("debugMode")
                );

	# Add toggleQuery javascript
	$tabform->getTab("properties")->raw(qq|
		<script type="text/javascript">
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
	   $tabform->getTab("properties")->trClass("query".$nr);

	   $tabform->getTab("properties")->readOnly(
		   -value=>"<hr>",
                   -label=>join '', "<b>", $i18n->get('4'), $nr,":</b>",
		   ); 
	   $tabform->getTab("properties")->yesNo(
	  	   -name=>"preprocessMacros".$nr,
		   -label=>$i18n->get(15),
		   -hoverHelp=>$i18n->get('15 description'),
		   -value=>$self->getValue("preprocessMacros".$nr)
		   );
	   $tabform->getTab("properties")->textarea(
                   -name=>"placeholderParams".$nr,
                   -label=>$i18n->get('Placeholder Parameters'),
                   -hoverHelp=>$i18n->get('Placeholder Parameters description'),
                   -value=>$self->getValue("placeholderParams".$nr)
                   );
	   $tabform->getTab("properties")->codearea(
		   -name=>"dbQuery".$nr,
		   -label=>$i18n->get(4),
		   -hoverHelp=>$i18n->get('4 description'),
		   -value=>$self->getValue("dbQuery".$nr)
		   );
	   $tabform->getTab("properties")->databaseLink(
		   -name=>"databaseLinkId".$nr,
		   -value=>$self->getValue("databaseLinkId".$nr)
		   );

	   # Add a "Add another query" button
	   if ($nr < 5	and ($self->get("dbQuery".($nr+1)) eq "" || ($self->get("dbQuery".($nr)) eq "" and $self->get("dbQuery".($nr+1)) ne ""))) {
	           $tabform->getTab("properties")->button(
        	           -value=>$i18n->get('Add another query'),
                	   -extras=>'onclick="toggleQuery(\''.($nr+1).'\'); this.style.display=\'none\';"',
	                   -noWait=>1
        	           );
	   }

	   # Make empty query blocks invisible
           if ($nr > 1 && ($self->get("dbQuery".$nr) eq "" || $self->get("dbQuery".($nr-1)) eq "")) {
		$tabform->getTab("properties")->raw(qq|
                        <script type="text/javascript">
                                toggleQuery('$nr');
                        </script>
                        |);
           }

	}
	# Undefine TR class
	$tabform->getTab("properties")->trClass();

	$tabform->getTab("display")->integer(
		-name=>"paginateAfter",
		-label=>$i18n->get(14),
		-hoverHelp=>$i18n->get('14 description'),
		-value=>$self->getValue("paginateAfter")
		);
	return $tabform;
}


#-------------------------------------------------------------------
sub view {
	my $self = shift;
        # Initiate an empty debug loop
        $self->{_debug_loop} = [] ;
	
	# Store queries in class
	$self->_storeQueries();

	# Process the quer(y|ies)
	my $var = $self->_processQuery();
	
	# Add debug loop to template vars
	$var->{'debug_loop'} = $self->{_debug_loop};
	#use Data::Dumper; return '<pre>'.Dumper($var).'</pre>';
	return $self->processTemplate($var, $self->get("templateId"));
}

#-------------------------------------------------------------------
#sub www_edit {
#        my $self = shift;
#	return $self->session->privilege->insufficient() unless $self->canEdit;
#	$self->getAdminConsole->setHelp("sql report add/edit", "Asset_SQLReport");
#        return $self->getAdminConsole->render($self->getEditForm->print,WebGUI::International::get("8","Asset_SQLReport"));
#}


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
        foreach my $row (split(/\n/,$params)) {
		chop($row) if ($row =~ m/\s+$/);	
                next if ($row =~ /^\s*$/);
                my ($type,$field) = split(/:/,$row);
                my $param;
                if($type =~ /^form/) {
                        $param = $self->session->form->process("$field");
                } elsif ($type =~ /^query(\d)/) {
                        $param = $self->{_query}{$1}{rowData}{$field};
                }
                WebGUI::Macro::process($self->session,\$param);
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
		$query = $self->{_query}{$nr}{dbQuery};
                WebGUI::Macro::process($self->session,\$query);
        } else {
                $query = $self->{_query}{$nr}{dbQuery};
        }
	
	my $i18n = WebGUI::International->new($self->session,"Asset_SQLReport");
        push(@{$self->{_debug_loop}},{'debug.output'=>$i18n->get(17).$query});
        push(@{$self->{_debug_loop}},{'debug.output'=>$i18n->get('debug placeholder parameters').join(",",@$placeholderParams)});
        my $dbLink = WebGUI::DatabaseLink->new($self->session,$self->{_query}{$nr}{databaseLinkId});
        my $dbh = $dbLink->db;
        if (defined $dbh) {
                if ($query =~ /^select/i || $query =~ /^show/i || $query =~ /^describe/i) {
                        my $url = $self->getUrl('func=view');
                        foreach (keys %{$session{form}}) {
                                unless ($_ eq "pn" || $_ eq "func" || $_ =~ /identifier/i || $_ =~ /password/i) {
                                        $url = $self->session->url->append($url, $self->session->url->escape($_)
                                                .'='.$self->session->url->escape($self->session->form->process("$_")));
                                }
                        }
			my $paginateAfter = $self->get("paginateAfter");
			$paginateAfter = 1000 if($nr > 1);
                        my $p = WebGUI::Paginator->new($self->session,$url,$paginateAfter);
                        my $error = $p->setDataByQuery($query,$dbh,1,$placeholderParams);
                        if ($error ne "") {
                                $self->session->errorHandler->warn("There was a problem with the query: ".$error);
                                push(@{$self->{_debug_loop}},{'debug.output'=>$i18n->get(11)." ".$error});
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
                                $var{$prefix.'rows.count.isZero.label'} = $i18n->get(18);
                                $p->appendTemplateVars(\%var) if ($nr == 1);
                        }
                } else {
                        push(@{$self->{_debug_loop}},{'debug.output'=>$i18n->get(10)});
                        $self->session->errorHandler->warn("SQLReport [".$self->getId."] The SQL query is improperly formatted.");
                }
                $dbLink->disconnect;
        } else {
                push(@{$self->{_debug_loop}},{'debug.output'=>$i18n->get(12)});
                $self->session->errorHandler->warn("SQLReport [".$self->getId."] Could not connect to database.");
        }
	return \%var;
}
1;

