package WebGUI::Asset::Wobject::InOutBoard;


use strict;
use WebGUI::HTMLForm;
use WebGUI::International;
use WebGUI::Paginator;
use WebGUI::SQL;

use WebGUI::Definition::Asset;
extends 'WebGUI::Asset::Wobject';
aspect tableName => 'InOutBoard';
aspect assetName => ['assetName', 'Asset_MapPoint'];
aspect icon      => 'iob.gif';
property statusList => (
                tab          => 'properties',
                fieldType    => "textarea",
                builder      => '_statusList_builder',
                lazy         => 1,
                label        => [1, 'Asset_InOutBoard'],
                hoverHelp    => ['1 description', 'Asset_InOutBoard'],
                subtext      => [2, 'Asset_InOutBoard'],
         );
sub _statusList_builder {
    my $self = shift;
    my $session = $self->session;
    my $i18n    = WebGUI::International->new($session, 'Asset_InOutBoard');
    return $i18n->get(10)."\n".$i18n->get(11)."\n";
}
property reportViewerGroup => (
                tab          => 'security',
                default      => 3,
                fieldType    => "group",
                label        => [3, 'Asset_InOutBoard'],
                hoverHelp    => ["3 description", 'Asset_InOutBoard'],
         );
property inOutGroup => (
                tab          => 'security',
                default      => 2,
                fieldType    => "group",
                label        => ['inOutGroup', 'Asset_InOutBoard'],
                hoverHelp    => ['inOutGroup description', 'Asset_InOutBoard'],
         );
property inOutTemplateId => (
                tab          => 'display',
                fieldType    => "template",
                namespace    => "InOutBoard",
                label        => ["In Out Template", 'Asset_InOutBoard'],
                hoverHelp    => ["In Out Template description", 'Asset_InOutBoard'],
                default      => 'IOB0000000000000000001',
         );
property reportTemplateId => (
                tab          => 'display',
                fieldType    => "template",
                default      => 'IOB0000000000000000002',
                label        => [13, 'Asset_InOutBoard'],
                hoverHelp    => ["13 description", 'Asset_InOutBoard'],
                namespace    => "InOutBoard/Report"
         );
property paginateAfter => (
                tab          => 'display',
                fieldType    => "integer",
                default      => 50,
                label        => [12, 'Asset_InOutBoard'],
                hoverHelp    => ['12 description', 'Asset_InOutBoard'],
         );

#See line 285 if you wish to change the users visible in the delegate select list

#-------------------------------------------------------------------

sub _defineUsername {
	my $data = shift;
	if ($data->{firstName} ne "" && $data->{lastName} ne "") {
	  return join ' ', $data->{firstName}, $data->{lastName};
	}
	else {
	  return $data->{username};
	}
}

#-------------------------------------------------------------------

sub _fetchNames {
	my $self = shift;
	my @userIds = @_;
	my %nameHash;
	my $sql = "SELECT users.username, users.userId, firstName, lastName
FROM users
LEFT JOIN userProfileData ON users.userId=userProfileData.userId
WHERE users.userId=?";
	my $sth = $self->session->db->prepare($sql);
	foreach my $userId (@userIds) {
		$sth->execute([ $userId ]);
		$nameHash{ $userId } = _defineUsername($sth->hashRef);
	}
	$sth->finish;
	return %nameHash;
}

#-------------------------------------------------------------------
sub _fetchDepartments {
	my $self = shift;
	return $self->session->db->buildArray("SELECT department FROM userProfileData GROUP BY department");
}


#-------------------------------------------------------------------
sub definition {
    my $class = shift;
    my $session = shift;
    my $definition = shift;
    my $i18n = WebGUI::International->new($session,"Asset_InOutBoard");
    push(@{$definition}, {
        autoGenerateForms => 1,
        properties   => {
        }
    });
    return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
    my $self = shift;
    $self->SUPER::prepareView();
    my $template = WebGUI::Asset::Template->new($self->session, $self->inOutTemplateId);
    if (!$template) {
        WebGUI::Error::ObjectNotFound::Template->throw(
            error      => qq{Template not found},
            templateId => $self->inOutTemplateId,
            assetId    => $self->getId,
        );
    }
    $template->prepare($self->getMetaDataAsTemplateVariables);
    $self->{_viewTemplate} = $template;
}


