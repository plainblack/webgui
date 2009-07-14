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
use WebGUI::Pluggable;

use WebGUI::Test;    # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Text;
use WebGUI::Workflow;
use WebGUI::Group;
use WebGUI::Crypt::None;
use File::Spec;
use Cwd;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;
my $providerData = $session->config->get('crypt')->{'None'};
$providerData->{providerId} = 'None';

my $crypt = eval { WebGUI::Pluggable::run( 'WebGUI::Crypt::None', 'new', [$session, $providerData] ); };
#----------------------------------------------------------------------------
# Tests
WebGUI::Error->Trace(1);    # Turn on tracing of uncaught Exception::Class exceptions
plan tests => 4;

#----------------------------------------------------------------------------
# put your tests here
#require_ok( File::Spec->catfile( cwd(), qw( t Crypt crypt.pl ) ) );

#######################################################################
#
# constructor
#
#######################################################################
{
   # my $crypt = WebGUI::Crypt::None->new( $session );
    
    isa_ok( $crypt, 'WebGUI::Crypt::None', 'constructor works' );
    is( $crypt->providerId(), 'None', "provider was created ");
}

#######################################################################
#
# en/decrypt
#
#######################################################################
{
    is( $crypt->decrypt($crypt->encrypt("hi")), 'hi', 'encrypt hi should return hi');
}
{
    is( $crypt->decrypt($crypt->encrypt('')), '', 'encrypt undef should return nothign');
}
