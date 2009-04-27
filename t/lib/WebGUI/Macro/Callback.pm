package WebGUI::Macro::Callback;

use strict;
use warnings;

my $callback = sub {''};

sub process {
    return $callback->(@_);
}

sub setCallback {
    $callback = shift;
}

1;

