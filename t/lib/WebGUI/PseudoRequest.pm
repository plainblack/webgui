package WebGUI::PseudoRequest;

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

use Test::MockObject;

BEGIN {
    if( do { no strict 'refs'; ! exists ${"Apache2::"}{"Cookie::"} } ) {
        Test::MockObject->fake_module(
            'Apache2::Cookie',
            new => sub {
                my $class = shift;
                my $self = Test::MockObject->new;
                $self->set_isa($class);
                $self->set_true(qw(expires domain bake));
            },
        );
    }

    if( do { no strict 'refs'; ! exists ${"APR::"}{"Request::"} } ) {
        Test::MockObject->fake_module('APR::Request::Apache2',
            handle => sub {
                return $_[1];
            },
        );
    }
}

use WebGUI::PseudoRequest::Headers;
use WebGUI::PseudoRequest::Upload;

=head1 NAME

Package WebGUI::PseudoRequest

=head1 DESCRIPTION

This is an almost complete imitation of Apache2::Request.  You can use this package to
create a request object that will work with WebGUI, without actually being inside
the mod_perl environment.

Why in the world would you want to do this?  Well, when doing API testing sometimes
you run across things that require a request object, but you don't really want to
fire up Apache in order to do it.  This will let you bypass that.

=head2 new

Construct a new PseudoRequest object.  Creates a new Headers object as well and places
it inside the PseudoRequest object.

=cut

sub new {
	my $this = shift;
	my $class = ref($this) || $this;
	my $headers = WebGUI::PseudoRequest::Headers->new();
	my $self = { headers_out => $headers, headers_in => {} };
	bless $self, $class;
	return $self;
}

#----------------------------------------------------------------------------

=head2 body ( [$value])

Compatibility method.  Returns the requested form value, $value.  If $value isn't passed in, returns
all form variables.

=cut


sub body {
	my $self = shift;
	my $value = shift;
    if ( !defined $value ) {
        return if !$self->{body};
        return keys %{ $self->{body} } if wantarray;
        return { %{ $self->{body} } };
    }
	if (defined $self->{body}->{$value}) {
        if (wantarray && ref $self->{body}->{$value} eq "ARRAY") {
            return @{$self->{body}->{$value}};
        }
        elsif (ref $self->{body}->{$value} eq "ARRAY") {
            return $self->{body}->{$value}->[0];
        }
        else {
            return $self->{body}->{$value};
        }
    }
    else {
        if (wantarray) {
            return ();
        }
        else {
            return undef;
        }
    }
}

#----------------------------------------------------------------------------

=head2 setup_body ( $value )

Setup the object's body method so that it can be used.  $value should be a hash ref of named
form variables and values.

=cut

sub setup_body {
	my $self = shift;
	my $value = shift;
	$self->{body} = $value;
}

#----------------------------------------------------------------------------

=head2 content_type ( [$value] )

Getter and setter for content_type.  If $value is passed in, it will set the content_type of
the object to that.  Returns the content_type stored in the object.

=cut

sub content_type {
	my $self = shift;
	my $value = shift;
	if (defined $value) {
		$self->{content_type} = $value;
	}
	return $self->{content_type};
}

#----------------------------------------------------------------------------

=head2 headers_in ( )

Mimics the behavior of Apache2::Request->headers_in.

=cut

sub headers_in {
       my $self = shift;
       return $self->{headers_in};
}

#----------------------------------------------------------------------------

=head2 headers_out ( )

Returns the PseudoRequst::Headers object stored in $self for access to the headers.

=cut

sub headers_out {
	my $self = shift;
	return $self->{headers_out}; ##return object for method chaining
}

#----------------------------------------------------------------------------

=head2 no_cache ( [$value] )

Getter and setter for no_cache.  If $value is passed in, it will set no_cache of
the object to that.  Returns the no_cache value stored in the object.

=cut

sub no_cache {
	my $self = shift;
	my $value = shift;
	if (defined $value) {
		$self->{no_cache} = $value;
	}
	return $self->{no_cache};
}

#----------------------------------------------------------------------------

=head2 param ( [$value])

Compatibility method.  Works exactly like the body method.

=cut

sub param {
	my $self = shift;
    $self->body(@_);
}

#----------------------------------------------------------------------------

=head2 setup_param ( $value )

Setup the object's param method so that it can be used.  $value should be a hash ref of named
form variables and values.

=cut

sub setup_param {
	my $self = shift;
    $self->setup_body(@_);
}

#----------------------------------------------------------------------------

=head2 clear_output ( )

Clear the internally cached request output generated by calling the
C<print> method.

=cut

sub clear_output {
    my $self = shift;
    $self->{output} = '';
}

