package WebGUI::Asset::Wobject::InOutBoard;

$VERSION = "0.5.3";

use strict;
use WebGUI::HTMLForm;
use WebGUI::International;
use WebGUI::Paginator;
use WebGUI::SQL;
use WebGUI::Asset::Wobject;
use Data::Dumper;

our @ISA = qw(WebGUI::Asset::Wobject);

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
	my $sql = "select users.username, 
users.userId, 
a.fieldData as firstName,
b.fieldData as lastName
from users
left join userProfileData a on users.userId=a.userId and a.fieldName='firstName'
left join userProfileData b on users.userId=b.userId and b.fieldName='lastName'
where users.userId=?";
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
	return $self->session->db->buildArray("select fieldData from userProfileData where fieldName='department' GROUP by fieldData");
}


#-------------------------------------------------------------------
sub definition {
	my $class = shift;
	my $session = shift;
        my $definition = shift;
	my $i18n = WebGUI::International->new($session,"Asset_InOutBoard");
        push(@{$definition}, {
                tableName=>'InOutBoard',
                className=>'WebGUI::Asset::Wobject::InOutBoard',
                assetName=>$i18n->get('assetName'),
		icon=>'iob.gif',
                properties=>{
			statusList => {
				defaultValue => $i18n->get(10)."\n"
						.$i18n->get(11)."\n",
				fieldType=>"textarea"
				},
			reportViewerGroup => {
				defaultValue => 3,
				fieldType => "group"
				},
		    inOutGroup => {
				defaultValue => 2,
				fieldType => "group"
				},
			inOutTemplateId => {
				fieldType=>"template",
			        defaultValue => 'IOB0000000000000000001'
			        },
			reportTemplateId => {
				fieldType=>"template",
			        defaultValue => 'IOB0000000000000000002'
			        },
			paginateAfter => {
				fieldType=>"integer",
				defaultValue => 50
				},
  			}
                });
        return $class->SUPER::definition($session, $definition);
}


#-------------------------------------------------------------------
sub getEditForm {
        my $self = shift;
        my $tabform = $self->SUPER::getEditForm();
	my $i18n = WebGUI::International->new($self->session, "Asset_InOutBoard");
	$tabform->getTab("properties")->textarea(
		-name=>"statusList",
		-label=>$i18n->get(1),
		-value=>$self->getValue("statusList"),
		-subtext=>$i18n->get(2),
		);
	$tabform->getTab("display")->integer(
		-name=>"paginateAfter",
		-label=>$i18n->get(12),
		-value=>$self->getValue("paginateAfter")
		);
	$tabform->getTab("display")->template (
	    -name => "inOutTemplateId",
	    -value => $self->getValue("inOutTemplateId"),
	    -label => $i18n->get("In Out Template"),
	    -namespace => "InOutBoard"
	    );
	$tabform->getTab("display")->template (
	    -name => "reportTemplateId",
	    -value => $self->getValue("reportTemplateId"),
	    -label => $i18n->get(13),
	    -namespace => "InOutBoard/Report"
	    );
	$tabform->getTab("security")->group(
		-name=>"reportViewerGroup",
		-value=>[$self->getValue("reportViewerGroup")],
		-label=>$i18n->get(3)
		);
   $tabform->getTab("security")->group(
		-name=>"inOutGroup",
		-value=>[$self->getValue("inOutGroup")],
		-label=>$i18n->get('inOutGroup')
		);
    return $tabform;
}


#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
	my $self = shift;
	$self->SUPER::prepareView();
	my $template = WebGUI::Asset::Template->new($self->session, $self->getValue("inOutTemplateId"));
	$template->prepare;
	$self->{_viewTemplate} = $template;
}


