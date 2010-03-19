package WebGUI::Asset;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use File::Path ();
use Path::Class ();
use Scalar::Util qw(looks_like_number);
use WebGUI::International;
use WebGUI::Exception;
use WebGUI::Utility ();
use WebGUI::Session;
use URI::URL ();
use Scope::Guard;

=head1 NAME

Package WebGUI::Asset (AssetExportHtml)

=head1 DESCRIPTION

This is a mixin package for WebGUI::Asset that contains all exporting related
functions.

=head1 SYNOPSIS

 use WebGUI::Asset;

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 exportCheckPath ( [session] )

Class or object method. Tries very hard to ensure that exportPath is defined in the
configuration file, that it exists on the filesystem (creating any directories
necessary), and that the OS user running WebGUI can write to it. Throws an
appropriate exception on failure and returns a the export path as a L<Path::Class::Dir>
object on success.

Takes the following parameters:

=head3 session

A reference to a L<WebGUI::Session> object.  Should only be specified if called as a class method.

Throws the following exceptions:

=head3 WebGUI::Error::InvalidParam

exportPath isn't defined in the configuration file.

=head3 WebGUI::Error

Encountered filesystem permission problems with the defined exportPath

=cut

sub exportCheckPath {
    my $class   = shift;
    my $session;
    if (ref $class && $class->can('session')) {
        $session = $class->session;
    }
    else {
        $session = shift;
        # make sure we were given the right parameters
        if((!ref $session) || !$session->isa('WebGUI::Session')) {
            WebGUI::Error::InvalidObject->throw(error => "first param to exportCheckPath as a class method must be a WebGUI::Session");
        }
    }
    my $exportPath = $session->style->useMobileStyle ? $session->config->get('mobileExportPath')
                                                     : $session->config->get('exportPath');

    # first check that the path is defined in the config file and that it's not
    # an empty string
    if (!defined $exportPath || !$exportPath) {
        WebGUI::Error::InvalidObject->throw(error => 'exportPath must be defined and not ""');
    }
    $exportPath = Path::Class::Dir->new($exportPath);

    # now that we know that it's defined and not an empty string, test if it exists.
    if (!-e $exportPath) {
        # it doesn't exist; let's try making it
        eval { $exportPath->mkpath };
        if($@) {
            WebGUI::Error->throw(error => "can't create exportPath $exportPath");
        }

        # the path didn't exist, and we succeeded creating it. Therefore we
        # know we can write to it and that it's an actual directory. Nothing
        # more left to do. indicate success to our caller.
        return $exportPath;
    }

    # the path exists. make sure it's actually a directory.
    if (!-d $exportPath) {
        WebGUI::Error->throw(error => "$exportPath isn't a directory");
    }

    # the path is defined, isn't an empty string, exists on disk as a
    # directory. let's make sure we have the appropriate permissions. On Unix
    # systems, we need to be able to write to the directory to create files and
    # directories beneath it, and we need to be able to 'execute' the directory
    # to list files in it. and of course we need to be able to read it too.
    # check for all of these.
    if (! (-w $exportPath && -x _ && -r _) ) {
        WebGUI::Error->throw(error => "can't access $exportPath");
    }

    # everything checks out, return path
    return $exportPath;
}

#-------------------------------------------------------------------

=head2 exportAsHtml ( params )

Main logic hub for export functionality. This method calls most of the rest of
the methods that handle exporting. Any exceptions thrown by the called methods
are returned as strings to the caller. Returns a status description upon
completion.

Internally, it sets two scratch variables in private sessions that it creates
for exporting.

=over 4

=item exportMode

If this scratch variable exists, and is true, then the Asset is being exported.

=item exportUrl

This scratch variable is used by the Widget Macro.

=back

