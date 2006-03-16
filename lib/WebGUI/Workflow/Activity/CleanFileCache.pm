package WebGUI::Workflow::Activity::CleanFileCache;


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
use base 'WebGUI::Workflow::Activity';
use WebGUI::Cache::FileCache;

=head1 NAME

Package WebGUI::Workflow::Activity::CleanFileCache

=head1 DESCRIPTION

This activity deletes files from the file cache if the file cache has gotten too big.

=head1 SYNOPSIS

See WebGUI::Workflow::Activity for details on how to use any activity.

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 definition ( session, definition )

See WebGUI::Workflow::Activity::defintion() for details.

=cut 

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my $i18n = WebGUI::International->new($session, "Workflow_Activity_CleanFileCache");
	push(@{$definition}, {
		name=>$i18n->get("topicName"),
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
        my $cache = WebGUI::Cache::FileCache->new;
        while ($size > $self->get("sizeLimit")) {
                $size = $cache->getNamespaceSize($expiresModifier);
                $expiresModifier += 60 * 30; # add 30 minutes each pass
        }
	return $self->COMPLETE;
}



1;


