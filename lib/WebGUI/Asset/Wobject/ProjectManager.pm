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
sub www_editProject {
   my $self = shift;
   #Set Method Helpers
   my ($session,$privilege,$form,$db,$datetime,$i18n,$user) = $self->setSessionVars;

   #Check Privileges
   return $privilege->insufficient unless ($user->isInGroup($self->get("groupToAdd")));
   
   #Set Local Vars
   my $projectId = $form->get("projectId"); 
   my $project = $db->quickHashRef("select * from PM_project where projectId=".$db->quote($projectId));
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

    #Check Privileges
    return $privilege->insufficient unless ($user->isInGroup($self->get("groupToAdd")));
    
	my $now = $dt->time();
	my $uid = $user->userId;
	my $projectId = $form->process("projectId","hidden");
	
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
	
	if($projectId eq "new") {
	   #Create Project Start Milestone Task for new projects
	   $props = {};
	   $props->{taskId} = "new";
	   $props->{projectId} = $projectId;
	   $props->{taskName} = $i18n->get("project start task label");
	   $props->{duration} = 0;
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
				-extras=>qq|style="width:70%;" onchange="adjustTaskTimeFromDuration(this.form.start,this.form.end,this,true,this.form.dependants,this.form.orig_start,this.form.orig_end,$seq)"  onblur="if(this.value == 0){ adjustTaskTimeFromDuration(this.form.start,this.form.end,this,true) }" $extras|
				});
   $var->{'form.duration.units'} = $self->_getDurationUnitHashAbbrev->{$project->{durationUnits}};
   $var->{'form.start'} = WebGUI::Form::text($session,{
				-name=>"start",
				-value=>$start,
				-size=>"10",
				-maxlength=>"10",
				-extras=>qq|onfocus="doCalendar(this.id);" onblur="adjustTaskTimeFromDate(this.form.start,this.form.end,this.form.duration,this,true,this.form.dependants,this.form.orig_start,this.form.orig_end,$seq);" onblur="if(this.form.milestone.checked==true){ this.form.end.value=this.value; }" style="width:88%;"|
				});
													
   $var->{'form.end'} = WebGUI::Form::text($session,{
				-name=>"end",
				-value=>$end,
				-size=>"10",
				-maxlength=>"10",
				-extras=>qq|onfocus="doCalendar(this.id);" style="width:88%;" onblur="adjustTaskTimeFromDate(this.form.start,this.form.end,this.form.duration,this,true,this.form.dependants,this.form.orig_start,this.form.orig_end,$seq);" $extras|
				});

   $var->{'form.dependants'} = WebGUI::Form::integer($session,{
				-name=>"dependants",
				-value=>$dependant || "",
				-defaultValue=>"",
				-size=>4,
				-maxlength=>10, 
				-extras=>qq|style="width:50%;" onchange="validateDependant(this,this.form.orig_dependant,'$seq',this.form.start,this.form.end,this.form.duration,true,true,this.form.orig_start,this.form.orig_end);"|
				});

   tie my %users, "Tie::IxHash";
   %users = $db->buildHash("select userId,username from users where userId not in (1,3)");
   %users = (""=>$i18n->get("resource none"),%users);
   $var->{'form.resource'} = WebGUI::Form::selectBox($session, {
				-name=>"resource",
				-options=>\%users,
				-value=>[$task->{resourceId}],
				-extras=>$extras
				});
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

return $self->processTemplate($var,$self->getValue("editTaskTemplateId"))
}

