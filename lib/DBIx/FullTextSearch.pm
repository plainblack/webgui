# -*- Mode: Perl; indent-tabs-mode: t; tab-width: 2 -*-

=head1 NAME

DBIx::FullTextSearch - Indexing documents with MySQL as storage

=cut

package DBIx::FullTextSearch;
use strict;
use Parse::RecDescent;

use vars qw($errstr $VERSION $parse);
$errstr = undef;
$VERSION = '0.73';

use locale;

my %DEFAULT_PARAMS = (
	'num_of_docs' => 0,	# statistical value, should be maintained
	'word_length' => 30,	# max length of words we index

	'protocol' => 40,	# we only support protocol with the same numbers

	'blob_direct_fetch' => 20,	# with the blob store, when we stop searching
				# and fetch everything at once
	'data_table' => undef,	# table where the actual index is stored
	'name_length' => 255,	# for filenames or URLs, what's the max length

	'word_id_bits' => 16,	# num of bits for word_id (column store)
	'doc_id_bits' => 16,	# num of bits for doc_id
	'count_bits' => 8,	# num of bits for count value
	'position_bits' => 32,	# num of bits for word positions

	'backend' => 'blob',	# what database backend (way the data is
				# stored) we use
	'frontend' => 'none',	# what application frontend we use (how
				# the index behaves externaly)
	'filter' => 'map { lc $_ }',
	'search_splitter' => '/(\w{2,$word_length}\*?)/g',
	'index_splitter' => '/(\w{2,$word_length})/g',
				# can use the $word_length
				# variable
	'init_env' => ''
	);
my %backend_types = (
	'blob' => 'DBIx::FullTextSearch::Blob',
	'blobfast' => 'DBIx::FullTextSearch::BlobFast',
	'column' => 'DBIx::FullTextSearch::Column',
	'phrase' => 'DBIx::FullTextSearch::Phrase',
	);
my %frontend_types = (
	'none' => 'DBIx::FullTextSearch',
	'default' => 'DBIx::FullTextSearch',
	'file' => 'DBIx::FullTextSearch::File',
	'string' => 'DBIx::FullTextSearch::String',
	'url' => 'DBIx::FullTextSearch::URL',
	'table' => 'DBIx::FullTextSearch::Table',
	);

use vars qw! %BITS_TO_PACK %BITS_TO_INT %INT_TO_BITS !;
%BITS_TO_PACK = qw! 0 A0 8 C 16 S 32 L !;
%BITS_TO_INT = qw! 8 tinyint 16 smallint 24 mediumint 32 int 64 bigint !;
%INT_TO_BITS = map { ($BITS_TO_INT{$_} => $_ ) }keys %BITS_TO_INT;

# Open reads in the information about existing index, creates an object
# in memory
sub open {
	my ($class, $dbh, $TABLE) = @_;
	$errstr = undef;

	# the $dbh is either a real dbh of a DBI->connect parameters arrayref
	my $mydbh = 0;
	if (ref $dbh eq 'ARRAY') {
		if (not $dbh = DBI->connect(@$dbh)) {
			$errstr = $DBI::errstr; return;
		}
    
		$mydbh = 1;
	}

	# load the parameters to the object
	my %PARAMS = %DEFAULT_PARAMS;
	my $sth = $dbh->prepare("select * from $TABLE");
	$sth->{'PrintError'} = 0;
	$sth->{'RaiseError'} = 0;
	$sth->execute or do {
		if (not grep { $TABLE eq $_ }
			DBIx::FullTextSearch->list_fts_indexes($dbh)) {
			$errstr = "FullTextSearch index $TABLE doesn't exist.";
		} else {
			$errstr = $sth->errstr;
		}
		return;
	};
	while (my ($param, $value) = $sth->fetchrow_array) {
		$PARAMS{$param} = $value;
	}
  
	my $self = bless {
		    'dbh' => $dbh,
		    'table' => $TABLE,
		    %PARAMS,
		   }, $class;
	my $data_table = $self->{'data_table'};

	# we should disconnect if we've opened the dbh here
	if ($mydbh) { $self->{'disconnect_on_destroy'} = 1; }

	# some basic sanity check
	if (not defined $dbh->selectrow_array("select count(*) from $data_table")) {
		$errstr = "Table $data_table not found in the database\n";
		return;
	}


	# load and set the application frontend
	my $front_module = $frontend_types{$PARAMS{'frontend'}};
	if (defined $front_module) {
		if ($front_module ne $class) {
			eval "use $front_module";
			die $@ if $@;
		}
		bless $self, $front_module;
		$self->_open_tables;
	}
	else {
		$errstr = "Specified frontend type `$PARAMS{'frontend'}' is unknown\n"; return;
	}

	# load and set the backend (actual database access) module
	my $back_module = $backend_types{$PARAMS{'backend'}};
	if (defined $back_module) {
		eval "use $back_module";
		die $@ if $@;
		$self->{'db_backend'} = $back_module->open($self);
	}
	else {
		$errstr = "Specified backend type `$PARAMS{'backend'}' is unknown\n"; return;
	}

	# load DBIx::FullTextSearch::StopList object (if specified)
	if ($PARAMS{'stoplist'}) {
		eval "use DBIx::FullTextSearch::StopList";
		die $@ if $@;
		$self->{'stoplist'} = DBIx::FullTextSearch::StopList->open($dbh, $PARAMS{'stoplist'});
	}

	# load Lingua::Stem object (if specified)
	if($PARAMS{'stemmer'}){
		eval "use Lingua::Stem";
		die $@ if $@;
		$self->{'stemmer'} = Lingua::Stem->new(-locale => $PARAMS{'stemmer'});
	}

	# finally, return the object
	$self;
}

