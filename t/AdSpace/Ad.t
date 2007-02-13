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
use HTML::TokeParser;

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

my $numTests = 13; # increment this value for each test you create
$numTests += scalar keys %{ $newAdSettings };
++$numTests; ##For conditional testing on module load

plan tests => $numTests;

my $loaded = use_ok('WebGUI::AdSpace::Ad');

my $session = WebGUI::Test->session;
my $ad;
my ($richAd, $textAd);
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

    ##In this series of tests, we'll render a text ad and then pick it apart and make
    ##sure that all th requisite components are in there.
    $adSpace->set({
	width => 102,
	height => 202
    });

    $textAd = WebGUI::AdSpace::Ad->create($session, $adSpace->getId);
    $textAd->set({
    	type        => 'text',
	borderColor => 'black',
	backgroundColor => 'white',
	textColor => 'blue',
	title => 'This is a text ad',
	adText => 'Will hack for Gooey dolls.',
    });
    my $renderedTextAd = $textAd->get('renderedAd');
    
    my $textP = HTML::TokeParser->new(\$renderedTextAd);

    ##Outer div checks
    my $token = $textP->get_tag("div");
    my $style = $token->[1]{style};
    like($style, qr/height:200/,          'adSpace height rendered correctly');
    like($style, qr/width:100/,           'adSpace width rendered correctly');
    like($style, qr/border:solid black/,  'ad borderColor rendered correctly');

    ##Link checks
    $token = $textP->get_tag("a");
    my $href = $token->[1]{href};
    like($href, qr/op=clickAd/,               'ad link has correct operation');

    my $adId = $textAd->getId;
    like($href, qr/id=$adId/,                 'ad link has correct ad id');

    $style = $token->[1]{style};
    like($style, qr/background-color:white/,  'ad link background is white');
}

END {
	foreach my $advertisement ($ad, $richAd, $textAd) {
		if (defined $advertisement and ref $advertisement eq 'WebGUI::AdSpace::Ad') {
			$advertisement->delete;
		}
	}
	if (defined $adSpace and ref $adSpace eq 'WebGUI::AdSpace') {
		$adSpace->delete;
	}
}
