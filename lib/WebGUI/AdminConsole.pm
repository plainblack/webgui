package WebGUI::AdminConsole;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use WebGUI::International;
use WebGUI::Asset::Template;

=head1 NAME

Package WebGUI::Asset

=head1 DESCRIPTION

The admin console is a menuing system to manage webgui's administrative functions.

=head1 SYNOPSIS

 use WebGUI::AdminConsole;

 _formatFunction
 addSubmenuItem
 getAdminConsoleParams
 getAdminFunction
 new
 render
 setHelp
 setIcon
  
=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 _formatFunction ( function )

Returns a Hash of title, icon, url, and canUse. title is the Internationalized title of the function. icon is the function icon, currently in extras/adminConsole/. url is current page with func= or op= depending on if the function is a function or operation. canUse checks if the current user is in the function group.

=head3 function

A hash ref to a function. Required.

=cut

sub _formatFunction {
	my $self = shift;
	my $function = shift;
	my $url;
	if (exists $function->{func}) {
		$url = $self->session->url->page("func=".$function->{func});
	} else {
		$url = $self->session->url->page("op=".$function->{op});
	}
	my $i18n = WebGUI::International->new($self->session);
	return {
		title=>$i18n->get($function->{title}{id}, $function->{title}{namespace}),
		icon=>$self->session->config->get("extrasURL")."/adminConsole/".$function->{icon},
		'icon.small'=>$self->session->config->get("extrasURL")."/adminConsole/small/".$function->{icon},
		url=>$url,
		canUse=>$self->session->user->isInGroup($function->{group}),
		isCurrentOpFunc=>($self->session->form->process("op") eq $function->{op} || $self->session->form->process("func") eq $function->{func})
	};
}

#-------------------------------------------------------------------

=head2 addSubmenuItem ( url, label, extras )

Puts params into the current AdminConsole submenu.

=head3 url

A string representing a URL.

=head3 label

A (hopefully informative) string.

=head3 extras

Additional information.

=cut

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

#-------------------------------------------------------------------

=head2 getAdminConsoleParams ( )

Returns a Hash of title, url, canUse, and icon. title is the Internationalization of "Admin Console". url is the page with op=adminConsole, canUse checks if is in group 12. icon is image located in extras/adminConsole/adminConsole.gif.

=cut

sub getAdminConsoleParams {
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session);
	return { 'title' => $i18n->get("admin console","AdminConsole"),
		url => $self->session->url->page("op=adminConsole"),
		canUse => $self->session->user->isInGroup("12"),
		icon => $self->session->config->get("extrasURL")."/adminConsole/adminConsole.gif"
		};
}

#-------------------------------------------------------------------

=head2 getAdminFunction ( [id] )

Returns _formatFunction list of available AdminFunctions.

=head3 id

If present, returns a _formatFunction hash based upon the given parameter.

