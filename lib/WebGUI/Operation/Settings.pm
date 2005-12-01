package WebGUI::Operation::Settings;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
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
use WebGUI::DateTime;
use WebGUI::Grouping;
use WebGUI::TabForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::Setting;
use WebGUI::Style;
use WebGUI::SQL;
use WebGUI::URL;

#-------------------------------------------------------------------
sub www_editSettings {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my $i18n = WebGUI::International->new("WebGUI");
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
 	my $tabform = WebGUI::TabForm->new(\%tabs);
	$tabform->hidden({
		name=>"op",
		value=>"saveSettings"});
# company settings
        $tabform->getTab("company")->text(
		-name=>"companyName",
		-label=>$i18n->get(125),
		-hoverHelp=>$i18n->get('125 description'),
		-value=>$session{setting}{companyName}
		);
        $tabform->getTab("company")->text(
		-name=>"companyEmail",
		-label=>$i18n->get(126),
		-hoverHelp=>$i18n->get('126 description'),
		-value=>$session{setting}{companyEmail}
		);
        $tabform->getTab("company")->url(
		-name=>"companyURL",
		-label=>$i18n->get(127),
		-hoverHelp=>$i18n->get('127 description'),
		-value=>$session{setting}{companyURL}
		);
# content settings
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
		-value=>$session{setting}{defaultPage}
		);
        $tabform->getTab("content")->asset(
		-name=>"notFoundPage",
		-label=>$i18n->get(141),
		-hoverHelp=>$i18n->get('141 description'),
		-value=>$session{setting}{notFoundPage}
		);
	$tabform->getTab("content")->text(
		-name=>"urlExtension",
		-value=>$session{setting}{urlExtension},
		-label=>$i18n->get("url extension"),
		-hoverHelp=>$i18n->get("url extension description"),
		);
        $tabform->getTab("content")->integer(
		-name=>"maxAttachmentSize",
		-label=>$i18n->get(130),
		-hoverHelp=>$i18n->get('130 description'),
		-value=>$session{setting}{maxAttachmentSize}
		);
        $tabform->getTab("content")->integer(
		-name=>"maxImageSize",
		-label=>$i18n->get(583),
		-hoverHelp=>$i18n->get('583 description'),
		-value=>$session{setting}{maxImageSize}
		);
        $tabform->getTab("content")->integer(
		-name=>"thumbnailSize",
		-label=>$i18n->get(406),
		-hoverHelp=>$i18n->get('406 description'),
		-value=>$session{setting}{thumbnailSize}
		);
	 $tabform->getTab("content")->yesNo(
                -name=>"autoCommit",
                -label=>WebGUI::International::get("enable autocommit of asset versioning","Asset"),
                -value=>$session{setting}{autoCommit}
        	);
	 $tabform->getTab("content")->yesNo(
                -name=>"metaDataEnabled",
                -label=>$i18n->get("Enable Metadata"),
                -hoverHelp=>$i18n->get("Enable Metadata description"),
                -value=>$session{setting}{metaDataEnabled}
        	);
# user interface settings
	$tabform->getTab("ui")->selectBox(
		-name=>"richEditor",
		-label=>$i18n->get("default rich editor"),
		-hoverHelp=>$i18n->get("default rich editor description"),
		-value=>[$session{setting}{richEditor}],
		-options=>WebGUI::SQL->buildHashRef("select assetData.assetId,assetData.title from asset left join assetData on asset.assetId=assetData.assetId where asset.className='WebGUI::Asset::RichEdit' order by assetData.title"),
		-defaultValue=>["PBrichedit000000000001"]
		);
        $tabform->getTab("ui")->integer(
		-name=>"textAreaRows",
		-label=>$i18n->get(463),
		-hoverHelp=>$i18n->get('463 description'),
		-value=>$session{setting}{textAreaRows}
		);
        $tabform->getTab("ui")->integer(
		-name=>"textAreaCols",
		-label=>$i18n->get(464),
		-hoverHelp=>$i18n->get('464 description'),
		-value=>$session{setting}{textAreaCols}
		);
        $tabform->getTab("ui")->integer(
		-name=>"textBoxSize",
		-label=>$i18n->get(465),
		-hoverHelp=>$i18n->get('465 description'),
		-value=>$session{setting}{textBoxSize}
		);
	$tabform->getTab("ui")->template(
		-name=>"userFunctionStyleId",
		-label=>$i18n->get('user function style'),
		-hoverHelp=>$i18n->get('user function style description'),
		-namespace=>"style",
		-value=>$session{setting}{userFunctionStyleId}
		);
	$tabform->getTab("ui")->template(
		-name=>"AdminConsoleTemplate",
		-label=>$i18n->get('admin console template'),
		-hoverHelp=>$i18n->get('admin console template description'),
		-namespace=>"AdminConsole",
		-value=>$session{setting}{AdminConsoleTemplate}
		);
