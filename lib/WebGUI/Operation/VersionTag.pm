package WebGUI::Operation::VersionTag;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2008 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use WebGUI::Paginator;
use WebGUI::AdminConsole;
use WebGUI::International;
use WebGUI::VersionTag;
use WebGUI::HTMLForm;
use WebGUI::Paginator;
use WebGUI::Operation::Spectre;

=head1 NAME

Package WebGUI::AssetVersioning

=head1 DESCRIPTION

This is a mixin package for WebGUI::Asset that contains all versioning related functions.

=head1 SYNOPSIS

 use WebGUI::Asset;

=head1 METHODS

These methods are available from this class:

=cut

#----------------------------------------------------------------------------

=head2 canApproveVersionTag ( session, tag [, user] )

Returns true if the user is allowed to approve this version tag. C<session>
is a WebGUI::Session, C<tag> is a WebGUI::VersionTag, C<user> is a 
WebGUI::User. If C<user> is not specified, users the default user from the 
session.

A user is allowed to approve a version tag if they are in the current
C<getGroupToApprove>. If this version tag does not currently need approval,
this returns false.

=cut

sub canApproveVersionTag {
    my $session     = shift;
    my $tag         = shift;
    my $user        = shift || $session->user;
    my $instance    = $tag->getWorkflowInstance;
    my $activity    = $instance->getNextActivity;
    
    # Check if this person is in one of the allowed groups
    my $groupToApprove  = $activity->can( 'getGroupToApprove' )
                        # New way returns an array reference
                        ? $activity->getGroupToApprove( $tag, $instance )
                        # Old way has a single group
                        : [ $activity->get( 'groupToApprove' ) ]
                        ;

    return 1 
        if grep { $user->isInGroup( $_ ) } @{ $groupToApprove };
}

#----------------------------------------------------------------------------

=head2 canViewVersionTag ( session, tag [, user] )

Returns true if the user is allowed to view this version tag. C<session>
is a WebGUI::Session, C<tag> is a WebGUI::VersionTag, C<user> is a 
WebGUI::User. If C<user> is not specified, uses the default user from the 
session.

A user is allowed to view a version tag if they are in the groupToUse
of the version tag, or if they canView.

=cut

sub canViewVersionTag {
    my $session     = shift;
    my $tag         = shift;
    my $user        = shift || $session->user;

    if ( $user->isInGroup( $tag->get("groupToUse") ) ) {
        return 1;
    }
    else { 
        return canView( $session, $user );
    }
}

#----------------------------------------------------------------------------

=head2 canView ( session [, user] )

Returns true if the user can administrate this operation. user defaults to 
the current user.

=cut

sub canView {
    my $session     = shift;
    my $user        = shift || $session->user;
    return $user->isInGroup( $session->setting->get("groupIdAdminVersionTag") );
}

#----------------------------------------------------------------------------

=head2 getVersionTagOptions ( session )

Gets a hash of tagId => name for all open version tags

=cut

sub getVersionTagOptions {
    my $session     = shift;
    tie my %tag, 'Tie::IxHash';
    
    for my $tag ( @{ WebGUI::VersionTag->getOpenTags( $session ) } ) {
        $tag{ $tag->getId } = $tag->get('name');
    }

    return %tag;
}

#-------------------------------------------------------------------

=head2 www_approveVersionTag ( session ) 

Sets an approval for a version tag.

=head3 session

A reference to the current session.

=cut

sub www_approveVersionTag {
    my $session     = shift;
    my $tag         = WebGUI::VersionTag->new( $session, $session->form->param("tagId") );

    return $session->privilege->insufficient 
        unless canApproveVersionTag( $session, $tag );
    
    my $activity    = $tag->getWorkflowInstance->getNextActivity;

    if ( $session->form->process("status", "selectBox") eq "approve" ) {
        $activity->setApproved( $instance );
    }
    else {
        $activity->setDenied( $instance );
    }

    $tag->set( { 
        comments    => $session->form->process("comments", "textarea"),
    });

    return www_manageVersions($session);
}

