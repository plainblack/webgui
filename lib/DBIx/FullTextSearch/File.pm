
package DBIx::FullTextSearch::File;
use DBIx::FullTextSearch::String;
use strict;
use vars qw! @ISA !;
@ISA = qw! DBIx::FullTextSearch::String !;

sub index_document {
	my ($self, $file, $extra_data) = @_;
	my $dbh = $self->{'dbh'};

	open FILE, $file or do {
		$self->{'errstr'} = "Reading the file `$file' failed: $!";
		return;
	};
	my $data;
	{
		local $/ = undef;
		$data = <FILE>;
	}
	$data .= " $extra_data" if $extra_data;
	close FILE;
	$self->SUPER::index_document($file, $data);
}

1;

