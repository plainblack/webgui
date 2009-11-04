package WebGUI::i18n::English::ShipDriver_USPS;

use strict;

our $I18N = {

    'userid' => {
        message => q|USPS Web Tools Username|,
        lastUpdated => 1203569535,
        context => q|Label in the ShipDriver edit form.|,
    },

    'userid help' => {
        message => q|You can get a Web Tools Username by first registering with the USPS.|,
        lastUpdated => 1203569511,
    },

    'password' => {
        message => q|USPS Web Tools Password (optional)|,
        lastUpdated => 1203569535,
        context => q|Label in the ShipDriver edit form.|,
    },

    'password help' => {
        message => q|You will recieve a password along with your username when you register.|,
        lastUpdated => 1203569511,
    },

    'instructions' => {
        message => q|Registration Instructions|,
        lastUpdated => 1203569535,
        context => q|Label in the ShipDriver edit form.|,
    },

    'usps instructions' => {
        lastUpdated => 1241028258,
        message => q|<p>In order to use the USPS Shipping Driver, you must first register with the United States Postal Service as a <a href="https://secure.shippingapis.com/registration/">USPS Web Tools User</a>.  Fill out the form, submit it, and within a few days the USPS will send you a username and password to use this service.  Enter your username and password in the form fields below.</p><p>This driver supports three kinds of shipping with one preset size for each kind.  Package sizes, and shipping services outside of those choices, are currently not supported.</p><p>For the purpose of calculating weight, the weight property of a Product is considered to be in pounds.|,
    },

    'ship type' => {
        message => q|Shipping type|,
        lastUpdated => 1203569535,
        context => q|Label in the ShipDriver edit form.|,
    },

    'ship type help' => {
        message => q|Select one from the list of options.  If you wish to provide multiple types of shipping, create one additional shipping driver instance for each option.|,
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

    'flatFee' => {
        message => q|Flat Fee|,
        lastUpdated => 1241214572,
        context => q|A fixed amount of money added to a purchase for shipping.|,
    },

    'flatFee help' => {
        message => q|A fixed amount of money added to a purchase for shipping, covering shipping materials and handling.|,
        lastUpdated => 1241214575,
    },

    'priority' => {
        message => q|Priority, Flat Rate Box|,
        lastUpdated => 1203569511,
        context => q|Label for a type of shipping from the USPS.|,
    },

    'priority variable' => {
        message => q|Priority, Custom box|,
        lastUpdated => 1203569511,
        context => q|Label for a type of shipping from the USPS.|,
    },

    'express' => {
        message => q|Express, Regular size|,
        lastUpdated => 1203569511,
        context => q|Label for a type of shipping from the USPS.|,
    },

    'parcel post' => {
        message => q|Parcel Post, Regular size|,
        lastUpdated => 1242166045,
        context => q|Label for a type of shipping from the USPS.|,
    },

    'add insurance' => {
        message => q|Ship with insurance?|,
        lastUpdated => 1253988886,
        context => q|Label for the edit screen.|,
    },

    'add insurance help' => {
        message => q|If set to yes, the shipping plugin will ask the USPS for the cost of insuring this shipment.  The cost will be added to the total cost of shipping.  If insurance is not available, then the option to use this driver will not be presented to the user.|,
        lastUpdated => 1253988884,
        context => q|Label for a type of shipping from the USPS.|,
    },

    'insurance rates' => {
        message => q|Insurance Rate Table|,
        lastUpdated => 1253988886,
        context => q|Label for the edit screen.|,
    },

    'insurance rates help' => {
        message => q|Enter in one field per line with the format, value:cost.<br />value is the value of the contents.<br />cost is the cost of insurance at that value.<br />value and cost should look like numbers with a decimal point, like 0.50 or 1.00.<br />For values of contents inbetween points, use the next highest value.  If the value of the contents exceeds the highest listed value, it will use the cost of insurance at the highest listed value.|,
        lastUpdated => 1257369016,
        context => q|Help for the insurance rate field.|,
    },

};

1;
