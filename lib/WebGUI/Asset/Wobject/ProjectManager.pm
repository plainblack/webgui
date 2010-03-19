package WebGUI::Asset::Wobject::ProjectManager;

use strict;
our $VERSION = "1.0.0";

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use DateTime;
use Tie::IxHash;
use WebGUI::International;
use WebGUI::Utility;
use WebGUI::HTML;
use POSIX qw(ceil floor);
use Moose;
use WebGUI::Definition::Asset;
extends 'WebGUI::Asset::Wobject';
define assetName => ['assetName', 'Asset_ProjectManager'];
define icon      => 'projManagement.gif';
define tableName => 'PM_wobject';
property projectDashboardTemplateId => (
            fieldType   => "template",  
            default     => 'ProjectManagerTMPL0001',
            tab         => "display",
            namespace   => "ProjectManager_dashboard", 
            hoverHelp   => ['projectDashboardTemplate hoverhelp', 'Asset_ProjectManager'],
            label       => ['projectDashboardTemplate label', 'Asset_ProjectManager'],
        );
property projectDisplayTemplateId => (
            fieldType   => "template",  
            default     => 'ProjectManagerTMPL0002',
            tab         => "display",
            namespace   => "ProjectManager_project", 
            hoverHelp   => ['projectDisplayTemplate hoverhelp', 'Asset_ProjectManager'],
            label       => ['projectDisplayTemplate label', 'Asset_ProjectManager'],
        );
property ganttChartTemplateId => (
            fieldType   => "template",  
            default     => 'ProjectManagerTMPL0003',
            tab         => "display",
            namespace   => "ProjectManager_gantt", 
            hoverHelp   => ['ganttChartTemplate hoverhelp', 'Asset_ProjectManager'],
            label       => ['ganttChartTemplate label', 'Asset_ProjectManager'],
        );
property editTaskTemplateId => (
            fieldType   => "template",  
            default     => 'ProjectManagerTMPL0004',
            tab         => "display",
            namespace   => "ProjectManager_editTask", 
            hoverHelp   => ['editTaskTemplate hoverhelp', 'Asset_ProjectManager'],
            label       => ['editTaskTemplate label', 'Asset_ProjectManager'],
        );
property resourcePopupTemplateId => (
            fieldType   => "template",  
            default     => 'ProjectManagerTMPL0005',
            tab         => "display",
            namespace   => "ProjectManager_resourcePopup", 
            hoverHelp   => ['resourcePopupTemplate hoverhelp', 'Asset_ProjectManager'],
            label       => ['resourcePopupTemplate label', 'Asset_ProjectManager'],
        );
property resourceListTemplateId => (
            fieldType   => "template",  
            default     => 'ProjectManagerTMPL0006',
            tab         => "display",
            namespace   => "ProjectManager_resourceList", 
            hoverHelp   => ['resourceListTemplate hoverhelp', 'Asset_ProjectManager'],
            label       => ['resourceListTemplate label', 'Asset_ProjectManager'],
        );
property groupToAdd => (
            fieldType   => "group",
            default     => 3,
            tab         => "security",
            hoverHelp   => ['groupToAdd hoverhelp', 'Asset_ProjectManager'],
            label       => ['groupToAdd label', 'Asset_ProjectManager'],
        );

#-------------------------------------------------------------------

=head2 _addDaysForMonth 

=cut

sub _addDaysForMonth {
   my $self = shift;
   my $dt = $self->session->datetime;
   my $eh = $self->session->errorHandler;
   
   my $days_loop = $_[0];
   my $hash = $_[1];
   my $month = $_[2];
   
   my ($monthStart,$monthEnd) = $dt->monthStartEnd($month);
   my $dayOfWeek = $dt->getDayOfWeek($monthStart);
   my $mondayAdjust = (7 - ($dayOfWeek-1)) % 7;

   my $firstMonday = $dt->addToDateTime($monthStart,0,0,$mondayAdjust,1);
   
   #This line of code just makes things easier to read
   my $colCount = 0;
   my $monday = $firstMonday;
   while ($monday < $monthEnd) {
      my $hash = {};
	  $hash->{'day.number'} = $dt->epochToHuman($monday,"%d");
	  #$eh->warn($hash->{'day.number'});
	  $monday += 604800; # Add one week to the first monday of the month
	  push(@{$days_loop},$hash);
	  $colCount++;
   }
   $hash->{'month.colspan'} = $colCount;
   #$eh->warn($dt->epochToHuman($firstMonday));
}

#-------------------------------------------------------------------

=head2 _clobberImproperDependants 

=cut

sub _clobberImproperDependants {
	my $self = shift;
	my $projectId = shift;
	my @nondependTaskIds = $self->session->db->buildArray("SELECT sequenceNumber FROM PM_task WHERE projectId = ? AND taskType <> 'timed'", [$projectId]);
	return undef unless @nondependTaskIds;
	$self->session->db->write("UPDATE PM_task SET dependants = NULL WHERE projectId = ? AND dependants IN (".join(', ', ('?') x @nondependTaskIds).")", [$projectId, @nondependTaskIds]);
}

#-------------------------------------------------------------------

=head2 _doGanttTaskResourceDisplay 

=cut

sub _doGanttTaskResourceDisplay {
	my $self = shift;
	my $hash = shift;
	my $task = shift;
	my @resources = @{$self->_resourceListOfTask($task->{taskId})};
	my @resourceNames = ();

	foreach my $resource (@resources) {
		my ($resourceKind, $resourceId) = @$resource{qw{resourceKind resourceId}};
		if ($resourceKind eq 'user') {
			my $u = WebGUI::User->new($self->session, $resourceId);
			my $name = $u->username;
			my $firstName = $u->profileField('firstName');
			my $lastName = $u->profileField('lastName');
			$name = "$firstName $lastName"
			    if (length $firstName and length $lastName);
			push @resourceNames, $name;
		} elsif ($resourceKind eq 'group') {
			my $g = WebGUI::Group->new($self->session, $resourceId);
			push @resourceNames, $g->name;
		} else {
			# Whee.
			push @resourceNames, "???"
		}
	}

	if (@resources) {
		$hash->{'task.hasResource'} = "true";
		$hash->{'task.resource.name'} =
		    join(', ', map { WebGUI::HTML::format($_, 'text') } @resourceNames);
	}
}

#-------------------------------------------------------------------

=head2 _getDurationUnitHash 

=cut

sub _getDurationUnitHash {
   my $self = shift;
   my ($session,$privilege,$form,$db,$dt,$i18n,$user) = $self->setSessionVars;
   
   tie my %hash, "Tie::IxHash";
   %hash = ( "hours"=>$i18n->get("hours label"), "days"=>$i18n->get("days label") );
   
   return \%hash;
}

#-------------------------------------------------------------------

=head2 _getDurationUnitHashAbbrev 

=cut

sub _getDurationUnitHashAbbrev {
   my $self = shift;
   my ($session,$privilege,$form,$db,$dt,$i18n,$user) = $self->setSessionVars;
   
   tie my %hash, "Tie::IxHash";
   %hash = ( "hours"=>$i18n->get("hours label abbrev"), "days"=>$i18n->get("days label abbrev") );
   
   return \%hash;
}

#-------------------------------------------------------------------

=head2 _groupSearchQuery 

=cut

sub _groupSearchQuery {
	my $self = shift;
	my $exclude = shift;
	my $searchPattern = lc('%'.shift().'%');
	my @exclude = ('1', '7', split /\;/, $exclude);
	my $excludePlaceholders = '('.join(',', ('?') x @exclude).')';
	my $query = <<"SQL";
SELECT 'group' AS resourceKind, groups.groupId AS resourceId
  FROM groups
 WHERE (LOWER(groups.groupName) LIKE ?) AND (groups.groupId NOT IN $excludePlaceholders)
       AND groups.isEditable = 1
 ORDER BY groups.groupName
SQL
	my @placeholders = ($searchPattern, @exclude);
	return ($query, \@placeholders);
}

#-------------------------------------------------------------------

=head2 _htmlOfResourceList 

=cut

sub _htmlOfResourceList {
	my $self = shift;
	my %args = %{+shift};
	my @resources = @_;
	my @listItems;
	my $assetExtras = $self->session->url->extras('wobject/ProjectManager');
	my $var = {};

	$var->{assetExtras} = $assetExtras;
	$var->{resourceLoop} = [];

	my $lastOdd = 0;
	foreach my $row (@resources) {
		my $subvar = {};
		my ($resourceKind, $resourceId) = @$row{qw{resourceKind resourceId}};
		my $odd = ($lastOdd = !$lastOdd);

		$subvar->{resourceKind} = $resourceKind;
		$subvar->{resourceId} = $resourceId;
		$subvar->{opCallbackJs} = $args{opCallbackJs};
		$subvar->{opIcon} = $args{opIcon};
		$subvar->{opTitle} = $args{opTitle};
		$subvar->{assetExtras} = $assetExtras;
		$subvar->{odd} = $odd;
		$subvar->{hiddenFields} = $args{hiddenFields};

		if ($resourceKind eq 'group') {
			my $group = WebGUI::Group->new($self->session, $resourceId);
			$subvar->{resourceName} = WebGUI::HTML::format($group->name, 'text');
			$subvar->{resourceIcon} = 'groups.gif';
		} elsif ($resourceKind eq 'user') {
			my $user = WebGUI::User->new($self->session, $resourceId);
			my ($firstName, $lastName, $username) = ($user->profileField('firstName'), $user->profileField('lastName'), $user->username);
			my $displayName = do {
				if (length($firstName) && length($lastName)) { "$lastName, $firstName" }
				elsif (length($firstName)) { $firstName }
				elsif (length($lastName)) { $lastName }
				else { $username }
			};
			$subvar->{resourceName} = WebGUI::HTML::format($displayName, 'text');
			$subvar->{resourceIcon} = 'users.gif';
		} else {
			$self->session->errorHandler->fatal("Unknown kind of resource '$resourceKind'!");
		}

		push @{$var->{resourceLoop}}, $subvar;
	}

	return $self->processTemplate($var, $self->resourceListTemplateId);
}

