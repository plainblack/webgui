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
        $$address[2] = $#{$self->answers($address)};
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
#$self->log("dd'ing questions".$#{$self->questions});
                push(@data,{text=>$self->question([$i,$x])->{text}, type=>'question'});
                if($address->[1] == $x){
                    for(my $y = 0; $y <= $#{$self->answers($address)}; $y++){
#$self->log("dd'ing answers".$#{$self->answers});
                        push(@data,{text=>$self->answer([$i,$x,$y])->{text}, type=>'answer'});
                    }
                }
            }
        }
    }
};
$self->log($@);
#$self->log('finished dding');
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
    for(1 .. 20){
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
    my $self = shift;
    my $address = shift;
    my $object = $self->answer($address);
    my %var = %{$object};
    $var{id} = $address->[0]."-".$address->[1]."-".$address->[2];
    $var{displayed_id} = $address->[2]+1;
    return \%var;
}

sub update{
    my ($self,$address,$ref) = @_;
    my $object;
    my $newQuestion = 0;
    if(@$address == 1){
        $object = $self->section($address);
        if(! defined $object){
            $object = $self->newSection();
            push(@{$self->sections},$object);
        }
    }elsif(@$address == 2){
        $object = $self->question($address);
        if(! defined $object){
            my $newQuestion = 1;
            $object = $self->newQuestion();
            push(@{$self->questions($address)},$object);
        }
    }elsif(@$address == 3){
        $object = $self->answer($address);
        if(! defined $object){
            $object = $self->newAnswer();
            push(@{$self->answers($address)},$object);
        }
    }
    if(@$address == 2 and ! $newQuestion){
        if($ref->{questionType} ne $self->question($address)->{questionType}){
            $self->updateQuestionAnswers($address,$ref->{questionType});
        }
    }
    for my $key(keys %$object){
        $object->{$key} = $ref->{$key} if(defined $$ref{$key});
    }
}


#determine what to add and add it.
# ref should contain all the information for the new
sub insertObject{
    my ($self,$object,$address) = @_;
$self->log("Inserting ".join(',',@$address));
    if(@$address == 1){
        splice(@{$self->sections($address)},$$address[0] + 1, 0, $object);
    }elsif(@$address == 2){ 
        splice(@{$self->questions($address)},$$address[1] + 1, 0, $object);
    }elsif(@$address == 3){ 
        splice(@{$self->answers($address)},$$address[2] + 1, 0, $object);
    }
$self->log("Finished inserting ");

}

