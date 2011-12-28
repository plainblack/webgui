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

# Test the search indexer
# 
#

use strict;
use Test::More;
use Test::Deep;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my ( $db ) = $session->quick(qw{ db });

# Create an article to index
my $article         = WebGUI::Test->asset->addChild( {
    className       => 'WebGUI::Asset::Wobject::Article',
    keywords        => 'keyword1,keyword2',
    title           => 'title',
    menuTitle       => 'menuTitle',
} );

#----------------------------------------------------------------------------
# Tests

plan tests => 24;        # Increment this number for each test you create

use_ok( 'WebGUI::Search::Index' );

#----------------------------------------------------------------------------
# Test initial index creation with no synopsis and no description
my $indexer = WebGUI::Search::Index->create( $article );

ok ( my $row = $db->quickHashRef( "SELECT * FROM assetIndex WHERE assetId=?", [ $article->getId ] ),
    "assetId exists in assetIndex"
);
cmp_deeply ( 
    $row,
    {
        assetId         => $article->getId,
        title           => $article->get('title'),
        synopsis        => $article->get('synopsis') || '',
        url             => $article->get('url'),
        revisionDate    => $article->get('revisionDate'),
        creationDate    => $article->get('creationDate'),
        ownerUserId     => $article->get('ownerUserId'),
        groupIdView     => $article->get('groupIdView'),
        groupIdEdit     => $article->get('groupIdEdit'),
        className       => ref($article),
        isPublic        => 1, # default
        keywords        => all( # keywords contains title, menuTitle, every part of the URL and every keyword
            re($article->get('title')),
            re($article->get('menuTitle')),
            re("root"), re("import"),
            re("keyword1"), re("keyword2"),
        ),
        lineage         => $article->get('lineage'),
        subId           => undef,
    },
    "Index has correct information" 
);

#----------------------------------------------------------------------------
# Test Index methods

# getId
is( $indexer->getId, $article->getId, "getId() returns assetId" );

# setIsPublic
$indexer->setIsPublic(0);
is( $db->quickScalar( "SELECT isPublic FROM assetIndex WHERE assetId=? and url=?", [$article->getId, $article->get('url')] ),
    0,
    "setIsPublic updates database",
);

# session
isa_ok( $indexer->session, 'WebGUI::Session', 'session returns session' );

# updateSynopsis
$indexer->updateSynopsis( "A new synopsis" );
is( $db->quickScalar( "SELECT synopsis FROM assetIndex WHERE assetId=? and url=?", [$article->getId, $article->get('url')] ),
    "A new synopsis",
    "updateSynopsis updates assetIndex"
);
$article    = WebGUI::Asset::Wobject::Article->new( $session, $article->getId );
isnt(
    $article->get('synopsis'),
    "A new synopsis",
    "updateSynopsis does not update asset's data",
);

# addFile
# TODO
 
# addKeywords
my $currentKeywords = $db->quickScalar( "SELECT keywords FROM assetIndex WHERE assetId=? and url=?", [$article->getId, $article->get('url')] );
$indexer->addKeywords("shawshank");
my $newKeywords     = $db->quickScalar( "SELECT keywords FROM assetIndex WHERE assetId=? and url=?", [$article->getId, $article->get('url')] );
like( $newKeywords, qr{$currentKeywords}, "addKeywords keeps old keywords" );
like( $newKeywords, qr{shawshank}, "addKeywords adds the keywords" );

#----------------------------------------------------------------------------
# Test Index updated with asset data (synopsis, no description)
$article->update({
    synopsis        => "This is a synopsis",
    description     => "",
} );
$indexer = WebGUI::Search::Index->create( $article );

ok ( $row = $db->quickHashRef( "SELECT * FROM assetIndex WHERE assetId=? and url=?", [ $article->getId, $article->get('url') ] ),
    "assetId exists in assetIndex"
);
cmp_deeply ( 
    $row,
    {
        assetId         => $article->getId,
        title           => $article->get('title'),
        synopsis        => $article->get('synopsis'),
        url             => $article->get('url'),
        revisionDate    => $article->get('revisionDate'),
        creationDate    => $article->get('creationDate'),
        ownerUserId     => $article->get('ownerUserId'),
        groupIdView     => $article->get('groupIdView'),
        groupIdEdit     => $article->get('groupIdEdit'),
        className       => ref($article),
        isPublic        => 1, # default
        keywords        => all( # keywords contains synopsis, title, menuTitle, every part of the URL and every keyword
            re("This is a synopsis"),
            re($article->get('title')),
            re($article->get('menuTitle')),
            re("root"), re("import"),
            re("keyword1"), re("keyword2"),
        ),
        lineage         => $article->get('lineage'),
        subId           => undef,
    },
    "Index has synopsis information in keywords" 
);


#----------------------------------------------------------------------------
# Test Index updated with asset data (no synopsis, description)
$article->update({
    synopsis        => "",
    description     => "My Description",
});
$indexer = WebGUI::Search::Index->create( $article );

$row = $db->quickHashRef( "SELECT * FROM assetIndex WHERE assetId=? and url=?", [ $article->getId, $article->get('url') ]);
cmp_deeply ( 
    $row,
    {
        assetId         => $article->getId,
        title           => $article->get('title'),
        synopsis        => $article->get('description'), # synopsis defaults to description when description exists
        url             => $article->get('url'),
        revisionDate    => $article->get('revisionDate'),
        creationDate    => $article->get('creationDate'),
        ownerUserId     => $article->get('ownerUserId'),
        groupIdView     => $article->get('groupIdView'),
        groupIdEdit     => $article->get('groupIdEdit'),
        className       => ref($article),
        isPublic        => 1, # default
        keywords        => all( # keywords contains description, title, menuTitle, every part of the URL and every keyword
            re("Description"),
            re($article->get('title')),
            re($article->get('menuTitle')),
            re("root"), re("import"),
            re("keyword1"), re("keyword2"),
        ),
        lineage         => $article->get('lineage'),
        subId           => undef,
    },
    "Index has description in keywords" 
);


