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
use WebGUI::ErrorHandler;
use WebGUI::International;
use WebGUI::Session;
use WebGUI::SQL;


#-------------------------------------------------------------------
sub get {
	my $templateId = $_[0] || 1;
	my $namespace = $_[1] || "Page";
        my ($template) = WebGUI::SQL->quickArray("select template from template 
		where templateId=".$templateId." and namespace=".quote($namespace));
        return $template;
}

#-------------------------------------------------------------------
sub getList {
	my $namespace = $_[0] || "Page";
	return WebGUI::SQL->buildHashRef("select templateId,name from template where namespace=".quote($namespace)." order by name");
}

#-------------------------------------------------------------------
sub process {
	my ($t, $test, $html);
	$html = $_[0];
	eval {
		$t = HTML::Template->new(
   			scalarref=>\$html,
			global_vars=>1,
   			loop_context_vars=>1,
			die_on_bad_params=>0,
			strict=>0
			);
	};
	unless ($@) {
	        while (my ($section, $hash) = each %session) {
			next unless (ref $hash eq 'HASH');
        		while (my ($key, $value) = each %$hash) {
        	                unless (lc($key) eq "password" || lc($key) eq "identifier") {
                	        	$t->param("session.".$section.".".$key=>$value);
                        	}
	                }
        	} 
		$t->param(%{$_[1]});
		$t->param("webgui.version"=>$WebGUI::VERSION);
		return $t->output;
	} else {
		WebGUI::ErrorHandler::warn("Error in template. ".$@);
		return WebGUI::International::get(848).$html;
	}
}


1;

