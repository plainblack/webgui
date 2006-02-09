#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
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
use Getopt::Long;
use strict qw(subs vars);
use WebGUI;
use WebGUI::Session;

$|=1;

my ($configFile, $assetId, $userId, $styleId, $toFile, $stripHtml, $help, $relativeUrls);
$userId = 1;
my $url = "";

GetOptions(
	'configFile:s'=>\$configFile,
	'assetId:s'=>\$assetId,
	'userId:s'=>\$userId,
	'toFile:s'=>\$toFile,
	'stripHtml'=>\$stripHtml,
	'help'=>\$help,
	'relativeUrls'=>\$relativeUrls,
	'url=s'=>\$url
);

if ($help || $configFile eq '' || !($assetId||$url)) {
	print <<STOP;


Usage: perl $0 --configFile=<webguiConfig> --url=home

Options:

	--configFile    WebGUI config file (with no path info).


	--assetId       Set the asset to be generated.

        --help		Displays this message.

	--stripHtml	A flag indicating that WebGUI should
			strip all the HTML from the document and
			output only text. NOTE: The resulting
			text may have formatting problems as a
			result.

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

my $asset = "";

if ($url) {
	$asset = WebGUI::Asset->newByUrl($session,$url);
} else {
	$asset = WebGUI::Asset->newByDynamicClass($session,$assetId);
}

if (defined $asset) {
	#$asset->{_properties}{styleTemplateId} = $styleId if ($styleId);
	#my $content = $asset->exportAsHtml({stripHtml => $stripHtml});
	my $content = $asset->www_view;
	if ($toFile) {
        	open (TOFILE, ">$toFile") or die "Can't open file $toFile for writing. $!";
		print TOFILE $content;
		close (TOFILE);
	} else {
		print $content;
	}
} else {
	print "Asset not defined!!\n";
}

# Clean-up WebGUI Session
$session->var->end;
$session->close;

exit;

