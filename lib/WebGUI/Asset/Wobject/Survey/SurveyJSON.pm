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
            $_ = WebGUI::Asset::Wobject::Survey::SectionJSON->new($_);
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
        $self->log("Survey passing ".Dumper $data);#,$address,$i, $$address[0]");
        $self->{sections}->[$i]->getDragDropList($data, $address, $i == $address->[0]);
        $self->log("Survey passing ".Dumper $data);#,$address,$i, $$address[0]");
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

sub update{
    my ($self,$ref) = @_;
    if(ref $$ref{ids} eq 'ARRAY' and $$ref{ids}->[0] ne 'NEW'){
        $self->{sections}->[$$ref{ids}->[0]]->update($ref);
    }else{
        push(@{$self->{sections}}, WebGUI::Asset::Wobject::Survey::SectionJSON->new($ref->{object}));
    }
}
#determine what to add and add it.
# ref should contain all the information for the new

sub remove{
    my ($self,$ref) = @_;
    $self->{sections}->[$$ref{ids}->[0]]->remove($ref);
    if(@$$ref{ids} == 0){
        splice(@{$self->{sections}},$$ref->{ids}->[0],1);
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
    delete $temp{log};
    foreach (@{$self->{sections}}){
        push(@{$temp{sections}},$_->freeze());
    }
$self->{log}->error(Dumper %temp);
    return \%temp;
}
1;
