package WebGUI::Asset::Wobject::IndexedSearch::Search;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2004 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use DBIx::FullTextSearch;
use WebGUI::SQL;
use WebGUI::HTML;
use WebGUI::Grouping;
use DBIx::FullTextSearch::StopList;
use WebGUI::Utility;
use HTML::Highlight;
use WebGUI::Macro;

=head1 NAME

Package WebGUI::Wobject::IndexedSearch::Search

=head1 DESCRIPTION

Search implementation for WebGUI. 

=head1 SYNOPSIS

 use WebGUI::Wobject::IndexedSearch::Search;
 my $search = WebGUI::Wobject::IndexedSearch::Search->new();
 $search->indexDocument( { text => 'Index this text',
				  location => 'http://www.mysite.com/index.pl/faq#45',
				  languageId => 3,
				  namespace => 'FAQ'
				});
 my $hits = search->search("+foo -bar koo",{ namespace = ['Article', 'FAQ']} );
 
 $search->close;
			   

=head1 SEE ALSO

This package is an extension to DBIx::FullTextSearch and HTML::Highlight. 
See that packages for documentation of their methods.

=head1 METHODS

These methods are available from this package:

=cut

#-------------------------------------------------------------------
sub _recurseCrumbTrail {
        my ($sth, %data, $output);
        tie %data, 'Tie::CPHash';
        %data = $self->session->db->quickHash("select asset.assetId,asset.parentId,assetData.menuTitle,asset.url from asset left join assetData on asset.assetId=assetData.assetId where asset.assetId=".$self->session->db->quote($_[0])." group by assetData.assetId order by assetData.revisionDate desc");
        if ($data{assetId}) {
                $output .= _recurseCrumbTrail($data{parentId});
        }
        if ($data{assetId} ne "PBasset000000000000001" && $data{menuTitle}) {
                $output .= '<a class="crumbTrail" href="'.$self->session->url->gateway($data{url})
                        .'">'.$data{menuTitle}.'</a> &gt; ';
        }
        return $output;
}

#-------------------------------------------------------------------

=head2 close ( )

Closes the DBIx::FullTextSearch session.

=cut

sub close {
	my $self=shift;
	$self->DESTROY();
}

#-------------------------------------------------------------------

=head2 create ( [ %options ] )

Creates a new DBIx::FullTextSearch index. 

=head3 %options

Options to pass to DBIx::FullTextSearch. 
The default options that are used are:

( backend => column, word_length => 20, stoplist => undef )

Please refer to the DBIx::FullTextSearch documentation for a complete list of options.

=cut

sub create {
	my ($self, %options) = @_;
	%options = (%{$self->{_createOptions}}, %options);
	if($options{stemmer}) {
		eval "use Lingua::Stem";
		if ($@) {
			$self->session->errorHandler->warn("IndexedSearch: Can't use stemmer: $@");
			delete $options{stemmer};
		}
	}
	if($options{stoplist}) {
		if(not $self->existsTable($self->getIndexName."_".$options{stoplist}."_stoplist")) {
			DBIx::FullTextSearch::StopList->create_default($self->getDbh, $self->getIndexName."_".$options{stoplist}, $options{stoplist});
		}
		$options{stoplist} = $self->getIndexName."_".$options{stoplist};
	}		
	$self->{_fts} = DBIx::FullTextSearch->create($self->getDbh, $self->getIndexName, %options);
	if (not defined $self->{_fts}) {
		$self->session->errorHandler->error("IndexedSearch: Unable to create index.\n$DBIx::FullTextSearch::errstr");
		return undef;
	}
	$self->{_docId} = 1;
	return $self->{_fts};
}

#-------------------------------------------------------------------

=head2 existsTable ( tableName )

Returns true if tableName exists in database.

=head3 tableName

The name of table.

=cut

sub existsTable {
        my ($self, $table) = @_;
	return isIn($table, $self->session->db->buildArray("show tables"));
}

#-------------------------------------------------------------------

=head2 getDetails ( docIdList , [ %options ] )

Returns an array reference containing details for each docId.

=head3 docIdList

An array reference containing docIds.

=head3 previewLength

The maximum number of characters in each of the context sections. Defaults to "80".

=head3 highlight

A boolean indicating whether or not to enable highlight. Defaults to "1".

=head3 highlightColors

A reference to an array of CSS color identificators.

=cut

