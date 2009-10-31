package WebGUI::i18n::English::Macro_PickLanguage;  ##Be sure to change the package name to match the filename

use strict; ##Required for all good Perl::Critic compliant code

our $I18N = { ##hashref of hashes
	'picklanguage title' => {
		message => q|PickLanguage macro template variables|,
		lastUpdated => 1131394070,
		context => q|Title of the help object|
	},
	'lang_loop' => { ##key that will be used to reference this entry.  Do not translate this.
		message => q|A loop that contains all installed languages|,
		lastUpdated => 1131394070, #seconds from the epoch
		context => q|A template loop|
	},

	'language_lang' => {
		message => q|The name of the language in that language.|,
		lastUpdated => 1131394072,
		context => q|A template variable to show the name of the language|
	},
	
	'language_langAbbr' => {
		message => q|An standard code for the language, for instance "en".|,
		lastUpdated => 1131394072,
		context => q|A label of the language to use in the template|
	},
	'language_langAbbrLoc' => {
                message => q|An standard abbreviated label for the language, for instance "US".|,
                lastUpdated => 1131394072,
                context => q|A label of the language to use in the template|
        },
	'language_langEng' => {
                message => q|The English name of the language.|,
                lastUpdated => 1131394072,
                context => q|A label of the language to use in the template|
        },
	'language_url' => {
                message => q|The url that sets the WebGUI language to the selected language.|,
                lastUpdated => 1131394072,
                context => q|The url to change languages|
        },
	'delete_url' => {
		message => q|The url that deletes the scratch language from the session.|,
		lastUpdated => 1131394072,
		context => q|A template var to remove the scratch language|
	},
        'delete' => {
                message => q|Go back to profile language.|,
                lastUpdated => 1131394072,
                context => q|An internationalized label to go back to the profile language|
        },
        'delete_label' => {
                message => q|A label for the link to go back to the profile language.|,
                lastUpdated => 1131394072,
                context => q|Help for delete_label|
        },


};

1;
#vim:ft=perl
