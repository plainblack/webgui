package WebGUI::Operation::Group;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use Exporter;
use strict;
use Tie::CPHash;
use WebGUI::DateTime;
use WebGUI::Group;
use WebGUI::Grouping;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Mail;
use WebGUI::Operation::Shared;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Utility;

our @ISA    = qw(Exporter);
our @EXPORT = qw(&www_manageUsersInGroup &www_deleteGroup &www_deleteGroupConfirm &www_editGroup
&www_editGroupSave &www_listGroups &www_emailGroup &www_emailGroupSend &www_manageGroupsInGroup
&www_addGroupsToGroupSave &www_deleteGroupGrouping);

#-------------------------------------------------------------------
sub _submenu {
	tie my %menu, 'Tie::IxHash';
	$menu{ WebGUI::URL::page( 'op=editGroup&gid=new' ) } = WebGUI::International::get( 90 );
	unless ( $session{ form }{ op } eq 'listGroups'
		or $session{ form }{ gid } eq 'new'
		or $session{ form }{ op }  eq 'deleteGroupConfirm' )
	{
		$menu{ WebGUI::URL::page( 'op=editGroup&gid='           . $session{ form }{ gid } ) } = WebGUI::International::get( 753 );
		$menu{ WebGUI::URL::page( 'op=manageUsersInGroup&gid='  . $session{ form }{ gid } ) } = WebGUI::International::get( 754 );
		$menu{ WebGUI::URL::page( 'op=manageGroupsInGroup&gid=' . $session{ form }{ gid } ) } = WebGUI::International::get( 807 );
		$menu{ WebGUI::URL::page( 'op=emailGroup&gid='          . $session{ form }{ gid } ) } = WebGUI::International::get( 808 );
		$menu{ WebGUI::URL::page( 'op=deleteGroup&gid='         . $session{ form }{ gid } ) } = WebGUI::International::get( 806 );
	}
	$menu{ WebGUI::URL::page( 'op=listGroups' ) } = WebGUI::International::get( 756 );
	return menuWrapper( $_[ 0 ], \%menu );
}

#-------------------------------------------------------------------
sub www_addGroupsToGroupSave {
	return WebGUI::Privilege::adminOnly() unless WebGUI::Privilege::isInGroup( 3 );
	my @groups = $session{ cgi }->param( 'groups' );
	WebGUI::Grouping::addGroupsToGroups( \@groups, [ $session{ form }{ gid } ] );
	return www_manageGroupsInGroup();
}

#-------------------------------------------------------------------
sub www_deleteGroup {
	return WebGUI::Privilege::adminOnly() unless WebGUI::Privilege::isInGroup( 3 );
	return WebGUI::Privilege::vitalComponent() if $session{ form }{ gid } < 26;
	my $output = helpIcon( 15 )
		. '<h1>' . WebGUI::International::get( 42 ) . '</h1>'
		. WebGUI::International::get( 86 ) . '<p>'
		. '<div align="center"><a href="' . WebGUI::URL::page( 'op=deleteGroupConfirm&gid=' . $session{ form }{ gid } )
		. '">' . WebGUI::International::get( 44 ) . '</a>'
		. '&nbsp;&nbsp;&nbsp;&nbsp;<a href="' . WebGUI::URL::page( 'op=listGroups' ) . '">'
		. WebGUI::International::get( 45 ) . '</a></div>';
	return _submenu( $output );
}

#-------------------------------------------------------------------
sub www_deleteGroupConfirm {
	return WebGUI::Privilege::adminOnly() unless WebGUI::Privilege::isInGroup( 3 );
	return WebGUI::Privilege::vitalComponent() if $session{ form }{ gid } < 26;
	my $g = WebGUI::Group->new( $session{ form }{ gid } );
	$g->delete;
	return www_listGroups();
}

#-------------------------------------------------------------------
sub www_deleteGroupGrouping {
	return WebGUI::Privilege::adminOnly() unless WebGUI::Privilege::isInGroup( 3 );
	WebGUI::Grouping::deleteGroupsFromGroups( [ $session{ form }{ delete } ], [ $session{ form }{ gid } ] );
	return www_manageGroupsInGroup();
}

