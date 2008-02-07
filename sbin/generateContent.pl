#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

 
our $webguiRoot;

BEGIN {
        $webguiRoot = "..";
        unshift (@INC, $webguiRoot."/lib");
}

use DBI;
use FileHandle;
use Getopt::Long;
use strict qw(subs vars);
use WebGUI::Session;
use WebGUI::Asset;

$|=1;

my ($configFile, $assetId, $userId, $styleId, $toFile, $help);
$userId = 1;
my $url = "";

GetOptions(
	'configFile:s'=>\$configFile,
	'assetId:s'=>\$assetId,
	'userId:s'=>\$userId,
	'toFile:s'=>\$toFile,
	'help'=>\$help,
	'styleId:s'=>\$styleId,
	'url=s'=>\$url
);

if ($help || $configFile eq '' || !($assetId||$url)) {
	print <<STOP;


Usage: perl $0 --configFile=<webguiConfig> --url=home

Options:

	--configFile    WebGUI config file (with no path info).


	--assetId       Set the asset to be generated.

        --help		Displays this message.

	--styleId	Set an alternate style for the page.
			Defaults to asset's default style.

	--toFile	Set the path and filename to write the
			content to instead of standard out.

	--url		The URL of the asset to be generated.

	--userId	Set the user that should view the page.
			Defaults to "1" (Visitor).

STOP
	exit;
}

# Open WebGUI session
my $session = WebGUI::Session->open($webguiRoot,$configFile);
$session->user({userId=>$userId}) if (defined $userId);
$session->scratch->set("personalStyleId", $styleId) if (defined $styleId);

my $asset = undef;

if ($url) {
	$asset = WebGUI::Asset->newByUrl($session,$url);
} else {
	$asset = WebGUI::Asset->newByDynamicClass($session,$assetId);
}

if (defined $asset) {
	my $file = undef;
	if ($toFile) {
		$file = FileHandle->new(">$toFile") or die "Can't open file $toFile for writing. $!";
		$session->output->setHandle($file);
	}
	my $content = $asset->www_view;
	unless ($content eq "chunked") {
		$session->output->print($content);	
		$session->output->setHandle(undef);
	}
	$file->close if (defined $file);
} else {
	print "Asset not defined!!\n";
}

# Clean-up WebGUI Session
$session->var->end;
$session->close;

exit;

