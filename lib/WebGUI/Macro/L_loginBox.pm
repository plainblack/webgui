package WebGUI::Macro::L_loginBox;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
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
use WebGUI::Asset::Template;
use URI;

=head1 NAME

Package WebGUI::Macro::L_loginBox

=head1 DESCRIPTION

Macro for displaying either a login box and registration link to the
user, or, if they're logged in, a link to access their account and log out.

=head2 _createURL ( text )

internal utility sub for wrapping text in a link.

=head3 text

text to wrap in a link for logging out.

=cut

#-------------------------------------------------------------------
sub _createURL {
	my $session = shift;
	my $text = shift;
	return '<a href="'.$session->url->page("op=auth;method=logout").'">'.$text.'</a>';
}

#-------------------------------------------------------------------

=head2 process ( boxSize, text, templateId )

=head3 boxSize

The size of the username and password form fields.  Defaults to 12.
Non-IE browsers will have their boxSize automatically scaled by 2/3
due differences in the way they render text form boxes.

=head3 text

A custom text message, processed for embedded text surrounded by percent signs
to turn into a link to logout.

=head3 templateId

The ID of a template for custom layout of the login box and text.

=cut

sub process {
	my $session = shift;
        my @param = @_;
	my $templateId = $param[2] || "PBtmpl0000000000000044";
	my %var;	
	my $i18n = WebGUI::International->new($session,'Macro_L_loginBox');
        $var{'user.isVisitor'} = ($session->var->get("userId") eq "1");
	$var{'customText'} = $param[1];
	$var{'customText'} =~ s/%(.*?)%/_createURL($session,$1)/ge;
	$var{'hello.label'} = $i18n->get(48);
	$var{'logout.url'} = $session->url->page("op=auth;method=logout");
	$var{'account.display.url'} = $session->url->page('op=auth;method=displayAccount');
        $var{'logout.label'} = $i18n->get(49);
        
        # A hidden field with the current URL
        my $returnUrl   = $session->url->page;
        if ( !$session->form->get("op") eq "auth" ) {
            $returnUrl  .= '?' . $session->env->get( "QUERY_STRING" );
        }
        $var{'form.returnUrl'} 
            = WebGUI::Form::hidden( $session, {
                name        => 'returnUrl',
                value       => $session->url->page($session->env->get("QUERY_STRING")),
            });
            
        # Fix box size
        my $boxSize = $param[0];
        $boxSize = 12 unless ($boxSize);
        if (index(lc($session->env->get("HTTP_USER_AGENT")),"msie") < 0) {
        	$boxSize = int($boxSize=$boxSize*2/3);
        }

	my $action;
        if ($session->config->get('sslEnabled') && $session->setting->get("encryptLogin")) {
                my $uri = URI->new($session->url->page(undef,1));
                $uri->scheme('https');
                $uri->host_port($uri->host);
                $action = $uri->canonical->as_string;
        }
	$var{'form.header'} = WebGUI::Form::formHeader($session,{action=>$action})
		.WebGUI::Form::hidden($session,{
			name=>"op",
			value=>"auth"
			})
		.WebGUI::Form::hidden($session,{
			name=>"method",
			value=>"login"
			});
	$var{'username.label'} = $i18n->get(50, 'WebGUI');
	$var{'username.form'} = WebGUI::Form::text($session,{
		name=>"username",
		size=>$boxSize,
		extras=>'class="loginBoxField"'
		});
        $var{'password.label'} = $i18n->get(51, 'WebGUI');
        $var{'password.form'} = WebGUI::Form::password($session,{
		name=>"identifier",
		size=>$boxSize,
		extras=>'class="loginBoxField"'
		});
        $var{'form.login'} = WebGUI::Form::submit($session,{
		value=>$i18n->get(52, 'WebGUI'),
		extras=>'class="loginBoxButton"'
		});
        $var{'account.create.url'} = $session->url->page('op=auth;method=createAccount');
	$var{'account.create.label'} = $i18n->get(407, 'WebGUI');
	$var{'form.footer'} = WebGUI::Form::formFooter($session,);
        return WebGUI::Asset::Template->new($session,$templateId)->process(\%var); 
}

1;