#-------------------------------------------------------------------

=head2 www_editVersionTag ( session, [ tagId ] )

Displays the edit version tag form.

=head3 session

A reference to the current session.

=head3 tagId

An open tag id. This is optional as it normally grabs this value from a form post.

=cut

sub www_editVersionTag {
	my $session = shift;
        return $session->privilege->insufficient() unless canView($session);
	my $tagId = shift || $session->form->param("tagId");
	my $ac = WebGUI::AdminConsole->new($session,"versions");
	my $i18n = WebGUI::International->new($session,"VersionTag");
        $ac->addSubmenuItem($session->url->page('op=manageVersions'), $i18n->get("manage versions"));
	my $f = WebGUI::HTMLForm->new($session);
	$f->submit;
	my $tag = WebGUI::VersionTag->new($session, $tagId);
	$f->hidden(
		-name=>"op",
		-value=>"editVersionTagSave"
		);
	my $value = $tag->getId if defined $tag;
	$f->hidden(
		-name=>"tagId",
		-value=>$value,
		-defaultValue=>"new"
		);
	$value = $tag->get("name") if defined $tag;
	$f->text(
		-name=>"name",
		-label=>$i18n->get("version tag name"),
		-hoverHelp=>$i18n->get("version tag name description"),
		-value=>$value,
		);
	my $workflowId = (defined $tag) ? $tag->get("workflowId") : $session->setting->get("defaultVersionTagWorkflow");
	my $groupId = (defined $tag) ? $tag->get("groupToUse") : "12";
	if (canView($session)) {
		$f->workflow(
			value=>$workflowId,
			type=>"WebGUI::VersionTag",
            includeRealtime=>1,
			);
		$f->group(
			value=>[$groupId],
			name=>"groupToUse",
			label=>$i18n->get("group to use"),
			hoverHelp=>$i18n->get("group to use help")
			);
	} else {
		$f->hidden(
			value=>$workflowId,
			name=>"workflowId"
			);
		$f->hidden(
			value=>$groupId,
			name=>"groupToUse"
			);
	}
	$f->submit;
        return $ac->render($f->print,$i18n->get("edit version tag"));	
}


#-------------------------------------------------------------------

=head2 www_editVersionTagSave ( session )

Adds a version tag and sets the user's default version tag to that.

=head3 session

A reference to the current session.

=cut

sub www_editVersionTagSave {
	my $session = shift;
        return $session->session->privilege->insufficient() unless canView($session);
	if ($session->form->param("tagId") eq "new") {
		my $tag = WebGUI::VersionTag->create($session, {
			name=>$session->form->process("name","text", "Untitled"),
			groupToUse=>$session->form->process("groupToUse","group","12"),
			workflowId=>$session->form->process("workflowId","workflow", $session->setting->get("defaultVersionTagWorkflow"))
			});
		$tag->setWorking;
	} else {
		my $tag = WebGUI::VersionTag->new($session, $session->form->param("tagId"));
		$tag->set({
			name=>$session->form->process("name","text", "Untitled"),
			groupToUse=>$session->form->process("groupToUse","group","12"),
			workflowId=>$session->form->process("workflowId","workflow", $session->setting->get("defaultVersionTagWorkflow"))
			});
	}
	return www_manageVersions($session);
}


#-------------------------------------------------------------------

=head2 www_commitVersionTag ( session ) 

Prompts a user to apply some comments before they commit their tag.

=head3 session

A reference to the current session.

=cut

