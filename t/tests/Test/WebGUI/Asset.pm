package Test::WebGUI::Asset;
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use warnings;

use base qw/My::Test::Class/;

use Test::More;
use Test::Deep;
use Test::Exception;
use WebGUI::Test;
use Data::Dumper;
use List::MoreUtils;

# XXXX fix the Test(n) numbers to match reality

sub dynamic_form_labels { return; }; # per-class form labels added at run time rather than through property blocks

sub constructorExtras {
    return;
}

sub postProcessMergedProperties {
    return;
}

sub dump_assets {
    my $session = shift;
    # my $assets = WebGUI::Asset->getRoot($session)->getLineage(['descendants'], { returnObjects => 1, } );
    my $assets = WebGUI::Asset->getRoot($session)->getLineage(['descendants']);
    warn "all assets: " . Dumper $assets;
}

sub debug {

    # if the last eval { } caught something, give full diagnostics on that and stop the tests.
    # while working through these bugs in here, it does no good to run the test suite until completion after something blows up.

    my $e = Exception::Class->caught() or return;
    my $line = (caller)[2];
    
    # XXX redundant with $SIG{__DIE__} handlers
    #if( Scalar::Util::blessed( $e ) ) {
    #    note( $line . ': ' . $e->error . "\n" . $e->full_message . "\n" . $e->trace->as_string );
    #} else {
    #    note( $line . ': ' . "\n(non-object error:) $e" );
    #}

    # return; # XXX enable/disable aborting tests on failure

    # system '/home/scott/bin/perl', '/home/scott/plainblack/dumplineage.pl'; # XXX
    warn "going to exit in ... a whole bunch... of seconds";  
    # sleep 10;
    system 'sleep 6000'; # sleep 10; # this way, we can control-c it!
    exit;
}

sub assetUiLevel {
    return 1;
}

sub list_of_tables {
    return [qw/assetData/];
}

sub parent_list {
    return [];
}

sub flattenFormObjects {
    my $arr = shift;
    my @result;
    my @no_arrays = map { (ref $_ eq 'ARRAY') ? flattenFormObjects($_) : $_ } @$arr;
    for my $formob (@no_arrays) {
        if($formob->get('buttons')) {
            push @result, flattenFormObjects( $formob->get('buttons') );
        } else {
            push @result, $formob;
        }
    }
    @result;
}

sub formProperties {
    my $asset = shift;
    my %properties = 
        map { ( $_ => $asset->get($_) ) } 
        # map { [ $_ => $asset->getFormProperties($_) ] } 
        grep { ! $asset->meta->find_attribute_by_name( $_ )->noFormPost } $asset->getProperties; 
    return %properties;
}

sub getAnchoredAsset {
    my $test    = shift;
    my $session = $test->session or die;
    my $tag     = WebGUI::VersionTag->getWorking($session);
    my @parents = $test->getMyParents;
    my $asset   = $parents[-1]->addChild({
        className => $test->class,
        status  => "pending",
        tagId   => $tag->getId,
        $test->constructorExtras($session),
    }, undef, undef, {skipNotification => 1});
    # warn "XXX getAnchoredAsset:  created new asset of Id: " . $asset->getId . ' of type: ' . ref $asset;
    $tag->commit;
    foreach my $a ($asset, @parents) {
        $a = $a->cloneFromDb;
    }
    WebGUI::Test->addToCleanup($tag);
    return ($tag, $asset, @parents);
}

sub getMyParents {
    my $test           = shift;
    my $session        = $test->session;
    my $parent_classes = $test->parent_list;
    my @parents        = ();
    my $default        = WebGUI::Asset->getDefault($session);
    push @parents, $default;
    my $parent = $default;
    my $tag     = WebGUI::VersionTag->getWorking($session);
    foreach my $parent_class (@{ $parent_classes }) {
        my $new_parent = $parent->addChild(
            {   
                className => $parent_class, 
                status => "pending", 
                tagId => $tag->getId,
                $test->constructorExtras($session), 
            }, 
            undef, 
            undef, 
            {skipNotification => 1,},
        );
        push @parents, $new_parent;
        $parent = $new_parent;
        WebGUI::Test->addToCleanup($new_parent);
    }
    return @parents;
}

