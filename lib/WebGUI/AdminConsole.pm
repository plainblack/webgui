package WebGUI::AdminConsole;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
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
use WebGUI::Macro;
use WebGUI::VersionTag;

=head1 NAME

Package WebGUI::AdminConsole

=head1 DESCRIPTION

The admin console is a menuing system to manage webgui's administrative functions.

=head1 SYNOPSIS

 use WebGUI::AdminConsole;

 _formatFunction
 addSubmenuItem
 addConfirmedSubmenuItem
 getAdminConsoleParams
 getAdminFunction
 getHelp
 new
 render
 setHelp
 setIcon

=head1 METHODS

These methods are available from this class:

=cut


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

=head2 addConfirmedSubmenuItem ( url, label, confirmation, extras )

Appends a link to the current AdminConsole submenu with a JavaScript confirmation showing the given message.

=head3 url

A string representing a URL.

=head3 label

A (hopefully informative) string.

=head3 confirmation

The message to use for the JavaScript confirmation before activating the link.

=head3 extras

Additional information.

=cut

sub addConfirmedSubmenuItem {
	my $self = shift;
	my $url = shift;
	my $label = shift;
	my $confirmation = shift;
	my $extras = shift;

	# Buggo.  We should really be using a proper JavaScript string escaping function here.
	$confirmation =~ s/([\\\'])/\\$1/g;
	$extras .= ' onclick="return confirm(\''.$confirmation.'\')"';
	$self->addSubmenuItem($url, $label, $extras);
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
		icon => $self->session->url->extras("adminConsole/adminConsole.gif")
		};
}

#-------------------------------------------------------------------

=head2 getAdminFunction ( )

Returns an array reference of available AdminFunctions.

=cut

sub getAdminFunction {
	my $self = shift;
	my $testing = shift;
	my $session = $self->session;
	my ($user, $url, $setting) = $session->quick(qw(user url setting));
	my $functions = $session->config->get("adminConsole");
	my %processed;
	
	# process the raw information from the config file
	foreach my $function (keys %{$functions}) {
		
		# make title
		my $title = $functions->{$function}{title};
		WebGUI::Macro::process($session, \$title);
		
		# determine if the user can use this thing
		my $canUse = 0;
		if (defined $functions->{$function}{group}) {
			$canUse = $user->isInGroup($functions->{$function}{group});
		}
		elsif (defined $functions->{$function}{groupSetting}) {
			$canUse = $user->isInGroup($setting->get($functions->{$function}{groupSetting}));
		}
		if ($functions->{$function}{uiLevel} > $user->get("uiLevel")) {
			$canUse = 0;
		}
		
		# build the attributes
		my %attributes = (
			title           => $title,
			icon            => $url->extras("/adminConsole/".$functions->{$function}{icon}),
			'icon.small'    => $url->extras("adminConsole/small/".$functions->{$function}{icon}),
			url             => $functions->{$function}{url},
			canUse          => $canUse,
		);
		
		# set the default function
		if ($self->{_functionId} eq $function) {
			$attributes{isCurrentOpFunc} = 1;
			$self->{_function} = \%attributes;
		}
		
		# build the list of processed items
		$processed{$title} = \%attributes;

	}

	#sort the functions alphabetically
	my @list;
	foreach my $title (sort keys %processed) {
		push @list, $processed{$title};
	}
	
	# all done
	return \@list;
}

#-------------------------------------------------------------------

=head2 new ( session, [id] )

Constructor.

=head3 session

A reference to the current session.

=head3 id

If supplied, provides a list of defaults such as title and icons for the admin console.

=head3 options

A hash reference of options with the following keys

=cut

sub new {
	my $class = shift;
	my $session = shift;
	my $id = shift;
    my $options = shift;
	my $self;
	$self->{_session} = $session;
	bless $self, $class;
	$self->{_function} = {};
	$self->{_functionId} = $id;
    $self->{_options} = $options;
	return $self;
}

#-------------------------------------------------------------------

=head2 render ( application.workarea [,application.title] )

Returns content wrapped inside of the Admin console template and style.

=head3 application.workarea

The main content to display to the user.

=head3 application.title

A string that defaults to _function's title.

=cut

sub render {
	my $self = shift;
    my $session = $self->session;
	$session->response->setCacheControl("none");
	my %var;
	$var{"application_loop"} = $self->getAdminFunction;
	$var{"application.workarea"} = shift;
	$var{"application.title"} = shift || $self->{_function}{title};
	my $i18n = WebGUI::International->new($session, "AdminConsole");
	$var{"backtosite.label"} = $i18n->get("493", "WebGUI");
	$var{"toggle.on.label"} = $i18n->get("toggle on");
	$var{"toggle.off.label"} = $i18n->get("toggle off");
	$var{"application.icon"} = $self->{_icon} || $self->{_function}{icon};
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
	my $working = WebGUI::VersionTag->getWorking($session, 1);
        my $workingId = "";
        my @tags = ();
        if ($working) {
			$workingId = $working->getId;
			push(@tags, {
					url=>$session->url->page("op=commitVersionTag;tagId=".$workingId),
					title=>$i18n->get("commit my changes","Macro_AdminBar"),
					icon=>$session->url->extras('adminConsole/small/versionTags.gif')
					});
        }
	foreach my $tag (@{WebGUI::VersionTag->getOpenTags($session)}) {
		next unless $session->user->isInGroup($tag->get("groupToUse"));
		push(@tags, {
				url=>$session->url->page("op=setWorkingVersionTag;tagId=".$tag->getId),
				title=>($tag->getId eq $workingId) ?  '* '.$tag->get("name") : $tag->get("name"),
				});
	}
	if (scalar(@tags)) {
		$var{versionTags} = \@tags;
	}

    $var{"backtosite.url"} = $session->url->getBackToSiteURL();
    my $formId = $self->getSubmenuFormId;
    $var{"formHeader"} = WebGUI::Form::formHeader($session, { action => $self->{_formUrl}, extras => qq|id='$formId'|, });
    $var{"formFooter"} = WebGUI::Form::formFooter($session);
    my $template
        = WebGUI::Asset::Template->newById(
            $session,
            $session->setting->get("AdminConsoleTemplate")
        );
    my $output  = $template->process(\%var);
    return $session->style->process($output,"PBtmpl0000000000000137");
}

#-------------------------------------------------------------------

=head2 setFormUrl ( $url )

Sets the action for the form that is used to submit CSRF requests.

=head3 $url

The URL for the form to submit to.  

=cut

sub setFormUrl {
	my $self = shift;
	$self->{_formUrl} = shift;
}

#-------------------------------------------------------------------

=head2 setHelp ( id [,namespace] )

Sets the _helpUrl to the urlized page.

B<NOTE:> This method is depricated and may be removed from a future version.

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

=head2 getHelp ( )

Returns the help topic, if any, that has been set for this adminConsole.

=cut

sub getHelp {
	my $self = shift;
	return (exists $self->{_helpUrl} ? $self->{_helpUrl} : '');
}

#-------------------------------------------------------------------

=head2 getSubmenuFormId ( )

Returns the id of the form used to to CSRF submits.

=cut

sub getSubmenuFormId {
	return 'submenuForm';
}

#-------------------------------------------------------------------

=head2 session ( )

Returns a reference to the current session.

=cut

sub session {
	my $self = shift;
	return $self->{_session};
}

#-------------------------------------------------------------------

=head2 setIcon ( icon )

Sets the _function icon to parameter.

=head3 icon

A string representing the location of the icon.

=cut

sub setIcon {
	my $self = shift;
	my $icon = shift;
	if ($icon) {
		$self->{_icon} = $icon;
	}
}

1;

