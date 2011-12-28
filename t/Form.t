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

# 
# 
#

use strict;
use Test::More;
use Test::Deep;
use WebGUI::Test;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests

plan tests => 5;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# Test the formHeader method

ok(
    !eval{ WebGUI::Form::formHeader( "" ); 1 },
    "formHeader() dies if first parameter is not WebGUI Session",
);

ok(
    !eval{ WebGUI::Form::formHeader( $session, ['foo'] ); 1 },
    "formHeader() dies if second parameter is not hash reference",
);

# Test the defaults for formHeader()
my $testDefaults = all(
    re( q{<form[^>]*>} ),
    re( q{action=} ),
    re( q{enctype="multipart/form-data"} ),
    re( q{method="post"} ),
    re( q{type="hidden" name="webguiCsrfToken"} ),
);

cmp_deeply( 
    WebGUI::Form::formHeader( $session ),
    $testDefaults,
    "formHeader called without an options hashref",
);

# Test options passed into formHeader()
my $testWithOptions = all(
    re( q{<form[^>]*>} ),
    re( q{action="action"} ),
    re( q{enctype="enctype"} ),
    re( q{method="method"} ),
);

cmp_deeply( 
    WebGUI::Form::formHeader( $session, {
        action      => "action",
        enctype     => "enctype",
        method      => "method",
    } ),
    $testWithOptions,
    "formHeader called with an options hashref",
);

# Test "action" option containing query parameters
my $testHiddenElements = all(
    re( q{<input type="hidden" name="func" value="edit"} ),
    re( q{<input type="hidden" name="a" value="1"} ),
    re( q{<input type="hidden" name="b" value="2"} ),
    re( q{<input type="hidden" name="webguiCsrfToken" value=".{22}"} ),
);

cmp_deeply(
    WebGUI::Form::formHeader( $session, {
        action      => "action?func=edit;a=1&b=2",
    }),
    $testHiddenElements,
    "formHeader 'action' option containing query parameters",
);

#----------------------------------------------------------------------------

TODO: {
    local $TODO = "Some things on the TODO list";
    # Test the formFooter method
    # Test that the autohandler works properly
}