#-------------------------------------------------------------------
sub view {
	my $self = shift;
	my %var;
	my $url = $self->getUrl('func=view');
	
	my $i18n = WebGUI::International->new($self->session, "Asset_InOutBoard");
	if ($self->session->user->isInGroup($self->getValue("reportViewerGroup"))) {
	  $var{'viewReportURL'} = $self->getUrl("func=viewReport");
	  $var{canViewReport} = 1;
	}
	else { $var{canViewReport} = 0; }
	
	my $statusUserId = $self->session->scratch->get("userId") || $self->session->user->userId;
	my $statusListString = $self->getValue("statusList");
	chop($statusListString);
	my @statusListArray = split("\n",$statusListString);
	my $statusListHashRef;
	
	foreach my $status (@statusListArray) {
		chop($status);
		$statusListHashRef->{$status} = $status;
	}

	#$self->session->errorHandler->warn("VIEW: userId: ".$statusUserId."\n" );
	my ($status) = $self->session->db->quickArray("select status from InOutBoard_status where userId=".$self->session->db->quote($statusUserId)." and assetId=".$self->session->db->quote($self->getId));

	##Find all the users for which I am a delegate
	my @users = $self->session->db->buildArray("select userId from InOutBoard_delegates where assetId=".$self->session->db->quote($self->getId)." and delegateUserId=".$self->session->db->quote($self->session->user->userId));

	my $f = WebGUI::HTMLForm->new($self->session,-action=>$self->getUrl);
	if (@users) {
		my %nameHash;
		tie %nameHash, "Tie::IxHash";
		%nameHash = $self->_fetchNames(@users);
		$nameHash{""} = $i18n->get('myself');
		%nameHash = WebGUI::Utility::sortHash(%nameHash);

		$f->selectBox(
			-name=>"delegate",
			-options=>\%nameHash,
			-value=>[ $self->session->scratch->get("userId") ],
			-label=>$i18n->get('delegate'),
			-extras=>q|onchange="this.form.submit();"|,
		);
	}
	$f->radioList(
		-name=>"status",
		-value=>$status,
		-options=>$statusListHashRef,
		-label=>$i18n->get(5)
		);
	$f->text(
		-name=>"message",
		-label=>$i18n->get(6)
		);
	$f->hidden(
		-name=>"func",
		-value=>"setStatus"
		);
	$f->submit;
	
	my ($isInGroup) = $self->session->db->quickArray("select count(*) from groupings where userId=".$self->session->db->quote($self->session->user->userId)." and groupId=".$self->session->db->quote($self->get("inOutGroup")));
	if ($isInGroup) {
	  $var{displayForm} = 1;
	  $var{'form'} = $f->print;
	  $var{'selectDelegatesURL'} = $self->getUrl("func=selectDelegates");
	}
	else { $var{displayForm} = 0; }
	
	my $lastDepartment = "_nothing_";
	
	my $p = WebGUI::Paginator->new($self->session,$url, $self->getValue("paginateAfter"));
	
	my $sql = "select users.username, 
users.userId, 
a.fieldData as firstName, 
InOutBoard_status.message, 
b.fieldData as lastName, 
InOutBoard_status.status, 
InOutBoard_status.dateStamp, 
c.fieldData as department, 
groupings.groupId
from users 
left join groupings on  groupings.userId=users.userId
left join InOutBoard on groupings.groupId=InOutBoard.inOutGroup
left join userProfileData a on users.userId=a.userId and a.fieldName='firstName'
left join userProfileData b on users.userId=b.userId and b.fieldName='lastName'
left join userProfileData c on users.userId=c.userId and c.fieldName='department'
left join InOutBoard_status on users.userId=InOutBoard_status.userId and InOutBoard_status.assetId=".$self->session->db->quote($self->getId())."
where users.userId<>'1' and InOutBoard.inOutGroup=".$self->session->db->quote($self->get("inOutGroup"))."
group by userId
order by department, lastName, firstName";

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
		
		if ($data->{firstName} ne "" && $data->{lastName} ne "") {
		  $row{'username'} = $data->{firstName}." ".$data->{lastName};
		}
		else {
		  $row{'username'} = $data->{username};
		}
		
		$row{'status'} = ($data->{status}||$i18n->get(15));
		$row{'dateStamp'} = $self->session->datetime->epochToHuman($data->{dateStamp});
		$row{'message'} = ($data->{message}||"&nbsp;");
		
		push (@rows, \%row);
	}
	$var{rows_loop} = \@rows;
	$var{'paginateBar'} = $p->getBarTraditional();
	$p->appendTemplateVars(\%var);
	
	return $self->processTemplate(\%var,undef,$self->{_viewTemplate});
}

