package WebGUI::Session::Scratch;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use WebGUI::International;

=head1 NAME

Package WebGUI::Session::Scratch

=head1 DESCRIPTION

This package allows you to attach arbitrary data to the session that lasts until the session dies.

=head1 SYNOPSIS

$scratch = WebGUI::Session::Scratch->new($session);

$scratch->delete('temp');
$scratch->set('temp',$value);
$value = $scratch->get('temp');

$scratch->deleteAll;
$scratch->deleteName('temp');


=head1 METHODS

These methods are available from this package:

=cut



#-------------------------------------------------------------------

=head2 delete ( name )

Deletes a scratch variable. Returns the value of the deleted variable for 
convenience, or undef if the variable was not defined.

=head3 name

The name of the scratch variable.

=cut

sub delete {
	my $self = shift;
	my $name = shift;
	return undef unless ($name);
	my $value = delete $self->{_data}{$name};
    my $session = $self->session;
    my $id = $session->getId;
    $session->cache->set("sessionscratch_".$id, $self->{_data}, $session->setting->get('sessionTimeout'));
	$session->db->write("delete from userSessionScratch where name=? and sessionId=?", [$name, $id]);
	return $value;
}


#-------------------------------------------------------------------

=head2 deleteAll ( )

Deletes all scratch variables for this session.

=cut

sub deleteAll {
	my $self = shift;
	delete $self->{_data};
    my $session = $self->session;
    my $id = $session->getId;
    $session->cache->remove("sessionscratch_".$id);
	$session->db->write("delete from userSessionScratch where sessionId=?", [$id]);
}


#-------------------------------------------------------------------

=head2 deleteName ( name )

Deletes a scratch variable for all users. This function must be used with care.

=head3 name

The name of the scratch variable.

=cut

sub deleteName {
	my $self = shift;
	my $name = shift;
	return undef unless ($name);	
	delete $self->{_data}{$name};
    my $session = $self->session;
    $session->cache->flush;
	$session->db->write("delete from userSessionScratch where name=?", [$name]);
}

#-------------------------------------------------------------------

=head2 deleteNameByValue ( name, value )

Deletes a scratch variable for all users where a particular name equals a particular value. This function must be used with care.

=head3 name

The name of the scratch variable.

=head3 value

The value to match.  This can be anything except for undef.

=cut

sub deleteNameByValue {
	my $self = shift;
	my $name = shift;
	my $value = shift;
	return undef unless ($name and defined $value);
	delete $self->{_data}{$name} if ($self->{_data}{$name} eq $value);
    my $session = $self->session;
    $session->cache->flush;
	$session->db->write("delete from userSessionScratch where name=? and value=?", [$name,$value]);
}


#-------------------------------------------------------------------

=head2 DESTROY ( )

Deconstructor.

=cut

sub DESTROY {
        my $self = shift;
        undef $self;
}


#-------------------------------------------------------------------

=head2 get( varName ) 

Retrieves the current value of a scratch variable.

=head3 varName

The name of the variable.

=cut

sub get {
    my ($self, $var) = @_;
	return $self->{_data}{$var};
}

#-------------------------------------------------------------------

=head2 getLanguageOverride ()

Retrieves the language of the session scratch

=cut

sub getLanguageOverride {
	my $self = shift;
	my $languageOverride = $self->session->scratch->get('language');
	return $languageOverride;
}

#-------------------------------------------------------------------

=head2 new ( session )

Constructor. Returns a scratch object.

=head3 session

The current session.

=cut

sub new {
    my ($class, $session) = @_;
    my $scratch = $session->cache->get("sessionscratch_".$session->getId);
    unless (ref $scratch eq "HASH") {
	    $scratch = $session->db->buildHashRef("select name,value from userSessionScratch where sessionId=?",[$session->getId], {noOrder => 1});
    }
	bless {_session=>$session, _data=>$scratch}, $class;
}

#-------------------------------------------------------------------

=head2 removeLanguageOverride()

Removes the language scratch variable from the session

=cut

sub removeLanguageOverride {
	my $self = shift;
	$self->session->scratch->delete('language');
}
#-------------------------------------------------------------------

=head2 session ( )

Returns a reference to the WebGUI::Session object.

=cut

sub session {
	my $self = shift;
	return $self->{_session};
}


#-------------------------------------------------------------------

=head2 set ( name, value )

Sets a scratch variable for this user session. 

=head3 name

The name of the scratch variable.

=head3 value

The value of the scratch variable.  Must be a string no longer than 16000 characters.

=cut

sub set {
    my ($self, $name, $value) = @_;
	return undef unless ($name);
	$self->{_data}{$name} = $value;
    my $session = $self->session;
    my $id = $session->getId;
    $session->cache->set("sessionscratch_".$id, $self->{_data}, $session->setting->get('sessionTimeout'));
	$session->db->write("replace into userSessionScratch (sessionId, name, value) values (?,?,?)", [$id, $name, $value]);
}

#----------------------------------------------------------------------

=head2 setLanguageOverride ( language )

Sets a scratch variable language in the session if the language is installed

=head3 language

The language that should be set into the session

=cut

sub setLanguageOverride {
	my $self = shift;
	my $language = shift;
        my $i18n = WebGUI::International->new($self->session);
        if($i18n->getLanguages()->{$language}) {
                $self->session->scratch->set("language",$language);
                return undef;
        }
        else {
                $self->session->log->error("Language $language is not installed in this site");
                return undef;
	}
}

1;
