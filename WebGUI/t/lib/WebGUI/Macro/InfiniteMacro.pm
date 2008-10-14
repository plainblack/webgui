package WebGUI::Macro::InfiniteMacro;

use strict;
use warnings;

sub process {
    my $session = shift;
    my $slow = shift;
    if ($slow) {
        my $rand = int(rand(10000));
        return <<END;
^InfiniteMacro(^dfkgjhdfgk();dssdfsdfawilygth4 wu gbzwilrstg 
sdfgdsfg
r7ilsgg hbawl
dsfgsdfgiegvgv
dfggvac
"sdaf${rand}gsdfgdsfg"
w3avvbfielysv iw4yvg silyrgvb iyzrsv bilw4u bgizs4rv,
"efgkhgsdfges.rkdjgdskjghsalkgh\\"\\"\\"sag"       );';
END
    }
    else {
        return '^InfiniteMacro();';
    }
}

1;

