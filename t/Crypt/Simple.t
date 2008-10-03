# Tests WebGUI::Crypt::Simple
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

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests
WebGUI::Error->Trace(1);    # Turn on tracing of uncaught Exception::Class exceptions
plan tests => 12;

#----------------------------------------------------------------------------
# put your tests here

#######################################################################
#
# constructor
#
#######################################################################
{
    eval { my $crypt = WebGUI::Crypt->new( $session, { provider => 'WebGUI::Crypt::Simple' } ); };
    my $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::Pluggable::RunFailed', 'new takes exception to missing key in config' );
}
{
    eval { my $crypt = WebGUI::Crypt->new( $session, { provider => 'WebGUI::Crypt::Simple', key => '' } ); };
    my $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::Pluggable::RunFailed', 'new takes exception to empty key in config' );
}
{
    # Try with default cipher
    my $crypt = WebGUI::Crypt->new( $session, { provider => 'WebGUI::Crypt::Simple', key => 'x' } );
    isa_ok( $crypt, 'WebGUI::Crypt', 'constructor works' );
    isa_ok( $crypt->provider, 'WebGUI::Crypt::Simple', 'provider was created' );
    test_provider($crypt, 'oh hai!');
}
{
    # Try with a different cipher
    my $crypt = WebGUI::Crypt->new( $session, { provider => 'WebGUI::Crypt::Simple', key => 'x', cipher => 'Crypt::DES' } );
    isa_ok( $crypt, 'WebGUI::Crypt', 'constructor works' );
    isa_ok( $crypt->provider, 'WebGUI::Crypt::Simple', 'provider was created' );
    test_provider($crypt, 'kimiwa sekushi des');
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
