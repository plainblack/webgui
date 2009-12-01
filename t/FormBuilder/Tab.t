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

# Test the tab object
# 
#

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 9;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# Creation, accessors and mutators
use_ok( 'WebGUI::FormBuilder::Tab' );
my $tab = WebGUI::FormBuilder::Tab->new( $session );
isa_ok( $tab, 'WebGUI::FormBuilder::Tab' );

ok( !$tab->name, 'no default' );
ok( !$tab->label, 'no default' );
is( $tab->session, $session );

$tab = WebGUI::FormBuilder::Tab->new( $session, name => "myname", label => 'My Label' );
is( $tab->name, 'myname' );
is( $tab->label, 'My Label' );
is( $tab->label('New Label'), 'New Label' );
is( $tab->label, 'New Label' );


#----------------------------------------------------------------------------
# Cleanup
END {

}
#vim:ft=perl
