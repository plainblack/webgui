package WebGUI::AdminConsole;

use strict;
use WebGUI::Grouping;
use WebGUI::International;
use WebGUI::Session;
use WebGUI::Template;
use WebGUI::URL;

sub _formatFunction {
	my $self = shift;
	my $function = shift;
	return {
		title=>WebGUI::International::get($function->{title}{id}, $function->{title}{namespace}),
		icon=>$session{config}{extrasURL}."/adminConsole/".$function->{icon},
		url=>WebGUI::URL::page("op=".$function->{op}),
		canUse=>WebGUI::Grouping::isInGroup($function->{group})
	};
}

sub addSubmenuItem {
	my $self = shift;
	my $url = shift;
	my $label = shift;
	push (@{$self->{_submenuItem}}, {
		url=>$url,
		label=>$label
		});
}

sub getAdminFunction {
	my $self = shift;
	my $id = shift;
	my $functions = {		# at some point in the future we'll need to make this pluggable/configurable
		"assets"=>{
			title=>{
				id=>"assets",
				namespace=>"Asset"
			},
			icon=>"assets.gif",
			op=>"manageAssets",
			group=>"12"
		},
		"users"=>{
			title=>{
				id=>"149",
				namespace=>"WebGUI"
			},
			icon=>"users.gif",
			op=>"listUsers",
			group=>"11"
		},
		"navigation"=>{
			title=>{
				id=>"navigation",
				namespace=>"Navigation"
			},
			icon=>"navigation.gif",
			op=>"listNavigation",
			group=>"4"
		},
		"clipboard"=>{
			title=>{
				id=>"948",
				namespace=>"WebGUI"
			},
			icon=>"clipboard.gif",
			op=>"manageClipboard",
			group=>"4"
		},
		"trash"=>{
			title=>{
				id=>"trash",
				namespace=>"WebGUI"
			},
			icon=>"trash.gif",
			op=>"manageTrash",
			group=>"3"
		},
		"databases"=>{
			title=>{
				id=>"databases",
				namespace=>"WebGUI"
			},
			icon=>"databases.gif",
			op=>"listDatabaseLinks",
			group=>"3"
		},
		"groups"=>{
			title=>{
				id=>"89",
				namespace=>"WebGUI"
			},
			icon=>"groups.gif",
			op=>"listGroups",
			group=>"11"
		},
		"packages"=>{
			title=>{
				id=>"packages",
				namespace=>"WebGUI"
			},
			icon=>"packages.gif",
			op=>"managePackages",
			group=>"4"
		},
		"settings"=>{
			title=>{
				id=>"settings",
				namespace=>"WebGUI"
			},
			icon=>"settings.gif",
			op=>"editSettings",
			group=>"3"
		},
		"templates"=>{
			title=>{
				id=>"templates",
				namespace=>"WebGUI"
			},
			icon=>"templates.gif",
			op=>"listTemplates",
			group=>"8"
		},
		"themes"=>{
			title=>{
				id=>"themes",
				namespace=>"WebGUI"
			},
			icon=>"themes.gif",
			op=>"listThemes",
			group=>"9"
		},
		"help"=>{
			title=>{
				id=>"help",
				namespace=>"WebGUI"
			},
			icon=>"help.gif",
			op=>"viewHelpIndex",
			group=>"12"
		},
		"statistics"=>{
			title=>{
				id=>"437",
				namespace=>"WebGUI"
			},
			icon=>"statistics.gif",
			op=>"viewStatistics",
			group=>"12"
		},
		"contentProfiling"=>{
			title=>{
				id=>"content profiling",
				namespace=>"MetaData"
			},
			icon=>"contentProfiling.gif",
			op=>"manageMetaData",
			group=>"4"
		},
		"contentFilters"=>{
			title=>{
				id=>"content filters",
				namespace=>"WebGUI"
			},
			icon=>"contentFilters.gif",
			op=>"listReplacements",
			group=>"4"
		},
		"userProfiling"=>{
			title=>{
				id=>"user profiling",
				namespace=>"WebGUIProfile"
			},
			icon=>"userProfiling.gif",
			op=>"editProfileSettings",
			group=>"3"
		},
		"loginHistory"=>{
			title=>{
				id=>"426",
				namespace=>"WebGUI"
			},
			icon=>"loginHistory.gif",
			op=>"viewLoginHistory",
			group=>"3"
		},
		"activeSessions"=>{
			title=>{
				id=>"425",
				namespace=>"WebGUI"
			},
			icon=>"activeSessions.gif",
			op=>"viewActiveSessions",
			group=>"3"
		},
	};
	if ($id) {
		return $self->_formatFunction($functions->{$id});
	} else {
		my %names;
		foreach my $id (keys %{$functions}) {
			my $func = $self->_formatFunction($functions->{$id});
			$names{$func->{title}} = $func;
		}
		my @sorted = sort {$a cmp $b} keys %names;
		my @list;
		foreach my $key (@sorted) {
			push(@list,$names{$key});
		}
		return \@list;
	}
}

sub new {
	my $class = shift;
	my $id = shift;
	my %self;
	$self{_function} = $class->getAdminFunction($id);
	bless \%self, $class;
}

sub render {
	my $self = shift;
	my %var;
	$var{"application.workarea"} = shift;
	$var{"application.title"} = shift || $self->{_function}{title};
	$var{"backtosite.label"} = WebGUI::International::get("493");
	$var{"toggle.on.label"} = WebGUI::International::get("toggle on", "AdminConsole");
	$var{"toggle.off.label"} = WebGUI::International::get("toggle off","AdminConsole");
	$var{"application.icon"} = $self->{_function}{icon};
	$var{"application.canUse"} = $self->{_function}{canUse};
	$var{"application.url"} = $self->{_function}{url};
	if (exists $self->{_submenuItem}) {
		$var{submenu_loop} = $self->{_submenuItem};
	}
	$var{"console.title"} = WebGUI::International::get("admin console","AdminConsole");
	$var{"console.url"} = WebGUI::URL::page("op=adminConsole");
	$var{"console.canUse"} = WebGUI::Grouping::isInGroup("12");
	$var{"console.icon"} = $session{config}{extrasURL}."/adminConsole/adminConsole.gif";
	$var{"help.url"} = $self->{_helpUrl};
	$var{"application_loop"} = $self->getAdminFunction;
	$session{page}{useAdminStyle} = 1;
	return WebGUI::Template::process($session{setting}{AdminConsoleTemplate}, "AdminConsole", \%var);
}

sub setHelp {
	my $self = shift;
	my $id = shift;
	my $namespace = shift || "WebGUI";
	$self->{_helpUrl} = WebGUI::URL::page('op=viewHelp&hid='.$id.'&namespace='.$namespace) if ($id);
}

1;

