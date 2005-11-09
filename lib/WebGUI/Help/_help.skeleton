package WebGUI::Help::_Help; ## Be sure to change the package name to match your filename.

##Stub document for creating help documents.

our $HELP = {  ##hashref of hashes
	'help article' => {	#name of article, used as a reference by other articles
		title => 'help article title',  #The title and body are looked up in the
		body => 'help article title',	#i18n file of the same name
		fields => [	#This array is used to list hover help for form fields.
                        {
                                title => 'form label 1',
                                description => 'form description 1',
                                namespace => 'namespace',  #The namespace is called out explicitly
                        },
                        {
                                title => 'form label 2',
                                description => 'form description 2',
                                namespace => 'namespace',  #The namespace is called out explicitly
                        },
		],
		related => [  ##This lists other help articles that are related to this one
			{
				tag => 'other help article',
				namespace => 'other help articles namespace'
			},
		],
	},
};

1;  ##All perl modules must return true
