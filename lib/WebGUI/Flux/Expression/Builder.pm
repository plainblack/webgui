package WebGUI::Flux::Expression::Builder;
use strict;
use warnings;

use Class::InsideOut qw{ :std };
use Readonly;
use JSON;
use WebGUI::Exception::Flux;

=head1 NAME

Package WebGUI::Flux::Expression::Builder

=head1 DESCRIPTION

This module drives the GUI for building individual Expressions. As such, it is
not required until we implement GUI building.

Each request from the user's browser contains a (partially) complete 
JSON-encoded Expression. This module parses the encoded Expression into an 
object that knows what stage of the Expression building process the user is 
up to. It is used to generate the next options to be returned to the user.

When it receives a complete JSON-encoded Expression, this module calls
Flux::Expression->create() to persist the Expression to the database.

=head1 SYNOPSIS

 # Possible usage:
 
 my $JSON = <<'END_JSON';
 {
    operand1: {
        xtype: 'UserProfile',
        args: {
            profileField: 'Birthday'
        },
        postProcessor: {
            xtype: 'WhenComparedToNowInUnitsOf',
            args: {
                units: 'd',
                timezone: 'user'
            }
        }
    },
    operator: {
        xtype: 'IsEqualTo'
    },
    operand2: {
        xtype: 'NumericalValue',
        args: {
            value: 0
        }
    }
 }
 END_JSON
 
 my $builder = Flux::Expression::Builder->parse($session, $JSON);
 if ($builder->isComplete()) {
     my $expression = Flux::Expression->create($session, {
         operand1 => $builder->getOperand1(),
         operand1Modifier => $builder->getOperand1Modifier(),
         operand2 => $builder->getOperand2(),
         operand2Modifier => $builder->getOperand2Modifier(),
         operator => $builder->getOperator(),
     });
 } else {
     my $nextStep = $builder->getNextStep();
     # .. return as JSON-encoded HTML response body
 } 

=head1 METHODS

These methods are available from this class:

=cut

1;
