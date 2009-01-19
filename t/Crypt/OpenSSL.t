# Tests that we can decrypt WebGUI::Crypt ciphertexts using OpenSSL
# N.B. Assumes that the openssl binary lives at: /data/wre/prereqs/bin/openssl
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
use MIME::Base64;

use Cwd;
use File::Spec;


#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests
WebGUI::Error->Trace(1);    # Turn on tracing of uncaught Exception::Class exceptions
plan tests => 3;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Crypt');

require_ok( File::Spec->catfile( cwd(), qw( t Crypt crypt.pl ) ) );

#######################################################################
#
#
#
#######################################################################
{
    my $key = make_string(20);
    my $plaintext         = make_string(100);
    
    my $crypt = WebGUI::Crypt->new( $session, { provider => 'WebGUI::Crypt::Simple', key => $key } );
    my $ciphertext        = $crypt->encrypt($plaintext);
    my $ciphertext_base64 = encode_base64($ciphertext); # Note to the curious, base64 adds a newline to the end, which is expected and required for OpenSSL compat
    is( $plaintext, `echo '$ciphertext_base64' | /data/wre/prereqs/bin/openssl enc -aes256 -salt -a -d -k $key`, 'Decrypted ciphertext using OpenSSL' );
}