Takes a hashref of arguments, containing the following keys:

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
    my $args                = shift;
    my $session             = $self->session;

    # get the i18n object
    my $i18n = WebGUI::International->new($self->session, 'Asset');

    # take down when we started to tell the user how long the process took.
    my $startTime           = $session->datetime->time;

    # get the export path and ensure it is valid.
    my $exportPath          = $self->exportCheckPath;

    # get parameters
    my $quiet               = $args->{quiet};
    my $userId              = $args->{userId};
    my $depth               = $args->{depth};
    my $indexFileName       = $args->{indexFileName};
    my $extrasUploadAction  = $args->{extrasUploadAction};
    my $rootUrlAction       = $args->{rootUrlAction};
    my $exportUrl           = $args->{exportUrl};

    my @extraUploadActions  = qw/ symlink none /;
    my @rootUrlActions      = qw/ symlink none /;

    # verify them
    if (!defined $userId) {
        WebGUI::Error->throw(error => $i18n->get('need a userId parameter'));
    }

    # we take either a numeric userId or a WebGUI::User object
    my $user;
    if ( ref $userId && $userId->isa('WebGUI::User') ) {
        $user = $userId;
    }
    elsif ( looks_like_number($userId) || $session->id->valid($userId) ) {
        $user = WebGUI::User->new($session, $userId);
    }
    if (! defined $user) {
        WebGUI::Error->throw(error => "'$userId' ".$i18n->get('is not a valid userId'));
    }
    $userId = $user->userId;

    # depth is required.
    if(! defined $depth) {
        WebGUI::Error->throw(error => $i18n->get('need a depth'));
    }
    # and it must be a number.
    if( !looks_like_number($depth) ) {
        WebGUI::Error->throw(error => sprintf $i18n->get('%s is not a valid depth'), $depth);
    }

    # extrasUploadAction and rootUrlAction must have values matching something
    # in the arrays defined above
    if( defined $extrasUploadAction && !WebGUI::Utility::isIn($extrasUploadAction, @extraUploadActions) ) {
        WebGUI::Error->throw(error => "'$extrasUploadAction' is not a valid extrasUploadAction");
    }

    if( defined $rootUrlAction && !WebGUI::Utility::isIn($rootUrlAction, @rootUrlActions) ) {
        WebGUI::Error->throw(error => "'$rootUrlAction' is not a valid rootUrlAction");
    }

    unless ( $self->canView($userId) ) {
        WebGUI::Error->throw(error => "can't view asset at URL " . $self->getUrl);
    }

    # now, create a new session as the user doing the exports. this is so that
    # the exported assets are taken from that user's perspective.
    my $exportSession = WebGUI::Session->open(
        $session->config->getWebguiRoot,
        $session->config->getFilename,
    );
    my $esGuard = Scope::Guard->new(sub {
        $exportSession->var->end;
        $exportSession->close;
    });

    $exportSession->user( { userId => $userId } );

    # set a scratch variable for Assets and widgets to know we're exporting
    $exportSession->scratch->set('isExporting', 1);
    $exportSession->scratch->set('exportUrl',   $exportUrl);
    $exportSession->style->setMobileStyle(0);

    my $asset = WebGUI::Asset->newById(
        $exportSession,
        $self->getId,
        $self->get('revisionDate'),
    );

    # pass in reporting session unless we're in quiet mode
    my $exportedCount = $asset->exportBranch( $args, $quiet ? () : $session );

    if ($session->config->get('mobileExportPath')) {
        $exportSession->style->setMobileStyle(1);

        # pass in reporting session unless we're in quiet mode
        $exportedCount += $asset->exportBranch( $args, $quiet ? () : $session );
    }

    # we're done. give the user a status report.
    my $timeRequired = $session->datetime->time - $startTime;
    my $message = sprintf $i18n->get('export information'), $exportedCount, $timeRequired;
    return $message;
}

