package WebGUI::Asset::Wobject::EventManagementSystem;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use base 'WebGUI::Asset::Wobject';
use Tie::IxHash;
use WebGUI::HTMLForm;
use WebGUI::International;


#-------------------------------------------------------------------
sub error {
	my $self = shift;
	my $errors = shift;
	my $callback = shift;
	my @errorMessages;
	
	foreach my $error (@$errors) {
		#Null Field Error
		if ($error->{type} eq "nullField") {
		  push(@errorMessages, "The ".$error->{fieldName}." field cannot be blank.");
		}
		
		#General Error Message
		elsif ($error->{type} eq "general") {
		  push(@errorMessages, $error->{message});
		}
	}
	return $self->$callback(\@errorMessages);
}

#-------------------------------------------------------------------
sub checkRequiredFields {
  my $self = shift;
  my $requiredFields = shift;
  my @errors;
  
  foreach my $requiredField (keys %{$requiredFields}) {
    if ($self->session->form->get($requiredField) eq "") {
      push(@errors, {
        type  	  => "nullField",
        fieldName => $requiredFields->{"$requiredField"}
        }
      );
    }
  }
        
  return \@errors;    
}

#------------------------------------------------------------------
#
# Returns prerequisiteId of every prerequisite grouping assigned to eventId passed in.
#
sub getAssignedPrerequisites {
	my $self = shift;
	my $eventId = shift;
	
	my $sql = "select prerequisiteId, operator from EventManagementSystem_prerequisites 
		   where productId=".$self->session->db->quote($eventId);
	
	return $self->session->db->buildHashRef($sql); 
}

#------------------------------------------------------------------
#
# Returns names of every event assigned to the prerequisite grouping of the prerequisite group id passed in
#
sub getRequiredEventNames {
	my $self = shift;
	my $prerequisiteId = shift;
	
	my $sql = "select title from products as p, EventManagementSystem_prerequisites as pr, EventManagementSystem_prerequisiteEvents as pe
		   where 
		     pe.requiredProductId = p.productId 
		     and pr.prerequisiteId = pe.prerequisiteId 
		     and pr.prerequisiteId=".$self->session->db->quote($prerequisiteId);
	
	return $self->session->db->buildArrayRef($sql);
}

#------------------------------------------------------------------
#
# This method returns all events except for
# a) the event matching the eventId parameter passed in AND
# b) any events currently assigned as a prerequisite to the eventId parameter passed in
# as a hash reference with the productId, and title
#
# Checks property globalPrerequisites to determine if events from all defined Event Managers should be displayed
# or only the events defined in this particular Event Manager
#
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
sub deleteOrphans {
	my $self = shift;
	
	#Check for orphaned prerequisite definitions
	my @orphans = $self->session->db->quickArray("select p.prerequisiteId from EventManagementSystem_prerequisites as p 
							left join EventManagementSystem_prerequisiteEvents as pe 
							on p.prerequisiteId = pe.prerequisiteId 
							where pe.prerequisiteId is null");
	foreach my $orphan (@orphans) {
		$self->session->db->write("delete from EventManagementSystem_prerequisites where prerequisiteId=".
					   $self->session->db->quote($orphan));
		

	} 
}

#------------------------------------------------------------------
sub eventIsApproved {
	my $self = shift;
	my $eventId = shift;
	my ($result) = $self->session->db->quickArray("select approved from EventManagementSystem_products where productId=".
			      $self->session->db->quote($eventId));
	return $result;
}

#------------------------------------------------------------------
sub validateEditEventForm {
  my $self = shift;
  my $errors;
  
  my %requiredFields;
  tie %requiredFields, 'Tie::IxHash';
  
  #-----Form name--------------User Friendly Name----#
  %requiredFields  = (
  	"title"	   		=>	"Title",
  	"description" 		=> 	"Description",
  	"price"			=>	"Price",
  	"maximumAttendees"	=>	"Maximum Attendees",
  );

  $errors = $self->checkRequiredFields(\%requiredFields);
  
  #Check price greater than zero
  if ($self->session->form->get("price") <= 0) {
      push (@{$errors}, {
      	type      => "general",
        message   => "Price must be greater than zero."
        }
      );
  }
  
  #Other checks go here
  
  return $errors;
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
				hoverHelp=>"When set to yes, you may assign events belonging to another instance of an Event Management System Asset as a prerequisite event for one of the events defined in this instance os the asset.  When set to no, only events defined within this instance of the asset may be used as prerequisites.",
				label=>"Global Prerequisites"
				},
		);
	push(@{$definition}, {
		assetName=>$i18n->get('assetName'),
		icon=>'article.gif',
		autoGenerateForms=>1,
		tableName=>'EventManagementSystem',
		className=>'WebGUI::Asset::Wobject::EventManagementSystem',
		properties=>\%properties
		});
	return $class->SUPER::definition($session,$definition);
}

