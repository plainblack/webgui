my $toVersion = "6.7.2";

$|=1; #disable output buffering

use lib "../../lib";
use Getopt::Long;
use strict;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Asset;

my $configFile;
my $quiet;

GetOptions(
    'configFile=s'=>\$configFile,
	'quiet'=>\$quiet
);

WebGUI::Session::open("../..",$configFile);
WebGUI::Session::refreshUserInfo(3);

WebGUI::SQL->write("insert into webguiVersion values (".quote($toVersion).",'upgrade',".time().")");
WebGUI::SQL->write("update DataForm_field set type=".quote('TimeField')." where type=".quote('time'));
WebGUI::SQL->write("update userProfileField set dataType=".quote('TimeField')." where dataType=".quote('time'));
fixSpelling();
fixCSTemplate();

WebGUI::Session::close();

#-------------------------------------------------
sub fixCSTemplate {
        print "\tFixing CS Search template.\n" unless ($quiet);
	my $asset = WebGUI::Asset->newByDynamicClass("PBtmpl0000000000000031");
	my $template = $asset->get("template");
	$template =~ s/<tmpl_var date>/<tmpl_var dateSubmitted.human>/ixsg;
	$template =~ s/<tmpl_var time>/<tmpl_var timeSubmitted.human>/ixsg;
	$asset->update({template=>$template});
	$asset->commit;
}


#-------------------------------------------------
sub fixSpelling {
        print "\tFixing a few spelling problems.\n" unless ($quiet);
	my $asset = WebGUI::Asset->newByDynamicClass("PBtmplCP00000000000001");
	$asset->update({url=>"default_product_template"});
	$asset->commit;
	$asset = WebGUI::Asset->newByDynamicClass("PBtmpl0000000000000134");
	my $template = $asset->get("template");
	$template =~ s/spesify/specify/ixsg;
	$asset->update({template=>$template});
	$asset->commit;
}

