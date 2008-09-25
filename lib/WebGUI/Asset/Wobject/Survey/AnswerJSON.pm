package WebGUI::Asset::Wobject::Survey::AnswerJSON;

use strict;
use Data::Structure::Util qw/unbless/;

sub new{
    my $class = shift;
    my $self = shift || {};
    my $parent = shift;
    $self->{answers} = $self->{answers} || [];
    $self->{text};
    $self->{index};
    $self->{parentIndex};
    $self->{parent} = $parent;
    $self->{verbatim};
    $self->{textCols};
    $self->{textRows};
    $self->{gotoQuestion};
    $self->{recordedAnswer};
    $self->{isCorrect};
    $self->{min};
    $self->{max};
    $self->{step};
    $self->{value};
    $self->{terminal};
    $self->{terminalUrl};
    $self->{type} = 'answer';
    bless($self,$class);
    return $self;
}
sub update{
    my ($self,$ref) = @_;

    while(my ($key,$value) = keys %{$ref->{object}}){
        $self->{$key} = $value;
    }
}
sub remove{
    my $self = shift;
    $self->{parent} = undef;
}
sub freeze{
    my $self = shift;
    my %temp = %{$self};
    $temp{parent} = undef;
#    unbless $self;
    return \%temp;
}

#address is the array of objects currently selected in the edit screen
#data is the array of hash items for displaying  
sub getDragDropList{
    my ($self,$data,$address,$selected) = @_;
    push(@$data, { "type",$self->{type},"text",$self->{"text"}, "recorded", $self->{'recordedAnswer'} });
}
1;
