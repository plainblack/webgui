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

GetOptions(
	'configFile:s'=>\$configFile,
	'assetId:s'=>\$assetId,
	'userId:s'=>\$userId,
	'toFile:s'=>\$toFile,
	'stripHtml'=>\$stripHtml,
	'help'=>\$help,
	'relativeUrls'=>\$relativeUrls,
);

if ($help || $configFile eq '' ) {
	print <<STOP;


Usage: perl $0 --configFile=<webguiConfig>

	--configFile    WebGUI config file (with no path info).

Options:

	--assetId       Set the page to be generated.

        --help		Displays this message.

	--userId	Set the user that should view the page.
			Defaults to "1" (Visitor).

	--styleId	Set an alternate style for the page.
			Defaults to asset's default style.

	--toFile	Set the path and filename to write the
			content to instead of standard out.

	--stripHtml	A flag indicating that WebGUI should
			strip all the HTML from the document and
			output only text. NOTE: The resulting
			text may have formatting problems as a
			result.

STOP
	exit;
}

# Open WebGUI session
WebGUI::Session::open($webguiRoot,$configFile);

my $asset = WebGUI::Asset->newByDynamicClass($assetId);
die "Asset not defined" unless $asset;
$asset->{_properties}{styleTemplateId} = $styleId if ($styleId);
my $content = $asset->exportAsHtml({stripHtml => $stripHtml});

if ($toFile) {
        open (TOFILE, ">$toFile") or die "Can't open file $toFile for writing. $!";
	print TOFILE $content;
	close (TOFILE);
} else {
	print $content;
}

# Clean-up WebGUI Session
WebGUI::Session::end($session{var}{sessionId});
WebGUI::Session::close();

exit;