# Create creates tables in the database according to the options, then
# calls open to load the object to memory
sub create {
	my ($class, $dbh, $TABLE, %OPTIONS) = @_;
	$errstr = undef;
	my $mydbh = 0;
	if (ref $dbh eq 'ARRAY') {
		$dbh = DBI->connect(@$dbh)
			or do { $errstr = $DBI::errstr; return; };
		$mydbh = 1;
	}

	my $self = bless {
		'dbh' => $dbh,
		'table' => $TABLE,
		%DEFAULT_PARAMS,
		%OPTIONS
		}, $class;

	$self->{'data_table'} = $TABLE.'_data'
				unless defined $self->{'data_table'};

	# convert array reference to CSV string
	$self->{'column_name'} = join(",",@{$self->{'column_name'}}) if ref($self->{'column_name'}) eq 'ARRAY';

	my $CREATE_PARAM = <<EOF;
		create table $TABLE (
			param varchar(16) binary not null,
			value varchar(255),
			primary key (param)
			)
EOF
	$dbh->do($CREATE_PARAM) or do { $errstr = $dbh->errstr; return; };
	push @{$self->{'created_tables'}}, $TABLE;

	# load and set the frontend database structures
	my $front_module = $frontend_types{$self->{'frontend'}};
	if (defined $front_module) {
		eval "use $front_module";
		die $@ if $@;
		bless $self, $front_module;
		$errstr = $self->_create_tables;
		if (defined $errstr) {
			$self->clean_failed_create; warn $errstr; return;
		}
	}
	else {
		$errstr = "Specified frontend type `$self->{'frontend'}' is unknown\n"; $self->clean_failed_create; return;
	}
  
	# create the backend database structures
	my $back_module = $backend_types{$self->{'backend'}};
	if (defined $back_module) {
		eval "use $back_module";
		die $@ if $@;
		$errstr = $back_module->_create_tables($self);
		if (defined $errstr) {
			$self->clean_failed_create; warn $errstr; return;
		}
	}
	else {
		$errstr = "Specified backend type `$self->{'backend'}' is unknown\n"; $self->clean_failed_create; return;
	}
  
	for (grep { not ref $self->{$_} } keys %$self) {
		$dbh->do("insert into $TABLE values (?, ?)", {}, $_, $self->{$_});
	}
  
	return $class->open($dbh, $TABLE);
}

sub _create_tables {}
sub _open_tables {}

sub clean_failed_create {
	my $self = shift;
	my $dbh = $self->{'dbh'};
	for my $table (@{$self->{'created_tables'}}) {
		$dbh->do("drop table $table");
	}
}

sub drop {
	my $self = shift;
	my $dbh = $self->{'dbh'};
	for my $tag (keys %$self) {
		next unless $tag =~ /(^|_)table$/;
		$dbh->do("drop table $self->{$tag}");
	}
	1;
}

sub empty {
	my $self = shift;
	my $dbh = $self->{'dbh'};

	for my $tag (keys %$self) {
		next unless $tag =~ /_table$/;
		$dbh->do("delete from $self->{$tag}");
	}
	$dbh->do("replace into $self->{'table'} values ('max_doc_id', 0)");
	return 1;
}

sub errstr {
	my $self = shift;
	ref $self ? $self->{'errstr'} : $errstr;
}

