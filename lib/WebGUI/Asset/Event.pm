package WebGUI::Asset::Event;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::CPHash;
use WebGUI::DateTime;
use WebGUI::Form;
use WebGUI::Grouping;
use WebGUI::HTML;
use WebGUI::HTMLForm;
use WebGUI::HTTP;
use WebGUI::Icon;
use WebGUI::Id;
use WebGUI::International;
use WebGUI::MessageLog;
use WebGUI::Operation;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Style;
use WebGUI::Asset::Template;
use WebGUI::URL;
use WebGUI::User;
use WebGUI::Utility;
use WebGUI::Asset;
use WebGUI::Asset::Wobject::EventsCalendar;

our @ISA = qw(WebGUI::Asset);



#-------------------------------------------------------------------
sub definition {
	my $class = shift;
  my $definition = shift;
  push(@{$definition}, {
    tableName=>'EventsCalendar_event',
    className=>'WebGUI::Asset::Event',
    properties=>{
			description => {
				fieldType=>"HTMLArea",
				defaultValue=>undef
				},
			eventStartDate => {
				fieldType=>"dateTime",
				defaultValue=>time()
				},
			eventEndDate => {
				fieldType=>"dateTime",
				defaultValue=>time()
				},
			EventsCalendar_recurringId => {
				fieldType=>"hidden",
				defaultValue=>undef
				},
			eventLocation => {
				fieldType=>"text",
				defaultValue=>undef
				},
#			allowRegistration => {
#				fieldType=>"yesNo",
#				defaultValue=>0
#				},
#			allowUnregistration => {
#				fieldType=>"yesNo",
#				defaultValue=>0
#				},
#			regConfirm => {
#				fieldType=>"yesNo",
#				defaultValue=>0
#				},
#			regNotify => {
#				fieldType=>"yesNo",
#				defaultValue=>0
#				},
#			regStartDate => {
#				fieldType=>"dateTime",
#				defaultValue=>time()
#				},
#			regEndDate => {
#				fieldType=>"dateTime",
#				defaultValue=>time()
#				},
#			allowReminders => {
#				fieldType=>"yesNo",
#				defaultValue=>0
#				},
#			reminderStartDate => {
#				fieldType=>"dateTime",
#				defaultValue=>time()
#				},
#			reminderEndDate => {
#				fieldType=>"dateTime",
#				defaultValue=>time()
#				},
#			reminderRecurs => {
#				fieldType=>"interval",
#				defaultValue=>604800
#				},
#			chargeForEvent => {
#				fieldType=>"yesNo",
#				defaultValue=>0
#				},
#			firstAttendeeFee => {
#				fieldType=>"float",
#				defaultValue=>0
#				},
#			secondAttendeeFee => {
#				fieldType=>"float",
#				defaultValue=>0
#				},
#			availableSeats => {
#				fieldType=>"integer",
#				defaultValue=>0
#				},
			templateId => {
				fieldType=>"template",
				defaultValue=>'PBtmpl0000000000000023'
				},
#			regConfirmTemplateId => {
#				fieldType=>"template",
#				defaultValue=>'MWtmplregConfirm000001'
#				},
#			regNotifyTemplateId => {
#				fieldType=>"template",
#				defaultValue=>'MWtmplregNotify0000001'
#				},
#			reminderTemplateId => {
#				fieldType=>"template",
#				defaultValue=>'MWtmplreminder00000001'
#				},
#			groupCanRegister => {
#				fieldType=>"group",
#				defaultValue=>'2'
#				},
#			groupCanReminder => {
#				fieldType=>"group",
#				defaultValue=>'2'
#				},
#			groupRegNotify => {
#				fieldType=>"group",
#				defaultValue=>'3'
#			}
		}
	});
	return $class->SUPER::definition($definition);
}



