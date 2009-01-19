package WebGUI::Flux::Operator::IsNotEmpty;
use strict;
use warnings;

use base 'WebGUI::Flux::Operator';
use Scalar::Util qw(looks_like_number);

=head1 NAME

Package WebGUI::Flux::Operator::MatchesPartialText

=head1 DESCRIPTION


See WebGUI::Flux::Operator base class for more information.

=cut

#-------------------------------------------------------------------

sub evaluate {
    my ( $self) = @_;
    
    my $a = $self->operand1();
    
    return !!$a;
}

1;
