package WebGUI::AdSpace::Ad;

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
use WebGUI::AdSpace;
use WebGUI::Macro;
use WebGUI::Storage;
use WebGUI::AssetCollateral::Sku::Ad::Ad;

=head1 NAME

Package WebGUI::AdSpace::Ad

=head1 DESCRIPTION

This class provides an mechanism for manipulating an individual ad within an ad space.

=head1 SYNOPSIS

 use WebGUI::AdSpace::Ad;

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 create ( session, adSpaceId, properties ) 

Object constructor for new Ads.

=head3 session

A reference to the current session

=head3 adSpaceId

The unique id of an ad space to attach this ad to.

=head3 properties

The properties used to create this object. See the set() method for details.
A hash must be passed into create and a "type" key of either "text", "rich"  or  "image" is mandatory. 

=cut

sub create {
	my $class = shift;
	my $session = shift;
	my $adSpaceId = shift;
	my $properties = shift;
	my $id = $session->db->setRow("advertisement","adId",{adSpaceId=>$adSpaceId, adId=>"new"});
	my $self = $class->new($session, $id);
	$self->set($properties);
	return $self;
}


#-------------------------------------------------------------------

=head2 delete ( )

Deletes this ad.

=cut

sub delete {
	my $self = shift;
        my $iterator = WebGUI::AssetCollateral::Sku::Ad::Ad->getAllIterator($self->session,{
             constraints => [ { "adSkuPurchase.adId = ?" => $self->getId } ],
             });
        while( my $object = $iterator->() ) {
             $object->update({'isDeleted' => 1});
        }
	my $storage = WebGUI::Storage->get($self->session, $self->get("storageId"));
	$storage->delete if defined $storage;
	$self->session->db->deleteRow("advertisement","adId",$self->getId);
	$self = undef;
}

#-------------------------------------------------------------------

=head2 get ( name )

Returns the value of a property.

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

=head2 getId ( )

Returns the id of this object.

=cut 

sub getId {
	my $self = shift;
	return $self->{_properties}{adId};
}

#-------------------------------------------------------------------

=head2 new ( session, id )

Object constructor for fetching an existing Ad.

=head3 session

A reference to the current session.

=head3 id

The unqiue ID of an ad.

=cut

