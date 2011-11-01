package WebGUI::i18n::English::PayDriver_CreditCard;
use strict;

our $I18N = {
    'cardNumber' => {
        message => q|Credit card number|,
        lastUpdated => 1101772177,
        context => q|Form label in the checkout form of the Credit Card module.|
    },
    'credentials template' => {
        message => q|Credentials Template|,
        lastUpdated => 0,
        context => q|Form label in the configuration form of the Credit Card module.|
    },
    'credentials template help' => {
        message => q|Pick a template to display the form where the user will enter in their billing information and credit card information.|,
        lastUpdated => 0,
        context => q|Hover help for the credentials template field in the configuration form of the Credit Card module.|
    },
    'cvv2' => {
        message => q|Verification number (ie. CVV2)|,
        lastUpdated => 1101772182,
        context => q|Form label in the checkout form of the Credit Card module.|
    },
    'error occurred message' => {
        message => q|The following errors occurred:|,
        lastUpdated => 0,
        context => q|The message that tell the user that there were some errors in their submitted credentials.|,
    },
    'expiration date' => {
        message => q|Expiration date|,
        lastUpdated => 1101772180,
        context => q|Form label in the checkout form of the Credit Card module.|
    },
    'expired expiration date' => {
        message => q|The expiration date on your card has already passed.|,
        lastUpdated => 0,
        context => q|An error indicating that an an expired card was used.|
    },
    'invalid firstName' => {
        message => q|You have to enter a valid first name.|,
        lastUpdated => 0,
        context => q|An error indicating that an invalid first name has been entered.|
    },
    'invalid lastName' => {
        message => q|You have to enter a valid last name.|,
        lastUpdated => 0,
        context => q|An error indicating that an invalid last name has been entered.|
    },
    'invalid address' => {
        message => q|You have to enter a valid address.|,
        lastUpdated => 0,
        context => q|An error indicating that an invalid street has been entered.|
    },
    'invalid city' => {
        message => q|You have to enter a valid city.|,
        lastUpdated => 0,
        context => q|An error indicating that an invalid city has been entered.|
    },
    'invalid zip' => {
        message => q|You have to enter a valid zipcode.|,
        lastUpdated => 0,
        context => q|An error indicating that an invalid zipcode has been entered.|
    },
    'invalid email' => {
        message => q|You have to enter a valid email address.|,
        lastUpdated => 0,
        context => q|An error indicating that an invalid email address has been entered.|
    },
    'invalid card number' => {
        message => q|You have to enter a valid credit card number.|,
        lastUpdated => 0,
        context => q|An error indicating that an invalid credit card number has been entered.|
    },
    'invalid cvv2' => {
        message => q|You have to enter a valid card security code (ie. cvv2).|,
        lastUpdated => 0,
        context => q|An error indicating that an invalid card security code has been entered.|
    },
    'invalid expiration date' => {
        message => q|You have to enter a valid expiration date.|,
        lastUpdated => 0,
        context => q|An error indicating that an invalid expiration date has been entered.|
    },
    'template gone' => {
        message => q|The template for entering in credentials has been deleted.  Please notify the site administrator.|,
        lastUpdated => 0,
        context => q|Error message when the getCredentials template cannot be accessed.|
    },
    'use cvv2' => {
        message => q|Use CVV2|,
        lastUpdated => 0,
        context => q|Form label in the configuration form of the Credit Card module.|
    },
    'use cvv2 help' => {
        message => q|Set this option to yes if you want to use CVV2.|,
        lastUpdated => 0,
        context => q|Form label in the configuration form of the Credit Card module.|
    },

    'edit credentials template' => {
        message => q|Edit Credentials Template|,
        lastUpdated => 0,
        context => q|Title of the help page.|
    },
    'edit credentials template help' => {
        message => q|This template is used to display a form to the user where they can enter in contact and credit card billing information.|,
        lastUpdated => 0,
        context => q|Title of the help page.|
    },

    'errors help' => {
        message     => q{A template loop containing a list of errors from processing the form.},
        lastUpdated => 0,
        context     => q{Template variable help.},
    },
    'error help' => {
        message     => q{One error from the errors loop.  It will have minimal markup.},
        lastUpdated => 0,
        context     => q{Template variable help.},
    },
    'addressField help' => {
        message     => q{A single text field for the user to enter in their street address.},
        lastUpdated => 0,
        context     => q{Template variable help.},
    },
    'emailField help' => {
        message     => q{A single text field for the user to enter in their email address.},
        lastUpdated => 1231192368,
        context     => q{Template variable help.},
    },
    'cardNumberField help' => {
        message     => q{A single text field for the user to enter in their credit card number.},
        lastUpdated => 0,
        context     => q{Template variable help.},
    },
    'monthYearField help' => {
        message     => q{A combination form field for the user to enter in the month and year of the expiration date for the credit card.},
        lastUpdated => 0,
        context     => q{Template variable help.},
    },
    'cvv2Field help' => {
        message     => q{A single text field for the user to enter in their credit card verification number.  If the PayDriver is not configured to use CVV2, then this field will be empty.},
        lastUpdated => 0,
        context     => q{Template variable help.},
    },
    'checkoutButton help' => {
        message     => q{A button with an internationalized label to submit the form and continue the checkout process.},
        lastUpdated => 0,
        context     => q{Template variable help.},
    },
    
    'fields help' => {
        message => q{A loop of all the available fields for convenience.  Each
entry in the loop contains name (field name), label (an internationalized
label for the field), and field (the same as in stateField, cityField, etc).},
        lastUpdated => 0,
    },
};

1;