#-------------------------------------------------------------------

=head2 purge ( )

Extend the base method to cleanup the status and statusLog tables.

=cut

sub purge {
    my $self    = shift;
    my $session = $self->session;
    $session->db->write('delete from InOutBoard_status    where assetId=?', [$self->getId]);
    $session->db->write('delete from InOutBoard_statusLog where assetId=?', [$self->getId]);
    $self->SUPER::purge(@_);
}


#-------------------------------------------------------------------

=head2 view 

Render the viewing screen, which displays In/Out status and a form to change
status.

=cut

sub view {
	my $self    = shift;
    my $session = $self->session;
	my %var;
	my $url = $self->getUrl('func=view');
	
	my $i18n = WebGUI::International->new($self->session, "Asset_InOutBoard");
	if ($session->user->isInGroup($self->reportViewerGroup)) {
        $var{'viewReportURL'}   = $self->getUrl("func=viewReport");
        $var{'viewReportLabel'} = $i18n->get('view report label');
        $var{canViewReport}     = 1;
	}
	else {
        $var{canViewReport} = 0;
    }
	
	my $statusUserId = $self->session->scratch->get("userId") || $self->session->user->userId;
	my $statusListString = $self->statusList;
	my @statusListArray = split("\n",$statusListString);
	my $statusListHashRef;
	tie %$statusListHashRef, 'Tie::IxHash';

	foreach my $status (@statusListArray) {
		chomp($status);
        next if $status eq "";
		$statusListHashRef->{$status} = $status;
	}

	#$self->session->log->warn("VIEW: userId: ".$statusUserId."\n" );
	my ($status) = $session->db->quickArray(
        "select status from InOutBoard_status where userId=? and assetId=?",
        [ $statusUserId, $self->getId]
    );

	##Find all the users for which I am a delegate
	my @users = $session->db->buildArray(
        "select userId from InOutBoard_delegates where assetId=? and delegateUserId=?",
        [ $self->getId, $session->user->userId ]
    );

	my $f = WebGUI::HTMLForm->new($session,-action=>$self->getUrl);
	if (@users) {
		my %nameHash;
		tie %nameHash, "Tie::IxHash";
		%nameHash = $self->_fetchNames(@users);
		$nameHash{""} = $i18n->get('myself');
		%nameHash = WebGUI::Utility::sortHash(%nameHash);

		$f->selectBox(
			-name=>"delegate",
			-options=>\%nameHash,
			-value=>[ $session->scratch->get("userId") ],
			-label=>$i18n->get('delegate'),
			-hoverHelp=>$i18n->get('delegate description'),
			-extras=>q|onchange="this.form.submit();"|,
		);
	}
	$f->radioList(
		-name=>"status",
		-value=>$status,
		-options=>$statusListHashRef,
		-label=>$i18n->get(5),
		-hoverHelp=>$i18n->get('5 description'),
		);
	$f->text(
		-name=>"message",
		-label=>$i18n->get(6),
		-hoverHelp=>$i18n->get('6 description'),
		);
	$f->hidden(
		-name=>"func",
		-value=>"setStatus"
		);
	$f->submit;
	
	my ($isInGroup) = $session->db->quickArray(
        "select count(*) from groupings where userId=? and groupId=?",
        [ $session->user->userId, $self->inOutGroup ]
    );
	if ($isInGroup) {
	    $var{displayForm} = 1;
	    $var{'form'} = $f->print;
	    $var{'selectDelegatesURL'} = $self->getUrl("func=selectDelegates");
	    $var{'selectDelegatesLabel'} = $i18n->get('select delegates label');
	}
	else {
        $var{displayForm} = 0;
    }
	
	my $lastDepartment = "_nothing_";
	
	my $p = WebGUI::Paginator->new($session, $url, $self->paginateAfter);
	
	my $sql = "select users.username, 
users.userId, 
firstName, 
InOutBoard_status.message, 
lastName, 
InOutBoard_status.status, 
InOutBoard_status.dateStamp, 
department, 
groupings.groupId
from users 
left join groupings on  groupings.userId=users.userId
left join InOutBoard on groupings.groupId=InOutBoard.inOutGroup
left join userProfileData on users.userId=userProfileData.userId
left join InOutBoard_status on users.userId=InOutBoard_status.userId and InOutBoard_status.assetId=?
where users.userId<>'1' and InOutBoard.inOutGroup=?
group by userId
order by department, lastName, firstName";

	$p->setDataByQuery($sql, undef, 0, [ $self->getId, $self->inOutGroup ], );
	my $rowdata = $p->getPageData();
	my @rows;
	foreach my $data (@$rowdata) {
		my %row;
		if ($lastDepartment ne $data->{department}) {
		  $row{deptHasChanged} = 1;
		  $row{'department'} = ($data->{department}||$i18n->get(7));
		  $lastDepartment = $data->{department};
		}
		else { $row{deptHasChanged} = 0; }
		
		if ($data->{firstName} ne "" && $data->{lastName} ne "") {
		  $row{'username'} = $data->{firstName}." ".$data->{lastName};
		}
		else {
		  $row{'username'} = $data->{username};
		}
		
		$row{'status'} = ($data->{status} || $i18n->get(15));
		$row{'dateStamp'} = $data->{status} ? $self->session->datetime->epochToHuman($data->{dateStamp}) : "&nbsp;";
		$row{'message'} = ($data->{message} || "&nbsp;");
		
		push (@rows, \%row);
	}
	$var{rows_loop} = \@rows;
	$var{'paginateBar'} = $p->getBarTraditional();
	$p->appendTemplateVars(\%var);
	
	return $self->processTemplate(\%var,undef,$self->{_viewTemplate});
}