=cut

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
		"versions"=>{
			title=>{
				id=>"content versioning",
				namespace=>"Asset"
			},
			icon=>"versionTags.gif",
			func=>"manageVersions",
			group=>"3"
		},
		"workflow"=>{
			title=>{
				id=>"topicName",
				namespace=>"Workflow"
			},
			icon=>"workflow.gif",
			op=>"manageWorkflows",
			group=>"pbgroup000000000000015"
		},
		"cron"=>{
			title=>{
				id=>"topicName",
				namespace=>"Workflow_Cron"
			},
			icon=>"cron.gif",
			op=>"manageCron",
			group=>"3"
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
			group=>"12"
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
		"ldapconnections"=>{
			title=>{
				id=>"ldapconnections",
				namespace=>"AuthLDAP"
			},
			icon=>"ldap.gif",
			op=>"listLDAPLinks",
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
		"settings"=>{
			title=>{
				id=>"settings",
				namespace=>"WebGUI"
			},
			icon=>"settings.gif",
			op=>"editSettings",
			group=>"3"
		},
	#	"themes"=>{
	#		title=>{
	#			id=>"themes",
	#			namespace=>"WebGUI"
	#		},
	#		icon=>"themes.gif",
	#		op=>"listThemes",
	#		group=>"9"
	#	},
		"help"=>{
			title=>{
				id=>"help",
				namespace=>"WebGUI"
			},
			icon=>"help.gif",
			op=>"viewHelpTOC",
			group=>"7"
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
				namespace=>"Asset"
			},
			icon=>"contentProfiling.gif",
			func=>"manageMetaData",
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
		"productManager"=>{
			title=>{
				id=>"manage products",
				namespace=>"ProductManager"
			},
			icon=>"productManager.gif",
			op=>"listProducts",
			group=>"14"
		},
		"cache"=>{
                        title=>{
                                id=>"manage cache",
                                namespace=>"WebGUI"
                        },
                        icon=>"cache.gif",
                        op=>"manageCache",
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

#-------------------------------------------------------------------

=head2 new ( session, [id] )

Constructor.

=head2 session

A reference to the current session.

=head3 id

If supplied, updates the _function of the AdminFunction.

=cut

sub new {
	my $class = shift;
	my $session = shift;
	my $id = shift;
	my $self;
	$self->{_session} = $session;
	bless $self, $class;
	$self->{_function} = $self->getAdminFunction($id) if ($id);
	return $self;
}

#-------------------------------------------------------------------

=head2 render ( application.workarea [,application.title] )

Prepares internationalization of variables. Returns a Style-processed AdminConsole.

=head3 application.workarea

=head3 application.title

A string that defaults to _function's title.

=cut

sub render {
	my $self = shift;
	my %var;
	$var{"application.workarea"} = shift;
	$var{"application.title"} = shift || $self->{_function}{title};
	my $i18n = WebGUI::International->new($self->session, "AdminConsole");
	$var{"backtosite.label"} = $i18n->get("493", "WebGUI");
	$var{"toggle.on.label"} = $i18n->get("toggle on");
	$var{"toggle.off.label"} = $i18n->get("toggle off");
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
	if (defined $self->session->asset) {
		my $importNode = WebGUI::Asset->getImportNode($self->session);
		my $importNodeLineage = $importNode->get("lineage");
		my $assetLineage = $self->session->asset->get("lineage");
		if ($assetLineage =~ /^$importNodeLineage/ || $assetLineage eq "000001") {
			$var{"backtosite.url"} = WebGUI::Asset->getDefault($self->session)->getUrl;
		} else {
			$var{"backtosite.url"} = $self->session->asset->getContainer->getUrl;
		}
	} else {
		$var{"backtosite.url"} = $self->session->url->page();
	}
	$var{"application_loop"} = $self->getAdminFunction;
	return $self->session->style->process(WebGUI::Asset::Template->new($self->session,$self->session->setting->get("AdminConsoleTemplate"))->process(\%var),"PBtmpl0000000000000137");
}

#-------------------------------------------------------------------

=head2 setHelp ( id[,namespace] )

Sets the _helpUrl to the urlized page.

=head3 id

If not provided, this method does nothing.

=head3 namespace

A string representing the namespace of the Help. Defaults to "WebGUI" as a namespace.

=cut

sub setHelp {
	my $self = shift;
	my $id = shift;
	my $namespace = shift || "WebGUI";
	$id =~ s/ /%20/g;
	$self->{_helpUrl} = $self->session->url->page('op=viewHelp;hid='.$id.';namespace='.$namespace) if ($id);
}

#-------------------------------------------------------------------

sub session {
	my $self = shift;
	return $self->{_session};
}

#-------------------------------------------------------------------

=head2 setIcon ( icon)

Sets the _function icon to parameter.

=head3 icon

A string representing the location of the icon.

=cut

sub setIcon {
	my $self = shift;
	my $icon = shift;
	if ($icon) { 
		$self->{_function}{icon} = $icon;
	}
}

1;

