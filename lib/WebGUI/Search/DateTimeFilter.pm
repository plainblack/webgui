package WebGUI::Search::DateTimeFilter;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use base 'Plucene::Search::Filter';
use Bit::Vector::Minimal;
use Plucene::Index::Term;
use WebGUI::Utility;

=head1 DESCRIPTION

This package is a replacement for Plucene::Search::DateFilter that uses epochs rather than Time::Piece objects.

=cut


#-------------------------------------------------------------------

=head2 new ( field [, from, to] )

Constructor.

=head3 field

The field name to build the filter for.

=head3 from

An epoch date to start the search from. Defaults to now minus one year.

=head3 to

An epoch date to end searching on. Defaults to now.

=cut

sub new {
	my $class = shift;
	my $args = shift;
	bless {
		field => $args->{field},
		from  => toBase36(($args->{from}||time()-60*60*24*365)*1000),
		to    => toBase36(($args->{to}||time())*1000),
	}, $class;
}

#-------------------------------------------------------------------

=head2 bits ( )

The actual filter method required by Plucene::Search::IndexSearcher.

=cut

sub bits {
        my ($self, $reader) = @_;
        my $bits = Bit::Vector::Minimal->new(size => $reader->max_doc);
        my $enum = $reader->terms(
                Plucene::Index::Term->new({
                                field => $self->{field},
                                text  => $self->{from} }));
        return $bits unless $enum->term;
        my $termdocs = $reader->term_docs;

        my $stop = Plucene::Index::Term->new({
                        field => $self->{field},
                        text  => $self->{to} });
        while ($enum->term->le($stop)) {
                $termdocs->seek($enum->term);
                $bits->set($termdocs->doc) while $termdocs->next;
                last unless $enum->next;
        }
        return $bits;
}

1;


