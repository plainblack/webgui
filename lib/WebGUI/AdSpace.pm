package WebGUI::AdSpace;

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
use WebGUI::AdSpace::Ad;

=head1 NAME

Package WebGUI::AdSpace

=head1 DESCRIPTION

This class provides a mechanism for controlling advertisements from within WebGUI.

=head1 SYNOPSIS

 use WebGUI::AdSpace;

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 countClick ( adId )

Increments click counter, and returns the URL to send the user to.

=head3 adId

The unique ID of the ad that was clicked.

=cut

sub countClick {
	my $class = shift;
	my $session = shift;
	my $id = shift;
	my ($url) = $session->db->quickArray("select url from advertisement where adId=?",[$id]);
        return $url if $session->request->requestNotViewed();
	$session->db->write("update advertisement set clicks=clicks+1 where adId=?",[$id]);
	return $url;
}

#-------------------------------------------------------------------

=head2 create ( session, properties ) 

Object constructor for new AdSpaces.

=head3 session

A reference to the current session.

=head3 properties

The properties used to create this object. See the set() method for details.

=cut

sub create {
	my $class = shift;
	my $session = shift;
	my $properties = shift || {};
	return undef unless $properties->{name};
	my $test = $class->newByName($session, $properties->{name});
	return undef if defined $test;
	my $id = $session->db->setRow("adSpace","adSpaceId",{adSpaceId=>"new"});
	my $self = $class->new($session, $id);
	$self->set($properties);
	return $self;
}


#-------------------------------------------------------------------

=head2 delete ( )

Deletes this ad space.

=cut

sub delete {
	my $self = shift;
	foreach my $ad (@{$self->getAds}) {
		$ad->delete;
	}
	$self->session->db->deleteRow("adSpace","adSpaceId",$self->getId);
	$self = undef;
}

#-------------------------------------------------------------------

=head2 displayImpression ( dontCount )

Finds out what the next ad is to display, increments it's impression counter, and returns the HTML to display it.

=head3 dontCount

A boolean that tells the ad system not to count this impression if true.

=cut

sub displayImpression {
	my $self = shift;
	my $dontCount = shift;
        return '' if $self->session->request->requestNotViewed();
	my ($id, $ad, $priority, $clicks, $clicksBought, $impressions, $impressionsBought) = $self->session->db->quickArray("select adId, renderedAd, priority, clicks, clicksBought, impressions, impressionsBought from advertisement where adSpaceId=? and isActive=1 order by nextInPriority asc limit 1",[$self->getId]);
	unless ($dontCount) {
		my $isActive = 1;
		if ($clicks >= $clicksBought && $impressions >= ($impressionsBought-1)) {
			$isActive = 0;
		}
		$self->session->db->write("update advertisement set impressions=impressions+1, nextInPriority=?, isActive=? where adId=?", 
			[time()+$priority, $isActive, $id]);
	}
	return $ad;
}

#-------------------------------------------------------------------

=head2 get ( name )

Returns the value of a property. See set() for a list of properties.

=head3 name

The name of the property to retrieve the value for.

=cut 

sub get {
	my $self = shift;
	my $name = shift;
    if (defined $name) {
        return $self->{_properties}{$name}
    }
    my %copyOfProperties = %{ $self->{_properties} };
    return \%copyOfProperties;
}

#-------------------------------------------------------------------

=head2 getAds ( )

Returns an array reference containing all the ads this ad space as objects.

=cut

sub getAds {
	my $self = shift;
	my @ads = ();
	my $rs = $self->session->db->read("select adId from advertisement where adSpaceId = ?", [$self->getId]);
	while (my ($id) = $rs->array) {
		push(@ads, WebGUI::AdSpace::Ad->new($self->session, $id));
	}	
	return \@ads;
}

#-------------------------------------------------------------------

=head2 getAdSpaces ( session )

Returns an array reference containing all the ad spaces as objects. This is a class method.

=cut

sub getAdSpaces {
	my $class = shift;
	my $session = shift;
	my @ads = ();
	my $rs = $session->db->read("select adSpaceId from adSpace order by title");
	while (my ($id) = $rs->array) {
		push(@ads, WebGUI::AdSpace->new($session, $id));
	}	
	return \@ads;
}

#-------------------------------------------------------------------

=head2 getId ( )

Returns the id of this object.

=cut 

sub getId {
	my $self = shift;
	return $self->{_properties}{adSpaceId};
}

#-------------------------------------------------------------------

=head2 new ( session, id )

Object constructor for fetching an existing AdSpace by id.

=head3 session

A reference to the current session.

=head3 id

The unqiue ID of an ad space location.

=cut

sub new {
	my $class = shift;
	my $session = shift;
	my $id = shift;
	my $properties = $session->db->getRow("adSpace","adSpaceId",$id);
	return undef unless $properties->{adSpaceId};
	bless {_session=>$session, _properties=>$properties}, $class;
}

#-------------------------------------------------------------------

=head2 newByName ( session, name )

Object constructor for fetching an existing AdSpace by name.

=head3 session

A reference to the current session.

=head3 name

The name of the ad space to retrieve.

=cut

sub newByName {
	my $class = shift;
	my $session = shift;
	my $name = shift;
	my $properties = $session->db->getRow("adSpace","name",$name);
	return undef unless $properties->{adSpaceId};
	bless {_session=>$session, _properties=>$properties}, $class;
}

#-------------------------------------------------------------------

=head2 session ( )

Returns a reference to the current session.

=cut

sub session {
	my $self = shift;
	return $self->{_session};
}

#-------------------------------------------------------------------

=head2 set ( properties ) 

Updates the properties of an ad space.

=head3 properties

A hash reference containing the properties to set.

=head4 name

The name that will be used to retrieve this ad space when it's in use one the web site. It should not contain spaces or characters other than alpha-numeric.

=head4 title

A human readable title for this ad space.

=head4 description

A human readable description for this ad space.

=head4 minimumImpressions

An integer indicating the minimum number of impressions an advertiser is allowed to purchase.

=head4 minimumClicks

An integer indicating the minimum number of clicks an advertiser is allowed to purchase.

=head4 width

The width, in pixels, of this ad space.

=head4 height

The height, in pixels, of this ad space.

=cut

sub set {
	my $self = shift;
	my $properties = shift || {};

	##create requires a name, default will never be used.  This prevents the name from being
    ##erased
	$self->{_properties}{name}  = $properties->{name} || $self->{_properties}{name}  || "Unnamed";

    ##Allow title and description to be cleared
	$self->{_properties}{title} = exists $properties->{title} ?  $properties->{title}
                                : $self->{_properties}{title} || "Untitled";
	$self->{_properties}{description} = exists $properties->{description} ? $properties->{description} : $self->{_properties}{description};
	$self->{_properties}{minimumImpressions} = $properties->{minimumImpressions} || $self->{_properties}{minimumImpressions};
	$self->{_properties}{minimumClicks} = $properties->{minimumClicks} || $self->{_properties}{minimumClicks};
	$self->{_properties}{width} = $properties->{width} || $self->{_properties}{width} || "468";
	$self->{_properties}{height} = $properties->{height} || $self->{_properties}{height} || "60";
	$self->session->db->setRow("adSpace","adSpaceId",$self->{_properties});
}

1;

