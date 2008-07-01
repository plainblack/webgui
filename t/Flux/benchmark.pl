# Tests higher-level Use Case of a Wobject assigned to a Rule with user attempting access
#
# Make sure LOGLEVEL is set to WARN or above to avoid skewing benchmarks
#
# Output from my dev machine:
#
#    [Benchmarks]
#                Rate f_deep f_complex f_combined f_group f_fluxrule f_dt group f_profile f_text
#    f_deep     161/s     --      -25%       -25%    -47%       -62% -72%  -74%      -79%   -80%
#    f_complex  216/s    34%        --        -0%    -29%       -50% -62%  -64%      -72%   -73%
#    f_combined 216/s    34%        0%         --    -29%       -50% -62%  -64%      -72%   -73%
#    f_group    304/s    89%       41%        41%      --       -29% -47%  -50%      -60%   -62%
#    f_fluxrule 430/s   167%       99%        99%     41%         -- -25%  -29%      -44%   -46%
#    f_dt       575/s   257%      166%       166%     89%        34%   --   -6%      -25%   -27%
#    group      609/s   278%      182%       182%    100%        42%   6%    --      -20%   -23%
#    f_profile  765/s   375%      254%       254%    152%        78%  33%   26%        --    -3%
#    f_text     790/s   390%      266%       265%    160%        84%  37%   30%        3%     --
#
# For profiling use a command like:
#    FLUX_PROFILING=1 perl -d:Profile t/Flux/benchmark.pl && less prof.out
#
#
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Data::Dumper;
use Readonly;
use WebGUI::Test;    # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Flux;
use WebGUI::Flux::Rule;
WebGUI::Error->Trace(1);    # Turn on tracing of uncaught Exception::Class exceptions
use Benchmark qw( cmpthese );

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;
$session->config->set( "disableCache", 1 );

#----------------------------------------------------------------------------

# Start with a clean slate
$session->db->write('delete from fluxRule');
$session->db->write('delete from fluxRuleUserData');
$session->db->write('delete from fluxExpression');

# Do our work in the import node
my $node       = WebGUI::Asset->getImportNode($session);
my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set( { name => 'Flux Benchmark Test' } );

# Note that we need to use 'our' package variables because the Benchmark module does string evals

# Create a test asset
our $article1 = $node->addChild( { className => 'WebGUI::Asset::Wobject::Article' } );
our $article1_id = $article1->getId();

# Create a test User and group
our $user    = WebGUI::User->new( $session, 'new' );
our $userId  = $user->userId();
our $group   = WebGUI::Group->new( $session, 'new' );
our $groupId = $group->getId();
$user->addToGroups( [$groupId] );
$user->profileField( 'firstName', 'George' );

#---------------------------------
if ( $ENV{FLUX_PROFILING} ) {
    print "[Profiling]\n";

    our $deep_rule_id = create_combined( create_combined( create_combined() ) )->getId();
    my $second_deep_rule_id = create_combined( create_combined( create_combined() ) )->getId();
    our $complex_rule_id
        = expr_fluxrule( expr_fluxrule( create_rule(), $deep_rule_id ), $second_deep_rule_id )->getId();

    WebGUI::Flux->generateGraph($session);

    for my $i ( 1 .. 1000 ) {
        WebGUI::Flux->evaluateFor( { user => $user, fluxRuleId => $complex_rule_id, assetId => $article1_id } );
    }
    exit;
}

#---------------------------------
print "[Benchmarks]\n";

our $group_rule_id    = expr_group( create_rule('Simple Group') )->getId();
our $text_rule_id     = expr_text( create_rule('Simple TextValue') )->getId();
our $datetime_rule_id = expr_datetime( create_rule('DateTime with Modifier') )->getId();
our $profile_rule_id  = expr_profile( create_rule('User Profile') )->getId();
our $fluxrule_rule_id = expr_fluxrule( create_rule('Dependent Rule'), $text_rule_id )->getId();
our $combined_rule_id = create_combined()->getId();
our $deep_rule_id     = create_combined( create_combined( create_combined() ) )->getId();
my $second_deep_rule_id = create_combined( create_combined( create_combined() ) )->getId();
our $complex_rule_id
    = expr_fluxrule( expr_fluxrule( create_rule(), $deep_rule_id ), $second_deep_rule_id )->getId();

WebGUI::Flux->generateGraph($session);

