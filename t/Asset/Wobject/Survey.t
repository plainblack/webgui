# Tests WebGUI::Asset::Wobject::Survey
#
#

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Test::More;
use Test::Deep;
use Data::Dumper;
use WebGUI::Test;    # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests
plan tests => 2;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Asset::Wobject::Survey');
my $user = WebGUI::User->new( $session, 'new' );
my $import_node = WebGUI::Asset->getImportNode($session);

# Create a Survey
my $survey = $import_node->addChild( { className => 'WebGUI::Asset::Wobject::Survey', } );
isa_ok($survey, 'WebGUI::Asset::Wobject::Survey');

#----------------------------------------------------------------------------
# Cleanup
END {
    $user->delete() if $user;
    $survey->purge() if $survey;

    my $versionTag = WebGUI::VersionTag->getWorking( $session, 1 );
    $versionTag->rollback() if $versionTag;
}
