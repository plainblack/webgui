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

use Test::More; # increment this value for each test you create
use Test::Deep;

my $num_tests = 3;

plan tests => $num_tests;
 
my $session = WebGUI::Test->session;
 
# put your tests here

my $privilege = $session->privilege;

my ($versionTag, $userTemplate) = setup_assets($session);

isa_ok($privilege, 'WebGUI::Session::Privilege', 'session has correct object type');

##Override the original user style template to make verification easier
my $origUserStyle = $session->setting->get('userFunctionStyleId');
$session->setting->set('userFunctionStyleId', $userTemplate->getId);

my $adminOnly = $privilege->adminOnly;
is($session->http->getStatus(), '401', 'adminOnly: status set to 401');
is($session->http->getStatusDescription(), 'Admin Only', 'adminOnly: description set to Admin Only');

sub setup_assets {
	my $session = shift;
	my $importNode = WebGUI::Asset->getImportNode($session);
	my $versionTag = WebGUI::VersionTag->getWorking($session);
	$versionTag->set({name=>"Session Style test"});
	my $properties = {
		title => 'user template for printing',
		className => 'WebGUI::Asset::Template',
		url => 'user_style_printable',
		namespace => 'Style',
		##Note, at this point 
		template => "<tmpl_var body.content>",
		id => 'printableUser0Template',
		#     '1234567890123456789012'
	};
	my $userTemplate = $importNode->addChild($properties, $properties->{id});
	return ($versionTag, $userTemplate);
}


END {
	$session->setting->set('userFunctionStyleId', $origUserStyle);
	if (defined $versionTag and ref $versionTag eq 'WebGUI::VersionTag') {
		$versionTag->rollback;
	}
}
