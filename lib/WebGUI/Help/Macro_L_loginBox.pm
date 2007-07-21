package WebGUI::Help::Macro_L_loginBox;

our $HELP = {

    'login box' => {
        title => 'login box title',
        body  => '',
        isa   => [
            {   namespace => "Asset_Template",
                tag       => "template variables"
            },
        ],
        variables => [
            { 'name' => 'user.isVisitor' },
            { 'name' => 'customText' },
            { 'name' => 'hello.label' },
            { 'name' => 'customText' },
            { 'name' => 'account.display.url' },
            { 'name' => 'logout.label' },
            {   'required' => 1,
                'name'     => 'form.header'
            },
            { 'name' => 'username.label' },
            {   'required' => 1,
                'name'     => 'username.form'
            },
            { 'name' => 'password.label' },
            {   'required' => 1,
                'name'     => 'password.form'
            },
            {   'required' => 1,
                'name'     => 'form.login'
            },
            { 'name' => 'account.create.url' },
            { 'name' => 'account.create.label' },
            {   'required' => 1,
                'name'     => 'form.footer'
            }
        ],
        fields  => [],
        related => []
    },

};

1;
