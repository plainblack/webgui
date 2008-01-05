package WebGUI::Test;

use strict;
use warnings;

our ( $SESSION, $WEBGUI_ROOT, $CONFIG_FILE, $WEBGUI_LIB, $WEBGUI_TEST_COLLATERAL );

use Config     qw[];
use IO::Handle qw[];
use File::Spec qw[];
use Test::MockObject::Extends;
use WebGUI::PseudoRequest;

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

BEGIN {

    STDERR->autoflush(1);

    $CONFIG_FILE = $ENV{ WEBGUI_CONFIG };

    unless ( defined $CONFIG_FILE ) {
        warn qq/Enviroment variable WEBGUI_CONFIG must be set.\n/;
        exit(1);
    }
   
    unless ( $CONFIG_FILE ) {
        warn qq/Enviroment variable WEBGUI_CONFIG must not be empty.\n/;
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
    $WEBGUI_TEST_COLLATERAL = File::Spec->catdir($WEBGUI_ROOT, 't', 'supporting_collateral');

    $WEBGUI_LIB  ||= File::Spec->catpath( (File::Spec->splitpath($WEBGUI_ROOT))[0], $WEBGUI_ROOT, 'lib' );

    push (@INC,$WEBGUI_LIB);

    # http://thread.gmane.org/gmane.comp.apache.apreq/3378
    # http://article.gmane.org/gmane.comp.apache.apreq/3388
    if ( $^O eq 'darwin' && $Config::Config{osvers} lt '8.0.0' ) {

        require Class::Null;
        require IO::File;

        unshift @INC, sub {
            return undef unless $_[1] =~ m/^Apache2|APR/;
            return IO::File->new( $INC{'Class/Null.pm'}, &IO::File::O_RDONLY );
        };

        no strict 'refs';

        *Apache2::Const::OK        = sub {   0 };
        *Apache2::Const::DECLINED  = sub {  -1 };
        *Apache2::Const::NOT_FOUND = sub { 404 };
    }

    unless ( eval "require WebGUI::Session;" ) {
        warn qq/Failed to require package 'WebGUI::Session'. Reason: '$@'.\n/;
        exit(1);
    }

    $SESSION = WebGUI::Session->open( $WEBGUI_ROOT, $CONFIG_FILE );

    my $logger = $SESSION->errorHandler->getLogger;
    $logger = Test::MockObject::Extends->new( $logger );

    $logger->mock( 'warn',  sub { $WebGUI::Test::logger_warns = $_[1]} );
    $logger->mock( 'debug', sub { $WebGUI::Test::logger_debug = $_[1]} );
    $logger->mock( 'info',  sub { $WebGUI::Test::logger_info  = $_[1]} );
    $logger->mock( 'error', sub { $WebGUI::Test::logger_error = $_[1]} );
}

END {
    my $Test = Test::Builder->new;
    if ($ENV{WEBGUI_TEST_DEBUG}) {
        $Test->diag('Sessions: '.$SESSION->db->quickScalar('select count(*) from userSession'));
        $Test->diag('Scratch : '.$SESSION->db->quickScalar('select count(*) from userSessionScratch'));
        $Test->diag('Users   : '.$SESSION->db->quickScalar('select count(*) from users'));
        $Test->diag('Groups  : '.$SESSION->db->quickScalar('select count(*) from groups'));
    }
    $SESSION->var->end;
    $SESSION->close if defined $SESSION;
}


sub config {
    return undef unless defined $SESSION;
    return $SESSION->config;
}


sub file {
    return $CONFIG_FILE;
}

#----------------------------------------------------------------------------

=head2 getPage ( asset, pageName [, opts] )

Get the entire response from a page request. asset is a WebGUI::Asset object.
pageName is the name of the page subroutine to run. options is a hash reference
of options with keys outlined below. 

 args           => Array reference of arguments to the pageName sub
 user           => A user object to set for this request
 userId         => A userId to set for this request
 formParams     => A hash reference of form parameters
 uploads        => A hash reference of files to "upload"

=cut

sub getPage {
    my $class       = shift;
    my $session     = $SESSION; # The session object
    my $asset       = shift;    # The asset object
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
    my $returnedContent = $asset->$page(@{$optionsRef->{args}});
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

sub lib {
    return $WEBGUI_LIB;
}

sub root {
    return $WEBGUI_ROOT;
}

sub session {
    return $SESSION;
}


#----------------------------------------------------------------------------

=head1 BUGS

When trying to load the APR module, perl invariably throws an Out Of Memory
error. For this reason, getPage disables header processing.

=cut

1;