sub www_commitVersionTag {
    my $session = shift;
    my $tagId = $session->form->param("tagId");

    if ( !$tagId ) { 
        return www_manageVersions( $session );
    }
    
    my $tag = WebGUI::VersionTag->new($session, $tagId);
    if ( !defined $tag || !$session->user->isInGroup($tag->get("groupToUse")) ) {
        return www_manageVersions( $session );
    }
    
    # Make sure we can connect to SPECTRE
    my $remote  = WebGUI::Operation::Spectre::getASpectre($session);
    my $i18n    = WebGUI::International->new($session, "VersionTag");
    if (!defined $remote) {
       $session->errorHandler->warn('Unable to connect to spectre.  Canceling the commit');
       my $output = sprintf qq{<h1>%s</h1>\n<p>%s</p><p><a href="%s">%s</a>},
           $i18n->get('broken spectre title', 'WebGUI'),
           $i18n->get('broken spectre body',  'WebGUI'),
           $session->url->getBackToSiteURL(),
           $i18n->get('493', 'WebGUI');
       return $session->style->userStyle($output);
    }
    $remote->disconnect;
    
    # Build the page
    my $output  = '';

    # Commit comments form
    my $f = WebGUI::HTMLForm->new($session);
    $f->submit;
    $f->readOnly(
            label=>$i18n->get("version tag name"),
            hoverHelp=>$i18n->get("version tag name description commit"),
            value=>$tag->get("name")
            );
    $f->hidden(
            name=>"tagId",
            value=>$session->form->param("tagId")
            );
    $f->hidden(
            name=>"op",
            value=>"commitVersionTagConfirm"
            );
    $f->textarea(
            name=>"comments",
            label=>$i18n->get("comments"),
            hoverHelp=>$i18n->get("comments description commit")
            );
    $f->submit;
    $output .= $f->print;
    
    # Revisions in this tag
    $output 
        .= '<table width="100%" class="content">'
        . '<tr>'
        . '<th></th>'
        . '<th>'.$i18n->get(99,"Asset").'</th>'
        . '<th>'.$i18n->get("type","Asset").'</th>'
        . '<th>'.$i18n->get("revision date","Asset").'</th>'
        . '<th>'.$i18n->get("revised by","Asset").'</th>'
        . '</tr> '
        ;
    
    my $p 
        = WebGUI::Paginator->new( $session,
            $session->url->page("op=commitVersionTag;tagId=".$tag->getId),
        );
    $p->setDataByQuery(q{
        SELECT assetData.revisionDate, users.username, asset.assetId, asset.className 
        FROM assetData 
        LEFT JOIN asset ON assetData.assetId = asset.assetId
        LEFT JOIN users ON assetData.revisedBy = users.userId
        WHERE assetData.tagId=? },
        undef, 
        undef, 
        [$tag->getId]
    );

    foreach my $row ( @{$p->getPageData} ) {
        my ( $date, $by, $id, $class) = @{ $row }{ qw( revisionDate username assetId className ) };
        my $asset = WebGUI::Asset->new($session, $id, $class, $date);
        $output 
            .= '<tr><td>'
            .$session->icon->view("func=view;revision=".$date, $asset->get("url"))
            .'</td>
            <td>'.$asset->getTitle.'</td>
            <td><img src="'.$asset->getIcon(1).'" alt="'.$asset->getName.'" />'.$asset->getName.'</td>
            <td>'.$session->datetime->epochToHuman($date).'</td>
            <td>'.$by.'</td></tr>';
    }
    $output .= '</table>'.$p->getBarSimple;
    
    # Render and send
    my $ac = WebGUI::AdminConsole->new($session,"versions");
    return $ac->render( $output );
}

#-------------------------------------------------------------------

=head2 www_commitVersionTagConfirm ( session )

Commits a version tag.

=head3 session

A reference to the current session.

=cut

sub www_commitVersionTagConfirm {
	my $session = shift;
	my $tagId = $session->form->param("tagId");
	if ($tagId) {
		my $tag = WebGUI::VersionTag->new($session, $tagId);
		if (defined $tag && $session->user->isInGroup($tag->get("groupToUse"))) {
			my $i18n = WebGUI::International->new($session, "VersionTag");
			$tag->set({comments=>$session->form->process("comments", "textarea")});
            my $message = $tag->requestCommit;
            my $error = "";
            if ($message) {
                 $error .= $i18n->get("bad commit")." ".$message;
            }
        	my $ac = WebGUI::AdminConsole->new($session,"versions");
			my $default = WebGUI::Asset->getDefault($session);
			return $ac->render(
				$error.'<p>'.$i18n->get("commit accepted").'</p>'
				.'<ul>
				<li><a href="'.$default->getUrl.'">'.$i18n->get("back to home").'</a></li>
				<li><a href="'.$default->getUrl("op=manageVersions").'">'.$i18n->get("manage versions").'</a></li>
				</ul>'	
				);
		}
	}
	return www_manageVersions($session);	
}