#-------------------------------------------------------------------

=head2 _innerHtmlOfResources 

=cut

sub _innerHtmlOfResources {
	my $self = shift;
	my @resources = @_;
	my $i18n = WebGUI::International->new($self->session, 'Asset_ProjectManager');
	return $self->_htmlOfResourceList({opCallbackJs => 'taskEdit_deleteResource', opIcon => 'delete.gif', opTitle => $i18n->get('resource remove opTitle'), hiddenFields => 1}, @resources);
}

#-------------------------------------------------------------------

=head2 _resourceListOfTask 

=cut

sub _resourceListOfTask {
	my $self         = shift;
	my $taskId       = shift;
    my $resourceList = [];
    
    unless ($taskId eq 'new') {
       my $sql = q|SELECT 
                    resourceKind, resourceId 
                  FROM 
                    PM_taskResource 
                  WHERE 
                    taskId = ? 
                  ORDER BY 
                    sequenceNumber
                 |;
       $resourceList 
           = $self->session->db->buildArrayRefOfHashRefs($sql,[$taskId]);
    }
    
	return $resourceList;    
}

#-------------------------------------------------------------------

=head2 _resourceSearchPopup 

=cut

sub _resourceSearchPopup {
	my $self = shift;
	my %args = @_;
	my $i18n = WebGUI::International->new($self->session,'Asset_ProjectManager');

	my $doSearch = $self->session->form->param('doSearch');
	my $jsCallback = $self->session->form->param('callback');
	$jsCallback =~ tr/A-Za-z0-9_//cd;
	my $selfUrlHtml = WebGUI::HTML::format($self->getUrl, 'text');
	my $assetExtras = $self->session->url->extras('wobject/ProjectManager');

	my ($search, $exclude) = map {scalar $self->session->form->param($_)} ('search', 'exclude');
	my ($searchHtml, $excludeHtml) = map {WebGUI::HTML::format($_, 'text')} ($search, $exclude);
	my $var = {};

	my $i18nprefix = $args{i18nprefix};
	foreach my $key (qw/title searchText foundMessage notFoundMessage/) {
		$var->{$key} = $i18n->get("$i18nprefix $key");
	}

	$var->{assetExtras} = $assetExtras;
	$var->{func} = $args{func};
	$var->{callback} = $jsCallback;
	$var->{exclude} = $excludeHtml;
	$var->{previousSearch} = $searchHtml;
	$var->{selfUrl} = $selfUrlHtml;

	if ($doSearch) {
		my @resources = @{$self->session->db->buildArrayRefOfHashRefs($args{queryCallback}->($exclude, $search))};
		$var->{doingSearch} = 1;
		$var->{foundResults} = scalar @resources;

		$var->{resourceDiv} = '<div id="taskEdit_resourceList_div">'.$self->_htmlOfResourceList({opCallbackJs => 'searchPopup_itemSelected', opIcon => 'add.gif', opTitle => $i18n->get('resource add opTitle'), hiddenFields => 0}, @resources).'</div>';
	} else {
		$var->{doingSearch} = 0;
	}

	return $self->processTemplate($var, $self->resourcePopupTemplateId);
}

#-------------------------------------------------------------------

=head2 _userSearchQuery 

=cut

sub _userSearchQuery {
	my $self = shift;
	my $exclude = shift;
	my $searchPattern = lc('%'.shift().'%');
	my @exclude = ('1', '3', split /\;/, $exclude);
	my $excludePlaceholders = '('.join(',', ('?') x @exclude).')';

	my $query = <<"SQL";
SELECT 'user' AS resourceKind, users.userId AS resourceId
  FROM users
       LEFT JOIN userProfileData ON users.userId = userProfileData.userId
 WHERE (LOWER(lastName) LIKE ? OR LOWER(firstName) LIKE ?
        OR LOWER(users.username) LIKE ?) AND (users.userId NOT IN $excludePlaceholders)
 ORDER BY lastName, firstName
SQL
	my @placeholders  = (($searchPattern) x 3, @exclude);
	return ($query, \@placeholders);
}

#-------------------------------------------------------------------

=head2 _updateDependantDates 

=cut

sub _updateDependantDates {
	my $self = shift;
	my $db = $self->session->db;
	my $dt = $self->session->datetime;
	my ($projectId) = @_;
	my $project = $self->getCollateral('PM_project', 'projectId', $projectId);

	my $tasks = $db->buildArrayRefOfHashRefs("select * from PM_task where projectId=?",[$projectId]);
   
	my $taskHash = {};
	foreach my $task (@{$tasks}) {
		my $seqNum = $task->{sequenceNumber};

		# Calculate initial duration in days and duration floor for this task.
		my $totalDurationInDays = $task->{duration} + $task->{lagTime};
		$totalDurationInDays = $totalDurationInDays / $project->{hoursPerDay} if( $project->{durationUnits} eq "hours" );
		my $totalDurationFloor = floor($totalDurationInDays);

		# If we have a predecessor, check against it.
		if (my $predecessor = $task->{dependants}) {
			my $pred = $taskHash->{$predecessor};
			unless ($pred) {
				# Predecessor has to have a lower sequence number, right?  Right?
				$self->session->errorHandler->error("Internal: predecessor '$predecessor' of task with seqNum '$seqNum' not in task hash?!");
				next;
			}

			# Need to fix the dates iff we intersect our predecessor.
			if ($task->{startDate} <= $pred->{endDate}) {
				# Update for fractional day part.
				# Buggo: why?
				$totalDurationInDays += $pred->{dayPart};
				$totalDurationFloor = floor($totalDurationInDays);
	           
				# Set start and end dates of the current task.
				$task->{startDate} = $pred->{endDate};
				$task->{endDate} = $dt->addToDateTime($task->{startDate}, 0, 0, $totalDurationFloor);
				# Update.
				$self->setCollateral("PM_task","taskId",$task,1,0,"projectId",$projectId);
			}
		}
	  
		# Extract fractional day part.
		my $totalDurationInDaysFrac = $totalDurationInDays - floor($totalDurationInDays);

		$taskHash->{$seqNum} = { 
					'startDate'=>$task->{startDate}, 
					'endDate'=>$task->{endDate}, 
					'duration'=>$task->{duration}, 
					'dayPart'=>$totalDurationInDaysFrac
				       };
	}
}

#-------------------------------------------------------------------

=head2 _userCanManageProject 

=cut

sub _userCanManageProject {
    my $self = shift;
    my $user = shift;
    my $projectId = shift;
    my ($managerGroup) = $self->session->db->quickArray("select projectManager from PM_project where projectId = ?", [$projectId]);
    return $self->canView($user->userId) && ($user->isInGroup($managerGroup) || $user->isInGroup($self->groupToAdd));
}

#-------------------------------------------------------------------

=head2 _userCanManageProjectList 

=cut

sub _userCanManageProjectList {
	my $self = shift;
	my $user = shift;
	return $self->canView($user->userId) && $user->isInGroup($self->groupToAdd);
}

#-------------------------------------------------------------------

=head2 _userCanObserveProject 

=cut

sub _userCanObserveProject {
	my $self = shift;
	my $user = shift;
	my $projectId = shift;
	my ($managerGroup, $observerGroup) = $self->session->db->quickArray("select projectManager, projectObserver from PM_project where projectId = ?", [$projectId]);
	return $self->canView($user->userId) && ($user->isInGroup($managerGroup) || $user->isInGroup($observerGroup) || $user->isInGroup($self->groupToAdd));
}

#-------------------------------------------------------------------
#API method called by Time Tracker to return the instance of the PM wobject which this project blongs

=head2 getProjectInstance 

=cut

sub getProjectInstance {
   my $class = shift;
   my $session = shift;
   my $db = $session->db;
   my $projectId = $_[0];
   return undef unless $projectId;
   my ($assetId) = $db->quickArray("select assetId from PM_project where projectId=?",[$projectId]);
   if($assetId) {
      return WebGUI::Asset->newById($session,$assetId);
   }
   return undef;
}

#-------------------------------------------------------------------
#API method called by Time Tracker to return all projects in all assets for which the user passed in has tasks assigned

=head2 getProjectList 

=cut

sub getProjectList {
	my $self = shift;
	my $db = $self->session->db;
	my $userId = $_[0];
	my @groupIds = @{WebGUI::User->new($self->session, $userId)->getGroups};
	my $groupIdQuery = @groupIds?
	    ('PM_taskResource.resourceId IN ('.join(',', ('?') x @groupIds).')') : '0';

	$self->session->db->buildHashRef(<<"SQL", [$userId, @groupIds]);
SELECT DISTINCT PM_project.projectId, PM_project.name
  FROM PM_project
       INNER JOIN PM_task ON PM_project.projectId = PM_task.projectId 
       INNER JOIN PM_taskResource ON PM_task.taskId = PM_taskResource.taskId
 WHERE (PM_taskResource.resourceKind = 'user' AND PM_taskResource.resourceId = ?)
       OR (PM_taskResource.resourceKind = 'group' AND $groupIdQuery)
SQL
}

