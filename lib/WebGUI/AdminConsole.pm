package WebGUI::AdminConsole;

use strict;
use WebGUI::Grouping;
use WebGUI::International;
use WebGUI::Session;
use WebGUI::Style;
use WebGUI::Template;
use WebGUI::URL;

sub _formatFunction {
	my $self = shift;
	my $function = shift;
	my $url;
	if (exists $function->{func}) {
		$url = WebGUI::URL::page("func=".$function->{func});
	} else {
		$url = WebGUI::URL::page("op=".$function->{op});
	}
	return {
		title=>WebGUI::International::get($function->{title}{id}, $function->{title}{namespace}),
		icon=>$session{config}{extrasURL}."/adminConsole/".$function->{icon},
		url=>$url,
		canUse=>WebGUI::Grouping::isInGroup($function->{group})
	};
}

sub addSubmenuItem {
	my $self = shift;
	my $url = shift;
	my $label = shift;
	my $extras = shift;
	push (@{$self->{_submenuItem}}, {
		url=>$url,
		label=>$label,
		extras=>$extras
		});
}

sub getAdminConsoleParams {
	return { 'title' => WebGUI::International::get("admin console","AdminConsole"),
		url => WebGUI::URL::page("op=adminConsole"),
		canUse => WebGUI::Grouping::isInGroup("12"),
		icon => $session{config}{extrasURL}."/adminConsole/adminConsole.gif"
		};
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
			func=>"manageAssets",
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
		"clipboard"=>{
			title=>{
				id=>"948",
				namespace=>"WebGUI"
			},
			icon=>"clipboard.gif",
			func=>"manageClipboard",
			group=>"12"
		},
		"trash"=>{
			title=>{
				id=>"trash",
				namespace=>"WebGUI"
			},
			icon=>"trash.gif",
			func=>"manageTrash",
			group=>"4"
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
		"commerce"=>{
			title=>{
				id=>"commerce settings",
				namespace=>"Commerce"
			},
			icon=>"commerce.gif",
			op=>"editCommerceSettings",
			group=>"3"
		},
		"subscriptions"=>{
			title=>{
				id=>"manage subscriptions",
				namespace=>"Subscription"
			},
			icon=>"subscriptions.gif",
			op=>"listSubscriptions",
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
	$self{_function} = $class->getAdminFunction($id) if ($id);
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
	my $acParams = $self->getAdminConsoleParams;
	$var{"console.title"} = $acParams->{title};
	$var{"console.url"} = $acParams->{url};
	$var{"console.canUse"} = $acParams->{canUse};
	$var{"console.icon"} = $acParams->{icon};
	$var{"help.url"} = $self->{_helpUrl};
	$var{"application_loop"} = $self->getAdminFunction;
	return WebGUI::Style::process(WebGUI::Template::process($session{setting}{AdminConsoleTemplate}, "AdminConsole", \%var),"adminConsole");
}

sub setHelp {
	my $self = shift;
	my $id = shift;
	my $namespace = shift || "WebGUI";
	$self->{_helpUrl} = WebGUI::URL::page('op=viewHelp&hid='.$id.'&namespace='.$namespace) if ($id);
}

sub setIcon {
	my $self = shift;
	my $icon = shift;
	if ($icon) { 
		$self->{_function}{icon} = $icon;
	}
}

1;