#-------------------------------------------------------------------

=head2 www_manageCommittedVersions ( session )

Shows a list of the committed asset version tags.

=head3 session

A reference to the current session.

=cut

sub www_manageCommittedVersions {
    my $session = shift;
    return $session->privilege->adminOnly
        unless canView($session);
    my $ac = WebGUI::AdminConsole->new($session,"versions");
    my $i18n = WebGUI::International->new($session,"VersionTag");
    my $rollback = $i18n->get('rollback');
    my $rollbackPrompt = $i18n->get('rollback version tag confirm');
    $ac->addSubmenuItem($session->url->page('op=editVersionTag'), $i18n->get("add a version tag"));
    $ac->addSubmenuItem($session->url->page('op=manageVersions'), $i18n->get("manage versions"));
    $ac->addSubmenuItem($session->url->page('op=managePendingVersions'), $i18n->get("manage pending versions")) if canView($session);
    my $output = '<table width="100%" class="content">
        <tr><th>'.$i18n->get("version tag name").'</th><th>'.$i18n->get("committed on").'</th><th>'.$i18n->get("committed by").'</th><th></th></tr> ';
    my $paginator = WebGUI::Paginator->new($session, $session->url->page("op=manageCommittedVersions"));
    $paginator->setDataByQuery('select tagId,name,commitDate,committedBy from assetVersionTag where isCommitted=1 ORDER BY commitDate DESC');
    my @versionTagFields = qw/tagId name commitDate committedBy /;
    foreach my $versionData (@{ $paginator->getPageData }) {
        my ($id,$name,$date,$by) = @{ $versionData }{@versionTagFields};
        my $u = WebGUI::User->new($session,$by);
        $output .= '<tr>
            <td><a href="'.$session->url->page("op=manageRevisionsInTag;tagId=".$id).'">'.$name.'</a></td>
            <td>'.$session->datetime->epochToHuman($date).'</td>
            <td>'.$u->username.'</td>
            <td><a href="'.$session->url->page("proceed=manageCommittedVersions;op=rollbackVersionTag;tagId=".$id).'" onclick="return confirm(\''.$rollbackPrompt.'\');">'.$rollback.'</a></td></tr>';
    }
    $output .= '</table>';
	$output .= $paginator->getBarTraditional();
    return $ac->render($output,$i18n->get("committed versions"));
}

#-------------------------------------------------------------------

=head2 www_managePendingVersions ( session )

Shows a list of the pending asset version tags.

=head3 session

A reference to the current session.

=cut

sub www_managePendingVersions {
        my $session = shift;
        return $session->privilege->adminOnly() unless canView($session);
        my $ac = WebGUI::AdminConsole->new($session,"versions");
        my $i18n = WebGUI::International->new($session,"VersionTag");
        $ac->addSubmenuItem($session->url->page('op=editVersionTag'), $i18n->get("add a version tag"));
        $ac->addSubmenuItem($session->url->page('op=manageVersions'), $i18n->get("manage versions"));
	$ac->addSubmenuItem($session->url->page('op=manageCommittedVersions'), $i18n->get("manage committed versions")) if canView($session);
        my $output = '<table width="100%" class="content">
        <tr><th>'.$i18n->get("version tag name").'</th></tr> ';
        my $sth = $session->db->read("select tagId,name,commitDate,committedBy from assetVersionTag where isCommitted=0 and isLocked=1");
        while (my ($id,$name) = $sth->array) {
                $output .= '<tr>
			<td><a href="'.$session->url->page("op=manageRevisionsInTag;tagId=".$id).'">'.$name.'</a></td>
			</tr>';
        }
        $sth->finish;
        $output .= '</table>';
        return $ac->render($output,$i18n->get("pending versions"));
}


