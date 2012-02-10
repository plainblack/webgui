package WebGUI::Role::Asset::Dashlet;

use Moose::Role;
use JSON;

=head1 NAME

WebGUI::AssetAspect::Dashlet - Implement features to turn Assets into Dashlets

=head1 SYNOPSIS

This Aspect provides methods that allow a Dashboard to determine, store and retrieve
customization options for Assets.

=head1 DESCRIPTION


=head1 METHODS

#----------------------------------------------------------------------------

=head2 fetchUserOverrides ($dashboardAssetId, [$userId])

Retrieve user preferences for a particular dashboard and user for this Asset from the database.

=head3 $dashboardId

The assetId of the dashboard to reference.

=head3 $userId

The userId to whose preferences should be returned.  Uses the current session user if omitted.

=cut

sub fetchUserOverrides {
    my $self             = shift;
    my $dashboardAssetId = shift;
    my $userId           = shift || $self->session->user->userId;
    my $properties_json  = $self->session->db->quickScalar('select properties from Dashboard_userPrefs where dashboardAssetId=? and userId=? and dashletAssetId=?',[$dashboardAssetId, $userId, $self->getId,]);
    $properties_json ||= '{}';
    my $properties = JSON->new->decode($properties_json);
    return $properties;
}

#----------------------------------------------------------------------------

=head2 getOverrideFormDefinition

Return an array ref of form properties.  The form properties are those that the
Asset has marked as being able to be overridden by a Dashboard asset by giving
the property the dashletOverridable flag.

Assets that want to allow additional properties outside of their definition should
override and extend this method.

=cut

sub getOverrideFormDefinition {
    my $self      = shift;
    my $session   = $self->session;
    my @properties;
    foreach my $property ( $self->getProperties ) {
        my $fieldHash = $self->getFieldData( $property );
        next unless $fieldHash->{dashletOverridable};
        $fieldHash->{name} = $property;
        push @properties, $fieldHash;
    }
    return @properties;
}

#----------------------------------------------------------------------------

=head2 getUserOverrides

Store user preferences for this Asset.  This is direct reference from inside the object, so
if you plan to modify the data, Clone it first.

=cut

sub getUserOverrides {
    return shift->{_userOverrides};
}

#----------------------------------------------------------------------------

=head2 setUserOverrides

Store user preferences for this Asset.

=cut

sub setUserOverrides {
    shift->{_userOverrides} = shift;
}

#----------------------------------------------------------------------------

=head2 storeUserOverrides ($dashboardAssetId, $properties, [$userId])

Store user preferences for a particular dashboard and user for this Asset to the database.

=head3 $dashboardId

The assetId of the dashboard to reference.

=head3 $userId

The userId to whose preferences should be returned.  Uses the current session user if omitted.

=cut

sub storeUserOverrides {
    my $self             = shift;
    my $session          = $self->session;
    my $dashboardAssetId = shift;
    my $properties       = shift;
    my $userId           = shift || $session->user->userId;
    my $properties_json  = JSON->new->encode($properties);
    $session->db->write('DELETE FROM Dashboard_userPrefs where dashboardAssetId=? and userId=? and dashletAssetId=?',[$dashboardAssetId, $userId, $self->getId]);
    $session->db->write('INSERT INTO Dashboard_userPrefs (dashboardAssetId, userId, dashletAssetId, properties) VALUES (?,?,?,?)', [$dashboardAssetId, $userId, $self->getId, $properties_json]);
}


1; # You can't handle the truth
