package WebGUI::Asset::Wobject::Navigation;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::IxHash;
use WebGUI::Asset::Wobject;
use WebGUI::ErrorHandler;
use WebGUI::Form;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::TabForm;
use WebGUI::URL;
use WebGUI::Utility;

our @ISA = qw(WebGUI::Asset::Wobject);



sub definition {
	my $class = shift;
	my $definition = shift;
	push(@{$definition}, {
		tableName=>'Navigation',
		className=>'WebGUI::Asset::Wobject::Navigation',
		properties=>{
			assetsToInclude=>{
				fieldType=>'checkList',
				defaultValue=>"descendants"
				},
			startType=>{
				fieldType=>'selectList',
				defaultValue=>"relativeToCurrentUrl"
				},
			startPoint=>{
				fieldType=>'text',
				defaultValue=>0
				},
			endPoint=>{
				fieldType=>'selectList',
				defaultValue=>55
				},
			showSystemPages=>{
				fieldType=>'yesNo',
				defaultValue=>0
				},
			showHiddenPages=>{
				fieldType=>'yesNo',
				defaultValue=>0
				},
			showUnprivilegedPages=>{
				fieldType=>'yesNo',
				defaultValue=>0
				}
			}
		});
        return $class->SUPER::definition($definition);
}

sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm;
	my ($descendantsChecked, $selfChecked, $pedigreeChecked, $siblingsChecked);
	my @assetsToInclude = split("\n",$self->getValue("assetsToInclude"));
	my $afterScript;
	foreach my $item (@assetsToInclude) {
		if ($item eq "self") {
			$selfChecked = 1;
		} elsif ($item eq "descendants") {
			$descendantsChecked = 1;
			$afterScript = "displayNavEndPoint = false;";
		} elsif ($item eq "siblings") {
			$siblingsChecked = 1;
		} elsif ($item eq "pedigree") {
			$pedigreeChecked = 1;
		}
	}
	$tabform->getTab("properties")->selectList(
		-name=>"startType",
		-options=>{
			specificUrl=>'Specific URL',
			relativeToCurrentUrl=>'Relative To Current URL',
			relativeToRoot=>'Relative To Root'
			},
		-value=>[$self->getValue("startType")],
		-label=>"Start Point Type",
		-extras=>'id="navStartType" onChange="changeStartPoint()"'
		);
	$tabform->getTab("properties")->readOnly(
		-label=>"Start Point",
		-value=>'<div id="navStartPoint"></div>'
		);
	$tabform->getTab("properties")->readOnly(
		-label=>"Relatives to Include",
		-value=>WebGUI::Form::checkbox({
				checked=>$selfChecked,
				name=>"assetsToInclude",
				value=>"self"
				}).'Self<br />'
			.WebGUI::Form::checkbox({
				checked=>$siblingsChecked,
				name=>"assetsToInclude",
				value=>"siblings"
				}).'Siblings<br />'
			.WebGUI::Form::checkbox({
				checked=>$descendantsChecked,
				name=>"assetsToInclude",
				value=>"descendants",
				extras=>'onChange="toggleEndPoint()"'
				}).'Descendants<br />'
			.WebGUI::Form::checkbox({
				checked=>$pedigreeChecked,
				name=>"assetsToInclude",
				value=>"pedigree"
				}).'Pedigree<br />'
		);
	my %options;
	tie %options, 'Tie::IxHash';
	%options = (
		'55'=>'Infinity',
		'1'=>'./a/ (+1)',
		'2'=>'./a/b/ (+2)',
		'3'=>'./a/b/c/ (+3)',
		'4'=>'./a/b/c/d/ (+4)',
		'5'=>'./a/b/c/d/e/ (+5)'
		);
	$tabform->getTab("properties")->raw(
		'</tbody><tbody id="navEnd"><tr><td class="formDescription">End Point</td><td>'
		.WebGUI::Form::selectList({
			name=>"endPoint",
			value=>[$self->getValue("endPoint")],
			options=>\%options
			})
		.'</td></tr></tbody><tbody>'
		);
	$tabform->getTab("display")->yesNo(
		-name=>'showSystemPages',
		-label=>WebGUI::International::get(30,'Navigation'),
		-value=>$self->getValue("showSystemPages")
		);
        $tabform->getTab("display")->yesNo(
                -name=>'showHiddenPages',
                -label=>WebGUI::International::get(31,'Navigation'),
                -value=>$self->getValue("showHiddenPages")
        	);
        $tabform->getTab("display")->yesNo(
                -name=>'showUnprivilegedPages',
                -label=>WebGUI::International::get(32,'Navigation'),
                -value=>$self->getValue("showUnprivilegedPages")
        	);
	my $start = $self->getValue("startPoint");
	$tabform->getTab("properties")->raw("<script type=\"text/javascript\">
		var displayNavEndPoint = true;
		function toggleEndPoint () {
			if (displayNavEndPoint) {
				document.getElementById('navEnd').style.display='none';
				displayNavEndPoint = false;
			} else {
				document.getElementById('navEnd').style.display='';
				displayNavEndPoint = true;
			}
		}
		function changeStartPoint () {
			var types = new Array();
			types['specificUrl']='<input type=\"text\" name=\"startPoint\" value=\"".$start."\">';
			types['relativeToRoot']='<select name=\"startPoint\"><option value=\"0\"".(($start == 0)?' selected=\"1\"':'').">/ (0)</option><option value=\"1\"".(($start eq "1")?' selected=\"1\"':'').">/a/ (+1)</option><option value=\"2\"".(($start eq "2")?' selected=\"1\"':'').">/a/b/ (+2)</option><option value=\"3\"".(($start eq "3")?' selected=\"1\"':'').">/a/b/c/ (+3)</option><option value=\"4\"".(($start eq "4")?' selected=\"1\"':'').">/a/b/c/d/ (+4)</option><option value=\"5\"".(($start eq "5")?' selected=\"1\"':'').">/a/b/c/d/e/ (+5)</option><option value=\"6\"".(($start eq "6")?' selected=\"1\"':'').">/a/b/c/d/e/f/ (+6)</option><option value=\"7\"".(($start eq "7")?' selected=\"1\"':'').">/a/b/c/d/e/f/g/h/ (+7)</option><option value=\"8\"".(($start eq "8")?' selected=\"1\"':'').">/a/b/c/d/e/f/g/h/ (+8)</option><option value=\"9\"".(($start eq "9")?' selected=\"1\"':'').">/a/b/c/d/e/f/g/h/i/ (+9)</option></select>';
			types['relativeToCurrentUrl']='<select name=\"startPoint\"><option value=\"-3\"".(($start eq "-3")?' selected=\"1\"':'').">../../.././ (-3)</option><option value=\"-2\"".(($start eq "-2")?' selected=\"1\"':'').">../.././ (-2)</option><option value=\"-1\"".(($start eq "-1")?' selected=\"1\"':'').">.././ (-1)</option><option value=\"0\"".(($start == 0)?' selected=\"1\"':'').">./ (0)</option><option value=\"1\"".(($start eq "1")?' selected=\"1\"':'').">./a/ (+1)</option><option value=\"2\"".(($start eq "2")?' selected=\"1\"':'').">./a/b/ (+2)</option><option value=\"3\"".(($start eq "3")?' selected=\"1\"':'').">./a/b/c/ (+3)</option></select>';
			document.getElementById('navStartPoint').innerHTML=types[document.getElementById('navStartType').options[document.getElementById('navStartType').selectedIndex].value];
		}
		".$afterScript."
		changeStartPoint();
		toggleEndPoint();
		</script>");
	my $previewButton;# = qq{
                          # <INPUT TYPE="button" VALUE="Preview" NAME="preview"
                          #  OnClick="
                          #      window.open('', 'navPreview', 'toolbar=no,status=no,location=no,scrollbars=yes,resizable=yes');
                          #      this.form.func.value='preview';
                          #      this.form.target = 'navPreview';
                          #      this.form.submit()">};
	my $saveButton = ' <input type="button" value="'.WebGUI::International::get(62).'" onClick="
		this.value=\''.WebGUI::International::get(452).'\';
		this.form.func.value=\'editSave\';
		this.form.target=\'_self\';
		this.form.submit();
		" >';
	$tabform->{_submit} = $previewButton." ".$saveButton;
	return $tabform;
}

