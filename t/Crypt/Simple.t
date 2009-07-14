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
use WebGUI::Crypt::Simple;
use File::Spec;
use Cwd;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;
my $config = {'provider' => 'WebGUI::Crypt::Simple', 'name' => 'simple', 'key' => 'abc'};
$config->{providerId} = 'The Simple';

my $crypt;
#----------------------------------------------------------------------------
# Tests
WebGUI::Error->Trace(1);    # Turn on tracing of uncaught Exception::Class exceptions
plan tests => 4;

#----------------------------------------------------------------------------
# put your tests here

#######################################################################
#
# constructor
#
#######################################################################
{
    $crypt = eval { WebGUI::Pluggable::run( 'WebGUI::Crypt::Simple', 'new', [$session, $config] ); };
    isa_ok( $crypt, 'WebGUI::Crypt::Simple', 'constructor works' );
    is( $crypt->providerId(), 'The Simple', "provider was created ");
}

#######################################################################
#
# en/decrypt
#
#######################################################################
{
    my $t = $crypt->encrypt('hi');
    $t =~ /CRYPT:(.*?):(.*)/;
    is( $crypt->decrypt($2), 'hi', 'encrypt hi should return hi');
}
{
    my $t = $crypt->encrypt('');
    $t =~ /CRYPT:(.*?):(.*)/;
    is( $crypt->decrypt($2), '', 'encrypt nothing should return nothing');
}
