#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";
use WebGUI::Test;
use WebGUI::Session;
use WebGUI::AdSpace;

use Test::More;
use Test::Deep;

my $newAdSettings = {
    title             => "Untitled",
    clicksBought      => 0, ##From db
    impressionsBought => 0, ##From db
    url               => undef,
    adText            => undef,
    storageId         => undef,
    richMedia         => undef,
    ownerUserId       => "3",
    isActive          => 0, ##From db
    type              => "text",
    borderColor       => "#000000",
    textColor         => "#000000",
    backgroundColor   => "#ffffff",
    priority          => "0",
};

my $numTests = 7; # increment this value for each test you create
$numTests += scalar keys %{ $newAdSettings };
++$numTests; ##For conditional testing on module load

plan tests => $numTests;

my $loaded = use_ok('WebGUI::AdSpace::Ad');

my $session = WebGUI::Test->session;
my $ad;
my $richAd;
my $adSpace;

SKIP: {

    skip "Unable to load WebGUI::AdSpace::Ad", $numTests-1 unless $loaded;
    $adSpace = WebGUI::AdSpace->create($session, {name=>"Alfred"});
    $ad=WebGUI::AdSpace::Ad->create($session, $adSpace->getId, {"type" => "text"});
    isa_ok($ad,"WebGUI::AdSpace::Ad");

    isa_ok($ad->session, 'WebGUI::Session');
    isa($ad->get('type'), 'text', 'property set during object creation');

    my $ad2 = WebGUI::AdSpace::Ad->new($session, $ad->getId);
    cmp_deeply($ad2, $ad, "new returns an identical object to the original what was created");

    undef $ad2;

	my $data = $session->db->quickHashRef("select adId, adSpaceId from advertisement where adId=?",[$ad->getId]);

	ok(exists $data->{adId}, "create()");
	is($data->{adId}, $ad->getId, "getId()");
	is($data->{adSpaceId}, $ad->get('adSpaceId'), "get() adSpaceId");

    foreach my $setting (keys %{ $newAdSettings } ) {
        is($newAdSettings->{$setting}, $ad->get($setting),
            sprintf "default setting for %s", $setting);
    }

    $richAd = WebGUI::AdSpace::Ad->create($session, $adSpace->getId);
    $richAd->set({
    	type      => 'rich',
	richMedia => 'This is rich, ^@;'
    });
    my $renderedAd = $richAd->get('renderedAd');
    my $userName = $session->user->username;
    like($renderedAd, qr/This is rich, $userName/, 'Rich media ads render macros');

}

END {
	foreach my $advertisement ($ad, $richAd) {
		if (defined $advertisement and ref $advertisement eq 'WebGUI::AdSpace::Ad') {
			$advertisement->delete;
		}
	}
	if (defined $adSpace and ref $adSpace eq 'WebGUI::AdSpace') {
		$adSpace->delete;
	}
}
