package WebGUI::AssetAspect::Installable;

use strict;
use Class::C3;

use WebGUI::Asset;
use WebGUI::Form::DynamicField;

=head1 NAME

WebGUI::AssetAspect::Installable -- Make your asset installable

=head1 SYNOPSIS

  package WebGUI::Asset::MyAsset;
  use base ( 'WebGUI::AssetAspect::Installable', 'WebGUI::Asset' );

  # Override the install method to install collateral tables
  sub install {
      my $class     = shift;
      my $session   = shift;
      $self->next::method( $session );
  }

  # Override the uninstall method to remove collateral tables
  sub uninstall {
      my $class     = shift;
      my $session   = shift;
      $self->next::method( $session );
  }

=head1 DESCRIPTION

This aspect adds installing and uninstalling to your asset class. 

For most purposes, just inheriting from this aspect will suffice.

If you need to install collateral information or otherwise, override the
C<install> method, but make sure to call the superclass before you try
anything else.

=head1 METHODS

=cut

#----------------------------------------------------------------------------

=head2 install ( session ) 

Install the asset. C<session> is a WebGUI::Session object from the site to
install the asset into.

=cut

sub install {
    my $class   = shift;
    my $session = shift;

    ### Install the first member of the definition
    my $definition = $class->definition($session);
    my $installDef = shift @{$definition};

    # Make the table according to WebGUI::Form::Control's databaseFieldType
    my $sql
        = q{CREATE TABLE `}
        . $installDef->{tableName} . q{` ( }
        . q{`assetId` CHAR(22) BINARY NOT NULL, }
        . q{`revisionDate` BIGINT NOT NULL, };
    for my $column ( keys %{ $installDef->{properties} } ) {
        my $control = WebGUI::Form::DynamicField->new( $session, %{ $installDef->{properties}->{$column} } );
        $sql .= q{`} . $column . q{` } . $control->getDatabaseFieldType . q{, };

    }
    $sql .= q{ PRIMARY KEY ( assetId, revisionDate ) ) };

    $session->db->write($sql);

    # Write to the configuration
    $session->config->addToHash( "assets", $installDef->{className}, { category => "basic" } );

    return;
} ## end sub install

#----------------------------------------------------------------------------

=head2 isInstalled ( session )

Returns true if the asset is installed. By default, only checks for the 
last database table.

=cut

sub isInstalled {
    my $class   = shift;
    my $session = shift;

    my $tableName = $class->definition($session)->[0]->{tableName};
    my $exists = $session->db->quickScalar( "SHOW TABLES LIKE ?", [$tableName], );

    return $exists ? 1 : 0;
}

#----------------------------------------------------------------------------

=head2 uninstall ( session ) 

Unnstall the asset. C<session> is a WebGUI::Session object from the site to
uninstall the asset from.

=cut

sub uninstall {
    my $class   = shift;
    my $session = shift;

    ### Uninstall the first member of the definition
    my $definition = $class->definition($session);
    my $installDef = shift @{$definition};

    ### Remove all assets contained in the table
    my $sth = $session->db->read("SELECT assetId FROM `$installDef->{tableName}`");
    while ( my ($assetId) = $sth->array ) {
        my $asset = WebGUI::Asset->newById( $session, $assetId );
        $asset->purge;
    }

    # Drop the table
    my $sql = q{DROP TABLE `} . $installDef->{tableName} . q{`};

    $session->db->write($sql);
    $session->config->deleteFromHash( "assets", $installDef->{className} );

    return;
} ## end sub uninstall

#----------------------------------------------------------------------------

=head2 upgrade ( session )

Upgrade an existing installation of this asset. Try to reconcile the current
table with the current definition and modify the table if necessary.

=cut

sub upgrade {
    my ( $class, $session ) = @_;
    unless ( defined $session && $session->isa('WebGUI::Session') ) {
        WebGUI::Error::InvalidObject->throw(
            expected => 'WebGUI::Session',
            got      => ( ref $session ),
            error    => 'Need a session.'
        );
    }
    my $db         = $session->db;
    my $dbh        = $db->dbh;
    my $definition = $class->definition($session);
    my $properties = $definition->[0]->{properties};
    my $tableName  = $dbh->quote_identifier( $definition->[0]->{tableName} );

    # find out what fields already exist
    my %tableFields = ();
    my $sth         = $db->read( "DESCRIBE " . $tableName );
    while ( my ( $col, $type, $null, $key, $default ) = $sth->array ) {
        next if ( grep { $_ eq $col } 'assetId', 'revisionDate' );
        $tableFields{$col} = { type => $type, };
    }

    # update existing and create new fields
    foreach my $property ( keys %{$properties} ) {
        my $control = WebGUI::Form::DynamicField->new( $session, %{ $properties->{$property} }, );
        my $fieldType = $control->getDatabaseFieldType;
        if ( exists $tableFields{$property} ) {
            my $changed = 0;

            # parse database table field type
            $tableFields{$property}{type} =~ m/^(\w+)(\([\d\s,]+\))?$/;
            my ( $tableFieldType, $tableFieldLength ) = ( $1, $2 );

            # parse form field type
            $fieldType =~ m/^(\w+)(\([\d\s,]+\))?\s*(binary)?$/;
            my ( $formFieldType, $formFieldLength ) = ( $1, $2 );

            # compare table parts to definition
            $changed = 1 if ( $tableFieldType   ne $formFieldType );
            $changed = 1 if ( $tableFieldLength ne $formFieldLength );

            # modify if necessary
            if ($changed) {
                $db->write( "alter table $tableName change column "
                        . $dbh->quote_identifier($property) . " "
                        . $dbh->quote_identifier($property)
                        . " $fieldType " );
            }
        } ## end if ( exists $tableFields...
        else {
            $db->write( "alter table $tableName add column " . $dbh->quote_identifier($property) . " $fieldType " );
        }
        delete $tableFields{$property};
    } ## end foreach my $property ( keys...

    # delete fields that are no longer in the definition
    foreach my $property ( keys %tableFields ) {
        if ( $tableFields{$property}{key} ) {
            $db->write( "alter table $tableName drop index " . $dbh->quote_identifier($property) );
        }
        $db->write( "alter table $tableName drop column " . $dbh->quote_identifier($property) );
    }
    return 1;
} ## end sub upgrade

# TODO: Add updateTemplates and getTemplatePackage
# or some other manner of installing and maintaining default template package

1;
