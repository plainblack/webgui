package WebGUI::Help::Friends;

our $HELP = {
	'manage friends template' => {
		title => 'manage friends template title',
		isa => [
            {   namespace => "WebGUI",
                tag       => "account options"
            },
            {   namespace => "Asset_Template",
                tag       => "template variables"
            },
		],
		variables => [
			{
				name => "formHeader",
				required => 1,
			},
			{
				name => "subjectForm",
			},
			{
				name => "messageForm",
			},
			{
				name => "removeFriendButton",
				required => 1,
			},
			{
				name => "friends",
				required => 1,
                variables => [
                    { name => "name", },
                    { name => "profileUrl", },
                    { name => "status", },
                    { name => "checkboxForm", },
                ],
			},
			{
				name => "formFooter",
				required => 1,
			},
		],
		related => [
		],
	},

};

1;
