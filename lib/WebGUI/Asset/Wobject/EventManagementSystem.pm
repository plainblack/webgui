package WebGUI::Asset::Wobject::EventManagementSystem;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use base 'WebGUI::Asset::Wobject';
use Tie::IxHash;
use WebGUI::HTMLForm;
use JSON;
use Digest::MD5;
use WebGUI::Workflow::Instance;
use WebGUI::Cache;
use WebGUI::International;
use WebGUI::Operation::Commerce;
use WebGUI::Commerce::ShoppingCart;
use WebGUI::Commerce::Item;
use WebGUI::Utility;
use Text::CSV_XS;
use IO::Handle;
use File::Temp 'tempfile';
use Data::Dumper;



#-------------------------------------------------------------------
sub _getFieldHash {
	my $self = shift;
	return $self->{_fieldHash} if ($self->{_fieldHash});

	my %hash;
	tie %hash, "Tie::IxHash";
	my $i18n = WebGUI::International->new($self->session,'Asset_EventManagementSystem');
	%hash = (
		"eventName"=>{
			name=>$i18n->get('add/edit event title'),
			type=>"text",
			compare=>"text",
			method=>"text",
			columnName=>"title",
			tableName=>"p",
			initial=>1
		},
		"eventDescription"=>{
			name=>$i18n->get("add/edit event description"),
			type=>"text",
			compare=>"text",
			method=>"text",
			columnName=>"description",
			tableName=>"p",
			initial=>1
		},
		"maxAttendees"=>{
			name=>$i18n->get("add/edit event maximum attendees"),
			type=>"text",
			compare=>"numeric",
			method=>"integer",
			columnName=>"maximumAttendees",
			tableName=>"e",
			initial=>1
		},
		"seatsAvailable"=>{
			name=>$i18n->get("seats available"),
			type=>"text",
			method=>"integer",
			compare=>"numeric",
			calculated=>1,
			initial=>1
		},
		"price"=>{
			name=>$i18n->get("price"),
			type=>"text",
			compare=>"numeric",
			method=>"float",
			columnName=>"price",
			tableName=>"p",
			initial=>1
		},
		"startDate"=>{
			name=>$i18n->get("add/edit event start date"),
			type=>"dateTime",
			compare=>"numeric",
			method=>"dateTime",
			columnName=>"startDate",
			tableName=>"e",
			initial=>1
		},
		"endDate"=>{
			name=>$i18n->get("add/edit event end date"),
			type=>"dateTime",
			compare=>"numeric",
			method=>"dateTime",
			columnName=>"endDate",
			tableName=>"e",
			initial=>1
		},
		"sku"=>{
			name=>$i18n->get("Event Number"),
			type=>"text",
			compare=>"numeric",
			method=>"text",
			columnName=>"sku",
			tableName=>"p",
			initial=>1
		},
		"requirement"=>{
			name=>$i18n->get('add/edit event required events'),
			type=>"select",
			list=>{''=>$i18n->get('select one'),$self->_getAllEvents()},
			compare=>"boolean",
			method=>"selectBox",
			calculated=>1,
			initial=>0
		}
	);
	# Add custom metadata fields to the list, matching the types up
	# automatically.
	my $fieldList = $self->getEventMetaDataArrayRef;
	foreach my $field (@{$fieldList}) {
	    next unless $field->{visible};
		my $dataType = $field->{dataType};
		my $compare = $self->_matchTypes($dataType);
		my $type;
		if ($dataType =~ /^date/i) {
			$type = lcfirst($dataType);
		} elsif ($compare eq 'text' || $compare eq 'numeric') {
			$type = 'text';
		} else {
			$type = 'select';
		}
		$hash{$field->{fieldId}} = {
			name=>$field->{label},
			type=>$type,
			method=>$dataType,
			initial=>$field->{autoSearch},
			compare=>$compare,
			calculated=>1,
			metadata=>1
		};
		if ($hash{$field->{fieldId}}->{type} eq 'select') {
			$hash{$field->{fieldId}}->{list} = $self->_matchPairs($field->{possibleValues});
		}
	}
	$self->{_fieldHash} = \%hash;
	return $self->{_fieldHash};
}

#-------------------------------------------------------------------
sub _acWrapper {
	my $self = shift;
	my $html = shift;
	my $title = shift;
	my $i18n = WebGUI::International->new($self->session,'Asset_EventManagementSystem');
	my $ac = $self->getAdminConsole;
	$ac->setHelp('add/edit event','Asset_EventManagementSystem')
		unless $ac->getHelp;
	$ac->addSubmenuItem($self->getUrl('func=search'),$i18n->get("manage events"));
	$ac->addSubmenuItem($self->getUrl('func=manageEventMetadata'), $i18n->get('manage event metadata'));
	$ac->addSubmenuItem($self->getUrl('func=managePrereqSets'), $i18n->get('manage prerequisite sets'));
	$ac->addSubmenuItem($self->getUrl('func=manageRegistrants'), $i18n->get('manage registrants'));
	$ac->addSubmenuItem($self->getUrl('func=manageDiscountPasses'), $i18n->get('manage discount passes'));
	$ac->addSubmenuItem($self->getUrl('func=importEvents'), $i18n->get('import events'));
	$ac->addSubmenuItem($self->getUrl('func=exportEvents'), $i18n->get('export events'));
	return $ac->render($html,$title);
}

#-------------------------------------------------------------------

sub _matchPairs {
	my $self = shift;
	my $options = shift;
	my %hash;
	tie %hash, 'Tie::IxHash';
	my $i18n = WebGUI::International->new($self->session, 'Asset_EventManagementSystem');
	$hash{''} = $i18n->get('select one');
	foreach (split("\n",$options)) {
		my $val = $_;
		#$val =~ s/\s//g;
		$val =~ s/\r//g;
		$val =~ s/\n//g;
		$hash{$val} = $val;
	}
	return \%hash;
}

#-------------------------------------------------------------------

sub _matchTypes {
	my $self = shift;
	my $dataType = lc(shift);
	return 'text' if (
		WebGUI::Utility::isIn($dataType, qw(
			codearea
			email
			htmlarea
			phone
			text
			textarea
			url
			zipcode
		))
	);
	return 'numeric' if (
		WebGUI::Utility::isIn($dataType, qw(
			date
			datetime
			float
			integer
			interval
		))
	);
	return 'boolean' if (
		WebGUI::Utility::isIn($dataType, qw(
			checkbox
			combo
			selectlist
			checklist
			contenttype
			databaselink
			fieldtype
			group
			ldaplink
			radio
			radiolist
			selectbox
			template
			timezone
			yesno
		))
	);
	return 'text';
}

#-------------------------------------------------------------------

sub _getAllEvents {
	my $self = shift;
	my $conditionalWhere;
	if ($self->get("globalPrerequisites") == 0) {
		$conditionalWhere = "and e.assetId=".$self->session->db->quote($self->get('assetId'));
	}
	my $sql = "select p.productId, p.title from products as p, EventManagementSystem_products as e
		   where p.productId = e.productId $conditionalWhere";
	return $self->session->db->buildHash($sql);
}

#-------------------------------------------------------------------
#
# Temporary Shopping Cart to store subevent selections for prerequisite and conflict checking
# Contents are moved to real shopping cart after attendee information is entered and the scratchCart gets emptied.
#
sub addToScratchCart {
	my $self = shift;
	my $event = shift;
	my $scratchCart = $self->session->scratch->get('EMS_scratch_cart');
	my @eventsInCart = split("\n",$scratchCart);
	my ($isApproved) = $self->session->db->quickArray("select approved from EventManagementSystem_products where productId = ?",[$event]);
	return undef unless $isApproved;
	unless (scalar(@eventsInCart) || $scratchCart) {
		# the cart is empty, so check if this is a master event or not.
		my ($isChild) = $self->session->db->quickArray("select prerequisiteId from EventManagementSystem_products where productId = ?",[$event]);
		return undef if $isChild;
		$self->session->scratch->set('currentMainEvent',$event);
		$self->session->scratch->set('EMS_scratch_cart', $event);
		return $event;
	}
	# check if event is actually available.
	my ($numberRegistered) = $self->session->db->quickArray("select count(*) from EventManagementSystem_registrations as r, EventManagementSystem_purchases as p, transaction as t where t.transactionId=p.transactionId and t.status='Completed' and r.purchaseId = p.purchaseId and r.returned=0 and r.productId=?",[$event]);
	my ($maxAttendees) = $self->session->db->quickArray("select maximumAttendees from EventManagementSystem_products where productId=?",[$event]);
	return undef unless ($self->canApproveEvents || ($maxAttendees > $numberRegistered));

	my $bid = $self->session->scratch->get('currentBadgeId');
	my @pastEvents = ($bid)?$self->session->db->buildArray("select r.productId from EventManagementSystem_registrations as r, EventManagementSystem_purchases as p, transaction as t where r.returned=0 and r.badgeId=? and t.transactionId=p.transactionId and t.status='Completed' and p.purchaseId=r.purchaseId group by productId",[$bid]):();
	push(@eventsInCart, $event) unless (isIn($event,@eventsInCart) || isIn($event,@pastEvents));

	$self->session->scratch->delete('EMS_scratch_cart');
	$self->session->scratch->set('EMS_scratch_cart', join("\n", @eventsInCart));
}

#-------------------------------------------------------------------

sub canApproveEvents {
	my $self = shift;
	return $self->session->user->isInGroup($self->get("groupToApproveEvents"));
}


#-------------------------------------------------------------------

sub canAddEvents {
	my $self = shift;
	return $self->session->user->isInGroup($self->get("groupToAddEvents"));
}


#-------------------------------------------------------------------

sub buildMenu {
	my $self = shift;
	my $var = shift;
	my $i18n = WebGUI::International->new($self->session,'Asset_EventManagementSystem');
	my $fields = $self->_getFieldHash();
	my $counter = 0;
	my $js = "var filterList = {\n";
	foreach my $fieldId (keys %{$fields}) {
		my $field = $fields->{$fieldId};
		next if $fieldId eq 'requirement';
		$js .= ",\n" if($counter++ > 0);
		my $fieldName = $field->{name};
		my $fieldType = $field->{type};
		my $compareType = $field->{compare};
		my $autoSearch = $field->{initial};
		$js .= qq|"$fieldId": {|;
		$js .= qq| "name":"$fieldName"|;
		$js .= qq| ,"type":"$fieldType"|;
		$js .= qq| ,"compare":"$compareType"|;
		$js .= qq| ,"autoSearch":"$autoSearch"|;
		if($fieldType eq "select") {
			my $list = $field->{list};
			my $fieldList = "";
			foreach my $key (keys %{$list}) {
				$fieldList .= "," if($fieldList ne "");
                my $js_key = $key;
                $js_key =~ s/\\/\\\\/g;
                $js_key =~ s/"/\\"/g;
				my $value = $list->{$key};
                $value =~ s/\\/\\\\/g;
                $value =~ s/"/\\"/g;
				$fieldList .= qq|"$js_key":"$value"|
			}
			$js .= qq| ,"list":{ $fieldList }|;
		}
		$js .= q| }|;
	}
	$js .= "\n};\n";

	$var->{'search.filters.options'} = $js;
	$var->{'search.data.url'} = $self->getUrl("func=search");
}

#-------------------------------------------------------------------

=head2 checkConflicts ( )

Check for scheduling conflicts in events in the user's cart.  A conflict is defined as
whenever two events have overlapping times.

=cut

sub checkConflicts {
	my $self = shift;
#	my $eventsInCart = $self->getEventsInCart;
	my $checkSingleEvent = shift;
	my $eventsInCart = $self->getEventsInScratchCart;
	# $self->session->errorHandler->warn(Dumper($eventsInCart));
	my @schedule;

	# Get schedule info for events in cart and sort asc by start date
	my $sth = $self->session->db->read("
		select productId, startDate, endDate from EventManagementSystem_products
		where productId in (".$self->session->db->quoteAndJoin($eventsInCart).")
		order by startDate"
	);

	# Build our schedule
	while (my $scheduleData = $sth->hashRef) {

		# make sure it's a subevent... 
		my ($isSubEvent) = $self->session->db->quickArray("
			select count(*) from EventManagementSystem_products
			where (prerequisiteId is not null and prerequisiteId != '') and productId=?", [$scheduleData->{productId}]
		);
		next unless ($isSubEvent);

		push(@schedule, $scheduleData);
	}
	my $singleData = {};
	$singleData = $self->session->db->quickHashRef("select productId, startDate, endDate from EventManagementSystem_products where productId=?", [$checkSingleEvent]) if $checkSingleEvent;

	# Check the schedule for conflicts
	for (my $i=0; $i < scalar(@schedule); $i++) {
		next if ($i == 0 && !$checkSingleEvent);
		if ($checkSingleEvent) {
			return 1 if ($singleData->{startDate} < $schedule[$i]->{endDate} && $singleData->{endDate} > $schedule[$i]->{startDate});
		}	else {
			unless ($schedule[$i]->{startDate} > $schedule[$i-1]->{endDate}) {
				 #conflict
				return [{ 'event1'    => $schedule[$i]->{productId},
					  'event2'    => $schedule[$i-1]->{productId},
					  'type'      => 'conflict'
				       }]; 	
			}
		}
	}
	return 0 if $checkSingleEvent;
	return [];
}

#-------------------------------------------------------------------

=head2 checkRequiredFields ( [ dataHref ] [, recNum ] )

Check for null form fields.

Returns an array reference containing error messages

=head3 dataHref

An href with the data for the event that we want to check. If absent, then the current form submission is used.

=head3 recNum

The number of the record, for error reporting

=cut

sub checkRequiredFields {
  my $self = shift;
  my $event_data_href = shift || $self->session->form->paramsHashRef();
  my $rec_num = shift || '';

  my $requiredFields = $self->getRequiredFields();
  my @errors;

  foreach my $requiredField (keys %{$requiredFields}) {
	if ($event_data_href->{$requiredField} eq "") {
      push(@errors, {
        type  	  => "nullField$rec_num",
        fieldName => $requiredFields->{"$requiredField"}
        }
      );
    }

  }

  return \@errors;    
}

#-------------------------------------------------------------------
sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my %properties;
	tie %properties, 'Tie::IxHash';
	my $i18n = WebGUI::International->new($session,'Asset_EventManagementSystem');
	%properties = (
			displayTemplateId =>{
				fieldType=>"template",
				defaultValue=>'EventManagerTmpl000001',	
				tab=>"display",
				namespace=>"EventManagementSystem",
                		hoverHelp=>$i18n->get('display template description'),
                		label=>$i18n->get('display template')
				},
			checkoutTemplateId =>{
				fieldType=>"template",
				defaultValue=>'EventManagerTmpl000003',
				tab=>"display",
				namespace=>"EventManagementSystem_checkout",
                		hoverHelp=>$i18n->get('checkout template description'),
                		label=>$i18n->get('checkout template')
				},
			managePurchasesTemplateId =>{
				fieldType=>"template",
				defaultValue=>'EventManagerTmpl000004',
				tab=>"display",
				namespace=>"EventManagementSystem_managePurchas",
                		hoverHelp=>$i18n->get('manage purchases template description'),
                		label=>$i18n->get('manage purchases template')
				},
			viewPurchaseTemplateId =>{
				fieldType=>"template",
				defaultValue=>'EventManagerTmpl000005',
				tab=>"display",
				namespace=>"EventManagementSystem_viewPurchase",
                		hoverHelp=>$i18n->get('view purchase template description'),
                		label=>$i18n->get('view purchase template')
				},
			searchTemplateId =>{
				fieldType=>"template",
				defaultValue=>'EventManagerTmpl000006',
				tab=>"display",
				namespace=>"EventManagementSystem_search",
                		hoverHelp=>$i18n->get('search template description'),
                		label=>$i18n->get('search template')
				},
			paginateAfter =>{
				fieldType=>"integer",
				defaultValue=>10,
				tab=>"display",
				hoverHelp=>$i18n->get('paginate after description'),
				label=>$i18n->get('paginate after')
				},
			groupToAddEvents =>{
				fieldType=>"group",
				defaultValue=>3,
				tab=>"security",
				hoverHelp=>$i18n->get('group to add events description'),
				label=>$i18n->get('group to add events')
				},
			groupToApproveEvents =>{
				fieldType=>"group",
				defaultValue=>3,
				tab=>"security",
				hoverHelp=>$i18n->get('group to approve events description'),
				label=>$i18n->get('group to approve events')
				},
			globalPrerequisites  =>{
				fieldType=>"yesNo",
				defaultValue=>1,
				tab=>"properties",
				label=>$i18n->get('global prerequisite'),
				hoverHelp=>$i18n->get('global prerequisite description')
				},
			globalMetadata  =>{
				fieldType=>"yesNo",
				defaultValue=>1,
				tab=>"properties",
				label=>$i18n->get('global metadata'),
				hoverHelp=>$i18n->get('global metadata description')
				},
		);
	push(@{$definition}, {
		assetName=>$i18n->get('assetName'),
		icon=>'ems.gif',
		autoGenerateForms=>1,
		tableName=>'EventManagementSystem',
		className=>'WebGUI::Asset::Wobject::EventManagementSystem',
		properties=>\%properties
		});
	return $class->SUPER::definition($session,$definition);
}

#------------------------------------------------------------------

=head2 deleteBadge ( id )

Delete a badge.

=cut

sub deleteBadge {
    my $self = shift;
    my $id = shift;
	$self->deleteCollateral('EventManagementSystem_badges', 'badgeId', $id); 
}

#------------------------------------------------------------------

=head2 deleteEvent ( id )

Delete an event.

=cut

sub deleteEvent {
    my $self = shift;
    my $id = shift;
    my $db = $self->session->db;
    $self->deletePrereq($id);
	$self->deleteCollateral('EventManagementSystem_registrations', 'productId', $id);
	$self->deleteCollateral('EventManagementSystem_products', 'productId', $id);
	$self->deleteCollateral('products','productId',$id);
	$self->reorderCollateral('EventManagementSystem_products', 'productId');
}

#------------------------------------------------------------------

=head2 deleteMetaField ( id )

Delete a meta field, and thusly metadata associated with that field.

=cut

sub deleteMetaField {
    my $self = shift;
    my $id = shift;
	$self->deleteCollateral('EventManagementSystem_metaData', 'fieldId', $id); # deleteCollateral doesn't care about assetId.
	$self->deleteCollateral('EventManagementSystem_metaField', 'fieldId', $id);
	$self->reorderCollateral('EventManagementSystem_metaField', 'fieldId');
}


#------------------------------------------------------------------

=head2 deletePrereq ( id )

Delete a prerequisite.

=head3 id

a valid event/product id

=cut

sub deletePrereq {
    my $self = shift;
    my $id = shift;
	$self->deleteCollateral('EventManagementSystem_prerequisiteEvents', 'requiredProductId', $id);
}

#------------------------------------------------------------------

=head2 deletePrereqSet ( id )

Delete a prerequisite set.

=cut

sub deletePrereqSet {
    my $self = shift;
    my $id = shift;
	$self->deleteCollateral('EventManagementSystem_prerequisiteEvents', 'prerequisiteId', $id);
	$self->deleteCollateral('EventManagementSystem_prerequisites', 'prerequisiteId', $id);
    $self->session->db->write("update EventManagementSystem_product set prerequisiteId=null where
        prerequisiteId=?", [$id]);
}

#-------------------------------------------------------------------
sub emptyScratchCart {
	my $self = shift;	
	$self->session->scratch->delete('EMS_scratch_cart');
}

#-------------------------------------------------------------------

=head2 error ( errors, callback )

Generates error messages and calls specified method to display them.

=head3 errors

An array reference containing an error stack

=cut

=head3 callback

The method to call and pass the generated error messages to for display to the user

=cut

sub error {
	my $self = shift;
	my $errors = shift;
	my $callback = shift;
	my $i18n = WebGUI::International->new($self->session,'Asset_EventManagementSystem');
	my @errorMessages;

	foreach my $error (@$errors) {
		#Null Field Error
		if ($error->{type} =~ m/nullField(\d*)/) {
		  my $num = $1 || ''; # there's a record number stuck in here, if they're doing a batch import of events
		  if ($num) {
		  	push(@errorMessages, sprintf($i18n->get('null field error recnum'),$error->{fieldName},$num));
		  }
		  else {
		  	push(@errorMessages, sprintf($i18n->get('null field error'),$error->{fieldName}));
		  }
		}

		#General Error Message
		elsif ($error->{type} eq "general") {
		  push(@errorMessages, $error->{message});
		}

		#Scheduling Conflict
		elsif ($error->{type} eq "conflict") {
		  push(@errorMessages, $self->resolveConflictForm($error->{event1}, $error->{event2}));
		}

		elsif ($error->{type} eq "special") {
		  push(@errorMessages, unpack("u",$error->{message}));
		}
	}
	return $self->$callback(\@errorMessages);
}

#------------------------------------------------------------------

=head2 eventIsApproved ( eventId )

Returns approval status of a specified event

=head3 eventId

Id of event whose approval status you are trying to determine

=cut

sub eventIsApproved {
	my $self = shift;
	my $eventId = shift;
	my ($result) = $self->session->db->quickArray("select approved from EventManagementSystem_products where productId=?",[$eventId]);
	return ($result eq "1");
}

#------------------------------------------------------------------

=head2 getAssignedPrerequisites ( eventId )

Returns prerequisiteId of every prerequisite grouping assigned to eventId passed in.

=head3 eventId

Id of the event whose prerequisites you want returned

=cut

sub getAssignedPrerequisites {
	my $self = shift;
	my $eventId = shift;
	my $returnProductIdFlag = shift;
	my $sql;

	unless ($returnProductIdFlag) {
		$sql = "select prereqs.prerequisiteId, prereqs.operator from EventManagementSystem_prerequisites as prereqs, EventManagementSystem_products as p 
			where prereqs.prerequisiteId = p.prerequisiteId and p.productId=?";
	}
	else {
		$sql = "select prereqs.prerequisiteId, prereqs.operator from EventManagementSystem_prerequisites as prereqs, EventManagementSystem_products as p 
		   where where prereqs.prerequisiteId = p.prerequisiteId and p.productId=?";
	}

	return $self->session->db->buildHashRef($sql,[$eventId]); 
}

#------------------------------------------------------------------

=head2 getEventsInCart ( )

Returns an array ref of all items in the cart, by id.

=cut

sub getEventsInCart {
	my $self = shift;
	my $cart = WebGUI::Commerce::ShoppingCart->new($self->session);
	my ($cartItems) = $cart->getItems;

	my @eventsInCart = map { $_->{item}->id } @{ $cartItems };

	return \@eventsInCart;
}

#------------------------------------------------------------------
sub getEventsInScratchCart {
	my $self = shift;
	my @eventsInCart = split("\n",$self->session->scratch->get('EMS_scratch_cart'));
	return \@eventsInCart;
}

#------------------------------------------------------------------
sub getEventName {
	my $self = shift;
	my $eventId = shift;

	my ($eventName) = $self->session->db->quickArray("select title from products where productId=?",[$eventId]);

	return $eventName;
}


#------------------------------------------------------------------

=head2 getPrerequisiteEventList ( eventId )

Returns hash reference of EventId, Name pairs of events that qualify to be a specified Event Id's prerequisite

This method returns all events except for
 a) the event matching the eventId parameter passed in AND
 b) any events currently assigned as a prerequisite to the eventId parameter passed in
as a hash reference with the productId, and title

Checks property globalPrerequisites to determine if events from all defined Event Managers should be displayed
or only the events defined in this particular Event Manager

=head3 eventId

Id of the event that you want to return eligible prerequisites for

=cut

sub getPrerequisiteEventList {
	my $self = shift;
	my $eventId = shift;
	my $conditionalWhere;

	if ($self->get("globalPrerequisites") == 0) {
		$conditionalWhere = "and e.assetId=".$self->session->db->quote($self->get('assetId'));
	}

	my $sql = "select p.productId, p.title from products as p, EventManagementSystem_products as e
		   where p.productId = e.productId 
		         and p.productId !=".$self->session->db->quote($eventId)."
		         $conditionalWhere
		         and p.productId not in
		         (select requiredProductId from EventManagementSystem_prerequisites as p,
							EventManagementSystem_prerequisiteEvents as pe 
			  where p.prerequisiteId = pe.prerequisiteId 
			        and p.productId=".$self->session->db->quote($eventId).")";

	return $self->session->db->buildHashRef($sql);
}


