# Tests WebGUI::Asset::Wobject::Survey Reporting
#
#

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../../lib";
use Test::More;
use Test::Deep;
use Data::Dumper;
use Storable qw/dclone/;
use WebGUI::Test;    # Must use this before any other WebGUI modules
use WebGUI::Session;
WebGUI::Error->Trace(1);    # Turn on tracing of uncaught Exception::Class exceptions

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# put your tests here

my $import_node = WebGUI::Asset->getImportNode($session);

# Create a Survey
my $survey = $import_node->addChild( { className => 'WebGUI::Asset::Wobject::Survey', } );
WebGUI::Test->addToCleanup($survey);

my $sJSON = $survey->surveyJSON;

# Load bare-bones survey, containing a single section (S0)
$sJSON->update([0], { variable => 'S0' });

# Add 1 question to S0
$sJSON->newObject([0]);    # S0Q0
$sJSON->update([0,0], { variable => 'toes', questionType => 'Multiple Choice' });
$sJSON->update([0,0,0], { text => 'one',});
$sJSON->update([0,0,1], { text => 'two',});
$sJSON->update([0,0,2], { text => 'more than two',});
$sJSON->update([0,1], { variable => 'name', questionType => 'Text' });

$survey->addType('toes', [0,0]);

$survey->persistSurveyJSON;  ##This does not update the SurveyJSON object cacched in the Survey object
$survey=$survey->cloneFromDb;

my $asset_data = $survey->exportAssetData();

ok exists $asset_data->{question_types}, 'question_types entry exists in asset data to package';
ok exists $asset_data->{question_types}->{toes}, 'the toes type in a question type' or
    explain $asset_data;
ok !exists $asset_data->{question_types}->{name}, 'name question not in question types';

$asset_data->{question_types}->{fingers} = $asset_data->{question_types}->{toes};

$survey->importAssetCollateralData($asset_data);

$survey = $survey->cloneFromDb;
my $multipleChoiceTypes = $survey->surveyJSON->multipleChoiceTypes;

ok exists $multipleChoiceTypes->{fingers}, 'fingers type imported as package collateral data';
ok exists $multipleChoiceTypes->{toes}, 'still have toes, too';

done_testing();

#vim:ft=perl
