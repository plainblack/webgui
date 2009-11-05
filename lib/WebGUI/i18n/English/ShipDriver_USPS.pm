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
        lastUpdated => 1257399744,
        message => q|<p>In order to use the USPS Shipping Driver, you must first register with the United States Postal Service as a <a href="https://secure.shippingapis.com/registration/">USPS Web Tools User</a>.  Fill out the form, submit it, and within a few days the USPS will send you a username and password to use this service.  After receiving your username, call 1-800-344-7779 to have the USPS authorize your username.  Enter your username and password in the form fields below.</p><p>This driver supports three kinds of shipping with one preset size for each kind.  Package sizes, and shipping services outside of those choices, are currently not supported.</p><p>For the purpose of calculating weight, the weight property of a Product is considered to be in pounds.|,
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

};

1;
