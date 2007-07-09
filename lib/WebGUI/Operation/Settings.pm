package WebGUI::Operation::Settings;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2007 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict qw(vars subs);
use Tie::IxHash;
use WebGUI::AdminConsole;
use WebGUI::TabForm;
use WebGUI::International;
use WebGUI::SQL;

=head1 NAME

Package WebGUI::Operation::Settings

=head1 DESCRIPTION

Operation handler for sitewide settings for content, messaging, authentication, etc.

=head1 FUNCTIONS

The following functions are available from this package.

=cut

#-------------------------------------------------------------------

=head2 definition ( )

Returns an array reference used by www_editSettings and www_editSettingsSave to process the form data.

=cut

sub definition {
	my $session = shift;
	my $i18n = shift;
	my @fields = ();
	# company info
	push(@fields, {
		tab=>"company",
		fieldType=>"text",
		name=>"companyName",
		label=>$i18n->get(125),
		hoverHelp=>$i18n->get('125 description'),
		defaultValue=>$session->setting->get("companyName")
		});
	push(@fields, {
		tab=>"company",
		fieldType=>"text",
		name=>"companyEmail",
		label=>$i18n->get(126),
		hoverHelp=>$i18n->get('126 description'),
		defaultValue=>$session->setting->get("companyEmail")
		});
	push(@fields, {
		tab=>"company",
		fieldType=>"url",
		name=>"companyURL",
		label=>$i18n->get(127),
		hoverHelp=>$i18n->get('127 description'),
		defaultValue=>$session->setting->get("companyURL")
		});

	# content settings
	push(@fields, {
		tab=>"content",
		fieldType=>"workflow",
		name=>"defaultVersionTagWorkflow",
		defaultValue=>$session->setting->get("defaultVersionTagWorkflow"),
		type=>"WebGUI::VersionTag",
		label=>$i18n->get("default version tag workflow"),
		hoverHelp=>$i18n->get('default version tag workflow help'),
        includeRealtime=>1,
		});
	push(@fields, {
		tab=>"content",
		fieldType=>"yesNo",
        name=>"autoRequestCommit",
        label=>$i18n->get("auto request commit"),
        hoverHelp=>$i18n->get("auto request commit help"),
        defaultValue=>$session->setting->get("autoRequestCommit")
		});
	push(@fields, {
		tab=>"content",
		fieldType=>"yesNo",
        name=>"skipCommitComments",
        label=>$i18n->get("skip commit comments"),
        hoverHelp=>$i18n->get("skip commit comments"),
        defaultValue=>$session->setting->get("skipCommitComments")
		});
	push(@fields, {
		tab=>"content",
		fieldType=>"workflow",
		name=>"trashWorkflow",
		defaultValue=>$session->setting->get("trashWorkflow"),
		type=>"None",
		label=>$i18n->get("trash workflow"),
		hoverHelp=>$i18n->get('trash workflow help')
		});
	push(@fields, {
		tab=>"content",
		fieldType=>"workflow",
		name=>"purgeWorkflow",
		defaultValue=>$session->setting->get("purgeWorkflow"),
		type=>"None",
		label=>$i18n->get("purge workflow"),
		hoverHelp=>$i18n->get('purge workflow help')
		});
	push(@fields, {
		tab=>"content",
		fieldType=>"workflow",
		name=>"changeUrlWorkflow",
		defaultValue=>$session->setting->get("changeUrlWorkflow"),
		type=>"None",
		label=>$i18n->get("changeUrl workflow"),
		hoverHelp=>$i18n->get('changeUrl workflow help')
		});

        my %htmlFilter = (
		'none'=>$i18n->get(420), 
		'most'=>$i18n->get(421), 
		'javascript'=>$i18n->get(526), 
		'all'=>$i18n->get(419)
		);
	push(@fields, {
		tab=>"content",
		fieldType=>"asset",
		name=>"defaultPage",
		label=>$i18n->get(527),
		hoverHelp=>$i18n->get('527 description'),
		defaultValue=>$session->setting->get("defaultPage")
		});
	push(@fields, {
		tab=>"content",
		fieldType=>"asset",
		name=>"notFoundPage",
		label=>$i18n->get(141),
		hoverHelp=>$i18n->get('141 description'),
		defaultValue=>$session->setting->get("notFoundPage")
		});
	push(@fields, {
		tab=>"content",
		fieldType=>"text",
		name=>"urlExtension",
		defaultValue=>$session->setting->get("urlExtension"),
		label=>$i18n->get("url extension"),
		hoverHelp=>$i18n->get("url extension description"),
		});
	push(@fields, {
		tab=>"content",
		fieldType=>"integer",
		name=>"maxAttachmentSize",
		label=>$i18n->get(130),
		hoverHelp=>$i18n->get('130 description'),
		defaultValue=>$session->setting->get("maxAttachmentSize")
		});
	push(@fields, {
		tab=>"content",
		fieldType=>"integer",
		name=>"maxImageSize",
		label=>$i18n->get(583),
		hoverHelp=>$i18n->get('583 description'),
		defaultValue=>$session->setting->get("maxImageSize")
		});
	push(@fields, {
		tab=>"content",
		fieldType=>"integer",
		name=>"thumbnailSize",
		label=>$i18n->get(406),
		hoverHelp=>$i18n->get('406 description'),
		defaultValue=>$session->setting->get("thumbnailSize")
		});
	push(@fields, {
		tab=>"content",
		fieldType=>"yesNo",
        name=>"metaDataEnabled",
        label=>$i18n->get("Enable Metadata"),
        hoverHelp=>$i18n->get("Enable Metadata description"),
        defaultValue=>$session->setting->get("metaDataEnabled")
		});
	# user interface settings
	push(@fields, {
		tab=>"ui",
		fieldType=>"selectBox",
		name=>"richEditor",
		label=>$i18n->get("default rich editor"),
		hoverHelp=>$i18n->get("default rich editor description"),
		defaultValue=>[$session->setting->get("richEditor") || "PBrichedit000000000001"],
		options=>WebGUI::Asset::RichEdit->getList($session)
		});
	push(@fields, {
		tab=>"ui",
		fieldType=>"integer",
		name=>"textBoxSize",
		label=>$i18n->get(465),
		hoverHelp=>$i18n->get('465 description'),
		defaultValue=>$session->setting->get("textBoxSize")
		});
	push(@fields, {
		tab=>"ui",
		fieldType=>"template",
		name=>"userFunctionStyleId",
		label=>$i18n->get('user function style'),
		hoverHelp=>$i18n->get('user function style description'),
		namespace=>"style",
		defaultValue=>$session->setting->get("userFunctionStyleId")
		});
	push(@fields, {
		tab=>"ui",
		fieldType=>"template",
		name=>"AdminConsoleTemplate",
		label=>$i18n->get('admin console template'),
		hoverHelp=>$i18n->get('admin console template description'),
		namespace=>"AdminConsole",
		defaultValue=>$session->setting->get("AdminConsoleTemplate")
		});
    push(@fields, {
		tab=>"ui",
		fieldType=>"template",
		name=>"viewInboxTemplateId",
		label=>$i18n->get('view inbox template'),
		hoverHelp=>$i18n->get('view inbox template description'),
		namespace=>"Inbox",
		defaultValue=>$session->setting->get("viewInboxTemplateId"),
		});
    push(@fields, {
		tab=>"ui",
		fieldType=>"template",
		name=>"viewInboxMessageTemplateId",
		label=>$i18n->get('view inbox message template'),
		hoverHelp=>$i18n->get('view inbox message template description'),
		namespace=>"Inbox/Message",
		defaultValue=>$session->setting->get("viewInboxMessageTemplateId"),
		});    
    push(@fields, {
		tab=>"ui",
		fieldType=>"template",
		name=>"sendPrivateMessageTemplateId",
		label=>$i18n->get('send private message template'),
		hoverHelp=>$i18n->get('send private message template description'),
		namespace=>"Inbox/SendPrivateMessage",
		defaultValue=>$session->setting->get("sendPrivateMessageTemplateId"),
		});    
	# messaging settings
	push(@fields, {
		tab=>"messaging",
		fieldType=>"text",
		name=>"smtpServer",
		label=>$i18n->get(135),
		hoverHelp=>$i18n->get('135 description'),
		defaultValue=>$session->setting->get("smtpServer")
		});
	push(@fields, {
		tab=>"messaging",
		fieldType=>"textarea",
		name=>"mailFooter",
		label=>$i18n->get(824),
		hoverHelp=>$i18n->get('824 description'),
		defaultValue=>$session->setting->get("mailFooter")
		});
	push(@fields, {
		tab=>"messaging",
		fieldType=>"email",
		name=>"mailReturnPath",
		label=>$i18n->get("mail return path"),
		hoverHelp=>$i18n->get('mail return path help'),
		defaultValue=>$session->setting->get("mailReturnPath")
		});
	# misc
	push(@fields, {
		tab=>"misc",
		fieldType=>"yesNo",
		name=>"preventProxyCache",
		label=>$i18n->get(400),
		hoverHelp=>$i18n->get('400 description'),
		defaultValue=>$session->setting->get("preventProxyCache")
		});
	push(@fields, {
		tab=>"misc",
		fieldType=>"text",
		name=>"debugIp",
		label=>$i18n->get("debug ip"),
		hoverHelp=>$i18n->get("debug ip description"),
		defaultValue=>$session->setting->get("debugIp")
		});
	push(@fields, {
		tab=>"misc",
		fieldType=>"yesNo",
		name=>"showDebug",
		label=>$i18n->get(707),
		hoverHelp=>$i18n->get('707 description'),
		defaultValue=>$session->setting->get("showDebug")
		});
	push(@fields, {
		tab=>"misc",
		fieldType=>"yesNo",
		name=>"showPerformanceIndicators",
		label=>$i18n->get('show performance indicators'),
		hoverHelp=>$i18n->get('show performance indicators description'),
		defaultValue=>$session->setting->get("showPerformanceIndicators")
		});
	push(@fields, {
		tab=>"misc",
		fieldType=>"selectBox",
		name=>"hostToUse",
		defaultValue=>[$session->setting->get("hostToUse")],
		options=>{
			sitename=>$i18n->get(1070),
			HTTP_HOST=>$i18n->get(1071)
			},
		label=>$i18n->get(1069),
		hoverHelp=>$i18n->get('1069 description'),
		});
	# user settings
	push(@fields, {
		tab=>"user",
		fieldType=>"yesNo",
		name=>"anonymousRegistration",
		label=>$i18n->get(118),
		hoverHelp=>$i18n->get('118 description'),
		defaultValue=>$session->setting->get("anonymousRegistration")
		});
	push(@fields, {
		tab=>"user",
		fieldType=>"yesNo",
                name=>"automaticLDAPRegistration",
                label=>$i18n->echo("Automatic LDAP Registration"),
                hoverHelp=>$i18n->echo('When set to yes, a WebGUI user account will be created and the user logged in, if the credentials entered are validated by LDAP.'),
		defaultValue=>$session->setting->get("automaticLDAPRegistration")
                });
	push(@fields, {
		tab=>"user",
		fieldType=>"workflow",
		none=>1,
		type=>"WebGUI::User",
		name=>"runOnRegistration",
		label=>$i18n->get(559),
		hoverHelp=>$i18n->get('559 description'),
		defaultValue=>$session->setting->get("runOnRegistration")
		});
	push(@fields, {
		tab=>"user",
		fieldType=>"yesNo",
		name=>"useKarma",
		label=>$i18n->get(539),
		hoverHelp=>$i18n->get('539 description'),
		defaultValue=>$session->setting->get("useKarma")
		});
	push(@fields, {
		tab=>"user",
		fieldType=>"integer",
		name=>"karmaPerLogin",
		label=>$i18n->get(540),
		hoverHelp=>$i18n->get('540 description'),
		defaultValue=>$session->setting->get("karmaPerLogin")
		});
	push(@fields, {
		tab=>"user",
		fieldType=>"interval",
		name=>"sessionTimeout",
		label=>$i18n->get(142),
		hoverHelp=>$i18n->get('142 description'),
		defaultValue=>$session->setting->get("sessionTimeout")
		});
	push(@fields, {
		tab=>"user",
		fieldType=>"yesNo",
		name=>"selfDeactivation",
		label=>$i18n->get(885),
		hoverHelp=>$i18n->get('885 description'),
		defaultValue=>$session->setting->get("selfDeactivation")
		});
	push(@fields, {
		tab=>"user",
		fieldType=>"yesNo",
		name=>"encryptLogin",
		label=>$i18n->get(1006),
		hoverHelp=>$i18n->get('1006 description'),
		defaultValue=>$session->setting->get("encryptLogin")
		});
	push(@fields, {
		tab=>"user",
		fieldType=>"yesNo",
                name=>"passiveProfilingEnabled",
                label=>$i18n->get("Enable passive profiling"),
                hoverHelp=>$i18n->get("Enable passive profiling description"),
                defaultValue=>$session->setting->get("passiveProfilingEnabled"),
                extras=>'onchange="alert(\''.$i18n->get("Illegal Warning").'\')" '
		});
    push(@fields, {
        tab=>"user",
        fieldType=>"yesNo",
        name=>"userInvitationsEnabled",
        label=>$i18n->get("Enable user invitations"),
        hoverHelp=>$i18n->get("Enable user invitations description"),
        defaultValue=>$session->setting->get("userInvitationsEnabled"),
    });
    push(@fields, {
        tab=>"user",
        fieldType=>"textarea",
        name=>"userInvitationsEmailExists",
        label=>$i18n->get("user invitations email exists"),
        hoverHelp=>$i18n->get("user invitations email exists description"),
        defaultValue=>$session->setting->get("userInvitationsEmailExists"),
    });
    push(@fields, {
		tab=>"user",
		fieldType=>"template",
		name=>"userInvitationsEmailTemplateId",
		label=>$i18n->get('user email template'),
		hoverHelp=>$i18n->get('user email template description'),
		namespace=>"userInvite/Email",
		defaultValue=>$session->setting->get("userInvitationsEmailTemplateId"),
		});    
	# auth settings 
   	my $options;
   	foreach (@{$session->config->get("authMethods")}) {
      		$options->{$_} = $_;
   	}
	push(@fields, {
		tab=>"auth",
		fieldType=>"selectBox",
            	name=>"authMethod",
		options=>$options,
		label=>$i18n->get(164),
		hoverHelp=>$i18n->get('164 description'),
		defaultValue=>[$session->setting->get("authMethod")],
		});
	return \@fields;
}


