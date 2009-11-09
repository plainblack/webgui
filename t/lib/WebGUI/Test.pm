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
use base qw(Test::Builder::Module);

use Test::MockObject;
use Test::MockObject::Extends;
use Clone               qw(clone);
use Config              ();
use IO::Handle          ();
use File::Spec          ();
use IO::Select          ();
use Cwd                 ();
use Scalar::Util        qw( blessed );
use List::MoreUtils     qw( any );
use Carp                qw( carp croak );
use JSON                qw( from_json to_json );
use Scope::Guard;

BEGIN {
    my $file_root = File::Spec->catpath((File::Spec->splitpath(__FILE__))[0,1], '');

    our $WEBGUI_ROOT = Cwd::realpath( File::Spec->catdir( $file_root, (File::Spec->updir) x 3 ));
    our $WEBGUI_TEST_COLLATERAL = File::Spec->catdir($WEBGUI_ROOT, 't', 'supporting_collateral');
    our $WEBGUI_LIB = File::Spec->catdir( $WEBGUI_ROOT, 'lib' );

    push @INC, $WEBGUI_LIB;

    ##Handle custom loaded library paths
    my $customPreload = File::Spec->catfile( $WEBGUI_ROOT, 'sbin', 'preload.custom');
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
}

use WebGUI::Session;
use WebGUI::PseudoRequest;

our @EXPORT = qw(cleanupGuard addToCleanup);
our @EXPORT_OK = qw(session config);

my $CLASS = __PACKAGE__;

my @guarded;

sub import {
    our $CONFIG_FILE = $ENV{ WEBGUI_CONFIG };

    die "Enviroment variable WEBGUI_CONFIG must be set to the full path to a WebGUI config file.\n"
        unless $CONFIG_FILE;
    die "WEBGUI_CONFIG path '$CONFIG_FILE' does not exist.\n"
        unless -e $CONFIG_FILE;
    die "WEBGUI_CONFIG path '$CONFIG_FILE' is not a file.\n"
        unless -f _;
    die "WEBGUI_CONFIG path '$CONFIG_FILE' is not readable by effective uid '$>'.\n"
        unless -r _;

    $CONFIG_FILE = File::Spec->abs2rel($CONFIG_FILE, File::Spec->catdir($CLASS->root, 'etc'));
    my $session = our $SESSION = $CLASS->newSession(1);

    my $originalSetting = clone $session->setting->get;
    push @guarded, Scope::Guard->new(sub {
        while (my ($param, $value) = each %{ $originalSetting }) {
            $session->setting->set($param, $value);
        }
    });

    if ($ENV{WEBGUI_TEST_DEBUG}) {
        ##Offset Sessions, and Scratch by 1 because 1 will exist at the start
        my @checkCount = (
            Sessions            => 'userSession',
            Scratch             => 'userSessionScratch',
            Users               => 'users',
            Groups              => 'groups',
            mailQ               => 'mailQueue',
            Tags                => 'assetVersionTag',
            Assets              => 'assetData',
            Workflows           => 'Workflow',
            Carts               => 'cart',
            Transactions        => 'transaction',
            'Transaction Items' => 'transactionItem',
            'Ship Drivers'      => 'shipper',
            'Database Links'    => 'databaseLink',
        );
        my %initCounts;
        for ( my $i = 0; $i < @checkCount; $i += 2) {
            my ($label, $table) = @checkCount[$i, $i+1];
            $initCounts{$table} = $session->db->quickScalar('SELECT COUNT(*) FROM ' . $table);
        }
        push @guarded, Scope::Guard->new(sub {
            for ( my $i = 0; $i < @checkCount; $i += 2) {
                my ($label, $table) = @checkCount[$i, $i+1];
                my $quant = $session->db->quickScalar('SELECT COUNT(*) FROM ' . $table);
                my $delta = $quant - $initCounts{$table};
                if ($delta) {
                    $CLASS->builder->diag(sprintf '%-10s: %4d (delta %+d)', $label, $quant, $delta);
                }
            }
        });
    }

    goto &{ $_[0]->can('SUPER::import') };
}

END {
    $CLASS->cleanup;
}

sub cleanup {
    # remove guards in reverse order they were added, triggering all of the
    # requested cleanup operations
    pop @guarded
        while @guarded;

    if ( our $SESSION ) {
        $SESSION->var->end;
        $SESSION->close;
        undef $SESSION;
    }
}

=head2 newSession ( $noCleanup )

Builds a WebGUI session object for testing.

=head3 $noCleanup

If true, the session won't be registered for automatic deletion.

=cut

