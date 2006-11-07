package WebGUI::i18n::English::Asset_EventManagementSystem;

our $I18N = { ##hashref of hashes
	'cancel registration' => {
		message => q|Cancel Registration|,
		lastUpdated => 0,
		context => q|Label for hyperlink asking user if they wish to cancel the registration process during checkout.|,
	},

        'search template' => { 
		message => q|Search Template|,
		lastUpdated => 1131394070,
		context => q|Field label for template selector|
	},

	'search template description' => {
		message => q|Controls the layout, look, and appearence of the Event Management System Search Page.|,
		lastUpdated => 1131394072,
		context => q|Describes this template field selector|
	},     
        
	'add/edit help title' => { 
		message => q|Add/Edit Event Management System|,
		lastUpdated => 1131394070,
		context => q|Title for Add/Edit Event Managment System Help|
	},

	'add/edit help body' => { 
		message => q|<p>The Event Management System (EMS) provides registration and payment for events inside WebGUI.  You can assign two groups who are allowed to do event management, one to add events to the manager and another to approve them.  You will also be able to setup several templates for the display of the list of events and the event checkout form.</p>
		<p>Each event for sale is a Product from the Commerce System.</p>|,
		lastUpdated => 1131394070,
		context => q|Body for Add/Edit Event Managment System Help|
	},

	'display template' => { 
		message => q|Display Template|,
		lastUpdated => 1131394070,
		context => q|Field label for template selector|
	},

	'display template description' => {
		message => q|Controls the layout, look, and appearence of an Event Management System.|,
		lastUpdated => 1131394072,
		context => q|Describes this template field selector|
	},

	'checkout template' => { 
		message => q|Checkout Template|,
		lastUpdated => 1145400901,
		context => q|Field label for template selector|
	},

	'checkout template description' => {
		message => q|Controls the layout, look, and appearence of the Checkout screen in the Event Management System.|,
		lastUpdated => 1145400973,
		context => q|Describes this template field selector|
	},

	'manage purchases template' => { 
		message => q|Manage Purchases Template|,
		lastUpdated => 1145400901,
		context => q|Field label for template selector|
	},

	'manage purchases template description' => {
		message => q|Controls the layout, look, and appearence of the Manage Purchases screen in the Event Management System.|,
		lastUpdated => 1145400970,
		context => q|Describes this template field selector|
	},

	'view purchase template' => { 
		message => q|View Purchase Template|,
		lastUpdated => 1145400901,
		context => q|Field label for template selector|
	},

	'view purchase template description' => {
		message => q|Controls the layout, look, and appearence of the View Purchase screen in the Event Management System.|,
		lastUpdated => 1145401024,
		context => q|Describes this template field selector|
	},

	'add/edit event template' => { 
		message => q|Event Template|,
		lastUpdated => 1131394070,
		context => q|Field label for event template selector|
	},

	'add/edit event template description' => {
		message => q|Controls the layout, look, and appearence of an individual Event in the Event Management System.|,
		lastUpdated => 1131394072,
		context => q|Describes the event template field selector|
	},

	'paginate after' => {
		message => q|Paginate After|,
		lastUpdated => 1131394072,
		context => q|Field label for Paginate After|
	},

	'paginate after description' => {
		message => q|Number of events to display on one page.|,
		lastUpdated => 1131394072,
		context => q|Describes the Paginate After field|
	},

	'group to add events' => {
		message => q|Group to Add Events|,
		lastUpdated => 1131394072,
		context => q|Field label|
	},

	'group to add events description' => {
		message => q|Members of the selected group will have the ability to add events to an Event Management System.
		Events added will not be available for purchase until the event is approved by a member of the Group to Approve Events.|,
		lastUpdated => 1131394072,
		context => q|Describes the Group To Add Events field|
	},

	'add/edit event start date' => {
		message => q|Event Start Date|,
		lastUpdated => 1138837472,
		context => q|Event start date field label|
	},

	'add/edit event start date description' => {
		message => q|The time and date when the event starts.|,
		lastUpdated => 1131394072,
		context => q|hover help for Event Start Date field|
	},

	'add/edit event end date' => {
		message => q|Event End Date|,
		lastUpdated => 1138837472,
		context => q|Event end date field label|
	},

	'add/edit event end date description' => {
		message => q|The time and date when the event ends.|,
		lastUpdated => 1138837560,
		context => q|hover help for Event End Date field|
	},

	'group to approve events' => {
		message => q|Group to Approve Events|,
		lastUpdated => 1131394072,
		context => q|Field Label|
	},

	'group to approve events description' => {
		message => q|Members of the selected group will have the ability to approve a pending event so that it is available for purchase.|,
		lastUpdated => 1131394072,
		context => q|Describes the Group To Approve Events field|
	},

	'add/edit event title' => {
		message => q|Event Title|,
		lastUpdated => 1138312761,
	},

	'add/edit event title description' => {
		message => q|Enter the name or title of your event.|,
		lastUpdated => 1138312761,
	},

	'add/edit event image' => {
		message => q|Event Image|,
		lastUpdated => 1145636759,
	},

	'add/edit event image description' => {
		message => q|An image representing your event for display to site visitors.|,
		lastUpdated => 1145636774,
	},

	'add/edit event description' => {
		message => q|Description|,
		lastUpdated => 1138312761,
	},

	'add/edit event description description' => {
		message => q|The details of your event, such as location, time, and what the event is about.|,
		lastUpdated => 1138312761,
	},

	'price' => {
		message => q|Price|,
		lastUpdated => 1138312761,
	},

	'add/edit event price description' => {
		message => q|The cost to attend the event.|,
		lastUpdated => 1138312761,
	},

        'add/edit useSalesTax' => {
                message => q|Use Sales Tax?|,
                lastUpdated => 1160109884,
        },

        'add/edit useSalesTax description' => {
                message => q|Should this event have sales tax applied to it?|,
                lastUpdated => 1160109886,
        },

	'add/edit event maximum attendees' => {
		message => q|Maximum Attendees|,
		lastUpdated => 1138312761,
	},

	'add/edit approve event' => {
		message => q|Approve Event|,
		lastUpdated => 1138312761,
		context => q|URL to approve an event in the Add/Edit Event form|,
	},

	'add/edit event maximum attendees description' => {
		message => q|Based on room size, chairs, staffing and other requirements, the number of people who can attend the event.|,
		lastUpdated => 1138899055,
	},

	'add/edit event required events' => {
		message => q|Required Events|,
		lastUpdated => 1138902214,
		context => q|form field in add/edit event|,
	},

	'add/edit event required events description' => {
		message => q|You can require that the user be registered for certain events before being allowed to register for this event.|,
		lastUpdated => 1138899055,
		context => q|hover help for required event field|,
	},

	'add/edit event operator' => {
		message => q|Operator|,
		lastUpdated => 1138902214,
		context => q|form field in add/edit event|,
	},

	'add/edit event operator description' => {
		message => q|As required events are added to this event, you can specify that all of the events must required (And) or that any of the events are required (Or)|,
		lastUpdated => 1138899055,
		context => q|hover help for operator field|,
	},

	'and' => {
		message => q|And|,
		lastUpdated => 1138899055,
		context => q|logical AND|,
	},

	'or' => {
		message => q|Or|,
		lastUpdated => 1138899055,
		context => q|logical OR|,
	},

	'add/edit event what next' => {
		message => q|What Next?|,
		lastUpdated => 1138902214,
		context => q|form field in add/edit event|,
	},

	'add/edit event what next description' => {
		message => q|After you have completed filling out this form, you can either add another required event, or simply save your settings and return to the Event Manager page.|,
		lastUpdated => 1138899055,
		context => q|hover help for What Next field|,
	},

	'add/edit event add another prerequisite' => {
		message => q|Add Another Prerequisite|,
		lastUpdated => 1138312761,
		context => q|option for adding another required event in the add/edit event screen|,
	},

	'add/edit event return to manage events' => {
		message => q|Return to Manage Events|,
		lastUpdated => 1138312761,
		context => q|option for returning to manage events page|,
	},

	'add/edit event assigned prerequisites' => {
		message => q|<br />Assigned Prerequisites<br /><br />|,
		lastUpdated => 1138312761,
		context => q|Label for displaying required events|,
	},

	'add/edit event error' => {
		message => q|ERROR|,
		lastUpdated => 1138903982,
		context => q|label for displaying errors when an event has been added or edited, such as missing required fields.|,
	},

	'event' => {
		message => q|Event|,
		lastUpdated => 1138904660,
	},

	'global prerequisite' => {
		message => q|Global Prerequisites|,
		lastUpdated => 1138312761,
	},

	'global prerequisite description' => {
		message => q|When set to yes, you may assign events belonging to another instance of an Event Management System Asset as a prerequisite event for one of the events defined in this instance os the asset.  When set to no, only events defined within this instance of the asset may be used as prerequisites.|,
		lastUpdated => 1138312761,
	},

	'price must be greater than zero' => {
		message => q|Price must be greater than zero.|,
		lastUpdated => 1138312761,
		context => q|Error message for an illegal price.|,
	},

	'status' => {
		message => q|Status|,
		lastUpdated => 1138908026,
		context => q|Whether an event has been approved or not|,
	},

	'approved' => {
		message => q|Approved|,
		lastUpdated => 1138908026,
		context => q|label in Event Manager, approved|,
	},

	'pending' => {
		message => q|Pending|,
		lastUpdated => 1138908026,
		context => q|label in Event Manager, waiting for approval|,
	},

	'confirm delete event' => {
		message => q|Are you sure you want to delete this event?|,
		lastUpdated => 1138908026,
		context => q|Confirm whether an event will be deleted|,
	},

	'confirm delete prerequisite' => {
		message => q|Are you sure you want to delete this prerequisite?|,
		lastUpdated => 1138908883,
		context => q|Confirm whether a prerequisite will be deleted in the add/edit event screen|,
	},

	'add event' => {
		message => q|Add Event|,
		lastUpdated => 1138908251,
		context => q|Link to add an event to the event manager|,
	},

	'manage event metadata' => {
		message => q|Manage Event Metadata|,
		lastUpdated => 1138908251,
		context => q|Link to manage event metadata|,
	},

	'add new event metadata field' => {
		message => q|Add new Event Metadata Field|,
		lastUpdated => 1138908251,
		context => q|In Manage Event Metadata screen|,
	},

	'add/edit event metadata field' => {
		message => q|Add/Edit Event Metadata Field|,
		lastUpdated => 1138908251,
		context => q|In Manage Event Metadata screen|,
	},

	'add/edit event metadata field body' => {
		message => q|<p>This screen allows you to add a new metadata field to an event or to reconfigure existing metadata fields.</p>|,
		lastUpdated => 1138908251,
	},

	'edit prerequisite set body' => {
		message => q|<p>This screen allows you to define prerequisites for an event or edit an event's current prerequisites.</p>
<p>With respect to prerequisites, there are basically two classes of Events.  There are those that have prerequisites (Select Events) and those that do not (Master Events).  Only Master Events can serve as prerequisites.  Adding a prerequisite to a Master Event will make it become a Select Event, and it may no longer be used as a Master Event.</p>|,
		lastUpdated => 1147146318,
	},

	'edit discount pass body' => {
		message => q|<p>This screen allows you to create new discount passes that can be purchased, or to edit existing passes.</p>
|,
		lastUpdated => 1147146318,
	},

	'null field error' => {
		message => q|The %s field cannot be blank.|,
		lastUpdated => 1138908251,
		context => q|When a required field is empty/blank, then this message is used in sprintf to tell the user which field it is and that it cannot be blank|,
	},

	'add to cart' => {
		message => q|Add To Badge|,
		lastUpdated => 1140466438,
		context => q|Label to invite the user to purchase this event and add it to their shopping cart.|,
	},

	'allowed sub events' => {
		message => q|You may also attend the following sub-events based on the events currently in your shopping cart.<br />|,
		lastUpdated => 1140469381,
	},

	'scheduling conflict message' => {
		message => q|You have a scheduling conflict.  Please remove one of the events below from your cart to resolve the problem.|,
		lastUpdated => 1142362442,
	},

	'scheduling conflict continue' => {
		message => q|Click here to continue|,
		lastUpdated => 1142362439,
	},

	'template help title' => {
		message => q|Event Management System Template|,
		lastUpdated => 1140465899,
	},

	'checkout.url' => {
		message => q|A URL to take the user the screen that displays the contents of their shopping cart.|,
		lastUpdated => 1149828278,
	},

	'checkout.label' => {
		message => q|A label to go with checkout.url.  The internationalized word "Checkout".|,
		lastUpdated => 1149828278,
	},

	'events_loop' => {
		message => q|This loop contains all events that have been approved so that users can register.|,
		lastUpdated => 1149828278,
	},

	'tmplVar event' => {
		message => q|The information for one event that has been processed by its own event template.|,
		lastUpdated => 1149828278,
	},

	'paginateBar' => {
		message => q|A bar to help the user page through sets of Events if several pages of Events exist.|,
		lastUpdated => 1149828278,
	},

	'Pagination variables' => {
		message => q|Common pagination template variables.|,
		lastUpdated => 1149828278,
	},

	'canManageEvents' => {
		message => q|A flag to indicate if the current user is allowed to Manage Events.|,
		lastUpdated => 1149829190,
	},

	'manageEvents.url' => {
		message => q|A URL to take the user to the screen where Events can be managed (i.e. added, approved, deleted)|,
		lastUpdated => 1149828278,
	},

	'manageEvents.label' => {
		message => q|An internationalized label to dispaly to the user the link for managing events.|,
		lastUpdated => 1149828278,
	},

	'managePurchases.url' => {
		message => q|A URL to take the user to the screen where purchases can be managed (i.e. added, approved, deleted)|,
		lastUpdated => 1149828278,
	},

	'managePurchases.label' => {
		message => q|An internationalized label to dispaly to the user the link for managing purchases.|,
		lastUpdated => 1149828278,
	},

	'template help body' => {
		message => q|
<p>This template is used to style the main page of the Event Management System where
products are displayed to the user as well as providing a link for managing events
in the system.</p>
|,
		lastUpdated => 1149828856,
	},

	'event template help title' => {
		message => q|Event Management System Event Template|,
		lastUpdated => 1140465899,
	},

	'title' => {
		message => q|The title of this event.|,
		lastUpdated => 1149828404,
	},

	'title.url' => {
		message => q|A URL to display a list of events that have this event|,
		lastUpdated => 1149828404,
	},

	'description' => {
		message => q|The description of this event.|,
		lastUpdated => 1149828404,
	},

	'image' => {
		message => q|The image assigned to represent this event.|,
		lastUpdated => 1149828404,
	},

	'tmplVar price' => {
		message => q|The price of this event.|,
		lastUpdated => 1149828404,
	},

	'tmplVar sku' => {
		message => q|The SKU for this event.|,
		lastUpdated => 1149828404,
	},

	'tmplVar sku template' => {
		message => q|The SKU templates used to generate the SKU for this event.|,
		lastUpdated => 1149828404,
	},

	'tmplVar weight' => {
		message => q|The weight associated with materials for this event.|,
		lastUpdated => 1149828404,
	},

	'numberRegistered' => {
		message => q|The number of people currently registered for this event.|,
		lastUpdated => 1149828404,
	},

	'maximumAttendees' => {
		message => q|The number of people allowed to attend this event.|,
		lastUpdated => 1149828404,
	},

	'seatsRemaining' => {
		message => q|The number of available seats remaining for this event.|,
		lastUpdated => 1149828404,
	},

	'eventIsFull' => {
		message => q|A boolean that is true if the there are no available seats remaining in this event.|,
		lastUpdated => 1149828404,
	},

	'eventIsApproved' => {
		message => q|A boolean that is true if the event has been approved.|,
		lastUpdated => 1149828404,
	},

	'startDate.human' => {
		message => q|The date and time this event starts, in human readable format.|,
		lastUpdated => 1149828404,
	},

	'endDate.human' => {
		message => q|The date and time this event ends, in human readable format.|,
		lastUpdated => 1149828404,
	},

	'purchase.label' => {
		message => q|An internationalized label to display to the user the link for purchasing this event.
If the event is full, the label will be "Sold out".|,
		lastUpdated => 1149828404,
	},

	'purchase.url' => {
		message => q|A URL for the user to register for this event and add it to their shopping cart.
If the event is full, the url will be blank.|,
		lastUpdated => 1149828404,
	},

	'purchase.message' => {
		message => q|A message to ask the user whether or not they'd like to see subevents for this event.
If the event is full, this variable will be blank.|,
		lastUpdated => 1149828404,
	},

	'purchase.wantToSearch.url' => {
		message => q|A URL to search for events that are requirements for this event.
If the event is full, this variable will be blank.|,
		lastUpdated => 1149828404,
	},

	'purchase.wantToContinue.url' => {
		message => q|A URL to add this event to the cart.
If the event is full, this variable will be blank.|,
		lastUpdated => 1149828404,
	},

	'purchase.label' => {
		message => q|The internationalized label "Add To Cart".
If the event is full, this variable will be blank.|,
		lastUpdated => 1149828404,
	},

	'event template help body' => {
		message => q|
<p>This template is used to display the contents of a single Event to the
user.</p>
|,
		lastUpdated => 1149828859,
	},

	'manage purchases template help title' => {
		message => q|EMS Manage Purchases Template|,
		lastUpdated => 1140465899,
	},

	'purchasesLoop' => {
		message => q|This loop contains all events that have been approved so that users can view their purchases.|,
		lastUpdated => 1149828546,
	},

	'purchaseUrl' => {
		message => q|A link to view the details of this purchase.|,
		lastUpdated => 1149828546,
	},

	'datePurchasedHuman' => {
		message => q|The date and time this purchase was started in a human readable format.|,
		lastUpdated => 1149828546,
	},

	'managePurchasesTitle' => {
		message => q|An internationalized label to title this screen.|,
		lastUpdated => 1149828546,
	},

	'manage purchases template help body' => {
		message => q|
<p>This template is used to style the screen of the Event Management System where
the user can manage their purchases.</p>
|,
		lastUpdated => 1149828862,
	},

	'view purchase template help title' => {
		message => q|EMS View Purchases Template|,
		lastUpdated => 1140465899,
	},

	'purchasesLoop' => {
		message => q|This loop contains all registrations that are included in this purchase.|,
		lastUpdated => 1149828601,
	},

	'regLoop' => {
		message => q|This loop contains all events that are included in this registration.|,
		lastUpdated => 1149828601,
	},

	'startDateHuman' => {
		message => q|The start date in a human readable format for this event.|,
		lastUpdated => 1149828601,
	},

	'startDateHuman' => {
		message => q|The start date in a human readable format for this event.|,
		lastUpdated => 1149828601,
	},

	'endDateHuman' => {
		message => q|The end date in a human readable format for this event.|,
		lastUpdated => 1149828601,
	},

	'startDate' => {
		message => q|This event's start date and time in epoch format.|,
		lastUpdated => 1149828601,
	},

	'endDateHuman' => {
		message => q|This event's end date and time in epoch format.|,
		lastUpdated => 1149828601,
	},

	'registrationId' => {
		message => q|The user's registrationId for this event.|,
		lastUpdated => 1149828601,
	},

	'templateId' => {
		message => q|The template used to style this event if it is to be displayed.|,
		lastUpdated => 1149828601,
	},

	'returned' => {
		message => q|A boolean that will be 1 if this event has been returned by the user.|,
		lastUpdated => 1149828601,
	},

	'tmplVar approved' => {
		message => q|A boolean that will be 1 if this event has been approved.|,
		lastUpdated => 1149828601,
	},

	'templateId' => {
		message => q|The template used to style this event if it is to be displayed.|,
		lastUpdated => 1149828601,
	},

	'userId' => {
		message => q|The Id of the user set to use this badge.|,
		lastUpdated => 1149828601,
	},

	'createdByUserId' => {
		message => q|The Id of the user who created this badge.|,
		lastUpdated => 1149828601,
	},

	'canReturnItinerary' => {
		message => q|A boolean indicating whether or not this event can be returned.|,
		lastUpdated => 1149828601,
	},

	'canAddEvents' => {
		message => q|A boolean indicating whether or not the current user is allowed to add events.  Admins, the owner
of the transaction, the user who created the registration or the user who the registration is
for are allowed to add events.|,
		lastUpdated => 1149828601,
	},

	'canReturnTransaction' => {
		message => q|A boolean that is true if any purchase can be returned.|,
		lastUpdated => 1149828601,
	},

	'viewPurchaseTitle' => {
		message => q|An internationalized label to title this screen.|,
		lastUpdated => 1149828601,
	},

	'canReturn' => {
		message => q|A boolean indicating if the current user may return events in the purchase.  Users who can add events 
fall into this group.|,
		lastUpdated => 1149828601,
	},

	'transactionId' => {
		message => q|The unique identifier for this transaction in the database.|,
		lastUpdated => 1149828601,
	},

	'appUrl' => {
		message => q|A URL back to the main screen of the Asset.|,
		lastUpdated => 1149828601,
	},

	'view purchase template help body' => {
		message => q|
<p>This template is used to style the screen of the Event Management System where
the users and admins can view or edit a purchase.</p>

<p>In addition to the template variables below, this template also has access to the
EMS Asset variables.</p>
|,
		lastUpdated => 1149828843,
	},

	'search template help title' => {
		message => q|EMS Search Template|,
		lastUpdated => 1140465899,
	},

	'calendarJS' => {
		message => q|Script tag to set up the javascript calendar picker.|,
		lastUpdated => 1149828900,
	},

	'basicSearch.formHeader' => {
		message => q|Form header for a basic search.|,
		lastUpdated => 1149828900,
	},

	'advSearch.formHeader' => {
		message => q|Form header for an advanced search.|,
		lastUpdated => 1149828900,
	},

	'isAdvSearch' => {
		message => q|Boolean indicating if an advanced search form has been requested.|,
		lastUpdated => 1149828900,
	},

	'search.formFooter' => {
		message => q|Form footer code for either type of search.|,
		lastUpdated => 1149828900,
	},

	'search.formSubmit' => {
		message => q|A button to submit the user's search data.  The button will contain the internationalized word "Filter".|,
		lastUpdated => 1149828900,
	},

	'endDate' => {
		message => q|The date and time this event ends, in epoch format.|,
		lastUpdated => 1149828900,
	},

	'productId' => {
		message => q|The unique identifier for this product.|,
		lastUpdated => 1149828900,
	},

	'manageToolbar' => {
		message => q|Code for an toolbar with icons to delete, edit and reorder events.|,
		lastUpdated => 1149828900,
	},

	'noSearchDialog' => {
		message => q|A boolean that indicates if the user has requested that no search dialog be presented
by setting the "hide" form variable.|,
		lastUpdated => 1149828900,
	},

	'addEvent.url' => {
		message => q|A URL to take the user to the screen to add a new event.|,
		lastUpdated => 1149828900,
	},

	'addEvent.label' => {
		message => q|An internationalized label to dispaly to the user the link for adding an event.|,
		lastUpdated => 1149828900,
	},

	'message' => {
		message => q|Messages from the system about the number and type of results being displayed.|,
		lastUpdated => 1149828900,
	},

	'numberOfSearchResults' => {
		message => q|The number of results returned by the current search.|,
		lastUpdated => 1149828900,
	},

	'continue.url' => {
		message => q|A url to add this event to the cart.|,
		lastUpdated => 1149828900,
	},

	'continue.label' => {
		message => q|The internationalized label, "Continue" to go with continue.url.|,
		lastUpdated => 1149828900,
	},

	'name.label' => {
		message => q|The internationalized label, "Event".|,
		lastUpdated => 1149828900,
	},

	'starts.label' => {
		message => q|The internationalized label, "Starts".|,
		lastUpdated => 1149828900,
	},

	'ends.label' => {
		message => q|The internationalized label, "Ends".|,
		lastUpdated => 1149828900,
	},

	'price.label' => {
		message => q|The internationalized label, "Price".|,
		lastUpdated => 1149828900,
	},

	'seats.label' => {
		message => q|The internationalized label, "Seats".|,
		lastUpdated => 1149828900,
	},

	'addToBadgeMessage' => {
		message => q|A message from the system if a badge was successfully added to this transaction.|,
		lastUpdated => 1149828900,
	},

	'search.filters.options' => {
		message => q|Javascript for a search interface for Events based on their properties and metadata.|,
		lastUpdated => 1149828900,
	},

	'search.data.url' => {
		message => q|The URL to this Asset.|,
		lastUpdated => 1149828900,
	},

	'ems.wobject.dir' => {
		message => q|The URL the EventManagementSystem area in the WebGUI Extras directory.|,
		lastUpdated => 1149828900,
	},

	'search template help body' => {
		message => q|
<p>This template is used to style the screen of the Event Management System where
the users and admins can view or edit a purchase.</p>
|,
		lastUpdated => 1149829240,
	},

	'event template help title' => {
		message => q|Event Management System Event Template|,
		lastUpdated => 1140465899,
	},

	'add/edit event help title' => { 
		message => q|Add/Edit Event|,
		lastUpdated => 1140469726,
		context => q|Title for Add/Edit Event Help|
	},

	'add/edit event help body' => { 
		message => q|
<p>In this form you will create an Event for sale on the site.
Each Event is very similar to a cross between a Product in the Product
Manager and an Event in the Events Calendar.  You will give the Event
a title, description, price, a template for displaying the event to the user and when
the event starts and ends.  There are also several Event Management System specific fields for
defining the maximum number of attendees, and if there are other events which are prerequisites
for this event.</p>

|,
		lastUpdated => 1140470450,
		context => q|Body for Add/Edit Event Help|
	},

	#If the help file documents an Asset, it must include an assetName key
	#If the help file documents an Macro, it must include an macroName key
	#For all other types, use topicName
	'assetName' => {
		message => q|Event Management System|,
		lastUpdated => 1131394072,
	},

	'global metadata' => {
		message => q|Use Global Event Metadata|,
		lastUpdated => 1140469381,
	},

	'global metadata description' => {
		message => q|Whether or not to use all other Event Management Systems Metadata Fields when assigning metadata to events and searching for events.<br /><br />The management screen list of metadata fields for this asset will still remain limited to those created by this EMS asset.<br />|,
		lastUpdated => 1140469381,
	},

	'type name here' => {
		message => q|Type Name Here|,
		lastUpdated => 1140469381,
	},

	'type label here' => {
		message => q|Type Label Here|,
		lastUpdated => 1140469381,
	},

	'sold out' => {
		message => q|Sold Out|,
		lastUpdated => 1140469381,
	},

	'confirm delete event metadata' => {
		message => q|Are you certain you want to delete this metadata field?  The metadata values for this field will be deleted from all events, including events in other EMS wobjects that are set to use global metadata.|,
		lastUpdated => 1140469381,
	},

	'manage purchases' => {
		message => q|Manage Purchases|,
		lastUpdated => 1145396293,
	},

	'view purchase' => {
		message => q|View Purchase|,
		lastUpdated => 1145396293,
	},

	'refresh events list' => {
		message => q|Refresh Events List|,
		lastUpdated => 1145396293,
	},

	'you' => {
		message => q|you|,
		lastUpdated => 1145396293,
		context => q|Third person pronoun|,
	},

	'create a badge for myself' => {
		message => q|Create a badge for myself|,
		lastUpdated => 1145396293,
	},

	'create a badge for someone else' => {
		message => q|Create a badge for someone else|,
		lastUpdated => 1145396293,
	},

	'you do not have any metadata fields to display' => {
		message => q|You do not have any metadata fields to display.|,
		lastUpdated => 1145396293,
	},

	'you do not have any events to display' => {
		message => q|You do not have any events to display.|,
		lastUpdated => 1145396293,
	},

	'save approvals' => {
		message => q|Save Approvals|,
		lastUpdated => 1145396293,
	},

	'approve event' => {
		message => q|Approve Event|,
		lastUpdated => 1145396293,
	},

	'approve event description' => {
		message => q|You can approve events so you may either submit events already approved or directly edit approval of events|,
		lastUpdated => 1145396293,
	},

	'approval' => {
		message => q|Approval|,
		lastUpdated => 1145396293,
	},

	'auto search' => {
		message => q|Initial Search Field|,
		lastUpdated => 1145400186,
	},

	'auto search description' => {
		message => q|Make this appear as a Filter Field on the Advanced Search screen by default|,
		lastUpdated => 1145400186,
	},

	'select one' => {
		message => q|Select One|,
		lastUpdated => 1145400186,
		context => q|Label to indicate that the user should pick one thing from a list of options|,
	},

	'select one or more' => {
		message => q|Select one or more|,
		lastUpdated => 1147293240,
		context => q|Label to indicate that the user should pick one or more things from a list of options|,
	},

	'seats available' => {
		message => q|Seats Available|,
		lastUpdated => 1145400186,
	},

	'missing prerequisites message' => {
		message => q|Some of the events you have selected require attendance of another event.  Please satisfy prerequisites from the list below.|,
		lastUpdated => 1145402683,
	},

	'checkout' => {
		message => q|Checkout|,
		lastUpdated => 1145402683,
	},

	'filter' => {
		message => q|Filter|,
		lastUpdated => 1145402683,
		context => q|Button in search form to limit displayed events based on user criteria|,
	},

	'managePrereqsMessage' => {
		message => q|Use the form below to add prerequisite assignments to %s.|,
		lastUpdated => 1145653451,
		context => q|Message for search form, that is passed to sprintf to fill in the name|,
	},

	'Admin manage sub events small resultset' => {
		message => q|You may manage the events below.  You can narrow the list of events displayed using the basic or advanced filter options above.|,
		lastUpdated => 1145653452,
	},

	'User sub events small resultset' => {
		message => q|You may also choose from the following sub-events.  You can narrow the list of sub-events by using the basic or advanced filter options above.|,
		lastUpdated => 1145653452,
	},

	'Admin manage sub events large resultset' => {
		message => q|You may manage the events below.  Due to the large number of sub-events available none are currently displayed, please narrow the results using the basic or advanced filter options above.|,
		lastUpdated => 1145653452,
	},

	'User sub events large resultset' => {
		message => q|You may also choose from the following sub-events.  Due to the large number of sub-events available none are currently displayed, please narrow the results using the basic or advanced filter options above.|,
		lastUpdated => 1145653452,
	},

	'option to narrow' => {
		message => q|You can narrow the list of prerequisites displayed using the basic or advanced filter options above.|,
		lastUpdated => 1145653452,
	},

	'forced narrowing' => {
		message => q|Due to the large number of prerequisites available none are currently displayed, please narrow the results using the basic or advanced filter options above.|,
		lastUpdated => 1145653452,
	},

	'first name' => {
		message => q|First Name|,
		lastUpdated => 1145743634,
		context => q|Given name|,
	},

	'last name' => {
		message => q|Last Name|,
		lastUpdated => 1145743634,
		context => q|Family name|,
	},

	'address' => {
		message => q|Address|,
		lastUpdated => 1145743634,
	},

	'city' => {
		message => q|City|,
		lastUpdated => 1145743634,
	},

	'state' => {
		message => q|State|,
		lastUpdated => 1145743634,
	},

	'zip code' => {
		message => q|Zip Code|,
		lastUpdated => 1145743634,
	},

	'country' => {
		message => q|Country|,
		lastUpdated => 1145743634,
	},

	'phone number' => {
		message => q|Phone Number|,
		lastUpdated => 1145743634,
	},

	'email address' => {
		message => q|Email Address|,
		lastUpdated => 1145743634,
	},

	'which badge' => {
		message => q|Which Badge|,
		lastUpdated => 1145743634,
	},

	'registration info message' => {
		message => q|<p>Enter Badge/Contact information for the series of events you are currently adding to the cart.</p>
<p>If you are logged in, you can choose to update your own user profile with this information by choosing your name from the drop-down box, or if your name is not listed, choose the option "Create badge for myself".</p>
<p>If you are making a purchase for someone else, select their name or select the "Create New for someone else" option from the drop-down box.  If you are adding items to a previous purchase, that badge is already selected, and cannot be changed.  If you make changes to the fields in this form for a badge that already exists, their information will be updated.</p>|,
		lastUpdated => 1146074906,
	},

	'manage prerequisites' => {
		message => q|Manage Prerequisites for this event|,
		lastUpdated => 1146075135,
	},

	'add to badge message' => {
		message => q|%s was added to your badge successfully.|,
		lastUpdated => 1146075135,
	},

	'sku template' => {
		message => q|SKU Template|,
		lastUpdated => 1146170715,
		context => q|The label for the sku template field in the edit product screen.|
	},

	'weight' => {
		message => q|Weight|,
		lastUpdated => 1146170737,
		context => q|Describing the physical weight of an object.|
	},

        'weight description' => {
                message => q|The weight of anything that may be associated with your event.|,
                lastUpdated => 1120449422,
        },

	'sku' => {
		message => q|SKU|,
		lastUpdated => 1146170838,
		context => q|The form label for the SKU (Stock Keeping Unit) field|
	},

	'sku description' => {
		message => q|A SKU Number to assign to the event.  A Globaly Unique Identifier is generated by default.|,
		lastUpdated => 1146170838,
	},

	'sku template' => {
		message => q|SKU Template|,
		lastUpdated => 1146170932,
		context => q|The label for the sku template field in the edit event screen.|
	},

        'sku template description' => {
                message => q|This field defines how the SKU for each
product variant will be composed. The syntax is the same as that of
normal templates.|,
                lastUpdated => 1146170930,
        },

        'error' => {
                message => q|Error:|,
                lastUpdated => 1146170930,
        },

        'manage prerequisite sets' => {
                message => q|Manage Prerequisite Sets|,
                lastUpdated => 1147050475,
        },

        'edit prerequisite set' => {
                message => q|Edit Prerequisite Set|,
                lastUpdated => 1147050475,
        },

        'assigned prerequisite set' => {
                message => q|Assigned Prerequisite Set|,
                lastUpdated => 1147050475,
        },

        'assigned prerequisite set description' => {
                message => q|The Prerequisite Set this event requires in order to be added to a badge.|,
                lastUpdated => 1147050475,
        },

        'confirm delete prerequisite set' => {
                message => q|Are you sure you want to delete this prerequisite set?  This will also unlink any events that require this prerequisite set.|,
                lastUpdated => 1147050475,
        },

        'no sets to display' => {
                message => q|You do not have any prerequisite sets to display.|,
                lastUpdated => 1147050475,
        },

        'add prerequisite set' => {
                message => q|Add Prerequisite Set|,
                lastUpdated => 1147050475,
        },

        'prereq set name field label' => {
                message => q|Prerequisite Set Name|,
                lastUpdated => 1147050475,
        },

        'prereq set name field description' => {
                message => q|A descriptive name for this prerequisite set|,
                lastUpdated => 1147050475,
        },

        'operator type' => {
                message => q|Operator Type|,
                lastUpdated => 1147050475,
        },

        'operator type description' => {
                message => q|Whether any or all of the selected events should be required.|,
                lastUpdated => 1147050958,
        },

        'any' => {
                message => q|Any|,
                lastUpdated => 1147050958,
        },

        'all' => {
                message => q|All|,
                lastUpdated => 1147050958,
        },

        'events required by this prerequisite set' => {
                message => q|Events required by this prerequisite set.|,
                lastUpdated => 1147050958,
        },

        'events required by description' => {
                message => q|Place a check beside the events that are part of this prerequisite set.|,
                lastUpdated => 1147050958,
        },

        'manage registrants' => {
                message => q|Manage Registrants|,
                lastUpdated => 1147050958,
        },

        'manage discount passes' => {
                message => q|Manage Discount Passes|,
                lastUpdated => 1147050958,
        },

        'add registrant' => {
                message => q|Add Registrant|,
                lastUpdated => 1147050958,
        },

        'edit registrant' => {
                message => q|Edit Registrant|,
                lastUpdated => 1147050958,
        },

        'edit registrant body' => {
                message => q|<p></p>|,
                lastUpdated => 1147050958,
        },

        'see available subevents' => {
                message => q|Would you like to see available subevents?|,
                lastUpdated => 1147050958,
        },

        'manage events' => {
                message => q|Manage Events|,
                lastUpdated => 1147050958,
        },

        'associated user' => {
                message => q|Associated User|,
                lastUpdated => 1147050958,
        },

        'associated user description' => {
                message => q|It is possible to link up this registrant with a user from the WebGUI user database and to synchronize their registrant information with their WebGUI profile.  You may also create a new WebGUI user with their profile information started with their registrant information.|,
                lastUpdated => 1147050958,
        },

        'badge id' => {
                message => q|badgeId|,
                lastUpdated => 1147050958,
        },

        'create new user' => {
                message => q|Create New User|,
                lastUpdated => 1147050958,
        },

        'Unlink User' => {
                message => q|Unlink User|,
                lastUpdated => 1147050958,
        },

        'reset user' => {
                message => q|Reset User|,
                lastUpdated => 1147050958,
        },

        'continue' => {
                message => q|Continue|,
                lastUpdated => 1147050958,
        },

        'starts' => {
                message => q|Starts|,
                lastUpdated => 1147058497,
        },

        'ends' => {
                message => q|Ends|,
                lastUpdated => 1147058499,
        },

        'Event Number' => {
                message => q|Event Number|,
                lastUpdated => 1147058499,
                context => q|Synonym for SKU|,
        },

        'created by' => {
                message => q|Created by|,
                lastUpdated => 1147058499,
        },

        'created by description' => {
                message => q|The user that created this registrant identity.|,
                lastUpdated => 1147058499,
        },

        'add discount pass' => {
                message => q|Add Discount Pass|,
                lastUpdated => 1147108858,
        },

        'discount pass id' => {
                message => q|Discount Pass ID|,
                lastUpdated => 1147108858,
        },

        'discount pass id description' => {
                message => q|A unique identifier used internally for this discount pass.  When a new discount pass is created, this will be the word "new".|,
                lastUpdated => 1147108858,
        },

        'discount pass type' => {
                message => q|Discount Pass Type|,
                lastUpdated => 1147108858,
        },

        'discount pass type description' => {
                message => q|The Discount Pass can be one of several types.  The 'Percent Off' type reduces the price on applied products by the given percentage.  The 'New Price' type sets the price of the product to the given amount.  The 'Amount Off' type reduces the price by the given absolute amount.  The default type is 'New Price'.|,
                lastUpdated => 1147108858,
        },

        'pass name' => {
                message => q|Discount Pass Name|,
                lastUpdated => 1147108858,
        },

        'pass name description' => {
                message => q|The name of your discount pass.  This will be used in the system to refer to this pass and the discounts that it provides so be sure to pick a descriptive name.  This field cannot be left blank.|,
                lastUpdated => 1147108858,
        },

        'percent off' => {
                message => q|Percent Off|,
                lastUpdated => 1147108858,
        },

        'amount off' => {
                message => q|Amount Off|,
                lastUpdated => 1147108858,
        },

        'new price' => {
                message => q|New Price|,
                lastUpdated => 1147108858,
        },

        'discount amount' => {
                message => q|Discount(ed) Amount|,
                lastUpdated => 1147108858,
        },

        'discount amount description' => {
                message => q|The amount field can be in one of several unit types, depending on the discount pass type.  The 'Percent Off' type is in percent units (for 10% reduction, enter '10').  The 'New Price' and 'Amount Off' types are in an absolute amount of currency.  The default value is '0.00'.|,
                lastUpdated => 1147108858,
        },

        'edit discount pass' => {
                message => q|Edit Discount Pass|,
                lastUpdated => 1147108858,
        },

        'None' => {
                message => q|None|,
                lastUpdated => 1147108858,
        },

        'discount pass member' => {
                message => q|<strong>This event is a member of a discount pass.</strong><br />  The selected discount pass should be applied to this event if both are in the user's cart|,
                lastUpdated => 1147108858,
        },

        'defines discount pass' => {
                message => q|<strong>This event defines a discount pass.</strong><br />  If the user adds this event to his/her cart, the associated discount will be applied (upon checkout) to any events that are members of this discount pass.|,
                lastUpdated => 1147108858,
        },

        'discount pass type' => {
                message => q|Discount Pass Type|,
                lastUpdated => 1147108858,
        },

        'discount pass type description' => {
                message => q|Define if this event uses a discount pass, and if it does, whether it is one or
is a member of a group that uses a discount pass.  For example, you could create a discount pass event called
Attend All Sessions for fifty dollars.  Each session may cost twenty-five dollars, but be eligible to be
added to the user's cart and would be discounted if the Attend All Sessions event is also purchased.|,
                lastUpdated => 1147108858,
        },

        'assigned discount pass' => {
                message => q|Assigned Discount Pass|,
                lastUpdated => 1147108858,
        },

        'assigned discount pass description' => {
                message => q|The Discount Pass, if any, that will be applied to this event.|,
                lastUpdated => 1147108858,
        },

        'manage discount pass body' => {
                message => q|<p>The Manage Discount Passes screen allows you to manage Discount Passes on any Event Management System asset on your site.  Any user who is allowed to add events to the EMS also has access this screen.  Using the list of displayed passes, you may delete or edit any pass.  Use the link to the right to create a new discount pass.</p>|,
                lastUpdated => 1147108858,
        },

        'confirm delete purchase' => {
                message => q|Are you sure you want to delete this item from your cart?  Any changes you have made to the current badge you are editing will also be lost.|,
                lastUpdated => 1147108858,
        },

};

1;
