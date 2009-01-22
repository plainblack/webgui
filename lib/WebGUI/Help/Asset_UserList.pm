package WebGUI::Help::Asset_UserList;

our $HELP = {
	'userlist template' => {
		title => 'UserList Template',
		body => '',
		isa => [
            {   namespace => "Asset_UserList",
                tag => "userlist asset template variables"
            },
            {   namespace => "Asset_Template",
                tag => "template variables"
            },
            {   namespace => "Asset",
                tag => "asset template"
            },
            {   tag => 'pagination template variables',
                namespace => 'WebGUI'
            },
        ],
		variables => [
            { 'name' => 'searchFormHeader' },
            { 'name' => 'searchFormSubmit' },
            { 'name' => 'searchFormFooter' },
            { 'name' => 'searchFormTypeOr' },
            { 'name' => 'searchFormTypeAnd' },
            { 'name' => 'searchFormTypeSelect' },
            { 'name' => 'searchFormQuery_form' },
            { 'name' => 'search_PROFILEFIELDNAME_text' },
            { 'name' => 'search_PROFILEFIELDNAME_form' },
            { 'name' => 'searchExact_PROFILEFIELDNAME_text' },
            { 'name' => 'searchExact_PROFILEFIELDNAME_form' },
            { 'name' => 'limitSearch' },
            { 'name' => 'includeInSearch_PROFILEFIELDNAME_hidden' },
            { 'name' => 'includeInSearch_PROFILEFIELDNAME_checkBox' },
            { 'name' => 'numberOfProfileFields' },
            { 'name' => 'profileField_PROFILEFIELDNAME_label' },
            { 'name' => 'profileField_PROFILEFIELDNAME_sortByURL' },
            {   'name'      => 'profileField_loop',
                'variables' => [
                    { 'name' => 'profileField_label' },
                    { 'name' => 'profileField_sortByURL' },
                ],
            },
            {   'name'      => 'alphabetSearch_loop',
                'variables' => [
                    { 'name' => 'alphabetSearch_loop_label' },
                    { 'name' => 'alphabetSearch_loop_hasResults' },
                    { 'name' => 'alphabetSearch_loop_searchURL' },
                ],
            },
            {   'name'      => 'user_loop',
                'variables' => [
                    { 'name' => 'user_name' },
                    { 'name' => 'user_id' },
                    { 'name' => 'user_profile_PROFILEFIELDNAME_value' },
                    { 'name' => 'user_profile_PROFILEFIELDNAME_notPublic' },
                    { 'name' => 'user_profile_PROFILEFIELDNAME_file' },
                    {   'name' => 'user_profile_loop', 
                        'variables' => [
                            { 'name' => 'profile_notPublic' },
                            { 'name' => 'profile_value' },
                            { 'name' => 'profile_file' },
                        ],
                    },
                ],
            },
        ],
        related => []
    },
    
    'userlist asset template variables' => {
        private => 1,
        title => 'UserList Template',
        body => '',
        isa     => [
            {   namespace => "Asset_Wobject",
                tag       => "wobject template variables",
            },
        ],
        variables => [
            { 'name' => 'alphabet' },
            { 'name' => 'showGroupId' },
            { 'name' => 'hideGroupId' },
            { 'name' => 'usersPerPage' },
            { 'name' => 'templateId' },
            { 'name' => 'showOnlyVisibleAsNamed' },
        ],
        related => []
    },
};

1;