#------------------------------------------------------------------

=head2 getEventMetaDataArrayRef (  )

Returns an arrayref of hash references of the metadata fields.

Checks $self->get("globalMetadata") by default; otherwise uses the first parameter.

=head3 useGlobalMetadata

Whether or not to use the asset's global setting, and the override.

=cut

sub getEventMetaDataArrayRef {
	my $self = shift;
	my $useGlobalMetadata = shift;
	my $productId = shift;
	$useGlobalMetadata = ($useGlobalMetadata)?$useGlobalMetadata:$self->get("globalMetadata");
	my $globalWhere = ($useGlobalMetadata == 0 || $useGlobalMetadata == 'false')?" where assetId='".$self->getId."'":'';
	return $self->getEventMetaDataFields($productId) if $productId;
	return $self->session->db->buildArrayRefOfHashRefs("select * from EventManagementSystem_metaField $globalWhere order by sequenceNumber, assetId");
}


#-------------------------------------------------------------------

=head2 getEventMetaDataFields ( productId )

Returns a hash reference containing all metadata field properties.

=head3 productId

Which product to get metadata for.

=cut

sub getEventMetaDataFields {
	my $self = shift;
	my $productId = shift;
	my $useGlobalMetadata = shift;
	my $globalWhere = ($useGlobalMetadata == 0 || $useGlobalMetadata == 'false')?" where f.assetId='".$self->getId."'":'';
	my $sql = "select f.*, d.fieldData
		from EventManagementSystem_metaField f
		left join EventManagementSystem_metaData d on f.fieldId=d.fieldId
		and d.productId=".$self->session->db->quote($productId)." $globalWhere
		order by f.sequenceNumber";
	tie my %hash, 'Tie::IxHash';
	my $sth = $self->session->db->read($sql);
	while( my $h = $sth->hashRef) {
		foreach(keys %$h) {
			$hash{$h->{fieldId}}{$_} = $h->{$_};
		}
	}
	$sth->finish;
	return \%hash;
}

#------------------------------------------------------------------

sub getBadgeSelector {
	my $self = shift;
	my $output;
	my $i18n = WebGUI::International->new($self->session, 'Asset_EventManagementSystem');
	my $selfName = ($self->session->var->get('userId') ne '1') ? $self->session->user->profileField('firstName').' '.$self->session->user->profileField('lastName').' ('.$i18n->get('you').')' : $i18n->get('create a badge for myself');
	$selfName = $i18n->get('create a badge for myself') if $selfName eq '  ('.$i18n->get('you').')';
	my %options;
	tie %options, 'Tie::IxHash';
	%options = (
		'thisIsI' => $selfName,
		'new' => $i18n->get('create a badge for someone else')
	);
	my $isAdmin = $self->canAddEvents;

	my $badges = {};
	my $me = $self->session->var->get('userId');
	my $addBadgeId = $self->session->scratch->get('EMS_add_purchase_badgeId');

	if ($isAdmin) {
		# all badges in the system.
		$badges = $self->session->db->buildHashRef("select badgeId, CONCAT(lastName,', ',firstName,' (',email,')') from EventManagementSystem_badges order by lastName");
	} elsif ($me eq '1') {
		#none
		$badges = {};
		%options = ();
	} else {
		#badges we have purchased.
		$badges = $self->session->db->buildHashRef("select b.badgeId, CONCAT(b.lastName,', ',b.firstName,' (',email,')') from EventManagementSystem_badges as b where b.userId='".$me."' or b.createdByUserId='".$me."' order by b.lastName");
	}
	if ($addBadgeId) {
		$badges = $self->session->db->buildHashRef("select badgeId, CONCAT(lastName,', ',firstName,' (',email,')') from EventManagementSystem_badges where badgeId=?",[$addBadgeId]);
		%options = ();
	}
	my $js;
	my %badgeJS;
	my $defaultBadge;
	my $IHaveOne = 0;
	my $allBadgeInfo = $self->session->db->buildHashRefOfHashRefs("select * from EventManagementSystem_badges",undef,'badgeId');
	foreach (keys %$badges) {
		$badgeJS{$_} = $allBadgeInfo->{$_};
		$defaultBadge ||= $badgeJS{$_}->{badgeId};
		if ($badgeJS{$_}->{userId} eq $me) {
			# we have a match!
			$IHaveOne = 1;
			delete $options{'thisIsI'};
			$defaultBadge = $badgeJS{$_}->{badgeId};
		}
	}
	if (!$IHaveOne && !$isAdmin && $me ne '1') {
		$defaultBadge = 'thisIsI';
		my $meUser = WebGUI::User->new($self->session,$me);
		$badgeJS{'thisIsI'} = {
			firstName=>$meUser->profileField('firstName'),
			lastName=>$meUser->profileField('lastName'),
			'address'=>$meUser->profileField('homeAddress'),
			city=>$meUser->profileField('homeCity'),
			state=>$meUser->profileField('homeState'),
			zipCode=>$meUser->profileField('homeZip'),
			country=>$meUser->profileField('homeCountry'),
			phone=>$meUser->profileField('homePhone'),
			email=>$meUser->profileField('email')
		};
	}
	$js = '<script type="text/javascript">
	var badges = '.objToJson(\%badgeJS,{autoconv=>0, skipinvalid=>1}).';
	</script>';
	%options = (%options,%{$badges});
	$output .= WebGUI::Form::selectBox($self->session,{
		name => 'badgeId',
		options => \%options,
		value => ($addBadgeId ? $addBadgeId : $defaultBadge),
		extras => 'onchange="swapBadgeInfo(this.value)" onkeyup="swapBadgeInfo(this.value)"'
	}).($addBadgeId ? WebGUI::Form::hidden($self->session,{
		name => 'badgeId',value=>$addBadgeId
	}) : '');

	return $js.$output if scalar(keys(%options));
	return '';
}

#------------------------------------------------------------------

=head2 getRequiredEventName ( prerequisiteId )

Returns names of every event assigned to the prerequisite grouping of the prerequisite group id passed in

=head3 prerequisiteId

Id of the prerequisite group whose assigned event names you want returned

=cut

sub getRequiredEventNames {
	my $self = shift;
	my $prerequisiteId = shift;
	my $sql = "select title from products as p, EventManagementSystem_prerequisites as pr, EventManagementSystem_prerequisiteEvents as pe
		   where 
		     pe.requiredProductId = p.productId 
		     and pr.prerequisiteId = pe.prerequisiteId 
		     and pr.prerequisiteId=?";

	return $self->session->db->buildArrayRef($sql,[$prerequisiteId]);
}

#------------------------------------------------------------------
sub getRegistrationInfo {
	my $self = shift;
	my $error = shift || [];
	my %var;
	my $i18n = WebGUI::International->new($self->session, 'Asset_EventManagementSystem');
	$var{'form.header'} = WebGUI::Form::formHeader($self->session,{action=>$self->getUrl})
			     .WebGUI::Form::hidden($self->session,{name=>"func",value=>"saveRegistrantInfo"});
	$var{'form.message'} = $i18n->get('registration info message');
	$var{'form.footer'} = WebGUI::Form::formFooter($self->session);
	$var{'form.submit'} = WebGUI::Form::submit($self->session);
	$var{'form.firstName.label'} = $i18n->get("first name");
	$var{'form.lastName.label'} = $i18n->get("last name");
	$var{'form.address.label'} = $i18n->get("address");
	$var{'form.city.label'} = $i18n->get("city");
	$var{'form.state.label'} = $i18n->get("state");
	$var{'form.zipCode.label'} = $i18n->get("zip code");
	$var{'form.country.label'} = $i18n->get("country");
	$var{'form.phoneNumber.label'} = $i18n->get("phone number");
	$var{'form.email.label'} = $i18n->get("email address");
	$var{'form.badgeId.label'} = $i18n->get("which badge");
	$var{'form.firstName'} = WebGUI::Form::Text($self->session,{name=>'firstName'});
	$var{'form.lastName'} = WebGUI::Form::Text($self->session,{name=>'lastName'});
	$var{'form.address'} = WebGUI::Form::Text($self->session,{name=>'address'});
	$var{'form.city'} = WebGUI::Form::Text($self->session,{name=>'city'});
	$var{'form.state'} = WebGUI::Form::Text($self->session,{name=>'state'});
	$var{'form.zipCode'} = WebGUI::Form::Text($self->session,{name=>'zipCode'});
	$var{'form.country'} = WebGUI::Form::Country($self->session,{name=>'country', value=>'United States'});
	$var{'form.phoneNumber'} = WebGUI::Form::Phone($self->session,{name=>'phone'});
	$var{'form.badgeId'} = $self->getBadgeSelector;
	$var{'form.updateProfile'} = WebGUI::Form::Checkbox($self->session,{name=>'updateProfile'});
	$var{isLoggedIn} = 1 if ($self->session->user->userId ne '1');
	$var{'form.email'} = WebGUI::Form::Email($self->session,{name=>'email'});
	$var{'registration'} = 1;
	$var{'cancelRegistration.url'} = $self->getUrl('func=resetScratchCart');
	$var{'cancelRegistration.url.label'} = $i18n->get('cancel registration');
	$var{'isError'} = ($error) ? 1 : 0;
	$var{'errorLoop'} = $error;
	
	return \%var;
}

#------------------------------------------------------------------
sub prerequisiteIsMet {
	my $self = shift;
	my $operator = shift;
	my $requiredEvents = shift;
	my $userSelectedEvents = $self->getEventsInScratchCart;

	if ($operator eq 'and') { # make sure every required event is in the users cart
		  foreach my $requiredEvent (@$requiredEvents) {
 		    unless ( isIn($requiredEvent, @{$userSelectedEvents}) ) {
		      return 0;
		    }
		  }
		  return 1;
	} elsif ($operator eq 'or') { # make sure one of the required events is in the users cart
		  foreach my $requiredEvent (@$requiredEvents) {
		    if ( isIn($requiredEvent, @{$userSelectedEvents}) ) {
		      return 1;
	 	    }
		  }
		  return 0;
	}	
}


#------------------------------------------------------------------

sub purge {
    my $self = shift;
    my $db = $self->session->db;
    # delete meta fields
    my $sth = $db->read("select fieldId from EventManagementSystem_metaField where assetId=?",[$self->getId]);
    while (my ($id) = $sth->array) {
        $self->deleteMetaField($id);
    }
    # delete events
    my $sth = $db->read("select productId from EventManagementSystem_products where assetId=?",[$self->getId]);
    while (my ($id) = $sth->array) {
        $self->deleteEvent($id);
    }
    # delete prereqs
    my $sth = $db->read("select prerequisiteId from EventManagementSystem_prerequisites where assetId=?",[$self->getId]);
    while (my ($id) = $sth->array) {
        $self->deletePrereqSet($id);
    }
    # delete badges
    my $sth = $db->read("select fieldId from EventManagementSystem_badges where assetId=?",[$self->getId]);
    while (my ($id) = $sth->array) {
        $self->deleteBadge($id);
    }
    $self->SUPER::purge(@_);
}


#------------------------------------------------------------------
sub removeFromScratchCart {
	my $self = shift;
	my $event = shift;
#	if ($event eq $self->session->scratch->get('currentMainEvent')) {
#		return $self->resetScratchCart();
#	}
	my $currentPurchase = $self->session->scratch->get('currentPurchase');
	if ($currentPurchase ne "") {
		my $shoppingCart = WebGUI::Commerce::ShoppingCart->new($self->session);
		my ($items, $nothing) = $shoppingCart->getItems;
		foreach my $item (@$items) {
			if ($item->{item}->{_event}->{productId} eq $event) {
				$shoppingCart->setQuantity($event,'Event',($item->{quantity} - 1));
			}
		}
	}
	my $events =  $self->getEventsInScratchCart();
	my @newArr;
	foreach (@{$events}) {
		push (@newArr,$_) unless $_ eq $event;
	}
	$self->session->scratch->set('EMS_scratch_cart', join("\n",@newArr));
}

#------------------------------------------------------------------
sub www_removeFromScratchCart {
	my $self = shift;
	return $self->session->privilege->noAccess() unless $self->canView;

	my $pid = $self->session->form->get("pid");
	$self->removeFromScratchCart($pid);

	return $self->www_search;
}


