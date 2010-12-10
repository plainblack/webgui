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
    exports => [ 'deprecate', 'derp' ],
    groups => {
        default => [ 'deprecate', 'derp' ],
    }
};

my %derped;
sub derp ($) { # DEprecation caRP
    my ( $message ) = @_;

    # Add stack info to message
    unless ( $message =~ /\n$/ ) {
        $message .= " at " . join( "-", (caller(1))[0,2] );
    }

    return if ( $derped{ $message }++ ); # HERP
    warn $message;
}

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
        derp "$package\::$old_method is deprecated and should be replaced with $new_method";
        local $deep{1} = 1;
        $self->$new_method(@_);
    });
    $stash->add_package_symbol('&'.$new_method, sub {
        my $self = $_[0];
        if (!$deep{1}) {
            my $old_sub = $self->can($old_method);
            if ($old_sub ne \&{"$package\::$old_method"}) {
                derp "Subclass of $package uses deprecated method $old_method, which should be replaced with $new_method";
                goto $old_sub;
            }
        }
        goto $new_sub;
    });
}

1;

