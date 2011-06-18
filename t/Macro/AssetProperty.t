use warnings;
use strict;

use Test::More tests => 8;

use FindBin;
use lib "$FindBin::Bin/../lib";

use WebGUI::Test;
use WebGUI::Asset;
use WebGUI::Macro::AssetProperty;

my $session = WebGUI::Test->session;
my $temp    = WebGUI::Asset->getTempspace($session);
my $props   = $temp->get;
my ($url, $id) = @{$props}{qw(url assetId)};

sub proc { WebGUI::Macro::AssetProperty::process($session, @_) }

is proc($id, 'url'), $url, 'assetId';
is proc($url, 'assetId'), $id, 'url';

for my $name (qw(url assetId parentId lineage title menuTitle)) {
    is proc($id, $name), $props->{$name}, "get $name";
}
