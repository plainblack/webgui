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
use WebGUI::Asset::Wobject;
use WebGUI::Text qw(:csv);
use Tie::IxHash;

use Moose;
use WebGUI::Definition::Asset;
extends 'WebGUI::Asset::Wobject';
define assetName => ['assetName', 'Asset_SQLReport'];
define icon      => 'sqlReport.gif';
define tableName => 'SQLReport';
property templateId => (
            fieldType   => "template",
            default     => 'PBtmpl0000000000000059',
            label       => [72, 'Asset_SQLReport'],
            hoverHelp   => ['72 description', 'Asset_SQLReport'],
      		namespace   => "SQLReport"
        );
property cacheTimeout => (
            fieldType   => "interval",
            default     => 0,
            label       => ['cache timeout', 'Asset_SQLReport'],
            hoverHelp   => ['cache timeout description', 'Asset_SQLReport'],
            uiLevel     => 8,
        );
property paginateAfter => (
            fieldType   => "integer",
            default     => 50,
            label       => ['14', 'Asset_SQLReport'],
            hoverHelp   => ['14 description', 'Asset_SQLReport'],
        );
property dbQuery1 => (
            fieldType   => "codearea",
            default     => undef,
            label       => [4, 'Asset_SQLReport', 1],
			hoverHelp   => ['4 description', 'Asset_RichEdit'],
            rowClass    => 'query1',
        );
property prequeryStatements1 => (
            fieldType   => "codearea",
            default     => undef,
            label       => ['Prequery statements %s', 'Asset_SQLReport', 1],
            rowClass    => 'query1',
        );
property preprocessMacros1 => (
            fieldType   => "yesNo",
            default     => 0,
            label       => ['Preprocess macros on query %s?', 'Asset_SQLReport', 1],
			hoverHelp   => ['15 description', 'Asset_RichEdit'],
            rowClass    => 'query1',
        );
property placeholderParams1 => (
            fieldType   => "textarea",
            default     => undef,
            label       => ['Placeholder Parameters %s', 'Asset_SQLReport', 1],
			hoverHelp   => ['Placeholder Parameters description', 'Asset_RichEdit'],
            rowClass    => 'query1',
        );
property databaseLinkId1 => (
            fieldType   => "databaseLink",
            default     => 0,
            label       => ['Database Link %s', 'Asset_SQLReport', 1],
            rowClass    => 'query1',
        );
property dbQuery2 => (
            fieldType   => "codearea",
            default     => undef,
            label       => [4, 'Asset_SQLReport', 2],
			hoverHelp   => ['4 description', 'Asset_RichEdit'],
            rowClass    => 'query2',
        );
property prequeryStatements2 => (
            fieldType   => "codearea",
            default     => undef,
            label       => ['Prequery statements %s', 'Asset_SQLReport', 2],
			hoverHelp   => ['15 description', 'Asset_RichEdit'],
            rowClass    => 'query2',
        );
property preprocessMacros2 => (
            fieldType   => "yesNo",
            default     => 0,
            label       => ['Preprocess macros on query %s?', 'Asset_SQLReport', 2],
			hoverHelp   => ['15 description', 'Asset_RichEdit'],
            rowClass    => 'query2',
        );
property placeholderParams2 => (
            fieldType   => "textarea",
            default     => undef,
            label       => ['Placeholder Parameters %s', 'Asset_SQLReport', 2],
			hoverHelp   => ['Placeholder Parameters description', 'Asset_RichEdit'],
            rowClass    => 'query2',
        );
property databaseLinkId2 => (
            fieldType   => "databaseLink",
            default     => 0,
            label       => ['Database Link %s', 'Asset_SQLReport', 2],
            rowClass    => 'query2',
        );
property dbQuery3 => (
            fieldType   => "codearea",
            default     => undef,
            label       => [4, 'Asset_SQLReport', 3],
			hoverHelp   => ['4 description', 'Asset_RichEdit'],
            rowClass    => 'query3',
        );
property prequeryStatements3 => (
            fieldType   => "codearea",
            default     => undef,
            label       => ['Prequery statements %s', 'Asset_SQLReport', 3],
			hoverHelp   => ['15 description', 'Asset_RichEdit'],
            rowClass    => 'query3',
        );
property preprocessMacros3 => (
            fieldType   => "yesNo",
            default     => 0,
            label       => ['Preprocess macros on query %s?', 'Asset_SQLReport', 3],
			hoverHelp   => ['15 description', 'Asset_RichEdit'],
            rowClass    => 'query3',
        );
property placeholderParams3 => (
            fieldType   => "textarea",
            default     => undef,
            label       => ['Placeholder Parameters %s', 'Asset_SQLReport', 3],
			hoverHelp   => ['Placeholder Parameters description', 'Asset_RichEdit'],
            rowClass    => 'query3',
        );
