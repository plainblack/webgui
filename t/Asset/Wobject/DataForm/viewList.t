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

addToCleanup( WebGUI::VersionTag->getWorking( $session ) );

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

my @entries = ();
for my $properties (@entryProperties) {
    my $entry = $df->entryClass->newFromHash( $df, $properties );
    $entry->submissionDate(WebGUI::DateTime->new($session, $birthday++));
    $entry->save;
    push @entries, $entry;
}

#----------------------------------------------------------------------------
# Tests

plan tests => 6;    # Increment this number for each test you create

#----------------------------------------------------------------------------
# Test getListTemplateVars

my $tmplVar     = $df->getListTemplateVars({});

# First our field definitions
my @fields  = (
    {
        name        => "from",
        type        => "email",
        isMailField => 1,
        label       => ignore(),
    },
    {
        name        => "to",
        type        => "email",
        isMailField => 1,
        label       => ignore(),
    },
    {
        name        => "cc",
        type        => "email",
        isMailField => 1,
        label       => ignore(),
    },
    {
        name        => "bcc",
        type        => "email",
        isMailField => 1,
        label       => ignore(),
    },
    {
        name        => "subject",
        type        => "text",
        isMailField => 1,
        label       => ignore(),
    },
    {
        name        => "name",
        type        => "text",
        isMailField => undef,
        label       => undef,
    },
    {
        name        => "message",
        type        => "text",
        isMailField => undef,
        label       => ignore(),
    },
);

#-------------------------------------
# Test the field_loop
my $fieldVars   = [];
for my $field ( @fields ) {
    my $var = {};
    for my $key ( keys %$field ) {
        $var->{ 'field.' . $key } = $field->{ $key };
    }
    push @{$fieldVars}, $var;
}

cmp_deeply( $tmplVar->{field_loop}, $fieldVars, 'field_loop is complete and correct' );

#-------------------------------------
# Test the record_loop
my $recordVars  = [];
my $entryIdx    = $#entries; # ordered by insert in reverse
while ( $entryIdx >= 0 ) {
    my $var = {
        'record.noloop.bcc'     => $entries[$entryIdx]->field('bcc'),
        'record.noloop.cc'      => $entries[$entryIdx]->field('cc'),
        'record.noloop.from'    => $entries[$entryIdx]->field('from'),
        'record.noloop.message' => $entries[$entryIdx]->field('message'),
        'record.noloop.name'    => $entries[$entryIdx]->field('name'),
        'record.noloop.subject' => $entries[$entryIdx]->field('session'),
        'record.noloop.to'      => $entries[$entryIdx]->field('to'),

        'record.entryId'        => $entries[$entryIdx]->getId,
        'record.userId'         => $session->user->userId,
        'record.username'       => $session->user->username,
        'record.ipAddress'      => undef,
        'record.delete.icon'    => ignore(),
        'record.delete.url'     => ignore(),
        'record.edit.icon'      => ignore(),
        'record.edit.url'       => ignore(),
        'record.submissionDate.epoch' => ignore(),
        'record.submissionDate.human' => ignore(),
    };
     
    my $fieldVars   = [];
    for my $field ( @fields ) {
        my $var = {};
        for my $key ( keys %$field ) {
            $var->{ 'record.data.' . $key } = $field->{ $key };
        }
        $var->{ record_data_type } = delete $var->{ 'record.data.type' };


        # Don't care about mail fields...
        if ( $field->{isMailField} ) {
            $var->{ 'record.data.value' } = ignore();
        }
        else {
            $var->{ 'record.data.value' } = $entries[$entryIdx]->field( $field->{name} );
        } 
        
        push @{$fieldVars}, $var;
    }
    $var->{ 'record.data_loop' } = $fieldVars;

    push @{$recordVars}, $var;
    
    $entryIdx--;
}

cmp_deeply(
    $tmplVar->{record_loop},
    $recordVars,
    'getListTemplateVars is complete and correct',
);

is($tmplVar->{'pagination.pageCount'}, 1, '... and has pagination variables');

#-------------------------------------
#Shove in a bunch of data to test pagination

my @quoteDb = (
    { name => "Red",    message => "That tall drink of water", },
    { name => "Norton", message => "Do you enjoy working in the laundry?", },
    { name => "Andy",   message => "They say it has no memory", },
    { name => "Boggs",  message => "Hey, we all need friends in here", },
    { name => "Andy",   message => "It's my life.  Don't you understand?", },

    { name => "Red",    message => "Rehabilitated?  Well, now let me see.", },
    { name => "Red",    message => "I know what *you* think it means, sonny.", },
    { name => "Red",    message => "I know what *you* think it means, sonny.", },
    { name => "Andy",   message => "How can you be so obtuse?", },
    { name => "Red",    message => "The man likes to play chess; let's get him some rocks. ", },

    { name => "Brooks", message => "Easy peasy japanesey.", },
    { name => "Hadley", message => "What is your malfunction?", },
    { name => "Red",    message => "Hope is a dangerous thing. Hope can drive a man insane. ", },
    { name => "Red",    message => "They send you here for life, and that's exactly what they take.", },
    { name => "Red",    message => "Truth is, I don't want to know. Some things are best left unsaid.", },

    { name => "Andy",   message => "That's the beauty of music.", },
    { name => "Red",    message => "I played a mean harmonica as a younger man.", },
    { name => "Tommy",  message => "I don't read so good.", },
    { name => "Andy",   message => "You don't read so *well*.", },
    { name => "Red",    message => "Murder, same as you.", },

    { name => "Norton", message => "Salvation lies within.", },
    { name => "Andy",   message => "Remember Red, hope is a good thing.", },
    { name => "Hadley", message => "Drink up while it's cold, ladies.", },
    { name => "Red",    message => "We sat and drank with the sun on our shoulders and felt like free men.", },
    { name => "Andy",   message => "You see that's tax deductible, you can write that off. ", },

    { name => "Norton", message => "Lord! It's a miracle!", },
    { name => "Red",    message => "I don't have her stuffed down the front of my pants right now, I'm sorry to say, but I'll get her.", },
    { name => "Andy",   message => "Get busy living, or get busy dying.", },
    { name => "Brooks", message => "The world went and got itself in a big damn hurry.", },
    { name => "Andy",   message => "Everybody's innocent in here. Didn't you know that?", },

);

for my $quote (@quoteDb) {
    my $entry = $df->entryClass->newFromHash( $df, $quote );
    $entry->submissionDate(WebGUI::DateTime->new($session, $birthday++));
    $entry->save;
    push @entries, $entry;
}

$tmplVar = $df->getListTemplateVars({});
is @{ $tmplVar->{record_loop} }, 25, 'list variables are paginated';
ok $tmplVar->{'pagination.pageCount.isMultiple'}, 'pagination: has multiple pages';

$session->request->setup_body({ pn => 2, });
$tmplVar = $df->getListTemplateVars({});
is @{ $tmplVar->{record_loop} }, 7, '7 entries in the 2nd page';

#vim:ft=perl
