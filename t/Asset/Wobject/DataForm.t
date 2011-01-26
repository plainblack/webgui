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

plan tests => 18;        # Increment this number for each test you create

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
sleep 1; # stupid addRevision
$mech->get_ok( $df->getUrl( 'func=editField;fieldName=request' ) );
$mech->submit_form_ok( {
    fields => {
        label   => 'Beg Here',
        tabId => 0,
        subtext => 'Throw yourself upon the mercy of the manager',
    },
}, "edit the field" );

$df = WebGUI::Asset->newPending( $mech->session, $df->getId );
cmp_deeply( 
    $df->getFieldConfig( "request" ),
    superhashof( {
        label   => 'Beg Here',
        name    => 'request',
        tabId   => undef,
        subtext => 'Throw yourself upon the mercy of the manager',
        type => 'Textarea',
    } ),
    "field config updated",
);


#----------------------------------------------------------------------------
# www_editTab
my $mech = WebGUI::Test::Mechanize->new( config => WebGUI::Test->file );
$mech->get_ok('/');
$mech->session->user({ userId => 3 });

# Create a new tab
$mech->get_ok( $df->getUrl( 'func=editTab' ) );
$mech->submit_form_ok( {
    fields => {
        label => 'Request Info',
        subtext => "We won't be reading it, but fill it out anyway or get fired.",
    },
}, "add a new tab" );

$df = WebGUI::Asset->newById( $mech->session, $df->getId );
# Figure out the ID
my $tabId = ( keys %{$df->getTabConfig} )[0];
cmp_deeply( 
    $df->getTabConfig( $tabId ),
    superhashof( {
        label => 'Request Info',
        subtext => "We won't be reading it, but fill it out anyway or get fired.",
    } ),
    "tab exists with correct config",
);

# Edit that tab
sleep 1; # stupid addRevision
$mech->get_ok( $df->getUrl( 'func=editTab;tabId=' . $tabId ) );
$mech->submit_form_ok( {
    fields => {
        label => 'Begging Info',
        subtext => "Adding puppydog eyes may help your case, slightly",
    },
}, "edit the tab" );

$df = WebGUI::Asset->newPending( $mech->session, $df->getId );
cmp_deeply( 
    $df->getTabConfig( $tabId ),
    superhashof( {
        label => 'Begging Info',
        subtext => "Adding puppydog eyes may help your case, slightly",
    } ),
    "tab config updated",
);

#vim:ft=perl
