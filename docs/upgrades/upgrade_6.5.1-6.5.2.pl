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

#--------------------------------------------
print "\tAdding data form template\n" unless ($quiet);
my $template = <<STOP;
<a name="<tmpl_var assetId>"></a>
<tmpl_if session.var.adminOn>
<p><tmpl_var controls></p>
</tmpl_if>
<tmpl_if displayTitle>
    <h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if error_loop>
<ul>
<tmpl_loop error_loop>
<li><b><tmpl_var error.message></b>
</tmpl_loop>
</ul>
</tmpl_if>

<tmpl_if description>
<tmpl_var description><p />
</tmpl_if>

<tmpl_if canEdit>
<a href="<tmpl_var entryList.url>"><tmpl_var entryList.label></a>
&middot; <a href="<tmpl_var export.tab.url>"><tmpl_var export.tab.label></a>
<tmpl_if entryId>
&middot; <a href="<tmpl_var delete.url>"><tmpl_var delete.label></a>
</tmpl_if>
<tmpl_if session.var.adminOn>
&middot; <a href="<tmpl_var addField.url>"><tmpl_var addField.label></a>
&middot; <a href="<tmpl_var addTab.url>"><tmpl_var addTab.label></a>
</tmpl_if>
<p />
</tmpl_if>
<tmpl_var form.start>
<table>
        <tmpl_loop field_loop>
                <tmpl_unless field.isHidden>
                        <tr>
                                <td class="formDescription" valign="top">
                                        <tmpl_if session.var.adminOn>
                                                <tmpl_if canEdit>
                                                        <tmpl_var field.controls>
                                                </tmpl_if>
                                        </tmpl_if>
                                        <tmpl_var field.label>
                                </td>
                                <td class="tableData" valign="top">
                                        <tmpl_if field.isDisplayed>
                                                <tmpl_var field.value>
                                        <tmpl_else>
                                                <tmpl_var field.form>
                                        </tmpl_if>
                                        <tmpl_if field.isRequired>*</tmpl_if>
                                        <span class="formSubtext">
                                                <br />
                                                <tmpl_var field.subtext>
                                        </span>
                                </td>
                        </tr>
                </tmpl_unless>
        </tmpl_loop>
</table>
<br>
<tmpl_var form.save>
<tmpl_var form.end>
STOP
my $importNode = WebGUI::Asset->getImportNode;
$importNode->addChild({
	className=>"WebGUI::Asset::Template",
	template=>$template,
	namespace=>"DataForm",
	title=>'Default DataForm',
        menuTitle=>'Default DataForm',
        ownerUserId=>'3',
        groupIdView=>'7',
        groupIdEdit=>'4',
        isHidden=>1
	}, 'PBtmpl0000000000000141'
);



WebGUI::Session::close();


