package WebGUI::Help::Macro_UsersOnline;

our $HELP = {

    'users online' => {
        title     => 'users online title',
        body      => 'users online body',

        variables => [ 
			{ name => 'members' }, 
			{ name => 'visitors' }, 
			{ name => 'total' }, 
			{ name => 'isVisitor' }, 
			{ name => 'hasMembers' },

            { name => 'member_loop',
                variables => [
                    { name => 'username' },
                    { name => 'firstName' },
                    { name => 'middleName' },
                    { name => 'lastName' },
                    { name => 'alias' },
                    { name => 'avatar' },
                    { name => 'uid' },
                    { name => 'sessionId' },
                    { name => 'ip' },
                    { name => 'lastActivity' },
                ],
            },

            { name => "visitor_loop",
                variables => [
                    { name => 'sessionId' },
                    { name => 'ip' },
                    { name => 'lastActivity' },
                ],
            },

			{ name => 'usersOnline_label' }, 
			{ name => 'members_label' }, 
			{ name => 'visitors_label' },
			{ name => 'total_label' },
			{ name => 'membersOnline_label' },
			{ name => 'visitorsOnline_label' },
			{ name => 'avatar_label' },
			{ name => 'name_label' },
			{ name => 'alias_label' },
			{ name => 'session_label' },
			{ name => 'ip_label' },
			{ name => 'lastActivity_label' },
		],
        fields    => [],
        related   => [],
    },

};

1;
