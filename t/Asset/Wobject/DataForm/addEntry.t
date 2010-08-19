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

# Test the viewList and related methods of the DataForm
#
#

use FindBin;
use strict;
use lib "$FindBin::Bin/../../../lib";
use Test::More;
use Test::Deep;
use WebGUI::Test;    # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

my $df = WebGUI::Asset->getImportNode($session)->addChild( { 
    className => 'WebGUI::Asset::Wobject::DataForm', 
} );

WebGUI::Test->addToCleanup( WebGUI::VersionTag->getWorking( $session ) );

# Add fields to the dataform
$df->createField( "name",    { type => "text", } );
$df->createField( "message", { type => "text", } );

# Add entries to the dataform
my @entryProperties = (
    {
        name    => "Andy",
        subject => "Problem!",
        message => "I need a Rita Heyworth",
    },
    {
        name    => "Red",
        subject => "Solution!",
        message => "I need about tree fiddy",
    }
);

my $birthday = WebGUI::Test->webguiBirthday;

is $df->entryClass, 'WebGUI::AssetCollateral::DataForm::Entry', 'entry class returns the right class';

ok ! $df->hasEntries, 'hasEntries: no entries yet';

my $entry;
$entry = $df->entryClass->newFromHash( $df, $entryProperties[0] );
isa_ok $entry, $df->entryClass;

$entry->submissionDate(WebGUI::DateTime->new($session, $birthday++));
my $entryId = $entry->save;
ok $session->id->valid($entryId), 'save returns the entryId, a GUID';

ok $df->hasEntries, 'hasEntries returns true after entries added';
is $df->entryClass->getCount($df), 1, 'getCount returns the number of entries';

$entry = $df->entryClass->newFromHash( $df, $entryProperties[0] );
isa_ok $entry, $df->entryClass;

$entry->submissionDate(WebGUI::DateTime->new($session, $birthday++));
$entry->save;
ok $df->hasEntries, 'hasEntries returns true after entries added';
is $df->entryClass->getCount($df), 2, 'count incremented';

done_testing;
#vim:ft=perl
