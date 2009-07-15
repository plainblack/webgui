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
use WebGUI::Crypt::Simple;
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
plan tests => 1;

#----------------------------------------------------------------------------
# put your tests here

#----------------------------------------------------------------------------
# Init
my $key = 'abc';
my $config = {'provider' => 'WebGUI::Crypt::Simple', 'name' => 'simple', 'key' => $key};
$config->{providerId} = 'The Simple';

my $crypt = WebGUI::Crypt::Simple->new($session,$config);

#######################################################################
#
#
#
#######################################################################
{
    my $plaintext         = 'test';
    my $ciphertext        = $crypt->encrypt($plaintext,{providerId=>'The Simple'});
    $ciphertext =~ /CRYPT:(.*?):(.*)/;
    $ciphertext = $2;
    my $ciphertext_base64 = encode_base64($ciphertext); # Note to the curious, base64 adds a newline to the end, which is expected and required for OpenSSL compat
    is( $plaintext, `echo "$ciphertext_base64" | /data/wre/prereqs/bin/openssl enc -aes256 -salt -a -d -k $key`, 'Decrypted ciphertext using OpenSSL' );
}


