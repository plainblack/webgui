package WebGUI::i18n::English::ShipDriver_UPS;

use strict;

our $I18N = {

    'userid' => {
        message => q|UPS UserId|,
        lastUpdated => 1203569535,
        context => q|Label in the ShipDriver edit form.|,
    },

    'userid help' => {
        message => q|You can get a UserId by first registering with the UPS.|,
        lastUpdated => 1203569511,
    },

    'password' => {
        message => q|UPS Password|,
        lastUpdated => 1203569535,
        context => q|Label in the ShipDriver edit form.|,
    },

    'password help' => {
        message => q|You will recieve a password along with your UserId when you register.|,
        lastUpdated => 1203569511,
    },

    'license' => {
        message => q|UPS Access License Number|,
        lastUpdated => 1203569535,
        context => q|Label in the ShipDriver edit form.|,
    },

    'license help' => {
        message => q|You will recieve a license along with your UserId and password when you register.|,
        lastUpdated => 1203569511,
    },

    'instructions' => {
        message => q|Registration Instructions|,
        lastUpdated => 1203569535,
        context => q|Label in the ShipDriver edit form.|,
    },

    'ups instructions' => {
        lastUpdated => 1241028258,
        message => q|<p>In order to use the UPS Shipping Driver, you must first register with the UPS on their <a href="http://www.ups.com/e_comm_access/gettools_index?loc=en_US">website</a>.  When you get to the step for an access key, be sure to get an XML access key.  Enter your UPS username and password and access key into the form.</p><p>The driver currently supports domestic and international shipping from the United States.  The weight property of a Product is considered to be in pounds.  All currencies are in United States dollars.  The package for shipping is a generic package, and there are no options for tubes, envelopes or fixed size packages available from the UPS.</p>|,
    },

    'ship service' => {
        message => q|Shipping service|,
        lastUpdated => 1203569535,
        context => q|Label in the ShipDriver edit form.|,
    },

    'ship service help' => {
        message => q|Select one from the list of options.  If you wish to provide multiple types of shipping, create one additional shipping driver instance for each option.|,
        lastUpdated => 1203569511,
    },

    'pickup type' => {
        message => q|Pickup Type|,
        lastUpdated => 1243006539,
        context => q|Label in the ShipDriver edit form.|,
    },

    'pickup type help' => {
        message => q|Select how the packages will be delivered to the UPS for shipping.|,
        lastUpdated => 1203569511,
    },

    'source zipcode' => {
        message => q|Shipping Zipcode|,
        lastUpdated => 1203569535,
        context => q|Label in the ShipDriver edit form.|,
    },

    'source zipcode help' => {
        message => q|The zipcode of the location you will be shipping from.|,
        lastUpdated => 1203569511,
    },

    'source country' => {
        message => q|Shipping Country|,
        lastUpdated => 1242945847,
        context => q|Label in the ShipDriver edit form.|,
    },

    'source country help' => {
        message => q|The country you will be shipping from.|,
        lastUpdated => 1242945844,
    },

    'customer classification' => {
        message => q|Customer Classification|,
        lastUpdated => 1241214572,
        context => q|What kind or type of customer are you?|,
    },

    'customer classification help' => {
        message => q|The kind or type of customer you are.|,
        lastUpdated => 1247110533,
    },

    'residentialIndicator' => {
        message => q|Residential or Commercial?|,
        lastUpdated => 1248113596,
        context => q|Residential (a person's home) versus Commercial, a business address.|,
    },

    'residential help' => {
        message => q|The UPS rates for delivering to a residential address, or a commercial address differ.  WebGUI will not ask the user which is which, so you will need to configure drivers for both kinds of destinations.|,
        lastUpdated => 1248113598,
    },

    'residential' => {
        message => q|Residential|,
        lastUpdated => 1248113596,
        context => q|Residential (a person's home)|,
    },

    'commercial' => {
        message => q|Commercial|,
        lastUpdated => 1248113596,
        context => q|A business address|,
    },

    'customer classification 01' => {
        message => q|Wholesale|,
        lastUpdated => 1247110533,
    },

    'customer classification 03' => {
        message => q|Occasional|,
        lastUpdated => 1247110533,
    },

    'customer classification 04' => {
        message => q|Retail|,
        lastUpdated => 1247110533,
    },

    'flatFee' => {
        message => q|Flat Fee|,
        lastUpdated => 1241214572,
        context => q|A fixed amount of money added to a purchase for shipping.|,
    },

    'flatFee help' => {
        message => q|A fixed amount of money added to a purchase for shipping, covering shipping materials and handling.|,
        lastUpdated => 1241214575,
    },

    'us domestic 01' => {
        message => q|UPS Next Day Air|,
        lastUpdated => 1203569511,
        context => q|Label for a type of shipping from the UPS.|,
    },

    'us domestic 02' => {
        message => q|UPS Second Day Air|,
        lastUpdated => 1203569511,
        context => q|Label for a type of shipping from the UPS.|,
    },

    'us domestic 03' => {
        message => q|UPS Ground|,
        lastUpdated => 1242166045,
        context => q|Label for a type of shipping from the UPS.|,
    },

    'us domestic 12' => {
        message => q|UPS Three-Day Select|,
        lastUpdated => 1203569511,
        context => q|Label for a type of shipping from the UPS.|,
    },

    'us domestic 13' => {
        message => q|UPS Next Day Air Saver|,
        lastUpdated => 1203569511,
        context => q|Label for a type of shipping from the UPS.|,
    },

    'us domestic 14' => {
        message => q|UPS Next Day Air Early A.M.|,
        lastUpdated => 1242166045,
        context => q|Label for a type of shipping from the UPS.|,
    },

    'us domestic 59' => {
        message => q|UPS Second Day Air A.M.|,
        lastUpdated => 1203569511,
        context => q|Label for a type of shipping from the UPS.|,
    },

    'pickup code 01' => {
        message => q|Daily Pickup|,
        lastUpdated => 1242166045,
        context => q|Label for a type of shipping from the UPS.|,
    },

    'pickup code 03' => {
        message => q|Customer Counter|,
        lastUpdated => 1242166045,
        context => q|Label for a type of shipping from the UPS.|,
    },

    'pickup code 06' => {
        message => q|One Time Pickup|,
        lastUpdated => 1242166045,
        context => q|Label for a type of shipping from the UPS.|,
    },

    'pickup code 07' => {
        message => q|On Call Air|,
        lastUpdated => 1242166045,
        context => q|Label for a type of shipping from the UPS.|,
    },

    'pickup code 11' => {
        message => q|Suggested Retail Rates|,
        lastUpdated => 1242166045,
        context => q|Label for a type of shipping from the UPS.|,
    },

    'pickup code 19' => {
        message => q|Letter Center|,
        lastUpdated => 1242166045,
        context => q|Label for a type of shipping from the UPS.|,
    },

    'pickup code 20' => {
        message => q|Air Service Center|,
        lastUpdated => 1242166045,
        context => q|Label for a type of shipping from the UPS.|,
    },

    'us domestic' => {
        message => q|US Domestic|,
        lastUpdated => 1242166045,
        context => q|Label for a type of shipping from the UPS.|,
    },

    'us international' => {
        message => q|US International|,
        lastUpdated => 1242166045,
        context => q|Label for a type of shipping from the UPS.|,
    },

    'ship type' => {
        message => q|Shipping Type|,
        lastUpdated => 1242166045,
        context => q|Label for a type of shipping from the UPS.|,
    },

    'ship type help' => {
        message => q|Pick a type of shipping that will be used.  The different types have different services available.  Not all services are available in all types, or in all countries.  Changing the service will change the Ship Service options below.|,
        lastUpdated => 1247111015,
        context => q|Label for a type of shipping from the UPS.|,
    },

    'us international 07' => {
        message => q|UPS Worldwide Express|,
        lastUpdated => 1203569511,
        context => q|Label for a type of shipping from the UPS.|,
    },

    'us international 08' => {
        message => q|UPS Worldwide Expedited|,
        lastUpdated => 1203569511,
        context => q|Label for a type of shipping from the UPS.|,
    },

    'us international 11' => {
        message => q|UPS Standard|,
        lastUpdated => 1242166045,
        context => q|Label for a type of shipping from the UPS.|,
    },

    'us international 54' => {
        message => q|UPS Worldwide Express Plus|,
        lastUpdated => 1242166045,
        context => q|Label for a type of shipping from the UPS.|,
    },

    'us international 65' => {
        message => q|UPS Saver|,
        lastUpdated => 1242166045,
        context => q|Label for a type of shipping from the UPS.|,
    },

    'UPS' => {
        message => q|UPS|,
        lastUpdated => 1242166045,
        context => q|Label for the plugin, the acronym United Parcel Service|,
    },

};

1;
