package WebGUI::PseudoRequest::Upload;

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
use File::Copy ();

=head1 NAME

Package WebGUI::PseudoRequest::Upload

=head2 new ( [$file] )

Construct a new PseudoRequest::Upload object.  This is just for holding headers.
It doesn't do any magic.

=head3 $file

The complete path to a file.  If this is sent to new, it will go ahead and open
a filehandle to that file for you, saving you the need to call the fh, filename
and filesize methods.

=cut

sub new {
	my $this = shift;
	my $class = ref($this) || $this;
	my $self = {
        fh       => undef,
        size     => 0,
        filename => '',
        output   => '',
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

#----------------------------------------------------------------------------

=head2 fh ( [$value] )

Getter and setter for fh.  If $value is passed in, it will set the internal filehandle in
the object to that.  Returns the filehandle stored in the object.

=cut

sub fh {
	my $self = shift;
	my $value = shift;
	if (defined $value) {
		$self->{fh} = $value;
	}
	return $self->{fh};
}

#----------------------------------------------------------------------------

=head2 filaname ( [$value] )

Getter and setter for filename.  If $value is passed in, it will set the filename in
the object to that.  Returns the filename in the object.

=cut

sub filename {
	my $self = shift;
	my $value = shift;
	if (defined $value) {
		$self->{filename} = $value;
	}
	return $self->{filename};
}

#----------------------------------------------------------------------------

=head2 size ( [$value] )

Getter and setter for size.  If $value is passed in, it will set the internal size in
the object to that.  Returns the size stored in the object.

=cut

sub size {
	my $self = shift;
	my $value = shift;
	if (defined $value) {
		$self->{size} = $value;
	}
	return $self->{size};
}

sub link {
    my $self = shift;
    my $dest = shift;
    return File::Copy::copy($self->filename, $dest);
}

1;

