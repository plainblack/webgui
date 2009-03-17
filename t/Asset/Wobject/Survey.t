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
my $tests = 11;
plan tests => $tests + 1;

#----------------------------------------------------------------------------
# put your tests here

my $usedOk = use_ok('WebGUI::Asset::Wobject::Survey');
my ($user, $import_node, $survey);

SKIP: {

skip $tests, "Unable to load Survey" unless $usedOk;
$user = WebGUI::User->new( $session, 'new' );
$import_node = WebGUI::Asset->getImportNode($session);

# Create a Survey
$survey = $import_node->addChild( { className => 'WebGUI::Asset::Wobject::Survey', } );
isa_ok($survey, 'WebGUI::Asset::Wobject::Survey');

# Load bare-bones survey, containing a single section (S0)
$survey->surveyJSON_update([0], { variable => 'S0' });

# Add 2 questions to S0
$survey->surveyJSON_newObject([0]);    # S0Q0
$survey->surveyJSON_update([0,0], { variable => 'S0Q0' });
$survey->surveyJSON_newObject([0]);    # S0Q1
$survey->surveyJSON_update([0,1], { variable => 'S0Q1' });

# Add a new section (S1)
$survey->surveyJSON_newObject([]);     # S1
$survey->surveyJSON_update([1], { variable => 'S1' });

# Add 2 questions to S1
$survey->surveyJSON_newObject([1]);    # S1Q0
$survey->surveyJSON_update([1,0], { variable => 'S1Q0' });
$survey->surveyJSON_newObject([1]);    # S1Q1
$survey->surveyJSON_update([1,1], { variable => 'S1Q1' });

# Now start a response as admin user
$session->user( { userId =>3 } );
$survey->responseIdCookies(0);

my $responseId = $survey->responseId;
my $s = WebGUI::Asset::Wobject::Survey->newByResponseId($session, $responseId);
is($s->getId, $survey->getId, 'newByResponseId returns same Survey');

#for my $address (@{ $survey->responseJSON->surveyOrder }) {
#    diag (Dumper $address);
#}

# www_jumpTo
{
    # Check a simple www_jumpTo request
    WebGUI::Test->getPage( $survey, 'www_jumpTo', { formParams => {id => '0'} } );
    is( $session->http->getStatus, '201', 'Page request ok' ); # why is "201 - created" status used??
    is($survey->responseJSON->nextResponse, 0, 'S0 is the first response');
    
    tie my %expectedSurveyOrder, 'Tie::IxHash';
    %expectedSurveyOrder =  (
        'undefined' => 0,
        '0' => 0,
        '0-0' => 0,
        '0-1' => 1,
        '1' => 2,
        '1-0' => 2,
        '1-1' => 3,
    );
    while (my ($id, $index) = each %expectedSurveyOrder) {
        WebGUI::Test->getPage( $survey, 'www_jumpTo', { formParams => {id => $id} } );
        is($survey->responseJSON->nextResponse, $index, "jumpTo($id) sets nextResponse to $index");
    }
}


}

#----------------------------------------------------------------------------
# Cleanup
END {
    $user->delete() if $user;
    $survey->purge() if $survey;

    my $versionTag = WebGUI::VersionTag->getWorking( $session, 1 );
    $versionTag->rollback() if $versionTag;
}