# messaging settings
        $tabform->getTab("messaging")->text(
		-name=>"smtpServer",
		-label=>$i18n->get(135),
		-hoverHelp=>$i18n->get('135 description'),
		-value=>$session{setting}{smtpServer}
		);
        $tabform->getTab("messaging")->textarea(
		-name=>"mailFooter",
		-label=>$i18n->get(824),
		-hoverHelp=>$i18n->get('824 description'),
		-value=>$session{setting}{mailFooter}
		);
        $tabform->getTab("messaging")->yesNo(
		-name=>"alertOnNewUser",
		-label=>$i18n->get(534),
		-hoverHelp=>$i18n->get('534 description'),
		-value=>$session{setting}{alertOnNewUser}
		);
        $tabform->getTab("messaging")->group(
		-name=>"onNewUserAlertGroup",
		-label=>$i18n->get(535),
		-hoverHelp=>$i18n->get('535 description'),
		-value=>[$session{setting}{onNewUserAlertGroup}]
	);
	$tabform->getTab("misc")->yesNo(
		-name=>"preventProxyCache",
		-label=>$i18n->get(400),
		-hoverHelp=>$i18n->get('400 description'),
		-value=>$session{setting}{preventProxyCache}
		);
	$tabform->getTab("misc")->text(
		-name=>"debugIp",
		-label=>$i18n->get("debug ip"),
		-hoverHelp=>$i18n->get("debug ip description"),
		-value=>$session{setting}{debugIp}
		);
	$tabform->getTab("misc")->yesNo(
		-name=>"showDebug",
		-label=>$i18n->get(707),
		-hoverHelp=>$i18n->get('707 description'),
		-value=>$session{setting}{showDebug}
		);
	$tabform->getTab("misc")->yesNo(
		-name=>"showPerformanceIndicators",
		-label=>$i18n->get('show performance indicators'),
		-hoverHelp=>$i18n->get('show performance indicators description'),
		-value=>$session{setting}{showPerformanceIndicators}
		);
	$tabform->getTab("misc")->selectBox(
		-name=>"hostToUse",
		-value=>[$session{setting}{hostToUse}],
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
		-value=>$session{setting}{anonymousRegistration}
		);
   	$tabform->getTab("user")->text(
		-name=>"runOnRegistration",
		-label=>$i18n->get(559),
		-hoverHelp=>$i18n->get('559 description'),
		-value=>$session{setting}{runOnRegistration}
		);
   	$tabform->getTab("user")->yesNo(
		-name=>"useKarma",
		-label=>$i18n->get(539),
		-hoverHelp=>$i18n->get('539 description'),
		-value=>$session{setting}{useKarma}
		);
   	$tabform->getTab("user")->integer(
		-name=>"karmaPerLogin",
		-label=>$i18n->get(540),
		-hoverHelp=>$i18n->get('540 description'),
		-value=>$session{setting}{karmaPerLogin}
		);
   	$tabform->getTab("user")->interval(
		-name=>"sessionTimeout",
		-label=>$i18n->get(142),
		-hoverHelp=>$i18n->get('142 description'),
		-value=>$session{setting}{sessionTimeout}
		);
   	$tabform->getTab("user")->yesNo(
		-name=>"selfDeactivation",
		-label=>$i18n->get(885),
		-hoverHelp=>$i18n->get('885 description'),
		-value=>$session{setting}{selfDeactivation}
		);
   	$tabform->getTab("user")->yesNo(
		-name=>"encryptLogin",
		-label=>$i18n->get(1006),
		-hoverHelp=>$i18n->get('1006 description'),
		-value=>$session{setting}{encryptLogin}
		);
        $tabform->getTab("user")->yesNo(
                -name=>"passiveProfilingEnabled",
                -label=>$i18n->get("Enable passive profiling"),
                -hoverHelp=>$i18n->get("Enable passive profiling description"),
                -value=>$session{setting}{passiveProfilingEnabled},
                -extras=>' onChange="alert(\''.$i18n->get("Illegal Warning").'\')" '
        );
# auth settings 
	WebGUI::Style::setScript($session{config}{extrasURL}."/swapLayers.js",{type=>"text/javascript"});
	WebGUI::Style::setRawHeadTags('<script type="text/javascript" >var active="'.$session{setting}{authMethod}.'";</script>');
   	my $options;
   	foreach (@{$session{config}{authMethods}}) {
      		$options->{$_} = $_;
   	}
   	$tabform->getTab("auth")->selectBox(
            	-name=>"authMethod",
		-options=>$options,
		-label=>$i18n->get(164),
		-hoverHelp=>$i18n->get('164 description'),
		-value=>[$session{setting}{authMethod}],
		-extras=>"onChange=\"active=operateHidden(this.options[this.selectedIndex].value,active)\""
		);
	foreach (@{$session{config}{authMethods}}) {
		my $authInstance = WebGUI::Operation::Auth::getInstance($_,1);
		my $style = '" style="display: none;' unless ($_ eq $session{setting}{authMethod});
		$tabform->getTab("auth")->raw('<tr id="'.$_.$style.'"><td colspan="2" width="100%"><table border="0" cellspacing="0" cellpadding="0" width="100%">'.$authInstance->editUserSettingsForm.'<tr><td width="304">&nbsp;</td><td width="496">&nbsp;</td></tr></table></td></tr>');
	}
	$tabform->submit();
	my $ac = WebGUI::AdminConsole->new("settings");
	$ac->setHelp("settings");
	return $ac->render($tabform->print);
}

#-------------------------------------------------------------------
sub www_saveSettings {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my ($key, $value);
	foreach $key (keys %{$session{form}}) {
		$value = $session{form}{$key};
		if ($key =~ m/(.*)_interval/) {
			$value = WebGUI::FormProcessor::interval($1);
			$key = $1;
		} elsif ($key =~ m/_units/) {
			next;
		} 
		unless ($key eq "op") {
			WebGUI::Setting::set($key,$value);
		}
	}
	return www_editSettings();
}

1;

