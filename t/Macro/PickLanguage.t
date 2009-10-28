#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------
use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";
 
use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Asset::Template;

use Test::More; # increment this value for each test you create
use Test::Deep;
use Test::MockObject;
use Test::MockObject::Extends;
  
my $session = WebGUI::Test->session;
 
my $numTests = 3;
 
$numTests += 1; #For the use_ok
 
plan tests => $numTests;
 
my $macro = 'WebGUI::Macro::PickLanguage';
my $loaded = use_ok($macro);
 
my $macroMock = Test::MockObject->new({});
$macroMock->set_isa('WebGUI::Macro::PickLanguage');
$macroMock->set_true('process');
 
#test for normal use

my $templateId = 'PICKLANGUAGE_TEMPLATE_';
 
my $templateMock = Test::MockObject->new({});
$templateMock->set_isa('WebGUI::Asset::Template');
$templateMock->set_always('getId', $templateId);
my $templateVars;
$templateMock->mock('process', sub { $templateVars = $_[1]; } );
 
 
{
      WebGUI::Test->mockAssetId($templateId, $templateMock);
      WebGUI::Macro::PickLanguage::process($session,$templateMock->getId);
       
      cmp_deeply(
          $templateVars,
              {
                      lang_loop => [
                      {       'language_url' => '?op=setLanguage;language=English',
                              'language_lang' => 'English',
                              'language_langAbbr' => 'en',
                              'language_langAbbrLoc' => 'US',
                              'language_langEng' => 'English'
                      },
              ],
              },
              'some template variables are created'
      );
      WebGUI::Test->unmockAssetId($templateId);
}

#test when template Id is left empty

$templateId = '';
my $templateNoId = $templateMock->mock('process','');
$templateMock->set_always('getId', $templateId);
$templateMock->mock('process', sub { $templateVars = $_[1]; } );

{

      WebGUI::Test->mockAssetId($templateId, $templateMock);
      WebGUI::Macro::PickLanguage::process($session,$templateMock->getId);

      cmp_deeply(
          $templateVars,
              {
                      lang_loop => [
                      {       'language_url' => '?op=setLanguage;language=English',
                              'language_lang' => 'English',
                              'language_langAbbr' => 'en',
                              'language_langAbbrLoc' => 'US',
                              'language_langEng' => 'English'
                      },
              ],
              },
              'some template variables are created, when no templateId is passed on with the macro'
      );
      WebGUI::Test->unmockAssetId($templateId);
}


#{
#      WebGUI::Test->mockAssetId($templateNoId, $templateMock);
#      $error = WebGUI::Macro::PickLanguage::process($session,$templateMock->getId);
#
#	is($error,'Could not instanciate template with id []',"Empty template Id should return error");
#	
#	WebGUI::Test->unmockAssetId($templateNoId);
#}

#test for an incorrect template Id 

$templateId = '1234567890123456789012';
my $templateWrongId = $templateMock->mock('process','');
$templateMock->set_always('getId', $templateId);
$templateMock->mock('process', sub { $templateVars = $_[1]; } );
my $error;


{
      WebGUI::Test->mockAssetId($templateWrongId, $templateMock);
      $error = WebGUI::Macro::PickLanguage::process($session,$templateMock->getId);

        is($error,'Could not instanciate template with id [1234567890123456789012]',"Template from the wrong namespace should not be initiated");
	WebGUI::Test->unmockAssetId($templateWrongId);
}