sub exportBranch {
    my $self = shift;
    my $options = shift;
    my $reportSession = shift;

    my $depth               = $options->{depth};
    my $indexFileName       = $options->{indexFileName};
    my $extrasUploadAction  = $options->{extrasUploadAction};
    my $rootUrlAction       = $options->{rootUrlAction};

    my $i18n;
    if ( $reportSession ) {
        $i18n = WebGUI::International->new($self->session, 'Asset');
    }

    my $exportedCount = 0;
    my $assetIds = $self->exportGetDescendants(undef, $depth);
    foreach my $assetId ( @{$assetIds} ) {
        # Must be created once for each asset, since session is supposed to only handle
        # one main asset
        my $outputSession = $self->session->duplicate;
        my $osGuard = Scope::Guard->new(sub {
            $outputSession->close;
        });

        my $asset       = WebGUI::Asset->newById($outputSession, $assetId);
        my $fullPath    = $asset->exportGetUrlAsPath;

        # skip this asset if we can't view it as this user.
        unless( $asset->canView ) {
            if( $reportSession ) {
                my $message = sprintf( $i18n->get('bad user privileges') . "\n") . $asset->getUrl;
                $reportSession->output->print($message);
            }
            next;
        }

        # skip this asset if it's not exportable.
        unless ( $asset->exportCheckExportable ) {
            if ( $reportSession ) {
                $reportSession->output->print("$fullPath skipped, not exportable<br />");
            }
            next;
        }

        # tell the user which asset we're exporting.
        if ( $reportSession ) {
            my $message = sprintf $i18n->get('exporting page'), $fullPath;
            $reportSession->output->print($message);
        }

        # try to write the file
        eval { $asset->exportWriteFile };
        if( $@ ) {
            WebGUI::Error->throw(error => "could not export asset with URL " . $asset->getUrl . ": $@");
        }

        # next, tell the asset that we're exporting, so that it can export any
        # of its collateral or other extra data.
        eval { $asset->exportAssetCollateral($asset->exportGetUrlAsPath, $options, $reportSession) };
        if($@) {
            WebGUI::Error->throw(error => "failed to export asset collateral for URL " . $asset->getUrl . ": $@");
        }

        # we exported this one successfully, so count it
        $exportedCount++;

        # track when this asset was last exported for external caching and the like
        $self->session->db->write( "UPDATE asset SET lastExportedAs = ? WHERE assetId = ?",
            [ $fullPath, $asset->getId ] );

        $self->updateHistory("exported");

        # tell the user we did this asset correctly
        if ( $reportSession ) {
            $reportSession->output->print($i18n->get('done'));
        }
    }

    # handle symlinking
    if ($extrasUploadAction eq 'symlink') {
        $self->exportSymlinkExtrasUploads;
    }

    if ($rootUrlAction eq 'symlink') {
        my $defaultAsset = WebGUI::Asset->getDefault($self->session);
        $self->exportSymlinkRoot($defaultAsset, $indexFileName, $reportSession);
    }
    return $exportedCount;
}

#-------------------------------------------------------------------

=head2 exportAssetCollateral ( basePath, params, [ session ] )

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

=head3 session

The session doing the full export.  Can be used to report status messages.

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

=head3 user

The WebGUI user object as which to do the export.  If not specified, uses the current user.

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

    # use current session by default
    my $session = $self->session;
    my $asset = $self;
    my $sGuard;

    # check for parameter validity
    if( (!defined $depth) or (!looks_like_number($depth)) ) {
        WebGUI::Error::InvalidParam->throw(error => 'Need a depth', param => $depth);
    }

    if ( defined $user ) {
        # open a temporary session as the user doing the exporting so we don't get
        # assets that they can't see
        if ( ref $user && $user->isa('WebGUI::User') ) {
            $session = WebGUI::Session->open(
                $session->config->getWebguiRoot,
                $session->config->getFilename,
            );
            $session->user( { userId => $user->userId } );
            $sGuard = Scope::Guard->new(sub {
                $session->var->end;
                $session->close;
            });
            # clone self in the new session
            $asset = WebGUI::Asset->newById(
                $session,
                $self->getId,
                $self->get('revisionDate'),
            );
        }
        else {
            WebGUI::Error::InvalidObject->throw(
                expected => 'WebGUI::User',
                got => ref $user,
                error => 'Need a WebGUI::User object',
                param => $user,
            );
        }
    }

    my $assetIds = $asset->getLineage( [ "self", "descendants" ], { 
        endingLineageLength => $asset->getLineageLength + $depth,
        orderByClause       => 'assetData.url DESC',
    } );

    return $assetIds;
}

#-------------------------------------------------------------------

=head2 exportGetUrlAsPath ( index )

Translates a URL into an appropriate path and filename for exporting. For
example, given C<'/foo/bar/baz'>, will return C<'/foo/bar/baz/index.html'>
provided the value of indexFile as given to exportAsHtml was C<'index.html'>.

Returns a Path::Class::File object.

=head3 url 

URL of the asset we need an export path for

=head3 index

index filename passed from L</exportAsHtml>

=cut