property databaseLinkId3 => (
            fieldType   => "databaseLink",
            default     => 0,
            label       => ['Database Link %s', 'Asset_SQLReport', 3],
            rowClass    => 'query3',
        );
property dbQuery4 => (
            fieldType   => "codearea",
            default     => undef,
            label       => [4, 'Asset_SQLReport', 4],
			hoverHelp   => ['4 description', 'Asset_RichEdit'],
            rowClass    => 'query4',
        );
property prequeryStatements4 => (
            fieldType   => "codearea",
            default     => undef,
            label       => ['Prequery statements %s', 'Asset_SQLReport', 4],
			hoverHelp   => ['15 description', 'Asset_RichEdit'],
            rowClass    => 'query4',
        );
property preprocessMacros4 => (
            fieldType   => "yesNo",
            default     => 0,
            label       => ['Preprocess macros on query %s?', 'Asset_SQLReport', 4],
			hoverHelp   => ['15 description', 'Asset_RichEdit'],
            rowClass    => 'query4',
        );
property placeholderParams4 => (
            fieldType   => "textarea",
            default     => undef,
            label       => ['Placeholder Parameters %s', 'Asset_SQLReport', 4],
			hoverHelp   => ['Placeholder Parameters description', 'Asset_RichEdit'],
            rowClass    => 'query4',
        );
property databaseLinkId4 => (
            fieldType   => "databaseLink",
            default     => 0,
            label       => ['Database Link %s', 'Asset_SQLReport', 4],
            rowClass    => 'query4',
        );
property dbQuery5 => (
            fieldType   => "codearea",
            default     => undef,
            label       => [4, 'Asset_SQLReport', 5],
			hoverHelp   => ['4 description', 'Asset_RichEdit'],
            rowClass    => 'query5',
        );
property prequeryStatements5 => (
            fieldType   => "codearea",
            default     => undef,
            label       => ['Prequery statements %s', 'Asset_SQLReport', 5],
			hoverHelp   => ['15 description', 'Asset_RichEdit'],
            rowClass    => 'query5',
        );
property preprocessMacros5 => (
            fieldType   => "yesNo",
            default     => 0,
            label       => ['Preprocess macros on query %s?', 'Asset_SQLReport', 5],
			hoverHelp   => ['15 description', 'Asset_RichEdit'],
            rowClass    => 'query5',
        );
property placeholderParams5 => (
            fieldType   => "textarea",
            default     => undef,
            label       => ['Placeholder Parameters %s', 'Asset_SQLReport', 5],
			hoverHelp   => ['Placeholder Parameters description', 'Asset_RichEdit'],
            rowClass    => 'query5',
        );
property databaseLinkId5 => (
            fieldType   => "databaseLink",
            default     => 0,
            label       => ['Database Link %s', 'Asset_SQLReport', 5],
            rowClass    => 'query5',
        );
property debugMode => (
            fieldType   => "yesNo",
            default     => 0,
            label       => [16, 'Asset_SQLReport'],
            hoverHelp   => ['16 description', 'Asset_SQLReport'],
        );

        # download
property downloadType => (
            fieldType   => "text",
            default     => "none",
            label       => ["download type", 'Asset_SQLReport'],
            hoverHelp   => ["download type description", 'Asset_RichEdit'],
            vertical    => 1,
            options     => \&_downloadType_options,
            extras      => "onclick='changeDownloadType(this)'"
        );
sub _downloadType_options {
    my $self = shift;
    tie my %downloadTypes, 'Tie::IxHash', 
        "none"     => "No Download",
        "csv"      => "CSV",
        "template" => "Template",
    ;
    return \%downloadTypes;
}
property downloadFilename => (
            fieldType   => "text",
            default     => "",
            label       => ["download filename", 'Asset_SQLReport'],
            hoverHelp   => ["download filename description", 'Asset_SQLReport'],
        );
property downloadTemplateId => (
            fieldType   => "template",
            default     => 'SQLReportDownload00001',
            label       => ["download template", 'Asset_SQLReport'],
            hoverHelp   => ["download template description", 'Asset_SQLReport'],
            namespace   => "SQLReport/Download",
        );
property downloadMimeType => (
            fieldType   => "text",
            default     => "text/html",
            label       => ["download mimetype", 'Asset_SQLReport'],
            hoverHelp   => ["download mimetype description", 'Asset_SQLReport'],
            options     => \&_downloadMimeType_options,
        );
