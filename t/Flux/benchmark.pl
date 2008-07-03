# Tests higher-level Use Case of a Wobject assigned to a Rule with user attempting access
#
# Make sure LOGLEVEL is set to WARN or above to avoid skewing benchmarks
#
# Output from my dev machine:
#
#    [Benchmarks]
#                 Rate f_complex f_deep f_combined f_group f_fluxrule f_dt group f_profile f_text
#    f_complex  28.3/s        --   -54%       -87%    -91%       -93% -95%  -95%      -96%   -97%
#    f_deep     61.5/s      117%     --       -72%    -81%       -84% -90%  -90%      -92%   -93%
#    f_combined  220/s      676%   257%         --    -32%       -42% -63%  -64%      -73%   -73%
#    f_group     322/s     1039%   424%        47%      --       -15% -46%  -48%      -60%   -61%
#    f_fluxrule  378/s     1235%   514%        72%     17%         -- -37%  -39%      -53%   -54%
#    f_dt        595/s     2005%   868%       171%     85%        58%   --   -3%      -26%   -28%
#    group       616/s     2079%   902%       181%     91%        63%   4%    --      -23%   -25%
#    f_profile   801/s     2732%  1203%       265%    149%       112%  35%   30%        --    -3%
#    f_text      824/s     2812%  1239%       275%    156%       118%  38%   34%        3%     --
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
$session->user( { userId => 3 } );
our $article1 = $node->addChild( { className => 'WebGUI::Asset::Wobject::Article' } );
$article1->update( { title => 'Test Article 1', description => 'Test Article 1 Content..' } );
our $article1_id = $article1->getId();

# Create a test User and group
our $user    = WebGUI::User->new( $session, 'new' );
our $userId  = $user->userId();
our $group   = WebGUI::Group->new( $session, 'new' );
our $groupId = $group->getId();
$user->addToGroups( [$groupId] );
$user->profileField( 'firstName', 'George' );

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

# Disable cache for these benchmarks
$session->config->set( "disableCache", 1 );
#cmpthese(
#    -10,
#    {   group => '$user->isInGroup($groupId)',
#        f_group =>
#            'WebGUI::Flux->evaluateFor({user => $user, fluxRuleId => $group_rule_id, assetId=> $article1_id})',
#        f_text =>
#            'WebGUI::Flux->evaluateFor({user => $user, fluxRuleId => $text_rule_id, assetId=> $article1_id})',
#        f_dt =>
#            'WebGUI::Flux->evaluateFor({user => $user, fluxRuleId => $datetime_rule_id, assetId=> $article1_id})',
#        f_profile =>
#            'WebGUI::Flux->evaluateFor({user => $user, fluxRuleId => $profile_rule_id, assetId=> $article1_id})',
#        f_fluxrule =>
#            'WebGUI::Flux->evaluateFor({user => $user, fluxRuleId => $fluxrule_rule_id, assetId=> $article1_id})',
#        f_combined =>
#            'WebGUI::Flux->evaluateFor({user => $user, fluxRuleId => $combined_rule_id, assetId=> $article1_id})',
#        f_deep =>
#            'WebGUI::Flux->evaluateFor({user => $user, fluxRuleId => $deep_rule_id, assetId=> $article1_id})',
#        f_complex =>
#            'WebGUI::Flux->evaluateFor({user => $user, fluxRuleId => $complex_rule_id, assetId=> $article1_id})',
#    }
#);

# Benchmark Requests
use WWW::Mechanize;
our $m = new WWW::Mechanize( autocheck => 0 );

# Login as admin
$m->get('http://dev.localhost.localdomain?op=auth;method=init');
$m->form_number(0);
$m->field( username   => 'admin' );
$m->field( identifier => '123qwe' );
$m->submit();

# Set working version
$m->get( '/?op=setWorkingVersionTag;tagId=' . $versionTag->getId() );

#$m->get( $article1->getUrl() );
#print $m->content();

$article1->update(
    {   groupIdView => $groupId,
        ownerUserId => 1,          # don't want this to be our user otherwise canView will short-circuit
    }
);
our $article1_url = $article1->getUrl();

# Article 2 - $group_rule_id
my $article2 = $node->addChild( { className => 'WebGUI::Asset::Wobject::Article' } );
$article2->update(
    {   fluxEnabled    => 1,
        fluxRuleIdView => $group_rule_id,
    }
);
our $article2_url = $article2->getUrl();

# Article 3 - $text_rule_id
my $article3 = $node->addChild( { className => 'WebGUI::Asset::Wobject::Article' } );
$article3->update(
    {   fluxEnabled    => 1,
        fluxRuleIdView => $text_rule_id,
    }
);
our $article3_url = $article3->getUrl();

# Article 4 - $datetime_rule_id
my $article4 = $node->addChild( { className => 'WebGUI::Asset::Wobject::Article' } );
$article4->update(
    {   fluxEnabled    => 1,
        fluxRuleIdView => $datetime_rule_id,
    }
);
our $article4_url = $article4->getUrl();

# Article 5 - $profile_rule_id
my $article5 = $node->addChild( { className => 'WebGUI::Asset::Wobject::Article' } );
$article5->update(
    {   fluxEnabled    => 1,
        fluxRuleIdView => $profile_rule_id,
    }
);
our $article5_url = $article5->getUrl();

# Article 6 - $fluxrule_rule_id
my $article6 = $node->addChild( { className => 'WebGUI::Asset::Wobject::Article' } );
$article6->update(
    {   fluxEnabled    => 1,
        fluxRuleIdView => $fluxrule_rule_id,
    }
);
our $article6_url = $article6->getUrl();

# Article 7 - $combined_rule_id
my $article7 = $node->addChild( { className => 'WebGUI::Asset::Wobject::Article' } );
$article7->update(
    {   fluxEnabled    => 1,
        fluxRuleIdView => $combined_rule_id,
    }
);
our $article7_url = $article7->getUrl();

# Article 8 - $deep_rule_id
my $article8 = $node->addChild( { className => 'WebGUI::Asset::Wobject::Article' } );
$article8->update(
    {   fluxEnabled    => 1,
        fluxRuleIdView => $deep_rule_id,
    }
);
our $article8_url = $article8->getUrl();

# Article 9 - $complex_rule_id
my $article9 = $node->addChild( { className => 'WebGUI::Asset::Wobject::Article' } );
$article9->update(
    {   fluxEnabled    => 1,
        fluxRuleIdView => $complex_rule_id,
    }
);
our $article9_url = $article9->getUrl();

# Re-enable cache for these benchmarks (requires wre restart to take effect)
$session->config->set( "disableCache", 1 );
cmpthese(
    300,
    {   group      => '$m->get($article1_url)',
        f_group    => '$m->get($article2_url)',
        f_text     => '$m->get($article3_url)',
        f_dt       => '$m->get($article4_url)',
        f_profile  => '$m->get($article5_url)',
        f_fluxrule => '$m->get($article6_url)',
        f_combined => '$m->get($article7_url)',
        f_deep     => '$m->get($article8_url)',
        f_complex  => '$m->get($article9_url)',

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