#-------------------------------------------------------------------

=head2 www_selectDelegates 

Form where a user can select delegates, other users who are allowed to change
their status.

=cut

sub www_selectDelegates {
	my $self = shift;
	my %userNames = ();
	my $sth = $self->session->db->read(
		"select 
			users.username, 
			users.userId, 
			firstName,
			lastName
		from users
		left join groupings on users.userId=groupings.userId
		left join InOutBoard on groupings.groupId=InOutBoard.inOutGroup
		left join userProfileData on users.userId=userProfileData.userId
		left join InOutBoard_status on users.userId=InOutBoard_status.userId and InOutBoard_status.assetId=?
		where
			users.userId<>'1'
			and users.status='Active'
			and users.userId <> ?
			and InOutBoard.inOutGroup=?
		group by userId
		",[$self->getId, $self->session->user->userId, $self->inOutGroup]);
	while (my $data = $sth->hashRef) {
		$userNames{ $data->{userId} } = _defineUsername($data);
	}
	$sth->finish;
	my $sql = sprintf "select delegateUserId from InOutBoard_delegates where userId=%s and assetId=%s",
	                $self->session->db->quote($self->session->user->userId), $self->session->db->quote($self->getId);
	my $delegates = $self->session->db->buildArrayRef($sql);
	my $i18n = WebGUI::International->new($self->session,"Asset_InOutBoard");
        my $f = WebGUI::HTMLForm->new($self->session,-action=>$self->getUrl);
        $f->hidden(
	    -name => "func",
	    -value => "selectDelegatesEditSave"
	);
        $f->selectList(
	    -name => "delegates",
	    -label => $i18n->get('in/out status delegates'),
	    -hoverHelp => $i18n->get('in/out status delegates description','Asset_InOutBoard'),
	    -options => \%userNames,
	    -multiple => 1,        ##Multiple select
	    -size => 10,        ##Multiple select
	    -sortByValue => 1,
	    -value => $delegates,  ##My current delegates, if any
	    -subtext => $i18n->get('in/out status delegates subtext'),
	);
	$f->submit;
	my $ac = $self->getAdminConsole;
	return $ac->render($f->print,
	                   $i18n->get('select delegate'));
}

#-------------------------------------------------------------------

=head2 www_selectDelegatesEditSave 

Process the selectDeletages form.

=cut

sub www_selectDelegatesEditSave {
	my $self      = shift;
    my $session   = $self->session;
    my $db        = $session->db;
	my @delegates = $session->form->selectList("delegates");
	$db->write(
        "delete from InOutBoard_delegates where assetId=? and userId=?",
        [ $self->getId, $session->user->userId ]
    );

	foreach my $delegate (@delegates) {
		$db->write(
            "insert into InOutBoard_delegates (userId,delegateUserId,assetId) values (?,?,?)",
            [$session->user->userId, $delegate, $self->getId ],
        );
	}
	return "";
}
#-------------------------------------------------------------------

=head2 www_setStatus 

Process the form from the view method to set status for a user.

=cut

sub www_setStatus {
	my $self     = shift;
    my $session  = $self->session;
    my $db       = $session->db;
    my $delegate = $session->form->process('delegate');
	if ($delegate eq $self->session->scratch->get("userId")) {
		my $sessionUserId = $session->scratch->get("userId") || $session->user->userId;
        my $status  = $session->form->process('status');
        return $self->www_view if $status eq '';
		$session->scratch->delete("userId");
        my $message = $session->form->process('message');
		$db->write("delete from InOutBoard_status where userId=? and assetId=?", [ $sessionUserId, $self->getId ]);
		$db->write(
            "insert into InOutBoard_status (assetId,userId,status,dateStamp,message) values (?,?,?,?,?)",
            [$self->getId, $sessionUserId, $status, $session->datetime->time(), $message ], 
        );
		$db->write(
            "insert into InOutBoard_statusLog (assetId,userId,createdBy,status,dateStamp,message) values (?,?,?,?,?,?)",
            [$self->getId, $sessionUserId, $session->user->userId, $status, $session->datetime->time(), $message ], 
        );
	}
	else {
		$session->scratch->set("userId",$delegate);
	}
	return $self->www_view;
}


#-------------------------------------------------------------------

=head2 www_viewReport 

Builds a templated form for doing drill-down reports, along with displaying results from
the report.

=cut

sub www_viewReport {
	my $self = shift;
	return "" unless ($self->session->user->isInGroup($self->reportViewerGroup));
	my %var;
	my $i18n = WebGUI::International->new($self->session,'Asset_InOutBoard');
	my $f = WebGUI::HTMLForm->new($self->session,-action=>$self->getUrl, -method=>"GET");
	my %changedBy = ();
	$f->hidden(
		-name=>"func",
		-value=>"viewReport"
		);
	$f->hidden(
		-name=>"doit",
		-value=>"1"
		);
	my $startDate = $self->session->datetime->addToDate($self->session->datetime->time(),0,0,-15);
	$startDate = $self->session->form->date("startDate") if ($self->session->form->process("doit")); 
	$f->date(
		-name=>"startDate",
		-label=>$i18n->get(16),
		-hoverHelp=>$i18n->get('16 description'),
		-value=>$startDate
		);
	my $endDate = $self->session->form->date("endDate");
	$f->date(
		-name=>"endDate",
		-label=>$i18n->get(17),
		-hoverHelp=>$i18n->get('17 description'),
		-value=>$endDate
		);
    ##Make a list of available departments.  Map empty departments to the No departments label, and
    ##handle the SQL clause for searching.
	my %depHash;
	%depHash = map { $_ => $_ } 
               ($self->_fetchDepartments(), $i18n->get('all departments'));
    $depHash{''} = $i18n->get('7');
	my $defaultDepartment   =  $self->session->form->process("selectDepartment");
	my $departmentSQLclause = $defaultDepartment eq $i18n->get('all departments')
	                        ? ''
                            : $defaultDepartment eq ''
                            ? 'and userProfileData.department IS NULL'
                            : 'and userProfileData.department='.$self->session->db->quote($defaultDepartment);
	$f->selectBox(
		-name=>"selectDepartment",
		-options=>\%depHash,
		-value=>[ $defaultDepartment ],
		-label=>$i18n->get('filter departments'),
		-label=>$i18n->get('filter departments description'),
	);
	my %paginHash;
	tie %paginHash, "Tie::IxHash"; ##Because default sort order is alpha
	%paginHash = (50 => 50, 100 => 100, 300 => 300, 500 => 500, 1000 => 1000, 10_000 => 10_000,);
	my $pageReportAfter = $self->session->form->process("reportPagination") || 50;
	$f->selectBox(
		-name=>"reportPagination",
		-options=>\%paginHash,
		-value=>[ $pageReportAfter ],
		-label=>$i18n->get(14),
		-hoverHelp=>$i18n->get('14 description'),
	);
	$f->submit(-value=>$i18n->get('search','Asset'));
	$var{'reportTitleLabel'} = $i18n->get('report title');
	$var{'form'}             = $f->print;
	my $url = $self->getUrl("func=viewReport;selectDepartment=".$defaultDepartment.";reportPagination=".$pageReportAfter.";startDate=".$self->session->form->process("startDate").";endDate=".$endDate.";doit=1");
	if ($self->session->form->process("doit")) {
	  $var{showReport} = 1;
	  $endDate = $self->session->datetime->addToTime($endDate,24,0,0);
	  my $lastDepartment = "_none_";
	  my $p = WebGUI::Paginator->new($self->session,$url, $pageReportAfter);
	  
	  my $sql = "select users.username, 
users.userId, 
firstName, 
InOutBoard_statusLog.message,
lastName, 
InOutBoard_statusLog.status, 
InOutBoard_statusLog.dateStamp, 
InOutBoard_statusLog.createdBy, 
department,
groupings.groupId
from users
left join groupings on groupings.userId=users.userId
left join userProfileData on users.userId=userProfileData.userId
left join InOutBoard_statusLog on users.userId=InOutBoard_statusLog.userId and InOutBoard_statusLog.assetId=".$self->session->db->quote($self->getId())."
where users.userId<>'1' and 
 groupings.groupId=".$self->session->db->quote($self->inOutGroup)." and 
 groupings.userId=users.userId and 
 InOutBoard_statusLog.dateStamp>=$startDate and 
 InOutBoard_statusLog.dateStamp<=$endDate
 $departmentSQLclause
group by InOutBoard_statusLog.dateStamp
order by department, lastName, firstName, InOutBoard_statusLog.dateStamp";
	  $self->session->log->warn("QUERY: $sql\n");
	  $p->setDataByQuery($sql);
	  my $rowdata = $p->getPageData();
	  my @rows;
	  foreach my $data (@$rowdata) {
		my %row;
		
		if ($lastDepartment ne $data->{department}) {
		  $row{deptHasChanged} = 1;
		  $row{'department'} = ($data->{department}||$i18n->get(7));
		  $lastDepartment = $data->{department};
		}
		else { $row{deptHasChanged} = 0; }

		$row{'username'} = _defineUsername($data);

		$row{'status'} = ($data->{status}||$i18n->get(15));
		$row{'dateStamp'} = $self->session->datetime->epochToHuman($data->{dateStamp});
		$row{'message'} = ($data->{message}||"&nbsp;");
		if (! exists $changedBy{ $data->{createdBy} }) {
			my %whoChanged = $self->_fetchNames($data->{createdBy});
			$changedBy{ $data->{createdBy} } = $whoChanged{ $data->{createdBy} };
		}
		$row{'createdBy'} = $changedBy{ $data->{createdBy} };

		push (@rows, \%row);
	  }
	  $var{rows_loop} = \@rows;
	  $var{'paginateBar'} = $p->getBarTraditional();
	  $var{'username.label'}  = $i18n->get('username label');
	  $var{'status.label'}    = $i18n->get(5);
	  $var{'date.label'}      = $i18n->get('date label');
	  $var{'message.label'}   = $i18n->get('message label');
	  $var{'updatedBy.label'} = $i18n->get('updatedBy label');
	  $p->appendTemplateVars(\%var);
	}
	else {
        $var{showReport} = 0;
    }
	
	return $self->processStyle($self->processTemplate(\%var, $self->reportTemplateId));
}

1;

