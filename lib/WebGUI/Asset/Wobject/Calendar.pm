package WebGUI::Asset::Wobject::Calendar;

$VERSION = "0.0.0";

####################################################################
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
####################################################################
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
####################################################################
# http://www.plainblack.com                     info@plainblack.com
####################################################################

use strict;

use Tie::IxHash;

use WebGUI::Utility;
use WebGUI::International;
use WebGUI::Search;
use WebGUI::Form;
use WebGUI::HTML;
use WebGUI::DateTime;

use base 'WebGUI::Asset::Wobject';

use DateTime;
use JSON;

=head1 Name


=head1 Description


=head1 Synopsis


=head1 Methods


=cut

####################################################################

sub definition {
    my $class       = shift;
    my $session     = shift;
    my $definition  = shift || [];
    
    my $i18n        = WebGUI::International->new($session, 'Asset_Calendar');
    
    ### Set up list options ###
    tie (my %optionsDefaultView, 'Tie::IxHash',
        month   => $i18n->get("defaultView value month"),
        week    => $i18n->get("defaultView value week"),
        day     => $i18n->get("defaultView value day"),
    );
    tie (my %optionsDefaultDate, 'Tie::IxHash', 
        current => $i18n->get("defaultDate value current"),
        first   => $i18n->get("defaultDate value first"),
        last    => $i18n->get("defaultDate value last"),
    );
    
    
    
    ### Build properties hash ###
    tie my %properties, 'Tie::IxHash';
    %properties = (
        
        ##### DEFAULTS #####
        defaultView => {
            fieldType       => "SelectBox",
            defaultValue    => "month",
            options         => \%optionsDefaultView,
            tab             => "display",
            label           => $i18n->get("defaultView label"),
            hoverHelp       => $i18n->get("defaultView description"),
        },
        
        defaultDate => {
            fieldType       => "SelectBox",
            defaultValue    => 'current',
            options         => \%optionsDefaultDate,
            tab             => "display",
            label           => $i18n->get("defaultDate label"),
            hoverHelp       => $i18n->get("defaultDate description"),
        },
        
        ##### GROUPS / ACCESS #####
        # Edit events
        groupIdEventEdit => {
            fieldType       => "group",
            defaultValue    => "3",
            tab             => "security",
            label           => $i18n->get("groupIdEventEdit label"),
            hoverHelp       => $i18n->get("groupIdEventEdit description"),
        },
        groupIdSubscribed => {
            fieldType       => 'hidden',
        },
        
        
        ##### TEMPLATES - DISPLAY #####
        # Month
        templateIdMonth => {
            fieldType       => "template",  
            defaultValue    => 'CalendarMonth000000001',
            tab             => "display",
            namespace       => "Calendar/Month", 
            hoverHelp       => $i18n->get('templateIdMonth description'),
            label           => $i18n->get('templateIdMonth label'),
        },
        
        # Week
        templateIdWeek => {
            fieldType       => "template",  
            defaultValue    => 'CalendarWeek0000000001',
            tab             => "display",
            namespace       => "Calendar/Week", 
            hoverHelp       => $i18n->get('templateIdWeek description'),
            label           => $i18n->get('templateIdWeek label'),
        },
        
        # Day
        templateIdDay => {
            fieldType       => "template",  
            defaultValue    => 'CalendarDay00000000001',
            tab             => "display",
            namespace       => "Calendar/Day", 
            hoverHelp       => $i18n->get('templateIdDay description'),
            label           => $i18n->get('templateIdDay label'),
        },
        
        # Event Details
        templateIdEvent => {
            fieldType       => "template",  
            defaultValue    => 'CalendarEvent000000001',
            tab             => "display",
            namespace       => "Calendar/Event", 
            hoverHelp       => $i18n->get('templateIdEvent description'),
            label           => $i18n->get('templateIdEvent label'),
        },
        
        # Event Edit
        templateIdEventEdit => {
            fieldType       => "template",  
            defaultValue    => 'CalendarEventEdit00001',
            tab             => "display",
            namespace       => "Calendar/EventEdit", 
            hoverHelp       => $i18n->get('templateIdEventEdit description'),
            label           => $i18n->get('templateIdEventEdit label'),
        },
        
        # Search
        templateIdSearch => {
            fieldType       => "template",  
            defaultValue    => 'CalendarSearch00000001',
            tab             => "display",
            namespace       => "Calendar/Search", 
            hoverHelp       => $i18n->get('templateIdSearch description'),
            label           => $i18n->get('templateIdSearch label'),
        },
        
        
        ##### TEMPLATES - PRINT #####
        # Month
        templateIdPrintMonth => {
            fieldType       => "template",  
            defaultValue    => 'CalendarPrintMonth0001',
            tab             => "display",
            namespace       => "Calendar/Print/Month", 
            hoverHelp       => $i18n->get('templateIdPrintMonth description'),
            label           => $i18n->get('templateIdPrintMonth label'),
        },
        
        # Week
        templateIdPrintWeek => {
            fieldType       => "template",  
            defaultValue    => 'CalendarPrintWeek00001',
            tab             => "display",
            namespace       => "Calendar/Print/Week", 
            hoverHelp       => $i18n->get('templateIdPrintWeek description'),
            label           => $i18n->get('templateIdPrintWeek label'),
        },
        
        # Day
        templateIdPrintDay => {
            fieldType       => "template",  
            defaultValue    => 'CalendarPrintDay000001',
            tab             => "display",
            namespace       => "Calendar/Print/Day", 
            hoverHelp       => $i18n->get('templateIdPrintDay description'),
            label           => $i18n->get('templateIdPrintDay label'),
        },
        
        # Event Details
        templateIdPrintEvent => {
            fieldType       => "template",  
            defaultValue    => 'CalendarPrintEvent0001',
            tab             => "display",
            namespace       => "Calendar/Print/Event", 
            hoverHelp       => $i18n->get('templateIdPrintEvent description'),
            label           => $i18n->get('templateIdPrintEvent label'),
        },
        
        
        ##### Miscellany #####
        visitorCacheTimeout => {
            fieldType       => "integer",
            defaultValue    => "60",
            tab             => "display",
            hoverHelp       => $i18n->get('visitorCacheTimeout description'),
            label           => $i18n->get('visitorCacheTimeout label'),
        },
        
        subscriberNotifyOffset => {
            fieldType       => "integer",
            defaultValue    => "2",
            tab             => "properties",
            hoverHelp       => $i18n->get('subscriberNotifyOffset description'),
            label           => $i18n->get('subscriberNotifyOffset label'),
        },    
    );
    
    push(@{$definition}, {
        assetName           => $i18n->get('assetName'),
        icon                => 'calendar.gif',
        tableName           => 'Calendar',
        className           => 'WebGUI::Asset::Wobject::Calendar',
        properties          => \%properties,
        autoGenerateForms   => 1,
    });
    
    return $class->SUPER::definition($session, $definition);
}






