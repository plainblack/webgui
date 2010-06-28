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
use WebGUI::Macro::PickLanguage;

use Test::More; # increment this value for each test you create
use Test::Deep;
use Test::MockObject;
use Test::MockObject::Extends;
use WebGUI::Test::MockAsset;
  
my $session = WebGUI::Test->session;
 
my $numTests = 3;
 
plan tests => $numTests;
 
my $macroMock = Test::MockObject->new({});
$macroMock->set_isa('WebGUI::Macro::PickLanguage');
$macroMock->set_true('process');
 
#test for normal use

my $templateId = 'PICKLANGUAGE_TEMPLATE_';
 
my $templateMock = WebGUI::Test::MockAsset->new('WebGUI::Asset::Template');
$templateMock->mock_id($templateId);
my $templateVars;
$templateMock->mock('process', sub { $templateVars = $_[1]; } );
 
 
{
      WebGUI::Macro::PickLanguage::process($session,$templateMock->getId);
       
      cmp_deeply(
          $templateVars,
              {
                      lang_loop => [
                      {       'language_url'      => '?op=setLanguage;language=English',
                              'language_lang'     => 'English',
                              'language_langAbbr' => 'en',
                              'language_langAbbrLoc' => 'US',
                              'language_langEng'     => 'English',
                              'language_isCurrent'   => 1,
                      },
              ],
		delete_url 	=> '?op=setLanguage;language=delete;',
		delete_label	=> 'Go back to profile language.',
              },
              'some template variables are created'
      );
}

#test when template Id is left empty

$templateId = '';
my $templateNoId = $templateMock->mock('process','');
$templateMock->mock_id($templateId);
$templateMock->mock('process', sub { $templateVars = $_[1]; } );

{
      WebGUI::Macro::PickLanguage::process($session,$templateMock->getId);

      cmp_deeply(
          $templateVars,
              {
                      lang_loop => [
                      {       'language_url' => '?op=setLanguage;language=English',
                              'language_lang' => 'English',
                              'language_langAbbr' => 'en',
                              'language_langAbbrLoc' => 'US',
                              'language_langEng' => 'English',
                              'language_isCurrent'   => 1,
                      },
              ],
			delete_url => '?op=setLanguage;language=delete;',
			delete_label => "Go back to profile language.",
              },
              'some template variables are created, when no templateId is passed on with the macro'
      );
}


#test for an incorrect template Id 

$templateId = '1234567890123456789012';
my $templateWrongId = $templateMock->mock('process','');
$templateMock->set_always('getId', $templateId);
$templateMock->mock('process', sub { $templateVars = $_[1]; } );
my $error;


{
      $error = WebGUI::Macro::PickLanguage::process($session,$templateMock->getId);

        is($error,'Could not instanciate template with id [1234567890123456789012]',"Template from the wrong namespace should not be initiated");
}

