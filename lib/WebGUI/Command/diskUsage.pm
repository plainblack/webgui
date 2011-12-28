package WebGUI::Command::diskUsage;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use WebGUI::Command -command;
use strict;
use warnings;

sub opt_spec {
    return (
        [ 'configFile=s', 'The WebGUI config file to use.  This parameter is required.'],
        [ 'assetId=s', 'AssetId to start with (optional) uses default page if not specified.' ],
        [ 'assetUrl=s', 'AssetUrl to start with (optional) uses default page if not specified'],
        [ 'quiet',  'No output except for numeric file size (default unit is bytes, will use blockSize if specified)'],
        [ 'summary!',   'Displays total space used for asset and descendants (unless recurse flag is set to false in which case only the asset specified will be used)'],
        [ 'blockSize=i',    'Change units in which space used is specified, defaults to bytes.'],
        [ 'recurse!',   'Flag indicating whether the disk space usage should consider asset and all descendants (default) or just the asset specified.'],
    );
}

sub validate_args {
    my ($self, $opt, $args) = @_;
    if (! $opt->{configfile}) {
        $self->usage_error('You must specify the --configFile option.');
    }
}

sub run {
    my ($self, $opt, $args) = @_;

    my ($configFile, $assetId, $assetUrl, $quiet, $summarize, $blockSize, $recurse) =
        @{$opt}{qw(configfile assetid asseturl quiet summary blocksize recurse)};
    $summarize //= 0;
    $blockSize //= 1;
    $recurse //= 1;

    my $session = WebGUI::Session->open($configFile);
    $session->user({userId=>3});

	my $asset;
	my $totalSize; # disk space used

	if ($assetId) { # They specified an assetId to start with
		$asset = WebGUI::Asset->newById($session,$assetId);
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

    $session->var->end;
    $session->close;
}

1;

__END__

=head1 NAME

WebGUI::Command::diskUsage - Display amount of disk space used by a WebGUI asset and its desecendants.

=head1 SYNOPSIS

 webgui.pl diskusage --configFile config.conf
                    [--assetId id]
                    [--assetUrl url]
                    [--blockSize bytes]
                    [--norecurse]
                    [--quiet]
                    [--summary]

=head1 DESCRIPTION

This WebGUI utility script displays the amount of disk space used by
an asset and it's descendants. It has been modeled after the *nix 'du'
utility.

=over

=item C<--configFile config.conf>

The WebGUI config file to use. Only the file name needs to be specified,
since it will be looked up inside WebGUI's configuration directory.
This parameter is required.

=item C<--assetId id>

Calculate disk usage starting from WebGUI's Asset identified by B<id>.
If this parameter is not supplied, calculations will start from
WebGUI's default page as defined in the Site settings.

=item C<--assetUrl url>

Calculate disk usage starting from the particular URL given by B<url>,
which must be relative to the server (e.g. C</home> instead of
B<http://your.server/home>). If this parameter is not supplied, calculations
will start from WebGUI's default page as defined in the Site settings.

=item C<--blockSize bytes>

Use C<bytes> as scaling factor to change the units in which disk space
will be reported. If this parameter is not supplied, it defaults to B<1>,
hence the results will be expressed in bytes. If you want to have kb,
use C<--blockSize 1024>.

=item C<--norecurse>

Prevent recursive calculation of disk space. This effectively computes
the used disk space for the starting Asset only, without including
its descendants.

=item C<--quiet>

Just display the total amount of disk space as a raw value.

=item C<--summary>

Just display the total amount of disk space in a human readable format.

=back

=head1 AUTHOR

Copyright 2001-2012 Plain Black Corporation.

=cut
