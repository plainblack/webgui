package WebGUI::Test;

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

=head1 NAME

Package WebGUI::Test

=head1 DESCRIPTION

Utility module for making testing in WebGUI easier.

=cut


use strict;
use warnings;
use Clone qw/clone/;
use Test::MockObject;

our ( $SESSION, $WEBGUI_ROOT, $CONFIG_FILE, $WEBGUI_LIB, $WEBGUI_TEST_COLLATERAL );

use Config     qw[];
use IO::Handle qw[];
use File::Spec qw[];
use IO::Select qw[];
use Cwd        qw[];
use Test::MockObject::Extends;
use WebGUI::PseudoRequest;
use Scalar::Util qw( blessed );
use List::MoreUtils qw/ any /;
use Carp qw[ carp croak ];
use JSON qw( from_json to_json );

##Hack to get ALL test output onto STDOUT.
use Test::Builder;
sub import {
    no warnings;
    *Test::Builder::failure_output = sub { return \*STDOUT };
}

our $logger_warns;
our $logger_debug;
our $logger_info;
our $logger_error;

my %originalConfig;
my $originalSetting;

my @assetsToPurge;
my @groupsToDelete;
my @usersToDelete;
my @sessionsToDelete;
my @storagesToDelete;
my @tagsToRollback;
my @workflowsToDelete;

my $smtpdPid;
my $smtpdStream;
my $smtpdSelect;

my $mocker;

BEGIN {

#----------------------------------------------------------------------------

=head2 sessionsToDelete ( $session, [$session, ...] )

Push a list of session objects onto the stack of groups to be automatically deleted
at the end of the test.  Note, this will be the last group of objects to be
cleaned up.

This is a class method.

=cut

sub sessionsToDelete {
    my $class = shift;
    push @sessionsToDelete, @_;
}


sub newSession {
    my $pseudoRequest = WebGUI::PseudoRequest->new;
    my $session = WebGUI::Session->open( $WEBGUI_ROOT, $CONFIG_FILE );
    $session->{_request} = $pseudoRequest;
    WebGUI::Test->sessionsToDelete($session);
    return $session;
}

}

BEGIN {

    $mocker = Test::MockObject->fake_module(
        'APR::Request::Apache2',
        handle => sub { return bless {}, 'APR::Request::Apache2'; }, 
        jar    => sub { return { }; },
    );

    STDERR->autoflush(1);

    $CONFIG_FILE = $ENV{ WEBGUI_CONFIG };

    unless ( defined $CONFIG_FILE ) {
        warn qq/Enviroment variable WEBGUI_CONFIG must be set to the full path to a WebGUI config file.\n/;
        exit(1);
    }
   
    unless ( $CONFIG_FILE ) {
        warn qq/Enviroment variable WEBGUI_CONFIG must not be empty.  It must be set to the full path of a WebGUI config file.\n/;
        exit(1);
    }

    unless ( -e $CONFIG_FILE ) {
        warn qq/WEBGUI_CONFIG path '$CONFIG_FILE' does not exist.\n/;
        exit(1);
    }

    unless ( -f _ ) {
        warn qq/WEBGUI_CONFIG path '$CONFIG_FILE' is not a file.\n/;
        exit(1);
    }

    unless ( -r _ ) {
        warn qq/WEBGUI_CONFIG path '$CONFIG_FILE' is not readable by effective uid '$>'.\n/;
        exit(1);
    }

    $WEBGUI_ROOT = $CONFIG_FILE;
    
    # convert to absolute path
    unless ( File::Spec->file_name_is_absolute($WEBGUI_ROOT) ) {
        $WEBGUI_ROOT = File::Spec->rel2abs($WEBGUI_ROOT);
    }

    $CONFIG_FILE = ( File::Spec->splitpath( $WEBGUI_ROOT ) )[2];
    $WEBGUI_ROOT = substr( $WEBGUI_ROOT, 0, index( $WEBGUI_ROOT, File::Spec->catdir( 'etc', $CONFIG_FILE ) ) );
    $WEBGUI_ROOT = File::Spec->canonpath($WEBGUI_ROOT);
    $WEBGUI_ROOT = Cwd::realpath($WEBGUI_ROOT);
    $WEBGUI_TEST_COLLATERAL = File::Spec->catdir($WEBGUI_ROOT, 't', 'supporting_collateral');

    my ($volume,$directories) = File::Spec->splitpath( $WEBGUI_ROOT, 'no_file' );
    $WEBGUI_LIB ||= File::Spec->catpath( $volume, $directories, 'lib' );

    push (@INC,$WEBGUI_LIB);

    ##Handle custom loaded library paths
    my $customPreload = File::Spec->catdir( $WEBGUI_ROOT, 'sbin', 'preload.custom');
    if (-e $customPreload) {
        open my $PRELOAD, '<', $customPreload or
            croak "Unload to open $customPreload: $!\n";
        LINE: while (my $line = <$PRELOAD>) {
            $line =~ s/#.*//;
            $line =~ s/^\s+//;
            $line =~ s/\s+$//;
            next LINE if !$line;
            unshift @INC, $line;
        }
        close $PRELOAD;
    }

    # http://thread.gmane.org/gmane.comp.apache.apreq/3378
    # http://article.gmane.org/gmane.comp.apache.apreq/3388
    if ( $^O eq 'darwin' && $Config::Config{osvers} lt '8.0.0' ) {
        unshift @INC, sub {
            return undef unless $_[1] =~ m/^Apache2|APR/;
            my $buffer = '1';
            open my $fh, '<', \$buffer;
            return $fh;
        };

        no warnings 'redefine';
        *Apache2::Const::OK        = sub {   0 };
        *Apache2::Const::DECLINED  = sub {  -1 };
        *Apache2::Const::NOT_FOUND = sub { 404 };
    }

    unless ( eval { require WebGUI::Session; } ) {
        warn qq/Failed to require package 'WebGUI::Session'. Reason: '$@'.\n/;
        exit(1);
    }


    $SESSION = WebGUI::Test->newSession;

    $originalSetting = clone $SESSION->setting->get;
}

