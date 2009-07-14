package WebGUI::Crypt;

use strict;
use Tie::IxHash;
use Class::InsideOut qw{ :std };
use WebGUI::Exception;
use WebGUI::Pluggable;
use English qw( -no_match_vars );

use Data::Dumper;

=head1 NAME

Package WebGUI::Crypt

=head1 DESCRIPTION

Package for interfacing with Crypt provider.

=head1 SYNOPSIS

 use WebGUI::Crypt;

 my $crypt = WebGUI::Crypt->new($session,$config);
 my $crypt2 = $session->crypt;
 my $ciphertext = $crypt->encrypt("Plain Text");
 my $plaintext = $crypt->decrypt($ciphertext);
 $crypt->disconnect;
 
=head1 METHODS

These methods are available from this package:

=cut

# InsideOut object properties
readonly session => my %session;    # WebGUI::Session object
private providers => my %providers;

#-------------------------------------------------------------------

=head2 new ( session, config )

Constructor.
=head3 session

A reference to the current session.

=head3 config

Crypt config

=cut

sub new {
    my ( $class, $session ) = @_;

    # Check arguments..
    if ( !defined $session || !$session->isa('WebGUI::Session') ) {
        WebGUI::Error::InvalidParam->throw(
            param => $session,
            error    => 'Need a session.'
        );
    }

    # Register Class::InsideOut object..
    my $self = register $class;

    # Initialise object properties..
    my $id = id $self;
    $session{$id} = $session;
    return $self;
}

#-------------------------------------------------------------------

=head2 _getProvider ( $args )

Returns the correct provider, creating the object if required

=cut

sub _getProvider{
    my ($self, $args) = @_;
    
    if ( ref $args ne 'HASH' ){
        WebGUI::Error::InvalidParam->throw(
            param => $args,
            error => 'getProvider requires a hash ref be passed in with a providerI or table/field combo.'
        );
    }
 
    my $providerId = exists $args->{providerId} ? $args->{providerId} : $self->lookupProviderId($args);

    return $providers{id $self}->{$providerId} if(exists $providers{id $self}->{$providerId});
    
    my $module;
    my $providerData;
    
    if($providerId eq 'None'){
        $module = "WebGUI::Crypt::None";
        $providerData = $session{id $self}->config->get("crypt")->{'None'};
        $providerData->{providerId} = $providerId;
    }   
    else{    
        $providerData = $session{id $self}->config->get("crypt")->{$providerId};
        $providerData->{providerId} = $providerId;
        if (!$providerData) {
            WebGUI::Error::InvalidParam->throw(
                param => $args,
                error => 'WebGUI::Crypt provider must be specified in config.'
            );
        }
        
        $module = $providerData->{provider};
    }

    # Try loading the Provider..
    eval {WebGUI::Pluggable::load($module)};
    if (Exception::Class->caught()) {
        WebGUI::Error::Pluggable::LoadFailed->throw(
            error  => $EVAL_ERROR,
            module => $module,
        );
    }

    # Instantiate the Provider..
    my $provider = eval { WebGUI::Pluggable::run( $module, 'new', [$session{id $self}, $providerData] ); };
    if (Exception::Class->caught()) {
        WebGUI::Error::Pluggable::RunFailed->throw(
            error      => $EVAL_ERROR,
            module     => $module,
            subroutine => 'new',
            params     => [$session{id $self}, $args],
        );
    }

    # Store the provider as a member for later resuse..
    $providers{id $self}->{$providerId} = $provider;
    
    return $provider,;
}

#-------------------------------------------------------------------

=head2 lookupProvider ( $args )

Takes a table and field and returns the correct providerId

=cut

sub lookupProviderId{
    my ($self, $args) = @_;

    if ( ! $args->{table} || ! $args->{field}) {
        WebGUI::Error::InvalidParam->throw(
            param => $args,
            error => 'lookupProviderId needs a table and field defined.'
        );
    }
    my $providerId = $self->session->db->quickScalar(
                "select providerId from cryptFieldProviders where `table` = ? and `field` = ?",
                [ $args->{table}, $args->{field} ] );
#Should this throw an error?  I don't think so, the return should just be sanity checked as a providerId may not exist yet.
#    if(! $providerId){
       # WebGUI::Error->throw(
       #     param => $args,
       #     error => "lookupProviderId could not find a providerID for table:$$args{table} and field:$$args{field} ."
       # );
#    }
    return $providerId;
}

#-------------------------------------------------------------------

=head2 noEnabled ( $plaintext, $args )