sub getDetails {
	my ($self, $docIdList, %options) = @_;
	my $docIds = $self->session->db->quoteAndJoin($docIdList);
	my (@searchDetails);
	my $sql = "select * from IndexedSearch_docInfo where docId in ($docIds) and indexName = ".$self->session->db->quote($self->getIndexName) ; 
	$sql .= " ORDER BY FIELD(docId, $docIds)";  # Maintain $docIdList order
	my $sth = $self->session->db->read($sql);
	while (my %data = $sth->hash) {
		if ($data{ownerId}) {
			($data{username}) = $self->session->db->quickArray("select username from users where userId = ".$self->session->db->quote($data{ownerId}));
			$data{userProfile} = $self->session->url->page("op=viewProfile&uid=$data{ownerId}");
		}
		if ($data{bodyShortcut} =~ /^\s*select /i) {
			$data{body} = ($self->session->db->quickArray($data{bodyShortcut}))[0];
		} else {
			$data{body} = $data{bodyShortcut};
		}
		if ($data{headerShortcut} =~ /^\s*select /i) {
			$data{header} = ($self->session->db->quickArray($data{headerShortcut}))[0];
		} else {
			$data{header} = $data{headerShortcut};
		}
		delete($data{bodyShortcut});
		delete($data{headerShortcut});
		if($data{body}) {
			$data{body} = WebGUI::Macro::filter($data{body});
			$data{body} = WebGUI::HTML::filter($data{body},'all');		
			$data{body} = $self->preview($data{body}, $options{previewLength});
			$data{body} = $self->highlight($data{body},undef, $options{highlightColors}) if ($options{highlight});
		}
		if($data{header}) {
			$data{header} = WebGUI::Macro::filter($data{header});
			$data{header} = WebGUI::HTML::filter($data{header},'all');
			$data{header} = $self->highlight($data{header},undef, $options{highlightColors}) if ($options{highlight});
			$data{location} = $self->session->url->gateway($data{location});
		}
		$data{crumbTrail} = _recurseCrumbTrail($data{assetId});
		$data{crumbTrail} =~ s/\s*\&gt;\s*$//;
		push(@searchDetails, \%data);
	}
	$sth->finish;
	return \@searchDetails;	
}

#-------------------------------------------------------------------

=head2 getDbh ( )

Returns the object's database handler.

=cut

sub getDbh {
	my $self = shift;
	return $self->{_dbh};
}

#-------------------------------------------------------------------

=head2 getDocId ( )

Returns the next docId for this object.

=cut

sub getDocId {
	my $self=shift;
	return $self->{_docId};
}

#-------------------------------------------------------------------

=head2 getIndexName ( )

Returns the full index name of this object.

=cut

sub getIndexName {
	my $self = shift;
	return $self->{_indexName};
}

#-------------------------------------------------------------------

=head2 _queryToWords ( [ query ] )

Converts a DBIx::FullTextSearch query to (\@Words, \@Wildcards) suitable to pass to HTML::Highlight

=cut