#-------------------------------------------------------------------
sub www_editTaskSave {
my $self = shift;
my $var = {};
#Set Method Helpers
my ($session,$privilege,$form,$db,$dt,$i18n,$user) = $self->setSessionVars;
my $config = $session->config;

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
   $props->{startDate} = $form->process("start","date");
   $props->{endDate} = ($isMilestone ? $props->{startDate} : $form->process("end","date"));
   $props->{dependants} = $form->process("dependants","selectBox") unless $isMilestone;
   $props->{isMilestone} =  $isMilestone || 0;
   $props->{resourceId} = $form->process("resource","selectBox");
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
  
   $self->_updateProject($projectId);   
   $self->_arrangePredecessors($project,$taskId);
   
   return $self->www_viewProject($projectId,$taskId);
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
   
   my $projectComplete = (($complete / $projectTotal) * 100);
   
   $db->write("update PM_project set startDate=?, endDate=?, percentComplete=? where projectId=?",[$minStart,$maxEnd,$projectComplete,$projectId]);
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
   
   my $tasks = $db->buildArrayRefOfHashRefs("select * from PM_task where projectId=".$db->quote($projectId));
   
   my $taskHash = {};
   foreach my $task (@{$tasks}) {
      my $seqNum = $task->{sequenceNumber};
	  #$eh->warn("Seq Num = $seqNum");
	  #Calculate initial duration in days and duration floor
	  my $durationInDays = $task->{duration};
	  $durationInDays = $durationInDays / $project->{hoursPerDay} if( $project->{durationUnits} == "hours" );
	  #$eh->warn("Duration in Days: ".$durationInDays);
	  my $durationFloor = floor($durationInDays);
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
				  $durationInDays += $predDayPart;
				  $durationFloor = floor($durationInDays);
			   } 
	           
			   #$eh->warn("Duration in Days is now: ".$durationInDays);
	           #$eh->warn("Duration Floor is now: ".$durationFloor);
			   
			   #$eh->warn("Pred End Date is now: ".$dt->epochToSet($predEndDate));
			   
			   #Set the start date of this task to the end date of the predecessor and update the hash
			   $task->{startDate} = $predEndDate;
			   #$eh->warn("Start Date is now: ".$dt->epochToSet($task->{startDate}));
	           #Adjust end date for change in start date and update the hash
	           $task->{endDate} = $dt->addToDateTime($task->{startDate}, 0, 0, $durationFloor);
			   #$eh->warn("End Date is now: ".$dt->epochToSet($task->{endDate})."\n\n");
			   #Update the database
			   $self->setCollateral("PM_task","taskId",$task,1,0,"projectId",$projectId);
		    } 
         }
      }
	  
	  #Adjust duration of days to only include the part of the day used
      $durationInDays = $durationInDays - floor($durationInDays);
	  #$eh->warn("Day Part left over is: $durationInDays \n\n");
	  
	  
	  #add this task to the taskHash
	  $taskHash->{$seqNum} = { 
	                           'startDate'=>$task->{startDate}, 
	                           'endDate'=>$task->{endDate}, 
							   'duration'=>$task->{duration}, 
							   'dayPart'=>$durationInDays
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
      }
	  $props->{lastUpdateDate} = $dt->time();
      $props->{lastUpdatedBy} = $user->userId;
	  
	  $self->setCollateral("PM_task","taskId",$props,1,0,"projectId",$projectId);
   }
   
   #Rearrange predecessors
   #$self->_arrangePredecessors($project);
   
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
    return $privilege->insufficient unless ($user->isInGroup($self->canView));
	
	$var->{'extras'} = $config->get("extrasURL")."/wobject/ProjectManager";
	$var->{'extras.base'} = $config->get("extrasURL");
	
    #Set Some Style stuff
	$style->setLink($var->{'extras'}."/subModal.css",{rel=>"stylesheet",type=>"text/css"});
	$style->setLink($var->{'extras.base'}."/calendar/calendar-win2k-1.css",{rel=>"stylesheet",type=>"text/css"});
	
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
	   
	   $hash->{'task.number'} = $seq;
	   $hash->{'task.number.id'} = "task~~".$id."~~rowId";
	   $hash->{'task.name'} = $row->{taskName};
	   	  
	   if($canEdit) {
	      my $startId = "start_".$id."_formId";
	      my $endId = "end_".$id."_formId";
		  my $durId = "duration_".$id."_formId";
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
			-extras=>qq|onfocus="doCalendar(this.id);" class="taskdate" onblur="adjustTaskTimeFromDate(this,document.getElementById('$endId'),document.getElementById('$durId'),this,false,document.getElementById('$predId'),document.getElementById('$origStartFieldId'),document.getElementById('$origEndFieldId'),$seq);"|
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
			-extras=>qq|class="taskdate" onfocus="doCalendar(this.id);" onblur="adjustTaskTimeFromDate(document.getElementById('$startId'),this,document.getElementById('$durId'),this,false,document.getElementById('$predId'),document.getElementById('$origStartFieldId'),document.getElementById('$origEndFieldId'),$seq);"|
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
				-extras=>qq|class="taskduration" onchange="adjustTaskTimeFromDuration(document.getElementById('$startId'),document.getElementById('$endId'),this,false,document.getElementById('$predId'),document.getElementById('$origStartFieldId'),document.getElementById('$origEndFieldId'),$seq);" |
				});
			 
	      }
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
	
	
	#Rowspan of gaant chart is 4 plus number of tasks
	$var->{'project.gaant.rowspan'} = 4 + $taskLength;
	
	$var->{'project.ganttChart'} = $self->www_drawGanttChart($projectId, $data, $var);
		
	$var->{'task.back.label'} = $i18n->get("task back label");
	$var->{'task.back.url'} = $self->getUrl;
	
	return $style->process($self->processTemplate($var,$self->getValue("projectDisplayTemplateId")),$self->getValue("styleTemplateId"));
}

