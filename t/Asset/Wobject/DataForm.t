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
use WebGUI::Test::Mechanize;
use WebGUI::Asset;
use WebGUI::Asset::Wobject::DataForm;
use WebGUI::VersionTag;
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

# Create a DataForm
my $df  = WebGUI::Test->asset
        ->addChild( {
            className           => "WebGUI::Asset::Wobject::DataForm",
            mailData            => 0,
            fieldConfiguration  => '[]',
        }, undef, time-10 );

my $dform = WebGUI::Test->asset->addChild({
    className           => "WebGUI::Asset::Wobject::DataForm",
    mailData            => 0,
}, undef, time-5);
$dform->createField('gotCaptcha', { type => 'Captcha', name => 'humanCheck', });

#----------------------------------------------------------------------------
# Tests

plan tests => 8;        # Increment this number for each test you create

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

sleep 3; # whyyyyyyyy

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

#----------------------------------------------------------------------------
# www_editField
my $mech = WebGUI::Test::Mechanize->new( config => WebGUI::Test->file );
$mech->get_ok('/');
$mech->session->user({ userId => 3 });

# Create a new field
$mech->get_ok( $df->getUrl( 'func=editField;fieldName=new' ) );
$mech->submit_form_ok( {
    fields => {
        label   => 'Request',
        newName => 'request',
        tabId => 0,
        subtext => 'Submit your request to the circular file',
        type => "Textarea",
    },
}, "add a new field" );

$df = WebGUI::Asset->newById( $mech->session, $df->getId );
cmp_deeply( 
    $df->getFieldConfig( "request" ),
    superhashof( {
        label   => 'Request',
        name    => 'request',
        tabId   => undef,
        subtext => 'Submit your request to the circular file',
        type => 'Textarea',
    } ),
    "field exists with correct config",
);

# Edit that field


#vim:ft=perl