#-------------------------------------------------------------------
#API method called by Time Tracker to return all tasks for the projectId passed in

=head2 getTaskList 

=cut

sub getTaskList {
	my $self = shift;
	my $db = $self->session->db;
	my $projectId = $_[0];
	my $userId = $_[1];
	my @groupIds = @{WebGUI::User->new($self->session, $userId)->getGroups};
	my $groupIdQuery = @groupIds?
	    ('PM_taskResource.resourceId IN ('.join(',', ('?') x @groupIds).')') : '0';

	$self->session->db->buildHashRef(<<"SQL", [$projectId, $userId, @groupIds]);
SELECT DISTINCT PM_task.taskId, PM_task.taskName
  FROM PM_task
       INNER JOIN PM_taskResource ON PM_task.taskId = PM_taskResource.taskId
 WHERE PM_task.projectId = ?
       AND ((PM_taskResource.resourceKind = 'user' AND PM_taskResource.resourceId = ?)
            OR (PM_taskResource.resourceKind = 'group' AND $groupIdQuery))
SQL
}

#-------------------------------------------------------------------

=head2 i18n 

=cut

sub i18n {
   my $self    = shift;
   my $session = $self->session;
   
   unless ($self->{_i18n}) {
      $self->{_i18n} 
          = WebGUI::International->new($session,'Asset_ProjectManager');
   }
   
   return $self->{_i18n};
}

#-------------------------------------------------------------------

=head2 prepareView 

=cut

sub prepareView {
    my $self = shift;
    $self->SUPER::prepareView();
    my $template = WebGUI::Asset::Template->newById($self->session, $self->projectDashboardTemplateId);
    if (!$template) {
        WebGUI::Error::ObjectNotFound::Template->throw(
            error      => qq{Template not found},
            templateId => $self->projectDashboardTemplateId,
            assetId    => $self->getId,
        );
    }
    $template->prepare($self->getMetaDataAsTemplateVariables);
    $self->{_viewTemplate} = $template;
}

#-------------------------------------------------------------------

=head2 processErrors 

=cut

sub processErrors {
   my $self = shift;
   my $errors = "";
   if($_[0]) {
      $errors = "<ul>";
	  foreach (@{$_[0]}) {
	     $errors .= "<li>$_</li>";
	  }
	  $errors .= "</ul>";
   }
   return $errors;
}


#-------------------------------------------------------------------

=head2 purge 

=cut

sub purge {
	my $self = shift;
	#purge your wobject-specific data here.  This does not include fields 
	# you create for your NewWobject asset/wobject table.
	return $self->SUPER::purge;
}

#-------------------------------------------------------------------

=head2 setSessionVars 

=cut

sub setSessionVars {
   my $self = shift;
   my $session = $self->session;
   
   return( 
            $session,
            $session->privilege,
            $session->form,
            $session->db,
            $session->datetime,
            $self->i18n,
            $session->user,
         );
}

#-------------------------------------------------------------------
# API method called by Time Tracker to set percent complete field in the task and update the project cache

=head2 updateProjectTask 

=cut

sub updateProjectTask {
	my $self = shift;
	my $db = $self->session->db;
	my $eh = $self->session->errorHandler;
   
	my $taskId = $_[0];
	my $projectId = $_[1];
	my $deltaHours = $_[2];
   	return 0 unless ($taskId && $projectId && $deltaHours);
   
	my $task = $self->getCollateral('PM_task', 'taskId', $taskId);
	my ($units,$hoursPerDay) = $db->quickArray("select durationUnits, hoursPerDay from PM_project where projectId=?",[$projectId]);
	return 0 unless ($task->{taskId});

	if ($task->{taskType} eq 'milestone') {
		return 0;
	} elsif ($task->{taskType} eq 'progressive') {
		my $deltaDuration = ($units eq 'days')? ($deltaHours / $hoursPerDay) : $deltaHours;
		$task->{duration} += $deltaDuration;
		$task->{endDate} += $deltaDuration * 3600;
		$task->{duration} = 0 if $task->{duration} < 0;
		$task->{endDate} = $task->{startDate} if $task->{endDate} < $task->{startDate};

		# Don't need to consider dependants here because nothing is allowed
		# to depend on a progressive task.
	} else {
		my $durationHours = ($units eq 'days')? ($task->{duration} * $hoursPerDay) : $task->{duration};
		$task->{percentComplete} += ($deltaHours / $durationHours) * 100;
		$task->{percentComplete} = 0 if $task->{percentComplete} < 0;
		$task->{percentComplete} = 100 if $task->{percentComplete} > 100;
	}
   
	$self->setCollateral("PM_task","taskId", { taskId=>$taskId, duration=>$task->{duration}, percentComplete=>$task->{percentComplete} });
	$self->updateProject($projectId);
	return 1;
}

#-------------------------------------------------------------------

=head2 updateProject 

=cut

sub updateProject {
	my $self = shift;
	my ($session,$privilege,$form,$db,$dt,$i18n,$user) = $self->setSessionVars;
	my $projectId= $_[0];
   
	my ($minStart, $maxEnd) = $db->quickArray("select min(startDate), max(endDate) from PM_task where projectId=?", [$projectId]);
	my ($projectTotal, $complete) = 0;

	my $tasks = $db->buildArrayRefOfHashRefs("select * from PM_task where projectId=? and taskType = 'timed' order by sequenceNumber asc", [$projectId]);
	foreach my $task (@{$tasks}) {
		$projectTotal += $task->{duration};
		$complete += ($task->{duration} * ($task->{percentComplete}/100));
	}

	my $projectComplete = ($projectTotal == 0)? 0 : (($complete / $projectTotal) * 100);
	$db->write("update PM_project set startDate=?, endDate=?, percentComplete=? where projectId=?",[$minStart,$maxEnd,$projectComplete,$projectId]);
}


#-------------------------------------------------------------------

=head2 view 

=cut

sub view {
	my $self = shift;
	my $var = $self->get;
	
	my ($session,$privilege,$form,$db,$datetime,$i18n,$user) = $self->setSessionVars;
	my $config = $session->config;
	my $eh = $session->errorHandler;
	
	$var->{'extras'} = $session->url->make_urlmap_work($config->get("extrasURL"))."/wobject/ProjectManager"; 
	$var->{'project.create'} = $self->getUrl("func=editProject;projectId=new");
	$var->{'project.create.label'} = $i18n->get("project new label");
	
	
	#Project Table Headers
	$var->{'project.name.label'} = $i18n->get("project name label");
	$var->{'project.startDate.label'} = $i18n->get("project start date label");
	$var->{'project.endDate.label'} = $i18n->get("project end date label");
	$var->{'project.cost.label'} = $i18n->get("project cost label");
	$var->{'project.complete.label'} = $i18n->get("project complete label");
	$var->{'project.actions.label'} = $i18n->get("project action label");
	
	$var->{'empty.colspan'} = 5;
	if($self->_userCanManageProjectList($user)) {
		$var->{'canEditProjects'} = "true";
	      $var->{'empty.colspan'} = 6;
	}
	
	#Project Data
	my @projects = ();
	my $sth = $db->read("select * from PM_project where assetId=".$db->quote($self->assetId));
	while (my $project = $sth->hashRef) {
	   my $hash = {};
	   my $projectId = $project->{projectId};

	   # Drop projects that the current user can't view.
	   next unless ($self->_userCanObserveProject($user, $projectId));

	   $hash->{'project.view.url'} = $self->getUrl("func=viewProject;projectId=".$projectId);
	   $hash->{'project.name.data'} = $project->{name};
	   $hash->{'project.description.data'} = $project->{description};
	   $hash->{'project.startDate.data'} = $project->{startDate}?$datetime->epochToSet($project->{startDate}):$i18n->get("N_A");
	   $hash->{'project.endDate.data'} = $project->{endDate}?$datetime->epochToSet($project->{endDate}):$i18n->get("N_A");
	   $hash->{'project.cost.data.int'} = WebGUI::Utility::commify(int($project->{targetBudget}));
	   $hash->{'project.cost.data.float'} = WebGUI::Utility::commify($project->{targetBudget});
	   $hash->{'project.complete.data.int'} = int($project->{percentComplete});
	   $hash->{'project.complete.data.int'} = 100 if($hash->{'project.complete.data.int'} > 100);
	   $hash->{'project.complete.data.float'} = sprintf("%2.2f",$project->{percentComplete});
	   if($var->{'canEditProjects'}) {
		  $hash->{'project.edit.url'} = $self->getUrl("func=editProject;projectId=".$projectId);
		  $hash->{'project.edit.title'} = $i18n->get("project edit title");
	      $hash->{'project.delete.url'} = $self->getUrl("func=deleteProject;projectId=".$projectId);   
		  $hash->{'project.delete.title'} = $i18n->get("project delete title");
	   }
	   push(@projects, $hash);
	}
	$sth->finish;
	
	my $warning = $i18n->get("project delete warning");
	$warning =~ s/'/\\'/g;
	$var->{'project.delete.warning'} = $warning;
	$var->{'noProjects'} = $i18n->get("no projects") if(scalar(@projects) == 0);
	$var->{'project.loop'} = \@projects;
	
	return $self->processTemplate($var, undef, $self->{_viewTemplate});
}

#-------------------------------------------------------------------

=head2 www_deleteProject 

=cut

