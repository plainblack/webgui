package WebGUI::Asset::Event;

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
	my $i18n = WebGUI::International->new($self->session,"Asset_Event");
  push(@{$definition}, {
	assetName=>$i18n->get('assetName'),
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
				defaultValue=$self->session->datetime->time()
			},
			eventEndDate => {
				fieldType=>"dateTime",
				defaultValue=$self->session->datetime->time()
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
	my $i18n = WebGUI::International->new($self->session,"Asset_Event");
	$tabform->getTab("properties")->HTMLArea(
		-name=>"description",
                -label=>$i18n->get(512),
                -hoverHelp=>$i18n->get('Description description'),
		-value=>$self->getValue("description")
		);
	$tabform->getTab("properties")->dateTime(
		-name=>"eventStartDate",
                -label=>$i18n->get(513),
                -hoverHelp=>$i18n->get('Start Date description'),
		-extras=>'onBlur="this.form.eventEndDate.value=this.form.eventStartDate.value;this.form.until.value=this.form.eventStartDate.value;"',
		-value=>$self->getValue("eventStartDate")
		);
	$tabform->getTab("properties")->dateTime(
		-name=>"eventEndDate",
                -label=>$i18n->get(514),
                -hoverHelp=>$i18n->get('End Date description'),
		-extras=>'onBlur="this.form.until.value=this.form.eventEndDate.value;"',
		-value=>$self->getValue("eventEndDate")
		);
	$tabform->getTab("properties")->text(
		-name=>"eventLocation",
                -label=>$i18n->get(515),
                -hoverHelp=>$i18n->get('515 description'),
		-value=>$self->getValue("eventLocation")
		);
	if ($self->session->form->process("func") eq "add") {
		my %recursEvery;
		tie %recursEvery, 'Tie::IxHash';
		%recursEvery = (
			'never'=>$i18n->get(4),
			'day'=>$i18n->get(700),
			'week'=>$i18n->get(701),
			'month'=>$i18n->get(702),
			'year'=>$i18n->get(703),
		);
		$tabform->getTab("properties")->readOnly(
			-label=>$i18n->get(8),
			-hoverHelp=>$i18n->get('Recurs every description'),
			-value=>WebGUI::Form::integer({
				name=>"interval",
				defaultValue=>1
				})
				.WebGUI::Form::selectBox({
					name=>"recursEvery",
					options=>\%recursEvery
					})
				.' '.$i18n->get(9).' '
				.WebGUI::Form::date({
					name=>"until"
					})
			);
	}
	$tabform->getTab("display")->template(
    -name=>"templateId",
    -value=>$self->getValue("templateId"),
    -namespace=>"EventsCalendar/Event",
    -label=>$i18n->get(530),
    -hoverHelp=>$i18n->get('530 description'),
    );
	return $tabform;
}




#-------------------------------------------------------------------
sub processPropertiesFromFormPost {
	my $self = shift;
	$self->SUPER::processPropertiesFromFormPost;
	if ($self->session->form->process("assetId") eq "new") {
		$self->update({eventEndDate=>$self->get("eventStartDate")}) unless ($self->get("eventEndDate") >= $self->get("eventStartDate"));
		if ($self->session->form->process("recursEvery") && $self->session->form->process("recursEvery") ne "never") {
			my $until = $self->session->datetime->setToEpoch($self->session->form->process("until"));
			$until = $self->get("eventEndDate") unless ($until >= $self->get("eventEndDate"));
			my $interval = ($self->session->form->process("interval") < 1) ? 1 : $self->session->form->process("interval");
			my $recurringEventId = $self->session->id->generate();
			$self->update({EventsCalendar_recurringId=>$recurringEventId});
			my $start = $self->get("eventStartDate");
			my $end = $self->get("eventEndDate");
			my $i = 0;
			while ($start < $until) {
				$i++;
				if ($self->session->form->process("recursEvery") eq "day") {
					$start = $self->session->datetime->addToDate($self->get("eventStartDate"),0,0,($i*$interval));
					$end = $self->session->datetime->addToDate($self->get("eventEndDate"),0,0,($i*$interval));
				} elsif ($self->session->form->process("recursEvery") eq "week") {
					$start = $self->session->datetime->addToDate($self->get("eventStartDate"),0,0,(7*$i*$interval));
					$end = $self->session->datetime->addToDate($self->get("eventEndDate"),0,0,(7*$i*$interval));
				} elsif ($self->session->form->process("recursEvery") eq "month") {
					$start = $self->session->datetime->addToDate($self->get("eventStartDate"),0,($i*$interval),0);
					$end = $self->session->datetime->addToDate($self->get("eventEndDate"),0,($i*$interval),0);
				} elsif ($self->session->form->process("recursEvery") eq "year") {
					$start = $self->session->datetime->addToDate($self->get("eventStartDate"),($i*$interval),0,0);
					$end = $self->session->datetime->addToDate($self->get("eventEndDate"),($i*$interval),0,0);
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
	my $i18n = WebGUI::International->new($self->session,"Asset_Event");
	$event = $self;
	$var{title} = $event->getValue("title");
	$var{"start.label"} =  $i18n->get(14);
	$var{"start.date"} =$self->session->datetime->epochToHuman($self->getValue("eventStartDate"),"%z");
	$var{"start.time"} =$self->session->datetime->epochToHuman($self->getValue("eventStartDate"),"%Z");
	$var{"end.label"} = $i18n->get(15);
	$var{"end.date"} =$self->session->datetime->epochToHuman($self->getValue("eventEndDate"),"%z");
	$var{"end.time"} =$self->session->datetime->epochToHuman($self->getValue("eventEndDate"),"%Z");
	$var{canEdit} = $self->canEdit;
	$var{"edit.url"} = $self->session->url->page('func=edit');
	$var{"edit.label"} = $i18n->get(575);
	$var{"delete.url"} = $self->session->url->page('func=deleteEvent;rid='.$self->getValue("EventsCalendar_recurringId"));
	$var{"delete.label"} = $i18n->get(576);
	my @others;
	my ($start, $garbage) = $self->session->datetime->dayStartEnd($self->get("eventStartDate"));
	my ($garbage, $end) = $self->session->datetime->dayStartEnd($self->get("eventEndDate"));
	my $sth = $self->session->db->read("select assetId from EventsCalendar_event where ((eventStartDate >= $start and eventStartDate <= $end) or (eventEndDate >= $start and eventEndDate <= $end)) and assetId<>".$self->session->db->quote($self->getId));
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
	return $self->session->privilege->insufficient() unless ($self->canEdit);
	my $i18n = WebGUI::International->new($self->session,"Asset_Event");
	my ($output);
	$output = '<h1>'.$i18n->get(42).'</h1>';
	$output .= $i18n->get(75).'<p><blockquote>';
	$output .= '<a href="'.$self->session->url->page('func=deleteEventConfirm').'">'.$i18n->get(76).'</a><p>';
	$output .= '<a href="'.$self->session->url->page('func=deleteEventConfirm;rid='.$self->session->form->process("rid")).'">'
		.$i18n->get(77).'</a><p>' if (($self->session->form->process("rid") ne "") and ($self->session->form->process("rid") ne "0"));
	$output .= '<a href="'.$self->getUrl.'">'.$i18n->get(78).'</a>';
	$output .= '</blockquote>';
	return $self->session->style->process($output,$self->getParent->getValue("styleTemplateId"));
}


#-------------------------------------------------------------------
sub www_deleteEventConfirm {
	my $self = shift;
	return $self->session->privilege->insufficient() unless ($self->canEdit);
	if (($self->session->form->process("rid") ne "") and ($self->session->form->process("rid") ne "0")) {
		my $series = $self->getParent->getLineage(["descendants"],{returnObjects=>1});
		foreach my $event (@{$series}) {
			$event->trash if $event->get("EventsCalendar_recurringId") eq $self->session->form->process("rid");
		}
	} else {
		$self->trash;
	}
	return $self->getParent->getContainer->www_view;;
}


#-------------------------------------------------------------------
sub www_edit {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	$self->getAdminConsole->setHelp("event add/edit","Asset_Event");
	my $i18n = WebGUI::International->new($self->session,"Asset_Event");
	return $self->getAdminConsole->render($self->getEditForm->print,$i18n->get('13'));
}

#-------------------------------------------------------------------
sub www_view {
	my $self = shift;
	return $self->session->privilege->insufficient() unless ($self->canView);
	return $self->session->style->process($self->view,$self->getParent->getValue("styleTemplateId"));
}


1;

