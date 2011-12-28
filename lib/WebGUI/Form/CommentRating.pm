package WebGUI::Form::CommentRating;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use base 'WebGUI::Form::RadioList';
use Tie::IxHash;

=head1 NAME

Package WebGUI::Form::CommentRating

=head1 DESCRIPTION

Displays a comment rating field (unhappy to happy).

=head1 SEE ALSO

This is a subclass of WebGUI::Form::Control::RadioList.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the super class for additional details.

=head3 additionalTerms

The following additional parameters have been added via this sub class.

=cut

sub definition {
    my $class = shift;
    my $session = shift;
    my $definition = shift || [];
    push(@{$definition}, {
        });
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 getDefaultValue ( )

Returns 0

=cut

sub getDefaultValue {
    return 0;
}

#-------------------------------------------------------------------

=head2 getName ( session )

Returns the name of the form control.

=cut

sub getName {
    my ($class, $session) = @_;
    return 'Comment Rating';
}

#-------------------------------------------------------------------

=head2 getOptions ( )

Options are passed in for many list types. Those options can come in as a hash ref, or a \n separated string, or a key|value\n separated string. This method returns a hash ref regardless of what's passed in.

=cut

sub getOptions {
    my ($self) = @_;
    my %options = ();
    tie %options, 'Tie::IxHash';
    my $url = $self->session->url;
    my $pathFragment = 'form/CommentRating';
    %options = (
        0 => q{<img src="}.$url->extras("$pathFragment/0.png").q{" style="vertical-align: middle;" alt="0" />},
        1 => q{<img src="}.$url->extras("$pathFragment/1.png").q{" style="vertical-align: middle;" alt="1" />},
        2 => q{<img src="}.$url->extras("$pathFragment/2.png").q{" style="vertical-align: middle;" alt="2" />},
        3 => q{<img src="}.$url->extras("$pathFragment/3.png").q{" style="vertical-align: middle;" alt="3" />},
        4 => q{<img src="}.$url->extras("$pathFragment/4.png").q{" style="vertical-align: middle;" alt="4" />},
        5 => q{<img src="}.$url->extras("$pathFragment/5.png").q{" style="vertical-align: middle;" alt="5" />},
        );
    return \%options;
}

#-------------------------------------------------------------------

=head2 getValue ( [ value ] )

Does some special processing.

=cut

sub getValue {
    my $self = shift;
    my $value = $self->SUPER::getValue(@_);

    if ($value !~ m/^\d+$/ || $value < 1 || $value > 5) {
        $value = $self->getDefaultValue;
    }

    return $value;
}

#-------------------------------------------------------------------

=head2 getValueAsHtml ( )

Formats as an icon.

=cut

sub getValueAsHtml {
    my $self = shift;
    my $value = $self->getValue;
    my $url = $self->session->url;
    return q{<img src="}.$url->extras('form/CommentRating'.$value.'.png').q{" style="vertical-align: middle;" alt="}.$value.q{" />};
}


1;