sub www_deleteProject {
	my $self = shift;
	#Set Method Helpers
    my ($session,$privilege,$form,$db,$datetime,$i18n,$user) = $self->setSessionVars;

    #Check Privileges
    return $privilege->insufficient unless $self->_userCanManageProjectList($user);
	
	my $projectId = $form->get("projectId");
    
	#Delete Project
	$db->write("delete from PM_project where projectId=?",[$projectId]);
	#Delete Associated Tasks
	$db->write("delete from PM_task where projectId=?",[$projectId]);
	
	return "";
}

#-------------------------------------------------------------------

=head2 www_deleteTask 

=cut

sub www_deleteTask {
   my $self = shift;
   #Set Method Helpers
   my ($session,$privilege,$form,$db,$datetime,$i18n,$user) = $self->setSessionVars;
   
   #Set Local Vars
   my $taskId = $form->get("taskId");
   my $task = $self->getCollateral('PM_task', 'taskId', $taskId);
   my $projectId = $task->{projectId};
   my $taskRank = $task->{sequenceNumber};
	     
   #Check Privileges
   return $privilege->insufficient unless $self->_userCanManageProject($user, $projectId);
   
   #Remove dependencies to this task
   $db->write("update PM_task set dependants=NULL where projectId=? and dependants=?",[$projectId,$taskId]);
   
   #Remove task
   $self->deleteCollateral("PM_task","taskId",$taskId);
   
   #Reorder dependants and tasks
   my $tasks = $db->buildArrayRefOfHashRefs("select * from PM_task where projectId=? order by sequenceNumber",[$projectId]);
   my $taskLen = scalar(@{$tasks});
   #$eh->warn("Task Length = $taskLen");
   foreach my $tsk (@{$tasks}) {
      my $seqNum = $tsk->{sequenceNumber};
      next unless ($seqNum >= $taskRank);
	  #$eh->warn("Fixing task $seqNum");		 
	  my $dependant = $tsk->{dependants};
	  #$eh->warn("Dependant is $dependant");
	  #Only decrement the dependant if it's greater than the rank point of the deleted task
	  if($dependant >= $taskRank){
	     $dependant--;
	  }
	  #$eh->warn("New dependant is $dependant");
	  $db->write("update PM_task set dependants=? where taskId=?",[$dependant,$tsk->{taskId}]);
   }
   $self->reorderCollateral("PM_task","taskId","projectId",$projectId);
   
   return $self->www_viewProject($projectId);
}

#-------------------------------------------------------------------

=head2 www_drawGanttChart 

=cut

sub www_drawGanttChart {
	my $self = shift;
	my $var = {};
	#Set Method Helpers
	my ($session,$privilege,$form,$db,$dt,$i18n,$user) = $self->setSessionVars;
	my $config = $session->config;
	my $style = $session->style;
	my $eh = $session->errorHandler;
	
	#Set up some the task data
	my $projectId = $_[0];
	my $taskList = $_[1] || [];
	my $projVar = $_[2] || {};
	my $calledByAjax = 0;
	
	unless($projectId) {
	   $projectId = $form->get("projectId");
	   $taskList = $db->buildArrayRefOfHashRefs("select * from PM_task where projectId=".$db->quote($projectId)." order by sequenceNumber asc");
	   $calledByAjax = 1;
	}


	#Check Privileges
    return $privilege->insufficient unless $self->_userCanObserveProject($user, $projectId);
	
	my ($dunits,$hoursPerDay) = $db->quickArray("select durationUnits,hoursPerDay from PM_project where projectId=".$db->quote($projectId));

	$var->{'extras'} = $session->url->make_urlmap_work($config->get("extrasURL"))."/wobject/ProjectManager";
	
	#Initialize display settings 
	my $projectDisplay = "weeks";
	my $monthInterval = 5;
	my $dayLimit = 150;
	if($projectDisplay eq "weeks") {
	   $monthInterval = 3;
	   $dayLimit = 60;
	}
	
	#Find start and end months: Set start and end months to always display at least 4 months if display in weeks, 6 months if display in months
	my ($startMonth,$endMonth);
	if(scalar(@{$taskList}) > 0) {
	   ($startMonth) = $db->quickArray("select min(startDate) from PM_task where projectId=".$db->quote($projectId));
	   ($endMonth) = $db->quickArray("select max(endDate) from PM_task where projectId=".$db->quote($projectId));
	   
	   #$eh->warn("Interval is: ".$dt->getDaysInInterval($startMonth,$endMonth));
	   if($dt->getDaysInInterval($startMonth,$endMonth) < 60) {
	      $endMonth = $dt->addToDate($startMonth,0,3);
	   }
	} else {
	   $startMonth = $dt->time;
	   $endMonth = $dt->addToDate($startMonth,0,3);
	}
	
	#$eh->warn($dt->epochToSet($startMonth));
	#$eh->warn($dt->epochToSet($endMonth));
	#Build the loops of weeks and days
	my @monthsLoop = ();
	my @daysLoop = ();
	
	if($projectDisplay eq "weeks") {
	   #Week View Below
	   my $dayOfWeek = $dt->getDayOfWeek($startMonth);
       my $sundayAdjust = (0 - ($dayOfWeek % 7));

       $startMonth = $dt->addToDateTime($startMonth,0,0,$sundayAdjust,1);
	   
	   my @days = ( 
	                $i18n->get("sunday label"),
	                $i18n->get("monday label"),
	                $i18n->get("tuesday label"),
					$i18n->get("wednesday label"),
					$i18n->get("thursday label"),
					$i18n->get("friday label"),
					$i18n->get("saturday label"),
				   ); 
	   #$eh->warn($dt->epochToSet($sundayOfFirstWeek));
	   #$eh->warn($dt->epochToSet($endMonth));
	   my $datecounter = $startMonth;
	   my $counter = 0;
	   while($datecounter <= $endMonth || $counter++ == 1000) {
	      my $hash = {};
		  $hash->{'month.name'} = $dt->epochToHuman($datecounter,"%C %d, %Y");
		  $hash->{'month.colspan'} = 7; 
		  push(@monthsLoop,$hash);
		  #Add 7 days for this week
		  foreach (@days) {
		     push(@daysLoop,{'day.number' => $_ });
		  }
		  #$eh->warn($dt->epochToSet($datecounter));
		  $datecounter = $dt->addToDateTime($datecounter,0,0,7);
	   }
	
	} else {
	   #Months View Below
	   my $junk;
	  ($startMonth,$junk) = $dt->monthStartEnd($startMonth);
	  ($junk,$endMonth) = $dt->monthStartEnd($endMonth);
	   my $numMonths = ($dt->monthCount($startMonth,$endMonth) + 1);
	
	   for(my $i = 0; $i < $numMonths; $i++) {
	      my $hash = {};
	      my $month = $dt->addToDateTime($startMonth,0,$i,0,1);
	   
	      $hash->{'month.name'} = $dt->epochToHuman($month,"%C %Y");
	      $self->_addDaysForMonth(\@daysLoop,$hash,$month);      
	      push(@monthsLoop,$hash);
	   }
	   
	}
	
	$var->{'months.loop'} = \@monthsLoop;
	$var->{'days.loop'} = \@daysLoop;
	
	#Build tasks and divs
	my @taskCount = ();
	my @taskDiv = ();
	my $taskCount = 0;
	
	my $pixelSize = ($projectDisplay eq "weeks")?23:3.2857;
	
	$var->{'project.task.array'} = "{\n";
	
	my $taskHash = {};
	foreach my $task (@{$taskList}) {
		my $hash = {};
		my $id = $task->{taskId};
		my $seq = $task->{sequenceNumber};
		my $taskType = $task->{taskType};
		my $startDate = $task->{startDate};
		my $endDate = $task->{endDate};
		my $duration = $task->{duration};
		my $lagTime = $task->{lagTime};
		my $totalDuration = $duration + $lagTime;
		my $predecessor = $task->{dependants};
		$self->_doGanttTaskResourceDisplay($hash, $task);

		if ($dunits eq 'hours') {
			foreach ($duration, $lagTime, $totalDuration) {
				$_ /= $hoursPerDay;
			}
		}

		my ($durationFloor, $lagTimeFloor, $totalDurationFloor) =
		    map {floor($_)} ($duration, $lagTime, $totalDuration);
		
		# Each day is 23 pixels so calculate the days and round
		$hash->{'task.div.width'} = int(($totalDuration * $pixelSize));

		# Lerp RGB: probably not the best way, but it's good enough.
		my @zerolag_color = (0x7a, 0xb7, 0xe9);
		my @alllag_color = (0x7a, 0xb7, 0xe9);
		$hash->{'task.div.color'} = sprintf "#%02x%02x%02x",
		    ($totalDuration > 0)? do {
			    my $lerp = $lagTime / $totalDuration;
			    map { $zerolag_color[$_] +
				      ($alllag_color[$_] - $zerolag_color[$_]) * $lerp }
				(0..2);
		    } : @zerolag_color;

		$hash->{'task.div.label.left'} = $hash->{'task.div.width'} + 3;
		$hash->{'task.div.label.left'} = 12 if $hash->{'task.div.label.left'} < 12;
		
		my $predDayPart = 0;
		my $predEndDate = "";
		if($predecessor) {
		   my $pred = $taskHash->{$predecessor}; 
		   $predEndDate = $pred->{endDate};
		   #Get the day part of the predecessor
		   $predDayPart = $pred->{dayPart};
		   if($startDate eq $predEndDate && $predDayPart > 0) {
		      #The previous task took up a part of the same  day.  Add the additional day part to get the correct duration
			   $duration += $predDayPart;
			   $totalDuration += $predDayPart;
			   $durationFloor = floor($duration);
			   $totalDurationFloor = floor($totalDuration);
		   }
		   
		}
		
		#Adjust top for MSIE
		my $isMSIE = ($session->env->get("HTTP_USER_AGENT") =~ /msie/i);
		my $divTop =  $isMSIE ? 45 : 45;
		#Start at 45 px and add 20px as the start of the new task
		#Set the propert mutiplier
		my $multiplier = $isMSIE ? 22 : 20;
		$hash->{'task.div.top'} = $divTop + ($multiplier*$taskCount);
		
		my $daysFromStart = $dt->getDaysInInterval($startMonth,$startDate);
		#Add day part of predecessor if necessary
		#$eh->warn("Task $seq is currently $daysFromStart days from the first day on ".$dt->epochToHuman($startDate));
		my $daysLeft = $daysFromStart;
		#Only adjust for predecessor if the start date of the task falls on the same day as it's predecessors end date
		if($startDate eq $predEndDate) {
		   $daysLeft += $predDayPart;
		   #$eh->warn("Adjusting this by $predDayPart days");
		}
		$hash->{'task.div.left'} = int(($daysLeft * $pixelSize));  #Each day is 23 pixels so calculate the days and round
		#$eh->warn("Starts at: $daysLeft * $pixelSize :".$hash->{'task.div.left'});
		
		# Buggo.  Refactor.
		$hash->{'task.isUntimed'} = ($task->{taskType} ne 'timed');
		$hash->{'task.hasDuration'} = ($task->{taskType} ne 'milestone');
		
		push(@taskDiv, $hash);
		push(@taskCount, { 'task.counter' => $task->{sequenceNumber} } );  
		$var->{'project.task.array'} .= ",\n" if($taskCount > 0);
	    $startDate = $dt->epochToSet($startDate);
		$endDate = $dt->epochToSet($endDate);
		my $rduration = $task->{duration};
		
		#Adjust duration of days to only include the part of the day used
		#$eh->warn("day part is being set to: $duration - ".floor($duration)." : ".($duration-floor($duration)));
        $duration = $duration - floor($duration);
		
		$hash->{'task.div.percentComplete'} = $task->{percentComplete} || 0;
		$var->{'project.task.array'} .= qq|"$seq": { "id":"$id" ,"start":"$startDate" ,"end":"$endDate", "duration":"$rduration", "dayPart":"$duration", "lagTime":"$lagTime", "predecessor":"$predecessor", "type":"$taskType" }|;
		$taskCount++;
		   
		$taskHash->{$seq} = { 
				     'startDate'=>$task->{startDate}, 
				     'endDate'=>$task->{endDate}, 
				     'duration'=>$task->{duration}, 
				     'lagTime'=>$task->{lagTime},
				     'dayPart'=>$duration
				    };
	}
	
	$var->{'task.count.loop'} = \@taskCount;
	$var->{'task.div.loop'} = \@taskDiv;
	$var->{'project.task.array'} .= "\n}";
	
	#Set Gantt Chart template vars
	my $cols = scalar(@daysLoop);
	$var->{'total.colspan'} = $cols;	
	$var->{'scrollWidth'} = $cols * 23;
	
	#Set project template vars
	$var->{'project.table.width'} = $projVar->{'project.table.width'} = 560 + $var->{'scrollWidth'};
	my $scrollWidth = (1- (560 / $projVar->{'project.table.width'})) * 100;
	$var->{'project.scroll.percentWidth'} = $projVar->{'project.scroll.percentWidth'} =  sprintf("%2.2f",$scrollWidth); 	
	
	return $self->processTemplate($var,$self->ganttChartTemplateId);
}

