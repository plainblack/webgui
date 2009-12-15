package WebGUI::i18n::English::TaxDriver_EU;

our $I18N = {

    'vat number invalid' => {
        message => q|The entered VAT number is invalid.|,
        lastUpdated => 0,
        context => q|An error message|,
    },

    'vies unavailable' => {
        message => q|Number validation is currently not available. Your number will be rechecked automatically
after some time.|,
        lastUpdated => 0,
        context => q|An error message|,
    },

    'select country' => {
        message => q|select a country|,
        lastUpdated => 0,
        context => q|Option of a select list in admin screen|,
    },

    'shop country' => {
        message => q|Residential country|,
        lastUpdated => 0,
        context => q|Form label in admin screen|,
    },

    'shop country help' => {
        message => q|Select the country where your shop resides. If your country does not appear in the select list, your country does not reside within the European Union and you cannot use this tax plugin.|,
        lastUpdated => 0,
        context => 'Hover help in the admin screen',
    },

    'user template' => {
        message => q|User screen template|,
        lastUpdated => 0,
        context => 'Form label in admin screen',
    },

    'user template help' => {
        message => q|The template for the user screen where users can enter their VAT numbers.|,
        lastUpdated => 0,
        context => 'Hover help in the admin screen',
    },

    'auto vies approval' => {
        message => q|Automatic VIES approval?|,
        lastUpdated => 0,
        context => 'Form label in admin screen',
    },

    'auto vies approval help' => {
        message => q|If you set this to yes, VAT numbers that are validated through the VIES service are directly usable by your customers. If set to no, only VAT numbers that have been explicitly approved by you are usable.|,
        lastUpdated => 1250796443,
        context => 'Hover help in the admin screen',
    },

    'accept when vies unavailable' => {
        message => q|Accept non-validated VAT numbers when VIES is unavailable?|,
        lastUpdated => 1250796458,
        context => 'Form label in admin screen',
    },

    'accept when vies unavailable help' => {
        message => q|If one of the VIES member states' databases is temporarily unavailable or the connection to VIES failed VAT numbers cannot be checked through this service. Normally this is a temporary problem. If you set this option to yes VAT numbers that could not be checked because of such an event are usable anyway. Note that the format of VAT numbers is always checked, regardless of the availability of VIES.|,
        lastUpdated => 1248190913,
        context => 'Hover help in the admin screen',
    },

    'group name' => {
        message => q|Group name|,
        lastUpdated => 0,
        context => q|Label for the group name column in the VAT group manager|,
    },

    'rate' => {
        message => q|Rate|,
        lastUpdated => 0,
        context => q|Label for the group rate column in the VAT group manager|,
    },

    'add vat group' => {
        message => q|Add a VAT group|,
        lastUpdated => 0,
        context => q|Label in the VAT group manager|,
    },

    'general configuration' => {
        message => q|General configuration|,
        lastUpdated => 0,
        context => 'Tab label in admin screen',
    },

    'vat groups' => {
        message => 'VAT Groups',
        lastUpdated => 0,
        context => 'Tab label in admin screen',
    },

    'vat numbers' => {
        message => 'VAT Numbers',
        lastUpdated => 0,
        context => 'Tab label in admin screen',
    },

    'default group' => {
        message => q|Default group|,
        lastUpadated => 0,
        context => q|Flag in VAT group manager|,
    },

    'make default' => {
        message => q|Make default|,
        lastUpdated => 0,
        context => q|Button label in VAT group manager|,
    },

    'delete group' => {
        message => q|Delete|,
        lastUpdated => 0,
        context => q|Button label in VAT group manager|,
    },

    'user' => {
        message => q|User|,
        lastUpdated => 0,
        context => q|Label in the VAT number manager|,
    },

    'vat number' => {
        message => q|VAT number|,
        lastUpdated => 0,
        context => q|Label in the VAT number manager|,
    },

    'vies validated' => {
        message => q|VIES validated|,
        lastUpdated => 0,
        context => q|Label in the VAT number manager|,
    },

    'vies error code' => {
        message => q|VIES error code|,
        lastUpdated => 0,
        context => q|Label in the VAT number manager|,
    },

    'approve' => {
        message => q|Approve|,
        lastUpdated => 0,
        context => q|Button label in the VAT number manager|,
    },

    'deny' => {
        message => q|Deny|,
        lastUpdated => 0,
        context => q|Button label in the VAT number manager|,
    },

    'add' => {
        message => q|Add|,
        lastUpdated => 0,
        context => q|Button label in the user screen|,
    },

    'vat group' => {
        message => q|VAT group|,
        lastUpdated => 0,
        context => q|Label in the SKU edit form|,
    },

    'illegal country code' => {
        message => q|Illegal country code|,
        lastUpdated => 0,
        context => q|Error message on adding vat number|,
    },

    'already has vat number' => {
        message => q|You have already registered a VAT number for this country.|,
        lastUpdated => 0,
        context => q|Error message on adding vat number|,
    },


};

1;
    
