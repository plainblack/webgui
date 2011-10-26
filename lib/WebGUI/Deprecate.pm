package WebGUI::Deprecate;

=head1 NAME

WebGUI::Deprecate - Warn about subroutine deprecations

=head1 SYNOPSIS

 use WebGUI::Deprecate;

 deprecate oldMethod => 'newMethod';
 sub newMethod { # will get called either way }

=head1 DESCRIPTION

Deprecate a subroutine, spitting out a warning whenever it is used.

=head2 derp ($message)

derp is short for DEprecation caRP.  Similar to carp, derp will emit the message
on STDERR.  If the message does not end with a newline, it will append a strack trace
to the message.  Each message is only printed once.

=head3 $message

The message to print.

=head2 deprecate ($old_method, $new_method)

This subroutine allows you to replace an old method with a new method and to emit a warning
to the user (developer) that they should be using something else.

=head3 $old_method

The old, deprecated method.

=head3 $new_method

The new, shiny method that should be called in its place.

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
        $message .= " at " . join( " line ", (caller(1))[0,2] );
    }

    return if ( $derped{ $message }++ ); # HERP
    warn $message . "\n"; # DERP
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

