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

our ( $configFile, $help, $man, $fix, $delete, $no_progress );
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

my $totalAsset      = $session->db->quickScalar('SELECT COUNT(*) FROM asset');
my $totalAssetData  = $session->db->quickScalar('SELECT COUNT( DISTINCT( assetId ) ) FROM assetData' );
my $total   = $totalAsset >= $totalAssetData ? $totalAsset : $totalAssetData;

# Order by lineage to put corrupt parents before corrupt children
# Join assetData to get all asset and assetData
my $sql   = "SELECT * FROM asset LEFT JOIN assetData USING ( assetId ) GROUP BY assetId ORDER BY lineage ASC";
my $sth   = $session->db->read($sql);

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
            unless ( $asset && WebGUI::Asset->newByDynamicClass( $session, $row{parentId} ) ) {
                $asset->setParent( WebGUI::Asset->getImportNode( $session ) );
                print "\tNOTE: Invalid parent. Asset moved to Import Node\n";
            }
            if (!$asset) {
                print "\tWARNING.  Asset is still broken.\n";
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

my $shortcuts = $session->db->quickScalar(q!select count(*) from asset where className='WebGUI::Asset::Shortcut'!);
if ($shortcuts) {
    print "Checking for broken shortcuts\n";
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
                if ($fix || $delete) {
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
causing undesired operation of your website.

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

Try to fix any corrupted assets.

=item B<--help>

Shows a short summary and usage

=item B<--man>

Shows this document

=back

=head1 AUTHOR

Copyright 2001-2009 Plain Black Corporation.

=cut

#vim:ft=perl