sub _downloadMimeType_options {
    my $self = shift;
    my %downloadMimeType;
    tie %downloadMimeType, 'Tie::IxHash', 
        "application/octet-stream"  => "application/octet-stream",
        "application/xml"           => "application/xml",
        "application/csv"           => "application/csv",
        "text/html"                 => "text/html",
        "text/plain"                => "text/plain",
    ;
    return \%downloadMimeType;
}
property downloadUserGroup => (
            fieldType   => "group",
            builder     => '_downloadUserGroup_default',
            lazy        => 1,
            label       => ["download usergroup", 'Asset_SQLReport'],
            hoverHelp   => ["download usergroup description", 'Asset_SQLReport'],
        );
sub _downloadUserGroup_default {
    my $self = shift;
    return $self->groupIdView;
}
has '+uiLevel' => (
    default => 5,
);




#-------------------------------------------------------------------

=head2 getContentLastModified ( )

Override the base method, since SQL Report content can change without the asset being
touched.  Default to using $self->get('cacheTimeout') seconds ago.

=cut

sub getContentLastModified {
    my $self = shift;
    return (time - $self->cacheTimeout);
}

#-------------------------------------------------------------------

=head2 getEditForm ( )

Manually make the edit form due to javascript for adding more queries.

=cut

override getEditForm => sub {
    my $self    = shift;
    my $session = $self->session;
    my ( $style, $url ) = $session->quick( qw( style url ) );

    # Add javascript
    $style->setScript( $url->extras("wobject/SQLReport/editFormDownload.js"), { type => 'text/javascript', } );
    $style->setScript( $url->extras("yui/build/yahoo-dom-event/yahoo-dom-event.js"), { type => 'text/javascript' } );

    # TODO: Add query toggling back

    return super();
};


#-------------------------------------------------------------------

=head2 download ( )

Returns the SQLReport in the configured manner. Returns nothing if download is
not enabled.

=cut

sub download {
	my $self	= shift;
	
	# Instead of going through some costly exercises...
	return undef if ($self->downloadType eq "none");
	
        # Initiate an empty debug loop
        $self->{_debug_loop} = [] ;
	
	# Store queries in class
	$self->_storeQueries();
	
	# If we're downloading CSV
	if ($self->downloadType eq "csv") {
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
    elsif ($self->downloadType eq "template") { 
        my $data	= $self->_processQuery(1,0);
        my $output  = $self->processTemplate($data,$self->downloadTemplateId);
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
    my $template = WebGUI::Asset::Template->newById($self->session, $self->templateId);
    if (!$template) {
        WebGUI::Error::ObjectNotFound::Template->throw(
            error      => qq{Template not found},
            templateId => $self->templateId,
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

override purgeCache => sub {
	my $self = shift;
	$self->session->cache->remove("view_".$self->getId);
	super();
};

#-------------------------------------------------------------------

=head2 view ( )

See WebGUI::Asset::view() for details.  This method also performs content caching
if the user is not in Admin Mode.

=cut

sub view {
	my $self = shift;
    my $cache = $self->session->cache;
    my $cacheKey = $self->getWwwCacheKey( 'view' );
    if (!$self->session->var->isAdminOn && $self->cacheTimeout > 10) {
        my $out = eval{ $cache->get( $cacheKey ) };
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
	if ($self->downloadType ne "none" 
		&& $self->session->user->isInGroup($self->downloadUserGroup)
	) {
	    $var->{'canDownload'} = 1;
        $var->{'downloadLink'} = $self->_getDownloadLink($self);
    }
	
       	my $out = $self->processTemplate($var,undef,$self->{_viewTemplate});
    if (!$self->session->var->isAdminOn && $self->cacheTimeout > 10) {
        eval { $cache->set( $cacheKey, $out, $self->cacheTimeout ) };
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
			foreach (split(/\n/, $self->get('prequeryStatements' .$nr))) {
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
			my $paginateAfter = ($page == 1) ? $self->paginateAfter : 99999999;
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
	return undef if $self->downloadType eq "none";
	
	# Only allow users in appropriate group
	return $self->session->privilege->noAccess() 
		unless $self->session->user->isInGroup($self->downloadUserGroup);
	
	# Set filename and mimetype
	if ($self->downloadType eq "csv") {
		$self->session->http->setFilename($self->downloadFilename,"application/octet-stream");
	}
	else {
		$self->session->http->setFilename($self->downloadFilename, $self->downloadMimeType);
	}
	
	$self->session->http->sendHeader;
	
	
	return $self->download;
}



#-------------------------------------------------------------------

=head2 www_view ( )

See WebGUI::Asset::Wobject::www_view() for details.

=cut

override www_view => sub {
	my $self = shift;
	$self->session->http->setCacheControl($self->cacheTimeout);
	super();
};

__PACKAGE__->meta->make_immutable;
1;

