# Tests WebGUI::Crypt
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

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests
WebGUI::Error->Trace(1);    # Turn on tracing of uncaught Exception::Class exceptions
plan tests => 13;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Crypt');

#######################################################################
#
# constructor
#
#######################################################################
{
    eval { my $crypt = WebGUI::Crypt->new() };
    my $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::InvalidParam', 'new takes exception to missing session object' );
}
{
    eval { my $crypt = WebGUI::Crypt->new($session) };
    my $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::InvalidParam', 'new takes exception to missing config object' );
}
{
    eval { my $crypt = WebGUI::Crypt->new( $session, {} ) };
    my $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::InvalidParam', 'new takes exception to invalid config object' );
}
{
    eval{my $crypt = WebGUI::Crypt->new( $session, { provider => 'WebGUI::What::Sort::Of::Namespace::Is::This?' })};
    my $e = Exception::Class->caught();
    isa_ok($e, 'WebGUI::Error::Pluggable::LoadFailed', 'new takes exception to invalid module');
}
{
    eval{my $crypt = WebGUI::Crypt->new( $session, { provider => 'Test::More' })};
    my $e = Exception::Class->caught();
    isa_ok($e, 'WebGUI::Error::Pluggable::RunFailed', 'new takes exception to invalid provider');
}
{
    my $crypt = WebGUI::Crypt->new( $session, { provider => 'WebGUI::Crypt::Simple', key => 'x' } );
    test_provider($crypt, 'keep me secret');
}

#######################################################################
#
# session->crypt
#
#######################################################################
{
    # This test requires that your webgui site config file contains crypt settings
    my $crypt = $session->crypt;
    isa_ok( $crypt, 'WebGUI::Crypt', 'session contructor works too' );
    test_provider($crypt, "don't say nothing");
}

# Carbon copy from Crypt.t
sub test_provider {
    my ($crypt, $plaintext) = @_;
    isa_ok( $crypt, 'WebGUI::Crypt', 'constructor works' );
    my $encrypted_hex = $crypt->encrypt_hex($plaintext);
    isnt($encrypted_hex, $plaintext, "$plaintext encrypted is: $encrypted_hex");
    my $decrypted = $crypt->decrypt_hex($encrypted_hex);
    is($decrypted, $plaintext, "got back our original text: $decrypted");
}

END {
}