sub getIcon {
	my $self = shift;
	my $small = shift;
	return $session{config}{extrasURL}.'/assets/small/navigation.gif' if ($small);
	return $session{config}{extrasURL}.'/assets/navigation.gif';
}

sub getName {
	return WebGUI::International::get("navigation","Navigation");
}


sub view {
	my $self = shift;
	# we've got to determine what our start point is based upon user conditions
	my ($start,$current);
	if (!exists $session{asset}) {
		$start = $current = $self;
	} elsif ($self->get("startType") eq "specificUrl") {
		$start = WebGUI::Asset->newByUrl($self->get("startPoint"));
	} elsif ($self->get("startType") eq "relativeToRoot") {
		unless (($self->get("startPoint")+1) >= $self->getLineageLength) {
			$start = WebGUI::Asset->newByLineage(substr($session{asset}->get("lineage"),0, ($self->get("startPoint") + 1) * 6));
		}
	} elsif ($self->get("startType") eq "relativeToCurrentUrl") {
		if ($self->get("startPoint") < 0) { 
			$start = WebGUI::Asset->newByLineage(substr($session{asset}->get("lineage"),0,
				($session{asset}->getLineageLength - $self->get("startPoint") + 1) * 6
				));
		} elsif ($self->get("startPoint") > 0) { 
			my $lineage = $session{asset}->getLineage;
			for (1..$self->get("startPoint")) {
				$lineage .= $self->formatRank(1);
			}
			$start = WebGUI::Asset->newByLineage($lineage);
		}
	}
	$current = $session{asset} unless (defined $current);
	$start = $session{asset} unless (defined $start); # if none of the above results in a start point, then the current page must be it
	my @includedRelationships = split("\n",$self->get("assetsToInclude"));
	my %rules;
	$rules{returnQuickReadObjects} = 1;
	$rules{endingLineageLength} = $start->getLineageLength+$self->get("endPoint");
	$rules{assetToPedigree} = $current if (isIn("pedigree",@includedRelationships));
	my $assets = $start->getLineage(\@includedRelationships,\%rules);	
	my $var = {'page_loop' => []};
	my @interestingProperties = ('assetId', 'parentId', 'title', 'ownerUserId', 'synopsis', 'newWindow', 'menuTitle');
	foreach my $property (@interestingProperties) {
		$var->{'currentPage.'.$property} = $current->get($property);
	}
	$var->{'currentPage.isHome'} = ($current->getId eq $session{setting}{defaultPage});
	$var->{'currentPage.url'} = $current->getUrl;
    	$var->{'currentPage.hasChild'} = $current->hasChildren;
	my $currentLineage = $current->get("lineage");
	my @linesToSkip;
	my $absoluteDepthOfLastPage;
	foreach my $asset (@{$assets}) {
		# skip pages we shouldn't see
		my $skip = 0;
		my $pageLineage = $asset->get("lineage");
		foreach my $lineage (@linesToSkip) {
			$skip = 1 if ($lineage =~ m/^$pageLineage/);
		}
		next if ($skip);
		if ($asset->get("isHidden") && !$self->get("showHiddenPages")) {
			push (@linesToSkip,$asset->getId);
			next;
		}
		if ($asset->get("isSystem") && !$self->get("showSystemPages")) {
			push (@linesToSkip,$asset->getId);
			next;
		}
		unless ($self->get("showUnprivilegedPages") || $asset->canView) {
			push (@linesToSkip,$asset->getId);
			next;
		}
		my $pageData = {};
		foreach my $property (@interestingProperties) {
			$pageData->{"page.".$property} = $asset->get($property);
		}
		# build nav variables
		$pageData->{"page.absDepth"} = $asset->getLineageLength;
		$pageData->{"page.relDepth"} = $asset->getLineageLength - $start->getLineageLength;
		$pageData->{"page.isSystem"} = $asset->get("isSystem");
		$pageData->{"page.isHidden"} = $asset->get("isHidden");
		$pageData->{"page.isViewable"} = $asset->canView;
		$pageData->{"page.url"} = $asset->getUrl;
		my $indent = $pageData->{"page.relDepth"};
		$pageData->{"page.indent_loop"} = [];
		push(@{$pageData->{"page.indent_loop"}},{'indent'=>$_}) for(1..$indent);
		$pageData->{"page.indent"} = "&nbsp;&nbsp;&nbsp;" x $indent;
		$pageData->{"page.isBranchRoot"} = ($pageData->{"page.absDepth"} == 1);
		$pageData->{"page.isTopOfBranch"} = ($pageData->{"page.absDepth"} == 2);
		$pageData->{"page.isChild"} = ($asset->get("parentId") eq $current->getId);
		$pageData->{"page.isParent"} = ($asset->getId eq $current->get("parentId"));
		$pageData->{"page.isCurrent"} = ($asset->getId eq $current->getId);
		$pageData->{"page.isDescendant"} = ( $currentLineage =~ m/^$pageLineage/ && !$pageData->{"page.isCurrent"});
		$pageData->{"page.isAnscestor"} = ( $pageLineage =~ m/^$currentLineage/ && !$pageData->{"page.isCurrent"});
		my $currentBranchLineage = substr($currentLineage,0,12);
		$pageData->{"page.inBranchRoot"} = ($currentBranchLineage =~ m/^$pageLineage/);
		$pageData->{"page.isSibling"} = (
			$pageData->{"page.inBranchRoot"} && 
			$asset->getLineageLength == $current->getLineageLength &&
			!$pageData->{"page.isCurrent"}
			);
		$pageData->{"page.inBranch"} = ( 
			$pageData->{"page.isCurrent"} ||
			$pageData->{"page.isAncestor"} ||
			$pageData->{"page.isSibling"} ||
			$pageData->{"page.isDescendant"}
			);
		$pageData->{"page.depthIs".$pageData->{"page.absDepth"}} = 1;
		$pageData->{"page.relativeDepthIs".$pageData->{"page.relDepth"}} = 1;
		my $depthDiff = ($absoluteDepthOfLastPage) ? ($absoluteDepthOfLastPage - $pageData->{'page.absDepth'}) : 0;
		if ($depthDiff > 0) {
			$pageData->{"page.depthDiff"} = $depthDiff if ($depthDiff > 0);
			$pageData->{"page.depthDiffIs".$depthDiff} = 1;
			push(@{$pageData->{"page.depthDiff_loop"}},{}) for(1..$depthDiff);
		}
		$absoluteDepthOfLastPage = $pageData->{"page.absDepth"};
		$pageData->{"page.hasChild"} = $asset->hasChildren;
		my $parent = $self->getParent;
		if (defined $parent) {
			foreach my $property (@interestingProperties) {
				$pageData->{"page.parent.".$property} = $parent->get($property);
			}
			$pageData->{"page.parent.url"} = $parent->getUrl;	
			# these next two variables can be very inefficient, consider getting rid of them
			my $parentsFirstChild = $parent->getFirstChild;
			if (defined $parentsFirstChild) {
				$pageData->{"page.isRankedFirst"} = ($asset->getId == $parentsFirstChild->getId);
			}
			my $parentsLastChild = $parent->getLastChild;
			if (defined $parentsLastChild) {
				$pageData->{"page.isRankedLast"} = ($asset->getId == $parentsLastChild->getId);
			}
		}
		push(@{$var->{page_loop}}, $pageData);	
	}
	return $self->processTemplate($var,"Navigation",$self->get("templateId"));
}


