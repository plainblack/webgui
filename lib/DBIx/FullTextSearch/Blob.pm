
package DBIx::FullTextSearch::Blob;
use strict;

# Open in the backend just sets the object
sub open {
	my ($class, $fts) = @_;
	return bless { 'fts' => $fts }, $class;
}
# Create creates the table(s) according to the parameters
sub _create_tables {
	my ($class, $fts) = @_;
	my $CREATE_DATA = <<EOF;
		create table $fts->{'data_table'} (
			word varchar($fts->{'word_length'}) binary
					default '' not null,
			idx longblob default '' not null,
			primary key (word)
		)
EOF
        my $dbh = $fts->{'dbh'};
	$dbh->do($CREATE_DATA) or return $dbh->errstr;
        push @{$fts->{'created_tables'}}, $fts->{'data_table'};
	return;
}

sub add_document {
	my ($self, $id, $words) = @_;
	my $fts = $self->{'fts'};
	my $dbh = $fts->{'dbh'};
	my $data_table = $fts->{'data_table'};

	my $update_sth = ( defined $self->{'adding_update_sth'}
		? $self->{'adding_update_sth'}
		: $self->{'adding_update_sth'} = $dbh->prepare(
			"update $data_table set idx = concat(idx, ?)
				where word = ?") );

	my @insert_values;

	my $packstring = $DBIx::FullTextSearch::BITS_TO_PACK{$fts->{'doc_id_bits'}}
		. $DBIx::FullTextSearch::BITS_TO_PACK{$fts->{'count_bits'}};
	my $num_words = 0;
	for my $word ( keys %$words ) {
### print STDERR "$word($id) adding\n";
		# here we will want to parametrize the bit size of the
		# data
		my $value = pack $packstring, $id, $words->{$word};
		my $rows = $update_sth->execute($value, $word);
		push @insert_values, $word, $value if $rows == 0;
		$num_words += $words->{$word};
	}

	if(@insert_values){
		my $sql_str = "insert into $data_table values ". join(',', ('(?, ?)') x (@insert_values/2));
		$dbh->do($sql_str,{},@insert_values);
	}

	return $num_words;
}

sub delete_document {
	my $self = shift;
	for my $id (@_) { $self->update_document($id, {}); }
}

sub update_document {
	my ($self, $id, $words) = @_;
	my $fts = $self->{'fts'};
	my $dbh = $fts->{'dbh'};
	my $data_table = $fts->{'data_table'};

	my $insert_sth = ( defined $self->{'insert_sth'}
		? $self->{'insert_sth'}
		: $self->{'insert_sth'} = $dbh->prepare("
			insert into $data_table values (?, ?)") );

        my $update_sth = ( defined $self->{'update_update_sth'}
		? $self->{'update_update_sth'}
		: $self->{'update_update_sth'} =
			$dbh->prepare("update $data_table set idx =
			concat(substring(idx, 1, ?), ?, substring(idx, ?))
					where word = ?") );


	my @insert_values;

	$dbh->do("lock tables $data_table write");

	my $select_sth = $dbh->prepare("select word from $data_table");
	$select_sth->execute;

	my $packstring = $DBIx::FullTextSearch::BITS_TO_PACK{$fts->{'doc_id_bits'}}
		. $DBIx::FullTextSearch::BITS_TO_PACK{$fts->{'count_bits'}};
	my ($packnulls) = pack $packstring, 0, 0;
	my $packlength = length $packnulls;
	my $num_words = 0;
	while (my ($word) = $select_sth->fetchrow_array) {
		my $value = (defined $words->{$word} ?
				pack($packstring, $id, $words->{$word}) : '');

		# the method find_position finds the position of the
		# "record" for document $id with word $word; returned is
		# the position in bytes and yes/no values specifying if
		# the record is already present in the blob; if it is,
		# we need to replace it, otherwise just insert.

		my ($pos, $shift) = $self->find_position($word, $id);
		if (not defined $pos) {
			push @insert_values, $word, $value;
		}
		else {
			my $spos = $pos + 1;	# I'm not sure why this
			$spos += $packlength if $shift;
			$update_sth->execute($pos, $value, $spos, $word);	
		}
		delete $words->{$word};	
		$num_words++ if defined $value;
	}

	for my $word ( keys %$words ) {
		my $value = pack $packstring, $id, $words->{$word};
		push @insert_values, $word, $value;
#		$insert_sth->execute($word, $value);
		$num_words++;
	}

	if(@insert_values){
		my $sql_str = "insert into $data_table values ". join(',', ('(?, ?)') x (@insert_values/2));
		$dbh->do($sql_str,{},@insert_values);
	}

	$dbh->do("unlock tables");

	return $num_words;
}

sub find_position {
	my ($self, $word, $id) = @_;
	# here, with the calculation of where in the blob we have the
	# docid and where the count of words and how long they are, we
	# should really look at the parameters (num of bits of various
	# structures and values) given to create

	my $fts = $self->{'fts'};
	my $dbh = $fts->{'dbh'};
	my $data_table = $fts->{'data_table'};

	# Sth to read the length of the blob holding the document/count info
	my $get_length_sth = ( defined $self->{'get_length_sth'}
		? $self->{'get_length_sth'}
		: $self->{'get_length_sth'} = $dbh->prepare("select
			length(idx) from $data_table where word = ?"));
	my $length = $dbh->selectrow_array($get_length_sth, {}, $word);

	my $packstring = $DBIx::FullTextSearch::BITS_TO_PACK{$fts->{'doc_id_bits'}}
		. $DBIx::FullTextSearch::BITS_TO_PACK{$fts->{'count_bits'}};
	my ($packnulls) = pack $packstring, 0, 0;
	my $packlength = length $packnulls;

	if (not defined $length) { return; }
	$length = int($length/$packlength);
	
	my ($bot, $top, $med, $val) = (0, $length);

	if (not defined $fts->{'max_doc_id'})
		{ $med = int(($top - $bot) / 2); }
	else
		{ $med = int($top * $id / $fts->{'max_doc_id'}); }

	my $blob_direct_fetch = $fts->{'blob_direct_fetch'};
	# we divide the interval
	while ($bot != $top) {
		$med = $top - 1 if $med >= $top;
		$med = $bot if $med < $bot;

		if ($top - $bot <= $blob_direct_fetch) {
			my $get_interval_sth = (
				defined $self->{'get_interval_sth'}
				? $self->{'get_interval_sth'}
				: $self->{'get_interval_sth'} = $dbh->prepare("select substring(idx,?,?) from $data_table where word = ?"));
			my $alldata = $dbh->selectrow_array($get_interval_sth,
				{},
				$bot * $packlength + 1,
				($top - $bot) * $packlength,
				$word);
			return unless defined $alldata;

			my @docs;
			my $i = 0;
			while ($i < length $alldata) {
				push @docs, unpack $packstring,
					substr $alldata, $i, $packlength;
				$i += $packlength;
			}
			for (my $i = 0; $i < @docs; $i += 2) {
                                if ($docs[$i] == $id) { return (($bot+($i/2))*$packlength, 1); }
				if ($docs[$i] > $id) { return (($bot+($i/2))*$packlength, 0); }
			}
			return ($top * $packlength, 0);
		}
		($val) = $dbh->selectrow_array(
			"select substring(idx, ?, 2) from $data_table
			where word = ?", {}, ($med * $packlength) + 1, $word);
		($val) = unpack $packstring, $val;

		if (not defined $val) { return; }
		if ($val == $id) { return ($med * $packlength, 1); }

		elsif ($val < $id) { $bot = $med + 1; }
		else { $top = $med; }

		$med = int($med * $id / $val);
	}
	return ($bot * $packlength, 0);
}

sub contains_hashref {
	my $self = shift;
	my $fts = $self->{'fts'};
	my $dbh = $fts->{'dbh'};
	my $data_table = $fts->{'data_table'};

	my $packstring = $DBIx::FullTextSearch::BITS_TO_PACK{$fts->{'doc_id_bits'}}
		. $DBIx::FullTextSearch::BITS_TO_PACK{$fts->{'count_bits'}};
	my ($packnulls) = pack $packstring, 0, 0;
	my $packlength = length $packnulls;

	my $sth = ( defined $self->{'get_idx_sth'} ?
		$self->{'get_idx_sth'} :
		$self->{'get_idx_sth'} =
			$dbh->prepare(
				"select idx from $data_table where word like ?"
			));
	
	my $out = {};
	for my $word (@_) {
		$sth->execute($word);
		while (my ($blob) = $sth->fetchrow_array) {
			next unless defined $blob;
			my @data;
			my $i = 0;
			while ($i < length $blob) {
				push @data, unpack $packstring,
					substr $blob, $i, $packlength;
				$i += $packlength;
			}
			while (@data) {
				my $doc = shift @data;
				my $count = shift @data;
				unless (defined $out->{$doc}) { $out->{$doc} = 0; }
				$out->{$doc} += $count;
			}
		}
		$sth->finish;
	}
	$out;
}

*parse_and_index_data = \&DBIx::FullTextSearch::parse_and_index_data_count;

1;

