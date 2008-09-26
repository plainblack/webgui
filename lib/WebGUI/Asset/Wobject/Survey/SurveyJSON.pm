package WebGUI::Asset::Wobject::Survey::SurveyJSON;

use strict;
use Data::Structure::Util qw/unbless/;
use WebGUI::Asset::Wobject::Survey::SectionJSON;
use Data::Dumper;

sub new{
    my $class = shift;
    my $self = shift || {};
    my $log = shift;
    if(defined $self->{sections}){
        foreach(@{$self->{sections}}){
            $_ = WebGUI::Asset::Wobject::Survey::SectionJSON->new($_,undef,$log);
        }
    }else{
        $self->{sections} = [];
    }
    $self->{log} = $log;
    bless($self,$class);
    return $self;
}
sub log{
    my ($self,$message) = @_;
    if(defined $self->{log}){
        $self->{log}->error($message);
    }
}
#address is the array of objects currently selected in the edit screen
#data is the array of hash items for displaying  
sub getDragDropList{
    my $self = shift;
    my $address = shift;
    my $data = shift;
    $self->{log} = shift;
    for(my $i=0; $i<=$#{$self->{sections}}; $i++){
        $self->{sections}->[$i]->getDragDropList($data, $address, $i == $address->[0]);
    }
}

sub getObject{
    my ($self,$address) = @_;
    if(@$address == 1){
        return $self->{sections}->[$address->[0]];
    }else{
        return $self->{sections}->[$address->[0]]->getObject($address);
    }
}

sub getEditVars{
    my ($self,$address) = @_;
$self->{log}->error("SurveyJSON geteditvars for: ".@$address);
    return $self->{sections}->[$address->[0]]->getEditVars($address);
}

sub update{
    my ($self,$address,$ref,$log) = @_;
    if(ref $address eq 'ARRAY' and $$address[0] ne 'NEW'){
$log->error('Address an array and sectionid not equal to NEW') if(defined $log);
        $self->{sections}->[$$ref{ids}->[0]]->update($address,$ref,$log);
    }else{
$log->error('Either address not an array or sectionid  equal to NEW') if(defined $log);
        push(@{$self->{sections}}, WebGUI::Asset::Wobject::Survey::SectionJSON->new({},$ref));
    }
}
#determine what to add and add it.
# ref should contain all the information for the new

sub remove{
    my ($self,$address) = @_;
    if(@$address == 1){
            splice(@{$self->{sections}},$$address[0],1) if($$address[0] != 0);#can't delete the first section
    }else{
        $self->{sections}->[$address->[0]]->remove($address);
    }
}

sub createTemp{
    my ($self,$ref) = @_;#ref{ids} contains the parent of the temp object which should be created and returned.

    if(ref $$ref{ids} eq 'ARRAY'){
        return $self->{sections}->[$$ref{ids}->[0]]->createTemp($ref);
    }else{
        return  WebGUI::Asset::Wobject::Survey::SectionJSON->new($self);
    }
}
sub freeze{
    my ($self) = @_;
    my %temp = %{$self};
    $temp{sections} = [];
    foreach (@{$self->{sections}}){
        push(@{$temp{sections}},$_->freeze());
    }
    delete $temp{log};
    return \%temp;
}
1;