#----------------------------------------------------------------------------

sub newSession {
    my $noCleanup = shift;
    my $pseudoRequest = WebGUI::PseudoRequest->new;
    my $session = WebGUI::Session->open( $CLASS->root, $CLASS->file );
    $session->{_request} = $pseudoRequest;
    if ( ! $noCleanup ) {
        $CLASS->sessionsToDelete($session);
    }
    return $session;
}


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
    my ($class, $url, $object) = @_;
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

=head2 unmockAllAssets ( )

Removes all asset IDs and URLs from being mocked.

=cut

sub unmockAllAssets {
    my ($class) = @_;
    keys %mockedAssetIds = ();
    keys %mockedAssetUrls = ();
    return;
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
        if ($assetId && $mockedAssetIds{$assetId}) {
            return $mockedAssetIds{$assetId};
        }
        goto $original_newPending;
    };
    my $original_newByUrl = \&WebGUI::Asset::newByUrl;
    *WebGUI::Asset::newByUrl = sub {
        my ($class, $session, $url, $revisionDate) = @_;
        if ($url && $mockedAssetUrls{$url}) {
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
    my $logger = $CLASS->session->log->getLogger;
    $logger = Test::MockObject::Extends->new( $logger );

    $logger->mock( 'warn',     sub { our $logger_warns = $_[1]} );
    $logger->mock( 'debug',    sub { our $logger_debug = $_[1]} );
    $logger->mock( 'info',     sub { our $logger_info  = $_[1]} );
    $logger->mock( 'error',    sub { our $logger_error = $_[1]} );
    $logger->mock( 'isDebug',  sub { return 1 } );
    $logger->mock( 'is_debug', sub { return 1 } );
}

#----------------------------------------------------------------------------

=head2 restoreLogging

Restores's the logging object to its original state.

=cut

sub restoreLogging {
    my $logger = $CLASS->session->log->getLogger;

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
    return undef unless defined $CLASS->session;
    return $CLASS->session->config;
}

#----------------------------------------------------------------------------

=head2 file

Returns the name of the WebGUI config file used for this test.

=cut

sub file {
    return our $CONFIG_FILE;
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
    my $actor       = shift;    # The actor to work on
    my $page        = shift;    # The page subroutine
    my $optionsRef  = shift;    # A hashref of options
                                # args      => Array ref of args to the page sub
                                # user      => A user object to set
                                # userId    => A user ID to set, "user" takes
                                #              precedence

    my $session = $CLASS->session;

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
    local $session->{_request} = $request;
    local $session->output->{_handle};

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
    }

    if ($returnedContent && $returnedContent ne "chunked") {
        $session->output->print($returnedContent);
    }

    # Restore the former user and request
    $session->user({ user => $oldUser });

    # Return the page's output
    return $request->get_output;
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
    return File::Spec->catfile(our $WEBGUI_TEST_COLLATERAL, $filename);
}

#----------------------------------------------------------------------------

=head2 lib ( )

Returns the full path to the WebGUI lib directory, usually /data/WebGUI/lib.

=cut

sub lib {
    return our $WEBGUI_LIB;
}

#----------------------------------------------------------------------------

=head2 root ( )

Returns the full path to the WebGUI root directory, usually /data/WebGUI.

=cut