#-------------------------------------------------------------------
sub www_approveEvent {
	my $self = shift;
	my $eventId = $self->session->form->get("pid");
	return $self->session->privilege->insuffficent unless ($self->session->user->isInGroup($self->get("groupToApproveEvents")));

	$self->session->db->write("update EventManagementSystem_products set approved=1 where productId=".
				   $self->session->db->quote($eventId));
	
	return $self->www_manageEvents;
}

#-------------------------------------------------------------------
sub www_deleteEvent {
	my $self = shift;
	my $eventId = $self->session->form->get("pid");

	return $self->session->privilege->insufficient unless ($self->session->user->isInGroup($self->get("groupToAddEvents")));
	
	#Remove this event as a prerequisite to any other event
	$self->session->db->write("delete from EventManagementSystem_prerequisiteEvents where requiredProductId=".
				   $self->session->db->quote($eventId));
	$self->deleteOrphans;	

	#Remove the event
	$self->deleteCollateral('EventManagementSystem_products', 'productId', $eventId);
	$self->session->db->write("delete from products where productId=".$self->session->db->quote($eventId));
	$self->reorderCollateral('EventManagementSystem_products', 'productId');

	return $self->www_manageEvents;			  
}

#-------------------------------------------------------------------
sub www_deletePrerequisite {
	my $self = shift;
	my $eventId = $self->session->form->get("id");
	
	return $self->session->privilege->insufficient unless ($self->session->user->isInGroup($self->get("groupToAddEvents")));
	
	$self->session->db->write("delete from EventManagementSystem_prerequisiteEvents where prerequisiteId=".
				   $self->session->db->quote($eventId));
	$self->session->db->write("delete from EventManagementSystem_prerequisites where prerequisiteId=".
				   $self->session->db->quote($eventId));
	
	return $self->www_editEvent;
}

