package WebGUI::Macro::L_loginBox;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
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
use WebGUI::Session;
use WebGUI::Asset::Template;
use WebGUI::URL;

#-------------------------------------------------------------------
sub _createURL {
	return '<a href="'.WebGUI::URL::page("op=auth;method=logout").'">'.$_[0].'</a>';
}

#-------------------------------------------------------------------
sub process {
        my @param = @_;
	my $templateId = $param[2] || "PBtmpl0000000000000044";
	my %var;	
        $var{'user.isVisitor'} = ($session{user}{userId} eq "1");
	$var{'customText'} = $param[1];
	$var{'customText'} =~ s/%(.*?)%/_createURL($1)/ge;
	$var{'hello.label'} = WebGUI::International::get(48,'Macro_L_loginBox');
	$var{'logout.url'} = WebGUI::URL::page("op=auth;method=logout");
	$var{'account.display.url'} = WebGUI::URL::page('op=auth;method=displayAccount');
        $var{'logout.label'} = WebGUI::International::get(49,'Macro_L_loginBox');
        my $boxSize = $param[0];
        $boxSize = 12 unless ($boxSize);
        if (index(lc($ENV{HTTP_USER_AGENT}),"msie") < 0) {
        	$boxSize = int($boxSize=$boxSize*2/3);
        }
	my $action;
        if ($session{setting}{encryptLogin}) {
                $action = WebGUI::URL::page(undef,1);
                $action =~ s/http:/https:/;
        }
	$var{'form.header'} = WebGUI::Form::formHeader({action=>$action})
		.WebGUI::Form::hidden({
			name=>"op",
			value=>"auth"
			})
		.WebGUI::Form::hidden({
			name=>"method",
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
        $var{'account.create.url'} = WebGUI::URL::page('op=auth;method=createAccount');
	$var{'account.create.label'} = WebGUI::International::get(407);
	$var{'form.footer'} = WebGUI::Form::formFooter();
        return WebGUI::Asset::Template->new($templateId)->process(\%var); 
}

1;

