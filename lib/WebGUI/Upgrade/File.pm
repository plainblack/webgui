package WebGUI::Upgrade::File;
use Moose::Role;

requires 'run';

sub once { 0 }

1;

