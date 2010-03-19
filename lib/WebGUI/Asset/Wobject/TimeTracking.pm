package WebGUI::Asset::Wobject::TimeTracking;

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
use POSIX qw(ceil floor);
use Moose;
use WebGUI::Definition::Asset;
extends 'WebGUI::Asset::Wobject';
define assetName => ['assetName', 'Asset_TimeTracking'];
define icon      => 'timetrack.gif';
define tableName => 'TT_wobject';
property userViewTemplateId => (
			fieldType   => "template",  
			default     => 'TimeTrackingTMPL000001',
			tab         => "display",
			namespace   => "TimeTracking_user", 
			hoverHelp   => ['userViewTemplate hoverhelp', 'Asset_TimeTracking'],
		    label       => ['userViewTemplate label', 'Asset_TimeTracking'],
		);
property managerViewTemplateId => (
			fieldType   => "template",  
			default     => 'TimeTrackingTMPL000002',
			tab         => "display",
			namespace   => "TimeTracking_manager", 
			hoverHelp   => ['managerViewTemplate hoverhelp', 'Asset_TimeTracking'],
		    label       => ['managerViewTemplate label', 'Asset_TimeTracking'],
		);
property timeRowTemplateId => (
			fieldType   => "template",  
			default     => 'TimeTrackingTMPL000003',
			tab         => "display",
			namespace   => "TimeTracking_row", 
			hoverHelp   => ['timeRowTemplateId hoverhelp', 'Asset_TimeTracking'],
		    label       => ['timeRowTemplateId label', 'Asset_TimeTracking'],
		);
property groupToManage => (
			fieldType   => "group",
			default     => 3,
			tab         => "security",
			hoverHelp   => ['groupToManage hoverhelp', 'Asset_TimeTracking'],
			label       => ['groupToManage label', 'Asset_TimeTracking'],
		);
property pmIntegration => (
		    fieldType   => "yesNo",
			default     => 0,
			tab         => "properties",
			hoverHelp   => ["Choose yes to pull projects and task information from the various project management assets on your site", 'Asset_TimeTracking'],
			label       => ["Project Management Integration", 'Asset_TimeTracking'],
		);




use WebGUI::Asset::Wobject::ProjectManager;

#-------------------------------------------------------------------

=head2 prepareView 

=cut

