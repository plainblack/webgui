package WebGUI::Macro::L_loginBox;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Form;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::Template;
use WebGUI::URL;

#-------------------------------------------------------------------
sub _createURL {
	return '<a href="'.WebGUI::URL::page("op=logout").'">'.$_[0].'</a>';
}

#-------------------------------------------------------------------
sub process {
        my @param = WebGUI::Macro::getParams($_[0]);
	my $templateId = $param[2] || 1;
	my %var;	
        $var{'user.isVisitor'} = ($session{user}{userId} == 1);
	$var{'customText'} = $param[1];
	$var{'customText'} =~ s/%(.*?)%/_createURL($1)/ge;
	$var{'hello.label'} = WebGUI::International::get(48);
	$var{'logout.url'} = WebGUI::URL::page("op=logout");
	$var{'account.display.url'} = WebGUI::URL::page('op=displayAccount');
        $var{'logout.label'} = WebGUI::International::get(49);
        my $boxSize = $param[0];
        $boxSize = 12 if (not defined $boxSize);
        if (index(lc($ENV{HTTP_USER_AGENT}),"msie") < 0) {
        	$boxSize = int($boxSize=$boxSize*2/3);
        }
	$var{'form.header'} = WebGUI::Form::formHeader()
		.WebGUI::Form::hidden({
			name=>"op",
			value=>"login"
			});
	$var{'username.label'} = WebGUI::International::get(50);
	$var{'username.form'} = WebGUI::Form::text({
		name=>"username",
		size=>$boxSize,
		extras=>'class="loginBoxField"'
		});
        $var{'password.label'} = WebGUI::International::get(51);
        $var{'password.form'} = WebGUI::Form::password({
		name=>"identifier",
		size=>$boxSize,
		extras=>'class="loginBoxField"'
		});
        $var{'form.login'} = WebGUI::Form::submit({
		value=>WebGUI::International::get(52),
		extras=>'class="loginBoxButton"'
		});
        $var{'account.create.url'} = WebGUI::URL::page('op=createAccount');
	$var{'account.create.label'} = WebGUI::International::get(407);
	$var{'form.footer'} = '</form>';
        return WebGUI::Template::process(WebGUI::Template::get($templateId,"Macro/L_loginBox"),\%var); 
}

1;

