#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use strict;
use lib "$FindBin::Bin/../../lib";

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Utility;
use WebGUI::Workflow::Activity::CryptUpdateFieldProviders;

use Test::More;

plan tests => 2; # increment this value for each test you create

#Create a session
my $session = WebGUI::Test->session;


############
# Create test data
############

$session->db->write("drop table if exists `encryptTest`");
$session->db->write("CREATE TABLE `encryptTest` ( `id` char(22)  NOT NULL, `testField` LONGTEXT  NOT NULL)");
$session->db->write("insert into encryptTest values ('1','ABC123')");

############
# Set up mock config entry (dont forget to reset it
############

#store config for automagic reset when the test ends
WebGUI::Test->originalConfig("crypt");
my $crypt = $session->config->get('crypt');
$crypt->{'cryptTestDeleteMe'} = {provider=>'WebGUI::Crypt::Simple', name=>'testProvider', key=>'123ABC'};
$session->config->set('crypt',$crypt);

############
# Set the provider to simple for the test table which also starts the workflow
############

$session->crypt->setProvider({table=>'encryptTest', field=>'testField', key=>'id','providerId'=>'cryptTestDeleteMe'});

############
# Make sure the test string is no longer plain text
############

my $ciphertext = $session->db->quickScalar("select testField from encryptTest where id = '1'");
{
    isnt('ABC123',$ciphertext,'Text should not longer be plain text');
}

############
# Set the provider to None for the test table which also starts the workflow
############

$session->crypt->setProvider({table=>'encryptTest', field=>'testField', key=>'id','providerId'=>'None'});

############
# Make sure the test string is now plain text
############

my $ciphertext = $session->db->quickScalar("select testField from encryptTest where id = '1'");
{
    is('ABC123',$ciphertext,'Text should now be plain text');
}

############
# Clean up test
############

$session->db->write("drop table if exists `encryptTest`");
$session->db->write("delete from cryptFieldProviders where `table` = 'encryptTest' and `field` = 'testField'");