sub prepareView {
	my $self = shift;
	$self->SUPER::prepareView();
	my $template;
    $template = WebGUI::Asset::Template->newById($self->session, $self->userViewTemplateId);
    if (!$template) {
        WebGUI::Error::ObjectNotFound::Template->throw(
            error      => qq{Template not found},
            templateId => $self->userViewTemplateId,
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

=head2 getDaysInWeek 

=cut

sub getDaysInWeek {
	my $self = shift;
	my $week = $_[0];
	return [] unless $week;
	
	my ($session,$dt,$eh) = $self->getSessionVars("datetime","errorHandler");
	my $i18n = WebGUI::International->new($session,'Asset_TimeTracking');
	
    #Week View Below
	my ($dayStart,$dayEnd) = $dt->dayStartEnd($week);
    my $dayOfWeek = $dt->getDayOfWeek($dayStart);
    my $sundayAdjust = ((7 - $dayOfWeek) - 7);
	my $weekStart = $dt->addToDateTime($dayStart,0,0,$sundayAdjust,1);
	tie my %hash, "Tie::IxHash";
	$hash{"0"} = $dt->epochToSet($weekStart);
	for (my $i = 1; $i < 7; $i++) {
	   $hash{$i} = $dt->epochToSet($dt->addToDate($weekStart,0,0,$i));
	}
	
	return \%hash;
}

#-------------------------------------------------------------------

=head2 getSessionVars 

=cut

sub getSessionVars {
   my $self = shift;
   my @vars = @_;
   my $session = $self->session;
   return ($session) unless (scalar(@vars) > 0);
   
   my @list = ();
   push(@list, $session);
   
   foreach my $var (@vars) {
         push(@list, $session->$var);
   }   
   return @list;
}


#-------------------------------------------------------------------

=head2 view 

=cut

sub view {
	my $self = shift;
	my $var = $self->get;
	
	my ($session,$privilege,$form,$db,$dt,$user,$eh,$config) = $self->getSessionVars("privilege","form","db","datetime","user","errorHandler","config");    
	my $i18n = WebGUI::International->new($session,'Asset_TimeTracking');
	$var->{'extras'} = $session->url->make_urlmap_work($config->get("extrasURL"))."/wobject/TimeTracking"; 
	
	if($user->isInGroup($self->groupToManage)) {
	   $var->{'project.manage.url'} = $self->getUrl("func=manageProjects");
	   $var->{'project.manage.label'} = $i18n->get("project manage label");
	}
	
	$var->{'form.header'} = WebGUI::Form::formHeader($session,{
				action=>$self->getUrl,
				extras=>q|name="editTimeForm" onsubmit="return validateForm(this);"|
				});
	$var->{'form.header'} .= WebGUI::Form::hidden($session, {
				-name=>"func",
				-value=>"editTimeEntrySave"
				});
	$var->{'form.header'} .= WebGUI::Form::hidden($session, {
				-name=>"rowTotal",
				-value=>""
				});

	$var->{'form.footer'} = WebGUI::Form::formFooter($session);
	
	$var->{'js.alert.removeRow.error'} = $i18n->get("There must be at least one row.  Please add more rows if you wish to delete this one");
	$var->{'js.alert.validate.hours.error'} = $i18n->get("You may not submit more hours than are available during any given week.");
	$var->{'js.alert.validate.incomplete.error'} = $i18n->get("The highlighted fields are required if you wish to submit this form.");
	
	$var->{'form.timetracker'} = $self->www_buildTimeTable($var);
	
	return $self->processTemplate($var, undef, $self->{_viewTemplate});
}

#-------------------------------------------------------------------

=head2 www_editTimeEntrySave 

=cut

sub www_editTimeEntrySave {
   	my $self = shift;
	my ($session,$privilege,$form,$db,$user,$eh,$dt) = $self->getSessionVars("privilege","form","db","user","errorHandler","datetime");
    
	return $privilege->insufficient unless ($self->canView);
	
	my $now = $dt->time();
	my $currUser = $user->userId;
	
	my $props = {};
	my $reportId = $form->get("reportId");
	
	$props->{reportId} = $reportId;
	$props->{startDate} = $form->process("startDate","hidden");
	$props->{endDate} = $form->process("endDate","hidden");
	$props->{reportComplete} = $form->process("isComplete","checkbox") || 0;
	$props->{resourceId} = $form->process("resourceId","hidden"); 
	if ($reportId eq "new") {
		$props->{creationDate} = $now;
		$props->{createdBy} = $currUser;
	}
	$props->{lastUpdatedBy} = $currUser;
	$props->{lastUpdateDate} = $now;
	$reportId = $self->setCollateral("TT_report","reportId",$props,0,1);
	
	my %deltaHours = ();

	foreach my $entry (@{$db->buildArrayRefOfHashRefs("SELECT * FROM TT_timeEntry WHERE reportId = ?", [$reportId])}) {
		$deltaHours{$entry->{projectId}}{$entry->{taskId}} -= $entry->{hours};
	}

	my $rowTotal = $form->get("rowTotal");
	my @entryIds = ();
	for (my $i = 1; $i <= $rowTotal; $i++) {
		my $entryId = $form->get("taskEntryId_$i");
		next unless $entryId;

		my $props = {};
		$props->{entryId} = $entryId;
		$props->{reportId} = $reportId;
		$props->{taskDate} = $form->process("taskDate_$i","selectBox");
		$props->{projectId} = $form->process("projectId_$i","selectBox");
		$props->{taskId} = $form->process("taskId_$i","selectBox");
		$props->{hours} = $form->process("hours_$i","float");
		$props->{comments} = $form->process("comments_$i","text");
		$deltaHours{$props->{projectId}}{$props->{taskId}} += $props->{hours};

		next unless $props->{taskDate} and $props->{projectId} and $props->{taskId} and $props->{hours};
		$entryId = $self->setCollateral("TT_timeEntry","entryId",$props,0,0);
		push @entryIds, $entryId;
	}
	
	# Clobber other entries.  We can't just do this beforehand
	# because otherwise setCollateral will fail.
	if(scalar(@entryIds) > 0) {
		$db->write("DELETE FROM TT_timeEntry WHERE reportId = ? AND entryId NOT IN (".join(', ', ('?') x @entryIds).")", [$reportId, @entryIds]);
	}
	
	# Update Project Management App if integrated
	if ($self->pmIntegration) {
		foreach my $projectId (keys %deltaHours) {
			foreach my $taskId (keys %{$deltaHours{$projectId}}) {
				my $deltaHours = $deltaHours{$projectId}{$taskId};
				if (my $pmAsset = WebGUI::Asset::Wobject::ProjectManager->getProjectInstance($session, $projectId)) {
					$pmAsset->updateProjectTask($taskId, $projectId, $deltaHours);
				}
			}
		}
	}
		  
	return "";
}

#-------------------------------------------------------------------

=head2 www_deleteProject 

=cut

sub www_deleteProject {
   	my $self = shift;
    my ($session,$privilege,$form,$db,$user,$eh,$config) = $self->getSessionVars("privilege","form","db","user","errorHandler","config");
	my $i18n = WebGUI::International->new($session,'Asset_TimeTracking');
	
	#Check Privileges
    return $privilege->insufficient unless ($user->isInGroup($self->groupToManage));
    my $projectId = $form->get("projectId");
	my ($count) = $db->quickArray("select count(*) from TT_timeEntry where projectId=".$db->quote($projectId));
    
	if($count > 0) {
	   my $error = $i18n->get("This project cannot be deleted as it is currently being used by existing time entry records and would corrupt this data.  The records must be deleted if you wish to remove this project");
	   return $self->www_manageProjects($error);
	}
	
	$db->write("delete from TT_projectResourceList where projectId=".$db->quote($projectId));
	$db->write("delete from TT_projectTasks where projectId=".$db->quote($projectId));
	$db->write("delete from TT_projectList where projectId=".$db->quote($projectId));
	return $self->www_manageProjects();
}

#-------------------------------------------------------------------

=head2 www_editProject 

=cut

sub www_editProject {
	my $self = shift;
    my ($session,$privilege,$form,$db,$user,$eh,$config) = $self->getSessionVars("privilege","form","db","user","errorHandler","config");
	my $i18n = WebGUI::International->new($session,'Asset_TimeTracking');
	
	#Check Privileges
    return $privilege->insufficient unless ($user->isInGroup($self->groupToManage));
    my $projectId = $_[0] || $form->get("projectId") || "new";
	my $taskError = qq|<br><span style="color:red;font-weight:bold">$_[1]</span>| if($_[1]);
	my $extras = $session->url->make_urlmap_work($config->get("extrasURL"))."/wobject/TimeTracking"; 
	
	my $project = $db->quickHashRef("select * from TT_projectList where projectId=".$db->quote($projectId));
	#Build Form
    my $f = WebGUI::HTMLForm->new($self->session,-action=>$self->getUrl);
    $f->hidden( 
       -name=>"func",
	   -value=>"editProjectSave" 
    );
    $f->hidden( 
       -name=>"projectId", 
       -value=>$projectId 
    );
	$f->hidden( 
       -name=>"action", 
       -value=>"post"
    );
    $f->readOnly(
		-label=>$i18n->get("edit project id label"),
		-hoverHelp => $i18n->get('edit project id hoverhelp'),
		-value=>$projectId
    );
    $f->text(
		-name  => "projectName",
		-value => $form->get("projectName") || $project->{projectName},
		-hoverHelp => $i18n->get('edit project name hoverhelp'),
		-label => $i18n->get('edit project name label')
    );
	
	tie my %users, "Tie::IxHash";
	%users = $db->buildHash("select userId,username from users where userId not in ('1','3') order by username");
	my $resources = $db->buildArrayRef("select resourceId from TT_projectResourceList where projectId=".$db->quote($projectId));
	
	$f->selectList(
		-name  => "resources",
		-options => \%users,
		-value => $resources,
		-hoverHelp => $i18n->get('edit project resource hoverhelp'),
		-label => $i18n->get('edit project resource label')
    );
	
	#Add Tasks
	my $taskNameLabel = $i18n->get("New Task Name");
	my $taskAddButtonLabel = $i18n->get("Add");
	my $taskTitleLabel = $i18n->get("Tasks");
	my $taskDeletePrompt = $i18n->echo("Are you sure you want to delete this activity?");
	$taskDeletePrompt =~ s/'/\\'/g;
	my $taskLabel = $i18n->get("edit project tasks label");
	
	my $taskLoop = "";
	tie my %tasks, "Tie::IxHash";
	%tasks = $db->buildHash("select taskId,taskName from TT_projectTasks where projectId=".$db->quote($projectId));
	foreach my $taskId (keys %tasks) {
	   my $deleteUrl = $self->getUrl("func=editProjectSave;taskId=".$taskId.";action=deleteTask");
	   my $taskName = $tasks{$taskId};
	   $taskLoop .= qq|
	      <tr>
	         <td width="95%" class="listItem">$taskName</td>
		     <td width="5%">
			    <span style="cursor:pointer;" onclick="if(confirm('$taskDeletePrompt')){window.location.href='$deleteUrl';}">
			       <img border="0" src="$extras/delete.gif" />
				</span>
		     </td>
	      </tr>|;
	}
	
	my $html = qq|
	   <table id="resources">
	      <tbody>
	      <tr>
	         <td colspan="2">
		        <input type="text" name="newTaskName" value="$taskNameLabel" style="font-size:8pt" onclick="if(this.value=='$taskNameLabel'){this.value='';}" /> 
				<input type="submit" value="$taskAddButtonLabel" style="font-size:8pt" onclick="this.form.action.value='addTask'" />$taskError
		     </td>
	      </tr>
	      <tr>
		     <td colspan="2" style="background-color:#F0F0F0;font-size:9pt;border-bottom:solid silver 2px;font-weight:bold;letter-spacing:2px;text-align:center;">$taskTitleLabel</td>	
   	      </tr>
		  $taskLoop
		 </tbody>
	   </table>|;
    $f->raw(qq|<tr><td class="formDescription">$taskLabel</td><td class="tableData">$html</td></tr>|);
	$f->submit();
	my $ac = $self->getAdminConsole;
	my $newProjectUrl = $self->getUrl('func=editProject;projectId=new');
	$ac->addSubmenuItem($newProjectUrl,$i18n->get("add project label"));
	return $ac->render($f->print,$i18n->get("edit project screen label"));

}

#-------------------------------------------------------------------

=head2 www_editProjectSave 

=cut

sub www_editProjectSave {
	my $self = shift;
    my ($session,$privilege,$form,$db,$dt,$user,$eh) = $self->getSessionVars("privilege","form","db","datetime","user","errorHandler");    
	my $i18n = WebGUI::International->new($session,'Asset_TimeTracking');
	
	#Check Privileges
    return $privilege->insufficient unless ($user->isInGroup($self->groupToManage));
	
	my $action = $form->get("action");
		
	if ($action eq "deleteTask") {
	   my $taskId = $form->get("taskId");
	   my ($pid) = $db->quickArray("select projectId from TT_projectTasks where taskId=".$db->quote($taskId));
	   $db->write("delete from TT_projectTasks where taskId=".$db->quote($taskId));
	   return $self->www_editProject($pid);
	}
	
	#Add Project
	my $projectId = $form->process("projectId","hidden") || "new";
	my $props = {};
	$props->{projectId} = $projectId;
	$props->{projectName} = $form->process("projectName","text") || "Not Named";
	if($projectId eq "new") {
       $props->{creationDate} = $dt->time();
       $props->{createdBy} = $user->userId;
    }
	$props->{lastUpdatedBy} = $user->userId;
    $props->{lastUpdateDate} = $dt->time();
	$projectId = $self->setCollateral("TT_projectList","projectId",$props,0,1);
	
	#Add Resources
	$db->write("delete from TT_projectResourceList where projectId=".$db->quote($projectId));
	my @resources = $form->process("resources","selectList");
	foreach (@resources) {
	   $db->write("insert into TT_projectResourceList (projectId,resourceId) values (".$db->quote($projectId).",".$db->quote($_).")");
	}
	
	#Add Tasks
	my $newTaskLabel = $i18n->get("New Task Name");
	my $newTaskValue = $form->process("newTaskName","text");
	my $newTaskId = "";
	if($newTaskValue ne $newTaskLabel && $newTaskValue ne "") {
	   $props = {};
	   $props->{taskId} = "new";
	   $props->{projectId} = $projectId;
	   $props->{taskName} = $newTaskValue;
	   $newTaskId = $self->setCollateral("TT_projectTasks","taskId",$props,0,0);
	}
	
	if($action eq "addTask") {
	   my $taskError = "";
	   $taskError = $i18n->get("No  name was entered for new task") if($newTaskId eq "");
	   return $self->www_editProject($projectId,$taskError);
	}
	
	return $self->www_manageProjects();
  
}

#-------------------------------------------------------------------

=head2 www_manageProjects 

=cut

sub www_manageProjects {
	my $self = shift;
    my ($session,$privilege,$form,$db,$dt,$user,$eh,$config) = $self->getSessionVars("privilege","form","db","datetime","user","errorHandler","config");    
	my $i18n = WebGUI::International->new($session,'Asset_TimeTracking');
	
	#Check Privileges
    return $privilege->insufficient unless ($user->isInGroup($self->groupToManage));
	
	my $pnLabel = $i18n->get("manage project name label");
	my $atLabel = $i18n->get("manage project available task label");
	my $resLabel = $i18n->get("manage project resource label");
	my $extras = $session->url->make_urlmap_work($config->get("extrasURL"))."/wobject/TimeTracking"; 
	my $errorMessage = "";
	$errorMessage = qq|<span style="color:red;font-weight:bold">$_[0]</span>| if($_[0]);
	
	 my $output .= qq|
       $errorMessage
	   <div id="wrapper">
	      <table id="mainDash">
	         <tbody>
	            <tr>
	               <td class="header" width="31%">$pnLabel</td>
		           <td class="header" width="31%">$atLabel</td>
		           <td class="header" width="31%">$resLabel</td>
		           <td width="7%">&#160;</td>
	            </tr>
	|;
	my $projects = $db->buildHashRef("select projectId, projectName from TT_projectList where assetId=".$db->quote($self->getId));
	
	my $count = 0;
	foreach my $projectId (keys %{$projects}) {
	   my $projectName = $projects->{$projectId};
	   my $projectId = $projectId;
	   my @tasks = $db->buildArray("select taskName from TT_projectTasks where projectId=".$db->quote($projectId));
	   my $taskList = join("<br />",@tasks);
	   my @resources = $db->buildArray("select resourceId from TT_projectResourceList where projectId=".$db->quote($projectId));
  	   for(my $i = 0; $i < scalar(@resources); $i++) {
	      my $u = WebGUI::User->new($session,$resources[$i]);
		  my $fname = $u->profileField("firstName");
		  my $lname = $u->profileField("lastName");
		  my $r = $u->username;
		  if($fname && $lname) {
		    $r = $fname." ".$lname;
		  }
		  $resources[$i] = $r;
	   }
	   my $resourceList = join("<br />",@resources);
	   
	   my $editUrl      = $self->getUrl("func=editProject;projectId=".$projectId);
       my $editIcon     = $session->icon->getBaseURL."edit.gif";
	   my $editLink     = qq|<a href="$editUrl"><img src="$editIcon" border="0"|.$i18n->get('Edit', 'Icon').q| /></a>|;
	   my $deletePrompt = $i18n->echo("Deleting this project will also delete all associated resources and tasks.  Are you sure you'd like to continue?");
	   $deletePrompt    =~ s/'/\\'/g;
	   my $deleteUrl    = $self->getUrl("func=deleteProject;projectId=".$projectId);
	   my $deleteIcon   = $session->icon->getBaseURL."delete.gif";
       my $deleteLink   = qq|<span style="cursor:pointer;" onclick="if(confirm('$deletePrompt')){window.location.href='$deleteUrl';}"><img src="$deleteIcon" border="0" |.$i18n->get('Delete', 'Icon').q|/></span>|;
	   
	   my $cl = "";
	   $cl = q|class="alt"| if($count++ % 2 eq 0);
	   	   
	   $output .= qq|
	     <tr $cl>
		    <td>$projectName</td>
			<td>$taskList</td>
			<td>$resourceList</td>
			<td>$editLink &#160; $deleteLink</td>
		 </tr>
	   |;
	}
	
	my $newProjectUrl = $self->getUrl('func=editProject;projectId=new');
	if(scalar(keys %{$projects}) == 0) {
	   my $noProjects = sprintf($i18n->get("no project message"),$newProjectUrl);
	   $output .= qq|<tr><td class="tableData" colspan="4">$noProjects</td></tr>|
	}
	
	$output .= "</tbody></table></div>";
	
	my $css = q|
	   <style type="text/css">
	      #wrapper {
		     width:645px;
	      }
	      #wrapper div.title {
		     width:100%;
		     font-size:13pt;
		     font-weight:bold;
		     font-variant:small-caps;
		     text-align:left;
		     font-family:arial;		
		     border-bottom:solid gray 2px;
		     margin-bottom:5px;
	      }
		  #mainDash {			
			border-top:solid gray 3px;
			border-bottom:solid gray 3px;
			margin:0px;									
			width:100%;
		  }
		  #mainDash td {
			font-family:arial;
			font-size:9pt;
		  }	
		  #mainDash td.header {
		    border-bottom:solid silver 2px;
			font-weight:bold;
		  }
		  #mainDash td.alt {
		     background-color:#F0F0F0;
		  }
       </style>
	|;
	
	$output = $css.$output;
	
	my $ac = $self->getAdminConsole;
	$ac->addSubmenuItem($newProjectUrl,$i18n->get("add project label"));
	return $ac->render($output,$i18n->get("manage projects screen label"));
}

