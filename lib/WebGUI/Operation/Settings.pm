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
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_editSettings &www_editSettingsSave);

#-------------------------------------------------------------------
sub www_editSettings {
        my ($output);
        if (WebGUI::Privilege::isInGroup(3)) {
                $output .= '<a href="'.$session{page}{url}.'?op=viewHelp&hid=12"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a><h1>Edit Settings</h1> <form method="post" action="'.$session{page}{url}.'"> ';
                $output .= WebGUI::Form::hidden("op","editSettingsSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription" valign="top">Path to WebGUI Extras</td><td>'.WebGUI::Form::text("lib",20,255,$session{setting}{lib}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">Session Timeout</td><td>'.WebGUI::Form::text("sessionTimeout",20,11,$session{setting}{sessionTimeout}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">Maximum Attachment Size</td><td>'.WebGUI::Form::text("maxAttachmentSize",20,11,$session{setting}{maxAttachmentSize}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">Web Attachment Path</td><td>'.WebGUI::Form::text("attachmentDirectoryWeb",20,255,$session{setting}{attachmentDirectoryWeb}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">Server Attachment Path</td><td>'.WebGUI::Form::text("attachmentDirectoryLocal",20,255,$session{setting}{attachmentDirectoryLocal}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">SMTP Server</td><td>'.WebGUI::Form::text("smtpServer",20,255,$session{setting}{smtpServer}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">Company Name</td><td>'.WebGUI::Form::text("companyName",20,255,$session{setting}{companyName}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">Company Email Address</td><td>'.WebGUI::Form::text("companyEmail",20,255,$session{setting}{companyEmail}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">Company URL</td><td>'.WebGUI::Form::text("companyURL",20,255,$session{setting}{companyURL}).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit("save").'</td></tr>';
                $output .= '</table>';
                $output .= '</form> ';
		$output .= '<hr size=1>Build Version: '.$WebGUI::VERSION;
        } else {
                $output = WebGUI::Privilege::insufficient();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_editSettingsSave {
        if (WebGUI::Privilege::isInGroup(3)) {
                WebGUI::SQL->write("update settings set value=".quote($session{form}{lib})." where name='lib'",$session{dbh});
                WebGUI::SQL->write("update settings set value=".quote($session{form}{sessionTimeout})." where name='sessionTimeout'",$session{dbh});
                WebGUI::SQL->write("update settings set value=".quote($session{form}{maxAttachmentSize})." where name='maxAttachmentSize'",$session{dbh});
                WebGUI::SQL->write("update settings set value=".quote($session{form}{attachmentDirectoryWeb})." where name='attachmentDirectoryWeb'",$session{dbh});
                WebGUI::SQL->write("update settings set value=".quote($session{form}{attachmentDirectoryLocal})." where name='attachmentDirectoryLocal'",$session{dbh});
                WebGUI::SQL->write("update settings set value=".quote($session{form}{smtpServer})." where name='smtpServer'",$session{dbh});
                WebGUI::SQL->write("update settings set value=".quote($session{form}{companyName})." where name='companyName'",$session{dbh});
                WebGUI::SQL->write("update settings set value=".quote($session{form}{companyEmail})." where name='companyEmail'",$session{dbh});
                WebGUI::SQL->write("update settings set value=".quote($session{form}{companyURL})." where name='companyURL'",$session{dbh});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
	}
}

1;
