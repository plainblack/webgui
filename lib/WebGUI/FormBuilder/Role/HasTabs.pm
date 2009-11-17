package WebGUI::FormBuilder::Role::HasTabs;

use strict;
use Moose::Role;

with 'WebGUI::FormBuilder::Role::HasObjects';
requires 'session', 'pack', 'unpack';

has 'tabs' => (
    is      => 'rw',
    isa     => 'ArrayRef[WebGUI::FormBuilder::Tab]',
    default => sub { [] },
);

=head1 METHODS

=cut

#----------------------------------------------------------------------------

=head2 addTab ( properties )

Add a tab. C<properties> is a list of name => value pairs to be passed to
L<WebGUI::FormBuilder::Tab>.

=head2 addTab ( object, propertiesOverrides )

Add a tab. C<object> is any object that implements L<WebGUI::FormBuilder::Role::HasFields>.
Any sub-tabs or fieldsets will also be included.

=cut

sub addTab {
    my ($tab, $self);
    if ( blessed( $_[1] ) ) {
        ( $self, my $object, my %properties ) = @_;
        $properties{ name   } ||= $object->can('name')      ? $object->name     : "";
        $properties{ label  } ||= $object->can('label')     ? $object->label    : "";
        $tab = WebGUI::FormBuilder::Tab->new( $self->session, %properties );
        if ( $object->DOES('WebGUI::FormBuilder::Role::HasTabs') ) {
            for my $objectTab ( @{$object->tabs} ) {
                $tab->addTab( $objectTab );
            }
        }
        if ( $object->DOES('WebGUI::FormBuilder::Role::HasFieldsets') ) {
            for my $objectFieldset ( @{$object->fieldsets} ) {
                $tab->addFieldset( $objectFieldset );
            }
        }
        if ( $object->DOES('WebGUI::FormBuilder::Role::HasFields') ) {
            for my $objectField ( @{$object->fields} ) {
                $tab->addField( $objectField );
            }
        }
    }
    else {
        ( $self, my @properties ) = @_;
        $tab = WebGUI::FormBuilder::Tab->new( $self->session, @properties );
    }
    push @{$self->tabs}, $tab;
    $self->{_tabsByName}{$tab->name} = $tab;
    return $tab;
}

#----------------------------------------------------------------------------

=head2 deleteTab ( name )

Delete a tab by name. Returns the tab deleted.

=cut

sub deleteTab {
    my ( $self, $name ) = @_;
    my $tab    = delete $self->{_tabsByName}{$name};
    for ( my $i = 0; $i < scalar @{$self->tabs}; $i++ ) {
        my $testTab    = $self->tabs->[$i];
        if ( $testTab->name eq $name ) {
            splice @{$self->tabs}, $i, 1;
        }
    }
    return $tab;
}

#----------------------------------------------------------------------------

=head2 getTab ( name )

Get a tab object by name

=cut

sub getTab {
    my ( $self, $name ) = @_;
    return $self->{_tabsByName}{$name};
}

1;
