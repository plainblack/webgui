package WebGUI::i18n::English::WobjectProxy;

our $I18N = {
	'1' => {
		message => q|Wobject To Proxy|,
		lastUpdated => 1031514049
	},

	'2' => {
		message => q|Edit Wobject Proxy|,
		lastUpdated => 1031514049
	},

	'3' => {
		message => q|Wobject Proxy|,
		lastUpdated => 1031514049
	},

	'4' => {
		message => q|Wobject proxying failed. Perhaps the proxied wobject has been deleted.|,
		lastUpdated => 1031514049
	},

	'5' => {
		message => q|Wobject Proxy, Add/Edit|,
		lastUpdated => 1031514049
	},

	'6' => {
		message => q|With the Wobject Proxy (aka Shortcut) you can mirror a wobject from another page to any other page. This is useful if you want to reuse the same content in multiple sections of your site.
<p>

<b>NOTE:</b> The wobject proxy is not available through the Add Content menu, but instead through the shortcut icon on each wobject's toolbar.
<p>

<b>Wobject To Proxy</b><br>
Provides a link to the orignal wobject being proxied.
<p>

<b>Override title?</b><br>
Set to "yes" to use the title of the wobject proxy instead of the original title of the wobject.
<p>

<b>Override description?</b><br>
Set to "yes" to use the description of the wobject proxy instead of the original description of the wobject.
<p>

<b>Override display title?</b><br>
Set to "yes" to use the display title setting of the wobject proxy instead of the original display title setting of the wobject.
<p>

<b>Override template?</b><br>
Set to "yes" to use the template of the wobject proxy instead of the original template of the wobject.
<p>

<b>Proxy by alternate criteria?</b><br>
Set to "yes" to enable selecting a wobject based upon custom criteria. Metadata must be enabled for this option to function properly.
<p>

<b>Resolve Multiples?</b><br>
Sets the order to use when multiple wobjects are selected. Random means that if multiple wobjects match the proxy criteria then the wobject proxy will select a random wobject to proxy.<br>
Most Recent will select the most recent wobject that match the proxy criteria.
<p>

<b>Criteria</b><br>
A statement to determinate what to proxy, in the form of "color = blue and weight != heavy". Multiple expressions may be joined with "and" and "or". <br>
A property or value must be quoted if it contains spaces. Feel free to use the criteria builder to build your statements.
<p>
|,
		lastUpdated => 1057091098
	},

	'8' => {
		message => q|Override display title?|,
		lastUpdated => 1053183719,
		context => q|Asking the user if s/he would like to use the "display title" setting specified in the wobject proxy or the original display title setting of the original wobject.|
	},

	'10' => {
		message => q|Override template?|,
		lastUpdated => 1053183837,
		context => q|Asking the user if s/he would like to use the template specified in the wobject proxy or the original template of the original wobject.|
	},

	'7' => {
		message => q|Override title?|,
		lastUpdated => 1053183682,
		context => q|Asking the user if s/he would like to use the title specified in the wobject proxy or the original title of the original wobject.|
	},

	'9' => {
		message => q|Override description?|,
		lastUpdated => 1053183804,
		context => q|Asking the user if s/he would like to use the description specified in the wobject proxy or the original description of the original wobject.|
	},
	'Proxy by alternate criteria?' => {
		message => q|Proxy by alternate criteria?|,
		lastUpdated => 1053183804,
		context => q|Asking the user if s/he would like to use alternate criteria to find a  matching a wobject to proxy.|
        },
	'Resolve Multiples?' => {
                message => q|Resolve Multiples?|,
                lastUpdated => 1053183804,
                context => q|Asking the user what sort order (random / most recent) to use if multiple hits are found.|
        },
	'Most Recent' => {
                message => q|Most Recent|,
                lastUpdated => 1053183804,
                context => q|Selectlist item for "Resolve Multiples?"|
        },
	'Random'  => {
                message => q|Random|,
                lastUpdated => 1053183804,
                context => q|Selectlist item for "Resolve Multiples?"|
        },
	'Criteria' => {
                message => q|Criteria|,
                lastUpdated => 1053183804,
                context => q|Label for the criteria textarea|
        },
	'AND' => {
		message => q|AND|,
		lastUpdated => 1053183804,
                context => q|Part of the WobjectProxy Query Builder|
        },
        'OR' => {
                message => q|OR|,
                lastUpdated => 1053183804,
                context => q|Part of the WobjectProxy Query Builder|
        },
        'is' => {
                message => q|is|,
                lastUpdated => 1053183804,
                context => q|Part of the WobjectProxy Query Builder|
        },
        'isnt' => {
                message => q|isn't|,
                lastUpdated => 1053183804,
                context => q|Part of the WobjectProxy Query Builder|
        },
	"less than" => {
		message => q|less than|,
                lastUpdated => 1053183804,
                context => q|Part of the WobjectProxy Query Builder|
        },
        "equal to" => {
                message => q|equal to|,
                lastUpdated => 1053183804,
                context => q|Part of the WobjectProxy Query Builder|
        },
        "greater than" => {
                message => q|greater than|,
                lastUpdated => 1053183804,
                context => q|Part of the WobjectProxy Query Builder|
        },
        "not equal to" => {
                message => q|not equal to|,
                lastUpdated => 1053183804,
                context => q|Part of the WobjectProxy Query Builder|
        },

};

1;