#-------------------------------------------------------------------

=head2 www_editProject 

=cut

sub www_editProject {
   my $self = shift;
   #Set Method Helpers
   my ($session,$privilege,$form,$db,$datetime,$i18n,$user) = $self->setSessionVars;

   #Check Privileges
   return $privilege->insufficient unless $self->_userCanManageProjectList($user);
   
   #Set Local Vars
   my $projectId = $form->get("projectId"); 
   my $project = $db->quickHashRef("select * from PM_project where projectId=?",[$projectId]);
   my $addEditText = ($projectId eq "new")?$i18n->get("create project"):$i18n->get("edit project");
   
   #Build Form
   my $f = WebGUI::HTMLForm->new($self->session,-action=>$self->getUrl, -extras=>q|onsubmit="return checkform(this);"|);
   $f->hidden( 
			    -name=>"func",
				-value=>"editProjectSave" 
   );
   $f->hidden( 
               -name=>"projectId", 
               -value=>$projectId 
   );
   $f->readOnly(
		-label=>$i18n->get("project id"),
		-hoverHelp => $i18n->get('project name hoverhelp'),
		-value=>$projectId
   );
   $f->text(
		   -name  => "name",
		   -value => $form->get("name") || $project->{name},
		   -hoverHelp => $i18n->get('project name hoverhelp'),
		   -label => $i18n->get('project name label')
   );
   $f->HTMLArea(
		-name  => "description",
		-value => $form->get("description") || $project->{description},
		-hoverHelp => $i18n->get('project description hoverhelp'),
		-label => $i18n->get('project description label')
   );
   $f->group(
         -name=> "projectManager",
		 -value=> $form->get("projectManager") || $project->{projectManager} || $self->groupToAdd,
		 -hoverHelp=> $i18n->get('project manager hoverhelp'),
		 -label => $i18n->get('project manager label')
   );
   $f->group(
         -name=> "projectObserver",
		 -value=> $form->get("projectObserver") || $project->{projectObserver} || '7',
		 -hoverHelp=> $i18n->get('project observer hoverhelp'),
		 -label => $i18n->get('project observer label')
   );
   
   my $dunitValue = $form->get("durationUnits") || $project->{durationUnits} || "hours";
   $f->selectBox(
          -name=>"durationUnits",
		  -value=> $dunitValue,
		  -options=>$self->_getDurationUnitHash,
		  -hoverHelp => $i18n->get('duration units hoverhelp'),
		  -label => $i18n->get('duration units label'),
		  -extras=> q|onchange="if(this.value == 'hours'){ document.getElementById('hoursper').style.display='' } else { document.getElementById('hoursper').style.display='none' }"|
   );
   
  
   
   my $hpdLabel = $i18n->get('hours per day label');
   my $hpdHoverHelp = $i18n->get('hours per day hoverhelp');
   my $hpdValue = $form->get("hoursPerDay") || $project->{hoursPerDay} || "8.0";
   my $hpdStyle = ($dunitValue eq "days"?"display:none":"");
   
   my $html = qq|
   <tr id="hoursper" style="$hpdStyle">
      <td class="formDescription" valign="top" style="width: 180px;">
	     <div class="wg-hoverhelp">$hpdHoverHelp</div>
         <label for="hoursPerDay_formId">$hpdLabel</label>
	  </td>
	  <td valign="top" class="tableData"  style="width: *;">
	     <input id="hoursPerDay_formId" type="text" name="hoursPerDay" value="$hpdValue" size="11" maxlength="14" />
	  </td>
   </tr>|;
   $f->raw($html);		
   
   $f->float (
           -name=>"targetBudget",
		   -value=> $form->get("targetBudget") || $project->{targetBudget} || "0.00",
		   -hoverHelp => $i18n->get('target budget hoverhelp'),
		   -label=> $i18n->get('target budget label')
   );
   $f->submit( 
           -extras=>"name='subbutton'",
		   -value=>$addEditText
   );
   
   my $jscript = qq|
      <script language="JavaScript">
	     function checkform(form) {		 
		    if(form.name.value == ""){ 
		       alert("You must enter a project name");
			   form.subbutton.value='$addEditText';
			   return false;
	        }
		    return true;
	     }
	  </script>
   |;
   
   my $errors = $self->processErrors($_[0]);
   
   my $output = $jscript."\n".$errors.$f->print;
   return $self->getAdminConsole->render($output,$addEditText);
}

#-------------------------------------------------------------------

=head2 www_editProjectSave 

=cut

sub www_editProjectSave {
	my $self = shift;
    #Set Method Helpers
    my ($session,$privilege,$form,$db,$dt,$i18n,$user) = $self->setSessionVars;
    my $eh = $session->errorHandler;
	
    #Check Privileges
    return $privilege->insufficient unless $self->_userCanManageProjectList($user);
    
	my $now = $dt->time();
	my $uid = $user->userId;
	my $projectId = $form->process("projectId","hidden");
	my $origProjId = $projectId;
	
	#Set Properties
	my $props = {};
	$props->{projectId} = $projectId;
	$props->{name} = $form->process("name","text");
	$props->{description} = $form->process("description","HTMLArea");
	$props->{projectManager} = $form->process("projectManager","group");
	$props->{projectObserver} = $form->process("projectObserver","group");
	$props->{durationUnits} = $form->process("durationUnits","selectBox");
	$props->{hoursPerDay} = $form->process("hoursPerDay","float") || 8.0;
	$props->{targetBudget} = $form->process("targetBudget","float");
    if($projectId eq "new") {
	   $props->{creationDate} = $now;
	   $props->{createdBy} = $uid;
	}
    $props->{lastUpdateDate} = $now;
    $props->{lastUpdatedBy} = $uid;
	#Process Errors	
	my @errors = ();
	push(@errors,"You must enter a project name") unless ($props->{name});
    if(scalar(@errors) > 0) {
       return $self->www_editProject(\@errors);
    }
	
	#Save the extended project data
	$projectId = $self->setCollateral("PM_project","projectId",$props,0,1);
	
	if($origProjId eq "new") {
	   #Create Project Start Milestone Task for new projects
	   $props = {};
	   $props->{taskId} = "new";
	   $props->{projectId} = $projectId;
	   $props->{taskName} = $i18n->get("project start task label");
	   $props->{duration} = 0;
	   $props->{lagTime} = 0;
	   $props->{startDate} = $dt->time();
	   $props->{endDate} = $dt->time();
	   $props->{taskType} = 'milestone';
       $props->{creationDate} = $now;
	   $props->{createdBy} = $uid;
       $props->{lastUpdateDate} = $now;
       $props->{lastUpdatedBy} = $uid;
	   
	   #Save the extended task data
	   my $taskId = $self->setCollateral("PM_task","taskId",$props,1,0,"projectId",$projectId);
    }
	
	return $self->www_viewProject($projectId);
}