#-------------------------------------------------------------------
sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm();
	#return $tabform;
	$tabform->getTab("properties")->HTMLArea(
		-name=>"description", -label=>WebGUI::International::get(512,"EventsCalendar"),
		-value=>$self->getValue("description")
		);
	$tabform->getTab("properties")->dateTime(
		-name=>"eventStartDate", -label=>WebGUI::International::get(513,"EventsCalendar"),
		-extras=>'onBlur="this.form.eventEndDate.value=this.form.eventStartDate.value;this.form.until.value=this.form.eventStartDate.value;"',
		-value=>$self->getValue("eventStartDate")
		);
	$tabform->getTab("properties")->dateTime(
		-name=>"eventEndDate", -label=>WebGUI::International::get(514,"EventsCalendar"),
		-extras=>'onBlur="this.form.until.value=this.form.eventEndDate.value;"',
		-value=>$self->getValue("eventEndDate")
		);
	$tabform->getTab("properties")->text(
		-name=>"eventLocation", -label=>WebGUI::International::get(515,"EventsCalendar"),
		-value=>$self->getValue("eventLocation")
		);
#	$tabform->getTab("properties")->yesNo(
#		-name=>"allowRegistration", -label=>WebGUI::International::get(516,"EventsCalendar"),
#		-value=>$self->getValue("allowRegistration")
#		);
#	$tabform->getTab("properties")->yesNo(
#		-name=>"allowUnregistration", -label=>WebGUI::International::get(517,"EventsCalendar"),
#		-value=>$self->getValue("allowUnregistration")
#		);
#	$tabform->getTab("properties")->yesNo(
#		-name=>"regConfirm", -label=>WebGUI::International::get(518,"EventsCalendar"),
#		-value=>$self->getValue("regConfirm")
#		);
#  $tabform->getTab("properties")->yesNo(
#		-name=>"regNotify", -label=>WebGUI::International::get(519,"EventsCalendar"),
#		-value=>$self->getValue("regNotify")
#		);
#	$tabform->getTab("properties")->dateTime(
#		-name=>"regStartDate", -label=>WebGUI::International::get(520,"EventsCalendar"),
#		-extras=>'onBlur="this.form.regEndDate.value=this.form.regStartDate.value;this.form.until.value=this.form.regStartDate.value;"',
#		-value=>$self->getValue("regStartDate")
#		);
#	$tabform->getTab("properties")->dateTime(
#		-name=>"regEndDate", -label=>WebGUI::International::get(521,"EventsCalendar"),
#		-extras=>'onBlur="this.form.until.value=this.form.regEndDate.value;"',
#		-value=>$self->getValue("regEndDate")
#		);
#	$tabform->getTab("properties")->yesNo(
#		-name=>"allowReminders", -label=>WebGUI::International::get(522,"EventsCalendar"),
#		-value=>$self->getValue("allowReminders")
#		);
#	$tabform->getTab("properties")->dateTime(
#		-name=>"reminderStartDate", -label=>WebGUI::International::get(523,"EventsCalendar"),
#		-extras=>'onBlur="this.form.reminderEndDate.value=this.form.reminderStartDate.value;this.form.until.value=this.form.reminderStartDate.value;"',
#		-value=>$self->getValue("reminderStartDate")
#		);
#	$tabform->getTab("properties")->dateTime(
#		-name=>"reminderEndDate", -label=>WebGUI::International::get(524,"EventsCalendar"),
#		-extras=>'onBlur="this.form.until.value=this.form.reminderEndDate.value;"',
#		-value=>$self->getValue("regEndDate")
#		);
#	$tabform->getTab("properties")->interval(
#		-name=>"reminderRecurs", 
#		-label=>WebGUI::International::get(524.5,"EventsCalendar"),
#		-value=>$self->getValue("reminderRecurs")
#		);
# Not quite implemented yet...
#	$tabform->getTab("properties")->yesNo(
#		-name=>"chargeForEvent", -label=>WebGUI::International::get(525,"EventsCalendar"),
#		-value=>$self->getValue("chargeForEvent")
#		);
#	$tabform->getTab("properties")->float(
#		-name=>"firstAttendeeFee", -label=>WebGUI::International::get(526,"EventsCalendar"),
#		-value=>$self->getValue("firstAttendeeFee")
#		);
#	$tabform->getTab("properties")->float(
#		-name=>"secondAttendeeFee", -label=>WebGUI::International::get(527,"EventsCalendar"),
#		-value=>$self->getValue("secondAttendeeFee")
#		);
#	$tabform->getTab("properties")->integer(
#		-name=>"availableSeats", -label=>WebGUI::International::get(528,"EventsCalendar"),
#		-value=>$self->getValue("availableSeats")
#		);
	if (($session{form}{func} eq "addStyledEvent") || ($session{form}{func} eq "addEvent")) {
		my %recursEvery;
		tie %recursEvery, 'Tie::IxHash';
		%recursEvery = (
			'never'=>WebGUI::International::get(4,"EventsCalendar"),
			'day'=>WebGUI::International::get(700,"EventsCalendar"),
			'week'=>WebGUI::International::get(701,"EventsCalendar"),
			'month'=>WebGUI::International::get(702,"EventsCalendar"),
			'year'=>WebGUI::International::get(703,"EventsCalendar"),
		);
		$tabform->getTab("properties")->readOnly(
			-label=>WebGUI::International::get(8,"EventsCalendar"),
			-value=>WebGUI::Form::integer({
				name=>"interval",
				defaultValue=>1
				})
				.WebGUI::Form::selectList({
					name=>"recursEvery",
					options=>\%recursEvery
					})
				.' '.WebGUI::International::get(9,"EventsCalendar").' '
				.WebGUI::Form::date({
					name=>"until"
					})
			);
	}
