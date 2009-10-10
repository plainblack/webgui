package WebGUI::Session::Plack;

use strict;
use warnings;
use Carp;

=head1 DESCRIPTION

This class is used instead of WebGUI::Session::Request when wg is started via plackup

=cut

sub new {
    my ( $class, %p ) = @_;

    # 'require' rather than 'use' so that non-plebgui doesn't freak out
    require Plack::Request;
    my $request  = Plack::Request->new( $p{env} );
    my $response = $request->new_response(200);

    bless {
        %p,
        pnotes      => {},
        request     => $request,
        response    => $response,
        server      => WebGUI::Session::Plack::Server->new( env => $p{env} ),
        headers_out => WebGUI::Session::Plack::HeadersOut->new( request => $request, response => $response ),
        body        => [],
        sendfile    => undef,
    }, $class;
}

our $AUTOLOAD;

sub AUTOLOAD {
    my $what = $AUTOLOAD;
    $what =~ s/.*:://;
    carp "!!plack->$what(@_)" unless $what eq 'DESTROY';
}

# Emulate/delegate/fake Apache2::* subs
sub uri          { shift->{request}->request_uri(@_) }
sub param        { shift->{request}->param(@_) }
sub params       { shift->{request}->params(@_) }
sub headers_in   { shift->{request}->headers(@_) }
sub headers_out  { shift->{headers_out} }
sub protocol     { shift->{request}->protocol(@_) }
sub status       { shift->{response}->status(@_) }
sub sendfile     { $_[0]->{sendfile} = $_[1] }
sub content_type { shift->{response}->content_type(@_) }
sub server       { shift->{server} }
sub status_line  { }
sub auth_type    { }                                       # should we support this?

# These two cookie subs are called from our wG Plack-specific code
sub get_request_cookies { shift->{request}->cookies }      # returns hashref of all request cookies

sub set_response_cookie {
    my ( $self, $name, $val ) = @_;

    #warn "setting cookies $name => " . Data::Dumper::Dumper($val);
    $self->{response}->cookies->{$name} = $val;
}

# TODO: I suppose this should do some sort of IO::Handle thing
sub print {
    my $self = shift;
    push @{ $self->{body} }, @_;
}

sub dir_config {
    my ( $self, $c ) = @_;
    return $self->{env}->{"wg.DIR_CONFIG.$c"};
}

sub pnotes {
    my ( $self, $key ) = ( shift, shift );
    return wantarray ? %{ $self->{pnotes} } : $self->{pnotes} unless defined $key;
    return $self->{pnotes}{$key} = $_[0] if @_;
    return $self->{pnotes}{$key};
}

sub user {
    my ( $self, $user ) = @_;
    if ( defined $user ) {
        $self->{user} = $user;
    }
    $self->{user};
}

sub push_handlers {
    my $self = shift;
    my ( $x, $sub ) = @_;

    # log it
    # carp "push_handlers($x)";

    # run it
    # returns something like Apache2::Const::OK, which we just ignore because we're not modperl
    my $ret = $sub->($self);

    return;
}

sub finalize {
    my $self     = shift;
    my $response = $self->{response};
    if ( $self->{sendfile} && open my $fh, '<', $self->{sendfile} ) {
        $response->body($fh);
    }
    else {
        $response->body( $self->{body} );
    }
    return $response->finalize;
}

sub no_cache {
    my ( $self, $doit ) = @_;
    if ($doit) {
        $self->{response}->headers->push_header( 'Pragma' => 'no-cache', 'Cache-control' => 'no-cache' );
    }
    else {
        $self->{response}->headers->remove_header( 'Pragma', 'Cache-control' );
    }
}

################################################

package WebGUI::Session::Plack::Server;

use strict;
use warnings;
use Carp;

sub new {
    my $class = shift;
    bless {@_}, $class;
}

our $AUTOLOAD;

sub AUTOLOAD {
    my $what = $AUTOLOAD;
    $what =~ s/.*:://;
    carp "!!server->$what(@_)" unless $what eq 'DESTROY';
}

sub dir_config {
    my ( $self, $c ) = @_;
    return $self->{env}->{"wg.DIR_CONFIG.$c"};
}

################################################

package WebGUI::Session::Plack::HeadersOut;

=head1 DESCRIPTION

This class is required so that wG can call: 

 $session->response->headers_out->set('a' => 'b');

But for code under out control we just use:

 $response->headers->push_header('a' => 'b');
 $repsonse->headers->remove_header('a');

=cut

use strict;
use warnings;
use Carp;

sub new {
    my $class = shift;
    bless {@_}, $class;
}

our $AUTOLOAD;

sub AUTOLOAD {
    my $what = $AUTOLOAD;
    $what =~ s/.*:://;
    carp "!!headers_out->$what(@_)" unless $what eq 'DESTROY';
}

# This is the sub that wG calls
sub set {
    my $self = shift;
    $self->{response}->headers->push_header(@_);
}

################################################

1;
