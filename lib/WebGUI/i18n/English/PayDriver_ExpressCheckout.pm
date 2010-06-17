package WebGUI::i18n::English::PayDriver_ExpressCheckout;

use strict;

our $I18N = {
    'api' => { 
        message     => q{API URL},
        lastUpdated => 1247254043,
    },
    'api error' => { 
        message     => q{Error communicating with PayPal API: %s},
        lastUpdated => 1247496228,
        context     => q{Error message to display on internal error talking to paypal},
    },
    'api help' => { 
        message     => q{Base URL for PayPal's NVP api},
        lastUpdated => 1247254068,
    },
    'apiSandbox' => { 
        message     => q{API Sandbox URL},
        lastUpdated => 1247499398,
    },
    'apiSandbox help' => { 
        message     => q{URL for Paypal API in test mode},
        lastUpdated => 1247499415,
    },
    'currency' => { 
        message     => q{Currency Code},
        lastUpdated => 1247253894,
    },
    'currency help' => { 
        message     => q{Paypal currency code to use (e.g. USD)},
        lastUpdated => 1247253924,
    },
    'internal paypal error' => { 
        message     => q{Internal PayPal Error},
        lastUpdated => 1247524131,
        context     => q{Message to display when something goes wrong talking to PayPal},
    },
    'name' => { 
        message     => q{PayPal Express Checkout},
        lastUpdated => 1247256412,
        context     => q{The name of the payment driver},
    },
    'password' => { 
        message     => q{Password},
        lastUpdated => 1247254156,
    },
    'password help' => { 
        message     => q{Password from PayPal credentials},
        lastUpdated => 1247254172,
    },
    'payment status' => { 
        message     => q{Payment Status: %s},
        lastUpdated => 1247524208,
        context     => q{Message to be used in receipt page as gateway message.  Placeholder is for the actual status.},
    },
    'paypal' => { 
        message     => q{Paypal URL},
        lastUpdated => 1247498678,
    },
    'paypal help' => { 
        message     => q{URL to use when redirecting to paypal},
        lastUpdated => 1247498700,
    },
    'sandbox' => { 
        message     => q{Sandbox URL},
        lastUpdated => 1247498780,
    },
    'sandbox help' => { 
        message     => q{URL to use for redirecting to paypal in test mode},
        lastUpdated => 1247498766,
    },
    'signature' => { 
        message     => q{Signature},
        lastUpdated => 1247254180,
    },
    'signature help' => { 
        message     => q{Signature from PayPal credentials},
        lastUpdated => 1247254195,
    },
    'testMode' => { 
        message     => q{Test Mode},
        lastUpdated => 1247253942,
    },
    'testMode help' => { 
        message     => q{Whether to use PayPal's sandbox},
        lastUpdated => 1247253981,
    },
    'user' => { 
        message     => q{Username},
        lastUpdated => 1247254097,
    },
    'user help' => { 
        message     => q{Username from Paypal credentials},
        lastUpdated => 1247254128,
    },
};

1;

#vim:ft=perl
