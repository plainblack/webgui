package WebGUI::Asset::Sku::EMSTicket;

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
use Moose;
use WebGUI::Definition::Asset;
extends 'WebGUI::Asset::Sku';
define assetName           => ['ems ticket', 'Asset_EMSTicket'];
define icon                => 'EMSTicket.gif';
define tableName           => 'EMSTicket';
property price => (
            tab             => "shop",
            fieldType       => "float",
            default         => 0.00,
            label           => ["price", 'Asset_EMSTicket'],
            hoverHelp       => ["price help", 'Asset_EMSTicket'],
         );
property seatsAvailable => (
            tab             => "shop",
            fieldType       => "integer",
            default         => 25,
            label           => ["seats available", 'Asset_EMSTicket'],
            hoverHelp       => ["seats available help", 'Asset_EMSTicket'],
         );
property eventNumber => (
            tab             => "properties",
            fieldType        => "integer",
            customDrawMethod=> 'drawEventNumberField',
            label           => ["event number", 'Asset_EMSTicket'],
            hoverHelp       => ["event number help", 'Asset_EMSTicket'],
         );
property startDate => (
            noFormPost      => 1,
            fieldType       => "hidden",
            builder         => '_startDate_builder',
            lazy            => 1,
            label           => ["add/edit event start date", 'Asset_EMSTicket'],
            hoverHelp       => ["add/edit event start date help", 'Asset_EMSTicket'],
            autoGenerate    => 0,
         );
sub _startDate_builder {
    my $session = shift->session;
	my $date = WebGUI::DateTime->new($session, time());
    return $date->toDatabase,
}
property duration => (
            tab             => "properties",
            fieldType       => "float",
            default         => 1.0,
            subtext         => ['hours', 'Asset_EMSTicket'],
            label           => ["duration", 'Asset_EMSTicket'],
            hoverHelp       => ["duration help", 'Asset_EMSTicket'],
         );
property location => (
            fieldType        => "combo",
            tab             => "properties",
            customDrawMethod=> 'drawLocationField',
            label           => ["location", 'Asset_EMSTicket'],
            hoverHelp       => ["location help", 'Asset_EMSTicket'],
         );
property relatedBadgeGroups => (
            tab             => "properties",
            fieldType        => "checkList",
            customDrawMethod=> 'drawRelatedBadgeGroupsField',
            label           => ["related badge groups", 'Asset_EMSTicket'],
            hoverHelp       => ["related badge groups ticket help", 'Asset_EMSTicket'],
         );
property relatedRibbons => (
            tab             => "properties",
            fieldType        => "checkList",
            customDrawMethod=> 'drawRelatedRibbonsField',
            label           => ["related ribbons", 'Asset_EMSTicket'],
            hoverHelp       => ["related ribbons help", 'Asset_EMSTicket'],
         );
property eventMetaData => (
            noFormPost      => 1,
            fieldType       => "hidden",
            default         => '{}',
         );

use JSON ();
use WebGUI::Utility;

=head1 NAME

Package WebGUI::Asset::Sku::EMSTicket

=head1 DESCRIPTION

A ticket for the Event Manager. Tickets allow you into invidivual events at a convention.

=head1 SYNOPSIS

use WebGUI::Asset::Sku::EMSTicket;

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 addToCart ( {badgeId=>$badgeId })

Does some bookkeeping to keep track of limited quantities of tickets that are available, then adds to cart.

=cut

around addToCart => sub {
	my ($orig, $self, $badgeInfo) = @_;
	my $db = $self->session->db;
	my @params = ($badgeInfo->{badgeId},$self->getId);
	# don't let them add a ticket they already have
	unless ($db->quickScalar("select count(*) from EMSRegistrantTicket where badgeId=? and ticketAssetId=?",\@params)) {
		$db->write("insert into EMSRegistrantTicket (badgeId, ticketAssetId) values (?,?)", \@params);
		$self->$orig($badgeInfo);
	}
};

#-------------------------------------------------------------------

=head2 drawEventNumberField ()

Draws the field for the eventNumber property.

=cut

