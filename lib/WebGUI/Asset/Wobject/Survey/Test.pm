package WebGUI::Asset::Wobject::Survey::Test;

use base qw/WebGUI::Crud/;
use WebGUI::International;

=head1 NAME

Package WebGUI::Asset::Wobject::Survey::Test;

=head1 DESCRIPTION

Base class for Survey tests

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 crud_definition ( )

WebGUI::Crud definition for this class.

=head3 tableName

Survey_test

=head3 tableKey

testId

=head3 assetId

testId

=head3 sequenceKey

assetId, e.g. each Survey instance has its own sequence of tests.

=head3 properties

=head4 assetId

Identifies the Survey instance.

=head4 name

A name for the test

=head4 test

The test code

=cut

sub crud_definition {
    my ( $class, $session ) = @_;
    my $definition = $class->SUPER::crud_definition($session);
    $definition->{tableName}   = 'Survey_test';
    $definition->{tableKey}    = 'testId';
    $definition->{sequenceKey} = 'assetId';
    my $properties = $definition->{properties};
    my $i18n       = WebGUI::International->new($session);
    $properties->{assetId} = {
        fieldType    => 'hidden',
        defaultValue => undef,
    };
    $properties->{name} = {
        fieldType    => 'text',
        label        => $i18n->get( 'test name', 'Asset_Survey' ),
        hoverHelp    => $i18n->get( 'test name help', 'Asset_Survey' ),
        defaultValue => '',
    };
    $properties->{test} = {
        fieldType    => 'codearea',
        label        => $i18n->get( 'test code', 'Asset_Survey' ),
        hoverHelp    => $i18n->get( 'test code help', 'Asset_Survey' ),
        syntax       => 'perl',
        defaultValue => 'test()',
    };
    return $definition;
}

1;

#vim:ft=perl
