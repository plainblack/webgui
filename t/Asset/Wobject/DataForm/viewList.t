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

WebGUI::Test->tagsToRollback( WebGUI::VersionTag->getWorking( $session ) );

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

my @entries = ();
for my $properties (@entryProperties) {
    my $entry = $df->entryClass->newFromHash( $df, $properties );
    $entry->save;
    push @entries, $entry;
    sleep 1;
}

#----------------------------------------------------------------------------
# Tests

plan tests => 2;    # Increment this number for each test you create

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


#----------------------------------------------------------------------------
# Cleanup

#vim:ft=perl
