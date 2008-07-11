package WebGUI::AssetMixin::Installable;

use strict;
use mixin::with 'WebGUI::Asset';

use WebGUI::Asset;
use WebGUI::Form::DynamicField;


=head1 NAME

WebGUI::AssetMixin::Installable -- Make your asset installable

=head1 SYNOPSIS

  package WebGUI::Asset::MyAsset;
  use mixin 'WebGUI::AssetMixin::Installable';

  # Override the install method to install collateral tables
  sub install {
      my $class     = shift;
      my $session   = shift;
      $self->SUPER::install( $session );
  }

  # Override the uninstall method to remove collateral tables
  sub uninstall {
      my $class     = shift;
      my $session   = shift;
      $self->SUPER::uninstall( $session );
  }

=head1 DESCRIPTION

This mixin adds installing and uninstalling to your asset class. 

For most purposes, just C<use mixin 'WebGUI::AssetMixin::Installable'> 
will suffice.

If you need to install collateral information or otherwise, override the
C<install> method, but make sure to call the superclass before you try
anything else.

=head1 METHODS

Methods prefixed with a C<_> are not exported into your namespace.

=cut

#----------------------------------------------------------------------------

=head2 install ( session ) 

Install the asset. C<session> is a WebGUI::Session object from the site to
install the asset into.

=cut

sub install {
    my $class       = shift;
    my $session     = shift;    

    ### Install the first member of the definition
    my $definition  = $class->definition( $session );
    my $installDef  = shift @{ $definition };

    # Make the table according to WebGUI::Form::Control's dbDataType
    my $sql     = q{CREATE TABLE `} . $installDef->{tableName} . q{` ( }
                . q{`assetId` VARCHAR(22) BINARY NOT NULL, }
                . q{`revisionDate` BIGINT NOT NULL, }
                ;
    for my $column ( keys %{ $installDef->{properties} } ) {
        my $control     
            = WebGUI::Form::DynamicField->new( $session, 
                %{ $installDef->{properties}->{ $column } } 
            );
        $sql .= q{`} . $column . q{` } . $control->get('dbDataType') . q{, };

    }
    $sql    .= q{ PRIMARY KEY ( assetId, revisionDate ) ) };

    $session->db->write( $sql );

    # Write to the configuration
    $session->config->addToArray( "assets", $installDef->{className} );

    return;
}

#----------------------------------------------------------------------------

=head2 uninstall ( session ) 

Unnstall the asset. C<session> is a WebGUI::Session object from the site to
uninstall the asset from.

=cut

sub uninstall {
    my $class       = shift;
    my $session     = shift;
    
    ### Uninstall the first member of the definition
    my $definition  = $class->definition( $session );
    my $installDef  = shift @{ $definition };

    ### Remove all assets contained in the table
    my $sth     = $session->db->read( "SELECT assetId FROM `$installDef->{tableName}`" );
    while ( my ( $assetId ) = $sth->array ) {
        my $asset   = WebGUI::Asset->newByDynamicClass( $session, $assetId );
        $asset->purge;
    }

    # Drop the table
    my $sql     = q{DROP TABLE `} . $installDef->{tableName} . q{`};

    $session->db->write( $sql );
    $session->config->deleteFromArray( "assets", $installDef->{className} );
    
    return;
}


1;