sub copy{
    my ($self,$address) = @_;
    if(@$address == 1){
            my %newSection = %{$self->section($address)};
            push(@{$self->sections}, \%newSection);
            return [$#{$self->sections}];
$self->log("copying here $$address[0] :".$#{$self->sections});
    }elsif(@$address == 2){
$self->log("copying question $$address[0] $$address[1]");
            my %newQuestion = %{$self->question($address)};
            push( @{$self->questions($address)}, \%newQuestion);
            $$address[1] = $#{$self->questions($address)};
$self->log("to $$address[0] $$address[1]");
            return $address;
    }
}


sub remove{
    my ($self,$address,$movingOverride) = @_;
    if(@$address == 1){
$self->log("removing here $$address[0] :".$#{$self->sections}) if($$address[0] != 0 or defined $movingOverride);;
            splice(@{$self->{sections}},$$address[0],1) if($$address[0] != 0 or defined $movingOverride);#can't delete the first section
$self->log("removing here $$address[0] :".$#{$self->sections});
    }elsif(@$address == 2){
$self->log("removing here $$address[0] $$address[1]");
            splice(@{$self->questions($address)},$$address[1],1);
    }elsif(@$address == 3){
$self->log("removing here $$address[0] $$address[1] $$address[2]");
            splice(@{$self->answers($address)},$$address[2],1);
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
    my %members = (
                'text', '',
                'verbatim',0,
                'textCols',10,
                'textRows',5,
                'goto','',
                'recordedAnswer','',
                'isCorrect',1,
                'min',1,
                'max',10,
                'step',1,
                'value',1,
                'terminal',0,
                'terminalUrl','',
                'type','answer'
            );
    return \%members;
}

sub updateQuestionAnswers{
    my $self = shift;
    my $address = shift;
    my $type = shift;

$self->log("In updateQuestion");

    my @addy = @{$address};
    my $question = $self->question($address);
    $question->{answers} = [];

    if($type eq 'Date Range' or $type eq  'Multi Slider - Allocate' or $type eq 'Dual Slider - Range'){
        push(@{$question->{answers}},$self->newAnswer()); 
        push(@{$question->{answers}},$self->newAnswer()); 
    }elsif($type eq 'Currency'){
        push(@{$question->{answers}},$self->newAnswer()); 
        $addy[2] = 0;
        $self->update(\@addy,{'text','Currency Amount'});
    }elsif($type eq 'Text Date'){
        push(@{$question->{answers}},$self->newAnswer()); 
        $addy[2] = 0;
        $self->update(\@addy,{'text','Date:'});
    }elsif($type eq 'Phone Number'){
        push(@{$question->{answers}},$self->newAnswer()); 
        $addy[2] = 0;
        $self->update(\@addy,{'text','Phone Number:'});
    }elsif($type eq 'Email'){
        push(@{$question->{answers}},$self->newAnswer()); 
        $addy[2] = 0;
        $self->update(\@addy,{'text','Email:'});
    }elsif($type eq 'Education'){
        my @ans = ('Elementary or some high school','High school/GED','Some college/vocational school','College graduate',
                    'Some graduate work','Master\'s degree','Doctorate (of any type)','Other degree (verbatim)');
        $self->addAnswersToQuestion(\@addy,\@ans,{7,1});
    }elsif($type eq 'Party'){
        my @ans = ('Democratic party','Republican party (or GOP)','Independant party','Other party (verbatim)');
        $self->addAnswersToQuestion(\@addy,\@ans,{3,1});
    }elsif($type eq 'Race'){
        my @ans = ('American Indian','Asian','Black','Hispanic','White non-Hispanic','Something else (verbatim)');
        $self->addAnswersToQuestion(\@addy,\@ans,{5,1});
    }elsif($type eq 'Ideology'){
        my @ans = ('Strongly liberal','Liberal','Somewhat liberal','Middle of the road','Slightly conservative','Conservative','Strongly conservative');
        $self->addAnswersToQuestion(\@addy,\@ans,{});
    }elsif($type eq 'Security'){
        my @ans = ('Not at all secure','','','','','','','','','','Extremely secure');
        $self->addAnswersToQuestion(\@addy,\@ans,{});
    }elsif($type eq 'Threat'){
        my @ans = ('No threat','','','','','','','','','','Extreme threat');
        $self->addAnswersToQuestion(\@addy,\@ans,{});
    }elsif($type eq 'Risk'){
        my @ans = ('No risk','','','','','','','','','','Extreme risk');
        $self->addAnswersToQuestion(\@addy,\@ans,{});
    }elsif($type eq 'Concern'){
        my @ans = ('Not at all concerned','','','','','','','','','','Extremely concerned');
        $self->addAnswersToQuestion(\@addy,\@ans,{});
    }elsif($type eq 'Effectiveness'){
        my @ans = ('Not at all effective','','','','','','','','','','Extremely effective');
        $self->addAnswersToQuestion(\@addy,\@ans,{});
    }elsif($type eq 'Confidence'){
        my @ans = ('Not at all confident','','','','','','','','','','Extremely confident');
        $self->addAnswersToQuestion(\@addy,\@ans,{});
    }elsif($type eq 'Satisfaction'){
        my @ans = ('Not at all satisfied','','','','','','','','','','Extremely satisfied');
        $self->addAnswersToQuestion(\@addy,\@ans,{});
    }elsif($type eq 'Certainty'){
        my @ans = ('Not at all certain','','','','','','','','','','Extremely certain');
        $self->addAnswersToQuestion(\@addy,\@ans,{});
    }elsif($type eq 'Likelihood'){
        my @ans = ('Not at all likely','','','','','','','','','','Extremely likely');
        $self->addAnswersToQuestion(\@addy,\@ans,{});
    }elsif($type eq 'Importance'){
        my @ans = ('Not at all important','','','','','','','','','','Extremely important');
        $self->addAnswersToQuestion(\@addy,\@ans,{});
    }elsif($type eq 'Oppose/Support'){
        my @ans = ('Strongly oppose','','','','','','Strongly Support');
        $self->addAnswersToQuestion(\@addy,\@ans,{});
    }elsif($type eq 'Agree/Disagree'){
        my @ans = ('Strongly disagree','','','','','','Strongly agree');
        $self->addAnswersToQuestion(\@addy,\@ans,{});
    }elsif($type eq 'True/False'){
        my @ans = ('True','False');
        $self->addAnswersToQuestion(\@addy,\@ans,{});
    }elsif($type eq 'Yes/No'){
        my @ans = ('Yes','No');
        $self->addAnswersToQuestion(\@addy,\@ans,{});
    }elsif($type eq 'Gender'){
        my @ans = ('Male','Female');
        $self->addAnswersToQuestion(\@addy,\@ans,{});
    }else{
        push(@{$question->{answers}},$self->newAnswer()); 
    }
}
sub addAnswersToQuestion{
    my $self = shift;
    my $addy = shift;
    my $ans = shift;
    my $verbs = shift;
$self->log(Dumper $verbs);
    for(0 .. $#$ans){
        push(@{$self->question($addy)->{answers}},$self->newAnswer()); 
        $$addy[2] = $_;
$self->log("$_:".defined $$verbs{$_}." ".$$verbs{$_});
        if(defined $$verbs{$_} and $_ == $$verbs{$_}){
            $self->update($addy,{'text',$$ans[$_],'recordedAnswer',$_+1,'verbatim',1});
        }else{
            $self->update($addy,{'text',$$ans[$_],'recordedAnswer',$_+1});
        }
    }
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
