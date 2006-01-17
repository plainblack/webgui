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
        while (my ($section, $hash) = each %{$self->session}) {
                next unless (ref $hash eq 'HASH');
        while (my ($key, $value) = each %$hash) {
                unless (lc($key) eq "password" || lc($key) eq "identifier") {
                $vars->{"session.".$section.".".$key} = $value;
                        }
                }
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
