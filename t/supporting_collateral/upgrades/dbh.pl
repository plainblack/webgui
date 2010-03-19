my ($totalAssets) = dbh->selectrow_array('SELECT COUNT(*) FROM asset');
print $totalAssets;