####################################################################

=head2 addChild ( properties [, more ] )

Only allows Events to be added as a child of this asset.

=cut

sub addChild {
    my $self        = shift;
    my $properties  = shift;
    my @other       = @_;
    
    if ($properties->{className} ne "WebGUI::Asset::Event") {
        $self->session->errorHandler->security("add a ".$properties->{className}." to a ".$self->get("className"));
        return undef;
    }

    return $self->SUPER::addChild($properties, @other);
}





####################################################################

=head2 canEdit

Returns true if the user can edit this asset.

Also returns true if the user is adding an Event and is allowed to do so (to get
around the canEdit check when www_editSave is being used to add an asset).

=cut

sub canEdit {
    my $self    = shift;
    my $form    = $self->session->form;
    my $user    = $self->session->user;
    
    # Account for new events
    return 1 if ($self->canAddEvent && $form->process("func") eq "add");
    return 1 if (
        $self->canAddEvent 
        && $form->process("assetId")    eq "new"
        && $form->process("func")       eq "editSave"
        && $form->process("class")      eq "WebGUI::Asset::Event"
    );

    return $self->SUPER::canEdit()
}




####################################################################

=head2 canAddEvent

Returns true if able to add events. Checks to make sure that the 
Calendar has been committed at least once. Checks to make sure that
the user is in the appropriate group (either the group that can edit
the calendar, or the group that can edit events in the calendar).

=cut

sub canAddEvent {
    my $self    = shift;
    
    # Events can only be added after the Calendar has been committed once
    return 0 if (
        $self->get("status") ne "approved"
        && $self->getTagCount <= 1
    );
            
    return 1 if (        
        $self->session->user->isInGroup($self->get("groupIdEventEdit")) 
        || $self->SUPER::canEdit
    );
}




####################################################################

=head2 createSubscriptionGroup ( )

Creates the group for users that are subscribed to the Calendar.

=cut

# Copied from WebGUI::Asset::Wobject::Collaboration.
sub createSubscriptionGroup {
    my $self    = shift;
    
    my $group   = WebGUI::Group->new($self->session, "new");
    $group->name($self->getId);
    $group->description("The group to store subscriptions for the calendar ".$self->getId);
    $group->isEditable(0);
    $group->showInForms(0);
    $group->deleteGroups([3]); # admins don't want to be auto subscribed to this thing
    
    $self->update({
        groupIdSubscription => $group->getId
    });

    return;
}





####################################################################

=head2 duplicate ( )

Duplicates an Event Calendar. Duplicates all the events in this Event Calendar.

=cut

sub duplicate {
    my $self        = shift;
    
    # Superclass duplicates the calendar
    my $newCalendar = $self->SUPER::duplicate(@_);
    
    # Duplicate the events in this calendar
    my @events = $self->getLineage(["descendents"], {
            returnObjects       => 1,
            includeOnlyClasses  => ['WebGUI::Asset::Event'],
        });
    
    for my $event (@events) {
        my %eventProperties = %{ $event->get() };
        $newCalendar->addChild(\%eventProperties);
    }
    
    return $newCalendar;
}





####################################################################

=head2 getEditForm

Adds an additional tab for feeds. 

TODO: Abstract the Javascript enough to export into extras/yui-webgui for use
in other areas.

=cut

sub getEditForm {
    my $self    = shift;
    my $session = $self->session;
    my $form    = $self->SUPER::getEditForm;
    my $i18n    = WebGUI::International->new($session,"Asset_Calendar");
    
    my $tab     = $form->addTab("feeds",$i18n->get("feeds"));
    $tab->raw("<tr><td>");
    
    
    $tab->raw(<<'ENDJS');
    <script type="text/javascript">
    var FeedsManager    = new Object();
    
    FeedsManager.addFeed = function (table,rowId,params) {
        // TODO: Verify that feed URL is valid
        
        
        var table    = document.getElementById(table);
        
        // If id is "new"
        //  Add a number on the end.
        if (rowId == "new")
            rowId = "new" + Math.round(Math.random() * 10000000000000000);
        
        // Create 5 cells
        var cells    = new Array();
        for (var i = 0; i < 5; i++)
            cells[i]    = document.createElement("td");
        
        
        /*** [0] - Delete button */
        var button    = document.createElement("img");
        button.setAttribute("src","/extras/wobject/Calendar/images/delete.gif");
        button.setAttribute("border","0");
        
        var deleteLink    = document.createElement("a");
        deleteLink.setAttribute("href","#");
        deleteLink.setAttribute("onclick","FeedsManager.deleteFeed('feeds','"+rowId+"'); return false;");
        deleteLink.appendChild(button);
        
        cells[0].appendChild(deleteLink);
        
        
        
        /*** [1] - Feed link for teh clicking and form element for teh saving */
        var feedLink    = document.createElement("a");
        feedLink.setAttribute("href",params.url);
        feedLink.setAttribute("target","_new"); // TODO: Use JS to open window. target="" is deprecated
        feedLink.appendChild(document.createTextNode(params.url));
        
        var formElement    = document.createElement("input");
        formElement.setAttribute("type","hidden");
        formElement.setAttribute("name","feeds-"+rowId);
        formElement.setAttribute("value",params.url);
        
        cells[1].appendChild(feedLink);
        cells[1].appendChild(formElement);
        
        
        
        /*** [2] - Result (new) */
        if (params.lastResult == undefined)
            params.lastResult = "new";
        var lastResult    = document.createTextNode(params.lastResult);
        
        cells[2].appendChild(lastResult);
        
        
        
        /*** [3] - Last updated */
        if (params.lastUpdated == undefined)
            params.lastUpdated = "never";
        var lastUpdated    = document.createTextNode(params.lastUpdated);
        
        cells[3].appendChild(lastUpdated);
        
        
        
        /*** [4] - Update now! */
        /* TODO */
        
        
        /* Add the row to the table */
        var row        = document.createElement("tr");
        row.setAttribute("id",rowId);
        for (var i = 0; i < cells.length; i++)
            row.appendChild(cells[i]);
        
        table.appendChild(row);
        FeedsManager.updateFeed(table.getAttribute("id"),rowId);
    }
    
    
    FeedsManager.updateFeed = function (table,rowId) {
        /* TODO */
        
    }
    
    
    FeedsManager.deleteFeed = function (table,rowId) {
        row        = document.getElementById(rowId);
        
        row.parentNode.removeChild(row);
    }
    
    
    FeedsManager.setFeed    = function (table,rowId,params) {
        
        
        
    }
    
    </script>
ENDJS
    
    
    $tab->raw(<<'ENDHTML');
    <label for="addFeed">Add a feed</label>
    <input type="text" size="60" id="addFeed" name="addFeed" value="http://google.com" />
    <input type="button" value="Add" onclick="FeedsManager.addFeed('feeds','new',{ 'url' : this.form.addFeed.value }); this.form.addFeed.value=''" />
    
    <table id="feeds" style="width: 100%;">
    <thead>
        <th style="width: 30px;">&nbsp;</th>
        <th style="width: 50%;">Feed URL</th>
        <th>Status</th>
        <th>Last Updated</th>
        <th>&nbsp;</th>
    </thead>
    </table>
ENDHTML
    
    
    
    # Add the existing feeds
    my $feeds    = $self->getFeeds();
    $tab->raw('<script type="text/javascript">'."\n");
    for my $feedId (keys %$feeds) {
        $tab->raw("FeedsManager.addFeed('feeds','".$feedId."',".objToJson($feeds->{$feedId}).");\n");
    }
    $tab->raw('</script>');
    
    
    $tab->raw("</td></tr>");
    return $form;
}





