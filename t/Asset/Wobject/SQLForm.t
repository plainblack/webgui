#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use strict;
use File::Spec;
use lib "$FindBin::Bin/../../lib";

##The goal of this test is to test the creation of SQLForm Wobjects.

use WebGUI::Test;
use WebGUI::Session;
use Test::More tests => 10; # increment this value for each test you create
use WebGUI::Asset::Wobject::SQLForm;

my $session = WebGUI::Test->session;

# Do our work in the import node
my $node = WebGUI::Asset->getImportNode($session);

my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"SQLForm Test"});
my $sqlForm = $node->addChild({className=>'WebGUI::Asset::Wobject::SQLForm'});

# Test for a sane object type
isa_ok($sqlForm, 'WebGUI::Asset::Wobject::SQLForm');

# Test to see if we can set new values
my $newSQLFormSettings = {
    tableName=>'SQLForm_test',
};
$sqlForm->update($newSQLFormSettings);

foreach my $newSetting (keys %{$newSQLFormSettings}) {
    is ($sqlForm->get($newSetting), $newSQLFormSettings->{$newSetting}, "updated $newSetting is ".$newSQLFormSettings->{$newSetting});
}

# Test value that uiLevel returns
my $uiLevel = $sqlForm->uiLevel;
ok($uiLevel eq '9', "UI Level is set to $uiLevel");

# Lets make sure the view method returns something.
# This is not a very good test but I need to do it to test the purgeCache method anyways =)
is ($sqlForm->{_viewTemplate}, undef, 'internal template cache unset until prepareView is called');

my $ac = $sqlForm->getAdminConsoleWithSubmenu;
ok($ac, 'getAdminConsoleWithSubmenu returns a value');

# Lets make sure we can get the edit form
# This could be improved...
my $edit_form = $sqlForm->getEditForm;
ok($edit_form, 'getEditForm returned a value');
ok($edit_form->{_tab}{properties}{form}{_data}, 'getEditForm returned data for the form');

# not sure if this method is even used...grep of source showed no use of this method.
#$indexer = $sqlForm->getIndexerParams;

#$sqlForm->prepareView;
#isnt ($sqlForm->{_viewTemplate}, undef, 'internal template cache set by prepare view');
#isa_ok ($sqlForm->{_viewTemplate}, 'WebGUI::Asset::Template', 'internal template cache');

my $output = $sqlForm->view;
isnt ($output, "", 'view method returns something');

my $editField = $sqlForm->www_editField;
ok($editField, 'www_editField returned a value');

# Lets see if caching works
my $cachedOutput = WebGUI::Cache->new($session, 'view_'.$sqlForm->getId)->get;
#is ($output, $cachedOutput, 'view method caches output');

# Lets see if the purgeCache method works
$sqlForm->purgeCache;
$cachedOutput = WebGUI::Cache->new($session, 'view_'.$sqlForm->getId)->get;  # Check cache post purge
isnt ($output, $cachedOutput, 'purgeCache method deletes cache');


END {
	# Clean up after thy self
	$versionTag->rollback();
}

