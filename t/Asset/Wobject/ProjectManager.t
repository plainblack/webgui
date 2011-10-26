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

# Test the Project Manager
# 
#

use FindBin;
use strict;
use lib "$FindBin::Bin/lib";
use Test::More;
use Test::Deep;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Test::Mechanize;
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

my $tag = WebGUI::VersionTag->getWorking($session);
my $pm  = WebGUI::Test->asset(
    className   => 'WebGUI::Asset::Wobject::ProjectManager',
    groupToAdd => 3,
);
$tag->commit;
$pm = $pm->cloneFromDb;

#----------------------------------------------------------------------------
# Tests

#----------------------------------------------------------------------------
# www_editProject
my $mech = WebGUI::Test::Mechanize->new( config => WebGUI::Test->file );
$mech->get_ok('/');
$mech->session->user({ userId => 3 });

# Add a new project
my %projectData = (
    name => 'Build a Library',
    description => 'Build a library to teach them how to be men.',
    targetBudget => "80.00",
);

$mech->get_ok( $pm->getUrl( 'func=editProject;projectId=new' ) );
$mech->submit_form_ok( {
        fields   => { %projectData },
    }, "create a new project"
);

# Check if created
my $pj = $session->db->quickHashRef(
    "SELECT * FROM PM_project WHERE assetId=?",
    [ $pm->getId ],
);
ok( $pj, "project exists" );
cmp_deeply(
    $pj,
    superhashof({
            %projectData,
            assetId => $pm->getId,
        }),
    "Project info correct",
);

# Initial milestone created too
my $task = $session->db->quickHashRef(
    "SELECT * FROM PM_task WHERE projectId=?",
    [ $pj->{projectId} ],
);
ok( keys %$task, "task exists" );
cmp_deeply(
    $task,
    superhashof({
        projectId => $pj->{projectId},
        taskType => "milestone",
    }),
    "Task info correct",
);


# Now edit it
$projectData{ description } = "Keep those heathens in their place.";
$mech->get_ok( $pm->getUrl( 'func=editProject;projectId=' . $pj->{projectId} ) );
$mech->submit_form_ok( {
        fields   => { %projectData },
    }, "edit project"
);

# Check if edited
my $pj = $session->db->quickHashRef(
    "SELECT * FROM PM_project WHERE assetId=?",
    [ $pm->getId ],
);
ok( $pj, "edited project exists" );
cmp_deeply(
    $pj,
    superhashof({
            %projectData,
            assetId => $pm->getId,
        }),
    "edited Project info correct",
);

done_testing;
#vim:ft=perl