#-------------------------------------------------------------------

=head2 www_editTask 

=cut

sub www_editTask {
   my $self = shift;
   my $var = {};
   #Set Method Helpers
   my $session   = $self->session;
   my $privilege = $session->privilege;
   my $form      = $session->form;
   my $db        = $session->db;
   my $dt        = $session->datetime;
   my $config    = $session->config;
   my $i18n      = $self->i18n;
   my $user      = $session->user;
   
   #Set variables from form data
   my $projectId = $form->get("projectId");
   my $taskId    = $form->get("taskId") || "new";
  
   #Get the project data
   my $project   = $self->getCollateral('PM_project', 'projectId', $projectId);
   
   #Get the task data
   my $task      = $self->getCollateral('PM_task', 'taskId', $taskId);
   
   #Check Privileges
   return $privilege->insufficient unless $self->_userCanManageProject($user, $projectId);
   
   my $taskType = ($task->{taskType} || 'timed');
   my $seq = $task->{sequenceNumber};
   my $disabledIfUntimed = ($taskType eq 'timed')? "" : " disabled";
   my $disabledIfMilestone = ($taskType ne 'milestone')? "" : " disabled";
   
   #Build the form header
   $var->{'form.header'} .= WebGUI::Form::formHeader($session,{
				action=>$self->getUrl,
				extras=>q|name="editTaskForm"|
				});
   $var->{'form.header'} .= WebGUI::Form::hidden($session, {
				-name=>"func",
				-value=>"editTaskSave"
				});
   $var->{'form.header'} .= WebGUI::Form::hidden($session, {
				-name=>"projectId",
				-value=>$projectId
				});
   $var->{'form.header'} .= WebGUI::Form::hidden($session, {
				-name=>"taskId",
				-value=>$taskId
				});
   $var->{'form.header'} .= WebGUI::Form::hidden($session, {
				-name=>"insertAt",
				-value=>$form->get("insertAt")
				});

   my ($startEpoch, $endEpoch) = $db->quickArray('SELECT startDate, startDate FROM PM_task WHERE projectId = ? ORDER BY sequenceNumber LIMIT 1', [$projectId]);
   my $dependant = $task->{dependants};
   #my $duration = $task->{duration} || (($taskType eq 'timed')? (($project->{durationUnits} eq 'hours')? $project->{hoursPerDay} : 1) : 0);
   my $duration = $task->{duration} || 0;   

   $startEpoch = $endEpoch = time unless defined $startEpoch and defined $endEpoch;
   $startEpoch = $task->{startDate} if $task->{startDate};
   $endEpoch = $task->{endDate} if $task->{endDate};
## Magic number = bad
   $endEpoch += 86400 if $taskType eq 'timed' and !$task->{duration} and !$task->{endDate};
   my ($start, $end) = ($dt->epochToSet($startEpoch), $dt->epochToSet($endEpoch));

   # Set some hidden variables to make it easy to reset data in javascript
   $var->{'form.header'} .= WebGUI::Form::hidden($session, {
				-name=>"orig_duration",
				-value=>$duration
				});
   $var->{'form.header'} .= WebGUI::Form::hidden($session, {
				-name=>"orig_start",
				-value=>$start
				});
   $var->{'form.header'} .= WebGUI::Form::hidden($session, {
				-name=>"orig_end",
				-value=>$end
				}); 
   $var->{'form.header'} .= WebGUI::Form::hidden($session, {
				-name=>"orig_dependant",
				-value=>$dependant
				});
   $var->{'form.name'} = WebGUI::Form::text($session,{
				-name=>"name",
				-value=>$task->{taskName}, 
				-extras=>q|style="width:95%;"|
				});

   $var->{'form.seqNum'} = WebGUI::Form::hidden($session, {
							   -name => "seqNum",
							   -value => $seq,
							  });
   
   my $durationEvents = qq|onchange="durationChanged(this.form, '', true)"  onblur="if (this.value == 0) durationChanged(this.form, '', true)"|;
   my $startDateEvents = qq|onblur="startDateChanged(this.form, '', true)"|;
   my $endDateEvents = qq|onblur="endDateChanged(this.form, '', true)"|;

   $var->{'form.duration'} = WebGUI::Form::float($session,{
				-name => "duration",
				-value => $duration,
				-extras => qq|style="width:70%;" $durationEvents $disabledIfMilestone|
				});
   $var->{'form.duration.units'} = $self->_getDurationUnitHashAbbrev->{$project->{durationUnits}};

   $var->{'form.lagTime'} = WebGUI::Form::float($session,{
                                -name => "lagTime",
				-value => (($taskType eq 'timed')? $task->{lagTime} : 'N/A'),
				-extras => qq|style="width:70%;" $durationEvents $disabledIfUntimed|
							 });
   $var->{'form.lagTime.units'} = $self->_getDurationUnitHashAbbrev->{$project->{durationUnits}};

   $var->{'form.start'} = WebGUI::Form::text($session,{
				-name=>"start",
				-value=>$start,
				-size=>"10",
				-maxlength=>"10",
				-extras=>qq|style="width:88%;" $startDateEvents|
				});

   $var->{'form.end'} = WebGUI::Form::text($session,{
				-name=>"end",
				-value=>$end,
				-size=>"10",
				-maxlength=>"10",
				-extras=>qq|style="width:88%;" $endDateEvents $disabledIfUntimed|
				});

   $var->{'form.dependants'} = WebGUI::Form::integer($session,{
				-name=>"dependants",
				-value=>$dependant || "",
				-defaultValue=>"",
				-size=>4,
				-maxlength=>10,
				-extras=>qq|style="width:50%;" onchange="predecessorChanged(this.form, '', true)"|
				});

   my @resources = @{$self->_resourceListOfTask($taskId)};
   my ($searchUserUrlHtml, $searchGroupUrlHtml) = map {
	   my $kind = $_;
	   my $exclude = $self->session->url->escape(join ';', map {$_->{resourceId}} grep {$_->{resourceKind} eq $kind} @resources);
	   my $func = $kind.'SearchPopup';
	   WebGUI::HTML::format($self->getUrl("func=$func;callback=taskEdit_queueAddResource;exclude=$exclude"), 'text');
   } (qw/user group/);

   $var->{'form.addUser.id'} = 'taskEdit_resourceList_addUser_a';
   $var->{'form.addUser.link'} = $searchUserUrlHtml;
   $var->{'form.addUser.text'} = $i18n->get('user add popup hover');
   
   $var->{'form.addGroup.id'} = 'taskEdit_resourceList_addGroup_a';
   $var->{'form.addGroup.link'} = $searchGroupUrlHtml;
   $var->{'form.addGroup.text'} = $i18n->get('group add popup hover');

   $var->{'form.resourceDiv'} =
       '<div id="taskEdit_resourceList_div">'.$self->_innerHtmlOfResources(@resources).'</div>';

   my %taskTypeOptions;
   tie %taskTypeOptions, 'Tie::IxHash';
   foreach my $option (qw/timed progressive milestone/) {
	   $taskTypeOptions{$option} = $i18n->get("taskType $option label");
   }

   $var->{'form.taskType'} = WebGUI::Form::radioList($session, {
				-name=>'taskType',
				-vertical=>0,
				-options=>\%taskTypeOptions,
			        -defaultValue=>$taskType,
				-extras=>q|onclick="configureForTaskType(this.form)"|,
				});
   $var->{'form.percentComplete'} = WebGUI::Form::float($session, {
				-name => "percentComplete",
				-value => (($taskType eq 'timed')? $task->{percentComplete} : 'N/A'),
				-extras => $disabledIfUntimed
				});
   $var->{'form.save'} = WebGUI::Form::submit($session, { 
				-value=>"Save", 
				-extras=>q|name="subbutton"| 
				});
   $var->{'form.footer'} = WebGUI::Form::formFooter($session);

   $var->{'extras'} = $session->url->make_urlmap_work($config->get("extrasURL"));
   $var->{'assetExtras'} = $session->url->make_urlmap_work($config->get("extrasURL")).'/wobject/ProjectManager';
   
   $var->{'task_name_label'}        = $i18n->get('task name label');
   $var->{'task_start_label'}       = $i18n->get('task start label');
   $var->{'task_finish_label'}      = $i18n->get('task end label');
   $var->{'task_duration_label'}    = $i18n->get('task duration label');
   $var->{'task_lagTime_label'}     = $i18n->get('task lag time label');
   $var->{'task_predecessor_label'} = $i18n->get('task predecessor edit label');
   $var->{'task_complete_label'}    = $i18n->get('project complete label');
   $var->{'task_resource_label'}    = $i18n->get('task resource label');
   $var->{'task_save_label'}        = $i18n->get('task save label');

   return $self->processTemplate($var,$self->editTaskTemplateId);
}

