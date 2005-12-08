package WebGUI::Asset::Wobject::InOutBoard;

$VERSION = "0.5.3";

use strict;
use WebGUI::DateTime;
use WebGUI::FormProcessor;
use WebGUI::Grouping;
use WebGUI::HTMLForm;
use WebGUI::International;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Asset::Wobject;
use WebGUI::ErrorHandler;
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
	my $sth = WebGUI::SQL->prepare($sql);
	foreach my $userId (@userIds) {
		$sth->execute([ $userId ]);
		$nameHash{ $userId } = _defineUsername($sth->hashRef);
	}
	$sth->finish;
	return %nameHash;
}

#-------------------------------------------------------------------
sub _fetchDepartments {
	return WebGUI::SQL->buildArray("select fieldData from userProfileData where fieldName='department' GROUP by fieldData");
}


#-------------------------------------------------------------------
sub definition {
	my $class = shift;
        my $definition = shift;
        push(@{$definition}, {
                tableName=>'InOutBoard',
                className=>'WebGUI::Asset::Wobject::InOutBoard',
		icon=>'iob.gif',
                properties=>{
			statusList => {
				defaultValue => WebGUI::International::get(10, "Asset_InOutBoard")."\n"
						.WebGUI::International::get(11, "Asset_InOutBoard")."\n",
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
        return $class->SUPER::definition($definition);
}


#-------------------------------------------------------------------
sub getEditForm {
        my $self = shift;
        my $tabform = $self->SUPER::getEditForm();
	$tabform->getTab("properties")->textarea(
		-name=>"statusList",
		-label=>WebGUI::International::get(1, "Asset_InOutBoard"),
		-value=>$self->getValue("statusList"),
		-subtext=>WebGUI::International::get(2, "Asset_InOutBoard"),
		);
	$tabform->getTab("display")->integer(
		-name=>"paginateAfter",
		-label=>WebGUI::International::get(12, "Asset_InOutBoard"),
		-value=>$self->getValue("paginateAfter")
		);
	$tabform->getTab("display")->template (
	    -name => "inOutTemplateId",
	    -value => $self->getValue("inOutTemplateId"),
	    -label => WebGUI::International::get("In Out Template", "Asset_InOutBoard"),
	    -namespace => "InOutBoard"
	    );
	$tabform->getTab("display")->template (
	    -name => "reportTemplateId",
	    -value => $self->getValue("reportTemplateId"),
	    -label => WebGUI::International::get(13, "Asset_InOutBoard"),
	    -namespace => "InOutBoard/Report"
	    );
	$tabform->getTab("security")->group(
		-name=>"reportViewerGroup",
		-value=>[$self->getValue("reportViewerGroup")],
		-label=>WebGUI::International::get(3, "Asset_InOutBoard")
		);
   $tabform->getTab("security")->group(
		-name=>"inOutGroup",
		-value=>[$self->getValue("inOutGroup")],
		-label=>WebGUI::International::get('inOutGroup', "Asset_InOutBoard")
		);
    return $tabform;
}


#-------------------------------------------------------------------
sub getName {
        return WebGUI::International::get(9,"Asset_InOutBoard");
}

#-------------------------------------------------------------------
sub view {
	my $self = shift;
	my %var;
	my $url = $self->getUrl('func=view');
	
	if (WebGUI::Grouping::isInGroup($self->getValue("reportViewerGroup"))) {
	  $var{'viewReportURL'} = $self->getUrl("func=viewReport");
	  $var{canViewReport} = 1;
	}
	else { $var{canViewReport} = 0; }
	
	my $statusUserId = $session{scratch}{userId} || $session{user}{userId};
	my $statusListString = $self->getValue("statusList");
	chop($statusListString);
	my @statusListArray = split("\n",$statusListString);
	my $statusListHashRef;
	
	foreach my $status (@statusListArray) {
		chop($status);
		$statusListHashRef->{$status} = $status;
	}

	#WebGUI::ErrorHandler::warn("VIEW: userId: ".$statusUserId."\n" );
	my ($status) = WebGUI::SQL->quickArray("select status from InOutBoard_status where userId=".quote($statusUserId)." and assetId=".quote($self->getId));

	##Find all the users for which I am a delegate
	my @users = WebGUI::SQL->buildArray("select userId from InOutBoard_delegates where assetId=".quote($self->getId)." and delegateUserId=".quote($session{user}{userId}));

	my $f = WebGUI::HTMLForm->new(-action=>$self->getUrl);
	if (@users) {
		my %nameHash;
		tie %nameHash, "Tie::IxHash";
		%nameHash = _fetchNames(@users);
		$nameHash{""} = WebGUI::International::get('myself',"Asset_InOutBoard");
		%nameHash = WebGUI::Utility::sortHash(%nameHash);

		$f->selectBox(
			-name=>"delegate",
			-options=>\%nameHash,
			-value=>[ $session{scratch}{userId} ],
			-label=>WebGUI::International::get('delegate', "Asset_InOutBoard"),
			-extras=>q|onchange="this.form.submit();"|,
		);
	}
	$f->radioList(
		-name=>"status",
		-value=>$status,
		-options=>$statusListHashRef,
		-label=>WebGUI::International::get(5, "Asset_InOutBoard")
		);
	$f->text(
		-name=>"message",
		-label=>WebGUI::International::get(6, "Asset_InOutBoard")
		);
	$f->hidden(
		-name=>"func",
		-value=>"setStatus"
		);
	$f->submit;
	
	my ($isInGroup) = WebGUI::SQL->quickArray("select count(*) from groupings where userId=".quote($session{user}{userId})." and groupId=".quote($self->get("inOutGroup")));
	if ($isInGroup) {
	  $var{displayForm} = 1;
	  $var{'form'} = $f->print;
	  $var{'selectDelegatesURL'} = $self->getUrl("func=selectDelegates");
	}
	else { $var{displayForm} = 0; }
	
	my $lastDepartment = "_nothing_";
	
	my $p = WebGUI::Paginator->new($url, $self->getValue("paginateAfter"));
	
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
left join InOutBoard_status on users.userId=InOutBoard_status.userId and InOutBoard_status.assetId=".quote($self->getId())."
where users.userId<>'1' and InOutBoard.inOutGroup=".quote($self->get("inOutGroup"))."
group by userId
order by department, lastName, firstName";

	$p->setDataByQuery($sql);
	my $rowdata = $p->getPageData();
	my @rows;
	foreach my $data (@$rowdata) {
		my %row;
		if ($lastDepartment ne $data->{department}) {
		  $row{deptHasChanged} = 1;
		  $row{'department'} = ($data->{department}||WebGUI::International::get(7, "Asset_InOutBoard"));
		  $lastDepartment = $data->{department};
		}
		else { $row{deptHasChanged} = 0; }
		
		if ($data->{firstName} ne "" && $data->{lastName} ne "") {
		  $row{'username'} = $data->{firstName}." ".$data->{lastName};
		}
		else {
		  $row{'username'} = $data->{username};
		}
		
		$row{'status'} = ($data->{status}||WebGUI::International::get(15, "Asset_InOutBoard"));
		$row{'dateStamp'} = WebGUI::DateTime::epochToHuman($data->{dateStamp});
		$row{'message'} = ($data->{message}||"&nbsp;");
		
		push (@rows, \%row);
	}
	$var{rows_loop} = \@rows;
	$var{'paginateBar'} = $p->getBarTraditional();
	$p->appendTemplateVars(\%var);
	
	return $self->processTemplate(\%var,$self->getValue("inOutTemplateId"));
}

#-------------------------------------------------------------------
sub www_edit {
        my $self = shift;
        return WebGUI::Privilege::insufficient() unless $self->canEdit;
        return $self->getAdminConsole->render($self->getEditForm->print,WebGUI::International::get("18","Asset_InOutBoard"));
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
#group by userId", quote($session{user}{userId});
    
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
group by userId", quote($self->getId), quote($session{user}{userId}), quote($self->getValue("inOutGroup")) ;
	my %userNames = ();
	my $sth = WebGUI::SQL->read($sql);
	while (my $data = $sth->hashRef) {
		$userNames{ $data->{userId} } = _defineUsername($data);
	}
	$sth->finish;
	$sql = sprintf "select delegateUserId from InOutBoard_delegates where userId=%s and assetId=%s",
	                quote($session{user}{userId}), quote($self->getId);
	my $delegates = WebGUI::SQL->buildArrayRef($sql);
        my $f = WebGUI::HTMLForm->new(-action=>$self->getUrl);
        $f->hidden(
	    -name => "func",
	    -value => "selectDelegatesEditSave"
	);
        $f->selectList(
	    -name => "delegates",
	    -label => WebGUI::International::get('in/out status delegates','Asset_InOutBoard'),
	    -options => \%userNames,
	    -multiple => 1,        ##Multiple select
	    -size => 10,        ##Multiple select
	    -sortByValue => 1,
	    -value => $delegates,  ##My current delegates, if any
	    -subtext => WebGUI::International::get('in/out status delegates subtext','Asset_InOutBoard'),
	);
	$f->submit;
	my $ac = $self->getAdminConsole;
	return $ac->render($f->print,
	                   WebGUI::International::get('select delegate','Asset_InOutBoard'));
}

#-------------------------------------------------------------------
sub www_selectDelegatesEditSave {
	my $self = shift;
	my @delegates = WebGUI::FormProcessor::selectList("delegates");
	WebGUI::SQL->write("delete from InOutBoard_delegates where assetId=".quote($self->getId)." and userId=".quote($session{user}{userId}));

	foreach my $delegate (@delegates) {
		WebGUI::SQL->write("insert into InOutBoard_delegates
		(userId,delegateUserId,assetId) values
		(".quote($session{user}{userId}).",".quote($delegate).",".quote($self->getId).")");
	}
	return "";
}
#-------------------------------------------------------------------
sub www_setStatus {
	my $self = shift;
	#WebGUI::ErrorHandler::warn("delegateId: ". $session{form}{delegate}."\n" );
	#WebGUI::ErrorHandler::warn("userId: ".$session{scratch}{userId} ."\n" );
	if ($session{form}{delegate} eq $session{scratch}{userId}) {
		#WebGUI::ErrorHandler::warn("Wrote data and removed scratch\n");
		my $sessionUserId = $session{scratch}{userId} || $session{user}{userId};
		#WebGUI::ErrorHandler::warn("user Id: ".$sessionUserId."\n");
		WebGUI::Session::deleteScratch("userId");
		WebGUI::SQL->write("delete from InOutBoard_status where userId=".quote($sessionUserId)." and  assetId=".quote($self->getId));
		WebGUI::SQL->write("insert into InOutBoard_status (assetId,userId,status,dateStamp,message) values (".quote($self->getId).",".quote($sessionUserId).","
			.quote($session{form}{status}).",".WebGUI::DateTime::time().",".quote($session{form}{message}).")");
		WebGUI::SQL->write("insert into InOutBoard_statusLog (assetId,userId,createdBy,status,dateStamp,message) values (".quote($self->getId).",".quote($sessionUserId).",".quote($session{user}{userId}).","
			.quote($session{form}{status}).",".WebGUI::DateTime::time().",".quote($session{form}{message}).")");
	}
	else {
		#WebGUI::ErrorHandler::warn("Set scratch, redisplay\n");
		#WebGUI::ErrorHandler::warn(sprintf "Delegate is %s\n", $session{form}{delegate});
		WebGUI::Session::setScratch("userId",$session{form}{delegate});
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
	return "" unless (WebGUI::Grouping::isInGroup($self->getValue("reportViewerGroup")));
	my %var;
	my $f = WebGUI::HTMLForm->new(-action=>$self->getUrl, -method=>"GET");
	my %changedBy = ();
	$f->hidden(
		-name=>"func",
		-value=>"viewReport"
		);
	$f->hidden(
		-name=>"doit",
		-value=>"1"
		);
	my $startDate = WebGUI::DateTime::addToDate(WebGUI::DateTime::time(),0,0,-15);
	$startDate = WebGUI::FormProcessor::date("startDate") if ($session{form}{doit}); 
	$f->date(
		-name=>"startDate",
		-label=>WebGUI::International::get(16, "Asset_InOutBoard"),
		-value=>$startDate
		);
	my $endDate = WebGUI::FormProcessor::date("endDate");
	$f->date(
		-name=>"endDate",
		-label=>WebGUI::International::get(17, "Asset_InOutBoard"),
		-value=>$endDate
		);
	my %depHash;
	%depHash = map { $_ => $_ } (_fetchDepartments(),
				     WebGUI::International::get('all departments', 'Asset_InOutBoard'));
	my $defaultDepartment =  $session{form}{selectDepartment}
	                      || WebGUI::International::get('all departments', 'Asset_InOutBoard');
	my $departmentSQLclause = ($defaultDepartment eq WebGUI::International::get('all departments', 'Asset_InOutBoard'))
	                        ? ''
				: 'and c.fieldData='.quote($defaultDepartment);
	$f->selectBox(
		-name=>"selectDepartment",
		-options=>\%depHash,
		-value=>[ $defaultDepartment ],
		-label=>WebGUI::International::get('filter departments', "Asset_InOutBoard"),
	);
	my %paginHash;
	tie %paginHash, "Tie::IxHash"; ##Because default sort order is alpha
	%paginHash = (50 => 50, 100 => 100, 300 => 300, 500 => 500, 1000 => 1000, 10_000 => 10_000,);
	my $pageReportAfter = $session{form}{reportPagination} || 50;
	$f->selectBox(
		-name=>"reportPagination",
		-options=>\%paginHash,
		-value=>[ $pageReportAfter ],
		-label=>WebGUI::International::get(14, "Asset_InOutBoard"),
	);
	$f->submit(-value=>"Search");
	$var{'form'} = $f->print;
	my $url = $self->getUrl("func=viewReport&selectDepartment=$session{form}{selectDepartment}&reportPagination=$session{form}{reportPagination}&startDate=$session{form}{startDate}&endDate=$session{form}{endDate}&doit=1");
	if ($session{form}{doit}) {
	  $var{showReport} = 1;
	  $endDate = WebGUI::DateTime::addToTime($endDate,24,0,0);
	  my $lastDepartment = "_none_";
	  my $p = WebGUI::Paginator->new($url, $pageReportAfter);
	  
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
left join InOutBoard_statusLog on users.userId=InOutBoard_statusLog.userId and InOutBoard_statusLog.assetId=".quote($self->getId())."
where users.userId<>'1' and 
 groupings.groupId=".quote($self->getValue("inOutGroup"))." and 
 groupings.userId=users.userId and 
 InOutBoard_statusLog.dateStamp>=$startDate and 
 InOutBoard_statusLog.dateStamp<=$endDate
 $departmentSQLclause
group by InOutBoard_statusLog.dateStamp
order by department, lastName, firstName, InOutBoard_statusLog.dateStamp";
	  #WebGUI::ErrorHandler::warn("QUERY: $sql\n");
	  $p->setDataByQuery($sql);
	  my $rowdata = $p->getPageData();
	  my @rows;
	  foreach my $data (@$rowdata) {
		my %row;
		
		if ($lastDepartment ne $data->{department}) {
		  $row{deptHasChanged} = 1;
		  $row{'department'} = ($data->{department}||WebGUI::International::get(7, "Asset_InOutBoard"));
		  $lastDepartment = $data->{department};
		}
		else { $row{deptHasChanged} = 0; }

		$row{'username'} = _defineUsername($data);

		$row{'status'} = ($data->{status}||WebGUI::International::get(15, "Asset_InOutBoard"));
		$row{'dateStamp'} = WebGUI::DateTime::epochToHuman($data->{dateStamp});
		$row{'message'} = ($data->{message}||"&nbsp;");
		if (! exists $changedBy{ $data->{createdBy} }) {
			my %whoChanged = _fetchNames($data->{createdBy});
			$changedBy{ $data->{createdBy} } = $whoChanged{ $data->{createdBy} };
		}
		$row{'createdBy'} = $changedBy{ $data->{createdBy} };

		push (@rows, \%row);
	  }
	  $var{rows_loop} = \@rows;
	  $var{'paginateBar'} = $p->getBarTraditional();
	  $var{'username.label'}  = WebGUI::International::get('username label','Asset_InOutBoard');
	  $var{'status.label'}    = WebGUI::International::get(5,'Asset_InOutBoard');
	  $var{'date.label'}      = WebGUI::International::get('date label','Asset_InOutBoard');
	  $var{'message.label'}   = WebGUI::International::get('message label','Asset_InOutBoard');
	  $var{'updatedBy.label'} = WebGUI::International::get('updatedBy label','Asset_InOutBoard');
	  $p->appendTemplateVars(\%var);
	}
	else { $var{showReport} = 0; }
	
	return $self->processStyle($self->processTemplate(\%var, $self->getValue("reportTemplateId")));
}

1;

