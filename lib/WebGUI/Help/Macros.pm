package WebGUI::Help::Macros;

use WebGUI::Session;

our $HELP = {

        'macros using' => {
		title => 'macros using title',
		body => 'macros using body',
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
		related => [ 
                             sort { $a->{tag} cmp $b->{tag} }
                             map {
                                 $tag = $_;
                                 $tag =~ s/^[a-zA-Z]+_//;           #Remove initial shortcuts
				 $tag =~ s/([A-Z]+(?![a-z]))/$1 /g; #Separate acronyms
				 $tag =~ s/([a-z])([A-Z])/$1 $2/g;  #Separate studly caps
				 $tag = lc $tag;
				 { tag => $tag,
				   namespace => $_ }
			     }
		             values %{ $session{config}{macros} }
			   ],
        },

};

1;
