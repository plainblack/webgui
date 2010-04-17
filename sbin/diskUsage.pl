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
use Getopt::Long;
use Pod::Usage;
use WebGUI::Paths -inc;
use WebGUI::Session;
use WebGUI::Asset;

my $configFile;
my $quiet;
my $assetId;
my $assetUrl;
my $summarize = 0;
my $blockSize = 1;
my $recurse = 1;
my $help;

$| = 1; # No buffering

GetOptions(
    'configFile=s'=>\$configFile,	# WebGUI Config file
    'assetId=s'   =>\$assetId,		# AssetId to start with (optional) uses default page if not specified.
    'assetUrl=s'  =>\$assetUrl,		# AssetUrl to start with (optional) uses default page if not specified
    'quiet'       =>\$quiet,		# No output except for numeric file size (default unit is bytes, will use blockSize if specified)
    'summary!'	  =>\$summarize,	# Displays total space used for asset and descendants (unless recurse flag is set to false in which case only the asset specified will be used)
    'blockSize=i' =>\$blockSize,	# Change units in which space used is specified, defaults to bytes.
    'recurse!'	  =>\$recurse,		# Flag indicating whether the disk space usage should consider asset and all descendants (default) or just the asset specified.
    'help!'	  =>\$help,	
);

pod2usage( verbose => 2 ) if $help;
pod2usage() unless $configFile;

my $session = start();
du();
finish($session);

#-------------------------------------------------
sub start {
        my $session = WebGUI::Session->open($configFile);
        $session->user({userId=>3});
        return $session;
}

#-------------------------------------------------
sub finish {
        my $session = shift;
	$session->var->end();
        $session->close();
}

#-------------------------------------------------------
sub du {
	my $asset;
	my $totalSize; # disk space used

	if ($assetId) { # They specified an assetId to start with
		$asset = WebGUI::Asset->newByDynamicClass($session,$assetId);
		die ("Unable to instanciate asset $assetId") unless defined $asset;
		print "\nStarting with asset $assetId...\n" unless $quiet;
	}
	elsif ($assetUrl) { # They specified an assetUrl to start with
		$asset = WebGUI::Asset->newByUrl($session,$assetUrl);
		die ("Unable to instanciate asset with URL $assetUrl") unless defined $asset;
		print "\nStarting with asset url $assetUrl...\n" unless $quiet;
	}
	else { # No id specified, assume they want to start with the site's home page
		$asset = WebGUI::Asset->getDefault($session);
		die ("Unable to instanciate the WebGUI Default Page.  Something is seriously broken.") unless defined $asset;
		print "\nStarting with the Default Page...\n" unless $quiet;
	}

	my $lineage = ["self"];
	push (@$lineage, "descendants") if $recurse;

	my $descendants = $asset->getLineage($lineage,{returnObjects=>1});
	foreach my $currentAsset (@$descendants) {
		my $size = $currentAsset->get("assetSize");
		$size = $size / $blockSize; # convert to blockSize specified
		$totalSize += $size;
	
		$size = sprintf("%.2f", $size) unless ($blockSize == 1); # No point in printing .00 after everything
		print "$size\t".$currentAsset->getUrl."\n" unless ($quiet || $summarize);
	}		

	# Format to a whole number unless the total is less than 1.  If it's less than 1 attempt to display 2 digits of precision to avoid displaying a zero size.
	unless ($totalSize < 1) {
		$totalSize = sprintf("%.0f", $totalSize);	
	}
	else {
		$totalSize = sprintf("%.2f", $totalSize);
	}

	unless ($quiet) { # Human readable	
		# try to come up with an intellegible label for the output
		my $units;
		if ($blockSize == 1) { # bytes
			$units = "bytes";
		} elsif ($blockSize == 1000 || $blockSize == 1024) { # kilobytes
			$units = "Kb";
		} elsif ($blockSize == 1000*1000 || $blockSize == 1024*1024) { # megabytes
			$units = "Mb";
		} else { # Unknown units
			$units = "units";
		}
	
		print "\nTotal Space used: $totalSize $units \n\n";
	} 
	else { # return script friendly output of the size only.
		print $totalSize;
	}
}

__END__

=head1 NAME

diskUsage - Display amount of disk space used by a WebGUI asset
            an its desecendants.

=head1 SYNOPSIS


 diskUsage --configFile config.conf
           [--assetId id]
	   [--assetUrl url]
           [--blockSize bytes]
	   [--norecurse]
	   [--quiet]
	   [--summary]

 diskUsage --help

=head1 DESCRIPTION

This WebGUI utility script displays the amount of disk space used by
an asset and it's descendants. It has been modeled after the *nix 'du'
utility.

=over

=item B<--configFile config.conf>

The WebGUI config file to use. Only the file name needs to be specified,
since it will be looked up inside WebGUI's configuration directory.
This parameter is required.

=item B<--assetId id>

Calculate disk usage starting from WebGUI's Asset identified by B<id>.
If this parameter is not supplied, calculations will start from
WebGUI's default page as defined in the Site settings.

=item B<--assetUrl url>

Calculate disk usage starting from the particular URL given by B<url>,
which must be relative to the server (e.g. B</home> instead of
B<http://your.server/home>). If this parameter is not supplied, calculations
will start from WebGUI's default page as defined in the Site settings.

=item B<--blockSize bytes>

Use B<bytes> as scaling factor to change the units in which disk space
will be reported. If this parameter is not supplied, it defaults to B<1>,
hence the results will be expressed in bytes. If you want to have kb,
use B<--blockSize 1024>.

=item B<--norecurse>

Prevent recursive calculation of disk space. This effectively computes
the used disk space for the starting Asset only, without including
its descendants.

=item B<--quiet>

Just display the total amount of disk space as a raw value.

=item B<--summary>

Just display the total amount of disk space in a human readable format.

=item B<--help>

Shows this documentation, then exits.

=back

=head1 AUTHOR

Copyright 2001-2009 Plain Black Corporation.

=cut
