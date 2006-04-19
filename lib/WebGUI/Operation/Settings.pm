package WebGUI::Operation::Settings;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
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

=head2 www_editSettings ( $session )

Display a form for sitewide settings, if the user is in group Admin (3).

=cut

#-------------------------------------------------------------------
sub www_editSettings {
	my $session = shift;
	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	my $i18n = WebGUI::International->new($session, "WebGUI");
	my %tabs;
	tie %tabs, 'Tie::IxHash';
 	%tabs = (
       		company=>{ label=>$i18n->get("company") },
        	content=>{ label=>$i18n->get("content") },
        	ui=>{ label=>$i18n->get("ui") },
        	messaging=>{ label=>$i18n->get("messaging") },
        	misc=>{ label=>$i18n->get("misc") },
        	user=>{ label=>$i18n->get("user") },
        	auth=>{ label=>$i18n->get("authentication") },
        );
 	my $tabform = WebGUI::TabForm->new($session,\%tabs);
	$tabform->hidden({
		name=>"op",
		value=>"saveSettings"});
# company settings
        $tabform->getTab("company")->text(
		-name=>"companyName",
		-label=>$i18n->get(125),
		-hoverHelp=>$i18n->get('125 description'),
		-value=>$session->setting->get("companyName")
		);
        $tabform->getTab("company")->text(
		-name=>"companyEmail",
		-label=>$i18n->get(126),
		-hoverHelp=>$i18n->get('126 description'),
		-value=>$session->setting->get("companyEmail")
		);
        $tabform->getTab("company")->url(
		-name=>"companyURL",
		-label=>$i18n->get(127),
		-hoverHelp=>$i18n->get('127 description'),
		-value=>$session->setting->get("companyURL")
		);
# content settings
	$tabform->getTab("content")->workflow(
		name=>"defaultVersionTagWorkflow",
		value=>$session->setting->get("defaultVersionTagWorkflow"),
		type=>"WebGUI::VersionTag",
		label=>$i18n->get("default version tag workflow"),
		hoverHelp=>$i18n->get('default version tag workflow help')
		);
        my %htmlFilter = (
		'none'=>$i18n->get(420), 
		'most'=>$i18n->get(421), 
		'javascript'=>$i18n->get(526), 
		'all'=>$i18n->get(419)
		);
        $tabform->getTab("content")->asset(
		-name=>"defaultPage",
		-label=>$i18n->get(527),
		-hoverHelp=>$i18n->get('527 description'),
		-value=>$session->setting->get("defaultPage")
		);
        $tabform->getTab("content")->asset(
		-name=>"notFoundPage",
		-label=>$i18n->get(141),
		-hoverHelp=>$i18n->get('141 description'),
		-value=>$session->setting->get("notFoundPage")
		);
	$tabform->getTab("content")->text(
		-name=>"urlExtension",
		-value=>$session->setting->get("urlExtension"),
		-label=>$i18n->get("url extension"),
		-hoverHelp=>$i18n->get("url extension description"),
		);
        $tabform->getTab("content")->integer(
		-name=>"maxAttachmentSize",
		-label=>$i18n->get(130),
		-hoverHelp=>$i18n->get('130 description'),
		-value=>$session->setting->get("maxAttachmentSize")
		);
        $tabform->getTab("content")->integer(
		-name=>"maxImageSize",
		-label=>$i18n->get(583),
		-hoverHelp=>$i18n->get('583 description'),
		-value=>$session->setting->get("maxImageSize")
		);
        $tabform->getTab("content")->integer(
		-name=>"thumbnailSize",
		-label=>$i18n->get(406),
		-hoverHelp=>$i18n->get('406 description'),
		-value=>$session->setting->get("thumbnailSize")
		);
	 $tabform->getTab("content")->yesNo(
                -name=>"metaDataEnabled",
                -label=>$i18n->get("Enable Metadata"),
                -hoverHelp=>$i18n->get("Enable Metadata description"),
                -value=>$session->setting->get("metaDataEnabled")
        	);
# user interface settings
	$tabform->getTab("ui")->selectBox(
		-name=>"richEditor",
		-label=>$i18n->get("default rich editor"),
		-hoverHelp=>$i18n->get("default rich editor description"),
		-value=>[$session->setting->get("richEditor")],
		-options=>WebGUI::Asset::RichEdit->getList($session),
		-defaultValue=>["PBrichedit000000000001"]
		);
        $tabform->getTab("ui")->integer(
		-name=>"textBoxSize",
		-label=>$i18n->get(465),
		-hoverHelp=>$i18n->get('465 description'),
		-value=>$session->setting->get("textBoxSize")
		);
	$tabform->getTab("ui")->template(
		-name=>"userFunctionStyleId",
		-label=>$i18n->get('user function style'),
		-hoverHelp=>$i18n->get('user function style description'),
		-namespace=>"style",
		-value=>$session->setting->get("userFunctionStyleId")
		);
	$tabform->getTab("ui")->template(
		-name=>"AdminConsoleTemplate",
		-label=>$i18n->get('admin console template'),
		-hoverHelp=>$i18n->get('admin console template description'),
		-namespace=>"AdminConsole",
		-value=>$session->setting->get("AdminConsoleTemplate")
		);
# messaging settings
        $tabform->getTab("messaging")->text(
		-name=>"smtpServer",
		-label=>$i18n->get(135),
		-hoverHelp=>$i18n->get('135 description'),
		-value=>$session->setting->get("smtpServer")
		);
        $tabform->getTab("messaging")->textarea(
		-name=>"mailFooter",
		-label=>$i18n->get(824),
		-hoverHelp=>$i18n->get('824 description'),
		-value=>$session->setting->get("mailFooter")
		);
        $tabform->getTab("messaging")->email(
		-name=>"mailReturnPath",
		-label=>$i18n->get("mail return path"),
		-hoverHelp=>$i18n->get('mail return path help'),
		-value=>$session->setting->get("mailReturnPath")
		);
# misc
	$tabform->getTab("misc")->yesNo(
		-name=>"preventProxyCache",
		-label=>$i18n->get(400),
		-hoverHelp=>$i18n->get('400 description'),
		-value=>$session->setting->get("preventProxyCache")
		);
	$tabform->getTab("misc")->text(
		-name=>"debugIp",
		-label=>$i18n->get("debug ip"),
		-hoverHelp=>$i18n->get("debug ip description"),
		-value=>$session->setting->get("debugIp")
		);
	$tabform->getTab("misc")->yesNo(
		-name=>"showDebug",
		-label=>$i18n->get(707),
		-hoverHelp=>$i18n->get('707 description'),
		-value=>$session->setting->get("showDebug")
		);
	$tabform->getTab("misc")->yesNo(
		-name=>"showPerformanceIndicators",
		-label=>$i18n->get('show performance indicators'),
		-hoverHelp=>$i18n->get('show performance indicators description'),
		-value=>$session->setting->get("showPerformanceIndicators")
		);
	$tabform->getTab("misc")->selectBox(
		-name=>"hostToUse",
		-value=>[$session->setting->get("hostToUse")],
		-options=>{
			sitename=>$i18n->get(1070),
			HTTP_HOST=>$i18n->get(1071)
			},
		-label=>$i18n->get(1069),
		-hoverHelp=>$i18n->get('1069 description'),
		);
# user settings
	$tabform->getTab("user")->yesNo(
		-name=>"anonymousRegistration",
		-label=>$i18n->get(118),
		-hoverHelp=>$i18n->get('118 description'),
		-value=>$session->setting->get("anonymousRegistration")
		);
   	$tabform->getTab("user")->workflow(
		-none=>1,
		-type=>"WebGUI::User",
		-name=>"runOnRegistration",
		-label=>$i18n->get(559),
		-hoverHelp=>$i18n->get('559 description'),
		-value=>$session->setting->get("runOnRegistration")
		);
   	$tabform->getTab("user")->yesNo(
		-name=>"useKarma",
		-label=>$i18n->get(539),
		-hoverHelp=>$i18n->get('539 description'),
		-value=>$session->setting->get("useKarma")
		);
   	$tabform->getTab("user")->integer(
		-name=>"karmaPerLogin",
		-label=>$i18n->get(540),
		-hoverHelp=>$i18n->get('540 description'),
		-value=>$session->setting->get("karmaPerLogin")
		);
   	$tabform->getTab("user")->interval(
		-name=>"sessionTimeout",
		-label=>$i18n->get(142),
		-hoverHelp=>$i18n->get('142 description'),
		-value=>$session->setting->get("sessionTimeout")
		);
   	$tabform->getTab("user")->yesNo(
		-name=>"selfDeactivation",
		-label=>$i18n->get(885),
		-hoverHelp=>$i18n->get('885 description'),
		-value=>$session->setting->get("selfDeactivation")
		);
   	$tabform->getTab("user")->yesNo(
		-name=>"encryptLogin",
		-label=>$i18n->get(1006),
		-hoverHelp=>$i18n->get('1006 description'),
		-value=>$session->setting->get("encryptLogin")
		);
        $tabform->getTab("user")->yesNo(
                -name=>"passiveProfilingEnabled",
                -label=>$i18n->get("Enable passive profiling"),
                -hoverHelp=>$i18n->get("Enable passive profiling description"),
                -value=>$session->setting->get("passiveProfilingEnabled"),
                -extras=>'onchange="alert(\''.$i18n->get("Illegal Warning").'\')" '
        );
# auth settings 
	$session->style->setScript($session->config->get("extrasURL")."/swapLayers.js",{type=>"text/javascript"});
	$session->style->setRawHeadTags('<script type="text/javascript" >var active="'.$session->setting->get("authMethod").'";</script>');
   	my $options;
   	foreach (@{$session->config->get("authMethods")}) {
      		$options->{$_} = $_;
   	}
   	$tabform->getTab("auth")->selectBox(
            	-name=>"authMethod",
		-options=>$options,
		-label=>$i18n->get(164),
		-hoverHelp=>$i18n->get('164 description'),
		-value=>[$session->setting->get("authMethod")],
		-extras=>"onchange=\"active=operateHidden(this.options[this.selectedIndex].value,active)\""
		);
	foreach (@{$session->config->get("authMethods")}) {
		$tabform->getTab("auth")->fieldSetStart($_);
		my $authInstance = WebGUI::Operation::Auth::getInstance($session,$_,1);
		$tabform->getTab("auth")->raw($authInstance->editUserSettingsForm);
		$tabform->getTab("auth")->fieldSetEnd;
	}
	$tabform->submit();
	my $ac = WebGUI::AdminConsole->new($session,"settings");
	$ac->setHelp("settings");
	return $ac->render($tabform->print);
}

=head2 www_saveSettings ( $session )

Form postprocessor for www_editSettings.  Returns adminOnly() unless the user
is in group Admin (3).  Returns the user to the Edit Settings screen, www_editSettings.

=cut

#-------------------------------------------------------------------
sub www_saveSettings {
	my $session = shift;
	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	my ($key, $value);
	foreach $key (%{$session->form->paramsHashRef}) {
		$value = $session->form->process("$key");
		if ($key =~ m/(.*)_interval/) {
			$value = $session->form->interval($1);
			$key = $1;
		} elsif ($key =~ m/_units/) {
			next;
		} 
		unless ($key eq "op") {
			$session->setting->set($key,$value);
		}
	}
	return www_editSettings($session);
}

1;

