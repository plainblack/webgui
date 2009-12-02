package WebGUI::Operation::Settings;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
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
	my $session     = shift;
	my $i18n        = shift;
	my @fields      = ();
    my $setting     = $session->setting;
	# company info
	push(@fields, {
		tab=>"company",
		fieldType=>"text",
		name=>"companyName",
		label=>$i18n->get(125),
		hoverHelp=>$i18n->get('125 description'),
		defaultValue=>$setting->get("companyName")
		});
	push(@fields, {
		tab=>"company",
		fieldType=>"text",
		name=>"companyEmail",
		label=>$i18n->get(126),
		hoverHelp=>$i18n->get('126 description'),
		defaultValue=>$setting->get("companyEmail")
		});
	push(@fields, {
		tab=>"company",
		fieldType=>"url",
		name=>"companyURL",
		label=>$i18n->get(127),
		hoverHelp=>$i18n->get('127 description'),
		defaultValue=>$setting->get("companyURL")
		});

	# content settings
	push(@fields, {
		tab=>"content",
		fieldType=>"workflow",
		name=>"defaultVersionTagWorkflow",
		defaultValue=>$setting->get("defaultVersionTagWorkflow"),
		type=>"WebGUI::VersionTag",
		label=>$i18n->get("default version tag workflow"),
		hoverHelp=>$i18n->get('default version tag workflow help'),
		});

        # Support for versionTagMode. We'll have:
        # - multi version tag per user
        # - one version tag per user (SwiftySite mode)
        # - one site wide version tag
        # - auto commit
        push (
            @fields,
            {   tab          => q{content},
		fieldType    => q{selectBox},
                name         => q{versionTagMode},
                defaultValue => [ $setting->get(q{versionTagMode}) ],
                options      => {
                    multiPerUser  => $i18n->get(q{versionTagMode multiPerUser}),
                    singlePerUser => $i18n->get(q{versionTagMode singlePerUser}),
                    siteWide      => $i18n->get(q{versionTagMode siteWide}),
                    autoCommit    => $i18n->get(q{versionTagMode autoCommit}),
                },
                label        => $i18n->get(q{version tag mode}),
                hoverHelp    => $i18n->get(q{version tag mode help}),
            },
        );

	push(@fields, {
		tab=>"content",
		fieldType=>"yesNo",
        name=>"skipCommitComments",
        label=>$i18n->get("skip commit comments"),
        hoverHelp=>$i18n->get("skip commit comments"),
        defaultValue=>$setting->get("skipCommitComments")
		});
	push(@fields, {
		tab=>"content",
		fieldType=>"workflow",
		name=>"trashWorkflow",
		defaultValue=>$setting->get("trashWorkflow"),
		type=>"None",
		label=>$i18n->get("trash workflow"),
		hoverHelp=>$i18n->get('trash workflow help'),
        none => 1,
		});
	push(@fields, {
		tab=>"content",
		fieldType=>"workflow",
		name=>"purgeWorkflow",
		defaultValue=>$setting->get("purgeWorkflow"),
		type=>"None",
		label=>$i18n->get("purge workflow"),
		hoverHelp=>$i18n->get('purge workflow help'),
        none => 1,
		});
	push(@fields, {
		tab=>"content",
		fieldType=>"workflow",
		name=>"changeUrlWorkflow",
		defaultValue=>$setting->get("changeUrlWorkflow"),
		type=>"None",
		label=>$i18n->get("changeUrl workflow"),
		hoverHelp=>$i18n->get('changeUrl workflow help'),
        none => 1,
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
		defaultValue=>$setting->get("defaultPage")
		});
	push(@fields, {
		tab=>"content",
		fieldType=>"asset",
		name=>"notFoundPage",
		label=>$i18n->get(141),
		hoverHelp=>$i18n->get('141 description'),
		defaultValue=>$setting->get("notFoundPage")
		});
	push(@fields, {
		tab=>"content",
		fieldType=>"text",
		name=>"urlExtension",
		defaultValue=>$setting->get("urlExtension"),
		label=>$i18n->get("url extension"),
		hoverHelp=>$i18n->get("url extension description"),
		});
	push(@fields, {
		tab=>"content",
		fieldType=>"integer",
		name=>"maxAttachmentSize",
		label=>$i18n->get(130),
		hoverHelp=>$i18n->get('130 description'),
		defaultValue=>$setting->get("maxAttachmentSize")
		});
	push(@fields, {
		tab=>"content",
		fieldType=>"integer",
		name=>"maxImageSize",
		label=>$i18n->get(583),
		hoverHelp=>$i18n->get('583 description'),
		defaultValue=>$setting->get("maxImageSize")
		});
	push(@fields, {
		tab=>"content",
		fieldType=>"integer",
		name=>"thumbnailSize",
		label=>$i18n->get(406),
		hoverHelp=>$i18n->get('406 description'),
		defaultValue=>$setting->get("thumbnailSize")
		});
	push(@fields, {
		tab=>"content",
		fieldType=>"yesNo",
        name=>"metaDataEnabled",
        label=>$i18n->get("Enable Metadata"),
        hoverHelp=>$i18n->get("Enable Metadata description"),
        defaultValue=>$setting->get("metaDataEnabled")
		});
	push(@fields, {
		tab=>"content",
		fieldType=>"interval",
        name=>"maxCacheTimeout",
        label=>$i18n->get("Maximum cache timeout"),
        hoverHelp=>$i18n->get("Maximum cache timeout description"),
        defaultValue=>$setting->get("maxCacheTimeout")
		});
	# user interface settings
	push(@fields, {
		tab=>"ui",
		fieldType=>"selectBox",
		name=>"richEditor",
		label=>$i18n->get("default rich editor"),
		hoverHelp=>$i18n->get("default rich editor description"),
		defaultValue=>[$setting->get("richEditor") || "PBrichedit000000000001"],
		options=>WebGUI::Asset::RichEdit->getList($session)
		});
	push(@fields, {
		tab=>"ui",
		fieldType=>"integer",
		name=>"textBoxSize",
		label=>$i18n->get(465),
		hoverHelp=>$i18n->get('465 description'),
		defaultValue=>$setting->get("textBoxSize")
		});
	push(@fields, {
		tab=>"ui",
		fieldType=>"template",
		name=>"userFunctionStyleId",
		label=>$i18n->get('user function style'),
		hoverHelp=>$i18n->get('user function style description'),
		namespace=>"style",
		defaultValue=>$setting->get("userFunctionStyleId")
		});
	push(@fields, {
		tab=>"ui",
		fieldType=>"template",
		name=>"AdminConsoleTemplate",
		label=>$i18n->get('admin console template'),
		hoverHelp=>$i18n->get('admin console template description'),
		namespace=>"AdminConsole",
		defaultValue=>$setting->get("AdminConsoleTemplate")
		});
    push(@fields, {
        tab             => "ui",
        fieldType       => "yesNo",
        name            => "useRecaptcha",
        label           => $i18n->get('use recaptcha'),
        hoverHelp       => $i18n->get('use recaptcha description'),
        defaultValue    => $setting->get('useRecaptcha'),
    });
    push(@fields, {
        tab             => "ui",
        fieldType       => "text",
        name            => "recaptchaPublicKey",
        label           => $i18n->get('recaptcha public key'),
        defaultValue    => $setting->get('recaptchaPublicKey'),
    });
    push(@fields, {
        tab             => "ui",
        fieldType       => "text",
        name            => "recaptchaPrivateKey",
        label           => $i18n->get('recaptcha private key'),
        defaultValue    => $setting->get('recaptchaPrivateKey'),
    });
    push @fields, {
        tab             => "ui",
        fieldType       => "codearea",
        name            => "globalHeadTags",
        label           => $i18n->get('global head tags label'),
        hoverHelp       => $i18n->get('global head tags description'),
        defaultValue    => $setting->get('globalHeadTags'),
    };
    push @fields, {
        tab             => 'ui',
        fieldType       => 'yesNo',
        name            => 'useMobileStyle',
        label           => $i18n->get('mobile style label'),
        hoverHelp       => $i18n->get('mobile style description'),
        defaultValue    => $setting->get('useMobileStyle'),
    };
	# messaging settings
	push(@fields, {
		tab=>"messaging",
		fieldType=>"text",
		name=>"smtpServer",
		label=>$i18n->get(135),
		hoverHelp=>$i18n->get('135 description'),
		defaultValue=>$setting->get("smtpServer")
		});
	push(@fields, {
		tab=>"messaging",
		fieldType=>"textarea",
		name=>"mailFooter",
		label=>$i18n->get(824),
		hoverHelp=>$i18n->get('824 description'),
		defaultValue=>$setting->get("mailFooter")
		});
	push(@fields, {
		tab=>"messaging",
		fieldType=>"email",
		name=>"mailReturnPath",
		label=>$i18n->get("mail return path"),
		hoverHelp=>$i18n->get('mail return path help'),
		defaultValue=>$setting->get("mailReturnPath")
		});
	push(@fields, {
		tab          => 'messaging',
		fieldType    => 'text',
		name         => 'smsGateway',
		label        => $i18n->get('sms gateway'),
		hoverHelp    => $i18n->get('sms gateway help'),
		defaultValue => $setting->get('smsGateway'),
        });
    push(@fields, {
		tab          => 'messaging',
		fieldType    => 'text',
		name         => 'smsGatewaySubject',
		label        => $i18n->get('sms gateway subject'),
		hoverHelp    => $i18n->get('sms gateway subject help'),
		defaultValue => $setting->get('smsGatewaySubject'),
		});
	# misc
	push(@fields, {
		tab=>"misc",
		fieldType=>"yesNo",
		name=>"preventProxyCache",
		label=>$i18n->get(400),
		hoverHelp=>$i18n->get('400 description'),
		defaultValue=>$setting->get("preventProxyCache")
		});
	push(@fields, {
		tab=>"misc",
		fieldType=>"text",
		name=>"debugIp",
		label=>$i18n->get("debug ip"),
		hoverHelp=>$i18n->get("debug ip description"),
		defaultValue=>$setting->get("debugIp")
		});
	push(@fields, {
		tab=>"misc",
		fieldType=>"yesNo",
		name=>"showDebug",
		label=>$i18n->get(707),
		hoverHelp=>$i18n->get('707 description'),
		defaultValue=>$setting->get("showDebug")
		});
	push(@fields, {
		tab=>"misc",
		fieldType=>"yesNo",
		name=>"showPerformanceIndicators",
		label=>$i18n->get('show performance indicators'),
		hoverHelp=>$i18n->get('show performance indicators description'),
		defaultValue=>$setting->get("showPerformanceIndicators")
		});
	push(@fields, {
		tab=>"misc",
		fieldType=>"selectBox",
		name=>"hostToUse",
		defaultValue=>[$setting->get("hostToUse")],
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
		defaultValue=>$setting->get("anonymousRegistration")
		});
	push(@fields, {
		tab=>"user",
		fieldType=>"yesNo",
                name=>"automaticLDAPRegistration",
                label=>$i18n->echo("Automatic LDAP Registration"),
                hoverHelp=>$i18n->echo('When set to yes, a WebGUI user account will be created and the user logged in, if the credentials entered are validated by LDAP.'),
		defaultValue=>$setting->get("automaticLDAPRegistration")
                });
	push(@fields, {
		tab=>"user",
		fieldType=>"workflow",
		none=>1,
		type=>"WebGUI::User",
		name=>"runOnRegistration",
		label=>$i18n->get(559),
		hoverHelp=>$i18n->get('559 description'),
		defaultValue=>$setting->get("runOnRegistration")
		});
    push(@fields, { 
        fieldType       => "workflow",
        tab             => "user",
        none            => 1,
        name            => "runOnAdminCreateUser",
        defaultValue    => $setting->get("runOnAdminCreateUser"),
        label           => $i18n->get("run on admin create user"),
        hoverHelp       => $i18n->get("run on admin create user help"),
        type            => "WebGUI::User",
        });
    push(@fields, { 
        fieldType       => "workflow",
        tab             => "user",
        none            => 1,
        name            => "runOnAdminUpdateUser",
        defaultValue    => $setting->get("runOnAdminUpdateUser"),
        label           => $i18n->get("run on admin update user"),
        hoverHelp       => $i18n->get("run on admin update user help"),
        type            => "WebGUI::User",
        });
	push(@fields, {
		tab=>"user",
		fieldType=>"yesNo",
		name=>"useKarma",
		label=>$i18n->get(539),
		hoverHelp=>$i18n->get('539 description'),
		defaultValue=>$setting->get("useKarma")
		});
	push(@fields, {
		tab=>"user",
		fieldType=>"integer",
		name=>"karmaPerLogin",
		label=>$i18n->get(540),
		hoverHelp=>$i18n->get('540 description'),
		defaultValue=>$setting->get("karmaPerLogin")
		});
	push(@fields, {
		tab=>"user",
		fieldType=>"interval",
		name=>"sessionTimeout",
		label=>$i18n->get(142),
		hoverHelp=>$i18n->get('142 description'),
		defaultValue=>$setting->get("sessionTimeout")
		});
	push(@fields, {
		tab=>"user",
		fieldType=>"yesNo",
		name=>"selfDeactivation",
		label=>$i18n->get(885),
		hoverHelp=>$i18n->get('885 description'),
		defaultValue=>$setting->get("selfDeactivation")
		});
	push(@fields, {
		tab         => "user",
		fieldType   => ($session->config->get("sslEnabled") ? 'yesNo' : 'hidden'),
		name        => "encryptLogin",
		label       => $i18n->get(1006),
		hoverHelp   => $i18n->get('1006 description'),
		defaultValue=> $setting->get("encryptLogin"),
		});
	push(@fields, {
		tab=>"user",
		fieldType=>"yesNo",
                name=>"passiveProfilingEnabled",
                label=>$i18n->get("Enable passive profiling"),
                hoverHelp=>$i18n->get("Enable passive profiling description"),
                defaultValue=>$setting->get("passiveProfilingEnabled"),
                extras=>'onchange="alert(\''.$i18n->get("Illegal Warning").'\')" '
		});
    push @fields, {
        tab             => "user",
        name            => "redirectAfterLoginUrl",
        fieldType       => "url",
        defaultValue    => $setting->get('redirectAfterLoginUrl'),
        label           => $i18n->get( 'redirectAfterLoginUrl label' ),
        hoverHelp       => $i18n->get( 'redirectAfterLoginUrl description' ),
    };
    push @fields, {
        tab             => "user",
        name            => "showMessageOnLogin",
        fieldType       => "yesNo",
        defaultValue    => $setting->get('showMessageOnLogin'),
        label           => $i18n->get( 'showMessageOnLogin label' ),
        hoverHelp       => $i18n->get( 'showMessageOnLogin description' ),
    };
    push @fields, {
        tab             => "user",
        name            => "showMessageOnLoginTimes",
        fieldType       => "integer",
        defaultValue    => $setting->get('showMessageOnLoginTimes'),
        label           => $i18n->get( 'showMessageOnLoginTimes label' ),
        hoverHelp       => $i18n->get( 'showMessageOnLoginTimes description' ),
    };
    push @fields, { 
        tab             => "user",
        name            => 'showMessageOnLoginReset',
        fieldType       => 'yesNo',
        defaultValue    => 0,
        label           => $i18n->get( 'showMessageOnLoginReset label' ),
        hoverHelp       => $i18n->get( 'showMessageOnLoginReset description' ),
    };
    push @fields, {
        tab             => "user",
        name            => 'showMessageOnLoginBody',
        fieldType       => 'HTMLArea',
        label           => $i18n->get( 'showMessageOnLoginBody label' ),
        hoverHelp       => $i18n->get( 'showMessageOnLoginBody description' ),
        defaultValue    => $setting->get('showMessageOnLoginBody'),
    };
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
		defaultValue=>[$setting->get("authMethod")],
		});

    # Administrative permissions
    my @groupSettings = qw(
        groupIdAdminActiveSessions
        groupIdAdminAdSpace
        groupIdAdminCache
        groupIdAdminClipboard
        groupIdAdminCron
        groupIdAdminDatabaseLink
        groupIdAdminFilePump
        groupIdAdminGraphics
        groupIdAdminGroup
        groupIdAdminGroupAdmin
        groupIdAdminHistory
        groupIdAdminHelp
        groupIdAdminLDAPLink
        groupIdAdminLoginHistory
        groupIdAdminProfileSettings
        groupIdAdminReplacements
        groupIdAdminSpectre
        groupIdAdminStatistics
        groupIdAdminTrash
        groupIdAdminUser
        groupIdAdminUserAdd
        groupIdAdminVersionTag
        groupIdAdminWorkflow
        groupIdAdminWorkflowRun
    );

    for my $group (@groupSettings) {
        push @fields, {
            tab             => 'perms',
            fieldType       => 'group',
            name            => $group,
            label           => $i18n->get("settings $group label"),
            hoverHelp       => $i18n->get("settings $group hoverHelp"),
            defaultValue    => $setting->get($group),
        };
    }


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
	return $session->privilege->adminOnly() unless ($session->user->isAdmin);
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
        account     => { label => $i18n->get("account settings tab")},
        user        => { label => $i18n->get("user") },
        auth        => { label => $i18n->get("authentication") },
        perms       => { label => $i18n->get("permissions") },
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

     # Get fieldsets for avaiable account methods
    my $accountConfigs = $session->config->get("account");

	foreach my $account (@{$accountConfigs}) {
        #Create the instance
        my $className = $account->{className};
		my $instance = eval { WebGUI::Pluggable::instanciate($className,"new",[ $session ]) };
        if ( $@ ) {
            $session->log->warn("Could not instantiate account pluggin $className...skipping");
            next;
        }
        
        #Get the content of the settings form from the instance
        my $settingsForm = eval { $instance->editSettingsForm };
        if( $@ ) {
            $session->log->warn("Error calling editSettingsForm in $className...skipping : ".$@);
            next;
        }

        #If editUserSettingsForm is empty, skip it
        next if $settingsForm eq "";

        #Set the title of the fieldset
        my $title = $account->{title};
        WebGUI::Macro::process($title);

        #Print the settings form for this account pluggin
		$tabform->getTab("account")->fieldSetStart($title);
		$tabform->getTab("account")->raw($settingsForm);
		$tabform->getTab("account")->fieldSetEnd;
	}

	$tabform->submit();
    $output .= $tabform->print;

	my $ac = WebGUI::AdminConsole->new($session,"settings");
	return $ac->render($output);
}