#-------------------------------------------------------------------
sub www_editGroup {
	return WebGUI::Privilege::adminOnly() unless WebGUI::Privilege::isInGroup( 3 );

	my $g = ( $session{ form }{ gid } eq 'new' )
		? WebGUI::Group->new( '' )
		: WebGUI::Group->new( $session{ form }{ gid } );

	my $f = WebGUI::HTMLForm->new;
	$f->hidden( 'op',  'editGroupSave' );
	$f->hidden( 'gid', $session{ form }{ gid } );
	$f->readOnly( $g->groupId, WebGUI::International::get( 379 ) );
	$f->text( 'groupName', WebGUI::International::get( 84 ), $g->name );
	$f->textarea( 'description', WebGUI::International::get( 85 ), $g->description );
	$f->interval( 'expireOffset', WebGUI::International::get( 367 ), WebGUI::DateTime::secondsToInterval( $g->expireOffset ) );
	$f->yesNo(
		-name  => 'expireNotify',
		-value => $g->expireNotify,
		-label => WebGUI::International::get( 865 )
	);
	$f->integer(
		-name  => 'expireNotifyOffset',
		-value => $g->expireNotifyOffset,
		-label => WebGUI::International::get( 864 )
	);
	$f->textarea(
		-name  => 'expireNotifyMessage',
		-value => $g->expireNotifyMessage,
		-label => WebGUI::International::get( 866 )
	);
	$f->integer(
		-name  => 'deleteOffset',
		-value => $g->deleteOffset,
		-label => WebGUI::International::get( 863 )
	);
	$f->integer( 'karmaThreshold', WebGUI::International::get( 538 ), $g->karmaThreshold ) if $session{ setting }{ useKarma };
	$f->text(
		-name  => 'ipFilter',
		-value => $g->ipFilter,
		-label => WebGUI::International::get( 857 )
	);
	$f->submit;

	return _submenu( helpIcon( 17 ) . '<h1>' . WebGUI::International::get( 87 ) . '</h1>' . $f->print );
}

#-------------------------------------------------------------------
sub www_editGroupSave {
	return WebGUI::Privilege::adminOnly() unless WebGUI::Privilege::isInGroup( 3 );
	my $g = WebGUI::Group->new( $session{ form }{ gid } );
	$g->description( $session{ form }{ description } );
	$g->name( $session{ form }{ groupName } );
	$g->expireOffset( WebGUI::DateTime::intervalToSeconds( $session{ form }{ expireOffset_interval }, $session{ form }{ expireOffset_units } ) );
	$g->karmaThreshold( $session{ form }{ karmaThreshold } );
	$g->ipFilter( $session{ form }{ ipFilter } );
	$g->expireNotify( $session{ form }{ expireNotify } );
	$g->expireNotifyOffset( $session{ form }{ expireNotifyOffset } );
	$g->expireNotifyMessage( $session{ form }{ expireNotifyMessage } );
	$g->deleteOffset( $session{ form }{ deleteOffset } );
	return www_listGroups();
}

#-------------------------------------------------------------------
sub www_emailGroup {
	return WebGUI::Privilege::adminOnly() unless WebGUI::Privilege::isInGroup( 3 );

	my $f = WebGUI::HTMLForm->new;
	$f->hidden( 'op', 'emailGroupSend' );
	$f->hidden( 'gid', $session{ form }{ gid } );
	$f->email(
		-name  => 'from',
		-value => $session{ setting }{ companyEmail },
		-label => WebGUI::International::get( 811 )
	);
	$f->text(
		-name  => 'subject',
		-label => WebGUI::International::get( 229 )
	);
	$f->textarea(
		-name  => 'message',
		-label => WebGUI::International::get( 230 ),
		-rows  => ( 5 + $session{ setting }{ textAreaRows } )
	);
	$f->submit( WebGUI::International::get( 810 ) );

	return _submenu( '<h1>' . WebGUI::International::get( 809 ) . '</h1>' . $f->print );
}

