
use lib "../lib";
use strict;
use Getopt::Long;
use Pod::Usage;
use WebGUI::Utility::Gallery;
use WebGUI::Session;

my $session = start();

my $folder      = getFolderFromArgs();
my $gallery     = getGalleryFromArgs();

WebGUI::Utility::Gallery->addAlbumFromFolder( $gallery, $folder );

finish($session);

#----------------------------------------------------------------------------
# getFolderFromArgs
# Gets the folder from the arguments. The argument can be 
# either an assetId or an absolute URL
sub getFolderFromArgs {
    my $asset;
    my $arg     = $ARGV[0];
    if ( $arg =~ m{^/} ) {
        $asset      = WebGUI::Asset->newByUrl( $session, $arg );
    }
    else {
        $asset      = WebGUI::Asset->newByDynamicClass( $session, $arg );
    }

    unless ( $asset && $asset->isa('WebGUI::Asset::Wobject::Folder') ) {
        pod2usage("$0: First argument must be a Folder asset");
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
        pod2usage(1);
    }
    
    unless ($configFile) {
        pod2usage("$0: Must specify a --configFile");
    }

    my $session = WebGUI::Session->open("..",$configFile);
    $session->user({userId=>3});
    
    my $versionTag = WebGUI::VersionTag->getWorking($session);
    $versionTag->set({name => 'Migrate Folder to Gallery'});
    
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


=head1 NAME

migrateFolderToGallery.pl -- Migrate a Folder into a Gallery

=head1 SYNOPSIS

migrateFolderToGallery.pl --configFile=<config> <folder> <gallery>

=head1 ARGUMENTS

=over

=item folder 

A Folder URL or asset ID. The URL must be an absolute URL, and
so must begin with a "/".

=item gallery 

A Gallery URL or asset ID. The URL must be an absolute URL, and so much begin
with a "/".

=back

=head1 OPTIONS

=over

=item configFile

The WebGUI config file to use.

=back

=head1 DESCRIPTION

This script migrates a Folder into a gallery album. It
uses C<WebGUI::Utility::Gallery> for its major features.


