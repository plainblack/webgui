package WebGUI::Upgrade::File;
use Moose::Role;

requires 'run';

has file        => ( is => 'ro' );
has configFile  => ( is => 'ro' );
has version     => ( is => 'ro' );
has upgrade => (
    is      => 'ro',
    handles => [ 'quiet' ],
);

sub once { 0 }

1;

