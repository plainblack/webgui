#!/usr/bin/perl

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black LLC.
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
use WebGUI::HTML;
use WebGUI::Utility;

$|=1;

my ($configFile, $pageId, $userId, $styleId, $toFile, $stripHTML, $help);

$userId = 1;

GetOptions(
	'configFile:s'=>\$configFile,
	'pageId:i'=>\$pageId,
	'userId:i'=>\$userId,
	'styleId:i'=>\$styleId,
	'toFile:s'=>\$toFile,
	'stripHTML'=>\$stripHTML,
	'help'=>\$help
);

#if ($help || $configFile eq '' || $pageId eq '' ) {
if ($help || $configFile eq '' ) {
	print <<STOP;


Usage: perl $0 --configfile=<webguiConfig> --pageId=<pageNumber>

	--configFile    WebGUI config file (with no path info).

	--pageId        Set the page to be generated.
	
Options:

        --help		Displays this message.

	--userId	Set the user that should view the page.
			Defaults to "1" (Visitor).

	--styleId	Set an alternate style for the page.
			Defaults to page's default style.

	--toFile	Set the path and filename to write the
			content to instead of standard out.

	--stripHTML	A flag indicating that WebGUI should
			strip all the HTML from the document and
			output only text. NOTE: The resulting
			text may have formatting problems as a
			result.
		
STOP
	exit;
}

# Open output file if necessary
if ($toFile) {
	open (TOFILE, ">$toFile") or die "Can't open file $toFile for writing. $!";
}

# Open WebGUI session
WebGUI::Session::open($webguiRoot,$configFile);
WebGUI::Session::refreshUserInfo($userId,$session{dbh});
WebGUI::Session::refreshPageInfo($pageId);

# No HTTP header as we're browserless
$session{page}{noHttpHeader} = 1;

# Alternate style
if (defined $styleId) {
	$session{form}{makePrintable}++; 	# prevent caching
	$session{page}{styleId} = $styleId;
}

# Retrieve content
my $content = WebGUI::page(undef, undef, 1);

# stripHTML
if ($stripHTML) {
	$content = WebGUI::HTML::html2text($content);
} else {
	# Make links absolute
	$content = WebGUI::HTML::makeAbsolute($content);
}

# Print result
if ($toFile) {
	print TOFILE $content;
} else {
	print $content;
}

# Clean-up WebGUI Session
WebGUI::Session::end($session{var}{sessionId});
WebGUI::Session::close();

# Close output file if necessary
close(TOFILE) if ($toFile);

exit;