cmpthese(
    -1,
    {   group => '$user->isInGroup($groupId)',
        f_group =>
            'WebGUI::Flux->evaluateFor({user => $user, fluxRuleId => $group_rule_id, assetId=> $article1_id})',
        f_text =>
            'WebGUI::Flux->evaluateFor({user => $user, fluxRuleId => $text_rule_id, assetId=> $article1_id})',
        f_dt =>
            'WebGUI::Flux->evaluateFor({user => $user, fluxRuleId => $datetime_rule_id, assetId=> $article1_id})',
        f_profile =>
            'WebGUI::Flux->evaluateFor({user => $user, fluxRuleId => $profile_rule_id, assetId=> $article1_id})',
        f_fluxrule =>
            'WebGUI::Flux->evaluateFor({user => $user, fluxRuleId => $fluxrule_rule_id, assetId=> $article1_id})',
        f_combined =>
            'WebGUI::Flux->evaluateFor({user => $user, fluxRuleId => $combined_rule_id, assetId=> $article1_id})',
        f_deep =>
            'WebGUI::Flux->evaluateFor({user => $user, fluxRuleId => $deep_rule_id, assetId=> $article1_id})',
        f_complex =>
            'WebGUI::Flux->evaluateFor({user => $user, fluxRuleId => $complex_rule_id, assetId=> $article1_id})',
    }
);

#---------------------------------

my $rule_creation_counter = 1;

sub create_rule {
    my $name = shift;
    my $rule = WebGUI::Flux::Rule->create($session);
    $name = $name ? $name : 'Test Rule ' . $rule_creation_counter++;
    $rule->update( { name => $name } );
    return $rule;
}

sub expr_group {
    my $rule = shift;
    $rule->addExpression(
        {   operand1     => 'Group',
            operand1Args => qq[{"groupId":  "$groupId"}],
            operator     => 'IsEqualTo',
            operand2     => 'TruthValue',
            operand2Args => '{"value":  "1"}',
            name         => 'Group Expr',
        }
    );
    return $rule;
}

sub expr_text {
    my $rule = shift;
    $rule->addExpression(
        {   operand1     => 'TextValue',
            operand1Args => '{"value":  "DURA-ACE"}',
            operator     => 'IsEqualTo',
            operand2     => 'TruthValue',
            operand2Args => '{"value":  "DURA-ACE"}',
            name         => 'TextValue eq TruthValue Expr',
        }
    );
    return $rule;
}

sub expr_datetime {
    my $rule = shift;

    # Create a sample DateTime string, usually this would come from the db
    # and hence always be in UTC
    my $dt = DateTime->new(
        year      => 1984,
        month     => 10,
        day       => 16,
        hour      => 16,
        minute    => 12,
        second    => 47,
        time_zone => 'UTC',
    );
    my $dbDateTime = WebGUI::DateTime->new( $dt->epoch() )->toDatabase();
    $rule->addExpression(
        {   operand1             => 'DateTime',
            operand1Args         => qq[{"value":  "$dbDateTime"}],
            operand1Modifier     => 'DateTimeFormat',
            operand1ModifierArgs => qq[{"pattern": "%x %X", "time_zone": "UTC"}],
            operator             => 'IsEqualTo',
            operand2             => 'TextValue',
            operand2Args         => '{"value":  "Oct 16, 1984 4:12:47 PM"}',
            name                 => 'DateTime with Modifier eq TextValue Expr',
        }
    );
    return $rule;
}

sub expr_profile {
    my $rule = shift;
    $rule->addExpression(
        {   operand1     => 'UserProfileField',
            operand1Args => '{"field":  "firstName"}',
            operator     => 'IsEqualTo',
            operand2     => 'TextValue',
            operand2Args => '{"value":  "George"}',
            name         => 'UserProfileField eq TextValue Expr',
        }
    );
    return $rule;
}

sub expr_fluxrule {
    my $rule              = shift;
    my $dependent_rule_id = shift;

    $rule->addExpression(
        {   operand1     => 'FluxRule',
            operand1Args => qq[{"fluxRuleId":  "$dependent_rule_id"}],
            operator     => 'IsEqualTo',
            operand2     => 'TruthValue',
            operand2Args => '{"value":  "1"}',
            name         => 'FluxRule Expr',
        }
    );
    return $rule;
}

sub create_combined {
    my $make_dependent_on = shift;

    my $rule = create_rule('Combined Rule');
    expr_group($rule);
    expr_text($rule);
    expr_datetime($rule);
    expr_profile($rule);
    $rule->update( { combinedExpression => 'e1 and e2 and e3 and e4' } );
    if ($make_dependent_on) {
        expr_fluxrule( $rule, $make_dependent_on->getId() );
        $rule->update( { combinedExpression => 'e1 and e2 and e3 and e4 and e5' } );
    }
    return $rule;
}

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
