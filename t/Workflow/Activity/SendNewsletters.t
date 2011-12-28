# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#------------------------------------------------------------------

use strict;
use Test::More;
use Test::Deep;
use Data::Dumper;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use Test::MockObject;
use Test::MockObject::Extends;
use WebGUI::Test::MockAsset;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 1;        # Increment this number for each test you create

##Disable sending email
my $sendmock = Test::MockObject->new( {} );
$sendmock->set_isa('WebGUI::Mail::Send');
$sendmock->set_true('addText', 'send', 'addHeaderField', 'addHtml', 'queue', 'addFooter');
local *WebGUI::Mail::Send::create;
$sendmock->fake_module('WebGUI::Mail::Send',
    create => sub { return $sendmock },
);

##Create Assets;
my $home = WebGUI::Test->asset;

                 #1234567890123456789012#
my $templateId = 'NEWSLETTER_TEMPLATE___';

my $templateMock = WebGUI::Test::MockAsset->new('WebGUI::Asset::Template');
$templateMock->mock_id($templateId);
my $templateVars;
$templateMock->mock('process', sub { $templateVars = $_[1]; } );

my $cs = $home->addChild({
    className            => 'WebGUI::Asset::Wobject::Collaboration::Newsletter',
    title                => 'Test Newsletter',
    enablePostMetaData   => 1,
    newsletterTemplateId => $templateId, ##Mocked asset for doing template variable checks
    description          => 'Fans of Shawshank Inmates',
    newsletterHeader     => 'newsletter header',
    newsletterFooter     => 'newsletter footer',
});

my $thread = $cs->addChild({
    className => 'WebGUI::Asset::Post::Thread',
    title     => 'Test Thread',
    content   => 'This is the content',
    synopsis  => 'This is the synopsis',
},);
$thread->setSkipNotification;
$thread->commit;

##Setup metadata
$session->setting->set('metaDataEnabled', 1);
$cs->addMetaDataField('new', 'newsletterCategory', '', '', 'radioList',
    join("\n", qw/Andy Red Boggs/),
);

my $metaDataFields = buildNameIndex($cs->getMetaDataFields);
$thread->updateMetaData($metaDataFields->{newsletterCategory}, 'Andy');

##Create subscriber user
my $subscriber = WebGUI::User->create($session);
$subscriber->update({ 'email', 'going@nowhere.com' });
WebGUI::Test->addToCleanup($subscriber);
$cs->setUserSubscriptions($metaDataFields->{newsletterCategory}."~Andy", $subscriber->getId);
$session->db->write(<<EOSQL, [ time()-24*60*60, $cs->getId, $subscriber->getId ]);
update Newsletter_subscriptions set lastTimeSent=? where assetId=? and userId=?
EOSQL

##Setup the workflow activity to run
my $activity = Test::MockObject::Extends->new( 'WebGUI::Workflow::Activity::SendNewsletters' );
$activity->set_always('session', $session);
$activity->set_always('getTTL', 60);
$activity->set_always('COMPLETE', 'complete');

{
    $activity->execute();
    cmp_deeply(
        $templateVars,
        {
            title       => 'Test Newsletter',
            description => 'Fans of Shawshank Inmates',
            footer      => 'newsletter footer',
            header      => 'newsletter header',
            thread_loop => [
                {
                    body     => 'This is the content',
                    synopsis => 'This is the synopsis',
                    title    => 'Test Thread',
                    url      => re('test-newsletter/test-thread'),
                },
            ],
        }
    );
}

foreach my $metadataId (keys %{ $cs->getMetaDataFields }) {
    $cs->deleteMetaDataField($metadataId);
}

sub buildNameIndex {
    my ($fidStruct) = @_;
    my $nameStruct;
    foreach my $field ( values %{ $fidStruct } ) {
        $nameStruct->{ $field->{fieldName} } = $field->{fieldId};
    }
    return $nameStruct;
}

#vim:ft=perl
