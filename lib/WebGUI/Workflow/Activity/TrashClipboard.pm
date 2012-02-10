package WebGUI::Workflow::Activity::TrashClipboard;


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
use WebGUI::Asset;
use WebGUI::AssetClipboard;

=head1 NAME

Package WebGUI::Workflow::Activity::TrashClipboard;

=head1 DESCRIPTION

Deletes 

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
	my $i18n = WebGUI::International->new($session, "Workflow_Activity_TrashClipboard");
	push(@{$definition}, {
		name=>$i18n->get("activityName"),
		properties=> {
			trashAfter => {
				fieldType=>"interval",
				label=>$i18n->get("trash after"),
				defaultValue=>60 * 60 * 24 * 30,
				hoverHelp=>$i18n->get("trash after help")
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
    my $expireDate = (time()-$self->get("trashAfter"));
    my $root = WebGUI::Asset->getRoot($self->session);
    foreach my $asset ( @{ $root->getAssetsInClipboard('', '', $expireDate) } ) {
        	$asset->trash;
    }
	return $self->COMPLETE;
}



1;