END {
    my $Test = Test::Builder->new;
    GROUP: foreach my $group (@groupsToDelete) {
        my $groupId = $group->getId;
        next GROUP if WebGUI::Group->vitalGroup($groupId);
        my $newGroup = WebGUI::Group->new($SESSION, $groupId);
        $newGroup->delete if $newGroup;
    }
    USER: foreach my $user (@usersToDelete) {
        my $userId = $user->userId;
        next USER if any { $userId eq $_ } (1,3);
        my $newUser = WebGUI::User->new($SESSION, $userId);
        $newUser->delete if $newUser;
    }
    STORAGE: foreach my $stor (@storagesToDelete) {
        if ($SESSION->id->valid($stor)) {
            my $storage = WebGUI::Storage->get($SESSION, $stor);
            $storage->delete if $storage;
        }
        else {
            $stor->delete;
        }
    }
    ASSET: foreach my $asset (@assetsToPurge) {
        $asset->purge;
    }
    TAG: foreach my $tag (@tagsToRollback) {
        $tag->rollback;
    }
    WORKFLOW: foreach my $workflow (@workflowsToDelete) {
        my $workflowId = $workflow->getId;
        next WORKFLOW if any { $workflowId eq $_ } qw/
                AuthLDAPworkflow000001 
                csworkflow000000000001 
                DPWwf20061030000000002 
                PassiveAnalytics000001 
                pbworkflow000000000001 
                pbworkflow000000000002 
                pbworkflow000000000003 
                pbworkflow000000000004 
                pbworkflow000000000005 
                pbworkflow000000000006 
                pbworkflow000000000007 
                send_webgui_statistics 
                /;

        $workflow->delete;
    }
    if ($ENV{WEBGUI_TEST_DEBUG}) {
        $Test->diag('Sessions : '.$SESSION->db->quickScalar('select count(*) from userSession'));
        $Test->diag('Scratch  : '.$SESSION->db->quickScalar('select count(*) from userSessionScratch'));
        $Test->diag('Users    : '.$SESSION->db->quickScalar('select count(*) from users'));
        $Test->diag('Groups   : '.$SESSION->db->quickScalar('select count(*) from groups'));
        $Test->diag('mailQ    : '.$SESSION->db->quickScalar('select count(*) from mailQueue'));
        $Test->diag('Tags     : '.$SESSION->db->quickScalar('select count(*) from assetVersionTag'));
        $Test->diag('Assets   : '.$SESSION->db->quickScalar('select count(*) from assetData'));
        $Test->diag('Workflows: '.$SESSION->db->quickScalar('select count(*) from Workflow'));
    }
    while (my ($key, $value) = each %originalConfig) {
        if (defined $value) {
            $SESSION->config->set($key, $value);
        }
        else {
            $SESSION->config->delete($key);
        }
    }
    while (my ($param, $value) = each %{ $originalSetting }) {
        $SESSION->setting->set($param, $value);
    }
    SESSION: foreach my $session (@sessionsToDelete) {
        $session->var->end;
        $session->close;
    }

    # Close SMTPD
    if ($smtpdPid) {
        kill INT => $smtpdPid;
    }
    if ($smtpdStream) {
        close $smtpdStream;
        # we killed it, so there will be an error.  Prevent that from setting the exit value.
        $? = 0;
    }
}

