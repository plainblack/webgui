# Tests WebGUI::Flux::Operand::AssetId
#
#

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Test::More;
use Test::Deep;
use Data::Dumper;
use Readonly;
use WebGUI::Test;    # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Flux::Rule;
use JSON;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;
#WebGUI::Error->Trace(1);

#----------------------------------------------------------------------------
# Tests
plan tests => 3;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Flux::Operand::AssetId');
my $user = WebGUI::User->new( $session, 'new' );
my $import_node = WebGUI::Asset->getImportNode($session);

# Create an Asset
my $article = $import_node->addChild( { className => 'WebGUI::Asset::Wobject::Article', } );
my $article_id = $article->getId();

{
    my $rule = WebGUI::Flux::Rule->create($session);
    $rule->addExpression(
        {   operand1     => 'AssetId',
            operand1Args => encode_json({}),
            operator     => 'IsEqualTo',
            operand2     => 'TextValue',
            operand2Args => encode_json({'value' => $article->getId}),
        }
    );
    ok( !$rule->evaluateFor( { user => $user } ), q{Evaluated independent of any assets} );
    ok( $rule->evaluateFor( { user => $user, assetId => $article->getId } ), q{Evaluated against our asset} );
}

#----------------------------------------------------------------------------
# Cleanup
END {
    $session->db->write('delete from fluxRule');
    $session->db->write('delete from fluxExpression');
    $session->db->write('delete from fluxRuleUserData');
    $user->delete() if $user;

    my $versionTag = WebGUI::VersionTag->getWorking( $session, 1 );
    $versionTag->rollback() if $versionTag;
}
