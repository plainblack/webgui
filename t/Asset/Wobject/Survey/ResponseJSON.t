# Tests WebGUI::Asset::Wobject::Survey
#
#

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../../lib";
use Test::More;
use Test::Deep;
use Data::Dumper;
use WebGUI::Test;    # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Asset::Wobject::Survey::SurveyJSON;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests
my $tests = 13;
plan tests => $tests + 1;

#----------------------------------------------------------------------------
# put your tests here

my $usedOk = use_ok('WebGUI::Asset::Wobject::Survey::ResponseJSON');
my ($responseJSON);

SKIP: {

skip $tests, "Unable to load ResponseJSON" unless $usedOk;

####################################################
#
# new, part 1
#
####################################################

my $newTime = time();
$responseJSON = WebGUI::Asset::Wobject::Survey::ResponseJSON->new('{}', $session->log);
isa_ok($responseJSON , 'WebGUI::Asset::Wobject::Survey::ResponseJSON');

is($responseJSON->lastResponse(), -1, 'new: default lastResponse is -1');
is($responseJSON->{questionsAnswered}, 0, 'new: questionsAnswered is 0 by default');
cmp_ok((abs$responseJSON->{startTime} - $newTime), '<=', 2, 'new: by default startTime set to time');
is_deeply( $responseJSON->responses, {}, 'new: by default, responses is an empty hashref');
is_deeply( $responseJSON->surveyOrder, [], 'new: by default, responses is an empty arrayref');

my $now = time();
my $rJSON = WebGUI::Asset::Wobject::Survey::ResponseJSON->new(qq!{ "startTime": $now }!, $session->log);
cmp_ok(abs($rJSON->startTime() - $now), '<=', 2, 'new: startTime set using JSON');

####################################################
#
# startTime
#
####################################################

$rJSON->startTime(780321600);
is($rJSON->startTime, 780321600, 'startTime: set and get');

####################################################
#
# hasTimedOut
#
####################################################

##Reset for next set of tests
$rJSON->startTime(time());

ok( ! $rJSON->hasTimedOut(1), 'hasTimedOut, not timed out, checked with 1 minute timeout');
ok( ! $rJSON->hasTimedOut(0), 'hasTimedOut, not timed out, checked with 0 minute timeout');

$rJSON->startTime(time()-7200);
ok(   $rJSON->hasTimedOut(1),    'hasTimedOut, timed out');
ok( ! $rJSON->hasTimedOut(0),    'hasTimedOut, bad limit');
ok( ! $rJSON->hasTimedOut(4*60), 'hasTimedOut, limit check');

}

####################################################
#
# Utility test routines
#
####################################################

sub buildSurveyJSON {
    my $session = shift;
    my $sjson = WebGUI::Asset::Wobject::Survey::SurveyJSON->new(undef, $session->log);
    ##Build 4 sections
    $sjson->newObject([]);
    $sjson->newObject([]);
    $sjson->newObject([]);
    $sjson->newObject([]);
    ##Add questions to the sections
    $sjson->newObject([0]);
    $sjson->newObject([0]);
    $sjson->newObject([0]);
    $sjson->newObject([1]);
    $sjson->newObject([1]);
    ##Section 3 has no questions
    $sjson->newObject([3]);
    $sjson->newObject([3]);
    $sjson->newObject([3]);
    ##Add questions
    $sjson->updateQuestionAnswers([0,0], 'Email');
    $sjson->updateQuestionAnswers([0,1], 'Phone number');
    $sjson->updateQuestionAnswers([0,2], 'Yes/No');
    $sjson->updateQuestionAnswers([1,0], 'True/False');
    $sjson->updateQuestionAnswers([1,1], 'Gender');
    $sjson->updateQuestionAnswers([3,0], 'Date Range');
    $sjson->updateQuestionAnswers([3,1], 'Ideology');
    $sjson->updateQuestionAnswers([3,2], 'Email');
    ##Title the sections and questions
    $sjson->section([0])->{title} = "Section 0";
    $sjson->section([1])->{title} = "Section 1";
    $sjson->section([2])->{title} = "Section 2";
    $sjson->section([3])->{title} = "Section 3";
    $sjson->question([0,0])->{title} = "Question 0-0";
    $sjson->question([0,1])->{title} = "Question 0-1";
    $sjson->question([0,2])->{title} = "Question 0-2";
    $sjson->question([1,0])->{title} = "Question 1-0";
    $sjson->question([1,1])->{title} = "Question 1-1";
    $sjson->question([3,0])->{title} = "Question 3-0";
    $sjson->question([3,1])->{title} = "Question 3-1";
    $sjson->question([3,2])->{title} = "Question 3-2";
    return $sjson;
}

#----------------------------------------------------------------------------
# Cleanup
END { }
