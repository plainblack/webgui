package WebGUI::Asset::Wobject::Survey::SectionJSON;

use strict;
use Data::Structure::Util qw/unbless/;
use WebGUI::Asset::Wobject::Survey::QuestionJSON;

sub new{
    my $class = shift;
    my $self = shift || {};
    my $parent = shift;

    if(defined $self->{questions}){
        foreach(@{$self->{questions}}){
            $_ = WebGUI::Asset::Wobject::Survey::QuestionJSON->new($_);
        }
    }else{
        $self->{questions} = [];
    }

    $self->{text}                       = $self->{text} || '';
    $self->{title}                      = $self->{title} || 'New Section';
    $self->{parent}                     = $parent;
    $self->{questionsPerPage}           = $self->{questionsPerPage} || 5;
    $self->{questionsOnSectionPage}     = $self->{questionsOnSectionPage} || 1;
    $self->{randomizeQuestions}         = $self->{randomizeQuestions} || 0;
    $self->{everyPageTitle}             = $self->{everyPageTitle} || 1;
    $self->{everyPageText}              = $self->{everyPageText} || 1;
    $self->{terminal}                   = $self->{terminal} || 0;
    $self->{terminalUrl};
    $self->{goto};
    $self->{timeLimit};
    $self->{type}                       = 'section';

    bless($self,$class);
    return $self;
}
sub getObject{ 
    my ($self,$address) = @_;
    if(@$address == 1){
        return $self->{questions}->[$address->[1]];
    }else{
        return $self->{questions}->[$address->[1]]->getObject($address);
    }
}
sub newQuestion{
    my $self = shift;
    push(@{$self->{questions}}, WebGUI::Assest::Wobject::Survey::QuestionJSON->new( $self,@{$self->{questions}}) );
}
sub remove{
    my ($self,$ref) = @_;
    $self->{questions}->[$$ref{ids}->[1]]->remove($ref);
    if(@$$ref{ids} == 0){
        for my $question(@{$self->{questions}}){
            $question->remove($ref);
        }
        $self->{parent} = undef;
    }
    if(@$$ref{ids} == 1){
        splice(@{$self->{questions}},$$ref->{ids}->[1],1);
    }
}

sub update{
    my ($self,$ref) = @_;

    #is a section
    if(@{$$ref{ids}} == 0){
        while(my ($key,$value) = keys %{$ref->{object}}){
            $self->{$key} = $value;
        }
    #is a new question
    }elsif($$ref{ids}->[1] eq 'NEW'){
        push(@{$self->{questions}}, WebGUI::Assest::Wobject::Survey::QuestionJSON->new( $self,@{$self->{object}}) );

    #is updating a question or answer
    }else{
        $self->{questions}->[$$ref{ids}->[1]]->update($ref);
    }
}

sub loadQuestion{
    my ($self,$questionHash) = @_;
    push(@{$self->{questions}}, WebGUI::Assest::Wobject::Survey::QuestionJSON->new( $self,@{$self->{questions}},$questionHash) );
}

sub deleteQuestion{
    my $self = shift;
    my $index = shift;
    splice(@{$self->{questions}},$index,1) if defined $index; 
}
#address is the array of objects currently selected in the edit screen
#data is the array of hash items for displaying  
sub getDragDropList{
    my ($self,$data,$address,$selected) = @_;
    push(@$data,{ "type",$self->{type},"text",$self->{"title"} });
    if($selected){
        for(my $i=0; $i<=$#{$self->{questions}}; $i++){
            $self->{questions}->[$i]->getDragDropList($data, $address, $i == $address->[1]);
        }
    }
}
sub getQuestion{
    my $self = shift;
    my $index = shift;
    return $self->{questions}->[$index] if defined $index;
}

sub freeze{
    my $self = shift;

    my %temp = %{$self};
    $temp{parent} = undef;
    $temp{questions} = [];
    foreach(@{$self->{questions}}){
        push(@{$temp{questions}}, $_->freeze());
    }
    return \%temp;
}

sub createTemp{
    my ($self,$ref) = @_;
    if(@{$$ref{ids}} > 1){
        return $self->{questions}->[$$ref{ids}->[1]]->createTemp($ref);
    }else{
        return  WebGUI::Asset::Wobject::Survey::QuestionJSON->new($self);
    }
}
1;
