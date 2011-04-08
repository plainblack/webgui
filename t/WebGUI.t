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

# Test the WebGUI PSGI handler
# 
#

use FindBin;
use strict;
use lib "$FindBin::Bin/lib";
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI;
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

# A template object to play with
my $template        = WebGUI::Test->asset(
    className       => 'WebGUI::Asset::Template',
    template        => '<html><body>Template World</body></html>',
);

# Create a fake content handler class to install in the config
BEGIN {
    $INC{'WebGUI/Content/TestHandler.pm'} = __FILE__;
    $INC{'WebGUI/Content/TestChunked.pm'} = __FILE__;
    $INC{'WebGUI/Content/TestTemplate.pm'} = __FILE__;

}

package WebGUI::Content::TestHandler;
sub handler { '<html><body>Hello World</body></html>' }
package WebGUI::Content::TestChunked;
sub handler { "chunked" }
package WebGUI::Content::TestTemplate;
sub handler { $template }

package main;

#----------------------------------------------------------------------------
# Test the various possibilities of content handlers
my ( $fh );

$session->config->set( 'contentHandlers', [ 'WebGUI::Content::TestHandler' ] );
$fh = capture_output();
WebGUI->handle( $session );
is(
    get_output( $fh ),
    WebGUI::Content::TestHandler->handler,
    'handler that returns HTML is output directly',
);

$session->config->set( 'contentHandlers', [ 'WebGUI::Content::TestChunked' ] );
$fh = capture_output();
WebGUI->handle( $session );
isnt(
    get_output( $fh ),
    'chunked',
    'chunked is not returned',
);

$session->config->set( 'contentHandlers', [ 'WebGUI::Content::TestTemplate' ] );
$fh = capture_output();
WebGUI->handle( $session );
is(
    get_output( $fh ),
    $template->process,
    'handler that returns template is processed',
);

sub capture_output {
    my $output_fh = undef;
    open $fh, '+>', \$output_fh;
    $session->output->setHandle( $fh );
    return $fh;
}

sub get_output {
    my ( $fh ) = @_;
    seek $fh, 0, 0;
    return join '', <$fh>;
}

done_testing;
#vim:ft=perl
