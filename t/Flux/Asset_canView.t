# Tests Flux-delegation in Assets.pm's canView method
#
#
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More;
use Test::Deep;
use Data::Dumper;
use Readonly;
use WebGUI::Test;    # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Flux;
use WebGUI::Flux::Rule;
WebGUI::Error->Trace(1);    # Turn on tracing of uncaught Exception::Class exceptions

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests
plan tests => 4;

# Start with a clean slate
$session->db->write('delete from fluxRule');
$session->db->write('delete from fluxRuleUserData');
$session->db->write('delete from fluxExpression');

# Do our work in the import node
my $node       = WebGUI::Asset->getImportNode($session);
my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set( { name => 'Flux Benchmark Test' } );

# Create a test asset
my $article1 = $node->addChild( { className => 'WebGUI::Asset::Wobject::Article' } );
$article1->update( { 
    title => 'Test Article 1', 
    description => 'Test Article 1 Content..',
} );
my $article1_id = $article1->getId();

# Create a test User and group
my $user    = WebGUI::User->new( $session, 'new' );
my $userId  = $user->userId();
my $group   = WebGUI::Group->new( $session, 'new' );
my $groupId = $group->getId();

# Make the article belong to our group
$article1->update(
    {   
    groupIdView => $groupId,
    ownerUserId => 1,          # don't want this to be our user otherwise canView will short-circuit
    }
);

ok(!$article1->canView($userId), q{User doesn't belong to group so can't view});

# Now add the user to our group
$user->addToGroups( [$groupId] );
ok($article1->canView($userId), q{..but now they are do and can});

# Create a test rule that fails
my $rule = WebGUI::Flux::Rule->create($session);
$rule->addExpression(
    {   operand1     => 'TextValue',
        operand1Args => '{"value":  "apples"}',
        operator     => 'IsEqualTo',
        operand2     => 'TextValue',
        operand2Args => '{"value":  "oranges"}',
        name         => 'A Rule that goes boom',
    }
);

# Turn flux on
$session->setting->set('fluxEnabled', 1);

# .. and flux the article
$article1->update(
    {   
    fluxEnabled => 1,
    fluxRuleIdView => $rule->getId(),
    }
);

ok(!$article1->canView($userId), q{..and now flux prevents access});

# Turn flux off
$session->setting->set('fluxEnabled', 0);

# And show that flux is now out of the loop
ok($article1->canView($userId), q{..until we disable flux site-wide!});

#----------------------------------------------------------------------------
# Cleanup
END {
    $session->db->write('delete from fluxRule');
    $session->db->write('delete from fluxRuleUserData');
    $session->db->write('delete from fluxExpression');
    $versionTag->rollback() if $versionTag;
    $user->delete()         if $user;
    $group->delete()        if $group;
}
