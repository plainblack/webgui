package WebGUI::Asset::Wobject::EventManagementSystem;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2008 Plain Black Corporation.
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
use WebGUI::Utility;
use Text::CSV_XS;
use IO::Handle;
use File::Temp 'tempfile';
use Data::Dumper;
use WebGUI::Asset::Sku::EMSBadge;
use WebGUI::Asset::Sku::EMSTicket;
use WebGUI::Asset::Sku::EMSRibbon;
use WebGUI::Asset::Sku::EMSToken;



#-------------------------------------------------------------------
sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my %properties;
	tie %properties, 'Tie::IxHash';
	my $i18n = WebGUI::International->new($session,'Asset_EventManagementSystem');
	%properties = (
		timezone => {
			fieldType 		=> 'TimeZone',
			defaultValue 	=> 'America/Chicago',
			tab				=> 'properties',
			label			=> $i18n->get('time zone'),
			hoverHelp		=> $i18n->get('time zone help'),
		},
		templateId => {
			fieldType 		=> 'template',
			defaultValue 	=> '2rC4ErZ3c77OJzJm7O5s3w',
			tab				=> 'display',
			label			=> $i18n->get('main template'),
			hoverHelp		=> $i18n->get('main template help'),
			namespace		=> 'EMS',
		},
		badgeBuilderTemplateId => {
			fieldType 		=> 'template',
			defaultValue 	=> 'BMybD3cEnmXVk2wQ_qEsRQ',
			tab				=> 'display',
			label			=> $i18n->get('badge builder template'),
			hoverHelp		=> $i18n->get('badge builder template help'),
			namespace		=> 'EMS/BadgeBuilder',
		},
		lookupRegistrantTemplateId => {
			fieldType 		=> 'template',
			defaultValue 	=> 'OOyMH33plAy6oCj_QWrxtg',
			tab				=> 'display',
			label			=> $i18n->get('lookup registrant template'),
			hoverHelp		=> $i18n->get('lookup registrant template help'),
			namespace		=> 'EMS/LookupRegistrant',
		},
		printBadgeTemplateId => {
			fieldType 		=> 'template',
			defaultValue 	=> 'PsFn7dJt4wMwBa8hiE3hOA',
			tab				=> 'display',
			label			=> $i18n->get('print badge template'),
			hoverHelp		=> $i18n->get('print badge template help'),
			namespace		=> 'EMS/PrintBadge',
		},
		printTicketTemplateId => {
			fieldType 		=> 'template',
			defaultValue 	=> 'yBwydfooiLvhEFawJb0VTQ',
			tab				=> 'display',
			label			=> $i18n->get('print ticket template'),
			hoverHelp		=> $i18n->get('print ticket template help'),
			namespace		=> 'EMS/PrintTicket',
		},
		badgeInstructions => {
			fieldType 		=> 'HTMLArea',
			defaultValue 	=> $i18n->get('default badge instructions'),
			tab				=> 'properties',
			label			=> $i18n->get('badge instructions'),
			hoverHelp		=> $i18n->get('badge instructions help'),
		},
		ticketInstructions => {
			fieldType 		=> 'HTMLArea',
			defaultValue 	=> $i18n->get('default ticket instructions'),
			tab				=> 'properties',
			label			=> $i18n->get('ticket instructions'),
			hoverHelp		=> $i18n->get('ticket instructions help'),
		},
		ribbonInstructions => {
			fieldType 		=> 'HTMLArea',
			defaultValue 	=> $i18n->get('default ribbon instructions'),
			tab				=> 'properties',
			label			=> $i18n->get('ribbon instructions'),
			hoverHelp		=> $i18n->get('ribbon instructions help'),
		},
		tokenInstructions => {
			fieldType 		=> 'HTMLArea',
			defaultValue 	=> $i18n->get('default token instructions'),
			tab				=> 'properties',
			label			=> $i18n->get('token instructions'),
			hoverHelp		=> $i18n->get('token instructions help'),
		},
		registrationStaffGroupId => {
			fieldType 		=> 'group',
			defaultValue 	=> [3],
			tab				=> 'security',
			label			=> $i18n->get('registration staff group'),
			hoverHelp		=> $i18n->get('registration staff group help'),
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

=head2 deleteEventMetaField ( id )

Delete a meta field.

=cut

sub deleteEventMetaField {
    my $self = shift;
    my $id = shift;
	$self->deleteCollateral('EMSEventMetaData', 'fieldId', $id); # deleteCollateral doesn't care about assetId.
	$self->deleteCollateral('EMSEventMetaField', 'fieldId', $id);
	$self->reorderCollateral('EMSEventMetaField', 'fieldId');
}


#-------------------------------------------------------------------

=head2 getBadges ()

Returns an array reference of badge objects.

=cut

sub getBadges {
	my $self = shift;
	return $self->getLineage(['children'],{returnObjects=>1, includeOnlyClasses=>['WebGUI::Asset::Sku::EMSBadge']});
}

#-------------------------------------------------------------------

=head2 getBadgeGroups ()

Returns a hash reference of id,name pairs of badge groups.

=cut

sub getBadgeGroups {
	my $self = shift;
	return $self->session->db->buildHashRef("select badgeGroupId,name from EMSBadgeGroup where emsAssetId=?",[$self->getId]);
}

#------------------------------------------------------------------

=head2 getEventMetaFields (  )

Returns an arrayref of hash references of the metadata fields.

=cut

sub getEventMetaFields {
	my $self = shift;
	return $self->session->db->buildArrayRefOfHashRefs("select * from EMSEventMetaField where assetId=? order by sequenceNumber, assetId",[$self->getId]);
}

#-------------------------------------------------------------------

=head2 getRegistrant ( badgeId )

Returns a hash reference containing the properties of a registrant.

=head3 badgeId

The unique id of the registrant you're looking for.

=cut

sub getRegistrant {
	my ($self, $badgeId) = @_;
	return $self->session->db->quickHashRef("select * from EMSRegistrant where badgeId=?",[$badgeId]);
}

#-------------------------------------------------------------------

=head2 getRibbons ()

Returns an array reference of ribbon objects.

=cut

sub getRibbons {
	my $self = shift;
	return $self->getLineage(['children'],{returnObjects=>1, includeOnlyClasses=>['WebGUI::Asset::Sku::EMSRibbon']});
}

#-------------------------------------------------------------------

=head2 getTickets ()

Returns an array reference of ticket objects.

=cut

sub getTickets {
	my $self = shift;
	return $self->getLineage(['children'],{returnObjects=>1, includeOnlyClasses=>['WebGUI::Asset::Sku::EMSTicket']});
}

#-------------------------------------------------------------------

=head2 getTokens ()

Returns an array reference of badge objects.

=cut

sub getTokens {
	my $self = shift;
	return $self->getLineage(['children'],{returnObjects=>1, includeOnlyClasses=>['WebGUI::Asset::Sku::EMSToken']});
}

#-------------------------------------------------------------------

=head2 isRegistrationStaff ( [ user ] )

Returns a boolean indicating whether the user is a member of the registration staff.

=head3 user

A WebGUI::User object. Defaults to $session->user.

=cut

sub isRegistrationStaff {
	my $self = shift;
	my $user = shift || $self->session->user;
	$user->isInGroup($self->get('registrationStaffGroupId'));
}

#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
	my $self = shift;
	$self->SUPER::prepareView();
 	my $template = WebGUI::Asset::Template->new($self->session, $self->get("templateId"));
	$template->prepare;
	$self->{_viewTemplate} = $template;
}

#-------------------------------------------------------------------

=head2 view

Displays the list of configured badges. And other links.

=cut

sub view {
	my ($self) = @_;
	my $session = $self->session;
	return $session->privilege->noAccess() unless $self->canView;

	# set up objects we'll need
	my %var = (
		addBadgeUrl			=> $self->getUrl('func=add;class=WebGUI::Asset::Sku::EMSBadge'),
		buildBadgeUrl		=> $self->getUrl('func=buildBadge'),
		manageBadgeGroupsUrl=> $self->getUrl('func=manageBadgeGroups'),
		getBadgesUrl		=> $self->getUrl('func=getBadgesAsJson'),
		canEdit				=> $self->canEdit,
		lookupRegistrantUrl	=> $self->getUrl('func=lookupRegistrant'),
		);

	# render
	return $self->processTemplate(\%var,undef,$self->{_viewTemplate});
}


#-------------------------------------------------------------------

=head2 www_addRibbonToBadge ()

Adds a ribbon to a badge. Expects two form parameters, assetId and badgeId, where assetId represents the ribbon, and badgeId represents the badge.

=cut

sub www_addRibbonToBadge {
	my $self = shift;
	my $session = $self->session;
    return $session->privilege->insufficient() unless $self->canView;
    my $form = $session->form;
	my $ribbon = WebGUI::Asset->new($session, $form->get('assetId'), 'WebGUI::Asset::Sku::EMSRibbon');
	if (defined $ribbon) {
		$ribbon->addToCart({badgeId=>$form->get('badgeId')});
	}
	return $self->www_getRegistrantAsJson();
}

#-------------------------------------------------------------------

=head2 www_addTicketsToBadge ()

Adds selected tickets to a badge. Expects two form parameters, assetId (multiples fine) and badgeId, where assetId represents the ticket and badgeId represents the badge.

=cut

sub www_addTicketsToBadge {
	my $self = shift;
	my $session = $self->session;
    return $session->privilege->insufficient() unless $self->canView;
    my $form = $session->form;
	my @ids = $form->param('assetId');
	foreach my $id (@ids) {
		my $ticket = WebGUI::Asset->new($session, $id, 'WebGUI::Asset::Sku::EMSTicket');
		if (defined $ticket) {
			$ticket->addToCart({badgeId=>$form->get('badgeId')});
		}		
	}
	return $self->www_getRegistrantAsJson();
}

#-------------------------------------------------------------------

=head2 www_addTokenToBadge ()

Adds a token to a badge. Expects three form parameters, assetId, quantity, and badgeId, where assetId represents the token, quantity is the amount to add, and badgeId represents the badge.

=cut

sub www_addTokenToBadge {
	my $self = shift;
	my $session = $self->session;
    return $session->privilege->insufficient() unless $self->canView;
    my $form = $session->form;
	my $token = WebGUI::Asset->new($session, $form->get('assetId'), 'WebGUI::Asset::Sku::EMSToken');
	if (defined $token) {
		my $item = $token->addToCart({badgeId=>$form->get('badgeId')});
		$item->setQuantity($form->get('quantity'));
	}
	return $self->www_getRegistrantAsJson();
}

#-------------------------------------------------------------------

=head2 www_buildBadge ( [badgeId, whichTab] )

Displays available ribbons, tokens, and tickets for the current badge.

=cut

sub www_buildBadge {
	my ($self, $badgeId, $whichTab) = @_;
	my $session = $self->session;
	return $session->privilege->noAccess() unless $self->canView;
	$badgeId = $session->form->get("badgeId") if ($badgeId eq "");
	my $i18n = WebGUI::International->new($session, "Asset_EventManagementSystem");
	my %var = (
		%{$self->get},
		addTicketUrl				=> $self->getUrl('func=add;class=WebGUI::Asset::Sku::EMSTicket'),
		importTicketsUrl			=> undef,
		exportTicketsUrl			=> undef,
		getTicketsUrl				=> $self->getUrl('func=getTicketsAsJson;badgeId='.$badgeId),
		canEdit						=> $self->canEdit,
		hasBadge					=> ($badgeId ne ""),
		badgeId						=> $badgeId,
		whichTab					=> $whichTab || "tickets",
		addRibbonUrl				=> $self->getUrl('func=add;class=WebGUI::Asset::Sku::EMSRibbon'),
		getRibbonsUrl				=> $self->getUrl('func=getRibbonsAsJson'),
		getTokensUrl				=> $self->getUrl('func=getTokensAsJson'),
		addTokenUrl					=> $self->getUrl('func=add;class=WebGUI::Asset::Sku::EMSToken'),
		lookupBadgeUrl				=> $self->getUrl('func=lookupRegistrant'),
		url							=> $self->getUrl,
		viewCartUrl					=> $self->getUrl('shop=cart'),
		customRequestUrl			=> $self->getUrl('badgeId='.$badgeId),
		manageEventMetaFieldsUrl 	=> $self->getUrl('func=manageEventMetaFields'),
		);
	my @otherBadges =();
	my $cart = WebGUI::Shop::Cart->getCartBySession($session);
	foreach my $item (@{$cart->getItems}) {
		my $id = $item->get('options')->{badgeId};
		next if ($id eq $badgeId);
		next unless ($item->getSku->isa("WebGUI::Asset::Sku::EMSBadge"));
		my $name = $session->db->quickScalar("select name from EMSRegistrant where badgeId=?",[$id]);
		push(@otherBadges, {
			badgeUrl	=> $self->getUrl('func=buildBadge;badgeId='.$id),
			badgeLabel	=> sprintf($i18n->get('switch to badge for'), $name),
			});
	}
	$var{otherBadgesInCart} = \@otherBadges;

	# render
	return $self->processStyle($self->processTemplate(\%var,$self->get('badgeBuilderTemplateId')));
}

#-------------------------------------------------------------------

=head2 www_deleteBadgeGroup ()

Deletes a badge group.

=cut

sub www_deleteBadgeGroup {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	$self->session->db->deleteRow("EMSBadgeGroup","badgeGroupId",$self->session->form->get("badgeGroupId"));
	return $self->www_manageBadgeGroups;
}

#-------------------------------------------------------------------

=head2 www_deleteEventMetaField ( )

Method to move an event metdata field up one position in display order

=cut

sub www_deleteEventMetaField {
	my $self = shift;
	return $self->session->privilege->insufficient unless ($self->canEdit);
    $self->deleteEventMetaField($self->session->form->get("fieldId"));
	return $self->www_manageEventMetaFields;
}

#-------------------------------------------------------------------

=head2 www_editBadgeGroup ()

Displays an edit screen for a badge group.

=cut

sub www_editBadgeGroup {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	my ($form, $db) = $self->session->quick(qw(form db));
	my $f = WebGUI::HTMLForm->new($self->session, action=>$self->getUrl);
	my $badgeGroup = $db->getRow("EMSBadgeGroup","badgeGroupId",$form->get('badgeGroupId'));
	$badgeGroup->{badgeList} = ($badgeGroup->{badgeList} ne "") ? JSON::decode_json($badgeGroup->{badgeList}) : [];
	my $i18n = WebGUI::International->new($self->session, "Asset_EventManagementSystem");
	$f->hidden(name=>'func', value=>'editBadgeGroupSave');
	$f->hidden(name=>'badgeGroupId', value=>$form->get('badgeGroupId'));
	$f->text(
		name		=> 'name',	
		value		=> $badgeGroup->{name},
		label		=> $i18n->get('badge group name'),
		hoverHelp	=> $i18n->get('badge group name help'),
		);
	$f->submit;
	return $self->processStyle('<h1>'.$i18n->get('badge groups').'</h1>'.$f->print);
}


#-------------------------------------------------------------------

=head2 www_editBadgeGroupSave ()

Saves a badge group.

=cut

sub www_editBadgeGroupSave {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	my $form = $self->session->form;
	my $id = $form->get("badgeGroupId") || "new";
	$self->session->db->setRow("EMSBadgeGroup","badgeGroupId",{
		badgeGroupId	=> $id,
		emsAssetId		=> $self->getId,
		name			=> $form->get('name'),
		});
	return $self->www_manageBadgeGroups;
}

#-------------------------------------------------------------------

=head2 www_editEventMetaField ( )

Displays the edit form for event meta fields.

=cut

sub www_editEventMetaField {
	my $self = shift;
	my $fieldId = shift || $self->session->form->process("fieldId");
	my $error = shift;
	return $self->session->privilege->insufficient unless ($self->canEdit);
	my $i18n2 = WebGUI::International->new($self->session,'Asset_EventManagementSystem');
	my $i18n = WebGUI::International->new($self->session,"WebGUIProfile");
	my $f = WebGUI::HTMLForm->new($self->session, (
		action => $self->getUrl("func=editEventMetaFieldSave;fieldId=".$fieldId)
	));
	my $data = {};
	if ($error) {
		# load submitted data.
		$data = {
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
		$data = $self->session->db->quickHashRef("select * from EMSEventMetaField where fieldId=?",[$fieldId]);
	} else {
		# new field defaults
		$data = {
			label => $i18n2->get('type label here'),
			dataType => 'text',
			visible => 1,
			required => 0,
		};
	}
	$f->text(
		-name => "label",
		-label => $i18n2->get('label'),
		-hoverHelp => $i18n2->get('label help'),
		-value => $data->{label},
		-extras=>(($data->{label} eq $i18n2->get('type label here'))?' style="color:#bbbbbb" ':'').' onblur="if(!this.value){this.value=\''.$i18n2->get('type label here').'\';this.style.color=\'#bbbbbb\';}" onfocus="if(this.value == \''.$i18n2->get('type label here').'\'){this.value=\'\';this.style.color=\'\';}"',
	);
	$f->yesNo(
		-name=>"visible",
		-label=>$i18n->get('473a'),
		-hoverHelp=>$i18n->get('473a description'),
		-value=>$data->{visible},
		defaultValue=>1,
	);
	$f->yesNo(
		-name=>"required",
		-label=>$i18n->get(474),
		-hoverHelp=>$i18n->get('474 description'),
		-value=>$data->{required}
	);
    $f->fieldType(
        -name=>"dataType",        
        -label=>$i18n->get(486),        
        -hoverHelp=>$i18n->get('486 description'),
        -value=>ucfirst $data->{dataType},        
        -defaultValue=>"Text",
        );
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
	$f->submit;
	return $self->processStyle($f->print);
}

#-------------------------------------------------------------------

=head2 www_editEventMetaFieldSave ( )

Processes the results from www_editEventMetaField ().

=cut

sub www_editEventMetaFieldSave {
	my $self = shift;
	return $self->session->privilege->insufficient unless ($self->canEdit);
	my $error = '';
	my $i18n = WebGUI::International->new($self->session,'Asset_EventManagementSystem');
	foreach ('label') {
		if ($self->session->form->get($_) eq "" || 
			$self->session->form->get($_) eq $i18n->get('type label here')) {
			$error .= sprintf($i18n->get('null field error'),$_)."<br />";
		}
	}
	return $self->www_editEventMetaField(undef,$error) if $error;
	my $newId = $self->setCollateral("EMSEventMetaField", "fieldId",{
		fieldId=>$self->session->form->process('fieldId'),
		label => $self->session->form->process("label"),
		dataType => $self->session->form->process("dataType",'fieldType'),
		visible => $self->session->form->process("visible",'yesNo'),
		required => $self->session->form->process("required",'yesNo'),
		possibleValues => $self->session->form->process("possibleValues",'textarea'),
		defaultValues => $self->session->form->process("defaultValues",'textarea'),
	},1,1);
	return $self->www_manageEventMetaFields();
}

#-------------------------------------------------------------------

=head2 www_editRegistrantSave ( )

=cut

sub www_editRegistrantSave {
	my $self = shift;
	return $self->session->privilege->insufficient unless ($self->isRegistrationStaff);
	my $form = $self->session->form;
	my %badgeInfo = (badgeId=>$form->get('badgeId'));
	foreach my $field (qw(name address1 address2 address3 city state organization notes)) {
		$badgeInfo{$field} = $form->get($field, "text");
	}
	$badgeInfo{'userId'} = $form->get('userId', 'user');
	$badgeInfo{'phoneNumber'} = $form->get('phoneNumber', 'phone');
	$badgeInfo{'email'} = $form->get('email', 'email');
	$badgeInfo{'country'} = $form->get('country', 'country');
	$badgeInfo{'zipcode'} = $form->get('zipcode', 'zipcode');
	$self->session->db->setRow('EMSRegistrant','badgeId', \%badgeInfo);
	return $self->www_manageRegistrant;
}

#-------------------------------------------------------------------

=head2 www_getBadgesAsJson ()

Retrieves a list of badges for the www_view() method.

=cut

sub www_getBadgesAsJson {
    my ($self) = @_;
	my $session = $self->session;
    return $session->privilege->insufficient() unless $self->canView;
    my ($db, $form) = $session->quick(qw(db form));
    my %results = ();
	foreach my $badge (@{$self->getBadges}) {
		push(@{$results{records}}, {
			title 				=> $badge->getTitle,
			description			=> $badge->get('description'),
			price				=> $badge->getPrice+0,
			quantityAvailable	=> $badge->getQuantityAvailable,
			url					=> $badge->getUrl,
			editUrl				=> $badge->getUrl('func=edit'),
			deleteUrl			=> $badge->getUrl('func=delete'),
			assetId				=> $badge->getId,
			});
	}
    $results{totalRecords} = $results{recordsReturned} = scalar(@{$results{records}});
    $results{'startIndex'} = 0;
    $results{'sort'}       = undef;
    $results{'dir'}        = "asc";
    $session->http->setMimeType('text/json');
    return JSON->new->utf8->encode(\%results);
}

#-------------------------------------------------------------------

=head2 www_getRegistrantAsJson (  )

Retrieves the properties of a specific badge and the items attached to it. Expects badgeId to be one of the form params.

=cut

sub www_getRegistrantAsJson {
	my ($self) = @_;
	my $session = $self->session;
	my $db = $session->db;
    return $session->privilege->insufficient() unless $self->canView;
    $session->http->setMimeType('text/json');
	my @tickets = ();
	my @tokens = ();
	my @ribbons = ();
	my $badgeId = $self->session->form->get('badgeId');

	# get badge info
	my $badgeInfo = $self->getRegistrant($badgeId);
	return "{}" unless (exists $badgeInfo->{badgeAssetId});
	my $badge = WebGUI::Asset::Sku::EMSBadge->new($session, $badgeInfo->{badgeAssetId});
	$badgeInfo->{title} = $badge->getTitle;
	$badgeInfo->{sku} = $badge->get('sku');
	$badgeInfo->{assetId} = $badge->getId;
	$badgeInfo->{hasPurchased} = ($badgeInfo->{purchaseComplete}) ? 1 : 0;
	
	# get existing tickets
	my $existingTickets = $db->read("select ticketAssetId from EMSRegistrantTicket where badgeId=? and purchaseComplete=1",[$badgeId]);
	while (my ($id) = $existingTickets->array) {
		my $ticket = WebGUI::Asset::Sku::EMSTicket->new($session, $id);
		push(@tickets, {
			title			=> $ticket->getTitle,
			eventNumber		=> $ticket->get('eventNumber'),
			hasPurchased 	=> 1,
			startDate		=> $ticket->get('startDate'),
			endDate			=> $ticket->get('endDate'),
			location		=> $ticket->get('location'),
			assetId			=> $ticket->getId,
			sku				=> $ticket->get('sku'),
			});
	}

	# get existing ribbons
	my $existingRibbons = $db->read("select ribbonAssetId from EMSRegistrantRibbon where badgeId=?",[$badgeId]);
	while (my ($id) = $existingRibbons->array) {
		my $ribbon = WebGUI::Asset::Sku::EMSRibbon->new($session, $id);
		push(@ribbons, {
			title			=> $ribbon->getTitle,
			hasPurchased 	=> 1,
			assetId			=> $ribbon->getId,
			sku				=> $ribbon->get('sku'),
			});
	}

	# get existing tokens
	my $existingTokens = $db->read("select tokenAssetId,quantity from EMSRegistrantToken where badgeId=?",[$badgeId]);
	while (my ($id, $quantity) = $existingTokens->array) {
		my $token = WebGUI::Asset::Sku::EMSToken->new($session, $id);
		push(@tokens, {
			title			=> $token->getTitle,
			hasPurchased 	=> 1,
			quantity		=> $quantity,
			assetId			=> $token->getId,
			sku				=> $token->get('sku'),
			});
	}

	# see what's in the cart
	my $cart = WebGUI::Shop::Cart->getCartBySession($session);
	foreach my $item (@{$cart->getItems}) {
		# not related to this badge, so skip it
		next unless $item->get('options')->{badgeId} eq $badgeId;

		my $sku = $item->getSku;
		# it's a ticket
		if ($sku->isa('WebGUI::Asset::Sku::EMSTicket')) {
			push(@tickets, {
				title			=> $sku->getTitle,
				eventNumber		=> $sku->get('eventNumber'),
				itemId 			=> $item->getId,
				startDate		=> $sku->get('startDate'),
				endDate			=> $sku->get('endDate'),
				location		=> $sku->get('location'),
				assetId			=> $sku->getId,
				sku				=> $sku->get('sku'),
				hasPurchased 	=> 0,
				price			=> $sku->getPrice+0,
				});
		}
		# it's a token
		elsif ($sku->isa('WebGUI::Asset::Sku::EMSToken')) {
			push(@tokens, {
				title			=> $sku->getTitle,
				itemId 			=> $item->getId,
				quantity		=> $item->get('quantity'),
				assetId			=> $sku->getId,
				hasPurchased 	=> 0,
				sku				=> $sku->get('sku'),				
				price			=> $sku->getPrice+0 * $item->get('quantity'),
				});
		}
		
		# it's a ribbon
		elsif ($sku->isa('WebGUI::Asset::Sku::EMSRibbon')) {
			push(@ribbons, {
				title			=> $sku->getTitle,
				itemId 			=> $item->getId,
				assetId			=> $sku->getId,
				hasPurchased 	=> 0,
				sku				=> $sku->get('sku'),				
				price			=> $sku->getPrice+0,
				});
		}
		# it's this badge
		elsif ($sku->isa('WebGUI::Asset::Sku::EMSBadge')) {
			$badgeInfo->{hasPurchased} = 0;
			$badgeInfo->{itemId} = $item->getId;
			$badgeInfo->{price} = $sku->getPrice+0;
		}
	}
	$badgeInfo->{tokens} = \@tokens;
	$badgeInfo->{tickets} = \@tickets;
	$badgeInfo->{ribbons} = \@ribbons;
	
	# build json datasource
    return JSON->new->utf8->encode($badgeInfo);
}

#-------------------------------------------------------------------

=head2 www_getRegistrantsAsJson (  )

Returns a list of registrants in the system. Can be a narrowed search by submitting a keywords form param with the request.

=cut

sub www_getRegistrantsAsJson {
	my ($self) = @_;
	my $session = $self->session;
    return $session->privilege->insufficient() unless $self->canView;
    my ($db, $form) = $session->quick(qw(db form));
    my $startIndex = $form->get('startIndex') || 0;
    my $numberOfResults = $form->get('results') || 25;
	my $keywords = $form->get('keywords');
	
	my $sql = "select SQL_CALC_FOUND_ROWS * from EMSRegistrant where purchaseComplete=1 and emsAssetId=?";
	my @params = ($self->getId);
	
	# user or staff
	unless ($self->isRegistrationStaff) {
		$sql .= " and userId=?";
		push @params, $session->user->userId;
	}

	# keyword search
    if ($keywords ne "") {
        $db->buildSearchQuery(\$sql, \@params, $keywords, [qw{badgeNumber name address1 address2 address3 city state country email notes zipcode phoneNumber organization}])
    }
	
	# limit
	$sql .= ' limit ?,?';
	push(@params, $startIndex, $numberOfResults);

	# get badge info
	my @records = ();
	my %results = ();
	my $badges = $db->read($sql,\@params);
    $results{'recordsReturned'} = $badges->rows()+0;
    $results{'totalRecords'} = $db->quickScalar('select found_rows()') + 0; ##Convert to numeric
	while (my $badgeInfo = $badges->hashRef) {
		my $badge = WebGUI::Asset::Sku::EMSBadge->new($session, $badgeInfo->{badgeAssetId});
		$badgeInfo->{title} = $badge->getTitle;
		$badgeInfo->{sku} = $badge->get('sku');
		$badgeInfo->{assetId} = $badge->getId;
		$badgeInfo->{manageUrl} = $self->getUrl('func=manageRegistrant;badgeId='.$badgeInfo->{badgeId});
		$badgeInfo->{buildBadgeUrl} = $self->getUrl('func=buildBadge;badgeId='.$badgeInfo->{badgeId});
		push(@records, $badgeInfo);
	}
    $results{'records'}      = \@records;
    $results{'startIndex'}   = $startIndex;
    $results{'sort'}         = undef;
    $results{'dir'}          = "asc";
	
	# build json datasource
    $session->http->setMimeType('text/json');
    return JSON->new->utf8->encode(\%results);
}


#-------------------------------------------------------------------

=head2 www_getRibbonsAsJson ()

Retrieves a list of ribbons for the www_buildBadge() method.

=cut

sub www_getRibbonsAsJson {
    my ($self) = @_;
	my $session = $self->session;
    return $session->privilege->insufficient() unless $self->canView;
    my ($db, $form) = $session->quick(qw(db form));
    my %results = ();
	foreach my $ribbon (@{$self->getRibbons}) {
		push(@{$results{records}}, {
			title 				=> $ribbon->getTitle,
			description			=> $ribbon->get('description'),
			price				=> $ribbon->getPrice+0,
			url					=> $ribbon->getUrl,
			editUrl				=> $ribbon->getUrl('func=edit'),
			deleteUrl			=> $ribbon->getUrl('func=delete'),
			assetId				=> $ribbon->getId,
			});
	}
    $results{totalRecords} = $results{recordsReturned} = scalar(@{$results{records}});
    $results{'startIndex'} = 0;
    $results{'sort'}       = undef;
    $results{'dir'}        = "asc";
    $session->http->setMimeType('text/json');
    return JSON->new->utf8->encode(\%results);
}


#-------------------------------------------------------------------

=head2 www_getTicketsAsJson ()

Retrieves a list of tickets for the www_buildBadge() method.

=cut

sub www_getTicketsAsJson {
    my ($self) = @_;
	my $session = $self->session;
    return $session->privilege->insufficient() unless $self->canView;
    my ($db, $form) = $session->quick(qw(db form));
    my $startIndex = $form->get('startIndex') || 0;
    my $numberOfResults = $form->get('results') || 25;
    my %results = ();
	my @ids = ();
	my $keywords = $form->get('keywords');
	
	# looking for specific events
	if ($keywords =~ m{^[\d+,*\s*]+$}) {
		@ids = $db->buildArray("select distinct(EMSTicket.assetId) from EMSTicket left join asset using (assetId) where
			asset.parentId=? and EMSTicket.eventNumber in (".$keywords.") order by EMSTicket.eventNumber",[$self->getId]);
	}
	
	# looking for keywords
	elsif ($keywords ne "") {
		@ids = @{WebGUI::Search->new($session)->search({
			keywords	=> $keywords,
			lineage		=> [$self->get('lineage')],
			classes		=> ['WebGUI::Asset::Sku::EMSTicket'],
			})->getAssetIds};
	}
	
	# just get all tickets
	else {
		@ids = $db->buildArray("select assetId from asset left join EMSTicket using (assetId) where parentId=? and className='WebGUI::Asset::Sku::EMSTicket' and revisionDate=(select max(revisionDate) from EMSTicket where assetId=asset.assetId) order by eventNumber", [$self->getId]);
	}
	
	# get badge's badge groups
	my $badgeId = $form->get('badgeId');
	my @badgeGroups = ();
	if (defined $badgeId) {
		my $assetId = $db->quickScalar("select badgeAssetId from EMSRegistrant where badgeId=?",[$badgeId]);
		my $badge = WebGUI::Asset->new($session, $assetId, 'WebGUI::Asset::Sku::EMSBadge');
		@badgeGroups = split("\n",$badge->get('relatedBadgeGroups')) if (defined $badge);
	}
	
	# get a list of tickets already associated with the badge
	my @existingTickets = $db->buildArray("select ticketAssetId from EMSRegistrantTicket where badgeId=?",[$badgeId]);
	
	# get assets
	my $counter = 0;
	my $totalTickets = scalar(@ids);
	my @records = ();
	foreach my $id (@ids) {

		# gotta get to the page we're working with
		next unless ($counter >= $startIndex);

		# skip tickets we already have
		if (isIn($id, @existingTickets)) {
			$totalTickets--;
			next;
		}

		my $ticket = WebGUI::Asset->new($session, $id, 'WebGUI::Asset::Sku::EMSTicket');
		
		# skip borked tickets
		unless (defined $ticket) {
			$session->errorHandler->warn("EMSTicket $id couldn't be instanciated by EMS ".$self->getId.".");
			$totalTickets--;
			next;
		}
		
		# skip tickets we can't view
		unless ($ticket->canView) {
			$totalTickets--;
			next;
		}
		
		# skip tickets not in our badge's badge groups
		if ($badgeId ne "" && scalar(@badgeGroups) > 0 && $ticket->get('relatedBadgeGroups') ne '') { # skip check if it has no badge groups
			my @groups = split("\n",$ticket->get('relatedBadgeGroups'));
			my $found = 0;
			BADGE: {
				foreach my $a (@badgeGroups) {
					foreach my $b (@groups) {
						if ($a eq $b) {
							$found = 1;
							last BADGE;
						}
					}
				}
			}
			unless ($found) {
				$totalTickets--;
				next;
			}
		}
		
		# publish the data for this ticket
        my $description = $ticket->get('description');
        my $data = $ticket->get('eventMetaData');
        $data = '{}' if ($data eq "");
        my $meta = JSON->new->utf8->decode($data);
        foreach my $field (keys %{$meta}) {
            $description .= '<p><b>'.$field.'</b>: '.$meta->{$field}.'</p>' unless ($meta->{$field} eq "");
        }
		my $date = WebGUI::DateTime->new($session, $ticket->get('startDate'));
		push(@records, {
			title 				=> $ticket->getTitle,
			description			=> $description,
			price				=> $ticket->getPrice+0,
			quantityAvailable	=> $ticket->getQuantityAvailable,
			url					=> $ticket->getUrl,
			editUrl				=> $ticket->getUrl('func=edit'),
			deleteUrl			=> $ticket->getUrl('func=delete'),
			assetId				=> $ticket->getId,
			eventNumber			=> $ticket->get('eventNumber'),
			location			=> $ticket->get('location'),
			startDate			=> $date->webguiDate("%W @ %H:%n%p"),
			duration			=> $ticket->get('duration'),
			});
		last unless (scalar(@records) < $numberOfResults);
		$counter++;
	}
	
	# humor
	my $find = pack('u',$keywords);
	chomp $find;
	if ($find eq q|'2$%,,C`P,0``|) {
		push(@records, {title=>unpack('u',q|022=M('-O<G)Y+"!$879E+@``|)});
		$totalTickets++;
	}
	
	# build json
	$results{records} 			= \@records;
    $results{totalRecords} 		= $totalTickets;
	$results{recordsReturned} 	= scalar(@records);
    $results{'startIndex'}   	= $startIndex;
    $results{'sort'}       		= undef;
    $results{'dir'}        		= "asc";
    $session->http->setMimeType('text/json');
    return JSON->new->utf8->encode(\%results);
}


#-------------------------------------------------------------------

=head2 www_getTokensAsJson ()

Retrieves a list of tokens for the www_buildBadge() method.

=cut

sub www_getTokensAsJson {
    my ($self) = @_;
	my $session = $self->session;
    return $session->privilege->insufficient() unless $self->canView;
    my ($db, $form) = $session->quick(qw(db form));
    my %results = ();
	foreach my $token (@{$self->getTokens}) {
		push(@{$results{records}}, {
			title 				=> $token->getTitle,
			description			=> $token->get('description'),
			price				=> $token->getPrice+0,
			url					=> $token->getUrl,
			editUrl				=> $token->getUrl('func=edit'),
			deleteUrl			=> $token->getUrl('func=delete'),
			assetId				=> $token->getId,
			});
	}
    $results{totalRecords} = $results{recordsReturned} = scalar(@{$results{records}});
    $results{'startIndex'} = 0;
    $results{'sort'}       = undef;
    $results{'dir'}        = "asc";
    $session->http->setMimeType('text/json');
    return JSON->new->utf8->encode(\%results);
}

#-------------------------------------------------------------------

=head2 www_lookupRegistrant ()

Displays the badges purchased by the current user, or all users if the user is part of the registration staff.

=cut

sub www_lookupRegistrant {
	my ($self) = @_;
	my $session = $self->session;
	return $session->privilege->noAccess() unless ($self->canView && $self->session->user->userId ne "1");

	# set up template variables
	my %var = (
		buyBadgeUrl			=> $self->getUrl,
		viewEventsUrl		=> $self->getUrl('func=buildBadge'),
		viewCartUrl			=> $self->getUrl('shop=cart'),
		getRegistrantsUrl	=> $self->getUrl('func=getRegistrantsAsJson'),
		isRegistrationStaff	=> $self->isRegistrationStaff,		
		);

	# render the page
	return $self->processStyle($self->processTemplate(\%var, $self->get('lookupRegistrantTemplateId')));
}

#-------------------------------------------------------------------

=head2 www_manageBadgeGroups ()

Displays a list of badge groups.

=cut

sub www_manageBadgeGroups {
	my $self = shift;
	my $session = $self->session;
    return $session->privilege->insufficient() unless $self->canView;
	my $i18n = WebGUI::International->new($session, 'Asset_EventManagementSystem');
	my $output = '<h1>'.$i18n->get('badge groups')
		.q|</h1><p><a href="|.$self->getUrl("func=editBadgeGroup").q|">|.$i18n->get('add a badge group').q|</a>
		&bull; <a href="|.$self->getUrl.q|">|.$i18n->get('view badges').q|</a>
		</p>|;
	my $groups = $session->db->read("select badgeGroupId,name from EMSBadgeGroup where emsAssetId=?",[$self->getId]);
	my $badgeGroups = $self->getBadgeGroups;
	foreach my $id (keys %{$badgeGroups}) {
		$output .= q|<div>[<a href="|.$self->getUrl("func=deleteBadgeGroup;badgeGroupId=".$id).q|">|.$i18n->get('delete').q|</a>
			/ <a href="|.$self->getUrl("func=editBadgeGroup;badgeGroupId=".$id).q|">|.$i18n->get('edit').q|</a>]
			|.$badgeGroups->{$id}.q|</div>|;
	}
	return $self->processStyle($output);
}

#-------------------------------------------------------------------

=head2 www_manageEventMetaFields ( )

Method to display the event metadata management console.

=cut

sub www_manageEventMetaFields {
	my $self = shift;

	return $self->session->privilege->insufficient unless ($self->canEdit);

	my $i18n = WebGUI::International->new($self->session,'Asset_EventManagementSystem');
	my $output = '<h1>'.$i18n->get('meta fields')
		.q|</h1><p><a href="|.$self->getUrl("func=editEventMetaField").q|">|.$i18n->get('add an event meta field').q|</a>
		&bull; <a href="|.$self->getUrl('func=buildBadge').q|">|.$i18n->get('view tickets').q|</a>
		</p>|;
	my $metadataFields = $self->getEventMetaFields;
	my $count = 0;
	my $number = scalar(@{$metadataFields});
	if ($number) {
		foreach my $row1 (@{$metadataFields}) {
			my %row = %{$row1};
			$count++;
			$output .= "<div>".
			$self->session->icon->delete('func=deleteEventMetaField;fieldId='.$row{fieldId},$self->get('url'),$i18n->get('confirm delete event metadata')).
			$self->session->icon->edit('func=editEventMetaField;fieldId='.$row{fieldId}, $self->get('url')).
			$self->session->icon->moveUp('func=moveEventMetaFieldUp;fieldId='.$row{fieldId}, $self->get('url'),($count == 1)?1:0);
			$output .= $self->session->icon->moveDown('func=moveEventMetaFieldDown;fieldId='.$row{fieldId}, $self->get('url'),($count == $number)?1:0).
			" ".$row{label}."</div>";
		}
	}
	else {
		$output .= $i18n->get('you do not have any metadata fields to display');
	}
	return $self->processStyle($output);
}

#-------------------------------------------------------------------

=head2 www_manageRegistrant ()

Displays an admin interface for managing a registrant.

=cut

sub www_manageRegistrant {
	my $self = shift;
	my $session = $self->session;
	
	# check privs
	return $session->privilege->insufficient unless ($self->isRegistrationStaff);
	
	# setup 
	my $badgeId = $self->session->form->get('badgeId');
	my $db = $session->db;
	my $i18n = WebGUI::International->new($session, "Asset_EventManagementSystem");
	my $registrant = $self->getRegistrant($badgeId);

	# show lookup registrant if registrant requested doesn't exist
	unless ($registrant->{badgeId} ne "") {
		return $self->www_lookupRegistrant;
	}
	
	# build form
	my $f = WebGUI::HTMLForm->new($session, action=>$self->getUrl, tableExtras=>'class="manageRegistrant"');
	$f->submit;
	$f->hidden(name=>"func", value=>"editRegistrantSave");
	$f->hidden(name=>'badgeId', value=>$badgeId);
	$f->readOnly(
		label			=> $i18n->get('badge number'),
		value			=> $registrant->{badgeNumber},
	);
	$f->user(
		name			=> 'userId',
		label			=> $i18n->get('user'),
		defaultValue	=> $registrant->{userId},
	);
	$f->text(
		name			=> 'name',
		label			=> $i18n->get('name','Shop'),
		defaultValue	=> $registrant->{name},
		);
	$f->text(
		name			=> 'organization',
		label			=> $i18n->get('organization'),
		defaultValue	=> $registrant->{organization},
		);
	$f->text(
		name			=> 'address1',
		label			=> $i18n->get('address','Shop'),		
		defaultValue	=> $registrant->{address1},
		);
	$f->text(
		name			=> 'address2',
		defaultValue	=> $registrant->{address2},
		);
	$f->text(
		name			=> 'address3',
		defaultValue	=> $registrant->{address3},
		);
	$f->text(
		name			=> 'city',
		label			=> $i18n->get('city','Shop'),		
		defaultValue	=> $registrant->{city},
		);
	$f->text(
		name			=> 'state',
		label			=> $i18n->get('state','Shop'),		
		defaultValue	=> $registrant->{state},
		);
	$f->zipcode(
		name			=> 'zipcode',
		label			=> $i18n->get('code','Shop'),		
		defaultValue	=> $registrant->{zipcode},
		);
	$f->country(
		name			=> 'country',
		label			=> $i18n->get('country','Shop'),		
		defaultValue	=> $registrant->{country},
		);
	$f->phone(
		name			=> 'phoneNumber',
		label			=> $i18n->get('phone number','Shop'),		
		defaultValue	=> $registrant->{phoneNumber},
		);
	$f->email(
		name			=> 'email',
		label			=> $i18n->get('email address'),
		defaultValue	=> $registrant->{email}
		);
	$f->textarea(
		name			=> 'notes',
		label			=> $i18n->get('notes'),
		defaultValue	=> $registrant->{notes}
		);
	$f->submit;
	
	# build html
	my $output = q|
	<div id="doc3">
		<div id="hd">
			^ViewCart;
			&bull; <a href="|.$self->getUrl('func=lookupRegistrant').q|">|.$i18n->get('lookup badge').q|</a>
			&bull; <a href="|.$self->getUrl.q|">|.$i18n->get('buy badge').q|</a>
		</div>
		<div id="bd">
			<div class="yui-gc">
				<div class="yui-u first">
				|.$f->print.q|
				</div>
				<div class="yui-u">
		|;
			
	if ($registrant->{hasCheckedIn}) {
		$output .= q|<a style="font-size: 200%; margin: 10px; line-height: 200%; padding: 10px; background-color: #ffdddd; color: #800000; text-decoration: none;" href="|.$self->getUrl('func=toggleRegistrantCheckedIn;badgeId='.$badgeId).q|">|.$i18n->get('checked in').q|</a>|;
	}
	else {
		$output .= q|<a style="font-size: 200%; margin: 10px; line-height: 200%; padding: 10px; background-color: #ddffdd; color: #008000; text-decoration: none;" href="|.$self->getUrl('func=toggleRegistrantCheckedIn;badgeId='.$badgeId).q|">|.$i18n->get('not checked in').q|</a>|;
	}

	# badge management
	my $badge = WebGUI::Asset::Sku::EMSBadge->new($session, $registrant->{badgeAssetId});
	$output .= q|<p><b style="font-size: 150%; line-height: 150%;">|.$badge->getTitle.q|</b><br />
		<a href="|.$self->getUrl('func=printBadge;badgeId='.$badgeId).q|" target="_blank">|.$i18n->get('print').q|</a>
		&bull; <a href="|.$self->getUrl('func=refundItem;badgeId='.$badgeId.';transactionItemId='.$registrant->{transactionItemId}).q|">|.$i18n->get('refund').q|</a>
		&bull; |;
	if ($registrant->{hasCheckedIn}) {
		$output .= q|<a href="|.$self->getUrl('func=toggleRegistrantCheckedIn;badgeId='.$badgeId).q|">|.$i18n->get('mark as not checked in').q|</a>|;
	}
	else {
		$output .= q|<a href="|.$self->getUrl('func=toggleRegistrantCheckedIn;badgeId='.$badgeId).q|">|.$i18n->get('mark as checked in').q|</a>|;
	}
	$output .= q|
		&bull; <a href="|.$self->getUrl('func=buildBadge;badgeId='.$badgeId).q|">|.$i18n->get('add more items').q|</a>
		</p><br />|;
	
	# ticket management
	my $existingTickets = $db->read("select ticketAssetId, transactionItemId from EMSRegistrantTicket where badgeId=? and purchaseComplete=1",[$badgeId]);
	while (my ($id, $itemId) = $existingTickets->array) {
		my $ticket = WebGUI::Asset::Sku::EMSTicket->new($session, $id);
		$output .= q|<p><b>|.$ticket->getTitle.q|</b><br />
			<a href="|.$self->getUrl('func=printTicket;badgeId='.$badgeId.';ticketAssetId='.$id).q|" target="_blank">|.$i18n->get('print').q|</a>
			&bull; <a href="|.$self->getUrl('func=refundItem;badgeId='.$badgeId.';transactionItemId='.$itemId).q|">|.$i18n->get('refund').q|</a>
			</p><br />|;
	}

	# ribbon management
	my $existingRibbons = $db->read("select ribbonAssetId, transactionItemId from EMSRegistrantRibbon where badgeId=?",[$badgeId]);
	while (my ($id, $itemId) = $existingRibbons->array) {
		my $ribbon = WebGUI::Asset::Sku::EMSRibbon->new($session, $id);
		$output .= q|<p><b>|.$ribbon->getTitle.q|</b><br />
			<a href="|.$self->getUrl('func=refundItem;badgeId='.$badgeId.';transactionItemId='.$itemId).q|">|.$i18n->get('refund').q|</a>
			</p><br />|;
	}

	# token management
	my $existingTokens = $db->read("select tokenAssetId,quantity,transactionItemIds from EMSRegistrantToken where badgeId=?",[$badgeId]);
	while (my ($id, $quantity, $itemIds) = $existingTokens->array) {
		my $token = WebGUI::Asset::Sku::EMSToken->new($session, $id);
		my @itemIds = split(',', $itemIds);
		$output .= q|<p><b>|.$token->getTitle.q|</b> (|.$quantity.q|)<br />
			<a href="|.$self->getUrl('func=refundItem;badgeId='.$badgeId.';transactionItemId='.join(';transactionItemId=', @itemIds)).q|">|.$i18n->get('refund').q|</a>
			</p><br />|;
	}

	$output .= q|
				</div>
			</div>
		</div>
		<div id="ft"></div>
	</div>
	|;

	# render
	$session->style->setLink($session->url->extras('/yui/build/reset-fonts-grids/reset-fonts-grids.css'), {rel=>"stylesheet", type=>"text/css"});
	$session->style->setRawHeadTags(q|
		<style type="text/css">
		.manageRegistrant tbody tr td { padding: 2px;}
		</style>
		|);
	return $self->processStyle($output);
}

#-------------------------------------------------------------------

=head2 www_moveEventMetaFieldDown ( )

Method to move an event down one position in display order

=cut

sub www_moveEventMetaFieldDown {
	my $self = shift;
	return $self->session->privilege->insufficient unless ($self->canEdit);
	$self->moveCollateralDown('EMSEventMetaField', 'fieldId', $self->session->form->get("fieldId"));
	return $self->www_manageEventMetaFields;
}

#-------------------------------------------------------------------

=head2 www_moveEventMetaFieldUp ( )

Method to move an event metdata field up one position in display order

=cut

sub www_moveEventMetaFieldUp {
	my $self = shift;
	return $self->session->privilege->insufficient unless ($self->canEdit);
	$self->moveCollateralUp('EMSEventMetaField', 'fieldId', $self->session->form->get("fieldId"));
	return $self->www_manageEventMetaFields;
}

#-------------------------------------------------------------------

=head2 www_printBadge ( )

Prints a badge using a template.

=cut

sub www_printBadge {
	my $self = shift;
	my $session = $self->session;
	return $session->privilege->insufficient unless ($self->isRegistrationStaff);
	my $form = $session->form;
	my $registrant = $self->getRegistrant($form->get('badgeId'));
	my $badge = WebGUI::Asset::Sku::EMSBadge->new($session, $registrant->{badgeAssetId});
	$registrant->{badgeTitle} = $badge->getTitle;
	return $self->processTemplate($registrant,$self->get('printBadgeTemplateId'));
}

#-------------------------------------------------------------------

=head2 www_printTicket ( )

Prints a ticket using a template.

=cut

sub www_printTicket {
	my $self = shift;
	my $session = $self->session;
	return $session->privilege->insufficient unless ($self->isRegistrationStaff);
	my $form = $session->form;
	my $registrant = $self->getRegistrant($form->get('badgeId'));
	my $ticket = WebGUI::Asset::Sku::EMSTicket->new($session, $form->get('ticketAssetId'));
	$registrant->{ticketTitle} = $ticket->getTitle;
	$registrant->{ticketStart} = $ticket->get('startDate');
	$registrant->{ticketDuration} = $ticket->get('duration');
	$registrant->{ticketLocation} = $ticket->get('location');
	$registrant->{ticketEventNumber} = $ticket->get('eventNumber');
	return $self->processTemplate($registrant,$self->get('printTicketTemplateId'));
}


#-------------------------------------------------------------------

=head2 www_refundItem ()

Removes a ribbon, token, or ticket or badge that is attached to a registrant.

=cut

sub www_refundItem {
	my $self = shift;
	my $session = $self->session;
    return $session->privilege->insufficient() unless $self->canView;
	my @itemIds = $session->form->param("transactionItemId");
	foreach my $id (@itemIds) {
		my $item = WebGUI::Shop::TransactionItem->newByDynamicTransaction($session, $id);
		if (defined $item) {
			$item->issueCredit;
		}
	}
	return $self->www_manageRegistrant();	
}


#-------------------------------------------------------------------

=head2 www_removeItemFromBadge ()

Removes a ribbon, token, or ticket from a badge that is in the cart.

=cut

sub www_removeItemFromBadge {
	my $self = shift;
	my $session = $self->session;
    return $session->privilege->insufficient() unless $self->canView;
    my $form = $session->form;
	my $cart = WebGUI::Shop::Cart->getCartBySession($session);
	my $item = $cart->getItem($form->get('itemId'));
    $item->remove;
	return $self->www_getRegistrantAsJson();	
}


#-------------------------------------------------------------------

=head2 www_toggleRegistrantCheckedIn ()

Toggles the registrant checked in flag.

=cut

sub www_toggleRegistrantCheckedIn {
	my $self = shift;
	return $self->session->privilege->insfufficient() unless ($self->isRegistrationStaff);
	my $db = $self->session->db;
	my $badgeId = $self->session->form->param('badgeId');
	my $flag = $db->quickScalar("select hasCheckedIn from EMSRegistrant where badgeId=?",[$badgeId]);
	$flag = ($flag == 1) ? 0 : 1;
	$db->write("update EMSRegistrant set hasCheckedIn=? where badgeId=?",[$flag, $badgeId]);
	return $self->www_manageRegistrant;
}






























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
	my $fieldList = $self->getEventMetaFields;
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
	$ac->addSubmenuItem($self->getUrl('func=search'),$i18n->get("manage events"));
	$ac->addSubmenuItem($self->getUrl('func=manageEventMetadata'), $i18n->get('manage event metadata'));
	$ac->addSubmenuItem($self->getUrl('func=managePrereqSets'), $i18n->get('manage prerequisite sets'));
	$ac->addSubmenuItem($self->getUrl('func=searchBadges'), "Search Badges");
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
		from EMSEventMetaField f
		left join EMSEventMetaData d on f.fieldId=d.fieldId
		and d.productId=? $globalWhere
		order by f.sequenceNumber";
	tie my %hash, 'Tie::IxHash';
	my $sth = $self->session->db->read($sql,[$productId]);
	while( my $h = $sth->hashRef) {
		foreach(keys %$h) {
			$hash{$h->{fieldId}}{$_} = $h->{$_};
		}
	}
	$sth->finish;
	return \%hash;
}

#------------------------------------------------------------------

sub purge {
    my $self = shift;
    my $db = $self->session->db;
    # delete meta fields
    my $sth = $db->read("select fieldId from EMSEventMetaField where assetId=?",[$self->getId]);
    while (my ($id) = $sth->array) {
        $self->deleteMetaField($id);
    }
    # delete events
    $sth = $db->read("select productId from EventManagementSystem_products where assetId=?",[$self->getId]);
    while (my ($id) = $sth->array) {
        $self->deleteEvent($id);
    }
    # delete prereqs
    $sth = $db->read("select prerequisiteId from EventManagementSystem_prerequisites where assetId=?",[$self->getId]);
    while (my ($id) = $sth->array) {
        $self->deletePrereqSet($id);
    }
    # delete badges
    $sth = $db->read("select badgeId from EventManagementSystem_badges where assetId=?",[$self->getId]);
    while (my ($id) = $sth->array) {
        $self->deleteBadge($id);
    }
    $self->SUPER::purge(@_);
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
	
	return $self->session->privilege->insufficient unless $self->canEdit;

	my $i18n = WebGUI::International->new($self->session,'Asset_EventManagementSystem');
	my $csv = Text::CSV_XS->new({ eol => "\n", binary => 1 }); # TODO use their newline?
	
	# if we need to punt
	my @error_args = ($i18n->get('export error'), $i18n->get('export events'));
	
	# get standard & metaField labels TODO - refactor this
	my @std_labels = map $i18n->get($_), ( 'status', 'add/edit event title', 'add/edit event description',
		'add/edit event image', 'add/edit useSalesTax', 'price', 'add/edit event template', 'weight', 'sku',
		'sku template', 'add/edit event start date', 'add/edit event end date', 'add/edit event maximum attendees',
		'prereq set name field label' );

	my $meta_fields_aref = $self->getEventMetaFields;
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

	my $custom_rows_aref = $self->getEventMetaFields;
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

	return $self->session->privilege->insufficient unless $self->canEdit;
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

	return $self->session->privilege->insufficient unless $self->canEdit;
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
	my $meta_fields_aref = $self->getEventMetaFields;
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
			my $sql = "insert into EMSEventMetaData values (".
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


1;