####################################################################

=head2 getEvent ( assetId )

Gets an Event object from the database. Returns a WebGUI::Asset::Event object
or undef if the event cannot be found, or is otherwise unable to be seen from 
this Calendar.

=cut

sub getEvent {
    my $self    = shift;
    my $assetId = shift;
    # Warn and return if no assetId
    $self->session->errorHandler->warn("WebGUI::Asset::Wobject::Calendar->getEvent :: No asset ID."), return
        unless $assetId;
    
    # ? Perhaps use Stow to cache events ?
    
    my $event = WebGUI::Asset->newByDynamicClass($self->session, $assetId);
    
    $self->session->errorHandler->warn("WebGUI::Asset::Wobject::Calendar->getEvent :: Event '$assetId' not a child of calendar '".$self->getId."'"), return
        unless $event->get("parentId") eq $self->getId;
    
    return $event;
}





####################################################################

=head2 getEventsIn ( startDate, endDate )

Returns a list of Event objects that fall between two dates, ordered by their
start date/time.

If no Events can be found, returns an empty list.

NOTE: This method expects that startDate and endDate are already adjusted for the 
user's time zone.

TODO: Allow WebGUI::DateTime objects to be passed as the parameters.

TODO: Allow for a hashref of options as the third parameter to specify such 
things as a limit clause, or additional where clause, or something.

This is the main API method to get events from a calendar, so it must be flexible.

=cut

sub getEventsIn {
    my $self    = shift;
    my $start   = shift;
    my $end     = shift;
    my $tz      = $self->session->user->profileField("timeZone");
    
    # Warn and return if no startDate or endDate
    unless ($start && $end) {
        $self->session->errorHandler->warn("WebGUI::Asset::Wobject::Calendar->getEventsIn() called with not enough arguments at ".join('::',(caller)[1,2]));
        return;
    }
    
    # Create objects and adjust for timezone
    
    my ($startDate,$startTime)    = split / /, $start;
    my ($endDate,$endTime)        = split / /, $end;
    
    my $startTz  = WebGUI::DateTime->new($self->session, mysql => $start, time_zone => $tz)
                    ->set_time_zone("UTC")->toMysql;
    my $endTz    = WebGUI::DateTime->new($self->session, mysql => $end, time_zone => $tz)
                    ->set_time_zone("UTC")->toMysql;
    
    my $where    
        = qq{ 
                ( 
                    Event.startTime IS NULL 
                    && Event.endTime IS NULL 
                    && Event.startDate >= '$startDate' 
                    && Event.startDate < '$endDate'
                ) 
                || ( 
                    CONCAT(Event.startDate,' ',Event.startTime) >= '$startTz' 
                    && CONCAT(Event.startDate,' ',Event.startTime) < '$endTz'
                )
        };

    my $orderby    
        = join ',',
            'Event.startDate', 
            'Event.startTime', 
            'Event.endDate', 
            'Event.endTime', 
            'assetData.title', 
            'assetData.assetId',
            ;
    
    my $events 
        = $self->getLineage(["descendants"], {
            returnObjects       => 1,
            includeOnlyClasses  => ['WebGUI::Asset::Event'],
            joinClass           => 'WebGUI::Asset::Event',
            orderByClause       => $orderby,
            whereClause         => $where,
        });
    
    #? Perhaps use Stow to cache Events ?#
    
    return @{$events};
}

####################################################################

=head2 getEventVars ( event )

Returns a list of all event template variables to be embedded in
week, month and or day views.

=cut

sub getEventVars {
    my $self    = shift;
    my $event   = shift;
    
    my %eventVar    = %{$event->get};
    %eventVar       = (map { "event".ucfirst($_) => delete $eventVar{$_} } keys %eventVar);
    my %eventDates  = $event->getTemplateVars;
    %eventDates     = (map { "event".ucfirst($_) => delete $eventDates{$_} } keys %eventDates);

    return %eventVar, %eventDates;
}





####################################################################

=head2 getFeeds ( )

Gets a hashref of hashrefs of all the feeds attached to this calendar.

TODO: Format lastUpdated into the user's time zone

=cut

sub getFeeds {
    my $self    = shift;
    
    return $self->session->db->buildHashRefOfHashRefs(
        "select * from Calendar_feeds where assetId=?",
        [$self->get("assetId")],
        "feedId"
        );
}





####################################################################

=head2 getFirstEvent ( )

Gets the first event in this calendar. Returns the Event object.

=cut

