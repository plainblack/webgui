# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#------------------------------------------------------------------

# This "test" script shoves products into the table so that the upgrade translation
# process can be tested.
#
# Here's what we're looking for after the upgrade runs.
# 1) Correct number of products translated
# 2) All revisions translated
# 3) Variants created for each Product Wobject
# 4) If no productNumber is defined, then it makes one for you.
# 5) Titles are truncated to 30 characters and used as the short description
#

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";
use Test::More qw(no_plan);

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Shop::Tax;
use WebGUI::Asset::Wobject::Article;
use WebGUI::VersionTag;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

#----------------------------------------------------------------------------
# put your tests here

##Create products by hand

my $tag = WebGUI::VersionTag->getWorking($session);

my $aProperties1 = {
    className     => 'WebGUI::Asset::Wobject::Article',
    url           => 'oneArticle',
    title         => 'One Article',
    description   => q|^Product(nY7Q6cQaPB1h-fYnMYGqJg); ^Product('Fluid Flora');|,
};

my $root = WebGUI::Asset->getRoot($session);
my $article1 = $root->addChild($aProperties1);

my $lProperties1 = {
    className     => 'WebGUI::Asset::Wobject::Layout',
    url           => 'oneLayout',
    title         => 'One Layout',
    description   => q|^Product(ChickFlick); ^Product(ChickFlick,'customTemplateId');|,
};

my $layout1 = $root->addChild($lProperties1);

my $sProperties1 = {
    className => 'WebGUI::Asset::Snippet',
    url       => 'oneSnippet',
    title     => 'One Snippet',
    snippet   => q|^Product('South Beach'); ^Product(i-mG8KKBPuPiUA0qq04byQ);|,
};

my $snippet1 = $root->addChild($sProperties1);

my $tProperties1 = {
    className => 'WebGUI::Asset::Template',
    url       => 'oneTemplate',
    title     => 'One Template',
    snippet   => q|^Product('Slingshot Dragonfly'); ^Product('jqRw23vjpIDOYuhaFHoBkA');|,
};

my $template1 = $root->addChild($tProperties1);

$tag->commit;

note "Done.";
