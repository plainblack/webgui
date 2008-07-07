package WebGUI::Flux::Operator::DoesNotMatchPartialText;
use strict;
use warnings;

use base 'WebGUI::Flux::Operator';
use Scalar::Util qw(looks_like_number);

=head1 NAME

Package WebGUI::Flux::Operator::DoeNotMatchPartialText

=head1 DESCRIPTION

Matches partial text operator ('==' for numbers, 'eq' for strings).

See WebGUI::Flux::Operator base class for more information.

=cut

#-------------------------------------------------------------------

sub evaluate {
    my ( $self) = @_;
    
    my $a = $self->operand1();
    my $b = $self->operand2();
    
    if ( looks_like_number($a) && looks_like_number($b) ) {
        return 0;
    }
    else {
        return $a !~ /$b/;
    }
}

1;
