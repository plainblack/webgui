# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#------------------------------------------------------------------

# Write a little about what this script tests.
# 
#

use FindBin;
use strict;
use lib "$FindBin::Bin/../../lib";
use Test::More;
use Test::Deep;
use Test::MockObject;

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
$session->db->dbh->do('drop table if exists dummyTable');
$session->db->dbh->do(<<EOSQL);
create table dummyTable(
    assetId      varchar(22) NOT NULL,
    revisionDate bigint(20)  NOT NULL,
    PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1
EOSQL

package WebGUI::Asset::DummyComments;

use Moose;
use WebGUI::Definition::Asset;
use WebGUI::Types;
extends 'WebGUI::Asset';
define tableName => 'dummyTable';
with 'WebGUI::Role::Asset::Comments';

package main;

use WebGUI::Asset;

my $mock = Test::MockObject->new();
$mock->fake_module('WebGUI::Asset::DummyComments', '__DUMMY__DUMMY__' => sub {}, );

#----------------------------------------------------------------------------
# put your tests here

my $dummy = WebGUI::Asset->getDefault($session)->addChild({
    className   => 'WebGUI::Asset::DummyComments',
    url         => '/home/shawshank',
    title       => 'Dummy Title',
    synopsis    => 'Dummy Synopsis',
    description => 'Dummy Description',
});
my $tag = WebGUI::VersionTag->getWorking($session);
addToCleanup($tag);

ok $dummy->does('WebGUI::Role::Asset::Comments'), 'dummy object does the right role';
$dummy->comments([{ television => 'drop', misdemeanor => 'felony', }]);
$dummy->write();

my $json = $session->db->quickScalar('select comments from assetAspectComments where assetId=?', [$dummy->assetId]);
like $json, qr/"television":"drop"/, 'checking serialize to json in the db';

my $dummy2 = $dummy->cloneFromDb();
cmp_deeply(
    $dummy2->comments(),
    [ { television => 'drop', misdemeanor => 'felony', }],
    'checking JSON and deserialize from db'
);

done_testing();

#----------------------------------------------------------------------------
# Cleanup
END {
    $session->db->dbh->do('drop table if exists dummyTable');
}
#vim:ft=perl
