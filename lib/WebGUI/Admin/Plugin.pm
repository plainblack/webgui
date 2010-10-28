package WebGUI::Admin::Plugin;

use Moose;
use Scalar::Util qw(blessed);

has 'id' => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

has 'title' => (
    is      => 'rw',
    isa     => 'Str',
);

has 'icon' => (
    is      => 'rw',
    isa     => 'Str',
    default => '',      # Find a good default
);

has 'iconSmall' => (
    is      => 'rw',
    isa     => 'Str',
    default => '',      # Find a good default
);

sub BUILDARGS {
    my ( $class, $session, %args ) = @_;
    return { session => $session, %args };
}

sub canUse {
    return 1;
}

sub getUrl {
    my ( $self, $method, $params ) = @_;
    $method ||= "view";
    return '?op=admin;plugin=' . $self->id . ';method=' . $method . ';' . $params;
}

1;
