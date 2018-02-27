package WebGUI::Form::Captcha;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use base 'WebGUI::Form::Text';
use WebGUI::International;
use WebGUI::Storage;
use LWP::UserAgent;
use JSON;

=head1 NAME

Package WebGUI::Form::Captcha

=head1 DESCRIPTION

Creates a captcha form element that helps verify a human is submitting the form rather than a bot.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::Text.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the super class for additional details.

=head3 additionalTerms

The following additional parameters have been added via this sub class.

=head3 label

Defaults to "Verify Your Humanity"

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	my $i18n = WebGUI::International->new($session,"Form_Captcha");
	push(@{$definition}, {
		label => {
			defaultValue=>$i18n->get("verify your humanity")
			},
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2  getDatabaseFieldType ( )

Returns "BOOLEAN".

=cut 

sub getDatabaseFieldType {
    return "BOOLEAN";
}

#-------------------------------------------------------------------

=head2 getName ( session )

Returns the human readable name of this control.

=cut

sub getName {
    my ($self, $session) = @_;
    return WebGUI::International->new($session, 'Form_Captcha')->get('topicName');
}

#-------------------------------------------------------------------

=head2 getValue ( )

Returns a boolean indicating whether the string typed matched the image.

=cut

sub getValue {
    my $self        = shift;

    if ($self->session->setting->get('useRecaptcha')) {
        my $privKey = $self->session->setting->get('recaptchaPrivateKey');
        my $response = $self->session->form->param('g-recaptcha-response');

        my $ua = LWP::UserAgent->new;
        my $res = $ua->post('https://www.google.com/recaptcha/api/siteverify', {
            secret      => $privKey,
            remoteip    => $self->session->env->getIp,
            response    => $response,
        });
        if ($res->is_success) {
            my $json = $res->content;
            my $data = eval { JSON::decode_json($json); };
            if ($@) {
                return undef;
            }
            return $data->{success} ? 1 : 0;
        }
        else {
            $self->session->log->warn("Google lookup failed");
        }
        return undef;
    }

    my $value       = $self->SUPER::getValue(@_); 
    my $challenge   = $self->session->scratch->get("captcha_".$self->get("name"));
    $self->session->scratch->delete("captcha_".$self->get("name"));
    my $passed  = lc $value eq lc $challenge;
    $self->session->errorHandler->info( 
        "Checking CAPTCHA '" . $self->get("name") . "': " . ( $passed ? "PASSED!" : "FAILED!" )
        . " Got: '" . $value . "', Wanted: '" . $challenge . "'"
    );
    return $passed;
}

#-------------------------------------------------------------------

=head2 isDynamicCompatible ( )

A class method that returns a boolean indicating whether this control is compatible with the DynamicField control.

=cut

sub isDynamicCompatible {
    return 1;
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a captcha field.

=cut

sub toHtml {
    my $self = shift;

    if ($self->session->setting->get('useRecaptcha')) {
        my $env = $self->session->env;
        my $pubKey = $self->session->setting->get('recaptchaPublicKey');
        my $server = "http://www.google.com/recaptcha/api";
        if ($env->sslRequest) {
            $server = "https://www.google.com/recaptcha/api";
        }
        return
            '<script type="text/javascript" src="https://www.google.com/recaptcha/api.js"></script>'
            . qq!<div class="g-recaptcha" data-sitekey="$pubKey"></div>!
            ;
    }

    my $storage = WebGUI::Storage->createTemp($self->session);
    my ($filename, $challenge) = $storage->addFileFromCaptcha;
    $self->set("size", 6);
    $self->set("maxlength", 6);
    $self->set("extras", 'class="wg-captchaForm"');
    $self->session->scratch->set("captcha_".$self->get("name"), $challenge);
    return $self->SUPER::toHtml.'<img src="'.$storage->getUrl($filename).'" class="wg-captchaImage" alt="captcha" />';
}

=head2 getErrorMessage ( )

Returns an internationalized error message based on which kind of captcha is being used.

=cut

sub getErrorMessage {
    my $self = shift;
    my $session = $self->session;
	my $i18n = WebGUI::International->new($session,"Form_Captcha");
    if ($session->setting->get('useRecaptcha')) {
        return $i18n->get("recaptcha failure");
    }
    return $i18n->get("captcha failure");
}


1;

