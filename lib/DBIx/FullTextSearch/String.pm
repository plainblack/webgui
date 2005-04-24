
package DBIx::FullTextSearch::String;
use DBIx::FullTextSearch;
use strict;
use vars qw! @ISA !;
@ISA = qw! DBIx::FullTextSearch !;

# Create creates the conversion table that converts string names of
# documents to numbers
sub _create_tables {
	my $fts = shift;
	$fts->{'doc_id_table'} = $fts->{'table'} . '_docid'
			unless defined $fts->{'doc_id_table'};

	unless($fts->{'name_length'}){
		return "The parameter name_length has to be specified.";
	}

	my $CREATE_DOCID = <<EOF;
		create table $fts->{'doc_id_table'} (
			name varchar($fts->{'name_length'}) binary not null,
			id $DBIx::FullTextSearch::BITS_TO_INT{$fts->{'doc_id_bits'}} unsigned not null auto_increment,
			primary key (id),
			unique (name)
			)
EOF
	my $dbh = $fts->{'dbh'};
	$dbh->do($CREATE_DOCID) or return $dbh->errstr;
	push @{$fts->{'created_tables'}}, $fts->{'doc_id_table'};
	return;
}

sub get_id_for_name {
	my ($self, $string) = @_;
	my $dbh = $self->{'dbh'};
	my $doc_id_table = $self->{'doc_id_table'};

	my $name_to_id_sth = ( defined $self->{'name_to_id_sth'}
		? $self->{'name_to_id_sth'}
		: $self->{'name_to_id_sth'} = $dbh->prepare("select id from $doc_id_table where name = ?") or die $dbh->errstr);
	my $id = $dbh->selectrow_array($name_to_id_sth, {}, $string);
	if (not defined $id) {
		my $new_name_sth = (defined $self->{'new_name_sth'}
			? $self->{'new_name_sth'}
			: $self->{'new_name_sth'} =
			$dbh->prepare("insert into $doc_id_table values (?, null)") or die $dbh->errstr );
		$new_name_sth->execute($string) or die $new_name_sth->errstr;
		$id = $new_name_sth->{'mysql_insertid'};
	}
	$id;
}

sub index_document {
	my ($self, $string, $data) = @_;
	my $id = $self->get_id_for_name($string);
	$self->SUPER::index_document($id, $data);
}

sub delete_document {
  my ($self, $doc_id) = @_;

  $self->SUPER::delete_document($self->get_id_for_name($doc_id));
}

sub contains_hashref {
	my $self = shift;
	my $res = $self->SUPER::contains_hashref(@_);
	return unless keys %$res;

	my $doc_id_table = $self->{'doc_id_table'};

	my $data = $self->{'dbh'}->selectall_arrayref("select name, id from $doc_id_table where id in (" . join(',', ('?') x keys %$res).")", {}, keys %$res);
	return { map { ( $_->[0], $res->{$_->[1]} ) } @$data };
}


1;