#	$tabform->getTab("display")->template(
#    -name=>"confirmationTemplateId",
#    -value=>$self->getValue("confirmationTemplateId"),
#    -namespace=>"EventsCalendar/Event",
#    -label=>WebGUI::International::get(529,"EventsCalendar"),
#    -afterEdit=>'func=edit'
#    );
	$tabform->getTab("display")->template(
    -name=>"templateId",
    -value=>$self->getValue("templateId"),
    -namespace=>"EventsCalendar/Event",
    -label=>WebGUI::International::get(530,"EventsCalendar"),
    -afterEdit=>'func=edit&wid='.$self->get("wobjectId")
    );
#	$tabform->getTab("display")->template(
#    -name=>"regNotifyTemplateId",
#    -value=>$self->getValue("regNotifyTemplateId"),
#    -namespace=>"EventsCalendar/Event",
#    -label=>WebGUI::International::get(531,"EventsCalendar"),
#    -afterEdit=>'func=edit&wid='.$self->get("wobjectId")
#    );
#  $tabform->getTab("display")->template(
#  	-name=>"reminderTemplateId",
#		-value=>$self->getValue("reminderTemplateId"),
#		-namespace=>"EventsCalendar/Event",
#		-label=>WebGUI::International::get(532,"EventsCalendar"),
#		-afterEdit=>'func=edit&wid='.$self->get("wobjectId")
#		);
#	$tabform->getTab("security")->group(
#		-name=>"groupCanRegister", -label=>WebGUI::International::get(533,"EventsCalendar"),
#		-value=>[$self->getValue("groupCanRegister")]
#		);
#	$tabform->getTab("security")->group(
#		-name=>"groupCanReminder", -label=>WebGUI::International::get(534,"EventsCalendar"),
#		-value=>[$self->getValue("groupCanReminder")]
#		);
#	$tabform->getTab("security")->group(
#		-name=>"groupNotify", -label=>WebGUI::International::get(535,"EventsCalendar"),
#		-value=>[$self->getValue("regNotifyGroupId")]
#		);
	return $tabform;
}



#-------------------------------------------------------------------
sub getIcon {
	my $self = shift;
	my $small = shift;
	return $session{config}{extrasURL}.'/assets/small/calendar.gif' if ($small);
	return $session{config}{extrasURL}.'/assets/calendar.gif';
}


#-------------------------------------------------------------------
sub getName {
        return WebGUI::International::get(511,"EventsCalendar");
}