sub _constructor : Test(4) {
    my $test    = shift;
    my $session = $test->session;
    my $asset   = $test->class->new({session => $session, $test->constructorExtras($session), });

    note '=' x 80;
    note "Constructor: CLASS " . $test->class;
    note '=' x 80;

    isa_ok $asset, $test->class, "asset we created isa ``@{[ $test->class ]}''";
    isa_ok $asset->session, 'WebGUI::Session', "the session @{[ $test->class ]} we created isa WebGUI::Session";
    is $asset->session->getId, $session->getId, 'asset was assigned the correct session';

    note "calling new with no assetId throws an exception";
    $asset = eval { WebGUI::Asset->new($session, ''); };
    my $e = Exception::Class->caught;
    isa_ok $e, 'WebGUI::Error';
    undef $@;

}

sub t_00_class_dispatch : Test(2) {
    # XXX this could be moved out of Test::Class into a linear test, such as in Asset.t
    my $test    = shift;
    my $session = $test->session;
    note "Class dispatch";
    # my $asset   = $test->class->new({session => $session});

    my $asset = WebGUI::Asset->new({
        session   => $session,
        title     => 'testing snippet',
        className => 'WebGUI::Asset::Snippet',
    });

    isa_ok $asset, 'WebGUI::Asset';
    is $asset->className, 'WebGUI::Asset', 'passing className is ignored';

    debug($@);
    undef $@;
}

sub t_00_get_tables : Test(1) {
    my $test    = shift;
    note "get_tables";
    my @tables = $test->class->meta->get_tables;
    cmp_bag(
        \@tables,
        $test->list_of_tables,
        'Set of tables for properties is correct'
    );

    debug($@);
    undef $@;
}

sub t_00_getParent : Test(2) {
    my $test    = shift;
    my $session = $test->session;
    note "getParent";
    my $testId1      = 'wg8TestAsset0000000001';
    my $testId2      = 'wg8TestAsset0000000002';
    my $now          = time();
    my $baseLineage  = $session->db->quickScalar('select lineage from asset where assetId=?',['PBasset000000000000002']);
    my $testLineage  = $baseLineage. '909090';
    $session->db->write("insert into asset (assetId, className, lineage) VALUES (?,?,?)",       [$testId1, 'WebGUI::Asset', $testLineage]);
    $session->db->write("insert into assetData (assetId, revisionDate, status) VALUES (?,?,?)", [$testId1, $now, 'approved']);
    my $testLineage2 = $testLineage . '000001';
    $session->db->write("insert into asset (assetId, className, parentId, lineage) VALUES (?,?,?,?)", [$testId2, 'WebGUI::Asset', $testId1, $testLineage2]);
    $session->db->write("insert into assetData (assetId, revisionDate) VALUES (?,?)", [$testId2, $now]);

    my $testAsset = WebGUI::Asset->new($session, $testId2, $now);
    is $testAsset->parentId, $testId1, 'parentId assigned correctly on db fetch in new';
    my $testParent = $testAsset->getParent();
    isa_ok $testParent, 'WebGUI::Asset';

    $session->db->write("delete from asset where assetId like 'wg8TestAsset00000%'");
    $session->db->write("delete from assetData where assetId like 'wg8TestAsset00000%'");

    debug($@);
    undef $@;
}

sub t_00_newByPropertyHashRef : Test(2) {
    my $test    = shift;
    my $session = $test->session;
    note "newByPropertyHashRef";
    my $asset;
    $asset = WebGUI::Asset->newByPropertyHashRef($session, {
        className => $test->class, 
        title => 'The Shawshank Snippet',
        $test->constructorExtras($session),
    });
    isa_ok $asset, $test->class;
    is $asset->title, 'The Shawshank Snippet', 'title is assigned from the property hash';

    debug($@);
    undef $@;
}

sub t_00_scan_properties : Test(1) {
    note "scan properties for table definitions";
    my $test    = shift;
    my @properties = $test->class->meta->get_all_properties;
    my @undefined_tables = ();
    foreach my $prop (@properties) {
        push @undefined_tables, $prop->name if (!$prop->tableName);
    }
    ok !@undefined_tables, "all properties have tables defined"
        or diag "except these: ".join ", ", @undefined_tables;

    debug($@);
    undef $@;
}

