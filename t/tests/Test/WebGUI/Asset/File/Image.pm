package Test::WebGUI::Asset::File::Image;
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------


use base qw/Test::WebGUI::Asset/;

use Test::More;
use Test::Deep;
use Test::Exception;


sub list_of_tables {
     return [qw/assetData FileAsset ImageAsset/];
}

sub dynamic_form_labels { return 'New file to upload'; }

sub t_11_getEditForm : Tests( 2 ) {
    my $test    = shift;
    $test->SUPER::t_11_getEditForm( @_ );
    my $session = $test->session;
    my ( $tag, $asset, @parents ) = $test->getAnchoredAsset();

    $asset->filename('abc.jpg'); # the thumbnail and imageSize read-only form elements only get added if there is a filename

    # Test extra fields
    my $f   = $asset->getEditForm;
# do { local $Data::Dumper::Maxdepth = 7; use Data::Dumper; warn Dumper $f; };
    isa_ok( $f->getTab("properties")->getField("thumbnail"), "WebGUI::Form::ReadOnly" );
    isa_ok( $f->getTab("properties")->getField("imageSize"), "WebGUI::Form::ReadOnly" );

    # TODO: Test overrides for extra fields

}

1;
