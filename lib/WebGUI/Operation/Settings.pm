package WebGUI::Operation::Settings;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001 Plain Black Software.
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
use WebGUI::SQL;
use WebGUI::Utility;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_editProfileSettings &www_editProfileSettingsSave &www_editAuthenticationSettings &www_editAuthenticationSettingsSave &www_editCompanyInformation &www_editCompanyInformationSave &www_editFileSettings &www_editFileSettingsSave &www_editMailSettings &www_editMailSettingsSave &www_editMiscSettings &www_editMiscSettingsSave &www_manageSettings);

#-------------------------------------------------------------------
sub www_editAuthenticationSettings {
        my ($output, %authMethod, @array, %yesNo);
        %authMethod = ('WebGUI'=>'WebGUI', 'LDAP'=>'LDAP');
        %yesNo = ('yes'=>WebGUI::International::get(138), 'no'=>WebGUI::International::get(139));
        if (WebGUI::Privilege::isInGroup(3)) {
                $output .= '<a href="'.$session{page}{url}.'?op=viewHelp&hid=2&namespace=WebGUI"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
                $output .= '<h1>'.WebGUI::International::get(117).'</h1>';
                $output .= ' <form method="post" action="'.$session{page}{url}.'"> ';
                $output .= WebGUI::Form::hidden("op","editAuthenticationSettingsSave");
                $output .= '<table>';
                $array[0] = $session{setting}{anonymousRegistration};
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(118).'</td><td>'.WebGUI::Form::selectList("anonymousRegistration",\%yesNo, \@array).'</td></tr>';
                $array[0] = $session{setting}{authMethod};
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(119).'</td><td>'.WebGUI::Form::selectList("authMethod",\%authMethod, \@array).'</td></tr>';
                $array[0] = $session{setting}{usernameBinding};
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(306).'</td><td>'.WebGUI::Form::selectList("usernameBinding",\%yesNo, \@array).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(120).'</td><td>'.WebGUI::Form::text("ldapURL",30,2048,$session{setting}{ldapURL}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(121).'</td><td>'.WebGUI::Form::text("ldapId",30,100,$session{setting}{ldapId}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(122).'</td><td>'.WebGUI::Form::text("ldapIdName",30,100,$session{setting}{ldapIdName}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(123).'</td><td>'.WebGUI::Form::text("ldapPasswordName",30,100,$session{setting}{ldapPasswordName}).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(62)).'</td></tr>';
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
                WebGUI::SQL->write("update settings set value=".quote($session{form}{authMethod})." where name='authMethod'",$session{dbh});
                WebGUI::SQL->write("update settings set value=".quote($session{form}{ldapURL})." where name='ldapURL'",$session{dbh});
                WebGUI::SQL->write("update settings set value=".quote($session{form}{ldapId})." where name='ldapId'",$session{dbh});
                WebGUI::SQL->write("update settings set value=".quote($session{form}{ldapIdName})." where name='ldapIdName'",$session{dbh});
                WebGUI::SQL->write("update settings set value=".quote($session{form}{ldapPasswordName})." where name='ldapPasswordName'",$session{dbh});
                WebGUI::SQL->write("update settings set value=".quote($session{form}{anonymousRegistration})." where name='anonymousRegistration'",$session{dbh});
                WebGUI::SQL->write("update settings set value=".quote($session{form}{usernameBinding})." where name='usernameBinding'",$session{dbh});
                return www_manageSettings();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_editCompanyInformation {
        my ($output);
        if (WebGUI::Privilege::isInGroup(3)) {
                $output .= '<a href="'.$session{page}{url}.'?op=viewHelp&hid=6&namespace=WebGUI"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
		$output .= '<h1>'.WebGUI::International::get(124).'</h1>';
		$output .= ' <form method="post" action="'.$session{page}{url}.'"> ';
                $output .= WebGUI::Form::hidden("op","editCompanyInformationSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(125).'</td><td>'.WebGUI::Form::text("companyName",30,255,$session{setting}{companyName}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(126).'</td><td>'.WebGUI::Form::text("companyEmail",30,255,$session{setting}{companyEmail}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(127).'</td><td>'.WebGUI::Form::text("companyURL",30,2048,$session{setting}{companyURL}).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(62)).'</td></tr>';
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
                WebGUI::SQL->write("update settings set value=".quote($session{form}{companyName})." where name='companyName'",$session{dbh});
                WebGUI::SQL->write("update settings set value=".quote($session{form}{companyEmail})." where name='companyEmail'",$session{dbh});
                WebGUI::SQL->write("update settings set value=".quote($session{form}{companyURL})." where name='companyURL'",$session{dbh});
                return www_manageSettings(); 
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_editFileSettings {
        my ($output);
        if (WebGUI::Privilege::isInGroup(3)) {
                $output .= '<a href="'.$session{page}{url}.'?op=viewHelp&hid=11&namespace=WebGUI"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
		$output .= '<h1>'.WebGUI::International::get(128).'</h1>';
		$output .= ' <form method="post" action="'.$session{page}{url}.'"> ';
                $output .= WebGUI::Form::hidden("op","editFileSettingsSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(129).'</td><td>'.WebGUI::Form::text("lib",30,255,$session{setting}{lib}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(130).'</td><td>'.WebGUI::Form::text("maxAttachmentSize",30,11,$session{setting}{maxAttachmentSize}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(131).'</td><td>'.WebGUI::Form::text("attachmentDirectoryWeb",30,255,$session{setting}{attachmentDirectoryWeb}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(132).'</td><td>'.WebGUI::Form::text("attachmentDirectoryLocal",30,255,$session{setting}{attachmentDirectoryLocal}).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(62)).'</td></tr>';
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
                WebGUI::SQL->write("update settings set value=".quote($session{form}{lib})." where name='lib'",$session{dbh});
                WebGUI::SQL->write("update settings set value=".quote($session{form}{maxAttachmentSize})." where name='maxAttachmentSize'",$session{dbh});
                WebGUI::SQL->write("update settings set value=".quote($session{form}{attachmentDirectoryWeb})." where name='attachmentDirectoryWeb'",$session{dbh});
                WebGUI::SQL->write("update settings set value=".quote($session{form}{attachmentDirectoryLocal})." where name='attachmentDirectoryLocal'",$session{dbh});
                return www_manageSettings();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_editMailSettings {
        my ($output);
        if (WebGUI::Privilege::isInGroup(3)) {
                $output .= '<a href="'.$session{page}{url}.'?op=viewHelp&hid=13&namespace=WebGUI"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
                $output .= '<h1>'.WebGUI::International::get(133).'</h1>';
                $output .= ' <form method="post" action="'.$session{page}{url}.'"> ';
                $output .= WebGUI::Form::hidden("op","editMailSettingsSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(134).'</td><td>'.WebGUI::Form::textArea("recoverPasswordEmail",$session{setting}{recoverPasswordEmail}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(135).'</td><td>'.WebGUI::Form::text("smtpServer",30,255,$session{setting}{smtpServer}).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(62)).'</td></tr>';
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
                WebGUI::SQL->write("update settings set value=".quote($session{form}{recoverPasswordEmail})." where name='recoverPasswordEmail'",$session{dbh});
                WebGUI::SQL->write("update settings set value=".quote($session{form}{smtpServer})." where name='smtpServer'",$session{dbh});
                return www_manageSettings();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_editMiscSettings {
        my ($output, @array, %notFoundPage);
        %notFoundPage = (1=>WebGUI::International::get(136), 4=>WebGUI::International::get(137));
        if (WebGUI::Privilege::isInGroup(3)) {
                $output .= '<a href="'.$session{page}{url}.'?op=viewHelp&hid=24&namespace=WebGUI"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
                $output .= '<h1>'.WebGUI::International::get(140).'</h1>';
                $output .= ' <form method="post" action="'.$session{page}{url}.'"> ';
                $output .= WebGUI::Form::hidden("op","editMiscSettingsSave");
                $output .= '<table>';
                $array[0] = $session{setting}{notFoundPage};
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(141).'</td><td>'.WebGUI::Form::selectList("notFoundPage",\%notFoundPage,\@array).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(142).'</td><td>'.WebGUI::Form::text("sessionTimeout",30,11,$session{setting}{sessionTimeout}).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(62)).'</td></tr>';
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
                WebGUI::SQL->write("update settings set value=".quote($session{form}{sessionTimeout})." where name='sessionTimeout'",$session{dbh});
                WebGUI::SQL->write("update settings set value=".quote($session{form}{notFoundPage})." where name='notFoundPage'",$session{dbh});
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
                $output .= '<a href="'.$session{page}{url}.'?op=viewHelp&hid=22&namespace=WebGUI"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
                $output .= '<h1>'.WebGUI::International::get(308).'</h1>';
                $output .= ' <form method="post" action="'.$session{page}{url}.'"> ';
                $output .= WebGUI::Form::hidden("op","editProfileSettingsSave");
                $output .= '<table>';
		$array[0] = $session{setting}{profileName};
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(309).'</td><td>'.WebGUI::Form::selectList("profileName",\%yesNo,\@array).'</td></tr>';
		$array[0] = $session{setting}{profileExtraContact};
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(310).'</td><td>'.WebGUI::Form::selectList("profileExtraContact",\%yesNo,\@array).'</td></tr>';
		$array[0] = $session{setting}{profileHome};
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(311).'</td><td>'.WebGUI::Form::selectList("profileHome",\%yesNo,\@array).'</td></tr>';
		$array[0] = $session{setting}{profileWork};
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(312).'</td><td>'.WebGUI::Form::selectList("profileWork",\%yesNo,\@array).'</td></tr>';
		$array[0] = $session{setting}{profileMisc};
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(313).'</td><td>'.WebGUI::Form::selectList("profileMisc",\%yesNo,\@array).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(62)).'</td></tr>';
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
                WebGUI::SQL->write("update settings set value=".quote($session{form}{profileName})." where name='profileName'",$session{dbh});
                WebGUI::SQL->write("update settings set value=".quote($session{form}{profileExtraContact})." where name='profileExtraContact'",$session{dbh});
                WebGUI::SQL->write("update settings set value=".quote($session{form}{profileHome})." where name='profileHome'",$session{dbh});
                WebGUI::SQL->write("update settings set value=".quote($session{form}{profileWork})." where name='profileWork'",$session{dbh});
                WebGUI::SQL->write("update settings set value=".quote($session{form}{profileMisc})." where name='profileMisc'",$session{dbh});
                return www_manageSettings();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_manageSettings {
        my ($output);
        if (WebGUI::Privilege::isInGroup(3)) {
                $output .= '<a href="'.$session{page}{url}.'?op=viewHelp&hid=12&namespace=WebGUI"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
                $output .= '<h1>'.WebGUI::International::get(143).'</h1>';
                $output .= '<ul>';
                $output .= '<li><a href="'.$session{page}{url}.'?op=editAuthenticationSettings">'.WebGUI::International::get(117).'</a>';
                $output .= '<li><a href="'.$session{page}{url}.'?op=editCompanyInformation">'.WebGUI::International::get(124).'</a>';
                $output .= '<li><a href="'.$session{page}{url}.'?op=editFileSettings">'.WebGUI::International::get(128).'</a>';
                $output .= '<li><a href="'.$session{page}{url}.'?op=editMailSettings">'.WebGUI::International::get(133).'</a>';
                $output .= '<li><a href="'.$session{page}{url}.'?op=editMiscSettings">'.WebGUI::International::get(140).'</a>';
                $output .= '<li><a href="'.$session{page}{url}.'?op=editProfileSettings">'.WebGUI::International::get(308).'</a>';
                $output .= '</ul>';
        } else {
                $output = WebGUI::Privilege::adminOnly();
        }
        return $output;
}



1;

