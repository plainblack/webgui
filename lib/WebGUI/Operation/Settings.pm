package WebGUI::Operation::Settings;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use Exporter;
use strict;
use WebGUI::DateTime;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_editUserSettings &www_editUserSettingsSave &www_editCompanyInformation 
	&www_editCompanyInformationSave &www_editPrivilegeSettings &www_editPrivilegeSettingsSave
	&www_editMailSettings &www_editMailSettingsSave &www_editMiscSettings 
	&www_editContentSettings &www_editContentSettingsSave &www_editMiscSettingsSave &www_manageSettings);

#-------------------------------------------------------------------
sub _saveSetting {
	WebGUI::SQL->write("update settings set value=".quote($session{form}{$_[0]})." where name='$_[0]'");
}

#-------------------------------------------------------------------
sub www_editUserSettings {
        my ($output, %authMethod, $f);
        %authMethod = ('WebGUI'=>'WebGUI', 'LDAP'=>'LDAP');
        if (WebGUI::Privilege::isInGroup(3)) {
                $output .= helpIcon(2);
                $output .= '<h1>'.WebGUI::International::get(117).'</h1>';
		$f = WebGUI::HTMLForm->new;
                $f->hidden("op","editUserSettingsSave");
                $f->yesNo("anonymousRegistration",WebGUI::International::get(118),$session{setting}{anonymousRegistration});
                $f->text("runOnRegistration",WebGUI::International::get(559),$session{setting}{runOnRegistration});
                $f->yesNo("alertOnNewUser",WebGUI::International::get(534),$session{setting}{alertOnNewUser});
		$f->group("onNewUserAlertGroup",WebGUI::International::get(535),[$session{setting}{onNewUserAlertGroup}]);
                $f->yesNo("useKarma",WebGUI::International::get(539),$session{setting}{useKarma});
                $f->integer("karmaPerLogin",WebGUI::International::get(540),$session{setting}{karmaPerLogin});
                $f->interval("sessionTimeout",WebGUI::International::get(142),WebGUI::DateTime::secondsToInterval($session{setting}{sessionTimeout}));
                $f->select("authMethod",\%authMethod,WebGUI::International::get(119),[$session{setting}{authMethod}]);
                $f->yesNo("usernameBinding",WebGUI::International::get(306),$session{setting}{usernameBinding});
                $f->url("ldapURL",WebGUI::International::get(120),$session{setting}{ldapURL});
                $f->text("ldapId",WebGUI::International::get(121),$session{setting}{ldapId});
                $f->text("ldapIdName",WebGUI::International::get(122),$session{setting}{ldapIdName});
                $f->text("ldapPasswordName",WebGUI::International::get(123),$session{setting}{ldapPasswordName});
		$f->submit;
		$output .= $f->print;
        } else {
                $output = WebGUI::Privilege::adminOnly();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_editUserSettingsSave {
        if (WebGUI::Privilege::isInGroup(3)) {
		$session{form}{sessionTimeout} = WebGUI::DateTime::intervalToSeconds($session{form}{sessionTimeout_interval},
			$session{form}{sessionTimeout_units});
		_saveSetting("sessionTimeout");
		_saveSetting("onNewUserAlertGroup");
		_saveSetting("alertOnNewUser");
		_saveSetting("authMethod");
		_saveSetting("useKarma");
		_saveSetting("karmaPerLogin");
		_saveSetting("ldapURL");
		_saveSetting("ldapId");
		_saveSetting("ldapIdName");
		_saveSetting("ldapPasswordName");
		_saveSetting("anonymousRegistration");
		_saveSetting("usernameBinding");
		_saveSetting("runOnRegistration");
                return www_manageSettings();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_editCompanyInformation {
        my ($output, $f);
        if (WebGUI::Privilege::isInGroup(3)) {
                $output .= helpIcon(6);
		$output .= '<h1>'.WebGUI::International::get(124).'</h1>';
		$f = WebGUI::HTMLForm->new;
                $f->hidden("op","editCompanyInformationSave");
                $f->text("companyName",WebGUI::International::get(125),$session{setting}{companyName});
                $f->email("companyEmail",WebGUI::International::get(126),$session{setting}{companyEmail});
                $f->url("companyURL",WebGUI::International::get(127),$session{setting}{companyURL});
		$f->submit;
		$output .= $f->print;
        } else {
                $output = WebGUI::Privilege::adminOnly();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_editCompanyInformationSave {
        if (WebGUI::Privilege::isInGroup(3)) {
		_saveSetting("companyName");
		_saveSetting("companyEmail");
		_saveSetting("companyURL");
                return www_manageSettings(); 
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_editContentSettings {
        my ($output, %htmlFilter, %editor, $f, $pages);
	$pages = WebGUI::SQL->buildHashRef("select pageId,menuTitle from page order by menuTitle");
        %htmlFilter = ('none'=>WebGUI::International::get(420), 'most'=>WebGUI::International::get(421), 
		'javascript'=>WebGUI::International::get(526), 'all'=>WebGUI::International::get(419));
        %editor = ('built-in'=>WebGUI::International::get(495), 'edit-on-pro'=>WebGUI::International::get(494));
        if (WebGUI::Privilege::isInGroup(3)) {
                $output .= helpIcon(29);
                $output .= '<h1>'.WebGUI::International::get(525).'</h1>';
                $f = WebGUI::HTMLForm->new;
                $f->hidden("op","editContentSettingsSave");
                $f->select("defaultPage",$pages,WebGUI::International::get(527),[$session{setting}{defaultPage}]);
                $f->select("notFoundPage",$pages,WebGUI::International::get(141),[$session{setting}{notFoundPage}]);
                $f->text("docTypeDec",WebGUI::International::get(398),$session{setting}{docTypeDec});
                $f->yesNo("addEditStampToPosts",WebGUI::International::get(524),$session{setting}{addEditStampToPosts});
                $f->select("filterContributedHTML",\%htmlFilter,WebGUI::International::get(418),[$session{setting}{filterContributedHTML}]);
                $f->integer("maxAttachmentSize",WebGUI::International::get(130),$session{setting}{maxAttachmentSize});
                $f->integer("maxImageSize",WebGUI::International::get(583),$session{setting}{maxImageSize});
                $f->integer("thumbnailSize",WebGUI::International::get(406),$session{setting}{thumbnailSize});
                $f->integer("textAreaRows",WebGUI::International::get(463),$session{setting}{textAreaRows});
                $f->integer("textAreaCols",WebGUI::International::get(464),$session{setting}{textAreaCols});
                $f->integer("textBoxSize",WebGUI::International::get(465),$session{setting}{textBoxSize});
                $f->select("richEditor",\%editor,WebGUI::International::get(496),[$session{setting}{richEditor}]);
                $f->submit;
                $output .= $f->print;
        } else {
                $output = WebGUI::Privilege::adminOnly();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_editContentSettingsSave {
        if (WebGUI::Privilege::isInGroup(3)) {
                _saveSetting("groupToManageImages");
                _saveSetting("addEditStampToPosts");
                _saveSetting("defaultPage");
                _saveSetting("notFoundPage");
                _saveSetting("docTypeDec");
                _saveSetting("filterContributedHTML");
                _saveSetting("textAreaRows");
                _saveSetting("textAreaCols");
                _saveSetting("textBoxSize");
                _saveSetting("richEditor");
                _saveSetting("maxImageSize");
                _saveSetting("maxAttachmentSize");
                _saveSetting("thumbnailSize");
                return www_manageSettings();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_editMailSettings {
        my ($output, $f);
        if (WebGUI::Privilege::isInGroup(3)) {
                $output .= helpIcon(13);
                $output .= '<h1>'.WebGUI::International::get(133).'</h1>';
		$f = WebGUI::HTMLForm->new;
                $f->hidden("op","editMailSettingsSave");
                $f->textarea("recoverPasswordEmail",WebGUI::International::get(134),$session{setting}{recoverPasswordEmail});
                $f->text("smtpServer",WebGUI::International::get(135),$session{setting}{smtpServer});
		$f->submit;
		$output .= $f->print;
        } else {
                $output = WebGUI::Privilege::adminOnly();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_editMailSettingsSave {
        if (WebGUI::Privilege::isInGroup(3)) {
		_saveSetting("recoverPasswordEmail");
		_saveSetting("smtpServer");
                return www_manageSettings();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_editMiscSettings {
        my ($output, $f);
        if (WebGUI::Privilege::isInGroup(3)) {
                $output .= helpIcon(24);
                $output .= '<h1>'.WebGUI::International::get(140).'</h1>';
		$f = WebGUI::HTMLForm->new;
                $f->hidden("op","editMiscSettingsSave");
		$f->yesNo("preventProxyCache",WebGUI::International::get(400),$session{setting}{preventProxyCache});
		$f->yesNo("showDebug",WebGUI::International::get(707),$session{setting}{showDebug});
		$f->yesNo("trackPageStatistics",WebGUI::International::get(749),$session{setting}{trackPageStatistics});
		$f->submit;
		$output .= $f->print;
        } else {
                $output = WebGUI::Privilege::adminOnly();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_editMiscSettingsSave {
        if (WebGUI::Privilege::isInGroup(3)) {
		_saveSetting("preventProxyCache");
		_saveSetting("showDebug");
		_saveSetting("trackPageStatistics");
                return www_manageSettings(); 
        } else {
                return WebGUI::Privilege::adminOnly();
	}
}

#-------------------------------------------------------------------
sub www_editPrivilegeSettings {
        my ($output, $f);
        if (WebGUI::Privilege::isInGroup(3)) {
                $output .= helpIcon(48);
                $output .= '<h1>'.WebGUI::International::get(710).'</h1>';
                $f = WebGUI::HTMLForm->new;
                $f->hidden("op","editPrivilegeSettingsSave");
                $f->group("imageManagersGroup",WebGUI::International::get(711),[$session{setting}{imageManagersGroup}]);
                $f->group("styleManagersGroup",WebGUI::International::get(713),[$session{setting}{styleManagersGroup}]);
                $f->group("templateManagersGroup",WebGUI::International::get(714),[$session{setting}{templateManagersGroup}]);
                $f->submit;
                $output .= $f->print;
        } else {
                $output = WebGUI::Privilege::adminOnly();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_editPrivilegeSettingsSave {
        if (WebGUI::Privilege::isInGroup(3)) {
                _saveSetting("imageManagersGroup");
                _saveSetting("styleManagersGroup");
                _saveSetting("templateManagersGroup");
                return www_manageSettings();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_manageSettings {
        my ($output);
        if (WebGUI::Privilege::isInGroup(3)) {
                $output .= helpIcon(12);
                $output .= '<h1>'.WebGUI::International::get(143).'</h1>';
                $output .= '<ul>';
                $output .= '<li><a href="'.WebGUI::URL::page('op=editCompanyInformation').'">'.WebGUI::International::get(124).'</a>';
                $output .= '<li><a href="'.WebGUI::URL::page('op=editContentSettings').'">'.WebGUI::International::get(525).'</a>';
                $output .= '<li><a href="'.WebGUI::URL::page('op=editMailSettings').'">'.WebGUI::International::get(133).'</a>';
                $output .= '<li><a href="'.WebGUI::URL::page('op=editMiscSettings').'">'.WebGUI::International::get(140).'</a>';
                $output .= '<li><a href="'.WebGUI::URL::page('op=editPrivilegeSettings').'">'.WebGUI::International::get(710).'</a>';
                $output .= '<li><a href="'.WebGUI::URL::page('op=editProfileSettings').'">'.WebGUI::International::get(308).'</a>';
                $output .= '<li><a href="'.WebGUI::URL::page('op=editUserSettings').'">'.WebGUI::International::get(117).'</a>';
                $output .= '</ul>';
        } else {
                $output = WebGUI::Privilege::adminOnly();
        }
        return $output;
}



1;

