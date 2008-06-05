package WebGUI::Flux::Operator;
use strict;
use warnings;

use WebGUI::Pluggable;
use English qw( -no_match_vars );
use WebGUI::Exception::Flux;

=head1 NAME

Package WebGUI::Flux::Operator

=head1 DESCRIPTION

Base class for Flux Operators. 

Operators implement a single boolean subroutine called compare()
that accepts exactly two arguemtns: operand1 and operand2.

=head1 SYNOPSIS

use WebGUI::Flux::Operator;

my $result 
    = WebGUI::Flux::Operator->compareUsing('IsEqualTo', 'aaa', 'bbb'); 
    # calls WebGUI::Flux::Operator::IsEqualTo->compare('aaa', 'bbb')
 
=head1 METHODS

These methods are available from this class:

=head2 compare( operand1, operand2 ) 

Implemented by inherited classes. Returns boolean value based on comparison of
operand1 and operand2.

=head3 operand1

First operand

=head3 operand2

Second operand

=cut

#-------------------------------------------------------------------

=head2 compareUsing( operator, operand1, operand2 ) 

Calls the compare() subroutine on the requested WebGUI::Flux::Operator 
subclass, e.g. 'IsEqualTo'. The compare() sub is passed operand1 and operand2
as its arguments. 

=head3 operator

WebGUI::Flux::Operator::<operator> to use (e.g. 'IsEqualTo')

=head3 operand1

First operand

=head3 operand2

Second operand

=cut

sub compareUsing {
    my ( $class, $operator, $a, $b ) = @_;

    if ( @_ != 4 ) {
        WebGUI::Error::InvalidParamCount->throw(
            got      => scalar(@_),
            expected => 4,
        );
    }
    
    # Trim whitespace from operands..
    # TODO: maybe this should be up to individual Operator modules?
    $a =~ s/^\s+//;
    $a =~ s/\s+$//;
    $b =~ s/^\s+//;
    $b =~ s/\s+$//;

    # Compare operands using the requested operator 
    my $result = eval { WebGUI::Pluggable::run("WebGUI::Flux::Operator::$operator", 'compare', [$a, $b]); };
    if ($EVAL_ERROR) {
         WebGUI::Error::Flux::OperatorEvalFailed->throw(
            operator => $operator,
            error => $EVAL_ERROR,
        );
    }

    return $result;
}

1;
