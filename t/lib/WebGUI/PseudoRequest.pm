package WebGUI::PseudoRequest;

use strict;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2005 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=head1 NAME

Package WebGUI::PseudoRequest

=head1 DESCRIPTION

This is the most complete imitation of Apache2::Request.  You can use this package to
create a request object that will work with WebGUI, without actually being inside
the mod_perl environment?

Why in the world would you want to do this?  Well, when doing API testing sometimes
you run across things that require a request object, but you don't really want to
fire up Apache in order to do it.  This will let you bypass that.

=cut

package WebGUI::PseudoRequest::Headers;

sub new {
	my $this = shift;
	my $class = ref($this) || $this;
	my $self = { headers => {} };
	bless $self, $class;
	return $self;
}

sub set {
	my $self = shift;
	my $key = shift;
	my $value = shift;
	$self->{headers}->{$key} = $value;
}

sub fetch {
	my $self = shift;
	return $self->{headers};
}

package WebGUI::PseudoRequest::Upload;

sub new {
	my $this = shift;
	my $class = ref($this) || $this;
	my $self = {
        fh       => undef,
        size     => 0,
        filename => '',
    };
    my $file = shift;
    if ($file and -e $file) {
        $self->{filename} = $file;
        $self->{size} = (stat $file)[7];
        open my $fh, '<' . $file or
            die "Unable to open $file for reading and creating a filehandle: $!\n";
        $self->{fh} = $fh;
    }
	bless $self, $class;
	return $self;
}

sub fh {
	my $self = shift;
	my $value = shift;
	if (defined $value) {
		$self->{fh} = $value;
	}
	return $self->{fh};
}

sub filename {
	my $self = shift;
	my $value = shift;
	if (defined $value) {
		$self->{filename} = $value;
	}
	return $self->{filename};
}

sub size {
	my $self = shift;
	my $value = shift;
	if (defined $value) {
		$self->{size} = $value;
	}
	return $self->{size};
}

package WebGUI::PseudoRequest;

#----------------------------------------------------------------------------

=head2 new

Construct a new PseudoRequest object.  Creates a new Headers object as well and places
it inside the PseudoRequest object.

=cut

sub new {
	my $this = shift;
	my $class = ref($this) || $this;
	my $headers = WebGUI::PseudoRequest::Headers->new();
	my $self = {headers_out => $headers};
	bless $self, $class;
	return $self;
}

=head2 body ( [$value])

Compatibility method.  Returns the requested form value, $value.  If $value isn't passed in, returns
all form variables.

=cut


sub body {
	my $self = shift;
	my $value = shift;
	return keys %{ $self->{body} } unless defined $value;
	if ($self->{body}->{$value}) {
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

=head2 setup_body ( $value )

Setup the object's body method so that it can be used.  $value should be a hash ref of named
form variables and values.

=cut

sub setup_body {
	my $self = shift;
	my $value = shift;
	$self->{body} = $value;
}

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

=head2 headers_out ( )

Returns the PseudoRequst::Headers object stored in $self for access to the headers.

=cut

sub headers_out {
	my $self = shift;
	return $self->{headers_out}; ##return object for method chaining
}

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

sub param {
	my $self = shift;
	my $value = shift;
	return keys %{ $self->{param} } unless defined $value;
	if ($self->{param}->{$value}) {
        if (wantarray && ref $self->{param}->{$value} eq "ARRAY") {
            return @{$self->{param}->{$value}};
        }
        elsif (ref $self->{param}->{$value} eq "ARRAY") {
            return $self->{param}->{$value}->[0];
        }
        else {
            return $self->{param}->{$value};
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

sub setup_param {
	my $self = shift;
	my $value = shift;
	$self->{param} = $value;
}

sub protocol {
	my $self = shift;
	my $value = shift;
	if (defined $value) {
		$self->{protocol} = $value;
	}
	return $self->{protocol};
}

sub status {
	my $self = shift;
	my $value = shift;
	if (defined $value) {
		$self->{status} = $value;
	}
	return $self->{status};
}

sub status_line {
	my $self = shift;
	my $value = shift;
	if (defined $value) {
		$self->{status_line} = $value;
	}
	return $self->{status_line};
}

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

sub uri {
	my $self = shift;
	my $value = shift;
	if (defined $value) {
		$self->{uri} = $value;
	}
	return $self->{uri};
}

sub user {
	my $self = shift;
	my $value = shift;
	if (defined $value) {
		$self->{user} = $value;
	}
	return $self->{user};
}

1;
