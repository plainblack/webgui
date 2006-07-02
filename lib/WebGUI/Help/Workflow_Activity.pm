package WebGUI::Help::Workflow_Activity;

our $HELP = {
	'add/edit workflow activity' => {
		title => 'add/edit workflow activity',
		body => 'add/edit workflow activity body',
		isa => [
		],
		fields => [
                        {
                                title => 'title',
                                description => 'title help',
                                namespace => 'Workflow_Activity',
                        },
                        {
                                title => 'description',
                                description => 'description help',
                                namespace => 'Workflow_Activity',
                        },
		],
		variables => [
		],
		related => [
		],
	},

	'list of installed activities' => {
		title => 'list of installed activities',
		body => sub {
			my $session = shift;
			my $dir = join '/', $session->config->getWebguiRoot,"lib","WebGUI","Workflow","Activity";
			opendir (DIR,$dir) or $session->errorHandler->fatal("Can't open Activity directory: $dir!");
			my @installedActivities = sort map { s/\.pm//; $_; }
				     grep { /\.pm$/ }
				     readdir(DIR);  ##list of namespaces
			closedir(DIR);

			##Build list of enabled activities, by namespace, by reversing session hash:
			my %workflows = %{ $session->config->get("workflowActivities") };
			my %activities = map { s/^WebGUI::Workflow::Activity:://; $_ => 1 }
					map { @{ $workflows{$_} } }
					keys %workflows;

			my $i18n = WebGUI::International->new($session, 'Workflow_Activity');
			my $yes = $i18n->get(138, 'WebGUI');
			my $no = $i18n->get(139, 'WebGUI');
			my $activity_table =
				join "\n", 
				map { join '', '<tr><td>', $_,
					'</td><td>',
					($activities{$_} ? $yes : $no), 
					'</td></tr>'
				} @installedActivities;

			$activity_table =
				join("\n", 
				 $i18n->get('activities list body'),
				 '<table border="1" cellpadding="3">',
				'<tr><th>',$i18n->get('activity name'),
				'</th><th>',
				$i18n->get('activity enabled header'),
				'</th></tr>',$activity_table,'</table>');
		},
		isa => [
		],
		fields => [
		],
		variables => [
		],
		related => sub {
			my $session = shift;

			##Build list of enabled activities, by namespace, by reversing session hash:
			my %workflows = %{ $session->config->get("workflowActivities") };
			my @activities = map { s/^WebGUI::Workflow::Activity:://; $_; }
					map { @{ $workflows{$_} } }
					keys %workflows;
			use Data::Dumper;
			$session->errorHandler->warn(Dumper \@activities);
			return map {
				my ($namespace, $tag) = ($_, $_);
				$tag =~ s/([a-z])([A-Z])/$1 $2/g;  #Separate studly caps
				$tag =~ s/([A-Z]+(?![a-z]))/$1 /g; #Separate acronyms
				$tag = lc $tag;
				$namespace = join '', 'Workflow_Activity_', $namespace;
				$session->errorHandler->warn($tag.' '.$namespace);
				{ tag => "$tag",
				namespace => $namespace }
			} @activities;

		},
	},

};

1;  ##All perl modules must return true
