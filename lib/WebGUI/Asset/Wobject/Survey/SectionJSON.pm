package WebGUI::Asset::Wobject::Survey::SectionJSON;

use strict;
use Data::Structure::Util qw/unbless/;
use WebGUI::Asset::Wobject::Survey::QuestionJSON;

use Data::Dumper;

sub new{
    my $class = shift;
    my $self = shift || {};
    my $postInfo = shift;
    my $log = shift; 
    if(defined $self->{questions}){
        foreach(@{$self->{questions}}){
            $_ = WebGUI::Asset::Wobject::Survey::QuestionJSON->new($_);
        }
    }else{
        $self->{questions} = [];
    }
    $self->{log}                        = $log if defined $log;
    $self->{text}                       = $self->{text} || '';
    $self->{title}                      = $self->{title} || 'New Section';
    $self->{variable}                   = $self->{variable} || '';
    $self->{questionsPerPage}           = $self->{questionsPerPage} || 5;
    $self->{questionsOnSectionPage}     = defined $self->{questionsOnSectionPage} ? $self->{questionsOnSectionPage} : 1;
    $self->{randomizeQuestions}         = $self->{randomizeQuestions} || 0;
    $self->{everyPageTitle}             = defined $self->{everyPageTitle} ? $self->{everyPageTitle} : 1;
    $self->{everyPageText}              = defined $self->{everyPageText} ? $self->{everyPageText} : 1;
    $self->{terminal}                   = $self->{terminal} || 0;
    $self->{terminalUrl}                = $self->{terminalUrl} || '';
    $self->{goto}                       = $self->{goto} || '';
    $self->{timeLimit}                  = $self->{timeLimit} || 0;
    $self->{type}                       = 'section';
    
    if(defined $postInfo and ref $postInfo eq 'HASH'){
        while(my ($key,$value) = each %$postInfo){
            if(defined $self->{$key}){
                $self->{$key} = $value;
            }
        }
    }

    bless($self,$class);
    return $self;
}
sub getObject{ 
    my ($self,$address) = @_;
    if(@$address == 2){
        return $self->{questions}->[$address->[1]];
    }else{
        return $self->{questions}->[$address->[1]]->getObject($address);
    }
}
sub getEditVars{
    my ($self,$address) = @_;
$self->{log}->error("section geteditvars");
    if(@$address > 1){
        return $self->{questions}->[$address->[1]]->getEditVars($address);
    }
    #Fill in a template var hash and return it
    my %var;
    while (my ($key,$value) = each %{$self}){
        if($key ne 'questions' and $key ne 'questionsPerPage' and $key ne 'log'){
            $var{$key} = $value;
        }
    }
    for(1 .. 10){
        if($_ == $self->{questionsPerPage}){
            push(@{$var{questionsPerPage}},{'index',$_,'selected',1});
        }else{
            push(@{$var{questionsPerPage}},{'index',$_,'selected',0});
        }
    }
    return \%var;
        
}
sub newQuestion{
    my $self = shift;
    push(@{$self->{questions}}, WebGUI::Assest::Wobject::Survey::QuestionJSON->new( $self,@{$self->{questions}}) );
}
sub remove{
    my ($self,$address) = @_;
    if(@$address == 2){
        splice(@{$self->{questions}},$$address[1],1);
    }else{
        $self->{questions}->[$$address[1]]->remove($address);
    }
}

sub update{
    my ($self,$address,$ref,$log) = @_;
    if(@{$address} == 1){
        while(my ($key,$value) = each %{$ref}){
            $self->{$key} = $value if defined $self->{$key};
        }
    #is a new question
    }elsif($$ref{ids}->[1] eq 'NEW'){
        push(@{$self->{questions}}, WebGUI::Assest::Wobject::Survey::QuestionJSON->new({},$ref) );

    #is updating a question or answer
    }else{
        $self->{questions}->[$$ref{ids}->[1]]->update($address,$ref);
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

    $temp{questions} = [];
    foreach(@{$self->{questions}}){
        push(@{$temp{questions}}, $_->freeze());
    }
    delete $temp{log};
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
