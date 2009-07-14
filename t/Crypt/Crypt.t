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

# Include helper
require "$FindBin::Bin/crypt.pl";

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Create test data
$session->db->write("drop table if exists `encryptTest`");
$session->db->write("CREATE TABLE `encryptTest` ( `id` char(22)  NOT NULL, `testField` LONGTEXT  NOT NULL)"); 
$session->db->write("insert into encryptTest values ('1','ABC123')");

#----------------------------------------------------------------------------
# Tests
WebGUI::Error->Trace(1);    # Turn on tracing of uncaught Exception::Class exceptions
plan tests => 24;

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
    isa_ok(WebGUI::Crypt->new( $session ), 'WebGUI::Crypt', 'Returns a happy WebGUI::Crypt'); 
}

#######################################################################
#
# Config File has crypt settings
#
#######################################################################

{
    is(ref $session->config->get('crypt'), 'HASH', 'Config file has the crypt hash');
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
}

#######################################################################
#
# session->crypt->setProvider
#
#######################################################################
{
    eval{$session->crypt->setProvider()};
    my $e = Exception::Class->caught();
    isa_ok($e, 'WebGUI::Error::InvalidParam', 'Must provide arguments to setProvider');
}
{
    eval{$session->crypt->setProvider({})};
    my $e = Exception::Class->caught();
    isa_ok($e, 'WebGUI::Error::InvalidParam', 'Must provide valid arguments to setProvider');
}
{
    is($session->crypt->setProvider({table=>'encryptTest', field=>'testField', key=>'id','providerId'=>'Test'}),1,'Valid arguments should set the provider');
}
{
    is($session->crypt->setProvider({table=>'encryptTest', field=>'testField', key=>'id','providerId'=>'None'}),1,'Valid arguments should update the provider');
}

#######################################################################
#
# session->crypt->_parseHeader
#
#######################################################################
{
    my ($a,$b) = $session->crypt->_parseHeader("hello");
    is($a,'None', 'No header returns the None provider');
    is($b,'hello', 'No header returns the None provider and text');
}
{
    my ($a,$b) = $session->crypt->_parseHeader("CRYPT:None:hello");
    is($a,'None', 'Header returns the None provider');
    is($b,'hello', 'Header returns the None provider and text');
}
#######################################################################
#
# session->crypt->isEnabled
#
#######################################################################
{
    my $enabled = $session->setting->get('cryptEnabled') ? 0 : 1;
    is($session->crypt->notEnabled(),  $enabled, 'Does enabled show the correct setting');
}
#######################################################################
#
# session->crypt->lookupProviderId
#
#######################################################################
{
    eval{$session->crypt->lookupProviderId};
    my $e = Exception::Class->caught();
    isa_ok($e, 'WebGUI::Error::InvalidParam', 'Must provide a hashref as argument');
}
{
    eval{$session->crypt->lookupProviderId({})};
    my $e = Exception::Class->caught();
    isa_ok($e, 'WebGUI::Error::InvalidParam', 'Must provide a valid hashref as argument');
}
{
    is($session->crypt->lookupProviderId({table=>'encryptTest',field => 'testField'}),'None', 'ProviderId should be None');
}
#######################################################################
#
# session->_getProvider
#
#######################################################################
{
    eval{$session->crypt->_getProvider()};
    my $e = Exception::Class->caught();
    isa_ok($e, 'WebGUI::Error::InvalidParam', 'Must provide a hashref as argument');
}
{
    eval{$session->crypt->_getProvider({})};
    my $e = Exception::Class->caught();
    isa_ok($e, 'WebGUI::Error::InvalidParam', 'Must provide a hashref with either providerId or table and field.');
}
{
    isa_ok( $session->crypt->_getProvider({providerId => 'None'}), 'WebGUI::Crypt::None', 'There should always be a None provider to test against');
}
#######################################################################
#
# session->crypt/decrypt?_hex
#
#######################################################################
{
    eval{$session->crypt->encrypt()};
    my $e = Exception::Class->caught();
    isa_ok($e, 'WebGUI::Error::InvalidParam', 'encrypt must have $plaintext defined.');
}
{
    eval{$session->crypt->decrypt()};
    my $e = Exception::Class->caught();
    isa_ok($e, 'WebGUI::Error::InvalidParam', 'encrypt must have $cyphertext defined.');
}
{
    eval{$session->crypt->decrypt_hex()};
    my $e = Exception::Class->caught();
    isa_ok($e, 'WebGUI::Error::InvalidParam', 'decrypt_hex must have $cyphertext defined.');
}
{
    eval{$session->crypt->encrypt_hex()};
    my $e = Exception::Class->caught();
    isa_ok($e, 'WebGUI::Error::InvalidParam', 'encrypt_hex must have $plaintext defined.');
}





#----------------------------------------------------------------------------
# clean up test case
$session->db->write("drop table if exists `encryptTest`");
$session->db->write("delete from cryptFieldProviders where `field` = 'testField' and `table` = 'encryptTest' and `key` = 'id'");
