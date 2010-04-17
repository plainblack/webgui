package WebGUI::Session::Form;

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
use Encode ();
use Tie::IxHash;
use base 'WebGUI::FormValidator';

=head1 NAME

Package WebGUI::Session::Form

=head1 DESCRIPTION

This is a subclass of WebGUI::FormValidator. It processes POST input.

=head1 SYNOPSIS

 use WebGUI::Session::Form;

 my $fp = WebGUI::Session::Form->new($session);

 $value = $fp->process("favoriteColor", "selectList", "black");

 $value = $fp->someFormControlType("fieldName");

 Example:

 $value = $fp->text("title");

=head1 METHODS

=cut


#-------------------------------------------------------------------

=head2 AUTOLOAD ( params )

This just passes control to WebGUI::FormValidator::AUTOLOAD.

=head3 params

Either an href of parameters or the fieldName in question.

=cut

sub AUTOLOAD {
	my $self = shift;
	my @args = @_;
	our $AUTOLOAD;
	my $method = "SUPER::".(split /::/, $AUTOLOAD)[-1];
	return if $method eq 'SUPER::DESTROY';
	return $self->$method(@args);
}

#-------------------------------------------------------------------

=head2 hasParam ( $param )

Returns true if the param is part of the submitted form data, or a URL param.

=cut

sub hasParam {
	my $self = shift;
    my $param = shift;
    return undef unless $param;
    return undef unless $self->session->request;
    my $hashRef = $self->session->request->param();
    return exists $hashRef->{$param};
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

=head2 param ( [ field ] )

Returns all the fields from a form post as an array.

=head3 field

The name of the field to retrieve if you want to retrieve just one specific field.

=cut

sub param {
	my $self = shift;
    return undef unless $self->session->request;
	my $field = shift;
	if ($field) {
        my @data = $self->session->request->param($field);
        foreach my $value (@data) {
            $value = Encode::decode_utf8($value);
        }
        return wantarray ? @data : $data[0];
	}
    else {
        my $paramRef = $self->session->request->param;
        return keys %{ $paramRef };
	}
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

	return $self->param($name) if ($type eq "");
	$type = ucfirst($type);

	return $self->SUPER::process({
		name	=>	$name,
		type	=>	$type,
		default	=>	$default,
		params	=>	$params,
	});
}

#-------------------------------------------------------------------

=head2 validToken ( )

Checks that the current form has a method=POST, and that it has a CSRF token matching
the one in this user's current session.

=cut

sub validToken {
	my ($self)  = @_;
    my $session = $self->session;
    $session->log->debug('HTTP method: '. $session->request->method);
    $session->log->debug('CSRF token: '. $session->scratch->get('webguiCsrfToken'));
    return 0 unless $session->request->method eq 'POST';
    return 0 unless $self->param('webguiCsrfToken') eq $session->scratch->get('webguiCsrfToken');
    return 1;
}

1;

