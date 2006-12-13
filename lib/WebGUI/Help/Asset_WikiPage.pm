package WebGUI::Help::Asset_WikiPage;

our $HELP = {
	'wiki page add/edit' => {
		title => 'add/edit title',
		body => 'add/edit body',
		isa => [
		],
		variables => [
                        {
                                name => 'title',
                        },
                        {
                                name => 'formHeader',
				required => 1,
                        },
                        {
                                name => 'formTitle',
                        },
                        {
                                name => 'titleLabel',
                                description => 'titleLabel variable',
                        },
                        {
                                name => 'formContent',
                        },
                        {
                                name => 'contentLabel',
                                description => 'contentLabel variable',
                        },
                        {
                                name => 'formProtect',
                        },
                        {
                                name => 'protectQuestionLabel',
                                description => 'protectQuestionLabel variable',
                        },
                        {
                                name => 'formSubmit',
				required => 1,
                        },
                        {
                                name => 'formFooter',
				required => 1,
                        },
                        {
                                name => 'isNew',
                        },
                        {
                                name => 'canAdminister',
                        },
                        {
                                name => 'isProtected',
                        },
                        {
                                name => 'deleteLabel',
                                description => 'deleteLabel variable',
                        },
                        {
                                name => 'deleteUrl',
                        },
		],
		related => [
		],
	},

};

1;
