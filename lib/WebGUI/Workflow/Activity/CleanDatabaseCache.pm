package WebGUI::Workflow::Activity::CleanDatabaseCache;


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
use WebGUI::Cache::Database;

=head1 NAME

Package WebGUI::Workflow::Activity::CleanDatabaseCache

=head1 DESCRIPTION

This activity deletes entries from the database cache if the cache size has gotten too big.

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
	my $i18n = WebGUI::International->new($session, "Workflow_Activity_CleanDatabaseCache");
	push(@{$definition}, {
		name=>$i18n->get("activityName"),
		properties=> {
			sizeLimit => {
				fieldType=>"integer",
				label=>$i18n->get("size limit"),
				subtext=>$i18n->get("bytes"),
				defaultValue=>100000000,
				hoverHelp=>$i18n->get("size limit help")
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
        my $size = $self->get("sizeLimit") + 10;
        my $expiresModifier = 0;
        my $cache = WebGUI::Cache::Database->new($self->session);
        while ($size > $self->get("sizeLimit")) {
                $size = $cache->getNamespaceSize($expiresModifier);
                $expiresModifier += 60 * 30; # add 30 minutes each pass
        }
	return $self->COMPLETE;
}



1;