#-------------------------------------------------------------------

=head2 www_manageVersions ( session )

Shows a list of the currently available asset version tags.

=head3 session

A reference to the current session.

=cut

sub www_manageVersions {
	my $session = shift;
        return $session->privilege->insufficient() unless canView($session);
        my $ac = WebGUI::AdminConsole->new($session,"versions");
	my $i18n = WebGUI::International->new($session,"VersionTag");
	$ac->addSubmenuItem($session->url->page('op=editVersionTag'), $i18n->get("add a version tag"));
	$ac->addSubmenuItem($session->url->page('op=managePendingVersions'), $i18n->get("manage pending versions")) if canView($session);
	$ac->addSubmenuItem($session->url->page('op=manageCommittedVersions'), $i18n->get("manage committed versions")) if canView($session);
	my ($tag,$workingTagId) = $session->db->quickArray("select name,tagId from assetVersionTag where tagId=?",[$session->scratch->get("versionTag")]);
	$tag ||= "None";
	my $rollback = $i18n->get("rollback");
	my $commit = $i18n->get("commit");
	my $setTag = $i18n->get("set tag");
	my $rollbackPrompt = $i18n->get("rollback version tag confirm");
	my $commitPrompt = $i18n->get("commit version tag confirm");
	my $output = '<p>'.$i18n->get("current tag is called").': <b>'.$tag.'</b>.</p><table width="100%" class="content">
	<tr><th></th><th>'.$i18n->get("version tag name").'</th><th>'.$i18n->get("created on").'</th><th>'.$i18n->get("created by").'</th><th></th></tr> ';
	foreach my $tag (@{WebGUI::VersionTag->getOpenTags($session)}) {	
		next unless ($session->user->isInGroup($tag->get("groupToUse")));
		my $u = WebGUI::User->new($session,$tag->get("createdBy"));
		$output .= '<tr>
			<td>';
        if (canView($session)) {
				$output .= $session->icon->delete("op=rollbackVersionTag;tagId=".$tag->getId,undef,$rollbackPrompt);
        }
        $output .= $session->icon->edit("op=editVersionTag;tagId=".$tag->getId)
			.'</td>
			<td><a href="'.$session->url->page("op=manageRevisionsInTag;tagId=".$tag->getId).'">'.$tag->get("name").'</a></td>
			<td>'.$session->datetime->epochToHuman($tag->get("creationDate")).'</td>
			<td>'.$u->username.'</td>
			<td>';
		unless ($workingTagId eq $tag->getId) {
			$output .= '<a href="'.$session->url->page("op=setWorkingVersionTag;tagId=".$tag->getId).'">'.$setTag.'</a> | ';
		}
		$output .='
			<a href="'.$session->url->page("op=commitVersionTag;tagId=".$tag->getId).'" onclick="return confirm(\''.$commitPrompt.'\');">'.$commit.'</a></td></tr>';
	}
	$output .= '</table>';
	return $ac->render($output);
}


#-------------------------------------------------------------------

=head2 www_manageRevisionsInTag ( session )

Displays a list of the revsions associated with this tag.

Optionally performs an action related to the revisions in this version
tag, such as purging or moving to another version tag.

=head3 session

A reference to the current session.

=cut

