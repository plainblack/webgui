# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#------------------------------------------------------------------

# This tests the moveField functions of the DataForm
# 
#

use strict;
use Test::More;
use Test::Deep;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Asset;
use WebGUI::Asset::Wobject::DataForm;
use WebGUI::VersionTag;
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

# Create a DataForm
my $df  = WebGUI::Asset->getImportNode( $session )
        ->addChild( {
            className           => "WebGUI::Asset::Wobject::DataForm",
            mailData            => 0,
            fieldConfiguration  => '[]',
        } );

my $dform = WebGUI::Asset->getDefault($session)->addChild({
    className           => "WebGUI::Asset::Wobject::DataForm",
    mailData            => 0,
});
$dform->createField('gotCaptcha', { type => 'Captcha', name => 'humanCheck', });

my $versionTag = WebGUI::VersionTag->getWorking($session);
WebGUI::Test->addToCleanup($versionTag);
$versionTag->commit;

#----------------------------------------------------------------------------
# Tests

plan tests => 4;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# _createForm

WebGUI::Test->interceptLogging( sub {
    my $log_data = shift;

    $df->_createForm(
        {
            name => 'test field',
            type => 'MASSIVE FORM FAILURE',
        },
        'some value'
    );

    is($log_data->{error}, "Unable to load form control - MASSIVE FORM FAILURE", '_createForm logs when it cannot load a form type');
});

#----------------------------------------------------------------------------
# getContentLastModified

sleep 3;

$df->{_mode} = 'form';
is($df->getContentLastModified,  $df->get('lastModified'), 'getContentLastModified: form normally returns lastModified');
$df->{_mode} = 'list';
cmp_ok(
    $df->getContentLastModified,
    '>',
    $df->get('lastModified'),
    '... form in list mode does not return lastModified'
);
$dform->{_mode} = 'form';
cmp_ok(
    $dform->getContentLastModified,
    '>',
    $dform->get('lastModified'),
    '... form with a captcha does not return lastModified, even in form mode'
);

#vim:ft=perl
