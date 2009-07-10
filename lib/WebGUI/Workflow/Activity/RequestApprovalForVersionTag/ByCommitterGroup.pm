package WebGUI::Workflow::Activity::RequestApprovalForVersionTag::ByCommitterGroup;


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

Package WebGUI::Workflow::Activity::RequestApprovalForVersionTag::ByCommitterGroup

=head1 DESCRIPTION

Requests approval for a version tag only if the committer is a member of
the specified group.

In this way, we can make certain groups of users go through additional 
approval.

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
    my $i18n        = WebGUI::International->new($session, "Activity_RequestApprovalForVersionTag_ByCommitterGroup");
    push @{ $definition }, {
        name        => $i18n->get( "topicName" ),
        properties  => {
            committerGroupId => {
                fieldType       => "group",
                defaultValue    => 0,
                label           => $i18n->get( 'committerGroupId label' ),
                hoverHelp       => $i18n->get( 'committerGroupId description' ),
            },
            invertGroupSetting => {
                fieldType       => "yesNo",
                defaultValue    => 0,
                label           => $i18n->get( 'invertGroupSetting label' ),
                hoverHelp       => $i18n->get( 'invertGroupSetting description' ),
            },
        },
    };
    return $class->SUPER::definition( $session, $definition );
}

#----------------------------------------------------------------------------

=head2 execute ( tag, instance )

Request the approval. Make sure the tag is covered by the C<committerGroupId>
and then request approval. 

If the tag is not covered, just continue with the workflow.

=cut

sub execute {
    my $self        = shift;
    my $tag         = shift;
    my $instance    = shift;
    my $committedBy = WebGUI::User->new( $self->session, $tag->get( 'committedBy' ) );

    # If tag is handled by this activity
    if ( (!$self->get( 'invertGroupSetting' ) && $committedBy->isInGroup( $self->get( 'committerGroupId' ) ) )
      || ($self->get( 'invertGroupSetting' ) && !$committedBy->isInGroup( $self->get( 'committerGroupId' ) ) ) ) {
        return $self->SUPER::execute( $tag, $instance );
    }
    else {
        return $self->COMPLETE;
    }
}


1;

