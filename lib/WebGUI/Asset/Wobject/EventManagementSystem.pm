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
sub www_editEvent {
	my $self = shift;
	my $errors = shift;
	my $errorMessages;
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

	$f->submit;

	my $output = $f->print;
	return $self->getAdminConsole->render($output, "Add/Edit Event");				
}

#-------------------------------------------------------------------
sub www_editEventSave {
	my $self = shift;

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

	return $self->www_view;
}

#-------------------------------------------------------------------
sub view {
	my $self = shift;
	my %var;

	my $templateId = $self->get("displayTemplateId");
	return $self->processTemplate(\%var, $templateId);
}


1;