sub exportGetUrlAsPath {
    my $self            = shift;
    my $index           = shift || 'index.html';
    my $options         = shift || {};

    my $config          = $self->session->config;

    # make sure that the export path is valid
    my $exportPath = $self->exportCheckPath;

    # get a list of file types to pass through as-is
    my $fileTypes       = $config->get('exportBinaryExtensions');

    # get the asset's URL as a URI::URL object for easy parsing of components
    my $url = $self->get('url');

    # for either a sub page or extension, remove the existing extension
    if ($options->{subPage} || $options->{extension}) {
        $url =~ s/\.[^.]+$//;
    }
    if ($options->{extension}) {
        my $ext = $options->{extension};
        $ext =~ s/^\.//;
        $url .= ".$ext";
    }
    if ($options->{subPage}) {
        my $subPage = $options->{subPage};
        $subPage =~ s{^/}{};
        $url .= "/$subPage";
    }
    $url = URI::URL->new($self->session->url->gateway($url));
    my @pathComponents  = $url->path_components;
    shift @pathComponents; # first item is the empty string
    my $filename        = pop @pathComponents; 

    my ($extension) = $filename =~ /\.([^.]+)$/;
    if ($extension && WebGUI::Utility::isIn($extension, @{ $fileTypes }) ) {
        return Path::Class::File->new($exportPath, @pathComponents, $filename);
    }
    else {
        return Path::Class::File->new($exportPath, @pathComponents, $filename, $index);
    }
}

#-------------------------------------------------------------------

=head2 exportSymlinkExtrasUploads ( [ session ] )

Class or object method. Sets up the extras and uploads symlinks.

Takes the following parameters:

=head3 session

A reference to a L<WebGUI::Session> object.  Should only be specified if caled as a class method.

Throws the following exceptions:

=head3 WebGUI::Error

Encountered a filesystem error in setting up the links.

=head3 WebGUI::InvalidObject

The first parameter is not a L<WebGUI::Session>.

=cut

