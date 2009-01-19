# Tests higher-level Use Case of a Wobject assigned to a Rule with user attempting access
#
# Make sure LOGLEVEL is set to WARN or above to avoid skewing benchmarks
#
#
# Uncomment the appropriate section and run:
#    perl -d:Profile t/Flux/profile.pl && less prof.out
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

# Do my work in the import node
my $node       = WebGUI::Asset->getImportNode($session);
my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set( { name => 'Flux Benchmark Test' } );

# Create a test asset
my $article1 = $node->addChild( { className => 'WebGUI::Asset::Wobject::Article' } );
my $article1_id = $article1->getId();

# Create a test User and group
my $user    = WebGUI::User->new( $session, 'new' );
my $userId  = $user->userId();
my $group   = WebGUI::Group->new( $session, 'new' );
my $groupId = $group->getId();
$user->addToGroups( [$groupId] );
$user->profileField( 'firstName', 'George' );

#---------------------------------
print "[Profiling]\n";


# Simple TextValue
#run_loop( expr_text( create_rule() ) );

# Simple Group - shows that group checking is the more expensive that Flux machinery
#run_loop( expr_group( create_rule() ) );

# Complex Rule
my $deep_rule_id = create_combined( create_combined( create_combined() ) )->getId();
my $second_deep_rule_id = create_combined( create_combined( create_combined() ) )->getId();
my $complex_rule
    = expr_fluxrule( expr_fluxrule( create_rule(), $deep_rule_id ), $second_deep_rule_id );
run_loop($complex_rule);


#---------------------------------
sub run_loop {
    my $rule_id = shift->getId();
    for my $i ( 1 .. 1000 ) {
        WebGUI::Flux->evaluateFor( { user => $user, fluxRuleId => $rule_id, assetId => $article1_id } );
    }
}

#---------------------------------
# Same utilities functions as in benchmark.pl below..
#---------------------------------

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
