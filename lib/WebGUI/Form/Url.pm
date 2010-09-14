package WebGUI::Form::Url;

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
use base 'WebGUI::Form::Text';
use WebGUI::International;

=head1 NAME

Package WebGUI::Form::Url

=head1 DESCRIPTION

Creates a URL form field.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::Text.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the superclass for additional details.

=head3 additionalTerms

The following additional parameters have been added via this sub class.

=head4 maxlength

Defaults to 2048. Determines the maximum number of characters allowed in this field.

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	my $i18n = WebGUI::International->new($session);
	push(@{$definition}, {
		maxlength=>{
			defaultValue=> 2048
			},
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 getName ( session )

Returns the human readable name of this control.

=cut

sub getName {
    my ($self, $session) = @_;
    return WebGUI::International->new($session, 'WebGUI')->get('478');
}

#-------------------------------------------------------------------

=head2 getValue ( )

Parses the posted value and tries to make corrections if necessary.

=cut

sub getValue {
	my $self = shift;
	my $value = $self->SUPER::getValue(@_);
	$value =~ tr/\r\n//d;
	# empty
	if ($value eq "" || $value =~ m{^http://$}i) {
		return "";
	}
	# proper email url
    elsif ($value =~ /mailto:/) {
        return $value;
    }
	# improper email url
    elsif ($value =~ /^([A-Z0-9]+[._+-]?){1,}([A-Z0-9]+[_+-]?)+\@(([A-Z0-9]+[._-]?){1,}[A-Z0-9]+\.){1,}[A-Z]{2,4}$/i) {
        return "mailto:".$value;
    }
	# proper web url
    elsif ($value =~ /^\// || $value =~ /:\/\// || $value =~ /^\^/) {
        return $value;
    }
	# improper web url
    return "http://".$value;
}

#-------------------------------------------------------------------

=head2 getValueAsHtml ( )

Formats as a link.

=cut

sub getValueAsHtml {
    my $self = shift;
    my $url = $self->getOriginalValue;
    return '<a href="'.$url.'">'.$url.'</a>';
}


#-------------------------------------------------------------------

=head2 headTags ( )

Add JS.

=cut

sub headTags {
    my $self = shift;
    return if $self->headTagsSent;
	$self->session->style->setScript($self->session->url->extras('addHTTP.js'),{ type=>'text/javascript' });
    $self->SUPER::headTags();
    return;
}

#-------------------------------------------------------------------

=head2 isDynamicCompatible ( )

A class method that returns a boolean indicating whether this control is compatible with the DynamicField control.

=cut

sub isDynamicCompatible {
    return 1;
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a URL field.

=cut

sub toHtml {
    my $self = shift;
	$self->set("extras", $self->get('extras') . ' onblur="addHTTP(this.form.'.$self->get("name").')"');
	return $self->SUPER::toHtml;
}

1;

