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
use Safe;

sub process {
        my ($expression, $true, $false) = @_;
        my $output = $false; 

        # Workaround to "Safely" eval $expression
        my $compartment = new Safe;
        my $return = $compartment->reval($expression);
        
        return "<p><b>If Macro failed:</b> $@ <p>Expression: $expression
		<br />Display if true: $true<br />Display if false: $false" if ($@);
        
        $output = $true if ($return);
        
        return $output;
}

1;