=head2 newSession ( )

Builds a WebGUI session object for testing.

=cut

=head2 mockAssetId ( $assetId, $object )

Causes WebGUI::Asset->new* initializers to return the specified
object instead of retreiving it from the database for the given
asset ID.

=cut

my %mockedAssetIds;
sub mockAssetId {
    my ($class, $assetId, $object) = @_;
    _mockAssetInits();
    $mockedAssetIds{$assetId} = $object;
}

=head2 unmockAssetId ( $assetId )

Removes a given asset ID from being mocked.

=cut

sub unmockAssetId {
    my ($class, $assetId) = @_;
    delete $mockedAssetIds{$assetId};
}

=head2 mockAssetUrl ( $url, $object )

Causes WebGUI::Asset->newByUrl to return the specified object instead
of retreiving it from the database for the given URL.

=cut

my %mockedAssetUrls;
sub mockAssetUrl {
    my ($url, $object) = @_;
    _mockAssetInits();
    $mockedAssetUrls{$url} = $object;
}

=head2 unmockAssetUrl ( $url )

Removes a given asset URL from being mocked.

=cut

sub unmockAssetUrl {
    my ($class, $url) = @_;
    delete $mockedAssetUrls{$url};
}

my $mockedNew;
sub _mockAssetInits {
    no warnings 'redefine';

    return
        if $mockedNew;
    require WebGUI::Asset;
    my $original_new = \&WebGUI::Asset::new;
    *WebGUI::Asset::new = sub {
        my ($class, $session, $assetId, $className, $revisionDate) = @_;
        if ($mockedAssetIds{$assetId}) {
            return $mockedAssetIds{$assetId};
        }
        goto $original_new;
    };
    my $original_newByDynamicClass = \&WebGUI::Asset::newByDynamicClass;
    *WebGUI::Asset::newByDynamicClass = sub {
        my ($class, $session, $assetId, $revisionDate) = @_;
        if ($mockedAssetIds{$assetId}) {
            return $mockedAssetIds{$assetId};
        }
        goto $original_newByDynamicClass;
    };
    my $original_newPending = \&WebGUI::Asset::newPending;
    *WebGUI::Asset::newPending = sub {
        my ($class, $session, $assetId, $revisionDate) = @_;
        if ($mockedAssetIds{$assetId}) {
            return $mockedAssetIds{$assetId};
        }
        goto $original_newPending;
    };
    my $original_newByUrl = \&WebGUI::Asset::newByUrl;
    *WebGUI::Asset::newByUrl = sub {
        my ($class, $session, $url, $revisionDate) = @_;
        if ($mockedAssetUrls{$url}) {
            return $mockedAssetUrls{$url};
        }
        goto $original_newByUrl;
    };

    $mockedNew = 1;
}

#----------------------------------------------------------------------------

=head2 interceptLogging

Intercept logging request and capture them in buffer variables for testing.  Also,
mock the isDebug flag so that debug output is always generated.

=cut

sub interceptLogging {
    my $logger = $SESSION->log->getLogger;
    $logger = Test::MockObject::Extends->new( $logger );

    $logger->mock( 'warn',     sub { $WebGUI::Test::logger_warns = $_[1]} );
    $logger->mock( 'debug',    sub { $WebGUI::Test::logger_debug = $_[1]} );
    $logger->mock( 'info',     sub { $WebGUI::Test::logger_info  = $_[1]} );
    $logger->mock( 'error',    sub { $WebGUI::Test::logger_error = $_[1]} );
    $logger->mock( 'isDebug',  sub { return 1 } );
    $logger->mock( 'is_debug', sub { return 1 } );
}

#----------------------------------------------------------------------------

=head2 restoreLogging

Restores's the logging object to its original state.

=cut

sub restoreLogging {
    my $logger = $SESSION->log->getLogger;

    $logger->unmock( 'warn'     )
           ->unmock( 'debug'    )
           ->unmock( 'info'     )
           ->unmock( 'error'    )
           ->unmock( 'isDebug'  )
           ->unmock( 'is_debug' );
}

#----------------------------------------------------------------------------

=head2 config

Returns the config object from the session.

=cut

sub config {
    return undef unless defined $SESSION;
    return $SESSION->config;
}

#----------------------------------------------------------------------------

=head2 file

Returns the name of the WebGUI config file used for this test.

=cut

sub file {
    return $CONFIG_FILE;
}

