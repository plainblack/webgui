# Tests WebGUI::Crypt::None
#
#

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More;
use Test::Deep;
use Exception::Class;

use WebGUI::Test;    # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Text;
use WebGUI::Workflow;
use WebGUI::Group;
use WebGUI::Crypt;
use File::Spec;
use Cwd;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests
WebGUI::Error->Trace(1);    # Turn on tracing of uncaught Exception::Class exceptions
plan tests => 5;

#----------------------------------------------------------------------------
# put your tests here
require_ok( File::Spec->catfile( cwd(), qw( t Crypt crypt.pl ) ) );

#######################################################################
#
# constructor
#
#######################################################################
{
    my $crypt = WebGUI::Crypt->new( $session, { provider => 'WebGUI::Crypt::None' } );
    isa_ok( $crypt, 'WebGUI::Crypt', 'constructor works' );
    isa_ok( $crypt->provider, 'WebGUI::Crypt::None', 'provider was created' );
    test_provider($crypt, make_string(rand(50)+1));
}