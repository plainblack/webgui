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
        pnotes   => {},
        request  => $request,
        response => $response,
        server   => WebGUI::Session::Plack::Server->new( env => $p{env} ),
        headers_out => Plack::Util::headers( [] ),    # use Plack::Util to manage response headers
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
sub method { shift->{request}->method }
sub upload { shift->{request}->upload(@_) }
sub status_line  { }
sub auth_type    { }                                       # should we support this?

# These two cookie subs are called from our wG Plack-specific code
sub get_request_cookies {

    # Get the hash of { name => CGI::Simple::Cookie }
    my $cookies = shift->{request}->cookies;

    # Convert into { name => value } as expected by wG
    my %c = map { $_->name => $_->value } values %{$cookies};

    return \%c;
}

sub set_response_cookie {
    my ( $self, $name, $val ) = @_;
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
    $response->headers( $self->{headers_out}->headers );
    return $response->finalize;
}

sub no_cache {
    my ( $self, $doit ) = @_;
    if ($doit) {
        $self->{headers_out}->set( 'Pragma' => 'no-cache', 'Cache-control' => 'no-cache' );
    }
    else {
        $self->{headers_out}->remove( 'Pragma', 'Cache-control' );
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

package Plack::Request::Upload;

sub link { shift->link_to(@_) }

1;
