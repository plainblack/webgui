package WebGUI::Operation::Settings;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use Exporter;
use strict qw(Vars Subs);
use WebGUI::Authentication;
use WebGUI::DateTime;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Operation::Shared;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_saveSettings &www_editUserSettings &www_editCompanyInformation 
	&www_editPrivilegeSettings &www_editMessagingSettings &www_editMiscSettings 
	&www_editContentSettings &www_manageSettings);

#-------------------------------------------------------------------
sub _submenu {
        my (%menu);
        tie %menu, 'Tie::IxHash';
        $menu{WebGUI::URL::page('op=manageSettings')} = WebGUI::International::get(4);
        return menuWrapper($_[0],\%menu);
}

#-------------------------------------------------------------------
sub www_editUserSettings {
	WebGUI::Privilege::adminOnly() unless (WebGUI::Privilege::isInGroup(3));
        my ($output, $f, $cmd, $html);
        $output .= helpIcon(2);
        $output .= '<h1>'.WebGUI::International::get(117).'</h1>';
	$f = WebGUI::HTMLForm->new;
        $f->hidden("op","saveSettings");
        $f->yesNo("anonymousRegistration",WebGUI::International::get(118),$session{setting}{anonymousRegistration});
        $f->text("runOnRegistration",WebGUI::International::get(559),$session{setting}{runOnRegistration});
        $f->yesNo("useKarma",WebGUI::International::get(539),$session{setting}{useKarma});
        $f->integer("karmaPerLogin",WebGUI::International::get(540),$session{setting}{karmaPerLogin});
        $f->interval("sessionTimeout",WebGUI::International::get(142),WebGUI::DateTime::secondsToInterval($session{setting}{sessionTimeout}));
	$f->yesNo("selfDeactivation",WebGUI::International::get(885),$session{setting}{selfDeactivation});
	foreach (@{$session{config}{authMethods}}) {
                $options->{$_} = $_;
        }
        $f->select("authMethod",$options,WebGUI::International::get(119),[$session{setting}{authMethod}]);
	foreach (@{$session{config}{authMethods}}) {
		$f->raw(WebGUI::Authentication::settingsForm($_));
 	}
	$f->submit;
	$output .= $f->print;
        return _submenu($output);
}

#-------------------------------------------------------------------
sub www_editCompanyInformation {
	WebGUI::Privilege::adminOnly() unless (WebGUI::Privilege::isInGroup(3));
        my ($output, $f);
        $output .= helpIcon(6);
	$output .= '<h1>'.WebGUI::International::get(124).'</h1>';
	$f = WebGUI::HTMLForm->new;
        $f->hidden("op","saveSettings");
        $f->text("companyName",WebGUI::International::get(125),$session{setting}{companyName});
        $f->email("companyEmail",WebGUI::International::get(126),$session{setting}{companyEmail});
        $f->url("companyURL",WebGUI::International::get(127),$session{setting}{companyURL});
	$f->submit;
	$output .= $f->print;
        return _submenu($output);
}

#-------------------------------------------------------------------
sub www_editContentSettings {
	WebGUI::Privilege::adminOnly() unless (WebGUI::Privilege::isInGroup(3));
        my ($output, %htmlFilter, $f, $pages);
	$pages = WebGUI::SQL->buildHashRef("select pageId,menuTitle from page order by menuTitle");
        %htmlFilter = ('none'=>WebGUI::International::get(420), 'most'=>WebGUI::International::get(421), 
		'javascript'=>WebGUI::International::get(526), 'all'=>WebGUI::International::get(419));
        $output .= helpIcon(29);
        $output .= '<h1>'.WebGUI::International::get(525).'</h1>';
        $f = WebGUI::HTMLForm->new;
        $f->hidden("op","saveSettings");
        $f->select("defaultPage",$pages,WebGUI::International::get(527),[$session{setting}{defaultPage}]);
        $f->select("notFoundPage",$pages,WebGUI::International::get(141),[$session{setting}{notFoundPage}]);
        $f->text("docTypeDec",WebGUI::International::get(398),$session{setting}{docTypeDec});
        $f->integer("maxAttachmentSize",WebGUI::International::get(130),$session{setting}{maxAttachmentSize});
        $f->integer("maxImageSize",WebGUI::International::get(583),$session{setting}{maxImageSize});
        $f->integer("thumbnailSize",WebGUI::International::get(406),$session{setting}{thumbnailSize});
        $f->integer("snippetsPreviewLength",WebGUI::International::get(888),$session{setting}{snippetsPreviewLength});
        $f->integer("textAreaRows",WebGUI::International::get(463),$session{setting}{textAreaRows});
        $f->integer("textAreaCols",WebGUI::International::get(464),$session{setting}{textAreaCols});
        $f->integer("textBoxSize",WebGUI::International::get(465),$session{setting}{textBoxSize});
        $f->submit;
        $output .= $f->print;
        return _submenu($output);
}

