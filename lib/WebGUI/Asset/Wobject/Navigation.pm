package WebGUI::Asset::Wobject::Navigation;

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
use Tie::IxHash;
use WebGUI::Asset::Wobject;
use WebGUI::ErrorHandler;
use WebGUI::Form;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::TabForm;
use WebGUI::URL;
use WebGUI::Utility;

our @ISA = qw(WebGUI::Asset::Wobject);


#-------------------------------------------------------------------
sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my $i18n = WebGUI::International->new($session,"Asset_Navigation");
	push(@{$definition}, {
		assetName=>$i18n->get("assetName"),
		icon=>'navigation.gif',
		tableName=>'Navigation',
		className=>'WebGUI::Asset::Wobject::Navigation',
		properties=>{
			templateId =>{
				fieldType=>"template",
				defaultValue=>'PBtmpl0000000000000048'
				},
			assetsToInclude=>{
				fieldType=>'checkList',
				defaultValue=>"descendants"
				},
			startType=>{
				fieldType=>'selectBox',
				defaultValue=>"relativeToCurrentUrl"
				},
			startPoint=>{
				fieldType=>'text',
				defaultValue=>0
				},
			ancestorEndPoint=>{
				fieldType=>'selectBox',
				defaultValue=>55
				},
			descendantEndPoint=>{
				fieldType=>'selectBox',
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
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------
sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm;
	my $i18n = WebGUI::International->new($self->session, "Asset_Navigation");
   	$tabform->getTab("display")->template(
      		-value=>$self->getValue('templateId'),
      		-namespace=>"Navigation",
		-label=>$i18n->get(1096),
		-hoverHelp=>$i18n->get('1096 description'),
   		);
	$tabform->hidden({
		name=>"returnUrl",
		value=>$self->session->form->process("returnUrl")
		});
	my ($descendantsChecked, $ancestorsChecked, $selfChecked, $pedigreeChecked, $siblingsChecked);
	my @assetsToInclude = split("\n",$self->getValue("assetsToInclude"));
	my $afterScript;
	foreach my $item (@assetsToInclude) {
		if ($item eq "self") {
			$selfChecked = 1;
		} elsif ($item eq "descendants") {
			$descendantsChecked = 1;
			$afterScript = "displayNavEndPoint = false;";
		} elsif ($item eq "ancestors") {
			$ancestorsChecked = 1;
		} elsif ($item eq "siblings") {
			$siblingsChecked = 1;
		} elsif ($item eq "pedigree") {
			$pedigreeChecked = 1;
		}
	}
	$tabform->getTab("properties")->selectBox(
		-name=>"startType",
		-options=>{
			specificUrl=>$i18n->get('Specific URL'),
			relativeToCurrentUrl=>$i18n->get('Relative To Current URL'),
			relativeToRoot=>$i18n->get('Relative To Root')
			},
		-value=>[$self->getValue("startType")],
		-label=>$i18n->get("Start Point Type"),
		-hoverHelp=>$i18n->get("Start Point Type description"),
		-id=>"navStartType",
		-extras=>'onchange="changeStartPoint()"'
		);
	$tabform->getTab("properties")->readOnly(
		-label=>$i18n->get("Start Point"),
		-hoverHelp=>$i18n->get("Start Point description"),
		-value=>'<div id="navStartPoint"></div>'
		);
	my %options = ();
	tie %options, 'Tie::IxHash';
	%options = (
		'1'=>'../ (-1)',
		'2'=>'../../ (-2)',
		'3'=>'../../../ (-3)',
		'4'=>'../../../../ (-4)',
		'5'=>'../../../../../ (-5)',
		'55'=>$i18n->get('Infinity')
		);
	$tabform->getTab("properties")->raw(
		'</tbody><tbody id="navAncestorEnd"><tr><td class="formDescription">'.$i18n->get("Ancestor End Point").'</td><td>'
		.WebGUI::Form::selectBox({
			name=>"ancestorEndPoint",
			value=>[$self->getValue("ancestorEndPoint")],
			options=>\%options
			})
		.'</td></tr></tbody><tbody>'
		);
	$tabform->getTab("properties")->readOnly(
		-label=>$i18n->get("Relatives To Include"),
		-hoverHelp=>$i18n->get("Relatives To Include description"),
		-value=>WebGUI::Form::checkbox({
				checked=>$ancestorsChecked,
				name=>"assetsToInclude",
				extras=>'onChange="toggleAncestorEndPoint()"',
				value=>"ancestors"
				}).$i18n->get('Ancestors').'<br />'
			.WebGUI::Form::checkbox({
				checked=>$selfChecked,
				name=>"assetsToInclude",
				value=>"self"
				}).$i18n->get('Self').'<br />'
			.WebGUI::Form::checkbox({
				checked=>$siblingsChecked,
				name=>"assetsToInclude",
				value=>"siblings"
				}).$i18n->get('Siblings').'<br />'
			.WebGUI::Form::checkbox({
				checked=>$descendantsChecked,
				name=>"assetsToInclude",
				value=>"descendants",
				extras=>'onChange="toggleDescendantEndPoint()"'
				}).$i18n->get('Descendants').'<br />'
			.WebGUI::Form::checkbox({
				checked=>$pedigreeChecked,
				name=>"assetsToInclude",
				value=>"pedigree"
				}).$i18n->get('Pedigree').'<br />'
		);
	%options = ();
	tie %options, 'Tie::IxHash';
	%options = (
		'1'=>'./a/ (+1)',
		'2'=>'./a/b/ (+2)',
		'3'=>'./a/b/c/ (+3)',
		'4'=>'./a/b/c/d/ (+4)',
		'5'=>'./a/b/c/d/e/ (+5)',
		'55'=>$i18n->get('Infinity')
		);
	$tabform->getTab("properties")->raw(
		'</tbody><tbody id="navDescendantEnd"><tr><td class="formDescription">'.$i18n->get('Descendant End Point').'</td><td>'
		.WebGUI::Form::selectBox({
			name=>"descendantEndPoint",
			value=>[$self->getValue("descendantEndPoint")],
			options=>\%options
			})
		.'</td></tr></tbody><tbody>'
		);
	$tabform->getTab("display")->yesNo(
		-name=>'showSystemPages',
		-label=>$i18n->get(30),
		-hoverHelp=>$i18n->get('30 description'),
		-value=>$self->getValue("showSystemPages")
		);
        $tabform->getTab("display")->yesNo(
                -name=>'showHiddenPages',
                -label=>$i18n->get(31),
                -hoverHelp=>$i18n->get('31 description'),
                -value=>$self->getValue("showHiddenPages")
        	);
        $tabform->getTab("display")->yesNo(
                -name=>'showUnprivilegedPages',
                -label=>$i18n->get(32),
                -hoverHelp=>$i18n->get('32 description'),
                -value=>$self->getValue("showUnprivilegedPages")
        	);
	my $start = $self->getValue("startPoint");
	$tabform->getTab("properties")->raw("<script type=\"text/javascript\">
		//<![CDATA[
		var displayNavDescendantEndPoint = true;
		var displayNavAncestorEndPoint = true;
		function toggleDescendantEndPoint () {
			if (displayNavDescendantEndPoint) {
				document.getElementById('navDescendantEnd').style.display='none';
				displayNavDescendantEndPoint = false;
			} else {
				document.getElementById('navDescendantEnd').style.display='';
				displayNavDescendantEndPoint = true;
			}
		}
		function toggleAncestorEndPoint () {
			if (displayNavAncestorEndPoint) {
				document.getElementById('navAncestorEnd').style.display='none';
				displayNavAncestorEndPoint = false;
			} else {
				document.getElementById('navAncestorEnd').style.display='';
				displayNavAncestorEndPoint = true;
			}
		}
		function changeStartPoint () {
			var types = new Array();
			types['specificUrl']='<input type=\"text\" name=\"startPoint\" value=\"".$start."\" />';
			types['relativeToRoot']='<select name=\"startPoint\"><option value=\"0\"".(($start == 0)?' selected=\"1\"':'').">/ (0)</option><option value=\"1\"".(($start eq "1")?' selected=\"1\"':'').">/a/ (+1)</option><option value=\"2\"".(($start eq "2")?' selected=\"1\"':'').">/a/b/ (+2)</option><option value=\"3\"".(($start eq "3")?' selected=\"1\"':'').">/a/b/c/ (+3)</option><option value=\"4\"".(($start eq "4")?' selected=\"1\"':'').">/a/b/c/d/ (+4)</option><option value=\"5\"".(($start eq "5")?' selected=\"1\"':'').">/a/b/c/d/e/ (+5)</option><option value=\"6\"".(($start eq "6")?' selected=\"1\"':'').">/a/b/c/d/e/f/ (+6)</option><option value=\"7\"".(($start eq "7")?' selected=\"1\"':'').">/a/b/c/d/e/f/g/ (+7)</option><option value=\"8\"".(($start eq "8")?' selected=\"1\"':'').">/a/b/c/d/e/f/g/h/ (+8)</option><option value=\"9\"".(($start eq "9")?' selected=\"1\"':'').">/a/b/c/d/e/f/g/h/i/ (+9)</option></select>';
			types['relativeToCurrentUrl']='<select name=\"startPoint\"><option value=\"-3\"".(($start eq "-3")?' selected=\"1\"':'').">../../.././ (-3)</option><option value=\"-2\"".(($start eq "-2")?' selected=\"1\"':'').">../.././ (-2)</option><option value=\"-1\"".(($start eq "-1")?' selected=\"1\"':'').">.././ (-1)</option><option value=\"0\"".(($start == 0 || $start > 0)?' selected=\"1\"':'').">./ (0)</option></select>';
			document.getElementById('navStartPoint').innerHTML=types[document.getElementById('navStartType').options[document.getElementById('navStartType').selectedIndex].value];
		}
		".$afterScript."
		changeStartPoint();
		".($descendantsChecked ? "" : "toggleDescendantEndPoint();")."
		".($ancestorsChecked ? "" : "toggleAncestorEndPoint();")."
		//]]>
		</script>");
	my $previewButton;# = qq{
                          # <INPUT TYPE="button" VALUE="Preview" NAME="preview"
                          #  OnClick="
                          #      window.open('', 'navPreview', 'toolbar=no,status=no,location=no,scrollbars=yes,resizable=yes');
                          #      this.form.func.value='preview';
                          #      this.form.target = 'navPreview';
                          #      this.form.submit()">};
	my $saveButton = ' <input type="button" value="'.$i18n->get(62,'WebGUI').'" onclick="
		this.value=\''.$i18n->get(452,'WebGUI').'\';
		this.form.func.value=\'editSave\';
		this.form.target=\'_self\';
		this.form.submit();
		" />';
	$tabform->{_submit} = $previewButton." ".$saveButton;
	return $tabform;
}



#-------------------------------------------------------------------

=head2 getToolbar ( )

Returns a toolbar with a set of icons that hyperlink to functions that delete, edit, promote, demote, cut, and copy.

=cut

sub getToolbar {
	my $self = shift;
	if ($self->getToolbarState) {
		my $returnUrl;
		if (exists $self->session->asset) {
			$returnUrl = ";proceed=goBackToPage;returnUrl=".$self->session->url->escape($self->session->asset->getUrl);	
		}
		my $toolbar;
		if (!$self->isLocked || $self->get("isLockedBy") eq $self->session->user->profileField("userId")) {
			$toolbar = $self->session->icon->edit('func=edit'.$returnUrl,$self->get("url"));
		}
		my $i18n = WebGUI::International->new($self->session, "Asset");
		return '<script type="text/javascript">
                var contextMenu = new contextMenu_createWithImage("'.$self->getIcon(1).'","'.$self->getId.'","'.$self->getName.'");
                contextMenu.addLink("'.$self->getUrl("func=copy").'","'.$i18n->get("copy").'");
                contextMenu.addLink("'.$self->getUrl("func=manageAssets").'","'.$i18n->get("manage").'");
                contextMenu.addLink("'.$self->getUrl.'","'.$i18n->get("view").'");
                contextMenu.print();
                </script>'.$toolbar;
	}
	return $self->SUPER::getToolbar();
}



#-------------------------------------------------------------------
sub view {
	my $self = shift;
	# we've got to determine what our start point is based upon user conditions
	my $start;
	$self->session->asset = WebGUI::Asset->newByUrl unless (exists $self->session->asset);
	my $current = $self->session->asset;
	if ($self->get("startType") eq "specificUrl") {
		$start = WebGUI::Asset->newByUrl($self->get("startPoint"));
	} elsif ($self->get("startType") eq "relativeToRoot") {
		unless (($self->get("startPoint")+1) >= $current->getLineageLength) {
			$start = WebGUI::Asset->newByLineage(substr($current->get("lineage"),0, ($self->get("startPoint") + 1) * 6));
		}
	} elsif ($self->get("startType") eq "relativeToCurrentUrl") {
		$start = WebGUI::Asset->newByLineage(substr($current->get("lineage"),0, ($current->getLineageLength + $self->get("startPoint")) * 6));
	}
	$start = $current unless (defined $start); # if none of the above results in a start point, then the current page must be it
	my @includedRelationships = split("\n",$self->get("assetsToInclude"));
	my %rules;
	$rules{returnObjects} = 1;
	$rules{endingLineageLength} = $start->getLineageLength+$self->get("descendantEndPoint");
	$rules{assetToPedigree} = $current if (isIn("pedigree",@includedRelationships));
	$rules{ancestorLimit} = $self->get("ancestorEndPoint");
	my $assets = $start->getLineage(\@includedRelationships,\%rules);	
	my $var = {'page_loop' => []};
	my @interestingProperties = ('assetId', 'parentId', 'ownerUserId', 'synopsis', 'newWindow');
	foreach my $property (@interestingProperties) {
		$var->{'currentPage.'.$property} = $current->get($property);
	}
	$var->{'currentPage.menuTitle'} = $current->getMenuTitle;
	$var->{'currentPage.title'} = $current->getTitle;
	$var->{'currentPage.isHome'} = ($current->getId eq $self->session->setting->get("defaultPage"));
	$var->{'currentPage.url'} = $current->getUrl;
    	$var->{'currentPage.hasChild'} = $current->hasChildren;
	my $currentLineage = $current->get("lineage");
	my $lineageToSkip = "noskip";
	my $absoluteDepthOfLastPage;
	my %lastChildren;
	foreach my $asset (@{$assets}) {
		# skip pages we shouldn't see
		my $pageLineage = $asset->get("lineage");
		next if ($pageLineage =~ m/^$lineageToSkip/);
		if ($asset->get("isHidden") && !$self->get("showHiddenPages")) {
			$lineageToSkip = $pageLineage unless ($pageLineage eq "000001");
			next;
		}
		if ($asset->get("isSystem") && !$self->get("showSystemPages")) {
			$lineageToSkip = $pageLineage unless ($pageLineage eq "000001");
			next;
		}
		unless ($self->get("showUnprivilegedPages") || $asset->canView) {
			$lineageToSkip = $pageLineage unless ($pageLineage eq "000001");
			next;
		}
		my $pageData = {};
		foreach my $property (@interestingProperties) {
			$pageData->{"page.".$property} = $asset->get($property);
		}
		$pageData->{'page.menuTitle'} = $asset->getMenuTitle;
		$pageData->{'page.title'} = $asset->getTitle;
		# build nav variables
		$pageData->{"page.rank"} = $asset->getRank;
		$pageData->{"page.absDepth"} = $asset->getLineageLength;
		$pageData->{"page.relDepth"} = $asset->getLineageLength - $start->getLineageLength;
		$pageData->{"page.isSystem"} = $asset->get("isSystem");
		$pageData->{"page.isHidden"} = $asset->get("isHidden");
		$pageData->{"page.isViewable"} = $asset->canView;
		$pageData->{'page.isContainer'} = isIn($asset->get('className'), @{$self->session->config->get("assetContainers")});
  		$pageData->{'page.isUtility'} = isIn($asset->get('className'), @{$self->session->config->get("utilityAssets")});
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
		$pageData->{"page.isDescendant"} = ( $pageLineage =~ m/^$currentLineage/ && !$pageData->{"page.isCurrent"});
		$pageData->{"page.isAncestor"} = ( $currentLineage =~ m/^$pageLineage/ && !$pageData->{"page.isCurrent"});
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
		$pageData->{"page.depthDiff"} = $depthDiff;
		$pageData->{"page.depthDiffIs".$depthDiff} = 1;
		if ($depthDiff > 0) {
			push(@{$pageData->{"page.depthDiff_loop"}},{}) for(1..$depthDiff);
		}
		$absoluteDepthOfLastPage = $pageData->{"page.absDepth"};
		$pageData->{"page.hasChild"} = $asset->hasChildren;
                ++$var->{"currentPage.hasSibling"}
                        if $pageData->{"page.isSibling"};
                ++$var->{"currentPage.hasViewableSiblings"}
                        if ($pageData->{"page.isSibling"} && $pageData->{"isViewable"});
                ++$var->{"currentPage.hasViewableChildren"}
                        if ($pageData->{"page.isChild"} && $pageData->{"isViewable"});

		my $parent = $asset->getParent;
		if (defined $parent) {
			foreach my $property (@interestingProperties) {
				$pageData->{"page.parent.".$property} = $parent->get($property);
			}
			$pageData->{'page.parent.menuTitle'} = $parent->getMenuTitle;
			$pageData->{'page.parent.title'} = $parent->getTitle;
			$pageData->{"page.parent.url"} = $parent->getUrl;	
			$pageData->{"page.isRankedFirst"} = 1 unless exists $lastChildren{$parent->getId};
			$lastChildren{$parent->getId} = $asset->getId;			
		}
		push(@{$var->{page_loop}}, $pageData);	
	}
	my $counter;
	for($counter=0 ; $counter < scalar( @{$var->{page_loop}} ) ; $counter++) {
		@{$var->{page_loop}}[$counter]->{"page.isRankedLast"} = 1 if 
			($lastChildren{@{$var->{page_loop}}[$counter]->{"page.parent.assetId"}} 
				eq @{$var->{page_loop}}[$counter]->{"page.assetId"});
	}
	#use Data::Dumper;$self->session->errorHandler->warn(Dumper($var));
	return $self->processTemplate($var,$self->get("templateId"));
}

#-------------------------------------------------------------------
sub www_goBackToPage {
	my $self = shift;
	WebGUI::HTTP::setRedirect($self->session->form->process("returnUrl")) if ($self->session->form->process("returnUrl"));
	return "";
}


#-------------------------------------------------------------------
# we eventually should reaadd this
sub www_preview {
	my $self = shift;
	$self->session->var->get("adminOn") = 0;
	return $self->session->privilege->insufficient() unless ($self->session->user->isInGroup(3));
	my $nav = WebGUI::Navigation->new(	depth=>$self->session->form->process("depth"),
						method=>$self->session->form->process("method"),
						startAt=>$self->session->form->process("startAt"),
						stopAtLevel=>$self->session->form->process("stopAtLevel"),
						templateId=>$self->session->form->process("templateId"),
						showSystemPages=>$self->session->form->process("showSystemPages"),
						showHiddenPages=>$self->session->form->process("showHiddenPages"),
						showUnprivilegedPages=>$self->session->form->process("showUnprivilegedPages"),
	                       			'reverse'=>$self->session->form->process("'reverse'"),
                                );
	my $output = qq(
		<table width="100%" border="0" cellpadding="5" cellspacing="0">
		<tr><td class="tableHeader" valign="top">
		Configuration
		</td><td class="tableHeader" valign="top">Output</td></tr>
		<tr><td class="tableHeader" valign="top">
		<font size=1>
			Identifier: $self->session->form->process("identifier")<br />
			startAt: $self->session->form->process("startAt")<br />
			method: $self->session->form->process("method")<br />
			stopAtLevel: $self->session->form->process("stopAtLevel")<br />
			depth: $self->session->form->process("depth")<br />
			templateId: $self->session->form->process("templateId")<br />
			reverse: $self->session->form->process("'reverse'")<br />
			showSystemPages: $self->session->form->process("showSystemPages")<br />
			showHiddenPages: $self->session->form->process("showHiddenPages")<br />
			showUnprivilegedPages: $self->session->form->process("showUnprivilegedPages")<br />
		</font>
		</td><td class="tableData" valign="top">
		) . $nav->build . qq(</td></tr></table>);
	
	# Because of the way the system is set up, the preview is cached. So let's remove it again...
	WebGUI::Cache->new($self->session,$nav->{_identifier}."$session{page}{pageId}", "Navigation-".$self->session->config->getFilename)->delete;
	
	return _submenu($output,"preview"); 
}

1;
