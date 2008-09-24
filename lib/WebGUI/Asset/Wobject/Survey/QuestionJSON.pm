package WebGUI::Asset::Wobject::Survey::QuestionJSON;

use strict;
use Data::Structure::Util qw/unbless/;

sub new{
    my $class = shift;
    my $self = shift || {};
    my $parent = shift;

    if(defined $self->{answers}){
        foreach(@{$self->{answers}}){
            $_ = WebGUI::Asset::Wobject::Survey::AnswerJSON->new($_);
        }
    }else{
        $self->{answers} = [];
    }

    $self->{variableName} = $self->{variableName} || '';
    $self->{text} = $self->{text} || '';
    $self->{parent} = $self->{parent} || $parent;  
    $self->{allowComment};
    $self->{commentCols};
    $self->{commentRows};
    $self->{randomizeAnswers};
    $self->{questionType};
    $self->{randomizedWords};
    $self->{verticalDisplay};
    $self->{required};
    $self->{maxAnswers};
    $self->{value};
    $self->{textInButton};
    $self->{terminal};
    $self->{terminalUrl};
    bless($self,$class);
    return $self;
}

sub update{
    my ($self,$ref) = @_;
    #is a question
    if(@{$$ref{ids}} == 1){
        while (my ($key,$value) = each %{$ref->{object}}){
            $self->{$key} = $value;
        }
    #is a new answer
    }elsif($$ref{ids}->[2] eq 'NEW'){
        push(@{$self->{answers}}, WebGUI::Assest::Wobject::Survey::AnswerJSON->new( $self,@{$self->{object}}) );
    #is updating a answer
    }else{
        $self->{answers}->[$$ref{ids}->[2]]->update($ref);
    }
}
sub getObject{ 
    my ($self,$address) = @_;
    return $self->{answers}->[$address->[2]];
}

sub createTemp{
    my ($self,$ref) = @_;
    return  WebGUI::Asset::Wobject::Survey::AnswerJSON->new($self);
}

sub remove{
    my ($self,$ref) = @_;
    if(@$$ref{ids} <= 1){
        $self->{parent} = undef;
        for my $answer(@{$self->{answers}}){
            $answer->remove();
        }
    }
    elsif(@$$ref{ids} == 2){
        $self->{answers}->[$$ref{ids}->[2]]->remove();
        splice(@{$self->{answers}},$$ref->{ids}->[2],1);
    }
}


sub freeze{
    my $self = shift;
    $self->{parent} = undef;
    my %temp = %{$self};
    $temp{answers} = [];
    foreach(@{$self->{answers}}){
        push(@{$temp{answers}},$_->freeze());
    }
    return \%temp;
}
#address is the array of objects currently selected in the edit screen
#data is the array of hash items for displaying  
sub getDragDropList{
    my ($self,$data,$address,$selected) = @_;
    push(@$data, { "type","question","text",$self->{text} });
    if($selected){
        for (@{$self->{answers}}){
            $_->getDragDropList($data, $address);
        }
    }
}

1;
