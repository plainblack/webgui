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
    $webguiRoot = File::Spec->rel2abs( File::Spec->catdir( File::Basename::dirname(__FILE__), File::Spec->updir ) );
    unshift @INC, File::Spec->catdir( $webguiRoot, 'lib' );
}

$|++;    # disable output buffering

our ( $configFile, $help, $man, $fix, $delete, $no_progress, $op_assetId );
use Pod::Usage;
use Getopt::Long;
use WebGUI::Session;

# Get parameters here, including $help
GetOptions(
    'configFile=s' => \$configFile,
    'help'         => \$help,
    'man'          => \$man,
    'fix'          => \$fix,
    'delete'       => \$delete,
    'noProgress'   => \$no_progress,
    'assetId=s'    => \$op_assetId,
);

pod2usage( verbose => 1 ) if $help;
pod2usage( verbose => 2 ) if $man;
pod2usage( msg => "Must specify a config file!" ) unless $configFile;

foreach my $libDir ( readLines( "preload.custom" ) ) {
    if ( !-d $libDir ) {
        warn "WARNING: Not adding lib directory '$libDir' from preload.custom: Directory does not exist.\n";
        next;
    }
    unshift @INC, $libDir;
}

my $session = start( $webguiRoot, $configFile );

sub progress {
    my ( $total, $current ) = @_;
    local $| = 1;
    my $done = int( ( ( $current / $total ) * 100 ) / 2 );
    $done &&= $done - 1;    # Fit the >
    my $space = 49 - $done;
    print "\r[", '=' x $done, '>', ' ' x $space, ']';
    printf ' (%d/%d)', $current, $total;
}

## SQL statements

my $total_asset_sql     = 'SELECT COUNT(*) FROM asset ';
my $total_assetdata_sql = 'SELECT COUNT( DISTINCT( assetId ) ) FROM assetData ';
my $count_shortcut_sql  = q!select count(*) from asset where className='WebGUI::Asset::Shortcut' !;
my $count_files_sql     = q!select count(*) from asset where className like 'WebGUI::Asset::File%' !;

# Order by lineage to put corrupt parents before corrupt children
# Join assetData to get all asset and assetData
my $iterator_sql   = "SELECT assetId, className, revisionDate, parentId FROM asset LEFT JOIN assetData USING ( assetId ) ";
my $sql_args = [];
if ($op_assetId) {
    my $asset_selector    = 'where assetId = ? ';
    $iterator_sql        .= $asset_selector;
    $total_asset_sql     .= $asset_selector;
    $total_assetdata_sql .= $asset_selector;
    $count_shortcut_sql  .= ' AND assetId = ? ';
    $count_files_sql      .= ' AND assetId = ? ';
    push @{ $sql_args }, $op_assetId;
}
$iterator_sql .= "GROUP BY assetId ORDER BY lineage ASC";
my $sth   = $session->db->read($iterator_sql, $sql_args);

my $totalAsset      = $session->db->quickScalar($total_asset_sql, $sql_args);
my $totalAssetData  = $session->db->quickScalar($total_assetdata_sql, $sql_args);
my $total   = $totalAsset >= $totalAssetData ? $totalAsset : $totalAssetData;

##Guarantee that we get the most recent revisionDate
my $max_revision  = $session->db->prepare('select max(revisionDate) from assetData where assetId=?');