sub www_manageRevisionsInTag {
    my $session = shift;
    my $tagId   = $session->form->get("tagId");
    my $tag     = WebGUI::VersionTag->new($session, $tagId);
    return www_manageVersions( $session ) unless $tag;
    
    ### Permissions check
    # This screen is also used to approve/deny the tag, so check that first
    if ( !canApproveVersionTag( $session, $tag ) && !canViewVersionTag( $session, $tag ) {
        return $session->privilege->insufficient;
    }

    my $ac      = WebGUI::AdminConsole->new($session,"versions");
    my $i18n    = WebGUI::International->new($session,"VersionTag");
    $ac->addSubmenuItem($session->url->page('op=editVersionTag'), $i18n->get("add a version tag"));
    $ac->addSubmenuItem($session->url->page('op=manageCommittedVersions'), $i18n->get("manage committed versions")) if canView($session);
    $ac->addSubmenuItem($session->url->page('op=manageVersions'), $i18n->get("manage versions"));

    # Process any actions
    if ( $session->form->get('action') eq "purge" ) {
        # Purge these revisions
        my @assetInfo       = $session->form->get('assetInfo'); 
        for my $assetInfo ( @assetInfo ) {
            ( my $assetId, my $revisionDate ) = split ":", $assetInfo;
            my $asset = WebGUI::Asset->new( $session, $assetId, undef, $revisionDate );
            $asset->purgeRevision;
        }

        # If no revisions remain, delete the version tag
        if ( $tag->getRevisionCount <= 0 ) {
            $tag->delete;
            return www_manageVersions( $session );
        }
    }
    elsif ( $session->form->get('action') eq "move" ) {
        # Get the new version tag
        my $moveToTagId = $session->form->get('moveToTagId');
        my $moveToTag;
        if ( $moveToTagId eq "new" ) {
            # Create a copy of the old version tag
            $moveToTag      = WebGUI::VersionTag->create( $session, $tag->get );
            # But update the name
            $moveToTag->set( { "name" => $tag->get('name') . ' ( copy )' } );
        }
        else {
            $moveToTag      = WebGUI::VersionTag->new( $session, $moveToTagId );
        }
        
        # Move these revisions
        my @assetInfo       = $session->form->get('assetInfo'); 
        for my $assetInfo ( @assetInfo ) {
            ( my $assetId, my $revisionDate ) = split ":", $assetInfo;
            my $asset = WebGUI::Asset->new( $session, $assetId, undef, $revisionDate );
            $asset->setVersionTag( $moveToTag->getId );
        }

        # If no revisions remain, delete the version tag
        if ( $tag->getRevisionCount <= 0 ) {
            $tag->delete;
            return www_manageVersions( $session );
        }
    }

    my $output = "";
    # FIXME: Do we really need the workflowInstanceId? It's a property of the VersionTag...
    # Then we wouldn't need to click the inbox message, if we used canApproveVersionTag we'd only
    # need to have permission to approve in order to see the right form.
    if ($session->form->param("workflowInstanceId")) {
            my $instance = WebGUI::Workflow::Instance->new($session, $session->form->param("workflowInstanceId"));
            if (defined $instance) {
                    my $form = WebGUI::HTMLForm->new($session);
                    $form->submit;
                    $form->hidden(
                            name=>"tagId",
                            value=>$tagId
                            );
                    $form->hidden(
                            name=>"op",
                            value=>"approveVersionTag"
                            );
                    $form->selectBox(
                            name=>"status",
                            defaultValue=>"approve",
                            label=>$i18n->get("approve/deny"),
                            hoverHelp=>$i18n->get("approve/deny help"),
                            options=>{
                                    approve=>$i18n->get("approve"),
                                    deny=>$i18n->get("deny")
                                    },
                            );
                    $form->textarea(
                            name=>"comments",
                            label=>$i18n->get("comments"),
                            hoverHelp=>$i18n->get("comments help")
                            );
                    $form->submit;
                    $output .= $form->print;
            }
    }
    if ($tag->get("comments")) {
            my $comments = $tag->get("comments");
            $comments =~ s/\n/<br \/>/g;
            $output .= $comments;
    }
    
    # The options for tags to move to
    tie my %moveToTagOptions, 'Tie::IxHash', (
        "new"       => $i18n->get( "manageRevisionsInTag moveTo new" ),
        ( getVersionTagOptions( $session ) ),
    );

    # Output the revisions
    $output 
        .= WebGUI::Form::formHeader( $session, {} )
        . WebGUI::Form::hidden( $session, { name => 'op', value=> 'manageRevisionsInTag' } )
        . WebGUI::Form::hidden( $session, { name => 'tagId', value => $tag->getId } )
        . '<table width="100%" class="content">'
        . '<tr>'
        . '<td colspan="5">'
        . $i18n->get("manageRevisionsInTag with selected")
        . '<button name="action" value="purge" class="red">' . $i18n->get('manageRevisionsInTag purge') . '</button>'
        . '<button name="action" value="move">' . $i18n->get("manageRevisionsInTag move") . '</button>'
        . WebGUI::Form::SelectBox( $session, {
            name        => 'moveToTagId',
            options     => \%moveToTagOptions,
        } )
        . '</td>'
        . '</tr>'
        . '<tr>'
        . '<th></th>'
        . '<th>'.$i18n->get(99,"Asset").'</th>'
        . '<th>'.$i18n->get("type","Asset").'</th>'
        . '<th>'.$i18n->get("revision date","Asset").'</th>'
        . '<th>'.$i18n->get("revised by","Asset").'</th>'
        . '</tr> '
        ;
    my $p = WebGUI::Paginator->new($session,$session->url->page("op=manageRevisionsInTag;tagId=".$tag->getId));
    $p->setDataByQuery("select assetData.revisionDate, users.username, asset.assetId, asset.className from assetData 
            left join asset on assetData.assetId=asset.assetId left join users on assetData.revisedBy=users.userId
            where assetData.tagId=?",undef, undef, [$tag->getId]);
    foreach my $row (@{$p->getPageData}) {
            my ($date,$by,$id, $class) = ($row->{revisionDate}, $row->{username}, $row->{assetId}, $row->{className});
            my $asset = WebGUI::Asset->new($session,$id,$class,$date);
            # A checkbox for delete and move actions
            my $checkbox    = WebGUI::Form::checkbox( $session, {
                name        => 'assetInfo',
                value       => join( ":", $id, $date ),
            });
            $output .= '<tr><td>'
                    . $checkbox
                    .$session->icon->view("func=view;revision=".$date, $asset->get("url"))
                    .'</td>
                    <td>'.$asset->getTitle.'</td>
                    <td><img src="'.$asset->getIcon(1).'" alt="'.$asset->getName.'" />'.$asset->getName.'</td>
                    <td>'.$session->datetime->epochToHuman($date).'</td>
                    <td>'.$by.'</td></tr>';
    }
    $output .= '</table>'.$p->getBarSimple.WebGUI::Form::formFooter( $session );
    $tag = $session->db->getRow("assetVersionTag","tagId",$tag->getId);
    return $ac->render($output,$i18n->get("revisions in tag").": ".$tag->{name});
}


#-------------------------------------------------------------------

=head2 www_rollbackVersionTag ( session )

Deletes a version tag and all asset revisions attached to it.

=head3 session

A reference to the current session.

=cut

sub www_rollbackVersionTag {
	my $session = shift;
	return $session->privilege->adminOnly() unless canView($session);
	my $tagId = $session->form->process("tagId");
	return $session->privilege->vitalComponent() if ($tagId eq "pbversion0000000000001");
	if ($tagId) {
		my $tag = WebGUI::VersionTag->new($session, $tagId);
		$tag->rollback if defined $tag;
	}
	if ($session->form->process("proceed") eq "manageCommittedVersions") {
		return www_manageCommittedVersions($session);
	}
	return www_manageVersions($session);
}



#-------------------------------------------------------------------

=head2 www_setWorkingVersionTag ( session )

Sets the current user's working version tag.

=head3 session

A reference to the current session.

=cut

sub www_setWorkingVersionTag {
	my $session = shift;
	my $tag = WebGUI::VersionTag->new($session, $session->form->process("tagId"));
	if (defined $tag && $session->user->isInGroup($tag->get("groupToUse"))) {
		$tag->setWorking();
	}
	if ($session->form->param("backToSite")) {
		return undef;
	}
	return www_manageVersions($session);
}



1;

