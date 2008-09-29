package WebGUI::Asset::Wobject::Survey::SurveyJSON;

use strict;
use JSON;
use Data::Dumper;

sub new{
    my $class = shift;
    my $json = shift;
    my $log = shift;
    my $self = {};
    $self->{log} = $log;
    my $temp = decode_json($json) if defined $json;
    $self->{sections} = defined $temp->{sections} ? $temp->{sections} : [];
    $self->{survey} = defined $temp->{survey} ? $temp->{survey} : {};
    $self->{gotoMap} = defined $temp->{gotoMap} ? $temp->{gotoMap} : {};
    bless($self,$class);
    if(@{$self->sections} == 0){
        $self->newObject([]);
    }
    return $self;
}
sub freeze{
    my $self = shift;
    my %temp;
    $temp{sections} = $self->{sections};
    $temp{survey} = $self->{survey};
    $temp{gotoMap} = $self->{gotoMap};
    return encode_json(\%temp);
}
sub newObject{
    my $self = shift;
    my $address = shift;
    if(@$address == 0){
        push(@{$self->sections}, $self->newSection());
        return [$#{$self->sections}];
    }elsif(@$address == 1){
        push( @{$self->questions($address)}, $self->newQuestion($address));
        $$address[1] = $#{$self->questions($address)};
        return $address;
    }elsif(@$address == 2){
        push(@{$self->answers($address)}, $self->newAnswer($address));
        $$address[2] = $#{$self->answers($$address)};
        return $address;
    }
}

#address is the array of objects currently selected in the edit screen
#data is the array of hash items for displaying  
sub getDragDropList{
    my $self = shift;
    my $address = shift;
    my @data;
$self->log("dd'ing sections".$#{$self->sections});
eval{
    for(my $i = 0; $i <= $#{$self->sections}; $i++){
        push(@data,{text=>$self->section([$i])->{title}, type=>'section'});
        if($address->[0] == $i){

            for(my $x = 0; $x <= $#{$self->questions($address)}; $x++){
$self->log("dd'ing questions".$#{$self->questions});
                push(@data,{text=>$self->question([$i,$x])->{text}, type=>'question'});
                if($address->[1] == $x){
                    for(my $y = 0; $y <= $#{$self->answers($address)}; $y++){
$self->log("dd'ing answers".$#{$self->answers});
                        push(@data,{text=>$self->answer([$i,$x,$y])->{text}, type=>'answer'});
                    }
                }
            }
        }
    }
};
$self->log($@);
$self->log('finished dding');
    return \@data;
}

sub getObject{
    my ($self,$address) = @_;
    if(@$address == 1){
        return $self->{sections}->[$address->[0]];
    }elsif(@$address == 2){
        return $self->{sections}->[$address->[0]]->{questions}->[$address->[1]];
    }else{
        return $self->{sections}->[$address->[0]]->{questions}->[$address->[1]]->{answers}->[$address->[2]];
    }
}

sub getEditVars{
    my ($self,$address) = @_;
    
    if(@$address == 1){
        return $self->getSectionEditVars($address);
    }elsif(@$address == 2){
        return $self->getQuestionEditVars($address);
    }elsif(@$address == 3){
        return $self->getAnswerEditVars($address);
    }
}
sub getSectionEditVars{
    my $self = shift;
    my $address = shift;
    my $object = $self->section($address);
    my %var = %{$object};
    $var{id} = $address->[0];
    $var{displayed_id} = $address->[0]+1;
    delete $var{questions};
    delete $var{questionsPerPage};
    for(1 .. 10){
#        if($_ == $self->section($address)->{questionsPerPage}){
        if($_ == $object->{questionsPerPage}){
            push(@{$var{questionsPerPage}},{'index',$_,'selected',1});
        }else{
            push(@{$var{questionsPerPage}},{'index',$_,'selected',0});
        }
    }
    return \%var;
}
sub getQuestionEditVars{
    my $self = shift;
    my $address = shift;
    my $object = $self->question($address);
    my %var = %{$object};
    $var{id} = $address->[0]."-".$address->[1];
    $var{displayed_id} = $address->[1]+1;
    delete $var{answers};
    delete $var{questionType};
    my @types = ('Agree/Disagree','Certainty','Concern','Confidence','Currency','Date','Date Range','Dual Slider - Range','Education','Effectiveness',
            'Email','File Upload','Gender','Hidden','Ideology','Importance','Likelihood','Multi Slider - Allocate','Multiple Choice','Oppose/Support',
            'Party','Phone Number','Race','Risk','Satisfaction','Scale','Security','Slider','Text','Text Date','Threat','True/False','Yes/No');
    for(@types){
        if($_ eq $object->{questionType}){
            push(@{$var{questionType}},{'text',$_,'selected',1});
        }else{ 
            push(@{$var{questionType}},{'text',$_,'selected',0});
        }
    }
    return \%var;
}
sub getAnswerEditVars{
}

sub update{
    my ($self,$address,$ref) = @_;
    my $object;
    if(@$address == 1){
        $object = $self->section($address);
        if(! defined $object){
            $object = $self->newSection();
            push(@{$self->sections},$object);
        }
    }elsif(@$address == 2){
        $object = $self->question($address);
        if(! defined $object){
$self->log("$object didn't exist");
            $object = $self->newQuestion();
            push(@{$self->questions($address)},$object);
        }
    }elsif(@$address == 3){
    }
    for my $key(keys %$object){
        $object->{$key} = $ref->{$key} if(defined $$ref{$key});
    }
}
#determine what to add and add it.
# ref should contain all the information for the new
sub insertObject{
    my ($self,$object,$address) = @_;

    if(@$address == 1){
        splice(@{$self->sections($address)},$$address[0] + 1, 0, $object);
    }elsif(@$address == 2) 
        splice(@{$self->questions($address)},$$address[1] + 1, 0, $object);
    }elsif(@$address == 3) 
        splice(@{$self->answers($address)},$$address[2] + 1, 0, $object);
    }

}
sub remove{
    my ($self,$address,$movingOverride) = @_;
    if(@$address == 1){
            splice(@{$self->{sections}},$$address[0],1) if($$address[0] != 0 and ! defined $movingOverride);#can't delete the first section
    }elsif(@$address == 2){
$self->log('removing here');
            splice(@{$self->questions($address)},$$address[1],1);

    }elsif(@$address == 3){
    }
}

sub newSection{
    my %members = (
                'text', '',
                'title', 'NEW SECTION',
                'variable', '', 
                'questionsPerPage', 5,
                'questionsOnSectionPage', 1,
                'randomizeQuestions', 0,
                'everyPageTitle', 1,
                'everyPageText', 1,
                'terminal', 0,
                'terminalUrl', '',
                'goto', '',
                'timeLimit', 0,
                'type','section'
            );
    $members{questions} = [];
    return \%members;
}
sub newQuestion{
    my %members = (
                'text', '',
                'variable','',
                'allowComment',0,
                'commentCols',10,
                'commentRows',5,
                'randomizeAnswers',0,
                'questionType','Multiple Choice',
                'randomWords','',
                'verticalDisplay',0,
                'required',0,
                'maxAnswers',1,
                'value',1,
                'textInButton',0,
                'terminal',0,
                'terminalUrl','',
                'type','question'
            );
    $members{answers} = [];
    return \%members;
}
sub newAnswer{
}



#------------------------------
#accessors and helpers
#------------------------------
sub sections{
    my $self = shift;
    return $self->{sections};
}
sub section{
    my $self = shift;
    my $address = shift;
    return $self->{sections}->[$$address[0]];
}
sub questions{
    my $self = shift;
    my $address = shift;
    return $self->{sections}->[$$address[0]]->{questions};
}
sub question{
    my $self = shift;
    my $address = shift;
    return $self->{sections}->[$$address[0]]->{questions}->[$$address[1]];
}
sub answers{
    my $self = shift;
    my $address = shift;
    return $self->{sections}->[$$address[0]]->{questions}->[$$address[1]]->{answers};
}
sub answer{
    my $self = shift;
    my $address = shift;
    return $self->{sections}->[$$address[0]]->{questions}->[$$address[1]]->{answers}->[$$address[2]];
}
sub log{
    my ($self,$message) = @_;
    if(defined $self->{log}){
        $self->{log}->error($message);
    }
}
1;