#-------------------------------------------------------------------

=head2 www_editTaskSave 

=cut

sub www_editTaskSave {
   my $self = shift;
   my $var = {};
   #Set Method Helpers
   my ($session,$privilege,$form,$db,$dt,$i18n,$user) = $self->setSessionVars;
   my $config = $session->config;
   my $eh = $session->errorHandler;

   my $projectId = $form->get("projectId");
   my $project = $db->quickHashRef("select * from PM_project where projectId=".$db->quote($projectId));

   #Check Privileges
   return $privilege->insufficient unless $self->_userCanManageProject($user, $projectId);
   
   my $taskType = $form->process("taskType", "radioList");
   my ($isMilestone, $isUntimed) = ($taskType eq 'milestone', $taskType ne 'timed');
   my $isProgressive = ($taskType eq 'progressive');
   
   my $props = {};
   $props->{taskId} = $form->process("taskId","hidden");
   $props->{projectId} = $projectId;
   $props->{taskName} = $form->process("name","text");
   $props->{duration} = $isMilestone? 0 : $form->process("duration","text");
   $props->{lagTime} = $isUntimed? 0 : $form->process("lagTime","text");
   $props->{startDate} = $form->process("start","date");
   $props->{endDate} = $isMilestone? $props->{startDate} :
       $isProgressive? undef : $form->process("end","date");
   $props->{dependants} = $form->process("dependants","selectBox") unless $isUntimed;
   $props->{taskType} = $taskType;
   my @resourceSpecs = $form->process("resources","hiddenList");
   $props->{percentComplete} = $isUntimed? 0 : $form->process("percentComplete","float");

   unless (defined $props->{endDate}) {
	   my $totalDuration = $props->{duration} + $props->{lagTime};
	   my $totalDurationDays = ($project->{durationUnits} eq 'days')? $totalDuration : ($totalDuration / $project->{hoursPerDay});
	   $props->{endDate} = $props->{startDate} + $totalDurationDays*86400;
   }
   
   my $now = $dt->time();
   if($props->{taskId} eq "new") {
	   $props->{creationDate} = $now;
	   $props->{createdBy} = $user->userId;
   }
   $props->{lastUpdateDate} = $now;
   $props->{lastUpdatedBy} = $user->userId;

   # Save the extended task data
   my $taskId = $self->setCollateral("PM_task","taskId",$props,1,0,"projectId",$projectId);
   $self->deleteCollateral('PM_taskResource', 'taskId', $taskId);
   foreach my $resourceSpec (@resourceSpecs) {
	   my ($resourceKind, $resourceId) = split / /, $resourceSpec, 2;
	   $self->setCollateral('PM_taskResource', 'taskResourceId', {taskId => $taskId, resourceKind => $resourceKind, resourceId => $resourceId}, 1, 0, 'taskId', $taskId);
   }

   #Reorder tasks if task is inserted
   my $insertAt = $form->get("insertAt");
   if($insertAt) {
      #$eh->warn("Inserting at $insertAt");
	  my $tasks = $db->buildArrayRefOfHashRefs("select * from PM_task where projectId=? order by sequenceNumber",[$projectId]);
	  my $taskLen = scalar(@{$tasks});
	  #$eh->warn("Task Length = $taskLen");
	  foreach my $task (@{$tasks}) {
	     my $seqNum = $task->{sequenceNumber};
		 next unless ($seqNum >= $insertAt);
		 #$eh->warn("Fixing task $seqNum");		 
		 my $newSeq = $seqNum + 1;
		 if($seqNum eq $taskLen) {
		    $newSeq = $insertAt;
		 }
		 #$eh->warn("New seqNum is $newSeq");
		 my $dependant = $task->{dependants};
		 #$eh->warn("Dependant is $dependant");
		 #Only increment the dependant if it's greater than or equal to the insertAt point
		 if($dependant >= $insertAt){
		    $dependant++;
		 }
		 #$eh->warn("New dependant is $dependant");
		 $db->write("update PM_task set sequenceNumber=?, dependants=? where taskId=?",[$newSeq,$dependant,$task->{taskId}]);
	  }
	  $self->reorderCollateral("PM_task","taskId","projectId",$projectId);
   }
  
   $self->updateProject($projectId);
   $self->_clobberImproperDependants($projectId);
   $self->_updateDependantDates($projectId);
   
   return $self->www_viewProject($projectId,$taskId);
}

#-------------------------------------------------------------------

=head2 www_groupSearchPopup 

=cut

sub www_groupSearchPopup {
	my $self = shift;
	my %args = (func => 'groupSearchPopup',
		    i18nprefix => 'group add popup',
		    queryCallback => sub { $self->_groupSearchQuery(@_) },
		   );
	$self->_resourceSearchPopup(%args);
}

#-------------------------------------------------------------------

=head2 www_innerHtmlOfResources 

=cut

sub www_innerHtmlOfResources {
	my $self = shift;
	my @resources = map {
		my ($resourceKind, $resourceId) = split / /, $_, 2;
		{ resourceKind => $resourceKind, resourceId => $resourceId }
	} split /\;/, $self->session->form->param('resources');
	return $self->_innerHtmlOfResources(@resources);
}

#-------------------------------------------------------------------

=head2 www_saveExistingTasks 

=cut

sub www_saveExistingTasks {
   my $self = shift;
   my $var = {};
   #Set Method Helpers
   my ($session,$privilege,$form,$db,$dt,$i18n,$user) = $self->setSessionVars;
   my $config = $session->config;
   
   my $projectId = $form->get("projectId");
   my $project = $db->quickHashRef("select * from PM_project where projectId=".$db->quote($projectId));
   
   #Check Privileges
   return $privilege->insufficient unless $self->_userCanManageProject($user, $projectId);
   
   my $tasks = $db->buildArrayRefOfHashRefs("select * from PM_task where projectId=".$db->quote($projectId)." order by sequenceNumber asc");
  
   #Save each row
   foreach my $task (@{$tasks}) {
	   my $taskType = $task->{taskType};
	   my $isUntimed = ($taskType ne 'timed');
	   my $props = {};
	   my $taskId = $task->{taskId};
	   $props->{taskId} = $taskId;
	   $props->{projectId} = $projectId;
	   $props->{startDate} = $form->process("start_$taskId","date");
	   $props->{endDate} = $form->process("end_$taskId","date");
	   $props->{dependants} = $form->process("dependants_$taskId","selectBox"); 
	   unless ($isUntimed) {
		   $props->{duration} = $form->process("duration_$taskId","float");
		   $props->{lagTime} = $form->process("lagTime_$taskId","float");
	   }

	   $props->{lastUpdateDate} = $dt->time();
	   $props->{lastUpdatedBy} = $user->userId;

	   $self->setCollateral("PM_task","taskId",$props,1,0,"projectId",$projectId);
   }
   
   $self->updateProject($projectId);
   $self->_updateDependantDates($projectId);
   return $self->www_drawGanttChart();
}

#-------------------------------------------------------------------

=head2 www_userSearchPopup 

=cut

sub www_userSearchPopup {
	my $self = shift;

	my %args = (func => 'userSearchPopup',
		    i18nprefix => 'user add popup',
		    queryCallback => sub { $self->_userSearchQuery(@_) },
		   );
	$self->_resourceSearchPopup(%args);
}

#-------------------------------------------------------------------

=head2 www_viewProject 

=cut