sub root {
    return our $WEBGUI_ROOT;
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
    return our $SESSION;
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

my $smtpdPid;
my $smtpdStream;
my $smtpdSelect;

sub prepareMailServer {
    eval {
        require Net::SMTP::Server;
        require Net::SMTP::Server::Client;
    };
    croak "Cannot load Net::SMTP::Server: $@" if $@;

    my $SMTP_HOST        = 'localhost';
    my $SMTP_PORT        = '54921';
    my $smtpd    = File::Spec->catfile( $CLASS->root, 't', 'smtpd.pl' );
    $smtpdPid = open $smtpdStream, '-|', $^X, $smtpd, $SMTP_HOST, $SMTP_PORT
        or die "Could not open pipe to SMTPD: $!";

    $smtpdSelect = IO::Select->new;
    $smtpdSelect->add($smtpdStream);

    $CLASS->session->setting->set( 'smtpServer', $SMTP_HOST . ':' . $SMTP_PORT );

    $CLASS->originalConfig('emailToLog');
    $CLASS->session->config->set( 'emailToLog', 0 );

    # Let it start up yo
    sleep 2;

    push @guarded, Scope::Guard->new(sub {
        # Close SMTPD
        if ($smtpdPid) {
            kill INT => $smtpdPid;
        }
        if ($smtpdStream) {
            # we killed it, so there will be an error.  Prevent that from setting the exit value.
            local $?;
            close $smtpdStream;
        }
    });

    return;
}

#----------------------------------------------------------------------------

=head2 originalConfig ( $param )

Stores the original data from the config file, to be restored
automatically at the end of the test.  This is a class method.

=cut

my %originalConfig;
sub originalConfig {
    my ($class, $param) = @_;
    my $safeValue = my $value = $CLASS->session->config->get($param);
    if (ref $value) {
        $safeValue = clone $value;
    }
    # add cleanup handler if this is the first time we were run
    if (! keys %originalConfig) {
        push @guarded, Scope::Guard->new(sub {
            while (my ($key, $value) = each %originalConfig) {
                if (defined $value) {
                    $CLASS->session->config->set($key, $value);
                }
                else {
                    $CLASS->session->config->delete($key);
                }
            }
        });
    }
    $originalConfig{$param} = $safeValue;
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
    
    my $messageId = $CLASS->session->db->quickScalar( "SELECT messageId FROM mailQueue" );
    warn $messageId;
    return unless $messageId; 

    require WebGUI::Mail::Send;
    my $mail    = WebGUI::Mail::Send->retrieve( $CLASS->session, $messageId );
    $mail->send;

    return $class->getMail;
}
#----------------------------------------------------------------------------

=head2 sessionsToDelete ( $session, [$session, ...] )

Push a list of session objects onto the stack of groups to be automatically deleted
at the end of the test.  Note, this will be the last group of objects to be
cleaned up.

This is a class method.

=cut

sub sessionsToDelete {
    my $class = shift;
    push @guarded, cleanupGuard(@_);
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
    push @guarded, cleanupGuard(@_);
}

#----------------------------------------------------------------------------

=head2 groupsToDelete ( $group, [$group ] )

Push a list of group objects onto the stack of groups to be automatically deleted
at the end of the test.

This is a class method.

=cut

sub groupsToDelete {
    my $class = shift;
    push @guarded, cleanupGuard(@_);
}


#----------------------------------------------------------------------------

=head2 storagesToDelete ( $storage, [$storageId ] )

Push a list of storage objects or storageIds onto the stack of storage locaitons
at the end of the test.

This is a class method.

=cut

sub storagesToDelete {
    my $class = shift;
    push @guarded, cleanupGuard(map {
        ref $_ ? $_ : ('WebGUI::Storage' => $_)
    } @_);
}

#----------------------------------------------------------------------------

=head2 tagsToRollback ( $tag )

Push a list of version tags to rollback at the end of the test.

This is a class method.

=cut

sub tagsToRollback {
    my $class = shift;
    push @guarded, cleanupGuard(@_);
}

#----------------------------------------------------------------------------

=head2 usersToDelete ( $user, [$user, ...] )

Push a list of user objects onto the stack of groups to be automatically deleted
at the end of the test.  If found in the stack, the Admin and Visitor users will not be deleted.

This is a class method.

=cut

sub usersToDelete {
    my $class = shift;
    push @guarded, cleanupGuard(@_);
}

#----------------------------------------------------------------------------

=head2 workflowsToDelete ( $workflow, [$workflow, ...] )

Push a list of workflow objects onto the stack of groups to be automatically deleted
at the end of the test.

This is a class method.

=cut

sub workflowsToDelete {
    my $class = shift;
    push @guarded, cleanupGuard(@_);
}


#----------------------------------------------------------------------------

=head2 cleanupGuard ( $object, $class => $ident )

Pass in a list of objects or pairs of classes and identifiers, and
it will return a guard object for cleaning them up.  When the guard
object goes out of scope, it will automatically clean up all of the
passed in objects.  Objects will be destroyed in the order they
were passed in.  Currently able to destroy:

    WebGUI::Asset
    WebGUI::Group
    WebGUI::Session
    WebGUI::Storage
    WebGUI::User
    WebGUI::VersionTag
    WebGUI::Workflow
    WebGUI::Shop::Cart
    WebGUI::Shop::ShipDriver
    WebGUI::Shop::Transaction
    WebGUI::DatabaseLink

Example call:

    my $guard = cleanupGuard(
        $user,
        $workflow,
        'WebGUI::Group' => $groupId,
        $asset,
    );

=cut

{
    my %initialize = (
        '' => sub {
            my ($class, $ident) = @_;
            return $class->new($CLASS->session, $ident);
        },
        'WebGUI::Storage' => sub {
            my ($class, $ident) = @_;
            return WebGUI::Storage->get($CLASS->session, $ident);
        },
    );

    my %clone = (
        'WebGUI::User' => sub {
            WebGUI::User->new($CLASS->session, shift->getId);
        },
        'WebGUI::Group' => sub {
            WebGUI::Group->new($CLASS->session, shift->getId);
        },
        'WebGUI::Session' => 'duplicate',
    );

    my %check = (
        'WebGUI::User' => sub {
            my $user = shift;
            my $userId = $user->userId;
            die "Refusing to clean up vital user @{[ $user->username ]}!\n"
                if any { $userId eq $_ } (1, 3);
        },
        'WebGUI::DatabaseLink' => sub {
            my $db_link = shift;
            die "Refusing to clean up database link @{[ $db_link->get('title') ]}!\n"
                if $db_link->getId eq '0';
        },
        'WebGUI::Group' => sub {
            my $group = shift;
            die "Refusing to clean up vital group @{[ $group->name ]}!\n"
                if $group->vitalGroup;
        },
        'WebGUI::Workflow' => sub {
            my $workflow = shift;
            my $workflowId = $workflow->getId;
            die "Refusing to clean up vital workflow @{[ $workflow->get('title') ]}!\n"
                if any { $workflowId eq $_ } qw{
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
                };
        },
    );

    my %cleanup = (
        'WebGUI::User'              => 'delete',
        'WebGUI::Group'             => 'delete',
        'WebGUI::Storage'           => 'delete',
        'WebGUI::Asset'             => 'purge',
        'WebGUI::VersionTag'        => 'rollback',
        'WebGUI::Workflow'          => 'delete',
        'WebGUI::DatabaseLink'      => 'delete',
        'WebGUI::Shop::Transaction' => 'delete',
        'WebGUI::Shop::ShipDriver'  => 'delete',
        'WebGUI::Shop::Cart'        => sub {
            my $cart        = shift;
            my $addressBook = $cart->getAddressBook();
            $addressBook->delete if $addressBook;  ##Should we call cleanupGuard instead???
            $cart->delete;
        },
        'WebGUI::Session'          => sub {
            my $session = shift;
            $session->var->end;
            $session->close;
        },
    );

    sub cleanupGuard {
        shift
            if eval { $_[0]->isa($CLASS) };
        my @cleanups;
        while (@_) {
            my $class = shift;
            my $construct;
            if ( ref $class ) {
                my $object = $class;
                my $cloneSub = $CLASS->_findByIsa($class, \%clone);
                $construct = $cloneSub ? sub { $object->$cloneSub } : sub { $object };
                $class = ref $class;
            }
            else {
                my $id = shift;
                my $initSub = $CLASS->_findByIsa($class, \%initialize)
                    || croak "Can't find initializer for $class\n";
                $construct = sub { $initSub->($class, $id) };
            }
            if (my $check = $CLASS->_findByIsa($class, \%check)) {
                local $@;
                if ( ! eval { $construct->()->$check; 1 } ) {
                    if ($@) {
                        carp $@;
                    }
                    else {
                        carp "Refusing to clean up vital $class!\n";
                    }
                    next;
                }
            }
            my $destroy = $CLASS->_findByIsa($class, \%cleanup)
                || croak "Can't find destructor for $class";
            push @cleanups, $construct, $destroy;
        }
        return Scope::Guard->new(sub {
            local $@;
            while ( 1 ) {
                my ($construct, $destroy) = (shift @cleanups, shift @cleanups);
                last
                    if ! $construct;
                if ( my $object = eval { $construct->() } ) {
                    eval { $object->$destroy };
                }
                if (ref $@ && $@->isa('WebGUI::Error::ObjectNotFound')) {
                    # ignore objects that don't exist
                }
                elsif ($@) {
                    warn $@;
                }
            }
            return;
        });
    }
}

sub _findByIsa {
    my $self = shift;
    my $toFind = shift;
    my $hash = shift;
    for my $key ( sort { length $b <=> length $a} keys %$hash ) {
        if ($toFind->isa($key)) {
            return $hash->{$key};
        }
    }
    return $hash->{''};
}

#----------------------------------------------------------------------------

=head2 addToCleanup ( $object, $class => $ident )

Takes the same parameters as cleanupGuard, but cleans the objects
up at the end of the test instead of returning a guard object.

This is a class method.

=cut

sub addToCleanup {
    shift
        if eval { $_[0]->isa($CLASS) };
    push @guarded, cleanupGuard(@_);
}

#----------------------------------------------------------------------------

=head1 BUGS

When trying to load the APR module, perl invariably throws an Out Of Memory
error. For this reason, getPage disables header processing.

=cut

1;
