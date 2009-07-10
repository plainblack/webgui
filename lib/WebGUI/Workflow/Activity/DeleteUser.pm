package WebGUI::Workflow::Activity::DeleteUser;

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

Package WebGUI::Workflow::Activity::DeleteUser

=head1 DESCRIPTION

Deletes a WebGUI user

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
    my $i18n = WebGUI::International->new($session, "WebGUI");
    push(@{$definition}, {
        name => $i18n->get("delete user"),
        properties=> {},
    });
    return $class->SUPER::definition($session,$definition);
}

#-------------------------------------------------------------------

=head2 execute ( [ object ] )

See WebGUI::Workflow::Activity::execute() for details.

=cut

sub execute {
    my $self = shift;
    my $user = shift;
    my $instance = shift;

    $instance->delete;
    $user->delete;

    return $self->COMPLETE;
}

1;

#vim:ft=perl