#-------------------------------------------------------------------
sub www_editMessagingSettings {
	WebGUI::Privilege::adminOnly() unless (WebGUI::Privilege::isInGroup(3));
        my ($output, $f);
        $output .= helpIcon(13);
        $output .= '<h1>'.WebGUI::International::get(133).'</h1>';
	$f = WebGUI::HTMLForm->new;
        $f->hidden("op","saveSettings");
        $f->text("smtpServer",WebGUI::International::get(135),$session{setting}{smtpServer});
        $f->textarea("mailFooter",WebGUI::International::get(824),$session{setting}{mailFooter});
        $f->yesNo("alertOnNewUser",WebGUI::International::get(534),$session{setting}{alertOnNewUser});
        $f->group("onNewUserAlertGroup",WebGUI::International::get(535),[$session{setting}{onNewUserAlertGroup}]);
	$f->submit;
	$output .= $f->print;
        return _submenu($output);
}

#-------------------------------------------------------------------
sub www_editMiscSettings {
	WebGUI::Privilege::adminOnly() unless (WebGUI::Privilege::isInGroup(3));
        my ($output, $f);
        $output .= helpIcon(24);
        $output .= '<h1>'.WebGUI::International::get(140).'</h1>';
	$f = WebGUI::HTMLForm->new;
        $f->hidden("op","saveSettings");
	$f->yesNo("preventProxyCache",WebGUI::International::get(400),$session{setting}{preventProxyCache});
	$f->yesNo("showDebug",WebGUI::International::get(707),$session{setting}{showDebug});
	$f->yesNo("trackPageStatistics",WebGUI::International::get(749),$session{setting}{trackPageStatistics});
	$f->submit;
	$output .= $f->print;
        return _submenu($output);
}

#-------------------------------------------------------------------
sub www_manageSettings {
	WebGUI::Privilege::adminOnly() unless (WebGUI::Privilege::isInGroup(3));
        my ($output);
        $output .= helpIcon(12);
        $output .= '<h1>'.WebGUI::International::get(143).'</h1>';
        $output .= '<ul>';
        $output .= '<li><a href="'.WebGUI::URL::page('op=editCompanyInformation').'">'.WebGUI::International::get(124).'</a>';
        $output .= '<li><a href="'.WebGUI::URL::page('op=editContentSettings').'">'.WebGUI::International::get(525).'</a>';
        $output .= '<li><a href="'.WebGUI::URL::page('op=editMessagingSettings').'">'.WebGUI::International::get(133).'</a>';
        $output .= '<li><a href="'.WebGUI::URL::page('op=editMiscSettings').'">'.WebGUI::International::get(140).'</a>';
        $output .= '<li><a href="'.WebGUI::URL::page('op=editProfileSettings').'">'.WebGUI::International::get(308).'</a>';
        $output .= '<li><a href="'.WebGUI::URL::page('op=editUserSettings').'">'.WebGUI::International::get(117).'</a>';
        $output .= '</ul>';
        return _submenu($output);
}

#-------------------------------------------------------------------
sub www_saveSettings {
	WebGUI::Privilege::adminOnly() unless (WebGUI::Privilege::isInGroup(3));
	my ($key, $value);
	foreach $key (keys %{$session{form}}) {
		$value = $session{form}{$key};
		if ($key =~ m/(.*)_interval/) {
			$value = WebGUI::DateTime::intervalToSeconds($session{form}{$key},$session{form}{$1."_units"});
			$key = $1;
		} elsif ($key =~ m/_units/) {
			next;
		} 
		unless ($key eq "op") {
			WebGUI::SQL->write("update settings set value=".quote($value)." where name='$key'");
		}
	}
	return www_manageSettings();
}

1;

