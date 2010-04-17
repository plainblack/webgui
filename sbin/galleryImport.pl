#!/usr/bin/env perl

# -------------------------------------------------------------------
#  WebGUI is Copyright 2001-2009 Plain Black Corporation.
# -------------------------------------------------------------------
#  Please read the legal notices (docs/legal.txt) and the license
#  (docs/license.txt) that came with this distribution before using
#  this software.
# -------------------------------------------------------------------
#  http://www.plainblack.com                     info@plainblack.com
# -------------------------------------------------------------------

use strict;
use File::Basename ();
use File::Spec;

my $webguiRoot;
BEGIN {
    $webguiRoot = File::Spec->rel2abs(File::Spec->catdir(File::Basename::dirname(__FILE__), File::Spec->updir));
    unshift @INC, File::Spec->catdir($webguiRoot, 'lib');
}

$|=1;
use Carp qw( carp croak );
use File::Find;
use Getopt::Long;
use Pod::Usage;
use Scalar::Util qw( blessed );
use WebGUI::Paths -inc;
use WebGUI::Asset::Wobject::Collaboration;
use WebGUI::Asset::Wobject::GalleryAlbum;
use WebGUI::Asset::Wobject::Gallery;
use WebGUI::Asset::Wobject::Folder;
use WebGUI::Asset::Post::Thread;
use WebGUI::Storage;

$|=1;

# custom flags
my ($fromAssetId, $fromPath, $fromAssetUrl, $toId, $toUrl) = undef;
my $tags = [];

# init
my $session = start();

# load gallery
my $gallery = undef;
if (defined $toId) {
    $gallery = WebGUI::Asset::Wobject::Gallery->new($session, $toId);
}
else { 
    $gallery = WebGUI::Asset::Wobject::Gallery->newByUrl($session, $toUrl);
}
if ( $gallery && $gallery->isa('WebGUI::Asset::Wobject::Gallery') ) {
    # import from
    if (defined $fromPath) {
        if (-d $fromPath) {
            addAlbumFromFilesystem($gallery,$fromPath);
        }
        else {
            pod2usage("$0: You must specify a valid directory to import from.");
        }
    }
    else {
        my $fromAsset = undef;
        if (defined $fromAssetId) {
            $fromAsset = WebGUI::Asset->newByDynamicClass($session, $fromAssetId);
        }
        else {
            $fromAsset = WebGUI::Asset->newByUrl($session, $fromAssetUrl);
        }
        if ($fromAsset && $fromAsset->isa("WebGUI::Asset::Wobject::Folder")) {
            addAlbumFromFolder($gallery, $fromAsset);
        }
        elsif ($fromAsset && $fromAsset->isa("WebGUI::Asset::Wobject::Collaboration")) {
            addAlbumFromCollaboration($gallery, $fromAsset);
        }
        elsif ($fromAsset && $fromAsset->isa("WebGUI::Asset::Post::Thread")) {
            addAlbumFromThread($gallery, $fromAsset);
        }
        else {
            pod2usage("$0: You must specify a valid asset to import from.");
        }
    }
}
else {
    pod2usage("$0: You must specify a gallery asset to import into.");
}

# cleanup
finish($session);

#----------------------------------------------------------------------------
# addAlbumFromCollaboration ( gallery, collab )
#
# Add an album or albums to the gallery from the given Collaboration System.
# gallery is an instanciated Gallery asset. collab is an instanciated 
# Collaboration System asset.
#
# Will add one album for every thread in the Collaboration System. Will call 
# addAlbumFromThread to do its dirty work.

sub addAlbumFromCollaboration {
    my $gallery         = shift;
    my $collab          = shift;

    croak "First argument must be Gallery asset"
        unless blessed $gallery && $gallery->isa('WebGUI::Asset::Wobject::Gallery');
    croak "Second argument must be Collaboration System asset"
        unless blessed $collab && $collab->isa('WebGUI::Asset::Wobject::Collaboration');

    my $threads         
        = $collab->getLineage(['descendants'], {
            returnObjects           => 1,
            includeOnlyClasses      => ['WebGUI::Asset::Post::Thread'],
            statesToInclude         => ['published'],
            statusToInclude         => ['approved', 'archived', 'pending'],
        });

    for my $thread ( @$threads ) {
        addAlbumFromThread( $gallery, $thread );
    }

    return undef;
}