print "Checking all assets\n";
my $count = 1;
my %classTables;            # Cache definition lookups
while ( my %row = $sth->hash ) {
    my $asset = eval { WebGUI::Asset->newPending( $session, $row{assetId} ) };
    if ( $@ || ! $asset ) {

        # Replace the progress bar with a message
        printf "\r%-68s", "-- Corrupt: $row{assetId}";

        # Should we do something?
        if ($fix) {
            my $classTables = $classTables{ $row{className} } ||= do {
                eval "require $row{className}";
                [ map { $_->{tableName} } reverse @{ $row{className}->definition($session) } ];
            };
            $max_revision->execute([$row{assetId}]);
            ($row{revisionDate}) = $max_revision->array();
            $row{revisionDate} ||= time;

            for my $table ( @{$classTables} ) {
                my $sqlFind     = "SELECT * FROM $table WHERE assetId=? ORDER BY revisionDate DESC";
                my @params      = @row{qw( assetId )};
                my $insertRow   = $session->db->quickHashRef( $sqlFind, \@params ) || {};
                if ( $row{revisionDate} != $insertRow->{revisionDate} ) {
                    $insertRow->{ assetId       } = $row{assetId};
                    $insertRow->{ revisionDate  } = $row{revisionDate};
                    my $cols    = join ",", keys %$insertRow;
                    my @values  = values %$insertRow;
                    my $places  = join ",", ('?') x @values;
                    my $sqlFix  = "INSERT INTO $table ($cols) VALUES ($places)";
                    $session->db->write( $sqlFix, \@values );
                }
            }
            print "Fixed.\n";

            my $asset   = WebGUI::Asset->newByDynamicClass( $session, $row{assetId} );
            # Make sure we have a valid parent
            if (!$asset) {
                print "\tWARNING.  Asset is still broken.\n";
            }
            elsif (! WebGUI::Asset->newByDynamicClass( $session, $row{parentId} )) {
                $asset->setParent( WebGUI::Asset->getImportNode( $session ) );
                print "\tNOTE: Invalid parent. Asset moved to Import Node\n";
            }

        } ## end if ($fix)
        elsif ($delete) {
            my $classTables = $classTables{ $row{className} } ||= do {
                eval "require $row{className}";
                [ map { $_->{tableName} } reverse @{ $row{className}->definition($session) } ];
            };

            my @params    = @row{qw( assetId revisionDate )};
            for my $table ( @{$classTables} ) {
                my $sqlDelete = "DELETE FROM $table WHERE assetId=? AND revisionDate=?";
                $session->db->write( $sqlDelete, \@params );
            }
            $session->db->write( "DELETE FROM asset WHERE assetId=?", [$row{assetId}] );

            print "Deleted.\n";
        } ## end elsif ($delete)
        else {    # report
            print "\n";
            if ( $row{revisionDate} ) {
                printf "%10s: %s\n", "revised", scalar( localtime $row{revisionDate} );
            }

            # Classname
            printf "%10s: %s\n", "class", $row{className};

            # Parent
            if ( my $parent = WebGUI::Asset->newByDynamicClass( $session, $row{parentId} ) ) {
                printf "%10s: %s (%s)\n", "parent", $parent->getTitle, $parent->getId;
            }
            elsif ( $session->db->quickScalar( "SELECT * FROM asset WHERE assetId=?", [$row{parentId}] ) ) {
                print "Parent corrupt ($row{parentId}).\n";
            }
            else {
                print "Parent missing ($row{parentId}).\n";
            }

            # More properties
            if ( $row{revisionDate} ) {
                my %assetData = $session->db->quickHash( "SELECT * FROM assetData WHERE assetId=? AND revisionDate=?",
                    [ @row{ "assetId", "revisionDate" } ] );
                for my $key (qw( title url )) {
                    printf "%10s: %s\n", $key, $assetData{$key};
                }
            }
            else {
                print "No current asset data.\n";
            }

            # Previous revisions
            my %lastRev 
                = $session->db->quickHash( 
                    "SELECT * FROM assetData WHERE assetId=? AND revisionDate != ? ORDER BY revisionDate DESC", 
                    [ $row{assetId}, $row{revisionDate} ]
                );
            if ( $lastRev{assetId} ) {
                print "Previous revision:\n";
                for my $key (qw( title url )) {
                    printf "%10s: %s\n", $key, $lastRev{$key};
                }
            }
            else {
                print "No previous revisions.\n";
            }


            # Asset History
            my $history = $session->db->buildArrayRefOfHashRefs(
                "SELECT * FROM assetHistory LEFT JOIN users USING (userId) WHERE assetId=? ORDER BY dateStamp DESC",
                [ $row{assetId} ],
            );
            if ( $history->[0] ) {
                my $username = $history->[0]{username} || "<Unknown User>";
                printf "Last action '%s'\n\tby %s\n\ton %s\n",
                    $history->[0]{actionTaken},
                    $username,
                    scalar( localtime $history->[0]{dateStamp} ),
                    ;
            }
        } ## end else [ if ($fix) ]

    } ## end if ( !$asset )
    progress( $total, $count++ ) unless $no_progress;
} ## end while ( my %row = $sth->hash)
$sth->finish;
$max_revision->finish;
print "\n";

