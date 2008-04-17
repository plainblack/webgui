package WebGUI::Asset;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2008 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use File::Basename;
use File::Path;
use FileHandle;
use Path::Class;
use Scalar::Util 'looks_like_number';
use WebGUI::International;
use WebGUI::Exception;
use WebGUI::Session;
use URI::URL;

=head1 NAME

Package WebGUI::AssetExportHtml

=head1 DESCRIPTION

This is a mixin package for WebGUI::Asset that contains all exporting related
functions.

=head1 SYNOPSIS

 use WebGUI::Asset;

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 exportCheckPath ( session )

Class method. Tries very hard to ensure that exportPath is defined in the
configuration file, that it exists on the filesystem (creating any directories
necessary), and that the OS user running WebGUI can write to it. Throws an
appropriate exception on failure and returns a true value on success.

Takes the following parameters:

=head3 session

A reference to a L<WebGUI::Session> object.

Throws the following exceptions:

=head3 WebGUI::Error::InvalidParam

exportPath isn't defined in the configuration file.

=head3 WebGUI::Error

Encountered filesystem permission problems with the defined exportPath

=cut

sub exportCheckPath {
    my $class   = shift;
    my $session = shift;

    # make sure we were given the right parameters
    if(ref $session ne 'WebGUI::Session') {
        WebGUI::Error::InvalidObject->throw(error => "first param to exportCheckPath must be a WebGUI::Session");
    }

    my $exportPath = $session->config->get('exportPath');

    # first check that the path is defined in the config file and that it's not
    # an empty string
    if(!defined $exportPath || !$exportPath) {
        WebGUI::Error::InvalidObject->throw(error => 'exportPath must be defined and not ""');
    }

    # now that we know that it's defined and not an empty string, test if it exists.
    if(!-e $exportPath) {
        # it doesn't exist; let's try making it
        eval { mkpath( [$exportPath] ) };
        if($@) {
            WebGUI::Error->throw(error => "can't create exportPath $exportPath");
        }

        # the path didn't exist, and we succeeded creating it. Therefore we
        # know we can write to it and that it's an actual directory. Nothing
        # more left to do. indicate success to our caller.
        return 1;
    }

    # the path exists. make sure it's actually a directory.
    if(!-d $exportPath) {
        WebGUI::Error->throw(error => "$exportPath isn't a directory");
    }

    # the path is defined, isn't an empty string, exists on disk as a
    # directory. let's make sure we have the appropriate permissions. On Unix
    # systems, we need to be able to write to the directory to create files and
    # directories beneath it, and we need to be able to 'execute' the directory
    # to list files in it. and of course we need to be able to read it too.
    # check for all of these.
    if(! (-w $exportPath) || ! (-x _) || ! (-r _) ) {
        WebGUI::Error->throw(error => "can't access $exportPath");
    }

    # everything checks out, return 1
    return 1;
}

#-------------------------------------------------------------------

=head2 exportAsHtml ( params )

Main logic hub for export functionality. This method calls most of the rest of
the methods that handle exporting. Any exceptions thrown by the called methods
are returned as strings to the caller. Returns a status description upon
completion. Takes a hashref of arguments, containing the following keys:

=head3 quiet

Boolean. To be or not to be quiet with our output. Defaults to false.

=head3 userId