sub t_01_assetId : Test(4) {
    my $test    = shift;
    my $session = $test->session;
    my $asset   = $test->class->new({
        session => $session,
        $test->constructorExtras($session),
    });
    note "assetId, getId";
    can_ok $asset, qw/assetId getId/;
    ok $session->id->valid( $asset->assetId), 'assetId generated by default is valid';
    is $asset->assetId, $asset->getId, '... getId is an alias for assetId';

    $asset = $test->class->new({ session => $session, assetId => '', $test->constructorExtras($session), });
    ok !$session->id->valid($asset->assetId), 'blank assetId in constructor is okay??';

    debug($@);
    undef $@;
}

sub t_01_title : Test(6) {
    my $test    = shift;
    my $session = $test->session;
    my $asset   = $test->class->new({
        session => $session,
        $test->constructorExtras($session),
    });

    note "title";
    can_ok $asset, 'title';
    is $asset->title, 'Untitled', 'title: default is untitled';

    $asset->title('asset title');
    is $asset->title, 'asset title', '... set, get';
    $asset->title('');
    is $asset->title, 'Untitled', '... get default title when empty title set';
    $asset->title('<h1>Header</h1>text');
    is $asset->title, 'Headertext', '... HTML is filtered out';
    $asset->title('<h1></h1>');
    is $asset->title, 'Untitled', '... if HTML filters out all, returns default';

    #is $asset->get('title'), $asset->title, '... get(title) works';

    debug($@);
    undef $@;
}

sub t_01_menuTitle : Test(8) {
    my $test    = shift;
    my $session = $test->session;
    my $asset = $test->class->new({
        session => $session,
        $test->constructorExtras($session),
    });

    note "menuTitle";

    can_ok $asset, 'menuTitle';
    is $asset->menuTitle, 'Untitled', 'menuTitle: default is untitled';

    $asset = $test->class->new({
        $test->constructorExtras($session),
        session => $session,
        title   => 'asset title',
    });

    is $asset->menuTitle, 'asset title', 'menuTitle: default is title';

    $asset->menuTitle('asset menuTitle');
    is $asset->menuTitle, 'asset menuTitle', '... set and get';

    $asset->menuTitle('');
    is $asset->menuTitle, 'asset title', '... set to default when trying to clear the title';

    $asset->menuTitle('<h1>Header</h1>text');
    is $asset->menuTitle, 'Headertext', '... HTML is filtered out';
    $asset->menuTitle('<h1></h1>');
    is $asset->menuTitle, 'asset title', '... if HTML filters out all, returns default';

    $asset = $test->class->new({
        $test->constructorExtras($session),
        session   => $session,
        title     => 'asset title',
        menuTitle => 'menuTitle asset',
    });
    is $asset->menuTitle, 'menuTitle asset', '... set via constructor';

    debug($@);
    undef $@;
}

sub t_01_uiLevel : Test(1) {
    my $test    = shift;
    my $session = $test->session;
    note "uiLevel";
    my $asset = $test->class->new({
        session => $session,
        $test->constructorExtras($session),
    });
    is $asset->uiLevel, $test->assetUiLevel, 'asset uiLevel check';

    debug($@);
    undef $@;
}

