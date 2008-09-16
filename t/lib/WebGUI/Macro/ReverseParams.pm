package WebGUI::Macro::ReverseParams;

use strict;
use warnings;

sub process {
    my $session = shift;
    return join '', reverse @_;
}

1;

