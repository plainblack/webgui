package WebGUI::Form;

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
use Carp qw( croak );
use Scalar::Util qw( blessed );
use Tie::IxHash;
use WebGUI::International;
use WebGUI::Pluggable;
use WebGUI::Utility;

=head1 NAME

Package WebGUI::Form

=head1 DESCRIPTION

This is a convenience package which provides a simple interface to use all of the form controls without having to load each one seperately, create objects, and call methods.

=head1 SYNOPSIS

 use WebGUI::Form;

 $html = WebGUI::Form::formFooter($self->session,);
 $html = WebGUI::Form::formHeader($self->session,);

 $html = WebGUI::Form::anyFieldType($self->session,%properties);

 Example:

 $html = WebGUI::Form::text($self->session,%properties);

=head1 METHODS 

These functions are available from this package:

=cut

#-------------------------------------------------------------------

=head2 AUTOLOAD ( )

Dynamically creates functions on the fly for all the different form control types.

=cut

sub AUTOLOAD {
	our $AUTOLOAD;
	my $name = ucfirst((split /::/, $AUTOLOAD)[-1]);	
	my $session = shift;
	my @params = @_;
    my $control = eval { WebGUI::Pluggable::instanciate("WebGUI::Form::".$name, "new", [ $session, @params ]) };
    if ($@) {
        $session->errorHandler->error($@);
        return undef;
    }
	return $control->toHtml;
}


#-------------------------------------------------------------------

=head2 formFooter ( session )

Returns a form footer.

=head3 session

A reference to the current session.

=cut

sub formFooter {
	return "</div></form>\n\n";
}


#-------------------------------------------------------------------

=head2 formHeader ( session, options )

Returns a form header.  Also generates a CSRF token for use with the form.

=head3 session

A reference to the current session.

=head3 options

A hash reference that contains one or more of the following parameters.

=head4 action

The form action. Defaults to the current page.

NOTE: If the C<action> contains a query string (?param=value), C<formHeader> 
will  translate the parameters into hidden form elements automatically.

=head4 method

The form method. Defaults to "post".

=head4 enctype

The form enctype. Defaults to "multipart/form-data".

=head4 extras

If you want to add anything special to the form header like javascript 
actions or stylesheet info, then use this.

=cut

sub formHeader {
    my $session     = shift;
    my $params      = shift     || {};

    croak "First parameter must be WebGUI::Session object"
        unless blessed $session && $session->isa( "WebGUI::Session" );
    croak "Second parameter must be hash reference"
        if ref $params ne "HASH";
    
    my $action      = (exists $params->{action} && $params->{action} ne "") ? $params->{action} : $session->url->page();
    my $method      = (exists $params->{method} && $params->{method} ne "") ? $params->{method} : "post";
    my $enctype     = (exists $params->{enctype} && $params->{enctype} ne "") ? $params->{enctype} : "multipart/form-data";

    # Fix a query string in the action URL
    my $hidden = csrfToken($session);
    if ($action =~ /\?/) {
        ($action, my $query) = split /\?/, $action, 2;
        my @params = split /[&;]/, $query;
        foreach my $param ( @params ) {
            my ($name, $value) = split /=/, $param;
            $hidden .= hidden( $session, { name => $name, value => $value } );
        }
    }

    return '<form action="'.$action.'" enctype="'.$enctype.'" method="'.$method.'" '.$params->{extras}.'><div class="formContents">'.$hidden;
}





1;


