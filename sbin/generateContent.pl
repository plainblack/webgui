#!/usr/bin/env perl

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use File::Basename ();
use File::Spec;

my $webguiRoot;
BEGIN {
    $webguiRoot = File::Spec->rel2abs(File::Spec->catdir(File::Basename::dirname(__FILE__), File::Spec->updir));
    unshift @INC, File::Spec->catdir($webguiRoot, 'lib');
}

use DBI;
use FileHandle;
use Getopt::Long;
use Pod::Usage;
no strict 'refs';
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

pod2usage( verbose => 2 ) if $help;
pod2usage() if ($configFile eq '' || !($assetId||$url) );

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

__END__

=head1 NAME

generateContent - Generate content for a specified Asset

=head1 SYNOPSIS

 generateContent --configFile config.conf {--url home|--assetID id}
                 [--styleId id]
                 [--toFile pathname]
                 [--userId id]

 generateContent --help

=head1 DESCRIPTION

This WebGUI utility script generates content for an Asset specified
either by its URL or its Asset ID. The content is sent to standard
output or to a filename.

A particular WebGUI UserId can be specified as a viewer, in order
to check whether the content is correctly generated or not, being
possible to specify any of the available WebGUI styles to format
the generated content.

=over

=item B<--configFile config.conf>

The WebGUI config file to use. Only the file name needs to be specified,
since it will be looked up inside WebGUI's configuration directory.
This parameter is required.

=item B<--assetId id>

Generate content for WebGUI's Asset identified by B<id>. Either this
parameter or B<--url> must be supplied.

=item B<--url url>

Generate content for WebGUI's Asset located at B<url>, which must be
relative to the server (e.g. B</home> instead of B<http://your.server/home>).
Either this parameter or B<--assetID> must be supplied.

=item B<--styleId id>

Use the WebGUI style specified by the AssetID B<id>. If left unspecified,
it defaults to using the Asset's default style.

=item B<--toFile pathname>

Send generated content to the specified filename. If left unspecified,
content is sent to standard output.

=item B<--userId id>

Set a specific WebGUI user to act as content viewer. If left unspecified,
defaults to B<1> (Visitor).

=item B<--help>

Shows this documentation, then exits.

=back

=head1 AUTHOR

Copyright 2001-2009 Plain Black Corporation.

=cut