#-------------------------------------------------------------------

=head2 www_editSettings ( $session, $argsHash )

Display a form for sitewide settings, if the user is in group Admin (3).

argsHash is a hash reference of additional arguments to this sub. Available
keys:

 errors     - An array reference of errors with processing the site settings
                NOTE: Must be i18n BEFORE given to this sub
 message    - A benign message to the user
                NOTE: Must be i18n BEFORE given to this sub

=cut

sub www_editSettings {
	my $session     = shift;
    my $argsHash    = shift;
	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	my $i18n        = WebGUI::International->new($session, "WebGUI");
    my $output      = '';

    # Show any errors or message
    if ($argsHash->{message}) {
        $output .= '<p>' . $argsHash->{message} . '</p>';
    }
    my @errors  = @{ $argsHash->{errors} };
    if (@errors) {
        $output .= '<p>' . $i18n->get("editSettings error occurred") . '</p>'
                . '<ul>'
                ;
        for my $error (@errors) {
            $output     .= "<li>$error</li>";
        }
        $output .= '</ul>';
    }

    # Available tabs
    # TODO: Build this from the definition instead.
	tie my %tabs, 'Tie::IxHash', (
        company     => { label => $i18n->get("company") },
        content     => { label => $i18n->get("content") },
        ui          => { label => $i18n->get("ui") },
        messaging   => { label => $i18n->get("messaging") },
        misc        => { label => $i18n->get("misc") },
        user        => { label => $i18n->get("user") },
        auth        => { label => $i18n->get("authentication") },
    );

    # Start the form
 	my $tabform = WebGUI::TabForm->new($session,\%tabs);
	$tabform->hidden({
		name        => "op",
		value       => "saveSettings"
    });

	my $definitions = definition($session, $i18n);
	foreach my $definition (@{$definitions}) {
		$tabform->getTab($definition->{tab})->dynamicField(%{$definition});
	}

    # Get fieldsets for avaiable auth methods
	foreach (@{$session->config->get("authMethods")}) {
		$tabform->getTab("auth")->fieldSetStart($_);
		my $authInstance = WebGUI::Operation::Auth::getInstance($session,$_,1);
		$tabform->getTab("auth")->raw($authInstance->editUserSettingsForm);
		$tabform->getTab("auth")->fieldSetEnd;
	}

	$tabform->submit();
    $output .= $tabform->print;

	my $ac = WebGUI::AdminConsole->new($session,"settings");
	$ac->setHelp("settings");
	return $ac->render($output);
}

#----------------------------------------------------------------------------

=head2 www_saveSettings ( $session )

Form postprocessor for www_editSettings.  Returns adminOnly() unless the user
is in group Admin (3).  Returns the user to the Edit Settings screen, www_editSettings.

=cut

sub www_saveSettings {
	my $session     = shift;
	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	my $i18n        = WebGUI::International->new($session, "WebGUI");
	my $setting     = $session->setting;
	my $form        = $session->form;
    my @errors;     # Errors trying to save the form

	my $definitions = definition($session, $i18n);
	foreach my $definition (@{$definitions}) {
		$setting->set($definition->{name}, $form->process($definition->{name}, $definition->{fieldType}, undef, $definition));
	}

	foreach (@{$session->config->get("authMethods")}) {
		my $authInstance    = WebGUI::Operation::Auth::getInstance($session,$_,1);

		my $authErrors          = $authInstance->editUserSettingsFormSave;
        if ($authErrors) {
            push @errors, @{ $authErrors };
        }
	}

	return www_editSettings($session, { errors => \@errors, message => $i18n->get("editSettings done") });
}

1;