#----------------------------------------------------------------------------

=head2 www_saveSettings ( $session )

Form postprocessor for www_editSettings.  Returns adminOnly() unless the user
is in group Admin (3).  Returns the user to the Edit Settings screen, www_editSettings.

=cut

sub www_saveSettings {
    my $session     = shift;
    return $session->privilege->adminOnly() unless ($session->user->isAdmin && $session->form->validToken);
    my $i18n        = WebGUI::International->new($session, "WebGUI");
    my $setting     = $session->setting;
    my $form        = $session->form;
    my @errors;     # Errors trying to save the form

    my $definitions = definition($session, $i18n);
    foreach my $definition (@{$definitions}) {
        next if ( $definition->{ noFormPost } );
        $setting->set($definition->{name}, $form->process($definition->{name}, $definition->{fieldType}, undef, $definition));
    }

    foreach (@{$session->config->get("authMethods")}) {
        my $authInstance    = WebGUI::Operation::Auth::getInstance($session,$_,1);

        my $authErrors          = $authInstance->editUserSettingsFormSave;
        if ($authErrors) {
            push @errors, @{ $authErrors };
        }
    }

    # Save account pluggin settings
    my $accountConfigs = $session->config->get("account");
	foreach my $account (@{$accountConfigs}) {
        #Create the instance
        my $className = $account->{className};
		my $instance = eval { WebGUI::Pluggable::instanciate($className,"new",[ $session ]) };

        if ( my $e = WebGUI::Error->caught ) {
            $session->log->warn("Could not instantiate account pluggin $className...skipping");
            next;
        }
        #Save the settings
        eval { $instance->editSettingsFormSave };
        
        if( $@ ) {
            $session->log->warn("Error calling editSettingsFormSave in $className...skipping : ".$@);
            next;
        }
	}

    ### Handle special settings
    # Reset login message seen numbers
    if ( $session->form->get( 'showMessageOnLoginReset' ) ) {
        $session->db->write( 
            "UPDATE userProfileData SET showMessageOnLoginSeen=0"
        );
        # Delete the user cache
        WebGUI::Cache->new( $session, [ "user" ] )->deleteChunk( [ "user" ] );
    }

    return www_editSettings($session, { errors => \@errors, message => $i18n->get("editSettings done") });
}

1;

