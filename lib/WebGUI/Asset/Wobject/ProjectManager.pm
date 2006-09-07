package WebGUI::Asset::Wobject::ProjectManager;

$VERSION = "1.0.0";

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use DateTime;
use Tie::IxHash;
use WebGUI::International;
use WebGUI::Utility;
use WebGUI::HTML;
use POSIX qw(ceil floor);
use base 'WebGUI::Asset::Wobject';

#-------------------------------------------------------------------
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
sub _getDurationUnitHash {
   my $self = shift;
   my ($session,$privilege,$form,$db,$dt,$i18n,$user) = $self->setSessionVars;
   
   tie my %hash, "Tie::IxHash";
   %hash = ( "hours"=>$i18n->get("hours label"), "days"=>$i18n->get("days label") );
   
   return \%hash;
}

#-------------------------------------------------------------------
sub _getDurationUnitHashAbbrev {
   my $self = shift;
   my ($session,$privilege,$form,$db,$dt,$i18n,$user) = $self->setSessionVars;
   
   tie my %hash, "Tie::IxHash";
   %hash = ( "hours"=>$i18n->get("hours label abbrev"), "days"=>$i18n->get("days label abbrev") );
   
   return \%hash;
}

#-------------------------------------------------------------------
sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my $i18n = WebGUI::International->new($session,'Asset_ProjectManager');
	my $db = $session->db;
	my %properties;
	tie %properties, 'Tie::IxHash';
	%properties = (
		projectDashboardTemplateId =>{
			fieldType=>"template",  
			defaultValue=>'ProjectManagerTMPL0001',
			tab=>"display",
			namespace=>"ProjectManager_dashboard", 
			hoverHelp=>$i18n->get('projectDashboardTemplate hoverhelp'),
		    label=>$i18n->get('projectDashboardTemplate label')
		},
		projectDisplayTemplateId => {
			fieldType=>"template",  
			defaultValue=>'ProjectManagerTMPL0002',
			tab=>"display",
			namespace=>"ProjectManager_project", 
			hoverHelp=>$i18n->get('projectDisplayTemplate hoverhelp'),
		    label=>$i18n->get('projectDisplayTemplate label')
		},
		ganttChartTemplateId => {
			fieldType=>"template",  
			defaultValue=>'ProjectManagerTMPL0003',
			tab=>"display",
			namespace=>"ProjectManager_gantt", 
			hoverHelp=>$i18n->get('ganttChartTemplate hoverhelp'),
		    label=>$i18n->get('ganttChartTemplate label')
		},
		editTaskTemplateId =>{
			fieldType=>"template",  
			defaultValue=>'ProjectManagerTMPL0004',
			tab=>"display",
			namespace=>"ProjectManager_editTask", 
			hoverHelp=>$i18n->get('editTaskTemplate hoverhelp'),
		    label=>$i18n->get('editTaskTemplate label')
		},
		resourcePopupTemplateId =>{
			fieldType=>"template",  
			defaultValue=>'ProjectManagerTMPL0005',
			tab=>"display",
			namespace=>"ProjectManager_resourcePopup", 
			hoverHelp=>$i18n->get('resourcePopupTemplate hoverhelp'),
		    label=>$i18n->get('resourcePopupTemplate label')
		},
		resourceListTemplateId =>{
			fieldType=>"template",  
			defaultValue=>'ProjectManagerTMPL0006',
			tab=>"display",
			namespace=>"ProjectManager_resourceList", 
			hoverHelp=>$i18n->get('resourceListTemplate hoverhelp'),
		    label=>$i18n->get('resourceListTemplate label')
		},
		groupToAdd => {
			fieldType=>"group",
			defaultValue=>3,
			tab=>"security",
			hoverHelp=>$i18n->get('groupToAdd hoverhelp'),
			label=>$i18n->get('groupToAdd label')
		}
	);
	push(@{$definition}, {
		assetName=>$i18n->get('assetName'),
		icon=>'projManagement.gif',
		autoGenerateForms=>1,
		tableName=>'PM_wobject',
		className=>'WebGUI::Asset::Wobject::ProjectManager',
		properties=>\%properties
	 });
     return $class->SUPER::definition($session, $definition);
}


#-------------------------------------------------------------------
sub duplicate {
	my $self = shift;
	my $newAsset = $self->SUPER::duplicate(shift);
	return $newAsset;
}

#-------------------------------------------------------------------
#API method called by Time Tracker to return the instance of the PM wobject which this project blongs
sub getProjectInstance {
   my $class = shift;
   my $session = shift;
   my $db = $session->db;
   my $projectId = $_[0];
   return undef unless $projectId;
   my ($assetId) = $db->quickArray("select assetId from PM_project where projectId=?",[$projectId]);
   if($assetId) {
      return WebGUI::Asset->newByDynamicClass($session,$assetId);
   }
   return undef;
}