#-------------------------------------------------------------------

=head2 www_buildTimeTable 

=cut

sub www_buildTimeTable {
   	my $self = shift;
	my $viewVar = $_[0];
	my $var = {};	
	$var->{'extras'} = $viewVar->{'extras'}; 
	my ($session,$dt,$eh,$form,$db,$user,$privilege) = $self->getSessionVars("datetime","errorHandler","form","db","user","privilege");
	my $i18n = WebGUI::International->new($session,'Asset_TimeTracking');
	
	return $privilege->insufficient unless ($self->canView);
	
	my $pmIntegration = $self->pmIntegration;
	
	my $week = $form->get("week") || $dt->time;
	
	my $nextWeek = $dt->addToDate($week,0,0,7);
	my $lastWeek = $dt->addToDate($week,0,0,-7);
	
	my $daysInWeek = $self->getDaysInWeek($week);
	
	my $weekStart = $daysInWeek->{"0"};	
	my $weekEnd = $daysInWeek->{"6"};
	
	#It's this week, don't allow next week url to be seen
    $var->{'report.nextWeek.url'} = $self->getUrl("func=view;week=$nextWeek");
	$var->{'report.lastWeek.url'} = $self->getUrl("func=view;week=$lastWeek");
	
	$var->{'time.report.header'} = sprintf($i18n->get("time report header"),$weekEnd);
	$var->{'time.report.totalHours.label'} = $i18n->get("total hours label");
	$var->{'time.report.date.label'} = $i18n->get("time report date label");
	$var->{'time.report.project.label'} = $i18n->get("time report project label");
	$var->{'time.report.task.label'} = $i18n->get("time report task label");
	$var->{'time.report.hours.label'} = $i18n->get("time report hours label");
	$var->{'time.report.comments.label'} = $i18n->get("time report comments label");
	$var->{'time.add.row.label'} = $i18n->get("Add Row");
	$var->{'time.save.label'} = $i18n->get("Save");
	$var->{'time.report.complete.label'} = $i18n->get("Report Complete");
	
	
	#my ($junk,$weekEnd) = $dt->dayStartEnd($daysInWeek->{"6"});
	
	#Rebuild days in week hash to contain set values
	tie my %setDaysHash,"Tie::IxHash";
	foreach my $day (keys %{$daysInWeek}) {
	   my $set = $daysInWeek->{$day};
	   $setDaysHash{$set} = $set;
	}
	
	#Build Project List
	tie my %projectList, "Tie::IxHash";
	%projectList = $db->buildHash("select a.projectId, a.projectName from TT_projectList a, TT_projectResourceList b where a.assetId=? and a.projectId=b.projectId and b.resourceId=? order by a.projectName",[$self->getId,$user->userId]);
	
	my $pmAsset;
	if($pmIntegration) {
	   #Build project list and task lists from project management app
	   my ($pmAssetId) = $db->quickArray("select a.assetId from PM_wobject a, asset b where a.assetId=b.assetId and b.state not like 'trash%'");   
	   if($pmAssetId) {
	      $pmAsset = WebGUI::Asset->newById($session,$pmAssetId);
	      my %pmProjectList = %{$pmAsset->getProjectList($user->userId)};
		  %projectList = WebGUI::Utility::sortHash((%projectList,%pmProjectList));
	   }
	} 
	
	my $chooseLabel = $i18n->get("Choose One");
	#Build Task Lists based on Project Ids
	tie my %taskList, "Tie::IxHash";
	#Build task list javascript:
	my $counter = 0;
	my $js = "{\n";
	foreach my $projectId (keys %projectList) {
	   tie my %taskHash, "Tie::IxHash";
	   %taskHash = $db->buildHash("select taskId, taskName from TT_projectTasks where projectId=?",[$projectId]);
	   if($pmAsset && scalar(keys %taskHash) == 0) {
	      my $pmTaskRef = $pmAsset->getTaskList($projectId,$user->userId) || {};
		  %taskHash = %{$pmTaskRef};
	   }
	   %taskHash = (""=>$chooseLabel,%taskHash);
	   $taskList{$projectId} = \%taskHash;
	   #Build JavaScript Hash
	   $js .= ",\n" if($counter++ > 0);
       $js .= qq|"$projectId": {|;
	   my $ind = 0;
	   foreach my $taskId (keys %taskHash) {
	      next if ($taskId eq "");
		  my $taskName = $taskHash{$taskId};
		  $js .= ",\n" if($ind++ > 0);
	      $js .= qq| "$taskId":"$taskName"|;
	   }
	   $js .= q| }|;   
	}
	$js .= "\n};\n";
	
	$viewVar->{'project.task.array'} = $js;
	
	#Set default project for project list
	%projectList = (""=>$chooseLabel,%projectList);
	
	my $resourceIdFromForm = $form->get("resourceId");
	my $resourceId = ($user->isInGroup($self->groupToManage) && $resourceIdFromForm)?$resourceIdFromForm:$user->userId;
	#Build Report Info
	my $report = $db->quickHashRef("select * from TT_report where resourceId=? and assetId=? and startDate=? and endDate=?",[$resourceId,$self->getId,$weekStart,$weekEnd]);	
	my $reportId = $report->{reportId};
	#$eh->warn($reportId);
	#Add Report Stuff to form header
	$viewVar->{'form.header'} .= WebGUI::Form::hidden($session, {
				-name=>"reportId",
				-value=>$reportId || "new"
				});
				
	$viewVar->{'form.header'} .= WebGUI::Form::hidden($session, {
				-name=>"startDate",
				-value=>$weekStart
				});
				
	$viewVar->{'form.header'} .= WebGUI::Form::hidden($session, {
				-name=>"endDate",
				-value=>$weekEnd
				});
				
	$viewVar->{'form.header'} .= WebGUI::Form::hidden($session, {
				-name=>"week",
				-value=>$week
				});
							
	$viewVar->{'form.header'} .= WebGUI::Form::hidden($session, {
				-name=>"resourceId",
				-value=>$resourceId
				});
	
	my $reportComplete = $report->{reportComplete};
	$var->{'form.isComplete'} = WebGUI::Form::checkbox($session, {
	              -name=>"isComplete",
				  -value=>1,
				  -checked=>$reportComplete
				});
	#Build Entries Loop
	my $entries = $db->buildArrayRefOfHashRefs("select * from TT_timeEntry where reportId=? order by taskDate",[$reportId]);
	my $rowCount = 1;
	my @timeEntries = ();
	
	my $totalHours = 0;
	foreach my $entry (@{$entries}) {
	   my $hash = {};
	   push (@timeEntries,$self->_buildRow($entry,$rowCount++,\%setDaysHash, \%projectList, \%taskList,$hash,$reportComplete));
	   $totalHours += $hash->{'entry.hours'};
	}
	
	$var->{'report.isComplete'} = $reportComplete;
	$var->{'time.totalHours'} = $totalHours;
	
	#Seed time tracker with 10 empty rows and build the dummy row
	unless($reportComplete) {
	   for( my $i = $rowCount; $i < ($rowCount + 10); $i++) {
	      push(@timeEntries,$self->_buildRow(undef,$i,\%setDaysHash, \%projectList, \%taskList));
	   }
	   $self->_buildRow(undef,"x",\%setDaysHash, \%projectList, \%taskList,$var);
	}
	
	$var->{'time.entry.loop'} = \@timeEntries;
	$viewVar->{'time.report.rows.total'} = (scalar(@timeEntries)+1);
	
    return $self->processTemplate($var,$self->timeRowTemplateId);
}

