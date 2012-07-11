package WebGUI::Operation::VersionTag;

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
use WebGUI::Paginator;
use WebGUI::AdminConsole;
use WebGUI::International;
use WebGUI::VersionTag;
use WebGUI::HTMLForm;
use WebGUI::Paginator;
use WebGUI::Fork;
use Monkey::Patch;
use JSON;

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
    return 0 unless $instance;
    my $activity    = $instance->getNextActivity;
    return 0 unless $activity;
    
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

#----------------------------------------------------------------------------

=head2 rollbackInFork ($process, $tagId)

WebGUI::Fork method called by www_rollbackVersionTag

=cut

sub rollbackInFork {
    my ( $process, $tagId ) = @_;
    my $session = $process->session;
    my $tag = WebGUI::VersionTag->new( $session, $tagId );
    my %status = (
        current => 0,
        total    => $process->session->db->quickScalar( 'SELECT count(*) FROM assetData WHERE tagId = ?', [$tagId] ),
        message  => '',
    );
    my $update = sub {
        $process->update( sub { JSON::encode_json( \%status ) } );
    };
    my $patch = Monkey::Patch::patch_class(
        'WebGUI::Asset',
        'purgeRevision',
        sub {
            my $purgeRevision = shift;
            my $self          = shift;
            $self->$purgeRevision(@_);
            $status{current}++;
            $update->();
        }
    );
    $update->();
    $tag->rollback( {
            outputSub => sub {
                $status{message} = shift;
                $update->();
            }
        }
    );

    # need to get at least one of these in for the degenerate case of no
    # revisions in tag
    $update->();
} ## end sub rollbackInFork

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
        unless canApproveVersionTag( $session, $tag ) && $session->form->validToken;
    
    my $instance    = $tag->getWorkflowInstance;
    my $activity    = $instance->getNextActivity;

    my $approve     = $session->form->process( "status", "selectBox" ) eq "approve";
    if ( $approve ) { 
        $activity->setApproved( $instance );
    }   
    else {
        $activity->setDenied( $instance );
    }   

    $tag->set( { 
        comments    => $session->form->process("comments", "textarea"),
    }); 

    # If we can't view the version tag after this, show a different message
    if ( !canViewVersionTag( $session, $tag ) ) { 
        my $i18n    = WebGUI::International->new( $session, "VersionTag" ); 
        return $session->style->userStyle( 
            sprintf $i18n->get( 'approveVersionTag message' ), 
                ( $approve ? $i18n->get( "approved" ) : $i18n->get( "denied" ) ),
                $session->url->getBackToSiteURL,
        );  
    }   
    else { 
        return www_manageVersions($session);
    }   
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
    return $session->session->privilege->insufficient() unless canView($session) && $session->form->validToken;
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
    
    my $i18n    = WebGUI::International->new($session, "VersionTag");
    # Build the page
    my $output  = '';

    # Commit comments form
    my $f = WebGUI::HTMLForm->new($session);
    $f->submit;
    $f->readOnly(
        label     => $i18n->get("version tag name"),
        hoverHelp => $i18n->get("version tag name description commit"),
        value     => $tag->get("name")
    );
    $f->hidden(
        name  =>"tagId",
        value =>$session->form->param("tagId")
    );
    $f->hidden(
        name  =>"op",
        value =>"commitVersionTagConfirm"
    );
    $f->textarea(
        name      => "comments",
        label     => $i18n->get("comments"),
        hoverHelp => $i18n->get("comments description commit")
    );
    $f->dateTime(
        name      => "startTime",
        label     => $i18n->get("startTime label"),
        hoverHelp => $i18n->get("startTime hoverHelp")
    );
    $f->dateTime(
        name      => "endTime",
        label     => $i18n->get("endTime label"),
        value     => WebGUI::DateTime->new($session,'2036-01-01 00:00:00')->epoch,
        hoverHelp => $i18n->get("endTime hoverHelp")
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
        SELECT assetData.revisionDate, assetData.revisedBy, asset.assetId, asset.className 
        FROM assetData 
        LEFT JOIN asset ON assetData.assetId = asset.assetId
        WHERE assetData.tagId=? },
        undef, 
        undef, 
        [$tag->getId]
    );

    foreach my $row ( @{$p->getPageData} ) {
        my ( $date, $byUserId, $id, $class) = @{ $row }{ qw( revisionDate revisedBy assetId className ) };
        my $asset = WebGUI::Asset->new($session, $id, $class, $date);
        my $byUser = WebGUI::User->new( $session, $byUserId );
        $output 
            .= '<tr><td>'
            .$session->icon->view("func=view;revision=".$date, $asset->get("url"))
            .'</td>
            <td>'.$asset->getTitle.'</td>
            <td><img src="'.$asset->getIcon(1).'" alt="'.$asset->getName.'" />'.$asset->getName.'</td>
            <td>'.$session->datetime->epochToHuman($date).'</td>
            <td>'.$byUser->get('username').'</td></tr>';
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
		if (defined $tag && $session->user->isInGroup($tag->get("groupToUse")) && $session->form->validToken) {
			my $i18n = WebGUI::International->new($session, "VersionTag");
			
            my $startTime = WebGUI::DateTime->new($session,$session->form->process("startTime","dateTime"))->toDatabase;
            my $endTime   = WebGUI::DateTime->new($session,$session->form->process("endTime","dateTime"))->toDatabase;
            
            $tag->set({
                comments  => $session->form->process("comments", "textarea"),
                startTime => $startTime,
                endTime   => $endTime
            });
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
                <li><a href="'.$session->url->page().'">'.$i18n->get("back to site").'</a></li>
				</ul>'	
				);
		}
	}
	return www_manageVersions($session);	
}