#-------------------------------------------------------------------
sub www_editEvent {
	my $self = shift;
	my $errors = shift;
	my $errorMessages;

	return $self->session->privilege->insufficient unless ($self->session->user->isInGroup($self->get("groupToAddEvents")));

	my $pid = $self->session->form->get("pid");
	my $i18n = WebGUI::International->new($self->session,'Asset_EventManagementSystem');

	my $event = $self->session->db->quickHashRef("
		select p.productId, p.title, p.description, p.price, p.weight, p.sku, p.templateId,
		       e.startDate, e.endDate, e.maximumAttendees, e.approved
		from
		       products as p, EventManagementSystem_products as e
		where
		       p.productId = e.productId and p.productId=".$self->session->db->quote($pid)
	); 

	my $f = WebGUI::HTMLForm->new($self->session,-action=>$self->getUrl);
	
	# Errors
	foreach (@$errors) {
		$errorMessages .= "<span style='color: red; font-weight: bold;'>ERROR: $_ </span><br />";
	}
	$f->readOnly( -value=>$errorMessages );
	
	$f->hidden( -name=>"assetId", -value=>$self->get("assetId") );
	$f->hidden( -name=>"func",-value=>"editEventSave" );
	$f->hidden( -name=>"pid", -value=>$pid );
	
	if ($self->session->user->isInGroup($self->get("groupToApproveEvents"))) {
	 unless ($self->eventIsApproved($pid)) {
	  $f->readOnly(
		-value  => "<a href='".$self->getUrl("func=approveEvent;pid=".$pid)."'>Approve Event</a>"
	  );
	 }	
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
	
	$f->float(
		-name  => "price",
		-value => $self->session->form->get("price") || $event->{price},
		-hoverHelp => $i18n->get('add/edit event price description'),		
		-label => $i18n->get('add/edit event price')
	);
	
	$f->template(
		-name  => "templateId",
		-namespace => "product",
		-value => $self->session->form->get("templateId") || $event->{templateId},
		-hoverHelp => $i18n->get('add/edit event template description'),		
		-label => "Event Template" #$i18n->get('add/edit event template')
	);
	
	$f->hidden(
		-name  => "weight",
		-value => "0"
	);
	
	$f->hidden(
		-name  => "sku",
		-value => $event->{sku} || $self->session->id->generate()
	);
	
	$f->dateTime(
		-name  => "startDate",
		-value => $self->session->form->get("startDate") || $event->{startDate},
		-hoverHelp => $i18n->get('add/edit event start date description'),
		-label => "Start Date" #$i18n->get('add/edit event start date')
	);
	
	$f->dateTime(
		-name  => "endDate",
		-value => $self->session->form->get("endDate") || $event->{endDate},
		-defaultValue => "32472169200",
		-hoverHelp => $i18n->get('add/edit event end date description'),
		-label => "End Date" #$i18n->get('add/edit event end date')
	);

	$f->integer(
		-name  => "maximumAttendees",
		-value => $self->session->form->get("maximumAttendees") || $event->{maximumAttendees},
		-defaultValue => 100,
		-hoverHelp => $i18n->get('add/edit event maximum attendees description'),
		-label => "Maximum Attendees" #$i18n->get('add/edit event maximum attendees')
	);

	my $prerequisiteList = $self->getPrerequisiteEventList($pid);
        if ( scalar(keys %{$prerequisiteList}) > 0) {
	 $f->checkList(
		-name    => "eventList",
		-options => $prerequisiteList,
		-vertical  => 1,
		-label   => "Required Events",
		-sortByValue => 1
	 );

	 $f->radioList(
		-name  => "requirement",
		-options => { "and" => "And",
			      "or"  => "Or",
			    },
		-label => "Operator",
		-defaultValue => "and"
	 );

	 $f->selectBox(
		-name  => "whatNext",
		-label => "What Next",
		-options => {
			"addAnotherPrereq" => "Add Another Prerequisite",
			"return"	   => "Return to Manage Events"
			    },
		-defaultValue => "return"
	 );

        }

	$f->submit;

	#Display Currently Assigned Prerequisites if any
	$f->readOnly( -value => "<br>Assigned Prerequisites<br><br>" );
	
	my $list = $self->getAssignedPrerequisites($pid);
	foreach my $prerequisiteId (keys %{$list}) {
	
		my $line = $self->session->icon->delete('func=deletePrerequisite;id='.$prerequisiteId,
							 $self->getUrl, "Are you sure you want to delete this prerequisite?")." ";
		
		my $eventNames = $self->getRequiredEventNames($prerequisiteId);
		my $events;
		foreach my $event (@$eventNames) {
			$events .= "$event ".$list->{$prerequisiteId}." ";
		}
		$events =~ s/(and\s|or\s)$//;
		
		$f->readOnly( -value => $line.$events );
	}

	my $output = $f->print;
	$self->getAdminConsole->addSubmenuItem($self->getUrl('func=manageEvents'),"Manage Events");
	return $self->getAdminConsole->render($output, "Add/Edit Event");				
}

#-------------------------------------------------------------------
sub www_editEventSave {
	my $self = shift;

	return $self->session->privilege->insufficient unless ($self->session->user->isInGroup($self->get("groupToAddEvents")));

	my $errors = $self->validateEditEventForm;
        if (scalar(@$errors) > 0) { return $self->error($errors, "www_editEvent"); }

	my $pid = $self->session->form->get("pid");
        my $eventIsNew = 1 if ($pid eq "" || $pid eq "new");
        my $event;
        
	#Save the extended product data
	$pid = $self->setCollateral("EventManagementSystem_products", "productId",
			    {
			     productId  => $pid,
			     startDate  => $self->session->datetime->humanToEpoch($self->session->form->get("startDate")),
			     endDate	=> $self->session->datetime->humanToEpoch($self->session->form->get("endDate")),
			     maximumAttendees => $self->session->form->get("maximumAttendees"),
			     approved	=> "0"
			    },1,1
			   );
			   
	#Save the standard product data
	$event = {
		productId	=> $pid,
		title		=> $self->session->form->get("title"),
		description	=> $self->session->form->get("description"),
		price		=> $self->session->form->get("price"),
		weight		=> $self->session->form->get("weight"),
		sku		=> $self->session->form->get("sku"),
		skuTemplate	=> $self->session->form->get("skuTemplate"),
		templateId	=> $self->session->form->get("templateId")
	};

	if ($eventIsNew) { # Event is new we need to use the same productId so we can join them later
		$self->session->db->setRow("products", "productId",$event,$pid);
	}
	else { # Updating the row
		$self->session->db->setRow("products", "productId", $event);
	}
	
	# Save the prerequisites
	my $prerequisiteList = $self->session->form->process("eventList", "checkList");

	unless ($prerequisiteList eq "") {
		my $prerequisiteId = $self->setCollateral("EventManagementSystem_prerequisites", "prerequisiteId",
				{
				 prerequisiteId  => "new",
				 productId       => $pid,
				 operator	 => $self->session->form->get("requirement")
				},0,0
		);
		
		my @list = split(/\n/, $prerequisiteList);
		foreach my $requiredEvent (@list) {
			$self->setCollateral("EventManagementSystem_prerequisiteEvents", "prerequisiteEventId",
				{
				 prerequisiteEventId => "new",
				 prerequisiteId      => $prerequisiteId,
				 requiredProductId   => $requiredEvent
				},0,0
			);
		}
	}
	
	return $self->www_editEvent if ($self->session->form->get("whatNext") eq "addAnotherPrereq");
	return $self->www_manageEvents;
}

#-------------------------------------------------------------------
sub www_moveEventDown {
	my $self = shift;
	my $eventId = $self->session->form->get("pid");
	
	return $self->session->privilege->insufficient unless ($self->session->user->isInGroup($self->get("groupToAddEvents")));
	
	$self->moveCollateralDown('EventManagementSystem_products', 'productId', $eventId);

	return $self->www_manageEvents;
}

#-------------------------------------------------------------------
sub www_moveEventUp {
	my $self = shift;
	my $eventId = $self->session->form->get("pid");

	return $self->session->privilege->insufficient unless ($self->session->user->isInGroup($self->get("groupToAddEvents")));
	
	$self->moveCollateralUp('EventManagementSystem_products', 'productId', $eventId);
	
	return $self->www_manageEvents;
}

#-------------------------------------------------------------------
sub www_manageEvents {
	my $self = shift;

	return $self->session->privilege->insufficient unless ($self->session->user->isInGroup($self->get("groupToAddEvents")));

	my $output;
	my $sth = $self->session->db->read("select p.productId, p.title, p.price, pe.approved from products as p, 
				EventManagementSystem_products as pe where p.productId = pe.productId
				and pe.assetId=".$self->session->db->quote($self->get("assetId"))." order by sequenceNumber");
	
	$output = "<table width='100%'><tr><th>Event</th><th>Price</th><th>Status</th></tr>";
	while (my %row = $sth->hash) {
		
		$output .= "<tr><td>";
		$output .= $self->session->icon->delete('func=deleteEvent;pid='.$row{productId}, $self->getUrl,
						       'Are you sure you want to delete this event?').
			  $self->session->icon->edit('func=editEvent;pid='.$row{productId}, $self->getUrl).
			  $self->session->icon->moveUp('func=moveEventUp;pid='.$row{productId}, $self->getUrl).
			  $self->session->icon->moveDown('func=moveEventDown;pid='.$row{productId}, $self->getUrl).
			  " ".$row{title};
		$output .= "</td><td>";
		$output .= $row{price};
		$output .= "</td><td>";
		
		if ($row{approved} == 0) {
			$output .= "Pending";
		}
		else {
			$output .= "Approved";
		}
		
		$output .= "</td></tr>";
	}
	$output .= "</table>";
	
	$self->getAdminConsole->addSubmenuItem($self->getUrl('func=editEvent;pid=new'), "Add Event");
	return $self->getAdminConsole->render($output, "Manage Events");
}

#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

#sub prepareView {
#	my $self = shift;
#	$self->SUPER::prepareView();
#	my $templateId = $self->get("displayTemplateId");
#	my $template = WebGUI::Asset::Template->new($self->session, $templateId);
#	$template->prepare;
#	$self->{_viewTemplate} = $template;
#}


#-------------------------------------------------------------------
sub view {
	my $self = shift;
	my %var;
	
	# Get the products available for sale for this page
	my $sql = "select p.productId, p.title, p.description, p.price, e.approved from products as p, EventManagementSystem_products as e
		   where
		   	p.productId = e.productId and approved=1
		   	and e.assetId =".$self->session->db->quote($self->get("assetId"));

	#my $p = WebGUI::Paginator->new($self->session,$self->getUrl,$self->get("paginateAfter"));
	#$p->setDataByQuery($sql);
	#$var{'events_loop'} = $p->getPage;
	#$p->appendTemplateVars(\%var);
	$var{'events_loop'} = $self->session->db->quickHash($sql);
	
	my $templateId = $self->get("displayTemplateId");
	return $self->processTemplate(\%var, undef, $self->{_viewTemplate});
}


1;

