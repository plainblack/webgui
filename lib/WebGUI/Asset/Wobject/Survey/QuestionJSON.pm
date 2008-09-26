package WebGUI::Asset::Wobject::Survey::QuestionJSON;

use strict;
use Data::Structure::Util qw/unbless/;

sub new{
    my $class = shift;
    my $self = shift || {};
    my $posts = shift;

    if(defined $self->{answers}){
        foreach(@{$self->{answers}}){
            $_ = WebGUI::Asset::Wobject::Survey::AnswerJSON->new($_);
        }
    }else{
        $self->{answers} = [];
    }

    $self->{variableName} = $self->{variableName} || '';
    $self->{text} = $self->{text} || '';
    $self->{allowComment} = $self->{allowComment} || 0;
    $self->{commentCols} = $self->{commentCols} || 10;
    $self->{commentRows} = $self->{commentRows} || 5;
    $self->{randomizeAnswers} = $self->{randomizeAnswers} || 0;
    $self->{questionType} = $self->{questionType} || '';
    $self->{randomizedWords} = $self->{randomizedWords} || '';
    $self->{verticalDisplay} = $self->{verticalDisplay} || 0;
    $self->{required} = $self->{required} || 0;
    $self->{maxAnswers} = $self->{maxAnswers} || 1;
    $self->{value} = $self->{value} || 1;
    $self->{textInButton} = $self->{textInButton} || 0;
    $self->{terminal} = $self->{terminal} || 0;
    $self->{terminalUrl} = $self->{terminalUrl} || '';
    $self->{type}       = 'question';

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
    #is a question
    if(@{$$ref{ids}} == 1){
        while (my ($key,$value) = each %{$ref->{object}}){
            $self->{$key} = $value;
        }
    #is a new answer
    }elsif($$ref{ids}->[2] eq 'NEW'){
        push(@{$self->{answers}}, WebGUI::Assest::Wobject::Survey::AnswerJSON->new( {},$ref) );
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
    my ($self,$address) = @_;
    splice(@{$self->{answers}},$$address[2],1);
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
    push(@$data, { "type",$self->{type},"text",$self->{text} });
    if($selected){
        for (@{$self->{answers}}){
            $_->getDragDropList($data, $address);
        }
    }
}

1;
