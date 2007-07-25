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

=head2 AUTOLOAD ( )

Dynamically creates functions on the fly for all the different form control types.

=cut

sub AUTOLOAD {
        our $AUTOLOAD;
	my $self = shift;
        my $name = ucfirst((split /::/, $AUTOLOAD)[-1]);
	my $params = shift;
	$params = {name=>$params} if ref ($params) ne "HASH";
        my $cmd = "use WebGUI::Form::".$name;
        eval ($cmd);
        if ($@) {
                $self->session->errorHandler->error("Couldn't compile form control: ".$name.". Root cause: ".$@);
                return undef;
        }
        my $class = "WebGUI::Form::".$name;
        return $class->new($self->session, $params)->getValueFromPost;
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

=head2 get ( )

An alias for process()

=cut

sub get {
	my $self = shift;
	return $self->process(@_);
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

=head2 param ( [ field ] )

Returns all the fields from a form post as an array.

=head3 field

The name of the field to retrieve if you want to retrieve just one specific field.

=cut

sub param {
	my $self = shift;
	my $field = shift;
	if ($field) {
		if ($self->session->request) {
			my @data = $self->session->request->body($field);
			return wantarray ? @data : $data[0] if (scalar(@data));
			@data = $self->session->request->param($field);
			return wantarray ? @data : $data[0];
		} else {
			return undef;
		}
	} else {
		if ($self->session->request) {
			my %params = ();
			foreach ($self->session->request->param) {
				$params{$_} = 1;
			}
			foreach ($self->session->request->body) {
				$params{$_} = 1; 
			}
			return keys %params;
		} else {
			return undef;
		}
	}
}

#-------------------------------------------------------------------

=head2 paramsHashRef (  )

Gets a hash ref of all the params passed in to this class, and their values. This should not be confused with the param() method.

=cut

sub paramsHashRef {
	my $self = shift;
	unless ($self->{_paramsHashRef}) {
		my %hash;
		tie %hash, "Tie::IxHash";
		foreach ($self->param) {
			my @arr = $self->process($_);
			$hash{$_} = (scalar(@arr) > 1)?\@arr:$arr[0];
		}
		$self->{_paramsHashRef} = \%hash;
	}
	return $self->{_paramsHashRef};
}


#-------------------------------------------------------------------

=head2 process ( name, type [ , default, params ] )

Returns whatever would be the expected result of the method type that was specified. This method also checks to make sure that the field is not returning a string filled with nothing but whitespace.

=head3 name

The name of the form variable to retrieve.

=head3 type

The type of form element this variable came from. Defaults to "text" if not specified.

=head3 default

The default value for this variable. If the variable is undefined then the default value will be returned instead.

=head3 params

A full set of form params just as you'd pass into any of the form controls when building it.

=cut

sub process {
	my ($self, $name, $type, $default, $params) = @_;
	$type = ucfirst($type);
	return $self->param($name) if ($type eq "");
	$params->{name} = $name;	
	if (wantarray) {	
		my @values = $self->$type($params);
		if (scalar(@values) < 1 && ref $default eq "ARRAY") {
			return @{$default};
		} else {
			return @values;
		}
	} else {
		my $value = $self->$type($params);
		unless (defined $value) {
			return $default;
		}
		if ($value =~ /^[\s]+$/) {
			return undef;
		}
		return $value;
	}
}

#-------------------------------------------------------------------

=head2 session ( )

Returns a reference to the current session.

=cut

sub session {
	my $self = shift;
	return $self->{_session};
}

1;