#----------------------------------------------------------------------------

=head2 get_output ( )

Get the internally cached request output generated by calling the
C<print> method.  Returns it as a scalar.

=cut

sub get_output {
    my $self = shift;
    return $self->{output};
}

#----------------------------------------------------------------------------

=head2 method ( [ $method ] )

Getter/setter for the HTTP request method.

=cut

sub method {
    my ($self, $newMethod) = @_;
    my $method = $self->{method};
    if (defined $newMethod) {
        $self->{method} = $newMethod;
    }
    return $method;
}

#----------------------------------------------------------------------------

=head2 print ( @values )

Fake print method for the PseudoRequest object.  It caches everything printed
to it by concatenating @values together, just like print would.  Use clear_output
to clear the cached value, and get_output to access it.

=cut

sub print {
    my $self = shift;
    $self->{output} .= join '', @_;
    return 1;
}

#----------------------------------------------------------------------------

=head2 protocol ( $value )

Getter and setter for protocol.  If $value is passed in, it will set the protocol of
the object to that.  Returns the protocol value stored in the object.

=cut

sub protocol {
	my $self = shift;
	my $value = shift;
	if (defined $value) {
		$self->{protocol} = $value;
	}
	return $self->{protocol};
}

#----------------------------------------------------------------------------

=head2 status ( $value )

Getter and setter for status.  If $value is passed in, it will set the status of
the object to that.  Returns the status value stored in the object.

=cut

sub status {
	my $self = shift;
	my $value = shift;
	if (defined $value) {
		$self->{status} = $value;
	}
	return $self->{status};
}

#----------------------------------------------------------------------------

=head2 status_line ( $value )

Getter and setter for status_line.  If $value is passed in, it will set the status_line of
the object to that.  Returns the status_line value stored in the object.

=cut

sub status_line {
	my $self = shift;
	my $value = shift;
	if (defined $value) {
		$self->{status_line} = $value;
	}
	return $self->{status_line};
}

#----------------------------------------------------------------------------

=head2 upload ( $formName, [ $uploadFileHandler ] )

Getter and setter for upload objects, which are indexed in this object by $formName.
Returns what was stored in the slot referred to as $formName.  If $formName is false,
it returns undef.

=head3 $uploadFileHandle.

$uploadFileHandle should be an array ref of WebGUI::PseudoRequest::Upload objects.  If you
pass it $uploadFileHandle, it will set store the object under the name, $formName.

=cut

sub upload {
	my $self = shift;
    my $formName = shift;
    my $uploadFileHandles = shift;
    return unless $formName;
	if (defined $uploadFileHandles) {
		$self->{uploads}->{$formName} = $uploadFileHandles;
	}
	return @{ $self->{uploads}->{$formName} };
}

#----------------------------------------------------------------------------

=head2 uploadFiles ( $formName, $filesToUpload )

Convenience method for uploading several files at once into the PseudoRequest object,
all to be referenced off of $formName.  If $formName is false, it returns undef.

=head3 $fileToUpload

$uploadFileHandle should be an array ref of complete paths to files.  The method will
create one PseudoRequest::Upload object per file, then store the array ref
using the upload method.

=cut

sub uploadFiles {
	my $self = shift;
    my $formName = shift;
    my $filesToUpload = shift;
    return unless $formName;
    return unless scalar $filesToUpload;
    my @uploadObjects = ();
    foreach my $file (@{ $filesToUpload }) {
        my $upload = WebGUI::PseudoRequest::Upload->new($file);
        push @uploadObjects, $upload;
    }
    $self->upload($formName, \@uploadObjects);
}

#----------------------------------------------------------------------------

=head2 uri ( $value )

Getter and setter for uri.  If $value is passed in, it will set the uri of
the object to that.  Returns the uri value stored in the object.

=cut

sub uri {
	my $self = shift;
	my $value = shift;
	if (defined $value) {
		$self->{uri} = $value;
	}
	return $self->{uri};
}

#----------------------------------------------------------------------------

=head2 user ( $value )

Getter and setter for user.  If $value is passed in, it will set the user of
the object to that.  Returns the user value stored in the object.

=cut

sub user {
	my $self = shift;
	my $value = shift;
	if (defined $value) {
		$self->{user} = $value;
	}
	return $self->{user};
}

#----------------------------------------------------------------------------

=head2 jar ( $value )

Getter and setter for cookie jar.  If $value is passed in, it will
set the cookie jar of the object to that.  Returns the cookie jar
hash.

=cut

sub jar {
    my $self = shift;
    my $value = shift;
    if (defined $value) {
        $self->{jar} = $value;
    }
    return $self->{jar};
}

1;

