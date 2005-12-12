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
use WebGUI::HTML;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::Id;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Style;
use WebGUI::URL;
use WebGUI::Asset;

our @ISA = qw(WebGUI::Asset);


#-------------------------------------------------------------------
sub definition {
	my $class = shift;
  my $definition = shift;
  push(@{$definition}, {
	assetName=>WebGUI::International::get('assetName',"Asset_Event"),
	icon=>'calendar.gif',
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
			templateId => {
				fieldType=>"template",
				defaultValue=>'PBtmpl0000000000000023'
			}
		}
	});
	return $class->SUPER::definition($definition);
}

#-------------------------------------------------------------------
sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm();
	$tabform->getTab("properties")->HTMLArea(
		-name=>"description",
                -label=>WebGUI::International::get(512,"Asset_Event"),
                -hoverHelp=>WebGUI::International::get('Description description',"Asset_Event"),
		-value=>$self->getValue("description")
		);
	$tabform->getTab("properties")->dateTime(
		-name=>"eventStartDate",
                -label=>WebGUI::International::get(513,"Asset_Event"),
                -hoverHelp=>WebGUI::International::get('Start Date description',"Asset_Event"),
		-extras=>'onBlur="this.form.eventEndDate.value=this.form.eventStartDate.value;this.form.until.value=this.form.eventStartDate.value;"',
		-value=>$self->getValue("eventStartDate")
		);
	$tabform->getTab("properties")->dateTime(
		-name=>"eventEndDate",
                -label=>WebGUI::International::get(514,"Asset_Event"),
                -hoverHelp=>WebGUI::International::get('End Date description',"Asset_Event"),
		-extras=>'onBlur="this.form.until.value=this.form.eventEndDate.value;"',
		-value=>$self->getValue("eventEndDate")
		);
	$tabform->getTab("properties")->text(
		-name=>"eventLocation",
                -label=>WebGUI::International::get(515,"Asset_Event"),
                -hoverHelp=>WebGUI::International::get('515 description',"Asset_Event"),
		-value=>$self->getValue("eventLocation")
		);
	if ($session{form}{func} eq "add") {
		my %recursEvery;
		tie %recursEvery, 'Tie::IxHash';
		%recursEvery = (
			'never'=>WebGUI::International::get(4,"Asset_Event"),
			'day'=>WebGUI::International::get(700,"Asset_Event"),
			'week'=>WebGUI::International::get(701,"Asset_Event"),
			'month'=>WebGUI::International::get(702,"Asset_Event"),
			'year'=>WebGUI::International::get(703,"Asset_Event"),
		);
		$tabform->getTab("properties")->readOnly(
			-label=>WebGUI::International::get(8,"Asset_Event"),
			-hoverHelp=>WebGUI::International::get('Recurs every description',"Asset_Event"),
			-value=>WebGUI::Form::integer({
				name=>"interval",
				defaultValue=>1
				})
				.WebGUI::Form::selectBox({
					name=>"recursEvery",
					options=>\%recursEvery
					})
				.' '.WebGUI::International::get(9,"Asset_Event").' '
				.WebGUI::Form::date({
					name=>"until"
					})
			);
	}
	$tabform->getTab("display")->template(
    -name=>"templateId",
    -value=>$self->getValue("templateId"),
    -namespace=>"EventsCalendar/Event",
    -label=>WebGUI::International::get(530,"Asset_Event"),
    -hoverHelp=>WebGUI::International::get('530 description',"Asset_Event"),
    );
	return $tabform;
}




