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

# Test the subscribable features of the Wiki
# 
#

use FindBin;
use strict;
use lib "$FindBin::Bin/../../../lib";
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Group;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $import          = WebGUI::Asset->getImportNode( $session );
my $wiki
    = $import->addChild( {
        className               => 'WebGUI::Asset::Wobject::WikiMaster',
        subscriptionTemplateId  => 'limMkk80fMB3fqNZVf162w',
        groupIdView             => '7', # Everyone
    } );

WebGUI::Test->tagsToRollback( WebGUI::VersionTag->getWorking( $session ) );

#----------------------------------------------------------------------------
# Tests

plan tests => 20;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# Test subscribable methods
ok( $wiki->DOES('subscribable'), 'WikiMaster is subscribable' );
ok( $wiki->shouldSkipNotification, "WikiMaster never notifies" );

ok( my $template = $wiki->getSubscriptionTemplate, 'getSubscriptionTemplate returns something' );
isa_ok( $template, 'WebGUI::Asset::Template', 'getSubscriptionTemplate' );

is( $wiki->getSubscriptionTemplateNamespace, 'AssetAspect/Subscribable', 'getSubscriptionNamespace' );

ok( my $subgroup = $wiki->getSubscriptionGroup, 'getSubscriptionGroup returns something' );
isa_ok( $subgroup, 'WebGUI::Group', 'getSubscriptionGroup' );

is( $wiki->getSubscribeUrl, $wiki->getUrl('func=subscribe'), 'getSubscribeUrl' );
is( $wiki->getUnsubscribeUrl, $wiki->getUrl('func=unsubscribe'), 'getUnsubscribeUrl' );


#----------------------------------------------------------------------------
# canSubscribe permissions
$session->user({ userId => '1' });
ok( !$wiki->canSubscribe, 'Visitor cannot subscribe' );
ok( $wiki->canSubscribe( '3' ), 'Admin can subscribe' );

# subscribe
$wiki->subscribe('3');
ok( 
    WebGUI::User->new( $session, '3' )->isInGroup( $wiki->getSubscriptionGroup->getId ), 
    'subscribe'
);

# isSubscribed
ok( $wiki->isSubscribed( '3' ), 'isSubscribed' );

# unsubscribe
$wiki->unsubscribe('3');
ok( 
    !WebGUI::User->new( $session, '3' )->isInGroup( $wiki->getSubscriptionGroup->getId ), 
    'unsubscribe'
);


#----------------------------------------------------------------------------
# skip notification
ok( !$wiki->get('skipNotification'), 'skipNotification defaults to false' );
$wiki->setSkipNotification();
ok( $wiki->get('skipNotification'), 'setSkipNotification sets skipNotification' );

# add revision
my $new_rev = $wiki->addRevision({},time+1);
ok( !$new_rev->get('skipNotification'), 'addRevision resets skipNotification to false' );

# notify subscribers
# subscription content

#----------------------------------------------------------------------------
# duplication

my $otherWiki = $wiki->duplicate({ skipAutoCommitWorkflows => 1 });
ok($otherWiki->get('subscriptionGroupId'), 'duplicate: duplicated wiki got a subscription group');
isnt(
    $wiki->get('subscriptionGroupId'),
    $otherWiki->get('subscriptionGroupId'),
    'and it is a different group from the original wiki'
);

#----------------------------------------------------------------------------
# purging

my $otherGroup = $otherWiki->getSubscriptionGroup();
$otherWiki->purge;

my $groupShouldBeGone = WebGUI::Group->new($session, $otherGroup->getId);
is(ref $groupShouldBeGone, '', 'purge: cleaned up the subscription group');

#----------------------------------------------------------------------------
# Cleanup

#vim:ft=perl
