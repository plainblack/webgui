package WebGUI::Clipboard;

use strict;
use WebGUI::Session;
use WebGUI::SQL;

sub getAssetsInClipboard {
	my @assets;
	my $sth = WebGUI::SQL->read("select assetId, title from asset where state='clipboard' order by lastUpdated desc");
	while (my ($assetId, $title) = $sth->array) {
		push(@assets, {
			title => $title,
			assetId => $assetId
			});
	}
	$sth->finish;
	return \@assets;
}

1;