my $shortcuts = $session->db->quickScalar($count_shortcut_sql, $sql_args);
if ($shortcuts) {
    print "Checking for broken shortcuts\n";
    use WebGUI::Asset::Shortcut;
    my $get_shortcut = WebGUI::Asset::Shortcut->getIsa($session, 0, {returnAll => 1});
    $count = 0;
    SHORTCUT: while (1) {
        my $shortcut = eval { $get_shortcut->() };
        if ( $@ || Exception::Class->caught() ) {
            ##Do nothing, since it would have been caught above
            printf "\r%-68s", "No shortcut to check";
        }
        elsif (!$shortcut) {
            last SHORTCUT
        }
        else {
            my $linked_asset = eval { WebGUI::Asset->newPending($session, $shortcut->get('shortcutToAssetId')); };
            if ( $@ || Exception::Class->caught() || ! $linked_asset ) {
                printf "\r%-68s", "-- Broken shortcut: ".$shortcut->getId.' pointing to '.$shortcut->get('shortcutToAssetId');
                if ($delete) {
                    my $success = $shortcut->purge;
                    if ($success) {
                        print "Purged shortcut";
                    }
                    else {
                        print "Could not purge shortcut";
                    }
                }
                print "\n";
            }
        }
        progress( $shortcuts, $count++ ) unless $no_progress;
    }
    progress( $shortcuts, $count ) unless $no_progress;
}

print "\n";

my $file_assets = $session->db->quickScalar($count_files_sql, $sql_args);
if ($file_assets) {
    print "Checking for broken File Assets\n";
    use WebGUI::Asset::File;
    my $get_asset = WebGUI::Asset::File->getIsa($session, 0, {returnAll => 1});
    $count = 0;
    FILE_ASSET: while (1) {
        my $file_asset = eval { $get_asset->() };
        if ( $@ || Exception::Class->caught() ) {
            ##Do nothing, since it would have been caught above
            printf "\r%-68s\n", "No asset to check";
        }
        elsif (!$file_asset) {
            last FILE_ASSET
        }
        else {
            my $storage = $file_asset->getStorageLocation;
            if (! $storage) {
                printf "\r%-s\n", "-- No storage location: ".$file_asset->getId." storageId: ".$file_asset->get('storageId');
            }
            else {
                my $file = $storage->getPath($file_asset->get('filename'));
                if (! -e $file) {
                    printf "\r%-s", "-- Broken file asset: ".$file_asset->getId." file does not exist: $file";
                    if ($delete) {
                        my $success = $file_asset->purge;
                        if ($success) {
                            print "Purged File Asset";
                        }
                        else {
                            print "Could not purge File Asset";
                        }
                    }
                    print "\n";
                }
            }
        }
        progress( $file_assets, $count++ ) unless $no_progress;
    }
    progress( $file_assets, $count ) unless $no_progress;
}

finish($session);
print "\n";

#----------------------------------------------------------------------------
# Your sub here

#-------------------------------------------------
sub readLines {
    my $file = shift;
    my @lines;
    if (open(my $fh, '<', $file)) {
        while (my $line = <$fh>) {
            $line =~ s/#.*//;
            $line =~ s/^\s+//;
            $line =~ s/\s+$//;
            next if !$line;
            push @lines, $line;
        }
        close $fh;
    }
    return @lines;
}


#----------------------------------------------------------------------------
sub start {
    my $webguiRoot = shift;
    my $configFile = shift;
    my $session    = WebGUI::Session->open( $webguiRoot, $configFile );
    $session->user( { userId => 3 } );
    return $session;
}

#----------------------------------------------------------------------------
sub finish {
    my $session = shift;
    $session->var->end;
    $session->close;
}

__END__


=head1 NAME

findBrokenAssets.pl -- Find and fix broken assets

=head1 SYNOPSIS

 findBrokenAssets.pl --configFile config.conf [--fix|--delete]

 utility --help

=head1 DESCRIPTION

This utility will find any broken assets that cannot be instantiated and are 
causing undesired operation of your website.  It also checks for these kinds of
semi-working assets and reports them:

=over 4

=item *

Shortcuts pointing to assets that don't exist.

=item *

File assets that have lost their files in the uploads area.

=back

It can also automatically delete them or fix them so you can restore missing data.

=head1 ARGUMENTS

=head1 OPTIONS

=over

=item B<--configFile config.conf>

The WebGUI config file to use. Only the file name needs to be specified,
since it will be looked up inside WebGUI's configuration directory.
This parameter is required.

=item B<--delete>

Delete any corrupted assets.

=item B<--fix>

Try to fix any corrupted assets.  The broken Shortcuts and File Assets cannot be fixed.

=item B<--assetId=s>

Limit the search for all broken assets to one assetId.

=item B<--help>

Shows a short summary and usage

=item B<--man>

Shows this document

=back

=head1 AUTHOR

Copyright 2001-2009 Plain Black Corporation.

=cut

#vim:ft=perl

