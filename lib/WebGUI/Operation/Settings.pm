package WebGUI::Operation::Settings;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use Exporter;
use strict;
use WebGUI::Form;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::Shortcut;
use WebGUI::SQL;
use WebGUI::URL;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_editProfileSettings &www_editProfileSettingsSave &www_editAuthenticationSettings &www_editAuthenticationSettingsSave &www_editCompanyInformation &www_editCompanyInformationSave &www_editFileSettings &www_editFileSettingsSave &www_editMailSettings &www_editMailSettingsSave &www_editMiscSettings &www_editMiscSettingsSave &www_manageSettings);

#-------------------------------------------------------------------
sub www_editAuthenticationSettings {
        my ($output, %authMethod, @array, %yesNo);
        %authMethod = ('WebGUI'=>'WebGUI', 'LDAP'=>'LDAP');
        %yesNo = ('yes'=>WebGUI::International::get(138), 'no'=>WebGUI::International::get(139));
        if (WebGUI::Privilege::isInGroup(3)) {
                $output .= helpLink(2);
                $output .= '<h1>'.WebGUI::International::get(117).'</h1>';
                $output .= formHeader();
                $output .= WebGUI::Form::hidden("op","editAuthenticationSettingsSave");
                $output .= '<table>';
                $array[0] = $session{setting}{anonymousRegistration};
                $output .= tableFormRow(WebGUI::International::get(118),WebGUI::Form::selectList("anonymousRegistration",\%yesNo, \@array));
                $array[0] = $session{setting}{authMethod};
                $output .= tableFormRow(WebGUI::International::get(119),WebGUI::Form::selectList("authMethod",\%authMethod, \@array));
                $array[0] = $session{setting}{usernameBinding};
                $output .= tableFormRow(WebGUI::International::get(306),WebGUI::Form::selectList("usernameBinding",\%yesNo, \@array));
                $output .= tableFormRow(WebGUI::International::get(120),WebGUI::Form::text("ldapURL",30,2048,$session{setting}{ldapURL}));
                $output .= tableFormRow(WebGUI::International::get(121),WebGUI::Form::text("ldapId",30,100,$session{setting}{ldapId}));
                $output .= tableFormRow(WebGUI::International::get(122),WebGUI::Form::text("ldapIdName",30,100,$session{setting}{ldapIdName}));
                $output .= tableFormRow(WebGUI::International::get(123),WebGUI::Form::text("ldapPasswordName",30,100,$session{setting}{ldapPasswordName}));
                $output .= formSave();
                $output .= '</table>';
                $output .= '</form> ';
        } else {
                $output = WebGUI::Privilege::adminOnly();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_editAuthenticationSettingsSave {
        if (WebGUI::Privilege::isInGroup(3)) {
                WebGUI::SQL->write("update settings set value=".quote($session{form}{authMethod})." where name='authMethod'");
                WebGUI::SQL->write("update settings set value=".quote($session{form}{ldapURL})." where name='ldapURL'");
                WebGUI::SQL->write("update settings set value=".quote($session{form}{ldapId})." where name='ldapId'");
                WebGUI::SQL->write("update settings set value=".quote($session{form}{ldapIdName})." where name='ldapIdName'");
                WebGUI::SQL->write("update settings set value=".quote($session{form}{ldapPasswordName})." where name='ldapPasswordName'");
                WebGUI::SQL->write("update settings set value=".quote($session{form}{anonymousRegistration})." where name='anonymousRegistration'");
                WebGUI::SQL->write("update settings set value=".quote($session{form}{usernameBinding})." where name='usernameBinding'");
                return www_manageSettings();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_editCompanyInformation {
        my ($output);
        if (WebGUI::Privilege::isInGroup(3)) {
                $output .= helpLink(6);
		$output .= '<h1>'.WebGUI::International::get(124).'</h1>';
		$output .= formHeader();
                $output .= WebGUI::Form::hidden("op","editCompanyInformationSave");
                $output .= '<table>';
                $output .= tableFormRow(WebGUI::International::get(125),WebGUI::Form::text("companyName",30,255,$session{setting}{companyName}));
                $output .= tableFormRow(WebGUI::International::get(126),WebGUI::Form::text("companyEmail",30,255,$session{setting}{companyEmail}));
                $output .= tableFormRow(WebGUI::International::get(127),WebGUI::Form::text("companyURL",30,2048,$session{setting}{companyURL}));
                $output .= formSave();
                $output .= '</table>';
                $output .= '</form> ';
        } else {
                $output = WebGUI::Privilege::adminOnly();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_editCompanyInformationSave {
        if (WebGUI::Privilege::isInGroup(3)) {
                WebGUI::SQL->write("update settings set value=".quote($session{form}{companyName})." where name='companyName'");
                WebGUI::SQL->write("update settings set value=".quote($session{form}{companyEmail})." where name='companyEmail'");
                WebGUI::SQL->write("update settings set value=".quote($session{form}{companyURL})." where name='companyURL'");
                return www_manageSettings(); 
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_editFileSettings {
        my ($output);
        if (WebGUI::Privilege::isInGroup(3)) {
                $output .= helpLink(11);
		$output .= '<h1>'.WebGUI::International::get(128).'</h1>';
		$output .= formHeader();
                $output .= WebGUI::Form::hidden("op","editFileSettingsSave");
                $output .= '<table>';
                $output .= tableFormRow(WebGUI::International::get(129),WebGUI::Form::text("lib",30,255,$session{setting}{lib}));
                $output .= tableFormRow(WebGUI::International::get(130),WebGUI::Form::text("maxAttachmentSize",30,11,$session{setting}{maxAttachmentSize}));
                $output .= tableFormRow(WebGUI::International::get(131),WebGUI::Form::text("attachmentDirectoryWeb",30,255,$session{setting}{attachmentDirectoryWeb}));
                $output .= tableFormRow(WebGUI::International::get(132),WebGUI::Form::text("attachmentDirectoryLocal",30,255,$session{setting}{attachmentDirectoryLocal}));
                $output .= formSave();
                $output .= '</table>';
                $output .= '</form> ';
        } else {
                $output = WebGUI::Privilege::adminOnly();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_editFileSettingsSave {
        if (WebGUI::Privilege::isInGroup(3)) {
                WebGUI::SQL->write("update settings set value=".quote($session{form}{lib})." where name='lib'");
                WebGUI::SQL->write("update settings set value=".quote($session{form}{maxAttachmentSize})." where name='maxAttachmentSize'");
                WebGUI::SQL->write("update settings set value=".quote($session{form}{attachmentDirectoryWeb})." where name='attachmentDirectoryWeb'");
                WebGUI::SQL->write("update settings set value=".quote($session{form}{attachmentDirectoryLocal})." where name='attachmentDirectoryLocal'");
                return www_manageSettings();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_editMailSettings {
        my ($output);
        if (WebGUI::Privilege::isInGroup(3)) {
                $output .= helpLink(13);
                $output .= '<h1>'.WebGUI::International::get(133).'</h1>';
                $output .= formHeader();
                $output .= WebGUI::Form::hidden("op","editMailSettingsSave");
                $output .= '<table>';
                $output .= tableFormRow(WebGUI::International::get(134),WebGUI::Form::textArea("recoverPasswordEmail",$session{setting}{recoverPasswordEmail}));
                $output .= tableFormRow(WebGUI::International::get(135),WebGUI::Form::text("smtpServer",30,255,$session{setting}{smtpServer}));
                $output .= formSave();
                $output .= '</table>';
                $output .= '</form> ';
        } else {
                $output = WebGUI::Privilege::adminOnly();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_editMailSettingsSave {
        if (WebGUI::Privilege::isInGroup(3)) {
                WebGUI::SQL->write("update settings set value=".quote($session{form}{recoverPasswordEmail})." where name='recoverPasswordEmail'");
                WebGUI::SQL->write("update settings set value=".quote($session{form}{smtpServer})." where name='smtpServer'");
                return www_manageSettings();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_editMiscSettings {
        my ($output, @array, %notFoundPage, %yesNo);
        %notFoundPage = (1=>WebGUI::International::get(136), 4=>WebGUI::International::get(137));
	%yesNo = ('1'=>WebGUI::International::get(138), '0'=>WebGUI::International::get(139));
        if (WebGUI::Privilege::isInGroup(3)) {
                $output .= helpLink(24);
                $output .= '<h1>'.WebGUI::International::get(140).'</h1>';
                $output .= formHeader();
                $output .= WebGUI::Form::hidden("op","editMiscSettingsSave");
                $output .= '<table>';
                $array[0] = $session{setting}{notFoundPage};
                $output .= tableFormRow(WebGUI::International::get(141),
			WebGUI::Form::selectList("notFoundPage",\%notFoundPage,\@array));
                $output .= tableFormRow(WebGUI::International::get(142),
			WebGUI::Form::text("sessionTimeout",30,11,$session{setting}{sessionTimeout}));
		$output .= tableFormRow(WebGUI::International::get(398),
			WebGUI::Form::text("docTypeDec", 70, 255, $session{setting}{docTypeDec}));
                $array[0] = $session{setting}{preventProxyCache};
                $output .= tableFormRow(WebGUI::International::get(400),
			WebGUI::Form::selectList("preventProxyCache",\%yesNo,\@array));
                $output .= formSave();
                $output .= '</table>';
                $output .= '</form> ';
        } else {
                $output = WebGUI::Privilege::adminOnly();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_editMiscSettingsSave {
        if (WebGUI::Privilege::isInGroup(3)) {
                WebGUI::SQL->write("update settings set value=".quote($session{form}{sessionTimeout}).
			" where name='sessionTimeout'");
                WebGUI::SQL->write("update settings set value=".quote($session{form}{notFoundPage}).
			" where name='notFoundPage'");
		WebGUI::SQL->write("update settings set value=".quote($session{form}{docTypeDec}).
			" where name='docTypeDec'");
		WebGUI::SQL->write("update settings set value=".quote($session{form}{preventProxyCache}).
			" where name='preventProxyCache'");
                return www_manageSettings(); 
        } else {
                return WebGUI::Privilege::adminOnly();
	}
}

#-------------------------------------------------------------------
sub www_editProfileSettings {
        my ($output, @array, %yesNo);
        %yesNo = ('1'=>WebGUI::International::get(138), '0'=>WebGUI::International::get(139));
        if (WebGUI::Privilege::isInGroup(3)) {
                $output .= helpLink(22);
                $output .= '<h1>'.WebGUI::International::get(308).'</h1>';
                $output .= formHeader();
                $output .= WebGUI::Form::hidden("op","editProfileSettingsSave");
                $output .= '<table>';
		$array[0] = $session{setting}{profileName};
                $output .= tableFormRow(WebGUI::International::get(309),WebGUI::Form::selectList("profileName",\%yesNo,\@array));
		$array[0] = $session{setting}{profileExtraContact};
                $output .= tableFormRow(WebGUI::International::get(310),WebGUI::Form::selectList("profileExtraContact",\%yesNo,\@array));
		$array[0] = $session{setting}{profileHome};
                $output .= tableFormRow(WebGUI::International::get(311),WebGUI::Form::selectList("profileHome",\%yesNo,\@array));
		$array[0] = $session{setting}{profileWork};
                $output .= tableFormRow(WebGUI::International::get(312),WebGUI::Form::selectList("profileWork",\%yesNo,\@array));
		$array[0] = $session{setting}{profileMisc};
                $output .= tableFormRow(WebGUI::International::get(313),WebGUI::Form::selectList("profileMisc",\%yesNo,\@array));
                $output .= formSave();
                $output .= '</table>';
                $output .= '</form> ';
        } else {
                $output = WebGUI::Privilege::adminOnly();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_editProfileSettingsSave {
        if (WebGUI::Privilege::isInGroup(3)) {
                WebGUI::SQL->write("update settings set value=".quote($session{form}{profileName})." where name='profileName'");
                WebGUI::SQL->write("update settings set value=".quote($session{form}{profileExtraContact})." where name='profileExtraContact'");
                WebGUI::SQL->write("update settings set value=".quote($session{form}{profileHome})." where name='profileHome'");
                WebGUI::SQL->write("update settings set value=".quote($session{form}{profileWork})." where name='profileWork'");
                WebGUI::SQL->write("update settings set value=".quote($session{form}{profileMisc})." where name='profileMisc'");
                return www_manageSettings();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_manageSettings {
        my ($output);
        if (WebGUI::Privilege::isInGroup(3)) {
                $output .= helpLink(12);
                $output .= '<h1>'.WebGUI::International::get(143).'</h1>';
                $output .= '<ul>';
                $output .= '<li><a href="'.WebGUI::URL::page('op=editAuthenticationSettings').
			'">'.WebGUI::International::get(117).'</a>';
                $output .= '<li><a href="'.WebGUI::URL::page('op=editCompanyInformation').
			'">'.WebGUI::International::get(124).'</a>';
                $output .= '<li><a href="'.WebGUI::URL::page('op=editFileSettings').
			'">'.WebGUI::International::get(128).'</a>';
                $output .= '<li><a href="'.WebGUI::URL::page('op=editMailSettings').
			'">'.WebGUI::International::get(133).'</a>';
                $output .= '<li><a href="'.WebGUI::URL::page('op=editMiscSettings').
			'">'.WebGUI::International::get(140).'</a>';
                $output .= '<li><a href="'.WebGUI::URL::page('op=editProfileSettings').
			'">'.WebGUI::International::get(308).'</a>';
                $output .= '</ul>';
        } else {
                $output = WebGUI::Privilege::adminOnly();
        }
        return $output;
}



1;

