package WebGUI::Macro::If;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

 
use strict;
use WebGUI::International;
use Safe;

=head1 NAME

Package WebGUI::Macro::If

=head1 DESCRIPTION

A macro for implementing a simple conditional.

=head2 process ( expression, trueResult, falseResult )

Returns trueResult if expression is true, falseResult if the expression
is false and an error message if there was a problem evaluating the
expression.

=head3 expression

A perl expression that will be evaulated in a Safe compartment.

=head3 trueResult

Text that will be returned if the expression is true.

=head3 falseResult

Text that will be returned if the expression is false.

=cut

sub process {
        my ($expression, $true, $false) = @_;
        my $output = $false; 

        # Workaround to "Safely" eval $expression
        my $compartment = new Safe;
        my $return = $compartment->reval($expression);
        
        return sprintf(WebGUI::International::get('eval error', 'Macro_If'),
		$@,$expression,$true,$false) if ($@);
        
        $output = $true if ($return);
        
        return $output;
}

1;