The WebGUI user ID as which to perform the export. Note that this user must be
able to view the assets which you want to export (i.e.,
C<$asset->canView($userId)>, or this will return a permissions error.

If given a L<WebGUI::User> object as a userId, will use that, but you didn't just read
that.

=head3 indexFileName

The file name to give to page layout and similar index files. Typically
C<index.html>, and also the default.

=head3 extrasUploadAction

A string, either 'symlink' or something false, describing what to do with the
C<extras> and C<uploads> directories. If 'symlink', will symlink the site's
directories into the exported content. If false, will do nothing.

=head3 rootUrlAction

The same as for C<extrasUploadAction>, where 'symlink' will make a symlink and
false will do nothing.

=cut

# the general flow here works like this:
#   1. make sure the export path is valid
#   2. construct the list of assets for exporting
#   3. for each asset, check that the user can view the asset. skip it if we can't.
#   4. for each asset, check if it's exportable. skip it if it isn't.
#   5. for each asset, write its contents to disk, making all the required
#      paths beforehand
#   6. handle symlinking if required  

sub exportAsHtml {
    my $self                = shift;
    my $session             = $self->session;
    my ($returnCode, $message);

    # get the i18n object
    my $i18n = WebGUI::International->new($self->session, 'Asset');

    # take down when we started to tell the user how long the process took.
    my $startTime           = $session->datetime->time;

    # before even looking at the parameters, make sure the exportPath is valid.
    eval { WebGUI::Asset->exportCheckPath($session) };

    # something went wrong. we don't really care what at this point. we did
    # everything we could to try to make exporting possible and we failed. give
    # up.
    if($@) {
        $returnCode         = 0;
        $message            = $@;
        return ($returnCode, $message);
    }

    # if we're still here, then the exportPath is valid.
    my $exportPath          = $session->config->get('exportPath');

    # get parameters
    my $args                = shift;
    my $quiet               = $args->{quiet};
    my $userId              = $args->{userId};
    my $depth               = $args->{depth};
    my $indexFileName       = $args->{indexFileName};
    my $extrasUploadAction  = $args->{extrasUploadAction};
    my $rootUrlAction       = $args->{rootUrlAction};

    # if we're doing symlinking of the root URL, then the current default asset
    # is the root of the tree. take down that asset ID so we can pass it to
    # exportSymlinkRoot later.
    my $defaultAssetId      = $self->session->setting->get('defaultPage');
    my $defaultAsset        = WebGUI::Asset->newByDynamicClass($session, $defaultAssetId);

    my @extraUploadActions  = qw/ symlink none /;
    my @rootUrlActions      = qw/ symlink none /;

    # verify them
    if(!defined $userId) {
        $returnCode = 0;
        $message    = 'need a userId parameter';
        return ($returnCode, $message);
    }

    # we take either a numeric userId or a WebGUI::User object
    if( ref $userId ne 'WebGUI::User' && !looks_like_number($userId) ) {
        $returnCode = 0;
        $message    = "'$userId' is not a valid userId";
        return ($returnCode, $message);
    }

    # depth is required.
    if(!defined $depth) {
        $returnCode = 0;
        $message    = 'need a depth';
        return ($returnCode, $message);
    }
    # and it must be a number.
    if( !looks_like_number($depth) ) {
        $returnCode = 0;
        $message    = "'$depth' is not a valid depth";
        return ($returnCode, $message);
    }

    # extrasUploadAction and rootUrlAction must have values matching something
    # in the arrays defined above
    if( defined $extrasUploadAction && !isIn($extrasUploadAction, @extraUploadActions) ) {
        $returnCode = 0;
        $message    = "'$extrasUploadAction' is not a valid extrasUploadAction";
        return ($returnCode, $message);
    }

    if( defined $rootUrlAction && !isIn($rootUrlAction, @rootUrlActions) ) {
        $returnCode = 0;
        $message    = "'$rootUrlAction' is not a valid rootUrlAction";
        return ($returnCode, $message);
    }

    # the export path is valid. the params are good. let's get started. first,
    # we need to get the assets that we'll be exporting. exportGetDescendants
    # takes a WebGUI::User object, so give it one.
    my $user;
    if(ref $userId ne 'WebGUI::User') {
        $user       = WebGUI::User->new($session, $userId);
    }
    else {
        $user       = $userId;
    }

    my $assetIds    = $self->exportGetDescendants($user, $depth);

    # now, create a new session as the user doing the exports. this is so that
    # the exported assets are taken from that user's perspective.
    my $exportSession = WebGUI::Session->open($self->session->config->getWebguiRoot, $self->session->config->getFilename);
    $exportSession->user( { userId => $userId } );

    # make sure this user can view the top level asset we're exporting. if not,
    # don't do anything.
    unless ( $self->canView($userId) ) {
        $returnCode = 0;
        $message    = "can't view asset at URL " . $self->getUrl;
        return ($returnCode, $message);
    }

    my $exportedCount = 0;
    foreach my $assetId ( @{$assetIds} ) {
        my $asset       = WebGUI::Asset->newByDynamicClass($exportSession, $assetId);
        my $fullPath    = $asset->exportGetUrlAsPath; 

        # skip this asset if we can't view it as this user.
        unless( $asset->canView($userId) ) {
            if( !$quiet ) {
                my $message = sprintf( $i18n->get('bad user privileges') . "\n") . $asset->getUrl;
                $self->session->output->print($message);
            }
            next;
        }

        # skip this asset if it's not exportable.
        unless ( $asset->exportCheckExportable ) {
            if( !$quiet ) {
                $self->session->output->print("$fullPath skipped, not exportable<br />");
            }
            next;
        }

        # tell the user which asset we're exporting.
        unless ($quiet) {
            my $message = sprintf $i18n->get('exporting page'), $fullPath;
            $self->session->output->print($message);
        }

        # try to write the file
        eval { $asset->exportWriteFile };
        if($@) {
            $returnCode = 0;
            $message    = $@;
            $self->session->output->print("could not export asset with URL " . $asset->getUrl . ": $@");
            return ($returnCode, $message);
        }

        # next, tell the asset that we're exporting, so that it can export any
        # of its collateral or other extra data.
        eval { $asset->exportAssetCollateral($asset->exportGetUrlAsPath, $args) };
        if($@) {
            $returnCode = 0;
            $message    = $@;
            $self->session->output->print("failed to export asset collateral for URL " . $asset->getUrl . ": $@");
            return ($returnCode, $message);
        }

        # we exported this one successfully, so count it
        $exportedCount++;

        # track when this asset was last exported for external caching and the like
        $session->db->write( "UPDATE asset SET lastExportedAs = ? WHERE assetId = ?",
            [ $fullPath, $asset->getId ] );

        # tell the user we did this asset correctly
        unless( $quiet ) {
            $session->output->print($i18n->get('done'));
        }
    }
    
    # handle symlinking
    if($extrasUploadAction eq 'symlink') {
        eval { WebGUI::Asset->exportSymlinkExtrasUploads($session) };
        if ($@) {
            $returnCode = 0;
            $message    = $@;
            return ($returnCode, $message);
        }
    }

    if($rootUrlAction eq 'symlink') {
        eval { WebGUI::Asset->exportSymlinkRoot($session, $defaultAsset, $indexFileName, $quiet) };
        if ($@) {
            $returnCode = 0;
            $message    = $@;
            return ($returnCode, $message);
        }
    }

    # we don't need the session any more, so close it.
    $exportSession->var->end;
    $exportSession->close;

    # we're done. give the user a status report.
    $returnCode = 1;
    my $timeRequired = $session->datetime->time - $startTime;
    $message = sprintf $i18n->get('export information'), $exportedCount, $timeRequired;
    return ($returnCode, $message);
}

#-------------------------------------------------------------------

=head2 exportAssetCollateral ( basePath, params )

Plug in point for complicated assets (like the CS, the Calendar) to manage
exporting their collateral data like other views, children threads and posts,
and the like. The base method in WebGUI::Asset doesn't do anything. This method
will be called from L</exportAsHtml> after L</exportWriteFile>, so any
exceptions that occur during this process will be separate from those that
occur during writing of the parent asset.

This method will be called with the following parameters:

=head3 basePath

A L<Path::Class> object representing the base filesystem path for this
particular asset.

=head3 params

A hashref with the quiet, userId, depth, and indexFileName parameters from
L</exportAsHtml>.

=cut

sub exportAssetCollateral {
}

#-------------------------------------------------------------------

=head2 exportCheckExportable ( )

Determines whether this asset is exportable, first by checking whether all of
its parents are exportable and then by checking the asset itself. Returns a
boolean indicating whether or not this asset is exportable.

=cut

sub exportCheckExportable {
    my $self = shift;

    # get this asset's ancestors. return objects as a shortcut since we'd be
    # instantiating them all anyway.
    my $assets = $self->getLineage( ['ancestors'], { returnObjects => 1 } );

    # process each one. return false if any of the assets in the lineage, or
    # this asset itself, isn't exportable.
    foreach my $asset ( @{$assets}, $self ) {
        return 0 unless $asset->get('isExportable');
    }

    # passed checks, return 1
    return 1;
}

#-------------------------------------------------------------------

=head2 exportGetDescendants ( user, depth )

Gets the descendants of this asset for exporting, walking the lineage as the
user specified. Takes the following parameters:

=head3 userId

The WebGUI user ID as which to do the export. 

=head3 depth

The depth to pass to getLineage. How many levels in the lineage to go.

Throws the following exceptions:

=head3 WebGUI::Error::InvalidObject

The given WebGUI user is not valid.

=head3 WebGUI::Error::InvalidParam

The value given for depth is invalid.

=cut

sub exportGetDescendants {
    my $self    = shift;
    my $user    = shift;
    my $depth   = shift;

    # check for parameter validity
    if( (!defined $user) or (ref $user ne 'WebGUI::User') ) {
        WebGUI::Error::InvalidObject->throw(
            expected => 'WebGUI::User', 
            got => ref $user, 
            error => 'Need a WebGUI::User object', 
            param => $user
        );
    }

    if( (!defined $depth) or (!looks_like_number($depth)) ) {
        WebGUI::Error::InvalidParam->throw(error => 'Need a depth', param => $depth);
    }

    # open a temporary session as the user doing the exporting so we don't get
    # assets that they can't see
    my $tempSession = WebGUI::Session->open($self->session->config->getWebguiRoot,$self->session->config->getFilename);
    $tempSession->user( { userId => $user->userId } );

    # clone self in the new session and get its lineage as the new user
    my $cloneOfSelf = WebGUI::Asset->new($tempSession, $self->getId, $self->get('className'), $self->get('revisionDate'));
    my $assetIds    = $cloneOfSelf->getLineage( [ "self", "descendants" ], { 
            endingLineageLength => $cloneOfSelf->getLineageLength + $depth,
            orderByClause       => 'assetData.url DESC',
    } );

    # properly close the temp session
    $tempSession->var->end;
    $tempSession->close;

    return $assetIds;
}

#-------------------------------------------------------------------

=head2 exportGetUrlAsPath ( index )

Translates a URL into an appropriate path and filename for exporting. For
example, given C<'/foo/bar/baz'>, will return C<'/foo/bar/baz/index.html'>
provided the value of indexFile as given to exportAsHtml was C<'index.html'>.

=head3 url 

URL of the asset we need an export path for

=head3 index

index filename passed from L</exportAsHtml>

=cut

sub exportGetUrlAsPath {
    my $self            = shift;
    my $index           = shift || 'index.html';

    my $config          = $self->session->config;

    # make sure that the export path is valid
    WebGUI::Asset->exportCheckPath($session);

    # if we're still here, it's valid. get it.
    my $exportPath      = $config->get('exportPath');
    
    # specify a list of file types apache recognises to be passed through as-is
    my @fileTypes = qw/.html .htm .txt .pdf .jpg .css .gif .png .doc .xls .xml
    .rss .bmp .mp3 .js .fla .flv .swf .pl .php .php3 .php4 .php5 .ppt .docx
    .zip .tar .rar .gz .bz2/;

    # get the asset's URL as a URI::URL object for easy parsing of components
    my $url             = URI::URL->new($config->get("sitename")->[0] . $self->getUrl);
    my @pathComponents  = $url->path_components;
    shift @pathComponents; # first item is the empty string
    my $filename        = pop @pathComponents; 

    # if there's no . (i.e., no file with an extension) in $filename, this is
    # simple. Slap on a directory separator, $index, and return it.
    if(!index $filename, '.') { # no need to regex match for a single character
        return Path::Class::File->new($exportPath, @pathComponents, $filename, $index);
    }
    else { # got a dot
        my $extension = (fileparse($filename, qr/\.[^.]*/))[2]; # get just the extension
        
        # check if the file type is recognised by apache. if it is, return it
        # as-is. if not, slap on the directory separator, $index, and return
        # it.
        if( isIn($extension, @fileTypes) ) {
            return Path::Class::File->new($exportPath, @pathComponents, $filename);
        }
        else { # don't know what it is
            return Path::Class::File->new($exportPath, @pathComponents, $filename, $index);
        }
    }
}

#-------------------------------------------------------------------

=head2 exportSymlinkExtrasUploads ( session )

Class method. Sets up the extras and uploads symlinks.

Takes the following parameters:

=head3 session

A reference to a L<WebGUI::Session> object.

Throws the following exceptions:

=head3 WebGUI::Error

Encountered a filesystem error in setting up the links.

=head3 WebGUI::InvalidObject

The first parameter is not a L<WebGUI::Session>.

=cut

sub exportSymlinkExtrasUploads {
    my $class       = shift;
    my $session     = shift;

    # check that session is a valid WebGUI::Session object
    if(!defined $session || ref $session ne 'WebGUI::Session') {
        WebGUI::Error::InvalidObject->throw(error => "first param to exportSymlinkExtrasUploads must be a WebGUI::Session");
    }

    my $config      = $session->config;
    my $extrasPath  = $config->get('extrasPath');
    my $extrasUrl   = $config->get('extrasURL');
    my $uploadsPath = $config->get('uploadsPath');
    my $uploadsUrl  = $config->get('uploadsURL');

    # we have no assurance whether the exportPath is valid or not, so check it.
    WebGUI::Asset->exportCheckPath($session);
    
    # if we're still here, it's valid
    my $exportPath  = $config->get('exportPath');

    # chop off leading / so we don't accidentally get absolute paths
    for my $url ($extrasUrl, $uploadsUrl) {
        s#^/*##;
    }

    # construct the destination paths
    my $extrasDst   = Path::Class::File->new($exportPath, $extrasUrl)->absolute->stringify;
    my $uploadsDst  = Path::Class::File->new($exportPath, $uploadsUrl)->absolute->stringify;

    # for each of extras and uploads, do the following:
    # check of the destination path exists and is a symlink
    # if it is, assume it's from a prior exporting and remove it
    # if that doesn't work, throw an exception
    # if that does work, symlink the on-disk path to the destination
    # if that doesn't work, throw an exception

    foreach my $rec ([$extrasPath, $extrasDst], [$uploadsPath, $uploadsDst]) {
        my ($source, $destination) = @{$rec};
        if (-l $destination) {
            next if (readlink $destination eq $source);
            unlink $destination or WebGUI::Error->throw(error => "could not unlink $destination: $!");
        }

        # the path holding the symlinks is the export path, which exists at
        # this point
        symlink $source, $destination or WebGUI::Error->throw(error => "could not symlink $source, $destination: $!");
    }
}

#-------------------------------------------------------------------

=head2 exportSymlinkRoot ( session, defaultAsset, [indexFile], [quiet] )

Class method. Places a symlink in the exportPath linking to the index file of
the default asset.

Takes the following parameters:

=head3 session

A reference to a L<WebGUI::Session> object.

Throws the following exceptions:

=head3 defaultAsset

The path to this asset's exported location on disk will be the target of the
symlink for the root URL.

=head3 indexFile

Optional. Specifies a file name for the index URL. Defaults to C<index.html>.

=head3 quiet

Optional. Whether to be quiet with our output.

=head3 WebGUI::Error

Encountered a filesystem error in setting up the link.

=head3 WebGUI::InvalidObject

The first parameter is not a L<WebGUI::Session>.

=cut

sub exportSymlinkRoot {
    my $class           = shift;

    my $session         = shift;
    my $defaultAsset    = shift;
    my $index           = shift || 'index.html';
    my $quiet           = shift;

    # check that $session is valid
    if(!defined $session || ref $session ne 'WebGUI::Session') {
        WebGUI::Error::InvalidObject->throw(error => 'first param to exportSymlinkRoot must be a WebGUI::Session');
    }

    # check that $defaultAsset is valid
    if( !defined $defaultAsset || !$defaultAsset->isa('WebGUI::Asset') ) {
        WebGUI::Error::InvalidParam->throw(error => 'second param to exportSymlinkRoot must be the default asset', param => $defaultAsset);
    }

    # can't be sure if the export path exists, so check it.
    WebGUI::Asset->exportCheckPath($session);

    # if we're still here, it's valid, so get it
    my $exportPath      = $session->config->get('exportPath');

    # get the source and the destination
    my $source          = $defaultAsset->exportGetUrlAsPath->absolute->stringify;
    my $destination     = Path::Class::File->new($exportPath, $index)->absolute->stringify;

    my $i18n            = WebGUI::International->new($session, 'Asset');

    # tell the user what's happening
    if( !$quiet ) {
        my $message     = $i18n->get('rootUrl symlinking default') . "\n";
        $session->output->print($message);
    }

    # if the link exists, check if it's set up properly. if it's not, remove it.
    if (-l $destination) {
        return if readlink $destination eq $source;
        unlink $destination or WebGUI::Error->throw(error => sprintf($i18n->get('could not unlink'), $destination, $!));
    }
    symlink $source, $destination or WebGUI::Error->throw(error => sprintf($i18n->get('could not symlink'), $source, $destination, $!));
}

#-------------------------------------------------------------------

=head2 exportWriteFile ( )

Creates required directories, gathers the content for this particular exported
file, and writes that content to disk. 

Throws the following exceptions:

=head3 WebGUI::Error

Insufficient privileges for writing to the FS path as this OS user, or
insufficient viewing privileges for the asset.

=cut

sub exportWriteFile {
    my $self = shift;

    # we have no assurance whether the exportPath is valid or not, so check it.
    WebGUI::Asset->exportCheckPath($self->session);

    # if we're still here, everything is well with the export path. let's make
    # sure that this user can view the asset that we want to export.
    unless($self->canView) {
        WebGUI::Error->throw(error => "user can't view asset at " .  $self->getUrl . " to export it");
    }


    # if we're still here, everything is well with the export path. let's get
    # our destination FS path and then make any required directories.

    my $dest = $self->exportGetUrlAsPath;
    my $parent = $dest->parent;

    eval { mkpath($parent->absolute->stringify) };
    if($@) {
        WebGUI::Error->throw(error => "could not make directory " . $parent->absolute->stringify);
    }

    # next, get the contents, open the file, and write the contents to the file.
    my $fh = eval { $dest->openw };
    if($@) {
        WebGUI::Error->throw(error => "can't open " . $dest->absolute->stringify . " for writing: $!");
    }
    my $previousHandle = $self->session->{_handle};
    my $previousDefaultAsset = $self->session->asset;
    $self->session->asset($self);
    $self->session->output->setHandle($fh);
    my $contents = $self->exportHtml_view;

    # chunked content is already printed, no need to print it again
    unless($contents eq 'chunked') {
        $self->session->output->print($contents);
    }

    $self->session->output->setHandle($previousHandle);
}

#-------------------------------------------------------------------

=head2 exportHtml_view ( )

View method for static export.  This is like www_view, and defaults to
just calling www_view, but this needs to be overridden if www_view
depends on there being an actual HTTP response on the other end.

=cut

sub exportHtml_view {
    my $self = shift;
    $self->www_view(@_);
}

#-------------------------------------------------------------------

=head2 www_export

Displays the export page administrative interface

=cut

sub www_export {
    my $self    = shift;
    return $self->session->privilege->insufficient() unless ($self->session->user->isInGroup(13));
    my $i18n    = WebGUI::International->new($self->session, "Asset");
    my $f       = WebGUI::HTMLForm->new($self->session, -action => $self->getUrl);
    $f->hidden(
        -name           => "func",
        -value          => "exportStatus"
    );
    $f->integer(
        -label          => $i18n->get('Depth'),
        -hoverHelp      => $i18n->get('Depth description'),
        -name           => "depth",
        -value          => 99,
    );
    $f->selectBox(
        -label          => $i18n->get('Export as user'),
        -hoverHelp      => $i18n->get('Export as user description'),
        -name           => "userId",
        -options        => $self->session->db->buildHashRef("select userId, username from users"),
        -value          => [1],
    );
    $f->text(
        -label          => $i18n->get("directory index"),
        -hoverHelp      => $i18n->get("directory index description"),
        -name           => "index",
        -value          => "index.html"
    );

    # TODO: maybe add copy options to these boxes alongside symlink
    $f->selectBox(
        -label          => $i18n->get('extrasUploads form label'),
        -hoverHelp      => $i18n->get('extrasUploads form hoverHelp'),
        -name           => "extrasUploadsAction",
        -options        => { 
            'symlink'   => $i18n->get('extrasUploads form option symlink'),
            'none'      => $i18n->get('extrasUploads form option none') },
        -value          => ['none'],
    );
    $f->selectBox(
        -label          => $i18n->get('rootUrl form label'),
        -hoverHelp      => $i18n->get('rootUrl form hoverHelp'),
        -name           => "rootUrlAction",
        -options        => {
            'symlink'   => $i18n->get('rootUrl form option symlinkDefault'),
            'none'      => $i18n->get('rootUrl form option none') },
        -value          => ['none'],
    );
    $f->submit;
    my $message;
    eval { WebGUI::Asset->exportCheckPath($self->session) };
    if($@) {
        $message = $@;
    }
    $self->getAdminConsole->render($message . $f->print, $i18n->get('Export Page'));
}


#-------------------------------------------------------------------

=head2 www_exportStatus

Displays the export status page

=cut

sub www_exportStatus {
    my $self        = shift;
    return $self->session->privilege->insufficient() unless ($self->session->user->isInGroup(13));
    my $i18n        = WebGUI::International->new($self->session, "Asset");
    my $iframeUrl   = $self->getUrl('func=exportGenerate');
    foreach my $formVar (qw/index depth userId extrasUploadsAction rootUrlAction/) {
        $iframeUrl  = $self->session->url->append($iframeUrl, $formVar . '=' . $self->session->form->process($formVar));
    }

    my $output      = '<iframe src="' . $iframeUrl . '" title="' . $i18n->get('Page Export Status') . '" width="700" height="500"></iframe>';
    $self->getAdminConsole->render($output, $i18n->get('Page Export Status'), "Asset");
}

#-------------------------------------------------------------------

=head2 www_exportGenerate

Executes the export process and displays real time status. This operation is displayed by exportStatus in an IFRAME.

=cut

# This routine is called in an IFRAME and prints status output directly to the browser.

sub www_exportGenerate {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->session->user->isInGroup(13));

    # Unbuffered data output
    $|++;
    $self->session->style->useEmptyStyle(1);
    $self->session->http->sendHeader;

    my $i18n = WebGUI::International->new($self->session, 'Asset');
    my ($success, $description) = $self->exportAsHtml( {
        quiet               => 0,
        userId              => $self->session->form->process('userId'),
        indexFileName       => $self->session->form->process('index'),
        extrasUploadAction  => $self->session->form->process('extrasUploadsAction'),
        rootUrlAction       => $self->session->form->process('rootUrlAction'),
        depth               => $self->session->form->process('depth'),
    });
    if (!$success) {
        $self->session->output->print($description, 1);
        return "chunked";
    }

    $self->session->output->print($description, 1);
    $self->session->output->print('<a target="_parent" href="' . $self->getUrl . '">' . $i18n->get(493, 'WebGUI') . '</a>');
    return "chunked";
}

1;
