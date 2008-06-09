#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

our ($webguiRoot);

BEGIN {
    $webguiRoot = "..";
    unshift (@INC, $webguiRoot."/lib");
}

use strict;
use Getopt::Long;
use Pod::Usage;
use WebGUI::Utility::Gallery;
use WebGUI::Session;

my $session = start();

my $collab      = getCollaborationFromArgs();
my $gallery     = getGalleryFromArgs();

WebGUI::Utility::Gallery->addAlbumFromCollaboration( $gallery, $collab );

finish($session);

#----------------------------------------------------------------------------
# getCollaborationFromArgs
# Gets the collaboration system from the arguments. The argument can be 
# either an assetId or an absolute URL
sub getCollaborationFromArgs {
    my $asset;
    my $arg     = $ARGV[0];
    if ( $arg =~ m{^/} ) {
        $asset      = WebGUI::Asset->newByUrl( $session, $arg );
    }
    else {
        $asset      = WebGUI::Asset->newByDynamicClass( $session, $arg );
    }

    unless ( $asset && $asset->isa('WebGUI::Asset::Wobject::Collaboration') ) {
        pod2usage("$0: First argument must be a Collaboration asset");
    }

    return $asset;
}

#----------------------------------------------------------------------------
# getGalleryFromArgs
# Gets the Gallery from the arguments. The argument can be either an assetId
# or an absolute URL
sub getGalleryFromArgs {
    my $asset;
    my $arg     = $ARGV[1];
    if ( $arg =~ m{^/} ) {
        $asset      = WebGUI::Asset->newByUrl( $session, $arg );
    }
    else {
        $asset      = WebGUI::Asset->newByDynamicClass( $session, $arg );
    }
    
    unless ( $asset && $asset->isa('WebGUI::Asset::Wobject::Gallery') ) {
        pod2usage("$0: Second argument must be a Gallery asset");
    }

    return $asset;
}

#----------------------------------------------------------------------------
sub start {
    $| = 1; #disable output buffering
    my ($configFile, $help);
    GetOptions(
        'configFile=s'  => \$configFile,
        'help'          => \$help,
    );

    # Show usage
    if ($help) {
        pod2usage( verbose => 2);
    }
    
    unless ($configFile) {
        pod2usage("$0: Must specify a --configFile");
    }

    my $session = WebGUI::Session->open($webguiRoot,$configFile);
    $session->user({userId=>3});
    
    my $versionTag = WebGUI::VersionTag->getWorking($session);
    $versionTag->set({name => 'Migrate Collaboration to Gallery'});
    
    return $session;
}

#----------------------------------------------------------------------------
sub finish {
    my $session = shift;
    
    my $versionTag = WebGUI::VersionTag->getWorking($session);
    $versionTag->commit;
    
    $session->var->end;
    $session->close;
}

__END__

=head1 NAME

migrateCollabToGallery -- Migrate a collaboration system into a Gallery

=head1 SYNOPSIS

migrateCollabToGallery --configFile config.conf collab gallery

migrateCollabToGallery --help

=head1 DESCRIPTION

This WebGUI utility script migrates a collaboration system's threads
into gallery albums. It uses B<WebGUI::Utility::Gallery> for its major
features.

=over

=item B<--configFile config.conf>

The WebGUI config file to use. Only the file name needs to be specified,
since it will be looked up inside WebGUI's configuration directory.
This parameter is required.

=item B<collab>

A WebGUI's Collaboration System URL or Asset ID. If an URL is given,
it must be an absolute URL beginning with a slash.

=item B<gallery>

A WebGUI's Gallery URL or Asset ID. If an URL is given, it must be
an absolute URL beginning with a slash.

=item B<--help>

Shows this documentation, then exits.

=back

=head1 AUTHOR

Copyright 2001-2008 Plain Black Corporation.

=cut