#-------------------------------------------------------------------

=head2 www_leaveVersionTag ( session )

Clears the current working version tag, and returns the user to www_manageVersions.

=head3 session

A reference to the current session.

=cut

sub www_leaveVersionTag {
    my $session = shift;
	
	my $tag = $session->scratch()->get(q{versionTag});
    WebGUI::VersionTag->getWorking($session)->leaveTag if $tag;
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
        my $sth = $session->db->read("select tagId,name from assetVersionTag where isCommitted=0 and isLocked=1");
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
    my ($icon, $url, $datetime, $user) = $session->quick(qw(icon url datetime user));
	$ac->addSubmenuItem($url->page('op=editVersionTag'), $i18n->get("add a version tag"));
	$ac->addSubmenuItem($url->page('op=managePendingVersions'), $i18n->get("manage pending versions"));
	$ac->addSubmenuItem($url->page('op=manageCommittedVersions'), $i18n->get("manage committed versions"));
	my ($tag,$workingTagId) = $session->db->quickArray("select name,tagId from assetVersionTag where tagId=?",[$session->scratch->get("versionTag")]);
	$tag ||= "None";
	my $rollback = $i18n->get("rollback");
	my $commit = $i18n->get("commit");
	my $setTag = $i18n->get("set tag");
    my $leave = ($workingTagId eq "") ? "" : '<a href="'.$url->page('op=leaveVersionTag').'">['.$i18n->get("leave this tag").']</a>';
	my $rollbackPrompt = $i18n->get("rollback version tag confirm");
	my $commitPrompt = $i18n->get("commit version tag confirm");
	my $output = '<p>'.$i18n->get("current tag is called").': <b>'.$tag.'</b>. '.$leave.'</p><table width="100%" class="content">
	<tr><th></th><th>'.$i18n->get("version tag name").'</th><th>'.$i18n->get("created on").'</th><th>'.$i18n->get("created by").'</th><th></th></tr> ';
	foreach my $tag (@{WebGUI::VersionTag->getOpenTags($session)}) {	
		next unless ($user->isInGroup($tag->get("groupToUse")));
		my $u = WebGUI::User->new($session,$tag->get("createdBy"));
		$output .= '<tr>
			<td>';
        $output .= $icon->delete("op=rollbackVersionTag;tagId=".$tag->getId,undef,$rollbackPrompt);
        $output .= $icon->edit("op=editVersionTag;tagId=".$tag->getId)
			.'</td>
			<td><a href="'.$url->page("op=manageRevisionsInTag;tagId=".$tag->getId).'">'.$tag->get("name").'</a></td>
			<td>'.$datetime->epochToHuman($tag->get("creationDate")).'</td>
			<td>'.$u->username.'</td>
			<td>';
		unless ($workingTagId eq $tag->getId) {
			$output .= '<a href="'.$url->page("op=setWorkingVersionTag;tagId=".$tag->getId).'">'.$setTag.'</a> | ';
		}
		$output .='
			<a href="'.$url->page("op=commitVersionTag;tagId=".$tag->getId).'" onclick="return confirm(\''.$commitPrompt.'\');">'.$commit.'</a></td></tr>';
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
    
    my $i18n    = WebGUI::International->new($session,"VersionTag");

    ### Permissions check
    # This screen is also used to approve/deny the tag, so check that first
    if ( !canApproveVersionTag( $session, $tag ) && !canViewVersionTag( $session, $tag ) ) {
        if ( $session->user->isVisitor ) {
            return $session->privilege->noAccess;
        }
        else {
            # Return a nice error message, since people are getting confused when they try 
            # to approve a tag that's already approved
            my $html    = '<h1>%s</h1>' . "\n"
                        . '<p>%s</p>' . "\n"
                        . q{<p><a href="%s">%s</a></p>} . "\n"
                        ;

            return $session->style->userStyle(
                sprintf $html, 
                    $i18n->get( "error permission www_manageRevisionsInTag title" ),
                    $i18n->get( "error permission www_manageRevisionsInTag body" ),
                    $session->url->getSiteURL,
                    $i18n->get( "back to site" ),
                );
        }
    }

    my $ac      = WebGUI::AdminConsole->new($session,"versions");
    $ac->addSubmenuItem($session->url->page('op=editVersionTag'), $i18n->get("add a version tag"));
    $ac->addSubmenuItem($session->url->page('op=manageCommittedVersions'), $i18n->get("manage committed versions")) if canView($session);
    $ac->addSubmenuItem($session->url->page('op=manageVersions'), $i18n->get("manage versions"));
    $ac->addSubmenuItem($session->url->page('op=managePendingVersions'), $i18n->get("manage pending versions")) if canView($session);

    # Process any actions
    my $action     = lc $session->form->get('action');
    my $form       = $session->form;
    my $validToken = $session->form->validToken;
    if ( $form->get('purge') && $validToken) {
        # Purge these revisions
        my @assetInfo       = $session->form->get('assetInfo'); 
        for my $assetInfo ( @assetInfo ) {
            ( my $assetId, my $revisionDate ) = split ":", $assetInfo;
            my $asset = WebGUI::Asset->new( $session, $assetId, undef, $revisionDate );
            $asset->purgeRevision;
        }

        # If no revisions remain, delete the version tag
        if ( $tag->getRevisionCount <= 0 ) {
            $tag->rollback;
            return www_manageVersions( $session );
        }
    }
    elsif ( $form->get('moveto') && $validToken) {
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
            $tag->rollback;
            return www_manageVersions( $session );
        }
    }
    elsif ( $form->get('update') && $validToken) {
        my $startTime = WebGUI::DateTime->new($session,$session->form->process("startTime","dateTime"))->toDatabase;
        my $endTime   = WebGUI::DateTime->new($session,$session->form->process("endTime","dateTime"))->toDatabase;
        
        $tag->set({
            startTime => $startTime,
            endTime   => $endTime
        });
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
    
    #Add the ability to change the start/end date
     
    
    # The options for tags to move to
    tie my %moveToTagOptions, 'Tie::IxHash', (
        "new"       => $i18n->get( "manageRevisionsInTag moveTo new" ),
        ( getVersionTagOptions( $session ) ),
    );

    ##Setup valid times for the datetime range form
    my $filterStartTime = defined $tag->get('startTime') ? $tag->get('startTime') : '1970-01-17 05:00:00';
    my $filterEndTime   = defined $tag->get('endTime')   ? $tag->get('endTime')   : time();

    # Output the revisions
    ### FIXME: Users who only pass canApproveVersionTag() and not canViewVersionTag() should
    # probably not be allowed to see the Actions or modify the Start and End dates
    $output 
        .= WebGUI::Form::formHeader( $session, {} )
        . WebGUI::Form::hidden( $session, { name => 'op', value=> 'manageRevisionsInTag' } )
        . WebGUI::Form::hidden( $session, { name => 'tagId', value => $tag->getId } )
        . '<table width="100%" class="content">'
        . '<tr>'
        . '<td colspan="5">'
        . $i18n->get('startTime label').':&nbsp;'
        . WebGUI::Form::dateTime($session, {
            name  =>"startTime",
            value => WebGUI::DateTime->new($session,$filterStartTime)->epoch,
        })
        . '<br />'.$i18n->get('endTime label').':&nbsp;'
        . WebGUI::Form::dateTime($session,{
            name  =>"endTime",
            value => WebGUI::DateTime->new($session,$filterEndTime)->epoch,
        })
        . '<br />'
        . '<input type="submit" name="update" value="'. $i18n->get('manageRevisionsInTag update') . '" />'
        . '</td>'
        . '</tr>'
        . '<tr><td colspan="5">&nbsp;</td></tr>'
        . '<tr>'
        . '<td colspan="5">'
        . $i18n->get("manageRevisionsInTag with selected")
        . '<input type="submit" name="moveto" value="'. $i18n->get("manageRevisionsInTag move")  . '" />'
        . WebGUI::Form::SelectBox( $session, {
            name        => 'moveToTagId',
            options     => \%moveToTagOptions,
        } )
        . '&nbsp;<input type="submit" name="purge" value="'. $i18n->get('manageRevisionsInTag purge') . '" class="red" />'
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
    $p->setDataByQuery("select assetData.revisionDate, assetData.revisedBy, asset.assetId, asset.className from assetData 
            left join asset on assetData.assetId=asset.assetId
            where assetData.tagId=?",undef, undef, [$tag->getId]);
    foreach my $row (@{$p->getPageData}) {
            my ($date,$byUserId,$id, $class) = ($row->{revisionDate}, $row->{revisedBy}, $row->{assetId}, $row->{className});
            my $byUser  = WebGUI::User->new( $session, $byUserId );
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
                    <td>'.$byUser->username.'</td></tr>';
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

    my $process = WebGUI::Fork->start(
        $session, 'WebGUI::Operation::VersionTag', 'rollbackInFork', $tagId
    );

    my $i18n = WebGUI::International->new($session, 'VersionTag');
	my $method = $session->form->process("proceed");
    $method    = $method eq "manageCommittedVersions" ? $method : 'manageVersions';
    my $redir = WebGUI::Asset->getDefault($session)->getUrl("op=$method");
    $session->http->setRedirect(
        $session->url->page(
            $process->contentPairs(
                'ProgressBar', {
                    icon    => 'versions',
                    title   => $i18n->get('rollback version tag'),
                    proceed => $redir,
                }
            )
        )
    );
    return 'redirect';
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