Returns true if globle encryption is not enabled

=cut 

sub notEnabled{
    my ($self) = @_;
    if($session{id $self}->setting->get('cryptEnabled')){
        return 0;
    }
    return 1;
}

#-------------------------------------------------------------------

=head2 encrypt ( $plaintext, $args )

Encrypt some plaintext

=head3 $plaintext

This is the string to be encrypted

=head3 $args

This is a hash ref which must contain a 'providerId' or a 'table' and 'field' in the providers table

=cut

sub encrypt {
    my ($self, $plaintext, $args) = @_;
    if ( ! defined $plaintext ) {
        WebGUI::Error::InvalidParam->throw(
            param => $plaintext,
            error => 'encrypt needs $plaintext defined.'
        );
    }
    if($self->notEnabled()){return;}
    $self->_getProvider($args)->encrypt($plaintext);
}



#-------------------------------------------------------------------

=head2 encrypt_hex ( $plaintext )

Encrypt some plaintext

=cut

sub encrypt_hex {
    my ($self, $plaintext, $args) = @_;
    if ( ! defined $plaintext ) {
        WebGUI::Error::InvalidParam->throw(
            param => $plaintext,
            error => 'encrypt_hex needs $plaintext defined.'
        );
    }
    if($self->notEnabled()){return;}
    $self->_getProvider($args)->encrypt_hex($plaintext);
}

#-------------------------------------------------------------------

=head2 decrypt ( $ciphertext )

Decrypt some ciphertext

=cut

sub decrypt {
    my ($self, $ciphertext) = @_;
    if ( ! defined $ciphertext ) {
        WebGUI::Error::InvalidParam->throw(
            param => $ciphertext,
            error => 'decrypt needs $ciphertext defined.'
        );
    }
    if($self->notEnabled()){return $ciphertext;}
    my ($providerId, $text) = $self->_parseHeader($ciphertext);
    return $self->_getProvider({providerId=>$providerId})->decrypt($text);
}

#-------------------------------------------------------------------

=head2 decrypt_hex ( $ciphertext )

Decrypt some ciphertext

=cut

sub decrypt_hex {
    my ($self, $ciphertext) = @_;
    if ( ! defined $ciphertext ) {
        WebGUI::Error::InvalidParam->throw(
            param => $ciphertext,
            error => 'decrypt_hex needs $ciphertext defined.'
        );
    }
    if($self->notEnabled()){return $ciphertext;}
    my ($providerId, $text) = $self->_parseHeader($ciphertext);
    return $self->_getProvider({providerId=>$providerId})->decrypt_hex($text);
}

#-------------------------------------------------------------------

=head2 _parseHeader ( $ciphertext )

Parse and return the header

=cut

sub _parseHeader{
    my ($self, $ciphertext) = @_;
    if($ciphertext =~ /CRYPT:(.*?):(.*)/){
        return ($1,$2);
    }else{
        return ('None',$ciphertext);        
    }
}

#-------------------------------------------------------------------

=head2 setProvider ( $arg_ref )

Allows client code to set providers for tables/fields

=head3 $arg_ref

This is a hash ref that must contain $table, $field, $key, $providerId

=cut

sub setProvider{
    my ($self, $arg_ref) = @_;
    if($self->notEnabled()){return 0;}
    
    if ( ref $arg_ref ne 'HASH' || ! $arg_ref->{table} || ! $arg_ref->{field} || ! $arg_ref->{key} || ! $arg_ref->{providerId}){
        WebGUI::Error::InvalidParam->throw(
            param => $arg_ref,
            error => 'setProvider requires a hash ref be passed in with $table, $field, $key, and $providerId.'
        );
    }
    my $providerId = $session{id $self}->db->quickScalar(
                "select providerId from cryptFieldProviders where `table` = ? and `field` = ?",
                [ $arg_ref->{table}, $arg_ref->{field} ] );
    if(!$providerId){
        $session{id $self}->db->write("insert into cryptFieldProviders values(?,?,?,?,?)",
            [$arg_ref->{table},$arg_ref->{field},$arg_ref->{key},$arg_ref->{providerId},"None,".$arg_ref->{providerId}]);
    }else{
        $session{id $self}->db->write("update cryptFieldProviders set providerId = ?, activeProviderIds = concat(activeProviderIds,',',?) where `table` = ? and `field` = ?",
            [$arg_ref->{providerId},$arg_ref->{providerId}, $arg_ref->{table}, $arg_ref->{field}]);
    }
    return 1;
}
1;

