package WebGUI::Asset::Wobject::Gallery::Utility;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2005 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use Carp qw( carp croak );
use File::Find;
use Scalar::Util qw( blessed );
use WebGUI::Asset::Wobject::Collaboration;
use WebGUI::Asset::Wobject::Gallery;
use WebGUI::Asset::Post::Thread;
use WebGUI::Storage::Image;


=head1 NAME

WebGUI::Asset::Wobject::Gallery::Utility -- Utility functions for working
with Gallery assets.

=head1 DESCRIPTION

This module provides utility functions to work with Gallery assets from 
utility scripts.

This module is B<NOT> to be used by the Gallery asset itself!

=head1 SYNOPSIS

 use WebGUI::Asset::Wobject::Gallery::Utility;
 my $utility = "WebGUI::Asset::Wobject::Gallery::Utility" # <- not as cumbersome
 
 # Add albums from a collaboration system's threads
 my $gallery        = WebGUI::Asset::Wobject::Gallery->new( ... );
 my $collab         = WebGUI::Asset::Wobject::Collaboration->new( ... );
 $utility->addAlbumFromCollaboration( $gallery, $collab );

 # Add a single album from a collaboration system thread
 my $thread         = WebGUI::Asset::Post::Thread->new( ... );
 $utility->addAlbumFromThread( $gallery, $thread );

 # Add a single album from a filesystem branch
 $utility->addAlbumFromFilesystem( $gallery, "/Users/Doug/Photos" );

 # Add a single album for every folder in a filesystem branch
 $utility->addAlbumFromFilesystem( 
    $gallery, "/Users/Doug/Photos", 
    { 
        multiple    => 1,  
    } 
 );

=head1 METHODS

These methods are available from this class:

=cut

#----------------------------------------------------------------------------

=head2 addAlbumFromCollaboration ( gallery, collab )

Add an album or albums to the gallery from the given Collaboration System.
C<gallery> is an instanciated Gallery asset. C<collab> is an instanciated 
Collaboration System asset.

Will add one album for every thread in the Collaboration System. Will call 
C<addAlbumFromThread> to do its dirty work.

=cut

sub addAlbumFromCollaboration {
    my $class           = shift;
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
        $class->addAlbumFromThread( $gallery, $thread );
    }

    return;
}

#----------------------------------------------------------------------------

=head2 addAlbumFromFilesystem ( gallery, root [, options] )

Add an album to the gallery from the file system. C<gallery> is an 
instanciated Gallery asset. C<root> is a location on the file system.

C<options> is a hash reference of options with the following keys:

 multiple           - Create multiple albums, one for each folder.

=cut

sub addAlbumFromFilesystem {
    my $class           = shift;
    my $gallery         = shift;
    my $root            = shift;
    my $options         = shift;

    # TODO!!!

    return;
}

#----------------------------------------------------------------------------

=head2 addAlbumFromThread ( gallery, thread )

Add an album to the gallery from the given Collaboration System thread.
C<gallery> is an instanciated Gallery asset. C<thread> is an instanciated
Thread asset.

=cut

sub addAlbumFromThread {
    my $class           = shift;
    my $gallery         = shift;
    my $thread          = shift;
    
    croak "First argument must be Gallery asset"
        unless blessed $gallery && $gallery->isa('WebGUI::Asset::Wobject::Gallery');
    croak "Second argument must be Thread asset"
        unless blessed $thread && $thread->isa('WebGUI::Asset::Post::Thread');

    my $session         = $gallery->session;
    my $addOptions      = { skipAutoCommitWorkflows => 1 };

    # Get all the storage locations
    my @storageIds      = ();
    for my $post ( @{ $thread->getPosts } ) {
        if ( $post->get('storageId') ) {
            push @storageIds, $post->get('storageId');
        }
    }

    # Create the new album
    my $album = $gallery->addChild({
        className           => 'WebGUI::Asset::Wobject::GalleryAlbum',
        title               => $thread->get('title'),
        menuTitle           => $thread->get('menuTitle'),
        description         => $thread->get('bodyText'),
        synopsis            => $thread->get('synopsis'),
    }, undef, $thread->get('revisionDate'), $addOptions );

    # Add a new Photo asset for each photo in the storage locations
    for my $storageId ( @storageIds ) {
        # Use WebGUI::Storage::Image to avoid thumbnails if there
        my $storage     = WebGUI::Storage::Image->get( $session, $storageId );
        
        for my $filename ( @{$storage->getFiles} ) {
            my $className       = $gallery->getAssetClassForFile( $filename );
            if ( !$className ) {
                warn "Skipping $filename because Gallery doesn't handle this file type";
                next;
            }

            my $file = $album->addChild({
                className           => $className,
            }, undef, $thread->get('revisionDate'), $addOptions );

            $file->setFile( $storage->getPath( $filename ) );
        }
    }

    return;
}

1;