sub _queryToWords {
	my ($self, $query) = @_;
	my $query ||= $self->{_query};

	# Return the processed words / wildcards from memory if it's cached.
	if ($self->{$query."words"} && $self->{$query."wildcards"}) {
		return ($self->{$query."words"}, $self->{$query."wildcards"});
	}

	# deal with quotes
	my $inQuote=0;
	my (@words, @wildcards);
	foreach (split(/\"/, $query)) {
		if($inQuote == 0) {
			foreach (split(/\s+/, $_)) {
				next if (/^AND$/i);	# boolean AND
				next if (/^OR$/i);	# boolean OR
				next if (/^NOT$/i);	# boolean OR
				next if (/^\-/);		# exclude word
				next if (/^.{0,1}$/);	# at least 2 characters
				if (/\*/) {
					push(@wildcards, '%'); # match any character
				} else {
					push(@wildcards, '*'); # Also match plural of word
				}
				s/['"()+*]+//g;		# remove query operators and quotes 
				push(@words, $_);
			}
		} else {
			my $phrase = $_;
			push(@words, qq/$phrase/);
			push(@wildcards, undef);	# Exact match
		}
		$inQuote = ++$inQuote % 2;
	}
	# Store words / wildcards in memory
	$self->{$query."words"} = \@words;
	$self->{$query."wildcards"} = \@wildcards;

	return (\@words, \@wildcards);
}

#-------------------------------------------------------------------

=head2 highlight ( text [ , query , colors ] )

highlight words or patterns in HTML documents.

=head3 text

The text to highlight

=head3 query

A query containing the words to highlight. Defaults to the last used $search->search query.
Special case: When query contains only an asterisk '*', no highlighting is applied.

=head3 colors

A reference to an array of CSS color identificators.
 
=cut

sub highlight {
	my ($self, $text, $query, $colors) = @_;
	my $query ||= $self->{_query};
	return $text if ($query =~ /^\s*\*\s*$/); # query = '*', no highlight
	my ($words, $wildcards) = $self->_queryToWords($query);
	my $hl = new HTML::Highlight ( 	words => $words, 
					wildcards => $wildcards,
					colors => $colors
						);
	return $hl->highlight($text);
} 

#-------------------------------------------------------------------

=head2 indexDocument ( hashRef )

Adds a document to the index.

This method doesn't store the document itself. Instead, it stores information about words 
in the document in such a structured way that it makes easy and fast to look up what 
documents contain certain words and return id's of the documents.

=head3 text

The text to index.

=head3 location

The location of the document. Most likely an URL.

=head3 contentType

The content type of this document. 

=head3 docId

The unique Id of this document. Defaults to the next empty docId.

=head3 assetId

The assetId of the asset that holds this content. Defaults to NULL.

=head3 ownerId

The ownerId of the document. Defaults to 3.

=head3 namespace

The namespace of this document. Defaults to 'WebGUI'.

=head3 groupIdView

Id of group authorized to view this content. Defaults to '7' (everyone)

=head3 special_groupIdView

Id of group authorized to view the details of this content. 

=head3 headerShortcut

An sql statement that returns the header (title, question, subject, name, whatever)
of this document.

=head3 bodyShortcut

An sql statement that returns the body (description, answer, message, whatever)
of this document.

=cut

sub indexDocument {
	my ($self, $document) = @_;
	$self->{_fts}->index_document($document->{docId} || $self->{_docId}, $document->{text});
	my $docId = ($document->{docId} || $self->{_docId});
	$self->session->db->write("insert into IndexedSearch_docInfo (			docId, 
										indexName,
										assetId,
										groupIdView,
										special_groupIdView,
										namespace, 
										location,
										headerShortcut,
										bodyShortcut,
										contentType,
										ownerId,
										dateIndexed  ) 
                                      values (	".
							$self->session->db->quote($docId).", ". 
							$self->session->db->quote($self->getIndexName).", ".
							$self->session->db->quote($document->{assetId}).", ". 
							$self->session->db->quote($document->{groupIdView} || "7").", ". 
							$self->session->db->quote($document->{special_groupIdView} || "7").", ". 
							$self->session->db->quote($document->{namespace} || 'WebGUI')." , ".
							$self->session->db->quote($document->{location}).", ".
							$self->session->db->quote($document->{headerShortcut})." ,".
							$self->session->db->quote($document->{bodyShortcut})." ,".
							$self->session->db->quote($document->{contentType})." ,".
							$self->session->db->quote($document->{ownerId} || 3).",
							".$self->session->datetime->time()." )"
				);
	$self->{_docId}++;
}

#-------------------------------------------------------------------

=head2 new ( [ indexName , dbh ] )

Constructor.

=head3 indexName

The name of the index to open. Defaults to 'default'.

=head3 $dbh

Database handler to use. Defaults to $WebGUI::Session::session{dbh}.

=cut

sub new {
	my ($class, $indexName, $dbh) = @_;
	$indexName = $indexName || 'default';
	my $self = { _indexName => $indexName,
			 _dbh => $dbh || $WebGUI::Session::session{dbh},
			 _createOptions => {( backend => 'column', 
						    word_length => 20,
						    filter => 'map { lc $_ if ($_ !~ /\^.*;/) }' 
						  )},
			};
	bless $self, $class;
}

#-------------------------------------------------------------------

=head2 open ( )

Opens an existing DBIx::FullTextSearch index.

=cut

sub open {
	my ($self) = @_;
	$self->{_fts} = DBIx::FullTextSearch->open($self->getDbh, $self->getIndexName);
	if (not defined $self->{_fts}) {
		$self->session->errorHandler->error("IndexedSearch: Unable to open index.\n$DBIx::FullTextSearch::errstr");
		return undef;
	}
	($self->{_docId}) = $self->session->db->quickArray("select max(docId) from IndexedSearch_docInfo where indexName = ".$self->session->db->quote($self->getIndexName)); 
	$self->{_docId}++;
	return $self->{_fts};
}

#-------------------------------------------------------------------

=head2 preview ( text , [ previewLength , query ] )

Returns a context preview in which words from a search query appear in the resulting documents. 
The words are always in the middle of each of the sections.

=head3 text

The text to preview

=head3 previewLength

The maximum number of characters in each of the context sections. Defaults to 80.
A preview length of "0" means no preview, 
while a negative preview length returns the complete text.

=head3 query

A query containing the words to highlight. Defaults to the last used $search->search query.

=cut

sub preview {
	my ($self, $text, $previewLength, $query) = @_;
	$previewLength = 80 if (not defined $previewLength);
	return '' unless ($previewLength);
	return $text if ($previewLength < 0);
	my $query ||= $self->{_query};
	if(($query =~ /^\s*\*\s*$/) or not $query) {	# Query is '*' or empty. 
		$text = WebGUI::HTML::filter($text,'all');
		$text =~ s/^(.{1,$previewLength})\s+.*$/$1/s;
	} else {
		my ($words, $wildcards) = $self->_queryToWords($query);
		my $hl = new HTML::Highlight ( 	words => $words, 
								wildcards => $wildcards
							);
		my $preview = join('... ',@{$hl->preview_context($text, $previewLength)});
		if ($preview) {
			$text = $preview;
		} else {
			$text = WebGUI::HTML::filter($text,'all');
			$text =~ s/^(.{1,$previewLength})\s+.*$/$1/s;
		}
	}
	$text =~ s/^(\s|&nbsp;)+//;
	$text =~ s/(\s|&nbsp;)+$//;
	if($text ne '') {
		$text = '<STRONG>... </STRONG>'.$text if ($text !~ /^[A-Z]+/); # ... broken up at the beginning
		$text .='<STRONG> ...</STRONG>' if ($text !~ /\.$/); # broken up at the end ...
	}
	return $text;
} 

#-------------------------------------------------------------------

=head2 recreate ( [ %options ] )

Like create, but first drops the existing index. Useful when rebuilding the index.

=head3 %options

Options to pass to WebGUI::IndexedSearch->create() 

=cut

sub recreate {
	my ($self, %options) = @_;
	$self->{_fts} = DBIx::FullTextSearch->open($self->getDbh, $self->getIndexName);
	if (defined $self->{_fts}) {
		$self->{_fts}->drop;
	}
	$self->{_fts} = $self->create($self->getIndexName, $self->getDbh, %options);
	$self->session->db->write("delete from IndexedSearch_docInfo where indexName = ".$self->session->db->quote($self->getIndexName));
	return $self->{_fts};
}

#-------------------------------------------------------------------

=head2 search ( query, \%filter )

Returns an array reference of docId's of documents that match the query. 
If the search has no results, undef is returned.

=head3 query

user input string. Will be parsed into can-include, must-include and must-not-include words and phrases.
Special case: when query is an asterisk (*), then no full text search is done, and results are returned
using \%filter.

Examples are: 
		+"this is a phrase" -koo +bar foo
		(foo OR baz) AND (bar OR caz)

=head3 filter

A hash reference containing filter elements.

Example:
        {
                language => [ 1, 3 ],
                namespace => [ 'Article', 'USS' ]
        }

=cut

sub search {
	my ($self, $query, $filter) = @_;
	$self->{_query} = $query;
	my $noFtsSearch = ($query =~ /^\s*\*\s*$/); # query = '*', no full text search
	my @fts_docIds = $self->{_fts}->search($query) unless $noFtsSearch ;
	if(@fts_docIds || $noFtsSearch) {
		my $groups = $self->session->db->quoteAndJoin($self->_getGroups);
		my $docIds = $self->session->db->quoteAndJoin(\@fts_docIds);
		my $sql = "select docId from IndexedSearch_docInfo where indexName = ".$self->session->db->quote($self->getIndexName);
		$sql .= " and docId in ($docIds)" unless $noFtsSearch;
		$sql .= " and groupIdView in ($groups)";
		$sql .= " and special_groupIdView in ($groups)";
		foreach my $filterElement (keys %{$filter}) {
			$sql .= " AND $filterElement in (".$self->session->db->quoteAndJoin($filter->{$filterElement}).")";
		}
		# Keep @fts_docIds list order
		$sql .= " ORDER BY FIELD(docID,$docIds)" unless $noFtsSearch;
		my $filteredDocIds = $self->session->db->buildArrayRef($sql);
		return $filteredDocIds if (ref $filteredDocIds eq 'ARRAY' and @{$filteredDocIds});
	}
	return undef;
}

#-------------------------------------------------------------------

=head2 _getGroups ( )

Returns an array reference containing all groupIds of groups the user is in.

=cut

sub _getGroups {
	my @groups;
	foreach my $groupId ($self->session->db->buildArray("select groupId from groups")) {
		push(@groups, $groupId) if ($self->session->user->isInGroup($groupId));
	}
	return \@groups;
}

#-------------------------------------------------------------------
sub DESTROY {
	my $self=shift;
	if (ref($self->{_fts})) {
		$self->{_fts}->DESTROY();
	}
}

1;
