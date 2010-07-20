package WebGUI::FormValidator;

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

use strict qw(vars subs);
use WebGUI::HTML;
use WebGUI::Pluggable;
use Scalar::Util qw( weaken );

=head1 NAME

Package WebGUI::FormValidator

=head1 DESCRIPTION

This is a convenience package to the individual form controls. It allows you to get the form post results back without having to load each form control seperately, instantiate an object, and call methods.

=head1 SYNOPSIS

 use WebGUI::FormValidator;

 my $fp = WebGUI::FormValidator->new($session);

 $value = $fp->process("favoriteColor", "selectList", "black");

 $value = $fp->someFormControlType("fieldName");

 Example:

 $value = $fp->text("title");

=head1 METHODS

These functions are available from this package:

=cut


#-------------------------------------------------------------------

=head2 AUTOLOAD ( params [, value ] )

Dynamically creates functions on the fly for all the different form control types. Returns their interpretation of a POST input field.

=head3 params

Either an href of parameters or the fieldName in question.

=head3 value

Optional. If present, then this value will be used instead of POST input (which is the default). May be a list of values, depending on the field type.

=cut

sub AUTOLOAD {
	our $AUTOLOAD;
	my $self	= shift;
	my $params	= shift;
	my @args	= @_;

    return if $AUTOLOAD =~ m/::DESTROY$/;
	my $name = ucfirst((split /::/, $AUTOLOAD)[-1]);
	$params = {name=>$params} if ref ($params) ne "HASH";
    my $control = eval { WebGUI::Pluggable::instanciate("WebGUI::Form::".$name, "new", [ $self->session, $params ]) };
    if ($@) {
        $self->session->errorHandler->error($@);
        return undef;
    }
	return $control->getValue(@args);
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
	my $self = bless {_session=>$session}, $class;
        weaken( $self->{_session} );
        return $self;
}


#-------------------------------------------------------------------

=head2 process ( paramsHref )

Returns whatever would be the expected result of the method type that was specified. This method also checks to make sure that the field is not returning a string filled with nothing but whitespace.

=head3 paramsHref

Required. An href of the following params...

=head4 name

The name of the form variable to retrieve.

=head4 type

The type of form element this variable came from. Defaults to "text" if not specified.

=head4 default

The default value for this variable. If the variable is undefined then the default value will be returned instead.

=head4 params

A full set of form params just as you'd pass into any of the form controls when building it.

=cut

sub process {
	my $self = shift;
	my $args = shift || '';

	die __PACKAGE__."::process requires a hash ref" unless ref $args eq 'HASH';

	my ($name, $type, $default, $params) = @$args{qw( name type default params )};
	$params->{name} = $name;
    $params->{defaultValue} = $default
        unless defined $params->{defaultValue};
	if (wantarray) {
		my @values = $self->$type($params);
        return @values;
	} else {
		my $value = $self->$type($params);
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

