package WebGUI::Workflow::Activity::PurgeOldTrash;


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
use WebGUI::Asset;

=head1 NAME

Package WebGUI::Workflow::Activity::PurgeOldTrash

=head1 DESCRIPTION

Purges trash that's been in the system for a while.

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
	my $i18n = WebGUI::International->new($session, "Asset");
	push(@{$definition}, {
		name=>$i18n->get("purge old trash"),
		properties=> {
			purgeAfter=>{
				fieldType=>"interval",
				defaultValue=>60*60*24*30,
				label=>$i18n->get("purge trash after"),
				hoverHelp=>$i18n->get("purge trash after help")
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
       	my $sth = $self->session->db->read("select assetId,className from asset where state='trash' and stateChanged < ?", [time() - $self->get("purgeAfter")]);
        while (my ($id, $class) = $sth->array) {
        	my $asset = WebGUI::Asset->new($self->session, $id,$class);
               $asset->purge if (defined $asset);
        }
	return $self->COMPLETE;
}




1;