sub t_01_write_update : Test(8) {
    my $test    = shift;
    my $session = $test->session;
    note "write, update";

    my $testId       = 'wg8TestAsset0000000001';
    my $revisionDate = time();
    $session->db->write("insert into asset (assetId) VALUES (?)", [$testId]);
    $session->db->write("insert into assetData (assetId, revisionDate) VALUES (?,?)", [$testId, $revisionDate]);

    my $testAsset = WebGUI::Asset->new($session, $testId, $revisionDate);
    $testAsset->title('wg8 test title');
    $testAsset->lastModified(0);
    is $testAsset->assetSize, 0, 'assetSize is 0 by default';
    $testAsset->write();
    isnt $testAsset->lastModified, 0, 'lastModified updated on write';
    isnt $testAsset->assetSize,    0, 'assetSize    updated on write';

    my $testData = $session->db->quickHashRef('select * from assetData where assetId=? and revisionDate=?',[$testId, $revisionDate]);
    is $testData->{title}, 'wg8 test title', 'data written correctly to db';

    $testAsset->update({
        isHidden    => 1,
        encryptPage => 1,
    });

    is $testAsset->isHidden,    1, 'isHidden set via update';
    is $testAsset->encryptPage, 1, 'encryptPage set via update';

    $testData = $session->db->quickHashRef('select * from assetData where assetId=? and revisionDate=?',[$testId, $revisionDate]);
    is $testData->{isHidden},    1, 'isHidden written correctly to db';
    is $testData->{encryptPage}, 1, 'encryptPage written correctly to db';

    $session->db->write("delete from asset where assetId=?", [$testId]);
    $session->db->write("delete from assetData where assetId=?", [$testId]);

    debug($@);
    undef $@;
}

sub t_05_cut_paste : Test(5) {
    note "cut";
    my $test    = shift;
    my $session = $test->session;
    my ($tag, $asset, @parents) = $test->getAnchoredAsset();
    ok $asset->cut, 'cut returns true if it was cut';
    is $asset->state, 'clipboard', 'asset state updated';
    my $session_asset = $session->asset();
    $session->asset($parents[-1]);
    ok eval { $asset->canPaste }, 'canPaste: allowed to paste here';
    debug($@);
    undef $@;
    ok eval { $parents[-1]->paste($asset->assetId) }, 'paste returns true when it pastes';
    debug($@);
    undef $@;
    my $asset_prime = eval { $asset->cloneFromDb };
    debug($@);
    undef $@;
    is $asset_prime->state, 'published', 'asset state updated';
    $session->asset($session_asset);
    debug($@);
    undef $@;
}

sub t_05_keywords : Test(3) {
    my $test    = shift;
    my $session = $test->session;
    my ($tag, $asset, @parents) = $test->getAnchoredAsset();
    can_ok $asset, 'keywords';
    $asset->keywords('chess set');
    is $asset->keywords, 'chess set', 'set and get of keywords via direct accessor';
    is $asset->get('keywords'), 'chess set', 'via get method';
    debug($@);
    undef $@;
}

sub t_05_purge : Test(3) {
    note "purge";
    my $test    = shift;
    my $session = $test->session;
    my ($tag, $asset, @parents) = $test->getAnchoredAsset();
    my @tables = $asset->meta->get_tables;
    ok $asset->purge, 'purge returns true if it was purged';
    throws_ok { WebGUI::Asset->newById($session, $asset->assetId); } 'WebGUI::Error::InvalidParam', 'Unable to fetch asset by assetId now'; 
    undef $@; # or else Test::Class barfs
    my $exists_in_table = 0;
    foreach my $table (@tables) {
        $exists_in_table ||= $session->db->quickScalar("select count(*) from `$table` where assetId=?",[$asset->assetId]);
    }
    ok ! $exists_in_table, 'assetId removed from all asset tables';
    debug($@);
    undef $@;
}

sub t_10_addRevision : Tests {
    note "addRevision";
    my ( $test ) = @_;
    my $session = $test->session;
    my ( $tag, $asset, @parents ) = $test->getAnchoredAsset();
    $tag->setWorking;

    my $newRevision = $asset->addRevision( 
        { title => "Newly Revised Title" }, 
        $asset->revisionDate+2, 
    );
    isa_ok( $newRevision, Scalar::Util::blessed( $asset ), "addRevision returns new revision of asset object" );
    is( $newRevision->title, "Newly Revised Title", "properties set correctly" );
    is( $newRevision->revisionDate, $asset->revisionDate+2, 'revisionDate set correctly' );
    $newRevision->purgeRevision;

    debug($@);
    undef $@;
}

