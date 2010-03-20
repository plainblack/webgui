my $totalAssets = dbh->selectrow_array('SELECT COUNT(*) FROM asset');
::is $totalAssets, $::totalAssets, 'dbh function working correctly';

