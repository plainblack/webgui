
package DBIx::FullTextSearch::TableString;
use vars qw! @ISA !;
@ISA = qw! DBIx::FullTextSearch::String DBIx::FullTextSearch::Table !;

sub index_document {
	my ($self, $id, $data) = @_;
	my @data_sets = $self->get_the_data_from_table($id);
	push @data_sets, $data if $data;
	$self->SUPER::index_document($id, \@data_sets);
}

package DBIx::FullTextSearch::TableNum;
use vars qw! @ISA !;
@ISA = qw! DBIx::FullTextSearch::Table !;

sub index_document {
	my ($self, $id, $extra_data) = @_;
	my @data_sets = $self->get_the_data_from_table($id);
	push @data_sets, $extra_data if $extra_data;
	$self->SUPER::index_document($id, \@data_sets);
}


package DBIx::FullTextSearch::Table;
use DBIx::FullTextSearch;
use strict;
use vars qw! @ISA !;
@ISA = qw! DBIx::FullTextSearch !;

sub _open_tables {
	my $self = shift;
	if (defined $self->{'doc_id_table'}) {
		eval 'use DBIx::FullTextSearch::String';
		bless $self, 'DBIx::FullTextSearch::TableString';
	}
	else {
		bless $self, 'DBIx::FullTextSearch::TableNum';
	}
}

# we do not create any new tables, we just check that the parameters are
# OK (the table and columns exist, etc.)
sub _create_tables {
	my $fts = shift;
	my ($table, $column, $id) = @{$fts}{ qw! table_name column_name
		column_id_name ! };
	if (not defined $table and $column =~ /\./) {
		($table, $column) = ($column =~ /^(.*)\.(.*)$/s);
	}
	my $id_type;

	if (not defined $table) {
		return "The parameter table_name has to be specified with the table frontend.";
	}
	if (not defined $column) {
		return "The parameter column_name has to be specified with the table frontend.";
	}
	my $dbh = $fts->{'dbh'};
	my $sth = $dbh->prepare("show columns from $table");
	$sth->{'PrintError'} = 0;
	$sth->{'RaiseError'} = 0;
	$sth->execute or return "The table `$table' doesn't exist.";

	my $info = $dbh->selectall_arrayref($sth,
			{ 'PrintError' => 0, 'RaiseError' => 0 });
	if (not defined $info) {
		return "The table `$table' doesn't exist.";
	}

# use Data::Dumper; print Dumper $info;

	if (not defined $id) {
		# search for column with primary key
		my $pri_num = 0;
		for my $i (0 .. $#$info) {
			if ($info->[$i][3] eq 'PRI') {
				$pri_num++;
				$id = $info->[$i][0];
				$id_type = $info->[$i][1];
			}
		}
		if ($pri_num > 1) {
			return 'The primary key has to be one-column.';
		}	
		if ($pri_num == 0) {
			return "No primary key found in the table `$table'.";
		}
	}
	else {
		# find '$id' column
		for my $i (0 .. $#$info) {
			if ($info->[$i][0] eq $id){
				$id_type = $info->[$i][1];
				last;
			}
		}
	}

	unless(defined $id_type){
		return "No key named '$id' found in the table '$table'";
	}

	my $testcol = $dbh->prepare("select $column from $table where 1 = 0");
	$testcol->execute or
		return "Column `$column' doesn't exist in table `$table'.";
	$testcol->finish;

	$fts->{'column_id_name'} = $id;

	my $errstr;

        if ($id_type =~ /([a-z]*int)/) {
                $fts->{'doc_id_bits'} = $DBIx::FullTextSearch::INT_TO_BITS{$1};
		bless $fts, 'DBIx::FullTextSearch::TableNum';
	}
	else {
		my ($length) = ($id_type =~ /^\w+\((\d+)\)$/);
		$fts->{'name_length'} = $1;
		eval 'use DBIx::FullTextSearch::String';
		bless $fts, 'DBIx::FullTextSearch::TableString';
		$errstr = $fts->DBIx::FullTextSearch::String::_create_tables($fts);
	}
### use Data::Dumper; print Dumper $fts;
	return $errstr;
}

sub get_the_data_from_table {
	my ($self, $id) = @_;
	my $dbh = $self->{'dbh'};
	my $get_data = ( defined $self->{'get_data_sth'}
		? $self->{'get_data_sth'}
		: $self->{'get_data_sth'} = $dbh->prepare("
			select $self->{'column_name'} from $self->{'table_name'}
			where $self->{'column_id_name'} = ?
			") );

	my @data_ary = $dbh->selectrow_array($get_data, {}, $id);
	return wantarray ? @data_ary : join(" ", @data_ary);
}

1;
