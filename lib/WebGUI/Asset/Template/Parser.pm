package WebGUI::Asset::Template::Parser;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use WebGUI::International;


#-------------------------------------------------------------------

=head2 addSessionVars ( vars ) 

Appends session variables to the variable list.

=head3 vars

A reference the template variable hash.

=cut

sub addSessionVars {
	my $self = shift;
	my $vars = shift;
	# These are the only session template variables used in the core as 
	# of 6.8.5.  Further use of session template vars is deprecated.
	$vars->{"session.user.username"} = $self->session->user->username;
	$vars->{"session.user.firstDayOfWeek"} = $self->session->user->profileField("firstDayOfWeek");
	$vars->{"session.config.extrasurl"} = $self->session->config->get("extrasURL");
	$vars->{"session.var.adminOn"} = $self->session->var->isAdminOn;
	$vars->{"session.setting.companyName"} = $self->session->setting->get("companyName");
	$vars->{"session.setting.anonymousRegistration"} = $self->session->setting->get("anonymousRegistration");
	foreach my $field ($self->session->form->param) {
		$vars->{"session.form.".$field} = $self->session->form->param($field);
	}
	$vars->{"webgui.version"} = $WebGUI::VERSION;
	$vars->{"webgui.status"} = $WebGUI::STATUS;
	return $vars;
}

#-------------------------------------------------------------------

=head2 new ( session )

Constructor.

=head3 session

A reference to the current session.

=cut

sub new {
	my $class = shift;
	my $session = shift;
	bless {_session=>$session}, $class; 
}

#-------------------------------------------------------------------

=head2 process ( template, vars )

Evaluate a template replacing template commands for HTML.  This method is required to be overridden.

=head3 template

A scalar variable containing the template.

=head3 vars

A hash reference containing template variables and loops. 

=cut

sub process { }

#-------------------------------------------------------------------

=head2 session ( )

A reference to the current session.

=cut

sub session {
	my $self = shift;
	return $self->{_session};
}


1;
