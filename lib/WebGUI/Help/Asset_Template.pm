package WebGUI::Help::Asset_Template;

our $HELP = {

	'template add/edit' => {
		title => '684',
		body => '639',
		fields => [
                        {
                                title => 'namespace',
                                description => 'namespace description',
                                namespace => 'Asset_Template',
                        },
                        {
                                title => 'show in forms',
                                description => 'show in forms description',
                                namespace => 'Asset_Template',
                        },
                        {
                                title => 'assetName',
                                description => 'template description',
                                namespace => 'Asset_Template',
                        },
                        {
                                title => 'head block',
                                description => 'head block description',
                                namespace => 'Asset_Template',
                        },
                        {
                                title => 'parser',
                                description => 'parser description',
                                namespace => 'Asset_Template',
                        },
		],
		related => [
		]
	},

	'template language' => {
		title => '825',
		body => '826',
		fields => [
		],
		related => [
			{
				tag => 'template variables',
				namespace => 'Asset_Template'
			},
		]
	},

	'template variables' => {
		title => 'template variable title',
		body => 'template variable body',
		fields => [
		],
		variables => [
			  {
			    'name' => 'webgui.version'
			  },
			  {
			    'name' => 'webgui.status'
			  },
			  {
			    'name' => 'session.user.username'
			  },
			  {
			    'name' => 'session.user.firstDayOfWeek'
			  },
			  {
			    'name' => 'session.config.extrasurl'
			  },
			  {
			    'name' => 'session.var.adminOn'
			  },
			  {
			    'name' => 'session.setting.companyName'
			  },
			  {
			    'name' => 'session.setting.anonymousRegistration'
			  },
			  {
			    'name' => 'session form variables'
			  },
			  {
			    'name' => 'session scratch variables'
			  },
		],
		related => [
		]
	},

	'style wizard' => {
		title => 'style wizard',
		body => 'style wizard help',
		fields => [
                        {
                                title => 'site name',
                                description => 'site name description',
                                namespace => 'Asset_Template',
                        },
                        {
                                title => 'logo',
                                description => 'logo description',
                                namespace => 'Asset_Template',
                        },
                        {
                                title => 'page background color',
                                description => 'page background color description',
                                namespace => 'Asset_Template',
                        },
                        {
                                title => 'header background color',
                                description => 'header background color description',
                                namespace => 'Asset_Template',
                        },
                        {
                                title => 'header text color',
                                description => 'header text color description',
                                namespace => 'Asset_Template',
                        },
                        {
                                title => 'body background color',
                                description => 'body background color description',
                                namespace => 'Asset_Template',
                        },
                        {
                                title => 'body text color',
                                description => 'body text color description',
                                namespace => 'Asset_Template',
                        },
                        {
                                title => 'menu background color',
                                description => 'menu background color description',
                                namespace => 'Asset_Template',
                        },
                        {
                                title => 'link color',
                                description => 'link color description',
                                namespace => 'Asset_Template',
                        },
                        {
                                title => 'visited link color',
                                description => 'visited link color description',
                                namespace => 'Asset_Template',
                        },
		],
		related => [
		]
	},

        'template parsers list' => {
		title => 'template parsers list title',
		body => sub {
			my $session = shift;
			my $dir = join '/', $session->config->getWebguiRoot,"lib","WebGUI","Asset","Template";
			opendir (DIR,$dir) or $session->errorHandler->fatal("Can't open Macro directory: $dir!");
			my @plugins = map { s/\.pm//; $_; }
				     grep { $_ ne "Parser.pm" }
				     grep { /\.pm$/ }
				     readdir(DIR);  ##list of namespaces
			closedir(DIR);

			##Build list of enabled macros, by namespace, by reversing session hash:
			my @enabledPlugins = map { s/^WebGUI::Asset::Template:://; $_ } @{ $session->config->get("templateParsers") };
			my $defaultParser = $session->config->get('defaultTemplateParser');
			$defaultParser =~ s/^WebGUI::Asset::Template:://;
			my %enabledPlugins = map { $_ => 1 } @enabledPlugins;

			my $i18n = WebGUI::International->new($session, 'Asset_Template');
			my $yes = $i18n->get(138, 'WebGUI');
			my $no = $i18n->get(139, 'WebGUI');
			use Data::Dumper;
			$session->errorHandler->warn(Dumper \@enabledPlugins);
			$session->errorHandler->warn(Dumper \@plugins);
			my $plugin_table =
				join "\n", 
				map { join '', '<tr><td>', $_,
					'</td><td>',
					($enabledPlugins{$_} ? $yes : $no), 
					'</td><td>',
					($_ eq $defaultParser ? $yes : $no), 
					'</td>',
				} @plugins;

			$plugin_table =
				join("\n", 
				 $i18n->get('template parsers list body'),
				 '<table border="1" cellpadding="3">',
				'<tr><th>',$i18n->get('plugin name'),
				'</th><th>',
				$i18n->get('plugin enabled header'),
				'</th><th>',
				$i18n->get('default parser'),
				'</th></tr>',$plugin_table,'</table>');
		},
		fields => [],
		related => sub {   ##Hey, you gotta pass in the session var, right?
			     my $session = shift;
                             sort { $a->{tag} cmp $b->{tag} }
                             map {
				 s/^WebGUI::Asset::Template:://;
                                 $tag = $_;
                                 $tag =~ s/^[a-zA-Z]+_//;           #Remove initial shortcuts
				 $tag =~ s/([A-Z]+(?![a-z]))/$1 /g; #Separate acronyms
				 $tag =~ s/([a-z])([A-Z])/$1 $2/g;  #Separate studly caps
				 $tag =~ s/\s+$//;
				 $tag = lc $tag;
				 $namespace = join '', 'Template_', $_;
				 { tag => $tag,
				   namespace => $namespace }
			     }
		             @{ $session->config->get("templateParsers") }
			   },
,
	},
};

1;