sub new {
	my $class = shift;
	my $session = shift;
	my $id = shift;
	my $properties = $session->db->getRow("advertisement","adId",$id);
	return undef unless $properties->{adId};
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

=head4 title

A human readable name for this ad, which will be displayed in the ad, and in menus.

=head4 adText

A chunk of text, no longer than 255 characters that will be displayed in text ads.

=head4 storageId

The id of the storage location that holds the image for an image style ad.

=head4 richMedia

A chunk of HTML that will be inserted into the page for rich media ads.

=head4 ownerUserId

The user that owns this ad, and will be able to view reports for it, etc.

=head4 isActive

A boolean indicating whether the ad is active or not.

=head4 type

The type of ad this is. Defaults to 'text'. Choose from 'text', 'image', or 'rich'.

=head4 borderColor

The hex color to be used to display the border on a text based ad.

=head4 textColor

The hex color to be used to display the text on a text based ad.

=head4 backgroundColor

The hex color to be used to display the background on a text based ad.

=head4 priority

An integer that will be used to scale the frequency of ad placement based upon traffic to your site. The lower the number, the more frequently it will be displayed. For example, on a site with an average of 1 impression per second, if you have two ads, one with a priority of 0 and another with a priority of 100, the first ad will be displayed 100 times more frequently than the second ad.

=head4 url

The URL that the user will be directed to when clicking on the ad. This is used in text and image based ads.

=head4 clicksBought

The number of clicks that have been purchased for this ad.

=head4 impressionsBought

The number of times the user has paid for this ad to be displayed on the site.

=cut

sub set {
	my $self = shift;
	my $properties = shift || {};
	$self->{_properties}{title} = $properties->{title} || $self->{_properties}{title} || "Untitled";
	$self->{_properties}{clicksBought} = $properties->{clicksBought} || $self->{_properties}{clicksBought};
	$self->{_properties}{impressionsBought} = $properties->{impressionsBought} || $self->{_properties}{impressionsBought};
	$self->{_properties}{url}    = exists $properties->{url}    ? $properties->{url}    : $self->{_properties}{url};
	$self->{_properties}{adText} = exists $properties->{adText} ? $properties->{adText} : $self->{_properties}{adText};
	$self->{_properties}{adText} = $properties->{adText} || $self->{_properties}{adText};
	$self->{_properties}{storageId} = $properties->{storageId} || $self->{_properties}{storageId};
	$self->{_properties}{richMedia} = $properties->{richMedia} || $self->{_properties}{richMedia};
	$self->{_properties}{ownerUserId} = $properties->{ownerUserId} || $self->{_properties}{ownerUserId} || "3";
	$self->{_properties}{isActive} = exists $properties->{isActive} ? $properties->{isActive} : $self->{_properties}{isActive};
	$self->{_properties}{type} = $properties->{type} || $self->{_properties}{type} || "text";
	$self->{_properties}{borderColor} = $properties->{borderColor} || $self->{_properties}{borderColor} || "#000000";
	$self->{_properties}{textColor} = $properties->{textColor} || $self->{_properties}{textColor} || "#000000";
	$self->{_properties}{backgroundColor} = $properties->{backgroundColor} || $self->{_properties}{backgroundColor} || "#ffffff";
	$self->{_properties}{priority} = exists $properties->{priority} ? $properties->{priority} : $self->{_properties}{priority};
	# prerender the ad for faster display
	my $adSpace = WebGUI::AdSpace->new($self->session, $self->get("adSpaceId"));
    if ($self->get("type") eq "text") {
        $self->{_properties}{renderedAd} =
            q{<div style="position:relative; width:} . ($adSpace->get("width")-2) . q{px; height:}
            . ($adSpace->get("height")-2) . q{px; margin:0px; overflow:hidden; border:solid }
            . $self->get("borderColor") . q{ 1px;"><a href='#' onclick="window.location.assign('}
            . $self->session->url->gateway(undef, "op=clickAd;id=".$self->getId)
            . q{')" style="position:absolute; padding: 3px; top:0px; left:0px; width:100%; height:100%; z-index:10;}
            . q{ display:block; text-decoration:none; vertical-align:top; background-color:}
            . $self->get("backgroundColor") . q{; font-size: 13px; font-weight: normal;"><b><span style="color:}
            . $self->get("textColor") . q{;">} . $self->get("title")
            . q{</span></b><br /><span style="color:} . $self->get("textColor") . q{;">}
            . $self->get("adText") . q{</span></a></div>};
    }
    elsif ($self->get("type") eq "image") {
        my $storage = WebGUI::Storage->get($self->session, $self->get("storageId"));
        $self->{_properties}{renderedAd} =
            q{<div style="position:relative; width:} . $adSpace->get("width") . q{px; height:}
            . $adSpace->get("height") . q{px; margin:0px; overflow:hidden; border:0px;"><a href="#" }
            . q{onclick="window.location.assign('} .$self->session->url->gateway(undef, "op=clickAd;id=".$self->getId)
            . q{')" style="position:absolute; padding: }
            . q{0px; top:0px; left:0px; width:100%; height:100%; z-index:10; display:block; text-decoration:none; }
            . q{vertical-align:top;"><img }
            . q{src="} . $storage->getUrl($storage->getFiles->[0]) . q{" alt="} . $self->get("title")
            . q{" style="z-index:0;position:relative;border-style:none;border: 0px;" /></a></div>};
    }
    elsif ($self->get("type") eq "rich") {
		my $ad = $self->get("richMedia");
		WebGUI::Macro::process($self->session, \$ad);
		$self->{_properties}{renderedAd} = $ad;
	}
	$self->session->db->setRow("advertisement","adId",$self->{_properties});
}

1;

