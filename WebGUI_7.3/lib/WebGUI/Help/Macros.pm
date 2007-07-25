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
		body => sub {
			my $session = shift;
			my $dir = join '/', $session->config->getWebguiRoot,"lib","WebGUI","Macro";
			opendir (DIR,$dir) or $session->errorHandler->fatal("Can't open Macro directory: $dir!");
			my @macros = map { s/\.pm//; $_; }
				     grep { /\.pm$/ }
				     readdir(DIR);  ##list of namespaces
			closedir(DIR);

			##Build list of enabled macros, by namespace, by reversing session hash:
			my %macros = reverse %{ $session->config->get("macros") };

			my $i18n = WebGUI::International->new($session, 'Macros');
			my $yes = $i18n->get(138, 'WebGUI');
			my $no = $i18n->get(139, 'WebGUI');
			my $macro_table =
				join "\n", 
				map { join '', '<tr><td>', $_,
					'</td><td>',
					($macros{$_} ? $yes : $no), 
					'</td><td>',
					($macros{$_} ? ('&#94;', $macros{$_}, '();') : '&nbsp;'), 
					'</td></tr>'
				} @macros;

			$macro_table =
				join("\n", 
				 $i18n->get('macros list body'),
				 '<table border="1" cellpadding="3">',
				'<tr><th>',$i18n->get('macro name'),
				'</th><th>',
				$i18n->get('macro enabled header'),
				'</th><th>',
				$i18n->get('macro shortcut'),
				'</th></tr>',$macro_table,'</table>');
		},
		fields => [],
		related => sub {   ##Hey, you gotta pass in the session var, right?
			     my $session = shift;
                             sort { $a->{tag} cmp $b->{tag} }
                             map {
                                 $tag = $_;
                                 $tag =~ s/^[a-zA-Z]+_//;           #Remove initial shortcuts
				 $tag =~ s/([A-Z]+(?![a-z]))/$1 /g; #Separate acronyms
				 $tag =~ s/([a-z])([A-Z])/$1 $2/g;  #Separate studly caps
				 $tag =~ s/\s+$//;
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
