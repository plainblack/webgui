package WebGUI::Flux::Operator::IsLessThan;
use strict;
use warnings;

use base 'WebGUI::Flux::Operator';
use Scalar::Util qw(looks_like_number);
use Carp;

=head1 NAME

Package WebGUI::Flux::Operator::IsEqualTo

=head1 DESCRIPTION

Equality operator ('==' for numbers, 'eq' for strings).

See WebGUI::Flux::Operator base class for more information.

=cut

#-------------------------------------------------------------------

sub compare {
    my ( $a, $b ) = @_;
    
    if ( looks_like_number($a) && looks_like_number($b) ) {
        return $a < $b;
    }
    else {
        return $a lt $b;
    }
}

1;
