package WebGUI::Help::Asset_Event;

our $HELP = {
	'event add/edit' => {
		title => 'add/edit title',
		body => 'add/edit body',
		isa => [
		],
		variables => [
		          {
		            'name'     => 'formHeader',
		            'required' => 1,
		          },
		          {
		            'name'     => 'formFooter',
		            'required' => 1,
		          },
		          {
		            'name'     => 'formTitle',
		            'required' => 1,
		          },
		          {
		            'name'     => 'formMenuTitle',
		          },
		          {
		            'name'     => 'formLocation',
		          },
		          {
		            'name'     => 'formDescription',
		          },
		          {
		            'name'     => 'formStartDate',
		          },
		          {
		            'name'     => 'formStartTime',
		          },
		          {
		            'name'     => 'formEndDate',
		          },
		          {
		            'name'     => 'formEndTime',
		          },
		          {
		            'name'     => 'formTime',
		          },
		          {
		            'name'     => 'formRelatedLinks',
		          },
                ],
		related => [
		],
	},

};

1;
