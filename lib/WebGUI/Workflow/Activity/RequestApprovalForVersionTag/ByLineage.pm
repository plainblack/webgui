package WebGUI::Workflow::Activity::RequestApprovalForVersionTag::ByLineage;


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
use base 'WebGUI::Workflow::Activity::RequestApprovalForVersionTag';

=head1 NAME

Package WebGUI::Workflow::Activity::RequestApprovalForVersionTag::ByLineage

=head1 DESCRIPTION

Requests approval for a version tag only if all the content is under
the specified asset. 

In this way we can create sections of our site that require approval 
from certain people.

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
    my $class       = shift;
    my $session     = shift;
    my $definition  = shift;
    my $i18n        = WebGUI::International->new($session, "Activity_RequestApprovalForVersionTag_ByLineage");
    push @{ $definition }, {
        name        => $i18n->get( "topicName" ),
        properties  => {
            assetId => {
                fieldType       => "asset",
                defaultValue    => 0,
                label           => $i18n->get( 'assetId label' ),
                hoverHelp       => $i18n->get( 'assetId description' ),
            },
        },
    };
    return $class->SUPER::definition( $session, $definition );
}

#----------------------------------------------------------------------------

=head2 execute ( tag, instance )

Request the approval. Make sure the tag is covered by the C<assetId>
and then request approval. 

If the tag is not covered, just continue with the workflow.

=cut

sub execute {
    my $self        = shift;
    my $tag         = shift;
    my $instance    = shift;
    my $ancestor    = WebGUI::Asset->newById( $self->session, $self->get( 'assetId' ) );
    my $lineage     = $ancestor->get( 'lineage' );
    # Descendant has at least the ancestors lineage plus 6 more character
    my $isDescendant    = qr{^$lineage.{6}};

    # If one piece of content isn't under our ancestor, complete
    for my $asset ( @{ $tag->getAssets } ) {
        if ( $asset->get( 'lineage' ) !~ $isDescendant ) {
            return $self->COMPLETE;
        }
    }
    
    # Every piece is under our ancestor, get some approval
    return $self->SUPER::execute( $tag, $instance );
}

1;