sub www_edit {
        my $self = shift;
        return WebGUI::Privilege::insufficient() unless $self->canEdit;
	$self->getAdminConsole->setHelp("navigation add/edit");
        return $self->getAdminConsole->render($self->getEditForm->print,WebGUI::International::get("22","Navigation"));
}


#-------------------------------------------------------------------
# we eventually should reaadd this
sub www_preview {
	my $self = shift;
	$session{var}{adminOn} = 0;
	return WebGUI::Privilege::insufficient() unless (WebGUI::Grouping::isInGroup(3));
	my $nav = WebGUI::Navigation->new(	depth=>$session{form}{depth},
						method=>$session{form}{method},
						startAt=>$session{form}{startAt},
						stopAtLevel=>$session{form}{stopAtLevel},
						templateId=>$session{form}{templateId},
						showSystemPages=>$session{form}{showSystemPages},
						showHiddenPages=>$session{form}{showHiddenPages},
						showUnprivilegedPages=>$session{form}{showUnprivilegedPages},
	                       			'reverse'=>$session{form}{'reverse'},
                                );
	my $output = qq(
		<table width="100%" border="0" cellpadding="5" cellspacing="0">
		<tr><td class="tableHeader" valign="top">
		Configuration
		</td><td class="tableHeader" valign="top">Output</td></tr>
		<tr><td class="tableHeader" valign="top">
		<font size=1>
			Identifier: $session{form}{identifier}<br>
			startAt: $session{form}{startAt}<br>
			method: $session{form}{method}<br>
			stopAtLevel: $session{form}{stopAtLevel}<br>
			depth: $session{form}{depth}<br>
			templateId: $session{form}{templateId}<br>
			reverse: $session{form}{'reverse'}<br>
			showSystemPages: $session{form}{showSystemPages}<br>
			showHiddenPages: $session{form}{showHiddenPages}<br>
			showUnprivilegedPages: $session{form}{showUnprivilegedPages}<br>
		</font>
		</td><td class="tableData" valign="top">
		) . $nav->build . qq(</td></tr></table>);
	
	# Because of the way the system is set up, the preview is cached. So let's remove it again...
	WebGUI::Cache->new($nav->{_identifier}."$session{page}{pageId}", "Navigation-".$session{config}{configFile})->delete;
	
	return _submenu($output,"preview"); 
}

1;
