#!/usr/bin/perl

use lib "../../lib";
use Getopt::Long;
use Parse::PlainConfig;
use strict;
use WebGUI::Session;
use WebGUI::SQL;


my $configFile;
my $quiet;

GetOptions(
        'configFile=s'=>\$configFile,
	'quiet'=>\$quiet
);

WebGUI::Session::open("../..",$configFile);

#--------------------------------------------
print "\tRemoving unneeded files and directories.\n" unless ($quiet);
unlink("../../lib/WebGUI/Operation/International.pm");
unlink("../../lib/WebGUI/Wobject/Item.pm");
unlink("../../lib/WebGUI/Wobject/LinkList.pm");
unlink("../../lib/WebGUI/Wobject/FAQ.pm");
unlink("../../lib/WebGUI/Wobject/ExtraColumn.pm");
unlink("../../lib/WebGUI/Macro/m_currentMenuHorizontal.pm");
unlink("../../lib/WebGUI/Macro/M_currentMenuVertical.pm");
unlink("../../lib/WebGUI/Macro/s_specificMenuHorizontal.pm");
unlink("../../lib/WebGUI/Macro/S_specificMenuVertical.pm");
unlink("../../lib/WebGUI/Macro/t_topMenuHorizontal.pm");
unlink("../../lib/WebGUI/Macro/T_topMenuVertical.pm");
unlink("../../lib/WebGUI/Macro/p_previousMenuHorizontal.pm");
unlink("../../lib/WebGUI/Macro/P_previousMenuVertical.pm");
unlink("../../lib/WebGUI/Macro/C_crumbTrail.pm");
unlink("../../lib/WebGUI/Macro/FlexMenu.pm");
unlink("../../lib/WebGUI/Macro/PreviousDropMenu.pm");
unlink("../../lib/WebGUI/Macro/Synopsis.pm");
unlink("../../lib/WebGUI/Macro/rootmenuHorizontal.pm");
unlink("../../lib/WebGUI/Macro/RootTab.pm");
unlink("../../lib/WebGUI/Macro/SpecificDropMenu.pm");
unlink("../../lib/WebGUI/Macro/TopDropMenu.pm");
unlink("../../lib/WebGUI/Macro/Question_search.pm");


print "\tResetting user languages.\n" unless ($quiet);
my ($defaultLangId) = WebGUI::SQL->quickArray("select dataDefault from userProfileField where fieldName='language'");
$defaultLangId =~ s/\[//;
$defaultLangId =~ s/\]//;
my $langs = {
	1 => "English",
	2 => "German",
	3 => "Dutch",
	4 => "Spanish",
	5 => "Portuguese",
	6 => "Swedish",
	7 => "Chinese-Simplified",
	8 => "Italian",
	9 => "Chinese-Traditional",
	10 => "Danish",
	11 => "Arabic",
	12 => "Norwegian",
	13 => "Finnish",
	14 => "Japanese",
	15 => "Croatian",
	16 => "Polish",
	21 => "Russian"
	};
WebGUI::SQL->write("update userProfileField set dataDefault=".quote("['".$langs->{$defaultLangId}."']")." where fieldName='language'");
WebGUI::SQL->write("update userProfileData set fieldData='".$langs->{$defaultLangId}."' where fieldName='language' and fieldData<>1");
WebGUI::SQL->write("update userProfileData set fieldData='English' where fieldName='language' and fieldData=1");
WebGUI::SQL->write("alter table page change languageId languageId varchar(50) not null default 'English'");
foreach my $key (keys %{$langs}) {
	WebGUI::SQL->write("update page set languageId=".quote($langs->{$key})." where languageId=".$key);
}

WebGUI::Session::close();