#-------------------------------------------------------------------
sub www_emailGroupSend {
	return WebGUI::Privilege::adminOnly() unless WebGUI::Privilege::isInGroup( 3 );

	my $sth = WebGUI::SQL->read( "select b.fieldData from groupings a left join userProfileData b 
		on a.userId=b.userId and b.fieldName='email' where a.groupId=$session{form}{gid}" );
	while ( my ( $email ) = $sth->array ) {
		next if $email eq '';
		WebGUI::Mail::send( $email, $session{ form }{ subject }, $session{ form }{ message }, '', $session{ form }{ from } );
	}
	$sth->finish;
	return _submenu( WebGUI::International::get( 812 ) );
}

#-------------------------------------------------------------------
sub www_listGroups {
	return WebGUI::Privilege::adminOnly() unless WebGUI::Privilege::isInGroup( 3 );

	my $sth = WebGUI::SQL->read( 'select groupId,groupName,description from groups 
		where groupId<>1 and groupId<>2 and groupId<>7 order by groupName' );

	my @row;
	while ( my @data = $sth->array ) {
		my ( $userCount ) = WebGUI::SQL->quickArray( "select count(*) from groupings where groupId=$data[0]" );
		push @row, '<tr>'
			. '<td valign="top" class="tableData"><a href="'
			. WebGUI::URL::page( 'op=editGroup&gid=' . $data[ 0 ] ) . '">' . $data[ 1 ] . '</td>'
			. '<td valign="top" class="tableData">' . $data[ 2 ] . '</td>'
			. '<td valign="top" class="tableData">' . $userCount . '</td></tr>'
			. '</tr>';
	}
	$sth->finish;

	my $p = WebGUI::Paginator->new( WebGUI::URL::page( 'op=listGroups' ), \@row );

	my $output = helpIcon( 10 )
		. '<h1>' . WebGUI::International::get( 89 ) . '</h1>'
		. '<table border=1 cellpadding=5 cellspacing=0 align="center">'
		. '<tr><td class="tableHeader">' . WebGUI::International::get( 84 ) . '</td><td class="tableHeader">'
		. WebGUI::International::get( 85 ) . '</td><td class="tableHeader">'
		. WebGUI::International::get( 748 ) . '</td></tr>'
		. $p->getPage( $session{ form }{ pn } )
		. '</table>'
		. $p->getBarTraditional( $session{ form }{ pn } );
	return _submenu( $output );
}

#-------------------------------------------------------------------
sub www_manageGroupsInGroup {
	return WebGUI::Privilege::adminOnly() unless WebGUI::Privilege::isInGroup( 3 );

	my $f = WebGUI::HTMLForm->new;
	$f->hidden( 'op',  'addGroupsToGroupSave' );
	$f->hidden( 'gid', $session{ form }{ gid } );
	my $groups = WebGUI::Grouping::getGroupsInGroup( $session{ form }{ gid } );
	push @$groups, $session{ form }{ gid };
	$f->group(
		-name          => 'groups',
		-excludeGroups => $groups,
		-label         => WebGUI::International::get( 605 ),
		-size          => 5,
		-multiple      => 1
	);
	$f->submit;

	my $output = '<h1>' . WebGUI::International::get( 813 ) . '</h1><div align="center">'
		. $f->print . '</div><p/><table class="tableData" align="center">'
		. '<tr class="tableHeader"><td></td><td>' . WebGUI::International::get( 84 ) . '</td></tr>';

	my $p = WebGUI::Paginator->new( WebGUI::URL::page( 'op=manageGroupsInGroup' ) );
	$p->setDataByQuery( "select a.groupName as name,a.groupId as id from groups a 
		left join groupGroupings b on a.groupId=b.groupId 
		where b.inGroup=$session{form}{gid} order by a.groupName" );
	$groups = $p->getPageData;
	for my $group ( @$groups ) {
		$output .= '<tr><td>'
			. deleteIcon( 'op=deleteGroupGrouping&gid=' . $session{ form }{ gid } . '&delete=' . $group->{ id } )
			. '</td><td><a href="' . WebGUI::URL::page( 'op=editGroup&gid=' . $group->{ id } )
			. '">' . $group->{ name } . '</a></td></tr>';
	}
	$output .= '</table>' . $p->getBarTraditional;
	return _submenu( $output );
}

#-------------------------------------------------------------------
sub www_manageUsersInGroup {
	return WebGUI::Privilege::adminOnly() unless WebGUI::Privilege::isInGroup( 3 );

	my $output = '<h1>' . WebGUI::International::get( 88 ) . '</h1>';
		. '<table align="center" border="1" cellpadding="2" cellspacing="0"><tr><td class="tableHeader">&nbsp;</td><td class="tableHeader">'
		. WebGUI::International::get( 50 ) . '</td><td class="tableHeader">'
		. WebGUI::International::get( 369 ) . '</td></tr>';

	my $sth = WebGUI::SQL->read( "select users.username,users.userId,groupings.expireDate
                from groupings,users where groupings.groupId=$session{form}{gid} and groupings.userId=users.userId
                order by users.username" );

	tie my %hash, 'Tie::CPHash';
	while ( %hash = $sth->hash ) {
		$output .= '<tr><td>'
			. deleteIcon( 'op=deleteGrouping&uid=' . $hash{ userId } . '&gid=' . $session{ form }{ gid } )
			. editIcon( 'op=editGrouping&uid=' . $hash{ userId } . '&gid=' . $session{ form }{ gid } )
			. '</td>'
			. '<td class="tableData"><a href="' . WebGUI::URL::page( 'op=editUser&uid=' . $hash{ userId } ) . '">'
			. $hash{ username } . '</a></td>'
			. '<td class="tableData">' . epochToHuman( $hash{ expireDate }, '%z' ) . '</td></tr>';
	}
	$sth->finish;
	$output .= '</table>';
	return _submenu( $output );
}


1;

