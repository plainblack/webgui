package WebGUI::Help::Macros;

use WebGUI::Session;
use Data::Dumper;

our $HELP = {

        'macros list' => {
		title => 'macros list title',
		body => 'macros list body',
		related => [ map {
                                 $tag = $_;
                                 $tag =~ s/^[a-zA-Z]+_//;           #Remove initial shortcuts
				 $tag =~ s/([A-Z]+(?![a-z]))/$1 /g; #Separate acronyms
				 $tag =~ s/([a-z])([A-Z])/$1 $2/g;  #Separate studly caps
				 $tag = lc $tag;
				 { tag => $tag,
				   namespace => $_ }
			     }
		             sort values %{ $session{config}{macros} }
			   ],
        },

};

1;
