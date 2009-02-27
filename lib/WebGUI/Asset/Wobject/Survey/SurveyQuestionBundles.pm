package WebGUI::Asset::Wobject::Survey::SurveyQuestionBundles;

use base WebGUI::Crud;

sub crud_definition {
    my ( $class, $session ) = @_;
    my $definition = $class->SUPER::crud_definition($session);
    $definition->{tableName}        = 'Survey_questionBundles';
    $definition->{tableKey}         = 'assetId';
    $definition->{properties}{} = {
        fieldType    => 'text',
        defaultValue => undef,
    };
    $definition->{properties}{} = {
        fieldType    => 'text',
        defaultValue => undef,
    };
    return $definition;
}

