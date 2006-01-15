package WebGUI::Session::Form;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict qw(vars subs);
use WebGUI::HTML;

=head1 NAME

Package WebGUI::Session::Form

=head1 DESCRIPTION

This is a convenience package to the individual form controls. It allows you to get the form post results back without having to load each form control seperately, instantiate an object, and call methods.

=head1 SYNOPSIS

 use WebGUI::Session::Form;

 my $fp = WebGUI::Session::Form->new($session);

 $value = $fp->process("favoriteColor", "selectList", "black");

 $value = $fp->someFormControlType("fieldName");

 Example:

 $value = $fp->text("title");

=head1 METHODS

These functions are available from this package:

=cut


#-------------------------------------------------------------------

=head2 AUTOLOAD ()

Dynamically creates functions on the fly for all the different form control types.

=cut

sub AUTOLOAD {
        our $AUTOLOAD;
	my $self = shift;
        my $name = ucfirst((split /::/, $AUTOLOAD)[-1]);
	my $fieldName = shift;
        my $cmd = "use WebGUI::Form::".$name;
        eval ($cmd);
        if ($@) {
                $self->session->errorHandler->error("Couldn't compile form control: ".$name.". Root cause: ".$@);
                return undef;
        }
        my $class = "WebGUI::Form::".$name;
        return $class->new($self->session, {name=>$fieldName})->getValueFromPost;
}

#-------------------------------------------------------------------

=head DESTROY ( )

Deconstructor.

=cut

sub DESTROY {
        my $self = shift;
        undef $self;
}



#-------------------------------------------------------------------

=head2 new ( session )

Constructor.

=head3 session

A reference to the current session.

=cut

sub new {
	my $class = shift;
	my $session = shift;
	bless {_session=>$session}, $class;
}


#-------------------------------------------------------------------

=head2 paramsHashRef (  )

Gets a hash ref of all the params passed in, and their values.

=cut

sub paramsHashRef {
	my $self = shift;
	unless ($self->{_paramsHashRef}) {
		my $hash;
		foreach ($self->session->request->params) {
			$hash->{$_} = $self->process($_);
		}
		$self->{_paramsHashRef} = $hash;
	}
	return $self->{_paramsHashRef};
}


#-------------------------------------------------------------------

=head2 process ( name, type [ , default ] )

Returns whatever would be the expected result of the method type that was specified. This method also checks to make sure that the field is not returning a string filled with nothing but whitespace.

=head3 name

The name of the form variable to retrieve.

=head3 type

The type of form element this variable came from. Defaults to "text" if not specified.

=head3 default

The default value for this variable. If the variable is undefined then the default value will be returned instead.

=cut

sub process {
	my ($self, $name, $type, $default) = @_;
	my $value;
	$type = ucfirst($type);
	$type = "Text" if ($type eq "");
	$value = $self->$type($self->session,$name);
	unless (defined $value) {
		return $default;
	}
	if ($value =~ /^[\s]+$/) {
		return undef;
	}
	return $value;
}

#-------------------------------------------------------------------

=head2 session

=cut

sub session {
	my $self = shift;
	return $self->{_session};
}

1;