#-------------------------------------------------------------------
sub www_edit {
        my $self = shift;
        return $self->session->privilege->insufficient() unless $self->canEdit;
	my $i18n = WebGUI::International->new($self->session, "Asset_InOutBoard");
        return $self->getAdminConsole->render($self->getEditForm->print,$i18n->get("18"));
}

#-------------------------------------------------------------------
sub www_selectDelegates {
	my $self = shift;
	
	#Uncomment the sql query below (lines 286 - 294) to show all users of the system in the delegate select list
	#my $sql = sprintf "select users.username, 
#users.userId, 
#a.fieldData as firstName,
#b.fieldData as lastName
#from users
#left join userProfileData a on users.userId=a.userId and a.fieldName='firstName'
#left join userProfileData b on users.userId=b.userId and b.fieldName='lastName'
#where users.userId<>'1' and users.status='Active' and users.userId<>%s
#group by userId", $self->session->db->quote($self->session->user->userId);
    
	#Comment the sql query below (lines 297 - 307) to show all users of the system in the delegate select list
    my $sql = sprintf "select users.username, 
users.userId, 
a.fieldData as firstName,
b.fieldData as lastName
from users, InOutBoard, groupings
left join userProfileData a on users.userId=a.userId and a.fieldName='firstName'
left join userProfileData b on users.userId=b.userId and b.fieldName='lastName'
left join userProfileData c on users.userId=c.userId and c.fieldName='department'
left join InOutBoard_status on users.userId=InOutBoard_status.userId and InOutBoard_status.assetId=%s
where users.userId<>'1' and groupings.groupId=InOutBoard.inOutGroup and users.status='Active' and users.userId <> %s and groupings.userId=users.userId and InOutBoard.inOutGroup=%s
group by userId", $self->session->db->quote($self->getId), $self->session->db->quote($self->session->user->userId), $self->session->db->quote($self->getValue("inOutGroup")) ;
	my %userNames = ();
	my $sth = $self->session->db->read($sql);
	while (my $data = $sth->hashRef) {
		$userNames{ $data->{userId} } = _defineUsername($data);
	}
	$sth->finish;
	$sql = sprintf "select delegateUserId from InOutBoard_delegates where userId=%s and assetId=%s",
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
sub www_selectDelegatesEditSave {
	my $self = shift;
	my @delegates = $self->session->form->selectList("delegates");
	$self->session->db->write("delete from InOutBoard_delegates where assetId=".$self->session->db->quote($self->getId)." and userId=".$self->session->db->quote($self->session->user->userId));

	foreach my $delegate (@delegates) {
		$self->session->db->write("insert into InOutBoard_delegates
		(userId,delegateUserId,assetId) values
		(".$self->session->db->quote($self->session->user->userId).",".$self->session->db->quote($delegate).",".$self->session->db->quote($self->getId).")");
	}
	return "";
}
#-------------------------------------------------------------------
sub www_setStatus {
	my $self = shift;
	#$self->session->errorHandler->warn("delegateId: ". $self->session->form->process("delegate")."\n" );
	#$self->session->errorHandler->warn("userId: ".$self->session->scratch->get("userId") ."\n" );
	if ($self->session->form->process("delegate") eq $self->session->scratch->get("userId")) {
		#$self->session->errorHandler->warn("Wrote data and removed scratch\n");
		my $sessionUserId = $self->session->scratch->get("userId") || $self->session->user->userId;
		#$self->session->errorHandler->warn("user Id: ".$sessionUserId."\n");
		$self->session->scratch->delete("userId");
		$self->session->db->write("delete from InOutBoard_status where userId=".$self->session->db->quote($sessionUserId)." and  assetId=".$self->session->db->quote($self->getId));
		$self->session->db->write("insert into InOutBoard_status (assetId,userId,status,dateStamp,message) values (".$self->session->db->quote($self->getId).",".$self->session->db->quote($sessionUserId).","
			.$self->session->db->quote($self->session->form->process("status")).",".$self->session->datetime->time().",".$self->session->db->quote($self->session->form->process("message")).")");
		$self->session->db->write("insert into InOutBoard_statusLog (assetId,userId,createdBy,status,dateStamp,message) values (".$self->session->db->quote($self->getId).",".$self->session->db->quote($sessionUserId).",".$self->session->db->quote($self->session->user->userId).","
			.$self->session->db->quote($self->session->form->process("status")).",".$self->session->datetime->time().",".$self->session->db->quote($self->session->form->process("message")).")");
	}
	else {
		#$self->session->errorHandler->warn("Set scratch, redisplay\n");
		#$self->session->errorHandler->warn(sprintf "Delegate is %s\n", $self->session->form->process("delegate"));
		$self->session->scratch->set("userId",$self->session->form->process("delegate"));
	}
	return $self->www_view;
}

sub www_view {
	my $self = shift;
	$self->SUPER::www_view(1);
}

#-------------------------------------------------------------------
sub www_viewReport {
	my $self = shift;
	return "" unless ($self->session->user->isInGroup($self->getValue("reportViewerGroup")));
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
		-value=>$startDate
		);
	my $endDate = $self->session->form->date("endDate");
	$f->date(
		-name=>"endDate",
		-label=>$i18n->get(17),
		-value=>$endDate
		);
	my %depHash;
	%depHash = map { $_ => $_ } ($self->_fetchDepartments(),
				     $i18n->get('all departments'));
	my $defaultDepartment =  $self->session->form->process("selectDepartment")
	                      || $i18n->get('all departments');
	my $departmentSQLclause = ($defaultDepartment eq $i18n->get('all departments'))
	                        ? ''
				: 'and c.fieldData='.$self->session->db->quote($defaultDepartment);
	$f->selectBox(
		-name=>"selectDepartment",
		-options=>\%depHash,
		-value=>[ $defaultDepartment ],
		-label=>$i18n->get('filter departments'),
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
	);
	$f->submit(-value=>"Search");
	$var{'form'} = $f->print;
	my $url = $self->getUrl("func=viewReport;selectDepartment=".$self->session->form->process("selectDepartment").";reportPagination=".$self->session->form->process("reportPagination").";startDate=".$self->session->form->process("startDate").";endDate=".$self->session->form->process("endDate").";doit=1");
	if ($self->session->form->process("doit")) {
	  $var{showReport} = 1;
	  $endDate = $self->session->datetime->addToTime($endDate,24,0,0);
	  my $lastDepartment = "_none_";
	  my $p = WebGUI::Paginator->new($self->session,$url, $pageReportAfter);
	  
	  my $sql = "select users.username, 
users.userId, 
a.fieldData as firstName, 
InOutBoard_statusLog.message,
b.fieldData as lastName, 
InOutBoard_statusLog.status, 
InOutBoard_statusLog.dateStamp, 
InOutBoard_statusLog.createdBy, 
c.fieldData as department,
groupings.groupId
from users
left join groupings on groupings.userId=users.userId
left join userProfileData a on users.userId=a.userId and a.fieldName='firstName'
left join userProfileData b on users.userId=b.userId and b.fieldName='lastName'
left join userProfileData c on users.userId=c.userId and c.fieldName='department'
left join InOutBoard_statusLog on users.userId=InOutBoard_statusLog.userId and InOutBoard_statusLog.assetId=".$self->session->db->quote($self->getId())."
where users.userId<>'1' and 
 groupings.groupId=".$self->session->db->quote($self->getValue("inOutGroup"))." and 
 groupings.userId=users.userId and 
 InOutBoard_statusLog.dateStamp>=$startDate and 
 InOutBoard_statusLog.dateStamp<=$endDate
 $departmentSQLclause
group by InOutBoard_statusLog.dateStamp
order by department, lastName, firstName, InOutBoard_statusLog.dateStamp";
	  #$self->session->errorHandler->warn("QUERY: $sql\n");
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
	else { $var{showReport} = 0; }
	
	return $self->processStyle($self->processTemplate(\%var, $self->getValue("reportTemplateId")));
}

1;