#-------------------------------------------------------------------
sub processPropertiesFromFormPost {
	my $self = shift;
	$self->SUPER::processPropertiesFromFormPost;
	if ($session{form}{assetId} eq "new") {
		$self->update({eventEndDate=>$self->get("eventStartDate")}) unless ($self->get("eventEndDate") >= $self->get("eventStartDate"));
		if ($session{form}{recursEvery} && $session{form}{recursEvery} ne "never") {
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

=head2 setParent ( newParent ) 

We're overloading the setParent in Asset because we don't want events to be able to be posted to anything other than the events calendar.

=head3 newParent

An asset object to make the parent of this asset.

=cut

sub setParent {
        my $self = shift;
        my $newParent = shift;
        return 0 unless ($newParent->get("className") eq "WebGUI::Asset::Wobject::EventsCalendar");
        return $self->SUPER::setParent($newParent);
}

#-------------------------------------------------------------------
sub view {
	my $self = shift;
	my ($output, $event, $id);
	my %var = $self->get;
	$event = $self;
	$var{title} = $event->getValue("title");
	$var{"start.label"} =  WebGUI::International::get(14,"Asset_Event");
	$var{"start.date"} = epochToHuman($self->getValue("eventStartDate"),"%z");
	$var{"start.time"} = epochToHuman($self->getValue("eventStartDate"),"%Z");
	$var{"end.label"} = WebGUI::International::get(15,"Asset_Event");
	$var{"end.date"} = epochToHuman($self->getValue("eventEndDate"),"%z");
	$var{"end.time"} = epochToHuman($self->getValue("eventEndDate"),"%Z");
	$var{canEdit} = $self->canEdit;
	$var{"edit.url"} = WebGUI::URL::page('func=edit');
	$var{"edit.label"} = WebGUI::International::get(575,"Asset_Event");
	$var{"delete.url"} = WebGUI::URL::page('func=deleteEvent;rid='.$self->getValue("EventsCalendar_recurringId"));
	$var{"delete.label"} = WebGUI::International::get(576,"Asset_Event");
	my @others;
	my ($start, $garbage) = WebGUI::DateTime::dayStartEnd($self->get("eventStartDate"));
	my ($garbage, $end) = WebGUI::DateTime::dayStartEnd($self->get("eventEndDate"));
	my $sth = WebGUI::SQL->read("select assetId from EventsCalendar_event where ((eventStartDate >= $start and eventStartDate <= $end) or (eventEndDate >= $start and eventEndDate <= $end)) and assetId<>".quote($self->getId));
	while (my ($assetId) = $sth->array) {
		my $asset = WebGUI::Asset::Event->new($assetId);
		# deal with multiple versions of the same event with conflicting dates
		next unless (($asset->get("eventStartDate") >= $start && $asset->get("eventStartDate") <= $end) || ($asset->get("eventEndDate") >= $start && $asset->get("eventEndDate") <= $end));
		push(@others,{
			url=>$asset->getUrl,
			title=>$asset->getTitle,
			});
	}
	$var{others_loop} = \@others;
	return $self->processTemplate(\%var,$self->getValue("templateId"));
}


#-------------------------------------------------------------------
sub www_deleteEvent {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless ($self->canEdit);
	my ($output);
	$output = '<h1>'.WebGUI::International::get(42,"Asset_Event").'</h1>';
	$output .= WebGUI::International::get(75,"Asset_Event").'<p><blockquote>';
	$output .= '<a href="'.WebGUI::URL::page('func=deleteEventConfirm').'">'.WebGUI::International::get(76,"Asset_Event").'</a><p>';
	$output .= '<a href="'.WebGUI::URL::page('func=deleteEventConfirm;rid='.$session{form}{rid}).'">'
		.WebGUI::International::get(77,"Asset_Event").'</a><p>' if (($session{form}{rid} ne "") and ($session{form}{rid} ne "0"));
	$output .= '<a href="'.$self->getUrl.'">'.WebGUI::International::get(78,"Asset_Event").'</a>';
	$output .= '</blockquote>';
	return WebGUI::Style::process($output,$self->getParent->getValue("styleTemplateId"));
}


#-------------------------------------------------------------------
sub www_deleteEventConfirm {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless ($self->canEdit);
	if (($session{form}{rid} ne "") and ($session{form}{rid} ne "0")) {
		my $series = $self->getParent->getLineage(["descendants"],{returnObjects=>1});
		foreach my $event (@{$series}) {
			$event->trash if $trashedEvent->get("EventsCalendar_recurringId") eq $session{form}{rid};
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
	$self->getAdminConsole->setHelp("event add/edit","Asset_Event");
	return $self->getAdminConsole->render($self->getEditForm->print,WebGUI::International::get('13', 'Asset_Event'));
}

#-------------------------------------------------------------------
sub www_view {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless ($self->canView);
	return WebGUI::Style::process($self->view,$self->getParent->getValue("styleTemplateId"));
}


1;