#----------------------------------------------------------------------------

=head2 getPage ( asset | sub, pageName [, opts] )

Get the entire response from a page request. C<asset> is a WebGUI::Asset 
object. C<sub> is a string containing a fully-qualified subroutine name. 
C<pageName> is the name of the page subroutine to run (may be C<undef> for 
sub strings. C<options> is a hash reference of options with keys outlined 
below. 

 args           => Array reference of arguments to the pageName sub
 user           => A user object to set for this request
 userId         => A userId to set for this request
 formParams     => A hash reference of form parameters
 uploads        => A hash reference of files to "upload"

=cut

sub getPage {
    my $class       = shift;
    my $session     = $SESSION; # The session object
    my $actor       = shift;    # The actor to work on
    my $page        = shift;    # The page subroutine
    my $optionsRef  = shift;    # A hashref of options
                                # args      => Array ref of args to the page sub
                                # user      => A user object to set
                                # userId    => A user ID to set, "user" takes
                                #              precedence

    #!!! GETTING COOKIES WITH WebGUI::PseudoRequest DOESNT WORK, SO WE USE 
    # THIS AS A WORKAROUND
    $session->http->{_http}->{noHeader} = 1;
    
    # Open a buffer as a filehandle
    my $buffer  = "";
    open my $output, ">", \$buffer or die "Couldn't open memory buffer as filehandle: $@";
    $session->output->setHandle($output);

    # Set the appropriate user
    my $oldUser     = $session->user;
    if ($optionsRef->{user}) {
        $session->user({ user => $optionsRef->{user} });
    }
    elsif ($optionsRef->{userId}) {
        $session->user({ userId => $optionsRef->{userId} });
    }
    $session->user->uncache;

    # Create a new request object
    my $oldRequest  = $session->request;
    my $request     = WebGUI::PseudoRequest->new;
    $request->setup_param($optionsRef->{formParams});
    $session->{_request} = $request;

    # Fill the buffer
    my $returnedContent;
    if (blessed $actor) {
        $returnedContent = $actor->$page(@{$optionsRef->{args}});
    }
    elsif ( ref $actor eq "CODE" ) {
        $returnedContent = $actor->(@{$optionsRef->{args}});
    }
    else {
        # Try using it as a subroutine
        no strict 'refs';
        $returnedContent = $actor->(@{$optionsRef->{args}});    
        use strict 'refs';
    }

    if ($returnedContent && $returnedContent ne "chunked") {
        print $output $returnedContent;
    }

    close $output;
    
    # Restore the former user and request
    $session->user({ user => $oldUser });
    $session->{_request} = $oldRequest;

    #!!! RESTORE THE WORKAROUND
    delete $session->http->{_http}->{noHeader};

    # Return the page's output
    return $buffer;
}

#----------------------------------------------------------------------------

=head2 getTestCollateralPath ( [filename] )

Returns the full path to the directory containing the collateral files to be
used for testing.

Optionally adds a filename to the end.

=cut

sub getTestCollateralPath {
    my $class           = shift;
    my $filename        = shift;
    return File::Spec->catfile($WEBGUI_TEST_COLLATERAL,$filename);
}

#----------------------------------------------------------------------------

=head2 lib ( )

Returns the full path to the WebGUI lib directory, usually /data/WebGUI/lib.

=cut

sub lib {
    return $WEBGUI_LIB;
}

#----------------------------------------------------------------------------

=head2 root ( )

Returns the full path to the WebGUI root directory, usually /data/WebGUI.

=cut

sub root {
    return $WEBGUI_ROOT;
}

#----------------------------------------------------------------------------

=head2 session ( )

Returns the WebGUI::Session object that was created by the test.  This session object
will automatically be destroyed if the test finishes without dying.

The logger for this session has been overridden so that you can test
that WebGUI is logging errors.  That means that errors will not be put into
your webgui.log file (or whereever log.conf says to put it).  This will probably
be moved into a utility sub so that the interception can be enabled, and then
disabled.

=cut

sub session {
    return $SESSION;
}

#----------------------------------------------------------------------------

=head2 webguiBirthday ( )

This constant is used in several tests, so it's reproduced here so it can
be found easy.  This is the epoch date when WebGUI was released.

=cut

sub webguiBirthday {
    return 997966800 ;
}

#----------------------------------------------------------------------------

=head2 prepareMailServer ( )

Prepare a Net::SMTP::Server to use for testing mail.

=cut

sub prepareMailServer {
    eval {
        require Net::SMTP::Server;
        require Net::SMTP::Server::Client;
    };
    croak "Cannot load Net::SMTP::Server: $@" if $@;

    my $SMTP_HOST        = 'localhost';
    my $SMTP_PORT        = '54921';
    my $smtpd    = File::Spec->catfile( WebGUI::Test->root, 't', 'smtpd.pl' );
    $smtpdPid = open $smtpdStream, '-|', $^X, $smtpd, $SMTP_HOST, $SMTP_PORT
        or die "Could not open pipe to SMTPD: $!";

    $smtpdSelect = IO::Select->new;
    $smtpdSelect->add($smtpdStream);

    $SESSION->setting->set( 'smtpServer', $SMTP_HOST . ':' . $SMTP_PORT );

    WebGUI::Test->originalConfig('emailToLog');
    $SESSION->config->set( 'emailToLog', 0 );

    # Let it start up yo
    sleep 2;

    return;
}

#----------------------------------------------------------------------------

=head2 originalConfig ( $param )

Stores the original data from the config file, to be restored
automatically at the end of the test.  This is a class method.

=cut

sub originalConfig {
    my ($class, $param) = @_;
    my $safeValue = my $value = $SESSION->config->get($param);
    if (ref $value) {
        $safeValue = clone $value;
    }
    $originalConfig{$param} = $safeValue;
}

#----------------------------------------------------------------------------

=head2 assetsToPurge ( $asset, [$asset ] )

Push a list of Asset objects onto the stack of assets to be automatically purged
at the end of the test.  This will also clean-up all version tags associated
with the Asset.

This is a class method.

=cut

sub assetsToPurge {
    my $class = shift;
    push @assetsToPurge, @_;
}

#----------------------------------------------------------------------------

=head2 groupsToDelete ( $group, [$group ] )

Push a list of group objects onto the stack of groups to be automatically deleted
at the end of the test.

This is a class method.

=cut

sub groupsToDelete {
    my $class = shift;
    push @groupsToDelete, @_;
}

#----------------------------------------------------------------------------

=head2 getMail ( ) 

Read a sent mail from the prepared mail server (L<prepareMailServer>)

=cut

sub getMail {
    my $json;
    
    if ( !$smtpdSelect ) {
        return from_json ' { "error": "mail server not prepared" }';
    }

    if ($smtpdSelect->can_read(5)) {
        $json = <$smtpdStream>;
    }
    else {
        $json = ' { "error": "mail not sent" } ';
    }
    
    if (!$json) {
        $json = ' { "error": "error in getting mail" } ';
    }
    
    return from_json( $json );
}

#----------------------------------------------------------------------------

=head2 getMailFromQueue ( )

Send the first mail in the queue and then retrieve it from the smtpd. Returns
false if there is no mail in the queue.

Will prepare the server if necessary

=cut

sub getMailFromQueue {
    my $class   = shift;
    if ( !$smtpdSelect ) {
        $class->prepareMailServer;
    }
    
    my $messageId = $SESSION->db->quickScalar( "SELECT messageId FROM mailQueue" );
    warn $messageId;
    return unless $messageId; 

    my $mail    = WebGUI::Mail::Send->retrieve( $SESSION, $messageId );
    $mail->send;

    return $class->getMail;
}

#----------------------------------------------------------------------------

=head2 storagesToDelete ( $storage, [$storageId ] )

Push a list of storage objects or storageIds onto the stack of storage locaitons
at the end of the test.

This is a class method.

=cut

sub storagesToDelete {
    my $class = shift;
    push @storagesToDelete, @_;
}

#----------------------------------------------------------------------------

=head2 tagsToRollback ( $tag )

Push a list of version tags to rollback at the end of the test.

This is a class method.

=cut

sub tagsToRollback {
    my $class = shift;
    push @tagsToRollback, @_;
}

#----------------------------------------------------------------------------

=head2 usersToDelete ( $user, [$user, ...] )

Push a list of user objects onto the stack of groups to be automatically deleted
at the end of the test.  If found in the stack, the Admin and Visitor users will not be deleted.

This is a class method.

=cut

sub usersToDelete {
    my $class = shift;
    push @usersToDelete, @_;
}

#----------------------------------------------------------------------------

=head2 workflowsToDelete ( $workflow, [$workflow, ...] )

Push a list of workflow objects onto the stack of groups to be automatically deleted
at the end of the test.

This is a class method.

=cut

sub workflowsToDelete {
    my $class = shift;
    push @workflowsToDelete, @_;
}

#----------------------------------------------------------------------------

=head1 BUGS

When trying to load the APR module, perl invariably throws an Out Of Memory
error. For this reason, getPage disables header processing.

=cut

1;
