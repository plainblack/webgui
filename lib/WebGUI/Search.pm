package WebGUI::Search;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use Carp qw( croak );
use WebGUI::Asset;
use WebGUI::Pluggable;

=head1 NAME

Package WebGUI::Search

=head1 DESCRIPTION

A package for creating queries with the WebGUI Search Engine.

=head1 SYNOPSIS

 use WebGUI::Search;

=head1 METHODS

These methods are available from this package:

=cut

#----------------------------------------------------------------------------

=head2 _isStopword ( word ) 

Returns true if the given word is in the stopword list.

=cut

sub _isStopword {
    my $self    = shift;
    my $word    = lc shift;
    $word       =~ s/[^A-Za-z']//g;
    my $stopwords   = q{
        a's able about above according accordingly across actually after 
        afterwards again against ain't all allow allows almost alone 
        along already also although always am among amongst an and another 
        any anybody anyhow anyone anything anyway anyways anywhere apart 
        appear appreciate appropriate are aren't around as aside ask asking 
        associated at available away awfully be became because become 
        becomes becoming been before beforehand behind being believe below beside besides best better between beyond both brief but by c'mon c's came can can't cannot cant cause causes certain certainly changes clearly co com come comes concerning consequently consider considering contain containing contains corresponding could couldn't course currently definitely described despite did didn't different do does doesn't doing don't done down downwards during each edu eg eight either else elsewhere enough entirely especially et etc even ever every everybody everyone everything everywhere ex exactly example except far few fifth first five followed following follows for former formerly forth four from further furthermore get gets getting given gives go goes going gone got gotten greetings had hadn't happens hardly has hasn't have haven't having he he's hello help hence her here here's hereafter hereby herein hereupon hers herself hi him himself his hither hopefully how howbeit however i'd i'll i'm i've ie if ignored immediate in inasmuch inc indeed indicate indicated indicates inner insofar instead into inward is isn't it it'd it'll it's its itself just keep keeps kept know knows known last lately later latter latterly least less lest let let's like liked likely little look looking looks ltd mainly many may maybe me mean meanwhile merely might more moreover most mostly much must my myself name namely nd near nearly necessary need needs neither never nevertheless new next nine no nobody non none noone nor normally not nothing novel now nowhere obviously of off often oh ok okay old on once one ones only onto or other others otherwise ought our ours ourselves out outside over overall own particular particularly per perhaps placed please plus possible presumably probably provides que quite qv rather rd re really reasonably regarding regardless regards relatively respectively right said same saw say saying says second secondly see seeing seem seemed seeming seems seen self selves sensible sent serious seriously seven several shall she should shouldn't since six so some somebody somehow someone something sometime sometimes somewhat somewhere soon sorry specified specify specifying still sub such sup sure t's take taken tell tends th than thank thanks thanx that that's thats the their theirs them themselves then thence there there's thereafter thereby therefore therein theres thereupon these they they'd they'll they're they've think third this thorough thoroughly those though three through throughout thru thus to together too took toward towards tried tries truly try trying twice two un under unfortunately unless unlikely until unto up upon us use used useful uses using usually value various very via viz vs want wants was wasn't way we we'd we'll we're we've welcome well went were weren't what what's whatever when whence whenever where where's whereafter whereas whereby wherein whereupon wherever whether which while whither who who's whoever whole whom whose why will willing wish with within without won't wonder would would wouldn't yes yet you you'd you'll you're you've your yours yourself yourselves zero
    };

    return 1 if $stopwords =~ /\b$word\b/xms;
}


#-------------------------------------------------------------------

=head2 _getQuery ( columnsToSelect )

This is a private method and should never be used outside of this class.

=cut

sub _getQuery { 
	my $self = shift;
	my $selectsRef = shift;
	return ('select ' 
		. join(', ', @$selectsRef,   ($self->{_score} ? $self->{_score} : ())) 
		. ' from assetIndex '
		. ($self->{_join} ? join(" ",@{$self->{_join}}) : '') # JOIN
		. ' where ' 
		. ($self->{_isPublic}? 'isPublic = 1 and ' : '') 
		. '('.$self->{_where}.')' 
		. ($self->{_score} ? ' order by score desc' : '')
		);
}


#-------------------------------------------------------------------

=head2 getAssetIds ( )

Returns an array reference containing all the asset ids of the assets that matched.

=cut

sub getAssetIds {
	my $self = shift;
	my $query = $self->_getQuery(['assetIndex.assetId']);
	my $rs = $self->session->db->prepare($query);
	$rs->execute($self->{_params});
	my @ids = ();
	while (my ($id) = $rs->array) {
		push(@ids, $id);		
	}
	return \@ids;
}


#-------------------------------------------------------------------

=head2 getAssets ( )

Returns an array reference containing asset objects for those that matched.

=cut

sub getAssets {
	my $self = shift;
	my $query = $self->_getQuery([qw(assetIndex.assetId assetIndex.className assetIndex.revisionDate)]);
	my $rs = $self->session->db->prepare($query);
	$rs->execute($self->{_params});
	my @assets = ();
	while (my ($id, $class, $version) = $rs->array) {
		my $asset = WebGUI::Asset->new($self->session, $id, $class, $version);
		unless (defined $asset) {
			$self->session->errorHandler->warn("Search index contains assetId $id even though it no longer exists.");
			next;
		}
		push(@assets, $asset);		
	}
	return \@assets;
}


#-------------------------------------------------------------------

=head2 getPaginatorResultSet ( currentURL, paginateAfter, pageNumber, formVar )

Returns a paginator object containing the search result set data.

=head3 currentURL

The URL of the current page including attributes. The page number will be appended to this in all links generated by the paginator.

=head3 paginateAfter

The number of rows to display per page. If left blank it defaults to 50.

=head3 pageNumber 

By default the page number will be determined by looking at $self->session->form->process("pn"). If that is empty the page number will be defaulted to "1". If you'd like to override the page number specify it here.

=head3 formVar

Specify the form variable the paginator should use in it's links.  Defaults to "pn".

=cut

sub getPaginatorResultSet {
	my $self = shift;
	my $url = shift;
	my $paginate = shift;
	my $pageNumber = shift;
	my $formVar = shift;
	my @columns	= qw(	assetIndex.assetId 
				assetIndex.title 
				assetIndex.url 
				assetIndex.synopsis 
				assetIndex.ownerUserId 
				assetIndex.groupIdView 
				assetIndex.groupIdEdit 
				assetIndex.creationDate 
				assetIndex.revisionDate 
				assetIndex.className
			);
	
	push @columns, (@{$self->{_columns}})
		if $self->{_columns};
	
	my $query = $self->_getQuery(\@columns);
	my $paginator = WebGUI::Paginator->new($self->session, $url, $paginate, $formVar, $pageNumber);
	$paginator->setDataByQuery($query, undef, undef, $self->{_params});
	return $paginator;
}

#-------------------------------------------------------------------

=head2 getResultSet ( ) 

Returns a WebGUI::SQL::ResultSet object containing the search results with 
columns labeled "assetId", "title", "url", "synopsis", "ownerUserId", 
"groupIdView", "groupIdEdit", "creationDate", "revisionDate", and "className", 
in addition to any columns passed as rules.

=cut

sub getResultSet {
	my $self 	= shift;
	my @columns	= qw(	assetIndex.assetId 
				assetIndex.title 
				assetIndex.url 
				assetIndex.synopsis 
				assetIndex.ownerUserId 
				assetIndex.groupIdView 
				assetIndex.groupIdEdit 
				assetIndex.creationDate 
				assetIndex.revisionDate 
				assetIndex.className
			);
	
	push @columns, (@{$self->{_columns}})
		if $self->{_columns};
	
	my $query 	= $self->_getQuery(\@columns);
	my $rs = $self->session->db->prepare($query);
	$rs->execute($self->{_params});
	return $rs;
}



#-------------------------------------------------------------------

=head2 new ( session  [ , isPublic ] )

Constructor.  Each search object can handle doing 1 search.  Performing multiple searches
will accumulate internal data and cause errors due to number of placeholder mismatches.

=head3 session

A reference to the current session.

=head3 isPublic

A boolean indicating whether this search should search all internal data (0), or just public data (1). Defaults to just public data (1).

=cut

sub new {
	my $class = shift;
	my $session = shift;
	my $isPublic = (shift eq "0") ? 0 : 1;
	bless {_session=>$session, _isPublic=>$isPublic}, $class;
}



#-------------------------------------------------------------------

=head2 rawClause ( sql [, placeholders ] ) 

Tells the search engine to use a custom sql where clause that you've designed for the assetIndex table instead of using the API to build it. It also returns a reference to the object so you can join a result method with it like this:

 my $assetIds = WebGUI::Search->new($session)->rawQuery($sql, $params)->getAssetIds;

=head3 sql

The where clause to execute. It should not actually contain the "where" term itself. 

=head3 placeholders

A list of placeholder parameters to go along with the query. See WebGUI::SQL::ResultSet::execute() for details.

=cut

sub rawClause {
	my $self = shift;
	$self->{_where} = shift;
	$self->{_params} = shift;
	return $self;
}

#-------------------------------------------------------------------

=head2 search ( rules ) 

A rules engine for WebGUI's search system. It also returns a reference to the search object so that you can join a result method with it like:

 my $assetIds = WebGUI::Search->new($session)->search(\%rules)->getAssetIds;

=head3 rules

A hash reference containing rules for a search. The rules will will be hash references containing the values of a rule. Here's an example rule set:

 { keywords => "something to search for", lineage => [ "000001000005", "000001000074000003" ] };

All rules, except for assetIds, are logically AND'ed together to create a finer search.  assetIds are OR'ed to the final
query.

=head4 keywords

This rule limits the search results to assets that match keyword criteria.

 keywords => "foo bar"

=head4 lineage

This rule limits the search to a specific set of descendants in the asset tree. An array reference of asset lineages to match against.

 lineage => [ "000001000003", "000001000024000005" ]

=head4 assetIds

This rule limits the search to a specific set of assetIds. An array reference of assetIds to match against.

 assetIds => [ "PBasset000000000000001", ]

Unlike every other rule, this rule is logically OR'ed with the other rules.

=head4 classes

This rule limits the search to a specific set of asset classes. An array reference of class names.

 classes => [ "WebGUI::Asset::Wobject::Article", "WebGUI::Asset::Snippet" ]

=head4 creationDate

This rule limits the search to a creation date range. It has two parameters: "start" and "end". Start and end represent the start and end dates to search in, which are represented as epoch dates. If start is not specified, it is infinity into the past. If end date is not specified, it is infinity into the future.

 creationDate => {
       start=>1110011,
       end=>30300003
    }

=head4 revisionDate

This rule limits the search to a revision date range. It has two parameters: "start" and "end". Start and end represent the start and end dates to search in, which are represented as epoch dates. If start is not specified, it is infinity into the past. If end date is not specified, it is infinity into the future.

 revisionDate => {
       start=>1110011,
       end=>30300003
    }

=head4 where

This rule adds an additional where clause to the search. 

 where => 'className NOT LIKE "WebGUI::Asset::Wobject%"'

=head4 joinClass

This is an array reference of asset classes.  Each asset class will be queried via its
definition method to see what tables should be joined to the assetData table.  Only the
most recent revisions of data will be added to the search.

=head4 join

This rule allows for an array reference of table join clauses.

 join => 'join assetData on assetId = assetData.assetId'

NOTE: This rule is deprecated and will be removed in a future release. Use 
joinClass instead.

=head4 columns

This rule allows for additional columns to be returned by getResultSet().

 columns => ['assetData.title','assetData.description']

TODO: 'where' and 'join' were added hackishly. It'd be nicer to see a data 
structure for 'join', and the ability to have multiple 'where' clauses with
placeholders and parameters.

=cut

sub search {
	my $self = shift;
	my $rules = shift;

        # Send the rules through some sanity checks
        croak "'lineage' rule must be array reference"
            if ( $rules->{lineage} && ref $rules->{lineage} ne "ARRAY" );

	my @params;
        my @orParams;
	my $query = "";
	my @clauses;
        my @orClauses;
    if ($rules->{keywords}) {
        my $keywords = $rules->{keywords};
        # do wildcards for people like they'd expect unless they are doing it themselves
        unless ($keywords =~ m/"|\*/) {
            # split into 'words'.  Ideographic characters (such as Chinese) are
            # treated as distinct words.  Everything else is space delimited.
            my @terms = grep { $_ ne q{} } split /\s+|(\p{Ideographic})/, $keywords;
            for my $term (@terms) {
                # we add padding to ideographic characters to avoid minimum word length limits on indexing
                if ($term =~ /\p{Ideographic}/) {
                    $term = q{''}.$term.q{''};
                }
                $term .= q{*};
                next
                    if $self->_isStopword($term);
                next
                    if $term =~ /^[+-]/;
                $term = q{+} . $term;
            }
            $keywords = join q{ }, @terms;
        }
		push(@params, $keywords, $keywords);
		$self->{_score} = "match (keywords) against (?) as score";
		push(@clauses, "match (keywords) against (? in boolean mode)");
	}
	if ($rules->{lineage}) {
		my @phrases = ();
		foreach my $lineage (@{$rules->{lineage}}) {
			next unless defined $lineage;
			push(@params, $lineage."%");
			push(@phrases, "lineage like ?");
		}
		push(@clauses, join(" or ", @phrases)) if (scalar(@phrases));
	}
	if ($rules->{assetIds}) {
		my @phrases = ();
		foreach my $assetId (@{$rules->{assetIds}}) {
			next unless $assetId;
			push(@orParams, $assetId);
                        push(@phrases, "assetId like ?");
                }
		push(@orClauses, join(" or ", @phrases)) if (scalar(@phrases));
	}
	if ($rules->{classes}) {
		my @phrases = ();
		foreach my $class (@{$rules->{classes}}) {
			next unless $class;
			push(@params, $class);
			push(@phrases, "className=?");
		}
		push(@clauses, join(" or ", @phrases)) if (scalar(@phrases));
	}
	if ($rules->{creationDate}) {
		my $start = $rules->{creationDate}{start} || 0;
		my $end = $rules->{creationDate}{end} || "9223372036854775807";
		push(@clauses, "creationDate between ? and ?");
		push(@params, $start, $end);
	}
	if ($rules->{revisionDate}) {
		my $start = $rules->{revisionDate}{start} || 0;
		my $end = $rules->{revisionDate}{end} || "9223372036854775807";
		push(@clauses, "revisionDate between ? and ?");
		push(@params, $start, $end);
	}
	if ($rules->{where}) {
		push(@clauses, $rules->{where});
	}
	# deal with custom joined tables if we must
	if (exists $rules->{joinClass}) {
            my $join        = [ "left join assetData on assetIndex.assetId=assetData.assetId" ];
            for my $className ( @{ $rules->{ joinClass } } ) {
                if ( ! eval { WebGUI::Pluggable::load($className) } ) {
                    $self->session->errorHandler->fatal($@);
                }
                foreach my $definition (@{$className->definition($self->session)}) {
                    unless ($definition->{tableName} eq "asset") {
                        my $tableName = $definition->{tableName};
                        push @$join, 
                            "left join $tableName on assetData.assetId=".$tableName.".assetId and assetData.revisionDate=".$tableName.".revisionDate";
                    }
                    last;
                }
            }
            # Get only the latest revision
            push @clauses, "assetData.revisionDate = (SELECT MAX(revisionDate) FROM assetData ad WHERE ad.assetId = assetData.assetId)";
            # Join happens in _getQuery
            $self->{_join} = $join;
	}
        elsif ($rules->{join}) {	# This join happens in _getQuery
            $rules->{join} = [$rules->{join}]
                unless (ref $rules->{join} eq "ARRAY");
            $self->{_join} = $rules->{join};
	}
	if ($rules->{columns}) {
		$rules->{columns} = [$rules->{columns}]
			unless (ref $rules->{columns} eq "ARRAY");
		$self->{_columns} = $rules->{columns};
	}

	push @{$self->{_params}}, @params;
	push @{$self->{_params}}, @orParams;

        if (@clauses) {
            $self->{_where} .= "(".join(") and (", @clauses).")";
        }
        if (@orClauses) {
            if (length( $self->{_where} )) {
                $self->{_where} .= ' or ';
            }
            $self->{_where} .= "(".join(") or (", @orClauses).")";
        }
	return $self;
}


#-------------------------------------------------------------------

=head2 session ( ) 

Returns a reference to the current session.

=cut

sub session {
	my $self = shift;
	return $self->{_session};
}



1;

