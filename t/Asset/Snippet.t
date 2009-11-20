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

##The goal of this test is to test the creation of Snippet Assets.

use WebGUI::Test;
use WebGUI::Session;
use Test::More tests => 18; # increment this value for each test you create
use WebGUI::Asset::Snippet;

my $session = WebGUI::Test->session;
my $node = WebGUI::Asset->getImportNode($session);
my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Snippet Test"});
addToCleanup($versionTag);
my $snippet = $node->addChild({className=>'WebGUI::Asset::Snippet'});

# Test for a sane object type
isa_ok($snippet, 'WebGUI::Asset::Snippet');

# Test to see if we can set values
my $properties = {
	cacheTimeout => 124,
	processAsTemplate => 1,
	mimeType => 'text/plain',
	snippet => "Gooey's milkshake brings all the girls to the yard...",
};
$snippet->update($properties);

foreach my $property (keys %{$properties}) {
	is ($snippet->get($property), $properties->{$property}, "updated $property is ".$properties->{$property});
}

# Test the getToolbar method
for (1..2) {
	my $toolbarState = $snippet->getToolbarState;
	my $toolbar = $snippet->getToolbar;
	is($toolbar, undef, 'getToolbar method returns undef when _toolbarState is set') if $toolbarState;
	isnt($toolbar, undef, 'getToolbar method returns something other than undef when _toolbarState is not set') unless $toolbarState;
	$snippet->toggleToolbar;
}

# Rudimentry test of the view method
my $output = $snippet->view;

# See if cache purges on update
$snippet->update({snippet=>"I pitty tha fool!"});
like($snippet->view, qr/I pitty tha fool/,"cache for view method purges on update");
like($snippet->www_view,qr/I pitty tha fool/,"cache for www_view method purges on update");

# It should return something
isnt ($output, undef, 'view method returns something');

# What about our snippet?
ok ($output =~ /Gooey's milkshake brings all the girls to the yard\.\.\./, 'view method output has our snippet in it'); 

my $wwwViewOutput = $snippet->www_view;
isnt ($wwwViewOutput, undef, 'www_view returns something');

my $editOutput = $snippet->www_edit;
isnt ($editOutput, undef, 'www_edit returns something');

$snippet->update({
    title   => "authMethod",
    processAsTemplate => 1,
    cacheTimeout      => 1,
    snippet => q|^SQL(select value from settings where name="<tmpl_var title>");|
});

WebGUI::Test->originalConfig('macros');
$session->config->addToHash('macros', 'SQL', 'SQL');

is($snippet->view(), 'WebGUI', 'Interpolating macros in works with template in the correct order');

my $empty = $node->addChild( { className => 'WebGUI::Asset::Snippet', } );
is($empty->www_view, 'empty', 'www_view: snippet with no content returns "empty"');

#----------------------------------------------------------------------
#Check caching

##Set up the snippet to do caching
$snippet->update({
    cacheTimeout   => 100,
    snippet        => 'Cache test: ^#;',
});

$versionTag->commit;

is $snippet->view, 'Cache test: 1', 'validate snippet content and set cache';
$session->user({userId => 3});
is $snippet->view(1), 'Cache test: 3', 'receive uncached content since view was passed the webMethod flag';

TODO: {
    local $TODO = "Tests to make later";
    ok(0, 'Test indexContent method');
}
