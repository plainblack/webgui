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

use strict;
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

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

my $page
    = $wiki->addChild( {
        className               => 'WebGUI::Asset::WikiPage',
    }, undef, undef, { skipAutoCommitWorkflows => 1 } );

WebGUI::Test->addToCleanup( WebGUI::VersionTag->getWorking( $session ) );

#----------------------------------------------------------------------------
# Tests

plan tests => 4;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# Test subscribable methods
ok( $page->DOES('subscribable'), 'WikiMaster is subscribable' );

ok( my $template = $page->getSubscriptionTemplate, 'getSubscriptionTemplate returns something' );
isa_ok( $template, 'WebGUI::Asset::Template', 'getSubscriptionTemplate' );
is( $template->getId, 'limMkk80fMB3fqNZVf162w', 'getSubscriptionTemplate gets wikimaster template' );

#----------------------------------------------------------------------------
# Cleanup

#vim:ft=perl
