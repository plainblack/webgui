package WebGUI::Asset::Wobject::Survey::AnswerJSON;

use strict;
use Data::Structure::Util qw/unbless/;

sub new{
    my $class = shift;
    my $self = shift || {};
    my $posts = shift;
    $self->{answers} = $self->{answers} || [];
    $self->{text} = $self->{text} || '';
    $self->{verbatim} = $self->{verbatim} || '';
    $self->{textCols} = $self->{textCols} || 10;
    $self->{textRows} = $self->{textRows} || 5;
    $self->{gotoQuestion} = $self->{gotoQuestion} || '';
    $self->{recordedAnswer} = $self->{recordedAnswer} || '';
    $self->{isCorrect} = $self->{isCorrect} || 1;
    $self->{min} = $self->{min} || 1;
    $self->{max} = $self->{max} || 10;
    $self->{step} = $self->{step} || 1;
    $self->{value} = $self->{value} || 1;
    $self->{terminal} = $self->{terminal} || 0;
    $self->{terminalUrl} = $self->{terminalUrl} || '';
    $self->{type} = 'answer';

    if(defined $posts and ref $posts eq 'HASH'){
        while(my ($key,$value) = each %$posts){
            if(defined $self->{$key}){
                $self->{$key} = $value;
            }
        }
    }
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
}
sub freeze{
    my $self = shift;
    my %temp = %{$self};
#    $temp{parent} = undef;
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