#----------------------------------------------------------------------------
# addAlbumFromFilesystem ( gallery, root )
#
# Add an album to the gallery from the file system. gallery is an 
# instanciated Gallery asset. root is a location on the file system.

sub addAlbumFromFilesystem {
    my $gallery         = shift;
    my $root            = shift;

    croak "First argument must be Gallery asset"
        unless blessed $gallery && $gallery->isa('WebGUI::Asset::Wobject::Gallery');
    croak "Second argument must be a path to a folder on the filesystem"
        unless -d $root;

    # define the import process
    my $recurseFilesystem = sub {
        if (-d $File::Find::name) {
            # find photos
            print "Searching ".$File::Find::name." for photos.\n";
            my @photos = ();
            if (opendir my $folder, $File::Find::name) {
                my @files = readdir $folder;
                closedir $folder; 
                foreach my $file (@files) {
                    unless (-d $File::Find::name."/".$file) {
                        if ($file =~ m/\.(jpg|gif|png|jpeg)$/i) {
                            push(@photos, $file);
                        }
                    }
                } 
            }  

            # import if we found anything
            if (scalar(@photos)) {
                # get album name
                my $albumName = $File::Find::name;
                $albumName =~ s{.*\/([A-Za-z0-9\.-_'\,\s]+)$}{$1}; 

                # create album
                print "Creating album $albumName\n";
                my $addOptions      = { skipAutoCommitWorkflows => 1 };
                my $album = $gallery->addChild({
                    className           => 'WebGUI::Asset::Wobject::GalleryAlbum',
                    menuTitle           => $albumName,
                    title               => $albumName,
                    url                 => $gallery->get('url') . "/" . $albumName,
                    keywords            => $tags,
                    }, undef, undef, $addOptions );

                # do the import
                print "\tImporting ".scalar(@photos)." files from ".$File::Find::name." into album called ".$albumName.".\n";
                foreach my $filename (@photos) {
                    print "\t\t".$filename."\n";
                    my $className       = $gallery->getAssetClassForFile( $filename );
                    if ( !$className ) {
                        warn "Skipping $filename because Gallery doesn't handle this file type";
                        next;
                    }
                    my ($title)  = $filename =~ m{(.*)\.[^.]*$};
                    my $asset = $album->addChild({
                        className           => $className,
                        menuTitle           => $title,
                        title               => $title,
                        url                 => $album->get('url') . "/" . $title,
                        keywords            => $tags,
                        }, undef, undef, $addOptions );
                    $asset->setFile( $File::Find::name."/".$filename );
                }
            }
        } 
    };

    # run the search and import process
    File::Find::find({wanted=>$recurseFilesystem,no_chdir=>1} , $root);

    return undef;
}

#----------------------------------------------------------------------------
# addAlbumFromFolder ( gallery, folder )
#
# Add an album from a Folder asset filled with File assets. gallery is an 
# instance of a Gallery asset. folder is an instance of a Folder asset.

sub addAlbumFromFolder {
    my $gallery         = shift;
    my $folder          = shift;

    croak "First argument must be Gallery asset"
        unless blessed $gallery && $gallery->isa('WebGUI::Asset::Wobject::Gallery');
    croak "Second argument must be Folder asset"
        unless blessed $folder && $folder->isa('WebGUI::Asset::Wobject::Folder');

    my $session         = $gallery->session;
    my $addOptions      = { skipAutoCommitWorkflows => 1 };

    # Create the new album
    my $album = $gallery->addChild({
        className           => 'WebGUI::Asset::Wobject::GalleryAlbum',
        description         => $folder->get('description'),
        menuTitle           => $folder->get('menuTitle'),
        createdBy           => $folder->get('createdBy'),
        creationDate        => $folder->get('creationDate'),
        ownerUserId         => $folder->get('ownerUserId'),
        synopsis            => $folder->get('synopsis'),
        title               => $folder->get('title'),
        keywords            => $tags,
        url                 => $gallery->get('url') . "/" . $folder->get('title'),
    }, undef, $folder->get('revisionDate'), $addOptions );

    my $fileIds 
        = $folder->getLineage( ['children'], {
            joinClass   => 'WebGUI::Asset::File',
        } );

    for my $fileId ( @{ $fileIds } ) {
        my $oldFile     = WebGUI::Asset->newByDynamicClass( $session, $fileId );
        my $oldStorage  = $oldFile->getStorageLocation;
        my $className   = $gallery->getAssetClassForFile( $oldStorage->getPath( $oldFile->get('filename') ) );
        if ( !$className ) {
            warn "Skipping " . $oldFile->get('filename') . " Gallery doesn't handle this file type";
            next;
        }

        my $newFile = $album->addChild({
            className           => $className,
            createdBy           => $oldFile->get('createdBy'),
            creationDate        => $oldFile->get('creationDate'),
            menuTitle           => $oldFile->get('menuTitle'),
            ownerUserId         => $oldFile->get('ownerUserId'),
            synopsis            => $oldFile->get('synopsis'),
            keywords            => $tags,
            title               => $oldFile->get('title'),
            url                 => $album->get('url') . "/" . $oldFile->get('menuTitle'),
        }, undef, $oldFile->get('revisionDate'), $addOptions );

        $newFile->setFile( $oldStorage->getPath( $oldFile->get('filename') ) );
    }

    return undef;
}

#----------------------------------------------------------------------------
# addAlbumFromThread ( gallery, thread )
#
# Add an album to the gallery from the given Collaboration System thread.
# gallery is an instanciated Gallery asset. thread is an instanciated
# Thread asset.

sub addAlbumFromThread {
    my $gallery         = shift;
    my $thread          = shift;
    
    croak "First argument must be Gallery asset"
        unless blessed $gallery && $gallery->isa('WebGUI::Asset::Wobject::Gallery');
    croak "Second argument must be Thread asset"
        unless blessed $thread && $thread->isa('WebGUI::Asset::Post::Thread');

    my $session         = $gallery->session;
    my $addOptions      = { skipAutoCommitWorkflows => 1 };

    # Create the new album
    my $album = $gallery->addChild({
        className           => 'WebGUI::Asset::Wobject::GalleryAlbum',
        description         => $thread->get('content'),
        menuTitle           => $thread->get('menuTitle'),
        createdBy           => $thread->get('createdBy'),
        creationDate        => $thread->get('creationDate'),
        ownerUserId         => $thread->get('ownerUserId'),
        synopsis            => $thread->get('synopsis'),
        keywords            => $tags,
        title               => $thread->get('title'),
        url                 => $gallery->get('url') . "/" . $thread->get('title'),
        userDefined1        => $thread->get('userDefined1'),
        userDefined2        => $thread->get('userDefined2'),
        userDefined3        => $thread->get('userDefined3'),
        userDefined4        => $thread->get('userDefined4'),
        userDefined5        => $thread->get('userDefined5'),
    }, undef, $thread->get('revisionDate'), $addOptions );

    for my $post ( @{ $thread->getPosts } ) {
        if ( my $storageId = $post->get('storageId') ) {
            # Use WebGUI::Storage to avoid thumbnails if there
            my $storage     = WebGUI::Storage->get( $session, $storageId );
            
            for my $filename ( @{$storage->getFiles} ) {
                my $className       = $gallery->getAssetClassForFile( $filename );
                if ( !$className ) {
                    warn "Skipping $filename because Gallery doesn't handle this file type";
                    next;
                }

                # Get rid of that file extention
                my ($title)  = $filename =~ m{(.*)\.[^.]*$};
                
                # Don't repeat the thread
                my $synopsis 
                    = $post->get('content') ne $thread->get('content') 
                    ? $post->get('content')
                    : undef
                    ;

                my $file = $album->addChild({
                    className           => $className,
                    createdBy           => $post->get('createdBy'),
                    creationDate        => $post->get('creationDate'),
                    menuTitle           => $title,
                    ownerUserId         => $post->get('ownerUserId'),
                    synopsis            => $synopsis,
                    title               => $title,
                    url                 => $album->get('url') . "/" . $title,
                    keywords            => $tags,
                    userDefined1        => $post->get('userDefined1'),
                    userDefined2        => $post->get('userDefined2'),
                    userDefined3        => $post->get('userDefined3'),
                    userDefined4        => $post->get('userDefined4'),
                    userDefined5        => $post->get('userDefined5'),
                }, undef, $post->get('revisionDate'), $addOptions );

                $file->setFile( $storage->getPath( $filename ) );
            }
        }
    }

    return undef;
}

#----------------------------------------------------------------------------
sub finish {
    my $session = shift;

    my $versionTag = WebGUI::VersionTag->getWorking($session);
    $versionTag->commit;

    $session->var->end;
    $session->close;
}


#----------------------------------------------------------------------------
sub start {
    $| = 1; #disable output buffering
    my ($configFile, $help);
    GetOptions(
        'configFile=s'      => \$configFile,
        'help'              => \$help,
        'tags=s{1,10}'      => $tags,
        'toUrl=s'           => \$toUrl,
        'fromAssetUrl=s'    => \$fromAssetUrl,
        'toId=s'            => \$toId,
        'fromAssetId=s'     => \$fromAssetId,
        'fromPath=s'        => \$fromPath,
    );

    # Show usage
    if ($help) {
        pod2usage( verbose => 2);
    }

    unless ($configFile) {
        pod2usage("$0: Must specify a --configFile");
    }

    my $session = WebGUI::Session->open($configFile);
    $session->user({userId=>3});

    my $versionTag = WebGUI::VersionTag->getWorking($session);
    $versionTag->set({name => 'Import Albums into Gallery'});

    return $session;
}

__END__

=head1 NAME

galleryImport.pl - Import media into a Gallery asset from various sources.

=head1 SYNOPSIS

 perl galleryImport.pl --configFile=www.example.com.conf --fromAssetId=XXXXXXXXXXXXXXXXXXXXXX --toId=XXXXXXXXXXXXXXXXXXXXXX

 perl galleryImport.pl --help

=head1 DESCRIPTION

This WebGUI utility script imports files from the filesystem, and other assets
into a Gallery asset. It automatically generates thumbnails and metadata just
as if the files were uploaded through the user interface.

Files with JPG, JPEG, GIF, and PNG extensions are supported.

The thumbnails are created using L<Image::Magick> for image transformations.

Exactly one --from* and exactly one --to* parameter are required.

=over

=item B<--configFile filename>

Specify the config file name of the site you wish to perform this import on.

=item B<--fromAssetId assetId>

Specify the asset id of an asset to import the files from. The asset type is
automatically discerned.

The supported asset types are Collaboration System, Thread, and Folder.

=item B<--fromAssetUrl url>

Specify the URL of an asset to import the files from. The asset type is
automatically discerned. The B<url> is the Asset URL parameter, not a fully 
qualified URL.

The supported asset types are Collaboration System, Thread, and Folder.

=item B<--fromPath path>

Specify the absolute B<path> to a folder containing folders images and other
folders with images. The folder name is used to create an album name, and the
files contained in the folder are added as photos in the folder.

=item B<--help>

Shows this documentation, then exits.

=item B<--tags keyword keyword keyword>

Attach keyword tags to the photos and albums created. One to 10 keywords may 
be specified. You may specify multi-word tags by wrapping them in quotes.

Eg: --tags=green old "very expensive"

=item B<--toId assetId>

Specify the B<assetId> of the Gallery to create albums in.

=item B<--toUrl url>

Specify the B<url> of the Gallery to create albums in. The URL is the asset
URL parameter of the Gallery, and not the fully qualified URL.

=back

=head1 AUTHOR

Copyright 2001-2009 Plain Black Corporation.

=cut


