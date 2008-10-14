package WebGUI::Macro::VisualMacro;

use strict;
use warnings;

sub process {
    my $session = shift;
    my @params = @_;
    $_ = "`$_`" for @params;
    return "\@MacroCall[" . join('.', @params) . "]:";
}

1;