#-------------------------------------------------------------------
sub processPropertiesFromFormPost {
	my $self = shift;
	$self->SUPER::processPropertiesFromFormPost;
	if ($session{form}{assetId} eq "new") {
		$self->update({eventEndDate=>$self->get("eventStartDate")}) unless ($self->get("eventEndDate") >= $self->get("eventStartDate"));
		if ($session{form}{recursEvery} ne "never") {
			my $until = WebGUI::DateTime::setToEpoch($session{form}{until});
			$until = $self->get("eventEndDate") unless ($until >= $self->get("eventEndDate"));
			my $interval = ($session{form}{interval} < 1) ? 1 : $session{form}{interval};
			my $recurringEventId = WebGUI::Id::generate();
			$self->update({EventsCalendar_recurringId=>$recurringEventId});
			my $start = $self->get("eventStartDate");
			my $end = $self->get("eventEndDate");
			my $i = 0;
			while ($start < $until) {
				$i++;
				if ($session{form}{recursEvery} eq "day") {
					$start = WebGUI::DateTime::addToDate($self->get("eventStartDate"),0,0,($i*$interval));
					$end = WebGUI::DateTime::addToDate($self->get("eventEndDate"),0,0,($i*$interval));
				} elsif ($session{form}{recursEvery} eq "week") {
					$start = WebGUI::DateTime::addToDate($self->get("eventStartDate"),0,0,(7*$i*$interval));
					$end = WebGUI::DateTime::addToDate($self->get("eventEndDate"),0,0,(7*$i*$interval));
				} elsif ($session{form}{recursEvery} eq "month") {
					$start = WebGUI::DateTime::addToDate($self->get("eventStartDate"),0,($i*$interval),0);
					$end = WebGUI::DateTime::addToDate($self->get("eventEndDate"),0,($i*$interval),0);
				} elsif ($session{form}{recursEvery} eq "year") {
					$start = WebGUI::DateTime::addToDate($self->get("eventStartDate"),($i*$interval),0,0);
					$end = WebGUI::DateTime::addToDate($self->get("eventEndDate"),($i*$interval),0,0);
				}
				my $newEvent = $self->getParent->duplicate($self);
				$newEvent->update({
					eventStartDate=>$start,
					eventEndDate=>$end
					});
			}
		}
	}
}


#-------------------------------------------------------------------
sub view {
	my $self = shift;
	return WebGUI::Privilege::noAccess() unless $self->canView;
		$self->logView() if ($session{setting}{passiveProfilingEnabled});
	my ($output, $event, %var, $id);
	$event = $self;
	$var{title} = $event->getValue("title");
	$var{"start.label"} =  WebGUI::International::get(14,"EventsCalendar");
	$var{"start.date"} = epochToHuman($self->getValue("eventStartDate"),"%z");
	$var{"start.time"} = epochToHuman($self->getValue("eventStartDate"),"%Z");
	$var{"end.label"} = WebGUI::International::get(15,"EventsCalendar");
	$var{"end.date"} = epochToHuman($self->getValue("eventEndDate"),"%z");
	$var{"end.time"} = epochToHuman($self->getValue("eventEndDate"),"%Z");
	$var{canEdit} = $self->canEdit;
	$var{"edit.url"} = WebGUI::URL::page('func=edit');
	$var{"edit.label"} = WebGUI::International::get(575,"EventsCalendar");
	$var{"delete.url"} = WebGUI::URL::page('func=deleteEvent&rid='.$self->getValue("EventsCalendar_recurringId"));
	$var{"delete.label"} = WebGUI::International::get(576,"EventsCalendar");
#	my $query = "select EventsCalendar_eventId from EventsCalendar_event where EventsCalendar_eventId<>".quote($event->getValue("EventsCalendar_eventId});
#	$query .= " and wobjectId=".quote($self->get("wobjectId")) unless ($self->get("isMaster"));
#	$query .= " and startDate<=$event->getValue("startDate} order by startDate desc, endDate desc";
#	($id) = WebGUI::SQL->quickArray($query,WebGUI::SQL->getSlave);
#	$var{"previous.label"} = '&laquo;'.WebGUI::International::get(92,"EventsCalendar");
#	$var{"previous.url"} = WebGUI::URL::page("func=viewEvent&wid=".$self->get("wobjectId")."&eid=".$id) if ($id);
#	$query = "select EventsCalendar_eventId from EventsCalendar_event where EventsCalendar_eventId<>".quote($event->getValue("EventsCalendar_eventId});
#	$query .= " and wobjectId=".quote($self->get("wobjectId")) unless ($self->get("isMaster"));
#	$query .= " and startDate>=$event->getValue("eventStartDate") order by startDate, endDate";
#        ($id) = WebGUI::SQL->quickArray($query,WebGUI::SQL->getSlave);
#        $var{"next.label"} = WebGUI::International::get(93,"EventsCalendar").'&raquo;';
#        $var{"next.url"} = WebGUI::URL::page("func=viewEvent&wid=".$self->get("wobjectId")."&eid=".$id) if ($id);
	$var{description} = $event->getValue("description");
#	my $where = "eventscalendar.type=2";
#	my $kiddos = $self->getLineage(["children"],{returnObjects=>1,joinClass=>"WebGUI::Asset::Wobject::EventsCalendar",whereClause=>$where});
#	my $tabform = WebGUI::TabForm->new();
#	#let's try to create a template variable that is a tabform of agendas.
#	foreach my $agenda (@{$kiddos}) {
#		$tabform->addTab($agenda->getId,$agenda->getValue("title"));
#		#These will be in order of lineage.  Use the Asset Manager to change the order.
#		$tabform->getTab($agenda->getId)->raw($agenda->WebGUI::Asset::Wobject::EventsCalendar::view);
#	}
#	$var{agendas} = $tabform->print;
	my $vars = \%var;
	#get parent so we can get the parent's style.  Hopefully the parent is an EventsCalendar.  If not, oh well.
	my $parent = $self->getParent;
	return WebGUI::Style::process($self->processTemplate($vars,$self->getValue("templateId")),$parent->getValue("styleTemplateId"));
}


