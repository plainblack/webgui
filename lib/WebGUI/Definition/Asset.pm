package WebGUI::Definition::Asset;

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
use warnings;
use 5.010;
use base qw(WebGUI::Definition);

use WebGUI::International;
use WebGUI::Exception;

our $VERSION = '0.0.1';

sub import {
    my $class = shift;
    if (! @_) {
        return;
    }
    my $definition = (@_ == 1 && ref $_[0]) ? $_[0] : { @_ };

    my $table = $definition->{tableName}
        || WebGUI::Error::InvalidParam->throw(param => 'tableName');

    if ( my $properties = $definition->{properties} ) {
        for ( my $i = 0; $i < $#{ $properties }; $i += 2) {
            my ($name, $value) = @{ $properties }[$i, $i + 1];
            $value->{tableName} ||= $table;
            if ( ! $value->{tableName}|| ref $value->{tableName}) {
                WebGUI::Error::InvalidParam->throw(param => 'tableName');
            }
            elsif ( ! $value->{fieldType}  || ref $value->{fieldType}) {
                WebGUI::Error::InvalidParam->throw(param => 'fieldType');
            }
            elsif ( ( ! $value->{noFormPost} || ref $value->{noFormPost} ) && ! $value->{label}) {
                WebGUI::Error::InvalidParam->throw(param => 'label');
            }
        }
    }

    # WebGUI::Definition->import uses caller, so avoid the extra entry in the call stack
    my $next = $class->next::can;
    @_ = ($class, $definition);
    goto $next;
}

sub _gen_getProperty {
    my $class = shift;
    my $superGetProperty = $class->next::method(@_);
    return sub {
        my $self = shift;
        my $property = $self->$superGetProperty(@_);
        for my $element (qw(label hoverHelp)) {
            if ($property->{$element} && ref $property->{$element} eq 'ARRAY') {
                $property->{$element}
                    = WebGUI::International->new($self->session)->get(@{$property->{$element}});
            }
        }
        return $property;
    };
}

1;

