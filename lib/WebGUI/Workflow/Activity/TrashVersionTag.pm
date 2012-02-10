package WebGUI::Workflow::Activity::TrashVersionTag;


=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
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
use WebGUI::VersionTag;


=head1 NAME

Package WebGUI::Workflow::Activity::TrashVersionTag

=head1 DESCRIPTION

This activity trashes all content attached to a version tag.

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
	my $i18n = WebGUI::International->new($session, "VersionTag");
	push(@{$definition}, {
		name=>$i18n->get("trash version tag"),
		properties=> { }
		});
	return $class->SUPER::definition($session,$definition);
}


#-------------------------------------------------------------------

=head2 execute (  )

See WebGUI::Workflow::Activity::execute() for details.

=cut

sub execute {
	my $self = shift;
	my $versionTag = shift;
	foreach my $asset (@{$versionTag->getAssets}) {
		$asset->trash;
	}
	$versionTag->lock;
	$versionTag->clearWorking;
	return $self->COMPLETE;
}




1;


