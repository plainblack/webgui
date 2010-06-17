package WebGUI::i18n::English::PayDriver_Ogone;
use strict;

our $I18N = { 
    'Ogone' => {
        message => q|Ogone|,
        lastUpdated => 0,
        context => q|The name of the Ogone plugin|,
    },

    'psp id' => {
        message => q|PSP ID|,
        lastUpdated => 0,
        context => q|Label of a setting in the ogone config screen.|,
    },

    'psp id help' => {
        message => q|Your ogone username|,
        lastUpdated => 0,
        context => q|Hover help of a setting in the ogone config screen.|,
    },

    'sha secret' => {
        message => q|Pre payment SHA secret (option 3.2)|,
        lastUpdated => 0,
        context => q|Label of a setting in the ogone config screen.|,
    },

    'sha secret help' => {
        message => q|The passphrase you set in section 3.2 in the Technical information page of the Ogone interface.|,
        lastUpdated => 0,
        context => q|Hover help of a setting in the ogone config screen.|,
    },

    'postback secret' => {
        message => q|Post payment SHA secret (option 4.4)|,
        lastUpdated => 0,
        context => q|Label of a setting in the ogone config screen.|,
    },

    'postback secret help' => {
        message => q|The passphrase you set in section 4.4 in the Technical information page of the Ogone interface.|,
        lastUpdated => 0,
        context => q|Hover help of a setting in the ogone config screen.|,
    },

    'locale' => {
        message => q|Ogone language|,
        lastUpdated => 0,
        context => q|Label of a setting in the ogone config screen.|,
    },

    'locale help' => {
        message => q|The locale string for the language the Ogone interface should be displayed in to the user (eg. nl_NL or en_US) |,
        lastUpdated => 0,
        context => q|Hover help of a setting in the ogone config screen.|,
    },

    'currency' => {
        message => q|Currency (ISO Alpha code)|,
        lastUpdated => 1250796737,
        context => q|Label of a setting in the ogone config screen.|,
    },

    'currency help' => {
        message => q|The currency in which the payment are to be made. Enter the ISO Alpha code. Commonly used codes are EUR for Euro, USD for US Dollar, CHF for Swiss Franks and GBP for Brittish Pounds. See http://en.wikipedia.org/wiki/ISO_currency_code#Active_codes for a complete list.|,
        lastUpdated => 0,
        context => q|Hover help of a setting in the ogone config screen.|,
    },

    'use test mode' => {
        message => q|Use in test mode?|,
        lastUpdated => 0,
        context => q|Label of a setting in the ogone config screen.|,
    },

    'use test mode help' => {
        message => q|Setting this option to yes directs all payment requests to Ogone's test environment. This allows you to check if everything is set up correctly before going live. No actual payments are being made while test mode is enabled, so don't forget to set this option to 'No' when you are finished testing.|,
        lastUpdated => 1250796785,
        context => q|Hover help of a setting in the ogone config screen.|,
    },

    'pay' => {
        message => q|Pay|,
        lastUpdated => 0,
        context => q|Label of the pay button.|,
    },

    'choose billing address' => {
        message => q|Choose billing address|,
        lastUpdated => 0,
        context => q|Label of the choose address button.|,
    },

    'please choose a billing address' => {
        message => q|Please choose a billing address.|,
        lastUpdated => 0,
        context => q|Status message|,
    },

    'ogone setup' => {
        message => q|
            <p>In order to use this plugin you need to set up Ogone as well. Please go to the Techincal Information
            page in the Ogone admin interface and set the properties listed below. Always start in test mode and
            check if everything work alright. When switching to production mode, don't forget to apply the option
            below to your production account as well.</p>
            <ul>
            <li>
                <b>4.1 Urls:</b>Set to <i>%s</i>
            </li>
            <li>
                <b>4.2 Request type:</b> Set to 'Make this request just after the payment and let the result
                customize the answer seen by customer (HTML code or redirection)'
            </li>
            <li>
                <b>4.4 SHA Signature:</b> Set to the exact sam value as entered above.
            </li>
            <li>
                <b>4.5 Redirection URL's:</b> Make sure the box is checked.
            </li>
            <li>
                <b>7.1 Warn:</b> Set to 'only at the authorisation request of the order'.
            </li>
            <li>
                <b>7.2 How:</b> Select 'Email and http request'. <br /><b>Url for offline httpRequests</b> Set to
                <i>%s</i>
            </li>
            </ul>|,
        lastUpdated => 0,
        context => q|Text that describes the required Ogone settings.|,
    },
};

1;

