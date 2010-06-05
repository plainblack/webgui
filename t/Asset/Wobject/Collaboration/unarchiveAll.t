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

# Test the unarchiveAll function of the collaboration system
# 
#

use FindBin;
use strict;
use lib "$FindBin::Bin/../../../lib";
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

my $collab          = WebGUI::Asset->getImportNode( $session )->addChild({
    className       => 'WebGUI::Asset::Wobject::Collaboration',
    archiveAfter    => 60*60*365.25,
});

# Add a thread
my @threads = (
    $collab->addChild({
        className       => 'WebGUI::Asset::Post::Thread',
        status          => 'archived',
        title           => 'Archived',
    }, undef, undef, { skipAutoCommitWorkflows => 1 }),
);

my $tag = WebGUI::VersionTag->getWorking( $session );
$tag->commit;
WebGUI::Test->tagsToRollback($tag);

#----------------------------------------------------------------------------
# Tests

plan tests => 1;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# www_unarchiveAll sets all threads to approved
$collab->www_unarchiveAll;
$threads[0] = WebGUI::Asset->newById( $session, $threads[0]->getId );
is( $threads[0]->get('status'), 'approved', "unarchiveAll sets thread to approved" );

#vim:ft=perl
