package DBIx::FullTextSearch::Phrase;
use strict;
use DBIx::FullTextSearch::Column;
use vars qw! @ISA !;
@ISA = qw! DBIx::FullTextSearch::Column !;

# Open in the backend just sets the object
sub open {
	my ($class, $fts) = @_;
	return bless { 'fts' => $fts }, $class;
}

sub DESTROY {
  my ($self) = @_;
  if (defined $self->{'select_wordid_sth'}) {
	$self->{'select_wordid_sth'}->finish();
  }
}


# Create creates the table(s) according to the parameters
sub _create_tables {
	my ($class, $fts) = @_;
	my $COUNT_FIELD = '';

	my $CREATE_DATA = <<EOF;
		create table $fts->{'data_table'} (
			word_id $DBIx::FullTextSearch::BITS_TO_INT{$fts->{'word_id_bits'}} unsigned not null,
			doc_id $DBIx::FullTextSearch::BITS_TO_INT{$fts->{'doc_id_bits'}} unsigned not null,
			idx longblob default '' not null,
			index (word_id),
			index (doc_id)
		)
EOF

	$fts->{'word_id_table'} = $fts->{'table'}.'_words'
				unless defined $fts->{'word_id_table'};
	
	
	my $CREATE_WORD_ID = <<EOF;
		create table if not exists $fts->{'word_id_table'} (
			word varchar($fts->{'word_length'}) binary
				default '' not null,
			id $DBIx::FullTextSearch::BITS_TO_INT{$fts->{'word_id_bits'}} unsigned not null auto_increment,
			primary key (id),
			unique (word)
			)
EOF

	my $dbh = $fts->{'dbh'};
	$dbh->do($CREATE_DATA) or return $dbh->errstr;
	push @{$fts->{'created_tables'}}, $fts->{'data_table'};
	$dbh->do($CREATE_WORD_ID) or return $dbh->errstr;
	push @{$fts->{'created_tables'}}, $fts->{'word_id_table'};
	return;
}

sub add_document {
  my ($self, $id, $words) = @_;
  # here the value in the %$words hash is an array of word
  # positions
  my $fts = $self->{'fts'};
  my $dbh = $fts->{'dbh'};
  my $word_id_table = $fts->{'word_id_table'};
  if (not defined $self->{'select_wordid_sth'}) {
    $self->{'select_wordid_sth'} = $dbh->prepare("
       select id from $word_id_table where word = ?
       ");
  }
  my $data_table = $fts->{'data_table'};
  my $packstring = $DBIx::FullTextSearch::BITS_TO_PACK{$fts->{'position_bits'}};
  my $num_words = 0;
  my (@wids,@data,@widshandler,@datahandler);
  my $wordid;
  $dbh->do("lock tables $word_id_table write");
  my ($maxid) = $dbh->selectrow_array("select max(id) 
                                       from $word_id_table");
  foreach my $word (keys %$words) {
    if(!defined $self->{'wordids'}->{$word}) {
      $self->{'select_wordid_sth'}->execute($word);
      ($wordid) = $self->{'select_wordid_sth'}->fetchrow_array();
      unless ($wordid) { 
	$maxid++;
	push @widshandler, "(?,$maxid)";
	push @wids, $word;
	$wordid = $maxid;
      }
      $self->{'wordids'}->{$word} = $wordid;
    } else {
      $wordid=$self->{'wordids'}->{$word};
    }
    push @datahandler, "($wordid,$id,?)";
    push @data, pack $packstring.'*', @{$words->{$word}};
    $num_words++;
  };
  $dbh->do("insert into $word_id_table values " . 
	   join (',',@widshandler),undef,@wids) if @wids;
  $dbh->do("unlock tables");
  $dbh->do("insert into $data_table values " . 
	   join (',',@datahandler),undef,@data) if @data;
  return $num_words;
}

sub update_document {
	my ($self, $id, $words) = @_;
	my $fts = $self->{'fts'};
	my $dbh = $fts->{'dbh'};
	my $data_table = $fts->{'data_table'};
	$dbh->do("delete from $data_table where doc_id = ?", {}, $id);

	$self->add_document($id, $words);
}

sub contains_hashref {
	my $self = shift;
	my $fts = $self->{'fts'};
	my $dbh = $fts->{'dbh'};
	my $data_table = $fts->{'data_table'};
	my $word_id_table = $fts->{'word_id_table'};

	my $packstring = $DBIx::FullTextSearch::BITS_TO_PACK{$fts->{'position_bits'}};

	my $SQL = qq{
		select doc_id, idx
		from $data_table, $word_id_table
		where word like ?
			and id = word_id
};
	my $out = {};

	for my $phrase (@_){

		my @words = split(' ', $phrase);

		my @sths;
		for (my $i = 0; $i < @words; $i++) {
			$sths[$i] = $dbh->prepare($SQL);
			$sths[$i]->execute($words[$i]);
		}

		my %prev_pos = ();
		my %cur_pos = ();

		# iterate through words in phrase
		for (my $i = 0; $i < @words; $i++){
			if($i > 0){
				%prev_pos = %cur_pos;
				%cur_pos = ();
			}
			# get docs that have this word
			while (my ($doc, $data) = $sths[$i]->fetchrow_array){
				# get positions of words in doc
				my @positions = unpack $packstring.'*', $data;
				map { $cur_pos{$doc}->{$_} = 1 } @positions;
			}
			if($i > 0){
				# check to see if word $i comes after word $i-1
				for my $doc (keys %cur_pos){
					my $isPhrase = 0;
					for my $position (keys %{$cur_pos{$doc}}){
						if ($position > 0 && exists $prev_pos{$doc}{$position - 1}){
							$isPhrase = 1;
						} else { 
							delete $cur_pos{$doc}{$position};
						}
					}
					delete $cur_pos{$doc} unless $isPhrase;
				}
			}
		}

		for my $doc (keys %cur_pos){
			my @positions = keys %{$cur_pos{$doc}};
			$out->{$doc} += scalar (@positions);
		}
	}
	return $out;
}

*parse_and_index_data = \&DBIx::FullTextSearch::parse_and_index_data_list;

1;
