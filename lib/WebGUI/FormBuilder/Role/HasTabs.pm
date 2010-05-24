package WebGUI::FormBuilder::Role::HasTabs;

use strict;
use Moose::Role;
use Carp qw(confess);

with 'WebGUI::FormBuilder::Role::HasObjects';
requires 'session', 'pack', 'unpack';

has 'tabsets' => (
    is      => 'rw',
    isa     => 'ArrayRef',
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
    my ($tab, $self, %properties);
    if ( blessed( $_[1] ) ) {
        ( $self, my $object, %properties ) = @_;
        $properties{ name   } ||= $object->can('name')      ? $object->name     : "";
        $properties{ label  } ||= $object->can('label')     ? $object->label    : "";
        $tab = WebGUI::FormBuilder::Tab->new( $self->session, %properties );
        if ( $object->DOES('WebGUI::FormBuilder::Role::HasTabs') ) {
            for my $objectTabset ( @{$object->tabsets} ) {
                for my $objectTab ( @{$objectTabset->tabs} ) {
                    $tab->addTab( $objectTab, tabset => $objectTabset->name );
                }
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
        ( $self, %properties ) = @_;
        $tab = WebGUI::FormBuilder::Tab->new( $self->session, %properties );
    }
    my $tabsetName  = delete $properties{ tabset } || "default";
    my $tabset      = $self->getTabset( $tabsetName )
                    || $self->addTabset( name => $tabsetName )
                    ;
    $tabset->addTab( $tab );
    $self->{_tabsByName}{$tab->name} = $tab;
    return $tab;
}

#----------------------------------------------------------------------------

=head2 addTabset ( properties )

Add a tabset. A tabset holds a bunch of tabs. Returns the WebGUI::FormBuilder::Tabset
object.

=cut

sub addTabset {
    my ( $self, %properties ) = @_;
    if ( $self->{_tabsetsByName}{$properties{name}} ) {
        confess "Cannot add another tabset of the same name: $properties{name}\n";
    }
    my $tabset  = WebGUI::FormBuilder::Tabset->new( $self->session, %properties );
    $self->{_tabsetsByName}{$tabset->name} = $tabset;
    push @{$self->tabsets}, $tabset;
    $self->addObject( $tabset );
    return $tabset;
}

#----------------------------------------------------------------------------

=head2 deleteTab ( name )

Delete a tab by name. Returns the tab deleted.

=cut

sub deleteTab {
    my ( $self, $name ) = @_;
    my $tab    = delete $self->{_tabsByName}{$name};
    for my $tabset ( @{ $self->tabsets } ) {
        for ( my $i = 0; $i < scalar @{$tabset->tabs}; $i++ ) {
            my $testTab    = $tabset->tabs->[$i];
            if ( $testTab->name eq $name ) {
                splice @{$tabset->tabs}, $i, 1;
            }
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

#----------------------------------------------------------------------------

=head2 getTabset ( name )

Get a tabset object by name

=cut

sub getTabset {
    my ( $self, $name ) = @_;
    $name ||= "default";
    return $self->{_tabsetsByName}{$name};
}

1;
