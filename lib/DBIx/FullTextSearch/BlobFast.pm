
package DBIx::FullTextSearch::BlobFast;
use DBIx::FullTextSearch::Blob;
use vars qw! @ISA !;
@ISA = qw! DBIx::FullTextSearch::Blob !;
use strict;

sub delete_document {
	my $self = shift;
	my $fts = $self->{'fts'};
	my $dbh = $fts->{'dbh'};
	my $data_table = $fts->{'data_table'};

	my $packstring = $DBIx::FullTextSearch::BITS_TO_PACK{$fts->{'doc_id_bits'}}
		. $DBIx::FullTextSearch::BITS_TO_PACK{$fts->{'count_bits'}};
	my $value = '';
	for my $id (@_) {
		$value .= pack $packstring, $id, 0;
	}
	$dbh->do("
		update $data_table set idx = concat(idx, ?)
		", {}, $value);
	1;
}

sub update_document {
	my $self = shift;
	$self->delete_document($_[0]);
	$self->add_document(@_);
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
			my %docs = ();
			my @data;
			my $i = length($blob) - $packlength;
			while ($i >= 0) {
				my ($doc_id, $count) =
					unpack "\@$i$packstring", $blob;
### print STDERR "$doc_id $count\n";
				$i -= $packlength;
				next if exists $docs{$doc_id};
				$docs{$doc_id} = 1;
				next unless $count;
				push @data, $doc_id, $count;
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