sub getFirstEvent {
    my $self        = shift;
    my $lineage     = $self->get("lineage");
    
    my ($assetId)   = $self->session->db->quickArray(<<ENDSQL);
        SELECT asset.assetId 
        FROM asset
        JOIN Event ON asset.assetId = Event.assetId
        WHERE lineage LIKE "$lineage\%"
        AND className = "WebGUI::Asset::Event"
        ORDER BY startDate ASC, startTime ASC, revisionDate DESC
        LIMIT 1
ENDSQL
    
    return $self->getEvent($assetId);
}





####################################################################

=head2 getLastEvent ( )

Gets the last event in this calendar. Returns the Event object.

=cut

sub getLastEvent {
    my $self    = shift;
    my $lineage = $self->get("lineage");
    
    my ($assetId) = $self->session->db->quickArray(<<ENDSQL);
        SELECT asset.assetId 
        FROM asset
        JOIN Event ON asset.assetId = Event.assetId
        WHERE lineage LIKE "$lineage\%"
        AND className = "WebGUI::Asset::Event"
        ORDER BY startDate DESC, startTime DESC, revisionDate DESC
        LIMIT 1
ENDSQL
    
    return $self->getEvent($assetId);
}




####################################################################

=head2 getSearchUrl ( )

Convenience method to be shared with the Event.

=cut

sub getSearchUrl {
    my $self    = shift;
    return $self->getUrl('func=search');
}




####################################################################

=head2 prepareView ( )

Loads the template to be used by the view() method.

Determines which template to load based on the "type" and "print" URL 
parameters.

=cut

sub prepareView {
    my $self = shift;
    $self->SUPER::prepareView();
    
    my $view = ucfirst lc $self->session->form->param("type")
            || ucfirst $self->get("defaultView") 
            || "Month";
    
    if ($self->session->form->param("print")){
        $view = "Print".$view;
        $self->session->style->makePrintable(1);
    }
    
    #$self->session->errorHandler->warn("Prepare view ".$view." with template ".$self->get("templateId".$view));
    
    my $template = WebGUI::Asset::Template->new($self->session, $self->get("templateId".$view));
    $template->prepare;
    
    $self->{_viewTemplate} = $template;
}






####################################################################

=head2 processPropertiesFromFormPost ( )

Process the Calendar Edit form.

Adds a subscription group if none exists.

Adds / removes feeds from the feed trough.

=cut

