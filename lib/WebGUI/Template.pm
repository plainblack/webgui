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

use HTML::Template;
use strict;
use Tie::IxHash;
use WebGUI::ErrorHandler;
use WebGUI::HTMLForm;
use WebGUI::Session;
use WebGUI::SQL;


#-------------------------------------------------------------------
sub _newPositionFormat {
	return "<tmpl_var template.position".($_[0]+1).">";
}

#-------------------------------------------------------------------
sub countPositions {
        my ($template, $i);
        $template = get($_[0]);
        $i = 1;
        while ($template =~ m/template\.position$i/) {
                $i++;
        }
        return $i-1;
}

#-------------------------------------------------------------------
sub draw {
	my $template = get($_[0]);
	$template =~ s/\n//g;
	$template =~ s/\r//g;
	$template =~ s/\'/\\\'/g;
	$template =~ s/\<table.*?\>/\<table cellspacing=0 cellpadding=3 width=100 height=80 border=1\>/ig;
	$template =~ s/\<tmpl_var\s+template\.position(\d+)\>/$1/ig;
	return $template;
}

#-------------------------------------------------------------------
sub get {
	my $templateId = $_[0] || 1;
	my $namespace = $_[1] || "Page";
        my ($template) = WebGUI::SQL->quickArray("select template from template 
		where templateId=".$templateId." and namespace=".quote($namespace));
	$template =~ s/\^(\d+)\;/_newPositionFormat($1)/eg; #compatibility with old-style templates
        return $template;
}

#-------------------------------------------------------------------
sub getList {
        my (%list);
	tie %list, 'Tie::IxHash';
	%list = WebGUI::SQL->buildHash("select templateId,name from template where namespace='Page' order by name");
        return \%list;
}

#-------------------------------------------------------------------
sub getPositions {
	my (%hash, $template, $i);
	tie %hash, "Tie::IxHash";
	for ($i=1; $i<=countPositions($_[0]); $i++) {
		$hash{$i} = $i;
	}
	return \%hash;
}

#-------------------------------------------------------------------
sub process {
	my ($t, $html);
	$html = $_[0];
	$t = HTML::Template->new(
   		scalarref=>\$html,
		global_vars=>1,
   		loop_context_vars=>1,
		die_on_bad_params=>0,
		strict=>0
		);
        while (my ($section, $hash) = each %session) {
        	while (my ($key, $value) = each %$hash) {
                	if (ref $value eq 'ARRAY') {
				next;
                        	#$value = '['.join(', ',@$value).']';
			} elsif (ref $value eq 'HASH') {
				next;
				#$value = '{'.join(', ',map {"$_ => $value->{$_}"} keys %$value).'}';
                      	}
                        unless (lc($key) eq "password" || lc($key) eq "identifier") {
                        	$t->param("session.".$section.".".$key=>$value);
                        }
                }
        } 
	$t->param(%{$_[1]});
	$t->param("webgui.version"=>$WebGUI::VERSION);
	return $t->output;
}

#-------------------------------------------------------------------
sub select {
	my ($templates, $output, $f, $key);
	$f = WebGUI::HTMLForm->new(1);
	$templates = getList();
	$f->select("templateId",$templates,'',[$_[0]],'','','onChange="changeTemplatePreview(this.form.templateId.value)"');
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
	foreach $key (keys %{$templates}) {
		$output .= "	var b".$key." = '".draw($key)."';\n";
	}
	$output .= '</script>';
	$output .= $f->printRowsOnly;
	$output .= '<div id="templatePreview" style="padding: 5px;"></div>';
	return $output;
}

1;

