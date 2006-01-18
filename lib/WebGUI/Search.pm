package WebGUI::Search;

use strict;
use warnings;

use Carp;
use Plucene::Analysis::SimpleAnalyzer;
use Plucene::Analysis::WhitespaceAnalyzer;
use Plucene::Document;
use Plucene::Document::Field;
use Plucene::Index::Reader;
use Plucene::Index::Writer;
use Plucene::QueryParser;
use Plucene::Search::HitCollector;
use Plucene::Search::IndexSearcher;
use Plucene::Index::Term;
use File::Spec::Functions qw(catfile);
use WebGUI::Search::DateTimeFilter;
use WebGUI::Utility;

sub open {
	my ($class, $dir) = @_;
	$dir or croak "No directory given";
	bless { _dir => $dir }, $class;
}

sub _dir { shift->{_dir} }

sub _parsed_query {
	my ($self, $query, $default) = @_;
	my $parser = Plucene::QueryParser->new({
			analyzer => Plucene::Analysis::SimpleAnalyzer->new(),
			default  => $default
		});
	$parser->parse($query);
}

sub _searcher { Plucene::Search::IndexSearcher->new(shift->_dir) }

sub _reader { Plucene::Index::Reader->open(shift->_dir) }

sub search {
	my ($self, $sstring) = @_;
	return () unless $sstring;
	my @docs;
	my $searcher = $self->_searcher;
	my $hc       = Plucene::Search::HitCollector->new(
		collect => sub {
			my ($self, $doc, $score) = @_;
			my $res = eval { $searcher->doc($doc) };
			push @docs, [ $res, $score ] if $res;
		});
	$searcher->search_hc($self->_parsed_query($sstring, 'text'), $hc);
	return map $_->[0]->get("id")->string, sort { $b->[1] <=> $a->[1] } @docs;
}

sub search_during {
	my ($self, $sstring, $date1, $date2) = @_;
	return () unless $sstring;
	my $filter = WebGUI::Search::DateTimeFilter->new({
			field => '_date_',
			from  => $date1,
			to    => $date2
		});
	my $qp = Plucene::QueryParser->new({
			analyzer => Plucene::Analysis::WhitespaceAnalyzer->new(),
			default  => "text"
		});
	my $query = $qp->parse($sstring);
	my $hits = $self->_searcher->search($query, $filter);
	return () unless $hits->length;
	my @docs = map $hits->doc($_), 0 .. ($hits->length - 1);
	return map $_->get("id")->string, @docs;
}

sub _writer {
	my $self = shift;
	return Plucene::Index::Writer->new(
		$self->_dir,
		Plucene::Analysis::SimpleAnalyzer->new(),
		-e catfile($self->_dir, "segments") ? 0 : 1
	);
}

sub add {
	my ($self, @data) = @_;
	my $writer = $self->_writer;
	while (my ($id, $terms) = splice @data, 0, 2) {
		my $doc = Plucene::Document->new;
		$doc->add(Plucene::Document::Field->Keyword(id => $id));
		foreach my $key (keys %$terms) {
			if ($key eq 'text') {
				next;    # gets added at the end anyway
			} elsif ($key eq "date") {
use DateTime;
				$doc->add(Plucene::Document::Field->Keyword("_date_", toBase36($terms->{date}*1000)));
				$doc->add(Plucene::Document::Field->Keyword("date", DateTime->from_epoch(epoch=>$terms->{date})->ymd));
			} else {
				$doc->add(Plucene::Document::Field->UnStored($key => $terms->{$key}));
				$terms->{text} .= " " . $terms->{$key} unless $key =~ /^_/;
			}
		}
		$doc->add(Plucene::Document::Field->UnStored(text => $terms->{text}));
		$writer->add_document($doc);
	}
	undef $writer;
}

sub index_document {
	my ($self, $id, $data) = @_;
	my $writer = $self->_writer;
	my $doc    = Plucene::Document->new;
	$doc->add(Plucene::Document::Field->Keyword(id => $id));
	$doc->add(Plucene::Document::Field->UnStored('text' => $data));
	$writer->add_document($doc);
	undef $writer;
}

sub delete_document {
	my ($self, $id) = @_;
	my $reader = $self->_reader;
	$reader->delete_term(
		Plucene::Index::Term->new({ field => "id", text => $id }));
	$reader->close;
}

sub optimize { shift->_writer->optimize() }

sub indexed {
	my ($self, $id) = @_;
	my $term = Plucene::Index::Term->new({ field => 'id', text => $id });
	return $self->_reader->doc_freq($term);
}



1;
