package WebGUI::Template;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::IxHash;
use WebGUI::ErrorHandler;
use WebGUI::HTMLForm;
use WebGUI::Session;
use WebGUI::SQL;

#-------------------------------------------------------------------
sub countPositions {
        my ($template, $i);
        ($template) = WebGUI::SQL->quickArray("select template from template where templateId=".$_[0]);
        $i = 0;
        while ($template =~ m/\^$i\;/) {
                $i++;
        }
        return $i;
}

#-------------------------------------------------------------------
sub generate {
        my ($output, $content, $template);
	$template = WebGUI::SQL->quickHashRef("select * from template where templateId=".$_[1]);
	$content = $template->{template};
	$content =~ s/\^(\d+)\;/${$_[0]}{$1}/g;
	return $content;
}

#-------------------------------------------------------------------
sub getList {
        my (%list);
	tie %list, 'Tie::IxHash';
	%list = WebGUI::SQL->buildHash("select templateId,name from template order by name");
        return %list;
}

#-------------------------------------------------------------------
sub getPositions {
	my (%hash, $template, $i);
	tie %hash, "Tie::IxHash";
	($template) = WebGUI::SQL->quickArray("select template from template where templateId=".$_[0]);
	$i = 0;
	while ($template =~ m/\^$i\;/) {
		$hash{$i} = $i;
		$i++;	
	}
	return \%hash;
}

#-------------------------------------------------------------------
sub selectTemplate {
	my ($output, $f, %templates, $key);
	tie %templates,'Tie::IxHash';
	$f = WebGUI::HTMLForm->new(1);
	%templates = WebGUI::SQL->buildHash("select templateId,name from template order by name");
	$f->select("templateId",\%templates,'',[$_[0]],'','','onChange="changeTemplatePreview(this.form.templateId.value)"');
	%templates = WebGUI::SQL->buildHash("select templateId,template from template");
	$output = '
	<script language="JavaScript">
	function checkBrowser(){
		this.ver=navigator.appVersion;
		this.dom=document.getElementById?1:0;
		this.ie5=(this.ver.indexOf("MSIE 5")>-1 && this.dom)?1:0;
		this.ie4=(document.all && !this.dom)?1:0;
		this.ns5=(this.dom && parseInt(this.ver) >= 5) ?1:0;
		this.ns4=(document.layers && !this.dom)?1:0;
		this.bw=(this.ie5 || this.ie4 || this.ns4 || this.ns5 || this.dom);
		return this;
	}
	bw=new checkBrowser();
	function makeChangeTextObj(obj){
   		this.css=bw.dom? document.getElementById(obj).style:bw.ie4?document.all[obj].style:bw.ns4?document.layers[obj]:0;
   		this.writeref=bw.dom? document.getElementById(obj):bw.ie4?document.all[obj]:bw.ns4?document.layers[obj].document:0;
   		this.writeIt=b_writeIt;
	}
	function b_writeIt(text){
		var obj;
   		if(bw.ns4) {
    		if (document.loading) document.loading.visibility = "hidden";
			this.writeref.write(text + "&nbsp;&nbsp;&nbsp;");
			this.writeref.close();
		} else {     
			if (bw.ie4) {
      			if (document.all.loading) obj = document.all.loading;     
		}
      		if (obj) obj.style.visibility = "hidden";
			this.writeref.innerHTML=text;
   		}
	}
	function init(){
		if(bw.bw){
			oMessage=new makeChangeTextObj("templatePreview");
			oMessage.css.visibility="visible";
			changeTemplatePreview('.$_[0].');
		}
	}
	onload=init
	function changeTemplatePreview(value) {
		oMessage.writeIt(eval("b"+value));
	}
	';
	foreach $key (keys %templates) {
		$templates{$key} =~ s/\n//g;
		$templates{$key} =~ s/\r//g;
		$templates{$key} =~ s/\'/\\\'/g;
		$templates{$key} =~ s/\<table.*?\>/\<table cellspacing=0 cellpadding=3 width=100 height=80 border=1\>/ig;
		$templates{$key} =~ s/\^(\d+)\;/$1/g;
		$output .= "	var b".$key." = '".$templates{$key}."';\n";
	}
	$output .= '</script>';
	$output .= $f->printRowsOnly;
	$output .= '<div id="templatePreview" style="padding: 5px;"></div>';
	return $output;
}

1;

