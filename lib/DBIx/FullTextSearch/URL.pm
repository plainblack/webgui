
package DBIx::FullTextSearch::URL;
use DBIx::FullTextSearch::String;
use strict;
use vars qw! @ISA !;
@ISA = qw! DBIx::FullTextSearch::String !;

use LWP::UserAgent;

sub index_document {
	my ($self, $uri, $extra_data) = @_;
	my $ua = ( defined $self->{'user_agent'}
		? $self->{'user_agent'}
		: $self->{'user_agent'} = new LWP::UserAgent );

	my $request = new HTTP::Request('GET', $uri);
	my $response = $ua->simple_request($request);
	if ($response->is_success) {
		my $data = $response->content;
		$data .= " $extra_data" if $extra_data;
		return $self->SUPER::index_document($uri, $data);
	}
	else {
		$self->{'errstr'} = $response->message;
	}
	return;
}

1;

