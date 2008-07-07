package WebGUI::Flux::Operator::MatchesPartialText;
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
    my $b = $self->operand2();
    
    return $a =~ /\Q$b\E/;    
}

1;
