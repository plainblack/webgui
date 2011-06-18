package WebGUI::Template::Proxy::Asset;
use strict;
use warnings;

use base 'WebGUI::Template::Proxy';

sub _get_allowed {
    my $self = shift;
    my $asset = shift;
    my @properties = $asset->meta->get_all_property_list;
    return @properties;
}

sub parent {
    my $self = shift;
    my $parent = $self->{_asset}->parentNode;
    $self->_wrap($parent);
    return $parent;
}

1;