sub t_11_getEditForm : Tests {
    note "getEditForm";
    my ( $test ) = @_;
    my $session = $test->session;
    my ( $tag, $asset, @parents ) = $test->getAnchoredAsset();

    # local $SIG{__DIE__} = sub { use Carp; Carp::confess "@_"; };
    # local $SIG{__DIE__} = sub { use wth; wth::wth "@_"; };  # wth.pm is in a gist of scrottie's on github

    my $f   = $asset->getEditForm;

    isa_ok( $f, 'WebGUI::FormBuilder' );

    # assetId, className, keywords
    isa_ok( $f->getTab('meta')->getField('assetId'), 'WebGUI::Form::Guid' );
    isa_ok( $f->getTab('meta')->getField('className'), 'WebGUI::Form::ClassName' );
    isa_ok( $f->getTab('meta')->getField('keywords'), 'WebGUI::Form::Keywords' );

    # Tabs
    isa_ok( $f->getTab('properties'), 'WebGUI::FormBuilder::Tab' );
    isa_ok( $f->getTab('display'), 'WebGUI::FormBuilder::Tab' );
    isa_ok( $f->getTab('security'), 'WebGUI::FormBuilder::Tab' );
    isa_ok( $f->getTab('meta'), 'WebGUI::FormBuilder::Tab' );

    # Metadata

    # Property overrides
    ok( !$f->getField('func'), 'form must not contain "func"' );

    # Properties
    use Data::Dumper;

    # compare $asset->getProperties to $asset->getEditForm->getFieldsRecursive

    my @properties = (
        List::MoreUtils::uniq                # no dups, please
        $test->dynamic_form_labels,          # per-test hard-coded labels known to be added at runtime vs with property blocks
        grep { ($_ ne 'Mobile Template') xor $session->setting->get('useMobileStyle') }
        grep $_,                             # a rare few property blocks have niether noFormPost nor label? XXX TODO tests/fix
        map { $asset->getFormProperties($_)->{label} }   # getFormProperties returns a plain hash
        grep { ! $asset->meta->find_attribute_by_name( $_ )->noFormPost } 
        $asset->getProperties
    ); 

    my @form = (
        List::MoreUtils::uniq
        grep { $_ and $_ ne 'Keywords' and $_ ne 'Class Name' and $_ ne 'Asset ID' and $_ ne 'Approved' }
        map $_->get('label'),
        flattenFormObjects($f->getFieldsRecursive)    # mixture of arrays of Form objects and arrays-of-arrays of them; flatten it out
    );

    my %superlist = map { ( $_ => 1 ) } @form, @properties;
    # note "all labels: " . join ', ', keys %superlist;

    for my $label (keys %superlist) {
        no warnings 'uninitialized';
        note "label ``$label'' not in properties" if ! grep { $_ eq $label } @properties;
        note "label ``$label'' not in form" if ! grep { $_ eq $label } @form;
    }

    note "properties: " . join ', ', sort { $a cmp $b } map { $_ } @properties;
    note "form: " . join ', ', sort { $a cmp $b } map { $_ } @form;

    cmp_deeply(
        \@properties,
        subbagof( @form ),
        'getProperties are all in getEditForm->getFieldsRecursive',
    );

    debug($@);
    undef $@;

}

sub t_20_www_editSave : Tests {
    note "www_editSave";
    my ( $test ) = @_;
    my $session = $test->session;
    my ( $tag, $asset, @parents ) = $test->getAnchoredAsset();

    # Alter permissions so www_editSave works
    my $oldGroupId = $asset->groupIdEdit;
    $asset->groupIdEdit( 7 ); # Everybody! Everybody!

    $asset->commit;
    $tag->setWorking;
    sleep 2; # XXXX Todo -- investigate whether this is actually fixing duplicate commit problems

    my %mergedProperties = (   
        formProperties($asset),  
        title       => "Newly Saved Title", 
    );

    $test->postProcessMergedProperties(\%mergedProperties);

    # local $SIG{__DIE__} = sub { use Carp; Carp::confess "@_"; };
    # local $SIG{__DIE__} = sub { use wth; wth::wth "@_"; };  # see note above about wth

    $session->request->setup_body( \%mergedProperties );

    my $content;
    ok(eval { $asset->www_editSave; }, 'www_editSave returns true');
    debug($@);
    undef $@;

    # Get the newly-created revision of the asset
    ok( my $newRevision = eval { WebGUI::Asset->newPending( $session, $asset->getId ); }, 'newPending returns true' );
    debug($@);
    undef $@;

    ok( $newRevision->tagId, 'new revision has a tag' );
    if ( $asset->getAutoCommitWorkflowId ) {
        isnt( $newRevision->tagId, $tag->getId, 'Not added to existing working tag' );
        ok( my $newTag = WebGUI::VersionTag->new( $session, $newRevision->tagId ), 'tag exists' );
    }
    else {
        is( $newRevision->tagId, $tag->getId, "Added to existing working tag" );
    }
    is( $newRevision->title, $mergedProperties{title}, 'new revision has the corret title' );

    # Alter permissions so it does not work
    # XXX todo?

    # Set locked so it does not work
    # XXX todo?

    eval { $asset->groupIdEdit( $oldGroupId ); };

    debug($@);
    undef $@;
}