#-------------------------------------------------------------------

=head2 _buildRow 

=cut

sub _buildRow {
	my $self = shift;
	my ($session,$dt,$eh,$form,$db,$user) = $self->getSessionVars("datetime","errorHandler","form","db","user");
	my $i18n = WebGUI::International->new($session,'Asset_TimeTracking');
	
	my $entry          = $_[0] || {};
	my $rowCount       = $_[1];
	my $daysInWeek     = $_[2];
	my $projectList    = $_[3];
	my $taskList       = $_[4];
	my $var            = $_[5] || {};
	my $reportComplete = $_[6] || 0;
	
	my $entryId = $entry->{entryId} || "new";
	$var->{'row.id'} = "row_$rowCount";
	#$var->{'row.id'} .= "_$entryId" if($entryId);
	my $projectId = $entry->{projectId};
	my $taskId = $entry->{taskId};
	
	#Task Entry Id
	$var->{'form.taskEntryId'} = WebGUI::Form::hidden($session,{
	                           -name=>"taskEntryId_$rowCount",
							   -value=>$entryId
							});

    ##Handle cases when a user has been removed from a project.  The projectList
    ##and taskList hash refs that have been passed in will not contain entries for
    ##their old project info

    #Entry Task
    tie my %taskHash, "Tie::IxHash";
    if ($projectId) {
        if (! exists $projectList->{$projectId}) {
            my $projectName = $db->quickScalar('select projectName from TT_projectList where projectId=?',[$projectId]);
            $projectList->{$projectId} = $projectName;
        }
        if (! exists $taskList->{$projectId}) {
            %taskHash = $db->buildHash("select taskId, taskName from TT_projectTasks where projectId=?",[$projectId]);
        }
        else {
            %taskHash = %{$taskList->{$projectId}};
        }
        #$eh->warn($projectId);
    }	
	my $chooseLabel = $i18n->get("Choose One");
    %taskHash = (""=>$chooseLabel,%taskHash);

	#Entry Date
	$var->{'entry.hours'} = $entry->{hours};
	if($reportComplete) {
	   $var->{'form.date'} = $entry->{taskDate};
	   $var->{'form.project'} = $projectList->{$projectId};
	   
	   $var->{'form.task'} = $taskHash{$entry->{taskId}};
	   $var->{'form.hours'} = $var->{'entry.hours'};
	   $var->{'form.comments'} = $entry->{comments};
	   
    }
    else {
	   tie my %days, "Tie::IxHash";
	   %days = (""=>$chooseLabel, %{$daysInWeek});
	   $var->{'form.date'} = WebGUI::Form::selectBox($session,{
				-name=>"taskDate_$rowCount",
				-value=>$entry->{taskDate},
				-options=>\%days,
				-extras=>qq|class="date-select"|
				});
	
	   my $taskName = "taskId_$rowCount";
	   $taskId = "taskId_".$rowCount."_formId";
	   $var->{'form.project'} = WebGUI::Form::selectBox($session,{
	            -name=>"projectId_$rowCount",
				-options=>$projectList,
				-value=>$projectId,
				-extras=>qq|onchange="changeOptions(this,document.getElementById('$taskId'));" class="pt-select"|
	            });

	   $var->{'form.task'} = WebGUI::Form::selectBox($session,{
	            -name=>$taskName,
				-options=>\%taskHash,
				-value=>$entry->{taskId},
				-extras=>qq|class="pt-select"|
	            });
	
	   #Entry Hours
	   $var->{'form.hours'} = WebGUI::Form::float($session, {
				-name=>"hours_$rowCount",
				-value=>$var->{'entry.hours'},
				-size=>5,
				-extras=>qq|onchange="recalcHours();"|
				});
	
	   #Entry Comments
 	   $var->{'form.comments'} = WebGUI::Form::text($session, {
	             -name=>"comments_$rowCount",
				 -value=>$entry->{comments},
				 -size=>40
				});
	}
	return $var;

}

1;