#----------------------------------------------------------------------------
# Test Index updated with asset data (synopsis and description)
$article->update({
    synopsis        => "This is a synopsis",
    description     => "My Description",
});
$indexer = WebGUI::Search::Index->create( $article );

$row = $db->quickHashRef( "SELECT * FROM assetIndex WHERE assetId=? and url=?", [ $article->getId, $article->get('url') ] );
cmp_deeply ( 
    $row,
    {
        assetId         => $article->getId,
        title           => $article->get('title'),
        synopsis        => $article->get('synopsis'), # synopsis is first priority to fill this
        url             => $article->get('url'),
        revisionDate    => $article->get('revisionDate'),
        creationDate    => $article->get('creationDate'),
        ownerUserId     => $article->get('ownerUserId'),
        groupIdView     => $article->get('groupIdView'),
        groupIdEdit     => $article->get('groupIdEdit'),
        className       => ref($article),
        isPublic        => 1, # default
        keywords        => all( # keywords contains title, menuTitle, every part of the URL and every keyword
            re($article->get('title')),
            re($article->get('menuTitle')),
            re("root"), re("import"),
            re("keyword1"), re("keyword2"),
        ),
        lineage         => $article->get('lineage'),
        subId           => undef,
    },
    "Index has synopsis and description in keywords" 
);

#----------------------------------------------------------------------------
# Test that HTML entities are decoded.
$article->update({
    description     => "sch&ouml;n ca&ntilde;&oacute;n",
});
$indexer = WebGUI::Search::Index->create( $article );

$row = $db->quickHashRef( "SELECT * FROM assetIndex WHERE assetId=? and url=?", [ $article->getId, $article->get('url') ] );
cmp_deeply ( 
    $row,
    superhashof({
        keywords        => all( # keywords contains title, menuTitle, every part of the URL and every keyword
            re("sch\xF6n"),
            re("ca\xF1\xF3n"),
        ),
    }),
    "Index has decoded entities" 
);

#----------------------------------------------------------------------------
# Test that Chinese ideographical characters are inserted and searchable.
SKIP: {
    use utf8;

    my $min_word_length = $session->db->quickHashRef("show variables like 'ft_min_word_len'");
    skip 'MySQL minimum word length too long to support ideograms', 1
        if $min_word_length->{Value} > 2;

    $article->update({
        description     => "甲骨文",
    });
    $indexer = WebGUI::Search::Index->create( $article );

    $row = $db->quickHashRef( "SELECT * FROM assetIndex WHERE assetId=? and url=?", [ $article->getId, $article->get('url') ] );
    cmp_deeply ( 
        $row,
        superhashof({
            keywords        => all( # keywords contains title, menuTitle, every part of the URL and every keyword
                re("''甲''"),
                re("''骨''"),
                re("''文''"),
            ),
        }),
        "Index has Chinese ideographs, separated by spaces and delimited with quotes to pad the length" 
    );
}

#----------------------------------------------------------------------------
# Test addRecord
note "addRecord";
$article->update({
    description     => "descriptive",
});
$indexer = WebGUI::Search::Index->create( $article );
is $session->db->quickScalar('select count(*) from assetIndex where assetId=?', [$article->getId]), 1, 'create puts 1 record into the db';
$indexer->addRecord( url => 'something else');
is $session->db->quickScalar('select count(*) from assetIndex where assetId=?', [$article->getId]), 1, 'addRecord does nothing without url and keywords entries';
$indexer->addRecord( keywords => 'something else');
is $session->db->quickScalar('select count(*) from assetIndex where assetId=?', [$article->getId]), 1, 'addRecord does nothing without url and keywords entries';
$indexer->addRecord( keywords => 'something else', url => '', );
is $session->db->quickScalar('select count(*) from assetIndex where assetId=?', [$article->getId]), 1, 'addRecord does nothing without url and keywords entries';
$indexer->addRecord( keywords => 'something else', url => 'another/thing/coming', );
is $session->db->quickScalar('select count(*) from assetIndex where assetId=?', [$article->getId]), 2, 'new record added';

my %original_record = $session->db->quickHash('select * from assetIndex where assetId=? and url=?', [$article->getId, $article->get('url')]);
my %new_record      = $session->db->quickHash('select * from assetIndex where assetId=? and url=?', [$article->getId, 'another/thing/coming']);

delete @original_record{qw/url keywords/};
delete @new_record{qw/url keywords/};

cmp_deeply(\%original_record, \%new_record, 'records are the same, aside from url and keywords');

$indexer->delete;
is $session->db->quickScalar('select count(*) from assetIndex where assetId=?', [$article->getId]), 0, 'all records deleted';

$indexer = WebGUI::Search::Index->create( $article );
$indexer->addRecord(url => 'other', keywords => 'yada yada yada', lineage => 'hike');
my %original_record = $session->db->quickHash('select * from assetIndex where assetId=? and url=?', [$article->getId, $article->get('url')]);
my %new_record      = $session->db->quickHash('select * from assetIndex where assetId=? and url=?', [$article->getId, 'other']);

is $original_record{lineage}, $new_record{lineage}, 'lineage is not allowed to be overridden';

#vim:ft=perl