sub drawEventNumberField {
	my ($self, $params) = @_;
	my $default = $self->session->db->quickScalar("select max(eventNumber)+1 from EMSTicket left join asset using (assetId)
		where parentId=?",[$self->parentId]);
	return WebGUI::Form::integer($self->session, {
		name			=> $params->{name},
		value			=> $self->get($params->{name}),
		defaultValue	=> $default,
		});
}

#-------------------------------------------------------------------

=head2 drawLocationField ()

Draws the field for the location property.

=cut

sub drawLocationField {
	my ($self, $params) = @_;
	my $options = $self->session->db->buildHashRef("select distinct(location) from EMSTicket left join asset using (assetId)
		where parentId=? order by location",[$self->parentId]);
	return WebGUI::Form::combo($self->session, {
		name	=> 'location',
		value	=> $self->location,
		options	=> $options,
		});
}

#-------------------------------------------------------------------

=head2 drawRelatedBadgeGroupsField ()

Draws the field for the relatedBadgeGroups property.

=cut

sub drawRelatedBadgeGroupsField {
	my ($self, $params) = @_;
	return WebGUI::Form::checkList($self->session, {
		name		=> $params->{name},
		value		=> $self->get($params->{name}),
		vertical	=> 1,
		options		=> $self->getParent->getBadgeGroups,
		});
}

#-------------------------------------------------------------------

=head2 drawRelatedRibbonsField ()

Draws the field for the relatedRibbons property.

=cut

sub drawRelatedRibbonsField {
	my ($self, $params) = @_;
	my %ribbons = ();
	foreach my $ribbon (@{$self->getParent->getRibbons}) {
		$ribbons{$ribbon->getId} = $ribbon->getTitle;
	}
	return WebGUI::Form::checkList($self->session, {
		name		=> $params->{name},
		value		=> $self->get($params->{name}),
		vertical	=> 1,
		options		=> \%ribbons,
		});
}

#-------------------------------------------------------------------

=head2 getAddToCartForm

Returns a button to take the user to the view screen.

=cut

sub getAddToCartForm {
    my $self    = shift;
    my $session = $self->session;
    my $i18n = WebGUI::International->new($session, 'Asset_Sku');
    return
        WebGUI::Form::formHeader($session, {action => $self->getUrl})
      . WebGUI::Form::hidden(    $session, {name => 'func', value => 'view'})
      . WebGUI::Form::submit(    $session, {value => $i18n->get('see more')})
      . WebGUI::Form::formFooter($session)
      ;}

#-------------------------------------------------------------------

=head2 getConfiguredTitle

Returns title + badgeholder name.

=cut

sub getConfiguredTitle {
    my $self = shift;
	my $name = $self->session->db->quickScalar("select name from EMSRegistrant where badgeId=?",[$self->getOptions->{badgeId}]);
    return $self->getTitle." (".$name.")";
}

#-------------------------------------------------------------------

=head2 getEditForm ()

Extended to support event metadata.

=cut

sub getEditForm {
	my $self = shift;
	my $form = $self->SUPER::getEditForm(@_);
	my $metadata = $self->getEventMetaData;
    my $i18n = WebGUI::International->new($self->session, "Asset_EventManagementSystem");
    my $date = WebGUI::DateTime->new($self->session, time());

	foreach my $field (@{$self->getParent->getEventMetaFields}) {
		$form->getTab("meta")->DynamicField(
			name			=> "eventmeta ".$field->{label},
			value			=> $metadata->{$field->{label}},
			defaultValue	=> $field->{defaultValues},
			options			=> $field->{possibleValues},
			fieldType		=> $field->{dataType},
			label			=> $field->{label},
			);
	}
    $form->getTab("properties")->DateTime(
            name            => "startDate", 
            label           => $i18n->get("add/edit event start date"),
            hoverHelp       => $i18n->get("add/edit event start date help"),
            timeZone        => $self->getParent->get("timezone"),
            defaultValue    => $date->toDatabase,
            value           => $self->startDate,
    );
	return $form;
}


#-------------------------------------------------------------------

=head2 getEventMetaData

Decodes and returns metadata properties as a hashref.

=head3 key

If specified, returns a single value for the key specified.

=cut

sub getEventMetaData {
	my $self = shift;
	my $key = shift;
	my $metadata = JSON->new->decode($self->eventMetaData || '{}');
	if (defined $key) {
		return $metadata->{$key};
	}
	return $metadata;
}

#-------------------------------------------------------------------

=head2 getMaxAllowedInCart

Returns 1.

=cut

sub getMaxAllowedInCart {
	return 1;
}

#-------------------------------------------------------------------

=head2 getPrice

Returns the value of the price field, after applying ribbon discounts.

=cut

sub getPrice {
    my $self = shift;
	my @ribbonIds = split("\n", $self->relatedRibbons);
	my $price = $self->price;
	my $discount = 0;
	my $badgeId = $self->getOptions->{badgeId};
	my $ribbonId = $self->session->db->quickScalar("select ribbonAssetId from EMSRegistrantRibbon where badgeId=? limit 1",[$badgeId]);
	if (defined $ribbonId && isIn($ribbonId, @ribbonIds)) {
		my $ribbon = WebGUI::Asset->newById($self->session, $ribbonId);
		$discount = $ribbon->percentageDiscount;
	}
	else {
		foreach my $item (@{$self->getCart->getItemsByAssetId(\@ribbonIds)}) {
			if ($item->get('options')->{badgeId} eq $badgeId) {
				my $ribbon = $item->getSku;
				$discount = $ribbon->percentageDiscount;
				last;
			}
		}
	}
	$price -= ($price * $discount / 100);
    return $price;
}

#-------------------------------------------------------------------

=head2 getQuantityAvailable

Returns seatsAvailable minus the count from the EMSRegistrantTicket table.

=cut

sub getQuantityAvailable {
	my $self = shift;
	my $seatsTaken = $self->session->db->quickScalar("select count(*) from EMSRegistrantTicket where ticketAssetId=?",[$self->getId]);
    return $self->seatsAvailable - $seatsTaken;
}

#-------------------------------------------------------------------

=head2 indexContent ( )

Adding location and eventNumber as a keyword. See WebGUI::Asset::indexContent() for additonal details. 

=cut

around indexContent => sub {
	my $orig = shift;
	my $self = shift;
	my $indexer = $self->$orig(@_);
    $indexer->addKeywords($self->location.' '.$self->eventNumber);
	return $indexer;
};



#-------------------------------------------------------------------

=head2 onCompletePurchase

Marks the ticket as purchased.

=cut

sub onCompletePurchase {
	my ($self, $item) = @_;
	$self->session->db->write("update EMSRegistrantTicket set purchaseComplete=1, transactionItemId=? where ticketAssetId=? and badgeId=?",
		[$item->getId, $self->getId, $self->getOptions->{badgeId}]);
	return undef;
}

#-------------------------------------------------------------------

=head2 onRefund ( item)

Destroys the ticket so that it can be resold.

=cut

sub onRefund {
	my ($self, $item) = @_;
	$self->session->db->write("delete from EMSRegistrantTicket where transactionItemId=?",[$item->getId]);
	return undef;
}

#-------------------------------------------------------------------

=head2 onRemoveFromCart

Frees up the ticket to be purchased by someone else.

=cut

sub onRemoveFromCart {
	my ($self, $item) = @_;
	$self->session->db->write("delete from EMSRegistrantTicket where ticketAssetId=? and badgeId=?",
		[$self->getId, $self->getOptions->{badgeId}]);
}

#-------------------------------------------------------------------

=head2 processEditForm ( )

Extended to support event meta fields.

=cut

sub processEditForm {
	my $self = shift;
	$self->SUPER::processEditForm(@_);
	my $form = $self->session->form;
	my %metadata = ();
	foreach my $field (@{$self->getParent->getEventMetaFields}) {
		$metadata{$field->{label}} = $form->process('eventmeta '.$field->{label}, $field->{dataType},
			{ defaultValue => $field->{defaultValues}, options => $field->{possibleValues}});
	}
    my $date = WebGUI::DateTime->new($self->session, time())->toDatabase;
    my $startDate = $form->process('startDate', "dateTime", $date, 
        { defaultValue => $date, timeZone => $self->getParent->timezone});
	$self->update({eventMetaData => JSON->new->encode(\%metadata), startDate => $startDate});
}

#-------------------------------------------------------------------

=head2 purge

Deletes all ticket purchases of this type. No refunds are given.

=cut

override purge => sub {
	my $self = shift;
	$self->session->db->write("delete from EMSRegistrantTicket where ticketAssetId=?",[$self->getId]);
	super();
};

#-------------------------------------------------------------------

=head2 setEventMetaData

Encodes the metadata for this event into an asset property.

=head3 properties

A hash reference containing all the metadata properties to set.

=cut

sub setEventMetaData {
	my $self = shift;
	my $properties = shift;
	$self->update({eventMetaData => JSON->new->encode($properties)});
}

#-------------------------------------------------------------------

=head2 view

Displays the ticket description.

=cut

sub view {
	my ($self) = @_;
	
	# build objects we'll need
	my $i18n = WebGUI::International->new($self->session, "Asset_EventManagementSystem");
	my $form = $self->session->form;
		
	
	# render the page;
	my $output = '<h1>'.$self->getTitle.' ('.$self->eventNumber.')</h1>'
		.'<p>'.$self->description.'</p>'
		.'<p>'.$self->startDate.'</p>';

	# build the add to cart form
	if ($form->get('badgeId') ne '') {
		my $addToCart = WebGUI::HTMLForm->new($self->session, action=>$self->getUrl);
		$addToCart->hidden(name=>"func", value=>"addToCart");
		$addToCart->hidden(name=>"badgeId", value=>$form->get('badgeId'));
		$addToCart->submit(value=>$i18n->get('add to cart','Shop'), label=>$self->getPrice);
		$output .= $addToCart->print;		
	}
		
	return $output;
}

#-------------------------------------------------------------------

=head2 www_addToCart

Takes form variable badgeId and add the ticket to the cart.

=cut

sub www_addToCart {
	my ($self) = @_;
	return $self->session->privilege->noAccess() unless $self->getParent->canView;
	my $badgeId = $self->session->form->get('badgeId');
	$self->addToCart({badgeId=>$badgeId});
	return $self->getParent->www_buildBadge($badgeId);
}

#-------------------------------------------------------------------

=head2 www_delete

Override to return to appropriate page.

=cut

sub www_delete {
	my ($self) = @_;
	return $self->session->privilege->insufficient() unless ($self->canEdit && $self->canEditIfLocked);
    return $self->session->privilege->vitalComponent() if $self->isSystem;
    return $self->session->privilege->vitalComponent() if (isIn($self->getId, $self->session->setting->get("defaultPage"), $self->session->setting->get("notFoundPage")));
    $self->trash;
	return $self->getParent->www_buildBadge(undef,'tickets');
}


#-------------------------------------------------------------------

=head2 www_edit ()

Displays the edit form.

=cut

sub www_edit {
	my ($self) = @_;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	return $self->session->privilege->locked() unless $self->canEditIfLocked;
	$self->session->style->setRawHeadTags(q|
		<style type="text/css">
		.forwardButton {
			background-color: green;
			color: white;
			font-weight: bold;
			padding: 3px;
		}
		.backwardButton {
			background-color: red;
			color: white;
			font-weight: bold;
			padding: 3px;
		}
		</style>
						   |);	
	my $i18n = WebGUI::International->new($self->session, "Asset_EventManagementSystem");
	my $form = $self->getEditForm;
	$form->hidden({name=>'proceed', value=>'viewAll'});
	return $self->processStyle('<h1>'.$i18n->get('ems ticket').'</h1>'.$form->print);
}

#-------------------------------------------------------------------

=head2 www_viewAll ()

Displays the list of tickets in the parent.

=cut

sub www_viewAll {
	my $self = shift;
	return $self->getParent->www_buildBadge(undef,"tickets");
}



__PACKAGE__->meta->make_immutable;
1;