sub list_fts_indexes {
	my ($class, $dbh) = @_;
	my %tables = map { ( $_->[0] => 1 ) }
	@{$dbh->selectall_arrayref('show tables')};
	my %indexes = ();
	for my $table (keys %tables) {
		local $dbh->{'PrintError'} = 0;
		local $dbh->{'RaiseError'} = 0;
		if ($dbh->selectrow_array("select param, value from $table
				where param = 'data_table'")) {
			$indexes{$table} = 1;
		}
	}
	return sort keys %indexes;
}

sub index_document {
	my ($self, $id, $data) = @_;
	return unless defined $id;

	my $dbh = $self->{'dbh'};

	my $param_table = $self->{'table'};

	my $adding_doc = 0;

	my $adding = 0;
	if (not defined $self->{'max_doc_id'} or $id > $self->{'max_doc_id'}) {
		$self->{'max_doc_id'} = $id;
		my $update_max_doc_id_sth =
			( defined $self->{'update_max_doc_id_sth'}
			? $self->{'update_max_doc_id_sth'}
			: $self->{'update_max_doc_id_sth'} = $dbh->prepare("replace into $param_table values (?, ?)"));
		$update_max_doc_id_sth->execute('max_doc_id', $id);
		$adding_doc = 1;
	}
  
	my $init_env = $self->{'init_env'};	# use packages, etc.
	eval $init_env if defined $init_env;
	print STDERR "Init_env failed with $@\n" if $@;

	$data = '' unless defined $data;
	return $self->{'db_backend'}->parse_and_index_data($adding_doc,
						     $id, $data);
}

# used for backends that need a count for each of the words
sub parse_and_index_data_count {
	my ($backend, $adding_doc, $id, $data) = @_;
	## note that this is run with backend object
	my $self = $backend->{'fts'};

	my $word_length = $self->{'word_length'};
	# this needs to get parametrized (lc, il2_to_ascii, parsing of
	# HTML tags, ...)

	my %words;
  my @data_sets = ref $data ? @$data : ($data);

	# We can just join the data sets together, since we don't care about position
  my $data_string = join(" ", @data_sets);

	my $filter = $self->{'filter'} . ' $data_string =~ ' . $self->{'index_splitter'};
	my $stoplist = $self->{'stoplist'};
	my $stemmer = $self->{'stemmer'};
	my @words = eval $filter;
	@words = grep !$stoplist->is_stop_word($_), @words if defined($stoplist);
	@words = @{$stemmer->stem(@words)} if defined($stemmer);
	for my $word ( @words ) {
		$words{$word} = 0 if not defined $words{$word};
		$words{$word}++;
	}

	my @result;
	if ($adding_doc) {
		@result = $backend->add_document($id, \%words);
	} else {
		@result = $backend->update_document($id, \%words);
	}

	if (wantarray) {
		return @result;
	}
	return $result[0];
}

# used for backends where list of occurencies is needed
sub parse_and_index_data_list {
	my ($backend, $adding_doc, $id, $data) = @_;
	## note that this is run with backend object
	my $self = $backend->{'fts'};

	my $word_length = $self->{'word_length'};
	# this needs to get parametrized (lc, il2_to_ascii, parsing of
	# HTML tags, ...)

	my %words;
  my @data_sets = ref $data ? @$data : ($data);

  foreach my $data_set (@data_sets) {
		my $filter = $self->{'filter'}.' $data_set =~ '.$self->{'index_splitter'};

		my $i = 0; # $i stores the position(s) of each word in the document.
	my $stoplist = $self->{'stoplist'};
	my $stemmer = $self->{'stemmer'};
	my @words = eval $filter;
	@words = grep !$stoplist->is_stop_word($_), @words if defined($stoplist);
	@words = @{$stemmer->stem(@words)} if defined($stemmer);
	for my $word ( @words ) {
		push @{$words{$word}}, ++$i;
	} 
		# Make sure the data sets are considered far apart in position, to
    # avoid phrase searches overlapping between table columns.
    $i += 100;
	}

	my @result;
	if ($adding_doc) {
		@result = $backend->add_document($id, \%words);
	} else {
		@result = $backend->update_document($id, \%words);
	}

	if (wantarray) {
		return @result;
	}
	return $result[0];
}

sub delete_document {
	my $self = shift;
	$self->{'db_backend'}->delete_document(@_);
}

sub contains_hashref {
	my $self = shift;
	my $word_length = $self->{'word_length'};
	my $stemmer = $self->{'stemmer'};
	my $filter = $self->{'filter'};
	my $stoplist = $self->{'stoplist'};
	my @phrases;
	for (@_){
		my $phrase;
		my $splitter = ' map { ' . $self->{'search_splitter'} . ' } $_';
		my @words = eval $splitter;
		@words = eval $filter.' @words';
		@words = grep !$stoplist->is_stop_word($_), @words if defined($stoplist);
		if (defined($stemmer)){
			my @stemmed_words = ();
			for (@words){
				if (m/\*$/){
					# wildcard search, make work with stemming
					my $stem_word = $stemmer->stem($_);
					for (@$stem_word){
						$_ .= "*";
						push @stemmed_words, $_;
					}
				} else {
					push @stemmed_words, @{$stemmer->stem($_)};
				}
			}
			$phrase = join(' ',@stemmed_words);
		} else {
			$phrase = join(' ',@words);
		}
		# change wildcard to SQL version (* -> %)
		$phrase =~ s/\*/%/g;
		push @phrases, $phrase;
	}
	$self->{'db_backend'}->contains_hashref(@phrases);
}

sub contains {
	my $self = shift;
	my $res = $self->contains_hashref(@_);
	if (not $self->{'count_bits'}) { return keys %$res; }
	return sort { $res->{$b} <=> $res->{$a} } keys %$res;
}

sub econtains_hashref {
	my $self = shift;
	my $docs = {};
	my $word_num = 0;
  
	my $stoplist = $self->{'stoplist'};
  
	my @plus_words = map { /^\+(.+)$/s } @_;
	@plus_words = grep !$stoplist->is_stop_word($_), @plus_words if defined($stoplist);
  
	# required words
	for my $word (@plus_words) {
		$word_num++;
		my $oneword = $self->contains_hashref($word);
		if ($word_num == 1) { $docs = $oneword; next; }
		for my $doc (keys %$oneword) {
			$docs->{$doc} += $oneword->{$doc} if defined $docs->{$doc};
		}
		for my $doc (keys %$docs) {
			delete $docs->{$doc} unless defined $oneword->{$doc};
		}
	}
  
	# optional words
	for my $word ( map { /^([^+-].*)$/s } @_) {
		my $oneword = $self->contains_hashref($word);
		for my $doc (keys %$oneword) {
			if (@plus_words) {
				$docs->{$doc} += $oneword->{$doc} if defined $docs->{$doc};
			}
			else {
				$docs->{$doc} = 0 unless defined $docs->{$doc};
				$docs->{$doc} += $oneword->{$doc};
			}
		}
	}
  
	# prohibited words
	for my $word ( map { /^-(.+)$/s } @_) {
		my $oneword = $self->contains_hashref($word);
		for my $doc (keys %$oneword) {
			delete $docs->{$doc};
		}
	}
	$docs;
}

sub econtains {
	my $self = shift;
	my $res = $self->econtains_hashref(@_);
	if (not $self->{'count_bits'}) { return keys %$res; }
	return sort { $res->{$b} <=> $res->{$a} } keys %$res;
}

sub _search_terms {
	my ($self, $query) = @_;
  
	if ($self->{'backend'} eq 'phrase') {
		# phrase backend, must deal with quotes

		# handle + and - operations on phrases
		$query =~ s/([\+\-])"/"$1/g;

		my $inQuote = 0;
		my @phrases = ();

		my @blocks = split(/\"/, $query);

		# deal with quotes
		for (@blocks){
			if($inQuote == 0){
				# we are outside quotes, search for individual words
				push @phrases, split(' ');
			} else {
				# we are inside quote, search for whole phrase
				push @phrases, $_;
			}
			$inQuote = ++$inQuote % 2;
		}
		return @phrases;
	} else
		{
		# not phrase backend, don't deal with quotes
		return split(' ', $query);
	}
}

sub _search_boolean {
	my ($self, $query) = @_;

	unless ($parse) {
		$::RD_AUTOACTION = q{ [@item] };
		my $grammar = q{
        expr    :       disj
        disj    :       conj 'or' disj | conj
        conj    :       unary 'and' conj | unary
        unary   :       '(' expr ')'
                |       atom
        atom    :       /([^\(\)\s]|\s(?!and)(?!or))+/
			};
		$parse = new Parse::RecDescent ($grammar);
	}
	my $tree = $parse->expr($query);
	return $self->_search_in_tree($tree);
}

sub _search_in_tree {
	my ($self, $tree) = @_;

	if (ref($tree->[1]) && ref($tree->[3])) {
		if (defined($tree->[2]) && $tree->[2] eq 'and') {
			my $hash_ref1 = $self->_search_in_tree($tree->[1]);
			my $hash_ref2 = $self->_search_in_tree($tree->[3]);
			for my $k (keys %$hash_ref1) {
				unless ($hash_ref2->{$k}) {
					delete $hash_ref1->{$k};
				} else {
					$hash_ref1->{$k} += $hash_ref2->{$k};
				}
			}
			return $hash_ref1;
		} elsif (defined($tree->[2]) && $tree->[2] eq 'or') {
			my $hash_ref1 = $self->_search_in_tree($tree->[1]);
			my $hash_ref2 = $self->_search_in_tree($tree->[3]);
			for my $k (keys %$hash_ref2) {
				$hash_ref1->{$k} += $hash_ref2->{$k};
			}
			return $hash_ref1;
		}
		return {};
  } elsif ($tree->[1] eq '(' && ref($tree->[2]) && $tree->[3] eq ')') {
		return $self->_search_in_tree($tree->[2]);
	} elsif (ref($tree->[1])) {
		return $self->_search_in_tree($tree->[1]);
	} elsif (defined($tree->[0]) && $tree->[0] eq 'atom') {
		return $self->econtains_hashref($self->_search_terms($tree->[1]));
	} else {
		warn "Unknown tree nodes " . join("\t", @$tree);
		return {};
	}
}

sub search {
	my ($self, $query) = @_;
	if ($query =~ s/\b(and|or|not)\b/lc($1)/eig) {
		return keys %{$self->_search_boolean($query)};
	}
	return $self->econtains($self->_search_terms($query));
}

sub search_hashref {
	my ($self, $query) = @_;
	if ($query =~ s/\b(and|or|not)\b/lc($1)/eig) {
		return $self->_search_boolean($query);
	}
	return $self->econtains_hashref($self->_search_terms($query));
}

sub document_count {
	my $self = shift;
	my $dbh = $self->{'dbh'};

	my $SQL = qq{
		select distinct doc_id from $self->{'data_table'}
	};
	my $ary_ref = $dbh->selectall_arrayref($SQL);
	return scalar @$ary_ref;
}

# find all words that are contained in at least $k % of all documents
sub common_word {
	my $self = shift;
	my $k = shift || 80;
	$self->{'db_backend'}->common_word($k);
}

sub DESTROY {
	my $self = shift;
	$self->{'db_backend'}->DESTROY()
		if (exists $self->{'db_backend'} && $self->{'db_backend'} &&$self->{'db_backend'}->can('DESTROY'));
}

1;

=head1 SYNOPSIS

DBIx::FullTextSearch uses a MySQL database backend to index files, web
documents and database fields.  Supports must include, can include, and cannot
include words and phrases.  Support for boolean (AND/OR) queries, stop words and stemming.

    use DBIx::FullTextSearch;
    use DBI;
    # connect to database (regular DBI)
    my $dbh = DBI->connect('dbi:mysql:database', 'user', 'passwd');

    # create a new stoplist
    my $sl = DBIx::FullTextSearch::StopList->create_default($dbh, 'sl_en', 'English');

    # create a new index with default english stoplist and english stemmer
    my $fts = DBIx::FullTextSearch->create($dbh, 'fts_web_1',
		frontend => 'string', backend => 'blob',
		stoplist => 'sl_en', stemmer => 'en-us');
    # or open existing one
    # my $fts = DBIx::FullTextSearch->open($dbh, 'fts_web_1');

    # index documents
    $fts->index_document('krtek', 'krtek leze pod zemi');
    $fts->index_document('jezek', 'Jezek ma ostre bodliny.');

    # search for matches
    my @docs = $fts->contains('foo');
    my @docs = $fts->econtains('+foo', '-Bar');
    my @docs = $fts->search('+foo -Bar');
    my @docs = $fts->search('foo AND (bar OR baz)');

=head1 DESCRIPTION

DBIx::FullTextSearch is a flexible solution for indexing contents of documents.
It uses the MySQL database to store the information about words and
documents and provides Perl interface for indexing new documents,
making changes and searching for matches.  For DBIx::FullTextSearch, a document
is nearly anything -- Perl scalar, file, Web document, database field.

The basic style of interface is shown above. What you need is a MySQL
database and a L<DBI> with L<DBD::mysql>. Then you create a DBIx::FullTextSearch index
-- a set of tables that maintain all necessary information. Once created
it can be accessed many times, either for updating the index (adding
documents) or searching.

DBIx::FullTextSearch uses one basic table to store parameters of the index. Second
table is used to store the actual information about documents and words,
and depending on the type of the index (specified during index creation)
there may be more tables to store additional information (like
conversion from external string names (eg. URL's) to internal numeric
form). For a user, these internal thingies and internal behaviour of the
index are not important. The important part is the API, the methods to
index document and ask questions about words in documents. However,
certain understanding of how it all works may be usefull when you are
deciding if this module is for you and what type of index will best
suit your needs.

=head2 Frontends

From the user, application point of view, the DBIx::FullTextSearch index stores
documents that are named in a certain way, allows adding new documents,
and provides methods to ask: "give me list of names of documents that
contain this list of words". The DBIx::FullTextSearch index doesn't store the
documents itself. Instead, it stores information about words in the
documents in such a structured way that it makes easy and fast to look
up what documents contain certain words and return names of the
documents.

DBIx::FullTextSearch provides a couple of predefined frontend classes that specify
various types of documents (and the way they relate to their names).

=over 4

=item default

By default, user specifies the integer number of the document and the
content (body) of the document. The code would for example read

	$fts->index_document(53, 'zastavujeme vyplaty vkladu');

and DBIx::FullTextSearch will remember that the document 53 contains three words.
When looking for all documents containing word (string) vklad, a call

	my @docs = $fts->contains('vklad*');

would return numbers of all documents containing words starting with
'vklad', 53 among them.

So here it's user's responsibility to maintain a relation between the
document numbers and their content, to know that a document 53 is about
vklady. Perhaps the documents are already stored somewhere and have
unique numeric id.

Note that the numeric id must be no larger than 2^C<doc_id_bits>.

=item string

Frontend B<string> allows the user to specify the names of the documents as
strings, instead of numbers. Still the user has to specify both the
name of the document and the content:

	$fts->index_document('foobar',
			'the quick brown fox jumped over lazy dog!');

After that,

	$fts->contains('dog')

will return 'foobar' as one of the names of documents with word
'dog' in it.

=item file

To index files, use the frontend B<file>. Here the content of the document
is clearly the content of the file specified by the filename, so in
a call to index_document, only the name is needed -- the content of the
file is read by the DBIx::FullTextSearch transparently:

	$fts->index_document('/usr/doc/FAQ/Linux-FAQ');
	my @files = $fts->contains('penguin');

=item url

Web document can be indexed by the frontend B<url>. DBIx::FullTextSearch uses L<LWP> to
get the document and then parses it normally:

	$fts->index_document('http://www.perl.com/');

Note that the HTML tags themselves are indexed along with the text.

=item table

You can have a DBIx::FullTextSearch index that indexes char or blob fields in MySQL
table. Since MySQL doesn't support triggers, you have to call the
C<index_document> method of DBIx::FullTextSearch any time something changes
in the table. So the sequence probably will be

	$dbh->do('insert into the_table (id, data, other_fields)
		values (?, ?, ?)', {}, $name, $data, $date_or_something);
	$fts->index_document($name);

When calling C<contains>, the id (name) of the record will be returned. If
the id in the_table is numeric, it's directly used as the internal
numeric id, otherwise a string's way of converting the id to numeric
form is used.

When creating this index, you'll have to pass it three additionial options,
C<table_name>, C<column_name>, and C<column_id_name>.  You may use the optional
column_process option to pre-process data in the specified columns.

=back

The structure of DBIx::FullTextSearch is very flexible and adding new frontend
(what will be indexed) is very easy.

=head2 Backends

While frontend specifies what is indexed and how the user sees the
collection of documents, backend is about low level database way of
actually storing the information in the tables. Three types are
available:

=over 4

=item blob

For each word, a blob holding list of all documents containing that word
is stored in the table, with the count (number of occurencies)
associated with each document number. That makes it for very compact
storage. Since the document names (for example URL) are internally
converted to numbers, storing and fetching the data is fast. However,
updating the information is very slow, since information concerning one
document is spread across all table, without any direct database access.
Updating a document (or merely reindexing it) requires update of all
blobs, which is slow.

The list of documents is stored sorted by document name so that
fetching an information about a document for one word is relatively
easy, still a need to update (or at least scan) all records in the table
makes this storage unsuitable for collections of documents that often
change.

=item column

The B<column> backend stores a word/document pair in database fields,
indexing both, thus allowing both fast retrieval and updates -- it's
easy to delete all records describing one document and insert new ones.
However, the database indexes that have to be maintained are large.

Both B<blob> and B<column> backends only store a count -- number of
occurencies of the word in the document (and even this can be switched
off, yielding just a yes/no information about the word's presence).
This allows questions like

	all documents containing words 'voda' or 'Mattoni'
		but not a word 'kyselka'

but you cannot ask whether a document contains a phrase 'kyselka
Mattoni' because such information is not maintained by these types of
backends.

=item phrase

To allow phrase matching, a B<phrase> backend is available. For each word
and document number it stores a blob of lists of positions of the word
in the document. A query

	$fts->contains('kyselk* Mattoni');

then only returns those documents (document names/numbers) where word
kyselka (or kyselky, or so) is just before word Mattoni.

=back

=head2 Mixing frontends and backends

Any frontend can be used with any backend in one DBIx::FullTextSearch index. You
can index Web documents with C<url> frontend and C<phrase> backend
to be able to find phrases in the documents. And you can use the
default, number based document scheme with C<blob> backend to use the disk
space as efficiently as possible -- this is usefull for example for
mailing-list archives, where we need to index huge number of documents
that do not change at all.

Finding optimal combination is very important and may require some
analysis of the document collection and manipulation, as well as the
speed and storage requirements. Benchmarking on actual target platform
is very useful during the design phase.

=head1 METHODS

The following methods are available on the user side as DBIx::FullTextSearch API.

=over 4

=item create

	my $fts = DBIx::FullTextSearch->create($dbh, $index_name, %opts);

The class method C<create> creates index of given name (the name of the
index is the name of its basic parameter table) and all necessary
tables, returns an object -- newly created index. The options that may
be specified after the index name define the frontend and backend types,
storage parameters (how many bits for what values), etc. See below for
list of create options and discussion of their use.

=item open

	my $fts = DBIx::FullTextSearch->open($dbh, $index_name);

Opens and returns object, accessing specifies DBIx::FullTextSearch index. Since all
the index parameters and information are stored in the C<$index_name> table
(including names of all other needed tables), the database handler and
the name of the parameter table are the only needed arguments.

=item index_document

	$fts->index_document(45, 'Sleva pri nakupu stribra.');
	$fts->index_document('http://www.mozilla.org/');
	$fts->index_document('http://www.mozilla.org/','This is the mozilla web site');

For the C<default> and C<string> frontends, two arguments are expected -- the
name (number or string) of the document and its content. For C<file>,
C<url>, and C<table> frontends the content is optional.  Any content that you pass
will be appended to the content from the file, URL, or database table.

=item delete_document

	$fts->delete_document('http://www.mozilla.org/');

Removes information about document from the index. Note that for C<blob>
backend this is very time consuming process.

=item contains

	my @docs = $fts->contains('sleva', 'strib*');

Returns list of names (numbers or strings, depending on the frontend)
of documents that contain some of specified words.

=item econtains

	my @docs = $fts->contains('foo', '+bar*', '-koo');

Econtains stands for extended contains and allows words to be prefixed
by plus or minus signs to specify that the word must or mustn't be
present in the document for it to match.

=item search

 my @docs = $fts->search(qq{+"this is a phrase" -koo +bar foo});
 my @docs = $fts->search("(foo OR baz) AND (bar OR caz)");

This is a wrapper to econtains which takes a user input string and parses
it into can-include, must-include, and must-not-include words and phrases.
It also can handle boolean (AND/OR) queries.

=item contains_hashref, econtains_hashref, search_hashref

Similar to C<contains>, C<econtains> and C<search>,
only instead of list of document
names, these methods return a hash reference to a hash where keys are
the document names and values are the number of occurencies of the
words.

=item drop

Removes all tables associated with the index, including the base
parameter table. Effectivelly destroying the index form the database.

 $fts->drop;

=item empty

Emptys the index so you can reindex the data.

 $fts->empty;

=back

=head1 INDEX OPTIONS

Here we list the options that may be passed to C<create> method.
These allow to specify the style and storage parameters in great detail.

=over 4

=item backend

The backend type, default C<blob>, possible values C<blob>, C<column> and C<phrase>
(see above for explanation).

=item frontend

The frontend type. The C<default> frontend requires the user to specify
numeric id of the document together with the content of the document,
other possible values are C<string>, C<file> and C<url> (see above for
more info).

=item word_length

Maximum length of words that may be indexed, default 30.

=item data_table

Name of the table where the actual data about word/document relation is
stored. By default, the name of the index (of the base table) with _data
suffix is used.

=item name_length

Any frontend that uses strings as names of documents needs to maintain
a conversion table from these names to internal integer ids. This value
specifies maximum length of these string names (URLs, file names, ...).

=item blob_direct_fetch

Only for C<blob> backend. When looking for information about specific
document in the list stored in the blob, the blob backend uses division
of interval to find the correct place in the blob. When the interval
gets equal or shorter that this value, all values are fetched from the
database and the final search is done in Perl code sequentially.

=item word_id_bits

With C<column> or C<phase> backends, DBIx::FullTextSearch maintains a numeric id for each
word to optimize the space requirements. The word_id_bits parameter
specifies the number of bits to reserve for this conversion and thus
effectively limits number of distinct words that may be indexed. The
default is 16 bits and possible values are 8, 16, 24 or 32 bits.

=item word_id_table

Name of the table that holds conversion from words to their numeric id
(for C<column> and C<phrase> backends). By default is the name of the index
with _words suffix.

=item doc_id_bits

A number of bits to hold a numeric id of the document (that is either
provided by the user (with C<default> frontend) or generated by the module
to accomplish the conversion from the string name of the document). This
value limits the maximum number of documents to hold. The default is 16
bits and possible values are 8, 16 and 32 bits for C<blob> backend and 8,
16, 24 and 32 bits for C<column> and C<phrase> backends.

=item doc_id_table

Name of the table that holds conversion from string names of documents
to their numeric id, by default the name of the index with _docid
suffix.

=item count_bits

Number of bits reserved for storing number of occurencies of each word
in the document. The default is 8 and possible values are the same as
with doc_id_bits.

=item position_bits

With C<phrase backend>, DBIx::FullTextSearch stores positions of each word of the
documents. This value specifies how much space should be reserved for
this purpose. The default is 32 bits and possible values are 8, 16 or 32
bits. This value limits the maximum number of words of each document
that can be stored.

=item index_splitter

DBIx::FullTextSearch allows the user to provide any Perl code that will be used to
split the content of the document to words when indexing documents. 
The code will be evalled inside of the DBIx::FullTextSearch code. The default is

	/(\w{2,$word_length})/g

and shows that the input is stored in the variable C<$data> and the code
may access any other variable available in the perl_and_index_data_*
methods (see source), especially C<$word_length> to get the maximum length
of words and C<$backend> to get the backend object.

The default value also shows that by default, the minimum length of
words indexed is 2.

=item search_splitter

This is similar to the C<index_splitter> method,
except that it is used in the C<contains_hashref> method 
when searching for documents instead of when indexing documents.  The default is

       /(\w{2,$word_length}\*?)/g

Which, unlike the default C<index_splitter>, allows for the wild card character (*).

=item filter

The output words of splitter (and also any parameter of (e)contains*
methods) are send to filter that may do further processing. Filter is
again a Perl code, the default is

	map { lc $_ }

showing that the filter operates on input list and by default does
conversion to lowercase (yielding case insensitive index).

=item init_env

Because user defined splitter or filter may depend on other things that
it is reasonable to set before the actual procession of words, you can
use yet another Perl hook to set things up. The default is no initialization
hook.

=item stoplist

This is the name of a L<DBIx::FullTextSearch::StopList> object that is used
for stop words.

=item stemmer

If this option is set, then word stemming will be enabled in the indexing and searching.

The value is the name of a L<Lingua::Stem> recognized locale.
Currently, 'en', 'en-us' and 'en-uk' are the only recognized locales.
All locale identifiers are converted to lowercase. 

=item table_name

For C<table> frontend; this is the name of the table that will be indexed.

=item column_name

For C<table> frontend; this is a reference to an array of columns in the
C<table_name> that contains the documents -- data to be indexed. It can
also have a form table.column that will be used if the C<table_name>
option is not specified.

=item column_id_name

For C<table> frontend; this is the name of the field in C<table_name> that
holds names (ids) of the records. If not specified, a field that has
primary key on it is used. If this field is numeric, it's values are
directly used as identifiers, otherwise a conversion to numeric values
is made.

=back

=head1 NOTES

To handle internationalization, it may help to use the following in your code
(for example Spanish in Chile):

  use POSIX;
  my $loc = POSIX::setlocale( &POSIX::LC_ALL, "es_CL" );

I haven't tested this, so I would be interested in hearing whether this
works.

=head1 ERROR HANDLING

The create and open methods return the DBIx::FullTextSearch object on success, upon
failure they return undef and set error message in C<$DBIx::FullTextSearch::errstr>
variable.

All other methods return reasonable (documented above) value on success,
failure is signalized by unreasonable (typically undef or null) return
value; the error message may then be retrieved by C<$fts-E<gt>errstr> method
call.

=head1 VERSION

This documentation describes DBIx::FullTextSearch module version 0.73.

=head1 BUGS

Error handling needs more polishing.

We do not check if the stored values are larger that specified by the
*_bits parameters.

No CGI administration tool at the moment.

No scoring algorithm implemented.

=head1 DEVELOPMENT

These modules are under active development.
If you would like to contribute, please e-mail tjmather@maxmind.com

There are two mailing lists for this module, one for users, and another for developers.  To subscribe,
visit http://sourceforge.net/mail/?group_id=8645

=head1 AUTHOR

(Original) Jan Pazdziora, adelton@fi.muni.cz,
http://www.fi.muni.cz/~adelton/ at Faculty of Informatics, Masaryk University in Brno, Czech
Republic

(Current Maintainer) T.J. Mather, tjmather@maxmind.com,
http://www.maxmind.com/app/opensourceservices Princeton, NJ USA

Paid support is available from directly from the maintainers of this package.
Please see L<http://www.maxmind.com/app/opensourceservices> for more details.

=head1 CREDITS

Fixes, Bug Reports, Docs have been generously provided by:

  Vladimir Bogdanov
  Ade Olonoh
  Kate Pugh
  Sven Paulus
  Andrew Turner
  Tom Bille
  Joern Reder
  Tarik Alkasab
  Dan Collis Puro
  Tony Bowden
  Mario Minati
  Miroslav Suchý
  Stephen Patterson
  Joern Reder
  Hans Poo

Of course, big thanks to Jan Pazdziora, the original author of this
module.  Especially for providing a clean, modular code base!

=head1 COPYRIGHT

All rights reserved. This package is free software; you can
redistribute it and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

L<DBIx::FullTextSearch::StopWord>,
L<Class::DBI::mysql::FullTextSearch>

=head1 OTHER PRODUCTS and why I've written this module

I'm aware of L<DBIx::TextIndex> and L<DBIx::KwIndex>
modules and about UdmSearch utility, and
about htdig and glimpse on the non-database side of the world.

To me, using a database gives reasonable maintenance benefits. With
products that use their own files to store the information (even if the
storage algorithms are efficient and well thought of), you always
struggle with permissions on files and directories for various users,
with files that somebody accidently deleted or mungled, and making the
index available remotely is not trivial.

That's why I've wanted a module that will use a database as a storage
backend. With MySQL, you get remote access and access control for free,
and on many web servers MySQL is part of the standard equipment. So
using it for text indexes seemed natural.

However, existing L<DBIx::TextIndex> and UdmSearch are too narrow-aimed to
me. The first only supports indexing of data that is stored in the
database, but you may not always want or need to store the documents in
the database as well. The UdmSearch on the other hand is only for web
documents, making it unsuitable for indexing mailing-list archives or
local data.

I believe that DBIx::FullTextSearch is reasonably flexible and still very
efficient. It doesn't enforce its own idea of what is good for you --
the number of options is big and you can always extend the module with
your own backend of frontend if you feel that those provided are not
sufficient. Or you can extend existing by adding one or two parameters
that will add new features. Of course, patches are always welcome.
DBIx::FullTextSearch is a tool that can be deployed in many projects. It's not
a complete environment since different people have different needs. On
the other hand, the methods that it provides make it easy to build
a complete solution on top of this in very short course of time.

=cut

