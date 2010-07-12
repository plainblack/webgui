#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
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
use WebGUI::AdSpace::Ad;

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

my $numTests = 33; # increment this value for each test you create
$numTests += scalar keys %{ $newAdSettings };

plan tests => $numTests;

my $session = WebGUI::Test->session;
my $ad;
my ($richAd, $textAd, $imageAd, $nonAd, $setAd);
my $imageStorage = WebGUI::Storage->create($session);
WebGUI::Test->addToCleanup($imageStorage);
$imageStorage->addFileFromScalar('foo.bmp', 'This is not really an image');

$session->request->env->{REMOTE_ADDR} = '10.0.0.1';
$session->request->env->{HTTP_USER_AGENT} = 'Mozilla/5.0';

my $adSpace = WebGUI::AdSpace->create($session, {name=>"Tim Robbins"});
$ad=WebGUI::AdSpace::Ad->create($session, $adSpace->getId, {"type" => "text"});
isa_ok($ad,"WebGUI::AdSpace::Ad");

isa_ok($ad->session, 'WebGUI::Session');
is($ad->get('type'), 'text', 'property set during object creation');

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
##sure that all the requisite components are in there.
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
my $href = $token->[1]{onclick};
like($href, qr/op=clickAd/,               'ad link has correct operation');

my $adId = $textAd->getId;
like($href, qr/id=\Q$adId\E/,             'ad link has correct ad id');

$style = $token->[1]{style};
like($style, qr/background-color:white/,  'ad link background is white');

$token = $textP->get_tag("span");
$style = $token->[1]{style};
like($style, qr/color:blue/,              'ad title text foreground is blue');

$token = $textP->get_tag("span");
$style = $token->[1]{style};
like($style, qr/color:blue/,              'ad title text foreground is blue');

my $adText = $textP->get_trimmed_text('/span');
is($adText, $textAd->get('adText'),       'ad text is correct');

##Ditto for the image ad
$adSpace->set({
    width  => 250,
    height => 250
});

$imageAd = WebGUI::AdSpace::Ad->create($session, $adSpace->getId);
$imageAd->set({
    type       => 'image',
    title      => 'This is an image ad',
    storageId  => $imageStorage->getId,
});
my $renderedImageAd = $imageAd->get('renderedAd');

my $textP = HTML::TokeParser->new(\$renderedImageAd);

##Outer div checks
my $token = $textP->get_tag("div");
my $style = $token->[1]{style};
like($style, qr/height:250/,          'adSpace height rendered correctly, image');
like($style, qr/width:250/,           'adSpace width rendered correctly, image');

##Link checks
$token = $textP->get_tag("a");
my $href = $token->[1]{onclick};
like($href, qr/op=clickAd/,               'ad link has correct operation, image');

$adId = $imageAd->getId;
like($href, qr/id=\Q$adId\E/,             'ad link has correct ad id, image');

$token = $textP->get_tag("img");
$style = $token->[1]{src};
is($style, $imageStorage->getUrl($imageStorage->getFiles->[0]), 'ad image points at correct file');
$style = $token->[1]{alt};
is($style, $imageAd->get('title'), 'ad title matches, image');

my $nonAdProperties = {
    type       => 'nothing',
    title      => 'This ad will never render',
};
$nonAd = WebGUI::AdSpace::Ad->create($session, $adSpace->getId, $nonAdProperties);
my $renderedNonAd = $nonAd->get('renderedAd');

is($renderedNonAd, undef, 'undefined ad types are not rendered');

$nonAd->delete;

$nonAd = WebGUI::AdSpace::Ad->new($session, 'nonExistantId');
is($nonAd, undef, 'requesting a non-existant id via new returns undef');

my $setAd = WebGUI::AdSpace::Ad->create($session, $adSpace->getId, {isActive => 1});
is($setAd->get('isActive'), 1, 'set isActive true during instantiation');
$setAd->set({isActive=>0});
is($setAd->get('isActive'), 0, 'set isActive false during instantiation');
$setAd->delete;

my $setAd = WebGUI::AdSpace::Ad->create($session, $adSpace->getId, {priority => 1});
is($setAd->get('priority'), 1, 'set priority=1 during instantiation');
$setAd->set({priority=>0});
is($setAd->get('priority'), 0, 'set priority=0');

$setAd->set({ title => 'myTitle', url => 'http://www.nowhere.com', adText => 'Performing a valuable service for the community'});
is($setAd->get('url'),    'http://www.nowhere.com',                          'set: url');
is($setAd->get('adText'), 'Performing a valuable service for the community', 'set: adText');

$setAd->set({ url => '', adText => ''});
is($setAd->get('url'),    '', 'set: clearing url');
is($setAd->get('adText'), '', 'set: clearing adText');
$setAd->delete;

#vim:ft=perl
