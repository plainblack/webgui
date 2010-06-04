#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";

use WebGUI::Test;
use WebGUI::Form::Template;
use WebGUI::Session;

use Test::Deep;
use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

plan tests => 4;

my $versionTag = WebGUI::VersionTag->create( $session );
$versionTag->setWorking;

{
    my $templateList = WebGUI::Asset::Template->getList( $session, 'style' );
    my $elem = WebGUI::Form::Template->new( $session, { 
        namespace       => 'style',
        onlyCommitted   => 0,
    } );

    $elem->setOptions;
    cmp_deeply( 
        $templateList,
        $elem->get('options'),
        'setOption sets correct templates'
    );

    my $newTemplate = WebGUI::Asset->getRoot( $session )->addChild( {
        title       => 'Klazam',
        menuTitle   => 'Klazam',
        template    => '',
        namespace   => 'style',
        className   => 'WebGUI::Asset::Template',
    } );

    $elem->setOptions;
    cmp_deeply( 
        { %{$templateList}, $newTemplate->getId => 'Klazam' },
        $elem->get('options'),
        'setOption includes uncommitted templates when onlyCommitted is false'
    );

    $elem->set( onlyCommitted => 1 );
    $elem->setOptions;
    cmp_deeply( 
        $templateList,
        $elem->get('options'),
        'setOption excludes uncommitted templates when onlyCommitted is true'
    );

    my ( $id, $name ) = %{ $templateList };
    $elem->set( 'value', $id );
    is( $elem->getValueAsHtml, $name, 'getValueAsHtml return template name' );

}

$versionTag->rollback;