#-------------------------------------------------------------------
#API method called by Time Tracker to return all projects in all assets for which the user passed in has tasks assigned
sub getProjectList {
	my $self = shift;
	my $db = $self->session->db;
	my $userId = $_[0];
	my @groupIds = @{WebGUI::User->new($self->session, $userId)->getGroups};
	my $groupIdQuery = @groupIds?
	    ('PM_taskResource.resourceId IN ('.join(',', map{'?'} @groupIds).')') : '0';

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
sub getTaskList {
	my $self = shift;
	my $db = $self->session->db;
	my $projectId = $_[0];
	my $userId = $_[1];
	my @groupIds = @{WebGUI::User->new($self->session, $userId)->getGroups};
	my $groupIdQuery = @groupIds?
	    ('PM_taskResource.resourceId IN ('.join(',', map{'?'} @groupIds).')') : '0';

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
#API method called by Time Tracker to set percent complete field in the task and update the project cache
sub updateProjectTask {
   my $self = shift;
   my $db = $self->session->db;
   my $eh = $self->session->errorHandler;
   
   my $taskId = $_[0];
   my $projectId = $_[1];
   my $totalHours = $_[2];
   
   $eh->warn("taskId: $taskId ~~ projectId: $projectId ~~ totalHours: $totalHours");
   return 0 unless ($taskId && $projectId && $totalHours);
   
   my $task = $db->quickHashRef("select * from PM_task where taskId=?",[$taskId]);
   my ($units,$hoursPerDay) = $db->quickArray("select durationUnits, hoursPerDay from PM_project where projectId=?",[$projectId]);
   
   return 0 unless ($task->{taskId});
   my $duration = $task->{duration};
   if($units eq "days"){
      $duration = $duration * $hoursPerDay;
   }
   
   my $percentComplete = ($totalHours / $duration) * 100;
   
   $self->setCollateral("PM_task","taskId",{ taskId=>$taskId, percentComplete=>$percentComplete });
   $self->_updateProject($projectId);
   return 1;
}

#-------------------------------------------------------------------
sub _updateProject {
   my $self = shift;
   my ($session,$privilege,$form,$db,$dt,$i18n,$user) = $self->setSessionVars;
   my $eh = $session->errorHandler;
   my $projectId= $_[0];
   
   my ($minStart) = $db->quickArray("select min(startDate) from PM_task where projectId=".$db->quote($projectId));
   my ($maxEnd) = $db->quickArray("select max(endDate) from PM_task where projectId=".$db->quote($projectId));
   
   my ($projectTotal) = $db->quickArray("select sum(duration) from PM_task where projectId=".$db->quote($projectId));
   
   my $complete = 0;
   
   my $tasks =  $db->buildArrayRefOfHashRefs("select * from PM_task where projectId=".$db->quote($projectId)." order by sequenceNumber asc");
   foreach my $task (@{$tasks}) {
      $complete += ($task->{duration} * ($task->{percentComplete}/100));   
   }
   
   my $projectComplete = ($projectTotal == 0)?0:(($complete / $projectTotal) * 100);
   
   $db->write("update PM_project set startDate=?, endDate=?, percentComplete=? where projectId=?",[$minStart,$maxEnd,$projectComplete,$projectId]);
}

#-------------------------------------------------------------------
sub prepareView {
	my $self = shift;
	$self->SUPER::prepareView();
	my $template = WebGUI::Asset::Template->new($self->session, $self->get("projectDashboardTemplateId"));
	$template->prepare;
	$self->{_viewTemplate} = $template;
}

#-------------------------------------------------------------------
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
sub purge {
	my $self = shift;
	#purge your wobject-specific data here.  This does not include fields 
	# you create for your NewWobject asset/wobject table.
	return $self->SUPER::purge;
}

#-------------------------------------------------------------------
sub setSessionVars {
   my $self = shift;
   my $session = $self->session;
   my $i18n = WebGUI::International->new($session,'Asset_ProjectManager');
   
   return ($session,$session->privilege,$session->form,$session->db,$session->datetime,$i18n,$session->user);
}

#-------------------------------------------------------------------
sub view {
	my $self = shift;
	my $var = $self->get;
	
	my ($session,$privilege,$form,$db,$datetime,$i18n,$user) = $self->setSessionVars;
	my $config = $session->config;
	my $eh = $session->errorHandler;
	
	$var->{'extras'} = $config->get("extrasURL")."/wobject/ProjectManager"; 
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
	if($user->isInGroup($self->get("groupToAdd"))) {
	      $var->{'canEditProjects'} = "true";
		  $var->{'empty.colspan'} = 6;
    }
	
	#Project Data
	my @projects = ();
	my $sth = $db->read("select * from PM_project where assetId=".$db->quote($self->get("assetId")));
	while (my $project = $sth->hashRef) {
	   my $hash = {};
	   my $projectId = $project->{projectId};
	   $hash->{'project.view.url'} = $self->getUrl("func=viewProject;projectId=".$projectId);
	   $hash->{'project.name.data'} = $project->{name};
	   $hash->{'project.description.data'} = $project->{description};
	   $hash->{'project.startDate.data'} = $project->{startDate}?$datetime->epochToSet($project->{startDate}):"N/A";
	   $hash->{'project.endDate.data'} = $project->{endDate}?$datetime->epochToSet($project->{endDate}):"N/A";
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
sub www_deleteProject {
	my $self = shift;
	#Set Method Helpers
    my ($session,$privilege,$form,$db,$datetime,$i18n,$user) = $self->setSessionVars;

    #Check Privileges
    return $privilege->insufficient unless ($user->isInGroup($self->get("groupToAdd")));
	
	my $projectId = $form->get("projectId");
    
	#Delete Project
	$db->write("delete from PM_project where projectId=?",[$projectId]);
	#Delete Associated Tasks
	$db->write("delete from PM_task where projectId=?",[$projectId]);
	
	return "";
}

#-------------------------------------------------------------------
sub www_deleteTask {
   my $self = shift;
   #Set Method Helpers
   my ($session,$privilege,$form,$db,$datetime,$i18n,$user) = $self->setSessionVars;
   
   #Check Privileges
   return $privilege->insufficient unless ($user->isInGroup($self->get("groupToAdd")));
   
   #Set Local Vars
   my $taskId = $form->get("taskId");
   my $task = $db->quickHashRef("select * from PM_task where taskId=?",[$taskId]);
   my $projectId = $task->{projectId};
   my $taskRank = $task->{sequenceNumber};
	     
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
sub www_editProject {
   my $self = shift;
   #Set Method Helpers
   my ($session,$privilege,$form,$db,$datetime,$i18n,$user) = $self->setSessionVars;

   #Check Privileges
   return $privilege->insufficient unless ($user->isInGroup($self->get("groupToAdd")));
   
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
		 -value=> $form->get("projectManager") || $project->{projectManager} || $self->get("groupToAdd"),
		 -hoverHelp=> $i18n->get('project manager hoverhelp'),
		 -label => $i18n->get('project manager label')
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
   $hpdHoverHelp =~ s/'/\\'/g;
   my $hpdValue = $form->get("hoursPerDay") || $project->{hoursPerDay} || "8.0";
   my $hpdStyle = ($dunitValue eq "days"?"display:none":"");
   
   my $html = qq|
   <tr id="hoursper" style="$hpdStyle">
      <td class="formDescription"  onmouseover="return escape('$hpdHoverHelp')" valign="top" style="width: 180px;">
	     <label for="hoursPerDay_formId">$hpdLabel</label>
	  </td>
	  <td valign="top" class="tableData"  style="width: *;">
	     <input id="hoursPerDay_formId" type="text" name="hoursPerDay" value="$hpdValue" size="11" maxlength="14"  onkeyup="doInputCheck(this.form.hoursPerDay,'0123456789-.')" />
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
sub www_editProjectSave {
	my $self = shift;
    #Set Method Helpers
    my ($session,$privilege,$form,$db,$dt,$i18n,$user) = $self->setSessionVars;
    my $eh = $session->errorHandler;
	
    #Check Privileges
    return $privilege->insufficient unless ($user->isInGroup($self->get("groupToAdd")));
    
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
	my $projectId = $self->setCollateral("PM_project","projectId",$props,0,1);
	
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
	   $props->{isMilestone} = 1;
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
			$subvar->{resourceName} = WebGUI::HTML::format($user->profileField('lastName').', '.$user->profileField('firstName'), 'text');
			$subvar->{resourceIcon} = 'users.gif';
		} else {
			$self->session->errorHandler->fatal("Unknown kind of resource '$resourceKind'!");
		}

		push @{$var->{resourceLoop}}, $subvar;
	}

	return $self->processTemplate($var, $self->getValue('resourceListTemplateId'));
}

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

	return $self->processTemplate($var, $self->getValue('resourcePopupTemplateId'));
}

#-------------------------------------------------------------------
sub _userSearchQuery {
	my $self = shift;
	my $exclude = shift;
	my $searchPattern = lc('%'.shift().'%');
	my @exclude = ('1', '3', split /\;/, $exclude);
	my $excludePlaceholders = '('.join(',', map{'?'} @exclude).')';

	my $query = <<"SQL";
SELECT 'user' AS resourceKind, users.userId AS resourceId
  FROM users
       LEFT JOIN userProfileData AS lastName ON users.userId = lastName.userId
                                             AND lastName.fieldName = 'lastName'
       LEFT JOIN userProfileData AS firstName ON users.userId = firstName.userId
                                              AND firstName.fieldName = 'firstName'
 WHERE (LOWER(lastName.fieldData) LIKE ? OR LOWER(firstName.fieldData) LIKE ?
        OR LOWER(users.username) LIKE ?) AND (users.userId NOT IN $excludePlaceholders)
 ORDER BY lastName.fieldData, firstName.fieldData
SQL
	my @placeholders  = (($searchPattern) x 3, @exclude);
	return ($query, \@placeholders);
}

sub www_userSearchPopup {
	my $self = shift;

	my %args = (func => 'userSearchPopup',
		    i18nprefix => 'user add popup',
		    queryCallback => sub { $self->_userSearchQuery(@_) },
		   );
	$self->_resourceSearchPopup(%args);
}

#-------------------------------------------------------------------
sub _groupSearchQuery {
	my $self = shift;
	my $exclude = shift;
	my $searchPattern = lc('%'.shift().'%');
	my @exclude = ('1', '7', split /\;/, $exclude);
	my $excludePlaceholders = '('.join(',', map{'?'} @exclude).')';
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

sub www_groupSearchPopup {
	my $self = shift;
	my %args = (func => 'groupSearchPopup',
		    i18nprefix => 'group add popup',
		    queryCallback => sub { $self->_groupSearchQuery(@_) },
		   );
	$self->_resourceSearchPopup(%args);
}

#-------------------------------------------------------------------
sub _resourceListOfTask {
	# TODO: Should there be a getAllCollateral in Asset::Wobject?
	my $self = shift;
	my $taskId = shift;
	return ($taskId eq 'new')? () :
	    @{$self->session->db->buildArrayRefOfHashRefs("SELECT resourceKind, resourceId FROM PM_taskResource WHERE taskId = ? ORDER BY sequenceNumber", [$taskId])};
}

sub _innerHtmlOfResources {
	my $self = shift;
	my @resources = @_;
	my $i18n = WebGUI::International->new($self->session, 'Asset_ProjectManager');
	return $self->_htmlOfResourceList({opCallbackJs => 'taskEdit_deleteResource', opIcon => 'delete.gif', opTitle => $i18n->get('resource remove opTitle'), hiddenFields => 1}, @resources);
}

sub www_innerHtmlOfResources {
	my $self = shift;
	my @resources = map {
		my ($resourceKind, $resourceId) = split / /, $_, 2;
		{ resourceKind => $resourceKind, resourceId => $resourceId }
	} split /\;/, $self->session->form->param('resources');
	return $self->_innerHtmlOfResources(@resources);
}

sub www_editTask {
   my $self = shift;
   my $var = {};
   #Set Method Helpers
   my ($session,$privilege,$form,$db,$dt,$i18n,$user) = $self->setSessionVars;
   my $config = $session->config;
   
   my $projectId = $form->get("projectId");
   my $taskId = $form->get("taskId") || "new";
  
   my $project = $db->quickHashRef("select * from PM_project where projectId=".$db->quote($projectId));
   my $task = $db->quickHashRef("select * from PM_task where taskId=".$db->quote($taskId));
   
   #Check Privileges
   return $privilege->insufficient unless ($user->isInGroup($project->{projectManager}));
   
   my $isMilestone = $task->{isMilestone};
   my $seq = $task->{sequenceNumber};
   my $extras = ($isMilestone)?" disabled":"";
   $var->{'form.header'} = WebGUI::Form::formHeader($session,{
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
   #Set some hidden variables to make it easy to reset data in javascript
   my $duration = $task->{duration};
   my $start = $dt->epochToSet($task->{startDate});
   my $end = $dt->epochToSet($task->{endDate});
   my $dependant = $task->{dependants};
   														   
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
  
   
   $var->{'form.duration'} = WebGUI::Form::float($session,{
				-name=>"duration",
				-value=>$task->{duration}, 
				-extras=>qq|style="width:70%;" onchange="adjustTaskTimeFromDuration(this.form.start,this.form.end,this,this.form.lagTime,true,this.form.dependants,this.form.orig_start,this.form.orig_end,'$seq')"  onblur="if(this.value == 0){ adjustTaskTimeFromDuration(this.form.start,this.form.end,this,this.form.lagTime,true,this.form.dependants,this.form.orig_start,this.form.orig_end,'$seq') }" $extras|
				});
   $var->{'form.duration.units'} = $self->_getDurationUnitHashAbbrev->{$project->{durationUnits}};

   $var->{'form.lagTime'} = WebGUI::Form::float($session,{
                                -name => "lagTime",
				-value => $task->{lagTime},
				-extras => qq|style="width:70%;" onchange="adjustTaskTimeFromDuration(this.form.start,this.form.end,this.form.duration,this,true,this.form.dependants,this.form.orig_start,this.form.orig_end,'$seq')"  onblur="if(this.value == 0){ adjustTaskTimeFromDuration(this.form.start,this.form.end,this.form.duration,this,true,this.form.dependants,this.form.orig_start,this.form.orig_end,'$seq') }" $extras|
							 });
   $var->{'form.lagTime.units'} = $self->_getDurationUnitHashAbbrev->{$project->{durationUnits}};

   $var->{'form.start'} = WebGUI::Form::text($session,{
				-name=>"start",
				-value=>$start,
				-size=>"10",
				-maxlength=>"10",
				-extras=>qq|onfocus="doCalendar(this.id);" onblur="if(this.form.milestone.checked==true) this.form.end.value=this.value; adjustTaskTimeFromDate(this.form.start,this.form.end,this.form.duration,this.form.lagTime,this,true,this.form.dependants,this.form.orig_start,this.form.orig_end,'$seq');" style="width:88%;"|
				});
													
   $var->{'form.end'} = WebGUI::Form::text($session,{
				-name=>"end",
				-value=>$end,
				-size=>"10",
				-maxlength=>"10",
				-extras=>qq|onfocus="doCalendar(this.id);" style="width:88%;" onblur="adjustTaskTimeFromDate(this.form.start,this.form.end,this.form.duration,this.form.lagTime,this,true,this.form.dependants,this.form.orig_start,this.form.orig_end,'$seq');" $extras|
				});

   $var->{'form.dependants'} = WebGUI::Form::integer($session,{
				-name=>"dependants",
				-value=>$dependant || "",
				-defaultValue=>"",
				-size=>4,
				-maxlength=>10, 
				-extras=>qq|style="width:50%;" onchange="validateDependant(this,this.form.orig_dependant,'$seq',this.form.start,this.form.end,this.form.duration,this.form.lagTime,true,true,this.form.orig_start,this.form.orig_end);"|
				});

   tie my %users, "Tie::IxHash";
   %users = $db->buildHash("select userId,username from users where userId not in ('1','3') order by userId");
   %users = (""=>$i18n->get("resource none"),%users);

   my @resources = $self->_resourceListOfTask($taskId);
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

   $var->{'form.milestone'} = WebGUI::Form::checkbox($session, {
				-name=>"milestone",
				-value=>1,
				-checked=>$task->{isMilestone},
				-extras=>q|onclick="configureMilestone(this)"|
				});
   $var->{'form.percentComplete'} = WebGUI::Form::float($session, {
				-name=>"percentComplete",
				-value=>$task->{percentComplete},
				-extras=>$extras
				});
   $var->{'form.save'} = WebGUI::Form::submit($session, { 
				-value=>"Save", 
				-extras=>q|name="subbutton"| 
				});													   	
$var->{'form.footer'} = WebGUI::Form::formFooter($session);

$var->{'extras'} = $config->get("extrasURL");
$var->{'assetExtras'} = $config->get("extrasURL").'/wobject/ProjectManager';
return $self->processTemplate($var,$self->getValue("editTaskTemplateId"))
}

#-------------------------------------------------------------------
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
   return $privilege->insufficient unless ($user->isInGroup($project->{projectManager}));
   
   my $isMilestone = $form->process("milestone","checkbox");
   
   my $props = {};
   $props->{taskId} = $form->process("taskId","hidden");
   $props->{projectId} = $projectId;
   $props->{taskName} = $form->process("name","text");
   $props->{duration} = $isMilestone? 0 : $form->process("duration","text");
   $props->{lagTime} = $isMilestone? 0 : $form->process("lagTime","text");
   $props->{startDate} = $form->process("start","date");
   $props->{endDate} = ($isMilestone ? $props->{startDate} : $form->process("end","date"));
   $props->{dependants} = $form->process("dependants","selectBox") unless $isMilestone;
   $props->{isMilestone} =  $isMilestone || 0;
   my @resourceSpecs = $form->process("resources","hiddenList");
   $props->{percentComplete} = $isMilestone? 0 : $form->process("percentComplete","float");
   
   my $now = $dt->time();
   if($props->{taskId} eq "new") {
      $props->{creationDate} = $now;
	  $props->{createdBy} = $user->userId;
   }
   $props->{lastUpdateDate} = $now;
   $props->{lastUpdatedBy} = $user->userId;
   
   #Save the extended task data
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
  
   $self->_updateProject($projectId);   
   $self->_arrangePredecessors($project,$taskId);
   
   return $self->www_viewProject($projectId,$taskId);
}

#-------------------------------------------------------------------
sub _arrangePredecessors {
   my $self = shift;
   my ($session,$privilege,$form,$db,$dt,$i18n,$user) = $self->setSessionVars;
   my $eh = $session->errorHandler;
   my ($project,$taskId) = @_;
   my $projectId = $project->{projectId};
   
   my $seq = 0;
   if($taskId) {
      $seq = "(select sequenceNumber from PM_task where taskId=".$db->quote($taskId).")";
   } 
   
   my $tasks = $db->buildArrayRefOfHashRefs("select * from PM_task where projectId=?",[$projectId]);
   
   my $taskHash = {};
   foreach my $task (@{$tasks}) {
      my $seqNum = $task->{sequenceNumber};
	  #$eh->warn("Seq Num = $seqNum");
	  #Calculate initial duration in days and duration floor
	  my $totalDurationInDays = $task->{duration} + $task->{lagTime};
	  $totalDurationInDays = $totalDurationInDays / $project->{hoursPerDay} if( $project->{durationUnits} eq "hours" );
	  #$eh->warn("Duration in Days: ".$durationInDays);
	  my $totalDurationFloor = floor($totalDurationInDays);
	  #$eh->warn("Duration Floor: ".$durationFloor);
	  
	  #Skip the first record as it has no predecessors
	  #next if (scalar(keys %{$taskHash})) == 1;
      if( scalar(keys %{$taskHash} )  > 0 ) {
	     #If the task has a predecessor, ensure that it starts are the right time.
	     my $predecessor = $task->{dependants};
		 #$eh->warn("Predecessor is: ".$predecessor);
	     if($predecessor) {
	        #Get the predecessor task data - since predecessors come before this task, it should be in the taskHash
		    my $pred = $taskHash->{$predecessor};
		    my $predEndDate = $pred->{endDate};
			#$eh->warn("Task Start Date: ".$dt->epochToSet($task->{startDate}));
			#$eh->warn("Pred End Date: ".$dt->epochToSet($predEndDate));
			#Get the day part of the predecessor
			my $predDayPart = $pred->{dayPart};
			#$eh->warn("Pred Day Part: ".$predDayPart);
		    #Make sure start date of this task is greater than the end date of the predecessor
		    if($task->{startDate} <= $predEndDate) {
		       #Change the start and end dates of the task
			   if($predDayPart > 0) {
			      #The previous task took up a part of a day.  Add the additional day part to get the correct duration
				  $totalDurationInDays += $predDayPart;
				  $totalDurationFloor = floor($totalDurationInDays);
			   } 
	           
			   #$eh->warn("Duration in Days is now: ".$durationInDays);
	           #$eh->warn("Duration Floor is now: ".$durationFloor);
			   
			   #$eh->warn("Pred End Date is now: ".$dt->epochToSet($predEndDate));
			   
			   #Set the start date of this task to the end date of the predecessor and update the hash
			   $task->{startDate} = $predEndDate;
			   #$eh->warn("Start Date is now: ".$dt->epochToSet($task->{startDate}));
	           #Adjust end date for change in start date and update the hash
	           $task->{endDate} = $dt->addToDateTime($task->{startDate}, 0, 0, $totalDurationFloor);
			   #$eh->warn("End Date is now: ".$dt->epochToSet($task->{endDate})."\n\n");
			   #Update the database
			   $self->setCollateral("PM_task","taskId",$task,1,0,"projectId",$projectId);
		    } 
         }
      }
	  
	  #Adjust duration of days to only include the part of the day used
      $totalDurationInDays = $totalDurationInDays - floor($totalDurationInDays);
	  #$eh->warn("Day Part left over is: $durationInDays \n\n");
	  
	  
	  #add this task to the taskHash
	  $taskHash->{$seqNum} = { 
	                           'startDate'=>$task->{startDate}, 
	                           'endDate'=>$task->{endDate}, 
							   'duration'=>$task->{duration}, 
							   'dayPart'=>$totalDurationInDays
							 };
   }
   
   return;  
}

#-------------------------------------------------------------------
sub www_saveExistingTasks {
   my $self = shift;
   my $var = {};
   #Set Method Helpers
   my ($session,$privilege,$form,$db,$dt,$i18n,$user) = $self->setSessionVars;
   my $config = $session->config;
   
   my $projectId = $form->get("projectId");
   my $project = $db->quickHashRef("select * from PM_project where projectId=".$db->quote($projectId));
   
   #Check Privileges
   return $privilege->insufficient unless ($user->isInGroup($project->{projectManager}));
   
   my $tasks = $db->buildArrayRefOfHashRefs("select * from PM_task where projectId=".$db->quote($projectId)." order by sequenceNumber asc");
  
   #Save each row
   foreach my $task (@{$tasks}) {
      my $isMilestone = $task->{isMilestone};
	  my $props = {};
	  my $taskId = $task->{taskId};
      $props->{taskId} = $taskId;
      $props->{projectId} = $projectId;
	  $props->{startDate} = $form->process("start_$taskId","date");
	  $props->{endDate} = $form->process("end_$taskId","date");
	  $props->{dependants} = $form->process("dependants_$taskId","selectBox"); 
	  unless($isMilestone) {
         $props->{duration} = $form->process("duration_$taskId","float");
         $props->{lagTime} = $form->process("lagTime_$taskId","float");
      }
	  $props->{lastUpdateDate} = $dt->time();
      $props->{lastUpdatedBy} = $user->userId;
	  
	  $self->setCollateral("PM_task","taskId",$props,1,0,"projectId",$projectId);
   }
   
   #Rearrange predecessors
   #$self->_arrangePredecessors($project);
   $self->_updateProject($projectId);
   return $self->www_drawGanttChart();
   
}

#-------------------------------------------------------------------
sub www_viewProject {
	my $self = shift;
	my $var = {};
    #Set Method Helpers
    my ($session,$privilege,$form,$db,$dt,$i18n,$user) = $self->setSessionVars;
    my $config = $session->config;
	my $style = $session->style;
	my $eh = $session->errorHandler;
	my $projectId = $_[0] || $form->get("projectId");
		
	#Check Privileges
    return $privilege->insufficient unless ($self->canView);
	
	my $extras = $config->get("extrasURL");
	my $assetExtras = $config->get("extrasURL")."/wobject/ProjectManager";
	
	$var->{'extras'} = $assetExtras;
	$var->{'extras.base'} = $extras;
	
    #Set Some Style stuff	
	$style->setLink($assetExtras."/subModal.css",{rel=>"stylesheet",type=>"text/css"});
	$style->setLink($assetExtras."/taskEdit.css",{rel=>"stylesheet",type=>"text/css"});
	$style->setLink($extras."/calendar/calendar-win2k-1.css",{rel=>"stylesheet",type=>"text/css"});
	$style->setLink($assetExtras."/cMenu.css",{rel=>"stylesheet",type=>"text/css"});
	
	$style->setScript($assetExtras."/cMenu.js",{ type=>"text/javascript" });
    $style->setScript($extras."/js/at/AjaxRequest.js",{ type=>"text/javascript" });
	$style->setScript($extras."/js/modal/modal.js",{ type=>"text/javascript" });
	$style->setScript($extras."/calendar/calendar.js",{ type=>"text/javascript" });
	$style->setScript($extras."/contextMenu/contextMenu.js",{ type=>"text/javascript" });
	$style->setScript($extras."/calendar/lang/calendar-en.js",{ type=>"text/javascript" });
	$style->setScript($extras."/calendar/calendar-setup.js",{ type=>"text/javascript" });
	$style->setScript($assetExtras."/projectDisplay.js",{ type=>"text/javascript" });
	$style->setScript($assetExtras."/taskEdit.js",{ type=>"text/javascript" });
	
	#Get Project Data
	my $project = $db->quickHashRef("select * from PM_project where projectId=".$db->quote($projectId));
    my $canEdit = $user->isInGroup($self->get("groupToAdd"));
	my $canAddTask = $user->isInGroup($project->{projectManager}) || $canEdit;
	my $dunits = $self->_getDurationUnitHashAbbrev->{$project->{durationUnits}};
	
	#Set some JavaScript stuff
	$var->{'project.durationUnits'} = $dunits;
	$var->{'project.hoursPerDay'} = $project->{hoursPerDay} || "0";
	
	#Get Tasks
	my $data = $db->buildArrayRefOfHashRefs("select * from PM_task where projectId=".$db->quote($projectId)." order by sequenceNumber asc");
	
	$var->{'task.name.label'} = $i18n->get("task name label");
	$var->{'task.duration.label'} = $i18n->get("task duration label");
	$var->{'task.start.label'} = $i18n->get("task start label");
	$var->{'task.end.label'} = $i18n->get("task end label");
	$var->{'task.dependants.label'} = $i18n->get("task dependant label");
	
    #JavaScript Alert Errors for Tasks
	$var->{'form.name.error'} = $i18n->get("task name error");
	$var->{'form.start.error'} = $i18n->get("task start error");
	$var->{'form.end.error'} = $i18n->get("task end error");
	$var->{'form.greaterthan.error'} = $i18n->get("task greaterthan error");
	$var->{'form.previousPredecessor.error'} = $i18n->get("task previousPredecessor error");
	$var->{'form.samePredecessor.error'} = $i18n->get("task samePredecessor error");
	$var->{'form.noPredecessor.error'} = $i18n->get("task noPredecessor error");
	$var->{'form.invalidMove.error'} = $i18n->get("task invalidMove error");
	
	my @taskList = ();
	my $count = 0;
	foreach my $row (@{$data}) {
	   my $hash = {};
	   my $seq = $row->{sequenceNumber};
	   my $id = $row->{taskId};
	   my $isMilestone = $row->{isMilestone} || 0;
	   my $startDate = $dt->epochToSet($row->{startDate});
	   my $endDate = $dt->epochToSet($row->{endDate});
	   my $duration = $row->{duration};
	   my $lagTime = $row->{lagTime};
	   
	   $hash->{'task.number'} = $seq;
	   $hash->{'task.row.id'} = "taskrow::$id";
	   $hash->{'task.name'} = $row->{taskName};
	   	  
	   if($canEdit) {
	      my $startId = "start_".$id."_formId";
	      my $endId = "end_".$id."_formId";
		  my $durId = "duration_".$id."_formId";
		  my $lagId = "lagTime_".$id."_formId";
		  my $predId = "dependants_".$id."_formId";
		  my $origStartField = "orig_start_$id";
		  my $origStartFieldId = $origStartField."_formId";
		  my $origDepField = "orig_dependants_$id";
		  my $origDepFieldId = $origDepField."_formId";
		  my $origEndField = "orig_end_$id";
		  my $origEndFieldId = $origEndField."_formId";

	      $hash->{'task.start'} = WebGUI::Form::text($session,{
		                                               -name=>"start_$id",
													   -value=>$startDate,
													   -size=>"10",
													   -maxlength=>"10",
													   -extras=>qq<onfocus="doCalendar(this.id);" class="taskdate" onblur="adjustTaskTimeFromDate(this,document.getElementById('$endId'),document.getElementById('$durId'),document.getElementById('$lagId'),this,false,document.getElementById('$predId'),document.getElementById('$origStartFieldId'),document.getElementById('$origEndFieldId'),'$seq');">
		                                            });
		  
		  $hash->{'task.start'} .= WebGUI::Form::hidden($session,{
			-name=>$origStartField,
			-value=>$startDate,
			-extras=>qq|id="$origStartFieldId"|
			});

		  $hash->{'task.dependants'} = WebGUI::Form::integer($session,{
			-name=>"dependants_$id",
			-value=>$row->{dependants} || "",
			-defaultValue=>"", 
			-extras=>qq|class="taskdependant" onchange="validateDependant(this,document.getElementById('$origDepFieldId'),'$seq',document.getElementById('$startId'),document.getElementById('$endId'),document.getElementById('$durId'),false,document.getElementById('$origStartFieldId'),document.getElementById('$origEndFieldId'));"|
			});
		  $hash->{'task.dependants'} .= WebGUI::Form::hidden($session,{
			-name=>$origDepField,
			-value=>$row->{dependants},
			-extras=>qq|id="$origDepFieldId"|
			});

		  $hash->{'task.end'} = WebGUI::Form::text($session,{
		                                               -name=>"end_$id",
								     -value=>$endDate,
								     -size=>"10",
								     -maxlength=>"10",
								     -extras=>qq|class="taskdate" onfocus="doCalendar(this.id);" onblur="adjustTaskTimeFromDate(document.getElementById('$startId'),this,document.getElementById('$durId'),document.getElementById('$lagId'),this,false,document.getElementById('$predId'),document.getElementById('$origStartFieldId'),document.getElementById('$origEndFieldId'),'$seq');"|
		                                            });
		  $hash->{'task.end'} .= WebGUI::Form::hidden($session,{
			-name=>$origEndField,
			-value=>$endDate,
			-extras=>qq|id="$origEndFieldId"|
			});
		  #Don't display uneditable fields if the task is a milestone.
		  if($isMilestone) {
			$hash->{'task.duration'} = $row->{duration};
			 $hash->{'task.duration'} .= WebGUI::Form::hidden($session,{
				-name=>"duration_$id",
				-value=>$duration,
				-extras=>qq|id="$durId"|
				});
		  } else {
	         $hash->{'task.duration'} = WebGUI::Form::float($session,{
				-name=>"duration_$id",
				-value=>$duration, 
				-extras=>qq|class="taskduration" onchange="adjustTaskTimeFromDuration(document.getElementById('$startId'),document.getElementById('$endId'),this,document.getElementById('$lagId'),false,document.getElementById('$predId'),document.getElementById('$origStartFieldId'),document.getElementById('$origEndFieldId'),'$seq');" |
				});
			 
	      }
	      $hash->{'task.lagTime'} = WebGUI::Form::hidden($session,{
								       -name => "lagTime_$id",
								       -value => $lagTime,
								       -extras=>qq|id="$lagId"|
								      });

	   } else {
	      $hash->{'task.duration'} = $duration;
	      $hash->{'task.start'} = $startDate;
	      $hash->{'task.end'} = $endDate;
	      $hash->{'task.dependants'} = $row->{dependants} || "&nbsp;";
	   }
	   $hash->{'task.duration.units'} = $dunits;
	   $hash->{'task.isMilestone'} = "true" if($isMilestone);
	   if($canAddTask) {
	      $hash->{'task.edit.url'} = $self->getUrl("func=editTask;projectId=$projectId;taskId=".$row->{taskId});
		  $hash->{'task.edit.label'} = $i18n->get("edit task label");
		  my $num = $row->{sequenceNumber};
		  $hash->{'task.insertAbove.url'} = $self->getUrl("func=editTask;projectId=$projectId;taskId=new;insertAt=$num");
		  $hash->{'task.insertAbove.label'} = $i18n->echo("Insert Task Above");
		  $hash->{'task.insertBelow.url'} = $self->getUrl("func=editTask;projectId=$projectId;taskId=new;insertAt=".($num+1));
		  $hash->{'task.insertBelow.label'} = $i18n->echo("Insert Task Below");
		  $hash->{'task.delete.url'} = $self->getUrl("func=deleteTask;taskId=".$row->{taskId});
		  $hash->{'task.delete.label'} = $i18n->echo("Delete Task");
	   }
	   push(@taskList, $hash);
	}
	$var->{'task.loop'} = \@taskList;
	
	#Set some javascript stuff;
	my $taskLength = scalar(@taskList);
	$var->{'project.task.length'} = $taskLength;
	
	if($canEdit) {
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
		$var->{'form.footer'} = WebGUI::Form::formFooter($session);
		$var->{'project.canEdit'} = "true";
		$var->{'task.resources.label'} = $i18n->get("task resources label");
		$var->{'task.resources.url'} = $self->getUrl("func=manageResources");
	}

	if($canAddTask) {
		$var->{'task.add.label'} = $i18n->get("add task label");
		$var->{'task.add.url'} = $self->getUrl("func=editTask;projectId=$projectId;taskId=new");
		$var->{'task.canAdd'} = "true";
	}
	
	
	#Rowspan of gantt chart is 4 plus number of tasks
	$var->{'project.gantt.rowspan'} = 4 + $taskLength;
	
	$var->{'project.ganttChart'} = $self->www_drawGanttChart($projectId, $data, $var);
		
	$var->{'task.back.label'} = $i18n->get("task back label");
	$var->{'task.back.url'} = $self->getUrl;
	
	return $style->process($self->processTemplate($var,$self->getValue("projectDisplayTemplateId")),$self->getValue("styleTemplateId"));
}

#-------------------------------------------------------------------
sub _doGanttTaskResourceDisplay {
	my $self = shift;
	my $hash = shift;
	my $task = shift;
	my @resources = $self->_resourceListOfTask($task->{taskId});
	my @resourceNames = ();

	foreach my $resource (@resources) {
		my ($resourceKind, $resourceId) = @$resource{qw{resourceKind resourceId}};
		if ($resourceKind eq 'user') {
			my $u = WebGUI::User->new($self->session, $resourceId);
			my $name = $u->username;
			my $firstName = $u->profileField('firstName');
			my $lastName = $u->profileField('lastName');
			$name = "$firstName $lastName" if ($firstName && $lastName);
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

sub www_drawGanttChart {
	my $self = shift;
	my $var = {};
	#Set Method Helpers
	my ($session,$privilege,$form,$db,$dt,$i18n,$user) = $self->setSessionVars;
	my $config = $session->config;
	my $style = $session->style;
	my $eh = $session->errorHandler;
	
	#Check Privileges
    return $privilege->insufficient unless ($self->canView);
	
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
	
	my ($dunits,$hoursPerDay) = $db->quickArray("select durationUnits,hoursPerDay from PM_project where projectId=".$db->quote($projectId));

	$var->{'extras'} = $config->get("extrasURL")."/wobject/ProjectManager";
	
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
		
		#Each day is 23 pixels so calculate the days and round
		unless ($duration) {
		   $hash->{'task.div.width'} = $pixelSize;
		} else {
		   $hash->{'task.div.width'} = int(($totalDuration * $pixelSize)) || 3;
		}

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
		
		#Interval includes current day if the start date is not the start of the month so add 1
		my $adder = 1;
		if($dt->epochToSet($startMonth) eq $dt->epochToSet($startDate)) {
		   $adder = 0;
		}
		my $daysFromStart = ($dt->getDaysInInterval($startMonth,$startDate)+$adder);
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
		
		$hash->{'task.isMilestone'} = $task->{isMilestone};
		
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
		$var->{'project.task.array'} .= qq|"$seq": { "id":"$id" ,"start":"$startDate" ,"end":"$endDate", "duration":"$rduration", "dayPart":"$duration", "lagTime":"$lagTime", "predecessor":"$predecessor" }|;
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
	
	return $self->processTemplate($var,$self->getValue("ganttChartTemplateId"));
}



1;