sub www_viewProject {
	my $self      = shift;
	my $var       = {};
    
	#Declare method variables
	my $session     = $self->session;
    my $privilege   = $session->privilege;
    my $form        = $session->form;
    my $db          = $session->db;
    my $dt          = $session->datetime;
    my $i18n        = $self->i18n;
    my $user        = $session->user;
    my $config      = $session->config;
	my $style       = $session->style;
	my $eh          = $session->errorHandler;
	my $projectId   = shift || $form->get("projectId");
		
    #Check Privileges
	return $privilege->insufficient unless $self->_userCanObserveProject($user, $projectId);
	
    #Set extras template variables
    my $extras            = $session->url->make_urlmap_work($config->get("extrasURL"));
	my $assetExtras       = $session->url->make_urlmap_work($config->get("extrasURL"))."/wobject/ProjectManager";	
    $var->{'extras'     } = $assetExtras;
	$var->{'extras.base'} = $extras;
    
	
	#Set page styles
	$style->setLink($assetExtras."/subModal.css", { 
                        rel=>"stylesheet", 
                        type=>"text/css", 
                    }
    );
    $style->setLink($assetExtras."/taskEdit.css", {
                        rel=>"stylesheet",
                        type=>"text/css",
                    }
    );
    $style->setLink($assetExtras."/cMenu.css",{
                        rel=>"stylesheet",
                        type=>"text/css",
                    }
    );
	
    #Set page scripts
	$style->setScript($assetExtras."/cMenu.js",{ 
                          type=>"text/javascript",
                      }
    );
    
	$style->setScript($extras."/contextMenu/contextMenu.js",{ 
                          type=>"text/javascript" 
                     }
    );
	
    $self->session->style->setScript(
      $self->session->url->extras('yui/build/yahoo/yahoo-min.js'),
      { type=>'text/javascript' }
    );
    
    $self->session->style->setScript(
      $self->session->url->extras('yui/build/event/event-min.js'),
      { type=>'text/javascript' }
    );
    
    $self->session->style->setScript(
      $self->session->url->extras('yui/build/dom/dom-min.js'),
      { type=>'text/javascript' }
    );
   
    $self->session->style->setScript(
      $self->session->url->extras('yui/build/connection/connection-min.js'),
      { type=>'text/javascript' }
    );
    
    $self->session->style->setScript(
      $self->session->url->extras('yui/build/container/container-min.js'),
      { type=>'text/javascript' }
    );
    
    $style->setScript($assetExtras."/modal.js",{ 
                          type=>"text/javascript" 
                      }
    );
    
    #$self->session->style->setScript(
    #  $self->session->url->extras('yui-webgui/build/datepicker/datepicker.js'),
    #  { type=>'text/javascript' }
    #);

	$style->setScript($assetExtras."/projectDisplay.js",{ 
                          type=>"text/javascript" 
                      }
    );
	$style->setScript($assetExtras."/taskEdit.js",{ 
                          type=>"text/javascript" 
                      }
    );
	
	#Get Project Data
    my $sql          = q|select * from PM_project where projectId=?|;   
	my $project      = $db->quickHashRef($sql,[$projectId]);
	
    #Get User Privileges
    my $canEditTasks = $self->_userCanManageProject($user, $projectId);
	
    #Set Duration Units
    my $dunits = $self->_getDurationUnitHashAbbrev->{$project->{durationUnits}};
	
	#Set some variables for use by Java Script
	$var->{'project.durationUnits'} = $dunits;
	$var->{'project.hoursPerDay'  } = $project->{hoursPerDay} || "0";
	
	#Set Task Table Lables	
	$var->{'task.name.label'      } = $i18n->get("task name label");
	$var->{'task.duration.label'  } = $i18n->get("task duration label");
	$var->{'task.start.label'     } = $i18n->get("task start label");
	$var->{'task.end.label'       } = $i18n->get("task end label");
	$var->{'task.dependants.label'} = $i18n->get("task dependant label");
	
	# JavaScript Alert Errors for Tasks
	$var->{'form.name.error'               } = $i18n->get("task name error");
	$var->{'form.start.error'              } = $i18n->get("task start error");
	$var->{'form.end.error'                } = $i18n->get("task end error");
	$var->{'form.greaterthan.error'        } = $i18n->get("task greaterthan error");
	$var->{'form.previousPredecessor.error'} = $i18n->get("task previousPredecessor error");
	$var->{'form.samePredecessor.error'    } = $i18n->get("task samePredecessor error");
	$var->{'form.noPredecessor.error'      } = $i18n->get("task noPredecessor error");
	$var->{'form.invalidMove.error'        } = $i18n->get("task invalidMove error");
	$var->{'form.untimedPredecessor.error' } = $i18n->get("task untimedPredecessor error");
	
    #Get Tasks
    $sql = "select * from PM_task where projectId=? order by sequenceNumber asc";
    my $data = $db->buildArrayRefOfHashRefs($sql,[$projectId]);
    
    #Build Task Data
	my @taskList = ();
    
	my $count = 0;
	foreach my $row (@{$data}) {
	   my $hash      = {};
	   my $seq       = $row->{sequenceNumber};
	   my $id        = $row->{taskId};
	   my $taskType  = $row->{taskType};
	   my $isUntimed = ($taskType ne 'timed');
	   my $startDate = $dt->epochToSet($row->{startDate});
	   my $endDate   = $dt->epochToSet($row->{endDate});
	   my $duration  = $row->{duration};
	   my $lagTime   = $row->{lagTime};
	   
	   $hash->{'task.number'} = $seq;
	   $hash->{'task.row.id'} = $id;
	   $hash->{'task.name'  } = $row->{taskName};
	   	  
	   if($canEditTasks) {
		   my $suffix = '_'.$id;
           
		   $hash->{'task.start'} = WebGUI::Form::text($session,{
                name=>'start'.$suffix,
			    value=>$startDate,
			    size=>"10",
			    maxlength=>"10",
			    extras=>qq<class="taskdate" onchange="startDateChanged(this.form, '$suffix', false);">
            });
          
		  $hash->{'task.start'} .= WebGUI::Form::hidden($session,{
			-name=>'orig_start'.$suffix,
			-value=>$startDate,
			});

		  $hash->{'task.dependants'} = WebGUI::Form::integer($session,{
			-name=>'dependants'.$suffix,
			-value=>$row->{dependants} || "",
			-defaultValue=>"", 
			-extras=>qq|class="taskdependant" onchange="predecessorChanged(this.form, '$suffix', false);"|
			});
		  $hash->{'task.dependants'} .= WebGUI::Form::hidden($session,{
			-name=>'orig_dependants'.$suffix,
			-value=>$row->{dependants},
			});

		  $hash->{'task.end'} = WebGUI::Form::text($session,{
            -name=>'end'.$suffix,
			-value=>$endDate,
			-size=>"10",
		    -maxlength=>"10",
			-extras=>qq|class="taskdate" onblur="endDateChanged(this.form, '$suffix', false);"|
		  });
		  
          $hash->{'task.end'} .= WebGUI::Form::hidden($session,{
			-name=>'orig_end'.$suffix,
			-value=>$endDate,
			});

		  # Don't display duration for untimed tasks.
		  if ($isUntimed) {
			$hash->{'task.duration'} = $row->{duration};
			 $hash->{'task.duration'} .= WebGUI::Form::hidden($session,{
				-name=>'duration'.$suffix,
				-value=>$duration,
				});
		  } 
          else {
			  $hash->{'task.duration'} = WebGUI::Form::float($session,{
				-name=>'duration'.$suffix,
				-value=>$duration, 
				-extras=>qq|class="taskduration" onchange="durationChanged(this.form, '$suffix', false);" |
				});
              $hash->{'task.duration'} .= WebGUI::Form::hidden($session,{
                -name=>'orig_duration'.$suffix,
                -value=>$duration,
			    });
			 
	      }
	      $hash->{'task.lagTime'} = WebGUI::Form::hidden($session,{
								       -name => 'lagTime'.$suffix,
								       -value => $lagTime,
								      });
		   $hash->{'task.taskType'} = WebGUI::Form::hidden($session, {
									      -name => 'taskType'.$suffix,
									      -value => $taskType,
									      });
		   $hash->{'task.seqNum'} = WebGUI::Form::hidden($session, {
									    -name => 'seqNum'.$suffix,
									    -value => $seq
									   });
	   } 
       else {
	      $hash->{'task.duration'   } = $duration;
	      $hash->{'task.start'      } = $startDate;
	      $hash->{'task.end'        } = $endDate;
	      $hash->{'task.dependants' } = $row->{dependants} || "&nbsp;";
	   }
	   $hash->{'task.duration.units'} = $dunits;
	   if($canEditTasks) {
	      my $num                           = $row->{sequenceNumber};
          $hash->{'task.edit.url'         } = $self->getUrl("func=editTask;projectId=$projectId;taskId=".$row->{taskId});
		  $hash->{'task.edit.label'       } = $i18n->get("edit task label");
		  $hash->{'task.insertAbove.url'  } = $self->getUrl("func=editTask;projectId=$projectId;taskId=new;insertAt=$num");
		  $hash->{'task.insertAbove.label'} = $i18n->echo("Insert Task Above");
		  $hash->{'task.insertBelow.url'  } = $self->getUrl("func=editTask;projectId=$projectId;taskId=new;insertAt=".($num+1));
		  $hash->{'task.insertBelow.label'} = $i18n->echo("Insert Task Below");
		  $hash->{'task.delete.url'       } = $self->getUrl("func=deleteTask;taskId=".$row->{taskId});
		  $hash->{'task.delete.label'     } = $i18n->echo("Delete Task");
	   }
	   push(@taskList, $hash);
	}
	$var->{'task.loop'} = \@taskList;
	
	#Set some javascript stuff;
	my $taskLength = scalar(@taskList);
	$var->{'project.task.length'} = $taskLength;
	
	if($canEditTasks) {
	   #Build Form for submitting on the fly updates
	    $var->{'form.header'} = WebGUI::Form::formHeader($session,{
			action=>$self->getUrl,
			extras=>q|name="editAll"|
			});
        $var->{'form.header'} .= WebGUI::Form::hidden($session, {
			-name=>"func",
			-value=>"saveExistingTasks"
			});
        $var->{'form.header'} .= WebGUI::Form::hidden($session, {
			-name=>"projectId",
			-value=>$projectId
			});												   
	    
        $var->{'form.footer'         } = WebGUI::Form::formFooter($session);
	    $var->{'project.canEdit'     } = "true";
	    $var->{'task.resources.label'} = $i18n->get("task resources label");
	    $var->{'task.resources.url'  } = $self->getUrl("func=manageResources");
	}

	if($canEditTasks) {
		$var->{'task.add.label'      } = $i18n->get("add task label");
        $var->{'task.add.projectId'  } = $projectId;
		$var->{'task.add.url'        } = $self->getUrl("func=editTask;projectId=$projectId;taskId=new");
        $var->{'task.canAdd'         } = "true";
	}


	# Rowspan of gantt chart is 4 plus number of tasks
	$var->{'project.gantt.rowspan'} = 4 + $taskLength;

	$var->{'project.ganttChart'} = $self->www_drawGanttChart($projectId, $data, $var);

	$var->{'task.back.label'} = $i18n->get("task back label");
	$var->{'task.back.url'} = $self->getUrl;

	return $self->processStyle($self->processTemplate($var,$self->projectDisplayTemplateId));
}


1;