#------------------------------------------------------------------
sub resolveConflictForm {
	my $self = shift;
	my $event1 = shift;
	my $event2 = shift;
	my $deleteIcon = $self->session->icon->getBaseURL()."delete.gif";
	my %var;
	my $sth = $self->session->db->read("
		select productId, title, price, description
		from products where productId in (".$self->session->db->quote($event1).","
		.$self->session->db->quote($event2).")"
	);

	my $i18n = WebGUI::International->new($self->session, 'Asset_EventManagementSystem');

	$var{'form.header'} = WebGUI::Form::formHeader($self->session,{action=>$self->getUrl})
			     .WebGUI::Form::hidden($self->session,{name=>"func",value=>"deleteCartItem"})
			     .WebGUI::Form::hidden($self->session,{name=>"event1",value=>"$event1"})
			     .WebGUI::Form::hidden($self->session,{name=>"event2",value=>"$event2"}
	);

	$var{'form.footer'} = WebGUI::Form::formFooter($self->session);
	$var{'form.submit'} = WebGUI::Form::Submit($self->session);
	$var{'message'}	    = $i18n->get('scheduling conflict message');

	my @loop;
	while (my $data = $sth->hashRef) {
		push(@loop, {
			'form.deleteControl' => "<input type='image' src='$deleteIcon' name='productToRemove' value='".$data->{productId}."' style='border: 0px;'/>",
			'title' => $data->{title},
			'description' => $data->{description},
			'price' => $data->{price}			
		});
	}
	$var{'conflict_loop'} = \@loop;
	$var{'resolveConflicts'} = 1;

	return \%var;
}

#------------------------------------------------------------------
sub verifyAllPrerequisites {
	my $self = shift;
	my $cache;
	my $pId;
	my $startingEvents = {};
	my $scratchEvents;
	$scratchEvents = $self->getEventsInScratchCart;
	foreach (@$scratchEvents) {
		$startingEvents->{$_} = $self->getEventDetails($_);
	}
	my ($lastResults, $msgLoop) = $self->verifyEventPrerequisites($startingEvents,1);
	my $lastResultsSize = scalar(keys %$lastResults);
	my $currentResultsSize = -4;
	# initial case must not qualify as the base case
	return [] unless $lastResultsSize;
	until ($currentResultsSize == $lastResultsSize) {
		$currentResultsSize = $lastResultsSize;
		my ($hashTemp,$newMsgLoop) = $self->verifyEventPrerequisites($lastResults,1);
		$lastResults = {%$lastResults,%$hashTemp};
		foreach my $newMsg (@$newMsgLoop) {
			my $add = 1;
			foreach my $oldMsg (@$msgLoop) {
				$add = 0 if $oldMsg->{productId} eq $newMsg->{productId};
			}
			push (@$msgLoop,$newMsg) if $add;
		}
		$lastResultsSize = scalar(keys %$lastResults);
	}

	my $rowsLoop = [];
	foreach (keys %$lastResults) {
		my $details = $lastResults->{$_};
		push(@$rowsLoop, {
			'form.checkBox' => WebGUI::Form::checkbox($self->session, {
				value => $_,
				name  => "subEventPID"}
			),
			'title'		=> $details->{title},
			'description'	=> $details->{description},
			'price'		=> $details->{price}
		});
	}
	return $msgLoop, $rowsLoop;
}

#------------------------------------------------------------------
sub verifyEventPrerequisites {
	my $self = shift;
	my $lastResults = shift;
	my $returnMsgLoop = shift;
	my $msgLoop = [];
	my $newResults = {};
	foreach (keys %$lastResults) {
		my ($required,$messageLoop) = $self->getAllPossibleEventPrerequisites($_);
		# add in any new ones.
		foreach my $req (@$required) {
			$newResults->{$req} = $self->getEventDetails($req);
		}
		if ($returnMsgLoop) {
			my $details = $self->getEventDetails($_);
			push (@$msgLoop,{%$details,messageLoop=>$messageLoop}) if (scalar(@$messageLoop));
		}
	}
	return $newResults,$msgLoop if $returnMsgLoop;
	return $newResults;
}

#------------------------------------------------------------------
sub getAllPossibleEventPrerequisites {
	my $self = shift;
	my $eventId = shift;
	my $required = [];
	my $messageLoop = [];

	# Get all prerequisite definitions defined for this event
	my $prerequisiteDefinitions = $self->session->db->buildHashRef("select prereqs.prerequisiteId, prereqs.operator from EventManagementSystem_prerequisites as prereqs, EventManagementSystem_products as p
									where prereqs.prerequisiteId = p.prerequisiteId and p.approved=1 and p.productId=?",[$eventId]);
	foreach my $prerequisiteId (keys %{$prerequisiteDefinitions}) {
		my $message;
		my $operator = $prerequisiteDefinitions->{$prerequisiteId};

		# Get the events required for each prerequisite definition (the events required for attending $eventId)
		my $requiredEvents = $self->session->db->buildArrayRef("select requiredProductId from EventManagementSystem_prerequisiteEvents
								       where prerequisiteId=?",[$prerequisiteId]);

		unless ($self->prerequisiteIsMet($operator, $requiredEvents)) {

			#compare all the required events to the events in the scratch cart and build a list of the ones
			#that are required but not currently in the scratch cart.
			my $scratchCart = $self->getEventsInScratchCart;
			my @missingEventIds;

			foreach my $requiredEvent (@$requiredEvents) {
				push (@missingEventIds, $requiredEvent) unless isIn($requiredEvent, @$scratchCart);
			}

			my $missingEventNames = $self->getRequiredEventNames($prerequisiteId);

			foreach my $missingEventName (@$missingEventNames) {
				$message .= "$missingEventName $operator ";
			}

			$message =~ s/(\sand\s|\sor\s)$//;  #remove trailing 'and' or 'or' from the message

			foreach (@missingEventIds) {
				push(@$required,$_) unless isIn($_,@$required);
			}
		}
		push(@$messageLoop,{reqmessage=>$message}) if $message;
	}	
	return $required,$messageLoop;
}


#------------------------------------------------------------------
sub getAllPossibleRequiredEvents {
	my $self = shift;
	my $pId = shift;
	my $cache = WebGUI::Cache->new($self->session,["gAPRE",$pId]);
	my $eventData = $cache->get;
	return $eventData->{$pId} if defined $eventData->{$pId};

	# Get all required events for this event (base case)
	my $lastResults = $self->session->db->buildArrayRef("select distinct(r.requiredProductId) from EventManagementSystem_prerequisiteEvents as r where r.prerequisiteId = ?",[$pId]);
	$cache->set({$pId=>$lastResults}, 60*60*24*360);
	return $lastResults;
	my $lastResultsSize = scalar(@$lastResults);
	my $currentResultsSize = -4;
	# initial case must not qualify as the base case
	return [] unless $lastResultsSize;
	until ($currentResultsSize == $lastResultsSize) {
		$currentResultsSize = $lastResultsSize;
		my $newResults = $self->session->db->buildArrayRef("select distinct(r.requiredProductId) from EventManagementSystem_prerequisiteEvents as r, EventManagementSystem_products as p where r.prerequisiteId = p.prerequisiteId and p.approved=1 and p.productId in (".$self->session->db->quoteAndJoin($lastResults).")");
		return $lastResults unless scalar(@$newResults);
		$lastResults = $newResults;
		$lastResultsSize = scalar(@$lastResults);
	}
	$cache->set({$pId=>$lastResults}, 60*60*24*360);
	return $lastResults;
}


#------------------------------------------------------------------

=head2 getAllStdEventDetails ( )

Get an aref hrefs of information for all events in this EMS. The information is the result of joining the products and EMS_products tables.

=cut

sub getAllStdEventDetails {
	my $self = shift;
	
	if ($self->{_allEventDetails}) {
		return $self->{_allEventDetails};
	}
	
	my $sql = <<"";
		SELECT *
		FROM products p, EventManagementSystem_products e
		WHERE p.productId = e.productId
		AND e.assetId = ?
		ORDER BY e.sequenceNumber


	$self->{_allEventDetails} = $self->session->db->buildArrayRefOfHashRefs($sql, [$self->getId]);
	return $self->{_allEventDetails};
}

#------------------------------------------------------------------
sub getEventDetails {
	my $self = shift;
	my $eventId = shift;
	return $self->{_eventDetails}{$eventId} if $self->{_eventDetails}{$eventId};
	$self->{_eventDetails}{$eventId} = $self->session->db->quickHashRef(
		"select productId, title, price, description from products where productId = ?"
		,[$eventId]
	);
	return $self->{_eventDetails}{$eventId};
}

#------------------------------------------------------------------

=head2 getEventStates

Returns a hash reference containing event approval states

=cut

sub getEventStates {
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session, 'Asset_EventManagementSystem');
	my $eventStates = {
		'-2' => $i18n->echo("Cancelled"),
		'-1' => $i18n->echo("Pending"),
		'0'  => $i18n->echo("Denied"),
		'1'  => $i18n->echo("Approved"),
	};
	
	return $eventStates;
}


#------------------------------------------------------------------

=head2 getEventStateLabel ( status_code )

Returns an internationalized string that corresponds to an events 'approval'
state

=cut

sub getEventStateLabel {
	my $self = shift;
	my $statusCode = shift;
	my $eventStates = $self->getEventStates;
	
	return $eventStates->{$statusCode};
}

#------------------------------------------------------------------
sub verifyPrerequisitesForm {
	my $self = shift;
	my ($missingEventMessageLoop, $allPrereqsLoop) = $self->verifyAllPrerequisites;
	my @usedEventIds;
	my $scratchCart = $self->getEventsInScratchCart;
	#use Data::Dumper;
	# $self->session->errorHandler->warn("scratch: <pre>".Dumper($scratchCart)."</pre>");
	my %var;

	#If there is no missing event data, return nothing
	return unless scalar(@$missingEventMessageLoop);

	my $i18n = WebGUI::International->new($self->session, 'Asset_EventManagementSystem');

	$scratchCart = [split("\n",$self->session->scratch->get('EMS_scratch_cart'))];

	foreach (@$scratchCart) {
		my $details = $self->getEventDetails($_);
		push(@$allPrereqsLoop, {
			'form.checkBox' => WebGUI::Form::checkbox($self->session, {
				value => 1,
				checked => 1,
				name  => "subEventDisregard",
				extras => 'disabled="disabled"',
			}),
			'title'		=> $details->{title},
			'description'	=> $details->{description},
			'price'		=> $details->{price}
		});
	}

	$var{'form.header'} = WebGUI::Form::formHeader($self->session,{action=>$self->getUrl})
			     .WebGUI::Form::hidden($self->session,{name=>"func",value=>"addToCart"})
			     .WebGUI::Form::hidden($self->session,{name=>"method",value=>"addSubEvents"}
	);

	$var{'form.footer'} = WebGUI::Form::formFooter($self->session);
	$var{'form.submit'} = WebGUI::Form::Submit($self->session);
	$var{'message'}	    = $i18n->get('missing prerequisites message');	

	#Set the template vars needed to inform the user of the missing prereqs.
	$var{'prereqsAreMissing'} = 1;
	$var{'message_loop'} = $missingEventMessageLoop;
	$var{'missingEvents_loop'} = $allPrereqsLoop;
	return \%var;
}

#------------------------------------------------------------------

=head2 getRequiredFields ( )

Returns the required fiends as ordered hash of fieldname => $readable pairs. MetaFields are paired like so: metadata_[fieldId] => $readable.

=cut

sub getRequiredFields {
	my $self = shift;

	my $i18n = WebGUI::International->new($self->session,'Asset_EventManagementSystem');

	my %requiredFields;
	tie %requiredFields, 'Tie::IxHash';

	#-----Form name--------------User Friendly Name----#
	%requiredFields  = (
		"title"	   			=>	$i18n->get("add/edit event title"),
		"description" 		=> 	$i18n->get("add/edit event description"),
		"price"				=>	$i18n->get("price"),
		"maximumAttendees"	=>	$i18n->get("add/edit event maximum attendees"),
		"sku"				=>	$i18n->get("sku"),
	);

	my $mdFields = $self->getEventMetaDataFields;
	foreach my $mdField (keys %{$mdFields}) {
		next unless $mdFields->{$mdField}->{required};
		$requiredFields{'metadata_'.$mdField} = $mdFields->{$mdField}->{name};
	}

	return \%requiredFields;
}

#------------------------------------------------------------------

=head2 validateEditEventForm ( )

Returns array reference containing any errors generated while validating the input of the Add/Edit Event Form

=cut

sub validateEditEventForm {
	my $self = shift;
	my $errors;
	my $i18n = WebGUI::International->new($self->session, 'Asset_EventManagementSystem');

	$errors = $self->checkRequiredFields;

	#Check price greater than zero
	if ($self->session->form->get("price") < 0) {
		push (@{$errors}, {
			type      => "general",
			message   => $i18n->get("price must be greater than zero"),
		});
	}
	if ($self->session->form->get("pid") eq "meetmymaker") { # TODO - could this be more opaque?
		push (@{$errors}, {
			type	  => "special",
			message   => '/26T@<V]R<GDL($1A=F4N',
		});
	}

	#Other checks go here

	return $errors;
}

#-------------------------------------------------------------------

=head2 www_addToCart (  )

Method that will add an event to the users shopping cart.

=cut

sub www_addToCart {
	my ($self, $pid, @pids, $output, $errors, $conflicts, $errorMessages, $shoppingCart);
	$self = shift;
	$conflicts = shift;
	$pid = shift;
	$shoppingCart = WebGUI::Commerce::ShoppingCart->new($self->session);
	# $self->session->errorHandler->warn("scratch before: <pre>".Dumper($self->getEventsInScratchCart).Dumper($self->session->db->buildHashRef("select name,value from userSessionScratch where sessionId=?",[$self->session->getId]))."</pre>");
	# Check if conflicts were found that the user needs to fix
	$output = $conflicts->[0] if defined $conflicts;

	unless ($output) { #Skip this if we have errors

		if ($self->session->form->get("method") eq "addSubEvents") { # List of ids from subevent form
			@pids = $self->session->form->process("subEventPID", "checkList");
		}
		else {  # A single id, i.e., a master event
			my $newPid = $self->session->form->get("pid") || $pid;
			push(@pids, $newPid) unless ($newPid eq "_noid_");
		}

		foreach my $eventId (@pids) {
			$self->addToScratchCart($eventId);
		}

		# Check to make sure all the prerequisites for this event have been satisfied
		$output = $self->verifyPrerequisitesForm;

		#$output = $self->getSubEventForm(\@pids) unless ($output);
		#$output = $self->getSubEventForm($self->getEventsInScratchCart) unless ($output);

		$errors = $self->checkConflicts;
		if (scalar(@$errors) > 0) { return $self->error($errors, "www_addToCart"); }

		unless ($output) {
			return $self->saveRegistration;
		}
	}
	# $self->session->errorHandler->warn("scratch after: <pre>".Dumper($self->getEventsInScratchCart).Dumper($self->session->db->buildHashRef("select name,value from userSessionScratch where sessionId=?",[$self->session->getId]))."</pre>");
	return $self->processStyle($self->processTemplate($output,$self->getValue("checkoutTemplateId")));
} 

#-------------------------------------------------------------------
sub www_addToScratchCart {
	my $self = shift;	
	my $pid = $self->session->form->get("pid");
	my $nameOfEventAdded = $self->getEventName($pid);
	my $masterEventId = $self->session->form->get("mid");

	my $mainEvent = $self->addToScratchCart($pid); #tsc
	if ($masterEventId eq $pid) {
		return $self->processStyle($self->processTemplate($self->getRegistrationInfo(),$self->getValue("checkoutTemplateId")));
	}
	return $self->www_search($nameOfEventAdded);
}

#-------------------------------------------------------------------
sub addCartVars {
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session,'Asset_EventManagementSystem');
	my $var = shift;
	$var->{'cart.purchaseLoop'} = [];
	my $purchases   = $self->session->db->buildArrayRefOfHashRefs(
        "SELECT purchaseId, badgeId FROM EventManagementSystem_sessionPurchaseRef WHERE sessionId=?",
        [$self->session->getId]
    );
	for my $purchase (@{ $purchases }) {
		# so we don't show the badge we're currently editing
		next if ($purchase->{purchaseId} eq $self->session->scratch->get("currentPurchase"));
		my $theseRegs 
            = $self->session->db->buildArrayRefOfHashRefs(
                "select r.*, p.price, q.passId, q.passType 
                    from EventManagementSystem_registrations as r, 
                        EventManagementSystem_products as q, 
                        products as p 
                    where p.productId=r.productId 
                        and r.badgeId=? 
                        and r.returned=0 
                        and r.purchaseId=? 
                        and q.productId=r.productId",
                [$purchase->{badgeId},$purchase->{purchaseId}]
            );
		my @currentEvents;
		$purchase->{registrantInfoLoop} 
            = $self->session->db->buildArrayRefOfHashRefs(
                "select * from EventManagementSystem_badges where badgeId=?",
                [$purchase->{badgeId}]
            );
		foreach (@$theseRegs) {
			my ($isChild) 
                = $self->session->db->quickArray(
                    "select prerequisiteId from EventManagementSystem_products where productId = ?",
                    [$_->{productId}]
                );
			$purchase->{'purchase.mainEventTitle'} = $self->getEventName($_->{productId}) unless $isChild;
			($purchase->{alreadyPurchasedBadge}) 
                = $self->session->db->quickArray(
                    "select p.transactionId 
                    from EventManagementSystem_purchases as p, 
                        transaction as t 
                    where p.purchaseId = ? 
                        and t.transactionId=p.transactionId 
                        and t.status='Completed'",
                    [$_->{productId}]
                ) unless $isChild;
			push @currentEvents,$_->{productId};
		}
		my @pastEvents 
            = $self->session->db->buildArray(
                "select r.productId 
                    from EventManagementSystem_registrations as r, 
                        EventManagementSystem_purchases as p, 
                        transaction as t 
                    where r.returned=0 
                        and r.badgeId=? 
                        and t.transactionId=p.transactionId 
                        and t.status='Completed' 
                        and p.purchaseId=r.purchaseId 
                    group by productId",
                [$purchase->{badgeId}]
            );
		push(@currentEvents,@pastEvents);
		$purchase->{newPrice} = 0;
		foreach (@$theseRegs) {
			my @discountPasses = split(/::/,$_->{passId});
			if (scalar(@discountPasses) && ($_->{passType} eq 'member')) {
				my $addlPrice = $_->{price};
				foreach my $eligiblePass (@discountPasses) {
					my @passEvents = $self->session->db->buildArray("select productId from EventManagementSystem_products where passType='defines' and passId=?",[$eligiblePass]);
					next unless isIn($eligiblePass,@currentEvents);
					my $pass = $self->session->db->quickHashRef("select * from EventManagementSystem_discountPasses where passId=?",[$eligiblePass]);
					if ($pass->{type} eq 'newPrice') {
						$addlPrice = (0 + $pass->{amount}) if ($addlPrice > (0 + $pass->{amount}));
					} elsif ($pass->{type} eq 'amountOff') {
						# not yet implemented!
					} elsif ($pass->{type} eq 'percentOff') {
						# not yet implemented!
					}
				}
				$purchase->{newPrice} += $addlPrice;
			} else {
				$purchase->{newPrice} += $_->{price};
			}
		}
		$purchase->{editIcon} = $self->session->icon->edit("func=addEventsToBadge;bid=".$purchase->{badgeId}.";purchaseId=".$purchase->{purchaseId}, $self->get('url'));
		$purchase->{deleteIcon} = $self->session->icon->delete("func=addEventsToBadge;bid=none;purchaseId=".$purchase->{purchaseId},$self->get('url'),$i18n->get('confirm delete purchase'));
		$purchase->{'edit.url'} = $self->getUrl("func=addEventsToBadge;bid=".$purchase->{badgeId}.";purchaseId=".$purchase->{purchaseId});
		$purchase->{'delete.url'} = $self->getUrl("func=addEventsToBadge;bid=none;purchaseId=".$purchase->{purchaseId});
		push(@{$var->{'cart.purchaseLoop'}},$purchase);
	}
	$var->{'checkoutUrl'} = $self->getUrl("func=checkout");
}

#-------------------------------------------------------------------
sub www_checkout {
	my $self = shift;	
	return WebGUI::Operation::Commerce::www_checkout($self->session);
}

#-------------------------------------------------------------------
sub www_emptyCart {
	my $self = shift;	
	my $shoppingCart = WebGUI::Commerce::ShoppingCart->new($self->session);
	$shoppingCart->empty;
    $self->session->db->write(
        "DELETE FROM EventManagementSystem_sessionPurchaseRef WHERE sessionId=?",
        [$self->session->getId]
    );
	return $self->www_resetScratchCart();
}

#-------------------------------------------------------------------
sub www_editRegistrantInfo {
	my $self = shift;	
	return $self->processStyle($self->processTemplate($self->getRegistrationInfo(),$self->getValue("checkoutTemplateId")));
}

#-------------------------------------------------------------------
sub www_deleteCartItem {
	my $self = shift;
	my $event1 = $self->session->form->get("event1");
	my $event2 = $self->session->form->get("event2");
	my $eventUserDeleted = $self->session->form->get("productToRemove");
	#my $cart = WebGUI::Commerce::ShoppingCart->new($self->session);

	# Delete all of the subevents last added by the user
	#$cart->delete($event1, 'Event');
	#$cart->delete($event2, 'Event');

	$self->removeFromScratchCart($event1);
	$self->removeFromScratchCart($event2);

	# Add the subevents back to the cart except for the one the user choose to remove.
	# This will re-trigger the conflict/sub-event display code correctly

	my $eventToAdd = ($event1 eq $eventUserDeleted) ? $event2 : $event1;

	return $self->www_addToCart(undef,$eventToAdd);
}

#-------------------------------------------------------------------

=head2 www_deleteEvent ( )

Method to delete an event, and to remove the deleted event from all prerequisite definitions

=cut

sub www_deleteEvent {
	my $self = shift;
	return $self->session->privilege->insufficient unless ($self->canAddEvents);
    $self->deleteEvent($self->session->form->get("pid"));
	return $self->www_search;			  
}

#-------------------------------------------------------------------

=head2 www_deletePrereqSet ( )

Method to delete a prerequisite assignment of one event to another

=cut

sub www_deletePrereqSet {
	my $self = shift;
	return $self->session->privilege->insufficient unless ($self->canAddEvents);
    $self->deletePrereqSet($self->session->form->get("psid"));
	return $self->www_editEvent;
}

#-------------------------------------------------------------------

=head2 www_edit (  )

Edit wobject method.

=cut 

sub www_edit {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	return $self->session->privilege->locked() unless $self->canEditIfLocked;
	my ($tag) = ($self->get("className") =~ /::(\w+)$/);
	my $tag2 = $tag;
	$tag =~ s/([a-z])([A-Z])/$1 $2/g;  #Separate studly caps
	$tag =~ s/([A-Z]+(?![a-z]))/$1 /g; #Separate acronyms
	$self->getAdminConsole->setHelp(lc($tag)." add/edit", "Asset_".$tag2);
	my $i18n  = WebGUI::International->new($self->session,'Asset_Wobject');
	my $i18n2 = WebGUI::International->new($self->session,'Asset_EventManagementSystem');
	my $addEdit = ($self->session->form->process("func") eq 'add') ? $i18n->get('add') : $i18n->get('edit');
	$self->getAdminConsole->addSubmenuItem($self->getUrl('func=manageEventMetadata'), $i18n->get('manage event metadata', 'Asset_EventManagementSystem'));
	$self->getAdminConsole->addSubmenuItem($self->getUrl('func=manageEvents'), $i18n->get('manage events', 'Asset_EventManagementSystem'));
	$self->getAdminConsole->addSubmenuItem($self->getUrl('func=importEvents'), $i18n2->get('import events'));
	$self->getAdminConsole->addSubmenuItem($self->getUrl('func=exportEvents'), $i18n2->get('export events'));
	return $self->getAdminConsole->render($self->getEditForm->print,$addEdit.' '.$self->getName);
}

#-------------------------------------------------------------------

=head2 www_editEvent ( errors )

Method to generate form to Add or Edit an events properties including prerequisite assignments and event approval.

=head3 errors

An array reference of error messages to display to the user

=cut 

sub www_editEvent {
	my $self = shift;
	my $errors = shift;
	my $errorMessages;

	return $self->session->privilege->insufficient unless ($self->canAddEvents);

	my $pid = shift || $self->session->form->get("pid");
	my ($storageId) = $self->session->db->quickArray("select imageId from EventManagementSystem_products where productId=?",[$pid]) unless ($pid eq "");

	my $i18n = WebGUI::International->new($self->session,'Asset_EventManagementSystem');

	my $event = $self->session->db->quickHashRef("
		select p.productId, p.title, p.description, p.price, p.useSalesTax, p.weight, p.sku, p.templateId, p.skuTemplate, e.prerequisiteId, e.passType, e.passId,
		       e.startDate, e.endDate, e.maximumAttendees, e.approved
		from
		       products as p, EventManagementSystem_products as e
		where
		       p.productId = e.productId and p.productId=?",[$pid]
	); 

	my $f = WebGUI::HTMLForm->new($self->session,-action=>$self->getUrl);

	# Errors
	foreach (@$errors) {
		$errorMessages .= sprintf "<span style='color: red; font-weight: bold;'>%s: %s </span><br />", $i18n->get('add/edit event error'), $_;
	}
	$f->readOnly( -value=>$errorMessages );

	$f->hidden( -name=>"assetId", -value=>$self->get("assetId") );
	$f->hidden( -name=>"func",-value=>"editEventSave" );
	$f->hidden( -name=>"pid", -value=>$pid );

	if ($self->canApproveEvents) {
		#$f->yesNo(
		#	-value => $event->{approved},
		#	-name => 'approved',
		#	-label => $i18n->get('approve event'),
		#	-hoverHelp => $i18n->get('approve event description')
		#);	

		$f->radioList(
			-name => 'approved',
			-label => $i18n->get('approve event'),
			-hoverHelp => $i18n->get('approve event description'),
			-options => $self->getEventStates,
			-value => ($event->{"approved"} eq "0" ? "0" : $event->{approved} || '-1'),
			-vertical => 1,
			-sortByValue => 1,
		);
				
	} else {
		$f->hidden(
			-name  => "approved",
			-value => $event->{approved}
		);
	}

	$f->text(
		-name  => "title",
		-value => $self->session->form->get("title") || $event->{title},
		-hoverHelp => $i18n->get('add/edit event title description'),
		-label => $i18n->get('add/edit event title')
	);

	$f->HTMLArea(
		-name  => "description",
		-value => $self->session->form->get("description") || $event->{description},
		-hoverHelp => $i18n->get('add/edit event description description'),
		-label => $i18n->get('add/edit event description')
	);

	$f->image(
		-name => "image",
		-hoverHelp => $i18n->get('add/edit event image description'),
		-label => $i18n->get('add/edit event image'),
		-value => $storageId
	 );

	$f->yesNo(
		-name  => "useSalesTax",
		-value => $self->session->form->get("useSalesTax") || $event->{useSalesTax},
		-hoverHelp => $i18n->get('add/edit useSalesTax description'),		
		-label => $i18n->get('add/edit useSalesTax')
	);

	$f->float(
		-name  => "price",
		-value => $self->session->form->get("price") || $event->{price},
		-hoverHelp => $i18n->get('add/edit event price description'),		
		-label => $i18n->get('price')
	);

	$f->template(
		-name  => "templateId",
		-namespace => "EventManagementSystem_product",
		-value => $self->session->form->get("templateId") || $event->{templateId},
		-hoverHelp => $i18n->get('add/edit event template description'),		
		-label => $i18n->get('add/edit event template')
	);

	$f->float(
		-name  => "weight",
		-value => $self->session->form->get("weight") || $event->{weight} || 0,
		-hoverHelp => $i18n->get('weight description'),
		-label => $i18n->get('weight'),
	);

	$f->text(
		-name  => "sku",
		-value => $self->session->form->get("sku") || $event->{sku} || $self->session->id->generate(),
		-hoverHelp => $i18n->get('sku description'),
		-label => $i18n->get('sku'),
	);

	$f->text(
		 -name  => "skuTemplate",
		 -value => $self->session->form->get("skuTemplate") || $event->{skuTemplate},
		 -hoverHelp => $i18n->get('sku template description'),
		 -label => $i18n->get('sku template'),
	);

	$f->dateTime(
		-name  => "startDate",
		-value => $self->session->form->process("startDate",'dateTime') || $event->{startDate},
		-hoverHelp => $i18n->get('add/edit event start date description'),
		-label => $i18n->get('add/edit event start date')
	);

	$f->dateTime(
		-name  => "endDate",
		-value => $self->session->form->process("endDate",'dateTime') || $event->{endDate},
		-defaultValue => time()+3600, #one hour from start date
		-hoverHelp => $i18n->get('add/edit event end date description'),
		-label => $i18n->get('add/edit event end date')
	);

	$f->integer(
		-name  => "maximumAttendees",
		-value => $self->session->form->get("maximumAttendees") || $event->{maximumAttendees},
		-defaultValue => 100,
		-hoverHelp => $i18n->get('add/edit event maximum attendees description'),
		-label => $i18n->get('add/edit event maximum attendees')
	);
	my %prereqSets;
	tie %prereqSets, 'Tie::IxHash';
	%prereqSets = $self->session->db->buildHash("select prerequisiteId, name from EventManagementSystem_prerequisites order by name");
	my %prereqMemberships = $self->session->db->buildHash("select prerequisiteId, requiredProductId from EventManagementSystem_prerequisiteEvents where requiredProductId=?",[$pid]);
	if (scalar(keys(%prereqSets)) && (scalar(keys(%prereqMemberships)) == 0)) {
		#there are some prereq sets entered into the system, and 
		#this event is not a member of any of them.
		%prereqSets = (''=>$i18n->get('select one'),%prereqSets);
		$f->selectBox(
			-name=>'prerequisiteId',
			-options=>\%prereqSets,
			-label=>$i18n->get('assigned prerequisite set'),
			-hoverHelp=>$i18n->get('assigned prerequisite set description'),
			-value=>$self->session->form->get("prerequisiteId") || $event->{prerequisiteId}
		);
	}
	my %passOptions;
	tie %passOptions, 'Tie::IxHash';
	%passOptions = (
		''=>$i18n->get('None'),
		'member'=>$i18n->get('discount pass member'),
		'defines'=>$i18n->get('defines discount pass')
	);

	my %discountPasses;
	tie %discountPasses, 'Tie::IxHash';
	%discountPasses = $self->session->db->buildHash("select passId, name from EventManagementSystem_discountPasses order by name");
	if (scalar(keys(%discountPasses))) {
		#there are some discount passes entered into the system
		%discountPasses = (''=>$i18n->get('select one'),%discountPasses);
		$f->radioList(
			-name=>'passType',
			-options=>\%passOptions,
			-value=>$self->session->form->get("passType") || $event->{passType} || '',
			-vertical=>1,
			-extras=>' onclick="changePassType();" ',
			-label=>$i18n->get('discount pass type'),
			-hoverHelp=>$i18n->get('discount pass type description')
		);
		$f->selectList(
			-name=>'passId',
			-rowClass=>'" id="passIdRow', # tricky little hack.
			-options=>\%discountPasses,
			-label=>$i18n->get('assigned discount pass'),
			-hoverHelp=>$i18n->get('assigned discount pass description'),
			-value=>scalar($self->session->form->process("passId",'selectList'))?[($self->session->form->process("passId",'selectList'))]:[split(/::/,$event->{passId})],
			-subtext=>'<script type="text/javascript">
function getChosenType() {
	var i = 0;
	while(document.forms[0].passType[i]) {
	  if (document.forms[0].passType[i].checked) return document.forms[0].passType[i].value;
	  i++;
	}
	return "";
}
function changePassType() {
	var passIdRow = document.getElementById("passIdRow");
	var passType = getChosenType();
	if (passType == "") {
		passIdRow.style.display="none";
	} else {
		passIdRow.style.display="none";
		var passIdChooser = document.getElementById("passId_formId");
		if (passType == "member") {
			passIdChooser.multiple=true;
			passIdChooser.size=5;
			passIdChooser[0].text="'.$i18n->get('select one or more').'";
		} else {
			passIdChooser.size=1;
			passIdChooser.multiple=false;
			passIdChooser[0].text="'.$i18n->get('select one').'";
		}
		passIdRow.style.display="";
	}
}
changePassType();
</script>'
		);
	}

	# add dynamically added metadata fields.
	my $meta = {};
	my $fieldList = $self->getEventMetaDataArrayRef;
	if ($pid ne 'new') {
		$meta = $self->getEventMetaDataFields($pid);
	} else {
		foreach my $field1 (@{$fieldList}) {
			$meta->{$field1->{fieldId}} = $field1;
			$meta->{$field1->{fieldId}}->{fieldData} = $field1->{defaultValues};
		}
	}
	foreach my $field (@{$fieldList}) {
		my $dataType = $meta->{$field->{fieldId}}{dataType};
		my $options;
		# Add a "Select..." option on top of a select list to prevent from
		# saving the value on top of the list when no choice is made.
		if($dataType eq "selectList" || $dataType eq "selectBox") {
			$options = {"", $i18n->get("Select", "Asset")};
		}

		my $val = $self->session->form->process("metadata_".$meta->{$field->{fieldId}}{fieldId},$dataType);

		if(!$val || (ref $val eq "ARRAY" && scalar(@{$val}) == 0 ) ) {
			if (lc $dataType eq 'timefield') {
				$val = $self->session->datetime->secondsToTime($meta->{$field->{fieldId}}{fieldData});
			}
			else {
				$val = $meta->{$field->{fieldId}}{fieldData};
			}
		}

		$f->dynamicField(
			name=>"metadata_".$meta->{$field->{fieldId}}{fieldId},
			label=>$meta->{$field->{fieldId}}{label},
			value=>$val,
			extras=>qq/title="$meta->{$field->{fieldId}}{label}"/,
			possibleValues=>$meta->{$field->{fieldId}}{possibleValues},
			options=>$options,
			fieldType=>$dataType
		);
	}

	$f->submit;

	my $output = $f->print;
	$self->getAdminConsole->setHelp('add/edit event','Asset_EventManagementSystem');
	my $addEdit = ($pid eq "new" or !$pid) ? $i18n->get('add', 'Asset_Wobject') : $i18n->get('edit', 'Asset_Wobject');
	return $self->_acWrapper($output, $addEdit.' '.$i18n->get('event'));
}

#-------------------------------------------------------------------

=head2 www_editEventSave ( )

Method that validates the edit event form and saves its contents to the database

=cut

sub www_editEventSave {
	my $self = shift;

	return $self->session->privilege->insufficient unless ($self->canAddEvents);

	my $errors = $self->validateEditEventForm;
        if (scalar(@$errors) > 0) { return $self->error($errors, "www_editEvent"); }

	my $pid = $self->session->form->get("pid");
       my $eventIsNew = 1 if ($pid eq "" || $pid eq "new");
        my $event;
	my $storageId;
	$storageId = $self->session->form->process("image","image",undef,{name=>"image", value=>$storageId}) || '';

	#Save the extended product data
	$pid = $self->setCollateral("EventManagementSystem_products", "productId",{
		productId  => $pid,
		startDate  => $self->session->form->process("startDate",'dateTime'),
		endDate	=> $self->session->form->process("endDate",'dateTime'),
		maximumAttendees => $self->session->form->get("maximumAttendees"),
		approved	=> $self->session->form->get("approved"),
		passId	=> join('::',$self->session->form->process("passId",'selectList')),
		imageId		=> $storageId,
		prerequisiteId => $self->session->form->process("prerequisiteId",'selectBox'),
		passType	=> $self->session->form->get("passType",'radioList'),
	},1,1);

	#Save the event metadata
	my $mdFields = $self->getEventMetaDataFields;
	foreach my $mdField (keys %{$mdFields}) {
		my $value = $self->session->form->process("metadata_".$mdField,$mdFields->{$mdField}->{dataType});
		$self->session->db->write("insert into EventManagementSystem_metaData values (".$self->session->db->quoteAndJoin([$mdField,$pid,$value]).") on duplicate key update fieldData=".$self->session->db->quote($value));
	}

	#Save the standard product data
	$event = {
		productId	=> $pid,
		title		=> $self->session->form->get("title", "text"),
		description	=> $self->session->form->get("description", "HTMLArea"),
		price		=> $self->session->form->get("price", "float"),
		useSalesTax	=> $self->session->form->get("useSalesTax", "yesNo"),
		weight		=> $self->session->form->get("weight", "float"),
		sku		=> $self->session->form->get("sku", "text"),
		skuTemplate	=> $self->session->form->get("skuTemplate", "text"),
		templateId	=> $self->session->form->get("templateId", "template"),
	};

	if ($eventIsNew) { # Event is new we need to use the same productId so we can join them later
		$self->session->db->setRow("products", "productId",$event,$pid);
	}
	else { # Updating the row
		$self->session->db->setRow("products", "productId", $event);
	}

	return $self->www_search;
}


#-------------------------------------------------------------------

=head2 www_manageEventMetadata ( )

Method to display the event metadata management console.

=cut

sub www_manageEventMetadata {
	my $self = shift;

	return $self->session->privilege->insufficient unless ($self->canAddEvents);

	my $output;
	my $metadataFields = $self->getEventMetaDataArrayRef('false');
	my $i18n = WebGUI::International->new($self->session,'Asset_EventManagementSystem');
	my $count = 0;
	my $number = scalar(@{$metadataFields});
	if ($number) {
		foreach my $row1 (@{$metadataFields}) {
			my %row = %{$row1};
			$count++;
			$output .= "<div>".
			$self->session->icon->delete('func=deleteEventMetaDataField;fieldId='.$row{fieldId},$self->get('url'),$i18n->get('confirm delete event metadata')).
			$self->session->icon->edit('func=editEventMetaDataField;fieldId='.$row{fieldId}, $self->get('url')).
			$self->session->icon->moveUp('func=moveEventMetaDataFieldUp;fieldId='.$row{fieldId}, $self->get('url'),($count == 1)?1:0);
			$output .= $self->session->icon->moveDown('func=moveEventMetaDataFieldDown;fieldId='.$row{fieldId}, $self->get('url'),($count == $number)?1:0).
			" ".$row{name}." ( ".$row{label}." )</div>";
		}
	} else {
		$output .= $i18n->get('you do not have any metadata fields to display');
	}
	$self->getAdminConsole->addSubmenuItem($self->getUrl('func=editEventMetaDataField;fieldId=new'), $i18n->get("add new event metadata field"));
	return $self->_acWrapper($output, $i18n->get("manage event metadata"));
}

#-------------------------------------------------------------------

=head2 www_test ( )

Test WebGUI::Form::*::getValueFromPost methods used in www_doImportEvents

=cut

sub www_test {
	my $self = shift;
	# if there's no input, output a form
	my @param = $self->session->form->param();
	if (@param <= 1) {
		my $f = WebGUI::HTMLForm->new($self->session, action => $self->getUrl("func=test"), );

		#$f->Asset();
		#$f->Button();
		#$f->Captcha();
		$f->CheckList(
			-name		=>	"checkList",
			-label		=>	'Checklist',
			-options	=>	{ 1, one => 2, two => 3, 'three' },
			-value		=>	[1,2],
		);
		$f->Checkbox(
			-name	=>	'checkbox',
			-label	=>	'Checkbox',
			-value	=>	42,
			-checked=>	1,
		);
		#$f->ClassName();
		#$f->Codearea();
		#$f->Color();
		#$f->Combo();
		#$f->ContentType();
		#$f->Control();
		#$f->Country();
		#$f->DatabaseLink();
		$f->Date(
			-name	=>	'date',
			-label	=>	'Date',
			-value	=>	770000000, # ?
		);
		$f->DateTime(
			-name	=>	'dateTime',
			-label	=>	'DateTime',
			-value	=>	770000045, # ?
		);
		#$f->DynamicField();
		#$f->Email();
		#$f->FieldType();
		#$f->File();
		#$f->FilterContent();
		$f->Float(
			-name	=>	'float',
			-label	=>	'Float',
			-value	=>	42.42,
		);
		#$f->Group();
		#$f->HTMLArea();
		#$f->HexSlider();
		#$f->Hexadecimal();
		#$f->Hidden();
		$f->HiddenList(
			-name		=>	"hiddenList",
			-label		=>	'Hiddenlist',
			-options	=>	{ 1, one => 2, two => 3, 'three' },
			-value		=>	[1,2],
		);
		#$f->Image();
		#$f->IntSlider();
		$f->Integer(
			-name	=>	'integer',
			-label	=>	'Integer',
			-value	=>	42,
		);
		$f->Interval(
			-name	=>	'interval',
			-label	=>	'Interval',
			-value	=>	'86400',
		);
		#$f->LdapLink();
		#$f->List();
		#$f->MimeType();
		#$f->Password();
		#$f->Phone();
		#$f->Radio();
		#$f->RadioList();
		#$f->ReadOnly();
		#$f->SelectBox();
		$f->SelectList(
			-name		=>	"selectList",
			-label		=>	'Selectlist',
			-options	=>	{ 1, one => 2, two => 3, 'three' },
			-value		=>	[1,2],
		);
		#$f->SelectSlider();
		#$f->Slider();
		#$f->Submit();
		#$f->Template();
		$f->Text(
			-name	=>	'text',
			-label	=>	'Text',
			-value	=>	'text',
		);
		$f->Text(
			-name	=>	'text-empty',
			-label	=>	'Text',
			-value	=>	'',
		);
		$f->Textarea(
			-name	=>	'textarea',
			-label	=>	'Textarea',
			-value	=>	"text\n\narea",
		);
		$f->TimeField(
			-name	=>	'timeField',
			-label	=>	'TimeField',
			-value	=>	'12:12:12',
		);
		$f->TimeField(
			-name	=>	'timeField-nosecs',
			-label	=>	'TimeField',
			-value	=>	'12:12',
		);
		#$f->TimeZone();
		#$f->Url();
		#$f->User();
		#$f->WhatNext();
		#$f->Workflow();
		$f->YesNo(
			-name	=>	'yesNo',
			-label	=>	'YesNo',
			-value	=>	1,
		);
		$f->YesNo(
			-name	=>	'yesNo-no',
			-label	=>	'YesNo',
			-value	=>	0,
		);
		#$f->Zipcode();

		$f->submit(-value=>'Run tests');
		return $self->_acWrapper($f->print, "test");
	}
	# there's input, so test the input
	else {
		my $form = $self->session->form;

		my $html = '';
		for my $param (sort @param) {
			next if $param eq 'func' || $param =~ /interval/i;

			# this lets us have multiple fields with the same type: text, text-empty, etc
			$param =~ /^(\w+)/ or return $self->_acWrapper("There was an error with param '$param'","test");
			my $type = $1;
			my @raw = $form->process($param);
			my $std = $form->process($param, $type);
			my $offline = $form->$type(undef, @raw);

			if ($std eq $offline and $std == $offline) {
				$html .= "'$param': raw: '@raw'; std: '$std'; offline: '$offline'<p/>";
			}
			else {
				$html .= "<font color='red'>'$param': raw: '@raw'; std: '$std'; offline: '$offline'</font><p/>";
			}
		}

		# do the interval test
		my $num   = $form->process('interval_interval');
		my $units = $form->process('interval_units');
		my $std_interval = $form->process('interval', 'interval');
		my $offline_interval = $form->interval(undef, "$num $units"); # pass in as it would be in an import file

		if ($std_interval eq $offline_interval and $std_interval == $offline_interval) {
			$html .= "'interval': raw: '$num $units'; std: '$std_interval'; offline: '$offline_interval'<p/>";
		}
		else {
			$html .= "<font color='red'>'interval': raw: '$num $units'; std: '$std_interval'; offline: '$offline_interval'</font><p/>";
		}
		

		# canned tests for things like all empty checkbox groups and yesNo fields
		$html .= "<p/>Other tests<p/>";

		# empty checkList
		my $cl = $form->checkList(undef, ''); # passing an empty list here is not going to work
		if ($cl eq '') {
			$html .= "empty CheckList is: ''<p/>";
		}
		else {
			$html .= "<font color='red'>empty CheckList is: '$cl'</font><p/>";
		}

		# empty date
		my $date = $form->date(undef, '');
		if ($date eq '') {
			$html .= "empty Date is: ''<p/>";
		}
		else {
			$html .= "<font color='red'>empty Date is: '$date'</font><p/>";
		}

		# empty datetime
		my $dt = $form->dateTime(undef, '');
		if ($dt eq '') {
			$html .= "empty DateTime is: ''<p/>";
		}
		else {
			$html .= "<font color='red'>empty DateTime is: '$dt'</font><p/>";
		}

		# empty hiddenList
		my $hl = $form->hiddenList(undef, ''); # passing an empty list here is not going to work
		if ($hl eq '') {
			$html .= "empty HiddenList is: ''<p/>";
		}
		else {
			$html .= "<font color='red'>empty HiddenList is: '$hl'</font><p/>";
		}

		# empty selectList
		my $sl = $form->selectList(undef, ''); # passing an empty list here is not going to work
		if ($sl eq '') {
			$html .= "empty SelectList is: ''<p/>";
		}
		else {
			$html .= "<font color='red'>empty SelectList is: '$sl'</font><p/>";
		}

		# empty timeField
		my $std_tf = $form->process('doesnotexist', 'timeField');
		my $tf = $form->timeField(undef, ''); # passing an empty list here is not going to work
		if ($tf eq $std_tf) {
			$html .= "empty TimeField is: '$std_tf'<p/>";
		}
		else {
			$html .= "<font color='red'>empty TimeField is: '$tf' (not '$std_tf')</font><p/>";
		}

		# yesNo
		my $yn = $form->yesNo(undef, '');
		if ($yn eq '') {
			$html .= "empty yesNo is: ''<p/>";
		}
		else {
			$html .= "<font color='red'>empty yesNo is: '$yn'</font><p/>";
		}


		return $self->_acWrapper("<pre>$html</pre>", "test");
	}
}

#-------------------------------------------------------------------

=head2 www_exportEvents ( )

Method to deliver this EMS's events in CSV format.

=cut

sub www_exportEvents {
	my $self = shift;
	
	return $self->session->privilege->insufficient unless $self->canAddEvents;

	my $i18n = WebGUI::International->new($self->session,'Asset_EventManagementSystem');
	my $csv = Text::CSV_XS->new({ eol => "\n", binary => 1 }); # TODO use their newline?
	
	# if we need to punt
	my @error_args = ($i18n->get('export error'), $i18n->get('export events'));
	
	# get standard & metaField labels TODO - refactor this
	my @std_labels = map $i18n->get($_), ( 'status', 'add/edit event title', 'add/edit event description',
		'add/edit event image', 'add/edit useSalesTax', 'price', 'add/edit event template', 'weight', 'sku',
		'sku template', 'add/edit event start date', 'add/edit event end date', 'add/edit event maximum attendees',
		'prereq set name field label' );

	my $meta_fields_aref = $self->getEventMetaDataArrayRef;
	my @meta_labels = map $_->{label}, @$meta_fields_aref;
	my @all_labels = (@std_labels, @meta_labels);

	# combine field labels for first line of CSV output
	return $self->_acWrapper(@error_args)
		unless $csv->combine(@all_labels);
	my $csvdata = $csv->string();

	# get events of this EMS
	my $events_std_data_aref = $self->getAllStdEventDetails;

	# get the prereqs
	my $prereqs_href   = $self->session->db->buildHashRef(<<"");
		SELECT prerequisiteId, name
		FROM EventManagementSystem_prerequisites

	my $templates_href = $self->session->db->buildHashRef(<<"");
		SELECT template.assetId, assetData.title
		FROM template 
		LEFT JOIN assetData
		ON assetData.assetId = template.assetId
		AND assetData.revisionDate = template.revisionDate

	# format useSalesTax(yes/no), startDate, endDate, and approved values
	my $dt = $self->session->datetime;
	for my $event (@$events_std_data_aref) {
		$event->{approved}       = $self->getEventStateLabel($event->{approved});
		$event->{startDate}      = $dt->epochToSet($event->{startDate},1);
		$event->{endDate}        = $dt->epochToSet($event->{endDate},1);
		$event->{useSalesTax}    = $event->{useSalesTax} ? 'Y' : 'N';
		$event->{prerequisiteId} = $prereqs_href->{$event->{prerequisiteId}};
		$event->{templateId}     = $templates_href->{$event->{templateId}};
	}

	# standard field names in the same order as the web forms
	my @std_fields = qw( approved title description imageId useSalesTax price templateId weight sku
		skuTemplate startDate endDate maximumAttendees prerequisiteId);

	# for each event, gather std & meta data & create CSV record
	for my $std_data_href (@$events_std_data_aref) {
		# get the std data
		my @std_data = map $std_data_href->{$_}, @std_fields;

		# get the meta data
		my ($meta_data_href) = $self->getEventMetaDataFields($std_data_href->{productId}, $self->get("globalMetadata"));
		my @meta_data = ();
		for my $meta_field_config_href (@$meta_fields_aref) {
			# get the value for this field, depending on the dataType
			my $value = $meta_data_href->{$meta_field_config_href->{fieldId}}->{fieldData};

			# format some field types
																 # if the type is,  then the value is 
			my $readable = 	$meta_field_config_href->{dataType} eq 'Date'		?	$dt->epochToSet($value)
						:	$meta_field_config_href->{dataType} eq 'DateTime'	?	$dt->epochToSet($value,1)
						:	$meta_field_config_href->{dataType} eq 'YesNo' 		?	( $value ? 'Y' : length($value) ? 'N' : '' )
						:	$meta_field_config_href->{dataType} eq 'TimeField'	?	$dt->secondsToTime($value)
						:															$value
						;

			$readable =~ s/\n/;/g;
			push @meta_data, $readable;
		}

		# create CSV record for this event or display error message
		if ($csv->combine(@std_data, @meta_data)) {
			$csvdata .= $csv->string();
		}
		else {
			return $self->_acWrapper(@error_args);
		}
	}

	# no errors, output file as attachment
	my $filename = $self->session->db->quickScalar(" SELECT title FROM assetData WHERE assetId = ? ", [ $self->getId ]);
	$filename =~ s/[^-\w.]//g; # old-school
	$self->session->http->setFilename("$filename.csv", 'application/excel');
	return $csvdata;
}

#-------------------------------------------------------------------

=head2 getEventDataFields ( )

Returns a form-field ordered aref of hrefs of event data fields (standard and meta) with these keys: name, label, type, and required.

=cut

sub getEventDataFields {
	my $self = shift;

	my $i18n = WebGUI::International->new($self->session,'Asset_EventManagementSystem');

	my $custom_rows_aref = $self->getEventMetaDataArrayRef;
	my @custom_rows = map {
			label		=>	$_->{label},
			name		=>	"metadata_$_->{fieldId}",
			required	=>	$_->{required},
			type		=>	$_->{dataType},
		}, @$custom_rows_aref;

	return [
		# std fields
		{ label => $i18n->get('status'), 							name => 'approved',			required => 0, type => 'text'		},
		{ label => $i18n->get('add/edit event title'), 				name => 'title', 			required => 1, type => 'text'		},
		{ label => $i18n->get('add/edit event description'),		name => 'description', 		required => 1, type => 'HTMLArea'	},
		{ label => $i18n->get('add/edit event image'), 				name => 'imageId',			required => 0, type => 'text'		},
		{ label => $i18n->get('add/edit useSalesTax'), 				name => 'useSalesTax', 		required => 0, type => 'yesNo'		},
		{ label => $i18n->get('price'), 							name => 'price', 			required => 1, type => 'float'		},
		{ label => $i18n->get('add/edit event template'), 			name => 'templateId', 		required => 0, type => 'template'	},
		{ label => $i18n->get('weight'), 							name => 'weight', 			required => 0, type => 'float'		},
		{ label => $i18n->get('sku'), 								name => 'sku', 				required => 1, type => 'text'		},
		{ label => $i18n->get('sku template'), 						name => 'skuTemplate', 		required => 0, type => 'text'		},
		{ label => $i18n->get('add/edit event start date'), 		name => 'startDate', 		required => 0, type => 'dateTime'	},
		{ label => $i18n->get('add/edit event end date'), 			name => 'endDate',			required => 0, type => 'dateTime'	},
		{ label => $i18n->get('add/edit event maximum attendees'),	name => 'maximumAttendees',	required => 1, type => 'integer'	},
		{ label => $i18n->get('prereq set name field label'),		name => 'prerequisiteId',	required => 0, type => 'text'		},

		@custom_rows,
	];
}

#-------------------------------------------------------------------

=head2 www_importEvents ( [ $errors_aref ] )

Show the CSV-file upload form, along with optional errors.

=cut

sub www_importEvents {
	my ($self) = shift;
	my $errors_aref = shift || [];

	return $self->session->privilege->insufficient unless $self->canAddEvents;
	my $i18n = WebGUI::International->new($self->session,'Asset_EventManagementSystem');
	my $form = $self->session->form;
	
	# header, with optional errors as unordered list
	my $page_header = $i18n->get('import form header');
	if (@$errors_aref) {
		$page_header .= "<ul>";
		for my $error_msg (@$errors_aref) {
			$page_header .= "<li>$error_msg</li>";
		}
		$page_header .= "</ul>";
	}

	# create the form
	my $f = WebGUI::HTMLForm->new( $self->session, action => $self->getUrl("func=doImportEvents"), enctype => 'multipart/form-data' );

	$f->file(
		-label     => $i18n->get('choose a file to import'),
		-hoverHelp => $i18n->get('import hoverhelp file'),
		-name      => 'file',
	);
	$f->selectBox(
		-label   => $i18n->get('what about duplicates'),
		-name    => 'duplicates_how',
		-hoverHelp => $i18n->get('import hoverhelp dups'),
		-value   => ($form->param('duplicates_how')||'skip'),
		-options => {
			skip      => $i18n->get('skip'),
			overwrite => $i18n->get('overwrite'),
		},
	);
	$f->radioList(
		-label   => $i18n->get('ignore first line'),
		-name    => 'ignore_first_line',
		-hoverHelp => $i18n->get('import hoverhelp first line'),
		-value   => ($form->param('ignore_first_line')||'no'),
		-options => {
			yes => $i18n->get('yes'),
			no  => $i18n->get('no'),
		},
	);
	$f->fieldSetStart('Fields');
	$f->raw(q[ <tr><td><table><tr><td style="width: 180px">&nbsp;</td><td style="width: 150px"> ].
			q[ <b>File Contains Field</b></td><td><b>Field Is Duplicate Key</b></td></tr> ]);

	# create the std & meta fields part of the form
	my $rows_aref = $self->getEventDataFields; # form-field ordered aref of hrefs with these keys: name, label, required, type
	my %row_data  = map { $_->{name}, $_ } @$rows_aref;
	for my $row (@$rows_aref) {
		$f->raw(qq[ <tr><td class="formDescription" style="width: 180px">$row->{label}</td><td> ]);
		# insert the first checkbox
		$f->raw(WebGUI::Form::Checkbox->new(
			$self->session,{
			-name    => "file_contains-$row->{name}",
			-value   => 1,
			-checked => ($row_data{$row->{name}}->{required} || $form->param("file_contains-$row->{name}")),
		})->toHtml());
		$f->raw(qq[ </td><td> ]);
		# insert the second checkbox
		$f->raw(WebGUI::Form::Checkbox->new(
			$self->session,{
			-name    => "check_duplicates-$row->{name}",
			-value   => 1,
			-checked => $form->param("check_duplicates-$row->{name}"),
		})->toHtml());
		$f->raw(qq[ </td></tr> ]);
	}

	$f->raw(q[ </table></td></tr> ]);
	$f->fieldSetEnd;
	$f->submit(-value=>$i18n->get('import events'));

	$self->getAdminConsole->setHelp('import events','Asset_EventManagementSystem');
	return $self->_acWrapper($page_header.'<p/>'.$f->print, $i18n->get('import events'));
}

#-------------------------------------------------------------------

=head2 doImportEvents ( )

Handle the uploading of a CSV event data file, along with other options.

=cut

my $max_errors = 10; # number of errors to collect before showing them, when we're in error-collecting mode.
sub www_doImportEvents {
	my $start_time = time;
	my $self = shift;

	return $self->session->privilege->insufficient unless $self->canAddEvents;
	my $i18n = WebGUI::International->new($self->session,'Asset_EventManagementSystem');
	my $csv = Text::CSV_XS->new({ binary => 1 });
	my $no_action_taken_error = { # on error, always let the user know that we didn't partially import their data
		type	=> 'general',
		message	=> $i18n->get("no import took place"),
	};

	# get input: CSV data
	my $storageId	= $self->session->form->param("file_file");
	my $storage		= WebGUI::Storage->get($self->session, $storageId);
	return $self->error([{ type => 'general', message => $i18n->get("enter import file") }], 'www_importEvents')
		unless $storage;
    my $filename	= $storage->addFileFromFormPost("file_file");
	my $csv_data	= $storage->getFileContentsAsScalar($filename);
	$storage->delete;

	# store the input on disk for processing - TODO can we do this whole thing more easily?
	my $fh = tempfile();
	print $fh $csv_data;
	seek $fh, 0, 0;

	# organize meta input: sorted fields included and duplicate keys
	my $skip_duplicates   = $self->session->form->process('duplicates_how')    eq 'skip' ? 1 : 0;
	my $ignore_first_line = $self->session->form->process('ignore_first_line') eq 'yes'  ? 1 : 0;
	my @params			= $self->session->form->param();
	my @fields_included	= grep s/^file_contains-(.+)$/$1/,    @params;
	my @dup_keys		= grep s/^check_duplicates-(.+)$/$1/, @params;
	return $self->error([$no_action_taken_error,{
				type	=> 'general',
				message	=> $i18n->get('import need dup key'),
			}], 'www_importEvents') unless @dup_keys;
	my @all_data_fields = @{ $self->getEventDataFields() }; # aref of sorted hrefs with name, label, required, type keys
	my $sku_is_required = grep { $_ eq 'sku' } @dup_keys;
	if (!$sku_is_required) {
		for my $field (@all_data_fields) { $field->{required} = 0 if $field->{name} eq 'sku' } # not required here
	}
	my @sorted_fields_included = ();
	for my $field (@all_data_fields) {
		if (grep { $_ eq $field->{name} } @fields_included) {
			push @sorted_fields_included, $field->{name};
		}
	}
	my @missing_required_fields = ();
	for my $field (grep $_->{required}, @all_data_fields) {
		if (!grep { $_ eq $field->{name} } @fields_included) {
			push @missing_required_fields, $field->{label};
		}
	}
	if (@missing_required_fields) {
		return $self->error([$no_action_taken_error,{
				type	=> 'general',
				message	=> $i18n->get('check required fields')."@missing_required_fields",
			}],
			'www_importEvents',
		);
	}

	# we sanity check all of the input before processing any of it
	# check all records for required fields and field count
	my $errors = [];
	my $prerequisites_href = {};
	if (grep /^prerequisiteId$/, @fields_included) {
		$prerequisites_href = $self->session->db->buildHashRef(" SELECT name, prerequisiteId FROM EventManagementSystem_prerequisites");
	}
	my $templates_href = {};
	if (grep /^templateId$/, @fields_included) {
		$templates_href = $self->session->db->buildHashRef(<<"");
				SELECT assetData.title, template.assetId
				FROM template 
				LEFT JOIN assetData
				ON assetData.assetId = template.assetId
				AND assetData.revisionDate = template.revisionDate

	}
	my %approved_values = ( Approved => 1, Denied => 0, Pending => -1, Cancelled => -2);
	my $meta_fields_aref = $self->getEventMetaDataArrayRef;
	my %meta_fields = ();
	@meta_fields{map {$_->{fieldId}} @$meta_fields_aref} = @$meta_fields_aref; # get them keyed by fieldId
	my $first_line = 1;
	my $before_check_time = time;
	while (my $line = do { local $/ = "\n"; <$fh> }) {
		if ($first_line and $ignore_first_line) {
			$first_line = 0;
			next;	
		}

		# line is blank - skip it, no error
		next if $line =~ /^[\s\r\n]*$/;

		# parse the line
		if (!$csv->parse($line)) {
			my $error_input = $csv->error_input;
			push @$errors,{
				type	=> 'general', # "There was an error processing this input: '$line'"
				message	=> sprintf $i18n->get('import record parse error'),
										$fh->input_line_number - $ignore_first_line, $error_input,
			};
			if (@$errors >= $max_errors) {
				return $self->error($errors, 'www_importEvents');
			}
			next;
		}

		my @columns = $csv->fields();

		# check the field count
		if (@columns != @fields_included) {
			push @$errors,{
				type	=> 'general',
				message	=> sprintf $i18n->get('field count mismatch'), $fh->input_line_number-$ignore_first_line, scalar @columns, scalar @fields_included,
			};
			if (@$errors >= $max_errors) {
				return $self->error($errors, 'www_importEvents');
			}
			next;
		}
		# check the required fields
		my %data = map { $sorted_fields_included[$_], $columns[$_] } 0..$#columns;
		$data{sku} ||= 'do not check this here - we will create one later if necessary' unless $sku_is_required;
		my $new_errors = $self->checkRequiredFields(\%data, $fh->input_line_number-$ignore_first_line);
		if (@$new_errors) {
			push @$errors, @$new_errors;
			return $self->error([$no_action_taken_error,@$errors], 'www_importEvents') if @$errors >= $max_errors;
		}
		#check that approved, if present, is a good value
		if (exists $data{approved} && ! grep { lc $_ eq lc $data{approved} } %approved_values) {
			push @$errors, {
				type	=>	'general',
				message	=>	sprintf $i18n->get('import invalid status'), $fh->input_line_number-$ignore_first_line, $data{approved},
			};
			return $self->error([$no_action_taken_error,@$errors], 'www_importEvents') if @$errors >= $max_errors;
		}
		#check that prerequisiteId, if present, is a good value
		if (exists $data{prerequisiteId} && !exists $prerequisites_href->{$data{prerequisiteId}}) {
			push @$errors, {
				type	=>	'general',
				message	=>	sprintf $i18n->get('import invalid prereq'), $fh->input_line_number-$ignore_first_line, $data{prerequisiteId},
			};
			return $self->error([$no_action_taken_error,@$errors], 'www_importEvents') if @$errors >= $max_errors;
		}
		#check that templateId, if present, is a good value
		if (exists $data{templateId} && !exists $templates_href->{$data{templateId}}) {
			push @$errors, {
				type	=>	'general',
				message	=>	sprintf $i18n->get('import invalid template'), $fh->input_line_number-$ignore_first_line, $data{templateId},
			};
			return $self->error([$no_action_taken_error,@$errors], 'www_importEvents') if @$errors >= $max_errors;
		}
	}
	my $after_check_time = time;

	# errors? output them instead of proceeding with the import
	return $self->error([$no_action_taken_error,@$errors], 'www_importEvents') if @$errors;

	# organize our existing events by duplicate keys
	my %duplicate_events = ();
	for my $event_href (@{ $self->getAllStdEventDetails }) {
		my $event_meta_data_href = $self->getEventMetaDataFields($event_href->{productId});
		my $dup_key = join '|', map { /^metadata_(.+)/ ? $event_meta_data_href->{$1}->{fieldData} : $event_href->{$_} } @dup_keys;
		$duplicate_events{$dup_key} = $event_href->{productId};
	}

	# input is deemed sane - time to process it
	my $total_lines = $fh->input_line_number;
	seek $fh, 0, 0; # start of the file, again
	my %all_data_fields;
	@all_data_fields{map $_->{name}, @all_data_fields} = @all_data_fields; # by name
	my $existing_events_aref = $self->getAllStdEventDetails;
	$first_line = 1;
	my @skipped     = ();
	my @overwritten = ();
	my @blank_lines = ();
	my $before_process_time = time;
	while (my $line = do { local $/ = "\n"; <$fh> }) {
		if ($first_line and $ignore_first_line) {
			$first_line = 0;
			next;
		}

		# line is blank - skip it, no error
		if ($line =~ /^[\s\r\n]*$/) {
			push @blank_lines, $fh->input_line_number - $ignore_first_line - $total_lines; # the record number
			next;
		}

		# parse the line
		if (!$csv->parse($line)) {
			my $error_input = $csv->error_input;
			push @$errors,{
				type	=> 'general', # "There was an error processing this input: '$line'"
				message	=> sprintf $i18n->get('import line parse error'), $error_input, $fh->input_line_number - $ignore_first_line - $total_lines,
			};
			# this should "never happen" (TM)
			return $self->error($errors, 'www_importEvents');
		}

		my @columns = $csv->fields();
		my %data = map { $sorted_fields_included[$_], $columns[$_] } 0..$#columns;

		# get the data in the form in which it will be compared to existing events
		#  to find dups, as well as how we'll store it in the db
		for my $key (keys %data) {
			if ($key eq 'approved') {
				$data{$key} = $approved_values{$data{$key}};
			}
			else {
				my $method = $all_data_fields{$key}->{type};
				if ($method =~ /^(?:hidden|check|select)List$/i) {
					$data{$key} = $self->session->form->$method(undef, split /;/, $data{$key});
				}
				else {
					$data{$key} = $self->session->form->$method(undef, $data{$key});
				}
			}
		}

		# store it or skip it
		my $is_new = 1;
		my $this_dup_key = join '|', map $data{$_}, @dup_keys;
		my $product_id = "new";
		if (exists $duplicate_events{$this_dup_key}) {
			if ($skip_duplicates) {
				push @skipped, $fh->input_line_number - $ignore_first_line - $total_lines; # the record number
				next;
			}
			push @overwritten, $fh->input_line_number - $ignore_first_line - $total_lines; # the record number
			$is_new = 0;
			$product_id = $duplicate_events{$this_dup_key}; # overwrite this product_id
			# TODO load everything for this product_id so that we only overwrite the fields that are in the CSV file
		}

		# reasonable defaults?
		$data{sku}      = $self->session->id->generate	unless exists $data{sku};
		$data{approved} = $approved_values{Pending}		unless exists $data{approved};

		# store data in the EMS_products table
		my $ems_products_href = {
			productId			=> $product_id,
			startDate			=> $data{startDate},
			endDate				=> $data{endDate},
			maximumAttendees	=> $data{maximumAttendees},
			approved			=> $data{approved},
			prerequisiteId		=> $prerequisites_href->{$data{prerequisiteId}},
			#passId				=> '', # NULL for these - there's no way to import them
			#imageId			=> '',
			#passType			=> '',
		};
		my $pid = $self->setCollateral("EventManagementSystem_products", "productId",$ems_products_href,1,1);

		# store data in EMS_metaData
		my @meta_fields = grep { $_->{name} =~ /^metadata_/ } @all_data_fields;
		foreach my $field (@meta_fields) {
			$field->{name} =~ /^metadata_(.+)$/;
			my $field_id = $1;
			my $data = $data{$field->{name}};
			my $sql = "insert into EventManagementSystem_metaData values (".
										$self->session->db->quoteAndJoin([$field_id, $pid, $data]).
										") on duplicate key update fieldData=".
										$self->session->db->quote($data);
			$self->session->db->write($sql);
		}

		# store data in products
		my $data_href = {
			productId	=> $pid,
			title		=> $data{title},
			description	=> $data{description},
			price		=> $data{price},
			useSalesTax	=> ($data{useSalesTax}||0),
			weight		=> ($data{weight}||0),
			sku			=> $data{sku},
			skuTemplate	=> ($data{skuTemplate}||''),
			templateId	=> ($templates_href->{$data{templateId}}||''),
		};
		if ($is_new) {
			$self->session->db->setRow("products", "productId", $data_href, $pid);
			$duplicate_events{$this_dup_key} = $product_id;
		}
		else {
			$self->session->db->setRow("products", "productId", $data_href);
		}
	}
	my $after_process_time = time;

	# acknowledge success - &error will work fine - with the number of records processed/imported/skipped/overwritten
	my $processed_count = $fh->input_line_number - $ignore_first_line - $total_lines;
	my $other_count     = $skip_duplicates ? @skipped : @overwritten;
	my $imported_count  = $processed_count - $other_count - @blank_lines;
	my $what_done       = $i18n->get($skip_duplicates ? 'skipped' : 'overwritten');
	my $message         = sprintf $i18n->get('import ok'), $processed_count, $imported_count, scalar(@blank_lines), $other_count, $what_done;
	my $html            = "<li>$message</li>";
	$html              .= join '', map "<li>".sprintf($i18n->get('import blank line'),$_)."</li>", @blank_lines;
	$html              .= join '', map "<li>".sprintf($i18n->get('import other line'),$_,$what_done)."</li>", ($skip_duplicates ? @skipped : @overwritten);

	my $total_time   = $after_process_time - $start_time;
	my $prep_time    = $before_check_time - $start_time;
	my $check_time   = $after_check_time - $before_check_time;
	my $prep_time2   = $before_process_time - $after_check_time;
	my $process_time = $after_process_time - $before_process_time;
	my $time_block   = <<"";
		<div style="display: none">
			total time: $total_time<br/>
			prep time: $prep_time<br/>
			check time: $check_time<br/>
			prep2 time: $prep_time2<br/>
			process time: $process_time<br/>
		</div>

	return $self->_acWrapper("$time_block<ul>$html</ul>", $i18n->get('import events'));
}

#-------------------------------------------------------------------

=head2 www_managePurchases ( )

Method to display list of purchases.  Event admins can see everyone's purchases.

=cut

sub www_managePurchases {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canView;
	return $self->session->privilege->insufficient if $self->session->var->get('userId') eq '1';
	my $isAdmin = $self->canAddEvents;
	return $self->www_viewPurchase unless $isAdmin;
	my $i18n = WebGUI::International->new($self->session,'Asset_EventManagementSystem');
	my $whereClause = ($isAdmin)?'':" and (t.userId='".$self->session->user->userId."' or b.userId='".$self->session->user->userId."' or b.createdByUserId='".$self->session->user->userId."') and e.endDate > '".$self->session->datetime->time()."'";
	my $sql = "select distinct(t.transactionId) as purchaseId, t.initDate as initDate from transaction as t, EventManagementSystem_purchases as p, EventManagementSystem_registrations as r, EventManagementSystem_badges as b, EventManagementSystem_products as e where p.transactionId=t.transactionId and b.badgeId=r.badgeId and t.status='Completed' and p.purchaseId=r.purchaseId and r.productId=e.productId $whereClause order by t.initDate";
	my $sth = $self->session->db->read($sql);
	my @purchasesLoop;
	while (my $purchase = $sth->hashRef) {
		$purchase->{datePurchasedHuman} = $self->session->datetime->epochToHuman($purchase->{initDate});
		$purchase->{purchaseUrl} = $self->getUrl("func=viewPurchase;tid=".$purchase->{purchaseId});

		push(@purchasesLoop,$purchase);
	}
	my %var;
	$var{managePurchasesTitle} = $i18n->get('manage purchases');
	$var{'purchaseId.label'} = $i18n->echo('Purchase Id');
	$var{'datePurchasedHuman.label'} = $i18n->echo('Purchase Date');
	$sth->finish;
	$var{'purchasesLoop'} = \@purchasesLoop;

	return $self->processStyle($self->processTemplate(\%var,$self->getValue("managePurchasesTemplateId")));
}

#-------------------------------------------------------------------

=head2 www_viewPurchase ( )

Method to display a purchase.  From this screen, admins can 
return the whole purchase, return a whole badge (registration, 
a.k.a itinerary for a single person), or return a single event
from an itinerary.  The purchaser can just add events to 
individual registrations that have at least one event that 
hasn't occurred yet.

=cut

sub www_viewPurchase {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canView;
	my $returnWoStyle = shift;
	my $badgeId = shift || $self->session->form->process('badgeId');
	my $tid = $self->session->form->process('tid');
	my %var;
	if ($badgeId) {
		my %var = $self->session->db->quickHash("select * from EventManagementSystem_badges where badgeId=?",[$badgeId]);
		my $isAdmin = $self->canAddEvents;
		my ($userId) = $self->session->db->quickArray("select userId from transaction where transactionId=?",[$tid]);
		my $i18n = WebGUI::International->new($self->session,'Asset_EventManagementSystem');
		my @purchasesLoop;
		$var{registrantView} = 1;
		$var{canReturnTransaction} = 0;
		my $filter = ($isAdmin)?'':' and r.returned=0 ';
		my $sql2 = "select r.registrationId, p.title, p.description, p.price, p.templateId, p.sku, r.returned, e.approved, e.maximumAttendees, e.startDate, e.endDate, b.userId, b.createdByUserId, e.productId from EventManagementSystem_registrations as r, EventManagementSystem_badges as b, EventManagementSystem_products as e, EventManagementSystem_purchases as z, products as p, transaction where p.productId = r.productId and p.productId = e.productId and r.badgeId=b.badgeId and r.purchaseId=z.purchaseId and r.badgeId=? and transaction.transactionId=z.transactionId and transaction.status='Completed' $filter group by r.registrationId order by e.startDate";
		my $sth2 = $self->session->db->read($sql2,[$badgeId]);
		my $purchase = {};
		$purchase->{regLoop} = [];
		$purchase->{canReturnItinerary} = 0;
		while (my $reg = $sth2->hashRef) {
			$reg->{startDateHuman} = $self->session->datetime->epochToHuman($reg->{'startDate'});
			$reg->{endDateHuman} = $self->session->datetime->epochToHuman($reg->{'endDate'});
			$purchase->{canAddEvents} = 1 if ($isAdmin || ($userId eq $self->session->var->get('userId')) || ($reg->{userId} eq $self->session->var->get('userId'))  || ($reg->{createdByUserId} eq $self->session->var->get('userId')));
			my ($isMainEvent) = $self->session->db->quickArray("select productId from EventManagementSystem_products where productId = ? and (prerequisiteId is NULL or prerequisiteId = '')",[$reg->{productId}]);
			$purchase->{purchaseEventId} = $reg->{productId} if ($isMainEvent && $reg->{'returned'} eq '0');
			push(@{$purchase->{regLoop}},$reg);
			}
		push(@purchasesLoop,$purchase);

		if ($self->canAddEvents) {  #Build list of badges made that weren't actually purchased and provide an interface for attaching them to purchases
			my @incompleteTransactions;

			# All transactionIds associated with this person (badge)
			my $transactionIds = $self->session->db->buildHashRef("select distinct(c.transactionId) from EventManagementSystem_registrations a
									  join products b on a.productId=b.productId
									  left join EventManagementSystem_purchases d on a.purchaseId=d.purchaseId
									  left join transaction c on d.transactionId=c.transactionId where c.transactionId is not NULL and a.badgeId=?",[$badgeId]);

			# All purchaseIds associated with this person (badge)
			my @purchaseIds = $self->session->db->buildArray("select distinct(a.purchaseId) from EventManagementSystem_registrations a
									  join products b on a.productId=b.productId
									  left join EventManagementSystem_purchases d on a.purchaseId=d.purchaseId
									  left join transaction c on d.transactionId=c.transactionId where c.transactionId is null and a.badgeId=?",[$badgeId]);


			foreach my $purchaseId (@purchaseIds) {
				my %data;
				my $loop = $self->session->db->buildArrayRefOfHashRefs("select a.registrationid, b.title, a.returned, c.transactionId, c.status as transactionStatus, b.sku 
						    from EventManagementSystem_registrations a join products b on a.productId=b.productId 
						    left join EventManagementSystem_purchases d on a.purchaseId=d.purchaseId 
						    left join transaction c on d.transactionId=c.transactionId where (a.badgeId is NULL or c.transactionId is NULL or d.purchaseId is NULL)
						    and a.badgeId=? and a.purchaseId=?",[$badgeId, $purchaseId]);


				$data{'purchaseId'} = $purchaseId;
				$data{'form.transactionSelect'} = ($purchaseId) ? WebGUI::Form::SelectBox($self->session, {name=>"transactionId", options=>$transactionIds}) : "";
				$data{'form.header'} = WebGUI::Form::formHeader($self->session, {action=>$self->getUrl("func=linkTransactionToPurchase")}).
						       WebGUI::Form::hidden($self->session, {name=>"purchaseId", value=>$purchaseId}).
						       WebGUI::Form::hidden($self->session, {name=>"badgeId", value=>$badgeId});
				$data{'form.footer'} = WebGUI::Form::formFooter($self->session);
				$data{'form.submit'} = ($purchaseId) ? WebGUI::Form::Submit($self->session, {value=>"Assign Selected Transaction to this Purchase"}) : "Purchase Id is Null and cannot be linked to any transactions!";
				$data{'unpurchased_loop'} = $loop;
				$data{'deleteRegistration.url'} = $self->getUrl("func=deleteRegistrationsByPurchaseId;pid=".$purchaseId).";bid=".$badgeId;
				$data{'deleteRegistration.label'} = "Delete ALL Registrations associated with this PurchaseId PERMANENTLY";
				$data{'canDeleteRegistration'} =  ($purchaseId);

				push(@incompleteTransactions,\%data);
			}

			$var{'badgeId'} = $badgeId;
			$var{'incompleteTransactions_loop'} = \@incompleteTransactions;
			$var{'hasIncompleteTransactions'} = scalar(@incompleteTransactions);
		}

		$var{viewPurchaseTitle} = $i18n->get('view purchase');
		$var{canReturn} = $isAdmin;
		$var{transactionId} = $tid;
		$var{appUrl} = $self->getUrl;
		$var{purchasesLoop} = \@purchasesLoop;
		return $self->processTemplate(\%var,$self->getValue("viewPurchaseTemplateId")) if $returnWoStyle;
		return $self->processStyle($self->processTemplate(\%var,$self->getValue("viewPurchaseTemplateId")));
	} elsif($tid) {
		my $showAll = $self->session->form->get('showAll');
		my $isAdmin = $self->canAddEvents;
		my ($userId) = $self->session->db->quickArray("select userId from transaction where transactionId=?",[$tid]);
		my $i18n = WebGUI::International->new($self->session,'Asset_EventManagementSystem');
		my $filter = ($isAdmin)?'':' and r.returned=0 ';
		my $sql = "select distinct(r.purchaseId), b.* from EventManagementSystem_registrations as r, EventManagementSystem_badges as b, EventManagementSystem_purchases as t, transaction where r.badgeId=b.badgeId and r.purchaseId=t.purchaseId and transaction.transactionId=t.transactionId and t.transactionId=? and transaction.status='Completed' $filter order by b.lastName";
		$sql = "select distinct(r.purchaseId) from EventManagementSystem_registrations as r,  EventManagementSystem_purchases as t, transaction where r.purchaseId=t.purchaseId and transaction.transactionId=t.transactionId and t.transactionId=? and transaction.status='Completed' $filter order by b.lastName" if $showAll;
		my $sth = $self->session->db->read($sql,[$tid]);
		my @purchasesLoop;
		$var{canReturnTransaction} = 0;
		while (my $purchase = $sth->hashRef) {
			$badgeId = $purchase->{badgeId};
			my $pid = $purchase->{purchaseId};
			my $sql2 = "select r.registrationId, p.title, p.description, p.price, p.templateId, p.sku, r.returned, e.approved, e.maximumAttendees, e.startDate, e.endDate, b.userId, b.createdByUserId, e.productId from EventManagementSystem_registrations as r, EventManagementSystem_badges as b, EventManagementSystem_products as e, EventManagementSystem_purchases as z, products as p, transaction where p.productId = r.productId and p.productId = e.productId and r.badgeId=b.badgeId and r.purchaseId=z.purchaseId and r.badgeId=? and r.purchaseId=? $filter and transaction.transactionId=z.transactionId and transaction.status='Completed' group by r.registrationId order by b.lastName";
			$sql2 = "select r.registrationId, p.title, p.description, p.price, p.templateId, r.returned, e.approved, e.maximumAttendees, e.startDate, e.endDate, e.productId from EventManagementSystem_registrations as r, EventManagementSystem_products as e, EventManagementSystem_purchases as z, products as p, transaction where p.productId = r.productId and p.productId = e.productId and r.purchaseId=z.purchaseId and and r.purchaseId=? $filter and transaction.transactionId=z.transactionId and transaction.status='Completed' group by r.registrationId" if $showAll;
			my $sth2 = $self->session->db->read($sql2,[$badgeId,$pid]);
			$purchase->{regLoop} = [];
			$purchase->{canReturnItinerary} = 0;
			while (my $reg = $sth2->hashRef) {
				$reg->{startDateHuman} = $self->session->datetime->epochToHuman($reg->{'startDate'});
				$reg->{endDateHuman} = $self->session->datetime->epochToHuman($reg->{'endDate'});
				$purchase->{canReturnItinerary} = 1 unless $reg->{'returned'};
				$purchase->{canAddEvents} = 1 if ($isAdmin || ($userId eq $self->session->var->get('userId')) || ($reg->{userId} eq $self->session->var->get('userId'))  || ($reg->{createdByUserId} eq $self->session->var->get('userId')));
				my ($isMainEvent) = $self->session->db->quickArray("select productId from EventManagementSystem_products where productId = ? and (prerequisiteId is NULL or prerequisiteId = '')",[$reg->{productId}]);
				$purchase->{purchaseEventId} = $reg->{productId} if ($isMainEvent && $reg->{'returned'} eq '0');
				push(@{$purchase->{regLoop}},$reg);
			}
			$var{canReturnTransaction} = 1 if $purchase->{canReturnItinerary};
			push(@purchasesLoop,$purchase);
		}

		$var{viewPurchaseTitle} = $i18n->get('view purchase');
		$var{canReturn} = $isAdmin;
		$var{transactionId} = $tid;
		$var{appUrl} = $self->getUrl;
		$sth->finish;
		$var{purchasesLoop} = \@purchasesLoop;
		return $self->processStyle($self->processTemplate(\%var,$self->getValue("viewPurchaseTemplateId")));
	} else {
		my $isAdmin = $self->canAddEvents;
		my $filter = ($isAdmin)?'':' and r.returned=0 ';
		my $i18n = WebGUI::International->new($self->session,'Asset_EventManagementSystem');
		my $sql = "select distinct(r.purchaseId), b.* from EventManagementSystem_registrations as r, EventManagementSystem_badges as b, EventManagementSystem_purchases as t, transaction where r.badgeId=b.badgeId and r.purchaseId=t.purchaseId and transaction.transactionId=t.transactionId and transaction.status='Completed' and (b.userId=? or transaction.userId=? or b.createdByUserId=?) $filter order by b.lastName";
		my $userId = $self->session->form->get('userId') || $self->session->var->get('userId');
		my $sth = $self->session->db->read($sql,[$userId,$userId,$userId]);
		my @purchasesLoop;
		$var{canReturnTransaction} = 0;
		while (my $purchase = $sth->hashRef) {
			$badgeId = $purchase->{badgeId};
			my $pid = $purchase->{purchaseId};
			my $sql2 = "select r.registrationId, p.title, p.description, p.price, p.templateId, r.returned, e.approved, e.maximumAttendees, e.startDate, e.endDate, b.userId, b.createdByUserId, e.productId from EventManagementSystem_registrations as r, EventManagementSystem_badges as b, EventManagementSystem_products as e, EventManagementSystem_purchases as z, products as p, transaction where p.productId = r.productId and p.productId = e.productId and r.badgeId=b.badgeId and r.purchaseId=z.purchaseId and r.badgeId=? and r.purchaseId=? and transaction.transactionId=z.transactionId and transaction.status='Completed' $filter group by r.registrationId order by b.lastName";
			my $sth2 = $self->session->db->read($sql2,[$badgeId,$pid]);
			$purchase->{regLoop} = [];
			$purchase->{canReturnItinerary} = 0;
			while (my $reg = $sth2->hashRef) {
				$reg->{startDateHuman} = $self->session->datetime->epochToHuman($reg->{'startDate'});
				$reg->{endDateHuman} = $self->session->datetime->epochToHuman($reg->{'endDate'});
				$purchase->{canReturnItinerary} = 1 unless $reg->{'returned'};
				$purchase->{canAddEvents} = 1 if ($isAdmin || ($userId eq $self->session->var->get('userId')) || ($reg->{userId} eq $self->session->var->get('userId'))  || ($reg->{createdByUserId} eq $self->session->var->get('userId')));
				my ($isMainEvent) = $self->session->db->quickArray("select productId from EventManagementSystem_products where productId = ? and (prerequisiteId is NULL or prerequisiteId = '')",[$reg->{productId}]);
				$purchase->{purchaseEventId} = $reg->{productId} if ($isMainEvent && $reg->{'returned'} eq '0');
				push(@{$purchase->{regLoop}},$reg);
			}
			$var{canReturnTransaction} = 1 if $purchase->{canReturnItinerary};
			push(@purchasesLoop,$purchase);
		}

		$var{viewPurchaseTitle} = $i18n->get('view purchase');
		$var{canReturn} = $isAdmin;
		$var{transactionId} = $tid;
		$var{appUrl} = $self->getUrl;
		$sth->finish;
		$var{purchasesLoop} = \@purchasesLoop;
		return $self->processStyle($self->processTemplate(\%var,$self->getValue("viewPurchaseTemplateId")));
	}
}

#-------------------------------------------------------------------

=head2 www_deleteRegistrationsByPurchaseId

Method to delete all entries in EMS_registrations associated with a particular purchaseId

RLJ -- This method is a stop gap to allow GAMA to clean up bad data introduced by early bugs in the system

=cut

sub www_deleteRegistrationsByPurchaseId {
	my $self = shift;
	my $purchaseId = $self->session->form->get("pid");
	my $badgeId = $self->session->form->get("bid");

	return $self->session->privilege->insufficient unless ($self->canAddEvents);

	$self->session->db->write("delete from EventManagementSystem_registrations where purchaseId=?",[$purchaseId]);

	return $self->www_viewPurchase(undef, $badgeId);	
}

#-------------------------------------------------------------------

=head2 www_linkTransactionToPurchase

Method to create entry in EMS_purchases based on user selected transactionId for a purchaseId

RLJ -- This method is a stop gap to allow GAMA to clean up bad data introduced by early bugs in the system

=cut

sub www_linkTransactionToPurchase {
	my $self = shift;
	my $transactionId = $self->session->form->process("transactionId", "selectBox");
	my $purchaseId = $self->session->form->get("purchaseId");
	my $badgeId = $self->session->form->get("badgeId");

	return $self->session->privilege->insufficent unless ($self->canAddEvents);

	$self->session->db->setRow("EventManagementSystem_purchases", "purchaseId",
				   { purchaseId    => "new",
				     transactionId => $transactionId,
				   }, $purchaseId);

	return $self->www_viewPurchase(undef, $badgeId);

}

#-------------------------------------------------------------------

=head2 www_addEventsToBadge ( )

Method to go into badge-addition mode.

=cut

sub www_addEventsToBadge {
	my $self = shift;
	my $isAdmin = $self->canAddEvents;
	my $bid = $self->session->form->process('bid') || 'none';
	my $eventId = $self->session->form->process('eventId');
	unless ($bid eq 'none') {
		my ($userId,$createdByUserId) = $self->session->db->quickArray("select userId, createdByUserId from EventManagementSystem_badges where badgeId=?",[$bid]);
	    unless($isAdmin || $userId eq $self->session->user->userId || $createdByUserId eq $self->session->user->userId) {
	      return $self->session->privilege->insufficient();
	    }
		$self->session->scratch->set('EMS_add_purchase_badgeId',$bid);
		my @pastEvents = $self->session->db->buildArray("select r.productId from EventManagementSystem_registrations as r, EventManagementSystem_purchases as p, transaction as t where r.returned=0 and r.badgeId=? and t.transactionId=p.transactionId and t.status='Completed' and p.purchaseId=r.purchaseId group by productId",[$bid]);
		$self->session->scratch->set('EMS_add_purchase_events',join("\n",@pastEvents));
		my $purchaseId = $self->session->form->process('purchaseId');
		if ($purchaseId ne "") {
			# if we're loading a badge that's in the cart, put its stuff in the scratch cart along with the already-purchased events for this badgeId.
			$self->session->scratch->set("currentPurchase",$purchaseId);
            my ($badgeId) 
                = $self->session->db->quickArray(
                    "SELECT badgeId FROM EventManagementSystem_sessionPurchaseRef WHERE sessionId=? AND purchaseId=?",
                    [$self->session->getId,$purchaseId]
                );
			my $theseRegs = $self->session->db->buildArrayRefOfHashRefs("select r.*, p.price, q.prerequisiteId from EventManagementSystem_registrations as r, EventManagementSystem_products as q, products as p where p.productId=r.productId and q.productId=r.productId and r.returned=0 and r.badgeId=?",[$badgeId]);
			foreach (@$theseRegs) {
				push(@pastEvents,$_->{productId}) unless isIn($_->{productId},@pastEvents);
				$eventId = $_->{productId} unless $_->{prerequisiteId};
			}
			$self->removePurchaseFromCart($purchaseId);
            # Remove from the sessionPurchaseRef, it will be added again when
            # the user is finished and clicks "Add to cart" again
            $self->session->db->write(
                "DELETE FROM EventManagementSystem_sessionPurchaseRef WHERE sessionId=? AND purchaseId=? AND badgeId=?",
                [$self->session->getId, $purchaseId, $badgeId]
            );
		} else {
			# gotta use the existing purchaseId, b/c we're loading a completed purchase.
			my ($purchaseId) = $self->session->db->quickArray("select purchaseId from EventManagementSystem_registrations where badgeId=? and productId=? and purchaseId != '' and returned=0 and purchaseId is not null limit 1",[$bid,$eventId]);
            $self->session->scratch->set("currentPurchase",$purchaseId);
            $self->session->db->write(
                "INSERT INTO EventManagementSystem_sessionPurchaseRef (sessionId, purchaseId, badgeId) VALUES (?,?,?)",
                [$self->session->getId, $purchaseId, $bid]
            );
		}
		$self->session->scratch->set('EMS_scratch_cart',join("\n",@pastEvents));
		$self->session->scratch->set('currentMainEvent',$eventId);
		$self->session->scratch->set('currentBadgeId',$bid);
		return $self->www_search();
	} else {
		my $purchaseId = $self->session->form->process('purchaseId');
		if ($purchaseId ne "") {
			$self->removePurchaseFromCart($purchaseId);
            $self->session->db->write(
                "DELETE FROM EventManagementSystem_sessionPurchaseRef WHERE purchaseId=?",
                [$purchaseId]
            );
		}
	}
	return $self->www_resetScratchCart();
}

#-------------------------------------------------------------------

=head2 removePurchaseFromCart ( )

Method to remove some items from the cart

=cut

sub removePurchaseFromCart {
	my $self = shift;
	my $purchaseId = shift;
	my @eventsToSubtract = $self->session->db->buildArray("select r.productId from EventManagementSystem_registrations as r where r.purchaseId=? and r.returned=0",[$purchaseId]);
	my $shoppingCart = WebGUI::Commerce::ShoppingCart->new($self->session);
	my ($items, $nothing) = $shoppingCart->getItems;
	foreach my $event (@eventsToSubtract) {
		foreach my $item (@$items) {
			if ($item->{item}->{_event}->{productId} eq $event) {
				$shoppingCart->setQuantity($event,'Event',($item->{quantity} - 1));
			}
		}
	}
}
#-------------------------------------------------------------------

=head2 www_returnItem ( )

Method to set some registrations as returned.

=cut

sub www_returnItem {
	my $self = shift;
	my $isAdmin = $self->canAddEvents;
	my $rid = $self->session->form->process('rid');
	my $tid = $self->session->form->process('tid');
	my $pid = $self->session->form->process('pid');
	my @regs;
	if ($pid) {
		@regs = $self->session->db->buildArray("select registrationId from EventManagementSystem_registrations where purchaseId=?",[$pid]);
	} elsif ($tid) {
		@regs = $self->session->db->buildArray("select registrationId from EventManagementSystem_purchases as t,EventManagementSystem_registrations as r where r.purchaseId=t.purchaseId and t.transactionId=?",[$tid]);
	} elsif ($rid) {
		@regs = ($rid);
	}
	foreach (@regs) {
		$self->session->db->write("update EventManagementSystem_registrations set returned=1 where registrationId=?",[$_]);
	}
	return $self->www_managePurchases;
}

#-------------------------------------------------------------------
sub www_editEventMetaDataField {
	my $self = shift;
	my $fieldId = shift || $self->session->form->process("fieldId");
	my $error = shift;
	return $self->session->privilege->insufficient unless ($self->canAddEvents);
	my $i18n2 = WebGUI::International->new($self->session,'Asset_EventManagementSystem');
	my $i18n = WebGUI::International->new($self->session,"WebGUIProfile");
	my $f = WebGUI::HTMLForm->new($self->session, (
		action => $self->getUrl("func=editEventMetaDataFieldSave;fieldId=".$fieldId)
	));
	my $data = {};
	if ($error) {
		# load submitted data.
		$data = {
			name => $self->session->form->process("name"),
			label => $self->session->form->process("label"),
			dataType => $self->session->form->process("dataType",'fieldType'),
			visible => $self->session->form->process("visible",'yesNo'),
			required => $self->session->form->process("required",'yesNo'),
			possibleValues => $self->session->form->process("possibleValues",'textarea'),
			defaultValues => $self->session->form->process("defaultValues",'textarea'),
		};
		$f->readOnly(
			-name => 'error',
			-label => $i18n2->get('error'),
			-value => '<span style="color:red;font-weight:bold">'.$error.'</span>',
		);
	} elsif ($fieldId ne 'new') {
		$data = $self->session->db->quickHashRef("select * from EventManagementSystem_metaField where fieldId=?",[$fieldId]);
	} else {
		# new field defaults
		$data = {
			name => $i18n2->get('type name here'),
			label => $i18n2->get('type label here'),
			dataType => 'text',
			visible => 0,
			required => 0,
			autoSearch => 0
		};
	}
	$f->text(
		-name => "name",
		-label => $i18n->get(475),
		-hoverHelp => $i18n->get('475 description'),
		-extras=>(($data->{name} eq $i18n2->get('type name here'))?' style="color:#bbbbbb" ':'').' onblur="if(!this.value){this.value=\''.$i18n2->get('type name here').'\';this.style.color=\'#bbbbbb\';}" onfocus="if(this.value == \''.$i18n2->get('type name here').'\'){this.value=\'\';this.style.color=\'\';}"',
		-value => $data->{name},
	);
	$f->text(
		-name => "label",
		-label => $i18n->get(472),
		-hoverHelp => $i18n->get('472 description'),
		-value => $data->{label},
		-extras=>(($data->{label} eq $i18n2->get('type label here'))?' style="color:#bbbbbb" ':'').' onblur="if(!this.value){this.value=\''.$i18n2->get('type label here').'\';this.style.color=\'#bbbbbb\';}" onfocus="if(this.value == \''.$i18n2->get('type label here').'\'){this.value=\'\';this.style.color=\'\';}"',
	);
	$f->yesNo(
		-name=>"visible",
		-label=>$i18n->get('473a'),
		-hoverHelp=>$i18n->get('473a description'),
		-value=>$data->{visible}
	);
	$f->yesNo(
		-name=>"required",
		-label=>$i18n->get(474),
		-hoverHelp=>$i18n->get('474 description'),
		-value=>$data->{required}
	);
	my $fieldType = WebGUI::Form::FieldType->new($self->session,
		-name=>"dataType",
		-label=>$i18n->get(486),
		-hoverHelp=>$i18n->get('486 description'),
		-value=>ucfirst $data->{dataType},
		-defaultValue=>"Text",
	);
	my @profileForms = ();
	foreach my $form ( sort @{ $fieldType->get("types") }) {
		next if $form eq 'DynamicField';
		my $cmd = join '::', 'WebGUI::Form', $form;
		eval "use $cmd";
		my $w = eval {"$cmd"->new($self->session)};
		push @profileForms, $form if $w->get("profileEnabled");
	}

	$fieldType->set("types", \@profileForms);
	$f->raw($fieldType->toHtmlWithWrapper());
	$f->textarea(
		-name => "possibleValues",
		-label => $i18n->get(487),
		-hoverHelp => $i18n->get('487 description'),
		-value => $data->{possibleValues},
	);
	$f->textarea(
		-name => "defaultValues",
		-label => $i18n->get(488),
		-hoverHelp => $i18n->get('488 description'),
		-value => $data->{defaultValues},
	);
	$f->yesNo(
		-name => "autoSearch",
		-label => $i18n2->get('auto search'),
		-hoverHelp => $i18n2->get('auto search description'),
		-value => $data->{autoSearch},
	);
	my %hash;
	foreach my $category (@{WebGUI::ProfileCategory->getCategories($self->session)}) {
		$hash{$category->getId} = $category->getLabel;
	}
	$f->submit;
	$self->getAdminConsole->setHelp('edit event metadata field','Asset_EventManagementSystem');
	$self->getAdminConsole->addSubmenuItem($self->getUrl('func=editEventMetaDataField;fieldId=new'), $i18n2->get("add new event metadata field"));
	return $self->_acWrapper($f->print, $i18n2->get("add/edit event metadata field"));
}

#-------------------------------------------------------------------
sub www_editEventMetaDataFieldSave {
	my $self = shift;
	return $self->session->privilege->insufficient unless ($self->canAddEvents);
	my $error = '';
	my $i18n = WebGUI::International->new($self->session,'Asset_EventManagementSystem');
	foreach ('name','label') {
		if ($self->session->form->get($_) eq "" || 
			$self->session->form->get($_) eq $i18n->get('type name here') ||
			$self->session->form->get($_) eq $i18n->get('type label here')) {
			$error .= sprintf($i18n->get('null field error'),$_)."<br />";
		}
	}
	return $self->www_editEventMetaDataField(undef,$error) if $error;
	my $newId = $self->setCollateral("EventManagementSystem_metaField", "fieldId",{
		fieldId=>$self->session->form->process('fieldId'),
		name => $self->session->form->process("name"),
		label => $self->session->form->process("label"),
		dataType => $self->session->form->process("dataType",'fieldType'),
		visible => $self->session->form->process("visible",'yesNo'),
		required => $self->session->form->process("required",'yesNo'),
		possibleValues => $self->session->form->process("possibleValues",'textarea'),
		defaultValues => $self->session->form->process("defaultValues",'textarea'),
		autoSearch => $self->session->form->process("autoSearch",'yesNo')
	},1,1);
	return $self->www_manageEventMetadata();
}



#-------------------------------------------------------------------

=head2 www_moveEventMetaDataFieldDown ( )

Method to move an event down one position in display order

=cut

sub www_moveEventMetaDataFieldDown {
	my $self = shift;
	return $self->session->privilege->insufficient unless ($self->canAddEvents);
	$self->moveCollateralDown('EventManagementSystem_metaField', 'fieldId', $self->session->form->get("fieldId"));
	return $self->www_manageEventMetadata;
}

#-------------------------------------------------------------------

=head2 www_moveEventMetaDataFieldUp ( )

Method to move an event metdata field up one position in display order

=cut

sub www_moveEventMetaDataFieldUp {
	my $self = shift;
	return $self->session->privilege->insufficient unless ($self->canAddEvents);
	$self->moveCollateralUp('EventManagementSystem_metaField', 'fieldId', $self->session->form->get("fieldId"));
	return $self->www_manageEventMetadata;
}


#-------------------------------------------------------------------

=head2 www_deleteEventMetaDataField ( )

Method to move an event metdata field up one position in display order

=cut

sub www_deleteEventMetaDataField {
	my $self = shift;
	return $self->session->privilege->insufficient unless ($self->canAddEvents);
    $self->deleteMetaField($self->session->form->get("fieldId"));
	return $self->www_manageEventMetadata;
}

#-------------------------------------------------------------------

=head2 www_moveEventDown ( )

Method to move an event down one position in display order

=cut

sub www_moveEventDown {
	my $self = shift;
	return $self->session->privilege->insufficient unless ($self->canAddEvents);
	$self->moveCollateralDown('EventManagementSystem_products', 'productId', $self->session->form->get("pid"));
	return $self->www_search;
}

#-------------------------------------------------------------------

=head2 www_moveEventUp ( )

Method to move an event up one position in display order

=cut

sub www_moveEventUp {
	my $self = shift;
	return $self->session->privilege->insufficient unless ($self->canAddEvents);
	$self->moveCollateralUp('EventManagementSystem_products', 'productId', $self->session->form->get("pid"));
	return $self->www_search;
}

#-------------------------------------------------------------------
sub saveRegistration {
	my $self = shift;
	my $eventsInCart = $self->getEventsInScratchCart;
	my $purchaseId = 	$self->session->id->generate;
	my $badgeId = $self->session->scratch->get('currentBadgeId');

	my $theirUserId;
	my $shoppingCart = WebGUI::Commerce::ShoppingCart->new($self->session);

	my @addingToPurchase = split("\n",$self->session->scratch->get('EMS_add_purchase_events'));
	# @addingToPurchase = () if ($self->session->scratch->get('EMS_add_purchase_badgeId') && !($self->session->scratch->get('EMS_add_purchase_badgeId') eq $badgeId));
	my @badgeEvents = $self->session->db->quickArray("select distinct(e.productId) from EventManagementSystem_registrations as r, EventManagementSystem_badges as b, EventManagementSystem_products as e, EventManagementSystem_purchases as z, products as p, transaction where p.productId = r.productId and p.productId = e.productId and r.badgeId=b.badgeId and r.badgeId=? and r.purchaseId !='' and r.purchaseId=z.purchaseId and r.returned=0 and z.transactionId=transaction.transactionId and r.purchaseId is not null and transaction.status='Completed' ",[$badgeId]);
	my $addedAny = 0;
	foreach my $eventId (@$eventsInCart) {
		next if isIn($eventId,@addingToPurchase);
		next if isIn($eventId,@badgeEvents);
		my $registrationId = $self->setCollateral("EventManagementSystem_registrations", "registrationId",{
            assetId         => $self->getId,
			registrationId  => "new",
			purchaseId	    => $purchaseId,
			productId	    => $eventId,
			badgeId         => $badgeId,
		    },0,0);
		$shoppingCart->add($eventId, 'Event');
		$addedAny = 1;
	}
    #Our item plug-in needs to be able to associate these records with the result of the payment attempt
    $self->session->db->write(
        "INSERT INTO EventManagementSystem_sessionPurchaseRef (sessionId, purchaseId, badgeId) VALUES (?,?,?)",
        [$self->session->getId, $purchaseId, $badgeId]
    );
    $self->emptyScratchCart;
    $self->session->scratch->delete('EMS_add_purchase_badgeId');
    $self->session->scratch->delete('EMS_add_purchase_events');
    $self->session->scratch->delete('currentBadgeId');
    $self->session->scratch->delete('currentMainEvent');
    $self->session->scratch->delete('currentPurchase');

#	if ($self->session->form->get('checkoutNow')) {
#	   srand;
#	   $self->session->http->setRedirect($self->getUrl("op=viewCart;something=".rand(44345552)));
#	}
#	return 1 if $self->session->form->get('checkoutNow');
	return $self->www_view;
}

#-------------------------------------------------------------------
sub www_resetScratchCart {
	my $self = shift;
	$self->emptyScratchCart;
	$self->session->scratch->delete('EMS_add_purchase_badgeId');
	$self->session->scratch->delete('EMS_add_purchase_events');
	$self->session->scratch->delete('currentMainEvent');
	$self->session->scratch->delete('currentBadgeId');
	$self->session->db->write(
        "DELETE FROM EventManagementSystem_sessionPurchaseRef WHERE purchaseId=?",
        [$self->session->scratch->get('currentPurchase')]
    );
	$self->session->scratch->delete('currentPurchase');
	return $self->www_view;
}

#-------------------------------------------------------------------
sub www_saveRegistrantInfo {
	my $self = shift;
	my ($myBadgeId) = $self->session->db->quickArray("select badgeId from EventManagementSystem_badges where userId=?",[$self->session->var->get('userId')]);
	$myBadgeId ||= "new"; # if there is no badge for this user yet, have setCollateral create one, assuming thisIsI.
	my $theirBadgeId = $self->session->form->get('badgeId') || "new";
	  # ^ if this is "new", the person is not currently logged in, so they 
	  # get a new badgeId no matter what.  If someone wants to add registrations
	  # to an existing badge, they need to log in first.
	my $thisIsI = $theirBadgeId eq 'thisIsI';
	my $badgeId = $thisIsI ? $myBadgeId : $theirBadgeId;
	my $userId = $thisIsI ? $self->session->var->get('userId') : '';
	my $firstName = $self->session->form->get("firstName", "text");
	my $lastName = $self->session->form->get("lastName", "text");
	my $address = $self->session->form->get("address", "text");
	my $city = $self->session->form->get("city", "text");
	my $state = $self->session->form->get("state", "text");
	my $zipCode = $self->session->form->get("zipCode", "text");
	my $country = $self->session->form->get("country", "selectBox");
	my $phoneNumber = $self->session->form->get("phone", "phone");
	my $email = $self->session->form->get("email", "email");
	my $addingNew = ($badgeId eq 'new') ? 1 : 0;

	# Check required fields
	my @error_loop;
	my $i18n = WebGUI::International->new($self->session,'Asset_EventManagementSystem');
	my $requiredFieldRef = { 'first name' => $firstName, 'last name' => $lastName, 'email address' => $email };

	foreach my $requiredField (keys %{$requiredFieldRef} ) {
		my $fieldValue = $requiredFieldRef->{$requiredField};

		# generate i18n error message for a null field that tells the user which field is null using the i18n label for that field
		if ($fieldValue eq "") {
			push(@error_loop, {
				error => sprintf($i18n->get('null field error'), lc($i18n->get($requiredField))),
			});
		}
	}
	return $self->processStyle($self->processTemplate($self->getRegistrationInfo(\@error_loop),$self->getValue("checkoutTemplateId")))
		if ( scalar(@error_loop) > 0 );
	
	my $details = {
		badgeId => $badgeId, # if this is "new", setCollateral will return the new one.
        assetId => $self->getId,
		firstName       => $firstName,
		lastName	 => $lastName,
		address         => $address,
		city            => $city,
		state		 => $state,
		zipCode	 => $zipCode,
		country	 => $country,
		phone		 => $phoneNumber,
		email		 => $email
	};
	$details->{userId} = $userId if ($userId && $userId ne '1');
	$details->{createdByUserId} = $self->session->var->get('userId') if ($addingNew && $userId ne '1');
	$badgeId = $self->setCollateral("EventManagementSystem_badges", "badgeId",$details,0,0);

	my ($theirUserId) = $self->session->db->quickArray("select userId from EventManagementSystem_badges where badgeId=?",[$badgeId]);
	$userId = $theirUserId unless $thisIsI;
	if ($userId && $userId ne '1') {
		my $u = WebGUI::User->new($self->session,$userId);
		$u->profileField('firstName',$firstName) if ($firstName ne "");
		$u->profileField('lastName',$lastName) if ($lastName ne "");
		$u->profileField('homeAddress',$address) if ($address ne "");
		$u->profileField('homeCity',$city) if ($city ne "");
		$u->profileField('homeState',$state) if ($state ne "");
		$u->profileField('homeZip',$zipCode) if ($zipCode ne "");
		$u->profileField('homeCountry',$country) if ($country ne "");
		$u->profileField('homePhone',$phoneNumber) if ($phoneNumber ne "");
		$u->profileField('email',$email) if ($email ne "");
	}

	$self->session->scratch->set('currentBadgeId',$badgeId);
	my $nameOfEventAdded = $self->getEventName($self->session->scratch->get('currentMainEvent'));
	return $self->www_view();
}

#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
	my $self = shift;
	$self->SUPER::prepareView();
	my $templateId = $self->get("displayTemplateId");
	my $template = WebGUI::Asset::Template->new($self->session, $templateId);
	$template->prepare;
	$self->{_viewTemplate} = $template;
}

#-------------------------------------------------------------------
sub www_search {
	my $self = shift;
	return $self->session->privilege->noAccess() unless $self->canView;
	my %var;
	my $i18n = WebGUI::International->new($self->session,'Asset_EventManagementSystem');
	$var{badgeSelected} = $self->session->scratch->get('currentMainEvent');
	$var{resetScratchCartUrl} = $self->getUrl("func=resetScratchCart");
	my $masterEventId = $var{badgeSelected};
	my $badgeHolderId = $self->session->scratch->get("currentBadgeId");  # primary key to EMS_badges containing all the attendees info

	if ($masterEventId && !$badgeHolderId) {
		# something is wrong; they must have skipped the badge choice step.
		return $self->www_editRegistrantInfo();
	}

	$self->addCartVars(\%var);

	# Get the current sort order and persist it until the user changes it
	my $sortKey = $self->session->form->get("sortKey") || $self->session->scratch->get("EMS_sortKey") || "sequenceNumber";
	$self->session->scratch->set("EMS_sortKey", $sortKey);
	
	# Parse our sort key into some mysql friendly lingo
	my ($orderBy, $direction) = split('_',$sortKey);
	
	# Build our sort list
	my %sortSelect;
	tie %sortSelect, 'Tie::IxHash';
	
	%sortSelect = (
		       'sequenceNumber' => $i18n->echo('Default'),
		       'title' 	    	=> $i18n->echo('Alphabetical A to Z'),
		       'title_desc' 	=> $i18n->echo('Alphabetical Z to A'),
		       'startDate'  	=> $i18n->echo('Earliest Start Times to Latest'),
		       'startDate_desc' => $i18n->echo('Latest Start Times to Earliest'),
		       'endDate'	=> $i18n->echo('Earliest End Times to Latest'),
		       'endDate_desc'	=> $i18n->echo('Latest End Times to Earliest'),
		       'price'		=> $i18n->echo('Lowest Price to Highest'),
		       'price_desc'	=> $i18n->echo('Highest Price to Lowest'),
		      );
	
	$var{'sortForm.header'} = WebGUI::Form::formHeader($self->session,{action=>$self->getUrl()}).
				  WebGUI::Form::hidden($self->session,{name=>"func", value=>"search"}).
				  WebGUI::Form::hidden($self->session,{name=>"searchKeywords", value=>$self->session->form->get("searchKeywords")});
				  #WebGUI::Form::hidden($self->session,{name=>"pn", value=>$self->session->form->get("pn")}).

				for (0..25) {
					if ($self->session->form->get("cfilter_s".$_) ne "") {
						$var{'sortForm.header'} .= WebGUI::Form::hidden($self->session,{name=>"cfilter_s".$_, value=>$self->session->form->get("cfilter_s".$_)}).
						WebGUI::Form::hidden($self->session,{name=>"cfilter_c".$_, value=>$self->session->form->get("cfilter_c".$_)}).
						WebGUI::Form::hidden($self->session,{name=>"cfilter_t".$_, value=>$self->session->form->get("cfilter_t".$_)});
					}
				}
	$var{'sortForm.header'} .= WebGUI::Form::hidden($self->session,{name=>"advSearch", value=>1});
	$var{'sortForm.selectBox'} = WebGUI::Form::selectBox($self->session,{name=>'sortKey', options=>\%sortSelect, value => $sortKey});
	$var{'sortForm.selectBox.label'} = $i18n->echo('Sort By');
	$var{'sortForm.submit'} = WebGUI::Form::submit($self->session,{value=>$i18n->echo('Sort')});
	$var{'sortForm.footer'} = WebGUI::Form::formFooter($self->session);

	# Get all the attendees details
	$var{badgeHolderInfo_loop} = $self->session->db->buildArrayRefOfHashRefs("select * from EventManagementSystem_badges where badgeId=?",[$badgeHolderId]);

	# Get all the events they have in the badge so far
	my $eventsInBadge = $self->getEventsInScratchCart;

	# Get all the info about these events and set the template vars
	my @selectedEvents_loop;
	my @pastEvents = $self->session->db->buildArray("select r.productId from EventManagementSystem_registrations as r, EventManagementSystem_purchases as p, transaction as t where r.returned=0 and r.badgeId=? and t.transactionId=p.transactionId and t.status='Completed' and p.purchaseId=r.purchaseId group by productId",[$badgeHolderId]);
	foreach my $eventId (@$eventsInBadge) {
		if ($eventId eq $masterEventId) {
			$var{'mainEventTitle'} = $self->getEventName($eventId);
			next;
		}
		my $eventData = $self->session->db->quickHashRef("select p.productId, p.title, p.description, p.price, p.weight, p.sku, p.skuTemplate, e.startDate, e.endDate, e.maximumAttendees, e.approved
								  from products as p, EventManagementSystem_products as e where p.productId = e.productId and p.productId=?",[$eventId]);
		$eventData->{'startDateHuman'} = $self->session->datetime->epochToHuman($eventData->{'startDate'});
		$eventData->{'endDateHuman'} = $self->session->datetime->epochToHuman($eventData->{'endDate'});
		$eventData->{'removeEventFromBadge.url'} = $self->getUrl("func=removeFromScratchCart;pid=".$eventData->{'productId'}.
								         ";searchKeywords=".$self->session->form->get("searchKeywords").
									 ";pn=".$self->session->form->get("pn")) unless isIn($eventData->{'productId'},@pastEvents);
		push(@selectedEvents_loop, $eventData);
	}
	$var{'eventsInBadge_loop'} = \@selectedEvents_loop;
	#these allow us to show a specific page of subevents after an add to scratch cart
	my $eventAdded = shift;
	my $cfilter_t0 = shift;
	my $cfilter_s0 = shift;
	my $cfilter_c0 = shift;
	my $pn;
	my $subSearchFlag;
	my $showAllFlag;
	my $addToBadgeMessage;
	if ($eventAdded) {
		$showAllFlag = 1;
		$addToBadgeMessage = sprintf $i18n->get('add to badge message'), $eventAdded;
	}
	if ($var{badgeSelected}) {
		# always filter by a main event if we have one selected.
		$cfilter_t0 = $self->session->scratch->get('currentMainEvent');
		$subSearchFlag = 1;
		$cfilter_s0 = "requirement";
		$cfilter_c0 = "eq";
		$pn = 1 || $self->session->form->get("pn");
	}

	my $keywords = $self->session->form->process("searchKeywords",'text');
	my @keys;
	my $joins;
	my $selects;
	my @joined;



	my $language  = $i18n->getLanguage(undef,"languageAbbreviation");
	$var{'calendarJS'} = '<script type="text/javascript" src="'.$self->session->url->extras('calendar/calendar.js').'"></script><script type="text/javascript" src="'.$self->session->url->extras('calendar/lang/calendar-'.$language.'.js').'"></script><script type="text/javascript" src="'.$self->session->url->extras('calendar/calendar-setup.js').'"></script>';

	push(@keys,$keywords) if $keywords;
	unless ($keywords =~ /^".*"$/) {
		foreach (split(" ",$keywords)) {
			push(@keys,$_) unless $keywords eq $_;
		}
	} else {
		$keywords =~ s/"//g;
		@keys = ($keywords);
	}
	my $searchPhrases;
	if (scalar(@keys)) {
		#$searchPhrases = " and ( ";
		my $count = 0;
		foreach (@keys) {
			$searchPhrases .= ' and ' if $count;
			my $val = $self->session->db->quote('%'.$_.'%');
			$searchPhrases .= "(p.title like $val or p.description like $val or p.sku like $val)";
			$count++;
		}
		#$searchPhrases .= " )";
	}
	my $basicSearch = $searchPhrases;
	my %reqHash;
	my $seatsAvailable = 'none';
	my $seatsCompare;
	if ($self->session->form->get("advSearch") || $self->session->form->get("subSearch") || $subSearchFlag) {
		my $fields = $self->_getFieldHash();
		my $count = 0;
		if ($basicSearch ne "") {
		   $count = 1;
		}
		for (my $cfilter = 0; $cfilter < 50; $cfilter++) {
			my $value;
			my $fieldId;
			my $compare;

			# filter 0 is reserved for passing a search filter via the url
			# or as parameters to this method call.  All user selectable filters
			# begin with number 1, i.e., cfilter_t1, cfilter_s1, cfilter_c1
			#
			if ($cfilter_t0 && $cfilter_s0 && $cfilter_c0 && $pn) { # a filter was passed as params to the method call
				if ($cfilter == 0) { #don't want to overwrite the user filters
					$value = $cfilter_t0;
					$fieldId = $cfilter_s0;
					$compare = $cfilter_c0;
				}
			}

			$value = $self->session->form->get("cfilter_t".$cfilter) unless ($value);
			$fieldId = $self->session->form->get("cfilter_s".$cfilter) unless ($fieldId);
			if ($fieldId eq 'requirement') {
				$reqHash{$value} = 1 if $value;
			}
			if ($fieldId eq 'seatsAvailable') {
				$seatsAvailable = $value if ($value || $value eq '0');
				$seatsCompare = $self->session->form->get("cfilter_c".$cfilter);
			}
			# temporary
			next if ($fieldId eq 'seatsAvailable' || $fieldId eq 'requirement');
			# end temporary
			next unless (($value || $value =~ /^0/) && defined $fields->{$fieldId});
			$compare = $self->session->form->get("cfilter_c".$cfilter) unless ($compare);
			#Format Value with Operator
			$value =~ s/%//g;
			my $field = $fields->{$fieldId};
			if ($field->{type} =~ /^date/i) {
        $value = $self->session->datetime->setToEpoch($value);
			} else {
				$value = lc($value);
			}
			my $compareType = $field->{compare};
			if($compare eq "eq") {
				$value = "=".$self->session->db->quote($value);
			} elsif($compare eq "ne"){
				$value = "<>".$self->session->db->quote($value);
			} elsif($compare eq "notlike") {
				$value = "not like ".$self->session->db->quote("%".$value."%");
			} elsif($compare eq "starts") {
				$value = "like ".$self->session->db->quote($value."%");
			} elsif($compare eq "ends") {
				$value = "like ".$self->session->db->quote("%".$value);
			} elsif($compare eq "gt") {
				$value = "> ".$value;
			} elsif($compare eq "lt") {
				$value = "< ".$value;
			} elsif($compare eq "lte") {
				$value = "<= ".$value;
			} elsif($compare eq "gte") {
				$value = ">= ".$value;
			} elsif($compare eq "like") {
				$value = " like ".$self->session->db->quote("%".$value."%");
			}
			$searchPhrases .= " and " if($count);
			$count++;
			my $isMeta = $field->{metadata};		
			my $phrase;
			if ($isMeta) {
				unless(WebGUI::Utility::isIn($fieldId,@joined)) {
					$joins .= " left join EventManagementSystem_metaData joinedField$count on e.productId=joinedField$count.productId and joinedField$count.fieldId='$fieldId'";
					push(@joined,$fieldId);
				}
				$phrase = " joinedField".$count.".fieldData ";
				$searchPhrases .= " ".$phrase." ".$value;
			} else {
				$phrase = $field->{tableName}.'.'.$field->{columnName};
				if ($compareType ne 'numeric') {
					$searchPhrases .= " lower(".$phrase.") ".$value;
				} else {
					$searchPhrases .= " ".$phrase." ".$value;
				}
			}
		}
	}
	$searchPhrases &&= " and ( ".$searchPhrases." )";
	# Get the products available for sale for this page
	my $approvalPhrase = ($self->canApproveEvents)?' ':' and approved=1';
	my $sql = "select p.productId, p.title, p.description, p.price, p.templateId, p.weight, p.sku, p.skuTemplate, e.approved, e.maximumAttendees, e.startDate, e.endDate, e.prerequisiteId $selects
		   from products as p, EventManagementSystem_products as e 
		   $joins 
		   where
		   	p.productId = e.productId $approvalPhrase
		   	and e.assetId =".$self->session->db->quote($self->get("assetId")).$searchPhrases. " order by $orderBy $direction";
	$var{'basicSearch.formHeader'} = WebGUI::Form::formHeader($self->session,{action=>$self->getUrl("func=search;advSearch=0",method=>'GET')}).
					 WebGUI::Form::hidden($self->session,{name=>"subSearch", value => $self->session->form->get("subSearch")}).
					 WebGUI::Form::hidden($self->session,{name => "cfilter_s0", value => "requirement"}).
					 WebGUI::Form::hidden($self->session,{name => "cfilter_c0", value => "eq"}).
					 WebGUI::Form::hidden($self->session,{name => "cfilter_t0", value => ($self->session->form->get("cfilter_t0") || $cfilter_t0)});
	$var{'advSearch.formHeader'} = WebGUI::Form::formHeader($self->session,{action=>$self->getUrl("func=search;advSearch=1"),method=>'GET'}).
				       WebGUI::Form::hidden($self->session,{name => "cfilter_s0", value => "requirement"}).
				       WebGUI::Form::hidden($self->session,{name => "cfilter_c0", value => "eq"}).
				       WebGUI::Form::hidden($self->session,{name => "cfilter_t0", value => ($self->session->form->get("cfilter_t0") || $cfilter_t0)});
	$var{isAdvSearch} = $self->session->form->get('advSearch');
	$var{'search.formFooter'} = WebGUI::Form::formFooter($self->session);
	$var{'search.formSubmit'} = WebGUI::Form::submit($self->session, {name=>"filter",value=>$i18n->get('filter')});
	my $searchUrl = $self->getUrl("a=1");  #a=1 is a hack to get the ? appended to the url in the right place.  This param/value does nothing.
	my $formVars = $self->session->form->paramsHashRef();
	my @paramsUsed;
	foreach ($self->session->form->param) {
		$searchUrl .= ';'.$_.'='.$formVars->{$_} if (($_ ne 'pn') && ($formVars->{$_} || $formVars->{$_} eq '0') && !isIn(@paramsUsed, $_) && $_ ne "a");
		push (@paramsUsed, $_);
	}
	my $p = WebGUI::Paginator->new($self->session,$searchUrl,$self->get("paginateAfter"));
	my (@results, $sth, $data);
	$sth = $self->session->db->read($sql);
	while ($data = $sth->hashRef) {
		my $shouldPush = 1;
		my $eventId = $data->{productId};
		my $requiredList = 
			($data->{prerequisiteId})
			?$self->getAllPossibleRequiredEvents($data->{prerequisiteId})
			:[];
		if ($seatsAvailable ne 'none') {
			my ($numberRegistered) = $self->session->db->quickArray("select count(*) from EventManagementSystem_registrations as r, EventManagementSystem_purchases as p, transaction as t where t.transactionId=p.transactionId and t.status='Completed' and r.purchaseId = p.purchaseId and r.returned=0 and r.productId=".$self->session->db->quote($eventId));
	  	if($seatsCompare eq "eq") {
				$shouldPush = 0 unless ($data->{'maximumAttendees'} - $numberRegistered == $seatsAvailable);
			} elsif($seatsCompare eq "ne"){
				$shouldPush = 0 unless ($data->{'maximumAttendees'} - $numberRegistered != $seatsAvailable);
			} elsif($seatsCompare eq "gt") {
				$shouldPush = 0 unless ($data->{'maximumAttendees'} - $numberRegistered > $seatsAvailable);
			} elsif($seatsCompare eq "lt") {
				$shouldPush = 0 unless ($data->{'maximumAttendees'} - $numberRegistered < $seatsAvailable);
			} elsif($seatsCompare eq "lte") {
				$shouldPush = 0 unless ($data->{'maximumAttendees'} - $numberRegistered <= $seatsAvailable);
			} elsif($seatsCompare eq "gte") {
				$shouldPush = 0 unless ($data->{'maximumAttendees'} - $numberRegistered >= $seatsAvailable);
			}
		}
		foreach (keys %reqHash) {
			$shouldPush = 0 unless isIn($_,@{$requiredList});
		}
		push(@results,$data) if $shouldPush;
	}
	$sth->finish;
	my $maxResultsForInitialDisplay = 500;
	my $numSearchResults = scalar(@results);
	@results = () unless ( ($numSearchResults <= $maxResultsForInitialDisplay) || ($self->session->form->get("advSearch") || $self->session->form->get("searchKeywords") || $showAllFlag));	
	$p->setDataByArrayRef(\@results);
	my $eventData = $p->getPageData($pn);
	my @events;
	foreach my $event (@$eventData) {
	  my %eventFields;

	  $eventFields{'title'} = $event->{'title'};
	  $eventFields{'description'} = $event->{'description'};
	  $eventFields{'price'} = '$'.$event->{'price'};
	  $eventFields{'sku'} = $event->{'sku'};
	  $eventFields{'skuTemplate'} = $event->{'skuTemplate'};
	  $eventFields{'weight'} = $event->{'weight'};
	  my ($numberRegistered) = $self->session->db->quickArray("select count(*) from EventManagementSystem_registrations as r, EventManagementSystem_purchases as p, transaction as t where t.transactionId=p.transactionId and t.status='Completed' and r.purchaseId = p.purchaseId and r.returned=0 and r.productId=".$self->session->db->quote($event->{'productId'}));
	  $eventFields{'numberRegistered'} = $numberRegistered;
	  $eventFields{'maximumAttendees'} = $event->{'maximumAttendees'};
	  $eventFields{'seatsRemaining'} = $event->{'maximumAttendees'} - $numberRegistered;
	  $eventFields{'startDate.human'} = $self->session->datetime->epochToHuman($event->{'startDate'});
	  $eventFields{'startDate'} = $event->{'startDate'};
	  $eventFields{'endDate.human'} = $self->session->datetime->epochToHuman($event->{'endDate'});
	  $eventFields{'endDate'} = $event->{'endDate'};
	  $eventFields{'productId'} = $event->{'productId'};
	  $eventFields{'eventIsFull'} = ($eventFields{'seatsRemaining'} <= 0);
	  $eventFields{'eventIsApproved'} = ($event->{'approved'} eq "1");
	  $eventFields{'eventIsPending'}  = ($event->{'approved'} eq "-1");
	  $eventFields{'eventIsCanceled'} = ($event->{'approved'} eq "-2");
	  $eventFields{'eventIsDenied'}   = ($event->{'approved'} eq "0");
	  $eventFields{'eventState.label'} = $self->getEventStateLabel($event->{approved});
	  $eventFields{'manageToolbar'} = $self->session->icon->delete('func=deleteEvent;pid='.$event->{productId}, $self->get('url'),
					  $i18n->get('confirm delete event')).
					  $self->session->icon->edit('func=editEvent;pid='.$event->{productId}, $self->get('url')).
					  $self->session->icon->moveUp('func=moveEventUp;pid='.$event->{productId}, $self->get('url')).
					  $self->session->icon->moveDown('func=moveEventDown;pid='.$event->{productId}, $self->get('url'));

	  if ($eventFields{'eventIsFull'}) {
	  	$eventFields{'purchase.label'} = $i18n->get('sold out');
	  }
	  else {
	  	$eventFields{'purchase.label'} = $i18n->get('add to cart');
	  }
		my $masterEventId = $cfilter_t0 || $self->session->form->get("cfilter_t0");
	  $eventFields{'purchase.url'} = $self->getUrl('func=addToScratchCart;pid='.$event->{'productId'}.";mid=".$masterEventId.";pn=".$self->session->form->get("pn"));
	  %eventFields = ('event' => $self->processTemplate(\%eventFields, $event->{'templateId'}), %eventFields) if ($self->{_calledFromView} && $self->session->form->process('func') eq 'view');
	  push (@events, \%eventFields);
	} 

	$var{'events_loop'} = \@events;
	$p->setAlphabeticalKey('title');
	$var{'paginateBar'} = $p->getBarTraditional;
	$p->appendTemplateVars(\%var);
	$var{'manageEvents.url'} = $self->getUrl('func=search');
	$var{'manageEvents.label'} = $i18n->get('manage events');
	$var{'managePurchases.url'} = $self->getUrl('func=managePurchases') if $self->session->var->get('userId') ne '1';
	$var{'managePurchases.label'} = $i18n->get('manage purchases');
	$var{'noSearchDialog'} = ($self->session->form->get('hide') eq "1") ? 1 : 0;
	$var{'addEvent.url'} = $self->getUrl('func=editEvent;pid=new');
	$var{'addEvent.label'} = $i18n->get('add event');
	if ($self->session->user->isInGroup($self->get("groupToManageEvents"))) {
		$var{'canManageEvents'} = 1;
	}
	else {
		$var{'canManageEvents'} = 0;
	}
	my $message;
	$subSearchFlag = $self->session->form->get("subSearch") || ($self->session->form->get("func"));
	my $advSearchFlag = $self->session->form->get("advSearch");
	my $basicSearchFlag = $self->session->form->get("searchKeywords");
	my $paginationFlag = $self->session->form->get("pn") || $pn;
	my $hasSearchedFlag = ($self->session->form->get("filter"));

	#Determine type of search results we're displaying
	if ($subSearchFlag && ($numSearchResults <= $maxResultsForInitialDisplay || $paginationFlag || $hasSearchedFlag)) {
		if ($self->canEdit) { #Admin manage sub events small resultset
			$message = $i18n->get('Admin manage sub events small resultset');
		} else { #User sub events small resultset
			$message = $i18n->get("User sub events small resultset");
		}
	} elsif ($subSearchFlag && $numSearchResults > $maxResultsForInitialDisplay && !$paginationFlag) {
		if ($self->canEdit) { #Admin manage sub events large resultset
			$message = $i18n->get('Admin manage sub events large resultset');   
		} else { #User sub events large resultset
			$message = $i18n->get('User sub events large resultset');   
		}
	} elsif ($numSearchResults <= $maxResultsForInitialDisplay || $paginationFlag || $hasSearchedFlag) {
		$message = $i18n->get('option to narrow');
	} elsif ($numSearchResults > $maxResultsForInitialDisplay && !$paginationFlag) {
		$message = $i18n->get('forced narrowing');
	}

	my $somethingInScratch = scalar(@{$self->getEventsInScratchCart});
	$var{'message'} = $message;
	$var{'numberOfSearchResults'} = $numSearchResults;
	$var{'continue.url'} = $self->getUrl('func=addToCart;pid=_noid_') if $somethingInScratch;
	$var{'checkoutNow.url'} = $self->getUrl('func=addToCart;pid=_noid_;checkoutNow=1') if $somethingInScratch;
	$var{'continue.label'} = $i18n->get("continue") if $somethingInScratch;
	$var{'name.label'} = $i18n->get("event");
	$var{'starts.label'} = $i18n->get("starts");
	$var{'ends.label'} = $i18n->get("ends");
	$var{'price.label'} = $i18n->get("price");
	$var{'seats.label'} = $i18n->get("seats available");
	$var{'addToBadgeMessage'} = $addToBadgeMessage;
	$var{'manageRegistrants'} = $self->getUrl("func=manageRegistrants");
	$var{'emptyCart.url'} = $self->getUrl("func=emptyCart");
	$var{'checkout.url'} = $self->getUrl("func=checkout");
	

	$self->buildMenu(\%var);
	$var{'ems.wobject.dir'} = $self->session->url->extras("wobject/EventManagementSystem");

	return $self->processStyle($self->processTemplate(\%var,$self->getValue("searchTemplateId")));
}

#-------------------------------------------------------------------
sub view {
	my $self = shift;
	my %var;
	return $self->session->privilege->noAccess() unless $self->canView;
	# If we're at the view method there is no reason we should have anything in our scratch cart
	# so let's empty it to prevent strange and awful things from happening
#	unless ($self->session->scratch->get('EMS_add_purchase_badgeId')) {
#		$self->emptyScratchCart;
#		$self->session->scratch->delete('EMS_add_purchase_events');
#	}

	$self->addCartVars(\%var);

	my $i18n = WebGUI::International->new($self->session,'Asset_EventManagementSystem');
	# Get the products available for sale for this page
	my $sql = "select p.productId, p.title, p.description, p.price, p.weight, p.sku, p.skuTemplate, p.templateId, e.approved, e.maximumAttendees 
		   from products as p, EventManagementSystem_products as e
		   where
		   	p.productId = e.productId and approved=1
		   	and e.assetId =".$self->session->db->quote($self->get("assetId"))."
			and (e.prerequisiteId is NULL or e.prerequisiteId = '') order by sequenceNumber";

	my $p = WebGUI::Paginator->new($self->session,$self->getUrl,$self->get("paginateAfter"));
	$p->setDataByQuery($sql);
	my $eventData = $p->getPageData;
	my @events;

	#We are getting each events information, passing it to the *events* template and processing it
	#The html returned from each events template is returned to the Event Manager Display Template for arranging
	#how the events are displayed in relation to one another.
	foreach my $event (@$eventData) {
	  my %eventFields;

	  $eventFields{'title'} = $event->{'title'};
	  $eventFields{'title.url'} = $self->getUrl('func=search;cfilter_s0=requirement;cfilter_c0=eq;subSearch=1;cfilter_t0='.$event->{'productId'});
	  $eventFields{'description'} = $event->{'description'};
	  $eventFields{'price'} = '$'.$event->{'price'};
	  $eventFields{'sku'} = $event->{'sku'};
	  $eventFields{'skuTemplate'} = $event->{'skuTemplate'};
	  $eventFields{'weight'} = $event->{'weight'};
	  my ($numberRegistered) = $self->session->db->quickArray("select count(*) from EventManagementSystem_registrations as r, EventManagementSystem_purchases as p, transaction as t where t.transactionId=p.transactionId and t.status='Completed' and r.purchaseId = p.purchaseId and returned=0 and r.productId=".$self->session->db->quote($event->{'productId'}));
	  $eventFields{'numberRegistered'} = $numberRegistered;
	  $eventFields{'maximumAttendees'} = $event->{'maximumAttendees'};
	  $eventFields{'seatsRemaining'} = $event->{'maximumAttendees'} - $numberRegistered;
	  $eventFields{'eventIsFull'} = ($eventFields{'seatsRemaining'} <= 0);
	  $eventFields{'canManageEvents'} = $self->canApproveEvents;
	  $eventFields{'eventIsApproved'} = $event->{'approved'};

	  if ($eventFields{'eventIsFull'}) {
	  	$eventFields{'purchase.label'} = $i18n->get('sold out');
	  }
	  else {
	  	$eventFields{'purchase.label'} = $i18n->get('add to cart');
	  }
  	$eventFields{'purchase.url'} = $self->getUrl('func=addToScratchCart;mid='.$event->{'productId'}.';pid='.$event->{'productId'});
		$eventFields{'purchase.message'} = $i18n->get('see available subevents');
		$eventFields{'purchase.wantToSearch.url'} = $self->getUrl('func=search;cfilter_s0=requirement;cfilter_c0=eq;subSearch=1;cfilter_t0='.$event->{productId});
	  $eventFields{'purchase.wantToContinue.url'} = $self->getUrl('func=addToCart;pid='.$event->{productId});

	  push (@events, {'event' => $self->processTemplate(\%eventFields, $event->{'templateId'}) });	  
	} 
	$var{'checkout.url'} = $self->getUrl('func=checkout');			
	$var{'checkout.label'} = $i18n->get('checkout');
	$var{'events_loop'} = \@events;
	$var{'paginateBar'} = $p->getBarTraditional;
	$var{'manageEvents.url'} = $self->getUrl('func=search');
	$var{'manageEvents.label'} = $i18n->get('manage events');
	$var{'managePurchases.url'} = $self->getUrl('func=managePurchases');
	$var{'managePurchases.label'} = $i18n->get('manage purchases');
	$var{'canManageEvents'} = $self->canApproveEvents;
	$var{'manageRegistrants.url'} = $self->getUrl("func=manageRegistrants");
	$var{'emptyCart.url'} = $self->getUrl("func=emptyCart");

	
	$p->appendTemplateVars(\%var);

#	my $templateId = $self->get("displayTemplateId");

	return $self->processTemplate(\%var, undef, $self->{_viewTemplate});
}

#-------------------------------------------------------------------

=head2 www_managePrereqSets ( )

Method to display the prereq set management console.

=cut

sub www_managePrereqSets {
	my $self = shift;

	return $self->session->privilege->insufficient unless ($self->canAddEvents);
	my $i18n = WebGUI::International->new($self->session,'Asset_EventManagementSystem');

	my $output;
	my $sth = $self->session->db->read("select prerequisiteId, name from EventManagementSystem_prerequisites order by name");

	if ($sth->rows) {

		while (my %row = $sth->hash) {
			$output .= "<div>";
			$output .= $self->session->icon->delete('func=deletePrereqSet;psid='.$row{prerequisiteId}, $self->get('url'),
							       $i18n->get('confirm delete prerequisite set')).
				  $self->session->icon->edit('func=editPrereqSet;psid='.$row{prerequisiteId}, $self->get('url')).
				  " ".$row{name}."</div>";
		}
	} else {
		$output .= $i18n->get('no sets to display');
	}
	$self->getAdminConsole->addSubmenuItem($self->getUrl('func=editPrereqSet;psid=new'), $i18n->get('add prerequisite set'));

	return $self->_acWrapper($output, $i18n->get("manage prerequisite sets"));
}


#-------------------------------------------------------------------
sub www_editPrereqSet {
	my $self = shift;
	my $psid = shift || $self->session->form->process("psid") || 'new';
	my $error = shift;
	return $self->session->privilege->insufficient unless ($self->canAddEvents);
	my $i18n = WebGUI::International->new($self->session,'Asset_EventManagementSystem');
	my $f = WebGUI::HTMLForm->new($self->session, (
		action => $self->getUrl("func=editPrereqSetSave;psid=".$psid)
	));
	my $data = {};
	if ($error) {
		# load submitted data.
		$data = {
			name => $self->session->form->process("name"),
			requiredEvents => $self->session->form->process("requiredEvents",'selectList'),
		};
		$f->readOnly(
			-name => 'error',
			-label => $i18n->get('error'),
			-value => '<span style="color:red;font-weight:bold">'.$error.'</span>',
		);
	} elsif ($psid eq 'new') {
		$data->{name} = $i18n->get('type name here');
		$data->{operator} = 'or';
	} else {
		$data = $self->session->db->quickHashRef("select * from EventManagementSystem_prerequisites where prerequisiteId=?",[$psid]);
	}
	$f->text(
		-name => "name",
		-label => $i18n->get('prereq set name field label'),
		-hoverHelp => $i18n->get('prereq set name field description'),
		-extras=>(($data->{name} eq $i18n->get('type name here'))?' style="color:#bbbbbb" ':'').' onblur="if(!this.value){this.value=\''.$i18n->get('type name here').'\';this.style.color=\'#bbbbbb\';}" onfocus="if(this.value == \''.$i18n->get('type name here').'\'){this.value=\'\';this.style.color=\'\';}"',
		-value => $data->{name},
	);
	$f->radioList(
		-name=>"operator",
		-vertical=>1,
		-label=>$i18n->get('operator type'),
		-hoverHelp => $i18n->get('operator type description'),
		-options=>{
			'or'=>$i18n->get('any'),
			'and'=>$i18n->get('all'),
		},
		-value=>$data->{operator}
	);
	$f->checkList(
		-name=>"requiredEvents",
		-vertical=>1,
		-label=>$i18n->get('events required by this prerequisite set'),
		-hoverHelp => $i18n->get('events required by description'),
		-options=>$self->session->db->buildHashRef("select p.productId, p.title
		   from products as p, EventManagementSystem_products as e
		   where
		   	p.productId = e.productId 
			and (e.prerequisiteId is NULL or e.prerequisiteId = '')"),
		-value=>$self->session->db->buildArrayRef("select requiredProductId from EventManagementSystem_prerequisiteEvents where prerequisiteId=?",[$psid])
	);
	$f->submit;
	return $self->_acWrapper($f->print, $i18n->get("edit prerequisite set"));
}

#-------------------------------------------------------------------
sub www_editPrereqSetSave {
	my $self = shift;
	return $self->session->privilege->insufficient unless ($self->canAddEvents);
	my $error = '';
	my $i18n = WebGUI::International->new($self->session,'Asset_EventManagementSystem');
	foreach ('name') {
		if ($self->session->form->get($_) eq "" || 
			$self->session->form->get($_) eq $i18n->get('type name here')) {
			$error .= sprintf($i18n->get('null field error'),$_)."<br />";
		}
	}
	return $self->www_editPrereqSet(undef,$error) if $error;
	my $psid = $self->session->form->process('psid');
	$psid = $self->setCollateral("EventManagementSystem_prerequisites", "prerequisiteId",{
		prerequisiteId=>$psid,
        assetId=>$self->getId,
		name => $self->session->form->process("name"),
		operator => $self->session->form->process("operator",'radioList')
	},0,0);
	$self->session->db->write("delete from EventManagementSystem_prerequisiteEvents where prerequisiteId=?",[$psid]);
	my @newRequiredEvents = $self->session->form->process('requiredEvents','checkList');
	foreach (@newRequiredEvents) {
		$self->session->db->write("insert into EventManagementSystem_prerequisiteEvents values (?,?)",[$psid,$_]);
	}
	
	# Rebuild the EMS Cache
	WebGUI::Workflow::Instance->create($self->session, {
			workflowId=>'EMSworkflow00000000001',
			className=>"none",
			priority=>1
	});
	
	return $self->www_managePrereqSets();
}


#-------------------------------------------------------------------

=head2 www_manageRegistrants ( )

Method to display the registrant management console.

=cut

sub www_manageRegistrants {
	my $self = shift;

	return $self->session->privilege->insufficient unless ($self->canAddEvents);
	my $i18n = WebGUI::International->new($self->session,'Asset_EventManagementSystem');

	my $output;
	my $sql = "select * from EventManagementSystem_badges where assetId=? order by lastName, firstName";
	my $p = WebGUI::Paginator->new($self->session,$self->getUrl('func=manageRegistrants'),50);
	#$p->setDataByArrayRef($self->session->db->buildArrayRefOfHashRefs($sql),[$self->getId]);
	$p->setDataByQuery($sql,undef,undef,[$self->getId]);
	$p->setAlphabeticalKey('lastName');
	foreach my $badge (@{$p->getPageData}) {
		$output .= "<div>";
	#	$output .= $self->session->icon->delete('func=deleteRegistrant;psid='.$_->{badgeId}, $self->get('url'));
		$output .= $self->session->icon->edit('func=editRegistrant;badgeId='.$badge->{badgeId}, $self->get('url')).
			"&nbsp;&nbsp;".$badge->{lastName}.",&nbsp;".$badge->{firstName}."&nbsp;&nbsp;(&nbsp;".$badge->{email}."&nbsp;)</div>";
	}
	$output .= '<div>'.$p->getBarAdvanced.'</div>';
	$self->getAdminConsole->addSubmenuItem($self->getUrl('func=editRegistrant;badgeId=new'), $i18n->get('add registrant'));
	return $self->_acWrapper($output, $i18n->get("manage registrants"));
}


#-------------------------------------------------------------------
sub www_editRegistrant {
	my $self = shift;
	my $badgeId = shift || $self->session->form->process("badgeId") || 'new';
	my $error = shift;
	return $self->session->privilege->insufficient unless ($self->canAddEvents);
	my $i18n = WebGUI::International->new($self->session,'Asset_EventManagementSystem');
	my $f = WebGUI::HTMLForm->new($self->session, (
		action => $self->getUrl("func=editRegistrantSave;badgeId=".$badgeId)
	));
	my $data = {};
	if ($error) {
		# load submitted data.
		$data = {
			userId => $self->session->var->get('userId'),
			firstName => $self->session->form->get("firstName", "text"),
			lastName => $self->session->form->get("lastName", "text"),
			'address' => $self->session->form->get("address", "text"),
			city => $self->session->form->get("city", "text"),
			state => $self->session->form->get("state", "text"),
			zipCode => $self->session->form->get("zipCode", "text"),
			country => $self->session->form->get("country", "selectBox"),
			phoneNumber => $self->session->form->get("phone", "phone"),
			email => $self->session->form->get("email", "email")
		};
		$f->readOnly(
			-name => 'error',
			-label => $i18n->get('error'),
			-value => '<span style="color:red;font-weight:bold">'.$error.'</span>',
		);
	} elsif ($badgeId eq 'new') {
		#
	} else {
		$data = $self->session->db->quickHashRef("select * from EventManagementSystem_badges where badgeId=?",[$badgeId]);
	}
	$f->readOnly(
		name=>'nullBadge',
		label=>$i18n->get('badge id'),
		value=>$badgeId
	);
	my $u;
	my $username;
	if ($data->{userId}) {
		$u = WebGUI::User->new($self->session,$data->{userId});
		$username = $u->username;
	}
	$f->user(
		name=>'userId',
		label=>$i18n->get('associated user'),
		hoverHelp=>$i18n->get('associated user description'),
		value=>$data->{userId},
		subtext=>'<script type="text/javascript">
var userField = document.getElementById("userId_formId");
var userFieldDisplay = document.getElementById("userId_formId_display");
if (userField.value == "1") userFieldDisplay.value="";
function clearUserField() {
	userField.value="";
	userFieldDisplay.value="";
}
function setUserNew() {
	userField.value="new";
	userFieldDisplay.value="'.$i18n->get('create new user').'";
}
function resetToInitial() {
	userField.value="'.$data->{userId}.'";
	userFieldDisplay.value="'.$username.'";
}
</script>
<input type="button" onclick="clearUserField();" value="'.$i18n->get('Unlink User').'" /><input type="button" onclick="setUserNew();" value="'.$i18n->get('create new user').'" /><input type="button" onclick="resetToInitial();" value="'.$i18n->get('reset user').'" />'
	);
	if ($data->{userId} ne 'new' && $data->{createdByUserId} && $data->{createdByUserId} ne '1') {
		$f->user(
			name=>'createdByUserId',
			label=>$i18n->get('created by'),
			hoverHelp=>$i18n->get('created by description'),
			readOnly=>1,
			value=>$data->{createdByUserId}
		);
	}
	$f->text(
		name=>'firstName',
		label=>$i18n->get("first name"),
		value=>$data->{firstName}
	);
	$f->text(
		name=>'lastName',
		label=>$i18n->get("last name"),
		value=>$data->{lastName}
	);
	$f->text(
		name=>'address',
		label=>$i18n->get("address"),
		value=>$data->{address}
	);
	$f->text(
		name=>'city',
		label=>$i18n->get("city"),
		value=>$data->{city}
	);
	$f->text(
		name=>'state',
		label=>$i18n->get("state"),
		value=>$data->{state}
	);
	$f->text(
		name=>'zipCode',
		label=>$i18n->get("zip code"),
		value=>$data->{zipCode}
	);
	$f->country(
		name=>'country',
		label=>$i18n->get("country"),
		value=>$data->{country} || 'United States'
	);
	$f->phone(
		name=>'phone',
		label=>$i18n->get("phone number"),
		value=>$data->{phone}
	);
	$f->email(
		name=>'email',
		label=>$i18n->get("email address"),
		value=>$data->{email}
	);
	$f->submit;
	$f->raw($self->www_viewPurchase('noStyle',$badgeId));
	$self->getAdminConsole->setHelp('edit registrant','Asset_EventManagementSystem');
	return $self->_acWrapper($f->print, $i18n->get("edit registrant"));
}

#-------------------------------------------------------------------
sub www_editRegistrantSave {
	my $self = shift;
	return $self->session->privilege->insufficient unless ($self->canAddEvents);
	my $error = '';
	my $i18n = WebGUI::International->new($self->session,'Asset_EventManagementSystem');
	foreach ('firstName','lastName','email') {
		if ($self->session->form->get($_) eq "") {
			$error .= sprintf($i18n->get('null field error'),$_)."<br />";
		}
	}
	return $self->www_editRegistrant(undef,$error) if $error;
	my $badgeId = $self->session->form->process('badgeId');
	my $userId = $self->session->form->get("userId", "user");
	my $firstName = $self->session->form->get("firstName", "text");
	my $lastName = $self->session->form->get("lastName", "text");
	my $address = $self->session->form->get("address", "text");
	my $city = $self->session->form->get("city", "text");
	my $state = $self->session->form->get("state", "text");
	my $zipCode = $self->session->form->get("zipCode", "text");
	my $country = $self->session->form->get("country", "selectBox");
	my $phoneNumber = $self->session->form->get("phone", "phone");
	my $email = $self->session->form->get("email", "email");
	$userId = '' if $userId eq '1';
	my $addingNew = ($userId eq 'new') ? 1 : 0;
	my $details = {
		badgeId => $badgeId, # if this is "new", setCollateral will return the new one.
        assetId => $self->getId,
		firstName       => $firstName,
		lastName	 => $lastName,
		'address'         => $address,
		city            => $city,
		state		 => $state,
		zipCode	 => $zipCode,
		country	 => $country,
		phone		 => $phoneNumber,
		email		 => $email
	};
	$details->{userId} = $userId;
	$details->{createdByUserId} = $self->session->var->get('userId') if ($addingNew && $userId);
	$badgeId = $self->setCollateral("EventManagementSystem_badges", "badgeId",$details,0,0);
	if ($userId) {
		my $u;
		if ($addingNew) {
			$u = WebGUI::User->new($self->session,'new');
			my $uid = lc($firstName).".".lc($lastName);
			$uid =~ s/\s//g; # fix potential space problems in UID.
			my ($uidIsTaken) = $self->session->db->quickArray("select count(userId) from users where username=?",[$uid]);
			while($uidIsTaken) {
				if($uid =~ /(.*)(\d+$)/){
					$uid = $1.($2+1);
				} else {
					$uid .= "1";
				}
				($uidIsTaken) = $self->session->db->quickArray("select count(userId) from users where username=?",[$uid]);
			}
			$u->username($uid);
			$u->authMethod("WebGUI");
			my $auth = WebGUI::Auth::WebGUI->new($self->session,"WebGUI",$u->userId);
			my $authprops = {};
			$authprops->{changePassword} = 1;
			$authprops->{changeUsername} = 0;
			my $len = $self->session->setting->get("webguiPasswordLength") || 6;
			my $password = "";
			srand();
			for(my $i = 0; $i < $len; $i++) {
				$password .= chr(ord('A') + randint(32));
			}
			$authprops->{identifier} = Digest::MD5::md5_base64($password);
			$auth->saveParams($u->userId,"WebGUI",$authprops);
			$self->setCollateral("EventManagementSystem_badges", "badgeId",{badgeId=>$badgeId,userId=>$u->userId},0,0);
		} else {
			$u = WebGUI::User->new($self->session,$userId);
		}
		if (ref($u) eq 'WebGUI::User') {
			$u->profileField('firstName',$firstName) if ($firstName ne "");
                	$u->profileField('lastName',$lastName) if ($lastName ne "");
                	$u->profileField('homeAddress',$address) if ($address ne "");
                	$u->profileField('homeCity',$city) if ($city ne "");
                	$u->profileField('homeState',$state) if ($state ne "");
                	$u->profileField('homeZip',$zipCode) if ($zipCode ne "");
                	$u->profileField('homeCountry',$country) if ($country ne "");
                	$u->profileField('homePhone',$phoneNumber) if ($phoneNumber ne "");
                	$u->profileField('email',$email) if ($email ne "");
		}
	}
	return $self->www_manageRegistrants();
}



#-------------------------------------------------------------------

=head2 www_manageDiscountPasses ( )

Method to display the discount pass management console.

=cut

sub www_manageDiscountPasses {
	my $self = shift;

	return $self->session->privilege->insufficient unless ($self->canAddEvents);
	my $i18n = WebGUI::International->new($self->session,'Asset_EventManagementSystem');

	my $output;
	my $sth = $self->session->db->read("select * from EventManagementSystem_discountPasses order by name");

	if ($sth->rows) {
		while (my $data = $sth->hashRef) {
			$output .= "<div>";
		#	$output .= $self->session->icon->delete('func=deleteDiscountPass;psid='.$data->{passId}, $self->get('url'));
			$output .= $self->session->icon->edit('func=editDiscountPass;passId='.$data->{passId}, $self->get('url')).
				"&nbsp;&nbsp;".$data->{name}."&nbsp;&nbsp;(".$data->{type}."&nbsp;".$data->{amount}."&nbsp;)</div>";
		}
	}
	$self->getAdminConsole->setHelp('manage discount passes', 'Asset_EventManagementSystem');
	$self->getAdminConsole->addSubmenuItem($self->getUrl('func=editDiscountPass;passId=new'), $i18n->get('add discount pass'));
	return $self->_acWrapper($output, $i18n->get("manage discount passes"));
}


#-------------------------------------------------------------------
sub www_editDiscountPass {
	my $self = shift;
	my $passId = shift || $self->session->form->process("passId") || 'new';
	my $error = shift;
	return $self->session->privilege->insufficient unless ($self->canAddEvents);
	my $i18n = WebGUI::International->new($self->session,'Asset_EventManagementSystem');
	my $f = WebGUI::HTMLForm->new($self->session, (
		action => $self->getUrl("func=editDiscountPassSave;passId=".$passId)
	));
	my $data = {};
	if ($error) {
		# load submitted data.
		$data = {
			name => $self->session->var->get('name'),
			type => $self->session->form->get("type", "radioList"),
			amount => $self->session->form->get("amount", "text")
		};
		$f->readOnly(
			-name => 'error',
			-label => $i18n->get('error'),
			-value => '<span style="color:red;font-weight:bold">'.$error.'</span>',
		);
	} elsif ($passId eq 'new') {
		#
	} else {
		$data = $self->session->db->quickHashRef("select * from EventManagementSystem_discountPasses where passId=?",[$passId]);
	}
	$f->readOnly(
		name=>'nullPass',
		label=>$i18n->get('discount pass id'),
		hoverHelp=>$i18n->get('discount pass id description'),
		value=>$passId
	);
	$f->text(
		name=>'name',
		label=>$i18n->get("pass name"),
		hoverHelp=>$i18n->get("pass name description"),
		value=>$data->{name}
	);
	$f->radioList(
		name=>'type',
		options=>{
			percentOff => $i18n->get("percent off"),
			newPrice => $i18n->get("new price"),
			amountOff => $i18n->get("amount off")
		},
		label=>$i18n->get("discount pass type"),
		hoverHelp=>$i18n->get("discount pass type description"),
		value=>$data->{type} || 'newPrice'
	);
	$f->float(
		name=>'amount',
		label=>$i18n->get("discount amount"),
		hoverHelp=>$i18n->get("discount amount description"),
		value=>$data->{amount} || '0.00'
	);
	$f->submit;
	$self->getAdminConsole->setHelp('edit discount pass', 'Asset_EventManagementSystem');
	return $self->_acWrapper($f->print, $i18n->get("edit discount pass"));
}

#-------------------------------------------------------------------
sub www_editDiscountPassSave {
	my $self = shift;
	return $self->session->privilege->insufficient unless ($self->canAddEvents);
	my $error = '';
	my $i18n = WebGUI::International->new($self->session,'Asset_EventManagementSystem');
	foreach ('name','type') {
		if ($self->session->form->get($_) eq "") {
			$error .= sprintf($i18n->get('null field error'),$_)."<br />";
		}
	}
	return $self->www_editDiscountPass(undef,$error) if $error;
	my $passId = $self->session->form->process('passId');
	my $type = $self->session->form->get("type", "radioList");
	my $name = $self->session->form->get("name", "text");
	my $amount = $self->session->form->get("amount", "float");
	my $details = {
		passId => $passId, # if this is "new", setCollateral will return the new one.
		type       => $type,
		amount	 => $amount,
		name => $name
	};
	$passId = $self->setCollateral("EventManagementSystem_discountPasses", "passId",$details,0,0);
	return $self->www_manageDiscountPasses();
}


#-------------------------------------------------------------------

=head2 www_view ( )

Returns the view() method of the asset object if the requestor canView.

=cut

sub www_view {
	my $self = shift;
	return $self->www_search() if $self->session->scratch->get('currentMainEvent');
	$self->{_calledFromView} = 1;
	my $check = $self->checkView;
	return $check if (defined $check);
	$self->session->http->setLastModified($self->get("revisionDate"));
	$self->session->http->sendHeader;	
	$self->prepareView;
	my $style = $self->processStyle("~~~");
	my ($head, $foot) = split("~~~",$style);
	$self->session->output->print($head, 1);
	$self->session->output->print($self->view);
	$self->session->output->print($foot, 1);
	return "chunked";
}



1;