sub t_20_addSave : Tests {
    note "www_addSave";
    my ( $test ) = @_;
    my $session = $test->session;
    my ( $tag, $asset, @parents ) = $test->getAnchoredAsset();

    # Alter permissions so www_addSave works
    my $oldGroupId = $asset->groupIdEdit;
    $asset->groupIdEdit( 7 ); # Everybody! Everybody!

    $tag->setWorking;


    debug( $@ );
    undef $@;
}

#sub asserts : Test(shutdown) {
#    # XXX Todo these should be moved into the appropriate Test::Class subclasses and be made more explicit, if they are to be kept
#    # XXX debugging garbage to track down corruption of the asset tree
#    my $test = shift;
#    my $session = $test->session;
#    my $assets = WebGUI::Asset->getRoot($session)->getLineage(['descendants'], {returnObjects=>1});
#    # local $SIG{__DIE__} = sub { use wth; wth::wth "@_"; }; # see note above about wth
#    for my $asset (@$assets) {
#        #if(ref($asset) eq 'WebGUI::Asset::Wobject::Layout') {
#        #    note "running view on Wobject::Layout of Id: " . $asset->getId;
#        #    # make sure any WG::A::Story objects created check out before testing gets any further along
#        #    $asset->view; 
#        #}
#        if(ref($asset) eq 'WebGUI::Asset::Story') {
#            note "running canEdit on Asset::Story of Id: " . $asset->getId;
#            # make sure any WG::A::Story objects created check out before testing gets any further along
#            $asset->canEdit; 
#        }
#    }
#}

1;

__END__

{
    note "getClassById";
    my $class;
    $class = WebGUI::Asset->getClassById($session, 'PBasset000000000000001');
    is $class, 'WebGUI::Asset', 'getClassById: retrieve a class';
    $class = WebGUI::Asset->getClassById($session, 'PBasset000000000000001');
    is $class, 'WebGUI::Asset', '... cache check';
    $class = WebGUI::Asset->getClassById($session, 'PBasset000000000000002');
    is $class, 'WebGUI::Asset::Wobject::Folder', '... retrieve another class';
}

{
    note "new, fetching from db";
    my $asset;
    $asset = WebGUI::Asset->new($session, 'PBasset000000000000001');
    isa_ok $asset, 'WebGUI::Asset';
    is $asset->title, 'Root', 'got the right asset';
}

{
    note "getDefault";
    my $asset = WebGUI::Asset->getDefault($session);
    isa_ok $asset, 'WebGUI::Asset::Wobject::Layout';
}

{
    note "get gets WebGUI::Definition properties, and standard attributes";
    my $asset = WebGUI::Asset->new({session => $session, parentId => 'I have a parent'});
    is $asset->get('className'), 'WebGUI::Asset', 'get(property) works on className';
    is $asset->get('assetId'),  $asset->assetId,   '... works on assetId';
    is $asset->get('parentId'), 'I have a parent',  '... works on parentId';
    my $properties = $asset->get();
    is $properties->{className}, 'WebGUI::Asset', 'get() works on className';
    is $properties->{assetId},  $asset->assetId,   '... works on assetId';
    is $properties->{parentId}, 'I have a parent',  '... works on parentId';
}