sub exportSymlinkExtrasUploads {
    my $class       = shift;
    my $session;
    if (ref $class && $class->can('session')) {
        $session = $class->session;
    }
    else {
        $session = shift;
        # make sure we were given the right parameters
        if((!ref $session) || !$session->isa('WebGUI::Session')) {
            WebGUI::Error::InvalidObject->throw(error => "first param to exportSymlinkExtrasUploads as a class method must be a WebGUI::Session");
        }
    }

    my $config      = $session->config;
    my $extrasPath  = $config->get('extrasPath');
    my $extrasUrl   = $session->url->make_urlmap_work($config->get('extrasURL'));
    my $uploadsPath = $config->get('uploadsPath');
    my $uploadsUrl  = $session->url->make_urlmap_work($config->get('uploadsURL'));

    # we have no assurance whether the exportPath is valid or not, so check it.
    my $exportPath = WebGUI::Asset->exportCheckPath($session);

    # chop off leading / so we don't accidentally get absolute paths
    for my $url ($extrasUrl, $uploadsUrl) {
        $url =~ s{^/*}{};
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

=head2 exportSymlinkRoot ( [session,] defaultAsset, [indexFile], [reportSession] )

Class method. Places a symlink in the exportPath linking to the index file of
the default asset.

Takes the following parameters:

=head3 session

A reference to a L<WebGUI::Session> object.  Should only be specified if called as a class method.

Throws the following exceptions:

=head3 defaultAsset

The path to this asset's exported location on disk will be the target of the
symlink for the root URL.

=head3 indexFile

Optional. Specifies a file name for the index URL. Defaults to C<index.html>.

=head3 reportSession

Optional. If included, status information will be printed to this session.

=head3 WebGUI::Error

Encountered a filesystem error in setting up the link.

=head3 WebGUI::InvalidObject

The first parameter is not a L<WebGUI::Session>.

=cut

sub exportSymlinkRoot {
    my $class           = shift;
    my $session;
    if (ref $class && $class->can('session')) {
        $session = $class->session;
    }
    else {
        $session = shift;
        # make sure we were given the right parameters
        if((!ref $session) || !$session->isa('WebGUI::Session')) {
            WebGUI::Error::InvalidObject->throw(error => "first param to exportSymlinkRoot as a class method must be a WebGUI::Session");
        }
    }

    my $defaultAsset    = shift;
    my $index           = shift || 'index.html';
    my $reportSession   = shift;

    # check that $defaultAsset is valid
    if( !defined $defaultAsset || !$defaultAsset->isa('WebGUI::Asset') ) {
        WebGUI::Error::InvalidParam->throw(error => 'second param to exportSymlinkRoot must be the default asset', param => $defaultAsset);
    }

    # can't be sure if the export path exists, so check it.
    my $exportPath = WebGUI::Asset->exportCheckPath($session);

    # get the source and the destination
    my $source          = $defaultAsset->exportGetUrlAsPath->absolute->stringify;
    my $destination     = Path::Class::File->new($exportPath, $index)->absolute->stringify;

    my $i18n            = WebGUI::International->new($session, 'Asset');

    # tell the user what's happening
    if ( $reportSession ) {
        my $message     = $i18n->get('rootUrl symlinking default') . "\n";
        $reportSession->output->print($message);
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
    $self->exportCheckPath;

    # if we're still here, everything is well with the export path. let's make
    # sure that this user can view the asset that we want to export.
    unless($self->canView) {
        WebGUI::Error->throw(error => "user can't view asset at " .  $self->getUrl . " to export it");
    }

    # if we're still here, everything is well with the export path. let's get
    # our destination FS path and then make any required directories.
    my $dest = $self->exportGetUrlAsPath;
    my $parent = $dest->parent;

    eval { $parent->absolute->mkpath };
    if($@) {
        WebGUI::Error->throw(error => "could not make directory " . $parent->absolute->stringify);
    }

    # next, get the contents, open the file, and write the contents to the file.
    my $fh = eval { $dest->open('>:utf8') };
    if($@) {
        WebGUI::Error->throw(error => "can't open " . $dest->absolute->stringify . " for writing: $!");
    }
    $self->session->asset($self);
    $self->session->output->setHandle($fh);
    my $contents = $self->exportHtml_view;

    # chunked content is already printed, no need to print it again
    unless($contents eq 'chunked') {
        $self->session->output->print($contents);
    }
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

    $f->text(
        -label          => $i18n->get("Export site root URL"),
        -name           => 'exportUrl',
        -value          => '',
        -hoverHelp      => $i18n->get("Export site root URL description"),
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
    eval { $self->exportCheckPath };
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
    foreach my $formVar (qw/index depth userId extrasUploadsAction rootUrlAction exportUrl/) {
        $iframeUrl  = $self->session->url->append($iframeUrl, $formVar . '=' . $self->session->form->process($formVar));
    }

    my $output      = '<iframe src="' . $iframeUrl . '" title="' . $i18n->get('Page Export Status') . '" width="100%" height="500"></iframe>';
    $self->getAdminConsole->render($output, $i18n->get('Page Export Status'), "Asset");
}

#-------------------------------------------------------------------

=head2 www_exportGenerate

Executes the export process and displays real time status. This operation is displayed by exportStatus in an IFRAME.

=cut

# This routine is called in an IFRAME and prints status output directly to the browser.

sub www_exportGenerate {
    my $self = shift;
    my $session = $self->session;
    return $session->privilege->insufficient
        unless $session->user->isInGroup(13);

    # Unbuffered data output
    $|++;
    $session->style->useEmptyStyle(1);
    $session->http->sendHeader;
    my $splitter = $self->getSeparator;
    my $style = $session->style->process($splitter);
    my ($head, $foot) = split /\Q$splitter/, $style;
    $session->output->print($head, 1);

    my $i18n = WebGUI::International->new($session, 'Asset');
    my $args = {
        quiet               => 0,
        userId              => $session->form->process('userId'),
        indexFileName       => $session->form->process('index'),
        extrasUploadAction  => $session->form->process('extrasUploadsAction'),
        rootUrlAction       => $session->form->process('rootUrlAction'),
        depth               => $session->form->process('depth'),
        exportUrl           => $session->form->process('exportUrl'),
    };
    eval {
        my $message = $self->exportAsHtml( $args );
        $self->session->output->print($message, 1);
        $self->session->output->print(
            '<a target="_parent" href="' . $self->getUrl . '">' . $i18n->get(493, 'WebGUI') . '</a>'
        );
    };
    if ($@) {
        $self->session->output->print("$@", 1);
    }
    $session->output->print($foot, 1);
    return "chunked";
}

1;
