package WebGUI::Asset::Wobject::SQLReport;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::DatabaseLink;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Paginator;
use WebGUI::SQL;
use WebGUI::Utility;
use WebGUI::Asset::Wobject;
use WebGUI::Cache;
use WebGUI::Text qw(:csv);

our @ISA = qw(WebGUI::Asset::Wobject);



#-------------------------------------------------------------------
sub definition {
    my $class = shift;
    my $session = shift;
    my $definition = shift;
    my $i18n = WebGUI::International->new($session,"Asset_SQLReport");
	my %properties;
	tie %properties, 'Tie::IxHash';
	%properties = (
        templateId =>{
            fieldType=>"template",
            defaultValue=>'PBtmpl0000000000000059',
            label=>$i18n->get(72),
        },
        cacheTimeout=>{
            fieldType=>"interval",
            defaultValue=>0,
            label=>$i18n->get('cache timeout'),
        },
        paginateAfter=>{
            fieldType=>"integer",
            defaultValue=>50,
            label=>$i18n->get(14),
        },
        dbQuery1=>{
            fieldType=>"codearea",
            defaultValue=>undef,
            label=>$i18n->get(4) . ' 1',
        },
        prequeryStatements1=>{
            fieldType=>"codearea",
            defaultValue=>undef,
            label => $i18n->get('Prequery statements') . ' 1',
        },
        preprocessMacros1=>{
            fieldType=>"yesNo",
            defaultValue=>0,
            label=>$i18n->get(15) . ' 1',
        },
        placeholderParams1=>{
            fieldType=>"textarea",
            defaultValue=>undef,
            label=>$i18n->get('Placeholder Parameters') . ' 1',
        },
        databaseLinkId1=>{
            fieldType=>"databaseLink",
            defaultValue=>0,
            label=>$i18n->get("1075", 'WebGUI').' 1',
        },
        dbQuery2=>{
            fieldType=>"codearea",
            defaultValue=>undef,
            label=>$i18n->get(4) . ' 2',
        },
        prequeryStatements2=>{
            fieldType=>"codearea",
            defaultValue=>undef,
            label => $i18n->get('Prequery statements') . ' 2',
        },
        preprocessMacros2=>{
            fieldType=>"yesNo",
            defaultValue=>0,
            label=>$i18n->get(15) . ' 2',
        },
        placeholderParams2=>{
            fieldType=>"textarea",
            defaultValue=>undef,
            label=>$i18n->get('Placeholder Parameters') . ' 2',
        },
        databaseLinkId2=>{
            fieldType=>"databaseLink",
            defaultValue=>0,
            label=>$i18n->get("1075", 'WebGUI').' 2',
        },
        dbQuery3=>{
            fieldType=>"codearea",
            defaultValue=>undef,
            label=>$i18n->get(4) . ' 3',
        },
        prequeryStatements3=>{
            fieldType=>"codearea",
            defaultValue=>undef,
            label => $i18n->get('Prequery statements') . ' 3',
        },
        preprocessMacros3=>{
            fieldType=>"yesNo",
            defaultValue=>0,
            label=>$i18n->get(15) . ' 3',
        },
        placeholderParams3=>{
            fieldType=>"textarea",
            defaultValue=>undef,
            label=>$i18n->get('Placeholder Parameters') . ' 3',
        },
        databaseLinkId3=>{
            fieldType=>"databaseLink",
            defaultValue=>0,
            label=>$i18n->get("1075", 'WebGUI').' 3',
        },
        dbQuery4=>{
            fieldType=>"codearea",
            defaultValue=>undef,
            label=>$i18n->get(4) . ' 4',
        },
        prequeryStatements4=>{
            fieldType=>"codearea",
            defaultValue=>undef,
            label => $i18n->get('Prequery statements') . ' 4',
        },
        preprocessMacros4=>{
            fieldType=>"yesNo",
            defaultValue=>0,
            label=>$i18n->get(15) . ' 4',
        },
        placeholderParams4=>{
            fieldType=>"textarea",
            defaultValue=>undef,
            label=>$i18n->get('Placeholder Parameters') . ' 4',
        },
        databaseLinkId4=>{
            fieldType=>"databaseLink",
            defaultValue=>0,
            label=>$i18n->get("1075", 'WebGUI').' 4',
        },
        dbQuery5=>{
            fieldType=>"codearea",
            defaultValue=>undef,
            label=>$i18n->get(4) . ' 5',
        },
        prequeryStatements5=>{
            fieldType=>"codearea",
            defaultValue=>undef,
            label => $i18n->get('Prequery statements') . ' 5',
        },
        preprocessMacros5=>{
            fieldType=>"yesNo",
            defaultValue=>0,
            label=>$i18n->get(15) . '5',
        },
        placeholderParams5=>{
            fieldType=>"textarea",
            defaultValue=>undef,
            label=>$i18n->get('Placeholder Parameters') . ' 5',
        },
        databaseLinkId5=>{
            fieldType=>"databaseLink",
            defaultValue=>0,
            label=>$i18n->get("1075", 'WebGUI').' 5',
        },
        debugMode=>{
            fieldType=>"yesNo",
            defaultValue=>0,
            label=>$i18n->get(16),
        },

        # download
        downloadType=>{
            fieldType=>"text",
            defaultValue=>"none",
            label=>$i18n->get("download type"),
        },
        downloadFilename=>{
            fieldType=>"text",
            defaultValue=>"",
            label=>$i18n->get("download filename"),
        },
        downloadTemplateId=>{
            fieldType=>"template",
            defaultValue=>'SQLReportDownload00001',
            label=>$i18n->get("download template"),
        },
        downloadMimeType=>{
            fieldType=>"text",
            defaultValue=>"text/html",
            label=>$i18n->get("download mimetype"),
        },
        downloadUserGroup=>{
            fieldType    => "group",
            defaultValue => "7",
            label        => $i18n->get("download usergroup"),
        },
    );
    push(@{$definition}, {
        assetName=>$i18n->get('assetName'),
        uiLevel => 5,
        icon=>'sqlReport.gif',
        tableName=>'SQLReport',
        className=>'WebGUI::Asset::Wobject::SQLReport',
		properties => \%properties,
        autoGenerateForms => 0,
    });
    return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 getContentLastModified ( )

Override the base method, since SQL Report content can change without the asset being
touched.  Default to using $self->get('cacheTimeout') seconds ago.

=cut

sub getContentLastModified {
    my $self = shift;
    return (time - $self->get("cacheTimeout"));
}

#-------------------------------------------------------------------

=head2 getEditForm ( )

Manually make the edit form due to javascript for adding more queries.

=cut

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
        $tabform->getTab("display")->interval(
                -name=>"cacheTimeout",
                -label=>$i18n->get('cache timeout'),
                -hoverHelp=>$i18n->get('cache timeout description'),
		-uiLevel => 8,
                -value=>$self->getValue("cacheTimeout")
                );
	
	
	### Download
	# Download Type
	my %downloadTypes;
	tie %downloadTypes, 'Tie::IxHash', 
		"none" 		=> $i18n->get("No Download"),
		"csv"		=> $i18n->get("CSV"),
		"template"	=> $i18n->get("Template"),
		;
		
	$tabform->getTab("properties")->radioList(
		-name=>"downloadType",		# ID is downloadType_formId
		-label=>$i18n->get("download type"),
		-hoverHelp=>$i18n->get("download type description"),
		-vertical=>1,
		-options=> \%downloadTypes,
		-defaultValue=>"none",
		-value=>$self->getValue("downloadType"),
		-extras=> "onclick='changeDownloadType(this)'"
		);
	
	# Download Filename
	$tabform->getTab("properties")->text(
		-name=>"downloadFilename",		# ID is downloadFilename_formId
		-label=>$i18n->get("download filename"),
		-hoverHelp=>$i18n->get("download filename description"),
		-value=>$self->getValue("downloadFilename"),
		);
	
	# Download template (if necessary)
	$tabform->getTab("properties")->template(
		-name=>"downloadTemplateId",	# ID is downloadTemplateId_formId
		-label=>$i18n->get("download template"),
		-hoverHelp=>$i18n->get("download template description"),
		-value=>$self->getValue("downloadTemplateId"),
		-namespace=>"SQLReport/Download",
		);
	
	# Download mimeType (if necessary)
	my %downloadMimeType;
	tie %downloadMimeType, 'Tie::IxHash', 
		"application/octet-stream"	=> "application/octet-stream",
		"application/xml"		=> "application/xml",
		"application/csv"		=> "application/csv",
		"text/html"			=> "text/html",
		"text/plain"			=> "text/plain",
		;

	$tabform->getTab("properties")->selectBox(
		-name=>"downloadMimeType",
		-label=>$i18n->get("download mimetype"),
		-hoverHelp=>$i18n->get("download mimetype description"),
		-options=> \%downloadMimeType,
		-value=>$self->getValue("downloadMimeType"),
		-defaultValue=>"application/octet-stream",
		);
	
	# Download UserGroup
	$tabform->getTab("security")->group(
		-name=>"downloadUserGroup",
		-label=>$i18n->get("download usergroup"),
		-hoverHelp=>$i18n->get("download usergroup description"),
		-value=>$self->getValue("downloadUserGroup"),
		-defaultValue=>$self->getValue("groupIdView"),
		);
	
	# javascript
	$self->session->style->setScript($self->session->url->extras("wobject/SQLReport/editFormDownload.js"), {type => 'text/javascript',});
	
	### /DOWNLOAD
	
	
	# Add toggleQuery javascript
	$tabform->getTab("properties")->raw(qq|
		<script type="text/javascript">
		function toggleQuery(Id) {
			queryClass = "query" + Id;
			var tr = document.getElementsByTagName("tr");
			if (tr == null) return undef;
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
			-name	=> "prequeryStatements".$nr,
			-label	=> $i18n->get('Prequery statements'),
			-hoverHelp => $i18n->get('Prequery statements description'),
            -syntax => "sql",
			-value	=> $self->getValue("prequeryStatements".$nr),
		);
		$tabform->getTab("properties")->codearea(
			-name=>"dbQuery".$nr,
			-label=>$i18n->get(4),
			-hoverHelp=>$i18n->get('4 description'),
            -syntax => "sql",
			-value=>$self->getValue("dbQuery".$nr)
		);
		$tabform->getTab("properties")->databaseLink(
			-name=>"databaseLinkId".$nr,
			-value=>$self->getValue("databaseLinkId".$nr)
		);

		# Add a "Add another query" button
		if ($nr < 5 and ($self->get("dbQuery".($nr+1)) eq "" || ($self->get("dbQuery".($nr)) eq "" and $self->get("dbQuery".($nr+1)) ne ""))) {
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

=head2 download ( )

Returns the SQLReport in the configured manner. Returns nothing if download is
not enabled.

=cut

sub download {
	my $self	= shift;
	
	# Instead of going through some costly exercises...
	return undef if ($self->getValue("downloadType") eq "none");
	
        # Initiate an empty debug loop
        $self->{_debug_loop} = [] ;
	
	# Store queries in class
	$self->_storeQueries();
	
	# If we're downloading CSV
	if ($self->getValue("downloadType") eq "csv") {
        my $data	= $self->_processQuery(0,0);
		my $out		= "";
		
		### Loop through the returned structure and put it through Text::CSV
		# Column heads
		$out	.= joinCSV(
			map { $_->{"field.name"} } 
				@{$data->{rows_loop}->[0]->{"row.field_loop"}}
			);
		
		# Data lines
		for my $row (@{$data->{rows_loop}}) {
			$out .= "\n".joinCSV(map { $_->{"field.value"} }
					@{$row->{"row.field_loop"}}
				);
		}
		
		return $out;
	} 
    elsif ($self->getValue("downloadType") eq "template") { 
        my $data	= $self->_processQuery(1,0);
        my $output  = $self->processTemplate($data,$self->get("downloadTemplateId"));
        WebGUI::Macro::process($self->session, \$output);
		return $output;
	} 
    else {
		# I don't know what to do
		return undef;
	}
}



#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
    my $self = shift;
    $self->SUPER::prepareView();
    my $template = WebGUI::Asset::Template->new($self->session, $self->get("templateId"));
    if (!$template) {
        WebGUI::Error::ObjectNotFound::Template->throw(
            error      => qq{Template not found},
            templateId => $self->get("templateId"),
            assetId    => $self->getId,
        );
    }
    $template->prepare($self->getMetaDataAsTemplateVariables);
    $self->{_viewTemplate} = $template;
}


#-------------------------------------------------------------------

=head2 purgeCache ( )

See WebGUI::Asset::purgeCache() for details.

=cut

sub purgeCache {
	my $self = shift;
	WebGUI::Cache->new($self->session,"view_".$self->getId)->delete;
	$self->SUPER::purgeCache;
}

#-------------------------------------------------------------------

=head2 view ( )

See WebGUI::Asset::view() for details.  This method also performs content caching
if the user is not in Admin Mode.

=cut

sub view {
	my $self = shift;
	if (!$self->session->var->isAdminOn && $self->get("cacheTimeout") > 10) {
        my $cache = $self->getCache;
        my $out   = $cache->get if defined $cache;
		return $out if $out;
	}
        # Initiate an empty debug loop
        $self->{_debug_loop} = [] ;
	
	# Store queries in class
	$self->_storeQueries();

	# Process the quer(y|ies)
	my $var = $self->_processQuery();
	
	# Add debug loop to template vars
	$var->{'debug_loop'} = $self->{_debug_loop};
	#use Data::Dumper; return '<pre>'.Dumper($var).'</pre>';
	
	# Add the "Download data" link if the user is allowed to download
	if ($self->getValue("downloadType") ne "none" 
		&& $self->session->user->isInGroup($self->getValue("downloadUserGroup"))
	) {
	    $var->{'canDownload'} = 1;
        $var->{'downloadLink'} = $self->_getDownloadLink($self);
    }
	
       	my $out = $self->processTemplate($var,undef,$self->{_viewTemplate});
	if (!$self->session->var->isAdminOn && $self->get("cacheTimeout") > 10) {
		WebGUI::Cache->new($self->session,"view_".$self->getId)->set($out,$self->get("cacheTimeout"));
	}
       	return $out;
}

#-------------------------------------------------------------------
# Create download link be adding all the passed in parameters and values to the url
sub _getDownloadLink {
	my $self = shift;
    my %params;
    for my $nr (1 .. 5) {
        foreach my $row (split(/\n/,$self->{_query}{$nr}{placeholderParams})) {
            $row =~ s/^\s+//;
            $row =~ s/\s+$//;
            if ($row =~ /^form:(.*)/) {
                $params{$1} ||= $self->session->form->param($1);
            }
        }
    }
    my $url = "func=download";
    for my $param (sort keys %params) {
        $url .= ";$param=" . $self->session->url->escape($params{$param});
    }
    return $self->getUrl($url);
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
        foreach my $row (split(/\n/,$params)) {
		$row =~ s/^\s+//;
		$row =~ s/\s+$//;
                next if ($row eq '');
                my ($type,$field) = split(/:/,$row);
                my $param;
                if($type =~ /^form/) {
                        $param = $self->session->form->process($field);
                } elsif ($type =~ /^query(\d)/) {
                        $param = $self->{_query}{$1}{rowData}{$field};
                }
		else {
			$param = $row;
		}
                WebGUI::Macro::process($self->session,\$param);
                push(@placeholderParams, $param);
        }
        return \@placeholderParams;
}


#-------------------------------------------------------------------
# _processQuery($nest, $page, $nr)
# Recursive sub to process this SQLReport's queries.
# Arguments:	$nest	- If true, will run the nested queries. Defaults to true
#		$page	- If true, will paginate. Defaults to true
#		$nr	- This query number. Defaults to one. This is used 
#		internally to tell which query we're performing. You should not
#		send this yourself.
# Returns:	A reference to a datastructure containing template variables to 
#		be passed to processTemplate()
sub _processQuery {
	my $self 	= shift;
	my $nest	= shift;
	$nest		= 1 unless defined $nest;	
	my $page	= shift;
	$page		= 1 unless defined $page;	
	my $nr 		= shift || 1;
        my ($query, %var, $prefix);
	my $i18n = WebGUI::International->new($self->session,"Asset_SQLReport");

	if($nr > 1) {
		$prefix = 'query'.$nr.'.';
	}

    if (! $self->{_query}{$nr}{dbQuery} || $self->{_query}{$nr}{dbQuery} =~ m{\A \s* \Z}msx) {
        $self->session->errorHandler->warn("No query specified for query $nr on '" . $self->getId . "'");
        push @{$self->{_debug_loop}}, { 'debug.output' => sprintf($i18n->get('No query specified for query'), $nr) };
        return \%var;
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

        push(@{$self->{_debug_loop}},{'debug.output'=>$i18n->get(17).$query});
        push(@{$self->{_debug_loop}},{'debug.output'=>$i18n->get('debug placeholder parameters').join(",",@$placeholderParams)});
        my $dbLink = WebGUI::DatabaseLink->new($self->session,$self->{_query}{$nr}{databaseLinkId});
        if (!$dbLink) {
            $self->session->errorHandler->error("Could not find database link for query #$nr: '".$self->{_query}{$nr}{databaseLinkId}."'. Has it been created?");
            push @{$self->{_debug_loop}}, { 'debug.output' => 'Could not find database link'};
            return \%var;
        }
	my $dbh = $dbLink->db;
        if (defined $dbh) {
		if ($dbLink->queryIsAllowed($query)) {
                	# Check and execute prequery statements first
			foreach (split(/\n/, $self->getValue("prequeryStatements".$nr))) {
				my $prequeryStatement = $_;
				WebGUI::Macro::process($self->session, \$prequeryStatement) if ($self->{_query}{$nr}{preprocessMacros});
				
				if ($dbLink->queryIsAllowed($prequeryStatement)) {
					my $sth = $dbh->unconditionalRead($prequeryStatement);
					if ($sth->errorCode > 0) {
						push(@{$self->{_debug_loop}},{
							'debug.output' => $i18n->get('Prequery error').' "'.$prequeryStatement.'": '.$sth->errorMessage
						});
					} 
					else {
						push(@{$self->{_debug_loop}},{
							'debug.output' => "Prequery: $prequeryStatement"
						});
					}
					$sth->finish;
				} 
				else {
					push(@{$self->{_debug_loop}},{'debug.output'=>$i18n->get("Prequery not allowed").$prequeryStatement});
				}
			}

                        my $url = $self->getUrl('func=view');
                        foreach ($self->session->form->param) {
                                unless ($_ eq "pn" || $_ eq "op" || $_ eq "func" || $_ =~ /identifier/i || $_ =~ /password/i) {
                                        $url = $self->session->url->append($url, $self->session->url->escape($_)
                                                .'='.$self->session->url->escape($self->session->form->process($_)));
                                }
                        }
			my $paginateAfter = ($page == 1) ? $self->get("paginateAfter") : 99999999;
			my $paginatePage = ($nr > 1) ? 1 : $self->session->form->param('pn');
                        my $p = WebGUI::Paginator->new($self->session,$url,$paginateAfter, undef, $paginatePage);
                        my $error = $p->setDataByQuery($query,$dbh,1,$placeholderParams);
                        if ($error ne "") {
                                $self->session->errorHandler->warn("There was a problem with the query: ".$error);
                                push(@{$self->{_debug_loop}},{'debug.output'=>$i18n->get(11)." ".$error});
                        } 
			else {
                                my $first = 1;
                                my @columns;
                                my @rows;
                                my $rownum = 1;
                                foreach my $data (@{$p->getPageData($paginatePage)}) {
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
                                                my $tmpl_name = $name;
                                                $tmpl_name =~ s/\ /-/g;
                                                $row{$prefix.'row.field.'.$tmpl_name.'.value'} = $data->{$name};
                                        }
					# Process nested query
                                        if ($nest && $self->{_query}{$nr + 1}{dbQuery} =~ m/\S/) {
                                                my $nest = $self->_processQuery($nest,$page,$nr+1);
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

#-------------------------------------------------------------------

=head2 www_download ( )

Calls download() to let user download the SQLReport in the configured manner.

=cut

sub www_download {
	my $self	= shift;
	
	# Only allow if download type is not "none"
	return undef if $self->getValue("downloadType") eq "none";
	
	# Only allow users in appropriate group
	return $self->session->privilege->noAccess() 
		unless $self->session->user->isInGroup($self->getValue("downloadUserGroup"));
	
	# Set filename and mimetype
	if ($self->getValue("downloadType") eq "csv") {
		$self->session->http->setFilename($self->getValue("downloadFilename"),"application/octet-stream");
	}
	else {
		$self->session->http->setFilename($self->getValue("downloadFilename"),$self->getValue("downloadMimeType"));
	}
	
	$self->session->http->sendHeader;
	
	
	return $self->download;
}



#-------------------------------------------------------------------

=head2 www_view ( )

See WebGUI::Asset::Wobject::www_view() for details.

=cut

sub www_view {
	my $self = shift;
	$self->session->http->setCacheControl($self->get("cacheTimeout"));
	$self->SUPER::www_view(@_);
}

1;

