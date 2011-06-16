package WebGUI::Template::Proxy;
use strict;
use warnings;
use Scalar::Util qw(blessed);
use mro;
use Try::Tiny;
use namespace::clean;

sub new {
    my $class = shift;
    $class = __PACKAGE__->_classify($class);
    return $class->_new(@_);
}

sub _new {
    my ($class, $context, $object) = @_;

    my $stash = $context->stash;
    my $session = $stash->{_session};

    my $self = bless {
        _session => $session,
        _context => $context,
        _object  => $object,
    }, $class;

    $self->{_methods} = $self->_get_methods($object);
    return $self;
}

sub DESTROY {
    # prevent AUTOLOADing
}

sub AUTOLOAD {
    my $subname = our $AUTOLOAD;
    $subname =~ s/.*:://;
    my $self = shift;
    if (my $sub = $self->can($subname)) {
        return $self->$sub(@_);
    }
    die 'Method not found: ' . $subname;
}

sub can {
    my ($self, $subname) = @_;
    my $sub = $self->SUPER::can($subname);
    if ($sub) {
        return $sub;
    }
    elsif (ref $self) {
        if ($self->{_methods}{$subname}) {
            return $self->{_methods}{$subname};
        }
    }
    return;
}

my %classified;
sub _classify {
    my $self = shift;
    my $class = shift;
    if ($classified{$class}) {
        return $classified{$class};
    }
    my $classes = mro::get_linear_isa($class);
    my @proxyclasses = map { (/^WebGUI::(.*)/ ? (__PACKAGE__ . '::' . $1) : (), __PACKAGE__ . '::' . $_) } @$classes;
    for my $isa ( @proxyclasses ) {
        (my $module = $isa . '.pm') =~ s{::}{/}g;
        try {
            require $module;
            $classified{$class} = $isa;
        } || next;
        return $isa;
    }
    die "Cannot proxy $class";
}

sub _get_methods {
    my $self = shift;
    my $object = shift;
    my @allowed = $self->_get_allowed($object);
    my %methods;
    for my $method ( @allowed ) {
        $methods{$method} = $self->_gen_wrapped($method);
    }
    return \%methods;
}

sub _gen_wrapped {
    my $self = shift;
    my $method = shift;
    my $context = $self->{_context};
    my $object = $self->{_object};
    return sub {
        my @res;
        if (wantarray) {
            @res = $object->$method;
        }
        else {
            $res[0] = $object->$method;
        }
        for my $res ( @res ) {
            $self->_wrap(@res);
        }
        return wantarray ? @res : $res[0];
    };
}

sub _wrap {
    my $self = shift;
    my $context = $self->{_context};
    for my $item ( @_ ) {
        if ( blessed $item ) {
            if (! $item->isa(__PACKAGE__) ) {
                $item = __PACKAGE__->new($context, $item);
            }
        }
    }
}

sub _get_allowed {
    return ();
}

1;

