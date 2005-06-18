#!/usr/bin/perl

use lib "../../lib";
use Getopt::Long;
use strict;
use WebGUI::Session;
use WebGUI::Asset;

my $configFile;
my $quiet;

GetOptions(
    'configFile=s'=>\$configFile,
	'quiet'=>\$quiet
);

WebGUI::Session::open("../..",$configFile);
print "\tInserting new Help template\n" unless ($quiet);
my $helpTemplate = <<EOT;
<p><tmpl_var body></p>

<tmpl_if fields>
<dl>
<tmpl_loop fields>
   <dt><tmpl_var title></dt>
      <dd><tmpl_var description></dd>
</tmpl_loop>
</dl>
</tmpl_if>
EOT

my $folder = WebGUI::Asset->newByUrl('templates/AdminConsole');
$folder->addChild({
	namespace=>'AdminConsole',
	title=>'Help',
	menuTitle=>'Help',
	url=>'Help',
	showInForms=>1,
	isEditable=>1,
	className=>"WebGUI::Asset::Template",
	template=>$helpTemplate},'PBtmplHelp000000000001');


WebGUI::Session::close();