#-------------------------------------------------------------------
sub www_drawGanttChart {
	my $self = shift;
	my $var = {};
	#Set Method Helpers
	my ($session,$privilege,$form,$db,$dt,$i18n,$user) = $self->setSessionVars;
	my $config = $session->config;
	my $style = $session->style;
	my $eh = $session->errorHandler;
	
	#Check Privileges
    return $privilege->insufficient unless ($user->isInGroup($self->canView));
	
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
		my $predecessor = $task->{dependants};
		my $resource = $task->{resourceId};
		
		if($resource) {
		   $hash->{'task.hasResource'} = "true";
		   my $u = WebGUI::User->new($session,$resource);
		   my $username = $u->username;
		   
		   my $firstName = $u->profileField('firstName');
		   my $lastName = $u->profileField('lastName');
		   if($firstName && $lastName) {
		      $username = $firstName." ".$lastName;
		   }
		   $hash->{'task.resource.name'} = $username;
		}		
		
		my $durationFloor = floor($duration);
		$duration = $duration / $hoursPerDay if( $dunits == "hours" );
		#Set duration to 1 day if it's a milestone
		#$duration = 1 unless ($duration);
		
		#Each day is 23 pixels so calculate the days and round
		unless ($duration) {
		   $hash->{'task.div.width'} = $pixelSize;
		} else {
		   $hash->{'task.div.width'} = int(($duration * $pixelSize)) || 3;
		}
	    
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
			  $durationFloor = floor($duration);
		   }
		   
		}
		
		#Adjust top for MSIE
		my $divTop = ($session->env->get("HTTP_USER_AGENT") =~ /msie/i) ? 45 : 43;
		#Start at 45 px and add 20px as the start of the new task
		$hash->{'task.div.top'} = $divTop + (22*$taskCount);
		
		#Interval includes current day so add 1
		my $daysFromStart = ($dt->getDaysInInterval($startMonth,$startDate) + 1);
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
		$var->{'project.task.array'} .= qq|"$seq": { "id":"$id" ,"start":"$startDate" ,"end":"$endDate", "duration":"$rduration", "dayPart":"$duration", "predecessor":"$predecessor" }|;
		$taskCount++;
		   
		$taskHash->{$seq} = { 
	                           'startDate'=>$task->{startDate}, 
	                           'endDate'=>$task->{endDate}, 
							   'duration'=>$task->{duration}, 
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
