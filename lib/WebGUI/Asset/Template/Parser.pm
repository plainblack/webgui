package WebGUI::Asset::Template::Parser;

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
use WebGUI::International;
use Scalar::Util qw(blessed);


#-------------------------------------------------------------------

=head2 addSessionVars ( vars ) 

Appends session variables to the variable list.

=head3 vars

A reference to the template variable hash.

=cut

sub addSessionVars {
	my $self = shift;
	my $vars = shift;
	# These are the only session template variables used in the core as 
	# of 6.8.5.  Further use of session template vars is deprecated.
	$vars->{"session.user.username"} = $self->session->user->username;
	$vars->{"session.user.firstDayOfWeek"} = $self->session->user->profileField("firstDayOfWeek");
	$vars->{"session.config.extrasurl"} = $self->session->url->extras();
	$vars->{"session.var.adminOn"} = $self->session->var->isAdminOn;
	$vars->{"session.setting.companyName"} = $self->session->setting->get("companyName");
	$vars->{"session.setting.anonymousRegistration"} = $self->session->setting->get("anonymousRegistration");
	my $forms = $self->session->form->paramsHashRef();
	foreach my $field (keys %$forms) {
		if ($forms->{$field}) {
			$vars->{"session.form.".$field} = 
				(ref($forms->{$field}) eq 'ARRAY')
					?$forms->{$field}[$forms->{$field}[-1]]
					:$forms->{$field};
		}
	}
        my $scratch = $self->session->scratch->{_data};
        foreach my $field (keys %$scratch) {
                if ($scratch->{$field}) {
                        $vars->{"session.scratch.".$field} = $scratch->{$field};
                }
        }
	$vars->{"webgui.version"} = $WebGUI::VERSION;
	$vars->{"webgui.status"} = $WebGUI::STATUS;
	return $vars;
}

#-------------------------------------------------------------------

=head2 downgrade ( vars )

Removes or converts things HTML::Template-like engines can't handle.  Coderefs
are removed, blessed objects are removed, and hashes are recursively flattened
by appending keys separated by dots (e.g. { foo => { bar => 'baz' } } becomes
{ 'foo.bar' => 'baz' }.  Also, array elements that aren't hashes are converted
to hashes via { value => $bareValue }.

=cut

sub downgrade {
    my ($self, $vars) = @_;
    for my $k (keys %$vars) {
        my $v = $vars->{$k};
        if (blessed($v) || ref $v eq 'CODE') {
            delete $vars->{$k};
        }
        elsif (ref $v eq 'ARRAY') {
            for my $i (0..$#$v) {
                if (ref $v->[$i] eq 'HASH') {
                    $self->downgrade($v->[$i]);
                }
                else {
                    my %hash = ( value => $v->[$i] );
                    $self->downgrade(\%hash);
                    $v->[$i] = \%hash;
                }
            }
        }
        elsif (ref $v eq 'HASH') {
            delete $vars->{$k};
            my %flatter;
            for my $subkey (keys %$v) {
                $flatter{"$k.$subkey"}  = $v->{$subkey};
            }
            $self->downgrade(\%flatter);
            @{$vars}{keys %flatter} = values %flatter;
        }
    }
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
