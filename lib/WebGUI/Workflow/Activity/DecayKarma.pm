package WebGUI::Workflow::Activity::DecayKarma;


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
use base 'WebGUI::Workflow::Activity';

=head1 NAME

Package WebGUI::Workflow::Activity::DecayKarma

=head1 DESCRIPTION

Subtracts a little bit of karma from each user. This can be used to slowly degrade the abilities of the users who stay away from the site for a long period of time.

=head1 SYNOPSIS

See WebGUI::Workflow::Activity for details on how to use any activity.

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 definition ( session, definition )

See WebGUI::Workflow::Activity::definition() for details.

=cut 

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my $i18n = WebGUI::International->new($session, "Workflow_Activity_DecayKarma");
	push(@{$definition}, {
		name=>$i18n->get("activityName"),
		properties=> {
			minimumKarma => {
				fieldType=>"integer",
				label=>$i18n->get("minimum karma"),
				defaultValue=>0,
				hoverHelp=>$i18n->get("minimum karma help")
				},
			decayFactor => {
				fieldType=>"integer",
				label=>$i18n->get("decay factor"),
				defaultValue=>1,
				hoverHelp=>$i18n->get("decay factor help")
				}
			}
		});
	return $class->SUPER::definition($session,$definition);
}


#-------------------------------------------------------------------

=head2 execute (  )

See WebGUI::Workflow::Activity::execute() for details.

=cut

sub execute {
	my $self = shift;
        $self->session->db->write("update users set karma=karma-? where karma > ?", [$self->get("decayFactor"), $self->get("minimumKarma")]);
	return $self->COMPLETE;
}



1;


