package WebGUI::i18n::English::Macro_SubscriptionItem;

our $I18N = {

	'macroName' => {
		message => q|Subscription Item|,
		lastUpdated => 1128919093,
	},

	'subscription item title' => {
		message => q|Subscription Item Macro|,
		lastUpdated => 1112547248,
	},

	'subscription item body' => {
		message => q|

<p><b>&#94;SubscriptionItem(<i>subscriptionId</i>,[<i>templateId</i>]);</b><br />
This macro is used to display information about subscription items from your site.
It accepts two arguments, the Id of the subscription item and an optional
template to use instead of the default template, specified by a template Id
from the Macro/SubscriptionItem namespace.</p>

<p>These variables are available in the template:</p>

<p><b>url</b><br />
The URL to purchase a subscription to this item.
</p>

<p><b>name</b><br />
The name of the item.

<p><b>description</b><br />
The description of the item.
</p>

<p><b>price</b><br />
The price of the item.
</p>

|,
		lastUpdated => 1146607323,
	},
};

1;
