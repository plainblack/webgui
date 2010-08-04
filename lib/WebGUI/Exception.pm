package WebGUI::Exception;

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

sub WebGUI::Error::full_message {
    my $self = shift;
    my $message = $self->message ? $self->message : $self->description;
    my @fields = map { defined $self->$_ ? ($_ . ': ' . $self->$_) : () } $self->Fields;
    if (@fields) {
        $message .= ' (' . join( q{, }, @fields ) . ')';
    }
    return $message;
}

=head1 NAME

Package WebGUI::Exception;

=head1 DESCRIPTION

A base class for all exception handling. It creates a few base exception objects.

=head1 SYNOPSIS

 use WebGUI::Exception;

 # throw
 WebGUI::Error->throw(error=>"Something bad happened.");
 WebGUI::Error::ObjectNotFound->throw(error=>"Couldn't instanciate object.", id=>$id);

 # try
 eval { someFunction() };
 eval { my $obj = SomeClass->new($id) };

 # catch
 if (my $e = WebGUI::Error->caught("WebGUI::Error::ObjectNotFound")) {
    my $errorMessage = $e->error;
    my $objectId = $e->id;
    # do something
 }

B<NOTE>: Though the package name is WebGUI::Exception, the handler objects that are created are WebGUI::Error.

=head1 EXCEPTION TYPES

These exception classes are defined in this class:

=cut

#-------------------------------------------------------------------

=head2 WebGUI::Error

A basic do nothing exception. ISA Exception::Class.

=head3 error

The error message

 WebGUI::Error->throw(error => "Something bad happened");

 $message = $e->error;

=head3 file

A read only exception method that returns the file name of the file where the exception was thrown.

 $filename = $e->file;

=head3 line

A read only exception method that returns the line number where the exception was thrown.

 $lineNumber = $e->line;

=head3 package

A read only exception method that returns the package name where the exception was thrown.

=cut

#-------------------------------------------------------------------

=head2 WebGUI::Error::OverrideMe

An interface was not overriden as expected.

=cut

#-------------------------------------------------------------------

=head2 WebGUI::Error::MethodNotFound

Tried calling a method that doesn't exist.

=head3 method

The method called.

=cut

#-------------------------------------------------------------------

=head2 WebGUI::Error::InvalidObject

Used when looking to make sure objects are passed in that you expect. ISA WebGUI::Error::InvalidParam.

=head3 expected

The type of object expected ("HASH", "ARRAY", "WebGUI::User", etc).

=head3 got

The object type we got.

=cut

#-------------------------------------------------------------------

=head2 WebGUI::Error::InvalidParam

Used when an invalid parameter is passed into a subroutine.

=head3 param

Used to return the bad parameter, if present.

=cut

#-------------------------------------------------------------------

=head2 WebGUI::Error::ObjectNotFound

Used when an object is trying to be retrieved, but does not exist. ISA WebGUI::Error.

=head3 id

The id of the object to be retrieved.

=cut

#-------------------------------------------------------------------

=head2 WebGUI::Error::ObjectNotFound::Template

Used when a template is trying to be retrieved, but does not exist. ISA WebGUI::Error::ObjectNotFound.

=head3 templateId | id | assetId

The id of the object to be retrieved.

=cut

#-------------------------------------------------------------------

=head2 WebGUI::Error::InvalidFile

Used when accessing a file and there are formatting or data problems found in the file. ISA WebGUI::Error.

=head3 brokenFile

The filename.

=head3 brokenLine

The line the error was found on.

=cut

#-------------------------------------------------------------------

=head2 WebGUI::Error::Template

Used when a template has parsing errors. ISA WebGUI::Error.

=cut

#-------------------------------------------------------------------

=head2 WebGUI::Error::Connection

Used when connecting to an external resource and it fails for some reason. ISA WebGUI::Error.

=head3 resource

The name or configuration or URL of the resource trying to be accessed.

=cut

use Exception::Class (

    'WebGUI::Error' => {
        description     => "A general error occured.",
        },


    'WebGUI::Error::OverrideMe' => {
        isa             => 'WebGUI::Error',
        description     => 'This method should be overridden by subclasses.',
        },


    'WebGUI::Error::MethodNotFound' => {
        isa             => 'WebGUI::Error',
        description     => q|Called a method that doesn't exist.|,
        fields          => 'method'
        },


    'WebGUI::Error::InvalidObject' => {
        isa             => 'WebGUI::Error::InvalidParam',
        description     => "Expected to get a reference to an object type that wasn't gotten.",
        fields          => ["expected","got"],
        },


    'WebGUI::Error::InvalidParam' => {
        isa             => 'WebGUI::Error',
        description     => "Expected to get a param we didn't get.",
        fields          => ["param"],
        },


    'WebGUI::Error::Compile' => {
        isa             => 'WebGUI::Error',
        description     => "Unable to compile the requested class",
        fields          => ["class", "cause"],
        },


    'WebGUI::Error::ObjectNotFound' => {
        isa             => 'WebGUI::Error',
        description     => "The object you were trying to retrieve does not exist.",
        fields          => ["id"],
        },


    'WebGUI::Error::ObjectNotFound::Template' => {
        isa             => 'WebGUI::Error',
        description     => "The template an asset was trying to retrieve does not exist.",
        fields          => [qw/templateId assetId/],
        },


    'WebGUI::Error::InvalidFile' => {
        isa             => 'WebGUI::Error',
        description     => "The file you have provided has errors.",
        fields          => [qw{ brokenFile brokenLine }],
        },


    'WebGUI::Error::Template' => {
        isa             => 'WebGUI::Error',
        description     => "A template has errors that prevent it from being processed.",
        },


    'WebGUI::Error::Connection' => {
        isa             => 'WebGUI::Error',
        description     => "Couldn't establish a connection.",
        fields          => [qw{ resource }],
        },

    'WebGUI::Error::Fatal' => {
        isa             => 'WebGUI::Error',
        description     => "Fatal error that should be shown to all site visitors.",
    },

    'WebGUI::Error::Database' => {
        isa             => 'WebGUI::Error',
        description     => 'A database error',
    },
);

{
    package WebGUI::Error;
    use overload '~~' => sub {
        return $_[0]->isa($_[1]);
    },
    'eq' => sub {
        return $_[0]->error eq $_[1];
    },
    'ne' => sub {
        return $_[0]->error ne $_[1];
    };
}

1;

