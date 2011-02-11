use warnings;
use strict;

use FindBin;
use lib "$FindBin::Bin/../../lib";

use Test::More;
use WebGUI::Test;
use WebGUI::Test::Metadata;

use WebGUI::Asset;

my $session = WebGUI::Test->session;
my $root = WebGUI::Asset->getImportNode($session);

sub asset {
    my $asset = $root->addChild({ @_ });
    WebGUI::Test->addToCleanup($asset);
    return $asset;
}

my $state  = WebGUI::Test::Metadata->new($root, fieldName => 'State');
my $county = WebGUI::Test::Metadata->new($root, fieldName => 'County');

my $snip = asset className => 'WebGUI::Asset::Snippet';

sub town {
    my ($t, $c, $s) = @_;
    sleep 1; #for different creation dates
    my $a = asset(className => 'WebGUI::Asset::Snippet', title => $t);
    $state->update($s, $a);
    $county->update($c, $a);
    return $a;
}

sub town_is {
    my ($got, $expected, $message) = @_;
    if ($got->getId eq $expected->getId) {
        pass($message);
    }
    else {
        fail($message);
        diag <<DIAG;
          got: ${ \$got->getTitle }
     expected: ${ \$expected->getTitle }
DIAG
    }
}

my $grafton   = town qw(Grafton Ozaukee Wisconsin);
my $baraboo   = town qw(Baraboo Sauk Wisconsin);
my $centralia = town qw(Centralia Lewis Washington);
my $seattle   = town qw(Seattle King Washington);

my $short = asset
    className          => 'WebGUI::Asset::Shortcut',
    shortcutToAssetId  => $snip->getId,
    disableContentLock => 1;

sub match {
    $short->update({ shortcutCriteria => shift });
    $short->getShortcutByCriteria;
}

plan tests => 4;

town_is match('State = Wisconsin and County != Sauk'), $grafton;
town_is match('State != Washington'), $baraboo;
town_is match('County = Lewis'), $centralia;
town_is match('County != Sauk'), $seattle;

# If we don't undef these explicitly, destruction order doesn't happen right
# because of closure in town()
undef $state;
undef $county;
