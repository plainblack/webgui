package WebGUI::i18n::English::Asset_Subscription;
use strict;

our $I18N = {
    'assetName' => {
        message => q|Subscription|,
        lastUpdated => 0,
        context => q|The name of the subscription asset|,
    },

	'expire subscription codes' => {
		message => q|Expire Subscription Codes|,
		lastUpdated => 0,
		context => q|the title of the expire subscription codes workflow activity|
	},

	'no subscription code batches' => {
		message => q|No subscription code batches have been created yet. Use the submenu on the right to generate a batch.|,
		lastUpdated => 1101228391,
		context => q|Displayed if no subscription code batches have been created|
	},

	'listSubscriptionCodes title' => {
		message => q|Manage Subscription Codes|,
		lastUpdated => 1101228391,
		context => q|Title of listSubscriptionCodes.|
	},

	'batch id' => {
		message => q|BatchId|,
		lastUpdated => 1101228391,
		context => q|Shows up in the table header in listSubscriptionCodes.|
	},

	'subscription description' => {
		message => q|Description|,
		lastUpdated => 1101228391,
		context => q|Form label in editSubscription|
	},

	'manage codes' => {
		message => q|Manage subscription codes|,
		lastUpdated => 1101228391,
		context => q|A submenu option in the Subscriptions Admin Console menu.|
	},

	'delete subscription confirm' => {
		message => q|Are you sure to delete this subscription?|,
		lastUpdated => 1101754598,
		context => q|Confirmation question when deleting a subscription.|
	},

	'subscriptionId' => {
		message => q|Subscription Id|,
		lastUpdated => 1101228391,
		context => q|Just leave it Subscription Id.|
	},

	'generate batch' => {
		message => q|Generate a batch of subscription codes|,
		lastUpdated => 1101228391,
		context => q|A submenu option in the Subscriptions Admin Console menu.|
	},

	'subscription name' => {
		message => q|Subscription name|,
		lastUpdated => 1101228391,
		context => q|Form label in editSubscription|
	},

	'code' => {
		message => q|Code|,
		lastUpdated => 1101228391,
		context => q|Shows up in the table header in listSubscriptionCodes.|
	},

	'code description' => {
		message => q|The subscription code that you want to redeem|,
		lastUpdated => 1101228391,
	},

	'delete batch confirm' => {
		message => q|Are you sure to delete this batch?|,
		lastUpdated => 1101228391,
		context => q|Confirmation question when deleting a code batch.|
	},

	'selection used' => {
		message => q|date of usage between|,
		lastUpdated => 1101228391,
		context => q|Shows up in the selection part of listSubscriptionCodes.|
	},

	'batch description' => {
		message => q|Batch description|,
		lastUpdated => 1101228391,
		context => q|Form option in createSubscriptionCodeBatch.|
	},

	'redeem code' => {
		message => q|Redeem a subscription code.|,
		lastUpdated => 1101228391,
		context => q|The title of the URL in displayLogin that points to code redemption.|
	},

	'selection message' => {
		message => q|You can make a selection of codes by:|,
		lastUpdated => 1101228391,
		context => q|Shows up in the selection part of listSubscriptionCodes.|
	},

        'subscription name description' => {
                message => q|<p>Name of the subscription.</p>|,
                lastUpdated => 1120861450,
        },

        'subscription price description' => {
                message => q|<p>Price to pay for the subscription.</p>|,
                lastUpdated => 1120861450,
        },

        'useSalesTax' => {
                message => q|Use Sales Tax?|,
                lastUpdated => 1159845025,
        },

        'useSalesTax description' => {
                message => q|Should this subscription have sales tax applied to it?|,
                lastUpdated => 1159845045,
        },

        'subscription description description' => {
                message => q|<p>Detailed description of the subscription.</p>|,
                lastUpdated => 1120861450,
        },

        'subscription group description' => {
                message => q|<p>When a user paid the fee, he/she will be added to this group.</p>|,
                lastUpdated => 1167190387,
        },

        'subscription duration description' => {
                message => q|<p>This sets the length of one subscription term. ie. You pay every month, or every half year.</p>|,
                lastUpdated => 1120861450,
        },

        'execute on subscription description' => {
                message => q|<p>A (Perl) script to call when someone has subscribed and paid.</p>|,
                lastUpdated => 1167190394,
        },

        'subscription karma description' => {
                message => q|<p>The amount of karma which is added to the user after he/she subscribes.</p>|,
                lastUpdated => 1120861450,
        },

	'codes expire' => {
		message => q|Codes expire after|,
		lastUpdated => 1101228392,
		context => q|Form option in createSubscriptionCodeBatch.|
	},

	'no association error' => {
		message => q|You have to associate this batch to at least one subscription.|,
		lastUpdated => 1101228391,
		context => q|An error that cab occur when creating a code batch.|
	},

	'subscription duration' => {
		message => q|Subscription period|,
		lastUpdated => 1101228391,
		context => q|Form label in editSubscription|
	},

	'creation date' => {
		message => q|Creation date|,
		lastUpdated => 1101228391,
		context => q|Shows up in the table header in listSubscriptionCodes.|
	},

	'and' => {
		message => q|and|,
		lastUpdated => 1101228391,
		context => q|Shows up in the selection part of listSubscriptionCodes.|
	},

	'subscription group' => {
		message => q|Subscribe to group|,
		lastUpdated => 1101228391,
		context => q|Form label in editSubscription|
	},

	'manage subscriptions' => {
		message => q|Subscriptions (beta)|,
		lastUpdated => 1101228391,
		context => q|A submenu option in the Subscriptions Admin Console menu.|
	},

	'execute on subscription' => {
		message => q|Execute on subscription|,
		lastUpdated => 1101228391,
		context => q|Form label in editSubscription|
	},

	'status' => {
		message => q|Status|,
		lastUpdated => 1101228391,
		context => q|Shows up in the table header in listSubscriptionCodes.|
	},

	'noc' => {
		message => q|Number of codes in batch|,
		lastUpdated => 1101228391,
		context => q|Form option in createSubscriptionCodeBatch.|
	},

	'selection created' => {
		message => q|date of creation between|,
		lastUpdated => 1101228391,
		context => q|Shows up in the selection part of listSubscriptionCodes.|
	},

	'display all' => {
		message => q|display all|,
		lastUpdated => 1216612381,
		context => q|Shows up in the selection part of listSubscriptionCodes.|
	},

	'manage batches' => {
		message => q|Manage subscription code batches|,
		lastUpdated => 1101228391,
		context => q|A submenu option in the Subscriptions Admin Console menu.|
	},

	'association' => {
		message => q|Associate with subscription|,
		lastUpdated => 1101228391,
		context => q|Form option in createSubscriptionCodeBatch.|
	},

	'no description error' => {
		message => q|You must enter a description.|,
		lastUpdated => 1101228391,
		context => q|An error that cab occur when creating a code batch.|
	},

	'subscription price' => {
		message => q|Price|,
		lastUpdated => 1101228391,
		context => q|Form label in editSubscription|
	},

	'dateUsed' => {
		message => q|Date of usage|,
		lastUpdated => 1101228391,
		context => q|Shows up in the table header in listSubscriptionCodes.|
	},

	'create batch error' => {
		message => q|An error has occurred:|,
		lastUpdated => 1101754822,
		context => q|Identifies an error in createSubscriptionCodeBatch.|
	},

	'select' => {
		message => q|Show selection|,
		lastUpdated => 1101228391,
		context => q|Shows up in the selection part of listSubscriptionCodes.|
	},

	'edit subscription title' => {
		message => q|Edit Subscription|,
		lastUpdated => 1101228391,
		context => q|Form label in editSubscription|
	},

	'add subscription' => {
		message => q|Add a new subscription|,
		lastUpdated => 1101228391,
		context => q|A submenu option in the Subscriptions Admin Console menu.|
	},

	'list codes in batch' => {
		message => q|List the codes in this batch|,
		lastUpdated => 1101228391,
		context => q|In listSubscriptionCodeBatches|
	},

	'delete codes' => {
		message => q|Delete all these codes.|,
		lastUpdated => 1216673469,
		context => q|Shows up in listSubscriptionCodes.|
	},

	'subscription karma' => {
		message => q|Karma|,
		lastUpdated => 1101228391,
		context => q|Form label in editSubscription|
	},

	'create batch menu' => {
		message => q|Create a batch of subscription codes|,
		lastUpdated => 1101228391,
		context => q|Menu name for createSubscriptionCodeBatch.|
	},

        'noc description' => {
                message => q|<p>Number of codes to create</p>|,
                lastUpdated => 1120858265,
        },

        'code length description' => {
                message => q|<p>The number of characters in the generated codes.  Codes must be at least 10
characters long.</p>|,
                lastUpdated => 1120858265,
        },

        'codes expire description' => {
                message => q|<p>The code must be used before this date.</p>|,
                lastUpdated => 1132353871,
        },

        'association description' => {
                message => q|<p>Which subscription(s) are made with the generated codes.</p>|,
                lastUpdated => 1120858265,
        },

        'batch description description' => {
                message => q|Description of the batch.|,
                lastUpdated => 1120858265,
        },

	'no subscriptions' => {
		message => q|There are no subscriptions yet. You can add subscriptions by using the 'Add Subscription' option in the menu on the right of the screen.|,
		lastUpdated => 0,
		context => q|A message that shows up in manage subscriptions indicating that there are no subscriptions at all.|
	},

	'redeem code success' => {
		message => q|You've successfully subscribed to the subscriptions. You can enter another code below.|,
		lastUpdated => 0,
		context => q|The success message for the code redemption function.|
	},
	'redeem code failure' => {
		message => q|You've entered a code that's wrong, already being used or expired. Please enter another code below.|,
		lastUpdated => 1101754837,
		context => q|The failure message for the code redemption function.|
	},
	'redeem code ask for code' => {
		message => q|Please enter your subscription code below.|,
		lastUpdated => 0,
		context => q|The enter a code message for the code redemption function.|
	},

	'selection batch name' => {
		message => q|batch name|,
		lastUpdated => 0,
		context => q|Shows up in the selection part of listSubscriptionCodes.|
	},

    'batchDescription' => {
        message => q|The description of the batch tied to the subscription code.|,
        context => q|Template variable in the redeem subscription code template|,
        lastUpdated => 0,
    },

    'message' => {
        message => q|The message that gives the result of your action. Depending on what you've done it says that you can enter a code, you've entered the wrong code, or you've successfully redeemed your code.|,
        context => q|Template variable in the redeem subscription code template|,
        lastUpdated => 0,
    },

    'codeForm' => {
        message => q|The form in which the user can enter his subscription code.|,
        context => q|Template variable in the redeem subscription code template|,
        lastUpdated => 0,
    },

	'help redeem code template title' => {
		message => q|Redeem subscription code template|,
		lastUpdated => 1101754848,
		context => q|The title of the help page of the code redemption template.|
	},

	'code length' => {
		message => q|Subscription code length|,
		lastUpdated => 1102660410,
		context => q|The label of the form field in which the length of a subscription code is entered.|
	},
	'code length error' => {
		message => q|You must enter a subscription code length between 10 and 64 (border values included).|,
		lastUpdated => 0,
		context => q|The error message that shows up when a wrong code length is specified.|
	},

	'topicName' => {
		message => q|Subscriptions|,
		lastUpdated => 1128920064,
	},

    'purchase button' => {
        message => q|Add to cart|,
        lastUpdates => 0,
        context => q|The label on the add to cart button|,
    },

    'default thank you message' => {
		message => q|The subscription has been added to the cart.|,
		lastUpdated => 1254256971,
		context => q|the default message that will go in the thank you message field|,
	},

	'thank you message' => {
		message => q|Thank You Message|,
		lastUpdated => 0,
		context => q|the label for the field where you type in teh message shown when a subscription is purchased|,
	},

	'thank you message help' => {
		message => q|Use this field to define the message that informs users that they've just put a subscription into the cart. Please note that the subscription will not be applied until the user checks out.|,
		lastUpdated => 0,
		context => q|help for the thank you message field|,
	},

	'template' => {
		message => q|Subscription template|,
		lastUpdated => 0,
		context => q|Asset property|,
	},

	'template help' => {
		message => q|Choose the template you wish to use to display this subscription|,
		lastUpdated => 0,
		context => q|Asset property hover help|,
	},

	'redeem subscription code template' => {
		message => q|Redeem Subscription template|,
		lastUpdated => 0,
		context => q|Asset property|,
	},

	'redeem subscription code template help' => {
		message => q|Choose the template that is used to display the screen where users redeem subscription codes.|,
		lastUpdated => 0,
		context => q|Asset property hover help|,
	},

	'batch name' => {
		message => q|Batch Name|,
		lastUpdated => 0,
		context => q|create subscription code form|,
	},

	'batch name description' => {
		message => q|Select a name for this batch of subscription codes.|,
		lastUpdated => 0,
		context => q|hover help for batch name|,
	},

	'subscription template' => {
		message => q|Subscription Template|,
		lastUpdated => 0,
		context => q|Title for the subscription template help page|,
	},

	'formHeader' => {
		message => q|The top of the subscription form.|,
		lastUpdated => 0,
		context => q|template variable|
	},

	'formFooter' => {
		message => q|The bottom of the subscription form.|,
		lastUpdated => 0,
		context => q|template variable|
	},

	'purchaseButton' => {
		message => q|The button for the subscription form.|,
		lastUpdated => 0,
		context => q|template variable|
	},

	'hasAddedToCart' => {
		message => q|A condition indicating that the user has added the subscription to their cart, so we can display the thank you message.|,
		lastUpdated => 0,
		context => q|template variable|
	},

	'codeControls' => {
		message => q|A series of links for creating subscription code batches and listing subscription codes and code batches.|,
		lastUpdated => 0,
		context => q|template variable|
	},

	'redeemCodeLabel' => {
		message => q|An internationalized label for the link to redeem a subscription code.  If there are no subscription codes, this will be blank|,
		lastUpdated => 1213936319,
		context => q|template variable|
	},

	'redeemCodeUrl' => {
		message => q|The URL to redeem a subscription code.  If there are no subscription codes, this will be blank.|,
		lastUpdated => 1213936341,
		context => q|template variable|
	},

	'price' => {
		message => q|The price for the subscription, formatted to two decimal places|,
		lastUpdated => 1214592963,
		context => q|template variable|
	},

	'continueShoppingUrl' => {
		message => q|A URL to reset the Product so that the user can continue shopping.|,
		lastUpdated => 0,
		context => q|template variable|
	},

	'recurring subscription' => {
		message => q|Is subscription recurring?|,
		lastUpdated => 0,
		context => q|Label for swith to set subscription to be recurring or not.|
	},

    'recurring subscription description' => {
		message => q|If set to yes, the customer will be charged after each term for a new one and the subscription
will be renewed for an extra term. If set to no, the customer will be charged for the first term only, and after one
term the subscription expires for the customer.|,
		lastUpdated => 0,
		context => q|Label for swith to set subscription to be recurring or not.|
	},

};

1;