sub processPropertiesFromFormPost {
    my $self    = shift;
    my $session = $self->session;
    my $form    = $self->session->form;
    $self->SUPER::processPropertiesFromFormPost;
    
    unless ($self->get("groupIdSubscribed")) {
        $self->createSubscriptionGroup();
    }
    
    
    ### Get feeds from the form
    # Workaround WebGUI::Session::Form->param bug that returns duplicate
    # names.
    my %feeds;
    $feeds{$_}++ 
        for map { s/^feeds-//; $_; } grep /^feeds-/,($form->param());
    my @feedsFromForm = keys %feeds;
    
    # Delete old feeds that are not in @feeds
    my @oldFeeds 
        = $session->db->buildArray(
            "select feedId from Calendar_feeds where assetId=?",
            [$self->get("assetId")]
        );

    for my $feedId (@oldFeeds) {
        if (!grep /^$feedId$/, @feedsFromForm) {
            $session->db->write(
                "delete from Calendar_feeds where feedId=? and assetId=?",
                [$feedId,$self->get("assetId")]
            );
        }
    }
    
    # Create new feeds
    for my $feedId (grep /^new(\d+)/, @feedsFromForm) {
        $session->db->setRow("Calendar_feeds","feedId",{
            feedId      => "new",
            assetId     => $self->get("assetId"),
            url         => $form->param("feeds-".$feedId),
            feedType    => "ical",
        });
    }
}




####################################################################

=head2 view ( )

Method called by the www_view method.  

Parses user input for sanity.

Calls the appropriate viewMonth, viewWeek, or viewDay method to get a template,

Returns a processed template to be displayed within the page style.

=cut

sub view {
    my $self    = shift;
    my $session = $self->session;
    my $form    = $session->form;
    my $var;
    
    
    ## INTERRUPT: If user is only a Visitor and we have a cached version 
        # and is not expired, use it.
    
    # Get the form parameters
    my $params        = {};    
    $params->{type}   = $form->param("type");
    $params->{start}  = $form->param("start");
    
    ### TODO: Parse user input for sanity.
    # {start} must be of the form: YYYY-MM-DD%20HH:MM:SS
    # {type} must be "month", "week", or "day"

    # Set defaults if necessary
    if (!$params->{start}) {
        $params->{start}    
            = $self->get("defaultDate") eq "first" && $self->getFirstEvent 
                ? $self->getFirstEvent->getDateTimeStart
            : $self->get("defaultDate") eq "last" && $self->getLastEvent
                ? $self->getLastEvent->getDateTimeStart
            :   WebGUI::DateTime->new($session, time)->toUserTimeZone
            ;
    }
    if (!$params->{type}) {
        $params->{type} = $self->get("defaultView") || "Month";
    }
    
    # Get the template from the appropriate view* method
    $var    = lc $params->{type} eq "month"     ? $self->viewMonth($params)
            : lc $params->{type} eq "week"      ? $self->viewWeek($params)
            : lc $params->{type} eq "day"       ? $self->viewDay($params)
            : return $self->errorHandler->error("Calendar invalid 'type=' url parameter")
            ;
    
    ##### Add any global variables
    # Admin
    if ($self->session->var->isAdminOn) {
        $var->{'admin'}         = 1;
        $var->{'adminControls'} = $self->getToolbar;
    }
    
    # Event editor
    if ($self->canAddEvent) {
        $var->{'editor'}    = 1;
        $var->{"urlAdd"}    = $self->getUrl("func=add;class=WebGUI::Asset::Event;start=$params->{start}");
    }
    
    # URLs
    $var->{"urlDay"}        = $self->getUrl("type=day;start=".$params->{start});
    $var->{"urlWeek"}       = $self->getUrl("type=week;start=".$params->{start});
    $var->{"urlMonth"}      = $self->getUrl("type=month;start=".$params->{start});
    $var->{"urlSearch"}     = $self->getSearchUrl;
    $var->{"urlPrint"}      = $self->getUrl("type=".$params->{type}.";start=".$params->{start}.";print=1");
    
    # Parameters
    $var->{"paramStart"}    = $params->{start};
    $var->{"paramType"}     = $params->{type};
    
    $var->{"extrasUrl"}     = $self->session->url->extras();
    
    ##### Process the template
    # TODO: If user is only a Visitor and we've gotten this far, update the cache
    
    # Return the processed template to be displayed for the user
    return $self->processTemplate($var, undef, $self->{_viewTemplate});
}





####################################################################

=head2 viewDay ( \%params )

Shows the day view. Returns the template parameters as a hash reference.

%params keys:

=over 4

=item start

The day to look at.

=back

=cut

sub viewDay {
    my $self        = shift;
    my $session     = $self->session;
    my $params      = shift;
    my $i18n        = WebGUI::International->new($session,"Asset_Calendar");
    my $var         = {};
    
    ### Get all the events in this time period
    # Get the range of the epoch of this day
    my $dt        = WebGUI::DateTime->new($session, $params->{start});
    $dt->set_locale($i18n->get("locale"));
    $dt->truncate( to => "day");
    
    my @events    = $self->getEventsIn($dt->toMysql,$dt->clone->add(days => 1)->toMysql);
    
    #### Create the template parameters
    # The events
    my $pos        = -1;
    my $last_hour  = -1;        # Keep track of hours for dividers
    for my $event (@events) {
        my $dt      = $event->getDateTimeStart;
        my $hour    = $dt->clone->truncate(to=>"hour")->hour;
        
        # Update position if necessary
        unless ($hour == $last_hour) {
            $pos++;
            $last_hour = $hour;
            # Fill in hour labels
            $var->{hours}->[$pos] = {
                "hour12"    => sprintf("%02d",($hour % 12) || 12),
                "hour24"    => sprintf("%02d",$hour),
                "hourM"     => ( $hour < 12 ? "am" : "pm"),
                };
        }
        
        my $eventVar    = $event->get;
        my %eventDates  = $event->getTemplateVars;
        push @{$var->{hours}->[$pos]->{events}}, {
            # Fill in event stuff, prepend with 'event' to not clobber global vars
            (map { "event".ucfirst($_) => $eventVar->{$_} } keys %$eventVar),
            (map { "event".ucfirst($_) => $eventDates{$_} } keys %eventDates),
            };
    }
    
    
    # Make the navigation bars
    $var->{"pageNextStart"}     = $dt->clone->add(days=>1)->toMysql;
    $var->{"pageNextUrl"}       = $self->getUrl("type=day;start=".$var->{"pageNextStart"});
    $var->{"pagePrevStart"}     = $dt->clone->subtract(days=>1)->toMysql;
    $var->{"pagePrevUrl"}       = $self->getUrl("type=day;start=".$var->{"pagePrevStart"});
    # Some friendly dates
    $var->{"dayName"}           = $dt->day_name;
    $var->{"dayAbbr"}           = $dt->day_abbr;
    $var->{"dayOfMonth"}        = $dt->day_of_month;
    $var->{"dayOfWeek"}         = $dt->day_of_week;
    $var->{"monthName"}         = $dt->month_name;
    $var->{"monthAbbr"}         = $dt->month_abbr;
    $var->{"year"}              = $dt->year;
    $var->{"ymd"}               = $dt->ymd;
    $var->{"mdy"}               = $dt->mdy;
    $var->{"dmy"}               = $dt->dmy;
    $var->{"epoch"}             = $dt->epoch;
    
    
    # Return the template parameters
    return $var;
}






####################################################################

=head2 viewMonth ( \%params )

Prepares the month view. Returns the template parameters as a hash reference.

%params keys:

=over 4

=item start

A day inside the month to look at. Required.

=back

=cut

sub viewMonth {
    my $self        = shift;
    my $session     = $self->session;
    my $params      = shift;
    my $i18n        = WebGUI::International->new($session,"Asset_Calendar");
    my $var         = {};
    my $tz          = $session->user->profileField("timeZone");
    my $today       = WebGUI::DateTime->new($self->session, time)
                    ->set_time_zone($tz)->toMysqlDate;
    
    #### Get all the events in this time period
    # Get the range of the epoch of this month
    my $dt          = WebGUI::DateTime->new($self->session, $params->{start});
    $dt->set_locale($i18n->get("locale"));
    $dt->truncate( to => "month");
    
    my @events      
        = $self->getEventsIn($dt->toMysql,$dt->clone->add(months => 1)->toMysql);
    
    
    #### Create the template parameters
    ## The grid
    my $first_dow     = $session->user->profileField("firstDayOfWeek") || 0;
                # 0 - sunday
                # 1 - mon
                # 2 - tue
                # etc...
    my $days_in_month    = $dt->clone->add(months=>1)->subtract(seconds=>1)->day_of_month;
    # Adjustment for first day of week
    my $adjust    = ( $dt->day_of_week_0 - $first_dow + 1) % 7;
    
    # First create the days that are in this month
    for my $day (0..$days_in_month-1) {
        my $dt_day      = $dt->clone->add(days=>$day);
        
        # Calculate what position this day should be in
        my $week        = int(($adjust + $dt_day->day_of_month_0) / 7);
        my $position    = ($adjust + $dt_day->day_of_month_0) % 7;
        
        # Add the day in the appropriate position
        $var->{weeks}->[$week]->{days}->[$position] = {
            "dayMonth"      => $dt_day->day_of_month,
            "dayUrl"        => $self->getUrl("type=day;start=".$dt_day->toMysql),
            "dayCurrent"    => ($today eq $dt_day->toMysqlDate ? 1 : 0 ),
        };
    }
    
    # Add any remaning trailing empty spaces
    push @{$var->{weeks}->[-1]->{days}},undef 
        until @{$var->{weeks}->[-1]->{days}} >= 7;
    
    ## The events
    for my $event (@events) {
        # Get the WebGUI::DateTime objects
        my $dt_event_start  = $event->getDateTimeStart;
        my $dt_event_end    = $event->getDateTimeEnd;
        
        # Prepare the template variables
        my %eventTemplateVariables = $self->getEventVars($event);

        # Make the event show on each day it spans
        for my $mday ($dt_event_start->day_of_month_0..$dt_event_end->day_of_month_0) {
            my $week        = int(($adjust + $mday) / 7);
            my $position    = ($adjust + $mday) % 7;
            
            push @{$var->{weeks}->[$week]->{days}->[$position]->{events}}, \%eventTemplateVariables;
        }
    }
    
    # Make the navigation bars
    my $dt_year     = $dt->clone->truncate(to => "year");
    for my $m (0..11) {
        my $dt_month = $dt_year->clone->add(months=>$m);
        
        push @{$var->{months}}, {
            "monthName"     => $dt_month->month_name,
            "monthAbbr"     => $dt_month->month_abbr,
            "monthEpoch"    => $dt_month->epoch,
            "monthUrl"      => $self->getUrl("type=month;start=".$dt_month->toMysql),
            "monthCurrent"  => ($dt_month->month eq $dt->month ? 1 : 0),
        };
    }
    
    # Day names
    my @dayNames    = @{$dt->locale->day_names}[6,0..5]; # Put sunday first
    my @dayAbbrs    = @{$dt->locale->day_abbreviations}[6,0..5];
    # Take from FirstDOW to the end and put it on the beginning
    unshift @dayNames,splice(@dayNames,$first_dow);
    unshift @dayAbbrs,splice(@dayAbbrs,$first_dow);
    
    for my $dayIndex (0..$#dayNames) {
        push @{$var->{dayNames}}, {
            "dayName"    => $dayNames[$dayIndex],
            "dayAbbr"    => $dayAbbrs[$dayIndex],
        };
    }
    
    $var->{"pageNextYear"   } = $dt->year + 1;
    $var->{"pageNextUrl"    } = $self->getUrl("type=month;start=" . $dt->clone->add(years=>1)->toMysql);
    $var->{"pagePrevYear"   } = $dt->year - 1;
    $var->{"pagePrevUrl"    } = $self->getUrl("type=month;start=" . $dt->clone->subtract(years=>1)->toMysql);
    $var->{"monthName"      } = $dt->month_name;
    $var->{"monthAbbr"      } = $dt->month_abbr;
    $var->{"year"           } = $dt->year;
    
    # Return the template
    return $var;
}






####################################################################

=head2 viewWeek ( \%params )

Shows the week view. Returns the template parameters as a hash reference.

%params keys:

=over 4

=item start

The day to start this week.

=back

=cut

sub viewWeek {
    my $self    = shift;
    my $session = $self->session;
    my $params  = shift;
    my $i18n    = WebGUI::International->new($session,"Asset_Calendar");
    my $var     = {};
    my $tz      = $session->user->profileField("timeZone");
    my $today   = WebGUI::DateTime->new($self->session, time)->set_time_zone($tz)
                ->toMysqlDate;
    
    
    #### Get all the events in this time period
    # Get the range of the epoch of this week
    my $dt      = WebGUI::DateTime->new($self->session, $params->{start});
    $dt->truncate( to => "day");
    
    # Apply First Day of Week settings
    my $first_dow = $session->user->profileField("firstDayOfWeek") || 0;
                # 0 - sunday
                # 1 - monday 
                # 2 - tuesday, etc...
    # subtract because we want to include the day that was passed
    $dt->subtract(days => $dt->day_of_week % 7 - $first_dow);
    
    my $start   = $dt->toMysql;
    my $dtEnd   = $dt->clone->add(days => 7);
    my $end     = $dtEnd->toMysql; # Clone to prevent saving change
    
    my @events  = $self->getEventsIn($start,$end);
    
    
    #### Create the template parameters
    # Some friendly dates
    for my $i (0..6) {
        my $day     = {};
        my $dt_day  = $dt->clone->add(days=>$i);
        
        $day->{"dayName"    } = $dt_day->day_name;
        $day->{"dayAbbr"    } = $dt_day->day_abbr;
        $day->{"dayOfMonth" } = $dt_day->day_of_month;
        $day->{"dayOfWeek"  } = $dt_day->day_of_week;
        $day->{"monthName"  } = $dt_day->month_name;
        $day->{"monthAbbr"  } = $dt_day->month_abbr;
        $day->{"year"       } = $dt_day->year;
        $day->{"ymd"        } = $dt_day->ymd;
        $day->{"mdy"        } = $dt_day->mdy;
        $day->{"dmy"        } = $dt_day->dmy;
        $day->{"epoch"      } = $dt_day->epoch;
        
        if ($dt_day->toMysqlDate eq $today) {
            $day->{"dayCurrent"} = 1;
        }
        
        push @{$var->{days}}, $day;
    }
    
    # The events
    for my $event (@events) {
        # Get the week this event is in, and add it to that week in
        # the template variables

        my $dt_event_start = $event->getDateTimeStart;
        my $dt_event_end   = $event->getDateTimeEnd;
        $dt_event_start->set_locale($i18n->get("locale"));
        $dt_event_end->set_locale($i18n->get("locale"));

        my %eventTemplateVariables = $self->getEventVars($event);

        foreach my $weekDay ($dt_event_start->day_of_week..$dt_event_end->day_of_week) {
            push @{$var->{days}->[$weekDay]->{events}}, \%eventTemplateVariables;
        }
    }
    
    # Make the navigation bars
    $var->{"pageNextUrl"}        
        = $self->getUrl("type=week;start=" . $dt->clone->add(weeks=>1)->toMysql);
    $var->{"pagePrevUrl"}        
        = $self->getUrl("type=week;start=" . $dt->clone->subtract(weeks=>1)->toMysql);
    
    $var->{"startMonthName"     } = $dt->month_name;
    $var->{"startMonthAbbr"     } = $dt->month_abbr;
    $var->{"startDayOfMonth"    } = $dt->day_of_month;
    $var->{"startDayName"       } = $dt->day_name;
    $var->{"startDayAbbr"       } = $dt->day_abbr;
    $var->{"startYear"          } = $dt->year;
    
    $var->{"endMonthName"       } = $dtEnd->month_name;
    $var->{"endMonthAbbr"       } = $dtEnd->month_abbr;
    $var->{"endDayOfMonth"      } = $dtEnd->day_of_month;
    $var->{"endDayName"         } = $dtEnd->day_name;
    $var->{"endDayAbbr"         } = $dtEnd->day_abbr;
    $var->{"endYear"            } = $dtEnd->year;
    
    
    # Return the template
    return $var;
}





####################################################################

=head2 unwrapIcal ( text )

Unwraps and unescapes an iCalendar string according to RFC 2445, which says that 
lines should be wrapped at 75 characters with a CRLF followed by a space, and 
that ; , \ and newlines should be escaped by prepending them with a \.

=cut

sub unwrapIcal
{
    my $self    = shift;
    my $text    = shift;
    
    
    
}





####################################################################

=head2 wrapIcal ( text )

Wraps and escapes an iCalendar string according to RFC 2445, which says that 
lines should be wrapped at 75 characters with a CRLF followed by a space, and 
that ; , \ and newlines should be escaped by prepending them with a \.

=cut

sub wrapIcal {
    my $self    = shift;
    my $text    = shift;
    
    return $text unless length $text >= 75;
    
    $text       =~ s/([,;\\])/\\$1/g;
    $text       =~ s/\n/\\n/g;
    
    my @text    = ($text =~ m/.{0,75}/g);
    return join "\r\n ",@text;
}





####################################################################

=head2 www_edit ( )

Adds a submenu to the default edit page that includes links to Add an Event.

=cut

sub www_edit {
    my $self    = shift;
    my $session = $self->session;
    my $i18n    = WebGUI::International->new($session, 'Asset_Calendar');
    
    return $session->privilege->insufficient() unless $self->canEdit;
    
    $self->getAdminConsole->setHelp("Calendar add/edit", "Calendar");
    
    return $self->getAdminConsole->render(
            $self->getEditForm->print,
            $i18n->get("assetName")
        );
}






####################################################################

=head2 www_ical

Export an iCalendar feed of this Events Calendar's events.

=cut

sub www_ical {
    my $self        = shift;
    my $session     = $self->session;
    my $form        = $self->session->form;
    
    #!!! Events from what time period should we show? Default perpage?
    # By default show the events for a month
    my $type        = $form->param("type") || lc($self->get("defaultView")) || "month";
    my $start       = $form->param("start");
    my $end         = $form->param("end");
    
    
    
    
    #!!! KLUDGE:
    # An "adminId" may be passed as a parameter in order to facilitate
    # calls between calendars on the same server getting administrator 
    # privileges
    # I do not know how dangerous this could possibly be, so THIS MUST 
    # CHANGE
    # Preferably: Spectre should add the appropriate cookie so that WebGUI
    # handles this automagically.
    my $adminId = $form->param("adminId");
    if ($adminId) {
        my ($spectreTest) 
            = $self->session->db->quickArray(
                "SELECT value FROM userSessionScratch WHERE sessionId=? and name=?",
                [$adminId,$self->get("assetId")]
            );
        
        if ($spectreTest eq "SPECTRE") {
            $self->session->user({userId => 3});
        }
    }
    #/KLUDGE
    
    
    my $dt_start;
    unless ($start) {
        #if ($self->get("defaultDate") eq "first")
        #{
            #!! TODO: Get the first event's date
                # select startDate from Events 
                #    join assetLineage
                #    order by startDate ASC, revisionDate DESC
                #    limit 1
        #}
        #elsif ($self->get("defaultDate") eq "last")
        #{
            #!! TODO: Get the last event's date
                # select startDate from Events 
                #    join assetLineage
                #    order by startDate DESC, revisionDate DESC
                #    limit 1
        #}
        #else
        #{
            $dt_start = WebGUI::DateTime->new($self->session, time-60*60*24*30)->set_time_zone($session->user->profileField("timeZone"));
        #}
    }
    else {
        $dt_start    = WebGUI::DateTime->new($self->session, mysql => $start, time_zone => $session->user->profileField("timeZone"));
    }
    
    
    
    my $dt_end;
    unless ($end) {
        #if ($type eq "month")
        #{
            $dt_end    = $dt_start->clone->add(months => 1);
        #}
        #elsif ($type eq "week")
        #{
        #    $dt_end = $dt_start->clone->add(weeks => 1);
        #}
        #elsif ($type eq "day")
        #{
        #    $dt_end = $dt_start->clone->add(days => 1);
        #}
    }
    else {
        $dt_end    = WebGUI::DateTime->new($self->session, mysql => $end, time_zone => $session->user->profileField("timeZone"));
    }
    
    
    
    # Get all the events we're going to display
    my @events    = $self->getEventsIn($dt_start->toMysql,$dt_end->toMysql);
    
    
    my $ical    = qq{BEGIN:VCALENDAR\r\n}
                . qq{PRODID:WebGUI }.$WebGUI::VERSION."-".$WebGUI::STATUS.qq{\r\n}
                . qq{VERSION:2.0\r\n};
    
    # VEVENT:
    for my $event (@events) {
        $ical   .= qq{BEGIN:VEVENT\r\n};
        
        ### UID
        # Use feed's UID to prevent over-propagation
        if ($event->get("feedUid")) {
            $ical       .= qq{UID:}.$event->get("feedUid")."\r\n";
        }
        # Create a UID for feeds native to this calendar
        else {
            my $domain  = $session->config->get("sitename")->[0];
            $ical       .= qq{UID:}.$event->get("assetId").'@'.$domain."\r\n";
        }
        
        # LAST-MODIFIED (revisionDate)
        $ical   .= qq{LAST-MODIFIED:}
                . WebGUI::DateTime->new($self->session, $event->get("revisionDate"))->toIcal
                . "\r\n";
        
        # CREATED (creationDate)
        $ical   .= qq{CREATED:}
                . WebGUI::DateTime->new($self->session, $event->get("creationDate"))->toIcal
                . "\r\n";
        
        # DTSTART
        $ical   .= qq{DTSTART:}.$event->getIcalStart."\r\n";
        
        # DTEND
        $ical   .= qq{DTEND:}.$event->getIcalEnd."\r\n";
        
        # Summary (the title)
        # Wrapped at 75 columns
        $ical   .= $self->wrapIcal("SUMMARY:".$event->get("title"))."\r\n";
                
        # Description (the text)
        # Wrapped at 75 columns
        $ical   .= $self->wrapIcal("DESCRIPTION:".$event->get("description"))."\r\n";
        
        
        
        # X-WEBGUI lines
        if ($event->get("groupIdView")) {
            $ical   .= "X-WEBGUI-GROUPIDVIEW:".$event->get("groupIdView")."\r\n";
        }
        if ($event->get("groupIdEdit")) {
            $ical   .= "X-WEBGUI-GROUPIDEDIT:".$event->get("groupIdEdit")."\r\n";
        }
        $ical   .= "X-WEBGUI-URL:".$event->get("url")."\r\n";
        $ical   .= "X-WEBGUI-MENUTITLE:".$event->get("menuTitle")."\r\n"; 
        
        $ical   .= qq{END:VEVENT\r\n};
    }
    # ENDVEVENT
    
    $ical       .= qq{END:VCALENDAR\r\n};
    
    
    # Set mime of text/icalendar
    #$self->session->http->setMimeType("text/plain");
    $self->session->http->setFilename("feed.ics","text/calendar");
    return $ical;
}





####################################################################

=head2 www_importIcal

!!!TODO!!! - This will be a future addition. I'm here to whet your whistle.

Import an iCalendar file into the Events Calendar.

=cut

sub www_importIcal {
    ### TODO: Everything
    
    return $_[0]->session->privilege->noAccess;
}





####################################################################

=head2 www_search ( )

Shows the search view

=cut

sub www_search {
    my $self        = shift;
    my $session     = $self->session;
    my $form        = $session->form;
    my $user        = $session->user;

    # Get the search parameters from the form
    my $keywords    = $form->param("keywords");
    my $startDate   = $form->process("startdate");
    my $endDate     = $form->process("enddate");
    my $perpage     = $form->param("perpage");
    
    my $var         = $self->get;
    $var->{url}     = $self->getUrl;
    
    # If there is a search to perform
    if ($keywords || $startDate || $endDate) {
        my $search      = new WebGUI::Search($session);
        my %rules       = (
            keywords        => $keywords,
            classes         => ['WebGUI::Asset::Event'],
            lineage         => [$self->get("lineage")],
            join            => "join Event on assetIndex.assetId=Event.assetId",
            columns         => ['Event.startDate','Event.startTime'],
        );
        
        # If the start and/or end dates are not filled in, do not limit
        # to a certain time period
        $rules{where}    .= "Event.startDate >= '$startDate'"
                if ($startDate);
        $rules{where}    .= " && " if ($startDate && $endDate);
        $rules{where}    .= "Event.endDate <= '$endDate'"
                if ($endDate);
        
        
        # Prepare the paginator
        my @results    = ();
        $search->search(\%rules);
        my $rs = $search->getResultSet;
        while (my $data = $rs->hashRef) {
            # Only show results the user is allowed to see
            if (    $user->userId eq $data->{ownerUserId} 
                    || $user->isInGroup($data->{groupIdView}) 
                    || $user->isInGroup($data->{groupIdEdit})   ) {
                # Format the date
                my $dt    = WebGUI::DateTime->new($self->session, $data->{startDate}." ".($data->{startTime}?$data->{startTime}:"00:00:00"));
                $dt->set_time_zone($self->session->user->profileField("timeZone"))
                    if ($data->{startTime});
            
                push(@results, {
                    url         => $self->session->url->gateway($data->{url}),
                    title       => $data->{title},
                    synopsis    => $data->{synopsis},
                    startDate   => $dt->strftime('%B %e, %Y'),
                });
            }
        } 
        
        my $urlParams   = 'func=search;'
                        . 'keywords=' . $self->session->url->escape($keywords) . ';'
                        . 'startdate=' . $startDate . ';'
                        . 'enddate=' . $endDate . ';'
                        ;

        my $p = WebGUI::Paginator->new(
            $self->session,
            $self->getUrl($urlParams),
            $perpage
        );

        $p->setDataByArrayRef(\@results);
        $p->appendTemplateVars($var);
        $var->{results} = $p->getPageData;
    }
    
    # Prepare the form
    my $default_dt      = WebGUI::DateTime->new($self->session, time);
    my $default_start   = $default_dt->toMysqlDate;
    my $default_end     = $default_dt->add(years => 1)->toMysqlDate;
    
    $var->{"form.header"}    
        = WebGUI::Form::formHeader($session, {
            action      => $self->getUrl,
        })
        . WebGUI::Form::hidden($self->session, {
            name        => "func",
            value       => "search",
        });
    
    $var->{"form.footer"} = WebGUI::Form::formFooter($session);
    
    $var->{"form.keywords"} 
        = WebGUI::Form::text($session, {
            name        => "keywords",
            value       => $keywords,
        });

    $var->{"form.perpage"}    
        = WebGUI::Form::text($session, {
            name        => "perpage",
            value       => $perpage,
        });

    $var->{"form.startDate"} 
        = WebGUI::Form::date($session, {
            name            => "startDate",
            value           => $startDate,
            defaultValue    => $default_start,
        });

    $var->{"form.endDate"} 
        = WebGUI::Form::date($session, {
            name            => "endDate",
            value           => $endDate,
            defaultValue    => $default_end,
        });
    
    my $i18n = WebGUI::International->new($session, 'Asset_Calendar');

    $var->{"form.submit"}    
        = WebGUI::Form::submit($session, {
            name            => "submit",
            value           => $i18n->get('searchButtonLabel'),
        });

    # This is very bad! It should be $self->processStyle or whatnot.
    $self->session->http->sendHeader;
    my $template    = WebGUI::Asset::Template->new($self->session,$self->get("templateIdSearch"));
    my $style = $self->session->style->process("~~~",$self->get("styleTemplateId"));
    my ($head, $foot) = split("~~~",$style);
    $self->session->output->print($head, 1);
    $self->session->output->print($self->processTemplate($var, undef, $template));
    $self->session->output->print($foot, 1);
    return "chunked";
}





####################################################################

=head2 www_view ( )

Shows the normal view

=head3 URL Parameters

=over 8

=item type

What view of the calendar to show. One of "month, "week", or "day".

=item start

What time to start the calendar. Must be a full MySQL Date/Time string in the
format 2006-12-17 14:00:00. 

The calendar will truncate the start to show the entire month, week, or day, 
depending on the type.

=item print

If set to some true value (like "1"), will show the printable version of the 
page.

=back




=head1 Templates

The templates provided by this Wobject and the parameters they contain

!!! TODO !!!




=head1 BUGS / RFE

In the calendar edit form on the Default View field on the display tab, put the 
current date of the first and last event, so that user's understand EXACTLY 
where the calendar will be going.

AM/PM is not localized

Ordinal numbers (1st, 2nd, 3rd, etc...) are not handled, due to translation 
issues. 

TODO: More abstraction so that certain methods can be tested.

DODO: Handle Time Zones more logically. Any time we create a WebGUI::DateTime
object, specify the time zone we're using. Use the new toDatabaseTimeZone and
toUserTimeZone methods of WebGUI::DateTime for to make less confusion.

=cut

1;
