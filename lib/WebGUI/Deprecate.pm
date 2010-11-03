package WebGUI::Deprecate;

=head1 NAME

WebGUI::Deprecate - Warn about subroutine deprecations

=head1 SYNOPSIS

 use WebGUI::Deprecate;

 deprecate oldMethod => 'newMethod';
 sub newMethod { # will get called either way }

=head1 DESCRIPTION

Deprecate a subroutine, spitting out a warning whenever it is used.

=cut

use strict;
use warnings;

use Sub::Exporter -setup => {
    exports => [ 'deprecate' ],
    groups => {
        default => [ 'deprecate' ],
    }
};

my %warned;
sub deprecate ($$) {
    my ($old_method, $new_method) = @_;
    my $package = caller;
    no strict 'refs';
    no warnings 'redefine';
    *{"$package\::$old_method"} = \&{"$package\::$new_method"};
    my $proxy_method = sub {
        my $self = $_[0];
        my $sub = $self->can($old_method);
        my $class = ref $self || $self;
        if ($sub ne \&{"$package\::$old_method"}) {
            my $message = "$class contains the method $old_method.  This has been deprecated and replaced with $new_method.";
            warn $message unless $warned{$message}++;
            $self->$new_method( @_ );
        }
        goto $sub;
    };
    *{"$package\::$new_method"} = $proxy_method;
}

1;

