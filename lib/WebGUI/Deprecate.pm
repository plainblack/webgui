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
use Package::Stash;

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
    my $stash = Package::Stash->new($package);

    my %deep;
    # keep a copy since it will be replaced
    my $new_sub = $stash->get_package_symbol('&'.$new_method);
    # call new method instead.  if 
    $stash->add_package_symbol('&'.$old_method, sub {
        my $self = shift;
        my $message = "$package\::$old_method is deprecated and should be replaced with $new_method at " . join( "-", (caller(0))[0,2] );
        warn $message
            unless $warned{$message}++;

        local $deep{1} = 1;
        $self->$new_method(@_);
    });
    $stash->add_package_symbol('&'.$new_method, sub {
        my $self = $_[0];
        if (!$deep{1}) {
            my $old_sub = $self->can($old_method);
            if ($old_sub ne \&{"$package\::$old_method"}) {
                my $message = "Subclass of $package uses deprecated method $old_method, which should be replaced with $new_method";
                carp $message
                    unless $warned{$message}++;
                goto $old_sub;
            }
        }
        goto $new_sub;
    });
}

1;

