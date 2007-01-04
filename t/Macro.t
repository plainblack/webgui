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
use lib "$FindBin::Bin/lib";

use WebGUI::Test;
use WebGUI::Session;

use WebGUI::Macro;
use WebGUI::Asset;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;
my $defaultAsset = WebGUI::Asset->getDefault($session);

$session->asset($defaultAsset);

##Create a non-admin user who will be in the Registered User group
my $registeredUser = WebGUI::User->new($session, "new");
$registeredUser->username('TimBob');
$session->user({user => $registeredUser});

my %originalMacros = %{ $session->config->get('macros') };
##Overwrite any local configuration so that we know how to call it.
foreach my $macro (qw/GroupText LoginToggle PageTitle/) {
	$session->config->addToHash('macros', $macro, $macro);
}

plan tests => 5;

my $macroText = "CompanyName: ^c;";
WebGUI::Macro::process($session, \$macroText),
is(
	$macroText,
	"CompanyName: ".$session->setting->get('companyName'),
	"c_companyName Macro in text processed okay"
);

my $macroText = "PageTitle: ^PageTitle;";
WebGUI::Macro::process($session, \$macroText),
is(
	$macroText,
	"PageTitle: ".$session->asset->getTitle,
	"PageTitle Macro in text processed okay"
);

my $macroText = q|GroupText(Registered Users, example) : ^GroupText("Registered Users","example");|;
WebGUI::Macro::process($session, \$macroText),
is(
	$macroText,
	"GroupText(Registered Users, example) : example",
	"GroupText Macro in text processed okay for registered user"
);

my $macroText = q|GroupText(Registered Users, example: c/CompanyName Macro) : ^GroupText("Registered Users","example: ^c;");|;
WebGUI::Macro::process($session, \$macroText),
is(
	$macroText,
	"GroupText(Registered Users, example: c/CompanyName Macro) : example: ".$session->setting->get('companyName'),
	"GroupText Macro with nested c_companyName macro"
);

my $macroText = q|GroupText(Registered Users, example: PageTitle): ^GroupText("Registered Users","example: ^PageTitle;");|;
WebGUI::Macro::process($session, \$macroText),
is(
	$macroText,
	"GroupText(Registered Users, example: PageTitle): example: ".$session->asset->getTitle,
	"GroupText Macro with nested PageTitle macro"
);

END {
	$session->config->set('macros', \%originalMacros);
	foreach my $dude ($registeredUser) {
		$dude->delete if (defined $dude and ref $dude eq 'WebGUI::User');
	}
}
