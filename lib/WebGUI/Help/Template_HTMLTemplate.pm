package WebGUI::Help::Template_HTMLTemplate;

our $HELP = {  ##hashref of hashes
	'html template' => {
		title => 'html template title',
		body => 'html template body',
		related => [
			{
				tag => 'template language',
				namespace => 'Asset_Template',
			},
		],
	},

};

1;  ##All perl modules must return true