#-------------------------------------------------------------------
sub www_deleteEvent {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless ($self->canEdit);
	my ($output);
	$output = '<h1>'.WebGUI::International::get(42,"EventsCalendar").'</h1>';
	$output .= WebGUI::International::get(75,"EventsCalendar").'<p><blockquote>';
	$output .= '<a href="'.WebGUI::URL::page('func=deleteEventConfirm').'">'.WebGUI::International::get(76,"EventsCalendar").'</a><p>';
	$output .= '<a href="'.WebGUI::URL::page('func=deleteEventConfirm&rid='.$session{form}{rid}).'">'
		.WebGUI::International::get(77,"EventsCalendar").'</a><p>' if (($session{form}{rid} ne "") and ($session{form}{rid} ne "0"));
	$output .= '<a href="'.$self->getUrl.'">'.WebGUI::International::get(78,"EventsCalendar").'</a>';
	$output .= '</blockquote>';
	return return WebGUI::Style::process($output,$self->getParent->getValue("styleTemplateId"));
}


#-------------------------------------------------------------------
sub www_deleteEventConfirm {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless ($self->canEdit);
	if (($session{form}{rid} ne "") and ($session{form}{rid} ne "0")) {
		my $where = "EventsCalendar_event.EventsCalendar_recurringId=".quote($session{form}{rid});
		my $series = $self->getParent->getLineage(["descendants"],{returnObjects=>1, 
		joinClass=>"WebGUI::Asset::Event",whereClause=>$where});
		foreach my $trashedEvent (@{$series}) {
			$trashedEvent->trash;
		}
	} else {
		$self->trash;
	}
	return $self->getParent->getContainer->www_view;;
}


#-------------------------------------------------------------------
sub www_edit {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	$self->getAdminConsole->setHelp("event add/edit");
	return $self->getAdminConsole->render($self->getEditForm->print,WebGUI::International::get('13', 'EventsCalendar'));
}




#-------------------------------------------------------------------
#sub www_editStyled {
#	my $self = shift;
#	#get parent so we can get the parent's style.  Hopefully the parent is a wobject.  If not, oh well.
#	my $parent = WebGUI::Asset->newByDynamicClass($self->get("parentId"));
#	return WebGUI::Privilege::noAccess() unless (($parent->getValue("className") eq "WebGUI::Asset::Wobject::EventsCalendar") && #($parent->canEdit));
#	return WebGUI::Style::process($self->getEditForm->print,$parent->getValue("styleTemplateId"));
#}

1;

