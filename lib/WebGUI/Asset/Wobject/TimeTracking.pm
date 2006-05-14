package WebGUI::Asset::Wobject::TimeTracking;

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
sub _acWrapper {
	my $self = shift;
	my $html = shift;
	my $title = shift;
	my $i18n = WebGUI::International->new($self->session,'Asset_TimeTracking');
	my $ac = $self->getAdminConsole;
	$ac->setHelp('add/edit event','Asset_EventManagementSystem') unless $ac->getHelp;
	$ac->addSubmenuItem($self->getUrl('func=search'),$i18n->get("manage events"));
	$ac->addSubmenuItem($self->getUrl('func=manageEventMetadata'), $i18n->get('manage event metadata'));
	$ac->addSubmenuItem($self->getUrl('func=managePrereqSets'), $i18n->get('manage prerequisite sets'));
	$ac->addSubmenuItem($self->getUrl('func=manageRegistrants'), $i18n->get('manage registrants'));
	$ac->addSubmenuItem($self->getUrl('func=manageDiscountPasses'), $i18n->get('manage discount passes'));
	return $ac->render($html,$title);
}

#-------------------------------------------------------------------
sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my $i18n = WebGUI::International->new($session,'Asset_TimeTracking');
	my %properties;
	tie %properties, 'Tie::IxHash';
	%properties = (
		userViewTemplateId =>{
			fieldType=>"template",  
			defaultValue=>'TimeTrackingTMPL000001',
			tab=>"display",
			namespace=>"TimeTracking_user", 
			hoverHelp=>$i18n->get('userViewTemplate hoverhelp'),
		    label=>$i18n->get('userViewTemplate label')
		},
		managerViewTemplateId => {
			fieldType=>"template",  
			defaultValue=>'TimeTrackingTMPL000002',
			tab=>"display",
			namespace=>"TimeTracking_manager", 
			hoverHelp=>$i18n->get('managerViewTemplate hoverhelp'),
		    label=>$i18n->get('managerViewTemplate label')
		},
		timeRowTemplateId=>  {
			fieldType=>"template",  
			defaultValue=>'TimeTrackingTMPL000003',
			tab=>"display",
			namespace=>"TimeTracking_row", 
			hoverHelp=>$i18n->get('timeRowTemplateId hoverhelp'),
		    label=>$i18n->get('timeRowTemplateId label')
		},
		groupToManage => {
			fieldType=>"group",
			defaultValue=>3,
			tab=>"security",
			hoverHelp=>$i18n->get('groupToManage hoverhelp'),
			label=>$i18n->get('groupToManage label')
		}
	);
	push(@{$definition}, {
		assetName=>$i18n->get('assetName'),
		icon=>'timetrack.gif',
		autoGenerateForms=>1,
		tableName=>'TT_wobject',
		className=>'WebGUI::Asset::Wobject::TimeTracking',
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
	my $template;
	#if($user->isInGroup($self->get("groupToManage")) {
	#  $template = WebGUI::Asset::Template->new($self->session, $self->get("managerViewTemplateId"));
	#} else {
	   $template = WebGUI::Asset::Template->new($self->session, $self->get("userViewTemplateId"));
	#}
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
sub getDaysInWeek {
	my $self = shift;
	my $week = $_[0];
	return [] unless $week;
	
	my ($session,$dt,$i18n,$eh) = $self->getSessionVars("datetime","i18n","errorHandler");
	
    #Week View Below
	my ($dayStart,$dayEnd) = $dt->dayStartEnd($week);
    my $dayOfWeek = $dt->getDayOfWeek($dayStart);
    my $sundayAdjust = (7 - $dayOfWeek);
    
	my $weekStart = $dt->addToDateTime($dayStart,0,0,$sundayAdjust,1);
	
	tie my %hash, "Tie::IxHash";
	$hash{"0"} = $weekStart;
	for (my $i = 1; $i < 7; $i++) {
	   $hash{$i} = $dt->addToDate($weekStart,0,0,$i);
	}
	
	return \%hash;
}

#-------------------------------------------------------------------
sub setSessionVars {
   my $self = shift;
   my $session = $self->session;
   my $i18n = WebGUI::International->new($session,'Asset_TimeTracking');
   
   return ($session,$session->privilege,$session->form,$session->db,$session->datetime,$i18n,$session->user);
}

#-------------------------------------------------------------------
sub getSessionVars {
   my $self = shift;
   my @vars = @_;
   my $session = $self->session;
   return ($session) unless (scalar(@vars) > 0);
   
   my @list = ();
   my $session = $self->session;
   push(@list, $session);
   
   foreach my $var (@vars) {
      if($var eq "i18n") {
	     push(@list,WebGUI::International->new($session,'Asset_TimeTracking'));
	  } else {
         push(@list, $session->$var);
      }
   }   
   return @list;
}


#-------------------------------------------------------------------
sub view {
	my $self = shift;
	my $var = $self->get;
	
	my ($session,$privilege,$form,$db,$dt,$i18n,$user) = $self->setSessionVars;
	my $config = $session->config;
	my $eh = $session->errorHandler;
	
	$var->{'extras'} = $config->get("extrasURL")."/wobject/TimeTracking"; 
	
	if($user->isInGroup($self->get("groupToManage"))) {
	   #Return manager screen
	   #$self->_buildManagerView($var);
	}
	
	$self->_buildUserView($var);
	
	return $self->processTemplate($var, undef, $self->{_viewTemplate});
}

#-------------------------------------------------------------------
sub www_editProject {
	my $self = shift;
    my ($session,$privilege,$form,$db,$dt,$i18n,$user,$eh) = $self->getSessionVars("privilege","form","db","datetime","i18n","user","errorHandler");    
	
	#Check Privileges
    return $privilege->insufficient unless ($user->isInGroup($self->get("groupToManage")));
    my $projectId = $form->get("projectId") || "new";
	
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
	
	$f->textarea(
		-name  => "taskList",
		-value => $project->{taskList},
		-hoverHelp => $i18n->get('edit project tasks hoverhelp'),
		-label => $i18n->get('edit project tasks label')
    );
	
	tie my %users, "Tie::IxHash";
	%users = $db->buildHash("select userId,username from users where userId not in (1,3)");
	my $resources = $db->buildArrayRef("select resourceId from TT_projectResourceList where projectId=".$db->quote($projectId));
	
	$f->selectList(
		-name  => "resources",
		-options => \%users,
		-value => $resources,
		-hoverHelp => $i18n->get('edit project resource hoverhelp'),
		-label => $i18n->get('edit project resource label')
    );
	
	return return $ac->render($f->print,$i18n->get("edit project screen label"));
	
}	

#-------------------------------------------------------------------
sub www_editProjectSave {
	my $self = shift;
    my ($session,$privilege,$form,$db,$dt,$i18n,$user,$eh) = $self->getSessionVars("privilege","form","db","datetime","i18n","user","errorHandler");    
	
	#Check Privileges
    return $privilege->insufficient unless ($user->isInGroup($self->get("groupToManage")));
 
  
}

#-------------------------------------------------------------------
sub www_manageProjects {
	my $self = shift;
    my ($session,$privilege,$form,$db,$dt,$i18n,$user,$eh) = $self->getSessionVars("privilege","form","db","datetime","i18n","user","errorHandler");    
	
	#Check Privileges
    return $privilege->insufficient unless ($user->isInGroup($self->get("groupToManage")));
	
	my $pnLabel = $i18n->get("manage project name label");
	my $atLabel = $i18n->get("manage project available task label");
	my $resLabel = $i18n->get("manage project resource label");
	
	my $output = qq|<table cellspacing="0" cellpadding="2" border="1">
	   <tbody>
	      <tr>
	         <td class="tableHeader">$pnLabel</td>
		     <td class="tableHeader">$atLabel</td>
		     <td class="tableHeader">$resLabel</td>
		     <td class="tableHeader">&#160;</td>
	      </tr>
	|;
	my $projects = $db->buildHashRef("select projectId, projectName from TT_projectList where assetId=".$db->quote($self->getId));
	
	foreach my $project (keys %{$projects}) {
	   my $projectName = $project->{projectName};
	   my $projectId = $project->{projectId};
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
	   my $editLink = "";
	   my $deleteLink = "";
	   $output .= qq|
	     <tr>
		    <td class="tableData">$projectName</td>
			<td class="tableData">$taskList</td>
			<td class="tableData">$resourceList</td>
			<td class="tableData">$editLink.$deleteLink</td>
		 </tr>
	   |;
	}
	if(scalar(keys %{$projects}) == 0) {
	   my $noProjects = sprintf($i18n->get("no project message"),$self->getUrl("func=editProject;projectId=new"));
	   $output .= qq|<tr><td class="tableData" colspan="4"></td></tr>|
	}
	
	$output .= "</tbody></table>";
	my $ac = $self->getAdminConsole;
	$ac->addSubmenuItem($self->getUrl('func=editProject;projectId=new'),$i18n->get("add project label"));
	return $ac->render($output,$i18n->get("manage projects screen label"));
}

#-------------------------------------------------------------------
sub _buildUserView {
	my $self = shift;
	my $var = $_[0];
	
	my ($session,$privilege,$form,$db,$dt,$i18n,$user,$eh) = $self->getSessionVars("privilege","form","db","datetime","i18n","user","errorHandler");
	my $pmAssetId = $self->getValue("pmAssetId");
	
	if($user->isInGroup($self->get("groupToManage"))) {
	   if($pmAssetId) {
	      #Add link to project dashboard
		  $var->{'project.manage.url'} = "";
	   } else {
	      $var->{'project.manage.url'} = $self->getUrl("func=manageProjects");
	   }
	   $var->{'project.manage.label'} = $i18n->get("project manage label");
	}
	
	$var->{'form.header'} = WebGUI::Form::formHeader($session,{
				action=>$self->getUrl,
				extras=>q|name="editTimeForm"|
				});
	$var->{'form.header'} .= WebGUI::Form::hidden($session, {
				-name=>"func",
				-value=>"editTimeEntrySave"
				});
				
	$var->{'form.footer'} = WebGUI::Form::formFooter($session);
	
	$var->{'form.timetracker'} = $self->_buildTimeTable($var);
	
}

#-------------------------------------------------------------------
sub _buildTimeTable {
   	my $self = shift;
	my $viewVar = $_[0];
	my $var = {};
	
	$var->{'extras'} = $viewVar->{'extras'}; 
	my ($session,$dt,$i18n,$eh,$form,$db,$user) = $self->getSessionVars("datetime","i18n","errorHandler","form","db","user");
	
	my $week = $form->get("week") || $dt->time;
	my $daysInWeek = $self->getDaysInWeek($week);
	my $endOfWeek = $dt->epochToSet($daysInWeek->{"6"});
	
	$var->{'time.report.header'} = sprintf($i18n->get("time report header"),$endOfWeek);
	$var->{'time.report.hours.label'} = $i18n->get("total hours label");
	$var->{'time.report.date.label'} = $i18n->get("time report date label");
	$var->{'time.report.project.label'} = $i18n->get("time report project label");
	$var->{'time.report.task.label'} = $i18n->get("time report task label");
	$var->{'time.report.hours.label'} = $i18n->get("time report hours label");
	$var->{'time.report.comments.label'} = $i18n->get("time report comments label");

	my $weekStart = $daysInWeek->{"0"};
	my ($junk,$weekEnd) = $dt->dayStartEnd($daysInWeek->{"6"});
	
	#Rebuild days in week hash to contain set values
	tie my %setDaysHash,"Tie::IxHash";
	foreach my $day (keys %{$daysInWeek}) {
	   $setDaysHash{$day} = $dt->epochToSet($daysInWeek->{$day});
	}
	
	#Build Entries Loop
	my $entries = $db->buildArrayRefOfHashRefs("select * from TT_timeEntry where resourceId=".$db->quote($user->userId)." and taskDate >= ".$db->quote($weekStart)." and taskDate <=".$db->quote($weekEnd));
	my $rowCount = 1;
	my @timeEntries = ();
	
	foreach my $entry (@{$entries}) {
	   push (@timeEntries,$self->_buildRow($entry,$rowCount++,\%setDaysHash));
	}
	
	#Seed time tracker with 10 empty rows
	for( my $i = $rowCount; $i < ($rowCount + 10); $i++) {
	   push(@timeEntries,$self->_buildRow(undef,$i,\%setDaysHash));
	}
	
	$var->{'time.entry.loop'} = \@timeEntries;
	$viewVar->{'time.report.rows.total'} = scalar(@timeEntries);
	
    return $self->processTemplate($var,$self->getValue("timeRowTemplateId"));
}

#-------------------------------------------------------------------
sub _buildRow {
	my $self = shift;
	my ($session,$dt,$i18n,$eh,$form,$db,$user) = $self->getSessionVars("datetime","i18n","errorHandler","form","db","user");
	
	my $var = {};
	my $entry = $_[0] || {};
	my $rowCount = $_[1];
	my $daysInWeek = $_[2];
	
	my $entryId = $entry->{entryId};
	$var->{'row.id'} = "row_$rowCount";
	$var->{'row.id'} .= "_$entryId" if($entryId);
	my $projectId = $entry->{projectId};
	my $taskId = $entry->{taskId};
	
	my $pmAssetId = $self->getValue("pmAssetId");
	
	#Entry Date
	tie my %days, "Tie::IxHash";
	%days = (""=>"Choose One", %{$daysInWeek});
	$var->{'form.date'} = WebGUI::Form::selectBox($session,{
				-name=>"taskDate_$rowCount",
				-value=>$entry->{taskDate},
				-options=>\%days
				});
	
	#Entry Project
	tie my %projectList, "Tie::IxHash";
	if($pmAssetId) {
	   #Build project list and task lists from project management app
	} else {
	   %projectList = $db->buildHash("select a.projectId, a.projectName from TT_projectList a, TT_projectResourceList b where a.assetId=".$db->quote($self->getId)." and a.projectId=b.projectId and b.resourceId=".$db->quote($user->userId));
	}

	#if(scalar(keys %projectList) == 0) {
	%projectList = (""=>"Choose One",%projectList);
	#}
	
	$var->{'form.project'} = WebGUI::Form::selectBox($session,{
	            -name=>"projectId_$rowCount",
				-options=>\%projectList,
				-value=>$projectId
	            });
	
	#Entry Task
	tie my %taskList, "Tie::IxHash";
	if($entryId) {
	   if($pmAssetId) {
	      #Build task list for project from project managmenet app
	   } else {
	      %taskList = $db->buildHash("select taskName, taskId from TT_projectTasks where projectId=".$db->quote($projectId));
	   }
	}
	
	%taskList = (""=>"Choose One",%taskList);
	
	$var->{'form.task'} = WebGUI::Form::selectBox($session,{
	            -name=>"taskId_$rowCount",
				-options=>\%taskList,
				-value=>$taskId
	            });
	
	#Entry Hours
	$var->{'form.hours'} = WebGUI::Form::float($session, {
				-name=>"hours_$rowCount",
				-value=>$entry->{hours},
				-size=>5
				});
	
	#Entry Comments
	$var->{'form.comments'} = WebGUI::Form::text($session, {
	             -name=>"comments_$rowCount",
				 -value=>$entry->{comments},
				 -size=>53
				});
	
	$var->{'delete.url'} = "";	
	return $var;

}

1;
