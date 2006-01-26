package WebGUI::Help::Macros;


our $HELP = {

        'macros using' => {
		title => 'macros using title',
		body => 'macros using body',
		fields => [
		],
		related => [
                        {
                                tag => "macros list",
                                namespace => "Macros",
                        },
                ],
        },

        'macros list' => {
		title => 'macros list title',
		body => 'macros list body',
		fields => [
		],
		related => sub {   ##Hey, you gotta pass in the session var, right?
			     my $session = shift;
                             sort { $a->{tag} cmp $b->{tag} }
                             map {
                                 $tag = $_;
                                 $tag =~ s/^[a-zA-Z]+_//;           #Remove initial shortcuts
				 $tag =~ s/([A-Z]+(?![a-z]))/$1 /g; #Separate acronyms
				 $tag =~ s/([a-z])([A-Z])/$1 $2/g;  #Separate studly caps
				 $tag = lc $tag;
				 $namespace = join '', 'Macro_', $_;
				 { tag => $tag,
				   namespace => $namespace }
			     }
		             values %{ $session->config->get("macros") }
			   },
        },

};

1;
