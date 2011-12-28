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

# Test the unarchiveAll function of the collaboration system
# 
#

use strict;
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
$session->user({ userId => '3' });

my $collab          = WebGUI::Asset->getImportNode( $session )->addChild({
    className       => 'WebGUI::Asset::Wobject::Collaboration',
    archiveAfter    => 60*60*365.25,
    groupIdEdit     => '3',
});

# Add a thread
my @threads = (
    $collab->addChild({
        className       => 'WebGUI::Asset::Post::Thread',
        status          => 'archived',
        title           => 'Archived',
        groupIdEdit     => '3',
    }),
);
for my $t ( @threads ) {
    $t->setSkipNotification;
    $t->commit;
}

WebGUI::Test->addToCleanup($collab,@threads);

#----------------------------------------------------------------------------
# Tests

plan tests => 1;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# www_unarchiveAll sets all threads to approved
note( $threads[0]->status );
$collab->www_unarchiveAll;
$threads[0] = $threads[0]->cloneFromDb;
is( $threads[0]->get('status'), 'approved', "unarchiveAll sets thread to approved" );

#vim:ft=perl
