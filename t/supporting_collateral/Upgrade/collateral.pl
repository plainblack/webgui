my $c = collateral;

::isa_ok $c, 'Path::Class::Dir';

::ok -e $c->file('collateral.txt'), 'correct collateral path used';


